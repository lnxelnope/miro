import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/enums.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/search_mode_selector.dart';
import '../../../l10n/app_localizations.dart';
import '../../health/models/food_entry.dart';
import '../../health/providers/health_provider.dart';
import '../../../core/database/database_service.dart';

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

  // Local nutrition state (recalculated when ingredients change)
  late double _calories;
  late double _protein;
  late double _carbs;
  late double _fat;

  // Original values for ingredient scaling
  late double _originalServingSize;
  List<Map<String, dynamic>> _baseIngredients = [];

  static const _unitOptions = [
    'serving', 'piece', 'g', 'ml', 'cup', 'tbsp', 'plate', 'bowl',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.entry.foodName);
    _quantityController = TextEditingController(
      text: widget.entry.servingSize > 0
          ? widget.entry.servingSize.toString()
          : '1',
    );
    _selectedUnit = widget.entry.servingUnit.isNotEmpty
        ? widget.entry.servingUnit
        : 'serving';
    if (!_unitOptions.contains(_selectedUnit)) {
      _selectedUnit = 'serving';
    }
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
      } catch (_) {}
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

  Future<void> _save() async {
    final entry = widget.entry;
    bool changed = false;

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
      entry.updatedAt = DateTime.now();
      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.foodEntries.put(entry);
      });
      refreshFoodProviders(ref, entry.timestamp);
    }

    if (mounted) Navigator.pop(context);
  }

  bool get _isDirty {
    if (_hasChanges) return true;
    if (_nameController.text.trim() != widget.entry.foodName) return true;
    final qty =
        double.tryParse(_quantityController.text) ?? widget.entry.servingSize;
    if (qty != widget.entry.servingSize) return true;
    final originalUnit = widget.entry.servingUnit.isNotEmpty
        ? widget.entry.servingUnit
        : 'serving';
    if (_selectedUnit != originalUnit) return true;
    if (_searchMode != widget.entry.searchMode) return true;
    return false;
  }

  bool get _hasNutrition => _calories > 0 || _protein > 0 || _carbs > 0 || _fat > 0;

  void _showFullScreenImage(BuildContext context, String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullScreenImageView(imagePath: imagePath),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final l10n = L10n.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasImage =
        entry.imagePath != null && File(entry.imagePath!).existsSync();

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
                  // 1. Image (tap to view full screen, tap again to close)
                  if (hasImage) ...[
                    GestureDetector(
                      onTap: () => _showFullScreenImage(context, entry.imagePath!),
                      child: ClipRRect(
                        borderRadius: AppRadius.lg,
                        child: Image.file(
                          File(entry.imagePath!),
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
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
                          value: _selectedUnit,
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
                          items: _unitOptions
                              .map((u) => DropdownMenuItem(
                                  value: u, child: Text(u)))
                              .toList(),
                          onChanged: _ingredients.isNotEmpty
                              ? null
                              : (v) {
                                  if (v != null) setState(() => _selectedUnit = v);
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
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 4. Ingredients (ถ้ามี)
                  if (_ingredients.isNotEmpty) ...[
                    Text(
                      l10n.ingredients,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ..._ingredients.asMap().entries.map((e) {
                      final i = e.key;
                      final ing = e.value;
                      return _buildIngredientRow(i, ing, isDark);
                    }),
                    const SizedBox(height: AppSpacing.lg),
                  ],

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

                  // 6. OK / Save button
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonMedium,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isDirty
                            ? AppColors.primary
                            : isDark
                                ? AppColors.surfaceVariantDark
                                : AppColors.surfaceVariant,
                        foregroundColor: _isDirty
                            ? Colors.white
                            : isDark
                                ? Colors.white70
                                : AppColors.textPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.md,
                        ),
                      ),
                      child: Text(
                        _isDirty ? l10n.saveChanges : l10n.ok,
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
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Icon(Icons.edit_rounded, size: 10, color: AppColors.primary),
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

/// Full-screen image viewer. Tap anywhere to close.
class _FullScreenImageView extends StatelessWidget {
  final String imagePath;

  const _FullScreenImageView({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        color: Colors.black,
        child: Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.file(
              File(imagePath),
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.broken_image_rounded,
                size: 64,
                color: Colors.white54,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
