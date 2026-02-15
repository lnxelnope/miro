import 'dart:convert';
import '../utils/unit_converter.dart';
import '../utils/logger.dart';

/// Service for processing text with AI
/// Uses Gemini API or local regex fallback
class LLMService {
  // ===== Food Name Database (ไม่ใช้แล้ว - เอาออก) =====
  // static List<Map<String, dynamic>>? _foodDb;
  // static bool _foodDbLoaded = false;

  /// Public accessor for normalize function
  static String normalizeThaiFood(String text) => _normalizeThaiFood(text);

  /// ไม่ต้อง load food database แล้ว
  static Future<void> loadFoodDatabase() async {
    // ไม่ทำอะไร - เก็บไว้เพื่อ backward compatibility
  }

  /// Normalize food name — supports both EN + TH (and other languages)
  static String normalizeFoodName(String name, {String locale = 'en'}) {
    var result = name.trim().toLowerCase();
    
    if (locale == 'en' || !_isThaiText(result)) {
      return _normalizeEnglishFood(result);
    } else {
      return _normalizeThaiFood(result);
    }
  }
  
  /// Check if text is Thai
  static bool _isThaiText(String text) {
    return text.runes.any((r) => r >= 0x0E00 && r <= 0x0E7F);
  }
  
  /// Normalize English food
  static String _normalizeEnglishFood(String name) {
    var result = name.toLowerCase().trim();
    result = result.replaceAll(RegExp(r'^(a |an |the |some )'), '');
    result = result.replaceAll(RegExp(r'\s*(bowl of|plate of|glass of|cup of|piece of)\s*'), ' ');
    result = result.replaceAll(RegExp(r'^(fried |grilled |steamed |boiled |baked |roasted )'), '');
    return result.trim();
  }

  /// Normalize Thai food spelling variations
  static String _normalizeThaiFood(String text) {
    String n = text;
    n = n.replaceAll('กระเพราะ', 'กะเพรา');
    n = n.replaceAll('กระเพรา', 'กะเพรา');
    n = n.replaceAll('กะเพราะ', 'กะเพรา');
    n = n.replaceAll('ก๊วยเตี๋ยว', 'ก๋วยเตี๋ยว');
    n = n.replaceAll('กวยเตี๋ยว', 'ก๋วยเตี๋ยว');
    n = n.replaceAll('กวยจั๊บ', 'ก๋วยจั๊บ');
    n = n.replaceAll('ท่อดมัน', 'ทอดมัน');
    n = n.replaceAll('เขียวหว่าน', 'เขียวหวาน');
    n = n.replaceAll('มะม้วง', 'มะม่วง');
    n = n.replaceAll('ข้าวหมัน', 'ข้าวมัน');
    return n;
  }

  /// Search food name from DB (ไม่ใช้แล้ว - ให้ใช้ My Meal และ Ingredient แทน)
  static Map<String, dynamic>? matchFoodFromDb(String query) {
    return null; // ไม่มี database แล้ว
  }

  /// Process text and classify intent (Food only for v1.0)
  Future<String> classifyAndParse(String text, {String pageContext = 'health'}) async {
    AppLogger.info('Processing with Local AI: $text (page: $pageContext)');
    return await _localFallback(text, pageContext: pageContext);
  }

