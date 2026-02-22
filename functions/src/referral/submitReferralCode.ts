/**
 * submitReferralCode
 *
 * เรียกเมื่อ: Referee ใส่ referral code ตอน register
 * Timing: ใส่ได้แค่ภายใน 24 ชั่วโมงหลัง register
 *
 * Input:  { deviceId, referralCode }
 * Output: { success, bonusEnergy }
 */

import {onRequest} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {checkReferralFraud} from "../utils/advancedFraudCheck";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

const REFERRAL_CONFIG = {
  refereeBonus: 20, // V3.1: Energy ที่ referee ได้ทันที (5E -> 20E)
  referrerReward: 15, // Legacy (not used in V3.1)
  requiredAiUsage: 3, // Legacy (not used in V3.1)
  expiryDays: 7, // จำนวนวันที่ referee ต้องใช้ AI ครบ (นับจาก register)
  maxPerMonth: 100, // V3.1: เพิ่มจาก 2 -> 100 (unlimited for weekly quest)
};

export const submitReferralCode = onRequest(
  {
    timeoutSeconds: 15,
    memory: "256MiB",
    cors: true,
  },
  async (req, res) => {
    try {
      const {deviceId, referralCode} = req.body;

      // 1. Validate inputs
      if (!deviceId || !referralCode) {
        res.status(400).json({error: "Missing fields"});
        return;
      }

      // 2. ดึง referee (คนใส่ code)
      const refereeDoc = await db.collection("users").doc(deviceId).get();
      if (!refereeDoc.exists) {
        res.status(404).json({error: "User not found"});
        return;
      }

      const referee = refereeDoc.data()!;

      // 3. เช็คว่าใส่ referral code แล้วหรือยัง
      if (referee.referrals?.referredBy) {
        res.status(400).json({error: "Already used a referral code"});
        return;
      }

      // 4. เช็คว่า register ภายใน 24 ชั่วโมงหรือไม่
      const createdAt = referee.createdAt?.toDate ?
        referee.createdAt.toDate() :
        new Date(0);
      const hoursSinceRegister =
        (Date.now() - createdAt.getTime()) / (1000 * 60 * 60);
      if (hoursSinceRegister > 24) {
        res.status(400).json({
          error: "Referral code must be used within 24 hours of registration",
        });
        return;
      }

      // 5. ห้าม refer ตัวเอง
      if (referee.miroId === referralCode) {
        res.status(400).json({error: "Cannot refer yourself"});
        return;
      }

      // 6. หา referrer (คนชวน) จาก MiRO ID
      const referrerSnapshot = await db
        .collection("users")
        .where("miroId", "==", referralCode)
        .limit(1)
        .get();

      if (referrerSnapshot.empty) {
        res.status(404).json({error: "Invalid referral code"});
        return;
      }

      const referrerDoc = referrerSnapshot.docs[0];
      const referrer = referrerDoc.data();
      const referrerDeviceId = referrerDoc.id;

      // 7. เช็ค referrer quota (2/month)
      const now = new Date();
      const currentMonth = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}-01`;
      const resetDate = referrer.referrals?.referralResetDate || "";

      let referralCount = referrer.referrals?.referralCount || 0;
      if (resetDate !== currentMonth) {
        referralCount = 0; // เดือนใหม่ → reset
      }

      if (referralCount >= REFERRAL_CONFIG.maxPerMonth) {
        res.status(400).json({error: "Referrer has reached monthly limit"});
        return;
      }

      // 8. Anti-fraud: Advanced IP check
      const refereeIp =
        req.ip ||
        (Array.isArray(req.headers["x-forwarded-for"]) ?
          req.headers["x-forwarded-for"][0] :
          req.headers["x-forwarded-for"]) ||
        "unknown";
      const referrerIp = referrer.registrationIp || "unknown";

      // Advanced fraud check
      const fraudCheck = await checkReferralFraud(
        referrerDeviceId,
        deviceId,
        referrerIp,
        refereeIp
      );

      if (fraudCheck.isSuspicious) {
        console.log(`🚨 [Referral] Fraud detected: ${fraudCheck.reason}`);
        res.status(403).json({
          error: "Referral code cannot be used due to suspicious activity",
          reason: fraudCheck.reason,
        });
        return;
      }

      // 9. ให้ referee +20 Energy bonus ทันที
      const refereeBonus = REFERRAL_CONFIG.refereeBonus;
      const expiresAt = admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + REFERRAL_CONFIG.expiryDays * 24 * 60 * 60 * 1000)
      );

      await db.runTransaction(async (transaction) => {
        const refDoc = await transaction.get(
          db.collection("users").doc(deviceId)
        );
        const currentBalance = refDoc.data()?.balance || 0;

        transaction.update(db.collection("users").doc(deviceId), {
          "balance": currentBalance + refereeBonus,
          "totalEarned": (referee.totalEarned || 0) + refereeBonus,
          "referrals.referredBy": referralCode,
          "referrals.referredByDeviceId": referrerDeviceId,
          "referredBy": referrerDeviceId,
          "lastUpdated": admin.firestore.FieldValue.serverTimestamp(),
        });

        // Log transaction
        const txRef = db.collection("transactions").doc();
        transaction.set(txRef, {
          deviceId,
          miroId: referee.miroId,
          type: "referral",
          amount: refereeBonus,
          balanceAfter: currentBalance + refereeBonus,
          description: `Referral bonus: +${refereeBonus} Energy`,
          metadata: {
            referralCode,
            referrerMiroId: referralCode,
            isReferee: true,
          },
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // สร้าง referral record
        const recordRef = db.collection("referral_records").doc();
        transaction.set(recordRef, {
          referrerId: referrerDeviceId,
          referrerMiroId: referralCode,
          refereeId: deviceId,
          refereeMiroId: referee.miroId,
          status: "pending",
          refereeAiUsageCount: 0,
          requiredUsage: REFERRAL_CONFIG.requiredAiUsage,
          referrerReward: REFERRAL_CONFIG.referrerReward,
          refereeReward: refereeBonus,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          expiresAt,
          ip: {
            referrer: referrerIp,
            referee: refereeIp,
          },
        });
      });

      console.log(
        `✅ [Referral] ${referee.miroId} used code ${referralCode} (+${refereeBonus} Energy)`
      );

      res.status(200).json({
        success: true,
        bonusEnergy: refereeBonus,
        message: `You got ${refereeBonus} Energy! Use AI 3 times to help your friend get ${REFERRAL_CONFIG.referrerReward} Energy too!`,
      });
    } catch (error: any) {
      console.error("❌ [submitReferralCode] Error:", error);
      res.status(500).json({error: error.message});
    }
  }
);
