/**
 * offersV2.ts
 *
 * Offer System V3 — getActiveOffers, dismissOffer, claimOffer
 *
 * Offer Priority (แสดงตามลำดับนี้):
 *   1. first_purchase  — $1 = 200E (4hr, urgent)
 *   2. bonus_40        — 40% bonus (24hr, หลัง $1 deal)
 *   3. tier_promo      — Tier upgrade bonus (24hr)
 *   4. winback         — Ex-subscriber $3/เดือน
 *   5. sub_upsell      — Milestone 50E → subscribe upsell
 *
 * Design Decisions:
 * - Dismissed offer: ซ่อนถาวร (stored in user.offers.dismissed[])
 * - Expiry: ตรวจสอบตอน query (ไม่มี cron clean-up → lazy evaluation)
 * - Offer ID: predictable key (ไม่ใช้ random uuid) เพราะ offer ประเภทน้อย
 */

import {onRequest} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

// ─── Types ───

export enum OfferPriority {
  FIRST_PURCHASE = 1,
  BONUS_40 = 2,
  TIER_PROMO = 3,
  WINBACK = 4,
  SUB_UPSELL = 5,
}

export interface OfferData {
  id: string;
  type: string;          // template.slug (เช่น 'starter_deal', 'bonus_40')
  priority: number;
  title: string;         // localized title
  description: string;   // localized description
  ctaText: string;       // localized CTA
  expiry: admin.firestore.Timestamp | null;  // null = ไม่มีวันหมด
  remainingSeconds: number | null;           // null = ไม่มี countdown
  metadata: Record<string, unknown>;  // rewardConfig
  rewardType: string;    // 'special_product' | 'bonus_rate' | 'free_energy' | 'subscription_deal'
}

// ─── Core: Get Active Offers ───

/**
 * ดึง offers ที่ active อยู่ของ user ทั้งหมด
 * อ่านจาก offer_templates collection (dynamic)
 * เรียงตาม priority (น้อยก่อน = สำคัญกว่า)
 * Filter: expired, claimed, และ dismissed ออกแล้ว
 */
export async function getActiveOffers(
  deviceId: string,
  userLocale: string = "en"
): Promise<OfferData[]> {
  const userDoc = await db.collection("users").doc(deviceId).get();

  if (!userDoc.exists) return [];

  const user = userDoc.data()!;
  const activeOffersMap = user.offers?.active || {};
  const dismissed: string[] = user.offers?.dismissed || [];
  const now = admin.firestore.Timestamp.now();
  const nowDate = now.toDate();

  const activeOffers: OfferData[] = [];

  // สำหรับแต่ละ entry ใน activeOffers
  for (const [templateId, offerState] of Object.entries(activeOffersMap)) {
    const state = offerState as any;

    // a. ข้าม ถ้า dismissed.includes(templateId)
    if (dismissed.includes(templateId)) {
      continue;
    }

    // b. ข้าม ถ้า claimed == true
    if (state.claimed === true) {
      continue;
    }

    // c. ข้าม ถ้า expiresAt != null && expiresAt < now (หมดอายุ)
    if (state.expiresAt) {
      const expiryDate = state.expiresAt.toDate();
      if (expiryDate <= nowDate) {
        continue; // หมดอายุแล้ว
      }
    }

    // d. Load template จาก offer_templates collection
    const templateDoc = await db.collection("offer_templates").doc(templateId).get();
    if (!templateDoc.exists) {
      continue; // template ถูกลบ → ข้าม
    }

    const template = templateDoc.data()!;

    // e. ข้าม ถ้า template ถูก deactivate โดย admin
    if (template.isActive === false) {
      continue;
    }

    // e. สร้าง OfferData object
    const expiry = state.expiresAt || null;
    const remainingSeconds = expiry
      ? Math.floor((expiry.toDate().getTime() - nowDate.getTime()) / 1000)
      : null;

    // เลือกภาษา (fallback to 'en')
    const title = template.title?.[userLocale] || template.title?.en || "";
    const description = template.description?.[userLocale] || template.description?.en || "";
    const ctaText = template.ctaText?.[userLocale] || template.ctaText?.en || "";

    activeOffers.push({
      id: templateId,
      type: template.slug || templateId,    // ใช้ slug แทน type เดิม
      priority: template.priority || 999,
      title,
      description,
      ctaText,
      expiry,
      remainingSeconds,
      metadata: template.rewardConfig || {},
      rewardType: template.rewardType || "bonus_rate",   // ⬅️ เพิ่ม field ใหม่
    });
  }

  // เรียงตาม priority (น้อยก่อน = สำคัญกว่า)
  activeOffers.sort((a, b) => a.priority - b.priority);

  return activeOffers;
}

