# 🚀 MIRO Energy System — Implementation Guide for Junior Developers
## Backend Proxy Architecture (Option B)

> **สำหรับ Junior Developer:** คู่มือนี้ออกแบบมาให้คุณทำตามได้ทีละขั้นตอนโดยไม่ต้องคิดเอง  
> Copy code ได้เลย แล้วปรับแต่งตาม TODO ที่ระบุไว้

---

## 📋 Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Backend API Implementation](#backend-api-implementation)
3. [Flutter App Implementation](#flutter-app-implementation)
4. [Testing Checklist](#testing-checklist)
5. [Deployment Checklist](#deployment-checklist)

---

## 🏗️ Architecture Overview

### Current Flow (BYOK — ลบทิ้ง)
```
User Device → User's API Key → Google Gemini API
```

### New Flow (Backend Proxy — ใช้อันนี้)
```
User Device 
    ↓ (HTTP POST + Energy token)
Our Backend Server (Firebase Cloud Functions / Google Cloud Functions)
    ├─ Validate request signature
    ├─ Check energy balance (from header)
    ├─ Forward to Google Gemini API (with OUR key)
    ├─ Return result + new balance
    └─ Log transaction
```

### ทำไมต้องใช้ Backend?
- ✅ **Security:** API key ไม่มีในแอป แกะไม่ได้
- ✅ **Control:** ตรวจสอบ usage ได้แบบ real-time
- ✅ **Scalability:** เพิ่ม rate limiting, caching ได้
- ✅ **Analytics:** เก็บสถิติการใช้งานได้

---

## 🔧 Backend API Implementation

### เลือก Backend Platform (เลือก 1 อัน)

| Platform | ราคา | Complexity | แนะนำ |
|----------|------|------------|-------|
| **Firebase Cloud Functions** | Free tier ดี (2M calls/month) | ⭐⭐ (ง่าย) | ✅ **แนะนำ** — integrate กับ Firebase Analytics/Auth/Firestore ที่ใช้อยู่แล้ว |
| **Google Cloud Functions** | Pay-as-you-go | ⭐⭐⭐ (ปานกลาง) | ⚠️ คล้าย Firebase แต่ต้อง setup เอง |
| **Vercel Serverless** | Free tier ดี | ⭐⭐ (ง่าย) | ⚠️ เหมาะถ้าคุ้นเคย Next.js |

> **Junior: ใช้ Firebase Cloud Functions ตามคู่มือนี้ — integrate กับโปรเจกต์ที่มีอยู่แล้ว**

---

## 📦 Step 1: Setup Firebase Project

### 1.1 ตรวจสอบ Firebase Project ที่มีอยู่
```bash
# คุณมี Firebase project อยู่แล้ว (ใช้กับ Firebase Analytics)
# ไปที่ https://console.firebase.google.com
# เลือกโปรเจกต์ MIRO ที่มีอยู่
```

### 1.2 Install Firebase CLI
```bash
# Windows (PowerShell)
npm install -g firebase-tools

# macOS / Linux
npm install -g firebase-tools

# Login
firebase login
```

### 1.3 Initialize Firebase Functions
```bash
cd c:/aiprogram/miro
firebase init functions

# เลือก:
# ✓ Use an existing project → เลือก MIRO project
# ✓ Language: TypeScript
# ✓ Use ESLint: Yes
# ✓ Install dependencies: Yes
```

---

## 🔑 Step 2: Setup Environment Variables

### 2.1 สร้าง Secret สำหรับ API Key
```bash
# ตั้งค่า Gemini API Key (ใช้ Firebase Secrets)
firebase functions:secrets:set GEMINI_API_KEY

# ระบบจะขอให้ใส่ค่า:
# Enter value for GEMINI_API_KEY: [สร้างใหม่จาก Google AI Studio]

# ตั้งค่า Energy Encryption Secret
firebase functions:secrets:set ENERGY_ENCRYPTION_SECRET

# ใส่ค่า random 64 characters (generate ด้วย: openssl rand -hex 32)
```

> **Important:** อย่า commit secrets ขึ้น git!  
> Firebase Secrets จะเก็บไว้บน Google Cloud อย่างปลอดภัย

### 2.2 ตรวจสอบ Secrets
```bash
# ดูรายการ secrets ที่ตั้งไว้
firebase functions:secrets:access GEMINI_API_KEY

# ลบ secret (ถ้าต้องการ)
# firebase functions:secrets:destroy GEMINI_API_KEY
```

---

## 🌐 Step 3: Create Backend API Endpoints

### 3.1 สร้างไฟล์ Cloud Function

> **Junior: Copy ไฟล์นี้ทั้งหมด**

สร้างไฟล์ `functions/src/analyzeFood.ts`:

```typescript
// functions/src/analyzeFood.ts

import * as functions from 'firebase-functions';
import * as crypto from 'crypto';

// ───────────────────────────────────────────────────────────
// 1. CONSTANTS & CONFIG
// ───────────────────────────────────────────────────────────

const GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";

// CORS Headers
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "Content-Type, x-energy-token, x-device-id",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

// ───────────────────────────────────────────────────────────
// 2. ENERGY TOKEN VALIDATION
// ───────────────────────────────────────────────────────────

interface EnergyToken {
  userId: string;      // Device ID or User ID
  balance: number;     // Current energy balance
  timestamp: number;   // Token creation time
  signature: string;   // HMAC signature
}

function verifyEnergyToken(token: string, secret: string): EnergyToken | null {
  try {
    const decoded = JSON.parse(
      Buffer.from(token, 'base64').toString('utf-8')
    ) as EnergyToken;
    
    // ตรวจสอบว่า token ไม่เก่าเกิน 5 นาที (ป้องกัน replay attack)
    const now = Date.now();
    if (now - decoded.timestamp > 5 * 60 * 1000) {
      console.log('Token expired');
      return null;
    }
    
    // ตรวจสอบ signature
    const payload = `${decoded.userId}:${decoded.balance}:${decoded.timestamp}`;
    const expectedSignature = generateSignature(payload, secret);
    
    if (decoded.signature !== expectedSignature) {
      console.log('Invalid signature');
      return null;
    }
    
    return decoded;
  } catch (error) {
    console.error('Token verification error:', error);
    return null;
  }
}

// ───────────────────────────────────────────────────────────
// 3. GEMINI API CALL
// ───────────────────────────────────────────────────────────

interface GeminiRequest {
  type: "image" | "text" | "barcode";
  prompt: string;
  imageBase64?: string;  // Optional: สำหรับ type=image
}

async function callGeminiAPI(request: GeminiRequest, apiKey: string): Promise<any> {
  const parts: any[] = [{ text: request.prompt }];
  
  if (request.imageBase64 && request.type === "image") {
    parts.push({
      inline_data: {
        mime_type: "image/jpeg",
        data: request.imageBase64,
      },
    });
  }
  
  const fetch = (await import('node-fetch')).default;
  const response = await fetch(`${GEMINI_API_URL}?key=${apiKey}`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      contents: [{ parts }],
      generationConfig: {
        temperature: 0.4,
        topK: 32,
        topP: 1,
        maxOutputTokens: 1024,
      },
    }),
  });
  
  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Gemini API error: ${error}`);
  }
  
  return response.json();
}

// ───────────────────────────────────────────────────────────
// 4. MAIN HANDLER (Firebase Cloud Function)
// ───────────────────────────────────────────────────────────

export const analyzeFood = functions
  .runWith({
    secrets: ['GEMINI_API_KEY', 'ENERGY_ENCRYPTION_SECRET'],
    timeoutSeconds: 60,
    memory: '512MB',
  })
  .https.onRequest(async (req, res) => {
    // Handle CORS preflight
    res.set(corsHeaders);
    
    if (req.method === "OPTIONS") {
      res.status(204).send("");
      return;
    }
    
    try {
      // ────── 4.1. Validate Energy Token ──────
      const energyToken = req.headers['x-energy-token'] as string;
      if (!energyToken) {
        res.status(401).json({ error: "Missing energy token" });
        return;
      }
      
      const secret = process.env.ENERGY_ENCRYPTION_SECRET!;
      const token = verifyEnergyToken(energyToken, secret);
      
      if (!token || token.balance < 1) {
        res.status(402).json({ 
          error: "Insufficient energy", 
          balance: token?.balance || 0 
        });
        return;
      }
      
      // ────── 4.2. Parse Request ──────
      const geminiRequest: GeminiRequest = req.body;
      
      // ────── 4.3. Call Gemini API ──────
      const apiKey = process.env.GEMINI_API_KEY!;
      const geminiResponse = await callGeminiAPI(geminiRequest, apiKey);
      
      // ────── 4.4. Deduct Energy & Generate New Token ──────
      const newBalance = token.balance - 1;
      const newTimestamp = Date.now();
      const newPayload = `${token.userId}:${newBalance}:${newTimestamp}`;
      const newSignature = generateSignature(newPayload, secret);
      
      const newToken: EnergyToken = {
        userId: token.userId,
        balance: newBalance,
        timestamp: newTimestamp,
        signature: newSignature,
      };
      
      const newTokenString = Buffer.from(JSON.stringify(newToken)).toString('base64');
      
      // ────── 4.5. Return Response ──────
      res.status(200)
        .set('X-Energy-Balance', newBalance.toString())
        .json({
          success: true,
          data: geminiResponse,
          newEnergyToken: newTokenString,
          newBalance,
        });
      
    } catch (error: any) {
      console.error("Error:", error);
      res.status(500).json({ 
        error: error.message || "Internal server error" 
      });
    }
  });
