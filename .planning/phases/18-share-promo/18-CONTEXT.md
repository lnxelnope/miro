# Phase 18: Share & promo — Context

**Gathered:** 2026-03-29  
**Status:** Ready for planning

<domain>
## Phase Boundary

ส่งมอบตาม ROADMAP / REQ:

1. **ARC2-SHARE-01:** Share card รองรับ preset อัตราส่วน **16:9** และ **1:1** และมี **toggle** ใส่ปริมาณ/ปริมาณเสิร์ฟบนภาพที่ capture — **ขอบเขต toggle ตามการตัดสินใจด้านล่าง (เฉพาะ food card)**
2. **ARC2-PROMO-01:** ผู้ใช้กรอก **promo code** ใน **Settings**; redeem สำเร็จได้รางวัลตามที่ backend กำหนด (เช่น energy, free pass)
3. **ARC2-PROMO-02:** **Admin** จัดการ CRUD โค้ด — **จำกัดครั้งรวม**, **จำกัดต่อผู้ใช้**, **วันหมดอายุ**

**Depends on:** ROADMAP ระบุว่า **ไม่บังคับ** dependency จากเฟสอื่น — ทำคู่ขนานบางส่วนได้; แนะนำให้แชร์การ์ดอ่านฟิลด์ `FoodEntry` / serving สอดคล้องกับ Phase 13–16 เมื่อมีแล้ว

**ไม่อยู่ในเฟสนี้:** referral program, QR การตลาดใหม่นอก REQ, แยก admin stack ใหม่

</domain>

<decisions>
## Implementation Decisions

### Share card (ARC2-SHARE-01)

