/**
 * milestoneV2.ts
 *
 * Milestone Cashback System V3 — 10 ขั้น, Diminishing Rewards
 *
 * ❌ V2 เดิม: 2 milestone (500E → +15, 1000E → +30) — ลบทิ้ง
 * ✅ V3 ใหม่: 10 milestone (10E → 10,000E), cashback ลดลงตามระดับ
 * ✅ V3.2: Manual claim — ไม่ auto-claim แล้ว, user ต้องกดปุ่ม claim เอง
 *
 * กฎสำคัญ:
 * - Reward ต้องกดปุ่ม claim เอง (ไม่ auto-claim)
 * - สามารถรวม reward จากหลาย milestone ได้ในครั้งเดียว
 * - 1 milestone = claim ได้ครั้งเดียวต่อบัญชี (idempotent)
 * - Milestone #1 (10E) → trigger $1 = 200E offer (offersV2.ts)
 * - Milestone #3 (50E) → trigger subscription upsell flag
 */

import {onRequest} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

// ─── Milestone Table (Hardcoded V3) ───
// threshold = totalSpent ต้องถึง, reward = energy ที่ได้
// cashback % ≈ reward/threshold: ลดลงตามระดับ (diminishing returns)
export const MILESTONES = [
  {index: 0, threshold: 10,    reward: 10,  label: "milestone_10",    cashbackPct: 100},
  {index: 1, threshold: 25,    reward: 5,   label: "milestone_25",    cashbackPct: 20},
  {index: 2, threshold: 50,    reward: 7,   label: "milestone_50",    cashbackPct: 14},
  {index: 3, threshold: 100,   reward: 10,  label: "milestone_100",   cashbackPct: 10},
  {index: 4, threshold: 250,   reward: 15,  label: "milestone_250",   cashbackPct: 6},
  {index: 5, threshold: 500,   reward: 20,  label: "milestone_500",   cashbackPct: 4},
  {index: 6, threshold: 1000,  reward: 30,  label: "milestone_1000",  cashbackPct: 3},
  {index: 7, threshold: 2500,  reward: 50,  label: "milestone_2500",  cashbackPct: 2},
  {index: 8, threshold: 5000,  reward: 65,  label: "milestone_5000",  cashbackPct: 1.3},
  {index: 9, threshold: 10000, reward: 100, label: "milestone_10000", cashbackPct: 1},
] as const;

export type MilestoneLabel = typeof MILESTONES[number]["label"];

// ─── Interfaces ───

export interface MilestoneState {
  totalSpent: number;
  claimedMilestones: string[];
  nextMilestoneIndex: number;
}

export interface MilestoneCheckResult {
  milestoneReached: boolean;
  milestoneLabel: string | null;
  reward: number;
  triggerFirstPurchaseOffer: boolean;   // Milestone #1 (10E)
  triggerSubUpsell: boolean;            // Milestone #3 (50E)
  nextMilestone: {threshold: number; reward: number; label: string} | null;
  newTotalSpent: number;
  unclaimedMilestones: string[];  // รายการ milestone ที่ยังไม่ได้ claim
}

// ─── Core Functions ───

/**
 * คำนวณ MilestoneState จาก totalSpent
 * ใช้สำหรับ migration existing users และ init state
 *
 * ⚠️ V3.2: ไม่ auto-claim — claimedMilestones เริ่มเป็น []
 * nextMilestoneIndex = 0 เสมอสำหรับ user ที่ยังไม่เคย claim
 * user ต้องกดปุ่ม claim เอง
 */
export function computeMilestoneState(totalSpent: number): MilestoneState {
  return {totalSpent, claimedMilestones: [], nextMilestoneIndex: 0};
}

/**
 * เช็คและ track milestone progress หลังทุก AI analysis
 *
 * ⚠️ V3.2: ไม่ auto-claim แล้ว — แค่ track progress
 * User ต้องกดปุ่ม claim เอง
 *
 * เรียกใน analyzeFood.ts หลัง deduct energy
 * ใช้ Firestore Transaction เพื่อ atomic update
 */
