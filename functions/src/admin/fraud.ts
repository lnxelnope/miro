/**
 * Admin API: Fraud Alerts
 *
 * GET /admin/fraud?status=pending
 * POST /admin/fraud/:alertId/review (review/dismiss/ban)
 */

import {onRequest} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

function verifyAdminAuth(req: any): boolean {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return false;
  }
  const token = authHeader.substring(7);
  return token === process.env.ADMIN_SECRET;
}

export const getFraudAlerts = onRequest(
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
      const status = (req.query.status as string) || "pending";

      let query: admin.firestore.Query = db
        .collection("fraud_alerts")
        .orderBy("createdAt", "desc")
        .limit(100);

      if (status !== "all") {
        query = query.where("status", "==", status);
      }

      const snapshot = await query.get();
      const alerts = snapshot.docs.map((doc) => ({
        id: doc.id,
        ...doc.data(),
      }));

      res.status(200).json({success: true, alerts});
    } catch (error: any) {
      console.error("❌ [getFraudAlerts] Error:", error);
      res.status(500).json({error: error.message});
    }
  }
);

export const reviewFraudAlert = onRequest(
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
      const alertId = req.query.alertId as string;
      const {action, reason} = req.body; // action: 'dismiss' | 'confirm' | 'ban'

      if (!alertId || !action) {
        res.status(400).json({error: "Missing required fields"});
        return;
      }

      const alertRef = db.collection("fraud_alerts").doc(alertId);
      const alertDoc = await alertRef.get();

      if (!alertDoc.exists) {
        res.status(404).json({error: "Alert not found"});
        return;
      }

      const alertData = alertDoc.data()!;
      const deviceId = alertData.deviceId;

      // Update alert status
      await alertRef.update({
        status: action === "ban" ? "confirmed" : action === "dismiss" ? "dismissed" : "reviewed",
        reviewedBy: req.headers["x-admin-id"] || "unknown",
        reviewedAt: admin.firestore.FieldValue.serverTimestamp(),
        reviewReason: reason,
      });

      // If ban action → ban user
      if (action === "ban") {
        await db.collection("users").doc(deviceId).update({
          isBanned: true,
          banReason: reason || "Fraud confirmed",
          banDate: admin.firestore.FieldValue.serverTimestamp(),
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      res.status(200).json({success: true});
    } catch (error: any) {
      console.error("❌ [reviewFraudAlert] Error:", error);
      res.status(500).json({error: error.message});
    }
  }
);
