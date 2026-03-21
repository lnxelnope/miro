# Technology Stack — ARscan Feature

**Project:** ArCal - AI Calorie Counter (v2.0 ARscan milestone)
**Researched:** 2026-03-16
**Focus:** Stack additions for real-time food detection with bounding boxes, multi-angle auto-capture

---

## Recommended Stack Additions

### 1. Real-Time Object Detection — `google_mlkit_object_detection`

| Field | Value |
|-------|-------|
| **Package** | `google_mlkit_object_detection` |
| **Version** | `^0.15.1` |
| **Purpose** | Real-time object detection with bounding boxes + tracking on camera stream |
| **Confidence** | HIGH — pub.dev verified, same publisher as existing ML Kit packages |

**Why this package:**
- Provides **bounding box coordinates** for detected objects — exactly what ARscan needs
- Built-in **STREAM_MODE** optimized for real-time video feed processing (low-latency)
- **Object tracking** with unique IDs across successive frames — critical for tracking food as camera moves
- **Coarse classification** into 5 categories including **"Food"** — immediate food detection without custom model
- Detects up to **5 objects simultaneously** with bounding boxes
- **Custom TFLite model support** via `LocalObjectDetectorOptions` — future upgrade path for food-specific detection
- **Same ecosystem** as existing `google_mlkit_image_labeling`, `google_mlkit_text_recognition`, `google_mlkit_barcode_scanning` — shared `google_mlkit_commons` dependency, proven integration pattern
- Already compatible with project's iOS 15.5+ and Android API 21+ targets

**Integration with existing code:**
- `VisionProcessor` (`lib/features/scanner/services/vision_processor.dart`) already uses `InputImage.fromFile()` — ARscan will use `InputImage.fromBytes()` for camera stream frames
- Shared `google_mlkit_commons` handles `CameraImage` → `InputImage` conversion for both platforms

### 2. Camera Stream Processing — `camera` (upgrade existing)

| Field | Value |
|-------|-------|
| **Package** | `camera` |
| **Version** | `^0.12.0` (upgrade from current `^0.10.5+5`) |
| **Purpose** | Camera preview + `startImageStream()` for frame-by-frame ML processing |
| **Confidence** | HIGH — pub.dev verified, official Flutter team package |

**Why upgrade (not replace):**
- Already in the project (`^0.10.5+5`) with working `CameraScreen`
- `startImageStream()` API provides `CameraImage` objects for real-time ML inference
- v0.12.0 includes stability fixes for Android CameraX image streaming
- No need for a new camera package — existing one supports everything needed
- `CameraPreview` widget already integrated in `camera_screen.dart`

**Critical configuration for ARscan:**
```dart
CameraController(
  camera,
  ResolutionPreset.medium,  // lower than current .high for stream perf
  enableAudio: false,
  imageFormatGroup: Platform.isAndroid
    ? ImageFormatGroup.nv21      // required for ML Kit on Android
    : ImageFormatGroup.bgra8888, // required for ML Kit on iOS
);
```

**Known limitations (with mitigations):**
- CameraX `startImageStream` can randomly stop → implement reconnection logic
- OOM risk when main thread busy → frame throttling + `isProcessing` flag (skip frames during inference)
- Cannot combine image stream + image capture simultaneously on some devices → stop stream before `takePicture()`, restart after

### 3. Device Orientation Sensing — `sensors_plus`

| Field | Value |
|-------|-------|
| **Package** | `sensors_plus` |
| **Version** | `^6.1.2` |
| **Purpose** | Accelerometer + gyroscope data for device angle detection (multi-angle capture guidance) |
| **Confidence** | HIGH — pub.dev verified, flutter.dev community plus plugin |

**Why this package:**
- Provides `accelerometerEventStream` for detecting device tilt angle relative to gravity
- X/Y/Z accelerometer values → calculate pitch/roll angles to determine viewing angle
- Used to guide user through 3 distinct capture angles (top-down, 45°, side)
- `gyroscopeEventStream` detects device rotation → reset tracking when camera moves away
- Configurable `samplingPeriod` for performance tuning
- Lightweight (no heavy native dependencies)

**Angle calculation pattern:**
```dart
// pitch = atan2(y, sqrt(x² + z²)) → tilt forward/back
// roll = atan2(x, sqrt(y² + z²)) → tilt left/right
// Use pitch to classify: ~90° = top-down, ~45° = angled, ~0° = side view
```

**Platform requirements:**
- iOS 12.0+ (project targets 15.5+ ✓)
- Android compileSDK 34 (project targets 35 ✓)
- iOS: requires `NSMotionUsageDescription` in Info.plist

---

## Existing Packages — No Changes Needed

| Package | Current Version | ARscan Role |
|---------|----------------|-------------|
| `google_mlkit_commons` | (transitive dep) | `InputImage` conversion from `CameraImage` — shared by object detection and existing labeling |
| `google_mlkit_image_labeling` | `any` | Existing retro-scan food classification — NOT used in ARscan real-time path |
| `permission_handler` | `^12.0.1` | Camera permission management — already handles camera access |
| `path_provider` | `^2.1.2` | Save captured images to app documents directory |

