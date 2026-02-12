# Step 11: Chat + AI Integration (ให้ AI สร้าง Entry จริง)

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 2-3 ชั่วโมง
> **ความยาก:** ยาก
> **ต้องทำก่อน:** Step 10 (Chat UI)

---

## 🎯 เป้าหมาย

เมื่อ user พิมพ์ข้อความ เช่น:
- "กินข้าวผัด 500 แคล" → สร้าง FoodEntry อัตโนมัติ
- "จ่ายค่ากาแฟ 65 บาท" → สร้าง Transaction อัตโนมัติ
- "พรุ่งนี้ประชุม 14:00" → สร้าง Task อัตโนมัติ

---

## สิ่งที่ต้องทำ

1. สร้าง Intent Handler Service
2. สร้าง Action Result Model
3. อัปเดต Chat Provider ให้ใช้ AI + สร้าง Entry
4. สร้าง Action Confirmation Card
5. ทดสอบทั้งระบบ

---

## ขั้นตอนที่ 1: สร้าง Action Result Model

**สร้างไฟล์:** `lib/features/chat/models/action_result.dart`

```dart
/// ผลลัพธ์จากการดำเนินการตาม Intent
class ActionResult {
  final bool success;
  final String message;
  final String? entryType; // 'food', 'expense', 'task', etc.
  final int? entryId;
  final Map<String, dynamic>? data;

  ActionResult({
    required this.success,
    required this.message,
    this.entryType,
    this.entryId,
    this.data,
  });

  factory ActionResult.success({
    required String message,
    String? entryType,
    int? entryId,
    Map<String, dynamic>? data,
  }) {
    return ActionResult(
      success: true,
      message: message,
      entryType: entryType,
      entryId: entryId,
      data: data,
    );
  }

  factory ActionResult.failure(String message) {
    return ActionResult(
      success: false,
      message: message,
    );
  }
}
```

---

## ขั้นตอนที่ 2: สร้าง Intent Handler Service

**สร้างไฟล์:** `lib/features/chat/services/intent_handler.dart`

```dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../core/ai/llm_service.dart';
import '../../../core/database/database_service.dart';
import '../../health/models/food_entry.dart';
import '../../finance/models/transaction.dart';
import '../../tasks/models/task.dart';
import '../models/action_result.dart';

/// Service สำหรับจัดการ Intent และสร้าง Entry
class IntentHandler {
  final LLMService _llmService = LLMService();

  /// ประมวลผลข้อความและดำเนินการตาม Intent
  Future<IntentResponse> processMessage(String message) async {
    try {
      // 1. ใช้ AI วิเคราะห์ข้อความ
      final jsonResult = await _llmService.classifyAndParse(message);
      final parsed = jsonDecode(jsonResult);

      final type = parsed['type'] as String? ?? 'unknown';
      final title = parsed['title'] as String? ?? message;
      final amount = parsed['amount'] as num?;
      final startStr = parsed['start'] as String?;
      final category = parsed['category'] as String? ?? 'Other';

      debugPrint('🤖 AI Result: type=$type, title=$title, amount=$amount');

      // 2. ดำเนินการตาม type
      switch (type) {
        case 'health':
          return await _handleHealth(message, title, category, parsed);
        case 'finance':
          return await _handleFinance(message, title, amount, category);
        case 'task':
          return await _handleTask(message, title, startStr, category);
        default:
          return IntentResponse(
            replyMessage: _getHelpMessage(),
            actionResult: null,
          );
      }
    } catch (e) {
      debugPrint('❌ IntentHandler error: $e');
      return IntentResponse(
        replyMessage: '❌ เกิดข้อผิดพลาด: $e\n\nลองใหม่อีกครั้งนะครับ',
        actionResult: ActionResult.failure('Error: $e'),
      );
    }
  }

  /// จัดการ Health Intent
  Future<IntentResponse> _handleHealth(
    String original,
    String title,
    String category,
    Map<String, dynamic> parsed,
  ) async {
    // ดึงข้อมูลแคลอรี่จากข้อความ
    final calories = _extractCalories(original);
    
    if (category == 'Food' || original.contains('กิน') || original.contains('ทาน')) {
      // สร้าง FoodEntry
      final entry = FoodEntry()
        ..name = title
        ..calories = calories ?? 0
        ..mealType = _detectMealType()
        ..date = DateTime.now()
        ..servingSize = 1
        ..servingUnit = 'จาน';

      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.foodEntries.put(entry);
      });

      return IntentResponse(
        replyMessage: '✅ บันทึกอาหารแล้ว!\n\n'
            '🍽️ **$title**\n'
            '🔥 ${calories ?? 0} แคลอรี่\n'
            '⏰ ${_getMealTypeText(_detectMealType())}\n\n'
            '_แก้ไขได้ที่หน้า Health > Diet_',
        actionResult: ActionResult.success(
          message: 'บันทึกอาหารสำเร็จ',
          entryType: 'food',
          entryId: entry.id,
          data: {'name': title, 'calories': calories},
        ),
      );
    }

    if (category == 'Workout' || original.contains('ออกกำลัง') || original.contains('วิ่ง')) {
      // TODO: สร้าง WorkoutEntry
      return IntentResponse(
        replyMessage: '🏃 ฟีเจอร์บันทึก Workout กำลังพัฒนา\n\n'
            'เร็วๆ นี้จะสามารถบันทึก:\n'
            '• ประเภทการออกกำลังกาย\n'
            '• ระยะเวลา\n'
            '• แคลอรี่ที่เผาผลาญ',
        actionResult: null,
      );
    }

    return IntentResponse(
      replyMessage: '🍎 ต้องการบันทึกสุขภาพอะไรครับ?\n\n'
          'ลองบอกว่า:\n'
          '• "กินข้าวผัด 500 แคล"\n'
          '• "วิ่ง 30 นาที"',
      actionResult: null,
    );
  }

  /// จัดการ Finance Intent
  Future<IntentResponse> _handleFinance(
    String original,
    String title,
    num? amount,
    String category,
  ) async {
    if (amount == null || amount <= 0) {
      return IntentResponse(
        replyMessage: '💰 ต้องระบุจำนวนเงินด้วยนะครับ\n\n'
            'ลองบอกว่า:\n'
            '• "จ่ายค่ากาแฟ 65 บาท"\n'
            '• "ซื้อของ 500 บาท"',
        actionResult: null,
      );
    }

    // ตรวจสอบว่าเป็นรายรับหรือรายจ่าย
    final isIncome = original.contains('ได้') || 
                     original.contains('รับ') || 
                     original.contains('เงินเดือน');
    
    final txnType = isIncome ? TransactionType.income : TransactionType.expense;

    // สร้าง Transaction
    final txn = Transaction()
      ..description = title
      ..amount = amount.toDouble()
      ..type = txnType
      ..category = category
      ..date = DateTime.now();

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.transactions.put(txn);
    });

    final emoji = isIncome ? '💵' : '💸';
    final typeText = isIncome ? 'รายรับ' : 'รายจ่าย';

    return IntentResponse(
      replyMessage: '✅ บันทึก$typeTextแล้ว!\n\n'
          '$emoji **$title**\n'
          '💰 ${amount.toStringAsFixed(0)} บาท\n'
          '📁 หมวด: $category\n\n'
          '_แก้ไขได้ที่หน้า Finance_',
      actionResult: ActionResult.success(
        message: 'บันทึก$typeTextสำเร็จ',
        entryType: 'transaction',
        entryId: txn.id,
        data: {'description': title, 'amount': amount, 'type': txnType.name},
      ),
    );
  }

  /// จัดการ Task Intent
  Future<IntentResponse> _handleTask(
    String original,
    String title,
    String? startStr,
    String category,
  ) async {
    DateTime? dueDate;
    DateTime? dueTime;

    // พยายาม parse วันเวลา
    if (startStr != null) {
      try {
        final parsed = DateTime.parse(startStr);
        dueDate = DateTime(parsed.year, parsed.month, parsed.day);
        dueTime = parsed;
      } catch (_) {}
    }

    // ถ้าไม่มีวันที่จาก AI ให้ลองหาจากข้อความ
    if (dueDate == null) {
      final now = DateTime.now();
      if (original.contains('พรุ่งนี้')) {
        dueDate = DateTime(now.year, now.month, now.day + 1);
      } else if (original.contains('วันนี้')) {
        dueDate = DateTime(now.year, now.month, now.day);
      } else if (original.contains('มะรืน')) {
        dueDate = DateTime(now.year, now.month, now.day + 2);
      }
    }

    // ลองหาเวลา
    if (dueTime == null && dueDate != null) {
      final timeMatch = RegExp(r'(\d{1,2})[:.]?(\d{2})?\s*(?:น\.|โมง)?').firstMatch(original);
      if (timeMatch != null) {
        int hour = int.parse(timeMatch.group(1)!);
        int minute = int.tryParse(timeMatch.group(2) ?? '0') ?? 0;
        
        // ปรับเวลาไทย
        if (hour >= 1 && hour <= 6 && original.contains('บ่าย')) {
          hour += 12;
        } else if (hour >= 1 && hour <= 5 && !original.contains('ตี')) {
          hour += 12; // บ่าย by default
        }
        
        dueTime = DateTime(dueDate.year, dueDate.month, dueDate.day, hour, minute);
      }
    }

    // สร้าง Task
    final task = Task()
      ..title = title
      ..description = original
      ..dueDate = dueDate
      ..dueTime = dueTime
      ..priority = TaskPriority.medium
      ..status = TaskStatus.pending
      ..category = category
      ..createdAt = DateTime.now();

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.tasks.put(task);
    });

    String dateTimeStr = '';
    if (dueDate != null) {
      dateTimeStr = '📅 ${_formatDate(dueDate)}';
      if (dueTime != null) {
        dateTimeStr += ' ⏰ ${_formatTime(dueTime)}';
      }
    }

    return IntentResponse(
      replyMessage: '✅ สร้าง Task แล้ว!\n\n'
          '📌 **$title**\n'
          '$dateTimeStr\n'
          '📁 หมวด: $category\n\n'
          '_แก้ไขได้ที่หน้า Tasks_',
      actionResult: ActionResult.success(
        message: 'สร้าง Task สำเร็จ',
        entryType: 'task',
        entryId: task.id,
        data: {'title': title, 'dueDate': dueDate?.toIso8601String()},
      ),
    );
  }

  // ============================================
  // HELPER METHODS
  // ============================================

  /// ดึงแคลอรี่จากข้อความ
  int? _extractCalories(String text) {
    // Pattern: 500 แคล, 500kcal, 500 cal
    final patterns = [
      RegExp(r'(\d+)\s*(?:แคล|kcal|cal|กิโลแคล)', caseSensitive: false),
      RegExp(r'(?:แคล|calories?)\s*(\d+)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return int.tryParse(match.group(1)!);
      }
    }

    return null;
  }

  /// ตรวจหามื้ออาหารจากเวลาปัจจุบัน
  String _detectMealType() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 10) return 'breakfast';
    if (hour >= 10 && hour < 14) return 'lunch';
    if (hour >= 14 && hour < 17) return 'snack';
    if (hour >= 17 && hour < 21) return 'dinner';
    return 'snack';
  }

  String _getMealTypeText(String type) {
    switch (type) {
      case 'breakfast': return 'มื้อเช้า';
      case 'lunch': return 'มื้อเที่ยง';
      case 'snack': return 'ของว่าง';
      case 'dinner': return 'มื้อเย็น';
      default: return 'อื่นๆ';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'วันนี้';
    if (dateOnly == today.add(const Duration(days: 1))) return 'พรุ่งนี้';
    if (dateOnly == today.add(const Duration(days: 2))) return 'มะรืนนี้';

    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _getHelpMessage() {
    return '🤔 ผมยังไม่เข้าใจนะครับ\n\n'
        'ลองบอกเรื่องเกี่ยวกับ:\n'
        '• 🍽️ **อาหาร**: "กินข้าวผัด 500 แคล"\n'
        '• 💰 **เงิน**: "จ่ายค่ากาแฟ 65 บาท"\n'
        '• 📅 **นัด**: "พรุ่งนี้ประชุม 14:00"\n\n'
        'หรือพิมพ์ "ช่วย" เพื่อดูว่าทำอะไรได้บ้าง';
  }
}

/// Response จาก Intent Handler
class IntentResponse {
  final String replyMessage;
  final ActionResult? actionResult;

  IntentResponse({
    required this.replyMessage,
    this.actionResult,
  });
}
```

