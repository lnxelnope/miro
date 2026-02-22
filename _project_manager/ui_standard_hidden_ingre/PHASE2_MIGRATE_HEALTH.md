# 📋 Task: Phase 2 — Migrate Health Feature ไปใช้ Design System

## 🎯 เป้าหมาย

Migrate bottom sheet ทั้ง 7 ตัว + ImageAnalysisPreviewScreen ในหน้า Health ให้ใช้ Design System จาก Phase 1 แทน hardcoded styles ทั้งหมด

**กฎหลัก:**
- ทุก `Color(0xFF6366F1)` → `AppColors.ai`
- ทุก `Colors.purple` → `AppColors.ai` หรือ `AppColors.premium`
- ทุก `Colors.grey.shadeXXX` → `AppColors.textSecondary` / `AppColors.textTertiary`
- ทุก `Colors.red` → `AppColors.error`
- ทุก `Colors.green` → `AppColors.success`
- ทุก `Colors.orange` → `AppColors.warning`
- ทุก `Colors.blue` → `AppColors.info`
- ทุก `BorderRadius.circular(20)` ใน container → `AppRadius.xl`
- ทุก `BorderRadius.circular(12)` → `AppRadius.md`
- ทุก `BorderRadius.circular(8)` → `AppRadius.sm`
- ทุก `EdgeInsets.all(16)` → `AppSpacing.paddingLg`
- ทุก `SizedBox(height: 16)` → `SizedBox(height: AppSpacing.lg)`
- ทุก `SizedBox(height: 20)` → `SizedBox(height: AppSpacing.xl)`
- ทุก `SizedBox(height: 24)` → `SizedBox(height: AppSpacing.xxl)`

## 📂 ไฟล์ที่เกี่ยวข้อง

| Action | ไฟล์ |
|--------|------|
| EDIT | `lib/features/health/widgets/food_detail_bottom_sheet.dart` |
| EDIT | `lib/features/health/widgets/add_food_bottom_sheet.dart` |
| EDIT | `lib/features/health/widgets/edit_food_bottom_sheet.dart` |
| EDIT | `lib/features/health/widgets/gemini_analysis_sheet.dart` |
| EDIT | `lib/features/health/widgets/edit_ingredient_sheet.dart` |
| EDIT | `lib/features/health/widgets/create_meal_sheet.dart` |
| EDIT | `lib/features/health/presentation/image_analysis_preview_screen.dart` |

---

## ⚠️ IMPORTANT: วิธีทำงาน

งานนี้เป็น **Search & Replace** เป็นหลัก ให้ทำทีละไฟล์ตามลำดับ:

1. เปิดไฟล์
2. เพิ่ม imports ที่จำเป็น (ถ้ายังไม่มี)
3. ทำ Search & Replace ตามกฎด้านบน
4. ตรวจสอบ compile ผ่าน
5. ไปไฟล์ถัดไป

**ห้าม** แก้ logic หรือเพิ่ม/ลบ features — แก้เฉพาะ styling

---

## 🔧 ขั้นตอนการทำงาน

---

### Step 1: Migrate GeminiAnalysisSheet

**ไฟล์:** `lib/features/health/widgets/gemini_analysis_sheet.dart`
**Action:** EDIT
**Explanation:** ไฟล์นี้มี hardcoded colors เยอะที่สุด (Colors.purple, Color(0xFF...) หลายจุด) เริ่มจากไฟล์นี้ก่อน

**1.1 เพิ่ม imports** (ถ้ายังไม่มี):

```dart
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
```

**1.2 แทนที่ hardcoded styles:**

ทำ Search & Replace ทั้งไฟล์ตามนี้ (ใช้ Find & Replace ใน IDE):

