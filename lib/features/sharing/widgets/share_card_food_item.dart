import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/ai/gemini_service.dart';
import '../../../core/database/app_database.dart';
import '../../../core/ar_scale/models/detected_object_label.dart';
import '../../../core/widgets/food_entry_image.dart';
import '../../../l10n/app_localizations.dart';
import '../models/share_card_config.dart';

class ShareCardFoodItem extends StatelessWidget {
  final ShareCardConfig config;

  const ShareCardFoodItem({super.key, required this.config});

  FoodEntryData get _entry => config.foodEntry!;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final ingredientLines =
        config.showIngredients ? _parseIngredientLines() : const <_ShareCardIngredientLine>[];

    // Match FoodEntryImageWithOverlay / simple_food_detail_sheet: per-image labels + native size + BoxFit.cover
    final detectionLabels = config.showHealthData
        ? ArImageDetectionData.labelsForImage(_entry.arLabelsJson, 0)
        : const <DetectedObjectLabel>[];
    final imgSize = ArImageDetectionData.imageSizeForImage(_entry.arLabelsJson, 0);
    final imgW = imgSize?.width ?? _entry.arImageWidth;
    final imgH = imgSize?.height ?? _entry.arImageHeight;
    final hasBoundingOverlay = detectionLabels.isNotEmpty &&
        imgW != null &&
        imgH != null &&
        imgW! > 0 &&
        imgH! > 0;

    final hasImage = _entry.imagePath != null &&
        _entry.imagePath!.isNotEmpty &&
        File(_entry.imagePath!).existsSync();

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        width: 1080 / 3,
        height: 1350 / 3,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background: image or gradient
            if (hasImage)
              Image.file(
                File(_entry.imagePath!),
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

            // Gradient scrim (bottom → up) for text readability
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
                      imageWidth: imgW!,
                      imageHeight: imgH!,
                      boxFit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

            // Branding badge (top-left)
            Positioned(
              top: 12,
              left: 12,
              child: _buildBrandBadge(),
            ),

            // Goal badge (top-right, optional)
            if (config.showGoalProgress && config.goalPercent != null)
              Positioned(
                top: 12,
                right: 12,
                child: _buildGoalBadge(config.goalPercent!),
              ),

            if (config.showIngredients && ingredientLines.isNotEmpty)
              Positioned(
                top: (config.showGoalProgress && config.goalPercent != null) ? 56 : 12,
                right: 12,
                child: _buildIngredientsPanel(l10n, ingredientLines),
              ),

            // Content overlay (bottom)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Food name
                  Text(
                    _entry.foodName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.15,
                      shadows: [
                        Shadow(blurRadius: 8, color: Colors.black54),
                      ],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),

                  // Kcal (left) + Macros (right) in one row
                  if (config.showCalories || config.showMacros)
                    Row(
                      children: [
                        if (config.showCalories)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _formatNumber(_entry.calories),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.kcal.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
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
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _macroLabel('P', _entry.protein),
                                const SizedBox(width: 16),
                                _macroLabel('C', _entry.carbs),
                                const SizedBox(width: 16),
                                _macroLabel('F', _entry.fat),
                              ],
                            ),
                          ),
                      ],
                    ),
                  const SizedBox(height: 8),

                  // Micro bar (optional)
                  if (config.showMicros && _hasMicros) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_entry.fiber != null && _entry.fiber! > 0)
                            _microLabel(l10n.shareCardFiber, _entry.fiber!, 'g'),
                          if (_entry.sugar != null && _entry.sugar! > 0) ...[
                            const SizedBox(width: 12),
                            _microLabel(l10n.shareCardSugar, _entry.sugar!, 'g'),
                          ],
                          if (_entry.sodium != null && _entry.sodium! > 0) ...[
                            const SizedBox(width: 12),
                            _microLabel(l10n.shareCardSodium, _entry.sodium!, 'mg'),
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

  bool get _hasMicros =>
      (_entry.fiber != null && _entry.fiber! > 0) ||
      (_entry.sugar != null && _entry.sugar! > 0) ||
      (_entry.sodium != null && _entry.sodium! > 0);

  Widget _buildBrandBadge() {
    return Transform.translate(
      offset: const Offset(0, -10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(
          'assets/icon/logo_with_store.png',
          width: 92,
          height: 92,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildGoalBadge(double percent) {
    final Color badgeColor;
    if (percent <= 100) {
      badgeColor = const Color(0xFF4CAF50);
    } else if (percent <= 120) {
      badgeColor = const Color(0xFFF59E0B);
    } else {
      badgeColor = const Color(0xFFF97316);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${percent.toInt()}% GOAL',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _macroLabel(String prefix, double value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          prefix,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(width: 3),
        Text(
          '${value.toInt()}g',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _microLabel(String name, double value, String unit) {
    return Text(
      '$name ${value.toInt()}$unit',
      style: TextStyle(
        fontSize: 11,
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
    if (raw == null || raw.isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];

      final out = <_ShareCardIngredientLine>[];

      void walk(IngredientDetail ing, int depth) {
        if (out.length >= _maxIngredientLines) return;
        final n = ing.name.trim();
        if (n.isNotEmpty) {
          out.add(_ShareCardIngredientLine(name: n, calories: ing.calories, depth: depth));
        }
        final subs = ing.subIngredients;
        if (subs != null) {
          for (final sub in subs) {
            walk(sub, depth + 1);
            if (out.length >= _maxIngredientLines) return;
          }
        }
      }

      for (final item in decoded) {
        if (out.length >= _maxIngredientLines) break;
        if (item is! Map) continue;
        walk(
          IngredientDetail.fromJson(Map<String, dynamic>.from(item)),
          0,
        );
      }

      return out;
    } catch (_) {
      return const [];
    }
  }

  Widget _buildIngredientsPanel(L10n l10n, List<_ShareCardIngredientLine> lines) {
    final showKcal = config.showCalories;
    return Container(
      constraints: const BoxConstraints(maxWidth: 148),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(12),
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
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          ...lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '${''.padLeft(line.depth * 2)}• ${line.name}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.88),
                        height: 1.2,
                      ),
                    ),
                  ),
                  if (showKcal) ...[
                    const SizedBox(width: 4),
                    Text(
                      _formatNumber(line.calories),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      l10n.kcal,
                      style: TextStyle(
                        fontSize: 7,
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
  final int depth;

  const _ShareCardIngredientLine({
    required this.name,
    required this.calories,
    required this.depth,
  });
}
