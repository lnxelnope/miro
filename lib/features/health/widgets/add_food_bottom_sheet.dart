import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/constants/enums.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../core/utils/logger.dart';
import '../../../core/ai/gemini_service.dart';
import '../../../core/database/database_service.dart';
import '../../../core/services/usage_limiter.dart';
import '../../../l10n/app_localizations.dart';
import '../../../features/energy/providers/energy_provider.dart';
import '../providers/my_meal_provider.dart';
import '../providers/health_provider.dart';
import '../models/food_entry.dart';
import '../models/ingredient.dart';
import '../models/my_meal.dart';

// ===== Editable Ingredient Row Model =====
class _EditableIngredient {
  final TextEditingController nameController;
  final TextEditingController amountController;
  String unit;
  String? nameEn;
  final Key key = UniqueKey();

  double baseCalories, baseProtein, baseCarbs, baseFat, baseAmount;
  double calories, protein, carbs, fat;
  bool isLoading = false;
  bool isFromDb = false;

  List<_EditableIngredient> subIngredients = [];

  _EditableIngredient({
    required String name,
    this.nameEn,
    required double amount,
    required this.unit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    List<_EditableIngredient>? subIngredients,
  })  : nameController = TextEditingController(text: name),
        amountController = TextEditingController(
            text: amount > 0 ? amount.toStringAsFixed(0) : ''),
        baseAmount = amount > 0 ? amount : 1,
        baseCalories = amount > 0 ? calories / amount : calories,
        baseProtein = amount > 0 ? protein / amount : protein,
        baseCarbs = amount > 0 ? carbs / amount : carbs,
        baseFat = amount > 0 ? fat / amount : fat,
        subIngredients = subIngredients ?? [];

  void saveBaseValues() {
    final amt = double.tryParse(amountController.text) ?? 0;
    if (amt > 0) {
      baseAmount = amt;
      baseCalories = calories / amt;
      baseProtein = protein / amt;
      baseCarbs = carbs / amt;
      baseFat = fat / amt;
    }
  }

  void recalculate() {
    final amt = double.tryParse(amountController.text) ?? 0;
    calories = baseCalories * amt;
    protein = baseProtein * amt;
    carbs = baseCarbs * amt;
    fat = baseFat * amt;

    if (subIngredients.isNotEmpty && baseAmount > 0) {
      final ratio = amt / baseAmount;
      for (final sub in subIngredients) {
        final newSubAmt = sub.baseAmount * ratio;
        sub.amountController.text = newSubAmt.toStringAsFixed(0);
        sub.calories = sub.baseCalories * newSubAmt;
        sub.protein = sub.baseProtein * newSubAmt;
        sub.carbs = sub.baseCarbs * newSubAmt;
        sub.fat = sub.baseFat * newSubAmt;
      }
    }
  }

  void dispose() {
    nameController.dispose();
    amountController.dispose();
    for (final sub in subIngredients) {
      sub.dispose();
    }
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': nameController.text.trim(),
      'name_en': nameEn,
      'amount': double.tryParse(amountController.text) ?? 0,
      'unit': unit,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
    if (subIngredients.isNotEmpty) {
      map['sub_ingredients'] =
          subIngredients.map((sub) => sub.toMap()).toList();
    }
    return map;
  }
}

// ===== Food Suggestion Model =====
class _FoodSuggestion {
  final String name;
  final String? nameEn;
  final String source;
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

class AddFoodBottomSheet extends ConsumerStatefulWidget {
  final MealType mealType;
  final Function(FoodEntry) onSave;
  final DateTime? selectedDate;

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
  bool _isAnalyzing = false;

  double _baseCalories = 0;
  double _baseProtein = 0;
  double _baseCarbs = 0;
  double _baseFat = 0;

  // Ingredients
  final List<_EditableIngredient> _ingredients = [];
  bool get _hasIngredients => _ingredients.isNotEmpty;
  List<Ingredient> _cachedIngredients = [];
  final Set<int> _lookingUpIndices = {};

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
    for (final ing in _ingredients) {
      ing.dispose();
    }
    super.dispose();
  }

