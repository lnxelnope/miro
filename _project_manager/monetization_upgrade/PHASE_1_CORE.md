# Phase 1: Core System — คู่มือ Implementation

**Scope:** MiRO ID + First AI Free + Streak Tier + Daily Check-in  
**ระยะเวลา:** 2 สัปดาห์  
**อ่านก่อน:** `README.md` ในโฟลเดอร์เดียวกัน

---

## สารบัญ

- [Task 1: Firestore Schema & Migration](#task-1-firestore-schema--migration)
- [Task 2: MiRO ID System](#task-2-miro-id-system)
- [Task 3: First AI Free](#task-3-first-ai-free)
- [Task 4: Streak Tier System](#task-4-streak-tier-system)
- [Task 5: Flutter Client](#task-5-flutter-client)
- [Task 6: Backup System Update](#task-6-backup-system-update)
- [Task 7: Testing Checklist](#task-7-testing-checklist)

---

## Task 1: Firestore Schema & Migration

### 1.1 สิ่งที่ต้องทำ

Collection เดิม `energy_balances/{deviceId}` มี:
```typescript
{
  balance: number;
  lastUpdated: Timestamp;
  createdAt: Timestamp;
  welcomeGiftClaimed: boolean;
  // บาง doc มี: migratedFrom, lastTransferredAt, lastReceivedAt
}
```

ต้อง migrate ไปเป็น `users/{deviceId}` ที่มีข้อมูลเพิ่มเติม

### 1.2 Schema ใหม่: `users/{deviceId}`

```typescript
// Phase 1 fields only (Phase 2+ จะเพิ่มทีหลัง)
interface UserDocument {
  // ─── Identity ───
  deviceId: string;
  miroId: string;                   // "MIRO-XXXX-XXXX-XXXX"
  createdAt: Timestamp;
  lastUpdated: Timestamp;

  // ─── Energy Balance (migrate จาก energy_balances) ───
  balance: number;
  totalEarned: number;              // default 0
  totalSpent: number;               // default 0
  totalPurchased: number;           // default 0
  welcomeGiftClaimed: boolean;

  // ─── Daily Free AI ───
  freeAiUsedToday: boolean;         // default false
  freeAiLastReset: string;          // "YYYY-MM-DD"

  // ─── Streak & Tier ───
  currentStreak: number;            // default 0
  longestStreak: number;            // default 0
  lastCheckInDate: string | null;   // "YYYY-MM-DD" or null
  tier: 'none' | 'bronze' | 'silver' | 'gold' | 'diamond';
  tierUnlockedAt: {
    bronze: Timestamp | null;
    silver: Timestamp | null;
    gold: Timestamp | null;
    diamond: Timestamp | null;
  };

  // ─── Flags ───
  isBanned: boolean;                // default false
  banReason: string | null;
}
```

### 1.3 Migration Cloud Function

สร้างไฟล์ `functions/src/migration.ts`:

```typescript
/**
 * migrateToUsersCollection
 *
 * One-time migration: energy_balances → users
 * เรียกจาก Admin Panel หรือ manual trigger
 *
 * สิ่งที่ทำ:
 * 1. อ่านทุก doc ใน energy_balances
 * 2. สร้าง doc ใน users (พร้อม MiRO ID)
 * 3. ไม่ลบ energy_balances (เก็บไว้เป็น backup)
 */

import { onRequest } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

// ใช้ CHARSET เดียวกับ transferKey.ts
const CHARSET = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

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

// ตรวจสอบว่า MiRO ID ซ้ำหรือไม่
async function isUniqueMiroId(miroId: string): Promise<boolean> {
  const snapshot = await db
    .collection('users')
    .where('miroId', '==', miroId)
    .limit(1)
    .get();
  return snapshot.empty;
}

// สร้าง MiRO ID ที่ unique
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

export const migrateToUsersCollection = onRequest(
  {
    timeoutSeconds: 540, // 9 minutes (max)
    memory: '1GiB',
    // ⚠️ ต้องมี auth check ใน production!
  },
  async (req, res) => {
    // TODO: เพิ่ม admin auth check

    try {
      const energyDocs = await db.collection('energy_balances').get();
      let migrated = 0;
      let skipped = 0;
      let errors = 0;

      for (const doc of energyDocs.docs) {
        const deviceId = doc.id;
        const data = doc.data();

        // เช็คว่า migrate แล้วหรือยัง
        const userDoc = await db.collection('users').doc(deviceId).get();
        if (userDoc.exists) {
          skipped++;
          continue;
        }

        try {
          const miroId = await generateUniqueMiroId();
          const now = admin.firestore.FieldValue.serverTimestamp();
          const today = new Date().toISOString().split('T')[0];

          await db.collection('users').doc(deviceId).set({
            // Identity
            deviceId,
            miroId,
            createdAt: data.createdAt || now,
            lastUpdated: now,

            // Energy (migrate)
            balance: data.balance || 0,
            totalEarned: 0,
            totalSpent: 0,
            totalPurchased: 0,
            welcomeGiftClaimed: data.welcomeGiftClaimed || false,

            // Daily Free AI
            freeAiUsedToday: false,
            freeAiLastReset: today,

            // Streak & Tier (fresh start)
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

            // Flags
            isBanned: false,
            banReason: null,
          });

          migrated++;
        } catch (err: any) {
          console.error(`Error migrating ${deviceId}:`, err);
          errors++;
        }
      }

      res.status(200).json({
        success: true,
        total: energyDocs.size,
        migrated,
        skipped,
        errors,
      });
    } catch (error: any) {
      console.error('Migration error:', error);
      res.status(500).json({ error: error.message });
    }
  }
);
```

### 1.4 สร้าง Config Documents

หลัง migration ต้องสร้าง config documents ด้วย:

**Document: `config/rewards`**
```json
{
  "streakTiers": {
    "bronze":  { "days": 7,  "energy": 10, "graceDays": 0 },
    "silver":  { "days": 14, "energy": 15, "graceDays": 1 },
    "gold":    { "days": 30, "energy": 30, "graceDays": 2, "bonusRate": 0.20 },
    "diamond": { "days": 60, "energy": 45, "graceDays": 3, "bonusRate": 0.30 }
  },
  "welcomeGift": 100
}
```

**Document: `config/features`**
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

### 1.5 สิ่งที่ต้องทำ (Checklist)

```
□ สร้างไฟล์ functions/src/migration.ts
□ สร้าง config/rewards document ใน Firestore Console
□ สร้าง config/features document ใน Firestore Console
□ ทดสอบ migration ด้วย test data ก่อน
□ รัน migration กับ production data
□ Verify ว่า users collection มีข้อมูลครบ
□ สร้าง Firestore Index สำหรับ query ที่ต้องใช้:
  - users.miroId (unique)
```

---

## Task 2: MiRO ID System

### 2.1 สิ่งที่ต้องทำ

- Cloud Function: `registerUser` — สร้าง user document + MiRO ID
- แก้ไข `syncBalance` — return MiRO ID กลับไปด้วย
- Flutter Client: เรียก registerUser ตอน first launch

### 2.2 Cloud Function: registerUser

สร้างไฟล์ `functions/src/registerUser.ts`:

```typescript
/**
 * registerUser Cloud Function
 *
 * เรียกตอน: App เปิดครั้งแรก (ยังไม่มี user document)
 * สิ่งที่ทำ: สร้าง user document + MiRO ID + Welcome Gift
 *
 * Input:  { deviceId: string }
 * Output: { success, miroId, balance }
 */

import { onRequest } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

const CHARSET = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
const WELCOME_GIFT = 100;

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

export const registerUser = onRequest(
  {
    timeoutSeconds: 15,
    memory: '256MiB',
    cors: '*',
  },
  async (req, res) => {
    if (req.method !== 'POST') {
      res.status(405).json({ error: 'Method not allowed' });
      return;
    }

    try {
      const { deviceId } = req.body;

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
      const today = new Date().toISOString().split('T')[0];

      // เช็คว่ามีใน energy_balances เก่าหรือไม่ (migration support)
      const oldDoc = await db.collection('energy_balances').doc(deviceId).get();
      const existingBalance = oldDoc.exists ? (oldDoc.data()?.balance ?? 0) : 0;
      const hasOldData = oldDoc.exists && existingBalance > 0;

      const balance = hasOldData ? existingBalance : WELCOME_GIFT;

      await db.collection('users').doc(deviceId).set({
        // Identity
        deviceId,
        miroId,
        createdAt: now,
        lastUpdated: now,

        // Energy
        balance,
        totalEarned: 0,
        totalSpent: 0,
        totalPurchased: 0,
        welcomeGiftClaimed: true,

        // Daily Free AI
        freeAiUsedToday: false,
        freeAiLastReset: today,

        // Streak & Tier
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

        // Flags
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

### 2.3 แก้ไข syncBalance.ts

เพิ่ม MiRO ID ใน response:

```typescript
// ใน syncBalance handler ตรงที่ return สำหรับ existing user:

// เดิม:
res.status(200).json({
  success: true,
  balance: serverBalance,
  action: 'synced',
});

// ใหม่:
// ดึงจาก users collection แทน energy_balances
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
  // Redirect ไป registerUser (user ยังไม่มี → สร้างใหม่)
  // หรือ call registerUser logic ตรงนี้เลย
}
```

**สำคัญ:** หลัง Phase 1 deploy ทุก Cloud Function ต้องอ่านจาก `users/{deviceId}` แทน `energy_balances/{deviceId}` — ทำทีละ function

### 2.4 Flutter Client: Registration Flow

**แก้ไขไฟล์:** `lib/core/services/energy_service.dart`

เพิ่ม method:

```dart
/// เรียก registerUser Cloud Function
/// เรียกตอน app startup (ใน main.dart หรือ splash screen)
Future<Map<String, dynamic>> registerOrSync() async {
  final deviceId = await DeviceIdService.getDeviceId();

  // เช็คว่ามี MiRO ID cached อยู่หรือยัง
  final cachedMiroId = await _storage.read(key: 'miro_id');

  if (cachedMiroId != null) {
    // มี MiRO ID แล้ว → sync balance ปกติ
    final balance = await syncBalanceWithServer();
    return {
      'miroId': cachedMiroId,
      'balance': balance,
      'isNew': false,
    };
  }

  // ไม่มี MiRO ID → register
  const url = 'https://us-central1-miro-d6856.cloudfunctions.net/registerUser';

  final response = await http.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'deviceId': deviceId}),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final data = jsonDecode(response.body);
    final miroId = data['miroId'] as String;
    final balance = data['balance'] as int;

    // Cache MiRO ID
    await _storage.write(key: 'miro_id', value: miroId);

    // Update local balance
    await updateFromServerResponse(balance);

    return {
      'miroId': miroId,
      'balance': balance,
      'isNew': data['isNew'] ?? false,
    };
  }

  throw Exception('Registration failed: ${response.statusCode}');
}

/// ดึง MiRO ID ที่ cached ไว้
Future<String?> getMiroId() async {
  return await _storage.read(key: 'miro_id');
}
```

### 2.5 Checklist

```
□ สร้าง functions/src/registerUser.ts
□ Export ใน functions/src/index.ts
□ Deploy & test registerUser
□ แก้ไข syncBalance.ts (อ่านจาก users collection + return MiRO ID)
□ แก้ไข energy_service.dart (เพิ่ม registerOrSync, getMiroId)
□ แก้ไข main.dart → เรียก registerOrSync ตอน startup
□ ทดสอบ: user ใหม่ → ได้ MiRO ID + 100 Energy
□ ทดสอบ: user เดิม → ได้ MiRO ID + balance เดิม
□ ทดสอบ: เรียกซ้ำ → return ข้อมูลเดิม (ไม่สร้างซ้ำ)
```

---

## Task 3: First AI Free

### 3.1 สิ่งที่ต้องทำ

แก้ไข `analyzeFood.ts`:
- เช็คว่าวันนี้ใช้ free AI แล้วหรือยัง
- ถ้ายังไม่ใช้ → ไม่หัก energy (free!)
- ถ้าใช้แล้ว → หัก energy ปกติ
- Reset `freeAiUsedToday` ทุกวัน (lazy reset ตอนเรียก)

### 3.2 Logic: Free AI Check

```
เมื่อ user เรียก analyzeFood:

1. อ่าน user document จาก users/{deviceId}
2. ดึง freeAiUsedToday, freeAiLastReset
3. เช็คว่าเป็นวันใหม่หรือยัง:
   - ถ้า freeAiLastReset !== today → reset freeAiUsedToday = false
4. ถ้า freeAiUsedToday === false:
   → ไม่หัก energy!
   → set freeAiUsedToday = true
   → set freeAiLastReset = today
   → บันทึก transaction type = 'free_ai'
5. ถ้า freeAiUsedToday === true:
   → หัก energy ปกติ (เหมือนเดิม)
```

### 3.3 แก้ไข analyzeFood.ts

**เพิ่ม helper function:**

```typescript
/**
 * ดึงวันที่ปัจจุบันตาม timezone ของ user
 * ถ้าไม่ส่ง timezone มา → ใช้ Asia/Bangkok (UTC+7)
 */
function getTodayString(timezoneOffset?: number): string {
  const now = new Date();
  // ถ้ามี offset → ใช้ offset นั้น (ในนาที)
  // ถ้าไม่มี → ใช้ UTC+7 (420 นาที)
  const offset = timezoneOffset ?? 420; // UTC+7
  const localTime = new Date(now.getTime() + offset * 60 * 1000);
  return localTime.toISOString().split('T')[0]; // "YYYY-MM-DD"
}

/**
 * เช็คและจัดการ Free AI
 *
 * @returns { isFree: boolean, needsUpdate: boolean }
 *   isFree = true → ครั้งนี้ฟรี (ไม่หัก energy)
 *   needsUpdate = true → ต้อง update freeAiUsedToday
 */
async function checkFreeAi(
  deviceId: string,
  timezoneOffset?: number
): Promise<{ isFree: boolean }> {
  const today = getTodayString(timezoneOffset);
  const userRef = db.collection('users').doc(deviceId);
  const userDoc = await userRef.get();

  if (!userDoc.exists) {
    return { isFree: false };
  }

  const userData = userDoc.data()!;
  const lastReset = userData.freeAiLastReset || '';
  const alreadyUsed = userData.freeAiUsedToday || false;

  // วันใหม่ → reset
  if (lastReset !== today) {
    // วันใหม่ + ยังไม่ใช้ → ฟรี!
    await userRef.update({
      freeAiUsedToday: true,
      freeAiLastReset: today,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    });
    return { isFree: true };
  }

  // วันเดิม + ยังไม่ใช้ → ฟรี!
  if (!alreadyUsed) {
    await userRef.update({
      freeAiUsedToday: true,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    });
    return { isFree: true };
  }

  // วันเดิม + ใช้แล้ว → ไม่ฟรี
  return { isFree: false };
}
```

**แก้ไขส่วน main handler ของ analyzeFood:**

ตรงที่เช็ค balance (ก่อนเรียก Gemini API) เพิ่ม free AI check:

```typescript
// ──── ก่อนเช็ค balance ──── //

// เช็ค Free AI ก่อน
const timezoneOffset = req.body.timezoneOffset; // Client ส่งมาด้วย
const { isFree } = await checkFreeAi(deviceId, timezoneOffset);

if (isFree) {
  console.log(`🆓 [analyzeFood] Free AI for ${deviceId} today!`);

  // เรียก Gemini ได้เลย ไม่ต้องเช็ค balance
  // ... (call Gemini API)

  // บันทึก transaction
  await db.collection('transactions').add({
    deviceId,
    miroId: userData.miroId || 'unknown',
    type: 'free_ai',
    amount: 0,
    balanceAfter: serverBalance,
    description: 'Daily free AI analysis',
    metadata: { requestType: type },
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  // ── อัพเดท challenge progress (Phase 2: useAi counter) ──
  // await incrementChallengeProgress(deviceId, 'useAi');

  // Return response (balance ไม่เปลี่ยน)
  res.status(200).json({
    success: true,
    data: geminiResponse, // or parsedResult for chat
    balance: serverBalance,
    energyUsed: 0,
    energyCost: 0,
    wasFreeAi: true,  // ← บอก client ว่าครั้งนี้ฟรี
  });
  return;
}

// ── ไม่ฟรี → เช็ค balance ปกติ (code เดิม) ──
```

### 3.4 Flutter Client: Free AI Indicator

**เพิ่ม field ใน response handling:**

```dart
// ใน gemini_service.dart หรือที่ parse response จาก analyzeFood:

final wasFreeAi = responseData['wasFreeAi'] == true;

if (wasFreeAi) {
  // แสดง UI "Free AI! 🆓" แทน energy deduction animation
  debugPrint('[AI] ✅ Free AI used today!');
} else {
  // Update balance ตามปกติ
  final newBalance = responseData['balance'] as int;
  await energyService.updateFromServerResponse(newBalance);
}
```

### 3.5 สิ่งสำคัญ

```
⚠️ Free AI ต้องเช็คที่ SERVER เท่านั้น (ไม่ใช่ client)
⚠️ Client ห้ามตัดสินว่า "ฟรีหรือไม่" — Server เป็น source of truth
⚠️ ถ้า Server ลง → ไม่ได้ free AI (fallback: หัก energy ปกติ)
⚠️ Free AI นับเป็น "check-in" ด้วย (สำหรับ streak)
```

### 3.6 Checklist

```
□ เพิ่ม checkFreeAi helper ใน analyzeFood.ts
□ แก้ไข analyzeFood handler (เพิ่ม free AI check ก่อนเช็ค balance)
□ Client ส่ง timezoneOffset ใน request body
□ Client handle wasFreeAi flag ใน response
□ บันทึก transaction type='free_ai'
□ ทดสอบ: ครั้งแรกของวัน → ฟรี + balance ไม่ลด
□ ทดสอบ: ครั้งที่ 2 ของวัน → หัก energy ปกติ
□ ทดสอบ: ข้ามวัน → reset (ฟรีอีกครั้ง)
□ ทดสอบ: user balance = 0 + free AI → ยังใช้ได้
```

---

## Task 4: Streak Tier System

### 4.1 สิ่งที่ต้องทำ

- Cloud Function: `claimDailyCheckIn` — บันทึก check-in + คำนวณ streak + ปลดล็อค tier
- Logic: Grace Period ตาม tier
- Logic: Tier ปลดล็อคแล้วไม่หลุด

### 4.2 Streak Logic (ละเอียด)

```
เมื่อ user ใช้ Free AI (ครั้งแรกของวัน):
→ เท่ากับ "Check-in" วันนี้

Server ทำ:
1. ดึง lastCheckInDate, currentStreak, tier
2. คำนวณ daysSinceLastCheckIn = today - lastCheckInDate
3. ดึง Grace Period จาก current tier:
   - none:    grace = 0
   - bronze:  grace = 0
   - silver:  grace = 1
   - gold:    grace = 2
   - diamond: grace = 3

4. ถ้า daysSinceLastCheckIn === 1:
   → ต่อ streak: currentStreak + 1

5. ถ้า daysSinceLastCheckIn === 0:
   → วันเดียวกัน: ไม่ทำอะไร (check-in แล้ว)

6. ถ้า daysSinceLastCheckIn <= (1 + grace):
   → ยังอยู่ใน grace period: ต่อ streak + 1
   (เช่น Silver user หยุด 1 วัน = daysSince = 2, grace = 1 → 2 <= 2 → OK!)

7. ถ้า daysSinceLastCheckIn > (1 + grace):
   → เกิน grace: streak reset เป็น 1 (วันนี้เป็นวันแรก)
   → แต่ Tier ยังคงเดิม!

8. เช็ค Tier upgrade:
   ถ้า currentStreak >= 7  && tier < bronze  → upgrade to bronze  (+10 Energy)
   ถ้า currentStreak >= 14 && tier < silver  → upgrade to silver  (+15 Energy)
   ถ้า currentStreak >= 30 && tier < gold    → upgrade to gold    (+30 Energy)
   ถ้า currentStreak >= 60 && tier < diamond → upgrade to diamond (+45 Energy)

9. Update user document
10. บันทึก transaction (ถ้าได้ tier bonus)
```

### 4.3 Cloud Function: claimDailyCheckIn

สร้างไฟล์ `functions/src/energy/dailyCheckIn.ts`:

```typescript
/**
 * claimDailyCheckIn
 *
 * ไม่ต้องเรียกแยก — ถูกเรียกอัตโนมัติเมื่อใช้ Free AI
 * (integrate กับ analyzeFood)
 *
 * แต่ก็เปิดให้เรียกตรงได้ (กรณี user เปิดแอปแต่ไม่ใช้ AI)
 *
 * Input:  { deviceId, timezoneOffset? }
 * Output: { success, currentStreak, tier, tierUpgrade?, energyBonus? }
 */

import * as admin from 'firebase-admin';

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

// ─── Tier Configuration ───
// อ่านจาก config/rewards ใน production
// Hardcode ไว้เป็น fallback
const TIER_CONFIG = {
  bronze:  { days: 7,  energy: 10, graceDays: 0 },
  silver:  { days: 14, energy: 15, graceDays: 1 },
  gold:    { days: 30, energy: 30, graceDays: 2 },
  diamond: { days: 60, energy: 45, graceDays: 3 },
};

const TIER_ORDER = ['none', 'bronze', 'silver', 'gold', 'diamond'];

function getTierIndex(tier: string): number {
  return TIER_ORDER.indexOf(tier);
}

function getGraceDays(tier: string): number {
  switch (tier) {
    case 'silver': return 1;
    case 'gold': return 2;
    case 'diamond': return 3;
    default: return 0; // none, bronze
  }
}

/**
 * คำนวณจำนวนวันระหว่าง 2 วัน (format: "YYYY-MM-DD")
 */
function daysBetween(dateStr1: string, dateStr2: string): number {
  const d1 = new Date(dateStr1);
  const d2 = new Date(dateStr2);
  const diffMs = Math.abs(d2.getTime() - d1.getTime());
  return Math.floor(diffMs / (1000 * 60 * 60 * 24));
}

function getTodayString(timezoneOffset?: number): string {
  const now = new Date();
  const offset = timezoneOffset ?? 420; // UTC+7
  const localTime = new Date(now.getTime() + offset * 60 * 1000);
  return localTime.toISOString().split('T')[0];
}

// ─── Main Logic ───

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
      newStreak = 1;
    } else {
      const daysSince = daysBetween(lastCheckInDate, today);
      const grace = getGraceDays(tier);

      if (daysSince <= 1 + grace) {
        // Within grace period → continue streak
        newStreak = currentStreak + 1;
      } else {
        // Streak broken → reset to 1
        newStreak = 1;
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
        break; // Only upgrade one tier at a time
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

      // Set bonus rate for Gold/Diamond
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
```

### 4.4 Integration กับ analyzeFood

**สำคัญ:** Check-in เกิดขึ้นอัตโนมัติเมื่อ free AI ถูกใช้

ใน `analyzeFood.ts` ตรง free AI section:

```typescript
if (isFree) {
  // ── Process check-in (streak + tier) ──
  const checkInResult = await processCheckIn(deviceId, timezoneOffset);

  // ... call Gemini API ...

  res.status(200).json({
    success: true,
    data: geminiResponse,
    balance: checkInResult.newBalance ?? serverBalance,
    energyUsed: 0,
    energyCost: 0,
    wasFreeAi: true,

    // Streak info
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

### 4.5 Standalone Check-in Endpoint (Optional)

ถ้าต้องการให้ user check-in โดยไม่ต้องใช้ AI:

```typescript
// functions/src/energy/dailyCheckIn.ts (เพิ่ม HTTP endpoint)

import { onRequest } from 'firebase-functions/v2/https';

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

### 4.6 Checklist

```
□ สร้าง functions/src/energy/dailyCheckIn.ts
□ Export processCheckIn function
□ Export claimDailyCheckIn HTTP endpoint
□ Integrate processCheckIn กับ analyzeFood (free AI section)
□ Export ใน index.ts
□ Deploy & test

□ ทดสอบ: Day 1 → streak = 1, tier = none
□ ทดสอบ: Day 7 ติดต่อกัน → streak = 7, tier = bronze (+10 Energy)
□ ทดสอบ: Day 14 ติดต่อกัน → tier = silver (+15 Energy)
□ ทดสอบ: หยุด 1 วัน (Silver) → streak ต่อ (grace = 1)
□ ทดสอบ: หยุด 2 วัน (Silver) → streak reset (grace = 1 ไม่พอ)
□ ทดสอบ: streak reset → tier ยังคงเดิม (ไม่หลุด!)
□ ทดสอบ: check-in ซ้ำวันเดียวกัน → ไม่นับซ้ำ
```

---

## Task 5: Flutter Client

### 5.1 สิ่งที่ต้องทำ

1. Energy Badge — แสดง Free AI indicator
2. Streak Display — แสดง streak + tier
3. Daily Check-in — ทำงานอัตโนมัติ (ผ่าน free AI)
4. Profile — แสดง MiRO ID + tier badge
5. Provider updates

### 5.2 Model: Gamification State

สร้างไฟล์ `lib/core/models/gamification_state.dart`:

```dart
/// สถานะ Gamification ของ user
class GamificationState {
  final String miroId;
  final int currentStreak;
  final int longestStreak;
  final String tier; // 'none', 'bronze', 'silver', 'gold', 'diamond'
  final bool freeAiAvailable; // วันนี้ยังมี free AI หรือไม่
  final int balance;

  const GamificationState({
    required this.miroId,
    required this.currentStreak,
    required this.longestStreak,
    required this.tier,
    required this.freeAiAvailable,
    required this.balance,
  });

  factory GamificationState.empty() {
    return const GamificationState(
      miroId: '',
      currentStreak: 0,
      longestStreak: 0,
      tier: 'none',
      freeAiAvailable: true,
      balance: 0,
    );
  }

  factory GamificationState.fromJson(Map<String, dynamic> json) {
    return GamificationState(
      miroId: json['miroId'] ?? '',
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      tier: json['tier'] ?? 'none',
      freeAiAvailable: !(json['freeAiUsedToday'] ?? false),
      balance: json['balance'] ?? 0,
    );
  }

  /// Tier display info
  String get tierEmoji {
    switch (tier) {
      case 'bronze': return '🥉';
      case 'silver': return '🥈';
      case 'gold': return '🥇';
      case 'diamond': return '💎';
      default: return '⭐';
    }
  }

  String get tierName {
    switch (tier) {
      case 'bronze': return 'Bronze';
      case 'silver': return 'Silver';
      case 'gold': return 'Gold';
      case 'diamond': return 'Diamond';
      default: return 'Starter';
    }
  }

  /// Days until next tier
  int get daysToNextTier {
    switch (tier) {
      case 'none': return 7 - currentStreak;
      case 'bronze': return 14 - currentStreak;
      case 'silver': return 30 - currentStreak;
      case 'gold': return 60 - currentStreak;
      default: return 0; // Diamond = max tier
    }
  }

  /// Grace period ปัจจุบัน
  int get graceDays {
    switch (tier) {
      case 'silver': return 1;
      case 'gold': return 2;
      case 'diamond': return 3;
      default: return 0;
    }
  }
}
```

### 5.3 Provider: Gamification

สร้างไฟล์ `lib/features/energy/providers/gamification_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_hybrid/core/models/gamification_state.dart';
import 'package:miro_hybrid/core/services/energy_service.dart';
import 'package:miro_hybrid/core/database/database_service.dart';

final gamificationProvider =
    StateNotifierProvider<GamificationNotifier, GamificationState>((ref) {
  return GamificationNotifier(EnergyService(DatabaseService.isar));
});

class GamificationNotifier extends StateNotifier<GamificationState> {
  final EnergyService _energyService;

  GamificationNotifier(this._energyService)
      : super(GamificationState.empty()) {
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final result = await _energyService.registerOrSync();
      state = GamificationState(
        miroId: result['miroId'] ?? '',
        currentStreak: result['currentStreak'] ?? 0,
        longestStreak: result['longestStreak'] ?? 0,
        tier: result['tier'] ?? 'none',
        freeAiAvailable: !(result['freeAiUsedToday'] ?? false),
        balance: result['balance'] ?? 0,
      );
    } catch (e) {
      // Fallback to local data
      final balance = await _energyService.getBalance();
      final miroId = await _energyService.getMiroId();
      state = GamificationState(
        miroId: miroId ?? '',
        currentStreak: 0,
        longestStreak: 0,
        tier: 'none',
        freeAiAvailable: true,
        balance: balance,
      );
    }
  }

  /// Update state จาก AI response
  void updateFromAiResponse(Map<String, dynamic> response) {
    final streak = response['streak'] as Map<String, dynamic>?;

    state = GamificationState(
      miroId: state.miroId,
      currentStreak: streak?['current'] ?? state.currentStreak,
      longestStreak: streak?['longest'] ?? state.longestStreak,
      tier: streak?['tier'] ?? state.tier,
      freeAiAvailable: false, // เพิ่งใช้ free AI → หมดแล้ว
      balance: response['balance'] ?? state.balance,
    );
  }

  /// Refresh from server
  Future<void> refresh() async {
    await _loadState();
  }
}
```

### 5.4 UI Components ที่ต้องสร้าง

**ไม่ต้องสร้างไฟล์ใหม่ — แก้ไขที่มีอยู่:**

#### 5.4.1 Energy Badge (แก้ไข)

แก้ไข `lib/features/energy/widgets/energy_badge.dart`:
- เพิ่ม "FREE" indicator เมื่อยังมี free AI
- แสดง streak count + tier emoji

```dart
// เพิ่มใน Energy Badge widget:
// ถ้า freeAiAvailable → แสดง "1 FREE" badge สีเขียว
// ถ้าไม่ → แสดง energy balance ปกติ
```

#### 5.4.2 Profile Screen (แก้ไข)

แก้ไข `lib/features/profile/presentation/profile_screen.dart`:
- แสดง MiRO ID (เช่น "MIRO-A3F9-K7X2-P8M1")
- แสดง Tier Badge + Streak
- ปุ่ม copy MiRO ID

#### 5.4.3 Streak Widget (สร้างใหม่)

สร้าง `lib/features/energy/widgets/streak_display.dart`:
- แสดง streak counter (🔥 14 days)
- แสดง current tier + badge
- แสดง progress to next tier
- แสดง grace period info

### 5.5 Checklist

```
□ สร้าง lib/core/models/gamification_state.dart
□ สร้าง lib/features/energy/providers/gamification_provider.dart
□ แก้ไข energy_badge.dart (Free AI indicator)
□ แก้ไข profile_screen.dart (MiRO ID + Tier)
□ สร้าง streak_display.dart widget
□ แก้ไข home_screen.dart (แสดง streak)
□ แก้ไข gemini_service.dart (handle wasFreeAi + streak response)
□ แก้ไข main.dart (เรียก registerOrSync + gamification provider)
□ ส่ง timezoneOffset ใน analyzeFood request
```

---

## Task 6: Backup System Update

### 6.1 สิ่งที่ต้องทำ

แก้ไข `BackupService` เพื่อ include MiRO ID ใน backup file

### 6.2 แก้ไข Backup Flow

**ไฟล์:** `lib/core/services/backup_service.dart`

**Backup — เพิ่ม MiRO ID + Streak data:**

```dart
// ใน createBackup() method:
// เดิม:
final backupData = {
  'transferKey': transferKey,
  'energyBalance': balance,
  'foodEntries': [...],
  'myMeals': [...],
  // ...
};

// ใหม่:
final miroId = await energyService.getMiroId();

final backupData = {
  'version': 2,  // ← เพิ่ม version (เดิมไม่มี)
  'miroId': miroId,  // ← ใหม่
  'transferKey': transferKey,
  'energyBalance': balance,
  'streakData': {  // ← ใหม่
    'currentStreak': gamificationState.currentStreak,
    'longestStreak': gamificationState.longestStreak,
    'tier': gamificationState.tier,
  },
  'foodEntries': [...],
  'myMeals': [...],
  // ...
};
```

**Restore — transfer MiRO ID:**

```dart
// ใน restoreFromBackup() method:
// หลังจาก redeemTransferKey สำเร็จ:

final miroId = backupData['miroId'] as String?;

if (miroId != null) {
  // Cache MiRO ID ใหม่
  await _storage.write(key: 'miro_id', value: miroId);

  // Server-side: ต้องอัพเดท users collection
  // ผูก MiRO ID กับ deviceId ใหม่
  // (ทำใน redeemTransferKey Cloud Function)
}
```

### 6.3 แก้ไข transferKey.ts

ใน `redeemTransferKey`:

```typescript
// หลังจาก transfer energy สำเร็จ:

// ─── Transfer MiRO ID ───
// ดึง MiRO ID จาก source device
const sourceUser = await db.collection('users').doc(sourceDeviceId).get();
const sourceMiroId = sourceUser.data()?.miroId;

if (sourceMiroId) {
  // ผูก MiRO ID กับ device ใหม่
  await db.collection('users').doc(newDeviceId).set({
    miroId: sourceMiroId,
    deviceId: newDeviceId,
    // ... copy streak data ...
    currentStreak: sourceUser.data()?.currentStreak || 0,
    longestStreak: sourceUser.data()?.longestStreak || 0,
    tier: sourceUser.data()?.tier || 'none',
    tierUnlockedAt: sourceUser.data()?.tierUnlockedAt || {},
  }, { merge: true });

  // Unlink MiRO ID จาก device เก่า
  // (ไม่ลบ doc แต่ mark ว่า transferred)
  await db.collection('users').doc(sourceDeviceId).update({
    miroId: `TRANSFERRED:${sourceMiroId}`,
    transferredTo: newDeviceId,
    transferredAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}
```

### 6.4 แจ้งเตือน User

**สำคัญ:** ต้องมีคำเตือนชัดเจนในแอป:

```
⚠️ MIRO ใช้ระบบ Anonymous
━━━━━━━━━━━━━━━━━━━━━━━━━━

MiRO ID ของคุณ: MIRO-A3F9-K7X2-P8M1

⚠️ ถ้าเปลี่ยนเครื่องหรือลบแอป โดยไม่ Backup:
  → ข้อมูลทั้งหมดจะหายถาวร
  → Energy, Streak, ประวัติอาหาร จะหายทั้งหมด
  → ไม่สามารถกู้คืนได้

✅ กรุณา Backup เป็นประจำ!
  → Settings > Backup Data > Save to Google Drive
```

### 6.5 Checklist

```
□ แก้ไข backup_service.dart (เพิ่ม miroId + streakData ใน backup)
□ แก้ไข backup_service.dart (restore: cache MiRO ID ใหม่)
□ แก้ไข transferKey.ts (transfer MiRO ID + streak data)
□ เพิ่มคำเตือน Anonymous ใน Profile/Settings
□ เพิ่ม version field ใน backup format (backward compatible)
□ ทดสอบ: Backup → ไฟล์มี miroId
□ ทดสอบ: Restore → MiRO ID ย้ายมาเครื่องใหม่
□ ทดสอบ: Restore → เครื่องเดิมหมดสิทธิ์
□ ทดสอบ: Restore backup เวอร์ชันเก่า (ไม่มี miroId) → ยังทำงานได้
```

---

## Task 7: Testing Checklist

### 7.1 Unit Tests (Cloud Functions)

```
registerUser:
□ New device → สร้าง MiRO ID + 100 Energy
□ Existing device → return ข้อมูลเดิม (ไม่สร้างซ้ำ)
□ Device ที่มีใน energy_balances → migrate balance
□ MiRO ID uniqueness (ไม่ซ้ำกัน)
□ Missing deviceId → 400 error

analyzeFood (Free AI):
□ ครั้งแรกของวัน → ฟรี (balance ไม่ลด)
□ ครั้งที่ 2+ → หัก energy ปกติ
□ ข้ามวัน → reset (ฟรีอีกครั้ง)
□ Balance = 0 + free AI → ยังใช้ได้
□ Balance = 0 + ไม่มี free AI → 402 error

processCheckIn (Streak):
□ First check-in → streak = 1
□ Consecutive days → streak + 1
□ Skip 1 day (None/Bronze tier) → streak reset
□ Skip 1 day (Silver tier) → streak continues (grace)
□ Skip 2 days (Silver tier) → streak reset
□ Skip 2 days (Gold tier) → streak continues (grace)
□ Skip 3 days (Gold tier) → streak reset
□ Reach Day 7 → tier = bronze (+10 Energy)
□ Reach Day 14 → tier = silver (+15 Energy)
□ Reach Day 30 → tier = gold (+30 Energy)
□ Reach Day 60 → tier = diamond (+45 Energy)
□ Streak reset → tier stays the same (ไม่หลุด!)
□ Same day double check-in → ไม่นับซ้ำ
```

### 7.2 Integration Tests

```
Full Flow:
□ Install app → registerUser → MiRO ID → 100 Energy
□ Use AI (Day 1) → free AI → streak = 1
□ Use AI again (Day 1) → หัก energy
□ Use AI (Day 2) → free AI → streak = 2
□ ... Day 7 → bronze (+10 Energy) → total = 109
□ Skip 1 day (Day 9 no check-in)
□ Day 10 → streak reset to 1 (bronze ยังอยู่)
□ Backup → ไฟล์มี MiRO ID + streak data
□ Restore on new device → MiRO ID + energy + streak transferred
```

### 7.3 Security Tests

```
□ Client ส่ง freeAiUsedToday = false โกง → Server ไม่เชื่อ (server check)
□ Client เปลี่ยน timezone โกง → ได้ free AI แค่ 1 ครั้ง (server check)
□ Client เรียก registerUser ซ้ำ → ได้ข้อมูลเดิม (ไม่ได้ Welcome Gift ซ้ำ)
□ Client เรียก claimDailyCheckIn ซ้ำ → streak ไม่เพิ่ม
□ Race condition: 2 request พร้อมกัน → ไม่ได้ free AI 2 ครั้ง (transaction)
```

### 7.4 Migration Tests

```
□ User เดิม (มี energy_balances) → registerUser → balance migrated
□ User ใหม่ (ไม่มี energy_balances) → registerUser → 100 Energy
□ User ที่ migrate แล้ว → registerUser → ไม่ migrate ซ้ำ
□ Backup เวอร์ชันเก่า restore → ยังทำงานได้ (backward compatible)
```

---

## 📂 Files Summary (Phase 1)

### สร้างใหม่:

```
functions/src/
  registerUser.ts           ← MiRO ID + Registration
  energy/
    dailyCheckIn.ts         ← Streak + Check-in logic
  migration.ts              ← One-time migration script

lib/core/
  models/
    gamification_state.dart ← Gamification state model

lib/features/energy/
  providers/
    gamification_provider.dart ← Riverpod provider
  widgets/
    streak_display.dart     ← Streak + Tier UI widget
```

### แก้ไข:

```
functions/src/
  analyzeFood.ts            ← เพิ่ม Free AI logic + check-in integration
  syncBalance.ts            ← อ่านจาก users collection + return MiRO ID
  transferKey.ts            ← Transfer MiRO ID + streak data
  index.ts                  ← Export new functions

lib/core/services/
  energy_service.dart       ← เพิ่ม registerOrSync, getMiroId
  backup_service.dart       ← เพิ่ม MiRO ID + streak ใน backup

lib/features/energy/
  widgets/
    energy_badge.dart       ← Free AI indicator
  providers/
    energy_provider.dart    ← เพิ่ม gamification integration

lib/features/profile/
  presentation/
    profile_screen.dart     ← แสดง MiRO ID + Tier badge

lib/features/home/
  presentation/
    home_screen.dart        ← แสดง streak

lib/main.dart               ← เรียก registerOrSync ตอน startup
```

### Firestore:

```
สร้าง Document:
  config/rewards            ← Tier config, reward values
  config/features           ← Feature flags

สร้าง Collection:
  users/{deviceId}          ← User data (migrate จาก energy_balances)
  transactions/{txId}       ← Transaction history

สร้าง Index:
  users.miroId              ← Unique index
```

---

## ⏰ Timeline

```
Day 1-2:   Task 1 (Schema + Migration)
Day 3-4:   Task 2 (MiRO ID System)
Day 5-6:   Task 3 (First AI Free)
Day 7-8:   Task 4 (Streak Tier)
Day 9-10:  Task 5 (Flutter Client)
Day 11:    Task 6 (Backup Update)
Day 12-14: Task 7 (Testing)
```
