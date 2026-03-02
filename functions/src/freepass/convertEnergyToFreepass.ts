/**
 * convertEnergyToFreepass - Cloud Function
 *
 * แลก energy เป็น freepass days
 * Rate: 50 energy = 1 day
 *
 * Freepass days ไม่มีวันหมดอายุ — เก็บไว้จนกว่าจะใช้
 * Auto-activate เมื่อ subscription หมดอายุ (handled in analyzeFood)
 */

import { onRequest } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

const ENERGY_PER_DAY = 50;
const MIN_DAYS = 1;
const MAX_DAYS_PER_CONVERSION = 60;

export const convertEnergyToFreepass = onRequest(
  {
    timeoutSeconds: 30,
    memory: "256MiB",
    cors: "*",
  },
  async (req, res) => {
    if (req.method === "OPTIONS") {
      res.status(204).send("");
      return;
    }

    if (req.method !== "POST") {
      res.status(405).json({ error: "Method not allowed" });
      return;
    }

    try {
      const { deviceId, days } = req.body;

      if (!deviceId || typeof deviceId !== "string") {
        res.status(400).json({ error: "Missing or invalid deviceId" });
        return;
      }

      const requestedDays = typeof days === "number" ? Math.floor(days) : 0;
      if (requestedDays < MIN_DAYS || requestedDays > MAX_DAYS_PER_CONVERSION) {
        res.status(400).json({
          error: `Days must be between ${MIN_DAYS} and ${MAX_DAYS_PER_CONVERSION}`,
          minDays: MIN_DAYS,
          maxDays: MAX_DAYS_PER_CONVERSION,
        });
        return;
      }

      const energyCost = requestedDays * ENERGY_PER_DAY;

      const result = await db.runTransaction(async (transaction) => {
        const userRef = db.collection("users").doc(deviceId);
        const userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          throw new Error("User not found");
        }

        const userData = userDoc.data()!;
        const currentBalance = userData.balance ?? 0;

        if (currentBalance < energyCost) {
          throw new Error(
            `Insufficient energy: have ${currentBalance}, need ${energyCost}`
          );
        }

        const currentFreepass = userData.freepass ?? {};
        const currentTotalDays = currentFreepass.totalDays ?? 0;
        const newTotalDays = currentTotalDays + requestedDays;
        const newBalance = currentBalance - energyCost;

        transaction.update(userRef, {
          balance: newBalance,
          "freepass.totalDays": newTotalDays,
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Log transaction
        const txRef = db.collection("transactions").doc();
        transaction.set(txRef, {
          deviceId,
          miroId: userData.miroId || "unknown",
          type: "freepass_conversion",
          amount: -energyCost,
          balanceAfter: newBalance,
          description: `Converted ${energyCost} energy to ${requestedDays} freepass days`,
          metadata: {
            daysConverted: requestedDays,
            energyCost,
            newTotalDays,
            rate: ENERGY_PER_DAY,
          },
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        return {
          newBalance,
          newTotalDays,
          daysConverted: requestedDays,
          energySpent: energyCost,
        };
      });

      console.log(
        `✅ [Freepass] ${deviceId}: converted ${result.energySpent}E → ${result.daysConverted} days (total: ${result.newTotalDays})`
      );

      res.status(200).json({
        success: true,
        ...result,
        freepass: {
          totalDays: result.newTotalDays,
          isActive: false,
        },
      });
    } catch (error: any) {
      console.error("❌ [Freepass] Error:", error.message);

      if (error.message.includes("Insufficient energy")) {
        res.status(402).json({ error: error.message });
        return;
      }
      if (error.message === "User not found") {
        res.status(404).json({ error: error.message });
        return;
      }

      res.status(500).json({ error: error.message || "Internal server error" });
    }
  }
);
