# Phase 1 Task 6: แก้ไข ChatNotifier.sendMessage()

## เป้าหมาย
แยก flow การส่งข้อความตาม AI mode ที่เลือก

## ขั้นตอน

### 1. เปิดไฟล์
ตำแหน่ง: `lib/features/chat/providers/chat_provider.dart`

### 2. เพิ่ม import

```dart
import 'package:miro/core/ai/gemini_chat_service.dart';
import 'package:miro/core/services/energy_service.dart';
```

### 3. หา method `sendMessage()` ใน `ChatNotifier` class

### 4. แก้ไขทั้งหมดเป็น:

```dart
Future<void> sendMessage(String text) async {
  if (text.trim().isEmpty) return;

  // Get current AI mode
  final aiMode = ref.read(chatAiModeProvider);
  
  // Add user message
  final userMsg = ChatMessage(
    text: text,
    isUser: true,
    timestamp: DateTime.now(),
  );
  state = [...state, userMsg];

  try {
    // Check AI mode and route accordingly
    if (aiMode == ChatAiMode.local) {
      // LOCAL AI — Free, no Energy cost
      await _handleLocalAi(text);
    } else {
      // MIRO AI — 1 Energy cost
      await _handleMiroAi(text);
    }
  } catch (e) {
    // Show error message
    final errorMsg = ChatMessage(
      text: 'Error: ${e.toString()}',
      isUser: false,
      timestamp: DateTime.now(),
    );
    state = [...state, errorMsg];
  }
}

/// Handle Local AI (existing flow)
Future<void> _handleLocalAi(String text) async {
  // Use existing LLMService local fallback
  final llmService = ref.read(llmServiceProvider);
  final processor = ref.read(chatProcessorProvider);
  
  final result = await llmService.processUserMessage(text);
  
  // Process with IntentHandler
  await processor.processIntent(
    intent: result['intent'] as String,
    entities: result['entities'] as Map<String, dynamic>,
  );
  
  // Add response message
  final response = result['response'] as String? ?? 'Message received';
  final botMsg = ChatMessage(
    text: response,
    isUser: false,
    timestamp: DateTime.now(),
  );
  state = [...state, botMsg];
}

/// Handle Miro AI (new flow)
Future<void> _handleMiroAi(String text) async {
  // Check Energy balance
  final energyService = ref.read(energyServiceProvider);
  final balance = await energyService.getEnergyBalance();
  
  if (balance < 1) {
    throw Exception('Not enough Energy. Please purchase more from the store.');
  }
  
  // Call Gemini Backend
  final response = await GeminiChatService.analyzeChatMessage(
    message: text,
  );
  
  // Deduct Energy (done by backend, but we confirm here)
  // Backend already deducted, so we just refresh balance
  await energyService.refreshBalance();
  
  // Parse response and save food entries
  await _parseMiroAiResponse(response);
  
  // Add bot reply
  final reply = response['reply'] as String? ?? 'Message received';
  final botMsg = ChatMessage(
    text: '$reply\n\n⚡ -1 Energy',
    isUser: false,
    timestamp: DateTime.now(),
  );
  state = [...state, botMsg];
}

/// Parse Miro AI response and save food entries
Future<void> _parseMiroAiResponse(Map<String, dynamic> response) async {
  if (response['type'] != 'food_log') return;
  
  final items = response['items'] as List<dynamic>?;
  if (items == null || items.isEmpty) return;
  
  final healthNotifier = ref.read(healthNotifierProvider.notifier);
  
  for (final item in items) {
    final foodEntry = FoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString() + 
          items.indexOf(item).toString(),
      foodName: item['food_name'] as String,
      foodNameLocal: item['food_name_local'] as String?,
      servingSize: (item['serving_size'] as num?)?.toDouble() ?? 1.0,
      servingUnit: item['serving_unit'] as String? ?? 'serving',
      calories: (item['calories'] as num?)?.toDouble() ?? 0,
      protein: (item['protein'] as num?)?.toDouble() ?? 0,
      carbs: (item['carbs'] as num?)?.toDouble() ?? 0,
      fat: (item['fat'] as num?)?.toDouble() ?? 0,
      mealType: item['meal_type'] as String? ?? 'snack',
      timestamp: DateTime.now(),
      source: 'chat',
    );
    
    await healthNotifier.addFoodEntry(foodEntry);
  }
}
```

## อธิบายการทำงาน

### Flow Diagram
```
User sends message
       ↓
Check AI Mode
    ↙        ↘
LOCAL AI    MIRO AI
(Free)      (1 Energy)
    ↓            ↓
LLMService   Check Energy >= 1?
    ↓            ↓
IntentHandler   Call Gemini
    ↓            ↓
Single item   Parse items[]
    ↓            ↓
Save entry    Save entries[]
    ↓            ↓
Show reply    Show reply + "⚡ -1 Energy"
```

### Key Points
1. **Local AI** = ฟรี, ใช้ flow เดิม (LLMService + IntentHandler)
2. **Miro AI** = 1 Energy, call Backend → parse multi-food → save
3. **Energy check** ทำก่อนส่ง (ถ้าไม่พอ → throw error)
4. **Reply message** แสดง "⚡ -1 Energy" ให้ user เห็น

## ทดสอบ
1. เลือก Local AI → พิมพ์ "chicken 100g" → ควรได้ reply ฟรี
2. เลือก Miro AI → พิมพ์ "I ate pizza 2 slices and salad" → ควรแยกเป็น 2 items + แสดง "⚡ -1 Energy"
3. Miro AI + Energy = 0 → ควรแสดง error "Not enough Energy"

## เสร็จแล้ว
✅ Task 6 เสร็จ — Core flow เสร็จสมบูรณ์!
➡️ ไปต่อ Task 7: `01_PHASE1_TASK7_energy_indicator.md`
