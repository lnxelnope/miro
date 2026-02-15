# Quick Start Guide for Junior Developer

> **📌 อ่านไฟล์นี้ก่อนเริ่มทำงาน - ข้อมูลสำคัญทั้งหมดอยู่ที่นี่!**

---

## ✅ Setup ที่ทำเสร็จแล้ว (โดย Senior)

### 1. Firebase Project
```
Project ID:     miro-d6856
Project Number: 65396857547
Region:         us-central1
Status:         ✅ Ready
```

### 2. Google Cloud Service Account
```
Email:          play-store-manager@miro-d6856.iam.gserviceaccount.com
Purpose:        Google Play Purchase Verification
Permissions:    View financial data, Manage orders
Status:         ✅ Added to Play Console
```

### 3. Firebase Secret
```
Secret Name:    GOOGLE_SERVICE_ACCOUNT_JSON
Status:         ✅ Set (version 1)
Location:       Firebase Functions Secrets
```

**ตรวจสอบว่ามี Secret:**
```bash
cd functions
firebase functions:secrets:access GOOGLE_SERVICE_ACCOUNT_JSON
# ควรเห็น JSON ที่มี client_email: "play-store-manager@..."
```

### 4. APIs Enabled
```
✅ Google Play Developer API
✅ Firebase Admin SDK
✅ Cloud Functions
✅ Firestore
```

---

## 🚀 เริ่มทำงาน (3 Steps)

### Step 1: อ่านเอกสาร Overview
```bash
# เปิดไฟล์นี้อ่าน
00_OVERVIEW.md
```

**สิ่งที่จะได้:**
- เข้าใจปัญหาที่จะแก้
- เข้าใจสถาปัตยกรรมเดิม vs ใหม่
- รู้ว่าต้องทำอะไรบ้าง

**เวลา:** 15-30 นาที

---

### Step 2: ทำ Phase 1 (CRITICAL)
```bash
# เปิดไฟล์นี้
01_PHASE1_FIRESTORE.md
```

**สิ่งที่จะทำ:**
1. Setup Firestore Rules
2. เขียน Backend (Firestore helpers, แก้ analyzeFood)
3. สร้าง syncBalance endpoint
4. แก้ Client (EnergyService)
5. Test ตาม checklist

**เวลา:** 1-2 วัน

**เมื่อเสร็จ Phase 1:**
- ✅ Balance อยู่ Server (Firestore)
- ✅ Client ไม่สามารถแก้ balance ได้
- ✅ Token forgery ใช้ไม่ได้

---

### Step 3: ทำ Phase 2 (CRITICAL)
```bash
# เปิดไฟล์นี้
02_PHASE2_PURCHASE.md
```

**⚠️ สำคัญ: ข้าม Step 2.1 ได้เลย!**

เพราะ Senior setup ให้แล้ว:
- ✅ Service Account สร้างแล้ว
- ✅ Play Console permissions set แล้ว
- ✅ Firebase Secret มีแล้ว

**เริ่มจาก Step 2.2 เลย:**
1. Install `googleapis` package
2. เขียน `verifyPurchase.ts`
3. แก้ `PurchaseService` (Client)
4. Test ตาม checklist

**เวลา:** 1-2 วัน

**เมื่อเสร็จ Phase 2:**
- ✅ Purchase verify กับ Google Play API
- ✅ Duplicate purchase ถูกบล็อก
- ✅ ซื้อปลอมไม่ได้

---

## 📋 Checklist การทำงาน

### ก่อนเริ่ม
- [ ] Git clone repository แล้ว
- [ ] Flutter SDK ติดตั้งแล้ว
- [ ] Firebase CLI ติดตั้งแล้ว (`npm install -g firebase-tools`)
- [ ] Firebase login แล้ว (`firebase login`)
- [ ] เปิด Firebase Console ดูได้: https://console.firebase.google.com/project/miro-d6856
- [ ] เปิด Play Console ดูได้: https://play.google.com/console
- [ ] ตรวจสอบ Secret: `firebase functions:secrets:access GOOGLE_SERVICE_ACCOUNT_JSON`

### Phase 1 (Day 1-2)
- [ ] อ่าน `01_PHASE1_FIRESTORE.md` จบ
- [ ] ทำ Step 1.1: Setup Firestore
- [ ] ทำ Step 1.2: Backend Helpers
- [ ] ทำ Step 1.3: แก้ analyzeFood
- [ ] ทำ Step 1.4: สร้าง syncBalance
- [ ] ทำ Step 1.5: แก้ EnergyService
- [ ] Deploy Backend: `firebase deploy --only functions`
- [ ] Test ตาม `99_TESTING_CHECKLIST.md` (Section Phase 1)
- [ ] Commit code: `git commit -m "feat: Phase 1 - Firestore Balance"`

### Phase 2 (Day 3-4)
- [ ] อ่าน `02_PHASE2_PURCHASE.md` จบ
- [ ] **ข้าม Step 2.1** (Senior ทำแล้ว)
- [ ] ทำ Step 2.2: Backend verifyPurchase
- [ ] ทำ Step 2.3: Client PurchaseService
- [ ] Deploy Backend: `firebase deploy --only functions`
- [ ] Test ตาม `99_TESTING_CHECKLIST.md` (Section Phase 2)
- [ ] Commit code: `git commit -m "feat: Phase 2 - Purchase Verification"`

