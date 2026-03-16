import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

import '../../../core/utils/logger.dart';
import '../domain/models/ar_scan_detection.dart';

/// Service สำหรับเชื่อม CameraImage → ML Kit ObjectDetector → ArScanDetection
class ArScanDetectionService {
  ArScanDetectionService({
    Duration throttleInterval = const Duration(milliseconds: 250),
    double foodConfidenceThreshold = 0.6,
  })  : _throttleInterval = throttleInterval,
        _foodConfidenceThreshold = foodConfidenceThreshold {
    _initDetector();
  }

  static const Set<String> _foodLabels = {
    'Food',
    'Meal',
    'Dish',
    'Snack',
    'Dessert',
    'Fruit',
    'Vegetable',
    'Baked goods',
    'Dairy',
    'Seafood',
    'Fast food',
    'Salad',
  };

  static bool _isFood(String label) {
    final lower = label.toLowerCase();
    for (final value in _foodLabels) {
      if (value.toLowerCase() == lower) {
        return true;
      }
    }
    return false;
  }

  final Duration _throttleInterval;
  final double _foodConfidenceThreshold;

  ObjectDetector? _objectDetector;
  DateTime? _lastDetectionTime;
  List<ArScanDetection> _lastDetections = const [];

  Future<void> _initDetector() async {
    if (Platform.isWindows) {
      debugPrint('[ArScanDetectionService] ML Kit not supported on Windows');
      return;
    }

    try {
      final options = ObjectDetectorOptions(
        mode: DetectionMode.stream,
        classifyObjects: true,
        multipleObjects: true,
      );
      _objectDetector = ObjectDetector(options: options);
      debugPrint('[ArScanDetectionService] ObjectDetector initialized (stream)');
    } catch (e) {
      AppLogger.error(
        '[ArScanDetectionService] Failed to initialize ObjectDetector',
        e,
      );
    }
  }

  bool get isReady => _objectDetector != null;

  /// ตรวจจับวัตถุจาก CameraImage แล้วแปลงเป็น List<ArScanDetection>
  ///
  /// - ใช้ throttle ไม่ให้เรียก ML Kit ถี่เกินไป (ค่า default ~250ms)
  /// - คืน list ว่างถ้าไม่มี food ตาม threshold
  Future<List<ArScanDetection>> detectFrame(
    CameraImage image,
    InputImageRotation rotation,
  ) async {
    if (Platform.isWindows) {
      return const [];
    }

    final now = DateTime.now();
    if (_lastDetectionTime != null &&
        now.difference(_lastDetectionTime!) < _throttleInterval) {
      // ใช้ผลลัพธ์เดิมตาม throttle
      return _lastDetections;
    }

    if (_objectDetector == null) {
      await _initDetector();
      if (_objectDetector == null) {
        return const [];
      }
    }

    try {
      final inputImage = _buildInputImage(image, rotation);
      final rawObjects = await _objectDetector!.processImage(inputImage);

      if (rawObjects.isEmpty) {
        _lastDetectionTime = now;
        _lastDetections = const [];
        return const [];
      }

      final imageWidth = image.width.toDouble();
      final imageHeight = image.height.toDouble();

      final detections = <ArScanDetection>[];
      for (final obj in rawObjects) {
        final rect = obj.boundingBox;
        final labelText =
            obj.labels.isNotEmpty ? obj.labels.first.text : 'Object';
        final confidence =
            obj.labels.isNotEmpty ? obj.labels.first.confidence : 0.0;

        final normalizedRect = Rect.fromLTWH(
          (rect.left / imageWidth).clamp(0.0, 1.0),
          (rect.top / imageHeight).clamp(0.0, 1.0),
          (rect.width / imageWidth).clamp(0.0, 1.0),
          (rect.height / imageHeight).clamp(0.0, 1.0),
        );

        final isFood = _isFood(labelText);

        detections.add(
          ArScanDetection(
            trackingId: obj.trackingId,
            label: labelText,
            confidence: confidence,
            normalizedRect: normalizedRect,
            isFood: isFood,
            isPrimary: false,
            lastSeenAt: now,
            stableFrameCount: 1,
          ),
        );
      }

      final withPrimary = _markPrimary(detections);

      _lastDetectionTime = now;
      _lastDetections = withPrimary;

      // ถ้าไม่มี food ที่ผ่าน threshold ให้คืน list ว่าง
      final hasFoodAboveThreshold = withPrimary.any(
        (d) => d.isFood && d.confidence >= _foodConfidenceThreshold,
      );
      if (!hasFoodAboveThreshold) {
        return const [];
      }

      return withPrimary;
    } catch (e, stack) {
      AppLogger.error(
        '[ArScanDetectionService] detectFrame error',
        e,
        stack,
      );
      return const [];
    }
  }

  List<ArScanDetection> _markPrimary(List<ArScanDetection> detections) {
    if (detections.isEmpty) return detections;

    ArScanDetection? bestFood;
    for (final d in detections) {
      if (!d.isFood) continue;
      if (d.confidence < _foodConfidenceThreshold) continue;
      if (bestFood == null || d.confidence > bestFood.confidence) {
        bestFood = d;
      }
    }

    if (bestFood == null) {
      return detections;
    }

    return detections
        .map(
          (d) => d.copyWith(isPrimary: identical(d, bestFood)),
        )
        .toList(growable: false);
  }

  InputImage _buildInputImage(
    CameraImage image,
    InputImageRotation rotation,
  ) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final imageSize = Size(
      image.width.toDouble(),
      image.height.toDouble(),
    );

    final format = InputImageFormat.values.firstWhere(
      (f) => f.rawValue == image.format.raw,
      orElse: () => Platform.isAndroid
          ? InputImageFormat.nv21
          : InputImageFormat.bgra8888,
    );

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: imageSize,
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.isNotEmpty ? image.planes.first.bytesPerRow : 0,
      ),
    );
  }

  Future<void> dispose() async {
    await _objectDetector?.close();
    _objectDetector = null;
  }
}

