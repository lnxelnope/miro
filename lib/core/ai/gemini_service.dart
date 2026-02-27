import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/analytics_service.dart';
import '../services/energy_service.dart';
import '../services/device_id_service.dart';
import '../services/usage_limiter.dart';
import '../services/purchase_service.dart';
import '../../features/energy/providers/gamification_provider.dart';
import '../../features/energy/presentation/energy_store_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/logger.dart';
import '../constants/enums.dart';

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

  /// Extract JSON from AI response text (handles markdown code blocks, leading text, trailing newlines)
  static String? _extractJsonFromResponse(String rawText) {
    final text = rawText.trim();
    if (text.isEmpty) return null;

    // Case 1: Wrapped in ```json ... ``` or ``` ... ```
    if (text.startsWith('```json') || text.startsWith('```')) {
      final cleaned = text
          .replaceFirst(RegExp(r'^```(?:json)?\s*\n?'), '')
          .replaceFirst(RegExp(r'\n?\s*```\s*$'), '')
          .trim();
      if (cleaned.startsWith('{') || cleaned.startsWith('[')) return cleaned;
    }

    // Case 2: Raw JSON
    if (text.startsWith('{') || text.startsWith('[')) return text;

    // Case 3: JSON embedded in markdown code block somewhere in text
    final codeBlockMatch = RegExp(r'```(?:json)?\s*\n([\s\S]*?)\n\s*```').firstMatch(text);
    if (codeBlockMatch != null) {
      final inner = codeBlockMatch.group(1)?.trim();
      if (inner != null && (inner.startsWith('{') || inner.startsWith('['))) {
        return inner;
      }
    }

    // Case 4: JSON object embedded in plain text
    final braceIdx = text.indexOf('{');
    if (braceIdx >= 0) {
      final candidate = text.substring(braceIdx).replaceFirst(RegExp(r'\n?\s*```\s*$'), '').trim();
      if (candidate.startsWith('{')) return candidate;
    }

    return null;
  }

  /// Show daily welcome dialog after first AI usage of the day
  /// Handles: daily energy, tier upgrade + reward, tier demote, welcome back, welcome offer
  static void _showDailyWelcomeDialog(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    if (!context.mounted) return;

    final dailyEnergy = data['dailyEnergy'] as int? ?? 0;
    final currentStreak = data['currentStreak'] as int? ?? 0;
    final tier = data['tier'] as String? ?? 'none';
    final tierUpgraded = data['tierUpgraded'] == true;
    final tierDemoted = data['tierDemoted'] == true;
    final previousTier = data['previousTier'] as String?;
    final newTier = data['newTier'] as String?;
    final showWelcomeBackOffer = data['showWelcomeBackOffer'] == true;
    final tierRewardEnergy = data['tierRewardEnergy'] as int? ?? 0;
    final promotionBonusRate = data['promotionBonusRate'] as double? ?? 0;
    if (dailyEnergy <= 0 && !tierDemoted && !tierUpgraded) return;

    final hasPromoOffer = showWelcomeBackOffer ||
        (tierUpgraded && promotionBonusRate > 0);

    final tierName = _tierDisplayName(tier);
    final greeting = _getDailyGreeting();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── Icon ───
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: tierUpgraded
                      ? Colors.purple.shade50
                      : tierDemoted
                          ? Colors.orange.shade50
                          : Colors.amber.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  tierUpgraded
                      ? Icons.emoji_events_rounded
                      : tierDemoted
                          ? Icons.trending_down_rounded
                          : Icons.wb_sunny_rounded,
                  size: 40,
                  color: tierUpgraded
                      ? Colors.purple.shade600
                      : tierDemoted
                          ? Colors.orange.shade600
                          : Colors.amber.shade600,
                ),
              ),
              const SizedBox(height: 16),

              // ─── Title ───
              Text(
                tierUpgraded
                    ? 'Congratulations!'
                    : tierDemoted
                        ? 'Welcome Back!'
                        : greeting,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // ─── Tier Upgrade Info ───
              if (tierUpgraded && newTier != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade100, Colors.blue.shade100],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Tier Up! ${_tierDisplayName(newTier)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple.shade700,
                    ),
                  ),
                ),
                if (tierRewardEnergy > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    '+$tierRewardEnergy Energy reward!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
              ],

              // ─── Demote Info ───
              if (tierDemoted && previousTier != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Text(
                    '${_tierDisplayName(previousTier)} → $tierName',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Use AI daily to climb back up!',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
              ],

              // ─── Normal Streak Info ───
              if (!tierUpgraded && !tierDemoted) ...[
                Text(
                  'Streak: $currentStreak days ($tierName)',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
              ],

              // ─── Daily Energy Reward ───
              if (dailyEnergy > 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt_rounded, color: Colors.green.shade600, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        '+$dailyEnergy Energy',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // ─── Tier Upgrade Promo (20% bonus) ───
              if (tierUpgraded && promotionBonusRate > 0) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade50, Colors.blue.shade50],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple.shade200),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '+${(promotionBonusRate * 100).toInt()}% Bonus on purchases!',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '24 hours only — celebrate your tier up!',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],

              // ─── Welcome Back Offer (40% bonus) ───
              if (showWelcomeBackOffer) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade50, Colors.blue.shade50],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple.shade200),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Welcome Back Offer!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+40% Bonus on purchases — 24 hours only',
                        style: TextStyle(fontSize: 13, color: Colors.purple.shade600),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (hasPromoOffer)
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Later'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EnergyStoreScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'View Offers →',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              )
            else
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: const Text(
                    'Let\'s go!',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  static String _tierDisplayName(String tier) {
    switch (tier) {
      case 'bronze':
        return 'Bronze';
      case 'silver':
        return 'Silver';
      case 'gold':
        return 'Gold';
      case 'diamond':
        return 'Diamond';
      default:
        return 'Starter';
    }
  }

  static String _getDailyGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning!';
    if (hour < 17) return 'Good Afternoon!';
    return 'Good Evening!';
  }

  /// Cuisine preference for biasing AI analysis toward user's typical cuisine
  static String _cuisinePreference = 'international';

  /// Set cuisine preference (call when profile loads or user changes preference)
  static void setCuisinePreference(String cuisine) {
    _cuisinePreference = cuisine;
  }

  /// Get EnergyService instance (for checking energy before API calls)
  static EnergyService? get energyService => _staticEnergyService;

  /// Check if user has enough energy (for UI checks before API calls)
  static Future<bool> hasEnergy() async {
    final service = _staticEnergyService;
    if (service == null) {
      return true; // Fallback: allow if service not initialized
    }
    return await service.hasEnergy();
  }

  /// Compress image for API: resize to max 800px and encode as JPEG 70% quality
  /// Reduces ~10MB photos to ~100-200KB — enough for Gemini food analysis
  static Future<String> _compressImageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final originalSizeKB = bytes.length / 1024;
    AppLogger.info(
        '📷 Original image: ${originalSizeKB.toStringAsFixed(0)} KB');

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
    AppLogger.info(
        '📷 Compressed: ${compressedSizeKB.toStringAsFixed(0)} KB (was ${originalSizeKB.toStringAsFixed(0)} KB)');

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
        AppLogger.info(
            '📷 Re-compressed: ${(smallerBytes.length / 1024).toStringAsFixed(0)} KB');
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
    int? itemCount,
  }) async {
    final service = energyService ?? _staticEnergyService;
    if (service == null) {
      throw Exception(
          'EnergyService not initialized. Please call GeminiService.setEnergyService() first.');
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
      final timezoneOffset = DateTime.now().timeZoneOffset.inMinutes;
      
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
          'timezoneOffset': timezoneOffset,
          if (imageBase64 != null) 'imageBase64': imageBase64,
          if (itemCount != null) 'itemCount': itemCount,
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
            'Your Energy has not been deducted.');
      }

      // Handle 422 (AI returned invalid response — no energy charged)
      if (response.statusCode == 422) {
        try {
          final error = json.decode(response.body);
          final errorMsg = error['error']?.toString() ??
              'AI could not analyze this food.';
          throw Exception('$errorMsg\n\nYour Energy has not been deducted.');
        } catch (e) {
          if (e.toString().contains('Energy has not been deducted')) rethrow;
          throw Exception(
              'AI could not analyze this food.\n\nYour Energy has not been deducted.');
        }
      }

      if (response.statusCode != 200) {
        try {
          final error = json.decode(response.body);
          final errorMsg = error['error'];

          // Check if it's a Gemini API error with status code
          if (errorMsg is Map && errorMsg['code'] == 429) {
            throw Exception(
                'AI service is experiencing high demand. Please try again in a minute.\n\n'
                'Your Energy has not been deducted.');
          }

          throw Exception(errorMsg?.toString() ?? 'Backend error');
        } catch (e) {
          if (e.toString().contains('429')) rethrow;
          throw Exception('Server error: ${response.statusCode}');
        }
      }

      final result = json.decode(response.body);

      // ────── 5. อัพเดท Energy Balance และ Gamification ──────
      // ✅ PHASE 1: รับ balance จาก response แล้ว sync
      if (result['balance'] != null) {
        final newBalance = result['balance'] as int;
        await service.updateFromServerResponse(newBalance);
      }

      // Update gamification state & show daily welcome dialog
      try {
        final ctx = _globalContext;
        if (ctx != null && ctx.mounted) {
          final container = ProviderScope.containerOf(ctx, listen: false);
          final checkInData = container
              .read(gamificationProvider.notifier)
              .updateFromAiResponse(result);

          // Show daily welcome dialog (first AI usage of the day)
          if (checkInData != null) {
            _showDailyWelcomeDialog(ctx, checkInData);
          }
        }
      } catch (e) {
        AppLogger.debug('[AI] Could not update gamification state: $e');
      }

      // ────── 6b. Log analytics event ──────
      AnalyticsService.logAiAnalysis(
        analysisType: type,
        energyCost: result['energyCost'] as int? ?? 1,
        isSubscriber: result['isSubscriber'] == true,
      );

      // ────── 7. Parse Gemini Response ──────
      final geminiData = result['data'];
      final text =
          geminiData['candidates'][0]['content']['parts'][0]['text'] as String;

      AppLogger.debug('[AI] Raw response (first 300 chars): ${text.substring(0, text.length > 300 ? 300 : text.length)}');

      // Extract JSON from response (handles markdown blocks, leading text, trailing newlines)
      final cleanedText = _extractJsonFromResponse(text);

      final isImageType = type == 'image';
      final notFoundMsg = isImageType
          ? 'No food found in this image.\n\nPlease try taking a new photo.'
          : 'Could not find nutrition data for this food.\n\nPlease try a different name.';
      final cannotAnalyzeMsg = isImageType
          ? 'AI could not analyze this image.\n\nPlease try taking a new photo.'
          : 'AI could not analyze this food.\n\nPlease try a different name.';

      if (cleanedText == null || cleanedText.isEmpty) {
        final lowerText = text.toLowerCase();
        if (lowerText.contains('sorry') ||
            lowerText.contains('cannot') ||
            lowerText.contains('not contain') ||
            lowerText.contains('unable') ||
            lowerText.contains('not a food') ||
            lowerText.contains('no food')) {
          throw Exception(notFoundMsg);
        }
        throw Exception(cannotAnalyzeMsg);
      }

      late final dynamic parsedResult;
      try {
        parsedResult = json.decode(cleanedText);
      } on FormatException {
        throw Exception(notFoundMsg);
      }

      // ────── 6.5. Validate ingredients_detail (MANDATORY) ──────
      if (type == 'image' && parsedResult is Map<String, dynamic>) {
        if (!parsedResult.containsKey('ingredients_detail') ||
            parsedResult['ingredients_detail'] == null ||
            parsedResult['ingredients_detail'] is! List ||
            (parsedResult['ingredients_detail'] as List).isEmpty) {
          AppLogger.warn(
              'AI response missing or empty ingredients_detail array - creating fallback');

          // Create fallback ingredient from main nutrition data
          final nutrition =
              parsedResult['nutrition'] as Map<String, dynamic>? ?? {};
          parsedResult['ingredients_detail'] = [
            {
              'name': parsedResult['food_name'] ?? 'Unknown Food',
              'name_en': parsedResult['food_name_en'] ??
                  parsedResult['food_name'] ??
                  'Unknown Food',
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

        // ────── 6.6. Warn if all-zero nutrition (likely AI confusion) ──────
        final nutrition = parsedResult['nutrition'] as Map<String, dynamic>?;
        if (nutrition != null) {
          final cal = (nutrition['calories'] ?? 0).toDouble();
          final pro = (nutrition['protein'] ?? 0).toDouble();
          final carb = (nutrition['carbs'] ?? 0).toDouble();
          final fat = (nutrition['fat'] ?? 0).toDouble();
          if (cal == 0 && pro == 0 && carb == 0 && fat == 0) {
            AppLogger.warn(
                '⚠️ AI returned all-zero nutrition for "${parsedResult['food_name']}" — '
                'energy already charged, returning result as-is for user to edit');
          }
        }
      }

      return parsedResult;
    } catch (e) {
      print('❌ Gemini Backend Error: $e');

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
    FoodSearchMode searchMode = FoodSearchMode.normal,
    List<Map<String, dynamic>>? userIngredients,
  }) async {
    AppLogger.info(
        'Starting image analysis: ${imageFile.path} (mode: ${searchMode.name})');

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

      // Choose prompt based on search mode
      String prompt = searchMode == FoodSearchMode.product
          ? _getProductImageAnalysisPrompt()
          : _getImageAnalysisPrompt(userIngredients: userIngredients);

      // Add optional user-provided information to prompt
      if (foodName != null && foodName.isNotEmpty) {
        prompt += searchMode == FoodSearchMode.product
            ? '\n\nThe user has indicated this product is: "$foodName".'
            : '\n\nThe user has indicated this is: "$foodName".';
      }

      if (quantity != null && unit != null) {
        prompt += '\n\nThe user has specified the portion as: $quantity $unit.';
      } else if (quantity != null) {
        prompt += '\n\nThe user has specified the quantity as: $quantity.';
      }

      AppLogger.info(
          '[analyzeFoodImage] mode=${searchMode.name}, '
          'foodName=$foodName, quantity=$quantity, unit=$unit');

      final result = await _callBackend(
        type: 'image',
        prompt: prompt,
        imageBase64: base64Image,
        description: 'Food image analysis',
        energyService: service,
      );

      FoodAnalysisResult? finalResult;
      if (result != null) {
        finalResult = FoodAnalysisResult.fromJson(result);
      } else {
        throw Exception('No result from AI analysis');
      }

      // Post-process: enforce user-specified amounts (ถ้ามี)
      if (userIngredients != null && userIngredients.isNotEmpty) {
        finalResult = enforceUserIngredientAmounts(finalResult, userIngredients);
      }

      return finalResult;
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

      final prompt =
          '''You are a Food Scientist specializing in packaged food analysis and nutrition label reading.

This is an image of a product with barcode: $barcodeValue

STEP-BY-STEP ANALYSIS:

Step 1 — PRODUCT IDENTIFICATION:
- Read the product name, brand, and variant from packaging
- If it is a convenience store product (7-Eleven, FamilyMart, CP, etc.), cross-reference against known Thai/Asian convenience store product databases for accuracy
- Note the product category (ready-to-eat meal, snack, beverage, etc.)

Step 2 — NUTRITION LABEL EXTRACTION:
- If a Nutrition Facts label is visible, extract EXACT values (do not estimate)
- Note serving size as stated on label
- Capture all available micronutrients (fiber, sugar, sodium, cholesterol, saturated fat, trans fat, unsaturated fat, monounsaturated fat, polyunsaturated fat, potassium)

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
    "sodium": 200,
    "cholesterol": 0,
    "saturatedFat": 3,
    "transFat": 0,
    "unsaturatedFat": 3,
    "monounsaturatedFat": 2,
    "polyunsaturatedFat": 1,
    "potassium": 150
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
    "sodium": 200,
    "cholesterol": 0,
    "saturatedFat": 3,
    "transFat": 0,
    "unsaturatedFat": 3,
    "monounsaturatedFat": 2,
    "polyunsaturatedFat": 1,
    "potassium": 150
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
  /// [searchMode] tells AI whether to treat as regular food or packaged product
  /// [ingredientNames] optional list of ingredient names for custom meals
  /// [userIngredients] optional list of user-specified ingredients with exact amounts
  ///   Each map contains: {'name': String, 'amount': double, 'unit': String}
  ///   When provided, Gemini will use these EXACT amounts and only fill in nutrition values
  static Future<FoodAnalysisResult?> analyzeFoodByName(
    String foodName, {
    double? servingSize,
    String? servingUnit,
    EnergyService? energyService,
    FoodSearchMode searchMode = FoodSearchMode.normal,
    List<String>? ingredientNames,
    List<Map<String, dynamic>>? userIngredients,
  }) async {
    // Extract embedded quantity from food name if user didn't specify serving
    var effectiveName = foodName;
    var effectiveSize = servingSize;
    var effectiveUnit = servingUnit;

    final hasUserServing = servingSize != null && servingSize > 0 &&
        servingUnit != null && servingUnit.isNotEmpty;
    if (!hasUserServing) {
      final extracted = _extractEmbeddedQuantity(foodName);
      if (extracted != null) {
        effectiveName = extracted.cleanedName;
        effectiveSize = extracted.size;
        effectiveUnit = extracted.unit;
        AppLogger.info(
            'Extracted quantity from name: "${extracted.cleanedName}" → ${extracted.size} ${extracted.unit}');
      }
    }

    AppLogger.info(
        'Analyzing food from name: "$effectiveName" (${effectiveSize ?? "?"} ${effectiveUnit ?? "?"}) mode: ${searchMode.name}');

    // Use Backend (Energy System)
    final service = energyService ?? _staticEnergyService;
    if (service == null) {
      throw Exception('EnergyService not initialized. Please restart the app.');
    }

    try {
      AppLogger.info('Using Backend (Energy System) for text analysis');

      // Choose prompt based on search mode
      final prompt = searchMode == FoodSearchMode.product
          ? _getProductTextAnalysisPrompt(
              effectiveName,
              servingSize: effectiveSize,
              servingUnit: effectiveUnit,
              ingredientNames: ingredientNames,
              userIngredients: userIngredients,
            )
          : _getTextAnalysisPrompt(
              effectiveName,
              servingSize: effectiveSize,
              servingUnit: effectiveUnit,
              ingredientNames: ingredientNames,
              userIngredients: userIngredients,
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

  /// Batch analyze multiple text-only food entries in a single API call.
  /// Max 5 items per batch. Returns list matching input order.
  static Future<List<FoodAnalysisResult>> analyzeFoodBatch(
    List<({String name, double? servingSize, String? servingUnit, FoodSearchMode searchMode, List<String>? ingredientNames, List<Map<String, dynamic>>? userIngredients})> items, {
    EnergyService? energyService,
  }) async {
    if (items.isEmpty) return [];
    assert(items.length <= 5, 'Batch size must not exceed 5');

    AppLogger.info('[BatchAnalyze] Batch analyzing ${items.length} items');

    final service = energyService ?? _staticEnergyService;
    if (service == null) {
      throw Exception('EnergyService not initialized. Please restart the app.');
    }

    try {
      final prompt = _getBatchTextAnalysisPrompt(items);

      final result = await _callBackend(
        type: 'batch_text',
        prompt: prompt,
        description: 'Batch food analysis (${items.length} items)',
        energyService: service,
        itemCount: items.length,
      );

      if (result == null) {
        throw Exception('No result from batch AI analysis');
      }

      // Response is { "items": [ ... ] }
      final itemsList = result['items'] as List<dynamic>?;
      if (itemsList == null || itemsList.isEmpty) {
        throw Exception('Empty items in batch response');
      }

      final results = <FoodAnalysisResult>[];
      for (int i = 0; i < itemsList.length; i++) {
        try {
          final item = itemsList[i] as Map<String, dynamic>;
          results.add(FoodAnalysisResult.fromJson(item));
        } catch (e) {
          AppLogger.warn('[BatchAnalyze] Failed to parse item $i: $e');
          // Add a null-equivalent result so caller can handle per-item failures
          results.add(FoodAnalysisResult(
            foodName: i < items.length ? items[i].name : 'Unknown',
            confidence: 0,
            servingSize: 1,
            servingUnit: 'serving',
            nutrition: NutritionData(calories: 0, protein: 0, carbs: 0, fat: 0),
          ));
        }
      }

      // If Gemini returned fewer items than requested, pad with failures
      while (results.length < items.length) {
        final idx = results.length;
        results.add(FoodAnalysisResult(
          foodName: items[idx].name,
          confidence: 0,
          servingSize: 1,
          servingUnit: 'serving',
          nutrition: NutritionData(calories: 0, protein: 0, carbs: 0, fat: 0),
        ));
      }

      AppLogger.info('[BatchAnalyze] ✅ Parsed ${results.length} results');
      return results;
    } catch (e) {
      AppLogger.error('❌ Batch analysis error', e);
      rethrow;
    }
  }

  // ───────────────────────────────────────────────────────────
  // PROMPT HELPERS (สำหรับ Backend)
  // ───────────────────────────────────────────────────────────

  static String _getImageAnalysisPrompt({List<Map<String, dynamic>>? userIngredients}) {
    // Build ingredients hint if user provided ingredients
    String ingredientsHint = '';
    if (userIngredients != null && userIngredients.isNotEmpty) {
      final lines = userIngredients.map((ing) {
        final name = ing['name'] ?? 'Unknown';
        final rawAmount = ing['amount'];
        final hasAmount = rawAmount is num && rawAmount > 0;
        final amount = hasAmount ? rawAmount : 1;
        final unit = hasAmount ? (ing['unit'] ?? 'g') : 'serving';
        return '  - $name: $amount $unit';
      }).join('\n');
      ingredientsHint = '''

═══════════════════════════════════════════════════════════════════
USER-SPECIFIED INGREDIENTS WITH EXACT AMOUNTS (CRITICAL):
═══════════════════════════════════════════════════════════════════
The user has specified EXACT ingredients and amounts they know are in this food.
These amounts are MORE ACCURATE than visual estimation because the user measured them.

$lines

MANDATORY RULES for user-specified ingredients:
1. You MUST use EXACTLY these amounts — do NOT change them
2. Calculate nutrition values (calories, protein, carbs, fat) for these EXACT amounts
3. Keep the ingredient names similar (you may add cooking state description)
4. You MUST actively discover HIDDEN ingredients not listed above:
   - Seasonings (fish sauce, soy sauce, MSG, sugar, salt, pepper)
   - Cooking oils/fats used in preparation
   - Marinades, pastes, or sauce bases
   - Small garnishes (cilantro, lime, chili flakes)
   - Binding agents (flour, starch, egg wash)
5. Added hidden ingredients should have amounts proportional to the dish
6. The total nutrition = sum of user's ingredients + discovered hidden ingredients
═══════════════════════════════════════════════════════════════════
''';
    }

    // Build cuisine bias instruction
    final cuisineBias = _cuisinePreference != 'international'
        ? '''

CUISINE CONTEXT (CRITICAL for accurate identification):
The user's cuisine preference is: "${_cuisinePreference.toUpperCase()}".
When the food in the image is visually ambiguous (e.g., curry, rice dish, noodles, soup, stew, grilled meat), 
you MUST bias your identification toward $_cuisinePreference cuisine FIRST.
- Example: A curry dish → identify as $_cuisinePreference curry (with typical $_cuisinePreference ingredients, spices, and cooking methods)
- Example: A rice dish → identify as $_cuisinePreference-style rice (with typical $_cuisinePreference seasonings and sides)
- Example: A noodle soup → identify as $_cuisinePreference-style noodle soup
- Use $_cuisinePreference ingredient names, cooking techniques, and typical portion sizes
- Only override this bias if the food is CLEARLY from another cuisine (e.g., sushi is clearly Japanese even if user prefers Thai)
'''
        : '';

    return '''You are a Food Scientist and Nutrition Expert specializing in deconstructing dishes into precise ingredients.
Your job is to "dissect" every visible food item in the image with professional-level specificity.
$cuisineBias$ingredientsHint
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

INGREDIENT HIERARCHY RULES (CRITICAL — prevents double counting):

1. "ingredients_detail" contains ONLY recognizable food components at the ROOT level.
   These ROOT items are what get COUNTED for total calories.
   
2. Each ROOT ingredient MAY have "sub_ingredients" — these are the atomic breakdown
   showing what the component is made of. Sub-ingredients are INFORMATIONAL ONLY.
   
3. CALORIE RULES:
   - sum(ROOT.calories) MUST equal nutrition.calories (the total)
   - sum(sub_ingredients.calories) ≈ parent ROOT ingredient calories
   - NEVER put both a composite AND its raw materials at ROOT level
   
4. When to use sub_ingredients:
   - Deep-fried items → show meat + batter + absorbed oil as subs
   - Sauces → show base ingredients (sugar, vinegar, chili) as subs
   - Processed foods → show components as subs
   - Simple items (plain rice, raw egg) → no sub_ingredients needed
   - Multi-item foods → show per-unit breakdown as subs

5. Each ingredient and sub_ingredient should include:
   - "name": English name with cooking state
   - "name_en": English name (same as name)
   - "detail": Preparation/composition description (optional)
   - "amount", "unit": Quantity
   - "calories", "protein", "carbs", "fat": Macros
   - "sub_ingredients": Array of sub-components (optional, ROOT only)

WRONG (double counting):
{
  "ingredients_detail": [
    {"name": "Fried Battered Chicken Breast", "calories": 150},
    {"name": "Chicken Breast", "calories": 100},     ← DUPLICATE!
    {"name": "Flour Batter", "calories": 30},        ← DUPLICATE!
    {"name": "Frying Oil", "calories": 80}           ← DUPLICATE!
  ]
}
Sum = 360 kcal ≠ nutrition.calories (250 kcal) ❌

CORRECT (hierarchical):
{
  "nutrition": {"calories": 250, ...},
  "ingredients_detail": [
    {
      "name": "Deep-fried Battered Chicken Breast Pieces",
      "name_en": "Deep-fried Battered Chicken Breast Pieces",
      "detail": "Bite-sized chicken coated in seasoned flour, deep-fried",
      "calories": 250,
      "protein": 18,
      "carbs": 12,
      "fat": 15,
      "sub_ingredients": [
        {"name": "Chicken Breast Meat", "name_en": "Chicken Breast Meat", "detail": "Lean white meat", "amount": 80, "unit": "g", "calories": 132, "protein": 17, "carbs": 0, "fat": 3},
        {"name": "Seasoned Flour Batter", "name_en": "Seasoned Flour Batter", "detail": "Contains wheat flour, corn starch, salt, spices", "amount": 25, "unit": "g", "calories": 48, "protein": 1, "carbs": 12, "fat": 0},
        {"name": "Absorbed Frying Oil", "name_en": "Absorbed Frying Oil", "detail": "Oil absorbed during deep-frying", "amount": 8, "unit": "ml", "calories": 70, "protein": 0, "carbs": 0, "fat": 8}
      ]
    }
  ]
}
Sum(ROOT) = 250 kcal ✅
Sum(SUB) = 132 + 48 + 70 = 250 ≈ parent ✅

CRITICAL RULES:
- "ingredients_detail" array is MANDATORY with at least 1 ingredient
- For complex dishes, use sub_ingredients to show composition
- The sum of ROOT ingredient calories must EXACTLY equal total nutrition.calories
- sub_ingredients should NOT have nested sub_ingredients (max 1 level)
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
    "sodium": 1100,
    "cholesterol": 0,
    "saturatedFat": 3,
    "transFat": 0,
    "unsaturatedFat": 3,
    "monounsaturatedFat": 2,
    "polyunsaturatedFat": 1,
    "potassium": 150
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
  "food_type": "food",
  "notes": "High sodium from kimchi + soy sauce + gochujang. Oil absorbed during stir-frying adds ~130 hidden calories."
}

IMPORTANT: Add "food_type" field:
- If you clearly see a packaged product with a nutrition label → set "food_type": "product"
- Otherwise → set "food_type": "food"

Return ONLY valid JSON, no markdown or explanations.''';
  }

  /// Prompt for analyzing PACKAGED PRODUCTS from image
  /// Focuses on reading nutrition labels and using known product data
  static String _getProductImageAnalysisPrompt() {
    final cuisineHint = _cuisinePreference != 'international'
        ? '\nThe user typically consumes $_cuisinePreference food products. If the product origin is ambiguous, prioritize $_cuisinePreference market products and brands.\n'
        : '';

    return '''You are a Nutrition Label Expert and Packaged Food Specialist.
This image shows a PACKAGED PRODUCT or BRANDED FOOD ITEM.
$cuisineHint

YOUR PRIORITY ORDER:
1. If a Nutrition Facts label is visible → extract EXACT values from the label
2. If the product is from a well-known brand/chain → use known official nutrition data
3. If neither → estimate based on product type, packaging size, and similar products

═══════════════════════════════════════════════════════════════════
ZERO-VALUE PROHIBITION (MOST CRITICAL RULE):
═══════════════════════════════════════════════════════════════════
You MUST NEVER return 0 for ALL nutrition values simultaneously.
Every real food product has calories, protein, carbs, or fat > 0.
- If you cannot read the nutrition label → estimate from the product type, brand, and size
- If you don't recognize the product → estimate from similar products in the same category
- A bag of chips ≈ 150-300 kcal, a candy bar ≈ 200-350 kcal, a drink ≈ 50-200 kcal, etc.
- ALWAYS provide your best estimate. Zero calories is NEVER acceptable for any real food.
═══════════════════════════════════════════════════════════════════

STEP-BY-STEP ANALYSIS:

Step 1 — PRODUCT IDENTIFICATION:
- Read brand name, product name, variant/flavor from packaging
- Identify the product category (snack, beverage, dairy, candy, ready meal, fast food, etc.)
- Identify the SIZE/VARIANT: the same product comes in different sizes (e.g., Coke 330ml can vs 500ml bottle vs 1.5L). Use visual cues from the packaging to determine the correct size. Do NOT assume a default size.
- Cross-reference against known product databases for accuracy

Step 2 — NUTRITION DATA EXTRACTION:
- If a Nutrition Facts label is visible, extract EXACT values (do NOT estimate)
- Note the serving size as stated on label
- Note servings per container if visible
- IMPORTANT: Distinguish "per serving" vs "per package". If label says per serving = 30g but the package is 60g (2 servings), and user eats the whole package, multiply by 2.
- If label is NOT readable or not visible → you MUST estimate from known product data or similar products. NEVER return 0.

Step 3 — PORTION CALCULATION:
- If the user specifies a portion (e.g., "300 ml"), calculate nutrition for THAT portion only, even if the container is larger.
  Formula: user_portion / total_container × total_nutrition
- Note the full container size in "notes" for reference (e.g., "Full bottle is 1000ml, user consumed 300ml")
- If user says "1 bag/box/bottle", calculate for the ENTIRE container (multiply servings per container)
- If NO portion is specified, use the most reasonable single-consumption portion

═══════════════════════════════════════════════════════════════════
VISUAL QUANTITY ESTIMATION (CRITICAL FOR IMAGE ANALYSIS):
═══════════════════════════════════════════════════════════════════
When analyzing the image, determine the consumption quantity based on what you SEE:

RULE 1 — WHOLE PRODUCT VISIBLE (single package, no individual units shown):
- If the image shows ONE complete product package (a bag, bottle, box, can, bar, etc.)
  and NO individual sub-units are visible → assume the user consumed the ENTIRE package
- Calculate nutrition for the FULL package content
- Example: A photo of a single bag of chips → nutrition for the entire bag
- Example: A photo of a chocolate bar → nutrition for the entire bar
- Example: A photo of a bottle of juice → nutrition for the entire bottle

RULE 2 — MULTI-PACK WITH INDIVIDUAL UNITS VISIBLE:
- If the image shows BOTH an outer package AND individual units/pieces inside it
  → assume the user consumed ONLY the number of individual units VISIBLE
- Count the individual units you can see
- Calculate nutrition per individual unit × number of visible units
- Example: A box of cookies opened with 3 cookies visible → nutrition for 3 cookies
- Example: A multi-pack with 2 sachets pulled out → nutrition for 2 sachets
- Example: An egg carton with 6 eggs visible → nutrition for 6 eggs

RULE 3 — PARTIAL CONSUMPTION:
- If the product appears partially consumed (half-eaten, partially poured) →
  estimate the consumed portion based on visual cues
- Example: A half-eaten sandwich → nutrition for approximately half
═══════════════════════════════════════════════════════════════════

MULTI-PACK / BOX-IN-BOX RULE (when NO individual units are visible):
- If the image shows ONLY a large outer box (e.g., "12-pack granola bars") with NO individual bars visible → assume 1 individual unit
- Use per-unit nutrition from the label (divide total by number of units if needed)
- Set serving_unit to the individual unit (e.g., "packet", "sachet", "bar", "piece")

BRANDED PREPARED FOOD RULE (KFC, McDonald's, Starbucks, Pizza Hut, Subway, etc.):
- If the product is from a well-known food chain or restaurant brand:
  1. COUNT the exact number of pieces/items visible in the image
  2. IDENTIFY each piece by type (e.g., drumstick vs breast vs wing for fried chicken)
  3. Look up the OFFICIAL per-piece/per-item nutrition for that brand
  4. List EACH piece as a SEPARATE entry in "ingredients_detail" with brand-specific calories
     Example: KFC bucket with 6 pieces → 6 separate entries, NOT a single "KFC Chicken 350 kcal"
  5. For combo/set meals, break down into individual components (burger + fries + drink)
  6. If brand is recognized but specific item is unclear, use the brand's average per-piece values
- WRONG: {"name": "KFC Chicken", "amount": 6, "unit": "piece", "calories": 350}  ← WAY too low for 6 pieces
- CORRECT: List each piece separately: Drumstick ~170kcal, Breast ~390kcal, Thigh ~290kcal, Wing ~130kcal

CRITICAL RULES:
- "ingredients_detail" array is MANDATORY
- ALL nutrition values MUST be > 0 (estimate if label is not readable)
- For simple packaged products, the product itself IS the main ingredient entry
- For branded food with multiple pieces, list EACH piece separately
- For combo/set meals, list EACH component separately
- If ingredients list is visible on packaging, parse it
- Use EXACT label/official values when available; if not available, ESTIMATE from known data
- serving_unit should match what the user specified or what makes sense (e.g., "bag", "bottle", "box", "bar", "pack", "can", "piece", "serving", "cup")

Respond in JSON format:
{
  "food_name": "Product name (original language from packaging)",
  "food_name_en": "English product name with brand",
  "confidence": 0.95,
  "serving_size": 1,
  "serving_unit": "bag",
  "serving_grams": 28,
  "nutrition": {
    "calories": 150,
    "protein": 2,
    "carbs": 15,
    "fat": 10,
    "fiber": 1,
    "sugar": 1,
    "sodium": 170
  },
  "ingredients_detail": [
    {
      "name": "Product Name or Individual Piece",
      "name_en": "Product Name in English",
      "detail": "Source: nutrition label / official brand data / estimated from similar products",
      "amount": 1,
      "unit": "piece",
      "calories": 150,
      "protein": 2,
      "carbs": 15,
      "fat": 10
    }
  ],
  "ingredients": ["ingredient1", "ingredient2"],
  "food_type": "product",
  "notes": "Source: nutrition label / known product database / estimated. Quantity basis: [whole product / N visible units]. Full container: [size]."
}

IMPORTANT RULES:
1. You MUST ALWAYS set "food_type": "product". Do NOT change it to "food".
2. calories, protein, carbs, and fat MUST NOT ALL be 0. Every food has nutrition.
   If you cannot read the label, ESTIMATE based on the product type and similar products.
3. Determine quantity from the image: whole product = entire package; visible units = only those units.

Return ONLY valid JSON, no markdown or explanations.''';
  }

  /// Extract embedded quantity from food name text.
  /// e.g. "ผัดกระเพราอกไก่ 200 กรัม" → (cleanedName: "ผัดกระเพราอกไก่", size: 200, unit: "g")
  /// Returns null if no quantity pattern is found.
  static ({String cleanedName, double size, String unit})? _extractEmbeddedQuantity(String foodName) {
    final thaiUnits = {
      'กรัม': 'g', 'กก.': 'kg', 'กิโลกรัม': 'kg', 'กก': 'kg',
      'มล.': 'ml', 'มิลลิลิตร': 'ml', 'มล': 'ml', 'ลิตร': 'l',
      'ช้อนโต๊ะ': 'tbsp', 'ช้อนชา': 'tsp',
      'ชิ้น': 'piece', 'ถ้วย': 'cup', 'จาน': 'plate', 'ชาม': 'bowl',
      'แก้ว': 'glass', 'ลูก': 'piece', 'ไม้': 'skewer',
      'กล่อง': 'box', 'ซอง': 'pack', 'ขวด': 'bottle', 'กระป๋อง': 'can',
      'ห่อ': 'wrap', 'แผ่น': 'sheet', 'ฝัก': 'piece', 'หัว': 'piece',
      'ผล': 'piece', 'ใบ': 'leaf', 'มัด': 'bunch', 'ฟอง': 'piece',
      'ถุง': 'bag', 'แท่ง': 'stick', 'ลัง': 'box',
    };
    final engUnits = {
      'g': 'g', 'gram': 'g', 'grams': 'g', 'gr': 'g',
      'kg': 'kg', 'kilogram': 'kg', 'kilograms': 'kg',
      'mg': 'mg', 'milligram': 'mg',
      'ml': 'ml', 'milliliter': 'ml', 'milliliters': 'ml',
      'l': 'l', 'liter': 'l', 'liters': 'l',
      'oz': 'oz', 'ounce': 'oz', 'ounces': 'oz',
      'lb': 'lbs', 'lbs': 'lbs', 'pound': 'lbs', 'pounds': 'lbs',
      'cup': 'cup', 'cups': 'cup',
      'tbsp': 'tbsp', 'tsp': 'tsp',
      'piece': 'piece', 'pieces': 'piece', 'pcs': 'piece', 'pc': 'piece',
      'slice': 'slice', 'slices': 'slice',
      'serving': 'serving', 'servings': 'serving',
      'plate': 'plate', 'bowl': 'bowl', 'glass': 'glass',
    };

    final allUnitsPattern = [...thaiUnits.keys, ...engUnits.keys]
        .map((u) => RegExp.escape(u))
        .toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    final unitPattern = allUnitsPattern.join('|');

    final regex = RegExp(
      r'(\d+(?:[.,]\d+)?)\s*(' + unitPattern + r')(?:\s*$|\s*[)\]])',
      caseSensitive: false,
    );

    final match = regex.firstMatch(foodName);
    if (match == null) return null;

    final numberStr = match.group(1)!.replaceAll(',', '.');
    final rawUnit = match.group(2)!.toLowerCase();
    final size = double.tryParse(numberStr);
    if (size == null || size <= 0) return null;

    final normalizedUnit = thaiUnits[match.group(2)!] ??
        engUnits[rawUnit] ??
        rawUnit;

    final cleanedName = foodName
        .replaceRange(match.start, match.end, '')
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');

    return (cleanedName: cleanedName, size: size, unit: normalizedUnit);
  }

  static bool _isWeightUnit(String? unit) {
    if (unit == null) return false;
    return const {'g', 'kg', 'mg', 'oz', 'lbs', 'ml', 'l', 'กรัม', 'กก', 'กก.', 'กิโลกรัม', 'มล', 'มล.', 'ลิตร'}
        .contains(unit.toLowerCase());
  }

  /// Convert internal unit key to human-readable label for AI prompts.
  /// Keeps original key in JSON so the app can parse it back correctly.
  static String _unitForAi(String? unit) {
    if (unit == null || unit.isEmpty) return 'serving';
    const map = {
      'cup_c': 'cup',
      'tbsp': 'tablespoon',
      'tsp': 'teaspoon',
      'fl oz': 'fluid ounce',
      'lbs': 'pound',
      'oz': 'ounce',
    };
    return map[unit] ?? unit;
  }

  static String _getTextAnalysisPrompt(String foodName,
      {double? servingSize, String? servingUnit, List<String>? ingredientNames, List<Map<String, dynamic>>? userIngredients}) {
    final hasUserServing = servingSize != null &&
        servingSize > 0 &&
        servingUnit != null &&
        !((servingUnit == 'g' || servingUnit == 'กรัม') && servingSize <= 1);
    final aiUnit = _unitForAi(servingUnit);
    final servingDesc =
        hasUserServing ? '$servingSize $aiUnit' : '1 standard serving';
    final servingSizeJson = hasUserServing ? servingSize : 1;
    final servingUnitJson = hasUserServing ? servingUnit : 'serving';

    final cuisineBias = _cuisinePreference != 'international'
        ? 'The user\'s cuisine preference is "$_cuisinePreference". If the food name is ambiguous (e.g., "curry", "fried rice", "noodle soup"), interpret it as a $_cuisinePreference dish with typical $_cuisinePreference ingredients and cooking methods.\n'
        : '';

    // Build user ingredients hint (with amounts if available, names-only as fallback)
    String ingredientsHint = '';
    final hasUserIngredients = userIngredients != null && userIngredients.isNotEmpty;
    if (hasUserIngredients) {
      final lines = userIngredients.map((ing) {
        final name = ing['name'] ?? 'Unknown';
        final rawAmount = ing['amount'];
        final hasAmount = rawAmount is num && rawAmount > 0;
        final amount = hasAmount ? rawAmount : 1;
        final unit = hasAmount ? (ing['unit'] ?? 'g') : 'serving';
        return '  - $name: $amount $unit';
      }).join('\n');
      ingredientsHint = '''

═══════════════════════════════════════════════════════════════════
USER-SPECIFIED INGREDIENTS WITH EXACT AMOUNTS (CRITICAL):
═══════════════════════════════════════════════════════════════════
The user has specified EXACT ingredients and amounts they actually used/consumed.
These amounts are MORE ACCURATE than any estimate because the user measured them.

$lines

MANDATORY RULES for user-specified ingredients:
1. You MUST use EXACTLY these amounts — do NOT change them
2. Calculate nutrition values (calories, protein, carbs, fat) for these EXACT amounts
3. Keep the ingredient names similar (you may add cooking state description)
4. You MUST actively discover HIDDEN ingredients the user likely forgot:
   - Cooking oils/fats (type & amount based on cooking method)
   - Seasonings (fish sauce, soy sauce, MSG, sugar, salt, pepper)
   - Marinades, pastes, or sauce bases
   - Small garnishes (cilantro, lime, chili)
   - Binding agents (flour, starch, egg wash)
   Mark discovered hidden ingredients with detail: "hidden - estimated"
5. Added ingredients should have amounts proportional to the user's specified amounts
6. The total nutrition = sum of user's ingredients + any added hidden ingredients
═══════════════════════════════════════════════════════════════════
''';
    } else if (ingredientNames != null && ingredientNames.isNotEmpty) {
      ingredientsHint = '\nUSER SPECIFIED INGREDIENTS: ${ingredientNames.join(", ")}\nUse these ingredients as the base for your analysis.\n';
    }

    return '''
You are a Food Scientist. Deconstruct this food into precise ingredients with professional-level specificity.
$cuisineBias
Food to analyze: "$foodName"
User-specified amount: $servingDesc$ingredientsHint

CRITICAL — AMOUNT RULE:
The user wants nutrition data for EXACTLY $servingDesc of "$foodName".
You MUST calculate ALL nutrition values (calories, protein, carbs, fat, fiber, sugar, sodium, cholesterol, saturatedFat, transFat, unsaturatedFat, monounsaturatedFat, polyunsaturatedFat, potassium) for this EXACT amount.
Do NOT override with a different serving size. Do NOT default to 100g unless the user specified 100g.
Example: "1 egg" means 1 whole egg (~50g), NOT 100g of egg.

EMBEDDED QUANTITY RULE:
If the food name itself contains a quantity (e.g., "ผัดกระเพราอกไก่ 200 กรัม", "grilled chicken 300g"),
the TOTAL WEIGHT of the entire dish is that amount. ALL ingredients combined must sum to approximately that weight.
Do NOT treat the embedded quantity as a single ingredient weight — it is the TOTAL DISH weight.
Example: "ผัดกระเพราอกไก่ไม่หนัง 200 กรัม" means the ENTIRE dish weighs 200g total, so the chicken portion might be ~120g, with rice ~0g (no rice), basil, garlic, oil, sauce making up the rest.

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
${_isWeightUnit(servingUnitJson) ? '- The user specified weight in grams/kg. Keep serving_unit as "$servingUnitJson" and serving_size as $servingSizeJson. Do NOT change to "plate" or "serving".' : '- Do NOT use "g" as serving_unit for dishes — use "plate", "bowl", "cup", "piece", "serving", etc.'}
- food_name: Keep in ORIGINAL language as user entered
- food_name_en: MUST ALWAYS be in English
- All ingredient names: MUST be in English with cooking state description
- Include "detail" field for each ingredient

INGREDIENT HIERARCHY RULES (CRITICAL — prevents double counting):

1. "ingredients_detail" contains ONLY recognizable food components at the ROOT level.
   These ROOT items are what get COUNTED for total calories.
   
2. Each ROOT ingredient MAY have "sub_ingredients" — these are the atomic breakdown
   showing what the component is made of. Sub-ingredients are INFORMATIONAL ONLY.
   
3. CALORIE RULES:
   - sum(ROOT.calories) MUST equal nutrition.calories (the total)
   - sum(sub_ingredients.calories) ≈ parent ROOT ingredient calories
   - NEVER put both a composite AND its raw materials at ROOT level
   
4. When to use sub_ingredients:
   - Deep-fried items → show meat + batter + absorbed oil as subs
   - Sauces → show base ingredients (sugar, vinegar, chili) as subs
   - Processed foods → show components as subs
   - Simple items (plain rice, raw egg) → no sub_ingredients needed

WRONG example (double counting):
{
  "ingredients_detail": [
    {"name": "Fried Chicken", "calories": 150},
    {"name": "Chicken", "calories": 100},  ← DUPLICATE!
    {"name": "Flour", "calories": 30},     ← DUPLICATE!
    {"name": "Oil", "calories": 20}        ← DUPLICATE!
  ]
}

CORRECT example (hierarchical):
{
  "ingredients_detail": [
    {
      "name": "Deep-fried Chicken Pieces",
      "name_en": "Deep-fried Chicken Pieces",
      "detail": "Coated in batter and deep-fried",
      "amount": 100,
      "unit": "g",
      "calories": 150,
      "protein": 15,
      "carbs": 8,
      "fat": 8,
      "sub_ingredients": [
        {"name": "Chicken Meat", "name_en": "Chicken Meat", "amount": 70, "unit": "g", "calories": 100, "protein": 14, "carbs": 0, "fat": 5},
        {"name": "Flour Batter", "name_en": "Flour Batter", "amount": 20, "unit": "g", "calories": 30, "protein": 1, "carbs": 8, "fat": 0},
        {"name": "Absorbed Oil", "name_en": "Absorbed Oil", "amount": 5, "unit": "ml", "calories": 20, "protein": 0, "carbs": 0, "fat": 3}
      ]
    }
  ]
}

IMPORTANT: Replace ALL numeric values below with actual calculated values for EXACTLY $servingDesc.
Do NOT copy example numbers. Calculate from nutrition databases (e.g., USDA) for the correct weight.

Respond in JSON only:
{
  "food_name": "Original name as user entered (any language)",
  "food_name_en": "ALWAYS English translation",
  "confidence": 0.7,
  "serving_size": $servingSizeJson,
  "serving_unit": "$servingUnitJson",
  "serving_grams": 0,
  "nutrition": {
    "calories": 0,
    "protein": 0,
    "carbs": 0,
    "fat": 0,
    "fiber": 0,
    "sugar": 0,
    "sodium": 0,
    "cholesterol": 0,
    "saturatedFat": 0,
    "transFat": 0,
    "unsaturatedFat": 0,
    "monounsaturatedFat": 0,
    "polyunsaturatedFat": 0,
    "potassium": 0
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
  "notes": "Flag hidden calorie sources and high sodium/sugar concerns",
  "food_type": "food"
}

IMPORTANT: Add "food_type" field. Set to "food" for home-cooked or restaurant dishes.''';
  }

  /// Prompt for analyzing PACKAGED PRODUCTS by name (text only)
  /// Uses known nutrition facts data for well-known products
  static String _getProductTextAnalysisPrompt(String productName,
      {double? servingSize, String? servingUnit, List<String>? ingredientNames, List<Map<String, dynamic>>? userIngredients}) {
    final hasUserServing = servingSize != null &&
        servingSize > 0 &&
        servingUnit != null &&
        servingUnit.isNotEmpty;
    final aiUnit = _unitForAi(servingUnit);
    final servingDesc =
        hasUserServing ? '$servingSize $aiUnit' : '1 serving';
    final servingSizeJson = hasUserServing ? servingSize : 1;
    final servingUnitJson = hasUserServing ? servingUnit : 'serving';

    // Build user ingredients hint (with amounts if available, names-only as fallback)
    String ingredientsHint = '';
    final hasUserIngredients = userIngredients != null && userIngredients.isNotEmpty;
    if (hasUserIngredients) {
      final lines = userIngredients.map((ing) {
        final name = ing['name'] ?? 'Unknown';
        final rawAmount = ing['amount'];
        final hasAmount = rawAmount is num && rawAmount > 0;
        final amount = hasAmount ? rawAmount : 1;
        final unit = hasAmount ? (ing['unit'] ?? 'g') : 'serving';
        return '  - $name: $amount $unit';
      }).join('\n');
      ingredientsHint = '''

USER SPECIFIED INGREDIENTS WITH EXACT AMOUNTS:
$lines
Use these ingredients to verify the product composition and calculate accurate nutrition.
''';
    } else if (ingredientNames != null && ingredientNames.isNotEmpty) {
      ingredientsHint = '\nUSER SPECIFIED INGREDIENTS: ${ingredientNames.join(", ")}\nUse these ingredients as the base for your analysis.\n';
    }

    return '''You are a Packaged Food & Nutrition Label Expert.

The user wants nutrition data for a PACKAGED PRODUCT or BRANDED FOOD ITEM.

Product: "$productName"
Portion: $servingDesc$ingredientsHint

YOUR TASK:
1. Identify the product (brand, variant, flavor, SIZE)
2. Use the OFFICIAL nutrition facts data for this product
3. Calculate nutrition for the SPECIFIED PORTION only

═══════════════════════════════════════════════════════════════════
ZERO-VALUE PROHIBITION (MOST CRITICAL RULE):
═══════════════════════════════════════════════════════════════════
You MUST NEVER return 0 for ALL nutrition values simultaneously.
Every real food product has calories > 0.
- If you don't recognize the product → estimate from similar products in the same category
- ALWAYS provide your best estimate. Zero calories is NEVER acceptable.
═══════════════════════════════════════════════════════════════════

IMPORTANT RULES:
- Use known/official nutrition data when available
- If the product has a known Nutrition Facts label, use those exact values
- If you don't recognize the product, indicate low confidence and ESTIMATE based on similar products (NEVER return 0)
- serving_unit should match what makes sense: "bag", "bottle", "box", "bar", "pack", "can", "piece", "serving", "cup"

PORTION vs CONTAINER RULE:
- If the user specifies a portion SMALLER than the full container (e.g., "300 ml" from a 1000 ml bottle), calculate nutrition ONLY for that portion:
  Formula: user_portion / total_container × total_nutrition
- If user says "1 bag/box/bottle", calculate for the ENTIRE container (multiply servings per container if label shows multiple)
- Always report nutrition for the portion the user specified, NOT the full container
- Note the full container size in "notes" for reference

MULTI-PACK / BOX-IN-BOX RULE:
- If the product name suggests a multi-pack (e.g., "granola bars 12-pack"), assume 1 individual unit
- Use per-unit nutrition, not the entire box
- Set serving_unit to the individual unit (e.g., "bar", "packet", "sachet")

BRANDED PREPARED FOOD RULE (KFC, McDonald's, Starbucks, Pizza Hut, Subway, etc.):
- If the product is from a well-known food chain/restaurant brand:
  1. Determine the number of pieces/items from the user's input (e.g., "KFC 6 pieces")
  2. Identify each piece by type if possible (e.g., drumstick vs breast vs wing)
  3. Look up the OFFICIAL per-piece/per-item nutrition for that brand
  4. List EACH piece as a SEPARATE entry in "ingredients_detail" with brand-specific calories
  5. For combo/set meals, break down into individual components (burger + fries + drink)
  6. If brand is recognized but specific item is unclear, use the brand's average per-piece values
- WRONG: {"name": "KFC Chicken", "amount": 6, "unit": "piece", "calories": 350}  ← WAY too low for 6 pieces
- CORRECT: List each piece with its real calories: Drumstick ~170kcal, Breast ~390kcal, Thigh ~290kcal, Wing ~130kcal

SIZE/VARIANT AWARENESS:
- The same product comes in different sizes (e.g., Coke 330ml can vs 500ml bottle vs 1.5L)
- If user specifies size, use that exact size
- If not specified, use the most common single-serving size for that product

FIELD REQUIREMENTS:
- serving_size: $servingSizeJson, serving_unit: "$servingUnitJson"
- food_name: Keep original name as user entered
- food_name_en: MUST ALWAYS be in English (include brand name)
- "ingredients_detail" array is MANDATORY (for multi-piece items, list EACH piece separately)

Respond in JSON only:
{
  "food_name": "$productName",
  "food_name_en": "English product name with brand",
  "confidence": 0.9,
  "serving_size": $servingSizeJson,
  "serving_unit": "$servingUnitJson",
  "serving_grams": 28,
  "nutrition": {
    "calories": 150,
    "protein": 2,
    "carbs": 15,
    "fat": 10,
    "fiber": 1,
    "sugar": 5,
    "sodium": 170
  },
  "ingredients_detail": [
    {
      "name": "$productName",
      "name_en": "English product name or individual piece name",
      "detail": "Source: official nutrition facts. Per $servingDesc.",
      "amount": $servingSizeJson,
      "unit": "$servingUnitJson",
      "calories": 150,
      "protein": 2,
      "carbs": 15,
      "fat": 10
    }
  ],
  "ingredients": [],
  "food_type": "product",
  "notes": "Source: official nutrition facts for $productName. Portion: $servingDesc. Full container: [size if applicable]."
}

Return ONLY valid JSON.''';
  }

  /// Build prompt for batch text analysis (up to 5 items)
  static String _getBatchTextAnalysisPrompt(
    List<({String name, double? servingSize, String? servingUnit, FoodSearchMode searchMode, List<String>? ingredientNames, List<Map<String, dynamic>>? userIngredients})> items,
  ) {
    final cuisineBias = _cuisinePreference != 'international'
        ? 'The user\'s cuisine preference is "$_cuisinePreference". If a food name is ambiguous, interpret it as a $_cuisinePreference dish.\n'
        : '';

    final itemsListStr = StringBuffer();
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      var itemName = item.name;
      var itemSize = item.servingSize;
      var itemUnit = item.servingUnit;

      final hasServing = itemSize != null && itemSize > 0 && itemUnit != null;
      if (!hasServing) {
        final extracted = _extractEmbeddedQuantity(itemName);
        if (extracted != null) {
          itemName = extracted.cleanedName;
          itemSize = extracted.size;
          itemUnit = extracted.unit;
        }
      }

      final servingDesc = (itemSize != null && itemSize > 0 && itemUnit != null)
          ? '$itemSize ${_unitForAi(itemUnit)}'
          : '1 standard serving';
      final modeHint = item.searchMode == FoodSearchMode.product ? ' [PRODUCT]' : '';

      String ingredientsHint = '';
      if (item.userIngredients != null && item.userIngredients!.isNotEmpty) {
        final details = item.userIngredients!.map((ing) {
          return '${ing['name']}: ${ing['amount']} ${ing['unit'] ?? 'g'}';
        }).join(', ');
        ingredientsHint = ' [USER INGREDIENTS (use exact amounts): $details]';
      } else if (item.ingredientNames != null && item.ingredientNames!.isNotEmpty) {
        ingredientsHint = ' [INGREDIENTS: ${item.ingredientNames!.join(", ")}]';
      }
      itemsListStr.writeln('  ${i + 1}. "$itemName" — $servingDesc$modeHint$ingredientsHint');
    }

    return '''
You are a Food Scientist. Analyze ALL ${items.length} food items below and return nutrition + ingredients for each.
$cuisineBias
FOOD ITEMS TO ANALYZE:
$itemsListStr
For EACH item, follow this analysis:

Step 1 — IDENTIFY COOKING STATE: Determine cooking method (stir-fried, deep-fried, grilled, steamed, boiled, raw, etc.).
Step 2 — INGREDIENT SPECIFICITY: Use specific descriptive names, never generic.
Step 3 — HIDDEN SEASONINGS: Include cooking oil, sauces, sugar, sodium seasonings as separate ingredients.
Step 4 — CROSS-REFERENCE: Reference known recipes/databases for accurate estimation.

INGREDIENT HIERARCHY RULES (CRITICAL):
- "ingredients_detail" at ROOT level only — these get COUNTED for total calories
- Each ROOT ingredient MAY have "sub_ingredients" (INFORMATIONAL ONLY)
- sum(ROOT.calories) MUST equal nutrition.calories
- NEVER put both a composite AND its raw materials at ROOT level

NAMING & UNIT RULES:
- food_name: Keep in ORIGINAL language as provided
- food_name_en: MUST ALWAYS be in English
- ingredient names: MUST be in English with cooking state
- serving_unit: Use "plate", "bowl", "cup", "piece", "serving", etc. NOT "g" or "ml" for dishes
- Valid serving_unit values: g, kg, mg, oz, lbs, ml, l, fl oz, cup, tbsp, tsp, serving, piece, slice, plate, bowl, cup_c, glass, egg, ball, fruit, skewer, whole, sheet, pair, bunch, leaf, stick, scoop, handful, pack, bag, wrap, box, can, bottle, bar
- Items marked [PRODUCT] are packaged products — reference nutrition labels and known databases

USER-SPECIFIED INGREDIENTS RULE:
Items marked [USER INGREDIENTS] have exact amounts specified by the user (they measured/weighed the food).
For these items: use the EXACT amounts provided, calculate nutrition for those amounts, and you may ADD hidden ingredients (oil, seasonings) but NEVER change the user's specified amounts.

EMBEDDED QUANTITY RULE:
If serving size was extracted from the food name (e.g., "200 g"), that is the TOTAL WEIGHT of the entire dish.
ALL ingredients combined must sum to approximately that weight. Do NOT treat it as a single ingredient weight.

CRITICAL: Return ALL ${items.length} items in the "items" array. Do not skip any.
Calculate nutrition for EXACTLY the serving size specified per item.

Return ONLY valid JSON:
{
  "items": [
    {
      "food_name": "Original name (any language)",
      "food_name_en": "English name",
      "food_type": "food",
      "confidence": 0.85,
      "serving_size": 1.0,
      "serving_unit": "plate",
      "serving_grams": 350,
      "nutrition": {
        "calories": 0,
        "protein": 0,
        "carbs": 0,
        "fat": 0,
        "fiber": 0,
        "sugar": 0,
        "sodium": 0
      },
      "ingredients_detail": [
        {
          "name": "Ingredient with Cooking State",
          "name_en": "Ingredient with Cooking State",
          "detail": "Preparation notes",
          "amount": 100,
          "unit": "g",
          "calories": 0,
          "protein": 0,
          "carbs": 0,
          "fat": 0
        }
      ]
    }
  ]
}

Return ONLY valid JSON, no markdown.''';
  }

  /// Post-process analysis result to enforce user-specified ingredient amounts.
  /// If Gemini returned different amounts for user-specified ingredients,
  /// scale the nutrition proportionally to match the user's amounts.
  static FoodAnalysisResult enforceUserIngredientAmounts(
    FoodAnalysisResult result,
    List<Map<String, dynamic>> userIngredients,
  ) {
    if (result.ingredientsDetail == null || result.ingredientsDetail!.isEmpty) {
      return result;
    }

    bool anyAdjusted = false;
    final adjustedIngredients = <IngredientDetail>[];

    for (final aiIngredient in result.ingredientsDetail!) {
      final aiNameLower = aiIngredient.name.toLowerCase();
      final aiNameEnLower = (aiIngredient.nameEn ?? '').toLowerCase();

      // Find matching user ingredient (bidirectional contains match)
      Map<String, dynamic>? matchedUser;
      for (final userIng in userIngredients) {
        final userName = (userIng['name'] as String? ?? '').toLowerCase();
        final userAmount = (userIng['amount'] as num?)?.toDouble() ?? 0;
        if (userName.isEmpty || userAmount <= 0) continue;

        if (aiNameLower.contains(userName) ||
            aiNameEnLower.contains(userName) ||
            userName.contains(aiNameLower) ||
            userName.contains(aiNameEnLower)) {
          matchedUser = userIng;
          break;
        }
      }

      if (matchedUser != null) {
        final userAmount = (matchedUser['amount'] as num).toDouble();
        final userUnit = matchedUser['unit'] as String? ?? 'g';
        final aiUnit = aiIngredient.unit;

        // Only scale if units are compatible and amounts differ
        if (userUnit == aiUnit && aiIngredient.amount > 0 && userAmount != aiIngredient.amount) {
          final ratio = userAmount / aiIngredient.amount;
          anyAdjusted = true;
          AppLogger.info(
            '[PostProcess] Adjusting "${aiIngredient.name}": '
            '${aiIngredient.amount}$aiUnit → $userAmount$userUnit (ratio: ${ratio.toStringAsFixed(2)})',
          );

          adjustedIngredients.add(IngredientDetail(
            name: aiIngredient.name,
            nameEn: aiIngredient.nameEn,
            detail: aiIngredient.detail,
            amount: userAmount,
            unit: userUnit,
            calories: aiIngredient.calories * ratio,
            protein: aiIngredient.protein * ratio,
            carbs: aiIngredient.carbs * ratio,
            fat: aiIngredient.fat * ratio,
            subIngredients: aiIngredient.subIngredients?.map((sub) => IngredientDetail(
              name: sub.name,
              nameEn: sub.nameEn,
              detail: sub.detail,
              amount: sub.amount * ratio,
              unit: sub.unit,
              calories: sub.calories * ratio,
              protein: sub.protein * ratio,
              carbs: sub.carbs * ratio,
              fat: sub.fat * ratio,
            )).toList(),
          ));
        } else {
          adjustedIngredients.add(aiIngredient);
        }
      } else {
        // Not a user-specified ingredient (e.g., AI-added oil/seasoning) — keep as-is
        adjustedIngredients.add(aiIngredient);
      }
    }

    if (!anyAdjusted) return result;

    // Recalculate total nutrition from adjusted ingredients
    double totalCal = 0, totalPro = 0, totalCarb = 0, totalFat = 0;
    for (final ing in adjustedIngredients) {
      totalCal += ing.calories;
      totalPro += ing.protein;
      totalCarb += ing.carbs;
      totalFat += ing.fat;
    }

    AppLogger.info(
      '[PostProcess] Recalculated totals: ${totalCal.toStringAsFixed(0)} kcal '
      '(was ${result.nutrition.calories.toStringAsFixed(0)} kcal)',
    );

    return FoodAnalysisResult(
      foodName: result.foodName,
      foodNameEn: result.foodNameEn,
      foodType: result.foodType,
      confidence: result.confidence,
      servingSize: result.servingSize,
      servingUnit: result.servingUnit,
      servingGrams: result.servingGrams,
      nutrition: NutritionData(
        calories: totalCal,
        protein: totalPro,
        carbs: totalCarb,
        fat: totalFat,
        fiber: result.nutrition.fiber,
        sugar: result.nutrition.sugar,
        sodium: result.nutrition.sodium,
      ),
      ingredients: result.ingredients,
      ingredientsDetail: adjustedIngredients,
      notes: result.notes,
    );
  }
}

// ============================================
// FOOD ANALYSIS RESULT
// ============================================

class FoodAnalysisResult {
  final String foodName;
  final String? foodNameEn;
  final String? foodType; // 'food' or 'product'
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
    this.foodType,
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
    if ((rawUnit == 'g' || rawUnit == 'กรัม' || rawUnit == 'ml') &&
        rawSize <= 1) {
      AppLogger.warn(
          'serving_unit "$rawUnit" with size $rawSize is unreasonable → fallback to "serving"');
      rawUnit = 'serving';
      rawSize = 1.0;
    }

    return FoodAnalysisResult(
      foodName: json['food_name'] ?? 'Unknown',
      foodNameEn: json['food_name_en'],
      foodType: json['food_type'], // 'food' or 'product'
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
  final String? detail; // NEW
  final double amount;
  final String unit;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final List<IngredientDetail>? subIngredients; // NEW: recursive

  IngredientDetail({
    required this.name,
    this.nameEn,
    this.detail, // NEW
    required this.amount,
    required this.unit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.subIngredients, // NEW
  });

  factory IngredientDetail.fromJson(Map<String, dynamic> json) {
    return IngredientDetail(
      name: json['name'] ?? '',
      nameEn: json['name_en'] ?? json['nameEn'],
      detail: json['detail'],
      amount: (json['amount'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'g',
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      subIngredients: json['sub_ingredients'] != null
          ? (json['sub_ingredients'] as List)
              .map((e) => IngredientDetail.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'name_en': nameEn,
      'detail': detail,
      'amount': amount,
      'unit': unit,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
    if (subIngredients != null && subIngredients!.isNotEmpty) {
      map['sub_ingredients'] = subIngredients!.map((s) => s.toJson()).toList();
    }
    return map;
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
  final double? cholesterol;
  final double? saturatedFat;
  final double? transFat;
  final double? unsaturatedFat;
  final double? monounsaturatedFat;
  final double? polyunsaturatedFat;
  final double? potassium;

  NutritionData({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber,
    this.sugar,
    this.sodium,
    this.cholesterol,
    this.saturatedFat,
    this.transFat,
    this.unsaturatedFat,
    this.monounsaturatedFat,
    this.polyunsaturatedFat,
    this.potassium,
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
      cholesterol: json['cholesterol']?.toDouble(),
      saturatedFat: json['saturatedFat']?.toDouble(),
      transFat: json['transFat']?.toDouble(),
      unsaturatedFat: json['unsaturatedFat']?.toDouble(),
      monounsaturatedFat: json['monounsaturatedFat']?.toDouble(),
      polyunsaturatedFat: json['polyunsaturatedFat']?.toDouble(),
      potassium: json['potassium']?.toDouble(),
    );
  }
}
