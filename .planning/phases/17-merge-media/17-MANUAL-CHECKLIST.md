# Phase 17 — Manual UAT checklist

อ้างอิง `17-CONTEXT` D-18 และ ROADMAP success criteria

## 1. Group merge (ARC2-GR-01 / แผน 01)

- [ ] เลือก ≥2 รายการในซานด์บ็อกซ์ → ปุ่ม Group ปรากฏ (หลัง Phase 15)
- [ ] เลือกรายการที่มี merged group (`isGroupOriginal` ฯลฯ) → Group **ถูก disable** + ข้อความอธิบาย
- [ ] Merge → dialog ยืนยัน → entry ใหม่ชื่อ `group_<suffix>` โภชนาการ = ผลรวม
- [ ] `ingredientsJson` เป็น v2 และแต่ละ entry ต้นทางสะท้อนเป็น main ตามสเปก
- [ ] รายการเดิมหายจากวันนั้น; timeline / แคลวันนี้อัปเดตถูกต้อง

## 2. Ingredient thumb (ARC2-THUMB-01 / แผน 02)

- [ ] แถวที่ **ไม่มี** รูป — **ไม่มี** กล่อง placeholder สีเทา
- [ ] แถวที่มี path — แสดง micro thumb; แตะ → เต็มจอ; มี bbox → overlay ถูกต้อง
- [ ] Add / Edit / Gemini (และ Create Meal ถ้ามีแถว) — ไม่ crash กับ JSON เก่า

## 3. Create Meal gallery (ARC2-MEAL-01 / แผน 03)

- [ ] แถว sub มีปุ่มแกลเลอรี/กล้อง ข้าง search
- [ ] เลือกรูป → pipeline เดียวกับวิเคราะห์รูปมาตรฐาน → ยืนยันผล → map เข้าแถว + path บนโหนด
- [ ] `_lookupSubIngredient` ยังทำงานเหมือนเดิมสำหรับเคสเดิม

## Sign-off

- [ ] รัน `flutter analyze` ตาม `17-VALIDATION.md`
- [ ] วันที่ / ผู้ทดสอบ: _______________
