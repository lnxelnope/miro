/**
 * claimDailyEnergy.ts
 *
 * V3: Manual Daily Claim Endpoint
 * V4: + Data Sync — accepts food entries & meals for cloud backup
 *
 * เปลี่ยนจาก auto check-in (ใน analyzeFood) → manual claim (user กดปุ่ม)
 * ใช้ logic จาก processCheckIn แต่เรียกผ่าน endpoint นี้
 */

import {onRequest} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {processCheckIn} from "./dailyCheckIn";
import {getActiveOffers} from "./offersV2";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

/**
 * Store sync payload (food entries + meals) in Firestore.
 * Non-blocking — failures don't affect the claim response.
 */
async function processSyncPayload(
  deviceId: string,
  sync: any
): Promise<boolean> {
  try {
    if (!sync) return false;

    const entries = sync.entries || [];
    const meals = sync.meals || [];
    const profile = sync.profile || null;
    const syncTimestamp = sync.syncTimestamp || Date.now();

    if (entries.length === 0 && meals.length === 0 && !profile) return false;

    const today = new Date().toISOString().split("T")[0];
    const syncRef = db
      .collection("user_sync")
      .doc(deviceId)
      .collection("daily_logs")
      .doc(today);

    const syncData: any = {
      syncTimestamp,
      entryCount: entries.length,
      mealCount: meals.length,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    if (entries.length > 0) {
      syncData.entries = admin.firestore.FieldValue.arrayUnion(...entries);
    }
    if (meals.length > 0) {
      syncData.meals = meals;
    }

    await syncRef.set(syncData, {merge: true});

    // Save latest profile snapshot at user_sync/{deviceId}/profile
    if (profile) {
      await db
        .collection("user_sync")
        .doc(deviceId)
        .set(
          {
            profile,
            profileUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
          },
          {merge: true}
        );
    }

    // Update user doc with latest entry count
    await db.collection("users").doc(deviceId).update({
      lastSyncAt: admin.firestore.FieldValue.serverTimestamp(),
      totalSyncedEntries: admin.firestore.FieldValue.increment(entries.length),
    });

    console.log(
      `✅ [Sync] ${deviceId}: ${entries.length} entries, ${meals.length} meals` +
        (profile ? ", profile synced" : "")
    );
    return true;
  } catch (error) {
    console.error(`❌ [Sync] Failed for ${deviceId}:`, error);
    return false;
  }
}

/**
 * claimDailyEnergy — Manual daily claim endpoint
 *
 * POST { deviceId, timezoneOffset?, sync?: { entries, meals, lastSyncTimestamp, syncTimestamp } }
 * Returns: { success, energyClaimed, newBalance, newStreak, tierUpgraded, syncAck, ... }
 */
export const claimDailyEnergy = onRequest(
  {
    timeoutSeconds: 15,
    memory: "256MiB",
    cors: true,
  },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({error: "Method not allowed"});
      return;
    }

    try {
      const {deviceId, timezoneOffset, sync} = req.body;

      if (!deviceId) {
        res.status(400).json({error: "Missing deviceId"});
        return;
      }

      // Process data sync payload (non-blocking)
      let syncAck = false;
      if (sync) {
        syncAck = await processSyncPayload(deviceId, sync);
      }

      // เรียก processCheckIn (ใช้ logic เดิมที่มีอยู่แล้ว)
      const checkInResult = await processCheckIn(deviceId, timezoneOffset);

      if (checkInResult.alreadyCheckedIn) {
        res.status(200).json({
          alreadyClaimed: true,
          message: "Already claimed today",
          syncAck,
        });
        return;
      }

      // ดึง active offers (สำหรับ Quest Bar UI)
      let activeOffers: any[] = [];
      try {
        activeOffers = await getActiveOffers(deviceId);
      } catch (error) {
        console.error("[claimDailyEnergy] Failed to get active offers:", error);
      }

      res.status(200).json({
        success: true,
        energyClaimed: checkInResult.dailyEnergy + checkInResult.tierRewardEnergy,
        newBalance: checkInResult.newBalance,
        newStreak: checkInResult.currentStreak,
        tierUpgraded: checkInResult.tierUpgraded,
        newTier: checkInResult.tierUpgraded ? checkInResult.newTier : null,
        tierReward: checkInResult.tierRewardEnergy,
        activeOffers,
        syncAck,
      });
    } catch (error: any) {
      console.error("❌ [claimDailyEnergy] Error:", error);
      res.status(500).json({error: error.message});
    }
  }
);
