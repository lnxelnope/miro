import '../constants/ar_scale_enums.dart';
import 'bounding_box_data.dart';
import 'reference_object.dart';

/// ผลลัพธ์การ calibrate จากวัตถุอ้างอิง
class CalibrationResult {
  /// วัตถุอ้างอิงที่ใช้ calibrate
  final DetectedReferenceObject referenceObject;

  /// อัตราส่วน pixel ต่อ 1 ซม. ในระนาบเดียวกัน
  final double pixelPerCm;

  /// Bounding box ของจาน/ชาม (ถ้าตรวจจับได้)
  final BoundingBoxData? plateBoundingBox;

  /// เส้นผ่านศูนย์กลางจาน (ซม.) ที่ประมาณได้
  final double? plateDiameterCm;

  /// พื้นที่จาน (ตร.ซม.) ที่ประมาณได้
  final double? plateAreaCm2;

  /// ปริมาตรประมาณ (มล.) — คำนวณจากเส้นผ่านศูนย์กลาง + ความลึกมาตรฐาน
  final double? estimatedVolumeMl;

  /// Timestamp ที่ calibrate
  final DateTime calibratedAt;

  CalibrationResult({
    required this.referenceObject,
    required this.pixelPerCm,
    this.plateBoundingBox,
    this.plateDiameterCm,
    this.plateAreaCm2,
    this.estimatedVolumeMl,
    DateTime? calibratedAt,
  }) : calibratedAt = calibratedAt ?? DateTime.now();

  /// ค่า confidence ของ calibration (มาจากวัตถุอ้างอิง)
  double get confidence => referenceObject.confidence;

  /// Tier ที่ตัดสินว่าจะใช้ calibration หรือไม่
  CalibrationTier get tier {
    if (confidence >= 0.85) return CalibrationTier.high;
    if (confidence >= 0.65) return CalibrationTier.medium;
    return CalibrationTier.low;
  }

  /// ควรใช้ calibration นี้หรือไม่ (ต้อง ≥ medium)
  bool get shouldUseCalibration => tier.shouldUseCalibration;

  /// แปลงขนาด pixel เป็น ซม.
  double pixelsToCm(double pixels) {
    if (pixelPerCm <= 0) return 0;
    return pixels / pixelPerCm;
  }

  /// แปลงขนาด ซม. เป็น pixel
  double cmToPixels(double cm) => cm * pixelPerCm;

  /// สร้าง hint สำหรับเพิ่มใน Gemini prompt
  /// [SENIOR จะ implement logic การสร้าง prompt ที่ถูกต้อง]
  String? toPromptHint() {
    if (!shouldUseCalibration) return null;

    final confLabel = tier == CalibrationTier.high
        ? 'HIGH confidence'
        : 'MEDIUM confidence (verify visually)';
    final refName = referenceObject.type.displayName;
    final confPct = (confidence * 100).toStringAsFixed(0);

    final buffer = StringBuffer()
      ..writeln('PHYSICAL CALIBRATION DATA ($confLabel):')
      ..writeln(
        'A $refName was detected in the image with $confPct% confidence.',
      );

    if (plateDiameterCm != null) {
      buffer.writeln(
        'Measured plate/bowl diameter: ~${plateDiameterCm!.toStringAsFixed(1)} cm.',
      );
    }
    if (estimatedVolumeMl != null) {
      buffer.writeln(
        'Estimated container volume: ~${estimatedVolumeMl!.toStringAsFixed(0)} ml.',
      );
    }

    buffer.writeln(
      'Use this measurement to estimate portion size more accurately.',
    );

    if (tier == CalibrationTier.medium) {
      buffer.writeln(
        'Note: Medium confidence — cross-check with visual estimation.',
      );
    }

    return buffer.toString();
  }

  factory CalibrationResult.fromJson(Map<String, dynamic> json) {
    return CalibrationResult(
      referenceObject: DetectedReferenceObject.fromJson(
        json['reference_object'] ?? {},
      ),
      pixelPerCm: (json['pixel_per_cm'] ?? 0).toDouble(),
      plateBoundingBox: json['plate_bounding_box'] != null
          ? BoundingBoxData.fromJson(json['plate_bounding_box'])
          : null,
      plateDiameterCm: json['plate_diameter_cm']?.toDouble(),
      plateAreaCm2: json['plate_area_cm2']?.toDouble(),
      estimatedVolumeMl: json['estimated_volume_ml']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'reference_object': referenceObject.toJson(),
        'pixel_per_cm': pixelPerCm,
        if (plateBoundingBox != null)
          'plate_bounding_box': plateBoundingBox!.toJson(),
        if (plateDiameterCm != null) 'plate_diameter_cm': plateDiameterCm,
        if (plateAreaCm2 != null) 'plate_area_cm2': plateAreaCm2,
        if (estimatedVolumeMl != null) 'estimated_volume_ml': estimatedVolumeMl,
      };
}
