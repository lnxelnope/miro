# Task 1: Firestore Schema & Migration

**ระยะเวลา:** 2 วัน  
**Complexity:** 🔴 Hard  
**ต้องรู้:** TypeScript, Firestore, Cloud Functions

---

## 🎯 สิ่งที่ต้องทำ

สร้าง Firestore schema ใหม่และ migrate ข้อมูลจาก `energy_balances` → `users`

### เป้าหมาย
1. สร้าง Cloud Function สำหรับ migration
2. สร้าง config documents (`config/rewards`, `config/features`)
3. Migrate ข้อมูล user ทั้งหมด
4. Verify ว่า migration สำเร็จ

---

## 📚 ความรู้ที่ต้องมี

### Firestore Collections ปัจจุบัน (ก่อน Phase 1)
```
energy_balances/{deviceId}
  - balance: number
  - lastUpdated: Timestamp
  - createdAt: Timestamp
  - welcomeGiftClaimed: boolean
```

### Firestore Collections ใหม่ (หลัง Phase 1)
```
users/{deviceId}
  - deviceId: string
  - miroId: string              ← ใหม่!
  - balance: number
  - totalEarned: number         ← ใหม่!
  - totalSpent: number          ← ใหม่!
  - freeAiUsedToday: boolean    ← ใหม่!
  - currentStreak: number       ← ใหม่!
  - tier: string                ← ใหม่!
  ... (และอื่นๆ)
```

---

## 📝 ขั้นตอนการทำ (Step-by-Step)

### Step 1.1: สร้างไฟล์ migration.ts

**ที่อยู่:** `functions/src/migration.ts`

**Code ที่ต้องเขียน:**

```typescript
import { onRequest } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

// ใช้ CHARSET เดียวกับ transferKey.ts (ไม่ใช้ตัวที่สับสน: 0,O,1,I,L)
const CHARSET = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

/**
 * สร้าง MiRO ID format: MIRO-XXXX-XXXX-XXXX
 * 
 * Example: MIRO-A3F9-K7X2-P8M1
 */
function generateMiroId(): string {
  const segments: string[] = [];
  
  // สร้าง 3 segments ของ 4 ตัวอักษร
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
 * เช็คว่า MiRO ID ซ้ำกับที่มีอยู่หรือไม่
 */
async function isUniqueMiroId(miroId: string): Promise<boolean> {
  const snapshot = await db
    .collection('users')
    .where('miroId', '==', miroId)
    .limit(1)
    .get();
  
  return snapshot.empty; // true = ไม่ซ้ำ
}

/**
 * สร้าง MiRO ID ที่ unique (ลองสูงสุด 10 ครั้ง)
 */
async function generateUniqueMiroId(): Promise<string> {
  let miroId = generateMiroId();
  let attempts = 0;
  const maxAttempts = 10;

  while (!(await isUniqueMiroId(miroId)) && attempts < maxAttempts) {
    miroId = generateMiroId();
    attempts++;
  }

  if (attempts >= maxAttempts) {
    throw new Error('Failed to generate unique MiRO ID after max attempts');
  }

  return miroId;
}

/**
 * migrateToUsersCollection
 * 
 * One-time migration: energy_balances → users
 * ⚠️ ใน production ต้องเพิ่ม auth check!
 */
export const migrateToUsersCollection = onRequest(
  {
    timeoutSeconds: 540, // 9 นาที (max)
    memory: '1GiB',
  },
  async (req, res) => {
    // TODO: เพิ่ม admin authentication check
    // if (!isAdmin(req)) { return res.status(403).json({ error: 'Forbidden' }); }

    try {
      console.log('🔄 [Migration] Starting migration...');

      // 1. ดึงข้อมูลทั้งหมดจาก energy_balances
      const energyDocs = await db.collection('energy_balances').get();
      
      let migrated = 0;
      let skipped = 0;
      let errors = 0;

      // 2. วนลูปแต่ละ user
      for (const doc of energyDocs.docs) {
        const deviceId = doc.id;
        const data = doc.data();

        // เช็คว่า migrate แล้วหรือยัง
        const userDoc = await db.collection('users').doc(deviceId).get();
        if (userDoc.exists) {
          console.log(`⏭️  [Migration] Skipping ${deviceId} (already migrated)`);
          skipped++;
          continue;
        }

        try {
          // 3. สร้าง MiRO ID ใหม่
          const miroId = await generateUniqueMiroId();
          const now = admin.firestore.FieldValue.serverTimestamp();
          const today = new Date().toISOString().split('T')[0]; // "YYYY-MM-DD"

          // 4. สร้าง user document ใหม่
          await db.collection('users').doc(deviceId).set({
            // ─── Identity ───
            deviceId,
            miroId,
            createdAt: data.createdAt || now,
            lastUpdated: now,

            // ─── Energy (migrate จาก energy_balances) ───
            balance: data.balance || 0,
            totalEarned: 0,
            totalSpent: 0,
            totalPurchased: 0,
            welcomeGiftClaimed: data.welcomeGiftClaimed || false,

            // ─── Daily Free AI ───
            freeAiUsedToday: false,
            freeAiLastReset: today,

            // ─── Streak & Tier (fresh start) ───
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

          console.log(`✅ [Migration] Migrated ${deviceId} → ${miroId}`);
          migrated++;
        } catch (err: any) {
          console.error(`❌ [Migration] Error migrating ${deviceId}:`, err);
          errors++;
        }
      }

      // 5. Return summary
      console.log(
        `✅ [Migration] Complete: ${migrated} migrated, ${skipped} skipped, ${errors} errors`
      );

      res.status(200).json({
        success: true,
        total: energyDocs.size,
        migrated,
        skipped,
        errors,
      });
    } catch (error: any) {
      console.error('❌ [Migration] Fatal error:', error);
      res.status(500).json({ error: error.message });
    }
  }
);
```

