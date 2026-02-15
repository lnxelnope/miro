# Phase 1: Firestore Balance (Server = Source of Truth)

> **🔴 Priority: CRITICAL — ทำ Phase นี้ก่อนทุก Phase**  
> **⏱️ Estimated Time: 1-2 วัน**  
> **🎯 Goal: Backend เป็นตัวกำหนด balance, Client เป็นแค่ cache**

---

## 📋 สารบัญ

- [Step 1.1: Setup Firestore](#step-11-setup-firestore)
- [Step 1.2: Backend - เพิ่ม Firestore Helpers](#step-12-backend---เพิ่ม-firestore-helpers)
- [Step 1.3: Backend - แก้ analyzeFood handler](#step-13-backend---แก้-analyzefood-handler)
- [Step 1.4: Backend - เพิ่ม syncBalance endpoint](#step-14-backend---เพิ่ม-syncbalance-endpoint)
- [Step 1.5: Client - แก้ EnergyService](#step-15-client---แก้-energyservice)
- [Testing](#testing)

---

## เป้าหมายของ Phase นี้

### ❌ ปัญหาปัจจุบัน

```
Client: balance = 95 (อยู่ใน SharedPreferences)
   ↓
Token: { userId, balance: 95, timestamp, signature }
   ↓
Backend: อ่าน balance จาก Token → เชื่อ Client!
```

**ผลลัพธ์**: Client แก้ balance เป็น 9999 → Token ก็จะมี balance: 9999 → Backend เชื่อ!

### ✅ หลังแก้

```
Client: balance = 95 (cache only, ไม่สำคัญ)
   ↓
Token: { userId, timestamp, signature } (ไม่มี balance)
   ↓
Backend: 
  1. อ่าน balance จาก FIRESTORE (Server = Truth)
  2. เช็คว่าพอหรือเปล่า
  3. หัก balance ใน FIRESTORE (atomic)
  4. ส่ง newBalance กลับให้ Client sync
```

**ผลลัพธ์**: Client แก้ balance เป็น 9999 → Backend ignore → อ่านจาก Firestore แทน → ปลอดภัย!

---

## Step 1.1: Setup Firestore

### 1.1.1 ตรวจสอบ Firebase Admin SDK

ไฟล์: `functions/package.json`

```bash
cd functions
cat package.json
```

ตรวจสอบว่ามี dependencies นี้:

```json
{
  "dependencies": {
    "firebase-admin": "^13.6.0",
    "firebase-functions": "^7.0.0"
  }
}
```

ถ้ายังไม่มี หรือ version เก่า:

```bash
npm install firebase-admin@latest firebase-functions@latest
```

### 1.1.2 ตั้งค่า Firestore Rules

ไฟล์: `firestore.rules`

**ตรวจสอบว่ามีไฟล์นี้ใน root directory หรือไม่**

ถ้ายังไม่มี ให้สร้างใหม่:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ─── Energy balances collection ───
    // ห้าม Client เข้าถึงตรง — เฉพาะ Cloud Functions เท่านั้น
    match /energy_balances/{deviceId} {
      allow read, write: if false;
    }
    
    // ─── Purchase records collection ───
    // ห้าม Client เข้าถึงตรง — เฉพาะ Cloud Functions เท่านั้น
    match /purchase_records/{purchaseHash} {
      allow read, write: if false;
    }
    
    // Collections อื่นๆ ที่มีอยู่เดิม...
    // (ไม่ต้องแก้ rules ของ collection อื่น)
  }
}
```

**Deploy Firestore Rules:**

```bash
firebase deploy --only firestore:rules
```

**คาดหวังผลลัพธ์:**

```
✔  firestore: deployed indexes in firestore.indexes.json successfully
✔  firestore: deployed rules firestore.rules successfully
```

### 1.1.3 ตรวจสอบ Firestore Structure

ใน Firebase Console → Firestore Database:

```
/energy_balances (collection) — ยังไม่มี document ก็ได้ (จะสร้างตอน runtime)
  /{deviceId} (document)
    - balance: number
    - lastUpdated: timestamp
    - welcomeGiftClaimed: boolean
    - createdAt: timestamp

/purchase_records (collection) — ยังไม่มีก็ได้ (จะสร้างใน Phase 2)
```

**ไม่ต้องสร้างอะไรตอนนี้** — Cloud Function จะสร้างให้เมื่อมีการใช้งาน

---

## Step 1.2: Backend - เพิ่ม Firestore Helpers

ไฟล์: `functions/src/analyzeFood.ts`

### 1.2.1 Import Firebase Admin (ถ้ายังไม่มี)

**ตรวจสอบด้านบนสุดของไฟล์ว่ามี import นี้หรือไม่:**

```typescript
import * as admin from 'firebase-admin';
```

ถ้ายังไม่มี ให้เพิ่ม

### 1.2.2 Initialize Firestore (ถ้ายังไม่มี)

**ค้นหาว่ามี `admin.initializeApp()` หรือยัง:**

```typescript
// ใกล้ๆ บรรทัดที่ 20-30 ประมาณนี้
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();
```

**ถ้ายังไม่มี ให้เพิ่มหลังจาก imports ทั้งหมด**

**⚠️ สำคัญ**: ต้อง initialize ครั้งเดียวเท่านั้น ถ้ามีแล้วอย่าเพิ่มซ้ำ

### 1.2.3 เพิ่ม Helper Functions

**เพิ่มก่อนฟังก์ชัน `analyzeFood` (ประมาณบรรทัดที่ 300-350):**

```typescript
// ===================================================================
// FIRESTORE HELPERS - Phase 1: Server-side Balance
// ===================================================================

/**
 * อ่าน balance จาก Firestore (Server = Source of Truth)
 * ถ้ายังไม่มี document → สร้างใหม่พร้อม welcome gift
 */
async function getServerBalance(deviceId: string): Promise<number> {
  try {
    const docRef = db.collection('energy_balances').doc(deviceId);
    const doc = await docRef.get();
    
    if (!doc.exists) {
      // New user — สร้าง document พร้อม welcome gift
      const welcomeBalance = 100;
      
      await docRef.set({
        balance: welcomeBalance,
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        welcomeGiftClaimed: true,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      
      console.log(`🎁 [Firestore] New user ${deviceId}: Welcome gift ${welcomeBalance}`);
      return welcomeBalance;
    }
    
    const balance = doc.data()?.balance ?? 0;
    console.log(`📊 [Firestore] User ${deviceId}: Balance = ${balance}`);
    return balance;
    
  } catch (error) {
    console.error(`❌ [Firestore] Error reading balance for ${deviceId}:`, error);
    throw new Error('Failed to read server balance');
  }
}

/**
 * หัก balance ใน Firestore (Atomic Transaction)
 * ป้องกัน race condition เมื่อมีหหลาย request พร้อมกัน
 * 
 * @param deviceId - Device ID ของ user
 * @param amount - จำนวนที่จะหัก
 * @returns balance ใหม่หลังหัก
 */
async function deductServerBalance(
  deviceId: string,
  amount: number
): Promise<number> {
  try {
    const docRef = db.collection('energy_balances').doc(deviceId);
    
    // ใช้ Transaction เพื่อป้องกัน race condition
    const newBalance = await db.runTransaction(async (transaction) => {
      const doc = await transaction.get(docRef);
      
      if (!doc.exists) {
        throw new Error('User not found in Firestore');
      }
      
      const currentBalance = doc.data()?.balance ?? 0;
      
      // ห้าม balance ติดลบ
      if (currentBalance < amount) {
        throw new Error(`Insufficient balance: have ${currentBalance}, need ${amount}`);
      }
      
      const updated = currentBalance - amount;
      
      transaction.update(docRef, {
        balance: updated,
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      });
      
      console.log(`💰 [Firestore] ${deviceId}: ${currentBalance} - ${amount} = ${updated}`);
      return updated;
    });
    
    return newBalance;
    
  } catch (error) {
    console.error(`❌ [Firestore] Error deducting balance for ${deviceId}:`, error);
    throw error;
  }
}

/**
 * เพิ่ม balance ใน Firestore (สำหรับ purchase, gift, etc.)
 * 
 * @param deviceId - Device ID ของ user
 * @param amount - จำนวนที่จะเพิ่ม
 * @param reason - เหตุผล (purchase, gift, welcome, etc.)
 * @returns balance ใหม่หลังเพิ่ม
 */
async function addServerBalance(
  deviceId: string,
  amount: number,
  reason: string
): Promise<number> {
  try {
    const docRef = db.collection('energy_balances').doc(deviceId);
    
    const newBalance = await db.runTransaction(async (transaction) => {
      const doc = await transaction.get(docRef);
      
      const currentBalance = doc.exists ? (doc.data()?.balance ?? 0) : 0;
      const updated = currentBalance + amount;
      
      if (doc.exists) {
        transaction.update(docRef, {
          balance: updated,
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        });
      } else {
        transaction.set(docRef, {
          balance: updated,
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
      
      console.log(`💎 [Firestore] ${deviceId}: ${currentBalance} + ${amount} = ${updated} (${reason})`);
      return updated;
    });
    
    return newBalance;
    
  } catch (error) {
    console.error(`❌ [Firestore] Error adding balance for ${deviceId}:`, error);
    throw error;
  }
}
```

**✅ Checkpoint**: บันทึกไฟล์แล้วตรวจสอบว่าไม่มี syntax error

---

## Step 1.3: Backend - แก้ analyzeFood handler

ไฟล์: `functions/src/analyzeFood.ts`

### 1.3.1 หาส่วนที่เช็ค balance (ประมาณบรรทัด 370-390)

**ค้นหา code นี้:**

```typescript
// 4.1 Check Energy Balance
const token = verifyEnergyToken(energyToken, secret);

if (!token || token.balance < 1) {
  res.status(402).json({ 
    error: 'Insufficient energy',
    balance: token?.balance ?? 0,
  });
  return;
}
```

### 1.3.2 แทนที่ด้วย code ใหม่ (อ่าน balance จาก Firestore)

```typescript
// ===================================================================
// 4.1 Check Energy Balance — PHASE 1: อ่านจาก Firestore
// ===================================================================
const token = verifyEnergyToken(energyToken, secret);

if (!token) {
  res.status(401).json({ error: 'Invalid or expired token' });
  return;
}

// ✅ อ่าน balance จาก FIRESTORE (Server = Source of Truth)
const deviceId = token.userId;
let serverBalance: number;

try {
  serverBalance = await getServerBalance(deviceId);
} catch (error) {
  console.error('[analyzeFood] Failed to get server balance:', error);
  res.status(500).json({ error: 'Failed to check balance' });
  return;
}

// คำนวณ cost
const baseCost = 1;
const extraCost = hasImage ? 1 : 0;
const totalCost = baseCost + extraCost;

// เช็คว่า balance พอหรือไม่
if (serverBalance < totalCost) {
  console.log(`❌ [analyzeFood] Insufficient balance: have ${serverBalance}, need ${totalCost}`);
  res.status(402).json({
    error: 'Insufficient energy',
    balance: serverBalance,
    required: totalCost,
  });
  return;
}

console.log(`✅ [analyzeFood] Balance check passed: ${serverBalance} >= ${totalCost}`);
```

### 1.3.3 หาส่วนที่หัก balance (ประมาณบรรทัด 450-480)

**ค้นหา code ที่มี `newBalance` หลังเรียก Gemini API สำเร็จ:**

```typescript
// 4.5 Update Energy Balance
const newBalance = token.balance - totalCost;
const newToken = generateEnergyToken(
  token.userId,
  newBalance,
  secret
);
```

### 1.3.4 แทนที่ด้วย code ใหม่ (หัก balance ใน Firestore)

```typescript
// ===================================================================
// 4.5 Update Energy Balance — PHASE 1: หักใน Firestore
// ===================================================================
let newBalance: number;

try {
  newBalance = await deductServerBalance(deviceId, totalCost);
  console.log(`✅ [analyzeFood] Balance updated: ${newBalance} (deducted ${totalCost})`);
} catch (error) {
  console.error('[analyzeFood] Failed to deduct balance:', error);
  // เกิด error ตอนหัก balance
  // แต่เราเรียก Gemini API ไปแล้ว — ต้องจัดการอย่างไร?
  // 
  // Option 1: Return error → User เสีย energy แต่ไม่ได้ผลลัพธ์ (ไม่ดี)
  // Option 2: Return result ไปก่อน → log error ไว้ manual refund (ดีกว่า)
  
  console.error('⚠️ WARNING: Gemini API called but balance deduction failed!');
  console.error('⚠️ Manual intervention may be required for user:', deviceId);
  
  // เราจะ return result ไปก่อน แต่ไม่อัพเดท balance
  // และส่ง balance เดิมกลับไป
  newBalance = serverBalance;
}

// ✅ PHASE 1: ไม่ต้องสร้าง newToken แล้ว
// เดิม: const newToken = generateEnergyToken(token.userId, newBalance, secret);
// Client จะ sync balance จาก response.balance แทน
```

### 1.3.5 แก้ Response ให้ส่ง balance กลับ

**ค้นหา `res.status(200).json({` ในส่วนท้าย:**

```typescript
res.status(200).json({
  success: true,
  analysis: responseContent,
  // ... fields อื่นๆ
  energyToken: newToken,  // ← เดิม: ส่ง token ใหม่
});
```

**แก้เป็น:**

```typescript
res.status(200).json({
  success: true,
  analysis: responseContent,
  // ... fields อื่นๆ เหมือนเดิม
  
  // ✅ PHASE 1: ส่ง balance กลับแทน token
  balance: newBalance,
  energyUsed: totalCost,
  
  // เก็บ energyToken เดิมไว้ก่อน (backward compatibility)
  // จะลบทิ้งใน Phase 3
  energyToken: energyToken,
});
```

**✅ Checkpoint**: บันทึกไฟล์แล้ว compile ดู

```bash
cd functions
npm run build
```

ถ้าไม่มี error → ผ่าน ✅

---

## Step 1.4: Backend - เพิ่ม syncBalance endpoint

### 1.4.1 สร้างไฟล์ใหม่

ไฟล์: `functions/src/syncBalance.ts`

```typescript
/**
 * syncBalance Cloud Function
 * 
 * Purpose: Sync balance between Client and Server
 * Use cases:
 * 1. App startup — Client ดึง balance จาก Server
 * 2. One-time migration — เมื่อ User เก่าใช้ app version ใหม่ครั้งแรก
 * 3. Manual sync — เมื่อ Client สงสัยว่า balance ไม่ตรง
 */

import { onRequest } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';

// Initialize Firebase Admin (ถ้ายังไม่ได้ init ใน analyzeFood.ts)
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

interface SyncBalanceRequest {
  deviceId: string;
  localBalance?: number; // สำหรับ migration (optional)
  type: 'startup' | 'migration' | 'manual';
}

export const syncBalance = onRequest(
  {
    timeoutSeconds: 10,
    memory: '256MiB',
    cors: '*',
  },
  async (req, res) => {
    // Validate request method
    if (req.method !== 'POST') {
      res.status(405).json({ error: 'Method not allowed' });
      return;
    }

    try {
      const body = req.body as SyncBalanceRequest;
      const { deviceId, localBalance, type } = body;

      // Validate required fields
      if (!deviceId) {
        res.status(400).json({ error: 'Missing deviceId' });
        return;
      }

      console.log(`📡 [syncBalance] Request from ${deviceId} (type: ${type})`);

      // ─── Check if user exists in Firestore ───
      const docRef = db.collection('energy_balances').doc(deviceId);
      const doc = await docRef.get();

      if (!doc.exists) {
        // ─── User ไม่มีใน Firestore ───
        
        // Case 1: Migration — เอา localBalance ไปใช้ (one-time)
        if (localBalance !== undefined && localBalance > 0) {
          const migratedBalance = localBalance;
          
          await docRef.set({
            balance: migratedBalance,
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            migratedFrom: 'local_storage',
            migratedAt: admin.firestore.FieldValue.serverTimestamp(),
            welcomeGiftClaimed: true, // ถือว่าได้ welcome gift แล้ว
          });
          
          console.log(`🔄 [syncBalance] Migrated ${deviceId}: ${migratedBalance} from local`);
          
          res.status(200).json({
            success: true,
            balance: migratedBalance,
            action: 'migrated',
          });
          return;
        }
        
        // Case 2: New user — สร้างพร้อม welcome gift
        const welcomeBalance = 100;
        
        await docRef.set({
          balance: welcomeBalance,
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          welcomeGiftClaimed: true,
        });
        
        console.log(`🎁 [syncBalance] New user ${deviceId}: Welcome gift ${welcomeBalance}`);
        
        res.status(200).json({
          success: true,
          balance: welcomeBalance,
          action: 'created_with_welcome_gift',
        });
        return;
      }

      // ─── User มีใน Firestore แล้ว ───
      const serverBalance = doc.data()?.balance ?? 0;
      
      console.log(`✅ [syncBalance] Existing user ${deviceId}: ${serverBalance}`);
      
      res.status(200).json({
        success: true,
        balance: serverBalance,
        action: 'synced',
      });

    } catch (error: any) {
      console.error('❌ [syncBalance] Error:', error);
      res.status(500).json({ 
        error: 'Internal server error',
        message: error.message,
      });
    }
  }
);
```

### 1.4.2 Export ฟังก์ชันใน index.ts

ไฟล์: `functions/src/index.ts`

**เพิ่มบรรทัดนี้:**

```typescript
export { syncBalance } from './syncBalance';
```

**ตำแหน่ง**: ใกล้ๆ กับ export อื่นๆ เช่น

```typescript
export { analyzeFood } from './analyzeFood';
export { syncBalance } from './syncBalance';  // ← เพิ่มบรรทัดนี้
```

### 1.4.3 Deploy Backend

```bash
cd functions

# Build
npm run build

# ถ้าไม่มี error:
cd ..
firebase deploy --only functions
```

**คาดหวังผลลัพธ์:**

```
✔  functions[analyzeFood(us-central1)] Successful update operation.
✔  functions[syncBalance(us-central1)] Successful create operation.

✔  Deploy complete!
```

**✅ Checkpoint**: Functions deploy สำเร็จ

---

## Step 1.5: Client - แก้ EnergyService

### 1.5.1 เพิ่ม FlutterSecureStorage

ไฟล์: `lib/core/services/energy_service.dart`

**ตรวจสอบ imports ด้านบน:**

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
```

**ถ้ายังไม่มี → เพิ่ม**

**เพิ่ม instance variable ใน class:**

```dart
class EnergyService {
  // เดิม
  static const String _keyBalance = 'energy_balance';
  static const String _keyWelcomeGift = 'energy_welcome_gift_claimed';
  static const String _keyTransactions = 'energy_transactions';
  
  // ✅ เพิ่มใหม่
  final _secureStorage = const FlutterSecureStorage();
  
  // ... methods อื่นๆ
}
```

### 1.5.2 แก้ getBalance() — อ่านจาก SecureStorage (cache)

**ค้นหา method `getBalance()`:**

```dart
Future<int> getBalance() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt(_keyBalance) ?? 0;
}
```

**แทนที่ด้วย:**

```dart
/// อ่าน balance จาก local cache
/// ⚠️ PHASE 1: นี่เป็นแค่ cache — Server = Source of Truth
Future<int> getBalance() async {
  // ลองอ่านจาก SecureStorage ก่อน (encrypted)
  try {
    final cached = await _secureStorage.read(key: _keyBalance);
    if (cached != null) {
      return int.tryParse(cached) ?? 0;
    }
  } catch (e) {
    debugPrint('[EnergyService] Error reading from SecureStorage: $e');
  }
  
  // Fallback: อ่านจาก SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final balance = prefs.getInt(_keyBalance) ?? 0;
  
  // Migrate ไป SecureStorage
  if (balance > 0) {
    await _secureStorage.write(key: _keyBalance, value: balance.toString());
  }
  
  return balance;
}
```

### 1.5.3 เพิ่ม updateFromServerResponse()

**เพิ่ม method ใหม่:**

```dart
/// อัพเดท balance จาก Server response
/// ✅ PHASE 1: Server = Source of Truth, Client sync ตามนี้
/// 
/// เรียก method นี้เมื่อ:
/// - ได้ response จาก analyzeFood (หลังใช้ energy)
/// - ได้ response จาก syncBalance (ตอน app startup)
/// - ได้ response จาก verifyPurchase (หลังซื้อ energy)
Future<void> updateFromServerResponse(int newBalance) async {
  try {
    // เก็บใน SecureStorage (encrypted, primary storage)
    await _secureStorage.write(
      key: _keyBalance,
      value: newBalance.toString(),
    );
    
    // เก็บใน SharedPreferences ด้วย (fast read cache)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyBalance, newBalance);
    
    debugPrint('[EnergyService] ✅ Balance updated from server: $newBalance');
    
  } catch (e) {
    debugPrint('[EnergyService] ❌ Error updating balance: $e');
    throw Exception('Failed to update balance');
  }
}
```

### 1.5.4 แก้ _updateBalance() — เรียก updateFromServerResponse

**ค้นหา method `_updateBalance()`:**

```dart
Future<void> _updateBalance(int newBalance) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_keyBalance, newBalance);
}
```

**แทนที่ด้วย:**

```dart
Future<void> _updateBalance(int newBalance) async {
  // ⚠️ PHASE 1: เปลี่ยนให้เรียก updateFromServerResponse แทน
  await updateFromServerResponse(newBalance);
}
```

### 1.5.5 เพิ่ม syncBalanceWithServer()

**เพิ่ม method ใหม่:**

```dart
/// Sync balance กับ Server (เรียกตอน app startup)
/// 
/// Migration strategy:
/// - ถ้ามี balance เดิมใน local → ส่งไปให้ Server (one-time migration)
/// - ถ้า Server มี balance แล้ว → ใช้ค่าจาก Server (server wins)
Future<int> syncBalanceWithServer() async {
  try {
    // อ่าน balance เดิมจาก local (สำหรับ migration)
    final localBalance = await getBalance();
    
    // ดึง deviceId
    final deviceId = await DeviceIdService.getDeviceId();
    
    // เรียก Backend
    final url = 'https://us-central1-miro-d6856.cloudfunctions.net/syncBalance';
    
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'deviceId': deviceId,
        'localBalance': localBalance > 0 ? localBalance : null,
        'type': localBalance > 0 ? 'migration' : 'startup',
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final serverBalance = data['balance'] as int;
      
      debugPrint('[EnergyService] ✅ Synced with server: $serverBalance (${data['action']})');
      
      // อัพเดท local cache
      await updateFromServerResponse(serverBalance);
      
      return serverBalance;
    } else {
      throw Exception('Server returned ${response.statusCode}');
    }
    
  } catch (e) {
    debugPrint('[EnergyService] ❌ Sync failed: $e');
    // Fallback: ใช้ local balance
    return await getBalance();
  }
}
```

### 1.5.6 เพิ่ม import ที่จำเป็น

**ตรวจสอบว่ามี imports นี้ด้านบนไฟล์:**

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'device_id_service.dart';
```

---

## Step 1.6: แก้ Chat Service ให้รับ balance จาก response

ไฟล์: `lib/core/ai/gemini_service.dart` หรือ `lib/features/chat/services/gemini_chat_service.dart`

### 1.6.1 หา code ที่เรียก analyzeFood API

**ค้นหาส่วนที่ parse response:**

```dart
if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
  
  // เดิม: อ่าน energyToken
  final newToken = data['energyToken'];
  // ... อื่นๆ
}
```

### 1.6.2 แก้ให้รับ balance แล้ว sync

**แทนที่ด้วย:**

```dart
if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
  
  // ✅ PHASE 1: รับ balance จาก response แล้ว sync
  if (data['balance'] != null) {
    final newBalance = data['balance'] as int;
    await energyService.updateFromServerResponse(newBalance);
    debugPrint('[GeminiService] ✅ Balance synced: $newBalance');
  }
  
  // เก็บ energyToken ไว้ก่อน (backward compatibility)
  // จะลบใน Phase 3
  
  // ... parse analysis และ return
}
```

---

## Step 1.7: เรียก syncBalance ตอน App Startup

ไฟล์: `lib/main.dart` หรือ `lib/features/home/presentation/home_screen.dart`

### 1.7.1 ใน main.dart (แนะนำ)

**ค้นหา `main()` function:**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ... Firebase init
  
  runApp(MyApp());
}
```

**เพิ่ม sync balance:**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ... Firebase init (เหมือนเดิม)
  
  // ✅ PHASE 1: Sync balance with server ตอน app startup
  try {
    final energyService = EnergyService();
    await energyService.syncBalanceWithServer();
    debugPrint('[Main] ✅ Balance synced with server');
  } catch (e) {
    debugPrint('[Main] ⚠️ Failed to sync balance: $e');
    // ไม่ block app launch
  }
  
  runApp(MyApp());
}
```

### 1.7.2 หรือใน HomeScreen (ทางเลือก)

**ถ้าไม่อยากใน main.dart → ใส่ใน HomeScreen:**

```dart
@override
void initState() {
  super.initState();
  
  // ✅ PHASE 1: Sync balance
  _syncBalance();
}

Future<void> _syncBalance() async {
  try {
    final energyService = EnergyService();
    await energyService.syncBalanceWithServer();
    setState(() {}); // refresh UI
  } catch (e) {
    debugPrint('[HomeScreen] Failed to sync balance: $e');
  }
}
```

---

## Testing

### Test Case 1: New User (ไม่มี balance เดิม)

**Steps:**
1. Uninstall app
2. Install app ใหม่
3. เปิด app
4. ตรวจสอบ balance

**คาดหวัง:**
- ✅ Balance = 100 (welcome gift)
- ✅ Console log: "🎁 New user {deviceId}: Welcome gift 100"
- ✅ Firebase Console → energy_balances collection มี document ใหม่

**Verify ใน Firebase Console:**
```
/energy_balances/{deviceId}
  balance: 100
  welcomeGiftClaimed: true
  createdAt: [timestamp]
  lastUpdated: [timestamp]
```

---

### Test Case 2: Existing User (มี balance เดิม = 50)

**Setup:**
1. ติดตั้ง app version เก่า (ก่อน Phase 1)
2. ใช้จน balance = 50
3. Update เป็น app version ใหม่ (มี Phase 1)

**Steps:**
1. เปิด app
2. ตรวจสอบ balance

**คาดหวัง:**
- ✅ Balance = 50 (migrate จาก local)
- ✅ Console log: "🔄 Migrated {deviceId}: 50 from local"
- ✅ Firebase Console → มี document พร้อม field `migratedFrom: 'local_storage'`

---

### Test Case 3: ใช้ Energy (analyzeFood)

**Setup:**
- User มี balance = 100

**Steps:**
1. ถ่ายรูปอาหาร หรือ Chat (ไม่มีรูป)
2. ส่ง request
3. ตรวจสอบ balance

**คาดหวัง:**
- ✅ Balance = 99 (ไม่มีรูป, cost = 1)
- ✅ หรือ Balance = 98 (มีรูป, cost = 2)
- ✅ Console log Backend: "💰 [Firestore] ... - 1 = 99"
- ✅ Firebase Console → balance ใน Firestore อัพเดทแล้ว

---

### Test Case 4: Insufficient Balance

**Setup:**
- User มี balance = 1
- จะถ่ายรูป (cost = 2)

**Steps:**
1. ถ่ายรูปอาหาร
2. ส่ง request

**คาดหวัง:**
- ❌ Response: 402 Insufficient energy
- ✅ Balance ยังคง = 1 (ไม่ถูกหัก)
- ✅ แสดง popup บอกให้ซื้อ energy

---

### Test Case 5: Client แก้ balance เป็น 9999 (Security Test)

**Steps:**
1. Root เครื่อง Android
2. แก้ `/data/data/{package}/shared_prefs/{file}.xml`:
   ```xml
   <int name="energy_balance" value="9999" />
   ```
3. Force stop app แล้วเปิดใหม่
4. UI อาจจะแสดง balance = 9999 (อ่านจาก local cache)
5. ลองใช้ energy (ถ่ายรูปหรือ chat)

**คาดหวัง:**
- ✅ Backend อ่าน balance จาก Firestore (balance จริง)
- ✅ ถ้า balance จริง < cost → ได้ 402 Insufficient energy
- ✅ หลังจากนั้น client sync balance จาก server → UI แสดง balance จริง
- ✅ **Security fix ทำงาน!**

---

### Test Case 6: Concurrent Requests (Race Condition)

**Setup:**
- User มี balance = 10

**Steps:**
1. ส่ง 2 requests พร้อมกัน (เปิด 2 tabs หรือใช้ script)
   - Request 1: chat (cost = 1)
   - Request 2: chat with image (cost = 2)

**คาดหวัง:**
- ✅ Request 1 สำเร็จ → balance = 9
- ✅ Request 2 สำเร็จ → balance = 7
- ✅ หรือ Request 2 สำเร็จก่อน → balance = 8 → Request 1 → balance = 7
- ✅ **ไม่มี race condition** (เพราะใช้ Firestore Transaction)

---

## Troubleshooting

### ปัญหา: Cloud Function deploy ไม่ได้

```
Error: Failed to deploy function analyzeFood
```

**แก้:**
1. ตรวจสอบ `npm run build` ไม่มี error
2. ตรวจสอบ Firebase quota (Blaze plan เท่านั้น)
3. ดู logs: `firebase functions:log --limit 50`

---

### ปัญหา: "Failed to read server balance"

```
[Firestore] Error reading balance: Permission denied
```

**แก้:**
1. ตรวจสอบ Firestore rules deploy แล้วหรือยัง
2. Cloud Function ต้องมี Firebase Admin SDK initialized
3. ตรวจสอบ IAM permissions

---

### ปัญหา: syncBalance ไม่ทำงาน

```
[EnergyService] Sync failed: SocketException
```

**แก้:**
1. ตรวจสอบ internet connection
2. ตรวจสอบ function URL ถูกต้องหรือไม่
3. ดู logs: `firebase functions:log syncBalance`

---

### ปัญหา: Balance ไม่อัพเดทใน UI

**แก้:**
1. ตรวจสอบว่าเรียก `updateFromServerResponse()` แล้วหรือยัง
2. ตรวจสอบว่า UI listen StateNotifier/Provider หรือไม่
3. ลอง force refresh: `setState(() {})`

---

## Checklist Phase 1

- [ ] Step 1.1: Setup Firestore ✅
  - [ ] Firestore rules deployed
  - [ ] Firebase Admin SDK installed
- [ ] Step 1.2: Backend Helpers ✅
  - [ ] getServerBalance() เพิ่มแล้ว
  - [ ] deductServerBalance() เพิ่มแล้ว
  - [ ] addServerBalance() เพิ่มแล้ว
- [ ] Step 1.3: analyzeFood แก้แล้ว ✅
  - [ ] อ่าน balance จาก Firestore
  - [ ] หัก balance ใน Firestore
  - [ ] Response ส่ง balance กลับ
- [ ] Step 1.4: syncBalance endpoint ✅
  - [ ] syncBalance.ts สร้างแล้ว
  - [ ] Export ใน index.ts แล้ว
  - [ ] Deploy สำเร็จ
- [ ] Step 1.5: Client EnergyService แก้แล้ว ✅
  - [ ] FlutterSecureStorage เพิ่มแล้ว
  - [ ] updateFromServerResponse() เพิ่มแล้ว
  - [ ] syncBalanceWithServer() เพิ่มแล้ว
- [ ] Step 1.6: GeminiService แก้แล้ว ✅
  - [ ] รับ balance จาก response
  - [ ] เรียก updateFromServerResponse()
- [ ] Step 1.7: App startup sync ✅
  - [ ] เรียก syncBalanceWithServer() ใน main()
- [ ] Testing ✅
  - [ ] Test Case 1: New user → welcome gift
  - [ ] Test Case 2: Migration → balance migrate
  - [ ] Test Case 3: ใช้ energy → balance หัก
  - [ ] Test Case 4: Insufficient balance → error
  - [ ] Test Case 5: Client แก้ balance → ไม่มีผล
  - [ ] Test Case 6: Concurrent requests → ไม่ race

---

## Next Step

**✅ Phase 1 เสร็จแล้ว!**

ตอนนี้:
- ✅ Backend เป็น Source of Truth แล้ว
- ✅ Client แก้ balance ไม่มีผลแล้ว
- ✅ Token forgery ใช้ไม่ได้แล้ว

**🔜 Next: Phase 2 — Purchase Verification**

อ่านไฟล์: `02_PHASE2_PURCHASE.md`

---

*Phase 1 Completed ✅*  
*Version: 1.0*
