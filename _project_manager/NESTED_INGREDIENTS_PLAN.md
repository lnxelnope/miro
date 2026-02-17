# Nested Ingredients (Sub-division) Architecture Plan

> **Status**: Planning  
> **Created**: 2026-02-17  
> **Priority**: High — แก้ปัญหา double counting + เพิ่มความสามารถ AI  

---

## 1. Problem Statement

### ปัญหาปัจจุบัน
เมื่อ AI วิเคราะห์อาหาร (เช่น "KFC Chicken Pop, 1 serving") ระบบคืน `ingredients_detail` เป็น **flat list** ระดับเดียว:

```json
{
  "food_name": "KFC Chicken Pop",
  "nutrition": { "calories": 300 },
  "ingredients_detail": [
    { "name": "Fried Batter with Flour Chicken Breast", "calories": 150 },
    { "name": "Chicken Breast", "calories": 100 },
    { "name": "Wheat Flour", "calories": 30 },
    { "name": "Cooking Oil", "calories": 80 }
  ]
}
```

**ปัญหา:**
- "Fried Batter Chicken Breast" (150 kcal) = composite ที่รวม ไก่+แป้ง+น้ำมัน ไว้แล้ว
- แต่ AI ก็แตก ไก่, แป้ง, น้ำมัน ออกมาเป็น flat items ด้วย
- **ผลรวม ingredients = 360 kcal ≠ total 300 kcal** → double counting ใน MyMeal

### Vision
ทำให้ระบบรองรับ **hierarchical ingredients** เพื่อ:
1. แก้ double counting
2. ผู้ใช้เข้าใจโครงสร้างอาหารได้ชัดเจน
3. รองรับ use case อนาคต เช่น กล่องขนม 10 ชิ้น → 1 ซอง → ส่วนประกอบในซอง

---

## 2. Proposed Architecture

### 2.1 Hierarchical Structure

```
MyMeal: "KFC Chicken Pop" (300 kcal)
│
├── [ROOT] Fried Batter Chicken Breast (150 kcal)  ← นับแคล
│   ├── [SUB] Chicken Breast Meat (100 kcal)        ← ไม่นับ (อธิบาย)
│   ├── [SUB] Wheat Flour Batter (20 kcal)          ← ไม่นับ (อธิบาย)
│   └── [SUB] Absorbed Deep-frying Oil (30 kcal)    ← ไม่นับ (อธิบาย)
│
├── [ROOT] Sweet Chili Dipping Sauce (40 kcal)      ← นับแคล
│   ├── [SUB] Chili Paste (15 kcal)                 ← ไม่นับ (อธิบาย)
│   ├── [SUB] Sugar (20 kcal)                       ← ไม่นับ (อธิบาย)
│   └── [SUB] Vinegar (5 kcal)                      ← ไม่นับ (อธิบาย)
│
└── [ROOT] Deep-frying Oil (residual) (110 kcal)    ← นับแคล
```

### 2.2 Calorie Counting Rules (สำคัญมาก)

| Level | นับแคลรวม? | ใช้ทำอะไร |
|-------|-----------|----------|
| **ROOT** (parentId = null) | **YES** | คำนวณ `MyMeal.totalCalories` |
| **SUB** (parentId ≠ null) | **NO** | แสดงรายละเอียดให้ผู้ใช้เข้าใจ |

**กฎ:**
- `MyMeal.totalCalories` = sum ของ ROOT ingredients เท่านั้น
- `sum(SUB.calories)` ≈ parent ROOT.calories (เป็นการอธิบาย ไม่ใช่การนับเพิ่ม)
- `FoodEntry.calories` ใช้ top-level `nutrition.calories` จาก AI (ไม่เปลี่ยน)

### 2.3 Use Case ตัวอย่าง: กล่องขนม

```
MyMeal: "Pocky Box (10 sticks)" (350 kcal)
│
├── [ROOT] Pocky Stick (35 kcal × 10 = 350 kcal)
│   ├── [SUB] Chocolate Coating (20 kcal)
│   ├── [SUB] Biscuit Stick (12 kcal)
│   └── [SUB] Sugar Glaze (3 kcal)
```

