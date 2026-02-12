# Step 24: สร้าง Ingredient + MyMeal Models (Self-Learning Food DB)

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 3-4 ชั่วโมง
> **ความยาก:** ปานกลาง
> **ต้องทำก่อน:** Step 23 (Remove Global DB + Fix Food Logic)

---

## 🎯 เป้าหมาย

1. สร้าง `Ingredient` model - ฐานข้อมูลวัตถุดิบส่วนตัว (ไข่, ข้าว, หมู ฯลฯ)
2. สร้าง `MyMeal` model - เมนูอาหารส่วนตัว (ผัดกระเพราไข่ดาว ฯลฯ)
3. สร้าง `MyMealIngredient` model - วัตถุดิบในเมนู (junction table)
4. ปรับ Gemini prompt ให้ส่ง ingredients แยกพร้อม nutrition แต่ละตัว
5. **Auto-save ingredients จากรูปอาหาร** - เมื่อ Gemini วิเคราะห์รูปเสร็จ ให้สกัดวัตถุดิบแต่ละตัวออกมาพร้อม nutrition แล้ว save ลง Ingredient DB + สร้าง MyMeal อัตโนมัติ
6. สร้าง Provider สำหรับ query ingredients/meals

---

## 📐 Concept: Self-Learning Food Database

### หลักการสำคัญ: ทุกรูปที่ส่งให้ Gemini = สร้างฐานข้อมูลวัตถุดิบอัตโนมัติ

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  📸 ขั้นตอนการเรียนรู้จากรูปอาหาร (AUTO-LEARN)                 │
│                                                                 │
│  วันที่ 1: ผู้ใช้ถ่ายรูปผัดกระเพราไข่ดาว                       │
│       ↓                                                         │
│  บันทึก FoodEntry ค่า 0 ก่อน (Step 23)                         │
│       ↓                                                         │
│  ผู้ใช้กดปุ่ม "วิเคราะห์ Gemini"                                │
│       ↓                                                         │
│  Gemini วิเคราะห์รูป → ส่ง ingredients_detail กลับมา:          │
│  ┌──────────────────────────────────────┐                      │
│  │ ข้าวสวย  200g → 260 kcal P:5 C:56 F:0│                     │
│  │ หมูสับ    80g → 170 kcal P:16 C:0 F:12│                    │
│  │ กระเพรา   10g →   3 kcal P:0 C:0 F:0 │                     │
│  │ ไข่ดาว     1ฟอง→ 90 kcal P:6 C:1 F:7 │                     │
│  │ น้ำมัน    10g →  88 kcal P:0 C:0 F:10│                     │
│  └──────────────────────────────────────┘                      │
│       ↓                                                         │
│  ผู้ใช้ยืนยันผลวิเคราะห์ (GeminiAnalysisSheet)                 │
│       ↓                                                         │
│  ⭐ AUTO-SAVE ทั้ง 3 อย่างพร้อมกัน:                            │
│  ┌──────────────────────────────────────┐                      │
│  │ 1. อัปเดต FoodEntry → 611 kcal       │                      │
│  │ 2. Ingredient DB ← ข้าวสวย, หมูสับ,  │                      │
│  │    กระเพรา, ไข่ดาว, น้ำมัน (5 ตัว)   │                      │
│  │ 3. MyMeal ← "ผัดกระเพราไข่ดาว"       │                      │
│  │    (link กับ ingredients ทั้ง 5)       │                      │
│  └──────────────────────────────────────┘                      │
│                                                                 │
│  🔮 ผลที่ได้: ฐานข้อมูลเรียนรู้เอง                             │
│                                                                 │
│  วันที่ 5: Chat "กินไข่ 2 ฟอง"                                 │
│  → ค้น Ingredient DB → เจอ "ไข่ดาว" (1 ฟอง = 90 kcal)         │
│  → 2 * 90 = 180 kcal → บันทึกทันที! (ไม่ต้อง Gemini)          │
│                                                                 │
│  วันที่ 10: Chat "กินผัดกระเพรา ไม่ใส่น้ำมัน"                  │
│  → ค้น MyMeal → เจอ "ผัดกระเพราไข่ดาว" (611 kcal)             │
│  → ลบ ingredient "น้ำมัน" (88 kcal)                            │
│  → 611 - 88 = 523 kcal → บันทึกทันที!                         │
│                                                                 │
│  วันที่ 15: Chat "กินข้าว 100 กรัม"                             │
│  → ค้น Ingredient DB → เจอ "ข้าวสวย" (200g = 260 kcal)         │
│  → 100g = 260 * (100/200) = 130 kcal → บันทึกทันที!            │
│                                                                 │
│  📊 ยิ่งใช้มาก → DB ยิ่งฉลาด → ยิ่งบันทึกเร็ว                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📂 ไฟล์ที่เกี่ยวข้อง