// ─── Dismiss Offer ───

/**
 * ซ่อน offer (ถาวร) เมื่อ user ปัดซ้าย
 * ไม่ลบ flag ใน offers field — แค่เพิ่ม templateId เข้า dismissed[]
 */
export async function dismissOffer(deviceId: string, offerId: string): Promise<void> {
  // validate: offerId ต้องอยู่ใน user's active offers
  const userDoc = await db.collection("users").doc(deviceId).get();
  const activeOffers = userDoc.data()?.offers?.active || {};

  if (!activeOffers[offerId]) {
    throw new Error(`Offer not found: ${offerId}`);
  }

  await db.collection("users").doc(deviceId).update({
    "offers.dismissed": admin.firestore.FieldValue.arrayUnion(offerId),
    lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
  });

  console.log(`👋 [OffersV2] ${deviceId} dismissed offer: ${offerId}`);
}

// ─── Cloud Function Endpoints ───

/**
 * getActiveOffers — GET endpoint สำหรับ Flutter app
 * POST { deviceId } → OfferData[]
 */
export const getActiveOffersEndpoint = onRequest(
  {timeoutSeconds: 10, memory: "256MiB", cors: true},
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({error: "Method not allowed"});
      return;
    }

    try {
      const {deviceId, locale} = req.body;

      if (!deviceId) {
        res.status(400).json({error: "Missing deviceId"});
        return;
      }

      const userLocale = locale || "en"; // default to English
      const offers = await getActiveOffers(deviceId, userLocale);

      res.status(200).json({
        success: true,
        offers,
        count: offers.length,
      });
    } catch (error: any) {
      console.error("❌ [getActiveOffers] Error:", error);
      res.status(500).json({error: error.message});
    }
  }
);

/**
 * dismissOfferEndpoint — POST { deviceId, offerId }
 */
export const dismissOfferEndpoint = onRequest(
  {timeoutSeconds: 10, memory: "256MiB", cors: true},
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({error: "Method not allowed"});
      return;
    }

    try {
      const {deviceId, offerId} = req.body;

      if (!deviceId || !offerId) {
        res.status(400).json({error: "Missing deviceId or offerId"});
        return;
      }

      await dismissOffer(deviceId, offerId);

      res.status(200).json({success: true});
    } catch (error: any) {
      console.error("❌ [dismissOffer] Error:", error);
      res.status(500).json({error: error.message});
    }
  }
);

/**
 * claimFreeEnergyEndpoint — POST { deviceId, templateId }
 * สำหรับ rewardType == 'free_energy' ที่ไม่ต้องซื้อผ่าน IAP
 */
