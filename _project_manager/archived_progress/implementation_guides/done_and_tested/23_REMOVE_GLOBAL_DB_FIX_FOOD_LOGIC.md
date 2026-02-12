# Step 23: ลบ Global Food Database + แก้ Logic ปริมาณ/แคลอรี่

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 4-5 ชั่วโมง
> **ความยาก:** ปานกลาง-ยาก
> **ต้องทำก่อน:** Step 07 (Food Preview AI)

---

## 🎯 เป้าหมาย

1. **ลบ** การใช้ `GlobalFoodDatabase` ออกจากทุกไฟล์ (ใช้ไม่ดี ข้อมูลไม่แม่น)
2. **แก้ Bug** เปลี่ยนปริมาณแล้ว แคลอรี่/macro ไม่เปลี่ยนตาม
3. **ปรับ Flow** ให้บันทึกอาหารด้วยค่า 0 ก่อน → ค่อยวิเคราะห์ด้วย Gemini ทีหลัง
4. **สร้าง UI** แสดงผลวิเคราะห์จาก Gemini + ให้ผู้ใช้แก้ปริมาณ → recalculate อัตโนมัติ
5. **ปรับ Refresh** ให้ UI ลื่นไหล ไม่กระพริบ

---

## 📐 System Flow (ใหม่)

```
┌─────────────────────────────────────────────────────────────────┐
│                    FOOD ENTRY FLOW (ใหม่)                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  [ถ่ายรูป/เลือกรูป]  →  บันทึก FoodEntry (kcal=0, macro=0)    │
│                          แสดงรูปใน Timeline ทันที               │
│                                                                 │
│  [ผู้ใช้กดปุ่ม "วิเคราะห์ Gemini"]                              │
│       ↓                                                         │
│  Gemini วิเคราะห์รูป → ได้ ชื่อ, kcal, P/C/F, ปริมาณ          │
│       ↓                                                         │
│  ┌─────────────────────────────────────┐                       │
│  │  แสดง Bottom Sheet ผลวิเคราะห์      │                       │
│  │  - ชื่ออาหาร (แก้ได้)              │                       │
│  │  - kcal, P, C, F                   │                       │
│  │  - ปริมาณ (แก้ได้ → recalculate)   │                       │
│  │  - [ยืนยัน] [ยกเลิก]              │                       │
│  └─────────────────────────────────────┘                       │
│       ↓                                                         │
│  อัปเดต FoodEntry ด้วยค่าจริง                                  │
│  เก็บ base values (ต่อ 1 หน่วย) สำหรับ recalculate ภายหลัง     │
│                                                                 │
│  [ผู้ใช้กด Edit ภายหลัง]                                       │
│       ↓                                                         │
│  เปลี่ยนปริมาณ → calories = baseCalories * newServing           │
│                   protein = baseProtein * newServing             │
│                   carbs = baseCarbs * newServing                 │
│                   fat = baseFat * newServing                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📂 ไฟล์ที่เกี่ยวข้อง

| ไฟล์ | Action | คำอธิบาย |
|------|--------|----------|
| `lib/features/health/models/food_entry.dart` | EDIT | เพิ่ม base nutrition fields |
| `lib/features/health/models/food_entry.g.dart` | REGENERATE | build_runner |
| `lib/features/health/widgets/edit_food_bottom_sheet.dart` | REWRITE | แก้ recalculate logic ทั้งหมด |
| `lib/features/health/widgets/gemini_analysis_sheet.dart` | CREATE | UI แสดงผลวิเคราะห์ Gemini |
| `lib/features/health/widgets/food_timeline_card.dart` | EDIT | ปรับปุ่ม 3 ปุ่ม |
| `lib/features/health/widgets/food_detail_bottom_sheet.dart` | EDIT | ปรับ UI ใหม่ |
| `lib/features/health/presentation/health_diet_tab.dart` | REWRITE | ลบ GlobalFoodDatabase |
| `lib/features/health/presentation/health_timeline_tab.dart` | EDIT | ปรับ analyze flow |
| `lib/features/health/presentation/food_preview_screen.dart` | EDIT | บันทึกค่า 0 ก่อน |
| `lib/features/health/providers/health_provider.dart` | EDIT | ปรับ analyze + refresh |
| `lib/core/ai/llm_service.dart` | EDIT | ลบ GlobalFoodDatabase |
| `lib/features/chat/services/intent_handler.dart` | EDIT | ใช้ค่า 0 |

---

## 🔧 ขั้นตอนการทำงาน

### Step 1: อัปเดต FoodEntry Model - เพิ่ม Base Nutrition Fields

**ไฟล์:** `lib/features/health/models/food_entry.dart`
**Action:** EDIT

**ทำไม:** ต้องเก็บ "ค่าโภชนาการต่อ 1 หน่วย" (base values) ไว้ เพื่อให้ recalculate ได้เมื่อผู้ใช้เปลี่ยนปริมาณ

**แทนที่ทั้งไฟล์ด้วย:**

```dart
import 'package:isar/isar.dart';
import '../../../core/constants/enums.dart';

part 'food_entry.g.dart';

@collection
class FoodEntry {
  Id id = Isar.autoIncrement;

  // ข้อมูลพื้นฐาน
  late String foodName;
  String? foodNameEn;
  late DateTime timestamp;
  String? imagePath;

  // มื้ออาหาร
  @enumerated
  late MealType mealType;

  // Serving Size - ปริมาณที่กิน
  late double servingSize; // เช่น 1.0, 0.5, 2.0
  late String servingUnit; // เช่น "จาน", "ถ้วย", "g"
  double? servingGrams;    // ปริมาณเป็นกรัม (ถ้าทราบ)

  // ============================================
  // Nutrition ที่คำนวณแล้ว (= base * servingSize)
  // ============================================
  late double calories;
  late double protein;
  late double carbs;
  late double fat;

  // ============================================
  // BASE Nutrition (ต่อ 1 หน่วย servingUnit)
  // ใช้สำหรับ recalculate เมื่อ servingSize เปลี่ยน
  // ตัวอย่าง: ถ้า 1 จาน = 520 kcal
  //   baseCalories = 520
  //   servingSize = 1 → calories = 520
  //   servingSize = 0.5 → calories = 260
  // ============================================
  double baseCalories = 0;
  double baseProtein = 0;
  double baseCarbs = 0;
  double baseFat = 0;

  // Micros (optional)
  double? fiber;
  double? sugar;
  double? sodium;
  double? cholesterol;
  double? saturatedFat;

  // Metadata
  @enumerated
  late DataSource source;
  double? aiConfidence;
  bool isVerified = false;
  String? notes;

  // ============================================
  // Links สำหรับ Phase 2 (My Meal / Ingredient)
  // ยังไม่ใช้ตอนนี้ แต่เตรียมไว้ก่อน
  // ============================================
  int? myMealId;          // link ไป MyMeal (ถ้ามา from My Meal)
  int? ingredientId;      // link ไป Ingredient (ถ้าเป็นวัตถุดิบเดี่ยว)
  String? groupId;        // group หลายรายการจากเมนูเดียวกัน
  String? ingredientsJson; // snapshot ของ ingredients ที่ใช้จริง

  // Sync
  String? healthConnectId;
  DateTime? syncedAt;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  // ============================================
  // Helper Methods
  // ============================================

  /// คำนวณ nutrition จาก base * servingSize
  void recalculateFromBase() {
    if (baseCalories > 0) {
      calories = baseCalories * servingSize;
      protein = baseProtein * servingSize;
      carbs = baseCarbs * servingSize;
      fat = baseFat * servingSize;
    }
  }

