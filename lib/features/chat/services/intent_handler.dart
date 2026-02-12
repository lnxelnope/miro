import 'dart:convert';
import 'package:isar/isar.dart';
import '../../../core/ai/llm_service.dart';
import '../../../core/database/database_service.dart';
import '../../../core/constants/enums.dart';
import '../../../core/utils/logger.dart';
import '../../health/models/food_entry.dart';
import '../models/action_result.dart';
import 'food_lookup_service.dart';
import '../../health/providers/my_meal_provider.dart';

/// Service for handling intents and creating entries (Food only for v1.0)
class IntentHandler {
  final LLMService _llmService = LLMService();

  /// Process message and execute based on intent
  Future<IntentResponse> processMessage(String message, {String pageContext = 'health'}) async {
    try {
      // 1. Use AI to analyze text
      final jsonResult = await _llmService.classifyAndParse(message, pageContext: pageContext);
      final parsed = jsonDecode(jsonResult);

      final type = parsed['type'] as String? ?? 'unknown';
      final title = parsed['title'] as String? ?? message;
      final category = parsed['category'] as String? ?? 'Other';

      AppLogger.info('AI Result: type=$type, title=$title');

      // 2. Execute based on type
      switch (type) {
        case 'health':
          return await _handleHealth(message, title, category, parsed);
        case 'create_meal':
          return await _handleCreateMeal(message, title, parsed);
        case 'finance':
        case 'task':
        case 'reminder':
          return IntentResponse(
            replyMessage: 'Sorry, this feature is not available in this version.\n'
                'Currently only food logging is supported.',
            actionResult: ActionResult.failure('Feature not available in v1.0'),
          );
        case 'query':
          return await _handleQuery(message, parsed);
        case 'edit':
          return IntentResponse(
            replyMessage: '✏️ Edit feature is under development\n\n'
                'You can edit entries directly from the data screen.',
            actionResult: null,
          );
        case 'delete':
          return IntentResponse(
            replyMessage: '🗑️ Delete feature is under development\n\n'
                'You can delete entries directly from the data screen.',
            actionResult: null,
          );
        default:
          return IntentResponse(
            replyMessage: _getHelpMessage(),
            actionResult: null,
          );
      }
    } catch (e) {
      AppLogger.error('IntentHandler error', e);
      return IntentResponse(
        replyMessage: '❌ An error occurred: $e\n\nPlease try again.',
        actionResult: ActionResult.failure('Error: $e'),
      );
    }
  }

