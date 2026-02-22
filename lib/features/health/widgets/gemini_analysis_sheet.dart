import 'package:flutter/material.dart';
import '../../../core/theme/app_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/disclaimer_widget.dart';
import '../../../core/ai/gemini_service.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../core/services/usage_limiter.dart';
import '../../../core/utils/logger.dart';
import '../../../features/energy/widgets/no_energy_dialog.dart';
import '../../../features/energy/providers/energy_provider.dart';
import '../../../core/constants/enums.dart';
import '../../../core/widgets/search_mode_selector.dart';
import '../../../core/widgets/keyboard_done_bar.dart';
import '../providers/my_meal_provider.dart';
import '../models/ingredient.dart';

// ===== Editable Ingredient Row Model =====
class _EditableIngredient {
  final TextEditingController nameController;
  final TextEditingController amountController;
  String unit;
  String? nameEn;
  String? detail; // NEW
  final Key key = UniqueKey(); // Unique key เพื่อป้องกัน Flutter reuse widget ผิดตัว

  // ค่าฐาน (ต่อ 1 หน่วย) — เพื่อ recalculate เมื่อเปลี่ยน amount
  double baseCalories;
  double baseProtein;
  double baseCarbs;
  double baseFat;
  double baseAmount; // amount ตอนได้ค่ามา (เพื่อหา per-unit)

  // ค่าที่คำนวณแล้ว (display)
  double calories;
  double protein;
  double carbs;
  double fat;

  // สถานะ
  bool isLoading = false;
  bool isFromDb = false;
  bool isExpanded = false; // NEW: สำหรับ collapse/expand sub-ingredients

  // NEW: Sub-ingredients
  List<_EditableIngredient>? subIngredients; // NEW

  _EditableIngredient({
    required String name,
    this.nameEn,
    this.detail, // NEW
    required double amount,
    required this.unit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.subIngredients, // NEW
  })  : nameController = TextEditingController(text: name),
        amountController = TextEditingController(
            text: amount > 0 ? amount.toStringAsFixed(0) : ''),
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
    
    // Scale sub-ingredients ตามสัดส่วน parent
    if (subIngredients != null && subIngredients!.isNotEmpty && baseAmount > 0) {
      final ratio = amt / baseAmount;
      for (final sub in subIngredients!) {
        final subBaseAmt = sub.baseAmount;
        final newSubAmt = subBaseAmt * ratio;
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
    // Dispose sub-ingredients recursively
    if (subIngredients != null) {
      for (final sub in subIngredients!) {
        sub.dispose();
      }
    }
  }

  Map<String, dynamic> toMap() {
    final map = {
      'name': nameController.text.trim(),
      'name_en': nameEn,
      'detail': detail, // NEW
      'amount': double.tryParse(amountController.text) ?? 0,
      'unit': unit,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };

    // NEW: เพิ่ม sub_ingredients ถ้ามี
    if (subIngredients != null && subIngredients!.isNotEmpty) {
      map['sub_ingredients'] =
          subIngredients!.map((sub) => sub.toMap()).toList();
    }

    return map;
  }
}

/// Bottom Sheet showing Gemini analysis results
/// User can edit amount → kcal/macro recalculates automatically
/// + Edit ingredients (name/amount) + Search DB / Gemini per item
class GeminiAnalysisSheet extends ConsumerStatefulWidget {
  final FoodAnalysisResult analysisResult;
  final Function(GeminiConfirmedData) onConfirm;

  const GeminiAnalysisSheet({
    super.key,
    required this.analysisResult,
    required this.onConfirm,
  });

  @override
  ConsumerState<GeminiAnalysisSheet> createState() =>
      _GeminiAnalysisSheetState();
}

class _GeminiAnalysisSheetState extends ConsumerState<GeminiAnalysisSheet> {
  late TextEditingController _nameController;
  late TextEditingController _servingSizeController;
  late String _servingUnit;

  // ค่าฐาน (ต่อ 1 หน่วย) จาก Gemini — สำหรับ overall food
  late double _baseCalories;
  late double _baseProtein;
  late double _baseCarbs;
  late double _baseFat;

  // Prevent double-tap on AI lookup
  final Set<int> _lookingUpIndices = {};

