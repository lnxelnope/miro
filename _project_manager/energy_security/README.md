# MIRO Energy Security Upgrade

> **📦 Documentation Package สำหรับ Junior Developer**  
> **เริ่มทำงานได้เลยโดยไม่ต้องถาม - ข้อมูลครบ 100%**

---

## 🚀 เริ่มต้นที่นี่

### สำหรับ Junior Developer:

**ขั้นตอนที่ 1:** อ่านไฟล์นี้ก่อน 👇

```
📖 00_QUICK_START.md
```

ไฟล์นี้มี:
- ✅ ข้อมูล Setup ทั้งหมดที่ Senior ทำให้แล้ว
- ✅ Checklist สิ่งที่ต้องทำ
- ✅ Commands ที่ใช้บ่อย
- ✅ วิธีถามเมื่อติดปัญหา

**เวลา:** 10 นาที

---

## 📚 โครงสร้างเอกสาร

```
energy_security/
│
├── README.md                    ← คุณอยู่ที่นี่
│
├── 00_QUICK_START.md           ← 🚀 เริ่มที่นี่! (อ่านก่อน)
├── 00_OVERVIEW.md              ← ภาพรวม Project
│
├── 01_PHASE1_FIRESTORE.md      ← 🔴 Day 1-2 (CRITICAL)
├── 02_PHASE2_PURCHASE.md       ← 🔴 Day 3-4 (CRITICAL)
├── 03_PHASE3_ENCRYPTION.md     ← 🟡 Day 5 (HIGH)
├── 04_PHASE4_APPCHECK.md       ← 🟢 Day 6 (OPTIONAL)
│
└── 99_TESTING_CHECKLIST.md     ← ✅ ใช้ test ทุก Phase
```

---

## 🎯 เป้าหมาย Project

**แก้ช่องโหว่ด้านความปลอดภัยของระบบ Energy ใน MIRO App**

### ปัญหาหลัก 4 ข้อ:

| # | ปัญหา | ผลกระทบ | Phase ที่แก้ |
|---|-------|---------|-------------|
| 1 | Balance เก็บใน SharedPreferences ไม่เข้ารหัส | User แก้ได้ → Energy ฟรี | Phase 1 |
| 2 | Backend เชื่อ Balance จาก Client | Token forgery → Energy ฟรี | Phase 1 |
| 3 | ไม่มี Server-side Purchase Verification | ซื้อปลอมได้ → Energy ฟรี | Phase 2 |
| 4 | Storage ไม่เข้ารหัส + HMAC ใน APK | Decompile APK → หา secret | Phase 3 |

### หลังแก้เสร็จ:

```
✅ Balance อยู่บน Server (Firestore) = Source of Truth
✅ Client แก้ balance ไม่ได้
✅ Purchase verify กับ Google Play API ก่อนเพิ่ม Energy
✅ Duplicate purchase ถูกบล็อก
✅ Local storage เข้ารหัส
✅ Security ระดับ Production-ready
```

---

## ⏱️ Timeline

| Phase | Priority | เวลา | สิ่งที่ได้ |
|-------|----------|------|----------|
| **Phase 1** | 🔴 CRITICAL | 1-2 วัน | Server-side Balance |
| **Phase 2** | 🔴 CRITICAL | 1-2 วัน | Purchase Verification |
| **Phase 3** | 🟡 HIGH | 0.5-1 วัน | Token Cleanup & Encryption |
| **Phase 4** | 🟢 OPTIONAL | 0.5 วัน | Firebase App Check |

**รวม:** 3-5 วัน (สำหรับ Phase 1-3 ที่สำคัญ)

---

## ✅ สิ่งที่ Senior Setup ให้แล้ว

```
✅ Firebase Project: miro-d6856
✅ Google Cloud Service Account: play-store-manager@miro-d6856.iam.gserviceaccount.com
✅ Google Play Developer API: Enabled
✅ Service Account Permissions: Set in Play Console
✅ Firebase Secret: GOOGLE_SERVICE_ACCOUNT_JSON (set)
✅ JSON Key: Secured in Dropbox
```

**Junior ไม่ต้องทำอะไรเพิ่ม → เริ่มเขียน code ได้เลย!**

---

## 📋 Quick Checklist

### ก่อนเริ่ม (5 นาที)
- [ ] Git clone repository
- [ ] Firebase CLI installed: `npm install -g firebase-tools`
- [ ] Firebase login: `firebase login`
- [ ] ตรวจสอบ Secret: `firebase functions:secrets:access GOOGLE_SERVICE_ACCOUNT_JSON`

### Phase 1 (1-2 วัน)
- [ ] อ่าน `01_PHASE1_FIRESTORE.md`
- [ ] Setup Firestore + เขียน Backend
- [ ] แก้ Client (EnergyService)
- [ ] Deploy + Test
- [ ] ✅ Client ไม่แก้ balance ได้

### Phase 2 (1-2 วัน)
- [ ] อ่าน `02_PHASE2_PURCHASE.md` (**ข้าม Step 2.1!**)
- [ ] เขียน verifyPurchase function
- [ ] แก้ PurchaseService
- [ ] Deploy + Test
- [ ] ✅ Purchase verify ทำงาน

