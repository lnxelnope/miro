# Testing Checklist

> **เอกสารนี้รวบรวม Test Cases ทั้งหมดสำหรับทุก Phase**  
> **ใช้เป็น Checklist หลังทำแต่ละ Phase เสร็จ**

---

## 📋 วิธีใช้เอกสารนี้

### สำหรับแต่ละ Phase:

1. ✅ ทำ Phase ตามเอกสาร (01, 02, 03, 04)
2. ✅ กลับมาที่เอกสารนี้
3. ✅ ทำ Test Cases ทั้งหมดของ Phase นั้น
4. ✅ เช็ค checkbox ✅ เมื่อผ่านแต่ละ test
5. ✅ ถ้าผ่านทั้งหมด → Phase สำเร็จ!

---

## Phase 1: Firestore Balance Testing

### Pre-test Setup

- [ ] Firestore rules deployed
- [ ] Backend deployed (analyzeFood, syncBalance)
- [ ] Client updated (EnergyService)
- [ ] Firebase Console เปิดไว้ (ดู Firestore real-time)

---

### Test 1.1: New User (Welcome Gift)

**Objective:** ตรวจสอบว่า user ใหม่ได้ welcome gift

**Steps:**
1. Uninstall app
2. Install app ใหม่
3. เปิด app ครั้งแรก
4. ตรวจสอบ UI แสดง balance

**Expected:**
- [ ] Balance = 100
- [ ] Console log: "🎁 New user {deviceId}: Welcome gift 100"
- [ ] Firebase Console → `energy_balances/{deviceId}`:
  - `balance: 100`
  - `welcomeGiftClaimed: true`
  - มี `createdAt` timestamp

**Notes:**

---

### Test 1.2: Existing User (Migration)

**Objective:** User เก่าที่มี balance ใน local ถูก migrate

**Setup:**
1. ติดตั้ง app version เก่า (ก่อน Phase 1)
2. ใช้ energy จน balance = 50
3. Update เป็น version ใหม่

**Steps:**
1. เปิด app (version ใหม่)
2. ตรวจสอบ balance

**Expected:**
- [ ] Balance = 50 (ค่าเดิม)
- [ ] Console log: "🔄 Migrated {deviceId}: 50 from local"
- [ ] Firebase Console → มี document พร้อม:
  - `balance: 50`
  - `migratedFrom: 'local_storage'`
  - มี `migratedAt` timestamp

**Notes:**

---

### Test 1.3: ใช้ Energy (Chat ไม่มีรูป)

**Setup:** User มี balance = 100

**Steps:**
1. Chat กับ AI (ไม่แนบรูป)
2. ส่งข้อความ
3. ตรวจสอบ balance หลังได้ response

**Expected:**
- [ ] Response สำเร็จ (ได้คำตอบจาก AI)
- [ ] Balance = 99 (หัก 1)
- [ ] Backend log: "💰 [Firestore] ... - 1 = 99"
- [ ] Firebase Console → balance อัพเดทเป็น 99
- [ ] UI แสดง balance 99

**Notes:**

---

### Test 1.4: ใช้ Energy (Chat มีรูป)

**Setup:** User มี balance = 100

**Steps:**
1. Chat กับ AI พร้อมแนบรูปอาหาร
2. ส่งข้อความ
3. ตรวจสอบ balance

**Expected:**
- [ ] Response สำเร็จ
- [ ] Balance = 98 (หัก 2: base 1 + image 1)
- [ ] Backend log: "💰 [Firestore] ... - 2 = 98"
- [ ] Firebase Console → balance = 98

**Notes:**

---

### Test 1.5: Insufficient Balance

**Setup:** User มี balance = 1

**Steps:**
1. พยายาม Chat พร้อมรูป (cost = 2)

**Expected:**
- [ ] Error: 402 Insufficient energy
- [ ] Balance ยังคง = 1 (ไม่ถูกหัก)
- [ ] Backend log: "❌ Insufficient balance: have 1, need 2"
- [ ] UI แสดง error message / popup ซื้อ energy

