import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/fulfill_calorie_provider.dart';

int _safe(double v) => (v.isNaN || v.isInfinite) ? 0 : v.toInt();

/// Ghost suggestion shown inside an empty MealSection.
/// Displays a faded food recommendation with calories & macros overlay.
class GhostMealSuggestion extends StatelessWidget {
  final MealSlotSuggestion suggestion;
  final VoidCallback onTap;
  final void Function(FoodSuggestion suggestion)? onSuggestionTap;

  const GhostMealSuggestion({
    super.key,
    required this.suggestion,
    required this.onTap,
    this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    // Daily kcal exceeded → don't suggest anything
    if (suggestion.dailyExceeded) {
      return _buildDailyExceeded(context);
    }

    if (!suggestion.hasData) {
      return _buildLearningState(context);
    }

    final top = suggestion.topSuggestion;
    if (top == null) {
      return _buildBudgetOnly(context);
    }

    return Column(
      children: [
        _buildSuggestionCard(context, top),
        for (final alt in suggestion.alternatives)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: _buildAlternativeCard(context, alt),
          ),
      ],
    );
  }

  /// Daily kcal exceeded → show gentle "done for the day" state
  Widget _buildDailyExceeded(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.green).withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isDark ? Colors.white24 : Colors.green).withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.green.withOpacity(0.5),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily goal reached',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: (isDark ? Colors.white : Colors.green.shade700)
                        .withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'No more calories recommended',
                  style: TextStyle(
                    fontSize: 11,
                    color: (isDark ? Colors.white : AppColors.textSecondary)
                        .withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// When user has no food data yet - show "learning" state
  Widget _buildLearningState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : AppColors.primary).withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (isDark ? Colors.white24 : AppColors.primary).withOpacity(0.12),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.primary.withOpacity(0.4),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '~${_safe(suggestion.allocatedCalories)} kcal budget',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: (isDark ? Colors.white : AppColors.textPrimary)
                          .withOpacity(0.45),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Start logging to get personal suggestions',
                    style: TextStyle(
                      fontSize: 11,
                      color: (isDark ? Colors.white : AppColors.textSecondary)
                          .withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.add_circle_outline_rounded,
              size: 20,
              color: AppColors.primary.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  /// When we have data but no food fits the budget
  Widget _buildBudgetOnly(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cals = suggestion.allocatedCalories;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : AppColors.health).withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (isDark ? Colors.white24 : AppColors.health).withOpacity(0.12),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.health.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.local_fire_department_rounded,
                color: AppColors.health.withOpacity(0.4),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '~${_safe(cals)} kcal remaining',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: (isDark ? Colors.white : AppColors.textPrimary)
                          .withOpacity(0.45),
                    ),
                  ),
                  const SizedBox(height: 2),
                  _buildMacroRow(context, opacity: 0.35),
                ],
              ),
            ),
            Icon(
              Icons.add_circle_outline_rounded,
              size: 20,
              color: AppColors.primary.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  /// Main suggestion card with food name, calories, and macros
  Widget _buildSuggestionCard(BuildContext context, FoodSuggestion food) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseOpacity = 0.45;

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
          color: (isDark ? Colors.white : AppColors.primary).withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (isDark ? Colors.white24 : AppColors.primary).withOpacity(0.10),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Main suggestion row
            Row(
              children: [
                // Food icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.health.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    food.isMeal ? Icons.restaurant_menu : Icons.egg_alt_rounded,
                    color: (food.isMeal ? AppColors.health : Colors.orange)
                        .withOpacity(baseOpacity),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                // Food info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        food.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: (isDark ? Colors.white : AppColors.textPrimary)
                              .withOpacity(baseOpacity),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          _macroChip('P', food.protein, AppColors.protein, baseOpacity),
                          const SizedBox(width: 6),
                          _macroChip('C', food.carbs, AppColors.carbs, baseOpacity),
                          const SizedBox(width: 6),
                          _macroChip('F', food.fat, AppColors.fat, baseOpacity),
                        ],
                      ),
                    ],
                  ),
                ),
                // Calories
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_safe(food.calories)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: (isDark ? Colors.white : AppColors.textPrimary)
                            .withOpacity(baseOpacity),
                      ),
                    ),
                    Text(
                      'kcal',
                      style: TextStyle(
                        fontSize: 10,
                        color: (isDark ? Colors.white : AppColors.textSecondary)
                            .withOpacity(baseOpacity * 0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Budget remaining hint
            const SizedBox(height: 6),
            Row(
              children: [
                const SizedBox(width: 52),
                Icon(
                  suggestion.cappedByDaily
                      ? Icons.trending_down_rounded
                      : Icons.local_fire_department_rounded,
                  size: 11,
                  color: (isDark ? Colors.white : AppColors.health)
                      .withOpacity(0.3),
                ),
                const SizedBox(width: 3),
                Text(
                  suggestion.cappedByDaily
                      ? 'Daily remaining ~${_safe(suggestion.allocatedCalories)} kcal'
                      : 'Budget ~${_safe(suggestion.allocatedCalories)} kcal',
                  style: TextStyle(
                    fontSize: 10,
                    color: (isDark
                            ? Colors.white
                            : suggestion.cappedByDaily
                                ? Colors.orange.shade700
                                : AppColors.textSecondary)
                        .withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Compact alternative suggestion card (tappable with prefill)
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
          color: (isDark ? Colors.white : AppColors.primary).withOpacity(0.02),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: (isDark ? Colors.white24 : AppColors.primary).withOpacity(0.06),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              food.isMeal ? Icons.restaurant_menu : Icons.egg_alt_rounded,
              size: 15,
              color: (food.isMeal ? AppColors.health : Colors.orange)
                  .withOpacity(opacity),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                food.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: (isDark ? Colors.white : AppColors.textPrimary)
                      .withOpacity(opacity),
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
                    .withOpacity(opacity),
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
            color: color.withOpacity(opacity),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          '$label ${_safe(value)}g',
          style: TextStyle(
            fontSize: 10,
            color: color.withOpacity(opacity),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroRow(BuildContext context, {required double opacity}) {
    return Row(
      children: [
        _macroChip('P', suggestion.allocatedProtein, AppColors.protein, opacity),
        const SizedBox(width: 6),
        _macroChip('C', suggestion.allocatedCarbs, AppColors.carbs, opacity),
        const SizedBox(width: 6),
        _macroChip('F', suggestion.allocatedFat, AppColors.fat, opacity),
      ],
    );
  }
}
