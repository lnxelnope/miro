import 'dart:math' as math;
import '../constants/ar_scale_enums.dart';
import '../constants/reference_objects_data.dart';
import '../models/bounding_box_data.dart';
import '../models/calibration_result.dart';
import '../models/reference_object.dart';

/// Service สำหรับคำนวณ pixel-to-cm ratio จากวัตถุอ้างอิง
/// แล้วใช้ ratio นั้นวัดขนาดจาน/ชาม
class ScaleCalibrationService {
  ScaleCalibrationService._();

  /// คำนวณ calibration จากวัตถุอ้างอิงที่ detect ได้
  ///
  /// [referenceObject] — วัตถุอ้างอิงที่ ML Kit detect ได้
  /// [plateBoundingBox] — bounding box ของจาน/ชาม (ถ้าตรวจจับได้)
  /// [imageWidth] / [imageHeight] — ขนาดรูปต้นฉบับ
  ///
  /// Returns [CalibrationResult] หรือ null ถ้า confidence ต่ำเกินไป
  static CalibrationResult? calibrate({
    required DetectedReferenceObject referenceObject,
    BoundingBoxData? plateBoundingBox,
    required double imageWidth,
    required double imageHeight,
  }) {
    // ปรับ confidence ตาม perspective distortion ก่อน
    final adjustedRef = _withAdjustedConfidence(referenceObject);

    // ถ้า confidence ต่ำกว่า threshold หลัง adjust → ไม่ใช้ calibration
    if (adjustedRef.confidence < ReferenceObjectsData.mediumConfidenceThreshold) {
      return null;
    }

    // คำนวณ pixelPerCm
    final pixelPerCm = calculatePixelPerCm(referenceObject: adjustedRef);
    if (pixelPerCm <= 0) return null;

    // คำนวณขนาดจาน (ถ้ามี plateBoundingBox)
    double? plateDiameterCm;
    double? plateAreaCm2;
    double? estimatedVolumeMl;

    if (plateBoundingBox != null) {
      plateDiameterCm = measurePlateDiameter(
        plateBoundingBox: plateBoundingBox,
        pixelPerCm: pixelPerCm,
      );
    }

    if (plateDiameterCm != null && plateDiameterCm > 0) {
      // คำนวณพื้นที่จาน: π × (d/2)²
      plateAreaCm2 = math.pi * math.pow(plateDiameterCm / 2, 2);

      // ประมาณ volume:
      // จาน (shallow): depth ≈ 2.5 cm
      // ชาม (deep): depth ≈ 7.0 cm × 0.6 (ไม่เต็มชาม)
      // ดูจากอัตราส่วน: ถ้าจานใหญ่กว่า 20 cm → น่าจะเป็นจาน
      final isBowl = plateDiameterCm < 20;
      estimatedVolumeMl = estimateVolume(
        diameterCm: plateDiameterCm,
        isBowl: isBowl,
      );
    }

    return CalibrationResult(
      referenceObject: adjustedRef,
      pixelPerCm: pixelPerCm,
      plateBoundingBox: plateBoundingBox,
      plateDiameterCm: plateDiameterCm,
      plateAreaCm2: plateAreaCm2,
      estimatedVolumeMl: estimatedVolumeMl,
    );
  }

  /// คำนวณ pixel-per-cm ratio จากวัตถุอ้างอิง
  ///
  /// สูตรหลัก:
  /// - ถ้า aspect ratio ของ bounding box ต่างจาก real object > 30% → วัตถุเอียง
  ///   → ใช้ diagonal: sqrt(w² + h²) / knownLengthCm
  /// - ถ้า aspect ratio ตรง (±15%) → ใช้ longestSide ตรงๆ
  static double calculatePixelPerCm({
    required DetectedReferenceObject referenceObject,
  }) {
    final bbox = referenceObject.boundingBox;
    final knownLengthCm = referenceObject.knownLengthCm;
    final knownWidthCm = referenceObject.knownWidthCm;

    if (knownLengthCm <= 0) return 0;

    final bboxLongest = math.max(bbox.width, bbox.height);
    final bboxShortest = math.min(bbox.width, bbox.height);

    if (bboxLongest <= 0 || bboxShortest <= 0) return 0;

    // คำนวณ expected aspect ratio จากขนาดจริง
    final expectedAspect = knownLengthCm / math.max(knownWidthCm, 0.01);
    final actualAspect = bboxLongest / math.max(bboxShortest, 0.01);

    // ถ้า aspect ratio ต่างกันเกิน 30% → วัตถุเอียง → ใช้ diagonal
    final aspectDeviation = (expectedAspect - actualAspect).abs() / expectedAspect;
    if (aspectDeviation > 0.30) {
      // ใช้ diagonal ของ bounding box หารด้วย knownLengthCm
      final diagonal = math.sqrt(bbox.width * bbox.width + bbox.height * bbox.height);
      return diagonal / knownLengthCm;
    }

    // aspect ratio ตรง → ใช้ longest side
    return bboxLongest / knownLengthCm;
  }

