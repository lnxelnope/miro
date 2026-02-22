import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/firebase_config.dart';
import '../services/device_id_service.dart';
import '../services/energy_service.dart';
import '../../features/profile/models/user_profile.dart';

/// Service for Chat with Miro AI (Gemini Backend)
class GeminiChatService {
  static const String _functionUrl = FirebaseConfig.analyzeFoodUrl;

  /// Sanitize a double value: replace NaN/Infinity with 0
  static double _safeDouble(double? value, [double fallback = 0]) {
    if (value == null || value.isNaN || value.isInfinite) return fallback;
    return value;
  }

  /// Recursively sanitize a Map/List for JSON encoding.
  /// Replaces NaN and Infinity doubles with 0.
  static dynamic _sanitizeForJson(dynamic value) {
    if (value is double) {
      return (value.isNaN || value.isInfinite) ? 0 : value;
    }
    if (value is Map) {
      return value.map((k, v) => MapEntry(k, _sanitizeForJson(v)));
    }
    if (value is List) {
      return value.map(_sanitizeForJson).toList();
    }
    return value;
  }

  /// Build user profile context for AI personalization
  static Map<String, dynamic> _buildProfileContext(UserProfile? profile) {
    if (profile == null) {
      return {};
    }

    final context = <String, dynamic>{};

    // Basic info
    if (profile.gender != null) context['gender'] = profile.gender;
    if (profile.age != null) context['age'] = profile.age;
    if (profile.weight != null) {
      context['weight'] = _safeDouble(profile.weight);
    }
    if (profile.height != null) {
      context['height'] = _safeDouble(profile.height);
    }
    if (profile.targetWeight != null) {
      context['targetWeight'] = _safeDouble(profile.targetWeight);
    }
    if (profile.activityLevel != null) {
      context['activityLevel'] = profile.activityLevel;
    }

    // Macro goals
    context['calorieGoal'] = _safeDouble(profile.calorieGoal, 2000);
    context['proteinGoal'] = _safeDouble(profile.proteinGoal, 120);
    context['carbGoal'] = _safeDouble(profile.carbGoal, 250);
    context['fatGoal'] = _safeDouble(profile.fatGoal, 65);

    // Meal budgets
    context['breakfastBudget'] = _safeDouble(profile.breakfastBudget, 560);
    context['lunchBudget'] = _safeDouble(profile.lunchBudget, 700);
    context['dinnerBudget'] = _safeDouble(profile.dinnerBudget, 600);
    context['snackBudget'] = _safeDouble(profile.snackBudget, 140);

    // Cuisine preference (replaces old locale/preferredLanguage)
    context['cuisinePreference'] = profile.cuisinePreference;

    // Calculate goal type (gain/lose/maintain weight)
    if (profile.weight != null && profile.targetWeight != null) {
      final w = _safeDouble(profile.weight);
      final tw = _safeDouble(profile.targetWeight);
      final weightDiff = tw - w;
      if (weightDiff > 2) {
        context['weightGoal'] = 'gain';
      } else if (weightDiff < -2) {
        context['weightGoal'] = 'lose';
      } else {
        context['weightGoal'] = 'maintain';
      }
    }

    return context;
  }

