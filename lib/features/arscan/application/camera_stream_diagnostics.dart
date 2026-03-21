import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/utils/logger.dart';

/// Lightweight utility สำหรับ debug performance ของ camera stream ใน dev build
///
/// วิธีใช้ (ตัวอย่าง):
/// ```dart
/// final diagnostics = CameraStreamDiagnostics();
///
/// cameraController.startImageStream((CameraImage image) {
///   diagnostics.onFrame();
///   // existing processing...
/// });
///
/// // ใน init หรือก่อนเริ่มทดสอบ long-run
/// diagnostics.startPeriodicLogging();
/// ```
class CameraStreamDiagnostics {
  CameraStreamDiagnostics({
    Duration fpsWindow = const Duration(seconds: 1),
    bool enableLogging = kDebugMode,
  })  : _fpsWindow = fpsWindow,
        _enableLogging = enableLogging;

  final Duration _fpsWindow;
  final bool _enableLogging;

  int _frameCountInWindow = 0;
  int _totalFrames = 0;
  DateTime? _windowStart;
  DateTime? _streamStart;
  double _currentFps = 0;
  Timer? _periodicLogTimer;

  /// ค่า fps ล่าสุดจาก window ปัจจุบัน
  double get currentFps => _currentFps;

  /// จำนวน frame ทั้งหมดตั้งแต่เริ่ม stream
  int get totalFrames => _totalFrames;

  /// ระยะเวลาตั้งแต่เริ่ม stream (ถ้าเคยรับ frame แล้ว)
  Duration? get elapsed {
    final start = _streamStart;
    if (start == null) return null;
    return DateTime.now().difference(start);
  }

  /// ควรเรียกทุกครั้งที่มี frame ใหม่จาก camera stream
  void onFrame() {
    final now = DateTime.now();
    _streamStart ??= now;
    _windowStart ??= now;

    _frameCountInWindow++;
    _totalFrames++;

    final windowStart = _windowStart!;
    final windowElapsed = now.difference(windowStart);
    if (windowElapsed >= _fpsWindow) {
      final seconds = windowElapsed.inMilliseconds / 1000.0;
      if (seconds > 0) {
        _currentFps = _frameCountInWindow / seconds;
      }

      if (_enableLogging) {
        final elapsedSeconds = elapsed?.inSeconds ?? 0;
        AppLogger.info(
          '[CameraDiagnostics] FPS=${_currentFps.toStringAsFixed(1)} '
          '(elapsed=${elapsedSeconds}s, frames=$_totalFrames)',
        );
      }

      _frameCountInWindow = 0;
      _windowStart = now;
    }
  }

  /// เริ่ม log สถานะ long-run เป็นระยะ ๆ (ใช้สำหรับทดสอบ stability)
  ///
  /// แนะนำให้ใช้ interval 30–60 วินาทีใน dev build
  void startPeriodicLogging({Duration interval = const Duration(seconds: 30)}) {
    _periodicLogTimer?.cancel();
    if (!_enableLogging) return;

    _periodicLogTimer = Timer.periodic(interval, (_) {
      final elapsedSeconds = elapsed?.inSeconds ?? 0;
      AppLogger.info(
        '[CameraDiagnostics] Long-run status: '
        'elapsed=${elapsedSeconds}s, '
        'fps(window)=${_currentFps.toStringAsFixed(1)}, '
        'frames=$_totalFrames',
      );
    });
  }

  /// หยุดการ log ระยะยาว (ควรถูกเรียกเมื่อปิดหน้าจอหรือหยุด stream)
  void stopPeriodicLogging() {
    _periodicLogTimer?.cancel();
    _periodicLogTimer = null;
  }

  void dispose() {
    stopPeriodicLogging();
  }
}

/// แนวทางทดสอบ long-run stability ของ camera stream
///
/// use-case หลัก:
/// - ตรวจสอบว่า stream รันต่อเนื่องอย่างน้อย 5 นาทีโดยไม่ crash
/// - ดูแนวโน้ม fps ว่าคงที่หรือเริ่ม drop ลงเมื่อเวลาผ่านไป
/// - ใช้คู่กับ Flutter DevTools เพื่อดู memory/exception เพิ่มเติม
class CameraStreamLongRunTestGuide {
  /// ระยะเวลาทดสอบแนะนำขั้นต่ำ
  static const Duration recommendedDuration = Duration(minutes: 5);

  /// Checklist แบบสั้น ๆ สำหรับ dev เวลาเตรียมทดสอบ
  static const List<String> checklist = [
    // 1) เตรียม build
    '1) เปิด dev build ในโหมด debug (เชื่อมต่อ DevTools ได้)',
    '2) เปิดหน้าจอ ARscan/camera stream ที่ใช้ CameraStreamDiagnostics',
    '3) สร้าง instance ของ CameraStreamDiagnostics และเรียก startPeriodicLogging()',

    // 2) ระหว่างทดสอบ
    '4) ปล่อยให้ camera stream ทำงานต่อเนื่องอย่างน้อย 5 นาที '
        '(ไม่สลับแอป / ไม่ปิดหน้าจอ ถ้าไม่ใช่ส่วนหนึ่งของ test case)',
    '5) ดู log prefix [CameraDiagnostics] ว่า fps ยังอยู่ในช่วงที่รับได้ '
        '(เช่น > 20 fps สำหรับ real-time AR)',
    '6) ดู log ว่าไม่มี error/exception ที่เกี่ยวกับ camera, memory, หรือ stream ถูกปิดเอง',

    // 3) การเก็บผล
    '7) หลังจบทดสอบ สรุปค่าเฉลี่ย fps คร่าว ๆ และ note device + OS version',
    '8) ใช้ Flutter DevTools (ถ้ามี) เพื่อดู memory graph ระหว่างช่วงทดสอบ '
        'เช็คว่าไม่มี memory leak ชัดเจน',
  ];

  /// คืนค่า checklist ในรูปแบบข้อความเดียว (ใช้แนบใน report หรือ UI dev tools)
  static String checklistAsMultilineText() {
    return checklist.join('\n');
  }
}


