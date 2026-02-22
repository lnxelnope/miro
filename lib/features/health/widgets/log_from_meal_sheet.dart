import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/theme/app_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/enums.dart';
import '../models/my_meal.dart';
import '../models/food_entry.dart';
import '../providers/my_meal_provider.dart';

/// Bottom sheet สำหรับบันทึกอาหารจาก MyMeal
/// ผู้ใช้ระบุ multiplier (ปริมาณ) แล้ว nutrition คำนวณอัตโนมัติ
class LogFromMealSheet extends ConsumerStatefulWidget {
  final MyMeal meal;
  final Function(FoodEntry) onConfirm;

  const LogFromMealSheet({
    super.key,
    required this.meal,
    required this.onConfirm,
  });

  @override
  ConsumerState<LogFromMealSheet> createState() => _LogFromMealSheetState();
}

class _LogFromMealSheetState extends ConsumerState<LogFromMealSheet> {
  late final TextEditingController _servingSizeController;
  late MealType _selectedMealType;
  late double _baseCalPerUnit;
  late double _baseProtPerUnit;
  late double _baseCarbPerUnit;
  late double _baseFatPerUnit;

  @override
  void initState() {
    super.initState();
    _selectedMealType = _guessMealType();

    final meal = widget.meal;
    // Parse "16 ลูก" → servingSize=16
    final initServing = meal.parsedServingSize;
    _servingSizeController = TextEditingController(
      text: initServing == initServing.roundToDouble()
          ? initServing.round().toString()
          : initServing.toStringAsFixed(1),
    );

    // คำนวณ base per 1 unit
    _baseCalPerUnit = meal.caloriesPerUnit;
    _baseProtPerUnit = meal.proteinPerUnit;
    _baseCarbPerUnit = meal.carbsPerUnit;
    _baseFatPerUnit = meal.fatPerUnit;

    _servingSizeController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _servingSizeController.dispose();
    super.dispose();
  }

  double get _servingSize => double.tryParse(_servingSizeController.text) ?? 0;
  double get _calories => _baseCalPerUnit * _servingSize;
  double get _protein => _baseProtPerUnit * _servingSize;
  double get _carbs => _baseCarbPerUnit * _servingSize;
  double get _fat => _baseFatPerUnit * _servingSize;

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
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppIcons.iconWithLabel(
                    AppIcons.meal,
                    widget.meal.name,
                    iconColor: AppIcons.mealColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildCloseButton(),
              ],
            ),
            Text(
              'Base: ${widget.meal.baseServingDescription} · ${widget.meal.totalCalories.round()} kcal',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),

            // ปริมาณ + หน่วย
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _servingSizeController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      helperText:
                          'Original ${widget.meal.parsedServingSize == widget.meal.parsedServingSize.roundToDouble() ? widget.meal.parsedServingSize.round() : widget.meal.parsedServingSize}',
                      helperStyle: TextStyle(
                          fontSize: 11, color: Colors.purple.shade300),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.purple, width: 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      widget.meal.parsedServingUnit,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Nutrition preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.health.withOpacity(0.1),
                    AppColors.health.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.health.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  // Calories
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(AppIcons.calories, size: 32, color: AppIcons.caloriesColor),
                      const SizedBox(width: 12),
                      Text(
                        '${_calories.toInt()}',
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
                  const SizedBox(height: 12),
                  // Macros
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _macroItem('Protein', _protein, AppColors.protein),
                      _macroItem('Carbs', _carbs, AppColors.carbs),
                      _macroItem('Fat', _fat, AppColors.fat),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Meal type
            const Text('Meal Type',
                style: TextStyle(fontWeight: FontWeight.w500)),
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
                  onSelected: (s) {
                    if (s) setState(() => _selectedMealType = type);
                  },
                  selectedColor: AppColors.health.withOpacity(0.2),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Confirm button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _servingSize > 0 ? _confirm : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.health,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _macroItem(String label, double value, Color color) {
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

  MealType _guessMealType() {
    final hour = DateTime.now().hour;
    if (hour < 10) return MealType.breakfast;
    if (hour < 14) return MealType.lunch;
    if (hour < 17) return MealType.snack;
    return MealType.dinner;
  }

  Future<void> _confirm() async {
    // โหลด ingredients จาก MyMeal (ใช้ tree provider สำหรับ nested structure)
    final treeAsync = ref.read(mealIngredientTreeProvider(widget.meal.id));
    final tree = treeAsync.value ?? [];

    // แปลงเป็น JSON สำหรับบันทึกลง FoodEntry (รวม sub_ingredients)
    String? ingredientsJsonStr;
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

        // เพิ่ม detail ถ้ามี
        if (node.ingredient.detail != null &&
            node.ingredient.detail!.isNotEmpty) {
          rootMap['detail'] = node.ingredient.detail;
        }

        // เพิ่ม sub_ingredients ถ้ามี
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

    final entry = FoodEntry()
      ..foodName = widget.meal.name
      ..foodNameEn = widget.meal.nameEn
      ..mealType = _selectedMealType
      ..timestamp = DateTime.now()
      ..servingSize = _servingSize
      ..servingUnit = widget.meal.parsedServingUnit
      ..calories = _calories
      ..protein = _protein
      ..carbs = _carbs
      ..fat = _fat
      // Base values per 1 unit (เช่น kcal ต่อ 1 ลูก)
      ..baseCalories = _baseCalPerUnit
      ..baseProtein = _baseProtPerUnit
      ..baseCarbs = _baseCarbPerUnit
      ..baseFat = _baseFatPerUnit
      ..myMealId = widget.meal.id
      ..ingredientsJson = ingredientsJsonStr // บันทึก ingredients JSON
      ..source = DataSource.database;

    widget.onConfirm(entry);
    Navigator.pop(context);
  }
}
