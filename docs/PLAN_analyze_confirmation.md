# Feature Plan: Analyze Confirmation Dialog

> **Goal:** ให้ระบบส่ง foodName + quantity + unit ที่ user แก้ไขแล้วไปวิเคราะห์ด้วย  
> และแสดง Confirmation Dialog ก่อนส่ง เพื่อให้ user ตรวจสอบ/แก้ไขข้อมูลก่อนใช้ Energy  
> **Scope:** Timeline Tab, Diet Tab (FoodDetailBottomSheet), Health Provider  
> **Breaking Change:** ไม่มี (เพิ่ม optional parameters)

---

## 1. Overview

### ปัญหาเดิม

**Timeline Tab** (`health_timeline_tab.dart` line 510-511):
```dart
if (hasImage) {
  result = await notifier.analyzeImage(File(entry.imagePath!));
}
```
- เมื่อ entry มีรูป → เรียก `analyzeImage(imageFile)` โดย **ไม่ส่ง** `foodName`, `servingSize`, `servingUnit` ไปเลย
- ข้อมูลที่ user แก้ไขไว้ (ชื่ออาหาร, ปริมาณ, หน่วย) ถูก **ละเลยทั้งหมด**

**Diet Tab** (`food_detail_bottom_sheet.dart` line 485):
```dart
result = await GeminiService.analyzeFoodImage(File(entry.imagePath!));
```
- ปัญหาเดียวกัน — ไม่ส่ง foodName, quantity, unit

**ข้อสังเกต:**
- `GeminiService.analyzeFoodImage()` **รองรับ parameters เหล่านี้อยู่แล้ว** (line 345-351):
  ```dart
  static Future<FoodAnalysisResult?> analyzeFoodImage(
    File imageFile, {
    String? foodName,      // ← รองรับแล้ว แต่ไม่มีใครส่งมา!
    double? quantity,      // ← รองรับแล้ว
    String? unit,          // ← รองรับแล้ว
  })
  ```
- `image_analysis_preview_screen.dart` เป็นตัวอย่างที่ทำถูก (line 105-110) — ส่ง foodName, quantity, unit ไปครบ

### Solution

1. แสดง **Confirmation Dialog** ก่อนส่งวิเคราะห์ ให้ user เห็นและแก้ไขข้อมูลที่จะส่ง
2. ส่ง foodName + quantity + unit ไปพร้อมกับรูปภาพทุกครั้ง
3. แก้ `health_provider.dart` `analyzeImage()` ให้รับ optional parameters

---

## 2. User Flow (ใหม่)

```
User กดปุ่ม ✨ (analyze) ที่ Timeline หรือ Diet tab
    │
    ▼
┌──────────────────────────────────┐
│  Analyze Confirmation Dialog     │
│                                  │
│  ┌────────────┐                  │
│  │  📷 Image  │  (ถ้ามีรูป)     │
│  │  Preview   │                  │
│  └────────────┘                  │
│                                  │
│  Food Name: [ข้าวผัดกะเพรา___]  │  ← แก้ไขได้
│  Quantity:  [300_________]       │  ← แก้ไขได้
│  Unit:      [g ▼________]       │  ← dropdown แก้ได้
│                                  │
│  ⚡ This will use 1 Energy       │
│                                  │
│  [Cancel]        [Analyze ✨]    │
└──────────────────────────────────┘
    │
    ▼ (User กด Analyze)
    │
ส่ง image + foodName + quantity + unit → AI
    │
    ▼
แสดง GeminiAnalysisSheet (เหมือนเดิม)
```

---

## 3. Files to Change

### 3.1 Health Provider: `lib/features/health/providers/health_provider.dart`

**Action:** เพิ่ม optional parameters ให้ `analyzeImage()`

**เดิม (line 130):**
```dart
Future<FoodAnalysisResult?> analyzeImage(File imageFile) async {
  final result = await GeminiService.analyzeFoodImage(imageFile);
  // ...
}
```

**ใหม่:**
```dart
Future<FoodAnalysisResult?> analyzeImage(
  File imageFile, {
  String? foodName,
  double? quantity,
  String? unit,
}) async {
  final result = await GeminiService.analyzeFoodImage(
    imageFile,
    foodName: foodName,
    quantity: quantity,
    unit: unit,
  );
  // ...rest unchanged...
}
```

---

### 3.2 Timeline Tab: `lib/features/health/presentation/health_timeline_tab.dart`

**Action:** เพิ่ม Confirmation Dialog ก่อนวิเคราะห์ + ส่ง parameters ไปด้วย

#### แก้ `_analyzeFoodWithGemini()` (~line 410)

**ตำแหน่งที่ต้องเพิ่ม:** หลัง re-analysis confirmation (line 462) แต่ก่อน energy check (line 470)

