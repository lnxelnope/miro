import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../core/utils/logger.dart';
import '../../../core/ai/gemini_service.dart';
import '../../../core/services/usage_limiter.dart';
import '../../../features/energy/widgets/no_energy_dialog.dart';
import '../../../features/energy/providers/energy_provider.dart';
import '../providers/my_meal_provider.dart';
import '../models/ingredient.dart';

/// Bottom sheet for editing or creating ingredient with AI search
class EditIngredientSheet extends ConsumerStatefulWidget {
  final Ingredient ingredient;
  final Function(Ingredient) onSave;
  final bool isCreateMode;

  const EditIngredientSheet({
    super.key,
    required this.ingredient,
    required this.onSave,
    this.isCreateMode = false,
  });

  @override
  ConsumerState<EditIngredientSheet> createState() => _EditIngredientSheetState();
}

class _EditIngredientSheetState extends ConsumerState<EditIngredientSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _baseAmountController;
  String _baseUnit = 'g';
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinController;
  late final TextEditingController _carbsController;
  late final TextEditingController _fatController;
  bool _isSaving = false;
  bool _isSearching = false;

  // Original values for auto-scaling
  double _originalBaseAmount = 1.0;
  double _originalCalories = 0;
  double _originalProtein = 0;
  double _originalCarbs = 0;
  double _originalFat = 0;

  @override
  void initState() {
    super.initState();
    final ing = widget.ingredient;
    _nameController = TextEditingController(text: ing.name);
    _baseAmountController = TextEditingController(text: ing.baseAmount.toStringAsFixed(ing.baseAmount == ing.baseAmount.roundToDouble() ? 0 : 1));
    _baseUnit = UnitConverter.ensureValid(ing.baseUnit);
    _caloriesController = TextEditingController(text: ing.caloriesPerBase.toStringAsFixed(0));
    _proteinController = TextEditingController(text: ing.proteinPerBase.toStringAsFixed(1));
    _carbsController = TextEditingController(text: ing.carbsPerBase.toStringAsFixed(1));
    _fatController = TextEditingController(text: ing.fatPerBase.toStringAsFixed(1));

    // Save original values for scaling
    _originalBaseAmount = ing.baseAmount;
    _originalCalories = ing.caloriesPerBase;
    _originalProtein = ing.proteinPerBase;
    _originalCarbs = ing.carbsPerBase;
    _originalFat = ing.fatPerBase;

    // Add listener to auto-scale when base amount changes
    _baseAmountController.addListener(_onBaseAmountChanged);
  }

  void _onBaseAmountChanged() {
    final newAmount = double.tryParse(_baseAmountController.text);
    if (newAmount == null || newAmount <= 0 || _originalBaseAmount <= 0) return;

    final ratio = newAmount / _originalBaseAmount;

    _caloriesController.text = (_originalCalories * ratio).toStringAsFixed(0);
    _proteinController.text = (_originalProtein * ratio).toStringAsFixed(1);
    _carbsController.text = (_originalCarbs * ratio).toStringAsFixed(1);
    _fatController.text = (_originalFat * ratio).toStringAsFixed(1);

    setState(() {});
  }

  /// When unit changes, convert base amount if possible
  void _onUnitChanged(String newUnit) {
    final oldUnit = _baseUnit;
    final oldAmount = double.tryParse(_baseAmountController.text);
    
    if (oldAmount != null && oldAmount > 0) {
      final result = UnitConverter.convertServing(
        oldQty: oldAmount,
        oldUnit: oldUnit,
        newUnit: newUnit,
      );
      
      setState(() {
        _baseUnit = newUnit;
        if (result.converted) {
          // Successfully converted (e.g. 100g → 3.5oz)
          _baseAmountController.text = result.newQty.toStringAsFixed(
            result.newQty == result.newQty.roundToDouble() ? 0 : 1
          );
          // Nutrition stays same (amount converted)
        }
        // If not converted (e.g. g → piece), amount stays same
      });
    } else {
      setState(() => _baseUnit = newUnit);
    }
  }

  @override
  void dispose() {
    _baseAmountController.removeListener(_onBaseAmountChanged);
    _nameController.dispose();
    _baseAmountController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
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
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppIcons.iconWithLabel(
                    widget.isCreateMode ? Icons.add_circle : AppIcons.edit,
                    widget.isCreateMode ? 'Add Ingredient' : 'Edit Ingredient',
                    iconColor: widget.isCreateMode ? const Color(0xFF10B981) : AppIcons.editColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildCloseButton(),
              ],
            ),
            const SizedBox(height: 20),

            // Ingredient Name with AI Search button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Ingredient Name *',
                      hintText: 'e.g. Chicken Egg',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                if (widget.isCreateMode) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSearching ? null : _searchWithAI,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSearching
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.search, size: 20),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Base Amount + Unit
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _baseAmountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Base Amount',
                      hintText: '100',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    initialValue: _baseUnit,
                    items: UnitConverter.compactDropdownItems,
                    onChanged: (newUnit) {
                      if (newUnit != null) {
                        _onUnitChanged(newUnit);
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    style: const TextStyle(color: Colors.black),
                    dropdownColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Nutrition per base amount
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.health.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.health.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nutrition per ${_baseAmountController.text.isEmpty ? "..." : _baseAmountController.text} $_baseUnit',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _caloriesController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Calories (kcal)',
                      prefixIcon: const Icon(AppIcons.calories, size: 16, color: AppIcons.caloriesColor),
                      prefixText: '',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _proteinController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Protein (g)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _carbsController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Carbs (g)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _fatController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Fat (g)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Nutrition calculated per ${_baseAmountController.text} $_baseUnit — system will auto-calculate based on actual amount consumed',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
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
                    : Text(widget.isCreateMode ? 'Create Ingredient' : 'Save Changes', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _searchWithAI() async {
    final ingredientName = _nameController.text.trim();
    if (ingredientName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter ingredient name first'), duration: Duration(seconds: 2)),
      );
      return;
    }

    final hasEnergy = await GeminiService.hasEnergy();
    if (!hasEnergy) {
      if (mounted) await NoEnergyDialog.show(context);
      return;
    }

    setState(() => _isSearching = true);

    try {
      final baseAmount = double.tryParse(_baseAmountController.text) ?? 100;
      final result = await GeminiService.analyzeFoodByName(
        ingredientName,
        servingSize: baseAmount,
        servingUnit: _baseUnit,
      );

      if (result != null && mounted) {
        await UsageLimiter.recordAiUsage();
        ref.invalidate(energyBalanceProvider);
        ref.invalidate(currentEnergyProvider);

        // Auto-fill nutrition — keep user's amount/unit as-is
        setState(() {
          if (result.foodName.isNotEmpty) _nameController.text = result.foodName;

          _caloriesController.text = result.nutrition.calories.toStringAsFixed(0);
          _proteinController.text = result.nutrition.protein.toStringAsFixed(1);
          _carbsController.text = result.nutrition.carbs.toStringAsFixed(1);
          _fatController.text = result.nutrition.fat.toStringAsFixed(1);

          // Original values use the user's amount (not AI's)
          _originalBaseAmount = baseAmount;
          _originalCalories = result.nutrition.calories;
          _originalProtein = result.nutrition.protein;
          _originalCarbs = result.nutrition.carbs;
          _originalFat = result.nutrition.fat;

          _isSearching = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('AI: "$ingredientName" $baseAmount $_baseUnit → ${result.nutrition.calories.toInt()} kcal'),
              backgroundColor: Colors.purple,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        setState(() => _isSearching = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to find this ingredient'),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isSearching = false);
      if (mounted) {
        if (e.toString().contains('Insufficient energy')) {
          await NoEnergyDialog.show(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Search failed: $e'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter ingredient name'), duration: Duration(seconds: 2)),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final notifier = ref.read(myMealNotifierProvider.notifier);
      final updated = await notifier.updateIngredient(
        ingredientId: widget.ingredient.id,
        name: name,
        nameEn: null,
        baseAmount: double.tryParse(_baseAmountController.text) ?? 1,
        baseUnit: _baseUnit,
        calories: double.tryParse(_caloriesController.text) ?? 0,
        protein: double.tryParse(_proteinController.text) ?? 0,
        carbs: double.tryParse(_carbsController.text) ?? 0,
        fat: double.tryParse(_fatController.text) ?? 0,
      );

      widget.onSave(updated);
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
}
