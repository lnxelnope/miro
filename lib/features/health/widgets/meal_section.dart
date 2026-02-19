import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/ai/gemini_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/constants/enums.dart';
import '../../../core/utils/logger.dart';
import '../../../features/energy/providers/energy_provider.dart';
import '../../../features/energy/widgets/no_energy_dialog.dart';
import '../models/food_entry.dart';
import '../providers/health_provider.dart';
import '../providers/fulfill_calorie_provider.dart';
import 'food_detail_bottom_sheet.dart';
import 'edit_food_bottom_sheet.dart';
import 'ghost_meal_suggestion.dart';

class MealSection extends ConsumerStatefulWidget {
  final MealType mealType;
  final List<FoodEntry> foods;
  final VoidCallback onAddFood;
  final Function(FoodEntry) onEditFood;
  final Function(FoodEntry) onDeleteFood;
  final DateTime selectedDate;
  final MealSlotSuggestion? ghostSuggestion;
  final void Function(FoodSuggestion suggestion)? onSuggestionTap;

  const MealSection({
    super.key,
    required this.mealType,
    required this.foods,
    required this.onAddFood,
    required this.onEditFood,
    required this.onDeleteFood,
    required this.selectedDate,
    this.ghostSuggestion,
    this.onSuggestionTap,
  });

  @override
  ConsumerState<MealSection> createState() => _MealSectionState();
}

class _MealSectionState extends ConsumerState<MealSection> {
  bool _isSelectMode = false;
  final Set<int> _selectedIds = {};
  final Set<int> _dismissedIds = {};

  // Analyze selected state
  bool _isAnalyzingSelected = false;
  int _analyzeTotal = 0;
  int _analyzeCurrent = 0;
  String _currentItemName = '';
  bool _cancelAnalyze = false;

