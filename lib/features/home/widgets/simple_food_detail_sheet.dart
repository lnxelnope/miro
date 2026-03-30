import 'dart:async';
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
import '../../../core/services/thumbnail_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/ar_scale/models/detected_object_label.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_service.dart';
import '../../../core/database/model_extensions.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../core/nutrition/ingredients_codec.dart';
import '../../../core/nutrition/ingredients_entry_codec.dart';
import '../../health/providers/health_provider.dart';
import '../../health/providers/my_meal_provider.dart';
import '../../health/providers/analysis_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../energy/providers/gamification_provider.dart';
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

  /// Root indices whose sub-ingredients are visible (default: none = collapsed).
  final Set<int> _expandedIngredientRoots = {};

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

        // Scale ingredients + nested sub_ingredients proportionally
        if (_baseIngredients.isNotEmpty) {
          final ratio = newQty / _originalServingSize;
          _ingredients = _baseIngredients.map((base) {
            final copy = _deepCopyIngredientMap(base);
            _scaleIngredientMapInPlace(copy, ratio);
            return copy;
          }).toList();
        }

        _hasChanges = true;
      });
    }
  }

  /// รายการย่อยจาก map (รองรับทั้ง `sub_ingredients` และ `subIngredients`)
  List<Map<String, dynamic>>? _getSubsListFromMap(Map<String, dynamic> m) {
    final raw = m['sub_ingredients'] ?? m['subIngredients'];
    if (raw is! List || raw.isEmpty) return null;
    final out = <Map<String, dynamic>>[];
    for (final e in raw) {
      if (e is Map<String, dynamic>) {
        out.add(e);
      } else if (e is Map) {
        out.add(Map<String, dynamic>.from(e));
      }
    }
    return out.isEmpty ? null : out;
  }

  Map<String, dynamic> _deepCopyIngredientMap(Map<String, dynamic> src) {
    final m = Map<String, dynamic>.from(src);
    m.remove('subIngredients');
    final subs = _getSubsListFromMap(src);
    if (subs != null && subs.isNotEmpty) {
      m['sub_ingredients'] =
          subs.map((s) => _deepCopyIngredientMap(Map<String, dynamic>.from(s))).toList();
    } else {
      m.remove('sub_ingredients');
    }
    return m;
  }

  void _normalizeIngredientMap(Map<String, dynamic> m) {
    if (m.containsKey('subIngredients') && !m.containsKey('sub_ingredients')) {
      m['sub_ingredients'] = m.remove('subIngredients');
    }
    final subs = _getSubsListFromMap(m);
    if (subs != null) {
      m['sub_ingredients'] = subs;
      for (final s in subs) {
        _normalizeIngredientMap(s);
      }
    }
  }

  void _scaleIngredientMapInPlace(Map<String, dynamic> ing, double ratio) {
    if (ratio == 1.0) return;
    final baseAmt = (ing['amount'] as num?)?.toDouble() ?? 0;
    ing['amount'] = baseAmt * ratio;
    ing['calories'] = ((ing['calories'] as num?)?.toDouble() ?? 0) * ratio;
    ing['protein'] = ((ing['protein'] as num?)?.toDouble() ?? 0) * ratio;
    ing['carbs'] = ((ing['carbs'] as num?)?.toDouble() ?? 0) * ratio;
    ing['fat'] = ((ing['fat'] as num?)?.toDouble() ?? 0) * ratio;
    final subs = _getSubsListFromMap(ing);
    if (subs != null) {
      for (final s in subs) {
        _scaleIngredientMapInPlace(s, ratio);
      }
    }
  }

  void _rollupParentFromSubsMap(Map<String, dynamic> parent) {
    final subs = _getSubsListFromMap(parent);
    if (subs == null || subs.isEmpty) return;
    double c = 0, p = 0, cb = 0, f = 0;
    for (final s in subs) {
      c += (s['calories'] as num?)?.toDouble() ?? 0;
      p += (s['protein'] as num?)?.toDouble() ?? 0;
      cb += (s['carbs'] as num?)?.toDouble() ?? 0;
      f += (s['fat'] as num?)?.toDouble() ?? 0;
    }
    parent['calories'] = c;
    parent['protein'] = p;
    parent['carbs'] = cb;
    parent['fat'] = f;
  }

  /// คง `_baseIngredients` ให้สอดคล้องกับ `_ingredients` ที่ปริมาณรวมปัจจุบัน
  void _syncBaseIngredientsFromCurrent() {
    if (_ingredients.isEmpty) {
      _baseIngredients = [];
      return;
    }
    final currentServing =
        double.tryParse(_quantityController.text) ?? _originalServingSize;
    if (currentServing <= 0) return;
    final factor = _originalServingSize / currentServing;
    _baseIngredients = _ingredients
        .map((ing) {
          final copy = _deepCopyIngredientMap(ing);
          _scaleIngredientMapInPlace(copy, factor);
          return copy;
        })
        .toList();
  }

  void _loadIngredients() {
    _expandedIngredientRoots.clear();
    if (widget.entry.ingredientsJson != null &&
        widget.entry.ingredientsJson!.isNotEmpty) {
      try {
        final parsed = parseIngredientsJson(widget.entry.ingredientsJson);
        final doc = parsed.documentV2;
        if (doc != null && doc.mainIngredients.isNotEmpty) {
          final list = ingredientsDocumentToLegacyList(doc);
          _ingredients = list.map((m) {
            final copy = _deepCopyIngredientMap(Map<String, dynamic>.from(m));
            _normalizeIngredientMap(copy);
            return copy;
          }).toList();
          _baseIngredients =
              _ingredients.map((m) => _deepCopyIngredientMap(m)).toList();
          _fixCaloriesIfMismatch();
          return;
        }
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
        _expandedIngredientRoots.clear();
        _ingredients = maps.map((m) {
          final copy = _deepCopyIngredientMap(Map<String, dynamic>.from(m));
          _normalizeIngredientMap(copy);
          return copy;
        }).toList();
        _baseIngredients =
            _ingredients.map((m) => _deepCopyIngredientMap(m)).toList();
      });
      _fixCaloriesIfMismatch();
    } catch (e) {
      AppLogger.warn('SimpleFoodDetail: load ingredients from meal failed', e);
    }
  }

  /// ถ้าผลรวม ingredients ไม่ตรงกับ entry.calories → แก้ไขค่าแสดงผลและ update DB
  ///
  /// รายการจาก MyMeal เก็บผลรวมโภชนาการ **เต็ม 1 เมนูฐาน** ใน JSON แต่ entry.calories
  /// อาจเป็น **เท่าส่วน** (เช่น 0.5 จาน) — ต้องเทียบกับค่าที่สเกลแล้ว ไม่ใช่ sum เต็ม
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

    final entry = widget.entry;
    final serving = entry.servingSize > 0 ? entry.servingSize : 1.0;

    double expectedCal;
    double expectedP;
    double expectedC;
    double expectedF;

    if (entry.baseCalories > 0) {
      final refServing = sumCal / entry.baseCalories;
      if (refServing <= 0) return;
      final scale = serving / refServing;
      expectedCal = sumCal * scale;
      expectedP = sumP * scale;
      expectedC = sumC * scale;
      expectedF = sumF * scale;
    } else {
      expectedCal = sumCal;
      expectedP = sumP;
      expectedC = sumC;
      expectedF = sumF;
    }

    final diff = (_calories - expectedCal).abs();
    if (diff < 1) return;

    _calories = expectedCal;
    _protein = expectedP;
    _carbs = expectedC;
    _fat = expectedF;

    entry.calories = expectedCal;
    entry.protein = expectedP;
    entry.carbs = expectedC;
    entry.fat = expectedF;

    entry.baseCalories = expectedCal / serving;
    entry.baseProtein = expectedP / serving;
    entry.baseCarbs = expectedC / serving;
    entry.baseFat = expectedF / serving;

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

  void _removeIngredient(int rootIndex, {int? subIndex}) {
    setState(() {
      if (subIndex != null) {
        final parent = _ingredients[rootIndex];
        final subs = _getSubsListFromMap(parent);
        if (subs != null && subIndex >= 0 && subIndex < subs.length) {
          subs.removeAt(subIndex);
          parent.remove('subIngredients');
          if (subs.isEmpty) {
            parent.remove('sub_ingredients');
            parent['calories'] = 0.0;
            parent['protein'] = 0.0;
            parent['carbs'] = 0.0;
            parent['fat'] = 0.0;
            _expandedIngredientRoots.remove(rootIndex);
          } else {
            parent['sub_ingredients'] = subs;
            _rollupParentFromSubsMap(parent);
          }
        }
      } else {
        _ingredients.removeAt(rootIndex);
        _remapExpandedRootsAfterRootRemoved(rootIndex);
      }
      _recalculateNutrition();
      _syncBaseIngredientsFromCurrent();
      _hasChanges = true;
    });
  }

  void _remapExpandedRootsAfterRootRemoved(int removedIndex) {
    final next = <int>{};
    for (final idx in _expandedIngredientRoots) {
      if (idx == removedIndex) continue;
      next.add(idx > removedIndex ? idx - 1 : idx);
    }
    _expandedIngredientRoots
      ..clear()
      ..addAll(next);
  }

  void _shiftExpandedRootsForInsertAt(int insertIndex) {
    final next = <int>{};
    for (final idx in _expandedIngredientRoots) {
      next.add(idx >= insertIndex ? idx + 1 : idx);
    }
    _expandedIngredientRoots
      ..clear()
      ..addAll(next);
  }

  void _editIngredientAmount(int rootIndex, {int? subIndex}) {
    final Map<String, dynamic> ing;
    if (subIndex != null) {
      final subs = _getSubsListFromMap(_ingredients[rootIndex]);
      if (subs == null || subIndex >= subs.length) return;
      ing = subs[subIndex];
    } else {
      ing = _ingredients[rootIndex];
    }
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
              _applyIngredientAmountChange(
                  rootIndex, subIndex, controller.text, oldAmount);
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
                _applyIngredientAmountChange(
                    rootIndex, subIndex, controller.text, oldAmount);
                Navigator.pop(ctx);
              },
              child: Text(L10n.of(context)!.ok),
            ),
          ],
        );
      },
    );
  }

  void _applyIngredientAmountChange(
    int rootIndex,
    int? subIndex,
    String newText,
    double oldAmount,
  ) {
    final newAmount = double.tryParse(newText);
    if (newAmount == null || newAmount <= 0 || newAmount == oldAmount) return;
    if (oldAmount <= 0) return;

    final ratio = newAmount / oldAmount;
    setState(() {
      if (subIndex != null) {
        final parent = _ingredients[rootIndex];
        final subs = _getSubsListFromMap(parent);
        if (subs == null || subIndex >= subs.length) return;
        final ing = subs[subIndex];
        ing['amount'] = newAmount;
        ing['calories'] = ((ing['calories'] as num?)?.toDouble() ?? 0) * ratio;
        ing['protein'] = ((ing['protein'] as num?)?.toDouble() ?? 0) * ratio;
        ing['carbs'] = ((ing['carbs'] as num?)?.toDouble() ?? 0) * ratio;
        ing['fat'] = ((ing['fat'] as num?)?.toDouble() ?? 0) * ratio;
        _rollupParentFromSubsMap(parent);
      } else {
        final ing = _ingredients[rootIndex];
        final subs = _getSubsListFromMap(ing);
        if (subs != null && subs.isNotEmpty) {
          ing['amount'] = newAmount;
          for (final s in subs) {
            _scaleIngredientMapInPlace(s, ratio);
          }
          _rollupParentFromSubsMap(ing);
        } else {
          ing['amount'] = newAmount;
          ing['calories'] =
              ((ing['calories'] as num?)?.toDouble() ?? 0) * ratio;
          ing['protein'] =
              ((ing['protein'] as num?)?.toDouble() ?? 0) * ratio;
          ing['carbs'] = ((ing['carbs'] as num?)?.toDouble() ?? 0) * ratio;
          ing['fat'] = ((ing['fat'] as num?)?.toDouble() ?? 0) * ratio;
        }
      }
      _recalculateNutrition();
      _syncBaseIngredientsFromCurrent();
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

  int _countAllIngredientRows(List<Map<String, dynamic>> roots) {
    var n = roots.length;
    for (final r in roots) {
      final subs = _getSubsListFromMap(r);
      if (subs != null) n += subs.length;
    }
    return n;
  }

  MealIngredientInput _mapToMealIngredientInput(Map<String, dynamic> ing) {
    final subs = _getSubsListFromMap(ing);
    return MealIngredientInput(
      name: (ing['name'] as String?) ?? '',
      nameEn: ing['name_en'] as String?,
      detail: ing['detail'] as String?,
      amount: (ing['amount'] as num?)?.toDouble() ?? 0,
      unit: (ing['unit'] as String?) ?? 'g',
      calories: (ing['calories'] as num?)?.toDouble() ?? 0,
      protein: (ing['protein'] as num?)?.toDouble() ?? 0,
      carbs: (ing['carbs'] as num?)?.toDouble() ?? 0,
      fat: (ing['fat'] as num?)?.toDouble() ?? 0,
      subIngredients: subs?.map(_mapToMealIngredientInput).toList(),
      ingredientImagePath: ing['imagePath'] as String?,
      ingredientArBoundingBox: ing['arBoundingBox'] as String?,
      ingredientArImageWidth: (ing['arImageWidth'] as num?)?.toInt(),
      ingredientArImageHeight: (ing['arImageHeight'] as num?)?.toInt(),
    );
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
              _shiftExpandedRootsForInsertAt(0);
              _ingredients.insert(0, newIng);
              _recalculateNutrition();
              _syncBaseIngredientsFromCurrent();
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
                  _shiftExpandedRootsForInsertAt(0);
                  _ingredients.insert(0, newIng);
                  _recalculateNutrition();
                  _syncBaseIngredientsFromCurrent();
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
      if (_ingredients.isNotEmpty) {
        final doc = legacyListToV2(_ingredients);
        entry.ingredientsJson = serializeIngredientsV2(doc);
        applyIngredientsRollupToFoodEntry(entry, doc);
      } else {
        entry.ingredientsJson = null;
        entry.calories = _calories;
        entry.protein = _protein;
        entry.carbs = _carbs;
        entry.fat = _fat;
        final ss = entry.servingSize > 0 ? entry.servingSize : 1.0;
        entry.baseCalories = _calories / ss;
        entry.baseProtein = _protein / ss;
        entry.baseCarbs = _carbs / ss;
        entry.baseFat = _fat / ss;
      }
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

        final inputs =
            _ingredients.map((ing) => _mapToMealIngredientInput(ing)).toList();

        final serving = '${_quantityController.text.trim()} $_selectedUnit';

        final entryAfterSave = widget.entry;
        String? mealImagePath;
        for (final p in entryAfterSave.allImagePaths) {
          if (p.isNotEmpty && File(p).existsSync()) {
            mealImagePath = p;
            break;
          }
        }

        final created = await ref.read(myMealNotifierProvider.notifier).createMeal(
              name: mealName,
              baseServingDescription: serving,
              ingredients: inputs,
              source: 'manual',
              imagePath: mealImagePath,
              thumbnailUrl: entryAfterSave.thumbnailUrl,
              thumbnailFirebasePath: entryAfterSave.thumbnailFirebasePath,
            );
        ref.invalidate(allMyMealsProvider);

        if (created.hasMealLocalImage) {
          unawaited(
            ThumbnailService.uploadMyMealThumbnail(
              meal: created,
              imageFile: File(created.imagePath!),
            ),
          );
        }

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

    final paths = entry.allImagePaths;
    final safePage = paths.isEmpty
        ? 0
        : _imagePage.clamp(0, paths.length - 1);
    final shareHeroPath =
        paths.isNotEmpty ? paths[safePage] : null;

    final referralCode = ref.read(gamificationProvider).miroId;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ShareCardCreatorScreen(
          initialConfig: ShareCardConfig(
            type: ShareCardType.foodItem,
            foodEntry: entry,
            mealBudget: mealBudget,
            heroImagePath: shareHeroPath,
            referralCode: referralCode,
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
                          initialValue: UnitConverter.ensureValid(_selectedUnit),
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
                            '${_countAllIngredientRows(_ingredients)}',
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
                    ..._ingredients.asMap().entries.expand((e) {
                      final i = e.key;
                      final ing = e.value;
                      final ingName = ing['name'] as String? ?? '';
                      final ingAmt = (ing['amount'] as num?)?.toDouble() ?? 0;
                      final subs = _getSubsListFromMap(ing);
                      final hasSubs = subs != null && subs.isNotEmpty;
                      final subsExpanded =
                          hasSubs && _expandedIngredientRoots.contains(i);
                      final rows = <Widget>[
                        KeyedSubtree(
                          key: ValueKey('ing_root_${i}_${ingName}_$ingAmt'),
                          child: _buildIngredientRow(
                            rootIndex: i,
                            ing: ing,
                            isDark: isDark,
                            isSub: false,
                            hasCollapsibleSubs: hasSubs,
                            subsExpanded: subsExpanded,
                            onToggleSubs: hasSubs
                                ? () => setState(() {
                                      if (_expandedIngredientRoots.contains(i)) {
                                        _expandedIngredientRoots.remove(i);
                                      } else {
                                        _expandedIngredientRoots.add(i);
                                      }
                                    })
                                : null,
                          ),
                        ),
                      ];
                      if (subs != null && subsExpanded) {
                        for (var si = 0; si < subs.length; si++) {
                          final sub = subs[si];
                          final sName = sub['name'] as String? ?? '';
                          final sAmt = (sub['amount'] as num?)?.toDouble() ?? 0;
                          rows.add(
                            KeyedSubtree(
                              key: ValueKey('ing_sub_${i}_${si}_${sName}_$sAmt'),
                              child: _buildIngredientRow(
                                rootIndex: i,
                                subIndex: si,
                                ing: sub,
                                isDark: isDark,
                                isSub: true,
                              ),
                            ),
                          );
                        }
                      }
                      return rows;
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

                  const SizedBox(height: AppSpacing.xl),

                  // 5. Save / OK / Analyze (เปลี่ยนชื่อแล้วใช้แค่บันทึก — ไม่มี Re-analyze)
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonMedium,
                    child: ElevatedButton(
                      onPressed: _isDirty
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

                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientRow({
    required int rootIndex,
    int? subIndex,
    required Map<String, dynamic> ing,
    required bool isDark,
    required bool isSub,
    bool hasCollapsibleSubs = false,
    bool subsExpanded = false,
    VoidCallback? onToggleSubs,
  }) {
    final name = ing['name'] as String? ?? '';
    final amount = (ing['amount'] as num?)?.toDouble();
    final unit = ing['unit'] as String? ?? 'g';
    final kcal = (ing['calories'] as num?)?.toInt();
    final amountStr = amount != null && amount > 0
        ? amount.toStringAsFixed(amount == amount.roundToDouble() ? 0 : 1)
        : null;
    final l10n = L10n.of(context)!;
    final nameStyle = TextStyle(
      fontSize: isSub ? 12 : 13,
      fontWeight: FontWeight.w600,
      color: isDark ? Colors.white : AppColors.textPrimary,
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: AppSpacing.xs,
        left: isSub ? AppSpacing.md : 0,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: isSub ? 0.04 : 0.06)
              : (isSub ? AppColors.surfaceVariant.withValues(alpha: 0.65) : AppColors.surfaceVariant),
          borderRadius: AppRadius.sm,
          border: isSub
              ? Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : AppColors.divider.withValues(alpha: 0.5),
                )
              : null,
        ),
        child: Row(
          children: [
            if (!isSub)
              SizedBox(
                width: 32,
                child: hasCollapsibleSubs && onToggleSubs != null
                    ? Tooltip(
                        message: subsExpanded
                            ? l10n.hideDetails
                            : l10n.showDetails,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onToggleSubs,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Icon(
                                subsExpanded
                                    ? Icons.keyboard_arrow_down_rounded
                                    : Icons.keyboard_arrow_right_rounded,
                                size: 22,
                                color: isDark
                                    ? Colors.white54
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      )
                    : null,
              ),
            if (isSub) ...[
              Icon(
                Icons.subdirectory_arrow_right,
                size: 14,
                color: isDark ? Colors.white38 : AppColors.textTertiary,
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (amountStr == null)
                    GestureDetector(
                      onTap: () =>
                          _editIngredientAmount(rootIndex, subIndex: subIndex),
                      child: Text(name, style: nameStyle),
                    )
                  else
                    Text(name, style: nameStyle),
                  if (amountStr != null) ...[
                    const SizedBox(height: 2),
                    GestureDetector(
                      onTap: () =>
                          _editIngredientAmount(rootIndex, subIndex: subIndex),
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
            Tooltip(
              message: l10n.delete,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () =>
                      _removeIngredient(rootIndex, subIndex: subIndex),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
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
