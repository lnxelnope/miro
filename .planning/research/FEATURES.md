# Feature Research: ARscan — Video-Based Food Detection & Multi-Angle Capture

**Domain:** Camera-based food detection with real-time bounding boxes and multi-angle auto-capture for calorie estimation
**Researched:** 2026-03-16
**Confidence:** MEDIUM-HIGH

## Feature Landscape

### Table Stakes (Users Expect These)

Features users assume exist when an app offers "AR food scanning." Missing these = product feels broken or gimmicky.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| **Real-time bounding box overlay** | Users expect visual feedback showing the app "sees" their food — without this, the camera feels like a regular photo mode | HIGH | Requires ML Kit object detection in STREAM_MODE on live camera feed. Existing `VisionProcessor` uses image labeling (not object detection) — need `google_mlkit_object_detection` package. Built-in coarse classifier has "Food" category. |
| **Manual capture fallback** | Users want a shutter button if auto-capture doesn't trigger — every scanning app (document, barcode) offers this | LOW | Reuse existing `CameraScreen` shutter pattern. Auto-capture should be the primary mode, manual tap as escape hatch. |
| **Capture progress indicator** | Users need to know "1 of 3 captured" — without this, the multi-angle process feels aimless | LOW | Simple counter UI (e.g., 3 dots/circles that fill as captures complete). Shows "✓" on each completed angle. |
| **On-screen text guidance** | Users need verbal instruction on what to do next — "Hold steady...", "Tilt camera down", "Move to side view" | MEDIUM | Text prompts at top/center of screen. Must be localized (EN/TH/VI via existing L10n). Changes based on current capture state. |
| **Flash/torch toggle** | Users scan food in restaurants, dimly lit rooms — flash is expected for any camera feature | LOW | Already implemented in `CameraScreen._flashOn`. Reuse. |
| **Preview of captured images** | After capture completes, users want to see what was captured before sending to AI | LOW | Thumbnail strip or grid showing 3 captured images. "Retake" option per image. |
| **Auto-send to Gemini analysis** | The whole point of zero-tap is to eliminate the manual "analyze" button — capture should flow directly to AI | MEDIUM | After 3 images captured → auto-navigate to `ImageAnalysisPreviewScreen` or directly invoke Gemini. Depends on existing `CameraScreen → ImageAnalysisPreviewScreen → Gemini` flow. |
| **Cancel/exit at any point** | Users must be able to abort the scan and go back | LOW | Back button / X button. Standard Flutter navigation. |

### Differentiators (Competitive Advantage)

