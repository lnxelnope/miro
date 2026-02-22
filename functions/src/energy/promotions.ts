/**
 * promotions.ts
 *
 * Promotion Bonus System (server-side, no IAP changes needed)
 *
 * 3 promotion types:
 * 1. Welcome Offer    — first 10 energy spent → +50 free + 40% bonus (24h, 1-time)
 * 2. Tier Upgrade     — each tier up → energy reward + 20% bonus (24h, 1-time per tier)
 * 3. Welcome Back     — ex-Diamond fell to Starter/Bronze → 40% bonus (24h, 1-time)
 *
 * All 1-time only. Stored in Firestore user doc under `promotions` field.
 *
 * verifyPurchase uses: effectiveBonus = max(tierBonusRate, promotionBonusRate)
 */

import * as admin from "firebase-admin";

const db = admin.firestore();

// ─── Configuration ───
const PROMO_DURATION_MS = 24 * 60 * 60 * 1000; // 24 hours

// Welcome Offer เดิม (ให้ +50E ฟรี) ถูกเปลี่ยนเป็น $1 = 200E deal แทน
// checkWelcomeOfferPromotion ยังคงมีไว้เพื่อ trigger $1 deal flag เท่านั้น (ไม่ให้ energy ฟรี)
const WELCOME_OFFER_THRESHOLD = 10; // total energy spent to trigger $1 deal

const TIER_UPGRADE_BONUS_RATE = 0.20; // 20% bonus หลัง tier upgrade

// ✅ V3: อัปเดต Tier Upgrade Rewards ตาม spec ใหม่
const TIER_UPGRADE_REWARDS: Record<string, number> = {
  bronze: 5,
  silver: 10,
  gold: 15,
  diamond: 25,
};

const WELCOME_BACK_BONUS_RATE = 0.40; // 40%

// ─── Interfaces ───
export interface PromotionResult {
  activated: boolean;
  type: string;
  bonusRate: number;
  freeEnergy: number;
  expiresAt?: Date;
  tierRewardEnergy?: number;
}

/**
 * Check Milestone #1 (10E spent) → trigger $1 = 200E Starter Deal offer flag.
 * ❌ ไม่ให้ energy ฟรีอีกต่อไป (ลบ +50E Welcome Offer ออกแล้ว)
 * ✅ แค่ set flag ให้ Frontend แสดง $1 deal (4 ชั่วโมง)
 *
 * Called after each energy deduction in analyzeFood.
 */
export async function checkWelcomeOfferPromotion(
  deviceId: string,
  totalSpent: number
): Promise<PromotionResult | null> {
  if (totalSpent < WELCOME_OFFER_THRESHOLD) return null;

  const userRef = db.collection("users").doc(deviceId);
  const userDoc = await userRef.get();
  if (!userDoc.exists) return null;

  const user = userDoc.data()!;
  const offers = user.offers || {};

  // 1-time only — ถ้า claim แล้วไม่ trigger ซ้ำ
  if (offers.firstPurchaseClaimed || offers.firstPurchaseAvailable) return null;

  const expiresAt = new Date(Date.now() + 4 * 60 * 60 * 1000); // 4 hours

  await userRef.update({
    "offers.firstPurchaseAvailable": true,
    "offers.firstPurchaseExpiry": admin.firestore.Timestamp.fromDate(expiresAt),
    "offers.firstPurchaseClaimed": false,
  });

  console.log(
    `💰 [Promotion] $1 Starter Deal triggered for ${deviceId}: ` +
    `available for 4 hours (expires ${expiresAt.toISOString()})`
  );

  return {
    activated: true,
    type: "first_purchase_offer",
    bonusRate: 0,
    freeEnergy: 0,
    expiresAt,
  };
}

/**
 * Activate Tier Upgrade promotion — energy reward + 20% bonus.
 * Called from dailyCheckIn when tier upgrades.
 *
 * Returns the energy reward amount (to be added to balance in the same transaction).
 */
export function getTierUpgradeReward(tier: string): number {
  return TIER_UPGRADE_REWARDS[tier] || 0;
}

/**
 * Activate tier upgrade promotion (20% bonus, 24h).
 * Called from dailyCheckIn AFTER the transaction completes.
 */
