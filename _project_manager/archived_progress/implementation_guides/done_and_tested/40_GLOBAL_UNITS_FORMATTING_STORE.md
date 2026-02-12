# Step 40: Global Units, Formatting + English Store Listing

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 1 วัน
> **ความยาก:** ง่าย-ปานกลาง
> **ต้องทำก่อน:** Step 39 (Global Food DB + Search)

---

## 🎯 เป้าหมาย

1. **Unit Display ตาม Locale** — แสดงชื่อหน่วยตามภาษา
2. **Date Formatting** — ใช้ `DateFormat` ตาม locale (ไม่ hardcode)
3. **Meal Type Labels** — ใช้ L10n แทน hardcode
4. **English Store Listing** — เตรียมสำหรับ Play Store Global
5. **Pricing Strategy** — ราคาแต่ละตลาด

---

## 📂 ไฟล์ที่เกี่ยวข้อง

| ไฟล์ | Action | คำอธิบาย |
|------|--------|----------|
| `lib/core/utils/unit_converter.dart` | EDIT | เพิ่ม locale-aware display names |
| ทุกไฟล์ที่ใช้ `DateFormat` | EDIT | เปลี่ยนจาก hardcode เป็น locale-aware |
| ทุกไฟล์ที่ hardcode meal labels | EDIT | ใช้ L10n keys |

---

## 🔧 ขั้นตอนการทำงาน

### Step 1: Unit Display ตาม Locale

**ไฟล์:** `lib/core/utils/unit_converter.dart`
**Action:** EDIT

#### 1.1 เพิ่ม display name ตาม locale

```dart
class UnitConverter {
  // ... code เดิม ...

  /// ชื่อหน่วยที่แสดงให้ผู้ใช้เห็น — ตาม locale
  static final Map<String, Map<String, String>> _unitDisplayNames = {
    // key: unit key (English) → { locale: display name }
    'g':       {'th': 'กรัม',    'en': 'g'},
    'kg':      {'th': 'กก.',     'en': 'kg'},
    'lbs':     {'th': 'ปอนด์',   'en': 'lbs'},
    'oz':      {'th': 'ออนซ์',   'en': 'oz'},
    'ml':      {'th': 'มล.',     'en': 'ml'},
    'l':       {'th': 'ลิตร',    'en': 'L'},
    'cup':     {'th': 'ถ้วย',    'en': 'cup'},
    'tbsp':    {'th': 'ช้อนโต๊ะ', 'en': 'tbsp'},
    'tsp':     {'th': 'ช้อนชา',  'en': 'tsp'},
    'fl oz':   {'th': 'ฟลูอิดออนซ์', 'en': 'fl oz'},
    'serving': {'th': 'เสิร์ฟ',  'en': 'serving'},
    'piece':   {'th': 'ชิ้น',    'en': 'piece'},
    'plate':   {'th': 'จาน',    'en': 'plate'},
    'bowl':    {'th': 'ชาม',    'en': 'bowl'},
    'glass':   {'th': 'แก้ว',    'en': 'glass'},
    'egg':     {'th': 'ฟอง',    'en': 'egg'},
    'ball':    {'th': 'ลูก',    'en': 'ball'},
    'stick':   {'th': 'ไม้',    'en': 'stick'},
    'box':     {'th': 'กล่อง',   'en': 'box'},
    'pack':    {'th': 'ห่อ',    'en': 'pack'},
    'slice':   {'th': 'ชิ้น',    'en': 'slice'},
    'can':     {'th': 'กระป๋อง', 'en': 'can'},
    'bottle':  {'th': 'ขวด',    'en': 'bottle'},
    'bag':     {'th': 'ถุง',    'en': 'bag'},
    'scoop':   {'th': 'สคูป',   'en': 'scoop'},
  };

  /// แสดงชื่อหน่วย ตาม locale
  static String displayUnit(String unitKey, String locale) {
    final names = _unitDisplayNames[unitKey];
    if (names == null) return unitKey; // ไม่เจอ → return key เดิม
    return names[locale] ?? names['en'] ?? unitKey;
  }

  /// Dropdown items — แสดงตาม locale
  static List<DropdownMenuItem<String>> dropdownItems(String locale) {
    return _unitDisplayNames.keys.map((key) {
      return DropdownMenuItem(
        value: key,
        child: Text(displayUnit(key, locale)),
      );
    }).toList();
  }
}
```

