import 'dart:io';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../models/share_card_config.dart';

class ShareCardDailySummary extends StatelessWidget {
  final ShareCardConfig config;

  const ShareCardDailySummary({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final hasHero = config.heroImagePath != null &&
        config.heroImagePath!.isNotEmpty &&
        File(config.heroImagePath!).existsSync();

    final hasFoodPhotos = config.selectedFoodPhotos.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        width: 1080 / 3,
        height: 1350 / 3,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background
            if (hasHero)
              Image.file(File(config.heroImagePath!), fit: BoxFit.cover)
            else if (hasFoodPhotos)
              _buildFoodCollage()
            else
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A2332), Color(0xFF2D4A3E)],
                  ),
                ),
              ),

            // Gradient scrim
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.2, 0.6, 1.0],
                    colors: [
                      Colors.black.withValues(alpha: 0.5),
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.1),
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
            ),

            // Header
            Positioned(
              top: 14,
              left: 16,
              right: 16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.shareCardDailySummaryTitle,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        if (config.date != null)
                          Text(
                            _formatDate(context, config.date!),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.6),
                              letterSpacing: 1,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildBrandBadge(),
                ],
              ),
            ),

            // Bottom content
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Kcal + Macro row
                  if (config.showCalories || config.showMacros)
                    Row(
                      children: [
                        if (config.showCalories && config.totalCalories != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _fmtNum(config.totalCalories!),
                                  style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  l10n.kcal.toUpperCase(),
                                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: Colors.white70, letterSpacing: 1),
                                ),
                                if (config.showGoalProgress && config.goalPercent != null) ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    config.goalPercent! <= 100 ? Icons.check_circle : Icons.info_outline,
                                    size: 14,
                                    color: Colors.white70,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        if (config.showCalories && config.showMacros) const SizedBox(width: 8),
                        if (config.showMacros)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _macroText('P', config.totalProtein ?? 0),
                                const SizedBox(width: 10),
                                _macroText('C', config.totalCarbs ?? 0),
                                const SizedBox(width: 10),
                                _macroText('F', config.totalFat ?? 0),
                              ],
                            ),
                          ),
                      ],
                    ),

                  // Micros
                  if (config.showMicros && _hasMicros) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (config.totalFiber != null && config.totalFiber! > 0)
                            _microText(l10n.shareCardFiber, config.totalFiber!, 'g'),
                          if (config.totalSugar != null && config.totalSugar! > 0) ...[
                            const SizedBox(width: 10),
                            _microText(l10n.shareCardSugar, config.totalSugar!, 'g'),
                          ],
                          if (config.totalSodium != null && config.totalSodium! > 0) ...[
                            const SizedBox(width: 10),
                            _microText(l10n.shareCardSodium, config.totalSodium!, 'mg'),
                          ],
                        ],
                      ),
                    ),
                  ],

                  // Streak
                  if (config.showStreak && config.streakDays != null && config.streakDays! > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          l10n.shareCardDayStreak(config.streakDays!),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _hasMicros =>
      (config.totalFiber != null && config.totalFiber! > 0) ||
      (config.totalSugar != null && config.totalSugar! > 0) ||
      (config.totalSodium != null && config.totalSodium! > 0);

  Widget _buildFoodCollage() {
    final photos = config.selectedFoodPhotos
        .where((p) => File(p).existsSync())
        .toList();
    if (photos.isEmpty) {
      return Container(color: const Color(0xFF1A2332));
    }
    if (photos.length == 1) {
      return Image.file(File(photos[0]), fit: BoxFit.cover);
    }
    if (photos.length == 2) {
      return Row(
        children: photos
            .map((p) => Expanded(child: Image.file(File(p), fit: BoxFit.cover, height: double.infinity)))
            .toList(),
      );
    }
    // 3+: 2x2 grid
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: Image.file(File(photos[0]), fit: BoxFit.cover)),
              Expanded(child: Image.file(File(photos[1]), fit: BoxFit.cover)),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(child: Image.file(File(photos[2]), fit: BoxFit.cover)),
              if (photos.length > 3)
                Expanded(child: Image.file(File(photos[3]), fit: BoxFit.cover))
              else
                Expanded(child: Container(color: const Color(0xFF1A2332))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBrandBadge() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.asset(
        'assets/icon/logo_with_store.png',
        width: 92,
        height: 92,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _macroText(String prefix, double value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${value.toInt()}',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        Text(
          prefix,
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.5)),
        ),
      ],
    );
  }

  Widget _microText(String name, double value, String unit) {
    return Text(
      '$name ${value.toInt()}$unit',
      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.7)),
    );
  }

  String _fmtNum(double v) {
    if (v >= 10000) return '${(v / 1000).toStringAsFixed(1)}k';
    return v.toInt().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},',
    );
  }

  String _formatDate(BuildContext context, DateTime d) {
    return MaterialLocalizations.of(context).formatMediumDate(d);
  }
}
