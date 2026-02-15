# 🚀 START HERE — สำหรับ Junior Developer

> **เป้าหมาย:** แปลง MIRO จาก BYOK → Energy System (Backend Proxy)  
> **ระยะเวลา:** 1 วันทำงาน (6-8 ชั่วโมง)  
> **ความยาก:** ⭐⭐⭐ (ปานกลาง — ทำตามได้ไม่ต้องคิดเอง)

---

## 📚 อ่านไฟล์ตามลำดับนี้

### 1️⃣ KEY_DECISIONS.md (หน้า 1-12)
⏱️ **15 นาที**  
📖 อ่านทั้งหมดเพื่อรู้ requirement และ decisions ที่ตัดสินใจไปแล้ว

**สิ่งสำคัญที่ต้องจำ:**
- Backend: Supabase Edge Functions
- Beta testers → 1,000 Energy
- Welcome Offer → เริ่มหลังใช้ 3 ครั้ง, 40% OFF, 24 ชั่วโมง, ซื้อได้ 1 package
- No refund (ยกเว้น error)

---

### 2️⃣ ENERGY_MIGRATION_PLAN.md (หน้า 13-39)
⏱️ **20 นาที**  
📖 อ่านเพื่อเข้าใจภาพรวม (reference only — ไม่ใช่คู่มือเขียนโค้ด)

**สิ่งสำคัญที่ต้องจำ:**
- 1 Energy = $0.00035 cost
- Packages: 100, 550, 1200, 2000 Energy
- Prices: $0.99, $4.99, $7.99, $9.99

---

### 3️⃣ ENERGY_IMPLEMENTATION_GUIDE.md ⭐ (หน้า 40-133)
⏱️ **60-90 นาที อ่าน + 4-6 ชั่วโมงเขียนโค้ด**  
📖 **คู่มือหลัก — ทำตามนี้ทีละ step**

**โครงสร้าง:**
- Step 1-2: Setup Backend (Supabase)
- Step 3: สร้าง Beta Testers Config
- Step 4: สร้าง Services (5 ไฟล์)
- Step 5: UI Components (3 ไฟล์)
- Step 6: Update Existing Files
- Step 7: Remove BYOK
- Step 8: Migration Code
- Step 9: Google Play IAP
- Step 10: Testing & Deployment

**วิธีใช้:**
1. เปิดไฟล์นี้ควบคู่กับ IDE
2. Copy โค้ดที่ให้มา
3. แก้ TODO comments (URL, API key, etc.)
4. Test ทุก step

---

### 4️⃣ BETA_TESTERS_SETUP.md (หน้า 134-145)
⏱️ **10 นาที**  
📖 อ่านเมื่อถึง Step "Create Beta Testers Configuration"

**สิ่งที่ต้องทำ:**
- เพิ่มรายชื่อ email ของ beta testers ใน `beta_testers.dart`
- Test กับ beta tester account → ควรได้ 1,000 Energy

---

## ⚡ Quick Reference

### ไฟล์ที่ต้องสร้างใหม่ (12 ไฟล์)

#### Configuration (1 ไฟล์)
```
lib/core/config/
  └── beta_testers.dart
```

#### Services (4 ไฟล์)
```
lib/core/services/
  ├── device_id_service.dart
  ├── energy_token_service.dart
  ├── energy_service.dart
  └── welcome_offer_service.dart
```

#### Models (1 ไฟล์)
```
lib/core/models/
  └── energy_transaction.dart (+ energy_transaction.g.dart)
```

#### UI Components (3 ไฟล์ + 1 folder)
```
lib/features/energy/
  ├── widgets/
  │   ├── energy_badge.dart
  │   └── no_energy_dialog.dart
  └── presentation/
      └── energy_store_screen.dart
```

#### Backend (1 folder)
```
supabase/functions/
  └── analyze-food/
      └── index.ts
```

---

### ไฟล์ที่ต้องแก้ไข (5 ไฟล์)

```
lib/
  ├── core/ai/gemini_service.dart (เรียก Backend)
  ├── core/services/purchase_service.dart (เพิ่ม 8 packages)
  ├── features/home/presentation/home_screen.dart (เพิ่ม Energy Badge)
  ├── features/profile/presentation/profile_screen.dart (ลบ API Key menu)
  └── main.dart (เพิ่ม Migration code)

+ ทุกไฟล์ที่เรียก geminiService.analyze...() (เช็ค Energy ก่อน)
```

---

### ไฟล์ที่ต้องลบ (1 ไฟล์)

```
❌ lib/features/profile/presentation/api_key_screen.dart
```

---

## 🔑 TODO: สิ่งที่ต้องเปลี่ยนในโค้ด

เมื่อ copy โค้ดจาก Implementation Guide มา ต้องแก้ตรงนี้:

### 1. Supabase Credentials
```dart
// ใน gemini_service.dart
static const String _backendUrl = 
    'https://YOUR_PROJECT_REF.supabase.co/functions/v1/analyze-food';
    // ↑ เปลี่ยนเป็น URL จริง
    
static const String _supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY_HERE';
    // ↑ เปลี่ยนเป็น anon key จริง
```

### 2. Encryption Secret
```dart
// ใน energy_token_service.dart
static const String _encryptionSecret = 'YOUR_64_CHAR_SECRET_HERE_CHANGE_THIS';
    // ↑ ต้องเหมือนกับที่ตั้งใน Supabase Backend ทุกตัวอักษร!
```

