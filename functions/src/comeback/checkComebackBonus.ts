/**
 * checkComebackBonus
 *
 * เรียกเมื่อ: User check-in หรือใช้ AI หลังจากหายไปหลายวัน
 * สิ่งที่ทำ: คำนวณ comeback bonus ตามจำนวนวันที่หายไป
 */

import * as admin from "firebase-admin";
import {checkComebackFraud} from "../utils/advancedFraudCheck";
import {getABTestConfig} from "../abTesting/getABGroup";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

// Phase 4: Support A/B testing for comeback rewards
const DEFAULT_COMEBACK_CONFIG = {
  "3-7": {energy: 3, streakFreeze: false},
  "7-14": {energy: 5, streakFreeze: false},
  "14-30": {energy: 10, streakFreeze: true},
  "30+": {energy: 15, streakFreeze: false, startAtBronze: true},
};

/**
 * คำนวณ comeback bonus
 */
export async function checkComebackBonus(
  deviceId: string,
  lastCheckInDate: string | null,
  currentStreak: number
): Promise<{
  bonus: number;
  streakFreeze: boolean;
  startAtBronze: boolean;
  daysAway: number;
}> {
  if (!lastCheckInDate) {
    return {bonus: 0, streakFreeze: false, startAtBronze: false, daysAway: 0};
  }

  const lastDate = new Date(lastCheckInDate);
  const today = new Date();
  const daysAway = Math.floor(
    (today.getTime() - lastDate.getTime()) / (1000 * 60 * 60 * 24)
  );

  // ถ้าน้อยกว่า 3 วัน → ไม่มี comeback bonus
  if (daysAway < 3) {
    return {bonus: 0, streakFreeze: false, startAtBronze: false, daysAway};
  }

  // Phase 4: Get comeback rewards from A/B test if available
  let baseConfig: { energy: number; streakFreeze: boolean; startAtBronze?: boolean };

  if (daysAway >= 30) {
    baseConfig = DEFAULT_COMEBACK_CONFIG["30+"];
  } else if (daysAway >= 14) {
    baseConfig = DEFAULT_COMEBACK_CONFIG["14-30"];
  } else if (daysAway >= 7) {
    baseConfig = DEFAULT_COMEBACK_CONFIG["7-14"];
  } else {
    baseConfig = DEFAULT_COMEBACK_CONFIG["3-7"];
  }

  // Get A/B test config for this tier
  const abEnergy = await getABTestConfig(
    deviceId,
    `comeback.${daysAway >= 30 ? "30+" : daysAway >= 14 ? "14-30" : daysAway >= 7 ? "7-14" : "3-7"}.energy`,
    baseConfig.energy
  );

  const config = {
    ...baseConfig,
    energy: abEnergy,
  };

  return {
    bonus: config.energy,
    streakFreeze: config.streakFreeze || false,
    startAtBronze: config.startAtBronze || false,
    daysAway,
  };
}

/**
 * Apply comeback bonus
 */
export async function applyComebackBonus(
  deviceId: string,
  comebackData: {
    bonus: number;
    streakFreeze: boolean;
    startAtBronze: boolean;
    daysAway: number;
  }
): Promise<{ success: boolean; error?: string }> {
  if (comebackData.bonus === 0) {
    return {success: true};
  }

  // Advanced fraud check
  const fraudCheck = await checkComebackFraud(deviceId, comebackData.daysAway);
  if (fraudCheck.isSuspicious) {
    console.log(`🚨 [Comeback] Fraud detected: ${fraudCheck.reason}`);
    return {success: false, error: fraudCheck.reason};
  }

  await db.runTransaction(async (transaction) => {
    const userRef = db.collection("users").doc(deviceId);
    const userDoc = await transaction.get(userRef);

    if (!userDoc.exists) return;

    const user = userDoc.data()!;
    const currentBalance = user.balance || 0;
    const newBalance = currentBalance + comebackData.bonus;

    const updates: Record<string, any> = {
      balance: newBalance,
      totalEarned: (user.totalEarned || 0) + comebackData.bonus,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    };

    // Streak freeze: ไม่ reset streak
    if (comebackData.streakFreeze && user.currentStreak > 0) {
      // Keep current streak
    }

    // Start at Bronze: ถ้า streak = 0 → set เป็น Bronze tier
    if (comebackData.startAtBronze && user.currentStreak === 0) {
      updates.tier = "bronze";
      updates.currentStreak = 7; // Start at Bronze = 7 days streak
      updates["tierUnlockedAt.bronze"] = admin.firestore.FieldValue.serverTimestamp();
    }

    transaction.update(userRef, updates);

    // Log transaction
    const txRef = db.collection("transactions").doc();
    transaction.set(txRef, {
      deviceId,
      miroId: user.miroId || "unknown",
      type: "comeback_bonus",
      amount: comebackData.bonus,
      balanceAfter: newBalance,
      description: `Welcome back! +${comebackData.bonus} Energy (${comebackData.daysAway} days away)`,
      metadata: {
        daysAway: comebackData.daysAway,
        streakFreeze: comebackData.streakFreeze,
        startAtBronze: comebackData.startAtBronze,
      },
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  return {success: true};
}
