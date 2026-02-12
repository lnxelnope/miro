# Step 41: English-Only v1.0 + Production Cleanup

> **For:** Junior Developer
> **Estimated time:** 2-3 days
> **Difficulty:** Medium (tedious but straightforward)
> **Prerequisites:** Step 40 complete

---

## Goal

v1.0 launches as **English-only** for global market. No Thai UI at all.

1. **Replace ALL hardcoded Thai strings** in UI → English
2. **Replace ALL `debugPrint`** → `AppLogger` (~300 calls in 33 files)
3. **Fix Privacy Policy placeholder URLs**
4. **Set English as default/only locale**
5. **Verify icon/splash** already configured correctly

---

## IMPORTANT RULES

- **DO NOT** delete Thai food names from `thai_food_database.dart` — those are DATA not UI
- **DO NOT** delete `app_th.arb` — keep for future Thai release
- **DO NOT** change unit keys (`_legacyMap` Thai → English mapping must stay)
- **DO NOT** touch `_unitDisplayNames` Thai entries — they're for future locale support
- **USE `L10n.of(context)!.keyName`** wherever possible (keys already exist in `app_en.arb`)
- Where L10n keys don't exist yet → **add new keys to BOTH `app_th.arb` AND `app_en.arb`** then use L10n

---

## Part A: Set English as Default Locale

### File: `lib/main.dart`

**Change `supportedLocales` order** (English first = default):

```dart
// BEFORE
supportedLocales: const [
  Locale('th'),  // ไทย
  Locale('en'),  // อังกฤษ
],

// AFTER
supportedLocales: const [
  Locale('en'),  // English (default)
  Locale('th'),  // Thai (future)
],
```

**Also initialize English date formatting:**

```dart
// BEFORE
await initializeDateFormatting('th', null);

// AFTER
await initializeDateFormatting('en', null);
await initializeDateFormatting('th', null); // keep for Thai food DB dates
```

---

## Part B: Replace `debugPrint` → `AppLogger`

### How to do it

1. Open each file listed below
2. Add import: `import 'package:miro/core/utils/logger.dart';`
   - Or relative: `import '../../../core/utils/logger.dart';` (adjust `../` count)
3. Replace `debugPrint(` calls:
   - Normal info/log → `AppLogger.info(`
   - Error messages → `AppLogger.error(`
   - Warning → `AppLogger.warn(`

### Files to fix (sorted by count, highest first)

