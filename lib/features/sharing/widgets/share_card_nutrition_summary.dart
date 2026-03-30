import 'dart:io';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../models/share_card_config.dart';
import 'share_card_brand_badge.dart';
import 'share_card_referral_line.dart';

class ShareCardNutritionSummary extends StatelessWidget {
  final ShareCardConfig config;

  const ShareCardNutritionSummary({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final hasHero = config.heroImagePath != null &&
        config.heroImagePath!.isNotEmpty &&
        File(config.heroImagePath!).existsSync();

    final cardSize = config.logicalSize;
    final s = config.layoutScale;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        width: cardSize.width,
        height: cardSize.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasHero)
              Positioned.fill(
                child: Image.file(
                  File(config.heroImagePath!),
                  fit: BoxFit.cover,
                ),
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
              left: 16 * s,
              right: 16 * s,
              top: 14 * s,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 10 * s),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14 * s),
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
                            style: TextStyle(
                              fontSize: 16 * s,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ShareCardBrandBadge(layoutScale: s),
                            ShareCardReferralLine(
                              referralCode: config.referralCode,
                              layoutScale: s,
                              align: CrossAxisAlignment.end,
                              compactBelowLogo: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (config.dateRangeStart != null && config.dateRangeEnd != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${_fmtDate(context, config.dateRangeStart!)} - ${_fmtDate(context, config.dateRangeEnd!)}',
                          style: TextStyle(
                            fontSize: 10 * s,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16 * s,
              right: 16 * s,
              bottom: 14 * s,
              child: Container(
                padding: EdgeInsets.all(12 * s),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.38),
                  borderRadius: BorderRadius.circular(14 * s),
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
                            style: TextStyle(
                              fontSize: 24 * s,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                          SizedBox(width: 5 * s),
                          Text(
                            l10n.kcal.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9 * s,
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
                                fontSize: 10 * s,
                                color: Colors.white.withValues(alpha: 0.65),
                              ),
                            ),
                        ],
                      ),
                    if (config.showMacros) ...[
                      SizedBox(height: 8 * s),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 7 * s),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20 * s),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _macroText('P', config.totalProtein ?? 0, s),
                            SizedBox(width: 12 * s),
                            _macroText('C', config.totalCarbs ?? 0, s),
                            SizedBox(width: 12 * s),
                            _macroText('F', config.totalFat ?? 0, s),
                          ],
                        ),
                      ),
                      SizedBox(height: 8 * s),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4 * s),
                        child: SizedBox(
                          height: 6 * s,
                          child: _buildMacroBar(),
                        ),
                      ),
                    ],
                    if (config.showMicros && _hasMicros) ...[
                      SizedBox(height: 8 * s),
                      Container(
                        padding: EdgeInsets.all(8 * s),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10 * s),
                        ),
                        child: Column(
                          children: [
                            if (config.totalFiber != null && config.totalFiber! > 0)
                              _microRow(l10n.shareCardFiber, '${config.totalFiber!.toStringAsFixed(1)}g', s),
                            if (config.totalSugar != null && config.totalSugar! > 0)
                              _microRow(l10n.shareCardSugar, '${config.totalSugar!.toStringAsFixed(1)}g', s),
                            if (config.totalSodium != null && config.totalSodium! > 0)
                              _microRow(l10n.shareCardSodium, '${config.totalSodium!.toInt()}mg', s),
                          ],
                        ),
                      ),
                    ],
                    if (!hasHero) ...[
                      SizedBox(height: 8 * s),
                      Text(
                        l10n.shareNoImageSelected,
                        style: TextStyle(
                          fontSize: 11 * s,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                    if (config.showStreak && config.streakDays != null && config.streakDays! > 0) ...[
                      SizedBox(height: 8 * s),
                      Row(
                        children: [
                          Text('🔥', style: TextStyle(fontSize: 14 * s)),
                          SizedBox(width: 6 * s),
                          Text(
                            l10n.shareCardDayStreak(config.streakDays!),
                            style: TextStyle(
                              fontSize: 12 * s,
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

  Widget _macroText(String prefix, double value, double s) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${value.toInt()}',
          style: TextStyle(
            fontSize: 16 * s,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          prefix,
          style: TextStyle(
            fontSize: 10 * s,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }

  Widget _microRow(String label, String value, double s) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2 * s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 11 * s, color: Colors.white.withValues(alpha: 0.6))),
          Text(value, style: TextStyle(fontSize: 11 * s, fontWeight: FontWeight.w600, color: Colors.white70)),
        ],
      ),
    );
  }

  String _fmtNum(double v) {
    return v.toInt().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  String _fmtDate(BuildContext context, DateTime d) {
    return MaterialLocalizations.of(context).formatMediumDate(d);
  }
}
