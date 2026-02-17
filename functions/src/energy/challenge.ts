/**
 * challenge.ts
 *
 * Weekly Challenges System
 */

import {onRequest} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {checkChallengeFraud} from "../utils/advancedFraudCheck";
import {getABTestConfig} from "../abTesting/getABGroup";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

// Challenge configuration (Phase 4: Support A/B testing)
const DEFAULT_CHALLENGE_CONFIG = {
  logMeals: {target: 7, reward: 5},
  useAi: {target: 3, reward: 5},
};

/**
 * ดึงวันที่ปัจจุบัน (YYYY-MM-DD)
 */
function getTodayString(timezoneOffset?: number): string {
  const now = new Date();
  const offset = timezoneOffset ?? 420; // UTC+7
  const localTime = new Date(now.getTime() + offset * 60 * 1000);
  return localTime.toISOString().split("T")[0];
}

/**
 * หาวันจันทร์ของสัปดาห์ (week start date)
 *
 * @param dateStr "YYYY-MM-DD"
 * @return วันจันทร์ของสัปดาห์นั้น "YYYY-MM-DD"
 */
function getWeekStartDate(dateStr: string): string {
  const date = new Date(dateStr);
  const day = date.getDay(); // 0 = Sunday, 1 = Monday, ..., 6 = Saturday
  const diff = day === 0 ? 6 : day - 1; // วันจันทร์ = 1, diff = 0
  date.setDate(date.getDate() - diff);
  return date.toISOString().split("T")[0];
}

/**
 * Increment challenge progress
 *
 * @param deviceId User device ID
 * @param challengeType 'logMeals' | 'useAi'
 * @param timezoneOffset Timezone offset (default: 420 = UTC+7)
 */
export async function incrementChallengeProgress(
  deviceId: string,
  challengeType: "logMeals" | "useAi",
  timezoneOffset?: number
): Promise<void> {
  const userRef = db.collection("users").doc(deviceId);
  const today = getTodayString(timezoneOffset);
  const weekStart = getWeekStartDate(today);

  await db.runTransaction(async (transaction) => {
    const userDoc = await transaction.get(userRef);

    if (!userDoc.exists) {
      console.log(`⚠️ [Challenge] User not found: ${deviceId}`);
      return;
    }

    const userData = userDoc.data()!;
    const challenges = userData.challenges?.weekly || {};

    // ถ้าสัปดาห์ใหม่ → reset
    if (challenges.weekStartDate !== weekStart) {
      console.log(`🔄 [Challenge] New week! Resetting challenges for ${deviceId}`);

      transaction.update(userRef, {
        "challenges.weekly": {
          logMeals: challengeType === "logMeals" ? 1 : 0,
          useAi: challengeType === "useAi" ? 1 : 0,
          claimedRewards: [],
          weekStartDate: weekStart,
        },
        "lastUpdated": admin.firestore.FieldValue.serverTimestamp(),
      });
      return;
    }

    // Increment (ถ้ายังไม่ถึง target)
    const current = challenges[challengeType] || 0;
    const target = DEFAULT_CHALLENGE_CONFIG[challengeType].target;

    if (current < target) {
      transaction.update(userRef, {
        [`challenges.weekly.${challengeType}`]: current + 1,
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(
        `📊 [Challenge] ${deviceId}: ${challengeType} = ${current + 1}/${target}`
      );
    } else {
      console.log(
        `✅ [Challenge] ${deviceId}: ${challengeType} already at max (${current}/${target})`
      );
    }
  });
}

/**
 * completeChallenge Cloud Function
 *
 * Claim reward เมื่อ challenge สำเร็จ
 */
export const completeChallenge = onRequest(
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
      const {deviceId, challengeType} = req.body;

      if (!deviceId || !challengeType) {
        res.status(400).json({error: "Missing deviceId or challengeType"});
        return;
      }

      if (challengeType !== "logMeals" && challengeType !== "useAi") {
        res.status(400).json({error: "Invalid challengeType"});
        return;
      }

      const userRef = db.collection("users").doc(deviceId);

      // Phase 4: Get config from A/B test if available
      const challengeKey = challengeType as "logMeals" | "useAi";
      const defaultConfig = DEFAULT_CHALLENGE_CONFIG[challengeKey];
      const reward = await getABTestConfig(
        deviceId,
        `challenge.${challengeType}.reward`,
        defaultConfig.reward
      );

      const config = {
        target: defaultConfig.target,
        reward,
      };

      // Advanced fraud check
      const fraudCheck = await checkChallengeFraud(deviceId);
      if (fraudCheck.isSuspicious) {
        console.log(`🚨 [Challenge] Fraud detected: ${fraudCheck.reason}`);
        res.status(403).json({
          error: "Challenge claim blocked due to suspicious activity",
          reason: fraudCheck.reason,
        });
        return;
      }

      const result = await db.runTransaction(async (transaction) => {
        const userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          throw new Error("User not found");
        }

        const userData = userDoc.data()!;
        const challenges = userData.challenges?.weekly || {};
        const balance = userData.balance || 0;
        const claimedRewards = challenges.claimedRewards || [];

        // Verify progress
        const current = challenges[challengeType] || 0;
        if (current < config.target) {
          throw new Error(`Challenge not completed: ${current}/${config.target}`);
        }

        // Verify not claimed
        if (claimedRewards.includes(challengeType)) {
          throw new Error("Reward already claimed");
        }

        // Phase 5: Double rewards for subscribers
        const isSubscriber = userData.subscription?.status === "active";
        let reward = config.reward;
        if (isSubscriber) {
          reward *= 2;
          console.log(`💎 [Challenge] Subscriber bonus: ${config.reward} → ${reward} Energy`);
        }

        // Award reward
        const newBalance = balance + reward;
        transaction.update(userRef, {
          "balance": newBalance,
          "totalEarned": (userData.totalEarned || 0) + reward,
          "challenges.weekly.claimedRewards": [...claimedRewards, challengeType],
          "lastUpdated": admin.firestore.FieldValue.serverTimestamp(),
        });

        // Log transaction
        const txRef = db.collection("transactions").doc();
        transaction.set(txRef, {
          deviceId,
          miroId: userData.miroId || "unknown",
          type: "challenge",
          amount: reward,
          balanceAfter: newBalance,
          description: `Weekly Challenge: ${challengeType} (+${reward} Energy${isSubscriber ? " [Subscriber 2x]" : ""})`,
          metadata: {
            challengeType,
            progress: current,
            target: config.target,
            baseReward: config.reward,
            isSubscriber,
          },
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        return {
          success: true,
          challengeType,
          reward,
          newBalance,
          isSubscriber,
        };
      });

      console.log(
        `🎉 [Challenge] ${deviceId} claimed ${challengeType}: +${config.reward} Energy`
      );

      res.status(200).json(result);
    } catch (error: any) {
      console.error("❌ [completeChallenge] Error:", error);
      res.status(500).json({error: error.message});
    }
  }
);
