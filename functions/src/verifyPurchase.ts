/**
 * verifyPurchase Cloud Function
 *
 * Purpose: Server-side verification of in-app purchases
 *
 * Flow:
 * 1. รับ purchaseToken จาก Client
 * 2. เช็ค duplicate purchase (token เคยใช้แล้วหรือยัง)
 * 3. Verify กับ Google Play Developer API
 * 4. เช็คสถานะ purchase (purchased/canceled/pending)
 * 5. Acknowledge purchase (required by Google Play)
 * 6. เพิ่ม balance ใน Firestore (atomic)
 * 7. บันทึก purchase record (ป้องกันใช้ซ้ำ)
 */

import {onRequest} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import * as admin from "firebase-admin";
import {google} from "googleapis";
import * as crypto from "crypto";
import {evaluateOffers} from "./energy/offerEngine";

// Initialize Firebase Admin
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

// Secret from Firebase
const GOOGLE_SERVICE_ACCOUNT = defineSecret("GOOGLE_SERVICE_ACCOUNT_JSON");

// ─── Product ID → Energy Amount Mapping ───
// ⚠️ ต้องตรงกับที่กำหนดใน Client!
const ENERGY_PRODUCTS: Record<string, number> = {
  "energy_100": 100,
  "energy_550": 550,
  "energy_1200": 1200,
  "energy_2000": 2000,
  "energy_first_purchase_200": 200,   // $1 = 200E Starter Deal (1-time)
  "energy_100_welcome": 100,
  "energy_550_welcome": 550,
  "energy_1200_welcome": 1200,
  "energy_2000_welcome": 2000,
};

// Legacy one-time products (backward compat — ใช้คู่กับ template-based check)
const ONE_TIME_PRODUCTS: Record<string, {
  claimField: string;
  errorMessage: string;
}> = {
  "energy_100_welcome": {
    claimField: "welcomeBonusClaimed",
    errorMessage: "Welcome bonus already claimed",
  },
  "energy_550_welcome": {
    claimField: "welcomeBonusClaimed",
    errorMessage: "Welcome bonus already claimed",
  },
  "energy_1200_welcome": {
    claimField: "welcomeBonusClaimed",
    errorMessage: "Welcome bonus already claimed",
  },
  "energy_2000_welcome": {
    claimField: "welcomeBonusClaimed",
    errorMessage: "Welcome bonus already claimed",
  },
};

/**
 * Check if an offer product has been claimed (template-based)
 * ตรวจจาก offers.active map — หา template ที่มี rewardConfig.productId ตรง
 */
async function isOfferProductClaimed(
  deviceId: string,
  productId: string
): Promise<boolean> {
  const userDoc = await db.collection("users").doc(deviceId).get();
  if (!userDoc.exists) return false;

  const activeOffers = userDoc.data()?.offers?.active || {};

  for (const [templateId, offerState] of Object.entries(activeOffers)) {
    const state = offerState as any;
    if (state.claimed) {
      const templateDoc = await db.collection("offer_templates").doc(templateId).get();
      const template = templateDoc.data();
      if (template?.rewardConfig?.productId === productId) {
        return true;
      }
    }
  }
  return false;
}

/**
 * Mark an offer as claimed after purchase verified
 */
async function markOfferClaimed(
  deviceId: string,
  productId: string
): Promise<void> {
  const userDoc = await db.collection("users").doc(deviceId).get();
  if (!userDoc.exists) return;

  const activeOffers = userDoc.data()?.offers?.active || {};

  for (const [templateId, offerState] of Object.entries(activeOffers)) {
    const state = offerState as any;
    if (!state.claimed) {
      const templateDoc = await db.collection("offer_templates").doc(templateId).get();
      const template = templateDoc.data();
      if (template?.rewardConfig?.productId === productId) {
        await userDoc.ref.update({
          [`offers.active.${templateId}.claimed`]: true,
          [`offers.active.${templateId}.claimedAt`]: admin.firestore.FieldValue.serverTimestamp(),
          [`offers.active.${templateId}.claimCount`]: (state.claimCount || 0) + 1,
        });
        console.log(`✅ [verifyPurchase] Marked offer "${state.slug}" as claimed`);
        break;
      }
    }
  }
}

