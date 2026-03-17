import 'dart:ui';

import 'package:flutter/foundation.dart';

/// Zone ของมุมกล้องสำหรับ multi-angle capture
/// ไม่มีช่องว่างระหว่างโซน — ทุกมุมอยู่ในโซนใดโซนหนึ่งเสมอ
enum AngleZone {
  /// 0°–30° (มองลงจากด้านบน)
  top,

  /// 30°–60° (มุมเฉียง ระดับอก)
  diagonal,

  /// 60°–90° (ด้านข้าง ระดับตา)
  side,

  /// fallback สำหรับ edge cases เท่านั้น
  outOfRange,
}

extension AngleZoneHelper on AngleZone {
  static AngleZone fromDegrees(double degrees) {
    final normalized = degrees.clamp(0, 90).toDouble();

    if (normalized <= 30) return AngleZone.top;
    if (normalized <= 60) return AngleZone.diagonal;
    return AngleZone.side;
  }
}

/// ผลลัพธ์การถ่ายภาพในแต่ละมุม
@immutable
class AngleCaptureResult {
  final AngleZone zone;
  final String imagePath;
  final DateTime capturedAt;
  final double actualAngle;

  /// Bounding box จาก still-image detection (normalized 0-1)
  final Rect? foodBoundingBox;

  /// Label จาก still-image detection
  final String? foodLabel;

  const AngleCaptureResult({
    required this.zone,
    required this.imagePath,
    required this.capturedAt,
    required this.actualAngle,
    this.foodBoundingBox,
    this.foodLabel,
  });

  AngleCaptureResult copyWithDetection({
    Rect? foodBoundingBox,
    String? foodLabel,
  }) {
    return AngleCaptureResult(
      zone: zone,
      imagePath: imagePath,
      capturedAt: capturedAt,
      actualAngle: actualAngle,
      foodBoundingBox: foodBoundingBox ?? this.foodBoundingBox,
      foodLabel: foodLabel ?? this.foodLabel,
    );
  }
}