### Phase 3 (0.5-1 วัน)
- [ ] อ่าน `03_PHASE3_ENCRYPTION.md`
- [ ] Token cleanup + SecureStorage
- [ ] Test
- [ ] ✅ Code cleanup เสร็จ

---

## 🎓 สำหรับ Junior Developer

### วิธีการทำงาน:

1. **อ่านก่อนเขียน**
   - อ่านเอกสารแต่ละ Phase ให้จบก่อน
   - ดูตัวอย่าง code ให้เข้าใจ
   - อ่าน Expected Result

2. **ทำทีละ Step**
   - อย่ารีบ
   - ทำครบทุก step
   - Test แต่ละ step ก่อนไปต่อ

3. **Test บ่อยๆ**
   - ใช้ `99_TESTING_CHECKLIST.md`
   - เช็ค Firebase Console real-time
   - เก็บ screenshot ผลลัพธ์

4. **Commit เมื่อเสร็จแต่ละ Phase**
   ```bash
   git add .
   git commit -m "feat: Phase 1 - Firestore Balance complete"
   git push
   ```

### เมื่อไหร่ควรถาม:

✅ **ถามได้:**
- ไม่เข้าใจขั้นตอน (หลังอ่านแล้ว)
- Error ที่แก้ไม่ได้ (ลองแล้ว 15-30 นาที)
- ไม่แน่ใจว่าทำถูกไหม

🟡 **ลองแก้ก่อน:**
- Syntax errors
- Import errors
- Compilation errors

❌ **อย่าถาม:**
- ยังไม่ได้อ่านเอกสาร
- ยังไม่ได้ลองทำ

---

## 📊 Expected Outcome

### หลังเสร็จ Phase 1-2 (3-4 วัน):

**Security Status:**
```
Before:
❌ Client แก้ balance ได้ (CRITICAL)
❌ Token forgery ทำได้ (CRITICAL)
❌ Purchase ปลอมได้ (CRITICAL)
❌ Duplicate purchase ได้ (CRITICAL)

After:
✅ Client แก้ balance ไม่ได้
✅ Token forgery ไม่ได้ผล
✅ Purchase verify กับ Google Play
✅ Duplicate purchase ถูกบล็อก
```

**Firestore Structure:**
```
/energy_balances/{deviceId}
  balance: number
  lastUpdated: timestamp
  welcomeGiftClaimed: boolean

/purchase_records/{purchaseToken_hash}
  deviceId: string
  productId: string
  energyAmount: number
  verifiedAt: timestamp
  orderId: string
  status: "verified"
```

---

## 🔒 Security Notes

### สิ่งที่ต้องระวัง:

1. **JSON Key File**
   - ❌ อย่า commit เข้า Git
   - ❌ อย่าแชร์ใน chat/email
   - ✅ เก็บไว้ปลอดภัย

2. **Firebase Secret**
   - ✅ ใช้ `firebase functions:secrets:set`
   - ❌ อย่า hardcode ใน code

3. **.gitignore**
   ```
   *.json
   miro-d6856-*.json
   .env
   ```

---

## 📞 Support

### เอกสารมี Troubleshooting Section

แต่ละ Phase มี section **Troubleshooting** พร้อมวิธีแก้:
- Common errors
- How to fix
- What to check

### ถ้ายังติด:

1. อ่าน Troubleshooting section
2. ลอง Google error message
3. เช็ค Firebase Console logs
4. ถาม Senior พร้อม:
   - Error message เต็มๆ
   - Steps to reproduce
   - สิ่งที่ลองแก้ไปแล้ว

---

## 🎉 Let's Start!

**ขั้นตอนแรก:**

```bash
# 1. อ่านไฟล์นี้
📖 00_QUICK_START.md

# 2. ตรวจสอบ setup
firebase functions:secrets:access GOOGLE_SERVICE_ACCOUNT_JSON

# 3. เริ่มทำ Phase 1
📖 01_PHASE1_FIRESTORE.md
```

---

## 📚 All Documents

```
1. 00_QUICK_START.md          - Setup info + Quick checklist
2. 00_OVERVIEW.md             - Project overview + Architecture
3. 01_PHASE1_FIRESTORE.md     - Firestore Balance (CRITICAL)
4. 02_PHASE2_PURCHASE.md      - Purchase Verification (CRITICAL)
5. 03_PHASE3_ENCRYPTION.md    - Token & Encryption (HIGH)
6. 04_PHASE4_APPCHECK.md      - Firebase App Check (OPTIONAL)
7. 99_TESTING_CHECKLIST.md    - Testing checklist for all phases
```

---

## 💪 You Got This!

เอกสารนี้เขียนมาเพื่อให้คุณทำงานได้เลยโดยไม่ต้องถาม

- ✅ ข้อมูลครบ 100%
- ✅ มี code examples ทั้งหมด
- ✅ มี test cases
- ✅ มี troubleshooting
- ✅ มี timeline
- ✅ มี checklist

**Just follow the steps และคุณจะทำสำเร็จ! 🚀**

---

*README*  
*Version: 1.0*  
*Last Updated: 15 Feb 2026*  
*Project: MIRO Energy Security Upgrade*  
*For: Junior Developer*
