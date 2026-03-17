import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:miro_hybrid/l10n/app_localizations.dart';
import '../../domain/models/ar_scan_detection.dart';

class ArScanBoundingBoxOverlay extends StatelessWidget {
  const ArScanBoundingBoxOverlay({
    super.key,
    required this.primaryDetection,
    required this.state,
    this.previewSize,
  });

  final ArScanDetection? primaryDetection;
  final ArScanState state;
  final Size? previewSize;

  bool get _shouldShowBox {
    final detection = primaryDetection;
    return detection != null;
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: SizedBox.expand(
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _ArScanBoundingBoxPainter(
                    detection: _shouldShowBox ? primaryDetection : null,
                    previewSize: previewSize,
                  ),
                ),
              ),
              if (state == ArScanState.searching) _buildNotDetectBanner(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotDetectBanner(BuildContext context) {
    final l10n = L10n.of(context)!;
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              l10n.noDataYet,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArScanBoundingBoxPainter extends CustomPainter {
  _ArScanBoundingBoxPainter({
    required this.detection,
    required this.previewSize,
  });

  final ArScanDetection? detection;
  final Size? previewSize;

  static bool _debugLogged = false;

  @override
  void paint(Canvas canvas, Size size) {
    final d = detection;
    if (d == null) return;

    // คำนวณ mapping ระหว่าง normalized rect (0-1) กับหน้าจอเมื่อใช้ BoxFit.cover
    final imageSize = previewSize;
    late final double imageWidth;
    late final double imageHeight;

    if (imageSize != null) {
      // preview ใช้ width = previewSize.height, height = previewSize.width
      imageWidth = imageSize.height;
      imageHeight = imageSize.width;
    } else {
      imageWidth = size.width;
      imageHeight = size.height;
    }

    final scale = math.max(
      size.width / imageWidth,
      size.height / imageHeight,
    );
    final scaledWidth = imageWidth * scale;
    final scaledHeight = imageHeight * scale;

    final dx = (size.width - scaledWidth) / 2;
    final dy = (size.height - scaledHeight) / 2;

    if (!_debugLogged) {
      _debugLogged = true;
      debugPrint(
        '[BBOverlay] canvas=${size.width.toInt()}x${size.height.toInt()}, '
        'previewSize=$previewSize, '
        'display=${imageWidth.toInt()}x${imageHeight.toInt()}, '
        'scale=${scale.toStringAsFixed(3)}, dx=${dx.toInt()}, dy=${dy.toInt()}, '
        'normRect=${d.normalizedRect}',
      );
    }

    final rect = Rect.fromLTWH(
      dx + d.normalizedRect.left * imageWidth * scale,
      dy + d.normalizedRect.top * imageHeight * scale,
      d.normalizedRect.width * imageWidth * scale,
      d.normalizedRect.height * imageHeight * scale,
    );

    final isFood = detection?.isFood ?? false;
    final paint = Paint()
      ..color = isFood ? Colors.green : const Color(0xFFFBBF24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(4),
    );
    canvas.drawRRect(rrect, paint);

    _drawLabel(canvas, rect);
  }

  void _drawLabel(Canvas canvas, Rect rect) {
    final label = detection?.label;
    if (label == null || label.isEmpty) return;

    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );
    final textSpan = TextSpan(text: label, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();

    const padding = EdgeInsets.symmetric(horizontal: 6, vertical: 2);
    final bgWidth = textPainter.width + padding.horizontal;
    final bgHeight = textPainter.height + padding.vertical;

    final top = rect.top - bgHeight - 4;
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        rect.left,
        top < 0 ? 0 : top,
        bgWidth,
        bgHeight,
      ),
      const Radius.circular(4),
    );

    final bgPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(bgRect, bgPaint);

    textPainter.paint(
      canvas,
      Offset(
        bgRect.left + padding.left,
        bgRect.top + padding.top,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _ArScanBoundingBoxPainter oldDelegate) {
    final a = detection;
    final b = oldDelegate.detection;
    if (identical(a, b)) return false;
    if (a == null || b == null) return true;
    if (a.normalizedRect != b.normalizedRect) return true;
    if (a.isFood != b.isFood) return true;
    if (previewSize != oldDelegate.previewSize) return true;
    return false;
  }
}