---

## Bounding Box Overlay — No Package Needed

**Use Flutter's built-in `CustomPainter` + `Stack` widget.**

| Component | Implementation |
|-----------|---------------|
| **Overlay rendering** | `CustomPaint` widget stacked above `CameraPreview` |
| **Box drawing** | `CustomPainter.paint()` with `canvas.drawRect()` using `DetectedObject.boundingBox` |
| **Coordinate translation** | Scale bounding box from camera resolution to screen preview size |
| **Animation** | `AnimationController` for smooth box transitions between frames |
| **Labels** | `canvas.drawParagraph()` for "Food" label + confidence above bounding box |

**Why no package:**
- Flutter `CustomPainter` is purpose-built for this exact use case
- google_mlkit_flutter example repo provides `coordinates_translator.dart` reference implementation
- Full control over visual style (animated corners, pulsing effect, color-coded confidence)
- Zero additional dependency weight

---

## What NOT to Add

### AR Packages (ARCore/ARKit) — NOT NEEDED

| Package | Why Skip |
|---------|----------|
| `ar_flutter_plugin` | Unmaintained since 2022. ARscan needs bounding box overlay, not 3D object placement |
| `ar_flutter_plugin_2` | Community fork — adds 3D models, plane detection, cloud anchors. None of this is needed |
| `augen` | Full AR framework. Massive SDK size increase for zero benefit |

**Rationale:** ARscan's "AR" is a camera preview with 2D bounding box overlays + guidance UI. This is `CustomPainter` over `CameraPreview`, not augmented reality. AR SDKs add 50-100MB to app size with complex native dependencies — all for features (plane detection, 3D models, spatial mapping) that ARscan explicitly doesn't need.

### `ultralytics_yolo` — NOT RECOMMENDED for v2.0

| Aspect | Issue |
|--------|-------|
| **Version** | v0.2.0 — still pre-1.0, limited production validation |
| **Overlap** | ML Kit object detection already provides bounding boxes + tracking + food classification |
| **Model size** | YOLOv8 TFLite is 12+ MB vs ML Kit base model bundled in SDK |
| **Complexity** | Requires bundling and managing separate model files |

**Future consideration:** If ML Kit base model's "food" classification proves too coarse (Phase-specific research flag), custom YOLOv8 trained on food datasets could be explored. But ML Kit is the correct starting point — zero model management, proven on-device performance, same ecosystem.

### `tflite_flutter` — DEFER to Phase 2 (if needed)

| Aspect | Details |
|--------|---------|
| **Version** | `^0.12.1` (tensorflow.org publisher) |
| **When needed** | Only if ML Kit base model + `LocalObjectDetectorOptions` with custom model is insufficient |
| **Why defer** | ML Kit's custom model pipeline (`LocalObjectDetectorOptions`) provides TFLite model loading natively. Adding `tflite_flutter` separately would duplicate inference capabilities. Only needed if running a model OUTSIDE of ML Kit's object detection pipeline |

---

## Model Strategy

### Phase 1: ML Kit Base Model (Immediate)

```dart
final options = ObjectDetectorOptions(
  mode: DetectionMode.stream,
  classifyObjects: true,
  multipleObjects: true,
);
final objectDetector = ObjectDetector(options: options);
```

- Built-in "Food" category detection — bounding box appears around food items
- Zero model management — bundled in SDK
- Tracking IDs for stable box rendering across frames
- **Sufficient for:** detecting food presence, drawing bounding boxes, triggering auto-capture

### Phase 2: Custom Food TFLite Model (If Needed)

```dart
final modelPath = await getModelPath('assets/ml/food_detector.tflite');
final options = LocalObjectDetectorOptions(
  mode: DetectionMode.stream,
  modelPath: modelPath,
  classifyObjects: true,
  multipleObjects: true,
);
final objectDetector = ObjectDetector(options: options);
```

- Custom YOLOv8-based model trained on food datasets (Roboflow, Open Images Food subset)
- Export as TFLite via `model.export(format='tflite')` with INT8 quantization (~3-5 MB)
- Load via ML Kit's `LocalObjectDetectorOptions` — no `tflite_flutter` dependency needed
- **When to trigger:** if base model's food detection rate < 80% in real-world testing
- **Research flag:** Needs phase-specific research for dataset selection and model training

---

## Architecture Integration

### Camera Stream → ML Kit → CustomPainter Pipeline

