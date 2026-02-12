# Miro App - Complete Implementation Guide

> **เป้าหมาย:** ทำให้แอป Miro ใช้งานได้ 100% จากปัจจุบันที่มีแค่โครง UI

---

## สถานะปัจจุบัน (Current State)

### สิ่งที่มีแล้ว
| ไฟล์ | สถานะ | หมายเหตุ |
|------|--------|----------|
| `main.dart` | ✅ ใช้ได้ | Entry point พร้อม |
| `TimelineScreen` | ⚠️ บางส่วน | UI พร้อม แต่ FAB ยังไม่ทำงาน |
| `TimelineCard` | ✅ ใช้ได้ | Swipe delete พร้อม |
| `IsarService` | ✅ ใช้ได้ | CRUD + Learning พร้อม |
| `LifeEntry` model | ✅ ใช้ได้ | Schema พร้อม |
| `VisionProcessor` | ✅ ใช้ได้ | ML Kit integration พร้อม |
| `GalleryService` | ✅ ใช้ได้ | Photo access พร้อม |
| `QRParser` | ⚠️ บางส่วน | ต้องเพิ่ม PromptPay decoder |
| `CalendarService` | ✅ ใช้ได้ | Google Calendar sync พร้อม |
| `FinanceService` | ✅ ใช้ได้ | Yahoo Finance API พร้อม |
| `BackupService` | ✅ ใช้ได้ | JSON export พร้อม |
| `ChatProcessor` | ✅ ใช้ได้ | Logic พร้อม |
| `LLMService` | ❌ Mock | ยังเป็น Hardcode response |
| `ScanController` | ✅ ใช้ได้ | Logic พร้อม แต่ยังไม่เชื่อม UI |

### สิ่งที่ยังขาด
- ❌ Scanner UI + Permission flow
- ❌ Real LLM (Gemma 3 / Gemini fallback)
- ❌ Settings screen
- ❌ Entry detail/edit screen
- ❌ "Ask AI" button for image analysis
- ❌ Auto-scan background service
- ❌ App initialization (Isar + assets)
- ❌ Error handling & loading states

---

## Phase A: Core Connectivity (เชื่อมทุกอย่างให้ทำงาน)

### A1: App Initialization
**ไฟล์ที่ต้องแก้:** `lib/main.dart`

```dart
// เพิ่ม initialization ก่อน runApp
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize Isar Database
  await IsarService().db;
  
  // 2. Create asset folders if needed
  // (สำหรับ LLM model file ในอนาคต)
  
  runApp(const ProviderScope(child: MiroApp()));
}
```

**สิ่งที่ต้องทำ:**
- [ ] เพิ่ม `WidgetsFlutterBinding.ensureInitialized()`
- [ ] Initialize Isar ก่อน runApp
- [ ] เพิ่ม splash screen ระหว่าง loading

---

### A2: Scanner UI Connection
**ไฟล์ที่ต้องแก้:** `lib/features/timeline/presentation/timeline_screen.dart`

**สิ่งที่ต้องทำ:**
- [ ] สร้าง `ScannerProvider` ใน `lib/features/scanner/providers/scanner_provider.dart`

```dart
// scanner_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:miro_hybrid/features/scanner/logic/scan_controller.dart';
import 'package:miro_hybrid/features/scanner/services/gallery_service.dart';
import 'package:miro_hybrid/features/scanner/services/vision_processor.dart';
import 'package:miro_hybrid/features/scanner/services/qr_parser.dart';
import 'package:miro_hybrid/core/database/isar_service.dart';

part 'scanner_provider.g.dart';

@riverpod
ScanController scanController(ScanControllerRef ref) {
  return ScanController(
    GalleryService(),
    VisionProcessor(),
    QRParser(),
    IsarService(),
  );
}
```

- [ ] แก้ FAB ใน `TimelineScreen`:

```dart
floatingActionButton: FloatingActionButton(
  child: Icon(Icons.camera_alt),
  onPressed: () async {
    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('กำลังสแกนรูปใหม่...')),
    );
    
    // Trigger scan
    await ref.read(scanControllerProvider).scanNewImages();
    
    // Done
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('สแกนเสร็จแล้ว!')),
    );
  },
),
```

