/// Product feature toggles (ship when ready).
class FeatureFlags {
  FeatureFlags._();

  /// Streak / quest bar / daily welcome dialog / claim-energy chat tips.
  /// Set `true` when streak + quest UI is live for users.
  static const bool enableStreakQuestPromotions = false;
}
