import 'dart:io';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:miro_hybrid/core/utils/logger.dart';

class VisionProcessor {
  final _imageLabeler =
      ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.7));

  Future<Map<String, dynamic>?> processImage(File file) async {
    AppLogger.info('Starting image processing: ${file.path}');

    if (Platform.isWindows) {
      AppLogger.warn('ML Kit Vision not supported on Windows. Skipping scan.');
      return null;
    }

    final inputImage = InputImage.fromFile(file);
    AppLogger.info('InputImage created successfully');

    // Check Labels (Food)
    AppLogger.info('Checking Labels (food)...');
    final labels = await _imageLabeler.processImage(inputImage);
    AppLogger.info('Found Labels: ${labels.length} items');

    // Labels ที่บอกว่าเป็นอาหาร
    final foodCategoryLabels = [
      'Food',
      'Drink',
      'Meal',
      'Breakfast',
      'Lunch',
      'Dinner',
      'Dish',
      'Cuisine',
      'Snack'
    ];

    // Labels เฉพาะเจาะจง (ใช้เป็นชื่ออาหาร)
    final specificFoodLabels = [
      'Egg',
      'Rice',
      'Noodle',
      'Soup',
      'Salad',
      'Pizza',
      'Burger',
      'Sandwich',
      'Bread',
      'Pasta',
      'Steak',
      'Chicken',
      'Pork',
      'Fish',
      'Seafood',
      'Shrimp',
      'Vegetable',
      'Fruit',
      'Apple',
      'Banana',
      'Orange',
      'Mango',
      'Coffee',
      'Tea',
      'Milk',
      'Juice',
      'Water',
      'Beer',
      'Wine',
      'Cake',
      'Cookie',
      'Ice cream',
      'Chocolate',
      'Dessert',
      'Fried rice',
      'Curry',
      'Sushi',
      'Ramen',
      'Dim sum',
    ];

    bool isFood = false;
    String detectedLabel = "";
    String specificLabel = "";
    List<String> allLabels = [];

    for (var label in labels) {
      AppLogger.info(
          '  - Label: ${label.label} (confidence: ${(label.confidence * 100).toStringAsFixed(1)}%)');
      allLabels.add(label.label);

      // เก็บ label เฉพาะเจาะจง (ใช้เป็นชื่ออาหาร)
      if (specificFoodLabels.contains(label.label) && specificLabel.isEmpty) {
        specificLabel = label.label;
        isFood = true;
        AppLogger.info('Found specific label: $specificLabel');
      }

      // เช็คว่าเป็นหมวดอาหารหรือไม่
      if (foodCategoryLabels.contains(label.label) && !isFood) {
        isFood = true;
        detectedLabel = label.label;
        AppLogger.info('Found food category: $detectedLabel');
      }
    }

    if (isFood) {
      // ใช้ label เฉพาะเจาะจง ถ้ามี มิฉะนั้นใช้หมวดอาหาร
      final finalLabel =
          specificLabel.isNotEmpty ? specificLabel : detectedLabel;
      AppLogger.info('Type: Health (food) - Label: $finalLabel');
      AppLogger.info('All Labels: ${allLabels.join(", ")}');
      return {
        'type': 'health',
        'sub_type': 'food',
        'label': finalLabel,
        'all_labels': allLabels,
      };
    }

    AppLogger.info('No food-related labels found - skipping this image');
    return null;
  }

  void dispose() {
    _imageLabeler.close();
  }
}
