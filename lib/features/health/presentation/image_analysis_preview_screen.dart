import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:miro_hybrid/core/theme/app_colors.dart';
import 'package:miro_hybrid/core/utils/logger.dart';
import 'package:miro_hybrid/core/utils/unit_converter.dart';
import 'package:miro_hybrid/core/constants/enums.dart';
import 'package:miro_hybrid/core/ai/gemini_service.dart';
import 'package:miro_hybrid/core/services/usage_limiter.dart';
import 'package:miro_hybrid/core/database/database_service.dart';
import 'package:miro_hybrid/features/health/models/food_entry.dart';
import 'package:miro_hybrid/features/health/providers/health_provider.dart';
import 'package:miro_hybrid/features/health/widgets/gemini_analysis_sheet.dart';
import 'package:miro_hybrid/features/energy/widgets/no_energy_dialog.dart';
import 'package:miro_hybrid/features/energy/providers/energy_provider.dart';
import 'package:miro_hybrid/features/health/providers/my_meal_provider.dart';
import 'package:miro_hybrid/core/widgets/search_mode_selector.dart';
import 'package:miro_hybrid/l10n/app_localizations.dart';

class ImageAnalysisPreviewScreen extends ConsumerStatefulWidget {
  final File imageFile;
  final String? initialFoodName;
  final double? initialQuantity;
  final String? initialUnit;

  const ImageAnalysisPreviewScreen({
    super.key,
    required this.imageFile,
    this.initialFoodName,
    this.initialQuantity,
    this.initialUnit,
  });

  @override
  ConsumerState<ImageAnalysisPreviewScreen> createState() =>
      _ImageAnalysisPreviewScreenState();
}

