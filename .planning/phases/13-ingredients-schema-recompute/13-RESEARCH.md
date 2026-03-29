# Phase 13 — Technical research: Ingredients schema & recompute

**Phase:** 13 — ingredients-schema-recompute  
**Date:** 2026-03-29  
**Question:** What do we need to know to PLAN and IMPLEMENT this phase well?

## RESEARCH COMPLETE

---

## 1. Current legacy shape (on disk)

- `FoodEntry.ingredientsJson` is often `jsonEncode(List<Map>)` where each map matches `_EditableIngredient.toMap()` in `add_food_bottom_sheet.dart`:
  - Keys: `name`, `name_en`, `amount`, `unit`, `calories`, `protein`, `carbs`, `fat`, optional nested `sub_ingredients` (same shape).
- Many readers assume `jsonDecode` → `List<dynamic>` (`food_detail_bottom_sheet`, `edit_food_bottom_sheet`, `meal_section`, `simple_food_detail_sheet`).
- **Implication:** `parse()` must branch: `List` → legacy; `Map` with `schemaVersion == 2` → v2 wrapper per `13-CONTEXT` D-10.

## 2. Target v2 wire format (locked)

- Root **object** (not array):
  - `schemaVersion`: `2` (int)
  - `mainIngredients`: `List` of mains; each has `subIngredients` (may be empty) and English keys for nutrition/amount fields (D-09).
- Align inner node field names with existing `toMap()` where possible (`name`, `name_en`, `amount`, `unit`, macros) to minimize migration friction; use `subIngredients` in JSON as camelCase for v2 root document (Dart `jsonEncode` convention) — **planner must pick one:** either keep snake_case `sub_ingredients` inside nodes for parity with legacy maps, or camelCase everywhere in v2 only; document in codec.

*Recommendation:* v2 document uses **camelCase** for structure keys (`mainIngredients`, `subIngredients`, `schemaVersion`) per typical Dart JSON; **per-ingredient** maps can keep `name`, `name_en`, `amount`, `unit`, macros identical to legacy list items so conversion is mechanical.

## 3. Recompute pipeline (sub → main → entry)

- **Main with empty subs:** main row macros are authoritative for that row (same as today).
- **Main with non-empty subs:** main macros = sum(subs) for protein/carbs/fat/calories; **do not** trust main’s stored macros if subs present (Phase 16 will lock UI; Phase 13 implements the math).
- **Entry-level macros:** When **any** main has non-empty `subIngredients`, entry `calories`/`protein`/`carbs`/`fat` should equal sum of mains after main roll-up (which equals sum of all subs under those mains). When **no** subs exist anywhere, entry macros remain as today (D-02).
- **Micro (fiber/sugar/sodium):** Per D-08b — only overwrite entry micro when **all** participating subs (and mains if counted) provide that micro field; otherwise **preserve** existing `FoodEntry` micro values (no silent nulling).

## 4. Flatten (ARC2-DATA-03 / D-07)

- **Input:** nested `ingredients_detail`-like trees (depth > 2).
- **Output:** at most main + one sub level; **total kcal (and other macros) must not increase** vs sum of leaf nodes if leaves were non-overlapping components.
- **Recommended algorithm (default for planner):**
  - Treat each **root** AI item as one **main**.
  - For any `sub_ingredients` entry that itself has `sub_ingredients`, **hoist** grandchildren: append them to the **same main’s** `subIngredients` list with a **display name** `"{parent} › {child}"` (or similar) and **split parent’s reported macros** across hoisted children **proportionally by child’s own calories if child has calories > 0**, else **equal split** of parent macro budget; reduce parent sub to a single synthetic row if needed to avoid double count — **executor must implement one deterministic strategy** and cover with unit test (D-11.3).
- **Edge case:** If AI returns only one root with deep nesting, flatten still yields one main with many subs.

## 5. Module placement

- New library under `lib/core/nutrition/` (or `lib/core/ingredients/`) — **no UI imports** from this library (keep dependency arrow clean).
- Public API sketch:
  - `IngredientsParseResult parseIngredientsJson(String? raw)` — never throws for malformed JSON; returns legacy/v2/empty enum + structured model or errors list.
  - `String? serializeIngredientsV2(IngredientsDocumentV2 doc)`
  - `IngredientsDocumentV2 flattenAiIngredients(List<Map<String, dynamic>> roots)` (or similar)
  - `EntryNutritionPatch recomputeEntryTotals({required IngredientsDocumentV2 doc, required double? currentFiber, ...})` — returns patch for entry columns only (macros + conditional micro).

## 6. Testing (Flutter)

- Project already has `test/` with `food_entry_extensions_test.dart` — add `test/core/nutrition/ingredients_codec_test.dart` (or parallel path matching implementation).
- Commands: `flutter test test/core/nutrition/ingredients_codec_test.dart` (quick), `flutter test` (full).

## 7. Integration boundary for Phase 13 vs 16

- **Phase 13:** Ship **library + tests** (+ optional **non-UI** helper re-exported for future use). Full wiring of Add/Edit/Gemini/chat → codec is **Phase 16** per `13-CONTEXT`.
- **ROADMAP** wording “บันทึกใหม่ใช้รูปแบบใหม่” is satisfied for this phase by **proven encoder** + **test** that legacy list round-trips to v2 string containing `"schemaVersion":2` when caller opts in; production UI save paths migrate in Phase 16.

---

## Validation Architecture

> Nyquist Dimension 8 — how execution proves correctness without shipping broken nutrition math.

### Feedback channels

1. **Automated:** `flutter test` on `ingredients_codec_test.dart` — required after every task touching `lib/core/nutrition/*`.
2. **Deterministic fixtures:** JSON strings committed in `test/` for legacy list, v2 document, deep-nested AI sample.
3. **Manual checklist (fallback for integration):** `13-MANUAL-CHECKLIST.md` (created in plan 02) — one engineer verifies read legacy entry file without crash using `parse()` only if UI wiring lands early; otherwise skip manual until Phase 16.

### Gate criteria before phase sign-off

- All unit tests in plan 02 green.
- At least **one** flatten fixture with depth ≥ 3 produces **≤ 2 levels** and **macro sum invariant** documented in test assertion.
- `recomputeEntryTotals` test: subs with known macros → entry patch matches hand-calculated sum; micro partial data → entry fiber/sugar/sodium unchanged (D-08b).

---

## Risks

- **Key naming drift** between legacy list maps and v2 inner maps — mitigate with explicit mapping table in codec.
- **Floating rounding** — use tolerance `1e-6` or round to 1 decimal for grams/kcal in tests.

---

*End of research*
