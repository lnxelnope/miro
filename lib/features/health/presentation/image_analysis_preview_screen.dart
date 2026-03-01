import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:miro_hybrid/core/theme/app_colors.dart';
import 'package:miro_hybrid/core/theme/app_tokens.dart';
import 'package:miro_hybrid/core/utils/logger.dart';
import 'package:miro_hybrid/core/utils/unit_converter.dart';
import 'package:miro_hybrid/core/constants/enums.dart';
import 'package:miro_hybrid/core/services/image_picker_service.dart';
import 'package:miro_hybrid/core/ar_scale/ar_scale.dart';
import 'package:miro_hybrid/features/health/models/food_entry.dart';
import 'package:miro_hybrid/features/health/providers/health_provider.dart';
import 'package:miro_hybrid/features/health/providers/analysis_provider.dart';
import 'package:miro_hybrid/core/widgets/search_mode_selector.dart';
import 'package:miro_hybrid/l10n/app_localizations.dart';

class ImageAnalysisPreviewScreen extends ConsumerStatefulWidget {
  final File? imageFile;
  final String? initialFoodName;
  final double? initialQuantity;
  final String? initialUnit;
  final MealType? initialMealType;
  final DateTime? selectedDate;

  const ImageAnalysisPreviewScreen({
    super.key,
    this.imageFile,
    this.initialFoodName,
    this.initialQuantity,
    this.initialUnit,
    this.initialMealType,
    this.selectedDate,
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
  File? _currentImageFile;

  // AR Scale state
  CalibrationResult? _calibrationResult;
  List<DetectedObjectLabel> _objectLabels = [];
  bool _isDetecting = false;
  Size _imageSize = Size.zero;

  bool get _hasImage => _currentImageFile != null;

  @override
  void initState() {
    super.initState();
    _currentImageFile = widget.imageFile;
    _foodNameController = TextEditingController(
      text: widget.initialFoodName ?? (_hasImage ? 'food' : ''),
    );
    _quantityController = TextEditingController(
      text: (widget.initialQuantity ?? 1.0).toString(),
    );
    _selectedUnit = widget.initialUnit ?? 'serving';
    _selectedMealType = widget.initialMealType ?? _guessMealType();
    if (_hasImage) {
      _copyImageToPermanentPath();
      _runARDetection(_currentImageFile!);
    }
  }

  Future<void> _copyImageToPermanentPath() async {
    if (_currentImageFile == null) return;
    try {
      final appDir = await getApplicationDocumentsDirectory();
      if (_currentImageFile!.path.startsWith(appDir.path)) {
        _permanentImagePath = _currentImageFile!.path;
        return;
      }
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final destPath = '${appDir.path}/$fileName';
      await _currentImageFile!.copy(destPath);
      _permanentImagePath = destPath;
    } catch (e) {
      AppLogger.error('Failed to copy image to permanent path', e);
      _permanentImagePath = _currentImageFile!.path;
    }
  }

  /// เรียก ML Kit detect + calibrate หลังจากได้รูปแล้ว
  Future<void> _runARDetection(File imageFile) async {
    if (!mounted) return;
    setState(() => _isDetecting = true);

    try {
      final imageBytes = await imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      final imgWidth = frame.image.width.toDouble();
      final imgHeight = frame.image.height.toDouble();
      frame.image.dispose();

      if (mounted) {
        setState(() => _imageSize = Size(imgWidth, imgHeight));
      }

      final detector = ReferenceDetectorService.instance;

      // 1. detect ทุก object สำหรับ label overlay (ไม่ filter)
      final allLabels = await detector.detectAllObjectLabels(imageFile);

      // 2. detect reference objects สำหรับ calibration (ส่ง Gemini)
      final detected = await detector.detectFromImage(imageFile);
      CalibrationResult? calibration;
      if (detected.isNotEmpty) {
        final plate = await detector.detectPlate(imageFile);
        calibration = ScaleCalibrationService.calibrate(
          referenceObject: detected.first,
          plateBoundingBox: plate?.boundingBox,
          imageWidth: imgWidth,
          imageHeight: imgHeight,
        );
      }

      if (!mounted) return;
      setState(() {
        _objectLabels = allLabels;
        _calibrationResult = calibration;
        _isDetecting = false;
      });
    } catch (e) {
      AppLogger.error('[AR] Detection error', e);
      if (mounted) setState(() => _isDetecting = false);
    }
  }

  Future<void> _pickImageFromCamera() async {
    final file = await ImagePickerService.pickFromCamera();
    if (file != null && mounted) {
      setState(() {
        _currentImageFile = file;
        _calibrationResult = null;
        _objectLabels = [];
      });
      await _copyImageToPermanentPath();
      await _runARDetection(file);
    }
  }

  Future<void> _pickImageFromGallery() async {
    final file = await ImagePickerService.pickFromGallery();
    if (file != null && mounted) {
      setState(() {
        _currentImageFile = file;
        _calibrationResult = null;
        _objectLabels = [];
      });
      await _copyImageToPermanentPath();
      await _runARDetection(file);
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

    if (!_hasImage && foodName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10n.of(context)!.pleaseEnterFoodNameFirst),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

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

    final effectiveName = foodName.isEmpty
        ? (_searchMode == FoodSearchMode.product ? 'product' : 'food')
        : foodName;
    final imagePath = _hasImage
        ? (_permanentImagePath ?? _currentImageFile!.path)
        : null;

    final date = widget.selectedDate ?? DateTime.now();
    final now = DateTime.now();
    final entryTimestamp = DateTime(date.year, date.month, date.day, now.hour, now.minute);

    final calibration = _calibrationResult;

    final entry = FoodEntry()
      ..foodName = effectiveName
      ..mealType = _selectedMealType
      ..timestamp = entryTimestamp
      ..imagePath = imagePath
      ..servingSize = quantity
      ..servingUnit = _selectedUnit
      ..calories = 0
      ..protein = 0
      ..carbs = 0
      ..fat = 0
      ..source = _hasImage ? DataSource.galleryScanned : DataSource.manual
      ..isVerified = false
      ..searchMode = _searchMode
      ..referenceObjectUsed = calibration?.referenceObject.type.name
      ..referenceConfidence = calibration?.referenceObject.confidence
      ..plateDiameterCm = calibration?.plateDiameterCm
      ..estimatedVolumeMl = calibration?.estimatedVolumeMl
      ..isCalibrated = calibration?.shouldUseCalibration ?? false
      // AR Label Overlay data (เก็บ JSON เพื่อ overlay ตอนแสดงผล)
      ..arLabelsJson = _objectLabels.isNotEmpty
          ? DetectedObjectLabel.encode(_objectLabels) : null
      ..arImageWidth = _imageSize.width > 0 ? _imageSize.width : null
      ..arImageHeight = _imageSize.height > 0 ? _imageSize.height : null
      ..arPixelPerCm = calibration?.pixelPerCm;

    debugPrint(
      '>>> [AR Save analyze] labels=${_objectLabels.length}, '
      'imgSize=${_imageSize.width.toInt()}x${_imageSize.height.toInt()}, '
      'jsonLen=${entry.arLabelsJson?.length ?? 0}',
    );

    final notifier = ref.read(foodEntriesNotifierProvider.notifier);
    await notifier.addFoodEntry(entry);

    if (!mounted) return;

    final selectedDate = dateOnly(date);
    ref.read(analysisProvider.notifier).enqueue(
      entries: [entry],
      selectedDate: selectedDate,
    );

    refreshFoodProviders(ref, selectedDate);
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

    if (!_hasImage && foodName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10n.of(context)!.pleaseEnterFoodNameFirst),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final date = widget.selectedDate ?? DateTime.now();
    final now = DateTime.now();
    final entryTimestamp = DateTime(date.year, date.month, date.day, now.hour, now.minute);

    final imagePath = _hasImage
        ? (_permanentImagePath ?? _currentImageFile!.path)
        : null;

    final effectiveName = foodName.isEmpty
        ? (_searchMode == FoodSearchMode.product ? 'product' : 'food')
        : foodName;

    final entry = FoodEntry()
      ..foodName = effectiveName
      ..mealType = _selectedMealType
      ..timestamp = entryTimestamp
      ..imagePath = imagePath
      ..servingSize = quantity
      ..servingUnit = _selectedUnit
      ..calories = 0
      ..protein = 0
      ..carbs = 0
      ..fat = 0
      ..source = _hasImage ? DataSource.galleryScanned : DataSource.manual
      ..isVerified = false
      ..searchMode = _searchMode
      // AR Label Overlay data
      ..arLabelsJson = _objectLabels.isNotEmpty
          ? DetectedObjectLabel.encode(_objectLabels) : null
      ..arImageWidth = _imageSize.width > 0 ? _imageSize.width : null
      ..arImageHeight = _imageSize.height > 0 ? _imageSize.height : null
      ..arPixelPerCm = _calibrationResult?.pixelPerCm;

    debugPrint(
      '>>> [AR Save diary] labels=${_objectLabels.length}, '
      'imgSize=${_imageSize.width.toInt()}x${_imageSize.height.toInt()}, '
      'jsonLen=${entry.arLabelsJson?.length ?? 0}',
    );

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(l10n.addFoodTitle),
          elevation: 0,
        ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Preview (only if has image)
            if (_hasImage)
              Container(
                height: 300,
                color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ArLabelOverlay(
                      labels: _objectLabels,
                      imageSize: _imageSize,
                      pixelPerCm: _calibrationResult?.pixelPerCm,
                      child: Image.file(
                        _currentImageFile!,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    // Loading indicator ระหว่าง detect
                    if (_isDetecting)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black26,
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Detecting objects...',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _currentImageFile = null;
                          _permanentImagePath = null;
                          _calibrationResult = null;
                          _objectLabels = [];
                        }),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // แสดง detection status หรือ tip
            if (_currentImageFile != null) ...[
              const SizedBox(height: 8),
              if (_objectLabels.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Detected ${_objectLabels.length} object${_objectLabels.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else if (!_isDetecting)
                const ReferenceGuideTip(compact: true),
            ],

            // No Image — show camera/gallery options
            if (!_hasImage)
              Container(
                margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.04),
                  borderRadius: AppRadius.lg,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.add_a_photo_rounded, size: 40,
                        color: AppColors.primary.withValues(alpha: 0.4)),
                    const SizedBox(height: 12),
                    Text(
                      l10n.foodNameQuantityAndModeImprovesAccuracy,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickImageFromCamera,
                            icon: const Icon(Icons.camera_alt_rounded, size: 20),
                            label: Text(l10n.navCamera),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.md,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickImageFromGallery,
                            icon: const Icon(Icons.photo_library_rounded, size: 20),
                            label: Text(l10n.navGallery),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.md,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _foodNameController,
                    autofocus: !_hasImage,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: l10n.foodNameHint,
                      hintStyle: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textTertiary,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        size: 20,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                      fillColor: isDark
                          ? AppColors.surfaceVariantDark
                          : AppColors.surfaceVariant,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? AppColors.dividerDark
                              : AppColors.divider,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),

                  // Helper Text
                  if (_hasImage)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 14,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              l10n.foodNameQuantityAndModeImprovesAccuracy,
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                      fontSize: 16,
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
                          style: const TextStyle(
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                        fontSize: 16,
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
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: '1',
                              hintStyle: TextStyle(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textTertiary,
                              ),
                              fillColor: isDark
                                  ? AppColors.surfaceVariantDark
                                  : AppColors.surfaceVariant,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? AppColors.dividerDark
                                      : AppColors.divider,
                                ),
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
                            value: _selectedUnit,
                            decoration: InputDecoration(
                              fillColor: isDark
                                  ? AppColors.surfaceVariantDark
                                  : AppColors.surfaceVariant,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? AppColors.dividerDark
                                      : AppColors.divider,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            dropdownColor: isDark
                                ? AppColors.surfaceDark
                                : Colors.white,
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: MealType.values.map((type) {
                        final isSelected = _selectedMealType == type;
                        final labelColor = isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary;
                        return ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(type.icon, size: 16, color: type.iconColor),
                              const SizedBox(width: 6),
                              Text(
                                type.displayName,
                                style: TextStyle(color: labelColor),
                              ),
                            ],
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedMealType = type);
                          },
                          selectedColor: AppColors.health.withValues(alpha: 0.2),
                          backgroundColor: isDark
                              ? AppColors.surfaceVariantDark
                              : AppColors.surfaceVariant,
                          side: BorderSide(
                            color: isDark
                                ? AppColors.dividerDark
                                : AppColors.divider,
                          ),
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
                        foregroundColor: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                        side: BorderSide(
                          color: isDark
                              ? AppColors.dividerDark
                              : AppColors.divider,
                        ),
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