  // ============================================================
  // Serving Size / Unit Logic
  // ============================================================
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
        setState(() => _servingUnit = newUnit);
      }

      _servingSizeController.addListener(_onServingSizeChanged);
    } else {
      setState(() => _servingUnit = newUnit);
    }
  }

  void _onServingSizeChanged() {
    if (!_filledFromDb || _baseCalories <= 0) return;
    final newServing = double.tryParse(_servingSizeController.text) ?? 0;
    if (newServing <= 0) return;

    if (_hasIngredients) {
      final ratio = newServing / (_baseCalories > 0 ? 1 : 1);
      for (final ing in _ingredients) {
        ing.recalculate();
      }
      _recalculateFromIngredients();
      return;
    }

    setState(() {
      _caloriesController.text =
          (_baseCalories * newServing).round().toString();
      _proteinController.text = (_baseProtein * newServing).round().toString();
      _carbsController.text = (_baseCarbs * newServing).round().toString();
      _fatController.text = (_baseFat * newServing).round().toString();
    });
  }

  // ============================================================
  // Food Name Search (My Meal + Ingredient)
  // ============================================================
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

    // Load ingredients if selected from MyMeal
    if (suggestion.myMealId != null) {
      _loadIngredientsFromMyMeal(suggestion.myMealId!);
    }
  }

  Future<void> _loadIngredientsFromMyMeal(int mealId) async {
    try {
      final tree = await ref.read(mealIngredientTreeProvider(mealId).future);
      if (tree.isEmpty) return;

      setState(() {
        _ingredients.clear();
        for (final node in tree) {
          List<_EditableIngredient>? subs;
          if (node.children.isNotEmpty) {
            subs = node.children.map((child) {
              return _EditableIngredient(
                name: child.ingredientName,
                nameEn: null,
                amount: child.amount,
                unit: child.unit,
                calories: child.calories,
                protein: child.protein,
                carbs: child.carbs,
                fat: child.fat,
              );
            }).toList();
          }
          _ingredients.add(_EditableIngredient(
            name: node.ingredient.ingredientName,
            amount: node.ingredient.amount,
            unit: node.ingredient.unit,
            calories: node.ingredient.calories,
            protein: node.ingredient.protein,
            carbs: node.ingredient.carbs,
            fat: node.ingredient.fat,
            subIngredients: subs,
          ));
        }
      });
    } catch (e) {
      AppLogger.warn('Failed to load ingredients from MyMeal', e);
    }
  }

  // ============================================================
  // Ingredient Management
  // ============================================================
  void _addIngredient() {
    setState(() {
      _ingredients.insert(
          0,
          _EditableIngredient(
            name: '',
            amount: 0,
            unit: 'g',
            calories: 0,
            protein: 0,
            carbs: 0,
            fat: 0,
          ));
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients[index].dispose();
      _ingredients.removeAt(index);
    });
    _recalculateFromIngredients();
  }

  void _recalculateFromIngredients() {
    if (!_hasIngredients) return;
    double cal = 0, p = 0, c = 0, f = 0;
    for (final ing in _ingredients) {
      cal += ing.calories;
      p += ing.protein;
      c += ing.carbs;
      f += ing.fat;
    }
    setState(() {
      _caloriesController.text = cal.round().toString();
      _proteinController.text = p.round().toString();
      _carbsController.text = c.round().toString();
      _fatController.text = f.round().toString();
    });
  }

  void _recalculateParentFromSubs(_EditableIngredient parent) {
    if (parent.subIngredients.isEmpty) return;
    double totalCal = 0, totalP = 0, totalC = 0, totalF = 0;
    for (final sub in parent.subIngredients) {
      totalCal += sub.calories;
      totalP += sub.protein;
      totalC += sub.carbs;
      totalF += sub.fat;
    }
    parent.calories = totalCal;
    parent.protein = totalP;
    parent.carbs = totalC;
    parent.fat = totalF;
  }

  // ============================================================
  // AI Lookup for Ingredient
  // ============================================================
  Future<void> _lookupIngredient(int index) async {
    if (_lookingUpIndices.contains(index)) return;

    final row = _ingredients[index];
    final name = row.nameController.text.trim();
    final amount = double.tryParse(row.amountController.text) ?? 0;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(L10n.of(context)!.pleaseEnterIngredientName),
            duration: const Duration(seconds: 2)),
      );
      return;
    }

    row.subIngredients = [];

    if (amount <= 0) {
      final action = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(L10n.of(context)!.amountNotSpecified),
          content: Text(L10n.of(context)!.amountNotSpecifiedMessage(name)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, 'cancel'),
                child: Text(L10n.of(context)!.cancel)),
            TextButton(
                onPressed: () => Navigator.pop(ctx, 'default'),
                child: Text(L10n.of(context)!.useDefault100g)),
          ],
        ),
      );
      if (action == 'default') {
        row.amountController.text = '100';
        row.unit = 'g';
      } else {
        return;
      }
    }

    final hasEnergy = await GeminiService.hasEnergy();
    if (!hasEnergy) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10n.of(context)!.notEnoughEnergy),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() => row.isLoading = true);
    _lookingUpIndices.add(index);

    try {
      final queryAmount = double.tryParse(row.amountController.text) ?? 100;
      final result = await GeminiService.analyzeFoodByName(
        name,
        servingSize: queryAmount,
        servingUnit: row.unit,
      );

      if (result != null && mounted) {
        await UsageLimiter.recordAiUsage();
        ref.invalidate(energyBalanceProvider);
        ref.invalidate(currentEnergyProvider);

        // Save to Ingredient DB immediately
        final savedIngredient = Ingredient()
          ..name = name
          ..nameEn = result.foodNameEn
          ..baseAmount = queryAmount
          ..baseUnit = row.unit
          ..caloriesPerBase = result.nutrition.calories
          ..proteinPerBase = result.nutrition.protein
          ..carbsPerBase = result.nutrition.carbs
          ..fatPerBase = result.nutrition.fat
          ..source = 'gemini'
          ..usageCount = 1;

        try {
          await DatabaseService.isar.writeTxn(() async {
            await DatabaseService.ingredients.put(savedIngredient);
          });
          ref.invalidate(allIngredientsProvider);
          AppLogger.info('Saved AI result to Ingredient DB: $name');
        } catch (e) {
          AppLogger.warn('Failed to save ingredient to DB', e);
        }

        setState(() {
          row.calories = result.nutrition.calories;
          row.protein = result.nutrition.protein;
          row.carbs = result.nutrition.carbs;
          row.fat = result.nutrition.fat;
          row.nameEn = result.foodNameEn;
          row.isLoading = false;
          _lookingUpIndices.remove(index);
          row.saveBaseValues();

          if (result.ingredientsDetail != null &&
              result.ingredientsDetail!.isNotEmpty) {
            row.subIngredients = result.ingredientsDetail!.map((sub) {
              return _EditableIngredient(
                name: sub.name,
                nameEn: sub.nameEn,
                amount: sub.amount,
                unit: sub.unit,
                calories: sub.calories,
                protein: sub.protein,
                carbs: sub.carbs,
                fat: sub.fat,
              );
            }).toList();
          }
        });
        _recalculateFromIngredients();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.of(context)!.aiAnalyzedResult(
                name, result.nutrition.calories.toInt())),
            backgroundColor: AppColors.premium,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        setState(() {
          row.isLoading = false;
          _lookingUpIndices.remove(index);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(L10n.of(context)!.unableToAnalyze),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 2)),
          );
        }
      }
    } catch (e) {
      setState(() {
        row.isLoading = false;
        _lookingUpIndices.remove(index);
      });
      if (mounted) {
        if (e.toString().contains('Insufficient energy')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(L10n.of(context)!.notEnoughEnergy),
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error,
                duration: const Duration(seconds: 2)),
          );
        }
      }
    }
  }

  // ============================================================
  // AI Lookup for Sub-Ingredient
  // ============================================================
  Future<void> _lookupSubIngredient(
      _EditableIngredient parentRow, int subIdx) async {
    final sub = parentRow.subIngredients[subIdx];
    final subName = sub.nameController.text.trim();

    if (subName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(L10n.of(context)!.pleaseEnterSubIngredientName),
            duration: const Duration(seconds: 2)),
      );
      return;
    }

    setState(() => sub.isLoading = true);

    try {
      // Try DB first
      final dbMatch = _cachedIngredients.where((ing) =>
          ing.name.toLowerCase() == subName.toLowerCase() ||
          (ing.nameEn?.toLowerCase() == subName.toLowerCase()));

      if (dbMatch.isNotEmpty) {
        final ing = dbMatch.first;
        final amount = double.tryParse(sub.amountController.text) ?? 1;
        final ratio = amount / ing.baseAmount;
        setState(() {
          sub.nameController.text = ing.name;
          sub.nameEn = ing.nameEn;
          sub.unit = ing.baseUnit;
          sub.calories = ing.caloriesPerBase * ratio;
          sub.protein = ing.proteinPerBase * ratio;
          sub.carbs = ing.carbsPerBase * ratio;
          sub.fat = ing.fatPerBase * ratio;
          sub.isFromDb = true;
          sub.isLoading = false;
          sub.saveBaseValues();
          _recalculateParentFromSubs(parentRow);
          _recalculateFromIngredients();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(L10n.of(context)!.foundInDatabaseSub(subName)),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 2)),
          );
        }
        return;
      }

      // AI lookup
      final hasEnergy = await GeminiService.hasEnergy();
      if (!hasEnergy && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.of(context)!.notEnoughEnergy),
            duration: const Duration(seconds: 3),
          ),
        );
        setState(() => sub.isLoading = false);
        return;
      }

      final amount = double.tryParse(sub.amountController.text) ?? 1;
      final result = await GeminiService.analyzeFoodByName(
        subName,
        servingSize: amount,
        servingUnit: sub.unit,
      );

      if (!mounted) return;

      if (result != null) {
        await UsageLimiter.recordAiUsage();
        ref.invalidate(energyBalanceProvider);
        ref.invalidate(currentEnergyProvider);

        // Save to Ingredient DB immediately
        final savedIngredient = Ingredient()
          ..name = subName
          ..nameEn = result.foodNameEn
          ..baseAmount = amount
          ..baseUnit = sub.unit
          ..caloriesPerBase = result.nutrition.calories
          ..proteinPerBase = result.nutrition.protein
          ..carbsPerBase = result.nutrition.carbs
          ..fatPerBase = result.nutrition.fat
          ..source = 'gemini'
          ..usageCount = 1;

        try {
          await DatabaseService.isar.writeTxn(() async {
            await DatabaseService.ingredients.put(savedIngredient);
          });
          ref.invalidate(allIngredientsProvider);
        } catch (e) {
          AppLogger.warn('Failed to save sub-ingredient to DB', e);
        }

        setState(() {
          sub.nameController.text = result.foodName;
          sub.nameEn = result.foodNameEn;
          sub.calories = result.nutrition.calories;
          sub.protein = result.nutrition.protein;
          sub.carbs = result.nutrition.carbs;
          sub.fat = result.nutrition.fat;
          sub.isFromDb = false;
          sub.isLoading = false;
          sub.saveBaseValues();
          _recalculateParentFromSubs(parentRow);
          _recalculateFromIngredients();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(L10n.of(context)!.aiAnalyzedSub(subName)),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 2)),
          );
        }
      } else {
        setState(() => sub.isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(L10n.of(context)!.couldNotAnalyzeSub),
                backgroundColor: AppColors.warning,
                duration: const Duration(seconds: 2)),
          );
        }
      }
    } catch (e) {
      setState(() => sub.isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), duration: const Duration(seconds: 2)),
        );
      }
    }
  }

  // ============================================================
  // Build
  // ============================================================
  @override
  Widget build(BuildContext context) {
    _cachedIngredients = ref.watch(allIngredientsProvider).valueOrNull ?? [];

    return Container(
      margin: AppSpacing.paddingLg,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.xl,
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
                  borderRadius: BorderRadius.circular(2), // Keep 2px for small indicator
                ),
              ),
            ),
            SizedBox(height: AppSpacing.lg),

            Text(
              '🍽️ ${L10n.of(context)!.addFoodTitle}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.xl),

            // ===== Food Name with Autocomplete =====
            _buildFoodNameField(),

            if (_filledFromDb) ...[
              SizedBox(height: AppSpacing.xs),
              Text(
                _selectedMyMealId != null
                    ? L10n.of(context)!.selectedFromMyMeal
                    : L10n.of(context)!.foundInDatabase,
                style: const TextStyle(fontSize: 11, color: AppColors.success),
              ),
            ] else if (_nameController.text.isNotEmpty) ...[
              SizedBox(height: AppSpacing.sm),
              AppButton.ai(
                label: L10n.of(context)!.saveAndAnalyze,
                icon: Icons.auto_awesome_rounded,
                isLoading: _isAnalyzing,
                onPressed: _saveAndAnalyze,
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                L10n.of(context)!.notFoundInDatabase,
                style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ],
            SizedBox(height: AppSpacing.lg),

            // ===== Serving Size + Unit =====
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _servingSizeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: L10n.of(context)!.amountLabel,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.md,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    initialValue: _servingUnit,
                    decoration: InputDecoration(
                      labelText: L10n.of(context)!.unitLabel,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.md,
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
            SizedBox(height: AppSpacing.lg),

            // ===== Nutrition Fields (styled) =====
            Container(
              padding: AppSpacing.paddingLg,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.warning.withValues(alpha: 0.1), AppColors.warning.withValues(alpha: 0.1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppRadius.lg,
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_fire_department_rounded,
                          color: AppColors.warning.withValues(alpha: 0.7), size: 20),
                      SizedBox(width: AppSpacing.sm), // 6 -> 8 closest
                      Text(
                        _filledFromDb || _hasIngredients
                            ? L10n.of(context)!.nutritionAutoCalculated
                            : L10n.of(context)!.nutritionEnterZero,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.warning),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _caloriesController,
                    keyboardType: TextInputType.number,
                    readOnly: _filledFromDb || _hasIngredients,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.warning,
                    ),
                    decoration: InputDecoration(
                      labelText: L10n.of(context)!.caloriesLabel,
                      labelStyle: TextStyle(
                        color: AppColors.warning.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                      suffixText: 'kcal',
                      suffixStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning.withValues(alpha: 0.7),
                      ),
                      prefixIcon: Icon(Icons.local_fire_department_rounded,
                          color: AppColors.warning),
                      hintText: '0',
                      filled: true,
                      fillColor: (_filledFromDb || _hasIngredients)
                          ? AppColors.warning.withValues(alpha: 0.1)
                          : Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.md,
                        borderSide: BorderSide(color: AppColors.warning.withValues(alpha: 0.4), width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadius.md,
                        borderSide: BorderSide(color: AppColors.warning, width: 2),
                      ),
                      border: OutlineInputBorder(
                          borderRadius: AppRadius.md),
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _proteinController,
                          keyboardType: TextInputType.number,
                          readOnly: _filledFromDb || _hasIngredients,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.info,
                          ),
                          decoration: InputDecoration(
                            labelText: L10n.of(context)!.proteinLabelShort,
                            labelStyle: const TextStyle(
                              color: AppColors.info,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            suffixText: 'g',
                            suffixStyle: const TextStyle(
                              color: AppColors.info,
                              fontWeight: FontWeight.w600,
                            ),
                            filled: true,
                            fillColor: (_filledFromDb || _hasIngredients)
                                ? AppColors.info.withValues(alpha: 0.06)
                                : Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppRadius.md,
                              borderSide: BorderSide(color: AppColors.info.withValues(alpha: 0.4)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: AppRadius.md,
                              borderSide: const BorderSide(color: AppColors.info, width: 2),
                            ),
                            border: OutlineInputBorder(
                                borderRadius: AppRadius.md),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: TextField(
                          controller: _carbsController,
                          keyboardType: TextInputType.number,
                          readOnly: _filledFromDb || _hasIngredients,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.warning,
                          ),
                          decoration: InputDecoration(
                            labelText: L10n.of(context)!.carbsLabelShort,
                            labelStyle: const TextStyle(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            suffixText: 'g',
                            suffixStyle: const TextStyle(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                            filled: true,
                            fillColor: (_filledFromDb || _hasIngredients)
                                ? AppColors.warning.withValues(alpha: 0.06)
                                : Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppRadius.md,
                              borderSide: BorderSide(color: AppColors.warning.withValues(alpha: 0.4)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: AppRadius.md,
                              borderSide: const BorderSide(color: AppColors.warning, width: 2),
                            ),
                            border: OutlineInputBorder(
                                borderRadius: AppRadius.md),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: TextField(
                          controller: _fatController,
                          keyboardType: TextInputType.number,
                          readOnly: _filledFromDb || _hasIngredients,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.error,
                          ),
                          decoration: InputDecoration(
                            labelText: L10n.of(context)!.fatLabelShort,
                            labelStyle: const TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            suffixText: 'g',
                            suffixStyle: const TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                            filled: true,
                            fillColor: (_filledFromDb || _hasIngredients)
                                ? AppColors.error.withValues(alpha: 0.06)
                                : Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppRadius.md,
                              borderSide: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: AppRadius.md,
                              borderSide: const BorderSide(color: AppColors.error, width: 2),
                            ),
                            border: OutlineInputBorder(
                                borderRadius: AppRadius.md),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_hasIngredients) ...[
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      '📊 ${L10n.of(context)!.calculatedFromIngredients}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg),

            // ===== Ingredients Section =====
            _buildIngredientsSection(),
            SizedBox(height: AppSpacing.lg),

            // ===== Meal Type =====
            Text(
              L10n.of(context)!.mealTypeLabel,
              style: const TextStyle(fontWeight: FontWeight.w500),
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
                      SizedBox(width: AppSpacing.sm), // 6 -> 8 closest
                      Text(type.displayName),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedMealType = type);
                    }
                  },
                  selectedColor: AppColors.health.withValues(alpha: 0.2),
                );
              }).toList(),
            ),
            SizedBox(height: AppSpacing.xxl),

            // ===== Save Button =====
            AppButton.primary(
              label: L10n.of(context)!.save,
              icon: Icons.save_rounded,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Food Name Field with Autocomplete
  // ============================================================
  Widget _buildFoodNameField() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Autocomplete<_FoodSuggestion>(
          initialValue: TextEditingValue(text: widget.prefillName ?? ''),
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
                borderRadius: AppRadius.md,
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
                                  ? AppColors.warning
                                  : AppColors.primary,
                        ),
                        title: Text(
                          option.name,
                          style: const TextStyle(fontSize: 14),
                        ),
                        subtitle: Text(
                          '${option.calories.round()} kcal · '
                          '${option.source == 'meal' ? L10n.of(context)!.suggestionSourceMyMeal : option.source == 'ingredient' ? L10n.of(context)!.suggestionSourceIngredient : L10n.of(context)!.suggestionSourceDatabase}',
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
                labelText: L10n.of(context)!.foodNameHint,
                hintText: L10n.of(context)!.foodNameHint,
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
                            _ingredients.clear();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                    borderRadius: AppRadius.md),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // Ingredients Section
  // ============================================================
  Widget _buildIngredientsSection() {
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.05),
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science_outlined, size: 16, color: AppColors.success),
              SizedBox(width: AppSpacing.sm), // 6 -> 8 closest
              Expanded(
                child: Text(
                  L10n.of(context)!.ingredientsEditable,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success),
                ),
              ),
              InkWell(
                onTap: _addIngredient,
                borderRadius: AppRadius.sm,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: AppRadius.sm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, size: 14, color: AppColors.success),
                      SizedBox(width: AppSpacing.xxs), // 2 -> 2
                      Text(L10n.of(context)!.addIngredientButton,
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.success,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md), // 10 -> 12 closest
          if (_ingredients.isEmpty)
            Padding(
              padding: AppSpacing.paddingSm,
              child: Text(L10n.of(context)!.noIngredientsAddHint,
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            )
          else
            ...List.generate(
                _ingredients.length, (i) => _buildIngredientRow(i)),
          SizedBox(height: AppSpacing.sm), // 6 -> 8 closest
          Text(
            L10n.of(context)!.editIngredientsHint,
            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Ingredient Row
  // ============================================================
  Widget _buildIngredientRow(int index) {
    final row = _ingredients[index];
    return Container(
      key: row.key,
      margin: EdgeInsets.only(bottom: AppSpacing.md), // 10 -> 12 closest
      padding: EdgeInsets.all(AppSpacing.md), // 10 -> 12 closest
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.md, // 10 -> 12 (closest)
        border: Border.all(
            color: row.isFromDb ? AppColors.success.withValues(alpha: 0.3) : AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Name (Autocomplete) + AI search + delete
          Row(
            children: [
              Expanded(
                child: Autocomplete<Ingredient>(
                  key: ValueKey('ac_${row.key}'),
                  initialValue: TextEditingValue(text: row.nameController.text),
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<Ingredient>.empty();
                    }
                    final query = textEditingValue.text.toLowerCase();
                    return _cachedIngredients.where((ing) {
                      return ing.name.toLowerCase().contains(query) ||
                          (ing.nameEn?.toLowerCase().contains(query) ?? false);
                    }).take(8);
                  },
                  displayStringForOption: (Ingredient ing) => ing.name,
                  onSelected: (Ingredient selection) {
                    final amt = double.tryParse(row.amountController.text) ??
                        selection.baseAmount;
                    final ratio = amt / selection.baseAmount;
                    setState(() {
                      row.nameController.text = selection.name;
                      row.nameEn = selection.nameEn;
                      row.unit = selection.baseUnit;
                      row.amountController.text = amt.toStringAsFixed(
                          amt == amt.roundToDouble() ? 0 : 1);
                      row.calories = selection.caloriesPerBase * ratio;
                      row.protein = selection.proteinPerBase * ratio;
                      row.carbs = selection.carbsPerBase * ratio;
                      row.fat = selection.fatPerBase * ratio;
                      row.isFromDb = true;
                      row.subIngredients = [];
                      row.saveBaseValues();
                    });
                    _recalculateFromIngredients();
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4,
                        borderRadius: AppRadius.sm,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                              maxHeight: 200, maxWidth: 280),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, idx) {
                              final ing = options.elementAt(idx);
                              return ListTile(
                                dense: true,
                                title: Text(ing.name,
                                    style: const TextStyle(fontSize: 13)),
                                subtitle: Text(
                                  '${ing.caloriesPerBase.toInt()} kcal / ${ing.baseAmount.toStringAsFixed(0)} ${ing.baseUnit}',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary),
                                ),
                                onTap: () => onSelected(ing),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  fieldViewBuilder: (context, textEditingController, focusNode,
                      onFieldSubmitted) {
                    textEditingController.addListener(() {
                      if (row.nameController.text != textEditingController.text) {
                        row.nameController.text = textEditingController.text;
                      }
                    });
                    return TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: L10n.of(context)!.ingredientNameHint,
                        hintStyle:
                            TextStyle(fontSize: 12, color: AppColors.textTertiary),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        border: OutlineInputBorder(
                            borderRadius: AppRadius.sm),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppRadius.sm,
                          borderSide: BorderSide(color: AppColors.divider),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppRadius.sm,
                          borderSide: const BorderSide(
                              color: AppColors.health, width: 1.5),
                        ),
                        suffixIcon: Icon(Icons.search,
                            size: 16, color: AppColors.textSecondary),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              row.isLoading
                  ? const SizedBox(
                      width: 32,
                      height: 32,
                      child: Padding(
                          padding: EdgeInsets.all(AppSpacing.sm), // 6 -> 8 closest
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : SizedBox(
                      width: 32,
                      height: 32,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                        tooltip: L10n.of(context)!.searchDbOrAi,
                        color: AppColors.premium,
                        onPressed: () => _lookupIngredient(index),
                      ),
                    ),
              SizedBox(
                width: 28,
                height: 28,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.close, size: 16, color: AppColors.error.withValues(alpha: 0.5)),
                  onPressed: () => _removeIngredient(index),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm), // 6 -> 8 closest

          // Row 2: Amount + Unit + kcal/macro
          Row(
            children: [
              SizedBox(
                width: 80,
                child: TextField(
                  controller: row.amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 13),
                  onChanged: (_) {
                    setState(() {
                      row.recalculate();
                    });
                    _recalculateFromIngredients();
                  },
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: L10n.of(context)!.amountHint,
                    hintStyle: TextStyle(fontSize: 11, color: AppColors.textTertiary),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
                    border: OutlineInputBorder(
                        borderRadius: AppRadius.sm),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.sm,
                      borderSide: BorderSide(color: AppColors.divider),
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.sm), // 6 -> 8 closest
              SizedBox(
                width: 72,
                child: DropdownButtonFormField<String>(
                  initialValue: UnitConverter.ensureValid(row.unit),
                  isDense: true,
                  isExpanded: true,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                  dropdownColor: Colors.white,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm), // 6 -> 8 closest
                    border: OutlineInputBorder(
                        borderRadius: AppRadius.sm),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.sm,
                      borderSide: BorderSide(color: AppColors.divider),
                    ),
                  ),
                  items: UnitConverter.compactDropdownItems,
                  onChanged: (v) {
                    if (v != null) setState(() => row.unit = v);
                  },
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${row.calories.toInt()} kcal',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.health),
                  ),
                  Text(
                    'P:${row.protein.toInt()} C:${row.carbs.toInt()} F:${row.fat.toInt()}',
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),

          if (row.isFromDb) ...[
            const SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs), // 6 -> 8, 2 -> 2
              decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4)), // Keep 4px for badge
              child: Text(L10n.of(context)!.fromDatabase,
                  style: const TextStyle(fontSize: 9, color: AppColors.success)),
            ),
          ],

          // Sub-ingredients
          if (row.subIngredients.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(height: 1),
            SizedBox(height: AppSpacing.sm), // 6 -> 8 closest
            _buildSubIngredientsSection(row),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // Sub-Ingredients Section
  // ============================================================
  Widget _buildSubIngredientsSection(_EditableIngredient parentRow) {
    return Padding(
      padding: EdgeInsets.only(left: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.subdirectory_arrow_right,
                  size: 14, color: AppColors.textSecondary),
              SizedBox(width: AppSpacing.xs),
              Text(
                L10n.of(context)!.subIngredients(parentRow.subIngredients.length),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    parentRow.subIngredients.insert(
                        0,
                        _EditableIngredient(
                          name: '',
                          amount: 0,
                          unit: 'g',
                          calories: 0,
                          protein: 0,
                          carbs: 0,
                          fat: 0,
                        ));
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_circle_outline,
                        size: 13, color: AppColors.primary),
                    const SizedBox(width: 2),
                    Text(L10n.of(context)!.addSubIngredient,
                        style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm), // 6 -> 8 closest
          ...parentRow.subIngredients.asMap().entries.map((entry) {
            final subIdx = entry.key;
            final sub = entry.value;
            return _buildSubIngredientRow(parentRow, sub, subIdx);
          }),
        ],
      ),
    );
  }

  Widget _buildSubIngredientRow(
      _EditableIngredient parentRow, _EditableIngredient sub, int subIdx) {
    return Container(
      key: sub.key is ValueKey
          ? sub.key
          : ValueKey('sub_${parentRow.key}_$subIdx'),
      margin: EdgeInsets.only(bottom: AppSpacing.sm, left: AppSpacing.xs), // 6 -> 8 closest
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.background,
                      borderRadius: AppRadius.sm,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          // Name + AI search + delete
          Row(
            children: [
              Container(
                width: 3,
                height: 3,
                margin: EdgeInsets.only(right: AppSpacing.sm), // 6 -> 8 closest
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Autocomplete<Ingredient>(
                  key: ValueKey('sub_ac_${sub.key}_$subIdx'),
                  initialValue:
                      TextEditingValue(text: sub.nameController.text),
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<Ingredient>.empty();
                    }
                    final query = textEditingValue.text.toLowerCase();
                    return _cachedIngredients.where((ing) {
                      return ing.name.toLowerCase().contains(query) ||
                          (ing.nameEn?.toLowerCase().contains(query) ?? false);
                    }).take(6);
                  },
                  displayStringForOption: (Ingredient ing) => ing.name,
                  onSelected: (Ingredient selection) {
                    final amt =
                        double.tryParse(sub.amountController.text) ??
                            selection.baseAmount;
                    final ratio = amt / selection.baseAmount;
                    setState(() {
                      sub.nameController.text = selection.name;
                      sub.nameEn = selection.nameEn;
                      sub.unit = selection.baseUnit;
                      sub.amountController.text = amt.toStringAsFixed(
                          amt == amt.roundToDouble() ? 0 : 1);
                      sub.calories = selection.caloriesPerBase * ratio;
                      sub.protein = selection.proteinPerBase * ratio;
                      sub.carbs = selection.carbsPerBase * ratio;
                      sub.fat = selection.fatPerBase * ratio;
                      sub.isFromDb = true;
                      sub.saveBaseValues();
                      _recalculateParentFromSubs(parentRow);
                      _recalculateFromIngredients();
                    });
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4,
                        borderRadius: AppRadius.sm,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                              maxHeight: 160, maxWidth: 220),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, idx) {
                              final ing = options.elementAt(idx);
                              return ListTile(
                                dense: true,
                                title: Text(ing.name,
                                    style: const TextStyle(fontSize: 11)),
                                subtitle: Text(
                                  '${ing.caloriesPerBase.toInt()} kcal / ${ing.baseAmount.toStringAsFixed(0)} ${ing.baseUnit}',
                                  style: const TextStyle(
                                      fontSize: 9,
                                      color: AppColors.textSecondary),
                                ),
                                onTap: () => onSelected(ing),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  fieldViewBuilder: (context, textEditingController, focusNode,
                      onFieldSubmitted) {
                    textEditingController.addListener(() {
                      if (sub.nameController.text !=
                          textEditingController.text) {
                        sub.nameController.text = textEditingController.text;
                      }
                    });
                    return SizedBox(
                      height: 30,
                      child: TextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        style: const TextStyle(fontSize: 11),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 6),
                          hintText: L10n.of(context)!.subIngredientNameHint,
                          hintStyle: TextStyle(
                              fontSize: 11, color: AppColors.textTertiary),
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.sm, // 6 -> 8 (closest)
                            borderSide:
                                BorderSide(color: AppColors.divider),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: AppRadius.sm, // 6 -> 8 (closest)
                            borderSide:
                                BorderSide(color: AppColors.divider),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              if (!sub.isLoading)
                InkWell(
                  onTap: () => _lookupSubIngredient(parentRow, subIdx),
                  borderRadius: AppRadius.sm, // 6 -> 8 closest
                  child: Container(
                    padding: EdgeInsets.all(AppSpacing.xs), // 5 -> 4 closest
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: AppRadius.sm, // 6 -> 8 closest
                    ),
                    child: const Icon(Icons.search,
                        size: 16, color: AppColors.info),
                  ),
                )
              else
                const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: AppSpacing.xs),
              GestureDetector(
                onTap: () {
                  setState(() {
                    parentRow.subIngredients.removeAt(subIdx);
                    _recalculateParentFromSubs(parentRow);
                    _recalculateFromIngredients();
                  });
                },
                child:
                    Icon(Icons.close, size: 14, color: AppColors.error.withValues(alpha: 0.5)),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm), // 6 -> 8 closest
          // Amount + Unit + Kcal
          Row(
            children: [
              const SizedBox(width: 12),
              SizedBox(
                width: 50,
                height: 28,
                child: TextField(
                  controller: sub.amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 11),
                  textAlign: TextAlign.center,
                  onChanged: (_) {
                    setState(() {
                      sub.recalculate();
                      _recalculateParentFromSubs(parentRow);
                      _recalculateFromIngredients();
                    });
                  },
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 5),
                    hintText: L10n.of(context)!.amountShort,
                    hintStyle:
                        TextStyle(fontSize: 10, color: AppColors.textTertiary),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.sm, // 6 -> 8 closest
                      borderSide: BorderSide(color: AppColors.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.sm, // 6 -> 8 closest
                      borderSide: BorderSide(color: AppColors.divider),
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.xs),
              Text(sub.unit,
                  style:
                      TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              const SizedBox(width: 8),
              Text(
                '${sub.calories.toInt()} kcal',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                'P:${sub.protein.toStringAsFixed(0)} C:${sub.carbs.toStringAsFixed(0)} F:${sub.fat.toStringAsFixed(0)}',
                style:
                    TextStyle(fontSize: 9, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Save & Analyze (analyze immediately, not later)
  // ============================================================
  Future<void> _saveAndAnalyze() async {
    final foodName = _nameController.text.trim();
    if (foodName.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(L10n.of(context)!.pleaseEnterFoodNameFirst),
            duration: const Duration(seconds: 2)),
      );
      return;
    }

    // Check energy first
    if (!await GeminiService.hasEnergy()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10n.of(context)!.notEnoughEnergy),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Show loading
    setState(() => _isAnalyzing = true);

    try {
      final servingSize = double.tryParse(_servingSizeController.text) ?? 1;
      
      // Extract ingredient names and amounts if available
      List<String>? ingredientNames;
      List<Map<String, dynamic>>? userIngredients;
      if (_hasIngredients) {
        ingredientNames = _ingredients
            .where((ing) => ing.nameController.text.trim().isNotEmpty)
            .map((ing) => ing.nameController.text.trim())
            .toList();

        userIngredients = _ingredients
            .where((ing) => ing.nameController.text.trim().isNotEmpty)
            .map((ing) {
              final amount = double.tryParse(ing.amountController.text);
              return <String, dynamic>{
                'name': ing.nameController.text.trim(),
                'amount': (amount != null && amount > 0) ? amount : 1.0,
                'unit': (amount != null && amount > 0) ? ing.unit : 'serving',
              };
            })
            .toList();
        if (userIngredients.isEmpty) userIngredients = null;
      }

      // Analyze with AI
      var result = await GeminiService.analyzeFoodByName(
        foodName,
        servingSize: servingSize,
        servingUnit: _servingUnit,
        ingredientNames: ingredientNames,
        userIngredients: userIngredients,
      );

      // Post-process: enforce user-specified amounts
      if (result != null && userIngredients != null && userIngredients.isNotEmpty) {
        result = GeminiService.enforceUserIngredientAmounts(result, userIngredients);
      }

      if (result == null) {
        if (!mounted) return;
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.of(context)!.analysisFailed),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Record energy usage
      await UsageLimiter.recordAiUsage();
      ref.invalidate(energyBalanceProvider);
      ref.invalidate(currentEnergyProvider);

      // Apply result to controllers
      _nameController.text = result.foodName;
      _caloriesController.text = result.nutrition.calories.toStringAsFixed(0);
      _proteinController.text = result.nutrition.protein.toStringAsFixed(1);
      _carbsController.text = result.nutrition.carbs.toStringAsFixed(1);
      _fatController.text = result.nutrition.fat.toStringAsFixed(1);
      _servingSizeController.text = result.servingSize.toStringAsFixed(0);
      _servingUnit = result.servingUnit;
      
      // Update ingredients from AI if available
      if (result.ingredientsDetail != null && result.ingredientsDetail!.isNotEmpty) {
        _ingredients.clear();
        for (final detail in result.ingredientsDetail!) {
          final ing = _EditableIngredient(
            name: detail.name,
            nameEn: detail.nameEn,
            amount: detail.amount,
            unit: detail.unit,
            calories: detail.calories,
            protein: detail.protein,
            carbs: detail.carbs,
            fat: detail.fat,
          );
          ing.isFromDb = true;
          _ingredients.add(ing);
        }
      }

      setState(() => _isAnalyzing = false);

      // Now save with the analyzed data
      final date = widget.selectedDate ?? DateTime.now();
      final now = DateTime.now();
      final timestamp = DateTime(date.year, date.month, date.day, now.hour, now.minute);

      String? ingredientsJsonStr;
      if (_hasIngredients) {
        ingredientsJsonStr = jsonEncode(_ingredients.map((e) => e.toMap()).toList());
      }

      final entry = FoodEntry()
        ..foodName = result.foodName
        ..mealType = _selectedMealType
        ..timestamp = timestamp
        ..servingSize = result.servingSize
        ..servingUnit = result.servingUnit
        ..calories = result.nutrition.calories
        ..protein = result.nutrition.protein
        ..carbs = result.nutrition.carbs
        ..fat = result.nutrition.fat
        ..baseCalories = result.servingSize > 0 
            ? result.nutrition.calories / result.servingSize 
            : result.nutrition.calories
        ..baseProtein = result.servingSize > 0 
            ? result.nutrition.protein / result.servingSize 
            : result.nutrition.protein
        ..baseCarbs = result.servingSize > 0 
            ? result.nutrition.carbs / result.servingSize 
            : result.nutrition.carbs
        ..baseFat = result.servingSize > 0 
            ? result.nutrition.fat / result.servingSize 
            : result.nutrition.fat
        ..ingredientsJson = ingredientsJsonStr
        ..source = DataSource.aiAnalyzed;

      widget.onSave(entry);

      // Auto-save to MyMeal + Ingredient DB if has ingredients
      if (_hasIngredients && result.ingredientsDetail != null && result.ingredientsDetail!.isNotEmpty) {
        await _autoSaveToDatabase(result.foodName, ingredientsJsonStr);
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10n.of(context)!.aiAnalysisComplete),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      AppLogger.error('[SaveAndAnalyze] Failed', e);
      if (!mounted) return;
      setState(() => _isAnalyzing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10n.of(context)!.analysisFailed),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ============================================================
  // Save (main action)
  // ============================================================
  Future<void> _save() async {
    final foodName = _nameController.text.trim();
    final calories = double.tryParse(_caloriesController.text) ?? 0;
    final protein = double.tryParse(_proteinController.text) ?? 0;
    final carbs = double.tryParse(_carbsController.text) ?? 0;
    final fat = double.tryParse(_fatController.text) ?? 0;
    final servingSize = double.tryParse(_servingSizeController.text) ?? 1.0;
    final hasNutrition = calories > 0 || protein > 0 || carbs > 0 || fat > 0;

    // Must have at least name, kcal, or ingredients
    if (foodName.isEmpty && !hasNutrition && !_hasIngredients) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(L10n.of(context)!.pleaseEnterFoodName),
            duration: const Duration(seconds: 2)),
      );
      return;
    }

    // Auto-name "Quick Add" if no name but has data
    final finalName = foodName.isNotEmpty
        ? foodName
        : L10n.of(context)!.quickAdd;

    final date = widget.selectedDate ?? DateTime.now();
    final now = DateTime.now();
    final timestamp =
        DateTime(date.year, date.month, date.day, now.hour, now.minute);

    // Build ingredientsJson
    String? ingredientsJsonStr;
    if (_hasIngredients) {
      ingredientsJsonStr =
          jsonEncode(_ingredients.map((e) => e.toMap()).toList());
    } else if (_filledFromDb && _selectedMyMealId != null) {
      try {
        final tree = await ref
            .read(mealIngredientTreeProvider(_selectedMyMealId!).future);
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
            if (node.ingredient.detail != null &&
                node.ingredient.detail!.isNotEmpty) {
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
      ..foodName = finalName
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

    // Auto-save to MyMeal + Ingredient DB if has new ingredients AND has nutrition
    // Don't save if waiting for AI analysis (no nutrition yet)
    if (_hasIngredients && !_filledFromDb && hasNutrition) {
      await _autoSaveToDatabase(finalName, ingredientsJsonStr);
    }

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(L10n.of(context)!.foodAdded),
          backgroundColor: AppColors.success),
    );
  }

  /// Auto-save new meal + ingredients to database
  Future<void> _autoSaveToDatabase(
      String mealName, String? ingredientsJsonStr) async {
    if (ingredientsJsonStr == null || ingredientsJsonStr.isEmpty) return;

    try {
      final ingredientsData =
          (jsonDecode(ingredientsJsonStr) as List<dynamic>)
              .map((e) => e as Map<String, dynamic>)
              .toList();

      // Get unique name if duplicate
      final all = await DatabaseService.myMeals.where().findAll();
      final uniqueName = _getUniqueMealName(mealName, all);

      final servingSize = double.tryParse(_servingSizeController.text) ?? 1;

      await ref
          .read(foodEntriesNotifierProvider.notifier)
          .saveIngredientsAndMeal(
        mealName: uniqueName,
        servingDescription: '$servingSize $_servingUnit',
        ingredientsData: ingredientsData,
      );

      ref.invalidate(allMyMealsProvider);
      ref.invalidate(allIngredientsProvider);
      AppLogger.info(
          '[AddFood] Auto-saved "$uniqueName" → MyMeal + ${ingredientsData.length} ingredients');
    } catch (e) {
      AppLogger.warn('[AddFood] Auto-save failed: $e');
    }
  }

  String _getUniqueMealName(String baseName, List<MyMeal> allMeals) {
    final names = allMeals.map((m) => m.name).toSet();
    if (!names.contains(baseName)) return baseName;
    
    int counter = 2;
    while (names.contains('$baseName ($counter)')) {
      counter++;
    }
    return '$baseName ($counter)';
  }
}
