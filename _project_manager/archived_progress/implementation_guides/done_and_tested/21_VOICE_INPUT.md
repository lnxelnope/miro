# Step 21: Voice Input

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 2-3 ชั่วโมง
> **ความยาก:** ปานกลาง
> **ต้องทำก่อน:** Step 11 (Chat AI Integration)
> **อ้างอิง:** `_project_manager/CHAT_INTEGRATION_DESIGN.md`

---

## 🎯 เป้าหมาย

- เพิ่มปุ่มไมโครโฟนใน Chat
- พูด → แปลงเป็นข้อความ → AI ประมวลผล
- รองรับภาษาไทย

---

## สิ่งที่ต้องทำ

1. เพิ่ม speech_to_text package
2. สร้าง Voice Input Service
3. อัปเดต Chat Screen (เพิ่มปุ่ม mic)
4. สร้าง Voice Input Modal
5. จัดการ Permissions
6. ทดสอบ

---

## ขั้นตอนที่ 1: เพิ่ม Package

**แก้ไขไฟล์:** `pubspec.yaml`

```yaml
dependencies:
  speech_to_text: ^6.6.0
  permission_handler: ^11.0.1
```

**รัน:**

```bash
flutter pub get
```

---

## ขั้นตอนที่ 2: ตั้งค่า Android Permissions

**แก้ไขไฟล์:** `android/app/src/main/AndroidManifest.xml`

**เพิ่มใน `<manifest>` tag:**

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

**ตัวอย่างไฟล์เต็ม:**

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.RECORD_AUDIO"/>
    <uses-permission android:name="android.permission.INTERNET"/>
    
    <application
        ...
    </application>
</manifest>
```

---

## ขั้นตอนที่ 3: ตั้งค่า iOS Permissions

**แก้ไขไฟล์:** `ios/Runner/Info.plist`

**เพิ่มใน `<dict>` tag:**

```xml
<key>NSSpeechRecognitionUsageDescription</key>
<string>ใช้รับฟังเสียงสำหรับสั่งงานด้วยเสียง</string>
<key>NSMicrophoneUsageDescription</key>
<string>ใช้ไมโครโฟนสำหรับสั่งงานด้วยเสียง</string>
```

---

## ขั้นตอนที่ 4: สร้าง Voice Input Service

**สร้างไฟล์:** `lib/core/services/voice_input_service.dart`

```dart
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

/// Service สำหรับ Voice Input
class VoiceInputService {
  static final VoiceInputService _instance = VoiceInputService._internal();
  factory VoiceInputService() => _instance;
  VoiceInputService._internal();

  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;

  // Callbacks
  Function(String)? onResult;
  Function(String)? onFinalResult;
  Function(double)? onSoundLevel;
  Function(String)? onError;

  /// Initialize speech recognition
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _speech.initialize(
        onError: (error) {
          debugPrint('❌ Speech error: ${error.errorMsg}');
          onError?.call(error.errorMsg);
          _isListening = false;
        },
        onStatus: (status) {
          debugPrint('🎤 Speech status: $status');
          if (status == 'notListening' || status == 'done') {
            _isListening = false;
          }
        },
      );

      debugPrint(_isInitialized 
          ? '✅ Speech recognition initialized' 
          : '❌ Speech recognition not available');

      return _isInitialized;
    } catch (e) {
      debugPrint('❌ Speech init error: $e');
      return false;
    }
  }

  /// Get available locales
  Future<List<LocaleName>> getLocales() async {
    if (!_isInitialized) await initialize();
    return await _speech.locales();
  }

  /// Start listening
  Future<void> startListening({
    String localeId = 'th-TH',
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        onError?.call('ไม่สามารถเริ่มรับฟังได้');
        return;
      }
    }

    if (_isListening) {
      await stopListening();
    }

    _isListening = true;

    await _speech.listen(
      onResult: _handleResult,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      localeId: localeId,
      cancelOnError: false,
      partialResults: true,
      onSoundLevelChange: (level) {
        onSoundLevel?.call(level);
      },
    );

    debugPrint('🎤 Started listening...');
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
      debugPrint('🎤 Stopped listening');
    }
  }

  /// Cancel listening
  Future<void> cancelListening() async {
    if (_isListening) {
      await _speech.cancel();
      _isListening = false;
      debugPrint('🎤 Cancelled listening');
    }
  }

  /// Handle speech result
  void _handleResult(SpeechRecognitionResult result) {
    final text = result.recognizedWords;
    
    debugPrint('🎤 Recognized: $text (final: ${result.finalResult})');
    
    if (result.finalResult) {
      onFinalResult?.call(text);
    } else {
      onResult?.call(text);
    }
  }

  /// Dispose
  void dispose() {
    _speech.stop();
    _isListening = false;
  }
}
```

---

## ขั้นตอนที่ 5: สร้าง Voice Input Button Widget

**สร้างไฟล์:** `lib/features/chat/widgets/voice_input_button.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/services/voice_input_service.dart';
import '../../../core/theme/app_colors.dart';

