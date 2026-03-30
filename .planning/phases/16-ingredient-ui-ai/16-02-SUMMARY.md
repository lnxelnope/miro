# 16-02 Summary — Gemini preview + batch

## สถานะ

- `batch_analysis_helper.dart`: `parseIngredientsJson`, `flattenAiIngredientRoots`, `serializeIngredientsV2`
- `food_preview_screen.dart`: ไม่มี `jsonEncode(_analysisResult!.ingredientsDetail)` (ใช้ pipeline v2 แล้ว)
- `gemini_analysis_sheet.dart`: flatten + `recomputeEntryRollup`; **เพิ่มในรอบนี้** `serializeIngredientsV2(doc)` → ฟิลด์ `ingredientsJsonV2` บน `GeminiConfirmedData` เพื่อ canonical string เดียวกับ doc ที่ rollup แล้ว
- `barcode_scanner_screen.dart`: ใช้ `ingredientsJsonV2` ก่อน แล้วค่อย fallback `legacyListToV2` + `parseIngredientsJson` เพื่อได้ `ingDoc` สำหรับ `applyIngredientsRollupToFoodEntry`
