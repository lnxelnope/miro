# 16-03 Summary — AI write paths

## สถานะ

- `gemini_service.dart`: prompt ระบุ ONE LEVEL / ไม่ nested ใน `sub_ingredients` (อ้างอิง `rg` ในแผน 16-03)
- `chat_provider.dart`: `preliminaryIngredientsJson` ผ่าน `flattenAiIngredientRoots` + `serializeIngredientsV2` (ไม่มี `preliminaryIngredientsJson = jsonEncode`)
- `log_from_meal_sheet.dart`: `ingredientTreeToJsonMaps` → `legacyListToV2` → `serializeIngredientsV2`
