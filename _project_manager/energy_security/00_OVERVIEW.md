# Energy Security Upgrade - Overview

> **เอกสารนี้เป็นภาพรวมของ Project การอัพเกรดความปลอดภัยระบบ Energy**  
> **สำหรับ Junior Developer: อ่านเอกสารนี้ก่อน แล้วค่อยไปทำตาม Phase ทีละ Phase**

---

## 📋 สารบัญเอกสาร

| ไฟล์ | คำอธิบาย | อ่านก่อนเริ่มทำ? |
|------|----------|-----------------|
| `00_QUICK_START.md` | 🚀 **เริ่มที่นี่!** Setup info + Checklist | ✅✅ อ่านก่อนทุกอย่าง |
| `00_OVERVIEW.md` | 📌 ภาพรวม Project | ✅ อ่านก่อน |
| `01_PHASE1_FIRESTORE.md` | 🔴 Phase 1: Firestore Balance (CRITICAL) | ✅ ทำก่อนสุด |
| `02_PHASE2_PURCHASE.md` | 🔴 Phase 2: Purchase Verification (CRITICAL) | ทำหลัง Phase 1 |
| `03_PHASE3_ENCRYPTION.md` | 🟡 Phase 3: Encryption & Token (HIGH) | ทำหลัง Phase 2 |
| `04_PHASE4_APPCHECK.md` | 🟢 Phase 4: Firebase App Check (Optional) | ทำสุดท้าย |
| `99_TESTING_CHECKLIST.md` | ✅ Checklist การทดสอบ | ใช้หลังทำแต่ละ Phase |

---

## 🎯 จุดประสงค์ของ Project

ระบบ Energy ปัจจุบันมี **ช่องโหว่ด้านความปลอดภัย 4 จุดหลัก**:

### ❌ ปัญหาที่พบ

1. **Balance เก็บใน SharedPreferences ไม่เข้ารหัส**
   - ผู้ใช้ root เครื่องแล้วแก้ไข balance ได้ตรงๆ
   - ใช้เวลาแค่ 5 นาที → ได้ Energy ไม่จำกัด

2. **HMAC Secret ฝังใน APK**
   - Decompile APK → หา Secret → สร้าง Token ปลอมได้
   - Token มี balance ข้างใน → Backend เชื่อตามที่ Client บอก

3. **Backend เชื่อ Balance จาก Client**
   - Backend ไม่มี Database เก็บ balance จริง
   - อ่าน balance จาก Token ที่ Client สร้างมา

4. **ไม่มี Server-side Purchase Verification**
   - ซื้อ Energy แล้วเพิ่ม balance ฝั่ง Client ตรงๆ
   - ไม่มีการ verify กับ Google Play API
   - ใช้ purchase token ซ้ำได้

### ✅ สิ่งที่จะแก้ไข

| ปัญหา | วิธีแก้ | Phase |
|-------|--------|-------|
| Client แก้ balance ได้ | ✅ Firestore เป็น Source of Truth | Phase 1 |
| Token forgery | ✅ Token ไม่มี balance, Server อ่าน Firestore | Phase 1 |
| Purchase ปลอม | ✅ Server verify กับ Google Play API | Phase 2 |
| Storage ไม่เข้ารหัส | ✅ FlutterSecureStorage | Phase 3 |
| Secret ใน APK | ⚠️ ยังอยู่แต่ไม่อันตรายแล้ว (Phase 3) | Phase 3 |
| Bot attacks | ✅ Firebase App Check (Optional) | Phase 4 |

---

## 📊 สถาปัตยกรรมเดิม vs ใหม่

### ❌ เดิม (ไม่ปลอดภัย)

```
CLIENT:
  - SharedPreferences → balance = 95 (ไม่เข้ารหัส)
  - สร้าง Token มี {userId, BALANCE, timestamp, signature}
  - ส่ง Token ไป Backend
             ↓
BACKEND:
  - Verify HMAC signature ✓
  - อ่าน balance จาก TOKEN ← เชื่อ Client!
  - เรียก Gemini API
  - หัก balance ใน Token
  - ส่ง Token ใหม่กลับ
  
⚠️ ไม่มี Database ฝั่ง Server
⚠️ ไม่มี Purchase Verification
```

