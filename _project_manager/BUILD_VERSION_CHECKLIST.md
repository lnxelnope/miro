# Build Version Checklist

เอกสารนี้ใช้สำหรับตรวจสอบความถูกต้องของ Build Version ก่อน Deploy ไป Google Play Store

**อัปเดตล่าสุด:** 2026-04-08 (Build 78)

---

## ✅ Build 78 (v2.0.0) - Status: READY FOR RELEASE

### 📋 Checklist

- [ ] **pubspec.yaml** - Version format ถูกต้อง (`2.0.0+78`)
- [ ] **android/app/build.gradle.kts** - Version sync ตรงกัน (`versionCode = 78`, `versionName = "2.0.0"`)
- [ ] **lib/features/profile/presentation/profile_screen.dart** - Version display in Settings (`'2.0.0'`)
- [ ] **Google Play Billing Library** - รองรับ 7.0+ (Billing Library 7.1.1 ใน AndroidManifest.xml)
- [ ] **Target SDK** - 35 (Android 15)
- [ ] **Compile SDK** - 36 (Android 16)
- [ ] **Version Naming** - ตาม Semantic Versioning (`2.0.0`)
- [ ] **CHANGELOG.md** - อัปเดตแล้ว (v2.0.0+78)
- [ ] **AdMob Compliance** - AD_ID permission ใน AndroidManifest.xml (`com.google.android.gms.permission.AD_ID`)
- [ ] **iOS** - `flutter build ipa` ใช้ `FLUTTER_BUILD_NUMBER` จาก pubspec (78)

### ✨ Changes in this version:
- Bump build 77→78 — AR Scan: คำเตือนแนวตั้งเมื่อหมุนกล้องแนวนอน (L10n หลายภาษา); Create Meal: helper ปริมาณรวมเมนูชัดขึ้น

---

## ✅ Build 77 (v2.0.0) - Status: RELEASED

### ✨ Changes in that version:
- Bump build 76→77 — ส่ง Store แก้บั๊ก (เช่น Basic mode: merge แล้วเปลี่ยนชื่อ → บันทึกเป็น My Meal)

---

## ✅ Build 76 (v2.0.0) - Status: RELEASED

### ✨ Changes in that version:
- **v2.0.0** — major version bump (build 75→76)
- Bump build 76 — สำหรับอัปโหลดขึ้น App Store / Google Play

---

## ✅ Build 75 (v1.2.7) - Status: RELEASED

### ✨ Changes in that version:
- Bump build 75 — สำหรับอัปโหลดขึ้น App Store / Google Play

---

## ✅ Build 74 (v1.2.7) - Status: RELEASED

### ✨ Changes in that version:
- **v1.2.7** — Share card (แชร์สรุปมื้อ / โภชนาการเป็นการ์ดภาพ)
- Bump build 74 — สำหรับอัปโหลดขึ้น App Store / Google Play

---

## ✅ Build 73 (v1.2.6) - Status: RELEASED

### ✨ Changes in that version:
- Bump build 73 — สำหรับอัปโหลดขึ้น App Store / Google Play (แทน build 72 ที่ใช้เลขไปแล้ว)

---

## ✅ Build 72 (v1.2.6) - Status: SUPERSEDED / DO NOT SHIP

### ✨ Changes in that version:
- Bump build 72 — สำหรับอัปโหลดขึ้น App Store / Google Play (เลขถูกใช้ / ยกเลิก — ใช้ 73 แทน)

---

## ✅ Build 71 (v1.2.6) - Status: RELEASED

### ✨ Changes in that version:
- Bump build 71 — store release: Android AR Scan (กัน concurrent ML Kit + ProGuard keep ML Kit), locale หลังเปลี่ยนในโปรไฟล์ซิงค์ SharedPreferences

---

## ✅ Build 70 (v1.2.6) - Status: RELEASED

### ✨ Changes in that version:
- Bump build 70 — Privacy consent: ปุ่ม Continue ใช้ได้ทันที (แก้ Guideline 2.1(a) บน iPad); ส่ง App Store / Play

---

## ✅ Build 69 (v1.2.6) - Status: RELEASED

### ✨ Changes in that version:
- Bump build 69 — IAP / Subscription / Energy Store ใช้ L10n ครบทุกภาษา (สอดคล้อง App Store metadata)

---

## ✅ Build 68 (v1.2.6) - Status: RELEASED

### ✨ Changes in that version:
- Bump build 68 สำหรับส่ง App Store / Play อีกครั้ง (หลังจัดการ promotion offer / ลบ IAP 200E ที่มีปัญหา)

---

## ✅ Build 67 (v1.2.6) - Status: RELEASED

### ✨ Changes in that version:
- Bump build 67 สำหรับอัปโหลดขึ้น Store

---

## ✅ Build 66 (v1.2.6) - Status: RELEASED

### ✨ Changes in that version:
- (เลขเดิมใช้ไปแล้ว — bump เป็น 67 สำหรับ build ใหม่)

---

## ✅ Build 65 (v1.2.6) - Status: RELEASED

### ✨ Changes in that version:
- iOS: Info.plist base values เป็นภาษาอังกฤษ, register InfoPlist.strings + PrivacyInfo.xcprivacy, bump build สำหรับ resubmit

