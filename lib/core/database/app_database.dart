import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// ============================================
// Enums (single source of truth — used by Drift intEnum)
//
// ⚠️ WARNING: intEnum stores the positional INDEX (0,1,2...) in SQLite.
// NEVER reorder, insert-in-middle, or remove existing values.
// Always APPEND new values at the end.
// ============================================
enum MealType {
  breakfast, // 0
  lunch, // 1
  dinner, // 2
  snack, // 3
}

enum DataSource {
  manual, // 0
  aiAnalyzed, // 1
  database, // 2
  slipScan, // 3
  healthConnect, // 4
  googleCalendar, // 5
  barcode, // 6
  galleryScanned, // 7
}

enum FoodSearchMode {
  normal, // 0
  product, // 1
}

enum MessageRole {
  user, // 0
  assistant, // 1
}

// ============================================
// Tables
// ============================================

@DataClassName('FoodEntryData')
@TableIndex(name: 'idx_food_timestamp', columns: {#timestamp})
@TableIndex(name: 'idx_food_deleted', columns: {#isDeleted})
@TableIndex(name: 'idx_food_synced', columns: {#isSynced, #isDeleted})
@TableIndex(name: 'idx_food_meal_type', columns: {#mealType, #timestamp})
class FoodEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Basic info
  TextColumn get foodName => text()();
  TextColumn get foodNameEn => text().nullable()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get imagePath => text().nullable()();

  // Meal type
  IntColumn get mealType => intEnum<MealType>()();

  // Serving size
  RealColumn get servingSize => real()();
  TextColumn get servingUnit => text()();
  RealColumn get servingGrams => real().nullable()();

  // Nutrition (calculated = base * servingSize)
  RealColumn get calories => real()();
  RealColumn get protein => real()();
  RealColumn get carbs => real()();
  RealColumn get fat => real()();

  // BASE Nutrition (per 1 servingUnit)
  RealColumn get baseCalories => real().withDefault(const Constant(0))();
  RealColumn get baseProtein => real().withDefault(const Constant(0))();
  RealColumn get baseCarbs => real().withDefault(const Constant(0))();
  RealColumn get baseFat => real().withDefault(const Constant(0))();

  // Micros
  RealColumn get fiber => real().nullable()();
  RealColumn get sugar => real().nullable()();
  RealColumn get sodium => real().nullable()();
  RealColumn get cholesterol => real().nullable()();
  RealColumn get saturatedFat => real().nullable()();
  RealColumn get transFat => real().nullable()();
  RealColumn get unsaturatedFat => real().nullable()();
  RealColumn get monounsaturatedFat => real().nullable()();
  RealColumn get polyunsaturatedFat => real().nullable()();
  RealColumn get potassium => real().nullable()();

  // Metadata
  IntColumn get source => intEnum<DataSource>()();
  IntColumn get searchMode =>
      intEnum<FoodSearchMode>().withDefault(const Constant(0))();
  RealColumn get aiConfidence => real().nullable()();
  BoolColumn get isVerified => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();

  // Links
  IntColumn get myMealId => integer().nullable()();
  IntColumn get ingredientId => integer().nullable()();
  TextColumn get groupId => text().nullable()();
  TextColumn get groupSource => text().nullable()();
  IntColumn get groupOrder => integer().nullable()();
  BoolColumn get isGroupOriginal =>
      boolean().withDefault(const Constant(false))();
  TextColumn get ingredientsJson => text().nullable()();

  // User Input & Correction Tracking
  TextColumn get userInputText => text().nullable()();
  TextColumn get originalFoodName => text().nullable()();
  TextColumn get originalFoodNameEn => text().nullable()();
  RealColumn get originalCalories => real().nullable()();
  RealColumn get originalProtein => real().nullable()();
  RealColumn get originalCarbs => real().nullable()();
  RealColumn get originalFat => real().nullable()();
  TextColumn get originalIngredientsJson => text().nullable()();
  IntColumn get editCount => integer().withDefault(const Constant(0))();
  BoolColumn get isUserCorrected =>
      boolean().withDefault(const Constant(false))();

  // Brand / Product Data
  TextColumn get brandName => text().nullable()();
  TextColumn get brandNameEn => text().nullable()();
  TextColumn get productName => text().nullable()();
  TextColumn get productBarcode => text().nullable()();
  RealColumn get netWeight => real().nullable()();
  TextColumn get netWeightUnit => text().nullable()();
  TextColumn get chainName => text().nullable()();
  TextColumn get productCategory => text().nullable()();
  TextColumn get packageSize => text().nullable()();
  TextColumn get nutritionSource => text().nullable()();

  // Scene Context
  TextColumn get sceneContext => text().nullable()();
  TextColumn get detectedObjectsJson => text().nullable()();

  // AR Calibration
  TextColumn get arBoundingBox => text().nullable()();
  RealColumn get estimatedWidthCm => real().nullable()();
  RealColumn get estimatedHeightCm => real().nullable()();
  RealColumn get estimatedDepthCm => real().nullable()();
  TextColumn get referenceObjectUsed => text().nullable()();
  RealColumn get referenceConfidence => real().nullable()();
  RealColumn get plateDiameterCm => real().nullable()();
  RealColumn get estimatedVolumeMl => real().nullable()();
  BoolColumn get isCalibrated =>
      boolean().withDefault(const Constant(false))();
  TextColumn get arLabelsJson => text().nullable()();
  RealColumn get arImageWidth => real().nullable()();
  RealColumn get arImageHeight => real().nullable()();
  RealColumn get arPixelPerCm => real().nullable()();

  // Health Connect Sync
  TextColumn get healthConnectId => text().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  // Sync & Cloud
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get firebaseDocId => text().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  TextColumn get thumbnailUrl => text().nullable()();
  TextColumn get thumbnailFirebasePath => text().nullable()();

  // Micronutrient details
  RealColumn get vitaminA => real().nullable()();
  RealColumn get vitaminC => real().nullable()();
  RealColumn get vitaminD => real().nullable()();
  RealColumn get vitaminE => real().nullable()();
  RealColumn get vitaminK => real().nullable()();
  RealColumn get thiamin => real().nullable()();
  RealColumn get riboflavin => real().nullable()();
  RealColumn get niacin => real().nullable()();
  RealColumn get vitaminB6 => real().nullable()();
  RealColumn get folate => real().nullable()();
  RealColumn get vitaminB12 => real().nullable()();
  RealColumn get calcium => real().nullable()();
  RealColumn get iron => real().nullable()();
  RealColumn get magnesium => real().nullable()();
  RealColumn get phosphorus => real().nullable()();
  RealColumn get zinc => real().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('IngredientData')
@TableIndex(name: 'idx_ingredient_name', columns: {#name})
class Ingredients extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();
  TextColumn get nameEn => text().nullable()();

  RealColumn get baseAmount => real()();
  TextColumn get baseUnit => text()();

  RealColumn get caloriesPerBase => real()();
  RealColumn get proteinPerBase => real()();
  RealColumn get carbsPerBase => real()();
  RealColumn get fatPerBase => real()();

  RealColumn get fiberPerBase => real().nullable()();
  RealColumn get sugarPerBase => real().nullable()();
  RealColumn get sodiumPerBase => real().nullable()();

  TextColumn get source => text()();
  IntColumn get usageCount => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('MyMealData')
class MyMeals extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();
  TextColumn get nameEn => text().nullable()();

  RealColumn get totalCalories => real()();
  RealColumn get totalProtein => real()();
  RealColumn get totalCarbs => real()();
  RealColumn get totalFat => real()();

  TextColumn get baseServingDescription => text()();
  TextColumn get imagePath => text().nullable()();
  TextColumn get source => text()();
  IntColumn get usageCount => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('MyMealIngredientData')
@TableIndex(name: 'idx_mmi_meal', columns: {#myMealId})
class MyMealIngredients extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get myMealId => integer()();
  IntColumn get ingredientId => integer()();
  TextColumn get ingredientName => text()();

  RealColumn get amount => real()();
  TextColumn get unit => text()();

  RealColumn get calories => real()();
  RealColumn get protein => real()();
  RealColumn get carbs => real()();
  RealColumn get fat => real()();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  // Nested/Sub-division fields
  IntColumn get parentId => integer().nullable()();
  IntColumn get depth => integer().withDefault(const Constant(0))();
  BoolColumn get isComposite => boolean().withDefault(const Constant(false))();
  TextColumn get detail => text().nullable()();
}

@DataClassName('DailySummaryData')
class DailySummaries extends Table {
  IntColumn get id => integer().autoIncrement()();

  DateTimeColumn get date => dateTime().unique()();

  RealColumn get caloriesEaten => real().withDefault(const Constant(0))();
  RealColumn get proteinEaten => real().withDefault(const Constant(0))();
  RealColumn get carbsEaten => real().withDefault(const Constant(0))();
  RealColumn get fatEaten => real().withDefault(const Constant(0))();

  RealColumn get tdee => real().withDefault(const Constant(0))();
  RealColumn get netEnergy => real().withDefault(const Constant(0))();

  TextColumn get deficitZone =>
      text().withDefault(const Constant('maintain'))();

  IntColumn get entryCount => integer().withDefault(const Constant(0))();
  IntColumn get correctionCount => integer().withDefault(const Constant(0))();
  RealColumn get calorieGoal => real().withDefault(const Constant(0))();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('ChatMessageData')
@TableIndex(name: 'idx_chat_session', columns: {#sessionId})
class ChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get sessionId => text()();
  IntColumn get role => intEnum<MessageRole>()();
  TextColumn get content => text()();

  // Rich content
  TextColumn get responseType => text().nullable()();
  TextColumn get cardDataJson => text().nullable()();
  TextColumn get actionsJson => text().nullable()();

  // Metadata
  TextColumn get detectedIntent => text().nullable()();
  RealColumn get confidence => real().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('ChatSessionData')
class ChatSessions extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text()();
  TextColumn get sessionId => text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('UserProfileData')
class UserProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().nullable()();
  TextColumn get avatarPath => text().nullable()();

  // Health Goals
  RealColumn get calorieGoal => real().withDefault(const Constant(2000))();
  RealColumn get proteinGoal => real().withDefault(const Constant(120))();
  RealColumn get carbGoal => real().withDefault(const Constant(250))();
  RealColumn get fatGoal => real().withDefault(const Constant(65))();
  RealColumn get waterGoal => real().withDefault(const Constant(2500))();

  // Meal Calorie Budgets
  RealColumn get breakfastBudget => real().withDefault(const Constant(560))();
  RealColumn get lunchBudget => real().withDefault(const Constant(700))();
  RealColumn get dinnerBudget => real().withDefault(const Constant(600))();
  RealColumn get snackBudget => real().withDefault(const Constant(140))();

  RealColumn get suggestionThreshold =>
      real().withDefault(const Constant(100))();
  BoolColumn get mealSuggestionsEnabled =>
      boolean().withDefault(const Constant(false))();

  // Settings
  BoolColumn get isDarkMode => boolean().withDefault(const Constant(false))();
  TextColumn get locale => text().nullable()();
  TextColumn get cuisinePreference =>
      text().withDefault(const Constant('international'))();

  // API Keys
  BoolColumn get hasGeminiApiKey =>
      boolean().withDefault(const Constant(false))();

  // Connections
  BoolColumn get isGoogleCalendarConnected =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isHealthConnectConnected =>
      boolean().withDefault(const Constant(false))();

  // Health Sync
  RealColumn get customBmr => real().withDefault(const Constant(1500))();
  RealColumn get tdee => real().withDefault(const Constant(0))();

  // Onboarding Fields
  TextColumn get gender => text().nullable()();
  IntColumn get age => integer().nullable()();
  RealColumn get weight => real().nullable()();
  RealColumn get height => real().nullable()();
  RealColumn get targetWeight => real().nullable()();
  TextColumn get activityLevel => text().nullable()();
  BoolColumn get onboardingComplete =>
      boolean().withDefault(const Constant(false))();

  // Consent & Data Sharing
  BoolColumn get foodResearchConsent =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get foodResearchConsentAt => dateTime().nullable()();

  TextColumn get platform => text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('EnergyTransactionData')
class EnergyTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get type => text()();
  IntColumn get amount => integer()();
  IntColumn get balanceAfter => integer()();

  TextColumn get packageId => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get purchaseToken => text().nullable()();
  TextColumn get deviceId => text().nullable()();

  DateTimeColumn get timestamp =>
      dateTime().withDefault(currentDateAndTime)();
}

// ============================================
// Database
// ============================================

@DriftDatabase(tables: [
  FoodEntries,
  Ingredients,
  MyMeals,
  MyMealIngredients,
  DailySummaries,
  ChatMessages,
  ChatSessions,
  UserProfiles,
  EnergyTransactions,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Future migrations go here.
          // Example for schemaVersion 2:
          // if (from < 2) {
          //   await m.addColumn(foodEntries, foodEntries.newColumn);
          // }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          await customStatement('PRAGMA journal_mode = WAL');
        },
      );

  // Singleton pattern
  static AppDatabase? _instance;
  static AppDatabase get instance {
    _instance ??= AppDatabase();
    return _instance!;
  }

  static Future<void> initialize() async {
    _instance = AppDatabase();
  }

  // Database connection
  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'miro_db.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
