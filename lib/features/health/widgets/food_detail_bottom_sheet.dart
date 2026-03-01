import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/theme/app_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../core/constants/enums.dart';
import '../../../core/widgets/search_mode_selector.dart';
import '../../../core/widgets/food_entry_image.dart';
import '../../../core/ai/gemini_service.dart';
import '../../../core/ar_scale/models/detected_object_label.dart';
import '../models/food_entry.dart';
import '../providers/health_provider.dart';
import '../providers/analysis_provider.dart';
import '../providers/my_meal_provider.dart';

class FoodDetailBottomSheet extends ConsumerStatefulWidget {
  final FoodEntry entry;
  final Function(FoodEntry)? onEdit;
  final Function(FoodEntry)? onDelete;
  final Function(FoodEntry)? onAnalyze;
  final DateTime? selectedDate;

  const FoodDetailBottomSheet({
    super.key,
    required this.entry,
    this.onEdit,
    this.onDelete,
    this.onAnalyze,
    this.selectedDate,
  });

  @override
  ConsumerState<FoodDetailBottomSheet> createState() =>
      _FoodDetailBottomSheetState();
}

class _FoodDetailBottomSheetState extends ConsumerState<FoodDetailBottomSheet>
    with SingleTickerProviderStateMixin {
  bool _isAnalyzing = false;
  bool _notesExpanded = false;
  bool _ingredientsExpanded = false;
  final Set<int> _expandedSubIndices = {};

  List<IngredientDetail>? _cachedIngredients;
  bool _loadedFromMeal = false;

  @override
  void initState() {
    super.initState();
    _loadIngredients();
  }

  void _loadIngredients() {
    final entry = widget.entry;

    // ถ้ามี ingredientsJson → parse ตรงๆ
    final parsed = _parseIngredientsFromJson(entry);
    if (parsed.isNotEmpty) {
      _cachedIngredients = parsed;
      _fixCaloriesIfMismatch(entry, parsed);
      return;
    }

    // ถ้าไม่มี ingredientsJson แต่มี myMealId → โหลดจาก database
    if (entry.myMealId != null && !_loadedFromMeal) {
      _loadedFromMeal = true;
      _loadIngredientsFromMeal(entry.myMealId!);
    }
  }

  /// ถ้าผลรวม ingredients ไม่ตรงกับ entry.calories → แก้ไข entry ให้ตรง
  void _fixCaloriesIfMismatch(FoodEntry entry, List<IngredientDetail> ingredients) {
    if (ingredients.isEmpty) return;

    double sumCal = 0, sumP = 0, sumC = 0, sumF = 0;
    for (final ing in ingredients) {
      sumCal += ing.calories;
      sumP += ing.protein;
      sumC += ing.carbs;
      sumF += ing.fat;
    }

    if (sumCal <= 0) return;

    final diff = (entry.calories - sumCal).abs();
    if (diff < 1) return;

    AppLogger.info(
        '[DetailSheet] Fixing calories mismatch: entry=${entry.calories.toInt()} vs sum=${sumCal.toInt()} (diff=${diff.toInt()})');

    entry.calories = sumCal;
    entry.protein = sumP;
    entry.carbs = sumC;
    entry.fat = sumF;

    final serving = entry.servingSize > 0 ? entry.servingSize : 1.0;
    entry.baseCalories = sumCal / serving;
    entry.baseProtein = sumP / serving;
    entry.baseCarbs = sumC / serving;
    entry.baseFat = sumF / serving;

    // fire-and-forget: update in DB
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(foodEntriesNotifierProvider.notifier).updateFoodEntry(entry).then((_) {
        final date = dateOnly(entry.timestamp);
        ref.invalidate(foodEntriesByDateProvider(date));
        ref.invalidate(healthTimelineProvider(date));
        ref.invalidate(todayCaloriesProvider);
        ref.invalidate(todayMacrosProvider);
      });
    });
  }

  Future<void> _loadIngredientsFromMeal(int mealId) async {
    try {
      final tree = await ref.read(mealIngredientTreeProvider(mealId).future);
      if (tree.isNotEmpty && mounted) {
        setState(() {
          _cachedIngredients = tree.map((node) {
            return IngredientDetail(
              name: node.ingredient.ingredientName,
              detail: node.ingredient.detail,
              amount: node.ingredient.amount,
              unit: node.ingredient.unit,
              calories: node.ingredient.calories,
              protein: node.ingredient.protein,
              carbs: node.ingredient.carbs,
              fat: node.ingredient.fat,
              subIngredients: node.children.isNotEmpty
                  ? node.children.map((child) {
                      return IngredientDetail(
                        name: child.ingredientName,
                        detail: child.detail,
                        amount: child.amount,
                        unit: child.unit,
                        calories: child.calories,
                        protein: child.protein,
                        carbs: child.carbs,
                        fat: child.fat,
                      );
                    }).toList()
                  : null,
            );
          }).toList();
        });
      }
    } catch (e) {
      AppLogger.warn('Failed to load ingredients from myMealId: $e');
    }
  }

  Widget _buildCloseButton(bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.close, size: 20,
          color: isDark ? Colors.white70 : Colors.grey.shade600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final hasImage = entry.hasAnyImage;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasNotes = entry.notes != null && entry.notes!.isNotEmpty;
    final hasAiConfidence =
        entry.aiConfidence != null && entry.aiConfidence! > 0;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle + close
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4, right: 12),
            child: Row(
              children: [
                const Spacer(),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _buildCloseButton(isDark),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === Image (if available) — tap to view full screen, tap again to close ===
                  if (hasImage) ...[
                    GestureDetector(
                      onTap: () => showFoodEntryImage(context, entry),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            FoodEntryImage(
                              entry: entry,
                              width: double.infinity,
                              height: 220,
                              borderRadius: BorderRadius.circular(16),
                              placeholder: _buildImagePlaceholder(isDark),
                            ),
                          // Gradient overlay at bottom of image
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.4),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Verified badge overlay
                          if (entry.isVerified)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: _buildVerifiedChip(),
                            ),
                        ],
                      ),
                    ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // === Food Name + Meta ===
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Meal type emoji
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.health.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          entry.mealType.icon,
                          color: entry.mealType.iconColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.foodName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 14,
                                  color: isDark
                                      ? Colors.white38
                                      : AppColors.textTertiary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatTime(entry.timestamp),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.white54
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  width: 3,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white24
                                        : AppColors.textTertiary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Text(
                                  entry.mealType.displayName,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.white54
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                if (!hasImage && entry.isVerified) ...[
                                  const SizedBox(width: 8),
                                  _buildVerifiedChip(),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // === Calories Hero Card ===
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.health.withValues(alpha: 0.12),
                          AppColors.health.withValues(alpha: 0.04),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.health.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(AppIcons.calories, size: 36, color: AppIcons.caloriesColor),
                        const SizedBox(width: 12),
                        Text(
                          '${entry.calories.toInt()}',
                          style: const TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                            color: AppColors.health,
                            letterSpacing: -1,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            'kcal',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // === Macros Row ===
                  Row(
                    children: [
                      Expanded(
                          child: _buildMacroChip(
                              'Protein', entry.protein, AppColors.protein, isDark)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _buildMacroChip(
                              'Carbs', entry.carbs, AppColors.carbs, isDark)),
                      const SizedBox(width: 8),
                      Expanded(
                          child:
                              _buildMacroChip('Fat', entry.fat, AppColors.fat, isDark)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // === AR Detection Info (ซ่อนไว้ กดเพื่อดู) ===
                  _buildDetectionInfoTile(entry, isDark),

                  // === Serving Size ===
                  if (entry.servingSize > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.straighten_rounded,
                            size: 18,
                            color: isDark
                                ? Colors.white38
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Amount',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.white54
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${entry.servingSize % 1 == 0 ? entry.servingSize.toInt() : entry.servingSize} ${entry.servingUnit}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color:
                                  isDark ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // === Ingredients Section (collapsible) ===
                  if (_cachedIngredients != null && _cachedIngredients!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildIngredientsSection(_cachedIngredients!, isDark),
                  ],

                  // === AI Confidence Badge ===
                  if (hasAiConfidence) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF6366F1).withValues(alpha: 0.1)
                            : const Color(0xFF6366F1).withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            size: 18,
                            color: Color(0xFF6366F1),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'AI Confidence',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? Colors.white54
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${(entry.aiConfidence! * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF6366F1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // === Notes (collapsible) ===
                  if (hasNotes) ...[
                    const SizedBox(height: 12),
                    _buildCollapsibleNotes(entry.notes!, isDark),
                  ],

                  const SizedBox(height: 24),

                  // === Elegant Action Bar ===
                  _buildActionBar(isDark),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Verified Chip
  // ============================================================
  Widget _buildVerifiedChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, size: 14, color: AppColors.success),
          SizedBox(width: 4),
          Text(
            'AI Verified',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Image Placeholder
  // ============================================================
  Widget _buildImagePlaceholder(bool isDark) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.health.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Icon(
          Icons.restaurant_rounded,
          size: 56,
          color: AppColors.health.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  // ============================================================
  // AR Detection Info (collapsible)
  // ============================================================
  Widget _buildDetectionInfoTile(FoodEntry entry, bool isDark) {
    debugPrint(
      '>>> [DetectionInfo] arLabelsJson=${entry.arLabelsJson?.length ?? 0} chars, '
      'arImgW=${entry.arImageWidth}, arImgH=${entry.arImageHeight}',
    );
    final labels = DetectedObjectLabel.decode(entry.arLabelsJson);
    debugPrint('>>> [DetectionInfo] decoded ${labels.length} labels');
    if (labels.isEmpty) return const SizedBox.shrink();

    final pixelPerCm = entry.arPixelPerCm;
    final hasCalibration = pixelPerCm != null && pixelPerCm > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.grey.shade200,
            ),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            childrenPadding:
                const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 14),
            leading: Icon(
              Icons.precision_manufacturing_rounded,
              size: 20,
              color: isDark ? Colors.white54 : AppColors.textSecondary,
            ),
            title: Text(
              'Object Detection (${labels.length})',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              hasCalibration ? 'Calibrated' : 'Uncalibrated',
              style: TextStyle(
                fontSize: 11,
                color: hasCalibration
                    ? AppColors.health
                    : (isDark ? Colors.white38 : AppColors.textTertiary),
              ),
            ),
            children: [
              for (final obj in labels)
                _buildDetectedObjectRow(obj, pixelPerCm, isDark),
              if (hasCalibration)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(Icons.straighten_rounded,
                          size: 14,
                          color: isDark
                              ? Colors.white38
                              : AppColors.textTertiary),
                      const SizedBox(width: 6),
                      Text(
                        '1 cm = ${pixelPerCm.toStringAsFixed(1)} px',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? Colors.white38
                              : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetectedObjectRow(
      DetectedObjectLabel obj, double? pixelPerCm, bool isDark) {
    final confPct = (obj.confidence * 100).toStringAsFixed(0);

    String sizeStr;
    if (pixelPerCm != null && pixelPerCm > 0) {
      final wCm = (obj.bboxWidth / pixelPerCm).toStringAsFixed(1);
      final hCm = (obj.bboxHeight / pixelPerCm).toStringAsFixed(1);
      sizeStr = '$wCm × $hCm cm';
    } else {
      sizeStr = '${obj.bboxWidth.toInt()} × ${obj.bboxHeight.toInt()} px';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.health,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              obj.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            sizeStr,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white54 : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.health.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$confPct%',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.health,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Macro Chip
  // ============================================================
  Widget _buildMacroChip(String label, double value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '${value.toInt()}g',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // Parse Ingredients from JSON
  // ============================================================
  List<IngredientDetail> _parseIngredientsFromJson(FoodEntry entry) {
    if (entry.ingredientsJson == null || entry.ingredientsJson!.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> list = jsonDecode(entry.ingredientsJson!);
      return list.map((e) => IngredientDetail.fromJson(e)).toList();
    } catch (e) {
      AppLogger.warn('Failed to parse ingredientsJson: $e');
      return [];
    }
  }

  // ============================================================
  // Ingredients Section (Collapsible)
  // ============================================================
  Widget _buildIngredientsSection(List<IngredientDetail> ingredients, bool isDark) {
    const headerColor = Color(0xFF10B981);

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : headerColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : headerColor.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header (tap to toggle)
          GestureDetector(
            onTap: () => setState(() => _ingredientsExpanded = !_ingredientsExpanded),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.restaurant_menu_rounded,
                    size: 18,
                    color: headerColor,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Ingredients',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: headerColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${ingredients.length}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: headerColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: _ingredientsExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: isDark ? Colors.white38 : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Ingredient list (animated)
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity, height: 0),
            secondChild: _buildIngredientList(ingredients, isDark),
            crossFadeState: _ingredientsExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientList(List<IngredientDetail> ingredients, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(
            height: 1,
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.withValues(alpha: 0.15),
          ),
          const SizedBox(height: 6),
          ...ingredients.asMap().entries.map((e) {
            final idx = e.key;
            final ingredient = e.value;
            final hasSub = ingredient.subIngredients != null &&
                ingredient.subIngredients!.isNotEmpty;
            final isSubExpanded = _expandedSubIndices.contains(idx);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Main ingredient row
                GestureDetector(
                  onTap: hasSub
                      ? () => setState(() {
                            if (isSubExpanded) {
                              _expandedSubIndices.remove(idx);
                            } else {
                              _expandedSubIndices.add(idx);
                            }
                          })
                      : null,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: Row(
                      children: [
                        // Expand arrow for sub-ingredients
                        if (hasSub)
                          AnimatedRotation(
                            turns: isSubExpanded ? 0.25 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12,
                              color: isDark ? Colors.white38 : Colors.grey,
                            ),
                          )
                        else
                          Icon(
                            Icons.circle,
                            size: 6,
                            color: isDark ? Colors.white24 : Colors.grey[400],
                          ),
                        const SizedBox(width: 8),
                        // Name + amount
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ingredient.name,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${ingredient.amount % 1 == 0 ? ingredient.amount.toInt() : ingredient.amount} ${ingredient.unit}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.white38 : AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Calories
                        Text(
                          '${ingredient.calories.toInt()} kcal',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white60 : AppColors.textSecondary,
                          ),
                        ),
                        if (hasSub) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${ingredient.subIngredients!.length}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white38 : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Sub-ingredients (animated)
                if (hasSub)
                  AnimatedCrossFade(
                    firstChild: const SizedBox(width: double.infinity, height: 0),
                    secondChild: _buildSubIngredients(ingredient.subIngredients!, isDark),
                    crossFadeState: isSubExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 200),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSubIngredients(List<IngredientDetail> subs, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(left: 20, bottom: 4),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.2),
            width: 2,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: subs.map((sub) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 4,
                  color: isDark ? Colors.white24 : Colors.grey[400],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sub.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${sub.amount % 1 == 0 ? sub.amount.toInt() : sub.amount} ${sub.unit}',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.white30 : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${sub.calories.toInt()} kcal',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // Collapsible Notes Section
  // ============================================================
  Widget _buildCollapsibleNotes(String notes, bool isDark) {
    final isLong = notes.length > 80;

    return GestureDetector(
      onTap: isLong
          ? () => setState(() => _notesExpanded = !_notesExpanded)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : const Color(0xFFF8F9FB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFE8EDF2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: isDark ? Colors.white38 : AppColors.textTertiary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Additional Details',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white54 : AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                if (isLong)
                  AnimatedRotation(
                    turns: _notesExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: isDark ? Colors.white38 : AppColors.textTertiary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            AnimatedCrossFade(
              firstChild: Text(
                notes,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: isDark ? Colors.white60 : AppColors.textSecondary,
                ),
              ),
              secondChild: Text(
                notes,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: isDark ? Colors.white60 : AppColors.textSecondary,
                ),
              ),
              crossFadeState: _notesExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
            if (isLong && !_notesExpanded)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Tap to read more',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primary.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Elegant Action Bar
  // ============================================================
  Widget _buildActionBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Edit button
          Expanded(
            child: _buildActionButton(
              icon: Icons.edit_rounded,
              label: 'Edit',
              color: AppColors.primary,
              isDark: isDark,
              onTap: _handleEdit,
            ),
          ),
          const SizedBox(width: 4),
          // AI Analysis button
          Expanded(
            child: _buildActionButton(
              icon: Icons.auto_awesome_rounded,
              label: 'AI',
              color: const Color(0xFF6366F1),
              isDark: isDark,
              onTap: _handleAnalyze,
              isLoading: _isAnalyzing,
            ),
          ),
          const SizedBox(width: 4),
          // Delete button
          Expanded(
            child: _buildActionButton(
              icon: Icons.delete_outline_rounded,
              label: 'Delete',
              color: AppColors.error,
              isDark: isDark,
              onTap: _handleDelete,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.12 : 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              else
                Icon(icon, size: 22, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // Format Time
  // ============================================================
  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // ============================================================
  // Handlers
  // ============================================================
  void _handleEdit() {
    Navigator.pop(context, {'action': 'edit', 'entry': widget.entry});
  }

  Future<void> _handleAnalyze() async {
    if (_isAnalyzing) return;

    final entry = widget.entry;

    // ถ้ามี onAnalyze callback (เรียกจาก Timeline)
    if (widget.onAnalyze != null) {
      Navigator.pop(context);
      await widget.onAnalyze!(entry);
      return;
    }

    // ถ้าวิเคราะห์แล้ว ให้ถามยืนยันก่อน
    if (entry.isVerified && mounted) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 12),
              Text('Re-analyze?'),
            ],
          ),
          content: const Text(
            'This food has already been analyzed.\n\n'
            'Analyzing again will use 1 Energy.\n\n'
            'Continue?',
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Re-analyze (1 Energy)'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
    }

    // Apply confirmed params before enqueueing
    if (!mounted) return;
    final analyzeParams = await _showAnalyzeConfirmation(entry);
    if (analyzeParams == null) return;

    final String confirmedFoodName = analyzeParams['foodName'] as String;
    final double confirmedQuantity = analyzeParams['quantity'] as double;
    final String confirmedUnit = analyzeParams['unit'] as String;
    final FoodSearchMode confirmedSearchMode =
        analyzeParams['searchMode'] as FoodSearchMode? ?? FoodSearchMode.normal;

    // Update entry with confirmed params before enqueue
    if (confirmedFoodName.isNotEmpty) entry.foodName = confirmedFoodName;
    if (confirmedQuantity > 0) entry.servingSize = confirmedQuantity;
    entry.servingUnit = confirmedUnit;
    entry.searchMode = confirmedSearchMode;
    await ref.read(foodEntriesNotifierProvider.notifier).updateFoodEntry(entry);

    if (!mounted) return;

    final selectedDate = widget.selectedDate ?? dateOnly(DateTime.now());
    ref.read(analysisProvider.notifier).enqueue(
      entries: [entry],
      selectedDate: selectedDate,
    );

    Navigator.pop(context);
  }

  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded,
                color: AppColors.error, size: 24),
            SizedBox(width: 12),
            Text('Delete Entry?'),
          ],
        ),
        content: Text(
          'Delete "${widget.entry.foodName}"?',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        if (widget.onDelete != null) {
          await widget.onDelete!(widget.entry);
        } else {
          final notifier = ref.read(foodEntriesNotifierProvider.notifier);
          await notifier.deleteFoodEntry(widget.entry.id);

          if (!mounted) return;

          if (widget.selectedDate != null) {
            ref.invalidate(foodEntriesByDateProvider(widget.selectedDate!));
            ref.invalidate(healthTimelineProvider(widget.selectedDate!));
          }
          ref.invalidate(todayCaloriesProvider);
          ref.invalidate(todayMacrosProvider);
        }

        if (!mounted) return;
        Navigator.pop(context);
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Entry deleted'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// แสดง Confirmation Dialog ก่อนส่งวิเคราะห์
  Future<Map<String, dynamic>?> _showAnalyzeConfirmation(
      FoodEntry entry) async {
    final foodNameController = TextEditingController(
      text: entry.foodName == 'food' ? '' : entry.foodName,
    );
    final quantityController = TextEditingController(
      text: entry.servingSize > 0 ? entry.servingSize.toString() : '',
    );
    final entryUnit =
        entry.servingUnit.isNotEmpty ? entry.servingUnit : 'serving';
    final validatedUnit = UnitConverter.ensureValid(entryUnit);
    String selectedUnit = validatedUnit;

    final hasImage = entry.hasAnyImage;
    FoodSearchMode searchMode = entry.searchMode; // Pre-fill from entry

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final theme = Theme.of(ctx);
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6366F1)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.auto_awesome_rounded,
                                color: Color(0xFF6366F1), size: 22),
                          ),
                          const SizedBox(width: 12),
                          Text('Analyze with AI',
                              style: theme.textTheme.titleLarge),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (hasImage) ...[
                        FoodEntryImage(
                          entry: entry,
                          width: double.infinity,
                          height: 150,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        const SizedBox(height: 16),
                      ],

                      const Text('Food Name',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 4),
                      TextField(
                        controller: foodNameController,
                        decoration: InputDecoration(
                          hintText: 'e.g. Pad Krapow, Salmon Sushi...',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Search Mode Toggle
                      SearchModeSelector(
                        selectedMode: searchMode,
                        onChanged: (mode) =>
                            setDialogState(() => searchMode = mode),
                      ),
                      const SizedBox(height: 12),

                      const Text('Quantity',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 4),
                      TextField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'e.g. 300',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Text(
                          _cachedIngredients != null && _cachedIngredients!.isNotEmpty
                              ? 'Unit 🔒'
                              : 'Unit',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        initialValue: selectedUnit,
                        isExpanded: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          isDense: true,
                        ),
                        items: UnitConverter.allDropdownItems,
                        onChanged: _cachedIngredients != null && _cachedIngredients!.isNotEmpty
                            ? null
                            : (v) {
                                if (v != null && v.isNotEmpty) {
                                  setDialogState(() => selectedUnit = v);
                                }
                              },
                      ),
                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.amber.withValues(alpha: 0.2)),
                        ),
                        child: const Row(
                          children: [
                            Icon(AppIcons.energy, size: 18, color: AppIcons.energyColor),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'This will use 1 Energy.\nProviding food name & quantity improves accuracy.',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, null),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx, {
                                'foodName': foodNameController.text.trim(),
                                'quantity': double.tryParse(
                                        quantityController.text.trim()) ??
                                    0.0,
                                'unit': selectedUnit,
                                'searchMode': searchMode,
                              });
                            },
                            icon: const Icon(Icons.auto_awesome_rounded,
                                size: 18),
                            label: const Text('Analyze'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Full-screen viewer now uses shared FoodEntryFullScreenImage from food_entry_image.dart
