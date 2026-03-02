import 'app_database.dart';

class DatabaseService {
  static late AppDatabase _db;

  static Future<void> initialize() async {
    await AppDatabase.initialize();
    _db = AppDatabase.instance;
  }

  // Database instance
  static AppDatabase get db => _db;

  // Table accessors
  static $FoodEntriesTable get foodEntries => _db.foodEntries;
  static $IngredientsTable get ingredients => _db.ingredients;
  static $MyMealsTable get myMeals => _db.myMeals;
  static $MyMealIngredientsTable get myMealIngredients => _db.myMealIngredients;
  static $ChatMessagesTable get chatMessages => _db.chatMessages;
  static $ChatSessionsTable get chatSessions => _db.chatSessions;
  static $UserProfilesTable get userProfiles => _db.userProfiles;
  static $DailySummariesTable get dailySummaries => _db.dailySummaries;
  static $EnergyTransactionsTable get energyTransactions =>
      _db.energyTransactions;

  // Transaction wrapper (for backward compatibility)
  static Future<T> writeTxn<T>(Future<T> Function() callback) async {
    return await _db.transaction(() async {
      return await callback();
    });
  }
}

