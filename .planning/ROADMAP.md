# Roadmap: ArCal - AI Calorie Counter

## Milestones

- ✅ **v1.0 MVP** - Phases 1-3 (pre-GSD)
- ✅ **v1.1 Gamification & Monetization** - Phases 4 (pre-GSD)
- ✅ **v1.2 Analytics & Health Integration** - Phase 5 (pre-GSD, last version v1.2.2+51)
- 🚧 **v2.0 ARscan + Rebrand** - Phases 6-11 (in progress)

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

<details>
<summary>✅ v1.0–v1.2 (Phases 1-5) — SHIPPED v1.2.2+51</summary>

Phases 1-5 were completed pre-GSD. See MILESTONES.md for details.

</details>

### 🚧 v2.0 ARscan + Rebrand

**Milestone Goal:** เพิ่มฟีเจอร์ ARscan สำหรับตรวจจับอาหารแบบ real-time พร้อม auto-capture 3 มุม เพื่อวิเคราะห์แคลอรี่แม่นยำขึ้น และเปลี่ยนชื่อแอปเป็น ArCal

- [ ] **Phase 6: Foundation** — Dependencies, data model, and build verification
- [ ] **Phase 7: Camera Stream** — Real-time video processing infrastructure
- [ ] **Phase 8: Food Detection** — ML Kit object detection with bounding box overlay
- [ ] **Phase 9: Multi-Angle Capture** — Guided 3-angle auto-capture with sensor integration
- [ ] **Phase 10: Review & Pipeline** — Bottom sheet review, Gemini analysis, and navigation
- [ ] **Phase 11: App Rebrand** — Rename app to ArCal across all platforms

## Phase Details

### Phase 6: Foundation
**Goal**: All ARscan dependencies installed, data model extended for multi-image storage, clean build verified on both platforms
**Depends on**: Nothing (first phase of v2.0)
**Requirements**: ARSCAN-14, ARSCAN-16
**Success Criteria** (what must be TRUE):
  1. App builds cleanly on both iOS and Android with all new packages (google_mlkit_object_detection, sensors_plus, camera upgrade)
  2. FoodEntry model can store up to 3 supplementary image paths per entry
  3. Food entries created via ARscan are distinguished from regular camera entries via DataSource indicator
  4. All existing features (camera, barcode, gallery, chat logging) continue to work without regression
**Plans**: 3 plans in 2 waves

Plans:
- [ ] 06-01: Data model (FoodEntry multi-image + dataSource) [wave 1]
- [ ] 06-02: Dependencies (ML Kit, sensors_plus, camera upgrade) [wave 1]
- [ ] 06-03: Repository layer (CRUD for ARscan FoodEntry) [wave 2]

### Phase 7: Camera Stream
**Goal**: Stable camera streaming with frame-by-frame processing at target FPS, lifecycle-safe on physical devices
**Depends on**: Phase 6
**Requirements**: ARSCAN-03
**Success Criteria** (what must be TRUE):
  1. Camera preview displays full-screen live video feed on ARscan screen
  2. Frame processing runs at stable target FPS (iOS ≥15fps, Android ≥8fps) without visible lag or frame drops
  3. Camera stream runs for 5+ minutes without memory leaks or crashes on physical devices
  4. Camera properly pauses/resumes when app moves to background/foreground
**Plans**: 3 plans in 2 waves

Plans:
- [ ] 07-01: ARscan screen + camera preview widget [wave 1]
- [ ] 07-02: Camera stream controller (logic layer) [wave 1]
- [ ] 07-03: FPS diagnostics + long-run stability testing [wave 2]

### Phase 8: Food Detection
**Goal**: Users see real-time bounding boxes highlighting detected food items on camera preview, powered by on-device ML Kit
**Depends on**: Phase 7
**Requirements**: ARSCAN-01, ARSCAN-02
**Success Criteria** (what must be TRUE):
  1. User sees bounding box rectangles drawn around detected food items in real-time on camera preview
  2. Food detection uses on-device ML Kit only — works without internet connection
  3. Bounding boxes accurately align with food items on screen across different device resolutions
  4. Detection works on at least 3 different Android devices without coordinate mismatch issues
