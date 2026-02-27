# คู่มือ iOS — จาก Build จนวางขาย App Store (จบกระบวนการ)

> **MiRO — My Intake Record Oracle**
> Bundle ID: `com.tanabun.miroHybrid`
> Version: 1.2.0+48
> Developer Team: P47BZUN3TR

---

# PHASE 1: เตรียมเครื่อง Mac + Build ลง iPhone ทดสอบ

## สถานะปัจจุบัน (ตรวจแล้ว)

| รายการ | สถานะ |
|---|---|
| Xcode 26.2 | ✅ |
| CocoaPods 1.16.2 | ✅ |
| Flutter 3.41.2 stable | ✅ |
| Apple Developer Account | ✅ |
| Development Team (P47BZUN3TR) | ✅ |
| Bundle ID: `com.tanabun.miroHybrid` | ✅ |
| AppDelegate (UIScene lifecycle) | ✅ |
| HealthKit entitlements | ✅ |
| Info.plist permissions | ✅ |
| In-App Purchase plugin (StoreKit) | ✅ |
| **GoogleService-Info.plist** | ❌ **ต้องสร้าง** |

---

## ขั้นตอน 1.1: สร้าง GoogleService-Info.plist

ไฟล์นี้ขาดอยู่ — ถ้าไม่มี build ไม่ผ่าน

1. ไปที่ https://console.firebase.google.com
2. เลือกโปรเจค **miro-d6856**
3. คลิก ⚙️ → **Project settings**
4. หา **Your apps** → เลือก **iOS app** (`com.tanabun.miroHybrid`)
   - ถ้ายังไม่มี iOS app → **Add app** → iOS → Bundle ID: `com.tanabun.miroHybrid`
5. **Download GoogleService-Info.plist**
6. วางที่ `ios/Runner/GoogleService-Info.plist`

ค่าต้องตรงกับ `firebase_options.dart`:

| Key | ค่า |
|---|---|
| `BUNDLE_ID` | `com.tanabun.miroHybrid` |
| `PROJECT_ID` | `miro-d6856` |
| `GOOGLE_APP_ID` | `1:65396857547:ios:cf4497c3d0968344a4d94e` |
| `API_KEY` | `AIzaSyC-cwx5eNc1B3KHVNLeOoMRfwqLbxFN1LA` |
| `GCM_SENDER_ID` | `65396857547` |

---

## ขั้นตอน 1.2: Register App ID บน Developer Portal

1. ไปที่ https://developer.apple.com/account/resources/identifiers/list
2. คลิก **+** → **App IDs** → **App**
3. ตั้งค่า:
   - **Description**: MiRO
   - **Bundle ID**: Explicit → `com.tanabun.miroHybrid`
4. เปิด **Capabilities**:
   - ✅ **HealthKit**
   - ✅ **In-App Purchase**
   - ✅ **Push Notifications** (สำหรับ Firebase Messaging)
5. **Continue** → **Register**

---

## ขั้นตอน 1.3: Build & Run ครั้งแรก

```bash
export LANG=en_US.UTF-8
cd /Users/tanabuninkeaw/ai_program/miro
flutter clean && flutter pub get
cd ios && pod install && cd ..
flutter run -d numini
```

> ครั้งแรก ~5-10 นาที

---

## ขั้นตอน 1.4: Trust Developer Profile บน iPhone

1. iPhone → **Settings** → **General** → **VPN & Device Management**
2. แตะ Developer App ของคุณ → **Trust** → ยืนยัน
3. กลับมารัน `flutter run -d numini`

---

## ขั้นตอน 1.5: ทดสอบบน iPhone

ก่อนส่ง App Store ต้องทดสอบทุกฟีเจอร์หลัก:

| # | ทดสอบ | วิธีเช็ค |
|---|---|---|
| 1 | เปิด app ได้ / Onboarding ทำงาน | ผ่าน 3 หน้า, เลือก cuisine, ตั้ง goal |
| 2 | บันทึกอาหาร manual | พิมพ์ชื่อ + แคลอรี่ → save |
| 3 | ถ่ายรูปอาหาร → AI วิเคราะห์ | ใช้กล้อง snap อาหาร → ดู ingredients |
| 4 | Chat AI | พิมพ์ "I had chicken rice for lunch" |
| 5 | Health Sync (HealthKit) | Profile → เปิด Health Sync → ขอ permission |
| 6 | เขียนข้อมูลไป Apple Health | บันทึกอาหาร → เปิด Apple Health app ดู |
| 7 | อ่าน Active Energy | เช็คว่าแคลอรี่ที่เผาผลาญแสดงถูกต้อง |
| 8 | In-App Purchase (Sandbox) | ทดสอบซื้อ Energy (ใช้ Sandbox account) |
| 9 | Dark Mode | สลับ Dark/Light mode ดู UI |
| 10 | Gallery Scan | ดึงรูปอาหารจาก gallery |

