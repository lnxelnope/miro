# Implementation Guide #10: Today Summary - Full Nutrition Dashboard

**Priority:** 🟡 High  
**Estimated Time:** 8-12 hours  
**Difficulty:** High

---

## Overview

Create a comprehensive nutrition dashboard that shows:
- Today's intake vs goals
- Date navigation to view any date
- Goals vs Actual comparison table
- Time-period summaries (1 day, 1 week, 1 month, 1 year, all time)
- Surplus/deficit calculations

This is the largest and most complex feature in this project.

---

## Files to Create

### New Files:
1. `lib/features/health/presentation/today_summary_dashboard_screen.dart` - Main dashboard screen
2. `lib/features/health/models/nutrition_summary.dart` - Summary data model
3. `lib/features/health/models/time_period_summary.dart` - Time period stats model
4. `lib/features/health/providers/nutrition_summary_provider.dart` - Summary provider
5. `lib/features/health/widgets/goals_vs_actual_table.dart` - Comparison table widget
6. `lib/features/health/widgets/time_period_cards.dart` - Period summary cards
7. `lib/features/health/widgets/date_navigation_bar.dart` - Date selector widget

### Files to Modify:
1. `lib/features/home/presentation/home_screen.dart` - Add dashboard button
2. `lib/features/health/widgets/daily_summary_card.dart` - Add dashboard navigation

---

## Architecture Overview

```
TodaySummaryDashboardScreen
  ├── DateNavigationBar (date selector)
  ├── GoalsVsActualTable (today's goals vs actual)
  ├── MacronutrientProgressCharts (visual progress)
  ├── TimePeriodCards (1 day, 1 week, 1 month, etc.)
  └── MicronutrientChartsSection (from Task #11)
```

---

## Step-by-Step Implementation

### STEP 1: Create Data Models

**Create file:** `lib/features/health/models/nutrition_summary.dart`

**Full file content:**

```dart
/// Summary of nutritional intake for a specific date
class NutritionSummary {
  final DateTime date;
  final double actualCalories;
  final double actualProtein;
  final double actualCarbs;
  final double actualFat;
  final double goalCalories;
  final double goalProtein;
  final double goalCarbs;
  final double goalFat;

  const NutritionSummary({
    required this.date,
    required this.actualCalories,
    required this.actualProtein,
    required this.actualCarbs,
    required this.actualFat,
    required this.goalCalories,
    required this.goalProtein,
    required this.goalCarbs,
    required this.goalFat,
  });

  // Calculate differences
  double get caloriesDifference => actualCalories - goalCalories;
  double get proteinDifference => actualProtein - goalProtein;
  double get carbsDifference => actualCarbs - goalCarbs;
  double get fatDifference => actualFat - goalFat;

  // Calculate percentages
  double get caloriesPercentage => goalCalories > 0 ? (actualCalories / goalCalories) * 100 : 0;
  double get proteinPercentage => goalProtein > 0 ? (actualProtein / goalProtein) * 100 : 0;
  double get carbsPercentage => goalCarbs > 0 ? (actualCarbs / goalCarbs) * 100 : 0;
  double get fatPercentage => goalFat > 0 ? (actualFat / goalFat) * 100 : 0;

  // Is over/under goal
  bool get isCaloriesOver => actualCalories > goalCalories;
  bool get isProteinOver => actualProtein > goalProtein;
  bool get isCarbsOver => actualCarbs > goalCarbs;
  bool get isFatOver => actualFat > goalFat;
}
```

---

**Create file:** `lib/features/health/models/time_period_summary.dart`

**Full file content:**

```dart
/// Summary of surplus/deficit over a time period
class TimePeriodSummary {
  final String label; // "1 Day", "1 Week", etc.
  final int days;
  final double totalCaloriesDifference;
  final double totalProteinDifference;
  final double totalCarbsDifference;
  final double totalFatDifference;
  final double averageCaloriesPerDay;
  final double averageProteinPerDay;
  final double averageCarbsPerDay;
  final double averageFatPerDay;

  const TimePeriodSummary({
    required this.label,
    required this.days,
    required this.totalCaloriesDifference,
    required this.totalProteinDifference,
    required this.totalCarbsDifference,
    required this.totalFatDifference,
    required this.averageCaloriesPerDay,
    required this.averageProteinPerDay,
    required this.averageCarbsPerDay,
    required this.averageFatPerDay,
  });

  bool get isCaloriesSurplus => totalCaloriesDifference > 0;
  bool get isProteinSurplus => totalProteinDifference > 0;
  bool get isCarbsSurplus => totalCarbsDifference > 0;
  bool get isFatSurplus => totalFatDifference > 0;
}
```

