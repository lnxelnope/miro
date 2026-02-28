# ⚡ Quick Reference Card: L10n ใน Flutter

> บันทึกสำหรับ Junior - ตรวจเช็คก่อนใช้ `L10n.of(context)` ทุกครั้ง!

---

## ✅ ตรวจสอบก่อนใช้ (Checklist)

```
[ ] โค้ดอยู่ใน Widget ไหม?
    ✅ ใช่ → ใช้ได้เลย
    ❌ ไม่ใช่ → อ่านต่อ!

[ ] อยู่ใน Class ประเภทไหน?
    ✅ Widget (extends StatelessWidget/StatefulWidget) → OK
    ❌ Provider (extends StateNotifier/Notifier) → ห้ามใช้!
    ❌ Service (class XxxService) → ห้ามใช้!
    ❌ Model (class XxxModel) → ห้ามใช้!

[ ] Method มี BuildContext parameter ไหม?
    ✅ ใช่ (method(BuildContext context)) → OK
    ❌ ไม่มี → ห้ามใช้!
```

---

## 📍 ใช้ได้ (Safe Zones)

### ✅ 1. Widget build method
```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(L10n.of(context)!.title); // ✅ OK
  }
}
```

### ✅ 2. Method ใน Widget (มี context)
```dart
class MyScreen extends StatelessWidget {
  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(L10n.of(context)!.confirm), // ✅ OK
      ),
    );
  }
}
```

### ✅ 3. Method ที่รับ context parameter
```dart
String _getTitle(BuildContext context) {
  return L10n.of(context)!.title; // ✅ OK - รับ context มา
}
```

---

## 🚫 ใช้ไม่ได้ (Danger Zones)

### ❌ 1. Provider/StateNotifier
```dart
class MyProvider extends StateNotifier {
  void method() {
    final text = L10n.of(context)!.text; // ❌ ERROR!
  }
}
```

### ❌ 2. Service Class
```dart
class MyService {
  String getText() {
    return L10n.of(context)!.text; // ❌ ERROR!
  }
}
```

### ❌ 3. Model Class
```dart
class MyModel {
  String name = L10n.of(context)!.name; // ❌ ERROR!
}
```

### ❌ 4. initState (ไม่มี context ให้)
```dart
class MyScreen extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    final text = L10n.of(context)!.text; // ❌ ERROR!
  }
}
```

---

## 🔧 วิธีแก้ (Quick Fix)

### กรณีที่ 1: Provider ต้องการ String

**❌ ผิด:**
```dart
// Provider
class ChatProvider extends StateNotifier {
  void showError() {
    final msg = L10n.of(context)!.error; // ❌ ไม่มี context
  }
}
```

**✅ ถูก:**
```dart
// Widget
class ChatScreen extends Widget {
  void _onError() {
    final errorText = L10n.of(context)!.error; // ✅ แปลที่นี่
    ref.read(chatProvider).showError(errorText); // ส่ง String
  }
}

// Provider
class ChatProvider extends StateNotifier {
  void showError(String errorText) { // รับ String parameter
    // ใช้ errorText ได้เลย
  }
}
```

### กรณีที่ 2: Service ต้องการ String

**❌ ผิด:**
```dart
class MyService {
  String getErrorMessage() {
    return L10n.of(context)!.error; // ❌
  }
}
```

**✅ ถูก:**
```dart
// Widget
final errorMsg = L10n.of(context)!.error;
MyService.showError(errorMsg);

// Service
class MyService {
  static void showError(String message) {
    // ใช้ message
  }
}
```

### กรณีที่ 3: Method ต้องการหลาย Strings

**✅ ส่งเป็น Map:**
```dart
// Widget
void _doSomething() {
  final texts = {
    'title': L10n.of(context)!.title,
    'subtitle': L10n.of(context)!.subtitle,
    'confirm': L10n.of(context)!.confirm,
  };
  ref.read(provider).process(texts);
}

// Provider
void process(Map<String, String> texts) {
  final title = texts['title']!;
  final subtitle = texts['subtitle']!;
  // ...
}
```

---

## 🎯 กฎทอง (Golden Rules)

1. **แปลใน Widget, ส่ง String เข้า Provider**
   ```
   Widget (แปล) → String → Provider (ใช้)
   ```

2. **ห้ามใช้ L10n ใน:**
   - ❌ Provider
   - ❌ Service
   - ❌ Model
   - ❌ Utility Functions
   - ❌ initState

