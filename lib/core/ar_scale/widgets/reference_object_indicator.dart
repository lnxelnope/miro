import 'package:flutter/material.dart';
import '../constants/ar_scale_enums.dart';
import '../../theme/app_tokens.dart';

/// Indicator แสดงว่าตรวจจับวัตถุอ้างอิงได้แล้ว
/// ใช้บน CameraScreen เป็น real-time feedback
class ReferenceObjectIndicator extends StatelessWidget {
  /// ประเภทวัตถุที่ตรวจจับได้
  final ReferenceObjectType? objectType;

  /// ค่า confidence (0.0 - 1.0)
  final double confidence;

  /// กำลัง detect อยู่หรือไม่ (แสดง loading)
  final bool isDetecting;

  const ReferenceObjectIndicator({
    super.key,
    this.objectType,
    this.confidence = 0,
    this.isDetecting = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isDetecting) return _buildDetecting();
    if (objectType == null) return _buildNotFound();
    return _buildFound();
  }

  Widget _buildDetecting() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: AppRadius.pill,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white70,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Text(
            'Scanning for reference...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFound() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: AppRadius.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 14,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'No reference detected',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFound() {
    final tier = _getTier();
    final confPct = (confidence * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: tier.color.withValues(alpha: 0.2),
        borderRadius: AppRadius.pill,
        border: Border.all(
          color: tier.color.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            objectType!.icon,
            size: 14,
            color: tier.color,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '${objectType!.displayName} $confPct%',
            style: TextStyle(
              fontSize: 12,
              color: tier.color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Icon(
            tier.shouldUseCalibration
                ? Icons.check_circle_rounded
                : Icons.warning_rounded,
            size: 14,
            color: tier.color,
          ),
        ],
      ),
    );
  }

  CalibrationTier _getTier() {
    if (confidence >= 0.85) return CalibrationTier.high;
    if (confidence >= 0.65) return CalibrationTier.medium;
    return CalibrationTier.low;
  }
}

/// ตัววาดกรอบ corner brackets แบบ real-time บน camera preview
/// [SENIOR จะนำไปใช้ใน CameraScreen กับ startImageStream]
class LiveReferenceBoundingBox extends StatelessWidget {
  final Rect boundingRect;
  final CalibrationTier tier;

  const LiveReferenceBoundingBox({
    super.key,
    required this.boundingRect,
    required this.tier,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: boundingRect.left,
      top: boundingRect.top,
      width: boundingRect.width,
      height: boundingRect.height,
      child: CustomPaint(
        painter: _CornerBracketPainter(color: tier.color),
      ),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  final Color color;

  _CornerBracketPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final cornerLen = size.shortestSide * 0.25;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Top-left
    canvas.drawLine(rect.topLeft, rect.topLeft + Offset(cornerLen, 0), paint);
    canvas.drawLine(rect.topLeft, rect.topLeft + Offset(0, cornerLen), paint);

    // Top-right
    canvas.drawLine(rect.topRight, rect.topRight + Offset(-cornerLen, 0), paint);
    canvas.drawLine(rect.topRight, rect.topRight + Offset(0, cornerLen), paint);

    // Bottom-left
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + Offset(cornerLen, 0), paint);
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + Offset(0, -cornerLen), paint);

    // Bottom-right
    canvas.drawLine(rect.bottomRight, rect.bottomRight + Offset(-cornerLen, 0), paint);
    canvas.drawLine(rect.bottomRight, rect.bottomRight + Offset(0, -cornerLen), paint);
  }

  @override
  bool shouldRepaint(_CornerBracketPainter oldDelegate) =>
      color != oldDelegate.color;
}
