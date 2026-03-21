# Project Research Summary

**Project:** ArCal - AI Calorie Counter (v2.0 ARscan milestone)
**Domain:** Real-time food detection + multi-angle auto-capture for calorie tracking (Flutter mobile)
**Researched:** 2026-03-16
**Confidence:** HIGH

## Executive Summary

ARscan adds video-based real-time food detection with bounding box overlays, guided 3-angle auto-capture, and zero-tap Gemini analysis to the existing ArCal calorie tracker. The research confirms this is a genuinely novel feature — **no mainstream consumer calorie app** (Lose It, MyFitnessPal, CalAI, SnapCalorie) offers guided multi-angle capture. All competitors use single-photo tap-to-snap. Multi-angle capture improves calorie estimation accuracy from ~74% (single best angle) to ~85% (combined 3 angles), making ArCal competitive with SnapCalorie's depth-sensor approach (±15% error) without requiring specialized hardware. The recommended stack additions are minimal: `google_mlkit_object_detection` for real-time bounding boxes, `sensors_plus` for device angle detection, and a camera package upgrade — all well-documented, high-confidence packages from the existing ML Kit ecosystem.

The architecture follows the established codebase patterns (Riverpod, feature-based modules, Isar) with a self-contained `arscan/` feature that connects to the existing camera → analysis → Gemini pipeline. The core technical challenge is the camera stream → ML inference → overlay rendering loop, which must handle frame throttling, memory management, and platform-specific performance gaps (iOS Neural Engine is 10-50x faster than Android CPU inference). A state machine with sealed classes orchestrates the multi-step capture flow (idle → detecting → locking → capturing × 3 → analyzing).

The highest-risk pitfalls are: (1) camera stream memory leaks on physical devices that don't appear on simulators, (2) ML Kit's base model having mediocre food-specific bounding box accuracy — it classifies "food" broadly but may box the entire plate rather than individual items, and (3) bounding box coordinate mismatches across different Android devices with varying sensor orientations. All three require early validation before building dependent features. The app rename from "Miro" to "ArCal" should be handled in a dedicated phase to avoid ASO disruption.

## Key Findings

### Recommended Stack

The stack additions are deliberately minimal — 1 new package, 1 upgrade, 1 addition — all from the same Google/Flutter ecosystem already in use. No AR frameworks needed; ARscan's "AR" is a 2D bounding box overlay via Flutter's built-in `CustomPainter`, not augmented reality.

**Core technologies:**
- **`google_mlkit_object_detection` (^0.15.1):** Real-time object detection with bounding boxes + tracking IDs + food coarse classification — same publisher as existing ML Kit packages
- **`sensors_plus` (^6.1.2):** Accelerometer/gyroscope for device angle detection — guides user through 3 capture angles (top-down, 45°, side)
- **`camera` (upgrade ^0.10.5+5 → ^0.12.0):** `startImageStream()` API for frame-by-frame ML processing with CameraX stability fixes
- **`CustomPainter` (built-in):** Bounding box overlay rendering — zero additional dependency, full visual control

**Explicitly rejected:** AR SDKs (50-100MB size increase for no benefit), `ultralytics_yolo` (pre-1.0), `tflite_flutter` (defer unless ML Kit insufficient). Two-phase model strategy: ML Kit base model first → custom TFLite model only if food detection rate < 80%.

*Details: [STACK.md](STACK.md)*

### Expected Features

**Must have (table stakes):**
- Real-time bounding box overlay — users expect visual feedback that the app "sees" their food
- Manual capture fallback — shutter button if auto-capture doesn't trigger
- Capture progress indicator — "1 of 3 captured" with visual dots
- On-screen text guidance — localized instructions ("Hold steady", "Tilt to 45°")
- Auto-send to Gemini — zero-tap flow eliminates manual "analyze" button
- Cancel/exit at any point

**Should have (differentiators — unique vs. all competitors):**
- 3-angle auto-capture with guided positioning — **no competitor does this**; combined angles push accuracy from 74% to 85%
- Zero-tap scanning — 2 taps total (open + confirm) vs. current 4 taps
- Angle detection via device sensors — accelerometer-based guidance to target angles
- "Moved away" detection — resets tracking when camera leaves food, handles multi-dish meals
- Haptic + audio feedback on capture

**Defer (v2.x / v3+):**
- Custom food detection model (needs dataset training)
- Depth sensor integration (hardware-dependent)
- Multi-food per session (scan item A → item B → combined meal)
- Visual angle gauge overlay (add if text guidance insufficient)

*Details: [FEATURES.md](FEATURES.md)*

