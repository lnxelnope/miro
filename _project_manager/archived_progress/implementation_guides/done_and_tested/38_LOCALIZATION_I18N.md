# Step 38: Localization (i18n) — ตั้ง Framework + แปลง Strings

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 3-5 วัน
> **ความยาก:** ปานกลาง-สูง (ปริมาณงานเยอะ ~550 strings, 30 ไฟล์)
> **ต้องทำก่อน:** Step 37 (Publish v1.0 Thai)

---

## 🎯 เป้าหมาย

1. **ตั้ง Flutter Localization Framework** — ใช้ `intl` + ARB files
2. **สร้าง ARB files** สำหรับ ไทย + อังกฤษ
3. **แปลง hardcoded Thai strings** → L10n keys (~550 จุด, ~30 ไฟล์)
4. **ปรับ Gemini Prompts** ให้ dynamic ตาม locale
5. **เพิ่ม Language Switcher** ใน Settings

---

## 📐 ภาพรวม

```
ก่อน:
  Text('กรุณากรอกชื่ออาหาร')          ← hardcoded Thai

หลัง:
  Text(L10n.of(context)!.pleaseEnterFoodName)  ← dynamic ตาม locale
  
  app_th.arb → "pleaseEnterFoodName": "กรุณากรอกชื่ออาหาร"
  app_en.arb → "pleaseEnterFoodName": "Please enter food name"
```

---

## 📂 ไฟล์ที่เกี่ยวข้อง

### สร้างใหม่

| ไฟล์ | คำอธิบาย |
|------|----------|
| `l10n.yaml` | Config สำหรับ localization |
| `lib/l10n/app_th.arb` | ภาษาไทย (ต้นฉบับ) |
| `lib/l10n/app_en.arb` | ภาษาอังกฤษ |

### แก้ไข

| ไฟล์ | จำนวน Thai strings | ความยาก |
|------|--------------------|---------|
| `pubspec.yaml` | - | ง่าย |
| `lib/main.dart` | - | ง่าย |
| `edit_food_bottom_sheet.dart` | ~76 | สูง |
| `gemini_analysis_sheet.dart` | ~76 | สูง |
| `intent_handler.dart` | ~75 | ปานกลาง |
| `food_preview_screen.dart` | ~63 | สูง |
| `health_diet_tab.dart` | ~39 | ปานกลาง |
| `health_timeline_tab.dart` | ~31 | ปานกลาง |
| `create_meal_sheet.dart` | ~30 | ปานกลาง |
| `food_detail_bottom_sheet.dart` | ~18 | ต่ำ |
| `gemini_service.dart` (prompts) | ~16 | พิเศษ |
| `api_key_screen.dart` | ~13 | ต่ำ |
| `health_goals_screen.dart` | ~11 | ต่ำ |
| อื่นๆ (~20 ไฟล์) | ~100 | ต่ำ |
| **รวม ~30 ไฟล์** | **~550** | |

---

## 🔧 ขั้นตอนการทำงาน

### Step 1: ตั้ง Localization Framework

#### 1.1 แก้ pubspec.yaml

**ไฟล์:** `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:       # ← เพิ่ม
    sdk: flutter
  intl: ^0.19.0                # ← มีอยู่แล้ว ถ้าไม่มีเพิ่ม

flutter:
  generate: true               # ← เพิ่มบรรทัดนี้! (เปิด code generation)
  # ... assets, fonts ที่มีอยู่ ...
```

#### 1.2 สร้าง l10n.yaml

**ไฟล์:** `l10n.yaml` (ที่ root ของ project — ข้างๆ pubspec.yaml)
**Action:** CREATE

```yaml
arb-dir: lib/l10n
template-arb-file: app_th.arb
output-localization-file: app_localizations.dart
output-class: L10n
```

> **อธิบาย:**
> - `arb-dir` → folder ที่เก็บ ARB files
> - `template-arb-file` → ภาษาไทยเป็นต้นฉบับ (เพราะเราเขียนไทยก่อน)
> - `output-class: L10n` → ชื่อ class ที่จะใช้ในโค้ด