| ไฟล์ | Action | คำอธิบาย |
|------|--------|----------|
| `lib/features/health/models/ingredient.dart` | CREATE | Isar model วัตถุดิบ |
| `lib/features/health/models/my_meal.dart` | CREATE | Isar model เมนูอาหาร |
| `lib/features/health/models/my_meal_ingredient.dart` | CREATE | Isar model วัตถุดิบในเมนู |
| `lib/core/database/database_service.dart` | EDIT | ลงทะเบียน collections ใหม่ |
| `lib/features/health/providers/my_meal_provider.dart` | CREATE | Provider สำหรับ CRUD |
| `lib/core/ai/gemini_service.dart` | EDIT | ปรับ prompt ให้ส่ง ingredients แยก |
| `lib/features/health/widgets/gemini_analysis_sheet.dart` | EDIT | แสดง ingredients list |
| `lib/features/health/providers/health_provider.dart` | EDIT | auto-save ingredients/meal หลัง Gemini |

---

## 🔧 ขั้นตอนการทำงาน

### Step 1: สร้าง Ingredient Model

**ไฟล์:** `lib/features/health/models/ingredient.dart`
**Action:** CREATE

```dart
import 'package:isar/isar.dart';

part 'ingredient.g.dart';

/// ฐานข้อมูลวัตถุดิบส่วนตัว
/// เรียนรู้จากการใช้งานจริง (Gemini วิเคราะห์ + manual)
/// 
/// ตัวอย่าง:
///   name: "ไข่", baseAmount: 1, baseUnit: "ฟอง"
///   caloriesPerBase: 90, proteinPerBase: 6, carbsPerBase: 1, fatPerBase: 7
///   → ถ้ากิน 2 ฟอง = 90*2 = 180 kcal
@collection
class Ingredient {
  Id id = Isar.autoIncrement;

  /// ชื่อวัตถุดิบ (ไทย)
  late String name;
  
  /// ชื่อวัตถุดิบ (อังกฤษ) - nullable
  String? nameEn;

  /// ปริมาณฐาน เช่น 100 (ถ้าหน่วยเป็น g) หรือ 1 (ถ้าหน่วยเป็น ฟอง)
  late double baseAmount;
  
  /// หน่วยฐาน เช่น "g", "ฟอง", "ถ้วย", "ช้อนโต๊ะ"
  late String baseUnit;

  /// Nutrition ต่อ baseAmount
  late double caloriesPerBase;
  late double proteinPerBase;
  late double carbsPerBase;
  late double fatPerBase;

  /// Micros (optional) ต่อ baseAmount
  double? fiberPerBase;
  double? sugarPerBase;
  double? sodiumPerBase;

  /// แหล่งที่มา: "gemini" | "manual"
  late String source;

  /// จำนวนครั้งที่ถูกใช้ (สำหรับ ranking ตอนค้นหา)
  int usageCount = 0;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  // ============================================
  // Helper Methods
  // ============================================

  /// คำนวณ nutrition สำหรับปริมาณที่ระบุ
  /// [amount] ปริมาณที่ต้องการ (ในหน่วย baseUnit)
  /// 
  /// ตัวอย่าง: ไข่ (base=1 ฟอง, cal=90)
  ///   calcCalories(2) → 180 kcal (2 ฟอง)
  ///   calcCalories(0.5) → 45 kcal (ครึ่งฟอง)
  /// 
  /// ตัวอย่าง: ข้าว (base=100g, cal=130)
  ///   calcCalories(200) → 260 kcal (200g)
  double calcCalories(double amount) => (caloriesPerBase / baseAmount) * amount;
  double calcProtein(double amount) => (proteinPerBase / baseAmount) * amount;
  double calcCarbs(double amount) => (carbsPerBase / baseAmount) * amount;
  double calcFat(double amount) => (fatPerBase / baseAmount) * amount;
}
```