### ✅ ใหม่ (ปลอดภัย)

```
CLIENT:
  - FlutterSecureStorage → balance (encrypted cache only)
  - สร้าง Token มีแค่ {userId, timestamp, signature}
  - ไม่มี balance ใน Token อีกต่อไป
  - ส่ง Token ไป Backend
             ↓
BACKEND + FIRESTORE:
  - Verify HMAC (app authentication only)
  - ✅ อ่าน balance จาก FIRESTORE (Server = Truth)
  - เรียก Gemini API
  - ✅ หัก balance ใน FIRESTORE (atomic transaction)
  - ส่ง newBalance กลับให้ Client sync
  
PURCHASE:
  - Client ส่ง purchaseToken ไป Backend
  - ✅ Backend verify กับ Google Play API
  - ✅ เช็ค duplicate purchase
  - ✅ เพิ่ม balance ใน Firestore
```

---

## 🚀 แผนการทำงาน

### Priority แต่ละ Phase

| Phase | ชื่อ | Priority | เวลา | ป้องกันอะไร |
|-------|------|----------|------|------------|
| **Phase 1** | Firestore Balance | 🔴 **CRITICAL** | 1-2 วัน | Client แก้ balance, Token forgery |
| **Phase 2** | Purchase Verification | 🔴 **CRITICAL** | 1-2 วัน | ซื้อปลอม, Purchase replay |
| **Phase 3** | Token & Encryption | 🟡 HIGH | 0.5-1 วัน | APK decompile, Root access |
| **Phase 4** | Firebase App Check | 🟢 NICE-TO-HAVE | 0.5 วัน | Bot/Script attacks |

**⚠️ สำคัญ: ต้องทำตามลำดับ Phase 1 → 2 → 3 → 4**

---

## 📝 ขั้นตอนการทำงานสำหรับ Junior

### ก่อนเริ่ม

1. ✅ อ่านเอกสารนี้ให้จบ
2. ✅ ตรวจสอบว่ามี tools ที่จำเป็น:
   - Flutter SDK (version ตรงกับ project)
   - Firebase CLI (`npm install -g firebase-tools`)
   - Node.js (สำหรับ Cloud Functions)
   - Android Studio / VS Code
3. ✅ Clone repo และ run ได้ตามปกติ
4. ✅ เข้าใจ codebase เดิม (อ่านไฟล์ที่เกี่ยวข้อง):
   - `lib/core/services/energy_service.dart`
   - `lib/core/services/energy_token_service.dart`
   - `lib/core/services/purchase_service.dart`
   - `functions/src/analyzeFood.ts`

### ขั้นตอนการทำ

```
วันที่ 1-2: Phase 1 (CRITICAL)
  ├── อ่าน 01_PHASE1_FIRESTORE.md
  ├── ทำตาม Step 1.1 → 1.2 → 1.3 → 1.4 → 1.5
  ├── Deploy Backend
  ├── Test ด้วย 99_TESTING_CHECKLIST.md (Section Phase 1)
  └── Commit code

วันที่ 3-4: Phase 2 (CRITICAL)
  ├── อ่าน 02_PHASE2_PURCHASE.md
  ├── Setup Google Play API (ใช้เวลา ~1 ชม.)
  ├── ทำตาม Step 2.1 → 2.2 → 2.3 → 2.4
  ├── Deploy Backend
  ├── Test ด้วย 99_TESTING_CHECKLIST.md (Section Phase 2)
  └── Commit code

วันที่ 5: Phase 3 (HIGH)
  ├── อ่าน 03_PHASE3_ENCRYPTION.md
  ├── ทำตาม Step 3.1 → 3.2 → 3.3
  ├── Update Client
  ├── Test ด้วย 99_TESTING_CHECKLIST.md (Section Phase 3)
  └── Commit code

วันที่ 6 (Optional): Phase 4
  ├── อ่าน 04_PHASE4_APPCHECK.md
  ├── ทำตามขั้นตอน
  ├── Test
  └── Commit code
```

