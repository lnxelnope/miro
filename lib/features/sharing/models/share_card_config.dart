import '../../../core/database/app_database.dart';

enum ShareCardType { foodItem, dailySummary, nutritionSummary }

class ShareCardConfig {
  final ShareCardType type;

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

  ShareCardConfig copyWith({
    ShareCardType? type,
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