---

### Step 2: สร้าง MyMeal Model

**ไฟล์:** `lib/features/health/models/my_meal.dart`
**Action:** CREATE

```dart
import 'package:isar/isar.dart';

part 'my_meal.g.dart';

/// เมนูอาหารส่วนตัว
/// ประกอบจาก Ingredients หลายตัว
/// 
/// ตัวอย่าง: "ผัดกระเพราไข่ดาว"
///   totalCalories: 611 (ผลรวมจาก ingredients ทั้งหมด)
///   baseServingDescription: "1 จาน"
@collection
class MyMeal {
  Id id = Isar.autoIncrement;

  /// ชื่อเมนู (ไทย)
  late String name;
  
  /// ชื่อเมนู (อังกฤษ) - nullable
  String? nameEn;

  /// รวม Nutrition ของเมนูนี้ (ผลรวมจาก ingredients ทั้งหมด)
  late double totalCalories;
  late double totalProtein;
  late double totalCarbs;
  late double totalFat;

  /// คำอธิบายปริมาณฐาน เช่น "1 จาน", "1 ชุด"
  late String baseServingDescription;

  /// รูปภาพ (ถ้ามี)
  String? imagePath;

  /// แหล่งที่มา: "gemini" | "manual"
  late String source;

  /// จำนวนครั้งที่ถูกใช้
  int usageCount = 0;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  // ============================================
  // Helper: คำนวณ nutrition ตาม multiplier
  // ============================================

  /// คำนวณแคลอรี่สำหรับ multiplier
  /// ตัวอย่าง: totalCalories=611, calcCalories(0.5) → 305.5
  double calcCalories(double multiplier) => totalCalories * multiplier;
  double calcProtein(double multiplier) => totalProtein * multiplier;
  double calcCarbs(double multiplier) => totalCarbs * multiplier;
  double calcFat(double multiplier) => totalFat * multiplier;
}
```

---

### Step 3: สร้าง MyMealIngredient Model

**ไฟล์:** `lib/features/health/models/my_meal_ingredient.dart`
**Action:** CREATE

```dart
import 'package:isar/isar.dart';

part 'my_meal_ingredient.g.dart';

/// วัตถุดิบในเมนู (Junction Table)
/// เชื่อม MyMeal กับ Ingredient พร้อมปริมาณ
/// 
/// ตัวอย่าง: ผัดกระเพราไข่ดาว (myMealId=1)
///   ingredientId=1 (ข้าว),   amount=200, unit="g"  → cal=260
///   ingredientId=2 (หมูสับ), amount=80,  unit="g"  → cal=170
///   ingredientId=3 (ไข่),    amount=1,   unit="ฟอง" → cal=90
@collection
class MyMealIngredient {
  Id id = Isar.autoIncrement;

  /// ID ของเมนูที่อยู่ใน
  late int myMealId;

  /// ID ของวัตถุดิบ
  late int ingredientId;

  /// ชื่อวัตถุดิบ (เก็บซ้ำเพื่อ display ไม่ต้อง join)
  late String ingredientName;

  /// ปริมาณที่ใช้ในเมนูนี้
  late double amount;
  
  /// หน่วย
  late String unit;

  /// Nutrition ที่คำนวณแล้ว (= ingredient.calc * amount)
  late double calories;
  late double protein;
  late double carbs;
  late double fat;

  /// ลำดับ (สำหรับ display)
  int sortOrder = 0;
}
```

