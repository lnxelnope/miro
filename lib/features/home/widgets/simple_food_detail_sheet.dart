import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart' hide JsonKey, Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/search_mode_selector.dart';
import '../../../core/widgets/food_entry_image.dart';
import '../../../core/ai/gemini_service.dart';
import '../../../core/services/usage_limiter.dart';
import '../../../core/utils/logger.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/ar_scale/models/detected_object_label.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_service.dart';
import '../../../core/database/model_extensions.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../core/utils/batch_analysis_helper.dart';
import '../../health/providers/health_provider.dart';
import '../../health/providers/my_meal_provider.dart';
import '../../health/providers/analysis_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../sharing/models/share_card_config.dart';
import '../../sharing/presentation/share_card_creator_screen.dart';
import '../../sharing/widgets/budget_meter.dart';

class SimpleFoodDetailSheet extends ConsumerStatefulWidget {
  final FoodEntry entry;

  const SimpleFoodDetailSheet({super.key, required this.entry});

  @override
  ConsumerState<SimpleFoodDetailSheet> createState() =>
      _SimpleFoodDetailSheetState();
}

class _SimpleFoodDetailSheetState extends ConsumerState<SimpleFoodDetailSheet> {
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late String _selectedUnit;
  late FoodSearchMode _searchMode;
  bool _isEditingName = false;
  bool _hasChanges = false;
  bool _isReanalyzing = false;
  List<Map<String, dynamic>> _ingredients = [];
  final bool _isAddingIngredient = false;

  // Local nutrition state (recalculated when ingredients change)
  late double _calories;
  late double _protein;
  late double _carbs;
  late double _fat;

  // Original values for ingredient scaling
  late double _originalServingSize;
  List<Map<String, dynamic>> _baseIngredients = [];

  // Multi-image page tracking
  int _imagePage = 0;

  /// กันโหลดซ้ำ — fallback เหมือน FoodDetailBottomSheet เมื่อไม่มี ingredientsJson
  bool _loadedFromMeal = false;

