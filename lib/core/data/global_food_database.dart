import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../utils/logger.dart';

/// ฐานข้อมูลอาหารทั่วโลกจาก MM-Food-100K dataset
/// ใช้ lazy loading และ isolate เพื่อไม่ให้บล็อก UI
class GlobalFoodDatabase {
  static List<GlobalFoodData>? _foods;
  static Map<String, List<int>>? _nameIndex;
  static Map<String, List<int>>? _categoryIndex;
  static Map<String, List<int>>? _cuisineIndex;
  static bool _isLoaded = false;
  static bool _isLoading = false;
  static Future<void>? _loadingFuture;

  /// โหลดข้อมูลจาก JSON file (lazy loading - โหลดเมื่อต้องการใช้)
  /// ใช้ isolate เพื่อไม่ให้บล็อก UI
  static Future<void> load() async {
    // ถ้ากำลังโหลดอยู่ ให้รอให้เสร็จก่อน
    if (_isLoading && _loadingFuture != null) {
      return _loadingFuture!;
    }

    // ถ้าโหลดเสร็จแล้ว ไม่ต้องโหลดซ้ำ
    if (_isLoaded) return;

    // เริ่มโหลด
    _isLoading = true;
    _loadingFuture = _loadInBackground();
    
    try {
      await _loadingFuture;
    } finally {
      _isLoading = false;
      _loadingFuture = null;
    }
  }

  /// โหลดข้อมูลใน background isolate
  static Future<void> _loadInBackground() async {
    try {
      debugPrint('📥 [GlobalFoodDatabase] กำลังโหลดข้อมูลใน background...');
      
      // โหลด JSON string ใน main isolate (rootBundle ต้องใช้ใน main isolate)
      final foodsJson = await rootBundle.loadString('assets/data/global_food_database.json');
      
      // Parse JSON ใน isolate เพื่อไม่ให้บล็อก UI
      final parsedData = await compute(_parseFoodsJson, foodsJson);
      _foods = parsedData;
      
      // โหลด index
      try {
        final indexJson = await rootBundle.loadString('assets/data/global_food_index.json');
        final indexData = await compute(_parseIndexJson, indexJson);
        
        _nameIndex = indexData['by_name'] as Map<String, List<int>>? ?? {};
        _categoryIndex = indexData['by_category'] as Map<String, List<int>>? ?? {};
        _cuisineIndex = indexData['by_cuisine'] as Map<String, List<int>>? ?? {};
      } catch (e) {
        AppLogger.warn('Index file not found, will create new...');
        _buildIndex();
      }
      
      _isLoaded = true;
      AppLogger.info('Loaded successfully: ${_foods!.length} items');
    } catch (e) {
      AppLogger.error('Load failed', e);
      _foods = [];
      _isLoaded = true; // ตั้งเป็น loaded เพื่อไม่ให้ลองโหลดซ้ำ
    }
  }

  /// Parse JSON ใน isolate
  static List<GlobalFoodData> _parseFoodsJson(String jsonString) {
    final List<dynamic> foodsList = jsonDecode(jsonString);
    return foodsList.map((json) => GlobalFoodData.fromJson(json)).toList();
  }

  /// Parse index JSON ใน isolate
  static Map<String, dynamic> _parseIndexJson(String jsonString) {
    final Map<String, dynamic> indexData = jsonDecode(jsonString);
    return {
      'by_name': Map<String, List<int>>.from(
        indexData['by_name']?.map((k, v) => MapEntry(k, List<int>.from(v))) ?? {},
      ),
      'by_category': Map<String, List<int>>.from(
        indexData['by_category']?.map((k, v) => MapEntry(k, List<int>.from(v))) ?? {},
      ),
      'by_cuisine': Map<String, List<int>>.from(
        indexData['by_cuisine']?.map((k, v) => MapEntry(k, List<int>.from(v))) ?? {},
      ),
    };
  }

