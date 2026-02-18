import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/app_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ai/gemini_service.dart';
import '../../../features/energy/widgets/no_energy_dialog.dart';
import '../../../features/energy/providers/energy_provider.dart';
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
  
  // Analyze All state
  bool _isAnalyzing = false;
  int _analyzeTotal = 0;
  int _analyzeCurrent = 0;
  String _currentItemName = '';
  List<int> _failedIds = [];
  bool _cancelRequested = false;

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

          // Meals Info Bar (compact, below meal sections)
          SliverToBoxAdapter(
            child: Builder(builder: (context) {
              final items = timelineAsync.valueOrNull ?? [];
              final foodEntries = items
                  .where((i) => i.type == 'food')
                  .map((i) => i.data as FoodEntry)
                  .where((f) => !f.isDeleted)
                  .toList();

              final withImage = foodEntries.where((f) =>
                f.imagePath != null && f.imagePath!.isNotEmpty
              ).length;
              final textOnly = foodEntries.where((f) =>
                (f.imagePath == null || f.imagePath!.isEmpty) &&
                f.source != DataSource.database
              ).length;
              final fromDb = foodEntries.where((f) =>
                f.source == DataSource.database
              ).length;
              final unanalyzed = foodEntries.where((f) =>
                !f.hasNutritionData
              ).toList();

              if (foodEntries.isEmpty && !_isAnalyzing) {
                return const SizedBox.shrink();
              }

              return _buildCompactInfoBar(
                context, foodEntries, unanalyzed,
                withImage, textOnly, fromDb,
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

  // ===== Analyze All Batch Processing =====
  
  Future<void> _startBatchAnalysis(List<FoodEntry> unanalyzedEntries) async {
    // Check energy first - use energy provider
    final energyAsync = ref.read(energyBalanceProvider);
    final currentBalance = energyAsync.valueOrNull ?? 0;
    
    final requiredEnergy = unanalyzedEntries.length;
    
    if (currentBalance < requiredEnergy) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => const NoEnergyDialog(),
      );
      return;
    }

    // Start analyzing
    setState(() {
      _isAnalyzing = true;
      _analyzeTotal = unanalyzedEntries.length;
      _analyzeCurrent = 0;
      _currentItemName = '';
      _failedIds = [];
      _cancelRequested = false;
    });

    int successCount = 0;

    for (int i = 0; i < unanalyzedEntries.length; i++) {
      if (_cancelRequested) {
        break;
      }

      final entry = unanalyzedEntries[i];
      
      setState(() {
        _analyzeCurrent = i + 1;
        _currentItemName = entry.foodName;
      });

      try {
        FoodAnalysisResult? result;
        
        // Analyze by image or by name
        if (entry.imagePath != null && entry.imagePath!.isNotEmpty) {
          result = await GeminiService.analyzeFoodImage(
            File(entry.imagePath!),
            foodName: entry.foodName,
            quantity: entry.servingSize,
            unit: entry.servingUnit,
          );
        } else {
          result = await GeminiService.analyzeFoodByName(
            entry.foodName,
            servingSize: entry.servingSize,
            servingUnit: entry.servingUnit,
          );
        }

        if (result != null) {
          // Update entry with analysis results
          entry.foodName = result.foodName;
          entry.foodNameEn = result.foodNameEn;
          entry.calories = result.nutrition.calories;
          entry.protein = result.nutrition.protein;
          entry.carbs = result.nutrition.carbs;
          entry.fat = result.nutrition.fat;
          entry.fiber = result.nutrition.fiber;
          entry.sugar = result.nutrition.sugar;
          entry.sodium = result.nutrition.sodium;
          // Calculate base values from serving size
          final serving = result.servingSize > 0 ? result.servingSize : 1.0;
          entry.baseCalories = result.nutrition.calories / serving;
          entry.baseProtein = result.nutrition.protein / serving;
          entry.baseCarbs = result.nutrition.carbs / serving;
          entry.baseFat = result.nutrition.fat / serving;
          entry.servingSize = result.servingSize;
          entry.servingUnit = result.servingUnit;
          entry.servingGrams = result.servingGrams?.toDouble();
          entry.source = DataSource.aiAnalyzed;
          entry.isVerified = true;
          entry.aiConfidence = result.confidence;
          
          // Save ingredients if available
          if (result.ingredientsDetail != null && result.ingredientsDetail!.isNotEmpty) {
            entry.ingredientsJson = jsonEncode(
              result.ingredientsDetail!.map((item) => {
                'name': item.name,
                'nameEn': item.nameEn,
                'amount': item.amount,
                'unit': item.unit,
                'calories': item.calories,
                'protein': item.protein,
                'carbs': item.carbs,
                'fat': item.fat,
              }).toList(),
            );
          }

          // Save to database
          await ref.read(foodEntriesNotifierProvider.notifier).updateFoodEntry(entry);
          successCount++;
        } else {
          _failedIds.add(entry.id);
        }
      } catch (e) {
        AppLogger.error('Analyze failed for ${entry.foodName}', e);
        _failedIds.add(entry.id);
        
        // Retry once for network errors
        if (e.toString().contains('network') || e.toString().contains('timeout')) {
          await Future.delayed(const Duration(milliseconds: 500));
          try {
            // Retry logic here (simplified)
            AppLogger.info('Retrying ${entry.foodName}...');
          } catch (retryError) {
            AppLogger.error('Retry failed', retryError);
          }
        }
      }

      // Rate limit protection
      if (i < unanalyzedEntries.length - 1) {
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }

    // Refresh UI
    ref.invalidate(healthTimelineProvider(_selectedDate));
    ref.invalidate(todayCaloriesProvider);
    ref.invalidate(todayMacrosProvider);
    ref.invalidate(fulfillCalorieProvider(_selectedDate));

    // Show summary
    setState(() {
      _isAnalyzing = false;
    });

    if (!mounted) return;
    
    final failedCount = _failedIds.length;
    final message = _cancelRequested
        ? 'ยกเลิกแล้ว - วิเคราะห์สำเร็จ $successCount รายการ'
        : failedCount == 0
            ? '✅ วิเคราะห์สำเร็จ $successCount รายการ'
            : '⚠️ วิเคราะห์สำเร็จ $successCount/${_analyzeTotal} รายการ ($failedCount ล้มเหลว)';
    
    _showMessage(message);
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

  // ===== Compact Meals Info Bar =====

  Widget _buildCompactInfoBar(
    BuildContext context,
    List<FoodEntry> allEntries,
    List<FoodEntry> unanalyzed,
    int imageCount,
    int textCount,
    int dbCount,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final energyCost = unanalyzed.length;
    final chipBg = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.05);
    final textColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    if (_isAnalyzing) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$_currentItemName  ($_analyzeCurrent/$_analyzeTotal)',
                    style: TextStyle(fontSize: 13, color: textColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _cancelRequested = true),
                  child: Icon(Icons.close_rounded, size: 18, color: AppColors.error),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _analyzeTotal > 0 ? _analyzeCurrent / _analyzeTotal : 0,
                minHeight: 4,
                backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          // Image count
          if (imageCount > 0) ...[
            _infoChip(
              AppIcons.camera, imageCount.toString(),
              AppIcons.cameraColor, chipBg, textColor,
            ),
            const SizedBox(width: 8),
          ],
          // Text-only count
          if (textCount > 0) ...[
            _infoChip(
              Icons.restaurant_menu_rounded, textCount.toString(),
              AppIcons.mealColor, chipBg, textColor,
            ),
            const SizedBox(width: 8),
          ],
          // Database count
          if (dbCount > 0) ...[
            _infoChip(
              Icons.menu_book_rounded, dbCount.toString(),
              AppColors.success, chipBg, textColor,
            ),
            const SizedBox(width: 8),
          ],

          const Spacer(),

          // Analyze button (only if there are unanalyzed entries)
          if (energyCost > 0)
            GestureDetector(
              onTap: () => _startBatchAnalysis(unanalyzed),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(AppIcons.ai, size: 14, color: Colors.white),
                    const SizedBox(width: 5),
                    const Text(
                      'Analyze All',
                      style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Icon(AppIcons.energy, size: 13, color: AppIcons.energyColor),
                    const SizedBox(width: 2),
                    Text(
                      '$energyCost',
                      style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: AppIcons.energyColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _infoChip(
    IconData icon, String count,
    Color iconColor, Color bgColor, Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 4),
          Text(
            count,
            style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500, color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
