import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/services/device_id_service.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/models/gamification_state.dart';
import '../providers/gamification_provider.dart';

class SeasonalQuestCard extends ConsumerStatefulWidget {
  final SeasonalQuestData quest;

  const SeasonalQuestCard({
    super.key,
    required this.quest,
  });

  @override
  ConsumerState<SeasonalQuestCard> createState() => _SeasonalQuestCardState();
}

class _SeasonalQuestCardState extends ConsumerState<SeasonalQuestCard> {
  bool _isLoading = false;

  Future<void> _claimReward() async {
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
          'challengeType': 'seasonal',
          'questId': widget.quest.id,
        }),
      );

      if (response.statusCode == 200) {
        ref.read(gamificationProvider.notifier).refresh();
        if (mounted) {
          final data = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.quest.icon, style: const TextStyle(fontSize: 18)),
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
              content: Text(error['error'] ?? l10n.errorFailed),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('[SeasonalQuest] Claim error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final quest = widget.quest;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.lg,
          border: Border.all(
            color: AppColors.warning.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header: LIMITED TIME badge + title ───
              Row(
                children: [
                  // Icon
                  Text(quest.icon, style: const TextStyle(fontSize: 28)),
                  SizedBox(width: AppSpacing.xs + AppSpacing.xxs),
                  // Title + description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xs + AppSpacing.xxs, vertical: AppSpacing.xxs),
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
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            SizedBox(width: AppSpacing.xs + AppSpacing.xxs),
                            Text(
                              l10n.seasonalQuestDaysLeft(quest.daysRemaining),
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          quest.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                        ),
                        if (quest.description.isNotEmpty) ...[
                          SizedBox(height: AppSpacing.xxs),
                          Text(
                            quest.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),

              // ─── Reward info + Claim button ───
              Row(
                children: [
                  // Reward info
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(AppIcons.energy, size: 16, color: AppColors.warning),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          quest.claimType == 'daily'
                              ? l10n.seasonalQuestRewardDaily(quest.rewardPerClaim)
                              : l10n.seasonalQuestRewardOnce(quest.rewardPerClaim),
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Claim button
                  if (quest.canClaimToday)
                    GestureDetector(
                      onTap: _isLoading ? null : _claimReward,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl, vertical: AppSpacing.xs + AppSpacing.xxs),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [AppColors.warning, AppColors.warning]),
                          borderRadius: AppRadius.md,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '+${quest.rewardPerClaim}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: AppSpacing.xs),
                                  const Icon(AppIcons.energy,
                                      size: 16, color: Colors.white),
                                ],
                              ),
                      ),
                    )
                  else if (quest.claimType == 'one_time' && quest.claimed)
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.xs + AppSpacing.xxs),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: AppRadius.sm,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle,
                              size: 16, color: AppColors.success),
                          SizedBox(width: AppSpacing.xs),
                          Text(
                            l10n.seasonalQuestClaimed,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (quest.claimType == 'daily' &&
                      !quest.canClaimToday &&
                      quest.isActive)
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.xs + AppSpacing.xxs),
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withValues(alpha: 0.15),
                        borderRadius: AppRadius.sm,
                      ),
                      child: Text(
                        l10n.seasonalQuestClaimedToday,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
