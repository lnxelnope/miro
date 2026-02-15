# Phase 1 Task 2: เพิ่ม ChatAiMode Provider

## เป้าหมาย
เพิ่ม state management สำหรับเก็บว่า user เลือกใช้ AI mode ไหน

## ขั้นตอน

### 1. เปิดไฟล์
ตำแหน่ง: `lib/features/chat/providers/chat_provider.dart`

### 2. เพิ่ม import ด้านบน

```dart
import 'package:miro/features/chat/models/chat_ai_mode.dart';
```

### 3. เพิ่ม Provider ใหม่ที่ด้านล่างสุดของไฟล์ (หลัง chatNotifierProvider)

```dart
/// Provider สำหรับเก็บ AI Mode ที่ user เลือก
/// Default: ChatAiMode.local (ฟรี, ไม่เสีย Energy)
final chatAiModeProvider = StateProvider<ChatAiMode>((ref) {
  return ChatAiMode.local;
});
```

## อธิบาย
- `StateProvider` = ใช้เก็บค่าธรรมดาที่เปลี่ยนแปลงได้
- Default เป็น `ChatAiMode.local` = เริ่มต้นให้ฟรีก่อน
- User สามารถสลับได้ใน Chat Screen (ทำใน Task ถัดไป)

## ทดสอบว่าใช้งานได้
ใช้ใน Widget:
```dart
final chatAiMode = ref.watch(chatAiModeProvider);
print(chatAiMode); // ChatAiMode.local

// สลับ mode
ref.read(chatAiModeProvider.notifier).state = ChatAiMode.miroAi;
```

## เสร็จแล้ว
✅ Task 2 เสร็จ
➡️ ไปต่อ Task 3: `01_PHASE1_TASK3_chat_screen_ui_toggle.md`
