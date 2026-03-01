import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.of(context)!.privacyPolicyTitle),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, isDark),
            const SizedBox(height: AppSpacing.xxl),
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
              isDark,
            ),
            _buildSection(
              L10n.of(context)!.privacyPolicySectionDataStorage,
              [
                '• All food data and personal information stored locally on your device (Local database)',
                '• Energy balance synchronized with Firebase Firestore for cross-device persistence',
                '• Compact food history backed up during daily Energy claims for cross-device restoration',
                '• Small thumbnail images (~40-80 KB) uploaded after AI analysis for backup',
                '• Full-resolution photos remain on your device only',
                '• You can delete all local data anytime (Profile → Clear Data)',
              ],
              isDark,
            ),
            _buildSection(
              'Cloud Backup & Data Sync',
              [
                'When you claim daily Energy, MiRO syncs a compact backup of your food history:',
                '',
                'What is synced:',
                '• Food entry text data (food name, calories, nutrients, meal type, timestamp)',
                '• Custom meals (recipe name, ingredients, nutrition)',
                '• Small thumbnail images (~40-80 KB) with nutrition metadata',
                '• Health profile (gender, age, weight, height, activity level)',
                '• Nutrition goals (calorie goal, macro targets, meal budgets, cuisine preference)',
                '• AR Scale data (detected object labels, bounding box coordinates, image dimensions, pixel-per-cm calibration ratio)',
                '',
                'What is NOT synced:',
                '• Full-resolution food photos',
                '• Your name or avatar',
                '',
                'Data is identified by an anonymous hashed device ID.',
                'You can restore your food history on a new device using a Recovery Key (viewable in Profile → Account).',
              ],
              isDark,
            ),
            _buildSection(
              'Anonymized AI Training Data',
              [
                'We may use anonymized food images and associated metadata (nutrition labels, detected object bounding boxes, calibration data) to improve AI food recognition models or license to third-party AI/ML companies. This data is:',
                '',
                '• Fully anonymized — no device ID, personal identity, or location data is included',
                '• Stripped of EXIF metadata and any identifying information',
                '• Aggregated at population level — individual users cannot be identified',
                '• Used solely for improving food recognition technology',
                '',
                'You may opt out of AI training data usage by contacting support@tnbgrp.com.',
              ],
              isDark,
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
                '• Cloud Functions → Process AI requests, manage Energy deduction, and handle data sync',
                '• Firestore → Stores Energy balance, compact food history backups, and Recovery Key hashes',
                '• Firebase Storage → Stores small food thumbnail images with nutrition metadata',
                '',
                'Firebase Analytics (Optional - Requires User Consent)',
                '',
                '• App events → Screen views, feature usage, and user interactions',
                '• Device information → Device model, OS version, screen resolution',
                '• Aggregated statistics → Usage patterns to improve app functionality',
                '',
                'What we DO NOT collect:',
                '',
                '• Full-resolution food photos (only small thumbnails ~40-80 KB)',
                '• Personal health information (weight, height, goals)',
                '• Personal identifiers (name, email, phone number)',
                '• Location data',
                '',
                'Purpose: Improve app performance, understand feature usage, and optimize user experience.',
                'Your Choice: You can opt-in or opt-out of analytics at any time in Profile → Settings.',
              ],
              isDark,
            ),
            _buildSection(
              L10n.of(context)!.privacyPolicySectionRequiredPermissions,
              [
                'MiRO requests the following permissions:',
                '',
                '• Camera: Take food photos for AI analysis',
                '• Photos/Gallery: Select food photos from gallery',
                '• Internet: Send photos to AI API and sync Energy balance',
                '• Health Data (optional): Read active energy burned and write dietary nutrition data to Apple Health (iOS) or Google Health Connect (Android)',
              ],
              isDark,
            ),
            _buildSection(
              L10n.of(context)!.privacyPolicySectionHealthData,
              [
                'When you enable Health Sync, MiRO integrates with Apple Health (iOS) or Google Health Connect (Android):',
                '',
                'What we READ (with your permission):',
                '',
                '• Active Energy Burned: Used to display how many calories you have burned today through physical activity',
                '',
                'What we WRITE (with your permission):',
                '',
                '• Dietary Energy (calories, protein, carbs, fat): When you log a meal in MiRO, the nutrition data is sent to your Health App',
                '',
                'Important:',
                '',
                '• Health Sync is optional — you must explicitly enable it',
                '• All health data stays on your device — it is never sent to our servers',
                '• You can disable Health Sync at any time in Settings',
                '• Disabling Health Sync does not delete previously synced data from your Health App',
                '• We only access the specific data types listed above — no heart rate, sleep, weight, or other health metrics',
              ],
              isDark,
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
              isDark,
            ),
            _buildSection(
              L10n.of(context)!.privacyPolicySectionUserRights,
              [
                '• Delete all local data anytime',
                '• Uninstall the app to remove all local data',
                '• Energy balance persists across app reinstalls (linked to your device)',
                '• Request deletion of cloud-synced food history and thumbnails by contacting support',
                '• Request Energy data deletion by contacting support',
              ],
              isDark,
            ),
            _buildSection(
              L10n.of(context)!.privacyPolicySectionDataRetention,
              [
                '• Local food data: Retained until you delete it or uninstall the app',
                '• Cloud-synced food history: Retained for up to 90 days for restoration; deleted upon request',
                '• Thumbnail images: Retained until you request deletion',
                '• Energy balance: Retained indefinitely (linked to your device)',
                '• Purchase records: Retained as required by Google Play and tax regulations',
              ],
              isDark,
            ),
            _buildSection(
              L10n.of(context)!.privacyPolicySectionChildrenPrivacy,
              [
                'MiRO is not intended for children under 13 years of age. We do not knowingly collect personal information from children.',
              ],
              isDark,
            ),
            _buildSection(
              L10n.of(context)!.privacyPolicySectionChangesToPolicy,
              [
                'We may update this Privacy Policy from time to time. Changes will be communicated through app updates. Continued use of the app after changes constitutes acceptance of the updated policy.',
              ],
              isDark,
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
              isDark,
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
                '• General Data: Device ID, Energy balance, purchase history, app usage (if opted-in), compact food history backups, thumbnail images, health profile, nutrition goals',
                '• Sensitive Data: Health-related information (weight, height, nutrition goals) — stored locally and synced as part of cloud backup (identified by anonymous device ID only)',
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
                '• Cloud-synced data: Food history backups retained for 90 days; thumbnails retained until deletion request',
                '• Energy balance: Retained until you request deletion',
                '• Analytics data: Retained according to Firebase\'s retention policy (opt-out anytime)',
              ],
              isDark,
            ),
            _buildSection(
              L10n.of(context)!.privacyPolicySectionContactUs,
              [
                'If you have questions about this Privacy Policy, please contact us through Google Play Store.',
              ],
              isDark,
            ),
            const SizedBox(height: 16),
            Text(
              L10n.of(context)!.privacyPolicyEffectiveDate,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          L10n.of(context)!.privacyPolicyTitle,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          L10n.of(context)!.privacyPolicySubtitle,
          style: TextStyle(
            fontSize: 16,
            color:
                isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
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
              const Icon(Icons.privacy_tip, color: AppColors.success, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  L10n.of(context)!.privacyPolicyHeaderNote,
                  style: const TextStyle(
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

  Widget _buildSection(String title, List<String> content, bool isDark) {
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
                color:
                    isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          );
        }),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
