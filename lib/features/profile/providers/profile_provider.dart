import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/database/database_service.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/constants/app_constants.dart';
import '../models/user_profile.dart';

// User Profile Provider
final userProfileProvider = FutureProvider<UserProfile>((ref) async {
  final profiles = await DatabaseService.userProfiles
      .filter()
      .idGreaterThan(0)
      .sortByCreatedAt()
      .findAll();

  if (profiles.isEmpty) {
    // สร้าง default profile
    final profile = UserProfile()
      ..name = 'User'
      ..calorieGoal = AppConstants.defaultCalorieGoal
      ..proteinGoal = AppConstants.defaultProteinGoal
      ..carbGoal = AppConstants.defaultCarbGoal
      ..fatGoal = AppConstants.defaultFatGoal
      ..waterGoal = AppConstants.defaultWaterGoal;

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.userProfiles.put(profile);
    });

    return profile;
  }

  return profiles.first;
});

// Has API Key Provider
final hasApiKeyProvider = FutureProvider<bool>((ref) async {
  return await SecureStorageService.hasGeminiApiKey();
});

// Update Profile Notifier
class ProfileNotifier extends StateNotifier<AsyncValue<UserProfile>> {
  ProfileNotifier() : super(const AsyncValue.loading()) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final profiles = await DatabaseService.userProfiles
          .filter()
          .idGreaterThan(0)
          .sortByCreatedAt()
          .findAll();

      if (profiles.isEmpty) {
        final profile = UserProfile()
          ..name = 'User'
          ..calorieGoal = AppConstants.defaultCalorieGoal
          ..proteinGoal = AppConstants.defaultProteinGoal
          ..carbGoal = AppConstants.defaultCarbGoal
          ..fatGoal = AppConstants.defaultFatGoal
          ..waterGoal = AppConstants.defaultWaterGoal;

        await DatabaseService.isar.writeTxn(() async {
          await DatabaseService.userProfiles.put(profile);
        });

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
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.userProfiles.put(profile);
    });
    state = AsyncValue.data(profile);
  }

  Future<void> updateHealthGoals({
    double? calorieGoal,
    double? proteinGoal,
    double? carbGoal,
    double? fatGoal,
    double? waterGoal,
    double? breakfastBudget,
    double? lunchBudget,
    double? dinnerBudget,
    double? snackBudget,
    double? suggestionThreshold,
  }) async {
    final currentProfile = state.value;
    if (currentProfile == null) return;

    if (calorieGoal != null) currentProfile.calorieGoal = calorieGoal;
    if (proteinGoal != null) currentProfile.proteinGoal = proteinGoal;
    if (carbGoal != null) currentProfile.carbGoal = carbGoal;
    if (fatGoal != null) currentProfile.fatGoal = fatGoal;
    if (waterGoal != null) currentProfile.waterGoal = waterGoal;
    if (breakfastBudget != null) currentProfile.breakfastBudget = breakfastBudget;
    if (lunchBudget != null) currentProfile.lunchBudget = lunchBudget;
    if (dinnerBudget != null) currentProfile.dinnerBudget = dinnerBudget;
    if (snackBudget != null) currentProfile.snackBudget = snackBudget;
    if (suggestionThreshold != null) currentProfile.suggestionThreshold = suggestionThreshold;

    await updateProfile(currentProfile);
  }
}

final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<UserProfile>>((ref) {
  return ProfileNotifier();
});
