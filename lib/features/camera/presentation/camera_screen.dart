import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:miro_hybrid/core/services/image_picker_service.dart';
import 'package:path_provider/path_provider.dart';

import 'package:miro_hybrid/core/theme/app_tokens.dart';
import 'package:miro_hybrid/l10n/app_localizations.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isProcessing = false;
  bool _flashOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
      _cameraController?.dispose();
      _cameraController = null;
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(L10n.of(context)!.cameraFailedToInitialize), duration: const Duration(seconds: 2)),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final controller = _cameraController;
    _cameraController = null;
    _isInitialized = false;
    controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    bool didPop = false;

    try {
      final XFile photo = await _cameraController!.takePicture();

      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = '${appDir.path}/$fileName';
      await File(photo.path).copy(filePath);

      if (mounted) {
        didPop = true;
        Navigator.of(context).pop(File(filePath));
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
      if (!didPop && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(L10n.of(context)!.cameraFailedToCapture), duration: const Duration(seconds: 2)),
        );
      }
    } finally {
      if (!didPop && mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() => _isProcessing = true);

    try {
      final File? image = await ImagePickerService.pickFromGallery();

      if (image != null && mounted) {
        Navigator.of(context).pop(image);
      } else if (mounted) {
        setState(() => _isProcessing = false);
      }
    } catch (e) {
      debugPrint('Error picking from gallery: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(L10n.of(context)!.cameraFailedToPickFromGallery), duration: const Duration(seconds: 2)),
        );
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null) return;
    try {
      _flashOn = !_flashOn;
      await _cameraController!
          .setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error toggling flash: $e');
    }
  }

  Widget _buildCameraPreview() {
    if (!_isInitialized ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    final previewSize = _cameraController!.value.previewSize;
    if (previewSize == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: previewSize.height,
          height: previewSize.width,
          child: CameraPreview(_cameraController!),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildCameraPreview(),

          // Vignette
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.4),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6),
                    ],
                    stops: const [0.0, 0.15, 0.75, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Top hint
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs + 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: AppRadius.xl,
                  ),
                  child: Text(
                    L10n.of(context)!.cameraTakePhotoOfFood,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // AR tip: วางช้อนส้อมข้างจาน (แนะนำเท่านั้น ไม่ detect real-time)
          Positioned(
            bottom: 140,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: AppRadius.pill,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.straighten_rounded,
                      size: 16,
                      color: Colors.white70,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Place cutlery for scale reference',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(
                    bottom: 24.0, left: 24.0, right: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildBottomButton(
                      icon: _flashOn ? Icons.flash_on : Icons.flash_off,
                      onTap: _toggleFlash,
                    ),
                    _buildGalleryButton(),
                    _buildCaptureButton(),
                    _buildBottomButton(
                      icon: Icons.close,
                      onTap: _isProcessing ? () {} : () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Processing Overlay
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        L10n.of(context)!.cameraProcessing,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: _isProcessing ? null : _takePicture,
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: _isProcessing ? 50 : 62,
            height: _isProcessing ? 50 : 62,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryButton() {
    return GestureDetector(
      onTap: _isProcessing ? null : _pickFromGallery,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: AppRadius.lg,
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: const Icon(
          Icons.photo_library_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
