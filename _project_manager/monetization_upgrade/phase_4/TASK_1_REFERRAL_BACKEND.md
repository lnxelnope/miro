# Phase 4 - Task 1: Referral System (Backend)

**Status:** 📝 Ready for Implementation  
**Estimated Time:** 6-8 hours  
**Difficulty:** ⭐⭐⭐⭐ Medium-Hard  
**Prerequisites:** Phase 1, 2, 3 must be completed

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

Referral system ที่ใช้ MiRO ID เป็น referral code:

**Features:**
- ✅ Referrer ได้ 15 Energy เมื่อ friend ใช้ AI 3 ครั้ง
- ✅ Referee ได้ 5 Energy bonus ทันที
- ✅ Max 2 referrals per month
- ✅ Anti-fraud (IP check, device fingerprint)
- ✅ 7 วัน expiry (referee ต้องใช้ AI ครบภายใน 7 วัน)

**Backend Functions ที่มีอยู่แล้ว:**
- ✅ `submitReferralCode` - Deploy แล้ว
- ✅ `checkReferralProgress` - ถูกเรียกใน `analyzeFood`

**สิ่งที่ต้องทำ:**
- เช็คและแก้ไข functions ที่มีอยู่
- เพิ่ม admin panel สำหรับ referral analytics
- ทดสอบ full flow

---

## 📊 Requirements

### Functional Requirements
- [ ] User สามารถ submit referral code ได้ (ภายใน 24 ชม. หลัง register)
- [ ] Referee ได้ 5 Energy ทันที
- [ ] Referee ต้องใช้ AI 3 ครั้งภายใน 7 วัน
- [ ] Referrer ได้ 15 Energy เมื่อ referee ใช้ AI ครบ 3 ครั้ง
- [ ] Limit 2 referrals per month (reset ทุกวันที่ 1)
- [ ] ห้าม refer ตัวเอง
- [ ] Anti-fraud: IP check

### Non-Functional Requirements
- [ ] Response time < 2 seconds
- [ ] Fraud detection accuracy > 95%
- [ ] Referral tracking 100% accurate

---

## 🏗️ Architecture

### Flow Diagram

```
┌─────────────┐
│  User A     │ Referrer
│  (ชวน)      │
└──────┬──────┘
       │ 1. Share MiRO ID
       │    "MIRO-A3F9-K7X2"
       ▼
┌─────────────┐
│  User B     │ Referee
│  (ถูกชวน)   │
└──────┬──────┘
       │ 2. Register → ได้ MiRO ID ของตัวเอง
       │ 3. Submit referral code
       │    POST /submitReferralCode
       │    { deviceId, referralCode }
       ▼
┌─────────────┐
│  Server     │
└──────┬──────┘
       │ 4. Validate:
       │    ✓ Code ถูกต้อง
       │    ✓ ไม่เกิน 24 ชม.
       │    ✓ Quota ยังไม่เต็ม
       │    ✓ ไม่ใช่ตัวเอง
       │    ✓ Anti-fraud
       │
       │ 5. ให้ Referee +5 Energy
       │ 6. สร้าง referral_record (pending)
       │
       │ Referee ใช้ AI ครั้งที่ 1 ✓
       │ Referee ใช้ AI ครั้งที่ 2 ✓
       │ Referee ใช้ AI ครั้งที่ 3 ✓
       │
       │ 7. ให้ Referrer +15 Energy
       │ 8. Update record status = completed
       │ 9. Send notification to Referrer
       ▼
    ✅ Done
```

### Firestore Schema

**Collection: `users/{deviceId}`** (เพิ่ม field)

```typescript
referrals: {
  myReferralCode: string;         // = miroId
  referredBy: string | null;      // MiRO ID ของคนชวน
  referredByDeviceId: string | null;
  referralCount: number;          // 0-2 (reset ทุกเดือน)
  referralResetDate: string;      // "YYYY-MM-01"
  referredUsers: string[];        // [miroId1, miroId2]
}
```

**Collection: `referral_records/{recordId}`** (สร้างใหม่)

```typescript
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
  expiresAt: Timestamp;           // 7 วันหลัง created
  ip: {
    referrer: string;
    referee: string;
  };
}
```

---

## 🚀 Step-by-Step Implementation

### Step 1: Review Existing Functions

Backend functions มีอยู่แล้วที่:
- `functions/src/referral/submitReferralCode.ts` ✅
- `functions/src/referral/checkReferralProgress.ts` ✅

**ทั้ง 2 functions ถูก deploy แล้ว** และพร้อมใช้งาน!

#### 1.1 Check submitReferralCode Function

อ่านไฟล์และตรวจสอบว่า logic ถูกต้อง:

```bash
cd functions/src/referral
cat submitReferralCode.ts
```