---

## ขั้นตอนที่ 3: อัปเดต Chat Provider

**แก้ไขไฟล์:** `lib/features/chat/providers/chat_provider.dart`

**แทนที่ทั้งไฟล์ด้วยโค้ดนี้:**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/database_service.dart';
import '../models/chat_message.dart';
import '../services/intent_handler.dart';

// Current session provider
final currentSessionIdProvider = StateProvider<String>((ref) {
  return const Uuid().v4();
});

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

// Chat notifier
class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref ref;
  final IntentHandler _intentHandler = IntentHandler();
  
  ChatNotifier(this.ref) : super([]);

  Future<void> sendMessage(String content) async {
    final sessionId = ref.read(currentSessionIdProvider);
    
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
    await _generateAIResponse(content);

    // 4. Hide loading
    ref.read(chatLoadingProvider.notifier).state = false;
  }

  Future<void> _generateAIResponse(String userMessage) async {
    final sessionId = ref.read(currentSessionIdProvider);
    
    try {
      // ใช้ IntentHandler ประมวลผล
      final response = await _intentHandler.processMessage(userMessage);
      
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
```

---

## ขั้นตอนที่ 4: อัปเดต Chat Screen (เพิ่ม Loading)

**แก้ไขไฟล์:** `lib/features/chat/presentation/chat_screen.dart`

**หา method `build` และเพิ่ม loading indicator:**

```dart
@override
Widget build(BuildContext context) {
  final messages = ref.watch(chatNotifierProvider);
  final isLoading = ref.watch(chatLoadingProvider); // เพิ่มบรรทัดนี้

  // Scroll to bottom when new message
  if (messages.isNotEmpty) {
    _scrollToBottom();
  }

  return Scaffold(
    appBar: AppBar(
      title: const Row(
        children: [
          Text('🤖', style: TextStyle(fontSize: 20)),
          SizedBox(width: 8),
          Text('Chat'),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _showClearConfirmation(),
        ),
      ],
    ),
    body: Column(
      children: [
        // Messages
        Expanded(
          child: messages.isEmpty
              ? _buildWelcomeScreen()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: messages.length + (isLoading ? 1 : 0), // เพิ่ม loading
                  itemBuilder: (context, index) {
                    // แสดง loading indicator ตัวสุดท้าย
                    if (isLoading && index == messages.length) {
                      return _buildTypingIndicator();
                    }
                    return MessageBubble(message: messages[index]);
                  },
                ),
        ),

        // Quick actions
        _buildQuickActions(),

        // Input field
        _buildInputField(),
      ],
    ),
  );
}
```

**เพิ่ม method `_buildTypingIndicator`:**

```dart
Widget _buildTypingIndicator() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.primary,
          child: const Text('🤖', style: TextStyle(fontSize: 14)),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDot(0),
              const SizedBox(width: 4),
              _buildDot(1),
              const SizedBox(width: 4),
              _buildDot(2),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildDot(int index) {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: Duration(milliseconds: 600 + (index * 200)),
    builder: (context, value, child) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: AppColors.textSecondary.withOpacity(0.3 + (value * 0.7)),
          shape: BoxShape.circle,
        ),
      );
    },
  );
}
```

---

## ขั้นตอนที่ 5: ตรวจสอบ Imports

**ตรวจสอบว่า `chat_screen.dart` มี import ครบ:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
```

