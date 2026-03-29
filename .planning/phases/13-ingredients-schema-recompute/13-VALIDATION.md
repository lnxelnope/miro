---
phase: 13
slug: ingredients-schema-recompute
status: draft
nyquist_compliant: true
wave_0_complete: true
created: 2026-03-29
---

# Phase 13 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Flutter test (`package:flutter_test`) |
| **Config file** | `pubspec.yaml` (existing dev_dependencies) |
| **Quick run command** | `flutter test test/core/nutrition/ingredients_codec_test.dart` |
| **Full suite command** | `flutter test` |
| **Estimated runtime** | ~30–120 seconds (project size dependent) |

---

## Sampling Rate

- **After every task commit:** Run `flutter test test/core/nutrition/ingredients_codec_test.dart`
- **After every plan wave:** Run `flutter test`
- **Before `/gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 120 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 13-01-01 | 01 | 1 | ARC2-DATA-01 | impl | `flutter analyze lib/core/nutrition` | ⬜ W1 | ⬜ pending |
| 13-01-02 | 01 | 1 | ARC2-DATA-02 | impl | same + unit in 02 | ⬜ W1 | ⬜ pending |
| 13-01-03 | 01 | 1 | ARC2-DATA-03 | impl | unit in 02 | ⬜ W1 | ⬜ pending |
| 13-02-01 | 02 | 2 | ARC2-DATA-01 | unit | `flutter test test/core/nutrition/ingredients_codec_test.dart` | ⬜ W2 | ⬜ pending |
| 13-02-02 | 02 | 2 | ARC2-DATA-02 | unit | same file | ⬜ W2 | ⬜ pending |
| 13-02-03 | 02 | 2 | ARC2-DATA-03 | unit | same file | ⬜ W2 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [x] Existing `flutter test` infrastructure (`test/widget_test.dart`, etc.) — no new framework install
- [ ] `test/core/nutrition/ingredients_codec_test.dart` — created in plan 02 (stubs acceptable only if immediately filled)

*Wave 0 = use existing Flutter test setup.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|---------------------|
| Legacy entry open in app without crash | ARC2-DATA-01 | Full UI wiring is Phase 16 | After Phase 16: open FoodDetail for entry with legacy `ingredientsJson` list |
| Optional: parse-only smoke | ARC2-DATA-01 | If executor adds temporary debug/main | Run snippet calling `parseIngredientsJson` on device JSON export |

*Primary proof for Phase 13: automated unit tests.*

---

## Validation Sign-Off

- [ ] All tasks have automated verify via `flutter test` (plan 02) or analyzer (plan 01)
- [ ] Sampling continuity: plan 01 followed by plan 02 tests
- [ ] Wave 0 covers all MISSING references — N/A (existing infra)
- [ ] No watch-mode flags
- [ ] Feedback latency < 120s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