#### 1.3 สร้าง ARB Files

สร้าง folder `lib/l10n/`

**ไฟล์:** `lib/l10n/app_th.arb`
**Action:** CREATE

```json
{
  "@@locale": "th",

  "appName": "Miro Cal",
  
  "save": "บันทึก",
  "cancel": "ยกเลิก",
  "delete": "ลบ",
  "edit": "แก้ไข",
  "search": "ค้นหา",
  "loading": "กำลังโหลด...",
  "error": "เกิดข้อผิดพลาด",
  "confirm": "ยืนยัน",
  "close": "ปิด",
  "done": "เสร็จ",
  "next": "ถัดไป",
  "skip": "ข้าม",
  "retry": "ลองใหม่",
  "ok": "ตกลง",

  "foodName": "ชื่ออาหาร",
  "calories": "แคลอรี่",
  "protein": "โปรตีน",
  "carbs": "คาร์บ",
  "fat": "ไขมัน",
  "servingSize": "ปริมาณ",
  "servingUnit": "หน่วย",
  "kcal": "kcal",

  "mealBreakfast": "เช้า",
  "mealLunch": "กลางวัน",
  "mealDinner": "เย็น",
  "mealSnack": "ของว่าง",

  "todaySummary": "สรุปวันนี้",
  "dateSummary": "สรุป {date}",
  "@dateSummary": { "placeholders": { "date": { "type": "String" } } },

  "savedSuccess": "บันทึกเรียบร้อย",
  "deletedSuccess": "ลบเรียบร้อย",
  "pleaseEnterFoodName": "กรุณากรอกชื่ออาหาร",
  "noDataYet": "ยังไม่มีข้อมูล",
  "addFood": "เพิ่มอาหาร",
  "editFood": "แก้ไขอาหาร",
  "deleteFood": "ลบอาหาร",
  "deleteConfirm": "ยืนยันการลบ?",
  "foodLoggedSuccess": "บันทึกอาหารแล้ว!",

  "noApiKey": "กรุณาตั้งค่า Gemini API Key",
  "noApiKeyDescription": "ไปที่ โปรไฟล์ → API Settings เพื่อตั้งค่า",
  "apiKeyTitle": "ตั้งค่า Gemini API Key",
  "apiKeyRequired": "ต้องการ API Key",
  "apiKeyFreeNote": "Gemini API ใช้ฟรี ไม่ต้องจ่ายเงิน",
  "apiKeySetup": "ตั้งค่า API Key",
  "testConnection": "ทดสอบการเชื่อมต่อ",
  "connectionSuccess": "เชื่อมต่อสำเร็จ! พร้อมใช้งาน",
  "connectionFailed": "เชื่อมต่อไม่สำเร็จ",
  "pasteKey": "วาง",
  "deleteKey": "ลบ API Key",
  "openAiStudio": "เปิด Google AI Studio",

  "chatHint": "สั่ง Miro เช่น \"บันทึกข้าวผัด\"...",
  "chatFoodSaved": "บันทึกอาหารแล้ว!",
  "chatFoodSavedDetail": "{name} {serving} {unit}\n{cal} kcal",
  "@chatFoodSavedDetail": { "placeholders": { "name": {"type":"String"}, "serving": {"type":"String"}, "unit": {"type":"String"}, "cal": {"type":"String"} } },
  "featureNotAvailable": "ขออภัย ฟังก์ชันนี้ยังไม่พร้อมในเวอร์ชันนี้",

  "goalCalories": "แคลอรี่/วัน",
  "goalProtein": "โปรตีน/วัน",
  "goalCarbs": "คาร์บ/วัน",
  "goalFat": "ไขมัน/วัน",
  "goalWater": "น้ำ/วัน",
  "healthGoals": "เป้าหมายสุขภาพ",

  "profile": "โปรไฟล์",
  "settings": "การตั้งค่า",
  "privacyPolicy": "นโยบายความเป็นส่วนตัว",
  "termsOfService": "เงื่อนไขการใช้งาน",
  "clearAllData": "ล้างข้อมูลทั้งหมด",
  "clearAllDataConfirm": "ข้อมูลทั้งหมดจะถูกลบ ลบแล้วกู้คืนไม่ได้!",
  "about": "เกี่ยวกับแอป",
  "language": "ภาษา",

  "upgradePro": "อัปเกรด Pro",
  "proUnlocked": "Miro Cal Pro",
  "proDescription": "ใช้ AI วิเคราะห์อาหารไม่จำกัด",
  "aiRemaining": "AI วิเคราะห์: เหลือ {remaining}/{total} ครั้งวันนี้",
  "@aiRemaining": { "placeholders": { "remaining": {"type":"int"}, "total": {"type":"int"} } },
  "aiLimitReached": "ใช้ AI ครบ 3 ครั้งแล้ววันนี้",
  "restorePurchase": "กู้คืนการซื้อ",

  "myMeals": "เมนูของฉัน",
  "createMeal": "สร้างเมนู",
  "ingredients": "วัตถุดิบ",
  "addIngredient": "เพิ่มวัตถุดิบ",
  "searchFood": "ค้นหาอาหาร",

  "analyzing": "กำลังวิเคราะห์...",
  "analyzeWithAi": "วิเคราะห์ด้วย AI",
  "analysisComplete": "วิเคราะห์เสร็จ",

  "timeline": "Timeline",
  "diet": "Diet",
  "quickAdd": "Quick Add",

  "welcomeTitle": "Miro Cal",
  "welcomeSubtitle": "บันทึกอาหารง่ายๆ ด้วย AI",
  "onboardingFeature1": "ถ่ายรูปอาหาร",
  "onboardingFeature1Desc": "AI วิเคราะห์ kcal อัตโนมัติ",
  "onboardingFeature2": "พิมพ์แชท",
  "onboardingFeature2Desc": "บอกว่า \"กินข้าวผัด\" → บันทึกให้เลย",
  "onboardingFeature3": "สรุปทุกวัน",
  "onboardingFeature3Desc": "ดู kcal, โปรตีน, คาร์บ, ไขมัน",
  "basicInfo": "ข้อมูลพื้นฐาน",
  "basicInfoDesc": "เพื่อคำนวณเป้าหมายแคลอรี่ที่เหมาะกับคุณ",
  "gender": "เพศ",
  "male": "ชาย",
  "female": "หญิง",
  "age": "อายุ",
  "weight": "น้ำหนัก",
  "height": "ส่วนสูง",
  "activityLevel": "ระดับกิจกรรม",
  "tdeeResult": "TDEE ของคุณ: {kcal} kcal/วัน",
  "@tdeeResult": { "placeholders": { "kcal": {"type":"int"} } },
  "setupAiTitle": "ตั้งค่า Gemini AI",
  "setupAiDesc": "ถ่ายรูปอาหาร → AI วิเคราะห์ให้อัตโนมัติ",
  "setupNow": "ตั้งค่าเลย",
  "skipForNow": "ข้ามไปก่อน → เข้าแอป",

  "errorTimeout": "หมดเวลาเชื่อมต่อ — ลองใหม่อีกครั้ง",
  "errorInvalidKey": "API Key ไม่ถูกต้อง — ตรวจสอบการตั้งค่า",
  "errorNoInternet": "ไม่มีอินเทอร์เน็ต — ตรวจสอบการเชื่อมต่อ",
  "errorGeneral": "เกิดข้อผิดพลาด — ลองใหม่อีกครั้ง",
  "errorQuotaExceeded": "ใช้ API เกินโควต้า — รอสักครู่แล้วลองใหม่"
}
```

