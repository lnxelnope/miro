import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/database/database_service.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/unit_converter.dart';
import '../models/ingredient.dart';
import '../models/my_meal.dart';
import '../models/my_meal_ingredient.dart';

// ===== INGREDIENT PROVIDERS =====

/// ดึง ingredients ทั้งหมด (เรียงตาม usageCount)
final allIngredientsProvider =
    FutureProvider.autoDispose<List<Ingredient>>((ref) async {
  final all = await DatabaseService.ingredients.where().findAll();
  all.sort((a, b) => b.usageCount.compareTo(a.usageCount));
  return all;
});

/// ค้นหา ingredient ตามชื่อ (fuzzy search)
final ingredientSearchProvider = FutureProvider.autoDispose
    .family<List<Ingredient>, String>((ref, query) async {
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
final allMyMealsProvider =
    FutureProvider.autoDispose<List<MyMeal>>((ref) async {
  final all = await DatabaseService.myMeals.where().findAll();
  all.sort((a, b) => b.usageCount.compareTo(a.usageCount));
  return all;
});

/// ค้นหา meal ตามชื่อ
final myMealSearchProvider =
    FutureProvider.autoDispose.family<List<MyMeal>, String>((ref, query) async {
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
final mealIngredientsProvider = FutureProvider.autoDispose
    .family<List<MyMealIngredient>, int>((ref, mealId) async {
  return await DatabaseService.myMealIngredients
      .filter()
      .myMealIdEqualTo(mealId)
      .sortBySortOrder()
      .findAll();
});

// ===== NOTIFIER =====

class MyMealNotifier extends StateNotifier<AsyncValue<void>> {
  MyMealNotifier() : super(const AsyncValue.data(null));

  /// Save new ingredient or update if exists
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
    // Validate and fallback unit
    final validUnit = UnitConverter.ensureValid(baseUnit);

    // Search if already exists (by name)
    final existing = await DatabaseService.ingredients
        .filter()
        .nameEqualTo(name)
        .findFirst();

    if (existing != null) {
      // Update with latest values
      existing.caloriesPerBase = calories;
      existing.proteinPerBase = protein;
      existing.carbsPerBase = carbs;
      existing.fatPerBase = fat;
      existing.baseAmount = baseAmount;
      existing.baseUnit = validUnit;
      existing.usageCount++;
      existing.updatedAt = DateTime.now();

      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.ingredients.put(existing);
      });

      AppLogger.info(
          'Updated Ingredient: ${existing.name} (id=${existing.id})');
      return existing;
    }

    // Create new
    final ingredient = Ingredient()
      ..name = name
      ..nameEn = nameEn
      ..baseAmount = baseAmount
      ..baseUnit = validUnit
      ..caloriesPerBase = calories
      ..proteinPerBase = protein
      ..carbsPerBase = carbs
      ..fatPerBase = fat
      ..source = source
      ..usageCount = 1;

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.ingredients.put(ingredient);
    });

    debugPrint(
        '✅ [MyMealNotifier] Created new Ingredient: ${ingredient.name} (id=${ingredient.id})');
    return ingredient;
  }

  /// Save ingredient และ sub-ingredients แบบ recursive
  /// Returns: MyMealIngredient ที่ save แล้ว (parent)
  Future<MyMealIngredient> _saveMealIngredient({
    required MyMeal meal,
    required MealIngredientInput input,
    required int? parentId, // null = root level
    required int depth, // 0 = root, 1 = sub, 2 = sub-sub
    required int sortOrder,
  }) async {
    // 1. บันทึก ingredient ลง Ingredient table ก่อน (สำหรับ reference)
    final savedIngredient = await saveIngredient(
      name: input.name,
      nameEn: input.nameEn,
      baseAmount: input.amount,
      baseUnit: input.unit,
      calories: input.calories,
      protein: input.protein,
      carbs: input.carbs,
      fat: input.fat,
      source: meal.source,
    );

    // 2. สร้าง MyMealIngredient จาก input
    final mealIngredient = MyMealIngredient()
      ..myMealId = meal.id
      ..ingredientId = savedIngredient.id
      ..ingredientName = input.name
      ..amount = input.amount
      ..unit = input.unit
      ..calories = input.calories
      ..protein = input.protein
      ..carbs = input.carbs
      ..fat = input.fat
      ..parentId = parentId // NEW
      ..depth = depth // NEW
      ..isComposite = false // จะ update ทีหลังถ้ามี sub
      ..detail = input.detail // NEW
      ..sortOrder = sortOrder;

    // 3. Save parent ก่อน (ต้องได้ id มาก่อน)
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.myMealIngredients.put(mealIngredient);
    });

    // 4. ถ้ามี sub-ingredients → save recursively
    if (input.subIngredients != null && input.subIngredients!.isNotEmpty) {
      int subSortOrder = sortOrder + 1;

      for (final subInput in input.subIngredients!) {
        await _saveMealIngredient(
          meal: meal,
          input: subInput,
          parentId: mealIngredient.id, // link to parent
          depth: depth + 1, // increase depth
          sortOrder: subSortOrder,
        );
        subSortOrder++;
      }

      // 5. Mark parent as composite
      mealIngredient.isComposite = true;
      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.myMealIngredients.put(mealIngredient);
      });
    }

    return mealIngredient;
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
    // คำนวณ total nutrition จาก ROOT ingredients เท่านั้น
    // (SUB ingredients อยู่ใน input.subIngredients ไม่นับ)
    double totalCal = 0, totalP = 0, totalC = 0, totalF = 0;
    for (final ing in ingredients) {
      totalCal += ing.calories; // ROOT only
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

    // สร้าง MyMealIngredient entries แบบ recursive (NEW)
    int sortIndex = 0;
    for (final input in ingredients) {
      await _saveMealIngredient(
        meal: meal,
        input: input,
        parentId: null, // ROOT
        depth: 0,
        sortOrder: sortIndex,
      );

      // sortIndex ต้องเพิ่มตามจำนวน sub ด้วย (ถ้ามี)
      if (input.subIngredients != null && input.subIngredients!.isNotEmpty) {
        sortIndex += input.subIngredients!.length;
      }
      sortIndex++;
    }

    AppLogger.info(
        'Created MyMeal: ${meal.name} (id=${meal.id}, ${ingredients.length} ROOT ingredients)');
    return meal;
  }

  /// อัปเดต MyMeal (ชื่อ, serving, nutrition) + ingredients
  Future<MyMeal> updateMeal({
    required int mealId,
    required String name,
    String? nameEn,
    required String baseServingDescription,
    String? imagePath,
    required List<MealIngredientInput> ingredients,
  }) async {
    final meal = await DatabaseService.myMeals.get(mealId);
    if (meal == null) throw Exception('Meal not found');

    // คำนวณ total nutrition จาก ROOT เท่านั้น
    double totalCal = 0, totalP = 0, totalC = 0, totalF = 0;
    for (final ing in ingredients) {
      totalCal += ing.calories; // ROOT only
      totalP += ing.protein;
      totalC += ing.carbs;
      totalF += ing.fat;
    }

    // อัปเดต MyMeal
    meal.name = name;
    meal.nameEn = nameEn;
    meal.totalCalories = totalCal;
    meal.totalProtein = totalP;
    meal.totalCarbs = totalC;
    meal.totalFat = totalF;
    meal.baseServingDescription = baseServingDescription;
    if (imagePath != null) meal.imagePath = imagePath;
    meal.updatedAt = DateTime.now();

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.myMeals.put(meal);

      // ลบ MyMealIngredient เดิมทั้งหมด (รวม children)
      await DatabaseService.myMealIngredients
          .filter()
          .myMealIdEqualTo(mealId)
          .deleteAll();
    });

    // สร้าง MyMealIngredient entries ใหม่แบบ recursive
    int sortIndex = 0;
    for (final input in ingredients) {
      await _saveMealIngredient(
        meal: meal,
        input: input,
        parentId: null, // ROOT
        depth: 0,
        sortOrder: sortIndex,
      );

      // sortIndex ต้องเพิ่มตามจำนวน sub ด้วย
      if (input.subIngredients != null && input.subIngredients!.isNotEmpty) {
        sortIndex += input.subIngredients!.length;
      }
      sortIndex++;
    }

    AppLogger.info('Updated MyMeal: ${meal.name} (id=${meal.id})');
    return meal;
  }

  /// Update existing Ingredient
  Future<Ingredient> updateIngredient({
    required int ingredientId,
    required String name,
    String? nameEn,
    required double baseAmount,
    required String baseUnit,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
  }) async {
    final ingredient = await DatabaseService.ingredients.get(ingredientId);
    if (ingredient == null) throw Exception('Ingredient not found');

    ingredient.name = name;
    ingredient.nameEn = nameEn;
    ingredient.baseAmount = baseAmount;
    ingredient.baseUnit = UnitConverter.ensureValid(baseUnit); // Validate unit
    ingredient.caloriesPerBase = calories;
    ingredient.proteinPerBase = protein;
    ingredient.carbsPerBase = carbs;
    ingredient.fatPerBase = fat;
    ingredient.updatedAt = DateTime.now();

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.ingredients.put(ingredient);
    });

    AppLogger.info(
        'Updated Ingredient: ${ingredient.name} (id=${ingredient.id})');
    return ingredient;
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

  /// เพิ่ม usageCount ของ ingredient
  Future<void> incrementIngredientUsage(int ingredientId) async {
    final ingredient = await DatabaseService.ingredients.get(ingredientId);
    if (ingredient != null) {
      ingredient.usageCount++;
      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.ingredients.put(ingredient);
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
  final String? detail; // NEW
  final double amount;
  final String unit;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final List<MealIngredientInput>? subIngredients; // NEW: recursive

  MealIngredientInput({
    required this.name,
    this.nameEn,
    this.detail, // NEW
    required this.amount,
    required this.unit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.subIngredients, // NEW
  });
}

// ===== TREE PROVIDER =====

/// ดึง ingredients ของ meal เป็น tree structure (ROOT + children)
final mealIngredientTreeProvider = FutureProvider.autoDispose
    .family<List<IngredientTreeNode>, int>((ref, mealId) async {
  // Query all ingredients ของ meal นี้
  final allIngredients = await DatabaseService.myMealIngredients
      .filter()
      .myMealIdEqualTo(mealId)
      .sortBySortOrder()
      .findAll();

  // แยก root vs sub
  final roots = allIngredients.where((e) => e.parentId == null).toList();

  // สร้าง map: parentId → List<children>
  final childMap = <int, List<MyMealIngredient>>{};
  for (final item in allIngredients.where((e) => e.parentId != null)) {
    childMap.putIfAbsent(item.parentId!, () => []).add(item);
  }

  // สร้าง tree nodes
  return roots.map((root) {
    return IngredientTreeNode(
      ingredient: root,
      children: childMap[root.id] ?? [],
    );
  }).toList();
});

/// Tree node สำหรับแสดง hierarchical ingredients
class IngredientTreeNode {
  final MyMealIngredient ingredient;
  final List<MyMealIngredient> children;

  IngredientTreeNode({
    required this.ingredient,
    required this.children,
  });

  bool get isComposite => children.isNotEmpty;

  /// Total calories รวม children (สำหรับ validation)
  double get totalCaloriesWithChildren {
    return ingredient.calories +
        children.fold<double>(0, (sum, child) => sum + child.calories);
  }
}
