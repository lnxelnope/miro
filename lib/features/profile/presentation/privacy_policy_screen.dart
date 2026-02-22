import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.of(context)!.privacyPolicyTitle),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            SizedBox(height: AppSpacing.xxl),
            _buildSection(
              L10n.of(context)!.privacyPolicySectionInformationWeCollect,
              [
                'MiRO stores the following data locally on your device (Offline-first):',
                '',
                '• Food entries (name, calories, nutrients)',
                '• Food photos (stored locally on your device)',
                '• Health goals (kcal, macros)',
                '• Basic personal information (name, gender, age, weight, height)',
                '• Created meal recipes (My Meals)',
                '• Saved ingredients (Ingredients)',
                '• Energy balance (for AI features)',
                '• Energy purchase history (via Google Play)',
              ],
            ),
            _buildSection(
              L10n.of(context)!.privacyPolicySectionDataStorage,
              [
                '• All food data and personal information stored locally on your device (Local database)',
                '• Energy balance synchronized with Firebase Firestore for cross-device persistence',
                '• No cloud backup of food data (if you uninstall the app, local food data will be lost)',
                '• You can delete all local data anytime (Profile → Clear Data)',
              ],
            ),
            _buildSection(
              L10n.of(context)!.privacyPolicySectionDataTransmission,
              [
                'In-App Purchase',
                '',
                '• Purchase data → Processed via Google Play Billing',
                '• Payment information is handled by Google, not by us',
                '• We only store Product ID and Purchase Token to verify purchases',
                '',
                'Firebase Services',
                '',
                '• Device ID → Used to manage Energy balance and prevent fraudulent usage',
                '• Cloud Functions → Process AI requests and manage Energy deduction',
                '• Firestore → Stores Energy balance for cross-device synchronization',
                '',
                'Firebase Analytics (Optional - Requires User Consent)',
                '',
                '• App events → Screen views, feature usage, and user interactions',
                '• Device information → Device model, OS version, screen resolution',
                '• Aggregated statistics → Usage patterns to improve app functionality',
                '',
                'What we DO NOT collect:',
                '',
                '• Food entries, food photos, or nutrition data',
                '• Personal health information (weight, height, goals)',
                '• Personal identifiers (name, email, phone number)',
                '• Location data',
                '',
                'Purpose: Improve app performance, understand feature usage, and optimize user experience.',
                'Your Choice: You can opt-in or opt-out of analytics at any time in Profile → Settings.',
              ],
            ),
            _buildSection(
              L10n.of(context)!.privacyPolicySectionRequiredPermissions,
              [
                'MiRO requests the following permissions:',
                '',
                '• Camera: Take food photos for AI analysis',
                '• Photos/Gallery: Select food photos from gallery',
                '• Internet: Send photos to AI API and sync Energy balance',
              ],
            ),
            _buildSection(
              L10n.of(context)!.privacyPolicySectionSecurity,
              [
                '• Energy transactions secured via Firebase with device authentication',
                '• Local data stored in encrypted Local Database (Isar)',
                '• Firebase Analytics used for app improvement (requires user consent)',
                '• No advertising or third-party tracking SDKs',
                '• Payment processing handled securely by Google Play Billing',
                '• All data transmission encrypted via HTTPS',
              ],
            ),
            _buildSection(
              L10n.of(context)!.privacyPolicySectionUserRights,
              [
                '• Delete all local data anytime',
                '• Uninstall the app to remove all local data',
                '• Energy balance persists across app reinstalls (linked to your device)',
                '• Request Energy data deletion by contacting support',
              ],
            ),
            _buildSection(
              L10n.of(context)!.privacyPolicySectionDataRetention,
              [
                '• Local food data: Retained until you delete it or uninstall the app',
                '• Energy balance: Retained indefinitely (linked to your device)',
                '• Purchase records: Retained as required by Google Play and tax regulations',
              ],
            ),
            _buildSection(
              L10n.of(context)!.privacyPolicySectionChildrenPrivacy,
              [
                'MiRO is not intended for children under 13 years of age. We do not knowingly collect personal information from children.',
              ],
            ),
            _buildSection(
              L10n.of(context)!.privacyPolicySectionChangesToPolicy,
              [
                'We may update this Privacy Policy from time to time. Changes will be communicated through app updates. Continued use of the app after changes constitutes acceptance of the updated policy.',
              ],
            ),
            _buildSection(
              L10n.of(context)!.privacyPolicySectionDataCollectionConsent,
              [
                'Analytics Opt-In/Opt-Out',
                '',
                'You have full control over analytics data collection:',
                '',
                '• Upon first app use, you\'ll be asked to consent to Firebase Analytics',
                '• You can decline and still use all app features normally',
                '• You can change your preference anytime in Profile → Settings → Analytics Data Collection',
                '• Declining analytics does not affect any core functionality',
                '',
                'What Happens When You Opt-In',
                '',
                '• App usage patterns are collected (anonymously)',
                '• No food data, photos, or health information is collected',
                '• Data is aggregated and cannot identify individual users',
                '• Used solely to improve app performance and user experience',
                '',
                'What Happens When You Opt-Out',
                '',
                '• No analytics data is collected',
                '• All app features remain fully functional',
                '• Energy system, AI analysis, and purchases work normally',
              ],
            ),
            _buildSection(
              L10n.of(context)!.privacyPolicySectionPDPACompliance,
              [
                'Your Rights',
                '',
                'Under the Personal Data Protection Act (PDPA), you have the right to:',
                '',
                '• Access: Request a copy of your data',
                '• Rectification: Correct inaccurate data',
                '• Erasure: Request deletion of your data',
                '• Portability: Receive your data in a structured format',
                '• Objection: Object to data processing',
                '• Withdraw Consent: Revoke analytics consent at any time',
                '',
                'Data Categories',
                '',
                '• General Data: Device ID, Energy balance, purchase history, app usage (if opted-in)',
                '• Sensitive Data: Health-related information (weight, height, nutrition goals) stored locally only on your device',
                '',
                'How to Exercise Your Rights',
                '',
                '• Delete local data: Profile → Clear Data',
                '• Revoke analytics consent: Profile → Settings → Analytics Data Collection (toggle off)',
                '• Request data deletion: Contact us through Google Play Store',
                '',
                'Data Retention',
                '',
                '• Local data: Until you delete it or uninstall the app',
                '• Energy balance: Retained until you request deletion',
                '• Analytics data: Retained according to Firebase\'s retention policy (opt-out anytime)',
              ],
            ),
            _buildSection(
              L10n.of(context)!.privacyPolicySectionContactUs,
              [
                'If you have questions about this Privacy Policy, please contact us through Google Play Store.',
              ],
            ),
            const SizedBox(height: 16),
            Text(
              L10n.of(context)!.privacyPolicyEffectiveDate,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          L10n.of(context)!.privacyPolicyTitle,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          L10n.of(context)!.privacyPolicySubtitle,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: AppRadius.sm,
            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.privacy_tip, color: AppColors.success, size: 20),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  L10n.of(context)!.privacyPolicyHeaderNote,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<String> content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        ...content.map((line) {
          if (line.isEmpty) {
            return const SizedBox(height: 8);
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              line,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          );
        }),
        SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
