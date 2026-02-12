import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../../../core/database/database_service.dart';
import '../../../core/utils/logger.dart';
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
    String servingUnit = 'serving',
    List<String> excludeIngredients = const [],
  }) async {
    AppLogger.info('FoodLookup searching: "$foodName"');
    AppLogger.info('   - Serving: $servingSize $servingUnit');
    if (excludeIngredients.isNotEmpty) {
      AppLogger.info('   - Exclude: ${excludeIngredients.join(", ")}');
    }

    // ===== Step 1: ค้นหาจาก MyMeal =====
    final mealResult = await _searchMyMeal(foodName);
    if (mealResult != null) {
      AppLogger.info('Found in MyMeal: "${mealResult.name}" (id=${mealResult.id})');

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
      AppLogger.info('Found in Ingredient: "${ingredientResult.name}" (id=${ingredientResult.id})');

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
    AppLogger.info('Not found "$foodName" → using 0');

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
  /// ปรับให้ไม่ match substring เพื่อป้องกัน "beef" match กับ "beef burger"
  static Future<Ingredient?> _searchIngredient(String query) async {
    final all = await DatabaseService.ingredients.where().findAll();
    if (all.isEmpty) return null;

    final lowerQuery = query.toLowerCase().trim();

    // 1. Exact match
    for (final ing in all) {
      if (ing.name.toLowerCase() == lowerQuery) return ing;
    }

    // 2. Whole word match only (not substring)
    // "beef" should NOT match "beef burger"
    for (final ing in all) {
      final ingName = ing.name.toLowerCase();
      // Check if ingredient name exists as whole word in query
      final pattern = RegExp(r'\b' + RegExp.escape(ingName) + r'\b');
      if (pattern.hasMatch(lowerQuery) && ingName.length >= 3) {
        // Additional check: query should not be significantly longer
        // to avoid matching "beef" when query is "beef burger"
        if (lowerQuery.length <= ingName.length + 3) {
          return ing;
        }
      }
    }

    // 3. Fuzzy match (Levenshtein) - only if very close
    Ingredient? bestMatch;
    int bestDistance = 999;
    for (final ing in all) {
      final dist = _levenshtein(ing.name.toLowerCase(), lowerQuery);
      // Stricter threshold: max 2 characters difference
      if (dist < bestDistance && dist <= 2) {
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