```


---

## 📱 Step 4: Flutter App Implementation

### 4.1 Add Dependencies

เปิด `pubspec.yaml` แล้วเพิ่ม:

```yaml
dependencies:
  # ... existing dependencies ...
  device_info_plus: ^10.1.0       # Device ID
  crypto: ^3.0.3                   # HMAC signature
  http: ^1.2.0                     # HTTP client (ถ้ายังไม่มี)
```

จากนั้นรัน:
```bash
flutter pub get
```

---

### 4.2 Create Beta Testers Configuration

#### 📁 `lib/core/config/beta_testers.dart`

> **Junior: สร้างไฟล์นี้และเพิ่ม email addresses ของ beta testers ทั้งหมด**

```dart
/// Configuration สำหรับระบุ Beta Testers
/// Beta testers จะได้รับ 1,000 Energy ฟรีเมื่อ migrate
class BetaTesters {
  /// รายชื่อ email ของ beta testers ทั้งหมด
  /// 
  /// TODO: เพิ่ม email addresses ของ beta testers ตรงนี้
  /// ดูรายชื่อได้จาก: Google Play Console → Testing → Testers
  static const List<String> emails = [
    // ตัวอย่าง:
    // 'john.doe@gmail.com',
    // 'beta.tester@example.com',
    // 'tester123@hotmail.com',
    
    // TODO: เพิ่มรายชื่อจริงตรงนี้
  ];
  
  /// ตรวจสอบว่า email นี้เป็น beta tester หรือไม่
  /// 
  /// Returns: true ถ้าเป็น beta tester, false ถ้าไม่ใช่
  static bool isBetaTester(String? email) {
    if (email == null || email.isEmpty) return false;
    
    // Case-insensitive comparison (อีเมลไม่สนใจตัวพิมพ์ใหญ่/เล็ก)
    final normalizedEmail = email.trim().toLowerCase();
    return emails.any((testerEmail) => 
      testerEmail.toLowerCase() == normalizedEmail
    );
  }
  
  /// สำหรับ debug: ดูว่าตัวเองเป็น beta tester หรือไม่
  static void printStatus(String? userEmail) {
    if (isBetaTester(userEmail)) {
      print('🌟 Beta Tester detected: $userEmail');
    } else {
      print('👤 Regular User: $userEmail');
    }
  }
  
  /// ดึงจำนวน beta testers ทั้งหมด
  static int get totalCount => emails.length;
}
```

> **⚠️ Security Note:** ไฟล์นี้ commit ขึ้น git ได้ (email เป็น public info อยู่แล้ว)  
> แต่ถ้าต้องการความเป็นส่วนตัวมากขึ้น → ย้ายไปเก็บใน Firebase Remote Config

---

### 4.3 Create Energy Service Files

#### 📁 `lib/core/services/device_id_service.dart`

> **Junior: Copy ทั้งหมด**

```dart
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service สำหรับจัดการ Device ID (persistent across reinstalls)
class DeviceIdService {
  static const _storage = FlutterSecureStorage();
  static const _keyDeviceId = 'persistent_device_id';
  
  /// ดึง Device ID ที่ persistent (ไม่เปลี่ยนเมื่อ reinstall)
  /// 
  /// Android: ANDROID_ID (survives reinstall)
  /// iOS: IDFV + Keychain backup (survives reinstall)
  /// Fallback: Hardware fingerprint (เกิดได้หายากมาก < 0.01%)
  static Future<String> getDeviceId() async {
    // ตรวจสอบ cache ใน Keychain/SecureStorage ก่อน
    final cachedId = await _storage.read(key: _keyDeviceId);
    if (cachedId != null && cachedId.isNotEmpty) {
      return cachedId;
    }
    
    // ดึง Device ID จาก platform
    final deviceInfo = DeviceInfoPlugin();
    String deviceId = '';
    
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        // ANDROID_ID: persistent across app reinstalls (reset เมื่อ factory reset)
        deviceId = androidInfo.id; // เดิมชื่อ androidId
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        // IDFV: Identifier for Vendor
        deviceId = iosInfo.identifierForVendor ?? '';
      }
    } catch (e) {
      print('⚠️ Error getting primary device ID: $e');
    }
    
    // ────── Fallback: Hardware Fingerprint ──────
    if (deviceId.isEmpty || deviceId == 'unknown') {
      try {
        if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          deviceId = '${androidInfo.brand}_${androidInfo.device}_${androidInfo.model}'
              .replaceAll(' ', '_')
              .toLowerCase();
          print('📱 Using Android hardware fingerprint: $deviceId');
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          deviceId = '${iosInfo.name}_${iosInfo.model}'
              .replaceAll(' ', '_')
              .toLowerCase();
          print('📱 Using iOS hardware fingerprint: $deviceId');
        } else {
          // Web/Desktop: generate UUID และ save ไว้
          final prefs = await SharedPreferences.getInstance();
          deviceId = prefs.getString('fallback_device_id') ?? '';
          if (deviceId.isEmpty) {
            deviceId = 'web_${DateTime.now().millisecondsSinceEpoch}';
            await prefs.setString('fallback_device_id', deviceId);
          }
        }
      } catch (e) {
        // Last resort: generate random ID
        deviceId = 'unknown_${DateTime.now().millisecondsSinceEpoch}';
        print('⚠️ Using random device ID: $deviceId');
      }
    }
    
    // บันทึกลง Keychain/SecureStorage (iOS: จะอยู่ต่อหลัง reinstall)
    await _storage.write(key: _keyDeviceId, value: deviceId);
    
    return deviceId;
  }
  
  /// สำหรับ debug: ดูว่า Device ID คืออะไร
  static Future<void> printDeviceId() async {
    final id = await getDeviceId();
    print('🔑 Device ID: $id');
  }
}
```

---

#### 📁 `lib/core/services/energy_token_service.dart`

> **Junior: Copy ทั้งหมด**

```dart
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'device_id_service.dart';

/// Service สำหรับสร้างและตรวจสอบ Energy Token
/// Token นี้ส่งไปให้ Backend เพื่อ verify ว่าเรามี Energy พอหรือไม่
class EnergyTokenService {
  // TODO: เปลี่ยน SECRET นี้ให้ตรงกับที่ตั้งใน Firebase Functions Secrets
  // ⚠️ ต้องเหมือนกับที่ตั้งใน Backend ทุกตัวอักษร!
  static const String _encryptionSecret = 'YOUR_64_CHAR_SECRET_HERE_CHANGE_THIS';
  
  /// สร้าง Energy Token ใหม่
  /// Format: { userId, balance, timestamp, signature }
  static Future<String> generateToken(int balance) async {
    final userId = await DeviceIdService.getDeviceId();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final payload = '$userId:$balance:$timestamp';
    final signature = _generateSignature(payload);
    
    final token = {
      'userId': userId,
      'balance': balance,
      'timestamp': timestamp,
      'signature': signature,
    };
    
    return base64Encode(utf8.encode(json.encode(token)));
  }
  
  /// สร้าง HMAC-SHA256 signature
  static String _generateSignature(String payload) {
    final key = utf8.encode(_encryptionSecret);
    final bytes = utf8.encode(payload);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return digest.toString();
  }
  
  /// Decode token เพื่อดูข้อมูลภายใน (ใช้สำหรับ debug)
  static Map<String, dynamic>? decodeToken(String token) {
    try {
      final decoded = utf8.decode(base64Decode(token));
      return json.decode(decoded);
    } catch (e) {
      return null;
    }
  }
}
```

> **⚠️ สำคัญมาก:** ต้องเปลี่ยน `YOUR_64_CHAR_SECRET_HERE` ให้ตรงกับที่ตั้งใน Firebase Functions Secrets!

**วิธีสร้าง Secret:**
```bash
# Windows PowerShell
[System.Convert]::ToBase64String((1..48 | ForEach-Object { Get-Random -Maximum 256 }))

# macOS/Linux
openssl rand -base64 48
```

---

#### 📁 `lib/core/models/energy_transaction.dart`

> **Junior: Copy ทั้งหมด**

```dart
import 'package:isar/isar.dart';

