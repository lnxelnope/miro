import 'package:flutter/material.dart';
import '../../../core/database/database_service.dart';
import 'package:miro_hybrid/core/services/consent_service.dart';
import 'package:miro_hybrid/core/services/analytics_service.dart';
import 'package:miro_hybrid/core/theme/app_colors.dart';
import 'package:miro_hybrid/core/theme/app_tokens.dart';
import 'package:miro_hybrid/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Combined consent dialog for Analytics + Food Research
/// Shown on first app open after onboarding
class AnalyticsConsentDialog extends StatefulWidget {
  const AnalyticsConsentDialog({super.key});

  static Future<void> show(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AnalyticsConsentDialog(),
    );
  }

  @override
  State<AnalyticsConsentDialog> createState() => _AnalyticsConsentDialogState();
}

class _AnalyticsConsentDialogState extends State<AnalyticsConsentDialog> {
  bool _analyticsEnabled = true;
  bool _foodResearchEnabled = false;

  Future<void> _openPrivacyPolicy() async {
    const url = 'https://lnxelnope.github.io/arcal/privacy-policy.html';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _handleConfirm() async {
    // Analytics
    if (_analyticsEnabled) {
      await ConsentService.grantConsent();
      await AnalyticsService.setAnalyticsEnabled(true);
    } else {
      await ConsentService.revokeConsent();
      await AnalyticsService.setAnalyticsEnabled(false);
    }

    // Food Research
    try {
      final profile = await (DatabaseService.db.select(DatabaseService.db.userProfiles)..where((tbl) => tbl.id.equals(1))).getSingleOrNull();
      if (profile != null) {
        profile.foodResearchConsent = _foodResearchEnabled;
        profile.foodResearchConsentAt =
            _foodResearchEnabled ? DateTime.now() : null;
        profile.updatedAt = DateTime.now();
        await DatabaseService.db.into(DatabaseService.db.userProfiles).insertOnConflictUpdate(profile);
      }
    } catch (_) {}

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = L10n.of(context)!;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      title: Row(
        children: [
          Icon(Icons.privacy_tip_outlined,
              color: theme.colorScheme.primary, size: 28),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              l10n.consentDialogTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Analytics Section ──
            _buildSectionHeader(
              icon: Icons.analytics_outlined,
              title: l10n.consentAnalyticsSection,
              isDark: isDark,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.consentAnalyticsDescription,
              style: TextStyle(
                fontSize: 14,
                color:
                    isDark ? AppColors.textSecondaryDark : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildInfoRow(
                icon: Icons.check_circle_outline,
                text: l10n.consentAnalyticsCollect,
                isDark: isDark),
            const SizedBox(height: 4),
            _buildInfoRow(
                icon: Icons.block,
                text: l10n.consentAnalyticsNotCollect,
                isDark: isDark),
            const SizedBox(height: 4),
            _buildInfoRow(
                icon: Icons.shield_outlined,
                text: l10n.consentAnalyticsAnonymous,
                isDark: isDark),
            const SizedBox(height: AppSpacing.sm),
            _buildToggleRow(
              value: _analyticsEnabled,
              onChanged: (v) => setState(() => _analyticsEnabled = v),
              isDark: isDark,
            ),

            const SizedBox(height: AppSpacing.lg),
            Divider(color: isDark ? Colors.white12 : Colors.black12),
            const SizedBox(height: AppSpacing.md),

            // ── Food Research Section ──
            _buildSectionHeader(
              icon: Icons.science_outlined,
              title: l10n.consentFoodResearchSection,
              isDark: isDark,
              color: AppColors.premium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.foodResearchDialogDescription,
              style: TextStyle(
                fontSize: 14,
                color:
                    isDark ? AppColors.textSecondaryDark : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildInfoRow(
                icon: Icons.check_circle_outline,
                text: '✅ ${l10n.foodResearchAnalyze1}',
                isDark: isDark),
            const SizedBox(height: 4),
            _buildInfoRow(
                icon: Icons.block,
                text: '❌ ${l10n.foodResearchSkip1}',
                isDark: isDark),
            const SizedBox(height: 4),
            Text(
              l10n.foodResearchPrivacyNote,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white38 : AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildToggleRow(
              value: _foodResearchEnabled,
              onChanged: (v) => setState(() => _foodResearchEnabled = v),
              isDark: isDark,
            ),

            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.consentChangeAnytime,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white38 : AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            InkWell(
              onTap: _openPrivacyPolicy,
              child: Text(
                'Read full Privacy Policy',
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: _handleConfirm,
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxl, vertical: AppSpacing.md),
          ),
          child: Text(l10n.confirm, style: const TextStyle(fontSize: 15)),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required bool isDark,
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? AppColors.success),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Align(
      alignment: Alignment.centerRight,
      child: Switch(value: value, onChanged: onChanged),
    );
  }
}