---

## ✅ Build 64 (v1.2.6) - Status: RELEASED

### ✨ Changes in that version:
- (เลขเดิมใช้ไปแล้ว — bump เป็น 65 สำหรับ build ใหม่)

---

## ✅ Build 63 (v1.2.6) - Status: RELEASED

### ✨ Changes in that version:
- (เลขเดิมใช้ไปแล้ว — bump เป็น 64 สำหรับ build ใหม่)

---

## ✅ Build 62 (v1.2.6) - Status: RELEASED

### ✨ Changes in that version:
- **Energy Fix** - ปิดช่องโหว่: ลบ free edit lookup, ทุกครั้งที่เรียก AI วิเคราะห์อาหารต้องหัก energy
- **Chat ฟรี** - AI Chat ฟรีวันละ 10 ครั้ง (รวม menu suggestion)
- **ลบ Local AI** - ลบระบบ Local AI Chat ทั้งหมด ใช้ Miro AI เสมอ
- **UI Fix** - แก้ label "ฟรี" ที่ไม่เป็นจริงแล้ว (AI Lookup, Re-analyze)

---

## ✅ Build 61 (v1.2.6) - Status: RELEASED

### ✨ Changes in that version:
- Same as Build 63

---

## ✅ Build 60 (v1.2.6) - Status: RELEASED

### ✨ Changes in that version:
- Same as Build 63

---

## ✅ Build 59 (v1.2.5) - Status: RELEASED

### ✨ Changes in that version:
- **Unified Privacy Consent Bottom Sheet** - รวมสิทธิ์ privacy ทั้งหมด (Notifications, Analytics, Food Research, Ads) ใน bottom sheet เดียว
- **Scroll-to-bottom requirement** - บังคับให้ผู้ใช้เลื่อนลงจนสุดก่อนกดยอมรับ (มืออาชีพตาม store policy)
- แทนที่ AnalyticsConsentDialog ด้วย PrivacyConsentSheet บน first launch
- Defer NotificationService init จนกว่าผู้ใช้จะยอมรับใน consent sheet

---

## ✅ Build 58 (v1.2.4) - Status: RELEASED

### ✨ Changes in that version:
- **Billing Library Version Fix** - แก้ไข AndroidManifest.xml meta-data จาก `6.0.1` → `7.1.1` เพื่อให้ผ่าน Google Play policy (Billing Library 7.0+ requirement)

---

## ✅ Build 57 (v1.2.4) - Status: RELEASED

### ✨ Changes in that version:
- AD_ID Permission Fix, Remove flutter_native_splash, Build Fix for release

---

## ✅ Build 56 (v1.2.4) - Status: RELEASED

### ✨ Changes in that version:
- Profile Data Persistence, Locale & Cuisine, Clear Data Dialog, AD_ID permission fix

---

## ✅ Build 55 (v1.2.4) - Status: RELEASED

### ✨ Changes in that version:
- Profile Data Persistence, Locale & Cuisine, Clear Data Dialog

---

## ✅ Build 54 (v1.2.4) - Status: RELEASED

### ✨ Changes in that version:
- **Name Change Re-Analysis Feature** - Dialog เลือก keep/re-analyze วัตถุดิบเมื่อเปลี่ยนชื่ออาหาร
- **Data Mining Value** - user_kept, ai_reanalyzed sources

---

## ✅ Build 53 (v1.2.3) - Status: RELEASED

### 📋 Checklist

- [x] **pubspec.yaml** - Version format ถูกต้อง (`1.2.3+53`)
- [x] **android/app/build.gradle.kts** - Version sync ตรงกัน (`versionCode = 53`, `versionName = "1.2.3"`)
- [x] **lib/features/profile/presentation/profile_screen.dart** - Version display in Settings (`'1.2.3'`)
- [x] **Google Play Billing Library** - รองรับ 7.0+ (ใช้ `in_app_purchase: ^3.2.3`)
- [x] **Target SDK** - 35 (Android 15)
- [x] **Compile SDK** - 36 (Android 16)
- [x] **Version Naming** - ตาม Semantic Versioning (`1.2.3`)
- [x] **CHANGELOG.md** - อัปเดตแล้ว (v1.2.3+53)
- [x] **AdMob Compliance** - AD_ID permission ใน AndroidManifest.xml (`com.google.android.gms.permission.AD_ID`)

### ✨ Changes in this version:
- **iOS Resubmit** - Bump build 51→53 (ITMS-90118: ลบ Routing App Coverage File ใน App Store Connect)
- **iOS Active Energy Fix** - HealthKit entitlements, provider invalidation, debug logging
- **Deficit Gauge** - Scale -TDEE to 0, surplus needle clamped at rightmost

---

## ✅ Build 51 (v1.2.3) - Status: REJECTED (iOS)

### ✨ Changes in that version:
- Same as Build 53 — Rejected due to ITMS-90118 (Routing App Coverage File)

---

## ✅ Build 50 (v1.2.2) - Status: RELEASED

### ✨ Changes in that version:
- **Dark Mode Support** - Nutrition Summary, Energy Pass, Subscription screens
- **Period-Aware Date Navigation** - Day/Week/Month/Year navigation
- **Subscription Screen Improvements** - Plan cards always visible