  void _exitSelectMode() {
    setState(() {
      _isSelectMode = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelect(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _isSelectMode = false;
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _selectAll() {
    final visibleFoods =
        widget.foods.where((f) => !_dismissedIds.contains(f.id)).toList();
    setState(() {
      if (_selectedIds.length == visibleFoods.length) {
        _selectedIds.clear();
        _isSelectMode = false;
      } else {
        _selectedIds.addAll(visibleFoods.map((f) => f.id));
      }
    });
  }

  Future<void> _deleteSelected() async {
    if (_selectedIds.isEmpty) return;

    final count = _selectedIds.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.delete_outline_rounded,
                color: AppColors.error, size: 24),
            const SizedBox(width: 12),
            Text('Delete $count ${count == 1 ? 'Entry' : 'Entries'}?'),
          ],
        ),
        content: Text(
          'Delete $count selected food ${count == 1 ? 'entry' : 'entries'}?',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final notifier = ref.read(foodEntriesNotifierProvider.notifier);
      for (final id in _selectedIds) {
        await notifier.deleteFoodEntry(id);
      }

      if (!mounted) return;
      _refreshProviders();

      _exitSelectMode();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted $count ${count == 1 ? 'entry' : 'entries'}'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ============================================================
  // Move Selected to Another Date
  // ============================================================
  Future<void> _moveSelected() async {
    if (_selectedIds.isEmpty) return;

    final picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );

    if (picked == null || !mounted) return;

    final notifier = ref.read(foodEntriesNotifierProvider.notifier);
    final count = _selectedIds.length;

    for (final id in _selectedIds) {
      final food = widget.foods.where((f) => f.id == id).firstOrNull;
      if (food == null) continue;

      final oldTime = food.timestamp;
      food.timestamp = DateTime(
        picked.year, picked.month, picked.day,
        oldTime.hour, oldTime.minute,
      );
      await notifier.updateFoodEntry(food);
    }

    if (!mounted) return;
    _refreshProviders(alsoRefreshDate: picked);
    _exitSelectMode();

    if (!mounted) return;
    final fmt = DateFormat('d MMM');
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Moved $count ${count == 1 ? 'entry' : 'entries'} to ${fmt.format(picked)}'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ============================================================
  // Analyze Selected Entries
  // ============================================================
  Future<void> _analyzeSelected() async {
    if (_selectedIds.isEmpty) return;

    final selectedEntries = widget.foods
        .where((f) => _selectedIds.contains(f.id))
        .where((f) => !f.hasNutritionData)
        .toList();

    if (selectedEntries.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All selected entries are already analyzed'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Check energy
    final energyAsync = ref.read(energyBalanceProvider);
    final currentBalance = energyAsync.valueOrNull ?? 0;
    final requiredEnergy = selectedEntries.length;

    if (currentBalance < requiredEnergy) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => const NoEnergyDialog(),
      );
      return;
    }

    setState(() {
      _isAnalyzingSelected = true;
      _analyzeTotal = selectedEntries.length;
      _analyzeCurrent = 0;
      _currentItemName = '';
      _cancelAnalyze = false;
    });

    int successCount = 0;
    final failedIds = <int>[];

    for (int i = 0; i < selectedEntries.length; i++) {
      if (_cancelAnalyze) break;

      final entry = selectedEntries[i];
      setState(() {
        _analyzeCurrent = i + 1;
        _currentItemName = entry.foodName;
      });

      try {
        FoodAnalysisResult? result;

        if (entry.imagePath != null && entry.imagePath!.isNotEmpty) {
          AppLogger.info('[SelectAnalyze] Analyzing image: "${entry.foodName}" (${entry.servingSize} ${entry.servingUnit}) mode: ${entry.searchMode.name}');
          result = await GeminiService.analyzeFoodImage(
            File(entry.imagePath!),
            foodName: entry.foodName,
            quantity: entry.servingSize,
            unit: entry.servingUnit,
            searchMode: entry.searchMode,
          );
        } else {
          AppLogger.info('[SelectAnalyze] Analyzing text: "${entry.foodName}" (${entry.servingSize} ${entry.servingUnit}) mode: ${entry.searchMode.name}');
          result = await GeminiService.analyzeFoodByName(
            entry.foodName,
            servingSize: entry.servingSize,
            servingUnit: entry.servingUnit,
            searchMode: entry.searchMode,
          );
        }

        if (result != null) {
          entry.foodName = result.foodName;
          entry.foodNameEn = result.foodNameEn;
          entry.calories = result.nutrition.calories;
          entry.protein = result.nutrition.protein;
          entry.carbs = result.nutrition.carbs;
          entry.fat = result.nutrition.fat;
          entry.fiber = result.nutrition.fiber;
          entry.sugar = result.nutrition.sugar;
          entry.sodium = result.nutrition.sodium;
          
          // Update searchMode based on AI response
          if (result.foodType != null) {
            if (result.foodType == 'product') {
              entry.searchMode = FoodSearchMode.product;
            } else {
              entry.searchMode = FoodSearchMode.normal;
            }
          }
          
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

          if (result.ingredientsDetail != null &&
              result.ingredientsDetail!.isNotEmpty) {
            entry.ingredientsJson = jsonEncode(
              result.ingredientsDetail!.map((item) => item.toJson()).toList(),
            );
          }

          await ref.read(foodEntriesNotifierProvider.notifier).updateFoodEntry(entry);
          successCount++;
        } else {
          failedIds.add(entry.id);
        }
      } catch (e, stackTrace) {
        AppLogger.error('[SelectAnalyze] ❌ FAILED "${entry.foodName}" — $e', stackTrace);
        failedIds.add(entry.id);
      }

      if (i < selectedEntries.length - 1) {
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }

    // Refresh
    ref.invalidate(healthTimelineProvider(widget.selectedDate));
    ref.invalidate(foodEntriesByDateProvider(widget.selectedDate));
    ref.invalidate(todayCaloriesProvider);
    ref.invalidate(todayMacrosProvider);
    ref.invalidate(fulfillCalorieProvider(widget.selectedDate));

    setState(() {
      _isAnalyzingSelected = false;
    });

    _exitSelectMode();

    if (!mounted) return;
    final failedCount = failedIds.length;
    final message = _cancelAnalyze
        ? 'Cancelled — $successCount analyzed'
        : failedCount == 0
            ? 'Analyzed $successCount ${successCount == 1 ? 'entry' : 'entries'}'
            : 'Analyzed $successCount/$_analyzeTotal ($failedCount failed)';

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: failedCount == 0 ? AppColors.success : AppColors.warning,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _deleteSingleWithUndo(FoodEntry food) {
    // 1. ลบจาก UI ทันที (ป้องกัน flash)
    setState(() => _dismissedIds.add(food.id));

    final notifier = ref.read(foodEntriesNotifierProvider.notifier);

    // 2. ลบจาก DB (async)
    notifier.deleteFoodEntry(food.id).then((_) {
      if (!mounted) return;
      _dismissedIds.remove(food.id);
      _refreshProviders();
    });

    // 3. แสดง SnackBar พร้อม Undo
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted "${food.foodName}"'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () async {
            await notifier.addFoodEntry(food);
            if (!mounted) return;
            setState(() => _dismissedIds.remove(food.id));
            _refreshProviders();
          },
        ),
      ),
    );
  }

