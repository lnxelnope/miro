/**
 * Admin API: Config Management
 *
 * GET /admin/config/:type (rewards | features)
 * POST /admin/config/:type (update config)
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

export const getConfig = onRequest(
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
      const type = req.query.type as string;
      if (!type || (type !== "rewards" && type !== "features")) {
        res.status(400).json({error: "Invalid config type"});
        return;
      }

      const doc = await db.collection("config").doc(type).get();
      if (!doc.exists) {
        res.status(404).json({error: "Config not found"});
        return;
      }

      res.status(200).json({
        success: true,
        config: doc.data(),
      });
    } catch (error: any) {
      console.error("❌ [getConfig] Error:", error);
      res.status(500).json({error: error.message});
    }
  }
);

export const updateConfig = onRequest(
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
      const type = req.query.type as string;
      const configData = req.body.config;

      if (!type || (type !== "rewards" && type !== "features")) {
        res.status(400).json({error: "Invalid config type"});
        return;
      }

      if (!configData) {
        res.status(400).json({error: "Missing config data"});
        return;
      }

      // Save previous version to history
      const currentDoc = await db.collection("config").doc(type).get();
      if (currentDoc.exists) {
        await db.collection("config_history").add({
          configType: type,
          previousData: currentDoc.data(),
          newData: configData,
          changedBy: req.headers["x-admin-id"] || "unknown",
          changedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      // Update config
      await db.collection("config").doc(type).set(
        {
          ...configData,
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        },
        {merge: true}
      );

      res.status(200).json({success: true});
    } catch (error: any) {
      console.error("❌ [updateConfig] Error:", error);
      res.status(500).json({error: error.message});
    }
  }
);
