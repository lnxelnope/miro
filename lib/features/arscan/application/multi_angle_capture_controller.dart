import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/models/angle_zone.dart';
import '../domain/models/ar_scan_detection.dart';
import 'arscan_camera_stream_controller.dart';
import 'device_angle_sensor.dart';

/// Controller สำหรับจัดการ multi-angle capture flow
class MultiAngleCaptureController {
  MultiAngleCaptureController({
    required this.cameraStreamController,
    required this.deviceAngleSensor,
    Duration autoCaptureCheckInterval =
        const Duration(milliseconds: 100),
    Duration requiredStableDuration =
        const Duration(milliseconds: 700),
    Duration detectionLostDuration = const Duration(seconds: 1),
  })  : _autoCaptureCheckInterval = autoCaptureCheckInterval,
        _requiredStableDuration = requiredStableDuration,
        _detectionLostDuration = detectionLostDuration {
    _init();
  }

  final ArScanCameraStreamController cameraStreamController;
  final DeviceAngleSensor deviceAngleSensor;

  final Duration _autoCaptureCheckInterval;
  final Duration _requiredStableDuration;
  final Duration _detectionLostDuration;

  static const List<AngleZone> _captureSequence = <AngleZone>[
    AngleZone.top,
    AngleZone.diagonal,
    AngleZone.side,
  ];

  int _currentTargetIndex = 0;
  Timer? _autoCaptureTimer;
  Timer? _detectionLostTimer;

  VoidCallback? _angleZoneListener;
  VoidCallback? _detectionStateListener;

  /// จำนวนภาพที่ถ่ายแล้ว (0-3)
  final ValueNotifier<int> capturedCount = ValueNotifier<int>(0);

  /// มุมที่ต้องถ่ายต่อไป
  final ValueNotifier<AngleZone?> currentTargetZone =
      ValueNotifier<AngleZone?>(AngleZone.top);

  /// มุมปัจจุบันของอุปกรณ์
  final ValueNotifier<AngleZone?> currentDeviceZone =
      ValueNotifier<AngleZone?>(null);

  /// มุมองศาปัจจุบัน (proxy จาก DeviceAngleSensor)
  late final ValueNotifier<double> currentAngle =
      deviceAngleSensor.currentAngle;

  /// ผล capture ล่าสุด
  final ValueNotifier<AngleCaptureResult?> lastCaptureResult =
      ValueNotifier<AngleCaptureResult?>(null);

  /// กำลัง capture อยู่หรือไม่
  final ValueNotifier<bool> isCapturing =
      ValueNotifier<bool>(false);

  /// สถานะว่าถ่ายครบทั้ง 3 มุมแล้วหรือยัง
  final ValueNotifier<bool> isComplete =
      ValueNotifier<bool>(false);

  /// ผลลัพธ์ทั้งหมดของภาพที่ถ่ายในแต่ละมุม
  final List<AngleCaptureResult> capturedImages = <AngleCaptureResult>[];

  void _init() {
    // sync currentDeviceZone จาก DeviceAngleSensor
    currentDeviceZone.value =
        deviceAngleSensor.currentZone.value;
    _angleZoneListener = () {
      currentDeviceZone.value =
          deviceAngleSensor.currentZone.value;
    };
    deviceAngleSensor.currentZone
        .addListener(_angleZoneListener!);

    // listen detection state เพื่อ handle reset เมื่อกล่องหาย
    _detectionStateListener = _handleDetectionStateChanged;
    cameraStreamController.detectionState
        .addListener(_detectionStateListener!);

    // periodic check สำหรับ auto-capture
    _autoCaptureTimer = Timer.periodic(
      _autoCaptureCheckInterval,
      (_) => _maybeAutoCapture(),
    );
  }

  void _handleDetectionStateChanged() {
    final state = cameraStreamController.detectionState.value;
    if (state == ArScanState.searching) {
      _detectionLostTimer ??=
          Timer(_detectionLostDuration, () {
        _detectionLostTimer = null;
        if (cameraStreamController.detectionState.value ==
            ArScanState.searching) {
          _resetProgress();
        }
      });
    } else {
      _detectionLostTimer?.cancel();
      _detectionLostTimer = null;
    }
  }

