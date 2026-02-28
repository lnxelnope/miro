# Task 2: MiRO ID System (Backend)

**ระยะเวลา:** 2 วัน  
**Complexity:** 🟡 Medium  
**ต้องรู้:** TypeScript, Cloud Functions, Firestore

---

## 🎯 สิ่งที่ต้องทำ

สร้าง Cloud Function `registerUser` สำหรับสร้าง user document + MiRO ID

### เป้าหมาย
1. สร้าง `registerUser` Cloud Function
2. แก้ไข `syncBalance` ให้ return MiRO ID
3. Test การสร้าง user ใหม่และ user เดิม

---

## 📝 ขั้นตอนการทำ (Step-by-Step)

### Step 2.1: สร้างไฟล์ registerUser.ts

**ที่อยู่:** `functions/src/registerUser.ts`

**Code ที่ต้องเขียน:**

```typescript
/**
 * registerUser Cloud Function
 *
 * เรียกตอน: App เปิดครั้งแรก (ยังไม่มี user document)
 * สิ่งที่ทำ: สร้าง user document + MiRO ID + Welcome Gift
 *
 * Input:  { deviceId: string }
 * Output: { success, miroId, balance, isNew }
 */

import { onRequest } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

// ใช้ CHARSET เดียวกับ migration.ts
const CHARSET = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
const WELCOME_GIFT = 100;

/**
 * สร้าง MiRO ID: MIRO-XXXX-XXXX-XXXX
 */
function generateMiroId(): string {
  const segments: string[] = [];
  
  for (let i = 0; i < 3; i++) {
    let segment = '';
    for (let j = 0; j < 4; j++) {
      const randomIndex = Math.floor(Math.random() * CHARSET.length);
      segment += CHARSET[randomIndex];
    }
    segments.push(segment);
  }
  
  return `MIRO-${segments.join('-')}`;
}

/**
 * สร้าง MiRO ID ที่ unique
 */
async function generateUniqueMiroId(): Promise<string> {
  let miroId = generateMiroId();
  let attempts = 0;

  while (attempts < 10) {
    const existing = await db
      .collection('users')
      .where('miroId', '==', miroId)
      .limit(1)
      .get();

    if (existing.empty) return miroId;

    miroId = generateMiroId();
    attempts++;
  }

  throw new Error('Failed to generate unique MiRO ID');
}

/**
 * registerUser Cloud Function
 */
export const registerUser = onRequest(
  {
    timeoutSeconds: 15,
    memory: '256MiB',
    cors: '*', // Allow CORS from Flutter app
  },
  async (req, res) => {
    // เช็ค HTTP method
    if (req.method !== 'POST') {
      res.status(405).json({ error: 'Method not allowed' });
      return;
    }

    try {
      const { deviceId } = req.body;

      // Validate input
      if (!deviceId || typeof deviceId !== 'string') {
        res.status(400).json({ error: 'Missing or invalid deviceId' });
        return;
      }

      // ─── เช็คว่า user มีอยู่แล้วหรือไม่ ───
      const existingUser = await db.collection('users').doc(deviceId).get();

      if (existingUser.exists) {
        // User มีแล้ว → return ข้อมูลเดิม
        const data = existingUser.data()!;
        console.log(`✅ [registerUser] Existing user: ${data.miroId}`);

        res.status(200).json({
          success: true,
          isNew: false,
          miroId: data.miroId,
          balance: data.balance,
          tier: data.tier,
          currentStreak: data.currentStreak,
          freeAiUsedToday: data.freeAiUsedToday,
        });
        return;
      }

      // ─── สร้าง user ใหม่ ───
      const miroId = await generateUniqueMiroId();
      const now = admin.firestore.FieldValue.serverTimestamp();
      const today = new Date().toISOString().split('T')[0]; // "YYYY-MM-DD"

      // เช็คว่ามีใน energy_balances เก่าหรือไม่ (migration support)
      const oldDoc = await db.collection('energy_balances').doc(deviceId).get();
      const existingBalance = oldDoc.exists ? (oldDoc.data()?.balance ?? 0) : 0;
      const hasOldData = oldDoc.exists && existingBalance > 0;

      // ถ้ามี balance เดิม → ใช้ balance เดิม, ถ้าไม่ → ให้ Welcome Gift
      const balance = hasOldData ? existingBalance : WELCOME_GIFT;

      // สร้าง user document
      await db.collection('users').doc(deviceId).set({
        // ─── Identity ───
        deviceId,
        miroId,
        createdAt: now,
        lastUpdated: now,

        // ─── Energy ───
        balance,
        totalEarned: 0,
        totalSpent: 0,
        totalPurchased: 0,
        welcomeGiftClaimed: true,

        // ─── Daily Free AI ───
        freeAiUsedToday: false,
        freeAiLastReset: today,

        // ─── Streak & Tier ───
        currentStreak: 0,
        longestStreak: 0,
        lastCheckInDate: null,
        tier: 'none',
        tierUnlockedAt: {
          bronze: null,
          silver: null,
          gold: null,
          diamond: null,
        },

        // ─── Flags ───
        isBanned: false,
        banReason: null,
      });

      // บันทึก transaction
      await db.collection('transactions').add({
        deviceId,
        miroId,
        type: hasOldData ? 'migration' : 'welcome_gift',
        amount: balance,
        balanceAfter: balance,
        description: hasOldData
          ? `Migrated from energy_balances: ${existingBalance} Energy`
          : `Welcome to MIRO! ${WELCOME_GIFT} Energy gift`,
        metadata: {},
        createdAt: now,
      });

      console.log(`🎉 [registerUser] New user: ${miroId} (balance: ${balance})`);

      // Return response
      res.status(201).json({
        success: true,
        isNew: true,
        miroId,
        balance,
        tier: 'none',
        currentStreak: 0,
        freeAiUsedToday: false,
      });
    } catch (error: any) {
      console.error('❌ [registerUser] Error:', error);
      res.status(500).json({ error: error.message });
    }
  }
);
```

