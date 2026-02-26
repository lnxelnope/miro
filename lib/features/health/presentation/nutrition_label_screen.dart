import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/logger.dart';
import '../../../core/constants/enums.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/health_provider.dart';
import '../providers/analysis_provider.dart';
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
          const SizedBox(height: AppSpacing.lg),
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
          const SizedBox(height: AppSpacing.xxxl),
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
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.md + 2),
                      shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.md),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: _pickFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('From Gallery'),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.md + 2),
                      shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.md),
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
            margin: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: AppRadius.lg,
              border:
                  Border.all(color: AppColors.textTertiary.withValues(alpha: 0.3)),
            ),
            child: ClipRRect(
              borderRadius: AppRadius.lg,
              child: Image.file(
                _capturedImage!,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),

        // Actions
        Padding(
          padding: AppSpacing.paddingLg,
          child: _isAnalyzing
              ? const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: AppSpacing.md),
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
                          backgroundColor: AppColors.premium,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                          shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.md),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _takePicture,
                            icon: const Icon(Icons.camera_alt, size: 18),
                            label: const Text('Retake'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                              shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.md),
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
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                              shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.md),
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

    final entry = FoodEntry()
      ..foodName = 'Nutrition Label'
      ..mealType = _guessMealType()
      ..timestamp = DateTime.now()
      ..imagePath = _capturedImage!.path
      ..searchMode = FoodSearchMode.product
      ..source = DataSource.galleryScanned;

    final notifier = ref.read(foodEntriesNotifierProvider.notifier);
    await notifier.addFoodEntry(entry);

    if (!context.mounted) return;

    ref.read(analysisProvider.notifier).enqueue(
      entries: [entry],
      selectedDate: dateOnly(DateTime.now()),
    );

    refreshFoodProviders(ref, dateOnly(DateTime.now()));
    Navigator.pop(context);
  }

  MealType _guessMealType() {
    final hour = DateTime.now().hour;
    if (hour < 10) return MealType.breakfast;
    if (hour < 14) return MealType.lunch;
    if (hour < 17) return MealType.snack;
    return MealType.dinner;
  }
}
