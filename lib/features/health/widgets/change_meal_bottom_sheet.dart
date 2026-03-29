import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:miro_hybrid/core/constants/date_planning_limits.dart';
import 'package:miro_hybrid/core/constants/enums.dart';
import 'package:miro_hybrid/core/database/app_database.dart';
import 'package:miro_hybrid/core/database/model_extensions.dart';
import 'package:miro_hybrid/core/theme/app_colors.dart';
import 'package:miro_hybrid/core/theme/app_tokens.dart';
import 'package:miro_hybrid/features/health/utils/meal_type_l10n.dart';
import 'package:miro_hybrid/l10n/app_localizations.dart';

/// Bottom sheet: change meal type and optionally move to another date.
/// Use [allowDateChange]: false for batch selection from sandbox (same day, type only).
class ChangeMealBottomSheet extends StatefulWidget {
  final List<FoodEntry> foods;
  final MealType currentMealType;
  final DateTime currentDate;
  final bool allowDateChange;

  ChangeMealBottomSheet({
    super.key,
    required List<FoodEntry> foods,
    required this.currentMealType,
    required this.currentDate,
    this.allowDateChange = true,
  })  : assert(foods.isNotEmpty, 'ChangeMealBottomSheet requires at least one food'),
        foods = List.unmodifiable(foods);

  @override
  State<ChangeMealBottomSheet> createState() => _ChangeMealBottomSheetState();
}

class _ChangeMealBottomSheetState extends State<ChangeMealBottomSheet> {
  late MealType _selectedMealType;
  DateTime? _newDate;

  bool get _isBatch => widget.foods.length > 1;

  FoodEntry get _primaryFood => widget.foods.first;

  @override
  void initState() {
    super.initState();
    _selectedMealType = widget.currentMealType;
  }

  Future<void> _pickDate() async {
    if (!widget.allowDateChange) return;
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.currentDate,
      firstDate: DateTime(2020),
      lastDate: getMaxPlanningDate(),
    );
    if (picked != null) {
      setState(() => _newDate = picked);
    }
  }

  bool get _hasChanges {
    final typeChanged =
        widget.foods.any((f) => f.mealType != _selectedMealType);
    return typeChanged || _newDate != null;
  }

  bool _isCurrentMealType(MealType type) {
    return widget.foods.every((f) => f.mealType == type) &&
        widget.currentMealType == type;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = L10n.of(context)!;
    final localeTag = Localizations.localeOf(context).toString();
    final dateFormat = DateFormat('d MMM yyyy', localeTag);

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.xl,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.swap_horiz_rounded,
                    color: AppColors.primary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _isBatch
                        ? l10n.changeMealBatchCount(widget.foods.length)
                        : _primaryFood.foodName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              l10n.changeMealType,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: MealType.values.map((type) {
                final isSelected = _selectedMealType == type;
                final isCurrent = _isCurrentMealType(type);
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: type != MealType.values.last ? 8 : 0,
                    ),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedMealType = type),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : AppColors.textSecondary.withValues(alpha: 0.08),
                          borderRadius: AppRadius.md,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(type.icon,
                                color: type.iconColor,
                                size: 24),
                            const SizedBox(height: 4),
                            Text(
                              mealTypeLabel(type, l10n),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.primary
                                    : isDark
                                        ? Colors.white70
                                        : AppColors.textSecondary,
                              ),
                            ),
                            if (isCurrent) ...[
                              const SizedBox(height: 2),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.6),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (widget.allowDateChange) ...[
              const SizedBox(height: 20),
              Text(
                l10n.moveToAnotherDate,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: _newDate != null
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : AppColors.textSecondary.withValues(alpha: 0.08),
                    borderRadius: AppRadius.md,
                    border: Border.all(
                      color: _newDate != null
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 20,
                        color: _newDate != null
                            ? AppColors.primary
                            : (isDark ? Colors.white54 : AppColors.textSecondary),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _newDate != null
                            ? dateFormat.format(_newDate!)
                            : l10n.currentDate(dateFormat.format(widget.currentDate)),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: _newDate != null
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: _newDate != null
                              ? AppColors.primary
                              : isDark
                                  ? Colors.white54
                                  : AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.edit_calendar_rounded,
                        size: 18,
                        color: isDark ? Colors.white38 : AppColors.textTertiary,
                      ),
                    ],
                  ),
                ),
              ),
              if (_newDate != null) ...[
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => setState(() => _newDate = null),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      l10n.cancelDateChange,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.error,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.md),
                    ),
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _hasChanges
                        ? () {
                            Navigator.pop(context, {
                              'mealType': widget.foods
                                      .any((f) => f.mealType != _selectedMealType)
                                  ? _selectedMealType
                                  : null,
                              'date': _newDate,
                            });
                          }
                        : null,
                    icon: const Icon(Icons.check_rounded, size: 20),
                    label: Text(l10n.confirm),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          isDark ? Colors.white12 : AppColors.divider,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.md),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).viewPadding.bottom),
          ],
        ),
      ),
    );
  }
}
