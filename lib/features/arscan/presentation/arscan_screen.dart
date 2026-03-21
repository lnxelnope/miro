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
  final ArScanCameraStreamController _streamController =
      ArScanCameraStreamController();
  late final DeviceAngleSensor _angleSensor;
  late final MultiAngleCaptureController _captureController;
  bool _isInitialized = false;
  bool _isPopping = false;
  VoidCallback? _completeListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    try {
      await _streamController.initialize();

      if (!mounted) return;

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
      if (!mounted) return;
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
    if (_completeListener != null) {
      _captureController.isComplete.removeListener(_completeListener!);
    }
    WidgetsBinding.instance.removeObserver(this);
    _isInitialized = false;

    // ต้อง dispose captureController ก่อน (รอ pending capture เสร็จ)
    // แล้วค่อย dispose streamController (dispose camera)
    // ป้องกัน Camera2 unlockAutoFocus NPE crash
    _disposeAsync();
    super.dispose();
  }

  Future<void> _disposeAsync() async {
    try {
      await _captureController.dispose();
    } catch (_) {}
    _angleSensor.dispose();
    try {
      await _streamController.dispose();
    } catch (_) {}
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
