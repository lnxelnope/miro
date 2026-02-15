# 01: Backend Setup (Cloud Functions)

> ⏱ **เวลา:** 3-4 ชั่วโมง  
> 🎯 **เป้าหมาย:** สร้าง Cloud Functions สำหรับ Generate และ Redeem Transfer Key

---

## 📂 ไฟล์ที่จะสร้าง/แก้

```
functions/
├── src/
│   ├── transferKey.ts  ← สร้างใหม่ (ไฟล์หลัก)
│   └── index.ts        ← แก้ไข (เพิ่ม export)
```

---

## ขั้นตอนที่ 1: สร้างไฟล์ `transferKey.ts`

### 1.1 เปิด Terminal และไปที่โฟลเดอร์ functions
```bash
cd functions
```

### 1.2 สร้างไฟล์ใหม่
```bash
# Windows (PowerShell)
New-Item -Path "src\transferKey.ts" -ItemType File

# macOS/Linux
touch src/transferKey.ts
```

### 1.3 เปิดไฟล์ `src/transferKey.ts` แล้ว**คัดลอกโค้ดนี้ทั้งหมด**

```typescript
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// ============================================================
// Constants
// ============================================================

// ตัวอักษรที่ใช้สำหรับ Transfer Key (ไม่รวมตัวที่สับสน: 0/O, 1/I/L)
const CHARSET = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

// Transfer Key หมดอายุใน 30 วัน
const KEY_EXPIRY_DAYS = 30;

// Rate limit: สร้าง key ได้สูงสุด 5 ครั้ง/ชั่วโมง/device
const RATE_LIMIT_PER_HOUR = 5;

// ============================================================
// Helper Functions
// ============================================================

/**
 * สร้าง Transfer Key รูปแบบ: MIRO-XXXX-XXXX-XXXX
 * ตัวอย่าง: MIRO-A3F9-K7X2-P8M1
 */
function generateTransferKeyString(): string {
  const segments: string[] = [];
  
  // สร้าง 3 segment (แต่ละ segment มี 4 ตัวอักษร)
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
 * ตรวจสอบ Rate Limit: จำกัดการสร้าง key ไม่เกิน 5 ครั้ง/ชั่วโมง
 */
async function checkRateLimit(deviceId: string): Promise<void> {
  const oneHourAgo = admin.firestore.Timestamp.fromDate(
    new Date(Date.now() - 60 * 60 * 1000)
  );
  
  const recentKeys = await admin
    .firestore()
    .collection('transfer_keys')
    .where('sourceDeviceId', '==', deviceId)
    .where('createdAt', '>', oneHourAgo)
    .get();
  
  if (recentKeys.size >= RATE_LIMIT_PER_HOUR) {
    throw new functions.https.HttpsError(
      'resource-exhausted',
      'Rate limit exceeded. You can generate up to 5 transfer keys per hour.'
    );
  }
}

/**
 * Expire key เก่าที่ยัง active อยู่ (สร้างได้แค่ 1 active key/device)
 */
async function expirePreviousActiveKeys(deviceId: string): Promise<void> {
  const activeKeys = await admin
    .firestore()
    .collection('transfer_keys')
    .where('sourceDeviceId', '==', deviceId)
    .where('status', '==', 'active')
    .get();
  
  const batch = admin.firestore().batch();
  
  activeKeys.forEach(doc => {
    batch.update(doc.ref, {
      status: 'expired',
      expiredAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });
  
  if (!batch.isEmpty) {
    await batch.commit();
  }
}

// ============================================================
// Cloud Function: generateTransferKey
// ============================================================

export const generateTransferKey = functions
  .region('asia-southeast1')
  .https.onCall(async (data, context) => {
    // 1. Validate Input
    const { deviceId } = data;
    
    if (!deviceId || typeof deviceId !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'deviceId is required and must be a string'
      );
    }
    
    try {
      // 2. ตรวจสอบ Rate Limit
      await checkRateLimit(deviceId);
      
      // 3. ดึง Energy Balance ปัจจุบัน
      const energyDoc = await admin
        .firestore()
        .collection('energy')
        .doc(deviceId)
        .get();
      
      if (!energyDoc.exists) {
        throw new functions.https.HttpsError(
          'not-found',
          'Device not found in energy collection'
        );
      }
      
      const energyBalance = energyDoc.data()?.balance || 0;
      
      // 4. Expire key เก่าที่ยัง active
      await expirePreviousActiveKeys(deviceId);
      
      // 5. สร้าง Transfer Key ใหม่
      const transferKey = generateTransferKeyString();
      const now = admin.firestore.Timestamp.now();
      const expiresAt = admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + KEY_EXPIRY_DAYS * 24 * 60 * 60 * 1000)
      );
      
      // 6. บันทึกลง Firestore
      await admin
        .firestore()
        .collection('transfer_keys')
        .add({
          transferKey,
          sourceDeviceId: deviceId,
          energyBalance, // Snapshot ตอนสร้าง key
          status: 'active',
          createdAt: now,
          expiresAt,
          redeemedAt: null,
          redeemedByDeviceId: null,
        });
      
      // 7. Return ผลลัพธ์
      return {
        success: true,
        transferKey,
        energyBalance,
        expiresAt: expiresAt.toDate().toISOString(),
      };
      
    } catch (error: any) {
      console.error('Error in generateTransferKey:', error);
      
      // ถ้าเป็น HttpsError แล้ว → throw ต่อ
      if (error instanceof functions.https.HttpsError) {
        throw error;
      }
      
      // Error อื่น ๆ → wrap เป็น internal error
      throw new functions.https.HttpsError(
        'internal',
        'Failed to generate transfer key',
        error.message
      );
    }
  });

// ============================================================
// Cloud Function: redeemTransferKey
// ============================================================

export const redeemTransferKey = functions
  .region('asia-southeast1')
  .https.onCall(async (data, context) => {
    // 1. Validate Input
    const { transferKey, newDeviceId } = data;
    
    if (!transferKey || typeof transferKey !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'transferKey is required and must be a string'
      );
    }
    
    if (!newDeviceId || typeof newDeviceId !== 'string') {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'newDeviceId is required and must be a string'
      );
    }
    
    // 2. Validate Transfer Key Format (ป้องกัน brute force)
    const keyPattern = /^MIRO-[A-Z2-9]{4}-[A-Z2-9]{4}-[A-Z2-9]{4}$/;
    if (!keyPattern.test(transferKey)) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Invalid transfer key format'
      );
    }
    
    try {
      // 3. ค้นหา Transfer Key ใน Firestore
      const keysSnapshot = await admin
        .firestore()
        .collection('transfer_keys')
        .where('transferKey', '==', transferKey)
        .limit(1)
        .get();
      
      if (keysSnapshot.empty) {
        throw new functions.https.HttpsError(
          'not-found',
          'Transfer key not found'
        );
      }
      
      const keyDoc = keysSnapshot.docs[0];
      const keyData = keyDoc.data();
      
      // 4. Validate Key Status
      if (keyData.status === 'redeemed') {
        throw new functions.https.HttpsError(
          'already-exists',
          'Transfer key has already been redeemed'
        );
      }
      
      if (keyData.status === 'expired') {
        throw new functions.https.HttpsError(
          'failed-precondition',
          'Transfer key has expired'
        );
      }
      
      // ตรวจสอบวันหมดอายุ
      const now = admin.firestore.Timestamp.now();
      if (keyData.expiresAt && keyData.expiresAt < now) {
        // Update status เป็น expired
        await keyDoc.ref.update({
          status: 'expired',
          expiredAt: now,
        });
        
        throw new functions.https.HttpsError(
          'failed-precondition',
          'Transfer key has expired'
        );
      }
      
      // 5. ป้องกันการโอนให้เครื่องเดิม
      const sourceDeviceId = keyData.sourceDeviceId;
      if (sourceDeviceId === newDeviceId) {
        throw new functions.https.HttpsError(
          'invalid-argument',
          'Cannot transfer to the same device'
        );
      }
      
      // 6. ดึง Energy Balance จริงจากเครื่องต้นทาง
      const sourceEnergyDoc = await admin
        .firestore()
        .collection('energy')
        .doc(sourceDeviceId)
        .get();
      
      if (!sourceEnergyDoc.exists) {
        throw new functions.https.HttpsError(
          'not-found',
          'Source device energy not found'
        );
      }
      
      const sourceBalance = sourceEnergyDoc.data()?.balance || 0;
      
      // 7. ดึง Energy Balance ปัจจุบันของเครื่องใหม่ (สำหรับ logging)
      const newEnergyDoc = await admin
        .firestore()
        .collection('energy')
        .doc(newDeviceId)
        .get();
      
      const previousBalance = newEnergyDoc.exists
        ? newEnergyDoc.data()?.balance || 0
        : 0;
      
      // 8. Atomic Transaction: โอน Energy
      await admin.firestore().runTransaction(async (transaction) => {
        // a. SET energy ของเครื่องเก่า = 0
        transaction.set(
          admin.firestore().collection('energy').doc(sourceDeviceId),
          {
            balance: 0,
            lastTransferredAt: admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true }
        );
        
        // b. SET energy ของเครื่องใหม่ = sourceBalance (REPLACE ไม่ใช่ ADD)
        transaction.set(
          admin.firestore().collection('energy').doc(newDeviceId),
          {
            balance: sourceBalance,
            lastReceivedAt: admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true }
        );
        
        // c. Mark key เป็น "redeemed"
        transaction.update(keyDoc.ref, {
          status: 'redeemed',
          redeemedAt: admin.firestore.FieldValue.serverTimestamp(),
          redeemedByDeviceId: newDeviceId,
        });
      });
      
      // 9. Return ผลลัพธ์
      return {
        success: true,
        energyTransferred: sourceBalance,
        previousBalance,
        newBalance: sourceBalance,
      };
      
    } catch (error: any) {
      console.error('Error in redeemTransferKey:', error);
      
      // ถ้าเป็น HttpsError แล้ว → throw ต่อ
      if (error instanceof functions.https.HttpsError) {
        throw error;
      }
      
      // Error อื่น ๆ → wrap เป็น internal error
      throw new functions.https.HttpsError(
        'internal',
        'Failed to redeem transfer key',
        error.message
      );
    }
  });
```

