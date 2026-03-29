# Phase 18 — Manual UAT checklist

อ้างอิง `18-CONTEXT` D-11 และ ROADMAP success criteria

## 1. Share (แผน 01 / ARC2-SHARE-01)

- [ ] เปิด Share creator จากจุดเดิมในแอป — ทุกประเภทการ์ดมีตัวเลือก **16:9** และ **1:1**
- [ ] Capture / share / บันทึกแกลเลอรี — ภาพได้สัดส่วนตามที่เลือก
- [ ] **Food item card:** มี toggle ปริมาณ; เปิดแล้วเห็นปริมาณรายการบนการ์ด; ปิดแล้วไม่เห็น
- [ ] **Daily / Nutrition:** **ไม่มี** toggle ปริมาณรายการอาหารเดี่ยว
- [ ] กรณีไม่มี serving — ตรงตามข้อตกลง (ซ่อน/disable + ข้อความ L10n)

## 2. Promo backend + admin (แผน 02 / ARC2-PROMO-02)

- [ ] Admin สร้างโค้ดใหม่ พร้อม max รวม, per-user, expiry
- [ ] แก้ไข/ปิดใช้โค้ดแล้ว redeem สะท้อนถูกต้อง

## 3. Settings redeem (แผน 03 / ARC2-PROMO-01)

- [ ] กรอกโค้ดถูก → **SnackBar สั้น** + ยอด energy หรือ freepass อัปเดตในแอป
- [ ] โค้ดผิด / หมดอายุ / เกิน limit / ใช้ครบแล้ว → ข้อความชัด (L10n)

## Sign-off

- [ ] `flutter analyze` + build functions/admin ตาม `18-VALIDATION.md`
- [ ] วันที่ / ผู้ทดสอบ: _______________
