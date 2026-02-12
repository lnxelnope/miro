# Step 27: Barcode & Nutrition Label Scanner

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 5-6 ชั่วโมง
> **ความยาก:** ปานกลาง-ยาก
> **ต้องทำก่อน:** Step 23 (Fix Food Logic) + Step 24 (Ingredient Model)

---

## 🎯 เป้าหมาย

1. **Barcode Scanner** - สแกนบาร์โค้ดสินค้า → จับภาพบรรจุภัณฑ์ → Gemini อ่าน nutrition label → บันทึก
2. **Nutrition Label Scanner** - ถ่ายรูปฉลากโภชนาการโดยตรง → Gemini อ่านค่าจากฉลาก → บันทึก
3. **Auto-save as Ingredient** - บันทึกสินค้าลง Ingredient DB เพื่อใช้ซ้ำได้
4. **ปรับ serving size ได้** - ผู้ใช้กินไม่หมดก็ลดปริมาณได้ → recalculate

---

## 📐 System Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│  ┌── BARCODE SCANNER ────────────────────────────────────────┐  │
│  │                                                            │  │
│  │  1. ผู้ใช้กดปุ่ม "สแกนบาร์โค้ด" (หน้า Health)             │  │
│  │       ↓                                                    │  │
│  │  2. เปิดกล้อง + barcode overlay                            │  │
│  │       ↓                                                    │  │
│  │  3. กล้องตรวจพบ barcode → จับ frame ภาพทั้งหมด             │  │
│  │     (ภาพจะเห็นบรรจุภัณฑ์ + nutrition label ด้วย)          │  │
│  │       ↓                                                    │  │
│  │  4. แสดงหน้า Preview: ภาพที่จับได้ + barcode number        │  │
│  │     [วิเคราะห์ด้วย Gemini] [ถ่ายใหม่] [ยกเลิก]           │  │
│  │       ↓                                                    │  │
│  │  5. ส่งรูปไป Gemini พร้อม prompt เฉพาะสินค้าบาร์โค้ด      │  │
│  │     "นี่คือสินค้าที่มีบาร์โค้ด [number]                    │  │
│  │      กรุณาอ่านชื่อสินค้าและ nutrition label จากรูป"        │  │
│  │       ↓                                                    │  │
│  │  6. Gemini ส่งผล: ชื่อ, serving size, kcal, P/C/F          │  │
│  │       ↓                                                    │  │
│  │  7. GeminiAnalysisSheet → ผู้ใช้ปรับปริมาณ → ยืนยัน       │  │
│  │       ↓                                                    │  │
│  │  8. บันทึก FoodEntry + Auto-save Ingredient                │  │
│  │                                                            │  │
│  └────────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌── NUTRITION LABEL SCANNER ────────────────────────────────┐  │
│  │                                                            │  │
│  │  1. ผู้ใช้กดปุ่ม "สแกนฉลากโภชนาการ"                       │  │
│  │       ↓                                                    │  │
│  │  2. เปิดกล้อง → ถ่ายรูปฉลาก nutrition facts               │  │
│  │       ↓                                                    │  │
│  │  3. ส่งรูปไป Gemini พร้อม prompt อ่านฉลาก                 │  │
│  │     "อ่านข้อมูลโภชนาการจากฉลากนี้"                        │  │
│  │       ↓                                                    │  │
│  │  4. Gemini อ่านค่าแม่นยำจากฉลาก (ไม่ต้องประมาณ)          │  │
│  │       ↓                                                    │  │
│  │  5. GeminiAnalysisSheet → ยืนยัน → บันทึก                 │  │
│  │                                                            │  │
│  └────────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📂 ไฟล์ที่เกี่ยวข้อง

| ไฟล์ | Action | คำอธิบาย |
|------|--------|----------|
| `pubspec.yaml` | EDIT | เพิ่ม `mobile_scanner` package |
| `lib/features/health/presentation/barcode_scanner_screen.dart` | CREATE | หน้าสแกน barcode |
| `lib/features/health/presentation/nutrition_label_screen.dart` | CREATE | หน้าถ่ายฉลาก |
| `lib/core/ai/gemini_service.dart` | EDIT | เพิ่ม method วิเคราะห์ barcode/label |
| `lib/features/health/presentation/health_page.dart` | EDIT | เพิ่มปุ่มสแกน |
| `android/app/src/main/AndroidManifest.xml` | EDIT | Camera permission |
| `ios/Runner/Info.plist` | EDIT | Camera permission |

