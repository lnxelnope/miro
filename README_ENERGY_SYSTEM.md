# 📚 MIRO Energy System — Documentation Index

> **สำหรับ Junior Developer**  
> อ่านไฟล์ตามลำดับนี้ แล้วเริ่มเขียนโค้ดได้เลย

---

## 🎯 เป้าหมาย

แปลงระบบ BYOK (Bring Your Own Key) → Energy System แบบ Backend Proxy  
- ผู้ใช้ไม่ต้องจัดการ API key เอง
- ใช้ระบบ Energy (1 Energy = 1 AI analysis)
- มีระบบซื้อ Energy packages
- มี Welcome Offer (40% OFF ภายใน 24 ชั่วโมง)

---

## 📖 ลำดับการอ่าน (อ่านตามนี้)

### 📄 ไฟล์ที่ 1: KEY_DECISIONS.md
**อ่านก่อนทุกอย่าง — 15 นาที**

📍 **หน้า:** 1-12 (371 บรรทัด)

**เนื้อหา:**
- ✅ การตัดสินใจทั้งหมดที่เสร็จแล้ว (ไม่ต้องคิดเอง)
- Backend architecture (Option B - Firebase Cloud Functions)
- Beta testers → 1,000 Energy
- API Key → Environment variable (Firebase Functions Config)
- Analytics → ใช้ Firebase Analytics
- Refund policy → ไม่ refund (ยกเว้น error)
- Welcome Offer → เริ่มหลังใช้ AI 3 ครั้ง
- Welcome Limit → ซื้อได้ 1 package เท่านั้น
- Device ID fallback → Hardware fingerprint
- Beta tester identification → Manual email list

**ทำไมต้องอ่าน:**
เพื่อให้รู้ว่า requirement คืออะไร และตัดสินใจอะไรไปแล้วบ้าง (ไม่ต้องถามอีก)

---

### 📄 ไฟล์ที่ 2: ENERGY_MIGRATION_PLAN.md
**อ่านเพื่อเข้าใจภาพรวม — 20 นาที**

📍 **หน้า:** 13-39 (664 บรรทัด)

**เนื้อหา:**
- 💰 Cost analysis (Gemini API pricing)
- 📦 Energy packages + pricing
- 🔒 Security architecture (BYOK → Centralized)
- 🎁 Welcome gift system (100 Energy ฟรี)
- ⏰ Welcome Offer (40% OFF — 24 ชั่วโมง)
- 📋 Implementation plan (Phase 1-6)
- 🗂️ Database schema (EnergyTransaction)
- 🎨 UI mockups
- ⚠️ Risks & mitigations
- 💡 Cost projections

**ทำไมต้องอ่าน:**
เพื่อเข้าใจ business logic, pricing strategy, และภาพรวมของระบบ

**⚠️ หมายเหตุ:** ไฟล์นี้เป็น planning document (reference) — อ่านเพื่อความเข้าใจ ไม่ได้เป็นคู่มือการเขียนโค้ด

---

### 📄 ไฟล์ที่ 3: ENERGY_IMPLEMENTATION_GUIDE.md ⭐ สำคัญที่สุด!
**อ่านละเอียดและทำตาม — 60-90 นาที**

📍 **หน้า:** 40-133 (2,500+ บรรทัด)

**เนื้อหา:**

#### ส่วนที่ 1: Backend (Firebase Cloud Functions)
- Setup Firebase project
- Install Firebase CLI
- สร้าง Environment Variables (Firebase Functions Config)
- โค้ด Backend API สมบูรณ์ (`functions/src/analyzeFood.ts`)
  - Energy Token validation (HMAC signature)
  - Gemini API integration
  - Error handling
- Deploy instructions

#### ส่วนที่ 2: Flutter App
**Configuration Files:**
- `lib/core/config/beta_testers.dart` — รายชื่อ beta testers

**Service Files (สร้างใหม่):**
- `lib/core/services/device_id_service.dart` — Device ID persistent
- `lib/core/services/energy_token_service.dart` — HMAC signature
- `lib/core/services/energy_service.dart` — Energy CRUD + migration
- `lib/core/services/welcome_offer_service.dart` — 24h timer

**Model Files:**
- `lib/core/models/energy_transaction.dart` — Isar model

**Update Existing Files:**
- `lib/core/ai/gemini_service.dart` — เรียก Backend แทน direct API
- `lib/core/services/purchase_service.dart` — เพิ่ม 8 Energy packages
- All AI call points — เช็ค Energy ก่อนใช้

