/**
 * winbackScheduler.ts
 *
 * V3: Winback Subscription Offer Scheduler
 *
 * ทุก 24 ชั่วโมง: scan users ที่ subscription expired > 7 วัน
 * → Set winbackOfferAvailable flag + ส่ง push notification
 */

import {onSchedule} from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

/**
 * winbackScheduler — Scheduled function (ทุก 24 ชั่วโมง)
 *
 * Query: subscription expired > 7 วัน && ยังไม่ส่ง winback
 * Action: Set winbackOfferAvailable flag + ส่ง push notification
 */
export const winbackScheduler = onSchedule(
  {
    schedule: "every 24 hours",
    timeZone: "UTC",
    timeoutSeconds: 300,
    memory: "512MiB",
  },
  async () => {
    console.log("🔄 [WinbackScheduler] Running...");

    const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
    const sevenDaysAgoTimestamp = admin.firestore.Timestamp.fromDate(sevenDaysAgo);

    // Query: subscription expired > 7 วัน && ยังไม่ส่ง winback
    const expiredUsers = await db
      .collection("users")
      .where("subscription.status", "==", "expired")
      .where("subscription.expiryDate", "<", sevenDaysAgoTimestamp)
      .where("winbackOfferAvailable", "==", false) // ยังไม่เคยส่ง
      .limit(100)
      .get();

    let processed = 0;
    let sentNotifications = 0;
    let errors = 0;

    for (const doc of expiredUsers.docs) {
      try {
        const user = doc.data();

        // Set winback flag
        const expiry = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 วัน
        await doc.ref.update({
          winbackOfferAvailable: true,
          winbackOfferExpiry: admin.firestore.Timestamp.fromDate(expiry),
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        });

        // ส่ง Push Notification
        if (user.fcmToken) {
          try {
            await admin.messaging().send({
              token: user.fcmToken,
              notification: {
                title: "กลับมาใช้ ArCal!",
                body: "Energy Pass เดือนแรกแค่ $3",
              },
              data: {
                type: "winback_offer",
                offerId: "winback-3usd",
              },
              android: {
                notification: {
                  icon: "ic_notification",
                  color: "#F97316",
                },
              },
            });

            sentNotifications++;
            console.log(`✅ [Winback] Sent notification to ${doc.id}`);
          } catch (error: any) {
            if (
              error.code === "messaging/registration-token-not-registered" ||
              error.code === "messaging/invalid-registration-token"
            ) {
              // Invalid token → ลบออก
              await doc.ref.update({fcmToken: admin.firestore.FieldValue.delete()});
            } else {
              console.error(`❌ [Winback] Failed to send notification to ${doc.id}:`, error);
            }
            errors++;
          }
        }

        processed++;
      } catch (error) {
        console.error(`❌ [Winback] Error processing ${doc.id}:`, error);
        errors++;
      }
    }

    console.log(
      `✅ [WinbackScheduler] Processed ${processed} users, sent ${sentNotifications} notifications, ${errors} errors`
    );
  }
);
