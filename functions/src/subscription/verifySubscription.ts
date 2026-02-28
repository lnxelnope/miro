/**
 * verifySubscription
 *
 * Android: Google Play API
 * iOS: Apple verifyReceipt API
 *
 * Input:  { deviceId, purchaseToken, productId, platform? }
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
const APPLE_SHARED_SECRET = defineSecret("APPLE_SHARED_SECRET");
const PACKAGE_NAME = "com.tanabun.miro";

const ANDROID_PRODUCT_ID = "miro_normal_subscription";
const IOS_PRODUCT_IDS = [
  "miro_energy_pass_weekly",
  "miro_energy_pass_monthly",
  "miro_energy_pass_yearly",
];

export const verifySubscription = onRequest(
  {
    secrets: [GOOGLE_SERVICE_ACCOUNT, APPLE_SHARED_SECRET],
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
      const {deviceId, purchaseToken, productId, platform = "android"} = req.body;
      const isIos = platform === "ios";

      if (!deviceId || !purchaseToken || !productId) {
        res.status(400).json({error: "Missing required fields"});
        return;
      }

      if (isIos) {
        if (!IOS_PRODUCT_IDS.includes(productId)) {
          res.status(400).json({error: "Invalid iOS product ID"});
          return;
        }
      } else {
        if (productId !== ANDROID_PRODUCT_ID) {
          res.status(400).json({error: "Invalid product ID"});
          return;
        }
      }

      console.log(`💎 [verifySubscription] Verifying for ${deviceId} (${platform})...`);

      let status: "active" | "grace_period" | "expired" | "cancelled";
      let expiryDate: Date;
      let autoRenewing: boolean;
      let startDate: admin.firestore.Timestamp;
      let expiryTimestamp: admin.firestore.Timestamp;

      if (isIos) {
        // ─── iOS: Apple verifyReceipt ───
        const sharedSecret = APPLE_SHARED_SECRET.value();
        const verifyBody = {
          "receipt-data": purchaseToken,
          password: sharedSecret,
          "exclude-old-transactions": false,
        };

        let appleRes = await fetch("https://buy.itunes.apple.com/verifyReceipt", {
          method: "POST",
          headers: {"Content-Type": "application/json"},
          body: JSON.stringify(verifyBody),
        });
        let appleData = await appleRes.json();

        if (appleData.status === 21007) {
          appleRes = await fetch("https://sandbox.itunes.apple.com/verifyReceipt", {
            method: "POST",
            headers: {"Content-Type": "application/json"},
            body: JSON.stringify(verifyBody),
          });
          appleData = await appleRes.json();
        }

        if (appleData.status !== 0) {
          console.log(`❌ [verifySubscription] Apple verifyReceipt failed: ${appleData.status}`);
          res.status(403).json({error: "Invalid receipt", status: appleData.status});
          return;
        }

        // Try latest_receipt_info first (auto-renewable subscriptions)
        // Then fallback to receipt.in_app
        const latestReceiptInfo = appleData.latest_receipt_info || appleData.receipt?.in_app || [];

        // Find the matching product with the latest expiry
        const matchingTxList = latestReceiptInfo
          .filter((tx: any) => IOS_PRODUCT_IDS.includes(tx.product_id));

        // If exact product not found, try any subscription product
        let matchingTx = matchingTxList
          .filter((tx: any) => tx.product_id === productId)
          .sort((a: any, b: any) => (b.expires_date_ms || 0) - (a.expires_date_ms || 0))[0];

        if (!matchingTx && matchingTxList.length > 0) {
          matchingTx = matchingTxList
            .sort((a: any, b: any) => (b.expires_date_ms || 0) - (a.expires_date_ms || 0))[0];
          console.log(`ℹ️ [verifySubscription] Using alt product: ${matchingTx.product_id} instead of ${productId}`);
        }

        if (!matchingTx) {
          console.log(`❌ [verifySubscription] No subscription product found in receipt`);
          console.log(`   Available products: ${latestReceiptInfo.map((tx: any) => tx.product_id).join(", ")}`);
          res.status(403).json({error: "Product not found in receipt"});
          return;
        }

        const expiryMs = parseInt(matchingTx.expires_date_ms || "0");
        const startMs = parseInt(matchingTx.purchase_date_ms || "0");
        expiryDate = new Date(expiryMs);
        const isActive = expiryDate > new Date();

        // Check auto_renew_status from pending_renewal_info
        const pendingRenewals = appleData.pending_renewal_info || [];
        const renewalInfo = pendingRenewals.find(
          (r: any) => r.product_id === matchingTx.product_id
        );
        const autoRenewStatus = renewalInfo?.auto_renew_status === "1";

        if (isActive && autoRenewStatus) {
          status = "active";
        } else if (isActive && !autoRenewStatus) {
          status = "cancelled";
        } else {
          status = "expired";
        }

        autoRenewing = autoRenewStatus;
        startDate = admin.firestore.Timestamp.fromMillis(startMs);
        expiryTimestamp = admin.firestore.Timestamp.fromMillis(expiryMs);

        console.log("📦 [verifySubscription] Apple receipt:", {
          productId: matchingTx.product_id,
          expiryDate: expiryDate.toISOString(),
          status,
          autoRenewing,
        });
      } else {
        // ─── Android: Google Play Developer API ───
        const serviceAccount = JSON.parse(GOOGLE_SERVICE_ACCOUNT.value());
        const auth = new google.auth.GoogleAuth({
          credentials: serviceAccount,
          scopes: ["https://www.googleapis.com/auth/androidpublisher"],
        });

        const androidPublisher = google.androidpublisher({
          version: "v3",
          auth,
        });

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

        const expiryTimeMillis = subscription.expiryTimeMillis || "0";
        expiryDate = new Date(parseInt(expiryTimeMillis));
        const isActive = expiryDate > new Date();
        const paymentState = subscription.paymentState || 0;

        if (isActive) {
          if (!subscription.autoRenewing) {
            status = "cancelled";
          } else if (paymentState === 0) {
            status = "grace_period";
          } else {
            status = "active";
          }
        } else {
          status = "expired";
        }

        autoRenewing = subscription.autoRenewing || false;
        const startTimeMillis = subscription.startTimeMillis || "0";
        startDate = admin.firestore.Timestamp.fromMillis(parseInt(startTimeMillis));
        expiryTimestamp = admin.firestore.Timestamp.fromMillis(parseInt(expiryTimeMillis));
      }

      // ─── Common: Update Firestore ───
      const userRef = db.collection("users").doc(deviceId);
      const userDoc = await userRef.get();

      if (!userDoc.exists) {
        res.status(404).json({error: "User not found"});
        return;
      }

      await userRef.update({
        "subscription.status": status,
        "subscription.productId": productId,
        "subscription.purchaseToken": purchaseToken,
        "subscription.startDate": startDate,
        "subscription.expiryDate": expiryTimestamp,
        "subscription.autoRenewing": autoRenewing,
        "subscription.lastVerifiedAt": admin.firestore.FieldValue.serverTimestamp(),
        "lastUpdated": admin.firestore.FieldValue.serverTimestamp(),
      });

      await db.collection("transactions").add({
        deviceId,
        miroId: userDoc.data()?.miroId || "unknown",
        type: "subscription",
        amount: 0,
        balanceAfter: userDoc.data()?.balance || 0,
        description: `Energy Pass subscription: ${status}`,
        metadata: {
          productId,
          status,
          expiryDate: expiryTimestamp.toDate().toISOString(),
          autoRenewing,
        },
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`✅ [verifySubscription] Subscription verified: ${status}`);

      res.status(200).json({
        success: true,
        status,
        expiryDate: expiryDate.toISOString(),
        autoRenewing,
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
