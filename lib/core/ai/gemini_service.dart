import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_analytics/firebase_analytics.dart';
import '../services/energy_service.dart';
import '../services/device_id_service.dart';
import '../services/usage_limiter.dart';
import '../services/purchase_service.dart';
import '../services/welcome_offer_service.dart';
import '../../features/energy/widgets/welcome_offer_unlocked_dialog.dart';
import '../utils/logger.dart';

class GeminiService {
  // Backend URL (Firebase Cloud Function)
  static const String _backendUrl = 
      'https://us-central1-miro-d6856.cloudfunctions.net/analyzeFood';
  
  // EnergyService instance (required for Backend calls)
  final EnergyService? _energyService;
  
  GeminiService(this._energyService);
  
  // Static instance for backward compatibility (deprecated)
  static EnergyService? _staticEnergyService;
  
  /// BuildContext for showing dialogs (optional)
  static BuildContext? _globalContext;
  
  /// Set EnergyService for static methods (deprecated - use instance methods instead)
  static void setEnergyService(EnergyService energyService) {
    _staticEnergyService = energyService;
  }
  
  /// Set global context for showing dialogs
  static void setContext(BuildContext context) {
    _globalContext = context;
  }
  
  /// Get EnergyService instance (for checking energy before API calls)
  static EnergyService? get energyService => _staticEnergyService;

  /// Check if user has enough energy (for UI checks before API calls)
  static Future<bool> hasEnergy() async {
    final service = _staticEnergyService;
    if (service == null) return true; // Fallback: allow if service not initialized
    return await service.hasEnergy();
  }

  /// Compress image for API: resize to max 800px and encode as JPEG 70% quality
  /// Reduces ~10MB photos to ~100-200KB — enough for Gemini food analysis
  static Future<String> _compressImageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final originalSizeKB = bytes.length / 1024;
    AppLogger.info('📷 Original image: ${originalSizeKB.toStringAsFixed(0)} KB');

    // Decode image
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: 800, // max width 800px (ย่อจากกล้อง ~4000px)
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;

    // Encode as JPEG with 70% quality
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    if (byteData == null) {
      // Fallback: use original bytes if encoding fails
      AppLogger.warn('⚠️ Image encode failed, using original');
      return base64Encode(bytes);
    }

    // Convert PNG to JPEG-like smaller size
    // Since dart:ui doesn't support JPEG quality, we use PNG with resize
    final compressedBytes = byteData.buffer.asUint8List();
    final compressedSizeKB = compressedBytes.length / 1024;
    AppLogger.info('📷 Compressed: ${compressedSizeKB.toStringAsFixed(0)} KB (was ${originalSizeKB.toStringAsFixed(0)} KB)');

    // If compressed is still too large (>500KB) or larger than original, use original resized
    if (compressedSizeKB > 500 && compressedSizeKB > originalSizeKB * 0.8) {
      // Re-encode at smaller resolution
      final codec2 = await ui.instantiateImageCodec(
        bytes,
        targetWidth: 600,
      );
      final frame2 = await codec2.getNextFrame();
      final image2 = frame2.image;
      final byteData2 = await image2.toByteData(format: ui.ImageByteFormat.png);
      image2.dispose();

      if (byteData2 != null) {
        final smallerBytes = byteData2.buffer.asUint8List();
        AppLogger.info('📷 Re-compressed: ${(smallerBytes.length / 1024).toStringAsFixed(0)} KB');
        return base64Encode(smallerBytes);
      }
    }

    return base64Encode(compressedBytes);
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

  // ───────────────────────────────────────────────────────────
  // BACKEND WRAPPER (New Energy System)
  // ───────────────────────────────────────────────────────────
  
