# Step 39: Global Food Database + Search + Chat Intent (English)

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 1-2 วัน
> **ความยาก:** ปานกลาง
> **ต้องทำก่อน:** Step 38 (Localization i18n)

---

## 🎯 เป้าหมาย

1. **food_names.json** — ใช้ `en` field เมื่อ locale = en
2. **Thai Food Database** — เพิ่ม English aliases
3. **Search** — ค้นหาได้ทั้งภาษาไทย + อังกฤษ
4. **Chat Intent** — รองรับ English keywords (ate, eat, had)
5. **Food Name Extraction** — รองรับ English particles (please, thanks)
6. **LLM Normalizer** — รองรับ English

---

## 📂 ไฟล์ที่เกี่ยวข้อง

| ไฟล์ | Action | คำอธิบาย |
|------|--------|----------|
| `lib/core/data/thai_food_database.dart` | EDIT | เพิ่ม English aliases + lookup method |
| `lib/core/data/global_food_database.dart` | EDIT | ใช้ `en` field จาก food_names.json |
| `lib/core/ai/llm_service.dart` | EDIT | เพิ่ม English normalizer + intent classification |
| `lib/features/chat/services/intent_handler.dart` | EDIT | เพิ่ม English keywords |
| `lib/features/chat/services/food_lookup_service.dart` | EDIT | Search ทั้ง th + en |
| `lib/features/health/widgets/food_search_field.dart` | EDIT | Search ทั้ง th + en |

---

## 🔧 ขั้นตอนการทำงาน

### Step 1: ปรับ food_names.json — ใช้ `en` field

**ข้อมูลปัจจุบัน (มี `en` อยู่แล้ว!):**

```json
{ "th": "ข้าวผัด", "en": "Fried Rice", "cal": null, "src": "thai" }
{ "th": "ต้มยำกุ้ง", "en": "Tom Yum Goong", "cal": null, "src": "thai" }
```

→ **ไม่ต้องแก้ JSON!** แค่แก้โค้ดที่อ่าน

### Step 1.1: แก้ที่อ่าน food_names.json

หาโค้ดที่อ่าน food_names.json → เพิ่มการใช้ `en` field:

```dart
/// ค้นหาอาหารจาก food_names.json
/// ค้นทั้ง th และ en field เสมอ (ไม่ว่า locale จะเป็นอะไร)
List<FoodNameEntry> searchFoodNames(String query) {
  final q = query.toLowerCase().trim();
  return _allFoods.where((food) {
    final thMatch = food.th?.toLowerCase().contains(q) ?? false;
    final enMatch = food.en?.toLowerCase().contains(q) ?? false;
    return thMatch || enMatch;
  }).toList();
}

/// ชื่อที่แสดง — ตาม locale
String displayName(FoodNameEntry food, String locale) {
  if (locale == 'en') {
    return food.en ?? food.th ?? '';
  }
  return food.th ?? food.en ?? '';
}
```

---

### Step 2: Thai Food Database — เพิ่ม English

**ไฟล์:** `lib/core/data/thai_food_database.dart`
**Action:** EDIT

#### 2.1 เพิ่ม English lookup map