part 'energy_transaction.g.dart';

/// Model สำหรับเก็บประวัติการใช้ Energy
@collection
class EnergyTransaction {
  Id id = Isar.autoIncrement;
  
  /// ประเภทของ transaction
  /// 'welcome_gift', 'purchase', 'usage', 'refund', 'pro_migration', 'welcome_offer'
  late String type;
  
  /// จำนวน Energy ที่เปลี่ยนแปลง (+100, -1, +550, ...)
  late int amount;
  
  /// ยอด Energy คงเหลือหลังจาก transaction นี้
  late int balanceAfter;
  
  /// Package ID (optional) — เช่น 'energy_100', 'energy_550_welcome'
  String? packageId;
  
  /// คำอธิบาย (optional) — เช่น 'Food image analysis', 'Purchased Value Pack'
  String? description;
  
  /// Google Play purchase token (optional) — ใช้สำหรับ verify การซื้อ
  String? purchaseToken;
  
  /// Device ID (optional) — ใช้สำหรับ track welcome gift
  String? deviceId;
  
  /// เวลาที่ทำ transaction
  late DateTime timestamp;
  
  /// Constructor
  EnergyTransaction({
    this.id = Isar.autoIncrement,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    this.packageId,
    this.description,
    this.purchaseToken,
    this.deviceId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
```

จากนั้นรัน:
```bash
flutter pub run build_runner build
```

---

#### 📁 `lib/core/services/energy_service.dart`

> **Junior: Copy ทั้งหมด**

```dart
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/energy_transaction.dart';
import 'device_id_service.dart';
import 'energy_token_service.dart';

/// Service หลักสำหรับจัดการ Energy Balance
class EnergyService {
  static const String _keyBalance = 'energy_balance';
  static const String _keyWelcomeClaimed = 'welcome_claimed_'; // + deviceId
  static const String _keyFirstAiUsage = 'first_ai_usage_time'; // สำหรับ Welcome Offer
  static const int welcomeGift = 100;
  static const _storage = FlutterSecureStorage();
  
  final Isar _isar;
  
  EnergyService(this._isar);
  
  // ───────────────────────────────────────────────────────────
  // 1. BALANCE MANAGEMENT
  // ───────────────────────────────────────────────────────────
  
  /// ดึงยอด Energy ปัจจุบัน (จาก SharedPreferences — เร็วกว่า Isar)
  Future<int> getBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyBalance) ?? 0;
  }
  
  /// ตรวจสอบว่ามี Energy พอใช้หรือไม่
  Future<bool> hasEnergy() async {
    final balance = await getBalance();
    return balance >= 1;
  }
  
  /// ใช้ Energy 1 หน่วย (เรียกหลังจาก AI analysis สำเร็จ)
  /// 
  /// Returns: true ถ้าใช้ได้, false ถ้า Energy ไม่พอ
  Future<bool> consumeEnergy({String? description}) async {
    final currentBalance = await getBalance();
    if (currentBalance < 1) {
      return false;
    }
    
    final newBalance = currentBalance - 1;
    await _updateBalance(newBalance);
    
    // บันทึก transaction
    await _saveTransaction(
      type: 'usage',
      amount: -1,
      balanceAfter: newBalance,
      description: description ?? 'AI food analysis',
    );
    
    // ตรวจสอบว่าใช้ครบ 3 ครั้งหรือยัง (สำหรับเปิด Welcome Offer)
    await _checkAiUsageCount();
    
    return true;
  }
  
  /// เพิ่ม Energy (หลังจากซื้อหรือได้รับของขวัญ)
  Future<void> addEnergy(
    int amount, {
    required String type,
    String? packageId,
    String? purchaseToken,
    String? description,
  }) async {
    final currentBalance = await getBalance();
    final newBalance = currentBalance + amount;
    await _updateBalance(newBalance);
    
    // บันทึก transaction
    await _saveTransaction(
      type: type,
      amount: amount,
      balanceAfter: newBalance,
      packageId: packageId,
      purchaseToken: purchaseToken,
      description: description,
    );
  }
  
  /// อัพเดทยอด Energy ใน SharedPreferences
  Future<void> _updateBalance(int newBalance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyBalance, newBalance);
  }
  
  // ───────────────────────────────────────────────────────────
  // 2. WELCOME GIFT (100 FREE ENERGY)
  // ───────────────────────────────────────────────────────────
  
  /// ตรวจสอบและมอบ Welcome Gift (100 Energy ฟรี)
  /// ผูกกับ Device ID — ได้รับแค่ครั้งเดียวต่อเครื่อง
  /// 
  /// Returns: true ถ้าได้รับ gift, false ถ้าเคยได้แล้ว
  Future<bool> initializeWelcomeGift() async {
    final deviceId = await DeviceIdService.getDeviceId();
    final key = '$_keyWelcomeClaimed$deviceId';
    final prefs = await SharedPreferences.getInstance();
    
    // ตรวจสอบ SharedPreferences
    if (prefs.getBool(key) == true) {
      return false; // เคยได้แล้ว
    }
    
    // ตรวจสอบ SecureStorage (iOS Keychain — อยู่ต่อหลัง reinstall)
    final secureFlag = await _storage.read(key: 'welcome_$deviceId');
    if (secureFlag == 'claimed') {
      // เคยได้แล้ว แต่ reinstall → sync กลับไป SharedPreferences
      await prefs.setBool(key, true);
      return false;
    }
    
    // มอบของขวัญ!
    await addEnergy(
      welcomeGift,
      type: 'welcome_gift',
      description: 'Welcome to MIRO! 🎉',
    );
    
    // บันทึก flag ทั้ง 2 ที่
    await prefs.setBool(key, true);
    await _storage.write(key: 'welcome_$deviceId', value: 'claimed');
    
    print('🎁 Welcome Gift granted: $welcomeGift Energy');
    return true;
  }
  
