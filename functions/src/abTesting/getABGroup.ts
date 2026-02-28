/**
 * A/B Testing Framework
 *
 * Deterministic group assignment: same user always gets same group
 */

import * as crypto from "crypto";
import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

/**
 * Assign user to A/B group deterministically
 *
 * @param deviceId User device ID
 * @param testId Test ID
 * @param allocation Allocation ratio (0.5 = 50/50 split)
 * @return 'A' or 'B'
 */
export function getABGroup(
  deviceId: string,
  testId: string,
  allocation = 0.5
): "A" | "B" {
  // Deterministic hash: same user + same test = same group
  const hash = crypto
    .createHash("md5")
    .update(`${deviceId}:${testId}`)
    .digest("hex");

  const value = parseInt(hash.substring(0, 8), 16) / 0xffffffff;
  return value < allocation ? "A" : "B";
}

/**
 * Get A/B test config value for user
 */
export async function getABTestConfig(
  deviceId: string,
  configKey: string,
  defaultValue: any
): Promise<any> {
  try {
    // Get active A/B tests
    const abTestsDoc = await db.collection("config").doc("ab_tests").get();
    if (!abTestsDoc.exists) {
      return defaultValue;
    }

    const abTests = abTestsDoc.data()?.tests || [];

    // Find active test for this config key
    const activeTest = abTests.find(
      (test: any) =>
        test.status === "active" &&
        test.configKey === configKey &&
        (!test.endDate || new Date(test.endDate) > new Date())
    );

    if (!activeTest) {
      return defaultValue;
    }

    // Get user's group (deterministic)
    const group = getABGroup(deviceId, activeTest.testId, activeTest.allocation || 0.5);

    // Return config value for user's group
    return activeTest.groups[group]?.config?.[configKey] || defaultValue;
  } catch (error) {
    console.error("[AB Testing] Error:", error);
    return defaultValue;
  }
}

/**
 * Record A/B test event for analytics
 */
export async function recordABTestEvent(
  deviceId: string,
  testId: string,
  event: string,
  value?: any
): Promise<void> {
  try {
    const group = getABGroup(deviceId, testId);

    await db.collection("ab_test_events").add({
      deviceId,
      testId,
      group,
      event,
      value,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
  } catch (error) {
    console.error("[AB Testing] Failed to record event:", error);
  }
}
