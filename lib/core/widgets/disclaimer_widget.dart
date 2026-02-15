import 'package:flutter/material.dart';
import 'package:miro_hybrid/core/constants/app_disclaimer.dart';
import 'package:miro_hybrid/features/legal/presentation/disclaimer_screen.dart';

/// Reusable disclaimer widget that can be added to any screen
class DisclaimerWidget extends StatelessWidget {
  final bool compact;
  final bool showFullButton;

  const DisclaimerWidget({
    super.key,
    this.compact = false,
    this.showFullButton = true,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactDisclaimer(context);
    } else {
      return _buildFullDisclaimer(context);
    }
  }

  Widget _buildCompactDisclaimer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'For informational purposes only. Not medical advice.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          if (showFullButton)
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DisclaimerScreen(),
                  ),
                );
              },
              child: const Text('Details', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildFullDisclaimer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        border: Border.all(color: Colors.orange.withOpacity(0.2), width: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Text('⚠️', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'For informational purposes only',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          if (showFullButton)
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const DisclaimerScreen(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Text(
                  'Read Disclaimer',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue.shade600,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
