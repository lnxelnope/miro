import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/database_service.dart';
import '../../../core/utils/logger.dart';
import '../models/chat_message.dart';
import '../services/intent_handler.dart';
import '../../health/providers/health_provider.dart';

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
      // ใช้ IntentHandler ประมวลผล (ส่ง pageContext ไปด้วย)
      final response = await _intentHandler.processMessage(userMessage, pageContext: pageContext);
      
      // สร้าง assistant message
      final assistantMessage = ChatMessage()
        ..sessionId = sessionId
        ..role = MessageRole.assistant
        ..content = response.replyMessage
        ..detectedIntent = response.actionResult?.entryType ?? 'unknown';

      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.chatMessages.put(assistantMessage);
      });

      state = [...state, assistantMessage];
      
      // ===== Refresh providers หลังเพิ่มข้อมูลสำเร็จ =====
      if (response.actionResult != null && response.actionResult!.entryType == 'food') {
        debugPrint('🔄 [ChatProvider] Refreshing food providers after chat food entry...');
        final today = DateTime.now();
        // ใช้ date จาก actionResult ถ้ามี
        DateTime entryDate = today;
        if (response.actionResult!.data != null && response.actionResult!.data!['date'] != null) {
          final parsedDate = DateTime.tryParse(response.actionResult!.data!['date'] as String);
          if (parsedDate != null) entryDate = parsedDate;
        }
        ref.invalidate(foodEntriesByDateProvider(entryDate));
        ref.invalidate(foodEntriesByDateProvider(today));
        ref.invalidate(todayCaloriesProvider);
        ref.invalidate(todayMacrosProvider);
        ref.invalidate(healthTimelineProvider(entryDate));
        ref.invalidate(healthTimelineProvider(today));
      }
      
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
}

final chatNotifierProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier(ref);
});