---

## 🎓 สิ่งที่ต้องรู้ก่อนเริ่ม

### ความรู้พื้นฐานที่จำเป็น

- **Flutter/Dart**: SharedPreferences, FlutterSecureStorage, async/await
- **Firebase Firestore**: Collections, Documents, Transactions
- **Cloud Functions**: TypeScript, HTTP handlers, Firebase Admin SDK
- **Google Play Billing**: In-app purchases, purchase tokens
- **Security concepts**: HMAC, encryption, server-side validation

### คำศัพท์ที่ใช้บ่อย

| คำ | ความหมาย |
|----|----------|
| **Balance** | จำนวน Energy ที่ User มี |
| **Token** | JWT-like string ที่ Client ส่งไป Backend เพื่อพิสูจน์ตัวตน |
| **HMAC** | Hashing algorithm ที่ใช้ sign Token |
| **Firestore** | NoSQL Database ของ Firebase |
| **Cloud Function** | Serverless backend function บน Firebase |
| **purchaseToken** | String ที่ได้จาก Google Play หลังซื้อสำเร็จ |
| **Source of Truth** | แหล่งข้อมูลหลักที่ถือว่าถูกต้องที่สุด |
| **Atomic Transaction** | การอัพเดทข้อมูลที่รับประกันว่าจะสำเร็จทั้งหมดหรือล้มเหลวทั้งหมด |

---

## ⚠️ สิ่งที่ต้องระวัง

### อย่าทำ

- ❌ **อย่าข้าม Phase** — ต้องทำตามลำดับ
- ❌ **อย่า hardcode values** — ใช้ constants และ environment variables
- ❌ **อย่า commit secrets** — ใช้ Firebase Secrets สำหรับ service account
- ❌ **อย่า deploy ตรงไป Production** — ทดสอบก่อนเสมอ
- ❌ **อย่าลบ code เดิมทิ้งทันที** — comment ไว้ก่อนในระหว่างทำ
- ❌ **อย่าแก้ไฟล์อื่นที่ไม่เกี่ยวข้อง** — focus เฉพาะไฟล์ที่บอก

### ต้องทำ

- ✅ **Backup code เดิม** — commit ก่อนเริ่มแต่ละ Phase
- ✅ **Test ทุกขั้นตอน** — ใช้ Testing Checklist
- ✅ **เขียน log ให้ชัดเจน** — debug ง่าย
- ✅ **Handle errors** — จัดการ error cases ให้ครบ
- ✅ **เก็บ backward compatibility** — ต้องรองรับ Client เวอร์ชันเก่า
- ✅ **ถ่าย screenshot ผลลัพธ์** — เก็บเป็นหลักฐาน
- ✅ **ถามเมื่อไม่แน่ใจ** — ดีกว่าทำผิด

---

## 📞 การขอความช่วยเหลือ

### เมื่อไหร่ควรถาม

- 🟢 **ถามได้เลย**:
  - ไม่เข้าใจขั้นตอนในเอกสาร
  - เจอ error ที่ไม่รู้จะแก้ยังไง
  - ไม่แน่ใจว่าทำถูกหรือเปล่า

- 🟡 **ลองแก้ก่อน 15-30 นาที แล้วค่อยถาม**:
  - Syntax error, type mismatch
  - Import ผิด, package หาไม่เจอ
  - Minor bugs ที่ search Google ได้

- 🔴 **อย่าถาม**:
  - ยังไม่ได้อ่านเอกสาร
  - ยังไม่ได้ลองทำเลย
  - ถามแล้วไม่ทำตามที่แนะนำ

### วิธีถามที่ดี

```
❌ ไม่ดี: "มัน error อ่ะครับ"

✅ ดี:
"ผมทำ Phase 1 Step 1.2 แล้วเจอ error นี้ครับ:

[Error message]

ผมลอง:
1. Check Firebase config แล้ว ถูกต้อง
2. Reinstall packages แล้ว
3. Clean build แล้ว

ยังไม่หายครับ แก้ยังไงดีครับ"
```

