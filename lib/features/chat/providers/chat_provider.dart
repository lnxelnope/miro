import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/database_service.dart';
import '../../../core/utils/logger.dart';
import '../../../core/ai/gemini_chat_service.dart';
import '../../../core/constants/enums.dart';
import '../models/chat_message.dart';
import '../models/chat_ai_mode.dart';
import '../services/intent_handler.dart';
import '../services/food_lookup_service.dart';
import '../../health/providers/health_provider.dart';
import '../../health/models/food_entry.dart';
import '../../health/models/my_meal.dart';
import '../../health/models/ingredient.dart';
import '../../energy/providers/energy_provider.dart';
import '../../profile/providers/profile_provider.dart';

/// Result of saving chat food entries
class _ChatSaveResult {
  final int fromDbCount;
  final int unanalyzedCount;
  final List<String> itemNames;
  int get totalCount => fromDbCount + unanalyzedCount;
  const _ChatSaveResult({
    required this.fromDbCount,
    required this.unanalyzedCount,
    required this.itemNames,
  });
}

// Current session provider
final currentSessionIdProvider = StateProvider<String>((ref) {
  return const Uuid().v4();
});

/// หน้าที่ผู้ใช้กำลังดูอยู่ — ใช้เป็น context ให้ AI
/// v1.0: Health only
final activePageContextProvider = StateProvider<String>((ref) => 'health');

// Messages for current session
final chatMessagesProvider = FutureProvider<List<ChatMessage>>((ref) async {
  final sessionId = ref.watch(currentSessionIdProvider);

  return await DatabaseService.chatMessages
      .filter()
      .sessionIdEqualTo(sessionId)
      .sortByCreatedAt()
      .findAll();
});

// Loading state
final chatLoadingProvider = StateProvider<bool>((ref) => false);

// ============ CHAT HISTORY ============

// Provider สำหรับดึง sessions ทั้งหมด
final chatSessionsProvider = FutureProvider<List<ChatSession>>((ref) async {
  return await DatabaseService.chatSessions
      .where()
      .sortByUpdatedAtDesc()
      .findAll();
});

// Provider สำหรับดึง messages ของ session ที่เลือก
final sessionMessagesProvider =
    FutureProvider.family<List<ChatMessage>, String>((ref, sessionId) async {
  return await DatabaseService.chatMessages
      .filter()
      .sessionIdEqualTo(sessionId)
      .sortByCreatedAt()
      .findAll();
});

