import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import '../constants/reference_objects_data.dart';
import '../models/calibration_result.dart';
import '../models/reference_object.dart';
import 'reference_detector_service.dart';
import 'scale_calibration_service.dart';

/// Processor สำหรับ real-time camera frame detection
/// จัดการ throttling, debouncing, และ callback
class CameraFrameProcessor {
  /// Callback เมื่อ detect วัตถุอ้างอิงได้
  final ValueChanged<DetectedReferenceObject?>? onReferenceDetected;

  /// Callback เมื่อ calibration พร้อม
  final ValueChanged<CalibrationResult?>? onCalibrationReady;

  /// กำลัง process frame อยู่หรือไม่ (ป้องกันซ้อน)
  bool _isProcessing = false;

  /// Timestamp ของ frame ล่าสุดที่ process
  int _lastProcessedMs = 0;

  /// ผลลัพธ์ล่าสุด
  DetectedReferenceObject? lastDetectedObject;
  CalibrationResult? lastCalibration;

  CameraFrameProcessor({
    this.onReferenceDetected,
    this.onCalibrationReady,
  });

  /// Process camera frame
  /// เรียกจาก CameraController.startImageStream()
  ///
  /// [imageBytes] — raw bytes จาก CameraImage.planes[0].bytes
  /// [width] / [height] — ขนาด frame
  /// [rotation] — camera sensor rotation
  Future<void> processFrame({
    required List<int> imageBytes,
    required int width,
    required int height,
    required int rotation,
    required int rawFormat,
    required int bytesPerRow,
  }) async {
    // Throttle: skip ถ้า process เร็วเกินไป
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_isProcessing ||
        now - _lastProcessedMs < ReferenceObjectsData.frameProcessingIntervalMs) {
      return;
    }

    _isProcessing = true;
    _lastProcessedMs = now;

    try {
      final detected = await ReferenceDetectorService.instance
          .detectFromCameraFrame(
            imageBytes: imageBytes,
            imageSize: Size(width.toDouble(), height.toDouble()),
            rotation: rotation,
            rawFormat: rawFormat,
            bytesPerRow: bytesPerRow,
          );

      lastDetectedObject = detected;
      onReferenceDetected?.call(detected);

      if (detected != null) {
        // สร้าง calibration ทุกครั้งที่ detect ได้
        // ให้ UI แสดง overlay + tier color ตาม confidence level
        final calibration = ScaleCalibrationService.calibrate(
          referenceObject: detected,
          imageWidth: width.toDouble(),
          imageHeight: height.toDouble(),
        );
        lastCalibration = calibration;
        onCalibrationReady?.call(calibration);
      } else {
        if (lastCalibration != null) {
          lastCalibration = null;
          onCalibrationReady?.call(null);
        }
      }
    } catch (e) {
      debugPrint('[CameraFrameProcessor] Error: $e');
    } finally {
      _isProcessing = false;
    }
  }

  /// หยุด processing
  void dispose() {
    _isProcessing = false;
    lastDetectedObject = null;
    lastCalibration = null;
  }
}