**Notes:**

---

### Test 1.6: Security - Client แก้ balance

**Objective:** ✨ TEST ที่สำคัญที่สุดของ Phase 1

**Setup:**
1. Root device Android หรือใช้ root explorer
2. แก้ SharedPreferences: `energy_balance = 9999`
3. Restart app

**Steps:**
1. UI อาจแสดง balance = 9999 (cache)
2. ลองใช้ energy (chat)

**Expected:**
- [ ] Backend อ่าน balance จาก Firestore (ค่าจริง)
- [ ] ถ้า balance จริง < cost → error 402
- [ ] ถ้า balance จริง >= cost → สำเร็จ แต่หักจาก Firestore
- [ ] หลังจากนั้น UI sync จาก server → แสดง balance จริง
- [ ] ✅ **SECURITY FIX ทำงาน!**

**Notes:**

---

### Test 1.7: Concurrent Requests

**Objective:** ตรวจสอบว่าไม่เกิด race condition

**Setup:** User มี balance = 10

**Tools:** ใช้ Postman / script ส่ง 2 requests พร้อมกัน

**Steps:**
1. ส่ง request 1: chat (cost = 1)
2. ส่ง request 2: chat with image (cost = 2) **พร้อมกัน**
3. ตรวจสอบ balance สุดท้าย

**Expected:**
- [ ] ทั้ง 2 requests สำเร็จ
- [ ] Balance = 7 (10 - 1 - 2)
- [ ] ไม่มี balance ผิดพลาด (เช่น 8 หรือ 9)
- [ ] ✅ Firestore Transaction ป้องกัน race condition

**Notes:**

---

### Phase 1 Summary

**ผ่านทั้งหมด?**
- [ ] ✅ Test 1.1: New user
- [ ] ✅ Test 1.2: Migration
- [ ] ✅ Test 1.3: ใช้ energy (ไม่มีรูป)
- [ ] ✅ Test 1.4: ใช้ energy (มีรูป)
- [ ] ✅ Test 1.5: Insufficient balance
- [ ] ✅ Test 1.6: Security - Client แก้ balance
- [ ] ✅ Test 1.7: Concurrent requests

**ถ้าผ่านทั้งหมด → Phase 1 สำเร็จ! ✅**

---

## Phase 2: Purchase Verification Testing

### Pre-test Setup

- [ ] Google Play Developer API setup
- [ ] Service Account added to Play Console
- [ ] Backend deployed (verifyPurchase)
- [ ] Client PurchaseService updated
- [ ] มี Test card หรือ License testing account

---

### Test 2.1: Real Purchase (Testing Account)

**Objective:** ซื้อด้วย license testing account

**Setup:**
1. เพิ่ม email ใน Play Console → License testing
2. Login ด้วย email นั้น

**Steps:**
1. เปิด app
2. ไปหน้า Purchase
3. กดซื้อ "550 Energy"
4. ชำระเงิน (ไม่มี charge จริง สำหรับ testing)
5. รอ verification

**Expected:**
- [ ] Google Play: Purchase successful
- [ ] Backend log: "🛒 [verifyPurchase] Request: energy_550 for {deviceId}"
- [ ] Backend log: "✅ [verifyPurchase] Success: ... (+550) → {newBalance}"
- [ ] Firebase Console → `purchase_records` มี document:
  - `productId: energy_550`
  - `energyAmount: 550`
  - `status: verified`
  - มี `orderId` จาก Google Play
- [ ] Firebase Console → `energy_balances/{deviceId}` balance เพิ่ม 550
- [ ] Client UI: Balance อัพเดท
- [ ] แสดง success message

**Notes:**

---

### Test 2.2: Duplicate Purchase

**Objective:** ใช้ purchase token ซ้ำ → ต้องถูกบล็อก

**Setup:** ดึง purchaseToken จาก Test 2.1

**Tools:** Postman / curl

**Steps:**

