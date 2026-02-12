import 'package:miro_hybrid/features/scanner/services/gallery_service.dart';
import 'package:miro_hybrid/features/scanner/services/vision_processor.dart';
import 'package:miro_hybrid/features/scanner/services/qr_parser.dart';
import 'package:miro_hybrid/core/database/database_service.dart';
import 'package:miro_hybrid/core/data/global_food_database.dart';
import 'package:miro_hybrid/core/utils/logger.dart';
import 'package:miro_hybrid/features/health/models/food_entry.dart';
import 'package:miro_hybrid/core/constants/enums.dart';

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

  Future<int> scanNewImages({DateTime? after}) async {
    AppLogger.info('Starting scan for new images... ${after != null ? "after: ${after.toString()}" : "all"}');
    
    final images = await _galleryService.fetchNewImages(after: after);
    AppLogger.info('Found images: ${images.length}');
    
    if (images.isEmpty) {
      AppLogger.info('No new images found - ending scan');
      return 0;
    }
    
    int processedCount = 0;
    int savedCount = 0;
    
    for (var asset in images) {
      processedCount++;
      AppLogger.info('Processing image $processedCount/${images.length}...');
      
      final file = await _galleryService.getFile(asset);
      if (file == null) {
        AppLogger.warn('Cannot load image file - skipping');
        continue;
      }

      final result = await _visionProcessor.processImage(file);
      if (result == null) {
        AppLogger.info('Image not relevant (not food/receipt) - skipping');
        continue; // Ignore irrelevant images
      }

      AppLogger.info('Found data! Type: ${result['type']}');

      if (result['type'] == 'health') {
        // บันทึกเป็น FoodEntry พร้อมค่าประมาณ
        final allLabels = result['all_labels'] as List<String>? ?? [];
        await _saveFoodEntry(
          imagePath: file.path,
          timestamp: asset.createDateTime,
          label: result['label'] as String? ?? 'Food',
          allLabels: allLabels,
        );
        savedCount++;
        AppLogger.info('FoodEntry saved successfully!');
      }
      
      AppLogger.info('Saved successfully! ($savedCount/${images.length})');
    }
    
    AppLogger.info('Scan complete! Processed: $processedCount images, Saved: $savedCount entries');
    return savedCount;
  }
  
  /// แปลง English label เป็นชื่อไทย
  String _translateLabel(String label) {
    final translations = {
      'Egg': 'ไข่',
      'Rice': 'ข้าว',
      'Noodle': 'ก๋วยเตี๋ยว',
      'Soup': 'ซุป',
      'Salad': 'สลัด',
      'Pizza': 'พิซซ่า',
      'Burger': 'เบอร์เกอร์',
      'Sandwich': 'แซนด์วิช',
      'Bread': 'ขนมปัง',
      'Pasta': 'พาสต้า',
      'Steak': 'สเต็ก',
      'Chicken': 'ไก่',
      'Pork': 'หมู',
      'Fish': 'ปลา',
      'Seafood': 'อาหารทะเล',
      'Shrimp': 'กุ้ง',
      'Vegetable': 'ผัก',
      'Fruit': 'ผลไม้',
      'Apple': 'แอปเปิ้ล',
      'Banana': 'กล้วย',
      'Orange': 'ส้ม',
      'Mango': 'มะม่วง',
      'Coffee': 'กาแฟ',
      'Tea': 'ชา',
      'Milk': 'นม',
      'Juice': 'น้ำผลไม้',
      'Beer': 'เบียร์',
      'Wine': 'ไวน์',
      'Cake': 'เค้ก',
      'Cookie': 'คุกกี้',
      'Ice cream': 'ไอศกรีม',
      'Chocolate': 'ช็อกโกแลต',
      'Dessert': 'ขนมหวาน',
      'Fried rice': 'ข้าวผัด',
      'Curry': 'แกง',
      'Sushi': 'ซูชิ',
      'Ramen': 'ราเม็ง',
      'Food': 'อาหาร',
      'Drink': 'เครื่องดื่ม',
      'Meal': 'มื้ออาหาร',
      'Dish': 'จาน',
    };
    return translations[label] ?? label;
  }

  /// บันทึกรายการอาหารจากการสแกน
  Future<void> _saveFoodEntry({
    required String imagePath,
    required DateTime timestamp,
    required String label,
    List<String> allLabels = const [],
  }) async {
    AppLogger.info('Creating FoodEntry...');
    AppLogger.info('Label: $label');
    AppLogger.info('All Labels: ${allLabels.join(", ")}');
    
    // กำหนดมื้ออาหารตามเวลา
    final mealType = _getMealTypeFromTime(timestamp);
    AppLogger.info('Meal type: ${mealType.displayName}');
    
    // แปลง label เป็นชื่อไทย
    final thaiName = _translateLabel(label);
    AppLogger.info('Thai name: $thaiName');
    
    // ถ้า label เป็นคำทั่วไป (Food, Meal, Dish, อาหาร) ให้ไม่ค้นหาใน database
    final commonLabels = ['Food', 'Meal', 'Dish', 'Cuisine', 'อาหาร', 'จาน', 'มื้ออาหาร'];
    final isCommonLabel = commonLabels.contains(label) || commonLabels.contains(thaiName);
    
    if (isCommonLabel) {
      AppLogger.warn('Label is generic ("$label") - not searching database');
      AppLogger.info('   - Will use 0 for all values - user must fill in');
    }
    
    // ค้นหาข้อมูลโภชนาการจากฐานข้อมูล
    double calories = 0;
    double protein = 0;
    double carbs = 0;
    double fat = 0;
    
    FoodNutritionData? nutritionData;
    GlobalFoodData? globalFoodData;
    double servingSize = 1.0;
    String servingUnit = 'serving';
    double? servingGrams;
    
    // ⭐ ค้นหาจาก Global Food Database โดยใช้ทุก labels จาก ML Kit
    // Step 1: Try multi-label search first (best for combining labels like "Shrimp" + "Egg")
    if (allLabels.isNotEmpty) {
      try {
        AppLogger.info('Searching with all labels: ${allLabels.join(", ")}');
        final searchResults = await GlobalFoodDatabase.searchByLabels(allLabels, limit: 1);
        
        if (searchResults.isNotEmpty) {
          globalFoodData = searchResults[0];
          nutritionData = globalFoodData.toNutritionData();
          calories = nutritionData.calories;
          protein = nutritionData.protein;
          carbs = nutritionData.carbs;
          fat = nutritionData.fat;
          servingSize = globalFoodData.servingSize;
          servingUnit = globalFoodData.servingUnit;
          servingGrams = globalFoodData.servingUnit == 'g' ? globalFoodData.servingSize : null;
          AppLogger.info('Found via multi-label search: ${globalFoodData.name}');
          AppLogger.info('   - Serving: ${globalFoodData.servingSize} ${globalFoodData.servingUnit}');
          AppLogger.info('   - Calories: $calories kcal, P: ${protein}g, C: ${carbs}g, F: ${fat}g');
        }
      } catch (e) {
        AppLogger.error('Multi-label search error', e);
      }
    }
    
    // Step 2: Fallback to exact match by primary label (if multi-label didn't find anything)
    if (nutritionData == null && !isCommonLabel) {
      try {
        AppLogger.info('Trying exact match: "$label"');
        GlobalFoodData? globalFood = await GlobalFoodDatabase.lookup(label);
        
        if (globalFood != null) {
          globalFoodData = globalFood;
          nutritionData = globalFood.toNutritionData();
          calories = nutritionData.calories;
          protein = nutritionData.protein;
          carbs = nutritionData.carbs;
          fat = nutritionData.fat;
          servingSize = globalFood.servingSize;
          servingUnit = globalFood.servingUnit;
          servingGrams = globalFood.servingUnit == 'g' ? globalFood.servingSize : null;
          AppLogger.info('Found via exact match: ${globalFood.name}');
        } else {
          AppLogger.info('No exact match for: "$label"');
        }
      } catch (e) {
        AppLogger.error('Exact match error', e);
      }
    }
    
    // Step 3: Fallback to fuzzy search by primary label
    if (nutritionData == null && !isCommonLabel) {
      try {
        AppLogger.info('Trying fuzzy search: "$label"');
        final searchResults = await GlobalFoodDatabase.search(label, limit: 1);
        
        if (searchResults.isNotEmpty) {
          globalFoodData = searchResults[0];
          nutritionData = globalFoodData.toNutritionData();
          calories = nutritionData.calories;
          protein = nutritionData.protein;
          carbs = nutritionData.carbs;
          fat = nutritionData.fat;
          servingSize = globalFoodData.servingSize;
          servingUnit = globalFoodData.servingUnit;
          servingGrams = globalFoodData.servingUnit == 'g' ? globalFoodData.servingSize : null;
          AppLogger.info('Found via fuzzy search: ${globalFoodData.name}');
        } else {
          AppLogger.info('No fuzzy match for: "$label"');
        }
      } catch (e) {
        AppLogger.error('Fuzzy search error', e);
      }
    }
    
    // ถ้ายังไม่พบ หรือเป็นคำทั่วไป ให้ใช้ค่า 0 ทั้งหมด (ให้ผู้ใช้กรอกเอง)
    if (nutritionData == null) {
      if (isCommonLabel) {
        AppLogger.warn('Label is generic - using 0 for all values');
      } else {
        AppLogger.warn('Not found in Global Food Database - using 0 for all values');
      }
      AppLogger.info('   - User must fill in data');
      // ใช้ค่าเริ่มต้นสำหรับ serving
      servingSize = 1.0;
      servingUnit = label == 'Egg' ? 'ฟอง' : 'จาน';
    }
    
    // Use database name if found, otherwise use original label
    final displayName = globalFoodData?.name ?? label;
    final displayNameEn = globalFoodData?.nameEn ?? label;
    
    final entry = FoodEntry()
      ..foodName = displayName
      ..foodNameEn = displayNameEn
      ..timestamp = timestamp
      ..imagePath = imagePath
      ..mealType = mealType
      ..servingSize = servingSize
      ..servingUnit = servingUnit
      ..servingGrams = servingGrams
      ..calories = calories
      ..protein = protein
      ..carbs = carbs
      ..fat = fat
      ..source = DataSource.galleryScanned
      ..aiConfidence = 0.7
      ..isVerified = false
      ..notes = 'ML Kit: ${allLabels.isNotEmpty ? allLabels.join(", ") : label}'
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();
    
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.foodEntries.put(entry);
    });
    
    AppLogger.info('FoodEntry saved ID: ${entry.id}');
    AppLogger.info('   - Name: ${entry.foodName} ($label)');
    AppLogger.info('   - Calories: ${entry.calories} kcal');
    AppLogger.info('   - P: ${entry.protein}g | C: ${entry.carbs}g | F: ${entry.fat}g');
    AppLogger.info('   - Meal: ${mealType.displayName}');
  }
  
  void dispose() {
    _visionProcessor.dispose();
  }
}
