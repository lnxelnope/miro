import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ai/gemini_service.dart';
import '../services/thumbnail_service.dart';
import '../services/usage_limiter.dart';
import '../utils/logger.dart';
import '../constants/enums.dart';
import '../ar_scale/models/detected_object_label.dart';
import '../../features/health/models/food_entry.dart';
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
  /// ถ้ามี ingredientsDetail → ใช้ผลรวม ingredients เป็น total (แม่นยำกว่า AI total)
  static void applyResultToEntry(FoodEntry entry, FoodAnalysisResult result) {
    entry.foodName = result.foodName;
    entry.foodNameEn = result.foodNameEn;

    double cal = result.nutrition.calories;
    double prot = result.nutrition.protein;
    double carb = result.nutrition.carbs;
    double fa = result.nutrition.fat;

    // ถ้ามี ingredients detail → รวมจาก ROOT ingredients (แม่นยำกว่า AI total)
    if (result.ingredientsDetail != null &&
        result.ingredientsDetail!.isNotEmpty) {
      double sumCal = 0, sumP = 0, sumC = 0, sumF = 0;
      for (final ing in result.ingredientsDetail!) {
        sumCal += ing.calories;
        sumP += ing.protein;
        sumC += ing.carbs;
        sumF += ing.fat;
      }
      if (sumCal > 0) {
        cal = sumCal;
        prot = sumP;
        carb = sumC;
        fa = sumF;
        AppLogger.info(
            '[applyResult] Using ingredients sum ($sumCal kcal) instead of AI total (${result.nutrition.calories} kcal)');
      }
    }

    entry.calories = cal;
    entry.protein = prot;
    entry.carbs = carb;
    entry.fat = fa;
    entry.fiber = result.nutrition.fiber;
    entry.sugar = result.nutrition.sugar;
    entry.sodium = result.nutrition.sodium;
    entry.cholesterol = result.nutrition.cholesterol;
    entry.saturatedFat = result.nutrition.saturatedFat;
    entry.transFat = result.nutrition.transFat;
    entry.unsaturatedFat = result.nutrition.unsaturatedFat;
    entry.monounsaturatedFat = result.nutrition.monounsaturatedFat;
    entry.polyunsaturatedFat = result.nutrition.polyunsaturatedFat;
    entry.potassium = result.nutrition.potassium;

    final serving = result.servingSize > 0 ? result.servingSize : 1.0;
    entry.baseCalories = cal / serving;
    entry.baseProtein = prot / serving;
    entry.baseCarbs = carb / serving;
    entry.baseFat = fa / serving;
    entry.servingSize = result.servingSize;
    entry.servingUnit = result.servingUnit;
    entry.servingGrams = result.servingGrams?.toDouble();
    entry.source = DataSource.aiAnalyzed;
    entry.isVerified = true;
    entry.aiConfidence = result.confidence;

    // AR Scale calibration data
    entry.referenceObjectUsed = result.referenceObjectUsed;
    entry.referenceConfidence = result.referenceConfidence;
    entry.plateDiameterCm = result.plateDiameterCm;
    entry.estimatedVolumeMl = result.estimatedVolumeMl;
    entry.isCalibrated = result.isCalibrated;

    if (result.ingredientsDetail != null &&
        result.ingredientsDetail!.isNotEmpty) {
      entry.ingredientsJson = jsonEncode(
        result.ingredientsDetail!.map((item) => item.toJson()).toList(),
      );
    }
  }

  /// Auto-save meal + ingredients ไป database
  /// AI results จะ overwrite MyMeal ชื่อเดิมเสมอ (ไม่สร้างซ้ำ)
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
      final ingredientsData =
          result.ingredientsDetail!.map((e) => e.toJson()).toList();

      await ref
          .read(foodEntriesNotifierProvider.notifier)
          .saveIngredientsAndMeal(
            mealName: result.foodName,
            mealNameEn: result.foodNameEn,
            servingDescription: '${result.servingSize} ${result.servingUnit}',
            imagePath: entry.imagePath,
            ingredientsData: ingredientsData,
            overwriteIfExists: true,
          );

      ref.invalidate(allMyMealsProvider);
      ref.invalidate(allIngredientsProvider);
      AppLogger.info(
          '[AutoSave] Saved "${result.foodName}" + ${ingredientsData.length} ingredients');
    } catch (e) {
      AppLogger.warn('[AutoSave] Failed for "${result.foodName}": $e');
    }
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
              _uploadThumbnailInBackground(entry);
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
                _uploadThumbnailInBackground(entry);
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
          // สร้าง calibration hint จากข้อมูล AR ที่เก็บไว้ใน entry (ถ้ามี)
          final calibrationHint = _buildCalibrationHint(entry);

          final result = await GeminiService.analyzeFoodImage(
            File(entry.imagePath!),
            foodName: entry.foodName,
            quantity: entry.servingSize,
            unit: entry.servingUnit,
            searchMode: entry.searchMode,
            calibrationHint: calibrationHint,
          );

          if (result != null) {
            applyResultToEntry(entry, result);
            await ref
                .read(foodEntriesNotifierProvider.notifier)
                .updateFoodEntry(entry);
            await autoSaveToDatabase(ref, entry, result);
            await UsageLimiter.recordAiUsage();
            _uploadThumbnailInBackground(entry);
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

  /// สร้าง calibration hint string จาก FoodEntry ที่มีข้อมูล AR Scale
  static String? _buildCalibrationHint(FoodEntry entry) {
    final buffer = StringBuffer();

    // --- Part 1: Calibration data (ถ้ามี) ---
    final isCalibrated = entry.isCalibrated;
    final confidence = entry.referenceConfidence;

    if (isCalibrated && confidence != null && confidence >= 0.65) {
      final diameterCm = entry.plateDiameterCm;
      final volumeMl = entry.estimatedVolumeMl;
      final refType = entry.referenceObjectUsed;

      final confLabel = confidence >= 0.85
          ? 'HIGH confidence'
          : 'MEDIUM confidence (verify visually)';
      final confPct = (confidence * 100).toStringAsFixed(0);
      final refName = refType ?? 'reference object';

      buffer
        ..writeln('PHYSICAL CALIBRATION DATA ($confLabel):')
        ..writeln(
          'A $refName was detected in the image with $confPct% confidence.',
        );

      if (diameterCm != null) {
        buffer.writeln(
          'Measured plate/bowl diameter: ~${diameterCm.toStringAsFixed(1)} cm.',
        );
      }
      if (volumeMl != null) {
        buffer.writeln(
          'Estimated container volume: ~${volumeMl.toStringAsFixed(0)} ml.',
        );
      }

      buffer.writeln(
        'Use this measurement to estimate portion size more accurately.',
      );

      if (confidence < 0.85) {
        buffer.writeln(
          'Note: Medium confidence — cross-check with visual estimation.',
        );
      }
    }

    // --- Part 2: Object detection metadata (ทุก object ที่ detect ได้) ---
    final labels = DetectedObjectLabel.decode(entry.arLabelsJson);
    if (labels.isNotEmpty) {
      final pxPerCm = entry.arPixelPerCm;
      final imgW = entry.arImageWidth;
      final imgH = entry.arImageHeight;

      buffer.writeln('DETECTED OBJECTS IN IMAGE (${labels.length}):');
      if (imgW != null && imgH != null) {
        buffer.writeln(
          'Image dimensions: ${imgW.toInt()}x${imgH.toInt()} pixels.',
        );
      }

      for (final obj in labels) {
        final confPct = (obj.confidence * 100).toStringAsFixed(0);
        if (pxPerCm != null && pxPerCm > 0) {
          final wCm = (obj.bboxWidth / pxPerCm).toStringAsFixed(1);
          final hCm = (obj.bboxHeight / pxPerCm).toStringAsFixed(1);
          buffer.writeln(
            '- ${obj.label} ($confPct%): $wCm×$hCm cm '
            'at position (${obj.centerX.toInt()}, ${obj.centerY.toInt()}) px',
          );
        } else {
          buffer.writeln(
            '- ${obj.label} ($confPct%): ${obj.bboxWidth.toInt()}×${obj.bboxHeight.toInt()} px '
            'at position (${obj.centerX.toInt()}, ${obj.centerY.toInt()}) px',
          );
        }
      }
      buffer.writeln(
        'Use these object sizes and positions to better estimate food portion sizes.',
      );
    }

    final result = buffer.toString().trim();
    return result.isEmpty ? null : result;
  }

  /// Fire-and-forget thumbnail upload (non-blocking, non-fatal).
  static void _uploadThumbnailInBackground(FoodEntry entry) {
    if (!entry.hasLocalImage) return;
    ThumbnailService.uploadThumbnail(
      entry: entry,
      imageFile: File(entry.imagePath!),
    );
  }
}
