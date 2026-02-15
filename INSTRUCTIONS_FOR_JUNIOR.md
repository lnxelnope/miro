# 📋 Instructions for Junior Developer

---

## 🎯 Task

แปลง MIRO App จาก **BYOK System** → **Energy System (Backend Proxy)**

**Deadline:** 2 วันทำงาน  
**Estimated Hours:** 8-13 ชั่วโมง

---

## 📚 เอกสารทั้งหมด (อ่านตามลำดับ)

| # | ไฟล์ | หน้า | เวลา | อ่านเมื่อไหร่ | สำคัญ |
|---|------|------|------|--------------|-------|
| **0** | **START_HERE.md** | - | 5 นาที | **อ่านก่อนทุกอย่าง** | ⭐⭐⭐⭐⭐ |
| **1** | **KEY_DECISIONS.md** | 1-12 | 15 นาที | ก่อนเริ่มเขียนโค้ด | ⭐⭐⭐⭐⭐ |
| **2** | **ENERGY_MIGRATION_PLAN.md** | 13-39 | 20 นาที | เพื่อเข้าใจภาพรวม | ⭐⭐⭐ |
| **3** | **ENERGY_IMPLEMENTATION_GUIDE.md** | 40-133 | 90+ นาที | **ขณะเขียนโค้ด (ทำตามนี้)** | ⭐⭐⭐⭐⭐ |
| **4** | **BETA_TESTERS_SETUP.md** | 134-145 | 10 นาที | เมื่อถึง Step Beta Testers | ⭐⭐⭐⭐ |
| **5** | **README_ENERGY_SYSTEM.md** | - | 30 นาที | Reference (มี Checklist ครบ) | ⭐⭐⭐⭐ |

**Total:** 145 หน้า, 3,841 บรรทัด

---

## 🚀 Quick Start (3 ขั้นตอน)

### Step 1: อ่าน (2 ชั่วโมง)
```
1. เปิด START_HERE.md → อ่านทั้งหมด (5 นาที)
2. เปิด KEY_DECISIONS.md → อ่านทั้งหมด (15 นาที)
3. เปิด ENERGY_IMPLEMENTATION_GUIDE.md → อ่าน Section 1-2 (30 นาที)
```

### Step 2: เขียนโค้ด (6-8 ชั่วโมง)
```
เปิด ENERGY_IMPLEMENTATION_GUIDE.md
→ ทำตาม Step 1 ถึง Step 10
→ Copy โค้ดที่ให้มา
→ แก้ TODO comments (API URL, Secret key, Email list)
→ Test ทุก step
```

### Step 3: ส่งตรวจ (1 ชั่วโมง)
```
Build app → Test บน real device → Screenshot → ส่งให้พี่
```

---

## ⚠️ สิ่งสำคัญที่ต้องจำ

### 1. ต้องแก้ในโค้ด
- [ ] Supabase URL (ใน `gemini_service.dart`)
- [ ] Supabase Anon Key (ใน `gemini_service.dart`)
- [ ] Encryption Secret (ใน `energy_token_service.dart` + Supabase Dashboard)
- [ ] Gemini API Key (ใน Supabase Dashboard → Secrets)
- [ ] Beta Testers Email List (ใน `beta_testers.dart`)

### 2. ห้ามทำ
- ❌ อย่า commit `.env` ขึ้น git
- ❌ อย่า hardcode API key ในโค้ด
- ❌ อย่าข้าม step ใดๆ
- ❌ อย่า test IAP ใน debug mode

### 3. ต้องทำ
- ✅ ทำตามลำดับ step ใน Implementation Guide
- ✅ Test หลังทำทุก step
- ✅ Commit บ่อยๆ (แต่ละ phase เสร็จ)
- ✅ ถามทันทีถ้าติดเกิน 30 นาที

---

## 📂 ไฟล์ที่ต้องสร้าง (12 ไฟล์ใหม่)

### Backend (1 ไฟล์)
- `supabase/functions/analyze-food/index.ts`

### Config (1 ไฟล์)
- `lib/core/config/beta_testers.dart`

### Services (4 ไฟล์)
- `lib/core/services/device_id_service.dart`
- `lib/core/services/energy_token_service.dart`
- `lib/core/services/energy_service.dart`
- `lib/core/services/welcome_offer_service.dart`

### Models (1 ไฟล์ + 1 generated)
- `lib/core/models/energy_transaction.dart`
- `lib/core/models/energy_transaction.g.dart` (auto-generated)

### UI (3 ไฟล์)
- `lib/features/energy/widgets/energy_badge.dart`
- `lib/features/energy/widgets/no_energy_dialog.dart`
- `lib/features/energy/presentation/energy_store_screen.dart`

---

## 📝 ไฟล์ที่ต้องแก้ (6+ ไฟล์)

### Core Files
- `lib/core/ai/gemini_service.dart` — เปลี่ยนจาก direct API → call Backend
- `lib/core/services/purchase_service.dart` — เพิ่ม 8 Energy packages
- `lib/main.dart` — เพิ่ม Energy initialization + Migration

### UI Files
- `lib/features/home/presentation/home_screen.dart` — เพิ่ม Energy Badge
- `lib/features/profile/presentation/profile_screen.dart` — ลบ "API Key" menu item
- `lib/features/onboarding/presentation/onboarding_screen.dart` — ลบ API Key setup step (ถ้ามี)