---

## ✅ Build 49 (v1.2.1) - Status: RELEASED

### 📋 Checklist

- [x] **pubspec.yaml** - Version format ถูกต้อง (`1.2.1+49`)
- [x] **android/app/build.gradle.kts** - Version sync ตรงกัน (`versionCode = 49`, `versionName = "1.2.1"`)
- [x] **lib/features/profile/presentation/profile_screen.dart** - Version display in Settings (`'1.2.1'`)
- [x] **Google Play Billing Library** - รองรับ 7.0+ (ใช้ `in_app_purchase: ^3.2.3`)
- [x] **Target SDK** - 35 (Android 15)
- [x] **Compile SDK** - 36 (Android 16)
- [x] **Version Naming** - ตาม Semantic Versioning (`1.2.1`)
- [ ] **CHANGELOG.md** - อัปเดตแล้ว (v1.2.1+49)
- [x] **AdMob Compliance** - AD_ID permission ใน AndroidManifest.xml (`com.google.android.gms.permission.AD_ID`)

### ✨ Changes in this version:
- **L10n Support for Nutrition Summary Dashboard** - เพิ่มการแปลภาษาไทยและภาษาอื่นๆ สำหรับหน้า Nutrition Summary Dashboard
  - แปลข้อความทั้งหมดใน `today_summary_dashboard_screen.dart` เป็นระบบ L10n
  - เพิ่ม keys ใหม่: `nutritionSummary`, `macroDistribution`, `calorieTrend`, `calorieTrend7Days`, `micronutrientTracker`, `fatBreakdown`, `goal`, `over`, `saturated`, `mono`, `poly`, `trans`, `noDataFor`, `errorColon`
  - รองรับการแปลเป็น 12 ภาษา (EN, TH, และภาษาอื่นๆ)

---

## ✅ Build 48 (v1.2.0) - Status: RELEASED

### 📋 Checklist

- [x] **pubspec.yaml** - Version format ถูกต้อง (`1.2.0+48`)
- [x] **android/app/build.gradle.kts** - Version sync ตรงกัน (`versionCode = 48`, `versionName = "1.2.0"`)
- [x] **lib/features/profile/presentation/profile_screen.dart** - Version display in Settings (`'1.2.0'`)
- [x] **Google Play Billing Library** - รองรับ 7.0+ (ใช้ `in_app_purchase: ^3.2.3`)
- [x] **Target SDK** - 35 (Android 15)
- [x] **Compile SDK** - 36 (Android 16)
- [x] **Version Naming** - ตาม Semantic Versioning (`1.2.0`)
- [x] **CHANGELOG.md** - อัปเดตแล้ว (v1.2.0+48)
- [x] **AdMob Compliance** - AD_ID permission ใน AndroidManifest.xml (`com.google.android.gms.permission.AD_ID`)

### ✨ Major Feature: Health Sync (Apple Health / Google Health Connect)

#### Two-Way Health Data Integration:
- **Outbound Sync:** Every food entry logged in MiRO automatically syncs to Apple Health (iOS) and Google Health Connect (Android)
  - Full ingredient-level breakdown: Calories, Protein, Carbs, Fat, Meal Type
  - Works with smartwatches (Apple Watch, Samsung Galaxy Watch), fitness apps (Google Fit, Fitbit, Garmin)
  - Delete food in MiRO → automatically removed from Health app too
- **Inbound Sync:** Active Energy (calories burned from movement) pulled from Health apps
  - Real-time bonus calories added to daily calorie goal
  - Green progress bar fills as you move throughout the day
  - Toggle on/off directly from home screen (Basic & Pro modes)
  - Customizable BMR (default 1,500 kcal/day) for accurate active energy calculation

#### Technical Implementation:
- **iOS:** Apple HealthKit integration with proper entitlements and Info.plist permissions
- **Android:** Google Health Connect integration (minSdk 26, FlutterFragmentActivity, manifest declarations)
- **Permission Flow:** Single permission request for both read (Active Energy) and write (Nutrition) permissions
- **Data Models:** Added `customBmr` field to UserProfile, `healthConnectId` to FoodEntry
- **Services:** HealthSyncService handles all health data operations
- **UI:** Compact Active Energy row with green progress bar, mini toggle, fire icon

#### Privacy & Legal:
- Updated Terms of Service and Privacy Policy with Health Data Integration sections
- Full localization (l10n) for all 12 supported languages
- Permission requested only when user enables Health Sync
- User can disable anytime — no data leaves device without consent

### 🐛 Bug Fixes:
- **Fixed: NaN/Infinity Error in BMR Calculation** - Resolved crash when displaying BMR in settings (`Unsupported operation: Infinity or NaN toInt`)
  - Root cause: Existing user profiles created before `customBmr` field was added returned NaN from Isar database
  - Solution: Added `safeBmr` getter in UserProfile model with NaN/Infinity safety checks
  - Added safety checks in all `.toInt()` calls for activeEnergy and goal calculations
  - All NaN/Infinity values now default to 1,500 kcal

