# MIRO Energy Security Upgrade Plan

> เอกสารนี้อธิบายช่องโหว่ด้านความปลอดภัยของระบบ Energy ปัจจุบัน  
> พร้อมแผนการแก้ไขแบบ step-by-step สำหรับ Senior Review  
> **วันที่:** 15 Feb 2026

---

## สารบัญ

1. [สถาปัตยกรรมปัจจุบัน (Current Architecture)](#1-สถาปัตยกรรมปัจจุบัน)
2. [ช่องโหว่ที่พบ (Vulnerabilities)](#2-ช่องโหว่ที่พบ)
3. [สถาปัตยกรรมใหม่ (Proposed Architecture)](#3-สถาปัตยกรรมใหม่)
4. [Implementation Plan](#4-implementation-plan)
5. [Migration Strategy](#5-migration-strategy)
6. [Risk Assessment](#6-risk-assessment)

---

## 1. สถาปัตยกรรมปัจจุบัน

### Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│  CLIENT (Flutter App)                                       │
│                                                             │
│  SharedPreferences ──► energy_balance = 95  ◄── ไม่เข้ารหัส │
│         │                                                   │
│  EnergyTokenService                                         │
│    - HMAC Secret ฝังใน APK (hardcoded)                      │
│    - สร้าง Token: {userId, BALANCE, timestamp, signature}   │
│         │                                                   │
│         ▼                                                   │
│  HTTP POST + Token ──────────────────────────────────────── │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│  BACKEND (Firebase Cloud Function)                          │
│                                                             │
│  1. รับ Token จาก Client                                    │
│  2. Verify HMAC Signature ✓                                 │
│  3. อ่าน balance จาก Token ◄── เชื่อ Client!                │
│  4. เรียก Gemini API                                        │
│  5. หัก balance ใน Token                                    │
│  6. สร้าง Token ใหม่ส่งกลับ                                 │
│                                                             │
│  ⚠️ ไม่มี Database เก็บ balance ฝั่ง Server                  │
│  ⚠️ ไม่มี Purchase Verification                             │
└─────────────────────────────────────────────────────────────┘
```

### ไฟล์ที่เกี่ยวข้อง

| ไฟล์ | หน้าที่ | ปัญหา |
|------|--------|-------|
| `lib/core/services/energy_service.dart` | จัดการ balance, welcome gift, transactions | เก็บ balance ใน SharedPreferences (ไม่เข้ารหัส) |
| `lib/core/services/energy_token_service.dart` | สร้าง HMAC Token ส่ง Backend | **Secret ฝังใน APK** (hardcoded) |
| `lib/core/services/purchase_service.dart` | จัดการ In-App Purchase | **ไม่ verify กับ Google Play API** |
| `lib/core/services/device_id_service.dart` | สร้าง Device ID | ใช้ ANDROID_ID / IDFV (spoof ได้บน root) |
| `functions/src/analyzeFood.ts` | Backend API | **เชื่อ balance จาก Client Token** |

---

## 2. ช่องโหว่ที่พบ

### 2.1 CRITICAL: Balance เก็บใน SharedPreferences แบบไม่เข้ารหัส

```dart
// energy_service.dart (line 10, 30, 91)
static const String _keyBalance = 'energy_balance';

Future<int> getBalance() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt(_keyBalance) ?? 0;  // ◄── อ่านตรงๆ
}

Future<void> _updateBalance(int newBalance) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_keyBalance, newBalance);  // ◄── เขียนตรงๆ
}
```

**วิธีโจมตี:** Root เครื่อง → เปิด SharedPreferences XML → แก้ `energy_balance` เป็น 999999  
**ความยาก:** ง่ายมาก (< 5 นาที)  
**ผลกระทบ:** ได้ Energy ไม่จำกัดโดยไม่ต้องซื้อ

---

### 2.2 CRITICAL: HMAC Secret ฝังใน Client Code

```dart
// energy_token_service.dart (line 10-11)
static const String _encryptionSecret = 
    'a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2';
```

**วิธีโจมตี:** Decompile APK → ค้นหา string → ได้ secret → สร้าง Token ปลอมด้วย balance เท่าไหร่ก็ได้  
**ความยาก:** ปานกลาง (ใช้ jadx หรือ apktool, 30 นาที)  
**ผลกระทบ:** เรียก API ได้ไม่จำกัดโดยไม่ต้องมี Energy จริง

---

### 2.3 CRITICAL: Backend เชื่อ Balance จาก Client

```typescript
// analyzeFood.ts (line 379-389)
const token = verifyEnergyToken(energyToken, secret);

if (!token || token.balance < 1) {   // ◄── balance มาจาก Client!
  res.status(402).json({ error: 'Insufficient energy' });
}
```

Backend ตรวจแค่ว่า HMAC ถูกต้อง แต่ **balance ใน Token มาจาก Client** ทั้งหมด  
ไม่มี Firestore/Database ฝั่ง Server ที่เก็บ balance จริง

---

### 2.4 CRITICAL: ไม่มี Server-side Purchase Verification

```dart
// purchase_service.dart (line 196-204)
case PurchaseStatus.purchased:
  // เพิ่ม Energy ทันทีเลย!
  await _energyService!.addEnergy(
    energyAmount,                    // ◄── เพิ่ม balance ฝั่ง Client ตรงๆ
    type: 'purchase',
    purchaseToken: purchase.verificationData.serverVerificationData,
    // ◄── purchaseToken เก็บไว้แต่ไม่เคยส่งไป verify กับ Google Play API
  );
```

**วิธีโจมตี:**  
1. ปลอม purchase event ด้วย Xposed/Frida  
2. Replay purchase token เดิมซ้ำ  
3. ใช้ license testing account (ซื้อฟรี)  
**ผลกระทบ:** ซื้อ Energy โดยไม่ต้องจ่ายเงินจริง

---

### 2.5 MEDIUM: Token Replay ภายใน 5 นาที

```typescript
// analyzeFood.ts (line 51-56)
const now = Date.now();
if (now - decoded.timestamp > 5 * 60 * 1000) {
  return null;  // ◄── Expiry เวลา 5 นาทีเท่านั้น
}
```

Token ใช้ซ้ำได้ภายใน 5 นาที เพราะไม่มี nonce tracking ฝั่ง Server

---

### สรุปสถานะความปลอดภัย

| ส่วน | ระดับ | ความเสี่ยง |
|------|------|-----------|
| Balance Storage | ❌ None | CRITICAL |
| HMAC Secret | ❌ Hardcoded in APK | CRITICAL |
| Backend Trust | ⚠️ Trusts client balance | CRITICAL |
| Purchase Verify | ❌ None | CRITICAL |
| Token Replay | ⚠️ 5-min window | MEDIUM |
| Device ID | ⚠️ Spoofable on root | MEDIUM |

---

## 3. สถาปัตยกรรมใหม่

### New Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│  CLIENT (Flutter App)                                       │
│                                                             │
│  FlutterSecureStorage ──► energy_balance (encrypted cache)  │
│         │                                                   │
│  Token: {deviceId, timestamp, signature}                    │
│    - ไม่มี balance ใน Token อีกต่อไป                         │
│    - Secret ยังคงใช้ HMAC แต่เป็น "app auth" เท่านั้น       │
│         │                                                   │
│  Purchase Flow:                                             │
│    - ซื้อจาก Play Store                                     │
│    - ส่ง purchaseToken ไป Backend verify                    │
│    - Backend verify กับ Google Play API                     │
│    - Backend เพิ่ม balance ใน Firestore                     │
│    - Client sync balance จาก response                      │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│  BACKEND (Firebase Cloud Function)                          │
│                                                             │
│  1. รับ Token จาก Client (มีแค่ deviceId + timestamp)       │
│  2. Verify HMAC (app authentication)                        │
│  3. ✅ อ่าน balance จาก FIRESTORE (Server = Source of Truth) │
│  4. เรียก Gemini API                                        │
│  5. ✅ หัก balance ใน FIRESTORE                              │
│  6. ส่ง newBalance กลับให้ Client sync                       │
│                                                             │
│  NEW: verifyPurchase endpoint                               │
│    - รับ purchaseToken จาก Client                           │
│    - ✅ Verify กับ Google Play Developer API                 │
│    - ✅ เช็ค duplicate (ไม่ให้ใช้ token ซ้ำ)                 │
│    - ✅ เพิ่ม balance ใน Firestore                           │
│                                                             │
│  Firestore:                                                 │
│    energy_balances/{deviceId}                               │
│      ├── balance: 95                                        │
│      ├── lastUpdated: Timestamp                             │
│      └── welcomeGiftClaimed: true                           │
│                                                             │
│    purchase_records/{purchaseToken_hash}                     │
│      ├── deviceId: "abc123"                                 │
│      ├── productId: "energy_550"                            │
│      ├── amount: 550                                        │
│      ├── verifiedAt: Timestamp                              │
│      └── status: "verified"                                 │
└─────────────────────────────────────────────────────────────┘
```

### สิ่งที่เปลี่ยน

| เรื่อง | เดิม | ใหม่ |
|--------|-----|------|
| Balance Storage (Server) | ❌ ไม่มี | ✅ Firestore |
| Balance Storage (Client) | SharedPreferences | FlutterSecureStorage (cache only) |
| Token มี balance | ✅ ใช่ (Client กำหนด) | ❌ ไม่มี (Server อ่านจาก Firestore) |
| Purchase Verification | ❌ Client-side only | ✅ Server verify กับ Google Play API |
| Duplicate Purchase | ❌ ไม่เช็ค | ✅ เช็คจาก purchase_records collection |
| HMAC Secret | Hardcoded ใน APK | ยังคง hardcode แต่ใช้เป็นแค่ app auth (**ไม่ใช่ balance proof**) |

---

## 4. Implementation Plan

### Phase 1: Firestore Balance (Server = Source of Truth)

**Priority: CRITICAL — ต้องทำก่อน**  
**Estimated effort: 1-2 วัน**

#### 4.1.1 Backend: เพิ่ม Firestore ใน analyzeFood.ts

```typescript
// functions/src/analyzeFood.ts

import * as admin from 'firebase-admin';

// Initialize Firestore
admin.initializeApp();
const db = admin.firestore();

// ─── Helper: อ่าน balance จาก Firestore ───
async function getServerBalance(deviceId: string): Promise<number> {
  const docRef = db.collection('energy_balances').doc(deviceId);
  const doc = await docRef.get();
  
  if (!doc.exists) {
    // New user — create with welcome gift
    const welcomeBalance = 100;
    await docRef.set({
      balance: welcomeBalance,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      welcomeGiftClaimed: true,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log(`🎁 New user ${deviceId}: Welcome gift ${welcomeBalance}`);
    return welcomeBalance;
  }
  
  return doc.data()?.balance ?? 0;
}

// ─── Helper: หัก balance ใน Firestore (atomic) ───
async function deductServerBalance(
  deviceId: string, 
  amount: number
): Promise<number> {
  const docRef = db.collection('energy_balances').doc(deviceId);
  
  // ใช้ Transaction เพื่อป้องกัน race condition
  return db.runTransaction(async (transaction) => {
    const doc = await transaction.get(docRef);
    const currentBalance = doc.data()?.balance ?? 0;
    
    // ห้าม balance ติดลบ
    const actualDeduction = Math.min(amount, currentBalance);
    const newBalance = currentBalance - actualDeduction;
    
    transaction.update(docRef, {
      balance: newBalance,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
    });
    
    return newBalance;
  });
}
```

#### 4.1.2 Backend: แก้ analyzeFood handler

```typescript
// แก้ section 4.1 ใน analyzeFood handler

// เดิม: อ่าน balance จาก token (CLIENT กำหนด)
if (!token || token.balance < 1) { ... }

// ใหม่: อ่าน balance จาก FIRESTORE (SERVER กำหนด)
const serverBalance = await getServerBalance(token.userId);
if (serverBalance < baseCost) {
  res.status(402).json({ 
    error: 'Insufficient energy', 
    balance: serverBalance,
    required: baseCost
  });
  return;
}

// ... เรียก Gemini API ...

// เดิม: หัก balance จาก token
const newBalance = token.balance - totalCost;

// ใหม่: หัก balance ใน Firestore (atomic transaction)
const newBalance = await deductServerBalance(token.userId, totalCost);
```

#### 4.1.3 Client: Sync balance จาก Server response

```dart
// energy_service.dart

/// อัพเดท Energy จาก Backend response
/// Server เป็น source of truth — Client เป็นแค่ cache
Future<void> updateFromServerResponse(int newBalance) async {
  // เก็บใน FlutterSecureStorage (encrypted)
  await _secureStorage.write(
    key: _keyBalance, 
    value: newBalance.toString(),
  );
  
  // เก็บใน SharedPreferences ด้วย (สำหรับ fast read)
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_keyBalance, newBalance);
}
```

#### 4.1.4 Client: เพิ่ม sync balance endpoint

```dart
// เพิ่มใน gemini_chat_service.dart หรือสร้าง energy_api_service.dart ใหม่

/// Sync balance จาก Server (เรียกตอน app startup)
static Future<int> syncBalance({
  required EnergyService energyService,
}) async {
  final deviceId = await DeviceIdService.getDeviceId();
  final energyToken = await energyService.generateEnergyToken();
  
  final response = await http.post(
    Uri.parse('$_functionUrl/syncBalance'),  // endpoint ใหม่
    headers: {
      'Content-Type': 'application/json',
      'x-energy-token': energyToken,
      'x-device-id': deviceId,
    },
    body: jsonEncode({'type': 'sync', 'deviceId': deviceId}),
  );
  
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['balance'] as int;
  }
  
  throw Exception('Failed to sync balance');
}
```

---

### Phase 2: Purchase Verification (Server-side)

**Priority: CRITICAL**  
**Estimated effort: 1-2 วัน**

#### 4.2.1 Backend: เพิ่ม verifyPurchase function

```typescript
// functions/src/verifyPurchase.ts (ไฟล์ใหม่)

import { onRequest } from 'firebase-functions/v2/https';
import { defineSecret } from 'firebase-functions/params';
import * as admin from 'firebase-admin';
import { google } from 'googleapis';

const GOOGLE_SERVICE_ACCOUNT = defineSecret('GOOGLE_SERVICE_ACCOUNT_JSON');

// Product ID → Energy amount mapping (ต้องตรงกับ Client)
const ENERGY_PRODUCTS: Record<string, number> = {
  'energy_100': 100,
  'energy_550': 550,
  'energy_1200': 1200,
  'energy_2000': 2000,
  'energy_100_welcome': 100,
  'energy_550_welcome': 550,
  'energy_1200_welcome': 1200,
  'energy_2000_welcome': 2000,
};

export const verifyPurchase = onRequest(
  {
    secrets: [GOOGLE_SERVICE_ACCOUNT],
    timeoutSeconds: 30,
    memory: '256MiB',
    cors: '*',
  },
  async (req, res) => {
    try {
      const { purchaseToken, productId, deviceId } = req.body;
      
      if (!purchaseToken || !productId || !deviceId) {
        res.status(400).json({ error: 'Missing required fields' });
        return;
      }
      
      const energyAmount = ENERGY_PRODUCTS[productId];
      if (!energyAmount) {
        res.status(400).json({ error: 'Invalid product ID' });
        return;
      }
      
      // ─── 1. Check duplicate purchase ───
      const db = admin.firestore();
      const purchaseHash = hashPurchaseToken(purchaseToken);
      const existingPurchase = await db
        .collection('purchase_records')
        .doc(purchaseHash)
        .get();
      
      if (existingPurchase.exists) {
        res.status(409).json({ 
          error: 'Purchase already verified',
          balance: (await db.collection('energy_balances').doc(deviceId).get())
            .data()?.balance ?? 0,
        });
        return;
      }
      
      // ─── 2. Verify with Google Play Developer API ───
      const serviceAccount = JSON.parse(GOOGLE_SERVICE_ACCOUNT.value());
      const auth = new google.auth.GoogleAuth({
        credentials: serviceAccount,
        scopes: ['https://www.googleapis.com/auth/androidpublisher'],
      });
      
      const androidPublisher = google.androidpublisher({
        version: 'v3',
        auth,
      });
      
      const packageName = 'com.yourapp.miro'; // ← แก้เป็น package name จริง
      
      // สำหรับ consumable products
      const purchaseResponse = await androidPublisher.purchases.products.get({
        packageName,
        productId,
        token: purchaseToken,
      });
      
      const purchase = purchaseResponse.data;
      
      // ตรวจสอบสถานะ
      // purchaseState: 0 = purchased, 1 = canceled, 2 = pending
      if (purchase.purchaseState !== 0) {
        res.status(403).json({ error: 'Purchase not completed' });
        return;
      }
      
      // ─── 3. Acknowledge purchase (required!) ───
      if (purchase.acknowledgementState === 0) {
        await androidPublisher.purchases.products.acknowledge({
          packageName,
          productId,
          token: purchaseToken,
        });
      }
      
      // ─── 4. Add energy to Firestore (atomic) ───
      const balanceRef = db.collection('energy_balances').doc(deviceId);
      const newBalance = await db.runTransaction(async (transaction) => {
        const doc = await transaction.get(balanceRef);
        const currentBalance = doc.data()?.balance ?? 0;
        const updated = currentBalance + energyAmount;
        
        transaction.set(balanceRef, {
          balance: updated,
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });
        
        return updated;
      });
      
      // ─── 5. Record purchase (prevent duplicates) ───
      await db.collection('purchase_records').doc(purchaseHash).set({
        deviceId,
        productId,
        energyAmount,
        purchaseToken: purchaseToken.substring(0, 20) + '...',  // เก็บแค่ส่วนหน้า
        verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
        orderId: purchase.orderId,
        purchaseTime: purchase.purchaseTimeMillis,
        status: 'verified',
      });
      
      console.log(`✅ Purchase verified: ${productId} (+${energyAmount}) for ${deviceId}`);
      
      res.status(200).json({
        success: true,
        balance: newBalance,
        energyAdded: energyAmount,
      });
      
    } catch (error: any) {
      console.error('❌ Purchase verification error:', error);
      res.status(500).json({ error: error.message });
    }
  }
);

function hashPurchaseToken(token: string): string {
  const crypto = require('crypto');
  return crypto.createHash('sha256').update(token).digest('hex');
}
```

#### 4.2.2 Client: แก้ purchase_service.dart

```dart
// purchase_service.dart — แก้ _handleEnergyPurchase

case PurchaseStatus.purchased:
  // เดิม: เพิ่ม Energy ตรงๆ ฝั่ง Client
  // await _energyService!.addEnergy(energyAmount, ...);
  
  // ใหม่: ส่ง purchaseToken ไป Backend verify ก่อน
  final verified = await _verifyPurchaseWithServer(
    purchaseToken: purchase.verificationData.serverVerificationData,
    productId: productId,
  );
  
  if (verified != null) {
    // Backend verify สำเร็จ — sync balance จาก server response
    await _energyService!.updateFromServerResponse(verified['balance']);
    debugPrint('[PurchaseService] ✅ Server-verified: +${verified['energyAdded']}');
  } else {
    // Fallback: ถ้า server verify ไม่ได้ (offline?) — เก็บไว้ retry ทีหลัง
    await _savePendingPurchase(purchase);
    debugPrint('[PurchaseService] ⚠️ Server offline, saved for retry');
  }
  break;

// ─── New method: Verify with server ───
static Future<Map<String, dynamic>?> _verifyPurchaseWithServer({
  required String purchaseToken,
  required String productId,
}) async {
  try {
    final deviceId = await DeviceIdService.getDeviceId();
    
    final response = await http.post(
      Uri.parse('https://us-central1-miro-d6856.cloudfunctions.net/verifyPurchase'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'purchaseToken': purchaseToken,
        'productId': productId,
        'deviceId': deviceId,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    
    return null;
  } catch (e) {
    debugPrint('[PurchaseService] ❌ Server verify error: $e');
    return null;
  }
}
```

---

### Phase 3: Remove Secret from Client / Encrypt Local Storage

**Priority: HIGH (but less urgent if Phase 1 is done)**  
**Estimated effort: 0.5-1 วัน**

#### 4.3.1 เปลี่ยน Token Format

```dart
// energy_token_service.dart — เปลี่ยน Token ให้ไม่มี balance

// เดิม: Token มี balance (Client กำหนด)
static Future<String> generateToken(int balance) async {
  final token = {
    'userId': userId,
    'balance': balance,      // ◄── ปัญหา: Client กำหนด balance เอง
    'timestamp': timestamp,
    'signature': signature,
  };
}

// ใหม่: Token มีแค่ identity (Server อ่าน balance จาก Firestore เอง)
static Future<String> generateToken() async {
  final userId = await DeviceIdService.getDeviceId();
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final payload = '$userId:$timestamp';  // ◄── ไม่มี balance แล้ว
  final signature = _generateSignature(payload);
  
  final token = {
    'userId': userId,
    'timestamp': timestamp,
    'signature': signature,
    // ไม่มี balance อีกต่อไป — Server อ่านจาก Firestore
  };
  
  return base64Encode(utf8.encode(json.encode(token)));
}
```

> **หมายเหตุ:** HMAC Secret ยังคงอยู่ใน APK  
> ถ้า Phase 1 ทำเสร็จแล้ว ค่า secret นี้ใช้แค่ "พิสูจน์ว่า request มาจากแอปของเรา"  
> ไม่สามารถใช้เพื่อปลอม balance ได้อีก เพราะ **Server อ่าน balance จาก Firestore เท่านั้น**  
>  
> ถ้าต้องการ security สูงขึ้นอีก → ใช้ Firebase App Check แทน HMAC

#### 4.3.2 ย้าย Balance Cache ไป FlutterSecureStorage

```dart
// energy_service.dart

// เดิม:
Future<int> getBalance() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt(_keyBalance) ?? 0;  // ◄── ไม่เข้ารหัส
}

// ใหม่:
Future<int> getBalance() async {
  // อ่านจาก FlutterSecureStorage (encrypted, Keychain on iOS)
  final cached = await _storage.read(key: _keyBalance);
  if (cached != null) {
    return int.tryParse(cached) ?? 0;
  }
  
  // Fallback: sync จาก Server
  return 0;
}

Future<void> _updateBalance(int newBalance) async {
  // เก็บใน FlutterSecureStorage (encrypted)
  await _storage.write(key: _keyBalance, value: newBalance.toString());
  
  // SharedPreferences ใช้เป็น fast-read cache เท่านั้น
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(_keyBalance, newBalance);
}
```

---

### Phase 4: (Optional) Firebase App Check

**Priority: NICE-TO-HAVE**  
**Estimated effort: 0.5 วัน**

แทนที่ HMAC Secret ด้วย [Firebase App Check](https://firebase.google.com/docs/app-check):

- ใช้ Play Integrity API (Android) / DeviceCheck (iOS)
- พิสูจน์ว่า request มาจากแอปจริงๆ (ไม่ใช่ script/bot)
- Google จัดการ key ให้ — ไม่ต้อง hardcode secret

```dart
// Client: เพิ่ม Firebase App Check
await FirebaseAppCheck.instance.activate(
  androidProvider: AndroidProvider.playIntegrity,
  appleProvider: AppleProvider.deviceCheck,
);
```

```typescript
// Backend: ตรวจ App Check token
import { getAppCheck } from 'firebase-admin/app-check';

const appCheckToken = req.headers['x-firebase-appcheck'] as string;
const appCheckClaims = await getAppCheck().verifyToken(appCheckToken);
```

---

## 5. Migration Strategy

### สำหรับ Existing Users (มี balance ใน SharedPreferences แล้ว)

```
App Startup Flow (หลัง upgrade):

1. อ่าน balance เดิมจาก SharedPreferences
2. เรียก Backend: POST /syncBalance { deviceId, localBalance }
3. Backend:
   - ถ้า Firestore ยังไม่มี document → สร้างใหม่ด้วย localBalance
   - ถ้า Firestore มีแล้ว → ใช้ค่าจาก Firestore (server wins)
4. Client sync balance จาก response
```

```typescript
// Backend: syncBalance handler
async function handleSyncBalance(deviceId: string, localBalance: number) {
  const docRef = db.collection('energy_balances').doc(deviceId);
  const doc = await docRef.get();
  
  if (!doc.exists) {
    // First time after upgrade — trust local balance (one-time migration)
    await docRef.set({
      balance: localBalance,
      lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      migratedAt: admin.firestore.FieldValue.serverTimestamp(),
      migratedFrom: 'local_storage',
    });
    return localBalance;
  }
  
  // Document exists — server is source of truth
  return doc.data()?.balance ?? 0;
}
```

### Backwards Compatibility

- **Token format:** Backend ยังรับ Token เดิม (มี balance) ได้ แต่ **ไม่ใช้ balance จาก Token** → อ่านจาก Firestore แทน
- **Client เก่า:** ถ้า Client ยังไม่ upgrade → Token ยังมี balance → Backend ignore มัน → ทำงานได้ปกติ
- **Gradual rollout:** Deploy Backend ก่อน → ค่อย update Client → ไม่ break

---

## 6. Risk Assessment

### Before Fix (ปัจจุบัน)

| Attack Vector | Difficulty | Impact | Risk |
|--------------|-----------|--------|------|
| SharedPreferences modification | ง่ายมาก | Energy ไม่จำกัด | 🔴 CRITICAL |
| APK decompile + token forgery | ปานกลาง | Energy ไม่จำกัด | 🔴 CRITICAL |
| Purchase replay | ง่าย | ซื้อซ้ำไม่จ่ายเงิน | 🔴 CRITICAL |
| Token replay (5 min) | ง่าย | ใช้ซ้ำหลายครั้ง | 🟡 MEDIUM |

### After Fix (หลังทำ Phase 1-3)

| Attack Vector | Difficulty | Impact | Risk |
|--------------|-----------|--------|------|
| SharedPreferences modification | ง่าย | ❌ ไม่มีผล (Server อ่าน Firestore) | ✅ FIXED |
| APK decompile + token forgery | ปานกลาง | ❌ ไม่มีผล (Token ไม่มี balance) | ✅ FIXED |
| Purchase replay | ง่าย | ❌ ไม่มีผล (Server verify + dedup) | ✅ FIXED |
| Token replay (5 min) | ง่าย | ⚠️ เรียก API ซ้ำ (แต่หัก balance จริง) | 🟢 LOW |
| Direct Firestore manipulation | ยากมาก | ⚠️ ต้อง hack Firebase | 🟢 LOW |

---

## Appendix: Setup Requirements

### Google Play Developer API

1. สร้าง Service Account ใน Google Cloud Console
2. เปิด Google Play Developer API
3. ใน Google Play Console → Settings → API Access → เพิ่ม Service Account
4. ให้สิทธิ์ "View financial data" และ "Manage orders"
5. Save JSON key → เก็บเป็น Firebase Secret:
   ```bash
   firebase functions:secrets:set GOOGLE_SERVICE_ACCOUNT_JSON
   ```

### Firestore Rules

```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Energy balances — only Cloud Functions can read/write
    match /energy_balances/{deviceId} {
      allow read, write: if false;  // Client ห้ามเข้าถึงตรง
    }
    
    // Purchase records — only Cloud Functions can read/write
    match /purchase_records/{purchaseHash} {
      allow read, write: if false;
    }
  }
}
```

### Dependencies

```yaml
# pubspec.yaml (ไม่ต้องเพิ่มอะไร — ใช้ flutter_secure_storage ที่มีอยู่แล้ว)
```

```json
// functions/package.json — เพิ่ม googleapis
{
  "dependencies": {
    "firebase-admin": "^13.6.0",
    "firebase-functions": "^7.0.0",
    "googleapis": "^126.0.0"  // ← เพิ่มสำหรับ Google Play API
  }
}
```

---

## สรุป Priority

| Phase | สิ่งที่ทำ | Priority | Effort | ป้องกันอะไร |
|-------|---------|----------|--------|------------|
| **1** | Firestore Balance | 🔴 CRITICAL | 1-2 วัน | Client แก้ balance, Token forgery |
| **2** | Purchase Verification | 🔴 CRITICAL | 1-2 วัน | ซื้อปลอม, Replay purchase |
| **3** | Remove Secret / Encrypt Cache | 🟡 HIGH | 0.5-1 วัน | Decompile APK, Root access |
| **4** | Firebase App Check | 🟢 NICE-TO-HAVE | 0.5 วัน | Bot/Script attacks |

**ทำ Phase 1 + 2 ก่อน = ปิดช่องโหว่ Critical ทั้งหมด**