**ไฟล์:** `lib/l10n/app_en.arb`
**Action:** CREATE

```json
{
  "@@locale": "en",

  "appName": "Miro Cal",
  
  "save": "Save",
  "cancel": "Cancel",
  "delete": "Delete",
  "edit": "Edit",
  "search": "Search",
  "loading": "Loading...",
  "error": "An error occurred",
  "confirm": "Confirm",
  "close": "Close",
  "done": "Done",
  "next": "Next",
  "skip": "Skip",
  "retry": "Retry",
  "ok": "OK",

  "foodName": "Food name",
  "calories": "Calories",
  "protein": "Protein",
  "carbs": "Carbs",
  "fat": "Fat",
  "servingSize": "Serving size",
  "servingUnit": "Unit",
  "kcal": "kcal",

  "mealBreakfast": "Breakfast",
  "mealLunch": "Lunch",
  "mealDinner": "Dinner",
  "mealSnack": "Snack",

  "todaySummary": "Today's Summary",
  "dateSummary": "Summary for {date}",

  "savedSuccess": "Saved successfully",
  "deletedSuccess": "Deleted successfully",
  "pleaseEnterFoodName": "Please enter food name",
  "noDataYet": "No data yet",
  "addFood": "Add food",
  "editFood": "Edit food",
  "deleteFood": "Delete food",
  "deleteConfirm": "Confirm delete?",
  "foodLoggedSuccess": "Food logged!",

  "noApiKey": "Please set up Gemini API Key",
  "noApiKeyDescription": "Go to Profile → API Settings to set up",
  "apiKeyTitle": "Set up Gemini API Key",
  "apiKeyRequired": "API Key required",
  "apiKeyFreeNote": "Gemini API is free to use",
  "apiKeySetup": "Set up API Key",
  "testConnection": "Test connection",
  "connectionSuccess": "Connected successfully! Ready to use",
  "connectionFailed": "Connection failed",
  "pasteKey": "Paste",
  "deleteKey": "Delete API Key",
  "openAiStudio": "Open Google AI Studio",

  "chatHint": "Tell Miro e.g. \"Log fried rice\"...",
  "chatFoodSaved": "Food logged!",
  "chatFoodSavedDetail": "{name} {serving} {unit}\n{cal} kcal",
  "featureNotAvailable": "Sorry, this feature is not available yet",

  "goalCalories": "Calories/day",
  "goalProtein": "Protein/day",
  "goalCarbs": "Carbs/day",
  "goalFat": "Fat/day",
  "goalWater": "Water/day",
  "healthGoals": "Health Goals",

  "profile": "Profile",
  "settings": "Settings",
  "privacyPolicy": "Privacy Policy",
  "termsOfService": "Terms of Service",
  "clearAllData": "Clear all data",
  "clearAllDataConfirm": "All data will be deleted. This cannot be undone!",
  "about": "About",
  "language": "Language",

  "upgradePro": "Upgrade to Pro",
  "proUnlocked": "Miro Cal Pro",
  "proDescription": "Unlimited AI food analysis",
  "aiRemaining": "AI analysis: {remaining}/{total} remaining today",
  "aiLimitReached": "AI limit reached for today (3/3)",
  "restorePurchase": "Restore purchase",

  "myMeals": "My Meals",
  "createMeal": "Create meal",
  "ingredients": "Ingredients",
  "addIngredient": "Add ingredient",
  "searchFood": "Search food",

  "analyzing": "Analyzing...",
  "analyzeWithAi": "Analyze with AI",
  "analysisComplete": "Analysis complete",

  "timeline": "Timeline",
  "diet": "Diet",
  "quickAdd": "Quick Add",

  "welcomeTitle": "Miro Cal",
  "welcomeSubtitle": "Easy food logging with AI",
  "onboardingFeature1": "Snap a photo",
  "onboardingFeature1Desc": "AI calculates calories automatically",
  "onboardingFeature2": "Type to log",
  "onboardingFeature2Desc": "Say \"had fried rice\" and it's logged",
  "onboardingFeature3": "Daily summary",
  "onboardingFeature3Desc": "Track kcal, protein, carbs, fat",
  "basicInfo": "Basic Info",
  "basicInfoDesc": "To calculate your recommended daily calories",
  "gender": "Gender",
  "male": "Male",
  "female": "Female",
  "age": "Age",
  "weight": "Weight",
  "height": "Height",
  "activityLevel": "Activity Level",
  "tdeeResult": "Your TDEE: {kcal} kcal/day",
  "setupAiTitle": "Set up Gemini AI",
  "setupAiDesc": "Snap a photo and AI analyzes it automatically",
  "setupNow": "Set up now",
  "skipForNow": "Skip for now",

  "errorTimeout": "Connection timeout — please try again",
  "errorInvalidKey": "Invalid API Key — check your settings",
  "errorNoInternet": "No internet connection",
  "errorGeneral": "An error occurred — please try again",
  "errorQuotaExceeded": "API quota exceeded — please wait and retry"
}
```

