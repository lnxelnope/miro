# 🚨 แก้ปัญหา: Context ไม่มีให้ใช้ใน Provider

> **ปัญหา:** `L10n.of(context)` ใช้ไม่ได้ใน Provider เพราะ Provider ไม่มี `context`

---

## 📋 สรุปปัญหา

Junior พบปัญหาตอนทำ `chat_provider.dart`:

```dart
❌ ERROR: L10n.of(context) ไม่สามารถใช้ได้
```

**สาเหตุ:**
- **Provider** (StateNotifier, Notifier) ไม่ใช่ Widget → **ไม่มี `context`**
- `L10n.of(context)` ต้องการ `BuildContext` → ใช้ได้แค่ใน Widget tree เท่านั้น

---

## 🎯 วิธีแก้ปัญหา (3 แนวทาง)

### ✅ วิธีที่ 1: ส่ง String จาก Widget (แนะนำ!)

**หลักการ:** แปลข้อความใน Widget ก่อน แล้วส่ง String ที่แปลแล้วเข้า Provider

**ตัวอย่าง:**

#### ❌ ผิด (แปลใน Provider)
```dart
// chat_provider.dart
class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  Future<void> showError() async {
    final errorMsg = ChatMessage()
      ..content = L10n.of(context)!.failedToLoad; // ❌ ไม่มี context!
  }
}
```

#### ✅ ถูกต้อง (แปลใน Widget)
```dart
// chat_screen.dart (Widget)
void _handleError() {
  final errorText = L10n.of(context)!.failedToLoad; // ✅ มี context
  ref.read(chatNotifierProvider.notifier).showError(errorText);
}

// chat_provider.dart (Provider)
class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  Future<void> showError(String errorText) async {
    final errorMsg = ChatMessage()..content = errorText; // ✅ รับ String มา
  }
}
```

---

### ✅ วิธีที่ 2: ส่ง `Ref` แล้วดึง Context จาก Widget (กรณีซับซ้อน)

**หลักการ:** ถ้าต้องการแปลหลาย string ใน method เดียว ให้ส่ง callback function

**ตัวอย่าง:**

```dart
// chat_screen.dart
void _showWeeklySummary() {
  ref.read(chatNotifierProvider.notifier).showWeeklySummary(
    // ส่ง closure ที่สามารถเข้าถึง context ได้
    (key) {
      switch (key) {
        case 'title':
          return L10n.of(context)!.weeklySummaryTitle;
        case 'noData':
          return L10n.of(context)!.noDataThisWeek;
        default:
          return '';
      }
    },
  );
}

// chat_provider.dart
class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  Future<void> showWeeklySummary(
    String Function(String key) translate,
  ) async {
    final title = translate('title');
    final noData = translate('noData');
    // ... ใช้ title และ noData
  }
}
```

---

### ✅ วิธีที่ 3: Hardcode ไว้ก่อน แล้วแปลทีหลัง (Temporary)

**หลักการ:** ถ้ายังไม่เร่งด่วน สามารถ hardcode ไว้ก่อนแล้วค่อยแปลทีหลัง

**ตัวอย่าง:**

```dart
// chat_provider.dart
class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  Future<void> showError() async {
    final errorMsg = ChatMessage()
      ..content = '❌ เกิดข้อผิดพลาด กรุณาลองใหม่'; // 🟡 Hardcode ไว้ก่อน
    
    // TODO(i18n): Replace with localized string
  }
}
```

---

## 🔧 แก้ไข `chat_provider.dart`

### ปัญหาที่พบ (12 จุด)

ใน `chat_provider.dart` มีที่ที่ใช้ `L10n.of(context)` แต่ไม่มี context อยู่ **หลายจุด** ในฟังก์ชันเหล่านี้:

1. ❌ Line ~179: Error message - hardcoded แล้ว OK
2. ❌ Line ~309: Not enough energy error
3. ❌ Line ~349-357: Save result messages (3 messages)
4. ❌ Line ~447-472: Preliminary ingredients logging

**แนวทางแก้:**

#### Option A: ส่ง Strings จาก `chat_screen.dart` (แนะนำ!)

