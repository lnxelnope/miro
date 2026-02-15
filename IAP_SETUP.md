# In-App Purchase Setup Guide

## ⚠️ สำคัญมาก: Setup ใน Google Play Console

ก่อนที่ In-App Purchase จะทำงานได้ ต้อง setup ใน Play Console ก่อน

---

## 📋 ขั้นตอนการ Setup

### 1. ไปที่ Play Console → Monetize

```
Google Play Console
→ เลือกแอป MIRO
→ Monetize → In-app products
→ Create product
```

### 2. สร้าง Product

#### Product Details:
- **Product ID**: `miro-pro` (ต้องตรงกับใน code)
- **Name**: `MIRO Pro`
- **Description**: `Unlock unlimited AI food analysis. No daily limits!`

#### Product Type:
เลือก **One-time purchase** (ซื้อครั้งเดียว ใช้ตลอด)

#### Pricing:
ตั้งราคาตามต้องการ เช่น:
- ไทย: ฿99
- สหรัฐ: $2.99
- หรือใช้ template pricing จาก Google

#### Status:
- ต้องเปลี่ยนเป็น **Active** ถึงจะใช้งานได้

---

## 🧪 การทดสอบ

### 1. Test Accounts (License Testing)

ไปที่ Play Console → Setup → License testing:

1. เพิ่ม Gmail ที่ใช้ทดสอบ
2. License response: เลือก `RESPOND_NORMALLY`
3. Save

**ข้อดี:**
- ไม่เสียเงินจริง
- สามารถซื้อซ้ำได้เรื่อยๆ
- ทดสอบได้ก่อน publish

### 2. วิธีทดสอบ

1. Build และ upload version ใหม่ (1.0.2+6) ไป Internal Testing
2. รอ Google ประมวลผล (5-30 นาที)
3. ติดตั้งจาก Play Store บน device ที่เป็น test account
4. เปิดแอป → Profile → กด "Upgrade to Pro"
5. ควรจะเห็น dialog ซื้อขึ้นมา พร้อมราคาที่ตั้งไว้
6. กด Subscribe/Buy
7. ถ้าเป็น test account จะไม่เสียเงินจริง แต่จะได้ Pro

### 3. ตรวจสอบ Logs

เปิด Android Studio → Logcat → filter: `PurchaseService`

จะเห็น log แบบนี้:
```
[PurchaseService] 🛒 IAP available: true
[PurchaseService] ✅ Purchase stream listening
[PurchaseService] ✅ Restore completed
[PurchaseService] 🛒 Querying product: miro-pro
[PurchaseService] ✅ Product found: MIRO Pro - ฿99.00
[PurchaseService] 🛒 Initiating purchase...
[PurchaseService] 📦 Received 1 purchase updates
[PurchaseService] ✅ Pro unlocked!
```

---

## ❌ ปัญหาที่พบบ่อย

### 1. ❌ "Product not found"

**สาเหตุ:**
- ยังไม่สร้าง product ใน Play Console
- Product ID ไม่ตรงกับ `miro-pro`
- Product status ยังไม่เป็น "Active"
- แอปยังไม่ได้ publish ไปยัง internal test track

**วิธีแก้:**
1. ตรวจสอบ Play Console → Monetize → In-app products
2. ต้องมี product ID: `miro-pro`
3. ต้องเป็น **Active**
4. แอปต้องมี version ที่ publish แล้ว (byอย่างน้อย Internal test)

### 2. ❌ "IAP not available"

**สาเหตุ:**
- เครื่องไม่มี Google Play Services
- ติดตั้งจาก APK โดยตรง (ไม่ได้ติดตั้งผ่าน Play Store)

**วิธีแก้:**
- ต้องติดตั้งจาก Play Store เท่านั้น
- ใช้ Internal Test track สำหรับทดสอบ

### 3. ❌ กดซื้อแล้วไม่เกิดอะไร

**สาเหตุ:**
- ขาด BILLING permission (✅ แก้แล้วใน version 1.0.2)
- Purchase stream ไม่ทำงาน
- Error แต่ไม่แสดง

**วิธีแก้:**
- ดู Logcat จะบอก error
- Update เป็น version 1.0.2+6 (มี debug logging)

---

## 🔐 Security Best Practices

### ✅ ที่เราทำแล้ว:
- ใช้ `buyNonConsumable` สำหรับ one-time purchase
- เรียก `completePurchase()` หลังประมวลผลเสร็จ
- Restore purchases เมื่อเปลี่ยนเครื่อง
- เก็บ Pro status ใน SharedPreferences (offline-first)

### ⚠️ ที่ควรเพิ่มใน Production:
- Server-side verification (ตรวจสอบ purchase ที่ server)
- Receipt validation กับ Google Play API
- Prevent piracy และ unauthorized unlocks

**Note:** สำหรับ v1.0 เราใช้ client-side verification เพียงอย่างเดียว (เพียงพอสำหรับแอปเล็กๆ)

---

## 📱 การ Restore Purchase

ถ้าผู้ใช้เปลี่ยนเครื่อง หรือลบแอป:

1. ติดตั้งแอปใหม่
2. ไป Profile → "Restore Purchase"
3. Google จะตรวจสอบว่าเคยซื้อแล้วหรือยัง
4. ถ้าซื้อแล้ว → ปลดล็อค Pro ให้ทันที

---

## 🚀 Build และ Upload

```bash
# 1. Clean
flutter clean
flutter pub get

# 2. Build
flutter build appbundle --release

# 3. Upload
# build/app/outputs/bundle/release/app-release.aab
```

Upload ไปยัง Internal Testing track แล้วทดสอบใหม่

---

## ✅ Checklist

- [x] เพิ่ม BILLING permission ใน AndroidManifest
- [x] เพิ่ม debug logging ใน PurchaseService
- [x] เพิ่ม loading dialog และ error messages
- [ ] สร้าง product ใน Play Console (`miro-pro`)
- [ ] ตั้งเป็น Active
- [ ] ตั้งราคา
- [ ] เพิ่ม test account ใน License testing
- [ ] Build version 1.0.2+6
- [ ] Upload ไป Internal Testing
- [ ] ทดสอบบนเครื่องจริง
- [ ] ตรวจสอบ Logcat
- [ ] ทดสอบซื้อและ restore

---

## 📞 Support

ถ้ายังมีปัญหา ให้ส่ง Logcat output มา จะช่วย debug ต่อครับ

```bash
adb logcat | grep -E "PurchaseService|IAP"
```
