# Miro Chat Integration - Detailed Design

> **โฟกัส:** สร้าง Chat ที่เข้าใจ Health, Finance, Tasks
> **อ้างอิง:** Sentina Chat System (life_detector, context_builder)
> **หลักการ:** Local AI First, Cloud AI Last

---

## 1. Chat Architecture

### 1.1 Overview

```
┌─────────────────────────────────────────────────┐
│                                                 │
│  MIRO CHAT ARCHITECTURE                         │
│  ═══════════════════════════════════════════   │
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │  User Input (text / voice / image)      │   │
│  └────────────────────┬────────────────────┘   │
│                       │                         │
│                       ▼                         │
│  ┌─────────────────────────────────────────┐   │
│  │  Intent Detector (Local AI)             │   │
│  │  ├─ Keyword Detection (fast)            │   │
│  │  └─ Gemma 3 Analysis (if needed)        │   │
│  └────────────────────┬────────────────────┘   │
│                       │                         │
│          ┌────────────┼────────────┐            │
│          ▼            ▼            ▼            │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐        │
│  │ Health   │ │ Finance  │ │  Task    │        │
│  │ Handler  │ │ Handler  │ │ Handler  │        │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘        │
│       │            │            │               │
│       └────────────┼────────────┘               │
│                    ▼                            │
│  ┌─────────────────────────────────────────┐   │
│  │  Context Builder                        │   │
│  │  (User Profile + History + Data)        │   │
│  └────────────────────┬────────────────────┘   │
│                       │                         │
│                       ▼                         │
│  ┌─────────────────────────────────────────┐   │
│  │  Response Generator (Local LLM)         │   │
│  └────────────────────┬────────────────────┘   │
│                       │                         │
│                       ▼                         │
│  ┌─────────────────────────────────────────┐   │
│  │  Intent Card / Response                 │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

## 2. Intent Detection (Local AI First)

### 2.1 Intent Types

```dart
enum IntentType {
  // Health Intents
  logFood,              // "กินข้าวผัด 500 แคล"
  logWorkout,           // "วิ่ง 3 กม."
  logWeight,            // "ชั่งน้ำหนักได้ 72 กก."
  logWater,             // "ดื่มน้ำ 2 แก้ว"
  logMedicine,          // "กินยาแล้ว"
  askTodayWorkout,      // "ขอโปรแกรมออกกำลังวันนี้"
  askHealthSummary,     // "สรุปสุขภาพสัปดาห์นี้"
  askLabResults,        // "ผลตรวจสุขภาพล่าสุด"
  
  // Finance Intents
  logExpense,           // "จ่ายค่ากาแฟ 65 บาท"
  logIncome,            // "ได้เงินเดือน 45000"
  askBillsDue,          // "บิลอะไรจะถึงกำหนด"
  askSpendingSummary,   // "เดือนนี้ใช้ไปเท่าไหร่"
  askPortfolio,         // "พอร์ตหุ้นเป็นยังไง"
  searchAsset,          // "หาหุ้น PTT"
  
  // Task Intents
  createTask,           // "พรุ่งนี้ประชุม 2 โมง"
  createTodoList,       // "จดรายการซื้อของ: นม ไข่ ผัก"
  createNote,           // "จดเบอร์ช่างแอร์ 081-xxx"
  askTodayTasks,        // "วันนี้มีอะไรบ้าง"
  completeTask,         // "ทำเสร็จแล้ว"
  
  // General
  greeting,             // "สวัสดี"
  askHelp,              // "ช่วยอะไรได้บ้าง"
  unknown,              // ไม่รู้จัก
}
```

### 2.2 Keyword Detection (Fast - Local)

```dart
class KeywordDetector {
  
