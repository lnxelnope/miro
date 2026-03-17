import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/models/angle_zone.dart';
import 'camera_stream_controller.dart';
import 'device_angle_sensor.dart';

/// Controller สำหรับจัดการ multi-angle capture flow
///
/// 2-phase approach:
///   Phase 1 — Positioning: user วางอาหารในกรอบแล้วกด "เริ่ม"
///   Phase 2 — Auto-capture: ใช้ gyro อย่างเดียว (ไม่พึ่ง ML Kit) ถ่ายอัตโนมัติเมื่อนิ่งในโซนใหม่
class MultiAngleCaptureController {
  MultiAngleCaptureController({
    required this.cameraStreamController,
    required this.deviceAngleSensor,
    Duration autoCaptureCheckInterval = const Duration(milliseconds: 100),
    Duration requiredStableDuration = const Duration(milliseconds: 700),
  })  : _autoCaptureCheckInterval = autoCaptureCheckInterval,
        _requiredStableDuration = requiredStableDuration {
    _init();
  }

  final ArScanCameraStreamController cameraStreamController;
  final DeviceAngleSensor deviceAngleSensor;

  final Duration _autoCaptureCheckInterval;
  final Duration _requiredStableDuration;

  bool _isDisposed = false;
  Future<void>? _pendingCapture;

  static const List<AngleZone> allZones = <AngleZone>[
    AngleZone.top,
    AngleZone.diagonal,
    AngleZone.side,
  ];

  Timer? _autoCaptureTimer;
  VoidCallback? _angleZoneListener;

  final Set<AngleZone> _capturedZones = {};

  /// Phase 1 → Phase 2: user กดเริ่มแล้ว
  final ValueNotifier<bool> isStarted = ValueNotifier<bool>(false);

  /// มุมองศาตอน user กดเริ่ม (baseline สำหรับ gyro calibration)
  double? baselineAngle;

  final ValueNotifier<int> capturedCount = ValueNotifier<int>(0);

  /// มุมที่แนะนำให้ถ่ายต่อไป
  final ValueNotifier<AngleZone?> currentTargetZone =
      ValueNotifier<AngleZone?>(null);

  final ValueNotifier<AngleZone?> currentDeviceZone =
      ValueNotifier<AngleZone?>(null);

  late final ValueNotifier<double> currentAngle =
      deviceAngleSensor.currentAngle;

  final ValueNotifier<AngleCaptureResult?> lastCaptureResult =
      ValueNotifier<AngleCaptureResult?>(null);

  final ValueNotifier<bool> isCapturing = ValueNotifier<bool>(false);

  final ValueNotifier<bool> isComplete = ValueNotifier<bool>(false);

  final List<AngleCaptureResult> capturedImages = <AngleCaptureResult>[];

  void _init() {
    currentDeviceZone.value = deviceAngleSensor.currentZone.value;
    _angleZoneListener = () {
      currentDeviceZone.value = deviceAngleSensor.currentZone.value;
      if (isStarted.value) {
        _updateTargetFromDeviceZone();
      }
    };
    deviceAngleSensor.currentZone.addListener(_angleZoneListener!);

    _autoCaptureTimer = Timer.periodic(
      _autoCaptureCheckInterval,
      (_) => _maybeAutoCapture(),
    );
  }

  // ─── Phase 1 → Phase 2 transition ───

  /// User กดเริ่ม: ถ่ายรูปแรก + เปิด auto-capture
  Future<void> startCapture() async {
    if (isStarted.value) return;

    baselineAngle = currentAngle.value;

    await _captureCurrentAngle(isAuto: false);

    if (capturedImages.isNotEmpty) {
      isStarted.value = true;
      _updateTargetFromDeviceZone();
    }
  }

  // ─── Target zone logic ───

  void _updateTargetFromDeviceZone() {
    if (isComplete.value) {
      currentTargetZone.value = null;
      return;
    }

    final deviceZone = currentDeviceZone.value;
    if (deviceZone == null || deviceZone == AngleZone.outOfRange) {
      currentTargetZone.value = _nextUncapturedZone();
      return;
    }

    if (_capturedZones.contains(deviceZone)) {
      currentTargetZone.value = _nextUncapturedZone();
    } else {
      currentTargetZone.value = deviceZone;
    }
  }

  AngleZone? _nextUncapturedZone() {
    for (final zone in allZones) {
      if (!_capturedZones.contains(zone)) return zone;
    }
    return null;
  }

  bool isZoneCaptured(AngleZone zone) => _capturedZones.contains(zone);

