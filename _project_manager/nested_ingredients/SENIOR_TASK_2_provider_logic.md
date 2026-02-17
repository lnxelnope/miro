# 🧩 SENIOR TASK 2: Provider Logic (Recursive Save)

> **ระดับความยาก:** 🔴 Senior (ยากมาก — ต้องเข้าใจ recursive logic)  
> **เวลาประมาณ:** 3-4 ชั่วโมง  
> **ความรู้ที่ต้องมี:** Recursion, Isar database, Provider pattern, async/await

---

## 🎯 เป้าหมาย

แก้ provider logic ให้รองรับการ save/update nested ingredients แบบ recursive

---

## 📍 ไฟล์ที่ต้องแก้

1. **`lib/features/health/providers/my_meal_provider.dart`** — createMeal(), updateMeal()
2. **`lib/features/health/providers/health_provider.dart`** — saveIngredientsAndMeal()
3. **New Provider** — mealIngredientTreeProvider (query tree structure)

---

## ⚠️ Critical Requirements

### 1. Backward Compatibility

**ต้องรองรับ:**
- ✅ Flat ingredients (เดิม) — `parentId = null` ทั้งหมด
- ✅ Nested ingredients (ใหม่) — มีทั้ง `parentId = null` (root) และ `parentId != null` (sub)

**ห้าม:**
- ❌ ทำให้ record เดิมพัง
- ❌ เปลี่ยน calorie counting logic สำหรับ flat ingredients
- ❌ Force migration

---

### 2. Calorie Counting Rules

```dart
// CRITICAL: คำนวณ total จาก ROOT ingredients เท่านั้น
double totalCalories = 0;
for (final ing in rootIngredients) {  // parentId == null
  totalCalories += ing.calories;
}
// SUB ingredients (parentId != null) ไม่นับ!
```

---

## 📋 Implementation Steps

### Phase 1: Helper Method — Recursive Save

**ไฟล์:** `lib/features/health/providers/my_meal_provider.dart`

**สร้าง private method ใหม่:**

```dart
/// Save ingredient และ sub-ingredients แบบ recursive
/// Returns: MyMealIngredient ที่ save แล้ว (parent)
Future<MyMealIngredient> _saveMealIngredient({
  required MyMeal meal,
  required MealIngredientInput input,
  required int? parentId,      // null = root level
  required int depth,           // 0 = root, 1 = sub, 2 = sub-sub
  required int sortOrder,
}) async {
  // 1. สร้าง MyMealIngredient จาก input
  final ingredient = MyMealIngredient()
    ..myMealId = meal.id
    ..ingredientId = 0  // TODO: lookup from Ingredient table (optional)
    ..ingredientName = input.name
    ..amount = input.amount
    ..unit = input.unit
    ..calories = input.calories
    ..protein = input.protein
    ..carbs = input.carbs
    ..fat = input.fat
    ..parentId = parentId           // NEW
    ..depth = depth                 // NEW
    ..isComposite = false           // จะ update ทีหลังถ้ามี sub
    ..detail = input.detail         // NEW
    ..sortOrder = sortOrder;

  // 2. Save parent ก่อน (ต้องได้ id มาก่อน)
  await DatabaseService.isar.writeTxn(() async {
    await DatabaseService.myMealIngredients.put(ingredient);
  });

  // 3. ถ้ามี sub-ingredients → save recursively
  if (input.subIngredients != null && input.subIngredients!.isNotEmpty) {
    int subSortOrder = sortOrder + 1;
    
    for (final subInput in input.subIngredients!) {
      await _saveMealIngredient(
        meal: meal,
        input: subInput,
        parentId: ingredient.id,     // link to parent
        depth: depth + 1,             // increase depth
        sortOrder: subSortOrder,
      );
      subSortOrder++;
    }

    // 4. Mark parent as composite
    ingredient.isComposite = true;
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.myMealIngredients.put(ingredient);
    });
  }

  return ingredient;
}
```

**คำอธิบาย:**
1. สร้าง ingredient object
2. Save ลง DB เพื่อได้ ID
3. ถ้ามี sub → เรียก recursive
4. Mark parent เป็น composite

---

### Phase 2: แก้ createMeal() — ใช้ recursive helper

**ไฟล์:** `lib/features/health/providers/my_meal_provider.dart`

**หา method:** `Future<MyMeal> createMeal({...})`

**เดิม (flat save):**

