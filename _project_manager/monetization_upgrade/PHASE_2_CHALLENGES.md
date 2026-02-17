# Phase 2: Challenges & Milestones — คู่มือ Implementation

**Scope:** Weekly Challenges + Milestone Rewards + Bonus Energy + Random Daily Bonus  
**ระยะเวลา:** 2 สัปดาห์  
**ต้องทำ Phase 1 เสร็จก่อน:** MiRO ID, Free AI, Streak Tier ต้องทำงานแล้ว

---

## สารบัญ

- [Task 1: Weekly Challenges](#task-1-weekly-challenges)
- [Task 2: Milestone Rewards](#task-2-milestone-rewards)
- [Task 3: Bonus Energy System](#task-3-bonus-energy-system)
- [Task 4: Random Daily Bonus](#task-4-random-daily-bonus)
- [Task 5: Cron Jobs](#task-5-cron-jobs)
- [Task 6: Flutter Client](#task-6-flutter-client)
- [Task 7: Testing Checklist](#task-7-testing-checklist)

---

## Task 1: Weekly Challenges

### 1.1 Overview

| Challenge | Target | Reward | Reset |
|-----------|--------|--------|-------|
| Log meals | 7 meals/week | 5 Energy | ทุกวันจันทร์ 00:00 (UTC+7) |
| Use AI | 3 times/week (free + paid) | 5 Energy | ทุกวันจันทร์ 00:00 (UTC+7) |

### 1.2 Firestore Schema Update

เพิ่มใน `users/{deviceId}` (Phase 1 เตรียม field ไว้แล้ว):

```typescript
challenges: {
  weekly: {
    logMeals: number;           // 0-7 (increment เมื่อ log meal)
    useAi: number;              // 0-3 (increment เมื่อใช้ AI)
    claimedRewards: string[];   // ["logMeals"] หรือ ["logMeals", "useAi"]
    weekStartDate: string;      // "YYYY-MM-DD" (วันจันทร์ของสัปดาห์นี้)
  };
}
```

### 1.3 Progress Tracking

**"Log meals" challenge — increment เมื่อไหร่?**

ทุกครั้งที่ `analyzeFood` สำเร็จ (ทั้ง free + paid) + type เป็น food analysis:

```typescript
// ใน analyzeFood.ts — หลังจาก Gemini response สำเร็จ:

async function incrementChallengeProgress(
  deviceId: string,
  challengeType: 'logMeals' | 'useAi'
): Promise<void> {
  const userRef = db.collection('users').doc(deviceId);
  const today = getTodayString();
  const weekStart = getWeekStartDate(today); // วันจันทร์ของสัปดาห์นี้

  await db.runTransaction(async (transaction) => {
    const userDoc = await transaction.get(userRef);
    if (!userDoc.exists) return;

    const user = userDoc.data()!;
    const challenges = user.challenges?.weekly || {};
    const storedWeekStart = challenges.weekStartDate || '';

    // ถ้าสัปดาห์ใหม่ → reset
    if (storedWeekStart !== weekStart) {
      transaction.update(userRef, {
        'challenges.weekly': {
          logMeals: challengeType === 'logMeals' ? 1 : 0,
          useAi: challengeType === 'useAi' ? 1 : 0,
          claimedRewards: [],
          weekStartDate: weekStart,
        },
      });
      return;
    }

    // สัปดาห์เดิม → increment
    const currentValue = challenges[challengeType] || 0;
    const target = challengeType === 'logMeals' ? 7 : 3;

    if (currentValue < target) {
      transaction.update(userRef, {
        [`challenges.weekly.${challengeType}`]: currentValue + 1,
      });
    }
  });
}

// Helper: หาวันจันทร์ของสัปดาห์
function getWeekStartDate(dateStr: string): string {
  const date = new Date(dateStr);
  const day = date.getDay(); // 0=Sun, 1=Mon, ...
  const diff = day === 0 ? 6 : day - 1; // จำนวนวันถอยกลับไปวันจันทร์
  date.setDate(date.getDate() - diff);
  return date.toISOString().split('T')[0];
}
```

**เรียก increment ที่ไหน?**

```typescript
// ใน analyzeFood.ts:

// หลัง Gemini response สำเร็จ (ทั้ง free + paid):
// 1. Log meals (ทุกครั้งที่ analyze อาหาร)
if (['image', 'text', 'barcode', 'chat'].includes(type)) {
  await incrementChallengeProgress(deviceId, 'logMeals');
}

// 2. Use AI (ทุกครั้งที่ใช้ AI ไม่ว่า type ไหน)
await incrementChallengeProgress(deviceId, 'useAi');
```

### 1.4 Cloud Function: completeChallenge

สร้างไฟล์ `functions/src/energy/challenge.ts`:

```typescript
/**
 * completeChallenge
 *
 * เรียกเมื่อ: User กดปุ่ม "Claim Reward" หลัง challenge สำเร็จ
 * Server verify: progress ถึง target จริงหรือไม่ (ไม่เชื่อ client)
 *
 * Input:  { deviceId, challengeType: 'logMeals' | 'useAi' }
 * Output: { success, energyReward, newBalance }
 */

import { onRequest } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

const CHALLENGE_CONFIG: Record<string, { target: number; reward: number }> = {
  logMeals: { target: 7, reward: 5 },
  useAi:    { target: 3, reward: 5 },
};

export const completeChallenge = onRequest(
  {
    timeoutSeconds: 10,
    memory: '256MiB',
    cors: '*',
  },
  async (req, res) => {
    if (req.method !== 'POST') {
      res.status(405).json({ error: 'Method not allowed' });
      return;
    }

    try {
      const { deviceId, challengeType } = req.body;

      if (!deviceId || !challengeType) {
        res.status(400).json({ error: 'Missing deviceId or challengeType' });
        return;
      }

      const config = CHALLENGE_CONFIG[challengeType];
      if (!config) {
        res.status(400).json({ error: `Invalid challengeType: ${challengeType}` });
        return;
      }

      const result = await db.runTransaction(async (transaction) => {
        const userRef = db.collection('users').doc(deviceId);
        const userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          throw new Error('User not found');
        }

        const user = userDoc.data()!;
        const challenges = user.challenges?.weekly || {};
        const progress = challenges[challengeType] || 0;
        const claimed = challenges.claimedRewards || [];

        // เช็คว่าเคลมแล้วหรือยัง
        if (claimed.includes(challengeType)) {
          throw new Error('Already claimed this challenge reward');
        }

        // เช็คว่า progress ถึง target หรือยัง (SERVER verify!)
        if (progress < config.target) {
          throw new Error(
            `Challenge not completed: ${progress}/${config.target}`
          );
        }

        // Award reward
        const newBalance = (user.balance || 0) + config.reward;

        transaction.update(userRef, {
          balance: newBalance,
          totalEarned: (user.totalEarned || 0) + config.reward,
          'challenges.weekly.claimedRewards': [...claimed, challengeType],
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Log transaction
        const txRef = db.collection('transactions').doc();
        transaction.set(txRef, {
          deviceId,
          miroId: user.miroId || 'unknown',
          type: 'challenge',
          amount: config.reward,
          balanceAfter: newBalance,
          description: `Weekly challenge completed: ${challengeType}`,
          metadata: { challengeType, progress },
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        return { energyReward: config.reward, newBalance };
      });

      res.status(200).json({
        success: true,
        ...result,
      });
    } catch (error: any) {
      console.error('❌ [completeChallenge]', error);
      res.status(400).json({ error: error.message });
    }
  }
);
```

### 1.5 Checklist

```
□ เพิ่ม incrementChallengeProgress ใน analyzeFood.ts
□ สร้าง functions/src/energy/challenge.ts
□ Export ใน index.ts
□ ทดสอบ: log 7 meals → challenge สำเร็จ → claim 5 Energy
□ ทดสอบ: use AI 3 times (free + paid) → challenge สำเร็จ
□ ทดสอบ: claim ซ้ำ → error
□ ทดสอบ: progress ไม่ถึง + claim → error
□ ทดสอบ: สัปดาห์ใหม่ → progress reset
```

---

## Task 2: Milestone Rewards

### 2.1 Overview

| Milestone | Condition | Reward | ได้ครั้งเดียว |
|-----------|-----------|--------|-------------|
| 500 Energy spent | totalSpent >= 500 | 15 Energy back | ✅ |
| 1000 Energy spent | totalSpent >= 1000 | 30 Energy back | ✅ |

### 2.2 Tracking totalSpent

**ที่ไหน:** ทุกครั้งที่ `analyzeFood` หัก energy (ไม่นับ free AI)

```typescript
// ใน analyzeFood.ts — หลังจาก deductServerBalance สำเร็จ:

await db.collection('users').doc(deviceId).update({
  totalSpent: admin.firestore.FieldValue.increment(energyCost),
});
```

### 2.3 Cloud Function: claimMilestone

สร้างไฟล์ `functions/src/energy/milestone.ts`:

```typescript
/**
 * claimMilestone
 *
 * Input:  { deviceId, milestoneType: 'spent500' | 'spent1000' }
 * Output: { success, energyReward, newBalance }
 */

import { onRequest } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

const MILESTONE_CONFIG: Record<string, { threshold: number; reward: number }> = {
  spent500:  { threshold: 500,  reward: 15 },
  spent1000: { threshold: 1000, reward: 30 },
};

export const claimMilestone = onRequest(
  {
    timeoutSeconds: 10,
    memory: '256MiB',
    cors: '*',
  },
  async (req, res) => {
    if (req.method !== 'POST') {
      res.status(405).json({ error: 'Method not allowed' });
      return;
    }

    try {
      const { deviceId, milestoneType } = req.body;

      if (!deviceId || !milestoneType) {
        res.status(400).json({ error: 'Missing fields' });
        return;
      }

      const config = MILESTONE_CONFIG[milestoneType];
      if (!config) {
        res.status(400).json({ error: `Invalid milestoneType: ${milestoneType}` });
        return;
      }

      const result = await db.runTransaction(async (transaction) => {
        const userRef = db.collection('users').doc(deviceId);
        const userDoc = await transaction.get(userRef);

        if (!userDoc.exists) throw new Error('User not found');

        const user = userDoc.data()!;
        const totalSpent = user.totalSpent || 0;
        const milestones = user.milestones || {};

        // เช็คว่าเคลมแล้วหรือยัง
        const claimKey = `${milestoneType}Claimed`;
        if (milestones[claimKey]) {
          throw new Error('Milestone already claimed');
        }

        // เช็ค threshold (SERVER verify!)
        if (totalSpent < config.threshold) {
          throw new Error(
            `Milestone not reached: ${totalSpent}/${config.threshold}`
          );
        }

        const newBalance = (user.balance || 0) + config.reward;

        transaction.update(userRef, {
          balance: newBalance,
          totalEarned: (user.totalEarned || 0) + config.reward,
          [`milestones.${claimKey}`]: true,
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        });

        const txRef = db.collection('transactions').doc();
        transaction.set(txRef, {
          deviceId,
          miroId: user.miroId || 'unknown',
          type: 'milestone',
          amount: config.reward,
          balanceAfter: newBalance,
          description: `Milestone reached: ${totalSpent} Energy spent`,
          metadata: { milestoneType, totalSpent },
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        return { energyReward: config.reward, newBalance };
      });

      res.status(200).json({ success: true, ...result });
    } catch (error: any) {
      console.error('❌ [claimMilestone]', error);
      res.status(400).json({ error: error.message });
    }
  }
);
```

### 2.4 Checklist

```
□ อัพเดท totalSpent ใน analyzeFood.ts (เมื่อหัก energy)
□ สร้าง functions/src/energy/milestone.ts
□ Export ใน index.ts
□ ทดสอบ: totalSpent = 500 → claim 15 Energy
□ ทดสอบ: totalSpent = 1000 → claim 30 Energy
□ ทดสอบ: claim ซ้ำ → error
□ ทดสอบ: totalSpent < threshold → error
```

---

## Task 3: Bonus Energy System

### 3.1 Overview

แทน Discount — ให้ Bonus Energy เมื่อซื้อ:

| Tier | Bonus Rate | ตัวอย่าง |
|------|-----------|---------|
| None/Bronze/Silver | 0% | ซื้อ 100 → ได้ 100 |
| Gold | +20% | ซื้อ 100 → ได้ 120 |
| Diamond | +30% | ซื้อ 100 → ได้ 130 |

### 3.2 แก้ไข verifyPurchase.ts

```typescript
// ใน verifyPurchase.ts — หลังจาก verify purchase สำเร็จ:

// เดิม:
const energyAmount = PRODUCT_MAP[productId]; // e.g. 100

// ใหม่:
const baseEnergy = PRODUCT_MAP[productId]; // e.g. 100

// ดึง user tier เพื่อคำนวณ bonus
const userDoc = await db.collection('users').doc(deviceId).get();
const bonusRate = userDoc.data()?.bonusRate || 0; // 0, 0.2, or 0.3

const bonusEnergy = Math.floor(baseEnergy * bonusRate);
const totalEnergy = baseEnergy + bonusEnergy;

console.log(`💎 Purchase: ${baseEnergy} + ${bonusEnergy} bonus = ${totalEnergy}`);

// เพิ่ม energy ด้วย totalEnergy (ไม่ใช่ baseEnergy)
await addServerBalance(deviceId, totalEnergy, 'purchase');

// อัพเดท totalPurchased
await db.collection('users').doc(deviceId).update({
  totalPurchased: admin.firestore.FieldValue.increment(totalEnergy),
});

// บันทึก transaction ด้วย breakdown
await db.collection('transactions').add({
  deviceId,
  miroId: userDoc.data()?.miroId || 'unknown',
  type: 'purchase',
  amount: totalEnergy,
  balanceAfter: newBalance,
  description: `Purchased ${baseEnergy} Energy` +
    (bonusEnergy > 0 ? ` + ${bonusEnergy} Bonus (${bonusRate * 100}%)` : ''),
  metadata: {
    productId,
    baseEnergy,
    bonusRate,
    bonusEnergy,
    totalEnergy,
    purchaseToken,
  },
  createdAt: admin.firestore.FieldValue.serverTimestamp(),
});
```

### 3.3 Checklist

```
□ แก้ไข verifyPurchase.ts (ดึง bonusRate จาก user + คำนวณ bonus)
□ บันทึก transaction พร้อม breakdown
□ ทดสอบ: Gold user (20%) ซื้อ 100 → ได้ 120
□ ทดสอบ: Diamond user (30%) ซื้อ 100 → ได้ 130
□ ทดสอบ: None/Bronze/Silver user → ไม่มี bonus
□ ทดสอบ: bonusRate เปลี่ยนหลัง tier upgrade → purchase ถัดไปได้ bonus
```

---

## Task 4: Random Daily Bonus

### 4.1 Overview

- ทุกวันที่ check-in → roll 5% chance
- ถ้าโชคดี → ได้ 5-10 Energy ฟรี
- แสดง animation ใน app (surprise & delight)

### 4.2 Logic

**เรียกตอนไหน:** ใน `processCheckIn` (Phase 1 — dailyCheckIn.ts)

```typescript
// เพิ่มใน processCheckIn (dailyCheckIn.ts):

// ─── Random Bonus ───
let randomBonus = 0;
const featureFlags = await getFeatureFlags(); // อ่านจาก config/features

if (featureFlags.enableRandomBonus) {
  const config = await getRewardsConfig(); // อ่านจาก config/rewards
  const chance = config.randomBonus?.chance || 0.05;
  const minReward = config.randomBonus?.minReward || 5;
  const maxReward = config.randomBonus?.maxReward || 10;

  // ม้วนลูกเต๋า
  const roll = Math.random();
  if (roll < chance) {
    randomBonus = Math.floor(
      Math.random() * (maxReward - minReward + 1) + minReward
    );

    // เพิ่ม energy
    transaction.update(userRef, {
      balance: (currentBalance + energyBonus + randomBonus),
      lastRandomBonus: today,
      randomBonusCount: admin.firestore.FieldValue.increment(1),
    });

    // Log transaction
    const txRef = db.collection('transactions').doc();
    transaction.set(txRef, {
      deviceId,
      miroId: user.miroId || 'unknown',
      type: 'random_bonus',
      amount: randomBonus,
      balanceAfter: currentBalance + energyBonus + randomBonus,
      description: `Lucky! Random bonus: +${randomBonus} Energy 🎲`,
      metadata: { roll, chance },
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }
}

// เพิ่มใน return:
return {
  // ... existing fields ...
  randomBonus,
  gotRandomBonus: randomBonus > 0,
};
```

### 4.3 Checklist

```
□ เพิ่ม random bonus logic ใน processCheckIn
□ อ่าน config จาก config/rewards (ไม่ hardcode chance)
□ เช็ค feature flag enableRandomBonus
□ ทดสอบ: 5% chance → ~5 ใน 100 ครั้ง
□ ทดสอบ: ได้ 5-10 Energy (random)
□ ทดสอบ: feature flag off → ไม่ roll
```

---

## Task 5: Cron Jobs

### 5.1 Overview

| Cron Job | Schedule | สิ่งที่ทำ |
|----------|----------|----------|
| Reset Weekly Challenges | ทุกวันจันทร์ 00:00 UTC+7 | reset logMeals, useAi, claimedRewards |

### 5.2 Weekly Challenge Reset

สร้างไฟล์ `functions/src/cron/resetWeeklyChallenges.ts`:

```typescript
/**
 * resetWeeklyChallenges
 *
 * Schedule: ทุกวันจันทร์ 00:00 (UTC+7 = 17:00 UTC วันอาทิตย์)
 * สิ่งที่ทำ: Reset weekly challenge progress ของทุก user
 *
 * หมายเหตุ: ใช้ lazy reset ใน incrementChallengeProgress แทนก็ได้
 * แต่ cron job ดีกว่าเพราะ:
 * - ล้าง claimedRewards ให้ claim ใหม่ได้
 * - ข้อมูลสะอาดสำหรับ admin dashboard
 */

import { onSchedule } from 'firebase-functions/v2/scheduler';
import * as admin from 'firebase-admin';

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

export const resetWeeklyChallenges = onSchedule(
  {
    // ทุกวันจันทร์ 00:00 UTC+7 = วันอาทิตย์ 17:00 UTC
    schedule: '0 17 * * 0',
    timeZone: 'UTC',
    timeoutSeconds: 540,
    memory: '512MiB',
  },
  async () => {
    console.log('🔄 [Cron] Resetting weekly challenges...');

    const today = new Date().toISOString().split('T')[0];
    let processed = 0;
    let errors = 0;

    // Batch process users (500 per batch — Firestore limit)
    let lastDoc: any = null;
    const batchSize = 500;

    while (true) {
      let query = db.collection('users')
        .orderBy('deviceId')
        .limit(batchSize);

      if (lastDoc) {
        query = query.startAfter(lastDoc);
      }

      const snapshot = await query.get();

      if (snapshot.empty) break;

      const batch = db.batch();

      for (const doc of snapshot.docs) {
        try {
          batch.update(doc.ref, {
            'challenges.weekly.logMeals': 0,
            'challenges.weekly.useAi': 0,
            'challenges.weekly.claimedRewards': [],
            'challenges.weekly.weekStartDate': today,
          });
          processed++;
        } catch (err) {
          errors++;
        }
      }

      await batch.commit();
      lastDoc = snapshot.docs[snapshot.docs.length - 1];

      console.log(`🔄 [Cron] Processed ${processed} users...`);
    }

    console.log(
      `✅ [Cron] Weekly challenges reset: ${processed} users, ${errors} errors`
    );
  }
);
```

### 5.3 Checklist

```
□ สร้าง functions/src/cron/resetWeeklyChallenges.ts
□ Export ใน index.ts
□ Deploy & verify cron schedule
□ ทดสอบ: manual trigger → progress reset เป็น 0
□ ทดสอบ: claimedRewards ถูก clear
□ Monitor: Cloud Functions logs ทุกวันจันทร์
```

---

## Task 6: Flutter Client

### 6.1 UI Components ที่ต้องสร้าง

#### 6.1.1 Weekly Challenge Card

```dart
/// แสดง progress ของ weekly challenge
/// ตำแหน่ง: หน้า Home หรือ Energy screen
///
/// UI:
/// ┌──────────────────────────────┐
/// │ 📋 Weekly Challenges         │
/// │                              │
/// │ 🍽 Log 7 meals     [5/7] ████░  │
/// │                    [Claim!]  │ ← ถ้าครบ 7 + ยังไม่ claim
/// │                              │
/// │ 🤖 Use AI 3 times  [3/3] █████  │
/// │                    [✅ Done] │ ← ถ้า claim แล้ว
/// │                              │
/// │ ⏰ Resets in 3d 14h          │
/// └──────────────────────────────┘
```

#### 6.1.2 Milestone Progress Card

```dart
/// แสดง progress ของ milestone
///
/// UI:
/// ┌──────────────────────────────┐
/// │ 🏆 Milestones                │
/// │                              │
/// │ 500 Energy spent     [245/500]  │
/// │ ████████░░░░  49%    +15 ⚡  │
/// │                              │
/// │ 1000 Energy spent    [245/1000] │
/// │ ████░░░░░░░░  25%    +30 ⚡  │
/// └──────────────────────────────┘
```

#### 6.1.3 Random Bonus Animation

```dart
/// เมื่อได้ random bonus → แสดง popup animation
///
/// UI:
/// ┌──────────────────────────────┐
/// │                              │
/// │         🎲 LUCKY! 🎲         │
/// │                              │
/// │      You got 8 Energy!       │
/// │         ⚡ +8 ⚡             │
/// │                              │
/// │        [Awesome! 🎉]         │
/// └──────────────────────────────┘
```

#### 6.1.4 Bonus Energy Badge (Purchase Screen)

```dart
/// แสดงใน Energy Store ว่า user ได้ bonus rate เท่าไหร่
///
/// UI (Gold user):
/// ┌──────────────────────────────┐
/// │ 100 Energy — ฿99             │
/// │ 🥇 Gold Bonus: +20 FREE!    │
/// │ Total: 120 Energy            │
/// └──────────────────────────────┘
```

### 6.2 Provider Updates

```dart
// เพิ่มใน gamification_provider.dart:

// Challenge state
final weeklyChallenge = user['challenges']?['weekly'] ?? {};
final logMealsProgress = weeklyChallenge['logMeals'] ?? 0;
final useAiProgress = weeklyChallenge['useAi'] ?? 0;
final claimedRewards = List<String>.from(weeklyChallenge['claimedRewards'] ?? []);

// Milestone state
final totalSpent = user['totalSpent'] ?? 0;
final spent500Claimed = user['milestones']?['spent500Claimed'] ?? false;
final spent1000Claimed = user['milestones']?['spent1000Claimed'] ?? false;
```

### 6.3 Checklist

```
□ สร้าง weekly_challenge_card.dart widget
□ สร้าง milestone_progress_card.dart widget
□ สร้าง random_bonus_dialog.dart (animation popup)
□ แก้ไข energy_store_screen.dart (แสดง bonus rate)
□ แก้ไข gamification_provider.dart (เพิ่ม challenge + milestone state)
□ แก้ไข home_screen.dart (แสดง challenge + milestone)
□ Handle completeChallenge API response
□ Handle claimMilestone API response
□ Handle randomBonus ใน check-in response → แสดง animation
```

---

## Task 7: Testing Checklist

### 7.1 Weekly Challenges

```
□ Log 1 meal → logMeals = 1
□ Log 7 meals → logMeals = 7 → claim → +5 Energy
□ Use free AI → useAi = 1
□ Use paid AI → useAi = 2
□ Use free + 2 paid = 3 → claim → +5 Energy
□ Claim ซ้ำ → error
□ สัปดาห์ใหม่ → progress reset เป็น 0
□ Claim ก่อน progress ถึง target → error
```

### 7.2 Milestones

```
□ totalSpent < 500 → claim → error
□ totalSpent = 500 → claim → +15 Energy
□ totalSpent = 1000 → claim → +30 Energy
□ Claim ซ้ำ → error
□ totalSpent increment ถูกต้องหลังทุก AI call
```

### 7.3 Bonus Energy

```
□ None tier ซื้อ 100 → ได้ 100 (no bonus)
□ Gold tier ซื้อ 100 → ได้ 120 (+20%)
□ Diamond tier ซื้อ 100 → ได้ 130 (+30%)
□ Tier upgrade → next purchase ได้ bonus ใหม่
```

### 7.4 Random Bonus

```
□ Feature flag off → ไม่ roll
□ Feature flag on → ~5% chance
□ Bonus amount: 5-10 range
□ Transaction บันทึกถูกต้อง
□ Client แสดง animation
```

### 7.5 Cron

```
□ resetWeeklyChallenges → progress reset
□ claimedRewards ถูก clear
□ ไม่กระทบข้อมูลอื่น (balance, streak, etc.)
```

---

## 📂 Files Summary (Phase 2)

### สร้างใหม่:

```
functions/src/
  energy/
    challenge.ts                ← completeChallenge
    milestone.ts                ← claimMilestone
  cron/
    resetWeeklyChallenges.ts    ← Weekly reset cron

lib/features/energy/widgets/
  weekly_challenge_card.dart    ← Challenge progress UI
  milestone_progress_card.dart  ← Milestone progress UI
  random_bonus_dialog.dart      ← Bonus animation
```

### แก้ไข:

```
functions/src/
  analyzeFood.ts               ← incrementChallengeProgress + totalSpent
  verifyPurchase.ts            ← Bonus Energy calculation
  energy/dailyCheckIn.ts       ← Random Bonus logic
  index.ts                     ← Export new functions

lib/features/energy/
  providers/gamification_provider.dart ← Challenge + Milestone state
  presentation/energy_store_screen.dart ← Bonus rate display
  widgets/energy_badge.dart    ← อาจเพิ่ม challenge indicator

lib/features/home/
  presentation/home_screen.dart ← Challenge + Milestone cards
```

---

## ⏰ Timeline

```
Day 1-2:   Task 1 (Weekly Challenges - backend)
Day 3-4:   Task 2 (Milestones - backend)
Day 5:     Task 3 (Bonus Energy - แก้ verifyPurchase)
Day 6:     Task 4 (Random Bonus - แก้ dailyCheckIn)
Day 7:     Task 5 (Cron Jobs)
Day 8-10:  Task 6 (Flutter Client - UI)
Day 11-14: Task 7 (Testing)
```
