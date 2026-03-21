import 'package:drift/drift.dart' show Value;

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

  /// Convenience helper for inserting a generic FoodEntry.
  static Future<FoodEntryData> insertFoodEntry(
    FoodEntriesCompanion entry,
  ) {
    return _db.into(_db.foodEntries).insertReturning(entry);
  }

  /// Insert a FoodEntry that originates from ARscan.
  ///
  /// - Ensures `source` is set to `DataSource.arScan` by default.
  /// - Leaves `imagePath` and any supplementary image paths to the caller.
  static Future<FoodEntryData> insertArScanEntry(
    FoodEntriesCompanion entry,
  ) {
    final effective = entry.copyWith(
      source: entry.source.present
          ? entry.source
          : const Value(DataSource.arScan),
    );

    return _db.into(_db.foodEntries).insertReturning(effective);
  }
}

