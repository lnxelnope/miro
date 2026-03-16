# Pitfalls Research

**Domain:** Adding ARscan (real-time food detection + multi-angle auto-capture) to existing Flutter calorie app
**Researched:** 2026-03-16
**Confidence:** HIGH

## Critical Pitfalls

### Pitfall 1: Camera Stream Memory Leak on Physical Devices

**What goes wrong:**
`CameraController.startImageStream()` causes progressive memory leaks on physical devices, eventually exceeding 2GB and crashing the app. The leak scales with resolution — `ResolutionPreset.high` leaks much faster than `ResolutionPreset.low`. This problem does NOT appear on simulators/emulators, so developers assume it works until production deployment.

**Why it happens:**
On iOS, `textureRegistry.register` / `textureRegistry.textureFrameAvailable` / `textureRegistry.unregisterTexture` leak `IOSurface` objects. On Android, CameraImage buffers from `startImageStream()` are not properly released by the Dart GC, especially when ML processing delays frame consumption. Each unprocessed frame stays in memory. The camera plugin allocates new buffers faster than the GC can collect old ones.

**How to avoid:**
1. Use `ResolutionPreset.medium` (not `high`) for the streaming camera — ML detection doesn't need 1080p
2. Implement a strict `_isBusy` flag: skip frames entirely while ML inference is running — never queue them
3. Throttle stream processing to 10-15 FPS max (skip frames with timestamp-based gating)
4. Call `stopImageStream()` before `dispose()` — never dispose while stream is active
5. Monitor memory during development with Xcode Instruments (iOS) and Android Profiler

**Warning signs:**
- App works on simulator but crashes on physical device after 2-5 minutes
- Xcode memory graph shows linear growth without plateau
- `didReceiveMemoryWarning` callbacks increase over time
- Frame processing callback queue grows unbounded

**Phase to address:**
Phase: Camera Stream Infrastructure — must be the first thing validated on physical devices

---

### Pitfall 2: Camera Lifecycle Race Conditions

**What goes wrong:**
`CameraController` crashes when disposed during active image streaming, or when app lifecycle changes (background/foreground) happen during ML processing. Common errors: "Session has been closed", "No handler given, and current thread has no looper", "ChangeNotifier used after dispose". The existing `CameraScreen` handles lifecycle properly for single-shot capture, but streaming adds entirely new failure modes.

**Why it happens:**
1. `startImageStream` creates asynchronous callbacks that continue after `dispose()` is called
2. `AppLifecycleState.inactive` triggers while an ML inference is mid-flight on a stream frame
3. `stopImageStream()` called on an already-disposed or uninitialized controller
4. On Android CameraX, recreating a controller immediately after dispose fails because the browser/OS hasn't fully released MediaStream resources (needs ~100ms delay)
5. The existing `CameraScreen` already handles basic lifecycle (dispose camera on inactive, reinitialize on resume), but the ARscan must also stop/restart the image stream and ML detector

**How to avoid:**
1. Add a `_streamActive` boolean tracked separately from `_isInitialized`
2. Always `stopImageStream()` → wait → `dispose()` (never dispose while streaming)
3. Add 100-200ms delay between `dispose()` and re-initialization
4. Guard every stream callback with `if (!mounted || _cameraController == null) return`
5. Cancel any pending ML inference when lifecycle changes
6. Use a `Completer` or mutex to prevent concurrent init/dispose operations

**Warning signs:**
- Intermittent crashes when switching apps or receiving phone calls
- Black camera preview after returning from background
- PlatformException on Android when rapid navigation in/out of ARscan

**Phase to address:**
Phase: Camera Stream Infrastructure — lifecycle management must be bulletproof before adding ML processing on top

---

### Pitfall 3: ML Kit Base Model Cannot Detect "Food" as Category

**What goes wrong:**
Developers assume `google_mlkit_object_detection` base model can detect food and draw bounding boxes around it. In reality, ML Kit's base object detection model only classifies objects into 5 broad categories: fashion goods, food, home goods, places, and plants. It detects "an object is present" and can label it as "food" — but it cannot distinguish specific food types, and its bounding box accuracy for food on plates is mediocre compared to purpose-trained models.

