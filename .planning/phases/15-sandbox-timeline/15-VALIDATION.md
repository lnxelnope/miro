---
phase: 15
slug: sandbox-timeline
status: draft
nyquist_compliant: true
wave_0_complete: true
created: 2026-03-29
---

# Phase 15 — Validation Strategy

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Flutter analyzer + manual checklist |
| **Quick run** | `flutter analyze lib/core/constants/date_planning_limits.dart lib/features/home/widgets/food_sandbox.dart lib/features/health/widgets/daily_summary_card.dart lib/features/health/widgets/date_navigation_bar.dart` |
| **Full** | `flutter test` (ถ้ามีเทสต์ที่เกี่ยว) |

## Sampling Rate

- หลังแต่ละ wave: `flutter analyze` ชุดไฟล์ที่เกี่ยว
- ก่อนปิดเฟส: `15-MANUAL-CHECKLIST.md`

## Per-Task Map

| Plan | REQ | Verify |
|------|-----|--------|
| 15-01 | ARC2-TIMELINE-02 | analyze + grep DatePlanningLimits |
| 15-02 | ARC2-TIMELINE-03 | analyze + ไฟล์ change_meal_bottom_sheet มีอยู่ |
| 15-03 | ARC2-TIMELINE-01 | analyze + manual |

## Manual-Only

- มุมมองกลุ่มมื้อบนอุปกรณ์จริง / emulator
- เลื่อนไปพรุ่งนี้จาก summary + date bar
- multi-select → ย้ายมื้อ

## Sign-Off

- [ ] `nyquist_compliant: true`
- [ ] Checklist สร้างในแผน 03

**Approval:** pending
