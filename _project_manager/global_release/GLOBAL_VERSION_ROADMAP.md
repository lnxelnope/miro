# Miro Global Version Roadmap — จาก Thai → International

> **เป้าหมาย:** ทำให้แอปรองรับภาษาอังกฤษ (และภาษาอื่น) เพื่อขายทั่วโลก
> **จุดแข็ง:** ใช้ง่าย, Learning curve ต่ำ, ฐานข้อมูลวัตถุดิบโตขึ้นเองจากการใช้งาน (Network effect ส่วนตัว)
> **ข้อได้เปรียบ:** Gemini AI รู้จักอาหารทุกประเทศอยู่แล้ว — ไม่ต้องสร้าง DB ใหม่

---

## สถานะปัจจุบัน — สิ่งที่ต้องเปลี่ยน

### ภาษาไทย Hard-coded ทั่วโปรเจค

| หมวด | จำนวน Thai strings โดยประมาณ | ตัวอย่าง |
|------|-----|---------|
| Health widgets (UI labels, buttons, messages) | ~400+ | 'กรุณากรอกชื่ออาหาร', 'บันทึกเรียบร้อย' |
| Chat intent handler (AI responses) | ~75 | 'บันทึกอาหารแล้ว!', 'ลองใหม่อีกครั้งนะครับ' |
| Gemini prompts | ~16 | 'คุณเป็น AI ที่เชี่ยวชาญด้านโภชนาการอาหารไทย' |
| Profile/Settings | ~55 | 'โปรไฟล์ & การตั้งค่า' |
| Other features (finance, tasks, etc.) | ~400+ | ซ่อนอยู่แล้วใน v1.0 |
| **รวม (เฉพาะ food logging v1.0)** | **~550+ strings** | |

### สิ่งที่ภาษา-independent อยู่แล้ว (ไม่ต้องแก้)
- Gemini AI → รู้จักอาหารทุกชาติทุกภาษาอยู่แล้ว
- Isar Database → เก็บข้อมูลทุกภาษาได้
- Nutrition calculation → ตัวเลข universal
- UI layout → Material Design รองรับทุกภาษา
- food_names.json → มี field `en` อยู่แล้ว (ชื่ออังกฤษ)

---

## แนวทาง 2 ทาง (เลือก 1)

### ทางที่ 1: Localization (i18n) — แนะนำ
**แอปเดียว รองรับหลายภาษา** ผู้ใช้เลือกภาษาได้

- ใช้ Flutter `intl` + ARB files
- String ทุกจุดอ้าง key → แสดงตามภาษาที่เลือก
- เพิ่มภาษาได้ง่าย (เพิ่ม ARB file ทีละภาษา)

**ข้อดี:** maintain แอปเดียว, ผู้ใช้ไทยก็ใช้ได้
**ข้อเสีย:** ต้องแก้ไฟล์เยอะ (~550+ strings, ~30+ ไฟล์)

### ทางที่ 2: แยก Build — Thai + English
**2 แอปแยกกัน** (คนละ listing บน Play Store)

- Fork codebase → แก้ภาษาตรงๆ
- แต่ละ build มีภาษาเดียว

**ข้อดี:** ทำเร็ว, ไม่ต้องเรียนรู้ i18n
**ข้อเสีย:** maintain 2 codebase (nightmare ระยะยาว), ผู้ใช้ต้องเลือกตอนโหลด

### **แนะนำ: ทางที่ 1 (Localization)** — ลงทุนครั้งเดียว ใช้ได้ตลอด

---

## Phase 1 — ตั้ง Localization Framework (~1 วัน)

### 1.1 เปิดใช้ Flutter Localization

**ไฟล์:** `pubspec.yaml`

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0   # มีอยู่แล้ว

flutter:
  generate: true  # เปิด code generation