```dart
class ThaiFoodDatabase {
  // ... map เดิมที่มีอยู่ ...

  /// English aliases → map ไปหา key ภาษาไทย
  static final Map<String, String> _englishAliases = {
    'fried rice': 'ข้าวผัด',
    'chicken rice': 'ข้าวมันไก่',
    'pad thai': 'ผัดไทย',
    'tom yum': 'ต้มยำ',
    'tom yum goong': 'ต้มยำกุ้ง',
    'green curry': 'แกงเขียวหวาน',
    'red curry': 'แกงแดง',
    'massaman curry': 'แกงมัสมั่น',
    'pad kra pao': 'ผัดกระเพรา',
    'basil stir fry': 'ผัดกระเพรา',
    'sticky rice': 'ข้าวเหนียว',
    'papaya salad': 'ส้มตำ',
    'som tam': 'ส้มตำ',
    'mango sticky rice': 'ข้าวเหนียวมะม่วง',
    'spring roll': 'ปอเปี๊ยะ',
    'satay': 'สะเต๊ะ',
    'larb': 'ลาบ',
    'khao soi': 'ข้าวซอย',
    'boat noodles': 'ก๋วยเตี๋ยวเรือ',
    'pad see ew': 'ผัดซีอิ๊ว',
    'thai tea': 'ชาไทย',
    'thai iced tea': 'ชาเย็น',
    'thai iced coffee': 'กาแฟเย็น',
    // เพิ่มได้อีกตามต้องการ
  };

  /// ค้นหาอาหาร — รองรับทั้งไทยและอังกฤษ
  static FoodNutritionData? lookup(String name) {
    final lower = name.toLowerCase().trim();

    // ลองหาจาก map ภาษาไทยก่อน
    final thResult = _thaiFoods[lower];
    if (thResult != null) return thResult;

    // ลองหาจาก English aliases
    final thaiKey = _englishAliases[lower];
    if (thaiKey != null) {
      return _thaiFoods[thaiKey.toLowerCase()];
    }

    // ลอง fuzzy match (contains)
    for (final entry in _thaiFoods.entries) {
      if (entry.key.contains(lower) || lower.contains(entry.key)) {
        return entry.value;
      }
    }
    for (final entry in _englishAliases.entries) {
      if (entry.key.contains(lower) || lower.contains(entry.key)) {
        return _thaiFoods[entry.value.toLowerCase()];
      }
    }

    return null;
  }

  /// ค้นหา — return รายการที่ match (สำหรับ autocomplete)
  static List<MapEntry<String, FoodNutritionData>> search(String query) {
    final q = query.toLowerCase().trim();
    final results = <MapEntry<String, FoodNutritionData>>[];

    // ค้นจาก Thai
    for (final entry in _thaiFoods.entries) {
      if (entry.key.contains(q)) {
        results.add(entry);
      }
    }

    // ค้นจาก English aliases
    for (final alias in _englishAliases.entries) {
      if (alias.key.contains(q)) {
        final data = _thaiFoods[alias.value.toLowerCase()];
        if (data != null) {
          results.add(MapEntry(alias.key, data));
        }
      }
    }

    return results;
  }
}
```

---

### Step 3: ปรับ Chat Intent — รองรับ English

**ไฟล์:** `lib/features/chat/services/intent_handler.dart`
**Action:** EDIT

#### 3.1 เพิ่ม English keywords ใน intent classification

หา method ที่ classify intent (อาจเช็ค keyword ภาษาไทย) → เพิ่ม English:

```dart
/// keywords สำหรับ food intent
static const _foodKeywordsTh = ['กิน', 'ทาน', 'อาหาร', 'ดื่ม', 'บันทึก', 'เช้า', 'เที่ยง', 'เย็น', 'ของว่าง'];
static const _foodKeywordsEn = ['ate', 'eat', 'eating', 'had', 'have', 'drink', 'drank', 'log', 'record',
  'breakfast', 'lunch', 'dinner', 'snack', 'meal'];

bool _isFoodIntent(String text) {
  final lower = text.toLowerCase();
  return _foodKeywordsTh.any((k) => lower.contains(k)) ||
         _foodKeywordsEn.any((k) => lower.contains(k));
}
```

#### 3.2 Food Name Extraction — English particles

```dart
/// ลบคำลงท้ายภาษาไทย
String _removeThaiParticles(String text) {
  return text.replaceAll(RegExp(r'\s*(ครับ|ค่ะ|คะ|นะ|จ้า|น่ะ|ด้วย)\s*$'), '');
}

/// ลบคำลงท้ายภาษาอังกฤษ
String _removeEnglishParticles(String text) {
  return text.replaceAll(
    RegExp(r'\s*(please|thanks|today|for lunch|for dinner|for breakfast|for snack)\s*$',
        caseSensitive: false),
    '',
  );
}

/// ลบ keywords ภาษาอังกฤษ
String _removeEnglishKeywords(String text) {
  return text
    .replaceAll(RegExp(r'^\s*(I |i )', caseSensitive: false), '')
    .replaceAll(RegExp(r'\s*(ate|eat|eating|had|have|drank|just had|just ate)\s+',
        caseSensitive: false), '')
    .trim();
}

/// Extract food name — รองรับทั้ง 2 ภาษา
String extractFoodName(String text) {
  var result = text;
  result = _removeThaiParticles(result);
  result = _removeEnglishParticles(result);
  result = _removeEnglishKeywords(result);
  // ... ลบ keyword อาหาร ที่มีอยู่เดิม ...
  return result.trim();
}
```

