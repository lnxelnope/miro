# 🎨 JUNIOR TASK 3: แก้ UI Ingredient Card Widget

> **ระดับความยาก:** 🟢 Junior (ปานกลาง)  
> **เวลาประมาณ:** 45-60 นาที  
> **ความรู้ที่ต้องมี:** Flutter widgets, Text, Padding, Container

---

## 🎯 เป้าหมาย

แก้ไข `IngredientCard` widget ให้แสดง:
1. Detail text (ถ้ามี)
2. Visual indicator สำหรับ sub-ingredients (ใช้ indent + สีต่างกัน)

---

## ⚠️ ก่อนเริ่ม

**ต้องรอให้ Senior ทำเสร็จก่อน:**
- ✅ SENIOR_TASK_2 (Provider Logic)

**ถ้ายังไม่เสร็จ → ห้ามทำ Task นี้**

---

## 📋 ขั้นตอนการทำ (ทำตามลำดับ)

### ✅ Step 1: เปิดไฟล์ `ingredient_card.dart`

**ไฟล์:** `lib/features/health/widgets/ingredient_card.dart`

1. เปิดไฟล์นี้ใน VS Code
2. ดูโครงสร้างโค้ดคร่าวๆ ก่อน

---

### ✅ Step 2: เพิ่ม parameter `depth` และ `detail` เข้า widget

**หา class `IngredientCard`:**

```dart
class IngredientCard extends StatelessWidget {
  final MyMealIngredient ingredient;
  // ... other properties
  
  const IngredientCard({
    Key? key,
    required this.ingredient,
    // ...
  }) : super(key: key);
```

**เพิ่ม 2 properties นี้:**

```dart
class IngredientCard extends StatelessWidget {
  final MyMealIngredient ingredient;
  final int depth;           // NEW — เพิ่มบรรทัดนี้
  final String? detail;      // NEW — เพิ่มบรรทัดนี้
  // ... other properties
  
  const IngredientCard({
    Key? key,
    required this.ingredient,
    this.depth = 0,          // NEW — เพิ่มบรรทัดนี้
    this.detail,             // NEW — เพิ่มบรรทัดนี้
    // ...
  }) : super(key: key);
```

**คำอธิบาย:**
- `depth` — ระดับความลึก (0 = root, 1 = sub, 2 = sub-sub)
- `detail` — คำอธิบายเพิ่มเติม (nullable)

---

### ✅ Step 3: เพิ่ม padding ตาม depth

**หา method `build()` ที่ return Widget:**

```dart
@override
Widget build(BuildContext context) {
  return Container(
    // ...
  );
}
```

**เพิ่ม horizontal padding ตาม depth:**

```dart
@override
Widget build(BuildContext context) {
  // คำนวณ indent สำหรับ sub-ingredients
  final double indent = depth * 16.0;  // NEW — เพิ่มบรรทัดนี้
  
  return Padding(                       // NEW — wrap ด้วย Padding
    padding: EdgeInsets.only(left: indent),  // NEW
    child: Container(                   // เดิม
      // ... code เดิม
    ),
  );
}
```

**คำอธิบาย:**
- `depth = 0` → indent = 0 (ไม่เยื้อง)
- `depth = 1` → indent = 16 (เยื้อง 16 pixels)
- `depth = 2` → indent = 32 (เยื้อง 32 pixels)

---

### ✅ Step 4: เปลี่ยนสี background ตาม depth

**หา Container ที่มี `decoration`:**

```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,  // หรือสีอื่นๆ
    // ...
  ),
  // ...
)
```

**เปลี่ยนเป็น:**

```dart
Container(
  decoration: BoxDecoration(
    color: depth == 0 
        ? Colors.white          // ROOT: สีขาว
        : Colors.grey[50],      // SUB: สีเทาอ่อน
    // ... rest of decoration
  ),
  // ...
)
```

---

### ✅ Step 5: เปลี่ยนขนาดตัวอักษรตาม depth

**หา Text widget ที่แสดงชื่อ ingredient:**

```dart
Text(
  ingredient.ingredientName,
  style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  ),
)
```

**เปลี่ยนเป็น:**

```dart
Text(
  ingredient.ingredientName,
  style: TextStyle(
    fontSize: depth == 0 ? 16 : 14,      // ROOT: 16, SUB: 14
    fontWeight: depth == 0 
        ? FontWeight.w600                // ROOT: bold
        : FontWeight.w400,               // SUB: normal
    color: depth == 0 
        ? Colors.black87                 // ROOT: เข้ม
        : Colors.black54,                // SUB: จาง
  ),
)
```

---

### ✅ Step 6: เพิ่ม detail text (ถ้ามี)

**หาที่ที่แสดง ingredient name, amount, calories:**

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(ingredient.ingredientName, ...),  // ชื่อ
    Text('${ingredient.amount} ${ingredient.unit}', ...),  // ปริมาณ
    // ...
  ],
)
```

**เพิ่ม detail text ถ้ามี:**

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(ingredient.ingredientName, ...),  // ชื่อ
    Text('${ingredient.amount} ${ingredient.unit}', ...),  // ปริมาณ
    
    // NEW — เพิ่มส่วนนี้
    if (detail != null && detail!.isNotEmpty)
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          detail!,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    // END NEW
  ],
)
```

