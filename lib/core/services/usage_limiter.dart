import 'package:shared_preferences/shared_preferences.dart';

/// นับจำนวน AI calls ต่อวัน
/// Free user ใช้ได้ 3 ครั้ง/วัน
/// Pro user ใช้ได้ไม่จำกัด
class UsageLimiter {
  static const int freeAiCallsPerDay = 3;

  /// CLOSED BETA: Everyone is Pro during beta testing
  /// TODO: Set to false before public launch (when removing BetaFeedbackButton)
  static const bool _forceProDuringDev = true;

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

  // ============ Daily Analysis Safety Cap ============
  // Hard cap to prevent abuse (applies to ALL users including Pro/Energy Pass)
  static const int maxAnalysesPerDay = 100;
  static const String _keyAnalysisDate = 'analysis_cap_date';
  static const String _keyAnalysisCount = 'analysis_cap_count';

  /// Check if user has reached daily analysis cap
  static Future<bool> hasReachedDailyCap() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    final savedDate = prefs.getString(_keyAnalysisDate) ?? '';

    if (savedDate != today) return false;

    final count = prefs.getInt(_keyAnalysisCount) ?? 0;
    return count >= maxAnalysesPerDay;
  }

  /// Record an analysis usage (for daily cap)
  static Future<void> recordAnalysisForCap() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    final savedDate = prefs.getString(_keyAnalysisDate) ?? '';

    if (savedDate != today) {
      await prefs.setString(_keyAnalysisDate, today);
      await prefs.setInt(_keyAnalysisCount, 1);
    } else {
      final count = prefs.getInt(_keyAnalysisCount) ?? 0;
      await prefs.setInt(_keyAnalysisCount, count + 1);
    }
  }

  /// Remaining analyses today
  static Future<int> remainingAnalysesToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    final savedDate = prefs.getString(_keyAnalysisDate) ?? '';

    if (savedDate != today) return maxAnalysesPerDay;

    final count = prefs.getInt(_keyAnalysisCount) ?? 0;
    return (maxAnalysesPerDay - count).clamp(0, maxAnalysesPerDay);
  }

  // ============ Free Ingredient Edit Lookups ============
  // Ingredient lookups from edit screen are free (limited per day)
  // because user correction data is extremely valuable.

  static const int freeEditLookupsPerDay = 10;
  static const String _keyEditLookupDate = 'edit_lookup_date';
  static const String _keyEditLookupCount = 'edit_lookup_count';

  /// Check if user has free ingredient lookups remaining (edit screen only)
  static Future<bool> canUseFreeEditLookup() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    final savedDate = prefs.getString(_keyEditLookupDate) ?? '';

    if (savedDate != today) return true;

    final count = prefs.getInt(_keyEditLookupCount) ?? 0;
    return count < freeEditLookupsPerDay;
  }

  /// Record a free ingredient lookup usage
  static Future<void> recordFreeEditLookup() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    final savedDate = prefs.getString(_keyEditLookupDate) ?? '';

    if (savedDate != today) {
      await prefs.setString(_keyEditLookupDate, today);
      await prefs.setInt(_keyEditLookupCount, 1);
    } else {
      final count = prefs.getInt(_keyEditLookupCount) ?? 0;
      await prefs.setInt(_keyEditLookupCount, count + 1);
    }
  }

  /// Remaining free edit lookups today
  static Future<int> remainingFreeEditLookups() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    final savedDate = prefs.getString(_keyEditLookupDate) ?? '';

    if (savedDate != today) return freeEditLookupsPerDay;

    final count = prefs.getInt(_keyEditLookupCount) ?? 0;
    return (freeEditLookupsPerDay - count).clamp(0, freeEditLookupsPerDay);
  }

  // ============ Daily Free Chat Limit ============
  // Chat and menu suggestion are free but limited per day
  static const int freeChatPerDay = 10;
  static const String _keyChatDate = 'chat_limit_date';
  static const String _keyChatCount = 'chat_limit_count';

  /// Check if user has free chat remaining today
  static Future<bool> canUseFreeChat() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    final savedDate = prefs.getString(_keyChatDate) ?? '';

    if (savedDate != today) return true;

    final count = prefs.getInt(_keyChatCount) ?? 0;
    return count < freeChatPerDay;
  }

  /// Record a free chat usage
  static Future<void> recordFreeChatUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    final savedDate = prefs.getString(_keyChatDate) ?? '';

    if (savedDate != today) {
      await prefs.setString(_keyChatDate, today);
      await prefs.setInt(_keyChatCount, 1);
    } else {
      final count = prefs.getInt(_keyChatCount) ?? 0;
      await prefs.setInt(_keyChatCount, count + 1);
    }
  }

  /// Remaining free chats today
  static Future<int> remainingFreeChatToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    final savedDate = prefs.getString(_keyChatDate) ?? '';

    if (savedDate != today) return freeChatPerDay;

    final count = prefs.getInt(_keyChatCount) ?? 0;
    return (freeChatPerDay - count).clamp(0, freeChatPerDay);
  }

  // ============ Helper ============

  /// วันที่ปัจจุบัน format "2026-02-11"
  static String _todayString() {
    return DateTime.now().toIso8601String().substring(0, 10);
  }
}
