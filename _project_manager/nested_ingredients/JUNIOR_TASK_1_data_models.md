# 📦 JUNIOR TASK 1: เพิ่ม Fields ใน Data Models

> **ระดับความยาก:** 🟢 Junior (ง่าย)  
> **เวลาประมาณ:** 30-45 นาที  
> **ความรู้ที่ต้องมี:** Dart basics, class properties

---

## 🎯 เป้าหมาย

เพิ่ม fields ใหม่เข้าไปใน 3 models เพื่อรองรับ nested ingredients

---

## 📋 ขั้นตอนการทำ (ทำตามลำดับ)

### ✅ Step 1: เปิดไฟล์ `my_meal_ingredient.dart`

**ไฟล์:** `lib/features/health/models/my_meal_ingredient.dart`

1. เปิดไฟล์นี้ใน VS Code
2. หาบรรทัดที่มี `int sortOrder = 0;`
3. พร้อมที่จะเพิ่ม code ด้านล่างต่อ

---

### ✅ Step 2: เพิ่ม 4 fields ใหม่

**วางโค้ดนี้ต่อจาก `int sortOrder = 0;`**

```dart
  // ===== NEW: Nested/Sub-division fields =====
  
  /// Parent ingredient ID (null = root level, counted in total)
  int? parentId;
  
  /// Nesting depth (0 = root, 1 = sub-ingredient, 2 = sub-sub, etc.)
  int depth = 0;
  
  /// Whether this item has children (for quick checks without querying)
  bool isComposite = false;
  
  /// Detail/description about preparation or composition
  String? detail;
```

**คำอธิบาย:**
- `parentId` — ถ้าเป็น `null` แปลว่าเป็น ingredient หลัก, ถ้ามีค่าแปลว่าเป็น sub-ingredient ของ parent นั้น
- `depth` — ระดับความลึก (0 = หลัก, 1 = ลูก, 2 = หลาน)
- `isComposite` — บอกว่า ingredient นี้มีลูกหรือไม่ (เพื่อไม่ต้อง query database)
- `detail` — คำอธิบายเพิ่มเติม เช่น "Deep-fried with batter"

---

### ✅ Step 3: ตรวจสอบว่าเพิ่มครบหรือยัง

เมื่อเพิ่มเสร็จแล้ว ไฟล์ควรมีหน้าตาแบบนี้:

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

---

### ✅ Step 4: เปิดไฟล์ `gemini_service.dart` (ส่วน IngredientDetail)

**ไฟล์:** `lib/core/ai/gemini_service.dart`

1. กด `Ctrl+F` แล้วค้นหา `class IngredientDetail`
2. จะเจอคลาสที่มีหน้าตาประมาณนี้:

```dart
class IngredientDetail {
  final String name;
  final String? nameEn;
  final double amount;
  final String unit;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  
  // ... constructor
}
```

---

### ✅ Step 5: เพิ่ม 2 fields ใหม่ใน IngredientDetail

**เพิ่มบรรทัดนี้หลังจาก `final String? nameEn;`**

```dart
  final String? detail;           // NEW
```

**เพิ่มบรรทัดนี้หลังจาก `final double fat;`**

```dart
  final List<IngredientDetail>? subIngredients;  // NEW: recursive
```

