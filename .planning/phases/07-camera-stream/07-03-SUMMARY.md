---
phase: 07-camera-stream
plan: 03
subsystem: arscan
tags: [camera, diagnostics, fps, stability]

# Dependency graph
requires:
  - phase: 07-camera-stream
    provides: basic camera stream wiring and ARscan entry points
provides:
  - diagnostics utility for measuring camera stream FPS in dev builds
  - reusable long-run stability testing checklist for ARscan camera stream
affects:
  - 08-food-detection
  - 09-multi-angle-capture

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "CameraStreamDiagnostics utility for frame-based FPS sampling and logging"

key-files:
  created:
    - lib/features/arscan/application/camera_stream_diagnostics.dart
  modified: []

key-decisions:
  - "Use lightweight, code-only diagnostics utility (no UI overlay yet) for FPS and stability measurement"

patterns-established:
  - "ARscan camera features should rely on CameraStreamDiagnostics for performance validation in dev"

requirements-completed: [ARSCAN-03]

# Metrics
duration: 1min
completed: 2026-03-16
---

# Phase 07 Plan 03: Camera Stream Diagnostics Summary

**CameraStreamDiagnostics utility นับ frame ต่อวินาทีจาก camera stream และเพิ่ม checklist สำหรับทดสอบ long-run stability อย่างน้อย 5 นาทีใน dev build**

## Performance

- **Duration:** 1min
- **Started:** 2026-03-16T08:14:55Z
- **Completed:** 2026-03-16T08:15:03Z
- **Tasks:** 2
- **Files modified:** 1

## Accomplishments
- สร้าง `CameraStreamDiagnostics` สำหรับนับ frame และคำนวณ fps จาก camera stream พร้อม log แบบต่อเนื่องใน dev build
- เพิ่ม `CameraStreamLongRunTestGuide` พร้อม checklist ทดสอบ long-run stability อย่างน้อย 5 นาที

## Task Commits

Each task was committed atomically:

1. **Task 1: สร้าง diagnostics utility สำหรับนับ frame และคำนวณ fps** - `d4ea54f` (feat)
2. **Task 2: นิยามขั้นตอนทดสอบ long-run stability** - `6bccd59` (feat)

**Plan metadata:** _(จะถูกรวมใน commit docs ขั้นสุดท้ายโดย gsd tools)_

_Note: ไม่มี TDD tasks ในแผนนี้_

## Files Created/Modified
- `lib/features/arscan/application/camera_stream_diagnostics.dart` - utility สำหรับ fps measurement, long-run logging และ long-run stability test guide

## Decisions Made
- ใช้ utility แบบ code-only ที่พึ่งพา `AppLogger` และ `kDebugMode` เพื่อไม่เพิ่มภาระให้ production build
- เก็บ long-run test instructions เป็นคลาสใน codebase เพื่อให้ dev เรียกใช้/อ้างอิงซ้ำได้และค้นหาได้ง่าย

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- Phase 08 (food detection) และ Phase 09 (multi-angle capture) สามารถใช้ CameraStreamDiagnostics เพื่อวัด fps/stability ของ stream ก่อนเพิ่ม logic ด้าน detection และหลายมุมกล้อง

---
*Phase: 07-camera-stream*
*Completed: 2026-03-16*

