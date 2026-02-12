import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/secure_storage_service.dart';
import '../services/usage_limiter.dart';
import '../services/purchase_service.dart';
import '../utils/logger.dart';
import '../../features/profile/presentation/api_key_screen.dart';

class GeminiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';
  // Gemini 2.0 Flash - latest high-performance and fast model
  static const String _model = 'gemini-2.0-flash';

  // Check if API key is configured
  static Future<bool> hasApiKey() async {
    return await SecureStorageService.hasGeminiApiKey();
  }

  /// Test if API Key works
  /// Returns true if successful, throws error if not
  static Future<bool> testConnection() async {
    final apiKey = await SecureStorageService.getGeminiApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API Key not configured');
    }

    try {
      // Send simple request to test
      final url = Uri.parse('$_baseUrl/$_model:generateContent?key=$apiKey');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': 'Hi'}
              ]
            }
          ]
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return true;
      } else {
        final msg = response.body.toLowerCase();
        if (msg.contains('api key') || msg.contains('401') || msg.contains('invalid')) {
          throw Exception('Invalid API Key — please check and try again');
        }
        if (msg.contains('quota') || msg.contains('429')) {
          throw Exception('API quota exceeded — please wait and try again');
        }
        throw Exception('Connection failed: ${response.statusCode}');
      }
    } on http.ClientException {
      throw Exception('Connection timeout — please check your internet');
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('api key') || msg.contains('401') || msg.contains('invalid')) {
        throw Exception('Invalid API Key — please check and try again');
      }
      if (msg.contains('quota') || msg.contains('429')) {
        throw Exception('API quota exceeded — please wait a moment and try again');
      }
      if (msg.contains('timeout') || msg.contains('socket')) {
        throw Exception('Connection timeout — please check your internet');
      }
      throw Exception('Connection failed: ${e.toString()}');
    }
  }

  /// Check limit + record usage
  /// Returns true = can use → proceed
  /// Returns false = limit reached → show Upsell Dialog
  static Future<bool> checkAndConsumeUsage(BuildContext context) async {
    final canUse = await UsageLimiter.canUseAi();
    if (canUse) {
      // *** Don't record here ***
      // Record after Gemini call succeeds
      return true;
    }

    // Limit reached → show Upsell Dialog
    if (context.mounted) {
      _showUpgradeDialog(context);
    }
    return false;
  }

  /// Upsell Dialog
  static void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock, color: Colors.orange),
            SizedBox(width: 8),
            Expanded(child: Text('AI usage limit reached (3/day)')),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Unlock unlimited AI food analysis:'),
            SizedBox(height: 12),
            Text('✅ Unlimited food image analysis'),
            Text('✅ Unlimited AI nutrition lookup'),
            Text('✅ One-time payment, lifetime access'),
            SizedBox(height: 12),
            Text(
              '💡 You can still log food manually\nor wait until tomorrow for 3 new uses',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Later'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              PurchaseService.buyPro();
            },
            icon: const Icon(Icons.star),
            label: const Text('Upgrade to Pro'),
          ),
        ],
      ),
    );
  }

  /// Show dialog prompting user to set up API Key
  static void showNoApiKeyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.key_off, color: Colors.orange),
            SizedBox(width: 8),
            Expanded(child: Text('API Key Required')),
          ],
        ),
        content: const Text(
          'AI food analysis requires a Gemini API Key\n\n'
          'Create one for free! Takes just 5 minutes',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Later'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              // Navigate to API Key screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ApiKeyScreen()),
              );
            },
            icon: const Icon(Icons.settings),
            label: const Text('Set up API Key'),
          ),
        ],
      ),
    );
  }

  // Analyze food image
  static Future<FoodAnalysisResult?> analyzeFoodImage(File imageFile) async {
    AppLogger.info('Starting image analysis: ${imageFile.path}');
    
    // Check if file exists
    if (!await imageFile.exists()) {
      AppLogger.error('File not found: ${imageFile.path}');
      throw Exception('Image file not found');
    }
    
    final apiKey = await SecureStorageService.getGeminiApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      AppLogger.error('API Key not found');
      throw Exception('Gemini API Key not found - please configure in Settings → Profile → API Settings');
    }
    
    AppLogger.info('API Key found (${apiKey.substring(0, 10)}...)');

    try {
      // Read and encode image
      AppLogger.info('Reading image file...');
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      AppLogger.info('File read successfully: ${bytes.length} bytes (${(bytes.length / 1024).toStringAsFixed(1)} KB)');

      // Prepare request
      final url = Uri.parse('$_baseUrl/$_model:generateContent?key=$apiKey');
      AppLogger.debug('🌐 [GeminiService] URL: $_baseUrl/$_model:generateContent');
      
      final body = jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text': '''You are an AI expert in nutrition for global cuisine.
Analyze the food image and estimate nutritional values as accurately as possible.

Important:
- Break down each ingredient with quantity and nutritional values
- food_name: Detect the language in image/context and provide in ORIGINAL language (Thai, English, Japanese, etc.)
- food_name_en: MUST be the English translation for database purposes
- ingredient names: MUST be in English (for standardization)
- serving_unit must be appropriate for the food, e.g., "plate", "bowl", "cup", "piece", "glass", "egg", "ball", etc.
- Do NOT use "g" or "ml" as serving_unit for dishes/bowls/plates — use "serving" as fallback if unsure
- "g" is only used for individual ingredients in ingredients_detail

Respond in JSON format following this structure:
{
  "food_name": "Original name detected from image (e.g. ข้าวผัด, Fried Rice, 炒飯)",
  "food_name_en": "English translation (e.g. Fried Rice)",
  "confidence": 0.85,
  "serving_size": 1,
  "serving_unit": "plate",
  "serving_grams": 350,
  "nutrition": {
    "calories": 611,
    "protein": 27,
    "carbs": 57,
    "fat": 29,
    "fiber": 2,
    "sugar": 3,
    "sodium": 850
  },
  "ingredients_detail": [
    {
      "name": "Steamed Rice",
      "name_en": "Steamed Rice",
      "amount": 200,
      "unit": "g",
      "calories": 260,
      "protein": 5,
      "carbs": 56,
      "fat": 0.5
    },
    {
      "name": "Minced Pork",
      "name_en": "Minced Pork",
      "amount": 80,
      "unit": "g",
      "calories": 170,
      "protein": 16,
      "carbs": 0,
      "fat": 12
    }
  ],
  "ingredients": ["rice", "pork", "basil", "egg"],
  "notes": "Additional notes"
}''',
              },
              {
                'inline_data': {
                  'mime_type': 'image/jpeg',
                  'data': base64Image,
                },
              },
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.1,
          'topK': 32,
          'topP': 1,
          'maxOutputTokens': 2048,
          'response_mime_type': 'application/json',
        },
      });
      
      AppLogger.info('Sending request to Gemini API...');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 30));

      AppLogger.info('Received response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        AppLogger.debug('Response data keys: ${data.keys.toList()}');
        
        if (data['candidates'] == null || (data['candidates'] as List).isEmpty) {
          AppLogger.error('No candidates in response');
          throw Exception('Gemini API did not return results');
        }
        
        final candidate = data['candidates'][0];
        AppLogger.debug('Candidate keys: ${candidate.keys.toList()}');
        
        if (candidate['content'] == null) {
          AppLogger.error('No content in candidate');
          throw Exception('Gemini API response has no content');
        }
        
        final parts = candidate['content']['parts'] as List;
        if (parts.isEmpty) {
          AppLogger.error('❌ [GeminiService] No parts found in content');
          throw Exception('Gemini API response has no parts');
        }
        
        final text = parts[0]['text'] as String?;
        if (text == null || text.isEmpty) {
          AppLogger.error('❌ [GeminiService] No text found in parts');
          throw Exception('Gemini API returned no text');
        }
        
        AppLogger.debug('📝 [GeminiService] Received text: ${text.substring(0, text.length > 200 ? 200 : text.length)}...');
        
        // Parse JSON from response
        final jsonString = _extractJson(text);
        if (jsonString == null) {
          AppLogger.error('❌ [GeminiService] Cannot extract JSON');
          AppLogger.debug('📝 [GeminiService] Full text: $text');
          throw Exception('Cannot parse JSON from Gemini response');
        }
        
        AppLogger.info('✅ [GeminiService] JSON extracted successfully');
        final parsed = _convertToMap(jsonString);
        AppLogger.debug('📋 [GeminiService] Parsed JSON keys: ${parsed.keys.toList()}');
        
        final result = FoodAnalysisResult.fromJson(parsed);
        AppLogger.info('✅ [GeminiService] FoodAnalysisResult created successfully');
        return result;
      } else {
        AppLogger.error('❌ [GeminiService] API error: ${response.statusCode}');
        AppLogger.debug('📋 [GeminiService] Response body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
        
        // 404 or 400 may indicate incorrect model name
        if (response.statusCode == 404 || response.statusCode == 400) {
          AppLogger.warn('⚠️ [GeminiService] Model may be incorrect, trying gemini-1.5-flash');
          // Try fallback to gemini-1.5-flash
          return await _tryFallbackModel(imageFile, apiKey, base64Image);
        }
        
        final msg = response.body.toLowerCase();
        if (msg.contains('quota') || msg.contains('429')) {
          throw Exception('API quota exceeded — please wait and try again');
        }
        if (msg.contains('api key') || msg.contains('401')) {
          throw Exception('Invalid API Key — please check your settings');
        }
        throw Exception('Gemini API error: ${response.statusCode}');
      }
    } on TimeoutException {
      AppLogger.error('❌ [GeminiService] Timeout');
      throw Exception('Connection timeout — please try again');
    } on FormatException catch (e) {
      AppLogger.error('❌ [GeminiService] Format error', e);
      throw Exception('Cannot read AI result — please try again');
    } catch (e, stackTrace) {
      AppLogger.error('❌ [GeminiService] Exception', e, stackTrace);
      
      final msg = e.toString().toLowerCase();
      if (msg.contains('quota') || msg.contains('429')) {
        throw Exception('API quota exceeded — please wait a moment and try again');
      }
      if (msg.contains('api key') || msg.contains('401')) {
        throw Exception('Invalid API Key — please check your settings');
      }
      if (msg.contains('network') || msg.contains('socket')) {
        throw Exception('No internet connection — please check your network');
      }
      
      // Try fallback model if primary fails
      if (e.toString().contains('404') || e.toString().contains('400')) {
        AppLogger.warn('🔄 [GeminiService] Trying fallback model...');
        try {
          return await _tryFallbackModel(imageFile, apiKey, base64Encode(await imageFile.readAsBytes()));
        } catch (_) {
          // If fallback also fails, throw original error
        }
      }
      
      throw Exception('An error occurred — please try again');
    }
  }
  
  /// Fallback: try gemini-1.5-pro
  static Future<FoodAnalysisResult?> _tryFallbackModel(File imageFile, String apiKey, String base64Image) async {
    AppLogger.info('🔄 [GeminiService] Trying gemini-1.5-pro...');
    debugPrint('🔄 [GeminiService] Trying gemini-1.5-pro...');
    const fallbackModel = 'gemini-1.5-pro';
    final url = Uri.parse('$_baseUrl/$fallbackModel:generateContent?key=$apiKey');
    
    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {
              'text': '''You are an AI expert in nutrition for Thai and international foods.
Analyze food images and estimate nutritional values as accurately as possible.

Important: Break down each ingredient with quantity and nutritional values.

Respond in JSON format following this structure:
{
  "food_name": "Food name (in English)",
  "food_name_en": "English name",
  "confidence": 0.85,
  "serving_size": 1,
  "serving_unit": "plate",
  "serving_grams": 350,
  "nutrition": {
    "calories": 611,
    "protein": 27,
    "carbs": 57,
    "fat": 29,
    "fiber": 2,
    "sugar": 3,
    "sodium": 850
  },
  "ingredients_detail": [
    {
      "name": "Steamed Rice",
      "name_en": "Steamed Rice",
      "amount": 200,
      "unit": "g",
      "calories": 260,
      "protein": 5,
      "carbs": 56,
      "fat": 0.5
    },
    {
      "name": "Minced Pork",
      "name_en": "Minced Pork",
      "amount": 80,
      "unit": "g",
      "calories": 170,
      "protein": 16,
      "carbs": 0,
      "fat": 12
    }
  ],
  "ingredients": ["Rice", "Minced Pork", "Basil", "Egg"],
  "notes": "Additional notes"
}''',
            },
            {
              'inline_data': {
                'mime_type': 'image/jpeg',
                'data': base64Image,
              },
            },
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.1,
        'topK': 32,
        'topP': 1,
        'maxOutputTokens': 2048,
        'response_mime_type': 'application/json',
      },
    });
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
      final jsonString = _extractJson(text);
      if (jsonString != null) {
        try {
          final parsed = _convertToMap(jsonString);
          return FoodAnalysisResult.fromJson(parsed);
        } catch (e) {
          AppLogger.error('❌ [GeminiService] Error parsing fallback JSON', e);
        }
      }
    }
    
    return null;
  }

  /// Convert JSON string to Map, supporting both Map and List cases
  static Map<String, dynamic> _convertToMap(String jsonString) {
    final decoded = jsonDecode(jsonString);
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    } else if (decoded is List) {
      if (decoded.isNotEmpty && decoded[0] is Map) {
        return Map<String, dynamic>.from(decoded[0]);
      }
      throw Exception('JSON is a list but empty or doesn\'t contain a map');
    }
    throw Exception('JSON is neither a map nor a list of maps');
  }

  // Extract JSON from text
  static String? _extractJson(String text) {
    if (text.isEmpty) {
      AppLogger.error('❌ [GeminiService] Text is empty');
      return null;
    }
    
    AppLogger.debug('📝 [GeminiService] Original text length: ${text.length}');
    
    // Remove markdown code block if present (```json ... ```)
    String cleaned = text.trim();
    
    // Remove ```json or ``` at start and end
    if (cleaned.startsWith('```')) {
      final firstNewline = cleaned.indexOf('\n');
      if (firstNewline != -1) {
        cleaned = cleaned.substring(firstNewline + 1);
      } else {
        cleaned = cleaned.replaceFirst(RegExp(r'^```\w*\s*'), '');
      }
      
      if (cleaned.endsWith('```')) {
        cleaned = cleaned.substring(0, cleaned.length - 3).trim();
      }
    }
    
    // Method 1: Find first { and last } (most reliable for JSON)
    int startIndex = cleaned.indexOf('{');
    int endIndex = cleaned.lastIndexOf('}');
    
    if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
      String potentialJson = cleaned.substring(startIndex, endIndex + 1);
      try {
        jsonDecode(potentialJson);
        AppLogger.info('✅ [GeminiService] Found valid JSON (Method 1)');
        return potentialJson;
      } catch (e) {
        AppLogger.warn('⚠️ [GeminiService] Method 1 failed', e);
      }
    }
    
    // Method 2: If no closing } (may be truncated), try to recover
    if (startIndex != -1 && endIndex == -1) {
      AppLogger.warn('⚠️ [GeminiService] Detected truncated JSON (missing closing brace)');
      // In case of truncation, we may not be able to fully recover
      // but we'll log what was attempted
    }
    
    // Method 3: Try parsing the entire text directly
    try {
      jsonDecode(cleaned);
      AppLogger.info('✅ [GeminiService] Found valid JSON (Direct Parse)');
      return cleaned;
    } catch (e) {
      // Continue
    }
    
    AppLogger.error('❌ [GeminiService] Cannot extract JSON');
    AppLogger.debug('📝 [GeminiService] Text content: $text');
    return null;
  }

  /// Analyze product from image + barcode
  /// Used when scanning barcode with product packaging image
  static Future<FoodAnalysisResult?> analyzeBarcodedProduct(
    File imageFile,
    String barcodeValue,
  ) async {
    AppLogger.info('Analyzing product barcode: $barcodeValue');
    
    if (!await imageFile.exists()) {
      throw Exception('Image file not found');
    }
    
    final apiKey = await SecureStorageService.getGeminiApiKey();
    if (apiKey == null || apiKey.isEmpty) {
        throw Exception('Gemini API Key not found');
    }

    final imageBytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    final prompt = '''You are an AI expert in nutrition and food label reading.

This is an image of a product with barcode: $barcodeValue

Please:
1. Identify product name (if readable from packaging)
2. Read Nutrition Facts / nutritional information from label (if visible in image)
3. If no label visible, estimate from product type seen

Important: If nutrition label is visible, use values from label as primary (more accurate than estimation)

Respond in JSON format:
{
  "food_name": "Product name (in English)",
  "food_name_en": "English product name",
  "confidence": 0.95,
  "serving_size": 1,
  "serving_unit": "pack",
  "serving_grams": 30,
  "nutrition": {
    "calories": 150,
    "protein": 3,
    "carbs": 20,
    "fat": 7,
    "fiber": 1,
    "sugar": 10,
    "sodium": 200
  },
  "ingredients_detail": [
    {
      "name": "Product name",
      "name_en": "Product name",
      "amount": 1,
      "unit": "pack",
      "calories": 150,
      "protein": 3,
      "carbs": 20,
      "fat": 7
    }
  ],
  "ingredients": ["Ingredient1", "Ingredient2"],
  "barcode": "$barcodeValue",
  "notes": "Read from nutrition label / Estimated from image"
}

Respond in JSON only, no markdown formatting''';

    return await _callGeminiWithImage(apiKey, base64Image, prompt);
  }

  /// Analyze nutrition label from photo
  /// Used when user takes photo of nutrition label directly
  static Future<FoodAnalysisResult?> analyzeNutritionLabel(
    File imageFile,
  ) async {
    debugPrint('🔍 [GeminiService] Reading nutrition label from image');
    
    if (!await imageFile.exists()) {
      throw Exception('Image file not found');
    }
    
    final apiKey = await SecureStorageService.getGeminiApiKey();
    if (apiKey == null || apiKey.isEmpty) {
        throw Exception('Gemini API Key not found');
    }

    final imageBytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    const prompt = '''You are an AI expert in reading Nutrition Facts Labels.

This is a photo of a nutrition label. Please:
1. Read all nutritional information from the label
2. Specify Serving Size as stated on label
3. Specify Calories, Protein, Carbohydrate, Fat per 1 serving

Important: Use values directly from label, do not estimate

Respond in JSON format:
{
  "food_name": "Product name (read from label)",
  "food_name_en": "English name",
  "confidence": 0.98,
  "serving_size": 1,
  "serving_unit": "pack",
  "serving_grams": 30,
  "nutrition": {
    "calories": 150,
    "protein": 3,
    "carbs": 20,
    "fat": 7,
    "fiber": 1,
    "sugar": 10,
    "sodium": 200
  },
  "ingredients_detail": [
    {
      "name": "Product name",
      "name_en": "Product name",
      "amount": 1,
      "unit": "serving",
      "calories": 150,
      "protein": 3,
      "carbs": 20,
      "fat": 7
    }
  ],
  "ingredients": [],
  "notes": "Read from nutrition label"
}

Respond in JSON only, no markdown formatting''';

    return await _callGeminiWithImage(apiKey, base64Image, prompt);
  }

  /// Analyze food by name (no image - Text Only)
  /// Used when user logs food via chat or manual and wants AI to estimate nutrition
  /// [servingSize] and [servingUnit] are user-specified amounts (if provided)
  static Future<FoodAnalysisResult?> analyzeFoodByName(
    String foodName, {
    double? servingSize,
    String? servingUnit,
  }) async {
    AppLogger.info('Analyzing food from name: "$foodName" (${servingSize ?? "?"} ${servingUnit ?? "?"})');

    final apiKey = await SecureStorageService.getGeminiApiKey();
    if (apiKey == null || apiKey.isEmpty) {
        throw Exception('Gemini API Key not found');
    }

    // Build prompt using serving info from user (if provided)
    // If 1 g → unreasonable for a plate of food → fallback to serving
    final isSuspiciousGram = (servingUnit == 'g' || servingUnit == 'กรัม') &&
        (servingSize == null || servingSize <= 1);
    
    final hasUserServing = servingSize != null && servingSize > 0 && 
        servingUnit != null && !isSuspiciousGram;
    final servingDesc = hasUserServing
        ? '$servingSize $servingUnit'
        : '1 standard serving';

    final servingSizeJson = hasUserServing ? servingSize : 1;
    final servingUnitJson = hasUserServing ? servingUnit : 'serving';

    final prompt = '''
Analyze the nutrition of this food: "$foodName"
Provide nutritional values for: $servingDesc

Important:
- serving_size must be $servingSizeJson and serving_unit must be "$servingUnitJson"
- serving_unit should be appropriate, e.g. "plate", "bowl", "cup", "piece", "glass", "egg", "ball", etc.
- Do NOT use "g" as serving_unit for dishes/bowls/plates — use "serving" as fallback
- food_name: Keep in ORIGINAL language (Thai, English, Japanese, etc.) as entered by user
- food_name_en: MUST be the English translation (for database/search purposes)
- ingredient names: MUST be in English (for standardization)

Respond in JSON only:
{
  "food_name": "Original name as user entered (e.g. ข้าวผัด, Fried Rice, 炒飯)",
  "food_name_en": "English translation (e.g. Fried Rice)",
  "confidence": 0.7,
  "serving_size": $servingSizeJson,
  "serving_unit": "$servingUnitJson",
  "serving_grams": 300,
  "nutrition": {
    "calories": 450,
    "protein": 15,
    "carbs": 50,
    "fat": 20,
    "fiber": 2,
    "sugar": 3,
    "sodium": 800
  },
  "ingredients": ["Ingredient1 in English", "Ingredient2 in English"],
  "ingredients_detail": [
    {
      "name": "Ingredient name in English",
      "name_en": "Ingredient name in English",
      "amount": 100,
      "unit": "g",
      "calories": 100,
      "protein": 5,
      "carbs": 10,
      "fat": 3
    }
  ],
  "notes": "Additional notes"
}
''';

    return await _callGeminiTextOnly(apiKey, prompt);
  }

  /// Internal: Call Gemini API with text prompt only (no image)
  static Future<FoodAnalysisResult?> _callGeminiTextOnly(
    String apiKey,
    String prompt,
  ) async {
    final url = Uri.parse('$_baseUrl/$_model:generateContent?key=$apiKey');

    final requestBody = {
      'contents': [
        {
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.1,
        'topK': 1,
        'topP': 0.95,
        'maxOutputTokens': 2048,
        'response_mime_type': 'application/json',
      },
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        debugPrint('❌ [GeminiService] API error: ${response.statusCode}');
        throw Exception('Gemini API error: ${response.statusCode}');
      }

      final responseJson = jsonDecode(response.body);
      final candidates = responseJson['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('Gemini API returned no results');
      }

      final parts = candidates[0]?['content']?['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        throw Exception('Gemini API response has no parts');
      }

      final text = parts[0]?['text'] as String?;
      if (text == null || text.isEmpty) {
        throw Exception('Gemini API returned no text');
      }

      AppLogger.info('text-only received: ${text.substring(0, text.length > 200 ? 200 : text.length)}...');

      final jsonString = _extractJson(text);
      if (jsonString == null) {
        throw Exception('Cannot parse JSON from Gemini response');
      }

      final parsed = _convertToMap(jsonString);
      return FoodAnalysisResult.fromJson(parsed);
    } catch (e) {
      AppLogger.error('Error in _callGeminiTextOnly', e);
      rethrow;
    }
  }

  /// Internal: Call Gemini API with image + prompt
  /// (refactored from analyzeFoodImage for reuse)
  static Future<FoodAnalysisResult?> _callGeminiWithImage(
    String apiKey,
    String base64Image,
    String prompt,
  ) async {
    final url = Uri.parse(
      '$_baseUrl/$_model:generateContent?key=$apiKey',
    );

    final requestBody = {
      'contents': [
        {
          'parts': [
            {'text': prompt},
            {
              'inline_data': {
                'mime_type': 'image/jpeg',
                'data': base64Image,
              },
            },
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.1,
        'topK': 1,
        'topP': 0.95,
        'maxOutputTokens': 2048,
        'response_mime_type': 'application/json',
      },
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode != 200) {
        debugPrint('❌ [GeminiService] API error: ${response.statusCode}');
        throw Exception('Gemini API error: ${response.statusCode}');
      }

      final responseJson = jsonDecode(response.body);
      final candidates = responseJson['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw Exception('Gemini API returned no results');
      }

      final parts = candidates[0]?['content']?['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        throw Exception('Gemini API response has no parts');
      }

      final text = parts[0]?['text'] as String?;
      if (text == null || text.isEmpty) {
        throw Exception('Gemini API returned no text');
      }

      AppLogger.info('Received text: ${text.substring(0, text.length > 200 ? 200 : text.length)}...');

      // Parse JSON from response
      final jsonString = _extractJson(text);
      if (jsonString == null) {
        AppLogger.error('Cannot extract JSON');
        AppLogger.info('Full text: $text');
        throw Exception('Cannot parse JSON from Gemini response');
      }

      debugPrint('✅ [GeminiService] JSON extracted successfully');
      final parsed = _convertToMap(jsonString);
      AppLogger.info('Parsed JSON keys: ${parsed.keys.toList()}');

      final result = FoodAnalysisResult.fromJson(parsed);
      AppLogger.info('FoodAnalysisResult created successfully');
      return result;
    } catch (e) {
      debugPrint('❌ [GeminiService] Error in _callGeminiWithImage: $e');
      rethrow;
    }
  }
}

// ============================================
// FOOD ANALYSIS RESULT
// ============================================

class FoodAnalysisResult {
  final String foodName;
  final String? foodNameEn;
  final double confidence;
  final double servingSize;
  final String servingUnit;
  final int? servingGrams;
  final NutritionData nutrition;
  final List<String>? ingredients;
  final List<IngredientDetail>? ingredientsDetail;
  final String? notes;

  FoodAnalysisResult({
    required this.foodName,
    this.foodNameEn,
    required this.confidence,
    required this.servingSize,
    required this.servingUnit,
    this.servingGrams,
    required this.nutrition,
    this.ingredients,
    this.ingredientsDetail,
    this.notes,
  });

  factory FoodAnalysisResult.fromJson(Map<String, dynamic> json) {
    // Validate serving_unit: if Gemini returns "g" / "ml" with serving_size <= 1 → fallback to "serving"
    var rawUnit = json['serving_unit'] as String? ?? 'serving';
    var rawSize = (json['serving_size'] ?? 1).toDouble();
    
    // "1 g" for a plate of food is unreasonable → change to "serving"
    if ((rawUnit == 'g' || rawUnit == 'กรัม' || rawUnit == 'ml') && rawSize <= 1) {
      AppLogger.warn('serving_unit "$rawUnit" with size $rawSize is unreasonable → fallback to "serving"');
      rawUnit = 'serving';
      rawSize = 1.0;
    }
    
    return FoodAnalysisResult(
      foodName: json['food_name'] ?? 'Unknown',
      foodNameEn: json['food_name_en'],
      confidence: (json['confidence'] ?? 0.5).toDouble(),
      servingSize: rawSize,
      servingUnit: rawUnit,
      servingGrams: (json['serving_grams'] as num?)?.toInt(),
      nutrition: NutritionData.fromJson(json['nutrition'] ?? {}),
      ingredients: json['ingredients'] != null
          ? List<String>.from(json['ingredients'])
          : null,
      ingredientsDetail: json['ingredients_detail'] != null
          ? (json['ingredients_detail'] as List)
              .map((e) => IngredientDetail.fromJson(e))
              .toList()
          : null,
      notes: json['notes'],
    );
  }
}

class IngredientDetail {
  final String name;
  final String? nameEn;
  final double amount;
  final String unit;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  IngredientDetail({
    required this.name,
    this.nameEn,
    required this.amount,
    required this.unit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  factory IngredientDetail.fromJson(Map<String, dynamic> json) {
    return IngredientDetail(
      name: json['name'] ?? '',
      nameEn: json['name_en'],
      amount: (json['amount'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'g',
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
    );
  }
}

class NutritionData {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double? fiber;
  final double? sugar;
  final double? sodium;

  NutritionData({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber,
    this.sugar,
    this.sodium,
  });

  factory NutritionData.fromJson(Map<String, dynamic> json) {
    return NutritionData(
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      fiber: json['fiber']?.toDouble(),
      sugar: json['sugar']?.toDouble(),
      sodium: json['sodium']?.toDouble(),
    );
  }
}
