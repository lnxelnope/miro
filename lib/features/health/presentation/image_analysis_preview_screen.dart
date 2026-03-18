import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
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
import 'package:miro_hybrid/core/database/app_database.dart';
import 'package:miro_hybrid/core/database/model_extensions.dart';
import 'package:miro_hybrid/features/health/providers/health_provider.dart';
import 'package:miro_hybrid/features/health/providers/analysis_provider.dart';
import 'package:miro_hybrid/core/widgets/search_mode_selector.dart';
import 'package:miro_hybrid/l10n/app_localizations.dart';

class ImageAnalysisPreviewScreen extends ConsumerStatefulWidget {
  final File? imageFile;
  final List<File>? arScanImages;
  final String? initialFoodName;
  final double? initialQuantity;
  final String? initialUnit;
  final MealType? initialMealType;
  final DateTime? selectedDate;

  const ImageAnalysisPreviewScreen({
    super.key,
    this.imageFile,
    this.arScanImages,
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
  final bool _isAnalyzing = false;
  bool _showDetails = false;
  File? _currentImageFile;

  // AR Scale state
  CalibrationResult? _calibrationResult;
  List<DetectedObjectLabel> _objectLabels = [];
  bool _isDetecting = false;
  Size _imageSize = Size.zero;

  // Multi-image (AR scan) state
  List<File> _arScanImages = [];
  int _arScanPage = 0;
  final PageController _arScanPageController = PageController();
  final Map<int, List<DetectedObjectLabel>> _arScanLabelsCache = {};
  final Map<int, Size> _arScanSizeCache = {};
  final Map<int, CalibrationResult?> _arScanCalibCache = {};
  final Map<int, bool> _arScanDetecting = {};

  bool get _hasMultiImages => _arScanImages.length > 1;
  bool get _hasImage => _currentImageFile != null;

  @override
  void initState() {
    super.initState();
    _arScanImages = widget.arScanImages ?? [];
    if (_arScanImages.isNotEmpty) {
      _currentImageFile = _arScanImages.first;
    } else {
      _currentImageFile = widget.imageFile;
    }
    _foodNameController = TextEditingController(
      text: widget.initialFoodName ?? '',
    );
    _quantityController = TextEditingController(
      text: (widget.initialQuantity ?? 1.0).toString(),
    );
    _selectedUnit = widget.initialUnit ?? 'serving';
    _selectedMealType = widget.initialMealType ?? _guessMealType();
    if (_hasMultiImages) {
      _copyImageToPermanentPath();
      for (int i = 0; i < _arScanImages.length; i++) {
        _runARDetectionForIndex(i);
      }
    } else if (_hasImage) {
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

  Future<List<String>> _copyAllArImagesToPermanentPaths() async {
    if (_arScanImages.isEmpty) return [];
    final appDir = await getApplicationDocumentsDirectory();
    final paths = <String>[];
    for (int i = 0; i < _arScanImages.length; i++) {
      try {
        final file = _arScanImages[i];
        if (file.path.startsWith(appDir.path)) {
          paths.add(file.path);
        } else {
          final ts = DateTime.now().millisecondsSinceEpoch + i;
          final destPath = '${appDir.path}/arscan_$ts.jpg';
          await file.copy(destPath);
          paths.add(destPath);
        }
      } catch (e) {
        AppLogger.error('Failed to copy AR image $i', e);
        paths.add(_arScanImages[i].path);
      }
    }
    if (paths.isNotEmpty) _permanentImagePath = paths.first;
    return paths;
  }

  /// เรียก ML Kit detect + calibrate หลังจากได้รูปแล้ว
  Future<void> _runARDetection(File imageFile) async {
    if (!mounted) return;
    setState(() => _isDetecting = true);

    try {
      final imageBytes = await imageFile.readAsBytes();
      final correctedSize = await getExifCorrectedImageSize(imageBytes);
      final imgWidth = correctedSize.width;
      final imgHeight = correctedSize.height;

      if (mounted) {
        setState(() => _imageSize = Size(imgWidth, imgHeight));
      }

      final detector = ReferenceDetectorService.instance;

      // 1. detect ทุก object สำหรับ label overlay (ไม่ filter)
      final rawLabels = await detector.detectAllObjectLabels(imageFile);
      final allLabels = _transformLabelsForExif(rawLabels, imageBytes);

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

  Future<void> _runARDetectionForIndex(int index) async {
    if (!mounted || index >= _arScanImages.length) return;
    setState(() => _arScanDetecting[index] = true);

    try {
      final file = _arScanImages[index];
      final imageBytes = await file.readAsBytes();
      final correctedSize = await getExifCorrectedImageSize(imageBytes);
      final imgW = correctedSize.width;
      final imgH = correctedSize.height;

      final detector = ReferenceDetectorService.instance;
      final rawLabels = await detector.detectAllObjectLabels(file);
      final allLabels = _transformLabelsForExif(rawLabels, imageBytes);
      final detected = await detector.detectFromImage(file);
      CalibrationResult? calibration;
      if (detected.isNotEmpty) {
        final plate = await detector.detectPlate(file);
        calibration = ScaleCalibrationService.calibrate(
          referenceObject: detected.first,
          plateBoundingBox: plate?.boundingBox,
          imageWidth: imgW,
          imageHeight: imgH,
        );
      }

      if (!mounted) return;
      setState(() {
        _arScanLabelsCache[index] = allLabels;
        _arScanSizeCache[index] = Size(imgW, imgH);
        _arScanCalibCache[index] = calibration;
        _arScanDetecting[index] = false;
      });

      if (index == 0) {
        setState(() {
          _objectLabels = allLabels;
          _imageSize = Size(imgW, imgH);
          _calibrationResult = calibration;
        });
      }
    } catch (e) {
      AppLogger.error('[AR] Multi-image detection error idx=$index', e);
      if (mounted) setState(() => _arScanDetecting[index] = false);
    }
  }

  CalibrationResult? _bestCalibrationAcrossImages() {
    CalibrationResult? best;
    for (final entry in _arScanCalibCache.entries) {
      final c = entry.value;
      if (c == null) continue;
      if (best == null ||
          c.referenceObject.confidence > best.referenceObject.confidence) {
        best = c;
      }
    }
    return best;
  }

  void _onArScanPageChanged(int index) {
    setState(() {
      _arScanPage = index;
      _currentImageFile = _arScanImages[index];
      _objectLabels = _arScanLabelsCache[index] ?? [];
      _imageSize = _arScanSizeCache[index] ?? Size.zero;
      _calibrationResult = _arScanCalibCache[index];
      _isDetecting = _arScanDetecting[index] ?? false;
    });
    _copyImageToPermanentPath();
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _quantityController.dispose();
    _arScanPageController.dispose();
    super.dispose();
  }

  Widget _buildSingleImagePreview() {
    return Stack(
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
        if (_isDetecting) _buildDetectingIndicator(),
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
    );
  }

  Widget _buildMultiImagePreview() {
    return Stack(
      children: [
        PageView.builder(
          controller: _arScanPageController,
          itemCount: _arScanImages.length,
          onPageChanged: _onArScanPageChanged,
          itemBuilder: (_, index) {
            final file = _arScanImages[index];
            final labels = _arScanLabelsCache[index] ?? [];
            final imgSize = _arScanSizeCache[index] ?? Size.zero;
            final calib = _arScanCalibCache[index];
            final detecting = _arScanDetecting[index] ?? false;

            return Stack(
              fit: StackFit.expand,
              children: [
                ArLabelOverlay(
                  labels: labels,
                  imageSize: imgSize,
                  pixelPerCm: calib?.pixelPerCm,
                  child: Image.file(
                    file,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                if (detecting) _buildDetectingIndicator(),
              ],
            );
          },
        ),
        // Page dots indicator
        Positioned(
          left: 0,
          right: 0,
          bottom: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_arScanImages.length, (i) {
              final isActive = i == _arScanPage;
              return Container(
                width: isActive ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isActive
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.4),
                ),
              );
            }),
          ),
        ),
        // Page counter
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${_arScanPage + 1}/${_arScanImages.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetectingIndicator() {
    return Positioned.fill(
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
    );
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

    final effectiveName = foodName.isEmpty ? '--' : foodName;

    // Copy all AR images to permanent storage
    String? imagePath;
    String? supPath2;
    String? supPath3;
    if (_hasMultiImages) {
      final paths = await _copyAllArImagesToPermanentPaths();
      imagePath = paths.isNotEmpty ? paths[0] : null;
      supPath2 = paths.length > 1 ? paths[1] : null;
      supPath3 = paths.length > 2 ? paths[2] : null;
    } else {
      imagePath = _hasImage
          ? (_permanentImagePath ?? _currentImageFile!.path)
          : null;
    }

    final date = widget.selectedDate ?? DateTime.now();
    final now = DateTime.now();
    final entryTimestamp = DateTime(date.year, date.month, date.day, now.hour, now.minute);

    final calibration = _hasMultiImages
        ? _bestCalibrationAcrossImages()
        : _calibrationResult;

    final isAr = _hasMultiImages;
    final source = !_hasImage
        ? DataSource.manual
        : (isAr ? DataSource.arScan : DataSource.galleryScanned);

    // Build per-image AR detection data
    String? arLabelsJson;
    double? arImgW;
    double? arImgH;
    if (isAr) {
      final imageDetections = <ArImageDetectionData>[];
      for (int i = 0; i < _arScanImages.length; i++) {
        final labels = _arScanLabelsCache[i] ?? [];
        final size = _arScanSizeCache[i];
        final calib = _arScanCalibCache[i];
        imageDetections.add(ArImageDetectionData(
          imageIndex: i,
          imageWidth: size?.width ?? 0,
          imageHeight: size?.height ?? 0,
          pixelPerCm: calib?.pixelPerCm,
          labels: labels,
        ));
      }
      if (imageDetections.any((d) => d.labels.isNotEmpty)) {
        arLabelsJson = ArImageDetectionData.encodeMultiImage(imageDetections);
      }
      final firstSize = _arScanSizeCache[0];
      arImgW = firstSize?.width;
      arImgH = firstSize?.height;
    } else {
      arLabelsJson = _objectLabels.isNotEmpty
          ? DetectedObjectLabel.encode(_objectLabels)
          : null;
      arImgW = _imageSize.width > 0 ? _imageSize.width : null;
      arImgH = _imageSize.height > 0 ? _imageSize.height : null;
    }

    final entry = FoodEntry(
      id: 0,
      foodName: effectiveName,
      mealType: _selectedMealType,
      timestamp: entryTimestamp,
      imagePath: imagePath,
      supplementaryImagePath2: supPath2,
      supplementaryImagePath3: supPath3,
      servingSize: quantity,
      servingUnit: _selectedUnit,
      calories: 0,
      protein: 0,
      carbs: 0,
      fat: 0,
      baseCalories: 0,
      baseProtein: 0,
      baseCarbs: 0,
      baseFat: 0,
      source: source,
      isVerified: false,
      searchMode: _searchMode,
      referenceObjectUsed: calibration?.referenceObject.type.name,
      referenceConfidence: calibration?.referenceObject.confidence,
      plateDiameterCm: calibration?.plateDiameterCm,
      estimatedVolumeMl: calibration?.estimatedVolumeMl,
      isCalibrated: calibration?.shouldUseCalibration ?? false,
      arLabelsJson: arLabelsJson,
      arImageWidth: arImgW,
      arImageHeight: arImgH,
      arPixelPerCm: calibration?.pixelPerCm,
      isDeleted: false,
      isGroupOriginal: false,
      editCount: 0,
      isUserCorrected: false,
      isSynced: false,
      createdAt: now,
      updatedAt: now,
    );

    debugPrint(
      '>>> [AR Save analyze] multiImage=$isAr, '
      'perImageLabels=${isAr ? _arScanLabelsCache.entries.map((e) => '${e.key}:${e.value.length}').join(',') : _objectLabels.length}, '
      'paths=[${imagePath != null ? 1 : 0},${supPath2 != null ? 1 : 0},${supPath3 != null ? 1 : 0}]',
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

    String? imagePath;
    String? supPath2;
    String? supPath3;
    if (_hasMultiImages) {
      final paths = await _copyAllArImagesToPermanentPaths();
      imagePath = paths.isNotEmpty ? paths[0] : null;
      supPath2 = paths.length > 1 ? paths[1] : null;
      supPath3 = paths.length > 2 ? paths[2] : null;
    } else {
      imagePath = _hasImage
          ? (_permanentImagePath ?? _currentImageFile!.path)
          : null;
    }

    final effectiveName = foodName.isEmpty ? '--' : foodName;
    final isAr = _hasMultiImages;
    final source = !_hasImage
        ? DataSource.manual
        : (isAr ? DataSource.arScan : DataSource.galleryScanned);

    final entry = FoodEntry(
      id: 0,
      foodName: effectiveName,
      mealType: _selectedMealType,
      timestamp: entryTimestamp,
      imagePath: imagePath,
      supplementaryImagePath2: supPath2,
      supplementaryImagePath3: supPath3,
      servingSize: quantity,
      servingUnit: _selectedUnit,
      calories: 0,
      protein: 0,
      carbs: 0,
      fat: 0,
      baseCalories: 0,
      baseProtein: 0,
      baseCarbs: 0,
      baseFat: 0,
      source: source,
      isVerified: false,
      searchMode: _searchMode,
      arLabelsJson: _objectLabels.isNotEmpty
          ? DetectedObjectLabel.encode(_objectLabels) : null,
      arImageWidth: _imageSize.width > 0 ? _imageSize.width : null,
      arImageHeight: _imageSize.height > 0 ? _imageSize.height : null,
      arPixelPerCm: _calibrationResult?.pixelPerCm,
      isDeleted: false,
      isGroupOriginal: false,
      editCount: 0,
      isUserCorrected: false,
      isCalibrated: false,
      isSynced: false,
      createdAt: now,
      updatedAt: now,
    );

    debugPrint(
      '>>> [AR Save diary] multiImage=$isAr, labels=${_objectLabels.length}, '
      'paths=[${imagePath != null ? 1 : 0},${supPath2 != null ? 1 : 0},${supPath3 != null ? 1 : 0}]',
    );

    final notifier = ref.read(foodEntriesNotifierProvider.notifier);
    await notifier.addFoodEntry(entry);

    if (!mounted) return;

    final selectedDate = dateOnly(date);
    refreshFoodProviders(ref, selectedDate);

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
            // Image Preview
            if (_hasImage)
              Container(
                height: 300,
                color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
                child: _hasMultiImages
                    ? _buildMultiImagePreview()
                    : _buildSingleImagePreview(),
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
                      hintText: _hasImage ? l10n.imageFoodNameHint : l10n.foodNameHint,
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
                            initialValue: _selectedUnit,
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

/// Get the image size as Flutter's Image.file would render it.
///
/// Uses `instantiateImageCodec` which auto-applies EXIF rotation —
/// identical to how Flutter's `Image.file` widget decodes the image.
/// This guarantees `_imageSize` matches the rendered size exactly.
///
/// NOTE: Do NOT use manual SOF+EXIF parsing here. It caused recurring
/// mismatches with Flutter's rendering on iOS, leading to bounding box
/// offset bugs. The codec approach is the single source of truth.
Future<Size> getExifCorrectedImageSize(Uint8List bytes) async {
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  final w = frame.image.width.toDouble();
  final h = frame.image.height.toDouble();
  frame.image.dispose();
  debugPrint('[ImageSize] codec: ${w.toInt()}x${h.toInt()}');
  return Size(w, h);
}

/// On iOS, ML Kit `InputImage.fromFilePath` returns bounding boxes in the RAW
/// sensor pixel space (landscape, e.g. 4032×3024), NOT in display space.
/// This function transforms them to EXIF-corrected display space so
/// BoundingBoxPainter (which uses codec/display dimensions) maps correctly.
///
/// On Android, ML Kit already returns display-space coords — no transform.
///
/// ROTATION MATH (verified with pixel grid):
///
/// For a raw image W_raw × H_raw, display after rotation is H_raw × W_raw.
///
///   Orientation 6 (90° CW — most common iOS portrait):
///     display_x = H_raw - raw_y
///     display_y = raw_x
///
///   Orientation 8 (90° CCW):
///     display_x = raw_y
///     display_y = W_raw - raw_x
///
/// IMPORTANT: Previous implementations had case 6 and case 8 SWAPPED,
/// which caused the bounding box to shift in the wrong direction.
List<DetectedObjectLabel> _transformLabelsForExif(
  List<DetectedObjectLabel> labels,
  Uint8List imageBytes,
) {
  if (!Platform.isIOS || labels.isEmpty) return labels;

  final rawSize = _readJpegSofDimensions(imageBytes);
  if (rawSize == null) {
    debugPrint('[EXIF Transform] Not JPEG or SOF unreadable — skipping');
    return labels;
  }

  final orientation = _readJpegExifOrientation(imageBytes);
  if (orientation < 5 || orientation > 8) return labels;

  final rawW = rawSize.width;
  final rawH = rawSize.height;

  debugPrint(
    '[EXIF Transform] orientation=$orientation, '
    'raw=${rawW.toInt()}x${rawH.toInt()}, labels=${labels.length}',
  );

  return labels.map((label) {
    double cx, cy, bw, bh;
    switch (orientation) {
      case 6: // 90° CW (most common iOS portrait)
        cx = rawH - label.centerY;
        cy = label.centerX;
        bw = label.bboxHeight;
        bh = label.bboxWidth;
      case 8: // 90° CCW (270° CW)
        cx = label.centerY;
        cy = rawW - label.centerX;
        bw = label.bboxHeight;
        bh = label.bboxWidth;
      case 5: // transposed (mirror + swap axes)
        cx = label.centerY;
        cy = label.centerX;
        bw = label.bboxHeight;
        bh = label.bboxWidth;
      case 7: // transverse (mirror + 180° + swap)
        cx = rawH - label.centerY;
        cy = rawW - label.centerX;
        bw = label.bboxHeight;
        bh = label.bboxWidth;
      default:
        return label;
    }

    debugPrint(
      '  [EXIF] "${label.label}" raw(${label.centerX.toInt()},${label.centerY.toInt()}) '
      '→ display(${cx.toInt()},${cy.toInt()})',
    );

    return DetectedObjectLabel(
      label: label.label,
      confidence: label.confidence,
      centerX: cx,
      centerY: cy,
      bboxWidth: bw,
      bboxHeight: bh,
    );
  }).toList();
}

/// Read raw pixel dimensions from JPEG SOF (Start Of Frame) marker.
/// Returns the physical pixel dimensions before any EXIF rotation.
Size? _readJpegSofDimensions(Uint8List bytes) {
  if (bytes.length < 4 || bytes[0] != 0xFF || bytes[1] != 0xD8) return null;

  int offset = 2;
  while (offset < bytes.length - 2) {
    if (bytes[offset] != 0xFF) return null;
    final marker = bytes[offset + 1];

    if (marker >= 0xC0 && marker <= 0xCF && marker != 0xC4 && marker != 0xC8) {
      if (offset + 8 >= bytes.length) return null;
      final height = (bytes[offset + 5] << 8) | bytes[offset + 6];
      final width = (bytes[offset + 7] << 8) | bytes[offset + 8];
      return Size(width.toDouble(), height.toDouble());
    }

    if (marker == 0xDA) return null;
    if (offset + 3 >= bytes.length) return null;
    final segmentLength = (bytes[offset + 2] << 8) | bytes[offset + 3];
    offset += 2 + segmentLength;
  }

  return null;
}

/// Read EXIF orientation tag from JPEG. Returns 1 if unreadable.
int _readJpegExifOrientation(Uint8List bytes) {
  if (bytes.length < 12 || bytes[0] != 0xFF || bytes[1] != 0xD8) return 1;

  int offset = 2;
  while (offset < bytes.length - 4) {
    if (bytes[offset] != 0xFF) return 1;
    final marker = bytes[offset + 1];

    if (marker == 0xE1) {
      final exifStart = offset + 4;
      if (exifStart + 6 > bytes.length) return 1;
      if (bytes[exifStart] != 0x45 || bytes[exifStart + 1] != 0x78 ||
          bytes[exifStart + 2] != 0x69 || bytes[exifStart + 3] != 0x66) {
        return 1;
      }

      final tiffStart = exifStart + 6;
      if (tiffStart + 8 > bytes.length) return 1;

      final le = bytes[tiffStart] == 0x49;

      int read16(int o) => le
          ? (bytes[o] | (bytes[o + 1] << 8))
          : ((bytes[o] << 8) | bytes[o + 1]);
      int read32(int o) => le
          ? (bytes[o] |
              (bytes[o + 1] << 8) |
              (bytes[o + 2] << 16) |
              (bytes[o + 3] << 24))
          : ((bytes[o] << 24) |
              (bytes[o + 1] << 16) |
              (bytes[o + 2] << 8) |
              bytes[o + 3]);

      final ifd0Offset = tiffStart + read32(tiffStart + 4);
      if (ifd0Offset + 2 > bytes.length) return 1;

      final entries = read16(ifd0Offset);
      for (int i = 0; i < entries; i++) {
        final entry = ifd0Offset + 2 + i * 12;
        if (entry + 12 > bytes.length) return 1;
        if (read16(entry) == 0x0112) return read16(entry + 8);
      }
      return 1;
    }

    if (marker == 0xDA) return 1;
    offset += 2 + ((bytes[offset + 2] << 8) | bytes[offset + 3]);
  }
  return 1;
}
