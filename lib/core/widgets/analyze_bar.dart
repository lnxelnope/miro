import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_tokens.dart';
import '../../features/health/models/food_entry.dart';
import '../../features/health/providers/health_provider.dart';
import '../../features/health/providers/analysis_provider.dart';
import '../../l10n/app_localizations.dart';

/// Shared "Analyze All" bar — shows progress or an analyze button.
/// Completely self-contained: watches providers internally.
/// Returns [SizedBox.shrink] when there is nothing to show.
class AnalyzeBar extends ConsumerWidget {
  final DateTime selectedDate;
  final void Function(List<FoodEntry> unanalyzed) onAnalyze;

  const AnalyzeBar({
    super.key,
    required this.selectedDate,
    required this.onAnalyze,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisState = ref.watch(analysisProvider);
    final timelineAsync = ref.watch(healthTimelineProvider(selectedDate));
    final l10n = L10n.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = timelineAsync.valueOrNull ?? [];
    final foodEntries = items
        .where((i) => i.type == 'food')
        .map((i) => i.data as FoodEntry)
        .where((f) => !f.isDeleted)
        .toList();
    final unanalyzed = foodEntries.where((f) => !f.hasNutritionData).toList();
    final energyCost = unanalyzed.length;

    // Analyzing → progress bar
    if (analysisState.isAnalyzing) {
      return Container(
        margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md + 2, vertical: AppSpacing.xl / 2),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: AppRadius.md,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: AppSpacing.lg,
                  height: AppSpacing.lg,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                const SizedBox(width: AppSpacing.xl / 2),
                Expanded(
                  child: Text(
                    l10n.analyzeProgress(analysisState.currentItemName,
                        analysisState.current, analysisState.total),
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => ref.read(analysisProvider.notifier).cancel(),
                  child: const Icon(Icons.close_rounded,
                      size: 18, color: AppColors.error),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs + 2),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: analysisState.total > 0
                    ? analysisState.current / analysisState.total
                    : 0,
                minHeight: 4,
                backgroundColor: isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariant,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ],
        ),
      );
    }

    // Nothing to analyze → hide
    if (energyCost <= 0) return const SizedBox.shrink();

    // Has unanalyzed items → Analyze All button
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      child: GestureDetector(
        onTap: () => onAnalyze(unanalyzed),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: AppRadius.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(AppIcons.ai, size: 18, color: Colors.white),
              const SizedBox(width: AppSpacing.sm),
              Text(
                l10n.analyzeAll,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(AppIcons.energy,
                  size: 14, color: AppIcons.energyColor),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                '$energyCost',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppIcons.energyColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
