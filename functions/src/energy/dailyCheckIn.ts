/**
 * dailyCheckIn.ts
 *
 * Streak Tier System with Grace Period
 */

import {onRequest} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {
  checkComebackBonus,
} from "../comeback/checkComebackBonus";
import {getABTestConfig} from "../abTesting/getABGroup";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

// ─── Tier Configuration ───
// (อ่านจาก config/rewards ใน production)
// Phase 4: Support A/B testing for tier rewards
const DEFAULT_TIER_CONFIG = {
  bronze: {days: 7, energy: 10, graceDays: 0},
  silver: {days: 14, energy: 15, graceDays: 1},
  gold: {days: 30, energy: 30, graceDays: 2},
  diamond: {days: 60, energy: 45, graceDays: 3},
};

const TIER_ORDER = ["none", "bronze", "silver", "gold", "diamond"];

/**
 * หา index ของ tier (สำหรับเปรียบเทียบ)
 */
function getTierIndex(tier: string): number {
  return TIER_ORDER.indexOf(tier);
}

/**
 * หา Grace Period ของ tier
 */
function getGraceDays(tier: string): number {
  switch (tier) {
  case "silver": return 1;
  case "gold": return 2;
  case "diamond": return 3;
  default: return 0; // none, bronze
  }
}

/**
 * คำนวณจำนวนวันระหว่าง 2 วัน
 *
 * @param dateStr1 "YYYY-MM-DD"
 * @param dateStr2 "YYYY-MM-DD"
 * @return จำนวนวัน (absolute)
 */
function daysBetween(dateStr1: string, dateStr2: string): number {
  const d1 = new Date(dateStr1);
  const d2 = new Date(dateStr2);
  const diffMs = Math.abs(d2.getTime() - d1.getTime());
  return Math.floor(diffMs / (1000 * 60 * 60 * 24));
}

/**
 * ดึงวันที่ปัจจุบัน (YYYY-MM-DD)
 */
function getTodayString(timezoneOffset?: number): string {
  const now = new Date();
  const offset = timezoneOffset ?? 420; // UTC+7
  const localTime = new Date(now.getTime() + offset * 60 * 1000);
  return localTime.toISOString().split("T")[0];
}

// ─── Interface ───
export interface CheckInResult {
  success: boolean;
  currentStreak: number;
  longestStreak: number;
  tier: string;
  tierUpgraded: boolean;
  newTier?: string;
  energyBonus: number;
  newBalance?: number;
  alreadyCheckedIn: boolean;
}

/**
 * processCheckIn
 *
 * หัวใจของ Streak System
 *
 * @param deviceId User device ID
 * @param timezoneOffset Timezone offset (default: 420 = UTC+7)
 * @return CheckInResult
 */
