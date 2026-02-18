import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_hybrid/core/models/gamification_state.dart';
import 'package:miro_hybrid/core/services/energy_service.dart';
import 'package:miro_hybrid/core/services/analytics_service.dart';
import 'package:miro_hybrid/core/database/database_service.dart';

final gamificationProvider =
    StateNotifierProvider<GamificationNotifier, GamificationState>((ref) {
  final energyService = EnergyService(DatabaseService.isar);
  return GamificationNotifier(energyService);
});

class GamificationNotifier extends StateNotifier<GamificationState> {
  final EnergyService _energyService;

  GamificationNotifier(this._energyService)
      : super(GamificationState.empty()) {
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      debugPrint('[Gamification] _loadState: calling registerOrSync...');
      final result = await _energyService.registerOrSync();
      debugPrint('[Gamification] registerOrSync result keys: ${result.keys.toList()}');
      debugPrint('[Gamification] registerOrSync raw: miroId=${result['miroId']}, '
          'balance=${result['balance']}, tier=${result['tier']}, '
          'challenges=${result['challenges']}, '
          'milestones=${result['milestones']}, '
          'subscription=${result['subscription']}');

      // Phase 2: Load challenge & milestone data
      final challenges = result['challenges']?['weekly'] ?? {};
      final milestones = result['milestones'] ?? {};

      // Safe parsing for subscription
      final rawSub = result['subscription'];
      final subscription = rawSub is Map<String, dynamic> ? rawSub : <String, dynamic>{};
      final subStatus = subscription['status']?.toString();
      final isSubActive = subStatus == 'active' || subStatus == 'grace_period';

      // Parse subscription expiry date safely (handle Timestamp, String, Map)
      DateTime? subExpiryDate;
      final expiryRaw = subscription['expiryDate'];
      if (expiryRaw != null) {
        if (expiryRaw is String) {
          subExpiryDate = DateTime.tryParse(expiryRaw);
        } else if (expiryRaw is Map) {
          final seconds = expiryRaw['_seconds'] ?? expiryRaw['seconds'];
          if (seconds is num) {
            subExpiryDate =
                DateTime.fromMillisecondsSinceEpoch(seconds.toInt() * 1000);
          }
        }
      }

      state = GamificationState(
        miroId: result['miroId']?.toString() ?? '',
        currentStreak: (result['currentStreak'] as num?)?.toInt() ?? 0,
        longestStreak: (result['longestStreak'] as num?)?.toInt() ?? 0,
        tier: result['tier']?.toString() ?? 'none',
        freeAiAvailable: !(result['freeAiUsedToday'] ?? false),
        balance: (result['balance'] as num?)?.toInt() ?? 0,
        logMealsProgress: (challenges['logMeals'] as num?)?.toInt() ?? 0,
        useAiProgress: (challenges['useAi'] as num?)?.toInt() ?? 0,
        claimedRewards: List<String>.from(challenges['claimedRewards'] ?? []),
        totalSpent: (result['totalSpent'] as num?)?.toInt() ?? 0,
        spent500Claimed: milestones['spent500Claimed'] ?? false,
        spent1000Claimed: milestones['spent1000Claimed'] ?? false,
        bonusRate: (result['bonusRate'] as num?)?.toDouble() ?? 0.0,
        isSubscriber: isSubActive,
        subscriptionStatus: subStatus,
        subscriptionExpiryDate: subExpiryDate,
      );

      debugPrint('[Gamification] State set: miroId="${state.miroId}", '
          'balance=${state.balance}, tier=${state.tier}, '
          'logMeals=${state.logMealsProgress}, useAi=${state.useAiProgress}, '
          'isSubscriber=${state.isSubscriber}, sub=$subStatus');

      // Update analytics user properties
      AnalyticsService.updateUserProperties(
        tier: state.tier,
        isSubscriber: state.isSubscriber,
        totalSpent: state.totalSpent,
        streakDays: state.currentStreak,
      );
    } catch (e, stackTrace) {
      debugPrint('[Gamification] _loadState FAILED: $e');
      debugPrint('[Gamification] Stack: $stackTrace');
      // Fallback
      final balance = await _energyService.getBalance();
      final miroId = await _energyService.getMiroId();
      state = GamificationState(
        miroId: miroId ?? '',
        currentStreak: 0,
        longestStreak: 0,
        tier: 'none',
        freeAiAvailable: true,
        balance: balance,
        logMealsProgress: 0,
        useAiProgress: 0,
        claimedRewards: const [],
        totalSpent: 0,
        spent500Claimed: false,
        spent1000Claimed: false,
        bonusRate: 0.0,
      );
    }
  }

  /// Update state จาก AI response
  /// Returns daily check-in info for welcome dialog (null if already checked in)
  Map<String, dynamic>? updateFromAiResponse(Map<String, dynamic> response) {
    final streak = response['streak'] as Map<String, dynamic>?;
    final wasFreeAi = response['wasFreeAi'] == true;
    final newBalance = (response['balance'] as num?)?.toInt();
    
    // Phase 2: Update challenges & milestones
    final challenges = response['challenges']?['weekly'] ?? {};
    final milestones = response['milestones'] ?? {};
    final totalSpent = (response['totalSpent'] as num?)?.toInt() ?? state.totalSpent;

    // Subscription data from response (or from isSubscriber flag)
    final subscription = response['subscription'] as Map<String, dynamic>?;
    final isSubFromResponse = response['isSubscriber'] == true;

    state = state.copyWith(
      currentStreak: (streak?['current'] as num?)?.toInt(),
      longestStreak: (streak?['longest'] as num?)?.toInt(),
      tier: streak?['tier']?.toString(),
      freeAiAvailable: !wasFreeAi,
      balance: newBalance,
      logMealsProgress: (challenges['logMeals'] as num?)?.toInt() ?? state.logMealsProgress,
      useAiProgress: (challenges['useAi'] as num?)?.toInt() ?? state.useAiProgress,
      claimedRewards: List<String>.from(challenges['claimedRewards'] ?? state.claimedRewards),
      totalSpent: totalSpent,
      spent500Claimed: milestones['spent500Claimed'] ?? state.spent500Claimed,
      spent1000Claimed: milestones['spent1000Claimed'] ?? state.spent1000Claimed,
      isSubscriber: subscription != null
          ? (subscription['status'] == 'active' || subscription['status'] == 'grace_period')
          : (isSubFromResponse ? true : null),
      subscriptionStatus: subscription?['status']?.toString(),
      subscriptionExpiryDate: subscription?['expiryDate'] != null
          ? DateTime.tryParse(subscription!['expiryDate'].toString())
          : null,
    );

    // Return daily check-in data for welcome dialog
    final dailyEnergy = (streak?['energyBonus'] as num?)?.toInt() ?? 0;
    final tierUpgraded = streak?['tierUpgraded'] == true;
    final tierDemoted = streak?['tierDemoted'] == true;
    final currentStreak = (streak?['current'] as num?)?.toInt() ?? 0;
    final tier = streak?['tier']?.toString() ?? 'none';
    final showWelcomeBackOffer = streak?['showWelcomeBackOffer'] == true;
    final tierRewardEnergy = (streak?['tierRewardEnergy'] as num?)?.toInt() ?? 0;
    final promotionBonusRate = (streak?['promotionBonusRate'] as num?)?.toDouble() ?? 0;

    // Welcome offer promotion from response
    final promotion = response['promotion'] as Map<String, dynamic>?;

    if (dailyEnergy > 0 || tierDemoted || tierUpgraded || promotion != null) {
      return {
        'dailyEnergy': dailyEnergy,
        'currentStreak': currentStreak,
        'tier': tier,
        'tierUpgraded': tierUpgraded,
        'tierDemoted': tierDemoted,
        'previousTier': streak?['previousTier'],
        'newTier': streak?['newTier'],
        'showWelcomeBackOffer': showWelcomeBackOffer,
        'tierRewardEnergy': tierRewardEnergy,
        'promotionBonusRate': promotionBonusRate,
        if (promotion != null) ...{
          'welcomeOfferPromo': true,
          'welcomeOfferFreeEnergy': promotion['freeEnergy'] as int? ?? 0,
          'welcomeOfferBonusRate': (promotion['bonusRate'] as num?)?.toDouble() ?? 0,
        },
      };
    }
    return null;
  }

  /// Update state จาก check-in response (Phase 2: random bonus)
  /// Returns random bonus amount if got bonus, otherwise null
  int? updateFromCheckInResponse(Map<String, dynamic> response) {
    final streak = response['streak'] as Map<String, dynamic>?;
    final randomBonus = (response['randomBonus'] as num?)?.toInt() ?? 0;
    final gotRandomBonus = response['gotRandomBonus'] == true;
    final newBalance = (response['newBalance'] as num?)?.toInt();

    final currentStreak = (streak?['current'] as num?)?.toInt() ?? state.currentStreak;
    final tier = streak?['tier']?.toString() ?? state.tier;
    final energyBonus = (streak?['energyBonus'] as num?)?.toInt() ?? 0;

    state = state.copyWith(
      currentStreak: currentStreak,
      longestStreak: (streak?['longest'] as num?)?.toInt(),
      tier: tier,
      balance: newBalance,
    );

    // Analytics: daily check-in
    AnalyticsService.logDailyCheckIn(
      streakDays: currentStreak,
      tier: tier,
      energyBonus: energyBonus + randomBonus,
    );

    // Tier upgrade milestone
    if (streak?['tierUpgraded'] == true) {
      AnalyticsService.logStreakMilestone(
        streakDays: currentStreak,
        newTier: tier,
      );
    }

    // Return random bonus info สำหรับแสดง dialog
    if (gotRandomBonus && randomBonus > 0) {
      return randomBonus;
    }
    return null;
  }

  /// Refresh state จาก server
  Future<void> refresh() async {
    await _loadState();
  }
}