**UI Components (สร้างใหม่):**
- `lib/features/energy/widgets/energy_badge.dart` — แสดงบน AppBar
- `lib/features/energy/widgets/no_energy_dialog.dart` — แจ้งเมื่อหมด
- `lib/features/energy/presentation/energy_store_screen.dart` — ร้านค้า

**Remove Old Files:**
- `lib/features/profile/presentation/api_key_screen.dart` — ลบทิ้ง
- Remove API Key setup จาก Profile/Onboarding

#### ส่วนที่ 3: Google Play Console
- สร้าง 8 IAP products (4 regular + 4 welcome)
- Setup testing accounts

#### ส่วนที่ 4: Testing
- Backend API testing (curl commands)
- App testing scenarios (12 test cases)
- Migration testing

#### ส่วนที่ 5: Deployment
- Deploy Backend
- Build & upload app
- Environment variables checklist
- Troubleshooting guide

**ทำไมต้องอ่าน:**
นี่คือคู่มือหลักที่ใช้เขียนโค้ด — มีโค้ดสมบูรณ์ทุกไฟล์พร้อม copy-paste

**📌 วิธีใช้:**
1. เปิดไฟล์นี้ควบคู่กับ IDE
2. ทำตามทีละ Step
3. Copy โค้ดที่ให้มา
4. แก้ TODO comments (เช่น API URL, Secret key)
5. Test แต่ละ step

---

### 📄 ไฟล์ที่ 4: BETA_TESTERS_SETUP.md
**อ่านเมื่อถึง Step ที่เกี่ยวข้อง — 10 นาที**

📍 **หน้า:** 134-145 (280 บรรทัด)

**เนื้อหา:**
- วิธีรวบรวมรายชื่อ beta testers
  - จาก Google Play Console
  - จาก Firebase Authentication
  - จาก Google Form
- โค้ด `beta_testers.dart` แบบละเอียด
- Integration กับ Migration code
- Test cases (4 scenarios)
- Alternative: Firebase Remote Config
- FAQ

**ทำไมต้องอ่าน:**
เพื่อรู้วิธีเพิ่มรายชื่อ beta testers และทำให้พวกเขาได้รับ 1,000 Energy

**📌 เมื่อไหร่ควรอ่าน:**
- เมื่อทำถึง Step "Create Beta Testers Configuration" ใน Implementation Guide
- หรือเมื่อต้องการเพิ่ม/แก้ไขรายชื่อ beta testers

---

## 📊 สรุปจำนวนหน้า

| ไฟล์ | บรรทัด | หน้า (โดยประมาณ) | เวลาอ่าน | ความสำคัญ |
|------|--------|-------------------|----------|-----------|
| **BACKEND_SETUP_COMPLETE.md** | - | - | 5 นาที | ⭐⭐⭐⭐⭐ **อ่านก่อน!** |
| **KEY_DECISIONS.md** | 371 | 1-12 | 15 นาที | ⭐⭐⭐⭐⭐ |
| **ENERGY_MIGRATION_PLAN.md** | 664 | 13-39 | 20 นาที | ⭐⭐⭐ (Reference) |
| **ENERGY_IMPLEMENTATION_GUIDE.md** | 2,526 | 40-133 | 60-90 นาที | ⭐⭐⭐⭐⭐ (คู่มือหลัก) |
| **BETA_TESTERS_SETUP.md** | 280 | 134-145 | 10 นาที | ⭐⭐⭐⭐ |
| **รวม** | **3,841 บรรทัด** | **145 หน้า** | **115-145 นาที** | |

---

## 🚀 Quick Start (สำหรับคนขี้เกียจ)

ถ้าไม่มีเวลาอ่านทั้งหมด ให้ทำแบบนี้:

### Step 1: อ่านเฉพาะสิ่งที่ต้องรู้ (20 นาที)
1. **KEY_DECISIONS.md** → Section "Summary Table" (หน้า 11)
2. **ENERGY_IMPLEMENTATION_GUIDE.md** → Section "Architecture Overview" (หน้า 40-42)

### Step 2: เริ่มเขียนโค้ดตาม Implementation Guide (4-6 ชั่วโมง)
- เปิด **ENERGY_IMPLEMENTATION_GUIDE.md**
- ทำตาม Step 1 → Step 10 ทีละขั้น
- อย่าข้าม step ไหน
- Test ทุก step

