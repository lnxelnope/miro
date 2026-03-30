import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide JsonKey, Column;
import '../../../core/database/app_database.dart';
import '../../../core/database/database_service.dart';
import '../../../core/database/model_extensions.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/unit_converter.dart';
// ===== INGREDIENT PROVIDERS =====

/// ดึง ingredients ทั้งหมด (เรียงตาม usageCount)
final allIngredientsProvider =
    FutureProvider.autoDispose<List<Ingredient>>((ref) async {
  final all = await DatabaseService.db.select(DatabaseService.db.ingredients).get();
  all.sort((a, b) => b.usageCount.compareTo(a.usageCount));
  return all;
});

/// ค้นหา ingredient ตามชื่อ (fuzzy search)
final ingredientSearchProvider = FutureProvider.autoDispose
    .family<List<Ingredient>, String>((ref, query) async {
  if (query.isEmpty) return [];

  final all = await DatabaseService.db.select(DatabaseService.db.ingredients).get();
  final lowerQuery = query.toLowerCase();

  return all.where((ing) {
    return ing.name.toLowerCase().contains(lowerQuery) ||
        (ing.nameEn?.toLowerCase().contains(lowerQuery) ?? false);
  }).toList()
    ..sort((a, b) => b.usageCount.compareTo(a.usageCount));
});

// ===== MY MEAL PROVIDERS =====

/// ดึง meals ทั้งหมด — เรียงจากล่าสุดที่เปลี่ยนแปลง/บันทึกด้านบน
final allMyMealsProvider =
    FutureProvider.autoDispose<List<MyMeal>>((ref) async {
  final all = await DatabaseService.db.select(DatabaseService.db.myMeals).get();
  all.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return all;
});

/// ค้นหา meal ตามชื่อ
final myMealSearchProvider =
    FutureProvider.autoDispose.family<List<MyMeal>, String>((ref, query) async {
  if (query.isEmpty) return [];

  final all = await DatabaseService.db.select(DatabaseService.db.myMeals).get();
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
  return await (DatabaseService.db.select(DatabaseService.db.myMealIngredients)
        ..where((tbl) => tbl.myMealId.equals(mealId))
        ..orderBy([(tbl) => OrderingTerm.asc(tbl.sortOrder)]))
      .get();
});

// ===== NOTIFIER =====

class MyMealNotifier extends StateNotifier<AsyncValue<void>> {
  MyMealNotifier() : super(const AsyncValue.data(null));

  /// Save new ingredient or update if exists (delegates to IngredientActions.upsert)
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
    final validUnit = UnitConverter.ensureValid(baseUnit);
    return IngredientActions.upsert(
      name: name,
      nameEn: nameEn,
      baseAmount: baseAmount,
      baseUnit: validUnit,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      source: source,
    );
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

    // 2. สร้าง MyMealIngredient และ insert
    final mealIngredient = await DatabaseService.db
        .into(DatabaseService.db.myMealIngredients)
        .insertReturning(MyMealIngredientsCompanion.insert(
          myMealId: meal.id,
          ingredientId: savedIngredient.id,
          ingredientName: input.name,
          amount: input.amount,
          unit: input.unit,
          calories: input.calories,
          protein: input.protein,
          carbs: input.carbs,
          fat: input.fat,
          parentId: Value(parentId),
          depth: Value(depth),
          isComposite: const Value(false),
          detail: Value(input.detail),
          sortOrder: Value(sortOrder),
          ingredientImagePath: Value(input.ingredientImagePath),
          ingredientArBoundingBox: Value(input.ingredientArBoundingBox),
          ingredientArImageWidth: Value(input.ingredientArImageWidth),
          ingredientArImageHeight: Value(input.ingredientArImageHeight),
        ));

    // 3. ถ้ามี sub-ingredients → save recursively
    if (input.subIngredients != null && input.subIngredients!.isNotEmpty) {
      int subSortOrder = sortOrder + 1;

      for (final subInput in input.subIngredients!) {
        await _saveMealIngredient(
          meal: meal,
          input: subInput,
          parentId: mealIngredient.id,
          depth: depth + 1,
          sortOrder: subSortOrder,
        );
        subSortOrder++;
      }

      // 4. Mark parent as composite
      await (DatabaseService.db.update(DatabaseService.db.myMealIngredients)
            ..where((tbl) => tbl.id.equals(mealIngredient.id)))
          .write(MyMealIngredientsCompanion(isComposite: const Value(true)));
      mealIngredient.isComposite = true;
    }

