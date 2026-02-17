# Task 4: Streak Tier System (Backend)

**ระยะเวลา:** 2 วัน  
**Complexity:** 🔴 Hard  
**ต้องรู้:** TypeScript, Cloud Functions, Firestore Transactions, Date calculation

---

## 🎯 สิ่งที่ต้องทำ

สร้าง Streak Tier System พร้อม Grace Period

### เป้าหมาย
1. สร้าง `claimDailyCheckIn` Cloud Function
2. คำนวณ streak ถูกต้อง (ต่อเนื่อง + grace period)
3. ปลดล็อค tier (Bronze → Silver → Gold → Diamond)
4. Integrate กับ Free AI (check-in อัตโนมัติ)

---

## 📚 ความรู้ที่ต้องมี

### Streak Tier Config

| Tier | Days | Reward | Grace Period |
|------|------|--------|-------------|
| Bronze | 7 | 10 Energy | 0 วัน |
| Silver | 14 | 15 Energy | 1 วัน |
| Gold | 30 | 30 Energy | 2 วัน |
| Diamond | 60 | 45 Energy | 3 วัน |

### Streak Logic

```
วันที่ 1: streak = 1, tier = none
วันที่ 7: streak = 7, tier = bronze (+10 Energy)
วันที่ 14: streak = 14, tier = silver (+15 Energy)

ถ้าหยุด 1 วัน (Silver tier):
  → Grace period = 1 วัน → streak ยังต่อ!

ถ้าหยุด 2 วัน (Silver tier):
  → เกิน grace → streak reset เป็น 1
  → แต่ tier ยังคง silver! (ไม่หลุด)
```

---

## 📝 ขั้นตอนการทำ (Step-by-Step)

### Step 4.1: สร้างไฟล์ dailyCheckIn.ts

**ที่อยู่:** `functions/src/energy/dailyCheckIn.ts`

**Code ที่ต้องเขียน:**

