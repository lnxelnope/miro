# Requirements: ArCal - AI Calorie Counter

**Defined:** 2026-03-16
**Core Value:** ผู้ใช้สามารถบันทึกแคลอรี่และสารอาหารได้อย่างแม่นยำและสะดวกที่สุด โดยใช้ AI ช่วยวิเคราะห์จากภาพถ่ายอาหาร

## v2.0 Requirements

Requirements for milestone v2.0: ARscan + App Rebrand.

### ARScan Detection

- [ ] **ARSCAN-01**: User sees real-time bounding box overlay on camera preview that highlights detected food items
- [ ] **ARSCAN-02**: App uses on-device ML (ML Kit Object Detection) to detect food in camera stream without cloud API
- [ ] **ARSCAN-03**: Detection runs at stable frame rate (iOS 15fps, Android 8-10fps) without visible lag or frame drops
- [ ] **ARSCAN-04**: App resets capture progress when camera moves away from the current food target ("moved away" detection)

### ARScan Multi-Angle Capture

- [ ] **ARSCAN-05**: App auto-captures 3 angles (top-down ~0°, diagonal ~45°, side ~70°) when food is detected with sufficient confidence
- [ ] **ARSCAN-06**: App uses device sensors (accelerometer/gyroscope) to detect current camera angle
- [ ] **ARSCAN-07**: App shows on-screen guidance text telling user which angle to capture next (e.g. "Hold steady", "Tilt to 45°", "Move to side view")
- [ ] **ARSCAN-08**: App displays capture progress indicator showing how many angles captured (1/3, 2/3, 3/3)
- [ ] **ARSCAN-09**: User can manually tap shutter button to capture if auto-capture doesn't trigger
- [ ] **ARSCAN-10**: App provides haptic feedback and/or audio cue when each angle is successfully captured

### ARScan Review & Analysis

- [ ] **ARSCAN-11**: After 3 angles captured, app shows bottom sheet with captured images preview and form for additional details (hidden items, quantity, unit)
- [ ] **ARSCAN-12**: User can tap "Analyse" button in the bottom sheet to send 3 images to Gemini for nutritional analysis
- [ ] **ARSCAN-13**: Gemini analysis accepts and processes multiple images (3 angles) for improved portion estimation

### ARScan Data & Display

- [x] **ARSCAN-14**: FoodEntry model stores supplementary image paths (up to 3 images per entry)
- [ ] **ARSCAN-15**: User can view all captured images (3 angles) in food entry detail view
- [x] **ARSCAN-16**: Food entries created via ARscan are distinguished from regular camera entries (DataSource indicator)

### ARScan Navigation

- [ ] **ARSCAN-17**: ARscan button is prominently placed in navigation, more visually prominent than other buttons
- [ ] **ARSCAN-18**: Existing camera/gallery flow remains accessible as alternative method

### App Rebrand

- [ ] **BRAND-01**: App display name changed from "Miro" / "MIRO" to "ArCal - AI Calorie Counter" on both Android and iOS
- [ ] **BRAND-02**: All privacy/permission strings updated from "Miro" references to "ArCal" (Info.plist, localized strings)

## v3.0+ Requirements (Deferred)

### Advanced Detection

- **ARSCAN-D01**: Custom TFLite food detection model trained on Asian/Thai cuisine for better accuracy
- **ARSCAN-D02**: Multi-food per session — scan multiple dishes in sequence as combined meal
- **ARSCAN-D03**: Depth sensor integration for hardware-based volume estimation
- **ARSCAN-D04**: Visual angle gauge overlay (animated protractor showing current angle)

## Out of Scope

| Feature | Reason |
|---------|--------|
| 3D food reconstruction | Too complex for mobile, multi-angle 2D sufficient for portion estimation |
| Real-time calorie overlay during scanning | Requires cloud API during scan, defeats offline-first purpose |
| Package name change | Would break existing App Store / Play Store installs |
| AR SDK (ARCore/ARKit) integration | Adds 50-100MB to app size with no benefit over CustomPainter overlay |
| Custom food model training | Requires dataset collection + training pipeline, defer to v3.0 |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| ARSCAN-01 | Phase 8 | Pending |
| ARSCAN-02 | Phase 8 | Pending |
| ARSCAN-03 | Phase 7 | Pending |
| ARSCAN-04 | Phase 9 | Pending |
| ARSCAN-05 | Phase 9 | Pending |
| ARSCAN-06 | Phase 9 | Pending |
| ARSCAN-07 | Phase 9 | Pending |
| ARSCAN-08 | Phase 9 | Pending |
| ARSCAN-09 | Phase 9 | Pending |
| ARSCAN-10 | Phase 9 | Pending |
| ARSCAN-11 | Phase 10 | Pending |
| ARSCAN-12 | Phase 10 | Pending |
| ARSCAN-13 | Phase 10 | Pending |
| ARSCAN-14 | Phase 6 | Complete |
| ARSCAN-15 | Phase 10 | Pending |
| ARSCAN-16 | Phase 6 | Complete |
| ARSCAN-17 | Phase 10 | Pending |
| ARSCAN-18 | Phase 10 | Pending |
| BRAND-01 | Phase 11 | Pending |
| BRAND-02 | Phase 11 | Pending |

**Coverage:**
- v2.0 requirements: 20 total
- Mapped to phases: 20
- Unmapped: 0 ✓

---
*Requirements defined: 2026-03-16*
*Last updated: 2026-03-16 — traceability updated with phase mappings*
