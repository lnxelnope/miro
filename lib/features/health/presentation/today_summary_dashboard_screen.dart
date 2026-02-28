import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/fda_daily_values.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../profile/models/user_profile.dart';
import '../../profile/providers/profile_provider.dart';
import '../models/micronutrient_stats.dart';
import '../providers/health_provider.dart';
import '../providers/micronutrient_stats_provider.dart';
import '../widgets/date_navigation_bar.dart';

enum SummaryPeriod { day, week, month, year, all }

// ── Range Key สำหรับ provider family ──
class _RangeKey {
  final DateTime date;
  final SummaryPeriod period;
  const _RangeKey(this.date, this.period);

  @override
  bool operator ==(Object other) =>
      other is _RangeKey &&
      other.date.year == date.year &&
      other.date.month == date.month &&
      other.date.day == date.day &&
      other.period == period;

  @override
  int get hashCode => Object.hash(date.year, date.month, date.day, period);
}

/// Provider รวม macros + fat breakdown สำหรับช่วงที่เลือก
final _rangeDataProvider = FutureProvider.autoDispose
    .family<Map<String, double>, _RangeKey>((ref, key) async {
  final range = _computeRange(key.date, key.period);
  double protein = 0, carbs = 0, fat = 0, calories = 0;
  double saturated = 0, mono = 0, poly = 0, trans = 0;

  final now = DateTime.now();
  final days = range.end.difference(range.start).inDays + 1;
  for (int i = 0; i < days; i++) {
    final date = range.start.add(Duration(days: i));
    if (date.isAfter(now)) break;
    final entries = await ref.read(foodEntriesByDateProvider(date).future);
    for (final e in entries) {
      protein += e.protein;
      carbs += e.carbs;
      fat += e.fat;
      calories += e.calories;
      saturated += e.saturatedFat ?? 0;
      mono += e.monounsaturatedFat ?? 0;
      poly += e.polyunsaturatedFat ?? 0;
      trans += e.transFat ?? 0;
    }
  }

  return {
    'protein': protein, 'carbs': carbs, 'fat': fat, 'calories': calories,
    'saturated': saturated, 'mono': mono, 'poly': poly, 'trans': trans,
  };
});

DateTimeRange _computeRange(DateTime base, SummaryPeriod period) {
  final d = DateTime(base.year, base.month, base.day);
  switch (period) {
    case SummaryPeriod.day:
      return DateTimeRange(start: d, end: d);
    case SummaryPeriod.week:
      final start = d.subtract(Duration(days: d.weekday - 1));
      return DateTimeRange(start: start, end: start.add(const Duration(days: 6)));
    case SummaryPeriod.month:
      return DateTimeRange(
        start: DateTime(base.year, base.month, 1),
        end: DateTime(base.year, base.month + 1, 0),
      );
    case SummaryPeriod.year:
      return DateTimeRange(
        start: DateTime(base.year, 1, 1),
        end: DateTime(base.year, 12, 31),
      );
    case SummaryPeriod.all:
      return DateTimeRange(start: DateTime(2020), end: DateTime.now());
  }
}

/// Top-level provider: calorie trend for last 7 days (lightweight)
final _calorieTrendProvider = FutureProvider.autoDispose<List<FlSpot>>((ref) async {
  final now = DateTime.now();
  final calorieData = <FlSpot>[];

  for (int i = 6; i >= 0; i--) {
    final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
    final entries = await ref.read(foodEntriesByDateProvider(date).future);
    final calories = entries.fold<double>(0, (sum, e) => sum + e.calories);
    calorieData.add(FlSpot((6 - i).toDouble(), calories));
  }

  return calorieData;
});

class TodaySummaryDashboardScreen extends ConsumerStatefulWidget {
  const TodaySummaryDashboardScreen({super.key});

  @override
  ConsumerState<TodaySummaryDashboardScreen> createState() =>
      _TodaySummaryDashboardScreenState();
}

