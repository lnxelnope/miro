import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../core/ai/gemini_service.dart';
import '../../../core/services/usage_limiter.dart';
import '../../../features/energy/widgets/no_energy_dialog.dart';
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

  bool get _isEditMode => widget.existingMeal != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _nameController.text = widget.existingMeal!.name;
      // Parse baseServingDescription e.g. "1 plate" → size=1, unit="plate"
      final parsed = _parseServingDescription(widget.existingMeal!.baseServingDescription);
      _servingSizeController.text = parsed.size.toString();
      _servingUnit = parsed.unit;
      _originalServingSize = parsed.size; // Save original for scaling

      // Prefill ingredients
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
          // Save base values from existing data
          row.saveBaseValues();
          _ingredients.add(row);
        }
      }
    }
    
    // Add listener to serving size to auto-scale ingredients
    _servingSizeController.addListener(_onServingSizeChanged);
  }

  /// When serving size changes, scale all ingredients proportionally
  void _onServingSizeChanged() {
    if (!_isEditMode || _originalServingSize == null || _originalServingSize == 0) return;
    
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
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
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(_isEditMode ? '✏️ Edit Meal' : '🍽️ Create New Meal', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // ชื่อเมนู
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Meal Name *',
                hintText: 'e.g. Pad Krapow with fried egg',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),

            // Base Serving Size + Unit (2 fields)
            Row(
              children: [
                // Serving Size (number)
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _servingSizeController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Serving Size *',
                      hintText: '1',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Serving Unit (dropdown)
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    value: _servingUnit,
                    items: UnitConverter.allDropdownItems,
                    onChanged: (newUnit) {
                      if (newUnit != null) {
                        setState(() => _servingUnit = newUnit);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Unit *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    style: const TextStyle(color: Colors.black),
                    dropdownColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Ingredients
            Row(
              children: [
                const Text('🥬 Ingredients', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const Spacer(),
                // ปุ่ม AI ค้นหาทุกตัวที่ยังไม่มี nutrition
                if (_ingredients.any((r) => 
                    r.nameController.text.trim().isNotEmpty && 
                    (double.tryParse(r.calController.text) ?? 0) == 0))
                  TextButton.icon(
                    onPressed: _lookupAllMissingNutrition,
                    icon: const Icon(Icons.auto_awesome, size: 16),
                    label: const Text('AI All', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                TextButton.icon(
                  onPressed: _addIngredientRow,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_ingredients.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.textTertiary.withOpacity(0.3), style: BorderStyle.solid),
                ),
                child: const Center(
                  child: Text(
                    'Tap "Add" button to add ingredients\nOr enter total nutrition below',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.health.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📊 Total Nutrition', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('🔥 ${_totalCalories.toInt()} kcal', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('P:${_totalProtein.toInt()}g', style: const TextStyle(fontSize: 12)),
                      Text('C:${_totalCarbs.toInt()}g', style: const TextStyle(fontSize: 12)),
                      Text('F:${_totalFat.toInt()}g', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.health,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(_isEditMode ? 'Save Changes' : 'Save Meal', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientRow(_IngredientRow row, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.textTertiary.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
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
                  width: 24, height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  onPressed: () => _lookupIngredientNutrition(row),
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  color: AppColors.primary,
                  tooltip: 'Search nutrition with AI',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    helperText: row.hasBaseValues
                        ? '🔄 kcal auto-calculated'
                        : null,
                    helperStyle: TextStyle(fontSize: 10, color: Colors.purple.shade300),
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
                  value: row.unit,
                  items: UnitConverter.compactDropdownItems,
                  onChanged: (newUnit) {
                    if (newUnit != null) {
                      setState(() => row.unit = newUnit);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Unit',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: row.hasBaseValues,
                    fillColor: row.hasBaseValues ? Colors.grey.shade100 : null,
                  ),
                  style: const TextStyle(fontSize: 13),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: row.proteinController,
                  keyboardType: TextInputType.number,
                  readOnly: row.hasBaseValues,
                  decoration: InputDecoration(
                    labelText: 'P(g)',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: row.hasBaseValues,
                    fillColor: row.hasBaseValues ? Colors.grey.shade100 : null,
                  ),
                  style: const TextStyle(fontSize: 13),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: row.carbsController,
                  keyboardType: TextInputType.number,
                  readOnly: row.hasBaseValues,
                  decoration: InputDecoration(
                    labelText: 'C(g)',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: row.hasBaseValues,
                    fillColor: row.hasBaseValues ? Colors.grey.shade100 : null,
                  ),
                  style: const TextStyle(fontSize: 13),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: row.fatController,
                  keyboardType: TextInputType.number,
                  readOnly: row.hasBaseValues,
                  decoration: InputDecoration(
                    labelText: 'F(g)',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: row.hasBaseValues,
                    fillColor: row.hasBaseValues ? Colors.grey.shade100 : null,
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
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '📊 Base: ${row.baseCal.toInt()} kcal / ${row.baseAmount.toStringAsFixed(0)} ${row.unit}',
                style: TextStyle(fontSize: 10, color: Colors.purple.shade300),
              ),
            ),
        ],
      ),
    );
  }

  /// Autocomplete สำหรับชื่อวัตถุดิบ - ค้นหาจาก Ingredient DB
  Widget _buildIngredientAutocomplete(_IngredientRow row) {
    return Autocomplete<Ingredient>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<Ingredient>.empty();
        }
        final allIngredients = ref.read(allIngredientsProvider).valueOrNull ?? [];
        final query = textEditingValue.text.toLowerCase();
        return allIngredients.where((ing) {
          return ing.name.toLowerCase().contains(query) ||
                 (ing.nameEn?.toLowerCase().contains(query) ?? false);
        }).take(8); // จำกัด 8 รายการ
      },
      displayStringForOption: (Ingredient ing) => ing.name,
      onSelected: (Ingredient selection) {
        // เติมข้อมูลโภชนาการจาก DB อัตโนมัติ
        row.nameController.text = selection.name;
        row.amountController.text = selection.baseAmount.toStringAsFixed(
          selection.baseAmount == selection.baseAmount.roundToDouble() ? 0 : 1,
        );
        row.unit = UnitConverter.ensureValid(selection.baseUnit);
        row.calController.text = selection.caloriesPerBase.toStringAsFixed(0);
        row.proteinController.text = selection.proteinPerBase.toStringAsFixed(0);
        row.carbsController.text = selection.carbsPerBase.toStringAsFixed(0);
        row.fatController.text = selection.fatPerBase.toStringAsFixed(0);
        // บันทึก base values เพื่อ recalculate เมื่อเปลี่ยนปริมาณ
        row.saveBaseValues();
        setState(() {});
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
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
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    trailing: Text(
                      'x${ing.usageCount}',
                      style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
                    ),
                    onTap: () => onSelected(ing),
                  );
                },
              ),
            ),
          ),
        );
      },
      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
        // Sync with row.nameController
        if (textEditingController.text.isEmpty && row.nameController.text.isNotEmpty) {
          textEditingController.text = row.nameController.text;
        }
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          onChanged: (value) {
            row.nameController.text = value;
          },
          decoration: InputDecoration(
            labelText: 'Ingredient Name',
            isDense: true,
            border: InputBorder.none,
            suffixIcon: Icon(Icons.search, size: 14, color: AppColors.textTertiary.withOpacity(0.5)),
            suffixIconConstraints: const BoxConstraints(maxWidth: 20, maxHeight: 20),
          ),
          style: const TextStyle(fontSize: 14),
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
          const SnackBar(content: Text('Please enter ingredient name first')),
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
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 12),
              Text('Re-analyze?'),
            ],
          ),
          content: Text(
            '"$name" already has nutrition data.\n\n'
            'Analyzing again will use 1 Energy.\n\n'
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
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Re-analyze (1 Energy)'),
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
            title: const Text('Amount not entered'),
            content: Text(
              'Please enter amount for "$name" first\n'
              'e.g. 100 (grams), 1 (piece), 200 (ml)\n\n'
              'Or use default 100 g?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Enter manually'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Use 100 g'),
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
      await NoEnergyDialog.show(context);
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
          row.proteinController.text = result.nutrition.protein.toStringAsFixed(0);
          row.carbsController.text = result.nutrition.carbs.toStringAsFixed(0);
          row.fatController.text = result.nutrition.fat.toStringAsFixed(0);
          // บันทึก base values เพื่อ recalculate เมื่อเปลี่ยนปริมาณ
          row.saveBaseValues();
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
              content: Text('$name ($finalAmount $finalUnit): ${result.nutrition.calories.toInt()} kcal — ingredient saved'),
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
          await NoEnergyDialog.show(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Search failed: $e'),
              backgroundColor: AppColors.error,
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

  void _addIngredientRow() {
    setState(() {
      _ingredients.add(_IngredientRow());
    });
  }

  /// ค้นหาโภชนาการด้วย Gemini สำหรับทุกวัตถุดิบที่ยังไม่มี nutrition (kcal=0)
  Future<void> _lookupAllMissingNutrition() async {
    // === เพิ่ม Gate Check ===
    // 1. เช็คว่ามี API Key ไหม (จาก Step 30)
    // เช็ค Energy ก่อนเรียก AI
    final hasEnergy = await GeminiService.hasEnergy();
    if (!hasEnergy && mounted) {
      await NoEnergyDialog.show(context);
      return;
    } // Upsell dialog will show automatically
    // === จบ Gate Check ===

    final missingRows = _ingredients.where((r) =>
      r.nameController.text.trim().isNotEmpty &&
      (double.tryParse(r.calController.text) ?? 0) == 0
    ).toList();

    if (missingRows.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No ingredients need nutrition lookup')),
        );
      }
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
            title: const Text('Some ingredients missing amount'),
            content: Text(
              'The following items are missing amounts:\n$missingNames\n\n'
              'Please enter amounts for accurate results\n'
              'Or use default 100 g for all items?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Go back'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Use 100 g'),
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
          content: Text('Search successful: $success/${missingRows.length} items'),
          backgroundColor: success > 0 ? AppColors.success : AppColors.error,
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
        await NoEnergyDialog.show(context);
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
          row.proteinController.text = result.nutrition.protein.toStringAsFixed(0);
          row.carbsController.text = result.nutrition.carbs.toStringAsFixed(0);
          row.fatController.text = result.nutrition.fat.toStringAsFixed(0);
          // บันทึก base values เพื่อ recalculate เมื่อเปลี่ยนปริมาณ
          row.saveBaseValues();
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
        await NoEnergyDialog.show(context);
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

  double get _totalCalories => _ingredients.fold<double>(
      0, (sum, row) => sum + (double.tryParse(row.calController.text) ?? 0));
  double get _totalProtein => _ingredients.fold<double>(
      0, (sum, row) => sum + (double.tryParse(row.proteinController.text) ?? 0));
  double get _totalCarbs => _ingredients.fold<double>(
      0, (sum, row) => sum + (double.tryParse(row.carbsController.text) ?? 0));
  double get _totalFat => _ingredients.fold<double>(
      0, (sum, row) => sum + (double.tryParse(row.fatController.text) ?? 0));

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter meal name')),
      );
      return;
    }

    final servingSize = double.tryParse(_servingSizeController.text) ?? 1.0;
    if (servingSize <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid serving size')),
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
          SnackBar(content: Text('❌ Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _IngredientRow {
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  String unit = 'g'; // เปลี่ยนจาก TextEditingController เป็น String (เลือกจาก dropdown)
  final calController = TextEditingController(text: '0');
  final proteinController = TextEditingController(text: '0');
  final carbsController = TextEditingController(text: '0');
  final fatController = TextEditingController(text: '0');
  bool isLookingUp = false; // Gemini lookup state

  // ===== Base values (nutritional values per 1 unit of base amount) =====
  double baseAmount = 0;   // Base amount (e.g., 100 g)
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
  }

  void dispose() {
    nameController.dispose();
    amountController.dispose();
    // unit is now String, no need to dispose
    calController.dispose();
    proteinController.dispose();
    carbsController.dispose();
    fatController.dispose();
  }
}
