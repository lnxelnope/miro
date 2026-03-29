import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/logger.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/services/image_picker_service.dart';
import '../../../core/ai/gemini_service.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/model_extensions.dart';
import '../../health/providers/health_provider.dart';
import '../../profile/providers/locale_provider.dart';
import '../../../core/widgets/privacy_consent_sheet.dart';
import '../../../l10n/app_localizations.dart';
import '../../health/presentation/health_timeline_tab.dart';
import '../../health/presentation/health_my_meal_tab.dart';
import '../../health/presentation/image_analysis_preview_screen.dart';
import '../../camera/presentation/camera_screen.dart';
import '../../arscan/presentation/arscan_screen.dart';
import '../../chat/presentation/chat_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../profile/providers/profile_provider.dart';
import '../../energy/widgets/energy_badge_riverpod.dart';
import '../../energy/providers/gamification_provider.dart';
import '../widgets/feature_tour.dart';
import '../../../core/providers/app_mode_provider.dart';
import 'basic_mode_tab.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _hasRequestedPermissions = false;
  int _currentIndex = 0;

  // Add GlobalKey for Feature Tour (Energy Badge only)
  final _energyBadgeKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 1. Ensure permissions (silent — no dialog, onboarding already asked)
      await _checkAndRequestPermissions();

      // 2. Feature tour (only shows if user reset from Settings; onboarding marks it done for new users)
      await _checkAndShowFeatureTour();

      // 3. Show analytics consent dialog (only if never asked)
      await _checkAndShowConsentDialog();

      // 4. Set context for Welcome Offer notifications
      if (mounted) {
        GeminiService.setContext(context);
      }

      // 5. Set cuisine preference + user language for AI analysis
      try {
        final profile = await ref.read(userProfileProvider.future);
        GeminiService.setCuisinePreference(profile.cuisinePreference);
        final locale = ref.read(localeProvider);
        GeminiService.setUserLanguage(locale?.languageCode ?? 'en');
      } catch (_) {
        // Silent fail — defaults to 'international' / 'en'
      }

    });
  }

  Future<void> _checkAndRequestPermissions() async {
    if (_hasRequestedPermissions) return;
    _hasRequestedPermissions = true;

    AppLogger.info('Checking and requesting permissions...');

    final permissionService = PermissionService();
    final isFirstLaunch = await permissionService.isFirstLaunch();

    AppLogger.info('isFirstLaunch: $isFirstLaunch');

    if (isFirstLaunch) {
      // Show permission dialog
      if (mounted) {
        await _showPermissionDialog();
      }
      await permissionService.markFirstLaunchComplete();
    } else {
      // Check existing permissions
      final hasGallery = await permissionService.hasGalleryPermission();
      AppLogger.info('hasGalleryPermission: $hasGallery');

      if (!hasGallery && mounted) {
        // Request permission if not granted
        await permissionService.requestGalleryPermission();
      }
    }
  }

  Future<void> _showPermissionDialog() async {
    AppLogger.info('Showing Permission Dialog...');

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.security, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Text(L10n.of(context)!.permissionRequired),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(L10n.of(context)!.permissionRequiredDesc),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                const Icon(Icons.photo_library, color: AppColors.health),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(L10n.of(context)!.permissionPhotos)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.camera_alt, color: AppColors.finance),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(L10n.of(context)!.permissionCamera)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(L10n.of(context)!.permissionSkip),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _requestAllPermissions();
            },
            child: Text(L10n.of(context)!.permissionAllow),
          ),
        ],
      ),
    );
  }

  Future<void> _requestAllPermissions() async {
    AppLogger.info('Requesting all permissions...');

    final permissionService = PermissionService();
    final results = await permissionService.requestInitialPermissions();

    AppLogger.info('Permission results: $results');

    if (mounted) {
      final allGranted = results.values.every((granted) => granted);

      if (allGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.of(context)!.permissionAllGranted),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        final denied =
            results.entries.where((e) => !e.value).map((e) => e.key).join(', ');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.of(context)!.permissionDenied(denied)),
            backgroundColor: AppColors.warning,
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: L10n.of(context)!.openSettings,
              textColor: Colors.white,
              onPressed: () async {
                await permissionService.openSettings();
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // AR Scan (2) and Gallery (3) are fullscreen, IndexedStack skips them
    final stackIndex = _currentIndex <= 1 ? _currentIndex : _currentIndex - 2;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        // If not on Dashboard tab, go back to Dashboard first
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return;
        }
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
            title: Text(L10n.of(context)!.exitAppTitle),
            content: Text(L10n.of(context)!.exitAppMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(L10n.of(context)!.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
                child: Text(L10n.of(context)!.exit),
              ),
            ],
          ),
        );
        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(stackIndex),
        bottomNavigationBar: _buildBottomNavOrNull(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final mode = ref.watch(appModeProvider);
    String title;
    if (mode == AppMode.basic) {
      title = L10n.of(context)!.appBarTodayIntake;
    } else {
      switch (_currentIndex) {
        case 0:
          title = L10n.of(context)!.appBarTodayIntake;
          break;
        case 1:
          title = L10n.of(context)!.appBarMyMeals;
          break;
        case 4:
          title = L10n.of(context)!.appBarAiChat;
          break;
        default:
          title = L10n.of(context)!.appBarMiro;
      }
    }

    final gamification = ref.watch(gamificationProvider);
    final isFreepassActive = gamification.freepass.isActive;
    final hasFreepassDays = gamification.freepass.totalDays > 0;

    double badgeWidth = 100;
    if (isFreepassActive) {
      badgeWidth = 150;
    } else if (hasFreepassDays) {
      badgeWidth = 120;
    }

    return AppBar(
      title: Text(title),
      leading: Padding(
        key: _energyBadgeKey,
        padding: const EdgeInsets.only(left: AppSpacing.sm),
        child: const Center(
          child: EnergyBadgeRiverpod(),
        ),
      ),
      leadingWidth: badgeWidth,
      actions: [
        IconButton(
          icon: const Icon(Icons.restaurant_menu_outlined),
          tooltip: L10n.of(context)!.navMyMeals,
          onPressed: _openMyMealScreen,
        ),
        IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          },
          tooltip: L10n.of(context)!.navProfile,
        ),
      ],
    );
  }

  void _openMyMealScreen() {
    final l10n = L10n.of(context)!;
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (ctx) => Scaffold(
          appBar: AppBar(
            title: Text(l10n.appBarMyMeals),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(ctx),
              tooltip: MaterialLocalizations.of(ctx).backButtonTooltip,
            ),
          ),
          body: const HealthMyMealTab(),
        ),
      ),
    );
  }

  Widget _buildBody(int stackIndex) {
    final mode = ref.watch(appModeProvider);
    if (mode == AppMode.basic) {
      return const BasicModeTab();
    }
    return IndexedStack(
      index: stackIndex,
      children: const [
        HealthTimelineTab(), // 0: Dashboard
        HealthMyMealTab(), // 1: My Meals
        ChatScreen(), // 2 (mapped from 3): Chat
      ],
    );
  }

  Widget? _buildBottomNavOrNull() {
    final mode = ref.watch(appModeProvider);
    if (mode == AppMode.basic) return null; // ซ่อน bottom nav ใน basic mode
    return _buildBottomNav(); // method เดิม
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        if (index == 2) {
          _openARScan();
          return;
        }
        if (index == 3) {
          _openGalleryOrCamera();
          return;
        }
        setState(() => _currentIndex = index);
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: const Icon(Icons.home),
          label: L10n.of(context)!.navDashboard,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.restaurant_menu_outlined),
          activeIcon: const Icon(Icons.restaurant_menu),
          label: L10n.of(context)!.navMyMeals,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.center_focus_strong_rounded),
          activeIcon: const Icon(Icons.center_focus_strong),
          label: L10n.of(context)!.arScan,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.photo_library_outlined),
          activeIcon: const Icon(Icons.photo_library),
          label: L10n.of(context)!.gallery,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.auto_awesome_outlined),
          activeIcon: const Icon(Icons.auto_awesome),
          label: L10n.of(context)!.navAiChat,
        ),
      ],
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
        ),
      ),
    );
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
              onTap: () async {
                Navigator.pop(ctx);
                await _pickFromGalleryFlow();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: Text(l10n.takePhoto),
              onTap: () async {
                Navigator.pop(ctx);
                await _takePhotoFlow();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromGalleryFlow() async {
    final images = await ImagePickerService.pickMultipleFromGallery();
    if (images.isEmpty || !mounted) return;

    if (images.length == 1) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImageAnalysisPreviewScreen(
            imageFile: images.first,
          ),
        ),
      );
      return;
    }

    // Multiple images → create entries + enqueue for analysis
    final now = DateTime.now();
    final appDir = await getApplicationDocumentsDirectory();
    final notifier = ref.read(foodEntriesNotifierProvider.notifier);
    int savedCount = 0;

    for (final image in images) {
      try {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final destPath = '${appDir.path}/$fileName';
        await image.copy(destPath);

        final entry = FoodEntry(
          id: 0,
          foodName: '--',
          mealType: _guessMealType(),
          timestamp: now,
          imagePath: destPath,
          servingSize: 1.0,
          servingUnit: 'serving',
          calories: 0, protein: 0, carbs: 0, fat: 0,
          baseCalories: 0, baseProtein: 0, baseCarbs: 0, baseFat: 0,
          source: DataSource.galleryScanned,
          isVerified: false,
          searchMode: FoodSearchMode.normal,
          isDeleted: false,
          isGroupOriginal: false,
          editCount: 0,
          isUserCorrected: false,
          isCalibrated: false,
          isSynced: false,
          createdAt: now,
          updatedAt: now,
        );
        await notifier.addFoodEntry(entry);
        savedCount++;
      } catch (_) {}
    }

    if (savedCount > 0 && mounted) {
      refreshFoodProviders(ref, dateOnly(now));
    }
  }

  Future<void> _takePhotoFlow() async {
    final File? capturedImage = await Navigator.push<File>(
      context,
      MaterialPageRoute(builder: (_) => const CameraScreen()),
    );

    if (capturedImage != null && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImageAnalysisPreviewScreen(
            imageFile: capturedImage,
          ),
        ),
      );
    }
  }

  MealType _guessMealType() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return MealType.breakfast;
    if (hour >= 11 && hour < 15) return MealType.lunch;
    if (hour >= 15 && hour < 21) return MealType.dinner;
    return MealType.snack;
  }

  /// Check and show feature tour (first time only)
  /// Simplified to show only Energy Badge
  Future<void> _checkAndShowFeatureTour() async {
    final hasCompleted = await FeatureTour.hasCompletedTour();

    if (!hasCompleted && mounted) {
      // Wait for UI to render (800ms)
      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      // Build tour target (Energy Badge only)
      final targets = [
        FeatureTour.buildEnergyBadgeTarget(_energyBadgeKey),
      ];

      // Show tour (auto-dismiss after 5 seconds)
      FeatureTour.show(
        context: context,
        targets: targets,
        onFinish: () {
          debugPrint('Feature tour completed');
        },
        onSkip: () {
          debugPrint('Feature tour skipped');
        },
      );
    }
  }

  /// Show unified privacy consent sheet (first time only)
  Future<void> _checkAndShowConsentDialog() async {
    try {
      final needsConsent = await PrivacyConsentSheet.needsConsent();

      if (needsConsent && mounted) {
        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        await PrivacyConsentSheet.show(context);
        AppLogger.info('Privacy consent sheet completed');
      }
    } catch (e) {
      AppLogger.warn('Failed to show privacy consent sheet: $e');
    }
  }
}