| ค้นหา | แทนที่ด้วย | หมายเหตุ |
|-------|-----------|---------|
| `Colors.purple.shade50` | `AppColors.aiLight` | serving box bg |
| `Colors.purple.shade200` | `AppColors.ai.withValues(alpha: 0.3)` | serving box border |
| `Colors.purple` (ที่เป็น icon color) | `AppColors.ai` | header icon, serving icon |
| `const Color(0xFF6366F1)` | `AppColors.ai` | ถ้ามี |
| `BorderRadius.circular(20)` | `AppRadius.xl` | container radius |
| `BorderRadius.circular(12)` | `AppRadius.md` | button, input radius |
| `BorderRadius.circular(8)` | `AppRadius.sm` | small elements |
| `BorderRadius.circular(2)` | `AppRadius.pill` | drag handle |
| `const EdgeInsets.all(16)` | `AppSpacing.paddingLg` | - |
| `const EdgeInsets.all(12)` | `AppSpacing.paddingMd` | - |
| `const SizedBox(height: 16)` | `SizedBox(height: AppSpacing.lg)` | - |
| `const SizedBox(height: 20)` | `SizedBox(height: AppSpacing.xl)` | - |
| `const SizedBox(height: 24)` | `SizedBox(height: AppSpacing.xxl)` | - |
| `const SizedBox(height: 8)` | `SizedBox(height: AppSpacing.sm)` | - |
| `const SizedBox(width: 8)` | `SizedBox(width: AppSpacing.sm)` | - |
| `const SizedBox(width: 12)` | `SizedBox(width: AppSpacing.md)` | - |
| `Colors.grey.shade500` | `AppColors.textSecondary` | - |
| `Colors.grey.shade400` | `AppColors.textTertiary` | - |
| `Colors.grey.shade600` | `AppColors.textSecondary` | - |
| `Colors.grey.shade200` | `AppColors.divider` | - |
| `Colors.grey[600]` | `AppColors.textSecondary` | - |

**1.3 แทนที่ Confirm/Cancel buttons (บรรทัด ~885-916):**

ค้นหา block:
```dart
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _confirm,
                    icon: const Icon(Icons.check, size: 20),
                    label: const Text('Confirm'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
```

แทนด้วย:
```dart
            Row(
              children: [
                Expanded(
                  child: AppButton.outlined(
                    label: 'Cancel',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: AppButton.primary(
                    label: 'Confirm',
                    icon: Icons.check,
                    onPressed: _confirm,
                  ),
                ),
              ],
            ),
```

**1.4 แทนที่ drag handle:**

ค้นหา:
```dart
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
```

แทนด้วย:
```dart
            Center(
              child: Container(
                width: AppSizes.dragHandleWidth,
                height: AppSizes.dragHandleHeight,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: AppRadius.pill,
                ),
              ),
            ),
```

**1.5 แทนที่ container decoration:**

ค้นหา:
```dart
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
```

แทนด้วย:
```dart
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: AppRadius.xl,
      ),
```

**1.6 แทนที่ margin/padding:**

ค้นหา: `margin: const EdgeInsets.all(16),`
แทน: `margin: AppSpacing.paddingLg,`

ค้นหา:
```dart
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
```
แทนด้วย:
```dart
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.xl,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
```

---

### Step 2: Migrate FoodDetailBottomSheet

**ไฟล์:** `lib/features/health/widgets/food_detail_bottom_sheet.dart`
**Action:** EDIT

**2.1 เพิ่ม imports:**

```dart
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
```

**2.2 แทนที่ hardcoded colors ทั้งไฟล์:**

| ค้นหา | แทนที่ด้วย |
|-------|-----------|
| `const Color(0xFF6366F1)` | `AppColors.ai` |
| `Color(0xFF6366F1)` | `AppColors.ai` |
| `BorderRadius.circular(20)` | `AppRadius.xl` |
| `BorderRadius.circular(16)` | `AppRadius.lg` |
| `BorderRadius.circular(12)` | `AppRadius.md` |
| `BorderRadius.circular(8)` | `AppRadius.sm` |
| `Colors.grey[600]` | `AppColors.textSecondary` |
| `Colors.grey.shade600` | `AppColors.textSecondary` |
| `Colors.grey.shade500` | `AppColors.textSecondary` |
| `Colors.grey.shade400` | `AppColors.textTertiary` |
| `Colors.grey.shade300` | `AppColors.divider` |
| `Colors.grey.shade200` | `AppColors.divider` |

**2.3 แทนที่ Action Bar button colors (บรรทัด ~994-1041):**

ค้นหา: `color: const Color(0xFF6366F1),` (AI button)
แทน: `color: AppColors.ai,`

**2.4 แทนที่ spacing SizedBox ทั้งไฟล์:**