เมื่อผู้ใช้ถ่ายรูป 1 ซองจากกล่อง:
```
FoodEntry: "Pocky (1 stick)" → 35 kcal
  └── AI รู้ว่ามาจากกล่อง 10 ชิ้น → แสดง "1/10 of Pocky Box"
```

---

## 3. Data Model Changes

### 3.1 MyMealIngredient — เพิ่ม fields

**ไฟล์:** `lib/features/health/models/my_meal_ingredient.dart`

```dart
@collection
class MyMealIngredient {
  Id id = Isar.autoIncrement;

  late int myMealId;
  late int ingredientId;
  late String ingredientName;
  late double amount;
  late String unit;
  late double calories;
  late double protein;
  late double carbs;
  late double fat;
  int sortOrder = 0;

  // ===== NEW: Nested/Sub-division fields =====
  
  /// Parent ingredient ID (null = root level, counted in total)
  int? parentId;
  
  /// Nesting depth (0 = root, 1 = sub-ingredient, 2 = sub-sub, etc.)
  int depth = 0;
  
  /// Whether this item has children (for quick checks without querying)
  bool isComposite = false;
  
  /// Detail/description about preparation or composition
  String? detail;
}
```

**หมายเหตุ Isar:**
- เพิ่ม field ใหม่ที่มี default value → **ไม่ต้อง migrate** Isar จะใส่ default ให้ record เดิม
- `parentId` nullable → record เดิมจะเป็น null = root level → backward compatible

### 3.2 IngredientDetail (AI Response Model) — เพิ่ม sub_ingredients

**ไฟล์:** `lib/core/ai/gemini_service.dart`

```dart
class IngredientDetail {
  final String name;
  final String? nameEn;
  final String? detail;           // NEW
  final double amount;
  final String unit;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final List<IngredientDetail>? subIngredients;  // NEW: recursive

  // ... constructor & fromJson
  
  factory IngredientDetail.fromJson(Map<String, dynamic> json) {
    return IngredientDetail(
      name: json['name'] ?? '',
      nameEn: json['name_en'],
      detail: json['detail'],                    // NEW
      amount: (json['amount'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'g',
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      subIngredients: json['sub_ingredients'] != null   // NEW
          ? (json['sub_ingredients'] as List)
              .map((e) => IngredientDetail.fromJson(e))
              .toList()
          : null,
    );
  }
}
```

### 3.3 Models ที่ไม่ต้องแก้

| Model | เหตุผล |
|-------|--------|
| `MyMeal` | totalCalories ยังคำนวณจาก root ingredients เหมือนเดิม |
| `Ingredient` | ยังเป็น atomic ingredient database เหมือนเดิม |
| `FoodEntry` | ใช้ top-level calories, ingredientsJson เก็บ snapshot (จะมี sub_ingredients ด้วย) |

---

## 4. AI Prompt Changes

### 4.1 New JSON Format (ทั้ง 3 prompts)

**ไฟล์ที่ต้องแก้:**
1. `lib/core/ai/gemini_service.dart` → `_getImageAnalysisPrompt()` (line 661)
2. `lib/core/ai/gemini_service.dart` → `_getTextAnalysisPrompt()` (line 803)
3. `functions/src/analyzeFood.ts` → `buildChatPrompt()` (line 376)

**เพิ่ม rule ใน prompt:**

