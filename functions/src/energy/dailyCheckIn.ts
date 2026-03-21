/**
 * dailyCheckIn.ts
 *
 * Streak Tier System with Gradual Demotion
 *
 * Grace: Starter/Bronze = 0, Silver/Gold/Diamond = 1 day
 * Demote: miss beyond grace → drop 1 tier, streak = new tier's baseline
 * Floor: Starter (none)
 */

import {onRequest} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {sendTierUpNotification} from "../notifications/pushTriggers";
import {evaluateOffers} from "./offerEngine";

const TIER_UPGRADE_REWARDS: Record<string, number> = {
  bronze: 5,
  silver: 10,
  gold: 15,
  diamond: 25,
};

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

// ─── Tier Configuration ───
const DAILY_ENERGY_REWARD: Record<string, number> = {
  none: 1,
  bronze: 1,
  silver: 2,
  gold: 3,
  diamond: 4,
};

const TIER_UPGRADE_DAYS: Record<string, number> = {
  bronze: 7,
  silver: 14,
  gold: 30,
  diamond: 60,
};

const TIER_ORDER = ["none", "bronze", "silver", "gold", "diamond"];

function getTierIndex(tier: string): number {
  return TIER_ORDER.indexOf(tier);
}

function getGraceDays(tier: string): number {
  switch (tier) {
  case "silver":
  case "gold":
  case "diamond":
    return 1;
  default:
    return 0; // none, bronze
  }
}

/**
 * Demote tier by 1 step
 * Diamond → Gold → Silver → Bronze → Starter(none)
 */
function demoteTier(tier: string): string {
  const idx = getTierIndex(tier);
  if (idx <= 0) return "none";
  return TIER_ORDER[idx - 1];
}

/**
 * Get the streak baseline for a tier.
 * When demoted TO this tier, streak resets to this value
 * so the user keeps their "invested" days.
 *
 * Diamond(60) demoted → Gold: streak = 30
 * Gold(30) demoted → Silver: streak = 14
 * Silver(14) demoted → Bronze: streak = 7
 * Bronze(7) demoted → Starter: streak = 1
 */
function getTierBaselineStreak(tier: string): number {
  return TIER_UPGRADE_DAYS[tier] || 1;
}

function daysBetween(dateStr1: string, dateStr2: string): number {
  const d1 = new Date(dateStr1);
  const d2 = new Date(dateStr2);
  const diffMs = Math.abs(d2.getTime() - d1.getTime());
  return Math.floor(diffMs / (1000 * 60 * 60 * 24));
}

function getTodayString(_timezoneOffset?: number): string {
  const now = new Date();
  // SECURITY: บังคับ UTC+7 server-side เสมอ ป้องกัน timezone manipulation
  const localTime = new Date(now.getTime() + 420 * 60 * 1000);
  return localTime.toISOString().split("T")[0];
}

// ─── Interface ───
export interface CheckInResult {
  success: boolean;
  currentStreak: number;
  longestStreak: number;
  tier: string;
  tierUpgraded: boolean;
  tierDemoted: boolean;
  previousTier?: string;
  newTier?: string;
  energyBonus: number;
  dailyEnergy: number;
  tierRewardEnergy: number;
  promotionBonusRate: number;
  newBalance?: number;
  alreadyCheckedIn: boolean;
  showWelcomeBackOffer: boolean;
}

/**
 * processCheckIn — Streak system with gradual demotion
 */
