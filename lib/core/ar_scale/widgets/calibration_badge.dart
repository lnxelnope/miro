import 'package:flutter/material.dart';
import '../constants/ar_scale_enums.dart';
import '../../theme/app_tokens.dart';

/// Badge แสดงสถานะ calibration บนหน้าจอ
/// ใช้บน ImageAnalysisPreviewScreen และ FoodTimelineCard
class CalibrationBadge extends StatelessWidget {
  final CalibrationTier tier;
  final double? plateDiameterCm;
  final bool compact;

  const CalibrationBadge({
    super.key,
    required this.tier,
    this.plateDiameterCm,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (tier == CalibrationTier.none) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.sm : AppSpacing.md,
        vertical: compact ? AppSpacing.xxs : AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: tier.backgroundColor,
        borderRadius: AppRadius.pill,
        border: Border.all(
          color: tier.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            tier.icon,
            size: compact ? 12 : 14,
            color: tier.color,
          ),
          SizedBox(width: compact ? 3 : 5),
          Text(
            _buildLabel(),
            style: TextStyle(
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.w600,
              color: tier.color,
            ),
          ),
        ],
      ),
    );
  }

  String _buildLabel() {
    if (compact) return tier.displayName;

    if (plateDiameterCm != null) {
      return '${tier.displayName} · ${plateDiameterCm!.toStringAsFixed(1)}cm';
    }
    return tier.displayName;
  }
}

/// Badge แบบวงกลมเล็กๆ สำหรับแสดงมุมบนของรูปอาหาร
class CalibrationDot extends StatelessWidget {
  final CalibrationTier tier;
  final double size;

  const CalibrationDot({
    super.key,
    required this.tier,
    this.size = 8,
  });

  @override
  Widget build(BuildContext context) {
    if (tier == CalibrationTier.none) return const SizedBox.shrink();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tier.color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: tier.color.withValues(alpha: 0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
