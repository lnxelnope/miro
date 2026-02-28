/**
 * Admin API: User Management
 *
 * Endpoints สำหรับ Admin Panel:
 * - GET /admin/users?search=... (search by MiRO ID or deviceId)
 * - GET /admin/users/:deviceId (get user detail)
 * - POST /admin/users/:deviceId/topup (manual top-up)
 * - POST /admin/users/:deviceId/reset-streak (reset streak)
 * - POST /admin/users/:deviceId/ban (ban user)
 */

import {onRequest} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

/**
 * Simple admin auth check (Phase 3: basic password)
 * Phase ถัดไป: ใช้ Firebase Auth + role-based
 */
function verifyAdminAuth(req: any): boolean {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return false;
  }

  const token = authHeader.substring(7);
  // TODO: Verify JWT token หรือ admin password
  // ตอนนี้ใช้ simple check
  return token === process.env.ADMIN_SECRET;
}

/**
 * Search users by MiRO ID or deviceId
 */
export const searchUsers = onRequest(
  {
    timeoutSeconds: 10,
    memory: "256MiB",
    cors: true,
  },
  async (req, res) => {
    if (!verifyAdminAuth(req)) {
      res.status(401).json({error: "Unauthorized"});
      return;
    }

    try {
      const search = req.query.search as string;
      if (!search) {
        res.status(400).json({error: "Missing search parameter"});
        return;
      }

      let userDoc: admin.firestore.DocumentSnapshot | null = null;

      // Try search by MiRO ID
      const miroIdQuery = await db
        .collection("users")
        .where("miroId", "==", search)
        .limit(1)
        .get();

      if (!miroIdQuery.empty) {
        userDoc = miroIdQuery.docs[0];
      } else {
        // Try search by deviceId
        userDoc = await db.collection("users").doc(search).get();
      }

      if (!userDoc || !userDoc.exists) {
        res.status(404).json({error: "User not found"});
        return;
      }

      const userData = userDoc.data()!;

      res.status(200).json({
        success: true,
        user: {
          deviceId: userDoc.id,
          miroId: userData.miroId,
          balance: userData.balance || 0,
          totalSpent: userData.totalSpent || 0,
          totalPurchased: userData.totalPurchased || 0,
          totalEarned: userData.totalEarned || 0,
          tier: userData.tier || "none",
          currentStreak: userData.currentStreak || 0,
          longestStreak: userData.longestStreak || 0,
          challenges: userData.challenges || {},
          milestones: userData.milestones || {},
          isBanned: userData.isBanned || false,
          createdAt: userData.createdAt,
          lastUpdated: userData.lastUpdated,
        },
      });
    } catch (error: any) {
      console.error("❌ [searchUsers] Error:", error);
      res.status(500).json({error: error.message});
    }
  }
);

/**
 * Get user detail with transaction history
 */
export const getUserDetail = onRequest(
  {
    timeoutSeconds: 10,
    memory: "256MiB",
    cors: true,
  },
  async (req, res) => {
    if (!verifyAdminAuth(req)) {
      res.status(401).json({error: "Unauthorized"});
      return;
    }

    try {
      const deviceId = req.query.deviceId as string;
      if (!deviceId) {
        res.status(400).json({error: "Missing deviceId"});
        return;
      }

      const userDoc = await db.collection("users").doc(deviceId).get();
      if (!userDoc.exists) {
        res.status(404).json({error: "User not found"});
        return;
      }

      const userData = userDoc.data()!;

      // Get recent transactions (last 50)
      const transactionsSnapshot = await db
        .collection("transactions")
        .where("deviceId", "==", deviceId)
        .orderBy("createdAt", "desc")
        .limit(50)
        .get();

      const transactions = transactionsSnapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }));

      res.status(200).json({
        success: true,
        user: {
          deviceId: userDoc.id,
          miroId: userData.miroId,
          balance: userData.balance || 0,
          totalSpent: userData.totalSpent || 0,
          totalPurchased: userData.totalPurchased || 0,
          totalEarned: userData.totalEarned || 0,
          tier: userData.tier || "none",
          currentStreak: userData.currentStreak || 0,
          longestStreak: userData.longestStreak || 0,
          challenges: userData.challenges || {},
          milestones: userData.milestones || {},
          isBanned: userData.isBanned || false,
          createdAt: userData.createdAt,
          lastUpdated: userData.lastUpdated,
        },
        transactions,
      });
    } catch (error: any) {
      console.error("❌ [getUserDetail] Error:", error);
      res.status(500).json({error: error.message});
    }
  }
);

/**
 * Manual top-up energy
 */
export const topupEnergy = onRequest(
  {
    timeoutSeconds: 10,
    memory: "256MiB",
    cors: true,
  },
  async (req, res) => {
    if (!verifyAdminAuth(req)) {
      res.status(401).json({error: "Unauthorized"});
      return;
    }

    try {
      const {deviceId, amount, reason} = req.body;

      if (!deviceId || !amount || !reason) {
        res.status(400).json({error: "Missing required fields"});
        return;
      }

      const result = await db.runTransaction(async (transaction) => {
        const userRef = db.collection("users").doc(deviceId);
        const userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          throw new Error("User not found");
        }

        const user = userDoc.data()!;
        const newBalance = (user.balance || 0) + amount;

        transaction.update(userRef, {
          balance: newBalance,
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Log transaction
        const txRef = db.collection("transactions").doc();
        transaction.set(txRef, {
          deviceId,
          miroId: user.miroId || "unknown",
          type: "admin_topup",
          amount,
          balanceAfter: newBalance,
          description: `Admin top-up: ${reason}`,
          metadata: {
            adminAction: true,
            reason,
            adminId: req.headers["x-admin-id"] || "unknown",
          },
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        return {newBalance};
      });

      res.status(200).json({
        success: true,
        ...result,
      });
    } catch (error: any) {
      console.error("❌ [topupEnergy] Error:", error);
      res.status(500).json({error: error.message});
    }
  }
);

/**
 * Reset streak
 */
export const resetStreak = onRequest(
  {
    timeoutSeconds: 10,
    memory: "256MiB",
    cors: true,
  },
  async (req, res) => {
    if (!verifyAdminAuth(req)) {
      res.status(401).json({error: "Unauthorized"});
      return;
    }

    try {
      const {deviceId, reason} = req.body;

      if (!deviceId || !reason) {
        res.status(400).json({error: "Missing required fields"});
        return;
      }

      await db.collection("users").doc(deviceId).update({
        currentStreak: 0,
        lastCheckInDate: null,
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      });

      res.status(200).json({success: true});
    } catch (error: any) {
      console.error("❌ [resetStreak] Error:", error);
      res.status(500).json({error: error.message});
    }
  }
);

/**
 * Ban/Unban user
 */
export const banUser = onRequest(
  {
    timeoutSeconds: 10,
    memory: "256MiB",
    cors: true,
  },
  async (req, res) => {
    if (!verifyAdminAuth(req)) {
      res.status(401).json({error: "Unauthorized"});
      return;
    }

    try {
      const {deviceId, isBanned, reason} = req.body;

      if (!deviceId || isBanned === undefined || !reason) {
        res.status(400).json({error: "Missing required fields"});
        return;
      }

      await db.collection("users").doc(deviceId).update({
        isBanned,
        banReason: reason,
        banDate: isBanned ?
          admin.firestore.FieldValue.serverTimestamp() :
          null,
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      });

      res.status(200).json({success: true});
    } catch (error: any) {
      console.error("❌ [banUser] Error:", error);
      res.status(500).json({error: error.message});
    }
  }
);
