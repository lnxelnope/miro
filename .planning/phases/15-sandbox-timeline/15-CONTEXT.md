# Phase 15: Sandbox timeline - Context

**Gathered:** 2026-03-29  
**Status:** Ready for planning

<domain>
## Phase Boundary

ส่งมอบ **มุมมองวันเดียวใน Basic home** ที่:

1. **`FoodSandbox`** (หรือ wrapper) แสดงรายการอาหารเป็น **feed เดียว** แต่มี **กลุ่มมื้อแบบเบา** (เช้า / กลางวัน / เย็น / ว่าง) **ไม่**ใช้ layout แบบ Pro `MealSection` เป็นหลัก  
2. ผู้ใช้ **เลื่อนไปวันอนาคต** (พรุ่งนี้และต่อๆ ไป) ได้ **สอดคล้องกัน** ทุกจุดที่เกี่ยว (ลูกศร, date picker, ฯลฯ)  
3. ผู้ใช้ **เปลี่ยน `mealType`** ของรายการจาก flow แซนด์บ็อกซ์ได้ **อย่างน้อยหนึ่งวิธี** (ปุ่มบนแถบเลือกหลายรายการและ/หรือลาก — ขั้นต่ำคือ UX เทียบเท่า)

**ไม่อยู่ในเฟสนี้:** ปุ่ม Group / merge entry (Phase 17); ingredients schema (Phase 13); shell ModeToggle/QuestBar (Phase 14); ล็อก main ใน sheet (Phase 16)

**Dependency:** ROADMAP แนะนำ Phase 14 เสร็จก่อน — shell basic เสถียรก่อนจัดกลุ่มมื้อบนหน้าหลัก

</domain>

<decisions>
## Implementation Decisions

### กลุ่มมื้อในแซนด์บ็อกซ์ (ARC2-TIMELINE-01)

- **D-01:** ใช้ **สกรอลล์/คอลัมน์เดียว** เรียง **ตามลำดับมื้อคงที่:** Breakfast → Lunch → Dinner → Snack — **ไม่**ใช้แท็บที่ซ่อนมื้ออื่น (คงหลักการ “feed เดียว” จาก arcal2-01)
- **D-02:** มื้อที่ **ไม่มีรายการในวันนั้น** → **ไม่แสดงหัวข้อ/กรอบ** มื้อนั้น (ไม่โชว์ส่วนว่าง)
- **D-03:** **กรอบมื้อแบบเบา:** แต่ละมื้อมีหัวข้อมื้อ + กรอบ/พื้นหลังอ่อน (ตาม design token ที่มี) ครอบ **เฉพาะกลุ่มฟอง (`_FoodBubble`)** ของมื้อนั้น — ไม่ทำหัวมื้อใหญ่แบบบล็อก Pro แย่งพื้นที่แนวตั้งมากเกินไป
- **D-04:** ภายในแต่ละมื้อ ใช้ **กฎเรียงเดิมของแซนด์บ็อกซ์** เท่าที่เป็นไปได้: รูปก่อน แล้วเรียงตาม `timestamp` แบบเดิม (desc) **ภายในกลุ่มมื้อนั้น**
- **D-05:** หัวข้อมื้อใช้ **L10n** — `mealBreakfast`, `mealLunch`, `mealDinner`, `mealSnack` (มีใน ARB แล้ว) ผ่าน helper map จาก `MealType` → **ห้าม** hardcode ชื่อมื้อภาษาอังกฤษใน widget ใหม่

### วันที่อนาคต (ARC2-TIMELINE-02)

- **D-06:** นิยาม **ขีดบนสุดของการเลือกวัน** เป็นค่าคงที่เดียวกัน เช่น **`planningHorizonDays = 365`** (วันนี้ + 365) — เก็บในที่เดียว (เช่น `lib/core/constants/date_planning_limits.dart` หรือเทียบเท่า) แล้วให้ทุกจุดอ้างอิงค่านี้
- **D-07:** **`DailySummaryCard`:** ลูกศรขวาเปิดได้เมื่อ `selectedDate < maxPlanningDate` (ไม่ disable แค่เพราะ “เป็นวันนี้”); `showDatePicker` ใช้ `lastDate` = max วางแผนเดียวกัน
- **D-08:** **`DateNavigationBar`:** ปรับ `showDatePicker` `lastDate` และพฤติกรรมลูกศรให้สอดคล้อง D-06–D-07 (ทุก path ที่ผู้ใช้เลือกวันเดียวกันจากหน้าที่เกี่ยว)
- **D-09:** **`FoodSandbox._moveSelectedToDate`:** `lastDate` ของ date picker **ต้องสอดคล้อง** D-06 (ตอนนี้ใช้ `DateTime.now().add(Duration(days: 1))` — ต้องยกระดับให้เท่ากับขีดวางแผน)
- **D-10:** จุดอื่นที่มี `lastDate: DateTime.now()` หรือลูกศรจำกัดที่ “วันนี้” (เช่น `edit_food_bottom_sheet` ถ้ายังไม่สอดคล้อง) — **audit ในแผน** ให้ตรงกับ horizon เดียวกันเมื่อเป็น “เลือกวันของมื้อ/รายการ” ใน flow เดียวกับ timeline หลัก

### ย้ายมื้อ / เปลี่ยน mealType (ARC2-TIMELINE-03)

