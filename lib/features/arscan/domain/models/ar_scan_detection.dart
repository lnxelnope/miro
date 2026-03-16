import 'dart:ui';

/// Data model สำหรับผลลัพธ์การตรวจจับวัตถุใน ARscan
class ArScanDetection {
  final int? trackingId; // จาก ML Kit (null ถ้าไม่มี)
  final String label; // เช่น "Food", "Bowl", "Plate"
  final double confidence; // 0.0 - 1.0
  final Rect normalizedRect; // x/y/width/height อยู่ในช่วง 0-1
  final bool isFood; // true ถ้า label อยู่ใน food category
  final bool isPrimary; // true ถ้าเป็นกล่องหลักที่เลือกแล้ว
  final DateTime lastSeenAt; // timestamp ล่าสุดที่เห็น
  final int stableFrameCount; // จำนวนเฟรมติดต่อกันที่เห็น object นี้

  const ArScanDetection({
    required this.trackingId,
    required this.label,
    required this.confidence,
    required this.normalizedRect,
    required this.isFood,
    required this.isPrimary,
    required this.lastSeenAt,
    required this.stableFrameCount,
  });

  ArScanDetection copyWith({
    int? trackingId,
    String? label,
    double? confidence,
    Rect? normalizedRect,
    bool? isFood,
    bool? isPrimary,
    DateTime? lastSeenAt,
    int? stableFrameCount,
  }) {
    return ArScanDetection(
      trackingId: trackingId ?? this.trackingId,
      label: label ?? this.label,
      confidence: confidence ?? this.confidence,
      normalizedRect: normalizedRect ?? this.normalizedRect,
      isFood: isFood ?? this.isFood,
      isPrimary: isPrimary ?? this.isPrimary,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      stableFrameCount: stableFrameCount ?? this.stableFrameCount,
    );
  }
}

/// State หลักของ ARscan สำหรับให้ UI ใช้แสดงสถานะ
enum ArScanState {
  searching,
  foodFound,
  readyForCapture,
}

