# Phase 16: Ingredient UI & AI - Context

**Gathered:** 2026-03-29  
**Status:** Ready for planning

<domain>
## Phase Boundary

ส่งมอบ **กฎเดียวกันทุกจุด** สำหรับการแก้ไข/บันทึก ingredients ตาม arcal2-00/01 และ REQ **ARC2-ING-01 … ARC2-ING-04**, **ARC2-AI-01**:

1. เมื่อมี **sub-ingredients** ใต้ main → แถว main **composite** โภชนาการ **read-only** และ **derive จาก sub**
2. ผู้ใช้แก้ **ปริมาณรวม** ของแถว composite → **สเกล sub ตามสัดส่วน** (สอดคล้อง base ต่อหน่วย / `.cursorrules`)
3. ผลจาก AI: **root ใน `ingredients_detail` → main**; ชั้นลึก → **sub** (สูงสุดหนึ่งชั้นใต้ main ใน storage); ลึกกว่านั้น → **flatten** ตาม Phase 13
4. **`AddFoodBottomSheet`**, **`EditFoodBottomSheet`**, **`GeminiAnalysisSheet`**, และ path ที่ REQ เรียก **IntentHandler** ใช้ **serialization + recompute เดียวกัน** กับเลเยอร์กลางจาก Phase 13
5. **Prompt / post-process Gemini** ให้ **ยอดรวม entry สอดคล้อง** ผลรวมจาก mains/subs หลัง flatten (ไม่ double-count)

**Depends on:** **Phase 13** — ต้องมี codec v2, `recomputeEntryTotals` (หรือชื่อเทียบเท่า), flatten ก่อนทำ UI/AI รอบนี้

**ไม่อยู่ในเฟสนี้:** Group merge / thumbnail / Create Meal gallery→analysis (**Phase 17**); กลุ่มมื้อแซนด์บ็อกซ์ (**Phase 15**); โครงสร้าง schema ล้วนๆ (**Phase 13**)

</domain>

<decisions>
## Implementation Decisions

### ล็อก main + derive (ARC2-ING-01)

- **D-01:** ถ้า **อย่างน้อยหนึ่ง main** มี `subIngredients` ไม่ว่าง → ฟิลด์ **kcal / P / C / F (และ micro ที่ derive ได้)** ของ **main นั้น** ใน UI เป็น **read-only** คำนวณจาก sub ผ่าน **recompute กลาง**; ผู้ใช้แก้ได้ที่ **ระดับ sub** และที่ **ปริมาณรวมของ main** (trigger สเกล sub — ดู D-03)
- **D-02:** Entry / main **ไม่มี sub** → ไม่บังคับ hierarchy; พฤติกรรมเดิมของ “รายการธรรมดา” ยังใช้ได้ (สอดคล้อง arcal2-01 ข้อ 9)
- **D-03:** ระดับ **entry** เมื่อมีโครงสร้าง v2 ที่มี sub → คอลัมโภชนาการบน `FoodEntry` ต้อง **สอดคล้อง recompute** หลังทุกการแก้ที่เกี่ยว (สอดคล้อง Phase 13 D-03)

### สเกลปริมาณรวม (ARC2-ING-02)

- **D-04:** เมื่อผู้ใช้เปลี่ยน **ปริมาณรวม (serving/amount) ของแถว main ที่มี sub** → **สเกลทุก sub ตามสัดส่วนเดิม** ของ macro/ปริมาณต่อหน่วยที่เลเยอร์กลางกำหนด — **ห้าม** ให้ Add / Edit / Gemini ใช้สูตรคนละแบบ
- **D-05:** Listener / `readOnly` บนช่องโภชนาการของ main ต้องสอดคล้อง `.cursorrules` (base ต่อหน่วย, recalculate เมื่อปริมาณเปลี่ยน)

### AI → main/sub (ARC2-ING-03)

