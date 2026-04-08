import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:miro_hybrid/core/theme/app_tokens.dart';
import 'package:miro_hybrid/l10n/app_localizations.dart';

import '../application/camera_stream_controller.dart';
import '../application/device_angle_sensor.dart';
import '../application/multi_angle_capture_controller.dart';
import '../domain/models/angle_zone.dart';
import '../domain/models/ar_scan_detection.dart';
import 'widgets/arscan_bounding_box_overlay.dart';
import 'widgets/camera_preview_view.dart';
import 'widgets/multi_angle_capture_overlay.dart';

class ARscanScreen extends ConsumerStatefulWidget {
  const ARscanScreen({super.key});

  @override
  ConsumerState<ARscanScreen> createState() => _ARscanScreenState();
}

class _ARscanScreenState extends ConsumerState<ARscanScreen>
    with WidgetsBindingObserver {
  late final ArScanCameraStreamController _streamController;
  late final DeviceAngleSensor _angleSensor;
  late final MultiAngleCaptureController _captureController;
  bool _isInitialized = false;
  bool _isPopping = false;
  bool _isDisposing = false;
  VoidCallback? _completeListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _streamController = ArScanCameraStreamController();
    _angleSensor = DeviceAngleSensor();
    _captureController = MultiAngleCaptureController(
      cameraStreamController: _streamController,
      deviceAngleSensor: _angleSensor,
    );
    _completeListener = _onCaptureComplete;
    _captureController.isComplete.addListener(_completeListener!);
    _initializeCamera();
  }

  void _onCaptureComplete() {
    if (!_captureController.isComplete.value) return;
    if (_isPopping) return;
    _isPopping = true;

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      final sorted = List<AngleCaptureResult>.from(
        _captureController.capturedImages,
      )..sort((a, b) {
          const order = [AngleZone.top, AngleZone.diagonal, AngleZone.side];
          return order.indexOf(a.zone).compareTo(order.indexOf(b.zone));
        });
      final imagePaths = sorted.map((r) => r.imagePath).toList();
      Navigator.of(context).pop(imagePaths);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isDisposing) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
      _streamController.stopStream().catchError((_) {});
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    if (_isDisposing) return;

    try {
      await _streamController.initialize();

      if (!mounted || _isDisposing) return;

      if (!_streamController.isInitialized) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.of(context)!.cameraFailedToInitialize),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.of(context).maybePop();
        return;
      }

      setState(() {
        _isInitialized = true;
      });

      await _streamController.startStream();
    } catch (_) {
      if (!mounted || _isDisposing) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10n.of(context)!.cameraFailedToInitialize),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).maybePop();
    }
  }

  @override
  void dispose() {
    _isDisposing = true;
    _isInitialized = false;

    if (_completeListener != null) {
      _captureController.isComplete.removeListener(_completeListener!);
    }
    WidgetsBinding.instance.removeObserver(this);

    _disposeAsync();
    super.dispose();
  }

  Future<void> _disposeAsync() async {
    try {
      await _captureController.dispose();
    } catch (e) {
      debugPrint('[ARscanScreen] captureController.dispose error: $e');
    }
    try {
      await _angleSensor.dispose();
    } catch (e) {
      debugPrint('[ARscanScreen] angleSensor.dispose error: $e');
    }
    try {
      await _streamController.dispose();
    } catch (e) {
      debugPrint('[ARscanScreen] streamController.dispose error: $e');
    }
  }

  void _onScreenTap() {
    if (!_captureController.isStarted.value) return;
    if (!_captureController.canCapture.value) return;
    if (_captureController.isCapturing.value) return;
    if (_captureController.isComplete.value) return;

    _captureController.captureManual();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.black,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _onScreenTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CameraPreviewView(
                isInitialized: _isInitialized,
                controller: _streamController.cameraController,
              ),
              _buildTopBar(),
              ValueListenableBuilder<ArScanState>(
                valueListenable: _streamController.detectionState,
                builder: (_, state, __) {
                  return ValueListenableBuilder<ArScanDetection?>(
                    valueListenable: _streamController.primaryDetection,
                    builder: (_, detection, __) => ArScanBoundingBoxOverlay(
                      primaryDetection: detection,
                      state: state,
                      previewSize:
                          _streamController.cameraController?.value.previewSize,
                    ),
                  );
                },
              ),
              MultiAngleCaptureOverlay(
                controller: _captureController,
                streamController: _streamController,
              ),
              if (isLandscape) _buildLandscapeWarning(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLandscapeWarning() {
    final l10n = L10n.of(context)!;
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.85),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.screen_rotation_rounded,
                color: Colors.white,
                size: 64,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.arScanPortraitOnlyTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.arScanPortraitOnlyMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final l10n = L10n.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 26),
              onPressed: () => Navigator.of(context).maybePop(),
              tooltip: l10n.cancel,
            ),
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xs + 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: AppRadius.xl,
                  ),
                  child: Text(
                    l10n.cameraTakePhotoOfFood,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            ValueListenableBuilder<FlashMode>(
              valueListenable: _streamController.flashMode,
              builder: (_, mode, __) {
                final isOn = mode == FlashMode.torch;
                return IconButton(
                  icon: Icon(
                    isOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                    color: isOn ? const Color(0xFFFBBF24) : Colors.white,
                    size: 26,
                  ),
                  onPressed: () => _streamController.toggleFlash(),
                  tooltip: 'Flash',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
