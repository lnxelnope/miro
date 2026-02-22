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
