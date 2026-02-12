# Step 12: Google Calendar Sync

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 2-3 ชั่วโมง
> **ความยาก:** ยากมาก
> **ต้องทำก่อน:** Step 11 (Chat AI Integration)

---

## 🎯 เป้าหมาย

- เมื่อสร้าง Task/นัดหมาย → Sync ไป Google Calendar อัตโนมัติ
- ดึง events จาก Google Calendar มาแสดงในแอป
- รองรับ Login ด้วย Google Account

---

## สิ่งที่ต้องทำ

1. ตั้งค่า Google Cloud Console
2. ตั้งค่า Android OAuth
3. สร้าง Google Auth Service
4. อัปเดต Calendar Service
5. เชื่อมต่อกับ Task Creation
6. ทดสอบ

---

## ขั้นตอนที่ 1: ตั้งค่า Google Cloud Console

### 1.1 สร้าง Project

1. ไปที่ https://console.cloud.google.com/
2. สร้าง Project ใหม่ หรือเลือก Project ที่มีอยู่
3. จดชื่อ Project ID ไว้

### 1.2 เปิด Google Calendar API

1. ไปที่ **APIs & Services > Library**
2. ค้นหา "Google Calendar API"
3. กด **Enable**

### 1.3 ตั้งค่า OAuth Consent Screen

1. ไปที่ **APIs & Services > OAuth consent screen**
2. เลือก **External**
3. กรอกข้อมูล:
   - App name: `Miro`
   - User support email: (email ของคุณ)
   - Developer contact: (email ของคุณ)
4. กด **Save and Continue**
5. ในหน้า Scopes กด **Add or Remove Scopes**
6. เลือก:
   - `https://www.googleapis.com/auth/calendar.events`
   - `https://www.googleapis.com/auth/calendar.readonly`
7. กด **Save and Continue**
8. เพิ่ม Test users (email ที่จะใช้ทดสอบ)
9. กด **Save and Continue**

### 1.4 สร้าง OAuth Client ID (Android)

1. ไปที่ **APIs & Services > Credentials**
2. กด **Create Credentials > OAuth client ID**
3. เลือก **Android**
4. กรอกข้อมูล:
   - Name: `Miro Android`
   - Package name: `com.example.miro_hybrid` (ดูจาก `android/app/build.gradle.kts`)
   - SHA-1 certificate fingerprint: (ดูขั้นตอนถัดไป)

### 1.5 หา SHA-1 Fingerprint

**เปิด Terminal ใน folder project:**

```bash
cd android
./gradlew signingReport
```

**หรือบน Windows:**

```powershell
cd android
.\gradlew.bat signingReport
```

**หา SHA-1 ใน output:**

```
Variant: debug
Config: debug
Store: C:\Users\xxx\.android\debug.keystore
Alias: androiddebugkey
MD5:  XX:XX:XX:...
SHA1: AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD  ← ใช้อันนี้
SHA-256: ...
```

**Copy SHA-1 ไปใส่ใน Google Cloud Console**

---

## ขั้นตอนที่ 2: ตั้งค่า Android

### 2.1 แก้ไข `android/app/build.gradle.kts`

**ตรวจสอบ package name:**

```kotlin
android {
    namespace = "com.example.miro_hybrid"  // ต้องตรงกับที่ลงทะเบียนใน Google Cloud
    
    defaultConfig {
        applicationId = "com.example.miro_hybrid"  // ต้องตรงกัน
        minSdk = 21
        targetSdk = 34
        // ...
    }
}
```

### 2.2 ตรวจสอบ Dependencies ใน `pubspec.yaml`

```yaml
dependencies:
  google_sign_in: ^6.2.1
  extension_google_sign_in_as_googleapis_auth: ^2.0.7
  googleapis: ^13.1.0
```

**รัน:**

```bash
flutter pub get
```

---

## ขั้นตอนที่ 3: สร้าง Google Auth Service

**สร้างไฟล์:** `lib/core/services/google_auth_service.dart`

