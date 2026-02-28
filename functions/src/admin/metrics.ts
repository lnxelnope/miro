/**
 * Admin API: Metrics
 *
 * GET /admin/metrics?days=30
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

export const getMetrics = onRequest(
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
      const days = parseInt((req.query.days as string) || "30");
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - days);
      const startStr = startDate.toISOString().split("T")[0];

      const snapshot = await db
        .collection("metrics")
        .where("date", ">=", startStr)
        .orderBy("date", "desc")
        .get();

      const metrics = snapshot.docs.map((doc) => ({
        date: doc.id,
        ...doc.data(),
      }));

      res.status(200).json({success: true, metrics});
    } catch (error: any) {
      console.error("❌ [getMetrics] Error:", error);
      res.status(500).json({error: error.message});
    }
  }
);
