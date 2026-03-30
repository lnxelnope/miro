# Roadmap: ArCal - AI Calorie Counter

## Milestones

- ✅ **v1.0 MVP** - Phases 1-3 (pre-GSD)
- ✅ **v1.1 Gamification & Monetization** - Phases 4 (pre-GSD)
- ✅ **v1.2 Analytics & Health Integration** - Phase 5 (pre-GSD, last version v1.2.2+51)
- ✅ **v2.0 ARscan + Rebrand** — Phases 6–12 (shipped)
- ✅ **v3.0 Arcal 2.00 (upgrade_basic)** — Phases 13–18 โค้ดครบ; **UAT + deploy production** ตาม `18-MANUAL-CHECKLIST.md`

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

<details>
<summary>✅ v1.0–v1.2 (Phases 1-5) — SHIPPED v1.2.2+51</summary>

Phases 1-5 were completed pre-GSD. See MILESTONES.md for details.

</details>

### ✅ v2.0 ARscan + Rebrand (complete)

**Milestone Goal:** เพิ่มฟีเจอร์ ARscan สำหรับตรวจจับอาหารแบบ real-time พร้อม auto-capture 3 มุม เพื่อวิเคราะห์แคลอรี่แม่นยำขึ้น และเปลี่ยนชื่อแอปเป็น ArCal

- [x] **Phase 6: Foundation** — Dependencies, data model, and build verification
- [x] **Phase 7: Camera Stream** — Real-time video processing infrastructure
- [x] **Phase 8: Food Detection** — ML Kit object detection with bounding box overlay
- [x] **Phase 9: Multi-Angle Capture** — Guided 3-angle auto-capture with sensor integration
- [x] **Phase 10: Review & Pipeline** — Bottom sheet review, Gemini analysis, and navigation
- [x] **Phase 11: App Rebrand** — Rename app to ArCal across all platforms
- [x] **Phase 12: Miro→ArCal migration** — Inventory, user-facing rename, internal ID strategy (see Phase Details below)

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
- [x] 06-01: Data model (FoodEntry multi-image + dataSource) [wave 1]
- [x] 06-02: Dependencies (ML Kit, sensors_plus, camera upgrade) [wave 1]
- [x] 06-03: Repository layer (CRUD for ARscan FoodEntry) [wave 2]

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
- [x] 07-01: ARscan screen + camera preview widget [wave 1]
- [x] 07-02: Camera stream controller (logic layer) [wave 1]
- [x] 07-03: FPS diagnostics + long-run stability testing [wave 2]

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
- [x] 08-01: Detection service (ML Kit + ArScanDetection model + throttle) [wave 1]
- [x] 08-02: Bounding box overlay (CustomPainter + coordinate mapping) [wave 2]

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
- [x] 09-01: Sensor + capture logic (state machine, auto/manual, reset) [wave 1]
- [x] 09-02: Overlay + feedback (angle gauge, progress, haptic/sound) [wave 2]

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
- [x] 10-01: Review bottom sheet (handoff from Phase 9, preview, form) [wave 1]
- [x] 10-02: Gemini multi-image analysis service + save FoodEntry [wave 2]
- [x] 10-03: Navigation (ARscan prominent button + keep old flow) [wave 3]

### Phase 11: App Rebrand
**Goal**: App identity changed from Miro to ArCal across all user-facing surfaces on both platforms
**Depends on**: Phase 10
**Requirements**: BRAND-01, BRAND-02
**Success Criteria** (what must be TRUE):
  1. App displays as "ArCal - AI Calorie Counter" on home screen icon of both iOS and Android devices
  2. All permission dialogs and privacy strings reference "ArCal" instead of "Miro" on both platforms
**Plans**: 2 plans in 2 waves

Plans:
- [x] 11-01: Display name change (AndroidManifest + Info.plist) [wave 1]
- [x] 11-02: Privacy/permission strings update (localization + InfoPlist.strings) [wave 2]

## Progress (v2.0 — archived)

**Execution order ที่ใช้:** 6 → 7 → 8 → 9 → 10 → 11 → 12 — **ครบแล้ว**

| Phase | Milestone | Plans Complete | Status | Completed |
|-------|-----------|----------------|--------|-----------|
| 6. Foundation | v2.0 | 3/3 | Complete | — |
| 7. Camera Stream | v2.0 | 3/3 | Complete | — |
| 8. Food Detection | v2.0 | 2/2 | Complete | — |
| 9. Multi-Angle Capture | v2.0 | 2/2 | Complete | 2026-03-16 |
| 10. Review & Pipeline | v2.0 | 3/3 | Complete | — |
| 11. App Rebrand | v2.0 | 2/2 | Complete | 2026-03-16 |
| 12. Miro→ArCal migration | v2.0 | 3/3 | Complete | — |

### Phase 12: Rename from Miro to ArCal across app, web, admin; research all remaining Miro IDs/usages and plan migration