  /// Handle Health Intent (Food only)
  Future<IntentResponse> _handleHealth(
    String original,
    String title,
    String category,
    Map<String, dynamic> parsed,
  ) async {
    AppLogger.info('[IntentHandler] _handleHealth: category=$category, title=$title');
    
    if (category == 'Food' || original.toLowerCase().contains('eat') || original.toLowerCase().contains('ate') || original.toLowerCase().contains('had')) {
      // Extract date
      DateTime entryDate = DateTime.now();
      if (parsed['date'] != null) {
        final parsedDate = DateTime.tryParse(parsed['date'] as String);
        if (parsedDate != null) entryDate = parsedDate;
      }
      
      // Extract meal type
      final mealTypeStr = parsed['meal_type'] as String?;
      final mealType = mealTypeStr != null 
          ? _mapMealTypeFromString(mealTypeStr) 
          : _detectMealType();

      // Detect multiple food items
      final cleanedFoodText = _cleanFoodText(original);
      final foodItems = _splitMultipleFoods(cleanedFoodText);
      
      if (foodItems.length > 1) {
        AppLogger.info('Found ${foodItems.length} food items: $foodItems');
        return await _handleMultipleFoods(foodItems, mealType, entryDate);
      }

      // Single food
      var servingSizeFromAI = (parsed['serving_size'] as num?)?.toDouble() ?? 1.0;
      var servingUnitFromAI = parsed['serving_unit'] as String? ?? 'serving';
      
      // Validate unreasonable serving
      if ((servingUnitFromAI == 'g' || servingUnitFromAI == 'ml') && servingSizeFromAI <= 1) {
        AppLogger.warn('serving "$servingSizeFromAI $servingUnitFromAI" is unreasonable → fallback "1 serving"');
        servingSizeFromAI = 1.0;
        servingUnitFromAI = 'serving';
      }
      final servingGramsFromAI = (parsed['serving_grams'] as num?)?.toDouble();
      final excludeIngredients = (parsed['exclude_ingredients'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [];
      final isCreateMeal = parsed['is_create_meal'] as bool? ?? false;

      // Search from MyMeal / Ingredient DB
      final lookupResult = await FoodLookupService.lookup(
        foodName: title,
        servingSize: servingSizeFromAI,
        servingUnit: servingUnitFromAI,
        excludeIngredients: excludeIngredients,
      );

      AppLogger.info('Lookup result: ${lookupResult.type}');

      // Create FoodEntry
      final calories = lookupResult.calories;
      final protein = lookupResult.protein;
      final carbs = lookupResult.carbs;
      final fat = lookupResult.fat;

      DataSource source;
      switch (lookupResult.type) {
        case FoodLookupType.fromMeal:
        case FoodLookupType.fromIngredient:
          source = DataSource.aiAnalyzed;
          break;
        case FoodLookupType.notFound:
          source = DataSource.manual;
          break;
      }

      // Choose food name
      String foodName;
      if (lookupResult.type == FoodLookupType.notFound) {
        foodName = cleanedFoodText.isNotEmpty
            ? (cleanedFoodText.length > 80
                ? '${cleanedFoodText.substring(0, 80)}...'
                : cleanedFoodText)
            : lookupResult.displayName;
        AppLogger.info('Using original text as food name: "$foodName"');
      } else {
        foodName = lookupResult.displayName;
      }

      final entry = FoodEntry()
        ..foodName = foodName
        ..calories = calories
        ..protein = protein
        ..carbs = carbs
        ..fat = fat
        ..baseCalories = servingSizeFromAI > 0 ? calories / servingSizeFromAI : calories
        ..baseProtein = servingSizeFromAI > 0 ? protein / servingSizeFromAI : protein
        ..baseCarbs = servingSizeFromAI > 0 ? carbs / servingSizeFromAI : carbs
        ..baseFat = servingSizeFromAI > 0 ? fat / servingSizeFromAI : fat
        ..mealType = mealType
        ..timestamp = entryDate
        ..servingSize = servingSizeFromAI
        ..servingUnit = servingUnitFromAI
        ..servingGrams = servingGramsFromAI
        ..myMealId = lookupResult.meal?.id
        ..ingredientId = lookupResult.ingredient?.id
        ..source = source
        ..isVerified = lookupResult.type != FoodLookupType.notFound
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.foodEntries.put(entry);
      });

      AppLogger.info('FoodEntry saved: id=${entry.id}');

      // Build reply message
      String replyMessage;
      
      switch (lookupResult.type) {
        case FoodLookupType.fromMeal:
          String macrosText = '';
          if (protein > 0 || carbs > 0 || fat > 0) {
            macrosText = '\n💪 P: ${protein.toInt()}g | C: ${carbs.toInt()}g | F: ${fat.toInt()}g';
          }
          String modifierText = '';
          if (lookupResult.removedIngredients.isNotEmpty) {
            final removedNames = lookupResult.removedIngredients.map((e) => e.ingredientName).join(', ');
            final removedCal = lookupResult.removedIngredients.fold<double>(0, (sum, e) => sum + e.calories);
            modifierText = '\n🚫 Excluded: $removedNames (-${removedCal.toInt()} kcal)';
          }
          String dateText = _getDateText(entryDate);
          
          replyMessage = '✅ Food logged!\n\n'
              '🍽️ **${lookupResult.displayName}** (${_getMealTypeText(mealType)})'
              '$dateText\n'
              '🔥 ${calories.toInt()} kcal'
              '$macrosText'
              '$modifierText\n\n'
              '📂 _From My Meal_\n'
              '_Edit at Health screen_';
          break;

        case FoodLookupType.fromIngredient:
          String dateText = _getDateText(entryDate);
          
          replyMessage = '✅ Food logged!\n\n'
              '🥬 **${lookupResult.displayName}** (${_getMealTypeText(mealType)})'
              '$dateText\n'
              '🔥 ${calories.toInt()} kcal\n'
              '💪 P: ${protein.toInt()}g | C: ${carbs.toInt()}g | F: ${fat.toInt()}g\n\n'
              '📂 _From ingredient database_\n'
              '_Edit at Health screen_';
          break;

        case FoodLookupType.notFound:
          String dateText = _getDateText(entryDate);
          String createMealHint = '';
          if (isCreateMeal) {
            createMealHint = '\n\n🆕 Want to create a new meal? Go to My Meal > Create New Meal';
          }
          
          replyMessage = '✅ Food logged!\n\n'
              '🍽️ **$foodName** (${_getMealTypeText(mealType)})'
              '$dateText\n'
              '🔥 0 kcal\n\n'
              '⚠️ _No nutrition data yet_\n'
              '💡 _Tap Gemini at Health screen to analyze_'
              '$createMealHint\n\n'
              '_Edit at Health screen_';
          break;
      }

      return IntentResponse(
        replyMessage: replyMessage,
        actionResult: ActionResult.success(
          message: 'Food logged successfully',
          entryType: 'food',
          entryId: entry.id,
          data: {
            'name': foodName, 
            'calories': calories,
            'protein': protein,
            'carbs': carbs,
            'fat': fat,
            'date': entryDate.toIso8601String(),
            'mealType': mealType.name,
            'lookupType': lookupResult.type.name,
          },
        ),
      );
    }

    return IntentResponse(
      replyMessage: '🍎 What would you like to log?\n\n'
          'Try saying:\n'
          '• "ate fried rice"\n'
          '• "yesterday ate papaya salad"\n'
          '• "had 2 eggs for breakfast"',
      actionResult: null,
    );
  }
  