- **Fixed: Active Energy Not Updating When BMR Changed** - Active Energy now recalculates immediately when BMR is changed in settings
  - Root cause: `activeEnergyProvider` was reading profile directly from database instead of watching `profileNotifierProvider`
  - Solution: Changed provider to watch `profileNotifierProvider` — automatically recalculates when profile changes
  - Also fixed `effectiveCalorieGoalProvider` to watch profile changes

- **Fixed: Product Mode Not Saved Correctly** - เมื่อเลือก Product mode แล้วกด Save without analysis จะบันทึกเป็น Food mode แทน
  - Root cause: `_saveToDiary()` ใน `image_analysis_preview_screen.dart` ไม่ได้ set `searchMode` และใช้ชื่อ default เป็น `'food'` เสมอ
  - Solution: เพิ่ม `..searchMode = _searchMode` และเปลี่ยนชื่อ default ตาม search mode (`'product'` เมื่อเป็น product mode, `'food'` เมื่อเป็น food mode)
  - Applied to both `_saveAndAnalyze()` and `_saveToDiary()` methods

- **UI Improvement: Button Labels** - ปรับปรุงข้อความปุ่มให้กระชับขึ้น
  - "Save & Analyze" → **"Analyze"** (บันทึก & วิเคราะห์ → วิเคราะห์)
  - "Save without analysis" → **"Save"** (บันทึกโดยไม่วิเคราะห์ → บันทึก)
  - Updated localization files (EN & TH) and regenerated

### 🔧 Technical Changes:
- **image_analysis_preview_screen.dart**: 
  - Fixed `_saveToDiary()`: Added `..searchMode = _searchMode` to preserve selected search mode
  - Updated default name logic: `foodName.isEmpty ? (_searchMode == FoodSearchMode.product ? 'product' : 'food') : foodName`
  - Applied same fix to `_saveAndAnalyze()` for consistency
- **Localization**: Updated `app_en.arb` and `app_th.arb` button text, regenerated with `flutter gen-l10n`

---
## ✅ Build 47 (v1.1.22) - Status: RELEASED

### 📋 Checklist

- [x] **pubspec.yaml** - Version format ถูกต้อง (`1.1.22+47`)
- [x] **android/app/build.gradle.kts** - Version sync ตรงกัน (`versionCode = 47`, `versionName = "1.1.22"`)
- [x] **lib/features/profile/presentation/profile_screen.dart** - Version display in Settings (`'1.1.22'`)
- [x] **Google Play Billing Library** - รองรับ 7.0+ (ใช้ 7.1.1)
- [x] **Target SDK** - 35 (Android 15)
- [x] **Compile SDK** - 36 (Android 16)
- [x] **Version Naming** - ตาม Semantic Versioning
- [x] **CHANGELOG.md** - อัปเดตแล้ว
- [x] **AdMob Compliance** - AD_ID (Android), NSUserTrackingUsageDescription + SKAdNetworkItems (iOS), UMP Consent flow

### ✨ Changes in this version:
- **Basic Mode: Selection Bar UI Improvements** - Long press → selection mode with improved action bar
  - Added **Unselect** button (icon-only) to clear all selections
  - Converted Delete and Move Date buttons to **icon-only** (saves space)
  - Analyze button retains text label (only button with text)
  - All icon buttons have tooltips for better UX
- **Delete Confirmation Dialog** - Added confirmation dialog before deleting selected entries in Basic mode
  - Shows entry names in confirmation message
  - Uses l10n for proper localization
- **Bug Fix: Long Press Behavior** - Reverted from popup menu back to selection mode (matches original design)
  - Selection bar now appears above food items when long pressing
  - More intuitive and space-efficient UI

---

## ✅ Build 46 (v1.1.21) - Status: RELEASED

---

## ✅ Build 45 (v1.1.20) - Status: RELEASED

### 📋 Checklist

- [ ] **pubspec.yaml** - Version format ถูกต้อง (`1.1.20+45`)
- [ ] **android/app/build.gradle.kts** - Version sync ตรงกัน (`versionCode = 45`, `versionName = "1.1.20"`)
- [ ] **lib/features/profile/presentation/profile_screen.dart** - Version display in Settings (`'1.1.20'`)
- [ ] **Google Play Billing Library** - รองรับ 7.0+ (ใช้ 7.1.1)
- [ ] **Target SDK** - 35 (Android 15)
- [ ] **Compile SDK** - 36 (Android 16)
- [ ] **Version Naming** - ตาม Semantic Versioning
- [ ] **CHANGELOG.md** - อัปเดตแล้ว
- [ ] **AdMob Compliance** - AD_ID (Android), NSUserTrackingUsageDescription + SKAdNetworkItems (iOS), UMP Consent flow

### ✨ Changes in this version:
- Version bump 1.1.19 → 1.1.20 (Build 45)

---

## ✅ Build 44 (v1.1.19) - Status: RELEASED

### 📋 Checklist

- [x] **pubspec.yaml** - Version format ถูกต้อง (`1.1.19+44`)
- [x] **android/app/build.gradle.kts** - Version sync ตรงกัน (`versionCode = 44`, `versionName = "1.1.19"`)
- [x] **lib/features/profile/presentation/profile_screen.dart** - Version display in Settings (`'1.1.19'`)
- [x] **AdMob Compliance** - AD_ID (Android), NSUserTrackingUsageDescription + SKAdNetworkItems (iOS), UMP Consent flow

