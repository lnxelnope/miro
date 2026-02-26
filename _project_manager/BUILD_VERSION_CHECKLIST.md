# Build Version Checklist

เอกสารนี้ใช้สำหรับตรวจสอบความถูกต้องของ Build Version ก่อน Deploy ไป Google Play Store

**อัปเดตล่าสุด:** 2026-02-26

---

## ✅ Build 44 (v1.1.19) - Status: READY FOR PRODUCTION

### 📋 Checklist

- [ ] **pubspec.yaml** - Version format ถูกต้อง (`1.1.19+44`)
- [ ] **android/app/build.gradle.kts** - Version sync ตรงกัน (`versionCode = 44`, `versionName = "1.1.19"`)
- [ ] **lib/features/profile/presentation/profile_screen.dart** - Version display in Settings (`'1.1.19'`)
- [ ] **Google Play Billing Library** - รองรับ 7.0+ (ใช้ 7.1.1)
- [ ] **Target SDK** - 35 (Android 15)
- [ ] **Compile SDK** - 36 (Android 16)
- [ ] **Version Naming** - ตาม Semantic Versioning
- [ ] **CHANGELOG.md** - อัปเดตแล้ว
- [ ] **AdMob Compliance** - AD_ID (Android), NSUserTrackingUsageDescription + SKAdNetworkItems (iOS), UMP Consent flow

### ✨ Changes in this version:
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
version: 1.1.19+44
```
**Format:** `versionName+versionCode`
- `1.1.14` = Version name (แสดงให้ user เห็น)
- `39` = Build number / Version code (internal)

### 2. `android/app/build.gradle.kts` (บรรทัด 35-36)
```kotlin
defaultConfig {
    versionCode = 44
    versionName = "1.1.19"
}
```
**Format:**
- `versionCode` = **Integer** (ไม่มี quotes)
- `versionName` = **String** (ต้องมี quotes `""`)

### 3. `lib/features/profile/presentation/profile_screen.dart` (บรรทัด ~310)
```dart
_buildModernSettingCard(
  context: context,
  title: L10n.of(context)!.version,
  subtitle: '1.1.19',  // ⚠️ ต้องเปลี่ยนให้ตรงกับ versionName
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
# ตัวอย่าง: จาก 1.1.18+43 → 1.1.19+44
version: 1.1.19+44
```

### ขั้นที่ 2: อัปเดต build.gradle.kts
```kotlin
defaultConfig {
    versionCode = 44  // เพิ่มทีละ 1
    versionName = "1.1.19"  // ตรงกับ pubspec
```

### ขั้นที่ 3: อัปเดต profile_screen.dart
```dart
// ไฟล์: lib/features/profile/presentation/profile_screen.dart
// หาบรรทัด ~310 และแก้ subtitle
subtitle: '1.1.19',  // ⚠️ ต้องเปลี่ยนให้ตรงกับ versionName
```

### ขั้นที่ 4: ตรวจสอบ
```bash
# 1. ตรวจสอบ pubspec.yaml
grep "version:" pubspec.yaml

# 2. ตรวจสอบ build.gradle.kts
grep -A2 "defaultConfig" android/app/build.gradle.kts | grep version

# 3. ตรวจสอบ profile_screen.dart
grep "subtitle: '1\\.1\\." lib/features/profile/presentation/profile_screen.dart
```

### ขั้นที่ 5: Git Commit
```bash
git add pubspec.yaml android/app/build.gradle.kts CHANGELOG.md
git commit -m "build: v1.1.18+43 - description here"
```

---

## 📊 ประวัติ Build Versions

| Build | Version Name | Date | Status |
|-------|-------------|------|--------|
| 44 | 1.1.19 | 2026-02-26 | ✅ Current |
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
- `pubspec.yaml`: `1.1.19+44`
- `build.gradle.kts`: `versionCode = 44`, `versionName = "1.1.19"`

### ❌ Version ไม่ตรงในหน้า Settings
**สาเหตุ:** ลืมแก้เลขเวอร์ชันใน `profile_screen.dart`
**วิธีแก้:** เปิดไฟล์ `lib/features/profile/presentation/profile_screen.dart` บรรทัด ~310
```dart
subtitle: '1.1.19',  // แก้ให้ตรงกับ versionName
```
**⚠️ เป็นข้อผิดพลาดที่พบบ่อย - อย่าลืมแก้ทุกครั้ง!**

---

## 🚀 ก่อน Deploy ไป Google Play

### Pre-flight Checklist:
- [ ] Version ใน pubspec.yaml และ build.gradle.kts ตรงกัน
- [ ] versionCode เพิ่มขึ้นจากเวอร์ชันก่อนหน้า
- [ ] **profile_screen.dart เลขเวอร์ชันอัปเดตแล้ว** ⚠️
- [ ] CHANGELOG.md อัปเดตแล้ว
- [ ] AdMob: AD_ID (Android), ATT + SKAdNetwork (iOS), UMP Consent flow
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