  void _maybeAutoCapture() {
    if (isCapturing.value) return;
    if (capturedCount.value >= _captureSequence.length) {
      return;
    }

    if (cameraStreamController.detectionState.value !=
        ArScanState.readyForCapture) {
      return;
    }

    final targetZone = currentTargetZone.value;
    if (targetZone == null) return;

    final isStable = deviceAngleSensor.isStableInZone(
      targetZone,
      _requiredStableDuration,
    );
    if (!isStable) return;

    unawaited(_captureCurrentAngle(isAuto: true));
  }

  /// เรียกจาก UI เมื่อต้องการ manual capture
  Future<void> captureManual() {
    return _captureCurrentAngle(isAuto: false);
  }

  Future<void> _captureCurrentAngle({
    required bool isAuto,
  }) async {
    if (isCapturing.value) return;
    if (capturedCount.value >= _captureSequence.length &&
        isAuto) {
      return;
    }

    final cameraController =
        cameraStreamController.cameraController;
    if (cameraController == null ||
        !cameraController.value.isInitialized) {
      debugPrint(
        '[MultiAngleCaptureController] cameraController not ready',
      );
      return;
    }

    isCapturing.value = true;

    try {
      // CRITICAL: stop stream → takePicture → restart stream
      await cameraStreamController.stopStream();

      final angleAtCapture = currentAngle.value;

      AngleZone zone;
      if (isAuto) {
        zone = currentTargetZone.value ??
            AngleZoneHelper.fromDegrees(angleAtCapture);
      } else {
        zone = currentDeviceZone.value ??
            AngleZoneHelper.fromDegrees(angleAtCapture);
      }

      final XFile xfile =
          await cameraController.takePicture();

      final tempDir = await getTemporaryDirectory();
      final timestamp =
          DateTime.now().millisecondsSinceEpoch;
      final fileName =
          'arscan_${timestamp}_${zone.name}.jpg';
      final savePath = '${tempDir.path}/$fileName';

      await xfile.saveTo(savePath);

      final result = AngleCaptureResult(
        zone: zone,
        imagePath: savePath,
        capturedAt: DateTime.now(),
        actualAngle: angleAtCapture,
      );

      _upsertCaptureResult(result, isAuto: isAuto);

      // กลับมาเริ่ม stream ต่อ
      await cameraStreamController.startStream();
    } catch (e) {
      debugPrint(
        '[MultiAngleCaptureController] capture error: $e',
      );
    } finally {
      isCapturing.value = false;
    }
  }

  void _upsertCaptureResult(
    AngleCaptureResult result, {
    required bool isAuto,
  }) {
    final index = capturedImages
        .indexWhere((r) => r.zone == result.zone);

    if (index >= 0) {
      // manual/auto overwrite ถ้ามุมซ้ำ
      capturedImages[index] = result;
    } else {
      capturedImages.add(result);
      capturedCount.value = capturedImages.length;
    }

    lastCaptureResult.value = result;

    if (capturedImages.length >= _captureSequence.length) {
      isComplete.value = true;
      currentTargetZone.value = null;
    } else {
      _advanceTargetZone();
    }
  }

  void _advanceTargetZone() {
    _currentTargetIndex =
        capturedImages.length.clamp(0, _captureSequence.length - 1);
    if (_currentTargetIndex >= _captureSequence.length) {
      currentTargetZone.value = null;
      return;
    }
    currentTargetZone.value =
        _captureSequence[_currentTargetIndex];
  }

  void _resetProgress() {
    // ลบไฟล์รูปเก่าทั้งหมด (best-effort)
    for (final result in capturedImages) {
      try {
        final file = File(result.imagePath);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (_) {
        // ignore IO errors ใน reset
      }
    }

    capturedImages.clear();
    capturedCount.value = 0;
    lastCaptureResult.value = null;
    isComplete.value = false;
    _currentTargetIndex = 0;
    currentTargetZone.value = _captureSequence.first;
  }

  Future<void> dispose() async {
    _autoCaptureTimer?.cancel();
    _detectionLostTimer?.cancel();

    if (_angleZoneListener != null) {
      deviceAngleSensor.currentZone
          .removeListener(_angleZoneListener!);
      _angleZoneListener = null;
    }

    if (_detectionStateListener != null) {
      cameraStreamController.detectionState
          .removeListener(_detectionStateListener!);
      _detectionStateListener = null;
    }

    capturedCount.dispose();
    currentTargetZone.dispose();
    currentDeviceZone.dispose();
    lastCaptureResult.dispose();
    isCapturing.dispose();
    isComplete.dispose();
  }
}