  // ค่าที่คำนวณแล้ว
  double _displayCalories = 0;
  double _displayProtein = 0;
  double _displayCarbs = 0;
  double _displayFat = 0;

  // Editable ingredients
  final List<_EditableIngredient> _ingredients = [];
  bool get _hasIngredients => _ingredients.isNotEmpty;

  // Cache ingredients จาก DB เพื่อให้ Autocomplete ใช้ได้
  List<Ingredient> _cachedIngredients = [];

  // Track original serving size for ingredient scaling
  double _originalServingSize = 1.0;

  @override
  void initState() {
    super.initState();
    final result = widget.analysisResult;

    _nameController = TextEditingController(text: result.foodName);
    _servingSizeController = TextEditingController(
      text: result.servingSize.toString(),
    );
    // Validate and fallback unit from Gemini
    _servingUnit = UnitConverter.ensureValid(result.servingUnit);

    // คำนวณ base values (ต่อ 1 หน่วย)
    final geminiServing = result.servingSize > 0 ? result.servingSize : 1.0;
    _baseCalories = result.nutrition.calories / geminiServing;
    _baseProtein = result.nutrition.protein / geminiServing;
    _baseCarbs = result.nutrition.carbs / geminiServing;
    _baseFat = result.nutrition.fat / geminiServing;

    // Track original serving for ingredient scaling
    _originalServingSize = result.servingSize;

    // Create editable ingredient rows
    if (result.ingredientsDetail != null) {
      for (final ing in result.ingredientsDetail!) {
        // Parse sub-ingredients ถ้ามี
        List<_EditableIngredient>? subs;
        if (ing.subIngredients != null && ing.subIngredients!.isNotEmpty) {
          subs = ing.subIngredients!
              .map((sub) => _EditableIngredient(
                    name: sub.name,
                    nameEn: sub.nameEn,
                    detail: sub.detail,
                    amount: sub.amount,
                    unit: UnitConverter.ensureValid(sub.unit),
                    calories: sub.calories,
                    protein: sub.protein,
                    carbs: sub.carbs,
                    fat: sub.fat,
                  ))
              .toList();
        }

        _ingredients.add(_EditableIngredient(
          name: ing.name,
          nameEn: ing.nameEn,
          detail: ing.detail, // NEW
          amount: ing.amount,
          unit: UnitConverter.ensureValid(ing.unit), // Validate ingredient unit
          calories: ing.calories,
          protein: ing.protein,
          carbs: ing.carbs,
          fat: ing.fat,
          subIngredients: subs, // NEW
        ));
      }
    }

    _recalculate();
    _servingSizeController.addListener(_onServingSizeChanged);
  }

  /// คำนวณ nutrition ใหม่
  /// ถ้ามี ingredients → รวมจาก ROOT ingredients เท่านั้น (ไม่นับ sub)
  /// ถ้าไม่มี → ใช้ base * servingSize
  void _recalculate() {
    if (_hasIngredients) {
      // CRITICAL: คำนวณจาก ROOT เท่านั้น (sub อยู่ใน subIngredients ไม่นับ)
      double totalCal = 0, totalP = 0, totalC = 0, totalF = 0;
      for (final ing in _ingredients) {
        totalCal += ing.calories; // ROOT only
        totalP += ing.protein;
        totalC += ing.carbs;
        totalF += ing.fat;
      }
      setState(() {
        _displayCalories = totalCal;
        _displayProtein = totalP;
        _displayCarbs = totalC;
        _displayFat = totalF;
      });
    } else {
      final servingSize = double.tryParse(_servingSizeController.text) ?? 0;
      setState(() {
        _displayCalories = _baseCalories * servingSize;
        _displayProtein = _baseProtein * servingSize;
        _displayCarbs = _baseCarbs * servingSize;
        _displayFat = _baseFat * servingSize;
      });
    }
  }

