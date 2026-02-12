# Step 37: Build & Publish to Google Play Store

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 3-4 ชั่วโมง + รอ review 1-7 วัน
> **ความยาก:** ปานกลาง (ต้องทำตามขั้นตอนถูกต้อง)
> **ต้องทำก่อน:** Step 36 (Testing & QA ผ่านหมดแล้ว)

---

## 🎯 เป้าหมาย

1. **สร้าง Signing Key** — สำหรับ sign APK/AAB
2. **แก้ build.gradle.kts** — ตั้ง applicationId + signing config
3. **Build Release AAB** — สร้างไฟล์ upload
4. **สมัคร Google Play Console** + สร้าง App
5. **ตั้ง In-App Product** (miro_cal_pro)
6. **กรอก Store Listing** + upload screenshots
7. **Upload AAB** + submit for review

---

## ⚠️ ก่อนเริ่ม — ตรวจสอบ

- [ ] Testing ผ่าน Step 36 ทั้งหมด (ไม่มี Bug สูง)
- [ ] มี Privacy Policy URL แล้ว (จาก Step 35)
- [ ] มี App Icon แล้ว (จาก Step 34)
- [ ] API Key ไม่ได้หลุดอยู่ใน code
- [ ] `.gitignore` มี `.env`, `key.properties`, `*.jks`

---

## 🔧 ขั้นตอนการทำงาน

### Step 1: สร้าง Signing Key

> **สำคัญมาก:** เก็บ keystore file + password ให้ดี!
> ถ้าหาย จะ update แอปบน Play Store **ไม่ได้อีกเลย**

เปิด Terminal → รันคำสั่ง:

#### Windows:
```bash
keytool -genkey -v -keystore miro-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias miro
```

#### จะถาม:
```
Enter keystore password: [ตั้งรหัสผ่าน → จำไว้!]
Re-enter new password: [พิมพ์ซ้ำ]
What is your first and last name? [ชื่อ-นามสกุล]
What is the name of your organizational unit? [ทีม]
What is the name of your organization? [บริษัท/ชื่อตัวเอง]
What is the name of your City or Locality? [เมือง]
What is the name of your State or Province? [จังหวัด]
What is the two-letter country code for this unit? [TH]
```

> กด `yes` เพื่อยืนยัน

**ผลลัพธ์:** ไฟล์ `miro-release-key.jks`

**ย้ายไปเก็บที่ปลอดภัย + copy มาที่ project (อย่า commit!):**

```bash
# ย้ายมาไว้ที่ android/
move miro-release-key.jks android/
```

---

### Step 2: สร้าง key.properties

**ไฟล์:** `android/key.properties`
**Action:** CREATE

```properties
storePassword=รหัสผ่านที่ตั้ง
keyPassword=รหัสผ่านที่ตั้ง
keyAlias=miro
storeFile=../android/miro-release-key.jks
```

> **ห้าม commit ไฟล์นี้!** ตรวจว่า `.gitignore` มี:
> ```
> android/key.properties
> *.jks
> ```

---

### Step 3: แก้ build.gradle.kts

**ไฟล์:** `android/app/build.gradle.kts`
**Action:** EDIT

#### 3.1 เพิ่ม signing config ด้านบน

เพิ่มก่อน `android {`:

```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
```

#### 3.2 แก้ android block

```kotlin
android {
    namespace = "com.yourname.mirocalorie"  // ← เปลี่ยนเป็นชื่อ package ของคุณ (unique!)

    compileSdk = flutter.compileSdkVersion

    defaultConfig {
        applicationId = "com.yourname.mirocalorie"  // ← ต้องตรงกับ namespace
        minSdk = 23          // Android 6.0+ (สำหรับ Isar + Camera)
        targetSdk = 34       // Android 14
        versionCode = 1      // ← เพิ่มทุกครั้งที่ upload version ใหม่
        versionName = "1.0.0"
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true       // R8 shrink code
            isShrinkResources = true     // ลบ resource ที่ไม่ใช้
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

> **เลือก applicationId:**
> - ต้อง unique บน Play Store
> - format: `com.ชื่อ.ชื่อแอป` เช่น `com.johnsmith.mirocalorie`
> - **เปลี่ยนทีหลังไม่ได้!** (เปลี่ยนแล้วเป็นแอปใหม่)

#### 3.3 เพิ่ม ProGuard rules (ถ้าต้องการ)

สร้างไฟล์ `android/app/proguard-rules.pro`:

```
# Keep Isar
-keep class dev.isar.** { *; }
-keep class io.isar.** { *; }

# Keep JSON serialization
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep Generative AI
-keep class com.google.ai.** { *; }
```

เพิ่มใน build.gradle.kts (release block):
```kotlin
release {
    isMinifyEnabled = true
    isShrinkResources = true
    proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
    signingConfig = signingConfigs.getByName("release")
}
```

---

### Step 4: Build Release

#### 4.1 Clean + Build

```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

