---
phase: 14
slug: app-shell-energy
status: draft
nyquist_compliant: true
wave_0_complete: true
created: 2026-03-29
---

# Phase 14 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Flutter analyzer + `flutter test` (มีอยู่) |
| **Config file** | `analysis_options.yaml`, `pubspec.yaml` |
| **Quick run command** | `flutter analyze lib/features/home lib/features/health/presentation/basic_mode_tab.dart lib/features/health/presentation/health_timeline_tab.dart lib/features/energy/presentation/energy_store_screen.dart lib/core/providers/app_mode_provider.dart` |
| **Full suite command** | `flutter test` |
| **Estimated runtime** | ~1–5 min |

---

## Sampling Rate

- **After every task commit:** `flutter analyze` ชุดไฟล์ที่เกี่ยว
- **After wave 2:** `flutter test` (แก้เทสต์ที่แตกถ้ามี)
- **Before release / verify-work:** manual checklist `14-MANUAL-CHECKLIST.md`

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command / Check | Status |
|---------|------|------|-------------|-----------|---------------------------|--------|
| 14-01-* | 01 | 1 | ARC2-SHELL-* | analyze + grep | `flutter analyze` + `rg ModeToggle home_screen` | ⬜ |
| 14-02-* | 02 | 2 | ARC2-ENERGY-01 | analyze + grep | `rg claimFreeEnergy lib` → 0 | ⬜ |

---

## Wave 0 Requirements

- [x] โครง `flutter test` / analyzer มีอยู่แล้ว — ไม่ต้องติดตั้ง framework ใหม่

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Steps |
|----------|-------------|------------|-------|
| My Meal navigation | ARC2-SHELL-02 | UI flow | แตะไอคอน AppBar → เปิด My Meal → กดกลับ |
| QuestBar ไม่บน home | ARC2-SHELL-05 | Visual | เปิดหน้าหลัก basic |
| Free pass ยังใช้ได้ | ARC2-ENERGY-01 | Backend + UI | เปิด Energy Store ทดสอบ free pass ตามเส้นทางเดิม |

---

## Validation Sign-Off

- [ ] Analyzer clean สำหรับไฟล์ที่แตะ
- [ ] Grep gates ในแผนผ่าน
- [ ] `14-MANUAL-CHECKLIST.md` สร้างและครบ D-17
- [ ] `nyquist_compliant: true`

**Approval:** pending
