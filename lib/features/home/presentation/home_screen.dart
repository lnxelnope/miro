import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/logger.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/services/consent_service.dart';
import '../../../core/ai/gemini_service.dart';
import '../../../core/widgets/analytics_consent_dialog.dart';
import '../../../l10n/app_localizations.dart';
import '../../health/presentation/health_timeline_tab.dart';
import '../../health/presentation/health_my_meal_tab.dart';
import '../../health/presentation/image_analysis_preview_screen.dart';
import '../../camera/presentation/camera_screen.dart';
import '../../chat/presentation/chat_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../profile/providers/profile_provider.dart';
import '../../energy/widgets/energy_badge_riverpod.dart';
import '../../scanner/widgets/retro_scan_dialog.dart';
import '../widgets/feature_tour.dart';
import '../widgets/welcome_message_dialog.dart';

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
      // 1. Request permissions first
      await _checkAndRequestPermissions();

      // 2. Show feature tour (only first time)
      await _checkAndShowFeatureTour();

      // 3. Retro scan: scan gallery photos from last 7 days (first time only)
      await _checkAndStartRetroScan();

      // 4. Welcome message: mark end of tutorial
      await _showWelcomeMessage();

      // 5. Show analytics consent dialog (only if never asked)
      await _checkAndShowConsentDialog();

      // 6. Set context for Welcome Offer notifications
      if (mounted) {
        GeminiService.setContext(context);
      }

      // 7. Set cuisine preference for AI analysis bias
      try {
        final profile = await ref.read(userProfileProvider.future);
        GeminiService.setCuisinePreference(profile.cuisinePreference);
      } catch (_) {
        // Silent fail — defaults to 'international'
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
            SizedBox(width: AppSpacing.sm),
            Text(L10n.of(context)!.permissionRequired),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(L10n.of(context)!.permissionRequiredDesc),
            SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                const Icon(Icons.photo_library, color: AppColors.health),
                SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(L10n.of(context)!.permissionPhotos)),
              ],
            ),
            SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.camera_alt, color: AppColors.finance),
                SizedBox(width: AppSpacing.sm),
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
    // Map display index: Camera (2) is fullscreen, so IndexedStack skips it
    final stackIndex = _currentIndex > 2 ? _currentIndex - 1 : _currentIndex;

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
        body: IndexedStack(
          index: stackIndex,
          children: const [
            HealthTimelineTab(), // 0: Dashboard
            HealthMyMealTab(), // 1: My Meals
            ChatScreen(), // 2 (mapped from 3): Chat
          ],
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    String title;
    switch (_currentIndex) {
      case 0:
        title = L10n.of(context)!.appBarTodayIntake;
        break;
      case 1:
        title = L10n.of(context)!.appBarMyMeals;
        break;
      case 2:
        title = L10n.of(context)!.appBarCamera;
        break;
      case 3:
        title = L10n.of(context)!.appBarAiChat;
        break;
      default:
        title = L10n.of(context)!.appBarMiro;
    }

    return AppBar(
      title: Text(title),
      leading: Padding(
        key: _energyBadgeKey,
        padding: EdgeInsets.only(left: AppSpacing.sm),
        child: const Center(
          child: EnergyBadgeRiverpod(),
        ),
      ),
      leadingWidth: 80,
      actions: [
        // Profile icon button (top-right)
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

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        if (index == 2) {
          // Camera → open fullscreen route (don't embed in IndexedStack)
          _openFullScreenCamera();
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
          icon: const Icon(Icons.camera_alt_outlined),
          activeIcon: const Icon(Icons.camera_alt),
          label: L10n.of(context)!.navCamera,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.auto_awesome_outlined),
          activeIcon: const Icon(Icons.auto_awesome),
          label: L10n.of(context)!.navAiChat,
        ),
      ],
    );
  }

  /// Open Camera as fullscreen route, then navigate to analysis if photo taken
  Future<void> _openFullScreenCamera() async {
    final File? capturedImage = await Navigator.push<File>(
      context,
      MaterialPageRoute(builder: (context) => const CameraScreen()),
    );

    if (capturedImage != null && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageAnalysisPreviewScreen(
            imageFile: capturedImage,
          ),
        ),
      );
      
      // After returning from preview screen, switch to timeline tab
      // User can manually analyze when ready via "Analyze All"
      if (_currentIndex != 0) {
        setState(() => _currentIndex = 0);
      }
    }
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

  /// Retro scan: offer to scan gallery photos from last 7 days (first time only)
  Future<void> _checkAndStartRetroScan() async {
    try {
      final alreadyDone = await RetroScanDialog.hasCompletedRetroScan();
      if (alreadyDone) return;

      final permissionService = PermissionService();
      final hasGallery = await permissionService.hasGalleryPermission();
      if (!hasGallery) {
        AppLogger.info('RetroScan skipped: no gallery permission');
        await RetroScanDialog.markRetroScanDone();
        return;
      }

      if (!mounted) return;

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      final result = await RetroScanDialog.show(context);
      AppLogger.info('RetroScan result: $result food entries found');
    } catch (e) {
      AppLogger.warn('RetroScan failed: $e');
    }
  }

  /// Show welcome message after retro scan completes
  Future<void> _showWelcomeMessage() async {
    try {
      if (!mounted) return;

      await Future.delayed(const Duration(milliseconds: 400));

      if (!mounted) return;

      await WelcomeMessageDialog.show(context);
      AppLogger.info('✅ Welcome message shown');
    } catch (e) {
      AppLogger.warn('⚠️ Failed to show welcome message: $e');
    }
  }

  /// Check and show analytics consent dialog (only first time)
  Future<void> _checkAndShowConsentDialog() async {
    try {
      final needsConsent = await ConsentService.needsConsent();
      
      if (needsConsent && mounted) {
        // Wait a bit after feature tour
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (!mounted) return;
        
        await AnalyticsConsentDialog.show(context);
        AppLogger.info('✅ Analytics consent dialog shown');
      }
    } catch (e) {
      AppLogger.warn('⚠️ Failed to show consent dialog: $e');
    }
  }
}