### 1.4 บันทึกไฟล์

---

## ขั้นตอนที่ 2: แก้ไขไฟล์ `index.ts`

### 2.1 เปิดไฟล์ `functions/src/index.ts`

### 2.2 เพิ่มบรรทัดนี้ (ด้านบนสุดของไฟล์ หลังจาก import อื่น ๆ)

```typescript
// Export Transfer Key functions
export { generateTransferKey, redeemTransferKey } from './transferKey';
```

### 2.3 บันทึกไฟล์

---

## ขั้นตอนที่ 3: ตรวจสอบ Firestore Indexes (ถ้าจำเป็น)

### 3.1 เปิดไฟล์ `functions/firestore.indexes.json`

ถ้าไม่มีไฟล์นี้ → สร้างใหม่ใน `functions/firestore.indexes.json`:

```json
{
  "indexes": [
    {
      "collectionGroup": "transfer_keys",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "sourceDeviceId", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "transfer_keys",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "sourceDeviceId", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" }
      ]
    }
  ],
  "fieldOverrides": []
}
```

ถ้ามีแล้ว → เพิ่ม 2 indexes ข้างบนเข้าไปใน array `indexes`

---

## ขั้นตอนที่ 4: Deploy Cloud Functions

### 4.1 Build TypeScript
```bash
cd functions
npm run build
```