  static const Map<IntentType, List<String>> KEYWORDS = {
    // Health - Food
    IntentType.logFood: [
      'กิน', 'ทาน', 'อาหาร', 'kcal', 'แคล', 'แคลอรี่',
      'มื้อเช้า', 'มื้อเที่ยง', 'มื้อเย็น', 'ของว่าง',
    ],
    
    // Health - Workout
    IntentType.logWorkout: [
      'วิ่ง', 'ออกกำลัง', 'ปั่น', 'ว่ายน้ำ', 'โยคะ', 'ยิม',
      'กก.', 'kg', 'เซ็ต', 'รอบ', 'rep',
    ],
    IntentType.askTodayWorkout: [
      'โปรแกรมออกกำลัง', 'workout วันนี้', 'วันนี้ออกกำลัง',
      'ขอโปรแกรม', 'legs day', 'push day', 'pull day',
    ],
    
    // Health - Other
    IntentType.logWeight: ['น้ำหนัก', 'ชั่ง', 'กก.', 'กิโล'],
    IntentType.logWater: ['น้ำ', 'แก้ว', 'ลิตร', 'ดื่ม'],
    IntentType.logMedicine: ['ยา', 'วิตามิน', 'กินยา'],
    
    // Finance
    IntentType.logExpense: [
      'จ่าย', 'ซื้อ', 'ค่า', 'ใช้', 'บาท', '฿',
      'หมด', 'โอน', 'เติม',
    ],
    IntentType.logIncome: [
      'ได้เงิน', 'รับเงิน', 'เงินเดือน', 'โบนัส', 
      'รายได้', 'ปันผล',
    ],
    IntentType.askBillsDue: [
      'บิล', 'ถึงกำหนด', 'ต้องจ่าย', 'ค่าน้ำ', 'ค่าไฟ',
    ],
    IntentType.askPortfolio: [
      'หุ้น', 'พอร์ต', 'กองทุน', 'ทอง', 'ลงทุน',
    ],
    IntentType.searchAsset: [
      'หา', 'ค้นหา', 'ราคา', 'search',
    ],
    
    // Task
    IntentType.createTask: [
      'ประชุม', 'นัด', 'meeting', 'โมง', 'น.', 
      'พรุ่งนี้', 'มะรืน', 'วันที่', 'อาทิตย์หน้า',
    ],
    IntentType.createTodoList: [
      'รายการ', 'list', 'ซื้อของ', 'shopping',
      'จดรายการ', 'to do', 'todo',
    ],
    IntentType.createNote: [
      'จด', 'จำไว้', 'เบอร์', 'บันทึก', 'note',
    ],
  };
  
  IntentType? detectFromKeywords(String message) {
    final messageLower = message.toLowerCase();
    
    for (var entry in KEYWORDS.entries) {
      for (var keyword in entry.value) {
        if (messageLower.contains(keyword.toLowerCase())) {
          return entry.key;
        }
      }
    }
    
    return null;
  }
}
```

### 2.3 Semantic Analysis (Local LLM - Gemma 3)

```dart
class SemanticAnalyzer {
  
  final String SYSTEM_PROMPT = '''
คุณเป็น AI ที่วิเคราะห์ข้อความและจัดหมวดหมู่

วิเคราะห์ข้อความและตอบเป็น JSON:
{
  "intent": "log_food|log_workout|log_expense|create_task|...",
  "category": "health|finance|task|general",
  "confidence": 0.0-1.0,
  "extracted_data": {
    // ข้อมูลที่สกัดได้
  }
}

ตัวอย่าง:
- "กินข้าวผัด 500 แคล" → {"intent": "log_food", "category": "health", "extracted_data": {"food": "ข้าวผัด", "calories": 500}}
- "พรุ่งนี้ประชุม 2 โมง" → {"intent": "create_task", "category": "task", "extracted_data": {"title": "ประชุม", "time": "14:00", "date": "tomorrow"}}
- "จ่ายค่ากาแฟ 65 บาท" → {"intent": "log_expense", "category": "finance", "extracted_data": {"description": "ค่ากาแฟ", "amount": 65}}
''';

  Future<IntentResult> analyze(String message) async {
    // Use on-device Gemma 3
    final result = await localLLM.generate(
      systemPrompt: SYSTEM_PROMPT,
      userMessage: message,
    );
    
    return IntentResult.fromJson(result);
  }
}
```

---

## 3. Context Builder

### 3.1 User Context

```dart
class ContextBuilder {
  
