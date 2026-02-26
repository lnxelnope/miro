import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../ai/gemini_service.dart';
import '../database/database_service.dart';
import '../services/usage_limiter.dart';
import '../utils/logger.dart';
import '../constants/enums.dart';
import '../../features/health/models/food_entry.dart';
import '../../features/health/models/my_meal.dart';
import '../../features/health/providers/health_provider.dart';
import '../../features/health/providers/my_meal_provider.dart';
import '../../features/energy/providers/energy_provider.dart';

class BatchAnalysisResult {
  final int successCount;
  final int failedCount;
  final bool wasCancelled;

  BatchAnalysisResult({
    required this.successCount,
    required this.failedCount,
    required this.wasCancelled,
  });
}

class BatchAnalysisHelper {
  static const int _batchSize = 5;

  /// ตรวจสอบ energy ก่อน analyze
  /// return true ถ้าพอใช้
  static Future<bool> checkEnergy(Ref ref, int requiredEnergy) async {
    final energyService = GeminiService.energyService;
    if (energyService != null) {
      final isFirstFree = await energyService.isFirstFreeAnalysisAvailable();
      if (isFirstFree) {
        await energyService.grantFirstFreeAnalysis(requiredEnergy);
        ref.invalidate(energyBalanceProvider);
        ref.invalidate(currentEnergyProvider);
      }
    }

    final energyAsync = ref.read(energyBalanceProvider);
    final currentBalance = energyAsync.valueOrNull ?? 0;
    return currentBalance >= requiredEnergy;
  }

  /// Extract ingredient data จาก FoodEntry
  static ({List<String>? names, List<Map<String, dynamic>>? userIngredients})
      extractIngredientsFromJson(FoodEntry entry) {
    if (entry.ingredientsJson == null || entry.ingredientsJson!.isEmpty) {
      return (names: null, userIngredients: null);
    }
    try {
      final decoded = jsonDecode(entry.ingredientsJson!) as List<dynamic>;
      final names = decoded
          .map((item) => item['name'] as String?)
          .where((name) => name != null && name.isNotEmpty)
          .cast<String>()
          .toList();

      final userIngredients = decoded
          .where((item) =>
              item['name'] != null &&
              item['amount'] != null &&
              (item['amount'] as num) > 0)
          .map((item) => <String, dynamic>{
                'name': item['name'] as String,
                'amount': (item['amount'] as num).toDouble(),
                'unit': item['unit'] as String? ?? 'g',
              })
          .toList();

      return (
        names: names.isNotEmpty ? names : null,
        userIngredients: userIngredients.isNotEmpty ? userIngredients : null,
      );
    } catch (err) {
      AppLogger.warn('[extractIngredientsFromJson] Failed: $err');
      return (names: null, userIngredients: null);
    }
  }

  /// Apply AI result ไปที่ FoodEntry
  static void applyResultToEntry(FoodEntry entry, FoodAnalysisResult result) {
    entry.foodName = result.foodName;
    entry.foodNameEn = result.foodNameEn;
    entry.calories = result.nutrition.calories;
    entry.protein = result.nutrition.protein;
    entry.carbs = result.nutrition.carbs;
    entry.fat = result.nutrition.fat;
    entry.fiber = result.nutrition.fiber;
    entry.sugar = result.nutrition.sugar;
    entry.sodium = result.nutrition.sodium;

    final serving = result.servingSize > 0 ? result.servingSize : 1.0;
    entry.baseCalories = result.nutrition.calories / serving;
    entry.baseProtein = result.nutrition.protein / serving;
    entry.baseCarbs = result.nutrition.carbs / serving;
    entry.baseFat = result.nutrition.fat / serving;
    entry.servingSize = result.servingSize;
    entry.servingUnit = result.servingUnit;
    entry.servingGrams = result.servingGrams?.toDouble();
    entry.source = DataSource.aiAnalyzed;
    entry.isVerified = true;
    entry.aiConfidence = result.confidence;

    if (result.ingredientsDetail != null &&
        result.ingredientsDetail!.isNotEmpty) {
      entry.ingredientsJson = jsonEncode(
        result.ingredientsDetail!.map((item) => item.toJson()).toList(),
      );
    }
  }

