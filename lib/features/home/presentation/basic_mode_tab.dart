import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/constants/enums.dart';
import '../../../core/utils/batch_analysis_helper.dart';
import '../../../l10n/app_localizations.dart';
import '../../health/models/food_entry.dart';
import '../../health/providers/health_provider.dart';
import '../../health/widgets/daily_summary_card.dart';
import '../../energy/widgets/quest_bar.dart';
import '../../camera/presentation/camera_screen.dart';
import '../../health/presentation/image_analysis_preview_screen.dart';
import '../../chat/providers/chat_provider.dart';
import '../../scanner/providers/scanner_provider.dart';
import '../../../core/services/image_picker_service.dart';
import '../widgets/food_sandbox.dart';
import '../widgets/simple_food_detail_sheet.dart';

class BasicModeTab extends ConsumerStatefulWidget {
  const BasicModeTab({super.key});

  @override
  ConsumerState<BasicModeTab> createState() => _BasicModeTabState();
}

class _BasicModeTabState extends ConsumerState<BasicModeTab> {
  final _chatController = TextEditingController();
  bool _isComposing = false;
  bool _isScanning = false;

  // Batch analysis state
  bool _isAnalyzing = false;
  int _analyzeTotal = 0;
  int _analyzeCurrent = 0;
  String _currentItemName = '';
  bool _cancelRequested = false;

  late DateTime _selectedDate;

