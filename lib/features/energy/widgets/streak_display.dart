import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_hybrid/core/theme/app_icons.dart';
import 'package:miro_hybrid/core/theme/app_colors.dart';
import 'package:miro_hybrid/core/theme/app_tokens.dart';
import 'package:miro_hybrid/features/energy/providers/gamification_provider.dart';
import 'package:miro_hybrid/features/energy/presentation/tier_benefits_screen.dart';

class StreakDisplay extends ConsumerWidget {
  const StreakDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamification = ref.watch(gamificationProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lg,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with info button
            Row(
              children: [
                const Icon(AppIcons.streak, size: 28, color: AppIcons.streakColor),
                const SizedBox(width: 8),
                Text(
                  '${gamification.currentStreak} days',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Info button
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TierBenefitsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.info_outline,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  tooltip: 'View Tier Benefits',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Tier badge
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TierBenefitsScreen(),
                  ),
                );
              },
              borderRadius: AppRadius.md,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: gamification.tierColor.withValues(alpha: 0.1),
                  borderRadius: AppRadius.md,
                  border: Border.all(
                    color: gamification.tierColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      gamification.tierIcon,
                      size: 24,
                      color: gamification.tierColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${gamification.tierName} Tier',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: gamification.tierColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: gamification.tierColor.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Progress to next tier
            if (gamification.tier != 'diamond')
              Text(
                '${gamification.daysToNextTier} days until next tier',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            // Grace period info
            if (gamification.graceDays > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    size: 16,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Grace period: ${gamification.graceDays} day(s)',
                    style: const TextStyle(
                      color: AppColors.info,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
