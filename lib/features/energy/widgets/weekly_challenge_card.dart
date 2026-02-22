import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/services/device_id_service.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/gamification_provider.dart';
import '../providers/energy_provider.dart';

class WeeklyChallengeCard extends ConsumerStatefulWidget {
  final bool compact;

  const WeeklyChallengeCard({super.key, this.compact = false});

  @override
  ConsumerState<WeeklyChallengeCard> createState() =>
      _WeeklyChallengeCardState();
}

class _WeeklyChallengeCardState extends ConsumerState<WeeklyChallengeCard> {
  bool _isLoading = false;

  static const _challenges = [
    {'key': 'weeklyAi20', 'target': 20, 'reward': 3},
    {'key': 'weeklyAi40', 'target': 40, 'reward': 4},
    {'key': 'weeklyAi60', 'target': 60, 'reward': 5},
  ];

  Future<void> _claimChallenge(String challengeType) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final deviceId = await DeviceIdService.getDeviceId();
      final response = await http.post(
        Uri.parse(
            'https://us-central1-miro-d6856.cloudfunctions.net/completeChallenge'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'deviceId': deviceId,
          'challengeType': challengeType,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await ref.read(gamificationProvider.notifier).refresh();
        ref.invalidate(energyBalanceProvider);
        ref.invalidate(currentEnergyProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(AppIcons.celebration,
                      size: 18, color: Colors.white),
                  SizedBox(width: AppSpacing.sm),
                  Text('+${data['reward']}E!'),
                ],
              ),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        final error = jsonDecode(response.body);
        if (mounted) {
          final l10n = L10n.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error['error']?.toString() ?? l10n.errorFailed),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('[WeeklyChallenge] Claim error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.of(context)!.errorFailed),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gamification = ref.watch(gamificationProvider);
    final weeklyAi = gamification.weeklyAiCount;
    final claimed = gamification.weeklyClaimedRewards;
    final l10n = L10n.of(context)!;

    final items = _challenges.map((c) {
      final key = c['key'] as String;
      final target = c['target'] as int;
      final reward = c['reward'] as int;
      return _buildChallengeItem(
        icon: AppIcons.ai,
        iconColor: AppIcons.aiColor,
        title: '${l10n.questBarUseAi} $target',
        progress: weeklyAi,
        target: target,
        reward: reward,
        isClaimed: claimed.contains(key),
        onClaim: () => _claimChallenge(key),
      );
    }).toList();

    if (widget.compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < items.length; i++) ...[
            items[i],
            if (i < items.length - 1) SizedBox(height: AppSpacing.md),
          ],
        ],
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppIcons.iconWithLabel(
              AppIcons.challenge,
              l10n.questBarWeeklyChallenges,
              iconColor: AppIcons.challengeColor,
              iconSize: 24,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: AppSpacing.lg),
            for (int i = 0; i < items.length; i++) ...[
              items[i],
              if (i < items.length - 1) SizedBox(height: AppSpacing.md),
            ],
            SizedBox(height: AppSpacing.md),
            AppIcons.iconWithLabel(
              AppIcons.timer,
              l10n.questBarResetsMonday,
              iconColor: AppIcons.timerColor,
              iconSize: 14,
              fontSize: 12,
              textColor: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required int progress,
    required int target,
    required int reward,
    required bool isClaimed,
    required VoidCallback onClaim,
  }) {
    final isComplete = progress >= target;
    final progressPercent = (progress / target).clamp(0.0, 1.0);
    final color =
        isClaimed ? AppColors.success : (isComplete ? AppColors.warning : AppColors.info);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  children: [
                    TextSpan(text: title),
                    TextSpan(
                      text: ' (+$reward',
                      style: TextStyle(
                        color: isComplete ? AppColors.success : AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    WidgetSpan(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                        child: Icon(
                          AppIcons.energy,
                          size: 12,
                          color:
                              isComplete ? AppColors.success : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    TextSpan(
                      text: ')',
                      style: TextStyle(
                        color: isComplete ? AppColors.success : AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isClaimed)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 18),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    L10n.of(context)!.questBarClaimed,
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            else if (isComplete)
              GestureDetector(
                onTap: _isLoading ? null : onClaim,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isLoading
                          ? [AppColors.textTertiary, AppColors.textTertiary]
                          : [AppColors.warning, AppColors.warning],
                    ),
                    borderRadius: AppRadius.md,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '+$reward',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: AppSpacing.xxs),
                            const Icon(AppIcons.energy,
                                size: 12, color: Colors.white),
                          ],
                        ),
                ),
              )
            else
              Text(
                '[$progress/$target]',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
          ],
        ),
        SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: AppRadius.sm,
          child: LinearProgressIndicator(
            value: progressPercent,
            minHeight: 6,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
