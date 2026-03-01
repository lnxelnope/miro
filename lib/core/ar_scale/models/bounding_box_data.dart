import 'dart:ui';

/// Bounding box ของวัตถุที่ detect ได้จาก ML Kit หรือ Gemini
/// ค่า x, y, width, height เป็น pixel coordinates ของรูปต้นฉบับ
class BoundingBoxData {
  final double x;
  final double y;
  final double width;
  final double height;

  const BoundingBoxData({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  double get centerX => x + width / 2;
  double get centerY => y + height / 2;
  double get right => x + width;
  double get bottom => y + height;
  double get area => width * height;
  double get aspectRatio => width > 0 ? height / width : 0;

  /// แปลงเป็น Rect สำหรับวาดบน Canvas
  Rect toRect() => Rect.fromLTWH(x, y, width, height);

  /// Scale bounding box ให้ตรงกับขนาดจอแสดงผล
  BoundingBoxData scaleToDisplay({
    required double imageWidth,
    required double imageHeight,
    required double displayWidth,
    required double displayHeight,
  }) {
    final scaleX = displayWidth / imageWidth;
    final scaleY = displayHeight / imageHeight;
    return BoundingBoxData(
      x: x * scaleX,
      y: y * scaleY,
      width: width * scaleX,
      height: height * scaleY,
    );
  }

  factory BoundingBoxData.fromJson(Map<String, dynamic> json) {
    return BoundingBoxData(
      x: (json['x'] ?? 0).toDouble(),
      y: (json['y'] ?? 0).toDouble(),
      width: (json['width'] ?? 0).toDouble(),
      height: (json['height'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'width': width,
        'height': height,
      };

  @override
  String toString() =>
      'BoundingBoxData(x: ${x.toStringAsFixed(1)}, y: ${y.toStringAsFixed(1)}, '
      'w: ${width.toStringAsFixed(1)}, h: ${height.toStringAsFixed(1)})';
}
