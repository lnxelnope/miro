import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_hybrid/features/health/models/nutrition_summary.dart';
import 'package:miro_hybrid/features/health/models/time_period_summary.dart';
import 'package:miro_hybrid/features/health/providers/health_provider.dart';
import 'package:miro_hybrid/features/profile/providers/profile_provider.dart';

/// Provider for nutrition summary for a specific date
final nutritionSummaryProvider =
    FutureProvider.family<NutritionSummary, DateTime>(
  (ref, date) async {
    final foodEntries = await ref.watch(foodEntriesByDateProvider(date).future);
    final profileAsync = ref.watch(profileNotifierProvider);

    // Calculate actual intake
    double actualCalories = 0;
    double actualProtein = 0;
    double actualCarbs = 0;
    double actualFat = 0;

    for (final entry in foodEntries) {
      actualCalories += entry.calories;
      actualProtein += entry.protein;
      actualCarbs += entry.carbs;
      actualFat += entry.fat;
    }

    return profileAsync.when(
      data: (profile) => NutritionSummary(
        date: date,
        actualCalories: actualCalories,
        actualProtein: actualProtein,
        actualCarbs: actualCarbs,
        actualFat: actualFat,
        goalCalories: profile.calorieGoal,
        goalProtein: profile.proteinGoal,
        goalCarbs: profile.carbGoal,
        goalFat: profile.fatGoal,
      ),
      loading: () => NutritionSummary(
        date: date,
        actualCalories: actualCalories,
        actualProtein: actualProtein,
        actualCarbs: actualCarbs,
        actualFat: actualFat,
        goalCalories: 2000,
        goalProtein: 150,
        goalCarbs: 250,
        goalFat: 65,
      ),
      error: (_, __) => NutritionSummary(
        date: date,
        actualCalories: actualCalories,
        actualProtein: actualProtein,
        actualCarbs: actualCarbs,
        actualFat: actualFat,
        goalCalories: 2000,
        goalProtein: 150,
        goalCarbs: 250,
        goalFat: 65,
      ),
    );
  },
);

/// Provider for time period summaries
final timePeriodSummariesProvider = FutureProvider<List<TimePeriodSummary>>(
  (ref) async {
    final now = DateTime.now();

    final periods = [
      const _PeriodConfig('1 Day', 1),
      const _PeriodConfig('1 Week', 7),
      const _PeriodConfig('1 Month', 30),
      const _PeriodConfig('1 Year', 365),
      const _PeriodConfig('All Time', -1), // -1 means all available data
    ];

    final summaries = <TimePeriodSummary>[];

    for (final period in periods) {
      final summary = await _calculatePeriodSummary(ref, period, now);
      summaries.add(summary);
    }

    return summaries;
  },
);

class _PeriodConfig {
  final String label;
  final int days;
  const _PeriodConfig(this.label, this.days);
}

Future<TimePeriodSummary> _calculatePeriodSummary(
  Ref ref,
  _PeriodConfig period,
  DateTime endDate,
) async {
  final profileAsync = ref.read(profileNotifierProvider);

  // Get all relevant dates
  final dates = <DateTime>[];
  if (period.days == -1) {
    // All time - use last 365 days as approximation
    for (int i = 0; i < 365; i++) {
      dates.add(endDate.subtract(Duration(days: i)));
    }
  } else {
    for (int i = 0; i < period.days; i++) {
      dates.add(endDate.subtract(Duration(days: i)));
    }
  }

  double totalCaloriesDiff = 0;
  double totalProteinDiff = 0;
  double totalCarbsDiff = 0;
  double totalFatDiff = 0;

  int daysWithData = 0;

  for (final date in dates) {
    try {
      final summary = await ref.read(nutritionSummaryProvider(date).future);

      // Only count days with actual food entries
      if (summary.actualCalories > 0) {
        totalCaloriesDiff += summary.caloriesDifference;
        totalProteinDiff += summary.proteinDifference;
        totalCarbsDiff += summary.carbsDifference;
        totalFatDiff += summary.fatDifference;
        daysWithData++;
      }
    } catch (e) {
      // Skip dates with errors
      continue;
    }
  }

  final actualDays = daysWithData > 0 ? daysWithData : 1;

  return TimePeriodSummary(
    label: period.label,
    days: period.days == -1 ? daysWithData : period.days,
    totalCaloriesDifference: totalCaloriesDiff,
    totalProteinDifference: totalProteinDiff,
    totalCarbsDifference: totalCarbsDiff,
    totalFatDifference: totalFatDiff,
    averageCaloriesPerDay: totalCaloriesDiff / actualDays,
    averageProteinPerDay: totalProteinDiff / actualDays,
    averageCarbsPerDay: totalCarbsDiff / actualDays,
    averageFatPerDay: totalFatDiff / actualDays,
  );
}