**📌 จุดสำคัญ:**
- User มีอยู่แล้ว → return ข้อมูลเดิม (ไม่สร้างใหม่)
- User ใหม่ → สร้าง MiRO ID + Welcome Gift
- Support migration: ถ้ามี energy_balances เดิม → ใช้ balance เดิม
- บันทึก transaction ทุกครั้ง

---

### Step 2.2: Export function ใน index.ts

**ที่อยู่:** `functions/src/index.ts`

**เพิ่มบรรทัดนี้:**

```typescript
export { registerUser } from './registerUser';
```

---

### Step 2.3: Deploy Cloud Function

```bash
cd functions
firebase deploy --only functions:registerUser
```

**Output ที่คาดหวัง:**
```
✔ functions[registerUser(us-central1)] Successful create operation.
Function URL: https://us-central1-miro-d6856.cloudfunctions.net/registerUser
```

**🔖 บันทึก URL นี้ไว้!** จะใช้ใน Flutter client

---

### Step 2.4: Test registerUser ด้วย curl

**Test Case 1: User ใหม่**

```bash
curl -X POST https://us-central1-miro-d6856.cloudfunctions.net/registerUser \
  -H "Content-Type: application/json" \
  -d '{"deviceId": "test-device-001"}'
```

**Expected Response:**
```json
{
  "success": true,
  "isNew": true,
  "miroId": "MIRO-A3F9-K7X2-P8M1",
  "balance": 100,
  "tier": "none",
  "currentStreak": 0,
  "freeAiUsedToday": false
}
```

**Test Case 2: User เดิม (เรียกซ้ำ)**

```bash
# เรียก API เดิมอีกครั้ง
curl -X POST https://us-central1-miro-d6856.cloudfunctions.net/registerUser \
  -H "Content-Type: application/json" \
  -d '{"deviceId": "test-device-001"}'
```

**Expected Response:**
```json
{
  "success": true,
  "isNew": false,
  "miroId": "MIRO-A3F9-K7X2-P8M1",  ← เหมือนเดิม!
  "balance": 100,
  "tier": "none",
  "currentStreak": 0,
  "freeAiUsedToday": false
}
```

**Test Case 3: Missing deviceId**

```bash
curl -X POST https://us-central1-miro-d6856.cloudfunctions.net/registerUser \
  -H "Content-Type: application/json" \
  -d '{}'
```

**Expected Response:**
```json
{
  "error": "Missing or invalid deviceId"
}
```

---

### Step 2.5: แก้ไข syncBalance.ts

**ที่อยู่:** `functions/src/syncBalance.ts`

**แก้ไข:** Return MiRO ID พร้อม balance

**ก่อน:**
```typescript
res.status(200).json({
  success: true,
  balance: serverBalance,
  action: 'synced',
});
```

