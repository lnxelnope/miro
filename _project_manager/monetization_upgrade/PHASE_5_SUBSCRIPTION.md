# Phase 5: Subscription + Events — คู่มือ Implementation

**Scope:** Energy Pass Subscription + Seasonal Events + Social Features + iOS IAP  
**ระยะเวลา:** 2+ สัปดาห์ (ongoing)  
**ต้องทำ Phase 1-4 เสร็จก่อน**

---

## สารบัญ

- [Task 1: Energy Pass Subscription](#task-1-energy-pass-subscription)
- [Task 2: Seasonal Events](#task-2-seasonal-events)
- [Task 3: Social Features](#task-3-social-features)
- [Task 4: iOS IAP Integration](#task-4-ios-iap-integration)
- [Task 5: Energy Expiry (Optional)](#task-5-energy-expiry-optional)
- [Task 6: Testing Checklist](#task-6-testing-checklist)

---

## Task 1: Energy Pass Subscription

### 1.1 Product Definition

```
┌──────────────────────────────────────────┐
│  ⚡ Energy Pass — 149 THB/month          │
│  ────────────────────────────────────    │
│  ✅ Unlimited AI analysis (no energy)    │
│  ✅ Double streak rewards                │
│  ✅ Double challenge rewards             │
│  ✅ Exclusive 💎 Pass badge              │
│  ✅ Priority support                     │
│  ✅ No ads (ถ้ามี ads)                   │
│                                          │
│  [Subscribe — ฿149/month]               │
└──────────────────────────────────────────┘
```

### 1.2 Google Play Subscription Setup

```
Product ID: energy_pass_monthly
Type: Auto-renewable subscription
Price: ฿149/month (THB)
Free trial: 3 days (optional)
Grace period: 3 days
```

### 1.3 Firestore Schema

```typescript
// เพิ่มใน users/{deviceId}:
subscription: {
  status: 'none' | 'active' | 'grace_period' | 'expired' | 'cancelled';
  productId: string | null;
  purchaseToken: string | null;
  startDate: Timestamp | null;
  expiryDate: Timestamp | null;
  isTrialUsed: boolean;
  lastVerifiedAt: Timestamp | null;
};
```

### 1.4 Cloud Function: verifySubscription

```typescript
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

import { onRequest } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';

const db = admin.firestore();

export const verifySubscription = onRequest(
  {
    timeoutSeconds: 30,
    memory: '256MiB',
    cors: '*',
  },
  async (req, res) => {
    try {
      const { deviceId, purchaseToken, productId } = req.body;

      // 1. Verify with Google Play Developer API
      //    (คล้ายกับ verifyPurchase.ts แต่ใช้ subscriptions API)

      // const subscription = await androidPublisher.purchases.subscriptionsv2.get({
      //   packageName: 'com.miro.app',
      //   token: purchaseToken,
      // });

      // 2. ตรวจสอบสถานะ
      // const expiryTimeMillis = subscription.data.lineItems[0].expiryTime;
      // const isActive = new Date(expiryTimeMillis) > new Date();

      // 3. อัพเดท user document
      // await db.collection('users').doc(deviceId).update({
      //   'subscription.status': isActive ? 'active' : 'expired',
      //   'subscription.productId': productId,
      //   'subscription.purchaseToken': purchaseToken,
      //   'subscription.expiryDate': admin.firestore.Timestamp.fromMillis(expiryTimeMillis),
      //   'subscription.lastVerifiedAt': admin.firestore.FieldValue.serverTimestamp(),
      // });

      // Placeholder response:
      res.status(200).json({
        success: true,
        status: 'active',
        expiryDate: new Date(Date.now() + 30 * 86400000).toISOString(),
      });
    } catch (error: any) {
      console.error('❌ [verifySubscription]', error);
      res.status(500).json({ error: error.message });
    }
  }
);
```

### 1.5 Impact บน analyzeFood

```typescript
// ใน analyzeFood.ts — เพิ่มเช็ค subscription ก่อนเช็ค free AI:

// 1. เช็ค subscription ก่อน
const user = await db.collection('users').doc(deviceId).get();
const subscription = user.data()?.subscription;

if (subscription?.status === 'active') {
  // Subscriber → ใช้ AI ฟรีไม่จำกัด!
  console.log(`💎 [analyzeFood] Subscriber ${deviceId} — free unlimited!`);

  // เรียก Gemini API ได้เลย
  // ... call Gemini ...

  // บันทึก transaction (type = 'subscription_usage')
  // ไม่หัก energy

  // ยังนับ challenge progress:
  await incrementChallengeProgress(deviceId, 'logMeals');
  await incrementChallengeProgress(deviceId, 'useAi');

  // ยังนับ check-in (streak):
  await processCheckIn(deviceId, timezoneOffset);

  res.status(200).json({
    success: true,
    data: geminiResponse,
    balance: user.data()?.balance, // ไม่เปลี่ยน
    energyUsed: 0,
    energyCost: 0,
    isSubscriber: true,
  });
  return;
}

// 2. ไม่ใช่ subscriber → เช็ค free AI (เหมือนเดิม)
// ...
```

### 1.6 Double Rewards for Subscribers

```typescript
// ใน processCheckIn (dailyCheckIn.ts):

// เช็คว่าเป็น subscriber หรือไม่
const isSubscriber = user.subscription?.status === 'active';

// Streak tier bonus
let energyBonus = TIER_CONFIG[newTier].energy;
if (isSubscriber) {
  energyBonus *= 2; // Double!
}

// ใน completeChallenge:
let reward = config.reward;
if (isSubscriber) {
  reward *= 2; // Double!
}
```

### 1.7 RTDN (Real-Time Developer Notification)

```typescript
/**
 * Google Play sends RTDN เมื่อ subscription status เปลี่ยน:
 * - SUBSCRIPTION_PURCHASED
 * - SUBSCRIPTION_RENEWED
 * - SUBSCRIPTION_CANCELED
 * - SUBSCRIPTION_EXPIRED
 * - SUBSCRIPTION_REVOKED
 *
 * Setup: Google Cloud Pub/Sub → Cloud Function trigger
 */

import { onMessagePublished } from 'firebase-functions/v2/pubsub';

export const handleSubscriptionEvent = onMessagePublished(
  { topic: 'play-subscription-events' },
  async (event) => {
    const data = event.data.message.json;
    const { subscriptionNotification } = data;

    if (!subscriptionNotification) return;

    const { purchaseToken, notificationType } = subscriptionNotification;

    // หา user จาก purchaseToken
    const userSnapshot = await db
      .collection('users')
      .where('subscription.purchaseToken', '==', purchaseToken)
      .limit(1)
      .get();

    if (userSnapshot.empty) {
      console.error('User not found for purchaseToken');
      return;
    }

    const userDoc = userSnapshot.docs[0];

    switch (notificationType) {
      case 4: // SUBSCRIPTION_PURCHASED
      case 2: // SUBSCRIPTION_RENEWED
        await userDoc.ref.update({
          'subscription.status': 'active',
          'subscription.lastVerifiedAt': admin.firestore.FieldValue.serverTimestamp(),
        });
        break;

      case 3: // SUBSCRIPTION_CANCELED
        await userDoc.ref.update({
          'subscription.status': 'cancelled',
        });
        break;

      case 13: // SUBSCRIPTION_EXPIRED
        await userDoc.ref.update({
          'subscription.status': 'expired',
        });
        break;

      case 12: // SUBSCRIPTION_REVOKED
        await userDoc.ref.update({
          'subscription.status': 'expired',
        });
        break;
    }
  }
);
```

### 1.8 Checklist

```
□ สร้าง Google Play subscription product
□ สร้าง verifySubscription Cloud Function
□ สร้าง handleSubscriptionEvent (Pub/Sub)
□ แก้ไข analyzeFood (subscription check ก่อน free AI)
□ แก้ไข processCheckIn (double rewards)
□ แก้ไข completeChallenge (double rewards)
□ Flutter: subscription purchase flow (revenue_cat หรือ in_app_purchase)
□ Flutter: subscriber badge UI
□ Flutter: subscription management (cancel, restore)
□ ทดสอบ: subscribe → unlimited AI
□ ทดสอบ: cancel → กลับเป็น energy-based
□ ทดสอบ: renew → status active
□ ทดสอบ: double rewards ถูกต้อง
```

---

## Task 2: Seasonal Events

### 2.1 Event System

```typescript
// Firestore: events/{eventId}
interface SeasonalEvent {
  eventId: string;
  name: string;                     // "Songkran Special"
  description: string;
  startDate: string;                // "2026-04-13"
  endDate: string;                  // "2026-04-20"
  status: 'upcoming' | 'active' | 'ended';
  rewards: {
    doubleStreakRewards: boolean;
    tripleChallengeRewards: boolean;
    specialRandomBonus: {
      chance: number;               // e.g. 0.15 (15%)
      minReward: number;
      maxReward: number;
    };
    specialPackages: {
      productId: string;
      name: string;
      energy: number;
      price: number;
      bonusRate: number;            // e.g. 0.50 (50% bonus)
    }[];
  };
  badge: {
    name: string;                   // "Songkran 2026"
    emoji: string;                  // "🎉"
    requirement: string;            // "Log 10 meals during event"
  } | null;
  ui: {
    bannerImage: string;            // URL to banner image
    themeColor: string;             // "#FF6B35"
    animation: string | null;       // "confetti" | "water_splash" | null
  };
}
```

### 2.2 Event Calendar (Planned)

```
April 2026: Songkran Week (13-20 เม.ย.)
  - Double streak rewards
  - Special random bonus 15% chance (10-20 Energy)
  - Limited package: 200 Energy + 50 bonus = 250 (฿149)
  - Badge: "Songkran 2026 🎉" (log 10 meals during event)

July 2026: MIRO Anniversary (launch date)
  - Triple challenge rewards
  - 50% bonus on all purchases
  - Badge: "MIRO OG 🏆"

December 2026: Healthy New Year (25 ธ.ค. - 31 ม.ค.)
  - Log 31 meals → 100 Energy bonus
  - Double streak rewards
  - Badge: "Healthy 2027 💪"
```

### 2.3 Implementation

```typescript
// Cloud Functions ต้องเช็ค active events:

async function getActiveEvents(): Promise<SeasonalEvent[]> {
  const today = new Date().toISOString().split('T')[0];

  const snapshot = await db
    .collection('events')
    .where('startDate', '<=', today)
    .where('endDate', '>=', today)
    .where('status', '==', 'active')
    .get();

  return snapshot.docs.map((doc) => doc.data() as SeasonalEvent);
}

// ใช้ใน processCheckIn:
const activeEvents = await getActiveEvents();
const hasDoubleStreak = activeEvents.some(
  (e) => e.rewards.doubleStreakRewards
);

if (hasDoubleStreak) {
  energyBonus *= 2;
}
```

### 2.4 Admin: Event Manager

```
Admin สามารถ:
- สร้าง event ใหม่ (ตั้ง start/end date + rewards)
- Preview event UI
- Activate/deactivate event
- ดูสถิติ event (participation, revenue impact)
```

### 2.5 Checklist

```
□ สร้าง events collection schema
□ สร้าง getActiveEvents helper
□ แก้ไข processCheckIn (event multipliers)
□ แก้ไข completeChallenge (event multipliers)
□ แก้ไข verifyPurchase (event bonus packages)
□ Flutter: event banner UI (home screen)
□ Flutter: event-specific theme/animation
□ Flutter: event badge display
□ Admin: event management page
□ ทดสอบ: event active → rewards multiplied
□ ทดสอบ: event ended → rewards normal
```

---

## Task 3: Social Features

### 3.1 Streak Leaderboard

```
Firestore: leaderboard/{period}  (e.g. "2026-02")

{
  period: "2026-02",
  topUsers: [
    { miroId: "MIRO-...", streak: 45, tier: "gold" },
    { miroId: "MIRO-...", streak: 42, tier: "gold" },
    ...
  ],
  updatedAt: Timestamp,
}
```

```typescript
// Cron: updateLeaderboard (ทุกวัน)
// ดึง Top 50 users by currentStreak
// เก็บใน leaderboard/{currentMonth}
```

```dart
/// Flutter UI:
///
/// ┌──────────────────────────────┐
/// │ 🏆 Streak Leaderboard        │
/// │                              │
/// │ 1. 🥇 MIRO-K7X2  45 days   │
/// │ 2. 🥈 MIRO-P8M1  42 days   │
/// │ 3. 🥉 MIRO-A3F9  38 days   │
/// │ 4.    MIRO-H7T2  35 days   │
/// │ ...                         │
/// │                              │
/// │ Your rank: #127 (14 days)   │
/// └──────────────────────────────┘
```

### 3.2 Share Meal Analysis

```dart
/// หลังจาก AI วิเคราะห์อาหารเสร็จ:
/// ปุ่ม "Share" → สร้างรูป + แชร์ไปโซเชียล
///
/// ┌──────────────────────────────┐
/// │  [รูปอาหาร]                  │
/// │                              │
/// │  🍽 ข้าวกะเพราหมูไข่ดาว      │
/// │  📊 650 kcal                 │
/// │  💪 28g protein              │
/// │                              │
/// │  Analyzed by MIRO 🤖        │
/// │  miro-app.com               │
/// └──────────────────────────────┘
```

### 3.3 Community Goals (Optional)

```
"ชาว MIRO วิเคราะห์อาหารครบ 100,000 ครั้ง!"
→ ถ้าถึงเป้า: ทุกคนได้ 10 Energy ฟรี
→ Progress bar แสดงใน app

Firestore: config/community_goals
{
  currentGoal: {
    name: "100K AI Analyses",
    target: 100000,
    current: 87432,
    reward: 10,
    endDate: "2026-03-31"
  }
}
```

### 3.4 Checklist

```
□ สร้าง leaderboard cron + collection
□ Flutter: leaderboard screen
□ Flutter: share meal analysis (image generation + Share.share)
□ Community goals (optional, low priority)
□ ทดสอบ: leaderboard แสดง top users
□ ทดสอบ: user rank ถูกต้อง
□ ทดสอบ: share สร้างรูป + แชร์ได้
```

---

## Task 4: iOS IAP Integration

### 4.1 Overview

เมื่อ iOS version พร้อม:

```
ต้องเพิ่ม:
1. App Store Connect: สร้าง products + subscription
2. Cloud Function: verifyApplePurchase (App Store Server API)
3. Cloud Function: handleAppleSubscriptionEvent (Server Notifications V2)
4. Flutter: platform-specific purchase flow
```

### 4.2 Cloud Function: verifyApplePurchase

```typescript
/**
 * verifyApplePurchase
 *
 * คล้ายกับ verifyPurchase.ts แต่ใช้ App Store Server API
 *
 * References:
 * - https://developer.apple.com/documentation/appstoreserverapi
 * - Package: app-store-server-library (npm)
 */

// Placeholder — implement เมื่อ iOS ready

import { onRequest } from 'firebase-functions/v2/https';

export const verifyApplePurchase = onRequest(
  { timeoutSeconds: 30, memory: '256MiB', cors: '*' },
  async (req, res) => {
    // 1. Decode JWS transaction
    // 2. Verify with App Store Server API
    // 3. Check product mapping
    // 4. Add energy (with bonus rate)
    // 5. Record purchase

    res.status(501).json({ error: 'Not implemented yet — iOS coming soon' });
  }
);
```

### 4.3 Product Mapping (iOS)

```
App Store Connect products:
  energy_100   → 100 Energy  (฿35 / $0.99)
  energy_550   → 550 Energy  (฿159 / $4.99)
  energy_1200  → 1200 Energy (฿299 / $9.99)
  energy_2000  → 2000 Energy (฿449 / $14.99)
  energy_pass  → Subscription (฿149 / $4.99/month)

หมายเหตุ:
  - ราคา iOS อาจต่างจาก Android เล็กน้อย (Apple pricing tiers)
  - Apple เก็บ 30% commission (ปีแรก) / 15% (ปีต่อไป)
```

### 4.4 Checklist

```
□ สร้าง products ใน App Store Connect
□ สร้าง subscription ใน App Store Connect
□ สร้าง verifyApplePurchase Cloud Function
□ สร้าง handleAppleSubscriptionEvent (Server Notifications V2)
□ Flutter: platform detection → เรียก API ที่ถูกต้อง
□ ทดสอบ: sandbox purchase → energy เพิ่ม
□ ทดสอบ: sandbox subscription → unlimited AI
```

---

## Task 5: Energy Expiry (Optional)

### 5.1 Overview

```
เป้าหมาย: ป้องกัน user สะสม energy มากเกินไปแล้วไม่ซื้ออีก

กฎ:
  - Energy ที่ซื้อ (IAP) → ไม่หมดอายุ (ตลอดชีพ)
  - Energy ที่ได้ฟรี (reward) → หมดอายุ 90 วัน
  - ระบบใช้ free energy ก่อน paid energy (FIFO)
  - แจ้งเตือน 7 วันก่อนหมดอายุ

⚠️ Feature นี้ซับซ้อนมาก — แนะนำ implement เมื่อ:
  - มี user จำนวนมาก (10K+)
  - มีปัญหา hoarding จริง
  - ถ้ายังไม่จำเป็น → ข้ามไปก่อน
```

### 5.2 Schema (ถ้าทำ)

```typescript
// เพิ่ม collection: energy_ledger/{deviceId}/entries/{entryId}
interface EnergyEntry {
  entryId: string;
  amount: number;
  remaining: number;             // จำนวนที่ยังไม่ใช้
  source: 'purchase' | 'reward'; // purchase = ไม่หมดอายุ
  type: string;                  // 'welcome_gift', 'streak_bonus', etc.
  expiresAt: Timestamp | null;   // null = ไม่หมดอายุ
  createdAt: Timestamp;
}
```

### 5.3 Consumption Logic (FIFO)

```typescript
// เมื่อหัก energy:
// 1. เรียงตาม expiresAt (ใกล้หมดอายุก่อน)
// 2. หัก free energy ก่อน paid energy
// 3. ถ้า free energy ไม่พอ → หัก paid energy

async function consumeEnergy(deviceId: string, amount: number): Promise<void> {
  // ดึง entries เรียงตาม priority:
  // 1. Free energy ที่ใกล้หมดอายุ (expiresAt ASC, NOT NULL)
  // 2. Free energy ที่ไม่หมดอายุ
  // 3. Paid energy

  // หัก remaining จาก entry ที่เหมาะสม
  // ถ้า remaining = 0 → mark as depleted
}
```

### 5.4 Checklist

```
□ สร้าง energy_ledger collection (ถ้าตัดสินใจทำ)
□ แก้ไข addEnergy → สร้าง entry ใน ledger
□ แก้ไข deductEnergy → FIFO consumption
□ สร้าง cron: expireEnergy (ลบ expired entries)
□ Flutter: แสดง "energy expiring soon" warning
□ Notification: 7 วันก่อนหมดอายุ
□ ⚠️ ซับซ้อนมาก — พิจารณา ROI ก่อนทำ
```

---

## Task 6: Testing Checklist

### Subscription

```
□ Subscribe → unlimited AI (ไม่หัก energy)
□ Subscribe → double streak rewards
□ Subscribe → double challenge rewards
□ Cancel subscription → กลับเป็น energy-based
□ Subscription expired → กลับเป็น energy-based
□ Renew → status active อีกครั้ง
□ RTDN notification → status update ถูกต้อง
```

### Events

```
□ Active event → rewards multiplied
□ Event ended → rewards normal
□ Event banner แสดง/หายถูกต้อง
□ Event special packages แสดง
□ Event badge ได้เมื่อครบ requirement
```

### Social

```
□ Leaderboard แสดง top users
□ User rank ถูกต้อง
□ Share meal → สร้างรูป + แชร์ได้
```

### iOS (เมื่อพร้อม)

```
□ Sandbox purchase → energy เพิ่ม
□ Sandbox subscription → unlimited AI
□ Sandbox refund → energy ลด
□ Product prices ถูกต้อง
```

---

## ⏰ Timeline

```
Day 1-5:   Task 1 (Subscription — backend + Flutter + Google Play)
Day 6-8:   Task 2 (Seasonal Events — backend + admin)
Day 9-10:  Task 3 (Social Features — leaderboard + share)
Day 11-12: Task 4 (iOS IAP — เมื่อ iOS ready)
Day 13:    Task 5 (Energy Expiry — ถ้าจำเป็น)
Day 14:    Task 6 (Testing)
```

---

## 🎬 Project Complete!

เมื่อทำ Phase 5 เสร็จ ระบบ Monetization จะมี:

```
✅ Phase 1: MiRO ID + Free AI + Streak Tier
✅ Phase 2: Challenges + Milestones + Bonus Energy + Random Bonus
✅ Phase 3: Admin Panel + Notifications + Fraud Detection
✅ Phase 4: Referral + Comeback + A/B Testing
✅ Phase 5: Subscription + Events + Social + iOS

Revenue streams:
  1. Energy purchases (one-time) — Heavy users
  2. Energy Pass subscription (MRR) — Power users
  3. Event special packages (seasonal spikes)

Retention tools:
  1. Daily Free AI (ทุกวัน)
  2. Streak Tier + Grace Period
  3. Weekly Challenges
  4. Notifications (streak, challenge, comeback)
  5. Referral (viral growth)
  6. Seasonal Events (FOMO)
  7. Leaderboard (competition)
  8. Community Goals (sense of belonging)
```
