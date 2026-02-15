# Phase 4 Task 1: Menu Suggestion (Miro AI)

## เป้าหมาย
เพิ่มฟีเจอร์แนะนำเมนูอาหารจาก AI (ใช้ 1 Energy)

## ตัวอย่าง Output
```
🤖 Based on your food log, here are 3 meal suggestions:

1. 🥗 Grilled Chicken Salad (~350 kcal)
   P: 35g | C: 20g | F: 12g
   
2. 🍱 Brown Rice + Grilled Fish (~450 kcal)
   P: 28g | C: 50g | F: 15g
   
3. 🥚 2 Boiled Eggs + Whole Wheat Bread (~280 kcal)
   P: 18g | C: 30g | F: 10g

Pick one and I'll log it for you! 😊
```

## ขั้นตอน

### 1. แก้ไข Backend Function

เปิดไฟล์: `functions/index.js`

### 2. เพิ่ม type 'menu_suggestion' ใน prompt handling

หาส่วนที่จัดการ prompt และเพิ่ม:

```javascript
if (type === 'menu_suggestion') {
  // NEW: Menu suggestion
  prompt = `You are Miro, a friendly nutrition assistant.

The user wants meal suggestions.

Context:
- Recent food log: ${text} (last few days)
- Remaining calories for today: (if provided)
- User's typical cuisine: (detect from past meals)

Suggest 3 meal ideas that:
1. Fit their remaining calorie budget (or ~300-500 kcal range)
2. Match their cuisine preference
3. Are balanced (good protein, reasonable carbs/fat)

For each meal:
- Give a descriptive name
- Estimate calories, protein, carbs, fat
- Make it appealing and practical

IMPORTANT: Respond in ENGLISH only.

Return JSON:
{
  "type": "menu_suggestion",
  "suggestions": [
    {
      "name": "Grilled Chicken Salad",
      "emoji": "🥗",
      "calories": 350,
      "protein": 35,
      "carbs": 20,
      "fat": 12
    }
  ],
  "reply": "Based on your food log, here are 3 meal suggestions..."
}`;

} else if (type === 'chat') {
  // ... existing code
```

### 3. อัปเดต input validation

```javascript
if (type === 'menu_suggestion' && !text) {
  return res.status(400).json({ 
    error: 'Missing text (recent food context) for menu_suggestion' 
  });
}
```

### 4. สร้าง method ใน GeminiChatService

เปิดไฟล์: `lib/core/ai/gemini_chat_service.dart`

เพิ่ม method:

```dart
/// Get menu suggestions from Miro AI (costs 1 Energy)
static Future<Map<String, dynamic>> getMenuSuggestions({
  required String recentFoodContext,
}) async {
  try {
    final deviceId = await DeviceIdService.getDeviceId();

    final response = await http.post(
      Uri.parse(_functionUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'type': 'menu_suggestion',
        'text': recentFoodContext,
        'deviceId': deviceId,
      }),
    ).timeout(
      const Duration(seconds: 60),
      onTimeout: () {
        throw Exception('Request timeout');
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data as Map<String, dynamic>;
    } else if (response.statusCode == 429) {
      throw Exception('Energy depleted. Please purchase more Energy from the store.');
    } else {
      throw Exception('Failed to get menu suggestions: ${response.statusCode}');
    }
  } catch (e) {
    rethrow;
  }
}
```

### 5. แก้ไข Quick Action "Suggest Menu" ใน ChatScreen

เปิดไฟล์: `lib/features/chat/presentation/chat_screen.dart`

หา method `_buildMiroAiActions()` และแก้ปุ่ม "Suggest Menu":

```dart
_buildActionChip(
  icon: '🍽️',
  label: 'Suggest Menu',
  action: () => _requestMenuSuggestion(),
  energyCost: 1,
),
```

### 6. เพิ่ม method `_requestMenuSuggestion()`