```dart
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:http/http.dart' as http;

/// Service สำหรับ Google Authentication
class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      calendar.CalendarApi.calendarEventsScope,
      calendar.CalendarApi.calendarReadonlyScope,
    ],
  );

  static GoogleSignInAccount? _currentUser;

  /// ตรวจสอบว่า login อยู่หรือไม่
  static bool get isSignedIn => _currentUser != null;

  /// ข้อมูล user ปัจจุบัน
  static GoogleSignInAccount? get currentUser => _currentUser;

  /// Sign in with Google
  static Future<GoogleSignInAccount?> signIn() async {
    try {
      _currentUser = await _googleSignIn.signIn();
      if (_currentUser != null) {
        debugPrint('✅ Google Sign-In success: ${_currentUser!.email}');
      }
      return _currentUser;
    } catch (e) {
      debugPrint('❌ Google Sign-In error: $e');
      return null;
    }
  }

  /// Sign in silently (ถ้าเคย login แล้ว)
  static Future<GoogleSignInAccount?> signInSilently() async {
    try {
      _currentUser = await _googleSignIn.signInSilently();
      if (_currentUser != null) {
        debugPrint('✅ Google Sign-In silent success: ${_currentUser!.email}');
      }
      return _currentUser;
    } catch (e) {
      debugPrint('⚠️ Google Sign-In silent failed: $e');
      return null;
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    debugPrint('✅ Google Sign-Out success');
  }

  /// Get authenticated HTTP client
  static Future<http.Client?> getAuthenticatedClient() async {
    if (_currentUser == null) {
      await signInSilently();
    }

    if (_currentUser == null) {
      debugPrint('⚠️ User not signed in');
      return null;
    }

    try {
      final client = await _googleSignIn.authenticatedClient();
      return client;
    } catch (e) {
      debugPrint('❌ Failed to get authenticated client: $e');
      return null;
    }
  }

  /// Get Calendar API instance
  static Future<calendar.CalendarApi?> getCalendarApi() async {
    final client = await getAuthenticatedClient();
    if (client == null) return null;
    return calendar.CalendarApi(client);
  }
}
```

---

## ขั้นตอนที่ 4: อัปเดต Calendar Service

**แก้ไขไฟล์:** `lib/core/services/calendar_service.dart`

**แทนที่ทั้งไฟล์ด้วยโค้ดนี้:**

```dart
import 'package:flutter/foundation.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'google_auth_service.dart';

/// Service สำหรับ Google Calendar
class CalendarService {
  /// สร้าง Event ใน Google Calendar
  /// Return: Event ID หรือ null ถ้าไม่สำเร็จ
  static Future<String?> createEvent({
    required String title,
    required DateTime start,
    required DateTime end,
    String? description,
    String? location,
  }) async {
    try {
      final calendarApi = await GoogleAuthService.getCalendarApi();
      if (calendarApi == null) {
        debugPrint('⚠️ Calendar API not available - user not signed in');
        return null;
      }

      final event = calendar.Event()
        ..summary = title
        ..description = description
        ..location = location
        ..start = calendar.EventDateTime(
          dateTime: start,
          timeZone: 'Asia/Bangkok',
        )
        ..end = calendar.EventDateTime(
          dateTime: end,
          timeZone: 'Asia/Bangkok',
        );

      final result = await calendarApi.events.insert(event, 'primary');
      debugPrint('✅ Calendar event created: ${result.id}');
      return result.id;
    } catch (e) {
      debugPrint('❌ Calendar create event error: $e');
      return null;
    }
  }

  /// อัปเดต Event ใน Google Calendar
  static Future<bool> updateEvent({
    required String eventId,
    String? title,
    DateTime? start,
    DateTime? end,
    String? description,
  }) async {
    try {
      final calendarApi = await GoogleAuthService.getCalendarApi();
      if (calendarApi == null) return false;

      // Get existing event
      final existing = await calendarApi.events.get('primary', eventId);

      // Update fields
      if (title != null) existing.summary = title;
      if (description != null) existing.description = description;
      if (start != null) {
        existing.start = calendar.EventDateTime(
          dateTime: start,
          timeZone: 'Asia/Bangkok',
        );
      }
      if (end != null) {
        existing.end = calendar.EventDateTime(
          dateTime: end,
          timeZone: 'Asia/Bangkok',
        );
      }

      await calendarApi.events.update(existing, 'primary', eventId);
      debugPrint('✅ Calendar event updated: $eventId');
      return true;
    } catch (e) {
      debugPrint('❌ Calendar update event error: $e');
      return false;
    }
  }

  /// ลบ Event จาก Google Calendar
  static Future<bool> deleteEvent(String eventId) async {
    try {
      final calendarApi = await GoogleAuthService.getCalendarApi();
      if (calendarApi == null) return false;

      await calendarApi.events.delete('primary', eventId);
      debugPrint('✅ Calendar event deleted: $eventId');
      return true;
    } catch (e) {
      debugPrint('❌ Calendar delete event error: $e');
      return false;
    }
  }

  /// ดึง Events จาก Google Calendar
  static Future<List<CalendarEvent>> getEvents({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final calendarApi = await GoogleAuthService.getCalendarApi();
      if (calendarApi == null) return [];

      final events = await calendarApi.events.list(
        'primary',
        timeMin: start.toUtc(),
        timeMax: end.toUtc(),
        singleEvents: true,
        orderBy: 'startTime',
      );

      if (events.items == null) return [];

      return events.items!.map((e) => CalendarEvent.fromGoogleEvent(e)).toList();
    } catch (e) {
      debugPrint('❌ Calendar get events error: $e');
      return [];
    }
  }

  /// ดึง Events วันนี้
  static Future<List<CalendarEvent>> getTodayEvents() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return getEvents(start: startOfDay, end: endOfDay);
  }

  /// ดึง Events สัปดาห์นี้
  static Future<List<CalendarEvent>> getWeekEvents() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final end = start.add(const Duration(days: 7));

    return getEvents(start: start, end: end);
  }

  /// ดึง Events เดือนนี้
  static Future<List<CalendarEvent>> getMonthEvents(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);

    return getEvents(start: start, end: end);
  }
}

/// Model สำหรับ Calendar Event
class CalendarEvent {
  final String id;
  final String title;
  final String? description;
  final String? location;
  final DateTime start;
  final DateTime end;
  final bool isAllDay;

  CalendarEvent({
    required this.id,
    required this.title,
    this.description,
    this.location,
    required this.start,
    required this.end,
    this.isAllDay = false,
  });

  factory CalendarEvent.fromGoogleEvent(calendar.Event event) {
    final isAllDay = event.start?.date != null;

    DateTime start;
    DateTime end;

    if (isAllDay) {
      start = event.start!.date!;
      end = event.end!.date!;
    } else {
      start = event.start?.dateTime?.toLocal() ?? DateTime.now();
      end = event.end?.dateTime?.toLocal() ?? DateTime.now();
    }

    return CalendarEvent(
      id: event.id ?? '',
      title: event.summary ?? 'No title',
      description: event.description,
      location: event.location,
      start: start,
      end: end,
      isAllDay: isAllDay,
    );
  }
}
```

