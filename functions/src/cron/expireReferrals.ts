/**
 * expireReferrals
 *
 * Schedule: ทุกวันเวลา 02:00 UTC+7 (19:00 UTC)
 * สิ่งที่ทำ: หา pending referral records ที่หมดอายุแล้ว → update status = expired
 */

import {onSchedule} from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

export const expireReferrals = onSchedule(
  {
    schedule: "0 19 * * *", // 02:00 Asia/Bangkok (UTC+7)
    timeZone: "UTC",
    timeoutSeconds: 540,
    memory: "256MiB",
  },
  async (event) => {
    try {
      console.log("🔄 [Cron] Expiring old referral records...");

      const now = admin.firestore.Timestamp.now();

      // หา pending records ที่หมดอายุแล้ว
      const snapshot = await db
        .collection("referral_records")
        .where("status", "==", "pending")
        .where("expiresAt", "<", now)
        .get();

      if (snapshot.empty) {
        console.log("✅ [Cron] No expired referrals found");
        return;
      }

      // Update status = expired
      const batch = db.batch();
      snapshot.docs.forEach((doc) => {
        batch.update(doc.ref, {
          status: "expired",
          expiredAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      });

      await batch.commit();

      console.log(`✅ [Cron] Expired ${snapshot.size} referral records`);
    } catch (error) {
      console.error("❌ [Cron] expireReferrals error:", error);
    }
  }
);