> **หมายเหตุ:** นี่คือ keys หลักๆ ~120 keys
> ในการทำจริง จะมีอีก ~430 keys ที่ต้องเพิ่มเมื่อแปลงแต่ละไฟล์
> **เมื่อเจอ string ใหม่ → เพิ่ม key ในทั้ง 2 ARB files**

---

### Step 2: แก้ MaterialApp — เปิด Localization

**ไฟล์:** `lib/main.dart`
**Action:** EDIT

```dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ใน MaterialApp:
MaterialApp(
  // ... เดิม ...

  // === เพิ่ม Localization ===
  localizationsDelegates: const [
    L10n.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: const [
    Locale('th'),  // ไทย
    Locale('en'),  // อังกฤษ
  ],
  locale: _userLocale,  // อ่านจาก UserProfile หรือ system
  // === จบ Localization ===
)
```

#### Locale Provider

เพิ่ม Riverpod provider สำหรับ locale:

```dart
// lib/features/profile/providers/locale_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeProvider = StateProvider<Locale?>((ref) => null);
// null = ใช้ภาษาของระบบ
// Locale('th') = บังคับไทย
// Locale('en') = บังคับอังกฤษ
```

---

### Step 3: Generate Localization Code

รันคำสั่ง:
```bash
flutter gen-l10n
```

