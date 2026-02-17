import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/app_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../core/constants/enums.dart';
import '../../../core/ai/gemini_service.dart';
import '../../../core/services/usage_limiter.dart';
import '../../../core/widgets/search_mode_selector.dart';
import '../../../features/energy/widgets/no_energy_dialog.dart';
import '../../../features/energy/providers/energy_provider.dart';
import '../models/food_entry.dart';
import '../providers/health_provider.dart';
import '../providers/my_meal_provider.dart';
import 'gemini_analysis_sheet.dart';

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

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final hasImage =
        entry.imagePath != null && File(entry.imagePath!).existsSync();
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
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === Image (if available) ===
                  if (hasImage) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          Image.file(
                            File(entry.imagePath!),
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildImagePlaceholder(isDark),
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
                        Icon(AppIcons.calories, size: 36, color: AppIcons.caloriesColor),
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
                        const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            'kcal',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
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
                              'Protein', entry.protein, AppColors.protein)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _buildMacroChip(
                              'Carbs', entry.carbs, AppColors.carbs)),
                      const SizedBox(width: 8),
                      Expanded(
                          child:
                              _buildMacroChip('Fat', entry.fat, AppColors.fat)),
                    ],
                  ),
                  const SizedBox(height: 12),

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
  // Macro Chip
  // ============================================================
  Widget _buildMacroChip(String label, double value, Color color) {
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
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
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
    final hasImage =
        entry.imagePath != null && File(entry.imagePath!).existsSync();

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

    // แสดง Confirmation Dialog
    if (!mounted) return;
    final analyzeParams = await _showAnalyzeConfirmation(entry);
    if (analyzeParams == null) return;

    final String confirmedFoodName = analyzeParams['foodName'] as String;
    final double confirmedQuantity = analyzeParams['quantity'] as double;
    final String confirmedUnit = analyzeParams['unit'] as String;
    final FoodSearchMode confirmedSearchMode =
        analyzeParams['searchMode'] as FoodSearchMode? ?? FoodSearchMode.normal;

    // ตรวจสอบ Energy
    final hasEnergy = await GeminiService.hasEnergy();
    if (!hasEnergy && mounted) {
      await NoEnergyDialog.show(context);
      return;
    }

    if (!mounted) return;

    setState(() => _isAnalyzing = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              hasImage
                  ? 'PROCESSING IMAGE DATA...'
                  : 'PARSING FOOD NAME...',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Processing advanced nutrition analysis',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );

    try {
      FoodAnalysisResult? result;
      final notifier = ref.read(foodEntriesNotifierProvider.notifier);

      if (hasImage) {
        AppLogger.info(
            'Starting Gemini image analysis... (mode: ${confirmedSearchMode.name})');
        result = await GeminiService.analyzeFoodImage(
          File(entry.imagePath!),
          foodName: confirmedFoodName.isNotEmpty ? confirmedFoodName : null,
          quantity: confirmedQuantity > 0 ? confirmedQuantity : null,
          unit: confirmedUnit,
          searchMode: confirmedSearchMode,
        );
      } else {
        AppLogger.info(
            'Starting Gemini analysis from name... (mode: ${confirmedSearchMode.name})');
        result = await GeminiService.analyzeFoodByName(
          confirmedFoodName.isNotEmpty ? confirmedFoodName : entry.foodName,
          servingSize:
              confirmedQuantity > 0 ? confirmedQuantity : entry.servingSize,
          servingUnit: confirmedUnit,
          searchMode: confirmedSearchMode,
        );
      }

      if (result != null) {
        await UsageLimiter.recordAiUsage();

        if (!mounted) return;
        ref.invalidate(energyBalanceProvider);
        ref.invalidate(currentEnergyProvider);

        Navigator.pop(context); // ปิด loading dialog

        if (!mounted) return;
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => GeminiAnalysisSheet(
            analysisResult: result!,
            onConfirm: (confirmedData) async {
              String? ingredientsJsonStr;
              if (confirmedData.ingredientsDetail != null &&
                  confirmedData.ingredientsDetail!.isNotEmpty) {
                ingredientsJsonStr =
                    jsonEncode(confirmedData.ingredientsDetail);
              }

              await notifier.updateFromGeminiConfirmed(
                entry.id,
                foodName: confirmedData.foodName,
                foodNameEn: confirmedData.foodNameEn,
                calories: confirmedData.calories,
                protein: confirmedData.protein,
                carbs: confirmedData.carbs,
                fat: confirmedData.fat,
                baseCalories: confirmedData.baseCalories,
                baseProtein: confirmedData.baseProtein,
                baseCarbs: confirmedData.baseCarbs,
                baseFat: confirmedData.baseFat,
                servingSize: confirmedData.servingSize,
                servingUnit: confirmedData.servingUnit,
                servingGrams: confirmedData.servingGrams,
                confidence: confirmedData.confidence,
                fiber: confirmedData.fiber,
                sugar: confirmedData.sugar,
                sodium: confirmedData.sodium,
                notes: confirmedData.notes,
                ingredientsJson: ingredientsJsonStr,
              );

              if (confirmedData.ingredientsDetail != null &&
                  confirmedData.ingredientsDetail!.isNotEmpty) {
                try {
                  await notifier.saveIngredientsAndMeal(
                    mealName: confirmedData.foodName,
                    mealNameEn: confirmedData.foodNameEn,
                    servingDescription:
                        '${confirmedData.servingSize} ${confirmedData.servingUnit}',
                    imagePath: entry.imagePath,
                    ingredientsData: confirmedData.ingredientsDetail!,
                  );

                  if (!mounted) return;
                  ref.invalidate(allMyMealsProvider);
                  ref.invalidate(allIngredientsProvider);

                  AppLogger.info(
                      'Auto-saved: ${confirmedData.ingredientsDetail!.length} ingredients + 1 meal');
                } catch (e) {
                  AppLogger.warn('Could not auto-save meal: $e');
                }
              }

              if (!mounted) return;

              if (widget.selectedDate != null) {
                ref.invalidate(foodEntriesByDateProvider(widget.selectedDate!));
                ref.invalidate(healthTimelineProvider(widget.selectedDate!));
              }
              ref.invalidate(todayCaloriesProvider);
              ref.invalidate(todayMacrosProvider);

              if (!context.mounted) return;
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '✅ Updated successfully${confirmedData.ingredientsDetail != null && confirmedData.ingredientsDetail!.isNotEmpty ? ' + saved to My Meal' : ''}'),
                  backgroundColor: AppColors.success,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        );
      } else {
        if (!mounted) return;
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Could not analyze - please try again'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error('Error', e, stackTrace);

      setState(() => _isAnalyzing = false);

      if (!mounted) return;
      Navigator.pop(context);
      if (!mounted) return;

      if (e.toString().contains('Insufficient energy')) {
        await NoEnergyDialog.show(context);
        return;
      }

      String errorMessage = 'An error occurred. Please try again.';
      if (e.toString().contains('parse JSON')) {
        errorMessage = 'Could not read AI result - please try again';
      } else {
        errorMessage = e.toString().replaceAll('Exception: ', '');
        if (errorMessage.length > 100) {
          errorMessage = '${errorMessage.substring(0, 100)}...';
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ $errorMessage'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
    }
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
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: AppColors.error,
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

    final hasImage =
        entry.imagePath != null && File(entry.imagePath!).existsSync();
    FoodSearchMode searchMode = FoodSearchMode.normal;

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
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(entry.imagePath!),
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
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

                      const Text('Unit',
                          style: TextStyle(
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
                        onChanged: (v) {
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