  void _refreshProviders({DateTime? alsoRefreshDate}) {
    ref.invalidate(foodEntriesByDateProvider(widget.selectedDate));
    ref.invalidate(healthTimelineProvider(widget.selectedDate));
    ref.invalidate(todayCaloriesProvider);
    ref.invalidate(todayMacrosProvider);
    if (alsoRefreshDate != null) {
      ref.invalidate(foodEntriesByDateProvider(alsoRefreshDate));
      ref.invalidate(healthTimelineProvider(alsoRefreshDate));
    }
  }

  // ============================================================
  // Change Meal Type
  // ============================================================
  Future<void> _showChangeMealSheet(FoodEntry food) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ChangeMealBottomSheet(
        food: food,
        currentMealType: widget.mealType,
        currentDate: widget.selectedDate,
      ),
    );

    if (result == null || !mounted) return;

    final notifier = ref.read(foodEntriesNotifierProvider.notifier);
    final newMealType = result['mealType'] as MealType?;
    final newDate = result['date'] as DateTime?;

    if (newMealType != null && newMealType != food.mealType) {
      food.mealType = newMealType;
    }
    if (newDate != null) {
      final oldTime = food.timestamp;
      food.timestamp = DateTime(newDate.year, newDate.month, newDate.day,
          oldTime.hour, oldTime.minute);
    }

    await notifier.updateFoodEntry(food);
    if (!mounted) return;
    _refreshProviders(alsoRefreshDate: newDate);

    if (!mounted) return;

    final parts = <String>[];
    if (newMealType != null && newMealType != widget.mealType) {
      parts.add('Moved to ${newMealType.icon} ${newMealType.displayName}');
    }
    if (newDate != null) {
      final fmt = DateFormat('d MMM');
      parts.add('Date: ${fmt.format(newDate)}');
    }
    if (parts.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(parts.join(' · ')),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ============================================================
  // Build
  // ============================================================
  @override
  Widget build(BuildContext context) {
    // Filter out dismissed items to prevent flash error
    final visibleFoods =
        widget.foods.where((f) => !_dismissedIds.contains(f.id)).toList();
    final totalCalories =
        visibleFoods.fold<double>(0, (sum, f) => sum + f.calories);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
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
          // Header
          _isSelectMode
              ? _buildSelectModeHeader(isDark)
              : _buildNormalHeader(context, totalCalories),

          const SizedBox(height: 12),

          // Foods list
          if (visibleFoods.isEmpty && widget.ghostSuggestion != null)
            GhostMealSuggestion(
              suggestion: widget.ghostSuggestion!,
              onTap: widget.onAddFood,
              onSuggestionTap: widget.onSuggestionTap,
            )
          else if (visibleFoods.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No entries yet',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ...visibleFoods
                .map((food) => _buildFoodItem(context, food, isDark)),
        ],
      ),
    );
  }

  // ============================================================
  // Headers
  // ============================================================
  Widget _buildNormalHeader(BuildContext context, double totalCalories) {
    // Get budget for this meal from ghost suggestion (if available)
    final budget = widget.ghostSuggestion?.allocatedCalories;
    
    return Row(
      children: [
        Icon(
          widget.mealType.icon,
          color: widget.mealType.iconColor,
          size: 24,
        ),
        const SizedBox(width: 10),
        Text(
          widget.mealType.displayName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.health.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            budget != null && budget > 0
                ? '${totalCalories.toInt()} / ${budget.toInt()} kcal'
                : '${totalCalories.toInt()} kcal',
            style: const TextStyle(
              color: AppColors.health,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, size: 24),
          color: AppColors.primary,
          onPressed: widget.onAddFood,
        ),
      ],
    );
  }

  Widget _buildSelectModeHeader(bool isDark) {
    final visibleCount =
        widget.foods.where((f) => !_dismissedIds.contains(f.id)).length;
    final allSelected = _selectedIds.length == visibleCount;

    // Count how many selected entries need analysis
    final unanalyzedCount = widget.foods
        .where((f) => _selectedIds.contains(f.id) && !f.hasNutritionData)
        .length;

    if (_isAnalyzingSelected) {
      return Column(
        children: [
          Row(
            children: [
              const SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$_analyzeCurrent/$_analyzeTotal  $_currentItemName',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _cancelAnalyze = true),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  foregroundColor: AppColors.error,
                ),
                child: const Text('Cancel', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _analyzeTotal > 0 ? _analyzeCurrent / _analyzeTotal : 0,
              minHeight: 4,
              backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        // Close
        IconButton(
          icon: const Icon(Icons.close_rounded, size: 22),
          onPressed: _exitSelectMode,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 6),
        // Count badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '${_selectedIds.length}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppColors.primary,
            ),
          ),
        ),
        const Spacer(),
        // Select All / Deselect
        IconButton(
          onPressed: _selectAll,
          icon: Icon(
            allSelected ? Icons.deselect : Icons.select_all_rounded,
            size: 22,
          ),
          tooltip: allSelected ? 'Deselect all' : 'Select all',
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 8),
        // Move to another date
        IconButton(
          onPressed: _selectedIds.isNotEmpty ? _moveSelected : null,
          icon: const Icon(Icons.calendar_month_rounded, size: 22),
          color: AppColors.primary,
          tooltip: 'Move to date',
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 8),
        // Analyze selected
        IconButton(
          onPressed: _selectedIds.isNotEmpty && unanalyzedCount > 0
              ? _analyzeSelected
              : null,
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 22),
              if (unanalyzedCount > 0)
                Positioned(
                  right: -6,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.warning,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$unanalyzedCount',
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          color: AppColors.warning,
          tooltip: 'Analyze selected',
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 8),
        // Delete
        IconButton(
          onPressed: _selectedIds.isNotEmpty ? _deleteSelected : null,
          icon: const Icon(Icons.delete_outline_rounded, size: 22),
          color: AppColors.error,
          tooltip: 'Delete',
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  // ============================================================
  // Food Item (swipe left = delete, swipe right = change meal/date)
  // ============================================================
  Widget _buildFoodItem(BuildContext context, FoodEntry food, bool isDark) {
    final isSelected = _selectedIds.contains(food.id);

    Widget item = _buildFoodItemContent(context, food, isDark, isSelected);

    if (!_isSelectMode) {
      item = Dismissible(
        key: ValueKey(food.id),
        direction: DismissDirection.horizontal,
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            _showChangeMealSheet(food);
            return false;
          }
          // Swipe left → dismiss directly (undo via SnackBar)
          return true;
        },
        onDismissed: (_) => _deleteSingleWithUndo(food),
        // Swipe RIGHT background (startToEnd) → change meal
        background: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.9),
                AppColors.primary
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 22),
              SizedBox(width: 8),
              Text(
                'Move',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        // Swipe LEFT background (endToStart) → delete
        secondaryBackground: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppColors.error,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
            ],
          ),
        ),
        child: item,
      );
    }

    return item;
  }

  Widget _buildFoodItemContent(
    BuildContext context,
    FoodEntry food,
    bool isDark,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        if (_isSelectMode) {
          _toggleSelect(food.id);
        } else {
          _showFoodDetail(context, food);
        }
      },
      onLongPress: () {
        if (!_isSelectMode) {
          HapticFeedback.mediumImpact();
          setState(() {
            _isSelectMode = true;
            _selectedIds.add(food.id);
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.error.withValues(alpha: 0.08)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.error.withValues(alpha: 0.4)
                : Theme.of(context).dividerColor.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox (in select mode) or Image/icon
            if (_isSelectMode) ...[
              SizedBox(
                width: 40,
                height: 40,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.error : Colors.transparent,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.error
                            : isDark
                                ? Colors.white30
                                : AppColors.textTertiary,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded,
                            size: 16, color: Colors.white)
                        : null,
                  ),
                ),
              ),
            ] else ...[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.health.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: food.imagePath != null &&
                        File(food.imagePath!).existsSync()
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(food.imagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
                        ),
                      )
                    : _buildPlaceholderIcon(),
              ),
            ],
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.foodName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // Food/Product toggle icons
                      _buildSearchModeIcon(
                        context,
                        food,
                        FoodSearchMode.normal,
                        isDark,
                      ),
                      const SizedBox(width: 8),
                      _buildSearchModeIcon(
                        context,
                        food,
                        FoodSearchMode.product,
                        isDark,
                      ),
                      const SizedBox(width: 8),
                      // Serving size
                      Text(
                        '${food.servingSize % 1 == 0 ? food.servingSize.toInt() : food.servingSize} ${food.servingUnit}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white38 : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Calories
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${food.calories.toInt()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'kcal',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return const Center(
      child: Icon(
        Icons.restaurant,
        color: AppColors.health,
        size: 20,
      ),
    );
  }

  Widget _buildSearchModeIcon(
    BuildContext context,
    FoodEntry food,
    FoodSearchMode mode,
    bool isDark,
  ) {
    final isActive = food.searchMode == mode;
    final color = isActive
        ? (mode == FoodSearchMode.normal
            ? AppColors.health
            : Colors.orange)
        : (isDark ? Colors.white.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.3));

    return GestureDetector(
      onTap: () => _handleSearchModeToggle(context, food, mode),
      child: Icon(
        mode.icon,
        size: 16,
        color: color,
      ),
    );
  }

  Future<void> _handleSearchModeToggle(
    BuildContext context,
    FoodEntry food,
    FoodSearchMode newMode,
  ) async {
    // If already this mode, do nothing
    if (food.searchMode == newMode) return;

    // If entry is not yet analyzed, just update the searchMode
    if (!food.hasNutritionData) {
      food.searchMode = newMode;
      await ref.read(foodEntriesNotifierProvider.notifier).updateFoodEntry(food);
      setState(() {});
      return;
    }

    // Entry is already analyzed - show confirmation dialog for re-scan
    final currentModeName = food.searchMode.displayName;
    final newModeName = newMode.displayName;

    if (!context.mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.swap_horiz_rounded, color: AppColors.primary, size: 24),
            const SizedBox(width: 12),
            Text('Switch to $newModeName mode?'),
          ],
        ),
        content: Text(
          'This item was analyzed as $currentModeName.\n\n'
          'Re-analyzing as $newModeName will use 1 Energy.\n\n'
          'Continue?',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Re-analyze'),
                const SizedBox(width: 4),
                Icon(AppIcons.energy, size: 14, color: AppIcons.energyColor),
                const Text(' 1'),
              ],
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      // Update mode and trigger re-analysis
      food.searchMode = newMode;
      await ref.read(foodEntriesNotifierProvider.notifier).updateFoodEntry(food);
      
      // Trigger analysis with the new mode
      await _analyzeSingleEntry(context, food);
      
      setState(() {});
    }
  }

  Future<void> _analyzeSingleEntry(BuildContext context, FoodEntry entry) async {
    // Check energy
    final energyAsync = ref.read(energyBalanceProvider);
    final currentBalance = energyAsync.valueOrNull ?? 0;

    if (currentBalance < 1) {
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => const NoEnergyDialog(),
      );
      return;
    }

    // Show loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Analyzing as ${entry.searchMode.displayName}...',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    try {
      FoodAnalysisResult? result;

      if (entry.imagePath != null && entry.imagePath!.isNotEmpty) {
        AppLogger.info('[ReAnalyze] Analyzing image: "${entry.foodName}" as ${entry.searchMode.name}');
        result = await GeminiService.analyzeFoodImage(
          File(entry.imagePath!),
          foodName: entry.foodName,
          quantity: entry.servingSize,
          unit: entry.servingUnit,
          searchMode: entry.searchMode,
        );
      } else {
        AppLogger.info('[ReAnalyze] Analyzing text: "${entry.foodName}" as ${entry.searchMode.name}');
        result = await GeminiService.analyzeFoodByName(
          entry.foodName,
          servingSize: entry.servingSize,
          servingUnit: entry.servingUnit,
          searchMode: entry.searchMode,
        );
      }

      if (result != null) {
        entry.foodName = result.foodName;
        entry.foodNameEn = result.foodNameEn;
        entry.calories = result.nutrition.calories;
        entry.protein = result.nutrition.protein;
        entry.carbs = result.nutrition.carbs;
        entry.fat = result.nutrition.fat;
        entry.fiber = result.nutrition.fiber;
        entry.sugar = result.nutrition.sugar;
        entry.sodium = result.nutrition.sodium;
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

        // Update searchMode based on AI response
        if (result.foodType != null) {
          if (result.foodType == 'product') {
            entry.searchMode = FoodSearchMode.product;
          } else {
            entry.searchMode = FoodSearchMode.normal;
          }
        }

        if (result.ingredientsDetail != null &&
            result.ingredientsDetail!.isNotEmpty) {
          entry.ingredientsJson = jsonEncode(
            result.ingredientsDetail!.map((item) => item.toJson()).toList(),
          );
        }

        await ref.read(foodEntriesNotifierProvider.notifier).updateFoodEntry(entry);

        // Refresh providers
        ref.invalidate(healthTimelineProvider(widget.selectedDate));
        ref.invalidate(foodEntriesByDateProvider(widget.selectedDate));
        ref.invalidate(todayCaloriesProvider);
        ref.invalidate(todayMacrosProvider);

        if (!mounted) return;
        Navigator.pop(context); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Re-analyzed as ${entry.searchMode.displayName}'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        if (!mounted) return;
        Navigator.pop(context); // Close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Analysis failed'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error('[ReAnalyze] Error', e, stackTrace);

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // ============================================================
  // Detail & Edit
  // ============================================================
  void _showFoodDetail(BuildContext context, FoodEntry food) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => FoodDetailBottomSheet(
        entry: food,
        selectedDate: widget.selectedDate,
      ),
    ).then((result) {
      if (result != null && result is Map) {
        if (result['action'] == 'edit') {
          final entry = result['entry'] as FoodEntry;
          _showEditSheet(context, entry);
        }
      }
    });
  }

  void _showEditSheet(BuildContext context, FoodEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => EditFoodBottomSheet(
        entry: entry,
        onSave: (updatedEntry) async {
          final notifier = ref.read(foodEntriesNotifierProvider.notifier);
          await notifier.updateFoodEntry(updatedEntry);
          _refreshProviders();
        },
      ),
    );
  }
}

