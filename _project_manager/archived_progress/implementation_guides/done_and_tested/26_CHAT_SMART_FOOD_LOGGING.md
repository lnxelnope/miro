# Step 26: Chat Smart Food Logging - ค้นหา MyMeal/Ingredient อัตโนมัติ

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 5-6 ชั่วโมง
> **ความยาก:** ยาก
> **ต้องทำก่อน:** Step 24 (Ingredient & MyMeal Model) + Step 25 (MyMeal Tab UI)

---

## 🎯 เป้าหมาย

1. **Chat → ค้น MyMeal ก่อน:** "กลางวันกินผัดกระเพรา" → ค้น MyMeal → เจอ → บันทึกพร้อม nutrition ทันที
2. **Chat → ค้น Ingredient:** "กินไข่ 2 ฟอง" → ค้น Ingredient → เจอ → บันทึก 180 kcal ทันที
3. **ไม่เจอ → บันทึกค่า 0:** ถ้าไม่เจอใน MyMeal/Ingredient → บันทึกค่า 0 → แนะนำให้ใช้ Gemini
4. **Modifier:** "กินผัดกระเพรา ไม่ใส่น้ำมัน" → ดึง MyMeal → ลบ "น้ำมัน" → คำนวณใหม่
5. **สร้างเมนูใหม่ผ่าน Chat:** "สร้างเมนูใหม่ ข้าวไข่เจียว" → สร้าง entry ค่า 0 + ถามจะสร้าง MyMeal ไหม
6. **Auto-save Gemini Results:** เมื่อวิเคราะห์ Gemini เสร็จ → auto-save ingredients + meal ลง DB

---

## 📐 Chat Food Logging Flow

```
┌─────────────────────────────────────────────────────────────────┐
│  ผู้ใช้พิมพ์: "กลางวันกินผัดกระเพราหมูไข่ดาว 1 จาน"           │
│                                                                 │
│  ┌── Step 1: LLM Service parse ──┐                             │
│  │ type: "health"                 │                             │
│  │ category: "Food"              │                             │
│  │ title: "ผัดกระเพราหมูไข่ดาว"  │                             │
│  │ serving_size: 1               │                             │
│  │ serving_unit: "จาน"           │                             │
│  │ meal_type: "lunch"            │                             │
│  └────────────────────────────────┘                             │
│                                                                 │
│  ┌── Step 2: IntentHandler ──────────────────────────────────┐  │
│  │                                                            │  │
│  │  2a. ค้นหา MyMeal: "ผัดกระเพราหมูไข่ดาว"                 │  │
│  │      ↓                                                     │  │
│  │  [เจอ] → ใช้ nutrition จาก MyMeal                         │  │
│  │      calories = meal.totalCalories * servingSize            │  │
│  │      → บันทึก FoodEntry ทันที                              │  │
│  │      → ตอบ "✅ บันทึก ผัดกระเพราหมูไข่ดาว 611 kcal"       │  │
│  │                                                            │  │
│  │  [ไม่เจอ] → ค้น Ingredient: "ผัดกระเพราหมูไข่ดาว"        │  │
│  │      ↓                                                     │  │
│  │  [ไม่เจอ] → บันทึก 0 kcal                                │  │
│  │      → ตอบ "✅ บันทึกแล้ว (0 kcal)"                       │  │
│  │      → แนะนำ "กดปุ่ม Gemini ที่ Timeline เพื่อวิเคราะห์"  │  │
│  │                                                            │  │
│  └────────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ผู้ใช้พิมพ์: "กินผัดกระเพรา ไม่ใส่น้ำมัน"                     │
│                                                                 │
│  ┌── Step 2 (Modifier Case) ─────────────────────────────────┐  │
│  │  2a. ค้นหา MyMeal: "ผัดกระเพรา" → [เจอ]                  │  │
│  │  2b. ตรวจ modifier: "ไม่ใส่น้ำมัน"                        │  │
│  │  2c. ดึง ingredients ของ meal                              │  │
│  │  2d. หา ingredient "น้ำมัน" → เจอ (88 kcal)               │  │
│  │  2e. ลบ: 611 - 88 = 523 kcal                              │  │
│  │  2f. บันทึก FoodEntry: 523 kcal                            │  │
│  │      → ตอบ "✅ บันทึก ผัดกระเพรา (ไม่ใส่น้ำมัน) 523 kcal" │  │
│  └────────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ผู้ใช้พิมพ์: "กินไข่ 2 ฟอง เป็นอาหารเช้า"                    │
│                                                                 │
│  ┌── Step 2 (Ingredient Case) ───────────────────────────────┐  │
│  │  2a. ค้นหา MyMeal: "ไข่" → [ไม่เจอ]                       │  │
│  │  2b. ค้นหา Ingredient: "ไข่" → [เจอ] (90 kcal/ฟอง)       │  │
│  │  2c. คำนวณ: 90 * 2 = 180 kcal                             │  │
│  │  2d. บันทึก FoodEntry: 180 kcal                            │  │
│  │      → ตอบ "✅ บันทึก ไข่ 2 ฟอง 180 kcal"                 │  │
│  └────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📂 ไฟล์ที่เกี่ยวข้อง

| ไฟล์ | Action | คำอธิบาย |
|------|--------|----------|
| `lib/features/chat/services/intent_handler.dart` | REWRITE `_handleHealth` | ค้น MyMeal/Ingredient + modifier |
| `lib/features/chat/services/food_lookup_service.dart` | CREATE | Service ค้นหา food จาก DB |
| `lib/core/ai/llm_service.dart` | EDIT | ปรับ prompt ให้ตรวจจับ modifier |
| `lib/features/health/providers/health_provider.dart` | EDIT | auto-save จาก Gemini |
| `lib/features/health/widgets/gemini_analysis_sheet.dart` | EDIT | เพิ่มปุ่ม "สร้าง My Meal" |

---

## 🔧 ขั้นตอนการทำงาน

### Step 1: สร้าง Food Lookup Service

**ไฟล์:** `lib/features/chat/services/food_lookup_service.dart`
**Action:** CREATE

**ทำไม:** แยก logic การค้นหา MyMeal/Ingredient ออกมาเป็น service เพื่อให้ reuse ได้ง่าย

```dart
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../../../core/database/database_service.dart';
import '../../health/models/my_meal.dart';
import '../../health/models/my_meal_ingredient.dart';
import '../../health/models/ingredient.dart';