```

**สร้างไฟล์:** `l10n.yaml` (ราก project)

```yaml
arb-dir: lib/l10n
template-arb-file: app_th.arb
output-localization-file: app_localizations.dart
output-class: L10n
```

### 1.2 สร้าง ARB Files

**สร้าง:** `lib/l10n/app_th.arb` (ภาษาไทย — ต้นฉบับ)
**สร้าง:** `lib/l10n/app_en.arb` (ภาษาอังกฤษ)

ตัวอย่าง structure:

```json
// app_th.arb
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
  
  "foodName": "ชื่ออาหาร",
  "calories": "แคลอรี่",
  "protein": "โปรตีน",
  "carbs": "คาร์บ",
  "fat": "ไขมัน",
  "servingSize": "ปริมาณ",
  "servingUnit": "หน่วย",
  
  "mealBreakfast": "เช้า",
  "mealLunch": "กลางวัน", 
  "mealDinner": "เย็น",
  "mealSnack": "ของว่าง",
  
  "todaySummary": "สรุปวันนี้",
  "dateSummary": "สรุป {date}",
  "@dateSummary": { "placeholders": { "date": {} } },
  
  "savedSuccess": "บันทึกเรียบร้อย",
  "deletedSuccess": "ลบเรียบร้อย",
  "pleaseEnterFoodName": "กรุณากรอกชื่ออาหาร",
  "noApiKey": "กรุณาตั้งค่า Gemini API Key",
  "noApiKeyDescription": "ไปที่ โปรไฟล์ → API Settings เพื่อตั้งค่า",
  
  "chatHint": "สั่ง Miro เช่น \"บันทึกข้าวผัด\"...",
  "chatFoodSaved": "บันทึกอาหารแล้ว!",
  "chatFoodSavedDetail": "{name} {serving} {unit}\n{cal} kcal",
  "@chatFoodSavedDetail": { "placeholders": { "name": {}, "serving": {}, "unit": {}, "cal": {} } },
  
  "apiKeyTitle": "ตั้งค่า Gemini API Key",
  "apiKeyStep1": "เปิด Google AI Studio",
  "apiKeyStep2": "ล็อกอิน Google Account",
  "apiKeyStep3": "คลิก Create API Key",
  "apiKeyStep4": "คัดลอก Key",
  "apiKeyStep5": "วางในแอป → บันทึก",
  "apiKeyFreeNote": "Gemini API ใช้ฟรี ไม่ต้องจ่ายเงิน",
  
  "goalCalories": "แคลอรี่/วัน",
  "goalProtein": "โปรตีน/วัน",
  "goalCarbs": "คาร์บ/วัน",
  "goalFat": "ไขมัน/วัน",
  "goalWater": "น้ำ/วัน"
}
```

```json
// app_en.arb
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
  
  "foodName": "Food name",
  "calories": "Calories",
  "protein": "Protein",
  "carbs": "Carbs",
  "fat": "Fat",
  "servingSize": "Serving size",
  "servingUnit": "Unit",
  
  "mealBreakfast": "Breakfast",
  "mealLunch": "Lunch",
  "mealDinner": "Dinner",
  "mealSnack": "Snack",
  
  "todaySummary": "Today's Summary",
  "dateSummary": "Summary for {date}",
  
  "savedSuccess": "Saved successfully",
  "deletedSuccess": "Deleted successfully",
  "pleaseEnterFoodName": "Please enter food name",
  "noApiKey": "Please set up Gemini API Key",
  "noApiKeyDescription": "Go to Profile → API Settings to set up",
  
  "chatHint": "Tell Miro e.g. \"Log fried rice\"...",
  "chatFoodSaved": "Food logged!",
  "chatFoodSavedDetail": "{name} {serving} {unit}\n{cal} kcal",
  
  "apiKeyTitle": "Set up Gemini API Key",
  "apiKeyStep1": "Open Google AI Studio",
  "apiKeyStep2": "Sign in with Google",
  "apiKeyStep3": "Click Create API Key",
  "apiKeyStep4": "Copy the Key",
  "apiKeyStep5": "Paste in app → Save",
  "apiKeyFreeNote": "Gemini API is free to use",
  
  "goalCalories": "Calories/day",
  "goalProtein": "Protein/day",
  "goalCarbs": "Carbs/day",
  "goalFat": "Fat/day",
  "goalWater": "Water/day"
}
```

### 1.3 แก้ MaterialApp

**ไฟล์:** `lib/main.dart`

```dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