### Architecture Approach

A new self-contained `arscan/` feature module with 12 files across presentation, logic, services, widgets, models, and providers directories. The module uses a sealed-class state machine (`ARScanState`) managed by a Riverpod `StateNotifier`, with separate high-frequency providers for bounding box overlay data (10fps updates) to avoid unnecessary UI rebuilds. Connection to the existing pipeline is at the `AnalysisProvider` / `GeminiService` level — ARscan creates a `FoodEntry` with primary + supplementary image paths, then enqueues for Gemini multi-image analysis.

**Major components:**
1. **ARScanScreen** — full-screen camera UI with overlay stack (preview + bounding box + guidance + progress)
2. **ARScanController** — state machine orchestrating: idle → detecting → locking → capturing(1,2,3) → analyzing → complete
3. **FoodDetectionService** — ML Kit ObjectDetector wrapper (separate from existing VisionProcessor — different API, lifecycle, and purpose)
4. **CaptureManager** — manages stop-stream → capture → restart-stream cycle for 3 high-quality images
5. **BoundingBoxPainter** — `CustomPainter` with coordinate transformation (camera resolution → preview size → canvas)
6. **GuidanceOverlay** — localized text prompts + progress indicator, driven by state machine

**Data model change:** Add `supplementaryImagePaths` (nullable String, JSON array) to `FoodEntry` — no migration needed, backward compatible.

*Details: [ARCHITECTURE.md](ARCHITECTURE.md)*

### Critical Pitfalls

1. **Camera stream memory leak** — `startImageStream()` leaks on physical devices (not simulators). Prevention: `ResolutionPreset.medium`, strict `_isBusy` flag, 10fps throttle, stop stream before dispose. Must validate on physical device with memory profiling.

2. **ML Kit base model food detection quality** — Coarse "food" classification may box entire plate instead of individual items. May return "home goods" (plate/bowl) instead of food content. Prevention: test with real Thai/Asian food images early; plan fallback to combined object detection + image labeling signal.

3. **Bounding box coordinate mismatch** — Camera image resolution ≠ preview widget size. Sensor orientation varies by Android manufacturer. `BoxFit.cover` cropping adds offset. Prevention: build `CoordinateTransformer` utility, test on 3+ Android devices, lock to portrait mode.

4. **iOS vs Android ML performance gap (2-10x)** — iOS Neural Engine handles ML Kit inference 10-50x faster than Android CPU. Prevention: platform-specific FPS targets (iOS 15fps, Android 8-10fps), test on mid-range Android phones, pre-warm model on first launch.

5. **ML Kit package version conflicts** — Adding 4th `google_mlkit_*` package to existing 3 may cause pod/dex conflicts. Prevention: pin all ML Kit packages to same version (not `any`), clean build, verify existing features still work.

*Details: [PITFALLS.md](PITFALLS.md)*

## Implications for Roadmap

Based on research, suggested phase structure (6 phases):

### Phase 1: Foundation — Dependencies & Data Model
**Rationale:** Must resolve ML Kit package compatibility first (Pitfall 5) before any ML code. Data model extension is non-breaking and enables all downstream work.
**Delivers:** Clean build with all new packages, extended FoodEntry model, new DataSource enum
**Addresses:** Dependency setup, schema preparation
**Avoids:** Pitfall 5 (ML Kit package conflicts) — pin versions, verify clean build on both platforms
**Tasks:** Add `google_mlkit_object_detection`, `sensors_plus` to pubspec; upgrade `camera`; pin all ML Kit versions; add `supplementaryImagePaths` to FoodEntry; add `DataSource.arScanned`; verify existing features pass regression

### Phase 2: Camera Stream Infrastructure
**Rationale:** Camera streaming is the foundation for everything — detection, overlay, capture all depend on it. Memory leaks and lifecycle issues (Pitfalls 1, 2) must be resolved before building on top.
**Delivers:** Stable camera streaming with frame throttling, lifecycle-safe init/dispose, memory-profiled on physical devices
**Addresses:** Camera stream processing (table stakes foundation)
**Avoids:** Pitfall 1 (memory leak), Pitfall 2 (lifecycle race conditions)
**Tasks:** Implement `startImageStream` with `ResolutionPreset.medium`; frame throttling to 10fps; `_isBusy` guard; lifecycle management (background/foreground); `InputImage` conversion (NV21/BGRA8888); physical device memory validation

