import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/logger.dart';
import '../../../core/constants/enums.dart';
import '../../../core/ai/gemini_service.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../core/services/usage_limiter.dart';
import '../../../features/energy/widgets/no_energy_dialog.dart';
import '../../../features/energy/providers/energy_provider.dart';
import '../models/food_entry.dart';
import '../models/ingredient.dart';
import '../providers/my_meal_provider.dart';

// ===== Editable Ingredient Row Model =====
class _EditableIngredient {
  final TextEditingController nameController;
  final TextEditingController amountController;
  String unit;
  String? nameEn;
  final String originalName; // เก็บชื่อเดิมเพื่อเช็คว่าเปลี่ยนหรือไม่

  double baseCalories, baseProtein, baseCarbs, baseFat, baseAmount;
  double calories, protein, carbs, fat;
  bool isLoading = false;
  bool isFromDb = false;

  _EditableIngredient({
    required String name,
    this.nameEn,
    required double amount,
    required this.unit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  })  : nameController = TextEditingController(text: name),
        amountController = TextEditingController(text: amount > 0 ? amount.toStringAsFixed(0) : ''),
        originalName = name, // บันทึกชื่อเดิมไว้
        baseAmount = amount > 0 ? amount : 1,
        baseCalories = amount > 0 ? calories / amount : calories,
        baseProtein = amount > 0 ? protein / amount : protein,
        baseCarbs = amount > 0 ? carbs / amount : carbs,
        baseFat = amount > 0 ? fat / amount : fat;

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
  }

  void dispose() {
    nameController.dispose();
    amountController.dispose();
  }

  Map<String, dynamic> toMap() => {
        'name': nameController.text.trim(),
        'name_en': nameEn,
        'amount': double.tryParse(amountController.text) ?? 0,
        'unit': unit,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      };
}

/// Bottom Sheet สำหรับแก้ไข FoodEntry
/// - เปลี่ยนปริมาณ → recalculate kcal/macro อัตโนมัติ
/// - แก้ไขวัตถุดิบ (ชื่อ/ปริมาณ) + ค้น DB / Gemini ทีละรายการ
class EditFoodBottomSheet extends ConsumerStatefulWidget {
  final FoodEntry entry;
  final Function(FoodEntry) onSave;

  const EditFoodBottomSheet({
    super.key,
    required this.entry,
    required this.onSave,
  });

  @override
  ConsumerState<EditFoodBottomSheet> createState() => _EditFoodBottomSheetState();
}

class _EditFoodBottomSheetState extends ConsumerState<EditFoodBottomSheet> {
  late TextEditingController _nameController;
  late TextEditingController _servingSizeController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;

  late String _servingUnit;
  
  // Prevent double-tap on AI lookup
  final Set<int> _lookingUpIndices = {};
  late MealType _selectedMealType;

  late double _baseCalories, _baseProtein, _baseCarbs, _baseFat;
  late bool _hasBaseValues;

  // วันที่/เวลาที่แก้ไขได้
  late DateTime _timestamp;

  // Editable ingredients
  final List<_EditableIngredient> _ingredients = [];
  bool _ingredientsLoaded = false;
  bool get _hasIngredients => _ingredients.isNotEmpty;
  
  /// ตรวจว่า auto-recalculate ได้ไหม (มี base หรือ original ที่ใช้ ratio ได้)
  bool get _canAutoRecalculate => _hasBaseValues || _hasIngredients || _originalCalories > 0;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;

    _nameController = TextEditingController(text: entry.foodName);
    _servingSizeController = TextEditingController(text: entry.servingSize.toString());
    _caloriesController = TextEditingController(text: entry.calories.toInt().toString());
    _proteinController = TextEditingController(text: entry.protein.toInt().toString());
    _carbsController = TextEditingController(text: entry.carbs.toInt().toString());
    _fatController = TextEditingController(text: entry.fat.toInt().toString());

    _servingUnit = entry.servingUnit;
    _selectedMealType = entry.mealType;
    _timestamp = entry.timestamp;

