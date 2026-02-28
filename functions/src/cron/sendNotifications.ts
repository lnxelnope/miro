/**
 * sendStreakReminders
 *
 * Schedule: ทุกวัน 13:00 UTC (= 20:00 UTC+7)
 * สิ่งที่ทำ: ส่ง notification ให้ user ที่ยังไม่ check-in วันนี้
 */

import {onSchedule} from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

export const sendStreakReminders = onSchedule(
  {
    schedule: "0 13 * * *", // 20:00 UTC+7 = 13:00 UTC
    timeZone: "UTC",
    timeoutSeconds: 540,
    memory: "512MiB",
  },
  async () => {
    // วันนี้ (UTC+7)
    const now = new Date();
    const today = new Date(now.getTime() + 7 * 60 * 60 * 1000)
      .toISOString()
      .split("T")[0];

    console.log(`🔔 [Notify] Sending streak reminders for ${today}...`);

    // หา users ที่ยังไม่ check-in + มี streak > 0 + มี fcmToken
    const usersSnapshot = await db
      .collection("users")
      .where("currentStreak", ">", 0)
      .get();

    const messages: admin.messaging.Message[] = [];

    for (const doc of usersSnapshot.docs) {
      const user = doc.data();

      // ข้าม: check-in แล้ววันนี้
      if (user.lastCheckInDate === today) continue;

      // ข้าม: ไม่มี fcmToken
      if (!user.fcmToken) continue;

      // ข้าม: ปิด notification
      if (user.notificationSettings?.streakReminder === false) continue;

      // ข้าม: banned
      if (user.isBanned) continue;

      const streak = user.currentStreak || 0;
      const tier = user.tier || "none";

      // Tier emoji mapping
      const tierEmoji: Record<string, string> = {
        bronze: "🥉",
        silver: "🥈",
        gold: "🥇",
        diamond: "💎",
      };

      const tierText =
        tier !== "none" ?
          `${tierEmoji[tier] || ""} ${tier} tier ของคุณกำลังรอ!` :
          "ใช้ AI ฟรี 1 ครั้ง!";

      messages.push({
        token: user.fcmToken,
        notification: {
          title: `🔥 Streak ${streak} วัน!`,
          body: `อย่าลืมเข้า MIRO วันนี้ — ${tierText}`,
        },
        data: {
          type: "streak_reminder",
          streak: streak.toString(),
        },
        android: {
          priority: "high" as const,
        },
      });
    }

    // Send in batches (FCM limit: 500 per batch)
    const batchSize = 500;
    let sent = 0;
    let failed = 0;

    for (let i = 0; i < messages.length; i += batchSize) {
      const batch = messages.slice(i, i + batchSize);
      try {
        const result = await admin.messaging().sendEach(batch);
        sent += result.successCount;
        failed += result.failureCount;

        // Clean up invalid tokens
        result.responses.forEach((resp, idx) => {
          if (
            resp.error?.code === "messaging/registration-token-not-registered"
          ) {
            // Find deviceId from token (we need to store this mapping)
            // For now, we'll need to query users by fcmToken
            const message = batch[idx];
            const fcmToken = "token" in message ? message.token : null;
            if (fcmToken) {
              db.collection("users")
                .where("fcmToken", "==", fcmToken)
                .get()
                .then((snapshot) => {
                  snapshot.forEach((doc) => {
                    doc.ref.update({fcmToken: null});
                  });
                });
            }
          }
        });
      } catch (err) {
        console.error("❌ [Notify] Batch send error:", err);
        failed += batch.length;
      }
    }

    console.log(
      `✅ [Notify] Sent: ${sent}, Failed: ${failed}, Total: ${messages.length}`
    );
  }
);