**หลัง:**
```typescript
// อ่านจาก users collection (แทน energy_balances)
const userDoc = await db.collection('users').doc(deviceId).get();

if (userDoc.exists) {
  const userData = userDoc.data()!;
  
  res.status(200).json({
    success: true,
    balance: userData.balance,
    miroId: userData.miroId,
    tier: userData.tier,
    currentStreak: userData.currentStreak,
    freeAiUsedToday: userData.freeAiUsedToday,
    action: 'synced',
  });
} else {
  // User ไม่มี → ควรเรียก registerUser ก่อน
  res.status(404).json({
    error: 'User not found. Please call registerUser first.',
  });
}
```

**📌 สำคัญ:** ทุก Cloud Function ที่เคยอ่านจาก `energy_balances` ต้องแก้เป็น `users` ทั้งหมด!

---

### Step 2.6: Deploy syncBalance

```bash
firebase deploy --only functions:syncBalance
```

---

## ✅ Checklist

```
□ ไฟล์ functions/src/registerUser.ts สร้างแล้ว
□ Export ใน index.ts แล้ว
□ Deploy registerUser สำเร็จ
□ Test: user ใหม่ → ได้ MiRO ID + 100 Energy
□ Test: user เดิม → return ข้อมูลเดิม (isNew: false)
□ Test: missing deviceId → error 400
□ Test: MiRO ID format ถูกต้อง (MIRO-XXXX-XXXX-XXXX)
□ แก้ไข syncBalance.ts (อ่านจาก users, return MiRO ID)
□ Deploy syncBalance สำเร็จ
□ ไม่มี linter errors
```

---

## ⚠️ Common Issues

### Issue 1: "Failed to generate unique MiRO ID"
**อาการ:** ลอง 10 ครั้งแล้วยัง ID ซ้ำ  
**แก้ไข:** 
- เช็คว่า CHARSET ถูกต้อง (32 ตัวอักษร)
- เพิ่ม max attempts เป็น 20
- เช็คว่า Firestore Index สำหรับ miroId ทำงาน

### Issue 2: "CORS error"
**อาการ:** Flutter app เรียก API ไม่ได้  
**แก้ไข:**
- เช็คว่ามี `cors: '*'` ใน function config
- หรือติดตั้ง cors middleware:
```typescript
import cors from 'cors';
const corsHandler = cors({ origin: true });
```

### Issue 3: "Transaction already exists"
**อาการ:** บันทึก transaction ซ้ำ  
**แก้ไข:**
- ใช้ `.add()` แทน `.set()` (auto-generate ID)
- หรือเช็คว่ามี transaction แล้วก่อนสร้าง

---

## 🧪 Testing

**Manual Test Checklist:**

```bash
# 1. User ใหม่
✓ POST /registerUser → 201, isNew: true, miroId: "MIRO-..."

# 2. User เดิม (เรียกซ้ำ)
✓ POST /registerUser → 200, isNew: false, miroId เหมือนเดิม

# 3. Missing input
✓ POST /registerUser (no body) → 400

# 4. Verify Firestore
✓ users/{deviceId} document มีข้อมูลครบ
✓ transactions collection มี welcome_gift transaction

# 5. syncBalance
✓ GET /syncBalance → return miroId
```

---

## 📌 Important Notes

1. **MiRO ID เป็น identity ถาวร** — user ย้ายเครื่องยัง MiRO ID เดิม
2. **Welcome Gift ให้ครั้งเดียว** — ถ้าเรียก registerUser ซ้ำไม่ได้ gift ซ้ำ
3. **Migration support** — user เก่าที่มี energy_balances จะได้ balance เดิม
4. **CORS ต้องเปิด** — Flutter app จะเรียก API ได้

---

## 📚 Related Files

- `functions/src/registerUser.ts` — Register logic (ไฟล์นี้)
- `functions/src/syncBalance.ts` — Sync balance (แก้ไข)
- `functions/src/index.ts` — Export functions

---

## 🔗 API Endpoint

```
POST https://us-central1-miro-d6856.cloudfunctions.net/registerUser

Request Body:
{
  "deviceId": "string"
}

Response (201 Created):
{
  "success": true,
  "isNew": true,
  "miroId": "MIRO-XXXX-XXXX-XXXX",
  "balance": 100,
  "tier": "none",
  "currentStreak": 0,
  "freeAiUsedToday": false
}

Response (200 OK - existing user):
{
  "success": true,
  "isNew": false,
  "miroId": "MIRO-XXXX-XXXX-XXXX",
  "balance": 150,
  "tier": "bronze",
  "currentStreak": 7,
  "freeAiUsedToday": true
}
```

---

## ⏭️ Next Task

เมื่อทำ Task 2 เสร็จ → ไป **TASK_3_FREE_AI.md**