### ✨ Changes in that version:
- **AdMob Compliance (Android + iOS):**
  - Android: เพิ่ม `com.google.android.gms.permission.AD_ID` ใน AndroidManifest.xml (แก้ Play Console warning)
  - iOS: เพิ่ม `NSUserTrackingUsageDescription` + `SKAdNetworkItems` ใน Info.plist
  - สร้าง `AdmobConsentService` — UMP Consent + iOS ATT flow ก่อน init AdMob
  - ผู้ใช้ consent → Personalized Ads | ไม่ consent → Non-personalized Ads (fallback อัตโนมัติ)

---

## ✅ Build 43 (v1.1.18) - Status: RELEASED

### 📋 Checklist

- [x] **pubspec.yaml** - Version format ถูกต้อง (`1.1.18+43`)
- [x] **android/app/build.gradle.kts** - Version sync ตรงกัน (`versionCode = 43`, `versionName = "1.1.18"`)
- [x] **lib/features/profile/presentation/profile_screen.dart** - Version display in Settings (`'1.1.18'`)
- [x] **Google Play Billing Library** - รองรับ 7.0+ (ใช้ 7.1.1)
- [x] **Target SDK** - 35 (Android 15)
- [x] **Compile SDK** - 36 (Android 16)
- [x] **Version Naming** - ตาม Semantic Versioning
- [x] **CHANGELOG.md** - อัปเดตแล้ว

### ✨ Changes in this version:
- Default app mode to Basic for new users (first-time after onboarding)
- Fix: Recalculate calories when quantity changes in Basic mode detail sheet

---

## ✅ Build 42 (v1.1.17) - Status: RELEASED

### 📋 Checklist

- [x] **pubspec.yaml** - Version format ถูกต้อง (`1.1.17+42`)
- [x] **android/app/build.gradle.kts** - Version sync ตรงกัน (`versionCode = 42`, `versionName = "1.1.17"`)
- [x] **lib/features/profile/presentation/profile_screen.dart** - Version display in Settings (`'1.1.17'`)
- [x] **Google Play Billing Library** - รองรับ 7.0+ (ใช้ 7.1.1)
- [x] **Target SDK** - 35 (Android 15)
- [x] **Compile SDK** - 36 (Android 16)
- [x] **Version Naming** - ตาม Semantic Versioning
- [x] **CHANGELOG.md** - อัปเดตแล้ว

---

## ✅ Build 41 (v1.1.16) - Status: RELEASED

### 📋 Checklist

- [x] **pubspec.yaml** - Version format ถูกต้อง (`1.1.16+41`)
- [x] **android/app/build.gradle.kts** - Version sync ตรงกัน (`versionCode = 41`, `versionName = "1.1.16"`)
- [x] **lib/features/profile/presentation/profile_screen.dart** - Version display in Settings (`'1.1.16'`)
- [x] **Google Play Billing Library** - รองรับ 7.0+ (ใช้ 7.1.1)
- [x] **Target SDK** - 35 (Android 15)
- [x] **Compile SDK** - 36 (Android 16)
- [x] **Version Naming** - ตาม Semantic Versioning
- [x] **CHANGELOG.md** - อัปเดตแล้ว

---

## ✅ Build 40 (v1.1.15) - Status: RELEASED

### 📋 Checklist

- [x] **pubspec.yaml** - Version format ถูกต้อง (`1.1.15+40`)
- [x] **android/app/build.gradle.kts** - Version sync ตรงกัน (`versionCode = 40`, `versionName = "1.1.15"`)
- [x] **lib/features/profile/presentation/profile_screen.dart** - Version display in Settings (`'1.1.15'`)
- [x] **Google Play Billing Library** - รองรับ 7.0+ (ใช้ 7.1.1)
- [x] **Target SDK** - 35 (Android 15)
- [x] **Compile SDK** - 36 (Android 16)
- [x] **Version Naming** - ตาม Semantic Versioning
- [x] **CHANGELOG.md** - อัปเดตแล้ว

---
## ✅ Build 38 (v1.1.13) - Status: RELEASED

### 📋 Checklist

- [x] **pubspec.yaml** - Version format ถูกต้อง (`1.1.13+38`)
- [x] **android/app/build.gradle.kts** - Version sync ตรงกัน (`versionCode = 38`, `versionName = "1.1.13"`)
- [x] **lib/features/profile/presentation/profile_screen.dart** - Version display in Settings (`'1.1.13'`)
- [x] **Google Play Billing Library** - รองรับ 7.0+ (ใช้ 7.1.1)
- [x] **Target SDK** - 35 (Android 15)
- [x] **Compile SDK** - 36 (Android 16)
- [x] **Version Naming** - ตาม Semantic Versioning
- [x] **CHANGELOG.md** - อัปเดตแล้ว