  /// สร้าง index ใหม่
  static void _buildIndex() {
    if (_foods == null) return;
    
    _nameIndex = {};
    _categoryIndex = {};
    _cuisineIndex = {};
    
    for (int i = 0; i < _foods!.length; i++) {
      final food = _foods![i];
      final nameLower = food.name.toLowerCase();
      
      // Index by first word of name
      final firstWord = nameLower.split(' ').isNotEmpty 
          ? nameLower.split(' ')[0] 
          : nameLower;
      _nameIndex!.putIfAbsent(firstWord, () => []).add(i);
      
      // Index by category
      if (food.category.isNotEmpty) {
        final cat = food.category.toLowerCase();
        _categoryIndex!.putIfAbsent(cat, () => []).add(i);
      }
      
      // Index by cuisine
      if (food.cuisine.isNotEmpty) {
        final cuisine = food.cuisine.toLowerCase();
        _cuisineIndex!.putIfAbsent(cuisine, () => []).add(i);
      }
    }
  }

  /// ค้นหาอาหารจากชื่อ (exact match)
  /// จะโหลดข้อมูลอัตโนมัติถ้ายังไม่ได้โหลด (lazy loading)
  static Future<GlobalFoodData?> lookup(String foodName) async {
    AppLogger.info('lookup: "$foodName"');
    
    // Lazy loading: โหลดถ้ายังไม่ได้โหลด
    if (!_isLoaded) {
      AppLogger.info('Loading data...');
      await load();
    }

    if (_foods == null || _foods!.isEmpty) {
      debugPrint('❌ [GlobalFoodDatabase] ไม่มีข้อมูลใน database');
      return null;
    }

    AppLogger.info('Food count in database: ${_foods!.length}');
    final normalized = foodName.trim().toLowerCase();
    debugPrint('🔍 [GlobalFoodDatabase] ค้นหา: "$normalized"');
    
    // ค้นหาแบบ exact match
    for (final food in _foods!) {
      if (food.name.toLowerCase() == normalized || 
          food.nameEn.toLowerCase() == normalized) {
        AppLogger.info('Found exact match: ${food.name} (${food.nameEn})');
        return food;
      }
    }
    
    // ค้นหาแบบ contains - แต่ต้องระวังคำทั่วไป เช่น "food", "อาหาร"
    // ถ้าเป็นคำทั่วไป (food, meal, dish, อาหาร, จาน) ให้ไม่ใช้ contains
    final commonWords = ['food', 'meal', 'dish', 'cuisine', 'อาหาร', 'จาน', 'มื้อ'];
    final isCommonWord = commonWords.contains(normalized);
    
    if (!isCommonWord) {
      int matchCount = 0;
      for (final food in _foods!) {
        // ใช้ contains เฉพาะเมื่อ query ไม่ใช่คำทั่วไป
        if (food.name.toLowerCase().contains(normalized) ||
            food.nameEn.toLowerCase().contains(normalized)) {
          matchCount++;
          if (matchCount == 1) {
            AppLogger.info('Found contains match: ${food.name} (${food.nameEn})');
            return food;
          }
        }
      }
      
      if (matchCount == 0) {
        debugPrint('❌ [GlobalFoodDatabase] ไม่พบแบบ contains: "$normalized"');
      }
    } else {
      AppLogger.warn('Skipping contains search - generic word: "$normalized"');
    }
    
    return null;
  }

  /// ค้นหาแบบ fuzzy search (คำใกล้เคียง)
  /// จะโหลดข้อมูลอัตโนมัติถ้ายังไม่ได้โหลด (lazy loading)
  static Future<List<GlobalFoodData>> search(String query, {int limit = 10}) async {
    // Lazy loading: โหลดถ้ายังไม่ได้โหลด
    if (!_isLoaded) {
      await load();
    }

    if (_foods == null || _foods!.isEmpty) {
      return [];
    }

    final normalized = query.trim().toLowerCase();
    final results = <MapEntry<GlobalFoodData, int>>[];
    
    for (final food in _foods!) {
      int score = 0;
      
      // Exact match = highest score
      if (food.name.toLowerCase() == normalized || 
          food.nameEn.toLowerCase() == normalized) {
        score = 1000;
      }
      // Starts with = high score
      else if (food.name.toLowerCase().startsWith(normalized) ||
               food.nameEn.toLowerCase().startsWith(normalized)) {
        score = 500;
      }
      // Contains = medium score
      else if (food.name.toLowerCase().contains(normalized) ||
               food.nameEn.toLowerCase().contains(normalized)) {
        score = 100;
      }
      // Levenshtein distance = lower score
      else {
        final distance = _levenshtein(normalized, food.name.toLowerCase());
        final distanceEn = _levenshtein(normalized, food.nameEn.toLowerCase());
        final minDistance = distance < distanceEn ? distance : distanceEn;
        
        if (minDistance <= 3) {  // อนุญาตให้ผิดพลาดได้ 3 ตัวอักษร
          score = 50 - (minDistance * 10);
        }
      }
      
      if (score > 0) {
        results.add(MapEntry(food, score));
      }
    }
    
    // เรียงตาม score
    results.sort((a, b) => b.value.compareTo(a.value));
    
    return results.take(limit).map((e) => e.key).toList();
  }