  /// Send message to Gemini Backend for Chat analysis
  ///
  /// Requires EnergyService instance to generate token and update balance
  /// Optionally accepts UserProfile for personalized responses
  ///
  /// Returns:
  /// ```json
  /// {
  ///   "type": "food_log",
  ///   "items": [
  ///     {
  ///       "food_name": "Stir-fried basil pork",
  ///       "food_name_local": "ผัดกะเพราหมู",
  ///       "meal_type": "breakfast",
  ///       "serving_size": 1.0,
  ///       "serving_unit": "plate",
  ///       "calories": 450,
  ///       "protein": 25,
  ///       "carbs": 45,
  ///       "fat": 18
  ///     }
  ///   ],
  ///   "reply": "Logged 1 item! Today's total: 450 kcal 💪",
  ///   "newEnergyToken": "...",
  ///   "newBalance": 99
  /// }
  /// ```
  static Future<Map<String, dynamic>> analyzeChatMessage({
    required String message,
    required EnergyService energyService,
    UserProfile? userProfile,
    Map<String, dynamic>? foodContext,
  }) async {
    try {
      final deviceId = await DeviceIdService.getDeviceId();

      // Generate energy token
      final energyToken = await energyService.generateEnergyToken();

      // Build request body with profile context
      final timezoneOffset = DateTime.now().timeZoneOffset.inMinutes;
      
      final requestBody = <String, dynamic>{
        'type': 'chat',
        'text': message,
        'deviceId': deviceId,
        'timezoneOffset': timezoneOffset,
      };

      // Add profile context if available
      final profileContext = _buildProfileContext(userProfile);
      if (profileContext.isNotEmpty) {
        requestBody['userContext'] = profileContext;
      }

      // Add food context if available
      if (foodContext != null && foodContext.isNotEmpty) {
        requestBody['foodContext'] = foodContext;
      }

      final response = await http
          .post(
        Uri.parse(_functionUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-energy-token': energyToken,
          'x-device-id': deviceId,
        },
        body: jsonEncode(_sanitizeForJson(requestBody)),
      )
          .timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // ✅ PHASE 1: รับ balance จาก response แล้ว sync
        if (data['balance'] != null) {
          final newBalance = data['balance'] as int;
          await energyService.updateFromServerResponse(newBalance);
        }

        return data;
      } else if (response.statusCode == 401 || response.statusCode == 402) {
        throw Exception(
            'Not enough Energy. Please purchase more Energy from the store.');
      } else if (response.statusCode == 429) {
        throw Exception(
            'Energy depleted. Please purchase more Energy from the store.');
      } else if (response.statusCode == 422 || response.statusCode == 413) {
        throw ChatContentTooLongException();
      } else {
        throw Exception('Failed to analyze chat: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get menu suggestions from Miro AI (costs 1 Energy)
  /// Accepts UserProfile for personalized menu recommendations
  static Future<Map<String, dynamic>> getMenuSuggestions({
    required String recentFoodContext,
    required EnergyService energyService,
    UserProfile? userProfile,
  }) async {
    try {
      final deviceId = await DeviceIdService.getDeviceId();

      // Generate energy token
      final energyToken = await energyService.generateEnergyToken();

      // Build request body with profile context
      final timezoneOffset = DateTime.now().timeZoneOffset.inMinutes;
      
      final requestBody = <String, dynamic>{
        'type': 'menu_suggestion',
        'text': recentFoodContext,
        'deviceId': deviceId,
        'timezoneOffset': timezoneOffset, // ← ใหม่!
      };

      // Add profile context if available
      final profileContext = _buildProfileContext(userProfile);
      if (profileContext.isNotEmpty) {
        requestBody['userContext'] = profileContext;
      }

      final response = await http
          .post(
        Uri.parse(_functionUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-energy-token': energyToken,
          'x-device-id': deviceId,
        },
        body: jsonEncode(_sanitizeForJson(requestBody)),
      )
          .timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // ✅ PHASE 1: รับ balance จาก response แล้ว sync
        if (data['balance'] != null) {
          final newBalance = data['balance'] as int;
          await energyService.updateFromServerResponse(newBalance);
        }

        return data;
      } else if (response.statusCode == 401 || response.statusCode == 402) {
        throw Exception(
            'Not enough Energy. Please purchase more Energy from the store.');
      } else if (response.statusCode == 429) {
        throw Exception(
            'Energy depleted. Please purchase more Energy from the store.');
      } else if (response.statusCode == 422 || response.statusCode == 413) {
        throw ChatContentTooLongException();
      } else {
        throw Exception(
            'Failed to get menu suggestions: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}

/// Thrown when chat content is too long for the AI to process (422/413).
class ChatContentTooLongException implements Exception {
  @override
  String toString() =>
      'รายการยาวเกินไป ช่วยแบ่งส่งทีละ 2-3 รายการได้ไหมครับ 🙏\n\n'
      'Energy ไม่ถูกหักนะครับ';
}