---

### STEP 2: Create Summary Provider

**Create file:** `lib/features/health/providers/nutrition_summary_provider.dart`

**Full file content:**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro/features/health/models/nutrition_summary.dart';
import 'package:miro/features/health/models/time_period_summary.dart';
import 'package:miro/features/health/providers/health_provider.dart';
import 'package:miro/features/profile/providers/profile_provider.dart';

/// Provider for nutrition summary for a specific date
final nutritionSummaryProvider = FutureProvider.family<NutritionSummary, DateTime>(
  (ref, date) async {
    final foodEntries = await ref.watch(foodEntriesByDateProvider(date).future);
    final profile = ref.watch(profileNotifierProvider);

    // Calculate actual intake
    double actualCalories = 0;
    double actualProtein = 0;
    double actualCarbs = 0;
    double actualFat = 0;

    for (final entry in foodEntries) {
      final nutrition = entry.calculatedNutrition;
      actualCalories += nutrition.calories;
      actualProtein += nutrition.protein;
      actualCarbs += nutrition.carbs;
      actualFat += nutrition.fat;
    }

    return NutritionSummary(
      date: date,
      actualCalories: actualCalories,
      actualProtein: actualProtein,
      actualCarbs: actualCarbs,
      actualFat: actualFat,
      goalCalories: profile?.calorieGoal ?? 2000,
      goalProtein: profile?.proteinGoal ?? 150,
      goalCarbs: profile?.carbGoal ?? 250,
      goalFat: profile?.fatGoal ?? 65,
    );
  },
);

