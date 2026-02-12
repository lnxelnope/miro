import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/logger.dart';
import '../../../core/services/permission_service.dart';
import '../../health/presentation/health_page.dart';
import '../../profile/presentation/profile_screen.dart';
import '../widgets/magic_button.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _hasRequestedPermissions = false;
  
  @override
  void initState() {
    super.initState();
    // Request permission after build complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRequestPermissions();
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
      body: const HealthPage(),
      floatingActionButton: const MagicButton(),
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

}