- **D-11:** **ขั้นต่ำที่ต้องส่งมอบ:** บน **แถบเลือกหลายรายการ** (`_buildSelectionBar`) เพิ่มปุ่ม (ไอคอน + tooltip จาก L10n) เปิด bottom sheet เลือกมื้อใหม่ — ใช้พฤติกรรมเดียวกับ **`_ChangeMealBottomSheet` ใน `meal_section.dart`** โดย **แยก/ย้าย** widget นี้ไปไฟล์กลางที่ import ได้จากทั้ง `MealSection` และ `FoodSandbox` (ห้ามคัดลอกยาวโดยไม่จำเป็น)
- **D-12:** หลังเลือกมื้อ: อัปเดต **`FoodEntry.mealType`** ผ่านชั้น DB ที่มีอยู่ (`updateFoodEntry` + `invalidate` providers ตามแพทเทิร์นเดิมของ meal_section) — **timestamp ของ entry คงค่าเดิม** ในเฟสนี้ (ไม่บังคับเลื่อนเวลาให้เข้า “ช่วงมื้อ”)
- **D-13:** **ลากข้ามมื้อ (drag-and-drop):** เป็น **nice-to-have** ในเฟสนี้ — ถ้าไม่ทันรอบแรก ให้ส่งมอบเฉพาะ D-11 ยังผ่าน REQ; ถ้าทำได้ให้เพิ่มเป็นงานย่อยหลังปุ่มเสถียร

### การตรวจสอบ (ROADMAP success criteria)

- **D-14:** (1) เห็นกลุ่มมื้อแยกชัดในแซนด์บ็อกซ์โดยไม่กลายเป็น MealSection แบบ Pro (2) เลื่อนไปพรุ่งนี้และวันในอนาคตได้จาก summary + picker สอดคล้องกัน (3) เลือกหลายรายการ → ย้ายมื้อได้และรายการไปอยู่กลุ่มมื้อถูกต้องหลังรีเฟรช

### Claude's Discretion

- ความหนา/สีของกรอบมื้อ, padding ระหว่างกลุ่ม — ให้สอดคล้อง `AppSpacing` / dark mode  
- การ refactor `IndexedStack`/`Wrap` เป็น `ListView` ถ้าต้องการ scroll ยาว — ตามโครงสร้าง `BasicModeTab` ที่มีอยู่  
- แก้ข้อความ **'Today'** hardcode ใน `DailySummaryCard` เป็น L10n **ถ้า**แตะไฟล์นี้ในเฟสนี้ (สอดคล้อง `.cursorrules`)

</decisions>

<canonical_refs>
## Canonical References

### Product

- `_project_manager/arcal_2_00/arcal2-01.md` — §2.1 แซนด์บ็อกซ์ + กลุ่มมื้อเบา, §3.2 วันที่อนาคต, §3.4 ย้ายข้ามมื้อ

### Requirements

- `.planning/REQUIREMENTS.md` — **ARC2-TIMELINE-01**, **ARC2-TIMELINE-02**, **ARC2-TIMELINE-03**

### Prior phases

- `.planning/phases/14-app-shell-energy/14-CONTEXT.md` — shell basic เป็นหลักก่อนแสดงกลุ่มมื้อนี้
- `.planning/phases/13-ingredients-schema-recompute/13-CONTEXT.md` — ไม่ทับกัน

### Rules

- `.cursorrules` — L10n, ไม่ hardcode string

### Code

- `lib/features/home/widgets/food_sandbox.dart` — แซนด์บ็อกซ์, selection bar, `onMoveToDate`, sort
- `lib/features/home/presentation/basic_mode_tab.dart` — `FoodSandbox`, `_selectedDate`, providers
- `lib/features/health/widgets/daily_summary_card.dart` — ลูกศร, `_pickDate`, `isToday`
- `lib/features/health/widgets/date_navigation_bar.dart` — date picker `lastDate`
- `lib/features/health/widgets/meal_section.dart` — `_ChangeMealBottomSheet`, อัปเดต `mealType`
- `lib/features/health/providers/health_provider.dart` (หรือที่เกี่ยว) — `healthTimelineProvider`, `refreshFoodProviders`
- `lib/core/constants/enums.dart` — `MealTypeExtension` (displayName ภาษาอังกฤษ — อย่าใช้สำหรับ UI ใหม่ที่ต้องแปล; ใช้ L10n ตาม D-05)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets

- **`_ChangeMealBottomSheet`** ใน `meal_section.dart` — รูปแบบเลือกมื้อ/วันมีแล้ว; ควร extract ให้ `FoodSandbox` ใช้ร่วม
- **Selection bar** ใน `FoodSandbox` — มี delete / move date / analyze — ต่อยอดปุ่ม “ย้ายมื้อ”

### Established Patterns

- รายการต่อวันมาจาก `healthTimelineProvider(_selectedDate)` ใน `BasicModeTab`
- `MealType` เป็น Drift enum; บันทึกผ่านอัปเดต entry แล้ว invalidate

### Integration Points

- หลังเปลี่ยน `mealType` ต้อง **invalidate** ชุดเดียวกับที่ `meal_section` ใช้เพื่อให้แซนด์บ็อกซ์รีเฟรช

</code_context>

<specifics>
## Specific Ideas

- arcal2-01: ประหยัดพื้นที่หน้าจอ — กรอบมื้อ **เบา** ไม่แยกบล็อกใหญ่เหมือน Pro

</specifics>

<deferred>
## Deferred Ideas

- ปุ่ม **Group** / merge หลาย entry — **Phase 17**
- Thumbnail ราย ingredient — **Phase 17**
- ลากจริงข้ามกลุ่ม — D-13 optional

### Reviewed Todos

- ไม่มีจาก `todo match-phase 15`

</deferred>

---

*Phase: 15-sandbox-timeline*  
*Context gathered: 2026-03-29*
