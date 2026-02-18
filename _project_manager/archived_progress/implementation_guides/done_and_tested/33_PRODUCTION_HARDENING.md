# Step 33: Production Hardening — ลบ Debug Code + Error Handling

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 3-4 ชั่วโมง
> **ความยาก:** ง่าย (แต่ต้องละเอียด)
> **ต้องทำก่อน:** Step 32 (Onboarding + TDEE)

---

## 🎯 เป้าหมาย

1. **สร้าง Logger Utility** — แทน debugPrint ที่กระจายทั่ว
2. **Replace debugPrint ทั้งโปรเจค** → ใช้ AppLogger แทน
3. **แก้ TODO / Coming Soon** ที่ user เห็น
4. **Error Handling ครอบคลุม** ทุก network / DB call
5. **ลบ Dependencies ที่ไม่ใช้** (optional)

---

## 📂 ไฟล์ที่เกี่ยวข้อง

| ไฟล์ | Action | คำอธิบาย |
|------|--------|----------|
| `lib/core/utils/logger.dart` | CREATE | Logger utility |
| ทุกไฟล์ .dart (~32 ไฟล์) | EDIT | Replace debugPrint |
| `lib/features/profile/presentation/profile_screen.dart` | EDIT | Implement "ล้างข้อมูล" |
| `lib/core/ai/gemini_service.dart` | EDIT | Error handling ละเอียดขึ้น |
| `lib/features/chat/services/intent_handler.dart` | EDIT | Error handling |
| `pubspec.yaml` | EDIT | ลบ deps ที่ไม่ใช้ (optional) |

---

## 🔧 ขั้นตอนการทำงาน

### Step 1: สร้าง Logger Utility

**ไฟล์:** `lib/core/utils/logger.dart`
**Action:** CREATE

```dart
import 'package:flutter/foundation.dart';

/// Logger ที่พิมพ์เฉพาะใน Debug mode
/// ใน Release mode → ไม่พิมพ์อะไรเลย (performance ดีขึ้น + ปลอดภัย)
class AppLogger {
  /// ข้อมูลทั่วไป
  static void info(String message) {
    if (kDebugMode) debugPrint('[INFO] $message');
  }

  /// Error
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[ERROR] $message');
      if (error != null) debugPrint('  → $error');
      if (stackTrace != null) debugPrint('  → $stackTrace');
    }
  }

  /// Warning
  static void warn(String message) {
    if (kDebugMode) debugPrint('[WARN] $message');
  }

  /// Debug (เปิดเฉพาะตอน dev)
  static void debug(String message) {
    if (kDebugMode) debugPrint('[DEBUG] $message');
  }
}
```

---

### Step 2: Replace debugPrint ทั้งโปรเจค

> **วิธีทำ:** ใช้ Find & Replace ใน IDE

#### 2.1 หา debugPrint ทั้งหมด

ใน VS Code / Cursor:
- กด `Ctrl+Shift+H` (Find and Replace in Files)
- Search: `debugPrint(`
- Include: `lib/**/*.dart`

#### 2.2 แทนที่ตามเนื้อหา

**ไม่ใช่ Replace All ทีเดียว!** ต้องดูทีละจุดว่าเป็น info, error, หรือ warn

| เนื้อหา debugPrint | แทนด้วย |
|---------------------|---------|
| `debugPrint('Loading...')` | `AppLogger.info('Loading...')` |
| `debugPrint('Error: $e')` | `AppLogger.error('...', e)` |
| `debugPrint('Warning: ...')` | `AppLogger.warn('...')` |
| `debugPrint('[DEBUG] ...')` | `AppLogger.debug('...')` |

#### 2.3 เพิ่ม import ทุกไฟล์ที่แก้

```dart
import 'package:miro/core/utils/logger.dart';
// หรือ
import '../../../core/utils/logger.dart';  // ← ปรับตาม relative path
```

