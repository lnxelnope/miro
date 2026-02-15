# Phase 2: Purchase Verification (Server-side)

> **🔴 Priority: CRITICAL**  
> **⏱️ Estimated Time: 1-2 วัน**  
> **🎯 Goal: Verify purchases กับ Google Play API, ป้องกันการซื้อปลอม**

---

## 📋 สารบัญ

- [Step 2.1: Setup Google Play Developer API](#step-21-setup-google-play-developer-api)
- [Step 2.2: Backend - สร้าง verifyPurchase function](#step-22-backend---สร้าง-verifypurchase-function)
- [Step 2.3: Client - แก้ PurchaseService](#step-23-client---แก้-purchaseservice)
- [Step 2.4: Testing](#step-24-testing)

---

## เป้าหมายของ Phase นี้

### ❌ ปัญหาปัจจุบัน

```
User กด "ซื้อ Energy 550"
   ↓
Google Play: ชำระเงินสำเร็จ → purchaseToken
   ↓
Client: เพิ่ม balance += 550 ตรงๆ ใน SharedPreferences
   ↓
ไม่มี Server verification!
```

**ผลลัพธ์**:
- ปลอม purchase event ด้วย Frida/Xposed → ได้ energy ฟรี
- ใช้ purchase token ซ้ำหลายครั้ง → ได้ energy ไม่จำกัด
- ใช้ license testing account → ซื้อฟรี → ได้ energy จริง

### ✅ หลังแก้

```
User กด "ซื้อ Energy 550"
   ↓
Google Play: ชำระเงินสำเร็จ → purchaseToken
   ↓
Client: ส่ง purchaseToken ไป Backend
   ↓
Backend:
   1. ตรวจสอบ purchase_records → เช็คว่าใช้ token นี้แล้วหรือยัง
   2. เรียก Google Play Developer API → verify จริงๆ
   3. เช็ค purchaseState === 0 (purchased)
   4. เพิ่ม balance ใน Firestore (atomic)
   5. บันทึก token hash ใน purchase_records → ป้องกันใช้ซ้ำ
   ↓
Client: รับ newBalance จาก response → sync
```

---

## Step 2.1: Setup Google Play Developer API

> **✅ ขั้นตอนนี้ทำเสร็จแล้ว!**  
> **Senior ได้ setup ให้เรียบร้อยแล้ว - Junior ข้ามไปทำ Step 2.2 ได้เลย**

---

### ✅ สิ่งที่ Setup เสร็จแล้ว

#### 1. Service Account
- **Email**: `play-store-manager@miro-d6856.iam.gserviceaccount.com`
- **Project**: `miro-d6856`
- **Status**: ✅ Created

#### 2. Google Play Developer API
- **Status**: ✅ Enabled
- **Service Account Access**: ✅ Added to Play Console
- **Permissions**: 
  - ✅ View financial data
  - ✅ Manage orders and subscriptions

#### 3. Firebase Secret
- **Secret Name**: `GOOGLE_SERVICE_ACCOUNT_JSON`
- **Status**: ✅ Set (version 1)
- **Contains**: Service Account JSON key

**ตรวจสอบ Secret:**
```bash
firebase functions:secrets:access GOOGLE_SERVICE_ACCOUNT_JSON
# ควรเห็น JSON content ที่มี client_email: "play-store-manager@miro-d6856.iam.gserviceaccount.com"
```

#### 4. JSON Key File
- **Location**: เก็บไว้ปลอดภัยแล้ว (Dropbox)
- **Filename**: `miro-d6856-556f596f7196.json`
- **⚠️ สำคัญ**: ไม่ commit เข้า Git

---

### 📌 ข้อมูลที่ใช้ใน Phase นี้

```javascript
// ใช้ใน verifyPurchase.ts
const GOOGLE_SERVICE_ACCOUNT = defineSecret('GOOGLE_SERVICE_ACCOUNT_JSON');
// ✅ Secret name ตรงกับที่ set ไว้แล้ว

// Service Account Email (สำหรับ reference)
// play-store-manager@miro-d6856.iam.gserviceaccount.com
```

---

### 🚀 Junior เริ่มต้นจากตรงนี้

**ข้าม Step 2.1 ทั้งหมด → เริ่มที่ Step 2.2 เลย**

เพราะ:
- ✅ Service Account สร้างแล้ว
- ✅ Permissions set แล้ว
- ✅ Firebase Secret มีแล้ว
- ✅ ไม่ต้องทำอะไรเพิ่ม

---

### 2.1.6 ตรวจสอบ Package Name

**ใน Flutter project:**

ไฟล์: `android/app/build.gradle`

ค้นหา:
```gradle
android {
    namespace "com.yourapp.miro"  // ← package name
    ...
}
```

**หรือ:**
```gradle
android {
    defaultConfig {
        applicationId "com.yourapp.miro"  // ← package name
    }
}
```

**จดไว้**: เช่น `com.yourapp.miro` (จะใช้ใน Step 2.2)

---

## Step 2.2: Backend - สร้าง verifyPurchase function

### 2.2.1 Install googleapis package

```bash
cd functions
npm install googleapis
```

**ตรวจสอบ `package.json`:**

```json
{
  "dependencies": {
    "firebase-admin": "^13.6.0",
    "firebase-functions": "^7.0.0",
    "googleapis": "^126.0.0"
  }
}
```

---

### 2.2.2 สร้างไฟล์ใหม่

ไฟล์: `functions/src/verifyPurchase.ts`

```typescript
/**
 * verifyPurchase Cloud Function
 * 
 * Purpose: Server-side verification of in-app purchases
 * 
 * Flow:
 * 1. รับ purchaseToken จาก Client
 * 2. เช็ค duplicate purchase (token เคยใช้แล้วหรือยัง)
 * 3. Verify กับ Google Play Developer API
 * 4. เช็คสถานะ purchase (purchased/canceled/pending)
 * 5. Acknowledge purchase (required by Google Play)
 * 6. เพิ่ม balance ใน Firestore (atomic)
 * 7. บันทึก purchase record (ป้องกันใช้ซ้ำ)
 */

import { onRequest } from 'firebase-functions/v2/https';
import { defineSecret } from 'firebase-functions/params';
import * as admin from 'firebase-admin';
import { google } from 'googleapis';
import * as crypto from 'crypto';

// Initialize Firebase Admin
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

// Secret from Firebase
const GOOGLE_SERVICE_ACCOUNT = defineSecret('GOOGLE_SERVICE_ACCOUNT_JSON');

// ─── Product ID → Energy Amount Mapping ───
// ⚠️ ต้องตรงกับที่กำหนดใน Client!
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

// ✅ Package name ของ MIRO app
const PACKAGE_NAME = 'com.miro.app'; // ← ตรวจสอบใน android/app/build.gradle

interface VerifyPurchaseRequest {
  purchaseToken: string;
  productId: string;
  deviceId: string;
}

export const verifyPurchase = onRequest(
  {
    secrets: [GOOGLE_SERVICE_ACCOUNT],
    timeoutSeconds: 30,
    memory: '512MiB',
    cors: '*',
  },
  async (req, res) => {
    // ─── Validate Request ───
    if (req.method !== 'POST') {
      res.status(405).json({ error: 'Method not allowed' });
      return;
    }

    try {
      const body = req.body as VerifyPurchaseRequest;
      const { purchaseToken, productId, deviceId } = body;

      // Validate required fields
      if (!purchaseToken || !productId || !deviceId) {
        res.status(400).json({
          error: 'Missing required fields',
          required: ['purchaseToken', 'productId', 'deviceId'],
        });
        return;
      }

      console.log(`🛒 [verifyPurchase] Request: ${productId} for ${deviceId}`);

      // ─── 1. Check if product is valid ───
      const energyAmount = ENERGY_PRODUCTS[productId];
      if (!energyAmount) {
        console.log(`❌ [verifyPurchase] Invalid product: ${productId}`);
        res.status(400).json({
          error: 'Invalid product ID',
          productId,
        });
        return;
      }

      // ─── 2. Check duplicate purchase ───
      const purchaseHash = hashPurchaseToken(purchaseToken);
      const purchaseRecordRef = db
        .collection('purchase_records')
        .doc(purchaseHash);
      const existingPurchase = await purchaseRecordRef.get();

      if (existingPurchase.exists) {
        console.log(`⚠️ [verifyPurchase] Duplicate purchase: ${purchaseHash}`);
        
        // ดึง balance ปัจจุบันส่งกลับ (ไม่เพิ่ม energy ซ้ำ)
        const balanceDoc = await db
          .collection('energy_balances')
          .doc(deviceId)
          .get();
        const currentBalance = balanceDoc.data()?.balance ?? 0;

        res.status(409).json({
          error: 'Purchase already verified',
          balance: currentBalance,
          verified: true,
        });
        return;
      }

      // ─── 3. Verify with Google Play Developer API ───
      console.log(`🔍 [verifyPurchase] Verifying with Google Play API...`);

      const serviceAccount = JSON.parse(GOOGLE_SERVICE_ACCOUNT.value());
      const auth = new google.auth.GoogleAuth({
        credentials: serviceAccount,
        scopes: ['https://www.googleapis.com/auth/androidpublisher'],
      });

      const androidPublisher = google.androidpublisher({
        version: 'v3',
        auth,
      });

      // ⚠️ สำหรับ consumable products (ใช้แล้วหมด)
      // ถ้าเป็น subscription ต้องใช้ androidPublisher.purchases.subscriptions.get()
      const purchaseResponse = await androidPublisher.purchases.products.get({
        packageName: PACKAGE_NAME,
        productId,
        token: purchaseToken,
      });

      const purchase = purchaseResponse.data;
      console.log(`📦 [verifyPurchase] Google Play response:`, {
        orderId: purchase.orderId,
        purchaseState: purchase.purchaseState,
        acknowledgementState: purchase.acknowledgementState,
      });

      // ─── 4. Check purchase state ───
      // purchaseState: 0 = purchased, 1 = canceled, 2 = pending
      if (purchase.purchaseState !== 0) {
        console.log(`❌ [verifyPurchase] Purchase not completed: state=${purchase.purchaseState}`);
        res.status(403).json({
          error: 'Purchase not completed',
          purchaseState: purchase.purchaseState,
        });
        return;
      }

      // ─── 5. Acknowledge purchase (required by Google Play) ───
      // acknowledgementState: 0 = not acknowledged, 1 = acknowledged
      if (purchase.acknowledgementState === 0) {
        console.log(`✅ [verifyPurchase] Acknowledging purchase...`);
        
        await androidPublisher.purchases.products.acknowledge({
          packageName: PACKAGE_NAME,
          productId,
          token: purchaseToken,
        });
      }

      // ─── 6. Add energy to Firestore (atomic transaction) ───
      console.log(`💎 [verifyPurchase] Adding ${energyAmount} energy...`);

      const balanceRef = db.collection('energy_balances').doc(deviceId);
      const newBalance = await db.runTransaction(async (transaction) => {
        const doc = await transaction.get(balanceRef);
        const currentBalance = doc.exists ? (doc.data()?.balance ?? 0) : 0;
        const updated = currentBalance + energyAmount;

        if (doc.exists) {
          transaction.update(balanceRef, {
            balance: updated,
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          });
        } else {
          transaction.set(balanceRef, {
            balance: updated,
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
          });
        }

        return updated;
      });

      // ─── 7. Record purchase (prevent duplicates) ───
      await purchaseRecordRef.set({
        deviceId,
        productId,
        energyAmount,
        // เก็บ token แค่ส่วนหน้า (security: don't store full token)
        purchaseTokenPreview: purchaseToken.substring(0, 20) + '...',
        verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
        orderId: purchase.orderId,
        purchaseTimeMillis: purchase.purchaseTimeMillis,
        status: 'verified',
      });

      console.log(`✅ [verifyPurchase] Success: ${productId} (+${energyAmount}) → ${newBalance}`);

      // ─── Response ───
      res.status(200).json({
        success: true,
        balance: newBalance,
        energyAdded: energyAmount,
        productId,
      });

    } catch (error: any) {
      console.error('❌ [verifyPurchase] Error:', error);

      // ถ้า error จาก Google Play API
      if (error.code === 400 || error.code === 401 || error.code === 404) {
        res.status(403).json({
          error: 'Invalid purchase token',
          details: error.message,
        });
        return;
      }

      res.status(500).json({
        error: 'Internal server error',
        message: error.message,
      });
    }
  }
);

/**
 * Hash purchase token (SHA-256) สำหรับเก็บใน Firestore
 * ไม่เก็บ token เต็มๆ เพื่อความปลอดภัย
 */
function hashPurchaseToken(token: string): string {
  return crypto.createHash('sha256').update(token).digest('hex');
}
```

---

### 2.2.3 แก้ PACKAGE_NAME

**ในไฟล์ `verifyPurchase.ts` บรรทัดที่ ~45:**

```typescript
// ⚠️ แก้เป็น package name จริงของแอป
const PACKAGE_NAME = 'com.yourapp.miro';
```

**แก้เป็น package name จริง** ที่ดูจาก `android/app/build.gradle`

เช่น: `com.miro.app` หรือ `com.example.miro`

---

### 2.2.4 Export ฟังก์ชันใน index.ts

ไฟล์: `functions/src/index.ts`

**เพิ่ม:**

```typescript
export { analyzeFood } from './analyzeFood';
export { syncBalance } from './syncBalance';
export { verifyPurchase } from './verifyPurchase';  // ← เพิ่มบรรทัดนี้
```

---

### 2.2.5 Deploy Backend

```bash
cd functions

# Build
npm run build
```

**ตรวจสอบไม่มี error ✅**

```bash
# Deploy
cd ..
firebase deploy --only functions:verifyPurchase
```

**คาดหวังผลลัพธ์:**

```
✔  functions[verifyPurchase(us-central1)] Successful create operation.
Function URL: https://us-central1-miro-xxxxx.cloudfunctions.net/verifyPurchase

✔  Deploy complete!
```

**จด URL ไว้** → จะใช้ใน Client

---

## Step 2.3: Client - แก้ PurchaseService

ไฟล์: `lib/core/services/purchase_service.dart`

### 2.3.1 เพิ่ม imports

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'device_id_service.dart';
```

### 2.3.2 เพิ่ม constant

**ด้านบนของ class:**

```dart
class PurchaseService {
  // เดิม
  static const String _kDebugMode = ...;
  
  // ✅ เพิ่มใหม่
  static const String _verifyPurchaseUrl =
      'https://us-central1-miro-d6856.cloudfunctions.net/verifyPurchase';
  // ⚠️ แก้ URL ให้ตรงกับ project จริง
  
  // ... methods อื่นๆ
}
```

---

### 2.3.3 หา method _handleEnergyPurchase

**ค้นหา:**

```dart
Future<void> _handleEnergyPurchase(PurchaseDetails purchase, String productId) async {
  switch (purchase.status) {
    case PurchaseStatus.purchased:
      // เดิม: เพิ่ม energy ตรงๆ
      await _energyService!.addEnergy(
        energyAmount,
        type: 'purchase',
        purchaseToken: purchase.verificationData.serverVerificationData,
      );
      break;
    // ...
  }
}
```

---

### 2.3.4 แทนที่ด้วย code ใหม่

```dart
Future<void> _handleEnergyPurchase(PurchaseDetails purchase, String productId) async {
  switch (purchase.status) {
    case PurchaseStatus.pending:
      debugPrint('[PurchaseService] ⏳ Purchase pending: $productId');
      // แสดง loading หรือ pending state
      break;

    case PurchaseStatus.purchased:
      debugPrint('[PurchaseService] ✅ Purchase successful: $productId');
      
      // ✅ PHASE 2: Verify กับ Server ก่อน
      final verified = await _verifyPurchaseWithServer(
        purchaseToken: purchase.verificationData.serverVerificationData,
        productId: productId,
      );

      if (verified != null && verified['success'] == true) {
        // Server verify สำเร็จ
        final newBalance = verified['balance'] as int;
        final energyAdded = verified['energyAdded'] as int;

        // Sync balance จาก server
        await _energyService!.updateFromServerResponse(newBalance);

        debugPrint('[PurchaseService] 💎 Server-verified: +$energyAdded → Balance: $newBalance');

        // Complete purchase (tell Google Play we're done)
        await _inAppPurchase.completePurchase(purchase);

        // แสดง success message
        // เช่น: showSuccessDialog() หรือ setState()
        
      } else {
        // Server verify ไม่ได้ (error, duplicate, หรือ network issue)
        debugPrint('[PurchaseService] ⚠️ Server verification failed');
        
        // Save pending purchase สำหรับ retry ทีหลัง
        await _savePendingPurchase(purchase, productId);
        
        // แสดง error message
        // เช่น: "กรุณารอสักครู่ ระบบกำลังตรวจสอบการซื้อของคุณ"
      }
      break;

    case PurchaseStatus.error:
      debugPrint('[PurchaseService] ❌ Purchase error: ${purchase.error}');
      // แสดง error message
      break;

    case PurchaseStatus.canceled:
      debugPrint('[PurchaseService] 🚫 Purchase canceled');
      // ไม่ต้องทำอะไร
      break;

    case PurchaseStatus.restored:
      // สำหรับ non-consumable products (subscription, etc.)
      // Energy เป็น consumable → ไม่ต้อง restore
      debugPrint('[PurchaseService] 🔄 Purchase restored: $productId');
      break;
  }
}
```

---

### 2.3.5 เพิ่ม method _verifyPurchaseWithServer

**เพิ่ม method ใหม่:**

```dart
/// Verify purchase กับ Backend
/// 
/// Returns:
/// - Map ถ้า verify สำเร็จ: { success: true, balance: xxx, energyAdded: xxx }
/// - null ถ้า verify ไม่สำเร็จ (error, duplicate, network issue)
Future<Map<String, dynamic>?> _verifyPurchaseWithServer({
  required String purchaseToken,
  required String productId,
}) async {
  try {
    final deviceId = await DeviceIdService.getDeviceId();

    debugPrint('[PurchaseService] 🔍 Verifying with server...');
    debugPrint('[PurchaseService] Product: $productId');
    debugPrint('[PurchaseService] DeviceId: $deviceId');

    final response = await http.post(
      Uri.parse(_verifyPurchaseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'purchaseToken': purchaseToken,
        'productId': productId,
        'deviceId': deviceId,
      }),
    ).timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        debugPrint('[PurchaseService] ⏱️ Verification timeout');
        throw Exception('Verification timeout');
      },
    );

    debugPrint('[PurchaseService] Server response: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } else if (response.statusCode == 409) {
      // Duplicate purchase
      debugPrint('[PurchaseService] ⚠️ Duplicate purchase (already verified)');
      
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['verified'] == true && data['balance'] != null) {
        // Token เคยใช้แล้ว แต่เราจะ sync balance ให้
        await _energyService!.updateFromServerResponse(data['balance']);
      }
      
      return null; // ไม่ให้ถือว่า success (เพราะไม่ได้เพิ่ม energy)
    } else {
      // Other errors
      final errorBody = response.body;
      debugPrint('[PurchaseService] ❌ Server error: $errorBody');
      return null;
    }

  } catch (e) {
    debugPrint('[PurchaseService] ❌ Verification error: $e');
    return null;
  }
}
```

---

### 2.3.6 เพิ่ม method _savePendingPurchase (optional)

**สำหรับกรณีที่ server verify ไม่ได้ (offline, timeout):**

```dart
/// บันทึก pending purchase สำหรับ retry ทีหลัง
Future<void> _savePendingPurchase(
  PurchaseDetails purchase,
  String productId,
) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final pendingKey = 'pending_purchase_${purchase.purchaseID}';

    await prefs.setString(
      pendingKey,
      jsonEncode({
        'purchaseToken': purchase.verificationData.serverVerificationData,
        'productId': productId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }),
    );

    debugPrint('[PurchaseService] 💾 Saved pending purchase: $productId');
  } catch (e) {
    debugPrint('[PurchaseService] ❌ Failed to save pending purchase: $e');
  }
}