  Future<UserContext> buildContext(String userId) async {
    return UserContext(
      // User Profile
      profile: await getProfile(userId),
      
      // Health Data
      todayCalories: await getTodayCalories(),
      todayMacros: await getTodayMacros(),
      todayWorkout: await getTodayWorkout(),
      lastWeight: await getLastWeight(),
      activeWorkoutProgram: await getActiveProgram(),
      
      // Finance Data
      monthlySpending: await getMonthlySpending(),
      recentTransactions: await getRecentTransactions(limit: 5),
      portfolioSummary: await getPortfolioSummary(),
      upcomingBills: await getUpcomingBills(),
      
      // Task Data
      todayTasks: await getTodayTasks(),
      pendingTasks: await getPendingTasks(),
      habits: await getActiveHabits(),
      
      // Chat History
      recentMessages: await getRecentMessages(limit: 10),
    );
  }
  
  String buildContextString(UserContext ctx) {
    final parts = <String>[];
    
    // User info
    parts.add("=== ข้อมูลผู้ใช้ ===");
    parts.add("ชื่อ: ${ctx.profile.name}");
    
    // Health summary
    parts.add("\n=== สุขภาพวันนี้ ===");
    parts.add("แคลอรี่: ${ctx.todayCalories}/${ctx.calorieTarget} kcal");
    parts.add("Workout: ${ctx.todayWorkout?.name ?? 'ไม่มี'}");
    parts.add("น้ำหนักล่าสุด: ${ctx.lastWeight} kg");
    
    // Finance summary
    parts.add("\n=== การเงินเดือนนี้ ===");
    parts.add("ใช้จ่าย: ฿${ctx.monthlySpending}");
    parts.add("พอร์ต: ${ctx.portfolioSummary.changePercent}%");
    
    // Tasks
    parts.add("\n=== งานวันนี้ ===");
    for (var task in ctx.todayTasks) {
      parts.add("- ${task.title}");
    }
    
    // Recent chat
    parts.add("\n=== ประวัติการสนทนา ===");
    for (var msg in ctx.recentMessages) {
      final role = msg.isUser ? "ผู้ใช้" : "AI";
      parts.add("$role: ${msg.content}");
    }
    
    return parts.join('\n');
  }
}
```

---

## 4. Intent Handlers

### 4.1 Health Intent Handler

```dart
class HealthIntentHandler {
  
  Future<IntentResponse> handle(IntentResult intent, UserContext ctx) async {
    switch (intent.type) {
      
      case IntentType.logFood:
        return handleLogFood(intent.extractedData, ctx);
        
      case IntentType.askTodayWorkout:
        return handleAskTodayWorkout(ctx);
        
      case IntentType.askHealthSummary:
        return handleHealthSummary(ctx);
        
      case IntentType.logWeight:
        return handleLogWeight(intent.extractedData);
        
      default:
        return IntentResponse.unknown();
    }
  }
  
  Future<IntentResponse> handleAskTodayWorkout(UserContext ctx) async {
    final program = ctx.activeWorkoutProgram;
    if (program == null) {
      return IntentResponse.text(
        "คุณยังไม่มีโปรแกรมออกกำลังกาย\nต้องการสร้างโปรแกรมใหม่ไหม?"
      );
    }
    
    final todayWorkout = program.getTodayWorkout();
    if (todayWorkout == null) {
      return IntentResponse.text(
        "วันนี้เป็นวันพัก 😴\nพรุ่งนี้จะเป็น ${program.getTomorrowWorkout()?.name}"
      );
    }
    
    // Get progress from last session
    final lastSession = await getLastSession(todayWorkout.id);
    final exercises = todayWorkout.exercises.map((e) {
      final lastWeight = lastSession?.getWeight(e.id);
      final suggestedWeight = calculateProgressiveOverload(lastWeight);
      
      return ExerciseWithProgress(
        exercise: e,
        lastWeight: lastWeight,
        suggestedWeight: suggestedWeight,
      );
    }).toList();
    
    return IntentResponse.workoutCard(
      workout: todayWorkout,
      exercises: exercises,
      weekNumber: program.currentWeek,
      actions: [
        IntentAction(label: "สร้าง Task List", action: "create_workout_task"),
        IntentAction(label: "เริ่มเลย", action: "start_workout"),
      ],
    );
  }
  