  /// Local regex fallback for text classification (Food-focused for v1.0)
  Future<String> _localFallback(String text, {String pageContext = 'health'}) async {
    final lowerText = text.toLowerCase();

    // ========== 1. Query Detection ==========
    if (_containsAny(lowerText, ['how many calories', 'calorie summary', 'total calories', 'summary', 'total'])) {
      String queryType = 'calories';
      String period = 'today';
      
      if (lowerText.contains('month') || lowerText.contains('this month')) {
        period = 'month';
      } else if (lowerText.contains('week') || lowerText.contains('this week')) {
        period = 'week';
      }
      
      return jsonEncode({
        'type': 'query',
        'query_type': queryType,
        'period': period,
        'title': text,
      });
    }

    // ========== 2. Edit/Delete Detection ==========
    if (_containsAny(lowerText, ['edit', 'change', 'update', 'modify'])) {
      return jsonEncode({
        'type': 'edit',
        'title': text,
      });
    }

    if (_containsAny(lowerText, ['delete', 'remove', 'cancel'])) {
      return jsonEncode({
        'type': 'delete',
        'title': text,
      });
    }

    // ========== 3. Create Meal Detection ==========
    if (_containsAny(lowerText, ['create meal', 'new meal', 'new recipe', 'save recipe', 'add meal'])) {
      final mealInfo = _extractCreateMealInfo(text);
      return jsonEncode({
        'type': 'create_meal',
        'title': mealInfo['name'] ?? text,
        'meal_name': mealInfo['name'] ?? '',
        'ingredients_raw': mealInfo['ingredients'] ?? [],
      });
    }

    // ========== 4. Health/Food Detection ==========
    final isFoodRelated = _containsAny(lowerText, [
      'eat', 'ate', 'food', 'rice', 'curry', 'fried', 'boiled', 'salad',
      'noodle', 'noodles', 'pasta', 'soup', 'steak', 'chicken', 'pork',
      'calories', 'protein', 'carbs', 'kcal', 'breakfast', 'lunch', 'dinner', 'snack',
      'had', 'drank', 'drink',
    ]);

    if (isFoodRelated || pageContext == 'health') {
      final now = DateTime.now();
      DateTime entryDate = now;
      if (lowerText.contains('yesterday')) {
        entryDate = now.subtract(const Duration(days: 1));
      }
      final dateStr = '${entryDate.year}-${entryDate.month.toString().padLeft(2, '0')}-${entryDate.day.toString().padLeft(2, '0')}';
      
      String mealType = _detectMealTypeFromText(lowerText, now.hour);
      String foodName = _extractFoodName(text);
      final servingInfo = _extractServingSize(text);
      double? caloriesFromText = _extractCalories(text);

      // Detect exclude ingredients
      final excludeIngredients = _extractExcludeIngredients(text);

      // Detect if user wants to create new meal
      final isCreateMeal = lowerText.contains('create meal') || 
                           lowerText.contains('new meal') ||
                           lowerText.contains('new recipe');

      return jsonEncode({
        'type': 'health',
        'title': foodName,
        'category': 'Food',
        'calories': caloriesFromText ?? 0,
        'protein': 0,
        'carbs': 0,
        'fat': 0,
        'serving_size': servingInfo != null ? servingInfo['size'] : 1.0,
        'serving_unit': servingInfo != null ? servingInfo['unit'] : 'serving',
        'serving_grams': null,
        'date': dateStr,
        'meal_type': mealType,
        'exclude_ingredients': excludeIngredients,
        'is_create_meal': isCreateMeal,
      });
    }

    // ========== 5. Fallback — treat as food ==========
    AppLogger.info('No keyword match → treating as food');

    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final mealType = _detectMealTypeFromText(lowerText, now.hour);
    String foodName = _extractFoodName(text);
    final servingInfo = _extractServingSize(text);

    return jsonEncode({
      'type': 'health',
      'title': foodName,
      'category': 'Food',
      'calories': 0,
      'protein': 0,
      'carbs': 0,
      'fat': 0,
      'serving_size': servingInfo != null ? servingInfo['size'] : 1.0,
      'serving_unit': servingInfo != null ? servingInfo['unit'] : 'serving',
      'serving_grams': null,
      'date': dateStr,
      'meal_type': mealType,
      'exclude_ingredients': <String>[],
      'is_create_meal': false,
    });
  }

  /// Check if text contains any of the keywords
  bool _containsAny(String text, List<String> keywords) {
    for (final keyword in keywords) {
      if (text.contains(keyword)) return true;
    }
    return false;
  }

  /// Extract calories from text
  double? _extractCalories(String text) {
    final pattern = RegExp(r'(\d+(?:\.\d+)?)\s*(?:kcal|cal|calories)', caseSensitive: false);
    final match = pattern.firstMatch(text);
    if (match != null) {
      return double.tryParse(match.group(1)!);
    }
    return null;
  }

  /// Extract meal type from text or use current time
  String _detectMealTypeFromText(String lowerText, int currentHour) {
    if (lowerText.contains('morning') || lowerText.contains('breakfast')) {
      return 'Breakfast';
    }
    if (lowerText.contains('noon') || lowerText.contains('lunch')) {
      return 'Lunch';
    }
    if (lowerText.contains('evening') || lowerText.contains('dinner')) {
      return 'Dinner';
    }
    if (lowerText.contains('snack')) {
      return 'Snack';
    }
    
    if (currentHour >= 5 && currentHour < 10) return 'Breakfast';
    if (currentHour >= 10 && currentHour < 14) return 'Lunch';
    if (currentHour >= 14 && currentHour < 17) return 'Snack';
    if (currentHour >= 17 && currentHour < 21) return 'Dinner';
    return 'Snack';
  }

