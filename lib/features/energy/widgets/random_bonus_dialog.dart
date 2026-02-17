import 'package:flutter/material.dart';
import '../../../core/theme/app_icons.dart';

class RandomBonusDialog extends StatelessWidget {
  final int bonusAmount;

  const RandomBonusDialog({
    super.key,
    required this.bonusAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Icon(
              AppIcons.randomBonus,
              size: 80,
              color: AppIcons.randomBonusColor,
            ),
            const SizedBox(height: 16),
            // Title
            const Text(
              'LUCKY!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            // Message
            Text(
              'You got $bonusAmount Energy!',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Energy display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.orange.shade200,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(AppIcons.energy, size: 28, color: AppIcons.energyColor),
                  const SizedBox(width: 8),
                  Text(
                    '+$bonusAmount',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Awesome! ', style: TextStyle(fontSize: 16)),
                    Icon(AppIcons.celebration, size: 18, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void show(BuildContext context, int bonusAmount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => RandomBonusDialog(bonusAmount: bonusAmount),
    );
  }
}
