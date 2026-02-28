# 📋 Task: Phase 1 — Design System Foundation

## 🎯 เป้าหมาย

สร้าง Design System ที่เป็นมาตรฐานให้ทั้งแอป ประกอบด้วย:
- Design Tokens (spacing, radius, elevation, durations)
- เพิ่มสีที่ขาดใน AppColors
- Reusable Components: AppButton, AppTextField, AppBottomSheet, AppCard, AppChip

## 📂 ไฟล์ที่เกี่ยวข้อง

| Action | ไฟล์ |
|--------|------|
| CREATE | `lib/core/theme/app_tokens.dart` |
| EDIT   | `lib/core/theme/app_colors.dart` |
| CREATE | `lib/core/widgets/app_button.dart` |
| CREATE | `lib/core/widgets/app_text_field.dart` |
| CREATE | `lib/core/widgets/app_bottom_sheet.dart` |
| CREATE | `lib/core/widgets/app_card.dart` |
| CREATE | `lib/core/widgets/app_chip.dart` |

---

## 🔧 ขั้นตอนการทำงาน

---

### Step 1: สร้าง Design Tokens

**ไฟล์:** `lib/core/theme/app_tokens.dart`
**Action:** CREATE
**Explanation:** รวม spacing, border radius, elevation, animation durations ไว้ที่เดียว ทุกที่ในแอปจะ import ค่าเหล่านี้แทนการใส่ตัวเลขตรงๆ

```dart
import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════
// SPACING — ใช้แทน EdgeInsets ที่ใส่ตัวเลขตรงๆ
// ═══════════════════════════════════════════════════════════════
class AppSpacing {
  AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double xxxxl = 40;

  // Shortcut EdgeInsets ที่ใช้บ่อย
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);

  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);
}

// ═══════════════════════════════════════════════════════════════
// RADIUS — ใช้แทน BorderRadius.circular(ตัวเลข)
// ═══════════════════════════════════════════════════════════════
class AppRadius {
  AppRadius._();

  static const double smValue = 8;
  static const double mdValue = 12;
  static const double lgValue = 16;
  static const double xlValue = 20;
  static const double xxlValue = 24;
  static const double pillValue = 999;

  static final BorderRadius sm = BorderRadius.circular(smValue);
  static final BorderRadius md = BorderRadius.circular(mdValue);
  static final BorderRadius lg = BorderRadius.circular(lgValue);
  static final BorderRadius xl = BorderRadius.circular(xlValue);
  static final BorderRadius xxl = BorderRadius.circular(xxlValue);
  static final BorderRadius pill = BorderRadius.circular(pillValue);

  // สำหรับ bottom sheet (โค้งแค่ด้านบน)
  static final BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(xlValue),
  );
}

// ═══════════════════════════════════════════════════════════════
// ELEVATION — ค่า elevation มาตรฐาน
// ═══════════════════════════════════════════════════════════════
class AppElevation {
  AppElevation._();

  static const double none = 0;
  static const double sm = 1;
  static const double md = 2;
  static const double lg = 4;
  static const double xl = 8;
}

// ═══════════════════════════════════════════════════════════════
// DURATIONS — animation durations
// ═══════════════════════════════════════════════════════════════
class AppDurations {
  AppDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration verySlow = Duration(milliseconds: 600);
}

// ═══════════════════════════════════════════════════════════════
// SIZES — ขนาดมาตรฐานสำหรับ component ต่างๆ
// ═══════════════════════════════════════════════════════════════
class AppSizes {
  AppSizes._();

  // Button heights
  static const double buttonSmall = 36;
  static const double buttonMedium = 48;
  static const double buttonLarge = 56;

  // Icon sizes
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double iconXl = 32;

  // Drag handle
  static const double dragHandleWidth = 40;
  static const double dragHandleHeight = 4;
}
```

---

### Step 2: เพิ่มสีที่ขาดใน AppColors

**ไฟล์:** `lib/core/theme/app_colors.dart`
**Action:** EDIT
**Explanation:** เพิ่มสี AI (Indigo), Premium (Purple) ที่ปัจจุบัน hardcode `Color(0xFF6366F1)` อยู่ 10+ จุด

เพิ่ม **ก่อนบรรทัดสุดท้าย** `}` ของ class AppColors:

```dart
  // AI / Gemini Analysis
  static const Color ai = Color(0xFF6366F1); // Indigo-500
  static const Color aiLight = Color(0xFFE0E7FF); // Indigo-100
  static const Color aiDark = Color(0xFF4F46E5); // Indigo-600

  // Premium / Subscription
  static const Color premium = Color(0xFF7C3AED); // Purple-600
  static const Color premiumLight = Color(0xFFEDE9FE); // Purple-100
  static const Color premiumDark = Color(0xFF6D28D9); // Purple-700

  // Skeleton / Shimmer Loading
  static const Color shimmer = Color(0xFFE5E7EB); // Gray-200
  static const Color shimmerDark = Color(0xFF374151); // Gray-700

  // Overlay
  static const Color overlay = Color(0x80000000); // Black 50%
  static const Color overlayLight = Color(0x1A000000); // Black 10%
```