---

## ขั้นตอนที่ 5: เพิ่ม Google Calendar Field ใน Task Model

**แก้ไขไฟล์:** `lib/features/tasks/models/task.dart`

**เพิ่ม field ใหม่:**

```dart
import 'package:isar/isar.dart';

part 'task.g.dart';

@collection
class Task {
  Id id = Isar.autoIncrement;

  late String title;
  String? description;
  
  @enumerated
  TaskStatus status = TaskStatus.pending;

  @enumerated
  TaskPriority priority = TaskPriority.medium;

  DateTime? dueDate;
  DateTime? dueTime;
  
  String? category;
  
  late DateTime createdAt;
  DateTime? completedAt;
  
  // ========== เพิ่ม field นี้ ==========
  String? googleEventId;  // เก็บ ID ของ Google Calendar Event
  // =====================================

  @override
  String toString() => 'Task($id, $title, status: $status)';
}

// Enums ที่มีอยู่แล้ว
enum TaskStatus {
  pending,
  inProgress,
  completed,
  cancelled,
}

enum TaskPriority {
  low,
  medium,
  high,
  urgent,
}
```

**รัน build_runner:**

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## ขั้นตอนที่ 6: อัปเดต Intent Handler ให้ Sync Calendar

**แก้ไขไฟล์:** `lib/features/chat/services/intent_handler.dart`

**เพิ่ม import:**

```dart
import '../../../core/services/calendar_service.dart';
import '../../../core/services/google_auth_service.dart';
```

**แก้ไข method `_handleTask`:**