  AngleCaptureResult? getCaptureResultForZone(AngleZone zone) {
    for (final r in capturedImages) {
      if (r.zone == zone) return r;
    }
    return null;
  }

  // ─── Auto-capture (Phase 2): gyro-only, ไม่พึ่ง ML Kit ───

  void _maybeAutoCapture() {
    if (_isDisposed) return;
    if (!isStarted.value) return;
    if (isCapturing.value) return;
    if (isComplete.value) return;

    final deviceZone = currentDeviceZone.value;
    if (deviceZone == null || deviceZone == AngleZone.outOfRange) return;
    if (_capturedZones.contains(deviceZone)) return;

    final isStable = deviceAngleSensor.isStableInZone(
      deviceZone,
      _requiredStableDuration,
    );
    if (!isStable) return;

    final capture = _captureCurrentAngle(isAuto: true);
    _pendingCapture = capture;
    unawaited(capture.whenComplete(() {
      if (_pendingCapture == capture) _pendingCapture = null;
    }));
  }

  /// Manual capture (ใช้ได้หลัง start เท่านั้น)
  Future<void> captureManual() {
    if (!isStarted.value) return Future.value();
    return _captureCurrentAngle(isAuto: false);
  }

  Future<void> _captureCurrentAngle({
    required bool isAuto,
  }) async {
    if (_isDisposed) return;
    if (isCapturing.value) return;
    if (isComplete.value && isAuto) return;

    final cameraController = cameraStreamController.cameraController;
    if (cameraController == null ||
        !cameraController.value.isInitialized) {
      debugPrint(
        '[MultiAngleCaptureController] cameraController not ready',
      );
      return;
    }

    isCapturing.value = true;

    try {
      await cameraStreamController.stopStream();

      if (_isDisposed) return;

      final angleAtCapture = currentAngle.value;

      AngleZone zone = currentDeviceZone.value ??
          AngleZoneHelper.fromDegrees(angleAtCapture);

      if (zone == AngleZone.outOfRange) {
        zone = _closestZone(angleAtCapture);
      }

      final XFile xfile = await cameraController.takePicture();

      // ให้ native callbacks (เช่น unlockAutoFocus) ทำงานเสร็จ
      // ก่อนจะ startStream หรือ dispose camera
      await Future.delayed(const Duration(milliseconds: 150));

      if (_isDisposed) return;

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'arscan_${timestamp}_${zone.name}.jpg';
      final savePath = '${tempDir.path}/$fileName';

      await xfile.saveTo(savePath);

      final result = AngleCaptureResult(
        zone: zone,
        imagePath: savePath,
        capturedAt: DateTime.now(),
        actualAngle: angleAtCapture,
      );

      if (!_isDisposed) {
        _upsertCaptureResult(result);
      }

      if (!_isDisposed) {
        await cameraStreamController.startStream();
      }
    } catch (e) {
      debugPrint(
        '[MultiAngleCaptureController] capture error: $e',
      );
    } finally {
      if (!_isDisposed) {
        isCapturing.value = false;
      }
    }
  }

  AngleZone _closestZone(double angle) {
    if (angle <= 30) return AngleZone.top;
    if (angle >= 60) return AngleZone.side;
    return AngleZone.diagonal;
  }

  void _upsertCaptureResult(AngleCaptureResult result) {
    final index =
        capturedImages.indexWhere((r) => r.zone == result.zone);

    if (index >= 0) {
      capturedImages[index] = result;
    } else {
      capturedImages.add(result);
      _capturedZones.add(result.zone);
      capturedCount.value = capturedImages.length;
    }

    lastCaptureResult.value = result;

    if (_capturedZones.length >= allZones.length) {
      isComplete.value = true;
      currentTargetZone.value = null;
    } else {
      _updateTargetFromDeviceZone();
    }
  }

  Future<void> dispose() async {
    _isDisposed = true;
    _autoCaptureTimer?.cancel();
    _autoCaptureTimer = null;

    // รอ capture ที่กำลังทำงานอยู่ให้เสร็จก่อน dispose
    // ป้องกัน native Camera2 callback crash (unlockAutoFocus NPE)
    final pending = _pendingCapture;
    if (pending != null) {
      try {
        await pending;
      } catch (_) {}
    }

    if (_angleZoneListener != null) {
      deviceAngleSensor.currentZone
          .removeListener(_angleZoneListener!);
      _angleZoneListener = null;
    }

    capturedCount.dispose();
    currentTargetZone.dispose();
    currentDeviceZone.dispose();
    lastCaptureResult.dispose();
    isCapturing.dispose();
    isComplete.dispose();
    isStarted.dispose();
  }
}
