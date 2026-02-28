import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/constants/enums.dart';
import '../providers/quick_add_provider.dart';
import '../providers/health_provider.dart';
import '../providers/my_meal_provider.dart';
import '../models/food_entry.dart';

/// Section แสดง Quick Add buttons + Repeat Yesterday
/// แสดงบน Timeline Tab ก่อนรายการอาหาร (ย่อ/ขยายได้)
class QuickAddSection extends ConsumerStatefulWidget {
  final DateTime selectedDate;

  const QuickAddSection({super.key, required this.selectedDate});

  @override
  ConsumerState<QuickAddSection> createState() => _QuickAddSectionState();
}

class _QuickAddSectionState extends ConsumerState<QuickAddSection>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late final AnimationController _animController;
  late final Animation<double> _expandAnimation;

  DateTime get selectedDate => widget.selectedDate;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final quickItemsAsync = ref.watch(topQuickAddItemsProvider);
    final repeatDayAsync = ref.watch(repeatDayProvider);
    final repeatAsync = ref.watch(repeatOptionsProvider);

    // ถ้าไม่มี data เลย ไม่ต้องแสดง section นี้
    final hasQuickItems = quickItemsAsync.valueOrNull?.isNotEmpty ?? false;
    final hasRepeatDay = repeatDayAsync.valueOrNull != null;
    final hasRepeat = repeatAsync.valueOrNull?.isNotEmpty ?? false;

    if (!hasQuickItems && !hasRepeat && !hasRepeatDay) return const SizedBox();

    final quickCount = quickItemsAsync.valueOrNull?.length ?? 0;
    final repeatCount = repeatAsync.valueOrNull?.length ?? 0;
    final totalCount = quickCount + repeatCount + (hasRepeatDay ? 1 : 0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.lg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (แตะเพื่อย่อ/ขยาย)
          InkWell(
            onTap: _toggleExpand,
            borderRadius: AppRadius.sm,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.bolt, size: 18, color: AppColors.warning),
                  const SizedBox(width: 6),
                  Text(
                    'Quick Add',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.health.withValues(alpha: 0.15),
                      borderRadius: AppRadius.md,
                    ),
                    child: Text(
                      '$totalCount',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.health,
                      ),
                    ),
                  ),
                  const Spacer(),
                  RotationTransition(
                    turns:
                        Tween(begin: 0.0, end: 0.5).animate(_expandAnimation),
                    child: Icon(
                      Icons.expand_more,
                      size: 20,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: -1.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // "Same as Yesterday" (ทั้งวัน) — แสดงก่อนสุด
                repeatDayAsync.when(
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                  data: (repeatDay) {
                    if (repeatDay == null) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildRepeatDayChip(context, ref, repeatDay),
                    );
                  },
                ),

                // Quick Add Chips (Favorite foods)
                quickItemsAsync.when(
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                  data: (items) {
                    if (items.isEmpty) return const SizedBox();
                    return Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: items
                          .map((item) => _buildQuickChip(
                                context,
                                ref,
                                item,
                              ))
                          .toList(),
                    );
                  },
                ),

                // Repeat Yesterday By Meal
                repeatAsync.when(
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                  data: (options) {
                    if (options.isEmpty) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: options
                            .map((opt) => _buildRepeatChip(
                                  context,
                                  ref,
                                  opt,
                                ))
                            .toList(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Chip สำหรับ "Same as Yesterday" (คัดลอกทั้งวัน)
  Widget _buildRepeatDayChip(
      BuildContext context, WidgetRef ref, RepeatDayInfo repeatDay) {
    return ActionChip(
      avatar: const Icon(AppIcons.repeat, size: 16, color: AppIcons.repeatColor),
      label: Text(
        'Same as Yesterday (${repeatDay.totalCalories.toInt()} kcal)',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      backgroundColor: AppColors.premium.withValues(alpha: 0.08),
      side: BorderSide(color: AppColors.premium.withValues(alpha: 0.3)),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xl),
      onPressed: () => _repeatDay(context, repeatDay),
    );
  }

  /// Chip สำหรับ quick add (1 tap = บันทึกทันที)
  Widget _buildQuickChip(
      BuildContext context, WidgetRef ref, QuickAddItem item) {
    return InputChip(
      avatar: Text(item.emoji, style: const TextStyle(fontSize: 14)),
      label: Text(
        '${item.name} (${item.calories.toInt()})',
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: AppColors.health.withValues(alpha: 0.08),
      side: BorderSide(color: AppColors.health.withValues(alpha: 0.2)),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xl),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: () => _deleteQuickAddItem(context, ref, item),
      onPressed: () => _quickAdd(context, item),
    );
  }

  /// Chip สำหรับ repeat yesterday
  Widget _buildRepeatChip(
      BuildContext context, WidgetRef ref, RepeatMealInfo option) {
    // แสดงชื่อตามประเภท: breakfast → "Yesterday Breakfast"
    String label;
    switch (option.mealType) {
      case MealType.breakfast:
        label = 'Yesterday Breakfast';
        break;
      case MealType.lunch:
        label = 'Yesterday Lunch';
        break;
      case MealType.dinner:
        label = 'Yesterday Dinner';
        break;
      case MealType.snack:
        label = 'Yesterday Snack';
        break;
    }

    return ActionChip(
      avatar: const Icon(AppIcons.repeat, size: 16, color: AppIcons.repeatColor),
      label: Text(
        '$label (${option.totalCalories.toInt()} kcal)',
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: AppColors.info.withValues(alpha: 0.08),
      side: BorderSide(color: AppColors.info.withValues(alpha: 0.2)),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xl),
      onPressed: () => _repeatMeal(context, option),
    );
  }

  /// Quick Add: บันทึกทันที 1 tap
  Future<void> _quickAdd(BuildContext context, QuickAddItem item) async {
    final mealType = _guessMealType();

    // ใช้ selectedDate + เวลาปัจจุบัน
    final now = DateTime.now();
    final date = widget.selectedDate;
    final ts = DateTime(date.year, date.month, date.day, now.hour, now.minute);

    final entry = FoodEntry()
      ..foodName = item.name
      ..mealType = mealType
      ..timestamp = ts
      ..servingSize = item.servingSize
      ..servingUnit = item.servingUnit
      ..calories = item.calories
      ..protein = item.protein
      ..carbs = item.carbs
      ..fat = item.fat
      ..baseCalories = item.baseCalories
      ..baseProtein = item.baseProtein
      ..baseCarbs = item.baseCarbs
      ..baseFat = item.baseFat
      ..myMealId = item.myMealId
      ..ingredientId = item.ingredientId
      ..source = DataSource.manual
      ..isVerified = true;

    final notifier = ref.read(foodEntriesNotifierProvider.notifier);
    await notifier.addFoodEntry(entry);
    refreshFoodProviders(ref, selectedDate);

    // เพิ่ม usage count
    if (item.myMealId != null) {
      await ref
          .read(myMealNotifierProvider.notifier)
          .incrementMealUsage(item.myMealId!);
    }
    if (item.ingredientId != null) {
      await ref
          .read(myMealNotifierProvider.notifier)
          .incrementIngredientUsage(item.ingredientId!);
    }

    ref.invalidate(topQuickAddItemsProvider);

    if (!context.mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(AppIcons.energy, size: 16, color: AppIcons.energyColor),
            const SizedBox(width: 4),
            Text('Saved "${item.name}" ${item.calories.toInt()} kcal'),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Edit',
          textColor: Colors.white,
          onPressed: () {
            scaffoldMessenger.hideCurrentSnackBar();
            // TODO: เปิด edit sheet
          },
        ),
      ),
    );

    // Auto-dismiss หลังจาก 1 วินาที (แม้จะมี action button)
    Timer(const Duration(seconds: 1), () {
      if (context.mounted) {
        scaffoldMessenger.hideCurrentSnackBar();
      }
    });
  }

  /// Repeat: copy entries ทั้งมื้อจากเมื่อวาน
  Future<void> _repeatMeal(BuildContext context, RepeatMealInfo option) async {
    // แสดงชื่อตามประเภท: breakfast → "Yesterday Breakfast"
    String label;
    switch (option.mealType) {
      case MealType.breakfast:
        label = 'Yesterday Breakfast';
        break;
      case MealType.lunch:
        label = 'Yesterday Lunch';
        break;
      case MealType.dinner:
        label = 'Yesterday Dinner';
        break;
      case MealType.snack:
        label = 'Yesterday Snack';
        break;
    }

    // ยืนยันก่อน
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(AppIcons.repeat, size: 20, color: AppIcons.repeatColor),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Copy ${option.entries.length} entries (${option.totalCalories.toInt()} kcal)',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            ...option.entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '  • ${e.foodName} (${e.calories.toInt()} kcal)',
                    style: const TextStyle(fontSize: 13),
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.health,
              foregroundColor: Colors.white,
            ),
            child: const Text('Copy'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final notifier = ref.read(foodEntriesNotifierProvider.notifier);
    final now = DateTime.now();
    final date = widget.selectedDate;
    final ts = DateTime(date.year, date.month, date.day, now.hour, now.minute);

    for (final original in option.entries) {
      final copy = FoodEntry()
        ..foodName = original.foodName
        ..foodNameEn = original.foodNameEn
        ..mealType = original.mealType
        ..timestamp = ts
        ..imagePath = original.imagePath
        ..servingSize = original.servingSize
        ..servingUnit = original.servingUnit
        ..servingGrams = original.servingGrams
        ..calories = original.calories
        ..protein = original.protein
        ..carbs = original.carbs
        ..fat = original.fat
        ..baseCalories = original.baseCalories
        ..baseProtein = original.baseProtein
        ..baseCarbs = original.baseCarbs
        ..baseFat = original.baseFat
        ..fiber = original.fiber
        ..sugar = original.sugar
        ..sodium = original.sodium
        ..myMealId = original.myMealId
        ..ingredientId = original.ingredientId
        ..source = original.source
        ..isVerified = original.isVerified
        ..notes = 'Copied from yesterday';

      await notifier.addFoodEntry(copy);
    }

    refreshFoodProviders(ref, selectedDate);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Copied ${option.entries.length} entries from $label '
          '(${option.totalCalories.toInt()} kcal)',
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 1), // เพิ่ม duration
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  MealType _guessMealType() {
    final hour = DateTime.now().hour;
    if (hour < 10) return MealType.breakfast;
    if (hour < 14) return MealType.lunch;
    if (hour < 17) return MealType.snack;
    return MealType.dinner;
  }

  /// ลบรายการออกจาก Quick Add (ลด usage count หรือลบ MyMeal/Ingredient)
  Future<void> _deleteQuickAddItem(
      BuildContext context, WidgetRef ref, QuickAddItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from Quick Add'),
        content: Text('Remove "${item.name}" from Quick Add?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final notifier = ref.read(myMealNotifierProvider.notifier);

    if (item.myMealId != null) {
      await notifier.deleteMeal(item.myMealId!);
    } else if (item.ingredientId != null) {
      await notifier.deleteIngredient(item.ingredientId!);
    }

    ref.invalidate(topQuickAddItemsProvider);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed "${item.name}" from Quick Add'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Repeat Day: copy ทุกรายการจากเมื่อวาน
  Future<void> _repeatDay(BuildContext context, RepeatDayInfo repeatDay) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppIcons.repeat, size: 20, color: AppIcons.repeatColor),
            SizedBox(width: 4),
            Text('Same as Yesterday'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Copy all ${repeatDay.entries.length} entries from yesterday (${repeatDay.totalCalories.toInt()} kcal)',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              'This will add all your meals from yesterday to today.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.premium,
              foregroundColor: Colors.white,
            ),
            child: const Text('Copy All'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final notifier = ref.read(foodEntriesNotifierProvider.notifier);
    final now = DateTime.now();
    final date = widget.selectedDate;
    final ts = DateTime(date.year, date.month, date.day, now.hour, now.minute);

    for (final original in repeatDay.entries) {
      final copy = FoodEntry()
        ..foodName = original.foodName
        ..foodNameEn = original.foodNameEn
        ..mealType = original.mealType
        ..timestamp = ts
        ..imagePath = original.imagePath
        ..servingSize = original.servingSize
        ..servingUnit = original.servingUnit
        ..servingGrams = original.servingGrams
        ..calories = original.calories
        ..protein = original.protein
        ..carbs = original.carbs
        ..fat = original.fat
        ..baseCalories = original.baseCalories
        ..baseProtein = original.baseProtein
        ..baseCarbs = original.baseCarbs
        ..baseFat = original.baseFat
        ..fiber = original.fiber
        ..sugar = original.sugar
        ..sodium = original.sodium
        ..myMealId = original.myMealId
        ..ingredientId = original.ingredientId
        ..source = original.source
        ..isVerified = original.isVerified
        ..notes = 'Copied from yesterday';

      await notifier.addFoodEntry(copy);
    }

    refreshFoodProviders(ref, selectedDate);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Copied ${repeatDay.entries.length} entries from yesterday '
          '(${repeatDay.totalCalories.toInt()} kcal)',
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