  /// ตรวจสอบว่าเคยได้ Welcome Gift หรือยัง
  Future<bool> hasClaimedWelcomeGift() async {
    final deviceId = await DeviceIdService.getDeviceId();
    final key = '$_keyWelcomeClaimed$deviceId';
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) == true;
  }
  
  // ───────────────────────────────────────────────────────────
  // 3. WELCOME OFFER (24-HOUR DISCOUNT)
  // ───────────────────────────────────────────────────────────
  
  static const String _keyAiUsageCount = 'ai_usage_count';
  
  /// ตรวจสอบว่าใช้ AI ครบ 3 ครั้งหรือยัง
  /// ถ้าครบ 3 ครั้ง → เริ่มนับ 24 ชั่วโมง Welcome Offer
  /// 
  /// **Design Decision:** เริ่ม offer หลังใช้ 3 ครั้ง (ไม่ใช่ครั้งแรก)
  /// เพราะผู้ใช้จะเห็นคุณค่าของ AI มากขึ้น → conversion rate สูงกว่า
  Future<void> _checkAiUsageCount() async {
    final prefs = await SharedPreferences.getInstance();
    
    // ถ้าเริ่ม offer ไปแล้ว → ไม่ต้องทำอะไร
    if (prefs.getInt(_keyFirstAiUsage) != null) {
      return;
    }
    
    // นับจำนวนครั้งที่ใช้
    final currentCount = prefs.getInt(_keyAiUsageCount) ?? 0;
    final newCount = currentCount + 1;
    await prefs.setInt(_keyAiUsageCount, newCount);
    
    // ถ้าใช้ครบ 3 ครั้ง → เริ่ม Welcome Offer!
    if (newCount >= 3) {
      await prefs.setInt(_keyFirstAiUsage, DateTime.now().millisecondsSinceEpoch);
      print('🎉 Used AI 3 times! Welcome Offer started (24h countdown).');
    } else {
      print('📊 AI usage count: $newCount/3');
    }
  }
  
  // ───────────────────────────────────────────────────────────
  // 4. TRANSACTION HISTORY
  // ───────────────────────────────────────────────────────────
  
  /// บันทึก transaction ลง Isar database
  Future<void> _saveTransaction({
    required String type,
    required int amount,
    required int balanceAfter,
    String? packageId,
    String? purchaseToken,
    String? description,
  }) async {
    final deviceId = await DeviceIdService.getDeviceId();
    
    final transaction = EnergyTransaction(
      type: type,
      amount: amount,
      balanceAfter: balanceAfter,
      packageId: packageId,
      purchaseToken: purchaseToken,
      description: description,
      deviceId: deviceId,
      timestamp: DateTime.now(),
    );
    
    await _isar.writeTxn(() async {
      await _isar.energyTransactions.put(transaction);
    });
  }
  
  /// ดึงประวัติ transaction ทั้งหมด (ใหม่สุดก่อน)
  Future<List<EnergyTransaction>> getTransactionHistory({int limit = 50}) async {
    return await _isar.energyTransactions
        .where()
        .sortByTimestampDesc()
        .limit(limit)
        .findAll();
  }
  
  /// ดึงประวัติการใช้ (เฉพาะ type='usage')
  Future<List<EnergyTransaction>> getUsageHistory({int limit = 30}) async {
    return await _isar.energyTransactions
        .filter()
        .typeEqualTo('usage')
        .sortByTimestampDesc()
        .limit(limit)
        .findAll();
  }
  
  // ───────────────────────────────────────────────────────────
  // 5. MIGRATION (สำหรับ existing users)
  // ───────────────────────────────────────────────────────────
  
  /// Migration: แปลง Pro user → 2,000 Energy
  /// Migration: แปลง Free user → 100 Energy (ถ้ายังไม่ได้รับ welcome gift)
  /// Migration: Beta testers → 1,000 Energy (พิเศษ!)
  Future<void> migrateFromProSystem({
    required bool wasProUser,
    bool isBetaTester = false,
  }) async {
    // ถ้าเคยได้ Welcome Gift แล้ว → ไม่ migrate
    if (await hasClaimedWelcomeGift()) {
      print('⚠️ User already migrated or claimed welcome gift');
      return;
    }
    
    final deviceId = await DeviceIdService.getDeviceId();
    final key = '$_keyWelcomeClaimed$deviceId';
    final prefs = await SharedPreferences.getInstance();
    
    if (isBetaTester) {
      // Beta tester → ได้ 1,000 Energy (รางวัลพิเศษ!)
      await addEnergy(
        1000,
        type: 'beta_tester_reward',
        description: 'Thank you for being a beta tester! 🙏💙',
      );
      print('✅ Beta tester migrated: 1,000 Energy');
    } else if (wasProUser) {
      // Pro user → ได้ 2,000 Energy
      await addEnergy(
        2000,
        type: 'pro_migration',
        description: 'Thank you for being an early Pro user! 🙏',
      );
      print('✅ Pro user migrated: 2,000 Energy');
    } else {
      // Free user → ได้ 100 Energy (เหมือน welcome gift)
      await addEnergy(
        100,
        type: 'pro_migration',
        description: 'Welcome to the new Energy system! 🎉',
      );
      print('✅ Free user migrated: 100 Energy');
    }
    
    // ทำเครื่องหมายว่า migrated แล้ว (ไม่ให้ได้ welcome gift ซ้ำ)
    await prefs.setBool(key, true);
    await _storage.write(key: 'welcome_$deviceId', value: 'claimed');
  }
  
  // ───────────────────────────────────────────────────────────
  // 6. TOKEN GENERATION (สำหรับส่งให้ Backend)
  // ───────────────────────────────────────────────────────────
  
  /// สร้าง Energy Token สำหรับส่งให้ Backend
  Future<String> generateEnergyToken() async {
    final balance = await getBalance();
    return EnergyTokenService.generateToken(balance);
  }
  
  /// อัพเดท Energy จาก Backend response (หลังจากใช้ AI)
  /// Backend จะส่ง newEnergyToken กลับมา
  Future<void> updateFromBackendToken(String newToken) async {
    final decoded = EnergyTokenService.decodeToken(newToken);
    if (decoded != null && decoded['balance'] != null) {
      await _updateBalance(decoded['balance'] as int);
    }
  }
}
```

---

#### 📁 `lib/core/services/welcome_offer_service.dart`

> **Junior: Copy ทั้งหมด**

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'device_id_service.dart';

/// Service สำหรับจัดการ Welcome Offer (40% OFF — 24 ชั่วโมง)
/// 
/// **Trigger:** หลังจากใช้ AI ครบ 3 ครั้ง
/// **Limit:** ซื้อได้เพียง 1 package ต่อ 1 device (ไม่ว่าจะเป็น package ไหน)
class WelcomeOfferService {
  static const String _keyFirstAiUsage = 'first_ai_usage_time';
  static const String _keyOfferClaimed = 'welcome_offer_claimed_'; // + deviceId
  static const String _keyPurchasedPackage = 'welcome_package_purchased'; // เก็บว่าซื้อ package ไหนไปแล้ว
  static const Duration offerDuration = Duration(hours: 24);
  static const _storage = FlutterSecureStorage();
  
  // ───────────────────────────────────────────────────────────
  // 1. OFFER STATUS
  // ───────────────────────────────────────────────────────────
  
  /// ตรวจสอบสถานะของ Welcome Offer
  static Future<WelcomeOfferStatus> getStatus() async {
    final deviceId = await DeviceIdService.getDeviceId();
    final key = '$_keyOfferClaimed$deviceId';
    final prefs = await SharedPreferences.getInstance();
    
    // ตรวจสอบว่าซื้อแล้วหรือยัง
    if (prefs.getBool(key) == true) {
      return WelcomeOfferStatus.claimed;
    }
    
    // ตรวจสอบ SecureStorage (iOS Keychain)
    final secureFlag = await _storage.read(key: 'offer_$deviceId');
    if (secureFlag == 'claimed') {
      await prefs.setBool(key, true); // sync
      return WelcomeOfferStatus.claimed;
    }
    
    // ตรวจสอบว่าเคยใช้ AI หรือยัง
    final firstUsageMs = prefs.getInt(_keyFirstAiUsage);
    if (firstUsageMs == null) {
      return WelcomeOfferStatus.notStarted; // ยังไม่ได้ใช้ AI เลย
    }
    
    // ตรวจสอบว่าหมดเวลาหรือยัง
    final firstUsage = DateTime.fromMillisecondsSinceEpoch(firstUsageMs);
    final expiresAt = firstUsage.add(offerDuration);
    final now = DateTime.now();
    
    if (now.isBefore(expiresAt)) {
      return WelcomeOfferStatus.active; // ยังใช้ได้อยู่
    }
    
    return WelcomeOfferStatus.expired; // หมดเวลาแล้ว
  }
  
  /// ดึงเวลาที่เหลือของ Offer
  /// Returns: null ถ้ายังไม่เริ่มหรือหมดเวลาแล้ว
  static Future<Duration?> getRemainingTime() async {
    final prefs = await SharedPreferences.getInstance();
    final firstUsageMs = prefs.getInt(_keyFirstAiUsage);
    if (firstUsageMs == null) return null;
    
    final expiresAt = DateTime.fromMillisecondsSinceEpoch(firstUsageMs)
        .add(offerDuration);
    final remaining = expiresAt.difference(DateTime.now());
    
    return remaining.isNegative ? null : remaining;
  }
  
  /// เริ่มจับเวลา 24 ชั่วโมง (เรียกหลังจากใช้ AI ครั้งแรก)
  static Future<bool> startTimer() async {
    final prefs = await SharedPreferences.getInstance();
    final firstUsageMs = prefs.getInt(_keyFirstAiUsage);
    
    if (firstUsageMs != null) {
      return false; // เริ่มไปแล้ว
    }
    
    await prefs.setInt(_keyFirstAiUsage, DateTime.now().millisecondsSinceEpoch);
    print('⏰ Welcome Offer timer started: 24 hours');
    return true;
  }
  
  /// ทำเครื่องหมายว่าซื้อ Welcome Offer แล้ว
  /// 
  /// **Important:** ซื้อได้แค่ 1 package — หลังจากซื้อแล้ว
  /// ทุก welcome package จะหายไป แม้ยังไม่หมด 24 ชั่วโมง
  static Future<void> markClaimed(String packageId) async {
    final deviceId = await DeviceIdService.getDeviceId();
    final key = '$_keyOfferClaimed$deviceId';
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool(key, true);
    await prefs.setString(_keyPurchasedPackage, packageId);
    await _storage.write(key: 'offer_$deviceId', value: 'claimed');
    await _storage.write(key: 'package_$deviceId', value: packageId);
    print('✅ Welcome Offer claimed: $packageId');
  }
  
  /// ตรวจสอบว่าซื้อ package ไหนไปแล้ว (สำหรับ analytics)
  static Future<String?> getPurchasedPackage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPurchasedPackage);
  }
  
  /// ตรวจสอบว่าซื้อแล้วหรือยัง
  static Future<bool> hasClaimed() async {
    final status = await getStatus();
    return status == WelcomeOfferStatus.claimed;
  }
  
  /// ดึงเวลาที่หมดอายุ (สำหรับแสดง countdown)
  static Future<DateTime?> getExpiryTime() async {
    final prefs = await SharedPreferences.getInstance();
    final firstUsageMs = prefs.getInt(_keyFirstAiUsage);
    if (firstUsageMs == null) return null;
    
    return DateTime.fromMillisecondsSinceEpoch(firstUsageMs).add(offerDuration);
  }
  
  /// Format เวลาที่เหลือเป็นข้อความ (เช่น "23h 41m")
  static String formatRemainingTime(Duration remaining) {
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}

/// สถานะของ Welcome Offer
enum WelcomeOfferStatus {
  notStarted,  // ยังไม่ได้ใช้ AI เลย
  active,      // กำลังนับเวลา 24 ชั่วโมง — แสดง offer
  expired,     // หมดเวลาแล้ว
  claimed,     // ซื้อไปแล้ว
}
```