export async function processCheckIn(
  deviceId: string,
  timezoneOffset?: number
): Promise<CheckInResult> {
  const today = getTodayString(timezoneOffset);
  const userRef = db.collection("users").doc(deviceId);

  return db.runTransaction(async (transaction) => {
    const userDoc = await transaction.get(userRef);

    if (!userDoc.exists) {
      throw new Error("User not found");
    }

    const user = userDoc.data()!;
    const lastCheckInDate = user.lastCheckInDate || null;
    const currentStreak = user.currentStreak || 0;
    const tier = user.tier || "none";
    const balance = user.balance || 0;
    let longestStreak = user.longestStreak || 0;

    // ─── Already checked in today ───
    if (lastCheckInDate === today) {
      console.log(`⏭️  [Check-in] Already checked in today: ${deviceId}`);

      return {
        success: true,
        currentStreak,
        longestStreak,
        tier,
        tierUpgraded: false,
        energyBonus: 0,
        newBalance: balance,
        alreadyCheckedIn: true,
      };
    }

    // ─── Calculate new streak ───
    let newStreak: number;

    if (lastCheckInDate === null) {
      // First ever check-in
      console.log(`🎉 [Check-in] First check-in for ${deviceId}`);
      newStreak = 1;
    } else {
      const daysSince = daysBetween(lastCheckInDate, today);
      const grace = getGraceDays(tier);

      console.log(
        `📅 [Check-in] ${deviceId}: last=${lastCheckInDate}, today=${today}, ` +
        `daysSince=${daysSince}, tier=${tier}, grace=${grace}`
      );

      if (daysSince <= 1 + grace) {
        // Within grace period → continue streak
        newStreak = currentStreak + 1;
        console.log(`✅ [Check-in] Streak continues: ${newStreak}`);
      } else {
        // Streak broken → reset to 1
        newStreak = 1;
        console.log("💔 [Check-in] Streak broken, reset to 1");
      }
    }

    // Update longest streak
    if (newStreak > longestStreak) {
      longestStreak = newStreak;
    }

    // ─── Check tier upgrade ───
    let newTier = tier;
    let tierUpgraded = false;
    let energyBonus = 0;

    // Phase 4: Get tier rewards from A/B test if available
    const bronzeEnergy = await getABTestConfig(deviceId, "tier.bronze.energy", DEFAULT_TIER_CONFIG.bronze.energy);
    const silverEnergy = await getABTestConfig(deviceId, "tier.silver.energy", DEFAULT_TIER_CONFIG.silver.energy);
    const goldEnergy = await getABTestConfig(deviceId, "tier.gold.energy", DEFAULT_TIER_CONFIG.gold.energy);
    const diamondEnergy = await getABTestConfig(deviceId, "tier.diamond.energy", DEFAULT_TIER_CONFIG.diamond.energy);

    // เช็คจาก tier สูงสุดก่อน (เพื่อ upgrade ข้าม tier ได้)
    const tierChecks = [
      {name: "diamond", days: DEFAULT_TIER_CONFIG.diamond.days, energy: diamondEnergy},
      {name: "gold", days: DEFAULT_TIER_CONFIG.gold.days, energy: goldEnergy},
      {name: "silver", days: DEFAULT_TIER_CONFIG.silver.days, energy: silverEnergy},
      {name: "bronze", days: DEFAULT_TIER_CONFIG.bronze.days, energy: bronzeEnergy},
    ];

    for (const check of tierChecks) {
      if (newStreak >= check.days && getTierIndex(tier) < getTierIndex(check.name)) {
        newTier = check.name;
        tierUpgraded = true;
        energyBonus = check.energy;

        // Phase 5: Double rewards for subscribers
        const isSubscriber = user.subscription?.status === "active";
        if (isSubscriber) {
          energyBonus *= 2;
          console.log(`💎 [Check-in] Subscriber bonus: ${check.energy} → ${energyBonus} Energy`);
        }

        console.log(`🎊 [Check-in] Tier upgraded: ${tier} → ${newTier} (+${energyBonus} Energy)`);
        break; // Upgrade one tier at a time
      }
    }

    // ─── Random Daily Bonus (Phase 2) ───
    let randomBonus = 0;
    let gotRandomBonus = false;

    // Phase 4: Get config from A/B test if available
    const randomBonusChance = await getABTestConfig(deviceId, "randomBonus.chance", 0.05);
    const randomBonusMin = await getABTestConfig(deviceId, "randomBonus.minReward", 5);
    const randomBonusMax = await getABTestConfig(deviceId, "randomBonus.maxReward", 10);

    // Roll dice
    const roll = Math.random();
    if (roll < randomBonusChance) {
      randomBonus = Math.floor(
        Math.random() * (randomBonusMax - randomBonusMin + 1) + randomBonusMin
      );
      gotRandomBonus = true;
      console.log(`🎲 [Check-in] Random bonus! +${randomBonus} Energy`);
    }

    // ─── Phase 4: Comeback Bonus ───
    let comebackBonus = 0;
    let gotComebackBonus = false;
    let comebackData: {
      bonus: number;
      streakFreeze: boolean;
      startAtBronze: boolean;
      daysAway: number;
    } | null = null;

    if (lastCheckInDate && daysBetween(lastCheckInDate, today) > 3) {
      // หายไปมากกว่า 3 วัน → เช็ค comeback bonus
      comebackData = await checkComebackBonus(
        deviceId,
        lastCheckInDate,
        currentStreak
      );

      if (comebackData.bonus > 0) {
        comebackBonus = comebackData.bonus;
        gotComebackBonus = true;
        console.log(
          `🎉 [Check-in] Comeback bonus! +${comebackBonus} Energy (${comebackData.daysAway} days away)`
        );
      }
    }

    // ─── Update user document ───
    const totalBonus = energyBonus + randomBonus + comebackBonus;
    const updates: Record<string, any> = {
      currentStreak: newStreak,
      longestStreak,
      lastCheckInDate: today,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    };

    if (tierUpgraded) {
      updates.tier = newTier;
      updates[`tierUnlockedAt.${newTier}`] = admin.firestore.FieldValue.serverTimestamp();
      updates.totalEarned = (user.totalEarned || 0) + energyBonus;

      // Set bonus rate for Gold/Diamond (Phase 2)
      if (newTier === "gold") updates.bonusRate = 0.20;
      if (newTier === "diamond") updates.bonusRate = 0.30;
    }

    if (gotRandomBonus) {
      updates.lastRandomBonus = today;
      updates.randomBonusCount = (user.randomBonusCount || 0) + 1;
      updates.totalEarned = (updates.totalEarned || user.totalEarned || 0) + randomBonus;
    }

    if (gotComebackBonus && comebackData) {
      updates.totalEarned = (updates.totalEarned || user.totalEarned || 0) + comebackBonus;

      // Apply comeback bonus effects
      if (comebackData.streakFreeze && currentStreak > 0) {
        // Keep streak (already handled above)
      }

      if (comebackData.startAtBronze && currentStreak === 0) {
        updates.tier = "bronze";
        updates.currentStreak = 7;
        updates["tierUnlockedAt.bronze"] = admin.firestore.FieldValue.serverTimestamp();
      }
    }

    if (totalBonus > 0) {
      updates.balance = balance + totalBonus;
    }

    transaction.update(userRef, updates);

    // ─── Log transaction (if tier bonus) ───
    if (tierUpgraded && energyBonus > 0) {
      const txRef = db.collection("transactions").doc();
      transaction.set(txRef, {
        deviceId,
        miroId: user.miroId || "unknown",
        type: "streak_bonus",
        amount: energyBonus,
        balanceAfter: balance + totalBonus,
        description: `Streak Tier unlocked: ${newTier}! +${energyBonus} Energy`,
        metadata: {
          tier: newTier,
          streak: newStreak,
        },
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    // ─── Log transaction (if random bonus) ───
    if (gotRandomBonus && randomBonus > 0) {
      const txRef = db.collection("transactions").doc();
      transaction.set(txRef, {
        deviceId,
        miroId: user.miroId || "unknown",
        type: "random_bonus",
        amount: randomBonus,
        balanceAfter: balance + totalBonus,
        description: `Lucky! Random bonus: +${randomBonus} Energy 🎲`,
        metadata: {
          roll,
          chance: randomBonusChance,
        },
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    // ─── Log transaction (if comeback bonus) ───
    if (gotComebackBonus && comebackBonus > 0 && comebackData) {
      const txRef = db.collection("transactions").doc();
      transaction.set(txRef, {
        deviceId,
        miroId: user.miroId || "unknown",
        type: "comeback_bonus",
        amount: comebackBonus,
        balanceAfter: balance + totalBonus,
        description: `Welcome back! +${comebackBonus} Energy (${comebackData.daysAway} days away)`,
        metadata: {
          daysAway: comebackData.daysAway,
          streakFreeze: comebackData.streakFreeze,
          startAtBronze: comebackData.startAtBronze,
        },
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    return {
      success: true,
      currentStreak: newStreak,
      longestStreak,
      tier: newTier,
      tierUpgraded,
      newTier: tierUpgraded ? newTier : undefined,
      energyBonus,
      randomBonus,
      gotRandomBonus,
      comebackBonus,
      gotComebackBonus,
      comebackDaysAway: comebackData?.daysAway || 0,
      newBalance: balance + totalBonus,
      alreadyCheckedIn: false,
    };
  });
}

/**
 * claimDailyCheckIn HTTP Endpoint
 *
 * Optional: ให้ user check-in โดยไม่ต้องใช้ AI
 */
export const claimDailyCheckIn = onRequest(
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

      const result = await processCheckIn(deviceId, timezoneOffset);
      res.status(200).json(result);
    } catch (error: any) {
      console.error("❌ [claimDailyCheckIn] Error:", error);
      res.status(500).json({error: error.message});
    }
  }
);
