/// tier_up_overlay.dart
///
/// V3: Tier Up Celebration Overlay
///
/// แสดง full-screen overlay เมื่อ user tier upgrade พร้อม animation
library;

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../l10n/app_localizations.dart';

class TierUpOverlay extends StatefulWidget {
  final String newTier;
  final int reward;
  final VoidCallback onDismiss;

  const TierUpOverlay({
    super.key,
    required this.newTier,
    required this.reward,
    required this.onDismiss,
  });

  @override
  State<TierUpOverlay> createState() => _TierUpOverlayState();
}

class _TierUpOverlayState extends State<TierUpOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    // Auto-dismiss หลัง 3 วิ
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getTierIcon(String tier) {
    const icons = {
      'bronze': '🥉',
      'silver': '🥈',
      'gold': '🥇',
      'diamond': '💎',
    };
    return icons[tier.toLowerCase()] ?? '⭐';
  }

  String _getTierName(BuildContext context, String tier) {
    final l10n = L10n.of(context);
    if (l10n == null) return tier.toUpperCase();
    
    switch (tier.toLowerCase()) {
      case 'bronze':
        return l10n.tierBronze;
      case 'silver':
        return l10n.tierSilver;
      case 'gold':
        return l10n.tierGold;
      case 'diamond':
        return l10n.tierDiamond;
      default:
        return l10n.tierStarter;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    return GestureDetector(
      onTap: widget.onDismiss,
      child: Container(
        color: Colors.black.withValues(alpha: 0.8),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tier icon
                  Text(
                    _getTierIcon(widget.newTier),
                    style: const TextStyle(fontSize: 100),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ยินดีด้วย
                  Text(
                    l10n.tierUpCongratulations,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Tier name
                  Text(
                    l10n.tierUpYouReached(_getTierName(context, widget.newTier)),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Motivation text
                  Text(
                    l10n.tierUpMotivation,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Reward
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxl,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      borderRadius: AppRadius.pill,
                    ),
                    child: Text(
                      l10n.tierUpReward(widget.reward),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