3. **ใช้ได้เฉพาะ:**
   - ✅ Widget build method
   - ✅ Method ใน Widget (มี context ให้ใช้)
   - ✅ Method ที่รับ BuildContext parameter

---

## 🔍 เครื่องมือช่วยตรวจสอบ

### ค้นหาปัญหาใน codebase

```bash
# หาใน Provider ทั้งหมด
rg "L10n\.of\(context\)" --type dart --glob "*provider.dart"

# หาใน Service ทั้งหมด
rg "L10n\.of\(context\)" --type dart --glob "*service.dart"

# หาใน Notifier ทั้งหมด
rg "L10n\.of\(context\)" --type dart --glob "*notifier.dart"
```

**ผลลัพธ์ที่พบ = ต้องแก้!**

---

## 📝 Debugging Steps

เมื่อเจอ error "context not found":

1. **ระบุตำแหน่ง:** โค้ดอยู่ที่ไหน?
   ```
   ไฟล์: _______________________
   Class: _______________________
   Method: _______________________
   ```

2. **ตรวจสอบ Class:**
   - [ ] Widget? → ใช้ได้
   - [ ] Provider? → ห้ามใช้
   - [ ] Service? → ห้ามใช้

3. **เลือกวิธีแก้:**
   - [ ] ย้ายการแปลไป Widget
   - [ ] ส่ง String เข้า Provider/Service
   - [ ] เปลี่ยน method signature

4. **แก้โค้ด:**
   - [ ] แก้ Widget
   - [ ] แก้ Provider/Service
   - [ ] ทดสอบ Hot Reload

---

## 💡 ตัวอย่างจริงจาก Codebase

### ✅ ถูกต้อง: chat_screen.dart (Widget)

```dart
Future<void> _showWeeklySummary() async {
  // ✅ อยู่ใน Widget - ใช้ L10n ได้
  final buffer = StringBuffer();
  buffer.writeln(
    L10n.of(context)!.weeklySummaryTitle(
      _formatDate(startOfWeek), 
      _formatDate(endOfWeek)
    )
  );
  
  // ส่ง String ที่แปลแล้วเข้า Provider
  final message = ChatMessage()..content = buffer.toString();
  await ref.read(chatNotifierProvider.notifier).addMessage(message);
}
```

### ❌ ผิด (ตัวอย่าง - ไม่มีในโค้ดจริง)

```dart
// chat_provider.dart (Provider)
class ChatNotifier extends StateNotifier {
  void showError() {
    // ❌ ใช้ไม่ได้ - Provider ไม่มี context!
    final msg = L10n.of(context)!.error;
  }
}
```

---

## 🎓 เข้าใจเพิ่มเติม

### ทำไม Provider ไม่มี Context?

```
Architecture:

[Widget Tree]           [Provider Layer]
    │                         │
    ├─ MaterialApp           ├─ StateNotifier
    │  └─ L10n Provider      │  └─ Business Logic
    │      ↓                  │  └─ ❌ No BuildContext
    └─ MyScreen              └─ ❌ No L10n.of(context)
       └─ BuildContext ✅
```

**Provider** = Business Logic Layer → ไม่ควรรู้เรื่อง UI หรือ i18n  
**Widget** = Presentation Layer → รับผิดชอบ UI + i18n

---

## ⚡ Quick Lookup Table

| คำถาม | คำตอบ |
|-------|-------|
| Widget build method | ✅ ใช้ได้ |
| Widget method (มี context) | ✅ ใช้ได้ |
| Provider/StateNotifier | ❌ ห้ามใช้ |
| Service class | ❌ ห้ามใช้ |
| Model class | ❌ ห้ามใช้ |
| initState | ❌ ห้ามใช้ |
| Method(BuildContext context) | ✅ ใช้ได้ |

---

## 🚨 เมื่อเจอ Error

**Error:** `The getter 'context' isn't defined`

**สาเหตุ:** ใช้ `L10n.of(context)` ใน Provider/Service

**วิธีแก้ (3 steps):**
1. ย้ายการแปลไป Widget
2. เปลี่ยน method ให้รับ String parameter
3. ส่ง String จาก Widget เข้า method

---

**พิมพ์ออกมาติดไว้ข้างจอ!** 📌

**Last Updated:** 19 ก.พ. 2026  
**สำหรับ:** Junior Developer  
**ดูเอกสารเพิ่มเติม:** `TROUBLESHOOTING_CONTEXT_ISSUE.md`
