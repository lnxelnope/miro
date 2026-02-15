import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/enums.dart';
import '../../../core/data/thai_food_database.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../core/utils/logger.dart';
import '../providers/health_provider.dart';
import '../providers/my_meal_provider.dart';
import '../widgets/daily_summary_card.dart';
import '../widgets/meal_section.dart';
import '../widgets/edit_food_bottom_sheet.dart';
import '../models/food_entry.dart';
import '../../scanner/providers/scanner_provider.dart';

class HealthDietTab extends ConsumerStatefulWidget {
  const HealthDietTab({super.key});

  @override
  ConsumerState<HealthDietTab> createState() => _HealthDietTabState();
}

class _HealthDietTabState extends ConsumerState<HealthDietTab> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final foodsAsync = ref.watch(foodEntriesByDateProvider(_selectedDate));

    return RefreshIndicator(
      onRefresh: () async {
        AppLogger.info('Pull-to-refresh starting...');
        // 1. Refresh existing data
        ref.invalidate(foodEntriesByDateProvider(_selectedDate));
        // 2. Trigger auto-scan for new images
        try {
          AppLogger.info('Starting to scan new images from Gallery...');
          final count = await ref.read(galleryScanNotifierProvider.notifier).scanNewImages();
          AppLogger.info('Scan complete - found: $count entries');
          if (count > 0) {
            ref.invalidate(foodEntriesByDateProvider(_selectedDate));
          }
        } catch (e) {
          AppLogger.error('Scan failed', e);
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Daily Summary — Pass selectedDate to summarize by selected date
            DailySummaryCard(selectedDate: _selectedDate),

            // Date Selector
            _buildDateSelector(),

            // Meals
            foodsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
              error: (e, st) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error: $e'),
              ),
              data: (foods) => Column(
                children: [
                  MealSection(
                    mealType: MealType.breakfast,
                    foods: foods.where((f) => f.mealType == MealType.breakfast).toList(),
                    onAddFood: () => _showAddFoodDialog(MealType.breakfast),
                    onEditFood: _showEditFoodDialog,
                    onDeleteFood: _deleteFoodEntry,
                    selectedDate: _selectedDate,
                  ),
                  MealSection(
                    mealType: MealType.lunch,
                    foods: foods.where((f) => f.mealType == MealType.lunch).toList(),
                    onAddFood: () => _showAddFoodDialog(MealType.lunch),
                    onEditFood: _showEditFoodDialog,
                    onDeleteFood: _deleteFoodEntry,
                    selectedDate: _selectedDate,
                  ),
                  MealSection(
                    mealType: MealType.dinner,
                    foods: foods.where((f) => f.mealType == MealType.dinner).toList(),
                    onAddFood: () => _showAddFoodDialog(MealType.dinner),
                    onEditFood: _showEditFoodDialog,
                    onDeleteFood: _deleteFoodEntry,
                    selectedDate: _selectedDate,
                  ),
                  MealSection(
                    mealType: MealType.snack,
                    foods: foods.where((f) => f.mealType == MealType.snack).toList(),
                    onAddFood: () => _showAddFoodDialog(MealType.snack),
                    onEditFood: _showEditFoodDialog,
                    onDeleteFood: _deleteFoodEntry,
                    selectedDate: _selectedDate,
                  ),
                ],
              ),
            ),
            
            // Bottom padding
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // ===== Date Selector =====
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
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '📅 ${isToday ? "Today" : dateFormat.format(_selectedDate)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isToday ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    color: isToday ? AppColors.primary : AppColors.textSecondary,
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
                      _selectedDate = _selectedDate.add(const Duration(days: 1));
                    });
                  },
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
          ref.invalidate(foodEntriesByDateProvider(_selectedDate));
          ref.invalidate(todayCaloriesProvider);
          ref.invalidate(todayMacrosProvider);
        },
      ),
    );
  }

  void _showEditFoodDialog(FoodEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditFoodBottomSheet(
        entry: entry,
        onSave: (updatedEntry) async {
          final notifier = ref.read(foodEntriesNotifierProvider.notifier);
          await notifier.updateFoodEntry(updatedEntry);
          ref.invalidate(foodEntriesByDateProvider(_selectedDate));
          ref.invalidate(todayCaloriesProvider);
          ref.invalidate(todayMacrosProvider);
        },
      ),
    );
  }

  Future<void> _deleteFoodEntry(FoodEntry entry) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete entry?'),
        content: Text('Do you want to delete "${entry.foodName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        final notifier = ref.read(foodEntriesNotifierProvider.notifier);
        await notifier.deleteFoodEntry(entry.id);
        
        // Refresh providers เพื่อ refresh UI
        refreshFoodProviders(ref, _selectedDate);
        
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Entry deleted successfully'),
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

// ============================================
// ADD FOOD BOTTOM SHEET
// ============================================

class AddFoodBottomSheet extends ConsumerStatefulWidget {
  final MealType mealType;
  final Function(FoodEntry) onSave;
  final DateTime? selectedDate; // Selected date (if not specified = today)

  const AddFoodBottomSheet({
    super.key,
    required this.mealType,
    required this.onSave,
    this.selectedDate,
  });

  @override
  ConsumerState<AddFoodBottomSheet> createState() => _AddFoodBottomSheetState();
}

/// ข้อมูล suggestion สำหรับ autocomplete
class _FoodSuggestion {
  final String name;
  final String? nameEn;
  final String source; // 'meal', 'ingredient', 'thai_db'
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double servingSize;
  final String servingUnit;
  final int? myMealId; // ถ้ามาจาก MyMeal

  const _FoodSuggestion({
    required this.name,
    this.nameEn,
    required this.source,
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.servingSize = 1,
    this.servingUnit = 'serving',
    this.myMealId,
  });
}

class _AddFoodBottomSheetState extends ConsumerState<AddFoodBottomSheet> {
  final _nameController = TextEditingController();
  final _servingSizeController = TextEditingController(text: '1');
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController(text: '0');
  final _carbsController = TextEditingController(text: '0');
  final _fatController = TextEditingController(text: '0');
  final _nameFocusNode = FocusNode();
  
  String _servingUnit = 'serving';
  late MealType _selectedMealType;
  bool _filledFromDb = false; // ถูก auto-fill จาก DB หรือยัง
  int? _selectedMyMealId;

  // ---- Base values for recalculating when amount changes ----
  double _baseCalories = 0;   // kcal per 1 unit
  double _baseProtein = 0;
  double _baseCarbs = 0;
  double _baseFat = 0;

  @override
  void initState() {
    super.initState();
    _selectedMealType = widget.mealType;
    _servingSizeController.addListener(_onServingSizeChanged);
  }

  @override
  void dispose() {
    _servingSizeController.removeListener(_onServingSizeChanged);
    _nameController.dispose();
    _servingSizeController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  /// เมื่อเปลี่ยนหน่วย → convert ปริมาณ (ถ้าแปลงได้) หรือ recalculate nutrition
  void _onUnitChanged(String newUnit) {
    final oldUnit = _servingUnit;
    final oldQty = double.tryParse(_servingSizeController.text) ?? 0;

    if (_filledFromDb && _baseCalories > 0 && oldQty > 0) {
      final result = UnitConverter.convertServing(
        oldQty: oldQty,
        oldUnit: oldUnit,
        newUnit: newUnit,
      );

      // Temporarily disable listener
      _servingSizeController.removeListener(_onServingSizeChanged);

      if (result.converted) {
        // Unit conversion successful (e.g. g → lbs) → change amount, nutrition stays same
        // But base per unit must change according to new unit
        final factor = result.newQty / oldQty; // e.g. 200g→0.44lbs = 0.0022
        _baseCalories = _baseCalories / factor;
        _baseProtein  = _baseProtein  / factor;
        _baseCarbs    = _baseCarbs    / factor;
        _baseFat      = _baseFat      / factor;

        setState(() {
          _servingUnit = newUnit;
          _servingSizeController.text = result.newQty < 10
              ? result.newQty.toStringAsFixed(2)
              : result.newQty.round().toString();
        });
      } else {
        // Cannot convert (e.g. piece → g) → keep quantity, just change unit
        setState(() {
          _servingUnit = newUnit;
        });
      }

      _servingSizeController.addListener(_onServingSizeChanged);
    } else {
      setState(() {
        _servingUnit = newUnit;
      });
    }
  }

  /// When amount changes → recalculate kcal/macro proportionally
  void _onServingSizeChanged() {
    if (!_filledFromDb || _baseCalories <= 0) return;
    final newServing = double.tryParse(_servingSizeController.text) ?? 0;
    if (newServing <= 0) return;

    setState(() {
      _caloriesController.text = (_baseCalories * newServing).round().toString();
      _proteinController.text = (_baseProtein * newServing).round().toString();
      _carbsController.text = (_baseCarbs * newServing).round().toString();
      _fatController.text = (_baseFat * newServing).round().toString();
    });
  }

  /// Search suggestions from My Meals + Ingredients + Thai Food DB
  List<_FoodSuggestion> _searchSuggestions(String query) {
    if (query.trim().isEmpty) return [];
    final q = query.trim().toLowerCase();
    final results = <_FoodSuggestion>[];

    // 1. Search from My Meals
    final mealsAsync = ref.read(allMyMealsProvider);
    mealsAsync.whenData((meals) {
      for (final meal in meals) {
        if (meal.name.toLowerCase().contains(q) ||
            (meal.nameEn?.toLowerCase().contains(q) ?? false)) {
          results.add(_FoodSuggestion(
            name: meal.name,
            nameEn: meal.nameEn,
            source: 'meal',
            calories: meal.totalCalories,
            protein: meal.totalProtein,
            carbs: meal.totalCarbs,
            fat: meal.totalFat,
            servingSize: meal.parsedServingSize,
            servingUnit: meal.parsedServingUnit,
            myMealId: meal.id,
          ));
        }
      }
    });

    // 2. Search from Ingredients (personal ingredients)
    final ingredientsAsync = ref.read(allIngredientsProvider);
    ingredientsAsync.whenData((ingredients) {
      for (final ing in ingredients) {
        if (ing.name.toLowerCase().contains(q) ||
            (ing.nameEn?.toLowerCase().contains(q) ?? false)) {
          results.add(_FoodSuggestion(
            name: ing.name,
            nameEn: ing.nameEn,
            source: 'ingredient',
            calories: ing.caloriesPerBase,
            protein: ing.proteinPerBase,
            carbs: ing.carbsPerBase,
            fat: ing.fatPerBase,
            servingSize: ing.baseAmount,
            servingUnit: ing.baseUnit,
          ));
        }
      }
    });

    // 3. Search from Thai Food Database (hardcode)
    final thaiResults = ThaiFoodDatabase.search(q);
    for (final entry in thaiResults.entries) {
      // Don't add if name already exists
      if (!results.any((r) => r.name == entry.key)) {
        results.add(_FoodSuggestion(
          name: entry.key,
          source: 'thai_db',
          calories: entry.value.calories,
          protein: entry.value.protein,
          carbs: entry.value.carbs,
          fat: entry.value.fat,
          servingSize: 1,
          servingUnit: 'serving',
        ));
      }
    }

    // Limit to 15 items
    if (results.length > 15) return results.sublist(0, 15);
    return results;
  }

  /// เมื่อเลือก suggestion → auto-fill ข้อมูล + คำนวณ base per unit
  void _onSuggestionSelected(_FoodSuggestion suggestion) {
    // ปิด listener ชั่วคราวเพื่อไม่ให้ recalc ระหว่าง fill
    _servingSizeController.removeListener(_onServingSizeChanged);

    final servingSize = suggestion.servingSize > 0 ? suggestion.servingSize : 1.0;

    // Calculate base per 1 unit (kcal per 1 piece, 1 plate, etc.)
    _baseCalories = suggestion.calories / servingSize;
    _baseProtein  = suggestion.protein  / servingSize;
    _baseCarbs    = suggestion.carbs    / servingSize;
    _baseFat      = suggestion.fat      / servingSize;

    setState(() {
      _nameController.text = suggestion.name;
      _servingSizeController.text = servingSize == servingSize.roundToDouble()
          ? servingSize.round().toString()
          : servingSize.toStringAsFixed(1);
      _servingUnit = UnitConverter.ensureValid(suggestion.servingUnit);
      _caloriesController.text = suggestion.calories.round().toString();
      _proteinController.text = suggestion.protein.round().toString();
      _carbsController.text = suggestion.carbs.round().toString();
      _fatController.text = suggestion.fat.round().toString();
      _filledFromDb = true;
      _selectedMyMealId = suggestion.myMealId;
    });

    // Re-enable listener
    _servingSizeController.addListener(_onServingSizeChanged);
    // Close keyboard
    _nameFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
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
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Title
            const Text(
              '🍽️ Add Food',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Food Name — Autocomplete from My Meals + Ingredients + Thai DB
            LayoutBuilder(
              builder: (context, constraints) {
                return Autocomplete<_FoodSuggestion>(
                  optionsBuilder: (textEditingValue) {
                    return _searchSuggestions(textEditingValue.text);
                  },
                  displayStringForOption: (option) => option.name,
                  onSelected: _onSuggestionSelected,
                  optionsMaxHeight: 250,
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(12),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: constraints.maxWidth,
                            maxHeight: 250,
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final option = options.elementAt(index);
                              return ListTile(
                                dense: true,
                                leading: Icon(
                                  option.source == 'meal'
                                      ? Icons.restaurant_menu
                                      : option.source == 'ingredient'
                                          ? Icons.egg_alt
                                          : Icons.menu_book,
                                  size: 20,
                                  color: option.source == 'meal'
                                      ? AppColors.health
                                      : option.source == 'ingredient'
                                          ? Colors.orange
                                          : AppColors.primary,
                                ),
                                title: Text(
                                  option.name,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                subtitle: Text(
                                  '${option.calories.round()} kcal · '
                                  '${option.source == 'meal' ? 'My Meal' : option.source == 'ingredient' ? 'Ingredient' : 'Database'}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                                onTap: () => onSelected(option),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
                    // Sync controllers: When Autocomplete creates its controller
                    // We need to sync with our _nameController
                    textController.addListener(() {
                      if (_nameController.text != textController.text) {
                        _nameController.text = textController.text;
                        // If typing manually (not selected from list) → reset filled flag
                        if (_filledFromDb) {
                          setState(() {
                            _filledFromDb = false;
                            _selectedMyMealId = null;
                          });
                        }
                      }
                    });
                    return TextField(
                      controller: textController,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: 'Food Name *',
                        hintText: 'Type to search e.g. fried rice, papaya salad',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: textController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  textController.clear();
                                  _nameController.clear();
                                  setState(() {
                                    _filledFromDb = false;
                                    _selectedMyMealId = null;
                                    _baseCalories = 0;
                                    _baseProtein = 0;
                                    _baseCarbs = 0;
                                    _baseFat = 0;
                                    _caloriesController.text = '';
                                    _proteinController.text = '0';
                                    _carbsController.text = '0';
                                    _fatController.text = '0';
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                );
              },
            ),
            if (_filledFromDb) ...[
              const SizedBox(height: 4),
              Text(
                _selectedMyMealId != null
                    ? '✅ Selected from My Meal — nutrition data auto-filled'
                    : '✅ Found in database — nutrition data auto-filled',
                style: const TextStyle(fontSize: 11, color: AppColors.success),
              ),
            ] else if (_nameController.text.isNotEmpty) ...[
              const SizedBox(height: 4),
              const Text(
                '💡 Not found in database — save first then use Gemini to analyze later',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: 16),
            
            // Serving size
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _servingSizeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    initialValue: _servingUnit,
                    decoration: InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: UnitConverter.allDropdownItems,
                    onChanged: (value) {
                      if (value == null || value.isEmpty) return;
                      _onUnitChanged(value);
                    },
                    style: const TextStyle(color: Colors.black),
                    dropdownColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Nutrition
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _filledFromDb
                        ? 'Nutrition (auto-calculated by amount)'
                        : 'Nutrition (enter 0 if unknown)',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _caloriesController,
                    keyboardType: TextInputType.number,
                    readOnly: _filledFromDb,
                    decoration: InputDecoration(
                      labelText: 'Calories (kcal)',
                      prefixText: '🔥 ',
                      hintText: '0',
                      filled: _filledFromDb,
                      fillColor: _filledFromDb ? Colors.grey.shade100 : null,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _proteinController,
                          keyboardType: TextInputType.number,
                          readOnly: _filledFromDb,
                          decoration: InputDecoration(
                            labelText: 'Protein (g)',
                            filled: _filledFromDb,
                            fillColor: _filledFromDb ? Colors.grey.shade100 : null,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _carbsController,
                          keyboardType: TextInputType.number,
                          readOnly: _filledFromDb,
                          decoration: InputDecoration(
                            labelText: 'Carbs (g)',
                            filled: _filledFromDb,
                            fillColor: _filledFromDb ? Colors.grey.shade100 : null,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _fatController,
                          keyboardType: TextInputType.number,
                          readOnly: _filledFromDb,
                          decoration: InputDecoration(
                            labelText: 'Fat (g)',
                            filled: _filledFromDb,
                            fillColor: _filledFromDb ? Colors.grey.shade100 : null,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Meal type selector
            const Text(
              'Meal Type',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: MealType.values.map((type) {
                final isSelected = _selectedMealType == type;
                return ChoiceChip(
                  label: Text('${type.icon} ${type.displayName}'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedMealType = type);
                    }
                  },
                  selectedColor: AppColors.health.withOpacity(0.2),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter food name')),
      );
      return;
    }

    final calories = double.tryParse(_caloriesController.text) ?? 0;
    final protein = double.tryParse(_proteinController.text) ?? 0;
    final carbs = double.tryParse(_carbsController.text) ?? 0;
    final fat = double.tryParse(_fatController.text) ?? 0;
    final servingSize = double.tryParse(_servingSizeController.text) ?? 1.0;

    // ใช้วันที่เลือก + เวลาปัจจุบัน (หรือเวลาตาม meal type)
    final date = widget.selectedDate ?? DateTime.now();
    final now = DateTime.now();
    final timestamp = DateTime(date.year, date.month, date.day, now.hour, now.minute);

    final entry = FoodEntry()
      ..foodName = _nameController.text.trim()
      ..mealType = _selectedMealType
      ..timestamp = timestamp
      ..servingSize = servingSize
      ..servingUnit = _servingUnit
      ..calories = calories
      ..protein = protein
      ..carbs = carbs
      ..fat = fat
      // เก็บ base values
      ..baseCalories = servingSize > 0 ? calories / servingSize : calories
      ..baseProtein = servingSize > 0 ? protein / servingSize : protein
      ..baseCarbs = servingSize > 0 ? carbs / servingSize : carbs
      ..baseFat = servingSize > 0 ? fat / servingSize : fat
      ..myMealId = _selectedMyMealId
      ..source = _filledFromDb ? DataSource.database : DataSource.manual;

    widget.onSave(entry);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Food added'), backgroundColor: AppColors.success),
    );
  }
}

// ============================================
// EDIT FOOD BOTTOM SHEET - MOVED TO widgets/edit_food_bottom_sheet.dart
// ============================================