- **D-06:** หลัง parse JSON จาก Gemini: **แต่ละ root ใน `ingredients_detail` → หนึ่ง main**; **`sub_ingredients` หนึ่งชั้น → sub** ของ main นั้น; โครงลึกกว่า → **เรียก flatten กลาง** (Phase 13) ก่อนเข้าโมเดล v2
- **D-07:** ชื่อจาน / ชื่อรายการบน entry ยังเป็นของ **ระดับ entry** — subs ไม่แยกเป็น entry ใหม่ในเฟสนี้

### สัญญาเดียวทุก path (ARC2-ING-04)

- **D-08:** **บันทึก `ingredientsJson`:** ทุก path ต้องผ่าน **encode v2 + recompute กลาง** (ไม่ `jsonEncode(List.from(_ingredients.map(toMap)))` แยกกันหลายแบบ) — refactor widget ให้เรียก API เดียวหลัง Phase 13 นิยามแล้ว
- **D-09:** **โหลด:** ใช้ **parse กลาง** ที่รองรับ legacy List + v2 Map (`schemaVersion`) ตาม Phase 13 — ห้ามสมมติแค่ `List` ในไฟล์ใหม่หลัง migrate จุดสำคัญ
- **D-10:** REQ ระบุ **IntentHandler** — ใน repo ปัจจุบันให้ถือว่าครอบคลุมอย่างน้อย **`lib/features/chat/providers/chat_provider.dart`** (flow `food_log`, `preliminaryIngredientsJson`) และ **ทุกจุดที่เพิ่ม/อัปเดต entry จากข้อความ AI** ในอนาคตต้องใช้สัญญาเดียวกัน; ถ้ามีคลาสชื่อ IntentHandler ภายหลัง ให้รวม path นั้นใน checklist เดียวกับ D-08

### Gemini prompt & post-process (ARC2-AI-01)

- **D-11:** หลังได้ `ingredients_detail` (และ flatten แล้ว): รัน **post-process** ที่ปรับ **ยอด macro ระดับ entry** ให้เท่ากับผลรวมที่ derive จาก mains/subs (ภายใน tolerance เล็กน้อยถ้ามี rounding — ระบุใน implementation) เพื่อผ่าน success criteria ROADMAP
- **D-12:** อัปเดต **prompt / คำอธิบาย schema ใน `gemini_service.dart`** ให้สอดคล้อง: root เท่านั้นในรายการหลัก, `sub_ingredients` หนึ่งชั้น, ไม่ double-count พลังงาน — สอดคล้องข้อความที่มีอยู่แต่ต้องไม่ขัดกับ v2 และ flatten
- **D-13:** **`GeminiAnalysisSheet`** วันนี้มี `_EditableIngredient` และ logic รวมจาก root เท่านั้น — ต้อง **อ้างเลเยอร์กลาง** แทน duplicate logic หลัง refactor (สอดคล้อง Phase 13 code_context)

### Micro และ Phase 13 D-08b

- **D-14:** เมื่อแก้ sub แล้ว recompute entry: ปฏิบัติตาม **Phase 13 D-08b** — micro บน entry ถ้ารวมจาก sub ไม่ครบให้ **คงค่าเดิม** ไม่ล้างเอง

### Claude's Discretion

- การ extract widget ร่วมสำหรับแถว main/sub ระหว่าง Add / Edit / Gemini (ลด triplicate `_EditableIngredient`)
- ลำดับงานภายในเฟส: อาจทำ “wire codec + recompute” ก่อน แล้วค่อยล็อก UI ทีละ sheet
- ข้อความ UI ใหม่ → **L10n** เท่านั้น

</decisions>

<canonical_refs>
## Canonical References

### Product

- `_project_manager/arcal_2_00/arcal2-01.md` — §2.2 ลำดับชั้น, ตารางตัดสินใจ (lock main, สเกลรวม, AI multi-root, flatten)
- `_project_manager/arcal_2_00/arcal2-00.md` — บริบท sub vs Create Meal, ingestion

### Requirements

- `.planning/REQUIREMENTS.md` — **ARC2-ING-01 … ARC2-ING-04**, **ARC2-AI-01**

