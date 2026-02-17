# Phase 3: Admin Panel + Notifications — คู่มือ Implementation

**Scope:** Admin Panel (Next.js + Cloud Run) + Push Notifications (FCM) + Fraud Detection  
**ระยะเวลา:** 2 สัปดาห์  
**ต้องทำ Phase 1-2 เสร็จก่อน**

---

## สารบัญ

- [Task 1: Admin Panel Setup](#task-1-admin-panel-setup)
- [Task 2: Dashboard & Metrics](#task-2-dashboard--metrics)
- [Task 3: User Management](#task-3-user-management)
- [Task 4: Config Management](#task-4-config-management)
- [Task 5: Push Notifications](#task-5-push-notifications)
- [Task 6: Fraud Detection](#task-6-fraud-detection)
- [Task 7: Emergency Controls](#task-7-emergency-controls)
- [Task 8: Deployment](#task-8-deployment)
- [Task 9: Testing Checklist](#task-9-testing-checklist)

---

## Task 1: Admin Panel Setup

### 1.1 Tech Stack

| Component | Technology | เหตุผล |
|-----------|-----------|--------|
| Framework | Next.js 14+ (App Router) | SSR + API Routes + ง่าย |
| UI | shadcn/ui + Tailwind CSS | สวย + component library |
| Charts | Recharts | ง่าย + ดูดี |
| Auth | Firebase Admin SDK | ผูก Firebase project เดิม |
| Deploy | Cloud Run | มี Firebase อยู่แล้ว + ง่าย |
| Database | Firestore (direct) | Admin SDK อ่าน/เขียนได้เลย |

### 1.2 Project Structure

```
admin-panel/
├── app/
│   ├── layout.tsx              # Root layout + Auth wrapper
│   ├── page.tsx                # Dashboard (home)
│   ├── login/
│   │   └── page.tsx            # Admin login
│   ├── users/
│   │   ├── page.tsx            # User list + search
│   │   └── [deviceId]/
│   │       └── page.tsx        # User detail
│   ├── config/
│   │   ├── rewards/
│   │   │   └── page.tsx        # Reward configuration
│   │   └── features/
│   │       └── page.tsx        # Feature flags
│   ├── fraud/
│   │   └── page.tsx            # Fraud alerts
│   └── api/
│       ├── auth/
│       │   └── route.ts        # Auth endpoint
│       ├── users/
│       │   └── route.ts        # User CRUD
│       ├── metrics/
│       │   └── route.ts        # Metrics data
│       └── config/
│           └── route.ts        # Config CRUD
├── components/
│   ├── layout/
│   │   ├── Sidebar.tsx
│   │   ├── Header.tsx
│   │   └── AuthGuard.tsx
│   ├── dashboard/
│   │   ├── MetricCard.tsx
│   │   ├── RevenueChart.tsx
│   │   ├── StreakDistribution.tsx
│   │   └── UserSegmentPie.tsx
│   ├── users/
│   │   ├── UserTable.tsx
│   │   ├── UserDetail.tsx
│   │   ├── TransactionHistory.tsx
│   │   └── ManualTopup.tsx
│   └── config/
│       ├── RewardEditor.tsx
│       └── FeatureToggle.tsx
├── lib/
│   ├── firebase-admin.ts       # Firebase Admin SDK init
│   ├── auth.ts                 # Auth helpers
│   └── utils.ts                # Utility functions
├── Dockerfile                  # Cloud Run deployment
├── package.json
├── tailwind.config.ts
└── tsconfig.json
```

### 1.3 Auth: Admin-only Access

```typescript
// lib/firebase-admin.ts
import { initializeApp, cert, getApps } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

if (!getApps().length) {
  initializeApp({
    credential: cert({
      projectId: process.env.FIREBASE_PROJECT_ID,
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
      privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
    }),
  });
}

export const db = getFirestore();
```

```typescript
// lib/auth.ts
// Simple password-based auth (สำหรับ admin ไม่กี่คน)
// Phase ถัดไปอาจเปลี่ยนเป็น Firebase Auth

const ADMIN_CREDENTIALS = {
  username: process.env.ADMIN_USERNAME,
  password: process.env.ADMIN_PASSWORD,
};

export function verifyAdmin(username: string, password: string): boolean {
  return (
    username === ADMIN_CREDENTIALS.username &&
    password === ADMIN_CREDENTIALS.password
  );
}

// ใช้ JWT session cookie (httpOnly, secure)
// หรือ next-auth สำหรับ session management
```

### 1.4 Checklist

```
□ สร้าง admin-panel/ project (npx create-next-app)
□ ติดตั้ง dependencies: firebase-admin, shadcn/ui, recharts, tailwindcss
□ Setup Firebase Admin SDK
□ Setup auth (simple password or Firebase Auth)
□ Setup layout (Sidebar, Header)
□ สร้าง Dockerfile
□ ทดสอบ local: npm run dev
```

---

## Task 2: Dashboard & Metrics

### 2.1 Dashboard Layout

```
┌─────────────────────────────────────────────────────────┐
│  📊 MIRO Admin Dashboard                               │
├──────────┬──────────┬──────────┬───────────────────────│
│  DAU     │  Revenue │  Conv %  │  Avg Streak           │
│  3,241   │  ฿12,400 │  14.2%   │  8.3 days             │
│  +12%    │  +8%     │  -0.5%   │  +2.1                 │
├──────────┴──────────┴──────────┴───────────────────────│
│                                                         │
│  Revenue (30 days)          │  User Segments            │
│  ┌────────────────────┐     │  ┌──────────────────┐    │
│  │  📈 Line Chart     │     │  │  🥧 Pie Chart    │    │
│  │                    │     │  │  Normal  60%     │    │
│  │                    │     │  │  Active  30%     │    │
│  │                    │     │  │  Heavy   10%     │    │
│  └────────────────────┘     │  └──────────────────┘    │
│                                                         │
│  Streak Distribution        │  Challenge Completion     │
│  ┌────────────────────┐     │  ┌──────────────────┐    │
│  │  📊 Bar Chart      │     │  │  logMeals: 62%   │    │
│  │  Day 1-6:  45%     │     │  │  useAi:    78%   │    │
│  │  Day 7-13: 30%     │     │  │                  │    │
│  │  Day 14-29: 15%    │     │  │                  │    │
│  │  Day 30-59: 7%     │     │  │                  │    │
│  │  Day 60+:   3%     │     │  │                  │    │
│  └────────────────────┘     │  └──────────────────┘    │
└─────────────────────────────────────────────────────────┘
```

### 2.2 Metrics Collection (Cron)

สร้างไฟล์ `functions/src/cron/calculateMetrics.ts`:

```typescript
/**
 * calculateMetrics
 *
 * Schedule: ทุกวัน 03:00 UTC+7 (20:00 UTC)
 * สิ่งที่ทำ: คำนวณ daily metrics แล้วเก็บใน metrics/{date}
 */

import { onSchedule } from 'firebase-functions/v2/scheduler';
import * as admin from 'firebase-admin';

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

export const calculateMetrics = onSchedule(
  {
    schedule: '0 20 * * *', // 03:00 UTC+7
    timeZone: 'UTC',
    timeoutSeconds: 540,
    memory: '1GiB',
  },
  async () => {
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    const dateStr = yesterday.toISOString().split('T')[0];

    console.log(`📊 [Metrics] Calculating for ${dateStr}...`);

    const usersSnapshot = await db.collection('users').get();
    const totalUsers = usersSnapshot.size;

    let dau = 0;
    let totalRevenue = 0;
    let purchaseCount = 0;
    const streakDistribution = { '0': 0, '1-6': 0, '7-13': 0, '14-29': 0, '30-59': 0, '60+': 0 };
    const tierDistribution = { none: 0, bronze: 0, silver: 0, gold: 0, diamond: 0 };
    let challengeLogMealsCompleted = 0;
    let challengeUseAiCompleted = 0;

    for (const doc of usersSnapshot.docs) {
      const user = doc.data();

      // DAU: checked in yesterday
      if (user.lastCheckInDate === dateStr) dau++;

      // Streak distribution
      const streak = user.currentStreak || 0;
      if (streak === 0) streakDistribution['0']++;
      else if (streak <= 6) streakDistribution['1-6']++;
      else if (streak <= 13) streakDistribution['7-13']++;
      else if (streak <= 29) streakDistribution['14-29']++;
      else if (streak <= 59) streakDistribution['30-59']++;
      else streakDistribution['60+']++;

      // Tier distribution
      tierDistribution[user.tier || 'none']++;

      // Challenge completion
      const claimed = user.challenges?.weekly?.claimedRewards || [];
      if (claimed.includes('logMeals')) challengeLogMealsCompleted++;
      if (claimed.includes('useAi')) challengeUseAiCompleted++;
    }

    // Revenue from transactions
    const txStart = admin.firestore.Timestamp.fromDate(new Date(dateStr));
    const txEnd = admin.firestore.Timestamp.fromDate(
      new Date(new Date(dateStr).getTime() + 86400000)
    );

    const purchaseTx = await db
      .collection('transactions')
      .where('type', '==', 'purchase')
      .where('createdAt', '>=', txStart)
      .where('createdAt', '<', txEnd)
      .get();

    purchaseCount = purchaseTx.size;
    purchaseTx.forEach((doc) => {
      totalRevenue += doc.data().metadata?.totalEnergy || doc.data().amount || 0;
    });

    // Save metrics
    await db.collection('metrics').doc(dateStr).set({
      date: dateStr,
      totalUsers,
      dau,
      dauRate: totalUsers > 0 ? (dau / totalUsers) * 100 : 0,
      purchaseCount,
      conversionRate: dau > 0 ? (purchaseCount / dau) * 100 : 0,
      streakDistribution,
      tierDistribution,
      challengeCompletion: {
        logMeals: challengeLogMealsCompleted,
        useAi: challengeUseAiCompleted,
        logMealsRate: totalUsers > 0
          ? (challengeLogMealsCompleted / totalUsers) * 100 : 0,
        useAiRate: totalUsers > 0
          ? (challengeUseAiCompleted / totalUsers) * 100 : 0,
      },
      calculatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(`✅ [Metrics] Done: DAU=${dau}, Purchases=${purchaseCount}`);
  }
);
```

### 2.3 Admin API Route (Next.js)

```typescript
// admin-panel/app/api/metrics/route.ts

import { db } from '@/lib/firebase-admin';
import { NextResponse } from 'next/server';

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const days = parseInt(searchParams.get('days') || '30');

  const startDate = new Date();
  startDate.setDate(startDate.getDate() - days);
  const startStr = startDate.toISOString().split('T')[0];

  const snapshot = await db
    .collection('metrics')
    .where('date', '>=', startStr)
    .orderBy('date', 'desc')
    .get();

  const metrics = snapshot.docs.map((doc) => doc.data());

  return NextResponse.json({ metrics });
}
```

### 2.4 Checklist

```
□ สร้าง cron/calculateMetrics.ts
□ สร้าง admin API routes (metrics, users, config)
□ สร้าง Dashboard page (MetricCard × 4 + Charts)
□ สร้าง RevenueChart component (Recharts)
□ สร้าง StreakDistribution component
□ สร้าง UserSegmentPie component
□ ทดสอบ: metrics cron → data ถูกเขียนลง metrics/{date}
□ ทดสอบ: dashboard แสดงข้อมูลถูกต้อง
```

---

## Task 3: User Management

### 3.1 User Lookup

```
ค้นหาได้โดย:
- MiRO ID (exact match)
- deviceId (exact match)

แสดงข้อมูล:
- MiRO ID, deviceId, createdAt
- Balance, totalSpent, totalPurchased, totalEarned
- Current streak, longest streak, tier
- Challenge progress
- Milestone status
- Transaction history (ล่าสุด 50 รายการ)
- Flags (banned, suspicious)
```

### 3.2 Manual Operations

```typescript
// admin-panel/app/api/users/route.ts

// POST /api/users/topup
// Manual top-up energy (กรณี bug/ขออภัย)
export async function topupEnergy(deviceId: string, amount: number, reason: string) {
  await db.runTransaction(async (transaction) => {
    const userRef = db.collection('users').doc(deviceId);
    const userDoc = await transaction.get(userRef);

    if (!userDoc.exists) throw new Error('User not found');

    const user = userDoc.data()!;
    const newBalance = (user.balance || 0) + amount;

    transaction.update(userRef, {
      balance: newBalance,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    });

    const txRef = db.collection('transactions').doc();
    transaction.set(txRef, {
      deviceId,
      miroId: user.miroId,
      type: 'admin_topup',
      amount,
      balanceAfter: newBalance,
      description: `Admin top-up: ${reason}`,
      metadata: { adminAction: true, reason },
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });
}

// POST /api/users/reset-streak
export async function resetStreak(deviceId: string, reason: string) {
  // Reset streak แต่ไม่ reset tier
  await db.collection('users').doc(deviceId).update({
    currentStreak: 0,
    lastCheckInDate: null,
    lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
  });
}

// POST /api/users/ban
export async function banUser(deviceId: string, reason: string) {
  await db.collection('users').doc(deviceId).update({
    isBanned: true,
    banReason: reason,
    lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
  });
}
```

### 3.3 Checklist

```
□ สร้าง Users list page (table + search)
□ สร้าง User detail page
□ สร้าง Transaction history component
□ สร้าง Manual top-up form
□ สร้าง Reset streak button
□ สร้าง Ban/Unban button
□ API routes: search, topup, reset, ban
□ ทดสอบ: search by MiRO ID → แสดงข้อมูลถูกต้อง
□ ทดสอบ: manual topup → balance เพิ่ม + transaction บันทึก
```

---

## Task 4: Config Management

### 4.1 Reward Config Editor

```
Admin สามารถแก้ไขค่าเหล่านี้ได้โดยไม่ต้อง deploy:

Streak Tiers:
  - Bronze:  days=7,  energy=10, grace=0
  - Silver:  days=14, energy=15, grace=1
  - Gold:    days=30, energy=30, grace=2, bonusRate=0.20
  - Diamond: days=60, energy=45, grace=3, bonusRate=0.30

Challenges:
  - logMeals: target=7, reward=5
  - useAi:    target=3, reward=5

Milestones:
  - spent500:  reward=15
  - spent1000: reward=30

Random Bonus:
  - chance=0.05, min=5, max=10
```

### 4.2 Feature Flags

```
Admin สามารถ toggle on/off ได้ทันที:

  [✅] enableDailyFreeAi
  [✅] enableStreakTier
  [✅] enableWeeklyChallenges
  [✅] enableMilestones
  [✅] enableRandomBonus
  [❌] enableReferral        ← Phase 4
  [❌] enableComebackBonus   ← Phase 4
  [❌] enableSubscription    ← Phase 5
  [❌] enableNotifications   ← Phase 3 (this phase)

  Emergency:
  [❌] freezeAllRewards      ← ปิดทุก reward ฉุกเฉิน
  [❌] maintenanceMode       ← ปิดระบบชั่วคราว
```

### 4.3 Cloud Functions ต้องอ่าน Config

**สำคัญ:** ทุก Cloud Function ต้องอ่าน config จาก Firestore ไม่ hardcode

```typescript
// Helper function ที่ทุก function ใช้:

let cachedConfig: any = null;
let cacheTime = 0;
const CACHE_TTL = 5 * 60 * 1000; // 5 minutes

async function getRewardsConfig(): Promise<any> {
  if (cachedConfig && Date.now() - cacheTime < CACHE_TTL) {
    return cachedConfig;
  }

  const doc = await db.collection('config').doc('rewards').get();
  cachedConfig = doc.data() || {};
  cacheTime = Date.now();
  return cachedConfig;
}

async function getFeatureFlags(): Promise<any> {
  const doc = await db.collection('config').doc('features').get();
  return doc.data() || {};
}
```

### 4.4 Checklist

```
□ สร้าง Rewards config editor page
□ สร้าง Feature flags toggle page
□ API routes: get/update config
□ Config version history (เก็บ previous values)
□ Cloud Functions อ่าน config จาก Firestore (ไม่ hardcode)
□ ทดสอบ: เปลี่ยน config → Cloud Function ใช้ค่าใหม่
□ ทดสอบ: freeze all rewards → ทุก reward หยุดทำงาน
```

---

## Task 5: Push Notifications

### 5.1 Setup FCM

**Flutter Client:**

```dart
// lib/core/services/notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static final _messaging = FirebaseMessaging.instance;

  /// เรียกตอน app startup
  static Future<void> initialize() async {
    // Request permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get FCM token
      final token = await _messaging.getToken();
      if (token != null) {
        // ส่ง token ไปเก็บใน Firestore
        await _saveFcmToken(token);
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen(_saveFcmToken);
    }
  }

  static Future<void> _saveFcmToken(String token) async {
    final deviceId = await DeviceIdService.getDeviceId();
    // เรียก API เพื่อเก็บ token
    await http.post(
      Uri.parse('.../saveFcmToken'),
      body: jsonEncode({ 'deviceId': deviceId, 'fcmToken': token }),
    );
  }
}
```

**Firestore — เพิ่ม field ใน users:**

```typescript
// เพิ่มใน users/{deviceId}:
fcmToken: string | null;
notificationSettings: {
  streakReminder: boolean;    // default true
  challengeReminder: boolean; // default true
  promotions: boolean;        // default true
  reminderTime: string;       // "20:00" (user configurable)
};
```

### 5.2 Notification Cron

สร้างไฟล์ `functions/src/cron/sendNotifications.ts`:

```typescript
/**
 * sendStreakReminders
 *
 * Schedule: ทุกวัน 13:00 UTC (= 20:00 UTC+7)
 * สิ่งที่ทำ: ส่ง notification ให้ user ที่ยังไม่ check-in วันนี้
 */

import { onSchedule } from 'firebase-functions/v2/scheduler';
import * as admin from 'firebase-admin';

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

export const sendStreakReminders = onSchedule(
  {
    schedule: '0 13 * * *', // 20:00 UTC+7
    timeZone: 'UTC',
    timeoutSeconds: 540,
    memory: '512MiB',
  },
  async () => {
    // วันนี้ (UTC+7)
    const now = new Date();
    const today = new Date(now.getTime() + 7 * 60 * 60 * 1000)
      .toISOString().split('T')[0];

    console.log(`🔔 [Notify] Sending streak reminders for ${today}...`);

    // หา users ที่ยังไม่ check-in + มี streak > 0 + มี fcmToken
    const usersSnapshot = await db
      .collection('users')
      .where('currentStreak', '>', 0)
      .get();

    const messages: admin.messaging.Message[] = [];

    for (const doc of usersSnapshot.docs) {
      const user = doc.data();

      // ข้าม: check-in แล้ววันนี้
      if (user.lastCheckInDate === today) continue;

      // ข้าม: ไม่มี fcmToken
      if (!user.fcmToken) continue;

      // ข้าม: ปิด notification
      if (user.notificationSettings?.streakReminder === false) continue;

      // ข้าม: banned
      if (user.isBanned) continue;

      const streak = user.currentStreak || 0;
      const tier = user.tier || 'none';

      messages.push({
        token: user.fcmToken,
        notification: {
          title: `🔥 Streak ${streak} วัน!`,
          body: `อย่าลืมเข้า MIRO วันนี้ — ${tier !== 'none' ? `${user.tierEmoji || ''} ${tier} tier ของคุณกำลังรอ!` : 'ใช้ AI ฟรี 1 ครั้ง!'}`,
        },
        data: {
          type: 'streak_reminder',
          streak: streak.toString(),
        },
        android: {
          priority: 'high' as const,
        },
      });
    }

    // Send in batches (FCM limit: 500 per batch)
    const batchSize = 500;
    let sent = 0;
    let failed = 0;

    for (let i = 0; i < messages.length; i += batchSize) {
      const batch = messages.slice(i, i + batchSize);
      try {
        const result = await admin.messaging().sendEach(batch);
        sent += result.successCount;
        failed += result.failureCount;

        // Clean up invalid tokens
        result.responses.forEach((resp, idx) => {
          if (resp.error?.code === 'messaging/registration-token-not-registered') {
            const deviceId = batch[idx].data?.deviceId;
            if (deviceId) {
              db.collection('users').doc(deviceId).update({ fcmToken: null });
            }
          }
        });
      } catch (err) {
        console.error('❌ [Notify] Batch send error:', err);
        failed += batch.length;
      }
    }

    console.log(`✅ [Notify] Sent: ${sent}, Failed: ${failed}, Total: ${messages.length}`);
  }
);
```

### 5.3 Checklist

```
□ Flutter: setup FirebaseMessaging + request permission
□ Flutter: save FCM token to Firestore
□ Flutter: handle notification tap (navigate to app)
□ สร้าง cron/sendNotifications.ts (streak reminder)
□ เพิ่ม fcmToken + notificationSettings ใน user schema
□ Admin: manual send notification to user
□ ทดสอบ: user ไม่ check-in → ได้ notification
□ ทดสอบ: user check-in แล้ว → ไม่ได้ notification
□ ทดสอบ: user ปิด notification → ไม่ได้
```

---

## Task 6: Fraud Detection

### 6.1 Suspicious Patterns

```
ตรวจจับ:

1. Multiple registrations (same IP)
   → Flag: deviceId ที่ register จาก IP เดียวกันเกิน 3 ครั้ง/วัน

2. Abnormal energy gain
   → Flag: user ได้ energy เกิน 200/วัน จาก rewards

3. Time manipulation
   → Flag: client timestamp ต่างจาก server เกิน 10 นาที

4. Rapid requests
   → Flag: เกิน 100 requests/ชั่วโมง จาก device เดียว
```

### 6.2 Fraud Alert System

```typescript
// functions/src/utils/fraudCheck.ts

export async function checkFraud(
  deviceId: string,
  action: string,
  metadata: Record<string, any>
): Promise<void> {
  // อ่านจาก fraud rules config
  // ถ้า suspicious → สร้าง alert ใน fraud_alerts collection

  const alertRef = db.collection('fraud_alerts').doc();
  await alertRef.set({
    deviceId,
    action,
    metadata,
    status: 'pending', // pending, reviewed, dismissed, confirmed
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}
```

### 6.3 Admin Fraud Page

```
┌──────────────────────────────────────────────────┐
│ 🚨 Fraud Alerts                                  │
│                                                  │
│ [Pending: 3] [Reviewed: 12] [Confirmed: 1]      │
│                                                  │
│ ┌──────────────────────────────────────────────┐ │
│ │ ⚠️ Multiple registrations from same IP       │ │
│ │ DeviceId: abc123...                          │ │
│ │ IP: 203.150.xxx.xxx                          │ │
│ │ Count: 5 registrations in 1 hour             │ │
│ │ [Review] [Dismiss] [Ban User]                │ │
│ └──────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────┘
```

### 6.4 Checklist

```
□ สร้าง fraud_alerts collection schema
□ สร้าง fraudCheck utility function
□ Integrate fraud check ใน registerUser, claimDailyCheckIn
□ Admin: Fraud alerts page
□ Admin: Review/Dismiss/Ban actions
□ ทดสอบ: multiple registration → alert created
□ ทดสอบ: ban user → user ถูกบล็อก
```

---

## Task 7: Emergency Controls

### 7.1 Emergency Buttons (Admin)

```
🔴 Freeze All Rewards
   → ปิดทุก reward ทันที (streak, challenge, milestone, random)
   → ใช้เมื่อ: พบ exploit / bug ที่ทำให้ได้ reward ผิดปกติ

🔴 Maintenance Mode
   → ปิดระบบ gamification ทั้งหมด
   → ใช้เมื่อ: ต้อง migrate/fix data

🟡 Rollback Config
   → กลับไปใช้ config version ก่อนหน้า
   → ใช้เมื่อ: ตั้งค่า reward ผิด

🟡 Mass Restore
   → Restore balance ของทุก user ไปเป็น snapshot ก่อนหน้า
   → ใช้เมื่อ: Bug ทำให้ energy หายหมด
```

### 7.2 Config Version History

```typescript
// เมื่อ admin แก้ config → เก็บ version เก่าไว้

// Collection: config_history/{timestamp}
{
  configType: 'rewards' | 'features',
  previousData: { ... },
  newData: { ... },
  changedBy: 'admin',
  changedAt: Timestamp,
}
```

### 7.3 Checklist

```
□ Emergency buttons ใน Admin (freeze, maintenance, rollback)
□ Config version history
□ Cloud Functions เช็ค freezeAllRewards flag
□ Cloud Functions เช็ค maintenanceMode flag
□ ทดสอบ: freeze → reward claims ถูก reject
□ ทดสอบ: rollback config → ค่าเดิมกลับมา
```

---

## Task 8: Deployment

### 8.1 Dockerfile

```dockerfile
FROM node:20-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production

COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/public ./public

EXPOSE 3000

CMD ["npm", "start"]
```

### 8.2 Deploy to Cloud Run

```bash
# Build & push
gcloud builds submit --tag gcr.io/miro-d6856/admin-panel

# Deploy
gcloud run deploy admin-panel \
  --image gcr.io/miro-d6856/admin-panel \
  --platform managed \
  --region asia-southeast1 \
  --allow-unauthenticated \
  --set-env-vars "FIREBASE_PROJECT_ID=miro-d6856" \
  --set-secrets "FIREBASE_PRIVATE_KEY=firebase-admin-key:latest" \
  --set-secrets "ADMIN_PASSWORD=admin-password:latest" \
  --memory 512Mi \
  --max-instances 3
```

### 8.3 Checklist

```
□ Dockerfile ทำงานได้
□ Environment variables ตั้งค่าถูกต้อง
□ Secrets เก็บใน Secret Manager
□ Deploy to Cloud Run
□ Custom domain (optional): admin.miro-app.com
□ HTTPS ทำงานถูกต้อง
□ Auth ทำงานถูกต้อง (ไม่ให้คนนอกเข้า)
```

---

## Task 9: Testing Checklist

```
Dashboard:
□ Metrics แสดงถูกต้อง (DAU, Revenue, Conversion)
□ Charts render ถูกต้อง
□ Date range filter ทำงาน

User Management:
□ Search by MiRO ID → แสดงข้อมูลถูกต้อง
□ Search by deviceId → แสดงข้อมูลถูกต้อง
□ Manual topup → balance เพิ่ม
□ Reset streak → streak = 0, tier ยังอยู่
□ Ban user → isBanned = true

Config:
□ แก้ reward values → Cloud Functions ใช้ค่าใหม่ (ภายใน 5 นาที)
□ Toggle feature flag → feature on/off ทันที
□ Config history บันทึกถูกต้อง

Notifications:
□ Streak reminder ส่งถูกคน (ยังไม่ check-in)
□ ไม่ส่งถ้า check-in แล้ว
□ ไม่ส่งถ้าปิด notification
□ Invalid token ถูก clean up

Fraud:
□ Multiple registration → alert
□ Admin review → dismiss/ban
□ Banned user ถูกบล็อกจากทุก action

Emergency:
□ Freeze rewards → ทุก claim ถูก reject
□ Unfreeze → กลับมาปกติ
□ Rollback config → ค่าเดิมกลับมา
```

---

## ⏰ Timeline

```
Day 1-2:   Task 1 (Admin Panel setup + layout)
Day 3-4:   Task 2 (Dashboard + Metrics cron)
Day 5-6:   Task 3 (User Management)
Day 7:     Task 4 (Config Management)
Day 8-9:   Task 5 (Push Notifications)
Day 10:    Task 6 (Fraud Detection)
Day 11:    Task 7 (Emergency Controls)
Day 12:    Task 8 (Deploy to Cloud Run)
Day 13-14: Task 9 (Testing)
```
