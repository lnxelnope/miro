# UI Standard + Hidden Ingredients — Task Overview

## สรุปงาน

ปรับปรุง UI ให้เป็นมาตรฐานทั้งแอป + เพิ่มฟีเจอร์ Hidden Ingredients

## ลำดับการทำงาน

```
┌──────────────────────────────────────────────────────────────┐
│                    EXECUTION ORDER                            │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  Phase 1 ──▶ Phase 2 ──▶ Phase 3 ──▶ Phase 4                │
│  (Design     (Migrate     (Hidden      (Migrate              │
│   System)     Health)      Ingr.)       Rest)                │
│                                                               │
│  ⏱️ ~1 hr    ⏱️ ~2 hrs    ⏱️ ~2 hrs    ⏱️ ~3 hrs             │
│                                                               │
│  ❗ ห้ามข้าม Phase — ต้องทำตามลำดับ                           │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

## ไฟล์ Task

| Phase | ไฟล์ | สรุป |
|-------|------|------|
| 1 | `PHASE1_DESIGN_SYSTEM.md` | สร้าง Design Tokens + Reusable Components (7 ไฟล์ใหม่) |
| 2 | `PHASE2_MIGRATE_HEALTH.md` | Migrate Health bottom sheets 7 ตัว (Search & Replace) |
| 3 | `PHASE3_HIDDEN_INGREDIENTS.md` | สร้าง Hidden Ingredients feature (2 ไฟล์ใหม่ + แก้ 6 ไฟล์) |
| 4 | `PHASE4_MIGRATE_APP.md` | Migrate หน้าที่เหลือทั้งแอป (Search & Replace ~20 ไฟล์) |

## วิธีใช้

```
1. เปิด New Chat ใน Cursor
2. พิมพ์: @_project_manager/ui_standard_hidden_ingre/PHASE1_DESIGN_SYSTEM.md ทำตาม task นี้
3. เมื่อเสร็จ Phase 1 → เปิด New Chat → ทำ Phase 2
4. ทำซ้ำจนครบ Phase 4
```

## ตรวจงาน

เมื่อเสร็จแต่ละ Phase ให้ Senior (Planner) ตรวจงาน:
```
@_project_manager/workflow.md ตรวจงาน @_project_manager/ui_standard_hidden_ingre/PHASE1_DESIGN_SYSTEM.md
```
