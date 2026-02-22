import 'package:flutter/material.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../models/my_meal.dart';

class MyMealCard extends StatelessWidget {
  final MyMeal meal;
  final VoidCallback onUse;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const MyMealCard({
    super.key,
    required this.meal,
    required this.onUse,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAi = meal.source == 'gemini';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.lg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.lg,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    // Meal icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.health.withValues(alpha: 0.1),
                        borderRadius: AppRadius.md,
                      ),
                      child: Center(
                        child: Icon(AppIcons.meal, size: 24, color: AppIcons.mealColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Name & meta
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meal.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${meal.baseServingDescription} · ${meal.usageCount} uses',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    // Source badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAi
                            ? AppColors.premium.withValues(alpha: 0.1)
                            : AppColors.background,
                        borderRadius: AppRadius.sm,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isAi ? AppIcons.aiAnalyzed : AppIcons.edit,
                            size: 12,
                            color: isAi
                                ? AppIcons.aiAnalyzedColor
                                : AppIcons.editColor,
                          ),
                          const SizedBox(width: 2),
                          if (isAi)
                            Text(
                              'AI',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppIcons.aiAnalyzedColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Nutrition pills
                Row(
                  children: [
                    _nutritionPill('${meal.totalCalories.toInt()}', 'kcal',
                        AppColors.error),
                    const SizedBox(width: 8),
                    _nutritionPill('${meal.totalProtein.toInt()}g', 'P',
                        AppColors.info),
                    const SizedBox(width: 8),
                    _nutritionPill('${meal.totalCarbs.toInt()}g', 'C',
                        AppColors.warning),
                    const SizedBox(width: 8),
                    _nutritionPill('${meal.totalFat.toInt()}g', 'F',
                        AppColors.finance),
                  ],
                ),
                const SizedBox(height: 14),

                // Actions row
                Row(
                  children: [
                    // Use meal button (primary)
                    Expanded(
                      child: GestureDetector(
                        onTap: onUse,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.health.withValues(alpha: 0.1),
                            borderRadius: AppRadius.md,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_rounded,
                                  size: 18, color: AppColors.health),
                              SizedBox(width: 6),
                              Text(
                                'Log This Meal',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.health,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Edit
                    _actionIcon(
                        Icons.edit_outlined, AppColors.textTertiary, onEdit),
                    const SizedBox(width: 4),
                    // Delete
                    _actionIcon(Icons.delete_outline_rounded,
                        AppColors.error.withValues(alpha: 0.5), onDelete),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _nutritionPill(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: AppRadius.md,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.7)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionIcon(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: AppRadius.md,
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