**สิ่งที่ต้องมี:**
- ✅ Validate deviceId และ referralCode
- ✅ เช็ค user exists
- ✅ เช็คว่าใส่ code แล้วหรือยัง
- ✅ เช็คว่า register ภายใน 24 ชม.
- ✅ ห้าม refer ตัวเอง
- ✅ หา referrer จาก MiRO ID
- ✅ เช็ค quota 2/month
- ✅ Anti-fraud check
- ✅ ให้ referee +5 Energy
- ✅ สร้าง referral_record

#### 1.2 Check checkReferralProgress Function

อ่านไฟล์และตรวจสอบ:

```bash
cat checkReferralProgress.ts
```

**สิ่งที่ต้องมี:**
- ✅ หา pending referral record
- ✅ เช็ค expiry
- ✅ Increment AI usage count
- ✅ ถ้าครบ 3 ครั้ง → ให้ referrer reward
- ✅ Update record status

**✅ Functions พร้อมใช้งานแล้ว!**

---

### Step 2: Integrate checkReferralProgress with analyzeFood

`checkReferralProgress` ต้องถูกเรียกใน `analyzeFood.ts` ทุกครั้งที่ user ใช้ AI สำเร็จ

#### 2.1 Update analyzeFood.ts

**File:** `functions/src/analyzeFood.ts`

ให้เพิ่ม import และเรียก function:

```typescript
import { checkReferralProgress } from './referral/checkReferralProgress';

// ... existing code ...

// หลังจาก AI analysis สำเร็จและ deduct energy แล้ว
// เพิ่มบรรทัดนี้:

try {
  await checkReferralProgress(deviceId);
} catch (error) {
  console.error('Error checking referral progress:', error);
  // ไม่ throw error เพราะไม่อยากให้กระทบ AI analysis
}
```

**ตำแหน่งที่ควรเพิ่ม:**

```typescript
// Example placement in analyzeFood.ts:

export const analyzeFood = onRequest(
  { ... },
  async (req, res) => {
    try {
      // ... existing logic ...
      
      // Deduct energy
      await deductEnergy(deviceId, energyCost);
      
      // AI analysis
      const result = await gemini.analyzeFood(imageUrl);
      
      // ✅ เพิ่มตรงนี้
      await checkReferralProgress(deviceId);
      
      res.status(200).json({ success: true, result });
    } catch (error) {
      // ...
    }
  }
);
```

---

### Step 3: Create Referral Expiry Cron Job

Cron job สำหรับ expire referral records ที่เกิน 7 วัน

#### 3.1 Create Cron Function

**File:** `functions/src/cron/expireReferrals.ts`

```typescript
import { onSchedule } from 'firebase-functions/v2/scheduler';
import * as admin from 'firebase-admin';

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

/**
 * expireReferrals
 * 
 * ทุกวันเวลา 02:00 UTC+7 (19:00 UTC)
 * หา pending referral records ที่หมดอายุแล้ว → update status = expired
 */
export const expireReferrals = onSchedule(
  {
    schedule: '0 19 * * *', // 02:00 Asia/Bangkok
    timeZone: 'UTC',
  },
  async (event) => {
    try {
      console.log('🔄 [Cron] Expiring old referral records...');

      const now = new Date();
      
      // หา pending records ที่หมดอายุแล้ว
      const snapshot = await db
        .collection('referral_records')
        .where('status', '==', 'pending')
        .where('expiresAt', '<', now)
        .get();

      if (snapshot.empty) {
        console.log('✅ [Cron] No expired referrals found');
        return;
      }

      // Update status = expired
      const batch = db.batch();
      snapshot.docs.forEach((doc) => {
        batch.update(doc.ref, {
          status: 'expired',
          expiredAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      });

      await batch.commit();

      console.log(`✅ [Cron] Expired ${snapshot.size} referral records`);
    } catch (error) {
      console.error('❌ [Cron] expireReferrals error:', error);
    }
  }
);
```

#### 3.2 Export Function

**File:** `functions/src/index.ts`

เพิ่ม:

```typescript
export { expireReferrals } from './cron/expireReferrals';
```

---

### Step 4: Create Referral Reset Cron Job

Reset referral count ทุกวันที่ 1 ของเดือน

#### 4.1 Create Cron Function

**File:** `functions/src/cron/resetReferralQuota.ts`