---

## 🔧 ขั้นตอนการทำงาน

### Step 1: เพิ่ม Package mobile_scanner

**ไฟล์:** `pubspec.yaml`
**Action:** EDIT

```bash
flutter pub add mobile_scanner
```

**หรือเพิ่มใน `pubspec.yaml` manually:**

```yaml
dependencies:
  # ... existing dependencies ...
  mobile_scanner: ^5.2.3  # ใช้เวอร์ชันล่าสุด
```

แล้วรัน:
```bash
flutter pub get
```

---

### Step 2: ตั้งค่า Camera Permissions

**Android:** `android/app/src/main/AndroidManifest.xml`

ตรวจสอบว่ามี permission นี้อยู่แล้ว (น่าจะมีจาก food photo feature):

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Camera permission -->
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-feature android:name="android.hardware.camera" android:required="false" />
    <uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />
    
    <!-- ... rest of manifest ... -->
</manifest>
```

**iOS:** `ios/Runner/Info.plist`

ตรวจสอบว่ามี:

```xml
<key>NSCameraUsageDescription</key>
<string>ใช้กล้องเพื่อถ่ายรูปอาหารและสแกนบาร์โค้ด</string>
```

---

### Step 3: เพิ่ม Gemini Methods สำหรับ Barcode/Label

**ไฟล์:** `lib/core/ai/gemini_service.dart`
**Action:** EDIT

**เพิ่ม 2 methods ใหม่ใน class `GeminiService`:**

```dart
  /// วิเคราะห์สินค้าจากรูป + barcode
  /// ใช้เมื่อสแกน barcode ได้รูปบรรจุภัณฑ์
  static Future<FoodAnalysisResult?> analyzeBarcodedProduct(
    File imageFile,
    String barcodeValue,
  ) async {
    debugPrint('🔍 [GeminiService] วิเคราะห์สินค้า barcode: $barcodeValue');
    
    final apiKey = await _getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('ไม่พบ Gemini API Key');
    }

    final imageBytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    final prompt = '''คุณเป็น AI ที่เชี่ยวชาญด้านโภชนาการและการอ่านฉลากอาหาร

นี่คือรูปภาพสินค้าที่มีบาร์โค้ด: $barcodeValue

กรุณา:
1. ระบุชื่อสินค้า (ถ้าอ่านได้จากบรรจุภัณฑ์)
2. อ่าน Nutrition Facts / ข้อมูลโภชนาการจากฉลาก (ถ้าเห็นในรูป)
3. ถ้าไม่เห็นฉลาก ให้ประมาณจากชนิดสินค้าที่เห็น

สำคัญ: ถ้าเห็นฉลากโภชนาการ ให้ใช้ค่าจากฉลากเป็นหลัก (แม่นยำกว่าการประมาณ)

ให้ตอบเป็น JSON format:
{
  "food_name": "ชื่อสินค้าภาษาไทย",
  "food_name_en": "English product name",
  "confidence": 0.95,
  "serving_size": 1,
  "serving_unit": "ซอง",
  "serving_grams": 30,
  "nutrition": {
    "calories": 150,
    "protein": 3,
    "carbs": 20,
    "fat": 7,
    "fiber": 1,
    "sugar": 10,
    "sodium": 200
  },
  "ingredients_detail": [
    {
      "name": "ชื่อสินค้า",
      "name_en": "Product name",
      "amount": 1,
      "unit": "ซอง",
      "calories": 150,
      "protein": 3,
      "carbs": 20,
      "fat": 7
    }
  ],
  "ingredients": ["วัตถุดิบ1", "วัตถุดิบ2"],
  "barcode": "$barcodeValue",
  "notes": "อ่านจากฉลากโภชนาการ / ประมาณจากรูปภาพ"
}

ตอบเป็น JSON เท่านั้น ห้ามใส่ markdown formatting''';

    // ใช้ logic เดียวกับ analyzeFoodImage แต่เปลี่ยน prompt
    return await _callGeminiWithImage(apiKey, base64Image, prompt);
  }

  /// วิเคราะห์ฉลากโภชนาการจากรูปถ่าย
  /// ใช้เมื่อถ่ายรูป nutrition label โดยตรง
  static Future<FoodAnalysisResult?> analyzeNutritionLabel(
    File imageFile,
  ) async {
    debugPrint('🔍 [GeminiService] อ่านฉลากโภชนาการจากรูป');
    
    final apiKey = await _getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('ไม่พบ Gemini API Key');
    }

    final imageBytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    final prompt = '''คุณเป็น AI ที่เชี่ยวชาญด้านการอ่านฉลากโภชนาการ (Nutrition Facts Label)

นี่คือรูปถ่ายฉลากโภชนาการ กรุณา:
1. อ่านข้อมูลโภชนาการทั้งหมดจากฉลาก
2. ระบุ Serving Size ตามที่ฉลากระบุ
3. ระบุ Calories, Protein, Carbohydrate, Fat ต่อ 1 serving

สำคัญ: ใช้ค่าจากฉลากตรงๆ ห้ามประมาณเอง

ให้ตอบเป็น JSON format:
{
  "food_name": "ชื่อสินค้า (อ่านจากฉลาก)",
  "food_name_en": "English name",
  "confidence": 0.98,
  "serving_size": 1,
  "serving_unit": "ซอง",
  "serving_grams": 30,
  "nutrition": {
    "calories": 150,
    "protein": 3,
    "carbs": 20,
    "fat": 7,
    "fiber": 1,
    "sugar": 10,
    "sodium": 200
  },
  "ingredients_detail": [
    {
      "name": "ชื่อสินค้า",
      "name_en": "Product name",
      "amount": 1,
      "unit": "serving",
      "calories": 150,
      "protein": 3,
      "carbs": 20,
      "fat": 7
    }
  ],
  "ingredients": [],
  "notes": "อ่านจากฉลากโภชนาการ"
}

ตอบเป็น JSON เท่านั้น ห้ามใส่ markdown formatting''';

    return await _callGeminiWithImage(apiKey, base64Image, prompt);
  }

  /// Internal: เรียก Gemini API ด้วย image + prompt
  /// (refactor จาก analyzeFoodImage เพื่อ reuse)
  static Future<FoodAnalysisResult?> _callGeminiWithImage(
    String apiKey,
    String base64Image,
    String prompt,
  ) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey',
    );

    final requestBody = {
      'contents': [
        {
          'parts': [
            {'text': prompt},
            {
              'inline_data': {
                'mime_type': 'image/jpeg',
                'data': base64Image,
              },
            },
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.1,
        'topK': 1,
        'topP': 0.95,
        'maxOutputTokens': 2048,
      },
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode != 200) {
      throw Exception('Gemini API error: ${response.statusCode}');
    }

    final responseJson = jsonDecode(response.body);
    final text = responseJson['candidates']?[0]?['content']?['parts']?[0]?['text'];
    
    if (text == null) {
      throw Exception('ไม่ได้รับข้อมูลจาก Gemini');
    }

    // Parse JSON จาก response
    final jsonStr = _extractJson(text);
    final parsed = jsonDecode(jsonStr);
    
    return FoodAnalysisResult.fromJson(parsed);
  }

  /// Extract JSON from text (อาจมี ```json ... ``` wrapper)
  static String _extractJson(String text) {
    // ลบ markdown code block ถ้ามี
    String cleaned = text.trim();
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7);
    } else if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3);
    }
    return cleaned.trim();
  }
