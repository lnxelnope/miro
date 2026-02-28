import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/cuisine_options.dart';
import '../../../core/utils/logger.dart';
import '../../../l10n/app_localizations.dart';
import '../../health/providers/health_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../energy/providers/gamification_provider.dart';

/// Generates random AI greeting messages with dynamic user data
class GreetingService {
  static const String _keyLastBackupDate = 'last_backup_date';

  /// Save last backup date (called from BackupService)
  static Future<void> setLastBackupDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastBackupDate, date.millisecondsSinceEpoch);
  }

  /// Get last backup date
  static Future<DateTime?> getLastBackupDate() async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getInt(_keyLastBackupDate);
    if (ts == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ts);
  }

  /// Generate a random greeting message using dynamic user data
  static Future<String> generateGreeting({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    final l10n = L10n.of(context)!;
    final greetings = <String>[];

    try {
      // --- Gather data ---
      final todayCaloriesAsync = ref.read(todayCaloriesProvider);
      final todayCalories = await todayCaloriesAsync.when(
        data: (d) => Future.value(d),
        loading: () => Future.value(0.0),
        error: (_, __) => Future.value(0.0),
      );

      final todayMacrosAsync = ref.read(todayMacrosProvider);
      final todayMacros = await todayMacrosAsync.when(
        data: (d) => Future.value(d),
        loading: () => Future.value(<String, double>{
          'protein': 0.0,
          'carbs': 0.0,
          'fat': 0.0,
        }),
        error: (_, __) => Future.value(<String, double>{
          'protein': 0.0,
          'carbs': 0.0,
          'fat': 0.0,
        }),
      );

      final profileAsync = ref.read(profileNotifierProvider);
      final profile = await profileAsync.when(
        data: (d) => Future.value(d),
        loading: () => Future.value(null),
        error: (_, __) => Future.value(null),
      );

      final targetCalories = profile?.calorieGoal ?? 2000;
      final remaining = (targetCalories - todayCalories).clamp(0, 99999);
      final protein = todayMacros['protein']?.toInt() ?? 0;
      final carbs = todayMacros['carbs']?.toInt() ?? 0;
      final fat = todayMacros['fat']?.toInt() ?? 0;

      // 1. Main greeting — calories + macros summary
      greetings.add(l10n.greetingCalorieSummary(
        remaining.toInt(),
        protein,
        carbs,
        fat,
      ));

      // 2. Cuisine preference tip
      if (profile != null && profile.cuisinePreference.isNotEmpty) {
        final cuisineLabel =
            CuisineOptions.getLabel(profile.cuisinePreference);
        greetings.add(l10n.greetingCuisineTip(cuisineLabel));
      }

      // 3. Energy / streak tip
      final gamification = ref.read(gamificationProvider);
      if (gamification.balance > 0 &&
          gamification.currentStreak > 0) {
        greetings.add(l10n.greetingEnergyTip(gamification.balance));
      }

      // 4. Rename photo tip
      greetings.add(l10n.greetingRenamePhotoTip);

      // 5. Add ingredients tip
      greetings.add(l10n.greetingAddIngredientsTip);

      // 6. Backup reminder
      final lastBackup = await getLastBackupDate();
      if (lastBackup != null) {
        final daysSinceBackup =
            DateTime.now().difference(lastBackup).inDays;
        if (daysSinceBackup >= 3) {
          greetings.add(l10n.greetingBackupReminder(daysSinceBackup));
        }
      } else {
        greetings.add(l10n.greetingBackupReminder(0));
      }
    } catch (e) {
      AppLogger.warn('GreetingService: Error gathering data: $e');
    }

    // Fallback if nothing was generated
    if (greetings.isEmpty) {
      return l10n.greetingFallback;
    }

    // Pick a random greeting
    final random = Random();
    return greetings[random.nextInt(greetings.length)];
  }
}