**ไฟล์สมบูรณ์หลังแก้:**

```dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFF2D8B75);
  static const Color primaryLight = Color(0xFF5BB5A2);
  static const Color primaryDark = Color(0xFF1F6F5C);

  // Categories
  static const Color finance = Color(0xFF10B981);
  static const Color health = Color(0xFFF59E0B);
  static const Color tasks = Color(0xFF3B82F6);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Neutrals (Light Mode)
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F4F6);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color divider = Color(0xFFE5E7EB);

  // Neutrals (Dark Mode)
  static const Color backgroundDark = Color(0xFF111827);
  static const Color surfaceDark = Color(0xFF1F2937);
  static const Color surfaceVariantDark = Color(0xFF374151);
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color dividerDark = Color(0xFF374151);

  // Income/Expense
  static const Color income = Color(0xFF22C55E);
  static const Color expense = Color(0xFFEF4444);

  // Macros
  static const Color protein = Color(0xFFEF4444);
  static const Color carbs = Color(0xFFF59E0B);
  static const Color fat = Color(0xFF3B82F6);

  // Tier colors
  static const Color tierBronze = Color(0xFFCD7F32);
  static const Color tierSilver = Color(0xFFC0C0C0);
  static const Color tierGold = Color(0xFFFFD700);
  static const Color tierDiamond = primary;

  // Energy level colors
  static const Color energyVeryLow = Color(0xFFEF4444);
  static const Color energyLow = Color(0xFFF59E0B);
  static const Color energyMedium = Color(0xFF10B981);
  static const Color energyHigh = Color(0xFF06B6D4);

  // AI / Gemini Analysis
  static const Color ai = Color(0xFF6366F1); // Indigo-500
  static const Color aiLight = Color(0xFFE0E7FF); // Indigo-100
  static const Color aiDark = Color(0xFF4F46E5); // Indigo-600

  // Premium / Subscription
  static const Color premium = Color(0xFF7C3AED); // Purple-600
  static const Color premiumLight = Color(0xFFEDE9FE); // Purple-100
  static const Color premiumDark = Color(0xFF6D28D9); // Purple-700

  // Skeleton / Shimmer Loading
  static const Color shimmer = Color(0xFFE5E7EB); // Gray-200
  static const Color shimmerDark = Color(0xFF374151); // Gray-700

  // Overlay
  static const Color overlay = Color(0x80000000); // Black 50%
  static const Color overlayLight = Color(0x1A000000); // Black 10%
}
```

---

### Step 3: สร้าง AppButton

**ไฟล์:** `lib/core/widgets/app_button.dart`
**Action:** CREATE
**Explanation:** ปุ่มมาตรฐานที่ใช้ทั้งแอป รองรับ 6 variants ให้ไม่ต้องจำ style เอง

```dart
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
```

---

### Step 4: สร้าง AppTextField

**ไฟล์:** `lib/core/widgets/app_text_field.dart`
**Action:** CREATE
**Explanation:** Text field มาตรฐาน ใช้แทน TextField + InputDecoration ที่แต่ละที่ style ต่างกัน

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final Widget? prefix;
  final Widget? suffix;
  final bool isDense;
  final bool readOnly;
  final bool autofocus;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final String? errorText;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefix,
    this.suffix,
    this.isDense = false,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.onTap,
    this.focusNode,
    this.errorText,
    this.textInputAction,
    this.onSubmitted,
    this.obscureText = false,
  });

  /// Compact variant สำหรับ ingredient rows ที่มีพื้นที่น้อย
  const AppTextField.dense({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefix,
    this.suffix,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.onTap,
    this.focusNode,
    this.errorText,
    this.textInputAction,
    this.onSubmitted,
    this.obscureText = false,
  }) : isDense = true;

  /// Number-only variant
  const AppTextField.number({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefix,
    this.suffix,
    this.isDense = false,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.inputFormatters,
    this.onChanged,
    this.onTap,
    this.focusNode,
    this.errorText,
    this.textInputAction,
    this.onSubmitted,
    this.obscureText = false,
  }) : keyboardType = const TextInputType.numberWithOptions(decimal: true);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: controller,
      readOnly: readOnly,
      autofocus: autofocus,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onTap: onTap,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      obscureText: obscureText,
      style: TextStyle(
        fontSize: isDense ? 13 : 15,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        prefixIcon: prefix,
        suffixIcon: suffix,
        isDense: isDense,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isDense ? AppSpacing.sm : AppSpacing.md,
          vertical: isDense ? AppSpacing.sm : AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: isDense ? AppRadius.sm : AppRadius.md,
          borderSide: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.divider,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: isDense ? AppRadius.sm : AppRadius.md,
          borderSide: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.divider,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: isDense ? AppRadius.sm : AppRadius.md,
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: isDense ? AppRadius.sm : AppRadius.md,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        filled: true,
        fillColor: isDark
            ? AppColors.surfaceVariantDark.withValues(alpha: 0.3)
            : Colors.transparent,
      ),
    );
  }
}
```

---

### Step 5: สร้าง AppBottomSheet

**ไฟล์:** `lib/core/widgets/app_bottom_sheet.dart`
**Action:** CREATE
**Explanation:** Bottom sheet wrapper มาตรฐาน จัดการ drag handle, header, padding, keyboard ให้อัตโนมัติ ทุก bottom sheet ในแอปจะใช้ตัวนี้

```dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

