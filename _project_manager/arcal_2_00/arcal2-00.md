# ARCAL2-00 — Research: Sub-ingredients ในโหมดเพิ่มอาหาร vs สร้างเมนู

**สถานะ:** ✅ ตัดสินใจครบทุกประเด็น — ผนวกเข้า [arcal2-01.md](./arcal2-01.md)  
**วันที่:** 2026-03-29  

---

## 1. สรุปความต้องการ (วิสัยทัศน์ที่คุยกัน)

- ใน **โหมดเพิ่มอาหาร** การแสดงผลและโลจิกของ **sub-ingredients** ควร **สอดคล้องกับหน้าสร้างเมนูใหม่** (`CreateMealSheet`).
- เมื่อมี sub-ingredients แล้ว **แคลอรี่และมาโครของ "แถวหลัก" (main / composite)** ต้อง **มาจากการรวมจาก sub** ไม่ใช่ช่องที่ผู้ใช้แก้เองแยกต่างหาก.
- **Main = แสดงผล + ล็อก** (ชื่อเมนู/จานรวม เช่น "ปลาซาบะย่างซอส" ปริมาณรวม เช่น 40 g) — ผู้ใช้ **ปรับโภชนาการที่แถวย่อย** (เช่น ปลาซาบะย่าง 30 g + ซอสเทริยากิ 10 g).
- ต้อง **เริ่มถูกต้องตั้งแต่จุดที่รับข้อมูลจาก AI** (เช่น วิเคราะห์ชื่อจาน) เพื่อไม่ให้ main ถือค่า total จากโมเดลคนละชุดกับผลรวมจริงจาก sub.

ตัวอย่างอ้างอิง: *ปลาซาบะย่างซีอิ๊ว* — โครงสร้างที่ต้องการคือ sub เป็นส่วนประกอบจริง (ปลา + ซอส) แล้ว main เป็นชื่อรวม + น้ำหนักรวมที่ **สอดคล้อง**กับผลรวม sub.

---

## 2. สถานะปัจจุบันในโค้ด (fact จาก codebase)

### 2.1 `CreateMealSheet` (`lib/features/health/widgets/create_meal_sheet.dart`)

- มีแฟล็ก `hasSubIngredients`: เมื่อมี sub ที่มีข้อมูลแล้ว  
  - **ปริมาณ / หน่วย ของ parent เป็น `readOnly`**  
  - **kcal, P, C, F ของ parent เป็น `readOnly`** (`hasBaseValues || hasSubs`)  
  - ปุ่มค้นด้วย AI บนแถมหลัก **ปิด** เมื่อมี sub  
- `_recalculateIngredientRow`: โภชนาการ parent = **`base*WithoutSubs` + ผลรวมจาก sub** (โมเดล "ฐานที่ไม่รวม sub" + additive)  
- มีการ aggregate ปริมาณ parent จาก sub เมื่อหน่วยเข้ากันได้ (`_aggregateCompatibleSubAmounts`).

→ นี่คือ **แนวทางอ้างอิง** ที่ผู้ใช้ต้องการให้ "เพิ่มอาหาร" ใกล้เคียง (โดยเฉพาะเรื่อง **ล็อก main** และ **แหล่งที่มาของตัวเลข**).

### 2.2 `AddFoodBottomSheet` (`lib/features/health/widgets/add_food_bottom_sheet.dart`)

- มี `_EditableIngredient` พร้อม `subIngredients` และ `_recalculateParentFromSubs` (parent โภชนาการ = **ผลรวมจาก sub เท่านั้น** ไม่มีชั้น `baseWithoutSubs` แบบ create meal).
- **ช่องปริมาณ / หน่วยของแถวหลักยังแก้ได้** แม้มี sub — และ `recalculate()` บน parent จะ **สเกลปริมาณ sub ตามอัตราส่วน** เมื่อเปลี่ยน parent amount (`baseAmount` เดิม). พฤติกรรมนี้ **ต่างจาก** create meal ที่ล็อก parent เมื่อมี sub.
- หลัง `_lookupIngredient` (AI `analyzeFoodByName`):  
  - ตั้ง `row.calories` / macro จาก **`result.nutrition` (ยอดรวมจาก AI)**  
  - สร้าง `row.subIngredients` จาก **`result.ingredientsDetail`** (รายการ root ใน JSON)  
  - เรียกแค่ `_recalculateFromIngredients()` — **ไม่เรียก `_recalculateParentFromSubs`**  
- ผลที่เป็นไปได้: **ตัวเลขบน main กับผลรวม sub อาจไม่สอดคล้อง** จนกว่าผู้ใช้จะไปกระตุ้น path ที่เรียก `_recalculateParentFromSubs` (เช่น แก้ sub / lookup sub).

### 2.3 Prompt / โมเดลข้อมูล AI (`GeminiService`)

- กฎใน prompt ระบุว่า `ingredients_detail` ระดับ **root** คือสิ่งที่ใช้นับรวมกับ `nutrition.calories` และ `sub_ingredients` เป็นรายละเอียดภายใต้ root (เคยบอกว่า "informational" แต่ให้ผลรวม sub ≈ parent root).
- โครงสร้าง JSON รองรับ **ซ้อน `sub_ingredients` แบบ recursive** ใน `IngredientDetail` แต่ใน Add Food ตอน map เข้า `_EditableIngredient` **ใช้แค่ระดับบนสุดของ `ingredients_detail`** — **ไม่ได้ผูก nested `sub_ingredients` จาก AI** ลง sub ของแอปในแถวเดียวกัน (ถ้ามี).

