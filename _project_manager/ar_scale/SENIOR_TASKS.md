# Senior Tasks — AR Scale Ruler System

> **สำหรับ:** Senior Developer / AI Agent  
> **ประเภท:** Logic, Integration, Prompt Engineering  
> **ทำหลังจาก:** Junior ทำ JUNIOR_TASKS.md เสร็จทั้งหมด  
> **อัปเดตล่าสุด:** 1 มี.ค. 2026

---

## 📊 สถานะ

```
Phase 1 (Smart Prompt):        ████████████████████  100% (S1-S3) ✅
Phase 2 (Local Detection):     ████████████████████  100% (S4-S7) ✅
Phase 3 (Real-time AR Camera): ████████████████████  100% (S8-S10) ✅
```

Last updated: 1 มี.ค. 2026 — ทั้ง 3 Phase implement เสร็จแล้ว

---

## Pre-check ก่อนเริ่ม

ตรวจสอบว่า Junior ทำเสร็จแล้ว:

- [ ] J1: Isar schema regenerated
- [ ] J2-J5: Widget ถูกวางในตำแหน่งที่ถูกต้อง
- [ ] J6: Calibration fields ถูก apply ใน entry
- [ ] J7: Barrel export file สร้างแล้ว
- [ ] `flutter analyze` ไม่มี error
- [ ] App build + run ได้ปกติ

---

## Phase 1: Smart Gemini Prompt (S1-S3)

### S1. Implement ScaleCalibrationService Logic

**ไฟล์:** `lib/core/ar_scale/services/scale_calibration_service.dart`

แก้ทุก `TODO: [SENIOR]` ให้ implement จริง:

**Logic ที่ต้อง implement:**

1. `calculatePixelPerCm()`:
   ```
   สูตรหลัก:
   pixelPerCm = longestSidePixels / knownLengthCm
   
   แต่ต้อง handle:
   - ถ้า bounding box aspect ratio ต่างจาก real object > 30%
     → วัตถุเอียง → ใช้ diagonal: sqrt(w² + h²) / knownLengthCm
   - ถ้า aspect ratio ตรง (±15%) → ใช้ longestSide ตรงๆ
   ```

2. `calibrate()`:
   ```
   1. คำนวณ pixelPerCm
   2. ถ้ามี plateBoundingBox:
      - plateDiameter = max(plate.width, plate.height) / pixelPerCm
      - plateArea = π × (diameter/2)²
   3. estimateVolume:
      - plate: π × (d/2)² × 2.5cm (shallow)
      - bowl: π × (d/2)² × 7.0cm (deep) × 0.6 (not full)
   4. adjustConfidenceForPerspective
   5. ถ้า adjusted confidence < 0.65 → return null
   ```

3. `adjustConfidenceForPerspective()`:
   ```
   expectedAspectRatio = knownLengthCm / knownWidthCm
   actualAspectRatio = longestSide / shortestSide
   
   deviation = abs(expected - actual) / expected
   
   ถ้า deviation > 0.5 → confidence × 0.5 (perspective มาก)
   ถ้า deviation > 0.3 → confidence × 0.7
   ถ้า deviation > 0.15 → confidence × 0.85
   อื่นๆ → confidence × 1.0 (ปกติ)
   ```

---

### S2. แก้ Gemini Prompt สำหรับ Image Analysis

**ไฟล์:** `lib/core/ai/gemini_service.dart`

**แก้ method:** `_getImageAnalysisPrompt()`

**เพิ่ม section ใหม่ต่อจาก STEP 4 — CROSS-REFERENCE:**

```
Step 5 — REFERENCE OBJECT DETECTION (for portion accuracy):
Scan the image for standard reference objects placed near the food:
- Cutlery: Fork (~19.5cm), Spoon (~17cm), Knife (~22cm), Chopsticks (~23cm)
- Cards: Credit card (8.56×5.4cm), ID card
- Coins: visible coins of any denomination

If ANY reference object is found near the food:
1. Report it in "reference_objects" array
2. Use the known real-world size to estimate the plate/bowl diameter
3. Use the plate size to more accurately estimate the total food weight (serving_grams)

If NO reference object is found, simply skip the "reference_objects" field.

Add to your JSON response (ONLY if reference objects are found):
"reference_objects": [
  {
    "type": "dining_fork",
    "confidence": 0.92,
    "known_length_cm": 19.5
  }
],
"plate_measurement": {
  "estimated_diameter_cm": 22.5,
  "estimated_area_cm2": 397.6,
  "estimated_volume_ml": 450
}
```

**แก้ method:** `analyzeFoodImage()` 

เพิ่ม logic: ถ้ามี calibrationData → เพิ่ม hint ใน prompt:
```dart
// ถ้ามี local calibration data จาก ML Kit → เพิ่ม hint ให้ Gemini
if (calibrationHint != null) {
  prompt += '\n\n$calibrationHint';
}
```

**เพิ่ม parameter ใหม่ใน `analyzeFoodImage()`:**
```dart
String? calibrationHint, // จาก CalibrationResult.toPromptHint()
```

---

### S3. ทดสอบ Phase 1

