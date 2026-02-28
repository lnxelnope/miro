import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Firebase Analytics Service
///
/// Centralized analytics logging for user acquisition and ad network optimization.
/// Events are designed to align with Google Ads conversion tracking.
/// 
/// GDPR/PDPA Compliance:
/// - Analytics are disabled by default
/// - Only enabled after user consent
/// - User can revoke consent anytime
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static bool _isEnabled = false;

  /// Initialize analytics (disabled by default, respects consent)
  static Future<void> initialize({
    String? tier,
    bool? isSubscriber,
    int? totalSpent,
    int? streakDays,
    String? appVersion,
    bool enabled = false,
  }) async {
    try {
      _isEnabled = enabled;
      await _analytics.setAnalyticsCollectionEnabled(enabled);

      if (enabled) {
        if (tier != null) {
          await _analytics.setUserProperty(name: 'user_tier', value: tier);
        }
        if (isSubscriber != null) {
          await _analytics.setUserProperty(
            name: 'is_subscriber',
            value: isSubscriber.toString(),
          );
        }
        if (totalSpent != null) {
          await _analytics.setUserProperty(
            name: 'total_energy_spent',
            value: _spendBucket(totalSpent),
          );
        }
        if (streakDays != null) {
          await _analytics.setUserProperty(
            name: 'streak_days',
            value: _streakBucket(streakDays),
          );
        }
        if (appVersion != null) {
          await _analytics.setUserProperty(
            name: 'app_version',
            value: appVersion,
          );
        }
      }

      debugPrint('[Analytics] Initialized (enabled: $enabled)');
    } catch (e) {
      debugPrint('[Analytics] Init error: $e');
    }
  }

  /// Enable or disable analytics collection
  static Future<void> setAnalyticsEnabled(bool enabled) async {
    try {
      _isEnabled = enabled;
      await _analytics.setAnalyticsCollectionEnabled(enabled);
      debugPrint('[Analytics] Collection ${enabled ? "ENABLED" : "DISABLED"}');
    } catch (e) {
      debugPrint('[Analytics] Error setting enabled: $e');
    }
  }

  /// Check if analytics is currently enabled
  static bool get isEnabled => _isEnabled;

  /// Update user properties when state changes
  static Future<void> updateUserProperties({
    String? tier,
    bool? isSubscriber,
    int? totalSpent,
    int? streakDays,
  }) async {
    if (!_isEnabled) return; // Skip if analytics disabled
    
    try {
      if (tier != null) {
        await _analytics.setUserProperty(name: 'user_tier', value: tier);
      }
      if (isSubscriber != null) {
        await _analytics.setUserProperty(
          name: 'is_subscriber',
          value: isSubscriber.toString(),
        );
      }
      if (totalSpent != null) {
        await _analytics.setUserProperty(
          name: 'total_energy_spent',
          value: _spendBucket(totalSpent),
        );
      }
      if (streakDays != null) {
        await _analytics.setUserProperty(
          name: 'streak_days',
          value: _streakBucket(streakDays),
        );
      }
    } catch (e) {
      debugPrint('[Analytics] Update properties error: $e');
    }
  }

  // ─── Core Events ───

  /// AI food analysis completed
  static Future<void> logAiAnalysis({
    required String analysisType,
    int? energyCost,
    bool? isSubscriber,
    int? itemCount,
  }) async {
    await _logEvent('ai_analysis', {
      'analysis_type': analysisType,
      if (energyCost != null) 'energy_cost': energyCost,
      if (isSubscriber != null) 'is_subscriber': isSubscriber.toString(),
      if (itemCount != null) 'item_count': itemCount,
    });
  }

  /// Meal logged (manual or from AI)
  static Future<void> logMealLogged({
    required String source,
    int? itemCount,
  }) async {
    await _logEvent('meal_logged', {
      'source': source,
      if (itemCount != null) 'item_count': itemCount,
    });
  }

  /// Daily check-in
  static Future<void> logDailyCheckIn({
    required int streakDays,
    required String tier,
    int? energyBonus,
  }) async {
    await _logEvent('daily_checkin', {
      'streak_days': streakDays,
      'tier': tier,
      if (energyBonus != null) 'energy_bonus': energyBonus,
    });
  }

  /// Energy purchased (in-app purchase)
  static Future<void> logEnergyPurchase({
    required String packageId,
    required int energyAmount,
    required double price,
    required String currency,
  }) async {
    // Standard Firebase purchase event for Google Ads conversion
    await _analytics.logPurchase(
      currency: currency,
      value: price,
      items: [
        AnalyticsEventItem(
          itemId: packageId,
          itemName: 'Energy $energyAmount',
          quantity: 1,
          price: price,
        ),
      ],
    );

    await _logEvent('energy_purchase', {
      'package_id': packageId,
      'energy_amount': energyAmount,
      'price': price,
      'currency': currency,
    });
  }

  /// Subscription started
  static Future<void> logSubscribe({
    required String productId,
    required double price,
    required String currency,
  }) async {
    await _analytics.logPurchase(
      currency: currency,
      value: price,
      items: [
        AnalyticsEventItem(
          itemId: productId,
          itemName: 'Energy Pass',
          quantity: 1,
          price: price,
        ),
      ],
    );

    await _logEvent('subscribe', {
      'product_id': productId,
      'price': price,
      'currency': currency,
    });
  }

  /// Barcode scanned
  static Future<void> logBarcodeScan({
    bool? productFound,
  }) async {
    await _logEvent('barcode_scan', {
      if (productFound != null) 'product_found': productFound.toString(),
    });
  }

  /// Challenge completed
  static Future<void> logChallengeCompleted({
    required String challengeType,
    int? reward,
  }) async {
    await _logEvent('challenge_completed', {
      'challenge_type': challengeType,
      if (reward != null) 'reward': reward,
    });
  }

  /// Streak milestone reached
  static Future<void> logStreakMilestone({
    required int streakDays,
    required String newTier,
  }) async {
    await _logEvent('streak_milestone', {
      'streak_days': streakDays,
      'new_tier': newTier,
    });
  }

  /// Onboarding completed
  static Future<void> logOnboardingComplete() async {
    await _logEvent('onboarding_complete', {});
  }

  /// Energy store opened
  static Future<void> logStoreOpened() async {
    await _logEvent('store_opened', {});
  }

  /// Screen view
  static Future<void> logScreenView(String screenName) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
    } catch (e) {
      debugPrint('[Analytics] Screen view error: $e');
    }
  }

  /// Get analytics observer for MaterialApp navigatorObservers
  static FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // ─── Helpers ───

  static Future<void> _logEvent(
    String name,
    Map<String, Object> parameters,
  ) async {
    if (!_isEnabled) return; // Skip if analytics disabled
    
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
      debugPrint('[Analytics] Event: $name $parameters');
    } catch (e) {
      debugPrint('[Analytics] Log error ($name): $e');
    }
  }

  static String _spendBucket(int totalSpent) {
    if (totalSpent == 0) return '0';
    if (totalSpent < 50) return '1-49';
    if (totalSpent < 200) return '50-199';
    if (totalSpent < 500) return '200-499';
    if (totalSpent < 1000) return '500-999';
    return '1000+';
  }

  static String _streakBucket(int days) {
    if (days == 0) return '0';
    if (days < 3) return '1-2';
    if (days < 7) return '3-6';
    if (days < 14) return '7-13';
    if (days < 30) return '14-29';
    return '30+';
  }
}
