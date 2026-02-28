import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/constants/enums.dart';
import '../models/food_entry.dart';

class FoodTimelineCard extends StatelessWidget {
  final FoodEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onAnalyze;
  final VoidCallback? onDelete;

  const FoodTimelineCard({
    super.key,
    required this.entry,
    this.onTap,
    this.onEdit,
    this.onAnalyze,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.md,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image or Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.health.withValues(alpha: 0.1),
                  borderRadius: AppRadius.sm,
                ),
                child: entry.imagePath != null &&
                        File(entry.imagePath!).existsSync()
                    ? ClipRRect(
                        borderRadius: AppRadius.sm,
                        child: Image.file(
                          File(entry.imagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
                        ),
                      )
                    : _buildPlaceholderIcon(),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          entry.mealType.icon,
                          size: 16,
                          color: entry.mealType.iconColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            entry.foodName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(child: _buildCalorieBadge()),
                        const SizedBox(width: 6),
                        // Verified badge
                        if (entry.isVerified)
                          const Padding(
                            padding: EdgeInsets.only(right: 4),
                            child: Icon(Icons.verified,
                                size: 16, color: AppColors.success),
                          ),
                        // ปุ่มวิเคราะห์ด้วย AI
                        if (onAnalyze != null)
                          GestureDetector(
                            onTap: onAnalyze,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: AppRadius.sm,
                              ),
                              child: const Icon(
                                Icons.auto_awesome,
                                size: 18,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        if (onAnalyze != null) const SizedBox(width: 4),
                        if (onEdit != null)
                          GestureDetector(
                            onTap: onEdit,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.edit,
                                size: 20,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        if (onDelete != null) ...[
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: onDelete,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    _buildMacros(isDark),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatTime(entry.timestamp)} • ${entry.mealType.displayName}',
                      style: TextStyle(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return const Center(
      child: Icon(
        Icons.restaurant,
        color: AppColors.health,
        size: 28,
      ),
    );
  }

  Widget _buildCalorieBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.health.withValues(alpha: 0.1),
        borderRadius: AppRadius.md,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(AppIcons.calories, size: 14, color: AppIcons.caloriesColor),
          const SizedBox(width: 2),
          Text(
            '${entry.calories.toInt()} kcal',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.health,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacros(bool isDark) {
    return Row(
      children: [
        _buildMacroChip('P', entry.protein, AppColors.protein, isDark),
        const SizedBox(width: 8),
        _buildMacroChip('C', entry.carbs, AppColors.carbs, isDark),
        const SizedBox(width: 8),
        _buildMacroChip('F', entry.fat, AppColors.fat, isDark),
      ],
    );
  }

  Widget _buildMacroChip(String label, double value, Color color, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
        Text(
          '${value.toInt()}g',
          style: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
