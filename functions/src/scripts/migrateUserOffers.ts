/**
 * Migrate User Offers Script
 *
 * ย้าย user offers จาก hardcoded fields → dynamic offers.active format
 * รันหลัง seed script และ backend deploy แล้ว
 *
 * Usage:
 *   cd functions
 *   npx ts-node src/scripts/migrateUserOffers.ts
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

async function migrateUserOffers() {
  console.log("🔄 Starting user offers migration...\n");

  // 1. Load template IDs by slug
  const templatesSnapshot = await db.collection("offer_templates").get();
  const slugToId: Record<string, string> = {};
  templatesSnapshot.forEach((doc) => {
    const data = doc.data();
    slugToId[data.slug] = doc.id;
  });

  console.log(`📋 Found ${Object.keys(slugToId).length} templates:`);
  Object.entries(slugToId).forEach(([slug, id]) => {
    console.log(`   - ${slug} → ${id}`);
  });
  console.log();

  // 2. Scan all users
  const usersSnapshot = await db.collection("users").get();
  let migrated = 0;
  let skipped = 0;
  let errors = 0;

  console.log(`👥 Processing ${usersSnapshot.size} users...\n`);

  for (const userDoc of usersSnapshot.docs) {
    try {
      const user = userDoc.data();
      const oldOffers = user.offers || {};

      // ข้ามถ้าไม่มี offers เก่า
      if (
        !oldOffers.firstPurchaseAvailable &&
        !oldOffers.welcomeBonusAvailable
      ) {
        skipped++;
        continue;
      }

      const newActive: Record<string, any> = {};
      const existingActive = oldOffers.active || {};

      // Migrate starter_deal
      const starterDealId = slugToId["starter_deal"];
      if (starterDealId && oldOffers.firstPurchaseAvailable) {
        // ตรวจสอบว่ามีใน active อยู่แล้วหรือยัง (ไม่ overwrite)
        if (!existingActive[starterDealId]) {
          newActive[starterDealId] = {
            templateId: starterDealId,
            slug: "starter_deal",
            activatedAt:
              oldOffers.firstPurchaseClaimedAt ||
              admin.firestore.Timestamp.now(),
            expiresAt: oldOffers.firstPurchaseExpiry || null,
            claimed: oldOffers.firstPurchaseClaimed || false,
            claimedAt: oldOffers.firstPurchaseClaimedAt || null,
            claimCount: oldOffers.firstPurchaseClaimed ? 1 : 0,
          };
        }
      }

      // Migrate bonus_40
      const bonus40Id = slugToId["bonus_40_after_purchase"];
      if (bonus40Id && oldOffers.welcomeBonusAvailable) {
        // ตรวจสอบว่ามีใน active อยู่แล้วหรือยัง
        if (!existingActive[bonus40Id]) {
          newActive[bonus40Id] = {
            templateId: bonus40Id,
            slug: "bonus_40_after_purchase",
            activatedAt:
              oldOffers.welcomeBonusClaimedAt ||
              admin.firestore.Timestamp.now(),
            expiresAt: oldOffers.welcomeBonusExpiry || null,
            claimed: oldOffers.welcomeBonusClaimed || false,
            claimedAt: oldOffers.welcomeBonusClaimedAt || null,
            claimCount: oldOffers.welcomeBonusClaimed ? 1 : 0,
          };
        }
      }

      // Write new format (merge with existing active offers)
      if (Object.keys(newActive).length > 0) {
        await userDoc.ref.update({
          "offers.active": {
            ...existingActive,
            ...newActive,
          },
        });
        migrated++;
      } else {
        skipped++;
      }

      if (migrated > 0 && migrated % 100 === 0) {
        console.log(`   Migrated ${migrated} users...`);
      }
    } catch (error: any) {
      console.error(`❌ Error migrating user ${userDoc.id}:`, error.message);
      errors++;
    }
  }

  console.log(`\n✨ Done!`);
  console.log(`   ✅ Migrated: ${migrated}`);
  console.log(`   ⏭️  Skipped: ${skipped}`);
  console.log(`   ❌ Errors: ${errors}`);
  process.exit(0);
}

migrateUserOffers().catch((e) => {
  console.error("❌ Migration failed:", e);
  process.exit(1);
});