> **สำคัญ:** Unit **key** ยังเป็น English เสมอ (`g`, `kg`, `piece`, `plate`)
> เปลี่ยนแค่ **display name** ที่แสดงให้ผู้ใช้เห็น

---

### Step 2: Date Formatting ตาม Locale

#### 2.1 หาทุกจุดที่ใช้ DateFormat

Search ทั้งโปรเจค: `DateFormat(`

**ก่อน (hardcoded Thai):**
```dart
DateFormat('d MMM', 'th').format(date)      // "7 ก.พ."
DateFormat('d MMMM yyyy', 'th').format(date) // "7 กุมภาพันธ์ 2026"
DateFormat('HH:mm', 'th').format(date)       // "14:30"
```

**หลัง (locale-aware):**
```dart
// ดึง locale จาก context
final locale = Localizations.localeOf(context).languageCode;

DateFormat.MMMd(locale).format(date)         // TH: "7 ก.พ." / EN: "Feb 7"
DateFormat.yMMMd(locale).format(date)        // TH: "7 ก.พ. 2026" / EN: "Feb 7, 2026"
DateFormat.Hm(locale).format(date)           // "14:30" (เหมือนกันทุกภาษา)
```

#### 2.2 สร้าง helper (optional)

```dart
// lib/core/utils/date_helper.dart
import 'package:intl/intl.dart';

class DateHelper {
  static String shortDate(DateTime date, String locale) {
    return DateFormat.MMMd(locale).format(date);
  }

  static String fullDate(DateTime date, String locale) {
    return DateFormat.yMMMd(locale).format(date);
  }

  static String time(DateTime date, String locale) {
    return DateFormat.Hm(locale).format(date);
  }

  static String dayOfWeek(DateTime date, String locale) {
    return DateFormat.E(locale).format(date);
  }
}
```

---

### Step 3: Meal Type Labels — ใช้ L10n

#### 3.1 หาทุกจุดที่ hardcode meal labels

Search: `'มื้อเช้า'`, `'มื้อกลางวัน'`, `'มื้อเย็น'`, `'ของว่าง'`

**ก่อน:**
```dart
Text('มื้อเช้า')
Text('มื้อกลางวัน')
Text('มื้อเย็น')
Text('ของว่าง')
```

**หลัง:**
```dart
Text(L10n.of(context)!.mealBreakfast)
Text(L10n.of(context)!.mealLunch)
Text(L10n.of(context)!.mealDinner)
Text(L10n.of(context)!.mealSnack)
```

#### 3.2 Meal Type → Label mapping

ถ้ามี enum `MealType` → สร้าง extension:

```dart
extension MealTypeL10n on MealType {
  String label(BuildContext context) {
    final l10n = L10n.of(context)!;
    switch (this) {
      case MealType.breakfast: return l10n.mealBreakfast;
      case MealType.lunch: return l10n.mealLunch;
      case MealType.dinner: return l10n.mealDinner;
      case MealType.snack: return l10n.mealSnack;
    }
  }
}

// ใช้:
Text(entry.mealType.label(context))
```

---

### Step 4: English Store Listing

#### 4.1 อัพเดท Google Play Console — เพิ่มภาษาอังกฤษ

ไปที่ Play Console → Store presence → Store listing → Manage translations → **Add language: English**

#### 4.2 English Store Listing Content

| Field | English |
|-------|---------|
| **App name** | Miro Cal — AI Food Logger |
| **Short description** | Snap a photo of food → AI logs calories, protein, carbs & fat automatically |

**Full description (English):**

```
📸 Snap a photo → AI analyzes your meal instantly!
No searching, no manual entry. Just snap and log.

✨ Features:
• Photo → AI calorie analysis (powered by Gemini)
• Chat logging: type "had pizza for lunch" and it's logged
• Quick Add — one-tap logging for favorites
• Custom meals — save your recipes for reuse
• Daily kcal / macro tracking
• Set calorie & macro goals
• Growing ingredient database — learns from your usage!

💡 Free to use:
• Manual food logging — unlimited
• AI analysis — 3 times/day free
• Upgrade to Pro for unlimited AI (one-time purchase)

🔒 Your data stays on your device (offline-first)
🔑 Uses your own free Gemini API key (guide included)
📱 No account needed, no sign-up required

⚙️ Note:
• AI analysis requires a Gemini API Key (free from aistudio.google.com)
• Setup guide included in-app
• Works without API Key (manual logging only)
• Nutrition data from AI is approximate
```