เมื่อเสร็จแล้วจะได้แบบนี้:

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
  
  // ... constructor
}
```

---

### ✅ Step 6: แก้ constructor ของ IngredientDetail

**หา constructor (มีหน้าตาแบบนี้):**

```dart
IngredientDetail({
  required this.name,
  this.nameEn,
  required this.amount,
  required this.unit,
  required this.calories,
  required this.protein,
  required this.carbs,
  required this.fat,
});
```

**เพิ่ม 2 บรรทัดนี้เข้าไป:**

```dart
IngredientDetail({
  required this.name,
  this.nameEn,
  this.detail,                    // NEW
  required this.amount,
  required this.unit,
  required this.calories,
  required this.protein,
  required this.carbs,
  required this.fat,
  this.subIngredients,            // NEW
});
```

---

### ✅ Step 7: แก้ fromJson method

**หา method `factory IngredientDetail.fromJson(...)`**

มันจะมีหน้าตาแบบนี้:

```dart
factory IngredientDetail.fromJson(Map<String, dynamic> json) {
  return IngredientDetail(
    name: json['name'] ?? '',
    nameEn: json['name_en'],
    amount: (json['amount'] ?? 0).toDouble(),
    unit: json['unit'] ?? 'g',
    calories: (json['calories'] ?? 0).toDouble(),
    protein: (json['protein'] ?? 0).toDouble(),
    carbs: (json['carbs'] ?? 0).toDouble(),
    fat: (json['fat'] ?? 0).toDouble(),
  );
}
```

**เพิ่ม 2 บรรทัดนี้:**

```dart
factory IngredientDetail.fromJson(Map<String, dynamic> json) {
  return IngredientDetail(
    name: json['name'] ?? '',
    nameEn: json['name_en'],
    detail: json['detail'],                    // NEW — เพิ่มบรรทัดนี้
    amount: (json['amount'] ?? 0).toDouble(),
    unit: json['unit'] ?? 'g',
    calories: (json['calories'] ?? 0).toDouble(),
    protein: (json['protein'] ?? 0).toDouble(),
    carbs: (json['carbs'] ?? 0).toDouble(),
    fat: (json['fat'] ?? 0).toDouble(),
    subIngredients: json['sub_ingredients'] != null   // NEW — เพิ่มทั้งส่วนนี้
        ? (json['sub_ingredients'] as List)
            .map((e) => IngredientDetail.fromJson(e))
            .toList()
        : null,
  );
}
```

---

### ✅ Step 8: เปิดไฟล์ `my_meal_provider.dart` (ส่วน MealIngredientInput)

**ไฟล์:** `lib/features/health/providers/my_meal_provider.dart`

1. กด `Ctrl+F` แล้วค้นหา `class MealIngredientInput`
2. จะเจอคลาสที่มีหน้าตาประมาณนี้:

```dart
class MealIngredientInput {
  final String name;
  final String? nameEn;
  final double amount;
  final String unit;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  
  MealIngredientInput({...});
}
```

---

### ✅ Step 9: เพิ่ม 2 fields ใหม่ใน MealIngredientInput

**เพิ่มหลังจาก `final String? nameEn;`**

```dart
  final String? detail;                              // NEW
```

**เพิ่มหลังจาก `final double fat;`**

```dart
  final List<MealIngredientInput>? subIngredients;   // NEW: recursive
```

เมื่อเสร็จแล้วจะได้แบบนี้:

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
  
  MealIngredientInput({...});
}
```

---

### ✅ Step 10: แก้ constructor ของ MealIngredientInput

**หา constructor แล้วเพิ่ม 2 บรรทัดนี้:**

```dart
MealIngredientInput({
  required this.name,
  this.nameEn,
  this.detail,              // NEW
  required this.amount,
  required this.unit,
  required this.calories,
  required this.protein,
  required this.carbs,
  required this.fat,
  this.subIngredients,      // NEW
});
```

---

## ✅ การตรวจสอบว่าทำถูกต้อง

### 1. ตรวจไฟล์ทั้ง 3 อีกครั้ง

- [ ] `my_meal_ingredient.dart` — มี `parentId`, `depth`, `isComposite`, `detail`
- [ ] `gemini_service.dart` (IngredientDetail) — มี `detail`, `subIngredients` + fromJson ครบ
- [ ] `my_meal_provider.dart` (MealIngredientInput) — มี `detail`, `subIngredients`

### 2. Save ไฟล์ทั้ง 3

กด `Ctrl+S` ในแต่ละไฟล์

### 3. ดูว่ามี error แดงๆ ไหม

ถ้ามี error แดงๆ ใน VS Code:
- อ่านข้อความ error
- ตรวจสอบว่าคัดลอกโค้ดถูกต้องหรือไม่
- ดูว่าลืม comma (`,`) หรือไม่

---

## ⚠️ ข้อผิดพลาดที่พบบ่อย

### ❌ ลืมใส่ comma (`,`) หลัง field

```dart
final String? detail              // ❌ ลืม comma
final double amount;
```

**แก้:**

```dart
final String? detail,             // ✅ มี comma
final double amount,
```

### ❌ เพิ่ม field ผิดที่

ต้องเพิ่ม `detail` **หลังจาก** `nameEn`  
ต้องเพิ่ม `subIngredients` **หลังจาก** `fat`

### ❌ ลืมเพิ่มใน constructor

เพิ่ม field แล้วต้องเพิ่มใน constructor ด้วย!

---

## ✅ เมื่อทำเสร็จ

**ไปต่อที่:** `JUNIOR_TASK_2_build_runner.md`

---

## 🆘 ถ้าติดปัญหา

1. อ่านขั้นตอนใหม่อีกครั้งช้าๆ
2. ตรวจสอบว่าทำครบทุก Step หรือยัง
3. ถ้ายังไม่ได้ → copy error message ทั้งหมดมาถามพี่
4. **อย่า** พยายาม fix เองถ้าไม่เข้าใจ error

---

**หมายเหตุ:** Task นี้เป็นแค่การเพิ่ม fields ไม่มีอะไรซับซ้อน ทำตามขั้นตอนไปทีละข้อ อย่ารีบ!
