import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${meal.baseServingDescription} · Used ${meal.usageCount} times',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  // Source badge (non-interactive)
                  IgnorePointer(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: meal.source == 'gemini'
                            ? Colors.purple.withOpacity(0.1)
                            : AppColors.textTertiary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        meal.source == 'gemini' ? '✨ AI' : '✏️ Manual',
                        style: TextStyle(
                          fontSize: 10,
                          color: meal.source == 'gemini' ? Colors.purple : AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Nutrition row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.health.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _nutritionItem('🔥', '${meal.totalCalories.toInt()}', 'kcal', AppColors.health),
                    _divider(),
                    _nutritionItem('🥩', '${meal.totalProtein.toInt()}g', 'P', AppColors.protein),
                    _divider(),
                    _nutritionItem('🍞', '${meal.totalCarbs.toInt()}g', 'C', AppColors.carbs),
                    _divider(),
                    _nutritionItem('🫒', '${meal.totalFat.toInt()}g', 'F', AppColors.fat),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onUse,
                      icon: const Icon(Icons.restaurant, size: 16),
                      label: const Text('Use This Meal', style: TextStyle(fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.health,
                        side: BorderSide(color: AppColors.health.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    color: AppColors.textSecondary,
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: AppColors.error,
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nutritionItem(String emoji, String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 24, color: AppColors.textTertiary.withOpacity(0.3));
  }
}