```dart
Future<MyMeal> createMeal({
  required String mealName,
  required DateTime timestamp,
  required MealType mealType,
  required List<MealIngredientInput> ingredients,
  ...
}) async {
  // คำนวณ total
  double totalCal = 0, totalP = 0, totalC = 0, totalF = 0;
  for (final ing in ingredients) {
    totalCal += ing.calories;
    totalP += ing.protein;
    totalC += ing.carbs;
    totalF += ing.fat;
  }

  // สร้าง MyMeal
  final meal = MyMeal() ...;
  await DatabaseService.isar.writeTxn(() async {
    await DatabaseService.myMeals.put(meal);
  });

  // Save ingredients (flat)
  for (var i = 0; i < ingredients.length; i++) {
    final ing = ingredients[i];
    final mealIng = MyMealIngredient()
      ..myMealId = meal.id
      ..ingredientName = ing.name
      ..calories = ing.calories
      ...
      ..sortOrder = i;
    
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.myMealIngredients.put(mealIng);
    });
  }

  return meal;
}
```

**ใหม่ (nested save):**

```dart
Future<MyMeal> createMeal({
  required String mealName,
  required DateTime timestamp,
  required MealType mealType,
  required List<MealIngredientInput> ingredients,
  ...
}) async {
  // คำนวณ total จาก ROOT ingredients เท่านั้น
  // (SUB ingredients อยู่ใน input.subIngredients ไม่นับ)
  double totalCal = 0, totalP = 0, totalC = 0, totalF = 0;
  for (final ing in ingredients) {
    totalCal += ing.calories;  // ROOT only
    totalP += ing.protein;
    totalC += ing.carbs;
    totalF += ing.fat;
  }

  // สร้าง MyMeal (เหมือนเดิม)
  final meal = MyMeal()
    ..name = mealName
    ..timestamp = timestamp
    ..mealType = mealType
    ..totalCalories = totalCal
    ..totalProtein = totalP
    ..totalCarbs = totalC
    ..totalFat = totalF
    ...;
  
  await DatabaseService.isar.writeTxn(() async {
    await DatabaseService.myMeals.put(meal);
  });

  // Save ingredients แบบ recursive (NEW)
  int sortIndex = 0;
  for (final input in ingredients) {
    final savedRoot = await _saveMealIngredient(
      meal: meal,
      input: input,
      parentId: null,       // ROOT
      depth: 0,
      sortOrder: sortIndex,
    );
    
    // ถ้ามี sub-ingredients จะถูก save ด้วยใน _saveMealIngredient()
    // sortIndex ต้องเพิ่มตามจำนวน sub ด้วย
    if (input.subIngredients != null) {
      sortIndex += input.subIngredients!.length;
    }
    sortIndex++;
  }

  return meal;
}
```

---

### Phase 3: แก้ saveIngredientsAndMeal() — parse sub_ingredients

**ไฟล์:** `lib/features/health/providers/health_provider.dart`

**หา method:** `Future<void> saveIngredientsAndMeal({...})`

**เดิม:**

```dart
Future<void> saveIngredientsAndMeal({
  required List<Map<String, dynamic>> ingredientsData,
  ...
}) async {
  final inputs = ingredientsData.map((data) {
    return MealIngredientInput(
      name: data['name'] as String,
      nameEn: data['name_en'] as String?,
      amount: (data['amount'] as num).toDouble(),
      unit: data['unit'] as String,
      calories: (data['calories'] as num).toDouble(),
      protein: (data['protein'] as num).toDouble(),
      carbs: (data['carbs'] as num).toDouble(),
      fat: (data['fat'] as num).toDouble(),
    );
  }).toList();

  await ref.read(myMealProvider.notifier).createMeal(...);
}
```

**ใหม่ (parse recursive):**

```dart
Future<void> saveIngredientsAndMeal({
  required List<Map<String, dynamic>> ingredientsData,
  ...
}) async {
  // Helper function: parse ingredient แบบ recursive
  MealIngredientInput _parseIngredient(Map<String, dynamic> data) {
    // Parse sub_ingredients ถ้ามี
    List<MealIngredientInput>? subs;
    final subList = data['sub_ingredients'] as List<dynamic>?;
    if (subList != null && subList.isNotEmpty) {
      subs = subList.map((s) => _parseIngredient(s as Map<String, dynamic>)).toList();
    }

    return MealIngredientInput(
      name: data['name'] as String,
      nameEn: data['name_en'] as String?,
      detail: data['detail'] as String?,           // NEW
      amount: (data['amount'] as num).toDouble(),
      unit: data['unit'] as String,
      calories: (data['calories'] as num).toDouble(),
      protein: (data['protein'] as num).toDouble(),
      carbs: (data['carbs'] as num).toDouble(),
      fat: (data['fat'] as num).toDouble(),
      subIngredients: subs,                        // NEW
    );
  }

  // Parse all ROOT ingredients
  final inputs = ingredientsData.map((data) => _parseIngredient(data)).toList();

  // สร้าง meal (createMeal จะ handle nested save)
  await ref.read(myMealProvider.notifier).createMeal(
    mealName: mealName,
    timestamp: timestamp,
    mealType: mealType,
    ingredients: inputs,
    ...
  );
}
```

