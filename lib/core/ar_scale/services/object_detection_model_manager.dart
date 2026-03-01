import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Manages the custom TFLite object detection model lifecycle.
/// Copies the bundled EfficientDet-Lite0 model from Flutter assets
/// to the device filesystem so ML Kit can load it.
class ObjectDetectionModelManager {
  static const String _assetPath = 'assets/models/efficientnet_lite0_cls.tflite';
  static const String _modelFileName = 'efficientnet_lite0_cls.tflite';

  static String? _cachedModelPath;

  /// Returns the filesystem path to the TFLite model.
  /// Copies from assets on first call, returns cached path on subsequent calls.
  static Future<String?> getModelPath() async {
    if (_cachedModelPath != null) {
      final file = File(_cachedModelPath!);
      if (await file.exists()) return _cachedModelPath;
    }

    try {
      final appDir = await getApplicationSupportDirectory();
      final modelDir = Directory('${appDir.path}/ml_models');
      if (!await modelDir.exists()) {
        await modelDir.create(recursive: true);
      }

      final modelFile = File('${modelDir.path}/$_modelFileName');

      if (!await modelFile.exists()) {
        debugPrint('[ModelManager] Copying COCO model from assets...');
        final byteData = await rootBundle.load(_assetPath);
        await modelFile.writeAsBytes(
          byteData.buffer.asUint8List(
            byteData.offsetInBytes,
            byteData.lengthInBytes,
          ),
        );
        debugPrint('[ModelManager] Model copied: ${modelFile.path}');
      }

      _cachedModelPath = modelFile.path;
      return _cachedModelPath;
    } catch (e) {
      debugPrint('[ModelManager] Failed to prepare model: $e');
      return null;
    }
  }

  /// Clears the cached model (e.g. for re-download after update).
  static Future<void> clearCache() async {
    if (_cachedModelPath != null) {
      final file = File(_cachedModelPath!);
      if (await file.exists()) await file.delete();
      _cachedModelPath = null;
    }
  }
}
