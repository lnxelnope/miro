import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import '../../../core/services/energy_service.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../l10n/app_localizations.dart';
import 'tier_up_overlay.dart';

class ClaimButton extends ConsumerStatefulWidget {
  final int claimableEnergy;
  final VoidCallback? onTierUp;
  final VoidCallback? onClaimed;

  const ClaimButton({
    super.key,
    required this.claimableEnergy,
    this.onTierUp,
    this.onClaimed,
  });

  @override
  ConsumerState<ClaimButton> createState() => _ClaimButtonState();
}

class _ClaimButtonState extends ConsumerState<ClaimButton> {
  late ConfettiController _confettiController;
  bool _isClaiming = false;
  bool _hasClaimed = false;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _handleClaim() async {
    if (_isClaiming || _hasClaimed) return;

    setState(() => _isClaiming = true);

    try {
      final result = await EnergyService.claimDailyEnergy();

      if (result['success'] == true) {
        setState(() => _hasClaimed = true);
        widget.onClaimed?.call();
        _confettiController.play();

        if (mounted) {
          final l10n = L10n.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(l10n.claimButtonReceived('${result['energyClaimed']}')),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        if (result['tierUpgraded'] == true && mounted) {
          final newTier = result['newTier'] as String?;
          final tierReward = (result['tierReward'] as num?)?.toInt() ?? 0;

          if (newTier != null) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => TierUpOverlay(
                newTier: newTier,
                reward: tierReward,
                onDismiss: () => Navigator.of(ctx).pop(),
              ),
            );
          }

          widget.onTierUp?.call();
        }
      } else if (result['alreadyClaimed'] == true) {
        setState(() => _hasClaimed = true);
        if (mounted) {
          final l10n = L10n.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.claimButtonAlreadyClaimed),
              backgroundColor: AppColors.warning,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = L10n.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.claimButtonError('$e')),
              backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isClaiming = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final disabled = _isClaiming || _hasClaimed;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: disabled ? null : _handleClaim,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _hasClaimed
                  ? AppColors.divider
                  : _isClaiming
                      ? AppColors.textTertiary
                      : AppColors.success,
              borderRadius: AppRadius.pill,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isClaiming)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else if (_hasClaimed)
                  Icon(Icons.check, size: 16, color: AppColors.textSecondary)
                else
                  const Icon(AppIcons.energy, size: 14, color: Colors.white),
                SizedBox(width: AppSpacing.xs),
                Text(
                  '+${widget.claimableEnergy}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _hasClaimed ? AppColors.textSecondary : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: -3.14 / 2,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.3,
              colors: const [
                AppColors.success,
                AppColors.info,
                Colors.pink,
                AppColors.warning,
                AppColors.premium,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