- [ ] เพิ่มปุ่ม "เลือกรูปเดียว" สำหรับ manual pick

---

### A3: Permission Handling
**ไฟล์ใหม่:** `lib/core/services/permission_service.dart`

```dart
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestGalleryPermission() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    return ps.isAuth;
  }
  
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }
  
  Future<bool> requestCalendarPermission() async {
    final status = await Permission.calendar.request();
    return status.isGranted;
  }
}
```

**สิ่งที่ต้องทำ:**
- [ ] เพิ่ม `permission_handler: ^11.3.0` ใน pubspec.yaml
- [ ] สร้าง onboarding flow ขอ permission ตอนเปิดแอปครั้งแรก
- [ ] เก็บ flag `isFirstLaunch` ใน SharedPreferences

---

## Phase B: Real AI Brain (แทน Mock LLM)

### B1: Option 1 - Gemini API (ง่ายกว่า)
**ไฟล์ที่ต้องแก้:** `lib/core/ai/llm_service.dart`

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class LLMService {
  // ใช้ Gemini 2.0 Flash (Free tier มี 15 RPM)
  static const String _apiKey = 'YOUR_GEMINI_API_KEY'; // ควรเก็บใน .env
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  Future<String> classifyAndParse(String text) async {
    final prompt = '''
You are a Thai life assistant. Classify this input and extract structured data.

Input: "$text"

Rules:
- If about money/buying/paying → type: "finance"
- If about meeting/appointment/reminder → type: "task"
- If about food/exercise/health → type: "health"

Return ONLY valid JSON:
{
  "type": "finance|task|health|unknown",
  "title": "short description",
  "amount": number or null,
  "start": "ISO datetime" or null,
  "category": "Food|Transport|Work|Investment|Workout|Other"
}
''';

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'parts': [{'text': prompt}]}],
          'generationConfig': {
            'temperature': 0.1,
            'maxOutputTokens': 256,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['candidates'][0]['content']['parts'][0]['text'];
        // Extract JSON from response
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
        if (jsonMatch != null) return jsonMatch.group(0)!;
      }
    } catch (e) {
      print('Gemini API Error: $e');
    }
    
    // Fallback to local regex
    return _localFallback(text);
  }
  
  String _localFallback(String text) {
    if (text.contains(RegExp(r'ซื้อ|จ่าย|โอน|บาท'))) {
      return '{"type": "finance", "category": "Other"}';
    }
    if (text.contains(RegExp(r'ประชุม|นัด|เตือน'))) {
      return '{"type": "task", "title": "$text"}';
    }
    if (text.contains(RegExp(r'กิน|ทาน|ออกกำลัง'))) {
      return '{"type": "health", "category": "Food"}';
    }
    return '{"type": "unknown"}';
  }
}
```

**สิ่งที่ต้องทำ:**
- [ ] สมัคร Google AI Studio และสร้าง API Key
- [ ] สร้างไฟล์ `.env` เก็บ API Key (อย่า commit)
- [ ] เพิ่ม `flutter_dotenv: ^5.1.0` ใน pubspec.yaml
- [ ] Fallback เป็น local regex เมื่อ offline

---

### B2: Option 2 - On-Device Gemma 3 (MediaPipe LLM)
> ⚠️ ซับซ้อนกว่ามาก ต้องมี model file ~1-2GB

**สิ่งที่ต้องทำ:**
- [ ] ดาวน์โหลด Gemma 3 model (gemma-3-1b-it-int4.task)
- [ ] สร้าง Platform Channel (Kotlin/Swift) เชื่อม MediaPipe
- [ ] จัดการ model loading และ memory

**ไฟล์ใหม่ที่ต้องสร้าง:**
- `android/app/src/main/kotlin/.../LLMChannel.kt`
- `lib/core/ai/llm_native_channel.dart`

```dart
// llm_native_channel.dart
import 'package:flutter/services.dart';

class LLMNativeChannel {
  static const _channel = MethodChannel('com.miro/llm');
  