**Goal:** มี inventory ครบทุกการใช้ \"miro\" ในระบบ และเปลี่ยน user-facing surfaces เป็น ArCal ทั้งหมด พร้อมเอกสารแผน migration สำหรับ internal IDs/slug
**Requirements**: TBD (inventory / migration)
**Depends on:** Phase 11
**Plans:** 3 plans in 3 waves
**Status:** ✅ Complete (ตามที่ทีมยืนยัน)

Plans:
- [x] 12-01: Research & inventory ทุกการใช้ \"miro\" + classify และตัดสินใจเบื้องต้น [wave 1]
- [x] 12-02: User-facing rename (mobile/web/system dialogs) + verification commands [wave 2]
- [x] 12-03: Internal ID/slug/namespace strategy + migration/verification plan [wave 3]

---

### 🚧 v3.0 Arcal 2.00 (upgrade_basic)

**Milestone goal:** ประสบการณ์หลักโหมดเดียว (basic), แซนด์บ็อกซ์จัดกลุ่มมื้อเบาๆ, โภชนาการจาก sub เป็นความจริง, ซ่อน Quest/แชท, ถอด free energy legacy, วันที่อนาคต, ย้ายข้ามมื้อ, รวมกลุ่ม entry, thumbnail, สร้างเมนูจากรูป, share card, promo code

**Spec:** `_project_manager/arcal_2_00/arcal2-01.md`

- [x] **Phase 13: Ingredients schema & recompute** — `ingredientsJson` v2, backwards read, flatten, recompute pipeline (completed 2026-03-29)
- [x] **Phase 14: App shell & energy** — Lock basic, My Meal, hide chat & QuestBar, bottom nav alignment, remove legacy free energy (completed 2026-03-29)
- [x] **Phase 15: Sandbox timeline** — Meal grouping in `FoodSandbox`, future date navigation, cross-meal move UX (completed 2026-03-29)
- [x] **Phase 16: Ingredient UI & AI** — Add/Edit/Gemini/Intent unified rules; Gemini prompt/post-process alignment (completed 2026-03-29 — verify UAT `16-MANUAL-CHECKLIST.md`)
- [x] **Phase 17: Merge & media** — Group merge, micro thumbnails + preview, Create Meal gallery → analysis (completed 2026-03-29 — UAT `17-MANUAL-CHECKLIST.md`)
- [x] **Phase 18: Share & promo** — Share card aspect + serving toggle; Settings redeem; admin CRUD + backend (completed 2026-03-29 — UAT/deploy `18-MANUAL-CHECKLIST.md`)

## Phase Details (v3.0)

### Phase 13: Ingredients schema & recompute
**Goal:** มีโมเดล/สัญญาข้อมูลเดียวสำหรับ main/sub สูงสุด 2 ระดับ, อ่านข้อมูลเก่าได้, และฟังก์ชัน recompute ที่เหลือทีม implement ทุกจุดใช้ร่วมกันได้  
**Depends on:** — (v2.0 เฟส 6–12 เสร็จแล้ว)  
**Requirements:** ARC2-DATA-01, ARC2-DATA-02, ARC2-DATA-03  
**Success criteria:**
1. Legacy `ingredientsJson` ยังโหลดได้โดยไม่ crash; บันทึกใหม่ใช้รูปแบบใหม่
2. Unit / integration test หรือ manual checklist ยืนยัน recompute sub → main → entry
3. ตัวช่วย flatten จากผล AI ลึกเกิน 2 ระดับมีการทดสอบอย่างน้อย 1 เคส

**Plans:** 2/2 plans complete

### Phase 14: App shell & energy
**Goal:** ผู้ใช้เห็น shell เดียว (basic), เข้า My Meal จาก AppBar, ไม่เห็น QuestBar/แชท, Energy Store ไม่มีทางรับ free energy legacy  
**Depends on:** —  
**Requirements:** ARC2-SHELL-01 … ARC2-SHELL-05, ARC2-ENERGY-01  
**Success criteria:**
1. ไม่มี UI สลับ Pro; ไม่มี `ModeToggle`
2. แตะ My Meal จาก AppBar แล้วเข้า `HealthMyMealTab` + กลับได้
3. `QuestBar` ไม่แสดงบนหน้าหลักที่กำหนด
4. ไม่มี flow เรียก `claimFreeEnergy` / tile ที่เกี่ยว; free pass / offer อื่นยังทำงาน

**Plans:** 2/2 plans complete