```bash
curl -X POST https://us-central1-miro-xxxxx.cloudfunctions.net/verifyPurchase \
  -H "Content-Type: application/json" \
  -d '{
    "purchaseToken": "...",
    "productId": "energy_550",
    "deviceId": "test-device"
  }'
```

**Expected:**
- [ ] Response: 409 Conflict
- [ ] Body: `{ error: "Purchase already verified", balance: xxx, verified: true }`
- [ ] Balance ไม่เปลี่ยน (ไม่เพิ่ม 550 อีก)
- [ ] Backend log: "⚠️ [verifyPurchase] Duplicate purchase"

**Notes:**

---

### Test 2.3: Invalid Purchase Token

**Objective:** Token ปลอม → ต้อง reject

**Steps:**

```bash
curl -X POST ... \
  -d '{ "purchaseToken": "fake-token-123", "productId": "energy_550", "deviceId": "test" }'
```

**Expected:**
- [ ] Response: 403 Forbidden
- [ ] Body: `{ error: "Invalid purchase token" }`
- [ ] Balance ไม่เปลี่ยน
- [ ] Backend log: Google Play API error

**Notes:**

---

### Test 2.4: Canceled Purchase

**Objective:** Purchase ที่ refund แล้ว → ไม่ควรได้ energy

**Setup:**
1. ซื้อ energy
2. Refund ใน Play Console ทันที
3. ส่ง verify request

**Expected:**
- [ ] Response: 403 Forbidden
- [ ] Body: `{ error: "Purchase not completed", purchaseState: 1 }`
- [ ] Balance ไม่เปลี่ยน
- [ ] Backend log: "❌ Purchase not completed: state=1"

**Notes:**

---

### Test 2.5: Network Timeout & Retry

**Objective:** ถ้า verify ไม่ได้ (network issue) → retry ทีหลัง

**Steps:**
1. ซื้อ energy
2. ปิด internet ขณะ verify
3. เปิด internet กลับมา
4. Restart app

**Expected:**
- [ ] Purchase บันทึกใน `pending_purchases` (SharedPreferences)
- [ ] ตอน app startup → `retryPendingPurchases()` ทำงาน
- [ ] Retry สำเร็จ → balance อัพเดท
- [ ] Pending purchase ถูกลบออก
- [ ] Console log: "🔄 Retrying ... pending purchases"

**Notes:**

---

### Test 2.6: Firestore Structure

**Objective:** ตรวจสอบ data structure ถูกต้อง

**Expected Structure:**

```
/energy_balances/{deviceId}
  balance: 650
  lastUpdated: [timestamp]
  createdAt: [timestamp]

/purchase_records/{purchaseToken_hash}
  deviceId: "abc123"
  productId: "energy_550"
  energyAmount: 550
  purchaseTokenPreview: "AEuhp4iXFJRZDT..." (first 20 chars)
  verifiedAt: [timestamp]
  orderId: "GPA.1234-5678-9012-34567"
  purchaseTimeMillis: 1707988800000
  status: "verified"
```

**Check:**
- [ ] `energy_balances` มี document
- [ ] `balance` เป็น number
- [ ] มี timestamp fields
- [ ] `purchase_records` มี document
- [ ] `purchaseTokenPreview` ไม่เก็บ token เต็มๆ
- [ ] มี `orderId` จาก Google Play
- [ ] `status === "verified"`

**Notes:**

---

### Phase 2 Summary

**ผ่านทั้งหมด?**
- [ ] ✅ Test 2.1: Real purchase (testing account)
- [ ] ✅ Test 2.2: Duplicate purchase → blocked
- [ ] ✅ Test 2.3: Invalid token → rejected
- [ ] ✅ Test 2.4: Canceled purchase → rejected
- [ ] ✅ Test 2.5: Network timeout & retry
- [ ] ✅ Test 2.6: Firestore structure ถูกต้อง

**ถ้าผ่านทั้งหมด → Phase 2 สำเร็จ! ✅**

---

## Phase 3: Token & Encryption Testing

### Pre-test Setup

