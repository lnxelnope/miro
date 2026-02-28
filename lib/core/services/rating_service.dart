import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages app store rating prompts using the native review API.
///
/// Strategy: Trigger at natural "positive moments" — never tied to
/// energy rewards. Apple allows max 3 native prompts per 365 days
/// and controls when the dialog actually shows.
///
/// Milestones that trigger a review prompt:
///   - 10 meals logged (first experience)
///   - 30 meals logged (committed user)
///   - 7-day streak (engaged user)
class RatingService {
  static const String _keyHasPrompted = 'rating_prompted_milestones';

  static final InAppReview _inAppReview = InAppReview.instance;

  /// Meal-count milestones where we call requestReview()
  static const List<int> _mealMilestones = [10, 30, 75, 200];

  /// Streak milestones where we call requestReview()
  static const List<int> _streakMilestones = [7, 30];

  /// Call after a meal is logged. Checks if the total count
  /// has crossed a milestone and triggers native review if so.
  static Future<void> checkMealMilestone(int totalMealsLogged) async {
    final prefs = await SharedPreferences.getInstance();
    final prompted = prefs.getStringList(_keyHasPrompted) ?? [];

    for (final milestone in _mealMilestones) {
      final key = 'meals_$milestone';
      if (totalMealsLogged >= milestone && !prompted.contains(key)) {
        prompted.add(key);
        await prefs.setStringList(_keyHasPrompted, prompted);
        await _tryRequestReview();
        return;
      }
    }
  }

  /// Call when streak updates. Checks if streak has crossed
  /// a milestone and triggers native review if so.
  static Future<void> checkStreakMilestone(int currentStreak) async {
    final prefs = await SharedPreferences.getInstance();
    final prompted = prefs.getStringList(_keyHasPrompted) ?? [];

    for (final milestone in _streakMilestones) {
      final key = 'streak_$milestone';
      if (currentStreak >= milestone && !prompted.contains(key)) {
        prompted.add(key);
        await prefs.setStringList(_keyHasPrompted, prompted);
        await _tryRequestReview();
        return;
      }
    }
  }

  /// Calls the native in-app review API.
  /// Apple/Google control whether the dialog actually appears.
  static Future<void> _tryRequestReview() async {
    try {
      final isAvailable = await _inAppReview.isAvailable();
      if (isAvailable) {
        debugPrint('[RatingService] Requesting native review');
        await _inAppReview.requestReview();
      } else {
        debugPrint('[RatingService] In-app review not available');
      }
    } catch (e) {
      debugPrint('[RatingService] requestReview error: $e');
    }
  }
}