  /// ค้นหาอาหารโดยใช้หลาย labels จาก ML Kit
  /// ให้คะแนนตาม: ชื่อตรง > ingredients ตรง > หลาย labels ตรง
  static Future<List<GlobalFoodData>> searchByLabels(List<String> labels, {int limit = 5}) async {
    if (labels.isEmpty) return [];
    
    // Lazy loading
    if (!_isLoaded) {
      await load();
    }

    if (_foods == null || _foods!.isEmpty) {
      return [];
    }

    // Filter out common/generic labels
    final genericLabels = {'food', 'meal', 'dish', 'cuisine', 'drink', 'breakfast', 'lunch', 'dinner', 'snack'};
    final specificLabels = labels
        .map((l) => l.toLowerCase().trim())
        .where((l) => !genericLabels.contains(l))
        .toList();
    
    if (specificLabels.isEmpty) {
      debugPrint('⚠️ [GlobalFoodDatabase] All labels are generic, skipping search');
      return [];
    }
    
    AppLogger.info('searchByLabels: $specificLabels');

    final results = <MapEntry<GlobalFoodData, int>>[];
    
    for (final food in _foods!) {
      int score = 0;
      final nameLower = food.name.toLowerCase();
      final nameEnLower = food.nameEn.toLowerCase();
      final ingredientsLower = food.ingredients.map((i) => i.toLowerCase()).toList();
      
      for (final label in specificLabels) {
        // Exact name match = highest score
        if (nameLower == label || nameEnLower == label) {
          score += 1000;
          continue;
        }
        
        // Name contains label = high score
        if (nameLower.contains(label) || nameEnLower.contains(label)) {
          score += 200;
          continue;
        }
        
        // Ingredient exact match = medium-high score
        if (ingredientsLower.contains(label)) {
          score += 150;
          continue;
        }
        
        // Ingredient contains label = medium score
        for (final ingredient in ingredientsLower) {
          if (ingredient.contains(label) || label.contains(ingredient)) {
            score += 100;
            break;
          }
        }
      }
      
      // Bonus: more labels matched = better
      if (score > 0) {
        // Count how many labels matched
        int matchedLabels = 0;
        for (final label in specificLabels) {
          if (nameLower.contains(label) || 
              nameEnLower.contains(label) ||
              ingredientsLower.any((i) => i.contains(label) || label.contains(i))) {
            matchedLabels++;
          }
        }
        // Bonus for matching multiple labels
        score += matchedLabels * 50;
        
        results.add(MapEntry(food, score));
      }
    }
    
    if (results.isEmpty) {
      AppLogger.info('No matches for labels: $specificLabels');
      return [];
    }
    
    // Sort by score descending
    results.sort((a, b) => b.value.compareTo(a.value));
    
    final topResults = results.take(limit).map((e) => e.key).toList();
    debugPrint('✅ [GlobalFoodDatabase] Found ${results.length} matches, returning top $limit:');
    for (int i = 0; i < topResults.length && i < 3; i++) {
      final r = results[i];
      AppLogger.info('   ${i+1}. ${r.key.name} (score: ${r.value})');
    }
    
    return topResults;
  }

  /// ค้นหาตามหมวดหมู่
  /// จะโหลดข้อมูลอัตโนมัติถ้ายังไม่ได้โหลด (lazy loading)
  static Future<List<GlobalFoodData>> findByCategory(String category, {int limit = 20}) async {
    // Lazy loading: โหลดถ้ายังไม่ได้โหลด
    if (!_isLoaded) {
      await load();
    }

    if (_foods == null || _categoryIndex == null) {
      return [];
    }

    final cat = category.toLowerCase();
    final indices = _categoryIndex![cat] ?? [];
    
    return indices.take(limit).map((i) => _foods![i]).toList();
  }

