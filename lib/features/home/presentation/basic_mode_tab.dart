import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/constants/enums.dart';
import '../../../l10n/app_localizations.dart';
import '../../health/models/food_entry.dart';
import '../../health/providers/health_provider.dart';
import '../../health/providers/analysis_provider.dart';
import '../../../core/widgets/analyze_bar.dart';
import '../../health/widgets/daily_summary_card.dart';
import '../../energy/widgets/quest_bar.dart';
import '../../camera/presentation/camera_screen.dart';
import '../../health/presentation/image_analysis_preview_screen.dart';
import '../../chat/providers/chat_provider.dart';
import '../../scanner/providers/scanner_provider.dart';
import '../../../core/services/image_picker_service.dart';
import '../widgets/food_sandbox.dart';
import '../widgets/simple_food_detail_sheet.dart';
import '../../health/widgets/add_food_bottom_sheet.dart';

class BasicModeTab extends ConsumerStatefulWidget {
  const BasicModeTab({super.key});

  @override
  ConsumerState<BasicModeTab> createState() => _BasicModeTabState();
}

class _BasicModeTabState extends ConsumerState<BasicModeTab> {
  final _chatController = TextEditingController();
  bool _isComposing = false;
  bool _isScanning = false;

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

                // 3. Food Sandbox
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

        // 4. Analyze Bar (above action buttons, visible only when needed)
        AnalyzeBar(
          selectedDate: _selectedDate,
          onAnalyze: _startBatchAnalysis,
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
      onMoveToDate: _moveEntriesToDate,
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
                  color: isDark
                      ? AppColors.surfaceVariantDark
                      : AppColors.surfaceVariant,
                  borderRadius: AppRadius.xxl,
                ),
                child: TextField(
                  controller: _chatController,
                  maxLines: 3,
                  minLines: 1,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.tellMeWhatYouAte,
                    hintStyle: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textTertiary,
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
                    : (isDark
                        ? AppColors.surfaceVariantDark
                        : AppColors.divider),
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
                              valueColor:
                                  AlwaysStoppedAnimation(AppIcons.energyColor),
                            ),
                          )
                        : Icon(
                            AppIcons.energy,
                            color: _isComposing
                                ? AppIcons.energyColor
                                : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textTertiary),
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
    final hour = DateTime.now().hour;
    MealType mealType;
    if (hour >= 5 && hour < 11) {
      mealType = MealType.breakfast;
    } else if (hour >= 11 && hour < 15) {
      mealType = MealType.lunch;
    } else if (hour >= 15 && hour < 21) {
      mealType = MealType.dinner;
    } else {
      mealType = MealType.snack;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddFoodBottomSheet(
        mealType: mealType,
        selectedDate: _selectedDate,
        onSave: (entry) async {
          await ref
              .read(foodEntriesNotifierProvider.notifier)
              .addFoodEntry(entry);
          refreshFoodProviders(ref, _selectedDate);
        },
      ),
    );
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

  Future<void> _moveEntriesToDate(List<FoodEntry> entries, DateTime newDate) async {
    final notifier = ref.read(foodEntriesNotifierProvider.notifier);
    for (final entry in entries) {
      final oldTime = entry.timestamp;
      entry.timestamp = DateTime(
        newDate.year, newDate.month, newDate.day,
        oldTime.hour, oldTime.minute,
      );
      await notifier.updateFoodEntry(entry);
    }

    if (!mounted) return;
    refreshFoodProviders(ref, _selectedDate);
    refreshFoodProviders(ref, dateOnly(newDate));

    final fmt = DateFormat('d MMM');
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(L10n.of(context)!.movedEntriesToDate(entries.length, fmt.format(newDate))),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
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
    final l10n = L10n.of(context)!;
    final displayName = entries.length == 1
        ? entries.first.foodName
        : '${entries.length} items';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.confirmDeleteMessage(displayName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.deleteSelected),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final notifier = ref.read(foodEntriesNotifierProvider.notifier);
    for (final entry in entries) {
      await notifier.deleteFoodEntry(entry.id);
    }
    refreshFoodProviders(ref, _selectedDate);

    if (!mounted) return;
    final message = entries.length == 1
        ? '✅ ${l10n.deletedSingleEntry(entries.first.foodName)}'
        : '✅ ${l10n.deletedEntries(entries.length)}';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _analyzeSelectedEntries(List<FoodEntry> entries) {
    _startBatchAnalysis(entries);
  }

  void _startBatchAnalysis(List<FoodEntry> entries) {
    if (entries.isEmpty) return;
    ref.read(analysisProvider.notifier).enqueue(
          entries: entries,
          selectedDate: _selectedDate,
        );
  }
}
