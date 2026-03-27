import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

import 'package:google_mlkit_commons/google_mlkit_commons.dart';

import 'arscan_detection_service.dart';
import '../domain/models/ar_scan_detection.dart';

/// Controller สำหรับจัดการ camera stream ของ ARscan
///
/// จุดประสงค์หลัก:
/// - แยก logic การจัดการกล้องออกจาก UI/widget layer
/// - เตรียม interface สำหรับให้ phase detection มาสมัครรับ frame stream ภายหลัง
class ArScanCameraStreamController {
  final ResolutionPreset resolutionPreset;
  final bool enableAudio;

  CameraController? _cameraController;
  bool _isStreaming = false;
  bool _isDisposed = false;

  /// Static lock: ป้องกัน instance เก่ายัง dispose ไม่เสร็จ
  /// แล้ว instance ใหม่พยายามเปิดกล้องซ้อน → Camera2 NPE crash
  static Future<void>? _pendingDispose;

  /// Serialize concurrent initialize() calls — ป้องกัน iOS lifecycle
  /// trigger ซ้อนตอน permission dialog (inactive → resumed) ทำให้สร้าง
  /// CameraController 2 ตัวพร้อมกัน → AVCaptureSession conflict
  Completer<void>? _initCompleter;

  final ArScanDetectionService _detectionService = ArScanDetectionService();

  ArScanDetectionService get detectionService => _detectionService;

  final ValueNotifier<ArScanState> detectionState =
      ValueNotifier<ArScanState>(ArScanState.searching);

  final ValueNotifier<ArScanDetection?> primaryDetection =
      ValueNotifier<ArScanDetection?>(null);

  final ValueNotifier<FlashMode> flashMode =
      ValueNotifier<FlashMode>(FlashMode.off);

  ArScanDetection? _lastPrimaryDetection;

  /// Stream ของ camera frame สำหรับผู้บริโภคภายนอก (เช่น detection phase)
  final StreamController<CameraImage> _frameStreamController =
      StreamController<CameraImage>.broadcast();

  ArScanCameraStreamController({
    this.resolutionPreset = ResolutionPreset.high,
    this.enableAudio = false,
  });

  /// expose CameraController ให้ UI ใช้กับ CameraPreview ได้
  CameraController? get cameraController => _cameraController;

  /// สถานะการ initialize
  bool get isInitialized =>
      _cameraController != null && _cameraController!.value.isInitialized;

  /// สถานะการ stream
  bool get isStreaming => _isStreaming;

  /// stream ของ frame ที่พร้อมให้ consumer ใน phase ถัดไป subscribe
  Stream<CameraImage> get frameStream => _frameStreamController.stream;

