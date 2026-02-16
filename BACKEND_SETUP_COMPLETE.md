# ✅ Backend Setup สำเร็จแล้ว!

## 🎉 สรุป

Backend สำหรับ MIRO Energy System **ทำงานพร้อมแล้ว!**

---

## 📍 ข้อมูล Backend

### Cloud Function URL
```
https://us-central1-miro-d6856.cloudfunctions.net/analyzeFood
```

### Secrets ที่ตั้งค่าแล้ว
1. **GEMINI_API_KEY**: `[REDACTED - ตรวจสอบใน Firebase Console → Functions → Secrets]`
2. **ENERGY_ENCRYPTION_SECRET**: `[REDACTED - ควรใช้ค่าที่สร้างจาก openssl rand -hex 32]`

---

## 📱 ขั้นตอนถัดไป (สำหรับ Junior Developer)

### 1. อัพเดท Flutter App

#### ไฟล์: `lib/core/services/gemini_service.dart`

```dart
class GeminiService {
  // ✅ Backend URL (พร้อมใช้งาน)
  static const String _backendUrl = 
      'https://us-central1-miro-d6856.cloudfunctions.net/analyzeFood';
  
  final EnergyService _energyService;
  
  GeminiService(this._energyService);
  
  // ... rest of code ...
}
```

#### ไฟล์: `lib/core/services/energy_token_service.dart`

```dart
class EnergyTokenService {
  // ⚠️ ต้องใช้ค่าเดียวกับ Backend!
  static const String _encryptionSecret = 
      'a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6a7b8c9d0e1f2';
  
  // ... rest of code ...
}
```

---

### 2. สร้างไฟล์ Service ทั้งหมด

ตามคู่มือใน **ENERGY_IMPLEMENTATION_GUIDE.md** ให้สร้างไฟล์เหล่านี้:

#### Service Files (สร้างใหม่):
- ✅ `lib/core/services/device_id_service.dart`
- ✅ `lib/core/services/energy_token_service.dart`
- ✅ `lib/core/services/energy_service.dart`
- ✅ `lib/core/services/welcome_offer_service.dart`

#### Model Files:
- ✅ `lib/core/models/energy_transaction.dart` (Isar model)

#### Config Files:
- ✅ `lib/core/config/beta_testers.dart`

#### UI Components:
- ✅ `lib/features/energy/widgets/energy_badge.dart`
- ✅ `lib/features/energy/widgets/no_energy_dialog.dart`
- ✅ `lib/features/energy/presentation/energy_store_screen.dart`

---

### 3. Dependencies

เพิ่มใน `pubspec.yaml`:

```yaml
dependencies:
  device_info_plus: ^10.1.0  # Device ID
  crypto: ^3.0.3              # HMAC signature
  http: ^1.2.0                # HTTP client
```

จากนั้นรัน:
```bash
flutter pub get
```

---

### 4. Google Play Console - IAP Products

สร้าง **8 products** (ดู ENERGY_IMPLEMENTATION_GUIDE.md Section 9):

**Regular Products:**
| Product ID | Price |
|------------|-------|
| `energy_100` | $0.99 |
| `energy_550` | $4.99 |
| `energy_1200` | $7.99 |
| `energy_2000` | $9.99 |

**Welcome Offer Products (40% OFF):**
| Product ID | Price |
|------------|-------|
| `energy_100_welcome` | $0.59 |
| `energy_550_welcome` | $2.99 |
| `energy_1200_welcome` | $4.79 |
| `energy_2000_welcome` | $5.99 |

---

### 5. Testing

#### Backend Test (ทดสอบ Backend ก่อน):

```bash
# Test 1: CORS Check
curl https://us-central1-miro-d6856.cloudfunctions.net/analyzeFood \
  -X OPTIONS

# Test 2: ต้องได้ 401 (เพราะไม่มี token)
curl https://us-central1-miro-d6856.cloudfunctions.net/analyzeFood \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"type":"text","prompt":"Analyze: Apple"}'
```

#### App Testing Checklist:
- [ ] Fresh install → ได้ 100 Energy
- [ ] Reinstall (same device) → ไม่ได้ Energy ซ้ำ
- [ ] AI analysis ครั้งที่ 1-2 → ใช้ได้
- [ ] AI analysis ครั้งที่ 3 → เริ่ม Welcome Offer
- [ ] Purchase Energy → Balance เพิ่ม
- [ ] Energy หมด → แสดง dialog

---

## 🔧 Troubleshooting

### ❌ "Insufficient energy" แม้มี Energy

**แก้ไข:**
- ตรวจสอบว่า `_encryptionSecret` ในแอปตรงกับ Backend (ดูด้านบน)
- ตรวจสอบว่า Backend URL ถูกต้อง

### ❌ CORS Error

**แก้ไข:**
Backend มี CORS เปิดอยู่แล้ว (`cors: '*'` ใน `analyzeFood.ts`)
ถ้ายังเจอ → ลอง restart แอป

### ❌ Connection Timeout

**แก้ไข:**
- ตรวจสอบ internet connection
- ทดสอบ URL ด้วย browser: https://us-central1-miro-d6856.cloudfunctions.net/analyzeFood

---

## 📊 Backend Monitoring

### ดู Logs:
```bash
firebase functions:log --only analyzeFood
```

### ดูใน Firebase Console:
https://console.firebase.google.com/project/miro-d6856/functions

---

## ✅ Checklist สำหรับ Junior

- [ ] อ่าน ENERGY_IMPLEMENTATION_GUIDE.md ทั้งหมด
- [ ] สร้าง Service files ทั้งหมด
- [ ] อัพเดท `gemini_service.dart` (Backend URL)
- [ ] อัพเดท `energy_token_service.dart` (Secret)
- [ ] สร้าง `beta_testers.dart` + เพิ่มรายชื่อ
- [ ] สร้าง UI components (Energy Badge, Store, Dialog)
- [ ] ทดสอบบน real device
- [ ] สร้าง IAP products ใน Play Console
- [ ] Test ทุก scenario

---

## 🆘 ถ้าติดปัญหา

1. อ่าน Troubleshooting section ใน ENERGY_IMPLEMENTATION_GUIDE.md
2. ตรวจสอบ Backend logs: `firebase functions:log`
3. ตรวจสอบ Flutter logs: `flutter logs`
4. ถามพี่ (แนบ logs มาด้วย)

---

## 📝 สิ่งสำคัญที่ต้องจำ

1. **Secret ต้องเหมือนกัน** ระหว่าง Backend และ App
2. **Backend URL** = `https://us-central1-miro-d6856.cloudfunctions.net/analyzeFood`
3. **Test บ่อยๆ** หลังจากแก้ไขแต่ละ file
4. **อย่าข้าม step** ทำตามลำดับใน Implementation Guide

---

**Good luck! คุณทำได้! 💪**

> หมายเหตุ: Backend พร้อมใช้งานแล้ว ให้โฟกัสที่ Flutter App ต่อไปเลย!