  /// ตั้ง base values จาก nutrition ปัจจุบัน (สำหรับ serving = 1)
  /// เรียกหลังจาก Gemini วิเคราะห์เสร็จ หรือ manual entry
  void setBaseFromCurrentNutrition() {
    if (servingSize > 0) {
      baseCalories = calories / servingSize;
      baseProtein = protein / servingSize;
      baseCarbs = carbs / servingSize;
      baseFat = fat / servingSize;
    } else {
      baseCalories = calories;
      baseProtein = protein;
      baseCarbs = carbs;
      baseFat = fat;
    }
  }

  /// ตรวจสอบว่ามี base values หรือยัง
  bool get hasBaseValues => baseCalories > 0 || baseProtein > 0 || baseCarbs > 0 || baseFat > 0;

  /// ตรวจสอบว่ามีค่าโภชนาการหรือยัง (ยังไม่ได้วิเคราะห์ = ค่า 0 ทั้งหมด)
  bool get hasNutritionData => calories > 0 || protein > 0 || carbs > 0 || fat > 0;
}
```

---

### Step 2: Regenerate Isar Schema

**Action:** รัน command ใน terminal

```bash
dart run build_runner build --delete-conflicting-outputs
```

**ทำไม:** เพราะเราเปลี่ยน `FoodEntry` model (เพิ่ม fields ใหม่) ต้อง regenerate `food_entry.g.dart`

**⚠️ สำคัญ:** ถ้ามี error เรื่อง migration ให้ clear app data บนเครื่องทดสอบ (uninstall app แล้ว install ใหม่)

---

### Step 3: สร้าง Gemini Analysis Result Sheet (Widget ใหม่)

**ไฟล์:** `lib/features/health/widgets/gemini_analysis_sheet.dart`
**Action:** CREATE

**ทำไม:** เมื่อ Gemini วิเคราะห์เสร็จ ต้องแสดงผลลัพธ์ให้ผู้ใช้ดู + แก้ปริมาณได้ + recalculate อัตโนมัติ

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ai/gemini_service.dart';

/// Bottom Sheet แสดงผลวิเคราะห์จาก Gemini
/// ผู้ใช้สามารถแก้ปริมาณ → kcal/macro recalculate อัตโนมัติ
class GeminiAnalysisSheet extends StatefulWidget {
  final FoodAnalysisResult analysisResult;
  final Function(GeminiConfirmedData) onConfirm;

  const GeminiAnalysisSheet({
    super.key,
    required this.analysisResult,
    required this.onConfirm,
  });

  @override
  State<GeminiAnalysisSheet> createState() => _GeminiAnalysisSheetState();
}

class _GeminiAnalysisSheetState extends State<GeminiAnalysisSheet> {
  late TextEditingController _nameController;
  late TextEditingController _servingSizeController;
  late String _servingUnit;

  // ค่าฐาน (ต่อ 1 หน่วย) จาก Gemini - ห้ามเปลี่ยน
  late double _baseCalories;
  late double _baseProtein;
  late double _baseCarbs;
  late double _baseFat;

  // ค่าที่คำนวณแล้ว (= base * servingSize) - เปลี่ยนตาม serving
  double _displayCalories = 0;
  double _displayProtein = 0;
  double _displayCarbs = 0;
  double _displayFat = 0;

  @override
  void initState() {
    super.initState();
    final result = widget.analysisResult;

    _nameController = TextEditingController(text: result.foodName);
    _servingSizeController = TextEditingController(
      text: result.servingSize.toString(),
    );
    _servingUnit = result.servingUnit;

    // คำนวณ base values (ต่อ 1 หน่วย)
    // Gemini ส่ง nutrition มาสำหรับ serving_size ที่ระบุ
    // เช่น serving_size=1 + calories=520 → base = 520/1 = 520 per unit
    // เช่น serving_size=2 + calories=1040 → base = 1040/2 = 520 per unit
    final geminiServing = result.servingSize > 0 ? result.servingSize : 1.0;
    _baseCalories = result.nutrition.calories / geminiServing;
    _baseProtein = result.nutrition.protein / geminiServing;
    _baseCarbs = result.nutrition.carbs / geminiServing;
    _baseFat = result.nutrition.fat / geminiServing;

    // คำนวณค่าแสดงผลเริ่มต้น
    _recalculate();

    // ฟัง serving size เปลี่ยน → recalculate
    _servingSizeController.addListener(_recalculate);
  }

  /// คำนวณ nutrition ใหม่จาก base * servingSize
  void _recalculate() {
    final servingSize = double.tryParse(_servingSizeController.text) ?? 0;
    setState(() {
      _displayCalories = _baseCalories * servingSize;
      _displayProtein = _baseProtein * servingSize;
      _displayCarbs = _baseCarbs * servingSize;
      _displayFat = _baseFat * servingSize;
    });
  }

  @override
  void dispose() {
    _servingSizeController.removeListener(_recalculate);
    _nameController.dispose();
    _servingSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.purple, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'ผลวิเคราะห์จาก Gemini',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Confidence badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(widget.analysisResult.confidence * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ชื่ออาหาร (แก้ไขได้)
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'ชื่ออาหาร',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ปริมาณ (แก้ไขได้ → recalculate)
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _servingSizeController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'ปริมาณ',
                      helperText: 'เปลี่ยนปริมาณ → แคลเปลี่ยนตาม',
                      helperStyle: TextStyle(
                        fontSize: 11,
                        color: Colors.purple.shade300,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.purple, width: 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    value: _getValidUnit(_servingUnit),
                    decoration: InputDecoration(
                      labelText: 'หน่วย',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'จาน', child: Text('จาน')),
                      DropdownMenuItem(value: 'ถ้วย', child: Text('ถ้วย')),
                      DropdownMenuItem(value: 'ชิ้น', child: Text('ชิ้น')),
                      DropdownMenuItem(value: 'g', child: Text('กรัม (g)')),
                      DropdownMenuItem(value: 'ml', child: Text('ml')),
                      DropdownMenuItem(value: 'แก้ว', child: Text('แก้ว')),
                      DropdownMenuItem(value: 'ฟอง', child: Text('ฟอง')),
                      DropdownMenuItem(value: 'serving', child: Text('serving')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _servingUnit = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // แคลอรี่ (ใหญ่ เด่น)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.health.withOpacity(0.1),
                    AppColors.health.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.health.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Text(
                    '${_displayCalories.toInt()}',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppColors.health,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'kcal',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Macros (3 columns)
            Row(
              children: [
                Expanded(child: _buildMacroCard('โปรตีน', _displayProtein, AppColors.protein)),
                const SizedBox(width: 8),
                Expanded(child: _buildMacroCard('คาร์บ', _displayCarbs, AppColors.carbs)),
                const SizedBox(width: 8),
                Expanded(child: _buildMacroCard('ไขมัน', _displayFat, AppColors.fat)),
              ],
            ),
            const SizedBox(height: 12),

            // Base info (อ่านอย่างเดียว)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'ค่าฐาน: ${_baseCalories.toInt()} kcal / 1 $_servingUnit '
                      '(P:${_baseProtein.toInt()}g C:${_baseCarbs.toInt()}g F:${_baseFat.toInt()}g)',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ปุ่มยืนยัน + ยกเลิก
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('ยกเลิก'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _confirm,
                    icon: const Icon(Icons.check, size: 20),
                    label: const Text('ยืนยัน'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroCard(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${value.toStringAsFixed(1)}g',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getValidUnit(String unit) {
    const validUnits = ['จาน', 'ถ้วย', 'ชิ้น', 'g', 'ml', 'แก้ว', 'ฟอง', 'serving'];
    if (validUnits.contains(unit)) return unit;
    // Map Thai units
    switch (unit) {
      case 'กรัม': return 'g';
      case 'plate': return 'จาน';
      case 'cup': return 'ถ้วย';
      case 'piece': return 'ชิ้น';
      default: return 'serving';
    }
  }

  void _confirm() {
    final servingSize = double.tryParse(_servingSizeController.text) ?? 1.0;

    widget.onConfirm(GeminiConfirmedData(
      foodName: _nameController.text.trim(),
      foodNameEn: widget.analysisResult.foodNameEn,
      servingSize: servingSize,
      servingUnit: _servingUnit,
      servingGrams: widget.analysisResult.servingGrams?.toDouble(),
      // ค่าที่คำนวณแล้ว
      calories: _displayCalories,
      protein: _displayProtein,
      carbs: _displayCarbs,
      fat: _displayFat,
      // ค่าฐาน (ต่อ 1 หน่วย)
      baseCalories: _baseCalories,
      baseProtein: _baseProtein,
      baseCarbs: _baseCarbs,
      baseFat: _baseFat,
      // ข้อมูลเพิ่ม
      confidence: widget.analysisResult.confidence,
      fiber: widget.analysisResult.nutrition.fiber,
      sugar: widget.analysisResult.nutrition.sugar,
      sodium: widget.analysisResult.nutrition.sodium,
      ingredients: widget.analysisResult.ingredients,
      notes: widget.analysisResult.notes,
    ));
    Navigator.pop(context);
  }
}

/// ข้อมูลที่ผู้ใช้ยืนยันจาก Gemini Analysis
class GeminiConfirmedData {
  final String foodName;
  final String? foodNameEn;
  final double servingSize;
  final String servingUnit;
  final double? servingGrams;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double baseCalories;
  final double baseProtein;
  final double baseCarbs;
  final double baseFat;
  final double confidence;
  final double? fiber;
  final double? sugar;
  final double? sodium;
  final List<String>? ingredients;
  final String? notes;

  GeminiConfirmedData({
    required this.foodName,
    this.foodNameEn,
    required this.servingSize,
    required this.servingUnit,
    this.servingGrams,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.baseCalories,
    required this.baseProtein,
    required this.baseCarbs,
    required this.baseFat,
    required this.confidence,
    this.fiber,
    this.sugar,
    this.sodium,
    this.ingredients,
    this.notes,
  });
}
```