/// ผลลัพธ์การค้นหาอาหาร
class FoodLookupResult {
  /// ประเภทผลลัพธ์
  final FoodLookupType type;

  /// MyMeal ที่พบ (ถ้ามี)
  final MyMeal? meal;

  /// Ingredient ที่พบ (ถ้ามี)
  final Ingredient? ingredient;

  /// Ingredients ที่ลบออก (modifier: "ไม่ใส่...")
  final List<MyMealIngredient> removedIngredients;

  /// Nutrition ที่คำนวณแล้ว (หลังจาก modifier)
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  /// ปริมาณ
  final double servingSize;
  final String servingUnit;

  /// ชื่อ (สำหรับ display)
  final String displayName;

  FoodLookupResult({
    required this.type,
    this.meal,
    this.ingredient,
    this.removedIngredients = const [],
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.servingSize,
    required this.servingUnit,
    required this.displayName,
  });
}

enum FoodLookupType {
  fromMeal,        // พบใน MyMeal
  fromIngredient,  // พบใน Ingredient
  notFound,        // ไม่พบ → ใช้ค่า 0
}

/// Service สำหรับค้นหาอาหารจาก MyMeal + Ingredient DB
class FoodLookupService {

  /// ค้นหาอาหารจากชื่อ
  /// 
  /// [foodName] ชื่ออาหาร เช่น "ผัดกระเพราหมู"
  /// [servingSize] ปริมาณที่กิน เช่น 1.0
  /// [servingUnit] หน่วย เช่น "จาน"
  /// [excludeIngredients] วัตถุดิบที่ต้องลบออก เช่น ["น้ำมัน"]
  static Future<FoodLookupResult> lookup({
    required String foodName,
    double servingSize = 1.0,
    String servingUnit = 'จาน',
    List<String> excludeIngredients = const [],
  }) async {
    debugPrint('🔍 [FoodLookup] ค้นหา: "$foodName"');
    debugPrint('   - ปริมาณ: $servingSize $servingUnit');
    if (excludeIngredients.isNotEmpty) {
      debugPrint('   - ไม่ใส่: ${excludeIngredients.join(", ")}');
    }

    // ===== Step 1: ค้นหาจาก MyMeal =====
    final mealResult = await _searchMyMeal(foodName);
    if (mealResult != null) {
      debugPrint('✅ [FoodLookup] เจอใน MyMeal: "${mealResult.name}" (id=${mealResult.id})');

      // ดึง ingredients ของ meal
      final mealIngredients = await DatabaseService.myMealIngredients
          .filter()
          .myMealIdEqualTo(mealResult.id)
          .findAll();

      // คำนวณ nutrition (หลัง exclude)
      double totalCal = 0, totalP = 0, totalC = 0, totalF = 0;
      final removedIngs = <MyMealIngredient>[];

      for (final ing in mealIngredients) {
        // ตรวจว่า ingredient นี้อยู่ใน exclude list ไหม
        bool excluded = false;
        for (final ex in excludeIngredients) {
          if (_fuzzyMatch(ing.ingredientName, ex)) {
            excluded = true;
            removedIngs.add(ing);
            debugPrint('   ❌ ลบ: ${ing.ingredientName} (${ing.calories.toInt()} kcal)');
            break;
          }
        }

        if (!excluded) {
          totalCal += ing.calories;
          totalP += ing.protein;
          totalC += ing.carbs;
          totalF += ing.fat;
        }
      }

      // คูณด้วย serving size
      totalCal *= servingSize;
      totalP *= servingSize;
      totalC *= servingSize;
      totalF *= servingSize;

      // สร้าง display name
      String displayName = mealResult.name;
      if (excludeIngredients.isNotEmpty && removedIngs.isNotEmpty) {
        displayName += ' (ไม่ใส่${removedIngs.map((e) => e.ingredientName).join(", ")})';
      }

      // เพิ่ม usage count
      mealResult.usageCount++;
      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.myMeals.put(mealResult);
      });