class AppBottomSheet extends StatelessWidget {
  final String? title;
  final IconData? icon;
  final Color? iconColor;
  final Widget? trailing;
  final Widget child;
  final double maxHeightFactor;

  const AppBottomSheet({
    super.key,
    this.title,
    this.icon,
    this.iconColor,
    this.trailing,
    required this.child,
    this.maxHeightFactor = 0.9,
  });

  /// แสดง bottom sheet มาตรฐาน — เรียกใช้แทน showModalBottomSheet ตรงๆ
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget Function(BuildContext context) builder,
    String? title,
    IconData? icon,
    Color? iconColor,
    Widget? trailing,
    double maxHeightFactor = 0.9,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AppBottomSheet(
        title: title,
        icon: icon,
        iconColor: iconColor,
        trailing: trailing,
        maxHeightFactor: maxHeightFactor,
        child: builder(ctx),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: AppSpacing.paddingLg,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * maxHeightFactor,
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.xl,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: AppSizes.dragHandleWidth,
                height: AppSizes.dragHandleHeight,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: AppRadius.pill,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Header (optional)
            if (title != null) ...[
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: iconColor ?? AppColors.primary,
                        size: AppSizes.iconLg),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: Text(
                      title!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
            ],

            // Content
            child,
          ],
        ),
      ),
    );
  }
}
```

---

### Step 6: สร้าง AppCard

**ไฟล์:** `lib/core/widgets/app_card.dart`
**Action:** CREATE
**Explanation:** Card wrapper มาตรฐาน แทน Container ที่ใส่ decoration เอง

```dart
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
```

---

### Step 7: สร้าง AppChip

**ไฟล์:** `lib/core/widgets/app_chip.dart`
**Action:** CREATE
**Explanation:** Chip/badge มาตรฐาน ใช้สำหรับ tags, quick-select items, common ingredients

```dart
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
```

---

## ⚠️ ข้อควรระวัง

1. **อย่าลบหรือแก้สีเดิม** ใน `app_colors.dart` — แค่เพิ่มสีใหม่ต่อท้าย
2. **ห้ามแก้ `app_theme.dart`** ในขั้นตอนนี้ — จะแก้ใน Phase 2
3. ตรวจสอบว่า import path ถูกต้อง: `package:miro_hybrid/core/theme/app_tokens.dart`
4. ทุกไฟล์ใน `lib/core/widgets/` ต้อง import `app_tokens.dart` และ `app_colors.dart`

## ✅ Definition of Done

- [ ] ไฟล์ `lib/core/theme/app_tokens.dart` ถูกสร้างและ compile ผ่าน
- [ ] ไฟล์ `lib/core/theme/app_colors.dart` มีสี `ai`, `aiLight`, `aiDark`, `premium`, `premiumLight`, `premiumDark`, `shimmer`, `shimmerDark`, `overlay`, `overlayLight`
- [ ] ไฟล์ `lib/core/widgets/app_button.dart` ถูกสร้างและ compile ผ่าน
- [ ] ไฟล์ `lib/core/widgets/app_text_field.dart` ถูกสร้างและ compile ผ่าน
- [ ] ไฟล์ `lib/core/widgets/app_bottom_sheet.dart` ถูกสร้างและ compile ผ่าน
- [ ] ไฟล์ `lib/core/widgets/app_card.dart` ถูกสร้างและ compile ผ่าน
- [ ] ไฟล์ `lib/core/widgets/app_chip.dart` ถูกสร้างและ compile ผ่าน
- [ ] `dart analyze lib/core/theme/app_tokens.dart` ไม่มี error
- [ ] `dart analyze lib/core/widgets/` ไม่มี error

## 🚀 ต้อง Deploy หรือไม่?

- [x] ไม่ต้อง Deploy (Flutter client-side only)
- [ ] ต้อง Deploy Firebase Functions
- [ ] ต้อง Deploy Firestore Rules