/// Retry pending purchases (เรียกตอน app startup)
Future<void> retryPendingPurchases() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('pending_purchase_'));

    if (keys.isEmpty) return;

    debugPrint('[PurchaseService] 🔄 Retrying ${keys.length} pending purchases...');

    for (final key in keys) {
      final json = prefs.getString(key);
      if (json == null) continue;

      final data = jsonDecode(json) as Map<String, dynamic>;
      final purchaseToken = data['purchaseToken'] as String;
      final productId = data['productId'] as String;

      // Retry verification
      final verified = await _verifyPurchaseWithServer(
        purchaseToken: purchaseToken,
        productId: productId,
      );

      if (verified != null && verified['success'] == true) {
        // Success — remove from pending
        await prefs.remove(key);
        await _energyService!.updateFromServerResponse(verified['balance']);
        debugPrint('[PurchaseService] ✅ Retry success: $productId');
      }
    }
  } catch (e) {
    debugPrint('[PurchaseService] ❌ Retry error: $e');
  }
}
```

---

### 2.3.7 เรียก retryPendingPurchases ตอน app startup

ไฟล์: `lib/main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ... Firebase init
  
  // Phase 1: Sync balance
  final energyService = EnergyService();
  await energyService.syncBalanceWithServer();
  
  // ✅ Phase 2: Retry pending purchases
  final purchaseService = PurchaseService();
  await purchaseService.initialize(energyService);
  await purchaseService.retryPendingPurchases();
  
  runApp(MyApp());
}
```

---

## Step 2.4: Testing

### Test Case 1: ซื้อ Energy ปกติ (Real Purchase)

**Setup:**
- ใช้ real credit card หรือ Google Play balance
- ซื้อ `energy_550` (550 energy)

**Steps:**
1. เปิด app
2. ไปหน้า Purchase
3. กดซื้อ "550 Energy"
4. ชำระเงิน (จริง)
5. รอ verification

**คาดหวัง:**
- ✅ Google Play: ชำระเงินสำเร็จ
- ✅ Backend logs: "🛒 [verifyPurchase] Request: energy_550 for {deviceId}"
- ✅ Backend logs: "✅ [verifyPurchase] Success: energy_550 (+550) → {newBalance}"
- ✅ Firebase Console → `purchase_records` มี document ใหม่
- ✅ Firebase Console → `energy_balances/{deviceId}` balance เพิ่มขึ้น 550
- ✅ Client UI: Balance อัพเดท
- ✅ แสดง success message

---

### Test Case 2: Duplicate Purchase (ใช้ token ซ้ำ)

**Setup:**
- มี purchase token ที่ verify แล้ว

**Steps:**
1. ส่ง request ด้วย purchase token เดิมอีกครั้ง (ใช้ Postman/curl)

```bash
curl -X POST https://us-central1-miro-xxxxx.cloudfunctions.net/verifyPurchase \
  -H "Content-Type: application/json" \
  -d '{
    "purchaseToken": "...",
    "productId": "energy_550",
    "deviceId": "test-device"
  }'