```
INGREDIENT HIERARCHY RULES (CRITICAL — prevents double counting):

1. "ingredients_detail" contains ONLY recognizable food components at the ROOT level.
   These ROOT items are what get COUNTED for total calories.
   
2. Each ROOT ingredient MAY have "sub_ingredients" — these are the atomic breakdown
   showing what the component is made of. Sub-ingredients are INFORMATIONAL ONLY.
   
3. CALORIE RULES:
   - sum(ROOT.calories) MUST equal nutrition.calories (the total)
   - sum(sub_ingredients.calories) ≈ parent ROOT ingredient calories
   - NEVER put both a composite AND its raw materials at ROOT level
   
4. When to use sub_ingredients:
   - Deep-fried items → show meat + batter + absorbed oil
   - Sauces → show base ingredients (sugar, vinegar, chili)
   - Processed foods → show components
   - Simple items (plain rice, raw egg) → no sub_ingredients needed

WRONG (double counting):
  "ingredients_detail": [
    {"name": "Fried Chicken Breast", "calories": 150},
    {"name": "Chicken Breast", "calories": 100},     ← DUPLICATE!
    {"name": "Flour", "calories": 30},                ← DUPLICATE!
    {"name": "Oil", "calories": 80}                   ← DUPLICATE!
  ]

CORRECT (hierarchical):
  "ingredients_detail": [
    {
      "name": "Fried Batter Chicken Breast",
      "calories": 150,
      "sub_ingredients": [
        {"name": "Chicken Breast Meat", "calories": 100},
        {"name": "Wheat Flour Batter", "calories": 20},
        {"name": "Absorbed Frying Oil", "calories": 30}
      ]
    },
    {
      "name": "Deep-frying Oil (residual)",
      "calories": 110
    }
  ]
```

**New Example ใน prompt:**

```json
{
  "food_name": "KFC Chicken Pop",
  "food_name_en": "KFC Chicken Pop",
  "confidence": 0.85,
  "serving_size": 1,
  "serving_unit": "serving",
  "serving_grams": 150,
  "nutrition": {
    "calories": 300,
    "protein": 18,
    "carbs": 15,
    "fat": 20,
    "fiber": 0,
    "sugar": 1,
    "sodium": 600
  },
  "ingredients_detail": [
    {
      "name": "Deep-fried Battered Chicken Breast Pieces",
      "name_en": "Deep-fried Battered Chicken Breast Pieces",
      "detail": "Bite-sized chicken breast coated in seasoned flour batter, deep-fried",
      "amount": 120,
      "unit": "g",
      "calories": 250,
      "protein": 17,
      "carbs": 14,
      "fat": 15,
      "sub_ingredients": [
        {
          "name": "Chicken Breast Meat",
          "name_en": "Chicken Breast Meat",
          "detail": "Lean white meat, cut into pop-sized pieces",
          "amount": 80,
          "unit": "g",
          "calories": 132,
          "protein": 16,
          "carbs": 0,
          "fat": 7
        },
        {
          "name": "Seasoned Flour Batter",
          "name_en": "Seasoned Wheat Flour Batter (KFC style)",
          "detail": "Contains wheat flour, corn starch, salt, pepper, garlic powder, paprika",
          "amount": 25,
          "unit": "g",
          "calories": 48,
          "protein": 1,
          "carbs": 14,
          "fat": 0.3
        },
        {
          "name": "Absorbed Frying Oil",
          "name_en": "Vegetable Oil (absorbed during deep-frying)",
          "detail": "Oil absorbed by batter during frying at ~170°C",
          "amount": 8,
          "unit": "ml",
          "calories": 70,
          "protein": 0,
          "carbs": 0,
          "fat": 7.7
        }
      ]
    },
    {
      "name": "Seasoning Powder",
      "name_en": "MSG & Salt Seasoning Blend",
      "detail": "Sprinkled after frying — salt, MSG, sugar, spice mix",
      "amount": 3,
      "unit": "g",
      "calories": 5,
      "protein": 0,
      "carbs": 1,
      "fat": 0
    },
    {
      "name": "Dipping Sauce",
      "name_en": "Sweet Chili Dipping Sauce",
      "detail": "Thai-style sweet chili sauce served alongside",
      "amount": 25,
      "unit": "ml",
      "calories": 45,
      "protein": 1,
      "carbs": 10,
      "fat": 0,
      "sub_ingredients": [
        {
          "name": "Chili Paste",
          "name_en": "Red Chili Paste",
          "amount": 10,
          "unit": "g",
          "calories": 10,
          "protein": 0.5,
          "carbs": 2,
          "fat": 0
        },
        {
          "name": "Sugar",
          "name_en": "Cane Sugar",
          "amount": 8,
          "unit": "g",
          "calories": 32,
          "protein": 0,
          "carbs": 8,
          "fat": 0
        },
        {
          "name": "Vinegar & Garlic",
          "name_en": "Rice Vinegar & Minced Garlic",
          "amount": 7,
          "unit": "ml",
          "calories": 3,
          "protein": 0.5,
          "carbs": 0,
          "fat": 0
        }
      ]
    }
  ],
  "ingredients": ["chicken breast", "flour", "oil", "salt", "MSG", "chili sauce", "sugar"],
  "notes": "High sodium from seasoning + dipping sauce. Deep-frying adds significant hidden calories."
}
```