---

# PHASE 2: เตรียมข้อมูลสำหรับ App Store Connect

## ขั้นตอน 2.1: สร้าง App บน App Store Connect

1. ไปที่ https://appstoreconnect.apple.com
2. **My Apps** → **+** → **New App**
3. กรอกข้อมูล:

| ช่อง | กรอก |
|---|---|
| **Platform** | iOS |
| **Name** | MiRO - AI Calorie Tracker |
| **Primary Language** | English (U.S.) |
| **Bundle ID** | com.tanabun.miroHybrid (เลือกจาก dropdown) |
| **SKU** | miro-hybrid-ios |
| **User Access** | Full Access |

---

## ขั้นตอน 2.2: กรอก App Information

### App Information (แท็บหลัก)

| ช่อง | กรอก |
|---|---|
| **Name** | MiRO - AI Calorie Tracker |
| **Subtitle** | Decode every bite. Own every byte. |
| **Category** | Health & Fitness |
| **Secondary Category** | Food & Drink |
| **Content Rights** | ไม่มี third-party content ที่ต้อง declare |

### Privacy Policy URL

ต้องมี URL ที่เข้าถึงได้สาธารณะ (ห้ามเป็น local file)

**วิธีง่ายสุด:** Host บน GitHub Pages หรือ Firebase Hosting
- เนื้อหามีอยู่แล้วใน `PRIVACY_POLICY.md`
- ถ้ายังไม่มี URL → ใช้ GitHub: สร้าง public repo → upload `PRIVACY_POLICY.md` → ใช้ raw URL
- **ตัวอย่าง URL:** `https://lnxelnope.github.io/miro-privacy/`

### Age Rating

ตอบแบบสอบถาม App Store:

| คำถาม | ตอบ |
|---|---|
| Cartoon or Fantasy Violence | None |
| Realistic Violence | None |
| Sexual Content or Nudity | None |
| Profanity or Crude Humor | None |
| Alcohol, Tobacco, or Drug Use | None |
| Simulated Gambling | None |
| Horror/Fear Themes | None |
| Medical/Treatment Information | None |
| Unrestricted Web Access | No |
| Gambling and Contests | None |

**ผลลัพธ์ที่ควรได้:** Rating **4+** (เหมาะสำหรับทุกอายุ)

---

## ขั้นตอน 2.3: กรอก App Privacy (Data Collection)

Apple บังคับให้ declare ว่า app เก็บข้อมูลอะไร ตอบตามนี้:

### Data Types ที่ต้อง declare:

**1. Health & Fitness**
| ช่อง | ตอบ |
|---|---|
| Collected? | Yes |
| Linked to User? | No |
| Used for Tracking? | No |
| Purpose | App Functionality |
| หมายเหตุ | HealthKit data — Active Energy (อ่าน), Nutrition (เขียน). อยู่บนเครื่องเท่านั้น |

**2. Purchases**
| ช่อง | ตอบ |
|---|---|
| Collected? | Yes |
| Linked to User? | No |
| Used for Tracking? | No |
| Purpose | App Functionality |
| หมายเหตุ | In-App Purchase records (Energy tokens) |

**3. Identifiers — Device ID**
| ช่อง | ตอบ |
|---|---|
| Collected? | Yes |
| Linked to User? | No |
| Used for Tracking? | No |
| Purpose | App Functionality |
| หมายเหตุ | ใช้จัดการ Energy balance ผ่าน Firebase (ไม่ใช้ track users) |

**4. Usage Data — Product Interaction (ถ้าเปิด Analytics)**
| ช่อง | ตอบ |
|---|---|
| Collected? | Yes (optional, user consent) |
| Linked to User? | No |
| Used for Tracking? | No |
| Purpose | Analytics |
| หมายเหตุ | Firebase Analytics — user opt-in only |

**5. Diagnostics — Crash Data**
| ช่อง | ตอบ |
|---|---|
| Collected? | Yes |
| Linked to User? | No |
| Used for Tracking? | No |
| Purpose | App Functionality |

