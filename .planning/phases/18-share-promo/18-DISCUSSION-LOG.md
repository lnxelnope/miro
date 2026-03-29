# Phase 18: Share & promo — Discussion Log

> **Audit trail only.** การตัดสินใจหลักอยู่ใน `18-CONTEXT.md`

**Date:** 2026-03-29  
**Phase:** 18 — Share & promo  
**Mode:** ต่อจาก `/gsd-discuss-phase 18` — ผู้ใช้ตอบพื้นที่สีเทา 4 ข้อ

---

## Gray areas → User answers

| # | หัวข้อ | คำตอบผู้ใช้ |
|---|--------|------------|
| 1 | Preset 16:9 / 1:1 ใช้กับการ์ดใดบ้าง | **ทุกที่** — ทุกประเภทการ์ด (food item, daily summary, nutrition period) ใช้ preset เดียวกัน |
| 2 | Toggle แสดงปริมาณบนภาพ | **เฉพาะ food card** — ปริมาณของ **รายการอาหารนั้น** (ระดับ entry); ไม่ใช้ toggle นี้บน daily / nutrition summary |
| 3 | หลัง redeem สำเร็จ | **SnackBar สั้นๆ** |
| 4 | Promo / admin | **ต่อยอด** — admin-panel + backend เดิม (ไม่เริ่ม stack ใหม่) |

---

## Summary

- Share: `ShareCardCreatorScreen` / `ShareCardConfig` ต้องรองรับ **aspect** สำหรับทุก `ShareCardType`; **`showServingOnImage`** (หรือชื่อเทียบเท่า) มีผลเฉพาะเมื่อ `type == foodItem`
- Promo: UX สำเร็จ = SnackBar; implementation = ขยาย repo backend + admin ที่มี

---

*End of discussion log*
