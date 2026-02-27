import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/database/database_service.dart';
import '../../../core/constants/fda_daily_values.dart';
import '../models/micronutrient_stats.dart';
import '../models/food_entry.dart';

/// Provider for micronutrient statistics
final micronutrientStatsProvider =
    FutureProvider.autoDispose<MicronutrientStatistics>((ref) async {
  final last30Days = await _getFoodEntriesForPeriod(30);
  final last7Days = await _getFoodEntriesForPeriod(7);
  final last365Days = await _getFoodEntriesForPeriod(365);

  return MicronutrientStatistics(
    fiber: _calculateStats(
      name: 'Fiber', key: 'fiber', unit: 'g',
      entries: last365Days, dailyEntries: last30Days, weeklyEntries: last7Days,
      extractor: (e) => e.fiber ?? 0,
      fdaDv: FdaDailyValues.fiber,
    ),
    sugar: _calculateStats(
      name: 'Sugar', key: 'sugar', unit: 'g',
      entries: last365Days, dailyEntries: last30Days, weeklyEntries: last7Days,
      extractor: (e) => e.sugar ?? 0,
      fdaDv: FdaDailyValues.sugar,
    ),
    sodium: _calculateStats(
      name: 'Sodium', key: 'sodium', unit: 'mg',
      entries: last365Days, dailyEntries: last30Days, weeklyEntries: last7Days,
      extractor: (e) => e.sodium ?? 0,
      fdaDv: FdaDailyValues.sodium,
    ),
    cholesterol: _calculateStats(
      name: 'Cholesterol', key: 'cholesterol', unit: 'mg',
      entries: last365Days, dailyEntries: last30Days, weeklyEntries: last7Days,
      extractor: (e) => e.cholesterol ?? 0,
      fdaDv: FdaDailyValues.cholesterol,
    ),
    saturatedFat: _calculateStats(
      name: 'Saturated Fat', key: 'saturatedFat', unit: 'g',
      entries: last365Days, dailyEntries: last30Days, weeklyEntries: last7Days,
      extractor: (e) => e.saturatedFat ?? 0,
      fdaDv: FdaDailyValues.saturatedFat,
    ),
    transFat: _calculateStats(
      name: 'Trans Fat', key: 'transFat', unit: 'g',
      entries: last365Days, dailyEntries: last30Days, weeklyEntries: last7Days,
      extractor: (e) => e.transFat ?? 0,
      fdaDv: FdaDailyValues.transFat,
    ),
    unsaturatedFat: _calculateStats(
      name: 'Unsaturated Fat', key: 'unsaturatedFat', unit: 'g',
      entries: last365Days, dailyEntries: last30Days, weeklyEntries: last7Days,
      extractor: (e) => e.unsaturatedFat ?? 0,
    ),
    monounsaturatedFat: _calculateStats(
      name: 'Mono Fat', key: 'monounsaturatedFat', unit: 'g',
      entries: last365Days, dailyEntries: last30Days, weeklyEntries: last7Days,
      extractor: (e) => e.monounsaturatedFat ?? 0,
    ),
    polyunsaturatedFat: _calculateStats(
      name: 'Poly Fat', key: 'polyunsaturatedFat', unit: 'g',
      entries: last365Days, dailyEntries: last30Days, weeklyEntries: last7Days,
      extractor: (e) => e.polyunsaturatedFat ?? 0,
    ),
    potassium: _calculateStats(
      name: 'Potassium', key: 'potassium', unit: 'mg',
      entries: last365Days, dailyEntries: last30Days, weeklyEntries: last7Days,
      extractor: (e) => e.potassium ?? 0,
      fdaDv: FdaDailyValues.potassium,
    ),
  );
});

Future<List<FoodEntry>> _getFoodEntriesForPeriod(int days) async {
  final now = DateTime.now();
  final startDate = now.subtract(Duration(days: days));
  return await DatabaseService.foodEntries
      .filter()
      .timestampBetween(startDate, now)
      .isDeletedEqualTo(false)
      .sortByTimestampDesc()
      .findAll();
}

MicronutrientStats? _calculateStats({
  required String name,
  required String key,
  required String unit,
  required List<FoodEntry> entries,
  required List<FoodEntry> dailyEntries,
  required List<FoodEntry> weeklyEntries,
  required double Function(FoodEntry) extractor,
  double? fdaDv,
}) {
  if (entries.isEmpty) return null;

  final dailyValueMap = <DateTime, double>{};
  for (final entry in dailyEntries) {
    final dateOnly = DateTime(
      entry.timestamp.year, entry.timestamp.month, entry.timestamp.day,
    );
    dailyValueMap[dateOnly] = (dailyValueMap[dateOnly] ?? 0) + extractor(entry);
  }

  final dailyValues = dailyValueMap.entries
      .map((e) => DailyValue(date: e.key, value: e.value))
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  final totalValue = entries.fold<double>(0, (sum, e) => sum + extractor(e));
  final daysWithData = dailyValueMap.length;
  final dailyAverage = daysWithData > 0 ? totalValue / daysWithData : 0.0;

  final weeklyValueMap = <DateTime, double>{};
  for (final entry in weeklyEntries) {
    final dateOnly = DateTime(
      entry.timestamp.year, entry.timestamp.month, entry.timestamp.day,
    );
    weeklyValueMap[dateOnly] = (weeklyValueMap[dateOnly] ?? 0) + extractor(entry);
  }
  final weeklyAverage = weeklyValueMap.isNotEmpty
      ? weeklyValueMap.values.reduce((a, b) => a + b) / weeklyValueMap.length
      : 0.0;

  final monthlyValueMap = <String, double>{};
  for (final entry in entries) {
    final monthKey = '${entry.timestamp.year}-${entry.timestamp.month}';
    monthlyValueMap[monthKey] = (monthlyValueMap[monthKey] ?? 0) + extractor(entry);
  }
  final monthlyAverage = monthlyValueMap.isNotEmpty
      ? monthlyValueMap.values.reduce((a, b) => a + b) / monthlyValueMap.length
      : 0.0;

  return MicronutrientStats(
    name: name,
    key: key,
    unit: unit,
    dailyAverage: dailyAverage,
    weeklyAverage: weeklyAverage,
    monthlyAverage: monthlyAverage,
    yearlyAverage: dailyAverage,
    fdaDailyValue: fdaDv,
    dailyValues: dailyValues,
  );
}
