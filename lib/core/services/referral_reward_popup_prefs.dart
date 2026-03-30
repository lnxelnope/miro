import 'package:shared_preferences/shared_preferences.dart';

/// "Maybe later" / dismiss outside — hide referral claim popup until next calendar day.
class ReferralRewardPopupPrefs {
  ReferralRewardPopupPrefs._();

  static String _todayKey() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  static Future<bool> isSuppressedToday() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('referral_reward_popup_suppress_day') == _todayKey();
  }

  static Future<void> suppressUntilTomorrow() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('referral_reward_popup_suppress_day', _todayKey());
  }
}
