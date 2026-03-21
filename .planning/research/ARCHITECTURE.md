# Architecture Patterns — ARscan Integration

**Domain:** Real-time AR food detection for calorie tracking app (Flutter)
**Researched:** 2026-03-16
**Confidence:** HIGH (based on existing codebase analysis + verified Flutter/ML Kit documentation)

---

## Executive Summary

ARscan adds real-time video-based food detection with bounding box overlay, multi-angle auto-capture, and zero-tap Gemini analysis to the existing ArCal calorie tracker. The architecture must integrate cleanly with the established patterns (Riverpod, feature-based directories, Isar, existing camera→preview→analysis flow) while introducing new capabilities: continuous camera streaming, on-device ML inference, state machine for multi-step capture, and multi-image Gemini analysis.

The key architectural decision is to **create a new `arscan/` feature module** that is self-contained but connects to the existing analysis pipeline at the `ImageAnalysisPreviewScreen` / `AnalysisProvider` level. ML Kit Object Detection (with food coarse classification) handles real-time detection, while the existing Gemini backend handles final nutritional analysis.

---

## Recommended Architecture

### System Overview

```
┌─────────────────────────────────────────────────────┐
│                    ARScan Screen                     │
│  ┌───────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  Camera    │  │  Bounding    │  │  Guidance     │  │
│  │  Preview   │  │  Box Overlay │  │  UI Overlay   │  │
│  └─────┬─────┘  └──────┬───────┘  └──────────────┘  │
│        │               │                             │
│  ┌─────▼─────────────────▼────────────────────────┐  │
│  │         ARScanController (StateNotifier)        │  │
│  │  States: idle → detecting → locking →           │  │
│  │          capturing[1,2,3] → analyzing           │  │
│  └─────┬──────────┬──────────┬────────────────────┘  │
│        │          │          │                        │
└────────┼──────────┼──────────┼────────────────────────┘
         │          │          │
    ┌────▼────┐ ┌───▼───┐ ┌───▼──────────┐
    │ Camera  │ │ Food  │ │ Capture      │
    │ Stream  │ │Detect │ │ Manager      │
    │ Service │ │Service│ │ (3 images)   │
    └─────────┘ └───────┘ └───────┬──────┘
                                  │
                    ┌─────────────▼─────────────┐
                    │  Existing Analysis Pipeline │
                    │  FoodEntry → AnalysisProvider│
                    │  → Gemini Backend (multi-img)│
                    └─────────────────────────────┘
```

### Component Boundaries

| Component | Responsibility | Location | Communicates With |
|-----------|---------------|----------|-------------------|
| **ARScanScreen** | Full-screen camera UI with AR overlays | `lib/features/arscan/presentation/arscan_screen.dart` | ARScanController, CameraStreamService |
| **ARScanController** | State machine orchestrating the capture flow | `lib/features/arscan/logic/arscan_controller.dart` | FoodDetectionService, CaptureManager, existing AnalysisProvider |
| **FoodDetectionService** | ML Kit Object Detection wrapper for food bounding boxes | `lib/features/arscan/services/food_detection_service.dart` | ML Kit native APIs |
| **CaptureManager** | Manages capture of 3 high-quality images at different angles | `lib/features/arscan/services/capture_manager.dart` | CameraController, file system |
| **BoundingBoxPainter** | CustomPainter for real-time bounding box rendering | `lib/features/arscan/widgets/bounding_box_painter.dart` | ARScanController (reads detection state) |
| **GuidanceOverlay** | On-screen instructions for camera positioning | `lib/features/arscan/widgets/guidance_overlay.dart` | ARScanController (reads current phase) |
| **CaptureProgressIndicator** | Shows 1/3, 2/3, 3/3 capture progress | `lib/features/arscan/widgets/capture_progress.dart` | ARScanController |

### Data Flow

