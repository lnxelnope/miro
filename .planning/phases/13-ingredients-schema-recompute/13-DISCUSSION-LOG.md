# Phase 13: Ingredients schema & recompute - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.  
> Decisions are captured in `13-CONTEXT.md`.

**Date:** 2026-03-29  
**Phase:** 13 — Ingredients schema & recompute  
**Mode:** Spec-led capture (`/gsd-discuss-phase 13`) — ไม่ได้ทำ conversational multi-select แยกทีละหัวข้อในเซสชันนี้

**Areas covered implicitly:** phase boundary, backwards compatibility, depth/truth source, AI flatten, micro roll-up scope, JSON key language

---

## Summary

| Topic | Resolution |
|-------|----------------|
| Max depth | 2 levels: mains → subs (CONTEXT D-01) |
| Legacy read | Support `List` decode; lazy migrate on save (D-05–D-06) |
| Entry totals when subs exist | Macros derived via recompute (D-03); micros if present on nodes (D-08) |
| AI nested output | Flatten to 2 levels, no double-count (D-07, arcal2-00/01) |
| UI / prompts | Deferred to Phase 16 |

## User's choice

การสนทนาเดี่ยวไม่ได้ส่งตัวเลือกหัวข้อย่อย — **ใช้คำตัดสินใจที่บันทึกใน arcal2-01 + ARC2-DATA + การสำรวจโค้ด** เป็น authoritative สำหรับ CONTEXT ฉบับนี้

## Claude's Discretion

- โครงสร้าง JSON v2 ละเอียด (ชื่อคีย์ย่อย), โครงสร้างโฟลเดอร์ไฟล์ Dart — ตามส่วน Claude's Discretion ใน CONTEXT

## Deferred Ideas

- Phase 16: ingredient UI lock, Gemini, IntentHandler  
- Phase 17: merge, thumbnails  

---

*End of discussion log*