### 🐛 Critical Bug Fixes in this version:
- Fixed: Bonus rate offers (40% bonus, tier promo) not disappearing after purchase
  - Root cause: `markOfferClaimed()` only checked `productId` match, but `bonus_rate` offers don't have `productId`
  - Solution: Track `offerBonusTemplateId` and mark `claimed=true` after purchase completes
  - Frontend: Remove offers from local state immediately after purchase (UX improvement)
- Fixed: `getActiveOffers()` not checking `template.isActive` flag
  - Admin-deactivated offers were still visible to users
  - Solution: Added `isActive === false` check in `getActiveOffers()` filter
- Cleanup: Removed legacy code in `verifyPurchase.ts` (duplicate welcome bonus trigger)

### 🔧 Backend Changes:
- Updated `verifyPurchase.ts`: Added bonus_rate offer claiming logic
- Updated `offersV2.ts`: Added `template.isActive` check in `getActiveOffers()`
- Updated `energy_store_screen.dart`: Immediate offer removal from local state

---
## ✅ Build 37 (v1.1.12) - Status: RELEASED

### 📋 Checklist

- [x] **pubspec.yaml** - Version format ถูกต้อง (`1.1.12+37`)
- [x] **android/app/build.gradle.kts** - Version sync ตรงกัน (`versionCode = 37`, `versionName = "1.1.12"`)
- [x] **lib/features/profile/presentation/profile_screen.dart** - Version display in Settings (`'1.1.12'`)
- [x] **Google Play Billing Library** - รองรับ 7.0+ (ใช้ 7.1.1)
- [x] **Target SDK** - 35 (Android 15)
- [x] **Compile SDK** - 36 (Android 16)
- [x] **Version Naming** - ตาม Semantic Versioning
- [x] **CHANGELOG.md** - อัปเดตแล้ว

### ✨ New Feature in this version:
- Enhanced Add Food (Timeline) = Mini Create Meal
  - Main-ingredient / sub-ingredient editing with Autocomplete + AI search
  - Quick Add (save without name if has kcal)
  - Flexible save (name-only for Analyze All later)
  - Auto-save to MyMeal + Ingredient DB

### 🐛 Critical Bug Fix in this version:
- Fixed: AI usage not recording energy cost in 7 code paths
  - Analyze All / Analyze Selected / Re-analyze were free (no energy deducted)
  - Added `UsageLimiter.recordAiUsage()` to all missing points

---

## ✅ Build 36 (v1.1.11) - Status: RELEASED

---

## ✅ Build 35 (v1.1.10) - Status: RELEASED

### 📋 Checklist

- [x] **pubspec.yaml** - Version format ถูกต้อง
- [x] **android/app/build.gradle.kts** - Version sync ตรงกัน
- [x] **Google Play Billing Library** - รองรับ 7.0+ (ใช้ 7.1.1)
- [x] **Target SDK** - 35 (Android 15)
- [x] **Version Naming** - ตาม Semantic Versioning

### 🐛 Critical Bug Fix in this version:
- Fixed: Chat NaN error causing crashes on production devices
  - Root cause: NaN values from database migrations in profile/food data
  - Solution: 3-layer NaN sanitization (profile guard, food guard, JSON guard)
  - Added `_safeDouble()` and `_sanitizeForJson()` helpers
  - All NaN/Infinity values converted to 0 before JSON encoding

---

## ✅ Build 34 (v1.1.9) - Status: RELEASED

### 📋 Checklist

- [x] **pubspec.yaml** - Version format ถูกต้อง
- [x] **android/app/build.gradle.kts** - Version sync ตรงกัน
- [x] **Google Play Billing Library** - รองรับ 7.0+ (ใช้ 7.1.1)
- [x] **Target SDK** - 35 (Android 15)
- [x] **Version Naming** - ตาม Semantic Versioning

### ✨ New Features in this version:
- Smart Chat Context-Aware AI (database knowledge, custom meals, data-driven Q&A)
- Data source status icons (Database/AI Verified/Pending)
- Enhanced AI context (full macro goals, meal budgets, micronutrients)
- Chat UI cleanup (removed badge, wider chat area)

### 🐛 Bug Fixes in this version:
- Fixed: Analyze All not saving to MyMeal/Ingredient database
- Fixed: Chat not returning ingredients_hint from AI
- Fixed: AI prompt conflict (analyzing when should only log)
- Fixed: Consistent database icons across all screens

---

## ✅ Build 33 (v1.1.8) - Status: RELEASED

### 📋 Checklist

- [x] **pubspec.yaml** - Version format ถูกต้อง
- [x] **android/app/build.gradle.kts** - Version sync ตรงกัน
- [x] **Google Play Billing Library** - รองรับ 7.0+ (ใช้ 7.1.1)
- [x] **Target SDK** - 35 (Android 15)
- [x] **Version Naming** - ตาม Semantic Versioning

### 🐛 Bug Fixes in this version:
- Fixed: Meal detail bottom sheet not showing ingredients
- Fixed: Add ingredient not saving (was calling update instead of save)
- Fixed: Edit ingredient showing old values (now reloads from database)
- Fixed: Edit ingredient callback not async properly
- Improved: Removed duplicate save operation in add ingredient

---

## ✅ Build 32 (v1.1.7) - Status: RELEASED

### 📋 Checklist

