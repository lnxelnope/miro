import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/models/gamification_state.dart';
import '../../../core/services/device_id_service.dart';
import '../../../core/services/referral_reward_popup_prefs.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/referral_claim_bundle.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/energy_provider.dart';
import '../providers/gamification_provider.dart';

/// Referrer milestone Energy (weekly referFriends levels) — was only in QuestBar; claim all in one tap.
class ReferralRewardsPopupPresenter {
  ReferralRewardsPopupPresenter._();

  static bool _opening = false;

  static Future<void> maybeShow(
    BuildContext context,
    WidgetRef ref,
    GamificationState g, {
    required bool allowShow,
  }) async {
    if (!allowShow || !context.mounted || _opening) return;

    final bundle = ReferralClaimBundle.fromGamification(g);
    if (bundle.isEmpty) return;

    if (await ReferralRewardPopupPrefs.isSuppressedToday()) return;

    _opening = true;
    try {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!context.mounted) return;

      final fresh = ReferralClaimBundle.fromGamification(
        ref.read(gamificationProvider),
      );
      if (fresh.isEmpty) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => _ReferralRewardsPopupDialog(bundle: fresh),
      );
    } finally {
      _opening = false;
    }
  }
}

class _ReferralRewardsPopupDialog extends ConsumerStatefulWidget {
  final ReferralClaimBundle bundle;

  const _ReferralRewardsPopupDialog({required this.bundle});

  @override
  ConsumerState<_ReferralRewardsPopupDialog> createState() =>
      _ReferralRewardsPopupDialogState();
}

class _ReferralRewardsPopupDialogState
    extends ConsumerState<_ReferralRewardsPopupDialog> {
  bool _loading = false;

  Future<void> _later() async {
    await ReferralRewardPopupPrefs.suppressUntilTomorrow();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _claimAll() async {
    if (_loading) return;
    setState(() => _loading = true);

    final levels = widget.bundle.levelNumbers;
    var claimedSum = 0;
    String? errorText;

    try {
      final deviceId = await DeviceIdService.getDeviceId();

      for (final level in levels) {
        final response = await http.post(
          Uri.parse(
            'https://us-central1-miro-d6856.cloudfunctions.net/completeChallenge',
          ),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'deviceId': deviceId,
            'challengeType': 'referFriends',
            'referralLevel': level,
          }),
        );

        if (response.statusCode != 200) {
          try {
            final err = jsonDecode(response.body) as Map<String, dynamic>?;
            errorText = err?['error']?.toString();
          } catch (_) {}
          errorText ??= 'HTTP ${response.statusCode}';
          break;
        }

        final data = jsonDecode(response.body) as Map<String, dynamic>;
        claimedSum += (data['reward'] as num?)?.toInt() ?? 0;
      }

      if (!mounted) return;

      await ref.read(gamificationProvider.notifier).refresh();
      if (!mounted) return;
      ref.invalidate(energyBalanceProvider);
      ref.invalidate(currentEnergyProvider);
      if (!mounted) return;

      final l10n = L10n.of(context)!;
      final messenger = ScaffoldMessenger.of(context);
      final nav = Navigator.of(context);

      if (errorText != null) {
        if (claimedSum > 0) {
          nav.pop();
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                '${l10n.referralRewardsClaimedSummary(claimedSum)} ($errorText)',
              ),
              backgroundColor: AppColors.warning,
              duration: const Duration(seconds: 4),
            ),
          );
        } else {
          messenger.showSnackBar(
            SnackBar(
              content: Text(errorText),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      nav.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(AppIcons.celebration, color: Colors.white, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(l10n.referralRewardsClaimedSummary(claimedSum)),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.of(context)!.errorGeneric('$e')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final b = widget.bundle;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      title: Row(
        children: [
          const Icon(Icons.people_rounded, color: AppColors.primary, size: 28),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              l10n.referralRewardsPopupTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.referralRewardsPopupBody,
            style: TextStyle(
              fontSize: 14,
              height: 1.35,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              const Icon(AppIcons.energy, size: 24, color: AppColors.warning),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  l10n.referralEnergyBonus(b.totalEnergy),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : _later,
          child: Text(l10n.referralRewardsMaybeLater),
        ),
        FilledButton(
          onPressed: _loading ? null : _claimAll,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
          ),
          child: _loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(l10n.referralRewardsClaimAllButton(b.totalEnergy)),
        ),
      ],
    );
  }
}