    return mealIngredient;
  }

  /// สร้าง MyMeal พร้อม ingredients
  Future<MyMeal> createMeal({
    required String name,
    String? nameEn,
    required String baseServingDescription,
    String? imagePath,
    String? thumbnailUrl,
    String? thumbnailFirebasePath,
    required List<MealIngredientInput> ingredients,
    String source = 'gemini',
  }) async {
    // คำนวณ total nutrition จาก ROOT ingredients เท่านั้น
    double totalCal = 0, totalP = 0, totalC = 0, totalF = 0;
    for (final ing in ingredients) {
      totalCal += ing.calories;
      totalP += ing.protein;
      totalC += ing.carbs;
      totalF += ing.fat;
    }

    // สร้าง MyMeal
    final meal = await DatabaseService.db
        .into(DatabaseService.db.myMeals)
        .insertReturning(MyMealsCompanion.insert(
          name: name,
          totalCalories: totalCal,
          totalProtein: totalP,
          totalCarbs: totalC,
          totalFat: totalF,
          baseServingDescription: baseServingDescription,
          source: source,
          nameEn: Value(nameEn),
          imagePath: Value(imagePath),
          thumbnailUrl: Value(thumbnailUrl),
          thumbnailFirebasePath: Value(thumbnailFirebasePath),
          usageCount: const Value(1),
        ));

    // สร้าง MyMealIngredient entries แบบ recursive
    int sortIndex = 0;
    for (final input in ingredients) {
      await _saveMealIngredient(
        meal: meal,
        input: input,
        parentId: null,
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
    /// เปลี่ยนรูปเมนู (คัดลอกไฟล์ถาวรก่อนส่งจาก UI)
    String? newImagePath,
    /// ลบรูปเมนู + thumbnail backup
    bool removeMealImage = false,
    required List<MealIngredientInput> ingredients,
  }) async {
    final meal = await (DatabaseService.db.select(DatabaseService.db.myMeals)
          ..where((tbl) => tbl.id.equals(mealId)))
        .getSingleOrNull();
    if (meal == null) throw Exception('Meal not found');

    // คำนวณ total nutrition จาก ROOT เท่านั้น
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
    if (removeMealImage) {
      meal.imagePath = null;
      meal.thumbnailUrl = null;
      meal.thumbnailFirebasePath = null;
    } else if (newImagePath != null) {
      meal.imagePath = newImagePath;
      meal.thumbnailUrl = null;
      meal.thumbnailFirebasePath = null;
    }
    meal.updatedAt = DateTime.now();

    await DatabaseService.db.transaction(() async {
      await DatabaseService.db
          .into(DatabaseService.db.myMeals)
          .insertOnConflictUpdate(meal);

      // ลบ MyMealIngredient เดิมทั้งหมด (รวม children)
      await (DatabaseService.db.delete(DatabaseService.db.myMealIngredients)
            ..where((tbl) => tbl.myMealId.equals(mealId)))
          .go();
    });

    // สร้าง MyMealIngredient entries ใหม่แบบ recursive
    int sortIndex = 0;
    for (final input in ingredients) {
      await _saveMealIngredient(
        meal: meal,
        input: input,
        parentId: null,
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
    final ingredient = await (DatabaseService.db.select(DatabaseService.db.ingredients)
          ..where((tbl) => tbl.id.equals(ingredientId)))
        .getSingleOrNull();
    if (ingredient == null) throw Exception('Ingredient not found');

    ingredient.name = name;
    ingredient.nameEn = nameEn;
    ingredient.baseAmount = baseAmount;
    ingredient.baseUnit = UnitConverter.ensureValid(baseUnit);
    ingredient.caloriesPerBase = calories;
    ingredient.proteinPerBase = protein;
    ingredient.carbsPerBase = carbs;
    ingredient.fatPerBase = fat;
    ingredient.updatedAt = DateTime.now();

    await DatabaseService.db
        .into(DatabaseService.db.ingredients)
        .insertOnConflictUpdate(ingredient);

    AppLogger.info(
        'Updated Ingredient: ${ingredient.name} (id=${ingredient.id})');
    return ingredient;
  }

  /// ลบ MyMeal พร้อม ingredients
  Future<void> deleteMeal(int mealId) async {
    await DatabaseService.db.transaction(() async {
      await (DatabaseService.db.delete(DatabaseService.db.myMealIngredients)
            ..where((tbl) => tbl.myMealId.equals(mealId)))
          .go();
      await (DatabaseService.db.delete(DatabaseService.db.myMeals)
            ..where((tbl) => tbl.id.equals(mealId)))
          .go();
    });
  }

  /// ลบ ingredient
  Future<void> deleteIngredient(int ingredientId) async {
    await (DatabaseService.db.delete(DatabaseService.db.ingredients)
          ..where((tbl) => tbl.id.equals(ingredientId)))
        .go();
  }

  /// เพิ่ม usageCount ของ meal
  Future<void> incrementMealUsage(int mealId) async {
    final meal = await (DatabaseService.db.select(DatabaseService.db.myMeals)
          ..where((tbl) => tbl.id.equals(mealId)))
        .getSingleOrNull();
    if (meal != null) {
      meal.usageCount++;
      await DatabaseService.db
          .into(DatabaseService.db.myMeals)
          .insertOnConflictUpdate(meal);
    }
  }

  /// เพิ่ม usageCount ของ ingredient
  Future<void> incrementIngredientUsage(int ingredientId) async {
    await IngredientActions.incrementUsage(ingredientId);
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
  final String? detail;
  final double amount;
  final String unit;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final List<MealIngredientInput>? subIngredients;
  final String? ingredientImagePath;
  final String? ingredientArBoundingBox;
  final int? ingredientArImageWidth;
  final int? ingredientArImageHeight;

  MealIngredientInput({
    required this.name,
    this.nameEn,
    this.detail,
    required this.amount,
    required this.unit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.subIngredients,
    this.ingredientImagePath,
    this.ingredientArBoundingBox,
    this.ingredientArImageWidth,
    this.ingredientArImageHeight,
  });
}

// ===== TREE PROVIDER =====

/// ดึง ingredients ของ meal เป็น tree structure (ROOT + children)
final mealIngredientTreeProvider = FutureProvider.autoDispose
    .family<List<IngredientTreeNode>, int>((ref, mealId) async {
  final allIngredients = await (DatabaseService.db
              .select(DatabaseService.db.myMealIngredients)
            ..where((tbl) => tbl.myMealId.equals(mealId))
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.sortOrder)]))
        .get();

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

/// แปลง meal ingredient tree เป็น map สำหรับ `FoodEntry.ingredientsJson` (รวม sub_ingredients)
List<Map<String, dynamic>> ingredientTreeToJsonMaps(
    List<IngredientTreeNode> tree) {
  return tree.map((node) {
    final rootMap = <String, dynamic>{
      'name': node.ingredient.ingredientName,
      'amount': node.ingredient.amount,
      'unit': node.ingredient.unit,
      'calories': node.ingredient.calories,
      'protein': node.ingredient.protein,
      'carbs': node.ingredient.carbs,
      'fat': node.ingredient.fat,
    };
    final detail = node.ingredient.detail;
    if (detail != null && detail.isNotEmpty) {
      rootMap['detail'] = detail;
    }
    final rootImg = node.ingredient.ingredientImagePath;
    if (rootImg != null && rootImg.isNotEmpty) {
      rootMap['imagePath'] = rootImg;
    }
    final rootBbox = node.ingredient.ingredientArBoundingBox;
    if (rootBbox != null && rootBbox.isNotEmpty) {
      rootMap['arBoundingBox'] = rootBbox;
    }
    final rootW = node.ingredient.ingredientArImageWidth;
    if (rootW != null) rootMap['arImageWidth'] = rootW;
    final rootH = node.ingredient.ingredientArImageHeight;
    if (rootH != null) rootMap['arImageHeight'] = rootH;

    if (node.children.isNotEmpty) {
      rootMap['sub_ingredients'] = node.children.map((child) {
        final subMap = <String, dynamic>{
          'name': child.ingredientName,
          'amount': child.amount,
          'unit': child.unit,
          'calories': child.calories,
          'protein': child.protein,
          'carbs': child.carbs,
          'fat': child.fat,
        };
        if (child.detail != null && child.detail!.isNotEmpty) {
          subMap['detail'] = child.detail;
        }
        final cImg = child.ingredientImagePath;
        if (cImg != null && cImg.isNotEmpty) {
          subMap['imagePath'] = cImg;
        }
        final cBbox = child.ingredientArBoundingBox;
        if (cBbox != null && cBbox.isNotEmpty) {
          subMap['arBoundingBox'] = cBbox;
        }
        final cW = child.ingredientArImageWidth;
        if (cW != null) subMap['arImageWidth'] = cW;
        final cH = child.ingredientArImageHeight;
        if (cH != null) subMap['arImageHeight'] = cH;
        return subMap;
      }).toList();
    }
    return rootMap;
  }).toList();
}
