/**
 * calculateMetrics
 *
 * Schedule: ทุกวัน 03:00 UTC+7 (20:00 UTC)
 * สิ่งที่ทำ: คำนวณ daily metrics แล้วเก็บใน metrics/{date}
 */

import {onSchedule} from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

export const calculateMetrics = onSchedule(
  {
    schedule: "0 20 * * *", // 03:00 UTC+7 = 20:00 UTC
    timeZone: "UTC",
    timeoutSeconds: 540,
    memory: "1GiB",
  },
  async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    const dateStr = yesterday.toISOString().split("T")[0];

    console.log(`📊 [Metrics] Calculating for ${dateStr}...`);

    const usersSnapshot = await db.collection("users").get();
    const totalUsers = usersSnapshot.size;

    let dau = 0;
    let totalRevenue = 0;
    let purchaseCount = 0;
    const streakDistribution: Record<string, number> = {
      "0": 0,
      "1-6": 0,
      "7-13": 0,
      "14-29": 0,
      "30-59": 0,
      "60+": 0,
    };
    const tierDistribution: Record<string, number> = {
      none: 0,
      bronze: 0,
      silver: 0,
      gold: 0,
      diamond: 0,
    };
    let challengeLogMealsCompleted = 0;
    let challengeUseAiCompleted = 0;
    let totalStreak = 0;

    for (const doc of usersSnapshot.docs) {
      const user = doc.data();

      // DAU: checked in yesterday
      if (user.lastCheckInDate === dateStr) dau++;

      // Streak distribution
      const streak = user.currentStreak || 0;
      totalStreak += streak;
      if (streak === 0) streakDistribution["0"]++;
      else if (streak <= 6) streakDistribution["1-6"]++;
      else if (streak <= 13) streakDistribution["7-13"]++;
      else if (streak <= 29) streakDistribution["14-29"]++;
      else if (streak <= 59) streakDistribution["30-59"]++;
      else streakDistribution["60+"]++;

      // Tier distribution
      const tier = user.tier || "none";
      tierDistribution[tier] = (tierDistribution[tier] || 0) + 1;

      // Challenge completion
      const claimed = user.challenges?.weekly?.claimedRewards || [];
      if (claimed.includes("logMeals")) challengeLogMealsCompleted++;
      if (claimed.includes("useAi")) challengeUseAiCompleted++;
    }

    // Revenue from transactions
    const txStart = admin.firestore.Timestamp.fromDate(new Date(dateStr));
    const txEnd = admin.firestore.Timestamp.fromDate(
      new Date(new Date(dateStr).getTime() + 86400000)
    );

    const purchaseTx = await db
      .collection("transactions")
      .where("type", "==", "purchase")
      .where("createdAt", ">=", txStart)
      .where("createdAt", "<", txEnd)
      .get();

    purchaseCount = purchaseTx.size;
    purchaseTx.forEach((doc) => {
      const data = doc.data();
      // Revenue = total energy purchased (not amount in transaction)
      const energyAmount = data.metadata?.totalEnergy || data.amount || 0;
      totalRevenue += energyAmount;
    });

    const avgStreak = dau > 0 ? totalStreak / dau : 0;

    // Save metrics
    await db.collection("metrics").doc(dateStr).set({
      date: dateStr,
      totalUsers,
      dau,
      dauRate: totalUsers > 0 ? (dau / totalUsers) * 100 : 0,
      purchaseCount,
      conversionRate: dau > 0 ? (purchaseCount / dau) * 100 : 0,
      totalRevenue,
      avgStreak,
      streakDistribution,
      tierDistribution,
      challengeCompletion: {
        logMeals: challengeLogMealsCompleted,
        useAi: challengeUseAiCompleted,
        logMealsRate:
          totalUsers > 0 ?
            (challengeLogMealsCompleted / totalUsers) * 100 :
            0,
        useAiRate:
          totalUsers > 0 ? (challengeUseAiCompleted / totalUsers) * 100 : 0,
      },
      calculatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(
      `✅ [Metrics] Done: DAU=${dau}, Purchases=${purchaseCount}, Revenue=${totalRevenue}`
    );
  }
);
