import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildSection(
              'Acceptance of Terms',
              [
                'By downloading, installing, or using Miro Cal, you agree to be bound by these Terms of Service. If you do not agree, do not use the app.',
              ],
            ),
            _buildSection(
              'Service Description',
              [
                'Miro Cal is a nutrition tracking application that uses AI-powered analysis to help estimate nutritional content of food from photos and text descriptions.',
              ],
            ),
            _buildSection(
              'Disclaimer of Warranties',
              [
                '• Nutritional information from AI may not be 100% accurate',
                '• This app is not medical advice — always consult a doctor or registered dietitian for health decisions',
                '• Calorie and macro values are estimates only',
                '• The app is provided "as is" without warranties of any kind',
              ],
            ),
            _buildSection(
              'Energy System Terms',
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
                '• All decisions made by the Miro Cal system regarding Energy balance are final',
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
              'User Data and Responsibilities',
              [
                '• You are responsible for the accuracy of data you enter',
                '• The app does not provide cloud backup — uninstalling the app will delete local food data',
                '• Energy balance is preserved across reinstalls (linked to your device)',
                '• We recommend regularly exporting your data (when feature is available)',
              ],
            ),
            _buildSection(
              'In-App Purchases',
              [
                '• All Energy purchases are processed through Google Play Billing',
                '• Purchases are non-refundable except as required by applicable law',
                '• Google Play\'s refund policies apply',
                '• Prices are subject to change without notice',
              ],
            ),
            _buildSection(
              'Prohibited Uses',
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
              'Intellectual Property',
              [
                '• All app code, UI design, and content are proprietary and protected by copyright',
                '• The Miro Cal name and logo are trademarks',
                '• You may not copy, modify, or distribute app content without permission',
              ],
            ),
            _buildSection(
              'Limitation of Liability',
              [
                'To the maximum extent permitted by law:',
                '',
                '• We are not liable for any damages arising from app use or inability to use',
                '• We are not liable for loss of data due to app uninstallation or device failure',
                '• Our total liability shall not exceed the amount you paid for Energy in the past 3 months',
              ],
            ),
            _buildSection(
              'Service Termination',
              [
                '• You may stop using the app at any time by uninstalling it',
                '• Uninstalling the app will delete all local data (but Energy balance is preserved)',
                '• We reserve the right to suspend accounts engaged in fraudulent activity',
              ],
            ),
            _buildSection(
              'Changes to Terms',
              [
                'We may update these Terms of Service from time to time. Continued use after changes constitutes acceptance of updated terms. Material changes will be communicated through app updates.',
              ],
            ),
            _buildSection(
              'Governing Law',
              [
                'These terms are governed by the laws of Thailand, without regard to conflict of law principles.',
              ],
            ),
            _buildSection(
              'Contact Us',
              [
                'For questions, support, or to report issues, please contact us through Google Play Store.',
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'By using Miro Cal, you acknowledge that you have read, understood, and agree to these Terms of Service.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
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
          'Terms of Service',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Miro Cal — AI-Powered Nutrition Tracker',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
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
