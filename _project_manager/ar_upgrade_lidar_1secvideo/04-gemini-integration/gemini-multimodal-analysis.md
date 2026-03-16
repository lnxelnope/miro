# Gemini Multimodal API Integration for Food Analysis

**File:** `04-gemini-integration/gemini-multimodal-analysis.md`  
**Last Updated:** March 11, 2026

---

## Overview

This document details how to integrate Google's Gemini AI for multimodal food analysis, combining visual data from multiple frames with depth metadata to estimate food volume and calories.

---

## 1. Prompt Engineering Design

### System Prompt (Fixed)

```python
SYSTEM_PROMPT = """
You are a nutritionist and computer vision expert specialized in food volume estimation from multiple camera angles. You analyze 3 images of food taken during a 1-second scan, using parallax and depth data to estimate volume in milliliters (ml) and calculate calories based on detected food type.

Your output must be valid JSON following the schema below. Never include explanations outside the JSON structure.

Critical guidelines:
- Use standard nutritional databases for calorie calculations
- Account for typical density variations by food type
- Be conservative with estimates when confidence is low
- Always list uncertainty factors that may affect accuracy
"""
```

### User Prompt Template (Dynamic)

```dart
class GeminiPromptBuilder {
  
  String buildPrompt({
    required List<String> encodedFrames, // Base64 JPEG images
    required ScanMetadata metadata,
    required DeviceInfo deviceInfo,
    required DepthData? depthData,
    required LightingConditions lighting,
  }) {
    
    final buffer = StringBuffer();
    
    // Section 1: Context and instructions
    buffer.writeln('Analyze this 3-frame food scan and provide volume and calorie estimates.');
    buffer.writeln('');
    
    // Section 2: Device information (affects depth accuracy)
    buffer.writeln('**Device Information:**');
    buffer.writeln('- Model: ${deviceInfo.model}');
    buffer.writeln('- Depth Method: ${_getDepthMethod(deviceInfo, depthData)}');
    if (depthData != null && depthData.hasLiDAR) {
      buffer.writeln('- LiDAR Generation: ${depthData.scannerGeneration}');
      buffer.writeln('- Depth Accuracy: ±2mm (LiDAR mode)');
    } else if (deviceInfo.supportsDepthAPI) {
      buffer.writeln('- Depth Method: ARKit/ARCore estimation');
      buffer.writeln('- Depth Accuracy: ±15-30mm (estimated)');
    }
    buffer.writeln('');
    
    // Section 3: Scan metadata
    buffer.writeln('**Scan Metadata:**');
    buffer.writeln('- Frames captured: ${metadata.frameCount}');
    buffer.writeln('- Capture duration: ${metadata.captureDurationMs}ms');
    buffer.writeln('- Lighting quality: ${lighting.quality.name}');
    if (lighting.hasIssues) {
      final issues = <String>[];
      if (lighting.isTooDark) issues.add('low lighting');
      if (lighting.hasMotionBlur) issues.add('motion blur');
      if (lighting.hasReflections) issues.add('surface reflections');
      buffer.writeln('- Issues detected: ${issues.join(', ')}');
    }
    buffer.writeln('');
    
    // Section 4: Depth data (if available)
    if (depthData != null && depthData.isAvailable) {
      buffer.writeln('**Depth Data:**');
      buffer.writeln('- Volume estimate: ${depthData.volumeCm3} cm³');
      buffer.writeln()-bounding box: [${depthData.boundingBox.width}, ${depthData.boundingBox.height}, ${depthData.boundingBox.depth}] cm');
      buffer.writeln('- Depth confidence: ${(depthData.confidence * 100).toInt()}%');
      
      // Apply density correction based on food category hint
      if (depthData.densityCorrectionFactor != null) {
        buffer.writeln('- Density adjustment factor: ${depthData.densityCorrectionFactor}x');
      }
      buffer.writeln('');
    } else {
      buffer.writeln('**Note:** No depth data available. Using parallax analysis from 3 frames.');
      buffer.writeln('Consider using a reference object (plate, cup) for better scale estimation next time.');
      buffer.writeln('');
    }
    
    // Section 5: Visual instructions with frame descriptions
    buffer.writeln('**Visual Analysis Instructions:**');
    buffer.writeln('- Frame 1: Initial view - establish baseline food detection');
    buffer.writeln('- Frame 2: Mid-rotation view - optimal lighting typically present');
    buffer.writeln('- Frame 3: Final position - complete rotation captured');
    buffer.writeln('');
    buffer.writeln('Use the parallax between frames to estimate 3D volume.');
    buffer.writeln('If depth data is available, use it to refine your volume calculation.');
    buffer.writeln('');
    
    // Section 6: Output format specification (CRITICAL)
    buffer.writeln('**Output Format:**');
    buffer.writeln('Return ONLY valid JSON in this exact structure:');
    buffer.writeln('{');
    buffer.writeln('  "foodItems": [');
    buffer.writeln('    {');
    buffer.writeln('      "name": "string (common food name)",');
    buffer.writeln('      "category": "solid|liquid|mixed|leafy|dehydrated",');
    buffer.writeln('      "confidence": number (0-1, how sure about identification),');
    buffer.writeln('      "estimatedWeightGrams": number,');
    buffer.writeln('      "volumeMl": number,');
    buffer.writeln('      "calories": number,');
    buffer.writeln('      "nutritionPer100g": { "protein_g": num, "carbs_g": num, "fat_g": num, "fiber_g": num },');
    buffer.writeln('      "uncertaintyFactors": ["list of why estimate may be uncertain"]');
    buffer.writeln('    }');
    buffer.writeln('  ],');
    buffer.writeln('  "totalCalories": number (sum of all food items),');
    buffer.writeln('  "scanQuality": {');
    buffer.writeln('    "confidence": number (0-1, overall scan reliability),');
    buffer.writeln('    "issues": ["list of quality issues detected"],');
    buffer.writeln('    "recommendations": ["suggestions for better scan next time"]');
    buffer.writeln('  },');
    buffer.writeln('  "metadata": {');
    buffer.writeln('    "processingTimeMs": number,');
    buffer.writeln('    "modelVersion": "gemini-2.0-flash-food-v1"');
    buffer.writeln('  }');
    buffer.writeln('}');
    
    // Section 7: Frame data (appended as images)
    buffer.writeln('');
    buffer.writeln('**Images:**');
    for (var i = 0; i < encodedFrames.length; i++) {
      buffer.writeln('[Frame ${i + 1}: Base64 encoded JPEG - see attachment]');
    }
    
    return buffer.toString();
  }
  
  String _getDepthMethod(DeviceInfo device, DepthData? depth) {
    if (depth != null && depth.hasLiDAR) return 'LiDAR';
    if (device.supportsDepthAPI) return device.isIOS ? 'ARKit' : 'ARCore';
    return 'Parallax only';
  }
}

// Example generated prompt:
/*
Analyze this 3-frame food scan and provide volume and calorie estimates.

**Device Information:**
- Model: iPhone 15 Pro
- Depth Method: LiDAR
- LiDAR Generation: gen4
- Depth Accuracy: ±2mm (LiDAR mode)

**Scan Metadata:**
- Frames captured: 30
- Capture duration: 1000ms
- Lighting quality: good

**Depth Data:**
- Volume estimate: 450.5 cm³
- Bounding box: [18.2, 12.5, 8.3] cm
- Depth confidence: 94%

**Visual Analysis Instructions:**
- Frame 1: Initial view - establish baseline food detection
- Frame 2: Mid-rotation view - optimal lighting typically present
- Frame 3: Final position - complete rotation captured

Use the parallax between frames to estimate 3D volume.
If depth data is available, use it to refine your volume calculation.

**Output Format:**
Return ONLY valid JSON in this exact structure:
{...}

[Frame 1: Base64 encoded JPEG - see attachment]
[Frame 2: Base64 encoded JPEG - see attachment]
[Frame 3: Base64 encoded JPEG - see attachment]
*/
```

