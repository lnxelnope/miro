/**
 * resetReferralQuota
 *
 * Schedule: ทุกวันที่ 1 ของเดือน เวลา 00:00 UTC+7 (17:00 UTC วันที่ 30/31)
 * สิ่งที่ทำ: Reset referralCount ของทุก user
 */

import {onSchedule} from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

export const resetReferralQuota = onSchedule(
  {
    schedule: "0 17 1 * *", // 00:00 Asia/Bangkok on 1st of month
    timeZone: "UTC",
    timeoutSeconds: 540,
    memory: "512MiB",
  },
  async (event) => {
    try {
      console.log("🔄 [Cron] Resetting monthly referral quota...");

      const now = new Date();
      const currentMonth = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}-01`;

      // หา users ที่มี referralCount > 0
      const snapshot = await db
        .collection("users")
        .where("referrals.referralCount", ">", 0)
        .get();

      if (snapshot.empty) {
        console.log("✅ [Cron] No users to reset");
        return;
      }

      // Reset quota
      const batch = db.batch();
      snapshot.docs.forEach((doc) => {
        batch.update(doc.ref, {
          "referrals.referralCount": 0,
          "referrals.referralResetDate": currentMonth,
        });
      });

      await batch.commit();

      console.log(`✅ [Cron] Reset quota for ${snapshot.size} users`);
    } catch (error) {
      console.error("❌ [Cron] resetReferralQuota error:", error);
    }
  }
);
