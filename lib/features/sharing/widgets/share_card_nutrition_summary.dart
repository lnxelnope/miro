import 'dart:io';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../models/share_card_config.dart';

class ShareCardNutritionSummary extends StatelessWidget {
  final ShareCardConfig config;

  const ShareCardNutritionSummary({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final hasHero = config.heroImagePath != null &&
        config.heroImagePath!.isNotEmpty &&
        File(config.heroImagePath!).existsSync();

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        width: 1080 / 3,
        height: 1350 / 3,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasHero)
              Image.file(
                File(config.heroImagePath!),
                fit: BoxFit.cover,
              )
            else
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A2332), Color(0xFF0F3D3E)],
                  ),
                ),
              ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.22, 0.62, 1.0],
                    colors: [
                      Colors.black.withValues(alpha: 0.5),
                      Colors.black.withValues(alpha: 0.12),
                      Colors.black.withValues(alpha: 0.10),
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              top: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            config.periodLabel ?? l10n.nutritionSummary,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        _buildBrandBadge(),
                      ],
                    ),
                    if (config.dateRangeStart != null && config.dateRangeEnd != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${_fmtDate(context, config.dateRangeStart!)} - ${_fmtDate(context, config.dateRangeEnd!)}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 14,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.38),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (config.showCalories && config.totalCalories != null)
                      Row(
                        children: [
                          Text(
                            _fmtNum(config.totalCalories!),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            l10n.kcal.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Colors.white70,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const Spacer(),
                          if (config.daysTracked != null)
                            Text(
                              l10n.shareCardDays(config.daysTracked!),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white.withValues(alpha: 0.65),
                              ),
                            ),
                        ],
                      ),
                    if (config.showMacros) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _macroText('P', config.totalProtein ?? 0),
                            const SizedBox(width: 12),
                            _macroText('C', config.totalCarbs ?? 0),
                            const SizedBox(width: 12),
                            _macroText('F', config.totalFat ?? 0),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: SizedBox(
                          height: 6,
                          child: _buildMacroBar(),
                        ),
                      ),
                    ],
                    if (config.showMicros && _hasMicros) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            if (config.totalFiber != null && config.totalFiber! > 0)
                              _microRow(l10n.shareCardFiber, '${config.totalFiber!.toStringAsFixed(1)}g'),
                            if (config.totalSugar != null && config.totalSugar! > 0)
                              _microRow(l10n.shareCardSugar, '${config.totalSugar!.toStringAsFixed(1)}g'),
                            if (config.totalSodium != null && config.totalSodium! > 0)
                              _microRow(l10n.shareCardSodium, '${config.totalSodium!.toInt()}mg'),
                          ],
                        ),
                      ),
                    ],
                    if (!hasHero) ...[
                      const SizedBox(height: 8),
                      Text(
                        l10n.shareNoImageSelected,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                    if (config.showStreak && config.streakDays != null && config.streakDays! > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            l10n.shareCardDayStreak(config.streakDays!),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
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

  Widget _buildMacroBar() {
    final p = config.totalProtein ?? 0;
    final c = config.totalCarbs ?? 0;
    final f = config.totalFat ?? 0;
    final total = p + c + f;
    if (total == 0) return const SizedBox.shrink();

    return Row(
      children: [
        Flexible(
          flex: (p / total * 100).round().clamp(1, 100),
          child: Container(color: const Color(0xFF4CAF50)),
        ),
        Flexible(
          flex: (c / total * 100).round().clamp(1, 100),
          child: Container(color: const Color(0xFF42A5F5)),
        ),
        Flexible(
          flex: (f / total * 100).round().clamp(1, 100),
          child: Container(color: const Color(0xFFF59E0B)),
        ),
      ],
    );
  }

  Widget _macroText(String prefix, double value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${value.toInt()}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          prefix,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }

  Widget _microRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.6))),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white70)),
        ],
      ),
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

  String _fmtNum(double v) {
    return v.toInt().toString().replaceAllMapped(
      RegExp(r'(\\d)(?=(\\d{3})+(?!\\d))'),
      (m) => '${m[1]},',
    );
  }

  String _fmtDate(BuildContext context, DateTime d) {
    return MaterialLocalizations.of(context).formatMediumDate(d);
  }
}
