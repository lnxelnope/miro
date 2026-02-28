/**
 * seasonalQuest.ts
 *
 * Helpers for Seasonal Quest system
 */

import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

/**
 * Get today string in UTC+7
 */
function getTodayString(): string {
  const now = new Date();
  const localTime = new Date(now.getTime() + 420 * 60 * 1000);
  return localTime.toISOString().split("T")[0];
}

/**
 * Fetch active seasonal quests and merge with user progress
 *
 * Returns array of quests with user's claim status
 */
export async function getActiveSeasonalQuests(
  deviceId: string
): Promise<any[]> {
  const today = getTodayString();

  // Query active quests where today is within date range
  const snapshot = await db
    .collection("seasonal_quests")
    .where("status", "==", "active")
    .get();

  // Filter by date range (Firestore can't do compound range queries on different fields)
  const activeQuests = snapshot.docs.filter((doc) => {
    const data = doc.data();
    return data.startDate <= today && data.endDate >= today;
  });

  if (activeQuests.length === 0) return [];

  // Get user's seasonal progress
  const userDoc = await db.collection("users").doc(deviceId).get();
  const seasonalProgress = userDoc.data()?.seasonalProgress || {};

  // Merge quest data with user progress
  return activeQuests.map((doc) => {
    const quest = doc.data();
    const progress = seasonalProgress[doc.id] || {};

    return {
      id: doc.id,
      title: quest.title,
      description: quest.description || "",
      icon: quest.icon || "🎁",
      startDate: quest.startDate,
      endDate: quest.endDate,
      durationDays: quest.durationDays || 0,
      claimType: quest.claimType,
      rewardPerClaim: quest.rewardPerClaim,
      // User progress
      claimedDays: progress.claimedDays || [],
      claimed: progress.claimed || false,
    };
  });
}
