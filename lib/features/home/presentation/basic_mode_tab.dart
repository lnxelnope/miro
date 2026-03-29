import 'dart:io';
import 'dart:ui' as ui;
import 'package:miro_hybrid/core/database/model_extensions.dart';
import '../../../core/database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/services/usage_limiter.dart';
import '../../../core/theme/app_icons.dart';
import '../../../l10n/app_localizations.dart';
import '../../health/providers/health_provider.dart';
import '../../health/providers/analysis_provider.dart';
import '../../health/providers/fulfill_calorie_provider.dart';
import '../../../core/widgets/analyze_bar.dart';
import '../../health/widgets/daily_summary_card.dart';
import '../../arscan/presentation/arscan_screen.dart';
import '../../health/presentation/image_analysis_preview_screen.dart';
import '../../chat/providers/chat_provider.dart';
import '../../scanner/providers/scanner_provider.dart';
import '../../../core/services/image_picker_service.dart';
import '../../../core/ar_scale/ar_scale.dart';
import '../../../core/utils/logger.dart';
import '../../profile/providers/profile_provider.dart';
import '../widgets/food_sandbox.dart';
import '../widgets/basic_meal_suggestion.dart';
import '../widgets/simple_food_detail_sheet.dart';
import '../../health/widgets/add_food_bottom_sheet.dart';
import '../../health/utils/meal_type_l10n.dart';

class BasicModeTab extends ConsumerStatefulWidget {
  const BasicModeTab({super.key});

  @override
  ConsumerState<BasicModeTab> createState() => _BasicModeTabState();
}

class _BasicModeTabState extends ConsumerState<BasicModeTab> {
  final _chatController = TextEditingController();
  bool _isComposing = false;
  bool _isScanning = false;
  bool _selectionModeActive = false;

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
    final profile = ref.watch(profileNotifierProvider).valueOrNull;
    final suggestionsEnabled = profile?.mealSuggestionsEnabled ?? false;
    final fulfillAsync = suggestionsEnabled
        ? ref.watch(fulfillCalorieProvider(_selectedDate))
        : const AsyncValue<FulfillCalorieState?>.data(null);
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
                // QuestBar hidden on basic home (Phase 14)
                const SliverToBoxAdapter(child: SizedBox.shrink()),

                // DailySummaryCard
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

