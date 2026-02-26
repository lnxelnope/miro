import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/services/health_sync_service.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/health_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../profile/models/user_profile.dart';

class DailySummaryCard extends ConsumerWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onDateChanged;

  const DailySummaryCard({super.key, this.selectedDate, this.onDateChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = selectedDate ?? dateOnly(DateTime.now());
    final isToday = _isToday(date);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final foodsAsync = ref.watch(foodEntriesByDateProvider(date));
    final profileAsync = ref.watch(profileNotifierProvider);

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.surfaceVariantDark,
                  AppColors.surfaceDark,
                ]
              : [
                  AppColors.health.withValues(alpha: 0.05),
                  AppColors.health.withValues(alpha: 0.10),
                ],
        ),
        borderRadius: AppRadius.md,
        border: Border.all(
          color: isDark
              ? AppColors.health.withValues(alpha: 0.35)
              : AppColors.health.withValues(alpha: 0.18),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.health.withValues(alpha: isDark ? 0.10 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: profileAsync.when(
        loading: () => const SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        error: (_, __) => const SizedBox(),
        data: (profile) => foodsAsync.when(
          loading: () => const SizedBox(
            height: 80,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (_, __) => const Text('Error'),
          data: (entries) {
            final calories =
                entries.fold<double>(0, (sum, e) => sum + e.calories);
            final protein =
                entries.fold<double>(0, (sum, e) => sum + e.protein);
            final carbs = entries.fold<double>(0, (sum, e) => sum + e.carbs);
            final fat = entries.fold<double>(0, (sum, e) => sum + e.fat);

            final isHealthOn = profile.isHealthConnectConnected;
            final activeEnergyAsync =
                isToday && isHealthOn ? ref.watch(activeEnergyProvider) : null;
            final rawActive = activeEnergyAsync?.valueOrNull ?? 0.0;
            final activeEnergy =
                (rawActive.isNaN || rawActive.isInfinite) ? 0.0 : rawActive;

            final baseGoal = profile.calorieGoal;
            final goal =
                (isHealthOn && isToday) ? baseGoal + activeEnergy : baseGoal;
            final safeGoal = (goal.isNaN || goal.isInfinite) ? baseGoal : goal;
            final percent =
                safeGoal > 0 ? (calories / safeGoal).clamp(0.0, 1.0) : 0.0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date navigation row
                Row(
                  children: [
                    // Left arrow
                    if (onDateChanged != null)
                      _navArrow(
                        icon: Icons.chevron_left_rounded,
                        onTap: () => onDateChanged!(
                            date.subtract(const Duration(days: 1))),
                        isDark: isDark,
                      ),
                    if (onDateChanged != null)
                      const SizedBox(width: AppSpacing.xs),

                    // Date text (tap = date picker)
                    Expanded(
                      child: GestureDetector(
                        onTap: onDateChanged != null
                            ? () => _pickDate(context, date)
                            : null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              isToday
                                  ? 'Today'
                                  : DateFormat('d MMM yyyy', 'en').format(date),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              DateFormat('EEEE', 'en').format(date),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Right arrow (disabled if today)
                    if (onDateChanged != null)
                      _navArrow(
                        icon: Icons.chevron_right_rounded,
                        onTap: isToday
                            ? null
                            : () => onDateChanged!(
                                date.add(const Duration(days: 1))),
                        isDark: isDark,
                        disabled: isToday,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Main content: Macros + Active Energy (left) + Circular kcal (right)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left: Macro bars + Active Energy row
                    Expanded(
                      child: Column(
                        children: [
                          _buildMacroBar(
                            label: 'P',
                            value: protein,
                            goal: profile.proteinGoal,
                            color: AppColors.protein,
                            isDark: isDark,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _buildMacroBar(
                            label: 'C',
                            value: carbs,
                            goal: profile.carbGoal,
                            color: AppColors.carbs,
                            isDark: isDark,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _buildMacroBar(
                            label: 'F',
                            value: fat,
                            goal: profile.fatGoal,
                            color: AppColors.fat,
                            isDark: isDark,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _ActiveEnergyRow(
                            profile: profile,
                            activeEnergy: activeEnergy,
                            isHealthOn: isHealthOn,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),

                    // Right: Circular kcal (spans all 4 rows)
                    SizedBox(
                      width: 90,
                      height: 90,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 90,
                            height: 90,
                            child: CircularProgressIndicator(
                              value: percent,
                              strokeWidth: 6,
                              strokeCap: StrokeCap.round,
                              backgroundColor: isDark
                                  ? AppColors.surfaceVariantDark
                                  : AppColors.divider,
                              valueColor: AlwaysStoppedAnimation(
                                percent >= 1.0
                                    ? AppColors.error
                                    : AppColors.health,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${calories.toInt()}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '/${safeGoal.toInt()}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                'kcal',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _navArrow({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isDark,
    bool disabled = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: disabled
              ? Colors.transparent
              : (isDark 
                  ? AppColors.health.withValues(alpha: 0.15)
                  : AppColors.health.withValues(alpha: 0.10)),
          borderRadius: AppRadius.sm,
        ),
        child: Icon(
          icon,
          size: 20,
          color: disabled
              ? (isDark ? AppColors.dividerDark : AppColors.divider)
              : (isDark ? AppColors.health.withValues(alpha: 0.9) : AppColors.health),
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, DateTime current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      onDateChanged?.call(picked);
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Widget _buildMacroBar({
    required String label,
    required double value,
    required double goal,
    required Color color,
    required bool isDark,
  }) {
    final progress = goal > 0 ? (value / goal).clamp(0.0, 1.0) : 0.0;

    return Row(
      children: [
        SizedBox(
          width: 14,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor:
                  isDark ? AppColors.surfaceVariantDark : AppColors.divider,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 58,
          child: Text(
            '${value.toInt()}/${goal.toInt()}g',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark.withValues(alpha: 0.85) : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Compact Active Energy row — same height as macro bars.
/// Tap to toggle; first enable triggers Health Connect permission request.
class _ActiveEnergyRow extends ConsumerStatefulWidget {
  final UserProfile profile;
  final double activeEnergy;
  final bool isHealthOn;
  final bool isDark;

  const _ActiveEnergyRow({
    required this.profile,
    required this.activeEnergy,
    required this.isHealthOn,
    required this.isDark,
  });

  @override
  ConsumerState<_ActiveEnergyRow> createState() => _ActiveEnergyRowState();
}

class _ActiveEnergyRowState extends ConsumerState<_ActiveEnergyRow> {
  bool _isLoading = false;

  Future<void> _toggle() async {
    if (widget.isHealthOn) {
      widget.profile.isHealthConnectConnected = false;
      await ref
          .read(profileNotifierProvider.notifier)
          .updateProfile(widget.profile);
      return;
    }

    setState(() => _isLoading = true);

    final available = await HealthSyncService.isAvailable();
    if (!available) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.of(context)!.healthSyncNotAvailable),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final granted = await HealthSyncService.requestPermissions();
    if (!granted) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showPermissionDeniedDialog();
      }
      return;
    }

    widget.profile.isHealthConnectConnected = true;
    await ref
        .read(profileNotifierProvider.notifier)
        .updateProfile(widget.profile);
    if (mounted) setState(() => _isLoading = false);
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(L10n.of(context)!.healthSyncPermissionDeniedTitle),
        content: Text(L10n.of(context)!.healthSyncPermissionDeniedMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(L10n.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              HealthSyncService.openDeviceSettings();
            },
            child: Text(L10n.of(context)!.healthSyncGoToSettings),
          ),
        ],
      ),
    );
  }

  static const _barMaxKcal = 500.0;
  static const _activeGreen = Color(0xFF4CAF50);

  @override
  Widget build(BuildContext context) {
    final isOn = widget.isHealthOn;
    final offColor = widget.isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondary;
    final chipColor = isOn ? _activeGreen : offColor;
    final progress = isOn
        ? (widget.activeEnergy / _barMaxKcal).clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      onTap: _isLoading ? null : _toggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isOn
              ? _activeGreen.withValues(alpha: widget.isDark ? 0.15 : 0.10)
              : (widget.isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.divider.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              size: 12,
              color: chipColor,
            ),
            const SizedBox(width: 4),
            // Green progress bar (fills toward 500 kcal)
            Expanded(
              child: _isLoading
                  ? SizedBox(
                      height: 6,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: const LinearProgressIndicator(
                          minHeight: 6,
                        ),
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: SizedBox(
                        height: 6,
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: widget.isDark
                              ? AppColors.surfaceVariantDark
                              : AppColors.divider,
                          valueColor:
                              AlwaysStoppedAnimation(chipColor),
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 6),
            // Value text
            Text(
              isOn
                  ? '+${widget.activeEnergy.toInt()}'
                  : 'off',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: chipColor,
              ),
            ),
            const SizedBox(width: 4),
            // Mini toggle
            Container(
              width: 22,
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: isOn
                    ? _activeGreen
                    : (widget.isDark
                        ? Colors.grey.shade700
                        : Colors.grey.shade400),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment:
                    isOn ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 9,
                  height: 9,
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
