# 15-02 — Summary

**สถานะ:** เสร็จ

## สิ่งที่ส่งมอบ

- `change_meal_bottom_sheet.dart` — public widget, `allowDateChange`, batch `List<FoodEntry>`, `lastDate` จาก `DatePlanningLimits`
- `meal_section.dart` — ใช้ `ChangeMealBottomSheet`; Snackbar ผ่าน L10n (`mealMovedToMealType`, `mealMovedToDateLine`)
- `food_sandbox.dart` — `onChangeMealForSelected`, ปุ่ม `swap_horiz` + `sandboxTooltipChangeMeal`
- `basic_mode_tab.dart` — อัปเดต `mealType` แบบ batch + `refreshFoodProviders`

## ARB

- เพิ่มคีย์ EN/TH ที่เกี่ยวกับ navigation, snackbar, sandbox tooltip; รัน `flutter gen-l10n`
