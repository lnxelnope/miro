import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import '../constants/ar_scale_enums.dart';
import '../constants/reference_objects_data.dart';
import '../models/bounding_box_data.dart';
import '../models/detected_object_label.dart';
import '../models/reference_object.dart';
import 'object_detection_model_manager.dart';

/// Service สำหรับตรวจจับวัตถุอ้างอิงในรูปภาพ
/// ใช้ ML Kit Object Detection + Custom COCO Classifier (EfficientNet-Lite0)
///
/// Pipeline:
///   1. ML Kit's built-in SSD model → ตรวจจับ objects (bounding boxes)
///   2. Custom classifier model → จำแนกว่า object คืออะไร (fork, spoon, knife, ...)
///   3. ถ้า custom model ใช้ไม่ได้ → fallback เป็น base model + heuristics
class ReferenceDetectorService {
  static ReferenceDetectorService? _instance;
  static ReferenceDetectorService get instance =>
      _instance ??= ReferenceDetectorService._();
  ReferenceDetectorService._();

  ObjectDetector? _objectDetector;
  bool _isInitialized = false;
  bool _isCustomModel = false;

  /// Custom classifier model ยังไม่มีที่เหมาะ — ใช้ base model + heuristics
  /// ตั้ง true ไว้ก่อนจนกว่าจะมี model ที่ train สำหรับ cutlery โดยเฉพาะ
  bool _customModelPermanentlyFailed = true;

  /// เตรียม ML Kit Object Detector (single image mode)
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (Platform.isWindows) {
      debugPrint('[ReferenceDetectorService] ML Kit not supported on Windows');
      _isInitialized = true;
      return;
    }

