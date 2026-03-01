import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/detected_object_label.dart';
import 'ar_ruler_overlay.dart';

/// แสดงรูปอาหารพร้อม AR label overlay ซ้อนทับ
/// รองรับ BoxFit.cover / contain / fill — คำนวณ coordinate mapping ให้ถูก
class FoodImageWithOverlay extends StatelessWidget {
  final String imagePath;
  final String? arLabelsJson;
  final double? arImageWidth;
  final double? arImageHeight;
  final double? arPixelPerCm;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const FoodImageWithOverlay({
    super.key,
    required this.imagePath,
    this.arLabelsJson,
    this.arImageWidth,
    this.arImageHeight,
    this.arPixelPerCm,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final labels = DetectedObjectLabel.decode(arLabelsJson);
    final hasOverlay =
        labels.isNotEmpty && arImageWidth != null && arImageHeight != null;

    final image = Image.file(
      File(imagePath),
      fit: fit,
      width: width,
      height: height,
      errorBuilder: errorBuilder,
    );

    if (!hasOverlay) return image;

    return LayoutBuilder(
      builder: (context, constraints) {
        // ใช้ constraints จริง (ไม่ใช้ width/height ที่อาจเป็น infinity)
        final double containerW = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : (width != null && width!.isFinite ? width! : 300.0);
        final double containerH = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : (height != null && height!.isFinite ? height! : 300.0);

        if (containerW <= 0 || containerH <= 0) return image;

        debugPrint(
          '[FoodImageWithOverlay] ${labels.length} labels, '
          'container=${containerW.toInt()}x${containerH.toInt()}, '
          'img=${arImageWidth!.toInt()}x${arImageHeight!.toInt()}',
        );

        // Thumbnail เล็กเกินไป → แสดง badge แทน
        if (containerW <= 80 && containerH <= 80) {
          return Stack(
            children: [
              image,
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xCC000000),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'AR ${labels.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        final imgW = arImageWidth!;
        final imgH = arImageHeight!;

        double scale;
        double offsetX = 0, offsetY = 0;

        switch (fit) {
          case BoxFit.cover:
            scale = math.max(containerW / imgW, containerH / imgH);
            offsetX = (imgW * scale - containerW) / 2;
            offsetY = (imgH * scale - containerH) / 2;
          case BoxFit.contain:
            scale = math.min(containerW / imgW, containerH / imgH);
            offsetX = -(containerW - imgW * scale) / 2;
            offsetY = -(containerH - imgH * scale) / 2;
          default:
            scale = containerW / imgW;
            offsetX = 0;
            offsetY = 0;
        }

        final adjusted = labels
            .map((l) => DetectedObjectLabel(
                  label: l.label,
                  confidence: l.confidence,
                  centerX: l.centerX * scale - offsetX,
                  centerY: l.centerY * scale - offsetY,
                  bboxWidth: l.bboxWidth * scale,
                  bboxHeight: l.bboxHeight * scale,
                ))
            .toList();

        return SizedBox(
          width: containerW,
          height: containerH,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(child: image),
              Positioned.fill(
                child: CustomPaint(
                  painter: ArLabelOverlayPainter(
                    labels: adjusted,
                    imageSize: Size(containerW, containerH),
                    pixelPerCm: arPixelPerCm,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
