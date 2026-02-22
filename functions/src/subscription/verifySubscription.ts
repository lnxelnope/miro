/**
 * verifySubscription
 *
 * เรียกเมื่อ:
 * 1. User subscribe ครั้งแรก
 * 2. App startup (verify ว่ายัง active อยู่)
 * 3. RTDN (Real-Time Developer Notification) จาก Google
 *
 * Input:  { deviceId, purchaseToken, productId }
 * Output: { success, status, expiryDate }
 */

import {onRequest} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import * as admin from "firebase-admin";
import {google} from "googleapis";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

const GOOGLE_SERVICE_ACCOUNT = defineSecret("GOOGLE_SERVICE_ACCOUNT_JSON");
const PACKAGE_NAME = "com.tanabun.miro";

const SUBSCRIPTION_PRODUCT_ID = "miro_normal_subscription";

export const verifySubscription = onRequest(
  {
    secrets: [GOOGLE_SERVICE_ACCOUNT],
    timeoutSeconds: 30,
    memory: "512MiB",
    cors: true,
  },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({error: "Method not allowed"});
      return;
    }

    try {
      const {deviceId, purchaseToken, productId} = req.body;

      if (!deviceId || !purchaseToken || !productId) {
        res.status(400).json({error: "Missing required fields"});
        return;
      }

      if (productId !== SUBSCRIPTION_PRODUCT_ID) {
        res.status(400).json({error: "Invalid product ID"});
        return;
      }

      console.log(`💎 [verifySubscription] Verifying subscription for ${deviceId}...`);

      // 1. Verify with Google Play Developer API
      const serviceAccount = JSON.parse(GOOGLE_SERVICE_ACCOUNT.value());
      const auth = new google.auth.GoogleAuth({
        credentials: serviceAccount,
        scopes: ["https://www.googleapis.com/auth/androidpublisher"],
      });

      const androidPublisher = google.androidpublisher({
        version: "v3",
        auth,
      });

      // Get subscription details
      const subscriptionResponse = await androidPublisher.purchases.subscriptions.get({
        packageName: PACKAGE_NAME,
        subscriptionId: productId,
        token: purchaseToken,
      });

      const subscription = subscriptionResponse.data;
      console.log("📦 [verifySubscription] Google Play response:", {
        kind: subscription.kind,
        startTimeMillis: subscription.startTimeMillis,
        expiryTimeMillis: subscription.expiryTimeMillis,
        autoRenewing: subscription.autoRenewing,
        paymentState: subscription.paymentState,
      });

      // 2. ตรวจสอบสถานะ
      const expiryTimeMillis = subscription.expiryTimeMillis || "0";
      const expiryDate = new Date(parseInt(expiryTimeMillis));
      const isActive = expiryDate > new Date();
      const paymentState = subscription.paymentState || 0; // 0 = payment pending, 1 = payment received

      let status: "active" | "grace_period" | "expired" | "cancelled";

      if (isActive && paymentState === 1) {
        status = "active";
      } else if (isActive && paymentState === 0) {
        status = "grace_period"; // Payment pending but still within grace period
      } else if (!subscription.autoRenewing) {
        status = "cancelled";
      } else {
        status = "expired";
      }

      // 3. อัพเดท user document
      const userRef = db.collection("users").doc(deviceId);
      const userDoc = await userRef.get();

      if (!userDoc.exists) {
        res.status(404).json({error: "User not found"});
        return;
      }

      const startTimeMillis = subscription.startTimeMillis || "0";
      const startDate = admin.firestore.Timestamp.fromMillis(
        parseInt(startTimeMillis)
      );
      const expiryTimestamp = admin.firestore.Timestamp.fromMillis(
        parseInt(expiryTimeMillis)
      );

      await userRef.update({
        "subscription.status": status,
        "subscription.productId": productId,
        "subscription.purchaseToken": purchaseToken,
        "subscription.startDate": startDate,
        "subscription.expiryDate": expiryTimestamp,
        "subscription.autoRenewing": subscription.autoRenewing || false,
        "subscription.lastVerifiedAt": admin.firestore.FieldValue.serverTimestamp(),
        "lastUpdated": admin.firestore.FieldValue.serverTimestamp(),
      });

      // Log transaction
      await db.collection("transactions").add({
        deviceId,
        miroId: userDoc.data()?.miroId || "unknown",
        type: "subscription",
        amount: 0, // Subscription doesn't add energy
        balanceAfter: userDoc.data()?.balance || 0,
        description: `Energy Pass subscription: ${status}`,
        metadata: {
          productId,
          status,
          expiryDate: expiryTimestamp.toDate().toISOString(),
          autoRenewing: subscription.autoRenewing || false,
        },
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`✅ [verifySubscription] Subscription verified: ${status}`);

      res.status(200).json({
        success: true,
        status,
        expiryDate: expiryDate.toISOString(),
        autoRenewing: subscription.autoRenewing || false,
      });
    } catch (error: any) {
      console.error("❌ [verifySubscription] Error:", error);

      // Handle specific Google Play API errors
      if (error.code === 400 || error.code === 401 || error.code === 404) {
        res.status(403).json({
          error: "Invalid subscription token",
          details: error.message,
        });
        return;
      }

      res.status(500).json({error: error.message});
    }
  }
);
