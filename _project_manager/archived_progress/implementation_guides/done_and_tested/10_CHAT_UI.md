# Step 10: Chat UI & Basic Intent Detection

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 2 ชั่วโมง
> **ความยาก:** ยาก
> **ต้องทำก่อน:** Step 01 (Core Models), Step 07 (Gemini Service)

---

## สิ่งที่ต้องทำ

1. สร้าง Chat Provider
2. สร้าง Chat Screen UI
3. สร้าง Message Bubble Widgets
4. สร้าง Intent Detector (Keyword-based)
5. เชื่อมต่อกับ Magic Button

---

## ขั้นตอนที่ 1: สร้าง Chat Provider

**สร้างไฟล์:** `lib/features/chat/providers/chat_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/database_service.dart';
import '../models/chat_message.dart';

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

// Chat notifier
class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref ref;
  
  ChatNotifier(this.ref) : super([]);

  Future<void> sendMessage(String content) async {
    final sessionId = ref.read(currentSessionIdProvider);
    
    // Create user message
    final userMessage = ChatMessage()
      ..sessionId = sessionId
      ..role = MessageRole.user
      ..content = content;

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.chatMessages.put(userMessage);
    });

    state = [...state, userMessage];

    // Process and generate response
    await _generateResponse(content);
  }

  Future<void> _generateResponse(String userMessage) async {
    final sessionId = ref.read(currentSessionIdProvider);
    
    // Simple keyword-based response for now
    final response = _processMessage(userMessage);
    
    final assistantMessage = ChatMessage()
      ..sessionId = sessionId
      ..role = MessageRole.assistant
      ..content = response
      ..detectedIntent = _detectIntent(userMessage);

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.chatMessages.put(assistantMessage);
    });

    state = [...state, assistantMessage];
  }

  String _processMessage(String message) {
    final lower = message.toLowerCase();
    
    // Health intents
    if (lower.contains('กิน') || lower.contains('อาหาร') || lower.contains('แคล')) {
      return '🍽️ ต้องการบันทึกอาหารหรือเปล่า?\n\nลองบอกว่า:\n• "กินข้าวผัด 500 แคล"\n• "มื้อเที่ยง ส้มตำ 150 kcal"';
    }
    
    if (lower.contains('ออกกำลัง') || lower.contains('workout') || lower.contains('วิ่ง')) {
      return '🏃 ต้องการบันทึกการออกกำลังกายหรือเปล่า?\n\nลองบอกว่า:\n• "วิ่ง 3 กม. 30 นาที"\n• "ขอโปรแกรม workout วันนี้"';
    }
    
    if (lower.contains('น้ำหนัก') || lower.contains('ชั่ง')) {
      return '⚖️ ต้องการบันทึกน้ำหนักหรือเปล่า?\n\nลองบอกว่า:\n• "น้ำหนัก 72 กก."';
    }
    
    // Finance intents
    if (lower.contains('จ่าย') || lower.contains('ซื้อ') || lower.contains('บาท')) {
      return '💰 ต้องการบันทึกรายจ่ายหรือเปล่า?\n\nลองบอกว่า:\n• "จ่ายค่ากาแฟ 65 บาท"\n• "ซื้อของ 500 บาท หมวด shopping"';
    }
    
    if (lower.contains('เงินเดือน') || lower.contains('รายได้') || lower.contains('ได้เงิน')) {
      return '💵 ต้องการบันทึกรายรับหรือเปล่า?\n\nลองบอกว่า:\n• "ได้เงินเดือน 45000"\n• "รายได้ freelance 5000"';
    }
    
    if (lower.contains('บิล') || lower.contains('ถึงกำหนด')) {
      return '💳 ฟีเจอร์บิลยังอยู่ในระหว่างพัฒนา\n\nเร็วๆ นี้คุณจะสามารถ:\n• ดูบิลที่จะถึงกำหนด\n• ตั้งเตือนจ่ายบิล';
    }
    
    if (lower.contains('หุ้น') || lower.contains('พอร์ต') || lower.contains('ลงทุน')) {
      return '📈 ฟีเจอร์สินทรัพย์ยังอยู่ในระหว่างพัฒนา\n\nเร็วๆ นี้คุณจะสามารถ:\n• ติดตามพอร์ตหุ้น/กองทุน\n• ดูราคาหุ้นอัตโนมัติ';
    }
    
    // Task intents
    if (lower.contains('ประชุม') || lower.contains('นัด') || lower.contains('meeting')) {
      return '📅 ต้องการสร้างนัดหมายหรือเปล่า?\n\nลองบอกว่า:\n• "พรุ่งนี้ประชุม 14:00"\n• "นัดหมอ วันศุกร์ 10 โมง"';
    }
    
    if (lower.contains('จด') || lower.contains('รายการ') || lower.contains('todo')) {
      return '📝 ต้องการสร้าง list หรือเปล่า?\n\nลองบอกว่า:\n• "รายการซื้อของ: นม ไข่ ผัก"\n• "จด เบอร์ช่างแอร์ 081-xxx-xxxx"';
    }
    
    // Greeting
    if (lower.contains('สวัสดี') || lower.contains('hello') || lower.contains('hi')) {
      return '👋 สวัสดีครับ! ผม Miro พร้อมช่วยคุณจัดการชีวิตประจำวัน\n\n🍽️ **สุขภาพ** - บันทึกอาหาร ออกกำลังกาย\n💰 **การเงิน** - บันทึกรายรับ-รายจ่าย\n📅 **งาน** - สร้าง task นัดหมาย\n\nลองพิมพ์หรือพูดได้เลยครับ!';
    }
    
    if (lower.contains('ช่วย') || lower.contains('ทำอะไรได้')) {
      return '🤖 Miro สามารถช่วยคุณได้หลายอย่าง:\n\n**🍎 สุขภาพ**\n• บันทึกอาหาร + แคลอรี่\n• บันทึกการออกกำลังกาย\n• ติดตามน้ำหนัก\n\n**💰 การเงิน**\n• บันทึกรายรับ-รายจ่าย\n• ถ่ายรูปสลิป\n\n**📅 งาน**\n• สร้างนัดหมาย\n• สร้าง todo list\n\nลองพิมพ์ได้เลยครับ!';
    }
    
    // Default
    return '🤔 ผมยังไม่เข้าใจนะครับ\n\nลองบอกเรื่องเกี่ยวกับ:\n• 🍽️ อาหาร/แคลอรี่\n• 🏃 ออกกำลังกาย\n• 💰 รายรับ-รายจ่าย\n• 📅 นัดหมาย/task\n\nหรือพิมพ์ "ช่วย" เพื่อดูว่าทำอะไรได้บ้าง';
  }

  String _detectIntent(String message) {
    final lower = message.toLowerCase();
    
    if (lower.contains('กิน') || lower.contains('อาหาร')) return 'log_food';
    if (lower.contains('ออกกำลัง') || lower.contains('workout')) return 'log_workout';
    if (lower.contains('จ่าย') || lower.contains('ซื้อ')) return 'log_expense';
    if (lower.contains('ประชุม') || lower.contains('นัด')) return 'create_task';
    if (lower.contains('สวัสดี')) return 'greeting';
    
    return 'unknown';
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

## ขั้นตอนที่ 2: เพิ่ม UUID Package

```bash
flutter pub add uuid
```

---

## ขั้นตอนที่ 3: สร้าง Message Bubble Widget

**สร้างไฟล์:** `lib/features/chat/widgets/message_bubble.dart`

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: const Text(
                '🤖',
                style: TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : AppColors.surfaceVariant,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isUser ? Colors.white : AppColors.textPrimary,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryLight,
              child: const Icon(
                Icons.person,
                size: 18,
                color: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
```