MaterialApp(
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
  locale: _userLocale, // จาก UserProfile หรือ system
)
```

---

## Phase 2 — แปลง Hard-coded Strings (~3-5 วัน)

### วิธีทำ (ทำทีละไฟล์)

**ก่อน:**
```dart
const Text('กรุณากรอกชื่ออาหาร')
```

**หลัง:**
```dart
Text(L10n.of(context)!.pleaseEnterFoodName)
```

### ไฟล์ที่ต้องแก้ (เรียงตามปริมาณงาน)

| Priority | ไฟล์ | Thai strings | ความยาก |
|----------|------|-------------|---------|
| 1 | `edit_food_bottom_sheet.dart` | ~76 | สูง |
| 2 | `gemini_analysis_sheet.dart` | ~76 | สูง |
| 3 | `intent_handler.dart` | ~75 | ปานกลาง |
| 4 | `food_preview_screen.dart` | ~63 | สูง |
| 5 | `health_diet_tab.dart` | ~39 | ปานกลาง |
| 6 | `health_timeline_tab.dart` | ~31 | ปานกลาง |
| 7 | `create_meal_sheet.dart` | ~30 | ปานกลาง |
| 8 | `food_detail_bottom_sheet.dart` | ~18 | ต่ำ |
| 9 | `gemini_service.dart` (prompts) | ~16 | **พิเศษ** |
| 10 | `api_key_screen.dart` | ~13 | ต่ำ |
| 11 | `health_goals_screen.dart` | ~11 | ต่ำ |
| 12 | อื่นๆ (~20 ไฟล์) | ~100 | ต่ำ |
| **รวม** | **~30 ไฟล์** | **~550** | |

### หมายเหตุพิเศษ: Gemini Prompts

**ไฟล์:** `lib/core/ai/gemini_service.dart`

Prompt ปัจจุบัน:
```
คุณเป็น AI ที่เชี่ยวชาญด้านโภชนาการอาหารไทยและนานาชาติ
```

**ต้องเปลี่ยนเป็น dynamic ตาม locale:**
- ภาษาไทย: prompt ภาษาไทย → response ภาษาไทย
- English: prompt ภาษาอังกฤษ → response ภาษาอังกฤษ

```dart
static String _getAnalysisPrompt(String locale) {
  if (locale == 'th') {
    return 'คุณเป็น AI ที่เชี่ยวชาญด้านโภชนาการ...';
  }
  return 'You are a nutrition expert AI. Analyze this food image...';
}
```

**JSON response format เหมือนกัน** ทุกภาษา (เปลี่ยนแค่ food_name field)

---

## Phase 3 — ปรับ Food Database + Search (~1 วัน)

### 3.1 food_names.json — มี English อยู่แล้ว!

```json
{ "th": "ข้าวผัด", "en": "Fried Rice", "cal": null, "src": "thai" }
```

→ **ไม่ต้องสร้าง DB ใหม่** แค่ใช้ `en` field เมื่อ locale = en

### 3.2 Thai Food Database — เพิ่ม English keys

**ไฟล์:** `lib/core/data/thai_food_database.dart`

เพิ่ม English aliases:
```dart
'fried rice': const FoodNutritionData(calories: 450, ...),
'chicken rice': const FoodNutritionData(calories: 550, ...),
```

หรือดีกว่า → สร้าง Map แยก `_englishFoods` + method `lookup(name, locale)`

### 3.3 LLM Service — Thai Normalizer

**ไฟล์:** `lib/core/ai/llm_service.dart`

`_normalizeThaiFood()` ทำงานกับภาษาไทยเท่านั้น
→ เพิ่ม `_normalizeEnglishFood()` สำหรับ English
→ หรือทำ generic normalizer ที่ดูจาก locale

### 3.4 Search — รองรับทั้ง 2 ภาษา

ผู้ใช้ไทยค้น "ข้าวผัด" → เจอ
ผู้ใช้ EN ค้น "fried rice" → เจอเหมือนกัน

→ ค้นทั้ง `th` และ `en` field เสมอ (ไม่ว่า locale จะเป็นอะไร)

---

## Phase 4 — ปรับ Chat Intent สำหรับ English (~1 วัน)

### 4.1 Intent Classification

**ไฟล์:** `lib/core/ai/llm_service.dart`

ปัจจุบัน classify จาก keyword ภาษาไทย:
```dart
if (text.contains('กิน') || text.contains('ทาน')) → food
```

เพิ่ม English:
```dart
if (text.contains('ate') || text.contains('eat') || text.contains('had')) → food
```

### 4.2 Food Name Extraction

ปัจจุบัน:
```dart
.replaceAll(RegExp(r'\s*(ครับ|ค่ะ|คะ|นะ|จ้า)\s*$'), '')
```

เพิ่ม English particles:
```dart
.replaceAll(RegExp(r'\s*(please|thanks|today|for lunch|for dinner)\s*$', caseSensitive: false), '')
```

### 4.3 Unit Mapping

ปัจจุบัน: `'cup' → 'ถ้วย'`, `'piece' → 'ชิ้น'`
→ ถ้า locale = en → ไม่ต้องแปลง ใช้ English units เลย

---

## Phase 5 — ปรับ Units + Formatting (~ครึ่งวัน)

### 5.1 หน่วย Serving

| ไทย | English |
|-----|---------|
| จาน | plate/serving |
| ถ้วย | cup |
| ชิ้น | piece |
| แก้ว | glass |
| ชาม | bowl |
| ฟอง | egg |
| ไม้ | stick |
| กล่อง | box |
| ห่อ | pack |

→ สร้าง `UnitLocalizer` class ที่แปลง unit ตาม locale

### 5.2 Date Formatting

ปัจจุบัน: `DateFormat('d MMM', 'th')` → "7 ก.พ."
English: `DateFormat('MMM d', 'en')` → "Feb 7"

→ ใช้ `DateFormat.yMMMd(locale)` แทน hardcode

### 5.3 Meal Type Labels

ปัจจุบัน hardcode: `'มื้อเช้า'`, `'มื้อกลางวัน'`, `'มื้อเย็น'`
→ ใช้ L10n keys: `L10n.of(context)!.mealBreakfast`

---

## Phase 6 — Store Listing & Pricing (~ครึ่งวัน)

### 6.1 Play Store Listing (English)

```
Title: Miro Cal — AI Food Logger & Calorie Counter