// Chat notifier
class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref ref;
  final IntentHandler _intentHandler = IntentHandler();

  ChatNotifier(this.ref) : super([]);

  static double _safe(double? v, [double fallback = 0]) =>
      (v == null || v.isNaN || v.isInfinite) ? fallback : v;

  Future<void> sendMessage(String content, {String? pageContext}) async {
    final sessionId = ref.read(currentSessionIdProvider);
    final String activeContext =
        pageContext ?? ref.read(activePageContextProvider);

    // 1. Create user message
    final userMessage = ChatMessage()
      ..sessionId = sessionId
      ..role = MessageRole.user
      ..content = content;

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.chatMessages.put(userMessage);
    });

    state = [...state, userMessage];

    // 2. Show loading
    ref.read(chatLoadingProvider.notifier).state = true;

    // 3. Process with AI and generate response
    await _generateAIResponse(content, pageContext: activeContext);

    // 4. Hide loading
    ref.read(chatLoadingProvider.notifier).state = false;

    // 5. Update or create session
    await _updateSession(sessionId, content);
  }

  Future<void> _generateAIResponse(String userMessage,
      {String pageContext = 'health'}) async {
    final sessionId = ref.read(currentSessionIdProvider);

    try {
      // Get current AI mode
      final aiMode = ref.read(chatAiModeProvider);

      String replyMessage;
      String? detectedIntent;

      if (aiMode == ChatAiMode.local) {
        // LOCAL AI — Free, use existing IntentHandler flow
        final response = await _intentHandler.processMessage(userMessage,
            pageContext: pageContext);
        replyMessage = response.replyMessage;
        detectedIntent = response.actionResult?.entryType ?? 'unknown';

        // Refresh providers if food entry was created
        if (response.actionResult != null &&
            response.actionResult!.entryType == 'food') {
          debugPrint(
              '🔄 [ChatProvider] Refreshing food providers after Local AI food entry...');
          final today = dateOnly(DateTime.now());
          DateTime entryDate = today;
          if (response.actionResult!.data != null &&
              response.actionResult!.data!['date'] != null) {
            final parsedDate = DateTime.tryParse(
                response.actionResult!.data!['date'] as String);
            if (parsedDate != null) entryDate = dateOnly(parsedDate);
          }
          ref.invalidate(foodEntriesByDateProvider(entryDate));
          ref.invalidate(foodEntriesByDateProvider(today));
          ref.invalidate(todayCaloriesProvider);
          ref.invalidate(todayMacrosProvider);
          ref.invalidate(healthTimelineProvider(entryDate));
          ref.invalidate(healthTimelineProvider(today));
        }
      } else {
        // MIRO AI — 1 Energy cost, use Gemini Backend
        final miroResponse = await _handleMiroAi(userMessage);
        replyMessage = miroResponse;
        detectedIntent = 'food';
      }

      // สร้าง assistant message
      final assistantMessage = ChatMessage()
        ..sessionId = sessionId
        ..role = MessageRole.assistant
        ..content = replyMessage
        ..detectedIntent = detectedIntent;

      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.chatMessages.put(assistantMessage);
      });

      state = [...state, assistantMessage];
    } on ChatContentTooLongException catch (e) {
      final errorMessage = ChatMessage()
        ..sessionId = sessionId
        ..role = MessageRole.assistant
        ..content = '📝 $e'
        ..detectedIntent = 'error';

      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.chatMessages.put(errorMessage);
      });

      state = [...state, errorMessage];
    } catch (e) {
      final errorText = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      final errorMessage = ChatMessage()
        ..sessionId = sessionId
        ..role = MessageRole.assistant
        ..content = '❌ เกิดข้อผิดพลาด: $errorText\n\nลองใหม่อีกครั้งนะครับ'
        ..detectedIntent = 'error';

      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.chatMessages.put(errorMessage);
      });

      state = [...state, errorMessage];
    }
  }

  /// Gather local food context for AI prompt enhancement
  /// Returns a map with MyMeal names, Ingredient names, recent history, and today's summary
  Future<Map<String, dynamic>> _gatherFoodContext() async {
    final context = <String, dynamic>{};

    try {
      // 1. MyMeal DB: top 50 by usage count
      final myMeals = await DatabaseService.myMeals
          .where()
          .sortByUsageCountDesc()
          .limit(50)
          .findAll();
      if (myMeals.isNotEmpty) {
        context['savedMeals'] = myMeals.map((m) => m.name).toList();
      }

      // 2. Ingredient DB: top 50 by usage count
      final ingredients = await DatabaseService.ingredients
          .where()
          .sortByUsageCountDesc()
          .limit(50)
          .findAll();
      if (ingredients.isNotEmpty) {
        context['savedIngredients'] = ingredients.map((i) => i.name).toList();
      }

      // 3. Recent food history: last 7 days
      final now = DateTime.now();
      final recentHistory = <String>[];
      for (int i = 0; i < 7; i++) {
        final date = dateOnly(now.subtract(Duration(days: i)));
        final entriesAsync = ref.read(foodEntriesByDateProvider(date));
        final entries = await entriesAsync.when(
          data: (data) => Future.value(data),
          loading: () => Future.value(<FoodEntry>[]),
          error: (_, __) => Future.value(<FoodEntry>[]),
        );
        if (entries.isNotEmpty) {
          final dateStr = '${date.month}/${date.day}';
          final foodNames = entries.map((e) => e.foodName).take(5).join(', ');
          recentHistory.add('$dateStr: $foodNames');
        }
      }
      if (recentHistory.isNotEmpty) {
        context['recentHistory'] = recentHistory;
      }

      // 4. Today's summary
      final todayCaloriesAsync = ref.read(todayCaloriesProvider);
      final todayMacrosAsync = ref.read(todayMacrosProvider);
      
      final todayCalories = await todayCaloriesAsync.when(
        data: (data) => Future.value(data),
        loading: () => Future.value(0.0),
        error: (_, __) => Future.value(0.0),
      );
      
      final todayMacros = await todayMacrosAsync.when(
        data: (data) => Future.value(data),
        loading: () => Future.value({'protein': 0.0, 'carbs': 0.0, 'fat': 0.0}),
        error: (_, __) => Future.value({'protein': 0.0, 'carbs': 0.0, 'fat': 0.0}),
      );

      final profileAsync = ref.read(profileNotifierProvider);
      final profile = await profileAsync.when(
        data: (data) => Future.value(data),
        loading: () => Future.value(null),
        error: (_, __) => Future.value(null),
      );

      if (profile != null) {
        final cal = _safe(todayCalories);
        final pro = _safe(todayMacros['protein'] ?? 0);
        final carb = _safe(todayMacros['carbs'] ?? 0);
        final f = _safe(todayMacros['fat'] ?? 0);
        final target = _safe(profile.calorieGoal, 2000);
        context['todaySummary'] = {
          'consumed': cal.toInt(),
          'protein': pro.toInt(),
          'carbs': carb.toInt(),
          'fat': f.toInt(),
          'target': target.toInt(),
          'remaining': (target - cal).toInt(),
        };
      }

      AppLogger.info('[ChatContext] Gathered context: ${context.keys.toList()}');
      
      // DEBUG: Show actual context data
      if (context['savedMeals'] != null) {
        final meals = context['savedMeals'] as List;
        debugPrint('📊 Saved Meals (${meals.length}): ${meals.take(5).join(", ")}');
      }
      if (context['recentHistory'] != null) {
        final history = context['recentHistory'] as List;
        debugPrint('📊 Recent History (${history.length}): ${history.take(3).join(" | ")}');
      }
      if (context['todaySummary'] != null) {
        debugPrint('📊 Today Summary: ${context['todaySummary']}');
      }
      
      return context;
    } catch (e) {
      AppLogger.warn('[ChatContext] Failed to gather context: $e');
      return {};
    }
  }

  /// Handle Miro AI (new flow with Gemini Backend)
  /// Returns reply message string
  ///
  /// Energy pricing: flat 1⚡ per chat request
  /// Food entries are saved as unanalyzed (check DB first, 0 kcal if not found)
  Future<String> _handleMiroAi(String text) async {
    final energyService = ref.read(energyServiceProvider);
    final balance = await energyService.getBalance();

    if (balance < 1) {
      throw Exception(
          'Not enough Energy (minimum 1⚡ required). Please purchase more from the store.');
    }

    final profileAsync = ref.read(profileNotifierProvider);
    final profile = await profileAsync.when(
      data: (data) => Future.value(data),
      loading: () => Future.value(null),
      error: (_, __) => Future.value(null),
    );

    // Gather food context from local database
    final foodContext = await _gatherFoodContext();

    final response = await GeminiChatService.analyzeChatMessage(
      message: text,
      energyService: energyService,
      userProfile: profile,
      foodContext: foodContext,
    );

    // Parse response: check DB first, save as unanalyzed if not found
    final saveResult = await _parseMiroAiResponse(response);

    // Refresh providers
    debugPrint(
        '🔄 [ChatProvider] Refreshing food providers after Miro AI food entry...');
    final today = dateOnly(DateTime.now());
    ref.invalidate(foodEntriesByDateProvider(today));
    ref.invalidate(todayCaloriesProvider);
    ref.invalidate(todayMacrosProvider);
    ref.invalidate(healthTimelineProvider(today));

    final energyCost = response['energyCost'] as int? ?? 1;

    // Build reply ourselves (don't use AI reply — it contains AI-calculated kcal
    // that we no longer use since entries are saved as unanalyzed)
    final buffer = StringBuffer();
    if (saveResult != null && saveResult.totalCount > 0) {
      buffer.write(
          '✅ บันทึก ${saveResult.totalCount} รายการลง Timeline แล้ว!');

      if (saveResult.fromDbCount > 0) {
        buffer.write(
            '\n📋 ${saveResult.fromDbCount} รายการพบใน Database (ใช้ค่าจาก DB)');
      }
      if (saveResult.unanalyzedCount > 0) {
        buffer.write(
            '\n⏳ ${saveResult.unanalyzedCount} รายการรอ Analyze (กด Analyze All ที่ Timeline)');
      }

      // Show item names with source icons
      buffer.write('\n\n');
      for (final name in saveResult.itemNames) {
        buffer.write('$name\n');
      }
    } else {
      final reply = response['reply'] as String? ?? 'Message received';
      buffer.write(reply);
    }
    buffer.write('\n⚡ -$energyCost Energy');

    return buffer.toString();
  }

  /// Parse Miro AI response and save food entries to timeline
  ///
  /// Flow: AI parses food names → check DB (MyMeal/Ingredient) →
  /// - Found: use DB nutrition, mark as verified
  /// - Not found: save with 0 kcal, mark as unanalyzed (user can Analyze All later)
  /// Does NOT auto-save to MyMeal/Ingredient database
  Future<_ChatSaveResult?> _parseMiroAiResponse(
      Map<String, dynamic> response) async {
    if (response['type'] != 'food_log') return null;

    final items = response['items'] as List<dynamic>?;
    if (items == null || items.isEmpty) return null;

    // DEBUG: Log full response to see if ingredients_hint is present
    AppLogger.info('🔍 [Chat] Full response items: ${jsonEncode(items)}');

    final foodNotifier = ref.read(foodEntriesNotifierProvider.notifier);
    int fromDbCount = 0;
    int unanalyzedCount = 0;
    final itemNames = <String>[];

    for (final item in items) {
      // DEBUG: Log each item to see structure
      AppLogger.info('🔍 [Chat] Processing item: ${jsonEncode(item)}');
      
      final mealTypeStr = item['meal_type'] as String? ?? 'snack';
      MealType mealType;
      switch (mealTypeStr.toLowerCase()) {
        case 'breakfast':
          mealType = MealType.breakfast;
          break;
        case 'lunch':
          mealType = MealType.lunch;
          break;
        case 'dinner':
          mealType = MealType.dinner;
          break;
        default:
          mealType = MealType.snack;
      }

      final foodName =
          item['food_name_local'] as String? ?? item['food_name'] as String;
      final foodNameEn = item['food_name'] as String?;
      final servingSize = (item['serving_size'] as num?)?.toDouble() ?? 1.0;
      final servingUnit = item['serving_unit'] as String? ?? 'serving';

      // Check if AI provided ingredients_hint for custom meal creation
      final ingredientsHint = item['ingredients_hint'] as List<dynamic>?;
      final ingredientsDetail = item['ingredients_detail'] as List<dynamic>?;
      String? preliminaryIngredientsJson;
      
      debugPrint('🔍🔍🔍 RAW ITEM: ${item.toString()}');
      debugPrint('🔍🔍🔍 INGREDIENTS_HINT: $ingredientsHint');
      debugPrint('🔍🔍🔍 INGREDIENTS_DETAIL: ${ingredientsDetail != null ? "Present (${ingredientsDetail.length} items)" : "null"}');
      
      if (ingredientsHint != null && ingredientsHint.isNotEmpty) {
        // Preferred path: AI sent ingredients_hint
        // Support both old format (string array) and new format (object array with amounts)
        final preliminaryIngredients = ingredientsHint
            .map((item) {
                  if (item is Map) {
                    // New format: {"name": "ข้าว", "amount": 200, "unit": "g"}
                    return {
                      'name': (item['name'] ?? '').toString(),
                      'name_en': (item['name_en'] ?? item['name'] ?? '').toString(),
                      'detail': '',
                      'amount': (item['amount'] as num?)?.toDouble() ?? 0,
                      'unit': (item['unit'] ?? 'g').toString(),
                      'calories': 0,
                      'protein': 0,
                      'carbs': 0,
                      'fat': 0,
                    };
                  } else {
                    // Old format: simple string name
                    return {
                      'name': item.toString(),
                      'name_en': item.toString(),
                      'detail': '',
                      'amount': 0,
                      'unit': 'g',
                      'calories': 0,
                      'protein': 0,
                      'carbs': 0,
                      'fat': 0,
                    };
                  }
                })
            .toList();
        preliminaryIngredientsJson = jsonEncode(preliminaryIngredients);
        debugPrint('✅✅✅ SAVED ${ingredientsHint.length} ingredients from ingredients_hint: $preliminaryIngredientsJson');
        AppLogger.info(
            'Chat: Custom meal "$foodName" with ${ingredientsHint.length} ingredients → saved as preliminary ingredientsJson');
      } else if (ingredientsDetail != null && ingredientsDetail.isNotEmpty) {
        // Fallback: AI sent full ingredients_detail — preserve amounts if available
        final preliminaryIngredients = ingredientsDetail
            .map((ingredient) {
              final name = ingredient['name'] as String? ?? ingredient['name_en'] as String? ?? 'Unknown';
              return {
                'name': name,
                'name_en': ingredient['name_en'] as String? ?? name,
                'detail': ingredient['detail'] as String? ?? '',
                'amount': (ingredient['amount'] as num?)?.toDouble() ?? 0,
                'unit': ingredient['unit'] as String? ?? 'g',
                'calories': (ingredient['calories'] as num?)?.toDouble() ?? 0,
                'protein': (ingredient['protein'] as num?)?.toDouble() ?? 0,
                'carbs': (ingredient['carbs'] as num?)?.toDouble() ?? 0,
                'fat': (ingredient['fat'] as num?)?.toDouble() ?? 0,
              };
            })
            .toList();
        preliminaryIngredientsJson = jsonEncode(preliminaryIngredients);
        debugPrint('⚠️⚠️⚠️ FALLBACK: Extracted ${ingredientsDetail.length} ingredients from ingredients_detail (with amounts): $preliminaryIngredientsJson');
        AppLogger.warn(
            'Chat: AI sent ingredients_detail instead of ingredients_hint for "$foodName" - extracted ${ingredientsDetail.length} ingredients with amounts');
      } else {
        debugPrint('❌❌❌ NO ingredients_hint or ingredients_detail found in response!');
      }

      // Check DB first via FoodLookupService
      final lookupResult = await FoodLookupService.lookup(
        foodName: foodName,
        servingSize: servingSize,
        servingUnit: servingUnit,
      );

      final foodEntry = FoodEntry()
        ..foodName = foodName
        ..foodNameEn = foodNameEn
        ..servingSize = servingSize
        ..servingUnit = servingUnit
        ..mealType = mealType
        ..timestamp = DateTime.now()
        ..ingredientsJson = preliminaryIngredientsJson;

      if (lookupResult.type != FoodLookupType.notFound) {
        // Found in DB → use DB nutrition
        foodEntry
          ..calories = lookupResult.calories
          ..protein = lookupResult.protein
          ..carbs = lookupResult.carbs
          ..fat = lookupResult.fat
          ..baseCalories = lookupResult.calories
          ..baseProtein = lookupResult.protein
          ..baseCarbs = lookupResult.carbs
          ..baseFat = lookupResult.fat
          ..source = DataSource.database
          ..isVerified = true;
        fromDbCount++;
        itemNames.add(
            '🗄️ $foodName (${lookupResult.calories.toInt()} kcal)');
        AppLogger.info(
            'Chat: "$foodName" found in DB (${lookupResult.type.name}) → ${lookupResult.calories.toInt()} kcal');
      } else {
        // Not found → save as unanalyzed (0 kcal)
        foodEntry
          ..calories = 0
          ..protein = 0
          ..carbs = 0
          ..fat = 0
          ..baseCalories = 0
          ..baseProtein = 0
          ..baseCarbs = 0
          ..baseFat = 0
          ..source = DataSource.manual
          ..isVerified = false;
        unanalyzedCount++;
        itemNames.add('✏️ $foodName (รอ Analyze)');
        AppLogger.info(
            'Chat: "$foodName" not in DB → saved as unanalyzed (0 kcal)');
      }

      await foodNotifier.addFoodEntry(foodEntry);
    }

    return _ChatSaveResult(
      fromDbCount: fromDbCount,
      unanalyzedCount: unanalyzedCount,
      itemNames: itemNames,
    );
  }

  /// Update or create session with title from first message
  Future<void> _updateSession(String sessionId, String firstMessage) async {
    try {
      // Check if session already exists
      final existing = await DatabaseService.chatSessions
          .filter()
          .sessionIdEqualTo(sessionId)
          .findFirst();

      if (existing != null) {
        // Update timestamp
        existing.updatedAt = DateTime.now();
        await DatabaseService.isar.writeTxn(() async {
          await DatabaseService.chatSessions.put(existing);
        });
      } else {
        // Create new session with title from first message
        final title = firstMessage.length > 30
            ? '${firstMessage.substring(0, 30)}...'
            : firstMessage;

        final session = ChatSession()
          ..sessionId = sessionId
          ..title = title
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now();

        await DatabaseService.isar.writeTxn(() async {
          await DatabaseService.chatSessions.put(session);
        });

        AppLogger.info('Created new session: $title');
      }

      // Invalidate sessions provider to refresh list
      ref.invalidate(chatSessionsProvider);
    } catch (e) {
      debugPrint('❌ [ChatProvider] Error updating session: $e');
    }
  }

  /// Load messages from existing session
  Future<void> loadSession(String sessionId) async {
    // Switch to the session
    ref.read(currentSessionIdProvider.notifier).state = sessionId;

    // Load messages
    final messages = await DatabaseService.chatMessages
        .filter()
        .sessionIdEqualTo(sessionId)
        .sortByCreatedAt()
        .findAll();

    state = messages;
    AppLogger.info('Loaded session with ${messages.length} messages');
  }

  /// Start a new chat session
  void startNewSession() {
    state = [];
    ref.read(currentSessionIdProvider.notifier).state = const Uuid().v4();
    AppLogger.info('Started new session');
  }

  /// Delete a session and its messages
  Future<void> deleteSession(String sessionId) async {
    try {
      await DatabaseService.isar.writeTxn(() async {
        // Delete messages
        await DatabaseService.chatMessages
            .filter()
            .sessionIdEqualTo(sessionId)
            .deleteAll();

        // Delete session
        await DatabaseService.chatSessions
            .filter()
            .sessionIdEqualTo(sessionId)
            .deleteAll();
      });

      // If current session was deleted, start new one
      if (ref.read(currentSessionIdProvider) == sessionId) {
        startNewSession();
      }

      // Refresh sessions list
      ref.invalidate(chatSessionsProvider);

      AppLogger.info('Deleted session: $sessionId');
    } catch (e) {
      AppLogger.error('Error deleting session', e);
    }
  }

  void clearMessages() {
    state = [];
    // Create new session
    ref.read(currentSessionIdProvider.notifier).state = const Uuid().v4();
  }

  /// Add a message to chat (for system messages like greeting)
  Future<void> addMessage(ChatMessage message) async {
    final sessionId = ref.read(currentSessionIdProvider);
    message.sessionId = sessionId;

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.chatMessages.put(message);
    });

    state = [...state, message];
  }

  /// Remove a message from chat (for removing loading messages)
  Future<void> removeMessage(ChatMessage message) async {
    // Remove from database
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.chatMessages.delete(message.id);
    });

    // Remove from state
    state = state.where((msg) => msg.id != message.id).toList();
  }
}

final chatNotifierProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier(ref);
});

/// Provider สำหรับเก็บ AI Mode ที่ user เลือก
/// Default: ChatAiMode.miroAi (แม่นยำสูง, หลายภาษา)
/// เปลี่ยนได้ใน Settings
final chatAiModeProvider = StateProvider<ChatAiMode>((ref) {
  return ChatAiMode.miroAi;
});