/// Provider for time period summaries
final timePeriodSummariesProvider = FutureProvider<List<TimePeriodSummary>>(
  (ref) async {
    final now = DateTime.now();
    
    final periods = [
      _PeriodConfig('1 Day', 1),
      _PeriodConfig('1 Week', 7),
      _PeriodConfig('1 Month', 30),
      _PeriodConfig('1 Year', 365),
      _PeriodConfig('All Time', -1), // -1 means all available data
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
  final profile = ref.read(profileNotifierProvider);
  
  // Get all relevant dates
  final dates = <DateTime>[];
  if (period.days == -1) {
    // All time - get all dates with data
    // TODO: Implement getting all dates from database
    // For now, use last 365 days as approximation
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
    final summary = await ref.read(nutritionSummaryProvider(date).future);
    
    // Only count days with actual food entries
    if (summary.actualCalories > 0) {
      totalCaloriesDiff += summary.caloriesDifference;
      totalProteinDiff += summary.proteinDifference;
      totalCarbsDiff += summary.carbsDifference;
      totalFatDiff += summary.fatDifference;
      daysWithData++;
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
```

---

### STEP 3: Create Date Navigation Bar Widget

**Create file:** `lib/features/health/widgets/date_navigation_bar.dart`

**Full file content:**

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateNavigationBar extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const DateNavigationBar({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = _isToday(selectedDate);
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous day button
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              onDateChanged(selectedDate.subtract(const Duration(days: 1)));
            },
            tooltip: 'Previous day',
          ),

          const SizedBox(width: 8),

          // Date display with picker
          Expanded(
            child: InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  onDateChanged(picked);
                }
              },
              child: Column(
                children: [
                  Text(
                    dateFormat.format(selectedDate),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (isToday)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Today',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Next day button (disabled if today or future)
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _isToday(selectedDate) || _isFuture(selectedDate)
                ? null
                : () {
                    onDateChanged(selectedDate.add(const Duration(days: 1)));
                  },
            tooltip: 'Next day',
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isFuture(DateTime date) {
    final now = DateTime.now();
    return date.isAfter(now);
  }
}
```

---

### STEP 4: Create Goals vs Actual Table Widget

**Create file:** `lib/features/health/widgets/goals_vs_actual_table.dart`

**Full file content:**

```dart
import 'package:flutter/material.dart';
import 'package:miro/features/health/models/nutrition_summary.dart';

class GoalsVsActualTable extends StatelessWidget {
  final NutritionSummary summary;

  const GoalsVsActualTable({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Goals vs Actual',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Table
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1.5),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1.5),
              },
              border: TableBorder.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
              children: [
                // Header row
                TableRow(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                  ),
                  children: [
                    _buildHeaderCell('Nutrient'),
                    _buildHeaderCell('Goal'),
                    _buildHeaderCell('Actual'),
                    _buildHeaderCell('Diff'),
                  ],
                ),
                
                // Calories row
                _buildDataRow(
                  'Calories',
                  '${summary.goalCalories.toStringAsFixed(0)} kcal',
                  '${summary.actualCalories.toStringAsFixed(0)} kcal',
                  summary.caloriesDifference,
                  summary.isCaloriesOver,
                ),
                
                // Protein row
                _buildDataRow(
                  'Protein',
                  '${summary.goalProtein.toStringAsFixed(1)} g',
                  '${summary.actualProtein.toStringAsFixed(1)} g',
                  summary.proteinDifference,
                  summary.isProteinOver,
                ),
                
                // Carbs row
                _buildDataRow(
                  'Carbohydrates',
                  '${summary.goalCarbs.toStringAsFixed(1)} g',
                  '${summary.actualCarbs.toStringAsFixed(1)} g',
                  summary.carbsDifference,
                  summary.isCarbsOver,
                ),
                
                // Fat row
                _buildDataRow(
                  'Fat',
                  '${summary.goalFat.toStringAsFixed(1)} g',
                  '${summary.actualFat.toStringAsFixed(1)} g',
                  summary.fatDifference,
                  summary.isFatOver,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  TableRow _buildDataRow(
    String nutrient,
    String goal,
    String actual,
    double difference,
    bool isOver,
  ) {
    final diffText = difference >= 0 ? '+${difference.toStringAsFixed(0)}' : difference.toStringAsFixed(0);
    final diffColor = isOver ? Colors.red : Colors.green;

    return TableRow(
      children: [
        _buildDataCell(nutrient, fontWeight: FontWeight.w600),
        _buildDataCell(goal),
        _buildDataCell(actual),
        _buildDataCell(
          diffText,
          color: diffColor,
          fontWeight: FontWeight.bold,
        ),
      ],
    );
  }

  Widget _buildDataCell(
    String text, {
    Color? color,
    FontWeight? fontWeight,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: color,
          fontWeight: fontWeight,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
```

---

### STEP 5: Create Time Period Cards Widget

**Create file:** `lib/features/health/widgets/time_period_cards.dart`

**Full file content:**

```dart
import 'package:flutter/material.dart';
import 'package:miro/features/health/models/time_period_summary.dart';

class TimePeriodCards extends StatelessWidget {
  final List<TimePeriodSummary> summaries;

  const TimePeriodCards({
    super.key,
    required this.summaries,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Time Period Summaries',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        ...summaries.map((summary) => _buildPeriodCard(summary)),
      ],
    );
  }

  Widget _buildPeriodCard(TimePeriodSummary summary) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        title: Text(
          summary.label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${summary.days} days tracked',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSummaryRow(
                  'Calories',
                  summary.totalCaloriesDifference,
                  summary.averageCaloriesPerDay,
                  'kcal',
                  summary.isCaloriesSurplus,
                ),
                const Divider(),
                _buildSummaryRow(
                  'Protein',
                  summary.totalProteinDifference,
                  summary.averageProteinPerDay,
                  'g',
                  summary.isProteinSurplus,
                ),
                const Divider(),
                _buildSummaryRow(
                  'Carbs',
                  summary.totalCarbsDifference,
                  summary.averageCarbsPerDay,
                  'g',
                  summary.isCarbsSurplus,
                ),
                const Divider(),
                _buildSummaryRow(
                  'Fat',
                  summary.totalFatDifference,
                  summary.averageFatPerDay,
                  'g',
                  summary.isFatSurplus,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double totalDiff,
    double avgPerDay,
    String unit,
    bool isSurplus,
  ) {
    final color = isSurplus ? Colors.red : Colors.green;
    final icon = isSurplus ? Icons.arrow_upward : Icons.arrow_downward;
    final totalText = totalDiff >= 0 ? '+${totalDiff.toStringAsFixed(0)}' : totalDiff.toStringAsFixed(0);
    final avgText = avgPerDay >= 0 ? '+${avgPerDay.toStringAsFixed(1)}' : avgPerDay.toStringAsFixed(1);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Total: $totalText $unit',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Avg/day: $avgText $unit',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

### STEP 6: Create Main Dashboard Screen

**Create file:** `lib/features/health/presentation/today_summary_dashboard_screen.dart`

**Full file content:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro/core/theme/app_colors.dart';
import 'package:miro/features/health/providers/nutrition_summary_provider.dart';
import 'package:miro/features/health/widgets/date_navigation_bar.dart';
import 'package:miro/features/health/widgets/goals_vs_actual_table.dart';
import 'package:miro/features/health/widgets/time_period_cards.dart';
import 'package:miro/features/health/widgets/micronutrient_charts_section.dart';

class TodaySummaryDashboardScreen extends ConsumerStatefulWidget {
  const TodaySummaryDashboardScreen({super.key});

  @override
  ConsumerState<TodaySummaryDashboardScreen> createState() =>
      _TodaySummaryDashboardScreenState();
}

class _TodaySummaryDashboardScreenState
    extends ConsumerState<TodaySummaryDashboardScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(nutritionSummaryProvider(_selectedDate));
    final timePeriodSummariesAsync = ref.watch(timePeriodSummariesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(nutritionSummaryProvider);
          ref.invalidate(timePeriodSummariesProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Date Navigation
              DateNavigationBar(
                selectedDate: _selectedDate,
                onDateChanged: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              ),

              const SizedBox(height: 8),

              // Today's Summary
              summaryAsync.when(
                data: (summary) => GoalsVsActualTable(summary: summary),
                loading: () => const Card(
                  margin: EdgeInsets.all(16),
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (error, stack) => Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Error: ${error.toString()}'),
                  ),
                ),
              ),

              // Time Period Summaries
              timePeriodSummariesAsync.when(
                data: (summaries) => TimePeriodCards(summaries: summaries),
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error: ${error.toString()}'),
                ),
              ),

              // Micronutrient Charts (from Task #11)
              const MicronutrientChartsSection(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

### STEP 7: Add Dashboard Navigation

**File:** `lib/features/health/widgets/daily_summary_card.dart`

**At the top of the card, add a button to open dashboard:**

```dart
import 'package:miro/features/health/presentation/today_summary_dashboard_screen.dart';

// Inside the card, at the top:
Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(
      'Daily Summary',
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    ),
    TextButton.icon(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const TodaySummaryDashboardScreen(),
          ),
        );
      },
      icon: const Icon(Icons.bar_chart, size: 20),
      label: const Text('View Details'),
    ),
  ],
),
const SizedBox(height: 16),
```

---

### STEP 8: Add Intl Package for Date Formatting

**File:** `pubspec.yaml`

```yaml
dependencies:
  intl: ^0.18.1  # Add this for date formatting
