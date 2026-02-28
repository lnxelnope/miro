import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderColor,
    this.borderRadius,
    this.onTap,
  });

  /// Variant ที่มีพื้นหลังเป็นสีอ่อนๆ ตาม accent color
  factory AppCard.accent({
    Key? key,
    required Widget child,
    required Color accentColor,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return AppCard(
      key: key,
      color: accentColor.withValues(alpha: 0.08),
      borderColor: accentColor.withValues(alpha: 0.2),
      padding: padding,
      margin: margin,
      onTap: onTap,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final container = Container(
      margin: margin,
      padding: padding ?? AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: color ?? (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant),
        borderRadius: borderRadius ?? AppRadius.md,
        border: borderColor != null
            ? Border.all(color: borderColor!)
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? AppRadius.md,
          child: container,
        ),
      );
    }

    return container;
  }
}