    // Base values
    if (entry.hasBaseValues) {
      _hasBaseValues = true;
      _baseCalories = entry.baseCalories;
      _baseProtein = entry.baseProtein;
      _baseCarbs = entry.baseCarbs;
      _baseFat = entry.baseFat;
    } else if (entry.servingSize > 0 && entry.hasNutritionData) {
      _hasBaseValues = true;
      _baseCalories = entry.calories / entry.servingSize;
      _baseProtein = entry.protein / entry.servingSize;
      _baseCarbs = entry.carbs / entry.servingSize;
      _baseFat = entry.fat / entry.servingSize;
    } else {
      _hasBaseValues = false;
      _baseCalories = 0;
      _baseProtein = 0;
      _baseCarbs = 0;
      _baseFat = 0;
    }

    // โหลด ingredients จาก ingredientsJson
    _loadIngredientsFromJson();

    // ฟัง serving size เปลี่ยน (เฉพาะเมื่อไม่มี ingredients — ถ้ามี ingredients จะ recalculate จาก ingredient rows)
    _servingSizeController.addListener(_onServingSizeChanged);
  }

  void _loadIngredientsFromJson() {
    if (widget.entry.ingredientsJson != null && widget.entry.ingredientsJson!.isNotEmpty) {
      try {
        final list = jsonDecode(widget.entry.ingredientsJson!) as List;
        for (final item in list) {
          final map = item as Map<String, dynamic>;
          _ingredients.add(_EditableIngredient(
            name: map['name'] as String? ?? '',
            nameEn: map['name_en'] as String?,
            amount: (map['amount'] as num?)?.toDouble() ?? 0,
            unit: map['unit'] as String? ?? 'g',
            calories: (map['calories'] as num?)?.toDouble() ?? 0,
            protein: (map['protein'] as num?)?.toDouble() ?? 0,
            carbs: (map['carbs'] as num?)?.toDouble() ?? 0,
            fat: (map['fat'] as num?)?.toDouble() ?? 0,
          ));
        }
        _ingredientsLoaded = true;
      } catch (e) {
        AppLogger.warn('parse ingredientsJson error', e);
      }
    }
  }

  // serving size เดิมตอนเปิดหน้า → ใช้คำนวณ ratio
  late final double _originalServing = widget.entry.servingSize > 0 ? widget.entry.servingSize : 1.0;
  // ค่า calories เดิมตอนเปิดหน้า → สำหรับ ratio-based fallback
  late final double _originalCalories = widget.entry.calories;
  late final double _originalProtein = widget.entry.protein;
  late final double _originalCarbs = widget.entry.carbs;
  late final double _originalFat = widget.entry.fat;

  /// เมื่อเปลี่ยนหน่วย → convert ปริมาณถ้าแปลงได้
  void _onUnitChanged(String newUnit) {
    final oldUnit = _servingUnit;
    final oldQty = double.tryParse(_servingSizeController.text) ?? 0;

    if (_canAutoRecalculate && oldQty > 0) {
      final result = UnitConverter.convertServing(
        oldQty: oldQty,
        oldUnit: oldUnit,
        newUnit: newUnit,
      );

      _servingSizeController.removeListener(_onServingSizeChanged);

      if (result.converted) {
        // Convert quantity (nutrition stays the same)
        final factor = result.newQty / oldQty;
        if (_hasBaseValues) {
          _baseCalories = _baseCalories / factor;
          _baseProtein  = _baseProtein  / factor;
          _baseCarbs    = _baseCarbs    / factor;
          _baseFat      = _baseFat      / factor;
        }
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
    final newServing = double.tryParse(_servingSizeController.text) ?? 0;
    if (newServing <= 0) return;

    if (_hasIngredients) {
      // มี ingredients → scale ทุก ingredient ตามสัดส่วน serving ใหม่/เดิม
      final ratio = newServing / _originalServing;
      for (final ing in _ingredients) {
        final newAmount = ing.baseAmount * ratio;
        ing.amountController.text = newAmount.toStringAsFixed(0);
        ing.recalculate();
      }
      _recalculateFromIngredients();
      return;
    }

    if (_hasBaseValues) {
      // มี base values → คำนวณจาก base * serving
      setState(() {
        _caloriesController.text = (_baseCalories * newServing).round().toString();
        _proteinController.text = (_baseProtein * newServing).round().toString();
        _carbsController.text = (_baseCarbs * newServing).round().toString();
        _fatController.text = (_baseFat * newServing).round().toString();
      });
    } else if (_originalCalories > 0 && _originalServing > 0) {
      // Fallback: ไม่มี base values แต่มีค่าเดิม → ใช้ ratio
      final ratio = newServing / _originalServing;
      setState(() {
        _caloriesController.text = (_originalCalories * ratio).round().toString();
        _proteinController.text = (_originalProtein * ratio).round().toString();
        _carbsController.text = (_originalCarbs * ratio).round().toString();
        _fatController.text = (_originalFat * ratio).round().toString();
      });
    }
  }

  /// Recalculate totals จาก ingredients
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

  @override
  void dispose() {
    _servingSizeController.removeListener(_onServingSizeChanged);
    _nameController.dispose();
    _servingSizeController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    for (final ing in _ingredients) {
      ing.dispose();
    }
    super.dispose();
  }

  // ===== DB Lookup =====
  /// ค้นหาวัตถุดิบใน database ด้วย contains match
  /// Priority: exact match > starts with > contains
  Ingredient? _findInDb(String name) {
    final allIngredients = ref.read(allIngredientsProvider).valueOrNull ?? [];
    final query = name.trim().toLowerCase();
    if (query.isEmpty) return null;
    
    Ingredient? exactMatch;
    Ingredient? startsWithMatch;
    Ingredient? containsMatch;
    
    for (final ing in allIngredients) {
      final ingName = ing.name.toLowerCase();
      final ingNameEn = ing.nameEn?.toLowerCase();
      
      // 1. Exact match (highest priority)
      if (ingName == query || ingNameEn == query) {
        exactMatch = ing;
        break;
      }
      
      // 2. Starts with (medium priority)
      if (startsWithMatch == null) {
        if (ingName.startsWith(query) || (ingNameEn?.startsWith(query) ?? false)) {
          startsWithMatch = ing;
        }
      }
      
      // 3. Contains (lowest priority)
      if (containsMatch == null) {
        if (ingName.contains(query) || (ingNameEn?.contains(query) ?? false)) {
          containsMatch = ing;
        }
      }
    }
    
    // Return ตามลำดับความตรง
    return exactMatch ?? startsWithMatch ?? containsMatch;
  }

  Future<void> _lookupIngredient(int index) async {
    // Prevent double-tap
    if (_lookingUpIndices.contains(index)) return;
    
    final row = _ingredients[index];
    final name = row.nameController.text.trim();
    final amount = double.tryParse(row.amountController.text) ?? 0;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter ingredient name')),
      );
      return;
    }

    // === เช็คว่าชื่อเปลี่ยนจากเดิมหรือไม่ ===
    final nameChanged = name.toLowerCase() != row.originalName.toLowerCase();
    
    // === ถ้าชื่อเหมือนเดิม และมีข้อมูลอยู่แล้ว → ถามยืนยันก่อน ===
    // === ถ้าชื่อเปลี่ยน → ไม่ถาม (ถือว่าเป็น ingredient ใหม่) ===
    if (!nameChanged && row.calories > 0 && mounted) {
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

    // 1. ค้น DB
    final dbIng = _findInDb(name);
    if (dbIng != null) {
      final ratio = amount > 0 ? amount / dbIng.baseAmount : 1.0;
      setState(() {
        row.calories = dbIng.caloriesPerBase * ratio;
        row.protein = dbIng.proteinPerBase * ratio;
        row.carbs = dbIng.carbsPerBase * ratio;
        row.fat = dbIng.fatPerBase * ratio;
        row.nameEn = dbIng.nameEn;
        row.isFromDb = true;
        row.saveBaseValues();
      });
      _recalculateFromIngredients();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Found "$name" in database'), backgroundColor: AppColors.success, duration: const Duration(seconds: 2)),
        );
      }
      return;
    }

    // 2. ถ้าไม่มีปริมาณ → prompt
    if (amount <= 0) {
      final action = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Amount not specified'),
          content: Text('Please specify amount for "$name" first\nOr use default 100 g?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, 'cancel'), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(ctx, 'default'), child: const Text('Use 100 g')),
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

    // 3. Gemini lookup
    // ────── ตรวจสอบ Energy ก่อนเรียก API ──────
    final hasEnergy = await GeminiService.hasEnergy();
    if (!hasEnergy) {
      if (!mounted) return;
      await NoEnergyDialog.show(context);
      return;
    }

    setState(() => row.isLoading = true);
    try {
      final queryAmount = double.tryParse(row.amountController.text) ?? 100;
      final result = await GeminiService.analyzeFoodByName(
        name,
        servingSize: queryAmount,
        servingUnit: row.unit,
      );

      if (result != null && mounted) {
        // === Record AI Usage หลังสำเร็จ ===
        await UsageLimiter.recordAiUsage();
        
        // === อัพเดท Energy Badge ===
        if (!mounted) return;
        ref.invalidate(energyBalanceProvider);
        ref.invalidate(currentEnergyProvider);
        
        setState(() {
          row.calories = result.nutrition.calories;
          row.protein = result.nutrition.protein;
          row.carbs = result.nutrition.carbs;
          row.fat = result.nutrition.fat;
          row.nameEn = result.foodNameEn;
          row.isLoading = false;
          _lookingUpIndices.remove(index);
          row.saveBaseValues();
        });
        _recalculateFromIngredients();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI: "$name" → ${result.nutrition.calories.toInt()} kcal'),
            backgroundColor: Colors.purple,
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
            const SnackBar(content: Text('Unable to analyze'), backgroundColor: AppColors.error),
          );
        }
      }
    } catch (e) {
      setState(() {
        row.isLoading = false;
        _lookingUpIndices.remove(index);
      });
      if (mounted) {
        // ตรวจสอบว่าเป็น Energy error หรือไม่
        if (e.toString().contains('Insufficient energy')) {
          await NoEnergyDialog.show(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients[index].dispose();
      _ingredients.removeAt(index);
    });
    _recalculateFromIngredients();
  }

  /// Add new ingredient (insert at top so user sees it immediately)
  void _addIngredient() {
    setState(() {
      _ingredients.insert(0, _EditableIngredient(
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

  @override
  Widget build(BuildContext context) {
    // โหลด ingredients จาก MyMeal ถ้ายังไม่ได้โหลดจาก JSON
    if (!_ingredientsLoaded && widget.entry.myMealId != null && _ingredients.isEmpty) {
      _loadIngredientsFromMyMeal();
    }

    return Container(
      margin: const EdgeInsets.all(16),
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
                decoration: BoxDecoration(color: AppColors.textTertiary, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),

            const Text('✏️ Edit Food', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // วันที่/เวลา (เปลี่ยนได้)
            _buildDateTimePicker(),
            const SizedBox(height: 16),

            // ชื่ออาหาร
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Food Name',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // ปริมาณ + หน่วย
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _servingSizeController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      helperText: (!_hasIngredients && _hasBaseValues) ? 'Change amount → calories update automatically' : null,
                      helperStyle: TextStyle(fontSize: 11, color: Colors.purple.shade300),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    initialValue: _getValidUnit(_servingUnit),
                    decoration: InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: _buildUnitItems(),
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

            // Nutrition fields
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.health.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.health.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _caloriesController,
                    keyboardType: TextInputType.number,
                    readOnly: _canAutoRecalculate,
                    decoration: InputDecoration(
                      labelText: 'Calories (kcal)',
                      prefixText: '🔥 ',
                      filled: _canAutoRecalculate,
                      fillColor: _canAutoRecalculate ? Colors.grey.shade100 : null,
                      suffixIcon: _canAutoRecalculate
                          ? const Tooltip(
                              message: 'Auto-calculated',
                              child: Icon(Icons.lock_outline, size: 18),
                            )
                          : null,
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
                          readOnly: _canAutoRecalculate,
                          decoration: InputDecoration(
                            labelText: 'Protein (g)',
                            filled: _canAutoRecalculate,
                            fillColor: _canAutoRecalculate ? Colors.grey.shade100 : null,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _carbsController,
                          keyboardType: TextInputType.number,
                          readOnly: _canAutoRecalculate,
                          decoration: InputDecoration(
                            labelText: 'Carbs (g)',
                            filled: _canAutoRecalculate,
                            fillColor: _canAutoRecalculate ? Colors.grey.shade100 : null,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _fatController,
                          keyboardType: TextInputType.number,
                          readOnly: _canAutoRecalculate,
                          decoration: InputDecoration(
                            labelText: 'Fat (g)',
                            filled: _canAutoRecalculate,
                            fillColor: _canAutoRecalculate ? Colors.grey.shade100 : null,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_hasBaseValues && !_hasIngredients) ...[
                    const SizedBox(height: 8),
                    Text(
                      '📊 ค่าฐาน: ${_baseCalories.toInt()} kcal / 1 $_servingUnit',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                  if (_hasIngredients) ...[
                    const SizedBox(height: 8),
                    const Text(
                      '📊 Calculated from ingredients below',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ===== Editable Ingredients =====
            if (_hasIngredients || widget.entry.myMealId != null || widget.entry.ingredientsJson != null) ...[
              const Divider(),
              const SizedBox(height: 8),
              _buildEditableIngredientsSection(),
              const SizedBox(height: 16),
            ],

            // Meal type
            const Text('Meal Type', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: MealType.values.map((type) {
                final isSelected = _selectedMealType == type;
                return ChoiceChip(
                  label: Text('${type.icon} ${type.displayName}'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedMealType = type);
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================================
  // โหลด Ingredients จาก MyMeal (async)
  // ========================================================
  void _loadIngredientsFromMyMeal() {
    final mealIngredientsAsync = ref.watch(mealIngredientsProvider(widget.entry.myMealId!));
    mealIngredientsAsync.whenData((mealIngredients) {
      if (!_ingredientsLoaded && _ingredients.isEmpty) {
        for (final ing in mealIngredients) {
          _ingredients.add(_EditableIngredient(
            name: ing.ingredientName,
            amount: ing.amount,
            unit: ing.unit,
            calories: ing.calories,
            protein: ing.protein,
            carbs: ing.carbs,
            fat: ing.fat,
          ));
        }
        _ingredientsLoaded = true;
      }
    });
  }

  // ========================================================
  // Editable Ingredients Section
  // ========================================================
  Widget _buildEditableIngredientsSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science_outlined, size: 16, color: Colors.green),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  '🥬 Ingredients (Editable)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.green),
                ),
              ),
              InkWell(
                onTap: _addIngredient,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 14, color: Colors.green),
                      SizedBox(width: 2),
                      Text('Add', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (_ingredients.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text('No ingredients — tap "Add" to add new', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            )
          else
            ...List.generate(_ingredients.length, (i) => _buildEditableIngredientRow(i)),

          const SizedBox(height: 6),
          const Text(
            '💡 Edit name/amount → Tap 🔍 to search database or AI',
            style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableIngredientRow(int index) {
    final row = _ingredients[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: row.isFromDb ? Colors.green.shade200 : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: ชื่อ + lookup + delete
          Row(
            children: [
              Expanded(
                // ===== Autocomplete widget แทน TextField ธรรมดา =====
                child: Autocomplete<Ingredient>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<Ingredient>.empty();
                    }
                    final allIngredients = ref.read(allIngredientsProvider).valueOrNull ?? [];
                    final query = textEditingValue.text.toLowerCase();
                    return allIngredients.where((ing) {
                      return ing.name.toLowerCase().contains(query) ||
                             (ing.nameEn?.toLowerCase().contains(query) ?? false);
                    }).take(8);
                  },
                  displayStringForOption: (Ingredient ing) => ing.name,
                  onSelected: (Ingredient selection) {
                    // Auto-fill จาก DB (ไม่เสีย Energy)
                    final amt = double.tryParse(row.amountController.text) ?? selection.baseAmount;
                    final ratio = amt / selection.baseAmount;
                    setState(() {
                      row.nameController.text = selection.name;
                      row.nameEn = selection.nameEn;
                      row.calories = selection.caloriesPerBase * ratio;
                      row.protein = selection.proteinPerBase * ratio;
                      row.carbs = selection.carbsPerBase * ratio;
                      row.fat = selection.fatPerBase * ratio;
                      row.isFromDb = true;
                      row.saveBaseValues();
                    });
                    _recalculateFromIngredients();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Auto-filled from DB: ${selection.name}'),
                        backgroundColor: AppColors.success,
                        duration: const Duration(seconds: 2),
                      ),
                    );
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
                            itemBuilder: (context, idx) {
                              final ing = options.elementAt(idx);
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
                    // Sync กับ row.nameController
                    if (textEditingController.text.isEmpty && row.nameController.text.isNotEmpty) {
                      textEditingController.text = row.nameController.text;
                    }
                    textEditingController.addListener(() {
                      row.nameController.text = textEditingController.text;
                    });
                    return TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Ingredient name',
                        hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        suffixIcon: Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey[600]),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 4),
              row.isLoading
                  ? const SizedBox(
                      width: 32, height: 32,
                      child: Padding(padding: EdgeInsets.all(6), child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : SizedBox(
                      width: 32, height: 32,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.search, size: 18),
                        tooltip: 'Search DB / AI',
                        color: Colors.purple,
                        onPressed: () => _lookupIngredient(index),
                      ),
                    ),
              SizedBox(
                width: 28, height: 28,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.close, size: 16, color: Colors.red.shade300),
                  onPressed: () => _removeIngredient(index),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Row 2: ปริมาณ + หน่วย + kcal/macro
          Row(
            children: [
              SizedBox(
                width: 80,
                child: TextField(
                  controller: row.amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 13),
                  onChanged: (_) {
                    row.recalculate();
                    _recalculateFromIngredients();
                  },
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Amount',
                    hintStyle: TextStyle(fontSize: 11, color: Colors.grey[400]),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: 72,
                child: DropdownButtonFormField<String>(
                  initialValue: _getValidUnit(row.unit),
                  isDense: true,
                  isExpanded: true,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                  dropdownColor: Colors.white,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  items: _buildCompactUnitItems(),
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
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.health),
                  ),
                  Text(
                    'P:${row.protein.toInt()} C:${row.carbs.toInt()} F:${row.fat.toInt()}',
                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),

          if (row.isFromDb) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
              child: const Text('From Database', style: TextStyle(fontSize: 9, color: Colors.green)),
            ),
          ],
        ],
      ),
    );
  }

  // ========================================================
  // Helpers
  // ========================================================
  String _getValidUnit(String unit) {
    return UnitConverter.ensureValid(unit);
  }

  List<DropdownMenuItem<String>> _buildUnitItems() {
    return UnitConverter.allDropdownItems;
  }

  List<DropdownMenuItem<String>> _buildCompactUnitItems() {
    return UnitConverter.compactDropdownItems;
  }

  // ========================================================
  // Date / Time Picker
  // ========================================================
  Widget _buildDateTimePicker() {
    final dateStr = DateFormat('d MMM yyyy', 'th').format(_timestamp);
    final timeStr = DateFormat('HH:mm').format(_timestamp);
    final isToday = _isToday(_timestamp);

    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isToday ? AppColors.primary.withOpacity(0.06) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
            const SizedBox(width: 10),
            Text(
              isToday ? 'Today' : dateStr,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(width: 16),
            InkWell(
              onTap: _pickTime,
              child: Row(
                children: [
                  const Icon(Icons.access_time, size: 18, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    timeStr,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Icon(Icons.edit, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _timestamp,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() {
        _timestamp = DateTime(
          picked.year, picked.month, picked.day,
          _timestamp.hour, _timestamp.minute,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_timestamp),
    );
    if (picked != null) {
      setState(() {
        _timestamp = DateTime(
          _timestamp.year, _timestamp.month, _timestamp.day,
          picked.hour, picked.minute,
        );
      });
    }
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

    widget.entry.foodName = _nameController.text.trim();
    widget.entry.mealType = _selectedMealType;
    widget.entry.servingSize = servingSize;
    widget.entry.servingUnit = _servingUnit;
    widget.entry.calories = calories;
    widget.entry.protein = protein;
    widget.entry.carbs = carbs;
    widget.entry.fat = fat;
    widget.entry.timestamp = _timestamp; // ใช้วัน/เวลาที่ผู้ใช้เลือก
    widget.entry.updatedAt = DateTime.now();

    // อัปเดต base values
    if (!_hasIngredients && !_hasBaseValues && servingSize > 0 && calories > 0) {
      widget.entry.baseCalories = calories / servingSize;
      widget.entry.baseProtein = protein / servingSize;
      widget.entry.baseCarbs = carbs / servingSize;
      widget.entry.baseFat = fat / servingSize;
    }

    // อัปเดต ingredientsJson ถ้ามี ingredients
    if (_hasIngredients) {
      widget.entry.ingredientsJson = jsonEncode(_ingredients.map((e) => e.toMap()).toList());
    }

    widget.onSave(widget.entry);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Saved successfully'), backgroundColor: AppColors.success),
    );
  }
}
