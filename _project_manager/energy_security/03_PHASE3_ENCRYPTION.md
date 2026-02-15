# Phase 3: Token & Encryption Cleanup

> **🟡 Priority: HIGH** (แต่ไม่เร่งด่วนเท่า Phase 1-2)  
> **⏱️ Estimated Time: 0.5-1 วัน**  
> **🎯 Goal: ทำความสะอาด Token format และเข้ารหัส local storage**

---

## 📋 สารบัญ

- [Step 3.1: แก้ Token Format (ไม่มี balance)](#step-31-แก้-token-format-ไม่มี-balance)
- [Step 3.2: ย้าย Balance ไป FlutterSecureStorage เต็มรูปแบบ](#step-32-ย้าย-balance-ไป-fluttersecurestorage-เต็มรูปแบบ)
- [Step 3.3: ลบ Code เก่าที่ไม่ใช้](#step-33-ลบ-code-เก่าที่ไม่ใช้)
- [Testing](#testing)

---

## เป้าหมายของ Phase นี้

### ปัจจุบัน (หลัง Phase 1-2)

```
✅ Balance อยู่ใน Firestore (Server = Truth)
✅ Purchase verify แล้ว
⚠️ แต่ Token ยังมี balance อยู่ (ไม่ได้ใช้แล้ว แต่ยังอยู่)
⚠️ HMAC Secret ยังอยู่ใน APK
⚠️ Local storage ใช้ทั้ง SecureStorage และ SharedPreferences
```

### หลัง Phase 3

```
✅ Token ไม่มี balance (เหลือแค่ userId, timestamp, signature)
✅ Local storage ใช้ FlutterSecureStorage เป็นหลัก
✅ Code cleanup — ลบส่วนที่ไม่ใช้แล้ว
⚠️ HMAC Secret ยังอยู่ใน APK (ใช้เป็น app authentication)
   → ไม่อันตรายแล้ว เพราะ balance อยู่ Server
   → ถ้าต้องการ security สูงสุด → ทำ Phase 4 (App Check)
```

---

## Step 3.1: แก้ Token Format (ไม่มี balance)

### 3.1.1 Backend - แก้ verifyEnergyToken()

ไฟล์: `functions/src/analyzeFood.ts`

**ค้นหา function `verifyEnergyToken()`:**

```typescript
function verifyEnergyToken(token: string, secret: string) {
  try {
    const decoded = JSON.parse(
      Buffer.from(token, 'base64').toString('utf8')
    );
    
    const { userId, balance, timestamp, signature } = decoded;
    
    // Verify signature
    const payload = `${userId}:${balance}:${timestamp}`;
    const expectedSignature = generateHmac(payload, secret);
    
    if (signature !== expectedSignature) {
      return null;
    }
    
    // Check expiry (5 minutes)
    const now = Date.now();
    if (now - timestamp > 5 * 60 * 1000) {
      return null;
    }
    
    return { userId, balance, timestamp };
    
  } catch (error) {
    return null;
  }
}
```

**แก้เป็น: (รองรับทั้ง Token เก่า และ Token ใหม่)**

```typescript
/**
 * Verify Energy Token
 * 
 * ✅ PHASE 3: รองรับ 2 formats:
 * - Old format: { userId, balance, timestamp, signature }
 * - New format: { userId, timestamp, signature } ← ไม่มี balance
 * 
 * ⚠️ balance ใน token (ถ้ามี) จะถูก IGNORE
 * Backend อ่าน balance จาก Firestore เท่านั้น
 */
function verifyEnergyToken(token: string, secret: string) {
  try {
    const decoded = JSON.parse(
      Buffer.from(token, 'base64').toString('utf8')
    );
    
    const { userId, timestamp, signature } = decoded;
    
    // Validate required fields
    if (!userId || !timestamp || !signature) {
      console.log('❌ [verifyToken] Missing required fields');
      return null;
    }
    
    // ✅ PHASE 3: ไม่ต้องการ balance ใน token แล้ว
    // Token เก่าอาจจะมี balance, Token ใหม่ไม่มี
    const balance = decoded.balance; // อาจจะมีหรือไม่มีก็ได้
    
    // Verify signature
    let payload: string;
    if (balance !== undefined) {
      // Old token format (มี balance)
      payload = `${userId}:${balance}:${timestamp}`;
    } else {
      // New token format (ไม่มี balance)
      payload = `${userId}:${timestamp}`;
    }
    
    const expectedSignature = generateHmac(payload, secret);
    
    if (signature !== expectedSignature) {
      console.log('❌ [verifyToken] Invalid signature');
      return null;
    }
    
    // Check expiry (5 minutes)
    const now = Date.now();
    if (now - timestamp > 5 * 60 * 1000) {
      console.log('❌ [verifyToken] Token expired');
      return null;
    }
    
    console.log(`✅ [verifyToken] Valid token for user: ${userId}`);
    
    // ⚠️ Return balance as null — ไม่ใช้อีกต่อไป
    // Backend จะอ่านจาก Firestore แทน
    return { 
      userId, 
      balance: null, // IGNORED
      timestamp,
    };
    
  } catch (error) {
    console.log('❌ [verifyToken] Parse error:', error);
    return null;
  }
}
```

**✅ Checkpoint**: บันทึกแล้ว compile

```bash
cd functions
npm run build
```

---

### 3.1.2 Client - แก้ generateEnergyToken()

ไฟล์: `lib/core/services/energy_token_service.dart`

**ค้นหา method `generateToken()`:**

```dart
static Future<String> generateToken(int balance) async {
  final userId = await DeviceIdService.getDeviceId();
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  
  final payload = '$userId:$balance:$timestamp';
  final signature = _generateSignature(payload);
  
  final token = {
    'userId': userId,
    'balance': balance,  // ← ไม่ต้องการอีกแล้ว
    'timestamp': timestamp,
    'signature': signature,
  };
  
  return base64Encode(utf8.encode(json.encode(token)));
}
```

**แก้เป็น:**

```dart
/// สร้าง Energy Token สำหรับ authentication
/// 
/// ✅ PHASE 3: ไม่มี balance ใน token อีกต่อไป
/// Token ใช้เพื่อพิสูจน์ว่า request มาจากแอปของเราเท่านั้น
/// Backend จะอ่าน balance จาก Firestore เอง
static Future<String> generateToken() async {
  final userId = await DeviceIdService.getDeviceId();
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  
  // ✅ Payload ไม่มี balance แล้ว
  final payload = '$userId:$timestamp';
  final signature = _generateSignature(payload);
  
  final token = {
    'userId': userId,
    'timestamp': timestamp,
    'signature': signature,
    // ไม่มี balance อีกต่อไป
  };
  
  final encoded = base64Encode(utf8.encode(json.encode(token)));
  
  debugPrint('[EnergyTokenService] ✅ Token generated (no balance)');
  return encoded;
}
```

---

### 3.1.3 Client - แก้การเรียกใช้ generateToken()

**ค้นหาทุกที่ที่เรียก `generateToken(balance)`:**

ไฟล์: `lib/features/chat/services/gemini_chat_service.dart` หรือไฟล์ที่เรียก API

**เดิม:**

```dart
final balance = await energyService.getBalance();
final energyToken = await EnergyTokenService.generateToken(balance);
```

**ใหม่:**

```dart
// ✅ PHASE 3: ไม่ต้องส่ง balance อีกต่อไป
final energyToken = await EnergyTokenService.generateToken();
```

**ค้นหาและแก้ทุกที่:**

```bash
# ใช้ search in files (Ctrl+Shift+F)
# ค้นหา: generateToken(
# แก้ทุกที่จาก generateToken(balance) → generateToken()
```

---

### 3.1.4 Deploy Backend

```bash
cd functions
npm run build
cd ..
firebase deploy --only functions:analyzeFood
```

---

## Step 3.2: ย้าย Balance ไป FlutterSecureStorage เต็มรูปแบบ

ไฟล์: `lib/core/services/energy_service.dart`

### 3.2.1 ตรวจสอบว่า Phase 1 ทำแล้วหรือยัง

ถ้าทำ Phase 1 แล้ว → `getBalance()` และ `updateFromServerResponse()` ใช้ SecureStorage แล้ว

ถ้ายังไม่ทำ → ทำ Phase 1 ก่อน

### 3.2.2 เพิ่ม method migrateToSecureStorage()

**เพิ่ม method ใหม่:**

```dart
/// Migrate data จาก SharedPreferences → FlutterSecureStorage
/// เรียกครั้งเดียวตอน app startup
Future<void> migrateToSecureStorage() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    
    // ─── Migrate balance ───
    final balance = prefs.getInt(_keyBalance);
    if (balance != null) {
      // เช็คว่า SecureStorage มีหรือยัง
      final existing = await _secureStorage.read(key: _keyBalance);
      if (existing == null) {
        // ยังไม่มี → migrate
        await _secureStorage.write(
          key: _keyBalance,
          value: balance.toString(),
        );
        debugPrint('[EnergyService] 🔄 Migrated balance to SecureStorage: $balance');
      }
    }
    
    // ─── Migrate welcome gift flag ───
    final welcomeGift = prefs.getBool(_keyWelcomeGift);
    if (welcomeGift != null) {
      final existing = await _secureStorage.read(key: _keyWelcomeGift);
      if (existing == null) {
        await _secureStorage.write(
          key: _keyWelcomeGift,
          value: welcomeGift.toString(),
        );
        debugPrint('[EnergyService] 🔄 Migrated welcome gift flag');
      }
    }
    
    // ⚠️ ไม่ลบจาก SharedPreferences ทันที
    // เก็บไว้เป็น fallback สำหรับ user ที่ downgrade app
    
  } catch (e) {
    debugPrint('[EnergyService] ❌ Migration error: $e');
  }
}
```

---

### 3.2.3 เรียก migrateToSecureStorage ตอน app startup

ไฟล์: `lib/main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ... Firebase init
  
  final energyService = EnergyService();
  
  // ✅ PHASE 3: Migrate to SecureStorage
  await energyService.migrateToSecureStorage();
  
  // Phase 1: Sync balance
  await energyService.syncBalanceWithServer();
  
  // Phase 2: Retry pending purchases
  final purchaseService = PurchaseService();
  await purchaseService.initialize(energyService);
  await purchaseService.retryPendingPurchases();
  
  runApp(MyApp());
}
```

---

## Step 3.3: ลบ Code เก่าที่ไม่ใช้

### 3.3.1 ลบ addEnergy() ฝั่ง Client (ถ้ามี)

ไฟล์: `lib/core/services/energy_service.dart`

**ค้นหา method `addEnergy()`:**

```dart
Future<void> addEnergy(
  int amount, {
  required String type,
  String? purchaseToken,
}) async {
  final currentBalance = await getBalance();
  final newBalance = currentBalance + amount;
  await _updateBalance(newBalance);
  // ...
}
```

**⚠️ หลัง Phase 2 แล้ว method นี้ไม่ควรถูกเรียกจาก Client อีกแล้ว**

**ทำอย่างใดอย่างหนึ่ง:**

**Option 1: ลบทิ้ง (แนะนำ)**

```dart
// ลบ method addEnergy() ทั้งหมด
```

**Option 2: เปลี่ยนเป็น @deprecated (ถ้ายังมีที่เรียกอยู่)**

```dart
@Deprecated('Use server-side balance update instead (Phase 2)')
Future<void> addEnergy(
  int amount, {
  required String type,
  String? purchaseToken,
}) async {
  throw UnimplementedError(
    'addEnergy() is deprecated. Use updateFromServerResponse() instead.'
  );
}
```

---

### 3.3.2 ลบ deductEnergy() ฝั่ง Client (ถ้ามี)

**เหมือน addEnergy()** — หลัง Phase 1 แล้ว Client ไม่ควรหัก balance เอง

**ลบหรือ deprecate:**

```dart
@Deprecated('Balance is managed by server (Phase 1)')
Future<void> deductEnergy(int amount) async {
  throw UnimplementedError(
    'deductEnergy() is deprecated. Server manages balance via Firestore.'
  );
}
```

---

### 3.3.3 ลบ generateEnergyToken ที่ return Token ใหม่ (Backend)

ไฟล์: `functions/src/analyzeFood.ts`

**ค้นหา function `generateEnergyToken()`:**

```typescript
function generateEnergyToken(
  userId: string,
  balance: number,
  secret: string
): string {
  // ...
}
```

**เปลี่ยนเป็น @deprecated หรือลบ:**

```typescript
/**
 * @deprecated ไม่ใช้แล้วหลัง Phase 1
 * Backend ไม่ส่ง Token ใหม่กลับอีกต่อไป — ส่ง balance แทน
 */
function generateEnergyToken(
  userId: string,
  balance: number,
  secret: string
): string {
  throw new Error('generateEnergyToken is deprecated (Phase 1)');
}
```

**ลบการเรียกใช้ใน analyzeFood response:**

```typescript
// เดิม:
res.status(200).json({
  success: true,
  analysis: responseContent,
  energyToken: newToken,  // ← ลบบรรทัดนี้
  balance: newBalance,
});

// ใหม่:
res.status(200).json({
  success: true,
  analysis: responseContent,
  balance: newBalance,
  energyUsed: totalCost,
  // ไม่ส่ง energyToken อีกต่อไป
});
```

---

### 3.3.4 ลบ Transaction History ฝั่ง Client (optional)

ถ้ามี method `_saveTransaction()` ใน `energy_service.dart`:

```dart
Future<void> _saveTransaction({
  required String type,
  required int amount,
  required int balanceBefore,
  required int balanceAfter,
  String? purchaseToken,
}) async {
  // บันทึก transaction ใน SharedPreferences
  // ...
}
```

**ใน Phase ต่อไป → เก็บ transaction log ใน Firestore แทน**

**ตอนนี้:**
- ถ้ายังใช้อยู่ → เก็บไว้
- ถ้าไม่ใช้แล้ว → ลบ

---

## Testing

### Test Case 1: Token ใหม่ (ไม่มี balance)

**Steps:**
1. Update app ให้ใช้ Token format ใหม่
2. เรียก API (chat หรือ analyze food)

**คาดหวัง:**
- ✅ Token ที่ส่งไป ไม่มี field `balance`
- ✅ Backend verify สำเร็จ
- ✅ Backend อ่าน balance จาก Firestore
- ✅ Response ส่ง balance กลับ
- ✅ Client sync balance

---

### Test Case 2: Token เก่า (มี balance) ยังใช้ได้

**Setup:**
- Client version เก่า (ก่อน Phase 3) ยังมี balance ใน Token

**Steps:**
1. ส่ง request ด้วย Token เก่า

**คาดหวัง:**
- ✅ Backend verify สำเร็จ (backward compatible)
- ✅ Backend IGNORE balance ใน Token
- ✅ Backend อ่าน balance จาก Firestore แทน
- ✅ ทำงานปกติ

**→ Gradual rollout ทำได้ โดยไม่ break Client เก่า**

---

### Test Case 3: SecureStorage Migration

**Setup:**
- App version เก่ามี balance = 80 ใน SharedPreferences
- Update เป็น app version ใหม่

**Steps:**
1. เปิด app ครั้งแรก (หลัง update)
2. ตรวจสอบ balance

**คาดหวัง:**
- ✅ migrateToSecureStorage() ทำงาน
- ✅ Balance ถูก copy ไป SecureStorage
- ✅ UI แสดง balance = 80
- ✅ Console log: "🔄 Migrated balance to SecureStorage: 80"

---

### Test Case 4: ถ้า Client แก้ SecureStorage

**Setup:**
- User root เครื่องแล้วลอง decrypt SecureStorage (ยากมาก แต่เป็นไปได้)
- แก้ balance เป็น 9999

**Steps:**
1. เปิด app → UI อาจแสดง 9999 (cache)
2. ใช้ energy (chat หรือ analyze)

**คาดหวัง:**
- ✅ Backend อ่าน balance จาก Firestore (balance จริง)
- ✅ ถ้า balance จริง < cost → error 402
- ✅ หลังจากนั้น Client sync → UI แสดง balance จริง
- ✅ **Security ยังอยู่** (เพราะ Phase 1 = Server Truth)

---

### Test Case 5: addEnergy() / deductEnergy() ถูกเรียก (ถ้าเหลืออยู่)

**Setup:**
- Code เก่ามีที่เรียก `energyService.addEnergy(100)`

**Steps:**
1. Run app
2. Code เรียก addEnergy()

**คาดหวัง:**
- ✅ Throw Exception: "addEnergy() is deprecated..."
- ✅ หรือถ้าลบแล้ว → compile error
- ✅ **ต้องแก้ code ให้เรียก API แทน**

---

## Troubleshooting

### ปัญหา: Token verification ล้มเหลวหลังแก้

```
[verifyToken] Invalid signature
```

**สาเหตุ:**
- Client สร้าง signature จาก payload ใหม่: `userId:timestamp`
- แต่ Backend ยังตรวจจาก payload เก่า: `userId:balance:timestamp`

**แก้:**
ตรวจสอบว่า Backend verify รองรับทั้ง 2 format แล้วหรือยัง (Step 3.1.1)

---

### ปัญหา: SecureStorage ไม่ทำงานบน Android

```
PlatformException: read_error
```

**สาเหตุ:**
- Android < 6.0 ไม่รองรับ Keystore
- Emulator บางตัวไม่มี secure hardware

**แก้:**
1. ใช้ `AndroidOptions` ใน FlutterSecureStorage:

```dart
final _secureStorage = FlutterSecureStorage(
  aOptions: const AndroidOptions(
    encryptedSharedPreferences: true, // fallback สำหรับ Android เก่า
  ),
);
```

2. หรือ fallback ไป SharedPreferences (แต่ไม่ปลอดภัยเท่า)

---

### ปัญหา: Migration ไม่ทำงาน

**Debug:**
1. ตรวจสอบว่า `migrateToSecureStorage()` ถูกเรียกใน main() หรือไม่
2. ตรวจสอบ console log: "🔄 Migrated balance..."
3. ตรวจสอบว่า balance อยู่ใน SharedPreferences หรือเปล่า

---

## Checklist Phase 3

- [ ] Step 3.1: Token Format ✅
  - [ ] Backend verifyEnergyToken() รองรับ token ใหม่ (ไม่มี balance)
  - [ ] Backend รองรับ token เก่า (backward compatible)
  - [ ] Client generateToken() ไม่มี balance แล้ว
  - [ ] ทุกที่ที่เรียก generateToken() แก้แล้ว (ไม่ส่ง balance)
  - [ ] Backend deploy แล้ว
- [ ] Step 3.2: SecureStorage ✅
  - [ ] migrateToSecureStorage() เพิ่มแล้ว
  - [ ] เรียกใน main.dart แล้ว
  - [ ] getBalance() อ่านจาก SecureStorage เป็นหลัก
  - [ ] updateFromServerResponse() เขียนไป SecureStorage
- [ ] Step 3.3: Cleanup ✅
  - [ ] addEnergy() ลบหรือ deprecate แล้ว
  - [ ] deductEnergy() ลบหรือ deprecate แล้ว
  - [ ] generateEnergyToken() (Backend) ลบหรือ deprecate แล้ว
  - [ ] Response ไม่ส่ง energyToken อีกต่อไป (ส่ง balance แทน)
- [ ] Testing ✅
  - [ ] Test Case 1: Token ใหม่ทำงาน
  - [ ] Test Case 2: Token เก่ายังใช้ได้
  - [ ] Test Case 3: Migration ทำงาน
  - [ ] Test Case 4: แก้ SecureStorage ไม่มีผล (Server Truth)
  - [ ] Test Case 5: addEnergy deprecated

---

## สรุป Phase 3

**✅ สำเร็จ:**
- Token ไม่มี balance แล้ว (เหลือแค่ identity)
- Local storage เข้ารหัสด้วย FlutterSecureStorage
- Code cleanup — ลบส่วนที่ไม่ใช้แล้ว

**⚠️ HMAC Secret ยังอยู่ใน APK:**
- ✅ **ไม่อันตรายแล้ว** เพราะ:
  - Token ไม่มี balance
  - Backend อ่าน balance จาก Firestore
  - ปลอม Token ได้แต่ไม่มีประโยชน์
- ✅ Secret ใช้เป็น **app authentication** เท่านั้น
- 🎯 ถ้าต้องการ security สูงสุด → ทำ Phase 4 (Firebase App Check)

---

## Next Step

**✅ Phase 3 เสร็จแล้ว!**

**Security Status หลัง Phase 1-2-3:**

| Attack Vector | Status |
|--------------|--------|
| Client แก้ balance | ✅ FIXED (Server = Truth) |
| Token forgery | ✅ FIXED (Token ไม่มี balance) |
| Purchase ปลอม | ✅ FIXED (Server verify) |
| Duplicate purchase | ✅ FIXED (purchase_records) |
| APK decompile → Secret | ⚠️ ยังได้ Secret แต่ไม่อันตราย |
| Token replay (5 min) | 🟡 ยังมี แต่ต้องหัก balance จริง |

**🔜 Next (Optional): Phase 4 — Firebase App Check**

อ่านไฟล์: `04_PHASE4_APPCHECK.md`

หรือ **ถ้าพอใจกับ security ระดับนี้แล้ว → เสร็จสิ้น! 🎉**

---

*Phase 3 Completed ✅*  
*Version: 1.0*