**คำอธิบาย:**
- สร้าง helper function `_parseIngredient()` ที่เรียก recursive
- Parse `sub_ingredients` จาก JSON
- ส่ง nested `MealIngredientInput` ไปให้ `createMeal()`

---

### Phase 4: New Provider — Tree Query

**ไฟล์:** `lib/features/health/providers/my_meal_provider.dart` (เพิ่มท้ายไฟล์)

```dart
/// ดึง ingredients ของ meal เป็น tree structure (ROOT + children)
final mealIngredientTreeProvider = FutureProvider.autoDispose
    .family<List<IngredientTreeNode>, int>((ref, mealId) async {
  // Query all ingredients ของ meal นี้
  final allIngredients = await DatabaseService.myMealIngredients
      .filter()
      .myMealIdEqualTo(mealId)
      .sortBySortOrder()
      .findAll();

  // แยก root vs sub
  final roots = allIngredients.where((e) => e.parentId == null).toList();
  
  // สร้าง map: parentId → List<children>
  final childMap = <int, List<MyMealIngredient>>{};
  for (final item in allIngredients.where((e) => e.parentId != null)) {
    childMap.putIfAbsent(item.parentId!, () => []).add(item);
  }

  // สร้าง tree nodes
  return roots.map((root) {
    return IngredientTreeNode(
      ingredient: root,
      children: childMap[root.id] ?? [],
    );
  }).toList();
});

/// Tree node สำหรับแสดง hierarchical ingredients
class IngredientTreeNode {
  final MyMealIngredient ingredient;
  final List<MyMealIngredient> children;
  
  IngredientTreeNode({
    required this.ingredient,
    required this.children,
  });
  
  bool get isComposite => children.isNotEmpty;
  
  /// Total calories รวม children (สำหรับ validation)
  double get totalCaloriesWithChildren {
    return ingredient.calories + 
           children.fold<double>(0, (sum, child) => sum + child.calories);
  }
}
```

**การใช้งาน (ตัวอย่าง):**

```dart
// ใน UI widget
final tree = ref.watch(mealIngredientTreeProvider(mealId));

tree.when(
  data: (nodes) {
    return ListView.builder(
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        final node = nodes[index];
        return Column(
          children: [
            // แสดง ROOT ingredient
            IngredientCard(
              ingredient: node.ingredient,
              depth: 0,
            ),
            // แสดง SUB ingredients (ถ้ามี)
            ...node.children.map((child) => IngredientCard(
              ingredient: child,
              depth: 1,
            )),
          ],
        );
      },
    );
  },
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
);
```

---

### Phase 5: updateMeal() — Recursive Update

**ไฟล์:** `lib/features/health/providers/my_meal_provider.dart`

**Strategy:**
1. ลบ ingredients เดิมทั้งหมดของ meal นี้
2. Save ใหม่ทั้งหมด (ใช้ `_saveMealIngredient` recursive)

**เหตุผล:** 
- ง่ายกว่า diff + update แบบ smart
- ไม่มี orphan records (sub ที่ parent ถูกลบ)

```dart
Future<void> updateMeal({
  required int mealId,
  String? mealName,
  List<MealIngredientInput>? ingredients,
  ...
}) async {
  // 1. Query meal เดิม
  final meal = await DatabaseService.myMeals.get(mealId);
  if (meal == null) throw Exception('Meal not found');

  // 2. ถ้ามีการแก้ ingredients
  if (ingredients != null) {
    // ลบ ingredients เดิมทั้งหมด
    final oldIngredients = await DatabaseService.myMealIngredients
        .filter()
        .myMealIdEqualTo(mealId)
        .findAll();
    
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.myMealIngredients.deleteAll(
        oldIngredients.map((e) => e.id).toList()
      );
    });

    // คำนวณ total ใหม่ (จาก ROOT เท่านั้น)
    double totalCal = 0, totalP = 0, totalC = 0, totalF = 0;
    for (final ing in ingredients) {
      totalCal += ing.calories;
      totalP += ing.protein;
      totalC += ing.carbs;
      totalF += ing.fat;
    }

    // อัปเดต meal
    meal.totalCalories = totalCal;
    meal.totalProtein = totalP;
    meal.totalCarbs = totalC;
    meal.totalFat = totalF;

    // Save ingredients ใหม่ (recursive)
    int sortIndex = 0;
    for (final input in ingredients) {
      await _saveMealIngredient(
        meal: meal,
        input: input,
        parentId: null,
        depth: 0,
        sortOrder: sortIndex++,
      );
    }
  }

  // 3. อัปเดต meal fields อื่นๆ (ถ้ามี)
  if (mealName != null) meal.name = mealName;
  // ... other fields

  // 4. Save meal
  await DatabaseService.isar.writeTxn(() async {
    await DatabaseService.myMeals.put(meal);
  });
}
```

