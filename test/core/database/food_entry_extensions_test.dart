import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:miro_hybrid/core/database/app_database.dart';
import 'package:miro_hybrid/core/database/model_extensions.dart';

FoodEntryData _minimalEntry({
  String? imagePath,
  String? supplementaryImagePath2,
  String? supplementaryImagePath3,
  String? imagePathsJson,
}) {
  final now = DateTime.now();
  return FoodEntryData(
    id: 1,
    foodName: 'Test Food',
    foodNameEn: null,
    timestamp: now,
    imagePath: imagePath,
    supplementaryImagePath2: supplementaryImagePath2,
    supplementaryImagePath3: supplementaryImagePath3,
    imagePathsJson: imagePathsJson,
    mealType: MealType.breakfast,
    servingSize: 1,
    servingUnit: 'serving',
    servingGrams: null,
    calories: 100,
    protein: 10,
    carbs: 10,
    fat: 10,
    baseCalories: 100,
    baseProtein: 10,
    baseCarbs: 10,
    baseFat: 10,
    fiber: null,
    sugar: null,
    sodium: null,
    cholesterol: null,
    saturatedFat: null,
    transFat: null,
    unsaturatedFat: null,
    monounsaturatedFat: null,
    polyunsaturatedFat: null,
    potassium: null,
    source: DataSource.arScan,
    searchMode: FoodSearchMode.normal,
    aiConfidence: null,
    isVerified: false,
    isDeleted: false,
    notes: null,
    myMealId: null,
    ingredientId: null,
    groupId: null,
    groupSource: null,
    groupOrder: null,
    isGroupOriginal: false,
    ingredientsJson: null,
    userInputText: null,
    originalFoodName: null,
    originalFoodNameEn: null,
    originalCalories: null,
    originalProtein: null,
    originalCarbs: null,
    originalFat: null,
    originalIngredientsJson: null,
    editCount: 0,
    isUserCorrected: false,
    correctionHistoryJson: null,
    brandName: null,
    brandNameEn: null,
    productName: null,
    productBarcode: null,
    netWeight: null,
    netWeightUnit: null,
    chainName: null,
    productCategory: null,
    packageSize: null,
    nutritionSource: null,
    sceneContext: null,
    detectedObjectsJson: null,
    arBoundingBox: null,
    estimatedWidthCm: null,
    estimatedHeightCm: null,
    estimatedDepthCm: null,
    referenceObjectUsed: null,
    referenceConfidence: null,
    plateDiameterCm: null,
    estimatedVolumeMl: null,
    isCalibrated: false,
    arLabelsJson: null,
    arImageWidth: null,
    arImageHeight: null,
    arPixelPerCm: null,
    healthConnectId: null,
    syncedAt: null,
    isSynced: false,
    firebaseDocId: null,
    lastSyncAt: null,
    thumbnailUrl: null,
    thumbnailFirebasePath: null,
    vitaminA: null,
    vitaminC: null,
    vitaminD: null,
    vitaminE: null,
    vitaminK: null,
    thiamin: null,
    riboflavin: null,
    niacin: null,
    vitaminB6: null,
    folate: null,
    vitaminB12: null,
    calcium: null,
    iron: null,
    magnesium: null,
    phosphorus: null,
    zinc: null,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('FoodEntryExtensions', () {
    test('allImagePaths returns up to 3 non-empty paths in order', () {
      final entry = _minimalEntry(
        imagePath: 'path1.jpg',
        supplementaryImagePath2: 'path2.jpg',
        supplementaryImagePath3: 'path3.jpg',
      );

      final paths = entry.allImagePaths;

      expect(paths, ['path1.jpg', 'path2.jpg', 'path3.jpg']);
      expect(entry.isArScan, isTrue);
      expect(entry.hasMultipleImages, isTrue);
    });

    test('allImagePaths uses imagePathsJson when set (n > 3)', () {
      final five = List.generate(5, (i) => '/tmp/img_$i.jpg');
      final entry = _minimalEntry(
        imagePath: 'ignored_when_json',
        supplementaryImagePath2: 'also_ignored',
        supplementaryImagePath3: 'also_ignored',
        imagePathsJson: jsonEncode(five),
      );

      expect(entry.allImagePaths, five);
      expect(entry.hasMultipleImages, isTrue);
    });
  });
}