export async function claimFreeEnergyOffer(
  deviceId: string,
  templateId: string
): Promise<{success: boolean; energyAdded: number; newBalance: number}> {
  // 1. Load template first (outside transaction — template is shared/immutable)
  const templateDoc = await db.collection("offer_templates").doc(templateId).get();
  if (!templateDoc.exists) {
    throw new Error("Offer template not found");
  }

  const template = templateDoc.data()!;
  if (template.rewardType !== "free_energy") {
    throw new Error("This offer is not a free energy offer");
  }

  const energyAmount = template.rewardConfig?.amount || 0;
  if (energyAmount <= 0) {
    throw new Error("Invalid energy amount");
  }

  // 2. Atomic transaction: validate + add energy + mark claimed
  const userRef = db.collection("users").doc(deviceId);
  const result = await db.runTransaction(async (transaction) => {
    const userDoc = await transaction.get(userRef);
    if (!userDoc.exists) {
      throw new Error("User not found");
    }

    const user = userDoc.data()!;
    const activeOffers = user.offers?.active || {};
    const offerState = activeOffers[templateId];

    if (!offerState) {
      throw new Error("Offer not found or not active");
    }

    if (offerState.claimed === true) {
      throw new Error("Offer already claimed");
    }

    const now = admin.firestore.Timestamp.now();
    if (offerState.expiresAt && offerState.expiresAt.toDate() <= now.toDate()) {
      throw new Error("Offer expired");
    }

    const currentBalance = user.balance || 0;
    const newBalance = currentBalance + energyAmount;

    transaction.update(userRef, {
      balance: newBalance,
      [`offers.active.${templateId}.claimed`]: true,
      [`offers.active.${templateId}.claimedAt`]: admin.firestore.FieldValue.serverTimestamp(),
      [`offers.active.${templateId}.claimCount`]: (offerState.claimCount || 0) + 1,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {newBalance, miroId: user.miroId || "unknown"};
  });

  // 3. Log transaction (outside Firestore transaction — non-critical)
  await db.collection("transactions").add({
    deviceId,
    miroId: result.miroId,
    type: "offer_free_energy",
    amount: energyAmount,
    balanceAfter: result.newBalance,
    description: `Claimed free energy offer: ${template.slug || templateId}`,
    metadata: {
      templateId,
      slug: template.slug,
      rewardType: "free_energy",
    },
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  console.log(`✅ [claimFreeEnergy] ${deviceId} claimed ${energyAmount}E from offer ${template.slug || templateId}`);

  return {
    success: true,
    energyAdded: energyAmount,
    newBalance: result.newBalance,
  };
}

/**
 * claimFreeEnergyEndpoint — POST { deviceId, templateId }
 */
export const claimFreeEnergyEndpoint = onRequest(
  {timeoutSeconds: 10, memory: "256MiB", cors: true},
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({error: "Method not allowed"});
      return;
    }

    try {
      const {deviceId, templateId} = req.body;

      if (!deviceId || !templateId) {
        res.status(400).json({error: "Missing deviceId or templateId"});
        return;
      }

      const result = await claimFreeEnergyOffer(deviceId, templateId);

      res.status(200).json(result);
    } catch (error: any) {
      console.error("❌ [claimFreeEnergy] Error:", error);
      res.status(500).json({error: error.message});
    }
  }
);

// ─── Claim Freepass Offer ───

/**
 * Claim a freepass offer — adds N days to user's freepass.totalDays (no energy cost).
 */
export async function claimFreepassOffer(
  deviceId: string,
  templateId: string
): Promise<{success: boolean; daysAdded: number; newTotalDays: number}> {
  const templateDoc = await db.collection("offer_templates").doc(templateId).get();
  if (!templateDoc.exists) {
    throw new Error("Offer template not found");
  }

  const template = templateDoc.data()!;
  if (template.rewardType !== "freepass") {
    throw new Error("This offer is not a freepass offer");
  }

  const days = template.rewardConfig?.days || 0;
  if (days <= 0) {
    throw new Error("Invalid freepass days");
  }

  const userRef = db.collection("users").doc(deviceId);
  const result = await db.runTransaction(async (transaction) => {
    const userDoc = await transaction.get(userRef);
    if (!userDoc.exists) {
      throw new Error("User not found");
    }

    const user = userDoc.data()!;
    const activeOffers = user.offers?.active || {};
    const offerState = activeOffers[templateId];

    if (!offerState) {
      throw new Error("Offer not found or not active");
    }

    if (offerState.claimed === true) {
      throw new Error("Offer already claimed");
    }

    const now = admin.firestore.Timestamp.now();
    if (offerState.expiresAt && offerState.expiresAt.toDate() <= now.toDate()) {
      throw new Error("Offer expired");
    }

    const currentTotalDays = user.freepass?.totalDays ?? 0;
    const newTotalDays = currentTotalDays + days;

    transaction.update(userRef, {
      "freepass.totalDays": newTotalDays,
      [`offers.active.${templateId}.claimed`]: true,
      [`offers.active.${templateId}.claimedAt`]: admin.firestore.FieldValue.serverTimestamp(),
      [`offers.active.${templateId}.claimCount`]: (offerState.claimCount || 0) + 1,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {newTotalDays, miroId: user.miroId || "unknown"};
  });

  await db.collection("transactions").add({
    deviceId,
    miroId: result.miroId,
    type: "offer_freepass",
    amount: 0,
    balanceAfter: 0,
    description: `Claimed ${days}-day freepass from offer: ${template.slug || templateId}`,
    metadata: {
      templateId,
      slug: template.slug,
      rewardType: "freepass",
      daysAdded: days,
      newTotalDays: result.newTotalDays,
    },
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  console.log(`✅ [claimFreepass] ${deviceId} claimed ${days} days from offer ${template.slug || templateId}`);

  return {
    success: true,
    daysAdded: days,
    newTotalDays: result.newTotalDays,
  };
}

/**
 * claimFreepassEndpoint — POST { deviceId, templateId }
 */
export const claimFreepassEndpoint = onRequest(
  {timeoutSeconds: 10, memory: "256MiB", cors: true},
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({error: "Method not allowed"});
      return;
    }

    try {
      const {deviceId, templateId} = req.body;

      if (!deviceId || !templateId) {
        res.status(400).json({error: "Missing deviceId or templateId"});
        return;
      }

      const result = await claimFreepassOffer(deviceId, templateId);
      res.status(200).json(result);
    } catch (error: any) {
      console.error("❌ [claimFreepass] Error:", error);
      res.status(500).json({error: error.message});
    }
  }
);
