import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
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
      final newToken = result['newEnergyToken'] as String?;
      if (newToken != null) {
        await service.updateFromBackendToken(newToken);
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
  static Future<FoodAnalysisResult?> analyzeFoodImage(File imageFile, {EnergyService? energyService}) async {
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
      
      final prompt = _getImageAnalysisPrompt();
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
}''';

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
}''';

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
    return '''You are an AI expert in nutrition for global cuisine.
Analyze the food image and estimate nutritional values as accurately as possible.

CRITICAL REQUIREMENTS:
- food_name: Detect the language in image/context and provide in ORIGINAL language ONLY (Thai if Thai text, English if English text, Japanese if Japanese text, etc.)
- food_name_en: THIS FIELD MUST ALWAYS BE IN ENGLISH - If food_name is Thai/Japanese/Chinese/etc., you MUST translate it to English. This is for database standardization.
- Example 1: If you see "ข้าวผัด" → food_name: "ข้าวผัด", food_name_en: "Fried Rice"
- Example 2: If you see "Fried Rice" → food_name: "Fried Rice", food_name_en: "Fried Rice"
- Example 3: If you see "炒飯" → food_name: "炒飯", food_name_en: "Fried Rice"
- ingredient names in ingredients_detail: MUST be in English (for standardization)
- serving_unit must be appropriate for the food, e.g., "plate", "bowl", "cup", "piece", "glass", "egg", "ball", etc.
- Do NOT use "g" or "ml" as serving_unit for dishes/bowls/plates — use "serving" as fallback if unsure
- "g" is only used for individual ingredients in ingredients_detail

Break down each ingredient with quantity and nutritional values.

Respond in JSON format following this structure:
{
  "food_name": "Original name detected from image (Thai/English/Japanese/etc.)",
  "food_name_en": "ALWAYS English translation - NEVER leave this in Thai/Japanese/etc.",
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
}

If you can't identify the food, set confidence to 0.0 and make reasonable estimates.''';
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
Analyze the nutrition of this food: "$foodName"
Provide nutritional values for: $servingDesc

CRITICAL REQUIREMENTS:
- serving_size must be $servingSizeJson and serving_unit must be "$servingUnitJson"
- serving_unit should be appropriate, e.g. "plate", "bowl", "cup", "piece", "glass", "egg", "ball", etc.
- Do NOT use "g" as serving_unit for dishes/bowls/plates — use "serving" as fallback
- food_name: Keep in ORIGINAL language as entered by user (Thai if user entered Thai, English if user entered English, etc.)
- food_name_en: THIS FIELD MUST ALWAYS BE IN ENGLISH - If food_name is Thai/Japanese/Chinese/etc., you MUST translate it to English. This is for database standardization.
- Example 1: User enters "ข้าวผัด" → food_name: "ข้าวผัด", food_name_en: "Fried Rice"
- Example 2: User enters "Fried Rice" → food_name: "Fried Rice", food_name_en: "Fried Rice"
- ingredient names in ingredients_detail: MUST be in English (for standardization)

Respond in JSON only:
{
  "food_name": "Original name as user entered (keep Thai/Japanese/Chinese/etc.)",
  "food_name_en": "ALWAYS English translation - NEVER leave this in Thai/Japanese/etc.",
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
