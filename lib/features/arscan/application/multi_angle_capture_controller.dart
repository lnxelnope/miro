import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/models/angle_zone.dart';
import 'camera_stream_controller.dart';
import 'device_angle_sensor.dart';

/// Controller สำหรับจัดการ multi-angle capture flow (manual-only)
///
/// Phase 1 — Positioning: user วางอาหารในกรอบแล้วกด "เริ่ม" (ถ่ายรูปแรก)
/// Phase 2 — Manual capture: user เอียงมือถือไปมุมที่แนะนำแล้วแตะจอเพื่อถ่าย
///           กดได้เฉพาะเมื่ออยู่ในมุมที่ยังไม่ได้ถ่ายเท่านั้น
class MultiAngleCaptureController {
  MultiAngleCaptureController({
    required this.cameraStreamController,
    required this.deviceAngleSensor,
  }) {
    _init();
  }

  final ArScanCameraStreamController cameraStreamController;
  final DeviceAngleSensor deviceAngleSensor;

  bool _isDisposed = false;
  Future<void>? _pendingCapture;

  static const List<AngleZone> allZones = <AngleZone>[
    AngleZone.top,
    AngleZone.diagonal,
    AngleZone.side,
  ];

  VoidCallback? _angleZoneListener;

  final Set<AngleZone> _capturedZones = {};

  /// Phase 1 → Phase 2: user กดเริ่มแล้ว
  final ValueNotifier<bool> isStarted = ValueNotifier<bool>(false);

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

  /// true เมื่อมือถืออยู่ในมุมที่ยังไม่ได้ถ่าย → user กดถ่ายได้
  final ValueNotifier<bool> canCapture = ValueNotifier<bool>(false);

  final List<AngleCaptureResult> capturedImages = <AngleCaptureResult>[];

  void _init() {
    currentDeviceZone.value = deviceAngleSensor.currentZone.value;
    _angleZoneListener = () {
      currentDeviceZone.value = deviceAngleSensor.currentZone.value;
      _updateState();
    };
    deviceAngleSensor.currentZone.addListener(_angleZoneListener!);
  }

  // ─── Phase 1 → Phase 2 transition ───

  /// User กดเริ่ม: ถ่ายรูปแรกจากมุมปัจจุบัน
  Future<void> startCapture() async {
    if (isStarted.value) return;

    await _captureCurrentAngle();

    if (capturedImages.isNotEmpty) {
      isStarted.value = true;
      _updateState();
    }
  }

  // ─── State logic ───

  void _updateState() {
    if (isComplete.value) {
      currentTargetZone.value = null;
      canCapture.value = false;
      return;
    }

    final deviceZone = currentDeviceZone.value;

    // แนะนำมุมถัดไปที่ยังไม่ถ่าย
    if (deviceZone == null ||
        deviceZone == AngleZone.outOfRange ||
        _capturedZones.contains(deviceZone)) {
      currentTargetZone.value = _nextUncapturedZone();
      canCapture.value = false;
    } else {
      currentTargetZone.value = deviceZone;
      canCapture.value = isStarted.value && !isCapturing.value;
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

  // ─── Manual capture: user แตะจอเมื่ออยู่ในมุมถูกต้อง ───

  /// เรียกเมื่อ user แตะจอ — ถ่ายได้เฉพาะเมื่อ canCapture == true
  Future<void> captureManual() async {
    if (!isStarted.value) return;
    if (!canCapture.value) return;
    return _captureCurrentAngle();
  }

  Future<void> _captureCurrentAngle() async {
    if (_isDisposed) return;
    if (isCapturing.value) return;

    final cameraController = cameraStreamController.cameraController;
    if (cameraController == null ||
        !cameraController.value.isInitialized) {
      debugPrint(
        '[MultiAngleCapture] cameraController not ready',
      );
      return;
    }

    isCapturing.value = true;
    canCapture.value = false;

    try {
      // Stop stream before taking picture (required by camera plugin)
      try {
        await cameraStreamController.stopStream();
      } catch (e) {
        debugPrint('[MultiAngleCapture] stopStream error: $e');
      }

      if (_isDisposed) return;

      final angleAtCapture = currentAngle.value;

      AngleZone zone = currentDeviceZone.value ??
          AngleZoneHelper.fromDegrees(angleAtCapture);

      if (zone == AngleZone.outOfRange) {
        zone = _closestZone(angleAtCapture);
      }

      XFile? xfile;
      try {
        xfile = await cameraController.takePicture();
      } catch (e) {
        debugPrint('[MultiAngleCapture] takePicture error: $e');
        // Restart stream even on failure
        if (!_isDisposed) {
          try {
            await cameraStreamController.startStream();
          } catch (_) {}
        }
        return;
      }

      // Wait for native camera callbacks (e.g. unlockAutoFocus on Android)
      await Future.delayed(const Duration(milliseconds: 200));

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

      // Restart stream for next capture
      if (!_isDisposed && !isComplete.value) {
        try {
          await cameraStreamController.startStream();
        } catch (e) {
          debugPrint('[MultiAngleCapture] startStream error: $e');
        }
      }
    } catch (e) {
      debugPrint('[MultiAngleCapture] capture error: $e');
    } finally {
      if (!_isDisposed) {
        isCapturing.value = false;
        _updateState();
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
      canCapture.value = false;
    }
  }

  Future<void> dispose() async {
    _isDisposed = true;

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
    canCapture.dispose();
  }
}
