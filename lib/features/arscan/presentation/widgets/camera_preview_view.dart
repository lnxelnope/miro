import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Widget สำหรับแสดง camera preview แบบเต็มหน้าจอ
/// แยกออกมาเพื่อเตรียมรองรับ overlay และการแปลงพิกัดใน Phase ถัดไป
class CameraPreviewView extends StatelessWidget {
  final CameraController? controller;
  final bool isInitialized;

  const CameraPreviewView({
    super.key,
    required this.controller,
    required this.isInitialized,
  });

  @override
  Widget build(BuildContext context) {
    if (!isInitialized || controller == null || !controller!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    final previewSize = controller!.value.previewSize;
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
          child: CameraPreview(controller!),
        ),
      ),
    );
  }
}

