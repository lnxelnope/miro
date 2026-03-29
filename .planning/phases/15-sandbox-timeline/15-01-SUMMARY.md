# 15-01 — Summary

**สถานะ:** เสร็จ

## สิ่งที่ส่งมอบ

- `lib/core/constants/date_planning_limits.dart` — `planningHorizonDays` (365), `getMaxPlanningDate()`, `isOnOrBeforePlanningHorizon`
- `daily_summary_card.dart` — ลูกศรขวาเมื่อยังไม่ถึง max; `showDatePicker` ใช้ `getMaxPlanningDate`; `summaryLabelToday` + `DateFormat` ตาม locale
- `date_navigation_bar.dart` — forward ตาม horizon; picker `lastDate` เดียวกัน; L10n สำหรับ tooltips, badge, All time, month helpText
- `food_sandbox.dart` / `edit_food_bottom_sheet.dart` — `lastDate` = `getMaxPlanningDate()` สำหรับย้ายวัน / แก้ entry

## หมายเหตุ

- `dateOnly` ใน navigation bar ใช้จาก `health_provider` เพื่อให้สอดคล้องกับคีย์ provider
