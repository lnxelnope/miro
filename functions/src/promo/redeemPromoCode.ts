/**
 * Redeem promo code — idempotent per device + perUserLimit (ARC2-PROMO-02).
 */
import {onRequest} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

interface PromoDoc {
  code: string;
  active: boolean;
  rewardType: string;
  rewardPayload?: {amount?: number; days?: number};
  maxRedemptions: number;
  perUserLimit: number;
  expiryAt?: admin.firestore.Timestamp | null;
  redemptionCount: number;
}

export const redeemPromoCode = onRequest(
  {timeoutSeconds: 15, memory: "256MiB", cors: true},
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({error: "method_not_allowed", message: "Method not allowed"});
      return;
    }

    const body = req.body || {};
    const deviceId = typeof body.deviceId === "string" ? body.deviceId.trim() : "";
    const rawCode = typeof body.code === "string" ? body.code.trim() : "";

    if (!deviceId || !rawCode) {
      res.status(400).json({error: "bad_request", message: "Missing deviceId or code"});
      return;
    }

    const normalizedCode = rawCode.toUpperCase();

    const snap = await db
      .collection("promo_codes")
      .where("code", "==", normalizedCode)
      .where("active", "==", true)
      .limit(1)
      .get();

    if (snap.empty) {
      res.status(404).json({error: "invalid_code", message: "Promo code not found or inactive"});
      return;
    }

    const promoRef = snap.docs[0].ref;

    try {
      const result = await db.runTransaction(async (tx) => {
        const promoSnap = await tx.get(promoRef);
        if (!promoSnap.exists) {
          throw Object.assign(new Error("invalid_code"), {code: "invalid_code"});
        }
        const promo = promoSnap.data() as PromoDoc;

        if (!promo.active) {
          throw Object.assign(new Error("invalid_code"), {code: "invalid_code"});
        }

        const now = new Date();
        if (promo.expiryAt && promo.expiryAt.toDate() < now) {
          throw Object.assign(new Error("expired"), {code: "expired"});
        }

        const maxR = promo.maxRedemptions ?? 0;
        const currentGlobal = promo.redemptionCount ?? 0;
        if (maxR > 0 && currentGlobal >= maxR) {
          throw Object.assign(new Error("max_reached"), {code: "max_reached"});
        }

        const perUser = promo.perUserLimit ?? 1;
        const redemptionRef = promoRef.collection("redemptions").doc(deviceId);
        const redSnap = await tx.get(redemptionRef);
        const prevCount = redSnap.exists ? (redSnap.data()?.count as number) || 0 : 0;
        if (prevCount >= perUser) {
          throw Object.assign(new Error("per_user_limit"), {code: "per_user_limit"});
        }

        const userRef = db.collection("users").doc(deviceId);
        const userSnap = await tx.get(userRef);
        if (!userSnap.exists) {
          throw Object.assign(new Error("user_not_found"), {code: "user_not_found"});
        }

        const rewardType = promo.rewardType;
        const payload = promo.rewardPayload || {};

        if (rewardType === "energy") {
          const amount = Math.floor(Number(payload.amount) || 0);
          if (amount <= 0) {
            throw Object.assign(new Error("invalid_reward"), {code: "invalid_reward"});
          }
          tx.update(userRef, {
            balance: admin.firestore.FieldValue.increment(amount),
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          });
        } else if (rewardType === "freepass") {
          const days = Math.floor(Number(payload.days) || 0);
          if (days <= 0) {
            throw Object.assign(new Error("invalid_reward"), {code: "invalid_reward"});
          }
          tx.update(userRef, {
            "freepass.totalDays": admin.firestore.FieldValue.increment(days),
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          });
        } else {
          throw Object.assign(new Error("invalid_reward"), {code: "invalid_reward"});
        }

        tx.update(promoRef, {
          redemptionCount: admin.firestore.FieldValue.increment(1),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        if (redSnap.exists) {
          tx.update(redemptionRef, {
            count: admin.firestore.FieldValue.increment(1),
            redeemedAt: admin.firestore.FieldValue.serverTimestamp(),
            rewardGranted: payload,
          });
        } else {
          tx.set(redemptionRef, {
            count: 1,
            redeemedAt: admin.firestore.FieldValue.serverTimestamp(),
            rewardGranted: payload,
          });
        }

        return {rewardType, rewardPayload: payload};
      });

      await db.collection("transactions").add({
        deviceId,
        type: "promo_redeem",
        amount: 0,
        balanceAfter: 0,
        description: "Promo code redemption",
        metadata: {
          rewardType: result.rewardType,
          rewardPayload: result.rewardPayload,
        },
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      res.status(200).json({
        success: true,
        rewardType: result.rewardType,
        rewardPayload: result.rewardPayload,
        message: "Redeemed",
      });
    } catch (e: any) {
      const key = e?.code || "unknown";
      if (key === "invalid_code") {
        res.status(404).json({error: "invalid_code", message: "Promo code not found or inactive"});
        return;
      }
      if (key === "expired") {
        res.status(400).json({error: "expired", message: "Promo code has expired"});
        return;
      }
      if (key === "max_reached") {
        res.status(400).json({error: "max_reached", message: "Promo code redemption limit reached"});
        return;
      }
      if (key === "per_user_limit") {
        res.status(400).json({error: "per_user_limit", message: "You have already redeemed this code"});
        return;
      }
      if (key === "user_not_found") {
        res.status(404).json({error: "user_not_found", message: "User not registered"});
        return;
      }
      console.error("redeemPromoCode error", key);
      res.status(500).json({error: "server_error", message: "Redeem failed"});
    }
  }
);