export async function activateTierUpgradePromotion(
  deviceId: string,
  tier: string
): Promise<PromotionResult | null> {
  const userRef = db.collection("users").doc(deviceId);
  const userDoc = await userRef.get();
  if (!userDoc.exists) return null;

  const user = userDoc.data()!;
  const promotions = user.promotions || {};
  const tierPromos = promotions.tierPromoClaimed || {};

  // 1-time per tier
  if (tierPromos[tier]) return null;

  // Don't downgrade an active better promotion
  const currentRate = user.promotionBonusRate || 0;
  const currentExpires = user.promotionExpiresAt?.toDate?.() || new Date(0);
  const isCurrentActive = currentExpires > new Date() && currentRate > TIER_UPGRADE_BONUS_RATE;

  const expiresAt = new Date(Date.now() + PROMO_DURATION_MS);
  const tierReward = TIER_UPGRADE_REWARDS[tier] || 0;

  const updates: Record<string, any> = {
    [`promotions.tierPromoClaimed.${tier}`]: true,
    [`promotions.tierPromoAt.${tier}`]: admin.firestore.FieldValue.serverTimestamp(),
  };

  // Only set promotion bonus if no better active promotion
  if (!isCurrentActive) {
    updates.promotionBonusRate = TIER_UPGRADE_BONUS_RATE;
    updates.promotionExpiresAt = admin.firestore.Timestamp.fromDate(expiresAt);
    updates.promotionType = `tier_upgrade_${tier}`;
  }

  await userRef.update(updates);

  console.log(
    `🎊 [Promotion] Tier upgrade ${tier} for ${deviceId}: ` +
    `+${tierReward} energy reward + ${TIER_UPGRADE_BONUS_RATE * 100}% bonus (24h)`
  );

  return {
    activated: true,
    type: `tier_upgrade_${tier}`,
    bonusRate: TIER_UPGRADE_BONUS_RATE,
    freeEnergy: 0,
    expiresAt: isCurrentActive ? currentExpires : expiresAt,
    tierRewardEnergy: tierReward,
  };
}

/**
 * Activate Welcome Back promotion for ex-Diamond users who fell.
 * Called from dailyCheckIn when demotion triggers welcome back.
 */
export async function activateWelcomeBackPromotion(
  deviceId: string
): Promise<PromotionResult | null> {
  const userRef = db.collection("users").doc(deviceId);
  const userDoc = await userRef.get();
  if (!userDoc.exists) return null;

  const user = userDoc.data()!;
  const promotions = user.promotions || {};

  // 1-time only
  if (promotions.welcomeBackClaimed) return null;

  const expiresAt = new Date(Date.now() + PROMO_DURATION_MS);

  await userRef.update({
    "promotions.welcomeBackClaimed": true,
    "promotions.welcomeBackAt": admin.firestore.FieldValue.serverTimestamp(),
    promotionBonusRate: WELCOME_BACK_BONUS_RATE,
    promotionExpiresAt: admin.firestore.Timestamp.fromDate(expiresAt),
    promotionType: "welcome_back",
  });

  console.log(
    `🎁 [Promotion] Welcome Back activated for ${deviceId}: ` +
    `${WELCOME_BACK_BONUS_RATE * 100}% bonus (24h)`
  );

  return {
    activated: true,
    type: "welcome_back",
    bonusRate: WELCOME_BACK_BONUS_RATE,
    freeEnergy: 0,
    expiresAt,
  };
}

/**
 * Get the effective bonus rate for a purchase.
 * Returns max(tierBonusRate, promotionBonusRate if active).
 */
export async function getEffectiveBonusRate(
  deviceId: string
): Promise<{bonusRate: number; promotionActive: boolean; promotionType: string}> {
  const userDoc = await db.collection("users").doc(deviceId).get();
  if (!userDoc.exists) return {bonusRate: 0, promotionActive: false, promotionType: ""};

  const user = userDoc.data()!;
  const tierBonusRate = user.bonusRate || 0;
  const promoBonusRate = user.promotionBonusRate || 0;
  const promoExpires = user.promotionExpiresAt?.toDate?.() || new Date(0);
  const promoType = user.promotionType || "";

  const isPromoActive = promoExpires > new Date() && promoBonusRate > 0;
  const effectiveRate = isPromoActive
    ? Math.max(tierBonusRate, promoBonusRate)
    : tierBonusRate;

  return {
    bonusRate: effectiveRate,
    promotionActive: isPromoActive,
    promotionType: isPromoActive ? promoType : "",
  };
}