```
1. CameraController.startImageStream()
   │
   ▼
2. CameraImage (30fps raw frames)
   │
   ├──▶ [Throttle to ~10fps]
   │
   ▼
3. InputImage.fromBytes() conversion (platform-specific)
   │
   ▼
4. FoodDetectionService.processFrame(inputImage)
   │  ├── ObjectDetector (stream mode, classification ON)
   │  └── Returns: List<DetectedFood> (boundingBox, label, trackingId, confidence)
   │
   ▼
5. ARScanController receives detection results
   │  ├── Updates bounding box overlay (every frame)
   │  ├── Evaluates stability (same object tracked for N frames)
   │  └── Triggers auto-capture when conditions met
   │
   ▼
6. Auto-capture: stopImageStream → takePicture → copy to permanent path
   │  (or use concurrent capture if camera plugin version supports it)
   │
   ▼
7. After 3 angles captured:
   │  ├── Create FoodEntry with source = DataSource.arScanned
   │  ├── Store all 3 image paths (primary + supplementary)
   │  └── Enqueue in AnalysisProvider for Gemini multi-image analysis
   │
   ▼
8. AnalysisProvider → GeminiService.analyzeFoodImage() (extended for multi-image)
   │
   ▼
9. Result → Update FoodEntry → Refresh providers → Navigate to timeline
```

---

## Directory Structure

Following the existing feature-based organization:

```
lib/features/arscan/
├── presentation/
│   └── arscan_screen.dart          # Full-screen AR camera UI
├── logic/
│   └── arscan_controller.dart      # State machine (StateNotifier)
├── services/
│   ├── food_detection_service.dart # ML Kit ObjectDetector wrapper
│   └── capture_manager.dart        # Multi-angle image capture
├── widgets/
│   ├── bounding_box_painter.dart   # CustomPainter for detection boxes
│   ├── guidance_overlay.dart       # User instructions overlay
│   ├── capture_progress.dart       # 3-angle progress indicator
│   └── angle_thumbnail.dart        # Mini preview of captured angles
├── models/
│   ├── detected_food.dart          # Detection result model
│   ├── arscan_state.dart           # State machine states (sealed class)
│   └── capture_session.dart        # Tracks 3 captured images
└── providers/
    └── arscan_providers.dart       # Riverpod providers
```

---

## Patterns to Follow

### Pattern 1: State Machine with Sealed Classes (ARScanController)

The multi-angle capture flow is a classic state machine. Using sealed classes with Riverpod's StateNotifier ensures all states are handled exhaustively in the UI.

**State definitions:**

```dart
sealed class ARScanState {
  const ARScanState();
}

class ARScanIdle extends ARScanState {
  const ARScanIdle();
}

class ARScanDetecting extends ARScanState {
  final List<DetectedFood> detections;
  final int stableFrameCount;
  const ARScanDetecting({required this.detections, required this.stableFrameCount});
}

class ARScanLocking extends ARScanState {
  final DetectedFood target;
  final int lockProgress; // 0-100
  const ARScanLocking({required this.target, required this.lockProgress});
}

class ARScanCapturing extends ARScanState {
  final int currentAngle; // 1, 2, or 3
  final int totalAngles; // 3
  final List<String> capturedPaths;
  final String? guidanceText; // "Move camera to the right"
  const ARScanCapturing({
    required this.currentAngle,
    required this.totalAngles,
    required this.capturedPaths,
    this.guidanceText,
  });
}

class ARScanAnalyzing extends ARScanState {
  final List<String> capturedPaths;
  const ARScanAnalyzing({required this.capturedPaths});
}

class ARScanComplete extends ARScanState {
  final int foodEntryId;
  const ARScanComplete({required this.foodEntryId});
}

class ARScanError extends ARScanState {
  final String message;
  const ARScanError({required this.message});
}
```

**State transitions:**

```
idle ──[camera ready]──▶ detecting
detecting ──[food found, stable N frames]──▶ locking
locking ──[lock complete]──▶ capturing(angle=1)
capturing(1) ──[photo taken]──▶ capturing(2)
capturing(2) ──[photo taken]──▶ capturing(3)
capturing(3) ──[photo taken]──▶ analyzing
analyzing ──[enqueued in AnalysisProvider]──▶ complete
complete ──[navigate away]──▶ idle

// Reset transitions:
detecting ──[food lost]──▶ idle
locking ──[food lost]──▶ detecting
capturing ──[food lost between angles]──▶ detecting
any ──[error]──▶ error
error ──[retry]──▶ idle
```

### Pattern 2: Separate Detection Service (NOT extending VisionProcessor)

**Decision:** Create a new `FoodDetectionService` rather than extending `VisionProcessor`.