### Data Types ที่ **ไม่** เก็บ (ตอบ No):
- Contact Info (name, email, phone) → **No** (ไม่มี account system)
- Location → **No**
- Contacts → **No**
- User Content (photos, audio, files) → **No** (photos อยู่ local เท่านั้น)
- Search History → **No**
- Browsing History → **No**
- Sensitive Info → **No**
- Financial Info → **No** (handled by Apple)

---

## ขั้นตอน 2.4: เตรียม Screenshots (สำคัญมาก!)

Apple บังคับ screenshots สำหรับทุก device size ที่ support:

### ขนาดที่ต้องมี (จำเป็น):

| Device | ขนาด (pixels) | จำนวน |
|---|---|---|
| **iPhone 6.7"** (15 Pro Max) | 1290 x 2796 | 3-10 รูป |
| **iPhone 6.5"** (11 Pro Max) | 1242 x 2688 | 3-10 รูป |
| **iPhone 5.5"** (8 Plus) | 1242 x 2208 | 3-10 รูป (optional ถ้าไม่ support) |

### Screenshots ที่แนะนำ (6-8 รูป):

| # | หน้าจอ | จุดขาย |
|---|---|---|
| 1 | **Home + Calorie Ring** | "AI-Powered Calorie Tracker" |
| 2 | **ถ่ายรูปอาหาร → AI Result** | "Snap. Analyze. Every Ingredient." |
| 3 | **Ingredient Breakdown** | "See Hidden Calories in Every Bite" |
| 4 | **AI Chat** | "Just Tell MiRO What You Ate" |
| 5 | **Health Sync + Active Energy** | "Syncs with Apple Health" |
| 6 | **15 Cuisines** | "Understands YOUR Food" |
| 7 | **My Meals Library** | "Your Food Database Grows With You" |
| 8 | **No Login / Privacy** | "No Account. No Subscription. Just Start." |

### วิธีสร้าง Screenshots:
- **Option A (ง่ายสุด):** Screenshot จาก iPhone จริง → ใส่กรอบ mockup ด้วย https://mockuphone.com หรือ https://screenshots.pro
- **Option B:** ใช้ Figma/Canva สร้าง marketing screenshots สวยๆ
- **Option C:** ใช้ Xcode Simulator (แต่ HealthKit ไม่ทำงานบน Simulator)

---

## ขั้นตอน 2.5: เขียน Description + Keywords

### App Description (กรอกใน App Store Connect)

```
MiRO — The Most Accurate AI Food Tracker

Snap a photo. MiRO's AI breaks down every single ingredient with individual calorie counts — including hidden calories from cooking oil, sauces, and seasonings that other apps miss.

SNAP & ANALYZE
• Take a photo of any meal → AI identifies every ingredient
• Product Mode: Photograph packaged food → AI reads the label
• Nutrition Label: Snap the label → exact values extracted

AI CHAT — LOG BY TALKING
• "I had chicken rice and egg for lunch" → AI logs everything
• Describe your entire day in one message → all meals logged
• Get personalized meal suggestions based on your goals

CUISINE-SPECIFIC PRECISION
• Choose from 15 cuisines (Thai, Japanese, Korean, Indian, and more)
• AI understands cultural food differences for accurate analysis
• Same curry photo → correctly identified based on YOUR cuisine

INGREDIENT-LEVEL DETAIL
• See exactly WHERE your calories come from
• Sub-ingredients: Fried Chicken = Chicken + Batter + Absorbed Oil
• Edit, remove, or add ingredients after AI analysis

HEALTH SYNC
• Two-way sync with Apple Health
• Food entries automatically written to Health app
• Active Energy from your Apple Watch adds to your daily calorie goal
• Works with Apple Watch, Fitbit, Garmin, and more

PRIVACY FIRST
• No account required — no login, no email, no sign-up
• All food data stored locally on YOUR device
• Health data never leaves your device

SMART ENERGY SYSTEM
• 10 FREE Energy to start
• 1 Energy = 1 AI analysis
• Energy never expires — buy once, own forever
• Manual logging is always FREE
• No forced subscription

GALLERY AUTO-SCAN
• Forgot to log? Pull to refresh → MiRO finds food photos in your gallery
• Analyze them whenever you're ready

SELF-GROWING DATABASE
• Every food you log is saved to your personal library
• The more you use MiRO, the smarter it gets
• After a few weeks, log most meals with one tap — no AI needed

Download MiRO and decode every bite.
```

