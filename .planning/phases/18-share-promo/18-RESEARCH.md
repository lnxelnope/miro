# Phase 18 — Technical research: Share & promo

**Phase:** 18 — share-promo  
**Date:** 2026-03-29  

## RESEARCH COMPLETE

---

## 1. Share (ARC2-SHARE-01)

- **`ShareCardConfig`** (`lib/features/sharing/models/share_card_config.dart`): toggles โภชนาการ — **ยังไม่มี** aspect / `showServingOnImage`
- **`CardCaptureService`**: `captureCard(GlobalKey, pixelRatio)` — ขนาดผลลัพธ์ตาม `RenderRepaintBoundary` ของการ์ด (~360×450 logical ใน widget ปัจจุบัน)
- **`ShareCardCreatorScreen`**: ประกอบการ์ด 3 ประเภท + share/gallery
- **การตัดสินใจ CONTEXT:** 16:9 + 1:1 **ทุกประเภทการ์ด**; toggle ปริมาณบนภาพ **เฉพาะ `ShareCardType.foodItem`** — อ่าน `servingSize` / `servingUnit` จาก `FoodEntry` + `UnitConverter` / L10n

## 2. Promo — App

- **Settings:** `ProfileScreen` (`lib/features/profile/presentation/profile_screen.dart`) — โครงการ์ดย่อยหลายส่วน; เพิ่มส่วน **Promo code** แบบย่อ (ช่องกรอก + ปุ่ม redeem)
- **เรียก backend:** แพทเทิร์นหลัก = `http.post` → `https://us-central1-miro-d6856.cloudfunctions.net/<endpoint>` + `deviceId` (ดู `EnergyService`, `RecoveryKeyService`); redeem ต้องออกแบบให้สอดคล้องการระบุตัวผู้ใช้ที่ Functions ใช้อยู่

## 3. Promo — Backend & Admin

- **Functions:** `functions/src/index.ts` — export แบบแยกโมดูล; เพิ่ม endpoint redeem + logic อัปเดต energy/freepass ตาม `reward_type`
- **Admin:** `admin-panel/src/app/(dashboard)/offers/` + `OfferForm.tsx` — **ต้นแบบ CRUD** สำหรับหน้า promo codes ใหม่ (แยกจาก Offers ตาม arcal2-01)

## 4. Dependencies

- ROADMAP: Phase 18 **ไม่บังคับ** blocker จากเฟสอื่น; แนะนำให้ข้อความปริมาณบน food card สอดคล้องฟิลด์ entry หลัง Phase 13–16

---

## Validation Architecture

1. `flutter analyze` บนไฟล์ sharing + profile ที่แตะ
2. Deploy / emulator ทดสอบ Function redeem (ถ้ามี)
3. Manual `18-MANUAL-CHECKLIST.md`
4. Admin: smoke สร้างโค้ด → redeem จากแอป

---

*End of research*