> **ประมาณการ:** ~300 จุดใน ~32 ไฟล์
> ใช้เวลาประมาณ 1-2 ชั่วโมง

---

### Step 3: แก้ TODO / Coming Soon ที่ user เห็น

| จุด | ไฟล์ | Action |
|-----|------|--------|
| "ล้างข้อมูลทั้งหมด" (TODO) | `profile_screen.dart` | Implement → ดู 3.1 |
| "Coming Soon" Export/Import | `profile_screen.dart` | ซ่อน (comment out) |
| "Coming Soon" Privacy Policy | `profile_screen.dart` | จะ implement ใน Step 35 → แสดงแต่ disabled |

#### 3.1 Implement "ล้างข้อมูลทั้งหมด"

**ไฟล์:** `lib/features/profile/presentation/profile_screen.dart`

หา ListTile "ล้างข้อมูลทั้งหมด" → implement onTap:

```dart
ListTile(
  leading: const Icon(Icons.delete_forever, color: Colors.red),
  title: const Text('ล้างข้อมูลทั้งหมด', style: TextStyle(color: Colors.red)),
  onTap: () => _confirmClearAllData(),
),
```

เพิ่ม method:

```dart
Future<void> _confirmClearAllData() async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning, color: Colors.red),
          SizedBox(width: 8),
          Text('ล้างข้อมูลทั้งหมด?'),
        ],
      ),
      content: const Text(
        'ข้อมูลทั้งหมดจะถูกลบ:\n'
        '• อาหารที่บันทึก\n'
        '• My Meals\n'
        '• วัตถุดิบ\n'
        '• เป้าหมาย\n'
        '• ข้อมูลส่วนตัว\n\n'
        'ลบแล้วกู้คืนไม่ได้!',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('ยกเลิก'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('ลบทั้งหมด', style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    try {
      final isar = DatabaseService.isar;  // ปรับตาม code จริง
      await isar.writeTxn(() async {
        await isar.clear();  // ลบทุก collection
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ล้างข้อมูลเรียบร้อย')),
        );
        // กลับไป Onboarding
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          (_) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
```

#### 3.2 ซ่อน Export/Import (ถ้ามี)

```dart
// ===== ซ่อน v1.0 =====
// ListTile(
//   leading: Icon(Icons.import_export),
//   title: Text('Export / Import'),
//   subtitle: Text('Coming Soon'),
// ),
// ===== จบซ่อน =====
```

---

### Step 4: Error Handling ครอบคลุม

#### 4.1 GeminiService — เพิ่ม error handling ละเอียด

**ไฟล์:** `lib/core/ai/gemini_service.dart`

ตรวจทุก method ที่เรียก Gemini API ว่ามี try-catch:

```dart
try {
  // ... เรียก Gemini API ...
} on TimeoutException {
  AppLogger.error('Gemini timeout');
  throw Exception('หมดเวลาเชื่อมต่อ — ลองใหม่อีกครั้ง');
} on FormatException catch (e) {
  AppLogger.error('Gemini format error', e);
  throw Exception('ไม่สามารถอ่านผลลัพธ์จาก AI — ลองใหม่');
} catch (e) {
  final msg = e.toString().toLowerCase();
  if (msg.contains('quota') || msg.contains('429')) {
    throw Exception('ใช้ API เกินโควต้า — รอสักครู่แล้วลองใหม่');
  }
  if (msg.contains('api key') || msg.contains('401')) {
    throw Exception('API Key ไม่ถูกต้อง — ตรวจสอบการตั้งค่า');
  }
  if (msg.contains('network') || msg.contains('socket')) {
    throw Exception('ไม่มีอินเทอร์เน็ต — ตรวจสอบการเชื่อมต่อ');
  }
  AppLogger.error('Gemini unknown error', e);
  throw Exception('เกิดข้อผิดพลาด — ลองใหม่อีกครั้ง');
}
```

#### 4.2 ตรวจ `mounted` ก่อน setState ทุกจุด

