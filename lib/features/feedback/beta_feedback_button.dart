import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import 'dart:io';

/// Floating feedback button for closed beta testing
/// TODO: Remove before public launch
class BetaFeedbackButton extends StatefulWidget {
  const BetaFeedbackButton({super.key});

  @override
  State<BetaFeedbackButton> createState() => _BetaFeedbackButtonState();
}

class _BetaFeedbackButtonState extends State<BetaFeedbackButton> {
  static const String _keyDeviceInfo = 'beta_device_info';

  void _showFeedbackSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FeedbackSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      bottom: 80, // Above bottom navigation
      child: FloatingActionButton.extended(
        heroTag: 'betaFeedback',
        onPressed: _showFeedbackSheet,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.feedback, size: 20),
        label: const Text('Beta Feedback', style: TextStyle(fontSize: 12)),
      ),
    );
  }
}

class _FeedbackSheet extends StatefulWidget {
  @override
  State<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<_FeedbackSheet> {
  static const String _keyDeviceInfo = 'beta_device_info';
  
  final _deviceController = TextEditingController();
  final _feedbackController = TextEditingController();
  String _selectedCategory = 'Bug';
  bool _isLoading = false;

  final List<String> _categories = [
    'Bug',
    'Suggestion',
    'Health',
    'Feedback',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  @override
  void dispose() {
    _deviceController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _loadDeviceInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDevice = prefs.getString(_keyDeviceInfo);
    
    if (savedDevice != null && savedDevice.isNotEmpty) {
      _deviceController.text = savedDevice;
    } else {
      // Auto-detect basic device info
      final platform = Platform.isAndroid ? 'Android' : Platform.isIOS ? 'iOS' : 'Unknown';
      _deviceController.text = platform;
    }
  }

  Future<void> _saveDeviceInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDeviceInfo, _deviceController.text.trim());
  }

  Future<void> _sendFeedback() async {
    final device = _deviceController.text.trim();
    final feedback = _feedbackController.text.trim();

    if (device.isEmpty || feedback.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in device and feedback')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Save device info for next time
    await _saveDeviceInfo();

    // Compose email
    final subject = Uri.encodeComponent('[MIRO Beta] [$_selectedCategory] Feedback');
    final body = Uri.encodeComponent('''
Device: $device

Category: $_selectedCategory

Feedback:
$feedback

---
Sent from MIRO Beta App
    '''.trim());

    final emailUrl = 'mailto:lnxelnope@gmail.com?subject=$subject&body=$body';

    try {
      final uri = Uri.parse(emailUrl);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      
      if (launched) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Email app opened! Thank you for your feedback.'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        throw 'Could not launch email app';
      }
    } catch (e) {
      if (!mounted) return;
      
      // Show fallback dialog with email details
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Email App Found'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Please send your feedback manually to:'),
                const SizedBox(height: 12),
                const SelectableText(
                  'lnxelnope@gmail.com',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const SizedBox(height: 12),
                const Text('Subject:', style: TextStyle(fontWeight: FontWeight.w600)),
                SelectableText('[MIRO Beta] [$_selectedCategory] Feedback'),
                const SizedBox(height: 12),
                const Text('Message:', style: TextStyle(fontWeight: FontWeight.w600)),
                SelectableText('''
Device: $device

Category: $_selectedCategory

Feedback:
$feedback
                '''.trim()),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Row(
              children: [
                const Icon(Icons.feedback, color: Colors.orange, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Beta Feedback',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'BETA',
                    style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Help us improve MIRO! Share bugs, suggestions, or feedback.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Device info
            TextField(
              controller: _deviceController,
              decoration: InputDecoration(
                labelText: 'Device (saved for next time)',
                hintText: 'e.g., Samsung Galaxy S23',
                prefixIcon: const Icon(Icons.phone_android, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // Category
            const Text('Category', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedCategory = category);
                  },
                  selectedColor: Colors.orange.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.orange : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Feedback text
            TextField(
              controller: _feedbackController,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: 'Your Feedback',
                hintText: 'Describe the issue, suggestion, or feedback...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            // Send button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _sendFeedback,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send),
                label: Text(_isLoading ? 'Opening email...' : 'Send via Email'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Opens your email app or shows copy dialog',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
