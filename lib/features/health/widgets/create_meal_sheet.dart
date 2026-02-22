import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../core/ai/gemini_service.dart';
import '../../../core/services/usage_limiter.dart';
import '../../../core/database/database_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../features/energy/providers/energy_provider.dart';
import '../providers/my_meal_provider.dart';
import '../models/my_meal.dart';
import '../models/my_meal_ingredient.dart';
import '../models/ingredient.dart';

/// Bottom sheet สำหรับสร้าง/แก้ไขเมนูอาหาร
class CreateMealSheet extends ConsumerStatefulWidget {
  final Function(MyMeal) onSave;

  /// ถ้ามี = edit mode, ถ้า null = create mode
  final MyMeal? existingMeal;

  /// ingredients ของ meal (สำหรับ edit mode)
  final List<MyMealIngredient>? existingIngredients;

  const CreateMealSheet({
    super.key,
    required this.onSave,
    this.existingMeal,
    this.existingIngredients,
  });

  @override
  ConsumerState<CreateMealSheet> createState() => _CreateMealSheetState();
}

class _CreateMealSheetState extends ConsumerState<CreateMealSheet> {
  final _nameController = TextEditingController();
  final _servingSizeController = TextEditingController(text: '1');
  String _servingUnit = 'plate';
  final List<_IngredientRow> _ingredients = [];
  bool _isSaving = false;

  // Track original serving size for scaling ingredients when editing
  double? _originalServingSize;

  // Prevent double-tap on AI lookup
  final Set<_IngredientRow> _lookingUpRows = {};

  // Cache ingredients จาก DB เพื่อให้ Autocomplete ใช้ได้
  List<Ingredient> _cachedIngredients = [];

  bool get _isEditMode => widget.existingMeal != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _nameController.text = widget.existingMeal!.name;
      // Parse baseServingDescription e.g. "1 plate" → size=1, unit="plate"
      final parsed =
          _parseServingDescription(widget.existingMeal!.baseServingDescription);
      _servingSizeController.text = parsed.size.toString();
      _servingUnit = parsed.unit;
      _originalServingSize = parsed.size; // Save original for scaling