- [ ] Backend updated (verifyEnergyToken รองรับ token ใหม่)
- [ ] Client updated (generateToken ไม่มี balance)
- [ ] migrateToSecureStorage() เพิ่มแล้ว
- [ ] Backend deployed

---

### Test 3.1: Token Format (ใหม่)

**Objective:** Token ใหม่ไม่มี balance field

**Steps:**
1. Debug app → ดึง token ที่สร้างจาก `generateToken()`
2. Decode Base64 → ดู JSON structure

**Expected:**

```json
{
  "userId": "...",
  "timestamp": 1707988800000,
  "signature": "..."
  // ไม่มี "balance" field
}
```

- [ ] Token ไม่มี field `balance`
- [ ] มีแค่ `userId`, `timestamp`, `signature`

**Notes:**

---

### Test 3.2: Backward Compatibility

**Objective:** Token เก่า (มี balance) ยังใช้ได้

**Setup:** สร้าง token เก่าด้วย format:

```json
{
  "userId": "test-device",
  "balance": 999,
  "timestamp": [current_timestamp],
  "signature": "..."
}
```

**Steps:**
1. ส่ง request ด้วย token เก่า
2. ดู Backend logs

**Expected:**
- [ ] Backend verify สำเร็จ
- [ ] Backend IGNORE balance ใน token
- [ ] Backend อ่าน balance จาก Firestore แทน
- [ ] API ทำงานปกติ
- [ ] Console log: "✅ [verifyToken] Valid token for user: ..."

**Notes:**

---

### Test 3.3: SecureStorage Migration

**Objective:** Balance migrate จาก SharedPreferences → SecureStorage

**Setup:**
1. App version เก่ามี balance = 75 ใน SharedPreferences
2. Update เป็น version ใหม่ (มี Phase 3)

**Steps:**
1. เปิด app ครั้งแรก
2. ตรวจสอบ console logs

**Expected:**
- [ ] Console log: "🔄 Migrated balance to SecureStorage: 75"
- [ ] `getBalance()` return 75
- [ ] Balance ยังคงถูกต้อง

**Verify SecureStorage:**
```dart
final value = await FlutterSecureStorage().read(key: 'energy_balance');
print(value); // should be "75"
```

- [ ] SecureStorage มี balance แล้ว

**Notes:**

---

### Test 3.4: Security - แก้ SecureStorage

**Objective:** แม้แก้ SecureStorage ได้ (root + decrypt) ก็ไม่มีผล

**Setup:**
1. Root device
2. ลองแก้ SecureStorage → balance = 9999 (ยากมาก)
3. หรือแก้ SharedPreferences → balance = 9999 (ง่าย)

**Steps:**
1. Restart app → UI อาจแสดง 9999
2. ใช้ energy

**Expected:**
- [ ] Backend อ่าน balance จาก Firestore (ค่าจริง)
- [ ] ถ้า balance จริง < cost → error
- [ ] หลัง API call → Client sync balance จาก server → UI แสดงค่าจริง
- [ ] ✅ **Security ยังอยู่ (Phase 1 ครอบคลุม)**

**Notes:**

---

### Test 3.5: Deprecated Methods

**Objective:** addEnergy() / deductEnergy() ไม่สามารถเรียกได้

**Steps:**
1. ลองเรียก `energyService.addEnergy(100, type: 'test')`

**Expected:**
- [ ] Throw Exception: "addEnergy() is deprecated..."
- [ ] หรือ compile error (ถ้าลบแล้ว)
- [ ] ไม่มีทางเรียกใช้ method นี้ได้อีก

**Notes:**

---

### Phase 3 Summary

**ผ่านทั้งหมด?**
- [ ] ✅ Test 3.1: Token format ใหม่ (ไม่มี balance)
- [ ] ✅ Test 3.2: Backward compatible (token เก่ายังใช้ได้)
- [ ] ✅ Test 3.3: SecureStorage migration
- [ ] ✅ Test 3.4: แก้ SecureStorage ไม่มีผล
- [ ] ✅ Test 3.5: Deprecated methods