**ผลลัพธ์ที่คาดหวัง:**
```
✔ Build complete
```

ถ้า Error → ดูที่ `06_ERROR_HANDLING.md` section "TypeScript Build Errors"

### 4.2 Deploy to Firebase
```bash
firebase deploy --only functions:generateTransferKey,functions:redeemTransferKey
```

**ผลลัพธ์ที่คาดหวัง:**
```
✔ functions[generateTransferKey(asia-southeast1)] Successful update operation.
✔ functions[redeemTransferKey(asia-southeast1)] Successful update operation.
✔ Deploy complete!
```

---

## ขั้นตอนที่ 5: ทดสอบ Cloud Functions

### 5.1 ทดสอบ `generateTransferKey` ด้วย Firebase Emulator

เปิด Terminal ใหม่:
```bash
cd functions
npm run serve
```

**จะเห็น:**
```
✔ functions[asia-southeast1-generateTransferKey]: http function initialized
✔ functions[asia-southeast1-redeemTransferKey]: http function initialized
```

### 5.2 ทดสอบด้วย Flutter (หรือ Postman)

สร้างไฟล์ทดสอบชั่วคราว `test_functions.dart`:

```dart
import 'package:cloud_functions/cloud_functions.dart';

Future<void> testGenerateKey() async {
  try {
    final result = await FirebaseFunctions.instanceFor(region: 'asia-southeast1')
        .httpsCallable('generateTransferKey')
        .call({
      'deviceId': 'test-device-123',
    });
    
    print('✅ Success: ${result.data}');
    // คาดหวัง: { success: true, transferKey: "MIRO-...", energyBalance: ... }
    
  } catch (e) {
    print('❌ Error: $e');
  }
}

Future<void> testRedeemKey(String transferKey) async {
  try {
    final result = await FirebaseFunctions.instanceFor(region: 'asia-southeast1')
        .httpsCallable('redeemTransferKey')
        .call({
      'transferKey': transferKey,
      'newDeviceId': 'new-device-456',
    });
    
    print('✅ Success: ${result.data}');
    // คาดหวัง: { success: true, energyTransferred: ..., newBalance: ... }
    
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

### 5.3 ทดสอบ Error Cases (ต้องผ่านทุกข้อ)

| Test Case | คาดหวัง | วิธีทดสอบ |
|-----------|---------|-----------|
| สร้าง key ครั้งแรก | Success | เรียก `generateTransferKey` ด้วย deviceId ใหม่ |
| สร้าง key ซ้ำ (key เก่า expire) | Success + key ใหม่ | เรียก `generateTransferKey` อีกครั้งด้วย deviceId เดิม |
| Redeem key ที่ valid | Success | เรียก `redeemTransferKey` ด้วย key ที่ได้ + deviceId ใหม่ |
| Redeem key ซ้ำ | Error: "already redeemed" | เรียก `redeemTransferKey` ด้วย key เดิมอีกครั้ง |
| Redeem ด้วย deviceId เดิม | Error: "Cannot transfer to same device" | เรียก `redeemTransferKey` ด้วย sourceDeviceId |
| Redeem key ที่ไม่มีอยู่ | Error: "Transfer key not found" | เรียก `redeemTransferKey` ด้วย key ปลอม |

---

## ขั้นตอนที่ 6: Firestore Security Rules

### 6.1 เปิดไฟล์ `firestore.rules`

### 6.2 เพิ่ม Rules สำหรับ `transfer_keys` collection

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ... rules อื่น ๆ ที่มีอยู่แล้ว ...
    
    // Transfer Keys Collection
    // ❗ ห้าม read/write โดยตรงจาก client → ต้องผ่าน Cloud Functions เท่านั้น
    match /transfer_keys/{keyId} {
      allow read, write: if false;
    }
  }
}
```

