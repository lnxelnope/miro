---
gsd_state_version: 1.0
milestone: v3.0
milestone_name: Arcal 2.00 (upgrade_basic)
status: defining
stopped_at: —
last_updated: "2026-03-29T12:00:00.000Z"
last_activity: 2026-03-29 — Milestone v3.0 started (GSD new-milestone)
progress:
  total_phases: 6
  completed_phases: 0
  total_plans: 0
  completed_plans: 0
  percent: 0
---

# Project State

## Project Reference

See: `.planning/PROJECT.md` (Current Milestone: v3.0)

**Core value:** ผู้ใช้สามารถบันทึกแคลอรี่และสารอาหารได้อย่างแม่นยำและสะดวกที่สุด โดยใช้ AI ช่วยวิเคราะห์จากภาพถ่ายอาหาร

**Current focus:** Milestone v3.0 — Arcal 2.00 (`upgrade_basic`): single-mode UX, meal grouping in sandbox, ingredients truth from subs, energy/chat cleanup, promo codes, share card, future dates.

## Current Position

Phase: Not started (roadmap defined — Phase 13 next)
Plan: —
Status: Ready to plan / execute Phase 13
Last activity: 2026-03-29 — v2.0 เฟส 6–12 ทำเครื่องหมายเสร็จแล้ว; เหลือ v3.0 เฟส 13–18

Progress: [░░░░░░░░░░] 0%

## Performance Metrics

*Reset for new milestone — metrics fill in as plans complete.*

## Accumulated Context

### Decisions (v3.0)

- Research: reuse `_project_manager/arcal_2_00` (arcal2-00 / arcal2-01); skip fresh 4-agent ecosystem research for this milestone
- Phase numbering: **Phase 13+** — v2.0 เฟส 6–12 **เสร็จแล้ว** (ยืนยันโดยทีม)
- No feature flags for v3.0 — ship with version bump (per product decision in arcal2-01)
- Pro mode: **no user access**; `AppMode` locked to basic; Pro code retained in repo

### v2.0 status

- เฟส **6–12** ถือว่า **ปิดงานแล้ว** — โฟกัสเหลือ **v3.0 เฟส 13–18** เท่านั้น

### Blockers / Concerns

- `ingredientsJson` v2 must remain **backwards-compatible** with existing user data on device
- Promo codes require **backend + admin-panel + app Settings** — coordinate releases

## Session Continuity

Last session: 2026-03-29 — `/gsd-new-milestone` + `_project_manager/arcal_2_00`
Resume file: None