```dart
/// จัดการ Task Intent
Future<IntentResponse> _handleTask(
  String original,
  String title,
  String? startStr,
  String category,
) async {
  DateTime? dueDate;
  DateTime? dueTime;

  // พยายาม parse วันเวลา
  if (startStr != null) {
    try {
      final parsed = DateTime.parse(startStr);
      dueDate = DateTime(parsed.year, parsed.month, parsed.day);
      dueTime = parsed;
    } catch (_) {}
  }

  // ถ้าไม่มีวันที่จาก AI ให้ลองหาจากข้อความ
  if (dueDate == null) {
    final now = DateTime.now();
    if (original.contains('พรุ่งนี้')) {
      dueDate = DateTime(now.year, now.month, now.day + 1);
    } else if (original.contains('วันนี้')) {
      dueDate = DateTime(now.year, now.month, now.day);
    } else if (original.contains('มะรืน')) {
      dueDate = DateTime(now.year, now.month, now.day + 2);
    }
  }

  // ลองหาเวลา
  if (dueTime == null && dueDate != null) {
    final timeMatch = RegExp(r'(\d{1,2})[:.]?(\d{2})?\s*(?:น\.|โมง)?').firstMatch(original);
    if (timeMatch != null) {
      int hour = int.parse(timeMatch.group(1)!);
      int minute = int.tryParse(timeMatch.group(2) ?? '0') ?? 0;
      
      // ปรับเวลาไทย
      if (hour >= 1 && hour <= 6 && original.contains('บ่าย')) {
        hour += 12;
      } else if (hour >= 1 && hour <= 5 && !original.contains('ตี')) {
        hour += 12; // บ่าย by default
      }
      
      dueTime = DateTime(dueDate.year, dueDate.month, dueDate.day, hour, minute);
    }
  }

  // สร้าง Task
  final task = Task()
    ..title = title
    ..description = original
    ..dueDate = dueDate
    ..dueTime = dueTime
    ..priority = TaskPriority.medium
    ..status = TaskStatus.pending
    ..category = category
    ..createdAt = DateTime.now();

  // ========== เพิ่ม: Sync Google Calendar ==========
  String? googleEventId;
  String calendarNote = '';
  
  if (dueTime != null && GoogleAuthService.isSignedIn) {
    // สร้าง event ใน Google Calendar
    final endTime = dueTime.add(const Duration(hours: 1)); // Default 1 hour
    googleEventId = await CalendarService.createEvent(
      title: title,
      start: dueTime,
      end: endTime,
      description: original,
    );
    
    if (googleEventId != null) {
      task.googleEventId = googleEventId;
      calendarNote = '\n📅 _Synced to Google Calendar_';
    }
  } else if (dueTime != null && !GoogleAuthService.isSignedIn) {
    calendarNote = '\n\n_💡 เข้าสู่ระบบ Google เพื่อ sync calendar อัตโนมัติ_';
  }
  // ================================================

  await DatabaseService.isar.writeTxn(() async {
    await DatabaseService.tasks.put(task);
  });

  String dateTimeStr = '';
  if (dueDate != null) {
    dateTimeStr = '📅 ${_formatDate(dueDate)}';
    if (dueTime != null) {
      dateTimeStr += ' ⏰ ${_formatTime(dueTime)}';
    }
  }

  return IntentResponse(
    replyMessage: '✅ สร้าง Task แล้ว!\n\n'
        '📌 **$title**\n'
        '$dateTimeStr\n'
        '📁 หมวด: $category'
        '$calendarNote\n\n'
        '_แก้ไขได้ที่หน้า Tasks_',
    actionResult: ActionResult.success(
      message: 'สร้าง Task สำเร็จ',
      entryType: 'task',
      entryId: task.id,
      data: {
        'title': title,
        'dueDate': dueDate?.toIso8601String(),
        'googleEventId': googleEventId,
      },
    ),
  );
}
```

---

## ขั้นตอนที่ 7: เพิ่มปุ่ม Login Google ใน Profile

**แก้ไขไฟล์:** `lib/features/profile/presentation/profile_screen.dart`

**เพิ่ม import:**

```dart
import '../../../core/services/google_auth_service.dart';
```

**เพิ่ม widget ใน `_buildSettingsList`:**

```dart
Widget _buildSettingsList() {
  return ListView(
    padding: const EdgeInsets.all(16),
    children: [
      // ========== เพิ่ม section นี้ ==========
      _buildSectionTitle('🔗 เชื่อมต่อบัญชี'),
      _buildGoogleAccountCard(),
      const SizedBox(height: 24),
      // ======================================
      
      // ... ที่เหลือเหมือนเดิม ...
    ],
  );
}
```

**เพิ่ม method `_buildGoogleAccountCard`:**

```dart
Widget _buildGoogleAccountCard() {
  return StatefulBuilder(
    builder: (context, setState) {
      final isSignedIn = GoogleAuthService.isSignedIn;
      final user = GoogleAuthService.currentUser;

      return Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: isSignedIn ? Colors.green : Colors.grey,
            child: Icon(
              isSignedIn ? Icons.check : Icons.login,
              color: Colors.white,
            ),
          ),
          title: Text(isSignedIn ? 'Google Account' : 'เชื่อมต่อ Google'),
          subtitle: Text(
            isSignedIn 
                ? user?.email ?? 'Connected' 
                : 'เชื่อมต่อเพื่อ sync calendar',
          ),
          trailing: isSignedIn
              ? TextButton(
                  onPressed: () async {
                    await GoogleAuthService.signOut();
                    setState(() {});
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ออกจากระบบ Google แล้ว')),
                      );
                    }
                  },
                  child: const Text('ออกจากระบบ'),
                )
              : ElevatedButton(
                  onPressed: () async {
                    final result = await GoogleAuthService.signIn();
                    setState(() {});
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            result != null 
                                ? 'เข้าสู่ระบบสำเร็จ: ${result.email}'
                                : 'เข้าสู่ระบบไม่สำเร็จ',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('เชื่อมต่อ'),
                ),
        ),
      );
    },
  );
}
```

