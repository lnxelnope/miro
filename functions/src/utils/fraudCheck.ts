/**
 * fraudCheck.ts
 *
 * Utility functions สำหรับตรวจสอบ fraud patterns
 */

import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

export interface FraudCheckResult {
  isSuspicious: boolean;
  reason?: string;
  severity: "low" | "medium" | "high";
}

/**
 * ตรวจสอบ multiple registrations จาก IP เดียวกัน
 */
export async function checkMultipleRegistrations(
  deviceId: string,
  ipAddress?: string
): Promise<FraudCheckResult> {
  if (!ipAddress) {
    return {isSuspicious: false, severity: "low"};
  }

  // นับจำนวน registrations จาก IP เดียวกันใน 24 ชั่วโมงที่ผ่านมา
  const oneDayAgo = admin.firestore.Timestamp.fromDate(
    new Date(Date.now() - 24 * 60 * 60 * 1000)
  );

  const registrations = await db
    .collection("users")
    .where("registrationIp", "==", ipAddress)
    .where("createdAt", ">=", oneDayAgo)
    .get();

  const count = registrations.size;

  if (count >= 3) {
    return {
      isSuspicious: true,
      reason: `Multiple registrations from same IP: ${count} in 24h`,
      severity: count >= 5 ? "high" : "medium",
    };
  }

  return {isSuspicious: false, severity: "low"};
}

/**
 * ตรวจสอบ abnormal energy gain
 */
export async function checkAbnormalEnergyGain(
  deviceId: string
): Promise<FraudCheckResult> {
  const oneDayAgo = admin.firestore.Timestamp.fromDate(
    new Date(Date.now() - 24 * 60 * 60 * 1000)
  );

  // นับ energy ที่ได้จาก rewards ใน 24 ชั่วโมง
  const rewardTx = await db
    .collection("transactions")
    .where("deviceId", "==", deviceId)
    .where("type", "in", [
      "streak_bonus",
      "challenge",
      "milestone",
      "random_bonus",
      "welcome_gift",
    ])
    .where("createdAt", ">=", oneDayAgo)
    .get();

  let totalEarned = 0;
  rewardTx.forEach((doc) => {
    totalEarned += doc.data().amount || 0;
  });

  if (totalEarned > 200) {
    return {
      isSuspicious: true,
      reason: `Abnormal energy gain: ${totalEarned} in 24h`,
      severity: totalEarned > 500 ? "high" : "medium",
    };
  }

  return {isSuspicious: false, severity: "low"};
}

/**
 * ตรวจสอบ time manipulation
 */
export function checkTimeManipulation(
  clientTimestamp: number,
  serverTimestamp: number
): FraudCheckResult {
  const diffMinutes = Math.abs(
    (clientTimestamp - serverTimestamp) / (1000 * 60)
  );

  if (diffMinutes > 10) {
    return {
      isSuspicious: true,
      reason: `Time manipulation detected: ${diffMinutes.toFixed(1)} min difference`,
      severity: diffMinutes > 60 ? "high" : "medium",
    };
  }

  return {isSuspicious: false, severity: "low"};
}

/**
 * ตรวจสอบ rapid requests
 */
export async function checkRapidRequests(
  deviceId: string
): Promise<FraudCheckResult> {
  const oneHourAgo = admin.firestore.Timestamp.fromDate(
    new Date(Date.now() - 60 * 60 * 1000)
  );

  const requests = await db
    .collection("request_logs")
    .where("deviceId", "==", deviceId)
    .where("timestamp", ">=", oneHourAgo)
    .get();

  const count = requests.size;

  if (count > 100) {
    return {
      isSuspicious: true,
      reason: `Rapid requests: ${count} in 1 hour`,
      severity: count > 200 ? "high" : "medium",
    };
  }

  return {isSuspicious: false, severity: "low"};
}

/**
 * สร้าง fraud alert
 */
export async function createFraudAlert(
  deviceId: string,
  action: string,
  reason: string,
  severity: "low" | "medium" | "high",
  metadata?: Record<string, any>
): Promise<void> {
  const alertRef = db.collection("fraud_alerts").doc();
  await alertRef.set({
    deviceId,
    action,
    reason,
    severity,
    metadata: metadata || {},
    status: "pending", // pending, reviewed, dismissed, confirmed
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  console.log(
    `🚨 [Fraud] Alert created: ${deviceId} - ${reason} (${severity})`
  );
}

/**
 * Comprehensive fraud check
 */
export async function performFraudCheck(
  deviceId: string,
  action: string,
  metadata?: {
    ipAddress?: string;
    clientTimestamp?: number;
    energyGained?: number;
  }
): Promise<FraudCheckResult[]> {
  const results: FraudCheckResult[] = [];

  // Check multiple registrations
  if (metadata?.ipAddress) {
    const regCheck = await checkMultipleRegistrations(
      deviceId,
      metadata.ipAddress
    );
    if (regCheck.isSuspicious) {
      results.push(regCheck);
      await createFraudAlert(
        deviceId,
        action,
        regCheck.reason!,
        regCheck.severity,
        {ipAddress: metadata.ipAddress}
      );
    }
  }

  // Check abnormal energy gain
  const energyCheck = await checkAbnormalEnergyGain(deviceId);
  if (energyCheck.isSuspicious) {
    results.push(energyCheck);
    await createFraudAlert(
      deviceId,
      action,
      energyCheck.reason!,
      energyCheck.severity
    );
  }

  // Check time manipulation
  if (metadata?.clientTimestamp) {
    const timeCheck = checkTimeManipulation(
      metadata.clientTimestamp,
      Date.now()
    );
    if (timeCheck.isSuspicious) {
      results.push(timeCheck);
      await createFraudAlert(
        deviceId,
        action,
        timeCheck.reason!,
        timeCheck.severity
      );
    }
  }

  // Check rapid requests
  const rapidCheck = await checkRapidRequests(deviceId);
  if (rapidCheck.isSuspicious) {
    results.push(rapidCheck);
    await createFraudAlert(
      deviceId,
      action,
      rapidCheck.reason!,
      rapidCheck.severity
    );
  }

  return results;
}