---

## 2. API Implementation (Flutter)

### Gemini Analyzer Service

```dart
// lib/features/ar_scanner/gemini_food_analyzer.dart

import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiFoodAnalyzer {
  
  final GenerativeModel _model;
  final int _maxTokens = 1024; // Limit response size
  
  GeminiFoodAnalyzer({required String apiKey}) 
      : _model = GenerativeModel(
          model: 'gemini-2.0-flash',
          apiKey: apiKey,
          generationConfig: GenerationConfig(
            maxOutputTokens: _maxTokens,
            temperature: 0.3, // Low temperature for consistent results
            topP: 0.9,
          ),
        );
  
  Future<FoodScanResult> analyzeScan({
    required List<String> encodedFrames,
    required ScanMetadata metadata,
    required DeviceInfo deviceInfo,
    required DepthData? depthData,
    required LightingConditions lighting,
  }) async {
    
    try {
      // Build prompt with all context
      final promptText = GeminiPromptBuilder().buildPrompt(
        encodedFrames: encodedFrames,
        metadata: metadata,
        deviceInfo: deviceInfo,
        depthData: depthData,
        lighting: lighting,
      );
      
      // Prepare multimodal content
      final List<Content> contents = [
        Content.multi([
          for (var i = 0; i < encodedFrames.length; i++) 
            Part.base64(
              encodedFrames[i],
              mimeType: 'image/jpeg',
            ),
          Part.text(promptText),
        ]),
      ];
      
      // Execute analysis with timeout
      final response = await _model.generateContent(
        contents,
        tools: [ToolCodeExecution()], // Enable code execution for nutrition calculations
      ).timeout(
        Duration(seconds: 8), // Reasonable timeout for API call
        onTimeout: () {
          throw ScanTimeoutException('Gemini analysis timed out after ${Duration(seconds: 8).inSeconds} seconds');
        },
      );
      
      // Parse response and extract JSON
      final resultText = _extractJsonFromResponse(response.text!);
      
      return FoodScanResult.fromJson(json.decode(resultText));
      
    } catch (e) {
      debugPrint('Gemini analysis error: $e');
      throw AnalysisException('Failed to analyze scan with Gemini: $e');
    }
  }
  
  String _extractJsonFromResponse(String text) {
    // Remove markdown code blocks if present
    final cleaned = text.replaceAllMapped(
      RegExp(r'```(?:json)?\n?(.*?)\n?```', multiLine: true, caseSensitive: true),
      (match) => match.group(1)!,
    );
    
    // Remove any explanatory text before/after JSON
    final jsonStart = cleaned.indexOf('{');
    final jsonEnd = cleaned.lastIndexOf('}');
    
    if (jsonStart == -1 || jsonEnd == -1) {
      throw ParseError('No JSON object found in response: $text');
    }
    
    return cleaned.substring(jsonStart, jsonEnd + 1);
  }
}

// Exception classes for error handling
class ScanTimeoutException implements Exception {
  final String message;
  ScanTimeoutException(this.message);
  
  @override
  String toString() => 'ScanTimeoutException: $message';
}

class AnalysisException implements Exception {
  final String message;
  AnalysisException(this.message);
  
  @override
  String toString() => 'AnalysisException: $message';
}

class ParseError implements Exception {
  final String message;
  ParseError(this.message);
  
  @override
  String toString() => 'ParseError: $message';
}
```

