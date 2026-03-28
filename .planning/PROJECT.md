# ArCal - AI Calorie Counter

## What This Is

ArCal (formerly Miro) is an offline-first AI calorie and nutrition tracking mobile app built with Flutter. Users log food intake via camera, gallery, barcode scanning, chat, or manual entry. The app uses local ML Kit for food detection and Gemini API for detailed nutritional analysis. It supports gamification (energy tokens), subscription/IAP, health platform integration (HealthKit/Health Connect), and multi-language (EN/TH/VI).

## Core Value

ผู้ใช้สามารถบันทึกแคลอรี่และสารอาหารได้อย่างแม่นยำและสะดวกที่สุด โดยใช้ AI ช่วยวิเคราะห์จากภาพถ่ายอาหาร

## Current Milestone: v3.0 Arcal 2.00 (upgrade_basic)

**Goal:** รวมประสบการณ์หลักเป็นโหมดเดียว (Basic เป็นหลัก), จัดกลุ่มมื้อในแซนด์บ็อกซ์, ทำให้โภชนาการสอดคล้องกับ sub-ingredients เป็นความจริงเดียว, ปรับพลังงาน/แชท/QuestBar ตามสเปก, และเพิ่มฟีเจอร์รอง (วันที่อนาคต, share card, promo code).

**Target features:**

- `ingredientsJson` / โมเดล v2 + recompute (sub → main → entry), อ่านข้อมูลเก่าได้
- ล็อก `AppMode` basic; ถอด `ModeToggle`; ปุ่ม My Meal → `HealthMyMealTab`; ซ่อนแชท (เก็บโค้ด); ซ่อน QuestBar; ถอด free energy legacy ใน Energy Store
- `FoodSandbox` + กลุ่มมื้อแบบเบา (ไม่ใช้ `MealSection` แบบ Pro เป็นหลัก); เลือกวันอนาคต; ย้ายรายการข้ามมื้อ
- Add/Edit/Gemini/Intent: main ล็อกเมื่อมี sub; derive จาก sub; สเกลปริมาณรวม; AI root = main; flatten สูงสุด 2 ระดับ
- Group/Merge หลาย entry → entry เดียว (`group_xxx`); thumbnail ingredient + full view + bbox; Create Meal — ปุ่ม gallery → pipeline วิเคราะห์รูป
- Share card: aspect 16:9 / 1:1 + toggle ปริมาณ; Settings redeem code + admin CRUD + limits/expiry

**Research / spec:** `_project_manager/arcal_2_00/arcal2-00.md`, `arcal2-01.md` และ `.planning/research/ARC2-00-POINTERS.md`

## Requirements

### Validated

<!-- Shipped and confirmed valuable (v1.0 - v1.2.2) -->

- ✓ Food entry tracking with calories and macronutrients — v1.0
- ✓ Camera capture for food analysis — v1.0
- ✓ Gallery image picker for food analysis — v1.0
- ✓ Gemini API integration for AI nutritional analysis — v1.0
- ✓ ML Kit local AI (image labeling, text recognition, barcode) — v1.0
- ✓ Barcode scanner for packaged food — v1.0
- ✓ My Meals (saved meal templates) — v1.0
- ✓ Ingredients database — v1.0
- ✓ Chat-based food logging — v1.0
- ✓ Retro scan (gallery auto-scan past 7 days) — v1.0
- ✓ User profile with TDEE/goal setting — v1.0
- ✓ Health timeline view — v1.0
- ✓ Multi-language support (EN/TH/VI) — v1.0
- ✓ Offline-first with Isar database — v1.0
- ✓ Energy gamification system — v1.1
- ✓ In-app purchase / subscription — v1.1
- ✓ Firebase Analytics — v1.2
- ✓ Health Connect / HealthKit integration — v1.2
- ✓ In-app review prompt — v1.2
- ✓ Google Ads integration — v1.2

### Active (v3.0)

<!-- See .planning/REQUIREMENTS.md — ARC2-* -->

- [ ] Schema & recompute foundation (ARC2-DATA-*)
- [ ] App shell: basic-only, My Meal, hide chat/quest, energy legacy removal (ARC2-SHELL-*, ARC2-ENERGY-*)
- [ ] Sandbox meal groups, future dates, cross-meal move (ARC2-TIMELINE-*)
- [ ] Ingredient sheets + Gemini + intent + AI prompt alignment (ARC2-ING-*, ARC2-AI-*)
- [ ] Group merge, thumbnails, create-meal gallery (ARC2-GR-*, ARC2-THUMB-*, ARC2-MEAL-*)
- [ ] Share card + promo redeem + admin (ARC2-SHARE-*, ARC2-PROMO-*)

### Validated (v2.0 GSD — Phases 6–12)

<!-- ยืนยันโดยทีม: เฟส 6–12 เสร็จแล้ว — รายละเอียดใน REQUIREMENTS.md (ARSCAN-*, BRAND-*) และ ROADMAP -->

- ✓ v2.0 ARscan pipeline (foundation → stream → detection → multi-angle → review → navigation) — Phases 6–10
- ✓ App rebrand user-facing (ArCal) — Phase 11
- ✓ Miro→ArCal inventory / rename / internal ID strategy — Phase 12

### Out of Scope

- Real-time cloud streaming — Local AI only for bounding box, cloud API only for final analysis
- 3D food reconstruction — Too complex, multi-angle 2D analysis is sufficient
- Package name change — Existing installs must not break
- **v3.0:** Re-enabling Pro mode UI for end users; feature flags for v3.0 rollout (ship with version bump only)
- **v3.0:** New global search bar (use existing Add flow search)

## Context

- **Tech stack:** Flutter 3.x, Riverpod, Drift (SQLite) / legacy Isar references in older docs, ML Kit, Gemini API, Firebase
- **Current version:** 1.2.2+51 (published) — bump with v3.0 release train
- **Camera flow:** CameraScreen → ImageAnalysisPreviewScreen → Gemini analysis
- **ML Kit usage:** VisionProcessor for image labeling (food detection), text recognition, barcode scanning
- **App naming:** User-facing ArCal; package `miro_hybrid` unchanged

## Constraints

- **Package name**: Must remain `miro_hybrid` — changing would break existing installs and store listings
- **Offline-first**: Core food tracking must work without internet
- **Local AI for bounding box**: Real-time detection must use on-device ML (ML Kit or TFLite), not cloud API
- **Flutter**: Must stay within Flutter ecosystem
- **Gemini API**: Final nutritional analysis uses Gemini (user BYOK model)
- **v3.0 data:** `ingredientsJson` changes must be backwards-compatible on read

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| v3.0 Arcal 2.00 | Product upgrade from `_project_manager/arcal_2_00` | In progress |
| v2.0 phases 6–12 complete | ARscan + rebrand + migration shipped per team | Done |
| Single visible mode (basic) | Reduce confusion; Pro code retained | Pending |
| Nutrition truth from subs when present | Consistency with Create Meal + AI ingestion | Pending |
| Skip fresh GSD ecosystem research | arcal2-00 / arcal2-01 already document codebase + decisions | Done |
| Phase numbering continues at 13 | v2.0 roadmap uses phases 6–12 | Active |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):

1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):

1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-03-29 — v2.0 เฟส 6–12 ทำเครื่องหมายว่าเสร็จแล้ว; งานค้าง = v3.0 เฟส 13–18 เท่านั้น*