  /// Call Backend API (Firebase Cloud Function) with Energy Token
  static Future<Map<String, dynamic>?> _callBackend({
    required String type,
    required String prompt,
    String? imageBase64,
    required String description,
    EnergyService? energyService,
  }) async {
    final service = energyService ?? _staticEnergyService;
    if (service == null) {
      throw Exception('EnergyService not initialized. Please call GeminiService.setEnergyService() first.');
    }
    
    try {
      // ────── 1. ตรวจสอบว่ามี Energy พอหรือไม่ ──────
      final hasEnergy = await service.hasEnergy();
      if (!hasEnergy) {
        throw Exception('Insufficient energy');
      }
      
      // ────── 2. สร้าง Energy Token ──────
      final energyToken = await service.generateEnergyToken();
      final deviceId = await DeviceIdService.getDeviceId();
      
      // ────── 3. เรียก Backend ──────
      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-energy-token': energyToken,
          'x-device-id': deviceId,
        },
        body: json.encode({
          'type': type,
          'prompt': prompt,
          'deviceId': deviceId,
          if (imageBase64 != null) 'imageBase64': imageBase64,
        }),
      );
      
      // ────── 4. ตรวจสอบ Response ──────
      if (response.statusCode == 402) {
        // Insufficient energy
        throw Exception('Insufficient energy');
      }
      
      // Handle 429 (Rate Limit) with user-friendly message
      if (response.statusCode == 429) {
        throw Exception(
          'AI service is temporarily busy. Please try again in a few seconds.\n\n'
          'Your Energy has not been deducted.'
        );
      }
      
      if (response.statusCode != 200) {
        try {
          final error = json.decode(response.body);
          final errorMsg = error['error'];
          
          // Check if it's a Gemini API error with status code
          if (errorMsg is Map && errorMsg['code'] == 429) {
            throw Exception(
              'AI service is experiencing high demand. Please try again in a minute.\n\n'
              'Your Energy has not been deducted.'
            );
          }
          
          throw Exception(errorMsg?.toString() ?? 'Backend error');
        } catch (e) {
          if (e.toString().contains('429')) rethrow;
          throw Exception('Server error: ${response.statusCode}');
        }
      }
      
      final result = json.decode(response.body);
      
      // ────── 5. อัพเดท Energy Balance ──────
      // ✅ PHASE 1: รับ balance จาก response แล้ว sync
      if (result['balance'] != null) {
        final newBalance = result['balance'] as int;
        await service.updateFromServerResponse(newBalance);
      }
      
      // ────── 6. Parse Gemini Response ──────
      final geminiData = result['data'];
      final text = geminiData['candidates'][0]['content']['parts'][0]['text'] as String;
      
      // ลบ markdown code block (```json ... ```)
      final cleanedText = text
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll(RegExp(r'```\s*$'), '')
          .trim();
      
      final parsedResult = json.decode(cleanedText);
      
      // ────── 6.5. Validate ingredients_detail (MANDATORY) ──────
      if (type == 'image' && parsedResult is Map<String, dynamic>) {
        if (!parsedResult.containsKey('ingredients_detail') || 
            parsedResult['ingredients_detail'] == null ||
            !(parsedResult['ingredients_detail'] is List) ||
            (parsedResult['ingredients_detail'] as List).isEmpty) {
          AppLogger.warn('AI response missing or empty ingredients_detail array - creating fallback');
          
          // Create fallback ingredient from main nutrition data
          final nutrition = parsedResult['nutrition'] as Map<String, dynamic>? ?? {};
          parsedResult['ingredients_detail'] = [
            {
              'name': parsedResult['food_name'] ?? 'Unknown Food',
              'name_en': parsedResult['food_name_en'] ?? parsedResult['food_name'] ?? 'Unknown Food',
              'amount': parsedResult['serving_size'] ?? 1,
              'unit': parsedResult['serving_unit'] ?? 'serving',
              'calories': nutrition['calories'] ?? 0,
              'protein': nutrition['protein'] ?? 0,
              'carbs': nutrition['carbs'] ?? 0,
              'fat': nutrition['fat'] ?? 0,
              'fiber': nutrition['fiber'] ?? 0,
              'sugar': nutrition['sugar'] ?? 0,
              'sodium': nutrition['sodium'] ?? 0,
            }
          ];
          
          AppLogger.info('Created fallback ingredient from main nutrition');
        }
      }
      
