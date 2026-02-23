import 'package:flutter/material.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';

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
        borderRadius: AppRadius.xxl,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
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
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 8),
            // Message
            Text(
              'You got $bonusAmount Energy!',
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Energy display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: AppRadius.lg,
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(AppIcons.energy, size: 28, color: AppIcons.energyColor),
                  const SizedBox(width: 8),
                  Text(
                    '+$bonusAmount',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
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
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.md,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Awesome! ', style: TextStyle(fontSize: 16)),
                    Icon(AppIcons.celebration, size: 18, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.05),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
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
