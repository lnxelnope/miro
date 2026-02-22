import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/enums.dart';
import '../../../core/utils/unit_converter.dart';
import '../providers/my_meal_provider.dart';
import '../models/food_entry.dart';

class AddFoodBottomSheet extends ConsumerStatefulWidget {
  final MealType mealType;
  final Function(FoodEntry) onSave;
  final DateTime? selectedDate;

  /// Pre-fill data from ghost suggestion tap
  final String? prefillName;
  final double? prefillCalories;
  final double? prefillProtein;
  final double? prefillCarbs;
  final double? prefillFat;
  final double? prefillServingSize;
  final String? prefillServingUnit;
  final int? prefillMyMealId;

  const AddFoodBottomSheet({
    super.key,
    required this.mealType,
    required this.onSave,
    this.selectedDate,
    this.prefillName,
    this.prefillCalories,
    this.prefillProtein,
    this.prefillCarbs,
    this.prefillFat,
    this.prefillServingSize,
    this.prefillServingUnit,
    this.prefillMyMealId,
  });

  @override
  ConsumerState<AddFoodBottomSheet> createState() => _AddFoodBottomSheetState();
}

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
  final int? myMealId;

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
  bool _filledFromDb = false;
  int? _selectedMyMealId;

  double _baseCalories = 0;
  double _baseProtein = 0;
  double _baseCarbs = 0;
  double _baseFat = 0;

  @override
  void initState() {
    super.initState();
    _selectedMealType = widget.mealType;
    _servingSizeController.addListener(_onServingSizeChanged);
    _applyPrefill();
  }

  void _applyPrefill() {
    if (widget.prefillName == null) return;

    final servingSize = widget.prefillServingSize ?? 1.0;

    _nameController.text = widget.prefillName!;
    _servingSizeController.text = servingSize == servingSize.roundToDouble()
        ? servingSize.round().toString()
        : servingSize.toStringAsFixed(1);
    _servingUnit = widget.prefillServingUnit ?? 'serving';
    _caloriesController.text = (widget.prefillCalories ?? 0).round().toString();
    _proteinController.text = (widget.prefillProtein ?? 0).round().toString();
    _carbsController.text = (widget.prefillCarbs ?? 0).round().toString();
    _fatController.text = (widget.prefillFat ?? 0).round().toString();

    _baseCalories = servingSize > 0 ? (widget.prefillCalories ?? 0) / servingSize : 0;
    _baseProtein = servingSize > 0 ? (widget.prefillProtein ?? 0) / servingSize : 0;
    _baseCarbs = servingSize > 0 ? (widget.prefillCarbs ?? 0) / servingSize : 0;
    _baseFat = servingSize > 0 ? (widget.prefillFat ?? 0) / servingSize : 0;

    _filledFromDb = true;
    _selectedMyMealId = widget.prefillMyMealId;
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

  Widget _buildCloseButton() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.close, size: 20, color: Colors.grey.shade600),
      ),
    );
  }

  void _onUnitChanged(String newUnit) {
    final oldUnit = _servingUnit;
    final oldQty = double.tryParse(_servingSizeController.text) ?? 0;

    if (_filledFromDb && _baseCalories > 0 && oldQty > 0) {
      final result = UnitConverter.convertServing(
        oldQty: oldQty,
        oldUnit: oldUnit,
        newUnit: newUnit,
      );

      _servingSizeController.removeListener(_onServingSizeChanged);

      if (result.converted) {
        final factor = result.newQty / oldQty;
        _baseCalories = _baseCalories / factor;
        _baseProtein = _baseProtein / factor;
        _baseCarbs = _baseCarbs / factor;
        _baseFat = _baseFat / factor;

        setState(() {
          _servingUnit = newUnit;
          _servingSizeController.text = result.newQty < 10
              ? result.newQty.toStringAsFixed(2)
              : result.newQty.round().toString();
        });
      } else {
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

  void _onServingSizeChanged() {
    if (!_filledFromDb || _baseCalories <= 0) return;
    final newServing = double.tryParse(_servingSizeController.text) ?? 0;
    if (newServing <= 0) return;

    setState(() {
      _caloriesController.text =
          (_baseCalories * newServing).round().toString();
      _proteinController.text = (_baseProtein * newServing).round().toString();
      _carbsController.text = (_baseCarbs * newServing).round().toString();
      _fatController.text = (_baseFat * newServing).round().toString();
    });
  }

  Future<List<_FoodSuggestion>> _searchSuggestions(String query) async {
    if (query.trim().isEmpty) return [];
    final q = query.trim().toLowerCase();
    final results = <_FoodSuggestion>[];

    final mealsAsync = await ref.read(allMyMealsProvider.future);
    for (final meal in mealsAsync) {
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

    final ingredientsAsync = await ref.read(allIngredientsProvider.future);
    for (final ing in ingredientsAsync) {
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

    if (results.length > 15) return results.sublist(0, 15);
    return results;
  }

  void _onSuggestionSelected(_FoodSuggestion suggestion) {
    _servingSizeController.removeListener(_onServingSizeChanged);

    final servingSize =
        suggestion.servingSize > 0 ? suggestion.servingSize : 1.0;

    _baseCalories = suggestion.calories / servingSize;
    _baseProtein = suggestion.protein / servingSize;
    _baseCarbs = suggestion.carbs / servingSize;
    _baseFat = suggestion.fat / servingSize;

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

    _servingSizeController.addListener(_onServingSizeChanged);
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
            const SizedBox(height: 12),

            Row(
              children: [
                const Expanded(
                  child: Text(
                    '🍽️ Add Food',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildCloseButton(),
              ],
            ),
            const SizedBox(height: 20),

            LayoutBuilder(
              builder: (context, constraints) {
                return Autocomplete<_FoodSuggestion>(
                  optionsBuilder: (textEditingValue) async {
                    return await _searchSuggestions(textEditingValue.text);
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
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary),
                                ),
                                onTap: () => onSelected(option),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  fieldViewBuilder:
                      (context, textController, focusNode, onFieldSubmitted) {
                    textController.addListener(() {
                      if (_nameController.text != textController.text) {
                        _nameController.text = textController.text;
                        setState(() {
                          if (_filledFromDb) {
                            _filledFromDb = false;
                            _selectedMyMealId = null;
                          }
                        });
                      }
                    });
                    return TextField(
                      controller: textController,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: 'Food Name *',
                        hintText:
                            'Type to search e.g. fried rice, papaya salad',
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
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
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
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveAndAnalyze,
                  icon: const Icon(Icons.save_rounded, size: 18),
                  label: const Text(
                    'Save & Analyze',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 1,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Not found in database — will be analyzed in background',
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: 16),

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
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
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
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
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
                            fillColor:
                                _filledFromDb ? Colors.grey.shade100 : null,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
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
                            fillColor:
                                _filledFromDb ? Colors.grey.shade100 : null,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
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
                            fillColor:
                                _filledFromDb ? Colors.grey.shade100 : null,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

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
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(type.icon, size: 16, color: type.iconColor),
                      const SizedBox(width: 6),
                      Text(type.displayName),
                    ],
                  ),
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

  Future<void> _saveAndAnalyze() async {
    final foodName = _nameController.text.trim();
    if (foodName.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter food name first'), duration: Duration(seconds: 2)),
      );
      return;
    }

    final servingSize = double.tryParse(_servingSizeController.text) ?? 1;

    final date = widget.selectedDate ?? DateTime.now();
    final now = DateTime.now();
    final timestamp =
        DateTime(date.year, date.month, date.day, now.hour, now.minute);

    // Create unanalyzed entry
    final entry = FoodEntry()
      ..foodName = foodName
      ..mealType = _selectedMealType
      ..timestamp = timestamp
      ..servingSize = servingSize
      ..servingUnit = _servingUnit
      ..calories = 0
      ..protein = 0
      ..carbs = 0
      ..fat = 0
      ..source = DataSource.manual
      ..isVerified = false;

    widget.onSave(entry);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('✅ Saved — analyzing in background'), backgroundColor: AppColors.success),
    );
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter food name'), duration: Duration(seconds: 2)),
      );
      return;
    }

    final calories = double.tryParse(_caloriesController.text) ?? 0;
    final protein = double.tryParse(_proteinController.text) ?? 0;
    final carbs = double.tryParse(_carbsController.text) ?? 0;
    final fat = double.tryParse(_fatController.text) ?? 0;
    final servingSize = double.tryParse(_servingSizeController.text) ?? 1.0;

    final date = widget.selectedDate ?? DateTime.now();
    final now = DateTime.now();
    final timestamp =
        DateTime(date.year, date.month, date.day, now.hour, now.minute);

    // Load ingredientsJson from MyMeal if available
    String? ingredientsJsonStr;
    if (_filledFromDb && _selectedMyMealId != null) {
      try {
        final tree = await ref.read(mealIngredientTreeProvider(_selectedMyMealId!).future);
        if (tree.isNotEmpty) {
          final ingredientsData = tree.map((node) {
            final rootMap = <String, dynamic>{
              'name': node.ingredient.ingredientName,
              'amount': node.ingredient.amount,
              'unit': node.ingredient.unit,
              'calories': node.ingredient.calories,
              'protein': node.ingredient.protein,
              'carbs': node.ingredient.carbs,
              'fat': node.ingredient.fat,
            };
            if (node.ingredient.detail != null && node.ingredient.detail!.isNotEmpty) {
              rootMap['detail'] = node.ingredient.detail;
            }
            if (node.children.isNotEmpty) {
              rootMap['sub_ingredients'] = node.children.map((child) {
                final subMap = <String, dynamic>{
                  'name': child.ingredientName,
                  'amount': child.amount,
                  'unit': child.unit,
                  'calories': child.calories,
                  'protein': child.protein,
                  'carbs': child.carbs,
                  'fat': child.fat,
                };
                if (child.detail != null && child.detail!.isNotEmpty) {
                  subMap['detail'] = child.detail;
                }
                return subMap;
              }).toList();
            }
            return rootMap;
          }).toList();
          ingredientsJsonStr = jsonEncode(ingredientsData);
        }
      } catch (_) {}
    }

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
      ..baseCalories = servingSize > 0 ? calories / servingSize : calories
      ..baseProtein = servingSize > 0 ? protein / servingSize : protein
      ..baseCarbs = servingSize > 0 ? carbs / servingSize : carbs
      ..baseFat = servingSize > 0 ? fat / servingSize : fat
      ..myMealId = _selectedMyMealId
      ..ingredientsJson = ingredientsJsonStr
      ..source = _filledFromDb ? DataSource.database : DataSource.manual;

    widget.onSave(entry);
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('✅ Food added'), backgroundColor: AppColors.success),
    );
  }
}