  /// Update parent ingredient totals from its sub-ingredients
  void _recalculateParentFromSubs(int parentIndex) {
    final parent = _ingredients[parentIndex];
    if (parent.subIngredients == null || parent.subIngredients!.isEmpty) return;

    double totalCal = 0, totalP = 0, totalC = 0, totalF = 0;
    for (final sub in parent.subIngredients!) {
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

  /// When serving size changes, scale all ingredients proportionally
  void _onServingSizeChanged() {
    if (!_hasIngredients || _originalServingSize <= 0) {
      _recalculate();
      return;
    }

    final newSize = double.tryParse(_servingSizeController.text);
    if (newSize == null || newSize <= 0) {
      _recalculate();
      return;
    }

    final ratio = newSize / _originalServingSize;

    // Scale all ingredients
    for (final ing in _ingredients) {
      if (ing.baseAmount > 0) {
        final newAmount = ing.baseAmount * ratio;
        ing.amountController.text = newAmount
            .toStringAsFixed(newAmount == newAmount.roundToDouble() ? 0 : 1);
        ing.recalculate();
      }
    }

    _recalculate();
  }

  /// When ingredient unit changes, try to convert amount
  void _onIngredientUnitChanged(_EditableIngredient row, String newUnit) {
    final oldUnit = row.unit;
    final oldAmount = double.tryParse(row.amountController.text);

    if (oldAmount != null && oldAmount > 0) {
      final result = UnitConverter.convertServing(
        oldQty: oldAmount,
        oldUnit: oldUnit,
        newUnit: newUnit,
      );

      setState(() {
        row.unit = newUnit;
        if (result.converted) {
          // Successfully converted → update amount
          row.amountController.text = result.newQty.toStringAsFixed(
              result.newQty == result.newQty.roundToDouble() ? 0 : 1);
          // Nutrition stays same since amount was converted
        }
        // If not converted, amount stays same
      });

      _recalculate();
    } else {
      setState(() => row.unit = newUnit);
    }
  }

  /// When main serving unit changes (for non-ingredient mode)
  void _onMainUnitChanged(String newUnit) {
    final oldUnit = _servingUnit;
    final oldQty = double.tryParse(_servingSizeController.text);

    if (oldQty != null && oldQty > 0) {
      final result = UnitConverter.convertServing(
        oldQty: oldQty,
        oldUnit: oldUnit,
        newUnit: newUnit,
      );

      setState(() {
        _servingUnit = newUnit;
        if (result.converted) {
          // Convert quantity, nutrition stays same
          _servingSizeController.text = result.newQty.toStringAsFixed(
              result.newQty == result.newQty.roundToDouble() ? 0 : 1);
        }
      });

      _recalculate();
    } else {
      setState(() => _servingUnit = newUnit);
    }
  }

  @override
  void dispose() {
    _servingSizeController.removeListener(_onServingSizeChanged);
    _nameController.dispose();
    _servingSizeController.dispose();
    for (final ing in _ingredients) {
      ing.dispose();
    }
    super.dispose();
  }

  /// ค้นหาโภชนาการวัตถุดิบด้วย AI
  Future<void> _lookupIngredient(int index) async {
    // Prevent double-tap
    if (_lookingUpIndices.contains(index)) return;

    final row = _ingredients[index];
    final name = row.nameController.text.trim();
    final amount = double.tryParse(row.amountController.text) ?? 0;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter ingredient name'), duration: Duration(seconds: 2)),
      );
      return;
    }

    // === ถ้ามีข้อมูลอยู่แล้ว ให้ถามยืนยัน + เลือก search mode ===
    FoodSearchMode ingredientSearchMode = FoodSearchMode.normal;
    if (row.calories > 0 && mounted) {
      final result = await showDialog<FoodSearchMode?>(
        context: context,
        builder: (ctx) {
          FoodSearchMode dialogMode = FoodSearchMode.normal;
          return StatefulBuilder(
            builder: (ctx, setDialogState) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  SizedBox(width: 12),
                  Text('Re-analyze?'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '"$name" already has nutrition data.\n'
                    'Analyzing again will use 1 Energy.',
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 16),
                  const Text('Search as:',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 8),
                  SearchModeSelector(
                    selectedMode: dialogMode,
                    onChanged: (mode) =>
                        setDialogState(() => dialogMode = mode),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, null),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, dialogMode),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Re-analyze (1 Energy)'),
                ),
              ],
            ),
          );
        },
      );

      if (result == null) return; // User cancelled
      ingredientSearchMode = result;
    }

    // ปุ่มค้นหา → ไป AI โดยตรงเสมอ
    // (ถ้าผู้ใช้ต้องการใช้ข้อมูลจาก DB ให้เลือกจาก Autocomplete dropdown แทน)

    // ล้าง sub-ingredients เก่า
    row.subIngredients = [];

    // === ตรวจสอบ Energy ก่อนเรียก AI ===
    final hasEnergy = await GeminiService.hasEnergy();
    if (!hasEnergy && mounted) {
      await NoEnergyDialog.show(context);
      return;
    }

    if (amount <= 0) {
      // Prompt to enter amount first
      final action = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Amount not specified'),
          content: Text(
              'Please specify amount for "$name" before AI search\nOr use default 100 g?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, 'cancel'),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'default'),
              child: const Text('Use 100 g'),
            ),
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

    setState(() {
      _lookingUpIndices.add(index);
      row.isLoading = true;
    });

    try {
      final queryAmount = double.tryParse(row.amountController.text) ?? 100;
      final result = await GeminiService.analyzeFoodByName(
        name,
        servingSize: queryAmount,
        servingUnit: row.unit,
        searchMode: ingredientSearchMode,
      );

      if (result != null && mounted) {
        // === Record AI Usage after success ===
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
          
          // === Load sub-ingredients จาก AI result ===
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
        _recalculate();

        // ===== บันทึกลง Ingredient DB ทันที =====
        await _saveIngredientToDb(
          name: result.foodName.isNotEmpty ? result.foodName : name,
          nameEn: result.foodNameEn,
          amount: queryAmount,
          unit: row.unit,
          calories: result.nutrition.calories,
          protein: result.nutrition.protein,
          carbs: result.nutrition.carbs,
          fat: result.nutrition.fat,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'AI: "$name" $queryAmount ${row.unit} → ${result.nutrition.calories.toInt()} kcal — ingredient saved'),
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
            const SnackBar(
                content: Text('Unable to analyze'),
                backgroundColor: AppColors.error,
                duration: Duration(seconds: 2)),
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
            SnackBar(
                content: Text('Error: $e'), backgroundColor: AppColors.error,
                duration: const Duration(seconds: 2)),
          );
        }
      }
    }
  }

  /// บันทึก ingredient ลง DB ทันทีหลัง AI lookup สำเร็จ
  /// เพื่อให้ autocomplete และ ingredient list ใช้ได้ทันทีครั้งต่อไป
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
      // Refresh ingredient list
      if (!mounted) return;
      ref.invalidate(allIngredientsProvider);
      AppLogger.info('Ingredient "$name" saved to DB from GeminiAnalysisSheet');
    } catch (e) {
      debugPrint('⚠️ [GeminiAnalysisSheet] บันทึกวัตถุดิบล้มเหลว: $e');
    }
  }

  /// Remove ingredient
  void _removeIngredient(int index) {
    setState(() {
      _ingredients[index].dispose();
      _ingredients.removeAt(index);
    });
    _recalculate();
  }

  /// Add new ingredient (insert at top so user sees it immediately)
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

  @override
  Widget build(BuildContext context) {
    // Watch provider เพื่อ subscribe ข้อมูล ingredients จาก DB
    _cachedIngredients = ref.watch(allIngredientsProvider).valueOrNull ?? [];

    return KeyboardDoneBar(
      child: Container(
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
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.purple, size: 24),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'AI Analysis Result',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(widget.analysisResult.confidence * 100).toInt()}%',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Food Name
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Food Name',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // Serving Size + Unit (แสดงเสมอ)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.restaurant, color: Colors.purple, size: 20),
                  const SizedBox(width: 8),
                  const Text('Serving:',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _servingSizeController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        helperText:
                            _hasIngredients ? 'Scale all ingredients' : null,
                        helperStyle: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: _getValidUnit(_servingUnit),
                      isDense: true,
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black87),
                      dropdownColor: Colors.white,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      items: _buildUnitItems(),
                      onChanged: (newUnit) {
                        if (newUnit != null) _onMainUnitChanged(newUnit);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Amount (if no ingredients → use serving-level) - REMOVED
            // เพราะย้ายไปด้านบนแล้ว

            // ===== รวม kcal/macro =====
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.health.withOpacity(0.1),
                    AppColors.health.withOpacity(0.05)
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.health.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(AppIcons.calories, size: 32, color: AppIcons.caloriesColor),
                  const SizedBox(width: 12),
                  Text(
                    '${_displayCalories.toInt()}',
                    style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppColors.health),
                  ),
                  const SizedBox(width: 4),
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text('kcal',
                        style: TextStyle(
                            fontSize: 16, color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Macros
            Row(
              children: [
                Expanded(
                    child: _buildMacroCard(
                        'Protein', _displayProtein, AppColors.protein)),
                const SizedBox(width: 8),
                Expanded(
                    child: _buildMacroCard(
                        'Carbs', _displayCarbs, AppColors.carbs)),
                const SizedBox(width: 8),
                Expanded(
                    child: _buildMacroCard('Fat', _displayFat, AppColors.fat)),
              ],
            ),

            // ===== Editable Ingredients =====
            const SizedBox(height: 20),
            _buildEditableIngredientsSection(),

            const SizedBox(height: 24),
            const DisclaimerWidget(compact: false, showFullButton: true),
            const SizedBox(height: 24),

            // Confirm + Cancel buttons
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
                    onPressed: _confirm,
                    icon: const Icon(Icons.check, size: 20),
                    label: const Text('Confirm'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    );
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
          // Header
          Row(
            children: [
              const Icon(Icons.science_outlined, size: 16, color: Colors.green),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Ingredients (Editable)',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.green),
                ),
              ),
              // Add ingredient button
              InkWell(
                onTap: _addIngredient,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 14, color: Colors.green),
                      SizedBox(width: 2),
                      Text('Add',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.green,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Ingredient rows
          ...List.generate(
              _ingredients.length, (i) => _buildEditableIngredientRow(i)),

          const SizedBox(height: 6),
          const Text(
            'Edit name/amount → Tap search icon to search from database or AI',
            style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableIngredientRow(int index) {
    final row = _ingredients[index];
    final hasSubs =
        row.subIngredients != null && row.subIngredients!.isNotEmpty;

    return Column(
      key: row.key,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Parent ingredient
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: row.isFromDb
                    ? Colors.green.shade200
                    : Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Name + Lookup button + Delete button
              Row(
                children: [
                  // Expand indicator (ถ้ามี sub)
                  if (hasSubs)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(Icons.subdirectory_arrow_right,
                          size: 14, color: Colors.grey[600]),
                    ),
                  // Name with Autocomplete
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
                        _recalculate();
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(8),
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
                      fieldViewBuilder: (context, textEditingController,
                          focusNode, onFieldSubmitted) {
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
                            hintText: 'Ingredient name',
                            hintStyle:
                                TextStyle(fontSize: 12, color: Colors.grey[400]),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: AppColors.health, width: 1.5),
                            ),
                            suffixIcon: Icon(Icons.search,
                                size: 16, color: Colors.grey[500]),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Lookup button (DB / Gemini)
                  row.isLoading
                      ? const SizedBox(
                          width: 32,
                          height: 32,
                          child: Padding(
                            padding: EdgeInsets.all(6),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : SizedBox(
                          width: 32,
                          height: 32,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.search, size: 18),
                            tooltip: 'Search DB / AI',
                            color: Colors.purple,
                            onPressed: () => _lookupIngredient(index),
                          ),
                        ),
                  // Delete button
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.close,
                          size: 16, color: Colors.red.shade300),
                      onPressed: () => _removeIngredient(index),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Row 2: Amount + Unit
              Row(
                children: [
                  // Amount
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
                        _recalculate();
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Amount',
                        hintStyle:
                            TextStyle(fontSize: 11, color: Colors.grey[400]),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // หน่วย dropdown ย่อ
                  SizedBox(
                    width: 72,
                    child: DropdownButtonFormField<String>(
                      initialValue: _getValidUnit(row.unit),
                      isDense: true,
                      isExpanded: true,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black87),
                      dropdownColor: Colors.white,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 8),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      items: _buildCompactUnitItems(),
                      onChanged: (newUnit) {
                        if (newUnit != null) {
                          _onIngredientUnitChanged(row, newUnit);
                        }
                      },
                    ),
                  ),
                  const Spacer(),

                  // kcal / macro info
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

              // แสดง tag "จาก DB" ถ้ามี
              if (row.isFromDb) ...[
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('From Database',
                      style: TextStyle(fontSize: 9, color: Colors.green)),
                ),
              ],
            ],
          ),
        ),

        // NEW: แสดง sub-ingredients (ถ้ามี) - Collapsible + Editable
        if (hasSubs) ...[
          // Expand/Collapse button
          InkWell(
            onTap: () => setState(() => row.isExpanded = !row.isExpanded),
            child: Container(
              margin: const EdgeInsets.only(left: 24, bottom: 8, top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    row.isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    row.isExpanded
                        ? 'Hide ${row.subIngredients!.length} sub-ingredients'
                        : 'Show ${row.subIngredients!.length} sub-ingredients',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sub-ingredients list (editable when expanded)
          if (row.isExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...row.subIngredients!.asMap().entries.map((entry) {
                    final subIndex = entry.key;
                    final sub = entry.value;
                    return _buildSubIngredientRow(index, subIndex, sub);
                  }),
                  // Info text
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 12, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Sub-ingredients are for breakdown info (editable, searchable with 🔍)',
                            style: TextStyle(
                                fontSize: 9,
                                color: Colors.grey[500],
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }

  /// Build editable sub-ingredient row (similar to parent but indented)
  Widget _buildSubIngredientRow(
      int parentIndex, int subIndex, _EditableIngredient sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Name + Lookup + Delete
          Row(
            children: [
              // Indent indicator
              Container(
                width: 2,
                height: 20,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              // Name field with Autocomplete
              Expanded(
                child: Autocomplete<Ingredient>(
                  key: ValueKey('sub_ac_${sub.key}'),
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
                      _recalculateParentFromSubs(parentIndex);
                      _recalculate();
                    });
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(8),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                              maxHeight: 180, maxWidth: 240),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, idx) {
                              final ing = options.elementAt(idx);
                              return ListTile(
                                dense: true,
                                title: Text(ing.name,
                                    style: const TextStyle(fontSize: 12)),
                                subtitle: Text(
                                  '${ing.caloriesPerBase.toInt()} kcal / ${ing.baseAmount.toStringAsFixed(0)} ${ing.baseUnit}',
                                  style: const TextStyle(
                                      fontSize: 10,
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
                    return TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: 'Sub-ingredient name',
                        hintStyle:
                            TextStyle(fontSize: 12, color: Colors.grey[400]),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 6),

              // Lookup button (🔍)
              if (!sub.isLoading)
                InkWell(
                  onTap: () => _onSubIngredientLookup(parentIndex, subIndex),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child:
                        const Icon(Icons.search, size: 16, color: Colors.blue),
                  ),
                )
              else
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),

              const SizedBox(width: 4),

              // Delete button
              InkWell(
                onTap: () => _deleteSubIngredient(parentIndex, subIndex),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.close, size: 14, color: Colors.red),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Row 2: Amount + Unit + Nutrition
          Row(
            children: [
              const SizedBox(width: 10), // indent
              // Amount
              SizedBox(
                width: 60,
                child: TextField(
                  controller: sub.amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    hintText: '0',
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  onChanged: (_) {
                    setState(() {
                      sub.recalculate();
                      _recalculateParentFromSubs(parentIndex);
                      _recalculate();
                    });
                  },
                ),
              ),
              const SizedBox(width: 6),

              // Unit dropdown
              SizedBox(
                width: 72,
                child: DropdownButtonFormField<String>(
                  initialValue: _getValidUnit(sub.unit),
                  isDense: true,
                  isExpanded: true,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                  dropdownColor: Colors.white,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  items: _buildCompactUnitItems(),
                  onChanged: (newUnit) {
                    if (newUnit != null) {
                      setState(() {
                        _onSubIngredientUnitChanged(sub, newUnit);
                      });
                    }
                  },
                ),
              ),
              const Spacer(),

              // Nutrition info
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${sub.calories.toInt()} kcal',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'P:${sub.protein.toInt()} C:${sub.carbs.toInt()} F:${sub.fat.toInt()}',
                    style: const TextStyle(
                        fontSize: 9, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),

          // Detail text (if any)
          if (sub.detail != null && sub.detail!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                sub.detail!,
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],

          // DB badge
          if (sub.isFromDb) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('From Database',
                    style: TextStyle(fontSize: 9, color: Colors.green)),
              ),
            ),
          ],
        ],
      ),
    );
  } // <-- ปิด _buildEditableIngredientRow method

  // ========================================================
  // Helpers
  // ========================================================
  Widget _buildMacroCard(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(
            '${value.toStringAsFixed(1)}g',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  String _getValidUnit(String unit) {
    return UnitConverter.ensureValid(unit);
  }

  List<DropdownMenuItem<String>> _buildUnitItems() {
    return UnitConverter.allDropdownItems;
  }

  List<DropdownMenuItem<String>> _buildCompactUnitItems() {
    return UnitConverter.compactDropdownItems;
  }

  void _confirm() {
    final servingSize = double.tryParse(_servingSizeController.text) ?? 1.0;

    widget.onConfirm(GeminiConfirmedData(
      foodName: _nameController.text.trim(),
      foodNameEn: widget.analysisResult.foodNameEn,
      servingSize: servingSize,
      servingUnit: _servingUnit,
      servingGrams: widget.analysisResult.servingGrams?.toDouble(),
      calories: _displayCalories,
      protein: _displayProtein,
      carbs: _displayCarbs,
      fat: _displayFat,
      baseCalories: _hasIngredients
          ? (_displayCalories / (servingSize > 0 ? servingSize : 1))
          : _baseCalories,
      baseProtein: _hasIngredients
          ? (_displayProtein / (servingSize > 0 ? servingSize : 1))
          : _baseProtein,
      baseCarbs: _hasIngredients
          ? (_displayCarbs / (servingSize > 0 ? servingSize : 1))
          : _baseCarbs,
      baseFat: _hasIngredients
          ? (_displayFat / (servingSize > 0 ? servingSize : 1))
          : _baseFat,
      confidence: widget.analysisResult.confidence,
      fiber: widget.analysisResult.nutrition.fiber,
      sugar: widget.analysisResult.nutrition.sugar,
      sodium: widget.analysisResult.nutrition.sodium,
      ingredients: widget.analysisResult.ingredients,
      ingredientsDetail: _hasIngredients
          ? _ingredients.map((e) => e.toMap()).toList()
          : widget.analysisResult.ingredientsDetail
              ?.map((e) => {
                    'name': e.name,
                    'name_en': e.nameEn,
                    'amount': e.amount,
                    'unit': e.unit,
                    'calories': e.calories,
                    'protein': e.protein,
                    'carbs': e.carbs,
                    'fat': e.fat,
                  })
              .toList(),
      notes: widget.analysisResult.notes,
    ));
    Navigator.pop(context);
  }

  /// Lookup sub-ingredient (via DB or AI)
  Future<void> _onSubIngredientLookup(int parentIndex, int subIndex) async {
    final parent = _ingredients[parentIndex];
    final sub = parent.subIngredients![subIndex];
    final subName = sub.nameController.text.trim();

    if (subName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter sub-ingredient name first')),
      );
      return;
    }

    setState(() => sub.isLoading = true);

    try {
      // 1. Try database first
      final dbResult = await ref.read(ingredientSearchProvider(subName).future);
      if (dbResult.isNotEmpty) {
        final ing = dbResult.first;
        setState(() {
          sub.nameController.text = ing.name;
          sub.nameEn = ing.nameEn;
          sub.unit = ing.baseUnit;

          final amount = double.tryParse(sub.amountController.text) ?? 1;
          sub.baseAmount = ing.baseAmount;
          sub.baseCalories = ing.caloriesPerBase / ing.baseAmount;
          sub.baseProtein = ing.proteinPerBase / ing.baseAmount;
          sub.baseCarbs = ing.carbsPerBase / ing.baseAmount;
          sub.baseFat = ing.fatPerBase / ing.baseAmount;

          sub.calories = (ing.caloriesPerBase / ing.baseAmount) * amount;
          sub.protein = (ing.proteinPerBase / ing.baseAmount) * amount;
          sub.carbs = (ing.carbsPerBase / ing.baseAmount) * amount;
          sub.fat = (ing.fatPerBase / ing.baseAmount) * amount;

          sub.isFromDb = true;
          sub.isLoading = false;
          _recalculateParentFromSubs(parentIndex);
        });

        _recalculate();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Found "$subName" in database!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // 2. If not in DB, use AI
      if (!mounted) return;

      final hasEnergy = await GeminiService.hasEnergy();
      if (!hasEnergy && mounted) {
        await NoEnergyDialog.show(context);
        setState(() => sub.isLoading = false);
        return;
      }

      final amount = double.tryParse(sub.amountController.text) ?? 1;
      final unit = sub.unit;

      final result = await GeminiService.analyzeFoodByName(
        subName,
        servingSize: amount,
        servingUnit: unit,
      );

      if (!mounted) return;

      if (result != null) {
        // Record AI Usage
        await UsageLimiter.recordAiUsage();

        // Refresh Energy Badge
        if (!mounted) return;
        ref.invalidate(energyBalanceProvider);
        ref.invalidate(currentEnergyProvider);

        setState(() {
          sub.nameController.text = result.foodName;
          sub.nameEn = result.foodNameEn;
          sub.unit = result.servingUnit;
          sub.amountController.text = result.servingSize.toString();

          sub.baseAmount = result.servingSize;
          sub.baseCalories = result.nutrition.calories / result.servingSize;
          sub.baseProtein = result.nutrition.protein / result.servingSize;
          sub.baseCarbs = result.nutrition.carbs / result.servingSize;
          sub.baseFat = result.nutrition.fat / result.servingSize;

          sub.calories = result.nutrition.calories;
          sub.protein = result.nutrition.protein;
          sub.carbs = result.nutrition.carbs;
          sub.fat = result.nutrition.fat;

          sub.isFromDb = false;
          sub.isLoading = false;
          _recalculateParentFromSubs(parentIndex);
        });

        _recalculate();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('AI analyzed "$subName" (-1 Energy)'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        setState(() => sub.isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not analyze sub-ingredient'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.error('Sub-ingredient lookup failed', e);
      setState(() => sub.isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), duration: const Duration(seconds: 2)),
        );
      }
    }
  }

  /// Delete a sub-ingredient
  void _deleteSubIngredient(int parentIndex, int subIndex) {
    setState(() {
      final parent = _ingredients[parentIndex];
      parent.subIngredients![subIndex].dispose();
      parent.subIngredients!.removeAt(subIndex);

      // If no more subs, remove the list
      if (parent.subIngredients!.isEmpty) {
        parent.subIngredients = null;
        parent.isExpanded = false;
      }

      _recalculateParentFromSubs(parentIndex);
      _recalculate();
    });
  }

  /// Handle unit change for sub-ingredient
  Future<void> _onSubIngredientUnitChanged(
      _EditableIngredient sub, String newUnit) async {
    final oldUnit = sub.unit;
    final currentAmount = double.tryParse(sub.amountController.text) ?? 0;

    if (currentAmount <= 0) {
      sub.unit = newUnit;
      return;
    }

    // Convert if possible
    final converted = UnitConverter.convert(
      currentAmount,
      from: oldUnit,
      to: newUnit,
    );

    if (converted != null) {
      setState(() {
        sub.amountController.text = converted.toStringAsFixed(0);
        sub.unit = newUnit;
        sub.recalculate();
        _recalculate();
      });
    } else {
      // Cannot convert, just change unit
      setState(() {
        sub.unit = newUnit;
      });
    }
  }
}

/// Data confirmed by user from Gemini Analysis
class GeminiConfirmedData {
  final String foodName;
  final String? foodNameEn;
  final double servingSize;
  final String servingUnit;
  final double? servingGrams;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double baseCalories;
  final double baseProtein;
  final double baseCarbs;
  final double baseFat;
  final double confidence;
  final double? fiber;
  final double? sugar;
  final double? sodium;
  final List<String>? ingredients;
  final List<Map<String, dynamic>>? ingredientsDetail;
  final String? notes;

  GeminiConfirmedData({
    required this.foodName,
    this.foodNameEn,
    required this.servingSize,
    required this.servingUnit,
    this.servingGrams,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.baseCalories,
    required this.baseProtein,
    required this.baseCarbs,
    required this.baseFat,
    required this.confidence,
    this.fiber,
    this.sugar,
    this.sodium,
    this.ingredients,
    this.ingredientsDetail,
    this.notes,
  });
}