```typescript
import { onSchedule } from 'firebase-functions/v2/scheduler';
import * as admin from 'firebase-admin';

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

/**
 * resetReferralQuota
 * 
 * ทุกวันที่ 1 ของเดือน เวลา 00:00 UTC+7
 * Reset referralCount ของทุก user
 */
export const resetReferralQuota = onSchedule(
  {
    schedule: '0 17 1 * *', // 00:00 Asia/Bangkok on 1st of month
    timeZone: 'UTC',
  },
  async (event) => {
    try {
      console.log('🔄 [Cron] Resetting monthly referral quota...');

      const now = new Date();
      const currentMonth = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-01`;

      // หา users ที่มี referralCount > 0
      const snapshot = await db
        .collection('users')
        .where('referrals.referralCount', '>', 0)
        .get();

      if (snapshot.empty) {
        console.log('✅ [Cron] No users to reset');
        return;
      }

      // Reset quota
      const batch = db.batch();
      snapshot.docs.forEach((doc) => {
        batch.update(doc.ref, {
          'referrals.referralCount': 0,
          'referrals.referralResetDate': currentMonth,
        });
      });

      await batch.commit();

      console.log(`✅ [Cron] Reset quota for ${snapshot.size} users`);
    } catch (error) {
      console.error('❌ [Cron] resetReferralQuota error:', error);
    }
  }
);
```

#### 4.2 Export Function

**File:** `functions/src/index.ts`

```typescript
export { resetReferralQuota } from './cron/resetReferralQuota';
```

---

### Step 5: Deploy Functions

Deploy ทุก functions ที่เกี่ยวข้อง:

```bash
cd functions

# Deploy ทั้งหมด
firebase deploy --only functions

# หรือ deploy เฉพาะที่ต้องการ
firebase deploy --only functions:submitReferralCode
firebase deploy --only functions:expireReferrals
firebase deploy --only functions:resetReferralQuota
```

**ตรวจสอบ deployment:**

```bash
firebase functions:log --only submitReferralCode
```

---

### Step 6: Create Firestore Indexes

Referral system ต้องใช้ indexes เหล่านี้:

#### 6.1 Add to firestore.indexes.json

**File:** `firestore.indexes.json`

```json
{
  "indexes": [
    {
      "collectionGroup": "referral_records",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "refereeId", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "referral_records",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "expiresAt", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "referral_records",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "referrerId", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    }
  ]
}
```

#### 6.2 Deploy Indexes

```bash
firebase deploy --only firestore:indexes
```

---

### Step 7: Test Backend Functions

#### 7.1 Test submitReferralCode

**Test Case 1: Valid Referral**

```bash
curl -X POST https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/submitReferralCode \
  -H "Content-Type: application/json" \
  -d '{
    "deviceId": "TEST_DEVICE_123",
    "referralCode": "MIRO-A3F9-K7X2-P8M1"
  }'
```

**Expected Response:**

```json
{
  "success": true,
  "bonusEnergy": 5,
  "message": "You got 5 Energy! Use AI 3 times to help your friend get 15 Energy too!"
}
```

**Test Case 2: Self-Referral (Should Fail)**

```bash
curl -X POST https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/submitReferralCode \
  -H "Content-Type: application/json" \
  -d '{
    "deviceId": "TEST_DEVICE_123",
    "referralCode": "MIRO-SAME-AS-MYSELF"
  }'
```

**Expected Response:**

```json
{
  "error": "Cannot refer yourself"
}
```

**Test Case 3: Invalid Code (Should Fail)**

```bash
curl -X POST https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/submitReferralCode \
  -H "Content-Type: application/json" \
  -d '{
    "deviceId": "TEST_DEVICE_123",
    "referralCode": "MIRO-INVALID-CODE"
  }'
```

**Expected Response:**

```json
{
  "error": "Invalid referral code"
}
```

#### 7.2 Test Referral Completion

1. Referee submit referral code สำเร็จ → ได้ +5 Energy
2. Referee ใช้ AI 3 ครั้ง
3. ตรวจสอบว่า Referrer ได้ +15 Energy

**Check Firestore:**

```javascript
// ใน Firebase Console → Firestore
// Collection: referral_records

// ก่อนใช้ AI:
{
  status: "pending",
  refereeAiUsageCount: 0
}

// หลังใช้ AI ครั้งที่ 1:
{
  status: "pending",
  refereeAiUsageCount: 1
}

// หลังใช้ AI ครั้งที่ 3:
{
  status: "completed",
  refereeAiUsageCount: 3,
  completedAt: Timestamp
}

