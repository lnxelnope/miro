import 'package:flutter/material.dart';
import '../theme/app_icons.dart';
import '../theme/app_colors.dart';
import 'dart:math';

/// Tier Celebration data for a specific tier
class TierCelebrationData {
  final String startDate; // "YYYY-MM-DD"
  final List<int> claimedDays; // [1, 2, 5]

  const TierCelebrationData({
    required this.startDate,
    required this.claimedDays,
  });

  /// Current day number (1-7, or 0 if not started, 8+ if expired)
  int get currentDay {
    try {
      final start = DateTime.parse(startDate);
      final now = DateTime.now();
      final diff = now.difference(start).inDays;
      return diff + 1; // Day 1 = same day as start
    } catch (e) {
      return 0;
    }
  }

  /// Is celebration active (within 7-day window)
  bool get isActive => currentDay >= 1 && currentDay <= 7;

  /// Can claim today's reward
  bool get canClaimToday => isActive && !claimedDays.contains(currentDay);

  /// Total days claimed
  int get totalClaimed => claimedDays.length;

  /// Days remaining in window
  int get daysRemaining => max(0, 7 - currentDay + 1);

  /// Is celebration complete (all 7 days claimed or window expired)
  bool get isComplete => totalClaimed >= 7 || currentDay > 7;