export async function checkAndProcessMilestone(
  deviceId: string,
  energyDeducted: number
): Promise<MilestoneCheckResult> {
  const userRef = db.collection("users").doc(deviceId);

  return await db.runTransaction(async (transaction) => {
    const userDoc = await transaction.get(userRef);

    if (!userDoc.exists) {
      throw new Error(`User not found: ${deviceId}`);
    }

    const user = userDoc.data()!;

    // อ่าน milestone state (backward compat: รองรับ user เก่าที่ไม่มี field นี้)
    const existingMilestones = user.milestones as MilestoneState | undefined;

    // Migration: ถ้า user เก่าไม่มี milestones field → คำนวณจาก totalSpent เดิม
    const rawTotalSpent = existingMilestones?.totalSpent ??
      (user.totalSpent as number | undefined) ?? 0;
    const existingClaimed = existingMilestones?.claimedMilestones ?? [];
    const existingNextIndex = existingMilestones?.nextMilestoneIndex ??
      computeMilestoneState(rawTotalSpent).nextMilestoneIndex;

    // คำนวณ totalSpent ใหม่หลัง deduct
    const newTotalSpent = rawTotalSpent + energyDeducted;

    // เช็คว่าถึง milestone ถัดไปหรือยัง
    const nextIndex = existingNextIndex;

    // ไม่มี milestone ถัดไปแล้ว (ครบทุก milestone)
    if (nextIndex >= MILESTONES.length) {
      transaction.update(userRef, {
        "milestones.totalSpent": newTotalSpent,
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      });

      return {
        milestoneReached: false,
        milestoneLabel: null,
        reward: 0,
        triggerFirstPurchaseOffer: false,
        triggerSubUpsell: false,
        nextMilestone: null,
        newTotalSpent,
        unclaimedMilestones: [],
      };
    }

    const nextMilestone = MILESTONES[nextIndex];

    // คำนวณว่ามี milestone ที่ถึงแล้วแต่ยังไม่ได้ claim กี่อัน
    const unclaimedMilestones: string[] = [];
    for (let i = nextIndex; i < MILESTONES.length; i++) {
      if (newTotalSpent >= MILESTONES[i].threshold) {
        unclaimedMilestones.push(MILESTONES[i].label);
      } else {
        break;
      }
    }

    if (newTotalSpent < nextMilestone.threshold) {
      // ยังไม่ถึง milestone ถัดไป
      transaction.update(userRef, {
        "milestones.totalSpent": newTotalSpent,
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      });

      return {
        milestoneReached: false,
        milestoneLabel: null,
        reward: 0,
        triggerFirstPurchaseOffer: false,
        triggerSubUpsell: false,
        nextMilestone: {
          threshold: nextMilestone.threshold,
          reward: nextMilestone.reward,
          label: nextMilestone.label,
        },
        newTotalSpent,
        unclaimedMilestones: [],
      };
    }

    // ✅ Milestone reached! แต่ไม่ auto-claim — แค่ track
    // Special triggers
    const triggerFirstPurchaseOffer = nextMilestone.label === "milestone_10" &&
      !existingClaimed.includes("milestone_10");
    const triggerSubUpsell = nextMilestone.label === "milestone_50" &&
      !existingClaimed.includes("milestone_50");

    // อัปเดต totalSpent เท่านั้น (ไม่ claim)
    const updates: Record<string, any> = {
      "milestones.totalSpent": newTotalSpent,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    };

    // Trigger sub upsell flag (1-time)
    if (triggerSubUpsell && !user.subUpsellShown) {
      updates.subUpsellShown = true;
      updates.subUpsellAvailable = true;
    }

    transaction.update(userRef, updates);

    const newNextIndex = existingClaimed.length;
    const afterMilestone = newNextIndex < MILESTONES.length ? MILESTONES[newNextIndex] : null;

    console.log(
      `🏆 [MilestoneV2] ${deviceId}: ${unclaimedMilestones.length} milestone(s) ready to claim (total spent: ${newTotalSpent})`
    );

    return {
      milestoneReached: true,
      milestoneLabel: unclaimedMilestones[0] || null,
      reward: unclaimedMilestones.reduce((sum, label) => {
        const m = MILESTONES.find(x => x.label === label);
        return sum + (m?.reward || 0);
      }, 0),
      triggerFirstPurchaseOffer,
      triggerSubUpsell,
      nextMilestone: afterMilestone
        ? {
            threshold: afterMilestone.threshold,
            reward: afterMilestone.reward,
            label: afterMilestone.label,
          }
        : null,
      newTotalSpent,
      unclaimedMilestones,
    };
  });
}

/**
 * ดึง Milestone progress ปัจจุบันของ user
 * ใช้สำหรับ Quest Bar UI แสดง progress bar
 */
