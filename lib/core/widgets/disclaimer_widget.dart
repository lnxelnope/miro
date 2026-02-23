import 'package:flutter/material.dart';
import '../theme/app_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import 'package:miro_hybrid/features/legal/presentation/disclaimer_screen.dart';

/// Reusable disclaimer widget that can be added to any screen
class DisclaimerWidget extends StatelessWidget {
  final bool compact;
  final bool showFullButton;

  const DisclaimerWidget({
    super.key,
    this.compact = false,
    this.showFullButton = true,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactDisclaimer(context);
    } else {
      return _buildFullDisclaimer(context);
    }
  }

  Widget _buildCompactDisclaimer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
        borderRadius: AppRadius.sm,
      ),
      child: Row(
        children: [
          const Icon(AppIcons.warning, size: 18, color: AppIcons.warningColor),
          const SizedBox(width: AppSpacing.sm),
          const Expanded(
            child: Text(
              'For informational purposes only. Not medical advice.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (showFullButton)
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DisclaimerScreen(),
                  ),
                );
              },
              child: const Text('Details', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildFullDisclaimer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.05),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.2), width: 0.5),
        borderRadius: AppRadius.sm,
      ),
      child: Row(
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(width: AppSpacing.xs + 2),
          const Expanded(
            child: Text(
              'For informational purposes only',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          if (showFullButton)
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DisclaimerScreen(),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xxs),
                child: Text(
                  'Read Disclaimer',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.info,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
