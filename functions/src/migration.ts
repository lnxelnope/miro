import {onRequest} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

// ใช้ CHARSET เดียวกับ transferKey.ts (ไม่ใช้ตัวที่สับสน: 0,O,1,I,L)
const CHARSET = "ABCDEFGHJKMNPQRSTUVWXYZ23456789";

/**
 * สร้าง ArCal ID format: ARCAL-XXXX-XXXX-XXXX
 *
 * Example: ARCAL-A3F9-K7X2-P8M1
 */
function generateMiroId(): string {
  const segments: string[] = [];

  // สร้าง 3 segments ของ 4 ตัวอักษร
  for (let i = 0; i < 3; i++) {
    let segment = "";
    for (let j = 0; j < 4; j++) {
      const randomIndex = Math.floor(Math.random() * CHARSET.length);
      segment += CHARSET[randomIndex];
    }
    segments.push(segment);
  }

  return `ARCAL-${segments.join("-")}`;
}

/**
 * เช็คว่า ArCal ID ซ้ำกับที่มีอยู่หรือไม่
 */
async function isUniqueMiroId(miroId: string): Promise<boolean> {
  const snapshot = await db
    .collection("users")
    .where("miroId", "==", miroId)
    .limit(1)
    .get();

  return snapshot.empty; // true = ไม่ซ้ำ
}

/**
 * สร้าง ArCal ID ที่ unique (ลองสูงสุด 10 ครั้ง)
 */
async function generateUniqueMiroId(): Promise<string> {
  let miroId = generateMiroId();
  let attempts = 0;
  const maxAttempts = 10;

  while (!(await isUniqueMiroId(miroId)) && attempts < maxAttempts) {
    miroId = generateMiroId();
    attempts++;
  }

  if (attempts >= maxAttempts) {
    throw new Error("Failed to generate unique ArCal ID after max attempts");
  }

  return miroId;
}

/**
 * migrateToUsersCollection
 *
 * One-time migration: energy_balances → users
 * ⚠️ ใน production ต้องเพิ่ม auth check!
 */
export const migrateToUsersCollection = onRequest(
  {
    timeoutSeconds: 540, // 9 นาที (max)
    memory: "1GiB",
  },
  async (req, res) => {
    // TODO: เพิ่ม admin authentication check
    // if (!isAdmin(req)) { return res.status(403).json({ error: 'Forbidden' }); }

    try {
      console.log("🔄 [Migration] Starting migration...");

      // 1. ดึงข้อมูลทั้งหมดจาก energy_balances
      const energyDocs = await db.collection("energy_balances").get();

      let migrated = 0;
      let skipped = 0;
      let errors = 0;

      // 2. วนลูปแต่ละ user
      for (const doc of energyDocs.docs) {
        const deviceId = doc.id;
        const data = doc.data();

        // เช็คว่า migrate แล้วหรือยัง
        const userDoc = await db.collection("users").doc(deviceId).get();
        if (userDoc.exists) {
          console.log(`⏭️  [Migration] Skipping ${deviceId} (already migrated)`);
          skipped++;
          continue;
        }

        try {
          // 3. สร้าง ArCal ID ใหม่
          const miroId = await generateUniqueMiroId();
          const now = admin.firestore.FieldValue.serverTimestamp();

          // 4. สร้าง user document ใหม่
          await db.collection("users").doc(deviceId).set({
            // ─── Identity ───
            deviceId,
            miroId,
            createdAt: data.createdAt || now,
            lastUpdated: now,

            // ─── Energy (migrate จาก energy_balances) ───
            balance: data.balance || 0,
            totalEarned: 0,
            totalSpent: 0,
            totalPurchased: 0,
            welcomeGiftClaimed: data.welcomeGiftClaimed || false,

            // ─── Streak & Tier (fresh start) ───
            currentStreak: 0,
            longestStreak: 0,
            lastCheckInDate: null,
            tier: "none",
            tierUnlockedAt: {
              bronze: null,
              silver: null,
              gold: null,
              diamond: null,
            },

            // ─── Flags ───
            isBanned: false,
            banReason: null,
          });

          console.log(`✅ [Migration] Migrated ${deviceId} → ${miroId}`);
          migrated++;
        } catch (err: any) {
          console.error(`❌ [Migration] Error migrating ${deviceId}:`, err);
          errors++;
        }
      }

      // 5. Return summary
      console.log(
        `✅ [Migration] Complete: ${migrated} migrated, ${skipped} skipped, ${errors} errors`
      );

      res.status(200).json({
        success: true,
        total: energyDocs.size,
        migrated,
        skipped,
        errors,
      });
    } catch (error: any) {
      console.error("❌ [Migration] Fatal error:", error);
      res.status(500).json({error: error.message});
    }
  }
);