**คำอธิบาย:**
- ตรวจสอบว่า detail มีค่าหรือไม่ (`if (detail != null)`)
- ถ้ามี → แสดง text สีเทา ตัวเอียง
- จำกัด 2 บรรทัด (`maxLines: 2`)

---

### ✅ Step 7: เพิ่ม visual indicator สำหรับ sub-ingredients

**เพิ่ม vertical line ทางซ้าย:**

```dart
@override
Widget build(BuildContext context) {
  final double indent = depth * 16.0;
  
  return Padding(
    padding: EdgeInsets.only(left: indent),
    child: Row(                           // NEW — wrap ด้วย Row
      children: [
        // NEW — เส้นแนวตั้งสำหรับ sub
        if (depth > 0)
          Container(
            width: 2,
            height: 50,  // adjust ตามขนาด card
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        
        Expanded(                         // NEW
          child: Container(               // code เดิม
            // ... existing container code
          ),
        ),
      ],
    ),
  );
}
```

**คำอธิบาย:**
- ถ้า `depth > 0` → แสดงเส้นแนวตั้งทางซ้าย
- สีเทาอ่อนเพื่อแยกว่าเป็น sub-ingredient

---

## ✅ การตรวจสอบว่าทำถูกต้อง

### 1. ตรวจโค้ดที่เพิ่มไป

- [ ] เพิ่ม `depth` และ `detail` เข้า properties
- [ ] เพิ่ม `indent` calculation
- [ ] เปลี่ยนสี background ตาม depth
- [ ] เปลี่ยนขนาดตัวอักษรตาม depth
- [ ] แสดง detail text (ถ้ามี)
- [ ] เพิ่ม vertical line (ถ้า depth > 0)

### 2. Save ไฟล์

กด `Ctrl+S`

### 3. ตรวจสอบ error

ดูว่ามี error แดงๆ ไหม

**ถ้ามี:**
- อ่าน error message
- ตรวจสอบว่าลืม comma หรือไม่
- ตรวจสอบว่า bracket `{}` ครบหรือไม่

---

## 🎨 ตัวอย่างผลลัพธ์ที่ได้

```
┌──────────────────────────────────────┐
│ Fried Chicken Breast    250 kcal     │ ← ROOT (depth=0): ขาว, ตัวหนา
│ Coated in seasoned flour, deep-fried │
└──────────────────────────────────────┘

  │ ┌────────────────────────────────┐
  │ │ Chicken Breast Meat   132 kcal │ ← SUB (depth=1): เทาอ่อน, ตัวบาง
  │ │ Lean white meat                │
  │ └────────────────────────────────┘
  
  │ ┌────────────────────────────────┐
  │ │ Flour Batter          48 kcal  │ ← SUB (depth=1)
  │ └────────────────────────────────┘
```

---

## ⚠️ ข้อผิดพลาดที่พบบ่อย

### ❌ Layout overflow

**สาเหตุ:** ไม่ได้ wrap ด้วย `Expanded()`

**แก้:**

```dart
Row(
  children: [
    if (depth > 0) ...,
    Expanded(child: Container(...)),  // ✅ ต้องมี Expanded
  ],
)
```

### ❌ Text truncated

**สาเหตุ:** `maxLines` น้อยเกินไป

**แก้:** เพิ่ม `maxLines: 3` หรือไม่ใส่เลย

### ❌ Colors ไม่แสดง

**สาเหตุ:** ลืม `?` หลัง `Colors.grey`

**แก้:**

```dart
Colors.grey[50]  // ❌
Colors.grey[50]  // ✅ (actually same, but need nullcheck)
color: Colors.grey[50] ?? Colors.grey  // ✅ safer
```

---

## 🧪 การทดสอบ (ถ้าทำได้)

1. รันแอป: `flutter run`
2. ไปที่หน้า Health → Timeline
3. ถ่ายรูปอาหาร → ดูใน Analysis Sheet
4. **ต้องเห็น:**
   - ROOT ingredients: สีขาว, ตัวหนา
   - SUB ingredients: เทาอ่อน, เยื้อง, มีเส้นแนวตั้ง

**ถ้าไม่เห็นความต่าง:** ให้ Senior ตรวจ provider logic

---

## ✅ เมื่อทำเสร็จ

**คุณทำเสร็จแล้ว!**

**รอ Senior ทำ:**
- `SENIOR_TASK_3_ui_expandable.md` (Expandable tree UI)

---

## 🆘 ถ้าติดปัญหา

1. ตรวจสอบว่าทำครบทุก Step หรือยัง
2. ลอง Hot Reload (`r` ใน terminal) หรือ Hot Restart (`R`)
3. ถ้ามี error → copy error + screenshot มาถามพี่
4. ถ้า UI ไม่ออกมาตามต้องการ → screenshot มาถามพี่

---

**หมายเหตุ:** Task นี้เป็นการแก้ UI ง่ายๆ ไม่ซับซ้อน แต่ต้องทำอย่างละเอียด ตรวจสอบทุก detail!