### Phase 3: Real-Time Food Detection & Bounding Box Overlay
**Rationale:** Must validate that ML Kit actually detects food with acceptable accuracy (Pitfall 3) before investing in the multi-angle capture flow. Bounding box coordinate mapping (Pitfall 6) needs dedicated cross-device testing.
**Delivers:** Working food detection with visual bounding box overlay on camera preview, validated on real food images
**Addresses:** Real-time bounding box overlay (table stakes), food detection validation
**Avoids:** Pitfall 3 (ML Kit food detection quality), Pitfall 6 (coordinate mismatch), Pitfall 4 (platform performance gap)
**Tasks:** Create FoodDetectionService; implement ObjectDetector with stream mode; build BoundingBoxPainter with CoordinateTransformer; test food detection accuracy on 20+ Thai/Asian food images; cross-device testing (3+ Android devices); platform-specific FPS tuning

### Phase 4: Multi-Angle Auto-Capture & Guidance UI
**Rationale:** Core differentiator feature. Depends on working detection (Phase 3) and stable streaming (Phase 2). State machine and sensor integration are the most complex new code.
**Delivers:** Complete 3-angle guided capture flow with auto-capture, angle detection, stability tracking, "moved away" reset
**Addresses:** 3-angle auto-capture (differentiator), angle detection, zero-tap flow, guidance UI, capture progress, "moved away" detection, manual capture fallback
**Avoids:** UX pitfalls (no manual override, no feedback, auto-capture too fast)
**Tasks:** Implement ARScanState sealed classes + ARScanController state machine; integrate `sensors_plus` for angle classification (0°/45°/70°); build GuidanceOverlay with L10n strings; CaptureProgressIndicator; CaptureManager (stop stream → capture → restart); stability detection; food-lost/moved-away reset logic; manual shutter fallback

### Phase 5: Pipeline Integration & Navigation
**Rationale:** Connects ARscan output to existing Gemini analysis flow. Depends on capture working end-to-end (Phase 4). Navigation change makes ARscan accessible to users.
**Delivers:** Complete end-to-end flow: ARscan → 3 captures → FoodEntry → Gemini multi-image analysis → timeline
**Addresses:** Auto-send to Gemini (table stakes), prominent nav button (differentiator)
**Avoids:** Breaking existing camera flow (keep old CameraScreen accessible)
**Tasks:** Create FoodEntry with primary + supplementary images; extend GeminiService.analyzeFoodImage for multi-image; connect to AnalysisProvider; update navigation (Camera tab → Scan tab with AR icon); keep existing camera accessible via alternate path; add capture preview with confirm/retake before Gemini send

### Phase 6: App Rebrand & Polish
**Rationale:** Rename is lower risk than ARscan features and should be done after core features are stable. Cross-device optimization is final polish.
**Delivers:** "ArCal" branding throughout, optimized performance across devices, haptic feedback, edge case handling
**Addresses:** App rename requirement, cross-platform optimization, UX polish
**Avoids:** Pitfall 7 (ASO disruption from name change)
**Tasks:** Update display name to "ArCal - AI Calorie Counter" (Android label, iOS bundle name); update all Info.plist/Manifest privacy strings from "Miro" to "ArCal"; store listing with "formerly Miro"; haptic feedback on capture; model pre-warming on Android; detection timeout (30s → fallback prompt); image compression + cleanup lifecycle; battery indicator for sustained scanning

### Phase Ordering Rationale

- **Dependencies first** (Phase 1) — package conflicts would block all subsequent work; data model is a non-breaking prerequisite
- **Camera streaming before detection** (Phase 2 before 3) — detection runs on camera frames; stream must be stable and memory-safe first
- **Detection before capture** (Phase 3 before 4) — auto-capture triggers on detection results; must validate ML Kit accuracy before building capture logic
- **Capture before pipeline** (Phase 4 before 5) — pipeline connects captured images to Gemini; needs actual captured images to test
- **Rename last** (Phase 6) — low coupling to ARscan features; should ship with stable product, not during active feature development
- **Each phase is independently testable** — Phase 1: build succeeds; Phase 2: stream runs 5min without leak; Phase 3: boxes appear on food; Phase 4: 3 angles captured; Phase 5: Gemini returns nutrition; Phase 6: all strings say "ArCal"

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 3 (Detection & Overlay):** ML Kit base model food detection quality is uncertain — may need fallback strategy (combined object detection + image labeling) or custom model evaluation. Cross-device coordinate mapping is device-dependent.
- **Phase 4 (Auto-Capture):** Optimal stability thresholds (confidence, IoU, accelerometer delta) are starting estimates from adapted document-scanner patterns — need real-world tuning.

