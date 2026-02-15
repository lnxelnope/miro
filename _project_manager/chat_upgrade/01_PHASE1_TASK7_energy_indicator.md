# Phase 1 Task 7: Energy Indicator ข้าง Send Button

## เป้าหมาย
แสดง badge "⚡1" ข้างปุ่ม Send เมื่ออยู่ในโหมด Miro AI

## UI ที่ต้องการ
```
┌──────────────────────────────────────────┐
│  [Type message...]     [⚡1] [▶ Send]   │
└──────────────────────────────────────────┘
```

## ขั้นตอน

### 1. เปิดไฟล์
ตำแหน่ง: `lib/features/chat/presentation/chat_screen.dart`

### 2. หา TextField ที่เป็น message input (ด้านล่างของหน้าจอ)

มองหาส่วนที่มี `TextField` สำหรับพิมพ์ข้อความ

### 3. หา Row ที่มี Send Button

ประมาณนี้:
```dart
Row(
  children: [
    Expanded(
      child: TextField(
        // ...
      ),
    ),
    IconButton(
      icon: Icon(Icons.send),
      onPressed: _sendMessage,
    ),
  ],
)
```

### 4. แก้เป็น (เพิ่ม Energy badge ก่อน Send button):

```dart
Row(
  children: [
    Expanded(
      child: TextField(
        controller: _messageController,
        decoration: const InputDecoration(
          hintText: 'Type a message...',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        maxLines: null,
        textCapitalization: TextCapitalization.sentences,
      ),
    ),
    // Energy indicator (show only in Miro AI mode)
    _buildEnergyIndicator(),
    IconButton(
      icon: const Icon(Icons.send),
      onPressed: _sendMessage,
      color: Theme.of(context).colorScheme.primary,
    ),
  ],
)
```

### 5. เพิ่ม method `_buildEnergyIndicator()` ใน `_ChatScreenState`:

```dart
/// Energy indicator badge (show only in Miro AI mode)
Widget _buildEnergyIndicator() {
  final aiMode = ref.watch(chatAiModeProvider);
  
  // Show only in Miro AI mode
  if (aiMode != ChatAiMode.miroAi) {
    return const SizedBox.shrink();
  }
  
  return Container(
    margin: const EdgeInsets.only(right: 8),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        width: 1,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '⚡',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(width: 2),
        Text(
          '1',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    ),
  );
}
```

## อธิบาย
- Badge จะแสดงเฉพาะเมื่อ **Miro AI mode** เท่านั้น
- Local AI mode → ไม่แสดง badge (ฟรี)
- Badge อยู่ระหว่าง TextField กับ Send button

## ทดสอบ
1. เลือก Local AI → Badge ไม่แสดง
2. เลือก Miro AI → Badge แสดง "⚡1"
3. กด Send → ข้อความถูกส่ง + Energy ถูกหัก

## เสร็จแล้ว
✅ Task 7 เสร็จ — Phase 1 เสร็จสมบูรณ์!
🎉 Core Chat Upgrade สำเร็จ

### Phase 1 Summary
- ✅ Dual AI Mode (Local vs Miro)
- ✅ UI Toggle
- ✅ Gemini Chat Service
- ✅ Backend support
- ✅ Multi-food parsing
- ✅ Energy check & deduction
- ✅ Energy indicator

➡️ ไปต่อ Phase 2: `02_PHASE2_TASK1_smart_greeting.md`
