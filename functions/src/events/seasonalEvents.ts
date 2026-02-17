/**
 * Seasonal Events Framework
 *
 * Support for time-limited events (Songkran, New Year, etc.)
 */

import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

export interface EventConfig {
  eventId: string;
  name: string;
  startDate: string; // "YYYY-MM-DD"
  endDate: string; // "YYYY-MM-DD"
  rewards: {
    [key: string]: any;
  };
  challenges?: {
    [key: string]: {
      target: number;
      reward: number;
    };
  };
}

/**
 * Get active seasonal event
 */
export async function getActiveEvent(): Promise<EventConfig | null> {
  try {
    const eventsDoc = await db.collection("config").doc("seasonal_events").get();
    if (!eventsDoc.exists) {
      return null;
    }

    const events = eventsDoc.data()?.events || [];
    const today = new Date().toISOString().split("T")[0];

    // Find active event
    const activeEvent = events.find((event: EventConfig) => {
      return event.startDate <= today && event.endDate >= today;
    });

    return activeEvent || null;
  } catch (error) {
    console.error("[Seasonal Events] Error:", error);
    return null;
  }
}

/**
 * Check if user completed event challenge
 */
export async function checkEventChallenge(
  deviceId: string,
  eventId: string,
  challengeId: string
): Promise<boolean> {
  const userDoc = await db.collection("users").doc(deviceId).get();
  if (!userDoc.exists) return false;

  const user = userDoc.data()!;
  const eventProgress = user.eventProgress || {};
  const eventData = eventProgress[eventId] || {};
  const completed = eventData.completedChallenges || [];

  return completed.includes(challengeId);
}

/**
 * Complete event challenge
 */
export async function completeEventChallenge(
  deviceId: string,
  eventId: string,
  challengeId: string,
  reward: number
): Promise<void> {
  await db.runTransaction(async (transaction) => {
    const userRef = db.collection("users").doc(deviceId);
    const userDoc = await transaction.get(userRef);

    if (!userDoc.exists) return;

    const user = userDoc.data()!;
    const eventProgress = user.eventProgress || {};
    const eventData = eventProgress[eventId] || {};
    const completed = eventData.completedChallenges || [];

    // Check if already completed
    if (completed.includes(challengeId)) return;

    const newBalance = (user.balance || 0) + reward;

    transaction.update(userRef, {
      balance: newBalance,
      totalEarned: (user.totalEarned || 0) + reward,
      [`eventProgress.${eventId}.completedChallenges`]: [
        ...completed,
        challengeId,
      ],
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Log transaction
    const txRef = db.collection("transactions").doc();
    transaction.set(txRef, {
      deviceId,
      miroId: user.miroId || "unknown",
      type: "event_reward",
      amount: reward,
      balanceAfter: newBalance,
      description: `Event challenge completed: ${eventId}/${challengeId}`,
      metadata: {
        eventId,
        challengeId,
      },
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });
}