  Future<String> generate(String prompt) async {
    final result = await _channel.invokeMethod('generate', {'prompt': prompt});
    return result as String;
  }
  
  Future<void> loadModel(String modelPath) async {
    await _channel.invokeMethod('loadModel', {'path': modelPath});
  }
}
```

---

## Phase C: Enhanced UI/UX

### C1: Entry Detail Screen
**ไฟล์ใหม่:** `lib/features/timeline/presentation/entry_detail_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_hybrid/features/shared/models/life_entry.dart';
import 'dart:io';

class EntryDetailScreen extends ConsumerWidget {
  final LifeEntry entry;
  
  const EntryDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(entry.category ?? 'รายละเอียด'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _showEditDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Preview (if exists)
            if (entry.imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(entry.imagePath!),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            
            SizedBox(height: 16),
            
            // Info Cards
            _buildInfoCard('ประเภท', entry.type),
            _buildInfoCard('หมวดหมู่', entry.category ?? '-'),
            _buildInfoCard('วันที่', entry.timestamp.toString()),
            
            if (entry.amount != null)
              _buildInfoCard('จำนวนเงิน', '฿${entry.amount!.toStringAsFixed(2)}'),
            
            if (entry.receiverName != null)
              _buildInfoCard('ผู้รับ', entry.receiverName!),
            
            if (entry.originalText != null)
              _buildInfoCard('ข้อความ', entry.originalText!),
            
            SizedBox(height: 24),
            
            // Ask AI Button
            if (entry.imagePath != null)
              ElevatedButton.icon(
                onPressed: () => _askAI(context, ref),
                icon: Icon(Icons.auto_awesome),
                label: Text('ถาม AI วิเคราะห์เพิ่ม'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Card(
      child: ListTile(
        title: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(value, style: TextStyle(fontSize: 16)),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    // TODO: Implement edit dialog
  }

  void _askAI(BuildContext context, WidgetRef ref) {
    // TODO: Send image to Gemini Vision API
  }
}
```

**สิ่งที่ต้องทำ:**
- [ ] สร้าง `EntryDetailScreen`
- [ ] แก้ `TimelineCard` ให้กดแล้วไปหน้า detail
- [ ] Implement edit dialog
- [ ] Implement "Ask AI" with Gemini Vision

---

### C2: Settings Screen
**ไฟล์ใหม่:** `lib/features/settings/presentation/settings_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_hybrid/core/services/backup_service.dart';
import 'package:miro_hybrid/core/database/isar_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('ตั้งค่า')),
      body: ListView(
        children: [
          // Data Section
          ListTile(
            leading: Icon(Icons.backup),
            title: Text('สำรองข้อมูล'),
            subtitle: Text('Export เป็นไฟล์ JSON'),
            onTap: () async {
              final backup = BackupService(IsarService());
              await backup.exportData();
            },
          ),
          
          ListTile(
            leading: Icon(Icons.restore),
            title: Text('กู้คืนข้อมูล'),
            subtitle: Text('Import จากไฟล์ JSON'),
            onTap: () {
              // TODO: Implement import
            },
          ),
          
          Divider(),
          
          // AI Section
          ListTile(
            leading: Icon(Icons.psychology),
            title: Text('การตั้งค่า AI'),
            subtitle: Text('Gemini API / Offline Mode'),
            onTap: () {
              // TODO: AI settings
            },
          ),
          
          Divider(),
          
          // Account Section
          ListTile(
            leading: Icon(Icons.calendar_month),
            title: Text('เชื่อมต่อ Google Calendar'),
            onTap: () {
              // TODO: Google Sign-In flow
            },
          ),
          
          Divider(),
          
          // About Section
          ListTile(
            leading: Icon(Icons.info),
            title: Text('เกี่ยวกับ Miro'),
            subtitle: Text('Version 1.0.0'),
          ),
        ],
      ),
    );
  }
}
```

**สิ่งที่ต้องทำ:**
- [ ] สร้าง SettingsScreen
- [ ] เพิ่มปุ่ม settings ใน AppBar ของ TimelineScreen
- [ ] Implement import/restore function
- [ ] Implement API key settings

---

### C3: Improved TimelineScreen
**ไฟล์ที่ต้องแก้:** `lib/features/timeline/presentation/timeline_screen.dart`

**สิ่งที่ต้องเพิ่ม:**
- [ ] เพิ่มปุ่ม Settings ใน AppBar
- [ ] เพิ่ม Filter tabs (All / Finance / Health / Tasks)
- [ ] เพิ่ม Date header grouping
- [ ] เพิ่ม Pull-to-refresh
- [ ] ทำ empty state ให้สวยขึ้น

```dart
// ปรับ AppBar
appBar: AppBar(
  title: Text('Miro Timeline'),
  actions: [
    IconButton(
      icon: Icon(Icons.filter_list),
      onPressed: () => _showFilterSheet(context),
    ),
    IconButton(
      icon: Icon(Icons.settings),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SettingsScreen()),
      ),
    ),
  ],
),
```

---

## Phase D: PromptPay QR Decoder

### D1: เพิ่ม PromptPay Parser
**ไฟล์ที่ต้องแก้:** `lib/features/scanner/services/qr_parser.dart`

```dart
class QRParser {
  // EMVCo PromptPay Decoder
  Map<String, dynamic>? parsePromptPayQR(String rawValue) {
    if (!rawValue.startsWith('00020101')) return null;
    
    try {
      final result = <String, dynamic>{'type': 'promptpay'};
      int pos = 0;
      
      while (pos < rawValue.length - 4) {
        final tag = rawValue.substring(pos, pos + 2);
        final length = int.parse(rawValue.substring(pos + 2, pos + 4));
        final value = rawValue.substring(pos + 4, pos + 4 + length);
        
        switch (tag) {
          case '29': // PromptPay Merchant
          case '30':
            result['merchant_data'] = _parseSubTags(value);
            break;
          case '54': // Amount
            result['amount'] = double.tryParse(value);
            break;
          case '58': // Country
            result['country'] = value;
            break;
          case '59': // Merchant Name
            result['merchant_name'] = value;
            break;
          case '60': // City
            result['city'] = value;
            break;
        }
        
        pos += 4 + length;
      }
      
      return result;
    } catch (e) {
      return null;
    }
  }
  