### Keywords (100 characters max, comma separated)

```
calorie,tracker,food,AI,nutrition,diet,health,macro,protein,calories,meal,fitness,HealthKit,weight
```

### Promotional Text (170 characters, can update anytime)

```
NEW: Health Sync! Your meals auto-sync to Apple Health. Active Energy from your Apple Watch adds bonus calories to your daily goal.
```

### What's New (Release Notes)

```
NEW in 1.2.0:
• Health Sync — Two-way Apple Health integration
• Food entries auto-sync to Health app (calories, protein, carbs, fat)
• Active Energy from Apple Watch adds to your daily calorie goal
• Green progress bar shows burned calories in real-time
• Toggle Active Energy bonus on/off from home screen
• Bug fixes and performance improvements
```

---

## ขั้นตอน 2.6: ตั้งค่า In-App Purchases บน App Store Connect

MiRO ใช้ Energy token system — ต้อง create products ให้ตรงกับ code (เหมือน Android)

### ไปที่ App Store Connect → app ของคุณ → **Monetization** → **In-App Purchases**

### สร้าง Consumable Products (Product ID ต้องตรงกับ `purchase_service.dart`):

| Product ID | Display Name | Price |
|---|---|---|
| `energy_100` | Starter Kick — 100 Energy | $0.99 |
| `energy_550` | Value Pack — 550 Energy | $4.99 |
| `energy_1200` | Power User — 1,200 Energy | $7.99 |
| `energy_2000` | Ultimate Saver — 2,000 Energy | $9.99 |
| `energy_first_purchase_200` | First Purchase — 200 Energy | $0.99 (optional) |

**Type**: Consumable (ใช้แล้วหมด)

### App-Specific Shared Secret (จำเป็นสำหรับ Backend verify iOS receipt):

1. App Store Connect → **My Apps** → เลือก app → **App Information**
2. scroll ลงไป **App-Specific Shared Secret** → **Generate**
3. คัดลอก secret → เก็บไว้สำหรับขั้นตอน 2.6b

### ขั้นตอน 2.6b: ตั้งค่า Firebase Secret สำหรับ iOS IAP

Backend `verifyPurchase` รองรับ iOS แล้ว — ต้องเพิ่ม secret:

```bash
firebase functions:secrets:set APPLE_SHARED_SECRET
# วาง App-Specific Shared Secret ที่ได้จาก App Store Connect
```

จากนั้น deploy functions:
```bash
cd functions && npm run build && firebase deploy --only functions
```

### สร้าง Auto-Renewable Subscription (ถ้ามี):

| Product ID | Display Name | Price |
|---|---|---|
| `miro_normal_subscription` | Energy Pass Monthly | $4.99/month |

**Subscription Group**: MiRO Energy Pass

> **สำคัญ:** Product ID ต้องตรงกับที่ใช้ใน code!
> ตรวจสอบใน `lib/core/services/purchase_service.dart` และ `subscription_service.dart`

### Review Information สำหรับ IAP:

ทุก product ต้องมี:
- **Screenshot** ของหน้าที่แสดง product (Energy Store screen)
- **Review Notes** อธิบายว่า product ทำอะไร

---

## ขั้นตอน 2.7: App Review Information

กรอกใน App Store Connect → **App Review**:

| ช่อง | กรอก |
|---|---|
| **Contact First Name** | Tanabun |
| **Contact Last Name** | Inkeaw |
| **Contact Phone** | (เบอร์โทรของคุณ) |
| **Contact Email** | lnxelnope@gmail.com |
| **Demo Account** | ไม่ต้อง (app ไม่มี login) |
| **Notes** | This app does not require login. All data is stored locally. To test Health Sync: go to Profile → toggle Health Sync on. To test AI features: the app comes with 10 free Energy tokens. |

---

# PHASE 3: Build & Upload ไปยัง App Store Connect

## ขั้นตอน 3.1: Build Archive (Release Build)

> ⚠️ **ห้ามใช้ Simulator** — MLKit ไม่รองรับ ต้อง build บนเครื่อง Mac (flutter build ipa ไม่ต้องมี device เชื่อมต่อ)

```bash
export LANG=en_US.UTF-8
cd /Users/tanabuninkeaw/ai_program/miro

# Clean build
flutter clean && flutter pub get
cd ios && pod install && cd ..

# Build iOS release archive (สำหรับส่ง App Store)
flutter build ipa --release
```