---

### Step 4: Rewrite Edit Food Bottom Sheet - แก้ Recalculate Logic

**ไฟล์:** `lib/features/health/widgets/edit_food_bottom_sheet.dart`
**Action:** REWRITE ทั้งไฟล์

**ทำไม:** โค้ดเดิมใช้ GlobalFoodDatabase + recalculate logic ผิด ต้องเขียนใหม่ให้ใช้ base values

**แทนที่ทั้งไฟล์ด้วย:**

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/enums.dart';
import '../models/food_entry.dart';

/// Bottom Sheet สำหรับแก้ไข FoodEntry
/// - เปลี่ยนปริมาณ → recalculate kcal/macro อัตโนมัติ
/// - ถ้ามี base values → ใช้ base * serving
/// - ถ้าไม่มี base values → ใช้ ratio จากค่าเดิม
class EditFoodBottomSheet extends StatefulWidget {
  final FoodEntry entry;
  final Function(FoodEntry) onSave;

  const EditFoodBottomSheet({
    super.key,
    required this.entry,
    required this.onSave,
  });

  @override
  State<EditFoodBottomSheet> createState() => _EditFoodBottomSheetState();
}

class _EditFoodBottomSheetState extends State<EditFoodBottomSheet> {
  late TextEditingController _nameController;
  late TextEditingController _servingSizeController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;

  late String _servingUnit;
  late MealType _selectedMealType;

  // ค่าฐาน (ต่อ 1 หน่วย) - ใช้สำหรับ recalculate
  late double _baseCalories;
  late double _baseProtein;
  late double _baseCarbs;
  late double _baseFat;

  // ตรวจสอบว่ามี base values หรือไม่
  late bool _hasBaseValues;

  // เก็บ original serving size สำหรับ ratio calculation
  late double _originalServingSize;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;

    _nameController = TextEditingController(text: entry.foodName);
    _servingSizeController = TextEditingController(
      text: entry.servingSize.toString(),
    );
    _caloriesController = TextEditingController(
      text: entry.calories.toInt().toString(),
    );
    _proteinController = TextEditingController(
      text: entry.protein.toInt().toString(),
    );
    _carbsController = TextEditingController(
      text: entry.carbs.toInt().toString(),
    );
    _fatController = TextEditingController(
      text: entry.fat.toInt().toString(),
    );

    _servingUnit = entry.servingUnit;
    _selectedMealType = entry.mealType;
    _originalServingSize = entry.servingSize;

    // ใช้ base values ถ้ามี
    if (entry.hasBaseValues) {
      _hasBaseValues = true;
      _baseCalories = entry.baseCalories;
      _baseProtein = entry.baseProtein;
      _baseCarbs = entry.baseCarbs;
      _baseFat = entry.baseFat;
    } else if (entry.servingSize > 0 && entry.hasNutritionData) {
      // ถ้าไม่มี base values แต่มี nutrition data → คำนวณ base จากค่าปัจจุบัน
      _hasBaseValues = true;
      _baseCalories = entry.calories / entry.servingSize;
      _baseProtein = entry.protein / entry.servingSize;
      _baseCarbs = entry.carbs / entry.servingSize;
      _baseFat = entry.fat / entry.servingSize;
    } else {
      _hasBaseValues = false;
      _baseCalories = 0;
      _baseProtein = 0;
      _baseCarbs = 0;
      _baseFat = 0;
    }

