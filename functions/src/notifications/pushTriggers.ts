/**
 * pushTriggers.ts
 *
 * Push Notification Triggers — 3 กรณีเท่านั้น (ไม่ spam user)
 *
 * T1. checkOfferExpiry     — ทุก 15 นาที: แจ้งเตือน offer ใกล้หมด (< 1 ชม.)
 * T2. streakReminder       — ทุกวัน 21:00 UTC+7: ลืม claim หรือเปล่า?
 * T3. (Tier Up)            — เรียกใน dailyCheckIn.ts หลัง tier upgrade สำเร็จ
 *
 * Design Decisions:
 * - ใช้ FCM multicast สำหรับ batch notifications (ไม่ loop ทีละ token)
 * - Invalid token (NotRegistered) → ลบ fcmToken ออก (ไม่ส่งครั้งต่อไป)
 * - Idempotent: เช็ค sent flag ก่อนส่งทุกครั้ง
 * - Timezone: streakReminder ใช้ Cloud Scheduler timezone (Asia/Bangkok)
 */

import {onSchedule} from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

const BATCH_SIZE = 100; // FCM multicast limit คือ 500 tokens แต่เราใช้ 100 เพื่อ safety

// ─── T1: Offer Expiry Alert (ทุก 15 นาที) ───

/**
 * ส่ง push เมื่อ offer ของ user เหลือเวลา < 1 ชม.
 * ส่งครั้งเดียวต่อ offer (ตรวจสอบ notifications.offerExpirySent)
 */
export const checkOfferExpiry = onSchedule(
  {
    schedule: "every 15 minutes",
    timeZone: "UTC",
    timeoutSeconds: 120,
    memory: "256MiB",
  },
  async () => {
    console.log("⏰ [PushTrigger] Running offer expiry check...");

    const now = new Date();
    const oneHourFromNow = admin.firestore.Timestamp.fromDate(
      new Date(now.getTime() + 60 * 60 * 1000)
    );

    let sentCount = 0;
    let cleanedTokens = 0;

    // ─── Check firstPurchase offer ───
    const firstPurchaseQuery = await db.collection("users")
      .where("offers.firstPurchaseAvailable", "==", true)
      .where("offers.firstPurchaseClaimed", "==", false)
      .where("offers.firstPurchaseExpiry", "<=", oneHourFromNow)
      .where("offers.firstPurchaseExpiry", ">", admin.firestore.Timestamp.fromDate(now))
      .limit(BATCH_SIZE)
      .get();

    const firstPurchaseUsers = firstPurchaseQuery.docs.filter((doc) => {
      const user = doc.data();
      return !user.notifications?.offerExpirySent?.first_purchase;
    });

    if (firstPurchaseUsers.length > 0) {
      const tokens = firstPurchaseUsers
        .map((doc) => doc.data().fcmToken)
        .filter((token): token is string => !!token);

      if (tokens.length > 0) {
        const {sent, invalidTokenDeviceIds} = await sendMulticast(
          tokens,
          firstPurchaseUsers.map((doc) => doc.id),
          {
            title: "⏰ โปรพิเศษกำลังจะหมด!",
            body: "Starter Deal $1 = 200E เหลือเวลาอีก 1 ชั่วโมง",
          },
          {type: "offer_expiry", offerId: "first_purchase"}
        );
        sentCount += sent;
        cleanedTokens += invalidTokenDeviceIds.length;

        // Mark as sent (batch update)
        await markOfferExpirySent(firstPurchaseUsers.map((d) => d.ref), "first_purchase");
        await cleanInvalidTokens(invalidTokenDeviceIds);
      }
    }

    // ─── Check welcomeBonus offer ───
    const welcomeBonusQuery = await db.collection("users")
      .where("offers.welcomeBonusAvailable", "==", true)
      .where("offers.welcomeBonusClaimed", "==", false)
      .where("offers.welcomeBonusExpiry", "<=", oneHourFromNow)
      .where("offers.welcomeBonusExpiry", ">", admin.firestore.Timestamp.fromDate(now))
      .limit(BATCH_SIZE)
      .get();

    const welcomeBonusUsers = welcomeBonusQuery.docs.filter((doc) => {
      const user = doc.data();
      return !user.notifications?.offerExpirySent?.bonus_40;
    });

    if (welcomeBonusUsers.length > 0) {
      const tokens = welcomeBonusUsers
        .map((doc) => doc.data().fcmToken)
        .filter((token): token is string => !!token);

      if (tokens.length > 0) {
        const {sent, invalidTokenDeviceIds} = await sendMulticast(
          tokens,
          welcomeBonusUsers.map((doc) => doc.id),
          {
            title: "⏰ โบนัส +40% กำลังจะหมด!",
            body: "ซื้อ Energy ได้รับ +40% ก่อนหมดอายุ",
          },
          {type: "offer_expiry", offerId: "bonus_40"}
        );
        sentCount += sent;
        cleanedTokens += invalidTokenDeviceIds.length;

        await markOfferExpirySent(welcomeBonusUsers.map((d) => d.ref), "bonus_40");
        await cleanInvalidTokens(invalidTokenDeviceIds);
      }
    }

    console.log(
      `✅ [checkOfferExpiry] Sent ${sentCount} notifications, cleaned ${cleanedTokens} invalid tokens`
    );
  }
);

