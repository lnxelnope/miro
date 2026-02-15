# Phase 1 Task 3: เพิ่ม AI Mode Toggle ใน Chat Screen UI

## เป้าหมาย
เพิ่มปุ่มสลับระหว่าง Local AI กับ Miro AI ใน Chat Screen

## UI ที่ต้องการ
```
┌─────────────────────────────────┐
│  [🧠 Local AI]  [⚡ Miro AI]   │  ← Toggle
│   Free • EN only    1⚡/chat    │
└─────────────────────────────────┘
```

**หมายเหตุ:** UI text ทั้งหมดต้องเป็นภาษาอังกฤษ

## ขั้นตอน

### 1. เปิดไฟล์
ตำแหน่ง: `lib/features/chat/presentation/chat_screen.dart`

### 2. เพิ่ม import ด้านบน

```dart
import 'package:miro/features/chat/models/chat_ai_mode.dart';
```

### 3. หา Scaffold → appBar → เพิ่ม `bottom:` ใน AppBar

ค้นหา:
```dart
appBar: AppBar(
  title: const Text('Chat'),
  // ... existing code
),
```

แก้เป็น:
```dart
appBar: AppBar(
  title: const Text('Chat'),
  // ... existing code
  bottom: PreferredSize(
    preferredSize: const Size.fromHeight(80),
    child: _buildAiModeToggle(),
  ),
),
```

### 4. เพิ่ม method `_buildAiModeToggle()` ใน `_ChatScreenState` class

```dart
/// AI Mode Toggle — Local AI vs Miro AI
Widget _buildAiModeToggle() {
  final chatAiMode = ref.watch(chatAiModeProvider);
  
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border(
        bottom: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: _buildModeButton(
            mode: ChatAiMode.local,
            isSelected: chatAiMode == ChatAiMode.local,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildModeButton(
            mode: ChatAiMode.miroAi,
            isSelected: chatAiMode == ChatAiMode.miroAi,
          ),
        ),
      ],
    ),
  );
}

/// ปุ่มสำหรับแต่ละ Mode
Widget _buildModeButton({
  required ChatAiMode mode,
  required bool isSelected,
}) {
  return InkWell(
    onTap: () {
      ref.read(chatAiModeProvider.notifier).state = mode;
    },
    borderRadius: BorderRadius.circular(12),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                mode.icon,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 6),
              Text(
                mode.displayName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            mode.description,
            style: TextStyle(
              fontSize: 11,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7)
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    ),
  );
}
```

## ทดสอบ
1. Run app
2. เข้าหน้า Chat
3. ลองกดสลับระหว่าง Local AI กับ Miro AI
4. ปุ่มที่เลือกควรมีขอบสีน้ำเงิน

## เสร็จแล้ว
✅ Task 3 เสร็จ — UI Toggle เสร็จแล้ว
➡️ ไปต่อ Task 4: `01_PHASE1_TASK4_gemini_chat_service.md`