หรือ:
```bash
flutter pub get  # จะ auto-generate ถ้า `generate: true`
```

**ผลลัพธ์:** สร้าง `.dart_tool/flutter_gen/gen_l10n/` ที่มี:
- `app_localizations.dart`
- `app_localizations_th.dart`
- `app_localizations_en.dart`

---

### Step 4: แปลง Strings — ทำทีละไฟล์

#### วิธีแปลง (ทำซ้ำทุกไฟล์)

**ก่อน:**
```dart
const Text('กรุณากรอกชื่ออาหาร')
```

**หลัง:**
```dart
Text(L10n.of(context)!.pleaseEnterFoodName)
```

**Import ที่ต้องเพิ่มทุกไฟล์:**
```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
```

**Shortcut (optional):**
```dart
// เพิ่มที่ต้น build() เพื่อพิมพ์น้อยลง
final l10n = L10n.of(context)!;

// แล้วใช้
Text(l10n.pleaseEnterFoodName)
```

#### ลำดับไฟล์ที่แนะนำ (เรียงจากง่าย → ยาก)

1. `api_key_screen.dart` (~13 strings) — **เริ่มที่นี่ เพื่อฝึกก่อน**
2. `health_goals_screen.dart` (~11 strings)
3. `food_detail_bottom_sheet.dart` (~18 strings)
4. `create_meal_sheet.dart` (~30 strings)
5. `health_timeline_tab.dart` (~31 strings)
6. `health_diet_tab.dart` (~39 strings)
7. `food_preview_screen.dart` (~63 strings)
8. `intent_handler.dart` (~75 strings)
9. `gemini_analysis_sheet.dart` (~76 strings)
10. `edit_food_bottom_sheet.dart` (~76 strings)
11. อื่นๆ (~20 ไฟล์) (~100 strings)

