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
                'MIRO collects and stores the following information locally on your device:',
                '',
                '• Health Data: Daily calorie intake, macronutrients (protein, carbs, fat), food entries, meal logs',
                '• User Profile: Age, weight, height, gender, activity level, health goals',
                '• Custom Data: Your personal meals database, custom ingredients, serving sizes',
                '• Gemini API Key: If you choose to use AI features, your API key is stored in secure storage on your device',
              ],
            ),
            _buildSection(
              'How We Store Your Data',
              [
                'All data is stored LOCALLY on your device using Isar database.',
                '',
                '• We DO NOT send your personal data to our servers',
                '• We DO NOT have backend servers or cloud storage',
                '• We DO NOT require account creation or login',
                '• Your data stays on your device and is never uploaded',
              ],
            ),
            _buildSection(
              'Third-Party Services',
              [
                'Google Gemini API (Optional)',
                '',
                'If you choose to use AI food analysis features:',
                '',
                '• You provide your own free Gemini API key',
                '• Food images and text descriptions are sent to Google Gemini API for analysis',
                '• Google\'s privacy policy applies to data sent to their API',
                '• We do not have access to or store your Gemini usage data',
                '• You can revoke or delete your API key at any time',
                '',
                'Learn more: https://ai.google.dev/gemini-api/terms',
              ],
            ),
            _buildSection(
              'Permissions',
              [
                'MIRO requests the following permissions:',
                '',
                '• Camera: To take photos of your food for AI analysis',
                '• Photo Library: To select food photos from your gallery for scanning',
                '• Storage: To read food photos and save app data locally',
                '',
                'These permissions are used ONLY for app functionality and never to access unrelated personal files.',
              ],
            ),
            _buildSection(
              'In-App Purchases',
              [
                'MIRO offers an optional Pro upgrade (\$9.99 one-time purchase):',
                '',
                '• Purchase is managed by Google Play Billing',
                '• Google processes all payment information',
                '• We only receive notification of successful purchase',
                '• Purchase is linked to your Google Play account',
                '• No payment data is stored by MIRO',
              ],
            ),
            _buildSection(
              'Data Security',
              [
                '• Your Gemini API key is stored in secure encrypted storage',
                '• All health data is stored locally in Isar database',
                '• No data transmission to external servers (except Google Gemini API if you enable it)',
                '• You can clear all data anytime from Profile settings',
              ],
            ),
            _buildSection(
              'Analytics and Tracking',
              [
                'MIRO does NOT use:',
                '',
                '• Analytics services',
                '• Advertising networks',
                '• Tracking pixels or cookies',
                '• User behavior monitoring',
                '',
                'We respect your privacy completely.',
              ],
            ),
            _buildSection(
              'Data Deletion',
              [
                'You have full control over your data:',
                '',
                '• All data is stored locally on your device',
                '• You can clear all data from Profile > Data > Clear All Data',
                '• Uninstalling the app permanently deletes all local data',
                '• No data remains on any server (because we don\'t have servers)',
              ],
            ),
            _buildSection(
              'Children\'s Privacy',
              [
                'MIRO is not intended for children under 13. We do not knowingly collect personal information from children under 13.',
              ],
            ),
            _buildSection(
              'Changes to This Policy',
              [
                'We may update this Privacy Policy from time to time. Changes will be posted in the app. Continued use of MIRO constitutes acceptance of the updated policy.',
              ],
            ),
            _buildSection(
              'Contact',
              [
                'If you have questions about this Privacy Policy, you can:',
                '',
                '• Review the app source code (if open source)',
                '• Contact us through the Play Store listing',
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Last updated: February 12, 2026',
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
          'MIRO — My Intake Record Oracle',
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
                  'Your data stays on your device. No cloud, no servers.',
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
        }).toList(),
        const SizedBox(height: 20),
      ],
    );
  }
}
