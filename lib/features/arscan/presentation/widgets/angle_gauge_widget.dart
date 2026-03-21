import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/models/angle_zone.dart';

/// Visual arc indicator แสดงมุมกล้องปัจจุบัน + target zone
class AngleGaugeWidget extends StatelessWidget {
  const AngleGaugeWidget({
    super.key,
    required this.currentAngle,
    required this.targetZone,
    required this.isInZone,
  });

  final double currentAngle; // 0-90
  final AngleZone targetZone; // top/diagonal/side
  final bool isInZone;

  static const double _arcSize = 120;
  static const double _strokeWidth = 6;
  static const double _indicatorRadius = 5;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _arcSize,
      height: _arcSize / 2 + 28,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: _arcSize,
            height: _arcSize / 2 + _indicatorRadius,
            child: CustomPaint(
              painter: _ArcPainter(
                currentAngle: currentAngle,
                targetZone: targetZone,
                isInZone: isInZone,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _directionText,
            style: TextStyle(
              color: isInZone ? const Color(0xFF4ADE80) : Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              shadows: const [
                Shadow(blurRadius: 4, color: Colors.black54),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _directionText {
    if (isInZone) return 'Hold steady';

    final (low, high) = _zoneRange(targetZone);
    final mid = (low + high) / 2;

    if (currentAngle < mid) {
      return targetZone == AngleZone.top ? 'Tilt down' : 'Tilt up';
    }
    return targetZone == AngleZone.side ? 'Tilt up' : 'Tilt down';
  }

  static (double, double) _zoneRange(AngleZone zone) {
    switch (zone) {
      case AngleZone.top:
        return (0, 30);
      case AngleZone.diagonal:
        return (30, 60);
      case AngleZone.side:
        return (60, 90);
      case AngleZone.outOfRange:
        return (0, 90);
    }
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter({
    required this.currentAngle,
    required this.targetZone,
    required this.isInZone,
  });

  final double currentAngle;
  final AngleZone targetZone;
  final bool isInZone;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - AngleGaugeWidget._indicatorRadius;

    // background arc (grey)
    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = AngleGaugeWidget._strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      bgPaint,
    );

    // target zone highlight
    final (zoneLow, zoneHigh) =
        AngleGaugeWidget._zoneRange(targetZone);
    final startFrac = zoneLow / 90;
    final endFrac = zoneHigh / 90;

    final zonePaint = Paint()
      ..color = isInZone
          ? const Color(0xFF4ADE80).withValues(alpha: 0.7)
          : const Color(0xFFFBBF24).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = AngleGaugeWidget._strokeWidth + 2
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi + (startFrac * math.pi),
      (endFrac - startFrac) * math.pi,
      false,
      zonePaint,
    );

    // current angle indicator dot
    final angleFrac = (currentAngle.clamp(0, 90) / 90);
    final indicatorAngle = math.pi + (angleFrac * math.pi);
    final indicatorPos = Offset(
      center.dx + radius * math.cos(indicatorAngle),
      center.dy + radius * math.sin(indicatorAngle),
    );

    final dotPaint = Paint()
      ..color = isInZone ? const Color(0xFF4ADE80) : Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
        indicatorPos, AngleGaugeWidget._indicatorRadius, dotPaint);

    // outer ring for dot
    final dotBorderPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(
        indicatorPos, AngleGaugeWidget._indicatorRadius, dotBorderPaint);
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) =>
      oldDelegate.currentAngle != currentAngle ||
      oldDelegate.targetZone != targetZone ||
      oldDelegate.isInZone != isInZone;
}
