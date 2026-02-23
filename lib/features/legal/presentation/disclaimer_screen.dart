import 'package:flutter/material.dart';
import 'package:miro_hybrid/core/constants/app_disclaimer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../l10n/app_localizations.dart';

class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.of(context)!.disclaimerHealthDisclaimer),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        foregroundColor: isDark ? AppColors.textPrimaryDark : Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '⚠️',
                    style: TextStyle(fontSize: 48),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: AppSpacing.xxl),
            
            Text(
              AppDisclaimer.full,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: isDark ? AppColors.textPrimaryDark : Colors.black87,
              ),
            ),
            
            const SizedBox(height: AppSpacing.xxxl),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: AppRadius.md,
                border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    L10n.of(context)!.disclaimerImportantReminders,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.info,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildBulletPoint(L10n.of(context)!.disclaimerBullet1),
                  _buildBulletPoint(L10n.of(context)!.disclaimerBullet2),
                  _buildBulletPoint(L10n.of(context)!.disclaimerBullet3),
                  _buildBulletPoint(L10n.of(context)!.disclaimerBullet4),
                  _buildBulletPoint(L10n.of(context)!.disclaimerBullet5),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.xxxl),
            
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : AppColors.textPrimary,
                  foregroundColor: isDark ? AppColors.textPrimary : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.md,
                  ),
                ),
                child: Text(
                  L10n.of(context)!.disclaimerIUnderstand,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.info,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.info,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