// ─── T2: Streak Reminder (ทุกวัน 21:00 UTC+7 = 14:00 UTC) ───

/**
 * แจ้งเตือน users ที่ยังไม่ claim วันนี้ + มี streak > 0
 * ส่งครั้งเดียวต่อวัน (notifications.lastStreakReminder)
 */
export const streakReminder = onSchedule(
  {
    schedule: "0 14 * * *",  // 14:00 UTC = 21:00 UTC+7
    timeZone: "UTC",
    timeoutSeconds: 300,
    memory: "512MiB",
  },
  async () => {
    console.log("🔥 [PushTrigger] Running streak reminder...");

    const today = getThaiDate(); // 'YYYY-MM-DD' UTC+7
    let totalSent = 0;
    let cleanedTokens = 0;
    let lastDoc: admin.firestore.DocumentSnapshot | undefined;

    while (true) {
      let query = db.collection("users")
        .where("currentStreak", ">", 0)
        .orderBy("currentStreak")
        .limit(BATCH_SIZE);

      if (lastDoc) {
        query = query.startAfter(lastDoc);
      }

      const snapshot = await query.get();

      if (snapshot.empty) break;

      // Filter: ยังไม่ claim วันนี้ + ยังไม่ส่ง reminder วันนี้
      const eligibleDocs = snapshot.docs.filter((doc) => {
        const user = doc.data();
        const lastClaimDate = user.dailyClaim?.lastClaimDate || user.lastCheckInDate || "";
        const lastReminderDate = user.notifications?.lastStreakReminder || "";
        return lastClaimDate !== today && lastReminderDate !== today;
      });

      if (eligibleDocs.length > 0) {
        const pairs = eligibleDocs
          .map((doc) => ({deviceId: doc.id, token: doc.data().fcmToken as string | undefined}))
          .filter((p): p is {deviceId: string; token: string} => !!p.token);

        if (pairs.length > 0) {
          const {sent, invalidTokenDeviceIds} = await sendMulticast(
            pairs.map((p) => p.token),
            pairs.map((p) => p.deviceId),
            {
              title: "ลืม log หรือเปล่า?",
              body: "Streak จะหาย! 🔥 Daily reward รอคุณอยู่",
            },
            {type: "streak_reminder"}
          );
          totalSent += sent;
          cleanedTokens += invalidTokenDeviceIds.length;

          // Mark as sent (batch)
          const batch = db.batch();
          for (const doc of eligibleDocs) {
            batch.update(doc.ref, {
              "notifications.lastStreakReminder": today,
            });
          }
          await batch.commit();

          await cleanInvalidTokens(invalidTokenDeviceIds);
        }
      }

      lastDoc = snapshot.docs[snapshot.docs.length - 1];

      if (snapshot.size < BATCH_SIZE) break;
    }

    console.log(
      `✅ [streakReminder] Sent ${totalSent} reminders, cleaned ${cleanedTokens} invalid tokens`
    );
  }
);

// ─── T3: Tier Up (เรียกจาก dailyCheckIn) ───
// ไม่ใช่ scheduled function — เป็น helper ที่เรียกหลัง tier upgrade