---

## 🧪 Testing Strategy

### 1. Unit Tests

**Test Case 1: Flat ingredients (backward compat)**

```dart
test('createMeal with flat ingredients should work as before', () async {
  final inputs = [
    MealIngredientInput(name: 'Rice', calories: 200, ...),
    MealIngredientInput(name: 'Chicken', calories: 150, ...),
  ];

  final meal = await provider.createMeal(ingredients: inputs, ...);

  // ตรวจสอบ total
  expect(meal.totalCalories, 350);

  // ตรวจสอบว่า ingredient ทั้งหมดเป็น root (parentId = null)
  final saved = await db.myMealIngredients.filter().myMealIdEqualTo(meal.id).findAll();
  expect(saved.every((e) => e.parentId == null), true);
  expect(saved.every((e) => e.depth == 0), true);
});
```

**Test Case 2: Nested ingredients**

```dart
test('createMeal with nested ingredients should save recursively', () async {
  final inputs = [
    MealIngredientInput(
      name: 'Fried Chicken',
      calories: 250,
      subIngredients: [
        MealIngredientInput(name: 'Chicken', calories: 132, ...),
        MealIngredientInput(name: 'Flour', calories: 48, ...),
        MealIngredientInput(name: 'Oil', calories: 70, ...),
      ],
      ...
    ),
  ];

  final meal = await provider.createMeal(ingredients: inputs, ...);

  // ตรวจสอบ total = ROOT only
  expect(meal.totalCalories, 250);

  // ตรวจสอบ structure
  final saved = await db.myMealIngredients.filter().myMealIdEqualTo(meal.id).findAll();
  final root = saved.where((e) => e.parentId == null).single;
  expect(root.ingredientName, 'Fried Chicken');
  expect(root.isComposite, true);
  expect(root.depth, 0);

  final subs = saved.where((e) => e.parentId == root.id).toList();
  expect(subs.length, 3);
  expect(subs.every((e) => e.depth == 1), true);
  
  // ตรวจสอบ calorie sum
  final subSum = subs.fold<double>(0, (sum, e) => sum + e.calories);
  expect((subSum - root.calories).abs() < 1, true);
});
```

**Test Case 3: Tree provider**

```dart
test('mealIngredientTreeProvider should return hierarchical structure', () async {
  // สร้าง meal with nested ingredients
  final meal = await createTestMeal();

  // Query tree
  final container = ProviderContainer();
  final tree = await container.read(mealIngredientTreeProvider(meal.id).future);

  // ตรวจสอบ structure
  expect(tree.length, 1);  // 1 ROOT
  expect(tree.first.children.length, 3);  // 3 SUB
  expect(tree.first.isComposite, true);
});
```

---

### 2. Integration Tests

**Test Scenario: Image → Parse → Save → Query**

```dart
testWidgets('End-to-end: AI response → nested ingredients', (tester) async {
  // 1. Mock AI response
  final aiResponse = {
    "ingredients_detail": [
      {
        "name": "Fried Chicken",
        "calories": 250,
        "sub_ingredients": [
          {"name": "Chicken", "calories": 132},
          {"name": "Flour", "calories": 48},
          {"name": "Oil", "calories": 70},
        ]
      }
    ]
  };

  // 2. Parse & save
  await ref.read(healthProvider.notifier).saveIngredientsAndMeal(
    ingredientsData: aiResponse['ingredients_detail'],
    ...
  );

  // 3. Query meal
  final meals = await db.myMeals.where().findAll();
  expect(meals.length, 1);
  expect(meals.first.totalCalories, 250);  // ROOT only

  // 4. Query ingredients tree
  final tree = await ref.read(mealIngredientTreeProvider(meals.first.id).future);
  expect(tree.first.children.length, 3);
});
```

