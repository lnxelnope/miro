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

// Recovery Key API (cross-device account restoration with data sync)
export {registerRecoveryKey, redeemRecoveryKey} from "./recoveryKey";

// Migration API
export {migrateToUsersCollection} from "./migration";

// User Registration API
export {registerUser} from "./registerUser";

// Streak & Tier API
export {claimDailyCheckIn, processCheckIn} from "./energy/dailyCheckIn";
export {claimDailyEnergy} from "./energy/claimDailyEnergy";

// Challenge API
export {completeChallenge} from "./energy/challenge";

// Milestone API (V1 removed — replaced by milestoneV2 auto-claim in analyzeFood)
// export {claimMilestone} from "./energy/milestone"; // SECURITY: ลบออกป้องกัน double-dip กับ V2

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
export {checkReferralProgressEndpoint} from "./referral/checkReferralProgress";

// Subscription API
export {verifySubscription} from "./subscription/verifySubscription";
export {handleRTDN} from "./subscription/handleRTDN";
export {winbackScheduler} from "./subscription/winbackScheduler";

// ─── V3: Energy Marketing ───────────────────────────────────

// Milestone V3 (10 steps)
export {getMilestoneProgress, claimMilestoneRewardsEndpoint} from "./energy/milestoneV2";

// Offers V3
export {getActiveOffersEndpoint, dismissOfferEndpoint, claimFreeEnergyEndpoint} from "./energy/offersV2";

// Rewarded Ads SSV
export {verifyRewardedAd, claimAdReward, getAdStatus} from "./energy/rewardedAd";

// Push Notification Triggers
export {checkOfferExpiry, streakReminder} from "./notifications/pushTriggers";

// ─── Data Mining ────────────────────────────────────────────
export {computeDataMiningReports, getDataMiningReport, triggerDataMining, exportDataset} from "./admin/dataMining";