```

**Run:**
```bash
flutter pub get
```

---

## Testing Checklist

- [ ] Dashboard opens from Daily Summary Card
- [ ] Date navigation works (previous/next day)
- [ ] Date picker opens and allows date selection
- [ ] "Today" badge shows only for current date
- [ ] Next button is disabled for today/future dates
- [ ] Goals vs Actual table displays correctly
- [ ] Difference column shows + for over, - for under
- [ ] Difference values have correct colors (red for over, green for under)
- [ ] Time period cards expand/collapse
- [ ] Each period shows total and average per day
- [ ] "1 Day" shows today's data
- [ ] "1 Week" shows last 7 days
- [ ] "1 Month" shows last 30 days
- [ ] "1 Year" shows last 365 days
- [ ] "All Time" shows all available data
- [ ] Micronutrient section appears (if data exists)
- [ ] Pull to refresh works
- [ ] No crashes when no data exists
- [ ] Layout works on small screens

---

## Troubleshooting

### Issue: Provider errors
**Solution:** Ensure all providers are properly imported and initialized.

### Issue: Date navigation doesn't update data
**Solution:** Check that `_selectedDate` state triggers provider refresh.

### Issue: Time period calculations wrong
**Solution:** Verify date range logic and ensure food entries are filtered correctly.

### Issue: Table layout breaks
**Solution:** Adjust `FlexColumnWidth` values in Goals vs Actual table.

### Issue: "All Time" takes too long to load
**Solution:** Limit "All Time" to last 365 days or add pagination.

---

## Performance Optimization

### For Large Datasets:

1. **Cache calculations:**
```dart
final cachedSummariesProvider = Provider((ref) {
  // Cache summaries to avoid recalculation
});
```

2. **Paginate time periods:**
- Only calculate visible periods
- Load more on demand

3. **Database indexes:**
- Index food entries by date
- Use efficient queries

---

## Completion Criteria

✅ Task is complete when:
- Dashboard screen displays correctly
- Date navigation works smoothly
- Goals vs Actual table shows accurate data
- Time period cards display and expand
- All 5 time periods calculate correctly
- Micronutrient section integrates (Task #11)
- Navigation from Daily Summary Card works
- Pull to refresh works
- No crashes or errors
- Tested with real data
- Performance is acceptable

---

## Estimated Time

- 2 hours: Data models and providers
- 2 hours: Date navigation and table widgets
- 2 hours: Time period cards
- 2 hours: Main dashboard screen
- 1 hour: Integration and navigation
- 1 hour: Testing and bug fixes

**Total: 8-12 hours**

---

## Notes

- This is the most complex feature in the project
- Break implementation into smaller sessions
- Test each component independently before integration
- Time period calculations can be optimized later
- Consider adding charts/graphs in future versions
- "All Time" should be limited for performance
