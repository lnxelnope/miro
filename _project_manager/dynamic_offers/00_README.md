# Dynamic Offer System — Implementation Guide

> **สำหรับ:** Junior Developer (implement), Senior Developer (review)  
> **Stack:** Firebase Functions (TypeScript), Next.js Admin Panel, Flutter  
> **วันที่:** 21 ก.พ. 2026

---

## ภาพรวม

ปรับระบบ Offer จาก **Hardcoded** → **Hybrid Dynamic**:
- Admin สร้าง/แก้ไข Offer Template ใน Firestore ผ่าน Admin Panel (content, reward, duration)
- Trigger events ยัง hardcode ใน backend (เพิ่ม trigger ใหม่ = deploy code)
- Offers แสดงใน Quest Bar + Energy Store เหมือนเดิม (API response shape เดิม)
- เพิ่ม Notification deep-link → กดเปิด push แล้วไป Energy Store + highlight offer

| หมวด | สรุปการเปลี่ยน |
|------|--------------|
| Firestore | เพิ่ม collection `offer_templates` + เปลี่ยน user offers field เป็น `offers.active` map |
| Backend | สร้าง `offerEngine.ts` สำหรับ evaluate offers + แก้ไข 4 ไฟล์ที่ trigger events |
| Admin Panel | หน้า CRUD สำหรับ Offer Templates (list, create, edit, delete) |
| Flutter | Energy Store รองรับ `free_energy` reward type + notification deep-link |
| Migration | Seed hardcoded offers เป็น templates + migrate user data |

---

## ไฟล์ในโฟลเดอร์นี้

| ไฟล์ | เนื้อหา |
|------|---------|
| `00_README.md` | ภาพรวม, Role, ลำดับงาน (ไฟล์นี้) |
| `01_FIRESTORE_SCHEMA.md` | Schema ของ `offer_templates` collection + user document changes |
| `02_BACKEND_SPEC.md` | `offerEngine.ts` + การแก้ไข analyzeFood, dailyCheckIn, registerUser, verifyPurchase, offersV2 |
| `03_ADMIN_PANEL_SPEC.md` | หน้า Offers CRUD, API routes, form fields, UI mockup |
| `04_FLUTTER_SPEC.md` | Energy Store changes + Notification deep-link |
| `05_MIGRATION_SPEC.md` | Seed data, backward compat, cleanup plan |

---

## Dependencies (ลำดับงาน)

```
Phase 1 — Firestore Schema + Backend Engine (สัปดาห์ที่ 1)
├── T1: สร้าง offer_templates collection ใน Firestore          ← ดู 01_FIRESTORE_SCHEMA.md
├── T2: สร้าง offerEngine.ts (evaluateOffers function)         ← ดู 02_BACKEND_SPEC.md #1
├── T3: เพิ่ม totalMealsLogged counter ใน analyzeFood.ts       ← ดู 02_BACKEND_SPEC.md #2
├── T4: Integrate evaluateOffers ใน analyzeFood.ts              ← ดู 02_BACKEND_SPEC.md #3
├── T5: Integrate evaluateOffers ใน dailyCheckIn.ts             ← ดู 02_BACKEND_SPEC.md #4
├── T6: Integrate evaluateOffers ใน registerUser.ts             ← ดู 02_BACKEND_SPEC.md #5
└── T7: Integrate evaluateOffers ใน verifyPurchase.ts           ← ดู 02_BACKEND_SPEC.md #6

Phase 2 — Rewrite getActiveOffers (สัปดาห์ที่ 1-2)
└── T8: Rewrite offersV2.ts ให้อ่านจาก offer_templates         ← ดู 02_BACKEND_SPEC.md #7
    ⚠️ ต้องรอ T1, T2 เสร็จก่อน

Phase 3 — Admin Panel (สัปดาห์ที่ 2-3)
├── T9: API routes (CRUD)                                       ← ดู 03_ADMIN_PANEL_SPEC.md #1
├── T10: Offers list page                                       ← ดู 03_ADMIN_PANEL_SPEC.md #2
├── T11: Offer create/edit form                                 ← ดู 03_ADMIN_PANEL_SPEC.md #3
└── T12: Sidebar + menu item                                    ← ดู 03_ADMIN_PANEL_SPEC.md #4
    ⚠️ ต้องรอ T1 เสร็จก่อน (ต้องมี collection ก่อน)

Phase 4 — Flutter Changes (สัปดาห์ที่ 3)
├── T13: Energy Store รองรับ free_energy reward type            ← ดู 04_FLUTTER_SPEC.md #1
├── T14: Notification deep-link handler                         ← ดู 04_FLUTTER_SPEC.md #2
└── T15: Push Campaign + offer link                             ← ดู 04_FLUTTER_SPEC.md #3
    ⚠️ ต้องรอ T8 เสร็จก่อน (API response shape ต้อง stable)

Phase 5 — Migration + QA (สัปดาห์ที่ 3-4)
├── T16: Seed script สร้าง offer_templates จาก hardcoded        ← ดู 05_MIGRATION_SPEC.md #1
├── T17: Migrate user offers data                               ← ดู 05_MIGRATION_SPEC.md #2
└── T18: ลบ hardcoded logic เก่า                                ← ดู 05_MIGRATION_SPEC.md #3
```

### Timeline โดยประมาณ

| Phase | สัปดาห์ | สรุป |
|-------|---------|------|
| 1 | สัปดาห์ 1 | Firestore schema + Backend engine + Trigger integration |
| 2 | สัปดาห์ 1-2 | Rewrite getActiveOffers |
| 3 | สัปดาห์ 2-3 | Admin Panel CRUD |
| 4 | สัปดาห์ 3 | Flutter changes |
| 5 | สัปดาห์ 3-4 | Migration + QA |

> **รวม: ~4 สัปดาห์** (1 Junior full-time)

---

## Trigger Events ที่รองรับ

| triggerEvent | อธิบาย | ข้อมูลที่ตรวจ | fire ที่ไหน |
|---|---|---|---|
| `first_energy_use` | ใช้ Energy ครั้งแรก | `totalSpent` เปลี่ยนจาก 0 → 1+ | `analyzeFood.ts` |
| `energy_use_milestone` | ใช้ Energy ถึง threshold | `totalSpent >= triggerCondition.minTotalSpent` | `analyzeFood.ts` |
| `tier_up` | เลื่อน Tier | `newTier` ตรงกับ `triggerCondition.tier` (หรือ any ถ้าไม่ระบุ) | `dailyCheckIn.ts` |
| `first_app_open` | เปิด App ครั้งแรก (register) | user ใหม่ที่เพิ่งสร้าง | `registerUser.ts` |
| `meals_logged_milestone` | Log อาหารถึง threshold | `totalMealsLogged >= triggerCondition.minMealsLogged` | `analyzeFood.ts` |
| `first_purchase_complete` | ซื้อ offer product สำเร็จ | `productId` | `verifyPurchase.ts` |

> **เพิ่ม trigger ใหม่:** ต้อง deploy code — เพิ่ม call `evaluateOffers()` ในไฟล์ที่เกิด event + เพิ่ม triggerEvent ใน dropdown ของ Admin Panel