Short description:
Snap a photo of your food and AI instantly logs calories, protein, carbs & fat.

Full description:
📸 Take a photo → AI analyzes your meal automatically!
No searching, no manual entry. Just snap and log.

Features:
• Photo → AI calorie analysis (powered by Gemini)
• Chat logging: just type "had pizza for lunch"
• Quick Add — one-tap logging for favorites
• Custom meals — save your recipes for reuse
• Daily kcal / macro tracking
• Set calorie & macro goals
• Growing ingredient database — learns from your usage!

🔒 Your data stays on your device (offline-first)
🔑 Uses your own free Gemini API key (guide included)
```

### 6.2 Pricing Strategy

| Market | ราคา | เหตุผล |
|--------|------|--------|
| ไทย | 199-299 THB | ตลาดไทย, กำลังซื้อ |
| Global (USD) | $2.99-4.99 | เทียบ MyFitnessPal Premium $79.99/year → ขายขาดถูกกว่ามาก |
| Japan (JPY) | ¥490-700 | ตลาด health-conscious ใหญ่ |
| Southeast Asia | $1.99-2.99 | กำลังซื้อใกล้เคียงไทย |

**จุดขาย vs คู่แข่ง:**
| | Miro Cal | MyFitnessPal | Lose It! |
|---|---------|-------------|----------|
| ราคา | $3-5 ขายขาด | $80/ปี | $40/ปี |
| AI วิเคราะห์รูป | Gemini (ฟรี BYOK) | ต้อง Premium | ต้อง Premium |
| Offline | 100% | ต้อง online | ต้อง online |
| Privacy | ข้อมูลในเครื่อง | เก็บบน cloud | เก็บบน cloud |
| DB โตเอง | ใช่ | ไม่ | ไม่ |

---

## Phase 7 — ภาษาเพิ่มเติม (อนาคต)

เมื่อ framework i18n พร้อมแล้ว → เพิ่มภาษาใหม่ง่ายมาก:

**แค่สร้าง ARB file ใหม่:**

```
lib/l10n/
  app_th.arb    ← ไทย (มีอยู่แล้ว)
  app_en.arb    ← อังกฤษ (มีอยู่แล้ว)
  app_ja.arb    ← ญี่ปุ่น (เพิ่ม)
  app_zh.arb    ← จีน (เพิ่ม)
  app_ko.arb    ← เกาหลี (เพิ่ม)
