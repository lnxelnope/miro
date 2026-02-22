import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

enum AppButtonVariant { primary, secondary, outlined, text, danger, ai }
enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String label;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final bool isEnabled;
  final VoidCallback? onPressed;

  const AppButton({
    super.key,
    required this.label,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.isEnabled = true,
    this.onPressed,
  });

  // Convenience constructors
  const AppButton.primary({
    super.key,
    required this.label,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.isEnabled = true,
    this.onPressed,
  })  : variant = AppButtonVariant.primary,
        size = AppButtonSize.medium;

  const AppButton.secondary({
    super.key,
    required this.label,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.isEnabled = true,
    this.onPressed,
  })  : variant = AppButtonVariant.secondary,
        size = AppButtonSize.medium;

  const AppButton.outlined({
    super.key,
    required this.label,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.isEnabled = true,
    this.onPressed,
  })  : variant = AppButtonVariant.outlined,
        size = AppButtonSize.medium;

  const AppButton.text({
    super.key,
    required this.label,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.isEnabled = true,
    this.onPressed,
  })  : variant = AppButtonVariant.text,
        size = AppButtonSize.medium;

  const AppButton.danger({
    super.key,
    required this.label,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.isEnabled = true,
    this.onPressed,
  })  : variant = AppButtonVariant.danger,
        size = AppButtonSize.medium;

  const AppButton.ai({
    super.key,
    required this.label,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.isEnabled = true,
    this.onPressed,
  })  : variant = AppButtonVariant.ai,
        size = AppButtonSize.medium;

  double get _height {
    switch (size) {
      case AppButtonSize.small:
        return AppSizes.buttonSmall;
      case AppButtonSize.medium:
        return AppSizes.buttonMedium;
      case AppButtonSize.large:
        return AppSizes.buttonLarge;
    }
  }

  double get _fontSize {
    switch (size) {
      case AppButtonSize.small:
        return 13;
      case AppButtonSize.medium:
        return 15;
      case AppButtonSize.large:
        return 16;
    }
  }

  double get _iconSize {
    switch (size) {
      case AppButtonSize.small:
        return AppSizes.iconSm;
      case AppButtonSize.medium:
        return AppSizes.iconMd;
      case AppButtonSize.large:
        return AppSizes.iconLg;
    }
  }

  Color _backgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (variant) {
      case AppButtonVariant.primary:
        return AppColors.primary;
      case AppButtonVariant.secondary:
        return isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant;
      case AppButtonVariant.outlined:
      case AppButtonVariant.text:
        return Colors.transparent;
      case AppButtonVariant.danger:
        return AppColors.error;
      case AppButtonVariant.ai:
        return AppColors.ai;
    }
  }

  Color _foregroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.danger:
      case AppButtonVariant.ai:
        return Colors.white;
      case AppButtonVariant.secondary:
        return isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
      case AppButtonVariant.outlined:
        return isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
      case AppButtonVariant.text:
        return AppColors.primary;
    }
  }

  BorderSide? _borderSide(BuildContext context) {
    if (variant == AppButtonVariant.outlined) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return BorderSide(
        color: isDark ? AppColors.dividerDark : AppColors.divider,
        width: 1.5,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bg = _backgroundColor(context);
    final fg = _foregroundColor(context);
    final border = _borderSide(context);

    final effectiveOnPressed = (isLoading || !isEnabled) ? null : onPressed;

    final buttonStyle = ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(bg),
      foregroundColor: WidgetStatePropertyAll(fg),
      minimumSize: WidgetStatePropertyAll(
        Size(isFullWidth ? double.infinity : 0, _height),
      ),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 0,
        ),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: AppRadius.md,
          side: border ?? BorderSide.none,
        ),
      ),
      elevation: const WidgetStatePropertyAll(0),
      textStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: _fontSize, fontWeight: FontWeight.w600),
      ),
    );

    Widget child;
    if (isLoading) {
      child = SizedBox(
        width: _iconSize,
        height: _iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(fg),
        ),
      );
    } else if (icon != null) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _iconSize),
          const SizedBox(width: AppSpacing.sm),
          Text(label),
        ],
      );
    } else {
      child = Text(label);
    }

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: variant == AppButtonVariant.text
          ? TextButton(
              onPressed: effectiveOnPressed,
              style: buttonStyle,
              child: child,
            )
          : ElevatedButton(
              onPressed: effectiveOnPressed,
              style: buttonStyle,
              child: child,
            ),
    );
  }
}
