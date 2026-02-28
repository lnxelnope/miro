import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../health/providers/fulfill_calorie_provider.dart';

int _safe(double v) => (v.isNaN || v.isInfinite) ? 0 : v.toInt();

/// Simplified meal suggestion widget for Basic Mode.
/// Shows ghost-style suggestions for remaining daily calories.
class BasicMealSuggestion extends StatelessWidget {
  final FulfillCalorieState fulfillState;
  final VoidCallback onTap;
  final void Function(FoodSuggestion suggestion)? onSuggestionTap;

  const BasicMealSuggestion({
    super.key,
    required this.fulfillState,
    required this.onTap,
    this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = fulfillState.remainingCalories;

    if (remaining <= minSuggestionRemainingKcal) {
      return _buildDailyGoalReached(context);
    }

    // Collect all suggestions from empty meal slots
    final allSuggestions = <FoodSuggestion>[];
    for (final slot in fulfillState.suggestions.values) {
      if (slot.dailyExceeded) continue;
      if (slot.topSuggestion != null) {
        allSuggestions.add(slot.topSuggestion!);
      }
      allSuggestions.addAll(slot.alternatives);
    }

    // Deduplicate and sort by proximity to remaining calories
    final seen = <String>{};
    final unique = <FoodSuggestion>[];
    for (final s in allSuggestions) {
      final key = '${s.name}_${s.calories}';
      if (seen.add(key)) unique.add(s);
    }
    unique.sort((a, b) {
      final diffA = (a.calories - remaining).abs();
      final diffB = (b.calories - remaining).abs();
      return diffA.compareTo(diffB);
    });

    // Take top 3 (1 main + 2 alternatives)
    final top = unique.isNotEmpty ? unique.first : null;
    final alts = unique.length > 1 ? unique.sublist(1, unique.length.clamp(0, 3)) : <FoodSuggestion>[];

    if (!fulfillState.hasAnyFoodData) {
      return _buildNoDataState(context, remaining);
    }

    if (top == null) {
      return _buildRemainingOnly(context, remaining);
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSuggestionCard(context, top, remaining),
          for (final alt in alts)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: _buildAlternativeCard(context, alt),
            ),
        ],
      ),
    );
  }

  Widget _buildDailyGoalReached(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : AppColors.success)
            .withValues(alpha: 0.04),
        borderRadius: AppRadius.md,
        border: Border.all(
          color: (isDark ? Colors.white24 : AppColors.success)
              .withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.08),
              borderRadius: AppRadius.md,
            ),
            child: Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.success.withValues(alpha: 0.5),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Daily goal reached ✓',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: (isDark ? Colors.white : AppColors.success)
                    .withValues(alpha: 0.55),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState(BuildContext context, double remaining) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : AppColors.primary)
              .withValues(alpha: 0.03),
          borderRadius: AppRadius.md,
          border: Border.all(
            color: (isDark ? Colors.white24 : AppColors.primary)
                .withValues(alpha: 0.10),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: AppRadius.md,
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.primary.withValues(alpha: 0.4),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '~${_safe(remaining)} kcal remaining',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: (isDark ? Colors.white : AppColors.textPrimary)
                          .withValues(alpha: 0.45),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Log meals to get suggestions',
                    style: TextStyle(
                      fontSize: 11,
                      color: (isDark ? Colors.white : AppColors.textSecondary)
                          .withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.add_circle_outline_rounded,
              size: 18,
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemainingOnly(BuildContext context, double remaining) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : AppColors.health)
              .withValues(alpha: 0.04),
          borderRadius: AppRadius.md,
          border: Border.all(
            color: (isDark ? Colors.white24 : AppColors.health)
                .withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.health.withValues(alpha: 0.08),
                borderRadius: AppRadius.md,
              ),
              child: Icon(
                Icons.local_fire_department_rounded,
                color: AppColors.health.withValues(alpha: 0.4),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '~${_safe(remaining)} kcal remaining',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: (isDark ? Colors.white : AppColors.textPrimary)
                      .withValues(alpha: 0.45),
                ),
              ),
            ),
            Icon(
              Icons.add_circle_outline_rounded,
              size: 18,
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(
      BuildContext context, FoodSuggestion food, double remaining) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const baseOpacity = 0.45;

    return GestureDetector(
      onTap: () {
        if (onSuggestionTap != null) {
          onSuggestionTap!(food);
        } else {
          onTap();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : AppColors.primary)
              .withValues(alpha: 0.03),
          borderRadius: AppRadius.md,
          border: Border.all(
            color: (isDark ? Colors.white24 : AppColors.primary)
                .withValues(alpha: 0.10),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.health.withValues(alpha: 0.06),
                    borderRadius: AppRadius.md,
                  ),
                  child: Icon(
                    food.isMeal
                        ? Icons.restaurant_menu
                        : Icons.egg_alt_rounded,
                    color: (food.isMeal ? AppColors.health : AppColors.warning)
                        .withValues(alpha: baseOpacity),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color:
                              (isDark ? Colors.white : AppColors.textPrimary)
                                  .withValues(alpha: baseOpacity),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          _macroChip(
                              'P', food.protein, AppColors.protein, baseOpacity),
                          const SizedBox(width: 6),
                          _macroChip(
                              'C', food.carbs, AppColors.carbs, baseOpacity),
                          const SizedBox(width: 6),
                          _macroChip(
                              'F', food.fat, AppColors.fat, baseOpacity),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_safe(food.calories)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color:
                            (isDark ? Colors.white : AppColors.textPrimary)
                                .withValues(alpha: baseOpacity),
                      ),
                    ),
                    Text(
                      'kcal',
                      style: TextStyle(
                        fontSize: 10,
                        color:
                            (isDark ? Colors.white : AppColors.textSecondary)
                                .withValues(alpha: baseOpacity * 0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const SizedBox(width: 48),
                Icon(
                  Icons.local_fire_department_rounded,
                  size: 11,
                  color: (isDark ? Colors.white : AppColors.health)
                      .withValues(alpha: 0.3),
                ),
                const SizedBox(width: 3),
                Text(
                  '~${_safe(remaining)} kcal remaining today',
                  style: TextStyle(
                    fontSize: 10,
                    color: (isDark ? Colors.white : AppColors.textSecondary)
                        .withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlternativeCard(BuildContext context, FoodSuggestion food) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const opacity = 0.35;

    return GestureDetector(
      onTap: () {
        if (onSuggestionTap != null) {
          onSuggestionTap!(food);
        } else {
          onTap();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : AppColors.primary)
              .withValues(alpha: 0.02),
          borderRadius: AppRadius.md,
          border: Border.all(
            color: (isDark ? Colors.white24 : AppColors.primary)
                .withValues(alpha: 0.06),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              food.isMeal ? Icons.restaurant_menu : Icons.egg_alt_rounded,
              size: 14,
              color: (food.isMeal ? AppColors.health : AppColors.warning)
                  .withValues(alpha: opacity),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                food.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: (isDark ? Colors.white : AppColors.textPrimary)
                      .withValues(alpha: opacity),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${_safe(food.calories)} kcal',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: (isDark ? Colors.white : AppColors.textPrimary)
                    .withValues(alpha: opacity),
              ),
            ),
            const SizedBox(width: 6),
            _macroChip('P', food.protein, AppColors.protein, opacity),
            const SizedBox(width: 4),
            _macroChip('C', food.carbs, AppColors.carbs, opacity),
            const SizedBox(width: 4),
            _macroChip('F', food.fat, AppColors.fat, opacity),
          ],
        ),
      ),
    );
  }

  Widget _macroChip(String label, double value, Color color, double opacity) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: color.withValues(alpha: opacity),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          '$label ${_safe(value)}g',
          style: TextStyle(
            fontSize: 10,
            color: color.withValues(alpha: opacity),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