เพิ่ม confirmation dialog:
```dart
// ────── แสดง Confirmation Dialog ──────
final analyzeParams = await _showAnalyzeConfirmation(entry);
if (analyzeParams == null) return; // User cancelled

final String confirmedFoodName = analyzeParams['foodName'] as String;
final double confirmedQuantity = analyzeParams['quantity'] as double;
final String confirmedUnit = analyzeParams['unit'] as String;
```

**แก้ส่วนเรียก analyze (~line 510-511):**

**เดิม:**
```dart
if (hasImage) {
  result = await notifier.analyzeImage(File(entry.imagePath!));
} else {
  result = await GeminiService.analyzeFoodByName(
    entry.foodName,
    servingSize: entry.servingSize,
    servingUnit: entry.servingUnit,
  );
}
```

**ใหม่:**
```dart
if (hasImage) {
  result = await notifier.analyzeImage(
    File(entry.imagePath!),
    foodName: confirmedFoodName.isNotEmpty ? confirmedFoodName : null,
    quantity: confirmedQuantity > 0 ? confirmedQuantity : null,
    unit: confirmedUnit,
  );
} else {
  result = await GeminiService.analyzeFoodByName(
    confirmedFoodName.isNotEmpty ? confirmedFoodName : entry.foodName,
    servingSize: confirmedQuantity > 0 ? confirmedQuantity : entry.servingSize,
    servingUnit: confirmedUnit,
  );
}
```

#### เพิ่ม method `_showAnalyzeConfirmation()`:

```dart
/// แสดง Confirmation Dialog ก่อนส่งวิเคราะห์
/// Return null = user cancelled
/// Return Map = { foodName, quantity, unit }
Future<Map<String, dynamic>?> _showAnalyzeConfirmation(FoodEntry entry) async {
  final foodNameController = TextEditingController(
    text: entry.foodName == 'food' ? '' : entry.foodName,
  );
  final quantityController = TextEditingController(
    text: entry.servingSize > 0 ? entry.servingSize.toString() : '',
  );
  String selectedUnit = entry.servingUnit.isNotEmpty ? entry.servingUnit : 'serving';

  final hasImage = entry.imagePath != null && File(entry.imagePath!).existsSync();

  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.amber),
            SizedBox(width: 8),
            Text('Analyze with AI'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Preview
              if (hasImage) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(entry.imagePath!),
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Food Name
              const Text('Food Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 4),
              TextField(
                controller: foodNameController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Pad Krapow, Salmon Sushi...',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),

              // Quantity + Unit (Row)
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Quantity', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 4),
                        TextField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'e.g. 300',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Unit', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          value: selectedUnit,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          items: _servingUnits.map((u) =>
                            DropdownMenuItem(value: u, child: Text(u)),
                          ).toList(),
                          onChanged: (v) {
                            if (v != null) setDialogState(() => selectedUnit = v);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Info
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Text('⚡', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This will use 1 Energy.\nProviding food name & quantity improves accuracy.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx, {
                'foodName': foodNameController.text.trim(),
                'quantity': double.tryParse(quantityController.text.trim()) ?? 0.0,
                'unit': selectedUnit,
              });
            },
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: const Text('Analyze'),
          ),
        ],
      ),
    ),
  );
}

/// Serving unit options
static const _servingUnits = [
  'serving', 'plate', 'cup', 'bowl', 'piece', 'box', 'pack', 'bag',
  'bottle', 'glass', 'egg', 'ball', 'item', 'slice', 'pair', 'stick',
  'g', 'kg', 'ml', 'l', 'tbsp', 'tsp', 'oz', 'lbs',
];
```

---

### 3.3 Food Detail Bottom Sheet: `lib/features/health/widgets/food_detail_bottom_sheet.dart`

**Action:** ส่ง foodName + quantity + unit ไปเมื่อวิเคราะห์ภาพ (default behavior)

**เดิม (line 483-485):**
```dart
if (hasImage) {
  result = await GeminiService.analyzeFoodImage(File(entry.imagePath!));
}
```

**ใหม่:**
```dart
if (hasImage) {
  result = await GeminiService.analyzeFoodImage(
    File(entry.imagePath!),
    foodName: entry.foodName != 'food' ? entry.foodName : null,
    quantity: entry.servingSize > 0 ? entry.servingSize : null,
    unit: entry.servingUnit.isNotEmpty ? entry.servingUnit : null,
  );
}
```