export async function processCheckIn(
  deviceId: string,
  timezoneOffset?: number
): Promise<CheckInResult> {
  const today = getTodayString(timezoneOffset);
  const userRef = db.collection("users").doc(deviceId);

  const result = await db.runTransaction(async (transaction) => {
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
    const highestTier = user.highestTier || tier;

    // ─── Already checked in today ───
    if (lastCheckInDate === today) {
      return {
        success: true,
        currentStreak,
        longestStreak,
        tier,
        tierUpgraded: false,
        tierDemoted: false,
        energyBonus: 0,
        dailyEnergy: 0,
        tierRewardEnergy: 0,
        promotionBonusRate: 0,
        newBalance: balance,
        alreadyCheckedIn: true,
        showWelcomeBackOffer: false,
      };
    }

    // ─── Calculate new streak & tier ───
    let newStreak: number;
    let newTier = tier;
    let tierDemoted = false;
    let tierUpgraded = false;
    let previousTier: string | undefined;

    if (lastCheckInDate === null) {
      // First ever check-in
      console.log(`🎉 [Check-in] First check-in: ${deviceId}`);
      newStreak = 1;
    } else {
      const daysSince = daysBetween(lastCheckInDate, today);
      const grace = getGraceDays(tier);

      console.log(
        `📅 [Check-in] ${deviceId}: daysSince=${daysSince}, tier=${tier}, grace=${grace}`
      );

      if (daysSince <= 1 + grace) {
        // Within grace → streak continues
        newStreak = currentStreak + 1;
        console.log(`✅ [Check-in] Streak continues: ${newStreak}`);
      } else {
        // Beyond grace → demote 1 tier, streak = new tier's baseline
        previousTier = tier;
        newTier = demoteTier(tier);
        tierDemoted = true;
        newStreak = getTierBaselineStreak(newTier);
        console.log(`📉 [Check-in] Demoted: ${tier} → ${newTier}, streak set to ${newStreak}`);
      }
    }

    if (newStreak > longestStreak) {
      longestStreak = newStreak;
    }

    // ─── Check tier upgrade (only if not demoted) ───
    if (!tierDemoted) {
      for (const checkTier of [...TIER_ORDER].reverse()) {
        const days = TIER_UPGRADE_DAYS[checkTier];
        if (days && newStreak >= days && getTierIndex(newTier) < getTierIndex(checkTier)) {
          previousTier = newTier;
          newTier = checkTier;
          tierUpgraded = true;
          console.log(`🎊 [Check-in] Tier upgraded: ${previousTier} → ${newTier}`);
          break;
        }
      }
    }

    // ─── Track highest tier ever ───
    const newHighestTier = getTierIndex(newTier) > getTierIndex(highestTier)
      ? newTier
      : highestTier;

    // ─── Welcome Back Offer ───
    // Was Diamond+ but now at Starter/Bronze → offer 40% off
    let showWelcomeBackOffer = false;
    if (
      tierDemoted &&
      getTierIndex(highestTier) >= getTierIndex("diamond") &&
      getTierIndex(newTier) <= getTierIndex("bronze")
    ) {
      showWelcomeBackOffer = true;
      console.log(`🎁 [Check-in] Welcome Back Offer triggered for ${deviceId}`);
    }

    // ─── Tier Upgrade Reward (1-time per tier) ───
    let tierRewardEnergy = 0;
    if (tierUpgraded) {
      const promotions = user.promotions || {};
      const tierRewardsClaimed = promotions.tierRewardClaimed || {};
      if (!tierRewardsClaimed[newTier]) {
        tierRewardEnergy = TIER_UPGRADE_REWARDS[newTier] || 0;
        console.log(`🏆 [Check-in] Tier reward: +${tierRewardEnergy} Energy (${newTier})`);
      }
    }

    // ─── Daily Energy Reward ───
    const effectiveTier = newTier;
    const dailyEnergy = DAILY_ENERGY_REWARD[effectiveTier] || 1;
    console.log(`⚡ [Check-in] Daily: +${dailyEnergy} Energy (${effectiveTier})`);

    // ─── V3: ลบ Random Daily Bonus ออกแล้ว ───

    // ─── Update user document ───
    const totalBonus = dailyEnergy + tierRewardEnergy;
    const updates: Record<string, any> = {
      currentStreak: newStreak,
      longestStreak,
      tier: newTier,
      highestTier: newHighestTier,
      lastCheckInDate: today,
      balance: balance + totalBonus,
      totalEarned: (user.totalEarned || 0) + totalBonus,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    };

    if (tierUpgraded) {
      updates[`tierUnlockedAt.${newTier}`] = admin.firestore.FieldValue.serverTimestamp();
      if (newTier === "gold") updates.bonusRate = 0.10;
      if (newTier === "diamond") updates.bonusRate = 0.20;
      // Mark tier reward as claimed (1-time)
      if (tierRewardEnergy > 0) {
        updates[`promotions.tierRewardClaimed.${newTier}`] = true;
      }
      // ─── Tier Celebration: Initialize 7-day celebration for new tier ───
      console.log(`🎉 [TierCelebration] Initializing ${newTier} celebration for ${deviceId}`);
      updates[`tierCelebration.${newTier}`] = {
        startDate: today,
        claimedDays: [],
      };
    }

    if (tierDemoted) {
      if (newTier === "gold") updates.bonusRate = 0.10;
      else if (newTier === "diamond") updates.bonusRate = 0.20;
      else updates.bonusRate = 0;
    }

    transaction.update(userRef, updates);

    // ─── Log transactions ───
    const txRef = db.collection("transactions").doc();
    transaction.set(txRef, {
      deviceId,
      miroId: user.miroId || "unknown",
      type: "daily_checkin",
      amount: dailyEnergy,
      balanceAfter: balance + totalBonus,
      description: tierDemoted
        ? `Daily check-in: +${dailyEnergy} Energy (demoted ${tier} → ${newTier})`
        : tierUpgraded
          ? `Daily check-in: +${dailyEnergy} Energy (upgraded to ${newTier}!)`
          : `Daily check-in: +${dailyEnergy} Energy (${effectiveTier})`,
      metadata: {
        tier: effectiveTier,
        streak: newStreak,
        tierUpgraded,
        tierDemoted,
        previousTier: previousTier || null,
      },
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Log tier reward transaction
    if (tierRewardEnergy > 0) {
      const txRef3 = db.collection("transactions").doc();
      transaction.set(txRef3, {
        deviceId,
        miroId: user.miroId || "unknown",
        type: "tier_upgrade_reward",
        amount: tierRewardEnergy,
        balanceAfter: balance + totalBonus,
        description: `Tier Up! ${newTier} → +${tierRewardEnergy} Energy`,
        metadata: {tier: newTier, previousTier: previousTier || null},
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    return {
      success: true,
      currentStreak: newStreak,
      longestStreak,
      tier: newTier,
      tierUpgraded,
      tierDemoted,
      previousTier,
      newTier: tierUpgraded ? newTier : undefined,
      dailyEnergy,
      energyBonus: dailyEnergy,
      tierRewardEnergy,
        promotionBonusRate: 0, // will be set after transaction
        showWelcomeBackOffer,
        newBalance: balance + totalBonus,
        alreadyCheckedIn: false,
      };
  });

  // ─── Post-transaction: Notifications + offer evaluation ───
  if (result.tierUpgraded && result.newTier) {
    try {
      await sendTierUpNotification(deviceId, result.newTier, result.tierRewardEnergy);
    } catch (error) {
      console.error("[Check-in] Failed to send tier up notification:", error);
    }

    try {
      await evaluateOffers(deviceId, "tier_up", {
        newTier: result.newTier,
        previousTier: result.previousTier,
      });
    } catch (e) {
      console.error("[dailyCheckIn] evaluateOffers error:", e);
    }
  }

  return result;
}

/**
 * claimDailyCheckIn HTTP Endpoint
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
