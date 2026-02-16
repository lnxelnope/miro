# 🚀 LAUNCH CHECKLIST - MIRO Energy System

## ⚠️ CRITICAL: ต้องทำก่อน Launch ขึ้น Production!

---

## 🔴 Step 1: เปลี่ยน Welcome Gift กลับเป็น 100 Energy

**ไฟล์:** `lib/core/services/energy_service.dart`

**ค้นหา:**
```dart
static const int welcomeGift = 1000; // TODO: Change to 100 before launch!
```

**เปลี่ยนเป็น:**
```dart
static const int welcomeGift = 100; // Production: 100 Energy for new users
```

**ทำไมต้องเปลี่ยน?**
- ช่วง beta ตั้งไว้ 1,000 Energy เพื่อให้ testers ทดสอบได้ยาวๆ
- Production ควรให้ 100 Energy ตามแผน pricing strategy
- ถ้าลืมเปลี่ยน = user ใหม่ได้ 1,000 Energy ฟรี (เสียเปรียบทางธุรกิจ)

---

## ✅ Step 2: ตรวจสอบ Firebase Secrets

ตรวจสอบว่า secrets ครบถ้วน:

```bash
firebase functions:secrets:access GEMINI_API_KEY
firebase functions:secrets:access ENERGY_ENCRYPTION_SECRET
```

**Expected:**
- GEMINI_API_KEY: `[REDACTED - ตรวจสอบใน Firebase Console]`
- ENERGY_ENCRYPTION_SECRET: `[REDACTED - ตรวจสอบใน Firebase Secrets]`

---

## ✅ Step 3: ตรวจสอบ Backend URL

**ไฟล์:** `lib/core/ai/gemini_service.dart`

ตรวจสอบว่าใช้ Production URL:
```dart
static const String _backendUrl = 
    'https://us-central1-miro-d6856.cloudfunctions.net/analyzeFood';
```

---

## ✅ Step 4: ตรวจสอบ IAP Products ใน Google Play Console

**8 Products ที่ต้องมี:**

### Regular Products:
1. `energy_100` - $0.99 (100 Energy)
2. `energy_550` - $4.99 (550 Energy)
3. `energy_1200` - $7.99 (1,200 Energy)
4. `energy_2000` - $9.99 (2,000 Energy)

### Welcome Offer Products:
5. `energy_100_welcome` - $0.59 (100 Energy)
6. `energy_550_welcome` - $2.99 (550 Energy)
7. `energy_1200_welcome` - $4.79 (1,200 Energy)
8. `energy_2000_welcome` - $5.99 (2,000 Energy)

**สถานะ:** ทั้งหมดต้องเป็น `Active` และ `Available`

---

## ✅ Step 5: Build Release APK/AAB

```bash
flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info
```

**ตรวจสอบ:**
- [ ] Version code เพิ่มขึ้นจากเดิม
- [ ] Version name ถูกต้อง (เช่น 1.1.0)
- [ ] Obfuscation เปิดอยู่

---

## ✅ Step 6: Test บน Internal Testing Track

**Test Cases สำคัญ:**

### 1. Welcome Gift Test
- [ ] ลงครั้งแรก → ได้ **100 Energy** (ไม่ใช่ 1,000!)
- [ ] Uninstall + Reinstall → ไม่ได้ Energy ซ้ำ

### 2. AI Analysis Test
- [ ] วิเคราะห์อาหาร → หัก 1 Energy
- [ ] Balance แสดงถูกต้อง
- [ ] ใช้ครั้งที่ 3 → Welcome Offer เริ่มนับถอยหลัง 24 ชม.

### 3. Purchase Test
- [ ] ซื้อ Regular package → เพิ่ม Energy ถูกต้อง
- [ ] ซื้อ Welcome package → เพิ่ม Energy ถูกต้อง
- [ ] หลังซื้อ Welcome → ทุก welcome packages หายไป

### 4. Energy หมด Test
- [ ] Energy = 0 → แสดง NoEnergyDialog
- [ ] กดซื้อ → เปิด Energy Store

### 5. Backend Test
```bash
# ทดสอบ Backend API
curl -X POST https://us-central1-miro-d6856.cloudfunctions.net/analyzeFood \
  -H "Content-Type: application/json" \
  -H "x-energy-token: <TOKEN>" \
  -H "x-device-id: test-device" \
  -d '{"type":"image","prompt":"Analyze this food","imageBase64":"<BASE64>"}'
```

---

## ✅ Step 7: Monitor Logs (24 ชั่วโมงแรก)

### Firebase Functions Logs:
```bash
firebase functions:log --only analyzeFood --limit 100
```

**ตรวจสอบ:**
- [ ] ไม่มี error rate สูง (< 1%)
- [ ] Response time เฉลี่ย < 5 วินาที
- [ ] Token validation ผ่านทุกครั้ง

### Flutter App Logs:
```bash
flutter logs
```

**ตรวจสอบ:**
- [ ] ไม่มี crash rate สูง (< 0.1%)
- [ ] Energy transactions บันทึกถูกต้อง
- [ ] IAP transactions complete สำเร็จ

---

## ✅ Step 8: Analytics Setup

ตรวจสอบ Firebase Analytics events:
- `energy_received` (welcome_gift, purchase, etc.)
- `energy_consumed` (AI analysis)
- `energy_low` (balance < 10)
- `welcome_offer_started`
- `welcome_offer_expired`
- `purchase_completed`

---

## ✅ Step 9: Backup & Rollback Plan

### สำรอง:
- [ ] Git commit ล่าสุด tagged: `v1.1.0-beta`
- [ ] Firebase Functions code backup
- [ ] Database schema documented

### Rollback Plan:
ถ้าเจอปัญหาร้ายแรง:
1. Google Play Console → Halt rollout
2. Firebase Functions → Rollback to previous version
3. แก้ bug → Deploy hotfix → Resume rollout

---

## 📋 Final Checklist

- [ ] **CRITICAL:** เปลี่ยน welcomeGift = 100
- [ ] Firebase Secrets ครบถ้วน
- [ ] Backend URL ถูกต้อง
- [ ] IAP Products ครบ 8 รายการ
- [ ] Build release APK/AAB
- [ ] Test 5 scenarios ผ่านหมด
- [ ] Monitor logs 24h แรก
- [ ] Analytics tracking ครบ
- [ ] Backup & Rollback plan พร้อม

---

## 🎯 Success Metrics (Week 1)

**ตัวชี้วัด:**
- Welcome Gift claim rate > 95%
- AI usage rate > 70% (ใน users ที่มี Energy)
- IAP conversion rate > 2-5%
- Welcome Offer conversion rate > 10-15%
- Crash rate < 0.1%
- Backend error rate < 1%

---

## 📞 Support Plan

**ถ้ามีปัญหา:**
1. Check Firebase logs
2. Check Google Play Console crash reports
3. Check user reviews
4. Prepare hotfix within 24h

---

**Good luck with the launch! 🚀**

> Last updated: 2026-02-13  
> Version: 1.0