  void _onDateChanged(DateTime newDate) {
    setState(() => _selectedDate = dateOnly(newDate));
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = dateOnly(DateTime.now());
    _chatController.addListener(() {
      setState(() => _isComposing = _chatController.text.trim().isNotEmpty);
    });
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timelineAsync = ref.watch(healthTimelineProvider(_selectedDate));
    final l10n = L10n.of(context)!;

    return Column(
      children: [
        // Scrollable content area
        Expanded(
          child: RefreshIndicator(
            onRefresh: _scanForFood,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // 1. QuestBar
                const SliverToBoxAdapter(child: QuestBar()),

                // 2. DailySummaryCard
                SliverToBoxAdapter(
                  child: DailySummaryCard(
                    selectedDate: _selectedDate,
                    onDateChanged: _onDateChanged,
                  ),
                ),

                // 3. Analyze All / Progress Bar
                SliverToBoxAdapter(
                  child: _buildAnalyzeSection(timelineAsync),
                ),

                // 4. Food Sandbox
                SliverToBoxAdapter(
                  child: _buildSandbox(timelineAsync),
                ),

                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xxl),
                ),
              ],
            ),
          ),
        ),

        // 5. Action Buttons (Camera | Gallery | Add)
        _buildActionButtons(l10n),

        // 6. Chat Input
        _buildChatInput(l10n),
      ],
    );
  }

  // ============================================================
  // SANDBOX
  // ============================================================
  Widget _buildSandbox(AsyncValue<List<TimelineItem>> timelineAsync) {
    final items = timelineAsync.valueOrNull ?? [];
    final foodEntries = items
        .where((i) => i.type == 'food')
        .map((i) => i.data as FoodEntry)
        .where((f) => !f.isDeleted)
        .toList();

    return FoodSandbox(
      entries: foodEntries,
      onTap: (entry) => _showFoodDetail(entry),
      onDeleteSelected: _deleteSelectedEntries,
      onAnalyzeSelected: _analyzeSelectedEntries,
    );
  }

  // ============================================================
  // ANALYZE SECTION (Analyze All button / Progress bar)
  // ============================================================
  Widget _buildAnalyzeSection(AsyncValue<List<TimelineItem>> timelineAsync) {
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

    if (_isAnalyzing) {
      // Progress bar
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
                    l10n.analyzeProgress(
                        _currentItemName, _analyzeCurrent, _analyzeTotal),
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _cancelRequested = true),
                  child: const Icon(Icons.close_rounded,
                      size: 18, color: AppColors.error),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs + 2),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _analyzeTotal > 0 ? _analyzeCurrent / _analyzeTotal : 0,
                minHeight: 4,
                backgroundColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ],
        ),
      );
    }

    if (energyCost <= 0) return const SizedBox.shrink();

    // Analyze All button
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      child: GestureDetector(
        onTap: () => _startBatchAnalysis(unanalyzed),
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
              const Icon(AppIcons.energy, size: 14, color: AppIcons.energyColor),
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

  // ============================================================
  // ACTION BUTTONS (Camera | Gallery | Add)
  // ============================================================
  Widget _buildActionButtons(L10n l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Camera
          _actionButton(
            icon: Icons.camera_alt_rounded,
            label: l10n.navCamera,
            onTap: _openCamera,
          ),
          // Gallery
          _actionButton(
            icon: Icons.photo_library_rounded,
            label: l10n.gallery,
            onTap: _pickFromGallery,
          ),
          // Quick Add (+)
          _actionButton(
            icon: Icons.add_rounded,
            label: l10n.addFood,
            onTap: _quickAdd,
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.surfaceVariant,
          borderRadius: AppRadius.xl,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CHAT INPUT
  // ============================================================
  Widget _buildChatInput(L10n l10n) {
    final isLoading = ref.watch(chatLoadingProvider);
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.sm,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Builder(builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
                  borderRadius: AppRadius.xxl,
                ),
                child: TextField(
                  controller: _chatController,
                  maxLines: 3,
                  minLines: 1,
                  style: TextStyle(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.tellMeWhatYouAte,
                    hintStyle: TextStyle(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textTertiary,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                  ),
                  onSubmitted: (_) => _sendChat(),
                ),
              );
            }),
          ),
          const SizedBox(width: AppSpacing.sm),
          Builder(builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: (_isComposing || isLoading)
                  ? AppColors.primary
                  : (isDark ? AppColors.surfaceVariantDark : AppColors.divider),
              shape: BoxShape.circle,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isComposing && !isLoading ? _sendChat : null,
                borderRadius: AppRadius.xl,
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(AppIcons.energyColor),
                          ),
                        )
                      : Icon(
                          AppIcons.energy,
                          color: _isComposing
                              ? AppIcons.energyColor
                              : (isDark ? AppColors.textSecondaryDark : AppColors.textTertiary),
                          size: 18,
                        ),
                ),
              ),
            ),
          );
          }),
        ],
      ),
    );
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  void _sendChat() {
    final message = _chatController.text.trim();
    if (message.isEmpty) return;
    ref.read(chatNotifierProvider.notifier).sendMessage(message);
    _chatController.clear();
    // Refresh providers หลัง chat save entry
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) refreshFoodProviders(ref, _selectedDate);
    });
  }

  Future<void> _openCamera() async {
    final File? capturedImage = await Navigator.push<File>(
      context,
      MaterialPageRoute(builder: (_) => const CameraScreen()),
    );
    if (capturedImage != null && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImageAnalysisPreviewScreen(imageFile: capturedImage),
        ),
      );
    }
  }

  Future<void> _pickFromGallery() async {
    final File? image = await ImagePickerService.pickFromGallery();
    if (image != null && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImageAnalysisPreviewScreen(imageFile: image),
        ),
      );
    }
  }

  Future<void> _quickAdd() async {
    final entry = await _showQuickAddDialog();
    if (entry != null) {
      await ref.read(foodEntriesNotifierProvider.notifier).addFoodEntry(entry);
      refreshFoodProviders(ref, _selectedDate);
    }
  }

  Future<void> _scanForFood() async {
    if (_isScanning) return;
    setState(() => _isScanning = true);
    try {
      final count = await ref
          .read(galleryScanNotifierProvider.notifier)
          .scanNewImages(specificDate: _selectedDate);
      refreshFoodProviders(ref, _selectedDate);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(count > 0
              ? L10n.of(context)!.scanFoundNewImages(
                  count, DateFormat('d MMM yyyy').format(_selectedDate))
              : L10n.of(context)!.scanNoNewImages(
                  DateFormat('d MMM yyyy').format(_selectedDate))),
        ),
      );
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  void _showFoodDetail(FoodEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SimpleFoodDetailSheet(entry: entry),
    );
  }

  Future<void> _deleteSelectedEntries(List<FoodEntry> entries) async {
    final notifier = ref.read(foodEntriesNotifierProvider.notifier);
    for (final entry in entries) {
      await notifier.deleteFoodEntry(entry.id);
    }
    refreshFoodProviders(ref, _selectedDate);
  }

  Future<void> _analyzeSelectedEntries(List<FoodEntry> entries) async {
    await _startBatchAnalysis(entries);
  }

  Future<void> _startBatchAnalysis(List<FoodEntry> entries) async {
    if (entries.isEmpty) return;

    final hasEnergy =
        await BatchAnalysisHelper.checkEnergy(ref, entries.length);
    if (!hasEnergy && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(L10n.of(context)!.notEnoughEnergy)),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analyzeTotal = entries.length;
      _analyzeCurrent = 0;
      _currentItemName = '';
      _cancelRequested = false;
    });

    final result = await BatchAnalysisHelper.analyzeEntries(
      ref: ref,
      entries: entries,
      selectedDate: _selectedDate,
      onProgress: (current, total, itemName) {
        if (mounted) {
          setState(() {
            _analyzeCurrent = current;
            _analyzeTotal = total;
            _currentItemName = itemName;
          });
        }
      },
      shouldCancel: () => _cancelRequested,
    );

    if (!mounted) return;
    setState(() => _isAnalyzing = false);

    final l10n = L10n.of(context)!;
    final message = result.wasCancelled
        ? l10n.analyzeCancelled(result.successCount)
        : result.failedCount == 0
            ? l10n.analyzeSuccessAll(result.successCount)
            : l10n.analyzeSuccessPartial(
                result.successCount,
                result.successCount + result.failedCount,
                result.failedCount);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // Quick Add Dialog
  Future<FoodEntry?> _showQuickAddDialog() async {
    final nameController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    String selectedUnit = 'serving';
    final l10n = L10n.of(context)!;

    final result = await showModalBottomSheet<FoodEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            decoration: BoxDecoration(
              color: Theme.of(ctx).cardColor,
              borderRadius: AppRadius.sheetTop,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  l10n.quickAddTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(ctx).brightness == Brightness.dark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Food name
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: l10n.foodName,
                    hintText: l10n.quickAddHint,
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.md,
                    ),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Quantity + Unit row
                Row(
                  children: [
                    // Quantity
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.quantity,
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.md,
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    // Unit
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        value: selectedUnit,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l10n.servingUnit,
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.md,
                          ),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'serving', child: Text('serving')),
                          DropdownMenuItem(value: 'piece', child: Text('piece')),
                          DropdownMenuItem(value: 'g', child: Text('g')),
                          DropdownMenuItem(value: 'ml', child: Text('ml')),
                          DropdownMenuItem(value: 'cup', child: Text('cup')),
                          DropdownMenuItem(value: 'tbsp', child: Text('tbsp')),
                          DropdownMenuItem(value: 'plate', child: Text('plate')),
                          DropdownMenuItem(value: 'bowl', child: Text('bowl')),
                        ],
                        onChanged: (v) {
                          if (v != null) setSheetState(() => selectedUnit = v);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // Add button
                SizedBox(
                  width: double.infinity,
                  height: AppSizes.buttonMedium,
                  child: ElevatedButton(
                    onPressed: () {
                      final name = nameController.text.trim();
                      if (name.isEmpty) return;

                      final qty = double.tryParse(quantityController.text) ?? 1.0;
                      final now = DateTime.now();

                      // Auto-assign meal type ตามเวลา
                      MealType mealType;
                      final hour = now.hour;
                      if (hour >= 5 && hour < 11) {
                        mealType = MealType.breakfast;
                      } else if (hour >= 11 && hour < 15) {
                        mealType = MealType.lunch;
                      } else if (hour >= 15 && hour < 21) {
                        mealType = MealType.dinner;
                      } else {
                        mealType = MealType.snack;
                      }

                      final entry = FoodEntry()
                        ..foodName = name
                        ..timestamp = now
                        ..mealType = mealType
                        ..servingSize = qty
                        ..servingUnit = selectedUnit
                        ..calories = 0
                        ..protein = 0
                        ..carbs = 0
                        ..fat = 0
                        ..baseCalories = 0
                        ..baseProtein = 0
                        ..baseCarbs = 0
                        ..baseFat = 0
                        ..source = DataSource.manual
                        ..isVerified = false;

                      Navigator.pop(ctx, entry);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.md,
                      ),
                    ),
                    child: Text(
                      l10n.addToSandbox,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return result;
  }
}
