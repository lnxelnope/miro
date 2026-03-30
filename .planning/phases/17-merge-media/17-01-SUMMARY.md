# 17-01 Summary — Group merge (ARC2-GR-01)

- L10n: `mergeGroup`, `confirmMergeTitle`, `confirmMergeMessage`, `mergeDisabledNested`, `mergedSuccess` (en/th + gen-l10n)
- `merge_food_entries.dart`: `buildMergedEntry` → v2 `ingredientsJson`, `group_<timestamp>`, flatten mains
- `food_sandbox.dart`: `onMergeSelected`, ปุ่ม merge เมื่อ ≥2 และไม่มี `isGroupOriginal`
- `basic_mode_tab.dart`: `_mergeSelectedEntries` + dialog + ลบรายการเดิม + `refreshFoodProviders`
