import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../core/models/gamification_state.dart';
import '../../../core/services/device_id_service.dart';
import '../../../core/services/seasonal_quest_popup_prefs.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/gamification_provider.dart';

/// Shows seasonal quests as a one-shot dialog on Home (replaces quest-bar banners).
class SeasonalQuestPopupPresenter {
  SeasonalQuestPopupPresenter._();

  static bool _opening = false;

  static Future<void> maybeShow(
    BuildContext context,
    WidgetRef ref,
    GamificationState g, {
    required bool allowShow,
  }) async {
    if (!allowShow || !context.mounted || _opening) return;

    _opening = true;
    try {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!context.mounted) return;

      SeasonalQuestData? quest;
      for (final q in g.seasonalQuests) {
        if (q.isActive && q.canClaimToday) {
          quest = q;
          break;
        }
      }
      if (quest == null) return;

      if (await SeasonalQuestPopupPrefs.wasShownToday(quest.id)) return;

      await SeasonalQuestPopupPrefs.markShownToday(quest.id);
      if (!context.mounted) return;

      final q = quest;
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => _SeasonalQuestPopupDialog(quest: q),
      );
    } finally {
      _opening = false;
    }
  }
}

class _SeasonalQuestPopupDialog extends ConsumerStatefulWidget {
  final SeasonalQuestData quest;

  const _SeasonalQuestPopupDialog({required this.quest});

  @override
  ConsumerState<_SeasonalQuestPopupDialog> createState() =>
      _SeasonalQuestPopupDialogState();
}

class _SeasonalQuestPopupDialogState
    extends ConsumerState<_SeasonalQuestPopupDialog> {
  bool _loading = false;

  Future<void> _claim() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final deviceId = await DeviceIdService.getDeviceId();
      final response = await http.post(
        Uri.parse(
          'https://us-central1-miro-d6856.cloudfunctions.net/completeChallenge',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'deviceId': deviceId,
          'challengeType': 'seasonal',
          'questId': widget.quest.id,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        ref.read(gamificationProvider.notifier).refresh();
        final reward = data['reward'];
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.quest.icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: AppSpacing.sm),
                Text('+$reward E!'),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        Map<String, dynamic>? err;
        try {
          err = jsonDecode(response.body) as Map<String, dynamic>?;
        } catch (_) {}
        final l10n = L10n.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err?['error']?.toString() ?? l10n.errorFailed),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        final l10n = L10n.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorFailed),
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
    final q = widget.quest;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      title: Row(
        children: [
          Text(q.icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              q.title,
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
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(AppSpacing.xs),
                  ),
                  child: Text(
                    l10n.seasonalQuestLimitedTime,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l10n.seasonalQuestDaysLeft(q.daysRemaining),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
            if (q.description.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                q.description,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                const Icon(AppIcons.energy, size: 20, color: AppColors.warning),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    q.claimType == 'daily'
                        ? l10n.seasonalQuestRewardDaily(q.rewardPerClaim)
                        : l10n.seasonalQuestRewardOnce(q.rewardPerClaim),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
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
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.seasonalQuestMaybeLater),
        ),
        FilledButton(
          onPressed: _loading ? null : _claim,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.warning,
            foregroundColor: Colors.white,
          ),
          child: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(l10n.seasonalQuestClaimNow),
        ),
      ],
    );
  }
}