```typescript
/**
 * dailyCheckIn.ts
 * 
 * Streak Tier System with Grace Period
 */

import { onRequest } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

// ─── Tier Configuration ───
// (อ่านจาก config/rewards ใน production)
const TIER_CONFIG = {
  bronze:  { days: 7,  energy: 10, graceDays: 0 },
  silver:  { days: 14, energy: 15, graceDays: 1 },
  gold:    { days: 30, energy: 30, graceDays: 2 },
  diamond: { days: 60, energy: 45, graceDays: 3 },
};

const TIER_ORDER = ['none', 'bronze', 'silver', 'gold', 'diamond'];

/**
 * หา index ของ tier (สำหรับเปรียบเทียบ)
 */
function getTierIndex(tier: string): number {
  return TIER_ORDER.indexOf(tier);
}

/**
 * หา Grace Period ของ tier
 */
function getGraceDays(tier: string): number {
  switch (tier) {
    case 'silver': return 1;
    case 'gold': return 2;
    case 'diamond': return 3;
    default: return 0; // none, bronze
  }
}

/**
 * คำนวณจำนวนวันระหว่าง 2 วัน
 * 
 * @param dateStr1 "YYYY-MM-DD"
 * @param dateStr2 "YYYY-MM-DD"
 * @returns จำนวนวัน (absolute)
 */
function daysBetween(dateStr1: string, dateStr2: string): number {
  const d1 = new Date(dateStr1);
  const d2 = new Date(dateStr2);
  const diffMs = Math.abs(d2.getTime() - d1.getTime());
  return Math.floor(diffMs / (1000 * 60 * 60 * 24));
}

/**
 * ดึงวันที่ปัจจุบัน (YYYY-MM-DD)
 */
function getTodayString(timezoneOffset?: number): string {
  const now = new Date();
  const offset = timezoneOffset ?? 420; // UTC+7
  const localTime = new Date(now.getTime() + offset * 60 * 1000);
  return localTime.toISOString().split('T')[0];
}

// ─── Interface ───
export interface CheckInResult {
  success: boolean;
  currentStreak: number;
  longestStreak: number;
  tier: string;
  tierUpgraded: boolean;
  newTier?: string;
  energyBonus: number;
  newBalance?: number;
  alreadyCheckedIn: boolean;
}

/**
 * processCheckIn
 * 
 * หัวใจของ Streak System
 * 
 * @param deviceId User device ID
 * @param timezoneOffset Timezone offset (default: 420 = UTC+7)
 * @returns CheckInResult
 */
export async function processCheckIn(
  deviceId: string,
  timezoneOffset?: number
): Promise<CheckInResult> {
  const today = getTodayString(timezoneOffset);
  const userRef = db.collection('users').doc(deviceId);

  return db.runTransaction(async (transaction) => {
    const userDoc = await transaction.get(userRef);

    if (!userDoc.exists) {
      throw new Error('User not found');
    }

    const user = userDoc.data()!;
    const lastCheckInDate = user.lastCheckInDate || null;
    const currentStreak = user.currentStreak || 0;
    const tier = user.tier || 'none';
    const balance = user.balance || 0;
    let longestStreak = user.longestStreak || 0;

    // ─── Already checked in today ───
    if (lastCheckInDate === today) {
      console.log(`⏭️  [Check-in] Already checked in today: ${deviceId}`);
      
      return {
        success: true,
        currentStreak,
        longestStreak,
        tier,
        tierUpgraded: false,
        energyBonus: 0,
        newBalance: balance,
        alreadyCheckedIn: true,
      };
    }

    // ─── Calculate new streak ───
    let newStreak: number;

    if (lastCheckInDate === null) {
      // First ever check-in
      console.log(`🎉 [Check-in] First check-in for ${deviceId}`);
      newStreak = 1;
    } else {
      const daysSince = daysBetween(lastCheckInDate, today);
      const grace = getGraceDays(tier);

      console.log(
        `📅 [Check-in] ${deviceId}: last=${lastCheckInDate}, today=${today}, ` +
        `daysSince=${daysSince}, tier=${tier}, grace=${grace}`
      );

      if (daysSince <= 1 + grace) {
        // Within grace period → continue streak
        newStreak = currentStreak + 1;
        console.log(`✅ [Check-in] Streak continues: ${newStreak}`);
      } else {
        // Streak broken → reset to 1
        newStreak = 1;
        console.log(`💔 [Check-in] Streak broken, reset to 1`);
      }
    }

    // Update longest streak
    if (newStreak > longestStreak) {
      longestStreak = newStreak;
    }

    // ─── Check tier upgrade ───
    let newTier = tier;
    let tierUpgraded = false;
    let energyBonus = 0;

    // เช็คจาก tier สูงสุดก่อน (เพื่อ upgrade ข้าม tier ได้)
    const tierChecks = [
      { name: 'diamond', days: TIER_CONFIG.diamond.days, energy: TIER_CONFIG.diamond.energy },
      { name: 'gold', days: TIER_CONFIG.gold.days, energy: TIER_CONFIG.gold.energy },
      { name: 'silver', days: TIER_CONFIG.silver.days, energy: TIER_CONFIG.silver.energy },
      { name: 'bronze', days: TIER_CONFIG.bronze.days, energy: TIER_CONFIG.bronze.energy },
    ];

    for (const check of tierChecks) {
      if (newStreak >= check.days && getTierIndex(tier) < getTierIndex(check.name)) {
        newTier = check.name;
        tierUpgraded = true;
        energyBonus = check.energy;
        
        console.log(`🎊 [Check-in] Tier upgraded: ${tier} → ${newTier} (+${energyBonus} Energy)`);
        break; // Upgrade one tier at a time
      }
    }

    // ─── Update user document ───
    const updates: Record<string, any> = {
      currentStreak: newStreak,
      longestStreak,
      lastCheckInDate: today,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    };

    if (tierUpgraded) {
      updates.tier = newTier;
      updates[`tierUnlockedAt.${newTier}`] = admin.firestore.FieldValue.serverTimestamp();
      updates.balance = balance + energyBonus;

      // Set bonus rate for Gold/Diamond (Phase 2)
      if (newTier === 'gold') updates.bonusRate = 0.20;
      if (newTier === 'diamond') updates.bonusRate = 0.30;
    }

    transaction.update(userRef, updates);

    // ─── Log transaction (if tier bonus) ───
    if (tierUpgraded && energyBonus > 0) {
      const txRef = db.collection('transactions').doc();
      transaction.set(txRef, {
        deviceId,
        miroId: user.miroId || 'unknown',
        type: 'streak_bonus',
        amount: energyBonus,
        balanceAfter: balance + energyBonus,
        description: `Streak Tier unlocked: ${newTier}! +${energyBonus} Energy`,
        metadata: {
          tier: newTier,
          streak: newStreak,
        },
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    return {
      success: true,
      currentStreak: newStreak,
      longestStreak,
      tier: newTier,
      tierUpgraded,
      newTier: tierUpgraded ? newTier : undefined,
      energyBonus,
      newBalance: tierUpgraded ? balance + energyBonus : balance,
      alreadyCheckedIn: false,
    };
  });
}

/**
 * claimDailyCheckIn HTTP Endpoint
 * 
 * Optional: ให้ user check-in โดยไม่ต้องใช้ AI
 */
export const claimDailyCheckIn = onRequest(
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
      const { deviceId, timezoneOffset } = req.body;

      if (!deviceId) {
        res.status(400).json({ error: 'Missing deviceId' });
        return;
      }

      const result = await processCheckIn(deviceId, timezoneOffset);
      res.status(200).json(result);
    } catch (error: any) {
      console.error('❌ [claimDailyCheckIn] Error:', error);
      res.status(500).json({ error: error.message });
    }
  }
);
```