---

### 4.3 Update Gemini Service (เชื่อมต่อ Backend)

เปิดไฟล์ `lib/core/ai/gemini_service.dart` แล้วแก้:

> **Junior: แทนที่ทั้งไฟล์**

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:miro/core/services/energy_service.dart';
import 'package:miro/core/services/device_id_service.dart';

class GeminiService {
  // Backend URL (Firebase Cloud Function)
  // หลัง deploy แล้ว URL จะเป็น: https://REGION-PROJECT_ID.cloudfunctions.net/analyzeFood
  // Default region: us-central1
  static const String _backendUrl = 
      'https://us-central1-miro-d6856.cloudfunctions.net/analyzeFood';
  
  final EnergyService _energyService;
  
  GeminiService(this._energyService);
  
  // ───────────────────────────────────────────────────────────
  // 1. ANALYZE FOOD IMAGE
  // ───────────────────────────────────────────────────────────
  
  /// วิเคราะห์รูปอาหารด้วย AI
  /// ใช้ 1 Energy
  Future<Map<String, dynamic>?> analyzeFoodImage(String imageBase64) async {
    return _callBackend(
      type: 'image',
      prompt: _getImageAnalysisPrompt(),
      imageBase64: imageBase64,
      description: 'Food image analysis',
    );
  }
  
  // ───────────────────────────────────────────────────────────
  // 2. ANALYZE FOOD BY NAME (TEXT ONLY)
  // ───────────────────────────────────────────────────────────
  
  /// วิเคราะห์อาหารจากชื่อ (ไม่มีรูป)
  /// ใช้ 1 Energy
  Future<Map<String, dynamic>?> analyzeFoodByName(String foodName) async {
    return _callBackend(
      type: 'text',
      prompt: _getTextAnalysisPrompt(foodName),
      description: 'Text-based food analysis: $foodName',
    );
  }
  
  // ───────────────────────────────────────────────────────────
  // 3. ANALYZE NUTRITION LABEL / BARCODE
  // ───────────────────────────────────────────────────────────
  
  /// วิเคราะห์ nutrition label
  /// ใช้ 1 Energy
  Future<Map<String, dynamic>?> analyzeNutritionLabel(String imageBase64) async {
    return _callBackend(
      type: 'image',
      prompt: _getNutritionLabelPrompt(),
      imageBase64: imageBase64,
      description: 'Nutrition label analysis',
    );
  }
  
  // ───────────────────────────────────────────────────────────
  // 4. BACKEND CALLER (CORE LOGIC)
  // ───────────────────────────────────────────────────────────
  
  /// เรียก Backend API (Firebase Cloud Function)
  Future<Map<String, dynamic>?> _callBackend({
    required String type,
    required String prompt,
    String? imageBase64,
    required String description,
  }) async {
    try {
      // ────── 4.1. ตรวจสอบว่ามี Energy พอหรือไม่ ──────
      final hasEnergy = await _energyService.hasEnergy();
      if (!hasEnergy) {
        throw Exception('Insufficient energy');
      }
      
      // ────── 4.2. สร้าง Energy Token ──────
      final energyToken = await _energyService.generateEnergyToken();
      final deviceId = await DeviceIdService.getDeviceId();
      
      // ────── 4.3. เรียก Backend ──────
      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-energy-token': energyToken,
          'x-device-id': deviceId,
        },
        body: json.encode({
          'type': type,
          'prompt': prompt,
          if (imageBase64 != null) 'imageBase64': imageBase64,
        }),
      );
      
      // ────── 4.4. ตรวจสอบ Response ──────
      if (response.statusCode == 402) {
        // Insufficient energy
        throw Exception('Insufficient energy');
      }
      
      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Backend error');
      }
      
      final result = json.decode(response.body);
      
      // ────── 4.5. อัพเดท Energy Balance ──────
      final newToken = result['newEnergyToken'] as String?;
      if (newToken != null) {
        await _energyService.updateFromBackendToken(newToken);
      }
      
      // ────── 4.6. Parse Gemini Response ──────
      final geminiData = result['data'];
      final text = geminiData['candidates'][0]['content']['parts'][0]['text'] as String;
      
      // ลบ markdown code block (```json ... ```)
      final cleanedText = text
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll(RegExp(r'```\s*$'), '')
          .trim();
      
      final parsedResult = json.decode(cleanedText);
      
      // ────── 4.7. Analytics (Firebase) ──────
      await FirebaseAnalytics.instance.logEvent(
        name: 'ai_analysis_success',
        parameters: {
          'type': request.type,
          'energy_used': 1,
        },
      );
      
      return parsedResult;
      
    } catch (e) {
      print('❌ Gemini API Error: $e');
      
      // Analytics: log failure
      await FirebaseAnalytics.instance.logEvent(
        name: 'ai_analysis_failed',
        parameters: {
          'type': request.type,
          'error': e.toString(),
        },
      );
      
      rethrow;
    }
  }
  
  // ───────────────────────────────────────────────────────────
  // 5. PROMPTS
  // ───────────────────────────────────────────────────────────
  
  String _getImageAnalysisPrompt() {
    return '''
Analyze this food image and return a JSON with nutrition information.

IMPORTANT: Return ONLY valid JSON, no markdown, no explanation.

Format:
{
  "name": "Food name in Thai",
  "calories": 0,
  "protein": 0,
  "carbs": 0,
  "fat": 0,
  "servingSize": "100g",
  "confidence": 0.95
}

If you can't identify the food, set confidence to 0.0 and make reasonable estimates.
''';
  }
  
  String _getTextAnalysisPrompt(String foodName) {
    return '''
Provide nutrition information for: $foodName

Return ONLY valid JSON, no markdown:
{
  "name": "$foodName",
  "calories": 0,
  "protein": 0,
  "carbs": 0,
  "fat": 0,
  "servingSize": "100g",
  "confidence": 0.80
}
''';
  }
  
  String _getNutritionLabelPrompt() {
    return '''
Read this nutrition label and extract the information.

Return ONLY valid JSON:
{
  "name": "Product name",
  "calories": 0,
  "protein": 0,
  "carbs": 0,
  "fat": 0,
  "servingSize": "as stated on label",
  "confidence": 1.0
}
''';
  }
}
```

> **⚠️ สำคัญ:** ต้องเปลี่ยน:
> ✅ Project ID: **miro-d6856** (อัพเดทแล้ว)
> ✅ ไม่ต้องใช้ anon key เพราะ Firebase Functions เป็น public endpoint (ป้องกันด้วย Energy Token แทน)

---

### 4.4 Update Purchase Service

เปิด `lib/core/services/purchase_service.dart`:

> **Junior: เพิ่มโค้ดนี้เข้าไป**

```dart
// เพิ่มใน class PurchaseService

// ───────────────────────────────────────────────────────────
// ENERGY PACKAGE CONSTANTS
// ───────────────────────────────────────────────────────────

/// Regular energy packages
static const String energy100 = 'energy_100';      // $0.99
static const String energy550 = 'energy_550';      // $4.99
static const String energy1200 = 'energy_1200';    // $7.99
static const String energy2000 = 'energy_2000';    // $9.99

/// Welcome offer packages (40% OFF — 24h only)
static const String energy100Welcome = 'energy_100_welcome';    // $0.59
static const String energy550Welcome = 'energy_550_welcome';    // $2.99
static const String energy1200Welcome = 'energy_1200_welcome';  // $4.79
static const String energy2000Welcome = 'energy_2000_welcome';  // $5.99

/// Map: Product ID → Energy amount
static const Map<String, int> energyAmounts = {
  energy100: 100,
  energy550: 550,
  energy1200: 1200,
  energy2000: 2000,
  energy100Welcome: 100,
  energy550Welcome: 550,
  energy1200Welcome: 1200,
  energy2000Welcome: 2000,
};

// ───────────────────────────────────────────────────────────
// PURCHASE ENERGY
// ───────────────────────────────────────────────────────────

