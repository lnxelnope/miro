/**
 * checkReferralProgress — V3.1 Referral with Weekly Quest
 *
 * เรียกเมื่อ: Referee ใช้ AI สำเร็จ (ใน analyzeFood)
 * สิ่งที่ทำ: เช็ค milestones.totalSpent >= 10 → ให้ reward ผู้ชวน
 *
 * V3.1 Changes (Weekly Quest):
 * - Referee: ไม่ได้ reward ที่นี่ (ได้ 20E ตอน submit referral code แล้ว)
 * - Referrer: ได้ 5E base (uncapped) + 5E quest bonus (capped at 10 friends/week)
 * - Increment challenges.weekly.referFriends
 */

import {onRequest} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

const REFERRAL_BASE_REWARD = 5; // Base reward (uncapped)
// Quest bonus is now handled via completeChallenge endpoint

/**
 * Get week start date (Monday) for a given date string
 */
function getWeekStartDate(dateStr: string): string {
  const date = new Date(dateStr);
  const day = date.getDay(); // 0 = Sunday, 1 = Monday, ..., 6 = Saturday
  const diff = day === 0 ? 6 : day - 1; // วันจันทร์ = 1, diff = 0
  date.setDate(date.getDate() - diff);
  return date.toISOString().split("T")[0];
}

/**
 * Get today's date string (UTC+7)
 */
function getTodayString(): string {
  const now = new Date();
  const localTime = new Date(now.getTime() + 420 * 60 * 1000);
  return localTime.toISOString().split("T")[0];
}

export async function checkReferralProgress(deviceId: string): Promise<void> {
  const userDoc = await db.collection("users").doc(deviceId).get();

  if (!userDoc.exists) return;

  const user = userDoc.data()!;
  const referredByDeviceId = user.referredBy || user.referrals?.referredByDeviceId;

  // ถ้าไม่ได้ถูก refer → ไม่ต้องทำอะไร
  if (!referredByDeviceId) return;

  // V3: เช็ค milestones.totalSpent แทน refereeAiUsageCount
  const milestones = user.milestones || {};
  const totalSpent = milestones.totalSpent ?? (user.totalSpent as number | undefined) ?? 0;

  // ต้องใช้ Energy ครบ 10E ก่อน
  if (totalSpent < 10) return;

  // เช็คว่าได้ reward แล้วหรือยัง (1-time only)
  if (user.referralRewardClaimed) return;

  // ✅ ได้ reward! — เฉพาะผู้ชวน (referrer)
  await db.runTransaction(async (transaction) => {
    // Re-read เพื่อป้องกัน race condition
    const userRef = db.collection("users").doc(deviceId);
    const userDoc2 = await transaction.get(userRef);

    if (!userDoc2.exists) return;

    const userData = userDoc2.data()!;
    if (userData.referralRewardClaimed) return; // Double-check

    // 1. อ่านข้อมูล referrer และ challenges
    const referrerRef = db.collection("users").doc(referredByDeviceId);
    const referrerDoc = await transaction.get(referrerRef);

    if (!referrerDoc.exists) return;

    const referrerData = referrerDoc.data()!;
    const today = getTodayString();
    const weekStart = getWeekStartDate(today);
    
    const challenges = referrerData.challenges?.weekly || {};
    const currentWeekStart = challenges.weekStartDate || null;
    
    // Auto-reset if new week
    let referFriends = challenges.referFriends || 0;
    if (currentWeekStart !== weekStart) {
      // New week: reset
      referFriends = 0;
    }

    // Increment referFriends count
    const newReferFriends = referFriends + 1;
    
    // V3.2: ให้ base reward 5E ทันที (ไม่ใช่ quest)
    // Quest reward ต้องกดปุ่ม claim เอง
    const baseReward = REFERRAL_BASE_REWARD; // 5E base only
    const referrerNewBalance = (referrerData.balance || 0) + baseReward;

    // Update referrer
    const updateData: any = {
      balance: referrerNewBalance,
      totalEarned: (referrerData.totalEarned || 0) + baseReward,
      "challenges.weekly.referFriends": newReferFriends,
      "challenges.weekly.weekStartDate": weekStart,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    };

    // Preserve existing challenge data
    if (currentWeekStart === weekStart) {
      // Same week: preserve other challenge fields
      updateData["challenges.weekly.logMeals"] = challenges.logMeals || 0;
      updateData["challenges.weekly.logMealsLastDate"] = challenges.logMealsLastDate || null;
      updateData["challenges.weekly.logMealsFailed"] = challenges.logMealsFailed || false;
      updateData["challenges.weekly.useAi"] = challenges.useAi || 0;
      updateData["challenges.weekly.claimedRewards"] = challenges.claimedRewards || [];
    } else {
      // New week: reset all challenges
      updateData["challenges.weekly.logMeals"] = 0;
      updateData["challenges.weekly.logMealsLastDate"] = null;
      updateData["challenges.weekly.logMealsFailed"] = false;
      updateData["challenges.weekly.useAi"] = 0;
      updateData["challenges.weekly.claimedRewards"] = [];
    }

    transaction.update(referrerRef, updateData);

    // Log transaction (referrer only)
    const txRef = db.collection("transactions").doc();
    transaction.set(txRef, {
      deviceId: referredByDeviceId,
      miroId: referrerData.miroId || "unknown",
      type: "referral_base_reward",
      amount: baseReward,
      balanceAfter: referrerNewBalance,
      description: `Referral: friend spent 10E (+${baseReward}E base, quest reward requires claim)`,
      metadata: {
        friendDeviceId: deviceId,
        referFriendsCount: newReferFriends,
        baseReward: baseReward,
        questBonusAvailable: newReferFriends <= 10,
      },
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // 2. Mark referee as claimed (no reward for referee here)
    transaction.update(userRef, {
      referralRewardClaimed: true,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(
      `🎉 [Referral V3.2] ${userData.miroId} → referrer ${referrerData.miroId}: +${baseReward}E base (${newReferFriends}/week, quest requires claim)`
    );
  });
}

/**
 * HTTP endpoint wrapper for checkReferralProgress
 * For admin/testing purposes only
 */
export const checkReferralProgressEndpoint = onRequest(
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
      const {deviceId} = req.body;

      if (!deviceId) {
        res.status(400).json({error: "Missing deviceId"});
        return;
      }

      await checkReferralProgress(deviceId);

      res.status(200).json({
        success: true,
        message: "Referral progress checked successfully",
      });
    } catch (error: any) {
      console.error("❌ [checkReferralProgressEndpoint] Error:", error);
      res.status(500).json({error: error.message});
    }
  }
);