---

### Step 4: ลงทะเบียน Collections ใน DatabaseService

**ไฟล์:** `lib/core/database/database_service.dart`
**Action:** EDIT

**เพิ่ม imports:**

```dart
import '../../features/health/models/ingredient.dart';
import '../../features/health/models/my_meal.dart';
import '../../features/health/models/my_meal_ingredient.dart';
```

**เพิ่มใน schemas list (ตรง `Isar.open`):**

หาตรง `schemas:` แล้วเพิ่ม:
```dart
IngredientSchema,
MyMealSchema,
MyMealIngredientSchema,
```

**เพิ่ม getters สำหรับ collections ใหม่:**

```dart
static IsarCollection<Ingredient> get ingredients => isar.ingredients;
static IsarCollection<MyMeal> get myMeals => isar.myMeals;
static IsarCollection<MyMealIngredient> get myMealIngredients => isar.myMealIngredients;
```

---

### Step 5: รัน Build Runner

```bash
dart run build_runner build --delete-conflicting-outputs
```

**⚠️ ต้อง uninstall app** บนเครื่องทดสอบเพราะ schema เปลี่ยน

---

### Step 6: สร้าง MyMeal Provider

**ไฟล์:** `lib/features/health/providers/my_meal_provider.dart`
**Action:** CREATE

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/database/database_service.dart';
import '../models/ingredient.dart';
import '../models/my_meal.dart';
import '../models/my_meal_ingredient.dart';

// ===== INGREDIENT PROVIDERS =====

/// ดึง ingredients ทั้งหมด (เรียงตาม usageCount)
final allIngredientsProvider = FutureProvider<List<Ingredient>>((ref) async {
  return await DatabaseService.ingredients
      .where()
      .sortByUsageCountDesc()
      .findAll();
});

/// ค้นหา ingredient ตามชื่อ (fuzzy search)
final ingredientSearchProvider = FutureProvider.family<List<Ingredient>, String>((ref, query) async {
  if (query.isEmpty) return [];
  
  final all = await DatabaseService.ingredients.where().findAll();
  final lowerQuery = query.toLowerCase();
  
  return all.where((ing) {
    return ing.name.toLowerCase().contains(lowerQuery) ||
           (ing.nameEn?.toLowerCase().contains(lowerQuery) ?? false);
  }).toList()
    ..sort((a, b) => b.usageCount.compareTo(a.usageCount));
});

// ===== MY MEAL PROVIDERS =====

/// ดึง meals ทั้งหมด
final allMyMealsProvider = FutureProvider<List<MyMeal>>((ref) async {
  return await DatabaseService.myMeals
      .where()
      .sortByUsageCountDesc()
      .findAll();
});

/// ค้นหา meal ตามชื่อ
final myMealSearchProvider = FutureProvider.family<List<MyMeal>, String>((ref, query) async {
  if (query.isEmpty) return [];
  
  final all = await DatabaseService.myMeals.where().findAll();
  final lowerQuery = query.toLowerCase();
  
  return all.where((meal) {
    return meal.name.toLowerCase().contains(lowerQuery) ||
           (meal.nameEn?.toLowerCase().contains(lowerQuery) ?? false);
  }).toList()
    ..sort((a, b) => b.usageCount.compareTo(a.usageCount));
});

/// ดึง ingredients ของ meal
final mealIngredientsProvider = FutureProvider.family<List<MyMealIngredient>, int>((ref, mealId) async {
  return await DatabaseService.myMealIngredients
      .filter()
      .myMealIdEqualTo(mealId)
      .sortBySortOrder()
      .findAll();
});

// ===== NOTIFIER =====

class MyMealNotifier extends StateNotifier<AsyncValue<void>> {
  MyMealNotifier() : super(const AsyncValue.data(null));

