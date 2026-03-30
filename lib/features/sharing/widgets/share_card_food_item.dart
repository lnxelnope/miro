import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/model_extensions.dart';
import '../../../core/ar_scale/models/detected_object_label.dart';
import '../../../core/widgets/food_entry_image.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../core/nutrition/ingredients_codec.dart';
import '../models/share_card_config.dart';
import 'share_card_brand_badge.dart';
import 'share_card_referral_line.dart';

class ShareCardFoodItem extends StatelessWidget {
  final ShareCardConfig config;

  const ShareCardFoodItem({super.key, required this.config});

  FoodEntryData get _entry => config.foodEntry!;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final s = config.layoutScale;
    final cardSize = config.logicalSize;
    final ingredientLines =
        config.showIngredients ? _parseIngredientLines() : const <_ShareCardIngredientLine>[];

    final paths = _entry.allImagePaths;
    final heroFromConfig = config.heroImagePath;
    String? displayPath;
    if (heroFromConfig != null &&
        heroFromConfig.isNotEmpty &&
        File(heroFromConfig).existsSync()) {
      displayPath = heroFromConfig;
    } else if (_entry.imagePath != null &&
        _entry.imagePath!.isNotEmpty &&
        File(_entry.imagePath!).existsSync()) {
      displayPath = _entry.imagePath;
    }

    var overlayIndex = 0;
    if (displayPath != null && paths.isNotEmpty) {
      final idx = paths.indexOf(displayPath);
      if (idx >= 0) overlayIndex = idx;
    }

    // Match FoodEntryImageWithOverlay / simple_food_detail_sheet: per-image labels + BoxFit.cover
    final detectionLabels = config.showHealthData
        ? ArImageDetectionData.labelsForImage(_entry.arLabelsJson, overlayIndex)
        : const <DetectedObjectLabel>[];
    final imgSize =
        ArImageDetectionData.imageSizeForImage(_entry.arLabelsJson, overlayIndex);
    final imgW = imgSize?.width ?? _entry.arImageWidth;
    final imgH = imgSize?.height ?? _entry.arImageHeight;
    final hasBoundingOverlay = detectionLabels.isNotEmpty &&
        imgW != null &&
        imgH != null &&
        imgW > 0 &&
        imgH > 0;

    final shareImagePath = (displayPath != null && File(displayPath).existsSync())
        ? displayPath
        : null;

    final servingLabel = config.showServingOnImage &&
            _entry.servingSize > 0 &&
            _entry.servingUnit.isNotEmpty
        ? l10n.servingDisplay(
            _fmtServingSize(_entry.servingSize),
            UnitConverter.displayLabel(
              UnitConverter.ensureValid(_entry.servingUnit),
            ),
          )
        : null;

    final ingTop = (config.showGoalProgress && config.goalPercent != null) ? 56.0 * s : 12.0 * s;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        width: cardSize.width,
        height: cardSize.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (shareImagePath != null)
              Positioned.fill(
                child: Image.file(
                  File(shareImagePath),
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
                    stops: const [0.0, 0.35, 0.65, 1.0],
                    colors: [
                      Colors.black.withValues(alpha: 0.4),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),
            ),

            if (hasBoundingOverlay)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: BoundingBoxPainter(
                      labels: detectionLabels,
                      imageWidth: imgW,
                      imageHeight: imgH,
                      boxFit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

            Positioned(
              top: 12 * s,
              left: 12 * s,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ShareCardBrandBadge(layoutScale: s),
                  ShareCardReferralLine(
                    referralCode: config.referralCode,
                    layoutScale: s,
                    compactBelowLogo: true,
                  ),
                ],
              ),
            ),

            if (config.showGoalProgress && config.goalPercent != null)
              Positioned(
                top: 12 * s,
                right: 12 * s,
                child: _buildGoalBadge(config.goalPercent!, s),
              ),

            if (config.showIngredients && ingredientLines.isNotEmpty)
              Positioned(
                top: ingTop,
                right: 12 * s,
                child: _buildIngredientsPanel(l10n, ingredientLines, s),
              ),

            Positioned(
              left: 16 * s,
              right: 16 * s,
              bottom: 16 * s,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _entry.foodName,
                    style: TextStyle(
                      fontSize: 28 * s,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.15,
                      shadows: [
                        Shadow(blurRadius: 8 * s, color: Colors.black54),
                      ],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (servingLabel != null) ...[
                    SizedBox(height: 6 * s),
                    Text(
                      servingLabel,
                      style: TextStyle(
                        fontSize: 15 * s,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        shadows: [
                          Shadow(blurRadius: 6 * s, color: Colors.black87),
                          Shadow(blurRadius: 2 * s, color: Colors.black54),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 10 * s),

                  if (config.showCalories || config.showMacros)
                    Row(
                      children: [
                        if (config.showCalories)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 6 * s),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              borderRadius: BorderRadius.circular(20 * s),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatNumber(_entry.calories),
                                  style: TextStyle(
                                    fontSize: 18 * s,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 4 * s),
                                Text(
                                  l10n.kcal.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10 * s,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white70,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (config.showCalories && config.showMacros) const Spacer(),
                        if (config.showMacros)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 8 * s),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12 * s),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _macroLabel('P', _entry.protein, s),
                                SizedBox(width: 16 * s),
                                _macroLabel('C', _entry.carbs, s),
                                SizedBox(width: 16 * s),
                                _macroLabel('F', _entry.fat, s),
                              ],
                            ),
                          ),
                      ],
                    ),
                  SizedBox(height: 8 * s),