| # | File | Count | Import path |
|---|------|-------|-------------|
| 1 | `lib/features/scanner/logic/scan_controller.dart` | 43 | `../../../core/utils/logger.dart` |
| 2 | `lib/core/services/permission_service.dart` | 23 | `../utils/logger.dart` |
| 3 | `lib/core/ai/llm_service.dart` | 20 | `../utils/logger.dart` |
| 4 | `lib/core/data/global_food_database.dart` | 18 | `../utils/logger.dart` |
| 5 | `lib/features/scanner/providers/scanner_provider.dart` | 18 | `../../../core/utils/logger.dart` |
| 6 | `lib/features/scanner/services/gallery_service.dart` | 16 | `../../../core/utils/logger.dart` |
| 7 | `lib/features/scanner/services/vision_processor.dart` | 16 | `../../../core/utils/logger.dart` |
| 8 | `lib/features/chat/services/intent_handler.dart` | 16 | `../../../core/utils/logger.dart` |
| 9 | `lib/core/ai/gemini_service.dart` | 16 | `../utils/logger.dart` |
| 10 | `lib/features/health/providers/health_provider.dart` | 13 | `../../../core/utils/logger.dart` |
| 11 | `lib/features/timeline/presentation/timeline_screen.dart` | 13 | `../../../core/utils/logger.dart` |
| 12 | `lib/core/services/purchase_service.dart` | 10 | `../utils/logger.dart` |
| 13 | `lib/features/health/presentation/health_timeline_tab.dart` | 8 | `../../../core/utils/logger.dart` |
| 14 | `lib/core/services/calendar_service.dart` | 8 | `../utils/logger.dart` |
| 15 | `lib/core/services/google_auth_service.dart` | 7 | `../utils/logger.dart` |
| 16 | `lib/features/chat/providers/chat_provider.dart` | 7 | `../../../core/utils/logger.dart` |
| 17 | `lib/features/health/widgets/food_detail_bottom_sheet.dart` | 7 | `../../../core/utils/logger.dart` |
| 18 | `lib/features/chat/services/food_lookup_service.dart` | 7 | `../../../core/utils/logger.dart` |
| 19 | `lib/features/home/presentation/home_screen.dart` | 6 | `../../../core/utils/logger.dart` |
| 20 | `lib/features/scanner/services/qr_parser.dart` | 5 | `../../../core/utils/logger.dart` |
| 21 | `lib/features/health/widgets/create_meal_sheet.dart` | 5 | `../../../core/utils/logger.dart` |
| 22 | `lib/features/health/providers/my_meal_provider.dart` | 5 | `../../../core/utils/logger.dart` |
| 23 | `lib/main.dart` | 5 | `core/utils/logger.dart` |
| 24 | `lib/features/health/presentation/barcode_scanner_screen.dart` | 5 | `../../../core/utils/logger.dart` |
| 25 | `lib/features/health/presentation/health_diet_tab.dart` | 4 | `../../../core/utils/logger.dart` |
| 26 | `lib/features/finance/presentation/finance_timeline_tab.dart` | 4 | `../../../core/utils/logger.dart` |
| 27 | `lib/core/services/price_service.dart` | 3 | `../utils/logger.dart` |
| 28 | `lib/core/services/voice_input_service.dart` | 2 | `../utils/logger.dart` |
| 29 | `lib/features/health/widgets/edit_food_bottom_sheet.dart` | 1 | `../../../core/utils/logger.dart` |
| 30 | `lib/features/health/widgets/food_search_field.dart` | 1 | `../../../core/utils/logger.dart` |
| 31 | `lib/features/health/presentation/nutrition_label_screen.dart` | 1 | `../../../core/utils/logger.dart` |
| 32 | `lib/core/services/nudge_service.dart` | 1 | `../utils/logger.dart` |

**Total: ~300 replacements in 32 files**

### Replacement rules

| Pattern in debugPrint | Replace with |
|-----------------------|-------------|
| `debugPrint('✅ ...')` or `debugPrint('🚀 ...')` | `AppLogger.info('...')` |
| `debugPrint('[ERROR] ...')` or `debugPrint('❌ ...')` | `AppLogger.error('...')` |
| `debugPrint('⚠️ ...')` | `AppLogger.warn('...')` |
| `debugPrint('[XXX] something: $variable')` | `AppLogger.info('something: $variable')` |
| Inside `catch (e)` blocks | `AppLogger.error('description', e)` |

### After replacing all, verify:

```bash
# Should return 0 results (except logger.dart itself)
# Search: debugPrint( in lib/ excluding logger.dart
```

---

## Part C: Replace Thai Strings → English

### Strategy

**Where L10n key already exists** → use `L10n.of(context)!.keyName`
**Where L10n key does NOT exist** → add key to BOTH ARB files first, then use L10n
**Inside services without BuildContext** (intent_handler, gemini_service prompts) → hardcode English directly