### 6.3 Deploy Rules
```bash
firebase deploy --only firestore:rules
```

---

## ✅ Checklist สำหรับ Phase นี้

ตรวจสอบก่อนไป Phase ต่อไป:

- [ ] ไฟล์ `functions/src/transferKey.ts` สร้างแล้ว
- [ ] ไฟล์ `functions/src/index.ts` แก้ไขแล้ว (เพิ่ม export)
- [ ] `npm run build` ผ่าน (ไม่มี TypeScript errors)
- [ ] Deploy Cloud Functions สำเร็จ
- [ ] ทดสอบ `generateTransferKey` ได้ key กลับมา
- [ ] ทดสอบ `redeemTransferKey` โอน energy สำเร็จ
- [ ] ทดสอบ error cases ผ่านทั้งหมด
- [ ] Firestore Rules deploy แล้ว

---

## 🎉 สำเร็จ!

Backend เสร็จแล้ว! ตอนนี้ระบบมี:
- ✅ Cloud Function สำหรับสร้าง Transfer Key
- ✅ Cloud Function สำหรับ Redeem Transfer Key
- ✅ Firestore Collection: `transfer_keys`
- ✅ Security ครบถ้วน (Rate limit, Expiry, Single-use)

➡️ **[ไปที่ Phase 2: Client Service](./02_CLIENT_SERVICE.md)**

---

## 🆘 หากมีปัญหา

### Build Error
```bash
# ลองลบ node_modules และ install ใหม่
cd functions
rm -rf node_modules
npm install
npm run build
```

### Deploy Error
```bash
# ตรวจสอบว่า login อยู่หรือไม่
firebase login

# ตรวจสอบ project
firebase use --add

# ลอง deploy อีกครั้ง
firebase deploy --only functions
```

### Function ไม่ทำงาน
1. เช็ค Firebase Console → Functions → Logs
2. ดู Error Message ที่ปรากฏ
3. ตรวจสอบว่า `admin.initializeApp()` มีใน `index.ts` หรือไม่

---

*Next: [02_CLIENT_SERVICE.md](./02_CLIENT_SERVICE.md)*