/// ซื้อ Energy package
/// 
/// Example:
/// ```dart
/// await purchaseService.purchaseEnergy('energy_550');
/// ```
Future<bool> purchaseEnergy(String productId) async {
  try {
    final energyAmount = energyAmounts[productId];
    if (energyAmount == null) {
      throw Exception('Invalid product ID: $productId');
    }
    
    // เรียก in_app_purchase
    final ProductDetailsResponse response = 
        await _iap.queryProductDetails({productId});
    
    if (response.productDetails.isEmpty) {
      throw Exception('Product not found: $productId');
    }
    
    final product = response.productDetails.first;
    final purchaseParam = PurchaseParam(productDetails: product);
    
    // ซื้อ (consumable product)
    final success = await _iap.buyConsumable(
      purchaseParam: purchaseParam,
      autoConsume: false, // เราจะ consume เอง
    );
    
    return success;
  } catch (e) {
    print('❌ Purchase error: $e');
    return false;
  }
}

// ───────────────────────────────────────────────────────────
// HANDLE PURCHASE UPDATE
// ───────────────────────────────────────────────────────────

/// Listen to purchase updates
/// เพิ่มใน constructor หรือ init method:
void _listenToPurchases() {
  _iap.purchaseStream.listen((purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        await _handlePurchase(purchase);
      }
    }
  });
}

Future<void> _handlePurchase(PurchaseDetails purchase) async {
  final productId = purchase.productID;
  final energyAmount = energyAmounts[productId];
  
  if (energyAmount == null) {
    print('⚠️ Unknown product: $productId');
    return;
  }
  
  // เพิ่ม Energy
  await _energyService.addEnergy(
    energyAmount,
    type: productId.contains('welcome') ? 'welcome_offer' : 'purchase',
    packageId: productId,
    purchaseToken: purchase.verificationData.serverVerificationData,
    description: 'Purchased $energyAmount Energy',
  );
  
  // ถ้าเป็น welcome offer → mark as claimed
  if (productId.contains('welcome')) {
    // ตรวจสอบว่าเคยซื้อแล้วหรือยัง (double-check)
    final hasClaimed = await WelcomeOfferService.hasClaimed();
    if (hasClaimed) {
      print('⚠️ Welcome offer already claimed! This should not happen.');
      await _iap.completePurchase(purchase);
      return;
    }
    
    await WelcomeOfferService.markClaimed(productId);
    
    // Analytics: track welcome offer purchase
    await FirebaseAnalytics.instance.logEvent(
      name: 'welcome_offer_purchased',
      parameters: {
        'package_id': productId,
        'amount': energyAmount,
      },
    );
  } else {
    // Analytics: track regular purchase
    await FirebaseAnalytics.instance.logEvent(
      name: 'energy_purchased',
      parameters: {
        'package_id': productId,
        'amount': energyAmount,
      },
    );
  }
  
  // Complete purchase (consumable)
  await _iap.completePurchase(purchase);
  
  print('✅ Purchase completed: +$energyAmount Energy');
}
```

---

## 🎨 Step 5: Create UI Components

### 5.1 Energy Badge (AppBar)

สร้างไฟล์ `lib/features/energy/widgets/energy_badge.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:miro/core/services/energy_service.dart';
import 'package:miro/features/energy/presentation/energy_store_screen.dart';

/// Badge แสดง Energy ที่เหลือ (ติด AppBar)
class EnergyBadge extends StatefulWidget {
  const EnergyBadge({super.key});

  @override
  State<EnergyBadge> createState() => _EnergyBadgeState();
}

class _EnergyBadgeState extends State<EnergyBadge> {
  int _balance = 0;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    // TODO: ดึง EnergyService จาก GetIt หรือ Provider
    // final balance = await energyService.getBalance();
    // setState(() => _balance = balance);
    
