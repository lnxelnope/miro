import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../features/energy/widgets/quest_bar.dart';
import '../../../core/utils/logger.dart';
import '../providers/health_provider.dart';
import '../providers/fulfill_calorie_provider.dart';
import '../../../core/widgets/analyze_bar.dart';
import '../widgets/daily_summary_card.dart';
import '../widgets/edit_food_bottom_sheet.dart';
import '../widgets/log_from_meal_sheet.dart';
import '../widgets/meal_section.dart';
import '../../../core/database/database_service.dart';
import '../models/food_entry.dart';
import '../../../core/constants/enums.dart';
import '../widgets/add_food_bottom_sheet.dart';
import '../../scanner/providers/scanner_provider.dart';
import '../../../core/services/usage_limiter.dart';
import '../../../core/services/purchase_service.dart';
import '../../profile/providers/profile_provider.dart';
import '../providers/analysis_provider.dart';

class HealthTimelineTab extends ConsumerStatefulWidget {
  const HealthTimelineTab({super.key});

  @override
  ConsumerState<HealthTimelineTab> createState() => _HealthTimelineTabState();
}

class _HealthTimelineTabState extends ConsumerState<HealthTimelineTab> {
  DateTime _selectedDate = dateOnly(DateTime.now());

  // Scanning state
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();

    // Auto-trigger disabled: entries stay at 0 kcal until user manually
    // presses "Analyze All". Not every scanned image is food the user ate.
  }

  @override
  Widget build(BuildContext context) {
    final timelineAsync = ref.watch(healthTimelineProvider(_selectedDate));
    final profile = ref.watch(profileNotifierProvider).valueOrNull;
    final suggestionsEnabled = profile?.mealSuggestionsEnabled ?? false;
    final fulfillAsync = suggestionsEnabled
        ? ref.watch(fulfillCalorieProvider(_selectedDate))
        : const AsyncValue<FulfillCalorieState?>.data(null);

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _scanForFood,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Upsell Banner
                SliverToBoxAdapter(
                  child: _buildUpsellBanner(),
                ),

                // Quest Bar
                const SliverToBoxAdapter(
                  child: QuestBar(),
                ),

                // Daily Summary Card
                SliverToBoxAdapter(
                  child: DailySummaryCard(
                    selectedDate: _selectedDate,
                    onDateChanged: (date) {
                      setState(() => _selectedDate = date);
                    },
                  ),
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
                        const SizedBox(height: AppSpacing.sm),
                        MealSection(
                          mealType: MealType.breakfast,
                          foods: foodEntries
                              .where((f) => f.mealType == MealType.breakfast)
                              .toList(),
                          onAddFood: () =>
                              _showAddFoodDialog(MealType.breakfast),
                          onEditFood: _editFoodEntry,
                          onDeleteFood: _deleteFoodEntry,
                          selectedDate: _selectedDate,
                          ghostSuggestion:
                              fulfill?.suggestions[MealType.breakfast],
                          onSuggestionTap: (s) =>
                              _showAddFoodDialogWithSuggestion(
                                  MealType.breakfast, s),
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
                          onSuggestionTap: (s) =>
                              _showAddFoodDialogWithSuggestion(
                                  MealType.lunch, s),
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
                          ghostSuggestion:
                              fulfill?.suggestions[MealType.dinner],
                          onSuggestionTap: (s) =>
                              _showAddFoodDialogWithSuggestion(
                                  MealType.dinner, s),
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
                          onSuggestionTap: (s) =>
                              _showAddFoodDialogWithSuggestion(
                                  MealType.snack, s),
                        ),
                        if (timelineAsync.hasError)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg),
                            child: Text(
                              L10n.of(context)!
                                  .errorLoading(timelineAsync.error.toString()),
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
                  child: SizedBox(height: AppSpacing.xxxxl * 2.5),
                ),
              ],
            ),
          ),
        ),

        // Analyze Bar — fixed at bottom, above tab bar
        AnalyzeBar(
          selectedDate: _selectedDate,
          onAnalyze: _startBatchAnalysis,
        ),
      ],
    );
  }

  Future<void> _scanForFood() async {
    if (_isScanning) return;
    setState(() => _isScanning = true);
    try {
      AppLogger.info(
          'Scanning for food images on date: ${_selectedDate.toString()}');
      final count = await ref
          .read(galleryScanNotifierProvider.notifier)
          .scanNewImages(specificDate: _selectedDate);
      AppLogger.info(
          'Scan complete - found: $count entries for ${_selectedDate.toString()}');

      refreshFoodProviders(ref, _selectedDate);

      if (!mounted) return;
      if (count > 0) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.of(context)!.scanFoundNewImages(
                count, DateFormat('d MMM yyyy').format(_selectedDate))),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.of(context)!.scanNoNewImages(
                DateFormat('d MMM yyyy').format(_selectedDate))),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Scan failed', e);
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
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
              margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              padding: AppSpacing.paddingLg,
              decoration: BoxDecoration(
                color: AppColors.premiumLight,
                borderRadius: AppRadius.lg,
                border: Border.all(
                    color: AppColors.premium.withValues(alpha: 0.3),
                    width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    padding: AppSpacing.paddingSm,
                    decoration: BoxDecoration(
                      color: AppColors.premium.withValues(alpha: 0.1),
                      borderRadius: AppRadius.sm,
                    ),
                    child: const Icon(Icons.auto_awesome,
                        color: AppColors.premium, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          L10n.of(context)!.aiAnalysisRemaining(
                              remaining, UsageLimiter.freeAiCallsPerDay),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.premium,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          L10n.of(context)!.upgradeToProUnlimited,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => PurchaseService.buyPro(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.premium,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.xl,
                      ),
                    ),
                    child: Text(L10n.of(context)!.upgrade,
                        style: const TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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

  Future<void> _showAddFoodDialogWithSuggestion(
      MealType mealType, FoodSuggestion suggestion) async {
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
                _selectedDate.year,
                _selectedDate.month,
                _selectedDate.day,
                DateTime.now().hour,
                DateTime.now().minute,
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
        title: Text(L10n.of(context)!.confirmDelete),
        content: Text(L10n.of(context)!.confirmDeleteMessage(entry.foodName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(L10n.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: Text(L10n.of(context)!.delete),
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
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.of(context)!.entryDeletedSuccess),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.of(context)!.entryDeleteError(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // ===== Analyze All Batch Processing with Auto-Continue Queue =====

  void _startBatchAnalysis(List<FoodEntry> initialEntries) {
    if (initialEntries.isEmpty) return;
    ref.read(analysisProvider.notifier).enqueue(
          entries: initialEntries,
          selectedDate: _selectedDate,
        );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
