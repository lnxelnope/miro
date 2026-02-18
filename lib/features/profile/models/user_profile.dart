import 'package:isar/isar.dart';

part 'user_profile.g.dart';

@collection
class UserProfile {
  Id id = Isar.autoIncrement;

  String? name;
  String? avatarPath;

  // Health Goals
  double calorieGoal = 2000;
  double proteinGoal = 120;
  double carbGoal = 250;
  double fatGoal = 65;
  double waterGoal = 2500; // ml (legacy, kept for backward compat)

  // Meal Calorie Budgets (kcal per meal)
  double breakfastBudget = 560; // ~28%
  double lunchBudget = 700; // ~35%
  double dinnerBudget = 600; // ~30%
  double snackBudget = 140; // ~7%

  // Suggestion threshold: allow foods ± this many kcal from meal budget
  double suggestionThreshold = 100;

  // Settings
  bool isDarkMode = false;
  String? locale; // th, en (kept for backward compatibility, not used)
  String cuisinePreference = 'international'; // NEW: user's typical cuisine

  // API Keys (encrypted)
  bool hasGeminiApiKey = false;

  // Connections
  bool isGoogleCalendarConnected = false;
  bool isHealthConnectConnected = false;

  // ===== Onboarding Fields =====
  String? gender; // 'male' หรือ 'female'
  int? age;
  double? weight; // kg
  double? height; // cm
  double? targetWeight; // kg (optional)
  String?
      activityLevel; // 'sedentary', 'light', 'moderate', 'active', 'very_active'
  bool onboardingComplete = false;
  // ===== จบส่วนเพิ่ม =====

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