> Build จะอยู่ที่ `build/ios/ipa/miro_hybrid.ipa`

ถ้า build สำเร็จ จะแสดง path ของ `.ipa` file

---

## ขั้นตอน 3.2: Upload ไปยัง App Store Connect

### วิธี A: ใช้ Command Line (แนะนำ)

```bash
xcrun altool --upload-app \
  --type ios \
  --file build/ios/ipa/*.ipa \
  --apiKey YOUR_API_KEY \
  --apiIssuer YOUR_ISSUER_ID
```

### วิธี B: ใช้ Transporter (ง่ายสุด)

1. ดาวน์โหลด **Transporter** จาก Mac App Store (ฟรี)
2. เปิด Transporter → sign in ด้วย Apple ID
3. ลาก `.ipa` file เข้า → คลิก **Deliver**

### วิธี C: ใช้ Xcode

1. เปิด Xcode → `ios/Runner.xcworkspace`
2. **Product** → **Archive**
3. เมื่อ archive เสร็จ → **Distribute App** → **App Store Connect** → **Upload**

---

## ขั้นตอน 3.3: รอ Processing

หลัง upload:
- Apple จะ process build (~10-30 นาที)
- เมื่อเสร็จ build จะปรากฏใน App Store Connect → **TestFlight** และ **App Store** tab
- ถ้ามี error จะได้ email แจ้ง

---

# PHASE 4: TestFlight (ทดสอบก่อนส่ง Review)

## ขั้นตอน 4.1: Internal Testing

1. App Store Connect → **TestFlight** → เลือก build ที่ upload
2. **Internal Testing** → เพิ่ม email ตัวเอง (+ ทีม ถ้ามี)
3. ติดตั้ง **TestFlight** app บน iPhone
4. เปิด TestFlight → ติดตั้ง MiRO → ทดสอบ

## ขั้นตอน 4.2: Checklist ก่อนส่ง Review

| # | ตรวจสอบ | สถานะ |
|---|---|---|
| 1 | App เปิดได้ไม่ crash | ☐ |
| 2 | Onboarding ทำงานครบ | ☐ |
| 3 | บันทึกอาหาร (manual) ได้ | ☐ |
| 4 | ถ่ายรูป → AI วิเคราะห์ได้ | ☐ |
| 5 | Chat AI ทำงาน | ☐ |
| 6 | HealthKit permission ขอสำเร็จ | ☐ |
| 7 | เขียนข้อมูลไป Apple Health ได้ | ☐ |
| 8 | อ่าน Active Energy ได้ | ☐ |
| 9 | In-App Purchase (Sandbox) ซื้อได้ | ☐ |
| 10 | Dark Mode ดูดี | ☐ |
| 11 | ทุกภาษาแสดงถูกต้อง | ☐ |
| 12 | Privacy Policy URL เข้าถึงได้ | ☐ |
| 13 | App ไม่ crash เมื่อปิด/เปิด | ☐ |
| 14 | กล้องขอ permission ถูกต้อง | ☐ |
| 15 | Gallery ขอ permission ถูกต้อง | ☐ |

---

# PHASE 5: Submit for Review

## ขั้นตอน 5.1: เลือก Build + Submit

1. App Store Connect → **App Store** tab → version 1.2.0
2. เลื่อนลงไป **Build** → คลิก **+** → เลือก build ที่ upload
3. กรอกข้อมูลทุกช่อง (ดูขั้นตอน 2.x ด้านบน)
4. ตรวจสอบ:
   - ✅ Screenshots ครบทุก device size
   - ✅ Description กรอกแล้ว
   - ✅ Keywords กรอกแล้ว
   - ✅ Privacy Policy URL ใส่แล้ว
   - ✅ Age Rating ตอบแล้ว
   - ✅ App Privacy (Data Collection) ตอบแล้ว
   - ✅ In-App Purchases สร้างและ approved แล้ว
   - ✅ Review Notes กรอกแล้ว
5. คลิก **Add for Review** → **Submit to App Review**

---

## ขั้นตอน 5.2: รอ Apple Review

| รายการ | ระยะเวลาโดยประมาณ |
|---|---|
| Processing build | 10-30 นาที |
| Waiting for Review | 24-48 ชั่วโมง (ปกติ) |
| In Review | 2-24 ชั่วโมง |
| **รวม** | **1-3 วันทำการ** |