```

**คาดหวัง:**
- ✅ Response: 409 Conflict
- ✅ `{ error: "Purchase already verified", balance: xxx, verified: true }`
- ✅ Balance ไม่เพิ่ม
- ✅ Backend logs: "⚠️ [verifyPurchase] Duplicate purchase"

---

### Test Case 3: Invalid Purchase Token

**Steps:**
1. ส่ง request ด้วย purchase token ปลอม

```bash
curl -X POST ... \
  -d '{ "purchaseToken": "fake-token-123", ... }'
```

**คาดหวัง:**
- ✅ Response: 403 Forbidden
- ✅ `{ error: "Invalid purchase token" }`
- ✅ Balance ไม่เปลี่ยน

---

### Test Case 4: Canceled Purchase

**Setup:**
- ซื้อแล้ว refund ทันที (ใน Google Play Console)

**Steps:**
1. ซื้อ energy
2. Refund ทันที
3. ส่ง request verify

**คาดหวัง:**
- ✅ Response: 403 Forbidden
- ✅ `{ error: "Purchase not completed", purchaseState: 1 }`
- ✅ Backend logs: "❌ [verifyPurchase] Purchase not completed: state=1"
- ✅ Balance ไม่เปลี่ยน

---

### Test Case 5: License Testing Account (Free Purchase)

**Setup:**
- เพิ่ม license tester email ใน Google Play Console
- Login ด้วย email นั้น

**Steps:**
1. ซื้อ energy (จะไม่มีการ charge เงิน)
2. ตรวจสอบว่า backend verify

**คาดหวัง:**
- ✅ Google Play: ชำระเงินสำเร็จ (ฟรี, สำหรับ testing)
- ✅ Backend verify สำเร็จ
- ✅ Balance เพิ่มขึ้น
- ⚠️ **Note**: นี่เป็น valid use case สำหรับ testing — ไม่ใช่ exploit

---

### Test Case 6: Network Timeout

**Setup:**
- ปิด internet ขณะ verify

**Steps:**
1. ซื้อ energy
2. ระหว่าง verify → ปิด internet
3. เปิด internet กลับมา
4. รอ app retry

**คาดหวัง:**
- ✅ Client: timeout error
- ✅ Purchase บันทึกใน pending_purchases
- ✅ ตอน app startup ครั้งหน้า → retry
- ✅ Retry สำเร็จ → balance อัพเดท

---

### Test Case 7: Verify Firestore Structure

**เข้า Firebase Console:**

```
/energy_balances/{deviceId}
  balance: 650
  lastUpdated: [timestamp]

