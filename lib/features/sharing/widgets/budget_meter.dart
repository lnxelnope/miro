import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';

class BudgetMeter extends StatelessWidget {
  final String label;
  final double current;
  final double goal;
  final String unit;
  final bool compact;

  const BudgetMeter({
    super.key,
    required this.label,
    required this.current,
    required this.goal,
    this.unit = 'kcal',
    this.compact = false,
  });

  double get _percent => goal > 0 ? (current / goal).clamp(0.0, 1.5) : 0;

  Color get _barColor {
    final pct = _percent * 100;
    if (pct <= 100) return AppColors.success;
    if (pct <= 120) return AppColors.warning;
    return const Color(0xFFF97316); // Orange — no red
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pctDisplay = goal > 0 ? (_percent * 100).toInt() : 0;

    if (compact) return _buildCompact(isDark, pctDisplay);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white54 : AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Text(
              '${_fmt(current)} / ${_fmt(goal)} $unit',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$pctDisplay%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _barColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _percent.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation(_barColor),
          ),
        ),
      ],
    );
  }

  Widget _buildCompact(bool isDark, int pctDisplay) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: _percent.clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation(_barColor),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '${_fmt(current)}/${_fmt(goal)}g',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white54 : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _fmt(double v) {
    if (v >= 10000) return '${(v / 1000).toStringAsFixed(1)}k';
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }
}

class BudgetMeterSection extends StatelessWidget {
  final double mealCalories;
  final double mealBudget;
  final double dailyCalories;
  final double dailyGoal;
  final double protein;
  final double proteinGoal;
  final double carbs;
  final double carbGoal;
  final double fat;
  final double fatGoal;
  final String mealLabel;

  const BudgetMeterSection({
    super.key,
    required this.mealCalories,
    required this.mealBudget,
    required this.dailyCalories,
    required this.dailyGoal,
    required this.protein,
    required this.proteinGoal,
    required this.carbs,
    required this.carbGoal,
    required this.fat,
    required this.fatGoal,
    required this.mealLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: AppRadius.md,
      ),
      child: Column(
        children: [
          BudgetMeter(
            label: mealLabel,
            current: mealCalories,
            goal: mealBudget,
          ),
          const SizedBox(height: AppSpacing.sm),
          BudgetMeter(
            label: 'Today',
            current: dailyCalories,
            goal: dailyGoal,
          ),
          const SizedBox(height: AppSpacing.sm),
          BudgetMeter(label: 'P', current: protein, goal: proteinGoal, unit: 'g', compact: true),
          const SizedBox(height: 3),
          BudgetMeter(label: 'C', current: carbs, goal: carbGoal, unit: 'g', compact: true),
          const SizedBox(height: 3),
          BudgetMeter(label: 'F', current: fat, goal: fatGoal, unit: 'g', compact: true),
        ],
      ),
    );
  }
}
