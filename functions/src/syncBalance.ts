/**
 * syncBalance Cloud Function
 *
 * Purpose: Sync balance between Client and Server
 * Use cases:
 * 1. App startup — Client ดึง balance จาก Server
 * 2. One-time migration — เมื่อ User เก่าใช้ app version ใหม่ครั้งแรก
 * 3. Manual sync — เมื่อ Client สงสัยว่า balance ไม่ตรง
 */

import {onRequest} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import {getActiveSeasonalQuests} from "./energy/seasonalQuest";

// Initialize Firebase Admin (ถ้ายังไม่ได้ init ใน analyzeFood.ts)
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

interface SyncBalanceRequest {
  deviceId: string;
  localBalance?: number; // สำหรับ migration (optional)
  type: "startup" | "migration" | "manual";
}

export const syncBalance = onRequest(
  {
    timeoutSeconds: 10,
    memory: "256MiB",
    cors: "*",
  },
  async (req, res) => {
    // Validate request method
    if (req.method !== "POST") {
      res.status(405).json({error: "Method not allowed"});
      return;
    }

    try {
      const body = req.body as SyncBalanceRequest;
      const {deviceId, type} = body;

      // Validate required fields
      if (!deviceId) {
        res.status(400).json({error: "Missing deviceId"});
        return;
      }

      console.log(`📡 [syncBalance] Request from ${deviceId} (type: ${type})`);

      // ─── Check if user exists in Firestore (users collection) ───
      const userDoc = await db.collection("users").doc(deviceId).get();

      if (!userDoc.exists) {
        // ─── User ไม่มีใน users collection ───
        // ควรเรียก registerUser ก่อน
        res.status(404).json({
          error: "User not found. Please call registerUser first.",
        });
        return;
      }

      // ─── User มีใน Firestore แล้ว ───
      const userData = userDoc.data()!;
      const serverBalance = userData.balance ?? 0;

      // Compute bonusRate from tier
      let bonusRate = 0;
      if (userData.tier === "gold") bonusRate = 0.1;
      else if (userData.tier === "diamond") bonusRate = 0.2;

      console.log(`✅ [syncBalance] Existing user ${deviceId}: ${serverBalance}`);

      // คำนวณ canClaimToday (UTC+7 Thailand)
      const nowUtc7 = new Date(Date.now() + 7 * 60 * 60 * 1000);
      const todayStr = nowUtc7.toISOString().split("T")[0]; // 'YYYY-MM-DD'

      // ─── Retroactive Tier Celebration Initialization ───
      // Check if user has tier but missing tierCelebration for that tier
      // (handles admin panel tier changes or existing users)
      const currentTier = userData.tier ?? "none";
      const tierCelebration = userData.tierCelebration || {};
      const needsInit: string[] = [];

      if (currentTier !== "none" && !tierCelebration[currentTier]) {
        needsInit.push(currentTier);
      }

      // Also check starter if not initialized
      if (!tierCelebration["starter"]) {
        needsInit.push("starter");
      }

      if (needsInit.length > 0) {
        console.log(`🎉 [syncBalance] Retroactively initializing celebrations: ${needsInit.join(", ")}`);
        const updates: any = {};
        for (const tier of needsInit) {
          updates[`tierCelebration.${tier}`] = {
            startDate: todayStr,
            claimedDays: [],
          };
        }
        await db.collection("users").doc(deviceId).update(updates);
        // Re-fetch updated data
        const updatedDoc = await db.collection("users").doc(deviceId).get();
        Object.assign(userData, updatedDoc.data());
      }

      // Fetch active seasonal quests
      const seasonalQuests = await getActiveSeasonalQuests(deviceId);

      res.status(200).json({
        success: true,
        balance: serverBalance,
        miroId: userData.miroId,
        tier: userData.tier ?? "none",
        currentStreak: userData.currentStreak ?? 0,
        longestStreak: userData.longestStreak ?? 0,
        challenges: userData.challenges ?? {},
        milestones: userData.milestones ?? {},
        totalSpent: userData.totalSpent ?? 0,
        bonusRate: bonusRate,
        subscription: userData.subscription ?? {},
        tierCelebration: userData.tierCelebration ?? {},
        seasonalQuests: seasonalQuests,
        action: "synced",
      });
    } catch (error: any) {
      console.error("❌ [syncBalance] Error:", error);
      res.status(500).json({
        error: "Internal server error",
        message: error.message,
      });
    }
  }
);
