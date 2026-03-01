import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';

/// Tip widget แสดงคำแนะนำให้ user วางช้อน/ส้อมข้างจาน
/// ใช้ใน CameraScreen และ ImageAnalysisPreviewScreen
class ReferenceGuideTip extends StatelessWidget {
  /// แสดงแบบกะทัดรัด (1 บรรทัด) หรือแบบเต็ม (มี icon + คำอธิบาย)
  final bool compact;

  /// Callback เมื่อ user กดปิด tip
  final VoidCallback? onDismiss;

  const ReferenceGuideTip({
    super.key,
    this.compact = false,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (compact) return _buildCompact(isDark);
    return _buildFull(isDark);
  }

  Widget _buildCompact(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: AppRadius.pill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: 14,
            color: isDark ? Colors.amber.shade300 : Colors.amber.shade700,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'Place a spoon next to the plate for accurate measurement',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFull(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.amber.shade900.withValues(alpha: 0.2)
            : Colors.amber.shade50,
        borderRadius: AppRadius.lg,
        border: Border.all(
          color: isDark
              ? Colors.amber.shade700.withValues(alpha: 0.3)
              : Colors.amber.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.amber.shade800.withValues(alpha: 0.3)
                  : Colors.amber.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.straighten_rounded,
              size: 20,
              color: isDark ? Colors.amber.shade300 : Colors.amber.shade700,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'More accurate with a reference',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Place a spoon, fork, or credit card next to the plate '
                  'to measure portion size accurately.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: AppSpacing.xs),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close_rounded,
                size: 18,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Tip สำหรับแสดงบน Camera overlay (สีขาวบนพื้นดำ)
class CameraReferenceGuideTip extends StatelessWidget {
  const CameraReferenceGuideTip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: AppRadius.pill,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.straighten_rounded,
            size: 16,
            color: Colors.white70,
          ),
          SizedBox(width: AppSpacing.sm),
          Text(
            'Place cutlery for scale reference',
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
}
