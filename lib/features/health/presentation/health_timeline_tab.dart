import 'package:flutter/material.dart';
import '../../../core/theme/app_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/logger.dart';
import '../providers/health_provider.dart';
import '../providers/fulfill_calorie_provider.dart';
import '../widgets/daily_summary_card.dart';
import '../widgets/edit_food_bottom_sheet.dart';
import '../widgets/log_from_meal_sheet.dart';
import '../widgets/meal_section.dart';
import '../../../core/database/database_service.dart';
import '../models/food_entry.dart';
import '../../../core/constants/enums.dart';
import 'health_diet_tab.dart';
import '../../scanner/providers/scanner_provider.dart';
import '../../../core/services/usage_limiter.dart';
import '../../../core/services/purchase_service.dart';
class HealthTimelineTab extends ConsumerStatefulWidget {
  const HealthTimelineTab({super.key});

  @override
  ConsumerState<HealthTimelineTab> createState() => _HealthTimelineTabState();
}

class _HealthTimelineTabState extends ConsumerState<HealthTimelineTab> {
  DateTime _selectedDate = dateOnly(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final timelineAsync = ref.watch(healthTimelineProvider(_selectedDate));
    final fulfillAsync = ref.watch(fulfillCalorieProvider(_selectedDate));

    return RefreshIndicator(
      onRefresh: () async {
        AppLogger.info('Pull-to-refresh starting...');

        // 1. Trigger auto-scan for new images
        try {
          AppLogger.info('Starting to scan new images from Gallery...');
          final count = await ref
              .read(galleryScanNotifierProvider.notifier)
              .scanNewImages();
          AppLogger.info('Scan complete - found: $count entries');
        } catch (e) {
          AppLogger.error('Scan failed', e);
        }

        // 2. Refresh existing data
        refreshFoodProviders(ref, _selectedDate);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Upsell Banner
          SliverToBoxAdapter(
            child: _buildUpsellBanner(),
          ),

          // Daily Summary Card
          SliverToBoxAdapter(
            child: DailySummaryCard(selectedDate: _selectedDate),
          ),

          // Date Selector
          SliverToBoxAdapter(
            child: _buildDateSelector(),
          ),

          // Meal Sections — always visible
          SliverToBoxAdapter(
            child: Builder(builder: (context) {
              final items = timelineAsync.valueOrNull ?? [];
              final fulfill = fulfillAsync.valueOrNull;
              final foodEntries = items
                  .where((i) => i.type == 'food')
                  .map((i) => i.data as FoodEntry)
                  .toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  MealSection(
                    mealType: MealType.breakfast,
                    foods: foodEntries
                        .where((f) => f.mealType == MealType.breakfast)
                        .toList(),
                    onAddFood: () => _showAddFoodDialog(MealType.breakfast),
                    onEditFood: _editFoodEntry,
                    onDeleteFood: _deleteFoodEntry,
                    selectedDate: _selectedDate,
                    ghostSuggestion: fulfill?.suggestions[MealType.breakfast],
                    onSuggestionTap: (s) => _showAddFoodDialogWithSuggestion(MealType.breakfast, s),
                  ),
                  MealSection(
                    mealType: MealType.lunch,
                    foods: foodEntries
                        .where((f) => f.mealType == MealType.lunch)
                        .toList(),
                    onAddFood: () => _showAddFoodDialog(MealType.lunch),
                    onEditFood: _editFoodEntry,
                    onDeleteFood: _deleteFoodEntry,
                    selectedDate: _selectedDate,
                    ghostSuggestion: fulfill?.suggestions[MealType.lunch],
                    onSuggestionTap: (s) => _showAddFoodDialogWithSuggestion(MealType.lunch, s),
                  ),
                  MealSection(
                    mealType: MealType.dinner,
                    foods: foodEntries
                        .where((f) => f.mealType == MealType.dinner)
                        .toList(),
                    onAddFood: () => _showAddFoodDialog(MealType.dinner),
                    onEditFood: _editFoodEntry,
                    onDeleteFood: _deleteFoodEntry,
                    selectedDate: _selectedDate,
                    ghostSuggestion: fulfill?.suggestions[MealType.dinner],
                    onSuggestionTap: (s) => _showAddFoodDialogWithSuggestion(MealType.dinner, s),
                  ),
                  MealSection(
                    mealType: MealType.snack,
                    foods: foodEntries
                        .where((f) => f.mealType == MealType.snack)
                        .toList(),
                    onAddFood: () => _showAddFoodDialog(MealType.snack),
                    onEditFood: _editFoodEntry,
                    onDeleteFood: _deleteFoodEntry,
                    selectedDate: _selectedDate,
                    ghostSuggestion: fulfill?.suggestions[MealType.snack],
                    onSuggestionTap: (s) => _showAddFoodDialogWithSuggestion(MealType.snack, s),
                  ),
                  if (timelineAsync.hasError)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Error loading: ${timelineAsync.error}',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.error),
                      ),
                    ),
                ],
              );
            }),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    final dateFormat = DateFormat('d MMM yyyy');
    final isToday = _isToday(_selectedDate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
              });
            },
          ),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isToday
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(AppIcons.calendar, size: 16, color: AppIcons.calendarColor),
                      const SizedBox(width: 4),
                      Text(
                        isToday ? "Today" : dateFormat.format(_selectedDate),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isToday ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    color:
                        isToday ? AppColors.primary : AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: isToday
                ? null
                : () {
                    setState(() {
                      _selectedDate =
                          _selectedDate.add(const Duration(days: 1));
                    });
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildUpsellBanner() {
    return FutureBuilder<bool>(
      future: UsageLimiter.isPro(),
      builder: (context, proSnapshot) {
        if (proSnapshot.data == true) return const SizedBox.shrink();

        return FutureBuilder<int>(
          future: UsageLimiter.remainingToday(),
          builder: (context, countSnapshot) {
            final remaining = countSnapshot.data ?? 3;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.purple.shade200, width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.auto_awesome,
                        color: Colors.purple, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Analysis: $remaining/${UsageLimiter.freeAiCallsPerDay} remaining today',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Upgrade to Pro for unlimited use',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => PurchaseService.buyPro(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child:
                        const Text('Upgrade', style: TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showAddFoodDialog(MealType mealType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddFoodBottomSheet(
        mealType: mealType,
        selectedDate: _selectedDate,
        onSave: (entry) async {
          final notifier = ref.read(foodEntriesNotifierProvider.notifier);
          await notifier.addFoodEntry(entry);
          if (!mounted) return;
          refreshFoodProviders(ref, _selectedDate);
          ref.invalidate(fulfillCalorieProvider(_selectedDate));
        },
      ),
    );
  }

  Future<void> _showAddFoodDialogWithSuggestion(MealType mealType, FoodSuggestion suggestion) async {
    // If from MyMeal → open LogFromMealSheet with full ingredients
    if (suggestion.myMealId != null) {
      final meal = await DatabaseService.myMeals.get(suggestion.myMealId!);
      if (meal != null && mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => LogFromMealSheet(
            meal: meal,
            onConfirm: (entry) async {
              entry.mealType = mealType;
              entry.timestamp = DateTime(
                _selectedDate.year, _selectedDate.month, _selectedDate.day,
                DateTime.now().hour, DateTime.now().minute,
              );
              final notifier = ref.read(foodEntriesNotifierProvider.notifier);
              await notifier.addFoodEntry(entry);
              if (!mounted) return;
              refreshFoodProviders(ref, _selectedDate);
              ref.invalidate(fulfillCalorieProvider(_selectedDate));
            },
          ),
        );
        return;
      }
    }

    // Fallback: open AddFoodBottomSheet with prefilled data
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddFoodBottomSheet(
        mealType: mealType,
        selectedDate: _selectedDate,
        prefillName: suggestion.name,
        prefillCalories: suggestion.calories,
        prefillProtein: suggestion.protein,
        prefillCarbs: suggestion.carbs,
        prefillFat: suggestion.fat,
        prefillServingSize: suggestion.servingSize,
        prefillServingUnit: suggestion.servingUnit,
        prefillMyMealId: suggestion.myMealId,
        onSave: (entry) async {
          final notifier = ref.read(foodEntriesNotifierProvider.notifier);
          await notifier.addFoodEntry(entry);
          if (!mounted) return;
          refreshFoodProviders(ref, _selectedDate);
          ref.invalidate(fulfillCalorieProvider(_selectedDate));
        },
      ),
    );
  }

  void _editFoodEntry(FoodEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditFoodBottomSheet(
        entry: entry,
        onSave: (updatedEntry) async {
          final notifier = ref.read(foodEntriesNotifierProvider.notifier);
          await notifier.updateFoodEntry(updatedEntry);

          if (!mounted) return;
          refreshFoodProviders(ref, _selectedDate);
          ref.invalidate(fulfillCalorieProvider(_selectedDate));
        },
      ),
    );
  }

  /// Delete food entry
  Future<void> _deleteFoodEntry(FoodEntry entry) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Do you want to delete "${entry.foodName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        final notifier = ref.read(foodEntriesNotifierProvider.notifier);
        await notifier.deleteFoodEntry(entry.id);

        if (!mounted) return;
        refreshFoodProviders(ref, _selectedDate);
        ref.invalidate(fulfillCalorieProvider(_selectedDate));

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Entry deleted successfully'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
