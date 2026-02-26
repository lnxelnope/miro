# Background Analysis Migration Notes

## สถานะ: กลุ่ม A + B เสร็จแล้ว

---

## สรุปสิ่งที่ทำ (กลุ่ม A — Batch Analysis → Background)

### ปัญหาเดิม
เมื่อผู้ใช้กด Analyze All / Analyze Selected แล้วเปลี่ยนหน้า analysis จะหยุดเพราะ:
- state (`_isAnalyzing`, `_analyzeCurrent` ฯลฯ) ผูกกับ widget — widget ถูก dispose = state หาย
- `WidgetRef` ที่ใช้ save ผลลัพธ์กลับ DB จะ invalid เมื่อ widget หลุดจาก tree

### สิ่งที่แก้ไข

#### ไฟล์ใหม่
- `lib/features/health/providers/analysis_provider.dart`
  - `AnalysisState` — immutable state class: isAnalyzing, total, current, currentItemName, cancelRequested
  - `AnalysisNotifier extends StateNotifier<AnalysisState>` — ถือ `Ref` ระดับ provider (ไม่ผูกกับ widget)
  - **Queue-based**: รองรับหลาย job พร้อมกัน — job ใหม่เข้าคิวรอ ไม่ชนกัน
  - `analysisProvider` — StateNotifierProvider ระดับ global
  - energy check ทำภายใน notifier ก่อนเริ่ม analyze ทุก job

#### ไฟล์ที่แก้ไข (กลุ่ม A)
1. **`lib/core/utils/batch_analysis_helper.dart`**
   - `WidgetRef` → `Ref` ทั้ง 3 จุด: `checkEnergy()`, `autoSaveToDatabase()`, `analyzeEntries()`
   
2. **`lib/features/home/presentation/basic_mode_tab.dart`**
   - ลบ state 5 ตัว → `ref.watch(analysisProvider)` แทน
   - `_startBatchAnalysis()` → fire-and-forget `enqueue()`

3. **`lib/features/health/presentation/health_timeline_tab.dart`**
   - เหมือน basic_mode_tab — fire-and-forget `enqueue()`

4. **`lib/features/health/widgets/meal_section.dart`**
   - `_analyzeSelected()` → fire-and-forget `enqueue()`
   - `_analyzeSingleEntry()` → fire-and-forget `enqueue([entry])`
   - ลบ `_autoSaveToDatabase()`, `_extractIngredientsFromJson()`, `_getUniqueMealName()` (ไม่ใช้แล้ว)
   - ลบ import: `gemini_service`, `usage_limiter`, `energy_provider`, `my_meal`, `my_meal_provider`

---

## สรุปสิ่งที่ทำ (กลุ่ม B — Single Item Analysis → Background)

### UX ใหม่
ผู้ใช้ถ่ายรูป / เลือกจาก Gallery / scan label / พิมพ์ชื่ออาหาร → กด Analyze →
**กลับหน้าหลักทันที** → เห็น progress bar ที่แถบ Analyze All ทำงานอยู่เบื้องหลัง

### ไฟล์ที่แก้ไข (กลุ่ม B)

#### 1. `lib/features/health/presentation/food_preview_screen.dart`
- `_analyzeFood()` → save entry (unanalyzed) → `enqueue([entry])` → `Navigator.pop()`
- ลบ `PopScope` lock-screen (ไม่จำเป็นแล้ว)
- ลบ `_onWillPop()` dialog
- ลบ import: `gemini_service`, `usage_limiter`, `no_energy_dialog`
- เพิ่ม import: `analysis_provider`

#### 2. `lib/features/health/presentation/image_analysis_preview_screen.dart`
- `_saveAndAnalyze()` → save entry → `enqueue([entry])` → `popUntil(isFirst)`
- ลบ loading dialog + GeminiAnalysisSheet (ผลจะ auto-apply ในเบื้องหลัง)
- ลบ import: `dart:convert`, `gemini_service`, `usage_limiter`, `database_service`, `gemini_analysis_sheet`, `no_energy_dialog`, `energy_provider`, `my_meal_provider`, `app_tokens`
- เพิ่ม import: `analysis_provider`

#### 3. `lib/features/health/presentation/nutrition_label_screen.dart`
- `_analyzeLabel()` → create placeholder entry (foodName='Nutrition Label', searchMode=product) → save → `enqueue([entry])` → `Navigator.pop()`
- ลบ loading dialog + GeminiAnalysisSheet
- ลบ import: `gemini_service`, `gemini_analysis_sheet`, `my_meal_provider`
- เพิ่ม import: `analysis_provider`

#### 4. `lib/features/health/widgets/add_food_bottom_sheet.dart`
- `_saveAndAnalyze()` → save entry (with food name, serving, ingredients but no nutrition) → `enqueue([entry])` → `Navigator.pop()`
- ลบ GeminiService call + energy check + result display
- เพิ่ม import: `analysis_provider`
- **หมายเหตุ**: ingredient lookup analysis (กดลูกศรข้าง ingredient) ยังคงใช้ GeminiService ตรงๆ — เพราะต้องการ result ทันทีเพื่อ fill ค่า calorie/protein/etc. ของ ingredient

