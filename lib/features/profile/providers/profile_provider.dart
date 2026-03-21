import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide JsonKey, Column;
import '../../../core/database/app_database.dart';
import '../../../core/database/database_service.dart';
import '../../../core/database/model_extensions.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/secure_storage_service.dart';

final userProfileProvider = FutureProvider<UserProfile>((ref) async {
  final profiles = await (DatabaseService.db.select(DatabaseService.db.userProfiles)
        ..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)]))
      .get();

  if (profiles.isEmpty) {
    final profile = await DatabaseService.db
        .into(DatabaseService.db.userProfiles)
        .insertReturning(UserProfilesCompanion.insert(
          name: const Value('User'),
          calorieGoal: const Value(AppConstants.defaultCalorieGoal),
          proteinGoal: const Value(AppConstants.defaultProteinGoal),
          carbGoal: const Value(AppConstants.defaultCarbGoal),
          fatGoal: const Value(AppConstants.defaultFatGoal),
          waterGoal: const Value(AppConstants.defaultWaterGoal),
        ));
    return profile;
  }

  return profiles.first;
});

final hasApiKeyProvider = FutureProvider<bool>((ref) async {
  return await SecureStorageService.hasGeminiApiKey();
});

class ProfileNotifier extends StateNotifier<AsyncValue<UserProfile>> {
  ProfileNotifier() : super(const AsyncValue.loading()) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final profiles = await (DatabaseService.db.select(DatabaseService.db.userProfiles)
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)]))
          .get();

      if (profiles.isEmpty) {
        final profile = await DatabaseService.db
            .into(DatabaseService.db.userProfiles)
            .insertReturning(UserProfilesCompanion.insert(
              name: const Value('User'),
              calorieGoal: const Value(AppConstants.defaultCalorieGoal),
              proteinGoal: const Value(AppConstants.defaultProteinGoal),
              carbGoal: const Value(AppConstants.defaultCarbGoal),
              fatGoal: const Value(AppConstants.defaultFatGoal),
              waterGoal: const Value(AppConstants.defaultWaterGoal),
            ));
        state = AsyncValue.data(profile);
      } else {
        state = AsyncValue.data(profiles.first);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    profile.updatedAt = DateTime.now();
    await DatabaseService.db
        .into(DatabaseService.db.userProfiles)
        .insertOnConflictUpdate(profile);
    state = AsyncValue.data(profile);
  }

  Future<void> updateHealthGoals({
    double? calorieGoal,
    double? tdee,
    double? customBmr,
    double? proteinGoal,
    double? carbGoal,
    double? fatGoal,
    double? waterGoal,
    double? breakfastBudget,
    double? lunchBudget,
    double? dinnerBudget,
    double? snackBudget,
    double? suggestionThreshold,
    bool? mealSuggestionsEnabled,
  }) async {
    final currentProfile = state.value;
    if (currentProfile == null) return;

    if (calorieGoal != null) currentProfile.calorieGoal = calorieGoal;
    if (tdee != null) currentProfile.tdee = tdee;
    if (customBmr != null) currentProfile.customBmr = customBmr;
    if (proteinGoal != null) currentProfile.proteinGoal = proteinGoal;
    if (carbGoal != null) currentProfile.carbGoal = carbGoal;
    if (fatGoal != null) currentProfile.fatGoal = fatGoal;
    if (waterGoal != null) currentProfile.waterGoal = waterGoal;
    if (breakfastBudget != null) currentProfile.breakfastBudget = breakfastBudget;
    if (lunchBudget != null) currentProfile.lunchBudget = lunchBudget;
    if (dinnerBudget != null) currentProfile.dinnerBudget = dinnerBudget;
    if (snackBudget != null) currentProfile.snackBudget = snackBudget;
    if (suggestionThreshold != null) currentProfile.suggestionThreshold = suggestionThreshold;
    if (mealSuggestionsEnabled != null) currentProfile.mealSuggestionsEnabled = mealSuggestionsEnabled;

    await updateProfile(currentProfile);
  }
}

final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<UserProfile>>((ref) {
  return ProfileNotifier();
});
