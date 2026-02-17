# Phase 4: Referral + Comeback — คู่มือ Implementation

**Scope:** Referral System (MiRO ID based) + Comeback Bonus + A/B Testing  
**ระยะเวลา:** 2 สัปดาห์  
**ต้องทำ Phase 1-3 เสร็จก่อน** (ต้องมี MiRO ID, Admin Panel, Notifications)

---

## สารบัญ

- [Task 1: Referral System](#task-1-referral-system)
- [Task 2: Comeback Bonus](#task-2-comeback-bonus)
- [Task 3: A/B Testing Framework](#task-3-ab-testing-framework)
- [Task 4: Flutter Client](#task-4-flutter-client)
- [Task 5: Testing Checklist](#task-5-testing-checklist)

---

## Task 1: Referral System

### 1.1 Overview

| Feature | Detail |
|---------|--------|
| Referral Code | = MiRO ID ของ user (ไม่ต้องสร้างแยก) |
| Reward (Referrer) | +15 Energy per friend |
| Reward (Referee) | +5 Energy bonus (นอกจาก Welcome Gift) |
| Limit | 2 referrals/month |
| Condition | Friend ต้องใช้ AI จริง 3 ครั้ง |
| Anti-fraud | IP check + device fingerprint |

### 1.2 Flow

```
User A (Referrer):
  1. เปิดหน้า "Invite Friends"
  2. เห็น MiRO ID: MIRO-A3F9-K7X2-P8M1
  3. Share MiRO ID ให้เพื่อน (copy/share)

User B (Referee):
  1. ลง app → register → ได้ MiRO ID ของตัวเอง + 100 Welcome Gift
  2. ใส่ Referral Code: MIRO-A3F9-K7X2-P8M1
  3. ได้ +5 Energy bonus ทันที
  4. ใช้ AI 3 ครั้ง (ภายใน 7 วัน)

Server:
  1. หลัง User B ใช้ AI ครบ 3 ครั้ง → ให้ User A +15 Energy
  2. แจ้ง User A ผ่าน notification
```

### 1.3 Firestore Schema

```typescript
// เพิ่มใน users/{deviceId}:
referrals: {
  myReferralCode: string;         // = miroId (same thing)
  referredBy: string | null;      // MiRO ID ของคนชวน (null ถ้าไม่มี)
  referredByDeviceId: string | null;
  referralCount: number;          // 0-2 (reset ทุกเดือน)
  referralResetDate: string;      // "YYYY-MM-01"
  referredUsers: string[];        // [miroId1, miroId2]
  pendingReferrals: string[];     // [miroId ที่ยังใช้ AI ไม่ครบ 3 ครั้ง]
};

// Collection: referral_records/{recordId}
interface ReferralRecord {
  referrerId: string;             // deviceId ของคนชวน
  referrerMiroId: string;
  refereeId: string;              // deviceId ของคนถูกชวน
  refereeMiroId: string;
  status: 'pending' | 'completed' | 'expired' | 'fraudulent';
  refereeAiUsageCount: number;    // 0-3
  requiredUsage: number;          // 3
  referrerReward: number;         // 15
  refereeReward: number;          // 5
  createdAt: Timestamp;
  completedAt: Timestamp | null;
  expiresAt: Timestamp;           // 7 วันหลัง register
  ip: {
    referrer: string;
    referee: string;
  };
}
```

### 1.4 Cloud Function: submitReferralCode

```typescript
/**
 * submitReferralCode
 *
 * เรียกเมื่อ: Referee ใส่ referral code ตอน register
 * Timing: ใส่ได้แค่ภายใน 24 ชั่วโมงหลัง register
 *
 * Input:  { deviceId, referralCode }
 * Output: { success, bonusEnergy }
 */

import { onRequest } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';

const db = admin.firestore();

export const submitReferralCode = onRequest(
  { timeoutSeconds: 15, memory: '256MiB', cors: '*' },
  async (req, res) => {
    try {
      const { deviceId, referralCode } = req.body;

      // 1. Validate inputs
      if (!deviceId || !referralCode) {
        res.status(400).json({ error: 'Missing fields' });
        return;
      }

      // 2. ดึง referee (คนใส่ code)
      const refereeDoc = await db.collection('users').doc(deviceId).get();
      if (!refereeDoc.exists) {
        res.status(404).json({ error: 'User not found' });
        return;
      }

      const referee = refereeDoc.data()!;

      // 3. เช็คว่าใส่ referral code แล้วหรือยัง
      if (referee.referrals?.referredBy) {
        res.status(400).json({ error: 'Already used a referral code' });
        return;
      }

      // 4. เช็คว่า register ภายใน 24 ชั่วโมงหรือไม่
      const createdAt = referee.createdAt?.toDate?.() || new Date(0);
      const hoursSinceRegister =
        (Date.now() - createdAt.getTime()) / (1000 * 60 * 60);
      if (hoursSinceRegister > 24) {
        res.status(400).json({ error: 'Referral code must be used within 24 hours of registration' });
        return;
      }

      // 5. ห้าม refer ตัวเอง
      if (referee.miroId === referralCode) {
        res.status(400).json({ error: 'Cannot refer yourself' });
        return;
      }

      // 6. หา referrer (คนชวน) จาก MiRO ID
      const referrerSnapshot = await db
        .collection('users')
        .where('miroId', '==', referralCode)
        .limit(1)
        .get();

      if (referrerSnapshot.empty) {
        res.status(404).json({ error: 'Invalid referral code' });
        return;
      }

      const referrerDoc = referrerSnapshot.docs[0];
      const referrer = referrerDoc.data();
      const referrerDeviceId = referrerDoc.id;

      // 7. เช็ค referrer quota (2/month)
      const currentMonth = new Date().toISOString().slice(0, 7) + '-01';
      const resetDate = referrer.referrals?.referralResetDate || '';

      let referralCount = referrer.referrals?.referralCount || 0;
      if (resetDate !== currentMonth) {
        referralCount = 0; // เดือนใหม่ → reset
      }

      if (referralCount >= 2) {
        res.status(400).json({ error: 'Referrer has reached monthly limit' });
        return;
      }

      // 8. Anti-fraud: IP check
      const refereeIp = req.ip || req.headers['x-forwarded-for'] || 'unknown';
      // (optional) เช็คว่า IP เดียวกับ referrer หรือไม่

      // 9. ให้ referee +5 Energy bonus ทันที
      const refereeBonus = 5;
      await db.runTransaction(async (transaction) => {
        const refDoc = await transaction.get(
          db.collection('users').doc(deviceId)
        );
        const currentBalance = refDoc.data()?.balance || 0;

        transaction.update(db.collection('users').doc(deviceId), {
          balance: currentBalance + refereeBonus,
          'referrals.referredBy': referralCode,
          'referrals.referredByDeviceId': referrerDeviceId,
        });

        // Log transaction
        const txRef = db.collection('transactions').doc();
        transaction.set(txRef, {
          deviceId,
          miroId: referee.miroId,
          type: 'referral',
          amount: refereeBonus,
          balanceAfter: currentBalance + refereeBonus,
          description: `Referral bonus: joined via ${referralCode}`,
          metadata: { referrerMiroId: referralCode, role: 'referee' },
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      });

      // 10. สร้าง referral record (pending — รอ referee ใช้ AI 3 ครั้ง)
      await db.collection('referral_records').add({
        referrerId: referrerDeviceId,
        referrerMiroId: referralCode,
        refereeId: deviceId,
        refereeMiroId: referee.miroId,
        status: 'pending',
        refereeAiUsageCount: 0,
        requiredUsage: 3,
        referrerReward: 15,
        refereeReward: refereeBonus,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        completedAt: null,
        expiresAt: admin.firestore.Timestamp.fromDate(
          new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
        ),
        ip: { referee: String(refereeIp) },
      });

      res.status(200).json({
        success: true,
        bonusEnergy: refereeBonus,
        message: `Referral code accepted! +${refereeBonus} Energy`,
      });
    } catch (error: any) {
      console.error('❌ [submitReferralCode]', error);
      res.status(500).json({ error: error.message });
    }
  }
);
```

### 1.5 Referral Completion (ใน analyzeFood)

```typescript
// ใน analyzeFood.ts — หลังจาก AI call สำเร็จ:

async function checkReferralCompletion(deviceId: string): Promise<void> {
  // หา pending referral record ที่ referee = deviceId
  const records = await db
    .collection('referral_records')
    .where('refereeId', '==', deviceId)
    .where('status', '==', 'pending')
    .limit(1)
    .get();

  if (records.empty) return;

  const record = records.docs[0];
  const data = record.data();

  // เช็คว่าหมดอายุหรือยัง (7 วัน)
  if (data.expiresAt.toDate() < new Date()) {
    await record.ref.update({ status: 'expired' });
    return;
  }

  // Increment usage count
  const newCount = (data.refereeAiUsageCount || 0) + 1;
  await record.ref.update({ refereeAiUsageCount: newCount });

  // ถ้าครบ 3 ครั้ง → ให้ referrer reward
  if (newCount >= data.requiredUsage) {
    const referrerDeviceId = data.referrerId;
    const reward = data.referrerReward; // 15

    await db.runTransaction(async (transaction) => {
      const referrerRef = db.collection('users').doc(referrerDeviceId);
      const referrerDoc = await transaction.get(referrerRef);

      if (!referrerDoc.exists) return;

      const referrer = referrerDoc.data()!;
      const newBalance = (referrer.balance || 0) + reward;
      const currentMonth = new Date().toISOString().slice(0, 7) + '-01';

      transaction.update(referrerRef, {
        balance: newBalance,
        totalEarned: (referrer.totalEarned || 0) + reward,
        'referrals.referralCount': admin.firestore.FieldValue.increment(1),
        'referrals.referralResetDate': currentMonth,
        'referrals.referredUsers': admin.firestore.FieldValue.arrayUnion(data.refereeMiroId),
      });

      // Log
      const txRef = db.collection('transactions').doc();
      transaction.set(txRef, {
        deviceId: referrerDeviceId,
        miroId: referrer.miroId,
        type: 'referral',
        amount: reward,
        balanceAfter: newBalance,
        description: `Referral completed: ${data.refereeMiroId} used AI 3 times`,
        metadata: { refereeMiroId: data.refereeMiroId, role: 'referrer' },
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Update record
      transaction.update(record.ref, {
        status: 'completed',
        completedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    // TODO (Phase 3): Send notification to referrer
    console.log(`🎉 Referral completed! ${data.referrerMiroId} gets +${reward} Energy`);
  }
}
```

### 1.6 Checklist

```
□ สร้าง functions/src/energy/referral.ts (submitReferralCode)
□ เพิ่ม checkReferralCompletion ใน analyzeFood.ts
□ สร้าง referral_records collection
□ อัพเดท users schema (referrals field)
□ Cron: expire pending referrals > 7 วัน
□ Cron: reset referralCount ทุกเดือน
□ Anti-fraud: IP check
□ ทดสอบ: full referral flow
□ ทดสอบ: refer ตัวเอง → error
□ ทดสอบ: quota 2/month → error on 3rd
□ ทดสอบ: referee ไม่ใช้ AI ภายใน 7 วัน → expired
```

---

## Task 2: Comeback Bonus

### 2.1 Overview

| หายไป | Reward | เงื่อนไข |
|-------|--------|---------|
| 3-7 วัน | 3 Energy | ได้แค่ 1 ครั้ง/60 วัน |
| 7-14 วัน | 5 Energy | ได้แค่ 1 ครั้ง/60 วัน |
| 14-30 วัน | 10 Energy | ได้แค่ 1 ครั้ง/60 วัน |
| 30+ วัน | 15 Energy | ได้แค่ 1 ครั้ง/60 วัน |

### 2.2 Logic

```
เมื่อ user เปิดแอป (syncBalance / registerOrSync):

1. ดึง lastCheckInDate
2. คำนวณ daysSinceLastCheckIn
3. ถ้า daysSinceLastCheckIn >= 3:
   → เช็คว่าเคยได้ comeback bonus ใน 60 วันที่ผ่านมาหรือไม่
   → ถ้ายัง → ให้ comeback bonus ตาม tier
4. แสดง "Welcome Back!" dialog ใน app
```

### 2.3 Cloud Function: checkComebackBonus

```typescript
/**
 * checkComebackBonus
 *
 * เรียกจาก processCheckIn (dailyCheckIn.ts)
 * เมื่อ user กลับมาหลังหายไปนาน
 */

export async function checkComebackBonus(
  deviceId: string,
  daysSinceLastCheckIn: number
): Promise<{ bonusAmount: number } | null> {
  if (daysSinceLastCheckIn < 3) return null;

  const userRef = db.collection('users').doc(deviceId);
  const userDoc = await userRef.get();
  if (!userDoc.exists) return null;

  const user = userDoc.data()!;

  // เช็คว่าได้ comeback bonus ใน 60 วันที่ผ่านมาหรือไม่
  const lastComeback = user.lastComebackBonus;
  if (lastComeback) {
    const daysSinceComeback = Math.floor(
      (Date.now() - new Date(lastComeback).getTime()) / 86400000
    );
    if (daysSinceComeback < 60) return null; // ยังไม่ครบ 60 วัน
  }

  // คำนวณ bonus
  let bonusAmount: number;
  if (daysSinceLastCheckIn >= 30) bonusAmount = 15;
  else if (daysSinceLastCheckIn >= 14) bonusAmount = 10;
  else if (daysSinceLastCheckIn >= 7) bonusAmount = 5;
  else bonusAmount = 3;

  // ให้ bonus
  const newBalance = (user.balance || 0) + bonusAmount;
  const today = new Date().toISOString().split('T')[0];

  await userRef.update({
    balance: newBalance,
    totalEarned: (user.totalEarned || 0) + bonusAmount,
    lastComebackBonus: today,
  });

  // Log transaction
  await db.collection('transactions').add({
    deviceId,
    miroId: user.miroId,
    type: 'comeback',
    amount: bonusAmount,
    balanceAfter: newBalance,
    description: `Welcome back! +${bonusAmount} Energy (${daysSinceLastCheckIn} days away)`,
    metadata: { daysAway: daysSinceLastCheckIn },
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { bonusAmount };
}
```

### 2.4 Checklist

```
□ สร้าง checkComebackBonus function
□ Integrate กับ processCheckIn (เมื่อ streak reset)
□ เพิ่ม lastComebackBonus field ใน users schema
□ ส่ง Win-back notification (หลังหายไป 3 วัน)
□ Flutter: "Welcome Back!" dialog
□ ทดสอบ: หายไป 5 วัน → +3 Energy
□ ทดสอบ: หายไป 10 วัน → +5 Energy
□ ทดสอบ: ได้ comeback แล้ว → ต้องรอ 60 วัน
```

---

## Task 3: A/B Testing Framework

### 3.1 Overview

ทดสอบค่า reward ต่างๆ เพื่อหา optimal balance:

```
Test 1: Day 7 Streak Reward
  Group A: 10 Energy (default)
  Group B: 15 Energy

Test 2: Weekly Challenge Reward
  Group A: 5 Energy (default)
  Group B: 7 Energy

Test 3: Random Bonus Chance
  Group A: 5% (default)
  Group B: 8%
```

### 3.2 Implementation

```typescript
// Firestore: config/ab_tests
interface ABTest {
  testId: string;
  name: string;
  description: string;
  status: 'active' | 'paused' | 'completed';
  groups: {
    A: { name: string; config: Record<string, any> };
    B: { name: string; config: Record<string, any> };
  };
  allocation: number; // 0.5 = 50/50 split
  startDate: string;
  endDate: string | null;
}

// เพิ่มใน users/{deviceId}:
abTestGroups: {
  [testId: string]: 'A' | 'B';
};
```

```typescript
// Helper: assign user to A/B group
function getABGroup(deviceId: string, testId: string, allocation: number): 'A' | 'B' {
  // Deterministic: same user always gets same group
  const hash = crypto
    .createHash('md5')
    .update(`${deviceId}:${testId}`)
    .digest('hex');
  const value = parseInt(hash.substring(0, 8), 16) / 0xFFFFFFFF;
  return value < allocation ? 'A' : 'B';
}

// Helper: get config value considering A/B test
async function getConfigValue(
  deviceId: string,
  configKey: string,
  defaultValue: any
): Promise<any> {
  // เช็คว่ามี active A/B test สำหรับ config key นี้หรือไม่
  const tests = await db
    .collection('config')
    .doc('ab_tests')
    .get();

  // ... resolve group → return appropriate value
  return defaultValue;
}
```

### 3.3 Admin: A/B Test Dashboard

```
แสดง:
- Test name + status
- Group A vs Group B metrics:
  - DAU, Retention, Revenue, Streak length
- Statistical significance (p-value)
- Winner recommendation
```

### 3.4 Checklist

```
□ สร้าง A/B test schema (config/ab_tests)
□ สร้าง deterministic group assignment
□ แก้ไข Cloud Functions ให้อ่าน A/B config
□ Admin: A/B test management page
□ Admin: A/B test results dashboard
□ ทดสอบ: same user always gets same group
□ ทดสอบ: 50/50 split ~50% each group
```

---

## Task 4: Flutter Client

### 4.1 Referral UI

```dart
/// หน้า Invite Friends
///
/// ┌──────────────────────────────┐
/// │ 🤝 Invite Friends            │
/// │                              │
/// │ Your referral code:          │
/// │ ┌────────────────────────┐   │
/// │ │ MIRO-A3F9-K7X2-P8M1  │   │
/// │ │          [📋 Copy]    │   │
/// │ └────────────────────────┘   │
/// │                              │
/// │ [📤 Share Code]              │
/// │                              │
/// │ Earn 15 Energy per friend!   │
/// │ (Max 2 per month)            │
/// │                              │
/// │ This month: 1/2 referred     │
/// │                              │
/// │ ── Enter a referral code ──  │
/// │ ┌────────────────────────┐   │
/// │ │ Enter code...          │   │
/// │ └────────────────────────┘   │
/// │ [Submit Code]                │
/// └──────────────────────────────┘
```

### 4.2 Comeback Dialog

```dart
/// แสดงเมื่อ user กลับมาหลังหายไป 3+ วัน
///
/// ┌──────────────────────────────┐
/// │                              │
/// │     👋 Welcome Back!         │
/// │                              │
/// │  We missed you!              │
/// │  Here's a bonus:             │
/// │                              │
/// │       ⚡ +5 Energy           │
/// │                              │
/// │  Your streak was reset       │
/// │  but your Gold tier stays!   │
/// │                              │
/// │     [Let's Go! 🚀]          │
/// └──────────────────────────────┘
```

### 4.3 Checklist

```
□ สร้าง referral_screen.dart
□ สร้าง comeback_dialog.dart
□ แก้ไข profile_screen.dart (เพิ่ม Invite Friends link)
□ Handle submitReferralCode API
□ Handle comebackBonus ใน sync response
□ Share functionality (Share.share)
□ Copy to clipboard
```

---

## Task 5: Testing Checklist

### Referral

```
□ User A share code → User B ใส่ → B ได้ +5 Energy
□ User B ใช้ AI 3 ครั้ง → User A ได้ +15 Energy
□ User A refer 2 friends → quota full
□ User A refer 3rd friend → error
□ เดือนใหม่ → quota reset
□ Refer ตัวเอง → error
□ ใส่ code หลัง 24 ชั่วโมง → error
□ Friend ไม่ใช้ AI ภายใน 7 วัน → expired
□ Invalid MiRO ID → error
```

### Comeback

```
□ หายไป 3 วัน → +3 Energy
□ หายไป 10 วัน → +5 Energy
□ หายไป 20 วัน → +10 Energy
□ หายไป 45 วัน → +15 Energy
□ ได้ comeback แล้ว → ต้องรอ 60 วัน
□ Tier ยังอยู่หลัง comeback
□ Dialog แสดงถูกต้อง
```

### A/B Testing

```
□ User ถูก assign group เดียวกันทุกครั้ง
□ ~50/50 split
□ Config values ถูกต้องตาม group
□ Admin: สร้าง/หยุด/จบ test ได้
```

---

## ⏰ Timeline

```
Day 1-4:   Task 1 (Referral System - backend + fraud)
Day 5-6:   Task 2 (Comeback Bonus)
Day 7-8:   Task 3 (A/B Testing Framework)
Day 9-11:  Task 4 (Flutter Client)
Day 12-14: Task 5 (Testing)
```