**Why it happens:**
ML Kit object detection is designed for general-purpose use cases (shopping, inventory). The "food" category is extremely broad. A plate with multiple dishes may get a single bounding box around the entire plate, or the model may detect the plate/table instead of the food. Developers confuse "image labeling" (which ArCal already uses — detects food labels like "Rice", "Pizza") with "object detection" (draws bounding boxes).

**How to avoid:**
1. Test ML Kit object detection with real Thai/Asian food images early — base model performance varies significantly by cuisine type
2. Consider using a custom TFLite model (e.g., fine-tuned YOLOv8/MobileNet on food datasets) for better bounding box accuracy
3. Fallback: use ML Kit object detection for "something is in frame" + image labeling for "it's food" = combined signal to trigger capture
4. Don't expect per-food-item bounding boxes from base model — if user has rice + curry + som tam on a table, base model may return one big box
5. The existing `VisionProcessor` image labeling (food labels with confidence > 0.7) is actually more reliable for food detection — integrate it with object detection

**Warning signs:**
- Bounding box wraps entire table/plate instead of individual food items
- Low confidence scores (<0.5) on real food images with base model
- Model detects "home goods" (plate, bowl) instead of food content
- Different results between Android and iOS for same image

**Phase to address:**
Phase: ML Model Selection & Validation — must validate detection quality BEFORE building the bounding box UI overlay

---

### Pitfall 4: iOS vs Android ML Performance Gap (2-10x)

**What goes wrong:**
ARscan feels smooth and responsive on iOS but laggy/janky on Android. Frame processing that takes 20ms on iPhone takes 50-200ms on mid-range Android phones. Warm-up period on Android means first 30+ frames are extremely slow. Developers test on flagship Android phones and miss the gap.

**Why it happens:**
iOS has dedicated Neural Engine hardware (8-16 cores on iPhone 12+) that ML Kit/CoreML automatically leverages for 15x faster inference than CPU, with 1/10th power consumption. Android uses TensorFlow Lite with generic CPU, optional NNAPI/GPU delegates that vary wildly by device manufacturer and SoC. ML Kit on Android reports 10-50x slower inference than the same model on iOS in some cases. CameraX (now default Flutter camera backend on Android) adds additional overhead compared to Camera2.

**How to avoid:**
1. Set different FPS targets per platform: iOS 15 FPS, Android 10 FPS (or even 5 FPS on older devices)
2. Detect device capabilities at startup — adjust processing rate accordingly
3. Test on mid-range Android phones (not just Pixel/Samsung flagship): devices with MediaTek/Exynos SoCs
4. Enable NNAPI delegate on Android for hardware acceleration where available
5. Use `ResolutionPreset.medium` on Android, can use `high` on iOS
6. Pre-warm the ML model with a dummy image on first launch to avoid cold-start lag
7. Show a "warming up" indicator for the first few frames

**Warning signs:**
- Frame rate below 10 FPS on Android during ML processing
- UI thread jank when ML inference runs on main thread
- Battery drain complaints from Android users but not iOS
- Bounding box overlay visibly lagging behind camera movement on Android

**Phase to address:**
Phase: ML Integration & Optimization — platform-specific tuning after basic detection works

---

### Pitfall 5: Existing ML Kit Package Conflicts When Adding Object Detection

**What goes wrong:**
Adding `google_mlkit_object_detection` causes build failures, duplicate symbol errors, or runtime crashes because it conflicts with the existing `google_mlkit_image_labeling`, `google_mlkit_text_recognition`, and `google_mlkit_barcode_scanning` packages. On iOS, multiple ML Kit pods may link the same underlying GoogleMLKit framework with different versions.

**Why it happens:**
ArCal currently uses 3 separate `google_mlkit_*` packages, all pinned to `any`. Adding a 4th package (`google_mlkit_object_detection`) may pull a different underlying ML Kit SDK version. On iOS, CocoaPods resolves ML Kit subspecs into a shared GoogleMLKit pod — version mismatches cause build failures. On Android, multiple google_mlkit packages may include conflicting TFLite native libraries.