    await _createDetector(DetectionMode.single);
    _isInitialized = true;
  }

  /// เตรียม ML Kit Object Detector สำหรับ camera stream
  Future<void> initializeForStream() async {
    if (Platform.isWindows) return;

    _objectDetector?.close();
    _isInitialized = false;

    await _createDetector(DetectionMode.stream);
    _isInitialized = true;
  }

  /// สร้าง detector — ลอง custom model ก่อน, fallback เป็น base model
  Future<void> _createDetector(DetectionMode mode) async {
    if (!_customModelPermanentlyFailed) {
      try {
        final modelPath = await ObjectDetectionModelManager.getModelPath();
        if (modelPath != null) {
          final options = LocalObjectDetectorOptions(
            mode: mode,
            modelPath: modelPath,
            classifyObjects: true,
            multipleObjects: true,
            confidenceThreshold: 0.3,
          );
          _objectDetector = ObjectDetector(options: options);
          _isCustomModel = true;
          debugPrint(
            '[ReferenceDetectorService] Created with custom classifier model (${mode.name})',
          );
          return;
        }
      } catch (e) {
        debugPrint(
          '[ReferenceDetectorService] Custom model create failed: $e',
        );
      }
    }

    _initBaseModel(mode);
  }

  void _initBaseModel(DetectionMode mode) {
    final options = ObjectDetectorOptions(
      mode: mode,
      classifyObjects: true,
      multipleObjects: true,
    );
    _objectDetector = ObjectDetector(options: options);
    _isCustomModel = false;
    debugPrint(
      '[ReferenceDetectorService] Using base model (${mode.name})',
    );
  }

  /// ตรวจจับวัตถุอ้างอิงจากไฟล์รูป
  Future<List<DetectedReferenceObject>> detectFromImage(File imageFile) async {
    if (!_isInitialized) await initialize();
    if (_objectDetector == null) return [];

    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      return await _processAndMatch(inputImage);
    } catch (e) {
      // Runtime error → ลอง fallback
      if (await _tryFallbackOnError(e)) {
        try {
          final inputImage = InputImage.fromFilePath(imageFile.path);
          return await _processAndMatch(inputImage);
        } catch (_) {}
      }
      debugPrint('[ReferenceDetectorService] detectFromImage error: $e');
      return [];
    }
  }

  /// ตรวจจับ object ทั้งหมดในรูป — ไม่ filter, ไม่มี threshold
  /// ใช้สำหรับ overlay label แบบง่ายบนรูปอาหาร
  Future<List<DetectedObjectLabel>> detectAllObjectLabels(File imageFile) async {
    if (!_isInitialized) await initialize();
    if (_objectDetector == null) return [];

    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final detectedObjects = await _objectDetector!.processImage(inputImage);

      debugPrint(
        '[ReferenceDetectorService] detectAllObjectLabels: ${detectedObjects.length} raw objects',
      );

      final labels = <DetectedObjectLabel>[];

      for (final obj in detectedObjects) {
        final bbox = obj.boundingBox;
        final cx = bbox.center.dx;
        final cy = bbox.center.dy;

        String label;
        double conf;

        if (obj.labels.isNotEmpty) {
          final best = obj.labels.first;
          conf = best.confidence;
          label = _humanReadableLabel(best.text, bbox);
        } else {
          final shapeType = _classifyByShapeStrict(bbox);
          label = shapeType?.displayName ?? 'Object';
          conf = 0.5;
        }

        debugPrint(
          '  → "$label" conf=${conf.toStringAsFixed(2)} '
          'at (${cx.toInt()}, ${cy.toInt()}) '
          'size=${bbox.width.toInt()}x${bbox.height.toInt()}px',
        );

        labels.add(DetectedObjectLabel(
          label: label,
          confidence: conf,
          bboxWidth: bbox.width,
          bboxHeight: bbox.height,
          centerX: cx,
          centerY: cy,
        ));
      }

      return labels;
    } catch (e) {
      if (await _tryFallbackOnError(e)) {
        return detectAllObjectLabels(imageFile);
      }
      debugPrint('[ReferenceDetectorService] detectAllObjectLabels error: $e');
      return [];
    }
  }

  /// แปลง ML Kit label → ชื่อที่อ่านง่าย
  /// Generic labels เช่น "Home good", "Food" จะถูกแปลงด้วย shape heuristic
  String _humanReadableLabel(String rawLabel, Rect bbox) {
    final lower = rawLabel.toLowerCase();

    // Specific labels — ใช้ตรง
    if (lower.contains('fork')) return 'Fork';
    if (lower.contains('spoon') || lower == 'ladle' || lower == 'spatula') {
      return 'Spoon';
    }
    if (lower.contains('knife') || lower == 'cleaver') return 'Knife';
    if (lower.contains('chopstick')) return 'Chopsticks';
    if (lower.contains('phone') || lower.contains('mobile') || lower.contains('cellular')) {
      return 'Phone';
    }
    if (lower.contains('credit') || lower == 'card') return 'Card';
    if (lower.contains('coin') || lower.contains('money')) return 'Coin';
    if (lower.contains('cup') || lower.contains('mug')) return 'Cup';
    if (lower.contains('bottle')) return 'Bottle';
    if (lower.contains('bowl')) return 'Bowl';
    if (lower.contains('plate') || lower.contains('dish')) return 'Plate';
    if (lower.contains('glass')) return 'Glass';
    if (lower == 'person' || lower == 'hand') return 'Hand';

    // Generic labels → ลอง shape heuristic
    if (lower == 'home good' || lower == 'food' || lower == 'fashion good') {
      final shapeType = _classifyByShapeStrict(bbox);
      if (shapeType != null) return shapeType.displayName;
      // Fallback: ใช้ raw label ที่ capitalize แล้ว
      return rawLabel;
    }

    // Unknown — capitalize raw label
    if (rawLabel.isNotEmpty) {
      return rawLabel[0].toUpperCase() + rawLabel.substring(1);
    }
    return 'Object';
  }

  /// ตรวจจับวัตถุอ้างอิงจาก camera frame (Real-time)
  Future<DetectedReferenceObject?> detectFromCameraFrame({
    required List<int> imageBytes,
    required Size imageSize,
    required int rotation,
    required int rawFormat,
    required int bytesPerRow,
  }) async {
    if (!_isInitialized) await initialize();
    if (_objectDetector == null) return null;

    try {
      final inputImage = _buildCameraInputImage(
        imageBytes: imageBytes,
        imageSize: imageSize,
        rotation: rotation,
        rawFormat: rawFormat,
        bytesPerRow: bytesPerRow,
      );

      final results = await _processAndMatch(inputImage);
      return results.isNotEmpty ? results.first : null;
    } catch (e) {
      // Runtime error → fallback แบบ permanent
      if (await _tryFallbackOnError(e)) {
        try {
          final inputImage = _buildCameraInputImage(
            imageBytes: imageBytes,
            imageSize: imageSize,
            rotation: rotation,
            rawFormat: rawFormat,
            bytesPerRow: bytesPerRow,
          );
          final results = await _processAndMatch(inputImage);
          return results.isNotEmpty ? results.first : null;
        } catch (_) {}
      }
      debugPrint('[ReferenceDetectorService] detectFromCameraFrame error: $e');
      return null;
    }
  }

  /// ตรวจจับจาน/ชามในรูป
  Future<DetectedReferenceObject?> detectPlate(File imageFile) async {
    if (!_isInitialized) await initialize();
    if (_objectDetector == null) return null;

    try {
      final inputImage = InputImage.fromFilePath(imageFile.path);
      final detectedObjects = await _objectDetector!.processImage(inputImage);

      for (final obj in detectedObjects) {
        for (final label in obj.labels) {
          final labelLower = label.text.toLowerCase();
          final isPlate = _isPlateLabel(labelLower);
          if (isPlate && label.confidence >= 0.4) {
            final bbox = _rectToBoundingBox(obj.boundingBox);
            return DetectedReferenceObject(
              type: ReferenceObjectType.diningFork,
              boundingBox: bbox,
              confidence: label.confidence,
              knownLengthCm: 0,
              knownWidthCm: 0,
            );
          }
        }
      }
      return null;
    } catch (e) {
      if (await _tryFallbackOnError(e)) {
        return detectPlate(imageFile);
      }
      debugPrint('[ReferenceDetectorService] detectPlate error: $e');
      return null;
    }
  }

  void dispose() {
    _objectDetector?.close();
    _objectDetector = null;
    _isInitialized = false;
    _isCustomModel = false;
    _customModelPermanentlyFailed = false;
    _instance = null;
  }

  // ── Core processing ────────────────────────────────────────────────────────

  /// Process image → match → sort by confidence
  Future<List<DetectedReferenceObject>> _processAndMatch(
    InputImage inputImage,
  ) async {
    final detectedObjects = await _objectDetector!.processImage(inputImage);

    debugPrint(
      '[ReferenceDetectorService] Raw detections: ${detectedObjects.length} '
      '(custom=$_isCustomModel)',
    );
    for (final obj in detectedObjects) {
      for (final label in obj.labels) {
        debugPrint(
          '  → "${label.text}" conf=${label.confidence.toStringAsFixed(2)}',
        );
      }
    }

    final results = <DetectedReferenceObject>[];
    for (final obj in detectedObjects) {
      final matched = _matchToReferenceType(obj);
      if (matched != null) results.add(matched);
    }

    results.sort((a, b) => b.confidence.compareTo(a.confidence));
    debugPrint(
      '[ReferenceDetectorService] Matched ${results.length} reference objects',
    );
    return results;
  }

  /// Runtime fallback: ถ้า custom model error → switch เป็น base model ถาวร
  Future<bool> _tryFallbackOnError(Object error) async {
    if (!_isCustomModel) return false;

    final errorStr = error.toString();
    final isModelError = errorStr.contains('Failed to initialize detector') ||
        errorStr.contains('MlKitException') ||
        errorStr.contains('Unexpected number of dimensions');

    if (isModelError) {
      debugPrint(
        '[ReferenceDetectorService] Custom model incompatible → switching to base model permanently',
      );
      _customModelPermanentlyFailed = true;
      _objectDetector?.close();

      final mode = _isInitialized ? DetectionMode.stream : DetectionMode.single;
      _initBaseModel(mode);
      return true;
    }
    return false;
  }

  InputImage _buildCameraInputImage({
    required List<int> imageBytes,
    required Size imageSize,
    required int rotation,
    required int rawFormat,
    required int bytesPerRow,
  }) {
    final inputImageRotation = _rotationFromDegrees(rotation);

    final format = InputImageFormat.values.firstWhere(
      (f) => f.rawValue == rawFormat,
      orElse: () => Platform.isAndroid
          ? InputImageFormat.nv21
          : InputImageFormat.bgra8888,
    );

    return InputImage.fromBytes(
      bytes: Uint8List.fromList(imageBytes),
      metadata: InputImageMetadata(
        size: imageSize,
        rotation: inputImageRotation,
        format: format,
        bytesPerRow: bytesPerRow,
      ),
    );
  }

  // ── Label matching ─────────────────────────────────────────────────────────

  /// Map ML Kit DetectedObject → DetectedReferenceObject
  ///
  /// Strategy (3 layers):
  ///   1. Label match — ถ้า label ตรง (fork, spoon, Home good) → ใช้เลย
  ///   2. Shape fallback — ถ้า label ไม่ตรง (Food, Fashion good, etc.)
  ///      แต่ bounding box มี shape ยาวเรียวคล้ายช้อนส้อม → classify จาก shape
  ///   3. No labels — ถ้า ML Kit detect object แต่ไม่ให้ label → classify จาก shape
  DetectedReferenceObject? _matchToReferenceType(DetectedObject obj) {
    final bbox = obj.boundingBox;
    final bboxData = _rectToBoundingBox(bbox);

    // ── Layer 1: Label-based matching ──
    for (final label in obj.labels) {
      if (label.confidence < 0.3) continue;

      final labelLower = label.text.toLowerCase();
      final matchedType = _labelToReferenceType(labelLower, bbox);

      if (matchedType != null) {
        return _buildDetected(
          matchedType.$1,
          bboxData,
          label.confidence * matchedType.$2,
        );
      }
    }

    // ── Layer 2: Shape-only fallback for unmatched objects ──
    // ช้อนส้อมมี shape ยาวเรียว (aspect > 3.0) ซึ่งอาหารไม่เป็นแบบนี้
    // ML Kit ตรวจเจอ object แล้ว → confidence สูงกว่า pure guess
    final shapeType = _classifyByShapeStrict(bbox);
    if (shapeType != null) {
      // ML Kit detected + shape match → ใช้ 0.78 base confidence
      // (สูงพอสำหรับ CalibrationTier.medium ≥ 0.65)
      final baseConf = obj.labels.isNotEmpty
          ? math.max(obj.labels.first.confidence, 0.78)
          : 0.78;
      debugPrint(
        '  ↳ Shape fallback: ${shapeType.displayName} '
        '(bbox ${bbox.width.toInt()}x${bbox.height.toInt()}, conf=${baseConf.toStringAsFixed(2)})',
      );
      return _buildDetected(shapeType, bboxData, baseConf);
    }

    return null;
  }

  /// Returns (ReferenceObjectType, confidenceMultiplier) or null
  (ReferenceObjectType, double)? _labelToReferenceType(
    String labelLower,
    Rect bbox,
  ) {
    // ── Fork ──
    if (labelLower == 'fork' || labelLower.contains('fork')) {
      return (ReferenceObjectType.diningFork, 1.0);
    }

    // ── Spoon ──
    if (labelLower == 'spoon' ||
        labelLower == 'ladle' ||
        labelLower == 'spatula' ||
        labelLower.contains('spoon')) {
      return (ReferenceObjectType.tablespoon, 1.0);
    }

    // ── Knife ──
    if (labelLower == 'knife' ||
        labelLower == 'cleaver' ||
        labelLower == 'letter opener' ||
        labelLower.contains('knife')) {
      return (ReferenceObjectType.diningKnife, 1.0);
    }

    // ── Chopsticks ──
    if (labelLower.contains('chopstick')) {
      return (ReferenceObjectType.chopsticks, 1.0);
    }

    // ── Cell phone ──
    if (labelLower == 'cell phone' ||
        labelLower == 'cellular telephone' ||
        labelLower.contains('phone') ||
        labelLower.contains('mobile') ||
        labelLower.contains('cellular')) {
      return (ReferenceObjectType.smartphoneStandard, 1.0);
    }

    // ── Credit card ──
    if (labelLower.contains('credit') ||
        labelLower == 'card' ||
        labelLower.contains('wallet')) {
      return (ReferenceObjectType.creditCard, 1.0);
    }

    // ── Coin ──
    if (labelLower.contains('coin') || labelLower.contains('money')) {
      return (ReferenceObjectType.coin10Baht, 1.0);
    }

    // ── Base model generic labels ──
    if (labelLower == 'cutlery' || labelLower == 'tableware') {
      final type = _classifyCutleryByAspectRatio(bbox);
      return (type, 0.9);
    }

    if (labelLower == 'home good') {
      final type = _classifyHomeGoodByShape(bbox);
      if (type != null) return (type, 0.85);
    }

    return null;
  }

  bool _isPlateLabel(String labelLower) {
    const plateLabels = [
      'bowl', 'plate', 'dish', 'tableware', 'cup',
      'dining table', 'home good', 'soup bowl', 'mixing bowl',
    ];
    return plateLabels.any((pl) => labelLower.contains(pl));
  }

  DetectedReferenceObject? _buildDetected(
    ReferenceObjectType type,
    BoundingBoxData bboxData,
    double confidence,
  ) {
    final spec = ReferenceObjectsData.getSpec(type);
    if (spec == null) return null;
    return DetectedReferenceObject(
      type: type,
      boundingBox: bboxData,
      confidence: confidence,
      knownLengthCm: spec.lengthCm,
      knownWidthCm: spec.widthCm,
    );
  }

  // ── Shape heuristics ────────────────────────────────────────────────────────

  /// Shape-only classification with STRICT criteria.
  /// Only matches highly distinctive shapes to avoid false positives:
  ///   - aspect > 3.0  → cutlery (fork/spoon/knife/chopsticks)
  ///   - aspect 1.5-1.7 + small bbox → credit card
  /// Does NOT match phone shapes (too easy to confuse with other objects)
  ReferenceObjectType? _classifyByShapeStrict(Rect bbox) {
    final longest = math.max(bbox.width, bbox.height);
    final shortest = math.min(bbox.width, bbox.height);
    if (shortest <= 0) return null;

    final aspect = longest / shortest;

    // Very elongated → almost certainly cutlery
    if (aspect > 3.0) {
      return _classifyCutleryByAspectRatio(bbox);
    }

    return null;
  }

  ReferenceObjectType? _classifyHomeGoodByShape(Rect bbox) {
    final longest = math.max(bbox.width, bbox.height);
    final shortest = math.min(bbox.width, bbox.height);
    if (shortest <= 0) return null;

    final aspect = longest / shortest;

    if (aspect > 2.5) return _classifyCutleryByAspectRatio(bbox);
    if (aspect >= 1.4 && aspect <= 1.8) return ReferenceObjectType.creditCard;
    if (aspect >= 1.9 && aspect <= 2.5) {
      return ReferenceObjectType.smartphoneStandard;
    }

    return null;
  }

  ReferenceObjectType _classifyCutleryByAspectRatio(Rect bbox) {
    final longest = math.max(bbox.width, bbox.height);
    final shortest = math.min(bbox.width, bbox.height);

    if (shortest <= 0) return ReferenceObjectType.diningFork;

    final aspect = longest / shortest;

    if (aspect > 6) return ReferenceObjectType.chopsticks;
    if (aspect > 3) return ReferenceObjectType.diningFork;
    if (aspect >= 2) return ReferenceObjectType.tablespoon;
    return ReferenceObjectType.diningFork;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  BoundingBoxData _rectToBoundingBox(Rect rect) {
    return BoundingBoxData(
      x: rect.left,
      y: rect.top,
      width: rect.width,
      height: rect.height,
    );
  }

  InputImageRotation _rotationFromDegrees(int degrees) {
    switch (degrees) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }
}