- [x] **pubspec.yaml** - Version format ถูกต้อง
- [x] **android/app/build.gradle.kts** - Version sync ตรงกัน
- [x] **Google Play Billing Library** - รองรับ 7.0+ (ใช้ 7.1.1)
- [x] **Target SDK** - 35 (Android 15)
- [x] **Version Naming** - ตาม Semantic Versioning

---

## 📝 ไฟล์ที่ต้องอัปเดตทุกครั้ง

### 1. `pubspec.yaml` (บรรทัด 4)
```yaml
version: 2.0.0+77
```
**Format:** `versionName+versionCode`
- `2.0.0` = Version name (แสดงให้ user เห็น)
- `77` = Build number / Version code (internal)

### 2. `android/app/build.gradle.kts` (บรรทัด 35-36)
```kotlin
defaultConfig {
    versionCode = 77
    versionName = "2.0.0"
}
```
**Format:**
- `versionCode` = **Integer** (ไม่มี quotes)
- `versionName` = **String** (ต้องมี quotes `""`)

### 3. `lib/features/profile/presentation/profile_screen.dart` (บรรทัด ~370)
```dart
_buildModernSettingCard(
  context: context,
  title: L10n.of(context)!.version,
  subtitle: '2.0.0',  // ⚠️ ต้องเปลี่ยนให้ตรงกับ versionName
  showArrow: false,
),
```
**⚠️ สำคัญ:** ต้องเปลี่ยนเลขเวอร์ชันที่แสดงในหน้า Settings ด้วยทุกครั้ง!

## ⚠️ กฎสำคัญของ Google Play Store

### versionCode (Build Number)
- ✅ ต้องเป็น **positive integer** เท่านั้น
- ✅ ต้อง**มากกว่า**เวอร์ชันก่อนหน้าเสมอ (เช่น 31 → 32 → 33)
- ❌ **ห้าม**ใช้ version code ที่เคยใช้แล้ว
- ❌ **ห้าม**ลดค่า version code (เช่น 32 → 31)

### versionName (Version String)
- ✅ แนะนำ: `"MAJOR.MINOR.PATCH"` (Semantic Versioning)
- ✅ ตัวอย่างที่ถูก: `"1.1.7"`, `"2.0.0"`, `"1.2.3-beta"`
- ⚠️ สามารถใช้รูปแบบอื่นได้ แต่ควรสม่ำเสมอ

---

## 🔄 ขั้นตอนการอัปเดต Version

### ขั้นที่ 1: อัปเดต pubspec.yaml
```bash
# ตัวอย่าง: จาก 2.0.0+76 → 2.0.0+77
version: 2.0.0+77
```

### ขั้นที่ 2: อัปเดต build.gradle.kts
```kotlin
defaultConfig {
    versionCode = 77  // เพิ่มทีละ 1
    versionName = "2.0.0"  // ตรงกับ pubspec
```

### ขั้นที่ 3: อัปเดต profile_screen.dart
```dart
// ไฟล์: lib/features/profile/presentation/profile_screen.dart
// หาบรรทัด ~310 และแก้ subtitle
subtitle: '2.0.0',  // ⚠️ ต้องเปลี่ยนให้ตรงกับ versionName
```

### ขั้นที่ 4: ตรวจสอบ
```bash
# 1. ตรวจสอบ pubspec.yaml
grep "version:" pubspec.yaml

# 2. ตรวจสอบ build.gradle.kts
grep -A2 "defaultConfig" android/app/build.gradle.kts | grep version

# 3. ตรวจสอบ profile_screen.dart
grep "subtitle:" lib/features/profile/presentation/profile_screen.dart
```

### ขั้นที่ 5: Git Commit
```bash
git add pubspec.yaml android/app/build.gradle.kts CHANGELOG.md
git commit -m "build: v2.0.0+77 - description here"
```

---

## 📊 ประวัติ Build Versions

