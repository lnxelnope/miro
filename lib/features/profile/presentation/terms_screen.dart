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
                'By downloading, installing, or using MIRO, you agree to these Terms of Service. If you do not agree, please do not use the app.',
              ],
            ),
            _buildSection(
              'Description of Service',
              [
                'MIRO is a calorie and nutrition tracking application that:',
                '',
                '• Helps you log daily food intake',
                '• Calculates calories and macronutrients',
                '• Provides AI-powered food analysis (optional, requires your own Gemini API key)',
                '• Stores all data locally on your device',
              ],
            ),
            _buildSection(
              'Medical Disclaimer',
              [
                '⚠️ IMPORTANT: MIRO IS NOT MEDICAL ADVICE',
                '',
                '• All nutritional information provided is an ESTIMATE only',
                '• AI analysis may contain errors or inaccuracies',
                '• Do not use MIRO as a substitute for professional medical advice, diagnosis, or treatment',
                '• Always consult a qualified healthcare provider for medical questions',
                '• MIRO is not intended to diagnose, treat, cure, or prevent any disease',
                '',
                'You are solely responsible for your health decisions.',
              ],
            ),
            _buildSection(
              'User Responsibilities',
              [
                'You are responsible for:',
                '',
                '• The accuracy of data you enter',
                '• Obtaining and maintaining your own Gemini API key (if using AI features)',
                '• Complying with Google\'s Gemini API Terms of Service',
                '• Keeping your API key secure and confidential',
                '• All costs associated with your Gemini API usage',
                '• Understanding that Gemini 2.0 Flash has a free tier, but usage beyond free limits may incur charges from Google',
              ],
            ),
            _buildSection(
              'Free and Pro Tiers',
              [
                'Free Tier:',
                '• 3 AI food analyses per day',
                '• Unlimited manual food logging',
                '• Full access to nutrition dashboard',
                '• Local database storage',
                '',
                'Pro Tier (\$9.99 one-time purchase):',
                '• Unlimited AI food analyses',
                '• All Free tier features',
                '• Non-consumable purchase (buy once, use forever)',
                '• No subscription, no recurring charges',
              ],
            ),
            _buildSection(
              'In-App Purchases',
              [
                '• All purchases are processed through Google Play',
                '• Purchases are non-refundable except as required by law',
                '• Pro purchase is linked to your Google Play account',
                '• You can restore your purchase on new devices using "Restore Purchase" button',
                '• We reserve the right to change pricing for future buyers',
              ],
            ),
            _buildSection(
              'Data Ownership',
              [
                '• You own all data you enter into MIRO',
                '• All data is stored locally on your device',
                '• We do not claim ownership of your personal data',
                '• You can export or delete your data at any time',
                '• Uninstalling the app will permanently delete all local data',
              ],
            ),
            _buildSection(
              'Gemini API Key',
              [
                'If you choose to use AI features:',
                '',
                '• You must provide your own Gemini API key',
                '• You are responsible for obtaining the key from Google AI Studio',
                '• You agree to Google\'s Gemini API Terms of Service',
                '• MIRO does not provide, manage, or monitor your API usage',
                '• If your key is compromised, revoke it immediately and create a new one',
                '• We are not responsible for any charges incurred from your API usage',
              ],
            ),
            _buildSection(
              'Accuracy of Information',
              [
                '• Nutritional data is sourced from public databases and user input',
                '• AI estimates may vary from actual nutritional content',
                '• Portion sizes are estimates and may not be exact',
                '• We do not guarantee the accuracy of any nutritional information',
                '• Always verify information with original food packaging or reliable sources',
              ],
            ),
            _buildSection(
              'Limitation of Liability',
              [
                'TO THE MAXIMUM EXTENT PERMITTED BY LAW:',
                '',
                '• MIRO is provided "AS IS" without warranties of any kind',
                '• We are not liable for any damages arising from use of the app',
                '• We are not liable for inaccurate nutritional information',
                '• We are not liable for health consequences of dietary decisions',
                '• We are not liable for data loss (though all data is local)',
                '• We are not liable for Gemini API costs or service interruptions',
              ],
            ),
            _buildSection(
              'Service Availability',
              [
                '• MIRO is an offline-first app and works without internet',
                '• AI features require internet and a valid Gemini API key',
                '• We do not guarantee continuous, uninterrupted access',
                '• Google may change or discontinue Gemini API at any time',
              ],
            ),
            _buildSection(
              'Changes to Service',
              [
                'We reserve the right to:',
                '',
                '• Modify or discontinue features at any time',
                '• Update pricing for new purchases',
                '• Change these Terms of Service',
                '',
                'Continued use after changes constitutes acceptance of new terms.',
              ],
            ),
            _buildSection(
              'Termination',
              [
                '• You may stop using MIRO at any time by uninstalling the app',
                '• We may terminate or suspend service at any time',
                '• Upon termination, all local data will be deleted when you uninstall',
              ],
            ),
            _buildSection(
              'Governing Law',
              [
                'These Terms are governed by applicable laws in your jurisdiction. Any disputes shall be resolved in accordance with local laws.',
              ],
            ),
            _buildSection(
              'Contact',
              [
                'For questions about these Terms of Service:',
                '',
                '• Contact us through the Play Store listing',
                '• Review our Privacy Policy for data-related questions',
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
                      'By using MIRO, you acknowledge that you have read, understood, and agree to these Terms of Service.',
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
          'Terms of Service',
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