/**
 * ส่ง push notification เมื่อ user tier upgrade
 * เรียกจาก dailyCheckIn.ts หลัง processCheckIn สำเร็จ
 */
export async function sendTierUpNotification(
  deviceId: string,
  newTier: string,
  tierReward: number
): Promise<void> {
  try {
    const userDoc = await db.collection("users").doc(deviceId).get();

    if (!userDoc.exists) return;

    const user = userDoc.data()!;
    const token = user.fcmToken as string | undefined;

    if (!token) return;

    const tierNames: Record<string, string> = {
      bronze: "Bronze",
      silver: "Silver",
      gold: "Gold",
      diamond: "Diamond",
    };

    const tierDisplayName = tierNames[newTier] || newTier;

    const result = await admin.messaging().send({
      token,
      notification: {
        title: "🎉 ยินดีด้วย!",
        body: `คุณเลื่อนเป็น ${tierDisplayName}! Track calories เก่งมาก หุ่นในฝันใกล้จะเป็นจริงแล้ว!`,
      },
      data: {
        type: "tier_up",
        newTier,
        tierReward: String(tierReward),
      },
      android: {
        notification: {
          icon: "ic_notification",
          color: "#F97316",
        },
      },
    });

    console.log(`✅ [TierUp Push] Sent to ${deviceId}: ${result}`);
  } catch (error: any) {
    if (error.code === "messaging/registration-token-not-registered") {
      await cleanInvalidTokens([deviceId]);
    } else {
      console.error(`❌ [TierUp Push] Error for ${deviceId}:`, error);
    }
  }
}

// ─── Helpers ───

/**
 * ส่ง FCM multicast แบบ batch
 * Returns: {sent, invalidTokenDeviceIds}
 */
async function sendMulticast(
  tokens: string[],
  deviceIds: string[],
  notification: {title: string; body: string},
  data: Record<string, string>
): Promise<{sent: number; invalidTokenDeviceIds: string[]}> {
  if (tokens.length === 0) return {sent: 0, invalidTokenDeviceIds: []};

  const result = await admin.messaging().sendEachForMulticast({
    tokens,
    notification,
    data,
    android: {
      notification: {
        icon: "ic_notification",
        color: "#F97316",
        clickAction: "FLUTTER_NOTIFICATION_CLICK",
      },
    },
  });

  const invalidTokenDeviceIds: string[] = [];

  result.responses.forEach((response, index) => {
    if (!response.success) {
      const errorCode = response.error?.code;
      if (
        errorCode === "messaging/registration-token-not-registered" ||
        errorCode === "messaging/invalid-registration-token"
      ) {
        invalidTokenDeviceIds.push(deviceIds[index]);
      } else {
        console.error(
          `❌ [Push] Failed for ${deviceIds[index]}:`,
          response.error?.message
        );
      }
    }
  });

  return {
    sent: result.successCount,
    invalidTokenDeviceIds,
  };
}

/**
 * Mark offer expiry notification as sent (ไม่ส่งซ้ำ)
 */
async function markOfferExpirySent(
  refs: admin.firestore.DocumentReference[],
  offerId: string
): Promise<void> {
  const batch = db.batch();
  for (const ref of refs) {
    batch.update(ref, {
      [`notifications.offerExpirySent.${offerId}`]: true,
    });
  }
  await batch.commit();
}

/**
 * ลบ fcmToken ของ devices ที่ token หมดอายุ
 */
async function cleanInvalidTokens(deviceIds: string[]): Promise<void> {
  if (deviceIds.length === 0) return;

  const batch = db.batch();
  for (const deviceId of deviceIds) {
    const ref = db.collection("users").doc(deviceId);
    batch.update(ref, {fcmToken: admin.firestore.FieldValue.delete()});
  }
  await batch.commit();

  console.log(`🧹 [Push] Cleaned ${deviceIds.length} invalid FCM tokens`);
}

/**
 * คืนวันที่ปัจจุบัน UTC+7 (ไทย)
 */
function getThaiDate(): string {
  const now = new Date();
  const thaiTime = new Date(now.getTime() + 7 * 60 * 60 * 1000);
  return thaiTime.toISOString().split("T")[0];
}