      return FoodLookupResult(
        type: FoodLookupType.fromMeal,
        meal: mealResult,
        removedIngredients: removedIngs,
        calories: totalCal,
        protein: totalP,
        carbs: totalC,
        fat: totalF,
        servingSize: servingSize,
        servingUnit: servingUnit.isNotEmpty ? servingUnit : mealResult.baseServingDescription,
        displayName: displayName,
      );
    }

    // ===== Step 2: ค้นหาจาก Ingredient =====
    final ingredientResult = await _searchIngredient(foodName);
    if (ingredientResult != null) {
      debugPrint('✅ [FoodLookup] เจอใน Ingredient: "${ingredientResult.name}" (id=${ingredientResult.id})');

      final cal = ingredientResult.calcCalories(servingSize);
      final prot = ingredientResult.calcProtein(servingSize);
      final carb = ingredientResult.calcCarbs(servingSize);
      final fat2 = ingredientResult.calcFat(servingSize);

      // เพิ่ม usage count
      ingredientResult.usageCount++;
      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.ingredients.put(ingredientResult);
      });

      return FoodLookupResult(
        type: FoodLookupType.fromIngredient,
        ingredient: ingredientResult,
        calories: cal,
        protein: prot,
        carbs: carb,
        fat: fat2,
        servingSize: servingSize,
        servingUnit: servingUnit.isNotEmpty ? servingUnit : ingredientResult.baseUnit,
        displayName: '${ingredientResult.name} ${servingSize.toStringAsFixed(0)} ${ingredientResult.baseUnit}',
      );
    }

    // ===== Step 3: ไม่เจอ → ค่า 0 =====
    debugPrint('❓ [FoodLookup] ไม่เจอ "$foodName" → ใช้ค่า 0');

    return FoodLookupResult(
      type: FoodLookupType.notFound,
      calories: 0,
      protein: 0,
      carbs: 0,
      fat: 0,
      servingSize: servingSize,
      servingUnit: servingUnit,
      displayName: foodName,
    );
  }

  // ===== Private Methods =====

  /// ค้นหา MyMeal ด้วย fuzzy matching
  static Future<MyMeal?> _searchMyMeal(String query) async {
    final all = await DatabaseService.myMeals.where().findAll();
    if (all.isEmpty) return null;

    final lowerQuery = query.toLowerCase().trim();

    // 1. Exact match
    for (final meal in all) {
      if (meal.name.toLowerCase() == lowerQuery) return meal;
    }

    // 2. Contains match
    for (final meal in all) {
      if (meal.name.toLowerCase().contains(lowerQuery) ||
          lowerQuery.contains(meal.name.toLowerCase())) {
        return meal;
      }
    }

    // 3. Fuzzy match (Levenshtein distance)
    MyMeal? bestMatch;
    int bestDistance = 999;
    for (final meal in all) {
      final dist = _levenshtein(meal.name.toLowerCase(), lowerQuery);
      // ถ้า distance น้อยกว่า 30% ของความยาว ถือว่า match
      final threshold = (meal.name.length * 0.3).ceil();
      if (dist < bestDistance && dist <= threshold) {
        bestDistance = dist;
        bestMatch = meal;
      }
    }

    return bestMatch;
  }

  /// ค้นหา Ingredient ด้วย fuzzy matching
  static Future<Ingredient?> _searchIngredient(String query) async {
    final all = await DatabaseService.ingredients.where().findAll();
    if (all.isEmpty) return null;

    final lowerQuery = query.toLowerCase().trim();

    // 1. Exact match
    for (final ing in all) {
      if (ing.name.toLowerCase() == lowerQuery) return ing;
    }

    // 2. Contains match
    for (final ing in all) {
      if (ing.name.toLowerCase().contains(lowerQuery) ||
          lowerQuery.contains(ing.name.toLowerCase())) {
        return ing;
      }
    }

    // 3. Fuzzy match
    Ingredient? bestMatch;
    int bestDistance = 999;
    for (final ing in all) {
      final dist = _levenshtein(ing.name.toLowerCase(), lowerQuery);
      final threshold = (ing.name.length * 0.3).ceil();
      if (dist < bestDistance && dist <= threshold) {
        bestDistance = dist;
        bestMatch = ing;
      }
    }

    return bestMatch;
  }

  /// Fuzzy match สำหรับ ingredient name (ใช้ตรวจ exclude)
  static bool _fuzzyMatch(String a, String b) {
    final la = a.toLowerCase().trim();
    final lb = b.toLowerCase().trim();
    if (la == lb) return true;
    if (la.contains(lb) || lb.contains(la)) return true;

    // Levenshtein threshold
    final dist = _levenshtein(la, lb);
    final threshold = (la.length * 0.3).ceil().clamp(1, 3);
    return dist <= threshold;
  }

  /// Levenshtein distance
  static int _levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List.generate(t.length + 1, (i) => i);
    List<int> v1 = List.filled(t.length + 1, 0);

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;
      for (int j = 0; j < t.length; j++) {
        final cost = s[i] == t[j] ? 0 : 1;
        v1[j + 1] = [v1[j] + 1, v0[j + 1] + 1, v0[j] + cost].reduce((a, b) => a < b ? a : b);
      }
      final temp = v0;
      v0 = v1;
      v1 = temp;
    }
    return v0[t.length];
  }
}
```

---

### Step 2: ปรับ LLM Service - เพิ่มการตรวจจับ Modifier + สร้างเมนูใหม่

**ไฟล์:** `lib/core/ai/llm_service.dart`
**Action:** EDIT

**หา method `_localFallback` → ส่วนที่จัดการ health/food**

**ในส่วน Food classification (ประมาณบรรทัดที่มี `if (category == 'Food')`):**

**เพิ่มการ detect modifier ("ไม่ใส่...", "ไม่มี...", "ไม่เอา..."):**

หาตรงก่อนจะ return JSON สำหรับ health food (ประมาณก่อน `return jsonEncode(result)`) แล้วเพิ่ม:

```dart
        // ตรวจจับ modifiers (ไม่ใส่..., ไม่มี..., ไม่เอา...)
        final excludeIngredients = _extractExcludeIngredients(text);
        if (excludeIngredients.isNotEmpty) {
          debugPrint('🚫 [LLMService] Exclude ingredients: ${excludeIngredients.join(", ")}');
        }

        // ตรวจจับว่าต้องการสร้างเมนูใหม่หรือไม่
        final isCreateMeal = text.contains('สร้างเมนู') || 
                             text.contains('เมนูใหม่') ||
                             text.contains('สูตรใหม่') ||
                             text.contains('บันทึกสูตร');
