import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/utils/logger.dart';

class CardCaptureService {
  static Future<Uint8List?> captureCard(GlobalKey cardKey, {double pixelRatio = 3.0}) async {
    try {
      final boundary = cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      return byteData.buffer.asUint8List();
    } catch (e) {
      AppLogger.error('Failed to capture card', e);
      return null;
    }
  }

  static Future<File?> _saveTempFile(Uint8List bytes) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/arcal_share_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      AppLogger.error('Failed to save temp file', e);
      return null;
    }
  }

  static Future<bool> shareCard(GlobalKey cardKey, {double pixelRatio = 3.0}) async {
    final bytes = await captureCard(cardKey, pixelRatio: pixelRatio);
    if (bytes == null) return false;

    final file = await _saveTempFile(bytes);
    if (file == null) return false;

    try {
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
      return true;
    } catch (e) {
      AppLogger.error('Failed to share card', e);
      return false;
    }
  }

  static Future<bool> saveToGallery(GlobalKey cardKey, {double pixelRatio = 3.0}) async {
    final bytes = await captureCard(cardKey, pixelRatio: pixelRatio);
    if (bytes == null) return false;

    try {
      final permission = await PhotoManager.requestPermissionExtend();
      if (!permission.hasAccess) return false;

      final fileName = 'arcal_${DateTime.now().millisecondsSinceEpoch}.png';
      await PhotoManager.editor.saveImage(
        bytes,
        filename: fileName,
        title: fileName,
      );
      return true;
    } catch (e) {
      AppLogger.error('Failed to save to gallery', e);
      return false;
    }
  }
}