class VoiceInputButton extends ConsumerStatefulWidget {
  final Function(String) onResult;

  const VoiceInputButton({
    super.key,
    required this.onResult,
  });

  @override
  ConsumerState<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends ConsumerState<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  final VoiceInputService _voiceService = VoiceInputService();
  bool _isListening = false;
  String _currentText = '';
  double _soundLevel = 0;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _setupCallbacks();
  }

  void _setupCallbacks() {
    _voiceService.onResult = (text) {
      setState(() => _currentText = text);
    };

    _voiceService.onFinalResult = (text) {
      setState(() {
        _currentText = text;
        _isListening = false;
      });
      if (text.isNotEmpty) {
        widget.onResult(text);
      }
    };

    _voiceService.onSoundLevel = (level) {
      setState(() => _soundLevel = level);
    };

    _voiceService.onError = (error) {
      setState(() => _isListening = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    };
  }

  @override
  void dispose() {
    _animController.dispose();
    _voiceService.dispose();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _voiceService.stopListening();
      setState(() => _isListening = false);
    } else {
      // Check permission
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('กรุณาอนุญาตการใช้ไมโครโฟน')),
          );
        }
        return;
      }

      setState(() {
        _isListening = true;
        _currentText = '';
      });

      await _voiceService.startListening(localeId: 'th-TH');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isListening) {
      return _buildListeningModal();
    }

    return IconButton(
      icon: const Icon(Icons.mic),
      onPressed: _toggleListening,
      tooltip: 'พูดสั่งงาน',
    );
  }

  Widget _buildListeningModal() {
    return GestureDetector(
      onTap: () {}, // Prevent dismiss
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(32),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3 + (_soundLevel / 20)),
                            blurRadius: 20 + (_soundLevel * 2),
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.mic,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '🎤 กำลังฟัง...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: const BoxConstraints(minHeight: 60),
                    child: Text(
                      _currentText.isEmpty ? '...' : _currentText,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () async {
                          await _voiceService.cancelListening();
                          setState(() {
                            _isListening = false;
                            _currentText = '';
                          });
                        },
                        child: const Text('ยกเลิก'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () async {
                          await _voiceService.stopListening();
                        },
                        child: const Text('เสร็จสิ้น'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## ขั้นตอนที่ 6: อัปเดต Chat Screen

**แก้ไขไฟล์:** `lib/features/chat/presentation/chat_screen.dart`

**เพิ่ม import:**

```dart
import '../widgets/voice_input_button.dart';
```

**แก้ไข `_buildInputField` method เพิ่มปุ่ม mic:**

```dart
Widget _buildInputField() {
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: SafeArea(
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'พิมพ์ข้อความ...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 8),
          
          // Voice Input Button
          VoiceInputButton(
            onResult: (text) {
              if (text.isNotEmpty) {
                _textController.text = text;
                _sendMessage(text);
              }
            },
          ),
          
          // Send Button
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () => _sendMessage(_textController.text),
            color: AppColors.primary,
          ),
        ],
      ),
    ),
  );
}
```

---

## ขั้นตอนที่ 7: สร้าง Voice Input Overlay (Alternative)

**ถ้าต้องการ overlay แบบ full screen:**

**สร้างไฟล์:** `lib/features/chat/presentation/voice_input_overlay.dart`

```dart
import 'package:flutter/material.dart';
import '../../../core/services/voice_input_service.dart';
import '../../../core/theme/app_colors.dart';

class VoiceInputOverlay extends StatefulWidget {
  final Function(String) onResult;

  const VoiceInputOverlay({super.key, required this.onResult});

  @override
  State<VoiceInputOverlay> createState() => _VoiceInputOverlayState();

  static Future<String?> show(BuildContext context) async {
    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => VoiceInputOverlay(
        onResult: (text) => Navigator.pop(context, text),
      ),
    );
  }
}

class _VoiceInputOverlayState extends State<VoiceInputOverlay>
    with TickerProviderStateMixin {
  final VoiceInputService _voiceService = VoiceInputService();
  String _currentText = '';
  bool _isListening = false;
  double _soundLevel = 0;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _setupVoice();
    _startListening();
  }

  void _setupAnimation() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _setupVoice() {
    _voiceService.onResult = (text) {
      setState(() => _currentText = text);
    };

    _voiceService.onFinalResult = (text) {
      if (text.isNotEmpty) {
        widget.onResult(text);
      } else {
        Navigator.pop(context);
      }
    };

    _voiceService.onSoundLevel = (level) {
      setState(() => _soundLevel = level);
    };

    _voiceService.onError = (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
      Navigator.pop(context);
    };
  }

  Future<void> _startListening() async {
    setState(() => _isListening = true);
    await _voiceService.startListening(localeId: 'th-TH');
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _voiceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Column(
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  _voiceService.cancelListening();
                  Navigator.pop(context);
                },
              ),
            ),

            const Spacer(),

            // Microphone animation
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.5),
                      blurRadius: 30 + (_soundLevel * 3),
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.mic,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Status text
            Text(
              _isListening ? '🎤 กำลังฟัง...' : 'กด Start เพื่อเริ่ม',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            // Current text
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              constraints: const BoxConstraints(minHeight: 80),
              child: Text(
                _currentText.isEmpty ? 'พูดอะไรสักอย่าง...' : _currentText,
                style: TextStyle(
                  color: _currentText.isEmpty ? Colors.white54 : Colors.white,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const Spacer(),

            // Buttons
            Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    onPressed: () {
                      _voiceService.cancelListening();
                      Navigator.pop(context);
                    },
                    child: const Text('ยกเลิก'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    onPressed: () {
                      _voiceService.stopListening();
                    },
                    child: const Text('ส่ง'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## ขั้นตอนที่ 8: ตัวอย่างคำสั่งเสียง

**เพิ่มไว้ใน Chat Help หรือ Onboarding:**

```
🎤 ตัวอย่างคำสั่งเสียง:

🍽️ อาหาร:
• "กินข้าวผัดกุ้ง 500 แคล"
• "มื้อเที่ยงกินสลัด 200 แคลอรี่"

💰 การเงิน:
• "จ่ายค่ากาแฟ 65 บาท"
• "ได้เงินเดือน 45000"

📅 งาน:
• "พรุ่งนี้ประชุม 2 โมง"
• "วันศุกร์นัดหมอฟัน 10 โมง"

🏃 ออกกำลังกาย:
• "วิ่ง 3 กิโล 30 นาที"
• "ออกกำลังกาย 45 นาที"
```

---

## ขั้นตอนที่ 9: ทดสอบ

```bash
flutter run
```

### ทดสอบ:

1. **เปิด Chat → กดปุ่ม mic**
2. **พูด "กินข้าวผัด 500 แคล"**
3. **ตรวจสอบว่า AI ประมวลผลและสร้าง Entry**
4. **พูด "จ่ายค่ากาแฟ 65 บาท"**
5. **พูด "พรุ่งนี้ประชุม 14:00"**

---

## ✅ Checklist

- [ ] เพิ่ม `speech_to_text` package แล้ว
- [ ] เพิ่ม `permission_handler` package แล้ว
- [ ] ตั้งค่า Android permissions แล้ว
- [ ] ตั้งค่า iOS permissions แล้ว
- [ ] สร้าง `voice_input_service.dart` แล้ว
- [ ] สร้าง `voice_input_button.dart` แล้ว
- [ ] อัปเดต Chat Screen แล้ว
- [ ] ทดสอบพูดภาษาไทยได้
- [ ] ทดสอบ AI ประมวลผลได้ถูกต้อง

---

## ไฟล์ที่สร้าง/แก้ไขในขั้นตอนนี้

```
lib/
├── core/services/
│   └── voice_input_service.dart     ← NEW
└── features/chat/
    ├── widgets/
    │   └── voice_input_button.dart  ← NEW
    └── presentation/
        ├── chat_screen.dart         ← UPDATED
        └── voice_input_overlay.dart ← NEW (optional)
```

---

## ⚠️ Troubleshooting

### Error: Permission denied
- ตรวจสอบว่าเพิ่ม permissions ใน AndroidManifest.xml และ Info.plist แล้ว
- ตรวจสอบว่าอนุญาต permission ในแอป

### Speech recognition ไม่ทำงานใน Emulator
- Speech recognition อาจไม่ทำงานใน emulator
- ทดสอบบน device จริง

### ภาษาไทยไม่รองรับ
- ตรวจสอบว่า locale 'th-TH' มีใน device
- ลองใช้ 'th' แทน 'th-TH'

---

## ขั้นตอนถัดไป

ไป **Step 22: Weekly Insights** เพื่อสร้างสรุปรายสัปดาห์/รายเดือน