```

**เพิ่ม fields ใน result JSON:**

ในส่วนที่สร้าง JSON result ของ health food (ประมาณ `return jsonEncode({...})`) เพิ่ม:

```dart
        result['exclude_ingredients'] = excludeIngredients;
        result['is_create_meal'] = isCreateMeal;
```

**เพิ่ม method ใหม่ `_extractExcludeIngredients`:**

```dart
  /// ดึงรายการวัตถุดิบที่ต้องลบออก จากข้อความ
  /// เช่น "ไม่ใส่น้ำมัน" → ["น้ำมัน"]
  /// "ไม่เอาไข่ ไม่ใส่น้ำมัน" → ["ไข่", "น้ำมัน"]
  static List<String> _extractExcludeIngredients(String text) {
    final excludes = <String>[];
    
    // Pattern: ไม่ใส่X, ไม่มีX, ไม่เอาX, เอาXออก, ลบXออก, ไม่ต้องX
    final patterns = [
      RegExp(r'ไม่ใส่(\S+)'),
      RegExp(r'ไม่มี(\S+)'),
      RegExp(r'ไม่เอา(\S+)'),
      RegExp(r'เอา(\S+)ออก'),
      RegExp(r'ลบ(\S+)ออก'),
      RegExp(r'ไม่ต้อง(\S+)'),
      RegExp(r'งด(\S+)'),
    ];

    for (final pattern in patterns) {
      final matches = pattern.allMatches(text);
      for (final match in matches) {
        final ingredient = match.group(1)?.trim();
        if (ingredient != null && ingredient.isNotEmpty) {
          // ลบคำที่ไม่ใช่วัตถุดิบ
          final cleaned = ingredient
              .replaceAll('นะ', '')
              .replaceAll('ครับ', '')
              .replaceAll('ค่ะ', '')
              .replaceAll('น้า', '')
              .replaceAll('จ้า', '')
              .replaceAll('นะครับ', '')
              .replaceAll('นะคะ', '')
              .replaceAll('ด้วย', '')
              .trim();
          if (cleaned.isNotEmpty && cleaned.length > 1) {
            excludes.add(cleaned);
          }
        }
      }
    }

    return excludes;
  }