    // ฟัง serving size เปลี่ยน → recalculate
    _servingSizeController.addListener(_onServingSizeChanged);
  }

  /// เมื่อ serving size เปลี่ยน → คำนวณ kcal/macro ใหม่
  void _onServingSizeChanged() {
    if (!_hasBaseValues) return;

    final newServing = double.tryParse(_servingSizeController.text) ?? 0;
    if (newServing <= 0) return;

    final newCalories = (_baseCalories * newServing).roundToDouble();
    final newProtein = (_baseProtein * newServing).roundToDouble();
    final newCarbs = (_baseCarbs * newServing).roundToDouble();
    final newFat = (_baseFat * newServing).roundToDouble();

    setState(() {
      _caloriesController.text = newCalories.toInt().toString();
      _proteinController.text = newProtein.toInt().toString();
      _carbsController.text = newCarbs.toInt().toString();
      _fatController.text = newFat.toInt().toString();
    });
  }

  @override
  void dispose() {
    _servingSizeController.removeListener(_onServingSizeChanged);
    _nameController.dispose();
    _servingSizeController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            const Text(
              '✏️ แก้ไขอาหาร',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // ชื่ออาหาร
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'ชื่ออาหาร',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // ปริมาณ + หน่วย
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _servingSizeController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'ปริมาณ',
                      helperText: _hasBaseValues ? 'เปลี่ยนปริมาณ → แคลเปลี่ยนตาม' : null,
                      helperStyle: TextStyle(fontSize: 11, color: Colors.purple.shade300),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    value: _getValidUnit(_servingUnit),
                    decoration: InputDecoration(
                      labelText: 'หน่วย',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'จาน', child: Text('จาน')),
                      DropdownMenuItem(value: 'ถ้วย', child: Text('ถ้วย')),
                      DropdownMenuItem(value: 'ชิ้น', child: Text('ชิ้น')),
                      DropdownMenuItem(value: 'g', child: Text('กรัม (g)')),
                      DropdownMenuItem(value: 'ml', child: Text('ml')),
                      DropdownMenuItem(value: 'แก้ว', child: Text('แก้ว')),
                      DropdownMenuItem(value: 'ฟอง', child: Text('ฟอง')),
                      DropdownMenuItem(value: 'serving', child: Text('serving')),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _servingUnit = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Nutrition fields
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.health.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.health.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Calories
                  TextField(
                    controller: _caloriesController,
                    keyboardType: TextInputType.number,
                    readOnly: _hasBaseValues, // อ่านอย่างเดียวถ้ามี base values
                    decoration: InputDecoration(
                      labelText: 'แคลอรี่ (kcal)',
                      prefixText: '🔥 ',
                      filled: _hasBaseValues,
                      fillColor: _hasBaseValues ? Colors.grey.shade100 : null,
                      suffixIcon: _hasBaseValues
                          ? const Tooltip(
                              message: 'คำนวณอัตโนมัติจากปริมาณ',
                              child: Icon(Icons.lock_outline, size: 18),
                            )
                          : null,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Macros
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _proteinController,
                          keyboardType: TextInputType.number,
                          readOnly: _hasBaseValues,
                          decoration: InputDecoration(
                            labelText: 'Protein (g)',
                            filled: _hasBaseValues,
                            fillColor: _hasBaseValues ? Colors.grey.shade100 : null,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _carbsController,
                          keyboardType: TextInputType.number,
                          readOnly: _hasBaseValues,
                          decoration: InputDecoration(
                            labelText: 'Carbs (g)',
                            filled: _hasBaseValues,
                            fillColor: _hasBaseValues ? Colors.grey.shade100 : null,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _fatController,
                          keyboardType: TextInputType.number,
                          readOnly: _hasBaseValues,
                          decoration: InputDecoration(
                            labelText: 'Fat (g)',
                            filled: _hasBaseValues,
                            fillColor: _hasBaseValues ? Colors.grey.shade100 : null,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // แสดง base info ถ้ามี
                  if (_hasBaseValues) ...[
                    const SizedBox(height: 8),
                    Text(
                      '📊 ค่าฐาน: ${_baseCalories.toInt()} kcal / 1 $_servingUnit',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Meal type
            const Text('มื้ออาหาร', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: MealType.values.map((type) {
                final isSelected = _selectedMealType == type;
                return ChoiceChip(
                  label: Text('${type.icon} ${type.displayName}'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedMealType = type);
                  },
                  selectedColor: AppColors.health.withOpacity(0.2),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('บันทึก', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getValidUnit(String unit) {
    const validUnits = ['จาน', 'ถ้วย', 'ชิ้น', 'g', 'ml', 'แก้ว', 'ฟอง', 'serving'];
    if (validUnits.contains(unit)) return unit;
    switch (unit) {
      case 'กรัม': return 'g';
      case 'plate': return 'จาน';
      case 'cup': return 'ถ้วย';
      case 'piece': return 'ชิ้น';
      default: return 'serving';
    }
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกชื่ออาหาร')),
      );
      return;
    }

    final calories = double.tryParse(_caloriesController.text) ?? 0;
    final protein = double.tryParse(_proteinController.text) ?? 0;
    final carbs = double.tryParse(_carbsController.text) ?? 0;
    final fat = double.tryParse(_fatController.text) ?? 0;
    final servingSize = double.tryParse(_servingSizeController.text) ?? 1.0;

    // อัปเดต entry
    widget.entry.foodName = _nameController.text.trim();
    widget.entry.mealType = _selectedMealType;
    widget.entry.servingSize = servingSize;
    widget.entry.servingUnit = _servingUnit;
    widget.entry.calories = calories;
    widget.entry.protein = protein;
    widget.entry.carbs = carbs;
    widget.entry.fat = fat;
    widget.entry.updatedAt = DateTime.now();

    // อัปเดต base values ถ้าไม่มี (manual entry)
    if (!_hasBaseValues && servingSize > 0 && calories > 0) {
      widget.entry.baseCalories = calories / servingSize;
      widget.entry.baseProtein = protein / servingSize;
      widget.entry.baseCarbs = carbs / servingSize;
      widget.entry.baseFat = fat / servingSize;
    }

    widget.onSave(widget.entry);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ บันทึกเรียบร้อย'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
```

---

### Step 5: อัปเดต Health Provider - ปรับ Analyze Flow + Refresh

**ไฟล์:** `lib/features/health/providers/health_provider.dart`
**Action:** EDIT

**ทำไม:** 
1. `analyzeAndUpdateFoodEntry` ต้อง return `FoodAnalysisResult` แทนที่จะ auto-save → ให้ UI แสดง sheet ก่อน
2. เพิ่ม method ใหม่สำหรับ update จาก confirmed data
3. ปรับ refresh ให้ seamless

**แทนที่ทั้งไฟล์ด้วย:**

```dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/database/database_service.dart';
import '../../../core/ai/gemini_service.dart';
import '../../../core/constants/enums.dart';
import '../models/food_entry.dart';
import '../models/workout_entry.dart';
import '../models/other_health_entry.dart';

// ===== FOOD ENTRIES =====

// Get food entries for a specific date
final foodEntriesByDateProvider = FutureProvider.family<List<FoodEntry>, DateTime>((ref, date) async {
  final startOfDay = DateTime(date.year, date.month, date.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));
  
  return await DatabaseService.foodEntries
      .filter()
      .timestampBetween(startOfDay, endOfDay)
      .sortByTimestampDesc()
      .findAll();
});

// Get today's total calories
final todayCaloriesProvider = FutureProvider<double>((ref) async {
  final today = DateTime.now();
  final entries = await ref.watch(foodEntriesByDateProvider(today).future);
  return entries.fold<double>(0, (sum, entry) => sum + entry.calories);
});

// Get today's macros
final todayMacrosProvider = FutureProvider<Map<String, double>>((ref) async {
  final today = DateTime.now();
  final entries = await ref.watch(foodEntriesByDateProvider(today).future);
  
  double protein = 0, carbs = 0, fat = 0;
  for (final entry in entries) {
    protein += entry.protein;
    carbs += entry.carbs;
    fat += entry.fat;
  }
  
  return {
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
  };
});

// ===== WORKOUT ENTRIES =====

final workoutEntriesByDateProvider = FutureProvider.family<List<WorkoutEntry>, DateTime>((ref, date) async {
  final startOfDay = DateTime(date.year, date.month, date.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));
  
  return await DatabaseService.workoutEntries
      .filter()
      .timestampBetween(startOfDay, endOfDay)
      .sortByTimestampDesc()
      .findAll();
});

// ===== OTHER HEALTH ENTRIES =====

final otherHealthEntriesByDateProvider = FutureProvider.family<List<OtherHealthEntry>, DateTime>((ref, date) async {
  final startOfDay = DateTime(date.year, date.month, date.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));
  
  return await DatabaseService.otherHealthEntries
      .filter()
      .timestampBetween(startOfDay, endOfDay)
      .sortByTimestampDesc()
      .findAll();
});

// ===== COMBINED TIMELINE =====

class TimelineItem {
  final String type; // 'food', 'workout', 'other'
  final DateTime timestamp;
  final dynamic data;
  
  TimelineItem({
    required this.type,
    required this.timestamp,
    required this.data,
  });
}

final healthTimelineProvider = FutureProvider.family<List<TimelineItem>, DateTime>((ref, date) async {
  final foods = await ref.watch(foodEntriesByDateProvider(date).future);
  final workouts = await ref.watch(workoutEntriesByDateProvider(date).future);
  final others = await ref.watch(otherHealthEntriesByDateProvider(date).future);
  
  final items = <TimelineItem>[];
  
  for (final food in foods) {
    items.add(TimelineItem(type: 'food', timestamp: food.timestamp, data: food));
  }
  
  for (final workout in workouts) {
    items.add(TimelineItem(type: 'workout', timestamp: workout.timestamp, data: workout));
  }
  
  for (final other in others) {
    items.add(TimelineItem(type: 'other', timestamp: other.timestamp, data: other));
  }
  
  // Sort by timestamp descending
  items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  
  return items;
});

// ===== NOTIFIERS FOR ADDING DATA =====

class FoodEntriesNotifier extends StateNotifier<AsyncValue<List<FoodEntry>>> {
  FoodEntriesNotifier() : super(const AsyncValue.loading());

  Future<void> addFoodEntry(FoodEntry entry) async {
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.foodEntries.put(entry);
    });
  }

  Future<void> updateFoodEntry(FoodEntry entry) async {
    entry.updatedAt = DateTime.now();
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.foodEntries.put(entry);
    });
  }

  Future<void> deleteFoodEntry(int id) async {
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.foodEntries.delete(id);
    });
  }

  /// วิเคราะห์รูปอาหารด้วย Gemini - return ผลลัพธ์เพื่อให้ UI แสดง
  /// (ไม่ auto-save อีกต่อไป → ให้ผู้ใช้ยืนยันก่อน)
  Future<FoodAnalysisResult?> analyzeImage(File imageFile) async {
    debugPrint('🔍 [FoodEntriesNotifier] เริ่มวิเคราะห์รูปด้วย Gemini...');
    
    try {
      final result = await GeminiService.analyzeFoodImage(imageFile);
      
      if (result == null) {
        throw Exception('ไม่สามารถวิเคราะห์รูปได้');
      }
      
      debugPrint('✅ [FoodEntriesNotifier] ได้ผลลัพธ์:');
      debugPrint('   - ชื่อ: ${result.foodName}');
      debugPrint('   - แคลอรี่: ${result.nutrition.calories} kcal');
      
      return result;
    } catch (e, stackTrace) {
      debugPrint('❌ [FoodEntriesNotifier] Error: $e');
      debugPrint('📋 Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// อัปเดต FoodEntry หลังจากผู้ใช้ยืนยันผล Gemini
  Future<void> updateFromGeminiConfirmed(int entryId, {
    required String foodName,
    String? foodNameEn,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    required double baseCalories,
    required double baseProtein,
    required double baseCarbs,
    required double baseFat,
    required double servingSize,
    required String servingUnit,
    double? servingGrams,
    double? confidence,
    double? fiber,
    double? sugar,
    double? sodium,
    String? notes,
  }) async {
    final entry = await DatabaseService.foodEntries.get(entryId);
    if (entry == null) {
      throw Exception('ไม่พบรายการอาหาร');
    }

    entry.foodName = foodName;
    entry.foodNameEn = foodNameEn;
    entry.calories = calories;
    entry.protein = protein;
    entry.carbs = carbs;
    entry.fat = fat;
    entry.baseCalories = baseCalories;
    entry.baseProtein = baseProtein;
    entry.baseCarbs = baseCarbs;
    entry.baseFat = baseFat;
    entry.servingSize = servingSize;
    entry.servingUnit = servingUnit;
    entry.servingGrams = servingGrams;
    entry.fiber = fiber;
    entry.sugar = sugar;
    entry.sodium = sodium;
    entry.source = DataSource.aiAnalyzed;
    entry.aiConfidence = confidence;
    entry.isVerified = true;
    entry.notes = notes ?? 'วิเคราะห์ด้วย Gemini 2.0 Flash';
    entry.updatedAt = DateTime.now();

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.foodEntries.put(entry);
    });

    debugPrint('✅ [FoodEntriesNotifier] อัปเดต FoodEntry สำเร็จ: id=$entryId');
  }

  /// Legacy method - ยังคงเอาไว้เพื่อ backward compatibility
  Future<void> analyzeAndUpdateFoodEntry(int entryId, File imageFile) async {
    final result = await analyzeImage(imageFile);
    if (result == null) return;

    final geminiServing = result.servingSize > 0 ? result.servingSize : 1.0;

    await updateFromGeminiConfirmed(
      entryId,
      foodName: result.foodName,
      foodNameEn: result.foodNameEn,
      calories: result.nutrition.calories,
      protein: result.nutrition.protein,
      carbs: result.nutrition.carbs,
      fat: result.nutrition.fat,
      baseCalories: result.nutrition.calories / geminiServing,
      baseProtein: result.nutrition.protein / geminiServing,
      baseCarbs: result.nutrition.carbs / geminiServing,
      baseFat: result.nutrition.fat / geminiServing,
      servingSize: result.servingSize,
      servingUnit: result.servingUnit,
      servingGrams: result.servingGrams?.toDouble(),
      confidence: result.confidence,
      fiber: result.nutrition.fiber,
      sugar: result.nutrition.sugar,
      sodium: result.nutrition.sodium,
      notes: result.notes,
    );
  }
}

final foodEntriesNotifierProvider =
    StateNotifierProvider<FoodEntriesNotifier, AsyncValue<List<FoodEntry>>>((ref) {
  return FoodEntriesNotifier();
});

class WorkoutEntriesNotifier extends StateNotifier<AsyncValue<List<WorkoutEntry>>> {
  WorkoutEntriesNotifier() : super(const AsyncValue.loading());

  Future<void> addWorkoutEntry(WorkoutEntry entry) async {
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.workoutEntries.put(entry);
    });
  }
}

final workoutEntriesNotifierProvider =
    StateNotifierProvider<WorkoutEntriesNotifier, AsyncValue<List<WorkoutEntry>>>((ref) {
  return WorkoutEntriesNotifier();
});

// ===== HELPER: Refresh providers for a date =====
/// เรียกใช้เมื่อข้อมูลอาหารเปลี่ยนแปลง เพื่อ refresh UI
void refreshFoodProviders(WidgetRef ref, DateTime date) {
  ref.invalidate(healthTimelineProvider(date));
  ref.invalidate(foodEntriesByDateProvider(date));
  ref.invalidate(todayCaloriesProvider);
  ref.invalidate(todayMacrosProvider);
}
```

---

### Step 6: อัปเดต Health Timeline Tab - ใช้ Gemini Analysis Sheet

**ไฟล์:** `lib/features/health/presentation/health_timeline_tab.dart`
**Action:** EDIT

**แก้ไข:** เปลี่ยน `_analyzeFoodWithGemini` ให้แสดง `GeminiAnalysisSheet` แทน auto-save

**แทนที่ทั้งไฟล์ด้วย:**

```dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/enums.dart';
import '../providers/health_provider.dart';
import '../widgets/daily_summary_card.dart';
import '../widgets/food_timeline_card.dart';
import '../widgets/workout_timeline_card.dart';
import '../widgets/other_health_timeline_card.dart';
import '../widgets/edit_food_bottom_sheet.dart';
import '../widgets/food_detail_bottom_sheet.dart';
import '../widgets/gemini_analysis_sheet.dart';
import '../models/food_entry.dart';
import '../models/workout_entry.dart';
import '../models/other_health_entry.dart';
import '../../scanner/providers/scanner_provider.dart';
import '../../../core/ai/gemini_service.dart';

class HealthTimelineTab extends ConsumerStatefulWidget {
  const HealthTimelineTab({super.key});

  @override
  ConsumerState<HealthTimelineTab> createState() => _HealthTimelineTabState();
}

class _HealthTimelineTabState extends ConsumerState<HealthTimelineTab> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final timelineAsync = ref.watch(healthTimelineProvider(_selectedDate));

    return RefreshIndicator(
      onRefresh: () async {
        try {
          final count = await ref.read(galleryScanNotifierProvider.notifier).scanNewImages();
          debugPrint('📸 สแกนเสร็จ - พบ: $count รายการ');
        } catch (e) {
          debugPrint('❌ สแกนไม่สำเร็จ: $e');
        }
        refreshFoodProviders(ref, _selectedDate);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: DailySummaryCard()),
          SliverToBoxAdapter(child: _buildDateSelector()),

          timelineAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, st) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
            data: (items) {
              if (items.isEmpty) {
                return SliverFillRemaining(child: _buildEmptyState());
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = items[index];
                    switch (item.type) {
                      case 'food':
                        return FoodTimelineCard(
                          entry: item.data as FoodEntry,
                          onTap: () => _showFoodDetail(item.data),
                          onEdit: () => _editFoodEntry(item.data),
                          onAnalyze: () => _analyzeFoodWithGemini(item.data),
                          onDelete: () => _deleteFoodEntry(item.data),
                        );
                      case 'workout':
                        return WorkoutTimelineCard(
                          entry: item.data as WorkoutEntry,
                          onTap: () => _showWorkoutDetail(item.data),
                        );
                      case 'other':
                        return OtherHealthTimelineCard(
                          entry: item.data as OtherHealthEntry,
                        );
                      default:
                        return const SizedBox();
                    }
                  },
                  childCount: items.length,
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    final dateFormat = DateFormat('d MMM yyyy', 'th');
    final isToday = _isToday(_selectedDate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => setState(() {
              _selectedDate = _selectedDate.subtract(const Duration(days: 1));
            }),
          ),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isToday ? AppColors.primary.withOpacity(0.1) : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '📅 ${isToday ? "วันนี้" : dateFormat.format(_selectedDate)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isToday ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    color: isToday ? AppColors.primary : AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: isToday ? null : () => setState(() {
              _selectedDate = _selectedDate.add(const Duration(days: 1));
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📭', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text('ยังไม่มีข้อมูล', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('กดปุ่ม ✨ เพื่อเพิ่มข้อมูล', style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _showFoodDetail(FoodEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FoodDetailBottomSheet(
        entry: entry,
        selectedDate: _selectedDate,
        onEdit: (updatedEntry) async {
          final notifier = ref.read(foodEntriesNotifierProvider.notifier);
          await notifier.updateFoodEntry(updatedEntry);
          refreshFoodProviders(ref, _selectedDate);
        },
        onDelete: (entry) async {
          final notifier = ref.read(foodEntriesNotifierProvider.notifier);
          await notifier.deleteFoodEntry(entry.id);
          refreshFoodProviders(ref, _selectedDate);
        },
        onAnalyze: (entry) async {
          await _analyzeFoodWithGemini(entry);
        },
      ),
    );
  }

  void _editFoodEntry(FoodEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditFoodBottomSheet(
        entry: entry,
        onSave: (updatedEntry) async {
          final notifier = ref.read(foodEntriesNotifierProvider.notifier);
          await notifier.updateFoodEntry(updatedEntry);
          refreshFoodProviders(ref, _selectedDate);
        },
      ),
    );
  }

  Future<void> _deleteFoodEntry(FoodEntry entry) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('ต้องการลบ "${entry.foodName}" หรือไม่?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ยกเลิก')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final notifier = ref.read(foodEntriesNotifierProvider.notifier);
      await notifier.deleteFoodEntry(entry.id);
      refreshFoodProviders(ref, _selectedDate);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ ลบรายการเรียบร้อย'), backgroundColor: AppColors.success),
      );
    }
  }

  /// วิเคราะห์อาหารด้วย Gemini → แสดง sheet ให้ผู้ใช้ยืนยัน
  Future<void> _analyzeFoodWithGemini(FoodEntry entry) async {
    if (entry.imagePath == null || !File(entry.imagePath!).existsSync()) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่พบรูปภาพ')),
      );
      return;
    }

    final hasApiKey = await GeminiService.hasApiKey();
    if (!hasApiKey) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาตั้งค่า Gemini API Key ก่อน (Settings → Profile → API Settings)'),
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    // แสดง loading dialog
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('กำลังวิเคราะห์ด้วย Gemini AI...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            Text('กรุณารอสักครู่', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );

    try {
      final notifier = ref.read(foodEntriesNotifierProvider.notifier);
      final result = await notifier.analyzeImage(File(entry.imagePath!));

      if (!context.mounted) return;
      Navigator.pop(context); // ปิด loading dialog

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ ไม่สามารถวิเคราะห์ได้'), backgroundColor: AppColors.error),
        );
        return;
      }

      // แสดง Gemini Analysis Sheet ให้ผู้ใช้ยืนยัน
      if (!context.mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => GeminiAnalysisSheet(
          analysisResult: result,
          onConfirm: (confirmedData) async {
            // อัปเดต FoodEntry ด้วยข้อมูลที่ผู้ใช้ยืนยัน
            await notifier.updateFromGeminiConfirmed(
              entry.id,
              foodName: confirmedData.foodName,
              foodNameEn: confirmedData.foodNameEn,
              calories: confirmedData.calories,
              protein: confirmedData.protein,
              carbs: confirmedData.carbs,
              fat: confirmedData.fat,
              baseCalories: confirmedData.baseCalories,
              baseProtein: confirmedData.baseProtein,
              baseCarbs: confirmedData.baseCarbs,
              baseFat: confirmedData.baseFat,
              servingSize: confirmedData.servingSize,
              servingUnit: confirmedData.servingUnit,
              servingGrams: confirmedData.servingGrams,
              confidence: confirmedData.confidence,
              fiber: confirmedData.fiber,
              sugar: confirmedData.sugar,
              sodium: confirmedData.sodium,
              notes: confirmedData.notes,
            );

            refreshFoodProviders(ref, _selectedDate);

            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ อัปเดตข้อมูลเรียบร้อย'), backgroundColor: AppColors.success),
            );
          },
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // ปิด loading dialog

      String errorMessage = 'เกิดข้อผิดพลาด';
      if (e.toString().contains('API Key')) {
        errorMessage = 'ไม่พบ Gemini API Key';
      } else if (e.toString().contains('parse JSON')) {
        errorMessage = 'ไม่สามารถอ่านผลลัพธ์ ลองใหม่อีกครั้ง';
      } else {
        errorMessage = e.toString().replaceAll('Exception: ', '');
        if (errorMessage.length > 100) errorMessage = '${errorMessage.substring(0, 100)}...';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ $errorMessage'), backgroundColor: AppColors.error),
      );
    }
  }

  void _showWorkoutDetail(WorkoutEntry entry) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.activityName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('เผาผลาญ: ${entry.caloriesBurned.toInt()} kcal'),
            Text('เวลา: ${entry.durationMinutes} นาที'),
            if (entry.distanceKm != null) Text('ระยะทาง: ${entry.distanceKm!.toStringAsFixed(1)} กม.'),
          ],
        ),
      ),
    );
  }
}
```

---

### Step 7: อัปเดต Food Timeline Card - แสดงปุ่มเสมอ

**ไฟล์:** `lib/features/health/widgets/food_timeline_card.dart`
**Action:** EDIT

**ทำไม:** ปุ่ม "วิเคราะห์ Gemini" ต้องแสดงเสมอเมื่อมีรูป (ไม่ว่า isVerified หรือไม่) เพราะผู้ใช้อาจต้องการวิเคราะห์ซ้ำ

**แก้ไขบรรทัดที่ 86 (เงื่อนไขแสดงปุ่ม Gemini):**

หาข้อความนี้:
```dart
if (onAnalyze != null && !entry.isVerified && entry.imagePath != null && File(entry.imagePath!).existsSync())
```

แทนที่ **ทั้ง 2 ที่** (บรรทัด 86 และ 102) ด้วย:
```dart
if (onAnalyze != null && entry.imagePath != null && File(entry.imagePath!).existsSync())
```

**ทำไม:** ลบเงื่อนไข `!entry.isVerified` ออก เพื่อให้ปุ่ม Gemini แสดงเสมอเมื่อมีรูป (ผู้ใช้อาจต้องการวิเคราะห์ซ้ำ)

---

### Step 8: อัปเดต Food Preview Screen - บันทึกค่า 0 ก่อน

**ไฟล์:** `lib/features/health/presentation/food_preview_screen.dart`
**Action:** EDIT

**ทำไม:** เมื่อถ่ายรูป/เลือกรูป ให้บันทึกด้วยค่า 0 ทันที ไม่ต้องรอวิเคราะห์ → ผู้ใช้ค่อยกด Gemini ทีหลัง

**หาฟังก์ชัน `_saveFood` แล้วแก้ไข validation:**

หาข้อความนี้:
```dart
    final calories = double.tryParse(_caloriesController.text) ?? 0;
    if (calories <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกแคลอรี่')),
      );
      return;
    }
