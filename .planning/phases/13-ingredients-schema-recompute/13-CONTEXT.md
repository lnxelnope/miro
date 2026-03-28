# Phase 13: Ingredients schema & recompute - Context

**Gathered:** 2026-03-29  
**Status:** Ready for planning

<domain>
## Phase Boundary

ส่งมอบ **สัญญาข้อมูลเดียว** สำหรับ `FoodEntry.ingredientsJson` ที่รองรับ **main ingredients + sub-ingredients สูงสุด 2 ระดับ**, **อ่านรูปแบบเก่าได้โดยไม่ crash**, ตัวช่วย **flatten** โครงสร้างจาก AI ที่ซ้อนเกิน 2 ระดับ, และ **ฟังก์ชัน recompute** ที่คำนวณค่ารวมจาก sub → main → **คอลัมโภชนาการระดับ entry** เมื่อมี sub

**ไม่อยู่ในเฟสนี้:** การล็อก UI ของ main / การแก้ AddFood sheet / การแก้ Gemini prompt (เป็น Phase 16); การแสดงผล sandbox / กลุ่มมื้อ (Phase 15)

</domain>

<decisions>
## Implementation Decisions

### ความลึกและแหล่งความจริง (จาก arcal2-01 — ล็อกแล้ว)

- **D-01:** เก็บใน storage/UI ได้ **สูงสุด 2 ระดับ**: `mainIngredients[]` → แต่ละอันมี `subIngredients[]` (อาจว่าง)
- **D-02:** รายการที่ **ไม่มี sub** ไม่บังคับโครงสร้าง — ค่า macro/micro บนคอลัมน์ `FoodEntry` เป็นของจริงได้เหมือนเดิม
- **D-03:** เมื่อ **มี sub อย่างน้อยหนึ่งรายการใต้ main หรือใต้ entry (ตามสัญญา v2)** ค่า **calories / protein / carbs / fat** ระดับ entry ต้อง **derive จาก recompute** ไม่ใช่แก้สลับกับ sub อิสระ
- **D-04:** การ **เปลี่ยนปริมาณรวมแล้วสเกล sub ตามสัดส่วน** เป็นกฎผลิตภัณฑ์ — โค้ด recompute/schema ในเฟสนี้ต้องรองรับการถือ **base ต่อหน่วย** หรือข้อมูลเทียบเท่า เพื่อให้ Phase 16 ต่อยอดได้ (ไม่ต้องทำ UI ในเฟสนี้)

### Backwards compatibility

- **D-05:** **ไม่บังคับ migration ครั้งเดียวทั้งฐาน** — อ่าน legacy ได้; บันทึกครั้งถัดไปเขียนรูปแบบใหม่เมื่อ entry ถูกแก้/บันทึกผ่าน path ที่อัปเดตแล้ว
- **D-06:** **ตรวจจับรูปแบบ:** ถ้า `jsonDecode` ได้เป็น `List` → ถือเป็น **legacy** (รายการระดับบนสุดแบบปัจจุบัน); ถ้าเป็น `Map` และ `schemaVersion == 2` → **v2** (รายละเอียดโครงสร้างดู **D-10**)

### JSON v2 on wire (ล็อกตามที่ผู้ใช้ยอมรับคำแนะนำ)

- **D-10:** Root ของ `ingredientsJson` รูปแบบใหม่เป็น **object เดียว** ไม่ใช่ array โดยตรง:
  - `schemaVersion`: **2** (int)
  - `mainIngredients`: **List** ของแต่ละ main; แต่ละ main มี `subIngredients` (List อาจว่าง) และฟิลด์โภชนาการ/ปริมาณต่อโหนดเป็นภาษาอังกฤษตาม D-09
  - ไม่ใช้ชื่อคีย์ `version` แทน `schemaVersion` เพื่อความชัดเจนกับแพ็กเกจอื่น

### AI flatten

- **D-07:** ผลจาก AI ที่มี `sub_ingredients` ซ้อนลึก: **ยุบให้เหลือ 2 ระดับ** โดยไม่ double-count แคลอรี่ — รายละเอียดการกระจายโหนดลึกเป็นดุลยภาพ implementation

### Micro nutrients (fiber / sugar / sodium)

- **D-08:** Recompute ระดับ entry: **macro บังคับ** จากผลรวมที่ derive ได้
- **D-08b (ผู้ใช้ยืนยัน):** ถ้าโหนด sub/main **ไม่มีข้อมูล micro** ให้รวมเป็น entry ไม่ได้ — **คงค่า `fiber` / `sugar` / `sodium` เดิมบน `FoodEntry`** (ไม่เซ็ต null เพื่อ “ล้าง” โดยอัตโนมัติ); เมื่อมีค่า micro จาก subs ครบให้ใช้ผลรวมตามปกติ

### การทดสอบ (ตาม ROADMAP เฟส 13 — ผู้ใช้ยืนยัน)

- **D-11:**
  1. Legacy `ingredientsJson` ยังโหลดได้โดยไม่ crash; มีวิธีตรวจ (เทสต์หรือ checklist) อย่างน้อย **หนึ่งเส้นทาง** read → save ที่คาดหวังรูปแบบใหม่เมื่อผ่าน encoder ที่อัปเดต
  2. **Recompute** sub → main → entry: มี unit test, integration test หรือ **manual checklist** อย่างใดอย่างหนึ่งที่ยืนยันตัวเลข macro
  3. **Flatten** จากผล AI ลึกกว่า 2 ระดับ: มีการทดสอบอย่างน้อย **1 เคส** (ตรงกับ success criteria ใน `.planning/ROADMAP.md` เฟส 13)