### Import needed in every UI file:

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
```

### Shorthand (add at top of build methods):

```dart
final l10n = L10n.of(context)!;
```

---

### C1. Priority: HIGH — Main screens users see first

#### File: `lib/features/home/presentation/home_screen.dart` (~6 Thai strings)

| Thai | English |
|------|---------|
| `'ขออนุญาตเข้าถึง'` | `'Permission Required'` |
| `'Miro ต้องการเข้าถึงข้อมูลต่อไปนี้:'` | `'Miro needs access to the following:'` |
| `'รูปภาพ - เพื่อสแกนอาหารและใบเสร็จ'` | `'Photos — to scan food'` |
| `'กล้อง - เพื่อถ่ายรูปอาหารและใบเสร็จ'` | `'Camera — to photograph food'` |
| `'ข้าม'` | `'Skip'` |
| `'อนุญาต'` | `'Allow'` |
| `'✅ ได้รับอนุญาตทั้งหมดแล้ว'` | `'All permissions granted'` |
| `'⚠️ ไม่ได้รับอนุญาต: $denied'` | `'Permission denied: $denied'` |
| `'เปิด Settings'` | `'Open Settings'` |

#### File: `lib/features/onboarding/presentation/onboarding_screen.dart` (~20 Thai strings)

| Thai | English |
|------|---------|
| `'บันทึกอาหารง่ายๆ ด้วย AI'` | `'Easy food logging with AI'` |
| `'ถ่ายรูปอาหาร'` | `'Snap a photo'` |
| `'AI วิเคราะห์ kcal อัตโนมัติ'` | `'AI calculates calories automatically'` |
| `'พิมพ์แชท'` | `'Type to log'` |
| `'บอกว่า "กินข้าวผัด" → บันทึกให้เลย'` | `'Say "had fried rice" → logged instantly'` |
| `'สรุปทุกวัน'` | `'Daily summary'` |
| `'ดู kcal, โปรตีน, คาร์บ, ไขมัน'` | `'Track kcal, protein, carbs, fat'` |
| `'ข้อมูลพื้นฐาน'` | `'Basic Info'` |
| `'เพื่อคำนวณเป้าหมายแคลอรี่ที่เหมาะกับคุณ'` | `'To calculate your recommended daily calories'` |
| `'เพศ'` → `'Gender'` | |
| `'ชาย'` → `'Male'` | |
| `'หญิง'` → `'Female'` | |
| `'อายุ'` → `'Age'` | |
| `'น้ำหนัก'` → `'Weight'` | |
| `'ส่วนสูง'` → `'Height'` | |
| `'ระดับกิจกรรม'` → `'Activity Level'` | |
| `'แนะนำเป้าหมาย'` → `'Recommended Goals'` | |
| `'ตั้งค่า Gemini AI'` → `'Set up Gemini AI'` | |
| `'ตั้งค่าเลย'` → `'Set up now'` | |
| `'ข้ามไปก่อน → เข้าแอป'` → `'Skip for now'` | |

#### File: `lib/features/profile/presentation/profile_screen.dart` (~53 Thai strings)

| Thai | English |
|------|---------|
| `'โปรไฟล์ & การตั้งค่า'` | `'Profile & Settings'` |
| `'ขอบคุณที่สนับสนุน! AI ไม่จำกัด'` | `'Thank you for your support! Unlimited AI'` |
| `'อัปเกรด Pro'` | `'Upgrade to Pro'` |
| `'ใช้ AI วิเคราะห์อาหารไม่จำกัด'` | `'Unlimited AI food analysis'` |
| `'กู้คืนการซื้อ'` | `'Restore Purchase'` |
| `'สำหรับเปลี่ยนเครื่อง'` | `'For device transfers'` |
| `'กำลังตรวจสอบการซื้อ...'` | `'Checking purchase...'` |
| `'ยังไม่ตั้งค่า'` | `'Not configured'` |
| `'กำลังโหลด...'` | `'Loading...'` |
| `'แคลอรี่/วัน'` | `'Calories/day'` |
| `'โปรตีน/วัน'` | `'Protein/day'` |
| `'คาร์บ/วัน'` | `'Carbs/day'` |
| `'ไขมัน/วัน'` | `'Fat/day'` |
| `'ล้างข้อมูลทั้งหมด'` | `'Clear All Data'` |
| `'เวอร์ชัน'` | `'Version'` |
| `'นโยบายความเป็นส่วนตัว'` | `'Privacy Policy'` |
| `'เงื่อนไขการใช้งาน'` | `'Terms of Service'` |
| `'ล้างข้อมูลทั้งหมด?'` | `'Clear all data?'` |
| `'ข้อมูลทั้งหมดจะถูกลบ...'` | `'All data will be deleted...'` |
| `'ยกเลิก'` | `'Cancel'` |
| `'ลบทั้งหมด'` | `'Delete All'` |
| `'ล้างข้อมูลเรียบร้อย'` | `'Data cleared successfully'` |
| Section titles: `'⭐ Pro'`, `'🔑 API Settings'`, `'🎯 เป้าหมายสุขภาพ'`, `'📸 การสแกนรูปภาพ'`, `'💾 ข้อมูล'`, `'ℹ️ เกี่ยวกับ'` | `'⭐ Pro'`, `'🔑 API Settings'`, `'🎯 Health Goals'`, `'📸 Photo Scan'`, `'💾 Data'`, `'ℹ️ About'` |
| Scan settings: `'สแกนย้อนหลัง'`, `'จำนวนรูปที่สแกน'`, etc. | `'Scan history'`, `'Images to scan'`, etc. |

#### File: `lib/features/profile/presentation/api_key_screen.dart` (~37 Thai strings)

| Thai | English |
|------|---------|
| `'ตั้งค่า Gemini API Key'` | `'Set up Gemini API Key'` |
| `'วิเคราะห์อาหารด้วย AI'` | `'AI Food Analysis'` |
| `'ถ่ายรูปอาหาร → AI คำนวณแคลอรี่ให้อัตโนมัติ'` | `'Snap food photos → AI calculates calories automatically'` |
| `'Gemini API ใช้ฟรี ไม่ต้องจ่ายเงิน!'` | `'Gemini API is free!'` |
| Step titles: `'เปิด Google AI Studio'`, `'ล็อกอิน Google Account'`, `'คลิก "Create API Key"'`, `'คัดลอก Key แล้วกลับมาวางด้านล่าง'`, `'วาง API Key ที่นี่'` | `'Open Google AI Studio'`, `'Log in to Google'`, `'Click "Create API Key"'`, `'Copy Key and paste below'`, `'Paste API Key here'` |
| FAQ: `'ฟรีจริงไหม?'`, `'ปลอดภัยไหม?'`, `'ถ้าไม่สร้าง Key ล่ะ?'`, `'ต้องมีบัตรเครดิตไหม?'` | `'Is it really free?'`, `'Is it safe?'`, `'What if I don\'t create a Key?'`, `'Do I need a credit card?'` |
| All answers → translate to English |

#### File: `lib/features/profile/presentation/health_goals_screen.dart` (~11 Thai strings)

Translate all labels: เป้าหมาย, แคลอรี่, โปรตีน, คาร์บ, ไขมัน, น้ำ, บันทึก, etc.

#### File: `lib/features/home/widgets/magic_button.dart` (~4 Thai strings)

| Thai | English |
|------|---------|
| `'สวัสดีครับ!'` | `'Hello!'` |
| `'พิมพ์เพื่อเริ่มแชท'` | `'Type to start chatting'` |
| `'สั่ง Miro เช่น "บันทึกข้าวผัด"...'` | `'Tell Miro e.g. "log fried rice"...'` |
| `'ปัดขึ้นเพื่อดูประวัติการแชททั้งหมด'` | `'Swipe up for full chat history'` |

---

### C2. Priority: HIGH — Food logging screens

#### File: `lib/features/health/presentation/health_timeline_tab.dart` (~33 Thai strings)

Summary card, date labels, API key banner, upsell banner, meal section headers, error messages → all English

#### File: `lib/features/health/presentation/health_diet_tab.dart` (~13 Thai strings)

Add food form, meal type labels, validation messages → all English

#### File: `lib/features/health/widgets/edit_food_bottom_sheet.dart` (~22 Thai strings)

Edit form labels, save/cancel, validation → all English

#### File: `lib/features/health/widgets/food_detail_bottom_sheet.dart` (~17 Thai strings)

Food detail view, Gemini analysis button, nutrition labels → all English

#### File: `lib/features/health/widgets/gemini_analysis_sheet.dart` (~23 Thai strings)

Analysis progress, results, save button → all English

#### File: `lib/features/health/widgets/create_meal_sheet.dart` (~28 Thai strings)

Create meal form, ingredient list, Gemini lookup → all English

#### File: `lib/features/health/presentation/food_preview_screen.dart` (~15 Thai strings)

Camera preview, analysis button, results → all English

---

### C3. Priority: HIGH — Chat & AI

#### File: `lib/features/chat/services/intent_handler.dart` (~77 Thai strings)

This file has TWO types of Thai:

**Type 1: User-facing response messages** → Replace with English:
| Thai | English |
|------|---------|
| `'บันทึกอาหารแล้ว!'` | `'Food logged!'` |
| `'ขออภัยครับ ฟังก์ชันนี้ยังไม่พร้อม...'` | `'Sorry, this feature is not available yet'` |
| Error messages | English error messages |

**Type 2: Thai keyword detection** → KEEP both Thai + English:
```dart
// KEEP both — user might still type Thai food names
static const _foodKeywordsTh = ['กิน', 'ทาน', ...]; // KEEP
static const _foodKeywordsEn = ['ate', 'eat', ...];   // KEEP
```

#### File: `lib/core/ai/llm_service.dart` (~110 Thai strings)

This file has Thai in:
- Gemini prompts → MUST CHANGE to English prompts (critical for English users!)
- Thai food name matching → KEEP (data, not UI)
- Response parsing → may need adjustment

**CRITICAL:** Change all Gemini prompts from Thai to English. Example:

```dart
// BEFORE
'คุณเป็น AI ที่เชี่ยวชาญด้านโภชนาการอาหารไทยและนานาชาติ...'