      // Prefill ROOT ingredients (sub-ingredients จะโหลดแบบ async)
      if (widget.existingIngredients != null) {
        for (final ing in widget.existingIngredients!) {
          final row = _IngredientRow();
          row.nameController.text = ing.ingredientName;
          row.amountController.text = ing.amount.toStringAsFixed(0);
          row.unit = UnitConverter.ensureValid(ing.unit);
          row.calController.text = ing.calories.toStringAsFixed(0);
          row.proteinController.text = ing.protein.toStringAsFixed(0);
          row.carbsController.text = ing.carbs.toStringAsFixed(0);
          row.fatController.text = ing.fat.toStringAsFixed(0);
          row.detail = ing.detail; // NEW
          // Save base values from existing data
          row.saveBaseValues();
          _ingredients.add(row);

          // NEW: โหลด sub-ingredients แบบ async
          if (ing.isComposite) {
            _loadSubIngredients(row, ing.id);
          }
        }
      }
    }

    // Add listener to serving size to auto-scale ingredients
    _servingSizeController.addListener(_onServingSizeChanged);
  }

  /// โหลด sub-ingredients สำหรับ parent ingredient (จาก MyMealIngredient)
  Future<void> _loadSubIngredients(
      _IngredientRow parentRow, int parentId) async {
    // โหลดจาก Isar database - ใช้ filter ตรงๆ เร็วกว่าโหลดทั้งหมด
    final allSubs = await DatabaseService.myMealIngredients
        .filter()
        .parentIdEqualTo(parentId)
        .sortBySortOrder()
        .findAll();

    if (allSubs.isNotEmpty) {
      final subRows = allSubs.map((sub) {
        final subRow = _IngredientRow();
        subRow.nameController.text = sub.ingredientName;
        subRow.amountController.text = sub.amount.toStringAsFixed(0);
        subRow.unit = UnitConverter.ensureValid(sub.unit);
        subRow.calController.text = sub.calories.toStringAsFixed(0);
        subRow.proteinController.text = sub.protein.toStringAsFixed(0);
        subRow.carbsController.text = sub.carbs.toStringAsFixed(0);
        subRow.fatController.text = sub.fat.toStringAsFixed(0);
        subRow.detail = sub.detail;
        subRow.saveBaseValues();
        return subRow;
      }).toList();

      setState(() {
        parentRow.subIngredients = subRows;
      });
    }
  }
  
  /// เพิ่ม sub-ingredient ว่างๆ ให้ parent ingredient
  void _addSubIngredient(_IngredientRow parentRow) {
    final newSub = _IngredientRow();
    newSub.nameController.text = '';
    newSub.amountController.text = '0';
    newSub.unit = 'g';
    
    setState(() {
      if (parentRow.subIngredients == null) {
        parentRow.subIngredients = [newSub];
      } else {
        parentRow.subIngredients!.add(newSub);
      }
    });
  }

  /// When serving size changes, scale all ingredients proportionally
  void _onServingSizeChanged() {
    if (!_isEditMode ||
        _originalServingSize == null ||
        _originalServingSize == 0) {
      return;
    }

    final newSize = double.tryParse(_servingSizeController.text);
    if (newSize == null || newSize <= 0) return;

    final ratio = newSize / _originalServingSize!;

    // Scale all ingredients
    for (final row in _ingredients) {
      if (row.hasBaseValues) {
        // Use base values to recalculate
        final newAmount = row.baseAmount * ratio;
        row.amountController.text = newAmount.toStringAsFixed(1);
        row.recalculate();
      }
    }

    setState(() {});
  }

  /// Parse "1 plate" → (size: 1.0, unit: "plate")
  ({double size, String unit}) _parseServingDescription(String description) {
    final parts = description.trim().split(' ');
    if (parts.length >= 2) {
      final size = double.tryParse(parts[0]) ?? 1.0;
      final unit = parts.sublist(1).join(' ');
      return (size: size, unit: unit);
    }
    return (size: 1.0, unit: 'serving');
  }

  @override
  void dispose() {
    _servingSizeController.removeListener(_onServingSizeChanged);
    _nameController.dispose();
    _servingSizeController.dispose();
    for (final row in _ingredients) {
      row.dispose();
    }
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

  @override
  Widget build(BuildContext context) {
    // Watch provider เพื่อ subscribe ข้อมูล ingredients จาก DB
    _cachedIngredients = ref.watch(allIngredientsProvider).valueOrNull ?? [];

    return Container(
      margin: AppSpacing.paddingLg,
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.xl,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
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
            // Drag handle
            Center(
              child: Container(
                width: AppSizes.dragHandleWidth,
                height: AppSizes.dragHandleHeight,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: AppRadius.pill,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: AppIcons.iconWithLabel(
                    _isEditMode ? AppIcons.edit : AppIcons.meal,
                    _isEditMode ? L10n.of(context)!.editMealTitle : L10n.of(context)!.createNewMealTitle,
                    iconColor: _isEditMode ? AppIcons.editColor : AppIcons.mealColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildCloseButton(),
              ],
            ),
            const SizedBox(height: 20),

            // ชื่อเมนู
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: L10n.of(context)!.mealNameLabel,
                hintText: L10n.of(context)!.mealNameHint,
                border:
                    OutlineInputBorder(borderRadius: AppRadius.md),
              ),
            ),
            SizedBox(height: AppSpacing.md),

            // Base Serving Size + Unit (2 fields)
            Row(
              children: [
                // Serving Size (number)
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _servingSizeController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: L10n.of(context)!.servingSizeLabel,
                      hintText: '1',
                      border: OutlineInputBorder(
                          borderRadius: AppRadius.md),
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                // Serving Unit (dropdown)
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    initialValue: _getValidUnit(_servingUnit),
                    items: UnitConverter.allDropdownItems,
                    onChanged: (newUnit) {
                      if (newUnit != null) {
                        setState(() => _servingUnit = newUnit);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: L10n.of(context)!.unitRequired,
                      border: OutlineInputBorder(
                          borderRadius: AppRadius.md),
                    ),
                    style: const TextStyle(color: Colors.black),
                    dropdownColor: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.xl),

            // Ingredients
            Row(
              children: [
                Text('🥬 ${L10n.of(context)!.ingredientsSectionTitle}',
                    style:
                        const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const Spacer(),
                // ปุ่ม AI ค้นหาทุกตัวที่ยังไม่มี nutrition
                if (_ingredients.any((r) =>
                    r.nameController.text.trim().isNotEmpty &&
                    (double.tryParse(r.calController.text) ?? 0) == 0))
                  TextButton.icon(
                    onPressed: _lookupAllMissingNutrition,
                    icon: const Icon(Icons.auto_awesome, size: 16),
                    label: Text(L10n.of(context)!.aiAllButton, style: const TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                TextButton.icon(
                  onPressed: _addIngredientRow,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(L10n.of(context)!.addButton),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_ingredients.isEmpty)
              Container(
                padding: AppSpacing.paddingLg,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withValues(alpha: 0.1),
                  borderRadius: AppRadius.md,
                  border: Border.all(
                      color: AppColors.textTertiary.withValues(alpha: 0.3),
                      style: BorderStyle.solid),
                ),
                child: Center(
                  child: Text(
                    L10n.of(context)!.noIngredientsHint,
                    textAlign: TextAlign.center,
                    style: const
                        TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
              ),

            // Ingredient rows
            ..._ingredients.asMap().entries.map((entry) {
              final idx = entry.key;
              final row = entry.value;
              return _buildIngredientRow(row, idx);
            }),
            const SizedBox(height: 16),

            // Total nutrition (calculated or manual)
            Container(
              padding: AppSpacing.paddingMd,
              decoration: BoxDecoration(
                color: AppColors.health.withValues(alpha: 0.1),
                borderRadius: AppRadius.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppIcons.iconWithLabel(
                    AppIcons.statistics,
                    L10n.of(context)!.totalNutritionTitle,
                    iconColor: AppIcons.statisticsColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          const Icon(AppIcons.calories, size: 16, color: AppIcons.caloriesColor),
                          const SizedBox(width: 4),
                          Text(
                            '${_totalCalories.toInt()} kcal',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Text('P:${_totalProtein.toInt()}g',
                          style: const TextStyle(fontSize: 12)),
                      Text('C:${_totalCarbs.toInt()}g',
                          style: const TextStyle(fontSize: 12)),
                      Text('F:${_totalFat.toInt()}g',
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Save button
            AppButton.primary(
              label: _isEditMode ? L10n.of(context)!.saveChangesButton : L10n.of(context)!.saveMealButton,
              icon: Icons.save_rounded,
              isLoading: _isSaving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientRow(_IngredientRow row, int index) {
    return Container(
      key: row.key,
      margin: EdgeInsets.only(bottom: AppSpacing.md - 2),
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md - 2, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        border:
            Border.all(color: AppColors.textTertiary.withValues(alpha: 0.3)),
        borderRadius: AppRadius.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== Row 1: ชื่อวัตถุดิบ + ปุ่ม Gemini + ปุ่มลบ =====
          Row(
            children: [
              Expanded(
                child: _buildIngredientAutocomplete(row),
              ),
              const SizedBox(width: 4),
              if (row.isLookingUp)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  onPressed: () => _lookupIngredientNutrition(row),
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  color: AppColors.primary,
                  tooltip: L10n.of(context)!.searchNutritionWithAi,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              IconButton(
                onPressed: () => setState(() {
                  _ingredients[index].dispose();
                  _ingredients.removeAt(index);
                }),
                icon: const Icon(Icons.close, size: 18, color: AppColors.error),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ===== Row 2: Amount + Unit =====
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: row.amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: L10n.of(context)!.amountLabel,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md - 2, vertical: AppSpacing.md - 2),
                    border: OutlineInputBorder(
                        borderRadius: AppRadius.sm),
                    helperText:
                        row.hasBaseValues ? L10n.of(context)!.kcalAutoCalculated : null,
                    helperStyle:
                        TextStyle(fontSize: 10, color: AppColors.premium.withValues(alpha: 0.6)),
                  ),
                  style: const TextStyle(fontSize: 14),
                  onChanged: (_) {
                    // recalculate kcal/macro if has base values
                    row.recalculate();
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  initialValue: _getValidUnit(row.unit),
                  items: UnitConverter.compactDropdownItems,
                  onChanged: (newUnit) {
                    if (newUnit != null) {
                      setState(() => row.unit = newUnit);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: L10n.of(context)!.unitLabel,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md - 2, vertical: AppSpacing.md - 2),
                    border: OutlineInputBorder(
                        borderRadius: AppRadius.sm),
                  ),
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  dropdownColor: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ===== Row 3: โภชนาการ (kcal, P, C, F) =====
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: row.calController,
                  keyboardType: TextInputType.number,
                  readOnly: row.hasBaseValues,
                  decoration: InputDecoration(
                    labelText: 'kcal',
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.md - 2),
                    border: OutlineInputBorder(
                        borderRadius: AppRadius.sm),
                    filled: row.hasBaseValues,
                    fillColor: row.hasBaseValues ? AppColors.surfaceVariant : null,
                  ),
                  style: const TextStyle(fontSize: 13),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              SizedBox(width: AppSpacing.sm - 2),
              Expanded(
                child: TextField(
                  controller: row.proteinController,
                  keyboardType: TextInputType.number,
                  readOnly: row.hasBaseValues,
                  decoration: InputDecoration(
                    labelText: 'P(g)',
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.md - 2),
                    border: OutlineInputBorder(
                        borderRadius: AppRadius.sm),
                    filled: row.hasBaseValues,
                    fillColor: row.hasBaseValues ? AppColors.surfaceVariant : null,
                  ),
                  style: const TextStyle(fontSize: 13),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              SizedBox(width: AppSpacing.sm - 2),
              Expanded(
                child: TextField(
                  controller: row.carbsController,
                  keyboardType: TextInputType.number,
                  readOnly: row.hasBaseValues,
                  decoration: InputDecoration(
                    labelText: 'C(g)',
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.md - 2),
                    border: OutlineInputBorder(
                        borderRadius: AppRadius.sm),
                    filled: row.hasBaseValues,
                    fillColor: row.hasBaseValues ? AppColors.surfaceVariant : null,
                  ),
                  style: const TextStyle(fontSize: 13),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              SizedBox(width: AppSpacing.sm - 2),
              Expanded(
                child: TextField(
                  controller: row.fatController,
                  keyboardType: TextInputType.number,
                  readOnly: row.hasBaseValues,
                  decoration: InputDecoration(
                    labelText: 'F(g)',
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.md - 2),
                    border: OutlineInputBorder(
                        borderRadius: AppRadius.sm),
                    filled: row.hasBaseValues,
                    fillColor: row.hasBaseValues ? AppColors.surfaceVariant : null,
                  ),
                  style: const TextStyle(fontSize: 13),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          // แสดง base info ถ้ามี
          if (row.hasBaseValues)
            Padding(
              padding: EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                L10n.of(context)!.baseNutritionInfo(row.baseCal.toInt().toString(), row.baseAmount.toStringAsFixed(0), row.unit),
                style: TextStyle(fontSize: 10, color: AppColors.premium.withValues(alpha: 0.6)),
              ),
            ),

          // NEW: แสดง detail ถ้ามี
          if (row.detail != null && row.detail!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: AppSpacing.sm - 2),
              child: Text(
                '${row.detail}',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          // Add Sub-ingredient button
          Padding(
            padding: EdgeInsets.only(top: AppSpacing.sm),
            child: OutlinedButton.icon(
              onPressed: () => _addSubIngredient(row),
              icon: const Icon(Icons.add, size: 14),
              label: Text(
                L10n.of(context)!.addSubIngredientButton,
                style: const TextStyle(fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.info,
                side: BorderSide(color: AppColors.info.withValues(alpha: 0.4)),
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm - 2),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),

          // Sub-ingredients (editable)
          if (row.subIngredients != null && row.subIngredients!.isNotEmpty) ...[
            SizedBox(height: AppSpacing.sm),
            Container(
              padding: AppSpacing.paddingSm,
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.15),
                borderRadius: AppRadius.sm,
                border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.subdirectory_arrow_right,
                          size: 14, color: AppColors.info),
                      SizedBox(width: AppSpacing.xs),
                      Text(
                        L10n.of(context)!.subIngredientsCount(row.subIngredients!.length.toString()),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),
                  ...row.subIngredients!.asMap().entries.map((entry) {
                    final subIndex = entry.key;
                    final sub = entry.value;
                    return Container(
                      margin: EdgeInsets.only(bottom: AppSpacing.sm - 2),
                      padding: AppSpacing.paddingSm,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppSpacing.sm - 2),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row 1: Name (Autocomplete) + AI Search + Delete
                          Row(
                            children: [
                              Expanded(
                                child: Autocomplete<Ingredient>(
                                  key: ValueKey('sub_ac_${sub.key}_$subIndex'),
                                  initialValue: TextEditingValue(text: sub.nameController.text),
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
                                    final amt = double.tryParse(sub.amountController.text) ??
                                        selection.baseAmount;
                                    final ratio = amt / selection.baseAmount;
                                    setState(() {
                                      sub.nameController.text = selection.name;
                                      sub.unit = selection.baseUnit;
                                      sub.amountController.text = amt.toStringAsFixed(0);
                                      sub.calController.text =
                                          (selection.caloriesPerBase * ratio).toStringAsFixed(0);
                                      sub.proteinController.text =
                                          (selection.proteinPerBase * ratio).toStringAsFixed(0);
                                      sub.carbsController.text =
                                          (selection.carbsPerBase * ratio).toStringAsFixed(0);
                                      sub.fatController.text =
                                          (selection.fatPerBase * ratio).toStringAsFixed(0);
                                      sub.saveBaseValues();
                                    });
                                    _recalculateIngredientRow(row);
                                    _recalculateTotal();
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
                                  fieldViewBuilder: (context, textEditingController,
                                      focusNode, onFieldSubmitted) {
                                    textEditingController.addListener(() {
                                      if (sub.nameController.text !=
                                          textEditingController.text) {
                                        sub.nameController.text =
                                            textEditingController.text;
                                      }
                                    });
                                    return SizedBox(
                                      height: 30,
                                      child: TextField(
                                        controller: textEditingController,
                                        focusNode: focusNode,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: L10n.of(context)!.subIngredientNameHintCreate,
                                          hintStyle: TextStyle(
                                              fontSize: 11, color: AppColors.textTertiary),
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: AppSpacing.sm, vertical: AppSpacing.sm - 2),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(AppSpacing.sm - 2),
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
                              // AI Search button
                              if (!sub.isLookingUp)
                                InkWell(
                                  onTap: () => _lookupSubIngredient(row, subIndex),
                                  borderRadius: BorderRadius.circular(AppSpacing.sm - 2),
                                  child: Container(
                                    padding: EdgeInsets.all(AppSpacing.xs + 1),
                                    decoration: BoxDecoration(
                                      color: AppColors.info.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(AppSpacing.sm - 2),
                                    ),
                                    child: const Icon(Icons.search, size: 16, color: AppColors.info),
                                  ),
                                )
                              else
                                const SizedBox(
                                    width: 16, height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2)),
                              SizedBox(width: AppSpacing.xs),
                              // Delete button
                              IconButton(
                                icon: Icon(Icons.close, 
                                    size: 16, color: AppColors.error.withValues(alpha: 0.7)),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                    minWidth: 28, minHeight: 28),
                                onPressed: () {
                                  setState(() {
                                    row.subIngredients!.removeAt(subIndex);
                                    if (row.subIngredients!.isEmpty) {
                                      row.subIngredients = null;
                                    }
                                  });
                                  _recalculateIngredientRow(row);
                                  _recalculateTotal();
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Row 2: Amount + Unit + Kcal + Macros
                          Row(
                            children: [
                              SizedBox(
                                width: 60,
                                child: TextField(
                                  controller: sub.amountController,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontSize: 12),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm - 2, vertical: AppSpacing.sm - 2),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppSpacing.sm - 2),
                                    ),
                                  ),
                                  onChanged: (_) {
                                    setState(() {
                                      sub.recalculate();
                                      _recalculateIngredientRow(row);
                                      _recalculateTotal();
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: AppSpacing.xs),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm - 2, vertical: AppSpacing.sm - 2),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(AppSpacing.sm - 2),
                                ),
                                child: Text(
                                  sub.unit,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              SizedBox(width: AppSpacing.sm),
                              Text(
                                '${sub.calController.text} kcal',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.info,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'P:${sub.proteinController.text} C:${sub.carbsController.text} F:${sub.fatController.text}',
                                style: TextStyle(
                                    fontSize: 9, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    '💡 ${L10n.of(context)!.editSubIngredientHint}',
                    style: TextStyle(
                      fontSize: 9,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Autocomplete สำหรับชื่อวัตถุดิบ - ค้นหาจาก Ingredient DB
  Widget _buildIngredientAutocomplete(_IngredientRow row) {
    return Autocomplete<Ingredient>(
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
        row.nameController.text = selection.name;
        row.amountController.text = selection.baseAmount.toStringAsFixed(
          selection.baseAmount == selection.baseAmount.roundToDouble() ? 0 : 1,
        );
        row.unit = UnitConverter.ensureValid(selection.baseUnit);
        row.calController.text = selection.caloriesPerBase.toStringAsFixed(0);
        row.proteinController.text =
            selection.proteinPerBase.toStringAsFixed(0);
        row.carbsController.text = selection.carbsPerBase.toStringAsFixed(0);
        row.fatController.text = selection.fatPerBase.toStringAsFixed(0);
        row.saveBaseValues();
        setState(() {});
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: AppRadius.sm,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200, maxWidth: 280),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final ing = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(ing.name, style: const TextStyle(fontSize: 13)),
                    subtitle: Text(
                      '${ing.caloriesPerBase.toInt()} kcal / ${ing.baseAmount.toStringAsFixed(0)} ${ing.baseUnit}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                    onTap: () => onSelected(ing),
                  );
                },
              ),
            ),
          ),
        );
      },
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        // Sync: Autocomplete → row.nameController
        textEditingController.addListener(() {
          if (row.nameController.text != textEditingController.text) {
            row.nameController.text = textEditingController.text;
          }
        });
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: L10n.of(context)!.typeIngredientNameHint,
            hintStyle: TextStyle(fontSize: 13, color: AppColors.textTertiary),
            isDense: true,
            contentPadding:
                EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md - 2),
            border: OutlineInputBorder(
              borderRadius: AppRadius.sm,
              borderSide: BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.sm,
              borderSide: BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.sm,
              borderSide:
                  const BorderSide(color: AppColors.health, width: 1.5),
            ),
            suffixIcon: Icon(Icons.search,
                size: 18, color: AppColors.health.withValues(alpha: 0.6)),
          ),
        );
      },
    );
  }

  /// ค้นหาโภชนาการวัตถุดิบด้วย Gemini
  Future<void> _lookupIngredientNutrition(_IngredientRow row) async {
    // Prevent double-tap
    if (_lookingUpRows.contains(row)) return;

    final name = row.nameController.text.trim();
    if (name.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(L10n.of(context)!.pleaseEnterIngredientFirst), duration: const Duration(seconds: 2)),
        );
      }
      return;
    }

    // === ถ้ามีข้อมูลอยู่แล้ว ให้ถามยืนยันก่อน ===
    final currentCal = double.tryParse(row.calController.text) ?? 0;
    if (currentCal > 0 && mounted) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
              SizedBox(width: AppSpacing.md),
              Text(L10n.of(context)!.reAnalyzeQuestion),
            ],
          ),
          content: Text(
            L10n.of(context)!.reAnalyzeContent(name),
            style: const TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(L10n.of(context)!.cancelButton),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
              ),
              child: Text(L10n.of(context)!.reAnalyzeEnergy),
            ),
          ],
        ),
      );

      if (confirmed != true) return; // User cancelled
    }

    // ===== Check amount + unit before sending to Gemini =====
    final amountText = row.amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (amountText.isEmpty || amount == null || amount <= 0) {
      if (mounted) {
        // Warn to enter amount, then ask if want to use default
        final useDefault = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(L10n.of(context)!.amountNotEntered),
            content: Text(
              L10n.of(context)!.amountNotEnteredContent(name),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(L10n.of(context)!.enterManually),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(L10n.of(context)!.use100g),
              ),
            ],
          ),
        );

        if (useDefault != true) return; // User chose "Enter manually"

        // Set default values
        setState(() {
          row.amountController.text = '100';
          row.unit = 'g';
        });
      } else {
        return;
      }
    }

    if (row.unit.trim().isEmpty) {
      // If no unit, use 'g' as default
      setState(() {
        row.unit = 'g';
      });
    }

    final finalAmount = double.tryParse(row.amountController.text) ?? 100;
    final finalUnit = row.unit.trim().isEmpty ? 'g' : row.unit.trim();

    // === ตรวจสอบ Energy ก่อนเรียก AI ===
    final hasEnergy = await GeminiService.hasEnergy();
    if (!hasEnergy && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10n.of(context)!.notEnoughEnergy),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() => row.isLookingUp = true);

    try {
      AppLogger.info('Gemini lookup: "$name" $finalAmount $finalUnit');

      final result = await GeminiService.analyzeFoodByName(
        name,
        servingSize: finalAmount,
        servingUnit: finalUnit,
      );

      if (result != null && mounted) {
        // === Record AI Usage หลังสำเร็จ ===
        await UsageLimiter.recordAiUsage();

        // === อัพเดท Energy Badge ===
        if (!mounted) return;
        ref.invalidate(energyBalanceProvider);
        ref.invalidate(currentEnergyProvider);

        setState(() {
          row.calController.text = result.nutrition.calories.toStringAsFixed(0);
          row.proteinController.text =
              result.nutrition.protein.toStringAsFixed(0);
          row.carbsController.text = result.nutrition.carbs.toStringAsFixed(0);
          row.fatController.text = result.nutrition.fat.toStringAsFixed(0);
          // บันทึก base values เพื่อ recalculate เมื่อเปลี่ยนปริมาณ
          row.saveBaseValues();
          
          // === Load sub-ingredients จาก AI result ===
          if (result.ingredientsDetail != null &&
              result.ingredientsDetail!.isNotEmpty) {
            row.subIngredients = result.ingredientsDetail!.map((sub) {
              final subRow = _IngredientRow();
              subRow.nameController.text = sub.name;
              subRow.amountController.text = sub.amount.toStringAsFixed(0);
              subRow.unit = sub.unit;
              subRow.calController.text = sub.calories.toStringAsFixed(0);
              subRow.proteinController.text = sub.protein.toStringAsFixed(0);
              subRow.carbsController.text = sub.carbs.toStringAsFixed(0);
              subRow.fatController.text = sub.fat.toStringAsFixed(0);
              subRow.saveBaseValues();
              return subRow;
            }).toList();
          }
        });

        // ===== บันทึกลง Ingredient DB ทันที =====
        await _saveIngredientToDb(
          name: result.foodName.isNotEmpty ? result.foodName : name,
          nameEn: result.foodNameEn,
          amount: finalAmount,
          unit: finalUnit,
          calories: result.nutrition.calories,
          protein: result.nutrition.protein,
          carbs: result.nutrition.carbs,
          fat: result.nutrition.fat,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  L10n.of(context)!.ingredientSaved(name, finalAmount.toString(), finalUnit, result.nutrition.calories.toInt().toString())),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // ตรวจสอบว่าเป็น Energy error หรือไม่
        if (e.toString().contains('Insufficient energy')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(L10n.of(context)!.notEnoughEnergy),
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(L10n.of(context)!.searchFailed(e.toString())),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          row.isLookingUp = false;
          _lookingUpRows.remove(row);
        });
      }
    }
  }

  /// บันทึก ingredient ลง DB ทันทีหลัง Gemini lookup สำเร็จ
  /// เพื่อให้ autocomplete ใช้ได้ทันทีครั้งต่อไป
  Future<void> _saveIngredientToDb({
    required String name,
    String? nameEn,
    required double amount,
    required String unit,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
  }) async {
    try {
      final notifier = ref.read(myMealNotifierProvider.notifier);
      await notifier.saveIngredient(
        name: name,
        nameEn: nameEn,
        baseAmount: amount,
        baseUnit: unit,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
        source: 'gemini',
      );
      // Refresh autocomplete list
      if (!mounted) return;
      ref.invalidate(allIngredientsProvider);
      AppLogger.info('Ingredient "$name" saved to DB successfully');
    } catch (e) {
      debugPrint('⚠️ [CreateMeal] บันทึกวัตถุดิบล้มเหลว: $e');
    }
  }

  /// Add new ingredient row (insert at top for visibility)
  void _addIngredientRow() {
    setState(() {
      _ingredients.insert(0, _IngredientRow());
    });
  }

  /// ค้นหาโภชนาการด้วย Gemini สำหรับทุกวัตถุดิบที่ยังไม่มี nutrition (kcal=0)
  Future<void> _lookupAllMissingNutrition() async {
    final missingRows = _ingredients
        .where((r) =>
            r.nameController.text.trim().isNotEmpty &&
            (double.tryParse(r.calController.text) ?? 0) == 0)
        .toList();

    if (missingRows.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(L10n.of(context)!.noIngredientsNeedLookup), duration: const Duration(seconds: 2)),
        );
      }
      return;
    }

    // === แจ้งผู้ใช้ก่อนว่าจะใช้กี่ Energy ===
    if (mounted) {
      final itemCount = missingRows.length;
      final ingredientNames = missingRows
          .map((r) => '• ${r.nameController.text.trim()}')
          .join('\n');

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.warning),
              SizedBox(width: AppSpacing.sm),
              Text(L10n.of(context)!.aiAnalyzeAllTitle),
            ],
          ),
          content: Text(
            L10n.of(context)!.aiAnalyzeAllContent(itemCount.toString(), ingredientNames),
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(L10n.of(context)!.cancelButton),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(ctx, true),
              icon: const Icon(Icons.auto_awesome, size: 16),
              label: Text(L10n.of(context)!.analyzeCountEnergy(itemCount.toString())),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
    }

    // === เช็คว่ามี Energy เพียงพอหรือไม่ ===
    final hasEnergy = await GeminiService.hasEnergy();
    if (!hasEnergy && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10n.of(context)!.notEnoughEnergy),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // ===== เช็ควัตถุดิบที่ยังไม่ได้กรอกปริมาณ =====
    final rowsMissingAmount = missingRows.where((r) {
      final amt = double.tryParse(r.amountController.text.trim());
      return amt == null || amt <= 0;
    }).toList();

    if (rowsMissingAmount.isNotEmpty) {
      if (mounted) {
        final missingNames = rowsMissingAmount
            .map((r) => '• ${r.nameController.text.trim()}')
            .join('\n');

        final proceed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(L10n.of(context)!.someMissingAmount),
            content: Text(
              L10n.of(context)!.someMissingAmountContent(missingNames),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(L10n.of(context)!.goBack),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(L10n.of(context)!.use100g),
              ),
            ],
          ),
        );

        if (proceed != true) return; // ผู้ใช้เลือกกลับไปกรอก

        // Set default for all rows missing amount
        setState(() {
          for (final row in rowsMissingAmount) {
            row.amountController.text = '100';
            if (row.unit.trim().isEmpty) {
              row.unit = 'g';
            }
          }
        });
      } else {
        return;
      }
    }

    // ===== Start looking up all (no need to ask dialog again as already checked) =====
    int success = 0;
    for (final row in missingRows) {
      // Fill in missing units
      if (row.unit.trim().isEmpty) {
        setState(() => row.unit = 'g');
      }

      await _lookupIngredientNutritionDirect(row);
      if ((double.tryParse(row.calController.text) ?? 0) > 0) {
        success++;
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(L10n.of(context)!.searchSuccessCount(success.toString(), missingRows.length.toString())),
          backgroundColor: success > 0 ? AppColors.success : AppColors.error,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Lookup โดยไม่ถาม dialog ปริมาณ (ใช้สำหรับ batch ที่เช็คแล้ว)
  Future<void> _lookupIngredientNutritionDirect(_IngredientRow row) async {
    final name = row.nameController.text.trim();
    if (name.isEmpty) return;

    final finalAmount = double.tryParse(row.amountController.text) ?? 100;
    final finalUnit = row.unit.trim().isEmpty ? 'g' : row.unit.trim();

    // ────── ตรวจสอบ Energy ก่อนเรียก API ──────
    final hasEnergy = await GeminiService.hasEnergy();
    if (!hasEnergy) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.of(context)!.notEnoughEnergy),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    setState(() => row.isLookingUp = true);

    try {
      AppLogger.info('Batch Gemini lookup: "$name" $finalAmount $finalUnit');

      final result = await GeminiService.analyzeFoodByName(
        name,
        servingSize: finalAmount,
        servingUnit: finalUnit,
      );

      if (result != null && mounted) {
        // === Record AI Usage หลังสำเร็จ ===
        await UsageLimiter.recordAiUsage();

        // === อัพเดท Energy Badge ===
        if (!mounted) return;
        ref.invalidate(energyBalanceProvider);
        ref.invalidate(currentEnergyProvider);

        setState(() {
          row.calController.text = result.nutrition.calories.toStringAsFixed(0);
          row.proteinController.text =
              result.nutrition.protein.toStringAsFixed(0);
          row.carbsController.text = result.nutrition.carbs.toStringAsFixed(0);
          row.fatController.text = result.nutrition.fat.toStringAsFixed(0);
          // บันทึก base values เพื่อ recalculate เมื่อเปลี่ยนปริมาณ
          row.saveBaseValues();
          
          // === Load sub-ingredients จาก AI result ===
          if (result.ingredientsDetail != null &&
              result.ingredientsDetail!.isNotEmpty) {
            row.subIngredients = result.ingredientsDetail!.map((sub) {
              final subRow = _IngredientRow();
              subRow.nameController.text = sub.name;
              subRow.amountController.text = sub.amount.toStringAsFixed(0);
              subRow.unit = sub.unit;
              subRow.calController.text = sub.calories.toStringAsFixed(0);
              subRow.proteinController.text = sub.protein.toStringAsFixed(0);
              subRow.carbsController.text = sub.carbs.toStringAsFixed(0);
              subRow.fatController.text = sub.fat.toStringAsFixed(0);
              subRow.saveBaseValues();
              return subRow;
            }).toList();
          }
        });

        // ===== บันทึกลง Ingredient DB ทันที =====
        await _saveIngredientToDb(
          name: result.foodName.isNotEmpty ? result.foodName : name,
          nameEn: result.foodNameEn,
          amount: finalAmount,
          unit: finalUnit,
          calories: result.nutrition.calories,
          protein: result.nutrition.protein,
          carbs: result.nutrition.carbs,
          fat: result.nutrition.fat,
        );
      }
    } catch (e) {
      AppLogger.error('Batch lookup failed for "$name"', e);
      if (mounted && e.toString().contains('Insufficient energy')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.of(context)!.notEnoughEnergy),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          row.isLookingUp = false;
          _lookingUpRows.remove(row);
        });
      }
    }
  }

  /// AI lookup for a sub-ingredient
  Future<void> _lookupSubIngredient(
      _IngredientRow parentRow, int subIdx) async {
    final sub = parentRow.subIngredients![subIdx];
    final subName = sub.nameController.text.trim();

    if (subName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(L10n.of(context)!.pleaseEnterSubFirst)),
      );
      return;
    }

    setState(() => sub.isLookingUp = true);

    try {
      // 1. Try database first
      final dbMatch = _cachedIngredients.where((ing) =>
          ing.name.toLowerCase() == subName.toLowerCase() ||
          (ing.nameEn?.toLowerCase() == subName.toLowerCase()));

      if (dbMatch.isNotEmpty) {
        final ing = dbMatch.first;
        final amount = double.tryParse(sub.amountController.text) ?? ing.baseAmount;
        final ratio = amount / ing.baseAmount;
        setState(() {
          sub.nameController.text = ing.name;
          sub.unit = ing.baseUnit;
          sub.amountController.text = amount.toStringAsFixed(0);
          sub.calController.text = (ing.caloriesPerBase * ratio).toStringAsFixed(0);
          sub.proteinController.text = (ing.proteinPerBase * ratio).toStringAsFixed(0);
          sub.carbsController.text = (ing.carbsPerBase * ratio).toStringAsFixed(0);
          sub.fatController.text = (ing.fatPerBase * ratio).toStringAsFixed(0);
          sub.saveBaseValues();
          sub.isLookingUp = false;
        });
        _recalculateIngredientRow(parentRow);
        _recalculateTotal();
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

      // 2. AI lookup
      final hasEnergy = await GeminiService.hasEnergy();
      if (!hasEnergy && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.of(context)!.notEnoughEnergy),
            duration: const Duration(seconds: 3),
          ),
        );
        setState(() => sub.isLookingUp = false);
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

        setState(() {
          sub.nameController.text = result.foodName;
          sub.calController.text = result.nutrition.calories.toStringAsFixed(0);
          sub.proteinController.text = result.nutrition.protein.toStringAsFixed(0);
          sub.carbsController.text = result.nutrition.carbs.toStringAsFixed(0);
          sub.fatController.text = result.nutrition.fat.toStringAsFixed(0);
          sub.saveBaseValues();
          sub.isLookingUp = false;
        });
        _recalculateIngredientRow(parentRow);
        _recalculateTotal();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(L10n.of(context)!.aiAnalyzedEnergy(subName)),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 2)),
          );
        }
      } else {
        setState(() => sub.isLookingUp = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(L10n.of(context)!.couldNotAnalyzeSubIngredient),
                backgroundColor: AppColors.warning,
                duration: Duration(seconds: 2)),
          );
        }
      }
    } catch (e) {
      setState(() => sub.isLookingUp = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), duration: const Duration(seconds: 2)),
        );
      }
    }
  }

  /// Recalculate parent ingredient's nutrition from its sub-ingredients
  void _recalculateIngredientRow(_IngredientRow row) {
    if (row.subIngredients == null || row.subIngredients!.isEmpty) return;
    
    double totalCal = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    
    for (final sub in row.subIngredients!) {
      totalCal += double.tryParse(sub.calController.text) ?? 0;
      totalProtein += double.tryParse(sub.proteinController.text) ?? 0;
      totalCarbs += double.tryParse(sub.carbsController.text) ?? 0;
      totalFat += double.tryParse(sub.fatController.text) ?? 0;
    }
    
    setState(() {
      row.calController.text = totalCal.round().toString();
      row.proteinController.text = totalProtein.round().toString();
      row.carbsController.text = totalCarbs.round().toString();
      row.fatController.text = totalFat.round().toString();
    });
  }
  
  /// Trigger UI update for total nutrition display
  void _recalculateTotal() {
    setState(() {
      // The getters will automatically recalculate
    });
  }

  double get _totalCalories => _ingredients.fold<double>(
      0, (sum, row) => sum + (double.tryParse(row.calController.text) ?? 0));
  double get _totalProtein => _ingredients.fold<double>(0,
      (sum, row) => sum + (double.tryParse(row.proteinController.text) ?? 0));
  double get _totalCarbs => _ingredients.fold<double>(
      0, (sum, row) => sum + (double.tryParse(row.carbsController.text) ?? 0));
  double get _totalFat => _ingredients.fold<double>(
      0, (sum, row) => sum + (double.tryParse(row.fatController.text) ?? 0));

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(L10n.of(context)!.pleaseEnterMealName), duration: const Duration(seconds: 2)),
      );
      return;
    }

    final servingSize = double.tryParse(_servingSizeController.text) ?? 1.0;
    if (servingSize <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(L10n.of(context)!.pleaseEnterValidServing), duration: const Duration(seconds: 2)),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final notifier = ref.read(myMealNotifierProvider.notifier);

      final ingredients = _ingredients
          .where((row) => row.nameController.text.trim().isNotEmpty)
          .map((row) => MealIngredientInput(
                name: row.nameController.text.trim(),
                amount: double.tryParse(row.amountController.text) ?? 0,
                unit: row.unit.trim().isEmpty ? 'g' : row.unit.trim(),
                calories: double.tryParse(row.calController.text) ?? 0,
                protein: double.tryParse(row.proteinController.text) ?? 0,
                carbs: double.tryParse(row.carbsController.text) ?? 0,
                fat: double.tryParse(row.fatController.text) ?? 0,
              ))
          .toList();

      // Build baseServingDescription from size + unit
      final baseServingDescription = '$servingSize $_servingUnit';

      MyMeal meal;
      if (_isEditMode) {
        meal = await notifier.updateMeal(
          mealId: widget.existingMeal!.id,
          name: _nameController.text.trim(),
          baseServingDescription: baseServingDescription,
          ingredients: ingredients,
        );
      } else {
        meal = await notifier.createMeal(
          name: _nameController.text.trim(),
          baseServingDescription: baseServingDescription,
          ingredients: ingredients,
          source: 'manual',
        );
      }

      widget.onSave(meal);

      // Invalidate providers to refresh UI
      if (!mounted) return;
      ref.invalidate(allMyMealsProvider);
      ref.invalidate(allIngredientsProvider);

      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), duration: const Duration(seconds: 2)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Validate unit string - ensure it exists in dropdown items
  String _getValidUnit(String unit) {
    return UnitConverter.ensureValid(unit);
  }
}