#### 5. `lib/features/health/widgets/food_detail_bottom_sheet.dart`
- `_handleAnalyze()` → update entry with confirmed params → `enqueue([entry])` → `Navigator.pop()`
- ยังคงแสดง confirmation dialog (ให้ user ยืนยัน foodName/serving/searchMode ก่อน enqueue)
- ลบ loading dialog + GeminiAnalysisSheet + inline analysis logic
- ลบ import: `gemini_service`, `usage_limiter`, `no_energy_dialog`, `energy_provider`, `database_service`, `gemini_analysis_sheet`, `my_meal_provider`
- เพิ่ม import: `analysis_provider`

---

## Architecture Diagram (Final)

```
┌──────────────────────────────────────────────────────────┐
│                      Widget Layer                        │
│                                                          │
│  basic_mode_tab  ─┐  ref.watch(analysisProvider)         │
│  timeline_tab    ─┤  ref.read(analysisProvider.notifier)  │
│  meal_section    ─┤    .enqueue(entries, date)            │
│  food_preview    ─┤    .cancel()                          │
│  image_preview   ─┤                                       │
│  nutrition_label ─┤  save entry → enqueue → pop back     │
│  add_food_sheet  ─┤                                       │
│  food_detail     ─┘                                       │
│                                                          │
│  ⚠️ ยกเว้น: ingredient lookup ใน add_food_sheet          │
│     ยังใช้ GeminiService ตรงๆ (ต้องการ result ทันที)      │
└────────────────────────────┬─────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────┐
│              AnalysisNotifier (global, queue-based)      │
│              lib/features/health/providers/              │
│              analysis_provider.dart                      │
│                                                          │
│  - Queue: jobs เข้าคิว — process ทีละ job                │
│  - ถ้า batch กำลังทำ + user ถ่ายรูปใหม่ → เข้าคิวรอ      │
│  - Progress: current/total รวมทุก job ในคิว              │
│  - Energy check ก่อน process แต่ละ job                   │
│  - cancel() → หยุดหลัง item ปัจจุบันเสร็จ               │
└────────────────────────────┬─────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────┐
│           BatchAnalysisHelper (static)                   │
│           lib/core/utils/batch_analysis_helper.dart      │
│                                                          │
│  - Pure logic: batch/individual analyze                  │
│  - Uses Ref (not WidgetRef) to save results              │
│  - Calls GeminiService, saves to DB, auto-saves meals    │
│  - Refreshes providers after each entry                  │
└──────────────────────────────────────────────────────────┘
```

---

## UX Flow Examples

### ถ่ายรูปอาหาร
```
Camera → FoodPreviewScreen → กด Analyze
  → Save entry (unanalyzed) to DB
  → enqueue([entry]) → เข้าคิว
  → pop กลับหน้าหลัก
  → แถบ progress bar แสดงว่ากำลัง analyze
  → เสร็จ → entry อัปเดตอัตโนมัติ (calories, protein, etc.)
```

### Batch + Single ซ้อนกัน
```
กด Analyze All (5 items) → enqueue([5 entries])
ระหว่างนั้น ถ่ายรูปอีกจาน → enqueue([1 entry]) → เข้าคิวต่อท้าย
Progress: 0/6 → 1/6 → ... → 6/6 → เสร็จ
```

### Ingredient lookup (ยกเว้น — ยังล็อคจอ)
```
เปิด AddFoodBottomSheet → เพิ่ม ingredient "chicken breast"
→ กดลูกศร lookup → GeminiService.analyzeFoodByName() ตรงๆ
→ fill calories/protein/etc. ทันที
→ ไม่ผ่าน queue (ต้องการ result ทันที)
```

---

## Cleanup Notes

### Dead code ที่เหลืออยู่ (ไม่ error แต่ไม่ถูกเรียก)
- `food_preview_screen.dart`:
  - `_isAnalyzing`, `_isCancelled`, `_hasAnalyzed`, `_hasGeminiKey`, `_analysisResult`, `_error` ยังประกาศอยู่
  - `_hasBaseValues`, `_baseCalories`, `_baseProtein`, `_baseCarbs`, `_baseFat` ยังประกาศอยู่
  - UI conditionals ที่อ้าง `_hasAnalyzed`, `_isAnalyzing` ยังอยู่ (แต่ไม่ถูก trigger เพราะค่าเป็น false เสมอ)
  - **ไม่ได้ลบ** เพราะจะต้อง refactor UI ทั้งหน้า — ทำแยก session ได้

- `image_analysis_preview_screen.dart`:
  - `_isAnalyzing`, `_showDetails` อาจไม่ใช้แล้ว
  
- `add_food_bottom_sheet.dart`:
  - `_isAnalyzing` ยังใช้สำหรับ ingredient lookup (ไม่ใช่ dead code)

### Riverpod Version Note
- `flutter_riverpod: 2.6.1` / `riverpod: 2.6.1`
- `Ref` และ `WidgetRef` เป็นคนละ type
- `BatchAnalysisHelper` ใช้ `Ref` → เรียกได้จาก provider เท่านั้น
- Widget ไม่เรียก `BatchAnalysisHelper` ตรงๆ อีกแล้ว — ผ่าน `AnalysisNotifier` เสมอ
