import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSection(
              'Information We Collect',
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
              'Data Storage',
              [
                '• All food data and personal information stored locally on your device (Local database)',
                '• Energy balance synchronized with Firebase Firestore for cross-device persistence',
                '• No cloud backup of food data (if you uninstall the app, local food data will be lost)',
                '• You can delete all local data anytime (Profile → Clear Data)',
              ],
            ),
            _buildSection(
              'Data Transmission to Third Parties',
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
              ],
            ),
            _buildSection(
              'Required Permissions',
              [
                'MiRO requests the following permissions:',
                '',
                '• Camera: Take food photos for AI analysis',
                '• Photos/Gallery: Select food photos from gallery',
                '• Internet: Send photos to AI API and sync Energy balance',
              ],
            ),
            _buildSection(
              'Security',
              [
                '• Energy transactions secured via Firebase with device authentication',
                '• Local data stored in encrypted Local Database (Isar)',
                '• No analytics, tracking, or advertising SDKs',
                '• Payment processing handled securely by Google Play Billing',
              ],
            ),
            _buildSection(
              'User Rights',
              [
                '• Delete all local data anytime',
                '• Uninstall the app to remove all local data',
                '• Energy balance persists across app reinstalls (linked to your device)',
                '• Request Energy data deletion by contacting support',
              ],
            ),
            _buildSection(
              'Data Retention',
              [
                '• Local food data: Retained until you delete it or uninstall the app',
                '• Energy balance: Retained indefinitely (linked to your device)',
                '• Purchase records: Retained as required by Google Play and tax regulations',
              ],
            ),
            _buildSection(
              'Children\'s Privacy',
              [
                'MiRO is not intended for children under 13 years of age. We do not knowingly collect personal information from children.',
              ],
            ),
            _buildSection(
              'Changes to This Policy',
              [
                'We may update this Privacy Policy from time to time. Changes will be communicated through app updates. Continued use of the app after changes constitutes acceptance of the updated policy.',
              ],
            ),
            _buildSection(
              'Contact Us',
              [
                'If you have questions about this Privacy Policy, please contact us through Google Play Store.',
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Effective Date: February 13, 2026',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Privacy Policy',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'MiRO — My Intake Record Oracle',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.privacy_tip, color: Colors.green.shade700, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your food data stays on your device. Energy balance synced securely via Firebase.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.green.shade900,
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
                color: Colors.grey.shade800,
                height: 1.5,
              ),
            ),
          );
        }),
        const SizedBox(height: 20),
      ],
    );
  }
}
