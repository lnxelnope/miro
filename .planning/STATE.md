---
gsd_state_version: 1.0
milestone: v3.0
milestone_name: Arcal 2.00 (upgrade_basic)
status: milestone_code_complete
last_updated: "2026-03-29T12:00:00.000Z"
progress:
  total_phases: 6
  completed_phases: 6
  total_plans: 17
  completed_plans: 17
---

# Project State

## Project Reference

See: `.planning/PROJECT.md` (Current Milestone: v3.0)

**Core value:** ผู้ใช้สามารถบันทึกแคลอรี่และสารอาหารได้อย่างแม่นยำและสะดวกที่สุด โดยใช้ AI ช่วยวิเคราะห์จากภาพถ่ายอาหาร

**Current focus:** UAT + deploy production ตาม `18-MANUAL-CHECKLIST.md` (และ checklist เฟส 16–17 ถ้ายังไม่ sign-off)

## Current Position

Phase: **13–18 โค้ดใน repo ครบ** — งานที่เหลือคือ manual UAT, `firebase deploy` (rules/indexes/functions), และ deploy admin-panel ตาม stack ของทีม

### ตรวจใน repo (ล่าสุด)

- `functions/`: `npm run build` (tsc) ผ่าน  
- `admin-panel/`: `npm run build` ผ่าน  
- Flutter: **ไม่มี analyzer error** เมื่อใช้ `flutter analyze --no-fatal-infos --no-fatal-warnings`; แก้ `test/integration/quest_bar_test.dart` (mock Uri + ลบ `DeviceIdService.deviceId` ที่ไม่มีใน API)  
- `firebase deploy --only firestore:rules,firestore:indexes,functions` จาก sandbox อาจล้มเหลวเรื่องเครือข่าย/API — **รันซ้ำบนเครื่องที่ login Firebase ได้**

## Performance Metrics

*Reset for new milestone — metrics fill in as plans complete.*

## Accumulated Context

### Decisions (v3.0)

- Research: reuse `_project_manager/arcal_2_00` (arcal2-00 / arcal2-01); skip fresh 4-agent ecosystem research for this milestone
- Phase numbering: **Phase 13+** — v2.0 เฟส 6–12 **เสร็จแล้ว** (ยืนยันโดยทีม)
- No feature flags for v3.0 — ship with version bump (per product decision in arcal2-01)
- Pro mode: **no user access**; `AppMode` locked to basic; Pro code retained in repo

### v2.0 status

- เฟส **6–12** ถือว่า **ปิดงานแล้ว** — v3.0 เฟส **13–18** โค้ดใน repo **ครบ**; เหลือ UAT / deploy ตาม checklist

### Blockers / Concerns

- `ingredientsJson` v2 must remain **backwards-compatible** with existing user data on device
- Promo codes require **backend + admin-panel + app Settings** — coordinate releases (Phase 18: ต่อยอด repo เดิม — ดู `18-CONTEXT.md`)

## Session Continuity

Last session: 2026-03-30T01:00:00.000Z
Resume file: .planning/phases/18-share-promo/18-MANUAL-CHECKLIST.md