---

## ขั้นตอนที่ 4: สร้าง Chat Screen

**สร้างไฟล์:** `lib/features/chat/presentation/chat_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _isComposing = _controller.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatNotifierProvider);

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
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
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

  Widget _buildWelcomeScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🤖',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            const Text(
              'สวัสดีครับ!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ผม Miro พร้อมช่วยคุณจัดการชีวิตประจำวัน\nลองพิมพ์หรือเลือก Quick Action ด้านล่าง',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildQuickActionChip('🍔 บันทึกอาหาร', 'กินอะไรดี'),
          _buildQuickActionChip('🏃 Workout', 'ขอโปรแกรม workout วันนี้'),
          _buildQuickActionChip('💰 รายจ่าย', 'จ่ายค่าอะไร'),
          _buildQuickActionChip('📅 Task', 'พรุ่งนี้มีนัดอะไร'),
          _buildQuickActionChip('❓ ช่วยอะไรได้', 'ช่วยอะไรได้บ้าง'),
        ],
      ),
    );
  }

  Widget _buildQuickActionChip(String label, String message) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label),
        onPressed: () => _sendMessage(message),
      ),
    );
  }

  Widget _buildInputField() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'พิมพ์ข้อความ...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => _sendCurrentMessage(),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: IconButton(
                onPressed: _isComposing ? _sendCurrentMessage : null,
                icon: Icon(
                  Icons.send,
                  color: _isComposing ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;

    ref.read(chatNotifierProvider.notifier).sendMessage(message);
    _controller.clear();
  }

  void _sendCurrentMessage() {
    _sendMessage(_controller.text);
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ล้างประวัติ?'),
        content: const Text('ข้อความทั้งหมดจะถูกลบ'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () {
              ref.read(chatNotifierProvider.notifier).clearMessages();
              Navigator.pop(context);
            },
            child: const Text('ล้าง'),
          ),
        ],
      ),
    );
  }
}
```

---

## ขั้นตอนที่ 5: เชื่อมต่อกับ Magic Button

**แก้ไขไฟล์:** `lib/features/home/widgets/magic_button.dart`

**เพิ่ม import:**

```dart
import '../../chat/presentation/chat_screen.dart';
```

**แก้ไข method `_openChat`:**

```dart
void _openChat(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ChatScreen()),
  );
}
```

---

## ขั้นตอนที่ 6: ทดสอบ

```bash
flutter run
```

**ผลที่ควรได้:**
- กดปุ่ม ✨ → Chat AI → เปิดหน้า Chat
- พิมพ์ข้อความ → ได้ response จาก bot
- Quick Actions ทำงานได้
- ล้างประวัติ chat ได้

---

## ✅ Checklist

- [ ] เพิ่ม uuid package แล้ว
- [ ] สร้าง chat_provider.dart แล้ว
- [ ] สร้าง message_bubble.dart แล้ว
- [ ] สร้าง chat_screen.dart แล้ว
- [ ] เชื่อมต่อกับ magic_button.dart แล้ว
- [ ] ทดสอบส่งข้อความได้
- [ ] ทดสอบ Quick Actions ได้

---

## ไฟล์ที่สร้าง/แก้ไขในขั้นตอนนี้

```
lib/features/
├── chat/
│   ├── presentation/
│   │   └── chat_screen.dart      ← NEW
│   ├── providers/
│   │   └── chat_provider.dart    ← NEW
│   └── widgets/
│       └── message_bubble.dart   ← NEW
└── home/
    └── widgets/
        └── magic_button.dart     ← UPDATED
```

---

## ขั้นตอนถัดไป

- ปรับปรุง Intent Detection ให้ใช้ AI จริง
- เพิ่ม Action Cards ใน response
- เชื่อมต่อ actions กับการบันทึกข้อมูลจริง