**ถ้าผ่านทั้งหมด → Phase 3 สำเร็จ! ✅**

---

## Phase 4: Firebase App Check Testing

### Pre-test Setup

- [ ] Firebase App Check enabled
- [ ] Debug token added (สำหรับ debug build)
- [ ] Play Integrity configured (สำหรับ release build)
- [ ] Backend: `consumeAppCheckToken: true`
- [ ] Client: `FirebaseAppCheck.instance.activate()`

---

### Test 4.1: Debug Build (มี debug token)

**Setup:**
- Debug token added ใน Firebase Console
- App run ใน debug mode

**Steps:**
1. Build debug APK
2. เปิด app
3. เรียก API (chat, purchase)

**Expected:**
- [ ] API calls สำเร็จ
- [ ] Backend ไม่มี App Check error
- [ ] Console log: "[Main] ✅ Firebase App Check activated"

**Notes:**

---

### Test 4.2: Release Build (Play Integrity)

**Setup:**
- Build release APK
- Install บน device จริง (ไม่ใช่ emulator)

**Steps:**
1. `flutter build apk --release`
2. Install APK
3. เปิด app
4. เรียก API

**Expected:**
- [ ] API calls สำเร็จ
- [ ] Play Integrity verify ผ่าน
- [ ] Backend log: "✅ [AppCheck] Verified"

**Notes:**

---

### Test 4.3: Bot/Script (ไม่มี App Check token)

**Objective:** ✨ สำคัญที่สุดของ Phase 4

**Steps:**
ใช้ curl ยิง API ตรงๆ (ไม่ผ่าน app):

```bash
curl -X POST https://us-central1-miro-xxxxx.cloudfunctions.net/analyzeFood \
  -H "Content-Type: application/json" \
  -d '{
    "text": "test",
    "energyToken": "..."
  }'
```

**Expected:**
- [ ] Response: 401 Unauthorized
- [ ] Body: `{ error: "Unauthenticated" }`
- [ ] Backend log: "[AppCheck] No token provided"
- [ ] ✅ **BOT BLOCKED!**

**Notes:**

---

### Test 4.4: Invalid App Check Token

**Steps:**
ส่ง request ด้วย fake App Check token:

```bash
curl -X POST ... \
  -H "X-Firebase-AppCheck: fake-token-123" \
  -d '{...}'
```

**Expected:**
- [ ] Response: 401 Unauthorized
- [ ] Body: `{ error: "Invalid App Check token" }`
- [ ] Backend log: "[AppCheck] Verification failed"

**Notes:**

---

### Test 4.5: Rooted Device / Emulator

**Setup:**
- ใช้ device ที่ root แล้ว
- หรือใช้ emulator

**Steps:**
1. Build release APK
2. Install บน rooted device
3. เปิด app
4. เรียก API

**Expected (depends on enforcement level):**
- [ ] ถ้า Basic integrity: อาจผ่าน
- [ ] ถ้า Strong integrity: อาจถูกบล็อก
- [ ] ตรวจสอบ Backend logs ดู integrity level

**Notes:**

---

### Test 4.6: App Check Metrics

**Objective:** ตรวจสอบ metrics ใน Firebase Console

**Steps:**
1. ใช้ app ปกติ 1-2 วัน
2. เข้า Firebase Console → App Check → Metrics

**Expected:**
- [ ] เห็น total verifications
- [ ] Success rate > 95%
- [ ] ถ้า failed verifications สูง → มี bot พยายามเข้า

**Notes:**

---

### Test 4.7: Latency Impact

**Objective:** วัด latency ที่เพิ่มขึ้น

**Steps:**

```dart
final start = DateTime.now();
final token = await FirebaseAppCheck.instance.getToken();
final duration = DateTime.now().difference(start);
print('App Check latency: ${duration.inMilliseconds}ms');
```

**Expected:**
- [ ] Latency < 500ms (acceptable)
- [ ] ถ้า > 1000ms → มีปัญหา network หรือ config