1. ถ่ายรูปอาหาร + ช้อน → ส่ง Gemini → ตรวจว่ามี `reference_objects` ใน response
2. ตรวจว่า `FoodAnalysisResult.isCalibrated` = true
3. ตรวจว่า `CalibrationBadge` แสดงบน UI

---

## Phase 2: Local Detection + Enhanced (S4-S7)

### S4. Implement ReferenceDetectorService

**ไฟล์:** `lib/core/ar_scale/services/reference_detector_service.dart`

**แก้ทุก TODO:**

1. `initialize()`:
   ```dart
   import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

   late ObjectDetector _objectDetector;
   
   final options = ObjectDetectorOptions(
     mode: DetectionMode.single,
     classifyObjects: true,
     multipleObjects: true,
   );
   _objectDetector = ObjectDetector(options: options);
   ```

2. `detectFromImage()`:
   ```dart
   final inputImage = InputImage.fromFilePath(imageFile.path);
   final objects = await _objectDetector.processImage(inputImage);
   
   // Filter for reference objects
   for (final obj in objects) {
     for (final label in obj.labels) {
       // Match label.text กับ ReferenceObjectType.mlKitLabels
       // สร้าง DetectedReferenceObject
     }
   }
   ```

3. Handle ML Kit label mapping:
   - ML Kit base model อาจ return generic labels ("Cutlery", "Tableware")
   - ต้อง map กับ ReferenceObjectType อย่างถูกต้อง
   - ถ้า "Cutlery" → ใช้ aspect ratio แยกว่าเป็น fork/spoon/knife
     - aspect ratio > 6:1 → chopsticks
     - aspect ratio > 3:1 → fork or knife
     - aspect ratio 2:1 to 3:1 → spoon

---

### S5. Integrate Detection ใน ImageAnalysisPreviewScreen

**ไฟล์:** `lib/features/health/presentation/image_analysis_preview_screen.dart`

**Flow ใหม่:**
```
1. User ถ่ายรูป / เลือกจาก gallery
2. รูปแสดงใน preview
3. [ใหม่] เรียก ReferenceDetectorService.detectFromImage()
4. [ใหม่] ถ้าเจอ → เรียก ScaleCalibrationService.calibrate()
5. [ใหม่] แสดง ArRulerOverlay ทับรูป
6. [ใหม่] แสดง CalibrationBadge
7. User กด "Save & Analyze"
8. [ใหม่] ส่ง calibrationHint ไปพร้อม Gemini request
```

**สิ่งที่ต้องเพิ่ม:**
- State variables: `_calibrationResult`, `_isDetecting`
- เรียก detect ใน `initState` (หลัง image ready)
- Wrap Image widget ด้วย `ArRulerOverlay`
- ส่ง `CalibrationResult.toPromptHint()` ไปกับ analysis request

---

### S6. Integrate Detection ใน Gallery Scanner

**ไฟล์:** `lib/features/scanner/scan_controller.dart`

**Flow ใหม่:**
```
1. VisionProcessor detect "food" label ✅ (เดิม)
2. [ใหม่] ReferenceDetectorService.detectFromImage() 
3. [ใหม่] ถ้าเจอ reference → ScaleCalibrationService.calibrate()
4. [ใหม่] เก็บ calibration data ใน FoodEntry
5. Gemini analyze later → ใช้ calibrationHint ใน prompt
```

---

### S7. ทดสอบ Phase 2

1. ถ่ายรูปอาหาร + ช้อน → ตรวจว่า overlay แสดงกรอบรอบช้อน
2. ตรวจว่า CalibrationBadge แสดง "Calibrated" หรือ "Estimated"
3. ตรวจว่า confidence < 65% → ไม่แสดง overlay (ส่งปกติ)
4. ตรวจว่า Gemini ได้รับ calibration hint ใน prompt
5. เปรียบเทียบ: รูปเดียวกัน มีช้อน vs ไม่มีช้อน → serving_grams ต่างกันไหม

---

## Phase 3: Real-time AR Camera (S8-S10)

### S8. Implement CameraFrameProcessor

**ไฟล์:** `lib/core/ar_scale/services/camera_frame_processor.dart`

**แก้ TODO:**
```dart
Future<void> processFrame(...) async {
  _isProcessing = true;
  _lastProcessedMs = now;
  
  try {
    final detected = await ReferenceDetectorService.instance
        .detectFromCameraFrame(
          imageBytes: imageBytes,
          imageSize: Size(width.toDouble(), height.toDouble()),
          rotation: rotation,
          rawFormat: rawFormat,
          bytesPerRow: bytesPerRow,
        );
    
    lastDetectedObject = detected;
    onReferenceDetected?.call(detected);
    
    if (detected != null && detected.confidence >= 0.65) {
      final calibration = ScaleCalibrationService.calibrate(
        referenceObject: detected,
        imageWidth: width.toDouble(),
        imageHeight: height.toDouble(),
      );
      lastCalibration = calibration;
      onCalibrationReady?.call(calibration);
    }
  } catch (e) {
    debugPrint('[CameraFrameProcessor] Error: $e');
  } finally {
    _isProcessing = false;
  }
}
```