> **สำคัญ:** เมื่อเจอ string ที่ยังไม่มี key → เพิ่มใน **ทั้ง 2 ARB files** ก่อนใช้

---

### Step 5: Gemini Prompts — Dynamic ตาม Locale

**ไฟล์:** `lib/core/ai/gemini_service.dart`
**Action:** EDIT

**สำคัญ:** Gemini prompts ไม่ใช้ L10n (เพราะไม่มี BuildContext)
→ ใช้ locale string parameter แทน

```dart
/// สร้าง prompt สำหรับวิเคราะห์อาหาร (ภาษาเปลี่ยนตาม locale)
static String getAnalysisPrompt(String locale) {
  if (locale == 'th') {
    return '''คุณเป็น AI ที่เชี่ยวชาญด้านโภชนาการอาหารไทยและนานาชาติ
วิเคราะห์รูปอาหารนี้แล้วตอบเป็น JSON format:
{
  "food_name": "ชื่ออาหาร",
  "ingredients": [...],
  "total_calories": ...,
  "total_protein": ...,
  "total_carbs": ...,
  "total_fat": ...,
  "serving_size": ...,
  "serving_unit": "..."
}''';
  }

  // English (default)
  return '''You are a nutrition expert AI.
Analyze this food image and respond in JSON format:
{
  "food_name": "food name",
  "ingredients": [...],
  "total_calories": ...,
  "total_protein": ...,
  "total_carbs": ...,
  "total_fat": ...,
  "serving_size": ...,
  "serving_unit": "..."
}''';
}
```

> **JSON response format เหมือนกัน** ทุกภาษา → ต่าง key `food_name` ที่เป็นภาษานั้นๆ

---

### Step 6: เพิ่ม Language Switcher ใน Settings

**ไฟล์:** `lib/features/profile/presentation/profile_screen.dart`
**Action:** EDIT

```dart
ListTile(
  leading: const Icon(Icons.language),
  title: Text(L10n.of(context)!.language),
  subtitle: Text(_currentLanguageName()),
  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
  onTap: () => _showLanguagePicker(),
),
```

```dart
void _showLanguagePicker() {
  showDialog(
    context: context,
    builder: (ctx) => SimpleDialog(
      title: Text(L10n.of(context)!.language),
      children: [
        SimpleDialogOption(
          onPressed: () {
            ref.read(localeProvider.notifier).state = null; // system
            Navigator.pop(ctx);
          },
          child: const Text('ระบบ (System)'),
        ),
        SimpleDialogOption(
          onPressed: () {
            ref.read(localeProvider.notifier).state = const Locale('th');
            Navigator.pop(ctx);
          },
          child: const Text('ไทย'),
        ),
        SimpleDialogOption(
          onPressed: () {
            ref.read(localeProvider.notifier).state = const Locale('en');
            Navigator.pop(ctx);
          },
          child: const Text('English'),
        ),
      ],
    ),
  );
}
```

---

## ✅ Checklist

- [ ] `flutter gen-l10n` รันสำเร็จ ไม่มี error
- [ ] เปลี่ยนภาษาเป็น English → UI เปลี่ยนเป็นภาษาอังกฤษ
- [ ] เปลี่ยนภาษาเป็น Thai → UI กลับเป็นภาษาไทย
- [ ] Gemini วิเคราะห์อาหาร (EN) → ชื่ออาหารเป็นภาษาอังกฤษ
- [ ] Gemini วิเคราะห์อาหาร (TH) → ชื่ออาหารเป็นภาษาไทย
- [ ] ไม่มี hardcoded Thai strings เหลือ (Search `'` ในโค้ด)
- [ ] Error messages แปลตาม locale
- [ ] Settings → Language Switcher ทำงาน

---

## 🎉 เสร็จแล้ว! ไปต่อ Step 39 →

ไปทำ **Step 39: Global Food Database + Search** ได้เลย