// ============================================================
// Bottom Sheet: Change Meal Type + Move Date
// ============================================================
class _ChangeMealBottomSheet extends StatefulWidget {
  final FoodEntry food;
  final MealType currentMealType;
  final DateTime currentDate;

  const _ChangeMealBottomSheet({
    required this.food,
    required this.currentMealType,
    required this.currentDate,
  });

  @override
  State<_ChangeMealBottomSheet> createState() => _ChangeMealBottomSheetState();
}

class _ChangeMealBottomSheetState extends State<_ChangeMealBottomSheet> {
  late MealType _selectedMealType;
  DateTime? _newDate;

  @override
  void initState() {
    super.initState();
    _selectedMealType = widget.currentMealType;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() => _newDate = picked);
    }
  }

  bool get _hasChanges {
    return _selectedMealType != widget.currentMealType || _newDate != null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('d MMM yyyy');

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
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

            // Food name
            Row(
              children: [
                const Icon(Icons.swap_horiz_rounded,
                    color: AppColors.primary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.food.foodName,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Meal Type Selection
            const Text(
              'Change Meal Type',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: MealType.values.map((type) {
                final isSelected = _selectedMealType == type;
                final isCurrent = widget.currentMealType == type;
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
                                  : Colors.grey.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
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
                              type.displayName,
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
            const SizedBox(height: 20),

            // Move to Date
            const Text(
              'Move to Another Date',
              style: TextStyle(
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
                          : Colors.grey.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
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
                          : 'Current: ${dateFormat.format(widget.currentDate)}',
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
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'Cancel Date Change',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.error,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _hasChanges
                        ? () {
                            Navigator.pop(context, {
                              'mealType':
                                  _selectedMealType != widget.currentMealType
                                      ? _selectedMealType
                                      : null,
                              'date': _newDate,
                            });
                          }
                        : null,
                    icon: const Icon(Icons.check_rounded, size: 20),
                    label: const Text('Confirm'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          isDark ? Colors.white12 : Colors.grey.shade200,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
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
