import 'app_database.dart';

/// DatabaseService — Drift migration wrapper
/// Provides Isar-like interface for backward compatibility
class DatabaseService {
  static late AppDatabase db;

  static Future<void> initialize() async {
    await AppDatabase.initialize();
    db = AppDatabase.instance;
  }

  // Direct database access
  static AppDatabase get database => db;

  // Convenience getters (similar to old Isar interface)
  static $FoodEntriesTable get foodEntries => db.foodEntries;
  static $IngredientsTable get ingredients => db.ingredients;
  static $MyMealsTable get myMeals => db.myMeals;
  static $MyMealIngredientsTable get myMealIngredients => db.myMealIngredients;
  static $ChatMessagesTable get chatMessages => db.chatMessages;
  static $ChatSessionsTable get chatSessions => db.chatSessions;
  static $UserProfilesTable get userProfiles => db.userProfiles;
  static $DailySummariesTable get dailySummaries => db.dailySummaries;
  static $EnergyTransactionsTable get energyTransactions =>
      db.energyTransactions;

  // Transaction wrappers (similar to Isar's writeTxn)
  static Future<T> writeTxn<T>(Future<T> Function() callback) async {
    return await db.transaction(() async {
      return await callback();
    });
  }

  static Future<T> readTxn<T>(Future<T> Function() callback) async {
    // Drift doesn't require read transactions, but for API compatibility
    return await callback();
  }
}