```dart
/// Request menu suggestions from Miro AI (costs 1 Energy)
Future<void> _requestMenuSuggestion() async {
  // Check Energy
  final energyService = ref.read(energyServiceProvider);
  final balance = await energyService.getEnergyBalance();
  
  if (balance < 1) {
    final errorMsg = ChatMessage(
      text: '❌ Not enough Energy. Please purchase more from the store.',
      isUser: false,
      timestamp: DateTime.now(),
    );
    ref.read(chatNotifierProvider.notifier).addMessage(errorMsg);
    return;
  }
  
  // Show loading
  final loadingMsg = ChatMessage(
    text: '🤖 Thinking of great meal ideas for you...',
    isUser: false,
    timestamp: DateTime.now(),
  );
  ref.read(chatNotifierProvider.notifier).addMessage(loadingMsg);
  
  try {
    // Get recent food context (last 7 days)
    final allEntries = ref.read(healthNotifierProvider);
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    final recentEntries = allEntries.where((entry) {
      return entry.timestamp.isAfter(weekAgo);
    }).toList();
    
    // Build context string
    String context = 'Recent meals: ';
    if (recentEntries.isEmpty) {
      context += 'No recent food logged.';
    } else {
      final foodNames = recentEntries.map((e) => e.foodName).take(10).join(', ');
      context += foodNames;
    }
    
    // Get today's remaining calories
    final todayCalories = ref.read(todayCaloriesProvider);
    final healthGoal = ref.read(healthGoalProvider);
    final targetCalories = healthGoal?.targetCalories ?? 2000;
    final remaining = targetCalories - todayCalories;
    
    context += '. Remaining calories today: ${remaining.toStringAsFixed(0)} kcal.';
    
    // Call AI
    final response = await GeminiChatService.getMenuSuggestions(
      recentFoodContext: context,
    );
    
    // Remove loading message
    final currentMessages = ref.read(chatNotifierProvider);
    ref.read(chatNotifierProvider.notifier).state = 
        currentMessages.where((msg) => msg != loadingMsg).toList();
    
    // Parse and display suggestions
    await _displayMenuSuggestions(response);
    
    // Deduct Energy
    await energyService.refreshBalance();
    
  } catch (e) {
    // Remove loading message
    final currentMessages = ref.read(chatNotifierProvider);
    ref.read(chatNotifierProvider.notifier).state = 
        currentMessages.where((msg) => msg != loadingMsg).toList();
    
    // Show error
    final errorMsg = ChatMessage(
      text: '❌ Failed to get menu suggestions: ${e.toString()}',
      isUser: false,
      timestamp: DateTime.now(),
    );
    ref.read(chatNotifierProvider.notifier).addMessage(errorMsg);
  }
}

/// Display menu suggestions
Future<void> _displayMenuSuggestions(Map<String, dynamic> response) async {
  if (response['type'] != 'menu_suggestion') {
    throw Exception('Invalid response type');
  }
  
  final suggestions = response['suggestions'] as List<dynamic>?;
  if (suggestions == null || suggestions.isEmpty) {
    throw Exception('No suggestions returned');
  }
  
  // Build message
  final buffer = StringBuffer();
  buffer.writeln('🤖 Based on your food log, here are 3 meal suggestions:\n');
  
  int index = 1;
  for (final suggestion in suggestions) {
    final name = suggestion['name'] as String;
    final emoji = suggestion['emoji'] as String? ?? '🍽️';
    final calories = suggestion['calories'] as num;
    final protein = suggestion['protein'] as num;
    final carbs = suggestion['carbs'] as num;
    final fat = suggestion['fat'] as num;
    
    buffer.writeln('$index. $emoji $name (~${calories.toStringAsFixed(0)} kcal)');
    buffer.writeln('   P: ${protein}g | C: ${carbs}g | F: ${fat}g');
    if (index < suggestions.length) buffer.writeln();
    index++;
  }
  
  buffer.writeln('\nPick one and I\'ll log it for you! 😊');
  buffer.writeln('\n⚡ -1 Energy');
  
  // Add message
  final message = ChatMessage(
    text: buffer.toString(),
    isUser: false,
    timestamp: DateTime.now(),
  );
  ref.read(chatNotifierProvider.notifier).addMessage(message);
}
```

## อธิบาย

### Flow:
1. User กดปุ่ม "🍽️ Suggest Menu"
2. เช็ค Energy >= 1
3. ดึงรายการอาหาร 7 วันล่าสุด + remaining calories
4. ส่งไป Gemini Backend (type: 'menu_suggestion')
5. แสดงผล 3 เมนูแนะนำ
6. หัก 1 Energy

### Energy Cost:
- **1 Energy** per request
- แสดงเป็น "⚡ -1 Energy" ใน response

## ทดสอบ
1. เลือก Miro AI mode
2. กดปุ่ม "🍽️ Suggest Menu"
3. รอ AI ประมวลผล (~5-10 วินาที)
4. เห็นเมนู 3 รายการพร้อม nutrition info
5. Energy balance ลดลง 1

## เสร็จแล้ว
✅ Task 1 เสร็จ — Menu Suggestion สำเร็จ
➡️ ไปต่อ Task 2: `04_PHASE4_TASK2_terms_update.md`