**How to avoid:**
1. Pin all `google_mlkit_*` packages to the SAME version instead of `any` — check `pub.dev` for latest compatible set
2. Consider migrating to `google_ml_kit` (the umbrella package) which bundles all features with guaranteed compatible versions
3. Run `pod install --repo-update` on iOS after adding the new package
4. Test Android build on clean build (`flutter clean && flutter build apk`) to catch native library conflicts early
5. Verify the existing `VisionProcessor` still works correctly after adding object detection

**Warning signs:**
- `pod install` fails with "Unable to satisfy dependency" on iOS
- `DuplicateClassError` or `MergeDexException` on Android build
- Runtime crash on first ML Kit call after adding new package
- Build succeeds but existing barcode/text recognition stops working

**Phase to address:**
Phase: Dependency Setup — first task before any ML code changes

---

### Pitfall 6: Bounding Box Coordinate Mismatch Between Camera and Canvas

**What goes wrong:**
Bounding boxes drawn on the camera preview are offset, scaled incorrectly, or mirrored. Food appears to have its bounding box shifted to the side, or the box size doesn't match the food. Different devices show different offsets. Portrait/landscape orientation changes make it worse.

**Why it happens:**
1. Camera image resolution (from `startImageStream`) ≠ preview widget size on screen
2. ML Kit returns coordinates relative to the input image dimensions, but the Flutter `CustomPainter` canvas uses widget-local coordinates
3. Camera images may be rotated (especially on Android where sensor orientation varies by manufacturer)
4. `FittedBox` with `BoxFit.cover` in the existing `CameraScreen` clips the preview — bounding box must account for the cropping
5. Front camera is mirrored; back camera is not
6. iOS delivers BGRA8888, Android delivers NV21/YUV420 — input image rotation metadata differs

**How to avoid:**
1. Build a `CoordinateTransformer` utility that handles: image size → preview size → canvas size mapping
2. Account for the sensor orientation (0, 90, 180, 270 degrees) which varies by device
3. Handle the crop offset from `BoxFit.cover` — the visible preview area is smaller than the full camera image
4. Test on at least 3 Android devices with different sensor orientations
5. Lock orientation to portrait during ARscan to reduce complexity
6. Use ML Kit's `InputImageRotation` correctly based on device orientation

**Warning signs:**
- Bounding box is in the correct relative position but shifted by a fixed offset
- Bounding box aspect ratio is wrong (stretched horizontally/vertically)
- Bounding box works on one device but is wrong on another
- Box jumps when device orientation changes

**Phase to address:**
Phase: Bounding Box UI Overlay — dedicated coordinate mapping logic, tested cross-device

---

### Pitfall 7: App Name Change Breaks ASO and Confuses Existing Users

**What goes wrong:**
Changing display name from "Miro" to "ArCal" causes: existing users can't find the app by its old name in search, word-of-mouth recommendations break ("download Miro" → no results), App Store/Play Store search rankings drop for the old name, in-app references still show old name inconsistently.

**Why it happens:**
App Store and Play Store index apps by their display name. When the name changes, existing search rankings for the old name are lost. Users who told friends "use Miro" find nothing when searching. Both stores enforce 30-character limits. If the name change is done without updating ALL touchpoints (screenshots, description, in-app text, support URLs, social media), users experience fragmented branding.

**How to avoid:**
1. Use the format "ArCal - AI Calorie Counter" (brand + keyword) — follows App Store best practice for discoverability
2. Include "formerly Miro" in the app description for 2-3 update cycles
3. Update ALL store assets simultaneously: name, screenshots, description, promotional text
4. Update ALL in-app references: the current `Info.plist` says "Miro needs camera access..." — these must say "ArCal"
5. Send in-app notification to existing users explaining the name change
6. Keep the same app icon style/colors so users recognize the update
7. Update `NSCameraUsageDescription`, `NSHealthShareUsageDescription`, etc. that reference "Miro" or "MiRO"
8. The existing codebase has 6+ privacy strings referencing "Miro" — all need updating

**Warning signs:**
- App Store search for old name returns zero results
- User reviews mention "can't find app" or "wrong app"
- Privacy permission dialogs show old name (confuses users)
- Support email mentions old name while app shows new name

**Phase to address:**
Phase: App Rename & Branding — do this in a dedicated phase, update every touchpoint