  Future<IntentResponse> handleLogFood(Map data, UserContext ctx) async {
    final foodName = data['food'] as String?;
    final calories = data['calories'] as int?;
    
    // If AI gave us data, show confirmation
    if (foodName != null) {
      return IntentResponse.confirmCard(
        title: "บันทึกอาหาร",
        data: {
          'ชื่ออาหาร': foodName,
          'แคลอรี่': '${calories ?? "?"} kcal',
          'มื้อ': detectMealType(),
        },
        actions: [
          IntentAction(label: "✅ ยืนยัน", action: "confirm_food"),
          IntentAction(label: "✏️ แก้ไข", action: "edit_food"),
        ],
      );
    }
    
    // If not enough data, ask for more
    return IntentResponse.askMore(
      question: "ต้องการบันทึกอาหารอะไร กี่แคลอรี่?",
      examples: ["ข้าวผัด 450 แคล", "สลัด 200 kcal"],
    );
  }
}
```

### 4.2 Finance Intent Handler

```dart
class FinanceIntentHandler {
  
  Future<IntentResponse> handle(IntentResult intent, UserContext ctx) async {
    switch (intent.type) {
      
      case IntentType.logExpense:
        return handleLogExpense(intent.extractedData, ctx);
        
      case IntentType.askBillsDue:
        return handleAskBillsDue(ctx);
        
      case IntentType.askPortfolio:
        return handleAskPortfolio(ctx);
        
      case IntentType.searchAsset:
        return handleSearchAsset(intent.extractedData);
        
      default:
        return IntentResponse.unknown();
    }
  }
  
  Future<IntentResponse> handleAskBillsDue(UserContext ctx) async {
    final bills = ctx.upcomingBills;
    
    if (bills.isEmpty) {
      return IntentResponse.text(
        "ไม่มีบิลที่จะถึงกำหนดในเดือนนี้ 🎉"
      );
    }
    
    final total = bills.fold<double>(0, (sum, b) => sum + b.amount);
    
    return IntentResponse.listCard(
      title: "💳 บิลที่จะถึงกำหนด",
      items: bills.map((b) => ListItem(
        icon: b.icon,
        title: b.name,
        subtitle: "📅 ${formatDate(b.dueDate)}",
        trailing: "฿${formatNumber(b.amount)}",
      )).toList(),
      footer: "💰 รวม: ฿${formatNumber(total)}",
      actions: [
        IntentAction(label: "📋 สร้าง Reminders", action: "create_bill_reminders"),
        IntentAction(label: "➕ เพิ่มบิลใหม่", action: "add_bill"),
      ],
    );
  }
  
  Future<IntentResponse> handleSearchAsset(Map data) async {
    final query = data['query'] as String?;
    if (query == null) {
      return IntentResponse.askMore(
        question: "ต้องการค้นหาหุ้น/กองทุนอะไร?",
        examples: ["PTT", "K-USA", "ทองคำ"],
      );
    }
    
    // Use Sentina's asset search logic
    final results = await searchAsset(query);
    
    if (results.isEmpty) {
      return IntentResponse.text(
        "ไม่พบสินทรัพย์ '$query'\nลองค้นหาด้วยชื่ออื่น"
      );
    }
    
    return IntentResponse.assetSearchCard(
      query: query,
      results: results,
      actions: [
        IntentAction(label: "➕ เพิ่มในพอร์ต", action: "add_to_portfolio"),
      ],
    );
  }
}
```

### 4.3 Task Intent Handler

```dart
class TaskIntentHandler {
  
  Future<IntentResponse> handle(IntentResult intent, UserContext ctx) async {
    switch (intent.type) {
      
      case IntentType.createTask:
        return handleCreateTask(intent.extractedData, ctx);
        
      case IntentType.createTodoList:
        return handleCreateTodoList(intent.extractedData);
        
      case IntentType.askTodayTasks:
        return handleAskTodayTasks(ctx);
        
      default:
        return IntentResponse.unknown();
    }
  }
  
