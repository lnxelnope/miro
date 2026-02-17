# 🗂️ Nested Ingredients Implementation Guide

> **โฟลเดอร์นี้:** คู่มือสำหรับพัฒนา Nested Ingredients Feature  
> **แผนหลัก:** `_project_manager/NESTED_INGREDIENTS_PLAN.md`

---

## 📁 โครงสร้างไฟล์

```
nested_ingredients/
├── README.md                          # ไฟล์นี้
│
├── JUNIOR_TASK_1_data_models.md      # [JUNIOR] เพิ่ม fields ใน models
├── JUNIOR_TASK_2_build_runner.md     # [JUNIOR] รัน build_runner
├── JUNIOR_TASK_3_ui_ingredient_card.md # [JUNIOR] แก้ UI widget
│
├── SENIOR_TASK_1_ai_prompts.md       # [SENIOR] แก้ AI prompts ทั้ง 3 จุด
├── SENIOR_TASK_2_provider_logic.md   # [SENIOR] Recursive save logic
└── SENIOR_TASK_3_ui_expandable.md    # [SENIOR] Expandable tree UI
```

---

## 🎯 วิธีใช้งาน

### สำหรับ Junior Developer
1. เริ่มจาก `JUNIOR_TASK_1_data_models.md`
2. ทำตามขั้นตอนทีละข้อ ไม่ต้องคิดอะไรเพิ่ม
3. ถ้าติดปัญหาให้ copy error มาถามพี่
4. **ห้าม** เปิดไฟล์ `SENIOR_TASK_*.md` (ยากเกินไป)

### สำหรับ Senior Developer
1. อ่าน `NESTED_INGREDIENTS_PLAN.md` ทั้งหมดก่อน
2. เลือก SENIOR_TASK ที่รับได้
3. ใช้ judgment ของตัวเองในการแก้ปัญหา
4. ตรวจสอบว่า Junior Tasks เสร็จหรือยัง (dependency)

---

## 📊 Task Dependencies

```
JUNIOR_TASK_1 (models) ──> JUNIOR_TASK_2 (build_runner)
                                    │
                                    ▼
SENIOR_TASK_1 (AI prompts)  SENIOR_TASK_2 (providers)
                                    │
                                    ▼
                            JUNIOR_TASK_3 (ingredient_card)
                                    │
                                    ▼
                            SENIOR_TASK_3 (expandable UI)
```

---

## ✅ Progress Tracking

- [ ] JUNIOR_TASK_1 — Data Models
- [ ] JUNIOR_TASK_2 — Build Runner
- [x] SENIOR_TASK_1 — AI Prompts
- [x] SENIOR_TASK_2 — Provider Logic
- [x] JUNIOR_TASK_3 — Ingredient Card Widget
- [x] SENIOR_TASK_3 — Expandable Tree UI

---

## 🆘 เมื่อติดปัญหา

### Junior
- อ่านขั้นตอนใหม่อีกครั้ง (อ่านช้าๆ)
- ตรวจสอบว่าทำครบทุกขั้นตอนหรือยัง
- Copy error message ทั้งหมดมาถามพี่
- **อย่า** พยายาม fix เอง ถ้าไม่เข้าใจ

### Senior
- ตรวจสอบ backward compatibility
- ดู test cases ใน NESTED_INGREDIENTS_PLAN.md
- พิจารณา edge cases (flat ingredients, null handling)
- Review code ของ junior ก่อน merge

---

## 🧪 Testing (สำหรับ Senior)

หลังทำเสร็จแต่ละ phase:

1. **Unit Tests**: ทดสอบ model, provider logic
2. **Integration Tests**: ทดสอบ AI → provider → DB
3. **Manual Tests**: ทดสอบ UI จริงๆ บนมือถือ
4. **Backward Compat**: ทดสอบกับ data เก่า

---

## 📞 Contact

ถ้าติดปัญหาหนักๆ:
- Tag senior ใน Slack
- ยก error log + screenshot มาด้วย
- บอกว่าทำอะไรไปบ้างแล้ว

---

**หมายเหตุ:** ถ้า task ไหนดูยากเกินไป แจ้ง senior ให้รู้ทันที อย่าพยายามทำคนเดียว!