  /// ค้นหาตามอาหารประจำชาติ
  static List<GlobalFoodData> findByCuisine(String cuisine, {int limit = 20}) {
    if (!_isLoaded || _foods == null || _cuisineIndex == null) {
      return [];
    }

    final cui = cuisine.toLowerCase();
    final indices = _cuisineIndex![cui] ?? [];
    
    return indices.take(limit).map((i) => _foods![i]).toList();
  }

  /// Levenshtein distance สำหรับ fuzzy matching
  static int _levenshtein(String s1, String s2) {
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<int> prev = List.generate(s2.length + 1, (i) => i);
    List<int> curr = List.filled(s2.length + 1, 0);

    for (int i = 1; i <= s1.length; i++) {
      curr[0] = i;
      for (int j = 1; j <= s2.length; j++) {
        int cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        curr[j] = [
          prev[j] + 1,
          curr[j - 1] + 1,
          prev[j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
      List<int> temp = prev;
      prev = curr;
      curr = temp;
    }
    return prev[s2.length];
  }

  /// จำนวนอาหารทั้งหมด
  static int get count => _foods?.length ?? 0;

  /// ตรวจสอบว่าโหลดข้อมูลแล้วหรือยัง
  static bool get isLoaded => _isLoaded;

  /// ตรวจสอบว่ากำลังโหลดข้อมูลอยู่หรือไม่
  static bool get isLoading => _isLoading;
}

/// ข้อมูลอาหารจาก global database
class GlobalFoodData {
  final int id;
  final String name;
  final String nameEn;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final double sodium;
  final double servingSize;
  final String servingUnit;
  final String category;
  final String cuisine;
  final String imageUrl;
  final String cookingMethod;
  final List<String> ingredients;

  GlobalFoodData({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0,
    this.sugar = 0,
    this.sodium = 0,
    this.servingSize = 100,
    this.servingUnit = 'g',
    this.category = '',
    this.cuisine = '',
    this.imageUrl = '',
    this.cookingMethod = '',
    this.ingredients = const [],
  });

  factory GlobalFoodData.fromJson(Map<String, dynamic> json) {
    // รองรับทั้งชื่อไทยและอังกฤษ (dataset มีเฉพาะอังกฤษ)
    final nameEn = json['name_en'] ?? json['name'] ?? '';
    final name = json['name'] ?? nameEn; // ถ้าไม่มีชื่อไทยให้ใช้ชื่ออังกฤษ
    
    // Parse ingredients (อาจเป็น List หรือ String JSON)
    List<String> ingredientsList = [];
    if (json['ingredients'] != null) {
      if (json['ingredients'] is List) {
        ingredientsList = List<String>.from(json['ingredients']);
      } else if (json['ingredients'] is String) {
        try {
          final parsed = jsonDecode(json['ingredients']);
          if (parsed is List) {
            ingredientsList = List<String>.from(parsed);
          }
        } catch (e) {
          // Ignore parse error
        }
      }
    }
    
    return GlobalFoodData(
      id: json['id'] ?? 0,
      name: name,
      nameEn: nameEn,
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      fiber: (json['fiber'] ?? 0).toDouble(),
      sugar: (json['sugar'] ?? 0).toDouble(),
      sodium: (json['sodium'] ?? 0).toDouble(),
      servingSize: (json['serving_size'] ?? 100).toDouble(),
      servingUnit: json['serving_unit'] ?? 'g',
      category: json['category'] ?? json['food_type'] ?? '',
      cuisine: json['cuisine'] ?? '',
      imageUrl: json['image_url'] ?? '',
      cookingMethod: json['cooking_method'] ?? '',
      ingredients: ingredientsList,
    );
  }

  /// แปลงเป็น FoodNutritionData format
  FoodNutritionData toNutritionData({double? multiplier}) {
    // ถ้ามี multiplier (เช่น 2 จาน) ให้คูณค่าทั้งหมด
    final mult = multiplier ?? 1.0;
    return FoodNutritionData(
      calories: calories * mult,
      protein: protein * mult,
      carbs: carbs * mult,
      fat: fat * mult,
      servingSize: servingSize * mult,
      servingUnit: servingUnit,
    );
  }
}

/// ข้อมูลโภชนาการอาหาร
class FoodNutritionData {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double? servingSize;
  final String? servingUnit;

  const FoodNutritionData({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.servingSize,
    this.servingUnit,
  });
}
