import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../core/ai/gemini_service.dart';
import '../../../core/services/usage_limiter.dart';
import '../../../l10n/app_localizations.dart';
import '../../../features/energy/providers/energy_provider.dart';
import '../providers/my_meal_provider.dart';
import '../models/ingredient.dart';

/// Bottom sheet for editing or creating ingredient with AI search
class EditIngredientSheet extends ConsumerStatefulWidget {
  final Ingredient ingredient;
  final Future<void> Function(Ingredient) onSave;
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
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2), // Keep 2px for small indicator
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppIcons.iconWithLabel(
              widget.isCreateMode ? Icons.add_circle : AppIcons.edit,
              widget.isCreateMode ? L10n.of(context)!.addIngredient : L10n.of(context)!.editIngredientTitle,
              iconColor: widget.isCreateMode ? AppColors.finance : AppIcons.editColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 20),

            // Ingredient Name with AI Search button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: L10n.of(context)!.ingredientNameRequired,
                      hintText: L10n.of(context)!.ingredientNameHint,
                      border: OutlineInputBorder(borderRadius: AppRadius.md),
                    ),
                  ),
                ),
                if (widget.isCreateMode) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSearching ? null : _searchWithAI,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.premium,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
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
                      labelText: L10n.of(context)!.baseAmountLabel,
                      hintText: L10n.of(context)!.baseAmountHint,
                      border: OutlineInputBorder(borderRadius: AppRadius.md),
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
                      labelText: L10n.of(context)!.unitLabel,
                      border: OutlineInputBorder(borderRadius: AppRadius.md),
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
                color: AppColors.health.withValues(alpha: 0.08),
                borderRadius: AppRadius.md,
                border: Border.all(color: AppColors.health.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    L10n.of(context)!.nutritionPerBase(
                      _baseAmountController.text.isEmpty ? "..." : _baseAmountController.text,
                      _baseUnit,
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _caloriesController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: L10n.of(context)!.caloriesLabel,
                      prefixIcon: const Icon(AppIcons.calories, size: 16, color: AppIcons.caloriesColor),
                      prefixText: '',
                      border: OutlineInputBorder(borderRadius: AppRadius.md),
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
                            labelText: L10n.of(context)!.proteinLabelShort,
                            border: OutlineInputBorder(borderRadius: AppRadius.md),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _carbsController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: L10n.of(context)!.carbsLabelShort,
                            border: OutlineInputBorder(borderRadius: AppRadius.md),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _fatController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: L10n.of(context)!.fatLabelShort,
                            border: OutlineInputBorder(borderRadius: AppRadius.md),
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
                L10n.of(context)!.nutritionCalculatedPerBase(_baseAmountController.text, _baseUnit),
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 24),

            // Save button
            AppButton.primary(
              label: widget.isCreateMode ? L10n.of(context)!.createIngredient : L10n.of(context)!.saveChanges,
              icon: Icons.save_rounded,
              isLoading: _isSaving,
              onPressed: _save,
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
        SnackBar(content: Text(L10n.of(context)!.pleaseEnterIngredientNameFirst), duration: const Duration(seconds: 2)),
      );
      return;
    }

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
              content: Text(L10n.of(context)!.aiAnalyzedIngredient(ingredientName, baseAmount.toString(), _baseUnit, result.nutrition.calories.toInt())),
              backgroundColor: AppColors.premium,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        setState(() => _isSearching = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(L10n.of(context)!.unableToFindIngredient),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isSearching = false);
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
            SnackBar(
              content: Text(L10n.of(context)!.searchFailed(e.toString())),
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
        SnackBar(content: Text(L10n.of(context)!.pleaseEnterIngredientName), duration: const Duration(seconds: 2)),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final notifier = ref.read(myMealNotifierProvider.notifier);
      final Ingredient result;

      if (widget.isCreateMode) {
        // Create new ingredient
        debugPrint('[EditIngredient] Creating new ingredient: $name');
        result = await notifier.saveIngredient(
          name: name,
          nameEn: null,
          baseAmount: double.tryParse(_baseAmountController.text) ?? 1,
          baseUnit: _baseUnit,
          calories: double.tryParse(_caloriesController.text) ?? 0,
          protein: double.tryParse(_proteinController.text) ?? 0,
          carbs: double.tryParse(_carbsController.text) ?? 0,
          fat: double.tryParse(_fatController.text) ?? 0,
          source: 'manual',
        );
        debugPrint('[EditIngredient] Created ingredient id=${result.id}');
      } else {
        // Update existing ingredient
        debugPrint('[EditIngredient] Updating ingredient id=${widget.ingredient.id}, name=$name');
        debugPrint('[EditIngredient] New values - fat: ${_fatController.text}, calories: ${_caloriesController.text}');
        result = await notifier.updateIngredient(
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
        debugPrint('[EditIngredient] Updated ingredient - fat: ${result.fatPerBase}');
      }

      // Wait for callback to complete
      await widget.onSave(result);
      
      if (context.mounted) Navigator.pop(context);
    } catch (e, stackTrace) {
      debugPrint('[EditIngredient] Error saving ingredient: $e');
      debugPrint('[EditIngredient] StackTrace: $stackTrace');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