```

---

### Step 3: Rewrite IntentHandler `_handleHealth` - ค้น MyMeal/Ingredient

**ไฟล์:** `lib/features/chat/services/intent_handler.dart`
**Action:** EDIT

**เพิ่ม import:**

```dart
import 'food_lookup_service.dart';
import '../../health/models/my_meal.dart';
import '../../health/models/ingredient.dart' as IngredientModel;
import '../../health/models/my_meal_ingredient.dart';
```

**แทนที่ฟังก์ชัน `_handleHealth` ทั้งหมด (ตั้งแต่บรรทัด 73 ถึง 201) ด้วย:**

```dart
  /// จัดการ Health Intent
  Future<IntentResponse> _handleHealth(
    String original,
    String title,
    String category,
    Map<String, dynamic> parsed,
  ) async {
    debugPrint('🍎 [IntentHandler] _handleHealth: category=$category, title=$title');
    debugPrint('📋 [IntentHandler] Parsed data: $parsed');
    
    if (category == 'Food' || original.contains('กิน') || original.contains('ทาน')) {
      // ดึงค่าจาก AI
      final servingSizeFromAI = (parsed['serving_size'] as num?)?.toDouble() ?? 1.0;
      final servingUnitFromAI = parsed['serving_unit'] as String? ?? 'จาน';
      final servingGramsFromAI = (parsed['serving_grams'] as num?)?.toDouble();
      final excludeIngredients = (parsed['exclude_ingredients'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [];
      final isCreateMeal = parsed['is_create_meal'] as bool? ?? false;
      
      // ดึงวันที่
      DateTime entryDate = DateTime.now();
      if (parsed['date'] != null) {
        final parsedDate = DateTime.tryParse(parsed['date'] as String);
        if (parsedDate != null) entryDate = parsedDate;
      }
      
      // ดึงมื้ออาหาร
      final mealTypeStr = parsed['meal_type'] as String?;
      final mealType = mealTypeStr != null 
          ? _mapMealTypeFromString(mealTypeStr) 
          : _detectMealType();

      // ===== ค้นหาจาก MyMeal / Ingredient DB =====
      final lookupResult = await FoodLookupService.lookup(
        foodName: title,
        servingSize: servingSizeFromAI,
        servingUnit: servingUnitFromAI,
        excludeIngredients: excludeIngredients,
      );

      debugPrint('🔍 [IntentHandler] Lookup result: ${lookupResult.type}');
      debugPrint('   - displayName: ${lookupResult.displayName}');
      debugPrint('   - calories: ${lookupResult.calories}');

      // ===== สร้าง FoodEntry =====
      final calories = lookupResult.calories;
      final protein = lookupResult.protein;
      final carbs = lookupResult.carbs;
      final fat = lookupResult.fat;

      // กำหนด source ตาม lookup result
      DataSource source;
      switch (lookupResult.type) {
        case FoodLookupType.fromMeal:
          source = DataSource.aiAnalyzed; // มี nutrition data แล้ว
          break;
        case FoodLookupType.fromIngredient:
          source = DataSource.aiAnalyzed;
          break;
        case FoodLookupType.notFound:
          source = DataSource.manual; // ยังไม่มี data
          break;
      }

      final entry = FoodEntry()
        ..foodName = lookupResult.displayName
        ..calories = calories
        ..protein = protein
        ..carbs = carbs
        ..fat = fat
        // Base values สำหรับ recalculate
        ..baseCalories = servingSizeFromAI > 0 ? calories / servingSizeFromAI : calories
        ..baseProtein = servingSizeFromAI > 0 ? protein / servingSizeFromAI : protein
        ..baseCarbs = servingSizeFromAI > 0 ? carbs / servingSizeFromAI : carbs
        ..baseFat = servingSizeFromAI > 0 ? fat / servingSizeFromAI : fat
        ..mealType = mealType
        ..timestamp = entryDate
        ..servingSize = servingSizeFromAI
        ..servingUnit = servingUnitFromAI
        ..servingGrams = servingGramsFromAI
        // Links
        ..myMealId = lookupResult.meal?.id
        ..ingredientId = lookupResult.ingredient?.id
        ..source = source
        ..isVerified = lookupResult.type != FoodLookupType.notFound
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.foodEntries.put(entry);
      });

      debugPrint('✅ [IntentHandler] FoodEntry saved: id=${entry.id}');

      // ===== สร้างข้อความตอบกลับ =====
      String replyMessage;
      
      switch (lookupResult.type) {
        case FoodLookupType.fromMeal:
          // เจอใน MyMeal
          String macrosText = '';
          if (protein > 0 || carbs > 0 || fat > 0) {
            macrosText = '\n💪 P: ${protein.toInt()}g | C: ${carbs.toInt()}g | F: ${fat.toInt()}g';
          }
          String modifierText = '';
          if (lookupResult.removedIngredients.isNotEmpty) {
            final removedNames = lookupResult.removedIngredients.map((e) => e.ingredientName).join(', ');
            final removedCal = lookupResult.removedIngredients.fold<double>(0, (sum, e) => sum + e.calories);
            modifierText = '\n🚫 ไม่ใส่: $removedNames (-${removedCal.toInt()} kcal)';
          }
          String dateText = _getDateText(entryDate);
          
          replyMessage = '✅ บันทึกอาหารแล้ว!\n\n'
              '🍽️ **${lookupResult.displayName}** (${_getMealTypeText(mealType)})'
              '$dateText\n'
              '🔥 ${calories.toInt()} kcal'
              '$macrosText'
              '$modifierText\n\n'
              '📂 _จาก My Meal_\n'
              '_แก้ไขได้ที่หน้า Health > Timeline_';
          break;

        case FoodLookupType.fromIngredient:
          // เจอใน Ingredient
          String dateText = _getDateText(entryDate);
          
          replyMessage = '✅ บันทึกอาหารแล้ว!\n\n'
              '🥬 **${lookupResult.displayName}** (${_getMealTypeText(mealType)})'
              '$dateText\n'
              '🔥 ${calories.toInt()} kcal\n'
              '💪 P: ${protein.toInt()}g | C: ${carbs.toInt()}g | F: ${fat.toInt()}g\n\n'
              '📂 _จากฐานข้อมูลวัตถุดิบ_\n'
              '_แก้ไขได้ที่หน้า Health > Timeline_';
          break;

        case FoodLookupType.notFound:
          // ไม่เจอ → ค่า 0
          String dateText = _getDateText(entryDate);
          String createMealHint = '';
          if (isCreateMeal) {
            createMealHint = '\n\n🆕 ต้องการสร้างเป็นเมนูใหม่ ไปที่ My Meal > สร้างเมนูใหม่';
          }
          
          replyMessage = '✅ บันทึกอาหารแล้ว!\n\n'
              '🍽️ **${lookupResult.displayName}** (${_getMealTypeText(mealType)})'
              '$dateText\n'
              '🔥 0 kcal\n\n'
              '⚠️ _ยังไม่มีข้อมูลโภชนาการ_\n'
              '💡 _กดปุ่ม ✨ Gemini ที่หน้า Timeline เพื่อวิเคราะห์_'
              '$createMealHint\n\n'
              '_แก้ไขได้ที่หน้า Health > Timeline_';
          break;
      }

      return IntentResponse(
        replyMessage: replyMessage,
        actionResult: ActionResult.success(
          message: 'บันทึกอาหารสำเร็จ',
          entryType: 'food',
          entryId: entry.id,
          data: {
            'name': lookupResult.displayName, 
            'calories': calories,
            'protein': protein,
            'carbs': carbs,
            'fat': fat,
            'date': entryDate.toIso8601String(),
            'mealType': mealType.name,
            'lookupType': lookupResult.type.name,
          },
        ),
      );
    }

    if (category == 'Workout' || original.contains('ออกกำลัง') || original.contains('วิ่ง')) {
      return IntentResponse(
        replyMessage: '🏃 ฟีเจอร์บันทึก Workout กำลังพัฒนา\n\n'
            'เร็วๆ นี้จะสามารถบันทึก:\n'
            '• ประเภทการออกกำลังกาย\n'
            '• ระยะเวลา\n'
            '• แคลอรี่ที่เผาผลาญ',
        actionResult: null,
      );
    }

    return IntentResponse(
      replyMessage: '🍎 ต้องการบันทึกสุขภาพอะไรครับ?\n\n'
          'ลองบอกว่า:\n'
          '• "กินข้าวผัด"\n'
          '• "เมื่อวานกินส้มตำ"\n'
          '• "กินผัดกระเพรา ไม่ใส่น้ำมัน"\n'
          '• "กินไข่ 2 ฟอง"\n'
          '• "วิ่ง 30 นาที"',
      actionResult: null,
    );
  }

  /// Helper: สร้าง date text สำหรับ reply
  String _getDateText(DateTime entryDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDateOnly = DateTime(entryDate.year, entryDate.month, entryDate.day);
    if (entryDateOnly != today) {
      return '\n📅 ${_formatDate(entryDate)}';
    }
    return '';
  }