### Phase 3 (Day 5) - Optional but Recommended
- [ ] อ่าน `03_PHASE3_ENCRYPTION.md`
- [ ] ทำตามขั้นตอน
- [ ] Test
- [ ] Commit code

### Phase 4 (Day 6) - Optional
- [ ] อ่าน `04_PHASE4_APPCHECK.md`
- [ ] ตัดสินใจว่าจะทำหรือไม่
- [ ] ถ้าทำ: ทำตามขั้นตอน

---

## 🛠️ Commands ที่ใช้บ่อย

### Firebase
```bash
# Login
firebase login

# ดู project
firebase projects:list

# เลือก project
firebase use miro-d6856

# Deploy functions
firebase deploy --only functions

# Deploy functions เฉพาะตัว
firebase deploy --only functions:analyzeFood
firebase deploy --only functions:syncBalance
firebase deploy --only functions:verifyPurchase

# Deploy Firestore rules
firebase deploy --only firestore:rules

# ดู logs
firebase functions:log --limit 50

# ดู logs เฉพาะ function
firebase functions:log analyzeFood --limit 20

# ดู secrets
firebase functions:secrets:access GOOGLE_SERVICE_ACCOUNT_JSON
```

### Flutter
```bash
# Run debug
flutter run

# Build release APK
flutter build apk --release

# Clean
flutter clean
flutter pub get

# Analyze
flutter analyze
```

### Git
```bash
# สร้าง branch ใหม่
git checkout -b feature/energy-security-phase1

# Check status
git status

# Add & commit
git add .
git commit -m "feat: Phase 1 complete"

# Push
git push origin feature/energy-security-phase1
```

---

## 📞 เมื่อไหร่ควรถาม Senior

### ✅ ถามได้เลย:
- ไม่เข้าใจขั้นตอนในเอกสาร
- Error ที่ไม่รู้จะแก้ยังไง (ลองแก้ 15-30 นาทีแล้ว)
- ไม่แน่ใจว่าทำถูกหรือเปล่า
- ต้องการ clarify requirements

### 🟡 ลองแก้ก่อน 15-30 นาที:
- Syntax errors
- Import errors
- Package not found
- Compilation errors

### ❌ อย่าถาม:
- ยังไม่ได้อ่านเอกสาร
- ยังไม่ได้ลองทำเลย
- ถามแล้วไม่ทำตามคำแนะนำ

---

## 🎯 Expected Outcome

### หลัง Phase 1-2 เสร็จ (3-4 วัน):

**Security Improvements:**
```
✅ Client ไม่สามารถแก้ balance ได้
✅ Token forgery ไม่ได้ผล
✅ Purchase ต้อง verify กับ Google Play
✅ Duplicate purchase ถูกบล็อก
✅ Server-side validation ครบถ้วน
```

**Architecture:**
```
Before:
  Client ← balance (SharedPreferences, ไม่ปลอดภัย)
  
After:
  Server (Firestore) ← balance (Source of Truth)
  Client ← cache only
```

**Firestore Structure:**
```
/energy_balances/{deviceId}
  - balance: number
  - lastUpdated: timestamp
  
/purchase_records/{purchaseToken_hash}
  - productId: string
  - energyAmount: number
  - verifiedAt: timestamp
  - status: "verified"
```

---

## ⚠️ Important Notes

### Security
- ❌ **อย่า commit** JSON key file เข้า Git
- ❌ **อย่าแชร์** Firebase Secret ไปที่อื่น
- ✅ **ใช้** `.gitignore` กับไฟล์ sensitive

### Testing
- ✅ Test ทุกขั้นตอนก่อนไป step ถัดไป
- ✅ เช็ค Firebase Console real-time
- ✅ เก็บ screenshot ผลลัพธ์
- ✅ Test ทั้ง debug และ release build

### Code Quality
- ✅ เขียน log ให้ชัดเจน
- ✅ Handle errors ให้ครบ
- ✅ Comment code ที่ซับซ้อน
- ✅ ตั้งชื่อ variable ให้อ่านง่าย

### Deployment
- ✅ Test local ก่อน deploy
- ✅ Deploy ทีละ function (ถ้าเป็นไปได้)
- ✅ ดู logs หลัง deploy
- ✅ Test production หลัง deploy

---

## 📚 เอกสารเพิ่มเติม

- [Firebase Documentation](https://firebase.google.com/docs)
- [Firestore Guide](https://firebase.google.com/docs/firestore)
- [Cloud Functions Guide](https://firebase.google.com/docs/functions)
- [Google Play Billing](https://developer.android.com/google/play/billing)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)

---

## 🎉 Ready to Start!

**ขั้นตอนถัดไป:**

1. ✅ ตรวจสอบ checklist "ก่อนเริ่ม" ข้างบน
2. 📖 อ่าน `00_OVERVIEW.md`
3. 🚀 เริ่มทำ `01_PHASE1_FIRESTORE.md`

**Good luck! คุณทำได้! 💪**

---

*Quick Start Guide*  
*Version: 1.0*  
*Last Updated: 15 Feb 2026*  
*Project: MIRO Energy Security Upgrade*