---

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Process every camera frame | Simpler code (no throttling) | Memory leak, battery drain, device overheating, crashes on mid-range phones | Never — always throttle |
| Use `ResolutionPreset.high` for stream | Better image quality for ML | 2-3x more memory per frame, faster leak, no visible improvement in detection accuracy | Never for stream — use `medium`; `high` only for final capture |
| Pin ML Kit packages to `any` | Easier to manage versions | Breaking changes on `flutter pub upgrade`, pod conflicts | Never — pin exact versions |
| Skip coordinate transform testing | Faster development | Bounding boxes wrong on different devices, user sees broken AR overlay | Never — test on 3+ devices |
| Single FPS target for both platforms | Simpler code | Android runs at iOS framerate → overheats and drains battery | Never — platform-specific targets |
| Keep ML inference on main isolate | Avoids isolate complexity | UI jank during heavy inference, dropped frames, poor UX | Only for prototyping — production must offload |
| Store all 3 captured images as full-res | Simpler capture logic | Memory spike of 15-30MB per session (3x high-res images), accumulates if user scans frequently | Acceptable if images are compressed immediately after capture (quality 70-80) |

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| `camera` + `google_mlkit_object_detection` | Using `InputImage.fromFile()` (existing pattern) for real-time stream — this is for static files, not camera frames | Use `InputImage.fromBytes()` with correct format (`NV21` on Android, `bgra8888` on iOS) and `InputImageMetadata` including rotation |
| `camera` `startImageStream` | Not setting `imageFormatGroup` in `CameraController` constructor | Explicitly set `imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888` |
| `google_mlkit_object_detection` + existing `VisionProcessor` | Creating two separate ML Kit instances that compete for resources | Share a single object detection instance, or ensure only one ML Kit processor runs at a time (ARscan OR VisionProcessor, not both) |
| `camera` stream + `takePicture()` | Calling `takePicture()` while `startImageStream` is active — causes crash | Must `stopImageStream()` → wait → `takePicture()` → `startImageStream()` for auto-capture |
| Multiple `google_mlkit_*` packages | Adding `google_mlkit_object_detection` without version-locking existing packages | Lock ALL mlkit packages to same minor version; consider umbrella `google_ml_kit` package |
| Store 3 captured images | Saving images to app documents directory without cleanup strategy | Implement image lifecycle: capture → compress → send to Gemini → delete originals after analysis completes |

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Processing every camera frame | Memory growth >50MB/min, app killed by OS after 2-5 minutes | `_isBusy` flag + timestamp-based throttle (min 66ms between frames) | Immediately on physical devices |
| No warm-up for ML model | First 5-10 detections take 200-500ms, bounding box appears to "stutter" on launch | Run one dummy inference on app startup / screen open | First time user opens ARscan |
| Bounding box drawn in `build()` | Entire widget tree rebuilds every frame (10-15 FPS) | Use `CustomPainter` with `RepaintBoundary` — only repaint the overlay, not the camera preview | Visible jank at >5 FPS detection rate |
| Full-resolution capture × 3 angles | 3 high-res images = 15-30MB in memory simultaneously | Capture → compress to 70% quality → dispose original | Users with older phones (2-3GB RAM), especially after several scan sessions |
| ML inference on main thread | UI freeze during detection (dropped frames, unresponsive buttons) | Use `compute()` or platform channels for heavy inference; ML Kit natively handles threading but callback still runs on main thread | Mid-range Android phones, complex food scenes |
| No detection timeout | User points camera at non-food → ML runs indefinitely draining battery | Auto-timeout after 30s of no food detection, prompt user to try again | Every non-food-pointed session |

## Security Mistakes

