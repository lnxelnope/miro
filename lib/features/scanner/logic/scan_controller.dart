import 'dart:ui' as ui;

import 'package:drift/drift.dart' hide JsonKey, Column;
import '../../../core/database/app_database.dart';
import '../../../core/database/database_service.dart';
import 'package:miro_hybrid/features/scanner/services/gallery_service.dart';
import 'package:miro_hybrid/features/scanner/services/vision_processor.dart';
import 'package:miro_hybrid/features/scanner/services/qr_parser.dart';
import 'package:miro_hybrid/core/utils/logger.dart';
import 'package:miro_hybrid/core/constants/enums.dart';
import 'package:miro_hybrid/core/ar_scale/ar_scale.dart';

class ScanController {
  final GalleryService _galleryService;
  final VisionProcessor _visionProcessor;
  final QRParser _qrParser;

  ScanController(
    this._galleryService,
    this._visionProcessor,
    this._qrParser,
  );

  /// กำหนดมื้ออาหารตามเวลา
  MealType _getMealTypeFromTime(DateTime time) {
    final hour = time.hour;
    if (hour >= 5 && hour < 11) {
      return MealType.breakfast;
    } else if (hour >= 11 && hour < 15) {
      return MealType.lunch;
    } else if (hour >= 15 && hour < 21) {
      return MealType.dinner;
    } else {
      return MealType.snack;
    }
  }

  Future<int> scanNewImages({DateTime? after, DateTime? specificDate}) async {
    if (specificDate != null) {
      AppLogger.info('Starting scan for images on specific date: ${specificDate.toString()}');
    } else {
      AppLogger.info(
          'Starting scan for new images... ${after != null ? "after: ${after.toString()}" : "all"}');
    }

    final images = await _galleryService.fetchNewImages(
      after: after,
      specificDate: specificDate,
    );
    AppLogger.info('Found images: ${images.length}');

    if (images.isEmpty) {
      AppLogger.info('No new images found - ending scan');
      return 0;
    }

    int processedCount = 0;
    int savedCount = 0;
    int skippedDuplicate = 0;

    for (var asset in images) {
      processedCount++;
      AppLogger.info('Processing image $processedCount/${images.length}...');

      final file = await _galleryService.getFile(asset);
      if (file == null) {
        AppLogger.warn('Cannot load image file - skipping');
        continue;
      }

      // ⭐ เช็คว่ารูปนี้เคยถูกสแกนมาก่อนหรือไม่ (ไม่ว่าจะลบแล้วหรือยัง)
      // ถ้าเคยสแกน → skip เสมอ ป้องกันรูปที่ผู้ใช้ลบแล้วกลับมาหลัง refresh
      final existingEntry = await (DatabaseService.db.select(DatabaseService.db.foodEntries)
          ..where((tbl) => tbl.imagePath.equals(file.path)))
          .getSingleOrNull();

      if (existingEntry != null) {
        AppLogger.info(
            'Image already scanned - skipping (ID: ${existingEntry.id}, deleted: ${existingEntry.isDeleted}, path: ${file.path})');
        skippedDuplicate++;
        continue;
      }
      
      AppLogger.info('Image not in database - processing (path: ${file.path})');

      final result = await _visionProcessor.processImage(file);
      if (result == null) {
        AppLogger.info('Image not relevant (not food/receipt) - skipping');
        continue; // Ignore irrelevant images
      }

      AppLogger.info('Found data! Type: ${result['type']}');

      if (result['type'] == 'health') {
        final allLabels = result['all_labels'] as List<String>? ?? [];

        // AR Scale: detect objects + calibrate
        CalibrationResult? arCalibration;
        List<DetectedObjectLabel> objectLabels = [];
        double imgW = 0, imgH = 0;
        try {
          final detector = ReferenceDetectorService.instance;

          final imgBytes = await file.readAsBytes();
          final codec = await ui.instantiateImageCodec(imgBytes);
          final frame = await codec.getNextFrame();
          imgW = frame.image.width.toDouble();
          imgH = frame.image.height.toDouble();
          frame.image.dispose();

          final detected = await detector.detectFromImage(file);
          if (detected.isNotEmpty) {
            final plate = await detector.detectPlate(file);
            arCalibration = ScaleCalibrationService.calibrate(
              referenceObject: detected.first,
              plateBoundingBox: plate?.boundingBox,
              imageWidth: imgW,
              imageHeight: imgH,
            );
          }

          objectLabels = await detector.detectAllObjectLabels(file);
          if (objectLabels.isNotEmpty) {
            AppLogger.info(
              '[AR] Gallery scan: ${objectLabels.length} labels, '
              'calibration=${arCalibration != null}',
            );
          }
        } catch (e) {
          AppLogger.warn('[AR] Gallery scan detection error: $e');
        }

        await _saveFoodEntry(
          imagePath: file.path,
          timestamp: asset.createDateTime,
          label: result['label'] as String? ?? 'Food',
          allLabels: allLabels,
          arCalibration: arCalibration,
          arObjectLabels: objectLabels,
          arImageWidth: imgW > 0 ? imgW : null,
          arImageHeight: imgH > 0 ? imgH : null,
        );
        savedCount++;
        AppLogger.info('FoodEntry saved successfully!');
      }

      AppLogger.info('Saved successfully! ($savedCount/${images.length})');
    }

    AppLogger.info(
        'Scan complete! Processed: $processedCount images, Saved: $savedCount entries, Skipped duplicates: $skippedDuplicate');
    return savedCount;
  }