**ผลลัพธ์:** `build/app/outputs/bundle/release/app-release.aab`

#### 4.2 ตรวจขนาด

```bash
# ดูขนาด AAB
dir build\app\outputs\bundle\release\app-release.aab
```

> ขนาดควร < 50MB (AAB จะเล็กกว่า APK)

#### 4.3 ทดสอบ Release APK (optional)

```bash
flutter build apk --release
# ติดตั้งทดสอบ
flutter install --release
```

---

### Step 5: สมัคร Google Play Console

#### 5.1 สมัคร Developer Account

1. ไปที่ https://play.google.com/console
2. ล็อกอิน Google Account
3. จ่าย $25 (จ่ายครั้งเดียว)
4. กรอกข้อมูล developer

#### 5.2 สร้าง App ใหม่

1. กด "Create app"
2. App name: **Miro Cal** (หรือชื่อที่เลือก)
3. Default language: **ไทย** (หรือ English ถ้าจะ global)
4. App or game: **App**
5. Free or paid: **Free** (เราใช้ IAP)

---

### Step 6: ตั้ง In-App Product

> ต้องทำก่อน publish!

1. ไปที่ **Monetize → Products → In-app products**
2. กด **Create product**
3. กรอก:

| Field | Value |
|-------|-------|
| Product ID | `miro_cal_pro` |
| Name | Miro Cal Pro |
| Description | ปลดล็อค AI วิเคราะห์อาหารไม่จำกัด |
| Price | 199 THB (หรือ 299 THB) |
| Status | Active |

4. กด **Save** → **Activate**

> **Product Type:** Managed product (= Non-consumable)

---

### Step 7: กรอก Store Listing

#### 7.1 Main Store Listing

| Field | Value |
|-------|-------|
| App name | Miro Cal (max 30 ตัวอักษร) |
| Short description | บันทึกอาหาร นับแคลอรี่ ด้วย AI วิเคราะห์รูปถ่ายอัตโนมัติ (max 80) |
| Full description | ดู 7.2 ด้านล่าง |

#### 7.2 Full Description (คัดลอกได้เลย)

```
🍽️ บันทึกอาหาร นับแคลอรี่ ด้วย AI อัจฉริยะ

ถ่ายรูปอาหาร → AI วิเคราะห์ให้อัตโนมัติ!
ไม่ต้องค้นหาเอง ไม่ต้องกรอกเอง แค่ถ่ายรูปหรือพิมพ์บอก

✨ ฟีเจอร์หลัก:
• ถ่ายรูปอาหาร → AI วิเคราะห์ kcal, โปรตีน, คาร์บ, ไขมัน อัตโนมัติ
• พิมพ์แชท เช่น "กินข้าวผัด" → บันทึกให้เลย
• พิมพ์หลายเมนูพร้อมกัน เช่น "กินกระเพราะ ชาเย็น ขนมครก"
• Quick Add — เลือกจากเมนูยอดนิยม 1 แตะ
• สร้างสูตรอาหาร (My Meal) เก็บไว้ใช้ซ้ำ
• สรุป kcal / macro ทุกวัน
• ตั้งเป้าหมายสุขภาพ (kcal, โปรตีน, คาร์บ, ไขมัน, น้ำ)

💡 ใช้ฟรี:
• บันทึกอาหารด้วยมือ — ไม่จำกัด
• AI วิเคราะห์ — 3 ครั้ง/วัน ฟรี
• อัปเกรด Pro เพื่อใช้ AI ไม่จำกัด (จ่ายครั้งเดียว)

🔒 ข้อมูลของคุณปลอดภัย:
• ข้อมูลทั้งหมดเก็บในเครื่องของคุณ (Offline-first)
• ไม่มี server ของเรา ไม่เก็บข้อมูลของคุณ
• ใช้ Gemini API Key ของคุณเอง (ฟรีจาก Google)

⚙️ หมายเหตุ:
• การวิเคราะห์ด้วย AI ต้องใช้ Gemini API Key (สร้างฟรีที่ aistudio.google.com)
• มีคู่มือการตั้งค่าในแอป
• ไม่มี API Key ก็บันทึกอาหารด้วยมือได้
• ข้อมูลโภชนาการจาก AI อาจไม่แม่นยำ 100%
```

#### 7.3 Upload Screenshots

| Asset | ขนาด | จำนวน | เนื้อหา |
|-------|------|--------|---------|
| Phone Screenshots | 1080×1920 | 4-8 | ดูด้านล่าง |
| Feature Graphic | 1024×500 | 1 | banner สวยๆ |