| ค้นหา | แทนที่ด้วย |
|-------|-----------|
| `const SizedBox(height: 4)` | `SizedBox(height: AppSpacing.xs)` |
| `const SizedBox(height: 8)` | `SizedBox(height: AppSpacing.sm)` |
| `const SizedBox(height: 12)` | `SizedBox(height: AppSpacing.md)` |
| `const SizedBox(height: 16)` | `SizedBox(height: AppSpacing.lg)` |
| `const SizedBox(height: 20)` | `SizedBox(height: AppSpacing.xl)` |
| `const SizedBox(height: 24)` | `SizedBox(height: AppSpacing.xxl)` |
| `const SizedBox(width: 4)` | `SizedBox(width: AppSpacing.xs)` |
| `const SizedBox(width: 8)` | `SizedBox(width: AppSpacing.sm)` |
| `const SizedBox(width: 12)` | `SizedBox(width: AppSpacing.md)` |
| `const SizedBox(width: 16)` | `SizedBox(width: AppSpacing.lg)` |

**2.5 Analyze Confirmation Dialog buttons (บรรทัด ~1645-1675):**

ค้นหา:
```dart
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx, {
                                'foodName': foodNameController.text.trim(),
                                'quantity': double.tryParse(
                                        quantityController.text.trim()) ??
                                    0.0,
                                'unit': selectedUnit,
                                'searchMode': searchMode,
                              });
                            },
                            icon: const Icon(Icons.auto_awesome_rounded,
                                size: 18),
                            label: const Text('Analyze'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
```

แทนด้วย:
```dart
                          AppButton.ai(
                            label: 'Analyze',
                            icon: Icons.auto_awesome_rounded,
                            isFullWidth: false,
                            onPressed: () {
                              Navigator.pop(ctx, {
                                'foodName': foodNameController.text.trim(),
                                'quantity': double.tryParse(
                                        quantityController.text.trim()) ??
                                    0.0,
                                'unit': selectedUnit,
                                'searchMode': searchMode,
                              });
                            },
                          ),
```

**2.6 Energy warning box (บรรทัด ~1621-1642):**

ค้นหา: `color: Colors.amber.withValues(alpha: 0.08)`
แทน: `color: AppColors.warning.withValues(alpha: 0.08)`

ค้นหา: `color: Colors.amber.withValues(alpha: 0.2)`
แทน: `color: AppColors.warning.withValues(alpha: 0.2)`

---

### Step 3: Migrate AddFoodBottomSheet

**ไฟล์:** `lib/features/health/widgets/add_food_bottom_sheet.dart`
**Action:** EDIT

**3.1 เพิ่ม imports:**

```dart
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
```

**3.2 ทำ Search & Replace เหมือน Step 1 และ 2** — ใช้ตารางเดียวกัน:

- ทุก hardcoded `Color(0xFF...)` → `AppColors.xxx`
- ทุก `Colors.xxx` → `AppColors.xxx`
- ทุก `BorderRadius.circular(N)` → `AppRadius.xxx`
- ทุก `SizedBox(height/width: N)` → `SizedBox(height/width: AppSpacing.xxx)`
- ทุก `EdgeInsets.all(N)` → `AppSpacing.paddingXxx`

**3.3 Save & Analyze button:**

ค้นหา Save & Analyze button ที่ใช้ `ElevatedButton` กับสี purple/indigo:

แทนด้วย:
```dart
AppButton.ai(
  label: L10n.of(context)!.saveAndAnalyze,
  icon: Icons.auto_awesome_rounded,
  isLoading: _isAnalyzing,
  onPressed: _saveAndAnalyze,
)
```

**3.4 Save button:**

ค้นหา main Save button ที่ใช้ `ElevatedButton` กับ `AppColors.primary`:

แทนด้วย:
```dart
AppButton.primary(
  label: L10n.of(context)!.save,
  icon: Icons.save_rounded,
  onPressed: _save,
)
```

---

### Step 4: Migrate EditFoodBottomSheet

**ไฟล์:** `lib/features/health/widgets/edit_food_bottom_sheet.dart`
**Action:** EDIT

ทำเหมือน Step 3 (AddFood) เพราะโครงสร้าง UI คล้ายกัน:

**4.1 เพิ่ม imports** (app_tokens.dart, app_button.dart)

**4.2 ทำ Search & Replace** ตามตารางเดียวกัน

**4.3 แทนที่ปุ่ม Save:**
```dart
AppButton.primary(
  label: L10n.of(context)!.save,
  icon: Icons.save_rounded,
  onPressed: _save,
)
```

---

### Step 5: Migrate EditIngredientSheet

**ไฟล์:** `lib/features/health/widgets/edit_ingredient_sheet.dart`
**Action:** EDIT

