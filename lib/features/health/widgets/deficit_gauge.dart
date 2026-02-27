import 'dart:math';
import 'package:flutter/material.dart';

/// Compact semicircle gauge (Fear/Greed style) for Net Energy.
///
/// Zones (left → right):
///   Surplus (+) → Maintain (0 to -300) → Sweet Spot (-300 to -1000)
///   → Careful (-1000 to -1200) → Danger (< -1200)
class DeficitGauge extends StatelessWidget {
  final double netEnergy;
  final bool isDark;
  final double width;

  const DeficitGauge({
    super.key,
    required this.netEnergy,
    this.isDark = false,
    this.width = 110,
  });

  @override
  Widget build(BuildContext context) {
    final gaugeHeight = width * 0.45;
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: width,
            height: gaugeHeight,
            child: CustomPaint(
              size: Size(width, gaugeHeight),
              painter: _GaugePainter(netEnergy: netEnergy, isDark: isDark),
            ),
          ),
          Text(
            '${netEnergy < 0 ? "" : "+"}${netEnergy.toInt()}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              height: 1.1,
              color: statusColor,
            ),
          ),
          Text(
            'kcal',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Net Energy',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white38 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Color get statusColor {
    if (netEnergy > 0) return const Color(0xFFEF4444);
    if (netEnergy >= -300) return const Color(0xFF1976D2);
    if (netEnergy >= -1000) return const Color(0xFF4CAF50);
    if (netEnergy >= -1200) return const Color(0xFFFFA726);
    return const Color(0xFFEF4444);
  }
}

class _GaugePainter extends CustomPainter {
  final double netEnergy;
  final bool isDark;

  _GaugePainter({required this.netEnergy, required this.isDark});

  static const double _maxSurplus = 500;
  static const double _maxDeficit = -1500;
  static const double _range = 2000;
  static const _arcWidth = 10.0;

  static final _zones = [
    _Zone(500, 0, const Color(0xFFEF4444)),
    _Zone(0, -300, const Color(0xFF1976D2)),
    _Zone(-300, -1000, const Color(0xFF4CAF50)),
    _Zone(-1000, -1200, const Color(0xFFFFA726)),
    _Zone(-1200, -1500, const Color(0xFFEF4444)),
  ];

  double _valueToNorm(double value) =>
      ((_maxSurplus - value) / _range).clamp(0.0, 1.0);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height - 1;
    final radius = min(size.width / 2 - 12, size.height - 6);
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    for (final zone in _zones) {
      final sn = _valueToNorm(zone.from);
      final en = _valueToNorm(zone.to);

      canvas.drawArc(
        rect,
        pi + sn * pi,
        (en - sn) * pi,
        false,
        Paint()
          ..color = zone.color.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = _arcWidth
          ..strokeCap = StrokeCap.butt,
      );
    }

    // Rounded end caps
    final capPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _arcWidth
      ..strokeCap = StrokeCap.round;
    capPaint.color = _zones.first.color.withValues(alpha: 0.55);
    canvas.drawArc(rect, pi, 0.001, false, capPaint);
    capPaint.color = _zones.last.color.withValues(alpha: 0.55);
    canvas.drawArc(rect, 2 * pi - 0.001, 0.001, false, capPaint);

    // Needle
    final clamped = netEnergy.clamp(_maxDeficit, _maxSurplus);
    final needleAngle = pi + _valueToNorm(clamped) * pi;
    final needleLen = radius - _arcWidth / 2 - 5;
    final end = Offset(cx + needleLen * cos(needleAngle), cy + needleLen * sin(needleAngle));

    canvas.drawLine(
      Offset(cx, cy),
      end,
      Paint()
        ..color = isDark ? Colors.white : const Color(0xFF333333)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    // Pivot
    canvas.drawCircle(Offset(cx, cy), 3.5,
        Paint()..color = isDark ? Colors.white : const Color(0xFF333333));
    canvas.drawCircle(Offset(cx, cy), 1.5,
        Paint()..color = isDark ? const Color(0xFF1F2937) : Colors.white);
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.netEnergy != netEnergy || old.isDark != isDark;
}

class _Zone {
  final double from;
  final double to;
  final Color color;
  const _Zone(this.from, this.to, this.color);
}
