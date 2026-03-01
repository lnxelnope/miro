/**
 * recoveryKey.ts
 *
 * Cloud Functions for Recovery Key — cross-device account restoration.
 *
 * - registerRecoveryKey: stores bcrypt hash of the key on the server
 * - redeemRecoveryKey:   verifies key, links new device, returns all synced data
 */

import {onRequest} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import * as bcrypt from "bcryptjs";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

const CHARSET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
const BCRYPT_ROUNDS = 10;

function generateRecoveryKeyString(): string {
  const part1 = Array.from({length: 4}, () =>
    CHARSET[Math.floor(Math.random() * CHARSET.length)]
  ).join("");
  const part2 = Array.from({length: 4}, () =>
    CHARSET[Math.floor(Math.random() * CHARSET.length)]
  ).join("");
  return `MIRO-${part1}-${part2}`;
}

// ============================================================
// registerRecoveryKey
// POST { deviceId, recoveryKey, regenerate? }
// ============================================================

export const registerRecoveryKey = onRequest(
  {timeoutSeconds: 10, memory: "256MiB", cors: true},
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({error: "Method not allowed"});
      return;
    }

    try {
      const {deviceId, recoveryKey, regenerate} = req.body;

      if (!deviceId || !recoveryKey) {
        res.status(400).json({error: "Missing deviceId or recoveryKey"});
        return;
      }

      // Verify user exists
      const userDoc = await db.collection("users").doc(deviceId).get();
      if (!userDoc.exists) {
        res.status(404).json({error: "User not found"});
        return;
      }

      // Hash the key
      const keyHash = await bcrypt.hash(recoveryKey, BCRYPT_ROUNDS);

      // If regenerating, mark old keys as revoked
      if (regenerate) {
        const oldKeys = await db
          .collection("recovery_keys")
          .where("deviceId", "==", deviceId)
          .where("status", "==", "active")
          .get();

        const batch = db.batch();
        oldKeys.forEach((doc) => {
          batch.update(doc.ref, {
            status: "revoked",
            revokedAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        });
        await batch.commit();
      }

      // Store new key hash
      await db.collection("recovery_keys").add({
        deviceId,
        keyHash,
        status: "active",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Update user doc
      await db.collection("users").doc(deviceId).update({
        hasRecoveryKey: true,
        recoveryKeyCreatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`✅ [RecoveryKey] Registered for ${deviceId}`);
      res.status(200).json({success: true});
    } catch (error: any) {
      console.error("❌ [registerRecoveryKey] Error:", error);
      res.status(500).json({error: error.message});
    }
  }
);

// ============================================================
// redeemRecoveryKey
// POST { recoveryKey, newDeviceId }
// Returns { balance, miroId, entries, meals, newRecoveryKey }
// ============================================================

export const redeemRecoveryKey = onRequest(
  {timeoutSeconds: 30, memory: "512MiB", cors: true},
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({error: "Method not allowed"});
      return;
    }

    try {
      const {recoveryKey, newDeviceId} = req.body;

      if (!recoveryKey || !newDeviceId) {
        res.status(400).json({error: "Missing recoveryKey or newDeviceId"});
        return;
      }

      // Validate key format
      const keyPattern = /^MIRO-[A-Z2-9]{4}-[A-Z2-9]{4}$/;
      if (!keyPattern.test(recoveryKey)) {
        res.status(400).json({error: "Invalid recovery key format"});
        return;
      }

      // Find all active recovery keys and brute-check with bcrypt
      const activeKeys = await db
        .collection("recovery_keys")
        .where("status", "==", "active")
        .get();

      let matchedDoc: FirebaseFirestore.QueryDocumentSnapshot | null = null;
      for (const doc of activeKeys.docs) {
        const data = doc.data();
        const isMatch = await bcrypt.compare(recoveryKey, data.keyHash);
        if (isMatch) {
          matchedDoc = doc;
          break;
        }
      }

      if (!matchedDoc) {
        res.status(404).json({error: "Recovery key not found or expired"});
        return;
      }

      const keyData = matchedDoc.data();
      const sourceDeviceId = keyData.deviceId;

      // Prevent same-device redemption
      if (sourceDeviceId === newDeviceId) {
        res.status(400).json({error: "Cannot restore on the same device"});
        return;
      }

      // Get source user data
      const sourceUser = await db.collection("users").doc(sourceDeviceId).get();
      if (!sourceUser.exists) {
        res.status(404).json({error: "Source user not found"});
        return;
      }

      const userData = sourceUser.data()!;
      const balance = userData.balance || 0;
      const miroId = userData.miroId || "";

      // Collect profile data
      const syncDoc = await db
        .collection("user_sync")
        .doc(sourceDeviceId)
        .get();

      const profileData = syncDoc.exists ? syncDoc.data()?.profile || null : null;

      // Collect all synced food entries
      const syncLogs = await db
        .collection("user_sync")
        .doc(sourceDeviceId)
        .collection("daily_logs")
        .orderBy("updatedAt", "desc")
        .limit(90)
        .get();

      const allEntries: any[] = [];
      const allMeals: any[] = [];

      for (const logDoc of syncLogs.docs) {
        const logData = logDoc.data();
        if (logData.entries) allEntries.push(...logData.entries);
        if (logData.meals) allMeals.push(...logData.meals);
      }

      // De-duplicate entries by date+foodName (compact key 'dt'+'fn')
      const seen = new Set<string>();
      const uniqueEntries = allEntries.filter((e) => {
        const id = `${e.dt || ""}_${e.fn || ""}`;
        if (seen.has(id)) return false;
        seen.add(id);
        return true;
      });

      // Generate new recovery key for the new device
      const newKey = generateRecoveryKeyString();
      const newKeyHash = await bcrypt.hash(newKey, BCRYPT_ROUNDS);

      // Atomic transaction: transfer ownership
      await db.runTransaction(async (transaction) => {
        // Revoke old key
        transaction.update(matchedDoc!.ref, {
          status: "redeemed",
          redeemedAt: admin.firestore.FieldValue.serverTimestamp(),
          redeemedByDeviceId: newDeviceId,
        });

        // Create or update new device user
        const newUserRef = db.collection("users").doc(newDeviceId);
        const newUserDoc = await transaction.get(newUserRef);

        const transferData = {
          balance,
          miroId: miroId || (newUserDoc.exists ? newUserDoc.data()?.miroId : null),
          currentStreak: userData.currentStreak || 0,
          longestStreak: userData.longestStreak || 0,
          tier: userData.tier || "none",
          tierUnlockedAt: userData.tierUnlockedAt || {},
          totalEarned: userData.totalEarned || 0,
          totalSpent: userData.totalSpent || 0,
          totalPurchased: userData.totalPurchased || 0,
          hasRecoveryKey: true,
          recoveryKeyCreatedAt: admin.firestore.FieldValue.serverTimestamp(),
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        };

        if (newUserDoc.exists) {
          transaction.update(newUserRef, transferData);
        } else {
          transaction.set(newUserRef, {
            deviceId: newDeviceId,
            ...transferData,
            welcomeGiftClaimed: true,
            isBanned: false,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        }

        // Mark source user as transferred
        const sourceRef = db.collection("users").doc(sourceDeviceId);
        transaction.update(sourceRef, {
          balance: 0,
          transferredTo: newDeviceId,
          transferredAt: admin.firestore.FieldValue.serverTimestamp(),
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Register new key for new device
        const newKeyRef = db.collection("recovery_keys").doc();
        transaction.set(newKeyRef, {
          deviceId: newDeviceId,
          keyHash: newKeyHash,
          status: "active",
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      });

      console.log(
        `✅ [RedeemRecoveryKey] ${sourceDeviceId} → ${newDeviceId} ` +
          `(${uniqueEntries.length} entries, ${allMeals.length} meals, ${balance} energy)`
      );

      res.status(200).json({
        success: true,
        balance,
        miroId,
        entries: uniqueEntries,
        meals: allMeals,
        profile: profileData,
        newRecoveryKey: newKey,
      });
    } catch (error: any) {
      console.error("❌ [redeemRecoveryKey] Error:", error);
      res.status(500).json({error: error.message});
    }
  }
);
