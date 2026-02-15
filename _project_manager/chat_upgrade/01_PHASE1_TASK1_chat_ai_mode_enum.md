# Phase 1 Task 1: สร้าง ChatAiMode Enum

## เป้าหมาย
สร้าง enum สำหรับเก็บสถานะว่าผู้ใช้เลือกใช้ AI mode ไหน

## ขั้นตอน

### 1. สร้างไฟล์ใหม่
ตำแหน่ง: `lib/features/chat/models/chat_ai_mode.dart`

### 2. Copy โค้ดนี้ลงไฟล์

```dart
/// AI mode สำหรับ Chat System
/// - local: ใช้ Local AI (ฟรี, อังกฤษอย่างเดียว, ความแม่นยำต่ำ)
/// - miroAi: ใช้ Miro AI (1 Energy/chat, ทุกภาษา, ความแม่นยำสูง)
enum ChatAiMode {
  /// Local AI — Free, English only, Regex-based
  local,
  
  /// Miro AI — 1 Energy/chat, Multi-language, Gemini-powered
  miroAi;

  /// Display name สำหรับแสดงใน UI
  String get displayName {
    switch (this) {
      case ChatAiMode.local:
        return 'Local AI';
      case ChatAiMode.miroAi:
        return 'Miro AI';
    }
  }

  /// Description สำหรับแสดงใน UI
  String get description {
    switch (this) {
      case ChatAiMode.local:
        return 'Free • EN only';
      case ChatAiMode.miroAi:
        return '1⚡/chat';
    }
  }

  /// Icon สำหรับแสดงใน UI
  String get icon {
    switch (this) {
      case ChatAiMode.local:
        return '🧠';
      case ChatAiMode.miroAi:
        return '⚡';
    }
  }

  /// ว่าใช้ Energy หรือไม่
  bool get requiresEnergy {
    return this == ChatAiMode.miroAi;
  }
}
```

## ทดสอบว่าใช้งานได้
ลอง import ในไฟล์อื่น:
```dart
import 'package:miro/features/chat/models/chat_ai_mode.dart';

void test() {
  final mode = ChatAiMode.local;
  print(mode.displayName); // "Local AI"
  print(mode.requiresEnergy); // false
}
```

## เสร็จแล้ว
✅ Task 1 เสร็จ
➡️ ไปต่อ Task 2: `01_PHASE1_TASK2_chat_provider.md`
