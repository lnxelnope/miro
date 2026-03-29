---
gsd_state_version: 1.0
milestone: v3.0
milestone_name: Arcal 2.00 (upgrade_basic)
status: Phase 13–16 planned; Phase 17 planned; Phase 18 planned (18-01→03)
last_updated: "2026-03-30T01:00:00.000Z"
last_activity: 2026-03-29 — `/gsd-plan-phase 18` → RESEARCH, VALIDATION, 18-01..03, MANUAL-CHECKLIST
progress:
  total_phases: 7
  completed_phases: 5
  total_plans: 24
  completed_plans: 12
  percent: 0
---

# Project State

## Project Reference

See: `.planning/PROJECT.md` (Current Milestone: v3.0)

**Core value:** ผู้ใช้สามารถบันทึกแคลอรี่และสารอาหารได้อย่างแม่นยำและสะดวกที่สุด โดยใช้ AI ช่วยวิเคราะห์จากภาพถ่ายอาหาร

**Current focus:** Milestone v3.0 — Arcal 2.00 (`upgrade_basic`): single-mode UX, meal grouping in sandbox, ingredients truth from subs, energy/chat cleanup, promo codes, share card, future dates.

## Current Position

Phase: **18** — **planned** (`18-01`→`18-03-PLAN.md`); **17** ยังรอ dependency 13+15+16
Plan: **18-01** (Share 16:9/1:1 + serving food only) → **18-02** (Functions + admin CRUD) → **18-03** (Settings redeem)
Status: พร้อม execute 18 (แนะนำลำดับ 01 → 02 → 03); หรือคู่ขนาน 01 กับ 02
Last activity: 2026-03-29 — plan-phase 18

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
- Promo codes require **backend + admin-panel + app Settings** — coordinate releases (Phase 18: ต่อยอด repo เดิม — ดู `18-CONTEXT.md`)

## Session Continuity

Last session: 2026-03-30T01:00:00.000Z
Resume file: .planning/phases/18-share-promo/18-01-PLAN.md