---

## ขั้นตอนที่ 8: Initialize Google Auth ใน main.dart

**แก้ไขไฟล์:** `lib/main.dart`

**เพิ่ม import และ initialization:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/services/google_auth_service.dart';  // เพิ่มบรรทัดนี้

import 'core/theme/app_theme.dart';
import 'core/database/database_service.dart';
import 'features/home/presentation/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables (optional)
  try {
    await dotenv.load(fileName: ".env");
    debugPrint('✅ Environment loaded');
  } catch (e) {
    debugPrint('⚠️ .env file not found, using defaults');
  }
  
  // Initialize DateFormatting for Thai locale
  await initializeDateFormatting('th', null);
  debugPrint('✅ Date formatting initialized for Thai locale');
  
  // Initialize Isar Database
  await DatabaseService.initialize();
  
  // ========== เพิ่ม: Try silent sign-in ==========
  await GoogleAuthService.signInSilently();
  // ==============================================
  
  runApp(
    const ProviderScope(
      child: MiroApp(),
    ),
  );
}

// ... MiroApp class เหมือนเดิม ...
```

---

## ขั้นตอนที่ 9: ทดสอบ

```bash
flutter run
```

### ทดสอบ Step-by-step:

1. **เปิดแอป → Profile → กด "เชื่อมต่อ Google"**
   - ควรเห็นหน้า Login Google
   - เลือก account และ allow permissions

2. **กลับมาที่แอป ดูว่าแสดง email หรือไม่**

3. **ไปหน้า Chat → พิมพ์ "พรุ่งนี้ประชุม 14:00"**
   - ควรสร้าง Task
   - ควรแสดงข้อความ "Synced to Google Calendar"

4. **เปิด Google Calendar บนมือถือ/เว็บ**
   - ควรเห็น event "ประชุม" ในวันพรุ่งนี้ 14:00

---

## ✅ Checklist

- [ ] ตั้งค่า Google Cloud Console แล้ว
- [ ] เพิ่ม OAuth Client ID (Android) แล้ว
- [ ] สร้าง `google_auth_service.dart` แล้ว
- [ ] อัปเดต `calendar_service.dart` แล้ว
- [ ] เพิ่ม `googleEventId` ใน Task model แล้ว
- [ ] รัน `build_runner` แล้ว
- [ ] อัปเดต `intent_handler.dart` แล้ว
- [ ] เพิ่มปุ่ม Login Google ใน `profile_screen.dart` แล้ว
- [ ] อัปเดต `main.dart` แล้ว
- [ ] ทดสอบ Login Google ได้
- [ ] ทดสอบ sync calendar ได้

---

## ไฟล์ที่สร้าง/แก้ไขในขั้นตอนนี้

```
lib/
├── core/
│   └── services/
│       ├── google_auth_service.dart  ← NEW
│       └── calendar_service.dart     ← UPDATED
├── features/
│   ├── chat/
│   │   └── services/
│   │       └── intent_handler.dart   ← UPDATED
│   ├── tasks/
│   │   └── models/
│   │       └── task.dart             ← UPDATED (เพิ่ม googleEventId)
│   └── profile/
│       └── presentation/
│           └── profile_screen.dart   ← UPDATED
└── main.dart                         ← UPDATED
```

---

## ⚠️ Troubleshooting

### Error: "PlatformException(sign_in_failed, ...)"
- ตรวจสอบ SHA-1 fingerprint ว่าตรงกับที่ลงทะเบียนใน Google Cloud Console
- ตรวจสอบ package name ว่าตรงกัน

### Error: "ApiException: 10"
- เปิด Google Calendar API ใน Google Cloud Console แล้วหรือยัง
- Test user ถูกเพิ่มใน OAuth consent screen หรือยัง

### Event ไม่แสดงใน Calendar
- ตรวจสอบ timezone ว่าถูกต้อง
- ตรวจสอบว่า login ด้วย account ที่ถูกต้อง

### ไม่มี permission
- ตรวจสอบ scopes ใน `GoogleSignIn`
- ลอง sign out แล้ว sign in ใหม่

---

## ขั้นตอนถัดไป

ไป **Step 13: Task Calendar View** เพื่อแสดง calendar view ในแอป พร้อมแสดง events จาก Google Calendar
