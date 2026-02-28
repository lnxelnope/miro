/**
 * handleRTDN
 *
 * Real-Time Developer Notification จาก Google Play
 * เมื่อ subscription status เปลี่ยน (renewed, cancelled, expired, etc.)
 *
 * Setup: Configure RTDN endpoint ใน Google Play Console
 * URL: https://us-central1-miro-d6856.cloudfunctions.net/handleRTDN
 *
 * Note: RTDN arrives via Pub/Sub → message.data is base64-encoded JSON
 */

import {onRequest} from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

interface RTDNMessage {
  version: string;
  packageName: string;
  eventTimeMillis: string;
  subscriptionNotification?: {
    version: string;
    notificationType: number;
    purchaseToken: string;
    subscriptionId: string;
  };
}

/**
 * RTDN Notification Types:
 * 1 = SUBSCRIPTION_RECOVERED
 * 2 = SUBSCRIPTION_RENEWED
 * 3 = SUBSCRIPTION_CANCELED
 * 4 = SUBSCRIPTION_PURCHASED
 * 5 = SUBSCRIPTION_ON_HOLD
 * 6 = SUBSCRIPTION_IN_GRACE_PERIOD
 * 7 = SUBSCRIPTION_RESTARTED
 * 8 = SUBSCRIPTION_PRICE_CHANGE_CONFIRMED
 * 9 = SUBSCRIPTION_DEFERRED
 * 10 = SUBSCRIPTION_PAUSED
 * 11 = SUBSCRIPTION_PAUSE_SCHEDULE_CHANGED
 * 12 = SUBSCRIPTION_REVOKED
 * 13 = SUBSCRIPTION_EXPIRED
 */

export const handleRTDN = onRequest(
  {
    timeoutSeconds: 30,
    memory: "256MiB",
    cors: true,
  },
  async (req, res) => {
    try {
      // Pub/Sub sends base64-encoded data in message.data
      let message: RTDNMessage;
      if (req.body.message?.data) {
        const decoded = Buffer.from(req.body.message.data, "base64").toString("utf-8");
        message = JSON.parse(decoded) as RTDNMessage;
      } else {
        message = req.body.message || req.body;
      }

      if (!message.subscriptionNotification) {
        console.log("⚠️ [RTDN] No subscription notification in message");
        res.status(200).json({received: true});
        return;
      }

      const notification = message.subscriptionNotification;
      const {purchaseToken, subscriptionId, notificationType} = notification;

      console.log(
        `📬 [RTDN] Received notification: type=${notificationType}, product=${subscriptionId}`
      );

      // Find user by purchaseToken
      const usersSnapshot = await db
        .collection("users")
        .where("subscription.purchaseToken", "==", purchaseToken)
        .limit(1)
        .get();

      if (usersSnapshot.empty) {
        console.log(`⚠️ [RTDN] No user found with purchaseToken`);
        res.status(200).json({received: true});
        return;
      }

      const userDoc = usersSnapshot.docs[0];
      const deviceId = userDoc.id;

      let status: "active" | "grace_period" | "expired" | "cancelled" = "active";
      const updateData: Record<string, any> = {
        "subscription.lastVerifiedAt": admin.firestore.FieldValue.serverTimestamp(),
        "lastUpdated": admin.firestore.FieldValue.serverTimestamp(),
      };

      switch (notificationType) {
      case 1: // SUBSCRIPTION_RECOVERED
      case 2: // SUBSCRIPTION_RENEWED
      case 4: // SUBSCRIPTION_PURCHASED
      case 7: // SUBSCRIPTION_RESTARTED
        status = "active";
        updateData["subscription.status"] = status;
        updateData["subscription.autoRenewing"] = true;
        console.log(`✅ [RTDN] Subscription active: ${deviceId} (type=${notificationType})`);
        break;

      case 3: // SUBSCRIPTION_CANCELED
        status = "cancelled";
        updateData["subscription.status"] = status;
        updateData["subscription.autoRenewing"] = false;
        updateData["subscription.cancelledAt"] = admin.firestore.FieldValue.serverTimestamp();
        console.log(`❌ [RTDN] Subscription cancelled: ${deviceId}`);
        break;

      case 5: // SUBSCRIPTION_ON_HOLD
      case 10: // SUBSCRIPTION_PAUSED
        status = "grace_period";
        updateData["subscription.status"] = status;
        updateData["subscription.autoRenewing"] = false;
        console.log(`⏸️ [RTDN] Subscription on hold/paused: ${deviceId}`);
        break;

      case 6: // SUBSCRIPTION_IN_GRACE_PERIOD
        status = "grace_period";
        updateData["subscription.status"] = status;
        console.log(`⏳ [RTDN] Subscription in grace period: ${deviceId}`);
        break;

      case 9: // SUBSCRIPTION_DEFERRED
        console.log(`ℹ️ [RTDN] Subscription deferred: ${deviceId}`);
        res.status(200).json({received: true});
        return;

      case 8: // SUBSCRIPTION_PRICE_CHANGE_CONFIRMED
      case 11: // SUBSCRIPTION_PAUSE_SCHEDULE_CHANGED
        console.log(`ℹ️ [RTDN] Info notification: type=${notificationType}`);
        res.status(200).json({received: true});
        return;

      case 12: // SUBSCRIPTION_REVOKED
      case 13: // SUBSCRIPTION_EXPIRED
        status = "expired";
        updateData["subscription.status"] = status;
        updateData["subscription.autoRenewing"] = false;
        updateData["subscription.expiredAt"] = admin.firestore.FieldValue.serverTimestamp();
        console.log(`💔 [RTDN] Subscription expired/revoked: ${deviceId}`);
        break;

      default:
        console.log(`ℹ️ [RTDN] Unhandled notification type: ${notificationType}`);
        res.status(200).json({received: true});
        return;
      }

      await userDoc.ref.update(updateData);

      // Log event
      await db.collection("subscription_events").add({
        deviceId,
        miroId: userDoc.data()?.miroId || "unknown",
        notificationType,
        purchaseToken: purchaseToken.substring(0, 20) + "...",
        subscriptionId,
        status,
        eventTime: admin.firestore.Timestamp.fromMillis(
          parseInt(message.eventTimeMillis)
        ),
        receivedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      res.status(200).json({received: true, status});
    } catch (error: any) {
      console.error("❌ [RTDN] Error:", error);
      res.status(500).json({error: error.message});
    }
  }
);
