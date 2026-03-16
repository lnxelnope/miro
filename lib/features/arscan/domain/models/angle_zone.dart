import 'package:flutter/foundation.dart';

/// Zone ของมุมกล้องสำหรับ multi-angle capture
enum AngleZone {
  /// 0° ±15° (มองลงตรง ๆ)
  top,

  /// 45° ±20°
  diagonal,

  /// 70° ±20°
  side,

  /// มุมไม่ตรงกับ zone ใด
  outOfRange,
}

extension AngleZoneHelper on AngleZone {
  static AngleZone fromDegrees(double degrees) {
    final normalized = degrees.clamp(0, 90).toDouble();

    if (normalized >= 0 && normalized <= 15) {
      return AngleZone.top;
    }

    if (normalized >= 25 && normalized <= 65) {
      return AngleZone.diagonal;
    }

    if (normalized >= 50 && normalized <= 90) {
      return AngleZone.side;
    }

    return AngleZone.outOfRange;
  }
}

/// ผลลัพธ์การถ่ายภาพในแต่ละมุม
@immutable
class AngleCaptureResult {
  final AngleZone zone;
  final String imagePath; // path ที่เก็บรูปบนดิสก์
  final DateTime capturedAt;
  final double actualAngle; // มุมจริงที่วัดได้ตอน capture

  const AngleCaptureResult({
    required this.zone,
    required this.imagePath,
    required this.capturedAt,
    required this.actualAngle,
  });
}