                  if (config.showMicros && _hasMicros) ...[
                    SizedBox(height: 6 * s),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 6 * s),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12 * s),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_entry.fiber != null && _entry.fiber! > 0)
                            _microLabel(l10n.shareCardFiber, _entry.fiber!, 'g', s),
                          if (_entry.sugar != null && _entry.sugar! > 0) ...[
                            SizedBox(width: 12 * s),
                            _microLabel(l10n.shareCardSugar, _entry.sugar!, 'g', s),
                          ],
                          if (_entry.sodium != null && _entry.sodium! > 0) ...[
                            SizedBox(width: 12 * s),
                            _microLabel(l10n.shareCardSodium, _entry.sodium!, 'mg', s),
                          ],
                        ],
                      ),
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

  static String _fmtServingSize(double v) {
    if (v == v.roundToDouble()) return v.round().toString();
    return v.toStringAsFixed(1);
  }

  bool get _hasMicros =>
      (_entry.fiber != null && _entry.fiber! > 0) ||
      (_entry.sugar != null && _entry.sugar! > 0) ||
      (_entry.sodium != null && _entry.sodium! > 0);

  Widget _buildGoalBadge(double percent, double s) {
    final Color badgeColor;
    if (percent <= 100) {
      badgeColor = const Color(0xFF4CAF50);
    } else if (percent <= 120) {
      badgeColor = const Color(0xFFF59E0B);
    } else {
      badgeColor = const Color(0xFFF97316);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 6 * s),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(8 * s),
      ),
      child: Text(
        '${percent.toInt()}% GOAL',
        style: TextStyle(
          fontSize: 11 * s,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _macroLabel(String prefix, double value, double s) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          prefix,
          style: TextStyle(
            fontSize: 11 * s,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        SizedBox(width: 3 * s),
        Text(
          '${value.toInt()}g',
          style: TextStyle(
            fontSize: 14 * s,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _microLabel(String name, double value, String unit, double s) {
    return Text(
      '$name ${value.toInt()}$unit',
      style: TextStyle(
        fontSize: 11 * s,
        fontWeight: FontWeight.w500,
        color: Colors.white.withValues(alpha: 0.7),
      ),
    );
  }

  String _formatNumber(double value) {
    if (value >= 10000) return '${(value / 1000).toStringAsFixed(1)}k';
    return value.toInt().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  static const int _maxIngredientLines = 6;

  List<_ShareCardIngredientLine> _parseIngredientLines() {
    final raw = _entry.ingredientsJson;
    if (raw == null || raw.trim().isEmpty) return const [];

    final parsed = parseIngredientsJson(raw);
    final doc = parsed.documentV2;
    if (doc == null || doc.mainIngredients.isEmpty) return const [];

    final out = <_ShareCardIngredientLine>[];

    // Share card: top-level mains only (sub-ingredients clutter the small panel).
    for (final main in doc.mainIngredients) {
      if (out.length >= _maxIngredientLines) break;
      final n = main.name.trim();
      if (n.isNotEmpty) {
        out.add(_ShareCardIngredientLine(
          name: n,
          calories: main.calories,
        ));
      }
    }

    return out;
  }

  Widget _buildIngredientsPanel(L10n l10n, List<_ShareCardIngredientLine> lines, double s) {
    final showKcal = config.showCalories;
    return Container(
      constraints: BoxConstraints(maxWidth: 148 * s),
      padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 8 * s),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.16),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.ingredients,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10 * s,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.4,
            ),
          ),
          SizedBox(height: 4 * s),
          ...lines.map(
            (line) => Padding(
              padding: EdgeInsets.only(bottom: 2 * s),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '• ${line.name}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9 * s,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.88),
                        height: 1.2,
                      ),
                    ),
                  ),
                  if (showKcal) ...[
                    SizedBox(width: 4 * s),
                    Text(
                      _formatNumber(line.calories),
                      style: TextStyle(
                        fontSize: 9 * s,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 2 * s),
                    Text(
                      l10n.kcal,
                      style: TextStyle(
                        fontSize: 7 * s,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareCardIngredientLine {
  final String name;
  final double calories;

  const _ShareCardIngredientLine({
    required this.name,
    required this.calories,
  });
}
