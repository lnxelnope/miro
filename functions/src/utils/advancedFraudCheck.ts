/**
 * Advanced Fraud Detection
 *
 * Phase 4: Enhanced fraud detection patterns
 */

import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

/**
 * Check for referral fraud patterns
 */
export async function checkReferralFraud(
  referrerDeviceId: string,
  refereeDeviceId: string,
  referrerIp: string,
  refereeIp: string
): Promise<{ isSuspicious: boolean; reason?: string }> {
  // 1. Same IP check
  if (referrerIp === refereeIp && referrerIp !== "unknown") {
    return {
      isSuspicious: true,
      reason: "Referrer and referee have same IP address",
    };
  }

  // 2. Check if referrer has too many referrals from same IP
  const oneDayAgo = admin.firestore.Timestamp.fromDate(
    new Date(Date.now() - 24 * 60 * 60 * 1000)
  );

  const recentReferrals = await db
    .collection("referral_records")
    .where("referrerId", "==", referrerDeviceId)
    .where("createdAt", ">=", oneDayAgo)
    .get();

  const sameIpCount = recentReferrals.docs.filter(
    (doc) => doc.data().ip?.referee === refereeIp
  ).length;

  if (sameIpCount >= 2) {
    return {
      isSuspicious: true,
      reason: `Referrer has ${sameIpCount} referrals from same IP in 24h`,
    };
  }

  // 3. Check if referee was recently referred by someone else
  const refereeDoc = await db.collection("users").doc(refereeDeviceId).get();
  if (refereeDoc.exists) {
    const referee = refereeDoc.data()!;
    const createdAt = referee.createdAt?.toDate();
    if (createdAt && Date.now() - createdAt.getTime() < 60 * 60 * 1000) {
      // Created within 1 hour → might be fake account
      return {
        isSuspicious: true,
        reason: "Referee account created very recently",
      };
    }
  }

  return {isSuspicious: false};
}

/**
 * Check for comeback bonus abuse
 */
export async function checkComebackFraud(
  deviceId: string,
  daysAway: number
): Promise<{ isSuspicious: boolean; reason?: string }> {
  // Check if user got comeback bonus recently
  const sixtyDaysAgo = admin.firestore.Timestamp.fromDate(
    new Date(Date.now() - 60 * 24 * 60 * 60 * 1000)
  );

  const recentComebacks = await db
    .collection("transactions")
    .where("deviceId", "==", deviceId)
    .where("type", "==", "comeback_bonus")
    .where("createdAt", ">=", sixtyDaysAgo)
    .get();

  if (recentComebacks.size > 0) {
    return {
      isSuspicious: true,
      reason: "User already received comeback bonus within 60 days",
    };
  }

  // Check for suspicious pattern: multiple accounts from same IP getting comeback
  const userDoc = await db.collection("users").doc(deviceId).get();
  if (userDoc.exists) {
    const user = userDoc.data()!;
    const registrationIp = user.registrationIp;

    if (registrationIp && registrationIp !== "unknown") {
      const sameIpComebacks = await db
        .collection("transactions")
        .where("metadata.ip", "==", registrationIp)
        .where("type", "==", "comeback_bonus")
        .where("createdAt", ">=", sixtyDaysAgo)
        .get();

      if (sameIpComebacks.size >= 3) {
        return {
          isSuspicious: true,
          reason: `Multiple accounts from same IP got comeback bonus: ${sameIpComebacks.size}`,
        };
      }
    }
  }

  return {isSuspicious: false};
}

/**
 * Check for challenge completion fraud
 */
export async function checkChallengeFraud(
  deviceId: string
): Promise<{ isSuspicious: boolean; reason?: string }> {
  const oneDayAgo = admin.firestore.Timestamp.fromDate(
    new Date(Date.now() - 24 * 60 * 60 * 1000)
  );

  // Check if user completed multiple challenges in very short time
  const recentCompletions = await db
    .collection("transactions")
    .where("deviceId", "==", deviceId)
    .where("type", "==", "challenge")
    .where("createdAt", ">=", oneDayAgo)
    .get();

  if (recentCompletions.size > 2) {
    return {
      isSuspicious: true,
      reason: `User completed ${recentCompletions.size} challenges in 24h`,
    };
  }

  return {isSuspicious: false};
}

/**
 * Comprehensive advanced fraud check
 */
export async function performAdvancedFraudCheck(
  deviceId: string,
  action: string,
  metadata?: Record<string, any>
): Promise<{ isSuspicious: boolean; reasons: string[] }> {
  const reasons: string[] = [];

  // Referral fraud check
  if (action === "referral" && metadata?.referrerDeviceId && metadata?.refereeIp) {
    const referralCheck = await checkReferralFraud(
      metadata.referrerDeviceId,
      deviceId,
      metadata.referrerIp || "unknown",
      metadata.refereeIp
    );
    if (referralCheck.isSuspicious) {
      reasons.push(referralCheck.reason!);
    }
  }

  // Comeback fraud check
  if (action === "comeback" && metadata?.daysAway) {
    const comebackCheck = await checkComebackFraud(deviceId, metadata.daysAway);
    if (comebackCheck.isSuspicious) {
      reasons.push(comebackCheck.reason!);
    }
  }

  // Challenge fraud check
  if (action === "challenge") {
    const challengeCheck = await checkChallengeFraud(deviceId);
    if (challengeCheck.isSuspicious) {
      reasons.push(challengeCheck.reason!);
    }
  }

  return {
    isSuspicious: reasons.length > 0,
    reasons,
  };
}