class _IngredientRow {
  _IngredientRow() : key = UniqueKey();

  /// Unique key สำหรับ widget tree — ป้องกัน Flutter reuse state ผิดตัว
  final Key key;

  final nameController = TextEditingController();
  final amountController = TextEditingController();
  String unit =
      'g'; // เปลี่ยนจาก TextEditingController เป็น String (เลือกจาก dropdown)
  final calController = TextEditingController(text: '0');
  final proteinController = TextEditingController(text: '0');
  final carbsController = TextEditingController(text: '0');
  final fatController = TextEditingController(text: '0');
  bool isLookingUp = false; // Gemini lookup state

  // NEW: Nested ingredients support
  String? detail; // คำอธิบายเพิ่มเติม
  List<_IngredientRow>?
      subIngredients; // Sub-ingredients (read-only ในหน้า edit)

  // ===== Base values (nutritional values per 1 unit of base amount) =====
  double baseAmount = 0; // Base amount (e.g., 100 g)
  double baseCal = 0;
  double baseProtein = 0;
  double baseCarbs = 0;
  double baseFat = 0;

  /// Has base values or not (if yes = can recalculate)
  bool get hasBaseValues => baseAmount > 0 && baseCal > 0;

  /// Save base values from current values
  void saveBaseValues() {
    final amt = double.tryParse(amountController.text) ?? 0;
    if (amt <= 0) return;
    baseAmount = amt;
    baseCal = double.tryParse(calController.text) ?? 0;
    baseProtein = double.tryParse(proteinController.text) ?? 0;
    baseCarbs = double.tryParse(carbsController.text) ?? 0;
    baseFat = double.tryParse(fatController.text) ?? 0;
  }