**📌 จุดสำคัญ:**
- ใช้ Transaction เพื่อป้องกัน race condition
- คำนวณ streak ด้วย `daysBetween`
- Grace period ตาม tier ปัจจุบัน
- Tier ปลดล็อคแล้วไม่หลุด (แม้ streak reset)

---

### Step 4.2: Integrate กับ analyzeFood (Free AI)

**ที่อยู่:** `functions/src/analyzeFood.ts`

**แก้ไข section Free AI:**

```typescript
// Import processCheckIn
import { processCheckIn } from './energy/dailyCheckIn';

// ... ใน analyzeFood handler ...

if (isFree) {
  console.log(`🆓 [analyzeFood] Free AI for ${deviceId}`);

  // ────── Process check-in (streak + tier) ──────
  const checkInResult = await processCheckIn(deviceId, timezoneOffset);
  
  console.log(
    `📊 [Check-in] Streak: ${checkInResult.currentStreak}, ` +
    `Tier: ${checkInResult.tier}` +
    (checkInResult.tierUpgraded ? ` (UPGRADED!)` : '')
  );

  // ... เรียก Gemini API (code เดิม) ...

  // Return response พร้อม streak info
  res.status(200).json({
    success: true,
    data: geminiResponse,
    balance: checkInResult.newBalance ?? balance,
    energyUsed: 0,
    energyCost: 0,
    wasFreeAi: true,

    // ← Streak info (ใหม่!)
    streak: {
      current: checkInResult.currentStreak,
      longest: checkInResult.longestStreak,
      tier: checkInResult.tier,
      tierUpgraded: checkInResult.tierUpgraded,
      newTier: checkInResult.newTier,
      energyBonus: checkInResult.energyBonus,
    },
  });
  return;
}
```

**📌 สำคัญ:** Free AI = Check-in อัตโนมัติ!

---

### Step 4.3: Export functions

**ที่อยู่:** `functions/src/index.ts`

**เพิ่ม:**

```typescript
export { claimDailyCheckIn } from './energy/dailyCheckIn';
export { processCheckIn } from './energy/dailyCheckIn';
```

---

### Step 4.4: Deploy

```bash
cd functions
firebase deploy --only functions:claimDailyCheckIn,functions:analyzeFood
```

---

## ✅ Checklist

```
□ ไฟล์ functions/src/energy/dailyCheckIn.ts สร้างแล้ว
□ processCheckIn function ใช้งานได้
□ claimDailyCheckIn HTTP endpoint ใช้งานได้
□ Integrate กับ analyzeFood (free AI → check-in)
□ Export ใน index.ts แล้ว
□ Deploy สำเร็จ
□ ไม่มี linter errors
```

---

## 🧪 Testing

### Test Case 1: Day 1-6 → streak เพิ่ม, ยัง none

```bash
# Day 1
curl -X POST .../claimDailyCheckIn -d '{"deviceId":"test"}'
# Expected: { currentStreak: 1, tier: "none" }

# Day 2
# Expected: { currentStreak: 2, tier: "none" }

# ... Day 6
# Expected: { currentStreak: 6, tier: "none" }
```

---

### Test Case 2: Day 7 → Bronze tier (+10 Energy)

```bash
# Day 7
curl -X POST .../claimDailyCheckIn -d '{"deviceId":"test"}'

# Expected:
{
  "currentStreak": 7,
  "tier": "bronze",
  "tierUpgraded": true,
  "newTier": "bronze",
  "energyBonus": 10,
  "newBalance": 110  // (100 + 10)
}
```

