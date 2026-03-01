import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/detected_object_label.dart';

/// CustomPainter สำหรับวาด label แบบง่ายบนรูปอาหาร
/// Font size scale ตามขนาด canvas → ใช้ได้ทั้งบนหน้าจอและ bake ลงรูปจริง
class ArLabelOverlayPainter extends CustomPainter {
  final List<DetectedObjectLabel> labels;
  final Size imageSize;
  final double? pixelPerCm;

  ArLabelOverlayPainter({
    required this.labels,
    required this.imageSize,
    this.pixelPerCm,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (labels.isEmpty) return;
    if (imageSize.width <= 0 || imageSize.height <= 0) return;

    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    // Font size: ~1.2% ของความกว้าง canvas (อ่านง่ายทั้งบนจอและในรูปจริง)
    final baseFontSize = math.max(size.width * 0.028, 10.0);
    final smallFontSize = baseFontSize * 0.75;

    for (final obj in labels) {
      final x = obj.centerX * scaleX;
      final y = obj.centerY * scaleY;

      final confPct = (obj.confidence * 100).toStringAsFixed(0);
      final sizeText = _formatSize(obj);

      _drawFloatingLabel(
        canvas,
        title: '${obj.label} $confPct%',
        subtitle: sizeText,
        center: Offset(x, y),
        baseFontSize: baseFontSize,
        smallFontSize: smallFontSize,
      );
    }
  }

  String _formatSize(DetectedObjectLabel obj) {
    if (pixelPerCm != null && pixelPerCm! > 0) {
      final widthCm = obj.bboxWidth / pixelPerCm!;
      final heightCm = obj.bboxHeight / pixelPerCm!;
      return '${widthCm.toStringAsFixed(1)}×${heightCm.toStringAsFixed(1)} cm';
    }
    return '${obj.bboxWidth.toInt()}×${obj.bboxHeight.toInt()} px';
  }

  void _drawFloatingLabel(
    Canvas canvas, {
    required String title,
    required String subtitle,
    required Offset center,
    required double baseFontSize,
    required double smallFontSize,
  }) {
    final titlePainter = TextPainter(
      text: TextSpan(
        text: title,
        style: TextStyle(
          fontSize: baseFontSize,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black87, blurRadius: 4)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final subtitlePainter = TextPainter(
      text: TextSpan(
        text: subtitle,
        style: TextStyle(
          fontSize: smallFontSize,
          fontWeight: FontWeight.w400,
          color: const Color(0xCCFFFFFF),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final tagW = math.max(titlePainter.width, subtitlePainter.width) + baseFontSize * 1.2;
    final tagH = titlePainter.height + subtitlePainter.height + baseFontSize * 0.8;
    final padding = baseFontSize * 0.5;
    final arrowSize = baseFontSize * 0.5;

    final tagX = center.dx - tagW / 2;
    final tagY = center.dy - tagH - arrowSize - 2;

    // Background
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(tagX, tagY, tagW, tagH),
      Radius.circular(baseFontSize * 0.5),
    );
    canvas.drawRRect(bgRect, Paint()..color = const Color(0xDD000000));

    // Arrow pointing down
    final arrowPath = Path()
      ..moveTo(center.dx - arrowSize, tagY + tagH)
      ..lineTo(center.dx, tagY + tagH + arrowSize)
      ..lineTo(center.dx + arrowSize, tagY + tagH)
      ..close();
    canvas.drawPath(arrowPath, Paint()..color = const Color(0xDD000000));

    // Title text
    titlePainter.paint(
      canvas,
      Offset(tagX + padding, tagY + padding * 0.6),
    );

    // Subtitle text (size)
    subtitlePainter.paint(
      canvas,
      Offset(tagX + padding, tagY + padding * 0.6 + titlePainter.height + 2),
    );
  }

  @override
  bool shouldRepaint(ArLabelOverlayPainter oldDelegate) {
    return labels != oldDelegate.labels ||
        imageSize != oldDelegate.imageSize ||
        pixelPerCm != oldDelegate.pixelPerCm;
  }
}

/// Widget wrapper สำหรับ ArLabelOverlayPainter
class ArLabelOverlay extends StatelessWidget {
  final List<DetectedObjectLabel> labels;
  final Size imageSize;
  final Widget child;
  final double? pixelPerCm;

  const ArLabelOverlay({
    super.key,
    required this.labels,
    required this.imageSize,
    required this.child,
    this.pixelPerCm,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (labels.isNotEmpty)
          Positioned.fill(
            child: CustomPaint(
              painter: ArLabelOverlayPainter(
                labels: labels,
                imageSize: imageSize,
                pixelPerCm: pixelPerCm,
              ),
            ),
          ),
      ],
    );
  }
}
