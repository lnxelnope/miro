---
phase: 18
slug: share-promo
status: draft
nyquist_compliant: true
wave_0_complete: true
created: 2026-03-29
---

# Phase 18 — Validation Strategy

## Infrastructure

| Check | Command / artifact |
|-------|-------------------|
| Analyze (app) | `flutter analyze lib/features/sharing/ lib/features/profile/presentation/profile_screen.dart` + ไฟล์ service ใหม่ |
| Functions | `cd functions && npm run build` (หรือสคริปต์ที่โปรเจกต์ใช้) |
| Admin | `cd admin-panel && npm run build` |
| Manual | `18-MANUAL-CHECKLIST.md` |

## REQ → Plan

| Plan | Requirements |
|------|----------------|
| 18-01 | ARC2-SHARE-01 |
| 18-02 | ARC2-PROMO-02 (backend + admin CRUD) |
| 18-03 | ARC2-PROMO-01 + ผูกกับ API จาก 18-02 |

## Sign-Off

- [ ] ROADMAP success 1–3 ครบใน checklist
- [ ] `nyquist_compliant: true`

**Approval:** pending