```

แทนที่ด้วย:
```dart
    final calories = double.tryParse(_caloriesController.text) ?? 0;
    // อนุญาตให้บันทึกด้วยค่า 0 ได้ (จะวิเคราะห์ด้วย Gemini ทีหลัง)
```

**และ** เพิ่ม base values ในส่วน Create entry:

หาข้อความนี้:
```dart
    // Create entry
    final entry = FoodEntry()
      ..foodName = _nameController.text.trim()
      ..foodNameEn = _analysisResult?.foodNameEn
      ..calories = calories
      ..protein = double.tryParse(_proteinController.text) ?? 0
      ..carbs = double.tryParse(_carbsController.text) ?? 0
      ..fat = double.tryParse(_fatController.text) ?? 0
```

แทนที่ด้วย:
```dart
    // Create entry
    final protein = double.tryParse(_proteinController.text) ?? 0;
    final carbs = double.tryParse(_carbsController.text) ?? 0;
    final fat = double.tryParse(_fatController.text) ?? 0;
    final servingSize = double.tryParse(_servingSizeController.text) ?? 1;

    final entry = FoodEntry()
      ..foodName = _nameController.text.trim().isEmpty ? 'อาหาร (รอวิเคราะห์)' : _nameController.text.trim()
      ..foodNameEn = _analysisResult?.foodNameEn
      ..calories = calories
      ..protein = protein
      ..carbs = carbs
      ..fat = fat
      // เก็บ base values สำหรับ recalculate
      ..baseCalories = servingSize > 0 ? calories / servingSize : calories
      ..baseProtein = servingSize > 0 ? protein / servingSize : protein
      ..baseCarbs = servingSize > 0 ? carbs / servingSize : carbs
      ..baseFat = servingSize > 0 ? fat / servingSize : fat
