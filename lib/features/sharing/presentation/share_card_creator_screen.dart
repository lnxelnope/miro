import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/services/analytics_service.dart';
import '../../../l10n/app_localizations.dart';
import '../models/share_card_config.dart';
import '../services/card_capture_service.dart';
import '../widgets/share_card_food_item.dart';
import '../widgets/share_card_daily_summary.dart';
import '../widgets/share_card_nutrition_summary.dart';

class ShareCardCreatorScreen extends ConsumerStatefulWidget {
  final ShareCardConfig initialConfig;

  const ShareCardCreatorScreen({super.key, required this.initialConfig});

  @override
  ConsumerState<ShareCardCreatorScreen> createState() =>
      _ShareCardCreatorScreenState();
}

class _ShareCardCreatorScreenState
    extends ConsumerState<ShareCardCreatorScreen> {
  final GlobalKey _cardKey = GlobalKey();
  final ImagePicker _imagePicker = ImagePicker();
  late ShareCardConfig _config;
  bool _isProcessing = false;
  bool get _requiresHeroImage => _config.type == ShareCardType.nutritionSummary;
  bool get _hasValidHeroImage =>
      _config.heroImagePath != null &&
      _config.heroImagePath!.isNotEmpty &&
      File(_config.heroImagePath!).existsSync();

  @override
  void initState() {
    super.initState();
    _config = widget.initialConfig;
    AnalyticsService.logShareCard(
      eventName: 'share_card_opened',
      params: {'type': _config.type.name},
    );
  }

  Future<void> _share() async {
    if (_isProcessing) return;
    if (_requiresHeroImage && !_hasValidHeroImage) {
      _showRequiredImageSnack();
      return;
    }
    setState(() => _isProcessing = true);

    final success = await CardCaptureService.shareCard(_cardKey);

    if (success) {
      HapticFeedback.mediumImpact();
      AnalyticsService.logShareCard(
        eventName: 'share_card_shared',
        params: {'type': _config.type.name},
      );
    }

    if (mounted) setState(() => _isProcessing = false);
  }

  Future<void> _saveToGallery() async {
    if (_isProcessing) return;
    if (_requiresHeroImage && !_hasValidHeroImage) {
      _showRequiredImageSnack();
      return;
    }
    setState(() => _isProcessing = true);

    final success = await CardCaptureService.saveToGallery(_cardKey);

    if (mounted) {
      setState(() => _isProcessing = false);
      final l10n = L10n.of(context)!;
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? l10n.savedToGallery : l10n.saveFailed,
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      if (success) {
        AnalyticsService.logShareCard(
          eventName: 'share_card_saved',
          params: {'type': _config.type.name},
        );
      }
    }
  }

  void _showRequiredImageSnack() {
    final l10n = L10n.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.shareSelectImageRequired)),
    );
  }

  Future<void> _pickHeroFromGallery() async {
    try {
      final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;
      if (!mounted) return;
      setState(() {
        _config = _config.copyWith(heroImagePath: picked.path);
      });
    } catch (_) {
      if (!mounted) return;
      final l10n = L10n.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cameraFailedToPickFromGallery)),
      );
    }
  }

  Widget _buildDailyHeroSelector(L10n l10n, bool isDark) {
    final dayPhotos = _config.selectedFoodPhotos
        .where((p) => p.isNotEmpty && File(p).existsSync())
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickHeroFromGallery,
                  icon: const Icon(Icons.photo_library_outlined, size: 18),
                  label: Text(l10n.gallery),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isDark ? Colors.white24 : AppColors.divider,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
                  ),
                ),
              ),
              if (_config.heroImagePath != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    setState(() => _config = _config.copyWith(clearHeroImage: true));
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ],
          ),
          if (dayPhotos.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 58,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: dayPhotos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, index) {
                  final path = dayPhotos[index];
                  final isSelected = _config.heroImagePath == path;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _config = _config.copyWith(heroImagePath: path));
                    },
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark ? Colors.white24 : AppColors.divider),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: Image.file(File(path), fit: BoxFit.cover),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNutritionHeroSelector(L10n l10n, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _hasValidHeroImage ? l10n.shareImageSelected : l10n.shareNoImageSelected,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _hasValidHeroImage
                  ? AppColors.primary
                  : (isDark ? Colors.white70 : AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickHeroFromGallery,
                  icon: const Icon(Icons.photo_library_outlined, size: 18),
                  label: Text(l10n.gallery),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isDark ? Colors.white24 : AppColors.divider,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
                  ),
                ),
              ),
              if (_hasValidHeroImage) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    setState(() => _config = _config.copyWith(clearHeroImage: true));
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardPreview() {
    switch (_config.type) {
      case ShareCardType.foodItem:
        return ShareCardFoodItem(config: _config);
      case ShareCardType.dailySummary:
        return ShareCardDailySummary(config: _config);
      case ShareCardType.nutritionSummary:
        return ShareCardNutritionSummary(config: _config);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text(l10n.shareCard),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Card preview (centered, scaled)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: RepaintBoundary(
                      key: _cardKey,
                      child: _buildCardPreview(),
                    ),
                  ),
                ),
              ),
            ),

            if (_config.type == ShareCardType.dailySummary) ...[
              _buildDailyHeroSelector(l10n, isDark),
              const SizedBox(height: 8),
            ],
            if (_config.type == ShareCardType.nutritionSummary) ...[
              _buildNutritionHeroSelector(l10n, isDark),
              const SizedBox(height: 8),
            ],

            // Toggles
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _toggleRow(
                    l10n.macros,
                    _config.showMacros,
                    (v) => setState(() => _config = _config.copyWith(showMacros: v)),
                  ),
                  _toggleRow(
                    l10n.micronutrients,
                    _config.showMicros,
                    (v) => setState(() => _config = _config.copyWith(showMicros: v)),
                  ),
                  if (_config.type == ShareCardType.foodItem)
                    _toggleRow(
                      l10n.ingredients,
                      _config.showIngredients,
                      (v) => setState(() => _config = _config.copyWith(showIngredients: v)),
                    ),
                  if (_config.type == ShareCardType.foodItem && _config.mealBudget != null)
                    _toggleRow(
                      '% Goal',
                      _config.showGoalProgress,
                      (v) => setState(() => _config = _config.copyWith(showGoalProgress: v)),
                    ),
                  if (_config.type != ShareCardType.foodItem)
                    _toggleRow(
                      'Streak',
                      _config.showStreak,
                      (v) => setState(() => _config = _config.copyWith(showStreak: v)),
                    ),
                  if (_config.type != ShareCardType.foodItem && _config.calorieGoal != null)
                    _toggleRow(
                      '% Goal',
                      _config.showGoalProgress,
                      (v) => setState(() => _config = _config.copyWith(showGoalProgress: v)),
                    ),
                  if (_config.type == ShareCardType.foodItem)
                    _toggleRow(
                      l10n.shareCardShowBoundingBox,
                      _config.showHealthData,
                      (v) => setState(() => _config = _config.copyWith(showHealthData: v)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  // Save to gallery
                  Expanded(
                    child: SizedBox(
                      height: AppSizes.buttonLarge,
                      child: OutlinedButton.icon(
                        onPressed: _isProcessing ? null : _saveToGallery,
                        icon: _isProcessing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.save_alt_rounded, size: 20),
                        label: Text(l10n.saveToGallery),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.md,
                          ),
                          side: BorderSide(
                            color: isDark ? Colors.white24 : AppColors.divider,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Share
                  Expanded(
                    child: SizedBox(
                      height: AppSizes.buttonLarge,
                      child: FilledButton.icon(
                        onPressed: _isProcessing ? null : _share,
                        icon: _isProcessing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : const Icon(Icons.share_rounded, size: 20),
                        label: Text(l10n.share),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.md,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : AppColors.textPrimary,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