  Future<void> _saveFoodEntry({
    required String imagePath,
    required DateTime timestamp,
    required String label,
    List<String> allLabels = const [],
    CalibrationResult? arCalibration,
    List<DetectedObjectLabel> arObjectLabels = const [],
    double? arImageWidth,
    double? arImageHeight,
  }) async {
    AppLogger.info('Creating FoodEntry...');
    AppLogger.info('Label: $label');
    AppLogger.info('All Labels: ${allLabels.join(", ")}');

    // Determine meal type based on time
    final mealType = _getMealTypeFromTime(timestamp);
    AppLogger.info('Meal type: ${mealType.displayName}');

    // Skip generic labels - don't search database for these
    final commonLabels = ['Food', 'Meal', 'Dish', 'Cuisine'];
    final isCommonLabel = commonLabels.contains(label);

    if (isCommonLabel) {
      AppLogger.warn('Label is generic ("$label") - using as-is');
    }

    // ⭐ ไม่ใช้ Global Food Database แล้ว - ให้บันทึกชื่อ label ที่ได้มา
    // My Meal และ Ingredient จะถูกค้นหาในขั้นตอนอื่นแทน
    double calories = 0;
    double protein = 0;
    double carbs = 0;
    double fat = 0;

    double servingSize = 1.0;
    String servingUnit = 'serving';
    double? servingGrams;

    // ถ้าเป็น label ทั่วไป ให้ใช้ "Food" เป็นชื่อ
    final displayName = isCommonLabel ? 'Food' : label;
    final displayNameEn = isCommonLabel ? 'Food' : label;

    AppLogger.info('Saving entry with name: $displayName (from label: $label)');

    final entry = await DatabaseService.db.into(DatabaseService.db.foodEntries).insertReturning(FoodEntriesCompanion.insert(
      foodName: displayName,
      timestamp: timestamp,
      mealType: mealType,
      servingSize: servingSize,
      servingUnit: servingUnit,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      source: DataSource.galleryScanned,
      foodNameEn: Value(displayNameEn),
      imagePath: Value(imagePath),
      servingGrams: Value(servingGrams),
      aiConfidence: const Value(0.7),
      isVerified: const Value(false),
      notes: Value('ML Kit: ${allLabels.isNotEmpty ? allLabels.join(", ") : label}'),
      referenceObjectUsed: Value(arCalibration?.referenceObject.type.name),
      referenceConfidence: Value(arCalibration?.referenceObject.confidence),
      plateDiameterCm: Value(arCalibration?.plateDiameterCm),
      estimatedVolumeMl: Value(arCalibration?.estimatedVolumeMl),
      isCalibrated: Value(arCalibration?.shouldUseCalibration ?? false),
      arLabelsJson: Value(arObjectLabels.isNotEmpty ? DetectedObjectLabel.encode(arObjectLabels) : null),
      arImageWidth: Value(arImageWidth),
      arImageHeight: Value(arImageHeight),
      arPixelPerCm: Value(arCalibration?.pixelPerCm),
    ));

    AppLogger.info('FoodEntry saved ID: ${entry.id}');
    AppLogger.info('   - Name: ${entry.foodName} ($label)');
    AppLogger.info('   - Calories: ${entry.calories} kcal');
    AppLogger.info(
        '   - P: ${entry.protein}g | C: ${entry.carbs}g | F: ${entry.fat}g');
    AppLogger.info('   - Meal: ${mealType.displayName}');
  }

  void dispose() {
    _visionProcessor.dispose();
  }
}