**📌 จุดสำคัญ:**
- ใช้ `CHARSET` ที่ไม่มีตัวสับสน (0, O, 1, I, L)
- เช็คว่า MiRO ID ไม่ซ้ำก่อนสร้าง
- ถ้า user มีอยู่แล้วใน `users` → ข้าม (ไม่ migrate ซ้ำ)
- ไม่ลบ `energy_balances` (เก็บไว้เป็น backup)

---

### Step 1.2: Export function ใน index.ts

**ที่อยู่:** `functions/src/index.ts`

**เพิ่มบรรทัดนี้:**

```typescript
export { migrateToUsersCollection } from './migration';
```

---

### Step 1.3: Deploy Cloud Function

```bash
# ใน terminal:
cd functions

# Deploy migration function
firebase deploy --only functions:migrateToUsersCollection
```

**Output ที่คาดหวัง:**
```
✔ functions[migrateToUsersCollection(us-central1)] Successful create operation.
```

---

### Step 1.4: สร้าง Config Documents

**⚠️ ทำใน Firestore Console (Firebase Console > Firestore Database)**

#### Document 1: `config/rewards`

**Path:** `config/rewards`

**ข้อมูล (JSON):**
```json
{
  "streakTiers": {
    "bronze": {
      "days": 7,
      "energy": 10,
      "graceDays": 0
    },
    "silver": {
      "days": 14,
      "energy": 15,
      "graceDays": 1
    },
    "gold": {
      "days": 30,
      "energy": 30,
      "graceDays": 2,
      "bonusRate": 0.20
    },
    "diamond": {
      "days": 60,
      "energy": 45,
      "graceDays": 3,
      "bonusRate": 0.30
    }
  },
  "welcomeGift": 100
}
```

**วิธีสร้างใน Console:**
1. เปิด Firestore Console
2. คลิก "Start collection"
3. Collection ID: `config`
4. Document ID: `rewards`
5. Copy-paste JSON ข้างบน
6. คลิก "Save"

#### Document 2: `config/features`

**Path:** `config/features`

**ข้อมูล (JSON):**
```json
{
  "enableDailyFreeAi": true,
  "enableStreakTier": true,
  "enableWeeklyChallenges": false,
  "enableMilestones": false,
  "enableRandomBonus": false,
  "enableReferral": false,
  "enableComebackBonus": false,
  "enableSubscription": false,
  "enableNotifications": false,
  "freezeAllRewards": false,
  "maintenanceMode": false
}
```

**📌 หมายเหตุ:** Phase 1 เปิดแค่ `enableDailyFreeAi` และ `enableStreakTier` เท่านั้น

---

### Step 1.5: รัน Migration

**⚠️ ระวัง! ทดสอบกับ test data ก่อน**

```bash
# วิธีเรียก Cloud Function:

# Method 1: ใช้ curl
curl -X POST https://us-central1-miro-d6856.cloudfunctions.net/migrateToUsersCollection

# Method 2: ใช้ Firebase Functions shell
firebase functions:shell
> migrateToUsersCollection()
```

**Output ที่คาดหวัง:**
```json
{
  "success": true,
  "total": 150,
  "migrated": 150,
  "skipped": 0,
  "errors": 0
}
```

---

### Step 1.6: Verify Migration

**เช็คใน Firestore Console:**