  // ============================================
  // MULTI-FOOD HANDLING
  // ============================================

  /// Remove prefixes/meal words/suffixes, keep only food name
  String _cleanFoodText(String original) {
    String cleaned = original;
    
    // Remove time prefixes (today, yesterday, tomorrow, etc.)
    for (int i = 0; i < 3; i++) {
      cleaned = cleaned
        .replaceAll(RegExp(r'^\s*(today|yesterday|tomorrow|now|just|this morning|this afternoon|this evening)\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'^\s*(I |i |we |We )', caseSensitive: false), '');
    }
    
    // Remove action verbs (casual forms)
    cleaned = cleaned
      .replaceAll(RegExp(r'\s*(ate|eat|eating|had|have|having|drank|drink|drinking|got|get|getting)\s+', caseSensitive: false), ' ')
      .replaceAll(RegExp(r'\s*(just had|just ate|just got)\s+', caseSensitive: false), ' ');
    
    // Remove suffixes (politeness, time context)
    cleaned = cleaned
      .replaceAll(RegExp(r'\s*(please|thanks|thank you|thx|pls)\s*$', caseSensitive: false), '')
      .replaceAll(RegExp(r'\s*(today|for lunch|for dinner|for breakfast|for snack)\s*$', caseSensitive: false), '');
    
    // Remove meal type words (but keep them in food names like "breakfast burrito")
    cleaned = cleaned
      .replaceAll(RegExp(r'^\s*(for\s+)?(breakfast|lunch|dinner|snack|meal)[:\s]+', caseSensitive: false), ' ')
      .replaceAll(RegExp(r'\s+(as|for)\s+(breakfast|lunch|dinner|snack|meal)\s*$', caseSensitive: false), ' ');
    
    // Clean up whitespace
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return cleaned;
  }

  /// Split multiple food items from single text
  List<String> _splitMultipleFoods(String foodText) {
    if (foodText.trim().length < 4) return [foodText];
    
    // 1. Comma-separated (handle both English and Asian commas)
    if (RegExp(r'[,，、]').hasMatch(foodText)) {
      final items = foodText.split(RegExp(r'[,，、]\s*'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty && s.length >= 2)
          .toList();
      if (items.length > 1) return items;
    }
    
    // 2. "and" / "with" / "plus" conjunctions (casual speech)
    // This is PRIMARY for English — prioritize splitting by conjunction
    final conjPattern = RegExp(
      r'\s+(?:and|with|plus|also|then)\s+(?:another\s+)?(?:one\s+)?',
      caseSensitive: false
    );
    if (conjPattern.hasMatch(foodText)) {
      final items = foodText.split(conjPattern)
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty && s.length >= 2)
          .toList();
      if (items.length > 1) {
        AppLogger.info('Split by conjunction: ${items.length} items');
        return items;
      }
    }
    
    // 3. Food database matching (for Thai text or known dishes)
    // Skip this for English text with conjunctions (already handled above)
    final dbItems = _splitByFoodDatabase(foodText);
    if (dbItems.length > 1) return dbItems;
    
    // 4. Single item
    return [foodText];
  }

  /// Use food database to find food names in text and split accordingly
  /// Supports both Thai and English food names
  List<String> _splitByFoodDatabase(String text) {
    final foodDb = LLMService.foodDatabase;
    if (foodDb == null || foodDb.isEmpty) return [text];
    
    final lowerText = text.toLowerCase();
    
    final matches = <({int pos, int len, String name})>[];
    
    for (final food in foodDb) {
      // Check Thai name
      final th = ((food['th'] as String?) ?? '').toLowerCase();
      if (th.length >= 2) {
        int pos = lowerText.indexOf(th);
        if (pos >= 0) {
          matches.add((pos: pos, len: th.length, name: food['th'] as String));
          continue;
        }
        
        // Try normalized Thai
        final normalized = LLMService.normalizeThaiFood(th);
        if (normalized != th) {
          pos = lowerText.indexOf(normalized);
          if (pos >= 0) {
            matches.add((pos: pos, len: normalized.length, name: food['th'] as String));
            continue;
          }
        }
        
        // Try normalizing the input text
        final reverseLower = LLMService.normalizeThaiFood(lowerText);
        pos = reverseLower.indexOf(th);
        if (pos >= 0 && pos < lowerText.length) {
          matches.add((pos: pos, len: th.length, name: food['th'] as String));
          continue;
        }
      }
      
      // Check English name
      final en = ((food['en'] as String?) ?? '').toLowerCase();
      if (en.length >= 3) {
        final pos = lowerText.indexOf(en);
        if (pos >= 0) {
          matches.add((pos: pos, len: en.length, name: food['en'] as String));
        }
      }
    }
    
    if (matches.isEmpty) return [text];
    
    // Sort by position
    matches.sort((a, b) => a.pos.compareTo(b.pos));
    
    // Remove overlapping matches (keep longest)
    final filtered = <({int pos, int len, String name})>[];
    for (final m in matches) {
      bool overlaps = false;
      for (int i = 0; i < filtered.length; i++) {
        if (m.pos < filtered[i].pos + filtered[i].len && 
            m.pos + m.len > filtered[i].pos) {
          // Overlap detected — keep the longer match
          if (m.len > filtered[i].len) {
            filtered[i] = m;
          }
          overlaps = true;
          break;
        }
      }
      if (!overlaps) filtered.add(m);
    }
    
    filtered.sort((a, b) => a.pos.compareTo(b.pos));
    
    if (filtered.isEmpty) return [text];
    
    // Single match — check if there's text before/after
    if (filtered.length == 1) {
      if (filtered[0].pos > 2) {
        final before = text.substring(0, filtered[0].pos).trim();
        final after = text.substring(filtered[0].pos).trim();
        if (before.length >= 2 && after.length >= 2) {
          return [before, after];
        }
      }
      return [text];
    }
    
    // Multiple matches — extract segments
    final items = <String>[];
    
    // Text before first match
    if (filtered[0].pos > 0) {
      final before = text.substring(0, filtered[0].pos).trim();
      if (before.length >= 2) items.add(before);
    }
    
    // Extract each match and text between matches
    for (int i = 0; i < filtered.length; i++) {
      final start = filtered[i].pos;
      final end = i + 1 < filtered.length ? filtered[i + 1].pos : text.length;
      final item = text.substring(start, end).trim();
      if (item.length >= 2) items.add(item);
    }
    
    return items;
  }

  /// Extract serving info from food name
  /// Handles various casual patterns like "2 eggs", "fried rice 1 plate", "another coffee"
  ({String cleanedName, double size, String unit}) _extractServingFromItem(String foodItem) {
    // Convert word numbers to digits first
    String normalized = _normalizeWordNumbers(foodItem);
    
    // Pattern 1: Standard "number + unit" at the end
    // Examples: "fried rice 1 plate", "eggs 2 piece", "coffee 250 ml"
    final standardPattern = RegExp(
      r'(?:\s*another\s*)?(\d+(?:\.\d+)?)\s*(plate|plates|cup|cups|bowl|bowls|piece|pieces|box|boxes|pack|packs|bag|bags|bottle|bottles|glass|glasses|egg|eggs|ball|balls|item|items|slice|slices|pair|pairs|stick|sticks|g|gram|grams|kg|ml|milliliter|milliliters|l|liter|liters|serving|servings|tbsp|tsp|oz|ounce|ounces|lbs|pound|pounds)\s*(?:of)?\s*$',
      caseSensitive: false,
    );
    var match = standardPattern.firstMatch(normalized);
    
    if (match != null) {
      final size = double.tryParse(match.group(1)!) ?? 1.0;
      final rawUnit = match.group(2)!.toLowerCase();
      // Normalize plural forms
      final unit = _normalizeUnit(rawUnit);
      final cleanedName = normalized.substring(0, match.start).trim();
      return (
        cleanedName: cleanedName.isEmpty ? foodItem.trim() : cleanedName, 
        size: size, 
        unit: unit,
      );
    }
    
    // Pattern 2: "number + unit" at the beginning
    // Examples: "2 eggs", "3 plates fried rice", "250 ml water"
    final prefixPattern = RegExp(
      r'^(?:another\s+)?(\d+(?:\.\d+)?)\s*(plate|plates|cup|cups|bowl|bowls|piece|pieces|box|boxes|pack|packs|bag|bags|bottle|bottles|glass|glasses|egg|eggs|ball|balls|item|items|slice|slices|pair|pairs|stick|sticks|g|gram|grams|kg|ml|milliliter|milliliters|l|liter|liters|serving|servings|tbsp|tsp|oz|ounce|ounces|lbs|pound|pounds)\s+(?:of\s+)?',
      caseSensitive: false,
    );
    match = prefixPattern.firstMatch(normalized);
    
    if (match != null) {
      final size = double.tryParse(match.group(1)!) ?? 1.0;
      final rawUnit = match.group(2)!.toLowerCase();
      final unit = _normalizeUnit(rawUnit);
      final cleanedName = normalized.substring(match.end).trim();
      return (
        cleanedName: cleanedName.isEmpty ? foodItem.trim() : cleanedName, 
        size: size, 
        unit: unit,
      );
    }
    
    // Pattern 3: "another X" without explicit number (implies 1 more)
    if (normalized.toLowerCase().startsWith('another ')) {
      final cleanedName = normalized.substring(8).trim(); // Remove "another "
      return (cleanedName: cleanedName, size: 1.0, unit: 'serving');
    }
    
    // No pattern matched
    return (cleanedName: foodItem.trim(), size: 1.0, unit: 'serving');
  }
  
  /// Convert word numbers (one, two, three...) to digits
  String _normalizeWordNumbers(String text) {
    const wordToNumber = {
      'one': '1', 'two': '2', 'three': '3', 'four': '4', 'five': '5',
      'six': '6', 'seven': '7', 'eight': '8', 'nine': '9', 'ten': '10',
      'eleven': '11', 'twelve': '12', 'thirteen': '13', 'fourteen': '14', 'fifteen': '15',
      'sixteen': '16', 'seventeen': '17', 'eighteen': '18', 'nineteen': '19', 'twenty': '20',
    };
    
    String result = text;
    wordToNumber.forEach((word, number) {
      // Match whole word only
      result = result.replaceAllMapped(
        RegExp('\\b$word\\b', caseSensitive: false),
        (match) => number,
      );
    });
    
    return result;
  }
  
  /// Normalize plural unit forms to singular
  String _normalizeUnit(String unit) {
    const unitMap = {
      'plates': 'plate',
      'cups': 'cup',
      'bowls': 'bowl',
      'pieces': 'piece',
      'boxes': 'box',
      'packs': 'pack',
      'bags': 'bag',
      'bottles': 'bottle',
      'glasses': 'glass',
      'eggs': 'egg',
      'balls': 'ball',
      'items': 'item',
      'slices': 'slice',
      'pairs': 'pair',
      'sticks': 'stick',
      'grams': 'g',
      'gram': 'g',
      'milliliters': 'ml',
      'milliliter': 'ml',
      'liters': 'l',
      'liter': 'l',
      'servings': 'serving',
      'ounces': 'oz',
      'ounce': 'oz',
      'pounds': 'lbs',
      'pound': 'lbs',
    };
    return unitMap[unit.toLowerCase()] ?? unit.toLowerCase();
  }

  /// Handle multiple food items in single message
  Future<IntentResponse> _handleMultipleFoods(
    List<String> foodItems,
    MealType mealType,
    DateTime entryDate,
  ) async {
    final entries = <FoodEntry>[];
    final replyParts = <String>[];
    
    for (final rawItem in foodItems) {
      final servingInfo = _extractServingFromItem(rawItem);
      final foodName = servingInfo.cleanedName;
      var servingSize = servingInfo.size;
      var servingUnit = servingInfo.unit;
      
      if ((servingUnit == 'g' || servingUnit == 'ml') && servingSize <= 1) {
        servingSize = 1.0;
        servingUnit = 'serving';
      }
      
      AppLogger.info('Multi-food item: "$foodName" ($servingSize $servingUnit)');
      
      final lookupResult = await FoodLookupService.lookup(
        foodName: foodName,
        servingSize: servingSize,
        servingUnit: servingUnit,
      );
      
      final calories = lookupResult.calories;
      final protein = lookupResult.protein;
      final carbs = lookupResult.carbs;
      final fat = lookupResult.fat;
      
      DataSource source;
      switch (lookupResult.type) {
        case FoodLookupType.fromMeal:
        case FoodLookupType.fromIngredient:
          source = DataSource.aiAnalyzed;
          break;
        case FoodLookupType.notFound:
          source = DataSource.manual;
          break;
      }
      
      final displayName = lookupResult.type == FoodLookupType.notFound
          ? foodName
          : lookupResult.displayName;
      
      final entry = FoodEntry()
        ..foodName = displayName
        ..calories = calories
        ..protein = protein
        ..carbs = carbs
        ..fat = fat
        ..baseCalories = servingSize > 0 ? calories / servingSize : calories
        ..baseProtein = servingSize > 0 ? protein / servingSize : protein
        ..baseCarbs = servingSize > 0 ? carbs / servingSize : carbs
        ..baseFat = servingSize > 0 ? fat / servingSize : fat
        ..mealType = mealType
        ..timestamp = entryDate
        ..servingSize = servingSize
        ..servingUnit = servingUnit
        ..myMealId = lookupResult.meal?.id
        ..ingredientId = lookupResult.ingredient?.id
        ..source = source
        ..isVerified = lookupResult.type != FoodLookupType.notFound
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();
      
      entries.add(entry);
      
      final calText = calories > 0 ? '${calories.toInt()} kcal' : '0 kcal';
      final sourceIcon = lookupResult.type == FoodLookupType.fromMeal 
          ? '📂' 
          : lookupResult.type == FoodLookupType.fromIngredient ? '🥬' : '⚠️';
      replyParts.add('$sourceIcon **$displayName** ($servingSize $servingUnit) — $calText');
    }
    
    // Save all entries
    await DatabaseService.isar.writeTxn(() async {
      for (final entry in entries) {
        await DatabaseService.foodEntries.put(entry);
      }
    });
    
    AppLogger.info('Saved ${entries.length} food entries successfully');
    
    final dateText = _getDateText(entryDate);
    final itemsList = replyParts.map((p) => '  • $p').join('\n');
    final totalCal = entries.fold<double>(0, (sum, e) => sum + e.calories);
    final hasUnknown = entries.any((e) => e.source == DataSource.manual);
    
    String replyMessage = '✅ Logged ${entries.length} items! (${_getMealTypeText(mealType)})'
        '$dateText\n\n'
        '$itemsList\n\n'
        '🔥 Total: ${totalCal.toInt()} kcal';
    
    if (hasUnknown) {
      replyMessage += '\n\n⚠️ _Some items have no nutrition data yet_\n'
          '💡 _Tap Gemini at Health screen to analyze_';
    }
    
    return IntentResponse(
      replyMessage: replyMessage,
      actionResult: ActionResult.success(
        message: 'Logged ${entries.length} food items successfully',
        entryType: 'food',
        entryId: entries.first.id,
        data: {
          'name': entries.map((e) => e.foodName).join(', '),
          'calories': totalCal,
          'count': entries.length,
          'date': entryDate.toIso8601String(),
          'mealType': mealType.name,
        },
      ),
    );
  }

  /// Convert String meal type to MealType enum
  MealType _mapMealTypeFromString(String mealTypeStr) {
    switch (mealTypeStr.toLowerCase()) {
      case 'breakfast':
      case 'morning':
        return MealType.breakfast;
      case 'lunch':
      case 'noon':
      case 'midday':
        return MealType.lunch;
      case 'dinner':
      case 'evening':
        return MealType.dinner;
      case 'snack':
      default:
        return MealType.snack;
    }
  }

  /// Handle Create Meal Intent
  Future<IntentResponse> _handleCreateMeal(
    String original,
    String title,
    Map<String, dynamic> parsed,
  ) async {
    AppLogger.info('_handleCreateMeal');

    final mealName = (parsed['meal_name'] as String?)?.trim() ?? '';
    final ingredientsRaw = parsed['ingredients_raw'] as List<dynamic>? ?? [];

    if (mealName.isEmpty) {
      return IntentResponse(
        replyMessage: '🍽️ Please specify the meal name\n\n'
            'Try saying:\n'
            '• "Create new meal **fried rice** ingredients: rice 200g shrimp 100g egg 1 piece"\n'
            '• "Add meal pad thai ingredients: noodle 200g tofu 50g"',
        actionResult: null,
      );
    }

    if (ingredientsRaw.isEmpty) {
      return IntentResponse(
        replyMessage: '🍽️ Please specify ingredients\n\n'
            'Try saying:\n'
            '• "Create new meal $mealName **ingredients:** rice 200g egg 1 piece"\n\n'
            'Specify ingredient name + amount + unit',
        actionResult: null,
      );
    }

    // Create MealIngredientInput
    final inputs = <MealIngredientInput>[];
    for (final raw in ingredientsRaw) {
      if (raw is Map) {
        final name = (raw['name'] as String?)?.trim() ?? '';
        final amount = (raw['amount'] as num?)?.toDouble() ?? 0;
        final unit = (raw['unit'] as String?) ?? 'g';

        if (name.isNotEmpty && amount > 0) {
          inputs.add(MealIngredientInput(
            name: name,
            amount: amount,
            unit: unit,
            calories: 0,
            protein: 0,
            carbs: 0,
            fat: 0,
          ));
        }
      }
    }

    if (inputs.isEmpty) {
      return IntentResponse(
        replyMessage: '🍽️ Cannot read ingredients\n\n'
            'Try this format:\n'
            '• "Create new meal $mealName ingredients: **rice 200g** **egg 1 piece**"\n\n'
            'Specify **ingredient name + amount + unit** for each',
        actionResult: null,
      );
    }

    // Create MyMeal
    try {
      final notifier = MyMealNotifier();
      final meal = await notifier.createMeal(
        name: mealName,
        baseServingDescription: '1 plate',
        ingredients: inputs,
        source: 'manual',
      );

      AppLogger.info('MyMeal created successfully: ${meal.name} (id=${meal.id})');

      final ingredientLines = inputs.map((inp) => '  • ${inp.name} ${inp.amount.toStringAsFixed(0)} ${inp.unit}').join('\n');

      return IntentResponse(
        replyMessage: '✅ New meal created!\n\n'
            '🍽️ **$mealName**\n\n'
            '📋 Ingredients (${inputs.length} items):\n'
            '$ingredientLines\n\n'
            '⚠️ _Nutrition values are 0 — analyze with Gemini or edit at My Meal screen_\n\n'
            '💡 Next time type "ate $mealName" to log instantly',
        actionResult: ActionResult.success(
          message: 'New meal created successfully',
          entryType: 'myMeal',
          entryId: meal.id,
          data: {
            'name': mealName,
            'ingredientCount': inputs.length,
          },
        ),
      );
    } catch (e) {
      AppLogger.error('Error creating meal', e);
      return IntentResponse(
        replyMessage: '❌ Error creating meal: $e\n\nPlease try again',
        actionResult: ActionResult.failure('Error: $e'),
      );
    }
  }

  /// Handle Query Intent (calories only for v1.0)
  Future<IntentResponse> _handleQuery(
    String original,
    Map<String, dynamic> parsedData,
  ) async {
    final queryType = parsedData['query_type'] as String? ?? 'unknown';
    final period = parsedData['period'] as String? ?? 'today';
    
    AppLogger.info('Query: type=$queryType, period=$period');
    
    final now = DateTime.now();
    DateTime startDate;
    String periodText;
    
    switch (period) {
      case 'week':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        periodText = 'this week';
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        periodText = 'this month';
        break;
      default:
        startDate = DateTime(now.year, now.month, now.day);
        periodText = 'today';
    }
    
    if (queryType == 'calories' || queryType == 'unknown') {
      // Query food entries
      final entries = await DatabaseService.foodEntries
          .filter()
          .timestampGreaterThan(startDate, include: true)
          .findAll();
      
      final totalCalories = entries.fold<double>(0, (sum, e) => sum + e.calories);
      final count = entries.length;
      
      return IntentResponse(
        replyMessage: '📊 **Calories Summary ($periodText)**\n\n'
            '🔥 Total: ${totalCalories.toInt()} kcal\n'
            '🍽️ Meals: $count\n'
            '📈 Average: ${count > 0 ? (totalCalories / count).toInt() : 0} kcal/meal',
        actionResult: null,
      );
    }
    
    return IntentResponse(
      replyMessage: '🔍 What would you like to see?\n\n'
          'Try asking:\n'
          '• "How many calories today?"\n'
          '• "Calorie summary this week"',
      actionResult: null,
    );
  }

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Detect meal type from current time
  MealType _detectMealType() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 10) return MealType.breakfast;
    if (hour >= 10 && hour < 14) return MealType.lunch;
    if (hour >= 14 && hour < 17) return MealType.snack;
    if (hour >= 17 && hour < 21) return MealType.dinner;
    return MealType.snack;
  }

  String _getMealTypeText(MealType type) {
    return type.displayName;
  }

  /// Helper: Create date text for reply
  String _getDateText(DateTime entryDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDateOnly = DateTime(entryDate.year, entryDate.month, entryDate.day);
    if (entryDateOnly != today) {
      return '\n📅 ${_formatDate(entryDate)}';
    }
    return '';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == today.add(const Duration(days: 1))) return 'Tomorrow';
    if (dateOnly == today.subtract(const Duration(days: 1))) return 'Yesterday';

    return '${date.day}/${date.month}/${date.year}';
  }

  String _getHelpMessage() {
    return '🤔 I didn\'t understand that.\n\n'
        'Try telling me about:\n'
        '• 🍽️ **Food**: "ate fried rice 500 kcal"\n'
        '• 📷 **Photo**: Take a photo of your food\n'
        '• 📊 **Summary**: "How many calories today?"\n\n'
        'Type "help" for more info';
  }
}

/// Response from Intent Handler
class IntentResponse {
  final String replyMessage;
  final ActionResult? actionResult;

  IntentResponse({
    required this.replyMessage,
    this.actionResult,
  });
}
