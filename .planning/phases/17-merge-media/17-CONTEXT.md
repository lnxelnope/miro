# Phase 17: Merge & media - Context

**Gathered:** 2026-03-29  
**Status:** Ready for planning

<domain>
## Phase Boundary

ส่งมอบสามกลุ่มงานตาม ROADMAP / REQ:

1. **ARC2-GR-01:** จากโหมดเลือกหลายรายการใน **`FoodSandbox`** มีปุ่ม **Group** — **merge** เป็น `FoodEntry` ใหม่หนึ่งรายการ ชื่อดีฟอลต์ **`group_xxx`** (xxx = ลำดับหรือ timestamp ตามสเปกผลิตภัณฑ์); รายการเดิม **ลบ** (หรือทำเทียบเท่า hard delete ตามแพทเทิร์น app); ดูรายละเอียดด้วย **flow เดิม** (simple detail)
2. **ARC2-THUMB-01:** ในแถว **ingredient** ที่มี path รูป — แสดง **micro thumbnail**; แตะ → ดูเต็มจอ + **overlay bounding box** ถ้ามีข้อมูล; **ไม่มี placeholder** เมื่อไม่มีรูป
3. **ARC2-MEAL-01:** **`CreateMealSheet`** มีปุ่ม **gallery** คู่ปุ่ม search (แถว sub) — รูปที่เลือกวิ่ง **pipeline วิเคราะห์รูปเดียวกับ** flow อาหารจากรูปมาตรฐาน แล้ว map ผลเข้าแถววัตถุดิบ

**Depends on:** **Phase 13** (โครงสร้าง `ingredientsJson` v2 / flatten / ห้าม sub-sub); **Phase 15** (แถบเลือกหลายรายการในแซนด์บ็อกซ์ — ปุ่ม Group ต่อยอดแถบเดียวกัน)

**ไม่อยู่ในเฟสนี้:** Share card / promo (**Phase 18**); ล็อก main + Gemini unified (**Phase 16** เป็นคนละชุด — merge ต้อง **สอดคล้อง** v2 หลัง 16 เสร็จ)

</domain>

<decisions>
## Implementation Decisions

### Group / Merge (ARC2-GR-01)