หาทุก async method ที่เรียก `setState()`:

```dart
// ❌ ผิด
await someAsyncWork();
setState(() => _isLoading = false);

// ✅ ถูก
await someAsyncWork();
if (mounted) setState(() => _isLoading = false);
```

> **วิธีหาง่าย:** Search `setState` ทั้งโปรเจค → ตรวจว่ามี `if (mounted)` ก่อนหรือยัง

#### 4.3 ตรวจ showModalBottomSheet / showDialog

ทุกจุดที่เรียก `showModalBottomSheet` หรือ `showDialog` → ตรวจว่ามี `if (mounted)`:

```dart
// ❌ ผิด
await doSomething();
showModalBottomSheet(context: context, ...);

// ✅ ถูก
await doSomething();
if (mounted) {
  showModalBottomSheet(context: context, ...);
}
```

---

### Step 5: ลบ Dependencies ที่ไม่ใช้ (Optional)

**ไฟล์:** `pubspec.yaml`

> **ทำเฉพาะถ้ามั่นใจ** ว่าไม่ใช้แล้ว

**ตรวจสอบก่อนลบ:**
1. Search ชื่อ package ทั้งโปรเจค (ใน import)
2. ถ้าไม่มีที่ไหน import → ลบได้

| Package | ลบได้ถ้า... |
|---------|-------------|
| `googleapis` | ไม่ใช้ Google Calendar แล้ว (ซ่อนใน Step 29) |
| `google_sign_in` | ไม่ใช้ Google Calendar แล้ว |
| `extension_google_sign_in_as_googleapis_auth` | ไม่ใช้ Google Calendar แล้ว |
| `table_calendar` | ไม่มี Tasks tab แล้ว (ซ่อนใน Step 29) |

> **ระวัง:** ลบ dependency → ต้องลบ import ที่อ้างด้วย ไม่งั้น compile error
> **แนะนำ:** ลบทีละ 1 package แล้ว `flutter pub get` + `flutter build` ทดสอบ

---

## ✅ Checklist

### หลังทำเสร็จ ต้องตรวจสอบ:

- [ ] สร้าง `lib/core/utils/logger.dart` แล้ว
- [ ] Search `debugPrint(` ในโปรเจค → ไม่เจอ (หรือเหลือเฉพาะใน logger.dart)
- [ ] ทุกไฟล์ที่แก้ → import AppLogger ถูกต้อง
- [ ] `flutter analyze` ไม่มี error
- [ ] Profile → กด "ล้างข้อมูลทั้งหมด" → confirm → ข้อมูลหาย → ไป Onboarding
- [ ] ไม่มี "Coming Soon" ที่ user เห็นได้
- [ ] Gemini timeout → แสดง message "หมดเวลาเชื่อมต่อ" (ไม่ crash)
- [ ] Gemini key ผิด → แสดง message "API Key ไม่ถูกต้อง" (ไม่ crash)
- [ ] ไม่มี internet → ทุกจุดที่ใช้ network แสดง error ที่อ่านง่าย (ไม่ crash)
- [ ] Release build → console ไม่แสดง log ใดๆ

---

## 🔍 Troubleshooting

### Q: Import AppLogger ไม่ได้
**สาเหตุ:** path ไม่ถูก
**แก้:** ใช้ absolute import: `import 'package:miro/core/utils/logger.dart';`

### Q: ลบ dependency แล้ว build error
**สาเหตุ:** ยังมี import อ้างอยู่
**แก้:** Search ชื่อ package ทั้งโปรเจค → ลบ import ทุกจุด

### Q: `isar.clear()` error
**สาเหตุ:** อาจต้องใช้ method ชื่ออื่น
**แก้:** ลอง `isar.writeTxn(() => isar.clear())` หรือลบแต่ละ collection

---

## 🎉 เสร็จแล้ว! ไปต่อ Step 34 →

ไปทำ **Step 34: Branding — Icon, Splash, ชื่อแอป** ได้เลย
