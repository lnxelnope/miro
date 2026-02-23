import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/services/energy_service.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/database/database_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../energy/providers/energy_provider.dart';
import '../presentation/energy_store_screen.dart';

/// Dialog shown when Energy runs out
///
/// Returns true if the user watched a rewarded ad successfully,
/// so the caller can retry the operation without spending energy.
class NoEnergyDialog extends ConsumerStatefulWidget {
  final VoidCallback? onAdWatched;

  const NoEnergyDialog({super.key, this.onAdWatched});

  @override
  ConsumerState<NoEnergyDialog> createState() => _NoEnergyDialogState();

  /// Show the dialog. Returns true if user watched a rewarded ad.
  static Future<bool> show(BuildContext context, {VoidCallback? onAdWatched}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => NoEnergyDialog(onAdWatched: onAdWatched),
    );
    return result ?? false;
  }
}

class _NoEnergyDialogState extends ConsumerState<NoEnergyDialog> {
  final AdService _adService = AdService();
  bool _isLoadingAd = false;
  int _remainingAds = 3;

  @override
  void initState() {
    super.initState();
    _initAd();
  }

  Future<void> _initAd() async {
    await _adService.initialize();
    if (mounted) {
      setState(() => _remainingAds = _adService.remainingAds);
    }
  }

  Future<void> _handleWatchAd() async {
    if (_isLoadingAd || !_adService.canWatchAd) return;
    setState(() => _isLoadingAd = true);

    try {
      final reward = await _adService.showRewardedAd();

      if (reward > 0 && mounted) {
        // Return true so the caller knows it can retry
        Navigator.pop(context, true);
        widget.onAdWatched?.call();
      } else if (mounted) {
        final l10n = L10n.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.questBarAdNotReady),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingAd = false);
    }
  }

  @override
  void dispose() {
    _adService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xl),
      title: Row(
        children: [
          const Icon(AppIcons.energy, size: 32, color: AppIcons.energyColor),
          const SizedBox(width: AppSpacing.md),
          Text(l10n.noEnergyTitle),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.noEnergyContent,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              const Icon(AppIcons.tips, size: 16, color: AppIcons.tipsColor),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  l10n.noEnergyTip,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.noEnergyLater),
        ),
        if (_adService.canWatchAd)
          TextButton.icon(
            onPressed: _isLoadingAd ? null : _handleWatchAd,
            icon: _isLoadingAd
                ? const SizedBox(
                    width: AppSpacing.lg,
                    height: AppSpacing.lg,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_circle_outline, color: AppColors.info),
            label: Text(
              l10n.noEnergyWatchAd(_remainingAds),
              style: const TextStyle(color: AppColors.info),
            ),
          ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, false);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EnergyStoreScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.md),
          ),
          child: Text(l10n.noEnergyBuyEnergy, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
