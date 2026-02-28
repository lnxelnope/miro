import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:miro_hybrid/features/scanner/logic/scan_controller.dart';
import 'package:miro_hybrid/features/scanner/services/gallery_service.dart';
import 'package:miro_hybrid/features/scanner/services/vision_processor.dart';
import 'package:miro_hybrid/features/scanner/services/qr_parser.dart';
import 'package:miro_hybrid/core/services/permission_service.dart';
import 'package:miro_hybrid/core/database/database_service.dart';
import 'package:miro_hybrid/core/utils/logger.dart';
import 'package:miro_hybrid/features/health/models/food_entry.dart';
import 'package:miro_hybrid/core/constants/enums.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

part 'scanner_provider.g.dart';

/// Provider สำหรับ ScanController
/// ใช้สำหรับสแกนรูปจาก Gallery
@riverpod
ScanController scanController(ScanControllerRef ref) {
  return ScanController(
    GalleryService(),
    VisionProcessor(),
    QRParser(),
  );
}

/// Provider สำหรับ PermissionService
@riverpod
PermissionService permissionService(PermissionServiceRef ref) {
  return PermissionService();
}

/// Provider สำหรับสแกนรูปทั้งหมดใน Gallery
/// return จำนวนรูปที่สแกนได้
@riverpod
class GalleryScanNotifier extends _$GalleryScanNotifier {
  @override
  AsyncValue<int> build() {
    return const AsyncValue.data(0);
  }

  /// สแกนรูปใหม่จาก Gallery
  /// ถ้าระบุ [specificDate] จะสแกนเฉพาะรูปที่ถ่ายในวันนั้นเท่านั้น
  Future<int> scanNewImages({DateTime? specificDate}) async {
    if (specificDate != null) {
      AppLogger.info('scanNewImages() starting for specific date: ${specificDate.toString()}');
    } else {
      AppLogger.info('scanNewImages() starting (all recent images)');
    }
    state = const AsyncValue.loading();

    try {
      // ตรวจสอบ permission
      AppLogger.info('Checking Gallery permission...');
      final permService = ref.read(permissionServiceProvider);
      final hasPermission = await permService.hasGalleryPermission();
      AppLogger.info('Permission status: $hasPermission');

      if (!hasPermission) {
        AppLogger.warn('No permission - requesting permission...');
        final granted = await permService.requestGalleryPermission();
        AppLogger.info('Permission granted: $granted');
        if (!granted) {
          AppLogger.error('Gallery access denied');
          state = AsyncValue.error('Gallery access denied', StackTrace.current);
          return 0;
        }
      }

      final controller = ref.read(scanControllerProvider);
      int savedCount;

      if (specificDate != null) {
        // สแกนเฉพาะวันที่ที่กำหนด
        AppLogger.info('Calling ScanController.scanNewImages() for date: ${specificDate.toString()}');
        savedCount = await controller.scanNewImages(specificDate: specificDate);
      } else {
        // สแกนรูปล่าสุด (ตาม scan limit)
        AppLogger.info('Calling ScanController.scanNewImages() for recent images');
        savedCount = await controller.scanNewImages();
      }

      AppLogger.info('Scan complete - saved: $savedCount entries');

      // อัปเดตเวลาสแกน
      AppLogger.info('Updating last scan time...');
      await permService.setLastScanTime(DateTime.now());

      state = AsyncValue.data(savedCount);
      AppLogger.info('scanNewImages() complete - return: $savedCount');
      return savedCount;
    } catch (e, stack) {
      AppLogger.error('Error occurred', e, stack);
      state = AsyncValue.error(e, stack);
      return 0;
    }
  }
}

/// ผลลัพธ์การ scan รูปภาพ
class ScanResult {
  final String type; // 'health' หรือ 'finance'
  final int? entryId;
  final String? message;

  ScanResult({required this.type, this.entryId, this.message});
}

/// Provider สำหรับเลือกรูปเดียวจาก Gallery
@riverpod
class SingleImagePicker extends _$SingleImagePicker {
  @override
  AsyncValue<ScanResult?> build() {
    return const AsyncValue.data(null);
  }

  /// เลือกรูปเดียวจาก Gallery แล้วสแกน
  Future<ScanResult?> pickAndScanImage() async {
    state = const AsyncValue.loading();

    try {
      // เปิด Image Picker
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) {
        state = const AsyncValue.data(null);
        return null;
      }

      // Process image
      final file = File(pickedFile.path);
      final visionProcessor = VisionProcessor();

      final result = await visionProcessor.processImage(file);

      if (result == null) {
        state = AsyncValue.error('No data found in image', StackTrace.current);
        visionProcessor.dispose();
        return null;
      }

      ScanResult? scanResult;

      if (result['type'] == 'health') {
        // Save as FoodEntry
        final mealType = _getMealTypeFromTime(DateTime.now());

        final entry = FoodEntry()
          ..foodName = result['label'] as String? ?? 'Food'
          ..foodNameEn = result['label'] as String? ?? 'Food'
          ..timestamp = DateTime.now()
          ..imagePath = file.path
          ..mealType = mealType
          ..servingSize = 1.0
          ..servingUnit = 'serving'
          ..calories = 0
          ..protein = 0
          ..carbs = 0
          ..fat = 0
          ..source = DataSource.galleryScanned
          ..aiConfidence = 0.7
          ..isVerified = false
          ..notes = 'Selected from Gallery - please verify and edit'
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now();

        await DatabaseService.isar.writeTxn(() async {
          await DatabaseService.foodEntries.put(entry);
        });

        scanResult = ScanResult(
          type: 'health',
          entryId: entry.id,
          message: 'Food entry saved',
        );
        AppLogger.info('FoodEntry saved ID: ${entry.id}');
      }

      // Cleanup
      visionProcessor.dispose();

      state = AsyncValue.data(scanResult);
      return scanResult;
    } catch (e, stack) {
      debugPrint('❌ [SingleImagePicker] Error: $e');
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

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
}