Phases with standard patterns (skip research-phase):
- **Phase 1 (Dependencies):** Standard Flutter package management — well-documented
- **Phase 2 (Camera Stream):** Flutter camera streaming is well-documented with known pitfall patterns — prevention strategies are clear
- **Phase 5 (Pipeline):** Extends existing AnalysisProvider → Gemini flow — established codebase pattern
- **Phase 6 (Rebrand):** Standard app rename process — platform docs are clear

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | All packages verified on pub.dev with official publishers; existing ML Kit ecosystem compatibility confirmed; version requirements validated against project targets |
| Features | MEDIUM-HIGH | Feature landscape well-researched with peer-reviewed accuracy data (Choi & Kim 2025); competitor analysis comprehensive; anti-features clearly identified. Multi-angle accuracy improvement (74→85%) from controlled study, may vary in real-world |
| Architecture | HIGH | Based on direct codebase analysis of existing patterns; state machine and service separation are well-established Flutter/Riverpod patterns; integration points clearly identified |
| Pitfalls | HIGH | Pitfalls sourced from Flutter GitHub issues, ML Kit documentation, and real-world case studies; camera stream memory leak is widely documented; all pitfalls have concrete prevention strategies |

**Overall confidence:** HIGH

### Gaps to Address

- **ML Kit food detection quality on Asian cuisine:** Base model tested primarily on Western food datasets. Must validate with Thai/Asian food images early in Phase 3. If detection rate < 80%, need to evaluate custom TFLite model path (significant scope expansion).
- **Camera `startImageStream` + `takePicture` concurrent support:** Flutter camera plugin historically doesn't support both simultaneously. Must stop stream before capture. Verify timing/reliability of stop → capture → restart cycle on both platforms.
- **Gemini multi-image prompt engineering:** Current GeminiService sends single images. Multi-image prompt ("3 angles of the same food for better portion estimation") needs validation for quality of nutritional analysis response.
- **Mid-range Android performance baseline:** Research shows 2-10x performance gap, but actual FPS on target Android devices (Samsung A-series, Xiaomi) is unknown. Phase 3 testing will establish baseline.
- **Auto-capture threshold tuning:** Confidence ≥0.60, IoU ≥0.85 for 5+ frames, accelerometer delta <0.3 m/s² — these are adapted from document scanner patterns. Real-world food scanning may need different values. Plan for configurable constants file.

## Sources

### Primary (HIGH confidence)
- [google_mlkit_object_detection v0.15.1](https://pub.dev/packages/google_mlkit_object_detection) — API, detection modes, food classification
- [ML Kit Object Detection docs](https://developers.google.com/ml-kit/vision/object-detection) — official capabilities and limitations
- [camera v0.12.0](https://pub.dev/packages/camera) — startImageStream API, platform requirements
- [sensors_plus v6.1.2](https://pub.dev/packages/sensors_plus) — accelerometer/gyroscope API
- [Flutter camera Issue #60409](https://github.com/flutter/flutter/issues/60409) — memory leak documentation
- [Flutter camera Issue #152763](https://github.com/flutter/flutter/issues/152763) — CameraX stream issues
- Existing codebase analysis — camera_screen.dart, vision_processor.dart, home_screen.dart, gemini_service.dart, food_entry.dart, analysis_provider.dart

### Secondary (MEDIUM-HIGH confidence)
- Choi & Kim (2025). "Evaluating food portion estimation accuracy with multi-angle photographs." *Nutr Res Pract* 19(4):605–620. PMC12340097 — Multi-angle accuracy data (74→85% improvement)
- VolE (2026). "A point-cloud framework for food 3D reconstruction and volume estimation." *Nature Scientific Reports* — state-of-art accuracy benchmarks
- [SnapCalorie FAQ](https://www.snapcalorie.com/faq.html) — competitor accuracy claims (±15% mean caloric error)
- [LiteRT Issue #67](https://github.com/google-ai-edge/LiteRT/issues/67) — iOS vs Android inference performance gap

### Tertiary (MEDIUM confidence)
- [Flutter real-time object detection patterns](https://medium.com/@cia1099/approached-60-fps-object-detection-without-any-frame-dropout-on-mobile-devices-with-flutter-6ab3c9dc5c4b) — community implementation reference
- [YOLOv8 food detection study](https://etasr.com/index.php/ETASR/article/view/14810) — academic paper Dec 2025, alternative model evaluation
- Competitor apps (Lose It, CalAI, MyFitnessPal, Calorie Mama) — feature comparison, no direct accuracy validation

---
*Research completed: 2026-03-16*
*Ready for roadmap: yes*