**Rationale:**
- `VisionProcessor` processes static `File` images (gallery scan flow) — fundamentally different API
- `FoodDetectionService` processes `InputImage` from camera stream — different input, different lifecycle
- `VisionProcessor` uses `ImageLabeler` (classification only, no bounding boxes)
- `FoodDetectionService` uses `ObjectDetector` (bounding boxes + tracking + classification)
- Different lifecycle: `VisionProcessor` is fire-and-forget per image; `FoodDetectionService` maintains tracking state across frames
- Separation of concerns: scanner/gallery scan vs. real-time AR detection

```dart
class FoodDetectionService {
  late final ObjectDetector _detector;
  bool _isProcessing = false;

  FoodDetectionService() {
    final options = ObjectDetectorOptions(
      mode: DetectionMode.stream, // Real-time tracking
      classifyObjects: true,      // Enable coarse classification (food category)
      multipleObjects: true,      // Detect multiple food items
    );
    _detector = ObjectDetector(options: options);
  }

  Future<List<DetectedFood>> processFrame(InputImage inputImage) async {
    if (_isProcessing) return []; // Skip frame if previous still processing
    _isProcessing = true;

    try {
      final objects = await _detector.processImage(inputImage);
      return objects
          .where((obj) => _isFoodObject(obj))
          .map((obj) => DetectedFood.fromDetectedObject(obj))
          .toList();
    } finally {
      _isProcessing = false;
    }
  }

  bool _isFoodObject(DetectedObject obj) {
    // ML Kit coarse classification includes "food" category
    for (final label in obj.labels) {
      if (label.index == 2) return true; // index 2 = food category
      if (label.confidence > 0.5) return true; // generic detection with high confidence
    }
    return false;
  }

  void dispose() {
    _detector.close();
  }
}
```

### Pattern 3: Frame Throttling + InputImage Conversion

Camera streams at 30fps but ML inference can't keep up. Throttle to ~8-10fps and skip frames when detector is busy.

```dart
// In ARScanScreen
DateTime _lastProcessedTime = DateTime.now();
static const _minFrameInterval = Duration(milliseconds: 100); // ~10fps

void _onCameraFrame(CameraImage image) {
  final now = DateTime.now();
  if (now.difference(_lastProcessedTime) < _minFrameInterval) return;
  _lastProcessedTime = now;

  final inputImage = _convertCameraImage(image);
  if (inputImage == null) return;

  ref.read(arScanControllerProvider.notifier).onFrame(inputImage);
}

InputImage? _convertCameraImage(CameraImage image) {
  final camera = _cameras![0];
  final sensorOrientation = camera.sensorOrientation;

  InputImageRotation? rotation;
  if (Platform.isIOS) {
    rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
  } else if (Platform.isAndroid) {
    var rotationCompensation = sensorOrientation;
    // Compensate for device orientation
    rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
  }
  if (rotation == null) return null;

  final format = Platform.isAndroid
      ? InputImageFormat.nv21
      : InputImageFormat.bgra8888;

  // Validate format match
  if (image.format.group == ImageFormatGroup.yuv420 &&
      Platform.isAndroid) {
    // OK: NV21 on Android
  } else if (image.format.group == ImageFormatGroup.bgra8888 &&
      Platform.isIOS) {
    // OK: BGRA on iOS
  } else {
    return null; // Unsupported format
  }

  return InputImage.fromBytes(
    bytes: image.planes[0].bytes,
    metadata: InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: format,
      bytesPerRow: image.planes[0].bytesPerRow,
    ),
  );
}
```

### Pattern 4: Auto-Capture with Stability Detection

Don't capture immediately when food is detected — wait for stable tracking to ensure the user has positioned the camera well.