- **D-01:** Preset **16:9** และ **1:1** ใช้ได้กับ **ทุกประเภทการ์ด** — `ShareCardType.foodItem`, `dailySummary`, `nutritionSummary` ใช้ชุด preset เดียวกันใน UI สร้างการ์ด / ก่อน capture
- **D-02:** **Toggle แสดงปริมาณบนภาพ** (`showServingOnImage` หรือชื่อเทียบเท่า) มีเฉพาะเมื่อ **`ShareCardType == foodItem`** — แสดงปริมาณของ **รายการอาหารนั้น** ระดับ **entry** (เช่น `servingSize` + `servingUnit` / ข้อความที่สอดคล้อง `UnitConverter` + L10n) — **ไม่** ใส่ toggle นี้บน daily summary หรือ nutrition period card
- **D-03:** การ์ดประเภท **daily / nutrition** — **ไม่** ต้องมี toggle ปริมาณรายการอาหารเดี่ยวตาม REQ ข้อนี้; คง toggles ที่มีอยู่แล้ว (`showCalories`, `showMacros`, …) ตามเดิม
- **D-04:** **`CardCaptureService` / `RepaintBoundary`:** ต้อง capture จาก widget ที่ถูกห่อด้วย **ขนาดตาม aspect ที่เลือก** (รายละเอียด pixel ratio / export size เป็น Claude's discretion ให้คุณภาพชัดบนโซเชียล)
- **D-05:** ข้อความบนการ์ด — **L10n เท่านั้น**; ป้ายปริมาณตาม `.cursorrules`

### Promo — App (ARC2-PROMO-01)

- **D-06:** ตำแหน่งป้อนโค้ด: **Settings** (แบบ redeem เกมมือถือ — สอดคล้อง arcal2-01 §3.1)
- **D-07:** หลัง **redeem สำเร็จ** — แจ้งด้วย **SnackBar สั้นๆ** (L10n); **ไม่บังคับ** dialog เต็มหรือนำทางไป Energy Store ในเฟสนี้
- **D-08:** หลัง **ล้มเหลว** (โค้ดไม่ถูก / หมดอายุ / เกิน limit) — ข้อความชัดเจน (L10n); รายละเอียด status code จาก API map เป็นข้อความผู้ใช้

### Promo — Backend & Admin (ARC2-PROMO-02)

- **D-09:** **ต่อยอด** repository **backend** และ **admin-panel** ที่มีอยู่ — **ไม่** สร้าง admin stack ใหม่; โครง collection / API redeem / CRUD ผูกกับแพทเทิร์นโปรเจกต์เดิม
- **D-10:** ฟิลด์ตาม REQ: โค้ด, ประเภทรางวัล + payload, **max ครั้งรวม**, **per-user limit**, **expiry**; idempotent redeem และกันความซ้ำตามที่ backend ออกแบบ (รายละเอียด schema เป็น Claude's discretion ให้สอดคล้อง Offers ที่มีถ้า reuse ได้)

### การตรวจสอบ (ROADMAP)

- **D-11:** (1) Export 16:9 และ 1:1 จาก UI ได้ทุกประเภทการ์ด (2) Toggle ปริมาณทำงานเฉพาะ food card (3) Redeem สำเร็จ/ล้มเหลว ข้อความชัด (4) Admin สร้าง/แก้โค้ดจำกัดครั้ง+ต่อ user+หมดอายุได้

### Claude's Discretion

- ตำแหน่ง UI เลือก aspect ใน `ShareCardCreatorScreen` (segmented / chips)
- ถ้า entry ไม่มี serving ที่แสดงได้ — ซ่อน toggle ปริมาณหรือ disable พร้อมข้อความสั้น (L10n)
- Audit log / rate limit API — แนะนำถ้าต้นทุนต่ำ; ไม่บังคับใน CONTEXT ถ้าไม่กั้น MVP

</decisions>

<canonical_refs>
## Canonical References

### Product

- `_project_manager/arcal_2_00/arcal2-01.md` — §3.1 Promo, §3.3 Share card, T14/T15
- `_project_manager/arcal_2_00/arcal2-00.md` — บริบท promo / share

### Requirements

- `.planning/REQUIREMENTS.md` — **ARC2-SHARE-01**, **ARC2-PROMO-01**, **ARC2-PROMO-02**

### Roadmap

- `.planning/ROADMAP.md` — Phase 18

### Rules

- `.cursorrules` — L10n, ไม่ hardcode สตริง UI

### Code (จุดแตะหลัก)

- `lib/features/sharing/models/share_card_config.dart` — เพิ่ม aspect + flag ปริมาณ (เฉพาะ food)
- `lib/features/sharing/services/card_capture_service.dart` — capture ตามขนาด preset
- `lib/features/sharing/presentation/share_card_creator_screen.dart` — UI preset + toggle
- `lib/features/sharing/widgets/share_card_food_item.dart`, `share_card_daily_summary.dart`, `share_card_nutrition_summary.dart` — layout ตาม aspect
- Settings: หน้าตั้งค่าที่มีอยู่ — เพิ่มส่วน redeem (ค้นหา `settings` / `SettingsScreen`)
- `admin-panel` (repo แยก) + backend — CRUD promo, endpoint redeem

</canonical_refs>

<code_context>
## Existing Code Insights

### Share

- **`ShareCardConfig`:** มี toggles โภชนาการและรูปแบบเนื้อหา — **ยังไม่มี** `ShareCardAspect` / `showServingOnImage`
- **`CardCaptureService.captureCard`:** `RepaintBoundary.toImage` — ขนาดตาม widget ปัจจุบัน (~360×450 logical ในการ์ดเดิม); ต้องปรับให้สอดคล้อง D-01, D-04
- **การ์ดสามแบบ:** `ShareCardFoodItem`, `ShareCardDailySummary`, `ShareCardNutritionSummary` — ทุกแบบต้องอยู่ในกรอบ aspect เดียวกันตอน capture

### Promo

- arcal2-01: admin มี **Offers** แยกจาก promo code แบบ influencer — เฟสนี้เพิ่ม **promo code path** ต่อยอด backend/admin

### Deferred (นอกเฟส)

- Referral, deep link จากการ์ด, รางวัลประเภทใหม่นอกขอบเขต REQ

</code_context>
