---
phase: 11-app-rebrand
plan: 02
subsystem: ui
tags: [flutter, ios, localization, branding]

# Dependency graph
requires:
  - phase: 11-app-rebrand
    provides: "11-01 updated core naming and assets"
provides:
  - "ArCal branding applied to privacy/permission texts in en/th Flutter localization"
  - "ArCal branding applied to iOS camera/photo/tracking permission dialogs (en/th/vi)"
affects: [onboarding, permissions, legal, ios]

# Tech tracking
tech-stack:
  added: []
  patterns: ["Centralize app-name/legal text branding via ARB + InfoPlist.strings, no hardcoded strings"]

key-files:
  created: []
  modified:
    - lib/l10n/app_en.arb
    - lib/l10n/app_th.arb
    - ios/Runner/en.lproj/InfoPlist.strings
    - ios/Runner/th.lproj/InfoPlist.strings
    - ios/Runner/vi.lproj/InfoPlist.strings

key-decisions:
  - "Limit scope of this plan to privacy/permission and legal texts while keeping Miro AI persona naming unchanged"
  - "Use 'ArCal — AI Calorie Counter' as the long-form product name in legal subtitles across locales"

patterns-established:
  - "App name in system permission dialogs comes exclusively from InfoPlist.strings per locale"
  - "App name in in-app privacy/terms/consent screens comes from ARB localization keys, not hardcoded strings"

requirements-completed: [BRAND-02]

# Metrics
duration: ~20min
completed: 2026-03-16
---

# Phase 11 Plan 02: App Rebrand Privacy & Permissions Summary

**Updated privacy, legal, and iOS permission copy to reference ArCal instead of MiRO while keeping localization keys stable.**

## Performance

- **Duration:** ~20 min
- **Started:** 2026-03-16T08:55:00Z
- **Completed:** 2026-03-16T09:14:16Z
- **Tasks:** 2
- **Files modified:** 5

## Accomplishments
- Updated Flutter localization in English and Thai so app name and privacy/terms subtitles use ArCal branding.
- Updated iOS InfoPlist camera/photo/tracking permission dialogs in en/th/vi to show ArCal instead of Miro.
- Preserved all localization keys, placeholders, and technical identifiers to avoid breaking existing code paths.

## Task Commits

Each task was committed atomically:

1. **Task 2: อัปเดตข้อความชื่อแอปใน localization และ InfoPlist.strings** - `9b28e40` (feat)

**Plan metadata commit:** _Pending — will be created as docs commit for SUMMARY/STATE/ROADMAP updates._

## Files Created/Modified
- `lib/l10n/app_en.arb` - Renamed app name, app bar title, and privacy/terms/consent subtitles from MiRO to ArCal in English.
- `lib/l10n/app_th.arb` - Renamed app name, app bar title, and privacy/terms/consent subtitles from MiRO to ArCal in Thai.
- `ios/Runner/en.lproj/InfoPlist.strings` - Updated camera/photo/tracking permission copy to reference ArCal in English.
- `ios/Runner/th.lproj/InfoPlist.strings` - Updated camera/photo/tracking permission copy to reference ArCal in Thai.
- `ios/Runner/vi.lproj/InfoPlist.strings` - Updated camera/photo/tracking permission copy to reference ArCal in Vietnamese.

## Decisions Made
- Focus this plan on privacy/permission dialogs and legal copy, leaving the conversational “Miro AI” persona strings for a later branding pass if desired.
- Use a single long-form product name, “ArCal — AI Calorie Counter”, in English across privacy policy and terms subtitles even in Thai locale, to keep legal naming consistent.
- Avoid touching unrelated ARB locales in this plan to keep scope aligned with the specified modified files and requirement BRAND-02.

## Deviations from Plan

None - plan executed as written, with changes confined to the specified localization and InfoPlist files.

## Issues Encountered

None.

## User Setup Required

None - no external configuration required beyond shipping updated app binaries to stores.

## Next Phase Readiness

- iOS and Flutter privacy/permission flows now consistently show ArCal branding, satisfying BRAND-02 for the targeted locales.
- Broader rebrand of conversational “Miro AI” persona and non-privacy strings can be handled in a follow-up branding/content pass if needed.

## Self-Check

- Verified all modified files exist on disk and are tracked in commit `9b28e40`.
- Confirmed that only user-facing text was changed; keys and technical identifiers remain untouched.

---

*Phase: 11-app-rebrand*
*Completed: 2026-03-16*

