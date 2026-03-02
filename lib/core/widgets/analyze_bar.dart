import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/database/model_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_tokens.dart';
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

    // Analyzing → circular progress (iOS-style)
    if (analysisState.isAnalyzing) {
      final progress = analysisState.total > 0
          ? analysisState.current / analysisState.total
          : 0.0;

      return Container(
        margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md + 2, vertical: AppSpacing.sm + 2),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: AppRadius.md,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            // iOS-style circular progress
            SizedBox(
              width: 36,
              height: 36,
              child: _CircularDownloadProgress(
                progress: progress,
                color: AppColors.primary,
                trackColor: isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.sm + 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.analyzeProgress(analysisState.currentItemName,
                        analysisState.current, analysisState.total),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${analysisState.current}/${analysisState.total}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => ref.read(analysisProvider.notifier).cancel(),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded,
                    size: 16, color: AppColors.error),
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

/// iOS App Store download-style circular progress indicator.
/// Shows a filled arc that grows clockwise from 12 o'clock position.
class _CircularDownloadProgress extends StatelessWidget {
  final double progress; // 0.0 → 1.0
  final Color color;
  final Color trackColor;

  const _CircularDownloadProgress({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CircularProgressPainter(
        progress: progress,
        color: color,
        trackColor: trackColor,
      ),
      child: Center(
        child: Text(
          '${(progress * 100).toInt()}%',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 4) / 2;

    // Track (background circle)
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc (starts from top, clockwise)
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // start from 12 o'clock
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      color != oldDelegate.color;
}
