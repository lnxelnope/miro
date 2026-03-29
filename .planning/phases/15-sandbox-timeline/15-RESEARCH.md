# Phase 15 — Technical research: Sandbox timeline

**Phase:** 15 — sandbox-timeline  
**Date:** 2026-03-29  
**Question:** What do we need to know to PLAN and IMPLEMENT this phase well?

## RESEARCH COMPLETE

---

## 1. FoodSandbox ปัจจุบัน

- **ไฟล์:** `lib/features/home/widgets/food_sandbox.dart`
- **เรียง:** `sorted` = รูปก่อน แล้ว `timestamp` desc — ใช้กฎเดิม **ภายในแต่ละมื้อ** หลัง group (D-04)
- **เลือกหลายรายการ:** `_buildSelectionBar` — delete, move date (`lastDate: now+1d`), analyze — **ยังไม่มี** ย้ายมื้อ
- **Callback ที่มี:** `onMoveToDate`, `onDeleteSelected`, `onAnalyzeSelected` — ต้องเพิ่มแบบเดียวกันสำหรับ batch change meal → `BasicModeTab` เรียก `foodEntriesNotifierProvider.updateFoodEntry` + invalidate เหมือน `_moveEntriesToDate`

## 2. วันที่ — จุดที่ต้องจัดแนว

| ไฟล์ | ประเด็น |
|------|---------|
| `daily_summary_card.dart` | ลูกศรขวา `disabled: isToday`; `_pickDate` `lastDate: DateTime.now()`; ข้อความ `'Today'` hardcode |
| `date_navigation_bar.dart` | `_canGoForward` = `!_isCurrentPeriod` → ไปอนาคตไม่ได้เมื่อยังเป็นวันนี้; picker `lastDate: DateTime.now()` (2 จุด); tooltips ภาษาอังกฤษ hardcode |
| `food_sandbox.dart` | `_moveSelectedToDate` `lastDate: now+1` |
| `meal_section.dart` | `_ChangeMealBottomSheet._pickDate` `lastDate: now+1` |
| `edit_food_bottom_sheet.dart` | `lastDate: now+1` |

**กลยุทธ์:** ค่าคงที่ `planningHorizonDays = 365` ใน `lib/core/constants/date_planning_limits.dart` + `DateTime maxPlanningDate` (date-only หรือ endOfDay — เลือกหนึ่งแบบทั้งแผน) ใช้ร่วมกันทุก `showDatePicker` และ logic ลูกศร

## 3. Change meal sheet

- **`_ChangeMealBottomSheet`** ใน `meal_section.dart` (~บรรทัด 1259+) — Stateful, เลือก `MealType` + optional เปลี่ยนวัน (แต่ D-12 เฟสนี้ **timestamp คงเดิม** เมื่อย้ายมื้อจาก sandbox — แยกจากฟีเจอร์เปลี่ยนวันใน sheet เดิม)
- **Sandbox batch:** เปิด sheet แบบ **เลือกมื้ออย่างเดียว** (ไม่เปลี่ยนวันในรอบนี้) หรือซ่อน date section เมื่อ `isBatchMode` — ลดความสับสนกับ D-12
- **หลังบันทึก:** `updateFoodEntry` + `invalidate` ชุดเดียวกับ `_refreshProviders` ใน `meal_section` (foodEntriesByDateProvider, healthTimelineProvider, todayCaloriesProvider, todayMacrosProvider)

## 4. L10n

- มื้อ: `mealBreakfast`, `mealLunch`, `mealDinner`, `mealSnack` ใน ARB แล้ว (D-05)
- อาจต้องเพิ่ม: `moveToMealTooltip` / `changeMealForMultiple` สำหรับแถบเลือกและข้อความ snackbar แทน `"Moved to ${...displayName}"` ภาษาอังกฤษ

## 5. Phase 17

- ปุ่ม Group — แถบเลือกควรเหลือพื้นที่ต่อไอคอน (ไม่บังกับในเฟสนี้ แค่ระวัง layout)

---

## Validation Architecture

1. **`flutter analyze`** บนไฟล์ที่แตะ
2. **Grep gates:** `DateTime.now()` ใน `showDatePicker` `lastDate` ของ flow timeline หลักต้องไม่เหลือแบบเดิมที่จำกัดแค่พรุ่งนี้ — ต้องอ้าง `DatePlanningLimits` หรือค่าที่คำนวณจาก horizon เดียวกัน
3. **Manual `15-MANUAL-CHECKLIST.md`:** กลุ่มมื้อ, เลื่อนวันอนาคต, เลือกหลายรายการ → ย้ายมื้อ

---

*End of research*
