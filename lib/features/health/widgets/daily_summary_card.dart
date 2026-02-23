import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../providers/health_provider.dart';
import '../../profile/providers/profile_provider.dart';

class DailySummaryCard extends ConsumerWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onDateChanged;

  const DailySummaryCard({super.key, this.selectedDate, this.onDateChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = selectedDate ?? dateOnly(DateTime.now());
    final isToday = _isToday(date);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final foodsAsync = ref.watch(foodEntriesByDateProvider(date));
    final profileAsync = ref.watch(profileNotifierProvider);

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.surfaceVariantDark,
                  AppColors.surfaceDark,
                ]
              : [
                  AppColors.health.withValues(alpha: 0.05),
                  AppColors.health.withValues(alpha: 0.10),
                ],
        ),
        borderRadius: AppRadius.md,
        border: Border.all(
          color: isDark
              ? AppColors.health.withValues(alpha: 0.35)
              : AppColors.health.withValues(alpha: 0.18),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.health.withValues(alpha: isDark ? 0.10 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: profileAsync.when(
        loading: () => const SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        error: (_, __) => const SizedBox(),
        data: (profile) => foodsAsync.when(
          loading: () => const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (_, __) => const Text('Error'),
          data: (entries) {
            final calories =
                entries.fold<double>(0, (sum, e) => sum + e.calories);
            final protein =
                entries.fold<double>(0, (sum, e) => sum + e.protein);
            final carbs = entries.fold<double>(0, (sum, e) => sum + e.carbs);
            final fat = entries.fold<double>(0, (sum, e) => sum + e.fat);

            final goal = profile.calorieGoal;
            final percent = goal > 0 ? (calories / goal).clamp(0.0, 1.0) : 0.0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date navigation row
                Row(
                  children: [
                    // Left arrow
                    if (onDateChanged != null)
                      _navArrow(
                        icon: Icons.chevron_left_rounded,
                        onTap: () => onDateChanged!(
                            date.subtract(const Duration(days: 1))),
                        isDark: isDark,
                      ),
                    if (onDateChanged != null)
                      const SizedBox(width: AppSpacing.xs),

                    // Date text (tap = date picker)
                    Expanded(
                      child: GestureDetector(
                        onTap: onDateChanged != null
                            ? () => _pickDate(context, date)
                            : null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              isToday
                                  ? 'Today'
                                  : DateFormat('d MMM yyyy', 'en').format(date),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              DateFormat('EEEE', 'en').format(date),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Right arrow (disabled if today)
                    if (onDateChanged != null)
                      _navArrow(
                        icon: Icons.chevron_right_rounded,
                        onTap: isToday
                            ? null
                            : () => onDateChanged!(
                                date.add(const Duration(days: 1))),
                        isDark: isDark,
                        disabled: isToday,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Main content: Macros left + Circular right
                Row(
                  children: [
                    // Left: Macro progress bars
                    Expanded(
                      child: Column(
                        children: [
                          _buildMacroBar(
                            label: 'P',
                            value: protein,
                            goal: profile.proteinGoal,
                            color: AppColors.protein,
                            isDark: isDark,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _buildMacroBar(
                            label: 'C',
                            value: carbs,
                            goal: profile.carbGoal,
                            color: AppColors.carbs,
                            isDark: isDark,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _buildMacroBar(
                            label: 'F',
                            value: fat,
                            goal: profile.fatGoal,
                            color: AppColors.fat,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),

                    // Right: Circular kcal
                    SizedBox(
                      width: 76,
                      height: 76,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 76,
                            height: 76,
                            child: CircularProgressIndicator(
                              value: percent,
                              strokeWidth: 6,
                              strokeCap: StrokeCap.round,
                              backgroundColor: isDark
                                  ? AppColors.surfaceVariantDark
                                  : AppColors.divider,
                              valueColor: AlwaysStoppedAnimation(
                                percent >= 1.0
                                    ? AppColors.error
                                    : AppColors.health,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${calories.toInt()}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 17,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '/${goal.toInt()}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                'kcal',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _navArrow({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isDark,
    bool disabled = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: disabled
              ? Colors.transparent
              : (isDark 
                  ? AppColors.health.withValues(alpha: 0.15)
                  : AppColors.health.withValues(alpha: 0.10)),
          borderRadius: AppRadius.sm,
        ),
        child: Icon(
          icon,
          size: 20,
          color: disabled
              ? (isDark ? AppColors.dividerDark : AppColors.divider)
              : (isDark ? AppColors.health.withValues(alpha: 0.9) : AppColors.health),
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, DateTime current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      onDateChanged?.call(picked);
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Widget _buildMacroBar({
    required String label,
    required double value,
    required double goal,
    required Color color,
    required bool isDark,
  }) {
    final progress = goal > 0 ? (value / goal).clamp(0.0, 1.0) : 0.0;

    return Row(
      children: [
        SizedBox(
          width: 14,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor:
                  isDark ? AppColors.surfaceVariantDark : AppColors.divider,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 58,
          child: Text(
            '${value.toInt()}/${goal.toInt()}g',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark.withValues(alpha: 0.85) : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