class _ImageAnalysisPreviewScreenState
    extends ConsumerState<ImageAnalysisPreviewScreen> {
  late TextEditingController _foodNameController;
  late TextEditingController _quantityController;
  late String _selectedUnit;
  FoodSearchMode _searchMode = FoodSearchMode.normal;
  late MealType _selectedMealType;
  String? _permanentImagePath;
  bool _isAnalyzing = false;
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    _foodNameController = TextEditingController(
      text: widget.initialFoodName ?? 'food',
    );
    _quantityController = TextEditingController(
      text: (widget.initialQuantity ?? 1.0).toString(),
    );
    _selectedUnit = widget.initialUnit ?? 'serving';
    _selectedMealType = _guessMealType();
    _copyImageToPermanentPath();
  }

  Future<void> _copyImageToPermanentPath() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      if (widget.imageFile.path.startsWith(appDir.path)) {
        _permanentImagePath = widget.imageFile.path;
        return;
      }
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final destPath = '${appDir.path}/$fileName';
      await widget.imageFile.copy(destPath);
      _permanentImagePath = destPath;
    } catch (e) {
      AppLogger.error('Failed to copy image to permanent path', e);
      _permanentImagePath = widget.imageFile.path;
    }
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _saveAndAnalyze() async {
    if (_isAnalyzing) return;

    final foodName = _foodNameController.text.trim();
    final quantityText = _quantityController.text.trim();

    double quantity = 1.0;
    if (quantityText.isNotEmpty) {
      final parsed = double.tryParse(quantityText);
      if (parsed == null || parsed <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid quantity'), duration: Duration(seconds: 2)),
        );
        return;
      }
      quantity = parsed;
    }

    // Check energy before starting
    final hasEnergy = await GeminiService.hasEnergy();
    if (!hasEnergy && mounted) {
      await NoEnergyDialog.show(context);
      return;
    }
    if (!mounted) return;

    final effectiveName = foodName.isEmpty ? 'food' : foodName;
    final imagePath = _permanentImagePath ?? widget.imageFile.path;

    // Save entry to database first
    final entry = FoodEntry()
      ..foodName = effectiveName
      ..mealType = _selectedMealType
      ..timestamp = DateTime.now()
      ..imagePath = imagePath
      ..servingSize = quantity
      ..servingUnit = _selectedUnit
      ..calories = 0
      ..protein = 0
      ..carbs = 0
      ..fat = 0
      ..source = DataSource.galleryScanned
      ..isVerified = false
      ..searchMode = _searchMode;

    final notifier = ref.read(foodEntriesNotifierProvider.notifier);
    await notifier.addFoodEntry(entry);

    if (!mounted) return;

    setState(() => _isAnalyzing = true);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'PROCESSING IMAGE DATA...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Processing advanced nutrition analysis',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );

    try {
      final result = await GeminiService.analyzeFoodImage(
        File(imagePath),
        foodName: effectiveName != 'food' ? effectiveName : null,
        quantity: quantity > 0 ? quantity : null,
        unit: _selectedUnit,
        searchMode: _searchMode,
      );

      if (result != null) {
        await UsageLimiter.recordAiUsage();

        if (!mounted) return;
        ref.invalidate(energyBalanceProvider);
        ref.invalidate(currentEnergyProvider);

        Navigator.pop(context); // close loading dialog

        if (!mounted) return;

        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => GeminiAnalysisSheet(
            analysisResult: result,
            onConfirm: (confirmedData) async {
              String? ingredientsJsonStr;
              if (confirmedData.ingredientsDetail != null &&
                  confirmedData.ingredientsDetail!.isNotEmpty) {
                ingredientsJsonStr = jsonEncode(confirmedData.ingredientsDetail);
              }

              FoodSearchMode? updatedSearchMode;
              if (result.foodType != null) {
                updatedSearchMode = result.foodType == 'product'
                    ? FoodSearchMode.product
                    : FoodSearchMode.normal;
              }

              await notifier.updateFromGeminiConfirmed(
                entry.id,
                foodName: confirmedData.foodName,
                foodNameEn: confirmedData.foodNameEn,
                calories: confirmedData.calories,
                protein: confirmedData.protein,
                carbs: confirmedData.carbs,
                fat: confirmedData.fat,
                baseCalories: confirmedData.baseCalories,
                baseProtein: confirmedData.baseProtein,
                baseCarbs: confirmedData.baseCarbs,
                baseFat: confirmedData.baseFat,
                servingSize: confirmedData.servingSize,
                servingUnit: confirmedData.servingUnit,
                servingGrams: confirmedData.servingGrams,
                confidence: confirmedData.confidence,
                fiber: confirmedData.fiber,
                sugar: confirmedData.sugar,
                sodium: confirmedData.sodium,
                notes: confirmedData.notes,
                ingredientsJson: ingredientsJsonStr,
              );

              if (updatedSearchMode != null) {
                final updatedEntry = await DatabaseService.foodEntries.get(entry.id);
                if (updatedEntry != null) {
                  updatedEntry.searchMode = updatedSearchMode;
                  await DatabaseService.isar.writeTxn(() async {
                    await DatabaseService.foodEntries.put(updatedEntry);
                  });
                }
              }

              if (confirmedData.ingredientsDetail != null &&
                  confirmedData.ingredientsDetail!.isNotEmpty) {
                try {
                  await notifier.saveIngredientsAndMeal(
                    mealName: confirmedData.foodName,
                    mealNameEn: confirmedData.foodNameEn,
                    servingDescription:
                        '${confirmedData.servingSize} ${confirmedData.servingUnit}',
                    imagePath: imagePath,
                    ingredientsData: confirmedData.ingredientsDetail!,
                  );
                  if (!mounted) return;
                  ref.invalidate(allMyMealsProvider);
                  ref.invalidate(allIngredientsProvider);
                } catch (e) {
                  AppLogger.warn('Could not auto-save meal: $e');
                }
              }

              if (!mounted) return;
              final today = dateOnly(DateTime.now());
              ref.invalidate(healthTimelineProvider(today));
              ref.invalidate(foodEntriesByDateProvider(today));
              ref.invalidate(todayCaloriesProvider);
              ref.invalidate(todayMacrosProvider);

              if (!mounted) return;
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        );

        // User cancelled the analysis sheet — still go back
        if (mounted) {
          final today = dateOnly(DateTime.now());
          ref.invalidate(healthTimelineProvider(today));
          ref.invalidate(foodEntriesByDateProvider(today));
          ref.invalidate(todayCaloriesProvider);
          ref.invalidate(todayMacrosProvider);
        }
      } else {
        if (!mounted) return;
        Navigator.pop(context); // close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Analysis failed — saved as pending entry'),
            backgroundColor: AppColors.warning,
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      AppLogger.error('[SaveAndAnalyze] Error: $e');
      if (!mounted) return;
      Navigator.pop(context); // close loading dialog

      if (e.toString().contains('Insufficient energy')) {
        await NoEnergyDialog.show(context);
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '')}'),
          backgroundColor: AppColors.error,
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  MealType _guessMealType() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return MealType.breakfast;
    if (hour >= 11 && hour < 15) return MealType.lunch;
    if (hour >= 15 && hour < 19) return MealType.snack;
    return MealType.dinner;
  }

  Future<void> _saveToDiary() async {
    final foodName = _foodNameController.text.trim();
    final quantity = double.tryParse(_quantityController.text.trim()) ?? 1.0;

    final entry = FoodEntry()
      ..foodName = foodName.isEmpty ? 'food' : foodName
      ..mealType = _selectedMealType
      ..timestamp = DateTime.now()
      ..imagePath = _permanentImagePath ?? widget.imageFile.path
      ..servingSize = quantity
      ..servingUnit = _selectedUnit
      ..calories = 0
      ..protein = 0
      ..carbs = 0
      ..fat = 0
      ..source = DataSource.galleryScanned
      ..isVerified = false;

    final notifier = ref.read(foodEntriesNotifierProvider.notifier);
    await notifier.addFoodEntry(entry);

    if (!mounted) return;

    final today = dateOnly(DateTime.now());
    ref.invalidate(healthTimelineProvider(today));
    ref.invalidate(foodEntriesByDateProvider(today));
    ref.invalidate(todayCaloriesProvider);
    ref.invalidate(todayMacrosProvider);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Saved — analyze later with Analyze All'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    return PopScope(
      canPop: true,
      child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.analyzeFoodImageTitle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Preview
            Container(
              height: 300,
              color: Colors.grey[200],
              child: Image.file(
                widget.imageFile,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 24),

            // Input Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food Name Input (always visible)
                  Text(
                    l10n.foodNameLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _foodNameController,
                    decoration: InputDecoration(
                      hintText: l10n.foodNameHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),

                  // Helper Text (moved under food name)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb_outline, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            l10n.foodNameQuantityAndModeImprovesAccuracy,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ===== Search Mode (visible by default) =====
                  Text(
                    l10n.searchModeLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  SearchModeSelector(
                    selectedMode: _searchMode,
                    onChanged: (mode) => setState(() => _searchMode = mode),
                  ),

                  const SizedBox(height: 8),

                  // Show/Hide details toggle
                  GestureDetector(
                    onTap: () => setState(() => _showDetails = !_showDetails),
                    child: Row(
                      children: [
                        Icon(
                          _showDetails ? Icons.expand_less : Icons.expand_more,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _showDetails ? l10n.hideDetails : l10n.showDetails,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Collapsible details section
                  if (_showDetails) ...[
                    const SizedBox(height: 16),

                    // Quantity and Unit Row
                    Text(
                      l10n.quantityLabel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _quantityController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              hintText: '1',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedUnit,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            items: UnitConverter.allDropdownItems,
                            onChanged: (value) {
                              if (value != null && value.isNotEmpty) {
                                setState(() {
                                  _selectedUnit = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Meal Type
                    Text(
                      l10n.mealTypeTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
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
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedMealType = type);
                          },
                          selectedColor: AppColors.health.withValues(alpha: 0.2),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Save & Analyze Button (always visible)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isAnalyzing ? null : _saveAndAnalyze,
                      icon: _isAnalyzing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.auto_awesome_rounded, size: 24),
                      label: Text(
                        _isAnalyzing ? l10n.analyzingButton : l10n.saveAndAnalyzeButton,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Save to Diary button (always visible)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _isAnalyzing ? null : _saveToDiary,
                      icon: const Icon(Icons.bookmark_add_outlined, size: 20),
                      label: Text(
                        l10n.saveWithoutAnalysis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