// ✅ Package name ของ MIRO app
const PACKAGE_NAME = "com.tanabun.miro";

interface VerifyPurchaseRequest {
  purchaseToken: string;
  productId: string;
  deviceId: string;
}

export const verifyPurchase = onRequest(
  {
    secrets: [GOOGLE_SERVICE_ACCOUNT],
    timeoutSeconds: 30,
    memory: "512MiB",
    cors: "*",
  },
  async (req, res) => {
    // ─── Validate Request ───
    if (req.method !== "POST") {
      res.status(405).json({error: "Method not allowed"});
      return;
    }

    try {
      const body = req.body as VerifyPurchaseRequest;
      const {purchaseToken, productId, deviceId} = body;

      // Validate required fields
      if (!purchaseToken || !productId || !deviceId) {
        res.status(400).json({
          error: "Missing required fields",
          required: ["purchaseToken", "productId", "deviceId"],
        });
        return;
      }

      console.log(`🛒 [verifyPurchase] Request: ${productId} for ${deviceId}`);

      // ─── 1. Check if product is valid ───
      const energyAmount = ENERGY_PRODUCTS[productId];
      if (!energyAmount) {
        console.log(`❌ [verifyPurchase] Invalid product: ${productId}`);
        res.status(400).json({
          error: "Invalid product ID",
          productId,
        });
        return;
      }

      // ─── 2. Check duplicate purchase (by token hash) ───
      const purchaseHash = hashPurchaseToken(purchaseToken);
      const purchaseRecordRef = db
        .collection("purchase_records")
        .doc(purchaseHash);
      const existingPurchase = await purchaseRecordRef.get();

      if (existingPurchase.exists) {
        console.log(`⚠️ [verifyPurchase] Duplicate purchase: ${purchaseHash}`);

        const userDoc = await db.collection("users").doc(deviceId).get();
        const currentBalance = userDoc.exists ? (userDoc.data()?.balance ?? 0) : 0;

        res.status(409).json({
          error: "Purchase already verified",
          balance: currentBalance,
          verified: true,
        });
        return;
      }

      // ─── 2b. One-time offer validation (template-based + legacy fallback) ───
      // Template-based check
      const templateClaimed = await isOfferProductClaimed(deviceId, productId);
      if (templateClaimed) {
        console.log(
          `🚫 [verifyPurchase] Offer product already claimed (template): ${productId} for ${deviceId}`
        );
        res.status(409).json({
          error: "This offer has already been claimed",
          alreadyClaimed: true,
        });
        return;
      }

      // Legacy fallback (for users not yet migrated)
      const oneTimeConfig = ONE_TIME_PRODUCTS[productId];
      if (oneTimeConfig) {
        const userDoc = await db.collection("users").doc(deviceId).get();
        if (!userDoc.exists) {
          res.status(404).json({error: "User not found"});
          return;
        }

        const offers = userDoc.data()?.offers || {};
        if (offers[oneTimeConfig.claimField] === true) {
          console.log(
            `🚫 [verifyPurchase] One-time offer already claimed (legacy): ${productId} for ${deviceId}`
          );
          res.status(409).json({
            error: oneTimeConfig.errorMessage,
            alreadyClaimed: true,
          });
          return;
        }
      }

      // ─── 3. Verify with Google Play Developer API ───
      console.log("🔍 [verifyPurchase] Verifying with Google Play API...");

      const serviceAccount = JSON.parse(GOOGLE_SERVICE_ACCOUNT.value());
      const auth = new google.auth.GoogleAuth({
        credentials: serviceAccount,
        scopes: ["https://www.googleapis.com/auth/androidpublisher"],
      });

      const androidPublisher = google.androidpublisher({
        version: "v3",
        auth,
      });

      // ⚠️ สำหรับ consumable products (ใช้แล้วหมด)
      // ถ้าเป็น subscription ต้องใช้ androidPublisher.purchases.subscriptions.get()
      const purchaseResponse = await androidPublisher.purchases.products.get({
        packageName: PACKAGE_NAME,
        productId,
        token: purchaseToken,
      });

      const purchase = purchaseResponse.data;
      console.log("📦 [verifyPurchase] Google Play response:", {
        orderId: purchase.orderId,
        purchaseState: purchase.purchaseState,
        acknowledgementState: purchase.acknowledgementState,
      });

      // ─── 4. Check purchase state ───
      // purchaseState: 0 = purchased, 1 = canceled, 2 = pending
      if (purchase.purchaseState !== 0) {
        console.log(`❌ [verifyPurchase] Purchase not completed: state=${purchase.purchaseState}`);
        res.status(403).json({
          error: "Purchase not completed",
          purchaseState: purchase.purchaseState,
        });
        return;
      }

      // ─── 5. Acknowledge purchase (required by Google Play) ───
      // acknowledgementState: 0 = not acknowledged, 1 = acknowledged
      if (purchase.acknowledgementState === 0) {
        console.log("✅ [verifyPurchase] Acknowledging purchase...");

        await androidPublisher.purchases.products.acknowledge({
          packageName: PACKAGE_NAME,
          productId,
          token: purchaseToken,
        });
      }

      // ─── 6. Calculate Bonus Energy (tier + promotion + dynamic offers) ───
      const userDoc = await db.collection("users").doc(deviceId).get();
      const userData_ = userDoc.exists ? userDoc.data()! : {};
      const tierBonusRate = userData_.bonusRate || 0;

      // Legacy promotion bonus
      const promoBonusRate = userData_.promotionBonusRate || 0;
      const promoExpires = userData_.promotionExpiresAt?.toDate?.() || new Date(0);
      const promoType = userData_.promotionType || "";
      const isPromoActive = promoExpires > new Date() && promoBonusRate > 0;

      // Dynamic offer bonus — check active offers with rewardType 'bonus_rate'
      let offerBonusRate = 0;
      let offerBonusSlug = "";
      let offerBonusTemplateId = "";
      const activeOffersMap = userData_.offers?.active || {};
      const nowDate = new Date();

      for (const [templateId, offerState] of Object.entries(activeOffersMap)) {
        const state = offerState as any;
        if (state.claimed) continue;
        if (state.expiresAt) {
          const expiryDate = state.expiresAt.toDate();
          if (expiryDate <= nowDate) continue;
        }
        // Load template to check rewardType
        const templateDoc = await db.collection("offer_templates").doc(templateId).get();
        if (!templateDoc.exists) continue;
        const template = templateDoc.data()!;
        if (template.rewardType === "bonus_rate" && template.isActive) {
          const rate = template.rewardConfig?.bonusRate || 0;
          if (rate > offerBonusRate) {
            offerBonusRate = rate;
            offerBonusSlug = template.slug || templateId;
            offerBonusTemplateId = templateId;
          }
        }
      }

      // Use the highest bonus: tier vs legacy promo vs dynamic offer
      const bonusRate = Math.max(
        tierBonusRate,
        isPromoActive ? promoBonusRate : 0,
        offerBonusRate
      );

      let bonusSource = "tier";
      if (bonusRate === offerBonusRate && offerBonusRate > 0) {
        bonusSource = `offer:${offerBonusSlug}`;
      } else if (bonusRate === promoBonusRate && isPromoActive) {
        bonusSource = `promo:${promoType}`;
      }

      const baseEnergy = energyAmount;
      const bonusEnergy = Math.floor(baseEnergy * bonusRate);
      const totalEnergy = baseEnergy + bonusEnergy;

      console.log(
        `💎 [verifyPurchase] Purchase: ${baseEnergy} + ${bonusEnergy} bonus ` +
        `(${bonusRate * 100}% [${bonusSource}]) = ${totalEnergy}`
      );

      // ─── 7. Add energy to Firestore (atomic transaction) ───
      const userRef = db.collection("users").doc(deviceId);
      const result = await db.runTransaction(async (transaction) => {
        const doc = await transaction.get(userRef);

        if (!doc.exists) {
          throw new Error("User not found");
        }

        const userData = doc.data()!;
        const currentBalance = userData.balance || 0;
        const updated = currentBalance + totalEnergy;

        const updates: Record<string, any> = {
          balance: updated,
          totalPurchased: (userData.totalPurchased || 0) + totalEnergy,
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        };

        // Mark one-time offer as claimed (prevent re-purchase)
        if (oneTimeConfig) {
          updates[`offers.${oneTimeConfig.claimField}`] = true;
          updates[`offers.${oneTimeConfig.claimField}At`] =
            admin.firestore.FieldValue.serverTimestamp();
        }

        transaction.update(userRef, updates);

        return {
          newBalance: updated,
          userData,
        };
      });

      const newBalance = result.newBalance;
      const userData = result.userData;

      // ─── 8. Record purchase (prevent duplicates) ───
      await purchaseRecordRef.set({
        deviceId,
        productId,
        energyAmount: totalEnergy, // รวม bonus แล้ว
        baseEnergy,
        bonusEnergy,
        bonusRate,
        // เก็บ token แค่ส่วนหน้า (security: don't store full token)
        purchaseTokenPreview: purchaseToken.substring(0, 20) + "...",
        verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
        orderId: purchase.orderId,
        purchaseTimeMillis: purchase.purchaseTimeMillis,
        status: "verified",
      });

      // ─── 9. Log transaction ───
      await db.collection("transactions").add({
        deviceId,
        miroId: userData.miroId || "unknown",
        type: "purchase",
        amount: totalEnergy,
        balanceAfter: newBalance,
        description: `Purchased ${baseEnergy} Energy` +
          (bonusEnergy > 0 ? ` + ${bonusEnergy} Bonus (${bonusRate * 100}%)` : ""),
        metadata: {
          productId,
          baseEnergy,
          bonusRate,
          bonusEnergy,
          totalEnergy,
          purchaseToken: purchaseToken.substring(0, 20) + "...",
        },
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`✅ [verifyPurchase] Success: ${productId} (+${totalEnergy}) → ${newBalance}`);

      // ─── Mark template-based offer as claimed ───
      try {
        await markOfferClaimed(deviceId, productId);
      } catch (e) {
        console.error("[verifyPurchase] markOfferClaimed error:", e);
      }

      // ─── Mark bonus_rate offer as claimed (one-time use) ───
      if (offerBonusTemplateId && bonusRate === offerBonusRate && offerBonusRate > 0) {
        try {
          const userRef2 = db.collection("users").doc(deviceId);
          const offerSnap = await userRef2.get();
          const currentState = offerSnap.data()?.offers?.active?.[offerBonusTemplateId];
          if (currentState && !currentState.claimed) {
            await userRef2.update({
              [`offers.active.${offerBonusTemplateId}.claimed`]: true,
              [`offers.active.${offerBonusTemplateId}.claimedAt`]: admin.firestore.FieldValue.serverTimestamp(),
              [`offers.active.${offerBonusTemplateId}.claimCount`]: (currentState.claimCount || 0) + 1,
            });
            console.log(`✅ [verifyPurchase] Marked bonus_rate offer "${offerBonusSlug}" as claimed`);
          }
        } catch (e) {
          console.error("[verifyPurchase] markBonusRateOffer error:", e);
        }
      }

      // ─── Evaluate offers triggered by this purchase
      try {
        await evaluateOffers(deviceId, "first_purchase_complete", {
          productId: productId,
        });
      } catch (e) {
        console.error("[verifyPurchase] evaluateOffers error:", e);
      }

      // ─── Response ───
      res.status(200).json({
        success: true,
        balance: newBalance,
        energyAdded: totalEnergy,
        baseEnergy,
        bonusEnergy,
        bonusRate,
        promotionActive: isPromoActive,
        promotionType: isPromoActive ? promoType : undefined,
        productId,
      });
    } catch (error: any) {
      console.error("❌ [verifyPurchase] Error:", error);

      // ถ้า error จาก Google Play API
      if (error.code === 400 || error.code === 401 || error.code === 404) {
        res.status(403).json({
          error: "Invalid purchase token",
          details: error.message,
        });
        return;
      }

      res.status(500).json({
        error: "Internal server error",
        message: error.message,
      });
    }
  }
);

/**
 * Hash purchase token (SHA-256) สำหรับเก็บใน Firestore
 * ไม่เก็บ token เต็มๆ เพื่อความปลอดภัย
 */
function hashPurchaseToken(token: string): string {
  return crypto.createHash("sha256").update(token).digest("hex");
}