```

---

### Step 4: อัปเดต GeminiAnalysisSheet - Auto-save MyMeal + Ingredients

**ไฟล์:** `lib/features/health/widgets/gemini_analysis_sheet.dart`
**Action:** EDIT

**เพิ่มใน `GeminiConfirmedData`:**

```dart
  final List<Map<String, dynamic>>? ingredientsDetail;
```

เพิ่มใน constructor:
```dart
  this.ingredientsDetail,
```

**เพิ่มใน `_confirm()` ของ `_GeminiAnalysisSheetState`:**

```dart
      // เพิ่มข้อมูล ingredients_detail สำหรับ auto-save
      ingredientsDetail: widget.analysisResult.ingredientsDetail
          ?.map((e) => {
                'name': e.name,
                'name_en': e.nameEn,
                'amount': e.amount,
                'unit': e.unit,
                'calories': e.calories,
                'protein': e.protein,
                'carbs': e.carbs,
                'fat': e.fat,
              })
          .toList(),
```

---

### Step 5: อัปเดต Health Timeline Tab - Auto-save หลัง Gemini Confirm

**ไฟล์:** `lib/features/health/presentation/health_timeline_tab.dart`
**Action:** EDIT

**ในฟังก์ชัน `_analyzeFoodWithGemini` ตรง callback `onConfirm` ของ `GeminiAnalysisSheet`:**

หลัง `await notifier.updateFromGeminiConfirmed(...)` เพิ่ม:

```dart
            // Auto-save ingredients + meal ลง DB
            if (confirmedData.ingredientsDetail != null &&
                confirmedData.ingredientsDetail!.isNotEmpty) {
              try {
                await notifier.saveIngredientsAndMeal(
                  mealName: confirmedData.foodName,
                  mealNameEn: confirmedData.foodNameEn,
                  servingDescription: '${confirmedData.servingSize} ${confirmedData.servingUnit}',
                  imagePath: entry.imagePath,
                  ingredientsData: confirmedData.ingredientsDetail!,
                  ref: ref,
                );
                debugPrint('✅ Auto-saved meal + ingredients จาก Gemini');
              } catch (e) {
                debugPrint('⚠️ ไม่สามารถ auto-save meal: $e');
                // ไม่ throw - ไม่ควรทำให้ flow หลักพัง
              }
            }