---

## 5. Provider / Business Logic Changes

### 5.1 MealIngredientInput — เพิ่ม children

**ไฟล์:** `lib/features/health/providers/my_meal_provider.dart`

```dart
class MealIngredientInput {
  final String name;
  final String? nameEn;
  final String? detail;                              // NEW
  final double amount;
  final String unit;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final List<MealIngredientInput>? subIngredients;   // NEW: recursive

  MealIngredientInput({
    required this.name,
    this.nameEn,
    this.detail,
    required this.amount,
    required this.unit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.subIngredients,
  });
}
```

### 5.2 createMeal() — handle nested

```dart
Future<MyMeal> createMeal({...}) async {
  // คำนวณ total จาก ROOT ingredients เท่านั้น (ไม่รวม sub)
  double totalCal = 0, totalP = 0, totalC = 0, totalF = 0;
  for (final ing in ingredients) {
    totalCal += ing.calories;  // ROOT only — sub อยู่ใน ing.subIngredients
    totalP += ing.protein;
    totalC += ing.carbs;
    totalF += ing.fat;
  }

  // สร้าง MyMeal (เหมือนเดิม)
  final meal = MyMeal() ...;
  await DatabaseService.isar.writeTxn(() async {
    await DatabaseService.myMeals.put(meal);
  });

  // สร้าง MyMealIngredient entries (recursive)
  int sortIndex = 0;
  for (final inp in ingredients) {
    final parentEntry = await _saveMealIngredient(
      meal: meal,
      input: inp,
      parentId: null,       // ROOT
      depth: 0,
      sortOrder: sortIndex++,
    );

    // Save sub-ingredients if any
    if (inp.subIngredients != null) {
      for (final sub in inp.subIngredients!) {
        await _saveMealIngredient(
          meal: meal,
          input: sub,
          parentId: parentEntry.id,   // link to parent
          depth: 1,
          sortOrder: sortIndex++,
        );
      }
      // Mark parent as composite
      parentEntry.isComposite = true;
      await DatabaseService.isar.writeTxn(() async {
        await DatabaseService.myMealIngredients.put(parentEntry);
      });
    }
  }
}
```

### 5.3 saveIngredientsAndMeal() — parse sub_ingredients

```dart
Future<void> saveIngredientsAndMeal({
  required List<Map<String, dynamic>> ingredientsData,
  ...
}) async {
  final inputs = ingredientsData.map((data) {
    // Parse sub_ingredients recursively
    List<MealIngredientInput>? subs;
    final subList = data['sub_ingredients'] as List<dynamic>?;
    if (subList != null && subList.isNotEmpty) {
      subs = subList.map((s) => MealIngredientInput(
        name: s['name'] as String,
        nameEn: s['name_en'] as String?,
        detail: s['detail'] as String?,
        amount: (s['amount'] as num).toDouble(),
        unit: s['unit'] as String,
        calories: (s['calories'] as num).toDouble(),
        protein: (s['protein'] as num).toDouble(),
        carbs: (s['carbs'] as num).toDouble(),
        fat: (s['fat'] as num).toDouble(),
      )).toList();
    }

    return MealIngredientInput(
      name: data['name'] as String,
      nameEn: data['name_en'] as String?,
      detail: data['detail'] as String?,
      amount: (data['amount'] as num).toDouble(),
      unit: data['unit'] as String,
      calories: (data['calories'] as num).toDouble(),
      protein: (data['protein'] as num).toDouble(),
      carbs: (data['carbs'] as num).toDouble(),
      fat: (data['fat'] as num).toDouble(),
      subIngredients: subs,
    );
  }).toList();

  await notifier.createMeal(..., ingredients: inputs);
}
```