---

## ⚠️ Common Pitfalls

### 1. Orphan Records

**ปัญหา:** ลบ parent แต่ลืมลบ children → orphan records

**แก้:**

```dart
// เมื่อลบ meal
Future<void> deleteMeal(int mealId) async {
  // ลบ ingredients ทั้งหมด (รวม children)
  final allIngredients = await db.myMealIngredients
      .filter()
      .myMealIdEqualTo(mealId)
      .findAll();
  
  await db.writeTxn(() async {
    await db.myMealIngredients.deleteAll(allIngredients.map((e) => e.id).toList());
    await db.myMeals.delete(mealId);
  });
}
```

### 2. sortOrder Conflicts

**ปัญหา:** ROOT กับ SUB ใช้ sortOrder ชนกัน

**แก้:** ใช้ strategy แบบนี้

```dart
// ROOT: 0, 100, 200, 300, ...
// SUB of ROOT 0: 1, 2, 3, ...
// SUB of ROOT 100: 101, 102, 103, ...

int sortIndex = 0;
for (final input in ingredients) {
  final baseSort = sortIndex * 100;  // ROOT: 0, 100, 200, ...
  
  await _saveMealIngredient(
    meal: meal,
    input: input,
    parentId: null,
    depth: 0,
    sortOrder: baseSort,
  );
  
  // SUB: baseSort + 1, baseSort + 2, ...
  if (input.subIngredients != null) {
    for (var i = 0; i < input.subIngredients!.length; i++) {
      await _saveMealIngredient(
        meal: meal,
        input: input.subIngredients![i],
        parentId: parentEntry.id,
        depth: 1,
        sortOrder: baseSort + i + 1,
      );
    }
  }
  
  sortIndex++;
}
```

### 3. Double Counting ใน UI

**ปัญหา:** UI sum ทั้ง ROOT และ SUB

**แก้:** เช็ค `parentId` ก่อน sum

```dart
double calculateTotalCalories(List<MyMealIngredient> ingredients) {
  return ingredients
      .where((ing) => ing.parentId == null)  // ROOT only
      .fold<double>(0, (sum, ing) => sum + ing.calories);
}
```

---

## 📊 Performance Considerations

### Query Optimization

```dart
// ❌ ช้า: query แยกสำหรับแต่ละ parent
for (final root in roots) {
  final children = await db.myMealIngredients
      .filter()
      .parentIdEqualTo(root.id)
      .findAll();
}

// ✅ เร็ว: query ครั้งเดียว แล้ว group ใน memory
final allIngredients = await db.myMealIngredients
    .filter()
    .myMealIdEqualTo(mealId)
    .findAll();

final childMap = <int, List<MyMealIngredient>>{};
for (final item in allIngredients.where((e) => e.parentId != null)) {
  childMap.putIfAbsent(item.parentId!, () => []).add(item);
}
```

---

## ✅ Success Criteria

- [ ] createMeal() รองรับทั้ง flat และ nested
- [ ] Backward compatible กับ data เดิม
- [ ] Calorie counting ถูกต้อง (ROOT only)
- [ ] Tree provider ทำงานได้
- [ ] updateMeal() handle nested ได้
- [ ] deleteMeal() ไม่มี orphan records
- [ ] Unit tests ผ่านหมด (flat + nested + tree)
- [ ] Integration test ผ่าน (AI → save → query)

---

## 🔜 Next Steps

**เมื่อทำเสร็จ:**
- Junior สามารถทำ `JUNIOR_TASK_3_ui_ingredient_card.md` ได้แล้ว
- → `SENIOR_TASK_3_ui_expandable.md`

**Dependencies:**
- ✅ SENIOR_TASK_1 (AI prompts) — ไม่จำเป็นต้องเสร็จก่อน (แต่ควรทำคู่กัน)

---

## 🆘 ถ้าติดปัญหา

1. **Recursion ทำให้สับสน:** วาดดูบน whiteboard (tree diagram)
2. **sortOrder ซ้ำ:** ใช้ strategy baseSort * 100
3. **Orphan records:** เขียน migration script เพื่อ cleanup
4. **Performance ช้า:** ใช้ single query + in-memory grouping
5. **Tests ไม่ผ่าน:** debug ทีละ test case, ใช้ print() ดู structure

---

**หมายเหตุ:** Task นี้เป็น core logic ที่ซับซ้อนที่สุด ต้องทดสอบอย่างละเอียด ทำ TDD (Test-Driven Development) จะช่วยได้มาก!