```

**⚠️ สำคัญ:** ถ้า `analyzeFoodImage` ที่มีอยู่เดิมยังไม่ได้ refactor ให้ใช้ `_callGeminiWithImage` ก็ให้ refactor ด้วย:

หา method `analyzeFoodImage` เดิม แล้วแก้ให้ส่วนท้ายเรียก `_callGeminiWithImage` แทน

**เพิ่ม import ที่จำเป็น (ถ้ายังไม่มี):**
```dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
```

---

### Step 4: สร้าง Barcode Scanner Screen

**ไฟล์:** `lib/features/health/presentation/barcode_scanner_screen.dart`
**Action:** CREATE

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ai/gemini_service.dart';
import '../../../core/constants/enums.dart';
import '../providers/health_provider.dart';
import '../widgets/gemini_analysis_sheet.dart';
import '../models/food_entry.dart';

class BarcodeScannerScreen extends ConsumerStatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  ConsumerState<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isProcessing = false;
  String? _detectedBarcode;
  bool _hasScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('สแกนบาร์โค้ด'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          // Flash toggle
          IconButton(
            icon: ValueListenableBuilder<TorchState>(
              valueListenable: _controller.torchState,
              builder: (context, state, child) {
                return Icon(
                  state == TorchState.on ? Icons.flash_on : Icons.flash_off,
                  color: state == TorchState.on ? Colors.amber : Colors.white,
                );
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
          // Switch camera
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera view
          MobileScanner(
            controller: _controller,
            onDetect: _onBarcodeDetected,
          ),

          // Barcode overlay (scan area guide)
          _buildScanOverlay(),

          // Bottom info
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.9),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_detectedBarcode != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.success),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Barcode: $_detectedBarcode',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  if (_isProcessing)
                    const Column(
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 8),
                        Text(
                          'กำลังวิเคราะห์ด้วย Gemini...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    )
                  else ...[
                    const Text(
                      'ส่องกล้องไปที่บาร์โค้ดบนสินค้า',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'พยายามให้เห็นฉลากโภชนาการด้วยจะแม่นยำกว่า',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 16),
                    // ปุ่มถ่ายฉลากแทน
                    OutlinedButton.icon(
                      onPressed: () => _switchToNutritionLabel(),
                      icon: const Icon(Icons.receipt_long, color: Colors.white),
                      label: const Text('ถ่ายฉลากโภชนาการแทน', style: TextStyle(color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scanAreaSize = constraints.maxWidth * 0.7;
        final left = (constraints.maxWidth - scanAreaSize) / 2;
        final top = (constraints.maxHeight - scanAreaSize) / 2 - 50;

        return Stack(
          children: [
            // Dark overlay with transparent scan area
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5),
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Positioned(
                    left: left,
                    top: top,
                    child: Container(
                      width: scanAreaSize,
                      height: scanAreaSize,
                      decoration: BoxDecoration(
                        color: Colors.red, // สีอะไรก็ได้ จะถูก srcOut
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Corner markers
            Positioned(
              left: left,
              top: top,
              child: _buildCorner(Alignment.topLeft),
            ),
            Positioned(
              right: left,
              top: top,
              child: _buildCorner(Alignment.topRight),
            ),
            Positioned(
              left: left,
              bottom: constraints.maxHeight - top - scanAreaSize,
              child: _buildCorner(Alignment.bottomLeft),
            ),
            Positioned(
              right: left,
              bottom: constraints.maxHeight - top - scanAreaSize,
              child: _buildCorner(Alignment.bottomRight),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCorner(Alignment alignment) {
    const size = 30.0;
    const thickness = 3.0;
    const color = AppColors.primary;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerPainter(alignment: alignment, color: color, thickness: thickness),
      ),
    );
  }

  /// เมื่อตรวจพบ barcode
  void _onBarcodeDetected(BarcodeCapture capture) async {
    if (_isProcessing || _hasScanned) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    setState(() {
      _detectedBarcode = barcode.rawValue;
      _hasScanned = true;
      _isProcessing = true;
    });

    debugPrint('📦 [BarcodeScanner] Detected: ${barcode.rawValue}');

    try {
      // จับ frame จากกล้อง
      final capturedImage = capture.image;
      File imageFile;

      if (capturedImage != null) {
        // ใช้ image จาก capture
        final tempDir = await getTemporaryDirectory();
        final fileName = 'barcode_${DateTime.now().millisecondsSinceEpoch}.jpg';
        imageFile = File('${tempDir.path}/$fileName');
        await imageFile.writeAsBytes(capturedImage);
      } else {
        // fallback: ใช้ controller capture
        // mobile_scanner ไม่มี capture method ตรงๆ
        // ต้องแจ้งให้ผู้ใช้ถ่ายรูปเอง
        if (!context.mounted) return;
        setState(() {
          _isProcessing = false;
          _hasScanned = false;
        });
        
        _showManualCaptureDialog(barcode.rawValue!);
        return;
      }

      // วิเคราะห์ด้วย Gemini
      final result = await GeminiService.analyzeBarcodedProduct(
        imageFile,
        barcode.rawValue!,
      );

      if (!context.mounted) return;
      setState(() => _isProcessing = false);

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ ไม่สามารถวิเคราะห์สินค้าได้')),
        );
        setState(() => _hasScanned = false);
        return;
      }

      // แสดง GeminiAnalysisSheet
      _showAnalysisResult(result, barcode.rawValue!, imageFile.path);
    } catch (e) {
      debugPrint('❌ [BarcodeScanner] Error: $e');
      if (!context.mounted) return;
      setState(() {
        _isProcessing = false;
        _hasScanned = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  /// แสดง dialog ให้ถ่ายรูปบรรจุภัณฑ์เอง (fallback)
  void _showManualCaptureDialog(String barcodeValue) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('พบบาร์โค้ดแล้ว!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Barcode: $barcodeValue'),
            const SizedBox(height: 12),
            const Text(
              'กรุณาถ่ายรูปบรรจุภัณฑ์หรือฉลากโภชนาการ\n'
              'เพื่อให้ Gemini วิเคราะห์ข้อมูลสินค้า',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _hasScanned = false);
            },
            child: const Text('สแกนใหม่'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _captureAndAnalyze(barcodeValue);
            },
            child: const Text('ถ่ายรูป'),
          ),
        ],
      ),
    );
  }

  /// ถ่ายรูปบรรจุภัณฑ์แล้ววิเคราะห์
  Future<void> _captureAndAnalyze(String barcodeValue) async {
    // ใช้ image_picker เพื่อถ่ายรูป
    // (import image_picker ที่มีอยู่แล้วในโปรเจค)
    try {
      final picker = await _takePicture();
      if (picker == null) {
        setState(() => _hasScanned = false);
        return;
      }

      setState(() => _isProcessing = true);

      final result = await GeminiService.analyzeBarcodedProduct(
        File(picker),
        barcodeValue,
      );

      if (!context.mounted) return;
      setState(() => _isProcessing = false);

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ ไม่สามารถวิเคราะห์ได้')),
        );
        setState(() => _hasScanned = false);
        return;
      }

      _showAnalysisResult(result, barcodeValue, picker);
    } catch (e) {
      if (!context.mounted) return;
      setState(() {
        _isProcessing = false;
        _hasScanned = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ $e')),
      );
    }
  }

  /// ใช้ image_picker ถ่ายรูป
  Future<String?> _takePicture() async {
    // ใช้ ImagePicker ที่มีอยู่แล้วในโปรเจค
    final imagePicker = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => _SimpleCameraCapture(),
      ),
    );
    return imagePicker;
  }

  /// แสดงผลวิเคราะห์
  void _showAnalysisResult(FoodAnalysisResult result, String barcodeValue, String imagePath) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GeminiAnalysisSheet(
        analysisResult: result,
        onConfirm: (confirmedData) async {
          // สร้าง FoodEntry
          final entry = FoodEntry()
            ..foodName = confirmedData.foodName
            ..foodNameEn = confirmedData.foodNameEn
            ..mealType = _guessMealType()
            ..timestamp = DateTime.now()
            ..imagePath = imagePath
            ..servingSize = confirmedData.servingSize
            ..servingUnit = confirmedData.servingUnit
            ..servingGrams = confirmedData.servingGrams
            ..calories = confirmedData.calories
            ..protein = confirmedData.protein
            ..carbs = confirmedData.carbs
            ..fat = confirmedData.fat
            ..baseCalories = confirmedData.baseCalories
            ..baseProtein = confirmedData.baseProtein
            ..baseCarbs = confirmedData.baseCarbs
            ..baseFat = confirmedData.baseFat
            ..fiber = confirmedData.fiber
            ..sugar = confirmedData.sugar
            ..sodium = confirmedData.sodium
            ..source = DataSource.aiAnalyzed
            ..aiConfidence = confirmedData.confidence
            ..isVerified = true
            ..notes = 'สแกนบาร์โค้ด: $barcodeValue';

          final notifier = ref.read(foodEntriesNotifierProvider.notifier);
          await notifier.addFoodEntry(entry);

          // Auto-save ingredient
          if (confirmedData.ingredientsDetail != null &&
              confirmedData.ingredientsDetail!.isNotEmpty) {
            try {
              await notifier.saveIngredientsAndMeal(
                mealName: confirmedData.foodName,
                mealNameEn: confirmedData.foodNameEn,
                servingDescription: '${confirmedData.servingSize} ${confirmedData.servingUnit}',
                imagePath: imagePath,
                ingredientsData: confirmedData.ingredientsDetail!,
              );
            } catch (e) {
              debugPrint('⚠️ Auto-save ingredient failed: $e');
            }
          }

          refreshFoodProviders(ref, DateTime.now());

          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ บันทึก "${confirmedData.foodName}" แล้ว'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context); // ปิด scanner screen
        },
      ),
    );
  }

  void _switchToNutritionLabel() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const NutritionLabelScreen()),
    );
  }

  MealType _guessMealType() {
    final hour = DateTime.now().hour;
    if (hour < 10) return MealType.breakfast;
    if (hour < 14) return MealType.lunch;
    if (hour < 17) return MealType.snack;
    return MealType.dinner;
  }
}

/// Corner painter สำหรับ scan overlay
class _CornerPainter extends CustomPainter {
  final Alignment alignment;
  final Color color;
  final double thickness;

  _CornerPainter({
    required this.alignment,
    required this.color,
    required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    const length = 20.0;

    if (alignment == Alignment.topLeft) {
      path.moveTo(0, length);
      path.lineTo(0, 0);
      path.lineTo(length, 0);
    } else if (alignment == Alignment.topRight) {
      path.moveTo(size.width - length, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, length);
    } else if (alignment == Alignment.bottomLeft) {
      path.moveTo(0, size.height - length);
      path.lineTo(0, size.height);
      path.lineTo(length, size.height);
    } else if (alignment == Alignment.bottomRight) {
      path.moveTo(size.width - length, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, size.height - length);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Simple camera capture (fallback ถ้า mobile_scanner จับ frame ไม่ได้)
class _SimpleCameraCapture extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ถ่ายรูปบรรจุภัณฑ์')),
      body: const Center(
        child: Text(
          'ใช้ ImagePicker ที่มีอยู่แล้วในโปรเจค\n'
          'หรือเปลี่ยนมาใช้ camera package',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
```

