import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

import '../../../core/utils/logger.dart';
import '../domain/models/ar_scan_detection.dart';

/// Service สำหรับเชื่อม CameraImage → ML Kit ObjectDetector → ArScanDetection
///
/// ไม่สร้าง ObjectDetector ใน constructor เพื่อป้องกัน race condition
/// เมื่อ instance เก่ากำลัง close อยู่ — ใช้ lazy init ตอน detectFrame แทน
class ArScanDetectionService {
  ArScanDetectionService({
    Duration throttleInterval = const Duration(milliseconds: 250),
    double foodConfidenceThreshold = 0.6,
  })  : _throttleInterval = throttleInterval,
        _foodConfidenceThreshold = foodConfidenceThreshold;

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
  ObjectDetector? _singleDetector;
  DateTime? _lastDetectionTime;
  List<ArScanDetection> _lastDetections = const [];
  bool _isDisposed = false;
  bool _isInitializing = false;

  Future<void> _initDetector() async {
    if (_isDisposed || _isInitializing) return;
    if (_objectDetector != null) return;
    if (Platform.isWindows) {
      debugPrint('[ArScanDetectionService] ML Kit not supported on Windows');
      return;
    }

    _isInitializing = true;
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
    } finally {
      _isInitializing = false;
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
    if (_isDisposed || Platform.isWindows) {
      return const [];
    }

    final now = DateTime.now();
    if (_lastDetectionTime != null &&
        now.difference(_lastDetectionTime!) < _throttleInterval) {
      return _lastDetections;
    }

    if (_objectDetector == null) {
      await _initDetector();
      if (_objectDetector == null || _isDisposed) {
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

      // Android ML Kit with rotation 90°/270° returns bbox in the ROTATED
      // (portrait) space, so normalize with swapped dimensions.
      // iOS ML Kit returns bbox in the raw image space — no swap needed.
      final bool androidRotated = Platform.isAndroid &&
          (rotation == InputImageRotation.rotation90deg ||
              rotation == InputImageRotation.rotation270deg);
      final double normW = androidRotated ? imageHeight : imageWidth;
      final double normH = androidRotated ? imageWidth : imageHeight;

      if (_lastDetections.isEmpty) {
        debugPrint(
          '[ArScanDetection] image=${imageWidth.toInt()}x${imageHeight.toInt()}, '
          'norm=${normW.toInt()}x${normH.toInt()}, '
          'rotation=$rotation, platform=${Platform.operatingSystem}, '
          'objects=${rawObjects.length}',
        );
      }

      final detections = <ArScanDetection>[];
      for (final obj in rawObjects) {
        final rect = obj.boundingBox;
        final labelText =
            obj.labels.isNotEmpty ? obj.labels.first.text : 'Object';
        final confidence =
            obj.labels.isNotEmpty ? obj.labels.first.confidence : 0.0;

        final normalizedRect = Rect.fromLTWH(
          (rect.left / normW).clamp(0.0, 1.0),
          (rect.top / normH).clamp(0.0, 1.0),
          (rect.width / normW).clamp(0.0, 1.0),
          (rect.height / normH).clamp(0.0, 1.0),
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

    ArScanDetection? best = bestFood;
    if (best == null) {
      double maxArea = 0;
      for (final d in detections) {
        final area = d.normalizedRect.width * d.normalizedRect.height;
        if (area > maxArea) {
          maxArea = area;
          best = d;
        }
      }
    }

    if (best == null) return detections;

    final target = best;
    return detections
        .map(
          (d) => d.copyWith(isPrimary: identical(d, target)),
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

  /// ตรวจจับวัตถุจากไฟล์ภาพนิ่ง (JPEG) — ให้ bounding box ที่นิ่งกว่า streaming
  Future<({Rect? rect, String? label})> detectFromFile(
    String imagePath,
  ) async {
    if (Platform.isWindows) return (rect: null, label: null);

    try {
      if (_singleDetector == null) {
        final options = ObjectDetectorOptions(
          mode: DetectionMode.single,
          classifyObjects: true,
          multipleObjects: true,
        );
        _singleDetector = ObjectDetector(options: options);
      }

      final inputImage = InputImage.fromFilePath(imagePath);
      final rawObjects = await _singleDetector!.processImage(inputImage);

      if (rawObjects.isEmpty) return (rect: null, label: null);

      // prefer food, fallback to largest
      DetectedObject? best;
      DetectedObject? bestFood;
      double maxArea = 0;

      for (final obj in rawObjects) {
        final labelText =
            obj.labels.isNotEmpty ? obj.labels.first.text : 'Object';
        if (_isFood(labelText)) {
          final conf =
              obj.labels.isNotEmpty ? obj.labels.first.confidence : 0.0;
          if (bestFood == null ||
              conf >
                  (bestFood.labels.isNotEmpty
                      ? bestFood.labels.first.confidence
                      : 0.0)) {
            bestFood = obj;
          }
        }
        final area = obj.boundingBox.width * obj.boundingBox.height;
        if (area > maxArea) {
          maxArea = area;
          best = obj;
        }
      }

      final chosen = bestFood ?? best;
      if (chosen == null) return (rect: null, label: null);

      // need image dimensions for normalization
      final imageBytes = await File(imagePath).readAsBytes();
      final codec = await instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      final imgW = frame.image.width.toDouble();
      final imgH = frame.image.height.toDouble();
      frame.image.dispose();

      final r = chosen.boundingBox;
      final normalized = Rect.fromLTWH(
        (r.left / imgW).clamp(0.0, 1.0),
        (r.top / imgH).clamp(0.0, 1.0),
        (r.width / imgW).clamp(0.0, 1.0),
        (r.height / imgH).clamp(0.0, 1.0),
      );

      final label =
          chosen.labels.isNotEmpty ? chosen.labels.first.text : 'Object';

      return (rect: normalized, label: label);
    } catch (e) {
      AppLogger.error(
        '[ArScanDetectionService] detectFromFile error',
        e,
      );
      return (rect: null, label: null);
    }
  }

  Future<void> dispose() async {
    _isDisposed = true;
    try {
      await _objectDetector?.close();
    } catch (e) {
      debugPrint('[ArScanDetectionService] objectDetector.close error: $e');
    }
    _objectDetector = null;
    try {
      await _singleDetector?.close();
    } catch (e) {
      debugPrint('[ArScanDetectionService] singleDetector.close error: $e');
    }
    _singleDetector = null;
  }
}

