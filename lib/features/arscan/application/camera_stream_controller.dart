import 'dart:async';

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

  final ArScanDetectionService _detectionService = ArScanDetectionService();

  final ValueNotifier<ArScanState> detectionState =
      ValueNotifier<ArScanState>(ArScanState.searching);

  final ValueNotifier<ArScanDetection?> primaryDetection =
      ValueNotifier<ArScanDetection?>(null);

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

  /// เตรียมกล้องสำหรับใช้งาน
  Future<void> initialize() async {
    if (_isDisposed) return;
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint('[ArScanCameraStreamController] No cameras available');
        return;
      }

      // ใช้กล้องตัวแรก (โดยทั่วไปคือกล้องหลัง)
      final controller = CameraController(
        cameras.first,
        resolutionPreset,
        enableAudio: enableAudio,
      );

      await controller.initialize();

      if (_isDisposed) {
        await controller.dispose();
        return;
      }

      _cameraController = controller;
    } catch (e) {
      debugPrint('[ArScanCameraStreamController] initialize error: $e');
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
        if (_frameStreamController.isClosed) return;
        _frameStreamController.add(image);

        // Detection pipeline
        final rotation = _mapDeviceOrientationToInputRotation(
          controller.description.sensorOrientation,
        );

        final detections =
            await _detectionService.detectFrame(image, rotation);

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
        primaryDetection.value = updatedPrimary;

        if (stableCount >= 5) {
          detectionState.value = ArScanState.readyForCapture;
        } else {
          detectionState.value = ArScanState.foodFound;
        }
      });
      _isStreaming = true;
    } catch (e) {
      debugPrint('[ArScanCameraStreamController] startStream error: $e');
    }
  }

  /// หยุด stream ของกล้อง (แต่ยังไม่ dispose controller)
  Future<void> stopStream() async {
    final controller = _cameraController;
    if (_isDisposed || controller == null) return;
    if (!controller.value.isStreamingImages) return;

    try {
      await controller.stopImageStream();
    } catch (e) {
      debugPrint('[ArScanCameraStreamController] stopStream error: $e');
    } finally {
      _isStreaming = false;
    }
  }

  /// ปล่อย resource ทั้งหมดของกล้องและ stream
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    await stopStream();

    detectionState.dispose();
    primaryDetection.dispose();
    await _detectionService.dispose();

    final controller = _cameraController;
    _cameraController = null;
    if (controller != null) {
      await controller.dispose();
    }

    await _frameStreamController.close();
  }
}

