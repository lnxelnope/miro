import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_hybrid/core/models/gamification_state.dart';
import 'package:miro_hybrid/core/services/energy_service.dart';
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
      final result = await _energyService.registerOrSync();
      
      // Phase 2: Load challenge & milestone data
      final challenges = result['challenges']?['weekly'] ?? {};
      final milestones = result['milestones'] ?? {};
      
      state = GamificationState(
        miroId: result['miroId'] ?? '',
        currentStreak: result['currentStreak'] ?? 0,
        longestStreak: result['longestStreak'] ?? 0,
        tier: result['tier'] ?? 'none',
        freeAiAvailable: !(result['freeAiUsedToday'] ?? false),
        balance: result['balance'] ?? 0,
        logMealsProgress: challenges['logMeals'] ?? 0,
        useAiProgress: challenges['useAi'] ?? 0,
        claimedRewards: List<String>.from(challenges['claimedRewards'] ?? []),
        totalSpent: result['totalSpent'] ?? 0,
        spent500Claimed: milestones['spent500Claimed'] ?? false,
        spent1000Claimed: milestones['spent1000Claimed'] ?? false,
        bonusRate: result['bonusRate']?.toDouble() ?? 0.0,
        isSubscriber: result['subscription']?['status'] == 'active',
        subscriptionStatus: result['subscription']?['status'],
        subscriptionExpiryDate: result['subscription']?['expiryDate'] != null
            ? DateTime.parse(result['subscription']['expiryDate'])
            : null,
      );
    } catch (e) {
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
  void updateFromAiResponse(Map<String, dynamic> response) {
    final streak = response['streak'] as Map<String, dynamic>?;
    final wasFreeAi = response['wasFreeAi'] == true;
    final newBalance = response['balance'] as int?;
    
    // Phase 2: Update challenges & milestones
    final challenges = response['challenges']?['weekly'] ?? {};
    final milestones = response['milestones'] ?? {};
    final totalSpent = response['totalSpent'] as int? ?? state.totalSpent;

    state = state.copyWith(
      currentStreak: streak?['current'],
      longestStreak: streak?['longest'],
      tier: streak?['tier'],
      freeAiAvailable: !wasFreeAi, // ถ้าใช้ free AI แล้ว → ไม่มีอีก
      balance: newBalance,
      logMealsProgress: challenges['logMeals'] ?? state.logMealsProgress,
      useAiProgress: challenges['useAi'] ?? state.useAiProgress,
      claimedRewards: List<String>.from(challenges['claimedRewards'] ?? state.claimedRewards),
      totalSpent: totalSpent,
      spent500Claimed: milestones['spent500Claimed'] ?? state.spent500Claimed,
      spent1000Claimed: milestones['spent1000Claimed'] ?? state.spent1000Claimed,
    );
  }

  /// Update state จาก check-in response (Phase 2: random bonus)
  /// Returns random bonus amount if got bonus, otherwise null
  int? updateFromCheckInResponse(Map<String, dynamic> response) {
    final streak = response['streak'] as Map<String, dynamic>?;
    final randomBonus = response['randomBonus'] as int? ?? 0;
    final gotRandomBonus = response['gotRandomBonus'] == true;
    final newBalance = response['newBalance'] as int?;

    state = state.copyWith(
      currentStreak: streak?['current'],
      longestStreak: streak?['longest'],
      tier: streak?['tier'],
      balance: newBalance,
    );

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
