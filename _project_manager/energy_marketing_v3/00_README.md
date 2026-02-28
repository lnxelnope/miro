# Energy Marketing v3.1 — Implementation Guide

> **สำหรับ:** Senior Developer (วางแผน), Junior Developer (implement), Owner (ตั้งค่า IAP/AdMob)  
> **Blueprint อ้างอิง:** `_project_manager/ENERGY_MARKETING_BLUEPRINT.md`  
> **วันที่:** 20 ก.พ. 2026

---

## ภาพรวมการเปลี่ยนแปลง

ปรับระบบ Energy Marketing ทั้งหมดเพื่อเพิ่ม Retention, First Purchase Conversion, และ Revenue

| หมวด | สรุปการเปลี่ยน |
|------|--------------|
| Quest Bar | UI ใหม่บนหน้า Home — รวม Offer, Streak, Challenge, Milestone ไว้ที่เดียว |
| Daily Claim | เปลี่ยนจาก auto → ต้องกด Claim (บังคับเห็น Offer ก่อน) |
| Rewarded Ads | เพิ่มระบบดู Ad ได้ 3 ครั้ง/วัน เมื่อ Energy หมด |
| Milestone | เปลี่ยนจาก 2 ขั้น → 10 ขั้น + สูตร Diminishing Cashback |
| Challenges | ลด reward 5E → 3E ต่ออัน |
| Tier Reward | ปรับเป็น 5/10/15/25E (รวม 55E) |
| $1 Deal | Offer ใหม่ — $1 = 200E หลัง Milestone 10E, 4 ชม. |
| Subscription | เพิ่ม Weekly ($2) + Yearly ($40) + Winback ($3) |
| Referral | เปลี่ยนเป็น Two-way (ทั้งคู่ได้ 5E) |
| Push | เฉพาะ 3 กรณี (Offer หมด, ลืม login, Tier Up) |
| Bug Fix | Offer ซื้อซ้ำได้ไม่จำกัด → 1 ครั้ง/บัญชี |
| ลบออก | Random Bonus, First Empty Bonus 50E, Welcome Offer +50E, Double Quest (Sub) |

---

## ไฟล์ในโฟลเดอร์นี้

| ไฟล์ | สำหรับ | เนื้อหา |
|------|-------|---------|
| `00_README.md` | ทุกคน | ภาพรวม, Role, ลำดับงาน |
| `01_OWNER_SETUP.md` | **Owner** | สิ่งที่ต้องไปตั้งค่าเอง (IAP, AdMob, Push) |
| `02_BACKEND_SPEC.md` | **Senior/Junior** | Firebase Functions ที่ต้องแก้/เพิ่ม |
| `03_FRONTEND_SPEC.md` | **Senior/Junior** | Flutter UI/Logic ที่ต้องแก้/เพิ่ม |
| `04_ADMIN_PANEL_SPEC.md` | **Senior/Junior** | Admin Dashboard features ใหม่ |

---

## Role Assignment

### 🔴 Owner (ต้องทำเอง)
| # | งาน | ไฟล์อ้างอิง | ระยะเวลา |
|---|------|-----------|---------|
| O1 | สร้าง IAP Products ใน Google Play Console | `01_OWNER_SETUP.md` | 1-2 ชม. |
| O2 | สร้าง AdMob Account + Ad Unit IDs | `01_OWNER_SETUP.md` | 1-2 ชม. |
| O3 | ตั้งค่า FCM (Push Notification) | `01_OWNER_SETUP.md` | 30 นาที |
| O4 | Review & Approve App Store screenshots/description | — | 1 ชม. |

### 🟡 Senior (วางแผน + Review)
| # | งาน |
|---|------|
| S1 | Review spec ทุกไฟล์ก่อนแจกงาน |
| S2 | กำหนดลำดับงาน Sprint ตาม Dependencies |
| S3 | Code review ทุก PR |
| S4 | ทดสอบ Integration test (IAP + AdMob + Backend) |