### 2.4 จุดอื่นที่เกี่ยวข้อง (สั้นๆ)

- `GeminiAnalysisSheet` / `EditFoodBottomSheet` มี pattern โหลด sub จากผล AI คล้ายกัน — การอัปเกรดใหญ่ควรคิดเป็น **ชุดเดียวกัน** (แหล่งจริงของความจริง = sub หรือ root ตามสัญญาใหม่).

---

## 3. ช่องว่างเชิงผลิตภัณฑ์ (gap ระหว่าง "ที่ต้องการ" กับ "ที่ทำอยู่")

| หัวข้อ | ที่ต้องการ (จากบทสนทนา) | Add Food ปัจจุบัน |
|--------|-------------------------|-------------------|
| Main เมื่อมี sub | ล็อก + แสดงผล derived | ยังแก้ amount/unit ได้; โภชนาการไม่บังคับ derived ทันทีหลัง AI |
| แหล่ง kcal หลัก | จากผลรวม sub | หลัง AI ใช้ `nutrition` จากโมเดลโดยตรงบนแถวหลัก |
| ความสอดคล้องกับ Create Meal | เหมือนกันในแง่ UX/ล็อก | พฤติกรรมต่าง (ล็อก, scaling, baseWithoutSubs) |
| ข้อมูลจาก AI | โครงสร้าง atomic ชัด (ปลา 30 + ซอส 10 → main 40) | ขึ้นกับว่า AI คืนกี่ root; mapping ไป "sub ใต้แถวเดียว" อาจไม่ตรง mental model "main = composite" |

---

## 4. ประเด็นที่ตัดสินใจแล้ว (ตอบเรียบร้อย)

1. **นิยาม "main" ใน FoodEntry**  
   → **ไม่บังคับ** ว่าทุก entry ต้องมีโครงสร้าง main/sub — ถ้าไม่มี sub ก็เก็บ nutrition ตรงบน entry เหมือนเดิม; เมื่อมี sub → main ล็อกแสดงผล, nutrition derive จาก sub

2. **AI คืนหลาย root ใน `ingredients_detail`**  
   → **แต่ละ root จาก AI = main ingredient ใต้ชื่อจาน** (sub ของ root อีกชั้นหนึ่งถ้า AI ส่งมา)

3. **Nested `sub_ingredients` จาก JSON**  
   → **แบนให้เหลือ 2 ระดับเสมอ** (main + sub) ใน UI/DB — ถ้า AI คืนลึกกว่า ยุบให้เหลือ 2 ชั้น; lock main แก้ที่ sub; main คำนวณจาก sub

4. **การสเกลปริมาณ**  
   → **แก้ปริมาณรวมได้** → sub สเกลตามสัดส่วนเดิมอัตโนมัติ

5. **Prompt / post-process**  
   → ต้องปรับให้ sum(root) ≈ total; ไม่ double-count; สอดคล้องกับการ flatten ข้อ 3

6. **ขอบเขตไฟล์**  
   → อย่างน้อย: `add_food_bottom_sheet.dart`, `edit_food_bottom_sheet.dart`, `gemini_analysis_sheet.dart`, `intent_handler.dart`, `FoodEntry` serialization, `GeminiService` prompt

---

## 5. แนวทางที่ยืนยันแล้ว

- **Single source of truth:** เมื่อมี sub → nutrition ของ main คำนวณจาก sub เสมอ; อัปเดตทันทีหลังรับผล AI + ทุกครั้งที่ sub เปลี่ยน
- **UI สอดคล้อง Create Meal:** ล็อก nutrition/หน่วยของ main เมื่อมี sub; **แก้ปริมาณรวมได้ → sub สเกลตามสัดส่วน**
- **ไม่บังคับ sub:** รายการธรรมดา (กล้วย 1 ลูก) เก็บแบบเดิมได้โดยไม่ต้องสร้าง sub
- **2 ระดับเท่านั้น:** main + sub (ห้าม sub-sub ใน UI/DB)
- **AI root = main ingredient:** แต่ละ root ใน `ingredients_detail` → main ingredient ใต้ชื่อจาน
- **แยก "ชื่อจานที่ผู้ใช้พิมพ์" กับ "รายการย่อยจาก AI"** ในแบบเดียวกับ arcal2-01 ข้อ 2.2

---

## 6. อ้างอิงไฟล์หลัก

- `lib/features/health/widgets/create_meal_sheet.dart` — ล็อก main, `_recalculateIngredientRow`
- `lib/features/health/widgets/add_food_bottom_sheet.dart` — `_lookupIngredient`, `_recalculateParentFromSubs`, UI แถวหลัก
- `lib/core/ai/gemini_service.dart` — กฎ `ingredients_detail` / `sub_ingredients`, `IngredientDetail`, `enforceUserIngredientAmounts`

---

**→ ดูแผนอัปเกรดใหญ่ฉบับเต็ม:** [arcal2-01.md](./arcal2-01.md)

*เอกสารนี้ปิดประเด็นเปิดทั้งหมดแล้ว — ข้อมูลถูกผนวกเข้า arcal2-01 เพื่อใช้เป็น task breakdown*
