import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../l10n/app_localizations.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.of(context)!.termsOfServiceTitle),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: AppSpacing.xxl),
            _buildSection(
              L10n.of(context)!.termsSectionAcceptanceOfTerms,
              [
                'By downloading, installing, or using MiRO, you agree to be bound by these Terms of Service. If you do not agree, do not use the app.',
              ],
            ),
            _buildSection(
              L10n.of(context)!.termsSectionServiceDescription,
              [
                'MiRO is a nutrition tracking application that uses AI-powered analysis to help estimate nutritional content of food from photos and text descriptions.',
              ],
            ),
            _buildSection(
              L10n.of(context)!.termsSectionDisclaimerOfWarranties,
              [
                '• Nutritional information from AI may not be 100% accurate',
                '• This app is not medical advice — always consult a doctor or registered dietitian for health decisions',
                '• Calorie and macro values are estimates only',
                '• The app is provided "as is" without warranties of any kind',
              ],
            ),
            _buildSection(
              L10n.of(context)!.termsSectionEnergySystemTerms,
              [
                'Energy is the in-app currency used to access AI analysis features.',
                '',
                'Energy Purchase and Usage:',
                '• Energy is purchased through Google Play In-App Purchases',
                '• Energy is non-refundable and non-exchangeable for cash or other goods',
                '• Energy has no expiration date — purchased Energy remains valid indefinitely',
                '• Energy balance is linked to your device and persists across app reinstalls',
                '',
                'Energy Disputes:',
                '• All decisions made by the MiRO system regarding Energy balance are final',
                '• In case of technical errors affecting Energy balance, contact support with transaction details',
                '• We reserve the right to investigate and adjust Energy balances in cases of verified system errors',
                '• Fraudulent attempts to manipulate Energy balance may result in account suspension',
                '',
                'Welcome Offers and Promotions:',
                '• Limited-time offers (e.g., 24-hour welcome discount) are subject to specific terms displayed at time of offer',
                '• Promotional offers cannot be combined with other discounts',
                '• We reserve the right to modify or cancel promotional offers at any time',
              ],
            ),
            _buildSection(
              L10n.of(context)!.termsSectionUserDataAndResponsibilities,
              [
                '• You are responsible for the accuracy of data you enter',
                '• Food data is stored locally on your device',
                '• Energy balance is stored on our server, linked to your device identifier',
                '• You can backup your data (Energy + Food History) using the Backup feature in Settings',
                '• The backup file contains a one-time Transfer Key for moving Energy to a new device',
                '• Photos are NOT included in backup files — they are stored on your device only',
                '• If your photos are backed up via Google Photos or similar services, they may appear automatically on your new device, but this is not guaranteed',
                '• We are NOT responsible for data loss due to:',
                '  - Failure to create a backup before switching devices',
                '  - Lost or shared backup files',
                '  - Expired Transfer Keys (valid for 30 days)',
                '• Transfer Keys are single-use: once redeemed, the key becomes invalid',
                '• Creating a new backup invalidates any previous unused Transfer Key',
              ],
            ),
            _buildSection(
              L10n.of(context)!.termsSectionBackupTransfer,
              [
                '• Backup files contain your food history, settings, and a Transfer Key',
                '• Transfer Keys are valid for 30 days from creation',
                '• Each Transfer Key can only be used once',
                '• Using a Transfer Key transfers ALL Energy from the source device to the destination device (source device Energy becomes 0)',
                '• Only one active Transfer Key can exist per device — creating a new backup invalidates the previous key',
                '• You cannot restore a backup on the same device that created it',
                '• We are not responsible for unauthorized use of your backup file or Transfer Key',
                '• Keep your backup file secure — anyone with the file can redeem your Energy',
              ],
            ),
            _buildSection(
              L10n.of(context)!.termsSectionInAppPurchases,
              [
                '• All Energy purchases are processed through Google Play Billing',
                '• Purchases are non-refundable except as required by applicable law',
                '• Google Play\'s refund policies apply',
                '• Prices are subject to change without notice',
              ],
            ),
            _buildSection(
              L10n.of(context)!.termsSectionProhibitedUses,
              [
                'You agree NOT to:',
                '',
                '• Use the app for any illegal purposes',
                '• Reverse engineer, decompile, or disassemble the app',
                '• Attempt to hack or manipulate the Energy system',
                '• Share or sell your account or Energy balance',
                '• Use automated tools or bots to access the app',
              ],
            ),
            _buildSection(
              L10n.of(context)!.termsSectionIntellectualProperty,
              [
                '• All app code, UI design, and content are proprietary and protected by copyright',
                '• The MiRO name and logo are trademarks',
                '• You may not copy, modify, or distribute app content without permission',
              ],
            ),
            _buildSection(
              L10n.of(context)!.termsSectionLimitationOfLiability,
              [
                'To the maximum extent permitted by law:',
                '',
                '• We are not liable for any damages arising from app use or inability to use',
                '• We are not liable for loss of data due to app uninstallation or device failure',
                '• Our total liability shall not exceed the amount you paid for Energy in the past 3 months',
              ],
            ),
            _buildSection(
              L10n.of(context)!.termsSectionServiceTermination,
              [
                '• You may stop using the app at any time by uninstalling it',
                '• Uninstalling the app will delete all local data (but Energy balance is preserved on our server)',
                '• We recommend creating a backup before uninstalling to preserve your food history',
                '• We reserve the right to suspend accounts engaged in fraudulent activity',
              ],
            ),
            _buildSection(
              L10n.of(context)!.termsSectionChangesToTerms,
              [
                'We may update these Terms of Service from time to time. Continued use after changes constitutes acceptance of updated terms. Material changes will be communicated through app updates.',
              ],
            ),
            _buildSection(
              L10n.of(context)!.termsSectionGoverningLaw,
              [
                'These terms are governed by the laws of Thailand, without regard to conflict of law principles.',
              ],
            ),
            _buildSection(
              L10n.of(context)!.termsSectionContactUs,
              [
                'For questions, support, or to report issues, please contact us through Google Play Store.',
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: AppRadius.sm,
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber,
                      color: AppColors.warning, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      L10n.of(context)!.termsAcknowledgment,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.warning,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              L10n.of(context)!.termsLastUpdated,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
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
          L10n.of(context)!.termsOfServiceTitle,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          L10n.of(context)!.termsSubtitle,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
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
        const SizedBox(height: AppSpacing.sm),
        ...content.map((line) {
          if (line.isEmpty) {
            return const SizedBox(height: 8);
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              line,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
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