  Future<IntentResponse> handleCreateTask(Map data, UserContext ctx) async {
    final title = data['title'] as String?;
    final date = data['date'] as String?;
    final time = data['time'] as String?;
    
    // Parse date/time
    final parsedDateTime = parseDateTime(date, time);
    
    if (title == null) {
      return IntentResponse.askMore(
        question: "ต้องการสร้างงานอะไร?",
      );
    }
    
    // Determine task type
    TaskType taskType;
    if (parsedDateTime != null) {
      taskType = TaskType.calendarEvent;
    } else {
      taskType = TaskType.todoList;
    }
    
    return IntentResponse.confirmCard(
      title: "📅 สร้างงานใหม่",
      data: {
        'ชื่องาน': title,
        if (parsedDateTime != null) 'วันที่': formatDate(parsedDateTime),
        if (time != null) 'เวลา': time,
        'ประเภท': taskType == TaskType.calendarEvent ? 'Calendar Event' : 'Todo',
      },
      note: taskType == TaskType.calendarEvent 
        ? "📅 จะ sync ไปยัง Google Calendar" 
        : null,
      actions: [
        IntentAction(label: "✅ ยืนยัน", action: "confirm_task"),
        IntentAction(label: "✏️ แก้ไข", action: "edit_task"),
      ],
    );
  }
  
  Future<IntentResponse> handleCreateTodoList(Map data) async {
    final items = data['items'] as List<String>?;
    final title = data['title'] as String? ?? "รายการ";
    
    if (items == null || items.isEmpty) {
      return IntentResponse.askMore(
        question: "มีอะไรในรายการบ้าง?",
        examples: ["นม ไข่ ผัก เนื้อหมู"],
      );
    }
    
    return IntentResponse.confirmCard(
      title: "📝 สร้างรายการ",
      data: {'ชื่อ': title},
      listPreview: items,
      actions: [
        IntentAction(label: "✅ ยืนยัน", action: "confirm_list"),
        IntentAction(label: "✏️ แก้ไข", action: "edit_list"),
      ],
    );
  }
}
```

---

## 5. Intent Response Types

### 5.1 Response Types

```dart
enum IntentResponseType {
  text,           // ข้อความธรรมดา
  confirmCard,    // Card ยืนยัน (พร้อม actions)
  listCard,       // Card แสดง list
  workoutCard,    // Card แสดง workout + progress
  assetSearchCard,// Card แสดงผลค้นหาสินทรัพย์
  summaryCard,    // Card สรุปข้อมูล
  askMore,        // ถามข้อมูลเพิ่ม
}
```

### 5.2 Confirm Card UI

```
┌─────────────────────────────────────────────────┐
│  📅 สร้างงานใหม่                                │
├─────────────────────────────────────────────────┤
│                                                 │
│  📋 รายละเอียด:                                 │
│  ├─ ชื่องาน: ประชุม Team Weekly                 │
│  ├─ วันที่: 4 ก.พ. 2569                         │
│  └─ เวลา: 14:00 น.                             │
│                                                 │
│  📅 จะ sync ไปยัง Google Calendar              │
│                                                 │
│  ─────────────────────────────────────────────  │
│                                                 │
│        [✅ ยืนยัน]    [✏️ แก้ไข]                │
│                                                 │
└─────────────────────────────────────────────────┘
```

### 5.3 Workout Card UI

```
┌─────────────────────────────────────────────────┐
│  🏋️ Legs Day                                    │
│  โปรแกรม: Push Pull Legs 6 Days  (Week 3/4)    │
├─────────────────────────────────────────────────┤
│                                                 │
│  📊 Progress จากครั้งก่อน:                      │
│  ┌───────────────────────────────────────────┐ │
│  │ Exercise       Last      Suggest          │ │
│  │ ─────────────────────────────────────────  │ │
│  │ Squat          75kg×8    80kg×8 ↑         │ │
│  │ Leg Press      120kg×10  120kg×10         │ │
│  │ Romanian DL    55kg×10   60kg×10 ↑        │ │
│  │ Leg Curl       40kg×12   40kg×12          │ │
│  └───────────────────────────────────────────┘ │
│                                                 │
│  ─────────────────────────────────────────────  │
│                                                 │
│    [📋 สร้าง Task List]    [🏃 เริ่มเลย]        │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