```dart
// In ARScanController
static const int _stableFramesRequired = 15; // ~1.5 seconds at 10fps
static const double _minBoundingBoxArea = 0.05; // 5% of screen area
static const double _maxBoundingBoxArea = 0.80; // 80% of screen area

int _stableFrameCount = 0;
int? _trackedObjectId;

void onFrame(InputImage inputImage) async {
  final detections = await _detectionService.processFrame(inputImage);

  if (detections.isEmpty) {
    _stableFrameCount = 0;
    _trackedObjectId = null;
    state = const ARScanDetecting(detections: [], stableFrameCount: 0);
    return;
  }

  final primary = detections.first;

  // Check if same object is being tracked
  if (primary.trackingId == _trackedObjectId) {
    _stableFrameCount++;
  } else {
    _trackedObjectId = primary.trackingId;
    _stableFrameCount = 1;
  }

  // Check bounding box size (not too small, not too close)
  final areaRatio = primary.boundingBoxAreaRatio;
  if (areaRatio < _minBoundingBoxArea || areaRatio > _maxBoundingBoxArea) {
    state = ARScanDetecting(
      detections: detections,
      stableFrameCount: _stableFrameCount,
    );
    return;
  }

  if (_stableFrameCount >= _stableFramesRequired) {
    // Food is stable — trigger capture
    _triggerCapture(primary);
  } else {
    state = ARScanLocking(
      target: primary,
      lockProgress: (_stableFrameCount * 100 ~/ _stableFramesRequired),
    );
  }
}
```

### Pattern 5: Multi-Image Storage Strategy

Currently `FoodEntry.imagePath` stores a single path. For ARscan's 3-angle capture, add supplementary paths without breaking existing schema.

**Approach: Add `supplementaryImagePaths` field to FoodEntry**

```dart
// In FoodEntry model — add new field (non-breaking)
String? supplementaryImagePaths; // JSON array: '["path2.jpg","path3.jpg"]'

// Helper getters
List<String> get allImagePaths {
  final paths = <String>[];
  if (imagePath != null) paths.add(imagePath!);
  if (supplementaryImagePaths != null) {
    try {
      final list = json.decode(supplementaryImagePaths!) as List;
      paths.addAll(list.cast<String>());
    } catch (_) {}
  }
  return paths;
}
```