---

## 📈 Migration Strategy (สำหรับ User เดิม)

เมื่อ deploy Phase 1 เสร็จ, User ที่มี balance เดิมอยู่ใน SharedPreferences จะเกิดอะไรขึ้น?

```
App Startup (หลัง upgrade):
  1. App อ่าน balance เดิมจาก SharedPreferences = 95
  2. เรียก Backend: syncBalance({ deviceId, localBalance: 95 })
  3. Backend:
     - เช็ค Firestore ว่ามี document ของ deviceId นี้หรือยัง?
     - ถ้ายังไม่มี → สร้างใหม่ด้วย localBalance = 95 (one-time migration)
     - ถ้ามีแล้ว → ใช้ค่าจาก Firestore (server wins)
  4. Client sync balance จาก response
  5. ✅ Migration สำเร็จ
```

**User จะไม่เสีย balance!** 🎉

---

## 🔒 หลังทำเสร็จทั้ง 4 Phase

### ระดับความปลอดภัย

| Attack Vector | ก่อนแก้ | หลังแก้ |
|--------------|---------|---------|
| SharedPreferences modification | 🔴 CRITICAL | ✅ FIXED |
| Token forgery (APK decompile) | 🔴 CRITICAL | ✅ FIXED |
| Purchase replay | 🔴 CRITICAL | ✅ FIXED |
| Fake purchase | 🔴 CRITICAL | ✅ FIXED |
| Token replay (5 min window) | 🟡 MEDIUM | 🟢 LOW |
| Direct Firestore access | N/A | 🟢 LOW (ต้อง hack Firebase) |

---

## 📚 เอกสารเพิ่มเติม

- [Firebase Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Google Play Billing Library](https://developer.android.com/google/play/billing)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)
- [Firebase App Check](https://firebase.google.com/docs/app-check)

---

## ✅ Checklist ก่อนเริ่ม

- [ ] อ่านเอกสารนี้จบแล้ว
- [ ] เข้าใจสถาปัตยกรรมเดิมและใหม่
- [ ] ตรวจสอบ tools ครบแล้ว
- [ ] Backup code เดิมแล้ว
- [ ] Firebase Project: `miro-d6856` (verified)
- [ ] Service Account: `play-store-manager@miro-d6856.iam.gserviceaccount.com` (ready)
- [ ] Firebase Secret: `GOOGLE_SERVICE_ACCOUNT_JSON` (set)
- [ ] พร้อมเริ่ม Phase 1 แล้ว

**🎯 Next Step: อ่าน `01_PHASE1_FIRESTORE.md`**

---

## 📊 Project Information (สำหรับ Junior)

### Firebase Project
```
Project ID: miro-d6856
Project Number: 65396857547
Region: us-central1
```

### Service Account (สำหรับ Phase 2)
```
Email: play-store-manager@miro-d6856.iam.gserviceaccount.com
Secret Name: GOOGLE_SERVICE_ACCOUNT_JSON
Status: ✅ Ready to use
```

### Cloud Functions URLs (จะได้หลัง deploy)
```
analyzeFood: https://us-central1-miro-d6856.cloudfunctions.net/analyzeFood
syncBalance: https://us-central1-miro-d6856.cloudfunctions.net/syncBalance (Phase 1)
verifyPurchase: https://us-central1-miro-d6856.cloudfunctions.net/verifyPurchase (Phase 2)
```

### ข้อมูลสำคัญที่ต้องใช้
- **ไม่ต้องหา Package Name** - จะบอกให้ตอนถึง Phase 2
- **ไม่ต้อง setup Service Account** - ทำเสร็จแล้ว
- **เริ่มจาก Phase 1 ได้เลย** - ไม่มีอะไรขาด

---

*เอกสารนี้สร้างวันที่: 15 Feb 2026*  
*Version: 1.0*  
*สำหรับ: Junior Developer*