// AFTER  
'You are a nutrition expert AI specializing in global and Thai cuisine...'
```

#### File: `lib/core/ai/gemini_service.dart` (~38 Thai strings)

- Error messages → English
- Prompts → English  
- `showNoApiKeyDialog` → English text
- `_showUpgradeDialog` → English text

#### File: `lib/features/chat/presentation/chat_screen.dart` (~23 Thai strings)

Chat UI labels → all English

---

### C4. Priority: MEDIUM — Other UI

#### File: `lib/features/health/widgets/log_from_meal_sheet.dart` (~8)
#### File: `lib/features/health/presentation/health_my_meal_tab.dart` (~24)
#### File: `lib/features/health/widgets/quick_add_section.dart` (~6)
#### File: `lib/features/health/widgets/meal_section.dart` (~1)
#### File: `lib/features/health/widgets/edit_ingredient_sheet.dart` (~9)
#### File: `lib/features/health/presentation/nutrition_label_screen.dart` (~10)
#### File: `lib/features/health/presentation/barcode_scanner_screen.dart` (~11)
#### File: `lib/features/health/widgets/my_meal_card.dart` (~3)
#### File: `lib/features/health/widgets/ingredient_card.dart` (~2)
#### File: `lib/features/timeline/presentation/entry_detail_screen.dart` (~37)
#### File: `lib/features/timeline/presentation/widgets/timeline_card.dart` (~12)

All → translate Thai text to English.

---

### C5. Priority: LOW — Hidden/unused screens (but still translate)

These screens are hidden in v1 but may have Thai that shows in edge cases:

#### File: `lib/core/constants/enums.dart` (~23 Thai strings)

Meal type labels, etc. → add English equivalents or use L10n:

```dart
// BEFORE
String get label {
  switch (this) {
    case MealType.breakfast: return 'เช้า';
    ...
  }
}

