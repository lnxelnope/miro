import 'package:shared_preferences/shared_preferences.dart';

/// นับจำนวน AI calls ต่อวัน
/// Free user ใช้ได้ 3 ครั้ง/วัน
/// Pro user ใช้ได้ไม่จำกัด
class UsageLimiter {
  static const int freeAiCallsPerDay = 3;

  /// PRODUCTION: Set to false when ready to sell Pro in production
  static const bool _forceProDuringDev = false;

  // SharedPreferences keys
  static const String _keyDate = 'ai_usage_date';
  static const String _keyCount = 'ai_usage_count';
  static const String _keyIsPro = 'is_pro_user';

  // ============ Pro Status ============

  /// Check if user is Pro
  static Future<bool> isPro() async {
    if (_forceProDuringDev) return true;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsPro) ?? false;
  }

  /// ตั้ง Pro status (เรียกหลังซื้อสำเร็จ หรือ restore สำเร็จ)
  static Future<void> setPro(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPro, value);
  }

  // ============ Usage Check ============

  /// ตรวจว่ายังใช้ AI ได้อีกไหม
  /// return true = ใช้ได้ / false = ใช้ครบแล้ว
  static Future<bool> canUseAi() async {
    // Pro ไม่จำกัด
    if (await isPro()) return true;

    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    final savedDate = prefs.getString(_keyDate) ?? '';

    // วันใหม่ → reset counter
    if (savedDate != today) {
      await prefs.setString(_keyDate, today);
      await prefs.setInt(_keyCount, 0);
      return true;
    }

    final count = prefs.getInt(_keyCount) ?? 0;
    return count < freeAiCallsPerDay;
  }

  /// เพิ่ม counter หลังใช้ AI สำเร็จ
  /// *** เรียกหลังจาก Gemini response กลับมาสำเร็จแล้วเท่านั้น ***
  static Future<void> recordAiUsage() async {
    // Pro ไม่ต้องนับ
    if (await isPro()) return;

    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    final savedDate = prefs.getString(_keyDate) ?? '';

    if (savedDate != today) {
      await prefs.setString(_keyDate, today);
      await prefs.setInt(_keyCount, 1);
    } else {
      final count = prefs.getInt(_keyCount) ?? 0;
      await prefs.setInt(_keyCount, count + 1);
    }
  }

  /// เหลือกี่ครั้งวันนี้
  /// return -1 ถ้าเป็น Pro (ไม่จำกัด)
  static Future<int> remainingToday() async {
    if (await isPro()) return -1;

    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    final savedDate = prefs.getString(_keyDate) ?? '';

    if (savedDate != today) return freeAiCallsPerDay;

    final count = prefs.getInt(_keyCount) ?? 0;
    return (freeAiCallsPerDay - count).clamp(0, freeAiCallsPerDay);
  }

  // ============ Helper ============

  /// วันที่ปัจจุบัน format "2026-02-11"
  static String _todayString() {
    return DateTime.now().toIso8601String().substring(0, 10);
  }
}
