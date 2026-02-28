import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

class AppChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool compact;

  const AppChip({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.isSelected = false,
    this.onTap,
    this.onDelete,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = color ?? AppColors.primary;

    final bgColor = isSelected
        ? accentColor.withValues(alpha: 0.15)
        : isDark
            ? AppColors.surfaceVariantDark
            : AppColors.surfaceVariant;

    final fgColor = isSelected
        ? accentColor
        : isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondary;

    final borderClr = isSelected
        ? accentColor.withValues(alpha: 0.3)
        : isDark
            ? AppColors.dividerDark
            : AppColors.divider;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.pill,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? AppSpacing.sm : AppSpacing.md,
            vertical: compact ? AppSpacing.xs : AppSpacing.sm - 2,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppRadius.pill,
            border: Border.all(color: borderClr),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: compact ? 14 : 16, color: fgColor),
                SizedBox(width: compact ? 3 : AppSpacing.xs),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: compact ? 11 : 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: fgColor,
                ),
              ),
              if (onDelete != null) ...[
                SizedBox(width: compact ? 3 : AppSpacing.xs),
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(Icons.close, size: compact ? 12 : 14, color: fgColor),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
