import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:miro_hybrid/core/theme/app_colors.dart';
import 'package:miro_hybrid/core/theme/app_tokens.dart';
import 'package:miro_hybrid/l10n/app_localizations.dart';

import '../application/camera_stream_controller.dart';
import 'widgets/camera_preview_view.dart';

/// ARscan screen สำหรับแสดง live camera preview (เต็มหน้าจอ)
/// โฟกัสที่โครงสร้างและ lifecycle ของกล้อง
class ARscanScreen extends ConsumerStatefulWidget {
  const ARscanScreen({super.key});

  @override
  ConsumerState<ARscanScreen> createState() => _ARscanScreenState();
}

class _ARscanScreenState extends ConsumerState<ARscanScreen>
    with WidgetsBindingObserver {
  final ArScanCameraStreamController _streamController =
      ArScanCameraStreamController();
  bool _isInitialized = false;
  bool _isOpeningSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // ให้ behavior สอดคล้องกับ CameraScreen เดิม
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
      _streamController.stopStream();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      await _streamController.initialize();

      if (!mounted) return;

      if (!_streamController.isInitialized) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.of(context)!.cameraFailedToInitialize),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.of(context).maybePop();
        return;
      }

      setState(() {
        _isInitialized = true;
      });

      await _streamController.startStream();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10n.of(context)!.cameraFailedToInitialize),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).maybePop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _isInitialized = false;
    _streamController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.black,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            CameraPreviewView(
              isInitialized: _isInitialized,
              controller: _streamController.cameraController,
            ),
            _buildTopBar(),
            _buildBottomBar(),
            if (_isOpeningSettings)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final l10n = L10n.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).maybePop(),
              tooltip: l10n.cancel,
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xs + 2,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: AppRadius.xl,
              ),
              child: Text(
                l10n.cameraTakePhotoOfFood,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final l10n = L10n.of(context)!;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.lg,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRoundedButton(
                icon: Icons.help_outline,
                label: l10n.gallery,
                onTap: () {},
              ),
              _buildRoundedButton(
                icon: Icons.settings_input_antenna_rounded,
                label: l10n.navCamera,
                onTap: _openSystemSettings,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundedButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          borderRadius: AppRadius.xl,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSystemSettings() async {
    setState(() => _isOpeningSettings = true);
    try {
      const platform = MethodChannel('miro_hybrid/settings');
      await platform.invokeMethod<void>('openAppSettings');
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to open settings'),
        backgroundColor: AppColors.error,
        duration: Duration(seconds: 2),
      ));
    } finally {
      if (mounted) {
        setState(() => _isOpeningSettings = false);
      }
    }
  }
}

