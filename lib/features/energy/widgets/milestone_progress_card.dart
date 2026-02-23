import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/services/device_id_service.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/gamification_provider.dart';
import '../providers/energy_provider.dart';

const String _cloudFunctionsUrl = 'https://us-central1-miro-d6856.cloudfunctions.net';

class MilestoneProgressCard extends ConsumerStatefulWidget {
  final bool compact;

  const MilestoneProgressCard({super.key, this.compact = false});

  @override
  ConsumerState<MilestoneProgressCard> createState() => _MilestoneProgressCardState();
}

class _MilestoneProgressCardState extends ConsumerState<MilestoneProgressCard> {
  bool _isClaiming = false;

  static const List<Map<String, dynamic>> _milestones = [
    {'threshold': 10, 'reward': 10, 'label': 'milestone_10'},
    {'threshold': 25, 'reward': 5, 'label': 'milestone_25'},
    {'threshold': 50, 'reward': 7, 'label': 'milestone_50'},
    {'threshold': 100, 'reward': 10, 'label': 'milestone_100'},
    {'threshold': 250, 'reward': 15, 'label': 'milestone_250'},
    {'threshold': 500, 'reward': 20, 'label': 'milestone_500'},
    {'threshold': 1000, 'reward': 30, 'label': 'milestone_1000'},
    {'threshold': 2500, 'reward': 50, 'label': 'milestone_2500'},
    {'threshold': 5000, 'reward': 65, 'label': 'milestone_5000'},
    {'threshold': 10000, 'reward': 100, 'label': 'milestone_10000'},
  ];

  Future<void> _claimMilestones() async {
    if (_isClaiming) return;

    setState(() => _isClaiming = true);

    try {
      final deviceId = await DeviceIdService.getDeviceId();
      final response = await http.post(
        Uri.parse('$_cloudFunctionsUrl/claimMilestoneRewardsEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'deviceId': deviceId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final totalReward = data['totalReward'] as int;
          
          // Refresh state
          await ref.read(gamificationProvider.notifier).refresh();
          ref.invalidate(energyBalanceProvider);
          ref.invalidate(currentEnergyProvider);

          if (mounted) {
            final l10n = L10n.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.milestoneClaimedEnergy(totalReward)),
                backgroundColor: AppColors.success,
              ),
            );
          }
        } else {
          if (mounted) {
            final l10n = L10n.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.milestoneNoMilestonesToClaim),
                backgroundColor: AppColors.warning,
              ),
            );
          }
        }
      } else {
        throw Exception('Failed to claim: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error claiming milestones: $e');
      if (mounted) {
        final l10n = L10n.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorGeneric('$e')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isClaiming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gamification = ref.watch(gamificationProvider);
    final totalSpent = gamification.totalSpent;
    final nextIndex = gamification.nextMilestoneIndex;

    // Progressive Reveal: แสดง milestone ถัดไป + ล็อคตัวถัดจากนั้น
    final currentMilestone =
        nextIndex < _milestones.length ? _milestones[nextIndex] : null;
    final lockedMilestone =
        nextIndex + 1 < _milestones.length ? _milestones[nextIndex + 1] : null;

    // ถ้า claim ครบทุก milestone
    if (currentMilestone == null) {
      return widget.compact
          ? _buildAllComplete(context)
          : Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.lg),
              child: Padding(
                padding: AppSpacing.paddingLg,
                child: _buildAllComplete(context),
              ),
            );
    }

    final threshold = currentMilestone['threshold'] as int;
    final reward = currentMilestone['reward'] as int;
    final progress = (totalSpent / threshold).clamp(0.0, 1.0);
    final canClaim = totalSpent >= threshold;

    final l10n = L10n.of(context)!;
    if (widget.compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMilestoneRow(
            title: l10n.milestoneUseEnergyComplete(threshold),
            progress: totalSpent,
            target: threshold,
            reward: reward,
            progressPercent: progress,
            canClaim: canClaim,
          ),
          if (lockedMilestone != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.lock, size: 14, color: AppColors.textTertiary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  l10n.milestoneNext(lockedMilestone['threshold'] as int),
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
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
              AppIcons.milestone,
              l10n.milestoneTitle,
              iconColor: AppIcons.milestoneColor,
              iconSize: 24,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildMilestoneRow(
              title: l10n.milestoneUseEnergyComplete(threshold),
              progress: totalSpent,
              target: threshold,
              reward: reward,
              progressPercent: progress,
              canClaim: canClaim,
            ),
            if (lockedMilestone != null) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const Icon(Icons.lock, size: 14, color: AppColors.textTertiary),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    l10n.milestoneNext(lockedMilestone['threshold'] as int),
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneRow({
    required String title,
    required int progress,
    required int target,
    required int reward,
    required double progressPercent,
    required bool canClaim,
  }) {
    final isComplete = progress >= target;
    final color = canClaim ? AppColors.warning : (isComplete ? AppColors.success : AppColors.warning);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(AppIcons.milestone, size: 20, color: color),
            const SizedBox(width: AppSpacing.sm),
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
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                        child: Icon(
                          AppIcons.energy,
                          size: 12,
                          color: isComplete ? AppColors.success : AppColors.textSecondary,
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
            if (canClaim && !_isClaiming)
              GestureDetector(
                onTap: _claimMilestones,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.warning, AppColors.warning],
                    ),
                    borderRadius: AppRadius.md,
                  ),
                  child: Row(
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
                      const SizedBox(width: AppSpacing.xxs),
                      const Icon(AppIcons.energy, size: 12, color: Colors.white),
                    ],
                  ),
                ),
              )
            else if (_isClaiming)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Text(
                '[$progress/$target]',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: AppRadius.sm,
          child: LinearProgressIndicator(
            value: progressPercent,
            minHeight: 6,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(
              isComplete ? AppColors.success : AppColors.warning,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAllComplete(BuildContext context) {
    final l10n = L10n.of(context)!;
    return Row(
      children: [
        const Icon(Icons.check_circle, color: AppColors.success, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Text(
          l10n.milestoneAllComplete,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.success,
          ),
        ),
      ],
    );
  }
}