// AFTER
String get label {
  switch (this) {
    case MealType.breakfast: return 'Breakfast';
    case MealType.lunch: return 'Lunch';
    case MealType.dinner: return 'Dinner';
    case MealType.snack: return 'Snack';
  }
}
```

#### File: `lib/core/utils/error_handler.dart` (~3 Thai strings)

Error messages → English

#### Files in hidden features (scanner, finance, tasks, insights):

These are commented out / hidden, but if any Thai strings leak through (e.g. via providers), translate them. Lower priority.

---

### C6. Files to NOT change Thai in

| File | Reason |
|------|--------|
| `lib/l10n/app_th.arb` | This IS the Thai translation file |
| `lib/l10n/app_localizations_th.dart` | Generated from ARB |
| `lib/core/data/thai_food_database.dart` | Thai food NAMES are data, not UI |
| `lib/core/utils/unit_converter.dart` `_unitDisplayNames` Thai entries | For future locale support |
| `lib/core/utils/unit_converter.dart` `_legacyMap` | Maps old Thai unit keys to English |
| `lib/core/utils/tdee_calculator.dart` `activityLevels` Thai entries | For future locale |

---

## Part D: Fix Privacy Policy Placeholder URLs

### File: `lib/features/profile/presentation/profile_screen.dart`

Replace placeholder URLs with real ones:

```dart
// BEFORE
onTap: () => _openUrl(context, 'https://yourname.github.io/miro-cal-legal/privacy-policy'),
// ...
onTap: () => _openUrl(context, 'https://yourname.github.io/miro-cal-legal/terms'),

