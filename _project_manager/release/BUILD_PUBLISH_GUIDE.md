# Step 37: Build & Publish to Google Play Store — คู่มือฉบับย่อ

> **สำหรับ:** Developer  
> **เวลาโดยประมาณ:** 3-4 ชั่วโมง + รอ review 1-7 วัน

---

## ⚠️ ก่อนเริ่ม — ตรวจสอบ

- [ ] Testing ผ่าน Step 36 ทั้งหมด (ไม่มี Bug สูง)
- [ ] มี Privacy Policy URL แล้ว (จาก Step 35)
- [ ] มี App Icon แล้ว (จาก Step 34)
- [ ] API Key ไม่ได้หลุดอยู่ใน code
- [ ] `.gitignore` มี `key.properties`, `*.jks`

---

## 🔧 ขั้นตอนการทำงาน

### Step 1: สร้าง Signing Key

เปิด PowerShell → รันคำสั่ง:

```powershell
# Windows - ใช้ keytool จาก Android Studio
& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -genkey -v -keystore miro-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias miro
```

> **หมายเหตุ:** ถ้า path Android Studio ของคุณต่างออกไป ให้ค้นหา `keytool.exe` ที่อื่น

**จะถาม:**
- Enter keystore password: [ตั้งรหัสผ่าน → จำไว้!]
- Re-enter new password: [พิมพ์ซ้ำ]
- What is your first and last name? [ชื่อ-นามสกุล]
- What is the name of your organizational unit? [ทีม]
- What is the name of your organization? [บริษัท/ชื่อตัวเอง]
- What is the name of your City or Locality? [เมือง]
- What is the name of your State or Province? [จังหวัด]
- What is the two-letter country code for this unit? [TH]

**ย้ายไฟล์ไปเก็บที่ปลอดภัย:**
```bash
move miro-release-key.jks android/
```

---

### Step 2: สร้าง key.properties

1. คัดลอก `android/key.properties.template` เป็น `android/key.properties`
2. แก้ไขรหัสผ่านและ path ให้ถูกต้อง

**ไฟล์:** `android/key.properties`
```properties
storePassword=รหัสผ่านที่ตั้ง
keyPassword=รหัสผ่านที่ตั้ง
keyAlias=miro
storeFile=../android/miro-release-key.jks
```

> **ห้าม commit ไฟล์นี้!** ตรวจว่า `.gitignore` มี `android/key.properties`

---

### Step 3: แก้ applicationId ใน build.gradle.kts

**ไฟล์:** `android/app/build.gradle.kts`

เปลี่ยน:
- `namespace = "com.example.mirocal"` → เป็นชื่อ package ที่ unique ของคุณ
- `applicationId = "com.example.mirocal"` → ต้องตรงกับ namespace

**ตัวอย่าง:**
```kotlin
namespace = "com.yourname.mirocal"
applicationId = "com.yourname.mirocal"
```

> **สำคัญ:** applicationId ต้อง unique บน Play Store และเปลี่ยนทีหลังไม่ได้!

---

### Step 4: Build Release AAB

```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

**ผลลัพธ์:** `build/app/outputs/bundle/release/app-release.aab`

**ตรวจขนาด:**
```bash
dir build\app\outputs\bundle\release\app-release.aab
```

> ขนาดควร < 50MB

---

### Step 5: สมัคร Google Play Console

1. ไปที่ https://play.google.com/console
2. ล็อกอิน Google Account
3. จ่าย $25 (จ่ายครั้งเดียว)
4. กรอกข้อมูล developer

---

### Step 6: สร้าง App ใหม่

1. กด "Create app"
2. App name: **Miro Cal**
3. Default language: **ไทย**
4. App or game: **App**
5. Free or paid: **Free** (เราใช้ IAP)

---

### Step 7: ตั้ง In-App Product

1. ไปที่ **Monetize → Products → In-app products**
2. กด **Create product**
3. กรอก:
   - Product ID: `miro_cal_pro`
   - Name: Miro Cal Pro
   - Description: ปลดล็อค AI วิเคราะห์อาหารไม่จำกัด
   - Price: 199 THB (หรือ 299 THB)
   - Status: Active

---

### Step 8: กรอก Store Listing

#### Main Store Listing

- App name: Miro Cal
- Short description: บันทึกอาหาร นับแคลอรี่ ด้วย AI วิเคราะห์รูปถ่ายอัตโนมัติ
- Full description: ดูในคู่มือ Step 37

#### Upload Screenshots

- Phone Screenshots: 1080×1920 (4-8 รูป)
- Feature Graphic: 1024×500 (1 รูป)

---

### Step 9: กรอกข้อมูลอื่นๆ

#### App Content
- Privacy Policy URL: URL จาก Step 35
- App access: All functionality is available without special access
- Ads: No ads
- Content Rating: ทำแบบสอบถาม IARC

#### Data Safety
- Does your app collect or share user data? Yes
- Data types: Photos (optional), Health info
- Is data encrypted in transit? Yes
- Can users request data deletion? Yes

---

### Step 10: Upload AAB + Submit

1. ไปที่ **Release → Production**
2. กด **Create new release**
3. Upload `app-release.aab`
4. Release name: `1.0.0`
5. Release notes: (ดูในคู่มือ Step 37)
6. กด **Review release**
7. กด **Start rollout to Production**
8. **รอ review** — ครั้งแรกอาจใช้เวลา 3-7 วัน

---

## ✅ Checklist

- [ ] Signing key สร้างแล้ว + เก็บ backup ไว้ที่ปลอดภัย
- [ ] key.properties สร้างแล้ว + ไม่ commit
- [ ] build.gradle.kts แก้แล้ว (applicationId, signing, minify)
- [ ] `flutter build appbundle --release` สำเร็จ
- [ ] AAB ขนาด < 50MB
- [ ] Google Play Console สมัครแล้ว ($25)
- [ ] In-App Product `miro_cal_pro` สร้างแล้ว + Active
- [ ] Store Listing กรอกครบ
- [ ] Privacy Policy URL ใส่แล้ว
- [ ] Data Safety กรอกแล้ว
- [ ] Content Rating ทำแล้ว
- [ ] AAB upload แล้ว
- [ ] Submit for review แล้ว

---

## 🎉 ยินดีด้วย! แอป v1.0 อยู่บน Play Store แล้ว!
