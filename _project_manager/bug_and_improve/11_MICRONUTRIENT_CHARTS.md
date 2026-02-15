# Implementation Guide #11: Micronutrient Charts (Collapsible)

**Priority:** 🟡 Medium  
**Estimated Time:** 3-4 hours  
**Difficulty:** Medium

---

## Overview

Create collapsible charts for micronutrients showing daily, monthly, and yearly averages. This section is hidden by default to reduce clutter.

---

## Prerequisites

- Task #09 (Micronutrients in Summary) must be completed first
- Task #10 (Today Summary Dashboard) must be completed first
- Ensure micronutrient data is being tracked

---

## Files to Create/Modify

### New Files:
1. `lib/features/health/widgets/micronutrient_charts_section.dart` - Main collapsible section
2. `lib/features/health/models/micronutrient_stats.dart` - Stats model
3. `lib/features/health/providers/micronutrient_stats_provider.dart` - Stats provider

### Files to Modify:
1. `lib/features/health/presentation/today_summary_dashboard_screen.dart` - Add charts section

---

## Step-by-Step Implementation

### STEP 1: Add Chart Package Dependency

**File:** `pubspec.yaml`

**Find the `dependencies:` section:**

```yaml
dependencies:
  flutter:
    sdk: flutter
  fl_chart: ^0.65.0  # Add this line for charts
  # ... other dependencies
```

**Run:**
```bash
flutter pub get
```

---

### STEP 2: Create Micronutrient Stats Model

**Create file:** `lib/features/health/models/micronutrient_stats.dart`

**Full file content:**

```dart
/// Statistics for a single micronutrient over time
class MicronutrientStats {
  final String name;
  final String unit;
  final double dailyAverage;
  final double weeklyAverage;
  final double monthlyAverage;
  final double yearlyAverage;
  final List<DailyValue> dailyValues; // Last 30 days

  const MicronutrientStats({
    required this.name,
    required this.unit,
    required this.dailyAverage,
    required this.weeklyAverage,
    required this.monthlyAverage,
    required this.yearlyAverage,
    required this.dailyValues,
  });
}

/// A single day's micronutrient value
class DailyValue {
  final DateTime date;
  final double value;

  const DailyValue({
    required this.date,
    required this.value,
  });
}

/// All micronutrient statistics
class MicronutrientStatistics {
  final MicronutrientStats? fiber;
  final MicronutrientStats? sugar;
  final MicronutrientStats? sodium;
  final MicronutrientStats? cholesterol;
  final MicronutrientStats? saturatedFat;

  const MicronutrientStatistics({
    this.fiber,
    this.sugar,
    this.sodium,
    this.cholesterol,
    this.saturatedFat,
  });

  bool get hasAnyData =>
      fiber != null ||
      sugar != null ||
      sodium != null ||
      cholesterol != null ||
      saturatedFat != null;
}
```

---

### STEP 3: Create Micronutrient Stats Provider

**Create file:** `lib/features/health/providers/micronutrient_stats_provider.dart`

**Full file content:**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro/features/health/models/micronutrient_stats.dart';
import 'package:miro/features/health/providers/health_provider.dart';