### Prior phases

- `.planning/phases/13-ingredients-schema-recompute/13-CONTEXT.md` — codec v2, recompute, flatten, D-08b (micro)
- `.planning/phases/15-sandbox-timeline/15-CONTEXT.md` — ไม่ทับ scope แสดงผล timeline

### Rules

- `.cursorrules` — food pattern (base per unit, `UnitConverter`, L10n)

### Code (จุดบูรณาการหลัก)

- `lib/features/health/widgets/add_food_bottom_sheet.dart` — `_EditableIngredient`, `toMap`, save paths
- `lib/features/health/widgets/edit_food_bottom_sheet.dart` — parse/save `ingredientsJson`
- `lib/features/health/widgets/gemini_analysis_sheet.dart` — `_EditableIngredient`, รวมจาก root, sub parse
- `lib/core/ai/gemini_service.dart` — `ingredients_detail`, validation, prompts
- `lib/features/health/providers/health_provider.dart` — `updateFoodEntry` หลังวิเคราะห์, `saveIngredientsAndMeal`
- `lib/features/chat/providers/chat_provider.dart` — `food_log`, `preliminaryIngredientsJson` (IntentHandler-equivalent)
- `lib/features/health/widgets/log_from_meal_sheet.dart` — `ingredientTreeToJsonMaps` → `ingredientsJson`
- `lib/features/health/presentation/food_preview_screen.dart` — handoff บันทึกหลังวิเคราะห์ (ตรวจในแผน)
- `lib/core/utils/batch_analysis_helper.dart` — batch analyze → DB
- `lib/features/health/widgets/food_detail_bottom_sheet.dart`, `lib/features/home/widgets/simple_food_detail_sheet.dart`, `lib/features/health/widgets/meal_section.dart` — **อ่าน** `ingredientsJson` (ต้องรองรับ v2 / parse กลางเมื่อแก้การแสดงผล)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable assets (หลัง Phase 13)

- **Ingredients codec + `recomputeEntryTotals` + `flattenAiIngredients`** — single source of truth ตามที่ Phase 13 ส่งมอบ
- **`_EditableIngredient` ซ้ำ** ใน `add_food_bottom_sheet.dart` และ `gemini_analysis_sheet.dart` (+ ส่วนที่คล้ายกันใน `edit_food_bottom_sheet.dart`) — เป้าหมาย long-term: ลด duplication ผ่านโมเดล/ช่วยเหลือกลาง

### Established patterns วันนี้

- หลายจุด **encode เป็น List** จาก `toMap()` — ต้องเปลี่ยนเป็น **v2 object** เมื่อบันทึกผ่าน path ที่อัปเดตแล้ว
- `gemini_service` บังคับ `ingredients_detail` และมี fallback สร้างรายการเดียว — post-process ต้องไม่ทำให้ยอดขัดกับ subs

### Integration points

- ทุก `insert`/`update` ที่แตะ `ingredientsJson` ต้องอยู่ใน checklist เดียวกับ D-08–D-09

</code_context>

<specifics>
## Specific Ideas

- Success criteria ROADMAP: (1) หลัง AI ชื่อจาน ตัวเลขรวมสอดคล้อง mains/subs (2) แก้ sub → entry อัปเดต; แก้ปริมาณรวม → sub สเกล (3) chat + sheets ไม่แตกคนละสัญญา

</specifics>

<deferred>
## Deferred Ideas

- **Phase 17:** merge group, micro thumbnails, Create Meal จาก gallery
- การปรับ **UI แสดงรายละเอียด** บน `FoodDetailBottomSheet` ให้ “สวยขึ้น” โดยไม่จำเป็นต่อสัญญา — ทำเฉพาะเมื่อจำเป็นเพื่ออ่าน v2

### Reviewed Todos

- รัน `todo match-phase 16` ตอนบันทึก session

</deferred>

---

*Phase: 16-ingredient-ui-ai*  
*Context gathered: 2026-03-29*