```
┌─────────────┐    startImageStream()    ┌──────────────────┐
│  camera      │ ──────────────────────→ │  CameraImage     │
│  (^0.12.0)   │                         │  (raw bytes)     │
└─────────────┘                          └────────┬─────────┘
                                                  │
                                    InputImage.fromBytes()
                                                  │
                                         ┌────────▼─────────┐
                                         │  ML Kit Object   │
                                         │  Detection       │
                                         │  (STREAM_MODE)   │
                                         └────────┬─────────┘
                                                  │
                                    List<DetectedObject>
                                    (boundingBox, labels, trackingId)
                                                  │
                              ┌────────────────────┼──────────────────┐
                              │                    │                  │
                    ┌─────────▼──────┐  ┌──────────▼────────┐  ┌─────▼──────┐
                    │ CustomPainter  │  │  Angle Tracker     │  │  Auto-     │
                    │ (bounding box  │  │  (sensors_plus     │  │  Capture   │
                    │  overlay)      │  │   accelerometer)   │  │  Logic     │
                    └────────────────┘  └───────────────────┘  └────────────┘
```

### Frame Processing Strategy

```dart
// Throttle: process 1 frame every ~200ms (5 FPS detection is sufficient)
bool _isDetecting = false;
DateTime _lastProcessed = DateTime.now();

void _onCameraFrame(CameraImage image) {
  if (_isDetecting) return;
  if (DateTime.now().difference(_lastProcessed).inMilliseconds < 200) return;

  _isDetecting = true;
  _lastProcessed = DateTime.now();

  final inputImage = _inputImageFromCameraImage(image);
  if (inputImage == null) { _isDetecting = false; return; }

  _objectDetector.processImage(inputImage).then((objects) {
    // Update bounding box overlay
    // Check for food objects → update capture state
    _isDetecting = false;
  });
}
```

### Multi-Angle Capture Flow

```
sensors_plus accelerometer
         │
    pitch angle calculation
         │
    ┌────▼────────────────────────────┐
    │  Angle Classifier               │
    │  • 70-90° → "top-down"  (1/3)  │
    │  • 35-55° → "angled"    (2/3)  │
    │  • 0-20°  → "side"     (3/3)  │
    └────┬────────────────────────────┘
         │
    Auto-capture when:
    1. Food detected (ML Kit bounding box present)
    2. Angle is within target range
    3. Device is stable (gyroscope shows low rotation)
    4. This angle not yet captured
```

---

## Dependency Changes Summary

### pubspec.yaml Additions

```yaml
# ARscan — Real-time Object Detection
google_mlkit_object_detection: ^0.15.1

# ARscan — Device Angle Sensing
sensors_plus: ^6.1.2
```

### pubspec.yaml Modifications

```yaml
# Upgrade for startImageStream stability
camera: ^0.12.0  # was ^0.10.5+5
```

### Platform Configuration

**Android (`android/app/build.gradle.kts`):**
```kotlin
android {
    aaptOptions {
        noCompress += "tflite"  // for future custom model support
    }
}
```

**iOS (`ios/Runner/Info.plist`):**
```xml
<key>NSMotionUsageDescription</key>
<string>Used to detect camera angle for food scanning</string>
```

---

## Alternatives Considered

| Category | Recommended | Alternative | Why Not |
|----------|-------------|-------------|---------|
| Object Detection | `google_mlkit_object_detection` | `ultralytics_yolo` (v0.2.0) | Pre-1.0, requires bundled model, ML Kit already in project ecosystem |
| Object Detection | `google_mlkit_object_detection` | `tflite_flutter` + custom model | Overkill — ML Kit has built-in custom model support via LocalObjectDetectorOptions |
| Camera | `camera` (upgrade) | `camerawesome` | Different API, migration cost, camera already working |
| Bounding Box | `CustomPainter` (built-in) | `ar_flutter_plugin_2` | AR SDK adds 50-100MB for no benefit; we only need 2D overlays |
| Angle Detection | `sensors_plus` | `native_device_orientation` | sensors_plus provides raw data for flexible angle math; native_device_orientation only gives 4 orientations |

---

## Sources

- [google_mlkit_object_detection v0.15.1](https://pub.dev/packages/google_mlkit_object_detection) — pub.dev (HIGH confidence)
- [ML Kit Object Detection API](https://developers.google.com/ml-kit/vision/object-detection) — Google official docs (HIGH confidence)
- [google_mlkit_commons v0.11.1](https://pub.dev/packages/google_mlkit_commons) — InputImage conversion reference (HIGH confidence)
- [camera v0.12.0](https://pub.dev/packages/camera) — pub.dev, Flutter official (HIGH confidence)
- [tflite_flutter v0.12.1](https://pub.dev/packages/tflite_flutter) — pub.dev, tensorflow.org publisher (HIGH confidence)
- [sensors_plus v6.1.2](https://pub.dev/packages/sensors_plus) — pub.dev (HIGH confidence)
- [Flutter real-time object detection patterns](https://medium.com/@cia1099/approached-60-fps-object-detection-without-any-frame-dropout-on-mobile-devices-with-flutter-6ab3c9dc5c4b) — Community article (MEDIUM confidence)
- [YOLOv8 food detection study](https://etasr.com/index.php/ETASR/article/view/14810) — Academic paper Dec 2025 (MEDIUM confidence)
- [CameraX startImageStream limitations](https://github.com/flutter/flutter/issues/152763) — GitHub issue (HIGH confidence)