  Map<String, String> _parseSubTags(String data) {
    final result = <String, String>{};
    int pos = 0;
    
    while (pos < data.length - 4) {
      final tag = data.substring(pos, pos + 2);
      final length = int.parse(data.substring(pos + 2, pos + 4));
      final value = data.substring(pos + 4, pos + 4 + length);
      
      if (tag == '01' || tag == '02' || tag == '03') {
        result['phone_or_id'] = value;
      }
      
      pos += 4 + length;
    }
    
    return result;
  }

  // Enhanced Slip OCR
  Map<String, dynamic> extractFromSlipText(String text) {
    final result = <String, dynamic>{
      'type': 'finance',
      'category': 'uncategorized',
    };

    // Amount Pattern (Thai format: 1,234.56 or 1234.56)
    final amountPatterns = [
      RegExp(r'(?:จำนวน|Amount|THB|฿)\s*([\d,]+\.?\d*)'),
      RegExp(r'([\d,]+\.\d{2})\s*(?:บาท|THB|฿)'),
      RegExp(r'^([\d,]+\.\d{2})$', multiLine: true),
    ];
    
    for (var pattern in amountPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        String raw = match.group(1)!.replaceAll(',', '');
        result['amount'] = double.tryParse(raw);
        break;
      }
    }

    // Date Pattern (DD/MM/YYYY or DD-MM-YYYY)
    final datePattern = RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})');
    final dateMatch = datePattern.firstMatch(text);
    if (dateMatch != null) {
      result['date'] = '${dateMatch.group(1)}/${dateMatch.group(2)}/${dateMatch.group(3)}';
    }

    // Receiver Name Patterns
    final receiverPatterns = [
      RegExp(r'(?:To|ไปยัง|ผู้รับ)[:\s]+(.+)', caseSensitive: false),
      RegExp(r'(?:Name|ชื่อ)[:\s]+(.+)', caseSensitive: false),
    ];
    
    for (var pattern in receiverPatterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        result['receiver'] = match.group(1)!.trim();
        break;
      }
    }

    // Known Merchants Detection
    final merchants = {
      'Starbucks': 'Food & Drink',
      '7-Eleven': 'Convenience',
      'Lotus': 'Grocery',
      'Big C': 'Grocery',
      'Grab': 'Transport',
      'LINE': 'Transfer',
      'True': 'Bills',
      'AIS': 'Bills',
      'DTAC': 'Bills',
    };
    
    for (var entry in merchants.entries) {
      if (text.toLowerCase().contains(entry.key.toLowerCase())) {
        result['receiver'] = entry.key;
        result['category'] = entry.value;
        break;
      }
    }

    return result;
  }
}
```

**สิ่งที่ต้องทำ:**
- [ ] Implement PromptPay EMVCo decoder
- [ ] เพิ่ม merchant detection
- [ ] เพิ่ม date extraction

---

## Phase E: Error Handling & Polish

### E1: Global Error Handler
**ไฟล์ใหม่:** `lib/core/utils/error_handler.dart`

```dart
import 'package:flutter/material.dart';