// Referrer ได้ +15 Energy ใน transactions collection
```

#### 7.3 Test Quota Limit

1. User A refer friend 1 → Success
2. User A refer friend 2 → Success
3. User A refer friend 3 → Should fail with "Referrer has reached monthly limit"

---

## 🧪 Testing Checklist

### Basic Flow
- [ ] Referee submit valid code → ได้ +5 Energy
- [ ] Referee ใช้ AI 1 ครั้ง → refereeAiUsageCount = 1
- [ ] Referee ใช้ AI 3 ครั้ง → Referrer ได้ +15 Energy
- [ ] Record status เปลี่ยนเป็น "completed"

### Edge Cases
- [ ] Refer ตัวเอง → Error
- [ ] Invalid code → Error
- [ ] Already used code → Error
- [ ] Submit after 24 hours → Error
- [ ] Quota 2/month reached → Error on 3rd
- [ ] Referee ไม่ใช้ AI ภายใน 7 วัน → status = "expired"

### Cron Jobs
- [ ] expireReferrals ทำงานทุกวัน
- [ ] resetReferralQuota ทำงานวันที่ 1 ของเดือน

### Firestore
- [ ] referral_records collection ถูกสร้าง
- [ ] Indexes ถูก deploy
- [ ] Transactions ถูก log ถูกต้อง

---

## 🐛 Troubleshooting

### Issue: "Missing fields" Error

**Cause:** deviceId หรือ referralCode ไม่ได้ส่งมา

**Solution:**
```javascript
// ตรวจสอบ request body
console.log('Request body:', req.body);
```

### Issue: "User not found" Error

**Cause:** deviceId ไม่มีใน Firestore

**Solution:**
- ตรวจสอบว่า user register แล้วหรือยัง
- ตรวจสอบว่า `registerUser` function ทำงานถูกต้อง

### Issue: Referrer ไม่ได้รับ reward หลัง referee ใช้ AI 3 ครั้ง

**Cause:** `checkReferralProgress` ไม่ถูกเรียกใน `analyzeFood`

**Solution:**
- ตรวจสอบว่าเพิ่ม `await checkReferralProgress(deviceId)` แล้ว
- ตรวจสอบ logs ใน Firebase Functions Console

### Issue: Quota ไม่ reset ทุกเดือน

**Cause:** Cron job ไม่ทำงาน

**Solution:**
```bash
# ตรวจสอบ cron job logs
firebase functions:log --only resetReferralQuota

# ทดสอบ manual
firebase functions:shell
resetReferralQuota()
```

### Issue: Duplicate rewards

**Cause:** Race condition ใน transaction

**Solution:**
- ใช้ Firestore transaction อย่างถูกต้อง
- เช็ค status ก่อน give reward

---

## ✅ Completion Checklist

- [ ] reviewExisting functions (submitReferralCode, checkReferralProgress)
- [ ] Integrate checkReferralProgress ใน analyzeFood
- [ ] สร้าง expireReferrals cron job
- [ ] สร้าง resetReferralQuota cron job
- [ ] Deploy ทุก functions
- [ ] Deploy Firestore indexes
- [ ] ทดสอบ full referral flow
- [ ] ทดสอบ edge cases ทั้งหมด
- [ ] ทดสอบ cron jobs
- [ ] Document API endpoints

---

## 📸 Expected Results

### Firestore Structure After Successful Referral

**users/{refereeDeviceId}:**
```json
{
  "miroId": "MIRO-B1C2-D3E4-F5G6",
  "balance": 105,  // 100 (welcome) + 5 (referral)
  "referrals": {
    "myReferralCode": "MIRO-B1C2-D3E4-F5G6",
    "referredBy": "MIRO-A3F9-K7X2-P8M1",
    "referredByDeviceId": "referrer_device_id"
  }
}
```

**users/{referrerDeviceId}:** (after referee completes 3 AI)
```json
{
  "miroId": "MIRO-A3F9-K7X2-P8M1",
  "balance": 165,  // 150 + 15 (referral reward)
  "referrals": {
    "referralCount": 1,
    "referralResetDate": "2026-02-01",
    "referredUsers": ["MIRO-B1C2-D3E4-F5G6"]
  }
}
```

**referral_records/{recordId}:**
```json
{
  "referrerId": "referrer_device_id",
  "referrerMiroId": "MIRO-A3F9-K7X2-P8M1",
  "refereeId": "referee_device_id",
  "refereeMiroId": "MIRO-B1C2-D3E4-F5G6",
  "status": "completed",
  "refereeAiUsageCount": 3,
  "requiredUsage": 3,
  "referrerReward": 15,
  "refereeReward": 5,
  "createdAt": "2026-02-17T10:00:00Z",
  "completedAt": "2026-02-18T15:30:00Z",
  "expiresAt": "2026-02-24T10:00:00Z"
}
```

---

## 🚀 Next Steps

After completing this task:
1. Test thoroughly with real users
2. Monitor logs for errors
3. Move to **Task 2: Referral UI (Flutter)**

---

**Documentation Version:** 1.0  
**Last Updated:** 2026-02-17  
**Author:** Senior Developer  
**For:** Junior Developer

<function_calls>
<invoke name="Read">
<parameter name="path">c:\aiprogram\miro\functions\src\referral\submitReferralCode.ts