---

### Step 4: ปรับ LLM Service — English Normalizer

**ไฟล์:** `lib/core/ai/llm_service.dart`
**Action:** EDIT

หา `_normalizeThaiFood()` → เพิ่ม generic normalizer:

```dart
/// Normalize food name — รองรับทั้ง TH + EN
static String normalizeFoodName(String name, {String locale = 'th'}) {
  var result = name.trim().toLowerCase();

  if (locale == 'th' || _isThaiText(result)) {
    result = _normalizeThaiFood(result);
  } else {
    result = _normalizeEnglishFood(result);
  }

  return result;
}

/// ตรวจว่าเป็น text ภาษาไทยไหม
static bool _isThaiText(String text) {
  return text.runes.any((r) => r >= 0x0E00 && r <= 0x0E7F);
}

/// Normalize ภาษาอังกฤษ
static String _normalizeEnglishFood(String name) {
  var result = name.toLowerCase().trim();

  // ลบ articles
  result = result.replaceAll(RegExp(r'^(a |an |the |some )'), '');

  // ลบ adjectives ทั่วไป
  result = result.replaceAll(RegExp(r'\s*(bowl of|plate of|glass of|cup of|piece of)\s*'), ' ');

  // ลบ cooking methods prefix
  result = result.replaceAll(RegExp(r'^(fried |grilled |steamed |boiled |baked |roasted )'), '');

  return result.trim();
}
```

---

### Step 5: ปรับ Food Search Field — ค้นทั้ง 2 ภาษา

**ไฟล์:** `lib/features/health/widgets/food_search_field.dart`
**Action:** EDIT

ตรวจว่า Autocomplete ค้นทั้ง `th` + `en` fields:

```dart
// ใน optionsBuilder ของ Autocomplete:
optionsBuilder: (textEditingValue) {
  final query = textEditingValue.text.toLowerCase().trim();
  if (query.isEmpty) return const Iterable<FoodOption>.empty();

  // ค้นจาก My Meals (ชื่อไทย + ชื่ออังกฤษ)
  // ค้นจาก Ingredients
  // ค้นจาก Thai Food Database (ทั้ง _thaiFoods + _englishAliases)
  // ค้นจาก food_names.json (ทั้ง th + en field)

  return results;
},
```

---

## ✅ Checklist

- [ ] ค้นหา "fried rice" → เจอข้าวผัด (พร้อม nutrition data)
- [ ] ค้นหา "ข้าวผัด" → เจอเหมือนเดิม
- [ ] ค้นหา "pad thai" → เจอผัดไทย
- [ ] แชท (EN) "I had fried rice" → บันทึกสำเร็จ
- [ ] แชท (EN) "ate pizza for lunch" → บันทึกสำเร็จ
- [ ] แชท (TH) "กินข้าวผัด" → ยังทำงานเหมือนเดิม
- [ ] Autocomplete แสดงผลลัพธ์ทั้ง TH + EN
- [ ] ชื่อที่แสดง → ตาม locale (EN locale แสดง "Fried Rice", TH locale แสดง "ข้าวผัด")
- [ ] Gemini prompt → ภาษาตาม locale

---

## 🔍 Troubleshooting

### Q: ค้นหาภาษาอังกฤษไม่เจอ
**สาเหตุ:** ยังค้นเฉพาะ `th` field
**แก้:** เพิ่ม `en` field ในเงื่อนไข search

### Q: แชทภาษาอังกฤษไม่ถูก classify เป็น food
**สาเหตุ:** ยังไม่มี English keywords
**แก้:** เพิ่ม keywords ใน `_foodKeywordsEn`

### Q: "I ate fried rice" → food name เป็น "I fried rice"
**สาเหตุ:** ไม่ได้ลบ "ate"
**แก้:** ตรวจ `_removeEnglishKeywords()` ว่าลบ "ate" แล้ว

---

## 🎉 เสร็จแล้ว! ไปต่อ Step 40 →

ไปทำ **Step 40: Global Units + Formatting + Store Listing** ได้เลย
