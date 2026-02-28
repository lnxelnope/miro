import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/database/database_service.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/health_sync_service.dart';
import '../../../core/services/rating_service.dart';
import '../../../core/ai/gemini_service.dart';
import '../../../core/utils/logger.dart';
import '../../../core/constants/enums.dart';
import '../models/food_entry.dart';
import '../../profile/models/user_profile.dart';
import '../../profile/providers/profile_provider.dart';
import 'my_meal_provider.dart';

// ===== DATE HELPER =====
/// Normalize DateTime to date-only (midnight) for consistent provider keys.
/// Without this, DateTime.now() at different times would create different
/// provider instances in FutureProvider.family, causing refresh failures.
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

// ===== FOOD ENTRIES =====

// Get food entries for a specific date
final foodEntriesByDateProvider =
    FutureProvider.family<List<FoodEntry>, DateTime>((ref, date) async {
  final startOfDay = DateTime(date.year, date.month, date.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  return await DatabaseService.foodEntries
      .filter()
      .timestampBetween(startOfDay, endOfDay)
      .isDeletedEqualTo(false) // ไม่แสดงรายการที่ถูกลบ
      .sortByTimestampDesc()
      .findAll();
});

// Get today's total calories
final todayCaloriesProvider = FutureProvider<double>((ref) async {
  final today = dateOnly(DateTime.now());
  final entries = await ref.watch(foodEntriesByDateProvider(today).future);
  return entries.fold<double>(0, (sum, entry) => sum + entry.calories);
});

/// Active Energy burned today (kcal). Returns 0 if health sync is off.
/// Uses TCB − BMR (prorated) when ACTIVE_ENERGY_BURNED is unavailable.
/// Watches profileNotifierProvider so it recalculates when BMR changes.
final activeEnergyProvider = FutureProvider<double>((ref) async {
  try {
    final profileAsync = ref.watch(profileNotifierProvider);
    final profile = profileAsync.valueOrNull;
    if (profile == null || !profile.isHealthConnectConnected) return 0;

    return await HealthSyncService.getTodayActiveEnergy(
        bmr: profile.safeBmr);
  } catch (_) {
    return 0;
  }
});

/// Effective calorie goal = base goal + active energy (if health sync is on).
final effectiveCalorieGoalProvider = FutureProvider<double>((ref) async {
  final profileAsync = ref.watch(profileNotifierProvider);
  final profile = profileAsync.valueOrNull;
  final baseGoal = profile?.calorieGoal ?? 2000;

  if (profile != null && profile.isHealthConnectConnected) {
    final activeEnergy = await ref.watch(activeEnergyProvider.future);
    return baseGoal + activeEnergy;
  }

  return baseGoal;
});

// Get today's macros
final todayMacrosProvider = FutureProvider<Map<String, double>>((ref) async {
  final today = dateOnly(DateTime.now());
  final entries = await ref.watch(foodEntriesByDateProvider(today).future);

  double protein = 0, carbs = 0, fat = 0;
  for (final entry in entries) {
    protein += entry.protein;
    carbs += entry.carbs;
    fat += entry.fat;
  }

  return {
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
  };
});

// ===== FOOD TIMELINE (food only) =====

class TimelineItem {
  final String type; // 'food'
  final DateTime timestamp;
  final dynamic data;

  TimelineItem({
    required this.type,
    required this.timestamp,
    required this.data,
  });
}

final healthTimelineProvider =
    FutureProvider.family<List<TimelineItem>, DateTime>((ref, date) async {
  final foods = await ref.watch(foodEntriesByDateProvider(date).future);

  final items = <TimelineItem>[];

  for (final food in foods) {
    items
        .add(TimelineItem(type: 'food', timestamp: food.timestamp, data: food));
  }

  // Sort by timestamp descending
  items.sort((a, b) => b.timestamp.compareTo(a.timestamp));

  return items;
});

// ===== NOTIFIERS FOR ADDING DATA =====

class FoodEntriesNotifier extends StateNotifier<AsyncValue<List<FoodEntry>>> {
  FoodEntriesNotifier() : super(const AsyncValue.loading());

  Future<bool> _isHealthSyncEnabled() async {
    try {
      final profiles = await DatabaseService.userProfiles
          .filter()
          .idGreaterThan(0)
          .findFirst();
      return profiles?.isHealthConnectConnected ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> addFoodEntry(FoodEntry entry) async {
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.foodEntries.put(entry);
    });
    AnalyticsService.logMealLogged(source: entry.source.name);

    if (await _isHealthSyncEnabled()) {
      _syncEntryToHealth(entry);
    }

    // Check meal-count milestones for native review prompt
    final totalMeals = await DatabaseService.foodEntries
        .filter()
        .isDeletedEqualTo(false)
        .count();
    RatingService.checkMealMilestone(totalMeals);
  }

  Future<void> updateFoodEntry(FoodEntry entry) async {
    entry.updatedAt = DateTime.now();
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.foodEntries.put(entry);
    });

    if (await _isHealthSyncEnabled()) {
      _syncEntryToHealth(entry, oldSyncKey: entry.healthConnectId);
    }
  }

  Future<void> deleteFoodEntry(int id) async {
    try {
      final entry = await DatabaseService.foodEntries.get(id);
      if (entry == null) {
        AppLogger.warn('FoodEntry not found id=$id');
        throw Exception('Entry not found');
      }

      // Delete from Health App first (if synced)
      if (await _isHealthSyncEnabled() &&
          entry.healthConnectId != null &&
          entry.healthConnectId!.isNotEmpty) {
        await HealthSyncService.deleteFoodEntry(
            healthSyncKey: entry.healthConnectId!);
      }

      entry.isDeleted = true;
      entry.updatedAt = DateTime.now();

      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.foodEntries.put(entry);
      });

      AppLogger.info(
          'FoodEntry soft deleted: id=$id, name="${entry.foodName}", imagePath="${entry.imagePath}"');
    } catch (e, stackTrace) {
      AppLogger.error('Error deleting FoodEntry id=$id', e, stackTrace);
      rethrow;
    }
  }

  /// Fire-and-forget sync to Health App.
  Future<void> _syncEntryToHealth(FoodEntry entry, {String? oldSyncKey}) async {
    try {
      final syncKey = await HealthSyncService.updateFoodEntry(
        oldHealthSyncKey: oldSyncKey,
        name: entry.foodName,
        calories: entry.calories,
        protein: entry.protein,
        carbs: entry.carbs,
        fat: entry.fat,
        timestamp: entry.timestamp,
        mealType: entry.mealType,
        fiber: entry.fiber,
        sugar: entry.sugar,
        sodium: entry.sodium,
        cholesterol: entry.cholesterol,
        saturatedFat: entry.saturatedFat,
        transFat: entry.transFat,
        unsaturatedFat: entry.unsaturatedFat,
        monounsaturatedFat: entry.monounsaturatedFat,
        polyunsaturatedFat: entry.polyunsaturatedFat,
        potassium: entry.potassium,
      );

      if (syncKey != null) {
        entry.healthConnectId = syncKey;
        entry.syncedAt = DateTime.now();
        await DatabaseService.isar.writeTxn(() async {
          await DatabaseService.foodEntries.put(entry);
        });
      }
    } catch (e) {
      AppLogger.warn('Health sync failed for "${entry.foodName}"', e);
    }
  }

  /// Analyze food image with Gemini - return result for UI to display
  Future<FoodAnalysisResult?> analyzeImage(
    File imageFile, {
    String? foodName,
    double? quantity,
    String? unit,
  }) async {
    AppLogger.info('[FoodEntriesNotifier] Analyzing image with Gemini...');

    try {
      final result = await GeminiService.analyzeFoodImage(
        imageFile,
        foodName: foodName,
        quantity: quantity,
        unit: unit,
      );

      if (result == null) {
        throw Exception('Unable to analyze image');
      }

      AppLogger.info('Got result:');
      AppLogger.info('   - Name: ${result.foodName}');
      AppLogger.info('   - Calories: ${result.nutrition.calories} kcal');

      return result;
    } catch (e, stackTrace) {
      AppLogger.error('Error', e, stackTrace);
      rethrow;
    }
  }

  /// Update FoodEntry after user confirms Gemini result
  Future<void> updateFromGeminiConfirmed(
    int entryId, {
    required String foodName,
    String? foodNameEn,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    required double baseCalories,
    required double baseProtein,
    required double baseCarbs,
    required double baseFat,
    required double servingSize,
    required String servingUnit,
    double? servingGrams,
    double? confidence,
    double? fiber,
    double? sugar,
    double? sodium,
    double? cholesterol,
    double? saturatedFat,
    double? transFat,
    double? unsaturatedFat,
    double? monounsaturatedFat,
    double? polyunsaturatedFat,
    double? potassium,
    String? notes,
    String? ingredientsJson,
  }) async {
    final entry = await DatabaseService.foodEntries.get(entryId);
    if (entry == null) {
      throw Exception('Food entry not found');
    }

    entry.foodName = foodName;
    entry.foodNameEn = foodNameEn;
    entry.calories = calories;
    entry.protein = protein;
    entry.carbs = carbs;
    entry.fat = fat;
    entry.baseCalories = baseCalories;
    entry.baseProtein = baseProtein;
    entry.baseCarbs = baseCarbs;
    entry.baseFat = baseFat;
    entry.servingSize = servingSize;
    entry.servingUnit = servingUnit;
    entry.servingGrams = servingGrams;
    entry.fiber = fiber;
    entry.sugar = sugar;
    entry.sodium = sodium;
    entry.cholesterol = cholesterol;
    entry.saturatedFat = saturatedFat;
    entry.transFat = transFat;
    entry.unsaturatedFat = unsaturatedFat;
    entry.monounsaturatedFat = monounsaturatedFat;
    entry.polyunsaturatedFat = polyunsaturatedFat;
    entry.potassium = potassium;
    entry.source = DataSource.aiAnalyzed;
    entry.aiConfidence = confidence;
    entry.isVerified = true;
    entry.notes = notes ?? 'Analyzed by Gemini 2.0 Flash';
    entry.ingredientsJson = ingredientsJson;
    entry.updatedAt = DateTime.now();

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.foodEntries.put(entry);
    });

    AppLogger.info('FoodEntry updated successfully: id=$entryId');
  }

  /// Save ingredients + meal from Gemini result
  /// [overwriteIfExists] = true → ถ้ามี MyMeal ชื่อเดียวกัน จะ overwrite ทับ
  ///                        false → ถ้าชื่อซ้ำจะสร้างใหม่ด้วยชื่อไม่ซ้ำ (append number)
  Future<void> saveIngredientsAndMeal({
    required String mealName,
    String? mealNameEn,
    required String servingDescription,
    String? imagePath,
    required List<Map<String, dynamic>> ingredientsData,
    String source = 'gemini',
    bool overwriteIfExists = false,
  }) async {
    try {
      final notifier = MyMealNotifier();

      MealIngredientInput parseIngredient(Map<String, dynamic> data) {
        List<MealIngredientInput>? subs;
        final subList = data['sub_ingredients'] as List<dynamic>?;
        if (subList != null && subList.isNotEmpty) {
          subs = subList
              .map((s) => parseIngredient(s as Map<String, dynamic>))
              .toList();
        }

        return MealIngredientInput(
          name: data['name'] as String,
          nameEn: data['name_en'] as String?,
          detail: data['detail'] as String?,
          amount: (data['amount'] as num).toDouble(),
          unit: data['unit'] as String,
          calories: (data['calories'] as num).toDouble(),
          protein: (data['protein'] as num).toDouble(),
          carbs: (data['carbs'] as num).toDouble(),
          fat: (data['fat'] as num).toDouble(),
          subIngredients: subs,
        );
      }

      final inputs =
          ingredientsData.map((data) => parseIngredient(data)).toList();

      if (overwriteIfExists) {
        final allMeals = await DatabaseService.myMeals.where().findAll();
        final existing = allMeals
            .where((m) => m.name.toLowerCase() == mealName.toLowerCase())
            .firstOrNull;

        if (existing != null) {
          await notifier.updateMeal(
            mealId: existing.id,
            name: mealName,
            nameEn: mealNameEn,
            baseServingDescription: servingDescription,
            imagePath: imagePath,
            ingredients: inputs,
          );
          AppLogger.info(
              'Overwritten existing MyMeal: $mealName (id=${existing.id}) + ${inputs.length} ROOT ingredients');
          return;
        }
      }

      await notifier.createMeal(
        name: mealName,
        nameEn: mealNameEn,
        baseServingDescription: servingDescription,
        imagePath: imagePath,
        ingredients: inputs,
        source: source,
      );
      AppLogger.info(
          'Auto-saved meal: $mealName (source=$source) + ${inputs.length} ROOT ingredients');
    } catch (e) {
      AppLogger.warn('Failed to auto-save', e);
    }
  }

  /// Legacy method - kept for backward compatibility
  Future<void> analyzeAndUpdateFoodEntry(int entryId, File imageFile) async {
    final result = await analyzeImage(imageFile);
    if (result == null) return;

    final geminiServing = result.servingSize > 0 ? result.servingSize : 1.0;

    await updateFromGeminiConfirmed(
      entryId,
      foodName: result.foodName,
      foodNameEn: result.foodNameEn,
      calories: result.nutrition.calories,
      protein: result.nutrition.protein,
      carbs: result.nutrition.carbs,
      fat: result.nutrition.fat,
      baseCalories: result.nutrition.calories / geminiServing,
      baseProtein: result.nutrition.protein / geminiServing,
      baseCarbs: result.nutrition.carbs / geminiServing,
      baseFat: result.nutrition.fat / geminiServing,
      servingSize: result.servingSize,
      servingUnit: result.servingUnit,
      servingGrams: result.servingGrams?.toDouble(),
      confidence: result.confidence,
      fiber: result.nutrition.fiber,
      sugar: result.nutrition.sugar,
      sodium: result.nutrition.sodium,
      notes: result.notes,
    );
  }
}

final foodEntriesNotifierProvider =
    StateNotifierProvider<FoodEntriesNotifier, AsyncValue<List<FoodEntry>>>(
        (ref) {
  return FoodEntriesNotifier();
});

// ===== HELPER: Refresh providers for a date =====
/// Call when food data changes to refresh UI.
/// Normalizes date to date-only to match provider keys consistently.
void refreshFoodProviders(WidgetRef ref, DateTime date) {
  final d = dateOnly(date);
  ref.invalidate(healthTimelineProvider(d));
  ref.invalidate(foodEntriesByDateProvider(d));
  ref.invalidate(todayCaloriesProvider);
  ref.invalidate(todayMacrosProvider);
}