**Notes:**

---

### Phase 4 Summary

**ผ่านทั้งหมด?**
- [ ] ✅ Test 4.1: Debug build ผ่าน
- [ ] ✅ Test 4.2: Release build ผ่าน
- [ ] ✅ Test 4.3: Bot/Script ถูกบล็อก
- [ ] ✅ Test 4.4: Invalid token ถูก reject
- [ ] ✅ Test 4.5: Rooted device behavior
- [ ] ✅ Test 4.6: Metrics ดูได้
- [ ] ✅ Test 4.7: Latency ยอมรับได้

**ถ้าผ่านทั้งหมด → Phase 4 สำเร็จ! ✅**

---

## Final Integration Testing

### ทดสอบ End-to-End ทั้งระบบ

**Scenario: User Journey ปกติ**

**Steps:**
1. **New User**
   - [ ] เปิด app ครั้งแรก → ได้ welcome gift 100
   
2. **ใช้ Energy**
   - [ ] Chat 3 ครั้ง (ไม่มีรูป) → balance = 97
   - [ ] Chat 1 ครั้ง (มีรูป) → balance = 95
   
3. **ซื้อ Energy**
   - [ ] ซื้อ 550 energy
   - [ ] Verify สำเร็จ → balance = 645
   
4. **ใช้ Energy ต่อ**
   - [ ] Chat 5 ครั้ง → balance = 640
   
5. **Restart App**
   - [ ] Close app
   - [ ] เปิดใหม่
   - [ ] Balance sync ถูกต้อง = 640

**Expected:**
- [ ] ทุก step ทำงานถูกต้อง
- [ ] Balance สอดคล้องกันระหว่าง Client และ Firestore
- [ ] ไม่มี error หรือ crash

---

## Master Checklist

### ✅ All Phases Completed

- [ ] **Phase 1: Firestore Balance** (7/7 tests passed)
- [ ] **Phase 2: Purchase Verification** (6/6 tests passed)
- [ ] **Phase 3: Token & Encryption** (5/5 tests passed)
- [ ] **Phase 4: Firebase App Check** (7/7 tests passed) [Optional]
- [ ] **Final Integration Test** passed

---

## Bug Report Template

ถ้าเจอ test ไม่ผ่าน ใช้ template นี้รายงาน:

```
## Bug Report

**Test:** [ชื่อ test เช่น Test 1.6: Security - Client แก้ balance]

**Expected:**
[อธิบายว่าควรเกิดอะไร]

**Actual:**
[อธิบายว่าเกิดอะไรจริงๆ]

**Steps to Reproduce:**
1. ...
2. ...
3. ...

**Logs:**
```
[paste console logs / error messages]
```

**Screenshots:**
[ถ้ามี]

**Environment:**
- App version: 
- Platform: Android / iOS
- Device: 
- Firebase project: 
```

---

## คำแนะนำสุดท้าย

### 🎯 Testing Best Practices

1. **Test ตามลำดับ Phase** — อย่าข้าม
2. **ทำ test ทีละข้อ** — อย่ารีบ
3. **เช็ค Firebase Console** — ดู data real-time
4. **เก็บ screenshots** — เป็นหลักฐาน
5. **บันทึก notes** — จดสิ่งที่สังเกตเห็น
6. **ถ้าไม่ผ่าน** — อ่าน Troubleshooting ในเอกสาร Phase นั้นๆ

### 📊 Success Criteria

**Phase 1-3 (CRITICAL + HIGH):**
- ✅ ผ่านทุก test
- ✅ ไม่มี security vulnerabilities เหลืออยู่
- ✅ Ready สำหรับ production

**Phase 4 (OPTIONAL):**
- ✅ ผ่านทุก test
- ✅ Bot protection ทำงาน
- ✅ Production-grade security

---

**🎉 Good luck with testing!**

*Testing Checklist Version 1.0*  
*สำหรับ Energy Security Upgrade Project*