  factory TierCelebrationData.fromJson(Map<String, dynamic> json) {
    return TierCelebrationData(
      startDate: json['startDate'] as String? ?? '',
      claimedDays: (json['claimedDays'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate,
      'claimedDays': claimedDays,
    };
  }
}

/// Seasonal Quest data from server
class SeasonalQuestData {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String startDate;   // "YYYY-MM-DD"
  final String endDate;     // "YYYY-MM-DD"
  final int durationDays;
  final String claimType;   // "daily" | "one_time"
  final int rewardPerClaim;

  // User progress
  final List<String> claimedDays;  // for daily: ["2026-12-25", ...]
  final bool claimed;              // for one_time

  const SeasonalQuestData({
    required this.id,
    required this.title,
    this.description = '',
    this.icon = '🎁',
    required this.startDate,
    required this.endDate,
    this.durationDays = 0,
    required this.claimType,
    required this.rewardPerClaim,
    this.claimedDays = const [],
    this.claimed = false,
  });

  /// Is quest currently active (today within date range)
  bool get isActive {
    try {
      final now = DateTime.now();
      final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      return todayStr.compareTo(startDate) >= 0 && todayStr.compareTo(endDate) <= 0;
    } catch (e) {
      return false;
    }
  }

  /// Can claim today
  bool get canClaimToday {
    if (!isActive) return false;
    if (claimType == 'one_time') return !claimed;
    // daily: check if today's date is in claimedDays
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return !claimedDays.contains(todayStr);
  }

  /// Days remaining until end date
  int get daysRemaining {
    try {
      final end = DateTime.parse(endDate);
      final now = DateTime.now();
      final diff = end.difference(DateTime(now.year, now.month, now.day)).inDays;
      return diff >= 0 ? diff + 1 : 0;
    } catch (e) {
      return 0;
    }
  }

  /// Is quest completed (one_time: claimed, daily: expired)
  bool get isComplete {
    if (claimType == 'one_time') return claimed;
    return !isActive && daysRemaining == 0;
  }

  /// Total days claimed
  int get totalClaimed => claimedDays.length;

  factory SeasonalQuestData.fromJson(Map<String, dynamic> json) {
    return SeasonalQuestData(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? '🎁',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      durationDays: (json['durationDays'] as num?)?.toInt() ?? 0,
      claimType: json['claimType'] as String? ?? 'daily',
      rewardPerClaim: (json['rewardPerClaim'] as num?)?.toInt() ?? 0,
      claimedDays: (json['claimedDays'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      claimed: json['claimed'] as bool? ?? false,
    );
  }
}

class GamificationState {
  final String miroId;
  final int currentStreak;
  final int longestStreak;
  final String tier; // 'none', 'bronze', 'silver', 'gold', 'diamond'
  final int balance;
  
  // Challenges
  final int dailyAiCount; // Daily AI usage count
  final int weeklyAiCount; // Weekly AI usage count
  final List<String> dailyClaimedRewards; // Daily claimed reward keys
  final List<String> weeklyClaimedRewards; // Weekly claimed reward keys
  final int referFriendsProgress; // Referral count this week
  
  // Milestones
  final int totalSpent;
  final List<String> claimedMilestones;
  final int nextMilestoneIndex;
  final double bonusRate;
  
  // Phase 5: Subscription
  final bool isSubscriber;
  final String? subscriptionStatus; // 'active' | 'grace_period' | 'expired' | 'cancelled'
  final DateTime? subscriptionExpiryDate;

  // Tier Celebration (lifetime quests per tier)
  final Map<String, TierCelebrationData> tierCelebrations;

  // Seasonal Quests (limited-time events)
  final List<SeasonalQuestData> seasonalQuests;

  const GamificationState({
    required this.miroId,
    required this.currentStreak,
    required this.longestStreak,
    required this.tier,
    required this.balance,
    this.dailyAiCount = 0,
    this.weeklyAiCount = 0,
    this.dailyClaimedRewards = const [],
    this.weeklyClaimedRewards = const [],
    this.referFriendsProgress = 0,
    this.totalSpent = 0,
    this.claimedMilestones = const [],
    this.nextMilestoneIndex = 0,
    this.bonusRate = 0.0,
    this.isSubscriber = false,
    this.subscriptionStatus,
    this.subscriptionExpiryDate,
    this.tierCelebrations = const {},
    this.seasonalQuests = const [],
  });

  factory GamificationState.empty() {
    return const GamificationState(
      miroId: '',
      currentStreak: 0,
      longestStreak: 0,
      tier: 'none',
      balance: 0,
      dailyAiCount: 0,
      weeklyAiCount: 0,
      dailyClaimedRewards: [],
      weeklyClaimedRewards: [],
      referFriendsProgress: 0,
      totalSpent: 0,
      claimedMilestones: const [],
      nextMilestoneIndex: 0,
      bonusRate: 0.0,
      tierCelebrations: {},
      seasonalQuests: const [],
    );
  }

  /// Tier icon (replaces tierEmoji)
  IconData get tierIcon {
    switch (tier) {
      case 'bronze':
        return AppIcons.tierBronze;
      case 'silver':
        return AppIcons.tierSilver;
      case 'gold':
        return AppIcons.tierGold;
      case 'diamond':
        return AppIcons.tierDiamond;
      default:
        return AppIcons.tierStarter;
    }
  }
  
  /// Tier color
  Color get tierColor {
    switch (tier) {
      case 'bronze':
        return AppColors.tierBronze;
      case 'silver':
        return AppColors.tierSilver;
      case 'gold':
        return AppColors.tierGold;
      case 'diamond':
        return AppColors.tierDiamond;
      default:
        return AppIcons.tierStarterColor;
    }
  }
  
  /// Keep old getter for backward compatibility (deprecated)
  @Deprecated('Use tierIcon instead')
  String get tierEmoji {
    switch (tier) {
      case 'bronze':
        return '🥉';
      case 'silver':
        return '🥈';
      case 'gold':
        return '🥇';
      case 'diamond':
        return '💎';
      default:
        return '⭐';
    }
  }

  String get tierName {
    switch (tier) {
      case 'bronze':
        return 'Bronze';
      case 'silver':
        return 'Silver';
      case 'gold':
        return 'Gold';
      case 'diamond':
        return 'Diamond';
      default:
        return 'Starter';
    }
  }

  /// Days until next tier
  int get daysToNextTier {
    switch (tier) {
      case 'none':
        return 7 - currentStreak;
      case 'bronze':
        return 14 - currentStreak;
      case 'silver':
        return 30 - currentStreak;
      case 'gold':
        return 60 - currentStreak;
      default:
        return 0; // Diamond = max tier
    }
  }

  /// Grace period (Silver/Gold/Diamond = 1 day, Starter/Bronze = 0)
  int get graceDays {
    switch (tier) {
      case 'silver':
      case 'gold':
      case 'diamond':
        return 1;
      default:
        return 0;
    }
  }

  GamificationState copyWith({
    String? miroId,
    int? currentStreak,
    int? longestStreak,
    String? tier,
    int? balance,
    int? dailyAiCount,
    int? weeklyAiCount,
    List<String>? dailyClaimedRewards,
    List<String>? weeklyClaimedRewards,
    int? referFriendsProgress,
    int? totalSpent,
    List<String>? claimedMilestones,
    int? nextMilestoneIndex,
    double? bonusRate,
    bool? isSubscriber,
    String? subscriptionStatus,
    DateTime? subscriptionExpiryDate,
    Map<String, TierCelebrationData>? tierCelebrations,
    List<SeasonalQuestData>? seasonalQuests,
  }) {
    return GamificationState(
      miroId: miroId ?? this.miroId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      tier: tier ?? this.tier,
      balance: balance ?? this.balance,
      dailyAiCount: dailyAiCount ?? this.dailyAiCount,
      weeklyAiCount: weeklyAiCount ?? this.weeklyAiCount,
      dailyClaimedRewards: dailyClaimedRewards ?? this.dailyClaimedRewards,
      weeklyClaimedRewards: weeklyClaimedRewards ?? this.weeklyClaimedRewards,
      referFriendsProgress: referFriendsProgress ?? this.referFriendsProgress,
      totalSpent: totalSpent ?? this.totalSpent,
      claimedMilestones: claimedMilestones ?? this.claimedMilestones,
      nextMilestoneIndex: nextMilestoneIndex ?? this.nextMilestoneIndex,
      bonusRate: bonusRate ?? this.bonusRate,
      isSubscriber: isSubscriber ?? this.isSubscriber,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionExpiryDate: subscriptionExpiryDate ?? this.subscriptionExpiryDate,
      tierCelebrations: tierCelebrations ?? this.tierCelebrations,
      seasonalQuests: seasonalQuests ?? this.seasonalQuests,
    );
  }
  
  /// Subscription badge icon (replaces subscriptionBadge)
  IconData? get subscriptionIcon {
    if (isSubscriber && subscriptionStatus == 'active') {
      return AppIcons.subscription;
    }
    return null;
  }
  
  /// Subscription badge color
  Color? get subscriptionColor {
    if (isSubscriber && subscriptionStatus == 'active') {
      return AppIcons.subscriptionColor;
    }
    return null;
  }
  
  /// Keep old getter for backward compatibility (deprecated)
  @Deprecated('Use subscriptionIcon instead')
  String get subscriptionBadge {
    if (isSubscriber && subscriptionStatus == 'active') {
      return '💎';
    }
    return '';
  }
}