### Phase 15: Sandbox timeline
**Goal:** รายการอาหารต่อวันแสดงเป็น feed เดียวพร้อมกลุ่มมื้อเบาๆ; เลื่อนไปวันอนาคตได้; ย้ายรายการระหว่างมื้อได้  
**Depends on:** Phase 14 (แนะนำ — shell เสถียร)  
**Requirements:** ARC2-TIMELINE-01, ARC2-TIMELINE-02, ARC2-TIMELINE-03  
**Success criteria:**
1. มื้อเช้า/กลางวัน/เย็น/ว่างแยกมองเห็นได้โดยไม่ใช้ layout แบบ Pro `MealSection` เป็นหลัก
2. เลือกวันพรุ่งนี้ใน summary/date bar ได้สอดคล้องกันทุกจุดที่เกี่ยว
3. ผู้ใช้เปลี่ยน `mealType` จาก sandbox ได้อย่างน้อย 1 วิธี (ลากหรือปุ่ม)

**Plans:** 3/3 plans complete

### Phase 16: Ingredient UI & AI
**Goal:** ทุกจุดบันทึก/แก้ไข/AI ใช้กฎเดียวกับ arcal2-00/01 (ล็อก main, derive จาก sub, สเกลรวม, root=main)  
**Depends on:** Phase 13  
**Requirements:** ARC2-ING-01 … ARC2-ING-04, ARC2-AI-01  
**Success criteria:**
1. หลัง AI วิเคราะห์ชื่อจาน ตัวเลขรวมสอดคล้องผลรวมจาก mains/subs
2. แก้ sub แล้ว entry อัปเดต; แก้ปริมาณรวมแล้ว sub สเกล
3. `IntentHandler` / sheets หลักไม่แตกคนละสัญญา

**Plans:** 4 plans — `16-01` (Add/Edit + codec), `16-02` (Gemini / food preview), `16-03` (AI write paths: prompt + chat + log_from_meal), `16-04` (readers + MyMeal + checklist) ใน `.planning/phases/16-ingredient-ui-ai/` — `16-01` ขึ้นต่อ `13-02`; `16-04` ขึ้นต่อ `16-03`

### Phase 17: Merge & media
**Goal:** รวมหลาย entry เป็นกลุ่ม; thumbnail ราย ingredient; สร้างเมนูจากรูป  
**Depends on:** Phase 13, Phase 15  
**Requirements:** ARC2-GR-01, ARC2-THUMB-01, ARC2-MEAL-01  
**Success criteria:**
1. Multi-select → Group สร้าง entry ใหม่ชื่อ `group_xxx` และลบ/รวมข้อมูลตามสเปก
2. แถวที่มีรูปแสดง thumb เล็ก; แตะดูเต็ม + bbox ถ้ามี
3. Create Meal: เลือกรูปแล้วได้ผลวิเคราะห์เหมือน flow รูปปกติ

**Plans:** 3 plans — `17-01` (Group merge), `17-02` (thumb + schema โหนด), `17-03` (Create Meal gallery) ใน `.planning/phases/17-merge-media/` — `17-01` ขึ้นต่อ `13-02`, `15-03`, `16-04` ใน frontmatter

### Phase 18: Share & promo
**Goal:** แชร์การ์ดหลายสัดส่วน + ปริมาณ; แลกโค้ดใน Settings; แอดมินจัดการโค้ด  
**Depends on:** — (ทำ parallel ได้บางส่วน)  
**Requirements:** ARC2-SHARE-01, ARC2-PROMO-01, ARC2-PROMO-02  
**Success criteria:**
1. Export 16:9 และ 1:1 ได้จาก UI
2. Toggle แสดงปริมาณบนภาพทำงาน
3. Redeem สำเร็จ/ล้มเหลวมีข้อความชัด; admin สร้างโค้ดจำกัดครั้ง/ผู้ใช้/วันหมดอายุได้

**Plans:** 3 plans — `18-01` (share card aspect + serving food only), `18-02` (Functions + Firestore + admin CRUD), `18-03` (Settings redeem) ใน `.planning/phases/18-share-promo/` — `18-03` ขึ้นต่อ `18-02`; `18-01` ∥ `18-02` ได้

## Progress (v3.0)

| Phase | Milestone | Requirements | Status |
|-------|-----------|--------------|--------|
| 13. Schema & recompute | v3.0 | Complete    | 2026-03-29 |
| 14. Shell & energy | v3.0 | Complete    | 2026-03-29 |
| 15. Sandbox timeline | v3.0 | Complete    | 2026-03-29 |
| 16. Ingredient UI & AI | v3.0 | ARC2-ING-*, ARC2-AI-01 | Complete (manual UAT: `16-MANUAL-CHECKLIST.md`) |
| 17. Merge & media | v3.0 | ARC2-GR-*, ARC2-THUMB-*, ARC2-MEAL-01 | Complete (manual UAT: `17-MANUAL-CHECKLIST.md`) |
| 18. Share & promo | v3.0 | ARC2-SHARE-*, ARC2-PROMO-* | Complete (manual UAT + deploy: `18-MANUAL-CHECKLIST.md`) |

**Suggested execution order:** 13 → 14 → 15 → 16 → 17 → 18 (adjust if parallelizing 14/18 with 13)