### 5.4 New Provider — get tree-structured ingredients

```dart
/// ดึง ingredients ของ meal เป็น tree structure
final mealIngredientTreeProvider = FutureProvider.autoDispose
    .family<List<IngredientTreeNode>, int>((ref, mealId) async {
  final all = await DatabaseService.myMealIngredients
      .filter()
      .myMealIdEqualTo(mealId)
      .sortBySortOrder()
      .findAll();

  // แยก root vs sub
  final roots = all.where((e) => e.parentId == null).toList();
  final childMap = <int, List<MyMealIngredient>>{};
  for (final item in all.where((e) => e.parentId != null)) {
    childMap.putIfAbsent(item.parentId!, () => []).add(item);
  }

  return roots.map((root) => IngredientTreeNode(
    ingredient: root,
    children: childMap[root.id] ?? [],
  )).toList();
});

class IngredientTreeNode {
  final MyMealIngredient ingredient;
  final List<MyMealIngredient> children;
  
  IngredientTreeNode({required this.ingredient, required this.children});
  
  bool get isComposite => children.isNotEmpty;
}
```

---

## 6. UI Changes

### 6.1 GeminiAnalysisSheet — แสดง ingredient tree

**ไฟล์:** `lib/features/health/widgets/gemini_analysis_sheet.dart`

แก้จาก flat ListView เป็น expandable list:

```
┌─────────────────────────────────────┐
│ KFC Chicken Pop          300 kcal   │
├─────────────────────────────────────┤
│ ▼ Fried Batter Chicken    250 kcal  │  ← กดเพื่อขยาย
│   ├ Chicken Breast Meat   132 kcal  │  ← sub (สีจาง)
│   ├ Seasoned Flour Batter  48 kcal  │
│   └ Absorbed Frying Oil    70 kcal  │
│                                     │
│   Seasoning Powder          5 kcal  │  ← ไม่มี sub (ไม่มีลูกศร)
│                                     │
│ ▼ Dipping Sauce            45 kcal  │  ← กดเพื่อขยาย
│   ├ Chili Paste            10 kcal  │
│   ├ Sugar                  32 kcal  │
│   └ Vinegar & Garlic        3 kcal  │
└─────────────────────────────────────┘
```

### 6.2 CreateMealSheet — add sub-ingredients

เพิ่มปุ่ม "Add Sub-ingredient" ใต้แต่ละ ingredient row:

```
┌─────────────────────────────────────┐
│ Ingredient 1: [fried chicken breast]│
│   Amount: [120] [g]  Cal: [250]     │
│   [+ Add Sub-ingredient]            │
│   ├ Sub 1: [chicken breast]         │
│   │ Amount: [80] [g]  Cal: [132]    │
│   ├ Sub 2: [flour batter]           │
│   │ Amount: [25] [g]  Cal: [48]     │
│   └ Sub 3: [frying oil]             │
│     Amount: [8] [ml]  Cal: [70]     │
│                                     │
│ Ingredient 2: [dipping sauce]       │
│   Amount: [25] [ml]  Cal: [45]      │
│   [+ Add Sub-ingredient]            │
│                                     │
│ [+ Add Ingredient]                  │
├─────────────────────────────────────┤
│ Total: 300 kcal (ROOT items only)   │
└─────────────────────────────────────┘
```

### 6.3 FoodDetailBottomSheet / LogFromMealSheet

- แสดง ingredients tree แบบ read-only
- Expandable sections สำหรับ composite items
- Sub-ingredients แสดงด้วย indent + สีจางกว่า

---