```dart
// chat_screen.dart
Future<void> _requestMenuSuggestion() async {
  final messages = {
    'notEnoughEnergy': L10n.of(context)!.notEnoughEnergy,
    'thinkingMealIdeas': L10n.of(context)!.thinkingMealIdeas,
    'savedItems': L10n.of(context)!.savedItems,
    'fromDb': L10n.of(context)!.fromDb,
    'waitAnalyze': L10n.of(context)!.waitAnalyze,
    // ... ส่งทุก string ที่ต้องใช้
  };
  
  await ref
      .read(chatNotifierProvider.notifier)
      .requestMenuSuggestion(messages);
}

// chat_provider.dart
Future<void> requestMenuSuggestion(Map<String, String> messages) async {
  // ใช้ messages['notEnoughEnergy'] แทน L10n.of(context)!.notEnoughEnergy
  if (balance < 2) {
    final errorMsg = ChatMessage()..content = messages['notEnoughEnergy']!;
    // ...
  }
}
```

#### Option B: Hardcode ไว้ก่อน แล้ว TODO

```dart
// chat_provider.dart
if (balance < 2) {
  final errorMsg = ChatMessage()
    ..content = 'Not enough Energy (minimum 2⚡ required)'; // TODO(i18n)
  // ...
}
```

---

## 📝 Checklist สำหรับตรวจสอบ

เมื่อเจอ error `L10n.of(context)` ใน Provider:

- [ ] ตรวจสอบว่าอยู่ใน **Widget** หรือ **Provider**
  - Widget → ใช้ได้เลย
  - Provider → ต้องแก้!

- [ ] เลือกวิธีแก้:
  - [ ] **วิธี 1:** ส่ง String จาก Widget (ง่ายที่สุด)
  - [ ] **วิธี 2:** ส่ง callback function (ซับซ้อน)
  - [ ] **วิธี 3:** Hardcode + TODO (ชั่วคราว)

- [ ] แก้โค้ดใน Provider
- [ ] แก้โค้ดใน Widget (ถ้าเลือกวิธี 1 หรือ 2)
- [ ] ทดสอบ Hot Reload
- [ ] ตรวจสอบไม่มี error

---

## 🎓 หลักการสำคัญ

### ❓ ทำไม Provider ไม่มี Context?

```
Widget Tree              Provider
    │                      │
    ├─ MaterialApp         ├─ StateNotifier
    │  └─ Localization     │  └─ ❌ No BuildContext!
    └─ Screen              └─ ❌ No L10n.of(context)!
       └─ BuildContext ✅
```

**อธิบาย:**
- **Widget** = UI Component → อยู่ใน Widget Tree → มี `BuildContext`
- **Provider** = Business Logic → อยู่นอก Widget Tree → **ไม่มี `BuildContext`**
- `L10n.of(context)` = ดึง localization จาก Widget Tree → ต้องมี `context`

### 🎯 Best Practice

1. **Presentation Layer (Widget)** → รับผิดชอบ UI + Localization
   ```dart
   class ChatScreen extends Widget {
     void _showError() {
       final errorText = L10n.of(context)!.error; // ✅ แปลที่นี่
       ref.read(provider).showError(errorText);
     }
   }
   ```

2. **Business Logic Layer (Provider)** → รับผิดชอบ Logic + Data
   ```dart
   class ChatNotifier extends StateNotifier {
     void showError(String errorText) { // ✅ รับ String
       // Logic here
     }
   }
   ```

**Separation of Concerns:**
- Widget = UI + i18n
- Provider = Logic only (no i18n)

---

## 📚 ตัวอย่างจริงจาก `chat_screen.dart`

### ✅ ตัวอย่างที่ทำถูกต้อง

```dart
// chat_screen.dart (Line 468-492)
Future<void> _showWeeklySummary() async {
  try {
    // ... logic ...
    
    final buffer = StringBuffer();
    buffer.writeln(
      L10n.of(context)!.weeklySummaryTitle(    // ✅ ใช้ใน Widget
        _formatDate(startOfWeek), 
        _formatDate(endOfWeek)
      )
    );
    
    // ... build message in Widget ...
    
    // ส่ง String ที่แปลแล้วเข้า Provider
    final message = ChatMessage()..content = buffer.toString();
    await ref.read(chatNotifierProvider.notifier).addMessage(message);
  }
}
```

**ทำไมถูก:**
- แปลใน Widget (`chat_screen.dart`) ซึ่งมี `context`
- ส่งแค่ String (`buffer.toString()`) เข้า Provider
- Provider แค่เก็บข้อมูล ไม่จำเป็นต้องรู้ภาษา

---

## 🔍 เครื่องมือตรวจสอบ

