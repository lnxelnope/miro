# Requirements: ArCal - AI Calorie Counter

**Defined:** 2026-03-16  
**Core Value:** ผู้ใช้สามารถบันทึกแคลอรี่และสารอาหารได้อย่างแม่นยำและสะดวกที่สุด โดยใช้ AI ช่วยวิเคราะห์จากภาพถ่ายอาหาร

## v3.0 Requirements (Arcal 2.00 / upgrade_basic)

**Source:** `_project_manager/arcal_2_00/arcal2-01.md` (decisions + dependency map)

### Data & schema (ARC2-DATA)

- [ ] **ARC2-DATA-01**: App documents and implements `ingredientsJson` v2 (or equivalent) with explicit main-ingredients / sub-ingredients structure, max depth two levels, and **backwards-compatible read** of legacy payloads
- [ ] **ARC2-DATA-02**: When sub-ingredients exist, entry-level macros (and roll-up micros as designed) are **recomputed** from subs (sub → main → entry) on change and on save
- [ ] **ARC2-DATA-03**: AI / import path **flattens** nested ingredient trees to at most two levels without losing totals (no double-count)

### App shell & energy (ARC2-SHELL, ARC2-ENERGY)

- [ ] **ARC2-SHELL-01**: `AppMode` is **locked to basic** for all users; no UI path toggles to Pro
- [ ] **ARC2-SHELL-02**: `ModeToggle` removed; AppBar action opens **My Meal** (`HealthMyMealTab`) with clear back navigation
- [ ] **ARC2-SHELL-03**: Chat UI is **hidden** on Basic and Pro entry points; chat code remains in repo
- [ ] **ARC2-SHELL-04**: Bottom navigation / home shell avoids duplicate "My Meals" entry if it is only reached via AppBar (per product layout)
- [ ] **ARC2-SHELL-05**: `QuestBar` is **not shown** on main timeline / basic home (streak/tier logic may continue in background)
- [ ] **ARC2-ENERGY-01**: Legacy **free energy claim** (`claimFreeEnergy` / related UI) is **removed** from Energy Store; **free pass** and seasonal/offer flows remain as designed

### Timeline & sandbox (ARC2-TIMELINE)

- [ ] **ARC2-TIMELINE-01**: `FoodSandbox` (or wrapper) shows **lightweight meal grouping** (e.g. tabs or bounded sections) for breakfast/lunch/dinner/snack without adopting full Pro `MealSection` layout
- [ ] **ARC2-TIMELINE-02**: User can navigate **forward** to tomorrow and further future days (consistent `lastDate`, chevrons, and pickers)
- [ ] **ARC2-TIMELINE-03**: User can **change meal type** for entries from the sandbox flow (drag-and-drop **or** equivalent e.g. selection action / "move to meal…")

### Ingredients & AI (ARC2-ING, ARC2-AI)

- [ ] **ARC2-ING-01**: When sub-ingredients exist, **main composite row** nutrition fields are **read-only** and derived from subs; entries **without** subs may stay simple (no forced hierarchy)
- [ ] **ARC2-ING-02**: User can change **total serving amount** for a composite row; app **scales sub-ingredients proportionally** to match
- [ ] **ARC2-ING-03**: Each **root** item in AI `ingredients_detail` maps to a **main ingredient** under the dish; nested items map to subs (max one sub-level under each main in storage/UI)
- [ ] **ARC2-ING-04**: `AddFoodBottomSheet`, `EditFoodBottomSheet`, `GeminiAnalysisSheet`, and `IntentHandler` use the **same serialization + recompute rules** for ingredients
- [ ] **ARC2-AI-01**: Gemini prompt / post-processing ensures **totals align** with flattened mains/subs (no double-count); consistent with ARC2-DATA-03

### Group, thumbnails, create meal (ARC2-GR, ARC2-THUMB, ARC2-MEAL)