class ErrorHandler {
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'ปิด',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
  
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}
```

### E2: Loading States
**สิ่งที่ต้องทำ:**
- [ ] เพิ่ม loading overlay ตอนสแกน
- [ ] เพิ่ม shimmer loading สำหรับ timeline
- [ ] เพิ่ม retry button เมื่อ API fail

---

## Phase F: Background Service (Optional)

### F1: WorkManager Integration
> สำหรับสแกนรูปอัตโนมัติเมื่อมีรูปใหม่

**สิ่งที่ต้องทำ:**
- [ ] เพิ่ม `workmanager: ^0.5.2` ใน pubspec.yaml
- [ ] สร้าง background task สแกนทุก 1 ชั่วโมง
- [ ] เก็บ lastScanTimestamp ใน SharedPreferences

```dart
// background_scanner.dart
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == 'scanGallery') {
      // Run scan logic
      final scanner = ScanController(...);
      await scanner.scanNewImages();
    }
    return true;
  });
}

void initBackgroundScanner() {
  Workmanager().initialize(callbackDispatcher);
  Workmanager().registerPeriodicTask(
    'gallery-scan',
    'scanGallery',
    frequency: Duration(hours: 1),
    constraints: Constraints(
      networkType: NetworkType.not_required,
      requiresBatteryNotLow: true,
    ),
  );
}
```

---

## Checklist Summary

### Must Have (MVP)
- [ ] A1: App Initialization
- [ ] A2: Scanner UI Connection
- [ ] A3: Permission Handling
- [ ] B1: Gemini API Integration
- [ ] C1: Entry Detail Screen
- [ ] D1: PromptPay QR Decoder
- [ ] E1: Error Handling

### Nice to Have
- [ ] B2: On-Device Gemma 3
- [ ] C2: Settings Screen
- [ ] C3: Improved Timeline (Filters, Groups)
- [ ] E2: Loading States
- [ ] F1: Background Scanner

### Final Testing
- [ ] สแกนรูปสลิปจริง
- [ ] ทดสอบ Chat input ภาษาไทย
- [ ] ทดสอบ Google Calendar sync
- [ ] ทดสอบ Export/Import backup
- [ ] ทดสอบบน Android จริง

---

## Dependencies ที่ต้องเพิ่ม

```yaml
# pubspec.yaml - เพิ่มใน dependencies:
permission_handler: ^11.3.0
flutter_dotenv: ^5.1.0
shared_preferences: ^2.2.2
shimmer: ^3.0.0

# Optional:
workmanager: ^0.5.2
```

---

## คำสั่งหลังแก้ไข

```bash
# Generate Riverpod & Isar code
dart run build_runner build --delete-conflicting-outputs

# Test on device
flutter run --debug

# Build APK
flutter build apk --release
```

---

**Created:** 2026-02-03
**Last Updated:** 2026-02-03
**Status:** Ready for Implementation