  /// วัดขนาดจาน/ชามจาก pixel ratio
  static double? measurePlateDiameter({
    required BoundingBoxData plateBoundingBox,
    required double pixelPerCm,
  }) {
    if (pixelPerCm <= 0) return null;
    // ใช้ max(width, height) เพราะจานมักจะเป็นวงกลม
    final platePixels = math.max(plateBoundingBox.width, plateBoundingBox.height);
    if (platePixels <= 0) return null;
    return platePixels / pixelPerCm;
  }

  /// ประมาณปริมาตรจากขนาดจาน/ชาม
  /// ใช้สูตร: V = π × (d/2)² × depth
  static double? estimateVolume({
    required double diameterCm,
    bool isBowl = false,
  }) {
    if (diameterCm <= 0) return null;
    final radius = diameterCm / 2;
    final area = math.pi * radius * radius;

    if (isBowl) {
      // ชาม: depth ≈ 7.0 cm × 0.6 (ไม่เต็มชาม)
      return area * ReferenceObjectsData.averageBowlDepthCm * 0.6;
    } else {
      // จาน: depth ≈ 2.5 cm (shallow)
      return area * ReferenceObjectsData.averagePlateDepthCm;
    }
  }

  /// ตรวจสอบว่า aspect ratio ของ bounding box
  /// ตรงกับ aspect ratio จริงของวัตถุหรือไม่
  /// ถ้าไม่ตรง → อาจมี perspective distortion → ลด confidence
  static double adjustConfidenceForPerspective({
    required DetectedReferenceObject referenceObject,
  }) {
    final bbox = referenceObject.boundingBox;
    final knownLengthCm = referenceObject.knownLengthCm;
    final knownWidthCm = referenceObject.knownWidthCm;

    if (knownLengthCm <= 0 || knownWidthCm <= 0) {
      return referenceObject.confidence;
    }

    final bboxLongest = math.max(bbox.width, bbox.height);
    final bboxShortest = math.min(bbox.width, bbox.height);

    if (bboxShortest <= 0) return referenceObject.confidence * 0.5;

    final expectedAspect = knownLengthCm / knownWidthCm;
    final actualAspect = bboxLongest / bboxShortest;

    final deviation = (expectedAspect - actualAspect).abs() / expectedAspect;

    double multiplier;
    if (deviation > 0.5) {
      multiplier = 0.5; // perspective มาก
    } else if (deviation > 0.3) {
      multiplier = 0.7;
    } else if (deviation > 0.15) {
      multiplier = 0.85;
    } else {
      multiplier = 1.0; // ปกติ
    }

    return (referenceObject.confidence * multiplier).clamp(0.0, 1.0);
  }

  /// Helper: สร้าง DetectedReferenceObject ใหม่พร้อม confidence ที่ adjust แล้ว
  static DetectedReferenceObject _withAdjustedConfidence(
    DetectedReferenceObject ref,
  ) {
    final adjustedConfidence = adjustConfidenceForPerspective(referenceObject: ref);
    if (adjustedConfidence == ref.confidence) return ref;
    return DetectedReferenceObject(
      type: ref.type,
      boundingBox: ref.boundingBox,
      confidence: adjustedConfidence,
      knownLengthCm: ref.knownLengthCm,
      knownWidthCm: ref.knownWidthCm,
    );
  }
}
