import 'dart:math';
import 'package:flutter/material.dart';

/// Compact semicircle gauge for Net Energy (Intake − TDEE − Active).
///
/// Scale: -TDEE (left) → 0 (right).
/// If net energy is positive (surplus), needle stays at rightmost and
/// the number displays the actual positive value.
///
/// Dynamic zones (left → right):
///   Danger (-TDEE…-BMR) → Careful → Sweet Spot → Maintain (…0)
class DeficitGauge extends StatelessWidget {
  final double netEnergy;
  final double bmr;
  final double tdee;
  final bool isDark;
  final double width;

  const DeficitGauge({
    super.key,
    required this.netEnergy,
    required this.bmr,
    required this.tdee,
    this.isDark = false,
    this.width = 110,
  });

  double get _safeBmr => (bmr > 0) ? bmr : 1500.0;
  double get _safeTdee => (tdee > _safeBmr) ? tdee : _safeBmr + 500;
  double get _deficit => _safeTdee - _safeBmr;

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
              painter: _GaugePainter(
                netEnergy: netEnergy,
                bmr: _safeBmr,
                tdee: _safeTdee,
                isDark: isDark,
              ),
            ),
          ),
          Text(
            '${netEnergy < 0 ? "" : "+"}${netEnergy.toInt()}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              height: 1.1,
              color: _statusColor,
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

  Color get _statusColor {
    if (netEnergy > 0) return const Color(0xFFEF4444);
    if (netEnergy >= -_deficit * 0.3) return const Color(0xFF1976D2);
    if (netEnergy >= -_deficit * 0.8) return const Color(0xFF4CAF50);
    if (netEnergy >= -_safeBmr) return const Color(0xFFFFA726);
    return const Color(0xFFEF4444);
  }
}

class _GaugePainter extends CustomPainter {
  final double netEnergy;
  final double bmr;
  final double tdee;
  final bool isDark;

  _GaugePainter({
    required this.netEnergy,
    required this.bmr,
    required this.tdee,
    required this.isDark,
  });

  static const _arcWidth = 10.0;

  @override
  void paint(Canvas canvas, Size size) {
    // Scale: -TDEE (left) to 0 (right)
    final minVal = -tdee;
    const maxVal = 0.0;
    final range = maxVal - minVal; // = tdee
    final deficit = tdee - bmr;

    // 0.0 = left (-TDEE), 1.0 = right (0)
    double valueToNorm(double value) =>
        ((value - minVal) / range).clamp(0.0, 1.0);

    // Zones: Danger → Careful → Sweet Spot → Maintain
    final zones = [
      _Zone(valueToNorm(minVal), valueToNorm(-bmr), const Color(0xFFEF4444)),
      _Zone(valueToNorm(-bmr), valueToNorm(-deficit * 0.8), const Color(0xFFFFA726)),
      _Zone(valueToNorm(-deficit * 0.8), valueToNorm(-deficit * 0.3), const Color(0xFF4CAF50)),
      _Zone(valueToNorm(-deficit * 0.3), valueToNorm(maxVal), const Color(0xFF1976D2)),
    ];

    final cx = size.width / 2;
    final cy = size.height - 1;
    final radius = min(size.width / 2 - 12, size.height - 6);
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    for (final zone in zones) {
      final startAngle = pi + zone.startNorm * pi;
      final sweepAngle = (zone.endNorm - zone.startNorm) * pi;
      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle,
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
    capPaint.color = zones.first.color.withValues(alpha: 0.55);
    canvas.drawArc(rect, pi, 0.001, false, capPaint);
    capPaint.color = zones.last.color.withValues(alpha: 0.55);
    canvas.drawArc(rect, 2 * pi - 0.001, 0.001, false, capPaint);

    // Needle — clamped to -TDEE..0, surplus stays at rightmost
    final clamped = netEnergy.clamp(minVal, maxVal);
    final needleAngle = pi + valueToNorm(clamped) * pi;
    final needleLen = radius - _arcWidth / 2 - 5;
    final end = Offset(
      cx + needleLen * cos(needleAngle),
      cy + needleLen * sin(needleAngle),
    );

    canvas.drawLine(
      Offset(cx, cy),
      end,
      Paint()
        ..color = isDark ? Colors.white : const Color(0xFF333333)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    // Pivot dot
    canvas.drawCircle(
      Offset(cx, cy),
      3.5,
      Paint()..color = isDark ? Colors.white : const Color(0xFF333333),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      1.5,
      Paint()..color = isDark ? const Color(0xFF1F2937) : Colors.white,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.netEnergy != netEnergy ||
      old.bmr != bmr ||
      old.tdee != tdee ||
      old.isDark != isDark;
}

class _Zone {
  final double startNorm;
  final double endNorm;
  final Color color;
  const _Zone(this.startNorm, this.endNorm, this.color);
}
