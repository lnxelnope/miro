import 'package:shared_preferences/shared_preferences.dart';

/// Remembers that the seasonal-quest home popup was already shown for a quest on a calendar day,
/// so we do not keep a persistent banner (quest bar is off).
class SeasonalQuestPopupPrefs {
  SeasonalQuestPopupPrefs._();

  static String _keyFor(String questId, String yyyyMmDd) =>
      'seasonal_quest_popup_v1_${questId}_$yyyyMmDd';

  static String _todayStr() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  static Future<bool> wasShownToday(String questId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFor(questId, _todayStr())) ?? false;
  }

  /// Call once when the popup is about to show (prevents duplicate dialogs the same day).
  static Future<void> markShownToday(String questId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFor(questId, _todayStr()), true);
  }
}