  /// บันทึก ingredient ใหม่ หรืออัปเดตถ้ามีอยู่แล้ว
  Future<Ingredient> saveIngredient({
    required String name,
    String? nameEn,
    required double baseAmount,
    required String baseUnit,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    String source = 'gemini',
  }) async {
    // ค้นหาว่ามีอยู่แล้วหรือไม่ (ตามชื่อ)
    final existing = await DatabaseService.ingredients
        .filter()
        .nameEqualTo(name)
        .findFirst();

    if (existing != null) {
      // อัปเดตด้วยค่าล่าสุด
      existing.caloriesPerBase = calories;
      existing.proteinPerBase = protein;
      existing.carbsPerBase = carbs;
      existing.fatPerBase = fat;
      existing.baseAmount = baseAmount;
      existing.baseUnit = baseUnit;
      existing.usageCount++;
      existing.updatedAt = DateTime.now();

      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.ingredients.put(existing);
      });

      debugPrint('✅ [MyMealNotifier] อัปเดต Ingredient: ${existing.name} (id=${existing.id})');
      return existing;
    }

    // สร้างใหม่
    final ingredient = Ingredient()
      ..name = name
      ..nameEn = nameEn
      ..baseAmount = baseAmount
      ..baseUnit = baseUnit
      ..caloriesPerBase = calories
      ..proteinPerBase = protein
      ..carbsPerBase = carbs
      ..fatPerBase = fat
      ..source = source
      ..usageCount = 1;

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.ingredients.put(ingredient);
    });

    debugPrint('✅ [MyMealNotifier] สร้าง Ingredient ใหม่: ${ingredient.name} (id=${ingredient.id})');
    return ingredient;
  }

  /// สร้าง MyMeal พร้อม ingredients
  Future<MyMeal> createMeal({
    required String name,
    String? nameEn,
    required String baseServingDescription,
    String? imagePath,
    required List<MealIngredientInput> ingredients,
    String source = 'gemini',
  }) async {
    // คำนวณ total nutrition
    double totalCal = 0, totalP = 0, totalC = 0, totalF = 0;
    for (final ing in ingredients) {
      totalCal += ing.calories;
      totalP += ing.protein;
      totalC += ing.carbs;
      totalF += ing.fat;
    }

    // สร้าง MyMeal
    final meal = MyMeal()
      ..name = name
      ..nameEn = nameEn
      ..totalCalories = totalCal
      ..totalProtein = totalP
      ..totalCarbs = totalC
      ..totalFat = totalF
      ..baseServingDescription = baseServingDescription
      ..imagePath = imagePath
      ..source = source
      ..usageCount = 1;

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.myMeals.put(meal);
    });

    // สร้าง MyMealIngredient entries
    for (int i = 0; i < ingredients.length; i++) {
      final inp = ingredients[i];

      // บันทึก ingredient ลง DB ด้วย
      final savedIngredient = await saveIngredient(
        name: inp.name,
        nameEn: inp.nameEn,
        baseAmount: inp.amount,
        baseUnit: inp.unit,
        calories: inp.calories,
        protein: inp.protein,
        carbs: inp.carbs,
        fat: inp.fat,
        source: source,
      );

      final mealIngredient = MyMealIngredient()
        ..myMealId = meal.id
        ..ingredientId = savedIngredient.id
        ..ingredientName = inp.name
        ..amount = inp.amount
        ..unit = inp.unit
        ..calories = inp.calories
        ..protein = inp.protein
        ..carbs = inp.carbs
        ..fat = inp.fat
        ..sortOrder = i;

      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.myMealIngredients.put(mealIngredient);
      });
    }

    debugPrint('✅ [MyMealNotifier] สร้าง MyMeal: ${meal.name} (id=${meal.id}, ${ingredients.length} ingredients)');
    return meal;
  }

  /// ลบ MyMeal พร้อม ingredients
  Future<void> deleteMeal(int mealId) async {
    await DatabaseService.isar.writeTxn(() async {
      // ลบ ingredients ของ meal
      await DatabaseService.myMealIngredients
          .filter()
          .myMealIdEqualTo(mealId)
          .deleteAll();
      // ลบ meal
      await DatabaseService.myMeals.delete(mealId);
    });
  }

  /// ลบ ingredient
  Future<void> deleteIngredient(int ingredientId) async {
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.ingredients.delete(ingredientId);
    });
  }

  /// เพิ่ม usageCount ของ meal
  Future<void> incrementMealUsage(int mealId) async {
    final meal = await DatabaseService.myMeals.get(mealId);
    if (meal != null) {
      meal.usageCount++;
      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.myMeals.put(meal);
      });
    }
  }
}