```

**อย่าลืมเพิ่ม import:**
```dart
import '../providers/my_meal_provider.dart';
```

---

### Step 6: อัปเดต Health Provider - เพิ่ม import สำหรับ saveIngredientsAndMeal

**ไฟล์:** `lib/features/health/providers/health_provider.dart`
**Action:** EDIT

**ตรวจสอบว่ามี method `saveIngredientsAndMeal`** แล้ว (จาก Step 24) ถ้ายังไม่มี ให้เพิ่ม

**อัปเดต import:**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'my_meal_provider.dart';
```

**อัปเดต method signature ของ `saveIngredientsAndMeal` ให้รับ `WidgetRef` แทน `Ref`:**

เปลี่ยน parameter `required Ref ref` เป็น `required WidgetRef ref` **ไม่ได้** เพราะ `FoodEntriesNotifier` ไม่ควรรู้จัก `WidgetRef`

**ทางที่ดีกว่า:** ให้ `saveIngredientsAndMeal` สร้าง `MyMealNotifier` ตรงๆ:

```dart
  /// บันทึก ingredients + meal จากผล Gemini
  Future<void> saveIngredientsAndMeal({
    required String mealName,
    String? mealNameEn,
    required String servingDescription,
    String? imagePath,
    required List<Map<String, dynamic>> ingredientsData,
  }) async {
    try {
      final notifier = MyMealNotifier();

      final inputs = ingredientsData.map((data) => MealIngredientInput(
        name: data['name'] as String,
        nameEn: data['name_en'] as String?,
        amount: (data['amount'] as num).toDouble(),
        unit: data['unit'] as String,
        calories: (data['calories'] as num).toDouble(),
        protein: (data['protein'] as num).toDouble(),
        carbs: (data['carbs'] as num).toDouble(),
        fat: (data['fat'] as num).toDouble(),
      )).toList();

      await notifier.createMeal(
        name: mealName,
        nameEn: mealNameEn,
        baseServingDescription: servingDescription,
        imagePath: imagePath,
        ingredients: inputs,
      );

      debugPrint('✅ [FoodEntriesNotifier] Auto-saved meal: $mealName + ${inputs.length} ingredients');
    } catch (e) {
      debugPrint('⚠️ [FoodEntriesNotifier] Failed to auto-save: $e');
    }
  }
```

