import '../models/gamification_state.dart';

/// Referral tier rewards (must match [quest_bar] / Cloud Function `REFERRAL_LEVELS`).
class ReferralClaimBundle {
  final int totalEnergy;
  final List<int> levelNumbers;

  const ReferralClaimBundle({
    required this.totalEnergy,
    required this.levelNumbers,
  });

  bool get isEmpty => totalEnergy <= 0 || levelNumbers.isEmpty;

  /// Levels the user has unlocked but not yet claimed this week.
  static ReferralClaimBundle fromGamification(GamificationState g) {
    const rows = <({int level, int target, int reward})>[
      (level: 1, target: 1, reward: 5),
      (level: 2, target: 2, reward: 5),
      (level: 3, target: 3, reward: 5),
      (level: 4, target: 4, reward: 5),
      (level: 5, target: 5, reward: 5),
      (level: 6, target: 6, reward: 5),
      (level: 7, target: 7, reward: 5),
      (level: 8, target: 8, reward: 5),
      (level: 9, target: 9, reward: 5),
      (level: 10, target: 10, reward: 25),
    ];

    final claimed = g.weeklyClaimedRewards;
    final n = g.referFriendsProgress;
    var total = 0;
    final levels = <int>[];

    for (final row in rows) {
      final key = 'referFriends_${row.level}';
      if (!claimed.contains(key) && n >= row.target) {
        levels.add(row.level);
        total += row.reward;
      }
    }

    return ReferralClaimBundle(totalEnergy: total, levelNumbers: levels);
  }
}
