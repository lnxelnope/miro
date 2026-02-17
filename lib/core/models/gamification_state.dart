import 'package:flutter/material.dart';
import '../theme/app_icons.dart';
import '../theme/app_colors.dart';

class GamificationState {
  final String miroId;
  final int currentStreak;
  final int longestStreak;
  final String tier; // 'none', 'bronze', 'silver', 'gold', 'diamond'
  final bool freeAiAvailable;
  final int balance;
  
  // Phase 2: Challenges & Milestones
  final int logMealsProgress;
  final int useAiProgress;
  final List<String> claimedRewards;
  final int totalSpent;
  final bool spent500Claimed;
  final bool spent1000Claimed;
  final double bonusRate; // 0, 0.2, or 0.3
  
  // Phase 5: Subscription
  final bool isSubscriber;
  final String? subscriptionStatus; // 'active' | 'grace_period' | 'expired' | 'cancelled'
  final DateTime? subscriptionExpiryDate;

  const GamificationState({
    required this.miroId,
    required this.currentStreak,
    required this.longestStreak,
    required this.tier,
    required this.freeAiAvailable,
    required this.balance,
    this.logMealsProgress = 0,
    this.useAiProgress = 0,
    this.claimedRewards = const [],
    this.totalSpent = 0,
    this.spent500Claimed = false,
    this.spent1000Claimed = false,
    this.bonusRate = 0.0,
    this.isSubscriber = false,
    this.subscriptionStatus,
    this.subscriptionExpiryDate,
  });

  factory GamificationState.empty() {
    return const GamificationState(
      miroId: '',
      currentStreak: 0,
      longestStreak: 0,
      tier: 'none',
      freeAiAvailable: true,
      balance: 0,
      logMealsProgress: 0,
      useAiProgress: 0,
      claimedRewards: [],
      totalSpent: 0,
      spent500Claimed: false,
      spent1000Claimed: false,
      bonusRate: 0.0,
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

  /// Grace period
  int get graceDays {
    switch (tier) {
      case 'silver':
        return 1;
      case 'gold':
        return 2;
      case 'diamond':
        return 3;
      default:
        return 0;
    }
  }

  GamificationState copyWith({
    String? miroId,
    int? currentStreak,
    int? longestStreak,
    String? tier,
    bool? freeAiAvailable,
    int? balance,
    int? logMealsProgress,
    int? useAiProgress,
    List<String>? claimedRewards,
    int? totalSpent,
    bool? spent500Claimed,
    bool? spent1000Claimed,
    double? bonusRate,
  }) {
    return GamificationState(
      miroId: miroId ?? this.miroId,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      tier: tier ?? this.tier,
      freeAiAvailable: freeAiAvailable ?? this.freeAiAvailable,
      balance: balance ?? this.balance,
      logMealsProgress: logMealsProgress ?? this.logMealsProgress,
      useAiProgress: useAiProgress ?? this.useAiProgress,
      claimedRewards: claimedRewards ?? this.claimedRewards,
      totalSpent: totalSpent ?? this.totalSpent,
      spent500Claimed: spent500Claimed ?? this.spent500Claimed,
      spent1000Claimed: spent1000Claimed ?? this.spent1000Claimed,
      bonusRate: bonusRate ?? this.bonusRate,
      isSubscriber: isSubscriber ?? this.isSubscriber,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionExpiryDate: subscriptionExpiryDate ?? this.subscriptionExpiryDate,
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