---

## 3. Result Parsing & Validation

### Food Scan Result Structure

```dart
// lib/features/ar_scanner/models/food_scan_result.dart

class FoodScanResult {
  final List<FoodItem> foodItems;
  final int totalCalories;
  final ScanQuality scanQuality;
  final AnalysisMetadata metadata;
  
  const FoodScanResult({
    required this.foodItems,
    required this.totalCalories,
    required this.scanQuality,
    required this.metadata,
  });
  
  factory FoodScanResult.fromJson(Map<String, dynamic> json) {
    return FoodScanResult(
      foodItems: (json['foodItems'] as List)
          .map((item) => FoodItem.fromJson(item))
          .toList(),
      totalCalories: json['totalCalories'],
      scanQuality: ScanQuality.fromJson(json['scanQuality']),
      metadata: AnalysisMetadata.fromJson(json['metadata']),
    );
  }
  
  // Validation logic
  bool get isValid {
    return foodItems.isNotEmpty && 
           totalCalories > 0 &&
           scanQuality.confidence >= 0.3; // Minimum acceptable confidence
  }
  
  bool get isHighConfidence => scanQuality.confidence >= 0.7;
}

class FoodItem {
  final String name;
  final String category; // solid, liquid, mixed, leafy, dehydrated
  final double confidence; // Identification confidence (0-1)
  final int estimatedWeightGrams;
  final int volumeMl;
  final int calories;
  final NutritionInfo nutritionPer100g;
  final List<String> uncertaintyFactors;
  
  const FoodItem({
    required this.name,
    required this.category,
    required this.confidence,
    required this.estimatedWeightGrams,
    required this.volumeMl,
    required this.calories,
    required this.nutritionPer100g,
    required this.uncertaintyFactors,
  });
  
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'] ?? 'Unknown food',
      category: _validateCategory(json['category']),
      confidence: (json['confidence'] ?? 0.5).toDouble(),
      estimatedWeightGrams: json['estimatedWeightGrams'] ?? 0,
      volumeMl: json['volumeMl'] ?? 0,
      calories: json['calories'] ?? 0,
      nutritionPer100g: NutritionInfo.fromJson(json['nutritionPer100g'] ?? {}),
      uncertaintyFactors: List<String>.from(json['uncertaintyFactors'] ?? []),
    );
  }
  
  static String _validateCategory(String? category) {
    final validCategories = ['solid', 'liquid', 'mixed', 'leafy', 'dehydrated'];
    if (category != null && validCategories.contains(category.toLowerCase())) {
      return category.toLowerCase();
    }
    return 'mixed'; // Default to mixed for unknown categories
  }
}

class NutritionInfo {
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;
  
  const NutritionInfo({
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.fiberG,
  });
  
  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      proteinG: (json['protein_g'] ?? 0).toDouble(),
      carbsG: (json['carbs_g'] ?? 0).toDouble(),
      fatG: (json['fat_g'] ?? 0).toDouble(),
      fiberG: (json['fiber_g'] ?? 0).toDouble(),
    );
  }
}

class ScanQuality {
  final double confidence; // Overall scan reliability (0-1)
  final List<String> issues; // Quality problems detected
  final List<String> recommendations; // Suggestions for improvement
  
  const ScanQuality({
    required this.confidence,
    required this.issues,
    required this.recommendations,
  });
  
  factory ScanQuality.fromJson(Map<String, dynamic> json) {
    return ScanQuality(
      confidence: (json['confidence'] ?? 0.5).toDouble(),
      issues: List<String>.from(json['issues'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }
  
  bool get hasIssues => issues.isNotEmpty;
}

class AnalysisMetadata {
  final int processingTimeMs;
  final String modelVersion;
  
  const AnalysisMetadata({
    required this.processingTimeMs,
    required this.modelVersion,
  });
  
  factory AnalysisMetadata.fromJson(Map<String, dynamic> json) {
    return AnalysisMetadata(
      processingTimeMs: json['processingTimeMs'] ?? 0,
      modelVersion: json['modelVersion'] ?? 'unknown',
    );
  }
}
```