- [ ] **ARC2-GR-01**: Multi-select toolbar exposes **Group**: merges selected entries into **one** new `FoodEntry` with default name `group_xxx`; prior entries removed per spec; detail uses existing simple flow
- [ ] **ARC2-THUMB-01**: Ingredient rows show a **micro thumbnail** when an image path exists; tap opens full view with **optional bounding box** overlay; no placeholder when no image
- [ ] **ARC2-MEAL-01**: `CreateMealSheet` exposes a **gallery** control beside magnifier; selected image runs the **same analysis pipeline** as standard food image analysis and maps into ingredient rows

### Share & promo (ARC2-SHARE, ARC2-PROMO)

- [ ] **ARC2-SHARE-01**: Share card supports **16:9** and **1:1** output presets and a **toggle** to include serving size / quantity on the captured image
- [ ] **ARC2-PROMO-01**: User can enter a **promo code** in **Settings**; successful redeem grants configured reward (e.g. energy, free pass) via backend
- [ ] **ARC2-PROMO-02**: Admin panel supports **CRUD** for promo codes with **global and per-user limits** and **expiry**

---

## v2.0 Requirements (complete)

Requirements for milestone v2.0: ARscan + App Rebrand. **ทีมยืนยันเฟส 6–12 เสร็จแล้ว** — checklist ด้านล่างถือว่าครบเพื่อการ traceability.

### ARScan Detection

- [x] **ARSCAN-01**: User sees real-time bounding box overlay on camera preview that highlights detected food items
- [x] **ARSCAN-02**: App uses on-device ML (ML Kit Object Detection) to detect food in camera stream without cloud API
- [x] **ARSCAN-03**: Detection runs at stable frame rate (iOS 15fps, Android 8-10fps) without visible lag or frame drops
- [x] **ARSCAN-04**: App resets capture progress when camera moves away from the current food target ("moved away" detection)

### ARScan Multi-Angle Capture

- [x] **ARSCAN-05**: App auto-captures 3 angles (top-down ~0°, diagonal ~45°, side ~70°) when food is detected with sufficient confidence
- [x] **ARSCAN-06**: App uses device sensors (accelerometer/gyroscope) to detect current camera angle
- [x] **ARSCAN-07**: App shows on-screen guidance text telling user which angle to capture next (e.g. "Hold steady", "Tilt to 45°", "Move to side view")
- [x] **ARSCAN-08**: App displays capture progress indicator showing how many angles captured (1/3, 2/3, 3/3)
- [x] **ARSCAN-09**: User can manually tap shutter button to capture if auto-capture doesn't trigger
- [x] **ARSCAN-10**: App provides haptic feedback and/or audio cue when each angle is successfully captured

### ARScan Review & Analysis

- [x] **ARSCAN-11**: After 3 angles captured, app shows bottom sheet with captured images preview and form for additional details (hidden items, quantity, unit)
- [x] **ARSCAN-12**: User can tap "Analyse" button in the bottom sheet to send 3 images to Gemini for nutritional analysis
- [x] **ARSCAN-13**: Gemini analysis accepts and processes multiple images (3 angles) for improved portion estimation

### ARScan Data & Display

- [x] **ARSCAN-14**: FoodEntry model stores supplementary image paths (up to 3 images per entry)
- [x] **ARSCAN-15**: User can view all captured images (3 angles) in food entry detail view
- [x] **ARSCAN-16**: Food entries created via ARscan are distinguished from regular camera entries (DataSource indicator)

### ARScan Navigation

- [x] **ARSCAN-17**: ARscan button is prominently placed in navigation, more visually prominent than other buttons
- [x] **ARSCAN-18**: Existing camera/gallery flow remains accessible as alternative method

### App Rebrand

- [x] **BRAND-01**: App display name changed from "Miro" / "MIRO" to "ArCal - AI Calorie Counter" on both Android and iOS
- [x] **BRAND-02**: All privacy/permission strings updated from "Miro" references to "ArCal" (Info.plist, localized strings)

---

## Future (post v3.0 product)

### Advanced Detection

- **ARSCAN-D01**: Custom TFLite food detection model trained on Asian/Thai cuisine for better accuracy
- **ARSCAN-D02**: Multi-food per session — scan multiple dishes in sequence as combined meal
- **ARSCAN-D03**: Depth sensor integration for hardware-based volume estimation
- **ARSCAN-D04**: Visual angle gauge overlay (animated protractor showing current angle)

