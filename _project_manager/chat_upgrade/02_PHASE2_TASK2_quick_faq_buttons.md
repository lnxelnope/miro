# Phase 2 Task 2: Quick FAQ Buttons

## เป้าหมาย
เพิ่มปุ่มลัดสำหรับคำถามยอดนิยม แยกตาม AI mode

## UI ที่ต้องการ

### Miro AI Mode
```
[📝 Log Food] [🍽️ Suggest Menu] [📊 Weekly] [📊 Monthly] [💡 Tips]
```

### Local AI Mode
```
[🍔 Log Food] [📊 Today's Summary] [❓ Help]
```

## ขั้นตอน

### 1. เปิดไฟล์
ตำแหน่ง: `lib/features/chat/presentation/chat_screen.dart`

### 2. หาส่วนที่แสดง chat messages (ListView)

### 3. เพิ่ม Quick Action Chips ใต้ AI Mode Toggle

หลัง `_buildAiModeToggle()` เพิ่ม:

```dart
/// Quick FAQ buttons (below AI mode toggle)
Widget _buildQuickActions() {
  final aiMode = ref.watch(chatAiModeProvider);
  
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border(
        bottom: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
    ),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: aiMode == ChatAiMode.miroAi
            ? _buildMiroAiActions()
            : _buildLocalAiActions(),
      ),
    ),
  );
}

/// Miro AI Quick Actions
List<Widget> _buildMiroAiActions() {
  return [
    _buildActionChip(
      icon: '📝',
      label: 'Log Food',
      hint: 'Tell me what you ate today',
      energyCost: 0, // Just a hint, no Energy
    ),
    const SizedBox(width: 8),
    _buildActionChip(
      icon: '🍽️',
      label: 'Suggest Menu',
      action: () => _sendQuickMessage('Suggest 3 meal ideas for me'),
      energyCost: 1, // AI suggestion costs Energy
    ),
    const SizedBox(width: 8),
    _buildActionChip(
      icon: '📊',
      label: 'Weekly',
      action: () => _showWeeklySummary(),
      energyCost: 0, // Local query
    ),
    const SizedBox(width: 8),
    _buildActionChip(
      icon: '📊',
      label: 'Monthly',
      action: () => _showMonthlySummary(),
      energyCost: 0, // Local query
    ),
    const SizedBox(width: 8),
    _buildActionChip(
      icon: '💡',
      label: 'Tips',
      action: () => _sendQuickMessage('Give me tips for healthy eating'),
      energyCost: 1, // AI tips cost Energy
    ),
  ];
}

/// Local AI Quick Actions
List<Widget> _buildLocalAiActions() {
  return [
    _buildActionChip(
      icon: '🍔',
      label: 'Log Food',
      hint: 'Example: chicken 100g and rice 200g',
      energyCost: 0,
    ),
    const SizedBox(width: 8),
    _buildActionChip(
      icon: '📊',
      label: 'Today\'s Summary',
      action: () => _sendQuickMessage('How many calories today?'),
      energyCost: 0,
    ),
    const SizedBox(width: 8),
    _buildActionChip(
      icon: '❓',
      label: 'Help',
      action: () => _showLocalAiHelp(),
      energyCost: 0,
    ),
  ];
}

/// Build action chip button
Widget _buildActionChip({
  required String icon,
  required String label,
  String? hint,
  VoidCallback? action,
  required int energyCost,
}) {
  return ActionChip(
    avatar: Text(icon, style: const TextStyle(fontSize: 16)),
    label: Text(label),
    labelStyle: const TextStyle(fontSize: 12),
    onPressed: () {
      if (hint != null) {
        // Show hint in text field
        _messageController.text = hint;
      } else if (action != null) {
        action();
      }
    },
    backgroundColor: energyCost > 0
        ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5)
        : Theme.of(context).colorScheme.surfaceVariant,
  );
}

/// Send quick message (for AI actions)
void _sendQuickMessage(String message) {
  _messageController.text = message;
  _sendMessage();
}

/// Show weekly summary (local query)
void _showWeeklySummary() {
  // TODO: Implement in Phase 2 Task 3
  final message = ChatMessage(
    text: '📊 Weekly summary feature coming soon!',
    isUser: false,
    timestamp: DateTime.now(),
  );
  ref.read(chatNotifierProvider.notifier).addMessage(message);
}

/// Show monthly summary (local query)
void _showMonthlySummary() {
  // TODO: Implement in Phase 2 Task 3
  final message = ChatMessage(
    text: '📊 Monthly summary feature coming soon!',
    isUser: false,
    timestamp: DateTime.now(),
  );
  ref.read(chatNotifierProvider.notifier).addMessage(message);
}

/// Show Local AI help
void _showLocalAiHelp() {
  final helpText = '''
🤖 Local AI Help

Format: [food] [amount] [unit]

Examples:
• chicken 100g and rice 200g
• pizza 2 slices
• apple 1 piece, banana 1 piece

Note: English only, basic parsing
Switch to Miro AI for better results!
''';
  
  final message = ChatMessage(
    text: helpText,
    isUser: false,
    timestamp: DateTime.now(),
  );
  ref.read(chatNotifierProvider.notifier).addMessage(message);
}
```

### 4. เพิ่ม Quick Actions ใน Scaffold

แก้ไข AppBar:

```dart
appBar: AppBar(
  title: const Text('Chat'),
  // ... existing code
  bottom: PreferredSize(
    preferredSize: const Size.fromHeight(140), // เพิ่มความสูงจาก 80 → 140
    child: Column(
      children: [
        _buildAiModeToggle(),
        _buildQuickActions(), // ← เพิ่มบรรทัดนี้
      ],
    ),
  ),
),
```

## อธิบาย

### Miro AI Actions
| Button | Action | Energy |
|--------|--------|--------|
| 📝 Log Food | แสดง hint ใน text field | Free |
| 🍽️ Suggest Menu | AI แนะนำเมนู | 1⚡ |
| 📊 Weekly | สรุปสัปดาห์ (local) | Free |
| 📊 Monthly | สรุปเดือน (local) | Free |
| 💡 Tips | AI ให้ tips | 1⚡ |

### Local AI Actions
| Button | Action | Energy |
|--------|--------|--------|
| 🍔 Log Food | แสดง example | Free |
| 📊 Today's Summary | ส่ง "How many calories today?" | Free |
| ❓ Help | แสดง format guide | Free |

## ทดสอบ
1. สลับไป Miro AI → เห็นปุ่ม 5 ปุ่ม
2. สลับไป Local AI → เห็นปุ่ม 3 ปุ่ม
3. กด "Log Food" (Miro AI) → text field แสดง hint
4. กด "Suggest Menu" → ส่งข้อความไป AI (ใช้ 1 Energy)
5. กด "Help" (Local AI) → แสดง format guide

## เสร็จแล้ว
✅ Task 2 เสร็จ — Quick FAQ Buttons สำเร็จ
➡️ ไปต่อ Task 3: `02_PHASE2_TASK3_weekly_monthly_summary.md`