### หา L10n ที่ใช้ผิด

```bash
# ค้นหา L10n ในไฟล์ Provider
rg "L10n\.of\(context\)" --type dart --glob "*provider.dart"

# ผลลัพธ์ที่พบ = ต้องแก้!
```

### Pattern ที่ต้องระวัง

```dart
❌ ผิด - อยู่นอก Widget
class XxxNotifier extends StateNotifier {
  void method() {
    L10n.of(context)!.xxx  // ❌ ไม่มี context
  }
}

❌ ผิด - อยู่ใน Service
class XxxService {
  String getText() {
    return L10n.of(context)!.xxx;  // ❌ ไม่มี context
  }
}

✅ ถูก - อยู่ใน Widget
class XxxScreen extends Widget {
  @override
  Widget build(BuildContext context) {
    return Text(L10n.of(context)!.xxx);  // ✅ มี context
  }
}
```

---

## 💡 ข้อแนะนำสำหรับ Junior

### 1. ตรวจสอบตำแหน่งโค้ด

ก่อนใช้ `L10n.of(context)` ถามตัวเองว่า:
- ❓ โค้ดนี้อยู่ใน Widget ไหม?
  - ✅ ใช่ → ใช้ได้เลย
  - ❌ ไม่ใช่ (Provider/Service/Model) → **ห้ามใช้!**

### 2. วิธีแก้ที่แนะนำ

**กฎทอง:** แปลใน Widget, ส่ง String เข้า Provider

```dart
// 1. แปลใน Widget
final text = L10n.of(context)!.message;

// 2. ส่งเข้า Provider
ref.read(provider).doSomething(text);

// 3. Provider ใช้ String ที่ได้
class Provider {
  void doSomething(String text) {
    // ใช้ text ได้เลย ไม่ต้องแปล
  }
}
```

### 3. เมื่อติดปัญหา

1. ดู error message → บรรทัดไหนมีปัญหา
2. ตรวจสอบว่าอยู่ใน Widget หรือ Provider
3. ถ้าอยู่ใน Provider → ย้ายการแปลไป Widget
4. ส่ง String ที่แปลแล้วเข้า Provider
5. ทดสอบ Hot Reload

---

## 🎯 Action Items สำหรับ Junior

### ⚠️ ไฟล์ Provider/Service — แนะนำข้ามไปก่อน

ไฟล์ต่อไปนี้มี hardcoded strings แต่เป็น Provider/Service ที่ไม่มี context:
- `chat_provider.dart` — มี ~5 user-facing strings (ที่เหลือเป็น AI prompt/debug log ไม่ต้องแปล)
- `scan_controller.dart` — Logic class
- `gemini_service.dart` / `gemini_chat_service.dart` — ส่วนใหญ่เป็น AI prompts ไม่ต้องแปล

**แนะนำ:** ทำ Widget ทั้งหมดให้เสร็จก่อน แล้วค่อยกลับมาทำ Provider/Service ทีหลัง

### ตรวจสอบก่อนเพิ่ม L10n ในไฟล์ใหม่

```bash
# ค้นหา L10n ที่ใช้ผิดที่ (ใน Provider/Service)
rg "L10n\.of\(context\)" --type dart --glob "*provider.dart"
rg "L10n\.of\(context\)" --type dart --glob "*service.dart"
rg "L10n\.of\(context\)" --type dart --glob "*notifier.dart"
```

**ผลลัพธ์ที่พบ = ต้องแก้!**

---

## 📖 สรุป

| ที่ | ใช้ได้ | ใช้ไม่ได้ | วิธีแก้ |
|----|--------|----------|---------|
| Widget | ✅ | - | ใช้ `L10n.of(context)` ได้เลย |
| Provider | ❌ | ไม่มี context | ส่ง String จาก Widget |
| Service | ❌ | ไม่มี context | ส่ง String จาก Widget |
| Model | ❌ | ไม่มี context | ส่ง String จาก Widget |

**กฎทอง:**
1. แปลใน **Widget** (มี context)
2. ส่ง **String** เข้า Provider/Service
3. Provider รับ **String** ใช้เลย ไม่ต้องแปล

---

**สร้างโดย:** AI Assistant  
**วันที่:** 19 ก.พ. 2026  
**สำหรับ:** แก้ปัญหา Context ไม่มีให้ใช้  
**Status:** 📖 Reference — อ่านเมื่อเจอปัญหา Context ใน Provider
