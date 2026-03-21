---
phase: 11-app-rebrand
plan: 01
subsystem: ui
tags: [flutter, android, ios, branding]

# Dependency graph
requires:
  - phase: 10-review-pipeline
    provides: Stable end-to-end capture and review flow before rebrand
provides:
  - Updated app display name to "ArCal - AI Calorie Counter" on Android and iOS
  - Updated pubspec description to new ArCal branding
affects: [11-app-rebrand, store-listing]

# Tech tracking
tech-stack:
  added: []
  patterns: ["Dedicated rebrand phase with minimal code changes"]

key-files:
  created: []
  modified:
    - android/app/src/main/AndroidManifest.xml
    - ios/Runner/Info.plist
    - pubspec.yaml

key-decisions:
  - "Keep package/bundle identifiers (miro_hybrid, bundle id) unchanged and only update user-facing names."

patterns-established:
  - "Use ArCal - AI Calorie Counter as the canonical full display name on both platforms."

requirements-completed: [BRAND-01]

# Metrics
duration: 1min
completed: 2026-03-16
---

# Phase 11 Plan 01: Display Name Change Summary

**Updated Android and iOS app display names to \"ArCal - AI Calorie Counter\" while preserving existing identifiers and build stability.**

## Performance

- **Duration:** ~1 min (tool-execution estimate)
- **Started:** 2026-03-16T09:12:05Z
- **Completed:** 2026-03-16T09:12:08Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments
- Updated Android `android:label` so the launcher name shows "ArCal - AI Calorie Counter".
- Updated iOS `CFBundleDisplayName` to "ArCal - AI Calorie Counter" without touching bundle identifier.
- Refreshed `pubspec.yaml` description to match the new ArCal branding.

## Task Commits

Each task was committed atomically:

1. **Task 1: ค้นหาการใช้งานชื่อแอปปัจจุบันในโปรเจกต์** - _Inspection only, no code changes (documented here, no commit created)_
2. **Task 2: ปรับชื่อแอปใน AndroidManifest และ Info.plist** - `2311470` (feat)

**Plan metadata:** _(to be added by docs commit at the end of phase execution)_

_Note: TDD was not required for this configuration-only change._

## Files Created/Modified
- `android/app/src/main/AndroidManifest.xml` - Updated `android:label` to ArCal - AI Calorie Counter for launcher display.
- `ios/Runner/Info.plist` - Updated `CFBundleDisplayName` to ArCal - AI Calorie Counter for home screen name.
- `pubspec.yaml` - Updated description string to ArCal - AI Calorie Counter branding.

## Decisions Made
- Kept package name (`miro_hybrid`) and bundle identifier unchanged to avoid app-store update and user migration issues.
- Aligned both platforms on the exact same display name string for consistent branding.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external configuration or store dashboard changes were made in this plan. Store listing updates remain a separate release task.

## Next Phase Readiness
- Phase 11-01 requirement BRAND-01 is satisfied; launcher and display names now show ArCal branding on both platforms.
- Ready to proceed with Phase 11-02 to update all privacy and permission strings to reference ArCal instead of Miro.

---
*Phase: 11-app-rebrand*
*Completed: 2026-03-16*
## Self-Check: PASSED