---

### S9. Integrate Real-time Detection ใน CameraScreen

**ไฟล์:** `lib/features/camera/presentation/camera_screen.dart`

**สิ่งที่ต้องเพิ่ม:**

1. State variables:
   ```dart
   CameraFrameProcessor? _frameProcessor;
   DetectedReferenceObject? _detectedRef;
   CalibrationResult? _liveCalibration;
   bool _isScanning = true;
   ```

2. ใน `_initializeCamera()` หลัง initialize สำเร็จ:
   ```dart
   _frameProcessor = CameraFrameProcessor(
     onReferenceDetected: (ref) {
       if (mounted) setState(() => _detectedRef = ref);
     },
     onCalibrationReady: (cal) {
       if (mounted) setState(() => _liveCalibration = cal);
     },
   );
   
   // เริ่ม image stream
   _cameraController!.startImageStream((CameraImage image) {
     if (!_isScanning) return;
     _frameProcessor!.processFrame(
       imageBytes: image.planes[0].bytes,
       width: image.width,
       height: image.height,
       rotation: _cameras![0].sensorOrientation,
       rawFormat: image.format.raw,
       bytesPerRow: image.planes[0].bytesPerRow,
     );
   });
   ```

3. ใน `build()` Stack, เพิ่ม overlay:
   ```dart
   // Live reference indicator
   if (_detectedRef != null)
     Positioned(
       top: 100,
       left: 0,
       right: 0,
       child: Center(
         child: ReferenceObjectIndicator(
           objectType: _detectedRef!.type,
           confidence: _detectedRef!.confidence,
         ),
       ),
     ),
   
   // Live bounding box
   if (_liveCalibration != null && _liveCalibration!.shouldUseCalibration)
     LiveReferenceBoundingBox(
       boundingRect: _convertToDisplayRect(_detectedRef!.boundingBox),
       tier: _liveCalibration!.tier,
     ),
   ```

4. ใน `_takePicture()`:
   ```dart
   // หยุด image stream ก่อนถ่าย
   _isScanning = false;
   await _cameraController!.stopImageStream();
   
   // ... take picture ...
   
   // ส่ง calibration ไปพร้อมรูป
   Navigator.of(context).pop({
     'file': File(filePath),
     'calibration': _liveCalibration,
   });
   ```

5. Handle `_convertToDisplayRect()`:
   ```dart
   Rect _convertToDisplayRect(BoundingBoxData bbox) {
     // แปลง camera frame coordinates → display coordinates
     // ต้อง handle rotation, mirroring, และ FittedBox scaling
   }
   ```

---

### S10. ทดสอบ Phase 3

1. เปิดกล้อง → ส่องอาหาร + ช้อน → ตรวจว่า overlay แสดง real-time
2. ขยับกล้อง → overlay ต้อง track ตาม
3. เอาช้อนออกจากเฟรม → overlay ต้องหายไป
4. Confidence < 65% → overlay ต้องไม่แสดง
5. ถ่ายรูป → calibration ต้องถูกส่งไปพร้อมรูป
6. ทดสอบ performance: FPS ต้องไม่ drop ต่ำกว่า 20

---

## ⚠️ Edge Cases ที่ต้อง Handle

| Case | การจัดการ |
|------|----------|
| ช้อนถูกอาหารบังบางส่วน | ใช้ส่วนที่เห็น + ลด confidence 20% |
| มีช้อน + ส้อม ในรูปเดียวกัน | เลือกตัวที่ confidence สูงสุด |
| ช้อนอยู่คนละระนาบกับจาน | adjustConfidenceForPerspective() ลด confidence |
| รูปถ่ายเอียง / หมุน | ใช้ EXIF rotation + adjust bounding box |
| ML Kit ไม่รองรับบน Windows | Skip detection, ส่ง Gemini ปกติ (เหมือน VisionProcessor) |
| ช้อนขนาดไม่มาตรฐาน | Gemini จะช่วยยืนยัน/ปรับใน Phase 1 prompt |

---

## 📁 ไฟล์ทั้งหมดที่ Senior ต้องแก้

### Phase 1 (แก้ 1 ไฟล์):
- `lib/core/ar_scale/services/scale_calibration_service.dart` — implement logic
- `lib/core/ai/gemini_service.dart` — เพิ่ม prompt section + parameter

### Phase 2 (แก้ 3 ไฟล์):
- `lib/core/ar_scale/services/reference_detector_service.dart` — ML Kit integration
- `lib/features/health/presentation/image_analysis_preview_screen.dart` — overlay + detection
- `lib/features/scanner/scan_controller.dart` — gallery scan integration

### Phase 3 (แก้ 2 ไฟล์):
- `lib/core/ar_scale/services/camera_frame_processor.dart` — real-time processing
- `lib/features/camera/presentation/camera_screen.dart` — live overlay + stream

---

## 🔑 Dependency Order

```
Phase 1 → ไม่ depend อะไร, ทำได้เลย
Phase 2 → depend Phase 1 (ต้องมี calibration logic ก่อน)
Phase 3 → depend Phase 2 (ต้องมี detector service ก่อน)
```
