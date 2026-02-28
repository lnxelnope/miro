/**
 * claimDailyEnergy.ts
 *
 * V3: Manual Daily Claim Endpoint
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

/**
 * claimDailyEnergy — Manual daily claim endpoint
 *
 * POST { deviceId, timezoneOffset? }
 * Returns: { success, energyClaimed, newBalance, newStreak, tierUpgraded, ... }
 */
export const claimDailyEnergy = onRequest(
  {
    timeoutSeconds: 10,
    memory: "256MiB",
    cors: true,
  },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({error: "Method not allowed"});
      return;
    }

    try {
      const {deviceId, timezoneOffset} = req.body;

      if (!deviceId) {
        res.status(400).json({error: "Missing deviceId"});
        return;
      }

      // เรียก processCheckIn (ใช้ logic เดิมที่มีอยู่แล้ว)
      const checkInResult = await processCheckIn(deviceId, timezoneOffset);

      if (checkInResult.alreadyCheckedIn) {
        res.status(200).json({
          alreadyClaimed: true,
          message: "Already claimed today",
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
      });
    } catch (error: any) {
      console.error("❌ [claimDailyEnergy] Error:", error);
      res.status(500).json({error: error.message});
    }
  }
);
