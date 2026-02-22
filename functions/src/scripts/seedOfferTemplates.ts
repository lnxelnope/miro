/**
 * Seed Offer Templates Script
 *
 * สร้าง offer_templates จาก hardcoded offers
 * รันครั้งเดียวหลังจาก deploy backend ใหม่
 *
 * Usage:
 *   cd functions
 *   npx ts-node src/scripts/seedOfferTemplates.ts
 */

import * as admin from "firebase-admin";
import * as path from "path";
import * as fs from "fs";

// ─── Initialize Firebase Admin ───
const possiblePaths = [
  path.join(__dirname, "../../serviceAccountKey.json"),
  path.join(__dirname, "../../../admin-panel/serviceAccountKey.json"),
];
const serviceAccountPath = possiblePaths.find((p) => fs.existsSync(p));
if (!serviceAccountPath) {
  console.error("❌ serviceAccountKey.json not found! Searched:", possiblePaths);
  process.exit(1);
}

const serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, "utf8"));
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// ─── Template Definitions ───
const TEMPLATES = [
  {
    slug: "starter_deal",
    triggerEvent: "energy_use_milestone",
    triggerCondition: { minTotalSpent: 10 },
    title: { en: "⚡ Starter Deal", th: "⚡ ดีลสตาร์ทเตอร์" },
    description: {
      en: "Get 200 Energy for just $1! Limited time offer.",
      th: "รับ 200 Energy แค่ $1! ข้อเสนอจำกัดเวลา",
    },
    ctaText: { en: "Buy $1", th: "ซื้อ $1" },
    icon: "⚡",
    rewardType: "special_product",
    rewardConfig: {
      productId: "energy_first_purchase_200",
      energyAmount: 200,
      displayPrice: "$1.00",
    },
    expiresAfterHours: 4,
    priority: 1,
    maxClaimsPerUser: 1,
    isActive: true,
  },
  {
    slug: "bonus_40_after_purchase",
    triggerEvent: "first_purchase_complete",
    triggerCondition: { afterProductId: "energy_first_purchase_200" },
    title: { en: "🎁 40% Bonus", th: "🎁 โบนัส 40%" },
    description: {
      en: "Buy any Energy package and get +40% bonus!",
      th: "ซื้อแพ็กเกจ Energy ใดก็ได้ รับโบนัสเพิ่ม 40%!",
    },
    ctaText: { en: "View Packages", th: "ดูแพ็กเกจ" },
    icon: "🎁",
    rewardType: "bonus_rate",
    rewardConfig: { bonusRate: 0.4 },
    expiresAfterHours: 24,
    priority: 2,
    maxClaimsPerUser: 1,
    isActive: true,
  },
  {
    slug: "tier_up_bonus",
    triggerEvent: "tier_up",
    triggerCondition: {}, // ทุก tier
    title: { en: "🌟 Tier Up Bonus!", th: "🌟 โบนัสเลื่อน Tier!" },
    description: {
      en: "Congratulations on your tier up! +20% bonus on your next purchase.",
      th: "ยินดีด้วยที่เลื่อน Tier! รับโบนัส 20% สำหรับการซื้อครั้งถัดไป",
    },
    ctaText: { en: "Buy Now", th: "ซื้อเลย" },
    icon: "🌟",
    rewardType: "bonus_rate",
    rewardConfig: { bonusRate: 0.2 },
    expiresAfterHours: 48,
    priority: 3,
    maxClaimsPerUser: 1, // 1 ต่อ tier (ถ้าต้องการให้ได้ทุก tier → เปลี่ยนเป็น 4)
    isActive: true,
  },
  {
    slug: "welcome_gift",
    triggerEvent: "first_app_open",
    triggerCondition: {},
    title: { en: "🎉 Welcome to MiRO!", th: "🎉 ยินดีต้อนรับสู่ MiRO!" },
    description: {
      en: "Start your health journey! Here's 5 free Energy.",
      th: "เริ่มต้นเส้นทางสุขภาพ! รับ 5 Energy ฟรี",
    },
    ctaText: { en: "Claim!", th: "รับเลย!" },
    icon: "🎉",
    rewardType: "free_energy",
    rewardConfig: { amount: 5 },
    expiresAfterHours: null, // ไม่หมดอายุ
    priority: 1,
    maxClaimsPerUser: 1,
    isActive: true,
  },
  {
    slug: "meals_100_reward",
    triggerEvent: "meals_logged_milestone",
    triggerCondition: { minMealsLogged: 100 },
    title: { en: "💝 100 Meals Logged!", th: "💝 Log อาหารครบ 100 ครั้ง!" },
    description: {
      en: "Amazing dedication! Here's 25 free Energy as a reward.",
      th: "ยอดเยี่ยม! รับ 25 Energy ฟรีเป็นรางวัล",
    },
    ctaText: { en: "Claim Reward", th: "รับรางวัล" },
    icon: "💝",
    rewardType: "free_energy",
    rewardConfig: { amount: 25 },
    expiresAfterHours: 168, // 7 days
    priority: 2,
    maxClaimsPerUser: 1,
    isActive: true,
  },
];

async function seed() {
  console.log("🌱 Starting seed offer templates...\n");

  let created = 0;
  let skipped = 0;

  for (const template of TEMPLATES) {
    // Check ว่า slug ซ้ำไหม
    const existing = await db
      .collection("offer_templates")
      .where("slug", "==", template.slug)
      .get();

    if (!existing.empty) {
      console.log(`⏭️  Skipped "${template.slug}" (already exists)`);
      skipped++;
      continue;
    }

    // Add timestamps
    const templateData = {
      ...template,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    const ref = await db.collection("offer_templates").add(templateData);
    console.log(`✅ Created "${template.slug}" → ${ref.id}`);
    created++;
  }

  console.log(`\n✨ Done! Created: ${created}, Skipped: ${skipped}`);
  process.exit(0);
}

seed().catch((e) => {
  console.error("❌ Seed failed:", e);
  process.exit(1);
});