```

---

### Step 9: อัปเดต Health Diet Tab - ลบ GlobalFoodDatabase

**ไฟล์:** `lib/features/health/presentation/health_diet_tab.dart`
**Action:** EDIT

**ลบ import:**
```dart
// ลบบรรทัดนี้:
import '../../../core/data/global_food_database.dart';
import '../widgets/food_search_field.dart';
```

**แก้ไข `AddFoodBottomSheet`:**

ลบ `GlobalFoodData? _selectedFood;` ออกทั้งหมด
ลบ `_onFoodSelected` method ออก
ลบ `FoodSearchField` ออก แล้วใช้ `TextField` ธรรมดาแทน
ลบ section "FROM DATABASE" ออก ใช้ manual entry อย่างเดียว

**แทนที่ class `AddFoodBottomSheet` ทั้งหมด (ตั้งแต่บรรทัด 178 ถึงท้ายไฟล์) ด้วย:**

```dart
class AddFoodBottomSheet extends StatefulWidget {
  final MealType mealType;
  final Function(FoodEntry) onSave;

  const AddFoodBottomSheet({
    super.key,
    required this.mealType,
    required this.onSave,
  });

  @override
  State<AddFoodBottomSheet> createState() => _AddFoodBottomSheetState();
}

class _AddFoodBottomSheetState extends State<AddFoodBottomSheet> {
  final _nameController = TextEditingController();
  final _servingSizeController = TextEditingController(text: '1');
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController(text: '0');
  final _carbsController = TextEditingController(text: '0');
  final _fatController = TextEditingController(text: '0');
  
