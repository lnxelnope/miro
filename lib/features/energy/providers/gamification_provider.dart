import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_hybrid/core/models/gamification_state.dart';
import 'package:miro_hybrid/core/services/energy_service.dart';
import 'package:miro_hybrid/core/services/analytics_service.dart';
import 'package:miro_hybrid/core/services/rating_service.dart';
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

      // Challenge data
      final daily = result['challenges']?['daily'] ?? {};
      final weekly = result['challenges']?['weekly'] ?? {};
      final milestones = result['milestones'] ?? {};
      final referFriendsProgress = (weekly['referFriends'] as num?)?.toInt() ?? 0;

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

      // Parse tier celebrations
      final rawTierCelebration = result['tierCelebration'];
      debugPrint('[Gamification] tierCelebration raw: $rawTierCelebration (type: ${rawTierCelebration.runtimeType})');
      final tierCelebrations = _parseTierCelebrations(rawTierCelebration);
      debugPrint('[Gamification] tierCelebrations parsed: ${tierCelebrations.keys.toList()} (${tierCelebrations.length} entries)');

      // Parse seasonal quests
      final seasonalQuests = _parseSeasonalQuests(result['seasonalQuests']);
      debugPrint('[Gamification] seasonalQuests parsed: ${seasonalQuests.length} active quests');

      state = GamificationState(
        miroId: result['miroId']?.toString() ?? '',
        currentStreak: (result['currentStreak'] as num?)?.toInt() ?? 0,
        longestStreak: (result['longestStreak'] as num?)?.toInt() ?? 0,
        tier: result['tier']?.toString() ?? 'none',
        balance: (result['balance'] as num?)?.toInt() ?? 0,
        dailyAiCount: (daily['aiCount'] as num?)?.toInt() ?? 0,
        weeklyAiCount: (weekly['aiCount'] as num?)?.toInt() ?? 0,
        dailyClaimedRewards: List<String>.from(daily['claimedRewards'] ?? []),
        weeklyClaimedRewards: List<String>.from(weekly['claimedRewards'] ?? []),
        referFriendsProgress: referFriendsProgress,
        totalSpent: (result['totalSpent'] as num?)?.toInt() ?? 0,
        claimedMilestones: List<String>.from(milestones['claimedMilestones'] ?? []),
        nextMilestoneIndex: (milestones['nextMilestoneIndex'] as num?)?.toInt() ?? 0,
        bonusRate: (result['bonusRate'] as num?)?.toDouble() ?? 0.0,
        isSubscriber: isSubActive,
        subscriptionStatus: subStatus,
        subscriptionExpiryDate: subExpiryDate,
        tierCelebrations: tierCelebrations,
        seasonalQuests: seasonalQuests,
      );

      debugPrint('[Gamification] State set: miroId="${state.miroId}", '
          'balance=${state.balance}, tier=${state.tier}, '
          'dailyAi=${state.dailyAiCount}, weeklyAi=${state.weeklyAiCount}, '
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
        balance: balance,
        dailyAiCount: 0,
        weeklyAiCount: 0,
        dailyClaimedRewards: const [],
        weeklyClaimedRewards: const [],
        referFriendsProgress: 0,
        totalSpent: 0,
        claimedMilestones: const [],
        nextMilestoneIndex: 0,
        bonusRate: 0.0,
      );
    }
  }

  /// Update state จาก AI response
  /// Returns daily check-in info for welcome dialog (null if already checked in)
  Map<String, dynamic>? updateFromAiResponse(Map<String, dynamic> response) {
    final streak = response['streak'] as Map<String, dynamic>?;
    final newBalance = (response['balance'] as num?)?.toInt();
    
    // Challenge data
    final daily = response['challenges']?['daily'] ?? {};
    final weekly = response['challenges']?['weekly'] ?? {};
    final milestones = response['milestones'] ?? {};
    final totalSpent = (response['totalSpent'] as num?)?.toInt() ?? state.totalSpent;
    final referFriendsProgress = (weekly['referFriends'] as num?)?.toInt() ?? state.referFriendsProgress;

    // Subscription data from response (or from isSubscriber flag)
    final subscription = response['subscription'] as Map<String, dynamic>?;
    final isSubFromResponse = response['isSubscriber'] == true;

    // Tier celebrations
    final tierCelebrations = response['tierCelebration'] != null
        ? _parseTierCelebrations(response['tierCelebration'])
        : null;

    // Seasonal quests
    final seasonalQuests = response['seasonalQuests'] != null
        ? _parseSeasonalQuests(response['seasonalQuests'])
        : null;

    state = state.copyWith(
      currentStreak: (streak?['current'] as num?)?.toInt(),
      longestStreak: (streak?['longest'] as num?)?.toInt(),
      tier: streak?['tier']?.toString(),
      balance: newBalance,
      dailyAiCount: (daily['aiCount'] as num?)?.toInt() ?? state.dailyAiCount,
      weeklyAiCount: (weekly['aiCount'] as num?)?.toInt() ?? state.weeklyAiCount,
      dailyClaimedRewards: List<String>.from(daily['claimedRewards'] ?? state.dailyClaimedRewards),
      weeklyClaimedRewards: List<String>.from(weekly['claimedRewards'] ?? state.weeklyClaimedRewards),
      referFriendsProgress: referFriendsProgress,
      totalSpent: totalSpent,
      claimedMilestones: List<String>.from(milestones['claimedMilestones'] ?? state.claimedMilestones),
      nextMilestoneIndex: (milestones['nextMilestoneIndex'] as num?)?.toInt() ?? state.nextMilestoneIndex,
      isSubscriber: subscription != null
          ? (subscription['status'] == 'active' || subscription['status'] == 'grace_period')
          : (isSubFromResponse ? true : null),
      subscriptionStatus: subscription?['status']?.toString(),
      subscriptionExpiryDate: subscription?['expiryDate'] != null
          ? DateTime.tryParse(subscription!['expiryDate'].toString())
          : null,
      tierCelebrations: tierCelebrations,
      seasonalQuests: seasonalQuests,
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

  /// Update state จาก check-in response (V3: no random bonus)
  void updateFromCheckInResponse(Map<String, dynamic> response) {
    final streak = response['streak'] as Map<String, dynamic>?;
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

    AnalyticsService.logDailyCheckIn(
      streakDays: currentStreak,
      tier: tier,
      energyBonus: energyBonus,
    );

    // Check streak milestones for native review prompt
    RatingService.checkStreakMilestone(currentStreak);

    if (streak?['tierUpgraded'] == true) {
      AnalyticsService.logStreakMilestone(
        streakDays: currentStreak,
        newTier: tier,
      );
    }
  }

  /// Refresh state จาก server
  Future<void> refresh() async {
    await _loadState();
  }

  /// Parse tier celebration data from API response
  Map<String, TierCelebrationData> _parseTierCelebrations(dynamic data) {
    if (data == null || data is! Map) return {};
    
    final result = <String, TierCelebrationData>{};
    for (final entry in data.entries) {
      try {
        if (entry.value is Map<String, dynamic>) {
          result[entry.key] = TierCelebrationData.fromJson(
            entry.value as Map<String, dynamic>,
          );
        }
      } catch (e) {
        debugPrint('[Gamification] Error parsing tierCelebration.${entry.key}: $e');
      }
    }
    return result;
  }

  /// Parse seasonal quests from API response
  List<SeasonalQuestData> _parseSeasonalQuests(dynamic data) {
    if (data == null || data is! List) return [];

    final result = <SeasonalQuestData>[];
    for (final item in data) {
      try {
        if (item is Map<String, dynamic>) {
          result.add(SeasonalQuestData.fromJson(item));
        }
      } catch (e) {
        debugPrint('[Gamification] Error parsing seasonalQuest: $e');
      }
    }
    return result;
  }
}