#### 4.3 เตรียม Screenshots ภาษาอังกฤษ

> เปลี่ยน locale เป็น English → ถ่าย screenshot ใหม่ทั้งหมด
> ใส่ข้อความ English บน screenshot mockup

---

### Step 5: Pricing Strategy (ตั้งราคาต่างประเทศ)

> ตั้งใน Google Play Console → In-app products → `miro_cal_pro` → Pricing

| ตลาด | ราคา | เหตุผล |
|-------|------|--------|
| Thailand (THB) | 199-299 ฿ | ตลาดหลัก |
| US (USD) | $4.99 | เทียบ MyFitnessPal $80/ปี → ถูกกว่ามาก |
| Japan (JPY) | ¥700 | ตลาด health-conscious ใหญ่ |
| South Korea (KRW) | ₩6,500 | K-health trend |
| Southeast Asia | $2.99-3.99 | กำลังซื้อใกล้เคียงไทย |
| Europe (EUR) | €4.99 | |
| UK (GBP) | £3.99 | |

> **Google Play** สามารถตั้งราคาต่างกันแต่ละประเทศได้

---

## ✅ Checklist

### Units + Formatting
- [ ] Dropdown หน่วย → แสดงชื่อตาม locale (EN: "piece", TH: "ชิ้น")
- [ ] วันที่ → แสดงตาม locale (EN: "Feb 7", TH: "7 ก.พ.")
- [ ] Meal labels → แสดงตาม locale (EN: "Breakfast", TH: "เช้า")
- [ ] Unit key ยังเป็น English ใน database (ไม่เปลี่ยน)

### Store Listing
- [ ] เพิ่ม English listing ใน Play Console
- [ ] Full description ภาษาอังกฤษกรอกแล้ว
- [ ] Screenshots ภาษาอังกฤษ upload แล้ว
- [ ] ราคาต่างประเทศตั้งแล้ว

### Final Global Check
- [ ] เปลี่ยนภาษาเป็น EN → ทุกหน้าแสดงภาษาอังกฤษ
- [ ] เปลี่ยนกลับ TH → ทุกหน้ายังเป็นไทย
- [ ] ค้นหาอาหารภาษาอังกฤษ → ทำงาน
- [ ] แชทภาษาอังกฤษ → ทำงาน
- [ ] ถ่ายรูปอาหาร (EN locale) → Gemini ตอบภาษาอังกฤษ
- [ ] ไม่มี hardcoded Thai string เหลือ

---

## 🎉 ยินดีด้วย! แอป v2.0 (Thai + English) พร้อม Global Launch!

---

## 🚀 Next Steps (อนาคต)

### เพิ่มภาษาใหม่ง่ายมาก!

แค่สร้าง ARB file ใหม่:

```
lib/l10n/
  app_th.arb    ← ไทย (มีแล้ว)
  app_en.arb    ← อังกฤษ (มีแล้ว)
  app_ja.arb    ← ญี่ปุ่น (เพิ่ม!)
  app_zh.arb    ← จีน (เพิ่ม!)
  app_ko.arb    ← เกาหลี (เพิ่ม!)
  app_es.arb    ← สเปน (เพิ่ม!)
```

แล้ว:
1. คัดลอก `app_en.arb` → `app_ja.arb`
2. แปลค่าทั้งหมด (ใช้ AI ช่วยแปลได้)
3. เพิ่ม `Locale('ja')` ใน `supportedLocales`
4. `flutter gen-l10n`
5. เสร็จ!

### ภาษาที่ควรทำก่อน (ตลาดใหญ่ + health-conscious):
1. Japanese (ตลาด health app ใหญ่มาก)
2. Chinese Simplified (ประชากรเยอะ)
3. Korean (K-health trend)
4. Spanish (LatAm + Spain)

---

## 📊 จุดขาย vs คู่แข่ง (สำหรับ Marketing)

| | Miro Cal | MyFitnessPal | Lose It! |
|---|---------|-------------|----------|
| ราคา | $5 ขายขาด | $80/ปี | $40/ปี |
| AI วิเคราะห์รูป | Gemini (ฟรี BYOK) | ต้อง Premium | ต้อง Premium |
| Offline | 100% | ต้อง online | ต้อง online |
| Privacy | ข้อมูลในเครื่อง | เก็บบน cloud | เก็บบน cloud |
| DB โตเอง | ใช่ | ไม่ | ไม่ |
| ไม่ต้อง sign up | ใช่ | ต้อง account | ต้อง account |