### ชื่อคีย์และภาษา

- **D-09:** คีย์ใน JSON ใหม่ใช้ **ภาษาอังกฤษ** สอดคล้อง `.cursorrules` / `UnitConverter` — ไม่ใช้คีย์หน่วยไทยในโครงสร้างใหม่

### Claude's Discretion

- ตำแหน่งไฟล์โมเดล/parse (`lib/core/...`) และชื่อคลาส Dart
- รายชื่อฟิลด์ต่อโหนดใน `mainIngredients` / `subIngredients` (นอกจากโครงสร้างหลักใน D-10) — ให้สอดคล้องฟิลด์ที่มีใน legacy map วันนี้ + สิ่งที่ต้องใช้ recompute
- การแยก `IngredientsCodec` / immutable models — ตามแนวทางที่อ่านง่ายใน codebase

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Product / upgrade spec

- `_project_manager/arcal_2_00/arcal2-00.md` — sub vs Create Meal; AI ingestion; การตัดสินใจ flatten / lock main (บริบท)
- `_project_manager/arcal_2_00/arcal2-01.md` — §2.2 ลำดับชั้นข้อมูล, §4 การตัดสินใจ 14 ข้อ, §5 dependency (T1), §6 ไฟล์ที่แตะ `app_database` / `database_service`
- `.planning/research/ARC2-00-POINTERS.md` — pointer ไปยังเอกสารด้านบน

### Requirements

- `.planning/REQUIREMENTS.md` — **ARC2-DATA-01**, **ARC2-DATA-02**, **ARC2-DATA-03**

### Engineering rules

- `.cursorrules` — food/nutrition pattern (base per unit, `UnitConverter`, L10n สำหรับ UI ที่แตะในเฟสหลัง)

### Schema / integration (โค้ด)

- `lib/core/database/app_database.dart` — ตาราง `FoodEntries`, คอลัมน์ `ingredientsJson`, `originalIngredientsJson`, macro + fiber/sugar/sodium
- `lib/core/database/database_service.dart` — insert/update entry
- `lib/features/health/widgets/add_food_bottom_sheet.dart` — `_EditableIngredient`, `toMap`, การ `jsonEncode` รายการ ingredients
- `lib/features/health/widgets/edit_food_bottom_sheet.dart` — parse/load `ingredientsJson`
- `lib/features/health/widgets/food_detail_bottom_sheet.dart`, `lib/features/home/widgets/simple_food_detail_sheet.dart`, `lib/features/health/widgets/meal_section.dart` — จุด `jsonDecode` เป็น `List` (ต้องรองรับ v2 ในเฟสถัดไปหรือผ่านเลเยอร์ parse กลาง)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets

- **`_EditableIngredient` ใน `add_food_bottom_sheet.dart`:** มี `subIngredients`, `baseCalories`/`baseProtein`/… และ `recalculate()` แบบสเกล sub เมื่อเปลี่ยน parent amount — เป็นแนวทาง behavior ที่สเปกต้องการต่อเนื่องใน Phase 16 แต่ Phase 13 ควรถอด **โมเดลข้อมูล + recompute กลาง** ออกมาให้ไม่ผูกกับ widget
- **`ingredientTreeToJsonMaps` (อ้างอิงใน `log_from_meal_sheet.dart`):** อาจมี pattern ต้นไม้จาก My Meal — ตรวจซ้ำตอน plan เพื่อหลีกเลี่ยงสัญญาซ้ำซ้อน

### Established Patterns

- **Legacy `ingredientsJson`:** สตริง JSON ที่ decode เป็น **`List`** ของ map — หลายไฟล์สมมติรูปแบบนี้
- **Drift `FoodEntryData`:** คอลัมโภชนาการระดับ entry เป็นตัวเลขจริง; การ recompute ควรอัปเดต companion/update ผ่านชั้นที่มีอยู่

### Integration Points

- ทุก path ที่ **บันทึก** `ingredientsJson` (add/edit/log meal/intent) จะต้องเรียก **encode v2** หลัง Phase 13–16 ครบ — ใน Phase 13 วาง **API กลาง** (`parse` / `serialize` / `recomputeEntryTotals`) แล้วค่อยไล่ต่อไฟล์ใน Phase 16
- **Gemini / flatten:** เรียกจากเลเยอร์กลางได้หลังมีฟังก์ชัน flatten ในเฟสนี้

</code_context>

<specifics>
## Specific Ideas

- สเปกผู้ใช้: **แต่ละ root จาก AI = main ingredient** ใต้ชื่อจาน; การ flatten ต้องไม่ทำให้ผลรวมแคลอรี่เกินจริง (สอดคล้อง arcal2-00 เรื่อง double-count)

</specifics>

<deferred>
## Deferred Ideas

- ล็อกช่อง main ใน UI และการแก้ prompt Gemini — **Phase 16**
- Thumbnail / Group merge — **Phase 17**

### Reviewed Todos (not folded)

- ไม่มีรายการจาก `todo match-phase 13`

</deferred>

---

*Phase: 13-ingredients-schema-recompute*  
*Context gathered: 2026-03-29 — อัปเดต: ผู้ใช้ยืนยัน D-10 (รูปแบบ v2), D-08b (คง micro เดิม), D-11 (ทดสอบตาม ROADMAP)*