Features that set ARscan apart from competitors. Most calorie apps use single-photo snap → manual confirm. Multi-angle auto-capture is inherently novel.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| **3-angle auto-capture with guided positioning** | No competitor (Lose It, MyFitnessPal, CalAI, Calorie Mama) does guided multi-angle capture. All use single tap-to-snap. This gives ArCal a unique accuracy advantage. | HIGH | Core differentiator. Research shows 45° is optimal for solid foods (74.4% accuracy for rice), 70° for beverages (73.2%). Combined angles push rice accuracy to 85.4%. Recommended sequence: (1) top-down ~0°, (2) 45° angle, (3) side view ~70°. |
| **Zero-tap scanning flow** | CalAI and Lose It require tap → confirm → adjust serving. ArCal's flow: point camera → auto-detect → auto-capture 3 angles → auto-analyze. Minimal user interaction. | MEDIUM | Auto-capture triggers when: (a) food detected with confidence ≥ threshold, (b) bounding box stable for N frames, (c) device steady. Similar to document scanner auto-capture UX. |
| **Angle detection via device sensors** | Using accelerometer/gyroscope to detect actual camera angle (0°, 45°, 70°) and guide the user to the right position | MEDIUM | Flutter `sensors_plus` package provides accelerometer data. Calculate pitch angle from gravity vector. Show angle indicator (like a level/compass). |
| **Smart "move away" detection** | When user moves camera away from detected food, the system resets and starts scanning for new food — handles multi-dish meals naturally | MEDIUM | Track bounding box across frames. If tracked object's IoU drops below threshold (e.g., < 0.3) for N consecutive frames, or bounding box area shrinks significantly → reset. Also reset if ML Kit returns different food category. |
| **Haptic + audio feedback on capture** | Subtle vibration + shutter sound when each angle is auto-captured — confirms capture without requiring visual attention | LOW | `HapticFeedback.mediumImpact()` + optional shutter sound. User knows capture happened even when looking at the food, not the screen. |
| **Prominent AR scan button in nav** | ARscan as a primary action button (like Instagram's post button) makes food logging a one-tap action from anywhere in the app | LOW | Already in PROJECT.md requirements. Center FAB or prominent nav item. |

### Anti-Features (Commonly Requested, Often Problematic)

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| **3D food reconstruction from images** | "More accurate volume estimation" | VolE achieves 2.22% MAPE but requires free-motion video with AR-capable device (LiDAR). Most phones lack depth sensors. Processing is heavy and slow. Out of scope per PROJECT.md. | Send 3 angle photos to Gemini and let AI estimate. Gemini can compare relative sizes across views. 2D multi-angle is sufficient for calorie app accuracy (±15-20%). |
| **Real-time calorie overlay (AR labels)** | "Show calories on each food item in real-time" | Requires cloud API call per frame (too slow), or on-device calorie model (doesn't exist at consumer level). Creates false precision illusion. | Show bounding box + food label only in real-time. Calorie estimation happens after capture via Gemini API. |
| **Depth sensor volume measurement** | SnapCalorie uses phone depth sensor for precise volume | Only works on devices with LiDAR (iPhone Pro, some Android flagships). Fragmented support. Complex implementation. SnapCalorie spent years + $3M+ building this. | Multi-angle 2D photos sent to Gemini provide "good enough" estimation. Research shows ±15% error is achievable with multi-angle, which is better than single-photo apps (±40-53% error). |
| **Custom food detection model** | "Train a model that recognizes specific food types" | Massive data collection effort (SnapCalorie used 5,000 weighed meals). Training, hosting, versioning overhead. ML Kit's built-in "Food" category + Gemini for identification is sufficient. | Use ML Kit coarse "Food" detection for bounding box. Send captured images to Gemini for specific food identification + nutrition. Two-stage approach: local AI for detection, cloud AI for analysis. |
| **Continuous video streaming to cloud** | "Stream video to server for real-time analysis" | Bandwidth intensive, latency issues, privacy concerns, requires always-on internet. Contradicts offline-first constraint. | Local ML Kit for real-time detection (on-device). Only send 3 captured still images to Gemini API. |
| **Automatic serving size measurement in grams** | "Tell me exactly how many grams this is" | Even depth-sensor apps achieve only ±15% accuracy. Without depth info, gram estimation from 2D images is unreliable. Creates false precision. | Provide AI-estimated portion description (e.g., "1 plate of rice", "2 pieces of chicken") and let users adjust. Match to existing `servingSize` + `servingUnit` pattern. |

## Research Findings

### 1. Optimal Angles for Multi-Angle Food Capture

**Source:** Choi & Kim (2025), peer-reviewed study with 82 participants, 6 food types, 3 angles each. [PMC12340097] — **HIGH confidence**

| Angle | Best For | Accuracy | Notes |
|-------|----------|----------|-------|
| **0° (top-down/overhead)** | Flat foods, plate composition overview | 56.1% (rice) | Good for showing food arrangement. Poor for estimating bowl depth/height. Underestimates rice. |
| **45° (diagonal)** | **Solid foods (rice, side dishes, kimchi)** | **74.4% (rice), 52.4% (kimchi)** | **Optimal general-purpose angle.** Matches natural seated viewing angle (~42-45°). Captures both surface area and height/depth. Multiple studies confirm (Turconi 2005, Nelson 1994, Subar 2010). |
| **70° (near-side)** | **Beverages, container fill level** | **73.2% (beverages)** | Best for seeing liquid levels and side profiles. Good for understanding 3D shape. Overestimates rice. |

**Combined multi-angle accuracy improvements:**
- Rice: 74.4% (single best) → **85.4%** (all 3 angles combined)
- Kimchi: 52.4% (single best) → **70.7%** (all 3 angles combined)
- Vegetables: 41.5% (single best) → **53.7%** (all 3 combined)

**Recommendation for ARscan:** Capture sequence should be:
1. **Top-down (~0°)** — overview shot, food composition
2. **45° diagonal** — primary accuracy shot, best for solid foods
3. **Side view (~70°)** — depth/height info, best for beverages and bowls

This maps well to natural user behavior: start looking straight down at plate, then tilt to an angle, then look from the side.

### 2. Competitor Analysis

| App | Camera Approach | Portion Estimation | Accuracy | Multi-angle? |
|-----|----------------|-------------------|----------|-------------|
| **Lose It (Snap It)** | Single photo, tap shutter | **Manual** — user selects serving size after AI identifies food | 87-97% food ID accuracy (lab), much lower real-world | No |
| **MyFitnessPal (Meal Scan)** | Single photo, tap shutter (Premium only) | **Manual** — user adjusts serving after AI suggests | Not published | No |
| **CalAI** | Single photo, tap shutter | **Semi-auto** — uses depth sensor on supported devices + AI | ±10-15% calorie error claimed | No |
| **Calorie Mama** | Single photo, tap shutter | **Manual** — user confirms | Not published | No |
| **SnapCalorie** | Single photo + depth sensor | **Automatic** — depth sensor measures volume → AI maps to weight | ±15% mean caloric error (CVPR published) | No (depth-based) |
| **SnappyMeal** (research) | Multimodal (photo + text + audio + receipts) | **AI-estimated with follow-up questions** | Strong perceived accuracy (user study) | No |
| **ArCal ARscan** (proposed) | **Video-based, auto-capture 3 angles** | **Semi-auto** — multi-angle to Gemini → AI estimates | Target: ±15-20% | **Yes — key differentiator** |

**Key insight:** No mainstream consumer calorie app does guided multi-angle capture. All use single-image snap + manual confirmation. ARscan would be genuinely novel.

### 3. Confidence Thresholds for Auto-Capture

**Source:** ML Kit documentation, document scanner patterns — **MEDIUM confidence** (adapted from adjacent domains)

| Parameter | Recommended Value | Rationale |
|-----------|------------------|-----------|
| **Food detection confidence** | ≥ 0.60 (60%) | ML Kit object detection reports 0.84-0.95 for clear objects. Food on plates may be lower. Start at 0.60 and tune up if false positives are high. |
| **Bounding box stability** | IoU ≥ 0.85 across 5+ consecutive frames | Ensures camera isn't moving and object is truly stable. Document scanners use similar frame-stability checks. |
| **Device stability** | Accelerometer delta < 0.3 m/s² for 500ms | Confirms user is holding device still. Prevents blurry captures. |
| **Auto-capture delay** | 1.5-2 seconds after all conditions met | Gives user time to notice "about to capture" indicator. Prevents accidental captures during camera movement. |
| **"Moved away" threshold** | IoU < 0.3 for 10+ consecutive frames, OR bounding box disappears for 500ms+ | Indicates camera no longer pointing at same food. Reset tracking and start scanning for new food item. |

**Implementation note:** These are starting values. Should be tunable via config/constants file for iteration based on real-world testing.

### 4. On-Screen Guidance UX Patterns

Based on document scanner UX patterns (Google ML Kit Doc Scanner, Adobe Scan, SAP Fiori) adapted for food scanning:

| State | Guidance Text | Visual Indicator |
|-------|--------------|-----------------|
| **Searching** | "Point camera at food" / "หันกล้องไปที่อาหาร" | Scanning animation (pulsing corners / crosshair) |
| **Food detected** | "Food found! Hold steady..." / "พบอาหาร! ถือนิ่ง..." | Green bounding box around detected food. Stability progress bar fills up. |
| **Capturing angle 1 (top-down)** | "Great! ✓ Now tilt camera to 45°" / "เยี่ยม! ✓ เอียงกล้อง 45°" | Capture flash animation. Progress: ●○○. Arrow animation showing tilt direction. |
| **Capturing angle 2 (45°)** | "✓✓ Now move to side view" / "✓✓ ย้ายไปมุมด้านข้าง" | Progress: ●●○. Arrow animation showing side movement. |
| **Capturing angle 3 (side)** | "✓✓✓ All captured! Analyzing..." / "✓✓✓ ครบแล้ว! กำลังวิเคราะห์..." | Progress: ●●●. Auto-transition to analysis screen. |
| **Camera unstable** | "Hold the camera steady" / "ถือกล้องให้นิ่ง" | Yellow warning indicator. Bounding box turns yellow. |
| **Food lost** | "Move camera back to food" / "เลื่อนกล้องกลับไปที่อาหาร" | Red indicator. Bounding box fades out. |
| **New food detected** | "New food detected! Starting fresh..." / "พบอาหารใหม่! เริ่มใหม่..." | Progress resets. New bounding box appears. |

**Angle indicator:** Show a simple tilt indicator (like a phone tilt gauge) that reads the accelerometer and shows current angle vs. target angle. Similar to a carpenter's level but for phone tilt.

### 5. "Moved Away From Food" Detection

**Approach:** Multi-signal detection combining several indicators:

| Signal | How to Detect | Weight |
|--------|--------------|--------|
| **Bounding box disappears** | ML Kit returns no "Food" classification for N frames | Primary |
| **Bounding box IoU drops** | Track bounding box position across frames. If IoU between frame N and frame N+1 < 0.3 for 10+ frames → object changed or left frame | Primary |
| **Bounding box area change** | If bounding box area shrinks by > 60% → camera moved far away from food | Secondary |
| **Scene content change** | If ML Kit returns different primary labels (e.g., was "Food" → now "Furniture") | Secondary |
| **Accelerometer spike** | Large acceleration change indicates rapid camera movement | Supporting |

**State machine:**
```
SCANNING → [food detected] → TRACKING → [stable + confident] → CAPTURING
CAPTURING → [angle captured] → TRACKING (next angle)
TRACKING → [food lost for 500ms+] → SCANNING (reset)
CAPTURING → [food lost] → TRACKING (retry current angle)
TRACKING → [different food] → SCANNING (full reset)
```

### 6. Multi-Angle vs Single-Image Accuracy

| Approach | Calorie Estimation Error | Source | Notes |
|----------|------------------------|--------|-------|
| **User self-estimation** | ±53% | SnapCalorie FAQ | Average user estimating from memory |
| **Professional dietitian from single photo** | ±40% | SnapCalorie FAQ | Trained professional looking at one photo |
| **Single-photo AI** (CalAI, Lose It) | ±10-30% | CalAI claims ±10-15%, varies by food | Depends heavily on food type and clarity |
| **Single-photo + depth sensor** (SnapCalorie) | ±15% mean | CVPR paper, peer-reviewed | Requires LiDAR/depth sensor hardware |
| **Multi-angle 2D photos** (research) | Improves accuracy by 10-30% over single angle | Choi & Kim 2025 | Rice: 74.4% → 85.4% with multi-angle |
| **3D reconstruction from multi-view** (VolE) | 2.22% MAPE volume estimation | Nature 2026 | Research-grade, requires AR-capable device + processing |

**ArCal's target accuracy:** ±15-20% calorie estimation error is realistic with 3-angle photos sent to Gemini. This would be competitive with SnapCalorie (which requires depth hardware) and significantly better than single-photo apps.

**Key insight:** The accuracy improvement comes primarily from giving Gemini multiple viewpoints to reason about portion size. Even without 3D reconstruction, an AI can infer volume better from 3 angles than from 1.

### 7. Zero-Tap Flow Definition

The "zero-tap" ideal: user opens ARscan → points at food → walk away with logged meal.

**Realistic flow for ArCal:**

```
User taps ARscan button (1 tap)
  → Camera opens with real-time detection
  → Food detected automatically
  → Auto-capture angle 1 (top-down)
  → Guidance: "tilt to 45°"
  → Auto-capture angle 2 (45°)
  → Guidance: "move to side"
  → Auto-capture angle 3 (side)
  → Auto-send 3 images to Gemini
  → Show results for confirmation
  → User confirms or adjusts (1 tap)
Total: 2 taps (open + confirm)
```

**Comparison to existing flow:**
```
Current ArCal: Open camera (1 tap) → Aim → Tap shutter (1 tap) → Preview → Analyze (1 tap) → Review → Confirm (1 tap)
Total: 4 taps

Proposed ARscan: Open ARscan (1 tap) → Auto-detect → Auto-capture ×3 → Auto-analyze → Confirm (1 tap)
Total: 2 taps
```

50% reduction in user interaction, with better accuracy from multi-angle.

## Feature Dependencies

```
[ML Kit Object Detection]
    └──requires──> [Camera stream processing] (exists: CameraScreen)
                       └──requires──> [camera package] (exists)

[Real-time bounding box overlay]
    └──requires──> [ML Kit Object Detection]
    └──requires──> [CustomPaint overlay on CameraPreview]

[Auto-capture logic]
    └──requires──> [Real-time bounding box overlay] (need stable detection first)
    └──requires──> [Device sensor angle detection] (sensors_plus)
    └──requires──> [Bounding box stability tracking]

[Angle guidance UI]
    └──requires──> [Device sensor angle detection]
    └──requires──> [L10n strings] (EN/TH/VI)

[3-angle capture sequence]
    └──requires──> [Auto-capture logic]
    └──requires──> [Angle guidance UI]
    └──requires──> [Capture state machine]

[Auto-send to Gemini]
    └──requires──> [3-angle capture sequence]
    └──requires──> [Existing Gemini analysis flow] (exists: ImageAnalysisPreviewScreen → Gemini)

["Moved away" detection]
    └──requires──> [Bounding box tracking across frames]
    └──enhances──> [3-angle capture sequence] (resets on new food)

[Prominent nav button]
    └──independent (UI-only change to existing navigation)
```

### Dependency Notes

- **ML Kit Object Detection requires new package:** Existing app uses `google_mlkit_image_labeling` for post-capture analysis. ARscan needs `google_mlkit_object_detection` for real-time bounding box detection during camera stream. These are different packages.
- **Camera stream processing exists but needs adaptation:** `CameraScreen` currently captures single frames. ARscan needs continuous frame processing (`.startImageStream()`).
- **Gemini analysis flow is reusable:** The existing `CameraScreen → ImageAnalysisPreviewScreen → Gemini` pipeline can be reused. ARscan just sends 3 images instead of 1. May need to modify Gemini prompt to explain multi-angle input.
- **L10n is required:** All guidance text must go through existing `app_en.arb` / `app_th.arb` / `app_vi.arb` system. No hardcoded strings.

## MVP Definition

### Launch With (v2.0 — ARscan MVP)

Minimum viable ARscan — validates that multi-angle auto-capture works and users find it valuable.

- [x] Real-time food detection with bounding box overlay (ML Kit object detection on camera stream)
- [x] 3-angle auto-capture with guided text prompts ("Hold steady", "Tilt to 45°", "Move to side")
- [x] Capture progress indicator (●●○ style)
- [x] Manual capture fallback (tap shutter button)
- [x] Device angle detection via accelerometer (show current angle vs. target)
- [x] Auto-send captured images to Gemini analysis
- [x] "Moved away" detection with tracking reset
- [x] Prominent ARscan button in navigation
- [x] L10n for all guidance strings (EN/TH/VI)

### Add After Validation (v2.x)

Features to add once core ARscan is working and user feedback is collected.

- [ ] Haptic + audio feedback on each capture — Add when users report "I didn't notice it captured"
- [ ] Visual angle indicator (tilt gauge overlay) — Add if users struggle with angle guidance text alone
- [ ] Multi-food session (scan food A → scan food B → combined meal log) — Add when users request scanning full meal plates item by item
- [ ] Capture quality assessment (blur detection, lighting check) — Add if captured images are frequently too blurry/dark for Gemini

### Future Consideration (v3+)

Features to defer until ARscan is proven valuable.

- [ ] Custom food detection model (trained on Asian food types) — Defer until ML Kit's coarse "Food" category proves insufficient
- [ ] Depth sensor integration for supported devices — Defer until user base on Pro/LiDAR devices is significant
- [ ] Offline calorie estimation (on-device model) — Defer until Gemini-dependent flow is validated

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| Real-time bounding box overlay | HIGH | HIGH | P1 |
| 3-angle auto-capture sequence | HIGH | HIGH | P1 |
| On-screen text guidance | HIGH | MEDIUM | P1 |
| Manual capture fallback | MEDIUM | LOW | P1 |
| Capture progress indicator | MEDIUM | LOW | P1 |
| Auto-send to Gemini | HIGH | MEDIUM | P1 |
| "Moved away" detection | MEDIUM | MEDIUM | P1 |
| Prominent nav button | HIGH | LOW | P1 |
| Device angle detection (accelerometer) | MEDIUM | MEDIUM | P1 |
| Haptic/audio feedback | LOW | LOW | P2 |
| Visual angle indicator (tilt gauge) | MEDIUM | MEDIUM | P2 |
| Multi-food session | MEDIUM | HIGH | P2 |
| Capture quality check (blur/light) | LOW | MEDIUM | P3 |
| Custom food detection model | LOW | HIGH | P3 |

**Priority key:**
- P1: Must have for ARscan launch
- P2: Should have, add based on user feedback
- P3: Nice to have, future consideration

## Competitor Feature Analysis

| Feature | Lose It (Snap It) | MyFitnessPal (Meal Scan) | CalAI | SnapCalorie | ArCal ARscan |
|---------|-------------------|--------------------------|-------|-------------|-------------|
| Camera capture | Single photo, tap | Single photo, tap (Premium) | Single photo, tap | Single photo + depth | **Multi-angle auto-capture** |
| Real-time detection | No | No | No | No | **Yes — bounding box overlay** |
| Multi-angle | No | No | No | No | **Yes — 3 angles guided** |
| Auto-capture | No | No | No | No | **Yes — zero-tap** |
| Portion estimation | Manual input | Manual input | Semi-auto (depth) | Auto (depth sensor) | **Semi-auto (multi-angle to AI)** |
| On-screen guidance | No | No | No | No | **Yes — text + angle indicator** |
| Food ID accuracy | 87-97% (lab) | Not published | Not published | ~85% | Depends on ML Kit + Gemini |
| Calorie accuracy | User-dependent | User-dependent | ±10-15% claimed | ±15% (peer-reviewed) | Target ±15-20% |
| Pricing | Free + Premium | Premium only | Free + Premium | Paid | Free + Premium |
| Multi-food per session | No | No | Yes (per-item breakdown) | No | Future (v2.x) |

## Sources

### Peer-Reviewed Research (HIGH confidence)
- Choi & Kim (2025). "Evaluating food portion estimation accuracy with multi-angle photographs." *Nutr Res Pract* 19(4):605–620. PMC12340097 — Multi-angle accuracy data, optimal angles
- VolE (2026). "A point-cloud framework for food 3D reconstruction and volume estimation." *Nature Scientific Reports* — 2.22% MAPE, state of art
- CVPR 2024 Workshop. "Food Portion Estimation via 3D Object Scaling." — 17.67% average energy error
- SnappyMeal (2025). arXiv:2511.03907 — Multimodal food logging evaluation

### Official Documentation (HIGH confidence)
- Google ML Kit Object Detection: https://developers.google.com/ml-kit/vision/object-detection
- `google_mlkit_object_detection` Flutter package: https://pub.dev/packages/google_mlkit_object_detection
- ML Kit Lose It case study: https://firebase.google.com/docs/ml-kit/case-studies/lose-it
- Google ML Kit Document Scanner (auto-capture patterns): https://developers.google.com/ml-kit/vision/doc-scanner

### Competitor Apps (MEDIUM confidence)
- Lose It Snap It: https://www.loseit.com/articles/how-do-i-use-lose-it-s-new-snap-it-feature/
- MyFitnessPal Meal Scan: https://support.myfitnesspal.com/hc/en-us/articles/360045761612
- CalAI: https://www.calai.app/ / https://www.calai-usa.com/
- Calorie Mama: https://caloriemama.ai/
- SnapCalorie: https://www.snapcalorie.com/faq.html
- MyFitnessPal acquires CalAI (March 2026): https://www.globenewswire.com/news-release/2026/03/02/3247439

### Industry Analysis (MEDIUM confidence)
- SnapCalorie TechCrunch coverage: https://techcrunch.com/2023/06/26/snapcalorie-computer-vision-health-app-raises-3m/
- CalorieCue photo logging explainer: https://caloriecue.app/blog/how-photo-food-logging-works
- LogMeal quantity detection: https://docs.logmeal.com/docs/guides-features-quantity-estimation

---
*Feature research for: ARscan video-based food detection & multi-angle capture*
*Researched: 2026-03-16*
