# Phase 2 Task 1: Smart Greeting เมื่อเปลี่ยนไป Miro AI

## เป้าหมาย
แสดง greeting message อัตโนมัติเมื่อ user สลับไปใช้ Miro AI พร้อมแสดงข้อมูล calories ที่เหลือ

## ตัวอย่าง Greeting
```
🤖 Hi! You have 1,200 kcal left for today.
   Ready to log your meals? 😊

   [📝 Log Food]  [🍽️ Suggest Menu]  [📊 Weekly Summary]
```

## ขั้นตอน

### 1. เปิดไฟล์
ตำแหน่ง: `lib/features/chat/presentation/chat_screen.dart`

### 2. เพิ่ม import

```dart
import 'package:miro/features/health/providers/health_provider.dart';
```

### 3. เพิ่ม listener สำหรับเช็คเมื่อเปลี่ยน AI mode

ใน `initState()` เพิ่ม:

```dart
@override
void initState() {
  super.initState();
  
  // Existing code...
  
  // Listen for AI mode changes
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.listen<ChatAiMode>(
      chatAiModeProvider,
      (previous, next) {
        if (previous == ChatAiMode.local && next == ChatAiMode.miroAi) {
          // Switched to Miro AI → Show greeting
          _showMiroAiGreeting();
        }
      },
    );
  });
}
```

### 4. เพิ่ม method `_showMiroAiGreeting()`

```dart
/// Show smart greeting when switching to Miro AI
Future<void> _showMiroAiGreeting() async {
  try {
    // Get today's calories
    final todayCalories = ref.read(todayCaloriesProvider);
    final healthGoal = ref.read(healthGoalProvider);
    final targetCalories = healthGoal?.targetCalories ?? 2000;
    
    // Calculate remaining
    final remaining = targetCalories - todayCalories;
    
    // Build greeting message
    String greeting;
    if (todayCalories == 0) {
      greeting = '🤖 Hi! No food logged yet today.\n'
          '   Target: ${targetCalories.toStringAsFixed(0)} kcal — Ready to start logging? 🍽️';
    } else if (remaining > 0) {
      greeting = '🤖 Hi! You have ${remaining.toStringAsFixed(0)} kcal left for today.\n'
          '   Ready to log your meals? 😊';
    } else {
      greeting = '🤖 Hi! You\'ve consumed ${todayCalories.toStringAsFixed(0)} kcal today.\n'
          '   ${(-remaining).toStringAsFixed(0)} kcal over target — Let\'s keep tracking! 💪';
    }
    
    // Add greeting message
    final greetingMsg = ChatMessage(
      text: greeting,
      isUser: false,
      timestamp: DateTime.now(),
    );
    
    ref.read(chatNotifierProvider.notifier).addMessage(greetingMsg);
    
  } catch (e) {
    // Fallback greeting
    final fallbackMsg = ChatMessage(
      text: '🤖 Hi! Ready to log your meals? 😊',
      isUser: false,
      timestamp: DateTime.now(),
    );
    ref.read(chatNotifierProvider.notifier).addMessage(fallbackMsg);
  }
}
```

### 5. เพิ่ม helper method ใน `ChatNotifier` (ถ้ายังไม่มี)

เปิดไฟล์: `lib/features/chat/providers/chat_provider.dart`

เพิ่ม method:

```dart
/// Add a message to chat (for system messages like greeting)
void addMessage(ChatMessage message) {
  state = [...state, message];
}
```

## อธิบาย

### Greeting แบ่งเป็น 3 กรณี:

1. **ยังไม่มีรายการอาหาร** (todayCalories = 0)
   ```
   🤖 Hi! No food logged yet today.
      Target: 2,000 kcal — Ready to start logging? 🍽️
   ```

2. **ยังเหลือ calories** (remaining > 0)
   ```
   🤖 Hi! You have 1,200 kcal left for today.
      Ready to log your meals? 😊
   ```

3. **ทานเกินเป้า** (remaining < 0)
   ```
   🤖 Hi! You've consumed 2,500 kcal today.
      500 kcal over target — Let's keep tracking! 💪
   ```

## ทดสอบ
1. เริ่มที่ Local AI
2. กดสลับไป Miro AI
3. ควรเห็น greeting message ปรากฏอัตโนมัติ
4. ลองสลับกลับไป Local AI แล้วสลับกลับมา Miro AI อีกครั้ง → greeting จะแสดงอีกครั้ง

## หมายเหตุ
- Greeting แสดงเฉพาะเมื่อ **สลับจาก Local → Miro** เท่านั้น
- ไม่แสดงเมื่อเปิด app ครั้งแรก (ถ้าเริ่มที่ Miro AI อยู่แล้ว)
- ใช้ภาษาอังกฤษทั้งหมด

## เสร็จแล้ว
✅ Task 1 เสร็จ — Smart Greeting สำเร็จ
➡️ ไปต่อ Task 2: `02_PHASE2_TASK2_quick_faq_buttons.md`
