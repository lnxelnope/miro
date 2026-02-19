import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/logger.dart';
import '../../../core/ai/gemini_service.dart';
import '../../../core/constants/enums.dart';
import '../../../features/energy/widgets/no_energy_dialog.dart';
import '../providers/health_provider.dart';
import '../providers/my_meal_provider.dart';
import '../widgets/gemini_analysis_sheet.dart';
import '../models/food_entry.dart';
import 'image_analysis_preview_screen.dart';

/// หน้าสแกนฉลากโภชนาการ
/// ถ่ายรูป Nutrition Facts Label → Gemini อ่านค่าจากฉลาก → บันทึก
class NutritionLabelScreen extends ConsumerStatefulWidget {
  const NutritionLabelScreen({super.key});

  @override
  ConsumerState<NutritionLabelScreen> createState() =>
      _NutritionLabelScreenState();
}

class _NutritionLabelScreenState extends ConsumerState<NutritionLabelScreen> {
  File? _capturedImage;
  bool _isAnalyzing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Nutrition Label'),
      ),
      body: _capturedImage == null ? _buildEmptyState() : _buildPreview(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📋', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            'Scan a nutrition label',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'AI will read Calories, Protein, Carbs, Fat\n'
            'automatically from the label (more accurate than estimation)',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _takePicture,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Photo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _pickFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('From Gallery'),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Column(
      children: [
        // Image preview
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: AppColors.textTertiary.withOpacity(0.3)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                _capturedImage!,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),

        // Actions
        Padding(
          padding: const EdgeInsets.all(16),
          child: _isAnalyzing
              ? const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('🧬 ANALYZING NUTRITION LABEL...'),
                  ],
                )
              : Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _analyzeLabel,
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('AI Analysis'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _takePicture,
                            icon: const Icon(Icons.camera_alt, size: 18),
                            label: const Text('Retake'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, size: 18),
                            label: const Text('Cancel'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
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
      ],
    );
  }

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 90,
    );

    if (photo != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ImageAnalysisPreviewScreen(
            imageFile: File(photo.path),
            initialFoodName: 'food',
          ),
        ),
      );
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 90,
    );

    if (photo != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ImageAnalysisPreviewScreen(
            imageFile: File(photo.path),
            initialFoodName: 'food',
          ),
        ),
      );
    }
  }

  Future<void> _analyzeLabel() async {
    if (_capturedImage == null) return;

    // ────── ตรวจสอบ Energy ก่อนเรียก API ──────
    final hasEnergy = await GeminiService.hasEnergy();
    if (!hasEnergy) {
      if (!context.mounted) return;
      await NoEnergyDialog.show(context);
      return;
    }

    setState(() => _isAnalyzing = true);

    // ────── แสดง loading dialog ──────
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await GeminiService.analyzeNutritionLabel(_capturedImage!);

      if (!context.mounted) return;
      Navigator.pop(context); // ปิด loading dialog
      setState(() => _isAnalyzing = false);

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Unable to read label. Try taking a clearer photo'),
              duration: Duration(seconds: 2)),
        );
        return;
      }

      // แสดงผล
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => GeminiAnalysisSheet(
          analysisResult: result,
          onConfirm: (confirmedData) async {
            final entry = FoodEntry()
              ..foodName = confirmedData.foodName
              ..foodNameEn = confirmedData.foodNameEn
              ..mealType = _guessMealType()
              ..timestamp = DateTime.now()
              ..imagePath = _capturedImage!.path
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
              ..notes = 'Scanned nutrition label';

            final notifier = ref.read(foodEntriesNotifierProvider.notifier);
            await notifier.addFoodEntry(entry);

            // Auto-save ingredient
            if (confirmedData.ingredientsDetail != null &&
                confirmedData.ingredientsDetail!.isNotEmpty) {
              try {
                await notifier.saveIngredientsAndMeal(
                  mealName: confirmedData.foodName,
                  mealNameEn: confirmedData.foodNameEn,
                  servingDescription:
                      '${confirmedData.servingSize} ${confirmedData.servingUnit}',
                  imagePath: _capturedImage!.path,
                  ingredientsData: confirmedData.ingredientsDetail!,
                );

                // Invalidate MyMeal providers to refresh UI
                ref.invalidate(allMyMealsProvider);
                ref.invalidate(allIngredientsProvider);
              } catch (e) {
                AppLogger.warn('Auto-save failed', e);
              }
            }

            refreshFoodProviders(ref, DateTime.now());

            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Saved "${confirmedData.foodName}"'),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 2),
              ),
            );
            Navigator.pop(context); // ปิด screen
          },
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      // ปิด loading dialog ถ้ายังเปิดอยู่
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      setState(() => _isAnalyzing = false);

      // ตรวจสอบว่าเป็น Energy error หรือไม่
      if (e.toString().contains('Insufficient energy')) {
        await NoEnergyDialog.show(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ $e'), duration: const Duration(seconds: 2)),
        );
      }
    }
  }

  MealType _guessMealType() {
    final hour = DateTime.now().hour;
    if (hour < 10) return MealType.breakfast;
    if (hour < 14) return MealType.lunch;
    if (hour < 17) return MealType.snack;
    return MealType.dinner;
  }
}