---

## Out of Scope

| Feature | Reason |
|---------|--------|
| 3D food reconstruction | Too complex for mobile, multi-angle 2D sufficient for portion estimation |
| Real-time calorie overlay during scanning | Requires cloud API during scan, defeats offline-first purpose |
| Package name change | Would break existing App Store / Play Store installs |
| AR SDK (ARCore/ARKit) integration | Adds 50-100MB to app size with no benefit over CustomPainter overlay |
| Custom food model training | Requires dataset collection + training pipeline, defer |
| v3.0: User-visible Pro mode toggle | Product decision — Pro code unused |
| v3.0: Feature-flag rollout for Arcal 2.00 | Product decision — version bump only |
| v3.0: New global search UI | Use existing Add-item / DB search flows |

---

## Traceability

### v3.0 (Arcal 2.00)

| Requirement | Phase | Status |
|-------------|-------|--------|
| ARC2-DATA-01 | Phase 13 | Pending |
| ARC2-DATA-02 | Phase 13 | Pending |
| ARC2-DATA-03 | Phase 13 | Pending |
| ARC2-SHELL-01 | Phase 14 | Pending |
| ARC2-SHELL-02 | Phase 14 | Pending |
| ARC2-SHELL-03 | Phase 14 | Pending |
| ARC2-SHELL-04 | Phase 14 | Pending |
| ARC2-SHELL-05 | Phase 14 | Pending |
| ARC2-ENERGY-01 | Phase 14 | Pending |
| ARC2-TIMELINE-01 | Phase 15 | Pending |
| ARC2-TIMELINE-02 | Phase 15 | Pending |
| ARC2-TIMELINE-03 | Phase 15 | Pending |
| ARC2-ING-01 | Phase 16 | Pending |
| ARC2-ING-02 | Phase 16 | Pending |
| ARC2-ING-03 | Phase 16 | Pending |
| ARC2-ING-04 | Phase 16 | Pending |
| ARC2-AI-01 | Phase 16 | Pending |
| ARC2-GR-01 | Phase 17 | Pending |
| ARC2-THUMB-01 | Phase 17 | Pending |
| ARC2-MEAL-01 | Phase 17 | Pending |
| ARC2-SHARE-01 | Phase 18 | Pending |
| ARC2-PROMO-01 | Phase 18 | Pending |
| ARC2-PROMO-02 | Phase 18 | Pending |

**Coverage v3.0:** 22 requirements → Phases 13–18 → Unmapped: 0 ✓

### v2.0 (carryover)

| Requirement | Phase | Status |
|-------------|-------|--------|
| ARSCAN-01 | Phase 8 | Complete |
| ARSCAN-02 | Phase 8 | Complete |
| ARSCAN-03 | Phase 7 | Complete |
| ARSCAN-04 | Phase 9 | Complete |
| ARSCAN-05 | Phase 9 | Complete |
| ARSCAN-06 | Phase 9 | Complete |
| ARSCAN-07 | Phase 9 | Complete |
| ARSCAN-08 | Phase 9 | Complete |
| ARSCAN-09 | Phase 9 | Complete |
| ARSCAN-10 | Phase 9 | Complete |
| ARSCAN-11 | Phase 10 | Complete |
| ARSCAN-12 | Phase 10 | Complete |
| ARSCAN-13 | Phase 10 | Complete |
| ARSCAN-14 | Phase 6 | Complete |
| ARSCAN-15 | Phase 10 | Complete |
| ARSCAN-16 | Phase 6 | Complete |
| ARSCAN-17 | Phase 10 | Complete |
| ARSCAN-18 | Phase 10 | Complete |
| BRAND-01 | Phase 11 | Complete |
| BRAND-02 | Phase 11 | Complete |

---

*Requirements defined: 2026-03-16*  
*Last updated: 2026-03-29 — v2.0 ARSCAN ทั้งหมดทำเครื่องหมาย Complete ตามที่ทีมยืนยันเฟส 6–12 เสร็จแล้ว; v3.0 traceability ไม่เปลี่ยน*
