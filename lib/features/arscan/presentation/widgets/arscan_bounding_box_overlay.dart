import 'package:flutter/material.dart';

import 'package:miro_hybrid/l10n/app_localizations.dart';
import '../../domain/models/ar_scan_detection.dart';

class ArScanBoundingBoxOverlay extends StatelessWidget {
  const ArScanBoundingBoxOverlay({
    super.key,
    required this.primaryDetection,
    required this.state,
  });

  final ArScanDetection? primaryDetection;
  final ArScanState state;

  bool get _shouldShowBox {
    final detection = primaryDetection;
    if (detection == null) return false;
    if (!detection.isFood) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: SizedBox.expand(
          child: Stack(
            children: [
              CustomPaint(
                painter: _ArScanBoundingBoxPainter(
                  detection: _shouldShowBox ? primaryDetection : null,
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
  });

  final ArScanDetection? detection;

  @override
  void paint(Canvas canvas, Size size) {
    final d = detection;
    if (d == null) return;

    final rect = Rect.fromLTWH(
      d.normalizedRect.left * size.width,
      d.normalizedRect.top * size.height,
      d.normalizedRect.width * size.width,
      d.normalizedRect.height * size.height,
    );

    final paint = Paint()
      ..color = Colors.green
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

    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        rect.left,
        rect.top - bgHeight - 4,
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
    return false;
  }
}

