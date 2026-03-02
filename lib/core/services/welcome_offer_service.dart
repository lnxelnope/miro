import 'package:shared_preferences/shared_preferences.dart';

/// Tracks AI usage to unlock a welcome discount offer.
class WelcomeOfferService {
  static const int triggerCount = 10;
  static const String _usageKey = 'welcome_offer_ai_usage';

  /// Returns how many more AI uses are needed before the offer unlocks.
  static Future<int> getRemainingUsages() async {
    final prefs = await SharedPreferences.getInstance();
    final used = prefs.getInt(_usageKey) ?? 0;
    final remaining = triggerCount - used;
    return remaining.clamp(0, triggerCount);
  }

  /// Increments the usage counter by one.
  static Future<void> recordUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final used = prefs.getInt(_usageKey) ?? 0;
    await prefs.setInt(_usageKey, used + 1);
  }
}
