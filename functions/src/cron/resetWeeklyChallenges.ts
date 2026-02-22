/**
 * resetWeeklyChallenges
 *
 * Schedule: ทุกวันจันทร์ 00:00 (UTC+7 = 17:00 UTC วันอาทิตย์)
 * สิ่งที่ทำ: Reset weekly challenge progress ของทุก user
 *
 * หมายเหตุ: ใช้ lazy reset ใน incrementChallengeProgress แทนก็ได้
 * แต่ cron job ดีกว่าเพราะ:
 * - ล้าง claimedRewards ให้ claim ใหม่ได้
 * - ข้อมูลสะอาดสำหรับ admin dashboard
 */

import {onSchedule} from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

/**
 * หาวันจันทร์ของสัปดาห์ (week start date)
 */
function getWeekStartDate(dateStr: string): string {
  const date = new Date(dateStr);
  const day = date.getDay(); // 0 = Sunday, 1 = Monday, ..., 6 = Saturday
  const diff = day === 0 ? 6 : day - 1; // วันจันทร์ = 1, diff = 0
  date.setDate(date.getDate() - diff);
  return date.toISOString().split("T")[0];
}

export const resetWeeklyChallenges = onSchedule(
  {
    // ทุกวันจันทร์ 00:00 UTC+7 = วันอาทิตย์ 17:00 UTC
    schedule: "0 17 * * 0",
    timeZone: "UTC",
    timeoutSeconds: 540,
    memory: "512MiB",
  },
  async () => {
    console.log("🔄 [Cron] Resetting weekly challenges...");

    try {
      const today = new Date().toISOString().split("T")[0];
      const weekStart = getWeekStartDate(today);

      console.log(`📅 [Cron] Today: ${today}, Week start: ${weekStart}`);

      // ดึง users ทั้งหมด (batch processing)
      const usersSnapshot = await db.collection("users").get();
      let reset = 0;
      let skipped = 0;
      const errors = 0;

      // Process ใน batches (500 users/batch)
      const batchSize = 500;
      const batches: admin.firestore.DocumentData[][] = [];

      for (let i = 0; i < usersSnapshot.docs.length; i += batchSize) {
        batches.push(usersSnapshot.docs.slice(i, i + batchSize));
      }

      for (const batch of batches) {
        const writeBatch = db.batch();

        for (const doc of batch) {
          const userData = doc.data();
          const challenges = userData.challenges?.weekly || {};
          const storedWeekStart = challenges.weekStartDate || "";

          // ถ้าสัปดาห์ใหม่ → reset
          if (storedWeekStart !== weekStart) {
            writeBatch.update(doc.ref, {
              "challenges.weekly": {
                aiCount: 0,
                referFriends: 0,
                claimedRewards: [],
                weekStartDate: weekStart,
              },
              "lastUpdated": admin.firestore.FieldValue.serverTimestamp(),
            });
            reset++;
          } else {
            skipped++;
          }
        }

        await writeBatch.commit();
        console.log(`✅ [Cron] Processed batch: ${reset} reset, ${skipped} skipped`);
      }

      console.log(
        `✅ [Cron] Complete: ${reset} reset, ${skipped} skipped, ${errors} errors`
      );
    } catch (error: any) {
      console.error("❌ [Cron] Error:", error);
      throw error;
    }
  }
);
