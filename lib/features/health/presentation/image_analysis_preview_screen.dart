import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_hybrid/core/ai/gemini_service.dart';
import 'package:miro_hybrid/core/theme/app_colors.dart';
import 'package:miro_hybrid/core/utils/logger.dart';
import 'package:miro_hybrid/core/utils/unit_converter.dart';
import 'package:miro_hybrid/core/constants/enums.dart';
import 'package:miro_hybrid/features/health/models/food_entry.dart';
import 'package:miro_hybrid/features/health/providers/health_provider.dart';
import 'package:miro_hybrid/features/health/widgets/gemini_analysis_sheet.dart';
import 'package:miro_hybrid/features/energy/providers/energy_provider.dart';
import 'package:miro_hybrid/core/services/usage_limiter.dart';
import 'package:miro_hybrid/core/widgets/search_mode_selector.dart';
import 'dart:convert';

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
  bool _isAnalyzing = false;
  bool _isCancelled = false;
  FoodSearchMode _searchMode = FoodSearchMode.normal;

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
  }

  @override
  void dispose() {
    _isCancelled = true;
    _foodNameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  /// เตือนผู้ใช้ก่อนออกขณะ AI กำลังวิเคราะห์
  Future<bool> _onWillPop() async {
    if (!_isAnalyzing) return true;

    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 12),
            Expanded(child: Text('Analyzing...')),
          ],
        ),
        content: const Text(
          'AI is analyzing food\n\n'
          'If you leave now, the analysis result will be lost '
          'and you will need to re-analyze (costs Energy again)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Wait'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );

    if (shouldLeave == true) {
      _isCancelled = true;
      return true;
    }
    return false;
  }

  Future<void> _analyzeWithAI() async {
    if (_isAnalyzing) return;

    // Validate inputs
    final foodName = _foodNameController.text.trim();
    final quantityText = _quantityController.text.trim();

    double? quantity;
    if (quantityText.isNotEmpty) {
      quantity = double.tryParse(quantityText);
      if (quantity == null || quantity <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid quantity')),
        );
        return;
      }
    }

    setState(() {
      _isAnalyzing = true;
      _isCancelled = false;
    });

    if (!mounted) return;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      // Call AI analysis with optional parameters + search mode
      final result = await GeminiService.analyzeFoodImage(
        widget.imageFile,
        foodName: foodName.isEmpty ? null : foodName,
        quantity: quantity,
        unit: _selectedUnit,
        searchMode: _searchMode,
      );

      // ถ้า user กดออกระหว่างรอ → หยุดทำงาน
      if (_isCancelled || !mounted) return;

      if (result == null) {
        throw Exception('No result from AI analysis');
      }

      // Record AI usage after success
      await UsageLimiter.recordAiUsage();

      // Update energy badge
      if (_isCancelled || !mounted) return;
      ref.invalidate(energyBalanceProvider);
      ref.invalidate(currentEnergyProvider);

      // Show analysis result
      if (_isCancelled || !mounted) return;
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => GeminiAnalysisSheet(
          analysisResult: result,
          onConfirm: (confirmedData) async {
            // Create new FoodEntry
            final entry = FoodEntry()
              ..foodName = confirmedData.foodName
              ..foodNameEn = confirmedData.foodNameEn
              ..mealType = _guessMealType()
              ..timestamp = DateTime.now()
              ..imagePath = widget.imageFile.path
              ..servingSize = confirmedData.servingSize
              ..servingUnit = confirmedData.servingUnit
              ..servingGrams = confirmedData.servingGrams
              ..calories = confirmedData.calories
              ..protein = confirmedData.protein
              ..carbs = confirmedData.carbs
              ..fat = confirmedData.fat
              ..baseCalories = confirmedData.baseCalories
              ..baseProtein = confirmedData.baseProtein
              ..baseCarbs = confirmedData.baseCarbs
              ..baseFat = confirmedData.baseFat
              ..fiber = confirmedData.fiber
              ..sugar = confirmedData.sugar
              ..sodium = confirmedData.sodium
              ..source = DataSource.aiAnalyzed
              ..aiConfidence = confirmedData.confidence
              ..isVerified = true
              ..notes = confirmedData.notes;

            // Save ingredients JSON if available
            if (confirmedData.ingredientsDetail != null &&
                confirmedData.ingredientsDetail!.isNotEmpty) {
              entry.ingredientsJson =
                  jsonEncode(confirmedData.ingredientsDetail);
            }

            // Add to database
            final notifier = ref.read(foodEntriesNotifierProvider.notifier);
            await notifier.addFoodEntry(entry);

            // Refresh timeline to show the new entry immediately
            if (mounted) {
              final today = dateOnly(DateTime.now());
              ref.invalidate(healthTimelineProvider(today));
              ref.invalidate(foodEntriesByDateProvider(today));
              // Also refresh the food entries list
              ref.invalidate(foodEntriesNotifierProvider);
            }

            // Auto-save ingredients and meal if available
            if (confirmedData.ingredientsDetail != null &&
                confirmedData.ingredientsDetail!.isNotEmpty) {
              try {
                await notifier.saveIngredientsAndMeal(
                  mealName: confirmedData.foodName,
                  mealNameEn: confirmedData.foodNameEn,
                  servingDescription:
                      '${confirmedData.servingSize} ${confirmedData.servingUnit}',
                  imagePath: entry.imagePath,
                  ingredientsData: confirmedData.ingredientsDetail!,
                );
              } catch (e) {
                AppLogger.error('Error saving ingredients/meal', e);
              }
            }

            // Navigate back to home after analysis
            if (mounted) {
              navigator.popUntil((route) => route.isFirst);
            }
          },
        ),
      );
    } catch (e) {
      if (_isCancelled || !mounted) return;

      messenger.showSnackBar(
        SnackBar(content: Text('Analysis failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
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
      ..mealType = _guessMealType()
      ..timestamp = DateTime.now()
      ..imagePath = widget.imageFile.path
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
    ref.invalidate(foodEntriesNotifierProvider);

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
    return PopScope(
      canPop: !_isAnalyzing,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldLeave = await _onWillPop();
        if (shouldLeave && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Analyze Food Image'),
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

            // Inline loading indicator (แทน dialog)
            if (_isAnalyzing)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'AI is analyzing food...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Please wait...',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

            if (!_isAnalyzing) const SizedBox(height: 0),

            // Input Section (ซ่อนเมื่อกำลังวิเคราะห์)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food Name Input
                  Text(
                    'Food name',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _foodNameController,
                    decoration: InputDecoration(
                      hintText: 'e.g., Grilled chicken salad',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Search Mode Toggle
                  SearchModeSelector(
                    selectedMode: _searchMode,
                    onChanged: (mode) => setState(() => _searchMode = mode),
                  ),

                  const SizedBox(height: 16),

                  // Quantity and Unit Row
                  Text(
                    'Quantity',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Quantity Input
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

                      // Unit Dropdown
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

                  const SizedBox(height: 20),

                  // Helper Text
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.blue[700],
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Entering the food name and quantity is optional, but providing them will improve AI analysis accuracy.',
                            style: TextStyle(
                              color: Colors.blue[900],
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Analyze Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isAnalyzing ? null : _analyzeWithAI,
                      icon: _isAnalyzing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.auto_awesome, size: 24),
                      label: Text(
                        _isAnalyzing ? 'Analyzing...' : 'Analyze with AI',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isAnalyzing
                            ? Colors.grey[400]
                            : AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Save to Diary button (save photo as pending entry)
                  if (!_isAnalyzing)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _saveToDiary,
                        icon: const Icon(Icons.bookmark_add_outlined, size: 20),
                        label: const Text(
                          'Save to Diary',
                          style: TextStyle(
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
