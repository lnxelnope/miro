class AppConstants {
  // App Info
  static const String appName = 'Miro';
  static const String appVersion = '1.0.0';

  // Default Goals
  static const double defaultCalorieGoal = 2000;
  static const double defaultProteinGoal = 120;
  static const double defaultCarbGoal = 250;
  static const double defaultFatGoal = 65;
  static const double defaultWaterGoal = 2500; // ml

  // API Endpoints
  static const String thaiGoldApiUrl =
      'https://api.chnwt.dev/thai-gold-api/latest';
  static const String secApiUrl = 'https://api.sec.or.th';

  // Local Storage Keys
  static const String apiKeyStorageKey = 'gemini_api_key';
  static const String userProfileKey = 'user_profile';
  static const String calorieGoalKey = 'calorie_goal';
  static const String proteinGoalKey = 'protein_goal';
  static const String carbGoalKey = 'carb_goal';
  static const String fatGoalKey = 'fat_goal';
}