// AFTER — replace with REAL URLs:
onTap: () => _openUrl(context, 'https://YOUR-REAL-URL/privacy-policy'),
// ...
onTap: () => _openUrl(context, 'https://YOUR-REAL-URL/terms'),
```

> **Action required from project owner:** Create and host Privacy Policy + Terms pages, then provide URLs.

---

## Part E: Verify Icon & Splash

The logo is already configured correctly:

- **Logo file:** `assets/icon/logo.png` ✅ (exists)
- **pubspec.yaml config:** ✅

```yaml
flutter_launcher_icons:
  android: true
  image_path: "assets/icon/logo.png"         # ✅
  adaptive_icon_foreground: "assets/icon/logo.png"  # ✅

flutter_native_splash:
  color: "#6366F1"
  image: "assets/icon/logo.png"              # ✅
```

**After making changes, regenerate:**

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

---

## Part F: Run `flutter gen-l10n` After Adding Keys

If you added new L10n keys to the ARB files:

```bash
flutter gen-l10n
```

Or just:

```bash
flutter pub get   # auto-generates if `generate: true` in pubspec.yaml
```

---

## Checklist

### Part A: Locale
- [ ] `supportedLocales` — English first
- [ ] English date formatting initialized

### Part B: debugPrint → AppLogger
- [ ] All 32 files converted
- [ ] Search `debugPrint(` in `lib/` → only `logger.dart` remains
- [ ] `flutter analyze` — no errors

### Part C: Thai → English  
- [ ] `home_screen.dart` — all English
- [ ] `onboarding_screen.dart` — all English
- [ ] `profile_screen.dart` — all English
- [ ] `api_key_screen.dart` — all English
- [ ] `health_goals_screen.dart` — all English
- [ ] `magic_button.dart` — all English
- [ ] `health_timeline_tab.dart` — all English
- [ ] `health_diet_tab.dart` — all English
- [ ] `edit_food_bottom_sheet.dart` — all English
- [ ] `food_detail_bottom_sheet.dart` — all English
- [ ] `gemini_analysis_sheet.dart` — all English
- [ ] `create_meal_sheet.dart` — all English
- [ ] `food_preview_screen.dart` — all English
- [ ] `intent_handler.dart` — responses English, keywords keep both TH+EN
- [ ] `llm_service.dart` — ALL Gemini prompts English
- [ ] `gemini_service.dart` — error messages + dialogs English
- [ ] `chat_screen.dart` — all English
- [ ] `enums.dart` — meal labels English
- [ ] All other files listed in C4 — all English
- [ ] Search for Thai characters outside allowed files → 0 results

### Part D: URLs
- [ ] Privacy Policy URL — real URL (not placeholder)
- [ ] Terms of Service URL — real URL (not placeholder)

### Part E: Icon/Splash
- [ ] `dart run flutter_launcher_icons` — success
- [ ] `dart run flutter_native_splash:create` — success

### Final
- [ ] `flutter analyze` — 0 errors
- [ ] `flutter build apk --release` — success
- [ ] Install on device — all UI in English
- [ ] No Thai text visible anywhere in the app UI

---

## Verification: Find remaining Thai strings

After completing all changes, run this search to find any remaining Thai:

**Search regex in `lib/` (excluding `l10n/`, `thai_food_database.dart`, `unit_converter.dart`):**

Pattern: `[ก-๙]` in `.dart` files

Any hits outside these allowed files must be fixed:
- `lib/l10n/*` — OK (translation files)
- `lib/core/data/thai_food_database.dart` — OK (food data)
- `lib/core/utils/unit_converter.dart` — OK (display names + legacy map)
- `lib/core/utils/tdee_calculator.dart` — OK (activity level labels for future)

Everything else → must be English.

---

## Done! Ready for Global v1.0 English Release
