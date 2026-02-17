import 'package:flutter/material.dart';
import '../../../core/theme/app_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/logger.dart';
import '../providers/health_provider.dart';
import '../widgets/daily_summary_card.dart';
import '../widgets/edit_food_bottom_sheet.dart';
import '../widgets/quick_add_section.dart';
import '../widgets/meal_section.dart';
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

          // Quick Add Section (Favorite + Repeat Yesterday)
          SliverToBoxAdapter(
            child: QuickAddSection(selectedDate: _selectedDate),
          ),

          // Timeline Items + Meal Sections
          timelineAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, st) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
            data: (items) {
              if (items.isEmpty) {
                return SliverFillRemaining(
                  child: _buildEmptyState(),
                );
              }

              final foodEntries = items
                  .where((i) => i.type == 'food')
                  .map((i) => i.data as FoodEntry)
                  .toList();

              return SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (foodEntries.isNotEmpty) ...[
                      const SizedBox(height: 8),

                      // Meal sections by type
                      MealSection(
                        mealType: MealType.breakfast,
                        foods: foodEntries
                            .where((f) => f.mealType == MealType.breakfast)
                            .toList(),
                        onAddFood: () => _showAddFoodDialog(MealType.breakfast),
                        onEditFood: _editFoodEntry,
                        onDeleteFood: _deleteFoodEntry,
                        selectedDate: _selectedDate,
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
                      ),
                    ],
                  ],
                ),
              );
            },
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

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '📭',
            style: TextStyle(fontSize: 64),
          ),
          SizedBox(height: 16),
          Text(
            'No data yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                Text(
                  'Pull to refresh and I\'ll search for food photos you\'ve taken',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'or just tell me what you ate today :)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

          // ────── เช็ค mounted ก่อน invalidate ──────
          if (!mounted) return;
          refreshFoodProviders(ref, _selectedDate);
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

        // ────── เช็ค mounted ก่อน invalidate ──────
        if (!mounted) return;
        refreshFoodProviders(ref, _selectedDate);

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