---

## 4. Error Handling & Fallback Strategies

### Multi-Layer Retry System

```dart
class AnalysisRetryHandler {
  
  final GeminiFoodAnalyzer _analyzer;
  final int _maxRetries = 2;
  
  Future<FoodScanResult> analyzeWithRetries({
    required List<String> encodedFrames,
    required ScanMetadata metadata,
    required DeviceInfo deviceInfo,
    required DepthData? depthData,
    required LightingConditions lighting,
  }) async {
    
    FoodScanResult? lastSuccessfulResult;
    AnalysisException? lastError;
    
    for (var attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        debugPrint('Analysis attempt ${attempt + 1}/$_maxRetries');
        
        final result = await _analyzer.analyzeScan(
          encodedFrames: encodedFrames,
          metadata: metadata,
          deviceInfo: deviceInfo,
          depthData: depthData,
          lighting: lighting,
        );
        
        // Validate result quality
        if (result.isValid) {
          lastSuccessfulResult = result;
          
          // If confidence is acceptable, return immediately
          if (result.isHighConfidence || attempt >= _maxRetries - 1) {
            return result;
          }
          
          // Low but valid confidence - try enhanced analysis
          debugPrint('Low confidence (${(result.scanQuality.confidence * 100).toInt()}%), retrying with enhanced prompt');
        } else {
          throw AnalysisException('Invalid result structure');
        }
        
      } catch (e) {
        lastError = e is AnalysisException ? e : AnalysisException(e.toString());
        debugPrint('Attempt ${attempt + 1} failed: $e');
        
        if (attempt == _maxRetries) break; // No more retries
        
        // Wait before retry (exponential backoff)
        await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
      }
    }
    
    // Return last successful result or throw error
    if (lastSuccessfulResult != null) {
      debugPrint('Returning best available result after $lastError attempts');
      return lastSuccessfulResult.copyWith(
        warnings: ['Multiple retry attempts required - accuracy may be reduced'],
      );
    }
    
    throw lastError ?? AnalysisException('All analysis attempts failed');
  }
}

// Enhanced prompt for low-confidence scenarios
class EnhancedPromptBuilder extends GeminiPromptBuilder {
  
  @override
  String buildPrompt({
    required List<String> encodedFrames,
    required ScanMetadata metadata,
    required DeviceInfo deviceInfo,
    required DepthData? depthData,
    required LightingConditions lighting,
  }) {
    
    final basePrompt = super.buildPrompt(
      encodedFrames: encodedFrames,
      metadata: metadata,
      deviceInfo: deviceInfo,
      depthData: depthData,
      lighting: lighting,
    );
    
    // Add enhanced instructions for difficult scenarios
    final buffer = StringBuffer(basePrompt);
    
    if (lighting.isTooDark) {
      buffer.writeln('');
      buffer.writeln('ENHANCED ANALYSIS REQUEST:');
      buffer.writeln('- This scan has low lighting conditions');
      buffer.writeln('- Focus on identifying food in the brightest visible regions');
      buffer.writeln('- Provide a range estimate if you cannot determine exact values');
      buffer.writeln('- List specific visual ambiguities that affect confidence');
    }
    
    if (depthData == null || !depthData.supportsDepthAPI) {
      buffer.writeln('');
      buffer.writeln('ENHANCED ANALYSIS REQUEST:');
      buffer.writeln('- No depth data available; use parallax analysis carefully');
      buffer.writeln('- Consider typical food densities when estimating volume');
      buffer.writeln('- Account for potential scale ambiguity in your uncertainty factors');
    }
    
    return buffer.toString();
  }
}

// Fallback: Use cached nutrition database if all else fails
class NutritionDatabaseFallback {
  
  Map<String, List<NutritionEntry>> _cache = {};
  
  Future<FoodScanResult> fallbackToDatabase({
    required String detectedFoodName,
    required int? estimatedWeightFromDepth,
  }) async {
    
    final entries = await _getNutritionEntries(detectedFoodName);
    
    if (entries.isEmpty) {
      throw DatabaseFallbackException('No nutrition data found for: $detectedFoodName');
    }
    
    // Use median values from database
    final avgEntry = entries.fold<NutritionEntry?>(null, (avg, entry) {
      if (avg == null) return entry;
      
      return NutritionEntry(
        calories: (entry.calories + avg.calories) / 2,
        proteinG: (entry.proteinG + avg.proteinG) / 2,
        carbsG: (entry.carbsG + avg.carbsG) / 2,
        fatG: (entry.fatG + avg.fatG) / 2,
      );
    });
    
    final weight = estimatedWeightFromDepth ?? 100; // Default to 100g
    
    return FoodScanResult(
      foodItems: [
        FoodItem(
          name: detectedFoodName,
          category: 'solid',
          confidence: 0.5, // Low confidence for fallback
          estimatedWeightGrams: weight,
          volumeMl: weight * 1.2, // Approximate density conversion
          calories: avgEntry!.calories * weight ~/ 100,
          nutritionPer100g: NutritionInfo(
            proteinG: avgEntry.proteinG,
            carbsG: avgEntry.carbsG,
            fatG: avgEntry.fatG,
            fiberG: 0, // Not in database
          ),
          uncertaintyFactors: ['Fallback to database estimate'],
        ),
      ],
      totalCalories: avgEntry.calories * weight ~/ 100,
      scanQuality: ScanQuality(
        confidence: 0.5,
        issues: ['Depth data unavailable', 'Database fallback used'],
        recommendations: ['Use better lighting next time', 'Consider reference object for scale'],
      ),
      metadata: AnalysisMetadata(
        processingTimeMs: 0,
        modelVersion: 'database-fallback-v1',
      ),
    );
  }
}

class DatabaseFallbackException implements Exception {
  final String message;
  DatabaseFallbackException(this.message);
  
  @override
  String toString() => 'DatabaseFallbackException: $message';
}
```

---

## Summary

This Gemini integration provides:
- ✅ Optimized prompt engineering for food analysis tasks
- ✅ Robust error handling with multi-layer retry system
- ✅ Enhanced prompts for challenging scenarios (low light, no depth)
- ✅ Fallback to nutrition database when AI analysis fails
- ✅ Strict JSON output validation and parsing

**Next Steps:** Implement testing strategies (`../05-limitations/testing-strategy.md`) to validate accuracy across different food types.