### Step 3: Setup Beta Testers (30 นาที)
- เปิด **BETA_TESTERS_SETUP.md**
- เพิ่มรายชื่อ email
- Test

### Step 4: Deploy (1 ชั่วโมง)
- Deploy Backend (Supabase)
- Build & upload app
- Monitor logs

**Total time:** 6-8 ชั่วโมง (1 วันทำงาน)

---

## ✅ Checklist สำหรับ Junior

### ✅ Phase 1: เตรียมความพร้อม (เสร็จแล้ว!)
- [x] อ่าน KEY_DECISIONS.md ทั้งหมด
- [x] อ่าน ENERGY_IMPLEMENTATION_GUIDE.md (Architecture Overview)
- [x] ติดตั้ง Firebase CLI
- [x] Setup Firebase Project (ใช้โปรเจกต์ที่มีอยู่แล้ว)
- [x] Clone/Pull โค้ดล่าสุด

### ✅ Phase 2: Backend (เสร็จแล้ว!)
- [x] สร้าง Environment Variables (Firebase Functions Config)
- [x] สร้างโค้ด `functions/src/analyzeFood.ts`
- [x] Deploy Cloud Function ✅
- [x] URL: `https://us-central1-miro-d6856.cloudfunctions.net/analyzeFood`
- [ ] ~~Test ด้วย curl commands~~ (ทำได้หลังสร้าง token ในแอป)

**📌 Backend พร้อมใช้งาน! อ่าน BACKEND_SETUP_COMPLETE.md สำหรับรายละเอียด**

### ✅ Phase 3: Configuration (เสร็จแล้ว!)
- [x] สร้าง `lib/core/config/beta_testers.dart` ✅
- [x] **กลยุทธ์เปลี่ยนแปลง:** ใช้ Welcome Gift 1,000 Energy ชั่วคราว (ง่ายกว่า!)
  - ไม่ต้องเพิ่มรายชื่อ beta testers
  - ⚠️ **ต้องจำเปลี่ยนกลับเป็น 100 ก่อน launch!** (ดู LAUNCH_CHECKLIST.md)

### □ Phase 4: Services (2-3 ชั่วโมง)
- [ ] สร้าง `device_id_service.dart`
- [ ] สร้าง `energy_token_service.dart`
- [ ] สร้าง `energy_transaction.dart` + run build_runner
- [ ] สร้าง `energy_service.dart`
- [ ] สร้าง `welcome_offer_service.dart`

### □ Phase 5: Update Existing Files (1 ชั่วโมง)
- [ ] แก้ `gemini_service.dart` (เรียก Backend)
- [ ] แก้ `purchase_service.dart` (เพิ่ม 8 packages)
- [ ] อัพเดท AI call points (เช็ค Energy ก่อน)

### □ Phase 6: UI Components (1-2 ชั่วโมง)
- [ ] สร้าง `energy_badge.dart`
- [ ] สร้าง `no_energy_dialog.dart`
- [ ] สร้าง `energy_store_screen.dart`

### □ Phase 7: Remove BYOK (15 นาที)
- [ ] ลบ `api_key_screen.dart`
- [ ] แก้ `profile_screen.dart`
- [ ] แก้ `onboarding_screen.dart`

### □ Phase 8: Migration (30 นาที)
- [ ] อัพเดท `main.dart` (initialize Energy system)
- [ ] เพิ่ม Migration code

### □ Phase 9: Google Play Console (30 นาที)
- [ ] สร้าง 4 regular products
- [ ] สร้าง 4 welcome products
- [ ] Setup test accounts

### □ Phase 10: Testing (1-2 ชั่วโมง)
- [ ] Test Backend API
- [ ] Test fresh install → ได้ 100 Energy
- [ ] Test reinstall → ไม่ได้ Energy ซ้ำ
- [ ] Test AI analysis → หัก 1 Energy
- [ ] Test 3rd AI use → เริ่ม Welcome Offer
- [ ] Test Welcome Offer timer
- [ ] Test purchase (regular + welcome)
- [ ] Test beta tester migration → ได้ 1,000 Energy
- [ ] Test no energy → show dialog

### □ Phase 11: Deployment (1 ชั่วโมง)
- [ ] Deploy Backend สุดท้าย
- [ ] Build app (--release --obfuscate)
- [ ] Upload to Play Console
- [ ] Test บน real device
- [ ] Monitor logs ครั้งแรก