### ถ้าถูก Reject:
- อ่าน rejection reason ใน App Store Connect → **Resolution Center**
- แก้ไขตาม feedback → upload build ใหม่ → submit อีกครั้ง
- rejection ทั่วไป:
  - **Guideline 5.1.1**: Privacy — ต้องมี privacy policy
  - **Guideline 3.1.1**: IAP — ต้อง purchase ผ่าน Apple ไม่ใช่ external
  - **Guideline 2.1**: Performance — app crash
  - **Guideline 5.1.2**: HealthKit — ต้องใช้ข้อมูล health ตาม purpose ที่แจ้ง

---

## ขั้นตอน 5.3: Release!

เมื่อ Apple approve:
- **Manual Release**: คุณกด Release เมื่อพร้อม
- **Automatic Release**: ปล่อยทันทีที่ approve
- แนะนำ: ใช้ **Manual Release** ครั้งแรก เพื่อเลือกเวลาปล่อยเอง

---

# PHASE 6: หลังวางขาย — สิ่งที่ต้องทำ

## อัพเดต Marketing Features Summary

ใน `_project_manager/MARKETING_FEATURES_SUMMARY.md` เปลี่ยน:
```
**Platform:** Android + iOS
```

## อัพเดต Privacy Policy

เพิ่ม Apple-specific info:
- In-App Purchase → Apple handles payment
- HealthKit data handling

## ติดตาม Metrics

- App Store Connect → **App Analytics**
- Firebase Console → **Analytics**
- Crash reports → **Xcode Organizer** หรือ **Firebase Crashlytics**

---

# QUICK REFERENCE: สรุปทุก Phase

| Phase | ทำอะไร | เวลาโดยประมาณ |
|---|---|---|
| **1** | GoogleService-Info.plist + Build + Test บน iPhone | 1 ชั่วโมง |
| **2** | กรอกข้อมูลทุกอย่างบน App Store Connect | 2-3 ชั่วโมง |
| **3** | Build Archive + Upload | 30 นาที |
| **4** | TestFlight ทดสอบ | 1-2 ชั่วโมง |
| **5** | Submit for Review | 5 นาที (รอ 1-3 วัน) |
| **6** | Release + Post-launch | ตลอดไป |
| **รวมถึงวางขาย** | | **~1-2 วัน** (ไม่รวมรอ review) |

---

# Troubleshooting

### ❌ Build Error: "GoogleService-Info.plist not found"
→ ทำขั้นตอน 1.1

### ❌ Build Error: "No signing certificate"
```bash
open ios/Runner.xcodeproj
```
→ Target **Runner** → **Signing & Capabilities** → เลือก Team

### ❌ "Framework 'Pods_Runner' not found"
```bash
cd ios && pod install && cd ..
flutter clean && flutter run -d numini
```

### ❌ Archive ไม่ผ่าน / Upload error
→ ต้อง set build config เป็น Release:
```bash
flutter build ipa --release
```

### ❌ "Missing Compliance" warning หลัง upload
→ App Store Connect → build → **Manage Export Compliance**
→ ตอบ: "Does your app use encryption?" → **No** (ถ้าใช้แค่ HTTPS ปกติ)
→ หรือ เพิ่มใน Info.plist:
```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

### ❌ "MLImage.framework architecture error"
→ ต้อง build/test บน Physical Device เท่านั้น (ไม่ใช่ Simulator)

### ❌ Apple Reject เรื่อง HealthKit
→ ใน Review Notes อธิบายชัดเจน:
"MiRO reads Active Energy Burned to add bonus calories to the user's daily calorie goal. MiRO writes Nutrition data (calories, protein, carbs, fat) when the user logs a meal. Health Sync is optional and requires explicit user consent."

### ⚠️ CocoaPods UTF-8 Warning
เพิ่มใน `~/.zshrc`:
```bash
export LANG=en_US.UTF-8
```

---

# สิ่งที่ต้องเตรียมนอก Code (Checklist)

- [ ] GoogleService-Info.plist (Firebase Console)
- [ ] Privacy Policy URL (host บน web)
- [ ] Screenshots 6-8 รูป (6.7" + 6.5")
- [ ] App Icon 1024x1024 (มีแล้วใน assets)
- [ ] Apple Developer Account (มีแล้ว)
- [ ] Sandbox Tester Account สำหรับ IAP testing
- [ ] Bank Account ใน App Store Connect (สำหรับรับเงิน)