**Screenshots แนะนำ (เรียงลำดับ):**

1. **หน้า Timeline + สรุปวัน** — แสดง Daily Summary + food entries
2. **ถ่ายรูปอาหาร → AI วิเคราะห์** — แสดงรูปอาหาร + ผลลัพธ์ AI
3. **แชทบันทึกอาหาร** — แสดงการพิมพ์แชท + ผลลัพธ์
4. **รายละเอียดโภชนาการ** — แสดง macro breakdown
5. **My Meal / สร้างสูตร** — แสดงการสร้าง meal
6. **ตั้งเป้าหมาย kcal/macro** — แสดง goal setting

> **วิธีถ่าย screenshot:** ใช้ emulator 1080×1920 → Print Screen
> **วิธีตกแต่ง:** ใช้ Canva / Figma ใส่กรอบมือถือ + ข้อความ

---

### Step 8: กรอกข้อมูลอื่นๆ

#### 8.1 App Content

| Section | Value |
|---------|-------|
| Privacy Policy URL | URL จาก Step 35 |
| App access | All functionality is available without special access |
| Ads | No ads |
| Content Rating | ทำแบบสอบถาม IARC → ได้ rating |
| Target audience | 13+ (ไม่ใช่เด็ก) |
| News app | No |
| Data safety | ดู 8.2 |

#### 8.2 Data Safety

| Question | Answer |
|----------|--------|
| Does your app collect or share user data? | Yes |
| Data types collected | Photos (optional, for AI), Health info (food logs) |
| Is data encrypted in transit? | Yes (HTTPS to Gemini API) |
| Can users request data deletion? | Yes (Clear all data in app) |
| Data shared with third parties? | Photos shared with Google Gemini API (user's own key) |

#### 8.3 Category

- **Category:** Health & Fitness
- **Tags:** Calorie Counter, Food Logger, Diet Tracker

---

### Step 9: Upload AAB + Submit

1. ไปที่ **Release → Production** (หรือ Open Testing ถ้าอยากทดสอบก่อน)
2. กด **Create new release**
3. Upload `app-release.aab`
4. Release name: `1.0.0`
5. Release notes:
```
เวอร์ชันแรก — Miro Cal

✨ ฟีเจอร์:
• บันทึกอาหาร + แคลอรี่ ด้วย AI
• ถ่ายรูปอาหาร → วิเคราะห์อัตโนมัติ
• แชทบันทึก เช่น "กินข้าวผัด"
• Quick Add เมนูยอดนิยม
• สร้าง My Meal เก็บไว้ใช้ซ้ำ
• สรุป kcal/macro ทุกวัน
```
6. กด **Review release**
7. กด **Start rollout to Production**
8. **รอ review** — ครั้งแรกอาจใช้เวลา 3-7 วัน

---

## ⚠️ สิ่งสำคัญก่อน Submit

- [ ] ตรวจว่าไม่มี API Key hardcode ใน code
- [ ] ตรวจว่า `.env` / `key.properties` ไม่อยู่ใน AAB
- [ ] ตรวจว่า `debugShowCheckedModeBanner` ไม่แสดง (release build จะไม่แสดงอยู่แล้ว)
- [ ] ตรวจว่า versionCode = 1 (ครั้งแรก)
- [ ] ตรวจว่า minSdk >= 23
- [ ] ตรวจว่า Privacy Policy URL เข้าถึงได้

---

## ✅ Checklist

- [ ] Signing key สร้างแล้ว + เก็บ backup ไว้ที่ปลอดภัย
- [ ] key.properties สร้างแล้ว + ไม่ commit
- [ ] build.gradle.kts แก้แล้ว (applicationId, signing, minify)
- [ ] `flutter build appbundle --release` สำเร็จ
- [ ] AAB ขนาด < 50MB
- [ ] Google Play Console สมัครแล้ว ($25)
- [ ] In-App Product `miro_cal_pro` สร้างแล้ว + Active
- [ ] Store Listing กรอกครบ (ชื่อ, description, screenshots)
- [ ] Privacy Policy URL ใส่แล้ว
- [ ] Data Safety กรอกแล้ว
- [ ] Content Rating ทำแล้ว
- [ ] AAB upload แล้ว
- [ ] Submit for review แล้ว

---

## 📋 หลัง Publish (Post-Launch)

- [ ] ดาวน์โหลดจาก Play Store ทดสอบจริง
- [ ] ทดสอบซื้อ IAP จริง
- [ ] ตอบ review ของผู้ใช้
- [ ] เตรียม v1.1 (bug fixes)

---

## 🎉 ยินดีด้วย! แอป v1.0 (Thai) อยู่บน Play Store แล้ว!

**ไปต่อ Step 38** → เริ่มทำ Localization เพื่อ Global Launch