## 6. Chat UI Components

### 6.1 Chat Screen Layout

```
┌─────────────────────────────────────────────────┐
│  ← Chat                                    [⋮]  │
├─────────────────────────────────────────────────┤
│                                                 │
│        ┌─────────────────────────────┐          │
│        │ 🤖 สวัสดีครับ! วันนี้ช่วย     │          │
│        │    อะไรได้บ้าง?              │          │
│        └─────────────────────────────┘          │
│                                                 │
│  ┌─────────────────────────────┐                │
│  │ 👤 ขอโปรแกรมออกกำลังวันนี้  │                │
│  └─────────────────────────────┘                │
│                                                 │
│        ┌─────────────────────────────┐          │
│        │ 🤖 [Workout Card UI]        │          │
│        │    ...                      │          │
│        └─────────────────────────────┘          │
│                                                 │
│  ┌─────────────────────────────┐                │
│  │ 👤 สร้าง task ให้หน่อย      │                │
│  └─────────────────────────────┘                │
│                                                 │
│        ┌─────────────────────────────┐          │
│        │ 🤖 [Confirm Card UI]        │          │
│        └─────────────────────────────┘          │
│                                                 │
├─────────────────────────────────────────────────┤
│                                                 │
│  Quick Actions:                                │
│  [🍔 บันทึกอาหาร] [🏃 Workout] [💰 รายจ่าย]     │
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │ พิมพ์ข้อความ...               [🎤] [📷] │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
└─────────────────────────────────────────────────┘
```

### 6.2 Quick Actions

```dart
final quickActions = [
  QuickAction(
    icon: "🍔",
    label: "บันทึกอาหาร",
    action: () => openCamera(mode: 'food'),
  ),
  QuickAction(
    icon: "🏃",
    label: "Workout",
    action: () => sendMessage("ขอโปรแกรมออกกำลังวันนี้"),
  ),
  QuickAction(
    icon: "💰",
    label: "รายจ่าย",
    action: () => openCamera(mode: 'slip'),
  ),
  QuickAction(
    icon: "📅",
    label: "Task",
    action: () => openTaskInput(),
  ),
];
```

---

## 7. Voice Input

### 7.1 Speech to Text

```dart
class VoiceInputHandler {
  
  Future<String?> startListening() async {
    // Use speech_to_text package
    final result = await speechToText.listen(
      localeId: 'th-TH',
      onResult: (result) {
        if (result.finalResult) {
          return result.recognizedWords;
        }
      },
    );
    return result;
  }
  
  // Voice commands ที่รองรับ
  static const voiceExamples = [
    "กินข้าวผัดกุ้ง 500 แคล",
    "วิ่ง 3 กิโล 30 นาที",
    "จ่ายค่ากาแฟ 65 บาท",
    "พรุ่งนี้ประชุม 2 โมง",
    "จดรายการซื้อของ นม ไข่ ผัก",
  ];
}
```

---

## 8. Image Input (Photo Analysis)

### 8.1 Photo Analysis Flow

```
📷 ถ่าย/เลือกรูป
       │
       ▼
┌─────────────────────────┐
│  Detect Image Type      │ ← Local AI (ML Kit)
│  • Food?                │
│  • Slip?                │
│  • Lab Result?          │
│  • Other?               │
└───────────┬─────────────┘
            │
    ┌───────┴───────┐
    │               │
  [Food]         [Slip]
    │               │
    ▼               ▼
┌─────────────┐ ┌─────────────┐
│ Food        │ │ Slip        │
│ Analysis    │ │ Analysis    │
│ (Local →    │ │ (ML Kit OCR │
│  Cloud opt) │ │  + Regex)   │
└──────┬──────┘ └──────┬──────┘
       │               │
       └───────┬───────┘
               │
               ▼
       ┌──────────────┐
       │ Confirm Card │
       │ (User verify)│
       └──────────────┘
```

---

## 9. Cross-Feature Commands

### 9.1 สรุปข้อมูลรวม