1. เปิด `users` collection → ต้องมี documents เท่ากับ `energy_balances`
2. เปิด document แรก → ต้องมี field:
   - ✅ `miroId` (format: `MIRO-XXXX-XXXX-XXXX`)
   - ✅ `balance` (เท่ากับ energy_balances เดิม)
   - ✅ `currentStreak` = 0
   - ✅ `tier` = "none"
   - ✅ `freeAiUsedToday` = false

**Query ตรวจสอบ:**
```typescript
// ใน Firebase Console > Firestore > Query
// SELECT * FROM users WHERE miroId LIKE 'MIRO-%'

// Expected: ทุก user ต้องมี miroId
```

---

### Step 1.7: สร้าง Firestore Index

**⚠️ สำคัญ! ต้องสร้าง index สำหรับ query MiRO ID**

**Method 1: ใน Console**
1. Firestore Console > Indexes tab
2. คลิก "Create Index"
3. Collection: `users`
4. Field: `miroId`, Order: Ascending
5. คลิก "Create"

**Method 2: ใน firestore.indexes.json**

**ที่อยู่:** `firestore.indexes.json` (root ของ project)

```json
{
  "indexes": [
    {
      "collectionGroup": "users",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "miroId",
          "order": "ASCENDING"
        }
      ]
    }
  ]
}
```

**Deploy index:**
```bash
firebase deploy --only firestore:indexes
```

---

## ✅ Checklist

ก่อนไป Task 2 ต้องเช็คให้ครบ:

```
□ ไฟล์ functions/src/migration.ts สร้างแล้ว
□ Export ใน index.ts แล้ว
□ Deploy migrateToUsersCollection สำเร็จ
□ Document config/rewards สร้างแล้ว (ใน Firestore Console)
□ Document config/features สร้างแล้ว
□ รัน migration แล้ว (migrated > 0, errors = 0)
□ Verify: users collection มี documents
□ Verify: ทุก user มี miroId
□ Verify: miroId format ถูกต้อง (MIRO-XXXX-XXXX-XXXX)
□ Firestore Index สำหรับ miroId สร้างแล้ว
□ ไม่มี linter errors ใน migration.ts
```

---

## ⚠️ Common Issues

### Issue 1: "Index not found"
**อาการ:** Query miroId error  
**แก้ไข:** รอ Firestore Index build เสร็จ (~5-10 นาที)

### Issue 2: "MiRO ID ซ้ำ"
**อาการ:** generateUniqueMiroId throw error  
**แก้ไข:** 
- เช็คว่ามี documents ใน `users` ที่มี miroId ซ้ำ
- ลบ documents เดิมออกแล้วรัน migration ใหม่

### Issue 3: "Timeout"
**อาการ:** Migration timeout (540s ไม่พอ)  
**แก้ไข:**
- แบ่ง migration เป็น batch (500 users/batch)
- หรือเพิ่ม memory เป็น `2GiB`

### Issue 4: "Function not found"
**อาการ:** curl ไม่เจอ function  
**แก้ไข:**
- เช็คว่า export ใน index.ts แล้ว
- เช็คว่า deploy สำเร็จ (`firebase functions:list`)

---

## 🧪 Testing

**Test case 1: Migration ครั้งแรก**
```bash
# Expected: migrated = จำนวน users ใน energy_balances
# Expected: errors = 0
```

**Test case 2: Migration ซ้ำ (idempotent)**
```bash
# รัน migration อีกครั้ง
# Expected: migrated = 0, skipped = จำนวน users ทั้งหมด
```

**Test case 3: MiRO ID uniqueness**
```typescript
// Query ใน Firestore Console:
// SELECT miroId, COUNT(*) FROM users GROUP BY miroId HAVING COUNT(*) > 1

// Expected: ไม่มี results (ไม่มี miroId ซ้ำ)
```

---

## 📌 Important Notes

1. **ไม่ลบ energy_balances!** — เก็บไว้เป็น backup
2. **Migration เป็น one-time job** — รันครั้งเดียว ไม่ต้องรันซ้ำ
3. **Auth check ใน production** — ต้องเพิ่ม admin auth ก่อน deploy จริง
4. **Backup ก่อนรัน** — Export Firestore data ก่อน migration

---

## 📚 Related Files

- `functions/src/migration.ts` — Migration logic
- `functions/src/index.ts` — Export functions
- `firestore.indexes.json` — Firestore indexes
- `config/rewards` — Reward config (Firestore document)
- `config/features` — Feature flags (Firestore document)

---

## ⏭️ Next Task

เมื่อทำ Task 1 เสร็จ → ไป **TASK_2_MIRO_BACKEND.md**