  Future<void> toggleFlash() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    final newMode =
        flashMode.value == FlashMode.off ? FlashMode.torch : FlashMode.off;
    try {
      await controller.setFlashMode(newMode);
      flashMode.value = newMode;
    } catch (e) {
      debugPrint('[ArScanCameraStreamController] toggleFlash error: $e');
    }
  }

  InputImageRotation _mapDeviceOrientationToInputRotation(int sensorOrientation) {
    switch (sensorOrientation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      case 0:
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  /// เตรียมกล้องสำหรับใช้งาน — รอ dispose เก่าจบก่อนแล้วค่อยเปิดใหม่
  ///
  /// Serialized: ถ้ามี init อีกตัวกำลังทำงาน จะรอให้เสร็จแทนที่จะ init ซ้อน
  /// (ป้องกัน iOS lifecycle trigger ซ้อน → AVCaptureSession conflict)
  Future<void> initialize() async {
    if (_isDisposed) return;

    // ถ้ามี init กำลังทำงาน → รอให้เสร็จแล้ว return (ไม่ init ซ้อน)
    final existing = _initCompleter;
    if (existing != null) {
      debugPrint('[ArScanCameraStreamController] waiting for existing init…');
      await existing.future;
      return;
    }

    // รอ instance เก่า dispose ให้เสร็จก่อน (ป้องกัน Camera2 ซ้อน)
    final pending = _pendingDispose;
    if (pending != null) {
      debugPrint('[ArScanCameraStreamController] waiting for previous dispose…');
      await pending;
    }

    if (_isDisposed) return;
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      return;
    }

    final completer = Completer<void>();
    _initCompleter = completer;

    try {
      const maxRetries = 2;
      for (var attempt = 0; attempt <= maxRetries; attempt++) {
        try {
          final cameras = await availableCameras();
          if (cameras.isEmpty) {
            debugPrint('[ArScanCameraStreamController] No cameras available');
            return;
          }

          final controller = CameraController(
            cameras.first,
            resolutionPreset,
            enableAudio: enableAudio,
            imageFormatGroup: Platform.isAndroid
                ? ImageFormatGroup.nv21
                : ImageFormatGroup.bgra8888,
          );

          await controller.initialize();

          if (_isDisposed) {
            await controller.dispose();
            return;
          }

          _cameraController = controller;
          return;
        } catch (e) {
          debugPrint(
            '[ArScanCameraStreamController] initialize error (attempt $attempt): $e',
          );
          if (attempt < maxRetries) {
            await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
            if (_isDisposed) return;
          }
        }
      }
    } finally {
      completer.complete();
      if (identical(_initCompleter, completer)) {
        _initCompleter = null;
      }
    }
  }

  /// เริ่ม stream ของ camera frame
  ///
  /// UI สามารถใช้ร่วมกับ CameraPreview ได้ และ phase detection ภายหลัง
  /// สามารถ subscribe `frameStream` เพื่อนำไปประมวลผลต่อ
  Future<void> startStream() async {
    final controller = _cameraController;
    if (_isDisposed || controller == null) return;
    if (!controller.value.isInitialized) return;
    if (_isStreaming) return;

    try {
      await controller.startImageStream((image) async {
        if (_isDisposed || !_isStreaming) return;
        if (_frameStreamController.isClosed) return;

        _frameStreamController.add(image);

        try {
          final rotation = _mapDeviceOrientationToInputRotation(
            controller.description.sensorOrientation,
          );

          // detectFrame() มี _isProcessing lock ภายในแล้ว —
          // ป้องกัน concurrent ML Kit processImage() บน Android
          // โดยคืน cached results ถ้า frame ก่อนหน้ายังประมวลผลอยู่
          final detections =
              await _detectionService.detectFrame(image, rotation);

          if (_isDisposed) return;

          if (detections.isEmpty) {
            detectionState.value = ArScanState.searching;
            primaryDetection.value = null;
            _lastPrimaryDetection = null;
            return;
          }

          final primary = detections.firstWhere(
            (d) => d.isPrimary,
            orElse: () => detections.first,
          );

          var stableCount = 1;
          if (_lastPrimaryDetection != null &&
              _lastPrimaryDetection!.trackingId != null &&
              primary.trackingId != null &&
              _lastPrimaryDetection!.trackingId == primary.trackingId) {
            stableCount = _lastPrimaryDetection!.stableFrameCount + 1;
          }

          final updatedPrimary =
              primary.copyWith(stableFrameCount: stableCount);

          _lastPrimaryDetection = updatedPrimary;
          if (!_isDisposed) {
            primaryDetection.value = updatedPrimary;

            final hasFoodPrimary = updatedPrimary.isFood;
            if (hasFoodPrimary && stableCount >= 5) {
              detectionState.value = ArScanState.readyForCapture;
            } else {
              detectionState.value = ArScanState.foodFound;
            }
          }
        } catch (e) {
          debugPrint('[ArScanCamera] frame processing error: $e');
        }
      });
      _isStreaming = true;
    } catch (e) {
      debugPrint('[ArScanCamera] startStream error: $e');
    }
  }

  /// หยุด stream ของกล้อง (แต่ยังไม่ dispose controller)
  Future<void> stopStream() async {
    _isStreaming = false;
    final controller = _cameraController;
    if (_isDisposed || controller == null) return;

    try {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
    } catch (e) {
      debugPrint('[ArScanCamera] stopStream error: $e');
    }
  }

  /// ปล่อย resource ทั้งหมดของกล้องและ stream
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    final future = _doDispose();
    _pendingDispose = future;
    await future;
    // เคลียร์ static ref เฉพาะเมื่อยังเป็น future เดิมอยู่
    if (identical(_pendingDispose, future)) {
      _pendingDispose = null;
    }
  }

  Future<void> _doDispose() async {
    try {
      await stopStream();
    } catch (e) {
      debugPrint('[ArScanCameraStreamController] stopStream in dispose error: $e');
    }

    detectionState.dispose();
    primaryDetection.dispose();
    flashMode.dispose();
    await _detectionService.dispose();

    final controller = _cameraController;
    _cameraController = null;
    if (controller != null) {
      // รอให้ native Camera2 callbacks (เช่น unlockAutoFocus) ทำงานเสร็จ
      // ก่อน dispose camera controller เพื่อป้องกัน NPE crash
      await Future.delayed(const Duration(milliseconds: 500));
      try {
        await controller.dispose();
      } catch (e) {
        debugPrint('[ArScanCameraStreamController] controller.dispose error: $e');
      }
    }

    await _frameStreamController.close();
  }
}

