import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/logger.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/ai/gemini_service.dart';
import '../../../core/constants/enums.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/health_provider.dart';
import '../providers/my_meal_provider.dart';
import '../widgets/gemini_analysis_sheet.dart';
import '../models/food_entry.dart';
import 'nutrition_label_screen.dart';
import 'image_analysis_preview_screen.dart';

class BarcodeScannerScreen extends ConsumerStatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  ConsumerState<BarcodeScannerScreen> createState() =>
      _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isProcessing = false;
  String? _detectedBarcode;
  bool _hasScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          // Flash toggle
          IconButton(
            icon: const Icon(Icons.flash_off),
            onPressed: () {
              // mobile_scanner 5.x ใช้ start() และ stop() สำหรับ torch
              // หรือใช้ controller.toggleTorch() ถ้ามี
              try {
                _controller.toggleTorch();
              } catch (e) {
                AppLogger.warn('Cannot toggle torch', e);
              }
            },
          ),
          // Switch camera
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () {
              try {
                _controller.switchCamera();
              } catch (e) {
                debugPrint('⚠️ [BarcodeScanner] Cannot switch camera: $e');
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera view
          MobileScanner(
            controller: _controller,
            onDetect: _onBarcodeDetected,
          ),

          // Barcode overlay (scan area guide)
          _buildScanOverlay(),

          // Bottom info
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.9),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_detectedBarcode != null) ...[
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.2),
                        borderRadius: AppRadius.xl,
                        border: Border.all(color: AppColors.success),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle,
                              color: AppColors.success, size: 20),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            'Barcode: $_detectedBarcode',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                  ],
                  if (_isProcessing)
                    const Column(
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: AppSpacing.sm),
                        Text(
                          '📱 READING BARCODE DATA...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    )
                  else ...[
                    const Text(
                      'Point camera at product barcode',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Including the nutrition label improves accuracy',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    SizedBox(height: AppSpacing.lg),
                    // ปุ่มถ่ายฉลากแทน
                    OutlinedButton.icon(
                      onPressed: () => _switchToNutritionLabel(),
                      icon: const Icon(Icons.receipt_long, color: Colors.white),
                      label: const Text('Scan nutrition label instead',
                          style: TextStyle(color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white54),
                        shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.md),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scanAreaSize = constraints.maxWidth * 0.7;
        final left = (constraints.maxWidth - scanAreaSize) / 2;
        final top = (constraints.maxHeight - scanAreaSize) / 2 - 50;

        return Stack(
          children: [
            // Dark overlay with transparent scan area
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.5),
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Positioned(
                    left: left,
                    top: top,
                    child: Container(
                      width: scanAreaSize,
                      height: scanAreaSize,
                      decoration: BoxDecoration(
                        color: AppColors.error, // สีอะไรก็ได้ จะถูก srcOut
                        borderRadius: AppRadius.lg,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Corner markers
            Positioned(
              left: left,
              top: top,
              child: _buildCorner(Alignment.topLeft),
            ),
            Positioned(
              right: left,
              top: top,
              child: _buildCorner(Alignment.topRight),
            ),
            Positioned(
              left: left,
              bottom: constraints.maxHeight - top - scanAreaSize,
              child: _buildCorner(Alignment.bottomLeft),
            ),
            Positioned(
              right: left,
              bottom: constraints.maxHeight - top - scanAreaSize,
              child: _buildCorner(Alignment.bottomRight),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCorner(Alignment alignment) {
    const size = 30.0;
    const thickness = 3.0;
    const color = AppColors.primary;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerPainter(
            alignment: alignment, color: color, thickness: thickness),
      ),
    );
  }

  /// เมื่อตรวจพบ barcode
  void _onBarcodeDetected(BarcodeCapture capture) async {
    if (_isProcessing || _hasScanned) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    setState(() {
      _detectedBarcode = barcode.rawValue;
      _hasScanned = true;
      _isProcessing = true;
    });

    AppLogger.info('Barcode detected: ${barcode.rawValue}');
    AnalyticsService.logBarcodeScan();

    try {
      // จับ frame จากกล้อง
      final capturedImage = capture.image;
      File? imageFile;

      if (capturedImage != null) {
        // ใช้ image จาก capture
        final tempDir = await getTemporaryDirectory();
        final fileName = 'barcode_${DateTime.now().millisecondsSinceEpoch}.jpg';
        imageFile = File('${tempDir.path}/$fileName');
        await imageFile.writeAsBytes(capturedImage);
      } else {
        // fallback: ใช้ image_picker ถ่ายรูปเอง
        if (!context.mounted) return;
        setState(() {
          _isProcessing = false;
          _hasScanned = false;
        });

        _showManualCaptureDialog(barcode.rawValue!);
        return;
      }

      // วิเคราะห์ด้วย Gemini
      final result = await GeminiService.analyzeBarcodedProduct(
        imageFile,
        barcode.rawValue!,
      );

      if (!context.mounted) return;
      setState(() => _isProcessing = false);

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to analyze product'), duration: Duration(seconds: 2)),
        );
        setState(() => _hasScanned = false);
        return;
      }

      // แสดง GeminiAnalysisSheet
      _showAnalysisResult(result, barcode.rawValue!, imageFile.path);
    } catch (e) {
      debugPrint('❌ [BarcodeScanner] Error: $e');
      if (!context.mounted) return;

      // ปิด loading dialog ถ้ายังเปิดอยู่
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      setState(() {
        _isProcessing = false;
        _hasScanned = false;
      });

      // ตรวจสอบว่าเป็น Energy error หรือไม่
      if (e.toString().contains('Insufficient energy')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.of(context)!.notEnoughEnergy),
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), duration: const Duration(seconds: 2)),
        );
      }
    }
  }

  /// แสดง dialog ให้ถ่ายรูปบรรจุภัณฑ์เอง (fallback)
  void _showManualCaptureDialog(String barcodeValue) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Barcode Found!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Barcode: $barcodeValue'),
            const SizedBox(height: 12),
            const Text(
              'Please take a photo of the packaging or nutrition label\n'
              'for AI to analyze product information',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _hasScanned = false);
            },
            child: const Text('Scan Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _captureAndAnalyze(barcodeValue);
            },
            child: const Text('Take Photo'),
          ),
        ],
      ),
    );
  }

  /// ถ่ายรูปบรรจุภัณฑ์แล้ววิเคราะห์
  Future<void> _captureAndAnalyze(String barcodeValue) async {
    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );

      if (photo == null) {
        setState(() => _hasScanned = false);
        return;
      }

      if (!context.mounted) return;
      setState(() {
        _isProcessing = false;
        _hasScanned = false;
      });

      // Navigate to preview screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ImageAnalysisPreviewScreen(
            imageFile: File(photo.path),
            initialFoodName: barcodeValue ?? 'product',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      setState(() {
        _isProcessing = false;
        _hasScanned = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ $e'), duration: const Duration(seconds: 2)),
      );
    }
  }

  /// แสดงผลวิเคราะห์
  void _showAnalysisResult(
      FoodAnalysisResult result, String barcodeValue, String imagePath) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GeminiAnalysisSheet(
        analysisResult: result,
        onConfirm: (confirmedData) async {
          // สร้าง FoodEntry
          final entry = FoodEntry()
            ..foodName = confirmedData.foodName
            ..foodNameEn = confirmedData.foodNameEn
            ..mealType = _guessMealType()
            ..timestamp = DateTime.now()
            ..imagePath = imagePath
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
            ..notes = 'Barcode scan: $barcodeValue';

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
                imagePath: imagePath,
                ingredientsData: confirmedData.ingredientsDetail!,
              );

              // Invalidate MyMeal providers to refresh UI
              ref.invalidate(allMyMealsProvider);
              ref.invalidate(allIngredientsProvider);
            } catch (e) {
              AppLogger.warn('Auto-save ingredient failed', e);
            }
          }

          refreshFoodProviders(ref, DateTime.now());

          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Saved "${confirmedData.foodName}"'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context); // ปิด scanner screen
        },
      ),
    );
  }

  void _switchToNutritionLabel() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const NutritionLabelScreen()),
    );
  }

  MealType _guessMealType() {
    final hour = DateTime.now().hour;
    if (hour < 10) return MealType.breakfast;
    if (hour < 14) return MealType.lunch;
    if (hour < 17) return MealType.snack;
    return MealType.dinner;
  }
}

/// Corner painter สำหรับ scan overlay
class _CornerPainter extends CustomPainter {
  final Alignment alignment;
  final Color color;
  final double thickness;

  _CornerPainter({
    required this.alignment,
    required this.color,
    required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    const length = 20.0;

    if (alignment == Alignment.topLeft) {
      path.moveTo(0, length);
      path.lineTo(0, 0);
      path.lineTo(length, 0);
    } else if (alignment == Alignment.topRight) {
      path.moveTo(size.width - length, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, length);
    } else if (alignment == Alignment.bottomLeft) {
      path.moveTo(0, size.height - length);
      path.lineTo(0, size.height);
      path.lineTo(length, size.height);
    } else if (alignment == Alignment.bottomRight) {
      path.moveTo(size.width - length, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, size.height - length);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