| Mistake | Risk | Prevention |
|---------|------|------------|
| Captured food images stored indefinitely without cleanup | Storage bloat over weeks/months, user privacy concern | Auto-delete captured images after Gemini analysis completes; implement configurable retention period |
| Camera permission requested at app launch | iOS App Store rejection (Guideline 5.1.1) — permissions must be requested in context | Request camera permission only when user taps ARscan button, with explanation dialog first |
| `NSCameraUsageDescription` too generic after adding ARscan | App Store rejection — description must explain ALL camera uses | Update to comprehensive description: "ArCal uses the camera for real-time food detection, barcode scanning, and food photo analysis for nutrition tracking" |
| Captured images include background/surroundings | Privacy concern — captures people, documents, personal items in background | Crop to bounding box area for Gemini analysis; don't send full frame if possible |

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| Fully automated flow with no manual override | User feels no control — "what if it captures wrong food?", anxiety about wasted Gemini API calls | Always show captured images with "Confirm" / "Retake" before sending to Gemini |
| No feedback during multi-angle capture | User doesn't know why they need to move camera, feels confused | Clear step indicator: "Angle 1/3 ✓ — Now move slightly to the right" with visual guide overlay |
| Bounding box flickers/jumps between frames | Feels broken, user loses confidence in the app | Apply smoothing: average bounding box position over 3-5 frames, use animation for transitions |
| ARscan replaces existing camera button | Users who prefer simple photo capture lose their workflow | Keep both options: ARscan as primary new button, existing camera still accessible |
| No fallback when ML detection fails | User stuck on ARscan screen with nothing happening | After 5-10s without detection, show "Can't detect food — try manual capture instead?" with one-tap fallback to existing CameraScreen |
| Auto-capture fires too fast | User gets 3 nearly identical angles, poor portion estimation | Require minimum camera movement (gyroscope/accelerometer delta) between captures, not just time delay |
| No indication of battery impact | User uses ARscan extensively, phone overheats, battery dies | Show subtle battery indicator when continuous scanning active for >1 minute |

## "Looks Done But Isn't" Checklist

- [ ] **Camera stream**: Works on simulator but crashes on physical device after 3+ minutes — test on real device with memory profiling
- [ ] **Bounding box**: Works on one phone but offset on another — test on 3+ Android devices with different sensor orientations
- [ ] **ML detection**: Detects food in test images but fails on real Thai/Asian food — test with actual target cuisine photos
- [ ] **Auto-capture**: Captures 3 images but they're nearly identical — verify camera position change between captures (gyroscope delta)
- [ ] **App name change**: Changed in store listing but privacy dialogs still say "Miro" — check ALL Info.plist / AndroidManifest strings
- [ ] **Stream + capture**: Stream works and capture works — but `takePicture()` while streaming crashes — test the actual capture-during-stream flow
- [ ] **Memory cleanup**: Images captured successfully — but old images never deleted, storage grows indefinitely
- [ ] **Battery drain**: ARscan works for 30 seconds in testing — test with 5-minute sustained session on older device
- [ ] **Existing features**: ARscan works — but adding `google_mlkit_object_detection` broke existing barcode scanner — regression test existing ML features
- [ ] **Android warm-up**: Detection works after a few seconds — first 5 frames show no detection (model loading), no loading indicator shown

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Memory leak from camera stream | MEDIUM | Add `_isBusy` flag + frame throttling + lower resolution. Requires refactoring stream callback but no architectural change |
| Bounding box coordinate mismatch | LOW | Create `CoordinateTransformer` utility class. Isolated fix, doesn't affect other components |
| ML Kit package version conflict | LOW | Pin versions, run `flutter clean`, `pod install --repo-update`. May need brief downtime for rebuild |
| Base ML model can't detect food well | HIGH | Switch to custom TFLite model — requires model training/selection, new integration code, possible app size increase. Should be validated before committing to architecture |
| App name change ASO drop | MEDIUM | Add "formerly Miro" in subtitle/description, optimize keywords for both names. Recovery takes 2-4 weeks of re-indexing |
| Camera lifecycle crashes | MEDIUM | Refactor to state machine pattern (Idle → Initializing → Streaming → Capturing → Disposing). Requires careful testing of all state transitions |
| Android performance too slow | HIGH | If device is too weak for real-time, need adaptive quality system or skip real-time detection entirely on low-end devices. Fundamental architecture consideration |

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Camera stream memory leak | Camera Stream Infrastructure | Memory stays flat during 5-minute session on physical device |
| Camera lifecycle race conditions | Camera Stream Infrastructure | No crashes during rapid app switch / background / foreground cycles |
| ML Kit base model food detection quality | ML Model Selection & Validation | Bounding box accuracy >80% on 20 test food images across cuisines |
| iOS vs Android ML performance gap | ML Integration & Optimization | Achieves ≥10 FPS detection on mid-range Android (e.g., Samsung A54) |
| ML Kit package conflicts | Dependency Setup | `flutter build apk` and `flutter build ios` both succeed cleanly; existing features pass regression |
| Bounding box coordinate mismatch | Bounding Box UI Overlay | Bounding box aligns with food on 3+ Android devices + iPhone in portrait mode |
| App name change ASO impact | App Rename & Branding | All Info.plist/Manifest strings reference "ArCal"; store listing updated with "formerly Miro" |
| Fully automated UX confusion | Auto-Capture UX Flow | User can review/retake before Gemini analysis; fallback to manual capture available |
| Multi-angle capture quality | Auto-Capture UX Flow | Gyroscope delta verified between captures; 3 images show meaningfully different angles |
| Captured image memory & storage | Image Management | Images compressed immediately; originals deleted after Gemini analysis; storage flat over 50 sessions |

