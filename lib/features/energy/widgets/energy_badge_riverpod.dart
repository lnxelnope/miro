import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_hybrid/core/theme/app_colors.dart';
import 'package:miro_hybrid/core/theme/app_tokens.dart';
import 'package:miro_hybrid/features/energy/presentation/energy_store_screen.dart';
import 'package:miro_hybrid/features/energy/providers/energy_provider.dart';
import 'package:miro_hybrid/core/models/gamification_state.dart';
import 'package:miro_hybrid/features/energy/providers/gamification_provider.dart';

/// Energy Badge — Clean minimal pill design with tier, subscriber & freepass indicator
class EnergyBadgeRiverpod extends ConsumerWidget {
  const EnergyBadgeRiverpod({super.key});

  static const _freepassColor = Color(0xFF2196F3);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final energyAsync = ref.watch(energyBalanceProvider);
    final gamification = ref.watch(gamificationProvider);

    return energyAsync.when(
      data: (balance) => _buildBadge(context, balance, gamification),
      loading: () => _buildShimmer(context),
      error: (error, stack) =>
          _buildBadge(context, 0, gamification, isError: true),
    );
  }

  Widget _buildBadge(
    BuildContext context,
    int balance,
    GamificationState gamification, {
    bool isError = false,
  }) {
    final isSubscriber = gamification.isSubscriber;
    final isFreepassActive = gamification.freepass.isActive;
    final freepassDays = gamification.freepass.totalDays;
    final hasFreepassDays = freepassDays > 0;
    final hasTier = gamification.tier != 'none';

    Color accentColor;
    if (isError) {
      accentColor = AppColors.textSecondary;
    } else if (isSubscriber) {
      accentColor = AppColors.premium;
    } else if (isFreepassActive) {
      accentColor = _freepassColor;
    } else if (balance < 10) {
      accentColor = AppColors.error;
    } else if (balance < 30) {
      accentColor = AppColors.warning;
    } else if (balance < 100) {
      accentColor = AppColors.finance;
    } else {
      accentColor = AppColors.energyHigh;
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const EnergyStoreScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        constraints: const BoxConstraints(minWidth: 50),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.1),
          borderRadius: AppRadius.lg,
          border: (isSubscriber || isFreepassActive)
              ? Border.all(color: accentColor.withValues(alpha: 0.3), width: 1)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (hasTier) ...[
              Icon(gamification.tierIcon, size: 14,
                  color: gamification.tierColor),
              const SizedBox(width: 2),
            ],

            // --- Subscriber: diamond + ∞ ---
            if (isSubscriber) ...[
              Icon(Icons.diamond_rounded, size: 18, color: accentColor),
              const SizedBox(width: 3),
              Text(
                '∞',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                  letterSpacing: -0.3,
                ),
              ),
            ]

            // --- Freepass active: ⚡balance | 🎫 Nd ---
            else if (isFreepassActive) ...[
              Icon(Icons.bolt_rounded, size: 16, color: accentColor),
              const SizedBox(width: 2),
              Text(
                _formatBalance(balance),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                  letterSpacing: -0.3,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Container(
                  width: 1,
                  height: 14,
                  color: accentColor.withValues(alpha: 0.3),
                ),
              ),
              const Icon(Icons.card_membership_rounded, size: 13, color: _freepassColor),
              const SizedBox(width: 2),
              Text(
                '${freepassDays}d',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _freepassColor,
                  letterSpacing: -0.3,
                ),
              ),
            ]

            // --- Normal: ⚡balance (+ freepass dot if banked) ---
            else ...[
              Icon(Icons.bolt_rounded, size: 18, color: accentColor),
              const SizedBox(width: 3),
              Text(
                isError ? '–' : _formatBalance(balance),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                  letterSpacing: -0.3,
                ),
              ),
              // Freepass indicator — only when user has banked days
              if (hasFreepassDays && !isError) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: _freepassColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.card_membership_rounded,
                          size: 10, color: _freepassColor),
                      const SizedBox(width: 2),
                      Text(
                        '$freepassDays',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _freepassColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  static String _formatBalance(int balance) {
    if (balance >= 1000) {
      return '${(balance / 1000).toStringAsFixed(1)}K';
    }
    return balance.toString();
  }

  Widget _buildShimmer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withValues(alpha: 0.08),
        borderRadius: AppRadius.lg,
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt_rounded, size: 18, color: AppColors.textTertiary),
          SizedBox(width: 3),
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
