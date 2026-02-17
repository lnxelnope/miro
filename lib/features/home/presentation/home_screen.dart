import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/logger.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/ai/gemini_service.dart';
import '../../health/presentation/health_timeline_tab.dart';
import '../../health/presentation/health_my_meal_tab.dart';
import '../../health/presentation/image_analysis_preview_screen.dart';
import '../../camera/presentation/camera_screen.dart';
import '../../chat/presentation/chat_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../profile/providers/profile_provider.dart';
import '../../energy/widgets/energy_badge_riverpod.dart';
import '../widgets/feature_tour.dart';

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
    // Request permission after build complete
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 1. Request permissions first
      await _checkAndRequestPermissions();

      // 2. Show feature tour (only first time)
      await _checkAndShowFeatureTour();

      // 3. Set context for Welcome Offer notifications
      if (mounted) {
        GeminiService.setContext(context);
      }

      // 4. Set cuisine preference for AI analysis bias
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
        title: const Row(
          children: [
            Icon(Icons.security, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Permission Required'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MIRO needs access to the following:'),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.photo_library, color: AppColors.health),
                SizedBox(width: 8),
                Expanded(child: Text('Photos — to scan food')),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.camera_alt, color: AppColors.finance),
                SizedBox(width: 8),
                Expanded(child: Text('Camera — to photograph food')),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _requestAllPermissions();
            },
            child: const Text('Allow'),
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
          const SnackBar(
            content: Text('All permissions granted'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final denied =
            results.entries.where((e) => !e.value).map((e) => e.key).join(', ');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Permission denied: $denied'),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Open Settings',
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

    return Scaffold(
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
    );
  }

  PreferredSizeWidget _buildAppBar() {
    String title;
    switch (_currentIndex) {
      case 0:
        title = "Today's Intake";
        break;
      case 1:
        title = 'My Meals';
        break;
      case 2:
        title = 'Camera';
        break;
      case 3:
        title = 'AI Chat';
        break;
      default:
        title = 'MIRO';
    }

    return AppBar(
      title: Text(title),
      leading: Padding(
        key: _energyBadgeKey,
        padding: const EdgeInsets.only(left: 8.0),
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
          tooltip: 'Profile',
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
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant_menu_outlined),
          activeIcon: Icon(Icons.restaurant_menu),
          label: 'My Meals',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt_outlined),
          activeIcon: Icon(Icons.camera_alt),
          label: 'Camera',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.auto_awesome_outlined),
          activeIcon: Icon(Icons.auto_awesome),
          label: 'AI Chat',
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageAnalysisPreviewScreen(
            imageFile: capturedImage,
          ),
        ),
      );
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
}