    // Placeholder:
    setState(() => _balance = 87);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // เปิด Energy Store
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EnergyStoreScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _balance < 10 
              ? Colors.red.withOpacity(0.1) 
              : Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _balance < 10 ? Colors.red : Colors.green,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚡', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(
              '$_balance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _balance < 10 ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**วิธีใช้:**
```dart
// ใน home_screen.dart, profile_screen.dart, etc.
AppBar(
  title: Text('MIRO'),
  actions: [
    EnergyBadge(), // เพิ่มตรงนี้
    SizedBox(width: 8),
    IconButton(...), // ปุ่มอื่นๆ
  ],
)
```

---

### 5.2 No Energy Dialog

สร้าง `lib/features/energy/widgets/no_energy_dialog.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:miro/features/energy/presentation/energy_store_screen.dart';

/// Dialog แสดงเมื่อ Energy หมด
class NoEnergyDialog extends StatelessWidget {
  const NoEnergyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Text('⚡', style: TextStyle(fontSize: 32)),
          SizedBox(width: 12),
          Text('Energy หมดแล้ว'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'คุณต้องใช้ 1 Energy เพื่อวิเคราะห์อาหารด้วย AI',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          Text(
            '💡 คุณยังสามารถบันทึกอาหารแบบธรรมดา (ไม่ใช้ AI) ได้ฟรี',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('ไว้ทีหลัง'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EnergyStoreScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text('ซื้อ Energy', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
  
  /// แสดง Dialog
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => NoEnergyDialog(),
    );
  }
}
```

**วิธีใช้:**
```dart
// ก่อนเรียก AI
final hasEnergy = await energyService.hasEnergy();
if (!hasEnergy) {
  // Analytics: user tried to analyze but no energy
  await FirebaseAnalytics.instance.logEvent(
    name: 'no_energy_shown',
    parameters: {'context': 'barcode_scanner'},
  );
  
  await NoEnergyDialog.show(context);
  return;
}
```

---

### 5.3 Energy Store Screen

สร้าง `lib/features/energy/presentation/energy_store_screen.dart`:

> **Junior: Copy ทั้งหมด — ไฟล์ยาวหน่อย**

```dart
import 'package:flutter/material.dart';
import 'package:miro/core/services/energy_service.dart';
import 'package:miro/core/services/welcome_offer_service.dart';
import 'package:miro/core/services/purchase_service.dart';

/// หน้าร้านค้า Energy (ซื้อ Energy packages)
class EnergyStoreScreen extends StatefulWidget {
  const EnergyStoreScreen({super.key});

  @override
  State<EnergyStoreScreen> createState() => _EnergyStoreScreenState();
}

class _EnergyStoreScreenState extends State<EnergyStoreScreen> {
  int _balance = 0;
  WelcomeOfferStatus _offerStatus = WelcomeOfferStatus.notStarted;
  Duration? _remainingTime;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // TODO: ดึงจาก GetIt/Provider
    // final balance = await energyService.getBalance();
    // final status = await WelcomeOfferService.getStatus();
    // final remaining = await WelcomeOfferService.getRemainingTime();
    
    // Placeholder:
    setState(() {
      _balance = 87;
      _offerStatus = WelcomeOfferStatus.active; // เปลี่ยนเป็น .notStarted/.expired/.claimed เพื่อทดสอบ
      _remainingTime = Duration(hours: 23, minutes: 41);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('⚡ Energy Store'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '⚡ $_balance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // ────── Current Balance ──────
          _buildBalanceCard(),
          SizedBox(height: 24),
          
          // ────── Welcome Offer (ถ้า active) ──────
          if (_offerStatus == WelcomeOfferStatus.active)
            _buildWelcomeOfferSection(),
          
          // ────── Regular Packages ──────
          Text(
            _offerStatus == WelcomeOfferStatus.active 
                ? '💰 Regular Prices' 
                : '⚡ Energy Packages',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          
          _buildPackageCard(
            emoji: '🎯',
            name: 'Starter Kick',
            energy: 100,
            price: 0.99,
            priceText: '\$0.99',
            productId: PurchaseService.energy100,
          ),
          
          _buildPackageCard(
            emoji: '💎',
            name: 'Value Pack',
            energy: 550,
            price: 4.99,
            priceText: '\$4.99',
            productId: PurchaseService.energy550,
            badge: '+10% bonus',
          ),
          
          _buildPackageCard(
            emoji: '🔥',
            name: 'Power User',
            energy: 1200,
            price: 7.99,
            priceText: '\$7.99',
            productId: PurchaseService.energy1200,
            badge: 'POPULAR',
            isPopular: true,
          ),
          
          _buildPackageCard(
            emoji: '🏆',
            name: 'Ultimate Saver',
            energy: 2000,
            price: 9.99,
            priceText: '\$9.99',
            productId: PurchaseService.energy2000,
            badge: 'BEST DEAL',
            isBest: true,
          ),
          
          SizedBox(height: 24),
          
          // ────── Info ──────
          _buildInfoCard(),
        ],
      ),
    );
  }
  
  // ───────────────────────────────────────────────────────────
  // WIDGETS
  // ───────────────────────────────────────────────────────────
  
  Widget _buildBalanceCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text('⚡', style: TextStyle(fontSize: 48)),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Energy ของคุณ',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Text(
                '$_balance',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildWelcomeOfferSection() {
    final timeStr = _remainingTime != null 
        ? WelcomeOfferService.formatRemainingTime(_remainingTime!)
        : '--';
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ────── Header ──────
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade400, Colors.red.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text('🎉', style: TextStyle(fontSize: 32)),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Offer — 40% OFF!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '⏰ Expires in: $timeStr',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 16),
        
        // ────── Welcome Packages ──────
        _buildPackageCard(
          emoji: '🎯',
          name: 'Starter Kick',
          energy: 100,
          price: 0.59,
          priceText: '\$0.59',
          originalPrice: '\$0.99',
          productId: PurchaseService.energy100Welcome,
          isWelcome: true,
        ),
        
        _buildPackageCard(
          emoji: '💎',
          name: 'Value Pack',
          energy: 550,
          price: 2.99,
          priceText: '\$2.99',
          originalPrice: '\$4.99',
          productId: PurchaseService.energy550Welcome,
          badge: '+10%',
          isWelcome: true,
        ),
        
        _buildPackageCard(
          emoji: '🔥',
          name: 'Power User',
          energy: 1200,
          price: 4.79,
          priceText: '\$4.79',
          originalPrice: '\$7.99',
          productId: PurchaseService.energy1200Welcome,
          badge: '+20%',
          isWelcome: true,
          isPopular: true,
        ),
        
        _buildPackageCard(
          emoji: '🏆',
          name: 'Ultimate Saver',
          energy: 2000,
          price: 5.99,
          priceText: '\$5.99',
          originalPrice: '\$9.99',
          productId: PurchaseService.energy2000Welcome,
          badge: '+50%',
          isWelcome: true,
          isBest: true,
        ),
        
        SizedBox(height: 24),
      ],
    );
  }
  
  Widget _buildPackageCard({
    required String emoji,
    required String name,
    required int energy,
    required double price,
    required String priceText,
    required String productId,
    String? originalPrice,
    String? badge,
    bool isPopular = false,
    bool isBest = false,
    bool isWelcome = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isPopular || isBest 
            ? Colors.orange.shade50 
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPopular || isBest ? Colors.orange : Colors.grey.shade300,
          width: isPopular || isBest ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _purchasePackage(productId, energy),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // ────── Icon ──────
                Text(emoji, style: TextStyle(fontSize: 36)),
                SizedBox(width: 16),
                
                // ────── Info ──────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (badge != null) ...[
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isPopular || isBest 
                                    ? Colors.orange 
                                    : Colors.blue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                badge,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        '⚡ $energy Energy',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // ────── Price ──────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (originalPrice != null) ...[
                      Text(
                        originalPrice,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      SizedBox(height: 2),
                    ],
                    Text(
                      priceText,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isWelcome ? Colors.orange : Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('ℹ️', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'เกี่ยวกับ Energy',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildInfoRow('⚡', '1 Energy = 1 AI analysis'),
          _buildInfoRow('♾️', 'Energy never expires'),
          _buildInfoRow('📱', 'Syncs across devices (coming soon)'),
          _buildInfoRow('💚', 'Manual logging is always free'),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String emoji, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 16)),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
  
  // ───────────────────────────────────────────────────────────
  // ACTIONS
  // ───────────────────────────────────────────────────────────
  
  Future<void> _purchasePackage(String productId, int energy) async {
    // TODO: เรียก PurchaseService
    // final success = await purchaseService.purchaseEnergy(productId);
    // if (success) {
    //   await _loadData(); // refresh balance
    // }
    
    // Placeholder:
    print('🛒 Purchasing: $productId (+$energy Energy)');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('TODO: Implement purchase flow')),
    );
  }
}
```

---

## ✅ Step 6: Update AI Call Points

ทุกที่ที่เรียกใช้ Gemini API ต้องตรวจสอบ Energy ก่อน:

### ตัวอย่าง: ใน `barcode_scanner_screen.dart`

**Before (BYOK):**
```dart
// Old code
final result = await geminiService.analyzeFoodImage(imageBase64);
```

**After (Energy System):**
```dart
// New code
// 1. ตรวจสอบ Energy
final hasEnergy = await energyService.hasEnergy();
if (!hasEnergy) {
  await NoEnergyDialog.show(context);
  return;
}

// 2. แสดง loading
showDialog(
  context: context,
  barrierDismissible: false,
  builder: (_) => Center(child: CircularProgressIndicator()),
);

try {
  // 3. เรียก API (จะ deduct Energy อัตโนมัติ)
  final result = await geminiService.analyzeFoodImage(imageBase64);
  
  // 4. Success!
  Navigator.pop(context); // ปิด loading
  // ... ทำอะไรต่อกับ result ...
  
} catch (e) {
  Navigator.pop(context);
  
  if (e.toString().contains('Insufficient energy')) {
    // Energy หมดระหว่างทาง (race condition)
    await NoEnergyDialog.show(context);
  } else {
    // Error อื่นๆ
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
```

> **Junior: ทำแบบนี้ใน**
> - `barcode_scanner_screen.dart`
> - `food_preview_screen.dart`
> - `nutrition_label_screen.dart`
> - `health_diet_tab.dart`
> - ทุกที่ที่เรียก `geminiService.analyze...()`

---

## 🗑️ Step 7: Remove BYOK System

### 7.1 Delete Files
```bash
# ลบไฟล์เก่าทั้งหมด
rm lib/features/profile/presentation/api_key_screen.dart
```

### 7.2 Remove from Profile Screen

เปิด `lib/features/profile/presentation/profile_screen.dart`:

**ลบส่วนนี้:**
```dart
// ❌ ลบทิ้ง
ListTile(
  leading: Icon(Icons.key),
  title: Text('Gemini API Key'),
  subtitle: Text('Set up your API key'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ApiKeyScreen()),
    );
  },
),
```

### 7.3 Remove from Onboarding

เปิด `lib/features/onboarding/presentation/onboarding_screen.dart`:

**ลบหน้า API Key setup (ถ้ามี):**
```dart
// ❌ ลบทิ้ง
PageViewModel(
  title: 'Set up API Key',
  body: '...',
  ...
),
```

### 7.4 Clean Up SecureStorageService

เปิด `lib/core/services/secure_storage_service.dart`:

**ลบ methods เหล่านี้ (หรือเก็บไว้ใช้งานอื่น):**
```dart
// ❌ ลบ/comment ออก
static Future<void> setGeminiApiKey(String key) async { ... }
static Future<String?> getGeminiApiKey() async { ... }
static Future<void> deleteGeminiApiKey() async { ... }
```

---

## 🎮 Step 8: Initialize at App Startup

เปิด `lib/main.dart` (หรือที่ใช้ initialize app):

```dart
Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ... existing initialization ...
  
  // ────── Initialize Energy System ──────
  final isar = await Isar.open([EnergyTransactionSchema]);
  final energyService = EnergyService(isar);
  
  // ตรวจสอบและมอบ Welcome Gift
  final receivedGift = await energyService.initializeWelcomeGift();
  if (receivedGift) {
    print('🎁 Welcome Gift: 100 Energy!');
  }
  
  // ────── Migrate Existing Users ──────
  // ดึง email จาก Firebase Auth
  final user = FirebaseAuth.instance.currentUser;
  final userEmail = user?.email;
  
  // ตรวจสอบว่าเป็น beta tester หรือไม่
  final isBetaTester = BetaTesters.isBetaTester(userEmail);
  if (isBetaTester) {
    print('🌟 Beta Tester detected: $userEmail');
  }
  
  // ตรวจสอบว่าเคยเป็น Pro user หรือไม่
  final wasPro = await _checkIfWasProUser();
  
  // Migrate
  await energyService.migrateFromProSystem(
    wasProUser: wasPro,
    isBetaTester: isBetaTester,
  );
  
  // ────── Helper: ตรวจสอบว่าเคยเป็น Pro หรือไม่ ──────
  Future<bool> _checkIfWasProUser() async {
    // TODO: Check จาก purchase history หรือ SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('was_pro_user') ?? false;
  }
  
  // ────── Register services (GetIt / Provider) ──────
  // getIt.registerSingleton<EnergyService>(energyService);
  // ... etc ...
  
  runApp(MyApp());
}
```

---

## 🧪 Testing Checklist

### ✅ Backend Testing
```bash
# Test 1: Health check
curl https://us-central1-miro-d6856.cloudfunctions.net/analyzeFood \
  -X OPTIONS

# Test 2: Valid token (ใช้ token จริงจากแอป)
curl https://us-central1-miro-d6856.cloudfunctions.net/analyzeFood \
  -X POST \
  -H "Content-Type: application/json" \
  -H "x-energy-token: YOUR_GENERATED_TOKEN" \
  -H "x-device-id: test_device_123" \
  -d '{"type":"text","prompt":"Analyze: Chicken breast 100g"}'

# Test 3: Invalid token
curl https://us-central1-miro-d6856.cloudfunctions.net/analyzeFood \
  -X POST \
  -H "Content-Type: application/json" \
  -H "x-energy-token: invalid_token" \
  -d '{"type":"text","prompt":"Test"}'
# Expected: 401 Unauthorized
```

### ✅ App Testing

| Test Case | Expected Result |
|-----------|----------------|
| **Fresh install** | Get 100 Energy welcome gift |
| **Reinstall (same device)** | No welcome gift, balance = 0 |
| **First AI analysis** | Welcome Offer timer starts (24h) |
| **Open Energy Store** | See welcome prices (if active) |
| **Purchase energy** | Balance increases, transaction logged |
| **AI analysis** | Balance decreases by 1 |
| **No energy** | Show NoEnergyDialog |
| **Welcome offer expires** | Only show regular prices |
| **Purchase welcome offer** | Mark as claimed, no more welcome UI |

---

## 🚀 Step 9: Google Play Console Setup

### 9.1 Create IAP Products

ไปที่: **Google Play Console → Your App → Monetize → In-app products**

**Regular Products:**
| Product ID | Name | Price | Type |
|------------|------|-------|------|
| `energy_100` | 100 Energy | $0.99 | Consumable |
| `energy_550` | 550 Energy | $4.99 | Consumable |
| `energy_1200` | 1,200 Energy | $7.99 | Consumable |
| `energy_2000` | 2,000 Energy | $9.99 | Consumable |

**Welcome Offer Products:**
| Product ID | Name | Price | Type |
|------------|------|-------|------|
| `energy_100_welcome` | 100 Energy (Welcome Offer) | $0.59 | Consumable |
| `energy_550_welcome` | 550 Energy (Welcome Offer) | $2.99 | Consumable |
| `energy_1200_welcome` | 1,200 Energy (Welcome Offer) | $4.79 | Consumable |
| `energy_2000_welcome` | 2,000 Energy (Welcome Offer) | $5.99 | Consumable |

> **Note:** Welcome products ไม่ควร "visible in store" — แค่ให้แอปเรียกได้เมื่อ offer active

### 9.2 Test IAP

1. เพิ่ม license testers ใน Play Console
2. Build app แบบ `--release` (IAP ไม่ทำงานใน debug mode)
3. Upload APK/AAB เป็น Internal Testing track
4. ทดสอบซื้อด้วย account ที่เป็น tester

---

## 📦 Step 10: Deployment

### 10.1 Backend Deployment (Firebase)

```bash
# Deploy Cloud Function
cd c:/aiprogram/miro
firebase deploy --only functions:analyzeFood

# ตรวจสอบว่า deploy สำเร็จ
firebase functions:list

# ตรวจสอบ secrets
firebase functions:secrets:access GEMINI_API_KEY
firebase functions:secrets:access ENERGY_ENCRYPTION_SECRET
# ต้องมี: GEMINI_API_KEY, ENERGY_ENCRYPTION_SECRET
```

### 10.2 App Deployment (Flutter)

```bash
# 1. Build Android
flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info

# 2. Build iOS
flutter build ios --release --obfuscate --split-debug-info=build/debug-info

# 3. Upload to Play Console / App Store Connect
```

### 10.3 Environment Variables Checklist

| Variable | Location | Value |
|----------|----------|-------|
| `GEMINI_API_KEY` | Firebase Secrets | Your Gemini API key |
| `ENERGY_ENCRYPTION_SECRET` | Firebase Secrets | 64-char random string |
| `_backendUrl` | `gemini_service.dart` | https://us-central1-miro-d6856.cloudfunctions.net/analyzeFood |
| `_encryptionSecret` | `energy_token_service.dart` | Same as Firebase secret |

---

## 🐛 Troubleshooting

### ❌ "Insufficient energy" แม้ว่ามี Energy

**สาเหตุ:** Token signature ไม่ตรงกัน

**แก้ไข:**
1. ตรวจสอบว่า `ENERGY_ENCRYPTION_SECRET` ใน Firebase Secrets ตรงกับ `_encryptionSecret` ในแอป
2. Redeploy Cloud Function: `firebase deploy --only functions:analyzeFood`
3. Rebuild แอป

---

### ❌ CORS Error

**สาเหตุ:** Backend ไม่ allow origin

**แก้ไข:** ใน `functions/src/analyzeFood.ts`, ตรวจสอบ:
```typescript
const corsHeaders = {
  "Access-Control-Allow-Origin": "*", // หรือระบุ domain ของแอป
  ...
};
```

---

### ❌ Welcome Gift ไม่ได้รับ

**สาเหตุ:** Device ID cache หรือ flag ค้างจากรอบก่อน

**แก้ไข:**
```dart
// ลบ cache (debug only)
final prefs = await SharedPreferences.getInstance();
await prefs.clear();
await FlutterSecureStorage().deleteAll();
```

---

### ❌ IAP ไม่ทำงาน

**สาเหตุ:** ต้อง build แบบ `--release` และ upload ขึ้น Play Console

**แก้ไข:**
1. Build: `flutter build appbundle --release`
2. Upload เป็น Internal Testing
3. ติดตั้งจาก Play Store (Internal Testing track)
4. ทดสอบซื้อ

---

## 📊 Performance Optimization

### 1. Cache Energy Balance
```dart
// ใช้ StreamController เพื่อ real-time update
class EnergyService {
  final _balanceController = StreamController<int>.broadcast();
  Stream<int> get balanceStream => _balanceController.stream;
  
  Future<void> _updateBalance(int newBalance) async {
    await prefs.setInt(_keyBalance, newBalance);
    _balanceController.add(newBalance); // notify listeners
  }
}
```

### 2. Debounce API Calls
```dart
// ป้องกันการกดซ้ำๆ เร็วๆ
Timer? _debounce;

void analyzeWithDebounce() {
  if (_debounce?.isActive ?? false) _debounce!.cancel();
  _debounce = Timer(Duration(milliseconds: 300), () {
    // ทำจริง
    geminiService.analyzeFoodImage(...);
  });
}
```

---

## 🎓 Next Steps (Optional)

### Phase 11: Advanced Features

| Feature | Description | Priority |
|---------|-------------|----------|
| **Cloud Sync** | Sync energy across devices (Firestore) | Medium |
| **Analytics** | Track usage patterns (Mixpanel/Firebase) | High |
| **Rate Limiting** | Limit AI calls per minute | Medium |
| **Caching** | Cache common food results | Low |
| **Referral Program** | Get 50 Energy for each referral | Low |

---

## 📝 Summary for Junior

### What You Need to Do:

1. ✅ **Setup Backend** (Firebase Cloud Functions)
   - Create project
   - Deploy `analyze-food` function
   - Set secrets

2. ✅ **Create Configuration Files**
   - `beta_testers.dart` → เพิ่ม email list ของ beta testers (ดูคู่มือใน `BETA_TESTERS_SETUP.md`)

3. ✅ **Create Services** (Flutter)
   - `device_id_service.dart`
   - `energy_token_service.dart`
   - `energy_service.dart`
   - `welcome_offer_service.dart`

4. ✅ **Update Existing Files**
   - `gemini_service.dart` → call backend
   - `purchase_service.dart` → add energy products
   - All AI call points → check energy first

4. ✅ **Create UI**
   - `energy_badge.dart`
   - `no_energy_dialog.dart`
   - `energy_store_screen.dart`
   - `welcome_offer_dialog.dart` (optional)

5. ✅ **Remove BYOK**
   - Delete `api_key_screen.dart`
   - Remove from profile/onboarding

6. ✅ **Test Everything**
   - Backend API
   - Energy flow
   - Welcome gift
   - Welcome offer
   - IAP

7. ✅ **Deploy**
   - Deploy Edge Function
   - Build app
   - Upload to stores

---

## 🔐 Security Checklist

- [x] API key อยู่บน backend only (ไม่มีในแอป)
- [x] Energy token มี signature (HMAC-SHA256)
- [x] Token มี timestamp (expire ใน 5 นาที)
- [x] Device ID ผูกกับ welcome gift (ป้องกัน reinstall abuse)
- [x] Welcome offer ผูกกับ device + timestamp (ป้องกัน clock manipulation)
- [x] Backend validate token ทุกครั้งก่อน call Gemini
- [x] `.env` ไม่ commit ขึ้น git

---

## 📞 Support

ถ้ามีปัญหา:
1. ตรวจสอบ logs: `supabase functions logs analyze-food`
2. Debug token: `EnergyTokenService.decodeToken(token)`
3. ตรวจสอบ balance: `energyService.getBalance()`
4. ดู transaction history: `energyService.getTransactionHistory()`

---

**จบแล้ว! เริ่มเขียนโค้ดได้เลย 🚀**

> ถ้ามีข้อสงสัย ให้ถามก่อนเขียนนะ — แต่คู่มือนี้ควรครอบคลุมพอให้เขียนได้ครบแล้ว!
