import 'dart:io';
import 'dart:ui' as ui;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../database/database_service.dart';
import '../database/model_extensions.dart';
import 'device_id_service.dart';

/// Uploads food entry thumbnails to Firebase Storage after AI analysis.
/// Stores compact images with nutrition metadata for data mining & cloud backup.
class ThumbnailService {
  static final _storage = FirebaseStorage.instance;

  /// Upload thumbnail to Firebase Storage after successful AI analysis.
  /// Returns the download URL, or null if upload fails.
  ///
  /// Path: food_images/{hashedDeviceId}/{date}/{entryId}.jpg
  /// Metadata: full nutrition data (macros + micros) as custom metadata
  static Future<String?> uploadThumbnail({
    required FoodEntry entry,
    required File imageFile,
  }) async {
    try {
      if (!imageFile.existsSync()) {
        debugPrint('[Thumbnail] Image file not found: ${imageFile.path}');
        return null;
      }

      final deviceId = await DeviceIdService.getDeviceId();
      final hashedId = _hashDeviceId(deviceId);
      final date = _formatDate(entry.timestamp);
      final path = 'food_images/$hashedId/$date/${entry.id}.jpg';

      // Compress to small thumbnail (~40-80KB)
      final thumbnailBytes = await _compressToThumbnail(imageFile);
      if (thumbnailBytes == null) return null;

      final ref = _storage.ref(path);

      // Check if user has opted into food research
      final profile = await (DatabaseService.db.select(DatabaseService.db.userProfiles)
          ..where((tbl) => tbl.id.equals(1)))
          .getSingleOrNull();
      final isResearchable = profile?.foodResearchConsent ?? false;

      // Custom metadata with all nutrition data + research labels if opted in
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: _buildNutritionMetadata(entry, hashedId,
            isResearchable: isResearchable),
      );

      await ref.putData(thumbnailBytes, metadata);
      final downloadUrl = await ref.getDownloadURL();

      debugPrint('[Thumbnail] Uploaded: $path '
          '(${(thumbnailBytes.length / 1024).toStringAsFixed(0)} KB)');

      // Update entry with thumbnail URL
      entry.thumbnailUrl = downloadUrl;
      await DatabaseService.db.into(DatabaseService.db.foodEntries).insertOnConflictUpdate(entry);

      return downloadUrl;
    } catch (e) {
      debugPrint('[Thumbnail] Upload failed (non-fatal): $e');
      return null;
    }
  }

  /// Ensure thumbnail exists and metadata is up-to-date.
  /// - If thumbnailUrl exists → update metadata only (fast)
  /// - If thumbnailUrl is null but local image exists → upload thumbnail
  /// - If neither → skip
  static Future<void> updateMetadataIfNeeded(FoodEntry entry) async {
    try {
      if (entry.hasThumbnailUrl) {
        // Thumbnail already uploaded → just update metadata
        final deviceId = await DeviceIdService.getDeviceId();
        final hashedId = _hashDeviceId(deviceId);
        final date = _formatDate(entry.timestamp);
        final path = 'food_images/$hashedId/$date/${entry.id}.jpg';

        final profile = await (DatabaseService.db.select(DatabaseService.db.userProfiles)
            ..where((tbl) => tbl.id.equals(1)))
            .getSingleOrNull();
        final isResearchable = profile?.foodResearchConsent ?? false;

        final metadata = SettableMetadata(
          customMetadata: _buildNutritionMetadata(entry, hashedId,
              isResearchable: isResearchable),
        );

        await _storage.ref(path).updateMetadata(metadata);
        debugPrint('[Thumbnail] Metadata updated: $path');
      } else if (entry.hasLocalImage) {
        // No thumbnail yet but local image exists → upload with metadata
        debugPrint('[Thumbnail] No thumbnailUrl, uploading from local image');
        await uploadThumbnail(
          entry: entry,
          imageFile: File(entry.imagePath!),
        );
      } else {
        debugPrint('[Thumbnail] No image available for entry ${entry.id}');
      }
    } catch (e) {
      debugPrint('[Thumbnail] Metadata update failed (non-fatal): $e');
    }
  }

  /// Backup thumbnail for [MyMeal] — path `my_meal_thumbs/{deviceHash}/{mealId}.jpg`
  static Future<String?> uploadMyMealThumbnail({
    required MyMeal meal,
    required File imageFile,
  }) async {
    try {
      if (meal.id <= 0 || !imageFile.existsSync()) return null;

      final deviceId = await DeviceIdService.getDeviceId();
      final hashedId = _hashDeviceId(deviceId);
      final storagePath = 'my_meal_thumbs/$hashedId/${meal.id}.jpg';

      final thumbnailBytes = await _compressToThumbnail(imageFile);
      if (thumbnailBytes == null) return null;

      final ref = _storage.ref(storagePath);
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uid': hashedId,
          'type': 'my_meal',
          'mealId': meal.id.toString(),
          'name': meal.name,
          'kcal': meal.totalCalories.toStringAsFixed(0),
        },
      );

      await ref.putData(thumbnailBytes, metadata);
      final downloadUrl = await ref.getDownloadURL();

      meal.thumbnailUrl = downloadUrl;
      meal.thumbnailFirebasePath = storagePath;
      await DatabaseService.db
          .into(DatabaseService.db.myMeals)
          .insertOnConflictUpdate(meal);

      debugPrint('[Thumbnail] MyMeal uploaded: $storagePath');
      return downloadUrl;
    } catch (e) {
      debugPrint('[Thumbnail] MyMeal upload failed (non-fatal): $e');
      return null;
    }
  }

  /// Compress image to ~300x300 JPEG thumbnail.
  static Future<Uint8List?> _compressToThumbnail(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();

      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: 300,
        targetHeight: 300,
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();

      if (byteData == null) return null;
      return byteData.buffer.asUint8List();
    } catch (e) {
      debugPrint('[Thumbnail] Compression failed: $e');
      return null;
    }
  }

  /// Build nutrition metadata map for Firebase Storage custom metadata.
  /// All values stored as strings (Firebase Storage requirement).
  static Map<String, String> _buildNutritionMetadata(
    FoodEntry entry,
    String hashedId, {
    bool isResearchable = false,
  }) {
    final meta = <String, String>{
      'uid': hashedId,
      'foodName': entry.foodName,
      'meal': entry.mealType.name,
      'kcal': entry.calories.toStringAsFixed(0),
      'protein': entry.protein.toStringAsFixed(1),
      'carbs': entry.carbs.toStringAsFixed(1),
      'fat': entry.fat.toStringAsFixed(1),
      'source': entry.source.name,
      'timestamp': entry.timestamp.toUtc().toIso8601String(),
    };

    if (entry.foodNameEn != null) meta['foodNameEn'] = entry.foodNameEn!;
    if (entry.servingGrams != null) {
      meta['servingGrams'] = entry.servingGrams!.toStringAsFixed(0);
    }
    if (entry.fiber != null) meta['fiber'] = entry.fiber!.toStringAsFixed(1);
    if (entry.sugar != null) meta['sugar'] = entry.sugar!.toStringAsFixed(1);
    if (entry.sodium != null) meta['sodium'] = entry.sodium!.toStringAsFixed(0);
    if (entry.cholesterol != null) {
      meta['cholesterol'] = entry.cholesterol!.toStringAsFixed(0);
    }
    if (entry.saturatedFat != null) {
      meta['saturatedFat'] = entry.saturatedFat!.toStringAsFixed(1);
    }
    if (entry.transFat != null) {
      meta['transFat'] = entry.transFat!.toStringAsFixed(1);
    }
    if (entry.unsaturatedFat != null) {
      meta['unsaturatedFat'] = entry.unsaturatedFat!.toStringAsFixed(1);
    }
    if (entry.monounsaturatedFat != null) {
      meta['monoFat'] = entry.monounsaturatedFat!.toStringAsFixed(1);
    }
    if (entry.polyunsaturatedFat != null) {
      meta['polyFat'] = entry.polyunsaturatedFat!.toStringAsFixed(1);
    }
    if (entry.potassium != null) {
      meta['potassium'] = entry.potassium!.toStringAsFixed(0);
    }
    if (entry.aiConfidence != null) {
      meta['confidence'] = entry.aiConfidence!.toStringAsFixed(2);
    }
    if (entry.isCalibrated) meta['calibrated'] = 'true';
    if (entry.referenceObjectUsed != null) {
      meta['refObject'] = entry.referenceObjectUsed!;
    }

    // Correction tracking — data quality (always included)
    if (entry.isUserCorrected) {
      meta['corrected'] = 'true';
      meta['editCount'] = entry.editCount.toString();
      if (entry.originalFoodName != null) {
        meta['origName'] = entry.originalFoodName!;
      }
      if (entry.originalCalories != null) {
        meta['origKcal'] = entry.originalCalories!.toStringAsFixed(0);
      }
    }

    // Research-grade metadata (only when user has consented)
    if (isResearchable) {
      meta['researchable'] = 'true';

      // AR bounding box labels — pre-labeled object detection data
      if (entry.arLabelsJson != null) meta['arLabels'] = entry.arLabelsJson!;
      if (entry.arImageWidth != null) {
        meta['imgW'] = entry.arImageWidth!.toStringAsFixed(0);
      }
      if (entry.arImageHeight != null) {
        meta['imgH'] = entry.arImageHeight!.toStringAsFixed(0);
      }
      if (entry.arPixelPerCm != null) {
        meta['pxPerCm'] = entry.arPixelPerCm!.toStringAsFixed(2);
      }

      // Scene context — food/beverage/dining items
      if (entry.sceneContextJson != null) {
        meta['sceneContext'] = entry.sceneContextJson!;
      }

      // Brand/product data
      if (entry.brandName != null) meta['brand'] = entry.brandName!;
      if (entry.chainName != null) meta['chain'] = entry.chainName!;
      if (entry.productCategory != null) meta['prodCat'] = entry.productCategory!;
      if (entry.packageSize != null) meta['pkgSize'] = entry.packageSize!;

      // User's raw input text
      if (entry.userInputText != null) meta['userInput'] = entry.userInputText!;

      // Ingredients detail
      if (entry.ingredientsJson != null) {
        meta['ingredients'] = entry.ingredientsJson!;
      }
    }

    return meta;
  }

  static String _hashDeviceId(String deviceId) {
    final bytes = utf8.encode(deviceId);
    return sha256.convert(bytes).toString().substring(0, 12);
  }

  static String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')}';
  }
}