This approach:
- **No migration needed** — `supplementaryImagePaths` is nullable
- **Backward compatible** — existing single-image entries work unchanged
- **Isar-friendly** — String field (Isar doesn't support List<String> directly)
- **Primary image** stays in `imagePath` — existing UI shows it without changes

### Pattern 6: Connection to Existing Analysis Pipeline

ARscan's output connects to the existing `AnalysisProvider` → `GeminiService` pipeline. The key integration point is after all 3 images are captured:

```dart
// In ARScanController — after capturing all 3 angles
Future<void> _onAllAnglesCaptured(List<String> paths) async {
  state = ARScanAnalyzing(capturedPaths: paths);

  // 1. Create FoodEntry with primary + supplementary images
  final entry = FoodEntry()
    ..foodName = 'food' // Generic name — Gemini will identify
    ..mealType = _guessMealType()
    ..timestamp = DateTime.now()
    ..imagePath = paths.first // Primary image
    ..supplementaryImagePaths = json.encode(paths.sublist(1))
    ..servingSize = 1.0
    ..servingUnit = 'serving'
    ..calories = 0
    ..protein = 0
    ..carbs = 0
    ..fat = 0
    ..source = DataSource.arScanned // New enum value
    ..isVerified = false;

  final notifier = ref.read(foodEntriesNotifierProvider.notifier);
  await notifier.addFoodEntry(entry);

  // 2. Enqueue for Gemini analysis (reuse existing pipeline)
  final selectedDate = dateOnly(DateTime.now());
  ref.read(analysisProvider.notifier).enqueue(
    entries: [entry],
    selectedDate: selectedDate,
  );

  // 3. Refresh UI providers
  refreshFoodProviders(ref, selectedDate);

  // 4. Navigate back to timeline
  state = ARScanComplete(foodEntryId: entry.id);
}
```

**GeminiService extension for multi-image:**

```dart
// Extend analyzeFoodImage to accept multiple images
static Future<FoodAnalysisResult?> analyzeFoodImage(
  File imageFile, {
  List<File>? supplementaryImages, // NEW: additional angles
  // ... existing params
}) async {
  // If supplementary images provided, encode all and send together
  // Backend prompt includes: "Multiple angles provided for better portion estimation"
}
```

---

## Providers Architecture

### New Providers (in `arscan_providers.dart`)

```dart
// Main state machine controller
final arScanControllerProvider =
    StateNotifierProvider.autoDispose<ARScanController, ARScanState>((ref) {
  return ARScanController(ref);
});

// Camera readiness (separate from scan state)
final arCameraReadyProvider = StateProvider.autoDispose<bool>((ref) => false);

// Detection overlay data (high-frequency updates — separate provider to minimize rebuilds)
final arDetectionOverlayProvider =
    StateProvider.autoDispose<List<DetectedFood>>((ref) => []);

// Capture session progress
final arCaptureSessionProvider =
    StateProvider.autoDispose<CaptureSession?>((ref) => null);
```

**Why `autoDispose`:** ARscan is a full-screen mode the user enters and exits. All state should be cleaned up on exit to free camera resources and ML Kit memory.

**Why separate overlay provider:** Bounding box positions update at ~10fps. Isolating this from the main state machine prevents unnecessary rebuilds of guidance UI and progress indicators when only box positions change.

### Existing Providers — Changes Needed

| Provider | Change | Reason |
|----------|--------|--------|
| `analysisProvider` | No change needed | Already handles queue-based analysis; ARscan just enqueues entries |
| `foodEntriesNotifierProvider` | No change needed | `addFoodEntry()` already accepts any FoodEntry |
| `foodEntriesByDateProvider` | No change needed | Queries by date, works with any source |

### Existing Enums — Addition Needed

```dart
// In core/constants/enums.dart — add new DataSource value
enum DataSource {
  manual,
  galleryScanned,
  aiAnalyzed,
  chatLogged,
  arScanned,     // NEW: captured via ARscan
}
```

---

## Navigation Integration

### Current Bottom Navigation

```
[Dashboard] [My Meals] [Camera] [AI Chat]
     0           1         2        3
```

Camera (index 2) currently opens `CameraScreen` as a fullscreen route.

### Recommended Change: Replace Camera Tab with ARscan

**Option A (Recommended): Replace Camera tab entirely**
- Change tab icon/label from Camera to "Scan" (with AR-style icon)
- Tapping opens `ARScanScreen` as fullscreen route (same pattern as current camera)
- Keep old `CameraScreen` accessible via gallery/manual add flows (it's still useful)
- The old camera is still available from `ImageAnalysisPreviewScreen` "add photo" buttons

```dart
// In HomeScreen._buildBottomNav()
BottomNavigationBarItem(
  icon: const Icon(Icons.center_focus_strong_outlined), // AR-style icon
  activeIcon: const Icon(Icons.center_focus_strong),
  label: L10n.of(context)!.navScan, // New l10n key: "Scan"
),
```

```dart
// In HomeScreen._openFullScreenCamera() → rename to _openARScan()
Future<void> _openARScan() async {
  await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ARScanScreen()),
  );
  // After returning, switch to timeline tab
  if (_currentIndex != 0) {
    setState(() => _currentIndex = 0);
  }
}
```

**Option B (Alternative): FAB overlay**
- Add a FloatingActionButton on top of bottom nav for ARscan
- Keep all 4 existing tabs
- More prominent but breaks standard bottom nav pattern

**Recommendation:** Option A — simpler, follows existing pattern, ARscan replaces the basic camera as the primary capture method.

---

## Thread / Isolate Architecture

### What Runs Where

| Operation | Thread | Reason |
|-----------|--------|--------|
| Camera frame callback | UI thread | Flutter camera plugin requirement |
| Frame throttling logic | UI thread | Lightweight — just timestamp comparison |
| `InputImage` construction | UI thread | Lightweight — metadata assembly |
| ML Kit `ObjectDetector.processImage()` | **Native thread** (auto) | ML Kit internally runs on native background threads via platform channels |
| Bounding box coordinate mapping | UI thread | Simple math on detection results |
| State machine transitions | UI thread | Riverpod StateNotifier |
| `takePicture()` | Native thread (auto) | Camera plugin handles internally |
| Image file copy to permanent path | **Isolate** | I/O-heavy, could stutter UI |
| Base64 encoding for Gemini | **Isolate** | CPU-heavy, must not block UI |

### Key Insight: ML Kit Does NOT Need Dart Isolates

ML Kit's `processImage()` uses platform channels to call native iOS/Android APIs, which run on their own background threads. The Dart call is async and returns when native processing completes. No Dart isolate is needed for this.

**However,** the frame conversion from `CameraImage` to `InputImage.fromBytes()` happens on the UI thread. Keep the frame resolution low (`ResolutionPreset.medium` for stream, `ResolutionPreset.high` for capture) to minimize this overhead.

### Isolate Usage

Use `compute()` for one-off heavy tasks:

```dart
// Image file operations — use isolate to prevent UI jank
Future<String> _copyImageInIsolate(String sourcePath, String destDir) {
  return compute(_copyFile, {'source': sourcePath, 'destDir': destDir});
}

static String _copyFile(Map<String, String> params) {
  final source = File(params['source']!);
  final dest = '${params['destDir']}/${DateTime.now().millisecondsSinceEpoch}.jpg';
  source.copySync(dest);
  return dest;
}
```

---

## Anti-Patterns to Avoid

### Anti-Pattern 1: Processing Every Frame
**What:** Running ML inference on every camera frame (30fps)
**Why bad:** ML Kit can't keep up → frame backlog → memory pressure → crashes
**Instead:** Throttle to ~8-10fps and skip frames when detector is busy (`_isProcessing` guard)

### Anti-Pattern 2: Blocking UI Thread with Image I/O
**What:** Copying captured images or encoding to base64 on main thread
**Why bad:** Causes visible frame drops during capture animation
**Instead:** Use `compute()` for file copy and base64 encoding

### Anti-Pattern 3: Monolithic State
**What:** Putting detection results + capture progress + UI state all in one provider
**Why bad:** Bounding box updates at 10fps would rebuild guidance text, progress indicators, and capture thumbnails
**Instead:** Separate `arDetectionOverlayProvider` (high-frequency) from `arScanControllerProvider` (state transitions)

### Anti-Pattern 4: Extending VisionProcessor for Real-Time Detection
**What:** Adding ObjectDetector capabilities to existing VisionProcessor class
**Why bad:** Completely different API surface (File vs CameraImage), lifecycle (one-shot vs persistent), and purpose (classify vs detect+track)
**Instead:** Create independent `FoodDetectionService` in arscan feature

### Anti-Pattern 5: Custom Navigation for ARscan
**What:** Creating a custom overlay/sheet for ARscan that layers on top of existing screens
**Why bad:** Camera requires full-screen control, lifecycle management (app background), and system UI hiding
**Instead:** Use standard `MaterialPageRoute` fullscreen push (same as current CameraScreen)

---

## Integration Points — Detailed

### Files That Need Modification (Existing)

| File | Change | Impact |
|------|--------|--------|
| `lib/features/health/models/food_entry.dart` | Add `supplementaryImagePaths` field | Low — nullable String, no migration |
| `lib/features/health/models/food_entry.g.dart` | Regenerate with `build_runner` | Auto-generated |
| `lib/core/constants/enums.dart` | Add `DataSource.arScanned` | Low — new enum value, no conflicts |
| `lib/features/home/presentation/home_screen.dart` | Change Camera tab to Scan, update `_openFullScreenCamera` | Medium — navigation change |
| `lib/core/ai/gemini_service.dart` | Extend `analyzeFoodImage` for multi-image | Medium — add optional `supplementaryImages` param |
| `pubspec.yaml` | Add `google_mlkit_object_detection` dependency | Low |
| `lib/l10n/app_en.arb` + `app_th.arb` | Add ARscan-related strings | Low |
| `ios/Podfile` | ML Kit Object Detection pod auto-added | Low |

### Files That Are NEW (Created)

| File | Purpose |
|------|---------|
| `lib/features/arscan/presentation/arscan_screen.dart` | Main AR camera screen with overlays |
| `lib/features/arscan/logic/arscan_controller.dart` | State machine (StateNotifier) |
| `lib/features/arscan/services/food_detection_service.dart` | ML Kit ObjectDetector wrapper |
| `lib/features/arscan/services/capture_manager.dart` | Multi-angle photo capture logic |
| `lib/features/arscan/widgets/bounding_box_painter.dart` | CustomPainter for detection boxes |
| `lib/features/arscan/widgets/guidance_overlay.dart` | User instructions overlay |
| `lib/features/arscan/widgets/capture_progress.dart` | 3-angle capture progress ring |
| `lib/features/arscan/widgets/angle_thumbnail.dart` | Mini preview of captured angles |
| `lib/features/arscan/models/detected_food.dart` | Detection result model |
| `lib/features/arscan/models/arscan_state.dart` | Sealed class state definitions |
| `lib/features/arscan/models/capture_session.dart` | Tracks captured images metadata |
| `lib/features/arscan/providers/arscan_providers.dart` | All Riverpod providers |

---

## Suggested Build Order

Based on dependency analysis and incremental testability:

### Phase 1: Foundation (no UI yet)
1. Add `google_mlkit_object_detection` to `pubspec.yaml`
2. Add `DataSource.arScanned` enum value
3. Add `supplementaryImagePaths` to `FoodEntry` model + regenerate
4. Create `DetectedFood` model
5. Create `ARScanState` sealed classes
6. Create `FoodDetectionService` (can test with static images first)

### Phase 2: Camera Stream + Detection
7. Create `ARScanScreen` with camera preview (no overlays yet)
8. Implement `startImageStream` → throttle → `FoodDetectionService`
9. Create `BoundingBoxPainter` — verify real-time overlay works
10. Create `ARScanController` (detecting state only)

### Phase 3: Auto-Capture + Multi-Angle
11. Implement stability detection logic in controller
12. Create `CaptureManager` for taking + saving photos
13. Implement full state machine (idle → detecting → locking → capturing × 3 → analyzing)
14. Create `GuidanceOverlay` and `CaptureProgressIndicator`

### Phase 4: Pipeline Integration
15. Connect captured images to `FoodEntry` creation
16. Enqueue in `AnalysisProvider` for Gemini analysis
17. Extend `GeminiService.analyzeFoodImage` for multi-image
18. Update navigation (Camera tab → Scan tab)

### Phase 5: Polish
19. Add angle thumbnails during capture
20. Add haptic feedback on capture
21. Add reset-on-food-lost logic
22. Add l10n strings
23. Test on low-end devices (frame rate, memory)

---

## Dependencies — New Packages

| Package | Version | Purpose | Confidence |
|---------|---------|---------|------------|
| `google_mlkit_object_detection` | ^0.15.1 | Real-time object detection with bounding boxes + food classification | HIGH — official Google package, already using other ML Kit packages |

**No other new packages needed.** The existing `camera` package (^0.10.5+5) supports `startImageStream` and `takePicture`. `google_mlkit_commons` is already a transitive dependency from existing ML Kit packages.

---

## Scalability Considerations

| Concern | Current (v2.0) | Future (v3.0+) |
|---------|----------------|----------------|
| Food detection accuracy | ML Kit coarse classification (food category only) | Custom TFLite model for specific food types (rice vs soup vs meat) |
| Number of captured angles | Fixed at 3 | Adaptive — more angles for complex dishes, fewer for simple items |
| Multi-food detection | Detect multiple but capture/analyze one at a time | Select which detected food to analyze from overlay |
| Model updates | Bundled with app | Firebase ML Model hosting for OTA model updates |

---

## Sources

- [google_mlkit_object_detection pub.dev](https://pub.dev/packages/google_mlkit_object_detection) — v0.15.1 docs (HIGH confidence)
- [ML Kit Object Detection docs](https://developers.google.com/ml-kit/vision/object-detection) — food coarse classification (HIGH confidence)
- [Flutter camera startImageStream API](https://pub.dev/documentation/camera/latest/camera/CameraController/startImageStream.html) — (HIGH confidence)
- [Flutter concurrent image capture + streaming PR #4332](https://github.com/flutter/packages/pull/4332) — merged (MEDIUM confidence — verify camera plugin version)
- [Dart Isolates for image processing](https://vibe-studio.ai/insights/using-dart-isolates-for-image-processing-performance) — best practices (MEDIUM confidence)
- [Flutter Riverpod state machine patterns](https://zenn.dev/caphtech/articles/riverpod-and-fsm) — sealed classes + StateNotifier (HIGH confidence)
- Existing codebase analysis: `camera_screen.dart`, `vision_processor.dart`, `home_screen.dart`, `health_provider.dart`, `gemini_service.dart`, `food_entry.dart`, `analysis_provider.dart` — (HIGH confidence, direct observation)
