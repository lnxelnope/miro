---
phase: 16
slug: ingredient-ui-ai
status: draft
nyquist_compliant: true
wave_0_complete: true
created: 2026-03-29
---

# Phase 16 — Validation Strategy

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Flutter analyzer + `flutter test` (รวม `test/core/nutrition/` จาก Phase 13 ถ้ามี) |
| **Quick** | `flutter analyze lib/features/health/widgets/add_food_bottom_sheet.dart lib/features/health/widgets/edit_food_bottom_sheet.dart lib/features/health/widgets/gemini_analysis_sheet.dart lib/core/ai/gemini_service.dart lib/features/chat/providers/chat_provider.dart` |
| **Full** | `flutter test` |

## Sampling

- หลังแต่ละ wave: analyze ชุดที่เกี่ยว
- ปิดเฟส: `16-MANUAL-CHECKLIST.md` + regression บน path วิเคราะห์รูป

## REQ Map

| Plan | Requirements |
|------|----------------|
| 16-01 | ARC2-ING-01, ARC2-ING-02, ARC2-ING-04 |
| 16-02 | ARC2-ING-03, ARC2-ING-04, ARC2-AI-01 |
| 16-03 | ARC2-ING-04, ARC2-AI-01 |

## Manual

- Lock main เมื่อมี sub บน Add/Edit/Gemini sheet
- Chat food_log บันทึกแล้วเปิดรายการได้ไม่ crash

**Approval:** pending
