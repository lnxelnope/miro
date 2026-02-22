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

class TierCelebrationCard extends ConsumerStatefulWidget {
  final String tierKey; // 'starter', 'bronze', 'silver', 'gold', 'diamond'
  final TierCelebrationData celebration;

  const TierCelebrationCard({
    super.key,
    required this.tierKey,
    required this.celebration,
  });

  @override
  ConsumerState<TierCelebrationCard> createState() =>
      _TierCelebrationCardState();
}

class _TierCelebrationCardState extends ConsumerState<TierCelebrationCard> {
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
          'challengeType': 'tierCelebration',
          'tier': widget.tierKey,
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
              content: Text(error['error'] ?? l10n.errorFailed),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('[TierCelebration] Claim error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  IconData _getTierIcon() {
    switch (widget.tierKey) {
      case 'bronze':
        return AppIcons.tierBronze;
      case 'silver':
        return AppIcons.tierSilver;
      case 'gold':
        return AppIcons.tierGold;
      case 'diamond':
        return AppIcons.tierDiamond;
      default:
        return AppIcons.tierStarter;
    }
  }

  Color _getTierColor() {
    switch (widget.tierKey) {
      case 'bronze':
        return AppColors.tierBronze;
      case 'silver':
        return AppColors.tierSilver;
      case 'gold':
        return AppColors.tierGold;
      case 'diamond':
        return AppColors.tierDiamond;
      default:
        return AppIcons.tierStarterColor;
    }
  }

  String _getTierName(BuildContext context) {
    final l10n = L10n.of(context)!;
    switch (widget.tierKey) {
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
    final celebration = widget.celebration;
    final currentDay = celebration.currentDay;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Icon(_getTierIcon(), size: 24, color: _getTierColor()),
                  SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.tierCelebrationTitle(_getTierName(context)),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (celebration.isComplete)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSpacing.xs),
                    ),
                    child: Text(
                      l10n.tierCelebrationComplete,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: AppSpacing.md),

            // 7-day indicator grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final dayNum = index + 1;
                final isClaimed = celebration.claimedDays.contains(dayNum);
                final isToday = dayNum == currentDay;
                final isExpired = dayNum < currentDay && !isClaimed;
                final isFuture = dayNum > currentDay;

                return Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: AppSpacing.xxs + AppSpacing.xxs),
                    child: Column(
                      children: [
                        // Circle indicator
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isClaimed
                                ? AppColors.success
                                : isToday
                                    ? AppColors.warning
                                    : isExpired
                                        ? AppColors.divider
                                        : AppColors.divider,
                            border: Border.all(
                              color: isToday
                                  ? AppColors.warning
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: isClaimed
                                ? const Icon(Icons.check,
                                    color: Colors.white, size: 24)
                                : isExpired
                                    ? Icon(Icons.close,
                                        color: AppColors.textSecondary, size: 20)
                                    : isFuture
                                        ? Icon(Icons.circle,
                                            color: AppColors.textTertiary,
                                            size: 8)
                                        : const Icon(AppIcons.energy,
                                            color: Colors.white, size: 20),
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        // Day label
                        Text(
                          l10n.tierCelebrationDay(dayNum),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: AppSpacing.md),

            // Claim button (only show if claimable today)
            if (celebration.canClaimToday)
              Center(
                child: GestureDetector(
                  onTap: _isLoading ? null : _claimReward,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxl, vertical: AppSpacing.xs + AppSpacing.xxs),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [AppColors.warning, AppColors.warning]),
                      borderRadius: AppRadius.md,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isLoading)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        else ...[
                          const Text(
                            '+2',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: AppSpacing.xs),
                          const Icon(AppIcons.energy,
                              size: 16, color: Colors.white),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

            // Expired message
            if (!celebration.isActive && !celebration.isComplete)
              Center(
                child: Text(
                  l10n.tierCelebrationExpired,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