- **D-01:** ปุ่ม **Group** อยู่บน **`_buildSelectionBar`** ใน `food_sandbox.dart` ข้างปุ่มที่มีอยู่ (หลัง Phase 15) — แสดงเมื่อเลือก **อย่างน้อย 2** รายการ
- **D-02:** การ merge คือ **สร้าง `FoodEntry` ใหม่ 1 รายการ** แล้ว **ลบ** `FoodEntry` ที่เลือกทั้งหมดจาก DB (ตามแพทเทิร์น `delete`/`isDeleted` ที่โปรเจกต์ใช้ — เลือกแบบเดียวกับลบหลายรายการที่มีอยู่)
- **D-03:** ชื่อดีฟอลต์ **`group_<suffix>`** โดย suffix = **timestamp สร้าง** (ms หรือสั้นๆ) หรือเลขลำดับวันที่ไม่ชน — ห้าม hardcode string ใน UI; ข้อความนำหน้า "group_" อาจมาจาก L10n key แยกส่วน prefix หรือเก็บเป็นค่าดีฟอลต์ภาษาอังกฤษในโค้ดเฉพาะ **identifier** ถ้าผลิตภัณฑ์กำหนด — **D-03b:** ถ้าใช้ L10n สำหรับชื่อที่ผู้ใช้เห็น ให้มี key เช่น `defaultGroupMealName` พารามิเตอร์เลข
- **D-04:** **โภชนาการระดับ entry ใหม่** = **ผลรวม** calories/protein/carbs/fat (และ micro ที่รวมได้) จากทุก entry ที่ merge; **base ต่อหน่วย** คำนวณใหม่จาก serving รวมของ entry ใหม่ตาม `.cursorrules`
- **D-05:** **โครงสร้าง `ingredientsJson` ของ entry ใหม่:** แต่ละ entry เดิมที่ถูก merge → กลายเป็น **main ingredient หนึ่งรายการ** ภายใต้ entry ใหม่ (ตาม arcal2-01 §2.3); ถ้า entry เดิมมี main/sub อยู่แล้ว → **ยุบ sub เข้า main** ก่อน (ห้าม sub-sub) โดยใช้กฎ **Phase 13 / 16**
- **D-06:** **ห้าม nested group:** ถ้า selection มี entry ที่เป็นกลุ่มจาก merge ก่อนหน้า (เช่น `foodName` นำ `group_` หรือ flag `isGroupOriginal` / heuristic ที่ทีมกำหนด) → **disable ปุ่ม Group** พร้อม Snackbar L10n **หรือ** อนุญาตแค่ “ใบไม้” — **D-06 เลือก:** **disable Group** เมื่อมีอย่างน้อยหนึ่งรายการที่ระบุว่าเป็น merged group (นิยามใน implementation จาก `isGroupOriginal` + กฎเพิ่มถ้าจำเป็น)
- **D-07:** **mealType / วันที่ของ entry ใหม่:** ใช้ **`mealType` และวันที่ (date part ของ `timestamp`) ของ entry ที่มี `timestamp` เร็วที่สุด** ในกลุ่มที่เลือก (เช้าของวันนั้น = context เดิม); เวลาในนาทีใช้เวลาปัจจุบันหรือเวลาของ entry แรก — **Claude's discretion** ให้สอดคล้องการแสดงใน timeline
- **D-08:** **รูปหลัก entry ใหม่:** ใช้ `imagePath` จาก entry แรกในลำดับที่มีรูป หรือ null ถ้าไม่มีใครมีรูป — บันทึกใน SUMMARY ถ้ามีหลายรูปและต้องการนโยบายอื่น
- **D-09:** หลัง merge: **`invalidate`** providers ชุดเดียวกับลบ/ย้ายหลายรายการ (`foodEntriesByDateProvider`, `healthTimelineProvider`, `todayCaloriesProvider`, `todayMacrosProvider` ฯลฯ)

### Thumbnail ingredient (ARC2-THUMB-01)

- **D-10:** แสดงเฉพาะเมื่อมี path รูปที่ใช้โหลดได้ — **ไม่มีกล่อง placeholder** สีเทา
- **D-11:** ขนาด **micro** (เช่น 24–36 logical px) สอดคล้อง `AppSpacing`; แตะ → **full-screen / dialog** ดูรูปเต็ม
- **D-12:** ถ้ามี **`arBoundingBox`** + `arImageWidth`/`arImageHeight` (หรือข้อมูลเทียบเท่า) → วาด **overlay** บนรูปเต็ม; ถ้าไม่มี bbox ให้แสดงแค่รูป
- **D-13:** ขอบเขตแถวที่ REQ หมายถึงในเฟสนี้: **อย่างน้อย** `create_meal_sheet.dart` และแถว ingredient ใน **Add/Edit food** / **Gemini analysis sheet** ที่มีข้อมูลรูปต่อแถว — ถ้าโมเดล v2 ยังไม่มี `imagePath` ต่อโหนด ให้ **ขยาย schema โหนด** (คีย์อังกฤษ) แบบ **optional** และอ่าน legacy ได้ (ไม่บังคับฟิลด์) — สอดคล้อง Phase 13 backward read
- **D-14:** สร้าง widget กลาง **`IngredientThumb`** (หรือชื่อเดียวกัน) ใน `lib/core/widgets/` หรือ `lib/features/health/widgets/` เพื่อ reuse

### Create Meal — gallery (ARC2-MEAL-01)

- **D-15:** วาง **`IconButton`/`InkWell`** ข้าง `Icons.search` บนแถว sub (บรรทัด ~953–966 ใน `create_meal_sheet.dart`) — เปิด **gallery** ผ่าน `ImagePickerService` (หรือแพทเทิร์นเดียวกับ `BasicModeTab` / gallery flow)
- **D-16:** หลังได้ `File`: นำทางไป **`ImageAnalysisPreviewScreen`** หรือเรียก **บริการวิเคราะห์เดียวกับ** flow รูปอาหารมาตรฐาน (Gemini) แล้ว map ผลไปยังแถว sub ที่กำลังแก้ — **base ต่อหน่วย + UnitConverter + L10n** ตาม `.cursorrules`
- **D-17:** ไม่ทำลาย `_lookupSubIngredient` เดิม — เพิ่ม path คู่ขนาน

