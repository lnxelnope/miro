/**
 * challenge.ts
 *
 * Daily & Weekly Challenges System
 *
 * Daily (reset ทุกวัน):
 *   - dailyAi1:  ใช้ AI 1 ครั้ง  → 1E (เพิ่มตาม tier)
 *   - dailyAi10: ใช้ AI 10 ครั้ง → 2E
 *
 * Weekly (reset วันจันทร์):
 *   - weeklyAi20: ใช้ AI 20 ครั้ง → 3E
 *   - weeklyAi40: ใช้ AI 40 ครั้ง → 4E
 *   - weeklyAi60: ใช้ AI 60 ครั้ง → 5E
 */

import {onRequest} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {checkChallengeFraud} from "../utils/advancedFraudCheck";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

// ─── Challenge Configs ───

const DAILY_CHALLENGES = {
  dailyAi1:  {target: 1,  reward: 1, scaleWithTier: true},
  dailyAi10: {target: 10, reward: 2, scaleWithTier: false},
};

const WEEKLY_CHALLENGES = {
  weeklyAi20: {target: 20, reward: 3},
  weeklyAi40: {target: 40, reward: 4},
  weeklyAi60: {target: 60, reward: 5},
};

// Tier bonus for dailyAi1 only
const TIER_DAILY_BONUS: Record<string, number> = {
  starter: 0,
  bronze: 0,
  silver: 1,
  gold: 2,
  diamond: 3,
};

// Referral quest: 10 levels (like milestones)
const REFERRAL_LEVELS = [
  {level: 1, target: 1, reward: 5},
  {level: 2, target: 2, reward: 5},
  {level: 3, target: 3, reward: 5},
  {level: 4, target: 4, reward: 5},
  {level: 5, target: 5, reward: 5},
  {level: 6, target: 6, reward: 5},
  {level: 7, target: 7, reward: 5},
  {level: 8, target: 8, reward: 5},
  {level: 9, target: 9, reward: 5},
  {level: 10, target: 10, reward: 25},
];

// Counter increment is done atomically inside deductBalance (analyzeFood.ts)