---

## ขั้นตอนที่ 6: ทดสอบ

```bash
flutter run
```

**ทดสอบ scenarios ต่อไปนี้:**

| พิมพ์ | ผลที่คาดหวัง |
|-------|-------------|
| "กินข้าวผัด 500 แคล" | สร้าง FoodEntry + แสดง confirmation |
| "จ่ายค่ากาแฟ 65 บาท" | สร้าง Transaction (expense) + แสดง confirmation |
| "ได้เงินเดือน 45000" | สร้าง Transaction (income) + แสดง confirmation |
| "พรุ่งนี้ประชุม 14:00" | สร้าง Task + แสดง confirmation |
| "วันนี้นัดหมอ 10 โมง" | สร้าง Task + แสดง confirmation |
| "สวัสดี" | แสดง greeting message |

---

## ✅ Checklist

- [ ] สร้าง `action_result.dart` แล้ว
- [ ] สร้าง `intent_handler.dart` แล้ว
- [ ] อัปเดต `chat_provider.dart` แล้ว
- [ ] อัปเดต `chat_screen.dart` เพิ่ม loading แล้ว
- [ ] ทดสอบ "กินข้าวผัด 500 แคล" → สร้าง FoodEntry
- [ ] ทดสอบ "จ่ายค่ากาแฟ 65 บาท" → สร้าง Transaction
- [ ] ทดสอบ "พรุ่งนี้ประชุม 14:00" → สร้าง Task
- [ ] ตรวจสอบข้อมูลในหน้า Health/Finance/Tasks ว่าแสดงถูกต้อง

---

## ไฟล์ที่สร้าง/แก้ไขในขั้นตอนนี้

```
lib/features/chat/
├── models/
│   └── action_result.dart      ← NEW
├── services/
│   └── intent_handler.dart     ← NEW
├── providers/
│   └── chat_provider.dart      ← UPDATED
└── presentation/
    └── chat_screen.dart        ← UPDATED
```

---

## ⚠️ Troubleshooting

### Error: "type 'Null' is not a subtype of type 'String'"
- ตรวจสอบว่า AI ตอบ JSON ถูกต้องหรือไม่
- เพิ่ม null check ใน `_handleHealth`, `_handleFinance`, `_handleTask`

### Error: Database not found
- ตรวจสอบว่า `DatabaseService` มี getter สำหรับ `foodEntries`, `transactions`, `tasks`

### ข้อมูลไม่แสดงในหน้า Health/Finance
- ตรวจสอบว่า provider ใช้ `watch` ไม่ใช่ `read`
- ลอง hot restart แทน hot reload

---

## ขั้นตอนถัดไป

ไป **Step 12: Google Calendar Sync** เพื่อ sync Task ไป Google Calendar อัตโนมัติ