                // 4. Meal Suggestions (ghost style)
                if (suggestionsEnabled)
                  SliverToBoxAdapter(
                    child: _buildBasicSuggestion(fulfillAsync),
                  ),

                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xxl),
                ),
              ],
            ),
          ),
        ),

        // 4. Analyze Bar — ซ่อนเมื่อโหมดเลือกเปิด เพื่อให้กดได้แค่ "Analyze selected"
        if (!_selectionModeActive)
          AnalyzeBar(
            selectedDate: _selectedDate,
            onAnalyze: _startBatchAnalysis,
          ),

        // 5. Action Buttons (Camera | Gallery | Add)
        _buildActionButtons(l10n),

        // Chat input hidden on basic home; keep widget tree for state (Phase 14)
        Visibility(
          visible: false,
          maintainState: true,
          child: _buildChatInput(l10n),
        ),
      ],
    );
  }

  // ============================================================
  // BASIC MEAL SUGGESTION
  // ============================================================
  Widget _buildBasicSuggestion(AsyncValue<FulfillCalorieState?> fulfillAsync) {
    final fulfill = fulfillAsync.valueOrNull;
    if (fulfill == null) return const SizedBox.shrink();

    return BasicMealSuggestion(
      fulfillState: fulfill,
      onTap: _quickAdd,
      onSuggestionTap: (suggestion) =>
          _showAddFoodDialogWithSuggestion(suggestion),
    );
  }

  void _showAddFoodDialogWithSuggestion(FoodSuggestion suggestion) {
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddFoodBottomSheet(
        mealType: mealType,
        selectedDate: _selectedDate,
        prefillName: suggestion.name,
        prefillCalories: suggestion.calories,
        prefillProtein: suggestion.protein,
        prefillCarbs: suggestion.carbs,
        prefillFat: suggestion.fat,
        prefillServingSize: suggestion.servingSize,
        prefillServingUnit: suggestion.servingUnit,
        onSave: (entry) async {
          await ref
              .read(foodEntriesNotifierProvider.notifier)
              .addFoodEntry(entry);
          refreshFoodProviders(ref, _selectedDate);
        },
      ),
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
      onChangeMealForSelected: _changeMealForSelectedEntries,
      onSelectionModeChanged: (active) {
        setState(() => _selectionModeActive = active);
      },
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
          // Gallery (+Camera)
          _actionButton(
            icon: Icons.photo_library_rounded,
            label: l10n.gallery,
            onTap: _openGalleryOrCamera,
          ),
          // AR Scan (prominent, center)
          _arScanButton(l10n),
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

  Widget _arScanButton(L10n l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: _openARScan,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: AppRadius.xl,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.center_focus_strong_rounded,
              size: 20,
              color: isDark ? Colors.black : Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              l10n.arScan,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.black : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openARScan() async {
    final permService = PermissionService();
    final hasPermission = await permService.hasCameraPermission();
    if (!hasPermission) {
      final result = await permService.requestCameraPermissionDetailed();

      if (!result.granted) {
        if (!mounted) return;

        // iOS: permanentlyDenied → ต้องไปเปิดใน Settings เอง
        if (result.permanentlyDenied) {
          final l10n = L10n.of(context)!;
          final goSettings = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(l10n.cameraFailedToInitialize),
              content: Text(l10n.cameraPermissionDeniedMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l10n.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(l10n.openSettings),
                ),
              ],
            ),
          );
          if (goSettings == true) {
            await permService.openSettings();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(L10n.of(context)!.cameraFailedToInitialize),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return;
      }
    }

    if (!mounted) return;
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(builder: (_) => const ARscanScreen()),
    );

    if (result == null || result.isEmpty || !mounted) return;

    final imageFiles = result
        .map((p) => File(p))
        .where((f) => f.existsSync())
        .toList();
    if (imageFiles.isEmpty) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImageAnalysisPreviewScreen(
          imageFile: imageFiles.first,
          arScanImages: imageFiles.length > 1 ? imageFiles : null,
          selectedDate: _selectedDate,
        ),
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

  void _openGalleryOrCamera() {
    final l10n = L10n.of(context)!;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: Text(l10n.pickFromGallery),
              onTap: () {
                Navigator.pop(ctx);
                _pickFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: Text(l10n.takePhoto),
              onTap: () async {
                Navigator.pop(ctx);
                final file = await ImagePickerService.pickFromCamera();
                if (file != null && mounted) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ImageAnalysisPreviewScreen(
                        imageFile: file,
                        selectedDate: _selectedDate,
                      ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    final images = await ImagePickerService.pickMultipleFromGallery();
    if (images.isEmpty || !mounted) return;

    if (images.length == 1) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImageAnalysisPreviewScreen(
            imageFile: images.first,
            selectedDate: _selectedDate,
          ),
        ),
      );
      return;
    }

    // Multiple images: create entries + enqueue for analysis
    final now = DateTime.now();
    final date = _selectedDate;
    final entryTimestamp = DateTime(date.year, date.month, date.day, now.hour, now.minute);
    final mealType = _guessMealTypeFromHour(now.hour);
    final appDir = await getApplicationDocumentsDirectory();
    final notifier = ref.read(foodEntriesNotifierProvider.notifier);
    final savedEntries = <FoodEntry>[];

    final detector = ReferenceDetectorService.instance;

    for (final image in images) {
      try {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final destPath = '${appDir.path}/$fileName';
        await image.copy(destPath);
        final destFile = File(destPath);

        // AR detection
        String? arLabelsJson;
        double? arImgW, arImgH, arPixelPerCm;
        try {
          final bytes = await destFile.readAsBytes();
          final codec = await ui.instantiateImageCodec(bytes);
          final frame = await codec.getNextFrame();
          arImgW = frame.image.width.toDouble();
          arImgH = frame.image.height.toDouble();
          frame.image.dispose();

          final allLabels = await detector.detectAllObjectLabels(destFile);
          if (allLabels.isNotEmpty) {
            arLabelsJson = DetectedObjectLabel.encode(allLabels);
          }

          final detected = await detector.detectFromImage(destFile);
          if (detected.isNotEmpty) {
            final plate = await detector.detectPlate(destFile);
            final calibration = ScaleCalibrationService.calibrate(
              referenceObject: detected.first,
              plateBoundingBox: plate?.boundingBox,
              imageWidth: arImgW,
              imageHeight: arImgH,
            );
            arPixelPerCm = calibration?.pixelPerCm;
          }
        } catch (e) {
          AppLogger.warn('AR detection failed for image: $e');
        }

        final entry = FoodEntry(
          id: 0,
          foodName: '--',
          mealType: mealType,
          timestamp: entryTimestamp,
          imagePath: destPath,
          servingSize: 1.0,
          servingUnit: 'serving',
          calories: 0, protein: 0, carbs: 0, fat: 0,
          baseCalories: 0, baseProtein: 0, baseCarbs: 0, baseFat: 0,
          source: DataSource.galleryScanned,
          isVerified: false,
          searchMode: FoodSearchMode.normal,
          arLabelsJson: arLabelsJson,
          arImageWidth: arImgW,
          arImageHeight: arImgH,
          arPixelPerCm: arPixelPerCm,
          isDeleted: false,
          isGroupOriginal: false,
          editCount: 0,
          isUserCorrected: false,
          isCalibrated: arPixelPerCm != null,
          isSynced: false,
          createdAt: now,
          updatedAt: now,
        );
        await notifier.addFoodEntry(entry);
        savedEntries.add(entry);
      } catch (e) {
        AppLogger.warn('Failed to save image: $e');
      }
    }

    if (savedEntries.isEmpty || !mounted) return;

    final selectedDate = dateOnly(date);
    refreshFoodProviders(ref, selectedDate);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(L10n.of(context)!.scanFoundNewImages(
            savedEntries.length, DateFormat('d MMM yyyy').format(date))),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  MealType _guessMealTypeFromHour(int hour) {
    if (hour >= 5 && hour < 11) return MealType.breakfast;
    if (hour >= 11 && hour < 15) return MealType.lunch;
    if (hour >= 15 && hour < 21) return MealType.dinner;
    return MealType.snack;
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
          backgroundColor: count > 0 ? AppColors.success : AppColors.info,
        ),
      );
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  Future<void> _changeMealForSelectedEntries(
      List<FoodEntry> entries, MealType newType) async {
    final notifier = ref.read(foodEntriesNotifierProvider.notifier);
    for (final entry in entries) {
      entry.mealType = newType;
      await notifier.updateFoodEntry(entry);
    }
    if (!mounted) return;
    refreshFoodProviders(ref, _selectedDate);
    final l10n = L10n.of(context)!;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.mealMovedToMealType(mealTypeLabel(newType, l10n))),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
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

  Future<void> _startBatchAnalysis(List<FoodEntry> entries) async {
    if (entries.isEmpty) return;

    if (await UsageLimiter.hasReachedDailyCap()) {
      if (!mounted) return;
      final l10n = L10n.of(context)!;
      final remaining = await UsageLimiter.remainingAnalysesToday();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.dailyCapReached(
            UsageLimiter.maxAnalysesPerDay - remaining,
            UsageLimiter.maxAnalysesPerDay,
          )),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    ref.read(analysisProvider.notifier).enqueue(
          entries: entries,
          selectedDate: _selectedDate,
        );
  }
}