## 7. ingredientsJson Snapshot Changes

`FoodEntry.ingredientsJson` จะเก็บ hierarchical format:

```json
[
  {
    "name": "Fried Batter Chicken Breast",
    "amount": 120, "unit": "g",
    "calories": 250, "protein": 17, "carbs": 14, "fat": 15,
    "sub_ingredients": [
      {"name": "Chicken Breast", "calories": 132, ...},
      {"name": "Flour Batter", "calories": 48, ...},
      {"name": "Frying Oil", "calories": 70, ...}
    ]
  },
  {
    "name": "Seasoning Powder",
    "amount": 3, "unit": "g",
    "calories": 5, ...
  }
]
```

**Backward compatible:** record เก่าไม่มี `sub_ingredients` → parse ได้ปกติ (null)

---

## 8. Backward Compatibility

### ✅ สิ่งที่ไม่พัง
| ส่วน | เหตุผล |
|------|--------|
| Isar DB | field ใหม่มี default → record เดิมทำงานปกติ |
| FoodEntry daily calories | ยังใช้ top-level calories เหมือนเดิม |
| ingredientsJson เดิม | parse ได้ → sub_ingredients = null |
| MyMeal.totalCalories | record เดิม = sum ของ flat ingredients (parentId=null ทั้งหมด) |
| ingredient search | ยังทำงานเหมือนเดิม |

### ⚠️ สิ่งที่ต้องระวัง
| ส่วน | วิธีจัดการ |
|------|----------|
| createMeal() | ต้อง handle ทั้ง flat (เดิม) และ nested (ใหม่) |
| GeminiAnalysisSheet | ต้อง handle IngredientDetail ทั้งแบบมีและไม่มี sub |
| Chat AI response | Backend prompt ต้องอัปเดตด้วย |

---

## 9. Implementation Phases

### Phase 1: Data Model + AI Prompt (ไม่กระทบ UI เดิม)
**Effort: ~2-3 ชม.**

1. **MyMealIngredient** — เพิ่ม `parentId`, `depth`, `isComposite`, `detail`
2. **IngredientDetail** — เพิ่ม `detail`, `subIngredients`
3. **MealIngredientInput** — เพิ่ม `detail`, `subIngredients`
4. Run `build_runner` เพื่อ generate Isar schema ใหม่

### Phase 2: AI Prompt Update
**Effort: ~1-2 ชม.**

1. **`_getImageAnalysisPrompt()`** — เพิ่ม hierarchy rules + example
2. **`_getTextAnalysisPrompt()`** — เพิ่ม hierarchy rules + example
3. **`buildChatPrompt()`** (backend) — เพิ่ม hierarchy rules + example

### Phase 3: Provider Logic
**Effort: ~2-3 ชม.**

1. **`createMeal()`** — recursive save ที่ handle sub-ingredients
2. **`updateMeal()`** — recursive update
3. **`saveIngredientsAndMeal()`** — parse sub_ingredients จาก AI response
4. **`mealIngredientTreeProvider`** — new provider สำหรับ tree query
5. ที่ทุกจุดที่เรียก `saveIngredientsAndMeal()` (chat, image, barcode, nutrition label, timeline)

### Phase 4: UI — Display (Read-only)
**Effort: ~3-4 ชม.**

1. **GeminiAnalysisSheet** — expandable ingredient list
2. **FoodDetailBottomSheet** — show hierarchy from ingredientsJson
3. **LogFromMealSheet** — show hierarchy
4. **IngredientCard widget** — update to handle nesting

### Phase 5: UI — Edit (Create/Update)
**Effort: ~3-4 ชม.**

1. **CreateMealSheet** — add sub-ingredient rows
2. **Edit existing meal** — load and edit tree structure

### รวม Effort: ~11-16 ชม. (2-3 วัน)

---

## 10. Files to Modify (Summary)