**5.1 เพิ่ม imports** (app_tokens.dart, app_button.dart)

**5.2 ทำ Search & Replace** ตามตารางเดียวกัน

**5.3 แทนที่ปุ่ม Save** — เปลี่ยนจาก `AppColors.health` เป็น `AppColors.primary` ให้เหมือนกันทั้งแอป:

```dart
AppButton.primary(
  label: widget.isCreateMode ? 'Create' : 'Save',
  icon: Icons.save_rounded,
  onPressed: _save,
)
```

---

### Step 6: Migrate CreateMealSheet

**ไฟล์:** `lib/features/health/widgets/create_meal_sheet.dart`
**Action:** EDIT

ทำเหมือน Step 5:
- เพิ่ม imports
- Search & Replace สี, spacing, radius
- แทนที่ปุ่ม Save ด้วย `AppButton.primary`

---

### Step 7: Migrate ImageAnalysisPreviewScreen

**ไฟล์:** `lib/features/health/presentation/image_analysis_preview_screen.dart`
**Action:** EDIT

**7.1 เพิ่ม imports:**

```dart
import 'package:miro_hybrid/core/theme/app_tokens.dart';
import 'package:miro_hybrid/core/widgets/app_button.dart';
```

**7.2 ทำ Search & Replace** ตามตารางเดียวกัน

**7.3 แทนที่ปุ่ม Save & Analyze:**

```dart
AppButton.ai(
  label: L10n.of(context)!.saveAndAnalyze,
  icon: Icons.auto_awesome_rounded,
  isLoading: _isAnalyzing,
  onPressed: _saveAndAnalyze,
)
```

**7.4 แทนที่ปุ่ม Save Only:**

```dart
AppButton.outlined(
  label: L10n.of(context)!.saveOnly,
  icon: Icons.save_outlined,
  onPressed: _saveOnly,
)
```

---

## ⚠️ ข้อควรระวัง

1. **ห้ามแก้ logic ใดๆ** — แก้เฉพาะ styling (สี, spacing, radius, ปุ่ม)
2. **ระวัง `const`** — ถ้าเปลี่ยนจาก `const SizedBox(...)` เป็น `SizedBox(height: AppSpacing.lg)` อาจต้องลบ `const` ออก
3. **ระวัง `.withOpacity()` vs `.withValues(alpha:)`** — ใช้ `.withValues(alpha:)` เสมอ (ตาม Flutter 3.x)
4. **ตรวจสอบ Dark Mode** — ถ้าเจอ `isDark ? Colors.white24 : Colors.black12` ให้เปลี่ยนเป็น `isDark ? AppColors.dividerDark : AppColors.divider`
5. **compile ทุกครั้งหลังแก้แต่ละไฟล์** — ถ้า error ให้แก้ก่อนไปไฟล์ถัดไป
6. **ถ้าเจอ `Colors.white`** ใน background ให้เปลี่ยนเป็น `AppColors.surface` (light mode) หรือใช้ `Theme.of(context).cardColor` (auto dark/light)

## ✅ Definition of Done

- [ ] ไฟล์ `gemini_analysis_sheet.dart` — ไม่มี `Color(0xFF...)`, `Colors.purple`, hardcoded spacing
- [ ] ไฟล์ `food_detail_bottom_sheet.dart` — ไม่มี `Color(0xFF6366F1)`, ใช้ `AppRadius` ทั้งหมด
- [ ] ไฟล์ `add_food_bottom_sheet.dart` — ปุ่ม Save/Analyze ใช้ `AppButton`
- [ ] ไฟล์ `edit_food_bottom_sheet.dart` — ปุ่ม Save ใช้ `AppButton`
- [ ] ไฟล์ `edit_ingredient_sheet.dart` — ปุ่มใช้ `AppButton`, สี primary แทน health
- [ ] ไฟล์ `create_meal_sheet.dart` — เหมือน edit_ingredient
- [ ] ไฟล์ `image_analysis_preview_screen.dart` — ปุ่มใช้ `AppButton`
- [ ] `dart analyze lib/features/health/` ไม่มี error
- [ ] แอป compile ได้ปกติ
- [ ] ไม่มี `Colors.purple` หรือ `Color(0xFF6366F1)` เหลือในไฟล์ที่แก้

## 🚀 ต้อง Deploy หรือไม่?

- [x] ไม่ต้อง Deploy (Flutter client-side only)