  String _servingUnit = 'จาน';
  late MealType _selectedMealType;

  @override
  void initState() {
    super.initState();
    _selectedMealType = widget.mealType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _servingSizeController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('🍽️ เพิ่มอาหาร', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // ชื่ออาหาร
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'ชื่ออาหาร *',
                hintText: 'เช่น ข้าวผัดกุ้ง, ส้มตำ',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // ปริมาณ
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _servingSizeController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'ปริมาณ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    value: _servingUnit,
                    decoration: InputDecoration(
                      labelText: 'หน่วย',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'จาน', child: Text('จาน')),
                      DropdownMenuItem(value: 'ถ้วย', child: Text('ถ้วย')),
                      DropdownMenuItem(value: 'ชิ้น', child: Text('ชิ้น')),
                      DropdownMenuItem(value: 'g', child: Text('กรัม (g)')),
                      DropdownMenuItem(value: 'ml', child: Text('ml')),
                      DropdownMenuItem(value: 'แก้ว', child: Text('แก้ว')),
                      DropdownMenuItem(value: 'ฟอง', child: Text('ฟอง')),
                    ],
                    onChanged: (v) { if (v != null) setState(() => _servingUnit = v); },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Nutrition
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ข้อมูลโภชนาการ (ใส่ 0 ได้ถ้ายังไม่ทราบ)', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _caloriesController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'แคลอรี่ (kcal)',
                      prefixText: '🔥 ',
                      hintText: '0',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _proteinController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Protein (g)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _carbsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Carbs (g)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _fatController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Fat (g)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Meal type
            const Text('มื้ออาหาร', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: MealType.values.map((type) {
                final isSelected = _selectedMealType == type;
                return ChoiceChip(
                  label: Text('${type.icon} ${type.displayName}'),
                  selected: isSelected,
                  onSelected: (s) { if (s) setState(() => _selectedMealType = type); },
                  selectedColor: AppColors.health.withOpacity(0.2),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Save
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('บันทึก', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกชื่ออาหาร')),
      );
      return;
    }

    final calories = double.tryParse(_caloriesController.text) ?? 0;
    final protein = double.tryParse(_proteinController.text) ?? 0;
    final carbs = double.tryParse(_carbsController.text) ?? 0;
    final fat = double.tryParse(_fatController.text) ?? 0;
    final servingSize = double.tryParse(_servingSizeController.text) ?? 1.0;

    final entry = FoodEntry()
      ..foodName = _nameController.text.trim()
      ..mealType = _selectedMealType
      ..timestamp = DateTime.now()
      ..servingSize = servingSize
      ..servingUnit = _servingUnit
      ..calories = calories
      ..protein = protein
      ..carbs = carbs
      ..fat = fat
      // เก็บ base values
      ..baseCalories = servingSize > 0 ? calories / servingSize : calories
      ..baseProtein = servingSize > 0 ? protein / servingSize : protein
      ..baseCarbs = servingSize > 0 ? carbs / servingSize : carbs
      ..baseFat = servingSize > 0 ? fat / servingSize : fat
      ..source = DataSource.manual;

    widget.onSave(entry);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ เพิ่มอาหารแล้ว'), backgroundColor: AppColors.success),
    );
  }
}
```

---

### Step 10: อัปเดต LLM Service - ลบ GlobalFoodDatabase

**ไฟล์:** `lib/core/ai/llm_service.dart`
**Action:** EDIT

**ลบ import:**

หา:
```dart
import '../data/global_food_database.dart';
```
แทนที่ด้วย:
```dart
// GlobalFoodDatabase ถูกลบออกแล้ว - ใช้ค่า 0 สำหรับอาหารที่ไม่รู้จัก
// ผู้ใช้จะวิเคราะห์ด้วย Gemini ทีหลัง
```

**ลบ GlobalFoodDatabase lookup ทั้งหมด (ประมาณบรรทัด 391-467):**

หาโค้ดส่วนนี้ (อยู่ใน `_localFallback` method, ภายใน `if (category == 'Food')`)

ลบตั้งแต่:
```dart
        GlobalFoodData? globalFoodData;
        FoodNutritionData? foodData;
        
        // ⭐ ค้นหาจาก Global Food Database เท่านั้น (20k+ รายการ)
```

ไปจนถึง:
```dart
        } else if (foodData != null) {
          debugPrint('✅ [LLMService] ใช้ข้อมูลจาก database: $calories kcal, P:$protein C:$carbs F:$fat');
        }
```

**แทนที่ด้วย:**
```dart
        // ดึงแคลอรี่จากข้อความ (ถ้าผู้ใช้ระบุ)
        double? caloriesFromText = _extractCalories(text);
        