**Plans**: 2 plans in 2 waves

Plans:
- [ ] 08-01: Detection service (ML Kit + ArScanDetection model + throttle) [wave 1]
- [ ] 08-02: Bounding box overlay (CustomPainter + coordinate mapping) [wave 2]

### Phase 9: Multi-Angle Capture
**Goal**: App guides user through 3-angle capture flow with auto-capture, device sensor angle detection, progress tracking, and manual fallback
**Depends on**: Phase 8
**Requirements**: ARSCAN-04, ARSCAN-05, ARSCAN-06, ARSCAN-07, ARSCAN-08, ARSCAN-09, ARSCAN-10
**Success Criteria** (what must be TRUE):
  1. App auto-captures 3 images at distinct angles (top-down ~0°, diagonal ~45°, side ~70°) when food is detected with sufficient confidence
  2. On-screen guidance text tells user which angle to capture next and updates as each angle completes
  3. Capture progress indicator shows how many angles captured (1/3, 2/3, 3/3) and updates after each capture
  4. Capture progress resets when camera moves away from the target food item
  5. User can manually tap shutter button to capture if auto-capture doesn't trigger, with haptic/audio feedback on success
**Plans**: 2 plans in 2 waves

Plans:
- [ ] 09-01: Sensor + capture logic (state machine, auto/manual, reset) [wave 1]
- [ ] 09-02: Overlay + feedback (angle gauge, progress, haptic/sound) [wave 2]

### Phase 10: Review & Pipeline
**Goal**: Complete end-to-end flow from ARscan capture through review bottom sheet to Gemini multi-image analysis, with prominent navigation placement
**Depends on**: Phase 9
**Requirements**: ARSCAN-11, ARSCAN-12, ARSCAN-13, ARSCAN-15, ARSCAN-17, ARSCAN-18
**Success Criteria** (what must be TRUE):
  1. After 3 angles captured, bottom sheet appears showing captured image previews and form for additional details
  2. User can tap "Analyse" to send 3 images to Gemini and receive nutritional analysis with improved portion estimation
  3. ARscan button is prominently placed in navigation, visually more prominent than other nav buttons
  4. User can view all 3 captured angle images when viewing food entry details
  5. Existing camera and gallery flow remains fully accessible as an alternative to ARscan
**Plans**: 3 plans in 3 waves

Plans:
- [ ] 10-01: Review bottom sheet (handoff from Phase 9, preview, form) [wave 1]
- [ ] 10-02: Gemini multi-image analysis service + save FoodEntry [wave 2]
- [ ] 10-03: Navigation (ARscan prominent button + keep old flow) [wave 3]

### Phase 11: App Rebrand
**Goal**: App identity changed from Miro to ArCal across all user-facing surfaces on both platforms
**Depends on**: Phase 10
**Requirements**: BRAND-01, BRAND-02
**Success Criteria** (what must be TRUE):
  1. App displays as "ArCal - AI Calorie Counter" on home screen icon of both iOS and Android devices
  2. All permission dialogs and privacy strings reference "ArCal" instead of "Miro" on both platforms
**Plans**: 2 plans in 2 waves

Plans:
- [ ] 11-01: Display name change (AndroidManifest + Info.plist) [wave 1]
- [ ] 11-02: Privacy/permission strings update (localization + InfoPlist.strings) [wave 2]

## Progress

**Execution Order:**
Phases execute in numeric order: 6 → 7 → 8 → 9 → 10 → 11

| Phase | Milestone | Plans Complete | Status | Completed |
|-------|-----------|----------------|--------|-----------|
| 6. Foundation | v2.0 | 0/3 | Not started | - |
| 7. Camera Stream | v2.0 | 0/3 | Not started | - |
| 8. Food Detection | 1/2 | In Progress|  | - |
| 9. Multi-Angle Capture | v2.0 | 0/2 | Not started | - |
| 10. Review & Pipeline | v2.0 | 0/3 | Not started | - |
| 11. App Rebrand | v2.0 | 0/2 | Not started | - |