| Build | Version Name | Date | Status |
|-------|-------------|------|--------|
| 77 | 2.0.0 | 2026-03-30 | ✅ Current |
| 76 | 2.0.0 | 2026-03-30 | ✅ Released |
| 75 | 1.2.7 | 2026-03-28 | ✅ Released |
| 74 | 1.2.7 | 2026-03-27 | ✅ Released |
| 73 | 1.2.6 | 2026-03-27 | ✅ Released |
| 72 | 1.2.6 | 2026-03-27 | ❌ Superseded |
| 71 | 1.2.6 | 2026-03-26 | ✅ Released |
| 70 | 1.2.6 | 2026-03-22 | ✅ Released |
| 69 | 1.2.6 | 2026-03-21 | ✅ Released |
| 68 | 1.2.6 | 2026-03-21 | ✅ Released |
| 67 | 1.2.6 | 2026-03-18 | ✅ Released |
| 66 | 1.2.6 | 2026-03-18 | ✅ Released |
| 65 | 1.2.6 | 2026-03-17 | ✅ Released |
| 64 | 1.2.6 | 2026-03-17 | ✅ Released |
| 63 | 1.2.6 | 2026-03-17 | ✅ Released |
| 62 | 1.2.6 | 2026-03-03 | ✅ Released |
| 61 | 1.2.6 | 2026-03-03 | ✅ Released |
| 60 | 1.2.6 | 2026-03-03 | ✅ Released |
| 59 | 1.2.5 | 2026-03-03 | ✅ Released |
| 58 | 1.2.4 | 2026-03-02 | ✅ Released |
| 57 | 1.2.4 | 2026-03-02 | ✅ Released |
| 54 | 1.2.4 | 2026-03-01 | ✅ Released |
| 53 | 1.2.3 | 2026-03-01 | ✅ Released |
| 51 | 1.2.3 | 2026-02-28 | ❌ Rejected (iOS) |
| 50 | 1.2.2 | 2026-02-28 | ✅ Released |
| 49 | 1.2.1 | 2026-02-27 | ✅ Released |
| 48 | 1.2.0 | 2026-02-26 | ✅ Released |
| 47 | 1.1.22 | 2026-02-26 | ✅ Released |
| 46 | 1.1.21 | 2026-02-26 | ✅ Released |
| 45 | 1.1.20 | 2026-02-26 | ✅ Released |
| 44 | 1.1.19 | 2026-02-26 | ✅ Released |
| 43 | 1.1.18 | 2026-02-24 | ✅ Released |
| 42 | 1.1.17 | 2026-02-23 | ✅ Released |
| 41 | 1.1.16 | 2026-02-23 | ✅ Released |
| 40 | 1.1.15 | 2026-02-23 | ✅ Released |
| 39 | 1.1.14 | 2026-02-21 | ✅ Released |
| 38 | 1.1.13 | 2026-02-21 | ✅ Released |
| 37 | 1.1.12 | 2026-02-20 | ✅ Released |
| 36 | 1.1.11 | 2026-02-20 | ✅ Released |
| 35 | 1.1.10 | 2026-02-20 | ✅ Released |
| 34 | 1.1.9 | 2026-02-20 | ✅ Released |
| 33 | 1.1.8 | 2026-02-19 | ✅ Released |
| 32 | 1.1.7 | 2026-02-19 | ✅ Released |
| 31 | 1.1.6 | 2026-02-18 | ✅ Released |
| 30 | 1.1.5 | 2026-02-18 | ✅ Released |

---

## 🐛 ปัญหาที่พบบ่อย

### ❌ Google Play ปฏิเสธ: "Version code already used"
**สาเหตุ:** ใช้ versionCode ที่เคยอัปโหลดไปแล้ว
**วิธีแก้:** เพิ่ม versionCode ให้มากกว่าเดิม (เช่น 32 → 33)

### ❌ Google Play ปฏิเสธ: "Version code must be an integer"
**สาเหตุ:** เขียน `versionCode = "32"` (มี quotes)
**วิธีแก้:** ลบ quotes ออก → `versionCode = 32`

### ❌ Flutter Build ล้มเหลว: "Version mismatch"
**สาเหตุ:** pubspec.yaml และ build.gradle.kts ไม่ตรงกัน
**วิธีแก้:** ตรวจสอบให้ตรงกัน:
- `pubspec.yaml`: `1.2.4+58`
- `build.gradle.kts`: `versionCode = 58`, `versionName = "1.2.4"`

### ❌ Version ไม่ตรงในหน้า Settings
**สาเหตุ:** ลืมแก้เลขเวอร์ชันใน `profile_screen.dart`
**วิธีแก้:** เปิดไฟล์ `lib/features/profile/presentation/profile_screen.dart` บรรทัด ~310
```dart
subtitle: '2.0.0',  // แก้ให้ตรงกับ versionName
```
**⚠️ เป็นข้อผิดพลาดที่พบบ่อย - อย่าลืมแก้ทุกครั้ง!**

---

## 🚀 ก่อน Deploy ไป Google Play

### Pre-flight Checklist (Build 77 / v2.0.0):
- [ ] Version ใน pubspec.yaml และ build.gradle.kts ตรงกัน (`2.0.0+77`)
- [ ] versionCode เพิ่มขึ้นจากเวอร์ชันก่อนหน้า (76 → 77)
- [ ] **profile_screen.dart เลขเวอร์ชันอัปเดตแล้ว** ⚠️ (`'2.0.0'`)
- [ ] CHANGELOG.md อัปเดตแล้ว (v2.0.0+77)
- [x] AdMob: AD_ID permission ใน AndroidManifest.xml (`com.google.android.gms.permission.AD_ID`)
- [x] Target SDK 35 (Android 15) และ Compile SDK 36 (Android 16)
- [x] Google Play Billing Library รองรับ 7.0+ (Billing Library 7.1.1 ใน AndroidManifest.xml)
- [ ] Build และทดสอบ APK/AAB บนเครื่อง
- [ ] Git commit และ push แล้ว

### Build Commands:
```bash
# Clean build
flutter clean
flutter pub get

# Build Release APK (for testing)
flutter build apk --release

# Build Release App Bundle (for Google Play)
flutter build appbundle --release
```

### Location of Built Files:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

---

## 📞 Contact

หากพบปัญหาหรือข้อสงสัย:
- ตรวจสอบ [Google Play Console](https://play.google.com/console)
- อ่าน [Android Versioning Guide](https://developer.android.com/studio/publish/versioning)
