# Phase 4: Firebase App Check (Optional)

> **🟢 Priority: NICE-TO-HAVE** (ไม่จำเป็นถ้า Phase 1-3 ทำแล้ว)  
> **⏱️ Estimated Time: 0.5 วัน**  
> **🎯 Goal: ป้องกัน Bot/Script attacks ด้วย Google Play Integrity**

---

## 📋 สารบัญ

- [What is Firebase App Check?](#what-is-firebase-app-check)
- [Step 4.1: Setup Firebase App Check](#step-41-setup-firebase-app-check)
- [Step 4.2: Client Integration](#step-42-client-integration)
- [Step 4.3: Backend Enforcement](#step-43-backend-enforcement)
- [Testing](#testing)

---

## What is Firebase App Check?

### ปัญหาที่เหลืออยู่หลัง Phase 1-3

```
✅ Balance อยู่ Server (Firestore)
✅ Purchase verify กับ Google Play
✅ Token ไม่มี balance
⚠️ แต่ถ้ามี Hacker:
   1. Decompile APK → ได้ HMAC Secret
   2. สร้าง Script/Bot ยิง API ซ้ำๆ ด้วย valid token
   3. ทำให้ Server โดน spam
```

**Firebase App Check แก้ปัญหานี้:**

```
Client:
  ├── Google Play Integrity API (Android)
  ├── DeviceCheck API (iOS)
  └── รับ App Check Token จาก Firebase
         ↓
Backend:
  ├── ตรวจ App Check Token
  ├── Verify ว่า request มาจาก:
  │   - แอปจริงๆ (ไม่ใช่ script)
  │   - Device จริงๆ (ไม่ใช่ emulator/rooted)
  │   - Package name ถูกต้อง
  └── ถ้าผ่าน → อนุญาต
```

---

## ข้อดี/ข้อเสีย

### ✅ ข้อดี

- ป้องกัน Bot/Script (ต้องใช้ device จริง)
- ป้องกัน API abuse (spam requests)
- Google จัดการ key ให้ (ไม่ต้อง hardcode secret)
- ทำงานร่วมกับ Play Integrity API (detect rooted device)

### ❌ ข้อเสีย

- เพิ่ม latency (~200-500ms ต่อ request)
- ต้องใช้ Google Play Services (ไม่รองรับ Huawei, China ROM)
- Quota จำกัด (10,000 verifications/day สำหรับ free tier)
- Debug ยากขึ้น (ต้องมี SHA-256 fingerprint ของ debug key)

---

## เมื่อไหร่ควรใช้ App Check?

### ✅ ใช้ถ้า:

- เป็น production app ที่มี user เยอะ
- เคยโดน abuse/spam API
- ต้องการ security สูงสุด
- ยอมเสีย latency เพิ่มเล็กน้อย

### ❌ ไม่จำเป็นถ้า:

- เป็น app เล็กๆ หรือ beta
- User ไม่เยอะ
- Phase 1-3 ป้องกันได้เพียงพอแล้ว
- ต้องการ performance สูงสุด

---

## Step 4.1: Setup Firebase App Check

### 4.1.1 เปิด App Check ใน Firebase Console

1. ไป https://console.firebase.google.com
2. เลือก project `miro`
3. ไปที่ **Build** → **App Check** (เมนูซ้าย)
4. คลิก **Get started**

---

### 4.1.2 Register App (Android)

1. ใน App Check page → เลือก Android app
2. คลิก **Register**

**Provider Options:**
- **Play Integrity** (แนะนำ, production)
- **SafetyNet** (deprecated, ใช้ถ้า device เก่า)
- **Debug provider** (สำหรับ development)

**เลือก: Play Integrity**

3. คลิก **Save**

---

### 4.1.3 Enable App Check สำหรับ Cloud Functions

ใน App Check page:

1. ไปที่ tab **APIs**
2. หา **Cloud Functions for Firebase**
3. คลิก **Enforce** หรือ **Unenforced**

**Options:**
- **Enforce**: บังคับต้องมี App Check token (แนะนำสำหรับ production)
- **Unenforced**: ไม่บังคับแต่ log metrics (แนะนำสำหรับ testing)

**เลือก: Unenforced** (ตอน development/testing)

→ จะเปลี่ยนเป็น Enforce ตอน production

---

### 4.1.4 Setup Debug Token (สำหรับ Development)

**เมื่อ develop ใน debug mode ต้องมี debug token:**

ไฟล์: `lib/main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // ✅ PHASE 4: Firebase App Check
  if (kDebugMode) {
    // Debug mode: ใช้ debug provider
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
    );
  } else {
    // Production: ใช้ Play Integrity
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity,
    );
  }
  
  // ... rest of initialization
  runApp(MyApp());
}
```

**Run app ใน debug mode:**

```bash
flutter run
```

**ดู Console log:**

```
D/FirebaseAppCheck: [PlayIntegrityProvider] App Check debug token: 
XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
```

**Copy debug token นั้น**

---

### 4.1.5 Add Debug Token ใน Firebase Console

1. ไปที่ Firebase Console → App Check
2. คลิก **Manage debug tokens** (มุมบนขวา)
3. คลิก **Add debug token**
4. Paste token ที่ copy มา
5. ใส่ชื่อ (เช่น "Dev Machine - Windows")
6. คลิก **Done**

**ตอนนี้ debug build จะผ่าน App Check แล้ว ✅**

---

## Step 4.2: Client Integration

### 4.2.1 เพิ่ม dependencies

ไฟล์: `pubspec.yaml`

```yaml
dependencies:
  firebase_core: ^3.10.0
  firebase_app_check: ^0.3.2+2  # ← เพิ่มบรรทัดนี้
  # ... dependencies อื่นๆ
```

**Install:**

```bash
flutter pub get
```

---

### 4.2.2 Initialize App Check

ไฟล์: `lib/main.dart`

```dart
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart'; // for kDebugMode

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // ===================================================================
  // ✅ PHASE 4: Firebase App Check
  // ===================================================================
  await FirebaseAppCheck.instance.activate(
    // Android
    androidProvider: kDebugMode
        ? AndroidProvider.debug          // Debug: ใช้ debug token
        : AndroidProvider.playIntegrity, // Production: ใช้ Play Integrity
    
    // iOS (ถ้ามี)
    appleProvider: kDebugMode
        ? AppleProvider.debug            // Debug: ใช้ debug token
        : AppleProvider.deviceCheck,     // Production: ใช้ DeviceCheck
  );
  
  debugPrint('[Main] ✅ Firebase App Check activated');
  
  // ... rest of initialization (EnergyService, PurchaseService, etc.)
  
  runApp(MyApp());
}
```

---

### 4.2.3 อัพเดท API calls (optional — automatic)

**App Check token จะถูกส่งไปอัตโนมัติ!**

ถ้าใช้ `firebase_functions` package → token จะถูกแนบใน header `X-Firebase-AppCheck`

ถ้าใช้ `http` package → ต้องเพิ่มเองทุก request

**ตัวอย่าง (ถ้าใช้ http package):**

```dart
Future<http.Response> _callAPI() async {
  // ดึง App Check token
  final appCheckToken = await FirebaseAppCheck.instance.getToken();
  
  final response = await http.post(
    Uri.parse('https://...'),
    headers: {
      'Content-Type': 'application/json',
      'X-Firebase-AppCheck': appCheckToken ?? '',  // ← เพิ่มบรรทัดนี้
    },
    body: jsonEncode({...}),
  );
  
  return response;
}
```

---

## Step 4.3: Backend Enforcement

### 4.3.1 อัพเดท Cloud Functions

ไฟล์: `functions/src/analyzeFood.ts`

```typescript
import { onRequest } from 'firebase-functions/v2/https';

export const analyzeFood = onRequest(
  {
    // ... options อื่นๆ
    
    // ✅ PHASE 4: Enforce App Check
    consumeAppCheckToken: true,  // ← เพิ่มบรรทัดนี้
  },
  async (req, res) => {
    // ถ้า consumeAppCheckToken: true
    // Firebase จะตรวจ App Check token อัตโนมัติ
    // ถ้าไม่ผ่าน → return 401 Unauthorized ทันที
    
    // Code ด้านล่างจะทำงานก็ต่อเมื่อ App Check ผ่านแล้วเท่านั้น
    
    try {
      // ... existing code
    } catch (error) {
      // ...
    }
  }
);
```

**ทำซ้ำกับทุก Cloud Function:**
- `syncBalance.ts` → เพิ่ม `consumeAppCheckToken: true`
- `verifyPurchase.ts` → เพิ่ม `consumeAppCheckToken: true`

---

### 4.3.2 Manual Verification (ถ้าต้องการ custom logic)

```typescript
import { getAppCheck } from 'firebase-admin/app-check';

export const analyzeFood = onRequest(
  {
    // ไม่ใช้ consumeAppCheckToken (manual verify)
  },
  async (req, res) => {
    try {
      // ─── Manual App Check Verification ───
      const appCheckToken = req.header('X-Firebase-AppCheck');
      
      if (!appCheckToken) {
        console.log('❌ [AppCheck] No token provided');
        res.status(401).json({ error: 'App Check token required' });
        return;
      }
      
      try {
        const appCheckClaims = await getAppCheck().verifyToken(appCheckToken);
        console.log('✅ [AppCheck] Verified:', appCheckClaims.app_id);
        
        // Optional: ตรวจเพิ่มเติม
        if (appCheckClaims.app_id !== 'YOUR_APP_ID') {
          throw new Error('Invalid app ID');
        }
        
      } catch (error) {
        console.log('❌ [AppCheck] Verification failed:', error);
        res.status(401).json({ error: 'Invalid App Check token' });
        return;
      }
      
      // ─── Continue with normal flow ───
      // ... existing code
      
    } catch (error) {
      // ...
    }
  }
);
```

---

### 4.3.3 Deploy Backend

```bash
cd functions
npm run build
cd ..
firebase deploy --only functions
```

---

## Testing

### Test Case 1: Debug Build (มี debug token)

**Setup:**
- Debug token เพิ่มใน Firebase Console แล้ว
- App run ใน debug mode

**Steps:**
1. เปิด app (debug build)
2. เรียก API (chat, analyze, purchase)

**คาดหวัง:**
- ✅ API calls สำเร็จ
- ✅ Backend logs ไม่มี App Check error
- ✅ ทำงานปกติ

---

### Test Case 2: Release Build (ใช้ Play Integrity)

**Setup:**
- Build release APK
- ติดตั้งบน device จริง (ไม่ใช่ emulator)

**Steps:**
1. Build release:
   ```bash
   flutter build apk --release
   ```
2. Install APK
3. เปิด app
4. เรียก API

**คาดหวัง:**
- ✅ API calls สำเร็จ
- ✅ Play Integrity verify ผ่าน
- ✅ Backend logs: "✅ [AppCheck] Verified"

---

### Test Case 3: Script/Bot (ไม่มี App Check token)

**Setup:**
- สร้าง script ยิง API ตรงๆ (ไม่ผ่าน app)

```bash
curl -X POST https://us-central1-miro-xxxxx.cloudfunctions.net/analyzeFood \
  -H "Content-Type: application/json" \
  -d '{...}'
```

**คาดหวัง:**
- ❌ Response: 401 Unauthorized
- ❌ `{ error: "Unauthenticated" }`
- ✅ Backend logs: "[AppCheck] No token provided"
- ✅ **Bot ถูกบล็อก!**

---

### Test Case 4: Rooted Device / Emulator

**Setup:**
- ใช้ device ที่ root แล้ว
- หรือ emulator

**Steps:**
1. Build release APK
2. Install บน rooted device
3. เปิด app
4. เรียก API

**คาดหวัง:**
- ⚠️ Play Integrity อาจ return `MEETS_BASIC_INTEGRITY` แทน `MEETS_STRONG_INTEGRITY`
- ถ้า enforce strict → อาจถูกบล็อก
- ถ้า enforce basic → ยังใช้ได้

**ปรับแต่ง:**
ใน Firebase Console → App Check → Settings:
- **Enforcement level**: Basic / Strong

---

### Test Case 5: App Check Metrics

**Firebase Console:**
1. ไปที่ App Check page
2. ดู **Metrics** tab

**ตรวจสอบ:**
- ✅ Total verifications
- ✅ Success rate
- ⚠️ Failed verifications (ถ้ามีเยอะ → มี bot พยายามเข้า)

---

## Troubleshooting

### ปัญหา: Debug build ไม่ผ่าน App Check

```
401 Unauthenticated
```

**แก้:**
1. ตรวจสอบ debug token ใน Firebase Console
2. ตรวจสอบ console log: มี "App Check debug token: ..." หรือไม่
3. ตรวจสอบว่า `AndroidProvider.debug` ใช้ใน debug mode
4. Restart app

---

### ปัญหา: Release build ไม่ผ่าน App Check

```
Play Integrity API error
```

**แก้:**
1. ตรวจสอบ SHA-256 fingerprint:
   ```bash
   keytool -list -v -keystore android/app/your-release-key.jks
   ```
2. เพิ่ม SHA-256 ใน Firebase Console → Project settings → Your apps → Android
3. ตรวจสอบ package name ตรงกัน
4. รอ ~10 นาที หลังเพิ่ม (Google propagate)

---

### ปัญหา: Quota exceeded

```
QUOTA_EXCEEDED
```

**สาเหตุ:**
- Free tier: 10,000 verifications/day
- เกิน quota แล้ว

**แก้:**
1. Upgrade เป็น Blaze plan
2. ลด frequency ของ API calls
3. ใช้ cache (App Check token valid 1 hour)

---

### ปัญหา: เพิ่ม latency มาก

**Debug:**
1. วัด latency:
   ```dart
   final start = DateTime.now();
   final token = await FirebaseAppCheck.instance.getToken();
   final duration = DateTime.now().difference(start);
   print('App Check latency: ${duration.inMilliseconds}ms');
   ```

2. ถ้า > 1000ms → มีปัญหา

**แก้:**
- ใช้ token cache (automatic ใน SDK)
- ตรวจสอบ network connection
- ลอง SafetyNet แทน Play Integrity (เร็วกว่า)

---

## Alternative: Custom Verification

ถ้าไม่อยากใช้ Firebase App Check แต่อยากป้องกัน bot:

### Option 1: Rate Limiting

```typescript
// Backend: ใช้ Redis หรือ Firestore
const RATE_LIMIT = 10; // requests per minute
const deviceId = req.body.deviceId;

const requests = await countRequests(deviceId, '1m');
if (requests > RATE_LIMIT) {
  res.status(429).json({ error: 'Too many requests' });
  return;
}
```

### Option 2: Device Fingerprinting

```typescript
// Client: ส่ง device info
const fingerprint = {
  deviceId,
  model: await deviceInfoPlugin.model,
  osVersion: await deviceInfoPlugin.version,
  screenSize: MediaQuery.of(context).size,
};

// Backend: เช็คว่า fingerprint เปลี่ยนบ่อยเกินไปหรือเปล่า
```

### Option 3: Challenge-Response

```typescript
// Backend: สร้าง challenge
const challenge = crypto.randomBytes(32).toString('hex');
await redis.set(`challenge:${deviceId}`, challenge, 'EX', 60);

// Client: แก้ challenge (เช่น hash กับ timestamp)
const response = sha256(challenge + timestamp);

// Backend: verify
const expected = await redis.get(`challenge:${deviceId}`);
if (sha256(expected + timestamp) !== response) {
  throw new Error('Invalid challenge');
}
```

---

## Checklist Phase 4

- [ ] Step 4.1: Setup Firebase App Check ✅
  - [ ] เปิด App Check ใน Firebase Console
  - [ ] Register Android app (Play Integrity)
  - [ ] Enable Cloud Functions enforcement (Unenforced)
  - [ ] Add debug token
- [ ] Step 4.2: Client Integration ✅
  - [ ] firebase_app_check package เพิ่มแล้ว
  - [ ] Initialize App Check ใน main.dart
  - [ ] Debug provider สำหรับ debug build
  - [ ] Play Integrity สำหรับ release build
- [ ] Step 4.3: Backend Enforcement ✅
  - [ ] analyzeFood: consumeAppCheckToken: true
  - [ ] syncBalance: consumeAppCheckToken: true
  - [ ] verifyPurchase: consumeAppCheckToken: true
  - [ ] Deploy สำเร็จ
- [ ] Testing ✅
  - [ ] Test Case 1: Debug build ผ่าน
  - [ ] Test Case 2: Release build ผ่าน
  - [ ] Test Case 3: Bot/Script ถูกบล็อก
  - [ ] Test Case 4: Rooted device behavior
  - [ ] Test Case 5: Metrics ใน Console

---

## สรุป Phase 4

**✅ หลังทำ Phase 4:**

```
Security Levels:

Phase 1: Server-side Balance
  → ป้องกัน: Client แก้ balance, Token forgery
  → ระดับ: CRITICAL FIXED

Phase 2: Purchase Verification
  → ป้องกัน: ซื้อปลอม, Duplicate purchase
  → ระดับ: CRITICAL FIXED

Phase 3: Token & Encryption
  → ป้องกัน: APK decompile (แต่ไม่อันตรายแล้ว)
  → ระดับ: HIGH IMPROVED

Phase 4: Firebase App Check
  → ป้องกัน: Bot/Script attacks, API abuse
  → ระดับ: NICE-TO-HAVE
```

**Final Security Status:**

| Attack Vector | Status |
|--------------|--------|
| Client แก้ balance | ✅ FIXED (Phase 1) |
| Token forgery | ✅ FIXED (Phase 1) |
| Purchase ปลอม | ✅ FIXED (Phase 2) |
| Duplicate purchase | ✅ FIXED (Phase 2) |
| APK decompile | ✅ MITIGATED (Phase 3) |
| Bot/Script attacks | ✅ FIXED (Phase 4) |
| Token replay | 🟢 LOW RISK |
| Rooted device | 🟢 DETECTED (Play Integrity) |

**🎉 System ปลอดภัยระดับ Enterprise แล้ว!**

---

## ควรทำ Phase 4 หรือไม่?

### ✅ ทำถ้า:

- App มี user เยอะ (> 10,000 DAU)
- เคยโดน abuse/spam
- เป็น app ที่มี revenue
- ต้องการ security สูงสุด

### ❌ ข้าม Phase 4 ถ้า:

- App เล็กๆ หรือ MVP
- Phase 1-3 ครอบคลุมเพียงพอแล้ว
- ไม่อยากเสีย latency
- Google Play Services ไม่พร้อม (Huawei, etc.)

**คำแนะนำ:**
- เริ่มด้วย **Unenforced** (log metrics only)
- ดู metrics 1-2 สัปดาห์
- ถ้าเห็น abuse → เปลี่ยนเป็น **Enforce**

---

## เสร็จสิ้น! 🎉

**ขั้นตอนทั้งหมด:**

```
✅ Phase 1: Firestore Balance (CRITICAL)
✅ Phase 2: Purchase Verification (CRITICAL)
✅ Phase 3: Token & Encryption (HIGH)
✅ Phase 4: Firebase App Check (OPTIONAL)
```

**ระบบ Energy ของคุณปลอดภัยแล้ว!**

---

*Phase 4 Completed ✅*  
*All Phases Completed! 🎉*  
*Version: 1.0*