  /// Extract food name from text
  String _extractFoodName(String text) {
    String cleaned = text;
    AppLogger.info('FoodName input: "$text"');

    // Step 1: Remove prefix
    for (int i = 0; i < 3; i++) {
      cleaned = cleaned
        .replaceAll(RegExp(r'^\s*(today|yesterday|day before yesterday|tomorrow|now|just)\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'^\s*(I |i )', caseSensitive: false), '')
        .replaceAll(RegExp(r'^\s*(got|went|came|will|already|just|just now)\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'^\s*(ate|eat|eating|had|have|ordered|bought)\s*', caseSensitive: false), '');
    }

    // Step 2: Remove meal phrases
    cleaned = cleaned
      .replaceAll(RegExp(r'\s*(for|as|at)?\s*(breakfast|lunch|dinner|snack|meal)\s*$', caseSensitive: false), '')
      .replaceAll(RegExp(r'\s*(this|in the)?\s*(morning|afternoon|evening|night)\s*$', caseSensitive: false), '')
      .replaceAll(RegExp(r'\s*(breakfast|lunch|dinner|snack|meal)\s*$', caseSensitive: false), '');

    // Step 3: Remove suffixes
    for (int i = 0; i < 2; i++) {
      cleaned = cleaned
        .replaceAll(RegExp(r'\s*(went|came|already|here|with|please|thanks|thank you|ok|okay)\s*$', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s*at\s*$', caseSensitive: false), '');
    }

    // Step 4: Remove quantity + calories
    cleaned = cleaned
      .replaceAll(RegExp(r'\s*\d+\s*(kcal|cal|calories)\s*', caseSensitive: false), '')
      .replaceAll(RegExp(r'\s*\d+(?:\.\d+)?\s*(?:plate|cup|piece|g|gram|kg|ml|l|milliliter|liter|item|egg|box|pack|ball|serving|tbsp|tsp|oz|lbs)\s*', caseSensitive: false), '');

    // Step 5: Remove duplicate spaces + trim
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    if (cleaned.isEmpty) {
      cleaned = text.length > 50 ? '${text.substring(0, 50)}...' : text;
    }

    AppLogger.info('FoodName cleaned: "$cleaned"');

    // ⭐ ลบการ match จาก food_names.json ออก - ให้ใช้แค่ชื่อที่ user พิมพ์มา
    // My Meal และ Ingredient จะถูกค้นหาในขั้นตอนอื่นแทน
    
    return cleaned;
  }

  /// Extract serving size from text
  Map<String, dynamic>? _extractServingSize(String text) {
    final lowerText = text.toLowerCase();
    
    final patterns = [
      RegExp(r'(\d+(?:\.\d+)?)\s*(plate|cup|cups|piece|pieces|g|kg|ml|l|gram|grams|item|items|unit|units|serving|servings)', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(lowerText);
      if (match != null) {
        final size = double.tryParse(match.group(1)!);
        final unit = match.group(2)!;
        
        if (size != null && size > 0 && size < 1000) {
          String resolvedUnit = unit;
          const unitAliases = {
            'plates': 'plate', 'cups': 'cup', 'pieces': 'piece',
            'items': 'piece', 'item': 'piece', 'units': 'serving', 'unit': 'serving',
            'gram': 'g', 'grams': 'g',
            'milliliter': 'ml', 'milliliters': 'ml',
            'liter': 'l', 'liters': 'l',
            'ounce': 'oz', 'ounces': 'oz',
            'pound': 'lbs', 'pounds': 'lbs',
          };
          resolvedUnit = unitAliases[unit.toLowerCase()] ?? unit;
          resolvedUnit = UnitConverter.ensureValid(resolvedUnit);
          
          return {'size': size, 'unit': resolvedUnit};
        }
      }
    }
    
    return null;
  }

  /// Extract create meal info from text
  Map<String, dynamic> _extractCreateMealInfo(String text) {
    String mealName = '';
    final ingredients = <Map<String, dynamic>>[];

    // Extract meal name
    final namePatterns = [
      RegExp(r'(?:create meal|new meal|add meal|new recipe|save recipe)\s+(.+?)(?:\s+ingredients|\s+with)', caseSensitive: false),
      RegExp(r'(?:create meal|new meal|add meal)\s+(.+)', caseSensitive: false),
    ];

    for (final pattern in namePatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        mealName = match.group(1)?.trim() ?? '';
        if (mealName.isNotEmpty) break;
      }
    }

    // Extract ingredients
    String ingredientsText = '';
    final ingStartPatterns = [
      RegExp(r'(?:ingredients|with|contains)[:.]?\s*(.+)', caseSensitive: false),
    ];

    for (final pattern in ingStartPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        ingredientsText = match.group(1)?.trim() ?? '';
        break;
      }
    }

    if (ingredientsText.isNotEmpty) {
      final ingPattern = RegExp(
        r'([a-zA-Z\s]+?)\s*(\d+(?:\.\d+)?)\s*(g|kg|ml|l|cup|tbsp|tsp|piece|pieces|oz|lbs)',
        caseSensitive: false,
      );

      final matches = ingPattern.allMatches(ingredientsText);
      for (final match in matches) {
        final name = match.group(1)?.trim() ?? '';
        final amountStr = match.group(2) ?? '0';
        final unit = match.group(3) ?? 'g';

        if (name.isNotEmpty) {
          ingredients.add({
            'name': name,
            'amount': double.tryParse(amountStr) ?? 0,
            'unit': unit,
          });
        }
      }
    }

    AppLogger.info('Create Meal: name="$mealName", ingredients=${ingredients.length}');

    return {
      'name': mealName,
      'ingredients': ingredients,
    };
  }

  /// Extract exclude ingredients from text
  static List<String> _extractExcludeIngredients(String text) {
    final excludes = <String>[];
    
    final patterns = [
      RegExp(r'no\s+(\w+)', caseSensitive: false),
      RegExp(r'without\s+(\w+)', caseSensitive: false),
      RegExp(r'exclude\s+(\w+)', caseSensitive: false),
      RegExp(r'remove\s+(\w+)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final matches = pattern.allMatches(text);
      for (final match in matches) {
        final ingredient = match.group(1)?.trim();
        if (ingredient != null && ingredient.isNotEmpty && ingredient.length > 1) {
          excludes.add(ingredient);
        }
      }
    }

    return excludes;
  }
}
