import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:miro_hybrid/core/theme/app_colors.dart';
import 'package:miro_hybrid/core/utils/logger.dart';
import 'package:miro_hybrid/core/utils/unit_converter.dart';
import 'package:miro_hybrid/core/constants/enums.dart';
import 'package:miro_hybrid/features/health/models/food_entry.dart';
import 'package:miro_hybrid/features/health/providers/health_provider.dart';
import 'package:miro_hybrid/core/widgets/search_mode_selector.dart';
import 'package:miro_hybrid/core/widgets/keyboard_done_bar.dart';

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
  String? _permanentImagePath;

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
    // Validate inputs
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

    // Create unanalyzed FoodEntry
    final entry = FoodEntry()
      ..foodName = foodName.isEmpty ? 'food' : foodName
      ..mealType = _guessMealType()
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

    // Save to database
    final notifier = ref.read(foodEntriesNotifierProvider.notifier);
    await notifier.addFoodEntry(entry);

    if (!mounted) return;

    // Refresh providers
    final today = dateOnly(DateTime.now());
    ref.invalidate(healthTimelineProvider(today));
    ref.invalidate(foodEntriesByDateProvider(today));
    ref.invalidate(todayCaloriesProvider);
    ref.invalidate(todayMacrosProvider);

    // Show success message
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Saved — use "Analyze All" when ready'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );

    // Navigate back to dashboard
    Navigator.of(context).popUntil((route) => route.isFirst);
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
    return PopScope(
      canPop: true,
      child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Analyze Food Image'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: KeyboardDoneBar(
        child: SingleChildScrollView(
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

                  // Save & Analyze Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _saveAndAnalyze,
                      icon: const Icon(Icons.save_rounded, size: 24),
                      label: const Text(
                        'Save & Analyze',
                        style: TextStyle(
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

                  // Save to Diary button (save photo as pending entry)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _saveToDiary,
                      icon: const Icon(Icons.bookmark_add_outlined, size: 20),
                      label: const Text(
                        'Save without analysis',
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
    ),
    );
  }
}