  // Unit options ใช้จาก UnitConverter (single source of truth)

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.entry.foodName);
    _quantityController = TextEditingController(
      text: widget.entry.servingSize > 0
          ? widget.entry.servingSize.toString()
          : '1',
    );
    _selectedUnit = UnitConverter.ensureValid(
      widget.entry.servingUnit.isNotEmpty ? widget.entry.servingUnit : 'serving',
    );
    _searchMode = widget.entry.searchMode;
    _calories = widget.entry.calories;
    _protein = widget.entry.protein;
    _carbs = widget.entry.carbs;
    _fat = widget.entry.fat;
    _originalServingSize = widget.entry.servingSize > 0 ? widget.entry.servingSize : 1;
    _loadIngredients();

    _quantityController.addListener(_onQuantityChanged);
  }

  @override
  void dispose() {
    _quantityController.removeListener(_onQuantityChanged);
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _onQuantityChanged() {
    final newQty = double.tryParse(_quantityController.text);
    if (newQty == null || newQty <= 0) return;

    final entry = widget.entry;
    if (entry.hasBaseValues) {
      setState(() {
        _calories = entry.baseCalories * newQty;
        _protein = entry.baseProtein * newQty;
        _carbs = entry.baseCarbs * newQty;
        _fat = entry.baseFat * newQty;

        // Scale ingredients proportionally
        if (_baseIngredients.isNotEmpty) {
          final ratio = newQty / _originalServingSize;
          _ingredients = _baseIngredients.map((base) {
            final scaled = Map<String, dynamic>.from(base);
            final baseAmt = (base['amount'] as num?)?.toDouble() ?? 0;
            scaled['amount'] = baseAmt * ratio;
            scaled['calories'] = ((base['calories'] as num?)?.toDouble() ?? 0) * ratio;
            scaled['protein'] = ((base['protein'] as num?)?.toDouble() ?? 0) * ratio;
            scaled['carbs'] = ((base['carbs'] as num?)?.toDouble() ?? 0) * ratio;
            scaled['fat'] = ((base['fat'] as num?)?.toDouble() ?? 0) * ratio;
            return scaled;
          }).toList();
        }

        _hasChanges = true;
      });
    }
  }

  void _loadIngredients() {
    if (widget.entry.ingredientsJson != null &&
        widget.entry.ingredientsJson!.isNotEmpty) {
      try {
        final decoded =
            jsonDecode(widget.entry.ingredientsJson!) as List<dynamic>;
        _ingredients = decoded
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        // Deep copy for base reference used when scaling by quantity
        _baseIngredients = decoded
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();

        // Fix: ถ้าผลรวม ingredients ไม่ตรงกับ entry → recalculate
        _fixCaloriesIfMismatch();
        return;
      } catch (_) {}
    }
    if (widget.entry.myMealId != null && !_loadedFromMeal) {
      _loadedFromMeal = true;
      _loadIngredientsFromMyMeal(widget.entry.myMealId!);
    }
  }

  Future<void> _loadIngredientsFromMyMeal(int mealId) async {
    try {
      final tree = await ref.read(mealIngredientTreeProvider(mealId).future);
      if (!mounted || tree.isEmpty) return;
      final maps = ingredientTreeToJsonMaps(tree);
      setState(() {
        _ingredients =
            maps.map((m) => Map<String, dynamic>.from(m)).toList();
        _baseIngredients =
            maps.map((m) => Map<String, dynamic>.from(m)).toList();
      });
      _fixCaloriesIfMismatch();
    } catch (e) {
      AppLogger.warn('SimpleFoodDetail: load ingredients from meal failed', e);
    }
  }

  /// ถ้าผลรวม ingredients ไม่ตรงกับ entry.calories → แก้ไขค่าแสดงผลและ update DB
  void _fixCaloriesIfMismatch() {
    if (_ingredients.isEmpty) return;

    double sumCal = 0, sumP = 0, sumC = 0, sumF = 0;
    for (final ing in _ingredients) {
      sumCal += (ing['calories'] as num?)?.toDouble() ?? 0;
      sumP += (ing['protein'] as num?)?.toDouble() ?? 0;
      sumC += (ing['carbs'] as num?)?.toDouble() ?? 0;
      sumF += (ing['fat'] as num?)?.toDouble() ?? 0;
    }
    if (sumCal <= 0) return;

    final diff = (_calories - sumCal).abs();
    if (diff < 1) return;

    _calories = sumCal;
    _protein = sumP;
    _carbs = sumC;
    _fat = sumF;

    final entry = widget.entry;
    entry.calories = sumCal;
    entry.protein = sumP;
    entry.carbs = sumC;
    entry.fat = sumF;

    final serving = entry.servingSize > 0 ? entry.servingSize : 1.0;
    entry.baseCalories = sumCal / serving;
    entry.baseProtein = sumP / serving;
    entry.baseCarbs = sumC / serving;
    entry.baseFat = sumF / serving;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(foodEntriesNotifierProvider.notifier).updateFoodEntry(entry).then((_) {
        final date = dateOnly(entry.timestamp);
        ref.invalidate(foodEntriesByDateProvider(date));
        ref.invalidate(healthTimelineProvider(date));
        ref.invalidate(todayCaloriesProvider);
        ref.invalidate(todayMacrosProvider);
      });
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
      _recalculateNutrition();
      _hasChanges = true;
    });
  }

  void _editIngredientAmount(int index) {
    final ing = _ingredients[index];
    final oldAmount = (ing['amount'] as num?)?.toDouble() ?? 0;
    final name = ing['name'] as String? ?? '';
    final unit = ing['unit'] as String? ?? 'g';
    final controller = TextEditingController(
      text: oldAmount == oldAmount.roundToDouble()
          ? oldAmount.toInt().toString()
          : oldAmount.toStringAsFixed(1),
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
          title: Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: '${L10n.of(context)!.quantity} ($unit)',
              border: OutlineInputBorder(borderRadius: AppRadius.md),
              isDense: true,
            ),
            onSubmitted: (_) {
              _applyIngredientAmountChange(index, controller.text, oldAmount);
              Navigator.pop(ctx);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(L10n.of(context)!.cancel),
            ),
            FilledButton(
              onPressed: () {
                _applyIngredientAmountChange(index, controller.text, oldAmount);
                Navigator.pop(ctx);
              },
              child: Text(L10n.of(context)!.ok),
            ),
          ],
        );
      },
    );
  }

  void _applyIngredientAmountChange(int index, String newText, double oldAmount) {
    final newAmount = double.tryParse(newText);
    if (newAmount == null || newAmount <= 0 || newAmount == oldAmount) return;
    if (oldAmount <= 0) return;

    final ratio = newAmount / oldAmount;
    setState(() {
      final ing = _ingredients[index];
      ing['amount'] = newAmount;
      ing['calories'] = ((ing['calories'] as num?)?.toDouble() ?? 0) * ratio;
      ing['protein'] = ((ing['protein'] as num?)?.toDouble() ?? 0) * ratio;
      ing['carbs'] = ((ing['carbs'] as num?)?.toDouble() ?? 0) * ratio;
      ing['fat'] = ((ing['fat'] as num?)?.toDouble() ?? 0) * ratio;
      _recalculateNutrition();
      _hasChanges = true;
    });
  }

  void _recalculateNutrition() {
    if (_ingredients.isEmpty) {
      _calories = 0;
      _protein = 0;
      _carbs = 0;
      _fat = 0;
      return;
    }
    double cal = 0, p = 0, c = 0, f = 0;
    for (final ing in _ingredients) {
      cal += (ing['calories'] as num?)?.toDouble() ?? 0;
      p += (ing['protein'] as num?)?.toDouble() ?? 0;
      c += (ing['carbs'] as num?)?.toDouble() ?? 0;
      f += (ing['fat'] as num?)?.toDouble() ?? 0;
    }
    _calories = cal;
    _protein = p;
    _carbs = c;
    _fat = f;
  }

  /// Show dialog to add a new ingredient with DB autocomplete + free AI lookup
  Future<void> _showAddIngredientDialog() async {
    final nameController = TextEditingController();
    final amountController = TextEditingController(text: '100');
    String unit = 'g';
    bool isSearching = false;
    List<Ingredient> dbResults = [];

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setDialogState) {
          Future<void> searchDb(String query) async {
            if (query.length < 2) {
              setDialogState(() => dbResults = []);
              return;
            }
            final results = await (DatabaseService.db.select(DatabaseService.db.ingredients)
                ..where((tbl) => tbl.name.lower().like('%${query.toLowerCase()}%') | tbl.nameEn.lower().like('%${query.toLowerCase()}%'))
                ..orderBy([(tbl) => OrderingTerm.desc(tbl.usageCount)])
                ..limit(5))
                .get();
            if (ctx.mounted) setDialogState(() => dbResults = results);
          }

          void selectFromDb(Ingredient ing) {
            final amount = double.tryParse(amountController.text) ?? 100;
            final newIng = <String, dynamic>{
              'name': ing.name,
              'name_en': ing.nameEn ?? ing.name,
              'amount': amount,
              'unit': ing.baseUnit,
              'calories': ing.calcCalories(amount),
              'protein': ing.calcProtein(amount),
              'carbs': ing.calcCarbs(amount),
              'fat': ing.calcFat(amount),
              'source': 'user_db',
            };
            IngredientActions.incrementUsage(ing.id);
            setState(() {
              _ingredients.insert(0, newIng);
              _recalculateNutrition();
              _hasChanges = true;
            });
            Navigator.pop(ctx);
          }

          Future<void> searchAi() async {
            final name = nameController.text.trim();
            if (name.isEmpty) return;

            final hasEnergy = await GeminiService.hasEnergy();
            if (!hasEnergy) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(L10n.of(context)!.notEnoughEnergy),
                  duration: const Duration(seconds: 3),
                ),
              );
              return;
            }

            final amount = double.tryParse(amountController.text) ?? 100;
            setDialogState(() => isSearching = true);

            try {
              final result = await GeminiService.analyzeFoodByName(
                name,
                servingSize: amount,
                servingUnit: unit,
              );

              if (result != null) {
                await UsageLimiter.recordAiUsage();

                final newIng = <String, dynamic>{
                  'name': result.foodName,
                  'name_en': result.foodNameEn ?? result.foodName,
                  'amount': amount,
                  'unit': unit,
                  'calories': result.nutrition.calories,
                  'protein': result.nutrition.protein,
                  'carbs': result.nutrition.carbs,
                  'fat': result.nutrition.fat,
                  'source': 'user_ai',
                };

                // Save to ingredient DB for future autocomplete
                _saveToIngredientDb(result, amount, unit);

                setState(() {
                  _ingredients.insert(0, newIng);
                  _recalculateNutrition();
                  _hasChanges = true;
                });

                if (ctx.mounted) Navigator.pop(ctx);
              } else {
                if (ctx.mounted) {
                  setDialogState(() => isSearching = false);
                }
              }
            } catch (_) {
              if (ctx.mounted) setDialogState(() => isSearching = false);
            }
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
            title: Row(
              children: [
                const Icon(Icons.restaurant_outlined, size: 20, color: AppColors.success),
                const SizedBox(width: 8),
                Text(L10n.of(context)!.addIngredient,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name field
                  TextField(
                    controller: nameController,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: L10n.of(context)!.ingredientNameHint,
                      hintText: L10n.of(context)!.ingredientSearchHintExample,
                      border: OutlineInputBorder(borderRadius: AppRadius.md),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      suffixIcon: isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(width: 18, height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2)),
                            )
                          : IconButton(
                              icon: const Icon(Icons.search_rounded,
                                  size: 20, color: AppColors.premium),
                              tooltip: 'AI Lookup (1⚡)',
                              onPressed: searchAi,
                            ),
                    ),
                    onChanged: searchDb,
                    onSubmitted: (_) => searchAi(),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Amount + Unit row
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: L10n.of(context)!.quantity,
                            border: OutlineInputBorder(borderRadius: AppRadius.md),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          initialValue: unit,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: L10n.of(context)!.servingUnit,
                            border: OutlineInputBorder(borderRadius: AppRadius.md),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                          ),
                          items: UnitConverter.compactDropdownItems,
                          onChanged: (v) {
                            if (v != null) setDialogState(() => unit = v);
                          },
                        ),
                      ),
                    ],
                  ),

                  // DB search results
                  if (dbResults.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 150),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: dbResults.length,
                        itemBuilder: (_, i) {
                          final ing = dbResults[i];
                          return ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            leading: Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: AppRadius.sm,
                              ),
                              child: const Icon(Icons.restaurant, size: 14, color: AppColors.primary),
                            ),
                            title: Text(ing.name,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            subtitle: Text(
                              '${ing.caloriesPerBase.toInt()} kcal / ${ing.baseAmount.toInt()} ${ing.baseUnit}',
                              style: const TextStyle(fontSize: 11),
                            ),
                            onTap: () => selectFromDb(ing),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(L10n.of(context)!.cancel),
              ),
            ],
          );
        });
      },
    );
  }

  /// Save AI result to ingredient DB for future autocomplete
  Future<void> _saveToIngredientDb(FoodAnalysisResult result, double amount, String unit) async {
    try {
      await IngredientActions.upsert(
        name: result.foodName,
        nameEn: result.foodNameEn,
        baseAmount: amount,
        baseUnit: unit,
        calories: result.nutrition.calories,
        protein: result.nutrition.protein,
        carbs: result.nutrition.carbs,
        fat: result.nutrition.fat,
      );
    } catch (_) {}
  }

  /// Save entry changes to DB (without popping the sheet)
  Future<void> _saveEntry() async {
    final entry = widget.entry;
    bool changed = false;

    final snapName = entry.foodName;
    final snapNameEn = entry.foodNameEn;
    final snapCalories = entry.calories;
    final snapProtein = entry.protein;
    final snapCarbs = entry.carbs;
    final snapFat = entry.fat;
    final snapIngredientsJson = entry.ingredientsJson;

    if (_nameController.text.trim() != entry.foodName) {
      entry.foodName = _nameController.text.trim();
      changed = true;
    }

    final newQty =
        double.tryParse(_quantityController.text) ?? entry.servingSize;
    if (newQty != entry.servingSize) {
      entry.servingSize = newQty;
      if (entry.hasBaseValues) {
        entry.recalculateFromBase();
      }
      changed = true;
    }

    if (_selectedUnit != entry.servingUnit) {
      entry.servingUnit = _selectedUnit;
      changed = true;
    }

    if (_searchMode != entry.searchMode) {
      entry.searchMode = _searchMode;
      changed = true;
    }

    if (_hasChanges) {
      entry.ingredientsJson =
          _ingredients.isNotEmpty ? jsonEncode(_ingredients) : null;
      entry.calories = _calories;
      entry.protein = _protein;
      entry.carbs = _carbs;
      entry.fat = _fat;
      changed = true;
    }

    if (changed) {
      if (entry.originalFoodName == null &&
          entry.source == DataSource.aiAnalyzed) {
        entry.originalFoodName = snapName;
        entry.originalFoodNameEn = snapNameEn;
        entry.originalCalories = snapCalories;
        entry.originalProtein = snapProtein;
        entry.originalCarbs = snapCarbs;
        entry.originalFat = snapFat;
        entry.originalIngredientsJson = snapIngredientsJson;
      }
      entry.editCount += 1;
      entry.isUserCorrected = true;

      await ref
          .read(foodEntriesNotifierProvider.notifier)
          .updateFoodEntry(entry);
      refreshFoodProviders(ref, entry.timestamp);
    }
  }

  Future<void> _save() async {
    await _saveEntry();
    if (mounted) Navigator.pop(context);
  }

  /// Save entry + create a new MyMeal (because ingredients changed)
  Future<void> _saveAndCreateMeal() async {
    final originalName = widget.entry.foodName;
    await _saveEntry();

    if (_ingredients.isNotEmpty) {
      try {
        final currentName = _nameController.text.trim();

        final mealName = (currentName == originalName)
            ? await _getNextMealName(currentName)
            : currentName;

        final inputs = _ingredients.map((ing) => MealIngredientInput(
              name: (ing['name'] as String?) ?? '',
              amount: (ing['amount'] as num?)?.toDouble() ?? 0,
              unit: (ing['unit'] as String?) ?? 'g',
              calories: (ing['calories'] as num?)?.toDouble() ?? 0,
              protein: (ing['protein'] as num?)?.toDouble() ?? 0,
              carbs: (ing['carbs'] as num?)?.toDouble() ?? 0,
              fat: (ing['fat'] as num?)?.toDouble() ?? 0,
            )).toList();

        final serving = '${_quantityController.text.trim()} $_selectedUnit';

        await ref.read(myMealNotifierProvider.notifier).createMeal(
              name: mealName,
              baseServingDescription: serving,
              ingredients: inputs,
              source: 'manual',
            );
        ref.invalidate(allMyMealsProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(L10n.of(context)!.savedAsNewMeal(mealName)),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        AppLogger.error('Failed to create new meal from detail sheet', e);
      }
    }

    if (mounted) Navigator.pop(context);
  }

  /// Find next available name (e.g. "ข้าวผัด 2", "ข้าวผัด 3")
  Future<String> _getNextMealName(String baseName) async {
    final allMeals =
        await DatabaseService.db.select(DatabaseService.db.myMeals).get();
    final existingNames =
        allMeals.map((m) => m.name.toLowerCase()).toSet();
    int suffix = 2;
    String candidate = '$baseName $suffix';
    while (existingNames.contains(candidate.toLowerCase())) {
      suffix++;
      candidate = '$baseName $suffix';
    }
    return candidate;
  }

  Future<void> _reanalyze() async {
    if (_isReanalyzing) return;
    
    final entry = widget.entry;
    final l10n = L10n.of(context)!;
    final newName = _nameController.text.trim();
    
    // Check if name changed and has ingredients
    final nameChanged = newName != entry.foodName;
    final hasIngredients = _ingredients.isNotEmpty;
    
    List<Map<String, dynamic>>? keptIngredients;
    
    // If name changed AND has ingredients → show checkbox dialog
    if (nameChanged && hasIngredients) {
      final checkedFlags = List<bool>.filled(_ingredients.length, true);
      
      final shouldProceed = await showDialog<List<bool>>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.premium, size: 28),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(l10n.keepOrReanalyzeTitle, style: const TextStyle(fontSize: 17)),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.keepOrReanalyzeDesc, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: AppSpacing.md),
                    const Divider(height: 1),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _ingredients.length,
                        itemBuilder: (_, i) {
                          final ing = _ingredients[i];
                          final name = ing['name'] ?? '—';
                          final amount = ing['amount'] ?? 0;
                          final unit = ing['unit'] ?? '';
                          final cal = ing['calories'] ?? 0;
                          return CheckboxListTile(
                            dense: true,
                            controlAffinity: ListTileControlAffinity.leading,
                            value: checkedFlags[i],
                            onChanged: (v) => setDialogState(() => checkedFlags[i] = v ?? true),
                            title: Text(
                              name,
                              style: TextStyle(
                                fontSize: 14,
                                decoration: checkedFlags[i] ? TextDecoration.lineThrough : null,
                                color: checkedFlags[i] ? Colors.grey : null,
                              ),
                            ),
                            subtitle: Text(
                              '$amount $unit  •  ${cal.round()} kcal',
                              style: TextStyle(
                                fontSize: 12,
                                color: checkedFlags[i] ? Colors.grey.shade400 : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, null),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Store kept ingredients indices (unchecked)
                    Navigator.pop(ctx, checkedFlags);
                  },
                  icon: const Icon(Icons.auto_fix_high, size: 18),
                  label: Text(l10n.reanalyze),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.premium,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        ),
      );
      
      if (shouldProceed == null || !mounted) return;
      
      // Build kept ingredients (unchecked)
      keptIngredients = [];
      for (int i = 0; i < _ingredients.length; i++) {
        if (!shouldProceed[i]) {
          keptIngredients.add(_ingredients[i]);
        }
      }
    }
    
    // Snapshot original before re-analysis
    final snapName = entry.foodName;
    final snapNameEn = entry.foodNameEn;
    final snapCalories = entry.calories;
    final snapProtein = entry.protein;
    final snapCarbs = entry.carbs;
    final snapFat = entry.fat;
    final snapIngredientsJson = entry.ingredientsJson;
    
    // Set reanalyzing state
    setState(() => _isReanalyzing = true);
    
    try {
      // Check free edit lookup first (free for user corrections)
      final hasEnergy = await GeminiService.hasEnergy();
      if (!hasEnergy) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.notEnoughEnergy)),
          );
        }
        setState(() => _isReanalyzing = false);
        return;
      }
      
      // Prepare user ingredients for kept items
      final userIngredients = keptIngredients?.map((ing) => <String, dynamic>{
        'name': ing['name'],
        'amount': ing['amount'],
        'unit': ing['unit'],
      }).toList();
      
      // Call Gemini
      FoodAnalysisResult? result;
      if (entry.hasAnyImage && entry.imagePath != null) {
        result = await GeminiService.analyzeFoodImage(
          File(entry.imagePath!),
          foodName: newName,
          searchMode: _searchMode,
          userIngredients: userIngredients,
        );
      } else {
        result = await GeminiService.analyzeFoodByName(
          newName,
          searchMode: _searchMode,
          userIngredients: userIngredients,
        );
      }
      
      if (result == null || !mounted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.reanalyzeSuccess)),
          );
        }
        setState(() => _isReanalyzing = false);
        return;
      }
      
      await UsageLimiter.recordAiUsage();
      
      // Apply result
      BatchAnalysisHelper.applyResultToEntry(entry, result);
      
      // Save correction history
      final correctionHistory = _buildCorrectionHistory(
        snapName, snapNameEn, snapCalories, snapProtein, snapCarbs, snapFat, snapIngredientsJson,
        entry, result,
      );
      entry.correctionHistoryJson = correctionHistory;
      
      // Mark as user corrected
      if (entry.originalFoodName == null && entry.source == DataSource.aiAnalyzed) {
        entry.originalFoodName = snapName;
        entry.originalFoodNameEn = snapNameEn;
        entry.originalCalories = snapCalories;
        entry.originalProtein = snapProtein;
        entry.originalCarbs = snapCarbs;
        entry.originalFat = snapFat;
        entry.originalIngredientsJson = snapIngredientsJson;
      }
      entry.editCount += 1;
      entry.isUserCorrected = true;
      
      // Save to database
      await ref.read(foodEntriesNotifierProvider.notifier).updateFoodEntry(entry);
      refreshFoodProviders(ref, entry.timestamp);
      
      // Update UI inline
      setState(() {
        _nameController.text = entry.foodName;
        _calories = entry.calories;
        _protein = entry.protein;
        _carbs = entry.carbs;
        _fat = entry.fat;
        _loadIngredients();
        _hasChanges = false;
        _isReanalyzing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.reanalyzeSuccess)),
        );
      }
    } catch (e) {
      AppLogger.error('Re-analysis failed', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.analysisFailed)),
        );
      }
      setState(() => _isReanalyzing = false);
    }
  }
  
  String? _buildCorrectionHistory(
    String snapName, String? snapNameEn, double snapCalories, double snapProtein, double snapCarbs, double snapFat, String? snapIngredientsJson,
    FoodEntry entry, FoodAnalysisResult result,
  ) {
    final history = <Map<String, dynamic>>[];
    
    // Try to parse existing history
    if (entry.correctionHistoryJson != null) {
      try {
        final existing = jsonDecode(entry.correctionHistoryJson!) as List;
        history.addAll(existing.cast<Map<String, dynamic>>());
      } catch (_) {}
    }
    
    // Add new correction
    history.add({
      'timestamp': DateTime.now().toIso8601String(),
      'action': 'reanalyze',
      'before': {
        'foodName': snapName,
        'foodNameEn': snapNameEn,
        'calories': snapCalories,
        'protein': snapProtein,
        'carbs': snapCarbs,
        'fat': snapFat,
        'ingredientsJson': snapIngredientsJson,
      },
      'after': {
        'foodName': entry.foodName,
        'foodNameEn': entry.foodNameEn,
        'calories': entry.calories,
        'protein': entry.protein,
        'carbs': entry.carbs,
        'fat': entry.fat,
        'ingredientsJson': entry.ingredientsJson,
      },
      'aiResult': {
        'foodName': result.foodName,
        'foodNameEn': result.foodNameEn,
        'calories': result.nutrition.calories,
        'protein': result.nutrition.protein,
        'carbs': result.nutrition.carbs,
        'fat': result.nutrition.fat,
        'confidence': result.confidence,
      },
    });
    
    return jsonEncode(history);
  }

  bool get _isNameChanged =>
      _nameController.text.trim() != widget.entry.foodName;

  bool get _isDirty {
    if (_hasChanges) return true;
    if (_isNameChanged) return true;
    final qty =
        double.tryParse(_quantityController.text) ?? widget.entry.servingSize;
    if (qty != widget.entry.servingSize) return true;
    final originalUnit = UnitConverter.ensureValid(widget.entry.servingUnit);
    if (_selectedUnit != originalUnit) return true;
    if (_searchMode != widget.entry.searchMode) return true;
    return false;
  }

  bool get _hasNutrition => _calories > 0 || _protein > 0 || _carbs > 0 || _fat > 0;

  /// เริ่มวิเคราะห์เฉพาะรายการนี้ (ใช้เมื่อรายการยังไม่มี nutrition)
  Future<void> _startAnalyzeThisEntry() async {
    final entry = widget.entry;
    final l10n = L10n.of(context)!;
    if (await UsageLimiter.hasReachedDailyCap()) {
      if (!mounted) return;
      final remaining = await UsageLimiter.remainingAnalysesToday();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.dailyCapReached(
            UsageLimiter.maxAnalysesPerDay - remaining,
            UsageLimiter.maxAnalysesPerDay,
          )),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }
    final selectedDate = dateOnly(entry.timestamp);
    ref.read(analysisProvider.notifier).enqueue(
          entries: [entry],
          selectedDate: selectedDate,
        );
    if (mounted) Navigator.pop(context);
  }

  Widget _buildBudgetMeter(FoodEntry entry) {
    final profile = ref.watch(profileNotifierProvider).valueOrNull;
    if (profile == null) return const SizedBox.shrink();

    final todayEntries = ref.watch(foodEntriesByDateProvider(dateOnly(entry.timestamp)));
    final dailyCal = todayEntries.valueOrNull?.fold<double>(0, (sum, e) => sum + e.calories) ?? 0;

    final l10n = L10n.of(context)!;
    double mealBudget;
    String mealLabel;
    switch (entry.mealType) {
      case MealType.breakfast:
        mealBudget = profile.breakfastBudget;
        mealLabel = l10n.breakfastLabel;
      case MealType.lunch:
        mealBudget = profile.lunchBudget;
        mealLabel = l10n.lunchLabel;
      case MealType.dinner:
        mealBudget = profile.dinnerBudget;
        mealLabel = l10n.dinnerLabel;
      case MealType.snack:
        mealBudget = profile.snackBudget;
        mealLabel = l10n.snackLabel;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: BudgetMeterSection(
        mealCalories: _calories,
        mealBudget: mealBudget,
        dailyCalories: dailyCal,
        dailyGoal: profile.calorieGoal,
        protein: _protein,
        proteinGoal: profile.proteinGoal,
        carbs: _carbs,
        carbGoal: profile.carbGoal,
        fat: _fat,
        fatGoal: profile.fatGoal,
        mealLabel: mealLabel,
      ),
    );
  }

  void _openShareCard(FoodEntry entry) {
    final profile = ref.read(profileNotifierProvider).valueOrNull;
    double? mealBudget;
    if (profile != null) {
      switch (entry.mealType) {
        case MealType.breakfast:
          mealBudget = profile.breakfastBudget;
        case MealType.lunch:
          mealBudget = profile.lunchBudget;
        case MealType.dinner:
          mealBudget = profile.dinnerBudget;
        case MealType.snack:
          mealBudget = profile.snackBudget;
      }
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ShareCardCreatorScreen(
          initialConfig: ShareCardConfig(
            type: ShareCardType.foodItem,
            foodEntry: entry,
            mealBudget: mealBudget,
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(FoodEntry entry) {
    final paths = entry.allImagePaths;

    if (paths.length <= 1) {
      return GestureDetector(
        onTap: () => showFoodEntryImage(context, entry),
        child: FoodEntryImageWithOverlay(
          entry: entry,
          width: double.infinity,
          height: 200,
          borderRadius: AppRadius.lg,
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: paths.length,
            onPageChanged: (i) => setState(() => _imagePage = i),
            itemBuilder: (_, i) {
              final file = File(paths[i]);
              final labels = ArImageDetectionData.labelsForImage(
                  entry.arLabelsJson, i);
              final imgSize = ArImageDetectionData.imageSizeForImage(
                  entry.arLabelsJson, i);
              final imgW = imgSize?.width ?? entry.arImageWidth;
              final imgH = imgSize?.height ?? entry.arImageHeight;
              final hasOverlay =
                  labels.isNotEmpty && imgW != null && imgH != null;

              return GestureDetector(
                onTap: () => _showFullScreenImage(file, imageIndex: i),
                child: ClipRRect(
                  borderRadius: AppRadius.lg,
                  child: SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          file,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.surfaceVariant,
                            child: const Icon(Icons.broken_image, size: 40),
                          ),
                        ),
                        if (hasOverlay)
                          CustomPaint(
                            painter: BoundingBoxPainter(
                              labels: labels,
                              imageWidth: imgW,
                              imageHeight: imgH,
                              boxFit: BoxFit.cover,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(paths.length, (i) {
                final active = i == _imagePage;
                return Container(
                  width: active ? 20 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: active
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4),
                  ),
                );
              }),
            ),
          ),
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_imagePage + 1}/${paths.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(File file, {int imageIndex = 0}) {
    final entry = widget.entry;
    final labels =
        ArImageDetectionData.labelsForImage(entry.arLabelsJson, imageIndex);
    final imgSize =
        ArImageDetectionData.imageSizeForImage(entry.arLabelsJson, imageIndex);
    final imgW = imgSize?.width ?? entry.arImageWidth;
    final imgH = imgSize?.height ?? entry.arImageHeight;
    final hasOverlay = labels.isNotEmpty && imgW != null && imgH != null;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: SizedBox(
                width: MediaQuery.of(ctx).size.width - 32,
                height: MediaQuery.of(ctx).size.height * 0.75,
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: hasOverlay
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(file, fit: BoxFit.contain),
                            Positioned.fill(
                              child: CustomPaint(
                                painter: BoundingBoxPainter(
                                  labels: labels,
                                  imageWidth: imgW,
                                  imageHeight: imgH,
                                  boxFit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Image.file(file, fit: BoxFit.contain),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final l10n = L10n.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasImage = entry.hasAnyImage;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.sheetTop,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20, 4, 20,
                MediaQuery.of(context).viewInsets.bottom + 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Image(s) — PageView if multi-angle AR, single otherwise
                  if (hasImage) ...[
                    _buildImageSection(entry),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // 2. Name + Quick Edit
                  Row(
                    children: [
                      Expanded(
                        child: _isEditingName
                            ? TextField(
                                controller: _nameController,
                                autofocus: true,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: AppRadius.md,
                                  ),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.sm,
                                  ),
                                ),
                                onSubmitted: (_) {
                                  setState(() {
                                    _isEditingName = false;
                                  });
                                },
                              )
                            : Text(
                                _nameController.text,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary,
                                ),
                              ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      GestureDetector(
                        onTap: () {
                          setState(() => _isEditingName = !_isEditingName);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: AppRadius.sm,
                          ),
                          child: Icon(
                            _isEditingName
                                ? Icons.check_rounded
                                : Icons.edit_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 2.5 Quantity + Unit
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _quantityController,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: l10n.quantity,
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.md,
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedUnit,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: _ingredients.isNotEmpty
                                ? '${l10n.servingUnit} 🔒'
                                : l10n.servingUnit,
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.md,
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                          ),
                          items: UnitConverter.allDropdownItems,
                          onChanged: _ingredients.isNotEmpty
                              ? null
                              : (v) {
                                  if (v != null && v.isNotEmpty) {
                                    setState(() => _selectedUnit = v);
                                  }
                                },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 2.6 Search Mode (Food / Product)
                  SearchModeSelector(
                    selectedMode: _searchMode,
                    onChanged: (mode) {
                      setState(() {
                        _searchMode = mode;
                        _hasChanges = true;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 3. Summary Energy + Macros (uses local state)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.health.withValues(alpha: 0.08),
                      borderRadius: AppRadius.lg,
                    ),
                    child: Column(
                      children: [
                        Text(
                          _hasNutrition
                              ? '${_calories.toInt()} kcal'
                              : '-- kcal',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: _hasNutrition
                                ? AppColors.health
                                : AppColors.warning,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _macroChip('P', _protein, AppColors.protein),
                            _macroChip('C', _carbs, AppColors.carbs),
                            _macroChip('F', _fat, AppColors.fat),
                          ],
                        ),
                        if (entry.aiConfidence != null && _hasNutrition) ...[
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                entry.aiConfidence! >= 0.85
                                    ? Icons.verified_rounded
                                    : Icons.auto_awesome_rounded,
                                size: 13,
                                color: _confidenceColor(entry.aiConfidence!),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'AI ${(entry.aiConfidence! * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: _confidenceColor(entry.aiConfidence!),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 3.5 Budget Meter (Goal Progress)
                  if (_hasNutrition) _buildBudgetMeter(entry),

                  // 4. Ingredients (view/add/edit/remove)
                  Row(
                    children: [
                      Text(
                        l10n.ingredients,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : AppColors.textPrimary,
                        ),
                      ),
                      if (_ingredients.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_ingredients.length}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                          ),
                        ),
                      ],
                      const Spacer(),
                      GestureDetector(
                        onTap: _isAddingIngredient ? null : _showAddIngredientDialog,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: AppRadius.sm,
                            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add_rounded, size: 14, color: AppColors.success),
                              const SizedBox(width: 2),
                              Text(
                                l10n.addIngredient,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (_ingredients.isNotEmpty)
                    ..._ingredients.asMap().entries.map((e) {
                      final i = e.key;
                      final ing = e.value;
                      final ingName = ing['name'] as String? ?? '';
                      final ingAmt = (ing['amount'] as num?)?.toDouble() ?? 0;
                      return KeyedSubtree(
                        key: ValueKey('ing_${i}_${ingName}_$ingAmt'),
                        child: _buildIngredientRow(i, ing, isDark),
                      );
                    }),
                  if (_ingredients.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        L10n.of(context)!.noIngredientsHint,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white38 : AppColors.textTertiary,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),

                  // 4.5 Detected Objects (simple chips)
                  _buildDetectedObjectsChips(entry, isDark),

                  // 4.6 Share button
                  if (_hasNutrition)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: SizedBox(
                        width: double.infinity,
                        height: AppSizes.buttonMedium,
                        child: OutlinedButton.icon(
                          onPressed: () => _openShareCard(entry),
                          icon: const Icon(Icons.share_rounded, size: 18),
                          label: Text(L10n.of(context)!.share),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(
                              color: AppColors.primary.withValues(alpha: 0.3),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.md,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // 5. Info text
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.06),
                      borderRadius: AppRadius.md,
                      border: Border.all(
                        color: AppColors.info.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 16, color: AppColors.info),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            l10n.useProModeForDetail,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white54
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // 6. Re-analyze / Save / OK button
                  if (_isNameChanged) ...[
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: AppSizes.buttonMedium,
                            child: ElevatedButton(
                              onPressed: _isReanalyzing ? null : _saveAndCreateMeal,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.md,
                                ),
                              ),
                              child: Text(
                                l10n.saveChanges,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: SizedBox(
                            height: AppSizes.buttonMedium,
                            child: ElevatedButton(
                              onPressed: _isReanalyzing ? null : _reanalyze,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.premium,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.md,
                                ),
                              ),
                              child: _isReanalyzing
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.auto_awesome, size: 16),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            l10n.reanalyze,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.2),
                                            borderRadius: AppRadius.sm,
                                          ),
                                          child: const Text(
                                            '1⚡',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      height: AppSizes.buttonMedium,
                      child: ElevatedButton(
                        onPressed: _isReanalyzing
                            ? null
                            : _isDirty
                                ? (_hasChanges ? _saveAndCreateMeal : _save)
                                : !_hasNutrition
                                    ? _startAnalyzeThisEntry
                                    : () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isDirty || !_hasNutrition
                              ? AppColors.primary
                              : isDark
                                  ? AppColors.surfaceVariantDark
                                  : AppColors.surfaceVariant,
                          foregroundColor: _isDirty || !_hasNutrition
                              ? Colors.white
                              : isDark
                                  ? Colors.white70
                                  : AppColors.textPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.md,
                          ),
                        ),
                        child: Text(
                          _isDirty
                              ? l10n.saveChanges
                              : !_hasNutrition
                                  ? l10n.analyzeSelected
                                  : l10n.ok,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientRow(
      int index, Map<String, dynamic> ing, bool isDark) {
    final name = ing['name'] as String? ?? '';
    final amount = (ing['amount'] as num?)?.toDouble();
    final unit = ing['unit'] as String? ?? 'g';
    final kcal = (ing['calories'] as num?)?.toInt();
    final amountStr = amount != null && amount > 0
        ? amount.toStringAsFixed(amount == amount.roundToDouble() ? 0 : 1)
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : AppColors.surfaceVariant,
          borderRadius: AppRadius.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  if (amountStr != null) ...[
                    const SizedBox(height: 2),
                    GestureDetector(
                      onTap: () => _editIngredientAmount(index),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$amountStr $unit',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                const Icon(Icons.edit_rounded, size: 10, color: AppColors.primary),
                              ],
                            ),
                          ),
                          if (kcal != null && kcal > 0) ...[
                            const SizedBox(width: 6),
                            Text(
                              '$kcal kcal',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white54 : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _removeIngredient(index),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectedObjectsChips(FoodEntry entry, bool isDark) {
    final labels = DetectedObjectLabel.decode(entry.arLabelsJson);
    if (labels.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.visibility_rounded,
                size: 14,
                color: isDark ? Colors.white38 : AppColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                'Detected ${labels.length} object${labels.length > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white38 : AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: labels.map((obj) {
              final confPct = (obj.confidence * 100).toStringAsFixed(0);
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  '${obj.label} $confPct%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Color _confidenceColor(double confidence) {
    if (confidence >= 0.85) return AppColors.success;
    if (confidence >= 0.70) return AppColors.warning;
    return AppColors.error;
  }

  Widget _macroChip(String prefix, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.sm,
      ),
      child: Text(
        '$prefix ${value.toInt()}g',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// Full-screen viewer now uses shared FoodEntryFullScreenImage from food_entry_image.dart