class _TodaySummaryDashboardScreenState
    extends ConsumerState<TodaySummaryDashboardScreen> {
  DateTime _selectedDate = DateTime.now();
  SummaryPeriod _selectedPeriod = SummaryPeriod.day;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profileAsync = ref.watch(profileNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.of(context)!.nutritionSummary),
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
        foregroundColor:
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        elevation: 0,
      ),
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(foodEntriesByDateProvider);
          ref.invalidate(micronutrientStatsProvider);
          ref.invalidate(_calorieTrendProvider);
          ref.invalidate(activeEnergyProvider);
          ref.invalidate(effectiveCalorieGoalProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DateNavigationBar(
                selectedDate: _selectedDate,
                period: _selectedPeriod,
                onDateChanged: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
              ),

              SizedBox(height: AppSpacing.sm),

              _buildPeriodSelector(isDark),

              SizedBox(height: AppSpacing.lg),

              _buildMacroDistribution(isDark, profileAsync),

              SizedBox(height: AppSpacing.lg),

              _buildCalorieTrend(isDark),

              SizedBox(height: AppSpacing.lg),

              _buildMicronutrientTracker(isDark),

              SizedBox(height: AppSpacing.lg),

              _buildFatBreakdown(isDark),

              SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  // ── Period Selector (compact text) ──
  Widget _buildPeriodSelector(bool isDark) {
    final l10n = L10n.of(context)!;
    final labels = {
      SummaryPeriod.day: 'D',
      SummaryPeriod.week: 'W',
      SummaryPeriod.month: 'M',
      SummaryPeriod.year: 'Y',
      SummaryPeriod.all: l10n.periodAll,
    };

    return Padding(
      padding: AppSpacing.horizontalLg,
      child: Row(
        children: SummaryPeriod.values.map((period) {
          final selected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = period),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary
                      : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant),
                  borderRadius: period == SummaryPeriod.day
                      ? const BorderRadius.horizontal(left: Radius.circular(10))
                      : period == SummaryPeriod.all
                          ? const BorderRadius.horizontal(right: Radius.circular(10))
                          : null,
                ),
                child: Center(
                  child: Text(
                    labels[period]!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? Colors.white
                          : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Macro Distribution ──
  Widget _buildMacroDistribution(bool isDark, AsyncValue<UserProfile> profileAsync) {
    final l10n = L10n.of(context)!;
    return profileAsync.when(
      data: (profile) {
        final futureAsync = ref.watch(_rangeDataProvider(_RangeKey(_selectedDate, _selectedPeriod)));
        return futureAsync.when(
          data: (data) {
            double protein = data['protein']!;
            double carbs = data['carbs']!;
            double fat = data['fat']!;
            double calories = data['calories']!;

            final totalMacros = protein + carbs + fat;
            if (totalMacros == 0) {
              return _buildEmptyCard(isDark, l10n.macroDistribution);
            }

            final proteinPct = (protein / totalMacros * 100).toStringAsFixed(0);
            final carbsPct = (carbs / totalMacros * 100).toStringAsFixed(0);
            final fatPct = (fat / totalMacros * 100).toStringAsFixed(0);

            final calorieGoal = profile.calorieGoal.toDouble();
            final calPct = calorieGoal > 0 ? (calories / calorieGoal * 100) : 0.0;

            return Card(
              margin: AppSpacing.horizontalLg,
              color: isDark ? AppColors.surfaceDark : AppColors.surface,
              child: Padding(
                padding: AppSpacing.paddingLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.macroDistribution,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),

                    // Donut chart — smaller radius to avoid overflow
                    SizedBox(
                      height: 160,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 35,
                          sections: [
                            PieChartSectionData(
                              value: protein,
                              title: '$proteinPct%',
                              titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                              color: AppColors.protein,
                              radius: 40,
                            ),
                            PieChartSectionData(
                              value: carbs,
                              title: '$carbsPct%',
                              titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                              color: AppColors.carbs,
                              radius: 40,
                            ),
                            PieChartSectionData(
                              value: fat,
                              title: '$fatPct%',
                              titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                              color: AppColors.fat,
                              radius: 40,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: AppSpacing.md),

                    // Calorie summary
                    Center(
                      child: Text(
                        '${calories.toInt()} / ${calorieGoal.toInt()} kcal (${calPct.toStringAsFixed(0)}%)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: calPct <= 100 ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ),

                    SizedBox(height: AppSpacing.md),

                    // Macro bars
                    _buildMacroBar(l10n.protein, protein, profile.proteinGoal.toDouble(), AppColors.protein, isDark),
                    SizedBox(height: AppSpacing.sm),
                    _buildMacroBar(l10n.carbs, carbs, profile.carbGoal.toDouble(), AppColors.carbs, isDark),
                    SizedBox(height: AppSpacing.sm),
                    _buildMacroBar(l10n.fat, fat, profile.fatGoal.toDouble(), AppColors.fat, isDark),
                  ],
                ),
              ),
            );
          },
          loading: () => _buildLoadingCard(isDark),
          error: (e, s) => _buildErrorCard(isDark, e.toString()),
        );
      },
      loading: () => _buildLoadingCard(isDark),
      error: (e, s) => _buildErrorCard(isDark, e.toString()),
    );
  }

  Widget _buildMacroBar(String label, double actual, double goal, Color color, bool isDark) {
    final percent = goal > 0 ? (actual / goal).clamp(0.0, 1.0) : 0.0;
    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: AppRadius.sm,
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Text(
          '${actual.toStringAsFixed(0)}/${goal.toStringAsFixed(0)}g',
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // ── Calorie Trend (uses top-level provider) ──
  Widget _buildCalorieTrend(bool isDark) {
    final l10n = L10n.of(context)!;
    final calorieDataAsync = ref.watch(_calorieTrendProvider);
    final profileAsync = ref.watch(profileNotifierProvider);

    return calorieDataAsync.when(
      data: (calorieData) {
        final allZero = calorieData.every((s) => s.y == 0);
        if (calorieData.isEmpty || allZero) {
          return _buildEmptyCard(isDark, l10n.calorieTrend);
        }

        final maxVal = calorieData.map((e) => e.y).reduce((a, b) => a > b ? a : b);
        final maxY = maxVal > 0 ? maxVal * 1.3 : 2500.0;
        final goalLine = profileAsync.valueOrNull?.calorieGoal.toDouble() ?? 2000.0;

        final now = DateTime.now();
        final dateLabels = List.generate(7, (i) {
          final date = now.subtract(Duration(days: 6 - i));
          return DateFormat('E').format(date);
        });

        return Card(
          margin: AppSpacing.horizontalLg,
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          child: Padding(
            padding: AppSpacing.paddingLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.calorieTrend7Days,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: maxY / 4,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)
                              .withValues(alpha: 0.15),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final i = value.toInt();
                              if (i < 0 || i >= dateLabels.length) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  dateLabels[i],
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) => Text(
                              value.toInt().toString(),
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: 6,
                      minY: 0,
                      maxY: maxY,
                      lineBarsData: [
                        LineChartBarData(
                          spots: calorieData,
                          isCurved: true,
                          color: AppColors.info,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                              radius: 3,
                              color: AppColors.info,
                              strokeWidth: 0,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.info.withValues(alpha: 0.12),
                          ),
                        ),
                        LineChartBarData(
                          spots: [FlSpot(0, goalLine), FlSpot(6, goalLine)],
                          isCurved: false,
                          color: AppColors.error.withValues(alpha: 0.5),
                          barWidth: 1.5,
                          dashArray: [5, 5],
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _legendDot(AppColors.info, l10n.intakeLabel),
                    SizedBox(width: AppSpacing.lg),
                    _legendDot(AppColors.error, l10n.goal),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => _buildLoadingCard(isDark),
      error: (e, s) => _buildErrorCard(isDark, e.toString()),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: AppSpacing.xs),
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  // ── Micronutrient Tracker ──
  Widget _buildMicronutrientTracker(bool isDark) {
    final l10n = L10n.of(context)!;
    final statsAsync = ref.watch(micronutrientStatsProvider);
    return statsAsync.when(
      data: (stats) {
        if (!stats.hasAnyData) {
          return _buildEmptyCard(isDark, l10n.micronutrientTracker);
        }

        final micronutrients = [
          if (stats.fiber != null) stats.fiber!,
          if (stats.sugar != null) stats.sugar!,
          if (stats.sodium != null) stats.sodium!,
          if (stats.cholesterol != null) stats.cholesterol!,
          if (stats.saturatedFat != null) stats.saturatedFat!,
          if (stats.transFat != null) stats.transFat!,
          if (stats.potassium != null) stats.potassium!,
        ];

        return Card(
          margin: AppSpacing.horizontalLg,
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          child: Padding(
            padding: AppSpacing.paddingLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.micronutrientTracker,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: micronutrients.length,
                  itemBuilder: (context, index) {
                    return _buildMicronutrientCard(micronutrients[index], isDark);
                  },
                ),
              ],
            ),
          ),
        );
      },
      loading: () => _buildLoadingCard(isDark),
      error: (e, s) => _buildErrorCard(isDark, e.toString()),
    );
  }

  Widget _buildMicronutrientCard(MicronutrientStats stats, bool isDark) {
    final fdaValue = stats.fdaDailyValue ?? 0;
    final actual = stats.dailyAverage;
    final percent = fdaValue > 0 ? (actual / fdaValue) * 100 : 0;

    final isLimit = FdaDailyValues.limitNutrients.contains(stats.key);
    final isTarget = FdaDailyValues.targetNutrients.contains(stats.key);

    Color statusColor;
    String statusText;

    final l10n = L10n.of(context)!;
    if (isLimit) {
      if (actual <= fdaValue) {
        statusColor = AppColors.success;
        statusText = '${percent.toStringAsFixed(0)}%';
      } else {
        statusColor = AppColors.error;
        statusText = l10n.over;
      }
    } else if (isTarget) {
      if (actual >= fdaValue) {
        statusColor = AppColors.success;
        statusText = '${percent.toStringAsFixed(0)}%';
      } else if (percent < 50) {
        statusColor = AppColors.error;
        statusText = '${percent.toStringAsFixed(0)}%';
      } else {
        statusColor = AppColors.warning;
        statusText = '${percent.toStringAsFixed(0)}%';
      }
    } else {
      statusColor = AppColors.textSecondary;
      statusText = '${percent.toStringAsFixed(0)}%';
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
        borderRadius: AppRadius.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(_getMicronutrientIcon(stats.key), size: 16, color: statusColor),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  stats.name,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            '${actual.toStringAsFixed(0)}${stats.unit} / ${fdaValue.toStringAsFixed(0)}${stats.unit}',
            style: TextStyle(fontSize: 10,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
          ),
          ClipRRect(
            borderRadius: AppRadius.sm,
            child: LinearProgressIndicator(
              value: fdaValue > 0 ? (actual / fdaValue).clamp(0.0, 1.0) : 0,
              backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 5,
            ),
          ),
          Text(
            statusText,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor),
          ),
        ],
      ),
    );
  }

  // ── Fat Breakdown ──
  Widget _buildFatBreakdown(bool isDark) {
    final l10n = L10n.of(context)!;
    final rangeAsync = ref.watch(_rangeDataProvider(_RangeKey(_selectedDate, _selectedPeriod)));
    return rangeAsync.when(
      data: (data) {
        double saturated = data['saturated']!;
        double mono = data['mono']!;
        double poly = data['poly']!;
        double trans = data['trans']!;

        final maxFat = [saturated, mono, poly, trans].reduce((a, b) => a > b ? a : b);
        if (maxFat == 0) return _buildEmptyCard(isDark, l10n.fatBreakdown);

        return Card(
          margin: AppSpacing.horizontalLg,
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          child: Padding(
            padding: AppSpacing.paddingLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.fatBreakdown,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                ),
                SizedBox(height: AppSpacing.lg),
                _buildFatBar(l10n.saturated, saturated, maxFat, AppColors.warning, isDark),
                SizedBox(height: AppSpacing.sm),
                _buildFatBar(l10n.mono, mono, maxFat, AppColors.info, isDark),
                SizedBox(height: AppSpacing.sm),
                _buildFatBar(l10n.poly, poly, maxFat, AppColors.primary, isDark),
                SizedBox(height: AppSpacing.sm),
                _buildFatBar(l10n.trans, trans, maxFat, AppColors.error, isDark),
              ],
            ),
          ),
        );
      },
      loading: () => _buildLoadingCard(isDark),
      error: (e, s) => _buildErrorCard(isDark, e.toString()),
    );
  }

  Widget _buildFatBar(String label, double value, double maxValue, Color color, bool isDark) {
    final percent = maxValue > 0 ? (value / maxValue).clamp(0.0, 1.0) : 0.0;
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: AppRadius.sm,
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 16,
            ),
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 42,
          child: Text('${value.toStringAsFixed(1)}g',
            textAlign: TextAlign.end,
            style: TextStyle(fontSize: 11,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
        ),
      ],
    );
  }

  IconData _getMicronutrientIcon(String key) {
    switch (key) {
      case 'fiber': return Icons.grass_rounded;
      case 'sugar': return Icons.cake_rounded;
      case 'sodium': return Icons.water_drop_rounded;
      case 'cholesterol': return Icons.favorite_rounded;
      case 'saturatedFat': return Icons.opacity_rounded;
      case 'transFat': return Icons.block_rounded;
      case 'potassium': return Icons.eco_rounded;
      default: return Icons.info;
    }
  }

  Widget _buildEmptyCard(bool isDark, String title) {
    final l10n = L10n.of(context)!;
    return Card(
      margin: AppSpacing.horizontalLg,
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Center(
          child: Text(l10n.noDataFor(title),
            style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
        ),
      ),
    );
  }

  Widget _buildLoadingCard(bool isDark) {
    return Card(
      margin: AppSpacing.horizontalLg,
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      child: const Padding(
        padding: AppSpacing.paddingXl,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildErrorCard(bool isDark, String error) {
    final l10n = L10n.of(context)!;
    return Card(
      margin: AppSpacing.horizontalLg,
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Text(l10n.errorColon(error), style: const TextStyle(color: AppColors.error)),
      ),
    );
  }
}
