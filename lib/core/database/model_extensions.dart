import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'app_database.dart';
import 'database_service.dart';

// ============================================
// Type Aliases (backward compat with old Isar model names)
// ============================================
typedef FoodEntry = FoodEntryData;
typedef ChatMessage = ChatMessageData;
typedef ChatSession = ChatSessionData;
typedef UserProfile = UserProfileData;
typedef MyMeal = MyMealData;
typedef MyMealIngredient = MyMealIngredientData;
typedef Ingredient = IngredientData;
typedef DailySummary = DailySummaryData;
typedef EnergyTransaction = EnergyTransactionData;

// ============================================
// FoodEntryData extensions
// ============================================
extension FoodEntryExtensions on FoodEntryData {
  bool get hasLocalImage =>
      allImagePaths.any((p) => p.isNotEmpty && File(p).existsSync());

  bool get hasAnyImage =>
      (thumbnailUrl != null && thumbnailUrl!.isNotEmpty) ||
      allImagePaths.isNotEmpty;

  /// ลำดับรูปทั้งหมด — ถ้ามี [imagePathsJson] (กรณี >3 รูป) ใช้เป็นแหล่งหลัก
  List<String> get allImagePaths {
    final j = imagePathsJson;
    if (j != null && j.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(j);
        if (decoded is List && decoded.isNotEmpty) {
          final list = decoded
              .map((e) => e.toString())
              .where((s) => s.trim().isNotEmpty)
              .toList();
          if (list.isNotEmpty) return list;
        }
      } catch (_) {}
    }
    final paths = <String>[];
    if (imagePath != null && imagePath!.isNotEmpty) {
      paths.add(imagePath!);
    }
    if (supplementaryImagePath2 != null &&
        supplementaryImagePath2!.isNotEmpty) {
      paths.add(supplementaryImagePath2!);
    }
    if (supplementaryImagePath3 != null &&
        supplementaryImagePath3!.isNotEmpty) {
      paths.add(supplementaryImagePath3!);
    }
    return paths;
  }

  bool get isArScan => source == DataSource.arScan;

  bool get hasMultipleImages => allImagePaths.length > 1;

  bool get hasThumbnailUrl =>
      thumbnailUrl != null && thumbnailUrl!.isNotEmpty;

  bool get hasNutritionData => calories > 0 || protein > 0 || carbs > 0 || fat > 0;

  bool get hasBaseValues => baseCalories > 0;

  /// Backward compat: old Isar field was `sceneContextJson`, Drift column is `sceneContext`
  String? get sceneContextJson => sceneContext;
  set sceneContextJson(String? value) => sceneContext = value;

  void recalculateFromBase() {
    if (!hasBaseValues) return;
    calories = baseCalories * servingSize;
    protein = baseProtein * servingSize;
    carbs = baseCarbs * servingSize;
    fat = baseFat * servingSize;
  }
}

// ============================================
// MyMealData extensions
// ============================================
extension MyMealExtensions on MyMealData {
  /// Parse "1 plate" → 1.0
  double get parsedServingSize {
    final parts = baseServingDescription.trim().split(' ');
    if (parts.isNotEmpty) {
      return double.tryParse(parts[0]) ?? 1.0;
    }
    return 1.0;
  }

  /// Parse "1 plate" → "plate"
  String get parsedServingUnit {
    final parts = baseServingDescription.trim().split(' ');
    if (parts.length >= 2) {
      return parts.sublist(1).join(' ');
    }
    return 'serving';
  }

  double get caloriesPerUnit {
    final size = parsedServingSize;
    return size > 0 ? totalCalories / size : totalCalories;
  }

  double get proteinPerUnit {
    final size = parsedServingSize;
    return size > 0 ? totalProtein / size : totalProtein;
  }

  double get carbsPerUnit {
    final size = parsedServingSize;
    return size > 0 ? totalCarbs / size : totalCarbs;
  }

  double get fatPerUnit {
    final size = parsedServingSize;
    return size > 0 ? totalFat / size : totalFat;
  }

  bool get hasMealLocalImage =>
      imagePath != null &&
      imagePath!.isNotEmpty &&
      File(imagePath!).existsSync();

  bool get hasMealThumbnailUrl =>
      thumbnailUrl != null && thumbnailUrl!.trim().isNotEmpty;
}

// ============================================
// IngredientData extensions
// ============================================
extension IngredientExtensions on IngredientData {
  double calcCalories(double amount) =>
      baseAmount > 0 ? (caloriesPerBase / baseAmount) * amount : 0;
  double calcProtein(double amount) =>
      baseAmount > 0 ? (proteinPerBase / baseAmount) * amount : 0;
  double calcCarbs(double amount) =>
      baseAmount > 0 ? (carbsPerBase / baseAmount) * amount : 0;
  double calcFat(double amount) =>
      baseAmount > 0 ? (fatPerBase / baseAmount) * amount : 0;
}

/// Static helpers that were on old Isar Ingredient model.
/// Call as `IngredientActions.upsert(...)` instead of `Ingredient.upsert(...)`.
class IngredientActions {
  IngredientActions._();

  static Future<IngredientData> upsert({
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
    final existing = await (DatabaseService.db.select(DatabaseService.db.ingredients)
          ..where((tbl) => tbl.name.equals(name))
          ..limit(1))
        .getSingleOrNull();

    if (existing != null) {
      existing.nameEn = nameEn;
      existing.baseAmount = baseAmount;
      existing.baseUnit = baseUnit;
      existing.caloriesPerBase = calories;
      existing.proteinPerBase = protein;
      existing.carbsPerBase = carbs;
      existing.fatPerBase = fat;
      existing.usageCount = existing.usageCount + 1;
      existing.updatedAt = DateTime.now();
      await DatabaseService.db
          .into(DatabaseService.db.ingredients)
          .insertOnConflictUpdate(existing);
      return existing;
    }

    return await DatabaseService.db
        .into(DatabaseService.db.ingredients)
        .insertReturning(IngredientsCompanion.insert(
          name: name,
          baseAmount: baseAmount,
          baseUnit: baseUnit,
          caloriesPerBase: calories,
          proteinPerBase: protein,
          carbsPerBase: carbs,
          fatPerBase: fat,
          source: source,
          nameEn: Value(nameEn),
        ));
  }

  static Future<void> incrementUsage(int id) async {
    final ingredient = await (DatabaseService.db.select(DatabaseService.db.ingredients)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    if (ingredient != null) {
      ingredient.usageCount++;
      await DatabaseService.db
          .into(DatabaseService.db.ingredients)
          .insertOnConflictUpdate(ingredient);
    }
  }
}

// ============================================
// UserProfileData extensions
// ============================================
extension UserProfileExtensions on UserProfileData {
  double get safeBmr => customBmr > 0 ? customBmr : 1500;
}