> **Note:** `food_detail_bottom_sheet.dart` ใช้ `onAnalyze` callback เมื่อถูกเรียกจาก timeline tab  
> ดังนั้นถ้า Timeline Tab แสดง confirmation dialog แล้ว → flow ผ่าน `onAnalyze` callback ก็จะได้ข้อมูลครบ  
> แต่ต้องแก้ **default behavior** (line 483-485) สำหรับกรณีที่เปิดจาก Diet tab (ที่ `onAnalyze == null`)  
>  
> สำหรับ Diet tab ไม่จำเป็นต้องมี confirmation dialog เพราะ user กำลังอยู่ใน FoodDetailBottomSheet อยู่แล้ว  
> (เห็นข้อมูลทั้งหมดอยู่) แค่ส่ง parameters ที่มีไปให้ AI ก็พอ

---

### 3.4 ไม่ต้องแก้ (สำหรับ reference)

| ไฟล์ | เหตุผล |
|------|--------|
| `gemini_service.dart` | `analyzeFoodImage()` รองรับ `foodName`, `quantity`, `unit` อยู่แล้ว |
| `image_analysis_preview_screen.dart` | ส่ง parameters ครบอยู่แล้ว (ทำถูกต้อง) |

---

## 4. Implementation Order

```
Step 1: แก้ health_provider.dart — เพิ่ม optional params ให้ analyzeImage()
Step 2: เพิ่ม _showAnalyzeConfirmation() method ใน health_timeline_tab.dart
Step 3: แก้ _analyzeFoodWithGemini() ใน health_timeline_tab.dart ให้เรียก confirmation + ส่ง params
Step 4: แก้ food_detail_bottom_sheet.dart ให้ส่ง params ตอนเรียก analyzeFoodImage()
Step 5: Test ทั้ง flow
```

---

## 5. Testing Checklist

### Timeline Tab
- [ ] กด analyze icon → แสดง Confirmation Dialog พร้อมข้อมูลที่มี
- [ ] Dialog แสดงรูป preview (ถ้ามี)
- [ ] Dialog แสดง food name ที่ user เคยแก้ไขไว้ (ถ้ายังเป็น "food" ให้โชว์ hint แทน)
- [ ] Dialog แสดง quantity + unit ที่ user เคยใส่ไว้
- [ ] User แก้ไข food name → AI ได้รับชื่อใหม่
- [ ] User แก้ไข quantity (เช่น 300g) → AI ได้รับปริมาณใหม่
- [ ] User กด Cancel → ไม่เสีย Energy
- [ ] User กด Analyze → ส่งข้อมูลครบ + เสีย 1 Energy
- [ ] Entry ไม่มีรูป → Confirmation Dialog ไม่แสดง image preview
- [ ] Entry ไม่มีรูป → ใช้ `analyzeFoodByName()` พร้อม parameters ที่แก้ไข

### Diet Tab (FoodDetailBottomSheet)
- [ ] กด AI Analysis → ส่ง foodName + servingSize + servingUnit ไปด้วย
- [ ] ผลวิเคราะห์ accurate ขึ้นเมื่อมี food name + quantity

### Edge Cases
- [ ] food name = "food" (default) → ส่ง null ให้ AI ตัดสินจากรูป
- [ ] quantity = 0 → ส่ง null ให้ AI ประมาณเอง
- [ ] unit = "" → ส่ง null ให้ AI ประมาณเอง
- [ ] ไม่มีรูป + ไม่มีชื่อ → แจ้ง user ว่าไม่มีข้อมูลพอวิเคราะห์

---

## 6. Impact on Accuracy

**ก่อนแก้ (เดิม):**
- AI เห็นแค่รูป → ต้องเดา food name, portion size เอง
- ถ้ารูปไม่ชัด, ถ่ายมุมไม่ดี → AI ผิดเยอะ

**หลังแก้:**
- AI เห็นรูป + "user บอกว่าคือ ข้าวผัดกะเพรา, 300g" → ตอบแม่นขึ้นมาก
- Prompt ที่ส่งไปจะมี:
  ```
  The user has indicated this is: "ข้าวผัดกะเพรา".
  The user has specified the quantity as: 300.0 g.
  ```
- AI ใช้ข้อมูลนี้ช่วยตัดสิน → ลด error rate

---

## 7. Notes

- **ไม่ต้องแก้ `gemini_service.dart`** เพราะรองรับ parameters อยู่แล้ว
- **Confirmation Dialog ใช้เฉพาะ Timeline tab** เพราะ user กดจาก card โดยตรง  
  (Diet tab ผ่าน FoodDetailBottomSheet ซึ่ง user เห็นข้อมูลอยู่แล้ว → แค่ส่ง params ไปก็พอ)
- **Serving unit list** ใช้ list เดียวกับ `gemini_service.dart` prompt ที่กำหนด valid units ไว้
- ถ้าอนาคตต้องการ confirmation dialog ใน Diet tab ด้วย สามารถ extract `_showAnalyzeConfirmation()` เป็น shared widget ได้
