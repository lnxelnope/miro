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
import '../../health/providers/my_meal_provider.dart';
import '../services/intent_handler.dart';
import '../../health/providers/health_provider.dart';
import '../../health/models/food_entry.dart';
import '../../energy/providers/energy_provider.dart';
import '../../profile/providers/profile_provider.dart';

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
final sessionMessagesProvider = FutureProvider.family<List<ChatMessage>, String>((ref, sessionId) async {
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

  Future<void> sendMessage(String content, {String? pageContext}) async {
    final sessionId = ref.read(currentSessionIdProvider);
    final String activeContext = pageContext ?? ref.read(activePageContextProvider);
    
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

  Future<void> _generateAIResponse(String userMessage, {String pageContext = 'health'}) async {
    final sessionId = ref.read(currentSessionIdProvider);
    
    try {
      // Get current AI mode
      final aiMode = ref.read(chatAiModeProvider);
      
      String replyMessage;
      String? detectedIntent;
      
      if (aiMode == ChatAiMode.local) {
        // LOCAL AI — Free, use existing IntentHandler flow
        final response = await _intentHandler.processMessage(userMessage, pageContext: pageContext);
        replyMessage = response.replyMessage;
        detectedIntent = response.actionResult?.entryType ?? 'unknown';
        
        // Refresh providers if food entry was created
        if (response.actionResult != null && response.actionResult!.entryType == 'food') {
          debugPrint('🔄 [ChatProvider] Refreshing food providers after Local AI food entry...');
          final today = dateOnly(DateTime.now());
          DateTime entryDate = today;
          if (response.actionResult!.data != null && response.actionResult!.data!['date'] != null) {
            final parsedDate = DateTime.tryParse(response.actionResult!.data!['date'] as String);
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
      
    } catch (e) {
      // Error fallback
      final errorMessage = ChatMessage()
        ..sessionId = sessionId
        ..role = MessageRole.assistant
        ..content = '❌ เกิดข้อผิดพลาด: $e\n\nลองใหม่อีกครั้งนะครับ'
        ..detectedIntent = 'error';

      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.chatMessages.put(errorMessage);
      });

      state = [...state, errorMessage];
    }
  }

  /// Handle Miro AI (new flow with Gemini Backend)
  /// Returns reply message string
  /// 
  /// Energy pricing: base 2⚡ + 1⚡ per food item detected
  /// Example: "ate rice, soup, salad, juice" → 2 + 4 = 6⚡
  Future<String> _handleMiroAi(String text) async {
    // Check Energy balance (minimum 2 Energy required for base cost)
    final energyService = ref.read(energyServiceProvider);
    final balance = await energyService.getBalance();
    
    if (balance < 2) {
      throw Exception('Not enough Energy (minimum 2⚡ required). Please purchase more from the store.');
    }
    
    // Get user profile for personalization
    final profileAsync = ref.read(profileNotifierProvider);
    final profile = await profileAsync.when(
      data: (data) => Future.value(data),
      loading: () => Future.value(null),
      error: (_, __) => Future.value(null),
    );
    
    // Call Gemini Backend (backend calculates dynamic cost and deducts)
    final response = await GeminiChatService.analyzeChatMessage(
      message: text,
      energyService: energyService,
      userProfile: profile,
    );
    
    // Note: Energy is deducted by backend (dynamic pricing), balance updated in GeminiChatService
    
    // Parse response and save food entries
    await _parseMiroAiResponse(response);
    
    // Refresh providers
    debugPrint('🔄 [ChatProvider] Refreshing food providers after Miro AI food entry...');
    final today = dateOnly(DateTime.now());
    ref.invalidate(foodEntriesByDateProvider(today));
    ref.invalidate(todayCaloriesProvider);
    ref.invalidate(todayMacrosProvider);
    ref.invalidate(healthTimelineProvider(today));
    
    // Build reply with actual energy cost breakdown
    final reply = response['reply'] as String? ?? 'Message received';
    final energyCost = response['energyCost'] as int? ?? 2;
    final breakdown = response['energyBreakdown'] as Map<String, dynamic>?;
    
    String energyInfo;
    if (breakdown != null) {
      final baseCost = breakdown['baseCost'] as int? ?? 2;
      final itemCount = breakdown['itemCount'] as int? ?? 0;
      if (itemCount > 0) {
        energyInfo = '⚡ -$energyCost Energy (base $baseCost + $itemCount items)';
      } else {
        energyInfo = '⚡ -$energyCost Energy';
      }
    } else {
      energyInfo = '⚡ -$energyCost Energy';
    }
    
    return '$reply\n\n$energyInfo';
  }

  /// Parse Miro AI response and save food entries
  /// Also saves ingredients and My Meal if backend returns them
  Future<void> _parseMiroAiResponse(Map<String, dynamic> response) async {
    if (response['type'] != 'food_log') return;
    
    final items = response['items'] as List<dynamic>?;
    if (items == null || items.isEmpty) return;
    
    final foodNotifier = ref.read(foodEntriesNotifierProvider.notifier);
    
    for (final item in items) {
      // Map meal_type string to MealType enum
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

      // Parse ingredients if backend returns them
      String? ingredientsJsonStr;
      final ingredientsList = item['ingredients_detail'] as List<dynamic>?;
      if (ingredientsList != null && ingredientsList.isNotEmpty) {
        ingredientsJsonStr = jsonEncode(ingredientsList);
      }

      // Parse micronutrients if available
      final fiber = (item['fiber'] as num?)?.toDouble();
      final sugar = (item['sugar'] as num?)?.toDouble();
      final sodium = (item['sodium'] as num?)?.toDouble();
      
      final foodEntry = FoodEntry()
        ..foodName = item['food_name_local'] as String? ?? item['food_name'] as String
        ..foodNameEn = item['food_name'] as String
        ..servingSize = (item['serving_size'] as num?)?.toDouble() ?? 1.0
        ..servingUnit = item['serving_unit'] as String? ?? 'serving'
        ..calories = (item['calories'] as num?)?.toDouble() ?? 0
        ..protein = (item['protein'] as num?)?.toDouble() ?? 0
        ..carbs = (item['carbs'] as num?)?.toDouble() ?? 0
        ..fat = (item['fat'] as num?)?.toDouble() ?? 0
        ..mealType = mealType
        ..timestamp = DateTime.now()
        ..source = DataSource.aiAnalyzed
        ..isVerified = true  // ✅ FIX: Chat AI ก็วิเคราะห์แล้ว → mark verified เพื่อเตือนก่อน re-analyze
        ..baseCalories = (item['calories'] as num?)?.toDouble() ?? 0
        ..baseProtein = (item['protein'] as num?)?.toDouble() ?? 0
        ..baseCarbs = (item['carbs'] as num?)?.toDouble() ?? 0
        ..baseFat = (item['fat'] as num?)?.toDouble() ?? 0
        ..fiber = fiber
        ..sugar = sugar
        ..sodium = sodium
        ..ingredientsJson = ingredientsJsonStr;
      
      await foodNotifier.addFoodEntry(foodEntry);

      // Auto-save ingredients and My Meal if data available
      if (ingredientsList != null && ingredientsList.isNotEmpty) {
        try {
          final ingredientsData = ingredientsList
              .map((e) => e as Map<String, dynamic>)
              .toList();
          
          await foodNotifier.saveIngredientsAndMeal(
            mealName: item['food_name_local'] as String? ?? item['food_name'] as String,
            mealNameEn: item['food_name'] as String?,
            servingDescription: '${(item['serving_size'] as num?)?.toDouble() ?? 1.0} ${item['serving_unit'] as String? ?? 'serving'}',
            ingredientsData: ingredientsData,
          );
          
          ref.invalidate(allMyMealsProvider);
          ref.invalidate(allIngredientsProvider);
          
          AppLogger.info('Chat: Auto-saved ${ingredientsList.length} ingredients + 1 meal');
        } catch (e) {
          AppLogger.warn('Chat: Could not auto-save meal: $e');
        }
      }
    }
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