### Feature Files (6-8 ไฟล์ — ทุกที่ที่เรียก Gemini API)
- `lib/features/health/presentation/barcode_scanner_screen.dart`
- `lib/features/health/presentation/food_preview_screen.dart`
- `lib/features/health/presentation/nutrition_label_screen.dart`
- `lib/features/health/presentation/health_diet_tab.dart`
- และอื่นๆ ที่เรียก `geminiService.analyze...()` → เพิ่มการเช็ค Energy

---

## 🗑️ ไฟล์ที่ต้องลบ (1 ไฟล์)

- ❌ `lib/features/profile/presentation/api_key_screen.dart`

---

## ✅ Deliverables (ส่งให้พี่ตรวจ)

### 1. Screenshots (7 รูป)
- [ ] Energy Badge บน AppBar (แสดงเลข Energy)
- [ ] Energy Store Screen (แสดง 4 packages)
- [ ] No Energy Dialog (เมื่อ Energy = 0)
- [ ] Welcome Offer (ถ้า active — แสดง 40% OFF)
- [ ] Transaction History (แสดงประวัติการใช้)
- [ ] Fresh Install (แสดงว่าได้ 100 Energy)
- [ ] Beta Tester Account (แสดงว่าได้ 1,000 Energy)

### 2. Screen Recording (2 วิดีโอ)
- [ ] วิดีโอซื้อ Energy package (regular)
- [ ] วิดีโอซื้อ Welcome Offer package (40% OFF)

### 3. Logs
- [ ] Supabase Function Logs (แสดงว่ามี API calls)
- [ ] Flutter Logs (แสดง Energy balance changes)

### 4. Test Results
- [ ] Checklist ใน START_HERE.md (ติ๊กหมดทุกข้อ)
- [ ] Test cases ใน Implementation Guide (Pass ทุก case)

### 5. Code
- [ ] Commit history (แบ่ง phase ชัดเจน)
- [ ] No `.env` file in git
- [ ] No TODO comments left (แก้หมดแล้ว)

---

## 🆘 เมื่อติดปัญหา

### 1. ตรวจสอบ Troubleshooting Guide
📍 ENERGY_IMPLEMENTATION_GUIDE.md → หน้า 120-125

### 2. Debug Commands
```dart
// Device ID
await DeviceIdService.printDeviceId();

// Beta Tester Status
BetaTesters.printStatus('user@email.com');

// Energy Balance
final balance = await energyService.getBalance();
print('Balance: $balance');

// Energy Token
final token = await energyService.generateEnergyToken();
final decoded = EnergyTokenService.decodeToken(token);
print(decoded);
```

### 3. Logs
```bash
# Backend
supabase functions logs analyze-food

# Flutter
flutter logs
```

### 4. ถามพี่
- สรุปปัญหา
- แนบ error logs
- บอกว่าทำถึง step ไหนแล้ว

---

## ⏱️ Timeline

| Day | Tasks | Hours |
|-----|-------|-------|
| **Day 1 AM** | อ่านเอกสาร + Setup Backend | 3-4 |
| **Day 1 PM** | สร้าง Services + Models | 3-4 |
| **Day 2 AM** | UI + Update Existing Files | 3-4 |
| **Day 2 PM** | Testing + Deployment | 2-3 |

**Total:** 11-15 ชั่วโมง (~2 วันทำงาน)

---

## 🎓 Learning Outcomes

หลังจากทำโปรเจคนี้เสร็จ คุณจะได้เรียนรู้:

✅ Backend API Development (Supabase Edge Functions)  
✅ Security (HMAC signature, API key protection)  
✅ Energy/Credit System Implementation  
✅ Device ID Binding (Anti-abuse)  
✅ In-App Purchase (IAP) Integration  
✅ Migration Strategy (Existing users)  
✅ Timer System (Welcome Offer countdown)  
✅ Analytics Integration  
✅ Database Design (Isar transactions)  
✅ UI/UX for Monetization  

---

## 📞 Contact

**ถ้ามีคำถาม:**
1. อ่าน START_HERE.md ก่อน
2. อ่าน Troubleshooting Guide
3. ลอง debug เอง (ใช้ debug commands ข้างบน)
4. ถ้าติดเกิน 30 นาที → ถามพี่ทันที (อย่าเสียเวลา)

**เมื่อถาม ให้แนบ:**
- Error logs (screenshot หรือ copy text)
- บอกว่าทำถึง step ไหนแล้ว
- บอกว่าลองแก้อย่างไรไปแล้วบ้าง

---

## 💪 Final Words

คู่มือนี้ออกแบบมาให้ **คุณทำได้โดยไม่ต้องคิดเอง**

- ✅ โค้ดครบทุกไฟล์ (copy-paste ready)
- ✅ คำอธิบายละเอียดทุกขั้นตอน
- ✅ TODO comments บอกว่าต้องแก้อะไร
- ✅ Test cases ครบถ้วน
- ✅ Troubleshooting guide

**สิ่งที่คุณต้องทำ:**
1. อ่านให้เข้าใจ
2. Copy โค้ด
3. แก้ TODO
4. Test
5. Commit

**หากทำตามทุกขั้นตอน → จะสำเร็จแน่นอน! 🎉**

---

**Good luck! 🚀**

> เริ่มจาก START_HERE.md → KEY_DECISIONS.md → ENERGY_IMPLEMENTATION_GUIDE.md  
> หลังจากนั้นเรามาตรวจร่วมกัน!
