/**
 * Firebase Cloud Functions for MIRO Energy System
 *
 * Export all functions here
 */

import {setGlobalOptions} from "firebase-functions";

// Global options for cost control
setGlobalOptions({
  maxInstances: 10,
  region: "us-central1",
});

// ───────────────────────────────────────────────────────────
// EXPORTS
// ───────────────────────────────────────────────────────────

// Energy System API
export {analyzeFood} from "./analyzeFood";
export {syncBalance} from "./syncBalance";
export {verifyPurchase} from "./verifyPurchase";

// Transfer Key API
export {generateTransferKey, redeemTransferKey} from "./transferKey";

// Migration API
export {migrateToUsersCollection} from "./migration";

// User Registration API
export {registerUser} from "./registerUser";

// Streak & Tier API
export {claimDailyCheckIn, processCheckIn} from "./energy/dailyCheckIn";

// Challenge API
export {completeChallenge} from "./energy/challenge";

// Milestone API
export {claimMilestone} from "./energy/milestone";

// Cron Jobs
export {resetWeeklyChallenges} from "./cron/resetWeeklyChallenges";
export {calculateMetrics} from "./cron/calculateMetrics";
export {sendStreakReminders} from "./cron/sendNotifications";
export {expireReferrals} from "./cron/expireReferrals";
export {resetReferralQuota} from "./cron/resetReferralQuota";

// Admin API
export {
  searchUsers,
  getUserDetail,
  topupEnergy,
  resetStreak,
  banUser,
} from "./admin/users";
export {getMetrics} from "./admin/metrics";
export {getConfig, updateConfig} from "./admin/config";
export {getFraudAlerts, reviewFraudAlert} from "./admin/fraud";

// Referral API
export {submitReferralCode} from "./referral/submitReferralCode";

// Subscription API
export {verifySubscription} from "./subscription/verifySubscription";
export {handleRTDN} from "./subscription/handleRTDN";