final myMealNotifierProvider =
    StateNotifierProvider<MyMealNotifier, AsyncValue<void>>((ref) {
  return MyMealNotifier();
});

/// Input data สำหรับสร้าง ingredient ใน meal
class MealIngredientInput {
  final String name;
  final String? nameEn;
  final double amount;
  final String unit;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  MealIngredientInput({
    required this.name,
    this.nameEn,
    required this.amount,
    required this.unit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}
```

---

### Step 7: อัปเดต GeminiAnalysisSheet - แสดง Ingredients ที่สกัดได้

**ไฟล์:** `lib/features/health/widgets/gemini_analysis_sheet.dart`
**Action:** EDIT

**ทำไม:** เมื่อ Gemini ส่ง `ingredients_detail` กลับมา ต้องแสดงให้ผู้ใช้เห็นว่าสกัดวัตถุดิบอะไรมาบ้าง ก่อนจะ auto-save

**เพิ่มใน `build()` method ก่อนปุ่มยืนยัน (ก่อนบรรทัด `// ปุ่มยืนยัน + ยกเลิก`):**

```dart
            // ===== Ingredients ที่สกัดได้ (จากรูป) =====
            if (widget.analysisResult.ingredientsDetail != null &&
                widget.analysisResult.ingredientsDetail!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.science_outlined, size: 16, color: Colors.green),
                        const SizedBox(width: 6),
                        const Text(
                          'วัตถุดิบที่สกัดได้ (จะบันทึกอัตโนมัติ)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...widget.analysisResult.ingredientsDetail!.map((ing) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          const Text('  •  ', style: TextStyle(fontSize: 12)),
                          Expanded(
                            child: Text(
                              '${ing.name} (${ing.amount.toStringAsFixed(0)} ${ing.unit})',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          Text(
                            '${ing.calories.toInt()} kcal',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 6),
                    const Text(
                      '💡 วัตถุดิบเหล่านี้จะถูกบันทึกลงฐานข้อมูลส่วนตัว\n'
                      '   สามารถใช้ซ้ำได้ในครั้งต่อไปผ่าน Chat หรือ My Meal',
                      style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
```

**เพิ่ม `ingredientsDetail` ใน `GeminiConfirmedData`:**

หา class `GeminiConfirmedData` เพิ่ม field:
```dart
  final List<Map<String, dynamic>>? ingredientsDetail;
```

เพิ่มใน constructor:
```dart
  this.ingredientsDetail,
```

**เพิ่มใน `_confirm()` method:**

หลัง `notes: widget.analysisResult.notes,` เพิ่ม:
```dart
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

### Step 8: ปรับ Gemini Prompt ให้ส่ง Ingredients แยก

**ไฟล์:** `lib/core/ai/gemini_service.dart`
**Action:** EDIT

**หา prompt ใน `analyzeFoodImage` (ส่วน text part) แทนที่ด้วย:**

```dart
'text': '''คุณเป็น AI ที่เชี่ยวชาญด้านโภชนาการอาหารไทยและนานาชาติ
วิเคราะห์รูปภาพอาหารและประมาณค่าโภชนาการให้แม่นยำที่สุด

สำคัญ: ให้แยกวัตถุดิบแต่ละอย่างพร้อมปริมาณและค่าโภชนาการ

ให้ตอบเป็น JSON format ตามโครงสร้างนี้:
{
  "food_name": "ชื่ออาหารภาษาไทย",
  "food_name_en": "English name",
  "confidence": 0.85,
  "serving_size": 1,
  "serving_unit": "จาน",
  "serving_grams": 350,
  "nutrition": {
    "calories": 611,
    "protein": 27,
    "carbs": 57,
    "fat": 29,
    "fiber": 2,
    "sugar": 3,
    "sodium": 850
  },
  "ingredients_detail": [
    {
      "name": "ข้าวสวย",
      "name_en": "Steamed Rice",
      "amount": 200,
      "unit": "g",
      "calories": 260,
      "protein": 5,
      "carbs": 56,
      "fat": 0.5
    },
    {
      "name": "หมูสับ",
      "name_en": "Minced Pork",
      "amount": 80,
      "unit": "g",
      "calories": 170,
      "protein": 16,
      "carbs": 0,
      "fat": 12
    }
  ],
  "ingredients": ["ข้าว", "หมูสับ", "กระเพรา", "ไข่"],
  "notes": "หมายเหตุเพิ่มเติม"
}''',
```

**เพิ่ม field `ingredientsDetail` ใน `FoodAnalysisResult`:**

หา class `FoodAnalysisResult` แล้วเพิ่ม:

```dart
  final List<IngredientDetail>? ingredientsDetail;
```

ใน constructor เพิ่ม:
```dart
  this.ingredientsDetail,
```

ใน `fromJson` เพิ่ม:
```dart
      ingredientsDetail: json['ingredients_detail'] != null
          ? (json['ingredients_detail'] as List)
              .map((e) => IngredientDetail.fromJson(e))
              .toList()
          : null,
```

**สร้าง class `IngredientDetail`:**

```dart
class IngredientDetail {
  final String name;
  final String? nameEn;
  final double amount;
  final String unit;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  IngredientDetail({
    required this.name,
    this.nameEn,
    required this.amount,
    required this.unit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory IngredientDetail.fromJson(Map<String, dynamic> json) {
    return IngredientDetail(
      name: json['name'] ?? '',
      nameEn: json['name_en'],
      amount: (json['amount'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'g',
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
    );
  }
}
```

---

### Step 9: Auto-save Ingredients + Meal หลัง Gemini Confirm (จุดสำคัญที่สุด)

**ไฟล์:** `lib/features/health/providers/health_provider.dart`
**Action:** EDIT

**ในฟังก์ชัน `updateFromGeminiConfirmed` เพิ่มที่ท้าย (ก่อน `debugPrint` สุดท้าย):**

```dart
    // Auto-save ingredients + meal (ถ้า Gemini ส่ง ingredients_detail มา)
    // จะทำใน Phase ถัดไป (Step 25) - เตรียม method ไว้ก่อน
```

**เพิ่ม method ใหม่:**

```dart
  /// บันทึก ingredients + meal จากผล Gemini
  /// เรียกหลังจาก updateFromGeminiConfirmed
  Future<void> saveIngredientsAndMeal({
    required String mealName,
    String? mealNameEn,
    required String servingDescription,
    String? imagePath,
    required List<Map<String, dynamic>> ingredientsData,
    required Ref ref,
  }) async {
    try {
      final notifier = ref.read(myMealNotifierProvider.notifier);

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

      debugPrint('✅ [FoodEntriesNotifier] Auto-saved meal + ingredients');
    } catch (e) {
      debugPrint('⚠️ [FoodEntriesNotifier] Failed to auto-save: $e');
      // ไม่ throw - เป็นแค่ bonus feature ไม่ควรทำให้ flow หลักพัง
    }
  }
```

**อย่าลืมเพิ่ม import:**
```dart
import 'my_meal_provider.dart';
```

---

### Step 10: เชื่อม Auto-save ใน Health Timeline Tab

**ไฟล์:** `lib/features/health/presentation/health_timeline_tab.dart`
**Action:** EDIT

**ทำไม:** หลังจากผู้ใช้กด "ยืนยัน" ใน GeminiAnalysisSheet ต้อง trigger auto-save ingredients + meal

**ในฟังก์ชัน `_analyzeFoodWithGemini` ตรง callback `onConfirm` ของ `GeminiAnalysisSheet`:**

หลัง `await notifier.updateFromGeminiConfirmed(...)` เพิ่ม:

```dart
            // ===== AUTO-SAVE: สกัด ingredients จากรูป → สร้าง Ingredient DB + MyMeal =====
            if (confirmedData.ingredientsDetail != null &&
                confirmedData.ingredientsDetail!.isNotEmpty) {
              try {
                await notifier.saveIngredientsAndMeal(
                  mealName: confirmedData.foodName,
                  mealNameEn: confirmedData.foodNameEn,
                  servingDescription: '${confirmedData.servingSize} ${confirmedData.servingUnit}',
                  imagePath: entry.imagePath,
                  ingredientsData: confirmedData.ingredientsDetail!,
                );
                
                debugPrint('✅ Auto-saved: ${confirmedData.ingredientsDetail!.length} ingredients + 1 meal');
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '✅ อัปเดตเรียบร้อย + บันทึก ${confirmedData.ingredientsDetail!.length} วัตถุดิบลง My Meal แล้ว',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                debugPrint('⚠️ ไม่สามารถ auto-save meal: $e');
                // ไม่ throw - flow หลัก (อัปเดต FoodEntry) สำเร็จแล้ว
              }
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ อัปเดตข้อมูลเรียบร้อย'), backgroundColor: AppColors.success),
                );
              }
            }
```

**⚠️ ลบ SnackBar เดิมที่อยู่ข้างล่างออก** (เพราะย้ายมาอยู่ใน if/else ข้างบนแล้ว)

---

## ✅ Definition of Done

- [ ] สร้าง `ingredient.dart`, `my_meal.dart`, `my_meal_ingredient.dart` แล้ว
- [ ] `build_runner` รันผ่าน
- [ ] ลงทะเบียน collections ใน `DatabaseService`
- [ ] `MyMealNotifier` สามารถ CRUD ได้
- [ ] Gemini prompt ส่ง `ingredients_detail` มา
- [ ] `FoodAnalysisResult` รองรับ `ingredientsDetail`
- [ ] GeminiAnalysisSheet แสดงรายการ ingredients ที่สกัดได้
- [ ] Auto-save: ถ่ายรูป → Gemini → ยืนยัน → ingredients + meal ถูก save ลง DB อัตโนมัติ
- [ ] SnackBar แสดงจำนวน ingredients ที่ save ได้
- [ ] ทดสอบ: วิเคราะห์อาหาร → ไปดูที่ My Meal tab → เห็นเมนู + วัตถุดิบที่ถูกสร้าง
- [ ] ทดสอบ: วิเคราะห์ซ้ำ → ingredients ที่มีอยู่แล้วถูกอัปเดต (ไม่ duplicate)

---

## 📁 ไฟล์ที่สร้าง/แก้ไข

```
lib/
├── core/
│   ├── ai/
│   │   └── gemini_service.dart          ← EDIT (prompt + IngredientDetail)
│   └── database/
│       └── database_service.dart        ← EDIT (register collections)
└── features/
    └── health/
        ├── models/
        │   ├── ingredient.dart          ← NEW
        │   ├── ingredient.g.dart        ← GENERATED
        │   ├── my_meal.dart             ← NEW
        │   ├── my_meal.g.dart           ← GENERATED
        │   ├── my_meal_ingredient.dart  ← NEW
        │   └── my_meal_ingredient.g.dart← GENERATED
        └── providers/
            ├── health_provider.dart     ← EDIT (auto-save method)
            └── my_meal_provider.dart    ← NEW
```
