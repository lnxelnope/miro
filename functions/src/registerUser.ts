/**
 * registerUser Cloud Function
 *
 * เรียกตอน: App เปิดครั้งแรก (ยังไม่มี user document)
 * สิ่งที่ทำ: สร้าง user document + ArCal ID + Welcome Gift
 *
 * Input:  { deviceId: string }
 * Output: { success, miroId, balance, isNew }
 */

import {onRequest} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {getActiveSeasonalQuests} from "./energy/seasonalQuest";
import {evaluateOffers} from "./energy/offerEngine";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

// ใช้ CHARSET เดียวกับ migration.ts
const CHARSET = "ABCDEFGHJKMNPQRSTUVWXYZ23456789";
const WELCOME_GIFT = 10;

/**
 * สร้าง ArCal ID: ARCAL-XXXX-XXXX-XXXX
 */
function generateMiroId(): string {
  const segments: string[] = [];

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
 * สร้าง ArCal ID ที่ unique
 */
async function generateUniqueMiroId(): Promise<string> {
  let miroId = generateMiroId();
  let attempts = 0;

  while (attempts < 10) {
    const existing = await db
      .collection("users")
      .where("miroId", "==", miroId)
      .limit(1)
      .get();

    if (existing.empty) return miroId;

    miroId = generateMiroId();
    attempts++;
  }

  throw new Error("Failed to generate unique ArCal ID");
}

/**
 * registerUser Cloud Function
 */
export const registerUser = onRequest(
  {
    timeoutSeconds: 15,
    memory: "256MiB",
    cors: true, // Allow CORS from Flutter app
  },
  async (req, res) => {
    // เช็ค HTTP method
    if (req.method !== "POST") {
      res.status(405).json({error: "Method not allowed"});
      return;
    }

    try {
      const {deviceId} = req.body;

      // Validate input
      if (!deviceId || typeof deviceId !== "string") {
        res.status(400).json({error: "Missing or invalid deviceId"});
        return;
      }

      // ─── เช็คว่า user มีอยู่แล้วหรือไม่ ───
      const existingUser = await db.collection("users").doc(deviceId).get();

      if (existingUser.exists) {
        // User มีแล้ว → return ข้อมูลครบทุก field
        const data = existingUser.data()!;
        console.log(`✅ [registerUser] Existing user: ${data.miroId}`);

        // Compute bonusRate from tier
        let bonusRate = 0;
        if (data.tier === "gold") bonusRate = 0.1;
        else if (data.tier === "diamond") bonusRate = 0.2;

        // ─── Retroactive Tier Celebration Initialization ───
        const today = new Date().toISOString().split("T")[0];
        const currentTier = data.tier ?? "none";
        const tierCelebration = data.tierCelebration || {};
        const needsInit: string[] = [];

        if (currentTier !== "none" && !tierCelebration[currentTier]) {
          needsInit.push(currentTier);
        }
        if (!tierCelebration["starter"]) {
          needsInit.push("starter");
        }

        let finalTierCelebration = data.tierCelebration ?? {};

        if (needsInit.length > 0) {
          console.log(`🎉 [registerUser] Retroactively initializing celebrations: ${needsInit.join(", ")}`);
          const updates: any = {};
          for (const tier of needsInit) {
            updates[`tierCelebration.${tier}`] = {
              startDate: today,
              claimedDays: [],
            };
          }
          await db.collection("users").doc(deviceId).update(updates);
          // Build merged object for response
          finalTierCelebration = {...tierCelebration};
          for (const tier of needsInit) {
            finalTierCelebration[tier] = {startDate: today, claimedDays: []};
          }
        }

        // Fetch active seasonal quests
        const seasonalQuests = await getActiveSeasonalQuests(deviceId);

        const lastCheckInDate = data.lastCheckInDate || null;
        const todayCheck = new Date(Date.now() + 7 * 60 * 60 * 1000).toISOString().split("T")[0];
        const canClaimToday = lastCheckInDate !== todayCheck;

        res.status(200).json({
          success: true,
          isNew: false,
          miroId: data.miroId,
          balance: data.balance ?? 0,
          tier: data.tier ?? "none",
          currentStreak: data.currentStreak ?? 0,
          longestStreak: data.longestStreak ?? 0,
          lastCheckInDate,
          canClaimToday,
          challenges: data.challenges ?? {},
          milestones: data.milestones ?? {},
          totalSpent: data.totalSpent ?? 0,
          bonusRate: bonusRate,
          subscription: data.subscription ?? {},
          tierCelebration: finalTierCelebration,
          seasonalQuests: seasonalQuests,
          freepass: data.freepass ?? {},
        });
        return;
      }

      // ─── สร้าง user ใหม่ ───
      const miroId = await generateUniqueMiroId();
      const now = admin.firestore.FieldValue.serverTimestamp();

      // ✅ ให้ Welcome Gift ตามปกติ (ลบ energy_balances migration แล้ว — เคย migrate ซ้ำทำให้ได้ 1000E+)
      const balance = WELCOME_GIFT;

      // สร้าง user document
      await db.collection("users").doc(deviceId).set({
        // ─── Identity ───
        deviceId,
        miroId,
        createdAt: now,
        lastUpdated: now,

        // ─── Energy ───
        balance,
        totalEarned: 0,
        totalSpent: 0,
        totalPurchased: 0,
        welcomeGiftClaimed: true,

        // ─── Streak & Tier ───
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

      // บันทึก transaction
      await db.collection("transactions").add({
        deviceId,
        miroId,
        type: "welcome_gift",
        amount: balance,
        balanceAfter: balance,
        description: `Welcome to ArCal! ${WELCOME_GIFT} Energy gift`,
        metadata: {},
        createdAt: now,
      });

      console.log(`🎉 [registerUser] New user: ${miroId} (balance: ${balance})`);

      // Evaluate offers for new user
      try {
        await evaluateOffers(deviceId, "first_app_open", {});
      } catch (e) {
        console.error("[registerUser] evaluateOffers error:", e);
      }

      // Fetch active seasonal quests for new users too
      const newUserSeasonalQuests = await getActiveSeasonalQuests(deviceId);

      // Return response
      res.status(201).json({
        success: true,
        isNew: true,
        miroId,
        balance,
        tier: "none",
        currentStreak: 0,
        tierCelebration: {},
        seasonalQuests: newUserSeasonalQuests,
      });
    } catch (error: any) {
      console.error("❌ [registerUser] Error:", error);
      res.status(500).json({error: error.message});
    }
  }
);
