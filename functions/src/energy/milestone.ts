/**
 * milestone.ts
 *
 * Milestone Rewards System
 */

import {onRequest} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

const MILESTONE_CONFIG: Record<string, { threshold: number; reward: number }> = {
  spent500: {threshold: 500, reward: 15},
  spent1000: {threshold: 1000, reward: 30},
};

/**
 * claimMilestone Cloud Function
 *
 * Claim reward เมื่อ milestone สำเร็จ
 */
export const claimMilestone = onRequest(
  {
    timeoutSeconds: 10,
    memory: "256MiB",
    cors: true,
  },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({error: "Method not allowed"});
      return;
    }

    try {
      const {deviceId, milestoneType} = req.body;

      if (!deviceId || !milestoneType) {
        res.status(400).json({error: "Missing deviceId or milestoneType"});
        return;
      }

      const config = MILESTONE_CONFIG[milestoneType];
      if (!config) {
        res.status(400).json({error: `Invalid milestoneType: ${milestoneType}`});
        return;
      }

      const result = await db.runTransaction(async (transaction) => {
        const userRef = db.collection("users").doc(deviceId);
        const userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          throw new Error("User not found");
        }

        const userData = userDoc.data()!;
        const totalSpent = userData.totalSpent || 0;
        const milestones = userData.milestones || {};
        const balance = userData.balance || 0;

        // เช็คว่าเคลมแล้วหรือยัง
        const claimKey = `${milestoneType}Claimed`;
        if (milestones[claimKey]) {
          throw new Error("Milestone already claimed");
        }

        // เช็ค threshold (SERVER verify!)
        if (totalSpent < config.threshold) {
          throw new Error(
            `Milestone not reached: ${totalSpent}/${config.threshold}`
          );
        }

        // Award reward
        const newBalance = balance + config.reward;

        transaction.update(userRef, {
          balance: newBalance,
          totalEarned: (userData.totalEarned || 0) + config.reward,
          [`milestones.${claimKey}`]: true,
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Log transaction
        const txRef = db.collection("transactions").doc();
        transaction.set(txRef, {
          deviceId,
          miroId: userData.miroId || "unknown",
          type: "milestone",
          amount: config.reward,
          balanceAfter: newBalance,
          description: `Milestone reached: ${totalSpent} Energy spent`,
          metadata: {
            milestoneType,
            totalSpent,
            threshold: config.threshold,
          },
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        return {
          success: true,
          energyReward: config.reward,
          newBalance,
        };
      });

      console.log(
        `🎉 [Milestone] ${deviceId} claimed ${milestoneType}: +${config.reward} Energy`
      );

      res.status(200).json(result);
    } catch (error: any) {
      console.error("❌ [claimMilestone] Error:", error);
      res.status(500).json({error: error.message});
    }
  }
);