**วิธีสร้าง Secret:**
```bash
# Windows PowerShell
[System.Convert]::ToBase64String((1..48 | ForEach-Object { Get-Random -Maximum 256 }))

# macOS/Linux
openssl rand -base64 48
```

### 3. Beta Testers List
```dart
// ใน beta_testers.dart
static const List<String> emails = [
  'tester1@gmail.com',    // ← เพิ่มรายชื่อจริงตรงนี้
  'tester2@hotmail.com',
  // ... เพิ่มต่อ
];
```

### 4. Gemini API Key (Backend)
```bash
# ตั้งใน Supabase Dashboard → Edge Functions → Secrets
GEMINI_API_KEY = AIzaSy...your_actual_key_here
ENERGY_ENCRYPTION_SECRET = (same as above)
```

---

## ✅ Checklist (ติ๊กเมื่อทำเสร็จ)

### เตรียมความพร้อม
- [ ] อ่าน KEY_DECISIONS.md ครบ
- [ ] อ่าน ENERGY_IMPLEMENTATION_GUIDE.md (Architecture)
- [ ] ติดตั้ง Supabase CLI
- [ ] สร้าง Supabase Project
- [ ] Pull โค้ดล่าสุด

### Backend (1-2 ชั่วโมง)
- [ ] สร้าง `.env` file (supabase/.env)
- [ ] ตั้ง Secrets ใน Supabase Dashboard
- [ ] Copy โค้ด `analyze-food/index.ts`
- [ ] Deploy: `supabase functions deploy analyze-food`
- [ ] Test ด้วย curl

### Configuration (15 นาที)
- [ ] สร้าง `beta_testers.dart`
- [ ] เพิ่มรายชื่อ email ทั้งหมด

### Services (2-3 ชั่วโมง)
- [ ] สร้าง `device_id_service.dart`
- [ ] สร้าง `energy_token_service.dart` (แก้ secret!)
- [ ] สร้าง `energy_transaction.dart`
- [ ] Run: `flutter pub run build_runner build`
- [ ] สร้าง `energy_service.dart`
- [ ] สร้าง `welcome_offer_service.dart`

### Update Files (1 ชั่วโมง)
- [ ] แก้ `gemini_service.dart` (แก้ URL + anon key!)
- [ ] แก้ `purchase_service.dart`
- [ ] อัพเดท AI call points (6-8 ไฟล์)

### UI (1-2 ชั่วโมง)
- [ ] สร้าง `energy_badge.dart`
- [ ] สร้าง `no_energy_dialog.dart`
- [ ] สร้าง `energy_store_screen.dart`
- [ ] เพิ่ม Badge ใน AppBar

### Cleanup (15 นาที)
- [ ] ลบ `api_key_screen.dart`
- [ ] แก้ `profile_screen.dart`
- [ ] แก้ `onboarding_screen.dart`

### Migration (30 นาที)
- [ ] อัพเดท `main.dart`
- [ ] เพิ่ม Migration code

### IAP (30 นาที)
- [ ] สร้าง 8 products ใน Play Console
- [ ] Setup test accounts

### Testing (1-2 ชั่วโมง)
- [ ] Test Backend (curl)
- [ ] Test fresh install → 100 Energy
- [ ] Test reinstall → no duplicate gift
- [ ] Test AI analysis → -1 Energy
- [ ] Test 3rd use → Welcome Offer starts
- [ ] Test purchase (regular)
- [ ] Test purchase (welcome)
- [ ] Test beta tester → 1,000 Energy
- [ ] Test no energy → dialog

### Deployment (1 ชั่วโมง)
- [ ] Deploy Backend final
- [ ] Build app: `flutter build appbundle --release`
- [ ] Upload to Play Console
- [ ] Test on real device
- [ ] Monitor logs

---

## 🆘 ถ้าติด

1. อ่าน **Troubleshooting** ใน Implementation Guide (หน้า 120-125)
2. ดู logs: `supabase functions logs analyze-food`
3. Debug tools:
   ```dart
   await DeviceIdService.printDeviceId();
   BetaTesters.printStatus(email);
   final balance = await energyService.getBalance();
   ```
4. ถามพี่ (แนบ error logs)

---

## 📊 Expected Time

| Phase | Time |
|-------|------|
| อ่านเอกสาร | 1-2 ชั่วโมง |
| Backend Setup | 1-2 ชั่วโมง |
| Services + Models | 2-3 ชั่วโมง |
| UI Components | 1-2 ชั่วโมง |
| Update Existing | 1 ชั่วโมง |
| Testing | 1-2 ชั่วโมง |
| Deployment | 1 ชั่วโมง |
| **Total** | **8-13 ชั่วโมง** |

> แนะนำ: แบ่งเป็น 2 วัน (Day 1: Backend + Services, Day 2: UI + Testing)

---

## 🎯 เมื่อเสร็จแล้ว

ส่งให้พี่เช็ค:
- ✅ Screenshot Energy Store (แสดง packages ทั้งหมด)
- ✅ Screenshot Energy Badge บน AppBar
- ✅ Screenshot Welcome Offer (ถ้า active)
- ✅ Video ซื้อ Energy package
- ✅ Supabase Function logs (แสดงว่าเรียกได้)
- ✅ Test results (pass ทุก case)

---

**Let's go! 💪 คุณทำได้! 🚀**

> หลังจากนั้นเรามาตรวจร่วมกัน — ไม่ต้องกังวล มีคู่มือครบ!
