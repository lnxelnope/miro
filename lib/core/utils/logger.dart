import 'package:flutter/foundation.dart';

/// Logger ที่พิมพ์เฉพาะใน Debug mode
/// ใน Release mode → ไม่พิมพ์อะไรเลย (performance ดีขึ้น + ปลอดภัย)
class AppLogger {
  /// ข้อมูลทั่วไป
  static void info(String message) {
    if (kDebugMode) debugPrint('[INFO] $message');
  }

  /// Error
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[ERROR] $message');
      if (error != null) debugPrint('  → $error');
      if (stackTrace != null) debugPrint('  → $stackTrace');
    }
  }

  /// Warning
  static void warn(String message, [Object? error]) {
    if (kDebugMode) {
      debugPrint('[WARN] $message');
      if (error != null) debugPrint('  → $error');
    }
  }

  /// Debug (เปิดเฉพาะตอน dev)
  static void debug(String message) {
    if (kDebugMode) debugPrint('[DEBUG] $message');
  }
}