```

**ภาษาที่ควรทำก่อน (ตลาดใหญ่ + health-conscious):**
1. English (Global)
2. Japanese (ตลาด health app ใหญ่มาก)
3. Chinese Simplified (ประชากรเยอะ)
4. Korean (ตลาด K-health trend)
5. Spanish (ตลาด LatAm + Spain)

**Tip:** ใช้ AI (ChatGPT/Gemini) ช่วยแปล ARB file ได้เลย — เร็วมาก

---

## Timeline ประมาณการ

| Phase | งาน | เวลา |
|-------|------|------|
| 1 | ตั้ง Localization framework | 1 วัน |
| 2 | แปลง strings (~550 จุด, 30 ไฟล์) | 3-5 วัน |
| 3 | ปรับ Food DB + Search | 1 วัน |
| 4 | ปรับ Chat Intent สำหรับ EN | 1 วัน |
| 5 | Units + Formatting | ครึ่งวัน |
| 6 | Store Listing EN | ครึ่งวัน |
| **รวม** | | **~7-9 วันทำงาน** |

**แนะนำ:** ทำหลัง v1.0 Thai launch เสร็จ + ได้ feedback แล้ว

---

## เส้นทางแนะนำ

```
v1.0 (Thai) ─── launch เร็วที่สุด ─── เก็บ feedback + bug fix
       │
       ▼
v1.1 (Thai) ─── แก้ bug + ปรับ UX ตาม feedback
       │
       ▼
v2.0 (Thai + EN) ─── Global launch ─── ขายทั่วโลก
       │
       ▼
v2.1+ ─── เพิ่มภาษา (JA, ZH, KO, ES) ─── ตาม demand
       │
       ▼
v3.0 ─── เปิด Finance + Tasks กลับมา ─── เป็น "Life Assistant" เต็มรูปแบบ
```

---

## Killer Feature สำหรับ Global: Self-Growing Database

จุดขายที่แตกต่างจากคู่แข่ง:

```
ผู้ใช้ถ่ายรูปอาหาร
    → Gemini วิเคราะห์ → ได้ ingredients + nutrition
    → บันทึกลง local Ingredient DB อัตโนมัติ
    → ครั้งต่อไปค้นเจอทันที ไม่ต้องรอ AI
    → DB ยิ่งใช้ยิ่งโต → ยิ่งเร็ว ยิ่งแม่น
    → ใช้ offline ได้เลย (หลังจาก AI เคยวิเคราะห์แล้ว)
```

**ทำงานทุกภาษา ทุกประเทศ** เพราะ:
- Gemini รู้จักอาหารทุกชาติ (ไทย, ญี่ปุ่น, อิตาลี, เม็กซิกัน...)
- DB เก็บทั้งชื่อ local + ชื่อ EN
- ผู้ใช้ญี่ปุ่นถ่ายราเม็ง → DB โตสำหรับอาหารญี่ปุ่น
- ผู้ใช้อิตาลีถ่ายพาสต้า → DB โตสำหรับอาหารอิตาลี
- **ไม่ต้องเตรียม food database แต่ละประเทศ!**

นี่คือข้อได้เปรียบที่คู่แข่งรายใหญ่ไม่มี — เพราะพวกเขาพึ่ง centralized database ที่ต้อง maintain เอง