**Verify Firestore:**
```
users/test:
  currentStreak: 7
  tier: "bronze"
  tierUnlockedAt.bronze: Timestamp(...)
  balance: 110

transactions:
  - type: "streak_bonus"
  - amount: 10
  - description: "Streak Tier unlocked: bronze! +10 Energy"
```

---

### Test Case 3: Skip 1 day (Bronze) → Streak reset

```bash
# Day 7: streak = 7, tier = bronze
# Day 8: หยุด (ไม่เรียก API)
# Day 9: เรียก API อีกครั้ง

curl -X POST .../claimDailyCheckIn -d '{"deviceId":"test"}'

# Expected:
{
  "currentStreak": 1,  // ← reset!
  "tier": "bronze",    // ← ยังคง bronze (ไม่หลุด)
  "tierUpgraded": false
}
```

**📌 Bronze grace = 0 → หยุด 1 วัน = daysSince 2 > 1 → reset**

---

### Test Case 4: Skip 1 day (Silver) → Streak ต่อ (grace!)

```bash
# Day 14: streak = 14, tier = silver (grace = 1)
# Day 15: หยุด
# Day 16: เรียก API

curl -X POST .../claimDailyCheckIn -d '{"deviceId":"test"}'

# Expected:
{
  "currentStreak": 15,  // ← ต่อ! (daysSince 2 <= 1+grace)
  "tier": "silver",
  "tierUpgraded": false
}
```

---

### Test Case 5: Skip 2 days (Silver) → Streak reset

```bash
# Day 14: streak = 14, tier = silver (grace = 1)
# Day 15-16: หยุด
# Day 17: เรียก API

curl -X POST .../claimDailyCheckIn -d '{"deviceId":"test"}'

# Expected:
{
  "currentStreak": 1,   // ← reset! (daysSince 3 > 2)
  "tier": "silver",     // ← ยังคง silver (ไม่หลุด)
  "tierUpgraded": false
}
```

---

### Test Case 6: Check-in ซ้ำวันเดียวกัน → ไม่นับ

```bash
# เรียก API 2 ครั้งในวันเดียวกัน

curl -X POST .../claimDailyCheckIn -d '{"deviceId":"test"}'
# Expected: { currentStreak: 5 }

curl -X POST .../claimDailyCheckIn -d '{"deviceId":"test"}'
# Expected: { currentStreak: 5, alreadyCheckedIn: true }
```

---

## ⚠️ Common Issues

### Issue 1: "Streak นับผิด"
**อาการ:** Streak ไม่เพิ่มหรือ reset ผิด  
**แก้ไข:**
- เช็ค `daysBetween` calculation
- เช็ค `lastCheckInDate` format (YYYY-MM-DD)
- เช็ค timezone offset

### Issue 2: "Grace period ไม่ทำงาน"
**อาการ:** หยุด 1 วัน (Silver) แล้ว streak reset  
**แก้ไข:**
- เช็คว่า `getGraceDays(tier)` return ถูกต้อง
- เช็ค condition: `daysSince <= 1 + grace`

### Issue 3: "Tier upgrade ข้าม tier"
**อาการ:** Streak 14 → upgrade เป็น gold แทน silver  
**แก้ไข:**
- ใช้ `break` หลัง upgrade (upgrade ทีละ tier)
- เช็ค `getTierIndex(tier) < getTierIndex(check.name)`

### Issue 4: "Transaction ซ้ำ"
**อาการ:** บันทึก streak_bonus หลายครั้ง  
**แก้ไข:**
- ใช้ Firestore Transaction
- เช็คว่า `tierUpgraded === true` ก่อนบันทึก

---

## 📌 Important Notes

1. **Tier ไม่หลุด** — Streak reset แต่ tier ยังคงเดิม
2. **Grace period ตาม tier ปัจจุบัน** — ไม่ใช่ tier ใหม่
3. **Upgrade ทีละ tier** — ไม่ข้าม tier (เว้นแต่ streak สูงมาก)
4. **Check-in อัตโนมัติ** — Free AI = check-in (ไม่ต้องเรียกแยก)

---

## 📚 Related Files

- `functions/src/energy/dailyCheckIn.ts` — Streak logic (ไฟล์นี้)
- `functions/src/analyzeFood.ts` — Integration (แก้ไข)
- `functions/src/index.ts` — Export

---

## ⏭️ Next Task

เมื่อทำ Task 4 เสร็จ → ไป **TASK_5_FLUTTER.md**
