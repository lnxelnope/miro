import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/logger.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/ai/gemini_service.dart';
import '../../health/presentation/health_page.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../feedback/beta_feedback_button.dart'; // TODO: Remove before public launch
import '../../energy/widgets/energy_badge_riverpod.dart';
import '../widgets/magic_button.dart';
import '../widgets/feature_tour.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _hasRequestedPermissions = false;
  
  // Add GlobalKeys for Feature Tour
  final _energyBadgeKey = GlobalKey();
  final _timelineAreaKey = GlobalKey();
  final _magicButtonKey = GlobalKey();
  
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
        final denied = results.entries
            .where((e) => !e.value)
            .map((e) => e.key)
            .join(', ');
        
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
    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          HealthPage(key: _timelineAreaKey),
          // TODO: Remove before public launch
          const BetaFeedbackButton(),
        ],
      ),
      floatingActionButton: MagicButton(key: _magicButtonKey),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'MIRO',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
      leading: Padding(
        key: _energyBadgeKey,
        padding: const EdgeInsets.only(left: 8.0),
        child: const Center(
          child: EnergyBadgeRiverpod(),
        ),
      ),
      leadingWidth: 80, // ปรับความกว้างให้พอดีกับ badge ขนาดเล็ก
      actions: [
        IconButton(
          icon: const Icon(Icons.person),
          onPressed: () => _openProfile(),
        ),
      ],
    );
  }


  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  /// Check and show feature tour (first time only)
  Future<void> _checkAndShowFeatureTour() async {
    final hasCompleted = await FeatureTour.hasCompletedTour();
    
    if (!hasCompleted && mounted) {
      // Wait for UI to render (500ms)
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) return;
      
      // Build tour targets
      final targets = [
        FeatureTour.buildEnergyBadgeTarget(_energyBadgeKey),
        FeatureTour.buildPullRefreshTarget(_timelineAreaKey),
        FeatureTour.buildChatButtonTarget(_magicButtonKey),
      ];
      
      // Show tour
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