```
👤 "สรุปสัปดาห์นี้"

🤖 [Weekly Summary Card]
   ┌─────────────────────────────────────────┐
   │ 📊 สรุปสัปดาห์ (27 ม.ค. - 2 ก.พ.)       │
   │                                         │
   │ 🍎 สุขภาพ                               │
   │ • kcal เฉลี่ย: 1,850/2,000              │
   │ • ออกกำลัง: 4/5 วัน ✅                  │
   │ • น้ำหนัก: −0.5 kg                      │
   │                                         │
   │ 💰 การเงิน                              │
   │ • ใช้จ่าย: ฿28,350                      │
   │ • พอร์ต: +2.3%                          │
   │                                         │
   │ 📅 งาน                                  │
   │ • เสร็จ: 8/10 tasks                     │
   │ • Streaks: 49 วัน                       │
   └─────────────────────────────────────────┘
```

### 9.2 ถามข้อมูลข้ามหมวด

```
👤 "วันที่ใช้จ่ายเยอะ ออกกำลังด้วยหรือเปล่า"

🤖 [Insight Card]
   ┌─────────────────────────────────────────┐
   │ 💡 Insight                              │
   │                                         │
   │ วิเคราะห์ 30 วันที่ผ่านมา:              │
   │                                         │
   │ • วันที่ไม่ได้ออกกำลังกาย                │
   │   ใช้จ่ายหมวดอาหาร +35%                 │
   │                                         │
   │ • วันที่ออกกำลังกาย                      │
   │   ใช้จ่ายหมวดอาหาร -15%                 │
   │                                         │
   │ 💡 อาจเป็น stress eating?               │
   └─────────────────────────────────────────┘
```

---

## 10. Data Models

### 10.1 ChatMessage

```dart
@collection
class ChatMessage {
  Id id = Isar.autoIncrement;
  
  late String sessionId;
  
  @enumerated
  late MessageRole role;        // user, assistant
  
  late String content;
  
  // Rich content
  IntentResponseType? responseType;
  Map<String, dynamic>? cardData;
  List<IntentAction>? actions;
  
  // Metadata
  IntentType? detectedIntent;
  double? confidence;
  
  DateTime createdAt = DateTime.now();
}

enum MessageRole { user, assistant }
```

### 10.2 ChatSession

```dart
@collection
class ChatSession {
  Id id = Isar.autoIncrement;
  
  late String title;
  
  final messages = IsarLinks<ChatMessage>();
  
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
```

---

## 11. Implementation Priority

### Phase 1: Core Chat

| Task | Priority | Effort |
|------|----------|--------|
| Chat UI | 🔴 High | 3h |
| Keyword Detection | 🔴 High | 2h |
| Intent Handlers (basic) | 🔴 High | 3h |
| Confirm Cards | 🔴 High | 2h |

### Phase 2: Smart Features

| Task | Priority | Effort |
|------|----------|--------|
| Context Builder | 🟡 Med | 3h |
| Workout Card + Progress | 🟡 Med | 3h |
| Finance Handlers | 🟡 Med | 3h |
| Voice Input | 🟡 Med | 2h |

### Phase 3: Advanced

| Task | Priority | Effort |
|------|----------|--------|
| Photo Analysis | 🟢 Low | 4h |
| Cross-Feature Insights | 🟢 Low | 3h |
| Weekly Summary | 🟢 Low | 2h |
| Local LLM (Gemma) | 🟢 Low | 4h |

---

## 12. Success Criteria

- [ ] พิมพ์ข้อความ → ตรวจจับ intent ถูกต้อง
- [ ] แสดง Confirm Card พร้อม actions
- [ ] "ขอโปรแกรม workout" → แสดง progress จากครั้งก่อน
- [ ] "บิลอะไรจะถึงกำหนด" → แสดง list
- [ ] สร้าง Task จาก chat → sync Google Calendar
- [ ] Voice input ทำงาน
- [ ] ถ่ายรูปอาหาร → วิเคราะห์ → บันทึก

---

**Created:** 2026-02-03
**Focus:** Chat Integration across Health, Finance, Tasks
**Reference:** Sentina Chat System
**Status:** Ready for Implementation
