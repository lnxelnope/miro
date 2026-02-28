# Phase 5 - Task 1: Subscription System (Backend)

**Status:** 📝 Ready for Implementation  
**Estimated Time:** 8-10 hours  
**Difficulty:** ⭐⭐⭐⭐⭐ Hard  
**Prerequisites:** Phase 1-4 must be completed

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Requirements](#requirements)
3. [Architecture](#architecture)
4. [Step-by-Step Implementation](#step-by-step-implementation)
5. [Testing](#testing)
6. [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

Subscription system สำหรับ **Energy Pass** (149 THB/month):

**Benefits:**
- ✅ Unlimited AI analysis (no energy cost)
- ✅ Double streak rewards
- ✅ Exclusive badge
- ✅ Priority support (optional)

**Technical Implementation:**
- Google Play Billing Library v6+
- Server-side receipt verification
- RTDN (Real-time Developer Notifications)
- Subscription lifecycle management

---

## 📊 Requirements

### Google Play Console Setup
- [x] สร้าง Product ID: `energy_pass_monthly` (149 THB/month)
- [x] Status: Active
- [x] Auto-renewing subscription
- [x] Set up RTDN (Real-time Developer Notifications)

### Backend Implementation
- [x] Deploy `verifySubscription` function
- [x] Deploy `handleRTDN` function
- [x] Add `GOOGLE_SERVICE_ACCOUNT_JSON` secret
- [x] Set up `.env` with License Key
- [x] Update `.gitignore` for secrets
- [x] Configure Pub/Sub topic and permissions

### Frontend Implementation (Flutter)
- [x] Add `cloud_firestore` dependency
- [x] Create subscription models (Status, Data, Plan)
- [x] Create SubscriptionService (Google Play Billing)
- [x] Create SubscriptionProvider (Riverpod)
- [x] Create Subscription Screen UI
- [x] Create Subscriber Badge widget
- [x] Integrate unlimited AI (no energy deduction)
- [x] Create SubscriptionAwareGeminiService wrapper

### Functional Requirements
- [x] Server verify purchase receipt
- [x] Grant subscription benefits (update Firestore)
- [x] Handle subscription renewal (via RTDN)
- [x] Handle subscription cancellation (via RTDN)
- [x] Handle subscription expiry (via RTDN)
- [x] RTDN webhook setup (Google Play → Pub/Sub → Cloud Function)
- [ ] User สามารถซื้อ subscription ผ่าน Google Play (Flutter app) - **Ready for testing**

### Non-Functional Requirements
- [ ] Receipt verification < 3 seconds
- [ ] 100% accurate subscription status
- [ ] Handle RTDN within 30 seconds
- [ ] Prevent fraud (duplicate purchases, fake receipts)

---

## 🏗️ Architecture

### Subscription Flow

```
┌─────────────┐
│  User       │
└──────┬──────┘
       │ 1. Tap "Subscribe" in app
       ▼
┌─────────────┐
│  Flutter    │
└──────┬──────┘
       │ 2. Launch Google Play Billing
       ▼
┌─────────────┐
│ Google Play │
└──────┬──────┘
       │ 3. User pays 149 THB
       │ 4. Return purchaseToken
       ▼
┌─────────────┐
│  Flutter    │
└──────┬──────┘
       │ 5. POST /verifySubscription
       │    { deviceId, purchaseToken, productId }
       ▼
┌─────────────┐
│  Server     │
└──────┬──────┘
       │ 6. Verify with Google Play API
       │ 7. Check subscription status
       │ 8. Grant benefits
       │ 9. Store subscription record
       ▼
    ✅ Active Subscription

┌─────────────┐
│ Google RTDN │ (Real-time Notifications)
└──────┬──────┘
       │ When: Renewal, Cancellation, Expiry
       │ POST /handleRTDN
       ▼
┌─────────────┐
│  Server     │
└──────┬──────┘
       │ Update subscription status
       │ Revoke benefits if expired
       ▼
    ✅ Updated
```

### Firestore Schema

**Collection: `subscriptions/{subscriptionId}`**

```typescript
interface Subscription {
  deviceId: string;
  miroId: string;
  productId: string;              // "energy_pass_monthly"
  purchaseToken: string;           // From Google Play
  orderId: string;                 // From Google Play
  status: 'active' | 'cancelled' | 'expired' | 'paused' | 'pending';
  
  // Dates
  purchaseTime: Timestamp;
  expiryTime: Timestamp;
  startTime: Timestamp;
  
  // Verification
  verifiedAt: Timestamp;
  lastVerifiedAt: Timestamp;
  
  // RTDN
  notificationTypes: string[];     // ["SUBSCRIPTION_PURCHASED", "SUBSCRIPTION_RENEWED", ...]
  lastNotificationAt: Timestamp | null;
  
  // Benefits
  benefitsGranted: {
    unlimitedAi: boolean;
    doubleRewards: boolean;
    badge: boolean;
  };
  
  // Metadata
  autoRenewing: boolean;
  canceledAt: Timestamp | null;
  cancelReason: string | null;
}
```

---

## 🚀 Step-by-Step Implementation

### Step 1: Setup Google Play Developer API

#### 1.1 Enable API

1. ไปที่ [Google Cloud Console](https://console.cloud.google.com/)
2. เลือกโปรเจคของคุณ
3. Enable **Google Play Android Developer API**

#### 1.2 Create Service Account

1. ไปที่ IAM & Admin → Service Accounts
2. Create Service Account
3. Grant permissions: **Service Account User**
4. Create JSON key

#### 1.3 Link to Play Console

1. ไปที่ [Play Console](https://play.google.com/console/)
2. Setup → API access
3. Link service account ที่สร้างไว้
4. Grant permissions: **View financial data**, **Manage orders and subscriptions**

#### 1.4 Add Service Account Key to Firebase

```bash
cd functions
mkdir -p secrets
# วาง service account JSON ไฟล์ที่นี่
cp ~/Downloads/service-account-key.json secrets/google-play-service-account.json

# เพิ่ม to .gitignore
echo "secrets/" >> .gitignore
```

---

### Step 2: Create Product in Play Console

#### 2.1 Create Subscription

1. ไปที่ Play Console → Your App → Monetization → Subscriptions
2. Create subscription product:
   - **Product ID:** `energy_pass_monthly`
   - **Name:** Energy Pass (Monthly)
   - **Description:** Unlimited AI analysis + Double rewards
   - **Price:** 149 THB
   - **Billing period:** 1 month
   - **Free trial:** 7 days (optional)

---

### Step 3: Implement verifySubscription Function

#### 3.1 Install Dependencies

```bash
cd functions
npm install googleapis@latest
```

#### 3.2 Create Function

**File:** `functions/src/subscription/verifySubscription.ts`

```typescript
import { onRequest } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { google } from 'googleapis';
import * as fs from 'fs';
import * as path from 'path';

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

// Load service account
const serviceAccountPath = path.join(__dirname, '..', 'secrets', 'google-play-service-account.json');
const serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'));

// Google Play API client
const auth = new google.auth.GoogleAuth({
  credentials: serviceAccount,
  scopes: ['https://www.googleapis.com/auth/androidpublisher'],
});

const androidpublisher = google.androidpublisher('v3');

const PACKAGE_NAME = 'com.yourapp.miro'; // แก้ให้ตรงกับ package name

export const verifySubscription = onRequest(
  {
    timeoutSeconds: 30,
    memory: '512MiB',
    cors: true,
  },
  async (req, res) => {
    try {
      const { deviceId, purchaseToken, productId } = req.body;

      // 1. Validate inputs
      if (!deviceId || !purchaseToken || !productId) {
        res.status(400).json({ error: 'Missing required fields' });
        return;
      }

      // 2. Get user
      const userDoc = await db.collection('users').doc(deviceId).get();
      if (!userDoc.exists) {
        res.status(404).json({ error: 'User not found' });
        return;
      }

      const user = userDoc.data()!;

      // 3. Verify purchase with Google Play API
      const authClient = await auth.getClient();
      
      const response = await androidpublisher.purchases.subscriptions.get({
        auth: authClient,
        packageName: PACKAGE_NAME,
        subscriptionId: productId,
        token: purchaseToken,
      });

      const subscription = response.data;

      // 4. Check subscription status
      const expiryTimeMillis = parseInt(subscription.expiryTimeMillis || '0');
      const now = Date.now();
      const isActive = expiryTimeMillis > now;

      if (!isActive) {
        res.status(400).json({ error: 'Subscription expired or invalid' });
        return;
      }

      // 5. Check for duplicate purchase token
      const existingSubSnapshot = await db
        .collection('subscriptions')
        .where('purchaseToken', '==', purchaseToken)
        .limit(1)
        .get();

      let subscriptionId: string;

      if (!existingSubSnapshot.empty) {
        // อัพเดท subscription ที่มีอยู่
        const existingDoc = existingSubSnapshot.docs[0];
        subscriptionId = existingDoc.id;

        await existingDoc.ref.update({
          status: 'active',
          expiryTime: admin.firestore.Timestamp.fromMillis(expiryTimeMillis),
          lastVerifiedAt: admin.firestore.FieldValue.serverTimestamp(),
          autoRenewing: subscription.autoRenewing ?? true,
        });
      } else {
        // สร้าง subscription record ใหม่
        const subRef = db.collection('subscriptions').doc();
        subscriptionId = subRef.id;

        await subRef.set({
          deviceId,
          miroId: user.miroId,
          productId,
          purchaseToken,
          orderId: subscription.orderId || '',
          status: 'active',
          purchaseTime: admin.firestore.Timestamp.fromMillis(
            parseInt(subscription.startTimeMillis || '0')
          ),
          expiryTime: admin.firestore.Timestamp.fromMillis(expiryTimeMillis),
          startTime: admin.firestore.Timestamp.fromMillis(
            parseInt(subscription.startTimeMillis || '0')
          ),
          verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
          lastVerifiedAt: admin.firestore.FieldValue.serverTimestamp(),
          notificationTypes: [],
          lastNotificationAt: null,
          benefitsGranted: {
            unlimitedAi: true,
            doubleRewards: true,
            badge: true,
          },
          autoRenewing: subscription.autoRenewing ?? true,
          canceledAt: null,
          cancelReason: null,
        });
      }

      // 6. Grant benefits to user
      await db.collection('users').doc(deviceId).update({
        'subscription.active': true,
        'subscription.productId': productId,
        'subscription.expiryTime': admin.firestore.Timestamp.fromMillis(expiryTimeMillis),
        'subscription.subscriptionId': subscriptionId,
      });

      console.log(`✅ [Subscription] Verified for ${user.miroId}: ${productId}`);

      res.status(200).json({
        success: true,
        subscription: {
          id: subscriptionId,
          productId,
          expiryTime: new Date(expiryTimeMillis).toISOString(),
          autoRenewing: subscription.autoRenewing,
        },
      });
    } catch (error: any) {
      console.error('❌ [verifySubscription] Error:', error);
      
      if (error.code === 401) {
        res.status(401).json({ error: 'Invalid purchase token or not found' });
      } else {
        res.status(500).json({ error: error.message });
      }
    }
  }
);
```

---

### Step 4: Implement RTDN Handler

#### 4.1 Setup RTDN in Play Console

1. ไปที่ Play Console → Your App → Monetization → Monetization setup
2. Enable Real-time developer notifications
3. Topic name: `your-project-rtdn`
4. Create Cloud Pub/Sub topic

#### 4.2 Create RTDN Handler

**File:** `functions/src/subscription/handleRTDN.ts`

```typescript
import { onRequest } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

/**
 * handleRTDN
 * 
 * Webhook สำหรับ Google Play RTDN
 * จะถูกเรียกเมื่อ subscription status เปลี่ยน
 */
export const handleRTDN = onRequest(
  {
    timeoutSeconds: 60,
    memory: '256MiB',
  },
  async (req, res) => {
    try {
      // Pub/Sub message format
      const message = req.body.message;
      
      if (!message || !message.data) {
        res.status(400).send('No message data');
        return;
      }

      // Decode base64
      const dataString = Buffer.from(message.data, 'base64').toString('utf-8');
      const notification = JSON.parse(dataString);

      console.log('📨 [RTDN] Received:', notification);

      // Extract notification details
      const subscriptionNotification = notification.subscriptionNotification;
      
      if (!subscriptionNotification) {
        res.status(200).send('Not a subscription notification');
        return;
      }

      const {
        version,
        notificationType,
        purchaseToken,
        subscriptionId,
      } = subscriptionNotification;

      // หา subscription record
      const subSnapshot = await db
        .collection('subscriptions')
        .where('purchaseToken', '==', purchaseToken)
        .limit(1)
        .get();

      if (subSnapshot.empty) {
        console.log('⚠️ [RTDN] Subscription not found');
        res.status(200).send('Subscription not found');
        return;
      }

      const subDoc = subSnapshot.docs[0];
      const subscription = subDoc.data();

      // Handle notification types
      switch (notificationType) {
        case 1: // SUBSCRIPTION_RECOVERED
          await handleRecovered(subDoc, subscription);
          break;

        case 2: // SUBSCRIPTION_RENEWED
          await handleRenewed(subDoc, subscription);
          break;

        case 3: // SUBSCRIPTION_CANCELED
          await handleCanceled(subDoc, subscription);
          break;

        case 4: // SUBSCRIPTION_PURCHASED
          await handlePurchased(subDoc, subscription);
          break;

        case 5: // SUBSCRIPTION_ON_HOLD
          await handleOnHold(subDoc, subscription);
          break;

        case 6: // SUBSCRIPTION_IN_GRACE_PERIOD
          await handleGracePeriod(subDoc, subscription);
          break;

        case 7: // SUBSCRIPTION_RESTARTED
          await handleRestarted(subDoc, subscription);
          break;

        case 10: // SUBSCRIPTION_PAUSE_SCHEDULE_CHANGED
          await handlePauseScheduleChanged(subDoc, subscription);
          break;

        case 12: // SUBSCRIPTION_REVOKED
          await handleRevoked(subDoc, subscription);
          break;

        case 13: // SUBSCRIPTION_EXPIRED
          await handleExpired(subDoc, subscription);
          break;

        default:
          console.log(`⚠️ [RTDN] Unknown notification type: ${notificationType}`);
      }

      // Update notification log
      await subDoc.ref.update({
        notificationTypes: admin.firestore.FieldValue.arrayUnion(`${notificationType}`),
        lastNotificationAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      res.status(200).send('OK');
    } catch (error: any) {
      console.error('❌ [RTDN] Error:', error);
      res.status(500).json({ error: error.message });
    }
  }
);

// Handler functions

async function handleRecovered(subDoc: any, subscription: any) {
  await subDoc.ref.update({
    status: 'active',
  });
  
  await db.collection('users').doc(subscription.deviceId).update({
    'subscription.active': true,
  });
  
  console.log(`✅ [RTDN] Subscription recovered: ${subscription.miroId}`);
}

async function handleRenewed(subDoc: any, subscription: any) {
  // Subscription auto-renewed
  console.log(`🔄 [RTDN] Subscription renewed: ${subscription.miroId}`);
  
  // อาจต้อง fetch expiry time ใหม่จาก Google Play API
  // และอัพเดท expiryTime
}

async function handleCanceled(subDoc: any, subscription: any) {
  await subDoc.ref.update({
    status: 'cancelled',
    canceledAt: admin.firestore.FieldValue.serverTimestamp(),
    autoRenewing: false,
  });
  
  console.log(`❌ [RTDN] Subscription canceled: ${subscription.miroId}`);
  
  // ยังใช้งานได้จนกว่าจะหมดอายุ
}

async function handlePurchased(subDoc: any, subscription: any) {
  console.log(`🎉 [RTDN] New subscription: ${subscription.miroId}`);
}

async function handleOnHold(subDoc: any, subscription: any) {
  await subDoc.ref.update({
    status: 'paused',
  });
  
  await db.collection('users').doc(subscription.deviceId).update({
    'subscription.active': false,
  });
  
  console.log(`⏸️ [RTDN] Subscription on hold: ${subscription.miroId}`);
}

async function handleGracePeriod(subDoc: any, subscription: any) {
  console.log(`⏰ [RTDN] Grace period: ${subscription.miroId}`);
  // ให้ใช้งานต่อชั่วคราว
}

async function handleRestarted(subDoc: any, subscription: any) {
  await subDoc.ref.update({
    status: 'active',
  });
  
  await db.collection('users').doc(subscription.deviceId).update({
    'subscription.active': true,
  });
  
  console.log(`▶️ [RTDN] Subscription restarted: ${subscription.miroId}`);
}

async function handlePauseScheduleChanged(subDoc: any, subscription: any) {
  console.log(`📅 [RTDN] Pause schedule changed: ${subscription.miroId}`);
}

async function handleRevoked(subDoc: any, subscription: any) {
  await subDoc.ref.update({
    status: 'expired',
  });
  
  await db.collection('users').doc(subscription.deviceId).update({
    'subscription.active': false,
  });
  
  console.log(`🚫 [RTDN] Subscription revoked: ${subscription.miroId}`);
}

async function handleExpired(subDoc: any, subscription: any) {
  await subDoc.ref.update({
    status: 'expired',
  });
  
  await db.collection('users').doc(subscription.deviceId).update({
    'subscription.active': false,
  });
  
  console.log(`⏰ [RTDN] Subscription expired: ${subscription.miroId}`);
}
```

---

### Step 5: Update analyzeFood for Unlimited AI

แก้ไข `analyzeFood.ts` ให้ไม่ deduct energy ถ้ามี active subscription:

```typescript
// ใน analyzeFood.ts:

// เช็คว่ามี subscription หรือไม่
const hasActiveSubscription = user.subscription?.active === true &&
  user.subscription?.expiryTime?.toDate() > new Date();

// ถ้ามี subscription → ไม่ต้อง deduct energy
if (hasActiveSubscription) {
  console.log(`✨ [Subscription] Free AI for ${user.miroId}`);
} else {
  // Deduct energy ตามปกติ
  await deductEnergy(deviceId, energyCost);
}
```

---

### Step 6: Deploy Functions

```bash
cd functions

# Deploy
firebase deploy --only functions:verifySubscription
firebase deploy --only functions:handleRTDN

# ตรวจสอบ
firebase functions:log --only verifySubscription
```

---

## 🧪 Testing

### Test verifySubscription

```bash
curl -X POST https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/verifySubscription \
  -H "Content-Type: application/json" \
  -d '{
    "deviceId": "TEST_DEVICE",
    "purchaseToken": "GOOGLE_PLAY_TOKEN",
    "productId": "energy_pass_monthly"
  }'
```

### Test RTDN

ใช้ [Google Play Console Test Notifications](https://developer.android.com/google/play/billing/test)

---

## ✅ Completion Checklist

- [ ] Google Play Developer API enabled
- [ ] Service account created and linked
- [ ] Subscription product created in Play Console
- [ ] verifySubscription function deployed
- [ ] handleRTDN function deployed
- [ ] RTDN configured in Play Console
- [ ] analyzeFood updated for unlimited AI
- [ ] Test purchase flow
- [ ] Test RTDN notifications

---

**Documentation Version:** 1.0  
**Last Updated:** 2026-02-17  
**Author:** Senior Developer  
**For:** Junior Developer