---

## 🆘 เมื่อติดปัญหา

### 1. อ่าน Troubleshooting Guide
📍 **ENERGY_IMPLEMENTATION_GUIDE.md** → Section "Troubleshooting" (หน้า 120-125)

มีคำตอบของปัญหาทั่วไป:
- "Insufficient energy" แม้มี Energy
- CORS Error
- Welcome Gift ไม่ได้รับ
- IAP ไม่ทำงาน

### 2. ตรวจสอบ Logs
```bash
# Backend logs
firebase functions:log --only analyzeFood

# Flutter logs
flutter logs
```

### 3. Debug Tools
```dart
// Debug Energy Token
final decoded = EnergyTokenService.decodeToken(token);
print(decoded);

// Debug Balance
final balance = await energyService.getBalance();
print('Balance: $balance');

// Debug Device ID
await DeviceIdService.printDeviceId();

// Debug Beta Tester Status
BetaTesters.printStatus(userEmail);
```

### 4. ถามผู้ใหญ่
- สรุปปัญหาที่เจอ
- แนบ error logs
- บอกว่าทำ step ไหนไปแล้วบ้าง
- บอกว่า test อะไรไปแล้ว

---

## 📌 สิ่งสำคัญที่ต้องจำ

### 🔐 Security
- ❌ **อย่า** commit `.env` ขึ้น git
- ❌ **อย่า** hardcode API key ในโค้ด
- ✅ **ต้อง** เก็บ API key ใน Firebase Functions Secrets
- ✅ **ต้อง** ใช้ HMAC signature สำหรับ Energy Token

### 💰 Pricing
- 1 Energy = 1 AI analysis
- Welcome Gift = 100 Energy (ฟรี)
- Beta Tester Bonus = 1,000 Energy (ฟรี)
- Regular packages: $0.99, $4.99, $7.99, $9.99
- Welcome Offer: 40% OFF (เริ่มหลังใช้ 3 ครั้ง, มี 24 ชั่วโมง, ซื้อได้ 1 package)

### 🧪 Testing
- ❌ **ห้าม** test IAP ใน debug mode
- ✅ **ต้อง** build --release และ upload เป็น Internal Testing
- ✅ **ต้อง** test บน real device (ไม่ใช่ emulator)
- ✅ **ต้อง** test ทั้ง beta tester และ regular user accounts

### 🚀 Deployment
- Backend: Deploy ก่อน App
- App: Build → Upload → Test → Release
- Monitor logs ใน 24 ชั่วโมงแรก

---

## 💡 Tips for Success

1. **อย่าข้าม step ไหน** — ทำตามลำดับใน Implementation Guide
2. **Copy-paste จากคู่มือ** — โค้ดพร้อมใช้แล้ว แค่แก้ TODO
3. **Test บ่อยๆ** — อย่ารอจนเสร็จหมดค่อย test
4. **Commit บ่อยๆ** — แต่ละ phase เสร็จ → commit
5. **ถ่ายภาพ error logs** — ถ้าติด จะได้ debug ง่าย
6. **ถามเร็ว** — ถ้าติดเกิน 30 นาที ให้ถามทันที (อย่าเสียเวลา)

---

## 📞 Contact

ถ้ามีคำถามหรือติดปัญหา:
1. อ่าน Troubleshooting Guide ก่อน
2. ตรวจสอบ logs
3. ถามพี่ (แนบ error logs มาด้วย)

---

## 🎯 Expected Outcome

หลังจากทำตามคู่มือนี้เสร็จ จะได้:

✅ Backend API ที่ secure (API key ไม่มีในแอป)  
✅ Energy System ทำงานได้ (เพิ่ม/ลด/ซื้อ Energy)  
✅ Welcome Gift (100 Energy) ให้ user ใหม่  
✅ Beta Tester Bonus (1,000 Energy) ให้ testers  
✅ Welcome Offer (40% OFF) เริ่มหลังใช้ 3 ครั้ง  
✅ Energy Store UI สวยงาม  
✅ IAP integration สมบูรณ์ (8 products)  
✅ Device ID binding (ป้องกัน abuse)  
✅ Analytics tracking ครบทุก event  
✅ App พร้อม deploy 🚀  

---

**Good luck! คุณทำได้! 💪**

> ระยะเวลารวม: 6-8 ชั่วโมง (1 วันทำงาน)  
> หลังจากนั้นเรามาตรวจร่วมกัน 🔍