  /// Auto-save meal + ingredients ไป database
  static Future<void> autoSaveToDatabase(
    Ref ref,
    FoodEntry entry,
    FoodAnalysisResult result,
  ) async {
    if (result.ingredientsDetail == null ||
        result.ingredientsDetail!.isEmpty) {
      return;
    }

    try {
      final all = await DatabaseService.myMeals.where().findAll();
      final uniqueName = _getUniqueMealName(result.foodName, all);

      final ingredientsData =
          result.ingredientsDetail!.map((e) => e.toJson()).toList();

      await ref
          .read(foodEntriesNotifierProvider.notifier)
          .saveIngredientsAndMeal(
            mealName: uniqueName,
            mealNameEn: result.foodNameEn,
            servingDescription: '${result.servingSize} ${result.servingUnit}',
            imagePath: entry.imagePath,
            ingredientsData: ingredientsData,
          );

      ref.invalidate(allMyMealsProvider);
      ref.invalidate(allIngredientsProvider);
      AppLogger.info(
          '[AutoSave] Saved "$uniqueName" + ${ingredientsData.length} ingredients');
    } catch (e) {
      AppLogger.warn('[AutoSave] Failed for "${result.foodName}": $e');
    }
  }

  static String _getUniqueMealName(String baseName, List<MyMeal> allMeals) {
    final names = allMeals.map((m) => m.name).toSet();
    if (!names.contains(baseName)) return baseName;

    int counter = 2;
    while (names.contains('$baseName ($counter)')) {
      counter++;
    }
    return '$baseName ($counter)';
  }

