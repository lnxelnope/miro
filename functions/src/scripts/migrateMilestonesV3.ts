/**
 * migrateMilestonesV3.ts
 *
 * Migration Script: V2 Milestone → V3 Milestone
 *
 * วิธีใช้:
 *   npx ts-node functions/src/scripts/migrateMilestonesV3.ts
 *
 * หรือ deploy เป็น one-time Cloud Function แล้วเรียก 1 ครั้ง
 *
 * กฎการ migrate:
 * 1. อ่าน totalSpent จาก user doc
 * 2. คำนวณ V3 milestone state ด้วย computeMilestoneState()
 * 3. Milestone ที่ผ่านมาแล้ว → ถือว่า "claimed" โดยอัตโนมัติ (ไม่ให้ reward ย้อนหลัง)
 * 4. เขียน milestones.{totalSpent, claimedMilestones, nextMilestoneIndex} ลง Firestore
 * 5. Process เป็น batch (500 docs ต่อครั้ง เพื่อไม่ให้ timeout)
 */

import * as admin from "firebase-admin";
import {computeMilestoneState} from "../energy/milestoneV2";

// Initialize (ต้องมี service account credentials)
if (!admin.apps.length) {
  const serviceAccount = require("../../../../service-account.json");
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

const db = admin.firestore();

const BATCH_SIZE = 400; // Firestore limit คือ 500 ops/batch

async function migrateMilestonesV3(): Promise<void> {
  console.log("🚀 Starting V3 Milestone Migration...");

  let processed = 0;
  let skipped = 0;
  let errors = 0;
  let lastDoc: admin.firestore.DocumentSnapshot | undefined;

  while (true) {
    // Query users แบบ paginated
    let query = db.collection("users")
      .orderBy("createdAt")
      .limit(BATCH_SIZE);

    if (lastDoc) {
      query = query.startAfter(lastDoc);
    }

    const snapshot = await query.get();

    if (snapshot.empty) {
      console.log("✅ No more users to process");
      break;
    }

    const batch = db.batch();
    let batchCount = 0;

    for (const doc of snapshot.docs) {
      try {
        const user = doc.data();

        // Skip ถ้ามี milestones field แล้ว (migrate แล้ว)
        if (user.milestones?.nextMilestoneIndex !== undefined) {
          skipped++;
          continue;
        }

        // ดึง totalSpent (จาก root field เก่า หรือ 0)
        const totalSpent = (user.totalSpent as number | undefined) ?? 0;

        // คำนวณ V3 state (existing milestone ถือว่า claimed แล้ว ไม่ให้ reward)
        const milestoneState = computeMilestoneState(totalSpent);

        batch.update(doc.ref, {
          milestones: {
            totalSpent: milestoneState.totalSpent,
            claimedMilestones: milestoneState.claimedMilestones,
            nextMilestoneIndex: milestoneState.nextMilestoneIndex,
          },
          // Init other V3 fields ถ้ายังไม่มี
          ...(!user.offers ? {
            offers: {
              firstPurchaseClaimed: false,
              firstPurchaseAvailable: false,
              firstPurchaseExpiry: null,
              welcomeBonusClaimed: false,
              welcomeBonusAvailable: false,
              welcomeBonusExpiry: null,
            },
          } : {}),
          ...(!user.adViews ? {
            adViews: {date: "", count: 0},
          } : {}),
          ...(!user.dailyClaim ? {
            dailyClaim: {
              lastClaimDate: user.lastCheckInDate || "",
            },
          } : {}),
          ...(!user.notifications ? {
            notifications: {
              offerExpirySent: {},
              lastStreakReminder: "",
            },
          } : {}),
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        });

        batchCount++;
        processed++;

        if (processed % 100 === 0) {
          console.log(`  📊 Processed: ${processed} users...`);
        }
      } catch (err) {
        console.error(`❌ Error processing ${doc.id}:`, err);
        errors++;
      }
    }

    if (batchCount > 0) {
      await batch.commit();
      console.log(`  ✅ Batch committed: ${batchCount} users`);
    }

    lastDoc = snapshot.docs[snapshot.docs.length - 1];

    if (snapshot.size < BATCH_SIZE) {
      break; // หมดแล้ว
    }
  }

  console.log("\n========================================");
  console.log(`✅ Migration Complete!`);
  console.log(`   Processed : ${processed}`);
  console.log(`   Skipped   : ${skipped} (already migrated)`);
  console.log(`   Errors    : ${errors}`);
  console.log("========================================");
}

migrateMilestonesV3().catch((err) => {
  console.error("❌ Migration failed:", err);
  process.exit(1);
});
