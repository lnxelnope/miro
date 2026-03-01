import '../constants/ar_scale_enums.dart';
import 'bounding_box_data.dart';

/// ข้อมูลวัตถุอ้างอิงที่ตรวจจับได้
class DetectedReferenceObject {
  /// ประเภทวัตถุ (fork, spoon, credit card, etc.)
  final ReferenceObjectType type;

  /// Bounding box ใน pixel coordinates ของรูปต้นฉบับ
  final BoundingBoxData boundingBox;

  /// ค่า confidence จาก ML Kit (0.0 - 1.0)
  final double confidence;

  /// ขนาดจริง (ซม.) ของด้านที่ยาวที่สุดของวัตถุนี้
  final double knownLengthCm;

  /// ขนาดจริง (ซม.) ของด้านที่สั้นที่สุดของวัตถุนี้
  final double knownWidthCm;

  const DetectedReferenceObject({
    required this.type,
    required this.boundingBox,
    required this.confidence,
    required this.knownLengthCm,
    required this.knownWidthCm,
  });

  /// ความยาวเป็น pixel ของด้านที่ยาวที่สุดใน bounding box
  double get longestSidePixels =>
      boundingBox.width > boundingBox.height
          ? boundingBox.width
          : boundingBox.height;

  /// ความยาวเป็น pixel ของด้านที่สั้นที่สุดใน bounding box
  double get shortestSidePixels =>
      boundingBox.width < boundingBox.height
          ? boundingBox.width
          : boundingBox.height;

  factory DetectedReferenceObject.fromJson(Map<String, dynamic> json) {
    return DetectedReferenceObject(
      type: ReferenceObjectType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ReferenceObjectType.diningFork,
      ),
      boundingBox: BoundingBoxData.fromJson(
        json['bounding_box'] ?? json['boundingBox'] ?? {},
      ),
      confidence: (json['confidence'] ?? 0).toDouble(),
      knownLengthCm: (json['known_length_cm'] ?? 0).toDouble(),
      knownWidthCm: (json['known_width_cm'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'bounding_box': boundingBox.toJson(),
        'confidence': confidence,
        'known_length_cm': knownLengthCm,
        'known_width_cm': knownWidthCm,
      };
}

/// ข้อมูลขนาดจริงของวัตถุอ้างอิงมาตรฐาน (ใช้ใน constants)
class ReferenceObjectSpec {
  final ReferenceObjectType type;

  /// ความยาวด้านยาว (ซม.)
  final double lengthCm;

  /// ความกว้างด้านสั้น (ซม.)
  final double widthCm;

  /// คำอธิบาย
  final String description;

  const ReferenceObjectSpec({
    required this.type,
    required this.lengthCm,
    required this.widthCm,
    required this.description,
  });
}