        // ใช้ค่าจากข้อความ หรือ 0 (ผู้ใช้จะวิเคราะห์ด้วย Gemini ทีหลัง)
        double calories = caloriesFromText ?? 0;
        double protein = 0;
        double carbs = 0;
        double fat = 0;
        
        double? servingSizeGrams;
        
        debugPrint('📊 [LLMService] ค่าที่ใช้: $calories kcal (จะวิเคราะห์ด้วย Gemini ภายหลัง)');
```

**และลบตัวแปร `_thaiToEnglishFood` map ทั้งหมด (ประมาณบรรทัด 617-711):**

หา `static const _thaiToEnglishFood = {` ลบไปจนถึง `};` ที่ปิด map

**และลบ method `_translateFoodToEnglish` ทั้งหมด (ประมาณบรรทัด 740-758)**

**และแก้ `_extractFoodName` ให้ไม่เรียก translate:**

หา:
```dart
    // Try to translate Thai food name to English for database lookup
    final translated = _translateFoodToEnglish(cleaned);
    if (translated != cleaned) {
      debugPrint('🌐 [LLMService] Translated: "$cleaned" -> "$translated"');
    }
    
    return translated;
```

แทนที่ด้วย:
```dart
    return cleaned;
```

---

### Step 11: อัปเดต Intent Handler - ใช้ค่า 0

**ไฟล์:** `lib/features/chat/services/intent_handler.dart`
**Action:** EDIT

**ไม่ต้องเปลี่ยนอะไรมาก** เพราะ IntentHandler ดึงค่าจาก LLM Service ซึ่งจะส่งค่า 0 มาอยู่แล้ว (หลัง Step 10)

**เพิ่ม base values ตอนสร้าง FoodEntry (ในฟังก์ชัน `_handleHealth`):**

หา:
```dart
      final entry = FoodEntry()
        ..foodName = title
        ..calories = calories
        ..protein = proteinFromAI
        ..carbs = carbsFromAI
        ..fat = fatFromAI
        ..mealType = mealType
        ..timestamp = entryDate
        ..servingSize = servingSizeFromAI
        ..servingUnit = servingUnitFromAI
        ..servingGrams = servingGramsFromAI
        ..source = DataSource.aiAnalyzed
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();
```

แทนที่ด้วย:
```dart
      final entry = FoodEntry()
        ..foodName = title
        ..calories = calories
        ..protein = proteinFromAI
        ..carbs = carbsFromAI
        ..fat = fatFromAI
        // เก็บ base values สำหรับ recalculate
        ..baseCalories = servingSizeFromAI > 0 ? calories / servingSizeFromAI : calories
        ..baseProtein = servingSizeFromAI > 0 ? proteinFromAI / servingSizeFromAI : proteinFromAI
        ..baseCarbs = servingSizeFromAI > 0 ? carbsFromAI / servingSizeFromAI : carbsFromAI
        ..baseFat = servingSizeFromAI > 0 ? fatFromAI / servingSizeFromAI : fatFromAI
        ..mealType = mealType
        ..timestamp = entryDate
        ..servingSize = servingSizeFromAI
        ..servingUnit = servingUnitFromAI
        ..servingGrams = servingGramsFromAI
        ..source = calories > 0 ? DataSource.aiAnalyzed : DataSource.manual
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();
```

**และเพิ่มข้อความบอกให้วิเคราะห์ Gemini (ถ้าค่า 0):**

หา:
```dart
      return IntentResponse(
        replyMessage: '✅ บันทึกอาหารแล้ว!\n\n'
            '🍽️ **$title** (${_getMealTypeText(mealType)})'
            '$dateText\n'
            '🔥 ${calories.toInt()} kcal'
            '$macrosText\n\n'
            '_แก้ไขได้ที่หน้า Health > Diet_',
```

แทนที่ด้วย:
```dart
      // ข้อความเพิ่มเติมถ้ายังไม่มีข้อมูล nutrition
      String geminiHint = '';
      if (calories == 0) {
        geminiHint = '\n\n💡 _กดปุ่ม Gemini ที่หน้า Timeline เพื่อวิเคราะห์ค่าโภชนาการ_';
      }

      return IntentResponse(
        replyMessage: '✅ บันทึกอาหารแล้ว!\n\n'
            '🍽️ **$title** (${_getMealTypeText(mealType)})'
            '$dateText\n'
            '🔥 ${calories.toInt()} kcal'
            '$macrosText'
            '$geminiHint\n\n'
            '_แก้ไขได้ที่หน้า Health > Timeline_',
```

---

### Step 12: อัปเดต Food Detail Bottom Sheet - แสดงปุ่ม Gemini เสมอ

**ไฟล์:** `lib/features/health/widgets/food_detail_bottom_sheet.dart`
**Action:** EDIT

**แก้เงื่อนไข `canAnalyze`:**

หา:
```dart
    final canAnalyze = hasImage && !entry.isVerified;
```

แทนที่ด้วย:
```dart
    // แสดงปุ่ม Gemini เสมอเมื่อมีรูป (ผู้ใช้อาจต้องการวิเคราะห์ซ้ำ)
    final canAnalyze = hasImage;
```

---

### Step 13: ลบ import GlobalFoodDatabase จาก Diet Tab

**ไฟล์:** `lib/features/health/presentation/health_diet_tab.dart`
**Action:** EDIT

**ลบ 2 บรรทัด import ที่ไม่ใช้แล้ว:**

หาและลบ:
```dart
import '../../../core/data/global_food_database.dart';
import '../widgets/food_search_field.dart';
```

---

## ⚠️ ข้อควรระวัง

1. **ต้องรัน `build_runner`** หลัง Step 1 เสมอ ไม่งั้น compile ไม่ผ่าน
2. **Uninstall app** บนเครื่องทดสอบก่อน install ใหม่ เพราะ Isar schema เปลี่ยน
3. **อย่าลบไฟล์** `global_food_database.dart` และ `food_search_field.dart` จริงในตอนนี้ แค่ลบ import - จะลบจริงใน Phase ถัดไป
4. **ทดสอบ recalculate** ให้แน่ใจว่า: เพิ่มอาหาร → วิเคราะห์ Gemini → ยืนยัน → แก้ไข → เปลี่ยนปริมาณ → kcal เปลี่ยนตาม

---

## ✅ Definition of Done

- [ ] FoodEntry model มี baseCalories, baseProtein, baseCarbs, baseFat
- [ ] `build_runner` รันผ่านไม่มี error
- [ ] ลบ GlobalFoodDatabase ออกจาก LLMService, EditFoodBottomSheet, HealthDietTab
- [ ] AddFoodBottomSheet ไม่มี FoodSearchField แล้ว
- [ ] กดปุ่ม Gemini → แสดง GeminiAnalysisSheet → แก้ปริมาณได้ → kcal เปลี่ยนตาม
- [ ] กด Edit อาหารที่วิเคราะห์แล้ว → เปลี่ยนปริมาณ → kcal recalculate ถูกต้อง
- [ ] ถ่ายรูป → บันทึกได้ด้วยค่า 0 → ปุ่ม Gemini แสดง
- [ ] Chat "กินข้าวผัด" → บันทึกค่า 0 + แสดงคำแนะนำให้ใช้ Gemini
- [ ] UI ไม่กระพริบเมื่อ refresh (ใช้ `refreshFoodProviders`)
- [ ] ปุ่ม Gemini แสดงเสมอเมื่อมีรูป (ไม่สนใจ isVerified)