## Sources

- [Flutter camera imageStream memory leak — GitHub Issue #60409](https://github.com/flutter/flutter/issues/60409) — Physical device memory leak documentation
- [google_ml_kit_flutter Issue #708 — Physical device crashes](https://github.com/flutter-ml/google_ml_kit_flutter/issues/708) — ML Kit + camera stream crash reports
- [Flutter camera lifecycle issues — GitHub Issue #90070](https://github.com/flutter/flutter/issues/90070) — startImageStream lifecycle problems
- [Flutter camera dispose race — GitHub Issue #183390](https://github.com/flutter/flutter/issues/183390) — getUserMedia fails after immediate dispose
- [Flutter camera stale data — GitHub Issue #115925](https://github.com/flutter/flutter/issues/115925) — startImageStream returns old data after stop/restart
- [Flutter camera random stop — GitHub Issue #152763](https://github.com/flutter/flutter/issues/152763) — CameraX image stream randomly stopping
- [ML Kit Object Detection Android Docs](https://developers.google.com/ml-kit/vision/object-detection/android) — Detection modes, categories, streaming
- [google_mlkit_object_detection pub.dev](https://pub.dev/packages/google_mlkit_object_detection) — Flutter plugin API reference
- [Camera ImageFormatGroup enum](https://pub.dev/documentation/camera/latest/camera/ImageFormatGroup.html) — Platform-specific format documentation
- [LiteRT Issue #67 — iOS vs Android inference inconsistency](https://github.com/google-ai-edge/LiteRT/issues/67) — 10-50x slower on Android
- [ML Kit on iOS vs Core ML — Xmartlabs](https://blog.xmartlabs.com/blog/ml-kit-core-ml/) — Platform performance comparison
- [On-Device ML: Core ML vs TFLite 2026](https://whistl.app/on-device-ml-core-ml-tensorflow-lite-2026.html) — Neural Engine performance data
- [Flutter camera CameraX migration — PR #6629](https://github.com/flutter/packages/pull/6629) — Default Android backend change
- [Top 10 iOS App Rejection Reasons 2026](https://betadrop.app/blog/ios-app-rejection-reasons-2026) — Current App Store review pitfalls
- [App Store Optimization: Name Change Impact](https://blog.mysticmediasoft.com/app-store-optimization-part-6-how-to-change-app-titles-while-minimizing-impact-on-aso/) — ASO and brand recognition risks
- [Embed Google ML Kit in Flutter: Battery Guide](https://metadesignsolutions.com/embed-google-ml-kit-in-flutter-real-time-ai-without-killing-battery/) — Battery optimization strategies
- [Flutter Image Memory Optimization — 375MB reduction](https://saropa-contacts.medium.com/how-we-reduced-flutter-memory-usage-by-375mb-image-optimization-strategies-5a097246ee0c) — Image memory management best practices
- [SnappyMeal: Multimodal AI Food Logging UX Research](https://arxiv.org/html/2511.03907v1) — Automation vs. user control in food logging

---
*Pitfalls research for: Adding ARscan to existing Flutter calorie app (ArCal v2.0)*
*Researched: 2026-03-16*