/purchase_records/{purchaseToken_hash}
  deviceId: "abc123"
  productId: "energy_550"
  energyAmount: 550
  purchaseTokenPreview: "AEuhp4iXFJRZDTsxp..."
  verifiedAt: [timestamp]
  orderId: "GPA.1234-5678-9012-34567"
  purchaseTimeMillis: 1707988800000
  status: "verified"
```

**ตรวจสอบ:**
- ✅ มี document ใน `purchase_records`
- ✅ purchaseToken ไม่เก็บเต็มๆ (เก็บแค่ preview)
- ✅ มี orderId จาก Google Play
- ✅ status === "verified"

---

## Troubleshooting

### ปัญหา: Google Play API Error 401 Unauthorized

```
Error: The caller does not have permission
```

**แก้:**
1. ตรวจสอบ Service Account email ถูกเพิ่มใน Play Console แล้วหรือยัง
2. ตรวจสอบสิทธิ์: "View financial data" + "Manage orders"
3. รอ ~10 นาที หลังเพิ่ม Service Account (Google อาจใช้เวลา propagate)

---

### ปัญหา: Google Play API Error 404 Not Found

```
Error: Purchase not found
```

**สาเหตุที่เป็นไปได้:**
1. **Package name ผิด** → ตรวจสอบ `PACKAGE_NAME` ใน `verifyPurchase.ts`
2. **Product ID ผิด** → ตรวจสอบว่า product มีอยู่จริงใน Play Console
3. **Purchase token หมดอายุ** → token เก่าไม่สามารถ verify ได้
4. **Testing account ไม่ตรง** → ใช้ email ที่เพิ่มใน license testers

---

### ปัญหา: Secret ไม่ทำงาน

```
Error: Cannot read property 'value' of undefined
```

**แก้:**
1. ตรวจสอบ secret set แล้วหรือยัง: `firebase functions:secrets:access GOOGLE_SERVICE_ACCOUNT_JSON`
2. Deploy ด้วย flag `--force`: `firebase deploy --only functions:verifyPurchase --force`
3. ตรวจสอบ IAM permissions ของ Cloud Functions service account

---

### ปัญหา: Purchase ไม่ acknowledged

**Google Play จะ auto-refund หลัง 3 วัน ถ้าไม่ acknowledge!**

**แก้:**
ตรวจสอบว่า code นี้ทำงาน:

```typescript
if (purchase.acknowledgementState === 0) {
  await androidPublisher.purchases.products.acknowledge({
    packageName: PACKAGE_NAME,
    productId,
    token: purchaseToken,
  });
}
```

---

### ปัญหา: Client ไม่ได้รับ balance

**Debug:**
1. ตรวจสอบ Backend logs: `firebase functions:log verifyPurchase --limit 20`
2. ตรวจสอบ response status: 200? 403? 409?
3. ตรวจสอบว่า `updateFromServerResponse()` ถูกเรียกหรือไม่
4. ตรวจสอบ UI refresh: `setState()` หรือ Provider notify

---

## Checklist Phase 2

- [ ] Step 2.1: Setup Google Play API ✅
  - [ ] Service Account สร้างแล้ว
  - [ ] JSON key download แล้ว
  - [ ] Google Play Developer API enabled
  - [ ] Service Account เพิ่มใน Play Console แล้ว
  - [ ] Firebase Secret set แล้ว
  - [ ] Package name ตรวจสอบแล้ว
- [ ] Step 2.2: Backend verifyPurchase ✅
  - [ ] googleapis install แล้ว
  - [ ] verifyPurchase.ts สร้างแล้ว
  - [ ] PACKAGE_NAME แก้ถูกต้องแล้ว
  - [ ] Export ใน index.ts แล้ว
  - [ ] Deploy สำเร็จ
- [ ] Step 2.3: Client PurchaseService ✅
  - [ ] _verifyPurchaseUrl แก้แล้ว
  - [ ] _handleEnergyPurchase แก้แล้ว
  - [ ] _verifyPurchaseWithServer เพิ่มแล้ว
  - [ ] _savePendingPurchase เพิ่มแล้ว (optional)
  - [ ] retryPendingPurchases เพิ่มแล้ว (optional)
  - [ ] เรียกใน main.dart แล้ว
- [ ] Testing ✅
  - [ ] Test Case 1: Real purchase → สำเร็จ
  - [ ] Test Case 2: Duplicate → error 409
  - [ ] Test Case 3: Invalid token → error 403
  - [ ] Test Case 4: Canceled → error 403
  - [ ] Test Case 5: License testing → สำเร็จ
  - [ ] Test Case 6: Network timeout → retry ทำงาน
  - [ ] Test Case 7: Firestore structure ถูกต้อง

---

## Next Step

**✅ Phase 2 เสร็จแล้ว!**

ตอนนี้:
- ✅ Purchase verify กับ Google Play API แล้ว
- ✅ Duplicate purchase ป้องกันแล้ว
- ✅ ซื้อปลอมไม่ได้แล้ว

**Combined with Phase 1:**
- ✅ Balance อยู่บน Server (Firestore)
- ✅ Purchase verify ก่อนเพิ่ม balance
- ✅ **Security ระดับ Production Ready แล้ว 🎉**

**🔜 Next: Phase 3 — Encryption & Token Cleanup**

อ่านไฟล์: `03_PHASE3_ENCRYPTION.md`

---

*Phase 2 Completed ✅*  
*Version: 1.0*
