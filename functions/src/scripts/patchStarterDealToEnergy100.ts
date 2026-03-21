/**
 * One-off migration: starter_deal ใช้ energy_100 + โบนัส +100% (รวม 200E) แทน SKU energy_first_purchase_200
 * bonus_40_after_purchase ใช้ trigger requiresStarterEnergy100Bonus แทน afterProductId
 *
 * Usage:
 *   cd functions
 *   npx ts-node src/scripts/patchStarterDealToEnergy100.ts
 */

import * as admin from "firebase-admin";
import * as path from "path";
import * as fs from "fs";

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

async function patchBySlug(slug: string, data: Record<string, unknown>) {
  const snap = await db.collection("offer_templates").where("slug", "==", slug).get();
  if (snap.empty) {
    console.log(`⏭️  No template with slug "${slug}" — skip`);
    return;
  }
  for (const doc of snap.docs) {
    await doc.ref.set(
      {
        ...data,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
    console.log(`✅ Patched "${slug}" → ${doc.id}`);
  }
}

async function main() {
  await patchBySlug("starter_deal", {
    title: { en: "⚡ Starter Deal", th: "⚡ ดีลสตาร์ทเตอร์" },
    description: {
      en: "One-time: buy Starter Kick (100 E) and get +100% bonus — 200 Energy total. Limited time!",
      th: "ครั้งเดียว: ซื้อ Starter Kick (100 E) รับโบนัส +100% — รวม 200 Energy จำกัดเวลา!",
    },
    ctaText: { en: "Open Energy Store", th: "เปิดร้าน Energy" },
    rewardType: "bonus_rate",
    rewardConfig: {
      bonusRate: 1.0,
      applyToProductId: "energy_100",
    },
  });

  await patchBySlug("bonus_40_after_purchase", {
    triggerCondition: { requiresStarterEnergy100Bonus: true },
  });

  console.log("\n✨ Done. Deploy Cloud Functions + remove IAP energy_first_purchase_200 from stores.");
  process.exit(0);
}

main().catch((e) => {
  console.error("❌ Patch failed:", e);
  process.exit(1);
});
