# Build Version Checklist

เอกสารนี้ใช้สำหรับตรวจสอบความถูกต้องของ Build Version ก่อน Deploy ไป Google Play Store

---

## ✅ Build 34 (v1.1.9) - Status: READY FOR PRODUCTION

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
version: 1.1.9+34
```
**Format:** `versionName+versionCode`
- `1.1.9` = Version name (แสดงให้ user เห็น)
- `34` = Build number / Version code (internal)

### 2. `android/app/build.gradle.kts` (บรรทัด 35-36)
```kotlin
defaultConfig {
    versionCode = 34
    versionName = "1.1.9"
}
```
**Format:**
- `versionCode` = **Integer** (ไม่มี quotes)
- `versionName` = **String** (ต้องมี quotes `""`)

---

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
# ตัวอย่าง: จาก 1.1.8+33 → 1.1.9+34
version: 1.1.9+34
```

### ขั้นที่ 2: อัปเดต build.gradle.kts
```kotlin
defaultConfig {
    versionCode = 34  // เพิ่มทีละ 1
    versionName = "1.1.9"  // ตรงกับ pubspec
}
```

### ขั้นที่ 3: ตรวจสอบ
```bash
# 1. ตรวจสอบ pubspec.yaml
grep "version:" pubspec.yaml

# 2. ตรวจสอบ build.gradle.kts
grep -A2 "defaultConfig" android/app/build.gradle.kts | grep version
```

### ขั้นที่ 4: Git Commit
```bash
git add pubspec.yaml android/app/build.gradle.kts CHANGELOG.md
git commit -m "build: v1.1.9+34 - Smart Chat Context-Aware AI & Data Source Icons"
```

---

## 📊 ประวัติ Build Versions

| Build | Version Name | Date | Status |
|-------|-------------|------|--------|
| 34 | 1.1.9 | 2026-02-20 | ✅ Current |
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
- `pubspec.yaml`: `1.1.9+34`
- `build.gradle.kts`: `versionCode = 34`, `versionName = "1.1.9"`

---

## 🚀 ก่อน Deploy ไป Google Play

### Pre-flight Checklist:
- [ ] Version ใน pubspec.yaml และ build.gradle.kts ตรงกัน
- [ ] versionCode เพิ่มขึ้นจากเวอร์ชันก่อนหน้า
- [ ] CHANGELOG.md อัปเดตแล้ว
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