### การตรวจสอบ (ROADMAP)

- **D-18:** (1) Multi-select → Group → entry ใหม่ + ของเดิมหายจากวันนั้น (2) แถวมีรูปแสดง thumb + แตะดู bbox ได้เมื่อมีข้อมูล (3) Create Meal เลือกรูปแล้วได้ผลแนวเดียวกับวิเคราะห์รูปปกติ

### Claude's Discretion

- Dialog ยืนยันก่อน merge (แนะนำ) — ข้อความ L10n
- การรวม `originalIngredientsJson` / notes / imagePath เสริมหลายรูป
- ประสิทธิภาพ cache รูปย่อ

</decisions>

<canonical_refs>
## Canonical References

### Product

- `_project_manager/arcal_2_00/arcal2-01.md` — §2.3 Group/Merge, §2.4 Thumbnail, §2.5 Create meal gallery, §6 ตารางไฟล์ (T11/T12)
- `_project_manager/arcal_2_00/arcal2-00.md` — บริบทกลุ่ม / merge

### Requirements

- `.planning/REQUIREMENTS.md` — **ARC2-GR-01**, **ARC2-THUMB-01**, **ARC2-MEAL-01**

### Prior phases

- `.planning/phases/15-sandbox-timeline/15-CONTEXT.md` — แถบเลือก (ต่อยอดปุ่ม Group)
- `.planning/phases/13-ingredients-schema-recompute/13-CONTEXT.md`, **16-CONTEXT** — โครงสร้าง ingredients v2 สำหรับ merge
- `.planning/phases/16-ingredient-ui-ai/16-CONTEXT.md` — สอดคล้องการบันทึกหลัง merge

### Rules

- `.cursorrules` — L10n, food pattern, `UnitConverter`

### Code

- `lib/features/home/widgets/food_sandbox.dart` — selection bar, `_FoodBubble`
- `lib/features/home/presentation/basic_mode_tab.dart` — ส่ง callback ลบ/ย้าย — เพิ่ม `onMergeSelected` หรือเทียบเท่า
- `lib/core/database/app_database.dart` — `FoodEntry`, `groupId`, `isGroupOriginal`, `imagePath`, `arBoundingBox`, AR columns
- `lib/features/health/widgets/create_meal_sheet.dart` — `_lookupSubIngredient`, แถว sub
- `lib/features/health/presentation/image_analysis_preview_screen.dart` — pipeline รูป
- `lib/core/services/image_picker_service.dart`

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable assets

- **Selection mode** ใน `FoodSandbox` — เพิ่มปุ่ม Group
- **ลบหลายรายการ** — แพทเทิร์น invalidate หลังลบ
- **AR / รูป:** คอลัมน์ bbox + ขนาดภาพมีใน `FoodEntry`
- **Create meal:** มีแต่ search ยังไม่มี gallery ข้างกัน

### Integration points

- Merge ต้อง produce `ingredientsJson` **v2** ถ้าเฟส 13–16 บังคับ v2 แล้ว — มิฉะนั้นใช้รูปแบบที่ codec รองรับตอน execute
- `HealthProvider` / `foodEntriesNotifierProvider` สำหรับ insert ใหม่ + delete ชุด

</code_context>

<specifics>
## Specific Ideas

- arcal2-01: ชื่อ `group_xxx`; nutrition รวม; entry เดิม → main ใน JSON ใหม่

</specifics>

<deferred>
## Deferred Ideas

- **Phase 18:** Share aspect / promo
- Drag reorder ข้ามมื้อแบบลาก (optional Phase 15 D-13) — แยกจาก Group merge

### Reviewed Todos

- รัน `todo match-phase 17` ตอนบันทึก session

</deferred>

---

*Phase: 17-merge-media*  
*Context gathered: 2026-03-29 — spec-led (arcal2-01 + REQ + scout)*