**อัปเดตใน `health_timeline_tab.dart` ให้ไม่ส่ง `ref`:**

```dart
                await notifier.saveIngredientsAndMeal(
                  mealName: confirmedData.foodName,
                  mealNameEn: confirmedData.foodNameEn,
                  servingDescription: '${confirmedData.servingSize} ${confirmedData.servingUnit}',
                  imagePath: entry.imagePath,
                  ingredientsData: confirmedData.ingredientsDetail!,
                );
```

---

## ✅ Definition of Done

- [ ] Chat "กินผัดกระเพรา" → ค้น MyMeal → เจอ → บันทึกพร้อม kcal
- [ ] Chat "กินไข่ 2 ฟอง" → ค้น Ingredient → เจอ → บันทึก 180 kcal
- [ ] Chat "กินข้าวราดแกง" → ค้น MyMeal → ไม่เจอ → ค้น Ingredient → ไม่เจอ → บันทึก 0 kcal + แนะนำ Gemini
- [ ] Chat "กินผัดกระเพรา ไม่ใส่น้ำมัน" → ค้น MyMeal → ลบน้ำมัน → คำนวณใหม่
- [ ] Chat "สร้างเมนูใหม่ ข้าวไข่เจียว" → บันทึก 0 kcal + แนะนำสร้าง MyMeal
- [ ] วิเคราะห์ Gemini → auto-save ingredients + meal ลง DB
- [ ] Fuzzy search ทำงานถูกต้อง (ค้นหา "ผัดกะเพรา" เจอ "ผัดกระเพรา")
- [ ] Usage count เพิ่มเมื่อใช้ MyMeal/Ingredient
- [ ] Reply message แสดงข้อมูลถูกต้อง (จาก MyMeal / Ingredient / 0 kcal)

---

## 📁 ไฟล์ที่สร้าง/แก้ไข

```
lib/
├── core/
│   └── ai/
│       └── llm_service.dart                    ← EDIT (modifier detection)
├── features/
│   ├── chat/
│   │   └── services/
│   │       ├── intent_handler.dart             ← EDIT (_handleHealth rewrite)
│   │       └── food_lookup_service.dart         ← NEW
│   └── health/
│       ├── providers/
│       │   └── health_provider.dart            ← EDIT (saveIngredientsAndMeal)
│       ├── widgets/
│       │   └── gemini_analysis_sheet.dart       ← EDIT (ingredientsDetail)
│       └── presentation/
│           └── health_timeline_tab.dart         ← EDIT (auto-save after Gemini)
```

---

## ⚠️ ข้อควรระวัง

1. **FoodLookupService ค้นจาก DB ตรง** ไม่ได้ใช้ Riverpod provider → ดังนั้นถ้า DB เปลี่ยน ต้อง invalidate providers ที่เกี่ยวข้อง
2. **Fuzzy search อาจ false positive** เช่น "ข้าว" อาจ match กับ "ข้าวต้ม" → threshold ต้องตั้งพอดี (30% of length)
3. **Modifier parsing เป็น regex** → อาจไม่ครอบคลุมทุกกรณี → สามารถเพิ่ม pattern ได้ภายหลัง
4. **Auto-save อาจสร้าง duplicate** ถ้าวิเคราะห์อาหารเดิมหลายครั้ง → `saveIngredient` เช็ค existing แล้วอัปเดตแทน
5. **Testing:** ทดสอบ flow ทั้งหมดก่อน push:
   - วิเคราะห์ Gemini ครั้งแรก → ingredients + meal ถูก save
   - Chat "กินผัดกระเพรา" → ค้นเจอ → kcal ถูกต้อง
   - Chat "กินไข่ 2 ฟอง" → ค้นเจอ → kcal ถูกต้อง
   - Chat "กินผัดกระเพรา ไม่ใส่น้ำมัน" → kcal ลดลง

---

## 🔄 Summary: ลำดับการทำงานทั้ง 4 Steps

```
Step 23 ──────────► Step 24 ──────────► Step 25 ──────────► Step 26
ลบ GlobalDB        สร้าง Models        สร้าง UI            Chat Integration
แก้ Recalculate     Ingredient          My Meal Tab          Smart Lookup
Gemini Analysis     MyMeal              CRUD                Modifier
Sheet              Auto-save           Log from Meal       Auto-save

  ↑ ต้องทำก่อน ↑    ↑ ต้องทำก่อน ↑    ↑ ต้องทำก่อน ↑
```

ทุก Step สามารถ test แยกได้ ไม่จำเป็นต้องทำทั้ง 4 Steps พร้อมกัน