export async function getMilestoneProgress(deviceId: string): Promise<{
  totalSpent: number;
  currentMilestone: typeof MILESTONES[number] | null;
  nextMilestone: typeof MILESTONES[number] | null;
  progressPct: number;
  claimedCount: number;
}> {
  const userDoc = await db.collection("users").doc(deviceId).get();

  if (!userDoc.exists) {
    return {
      totalSpent: 0,
      currentMilestone: null,
      nextMilestone: MILESTONES[0],
      progressPct: 0,
      claimedCount: 0,
    };
  }

  const user = userDoc.data()!;
  const milestones = user.milestones as MilestoneState | undefined;
  const totalSpent = milestones?.totalSpent ?? (user.totalSpent as number | undefined) ?? 0;
  const nextIndex = milestones?.nextMilestoneIndex ?? computeMilestoneState(totalSpent).nextMilestoneIndex;
  const claimedCount = nextIndex;

  const currentMilestone = nextIndex > 0 ? MILESTONES[nextIndex - 1] : null;
  const nextMilestone = nextIndex < MILESTONES.length ? MILESTONES[nextIndex] : null;

  let progressPct = 0;
  if (nextMilestone) {
    const prevThreshold = currentMilestone?.threshold ?? 0;
    const range = nextMilestone.threshold - prevThreshold;
    const progress = totalSpent - prevThreshold;
    progressPct = Math.min(100, Math.floor((progress / range) * 100));
  } else {
    progressPct = 100; // ครบทุก milestone
  }

  return {
    totalSpent,
    currentMilestone: currentMilestone ?? null,
    nextMilestone,
    progressPct,
    claimedCount,
  };
}

/**
 * Claim all available milestone rewards
 * ผู้ใช้กดปุ่ม claim → รวม reward จากทุก milestone ที่ถึงแล้ว
 */
export async function claimMilestoneRewards(deviceId: string): Promise<{
  success: boolean;
  totalReward: number;
  claimedMilestones: string[];
  newBalance: number;
}> {
  const userRef = db.collection("users").doc(deviceId);

  return await db.runTransaction(async (transaction) => {
    const userDoc = await transaction.get(userRef);

    if (!userDoc.exists) {
      throw new Error(`User not found: ${deviceId}`);
    }

    const user = userDoc.data()!;
    const existingMilestones = user.milestones as MilestoneState | undefined;

    const totalSpent = existingMilestones?.totalSpent ??
      (user.totalSpent as number | undefined) ?? 0;
    const existingClaimed = existingMilestones?.claimedMilestones ?? [];
    const existingNextIndex = existingMilestones?.nextMilestoneIndex ??
      computeMilestoneState(totalSpent).nextMilestoneIndex;

    // หา milestone ที่ถึงแล้วแต่ยังไม่ได้ claim
    const unclaimedMilestones: typeof MILESTONES[number][] = [];
    for (let i = existingNextIndex; i < MILESTONES.length; i++) {
      if (totalSpent >= MILESTONES[i].threshold) {
        unclaimedMilestones.push(MILESTONES[i]);
      } else {
        break;
      }
    }

    // ถ้าไม่มีอะไรจะ claim
    if (unclaimedMilestones.length === 0) {
      return {
        success: false,
        totalReward: 0,
        claimedMilestones: [],
        newBalance: user.balance || 0,
      };
    }

    // คำนวณ total reward
    const totalReward = unclaimedMilestones.reduce((sum, m) => sum + m.reward, 0);
    const newBalance = (user.balance || 0) + totalReward;
    const newClaimed = [...existingClaimed, ...unclaimedMilestones.map(m => m.label)];
    const newNextIndex = existingNextIndex + unclaimedMilestones.length;

    // อัปเดต user document
    transaction.update(userRef, {
      balance: newBalance,
      totalEarned: (user.totalEarned || 0) + totalReward,
      "milestones.claimedMilestones": newClaimed,
      "milestones.nextMilestoneIndex": newNextIndex,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Log transaction
    const txRef = db.collection("transactions").doc();
    transaction.set(txRef, {
      deviceId,
      miroId: user.miroId || "unknown",
      type: "milestone_claim",
      amount: totalReward,
      balanceAfter: newBalance,
      description: `Claimed ${unclaimedMilestones.length} milestone(s) → +${totalReward}E`,
      metadata: {
        milestones: unclaimedMilestones.map(m => ({
          label: m.label,
          threshold: m.threshold,
          reward: m.reward,
        })),
        totalSpent,
      },
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(
      `🎁 [MilestoneV2] ${deviceId}: Claimed ${unclaimedMilestones.length} milestone(s) ` +
      `→ +${totalReward}E (balance: ${newBalance})`
    );

    return {
      success: true,
      totalReward,
      claimedMilestones: unclaimedMilestones.map(m => m.label),
      newBalance,
    };
  });
}

/**
 * HTTP endpoint wrapper for claimMilestoneRewards
 */
export const claimMilestoneRewardsEndpoint = onRequest(
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

      const result = await claimMilestoneRewards(deviceId);

      res.status(200).json(result);
    } catch (error: any) {
      console.error("❌ [claimMilestoneRewardsEndpoint] Error:", error);
      res.status(500).json({error: error.message});
    }
  }
);
