import 'package:flutter/material.dart';
import 'package:miro_hybrid/core/services/consent_service.dart';
import 'package:miro_hybrid/core/services/analytics_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// Dialog requesting user consent for Firebase Analytics
/// Complies with GDPR, PDPA, and Google Play policies
class AnalyticsConsentDialog extends StatelessWidget {
  const AnalyticsConsentDialog({super.key});

  /// Show the consent dialog
  static Future<void> show(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Must choose
      builder: (context) => const AnalyticsConsentDialog(),
    );
  }

  Future<void> _openPrivacyPolicy() async {
    const url = 'https://lnxelnope.github.io/miro/privacy-policy.html';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _handleAccept(BuildContext context) async {
    await ConsentService.grantConsent();
    await AnalyticsService.setAnalyticsEnabled(true);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleDecline(BuildContext context) async {
    await ConsentService.revokeConsent();
    await AnalyticsService.setAnalyticsEnabled(false);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.privacy_tip_outlined,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Usage Data',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'We use Firebase Analytics to improve your app experience',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.grey[900],
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.check_circle_outline,
              text: 'What we collect: Feature usage, screens viewed',
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.block,
              text: 'Not collected: Food data, photos, health info',
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.shield_outlined,
              text: 'Data is aggregated and anonymous',
              isDark: isDark,
            ),
            const SizedBox(height: 16),
            Text(
              'You can change this anytime in Profile → Settings',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
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
        TextButton(
          onPressed: () => _handleDecline(context),
          child: Text(
            'Decline',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
        FilledButton(
          onPressed: () => _handleAccept(context),
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text(
            'Accept',
            style: TextStyle(fontSize: 15),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? Colors.green[300] : Colors.green[700],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[300] : Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }
}