/// Provider for micronutrient statistics
final micronutrientStatsProvider = FutureProvider.autoDispose<MicronutrientStatistics>((ref) async {
  final now = DateTime.now();
  
  // Get food entries for different time periods
  final last30Days = await _getFoodEntriesForPeriod(ref, 30);
  final last7Days = await _getFoodEntriesForPeriod(ref, 7);
  final last365Days = await _getFoodEntriesForPeriod(ref, 365);
  
  // Calculate stats for each micronutrient
  final fiberStats = _calculateStats(
    name: 'Fiber',
    unit: 'g',
    entries: last365Days,
    dailyEntries: last30Days,
    weeklyEntries: last7Days,
    extractor: (entry) => entry.calculatedNutrition.fiber ?? 0,
  );
  
  final sugarStats = _calculateStats(
    name: 'Sugar',
    unit: 'g',
    entries: last365Days,
    dailyEntries: last30Days,
    weeklyEntries: last7Days,
    extractor: (entry) => entry.calculatedNutrition.sugar ?? 0,
  );
  
  final sodiumStats = _calculateStats(
    name: 'Sodium',
    unit: 'mg',
    entries: last365Days,
    dailyEntries: last30Days,
    weeklyEntries: last7Days,
    extractor: (entry) => entry.calculatedNutrition.sodium ?? 0,
  );
  
  final cholesterolStats = _calculateStats(
    name: 'Cholesterol',
    unit: 'mg',
    entries: last365Days,
    dailyEntries: last30Days,
    weeklyEntries: last7Days,
    extractor: (entry) => entry.calculatedNutrition.cholesterol ?? 0,
  );
  
  final saturatedFatStats = _calculateStats(
    name: 'Saturated Fat',
    unit: 'g',
    entries: last365Days,
    dailyEntries: last30Days,
    weeklyEntries: last7Days,
    extractor: (entry) => entry.calculatedNutrition.saturatedFat ?? 0,
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
Future<List<FoodEntry>> _getFoodEntriesForPeriod(
  AutoDisposeProviderRef ref,
  int days,
) async {
  final now = DateTime.now();
  final startDate = now.subtract(Duration(days: days));
  
  // TODO: Implement database query to get entries between startDate and now
  // This is a placeholder - replace with actual database query
  final allEntries = <FoodEntry>[];
  
  return allEntries.where((entry) {
    return entry.createdAt.isAfter(startDate);
  }).toList();
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
      entry.createdAt.year,
      entry.createdAt.month,
      entry.createdAt.day,
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
  
  final dailyAverage = daysWithData > 0 ? totalValue / daysWithData : 0;
  
  final weeklyValueMap = <DateTime, double>{};
  for (final entry in weeklyEntries) {
    final dateOnly = DateTime(
      entry.createdAt.year,
      entry.createdAt.month,
      entry.createdAt.day,
    );
    weeklyValueMap[dateOnly] = (weeklyValueMap[dateOnly] ?? 0) + extractor(entry);
  }
  final weeklyAverage = weeklyValueMap.isNotEmpty
      ? weeklyValueMap.values.reduce((a, b) => a + b) / weeklyValueMap.length
      : 0;
  
  final monthlyValueMap = <String, double>{};
  for (final entry in entries) {
    final monthKey = '${entry.createdAt.year}-${entry.createdAt.month}';
    monthlyValueMap[monthKey] = (monthlyValueMap[monthKey] ?? 0) + extractor(entry);
  }
  final monthlyAverage = monthlyValueMap.isNotEmpty
      ? monthlyValueMap.values.reduce((a, b) => a + b) / monthlyValueMap.length
      : 0;
  
  final yearlyAverage = dailyAverage; // Simplified
  
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
```

---

### STEP 4: Create Micronutrient Charts Section Widget

**Create file:** `lib/features/health/widgets/micronutrient_charts_section.dart`

**Full file content (PART 1 - imports and class definition):**

```dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro/core/theme/app_colors.dart';
import 'package:miro/features/health/models/micronutrient_stats.dart';
import 'package:miro/features/health/providers/micronutrient_stats_provider.dart';

class MicronutrientChartsSection extends ConsumerStatefulWidget {
  const MicronutrientChartsSection({super.key});

  @override
  ConsumerState<MicronutrientChartsSection> createState() =>
      _MicronutrientChartsSectionState();
}

class _MicronutrientChartsSectionState
    extends ConsumerState<MicronutrientChartsSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(micronutrientStatsProvider);

    return statsAsync.when(
      data: (stats) {
        if (!stats.hasAnyData) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with expand/collapse button
              InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.show_chart,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Micronutrient Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Icon(
                        _isExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ),

              // Expandable content
              if (_isExpanded) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info note
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Showing average daily intake. No goals set for micronutrients.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),

                      // Individual micronutrient charts
                      if (stats.fiber != null)
                        _buildMicronutrientCard(
                          stats.fiber!,
                          Colors.green,
                          Icons.grass,
                        ),
                      
                      if (stats.sugar != null)
                        _buildMicronutrientCard(
                          stats.sugar!,
                          Colors.pink,
                          Icons.cake,
                        ),
                      
                      if (stats.sodium != null)
                        _buildMicronutrientCard(
                          stats.sodium!,
                          Colors.orange,
                          Icons.water_drop,
                        ),
                      
                      if (stats.cholesterol != null)
                        _buildMicronutrientCard(
                          stats.cholesterol!,
                          Colors.red,
                          Icons.favorite,
                        ),
                      
                      if (stats.saturatedFat != null)
                        _buildMicronutrientCard(
                          stats.saturatedFat!,
                          Colors.purple,
                          Icons.opacity,
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildMicronutrientCard(
    MicronutrientStats stats,
    Color color,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  stats.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Average values
          Row(
            children: [
              Expanded(
                child: _buildAverageBox(
                  'Daily',
                  stats.dailyAverage,
                  stats.unit,
                  color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAverageBox(
                  'Weekly',
                  stats.weeklyAverage,
                  stats.unit,
                  color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAverageBox(
                  'Monthly',
                  stats.monthlyAverage,
                  stats.unit,
                  color,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Chart (last 30 days)
          if (stats.dailyValues.isNotEmpty) ...[
            const Text(
              'Last 30 Days',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: _buildLineChart(stats, color),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAverageBox(
    String label,
    double value,
    String unit,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${value.toStringAsFixed(1)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(MicronutrientStats stats, Color color) {
    final spots = stats.dailyValues
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.value))
        .toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 10,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 5,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < stats.dailyValues.length) {
                  final date = stats.dailyValues[value.toInt()].date;
                  return Text(
                    '${date.day}',
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (stats.dailyValues.length - 1).toDouble(),
        minY: 0,
        maxY: stats.dailyValues.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.15),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

### STEP 5: Add Charts Section to Dashboard

**File:** `lib/features/health/presentation/today_summary_dashboard_screen.dart`

**After the macronutrient section, add:**

```dart
import 'package:miro/features/health/widgets/micronutrient_charts_section.dart';

// In the scrollable content, after macro charts:
const MicronutrientChartsSection(),
```

---

## Testing Checklist

- [ ] Chart package installed successfully
- [ ] Section is collapsed by default
- [ ] Tapping header expands/collapses section
- [ ] Only micronutrients with data are shown
- [ ] Each micronutrient shows icon and color
- [ ] Average boxes display correct values
- [ ] Line chart displays last 30 days data
- [ ] Chart is readable and scales properly
- [ ] Info note explains no goals are set
- [ ] No crashes when data is missing
- [ ] Section hides if no micronutrient data exists

---

## Troubleshooting

### Issue: Charts don't display
**Solution:** Ensure `fl_chart` package is installed. Run `flutter pub get`.

### Issue: No data in charts
**Solution:** Verify micronutrient data exists. Check provider logic and database queries.

### Issue: Chart overflow errors
**Solution:** Wrap chart in `SizedBox` with fixed height. Check min/max values.

### Issue: Expand/collapse doesn't animate
**Solution:** Add `AnimatedSize` or `AnimatedContainer` wrapper.

---

## Completion Criteria

✅ Task is complete when:
- Chart package integrated
- Collapsible section created
- Charts display for all tracked micronutrients
- Averages calculated correctly
- Line charts show last 30 days
- Section is collapsed by default
- No errors when data is missing
- Tested with real data

---

## Estimated Time

- 1 hour: Set up chart package and models
- 1 hour: Create charts section widget
- 1 hour: Implement chart rendering
- 30 min: Integration and styling
- 30 min: Testing

**Total: 3-4 hours**
