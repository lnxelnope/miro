import 'dart:io';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:miro_hybrid/core/utils/logger.dart';

class VisionProcessor {
  final _imageLabeler =
      ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.7));
  final _textRecognizer = TextRecognizer();
  final _barcodeScanner = BarcodeScanner();

  Future<Map<String, dynamic>?> processImage(File file) async {
    AppLogger.info('Starting image processing: ${file.path}');

    // Check if running on unsupported platform (Windows for ML Kit)
    if (Platform.isWindows) {
      AppLogger.warn('ML Kit Vision not supported on Windows. Skipping scan.');
      return null;
    }

    final inputImage = InputImage.fromFile(file);
    AppLogger.info('InputImage created successfully');

    // 1. Check for QR Code (Finance Priority)
    AppLogger.info('Checking QR Code/Barcode...');
    final barcodes = await _barcodeScanner.processImage(inputImage);
    if (barcodes.isNotEmpty) {
      AppLogger.info('Found QR/Barcode: ${barcodes.length} items');
      // It's likely a Bill/Slip
      AppLogger.info('Reading text from receipt...');
      final text = await _textRecognizer.processImage(inputImage);
      AppLogger.info(
          'Type: Finance (receipt/bill) - Text read: ${text.text.substring(0, text.text.length > 50 ? 50 : text.text.length)}...');
      return {
        'type': 'finance',
        'raw_text': text.text,
        'has_qr': true,
      };
    }
    AppLogger.info('No QR/Barcode found');

    // 2. Check Labels (Food Priority)
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

    // 3. If nothing matches -> Return null (Ignore)
    AppLogger.info(
        'No relevant data found (food/receipt) - skipping this image');
    return null;
  }

  void dispose() {
    _imageLabeler.close();
    _textRecognizer.close();
    _barcodeScanner.close();
  }
}
