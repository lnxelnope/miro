import 'dart:ui' show Size;

import '../../../core/database/app_database.dart';

enum ShareCardType { foodItem, dailySummary, nutritionSummary }

/// Export aspect presets for share cards (9:16 vertical / 1:1 square / 16:9 wide).
enum ShareCardAspect { ratio9x16, ratio1x1, ratio16x9 }

class ShareCardConfig {
  final ShareCardType type;

  /// Card frame aspect; default 9:16 vertical (Stories / short video).
  final ShareCardAspect aspect;

  /// Food-item only: show serving line on hero image.
  final bool showServingOnImage;

  // Hero image (gallery pick — for daily/nutrition only)
  final String? heroImagePath;

  // Content toggles
  final bool showCalories;
  final bool showMacros;
  final bool showMicros;
  final bool showIngredients;
  final bool showStreak;
  final bool showGoalProgress;
  final bool showHealthData;

  // Food photos (daily summary only — multi-select from entries)
  final List<String> selectedFoodPhotos;

  // Data — one of these is set depending on type
  final FoodEntryData? foodEntry;
  final DateTime? date;
  final DateTime? dateRangeStart;
  final DateTime? dateRangeEnd;
  final String? periodLabel;

  // Goal data for badge
  final double? mealBudget;
  final double? calorieGoal;

  // Streak
  final int? streakDays;

  /// User referral / miroId — always shown under the logo on exported cards.
  final String referralCode;

  // Summary values (for daily/nutrition)
  final double? totalCalories;
  final double? totalProtein;
  final double? totalCarbs;
  final double? totalFat;
  final double? totalFiber;
  final double? totalSugar;
  final double? totalSodium;
  final int? daysTracked;
  final int? daysInPeriod;

  const ShareCardConfig({
    required this.type,
    this.aspect = ShareCardAspect.ratio9x16,
    this.showServingOnImage = false,
    this.heroImagePath,
    this.showCalories = true,
    this.showMacros = true,
    this.showMicros = false,
    this.showIngredients = true,
    this.showStreak = true,
    this.showGoalProgress = true,
    this.showHealthData = false,
    this.selectedFoodPhotos = const [],
    this.foodEntry,
    this.date,
    this.dateRangeStart,
    this.dateRangeEnd,
    this.periodLabel,
    this.mealBudget,
    this.calorieGoal,
    this.streakDays,
    this.referralCode = '',
    this.totalCalories,
    this.totalProtein,
    this.totalCarbs,
    this.totalFat,
    this.totalFiber,
    this.totalSugar,
    this.totalSodium,
    this.daysTracked,
    this.daysInPeriod,
  });

  double get aspectRatio => switch (aspect) {
        ShareCardAspect.ratio9x16 => 9 / 16,
        ShareCardAspect.ratio1x1 => 1.0,
        ShareCardAspect.ratio16x9 => 16 / 9,
      };

  /// Logical pixel size for card layout & capture (scaled by FittedBox in UI).
  Size get logicalSize => switch (aspect) {
        ShareCardAspect.ratio9x16 => const Size(360, 640),
        ShareCardAspect.ratio1x1 => const Size(360, 360),
        ShareCardAspect.ratio16x9 => const Size(360, 202.5),
      };

  /// Scale inner typography/layout vs original 360×450 card.
  double get layoutScale {
    const refW = 360.0;
    const refH = 450.0;
    final s = logicalSize;
    final sx = s.width / refW;
    final sy = s.height / refH;
    return (sx < sy ? sx : sy).clamp(0.38, 1.2);
  }

  ShareCardConfig copyWith({
    ShareCardType? type,
    ShareCardAspect? aspect,
    bool? showServingOnImage,
    String? heroImagePath,
    bool clearHeroImage = false,
    bool? showCalories,
    bool? showMacros,
    bool? showMicros,
    bool? showIngredients,
    bool? showStreak,
    bool? showGoalProgress,
    bool? showHealthData,
    List<String>? selectedFoodPhotos,
    FoodEntryData? foodEntry,
    DateTime? date,
    DateTime? dateRangeStart,
    DateTime? dateRangeEnd,
    String? periodLabel,
    double? mealBudget,
    double? calorieGoal,
    int? streakDays,
    String? referralCode,
    double? totalCalories,
    double? totalProtein,
    double? totalCarbs,
    double? totalFat,
    double? totalFiber,
    double? totalSugar,
    double? totalSodium,
    int? daysTracked,
    int? daysInPeriod,
  }) {
    return ShareCardConfig(
      type: type ?? this.type,
      aspect: aspect ?? this.aspect,
      showServingOnImage: showServingOnImage ?? this.showServingOnImage,
      heroImagePath: clearHeroImage ? null : (heroImagePath ?? this.heroImagePath),
      showCalories: showCalories ?? this.showCalories,
      showMacros: showMacros ?? this.showMacros,
      showMicros: showMicros ?? this.showMicros,
      showIngredients: showIngredients ?? this.showIngredients,
      showStreak: showStreak ?? this.showStreak,
      showGoalProgress: showGoalProgress ?? this.showGoalProgress,
      showHealthData: showHealthData ?? this.showHealthData,
      selectedFoodPhotos: selectedFoodPhotos ?? this.selectedFoodPhotos,
      foodEntry: foodEntry ?? this.foodEntry,
      date: date ?? this.date,
      dateRangeStart: dateRangeStart ?? this.dateRangeStart,
      dateRangeEnd: dateRangeEnd ?? this.dateRangeEnd,
      periodLabel: periodLabel ?? this.periodLabel,
      mealBudget: mealBudget ?? this.mealBudget,
      calorieGoal: calorieGoal ?? this.calorieGoal,
      streakDays: streakDays ?? this.streakDays,
      referralCode: referralCode ?? this.referralCode,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProtein: totalProtein ?? this.totalProtein,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFat: totalFat ?? this.totalFat,
      totalFiber: totalFiber ?? this.totalFiber,
      totalSugar: totalSugar ?? this.totalSugar,
      totalSodium: totalSodium ?? this.totalSodium,
      daysTracked: daysTracked ?? this.daysTracked,
      daysInPeriod: daysInPeriod ?? this.daysInPeriod,
    );
  }

  double? get goalPercent {
    if (type == ShareCardType.foodItem && foodEntry != null && mealBudget != null && mealBudget! > 0) {
      return (foodEntry!.calories / mealBudget!) * 100;
    }
    if (totalCalories != null && calorieGoal != null && calorieGoal! > 0) {
      return (totalCalories! / calorieGoal!) * 100;
    }
    return null;
  }
}
