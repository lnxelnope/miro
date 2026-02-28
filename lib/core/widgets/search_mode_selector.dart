import 'package:flutter/material.dart';
import '../constants/enums.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// Compact toggle pills for selecting Food vs Product search mode.
/// Place on analysis screens before the "Analyze with AI" button.
class SearchModeSelector extends StatelessWidget {
  final FoodSearchMode selectedMode;
  final ValueChanged<FoodSearchMode> onChanged;

  const SearchModeSelector({
    super.key,
    required this.selectedMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        _buildPill(
          context,
          mode: FoodSearchMode.normal,
          isSelected: selectedMode == FoodSearchMode.normal,
          isDark: isDark,
        ),
        const SizedBox(width: AppSpacing.sm),
        _buildPill(
          context,
          mode: FoodSearchMode.product,
          isSelected: selectedMode == FoodSearchMode.product,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildPill(
    BuildContext context, {
    required FoodSearchMode mode,
    required bool isSelected,
    required bool isDark,
  }) {
    final bgColor = isSelected
        ? (mode == FoodSearchMode.normal ? AppColors.primary : AppColors.health)
        : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant);

    final textColor = isSelected
        ? Colors.white
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary);

    return GestureDetector(
      onTap: () => onChanged(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md + 2, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadius.xl,
          border: isSelected
              ? null
              : Border.all(
                  color: isDark ? AppColors.dividerDark : AppColors.divider,
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
              Icon(mode.icon, size: 18, color: isSelected ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
            const SizedBox(width: AppSpacing.xs + 2),
            Text(
              mode.displayName,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
