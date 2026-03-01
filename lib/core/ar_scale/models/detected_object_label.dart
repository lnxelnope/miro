import 'dart:convert';

/// ข้อมูล label ที่ detect ได้จาก ML Kit — ใช้แสดง overlay แบบง่าย
/// เก็บ pixel coordinates ของรูปต้นฉบับ + ขนาด bounding box
class DetectedObjectLabel {
  final String label;
  final double confidence;
  final double centerX;
  final double centerY;
  final double bboxWidth;
  final double bboxHeight;

  const DetectedObjectLabel({
    required this.label,
    required this.confidence,
    required this.centerX,
    required this.centerY,
    required this.bboxWidth,
    required this.bboxHeight,
  });

  double get aspectRatio {
    if (bboxWidth <= 0 || bboxHeight <= 0) return 1;
    final longest = bboxWidth > bboxHeight ? bboxWidth : bboxHeight;
    final shortest = bboxWidth < bboxHeight ? bboxWidth : bboxHeight;
    return longest / shortest;
  }

  Map<String, dynamic> toJson() => {
        'l': label,
        'c': confidence,
        'x': centerX,
        'y': centerY,
        'w': bboxWidth,
        'h': bboxHeight,
      };

  factory DetectedObjectLabel.fromJson(Map<String, dynamic> json) {
    return DetectedObjectLabel(
      label: json['l'] as String? ?? 'Object',
      confidence: (json['c'] as num?)?.toDouble() ?? 0,
      centerX: (json['x'] as num?)?.toDouble() ?? 0,
      centerY: (json['y'] as num?)?.toDouble() ?? 0,
      bboxWidth: (json['w'] as num?)?.toDouble() ?? 0,
      bboxHeight: (json['h'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Serialize list → JSON string (เก็บใน DB)
  static String encode(List<DetectedObjectLabel> labels) {
    return jsonEncode(labels.map((l) => l.toJson()).toList());
  }

  /// Deserialize JSON string → list (อ่านจาก DB)
  static List<DetectedObjectLabel> decode(String? json) {
    if (json == null || json.isEmpty) return [];
    try {
      final list = jsonDecode(json) as List;
      return list
          .map((e) => DetectedObjectLabel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
