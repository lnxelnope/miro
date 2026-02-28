import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

// Health Models (Food only for v1.0)
import '../../features/health/models/food_entry.dart';
import '../../features/health/models/ingredient.dart';
import '../../features/health/models/my_meal.dart';
import '../../features/health/models/my_meal_ingredient.dart';

// Chat Models
import '../../features/chat/models/chat_message.dart';

// Profile Models
import '../../features/profile/models/user_profile.dart';

// Energy Models
import '../../core/models/energy_transaction.dart';

class DatabaseService {
  static late Isar isar;

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();

    isar = await Isar.open(
      [
        // Health (Food only)
        FoodEntrySchema,
        IngredientSchema,
        MyMealSchema,
        MyMealIngredientSchema,

        // Chat
        ChatMessageSchema,
        ChatSessionSchema,

        // Profile
        UserProfileSchema,

        // Energy
        EnergyTransactionSchema,
      ],
      directory: dir.path,
      name: 'miro_db',
    );
  }

  // Health Queries (Food only)
  static IsarCollection<FoodEntry> get foodEntries => isar.foodEntrys;
  static IsarCollection<Ingredient> get ingredients => isar.ingredients;
  static IsarCollection<MyMeal> get myMeals => isar.myMeals;
  static IsarCollection<MyMealIngredient> get myMealIngredients =>
      isar.myMealIngredients;

  // Chat Queries
  static IsarCollection<ChatMessage> get chatMessages => isar.chatMessages;
  static IsarCollection<ChatSession> get chatSessions => isar.chatSessions;

  // Profile Queries
  static IsarCollection<UserProfile> get userProfiles => isar.userProfiles;
}
