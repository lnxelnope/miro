import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/database/database_service.dart';
import '../models/micronutrient_stats.dart';
import '../models/food_entry.dart';

/// Provider for micronutrient statistics
final micronutrientStatsProvider = FutureProvider.autoDispose<MicronutrientStatistics>((ref) async {
  final now = DateTime.now();
  
  // Get food entries for different time periods
  final last30Days = await _getFoodEntriesForPeriod(30);
  final last7Days = await _getFoodEntriesForPeriod(7);
  final last365Days = await _getFoodEntriesForPeriod(365);
  
  // Calculate stats for each micronutrient
  final fiberStats = _calculateStats(
    name: 'Fiber',
    unit: 'g',
    entries: last365Days,
    dailyEntries: last30Days,
    weeklyEntries: last7Days,
    extractor: (entry) => entry.fiber ?? 0,
  );
  
  final sugarStats = _calculateStats(
    name: 'Sugar',
    unit: 'g',
    entries: last365Days,
    dailyEntries: last30Days,
    weeklyEntries: last7Days,
    extractor: (entry) => entry.sugar ?? 0,
  );
  
  final sodiumStats = _calculateStats(
    name: 'Sodium',
    unit: 'mg',
    entries: last365Days,
    dailyEntries: last30Days,
    weeklyEntries: last7Days,
    extractor: (entry) => entry.sodium ?? 0,
  );
  
  final cholesterolStats = _calculateStats(
    name: 'Cholesterol',
    unit: 'mg',
    entries: last365Days,
    dailyEntries: last30Days,
    weeklyEntries: last7Days,
    extractor: (entry) => entry.cholesterol ?? 0,
  );
  
  final saturatedFatStats = _calculateStats(
    name: 'Saturated Fat',
    unit: 'g',
    entries: last365Days,
    dailyEntries: last30Days,
    weeklyEntries: last7Days,
    extractor: (entry) => entry.saturatedFat ?? 0,
  );
  
  return MicronutrientStatistics(
    fiber: fiberStats,
    sugar: sugarStats,
    sodium: sodiumStats,
    cholesterol: cholesterolStats,
    saturatedFat: saturatedFatStats,
  );
});

/// Get food entries for the last N days
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

/// Calculate statistics for a micronutrient
MicronutrientStats? _calculateStats({
  required String name,
  required String unit,
  required List<FoodEntry> entries,
  required List<FoodEntry> dailyEntries,
  required List<FoodEntry> weeklyEntries,
  required double Function(FoodEntry) extractor,
}) {
  if (entries.isEmpty) return null;
  
  // Calculate daily values (last 30 days)
  final dailyValueMap = <DateTime, double>{};
  for (final entry in dailyEntries) {
    final dateOnly = DateTime(
      entry.timestamp.year,
      entry.timestamp.month,
      entry.timestamp.day,
    );
    dailyValueMap[dateOnly] = (dailyValueMap[dateOnly] ?? 0) + extractor(entry);
  }
  
  final dailyValues = dailyValueMap.entries
      .map((e) => DailyValue(date: e.key, value: e.value))
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));
  
  // Calculate averages
  final totalValue = entries.fold<double>(0, (sum, entry) => sum + extractor(entry));
  final daysWithData = dailyValueMap.length;
  
  final dailyAverage = daysWithData > 0 ? (totalValue / daysWithData).toDouble() : 0.0;
  
  final weeklyValueMap = <DateTime, double>{};
  for (final entry in weeklyEntries) {
    final dateOnly = DateTime(
      entry.timestamp.year,
      entry.timestamp.month,
      entry.timestamp.day,
    );
    weeklyValueMap[dateOnly] = (weeklyValueMap[dateOnly] ?? 0) + extractor(entry);
  }
  final weeklyAverage = weeklyValueMap.isNotEmpty
      ? (weeklyValueMap.values.reduce((a, b) => a + b) / weeklyValueMap.length).toDouble()
      : 0.0;
  
  final monthlyValueMap = <String, double>{};
  for (final entry in entries) {
    final monthKey = '${entry.timestamp.year}-${entry.timestamp.month}';
    monthlyValueMap[monthKey] = (monthlyValueMap[monthKey] ?? 0) + extractor(entry);
  }
  final monthlyAverage = monthlyValueMap.isNotEmpty
      ? (monthlyValueMap.values.reduce((a, b) => a + b) / monthlyValueMap.length).toDouble()
      : 0.0;
  
  final yearlyAverage = dailyAverage.toDouble(); // Simplified
  
  return MicronutrientStats(
    name: name,
    unit: unit,
    dailyAverage: dailyAverage,
    weeklyAverage: weeklyAverage,
    monthlyAverage: monthlyAverage,
    yearlyAverage: yearlyAverage,
    dailyValues: dailyValues,
  );
}