  /// Analyze รายการที่เลือก (ใช้ได้ทั้ง analyze all และ analyze selected)
  /// [onProgress] callback: (currentIndex, totalCount, currentItemName)
  /// [shouldCancel] callback: return true เพื่อยกเลิก
  static Future<BatchAnalysisResult> analyzeEntries({
    required Ref ref,
    required List<FoodEntry> entries,
    required DateTime selectedDate,
    required void Function(int current, int total, String itemName) onProgress,
    required bool Function() shouldCancel,
  }) async {
    int totalSuccessCount = 0;
    List<int> failedIds = [];
    var entriesToProcess = entries;

    while (entriesToProcess.isNotEmpty && !shouldCancel()) {
      int batchSuccessCount = 0;

      final textEntries = entriesToProcess
          .where((e) => e.imagePath == null || e.imagePath!.isEmpty)
          .toList();
      final imageEntries = entriesToProcess
          .where((e) => e.imagePath != null && e.imagePath!.isNotEmpty)
          .toList();

      // Process text entries in batches of 5
      for (int chunkStart = 0;
          chunkStart < textEntries.length;
          chunkStart += _batchSize) {
        if (shouldCancel()) break;

        final chunkEnd =
            (chunkStart + _batchSize).clamp(0, textEntries.length);
        final chunk = textEntries.sublist(chunkStart, chunkEnd);

        onProgress(
          totalSuccessCount + batchSuccessCount + failedIds.length + 1,
          entries.length,
          '${chunk.length} items',
        );

        try {
          final batchItems = chunk.map((e) {
            final extracted = extractIngredientsFromJson(e);
            return (
              name: e.foodName,
              servingSize: e.servingSize as double?,
              servingUnit: e.servingUnit as String?,
              searchMode: e.searchMode,
              ingredientNames: extracted.names,
              userIngredients: extracted.userIngredients,
            );
          }).toList();

          final results = await GeminiService.analyzeFoodBatch(batchItems);

          for (int i = 0; i < chunk.length; i++) {
            final entry = chunk[i];
            var result = i < results.length ? results[i] : null;

            if (result != null && result.confidence > 0) {
              final userIngs = batchItems[i].userIngredients;
              if (userIngs != null && userIngs.isNotEmpty) {
                result = GeminiService.enforceUserIngredientAmounts(
                    result, userIngs);
              }
              applyResultToEntry(entry, result);
              await ref
                  .read(foodEntriesNotifierProvider.notifier)
                  .updateFoodEntry(entry);
              await autoSaveToDatabase(ref, entry, result);
              await UsageLimiter.recordAiUsage();
              batchSuccessCount++;
            } else {
              failedIds.add(entry.id);
            }
          }
        } catch (e) {
          AppLogger.error('[BatchAnalyze] Batch failed, falling back', e);
          for (final entry in chunk) {
            if (shouldCancel()) break;
            try {
              onProgress(
                totalSuccessCount + batchSuccessCount + failedIds.length + 1,
                entries.length,
                entry.foodName,
              );

              final extracted = extractIngredientsFromJson(entry);
              var result = await GeminiService.analyzeFoodByName(
                entry.foodName,
                servingSize: entry.servingSize,
                servingUnit: entry.servingUnit,
                searchMode: entry.searchMode,
                ingredientNames: extracted.names,
                userIngredients: extracted.userIngredients,
              );
              if (result != null) {
                if (extracted.userIngredients != null &&
                    extracted.userIngredients!.isNotEmpty) {
                  result = GeminiService.enforceUserIngredientAmounts(
                      result, extracted.userIngredients!);
                }
                applyResultToEntry(entry, result);
                await ref
                    .read(foodEntriesNotifierProvider.notifier)
                    .updateFoodEntry(entry);
                await autoSaveToDatabase(ref, entry, result);
                await UsageLimiter.recordAiUsage();
                batchSuccessCount++;
              } else {
                failedIds.add(entry.id);
              }
            } catch (e2) {
              AppLogger.error('[BatchAnalyze] Individual failed', e2);
              failedIds.add(entry.id);
            }
            await Future.delayed(const Duration(milliseconds: 300));
          }
        }

        if (chunkStart + _batchSize < textEntries.length) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      // Process image entries one-by-one
      for (int i = 0; i < imageEntries.length; i++) {
        if (shouldCancel()) break;

        final entry = imageEntries[i];
        onProgress(
          totalSuccessCount + batchSuccessCount + failedIds.length + 1,
          entries.length,
          entry.foodName,
        );

        try {
          final result = await GeminiService.analyzeFoodImage(
            File(entry.imagePath!),
            foodName: entry.foodName,
            quantity: entry.servingSize,
            unit: entry.servingUnit,
            searchMode: entry.searchMode,
          );

          if (result != null) {
            applyResultToEntry(entry, result);
            await ref
                .read(foodEntriesNotifierProvider.notifier)
                .updateFoodEntry(entry);
            await autoSaveToDatabase(ref, entry, result);
            await UsageLimiter.recordAiUsage();
            batchSuccessCount++;
          } else {
            failedIds.add(entry.id);
          }
        } catch (e) {
          AppLogger.error('[BatchAnalyze] Image failed', e);
          failedIds.add(entry.id);
        }

        if (i < imageEntries.length - 1) {
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }

      totalSuccessCount += batchSuccessCount;

      // Refresh providers — invalidate foodEntriesByDate first so healthTimeline gets fresh DB data
      final d = dateOnly(selectedDate);
      ref.invalidate(foodEntriesByDateProvider(d));
      ref.invalidate(healthTimelineProvider(d));
      ref.invalidate(todayCaloriesProvider);
      ref.invalidate(todayMacrosProvider);

      if (shouldCancel()) break;

      // Check for new unanalyzed entries
      try {
        final refreshed =
            await ref.read(foodEntriesByDateProvider(d).future);
        entriesToProcess = refreshed
            .where(
                (f) => !f.hasNutritionData && !failedIds.contains(f.id))
            .toList();

        if (entriesToProcess.isNotEmpty) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      } catch (e) {
        break;
      }
    }

    // Final refresh so UI shows results immediately when analyze completes
    final d = dateOnly(selectedDate);
    ref.invalidate(foodEntriesByDateProvider(d));
    ref.invalidate(healthTimelineProvider(d));
    ref.invalidate(todayCaloriesProvider);
    ref.invalidate(todayMacrosProvider);

    return BatchAnalysisResult(
      successCount: totalSuccessCount,
      failedCount: failedIds.length,
      wasCancelled: shouldCancel(),
    );
  }
}
