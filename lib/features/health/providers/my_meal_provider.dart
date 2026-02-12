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
final allIngredientsProvider = FutureProvider.autoDispose<List<Ingredient>>((ref) async {
  return await DatabaseService.ingredients
      .where()
      .sortByUsageCountDesc()
      .findAll();
});

/// ค้นหา ingredient ตามชื่อ (fuzzy search)
final ingredientSearchProvider = FutureProvider.autoDispose.family<List<Ingredient>, String>((ref, query) async {
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
final allMyMealsProvider = FutureProvider.autoDispose<List<MyMeal>>((ref) async {
  return await DatabaseService.myMeals
      .where()
      .sortByUsageCountDesc()
      .findAll();
});

/// ค้นหา meal ตามชื่อ
final myMealSearchProvider = FutureProvider.autoDispose.family<List<MyMeal>, String>((ref, query) async {
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
final mealIngredientsProvider = FutureProvider.autoDispose.family<List<MyMealIngredient>, int>((ref, mealId) async {
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

      AppLogger.info('Updated Ingredient: ${existing.name} (id=${existing.id})');
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

    debugPrint('✅ [MyMealNotifier] Created new Ingredient: ${ingredient.name} (id=${ingredient.id})');
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

    AppLogger.info('Created MyMeal: ${meal.name} (id=${meal.id}, ${ingredients.length} ingredients)');
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
    if (meal == null) throw Exception('ไม่พบเมนู');

    // คำนวณ total nutrition
    double totalCal = 0, totalP = 0, totalC = 0, totalF = 0;
    for (final ing in ingredients) {
      totalCal += ing.calories;
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

      // ลบ MyMealIngredient เดิม
      await DatabaseService.myMealIngredients
          .filter()
          .myMealIdEqualTo(mealId)
          .deleteAll();
    });

    // สร้าง MyMealIngredient entries ใหม่
    for (int i = 0; i < ingredients.length; i++) {
      final inp = ingredients[i];

      final savedIngredient = await saveIngredient(
        name: inp.name,
        nameEn: inp.nameEn,
        baseAmount: inp.amount,
        baseUnit: inp.unit,
        calories: inp.calories,
        protein: inp.protein,
        carbs: inp.carbs,
        fat: inp.fat,
        source: meal.source,
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

    AppLogger.info('Updated Ingredient: ${ingredient.name} (id=${ingredient.id})');
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