### Models (3 files)
| File | Change |
|------|--------|
| `lib/features/health/models/my_meal_ingredient.dart` | เพิ่ม parentId, depth, isComposite, detail |
| `lib/core/ai/gemini_service.dart` (IngredientDetail class) | เพิ่ม detail, subIngredients |
| `lib/features/health/providers/my_meal_provider.dart` (MealIngredientInput) | เพิ่ม detail, subIngredients |

### AI Prompts (2 files)
| File | Change |
|------|--------|
| `lib/core/ai/gemini_service.dart` (prompts) | เพิ่ม hierarchy rules ทั้ง image + text prompt |
| `functions/src/analyzeFood.ts` | เพิ่ม hierarchy rules ใน chat prompt |

### Providers (2 files)
| File | Change |
|------|--------|
| `lib/features/health/providers/my_meal_provider.dart` | createMeal, updateMeal → recursive |
| `lib/features/health/providers/health_provider.dart` | saveIngredientsAndMeal → parse subs |

### UI Widgets (4-5 files)
| File | Change |
|------|--------|
| `lib/features/health/widgets/gemini_analysis_sheet.dart` | Expandable ingredient tree |
| `lib/features/health/widgets/create_meal_sheet.dart` | Sub-ingredient editing |
| `lib/features/health/widgets/log_from_meal_sheet.dart` | Show hierarchy |
| `lib/features/health/widgets/food_detail_bottom_sheet.dart` | Show hierarchy |
| `lib/features/health/widgets/ingredient_card.dart` | Handle nesting display |

### Callers of saveIngredientsAndMeal (5 files)
| File | Change |
|------|--------|
| `lib/features/chat/providers/chat_provider.dart` | Pass sub_ingredients |
| `lib/features/health/presentation/image_analysis_preview_screen.dart` | Already passes raw data |
| `lib/features/health/presentation/health_timeline_tab.dart` | Already passes raw data |
| `lib/features/health/presentation/barcode_scanner_screen.dart` | Already passes raw data |
| `lib/features/health/presentation/nutrition_label_screen.dart` | Already passes raw data |

---

## 11. Testing Checklist

### Data Integrity
- [ ] Record เดิมยัง query ได้ปกติ (parentId=null = root)
- [ ] createMeal() สร้าง root + sub ถูกต้อง
- [ ] MyMeal.totalCalories = sum ของ ROOT เท่านั้น
- [ ] ingredientsJson snapshot มี sub_ingredients

### AI Response
- [ ] Text analysis "KFC Chicken Pop" → hierarchical ingredients
- [ ] Image analysis → hierarchical ingredients
- [ ] Chat "กินไก่ทอด 1 serving" → hierarchical ingredients
- [ ] Simple food (ข้าวเปล่า) → flat ingredients (no sub) ทำงานได้

### UI
- [ ] GeminiAnalysisSheet แสดง tree, expand/collapse ได้
- [ ] CreateMealSheet เพิ่ม/ลบ sub-ingredient ได้
- [ ] FoodDetailBottomSheet แสดง hierarchy
- [ ] Daily calories ไม่ double count

### Backward Compatibility
- [ ] เปิดแอปกับ DB เดิม → ไม่ crash
- [ ] FoodEntry เดิมที่มี flat ingredientsJson → แสดงได้ปกติ
- [ ] MyMeal เดิม (flat) → แก้ไข/log ได้ปกติ

---

## 12. Future Possibilities (หลัง implement)

1. **Smart Recognition**: AI จำกล่องขนมได้ → "นี่คือ 1/10 ของ Pocky Box ที่เคยสแกน"
2. **Ingredient Reuse**: เคย deconstruct "fried chicken breast" แล้ว → ครั้งหน้าใช้ซ้ำได้เลย
3. **Nutrition Education**: แสดงว่า "น้ำมันทอด" คิดเป็น 40% ของแคลทั้งหมด
4. **Recipe Builder**: ผู้ใช้สร้าง recipe แบบ nested → AI ช่วยคำนวณ
5. **Meal Comparison**: เปรียบเทียบ "ไก่ทอด" vs "ไก่นึ่ง" → เห็นว่าน้ำมันทอดต่างกันมาก
