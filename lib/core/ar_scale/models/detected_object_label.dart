import 'dart:convert';
import 'dart:ui';

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

  /// Serialize list → JSON string (เก็บใน DB) — single image format
  static String encode(List<DetectedObjectLabel> labels) {
    return jsonEncode(labels.map((l) => l.toJson()).toList());
  }

  /// Deserialize JSON string → list (อ่านจาก DB)
  /// Handles both legacy flat array and multi-image format.
  /// For multi-image format, returns labels of imageIndex 0 by default.
  static List<DetectedObjectLabel> decode(String? json) {
    if (json == null || json.isEmpty) return [];
    try {
      final parsed = jsonDecode(json);
      if (parsed is List) {
        return parsed
            .map((e) =>
                DetectedObjectLabel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (parsed is Map<String, dynamic> && parsed.containsKey('images')) {
        final images = parsed['images'] as List;
        if (images.isEmpty) return [];
        final first = images[0] as Map<String, dynamic>;
        final labels = first['labels'] as List? ?? [];
        return labels
            .map((e) =>
                DetectedObjectLabel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}

/// Per-image AR detection data for multi-angle captures.
class ArImageDetectionData {
  final int imageIndex;
  final double imageWidth;
  final double imageHeight;
  final double? pixelPerCm;
  final List<DetectedObjectLabel> labels;

  const ArImageDetectionData({
    required this.imageIndex,
    required this.imageWidth,
    required this.imageHeight,
    this.pixelPerCm,
    required this.labels,
  });

  Map<String, dynamic> toJson() => {
        'idx': imageIndex,
        'iw': imageWidth,
        'ih': imageHeight,
        if (pixelPerCm != null) 'pxCm': pixelPerCm,
        'labels': labels.map((l) => l.toJson()).toList(),
      };

  factory ArImageDetectionData.fromJson(Map<String, dynamic> json) {
    final labelsList = (json['labels'] as List? ?? [])
        .map((e) => DetectedObjectLabel.fromJson(e as Map<String, dynamic>))
        .toList();
    return ArImageDetectionData(
      imageIndex: json['idx'] as int? ?? 0,
      imageWidth: (json['iw'] as num?)?.toDouble() ?? 0,
      imageHeight: (json['ih'] as num?)?.toDouble() ?? 0,
      pixelPerCm: (json['pxCm'] as num?)?.toDouble(),
      labels: labelsList,
    );
  }

  /// Encode list of per-image data → JSON string for DB storage.
  static String encodeMultiImage(List<ArImageDetectionData> images) {
    return jsonEncode({
      'images': images.map((img) => img.toJson()).toList(),
    });
  }

  /// Decode JSON → list of per-image data.
  /// Returns empty list for legacy single-image format.
  static List<ArImageDetectionData> decodeMultiImage(String? json) {
    if (json == null || json.isEmpty) return [];
    try {
      final parsed = jsonDecode(json);
      if (parsed is Map<String, dynamic> && parsed.containsKey('images')) {
        final images = parsed['images'] as List;
        return images
            .map((e) =>
                ArImageDetectionData.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Decode and return labels for a specific imageIndex.
  static List<DetectedObjectLabel> labelsForImage(String? json, int index) {
    final images = decodeMultiImage(json);
    for (final img in images) {
      if (img.imageIndex == index) return img.labels;
    }
    if (index == 0) return DetectedObjectLabel.decode(json);
    return [];
  }

  /// Decode and return image size for a specific imageIndex.
  static Size? imageSizeForImage(String? json, int index) {
    final images = decodeMultiImage(json);
    for (final img in images) {
      if (img.imageIndex == index) {
        if (img.imageWidth > 0 && img.imageHeight > 0) {
          return Size(img.imageWidth, img.imageHeight);
        }
      }
    }
    return null;
  }
}