  /// Recalculate kcal/macro from base values when amount changes
  void recalculate() {
    if (!hasBaseValues) return;
    final newAmount = double.tryParse(amountController.text) ?? 0;
    if (newAmount <= 0) return;

    final ratio = newAmount / baseAmount;
    calController.text = (baseCal * ratio).round().toString();
    proteinController.text = (baseProtein * ratio).round().toString();
    carbsController.text = (baseCarbs * ratio).round().toString();
    fatController.text = (baseFat * ratio).round().toString();
    
    // Scale sub-ingredients ตามสัดส่วน parent
    if (subIngredients != null && subIngredients!.isNotEmpty) {
      for (final sub in subIngredients!) {
        if (sub.baseAmount > 0) {
          sub.amountController.text =
              (sub.baseAmount * ratio).toStringAsFixed(0);
          sub.calController.text = (sub.baseCal * ratio).round().toString();
          sub.proteinController.text =
              (sub.baseProtein * ratio).round().toString();
          sub.carbsController.text =
              (sub.baseCarbs * ratio).round().toString();
          sub.fatController.text = (sub.baseFat * ratio).round().toString();
        }
      }
    }
  }

  void dispose() {
    nameController.dispose();
    amountController.dispose();
    // unit is now String, no need to dispose
    calController.dispose();
    proteinController.dispose();
    carbsController.dispose();
    fatController.dispose();

    // Dispose sub-ingredients
    if (subIngredients != null) {
      for (final sub in subIngredients!) {
        sub.dispose();
      }
    }
  }
}