      // ────── 7. Track AI Usage & Start Welcome Offer Timer (after 10 uses) ──────
      try {
        final timerStarted = await WelcomeOfferService.incrementUsageAndCheckTimer();
        if (timerStarted) {
          debugPrint('[GeminiService] 🎉 Welcome Offer unlocked! (10 AI uses reached)');
          
          // แสดง dialog แจ้งเตือน (ถ้ามี context)
          if (_globalContext != null && _globalContext!.mounted) {
            // รอ 500ms เพื่อให้ current dialog/sheet ปิดก่อน
            await Future.delayed(const Duration(milliseconds: 500));
            if (_globalContext != null && _globalContext!.mounted) {
              await WelcomeOfferUnlockedDialog.show(_globalContext!);
            }
          }
        }
      } catch (e) {
        // Silent fail
        debugPrint('[GeminiService] Welcome offer error: $e');
      }
      
      // ────── 8. Analytics (Firebase) ──────
      await FirebaseAnalytics.instance.logEvent(
        name: 'ai_analysis_success',
        parameters: {
          'type': type,
          'energy_used': 1,
        },
      );
      
      return parsedResult;
      
    } catch (e) {
      print('❌ Gemini Backend Error: $e');
      
      // Analytics: log failure
      await FirebaseAnalytics.instance.logEvent(
        name: 'ai_analysis_failed',
        parameters: {
          'type': type,
          'error': e.toString(),
        },
      );
      
      rethrow;
    }
  }

  // Analyze food image (ใช้ Backend เท่านั้น)
  static Future<FoodAnalysisResult?> analyzeFoodImage(
    File imageFile, {
    EnergyService? energyService,
    String? foodName,
    double? quantity,
    String? unit,
  }) async {
    AppLogger.info('Starting image analysis: ${imageFile.path}');
    
    // Check if file exists
    if (!await imageFile.exists()) {
      AppLogger.error('File not found: ${imageFile.path}');
      throw Exception('Image file not found');
    }
    
    // Use Backend (Energy System)
    final service = energyService ?? _staticEnergyService;
    if (service == null) {
      throw Exception('EnergyService not initialized. Please restart the app.');
    }
    
    try {
      AppLogger.info('Using Backend (Energy System)');
      final base64Image = await _compressImageToBase64(imageFile);
      
      String prompt = _getImageAnalysisPrompt();
      
      // Add optional user-provided information to prompt
      if (foodName != null && foodName.isNotEmpty) {
        prompt += '\n\nThe user has indicated this is: "$foodName".';
      }
      
      if (quantity != null && unit != null) {
        prompt += '\n\nThe user has specified the quantity as: $quantity $unit.';
      } else if (quantity != null) {
        prompt += '\n\nThe user has specified the quantity as: $quantity.';
      }
      
      final result = await _callBackend(
        type: 'image',
        prompt: prompt,
        imageBase64: base64Image,
        description: 'Food image analysis',
        energyService: service,
      );
      
      if (result != null) {
        return FoodAnalysisResult.fromJson(result);
      }
      
      throw Exception('No result from AI analysis');
    } catch (e) {
      AppLogger.error('❌ Backend analysis error', e);
      rethrow;
    }
  }


  /// Analyze product from image + barcode (ใช้ Backend เท่านั้น)
  /// Used when scanning barcode with product packaging image
  static Future<FoodAnalysisResult?> analyzeBarcodedProduct(
    File imageFile,
    String barcodeValue, {
    EnergyService? energyService,
  }) async {
    AppLogger.info('Analyzing product barcode: $barcodeValue');
    
    if (!await imageFile.exists()) {
      throw Exception('Image file not found');
    }
    
    // Use Backend (Energy System)
    final service = energyService ?? _staticEnergyService;
    if (service == null) {
      throw Exception('EnergyService not initialized. Please restart the app.');
    }
    
    try {
      final base64Image = await _compressImageToBase64(imageFile);

      final prompt = '''You are a Food Scientist specializing in packaged food analysis and nutrition label reading.

This is an image of a product with barcode: $barcodeValue

STEP-BY-STEP ANALYSIS:

Step 1 — PRODUCT IDENTIFICATION:
- Read the product name, brand, and variant from packaging
- If it is a convenience store product (7-Eleven, FamilyMart, CP, etc.), cross-reference against known Thai/Asian convenience store product databases for accuracy
- Note the product category (ready-to-eat meal, snack, beverage, etc.)

Step 2 — NUTRITION LABEL EXTRACTION:
- If a Nutrition Facts label is visible, extract EXACT values (do not estimate)
- Note serving size as stated on label
- Capture all available micronutrients (fiber, sugar, sodium, saturated fat, trans fat)

Step 3 — INGREDIENT DECONSTRUCTION:
- If ingredients list is visible on label, parse EVERY ingredient into specific entries
- NEVER use generic names: instead of "Sauce", specify "Teriyaki Sauce (soy sauce, sugar, mirin, corn starch)"
- Identify hidden additives: preservatives, colorings, flavor enhancers (MSG), sweeteners
- For composite ingredients (e.g., "seasoning powder"), break down known sub-components
- Include a "detail" field describing each ingredient's role and composition

Step 4 — HIDDEN CALORIE SOURCES:
- Identify cooking oils used in preparation (visible from oily sheen or listed in ingredients)
- Note sugar content in sauces and marinades
- Flag high-sodium seasonings

CRITICAL RULES:
- "ingredients_detail" array is MANDATORY
- If nutrition label is visible, use label values as primary source
- If ingredients list is visible, parse each one separately with specificity
- If not visible, estimate main components based on product type
- All ingredient names must be in English with descriptive detail

Respond in JSON format:
{
  "food_name": "Product name (original language from packaging)",
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
      "name": "Specific Ingredient Name",
      "name_en": "Specific Ingredient Name in English",
      "detail": "Preparation state and composition details",
      "amount": 0,
      "unit": "g",
      "calories": 0,
      "protein": 0,
      "carbs": 0,
      "fat": 0
    }
  ],
  "ingredients": ["ingredient1", "ingredient2"],
  "barcode": "$barcodeValue",
  "notes": "Source: nutrition label / estimated. Flag any high sodium/sugar/additive concerns."
}

Return ONLY valid JSON.''';

      final result = await _callBackend(
        type: 'image',
        prompt: prompt,
        imageBase64: base64Image,
        description: 'Barcode product analysis: $barcodeValue',
        energyService: service,
      );
      
      if (result != null) {
        return FoodAnalysisResult.fromJson(result);
      }
      
      throw Exception('No result from AI analysis');
    } catch (e) {
      AppLogger.error('❌ Barcode analysis error', e);
      rethrow;
    }
  }

  /// Analyze nutrition label from photo (ใช้ Backend เท่านั้น)
  /// Used when user takes photo of nutrition label directly
  static Future<FoodAnalysisResult?> analyzeNutritionLabel(
    File imageFile, {
    EnergyService? energyService,
  }) async {
    AppLogger.info('🔍 Reading nutrition label from image');
    
    if (!await imageFile.exists()) {
      throw Exception('Image file not found');
    }
    
    // Use Backend (Energy System)
    final service = energyService ?? _staticEnergyService;
    if (service == null) {
      throw Exception('EnergyService not initialized. Please restart the app.');
    }
    
    try {
      final base64Image = await _compressImageToBase64(imageFile);

      const prompt = '''You are an AI expert in reading Nutrition Facts Labels.

This is a photo of a nutrition label.

IMPORTANT REQUIREMENTS:
1. Extract serving size and serving unit
2. Extract ALL nutritional values visible
3. If ingredients list is visible, parse it into "ingredients_detail" array
4. Provide exact values, do not estimate

Please:
1. Read all nutritional information from the label
2. Specify Serving Size as stated on label
3. Specify Calories, Protein, Carbohydrate, Fat per 1 serving
4. If ingredients list is visible, parse each ingredient separately

Important: Use values directly from label, do not estimate

CRITICAL: ingredients_detail array is MANDATORY.
If ingredients list is visible on the label, parse each ingredient separately.
If ingredients list is NOT visible, create a single ingredient entry with the product name and total nutrition values.

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
      "name": "Ingredient from ingredients list",
      "name_en": "Ingredient name in English",
      "amount": 0,
      "unit": "gram",
      "calories": 0,
      "protein": 0,
      "carbs": 0,
      "fat": 0
    }
  ],
  "ingredients": [],
  "notes": "Read from nutrition label"
}

Return ONLY valid JSON.''';

      final result = await _callBackend(
        type: 'image',
        prompt: prompt,
        imageBase64: base64Image,
        description: 'Nutrition label analysis',
        energyService: service,
      );
      
      if (result != null) {
        return FoodAnalysisResult.fromJson(result);
      }
      
      throw Exception('No result from AI analysis');
    } catch (e) {
      AppLogger.error('❌ Nutrition label analysis error', e);
      rethrow;
    }
  }

  /// Analyze food by name (no image - Text Only)
  /// Used when user logs food via chat or manual and wants AI to estimate nutrition
  /// [servingSize] and [servingUnit] are user-specified amounts (if provided)
  static Future<FoodAnalysisResult?> analyzeFoodByName(
    String foodName, {
    double? servingSize,
    String? servingUnit,
    EnergyService? energyService,
  }) async {
    AppLogger.info('Analyzing food from name: "$foodName" (${servingSize ?? "?"} ${servingUnit ?? "?"})');

    // Use Backend (Energy System)
    final service = energyService ?? _staticEnergyService;
    if (service == null) {
      throw Exception('EnergyService not initialized. Please restart the app.');
    }
    
    try {
      AppLogger.info('Using Backend (Energy System) for text analysis');
      
      final prompt = _getTextAnalysisPrompt(
        foodName,
        servingSize: servingSize,
        servingUnit: servingUnit,
      );
      
      final result = await _callBackend(
        type: 'text',
        prompt: prompt,
        description: 'Food nutrition lookup: $foodName',
        energyService: service,
      );
      
      if (result != null) {
        return FoodAnalysisResult.fromJson(result);
      }
      
      throw Exception('No result from AI analysis');
    } catch (e) {
      AppLogger.error('❌ Backend text analysis error', e);
      rethrow;
    }
  }

  // ───────────────────────────────────────────────────────────
  // PROMPT HELPERS (สำหรับ Backend)
  // ───────────────────────────────────────────────────────────
  
  static String _getImageAnalysisPrompt() {
    return '''You are a Food Scientist and Nutrition Expert specializing in deconstructing dishes into precise ingredients.
Your job is to "dissect" every visible food item in the image with professional-level specificity.

STEP-BY-STEP ANALYSIS (you MUST follow this order):

Step 1 — IDENTIFY COOKING STATE:
For each ingredient, determine its cooking method and state (e.g., Stir-fried in oil, Deep-fried, Grilled, Steamed, Boiled, Raw, Marinated, Braised). This affects calorie estimation significantly due to hidden oil/fat absorption.

Step 2 — INGREDIENT SPECIFICITY (CRITICAL):
NEVER use generic names. Always use specific descriptive names:
  ❌ BAD: "Pork", "Rice", "Sauce", "Vegetables"
  ✅ GOOD: "Stir-fried Pork Belly Slices (high fat, marinated in soy sauce)", "Steamed Jasmine Rice", "Sweet Chili Dipping Sauce (contains sugar, vinegar, garlic)", "Stir-fried Morning Glory with Garlic and Oyster Sauce"

Step 3 — HIDDEN SEASONINGS & CONDIMENTS:
Always account for hidden ingredients that add significant calories:
  - Cooking oil (estimate amount absorbed during frying/stir-frying)
  - Sugar in sauces (oyster sauce, sweet chili, teriyaki, ketchup)
  - Sodium-heavy seasonings (fish sauce, soy sauce, MSG, salt)
  - Paste/curry bases (Gochujang, Thai curry paste, miso)
  - Dressings and dips served alongside
  List these as SEPARATE ingredient entries with estimated amounts.

Step 4 — CROSS-REFERENCE:
If the food appears to be from a convenience store (7-Eleven, FamilyMart, Lawson) or chain restaurant, reference known product databases for more accurate nutrition data.

NAMING REQUIREMENTS:
- food_name: Detect language from image/context, keep ORIGINAL language
- food_name_en: MUST ALWAYS be in English for database standardization
- ingredient names in ingredients_detail: MUST be in English with descriptive cooking state
- serving_unit: "plate", "bowl", "cup", "piece", "glass", "egg", "ball", etc. Do NOT use "g" or "ml" as serving_unit for dishes.

CRITICAL RULES:
- "ingredients_detail" array is MANDATORY with at least 1 ingredient
- For complex dishes, list EVERY component separately including sauces and oils
- The sum of all ingredient nutrition must approximately equal the total nutrition
- Include a "detail" field for each ingredient describing its preparation state
- Estimate amounts in grams/ml

Example for "Kimchi Fried Rice with Pork":
{
  "food_name": "김치볶음밥",
  "food_name_en": "Kimchi Fried Rice with Pork",
  "confidence": 0.88,
  "serving_size": 1,
  "serving_unit": "plate",
  "serving_grams": 380,
  "nutrition": {
    "calories": 620,
    "protein": 22,
    "carbs": 75,
    "fat": 25,
    "fiber": 3,
    "sugar": 6,
    "sodium": 1100
  },
  "ingredients_detail": [
    {
      "name": "Steamed Jasmine Rice",
      "name_en": "Steamed Jasmine Rice",
      "detail": "Day-old rice, stir-fried — absorbs oil during cooking",
      "amount": 200,
      "unit": "g",
      "calories": 260,
      "protein": 5,
      "carbs": 56,
      "fat": 1
    },
    {
      "name": "Stir-fried Pork Belly Slices",
      "name_en": "Stir-fried Pork Belly Slices",
      "detail": "High-fat cut, rendered in own fat during stir-frying",
      "amount": 60,
      "unit": "g",
      "calories": 155,
      "protein": 9,
      "carbs": 0,
      "fat": 13
    },
    {
      "name": "Fermented Napa Cabbage Kimchi",
      "name_en": "Fermented Napa Cabbage Kimchi",
      "detail": "Contains gochugaru chili flakes, garlic, fish sauce, sugar",
      "amount": 50,
      "unit": "g",
      "calories": 25,
      "protein": 1,
      "carbs": 4,
      "fat": 0.5
    },
    {
      "name": "Gochujang Chili Paste",
      "name_en": "Gochujang Chili Paste",
      "detail": "Fermented red pepper paste — contains corn syrup and rice flour",
      "amount": 15,
      "unit": "g",
      "calories": 40,
      "protein": 1,
      "carbs": 9,
      "fat": 0.3
    },
    {
      "name": "Vegetable Oil (cooking)",
      "name_en": "Vegetable Oil for Stir-frying",
      "detail": "Absorbed during high-heat stir-frying of rice and pork",
      "amount": 12,
      "unit": "ml",
      "calories": 105,
      "protein": 0,
      "carbs": 0,
      "fat": 12
    },
    {
      "name": "Sesame Oil (finishing)",
      "name_en": "Sesame Oil Drizzle",
      "detail": "Added at the end for aroma",
      "amount": 3,
      "unit": "ml",
      "calories": 27,
      "protein": 0,
      "carbs": 0,
      "fat": 3
    },
    {
      "name": "Soy Sauce",
      "name_en": "Light Soy Sauce",
      "detail": "Seasoning — high sodium",
      "amount": 8,
      "unit": "ml",
      "calories": 5,
      "protein": 1,
      "carbs": 0.5,
      "fat": 0
    }
  ],
  "ingredients": ["jasmine rice", "pork belly", "kimchi", "gochujang", "vegetable oil", "sesame oil", "soy sauce", "garlic", "sugar", "egg"],
  "notes": "High sodium from kimchi + soy sauce + gochujang. Oil absorbed during stir-frying adds ~130 hidden calories."
}

Return ONLY valid JSON, no markdown or explanations.''';
  }
  
  static String _getTextAnalysisPrompt(String foodName, {double? servingSize, String? servingUnit}) {
    final hasUserServing = servingSize != null && servingSize > 0 && 
        servingUnit != null && !((servingUnit == 'g' || servingUnit == 'กรัม') && servingSize <= 1);
    final servingDesc = hasUserServing
        ? '$servingSize $servingUnit'
        : '1 standard serving';
    final servingSizeJson = hasUserServing ? servingSize : 1;
    final servingUnitJson = hasUserServing ? servingUnit : 'serving';
    
    return '''
You are a Food Scientist. Deconstruct this food into precise ingredients with professional-level specificity.

Food to analyze: "$foodName"
Serving: $servingDesc

STEP-BY-STEP ANALYSIS:

Step 1 — IDENTIFY COOKING STATE:
Determine typical preparation method for "$foodName" (stir-fried, deep-fried, grilled, steamed, boiled, raw, braised, etc.). This affects fat/calorie estimation due to oil absorption.

Step 2 — INGREDIENT SPECIFICITY:
NEVER use generic names. Be specific about every ingredient:
  ❌ BAD: "Pork", "Rice", "Sauce"
  ✅ GOOD: "Stir-fried Minced Pork (lean)", "Steamed Jasmine Rice", "Oyster Sauce (contains sugar, soy, corn starch)"

Step 3 — HIDDEN SEASONINGS & COOKING FATS:
Account for all hidden calorie sources typically used in this dish:
  - Cooking oil (type and estimated amount)
  - Sugar in sauces/marinades
  - Sodium-heavy seasonings (fish sauce, soy sauce, MSG)
  - Paste/curry bases
  List these as SEPARATE ingredients with estimated amounts.

Step 4 — CROSS-REFERENCE:
If this is a well-known dish (e.g., Thai street food, convenience store meal, restaurant chain item), reference typical recipes and portion sizes for accurate estimation.

FIELD REQUIREMENTS:
- serving_size: $servingSizeJson, serving_unit: "$servingUnitJson"
- Do NOT use "g" as serving_unit for dishes — use "plate", "bowl", "cup", "piece", "serving", etc.
- food_name: Keep in ORIGINAL language as user entered
- food_name_en: MUST ALWAYS be in English
- All ingredient names: MUST be in English with cooking state description
- Include "detail" field for each ingredient

Respond in JSON only:
{
  "food_name": "Original name as user entered (any language)",
  "food_name_en": "ALWAYS English translation",
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
  "ingredients": ["ingredient1", "ingredient2"],
  "ingredients_detail": [
    {
      "name": "Specific Ingredient with Cooking State",
      "name_en": "Specific Ingredient with Cooking State",
      "detail": "Preparation method, composition, hidden calories note",
      "amount": 100,
      "unit": "g",
      "calories": 100,
      "protein": 5,
      "carbs": 10,
      "fat": 3
    }
  ],
  "notes": "Flag hidden calorie sources and high sodium/sugar concerns"
}''';
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