---

### Step 5: สร้าง Nutrition Label Scanner Screen

**ไฟล์:** `lib/features/health/presentation/nutrition_label_screen.dart`
**Action:** CREATE

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ai/gemini_service.dart';
import '../../../core/constants/enums.dart';
import '../providers/health_provider.dart';
import '../widgets/gemini_analysis_sheet.dart';
import '../models/food_entry.dart';

/// หน้าสแกนฉลากโภชนาการ
/// ถ่ายรูป Nutrition Facts Label → Gemini อ่านค่าจากฉลาก → บันทึก
class NutritionLabelScreen extends ConsumerStatefulWidget {
  const NutritionLabelScreen({super.key});

  @override
  ConsumerState<NutritionLabelScreen> createState() => _NutritionLabelScreenState();
}

class _NutritionLabelScreenState extends ConsumerState<NutritionLabelScreen> {
  File? _capturedImage;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    // เปิดกล้องเลยเมื่อเข้าหน้านี้
    WidgetsBinding.instance.addPostFrameCallback((_) => _takePicture());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สแกนฉลากโภชนาการ'),
      ),
      body: _capturedImage == null
          ? _buildEmptyState()
          : _buildPreview(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📋', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            'ถ่ายรูปฉลากโภชนาการ',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Gemini จะอ่านค่า Calories, Protein, Carbs, Fat\n'
            'จากฉลากให้อัตโนมัติ (แม่นยำกว่าการประมาณ)',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _takePicture,
                icon: const Icon(Icons.camera_alt),
                label: const Text('ถ่ายรูป'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _pickFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('จาก Gallery'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Column(
      children: [
        // Image preview
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.textTertiary.withOpacity(0.3)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                _capturedImage!,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),

        // Actions
        Padding(
          padding: const EdgeInsets.all(16),
          child: _isAnalyzing
              ? const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('กำลังอ่านฉลากด้วย Gemini...'),
                  ],
                )
              : Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _analyzeLabel,
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('วิเคราะห์ด้วย Gemini'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _takePicture,
                            icon: const Icon(Icons.camera_alt, size: 18),
                            label: const Text('ถ่ายใหม่'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, size: 18),
                            label: const Text('ยกเลิก'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 90,
    );

    if (photo != null) {
      setState(() => _capturedImage = File(photo.path));
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 90,
    );

    if (photo != null) {
      setState(() => _capturedImage = File(photo.path));
    }
  }

  Future<void> _analyzeLabel() async {
    if (_capturedImage == null) return;

    setState(() => _isAnalyzing = true);

    try {
      final result = await GeminiService.analyzeNutritionLabel(_capturedImage!);

      if (!context.mounted) return;
      setState(() => _isAnalyzing = false);

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ ไม่สามารถอ่านฉลากได้ ลองถ่ายใหม่ให้ชัดกว่านี้')),
        );
        return;
      }

      // แสดงผล
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => GeminiAnalysisSheet(
          analysisResult: result,
          onConfirm: (confirmedData) async {
            final entry = FoodEntry()
              ..foodName = confirmedData.foodName
              ..foodNameEn = confirmedData.foodNameEn
              ..mealType = _guessMealType()
              ..timestamp = DateTime.now()
              ..imagePath = _capturedImage!.path
              ..servingSize = confirmedData.servingSize
              ..servingUnit = confirmedData.servingUnit
              ..servingGrams = confirmedData.servingGrams
              ..calories = confirmedData.calories
              ..protein = confirmedData.protein
              ..carbs = confirmedData.carbs
              ..fat = confirmedData.fat
              ..baseCalories = confirmedData.baseCalories
              ..baseProtein = confirmedData.baseProtein
              ..baseCarbs = confirmedData.baseCarbs
              ..baseFat = confirmedData.baseFat
              ..fiber = confirmedData.fiber
              ..sugar = confirmedData.sugar
              ..sodium = confirmedData.sodium
              ..source = DataSource.aiAnalyzed
              ..aiConfidence = confirmedData.confidence
              ..isVerified = true
              ..notes = 'สแกนฉลากโภชนาการ';

            final notifier = ref.read(foodEntriesNotifierProvider.notifier);
            await notifier.addFoodEntry(entry);

            // Auto-save ingredient
            if (confirmedData.ingredientsDetail != null &&
                confirmedData.ingredientsDetail!.isNotEmpty) {
              try {
                await notifier.saveIngredientsAndMeal(
                  mealName: confirmedData.foodName,
                  mealNameEn: confirmedData.foodNameEn,
                  servingDescription: '${confirmedData.servingSize} ${confirmedData.servingUnit}',
                  imagePath: _capturedImage!.path,
                  ingredientsData: confirmedData.ingredientsDetail!,
                );
              } catch (e) {
                debugPrint('⚠️ Auto-save failed: $e');
              }
            }

            refreshFoodProviders(ref, DateTime.now());

            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ บันทึก "${confirmedData.foodName}" แล้ว'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context); // ปิด screen
          },
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      setState(() => _isAnalyzing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ $e')),
      );
    }
  }

  MealType _guessMealType() {
    final hour = DateTime.now().hour;
    if (hour < 10) return MealType.breakfast;
    if (hour < 14) return MealType.lunch;
    if (hour < 17) return MealType.snack;
    return MealType.dinner;
  }
}
```

---

### Step 6: เพิ่มปุ่มสแกนในหน้า Health

**ไฟล์:** ที่เหมาะสมที่สุดคือเพิ่มใน FAB หรือ action button ของ health page

**ทางเลือกที่ 1:** เพิ่มใน AppBar ของ health_timeline_tab.dart

**ทางเลือกที่ 2:** เพิ่มเป็น option ใน FAB menu ที่มีอยู่แล้ว

**แนะนำ:** เพิ่มเป็นปุ่มใน health_timeline_tab.dart (ส่วน empty state หรือ appbar)

**หาตำแหน่งที่เหมาะสมในแอพ** (อาจเป็น BottomSheet ตอนกดปุ่ม + ของ health page) แล้วเพิ่ม:

```dart
ListTile(
  leading: const Icon(Icons.qr_code_scanner, color: AppColors.health),
  title: const Text('สแกนบาร์โค้ด'),
  subtitle: const Text('สแกนบาร์โค้ดสินค้าอาหาร'),
  onTap: () {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
  },
),
ListTile(
  leading: const Icon(Icons.receipt_long, color: AppColors.health),
  title: const Text('สแกนฉลากโภชนาการ'),
  subtitle: const Text('ถ่ายรูป Nutrition Facts Label'),
  onTap: () {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NutritionLabelScreen()),
    );
  },
),
```

**อย่าลืม import:**
```dart
import 'barcode_scanner_screen.dart';
import 'nutrition_label_screen.dart';
```

---

## ⚠️ ข้อควรระวัง

1. **`mobile_scanner` ต้อง minSdkVersion >= 21** (Android) - ตรวจสอบใน `android/app/build.gradle`
2. **iOS ต้อง minimum iOS 12.0** - ตรวจสอบใน `ios/Podfile`
3. **Camera permission** ต้อง request ก่อนใช้ - `mobile_scanner` จัดการให้อัตโนมัติ แต่ต้องมี permission ใน manifest
4. **Frame capture จาก `mobile_scanner`** อาจไม่ได้ทุกเครื่อง → มี fallback ถ่ายรูปเอง
5. **Gemini ไม่สามารถ lookup barcode number ได้** → ต้องพึ่งรูปภาพเป็นหลัก
6. **ทดสอบ:** สแกนสินค้าที่มีฉลากชัดๆ ก่อน เช่น นม, ขนม, เครื่องดื่ม

---

## ✅ Definition of Done

- [ ] `flutter pub add mobile_scanner` สำเร็จ
- [ ] Camera permission ตั้งค่าเรียบร้อย (Android + iOS)
- [ ] สแกนบาร์โค้ด → เห็น barcode number
- [ ] จับ frame → ส่ง Gemini → ได้ผลวิเคราะห์
- [ ] GeminiAnalysisSheet แสดงผล → ปรับ serving → ยืนยัน → บันทึก FoodEntry
- [ ] ถ่ายรูปฉลากโภชนาการ → Gemini อ่านค่าได้ถูกต้อง
- [ ] Auto-save ingredient ทำงาน
- [ ] สินค้าที่สแกนแล้ว ปรากฏใน My Meal > วัตถุดิบ

---

## 📁 ไฟล์ที่สร้าง/แก้ไข

```
pubspec.yaml                                    ← EDIT (mobile_scanner)
android/app/src/main/AndroidManifest.xml        ← EDIT (camera permission)
ios/Runner/Info.plist                            ← EDIT (camera description)
lib/
├── core/
│   └── ai/
│       └── gemini_service.dart                 ← EDIT (2 methods ใหม่ + refactor)
└── features/
    └── health/
        └── presentation/
            ├── barcode_scanner_screen.dart       ← NEW
            ├── nutrition_label_screen.dart       ← NEW
            └── health_timeline_tab.dart          ← EDIT (เพิ่มปุ่มสแกน)
```