### 🟢 Junior (Implement)
| # | งาน | ไฟล์อ้างอิง | ความยาก | ประมาณเวลา |
|---|------|-----------|---------|-----------|
| J1 | แก้ Bug: Offer ซื้อซ้ำ | `02_BACKEND_SPEC.md` #1 | ง่าย | 2-4 ชม. |
| J2 | ปรับค่า Config: Challenge, Tier, Milestone | `02_BACKEND_SPEC.md` #2 | ง่าย | 2-3 ชม. |
| J3 | ลบ: Random Bonus, First Empty, Double Quest | `02_BACKEND_SPEC.md` #3 | ง่าย | 2-3 ชม. |
| J4 | Backend: Milestone 10 ขั้น + สูตร | `02_BACKEND_SPEC.md` #4 | กลาง | 1-2 วัน |
| J5 | Backend: $1 = 200E Offer flow | `02_BACKEND_SPEC.md` #5 | กลาง | 1 วัน |
| J6 | Backend: Daily Claim (manual) | `02_BACKEND_SPEC.md` #6 | กลาง | 4-6 ชม. |
| J7 | Backend: Rewarded Ads verification | `02_BACKEND_SPEC.md` #7 | กลาง | 1 วัน |
| J8 | Backend: Push Notification triggers | `02_BACKEND_SPEC.md` #8 | กลาง | 1 วัน |
| J9 | Backend: Referral two-way | `02_BACKEND_SPEC.md` #9 | ง่าย | 4-6 ชม. |
| J10 | Backend: Winback Sub offer | `02_BACKEND_SPEC.md` #10 | กลาง | 4-6 ชม. |
| J11 | Frontend: Quest Bar UI | `03_FRONTEND_SPEC.md` #1 | ยาก | 3-5 วัน |
| J12 | Frontend: Daily Claim + Confetti | `03_FRONTEND_SPEC.md` #2 | กลาง | 1-2 วัน |
| J13 | Frontend: Tier Up Overlay | `03_FRONTEND_SPEC.md` #3 | กลาง | 1 วัน |
| J14 | Frontend: Rewarded Ads (AdMob) | `03_FRONTEND_SPEC.md` #4 | กลาง | 1-2 วัน |
| J15 | Frontend: Offer Snackbar (ปัดซ้าย) | `03_FRONTEND_SPEC.md` #5 | กลาง | 1 วัน |
| J16 | Frontend: Milestone Progressive UI | `03_FRONTEND_SPEC.md` #6 | กลาง | 1 วัน |
| J17 | Frontend: Subscription plans UI | `03_FRONTEND_SPEC.md` #7 | กลาง | 1 วัน |
| J18 | Frontend: Push Notification handling | `03_FRONTEND_SPEC.md` #8 | ง่าย | 4-6 ชม. |
| J19 | Admin: Analytics features | `04_ADMIN_PANEL_SPEC.md` | กลาง | 3-5 วัน |
| J20 | Admin: Campaign features | `04_ADMIN_PANEL_SPEC.md` | กลาง | 3-5 วัน |

---

## Dependencies (ลำดับงาน)

```
Phase 0 — Owner Setup (ทำก่อนทุกอย่าง)
├── O1: สร้าง IAP Products
├── O2: สร้าง AdMob Ad Units
└── O3: ตั้งค่า FCM

Phase 1 — Bug Fix + Config (Sprint 1, สัปดาห์ที่ 1)
├── J1: แก้ Bug Offer ซื้อซ้ำ  ← 🔴 Critical, ทำก่อน
├── J2: ปรับค่า Config (Challenge 3E, Tier 5/10/15/25)
└── J3: ลบ Random Bonus, First Empty, Double Quest

Phase 2 — Core Backend (Sprint 2, สัปดาห์ที่ 2)
├── J4: Milestone system ใหม่
├── J5: $1 = 200E Offer flow  ← ต้องรอ O1 (IAP)
├── J6: Daily Claim (manual)
└── J9: Referral two-way

Phase 3 — Ads + Push (Sprint 3, สัปดาห์ที่ 3)
├── J7: Rewarded Ads backend  ← ต้องรอ O2 (AdMob)
├── J8: Push Notification  ← ต้องรอ O3 (FCM)
└── J10: Winback Sub

Phase 4 — Frontend (Sprint 3-5, สัปดาห์ที่ 3-5)
├── J11: Quest Bar UI  ← ต้องรอ J4, J6
├── J12: Daily Claim + Confetti  ← ต้องรอ J6
├── J13: Tier Up Overlay  ← ต้องรอ J11
├── J14: Rewarded Ads UI  ← ต้องรอ J7
├── J15: Offer Snackbar  ← ต้องรอ J11
├── J16: Milestone UI  ← ต้องรอ J4
├── J17: Subscription plans  ← ต้องรอ O1
└── J18: Push handling  ← ต้องรอ J8

Phase 5 — Admin Panel (Sprint 5-6, สัปดาห์ที่ 5-6)
├── J19: Analytics
└── J20: Campaign

Phase 6 — QA & Launch
├── S4: Integration test
├── O4: Review screenshots
└── Deploy
```

### Timeline โดยประมาณ
| Phase | สัปดาห์ | สรุป |
|-------|---------|------|
| 0 | Owner ทำล่วงหน้า | IAP + AdMob + FCM setup |
| 1 | สัปดาห์ 1 | Bug fix + Config adjustments |
| 2 | สัปดาห์ 2 | Core backend (Milestone, Offer, Claim) |
| 3 | สัปดาห์ 3 | Ads + Push + Winback |
| 4 | สัปดาห์ 3-5 | Frontend UI (Quest Bar + ทั้งหมด) |
| 5 | สัปดาห์ 5-6 | Admin Panel |
| 6 | สัปดาห์ 7 | QA + Launch |

> **รวม: ~7 สัปดาห์** (1 Junior full-time) หรือ **~4 สัปดาห์** (2 Juniors parallel backend+frontend)