/**
 * completeChallenge Cloud Function
 * Claim reward for daily/weekly/referral challenges
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
      const {deviceId, challengeType, referralLevel} = req.body;

      if (!deviceId || !challengeType) {
        res.status(400).json({error: "Missing deviceId or challengeType"});
        return;
      }

      const validTypes = [
        "dailyAi1", "dailyAi10",
        "weeklyAi20", "weeklyAi40", "weeklyAi60",
        "referFriends",
        "tierCelebration",
        "seasonal",
      ];
      if (!validTypes.includes(challengeType)) {
        res.status(400).json({error: "Invalid challengeType"});
        return;
      }

      // ─── Tier Celebration: 2E/day x 7 days (lifetime per tier) ───
      if (challengeType === "tierCelebration") {
        const {tier} = req.body;
        if (!tier) {
          res.status(400).json({error: "Missing tier parameter"});
          return;
        }

        const validTiers = ["starter", "bronze", "silver", "gold", "diamond"];
        if (!validTiers.includes(tier)) {
          res.status(400).json({error: "Invalid tier"});
          return;
        }

        // Helper: Calculate day difference
        function daysDiff(dateStr1: string, dateStr2: string): number {
          const d1 = new Date(dateStr1);
          const d2 = new Date(dateStr2);
          const diffMs = d2.getTime() - d1.getTime();
          return Math.floor(diffMs / (1000 * 60 * 60 * 24));
        }

        // Get today string (UTC+7)
        function getTodayString(): string {
          const now = new Date();
          const localTime = new Date(now.getTime() + 420 * 60 * 1000);
          return localTime.toISOString().split("T")[0];
        }

        const today = getTodayString();
        const userRef = db.collection("users").doc(deviceId);

        const result = await db.runTransaction(async (transaction) => {
          const userDoc = await transaction.get(userRef);
          if (!userDoc.exists) throw new Error("User not found");

          const userData = userDoc.data()!;
          const tierCelebration = userData.tierCelebration?.[tier];

          if (!tierCelebration) {
            throw new Error(`Tier celebration not found for ${tier}`);
          }

          const {startDate, claimedDays} = tierCelebration;
          const dayNumber = daysDiff(startDate, today) + 1;

          // Validate day window (1-7)
          if (dayNumber < 1 || dayNumber > 7) {
            throw new Error(`Celebration expired: day ${dayNumber} (valid: 1-7)`);
          }

          // Check if already claimed today
          if (claimedDays.includes(dayNumber)) {
            throw new Error(`Day ${dayNumber} already claimed`);
          }

          const reward = 2;
          const balance = userData.balance || 0;
          const newBalance = balance + reward;

          transaction.update(userRef, {
            balance: newBalance,
            totalEarned: (userData.totalEarned || 0) + reward,
            [`tierCelebration.${tier}.claimedDays`]: [...claimedDays, dayNumber],
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          });

          const txRef = db.collection("transactions").doc();
          transaction.set(txRef, {
            deviceId,
            miroId: userData.miroId || "unknown",
            type: "tier_celebration",
            amount: reward,
            balanceAfter: newBalance,
            description: `${tier.charAt(0).toUpperCase() + tier.slice(1)} Celebration Day ${dayNumber}: +${reward}E`,
            metadata: {tier, dayNumber, reward},
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });

          return {success: true, reward, dayNumber, newBalance};
        });

        console.log(`🎉 [TierCelebration] ${deviceId} claimed ${tier} day ${result.dayNumber}: +${result.reward}E`);
        res.status(200).json(result);
        return;
      }

      // ─── Seasonal Quest Claim ───
      if (challengeType === "seasonal") {
        const {questId} = req.body;
        if (!questId) {
          res.status(400).json({error: "Missing questId parameter"});
          return;
        }

        // Get today string (UTC+7)
        function getTodayStringSeasonal(): string {
          const now = new Date();
          const localTime = new Date(now.getTime() + 420 * 60 * 1000);
          return localTime.toISOString().split("T")[0];
        }

        const today = getTodayStringSeasonal();

        // Fetch quest config
        const questDoc = await db.collection("seasonal_quests").doc(questId).get();
        if (!questDoc.exists) {
          res.status(404).json({error: "Quest not found"});
          return;
        }
        const quest = questDoc.data()!;

        // Check quest is active
        if (quest.status !== "active") {
          res.status(400).json({error: "Quest is not active"});
          return;
        }

        // Check date range
        if (today < quest.startDate || today > quest.endDate) {
          res.status(400).json({error: "Quest is not within active date range"});
          return;
        }

        const userRef = db.collection("users").doc(deviceId);

        const result = await db.runTransaction(async (transaction) => {
          const userDoc = await transaction.get(userRef);
          if (!userDoc.exists) throw new Error("User not found");

          const userData = userDoc.data()!;
          const progress = userData.seasonalProgress?.[questId] || {};

          if (quest.claimType === "one_time") {
            // ─── One-time claim ───
            if (progress.claimed === true) {
              throw new Error("Already claimed");
            }

            const reward = quest.rewardPerClaim;
            const balance = userData.balance || 0;
            const newBalance = balance + reward;

            transaction.update(userRef, {
              balance: newBalance,
              totalEarned: (userData.totalEarned || 0) + reward,
              [`seasonalProgress.${questId}.claimed`]: true,
              lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
            });

            const txRef = db.collection("transactions").doc();
            transaction.set(txRef, {
              deviceId,
              miroId: userData.miroId || "unknown",
              type: "seasonal_quest",
              amount: reward,
              balanceAfter: newBalance,
              description: `${quest.title}: +${reward}E`,
              metadata: {questId, claimType: "one_time", reward},
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });

            return {success: true, reward, newBalance, claimType: "one_time"};
          } else {
            // ─── Daily claim ───
            const claimedDays: string[] = progress.claimedDays || [];

            if (claimedDays.includes(today)) {
              throw new Error("Already claimed today");
            }

            const reward = quest.rewardPerClaim;
            const balance = userData.balance || 0;
            const newBalance = balance + reward;

            transaction.update(userRef, {
              balance: newBalance,
              totalEarned: (userData.totalEarned || 0) + reward,
              [`seasonalProgress.${questId}.claimedDays`]: [...claimedDays, today],
              lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
            });

            const txRef = db.collection("transactions").doc();
            transaction.set(txRef, {
              deviceId,
              miroId: userData.miroId || "unknown",
              type: "seasonal_quest",
              amount: reward,
              balanceAfter: newBalance,
              description: `${quest.title} (Day): +${reward}E`,
              metadata: {questId, claimType: "daily", date: today, reward},
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });

            return {success: true, reward, newBalance, claimType: "daily", date: today};
          }
        });

        console.log(`🎄 [Seasonal] ${deviceId} claimed ${questId}: +${result.reward}E`);
        res.status(200).json(result);
        return;
      }

      // ─── Referral: 10 levels ───
      if (challengeType === "referFriends") {
        if (!referralLevel || referralLevel < 1 || referralLevel > 10) {
          res.status(400).json({error: "Invalid referralLevel (1-10 required)"});
          return;
        }

        const level = REFERRAL_LEVELS.find(l => l.level === referralLevel);
        if (!level) {
          res.status(400).json({error: "Invalid referralLevel"});
          return;
        }

        const userRef = db.collection("users").doc(deviceId);
        const result = await db.runTransaction(async (transaction) => {
          const userDoc = await transaction.get(userRef);
          if (!userDoc.exists) throw new Error("User not found");

          const userData = userDoc.data()!;
          const weekly = userData.challenges?.weekly || {};
          const balance = userData.balance || 0;
          const claimedRewards = weekly.claimedRewards || [];
          const referFriends = weekly.referFriends || 0;

          if (referFriends < level.target) {
            throw new Error(`Level ${level.level} not reached: ${referFriends}/${level.target}`);
          }

          const claimKey = `referFriends_${level.level}`;
          if (claimedRewards.includes(claimKey)) {
            throw new Error(`Level ${level.level} already claimed`);
          }

          const newBalance = balance + level.reward;
          transaction.update(userRef, {
            balance: newBalance,
            totalEarned: (userData.totalEarned || 0) + level.reward,
            "challenges.weekly.claimedRewards": [...claimedRewards, claimKey],
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          });

          const txRef = db.collection("transactions").doc();
          transaction.set(txRef, {
            deviceId,
            miroId: userData.miroId || "unknown",
            type: "challenge",
            amount: level.reward,
            balanceAfter: newBalance,
            description: `Referral Level ${level.level}: +${level.reward}E`,
            metadata: {challengeType, level: level.level, reward: level.reward},
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });

          return {success: true, challengeType, level: level.level, reward: level.reward, newBalance};
        });

        res.status(200).json(result);
        return;
      }

      // ─── Daily / Weekly challenges ───
      const isDaily = challengeType.startsWith("daily");
      const userRef = db.collection("users").doc(deviceId);

      const fraudCheck = await checkChallengeFraud(deviceId);
      if (fraudCheck.isSuspicious) {
        res.status(403).json({error: "Blocked: suspicious activity", reason: fraudCheck.reason});
        return;
      }

      const result = await db.runTransaction(async (transaction) => {
        const userDoc = await transaction.get(userRef);
        if (!userDoc.exists) throw new Error("User not found");

        const userData = userDoc.data()!;
        const balance = userData.balance || 0;

        if (isDaily) {
          const daily = userData.challenges?.daily || {};
          const aiCount = daily.aiCount || 0;
          const claimedRewards = daily.claimedRewards || [];

          const config = DAILY_CHALLENGES[challengeType as keyof typeof DAILY_CHALLENGES];
          if (!config) throw new Error("Invalid daily challenge");

          if (aiCount < config.target) {
            throw new Error(`Not completed: ${aiCount}/${config.target}`);
          }
          if (claimedRewards.includes(challengeType)) {
            throw new Error("Already claimed");
          }

          // Calculate reward (with tier bonus for dailyAi1)
          let reward = config.reward;
          if (config.scaleWithTier) {
            const tier = userData.tier || "starter";
            reward += TIER_DAILY_BONUS[tier] || 0;
          }

          const newBalance = balance + reward;
          transaction.update(userRef, {
            balance: newBalance,
            totalEarned: (userData.totalEarned || 0) + reward,
            "challenges.daily.claimedRewards": [...claimedRewards, challengeType],
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          });

          const txRef = db.collection("transactions").doc();
          transaction.set(txRef, {
            deviceId,
            miroId: userData.miroId || "unknown",
            type: "challenge",
            amount: reward,
            balanceAfter: newBalance,
            description: `Daily: ${challengeType} (+${reward}E)`,
            metadata: {challengeType, target: config.target, reward},
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });

          return {success: true, challengeType, reward, newBalance};
        } else {
          // Weekly
          const weekly = userData.challenges?.weekly || {};
          const aiCount = weekly.aiCount || 0;
          const claimedRewards = weekly.claimedRewards || [];

          const config = WEEKLY_CHALLENGES[challengeType as keyof typeof WEEKLY_CHALLENGES];
          if (!config) throw new Error("Invalid weekly challenge");

          if (aiCount < config.target) {
            throw new Error(`Not completed: ${aiCount}/${config.target}`);
          }
          if (claimedRewards.includes(challengeType)) {
            throw new Error("Already claimed");
          }

          const reward = config.reward;
          const newBalance = balance + reward;
          transaction.update(userRef, {
            balance: newBalance,
            totalEarned: (userData.totalEarned || 0) + reward,
            "challenges.weekly.claimedRewards": [...claimedRewards, challengeType],
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          });

          const txRef = db.collection("transactions").doc();
          transaction.set(txRef, {
            deviceId,
            miroId: userData.miroId || "unknown",
            type: "challenge",
            amount: reward,
            balanceAfter: newBalance,
            description: `Weekly: ${challengeType} (+${reward}E)`,
            metadata: {challengeType, target: config.target, reward},
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });

          return {success: true, challengeType, reward, newBalance};
        }
      });

      console.log(`🎉 [Challenge] ${deviceId} claimed ${challengeType}: +${result.reward}E`);
      res.status(200).json(result);
    } catch (error: any) {
      console.error("❌ [completeChallenge] Error:", error);
      res.status(500).json({error: error.message});
    }
  }
);
