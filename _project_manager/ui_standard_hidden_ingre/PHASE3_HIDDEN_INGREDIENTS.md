# 📋 Task: Phase 3 — Hidden Ingredients Feature

## 🎯 เป้าหมาย

เพิ่มฟีเจอร์ "Hidden Ingredients" ให้ผู้ใช้ระบุวัตถุดิบหลักที่รู้ (พร้อมปริมาณ) แล้ว AI จะค้นหาวัตถุดิบย่อยที่มองไม่เห็น (เครื่องปรุง น้ำมัน ซอส) เช่น:
- ซาลาเปา → ผู้ใช้ระบุ "หมูสับ 50g" → AI เพิ่ม "แป้ง, น้ำตาล, ซีอิ๊ว, งา"
- ผัดกระเพรา → ผู้ใช้ระบุ "หมูสับ 100g, ใบกระเพรา 10g" → AI เพิ่ม "น้ำมัน 1 tbsp, น้ำปลา 1 tsp, พริก 3g, กระเทียม 5g"

## System Visualization

```
┌─────────────────────────────────────────────────────────────┐
│                    HIDDEN INGREDIENTS FLOW                    │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────┐    ┌───────────────────────────────┐  │
│  │ ENTRY POINTS     │    │  QuickIngredientsInput        │  │
│  │                  │    │  (Reusable Widget)             │  │
│  │ • FoodDetail     │───▶│                               │  │
│  │   Action Bar     │    │  ┌─────────┬──────┬──────┐   │  │
│  │                  │    │  │ อกไก่    │ 100  │  g   │   │  │
│  │ • Analyze Dialog │───▶│  ├─────────┼──────┼──────┤   │  │
│  │   (before AI)    │    │  │ น้ำปลา  │  1   │ tsp  │   │  │
│  │                  │    │  └─────────┴──────┴──────┘   │  │
│  │ • ImagePreview   │───▶│  [+ เพิ่ม]                    │  │
│  │   (camera/gallery)│   │                               │  │
│  │                  │    │  Common: [น้ำมัน][น้ำปลา]     │  │
│  │ • GeminiSheet    │───▶│         [ซีอิ๊ว][น้ำตาล]     │  │
│  │   (re-analyze)   │    │                               │  │
│  └──────────────────┘    │  [บันทึก]  [ส่งตรวจ AI ✨]    │  │
│                          └───────────────────────────────┘  │
│                                      │                       │
│                                      ▼                       │
│                          ┌───────────────────────────────┐  │
│                          │  GeminiService                 │  │
│                          │  analyzeFoodByName() ───┐      │  │
│                          │  analyzeFoodImage()  ───┤      │  │
│                          │                         ▼      │  │
│                          │  Prompt:                        │  │
│                          │  "USER INGREDIENTS: ..."       │  │
│                          │  "DISCOVER HIDDEN: ..."        │  │
│                          └───────────────────────────────┘  │
│                                      │                       │
│                                      ▼                       │
│                          ┌───────────────────────────────┐  │
│                          │  GeminiAnalysisSheet           │  │
│                          │  (แสดงผลลัพธ์ + re-analyze)    │  │
│                          └───────────────────────────────┘  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## 📂 ไฟล์ที่เกี่ยวข้อง

| Action | ไฟล์ | คำอธิบาย |
|--------|------|---------|
| CREATE | `lib/features/health/widgets/quick_ingredients_input.dart` | Reusable widget กรอกวัตถุดิบด่วน |
| CREATE | `lib/features/health/widgets/hidden_ingredients_sheet.dart` | Bottom sheet สำหรับเปิดจาก FoodDetail |
| EDIT   | `lib/features/health/widgets/food_detail_bottom_sheet.dart` | เพิ่มปุ่ม Ingredients ใน Action Bar |
| EDIT   | `lib/features/health/widgets/gemini_analysis_sheet.dart` | เพิ่มปุ่ม Re-analyze |
| EDIT   | `lib/features/health/presentation/image_analysis_preview_screen.dart` | เพิ่ม collapsible ingredients |
| EDIT   | `lib/core/ai/gemini_service.dart` | analyzeFoodImage รับ userIngredients + prompt |
| EDIT   | `lib/l10n/app_en.arb` | เพิ่ม English strings |
| EDIT   | `lib/l10n/app_th.arb` | เพิ่ม Thai strings |

---

## 🔧 ขั้นตอนการทำงาน

---

### Step 1: สร้าง QuickIngredientsInput Widget

**ไฟล์:** `lib/features/health/widgets/quick_ingredients_input.dart`
**Action:** CREATE
**Explanation:** Reusable widget ที่ embed ได้ทุกที่ สำหรับกรอกวัตถุดิบแบบด่วน

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../core/database/database_service.dart';
import '../models/ingredient.dart';
import '../providers/my_meal_provider.dart';

/// ข้อมูล ingredient แถวหนึ่ง (internal state)
class _IngredientRow {
  final TextEditingController nameController;
  final TextEditingController amountController;
  String unit;

  _IngredientRow({
    String name = '',
    String amount = '',
    this.unit = 'g',
  })  : nameController = TextEditingController(text: name),
        amountController = TextEditingController(text: amount);

  void dispose() {
    nameController.dispose();
    amountController.dispose();
  }

  bool get isValid =>
      nameController.text.trim().isNotEmpty &&
      (double.tryParse(amountController.text) ?? 0) > 0;

  Map<String, dynamic> toMap() => {
        'name': nameController.text.trim(),
        'amount': double.tryParse(amountController.text) ?? 0,
        'unit': unit,
      };
}

/// Common ingredients ที่ใช้บ่อย (กดปุ่มเดียวเพิ่มได้เลย)
class _CommonIngredient {
  final String name;
  final double amount;
  final String unit;

  const _CommonIngredient(this.name, this.amount, this.unit);
}

const _commonIngredients = [
  _CommonIngredient('น้ำมันพืช', 1, 'tbsp'),
  _CommonIngredient('น้ำปลา', 1, 'tsp'),
  _CommonIngredient('ซีอิ๊วขาว', 1, 'tsp'),
  _CommonIngredient('น้ำตาล', 1, 'tsp'),
  _CommonIngredient('กระเทียม', 5, 'g'),
  _CommonIngredient('พริก', 3, 'g'),
  _CommonIngredient('ซอสหอยนางรม', 1, 'tbsp'),
  _CommonIngredient('เกลือ', 1, 'g'),
];

/// Widget ที่ embed ได้ในหลาย context สำหรับกรอกวัตถุดิบ
class QuickIngredientsInput extends ConsumerStatefulWidget {
  /// Pre-fill ingredients (จาก entry.ingredientsJson)
  final List<Map<String, dynamic>>? initialIngredients;

  /// Callback เมื่อ ingredients เปลี่ยน
  final ValueChanged<List<Map<String, dynamic>>>? onChanged;

  /// แสดง common ingredient chips หรือไม่
  final bool showCommonChips;

  /// ขนาดกะทัดรัด (สำหรับ embed ใน dialog)
  final bool compact;

  const QuickIngredientsInput({
    super.key,
    this.initialIngredients,
    this.onChanged,
    this.showCommonChips = true,
    this.compact = false,
  });

  @override
  ConsumerState<QuickIngredientsInput> createState() =>
      QuickIngredientsInputState();
}

class QuickIngredientsInputState
    extends ConsumerState<QuickIngredientsInput> {
  final List<_IngredientRow> _rows = [];
  List<Ingredient> _cachedIngredients = [];

  @override
  void initState() {
    super.initState();

    // Pre-fill จาก initial data
    if (widget.initialIngredients != null) {
      for (final ing in widget.initialIngredients!) {
        _rows.add(_IngredientRow(
          name: ing['name']?.toString() ?? '',
          amount: (ing['amount'] ?? 0).toString(),
          unit: ing['unit']?.toString() ?? 'g',
        ));
      }
    }

    // เริ่มต้นด้วย 1 แถวว่างเสมอ (ถ้าไม่มี prefill)
    if (_rows.isEmpty) {
      _rows.add(_IngredientRow());
    }
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  /// ดึงค่า ingredients ปัจจุบันที่กรอกแล้ว (เฉพาะที่ valid)
  List<Map<String, dynamic>> getIngredients() {
    return _rows.where((r) => r.isValid).map((r) => r.toMap()).toList();
  }

  /// เพิ่มแถวใหม่
  void _addRow({String name = '', String amount = '', String unit = 'g'}) {
    setState(() {
      _rows.insert(0, _IngredientRow(name: name, amount: amount, unit: unit));
    });
    _notifyChange();
  }

  /// ลบแถว
  void _removeRow(int index) {
    if (_rows.length <= 1) return;
    setState(() {
      _rows[index].dispose();
      _rows.removeAt(index);
    });
    _notifyChange();
  }

  /// แจ้ง parent ว่า ingredients เปลี่ยน
  void _notifyChange() {
    widget.onChanged?.call(getIngredients());
  }

  /// เพิ่ม common ingredient (ถ้ายังไม่มี)
  void _addCommonIngredient(_CommonIngredient common) {
    final exists = _rows.any(
      (r) => r.nameController.text.trim().toLowerCase() == common.name.toLowerCase(),
    );
    if (exists) return;

    // ถ้าแถวแรกว่างอยู่ ใส่ลงไปเลย
    if (_rows.length == 1 && _rows.first.nameController.text.isEmpty) {
      setState(() {
        _rows.first.nameController.text = common.name;
        _rows.first.amountController.text = common.amount.toString();
        _rows.first.unit = common.unit;
      });
    } else {
      _addRow(name: common.name, amount: common.amount.toString(), unit: common.unit);
    }
    _notifyChange();
  }

  @override
  Widget build(BuildContext context) {
    _cachedIngredients = ref.watch(allIngredientsProvider).valueOrNull ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Common ingredient chips
        if (widget.showCommonChips) ...[
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: _commonIngredients.map((common) {
              final isAdded = _rows.any(
                (r) => r.nameController.text.trim().toLowerCase() ==
                    common.name.toLowerCase() &&
                    r.amountController.text.isNotEmpty,
              );
              return AppChip(
                label: '${common.name} ${common.amount}${common.unit}',
                icon: isAdded ? Icons.check : Icons.add,
                color: isAdded ? AppColors.success : AppColors.primary,
                isSelected: isAdded,
                compact: true,
                onTap: isAdded ? null : () => _addCommonIngredient(common),
              );
            }).toList(),
          ),
          SizedBox(height: AppSpacing.md),
        ],

        // Ingredient rows
        ...List.generate(_rows.length, (index) {
          return _buildIngredientRow(index, isDark);
        }),

        // Add row button
        SizedBox(height: AppSpacing.sm),
        Center(
          child: TextButton.icon(
            onPressed: () => _addRow(),
            icon: Icon(Icons.add_circle_outline, size: AppSizes.iconMd,
                color: AppColors.primary),
            label: Text(
              'เพิ่มวัตถุดิบ',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientRow(int index, bool isDark) {
    final row = _rows[index];

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          // Name field (with autocomplete)
          Expanded(
            flex: 4,
            child: Autocomplete<String>(
              initialValue: TextEditingValue(text: row.nameController.text),
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text.isEmpty) return const Iterable.empty();
                final query = textEditingValue.text.toLowerCase();
                return _cachedIngredients
                    .where((ing) =>
                        ing.name.toLowerCase().contains(query) ||
                        (ing.nameEn?.toLowerCase().contains(query) ?? false))
                    .map((ing) => ing.name)
                    .take(5);
              },
              onSelected: (selection) {
                row.nameController.text = selection;
                // Auto-fill amount from DB if available
                final matched = _cachedIngredients
                    .where((ing) => ing.name == selection)
                    .firstOrNull;
                if (matched != null && row.amountController.text.isEmpty) {
                  row.amountController.text = matched.baseAmount.toString();
                  row.unit = matched.baseUnit;
                  setState(() {});
                }
                _notifyChange();
              },
              fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                // Sync with our internal controller
                controller.text = row.nameController.text;
                controller.addListener(() {
                  row.nameController.text = controller.text;
                  _notifyChange();
                });

                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  style: TextStyle(fontSize: widget.compact ? 12 : 13),
                  decoration: InputDecoration(
                    hintText: 'ชื่อวัตถุดิบ',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.sm,
                    ),
                    border: OutlineInputBorder(borderRadius: AppRadius.sm),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.sm,
                      borderSide: BorderSide(
                        color: isDark ? AppColors.dividerDark : AppColors.divider,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppRadius.sm,
                      borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(width: AppSpacing.xs),

          // Amount field
          Expanded(
            flex: 2,
            child: TextField(
              controller: row.amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(fontSize: widget.compact ? 12 : 13),
              onChanged: (_) => _notifyChange(),
              decoration: InputDecoration(
                hintText: 'ปริมาณ',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                border: OutlineInputBorder(borderRadius: AppRadius.sm),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.sm,
                  borderSide: BorderSide(
                    color: isDark ? AppColors.dividerDark : AppColors.divider,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.sm,
                  borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.xs),

          // Unit dropdown
          SizedBox(
            width: widget.compact ? 52 : 60,
            child: DropdownButtonFormField<String>(
              value: UnitConverter.ensureValid(row.unit),
              isDense: true,
              style: TextStyle(
                fontSize: widget.compact ? 11 : 12,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.sm,
                ),
                border: OutlineInputBorder(borderRadius: AppRadius.sm),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.sm,
                  borderSide: BorderSide(
                    color: isDark ? AppColors.dividerDark : AppColors.divider,
                  ),
                ),
              ),
              items: UnitConverter.allDropdownItems,
              onChanged: (v) {
                if (v != null) {
                  setState(() => row.unit = v);
                  _notifyChange();
                }
              },
            ),
          ),

          // Delete button (ถ้ามีมากกว่า 1 แถว)
          if (_rows.length > 1) ...[
            SizedBox(width: AppSpacing.xxs),
            GestureDetector(
              onTap: () => _removeRow(index),
              child: Icon(Icons.close, size: AppSizes.iconSm,
                  color: AppColors.textTertiary),
            ),
          ],
        ],
      ),
    );
  }
}
```

---

### Step 2: สร้าง HiddenIngredientsSheet

**ไฟล์:** `lib/features/health/widgets/hidden_ingredients_sheet.dart`
**Action:** CREATE
**Explanation:** Bottom sheet เปิดจาก FoodDetailBottomSheet สำหรับระบุวัตถุดิบที่รู้ มี 2 ปุ่ม: Save / Send to AI

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../models/food_entry.dart';
import 'quick_ingredients_input.dart';

class HiddenIngredientsSheet extends ConsumerStatefulWidget {
  final FoodEntry entry;
  final Function(FoodEntry updatedEntry)? onSaveOnly;
  final Function(FoodEntry entry, List<Map<String, dynamic>> ingredients)? onAnalyze;

  const HiddenIngredientsSheet({
    super.key,
    required this.entry,
    this.onSaveOnly,
    this.onAnalyze,
  });

  /// แสดง sheet — เรียกใช้ง่าย
  static Future<void> show({
    required BuildContext context,
    required FoodEntry entry,
    Function(FoodEntry)? onSaveOnly,
    Function(FoodEntry, List<Map<String, dynamic>>)? onAnalyze,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HiddenIngredientsSheet(
        entry: entry,
        onSaveOnly: onSaveOnly,
        onAnalyze: onAnalyze,
      ),
    );
  }

  @override
  ConsumerState<HiddenIngredientsSheet> createState() =>
      _HiddenIngredientsSheetState();
}

class _HiddenIngredientsSheetState
    extends ConsumerState<HiddenIngredientsSheet> {
  final _inputKey = GlobalKey<QuickIngredientsInputState>();

  List<Map<String, dynamic>>? _initialIngredients;

  @override
  void initState() {
    super.initState();
    _initialIngredients = _parseExistingIngredients();
  }

  List<Map<String, dynamic>>? _parseExistingIngredients() {
    if (widget.entry.ingredientsJson == null ||
        widget.entry.ingredientsJson!.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(widget.entry.ingredientsJson!) as List;
      return decoded
          .map((e) => <String, dynamic>{
                'name': e['name'] ?? '',
                'amount': (e['amount'] ?? 0).toDouble(),
                'unit': e['unit'] ?? 'g',
              })
          .toList();
    } catch (_) {
      return null;
    }
  }

  void _handleSaveOnly() {
    final ingredients = _inputKey.currentState?.getIngredients() ?? [];
    if (ingredients.isEmpty) {
      Navigator.pop(context);
      return;
    }

    // สร้าง ingredientsJson แบบง่าย (ไม่มี nutrition — จะได้จาก AI ทีหลัง)
    final jsonStr = jsonEncode(ingredients);
    final updated = widget.entry..ingredientsJson = jsonStr;

    widget.onSaveOnly?.call(updated);
    Navigator.pop(context);
  }

  void _handleAnalyze() {
    final ingredients = _inputKey.currentState?.getIngredients() ?? [];
    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเพิ่มวัตถุดิบอย่างน้อย 1 รายการ'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    Navigator.pop(context);
    widget.onAnalyze?.call(widget.entry, ingredients);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: AppSpacing.paddingLg,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.xl,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
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
            SizedBox(height: AppSpacing.lg),

            // Header
            Row(
              children: [
                Icon(Icons.restaurant_menu_rounded,
                    color: AppColors.health, size: AppSizes.iconLg),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ระบุวัตถุดิบที่รู้',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.entry.foodName,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.sm),

            // Description
            Container(
              padding: AppSpacing.paddingMd,
              decoration: BoxDecoration(
                color: AppColors.ai.withValues(alpha: 0.06),
                borderRadius: AppRadius.md,
                border: Border.all(color: AppColors.ai.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, size: AppSizes.iconMd,
                      color: AppColors.ai),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'ใส่วัตถุดิบหลักที่คุณรู้ แล้ว AI จะค้นหาเครื่องปรุง น้ำมัน ซอส และวัตถุดิบย่อยที่ซ่อนอยู่ให้',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg),

            // Quick Ingredients Input
            QuickIngredientsInput(
              key: _inputKey,
              initialIngredients: _initialIngredients,
              showCommonChips: true,
            ),

            SizedBox(height: AppSpacing.xxl),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: AppButton.outlined(
                    label: 'บันทึกเฉยๆ',
                    icon: Icons.save_outlined,
                    onPressed: _handleSaveOnly,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: AppButton.ai(
                    label: 'ส่งตรวจ AI',
                    icon: Icons.auto_awesome_rounded,
                    onPressed: _handleAnalyze,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### Step 3: เพิ่มปุ่ม Ingredients ใน FoodDetailBottomSheet

**ไฟล์:** `lib/features/health/widgets/food_detail_bottom_sheet.dart`
**Action:** EDIT

**3.1 เพิ่ม import:**

```dart
import 'hidden_ingredients_sheet.dart';
```

**3.2 เพิ่มปุ่มที่ 4 ใน `_buildActionBar()`:**

ค้นหา (ใน `_buildActionBar` method, ประมาณบรรทัด 1003):

```dart
      child: Row(
        children: [
          // Edit button
          Expanded(
            child: _buildActionButton(
              icon: Icons.edit_rounded,
              label: 'Edit',
              color: AppColors.primary,
              isDark: isDark,
              onTap: _handleEdit,
            ),
          ),
          const SizedBox(width: 4),
          // AI Analysis button
          Expanded(
            child: _buildActionButton(
              icon: Icons.auto_awesome_rounded,
              label: 'AI',
              color: AppColors.ai,
              isDark: isDark,
              onTap: _handleAnalyze,
              isLoading: _isAnalyzing,
            ),
          ),
          const SizedBox(width: 4),
          // Delete button
          Expanded(
            child: _buildActionButton(
              icon: Icons.delete_outline_rounded,
              label: 'Delete',
              color: AppColors.error,
              isDark: isDark,
              onTap: _handleDelete,
            ),
          ),
        ],
      ),
```

แทนด้วย (เพิ่ม Ingredients button):

```dart
      child: Row(
        children: [
          // Edit button
          Expanded(
            child: _buildActionButton(
              icon: Icons.edit_rounded,
              label: 'Edit',
              color: AppColors.primary,
              isDark: isDark,
              onTap: _handleEdit,
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          // Ingredients button (NEW)
          Expanded(
            child: _buildActionButton(
              icon: Icons.restaurant_menu_rounded,
              label: 'Ingr.',
              color: AppColors.health,
              isDark: isDark,
              onTap: _handleIngredients,
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          // AI Analysis button
          Expanded(
            child: _buildActionButton(
              icon: Icons.auto_awesome_rounded,
              label: 'AI',
              color: AppColors.ai,
              isDark: isDark,
              onTap: _handleAnalyze,
              isLoading: _isAnalyzing,
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          // Delete button
          Expanded(
            child: _buildActionButton(
              icon: Icons.delete_outline_rounded,
              label: 'Delete',
              color: AppColors.error,
              isDark: isDark,
              onTap: _handleDelete,
            ),
          ),
        ],
      ),
```

**3.3 เพิ่ม `_handleIngredients` method:**

เพิ่มก่อน `_handleEdit()` method:

```dart
  void _handleIngredients() {
    HiddenIngredientsSheet.show(
      context: context,
      entry: widget.entry,
      onSaveOnly: (updatedEntry) async {
        final notifier = ref.read(foodEntriesNotifierProvider.notifier);
        await notifier.updateFoodEntry(updatedEntry);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('บันทึกวัตถุดิบแล้ว'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      onAnalyze: (entry, ingredients) {
        // ปิด FoodDetail sheet ก่อน แล้ว trigger analyze พร้อม ingredients
        Navigator.pop(context, {
          'action': 'analyzeWithIngredients',
          'entry': entry,
          'userIngredients': ingredients,
        });
      },
    );
  }
```

---

### Step 4: เพิ่ม Quick Ingredients ใน Analyze Confirmation Dialog

**ไฟล์:** `lib/features/health/widgets/food_detail_bottom_sheet.dart`
**Action:** EDIT

**4.1 เพิ่ม import** (ถ้ายังไม่มี):
```dart
import 'quick_ingredients_input.dart';
```

**4.2 แก้ `_showAnalyzeConfirmation` method:**

ค้นหา method `_showAnalyzeConfirmation` (ประมาณบรรทัด 1490+)

เพิ่ม state variable สำหรับ ingredients:

หลัง `FoodSearchMode searchMode = entry.searchMode;` เพิ่ม:
```dart
    final ingredientsInputKey = GlobalKey<QuickIngredientsInputState>();
    final existingIngredients = _extractIngredientsFromJson(entry);
    List<Map<String, dynamic>>? prefillIngredients = existingIngredients.userIngredients;
```

**4.3 เพิ่ม QuickIngredientsInput ใน dialog:**

ค้นหา block ที่มี Energy warning (ประมาณบรรทัด 1621):
```dart
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.08),
```

เพิ่ม **ก่อน** Energy warning block:
```dart
                      // Quick Ingredients Section
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: Row(
                          children: [
                            Icon(Icons.restaurant_menu_rounded,
                                size: AppSizes.iconMd, color: AppColors.health),
                            SizedBox(width: AppSpacing.sm),
                            Text('ระบุวัตถุดิบที่รู้ (optional)',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                        children: [
                          QuickIngredientsInput(
                            key: ingredientsInputKey,
                            initialIngredients: prefillIngredients,
                            showCommonChips: true,
                            compact: true,
                          ),
                          SizedBox(height: AppSpacing.md),
                        ],
                      ),
                      SizedBox(height: AppSpacing.md),
```

**4.4 แก้ return value ของ dialog ให้รวม ingredients:**

ค้นหา:
```dart
                              Navigator.pop(ctx, {
                                'foodName': foodNameController.text.trim(),
                                'quantity': double.tryParse(
                                        quantityController.text.trim()) ??
                                    0.0,
                                'unit': selectedUnit,
                                'searchMode': searchMode,
                              });
```

แทนด้วย:
```dart
                              final quickIngredients = ingredientsInputKey
                                  .currentState?.getIngredients();
                              Navigator.pop(ctx, {
                                'foodName': foodNameController.text.trim(),
                                'quantity': double.tryParse(
                                        quantityController.text.trim()) ??
                                    0.0,
                                'unit': selectedUnit,
                                'searchMode': searchMode,
                                'userIngredients': quickIngredients,
                              });
```

**4.5 แก้ `_handleAnalyze` เพื่อส่ง userIngredients ไป Gemini:**

ค้นหา (ประมาณบรรทัด 1167):
```dart
    final String confirmedFoodName = analyzeParams['foodName'] as String;
    final double confirmedQuantity = analyzeParams['quantity'] as double;
    final String confirmedUnit = analyzeParams['unit'] as String;
    final FoodSearchMode confirmedSearchMode =
        analyzeParams['searchMode'] as FoodSearchMode? ?? FoodSearchMode.normal;
```

เพิ่มหลังบรรทัดสุดท้าย:
```dart
    final List<Map<String, dynamic>>? dialogIngredients =
        analyzeParams['userIngredients'] as List<Map<String, dynamic>>?;
```

ค้นหา (image analysis call, ประมาณบรรทัด 1223):
```dart
        result = await GeminiService.analyzeFoodImage(
          File(entry.imagePath!),
          foodName: confirmedFoodName.isNotEmpty ? confirmedFoodName : null,
          quantity: confirmedQuantity > 0 ? confirmedQuantity : null,
          unit: confirmedUnit,
          searchMode: confirmedSearchMode,
        );
```

แทนด้วย:
```dart
        result = await GeminiService.analyzeFoodImage(
          File(entry.imagePath!),
          foodName: confirmedFoodName.isNotEmpty ? confirmedFoodName : null,
          quantity: confirmedQuantity > 0 ? confirmedQuantity : null,
          unit: confirmedUnit,
          searchMode: confirmedSearchMode,
          userIngredients: dialogIngredients,
        );

        // Post-process: enforce user-specified amounts
        if (result != null && dialogIngredients != null && dialogIngredients.isNotEmpty) {
          result = GeminiService.enforceUserIngredientAmounts(result, dialogIngredients);
        }
```

ค้นหา (text analysis call, ประมาณบรรทัด 1237):
```dart
        result = await GeminiService.analyzeFoodByName(
          confirmedFoodName.isNotEmpty ? confirmedFoodName : entry.foodName,
          servingSize:
              confirmedQuantity > 0 ? confirmedQuantity : entry.servingSize,
          servingUnit: confirmedUnit,
          searchMode: confirmedSearchMode,
          ingredientNames: extracted.names,
          userIngredients: extracted.userIngredients,
        );
```

แทนด้วย (merge dialog ingredients กับ existing):
```dart
        // Merge existing ingredients กับ dialog ingredients
        List<Map<String, dynamic>>? mergedIngredients = extracted.userIngredients;
        if (dialogIngredients != null && dialogIngredients.isNotEmpty) {
          mergedIngredients = [...?mergedIngredients, ...dialogIngredients];
          // Deduplicate by name (keep dialog version if duplicate)
          final seen = <String>{};
          mergedIngredients = mergedIngredients.reversed.where((ing) {
            final name = (ing['name'] ?? '').toString().toLowerCase();
            return seen.add(name);
          }).toList().reversed.toList();
        }

        result = await GeminiService.analyzeFoodByName(
          confirmedFoodName.isNotEmpty ? confirmedFoodName : entry.foodName,
          servingSize:
              confirmedQuantity > 0 ? confirmedQuantity : entry.servingSize,
          servingUnit: confirmedUnit,
          searchMode: confirmedSearchMode,
          ingredientNames: extracted.names,
          userIngredients: mergedIngredients,
        );
```

---

### Step 5: แก้ GeminiService — analyzeFoodImage รับ userIngredients

**ไฟล์:** `lib/core/ai/gemini_service.dart`
**Action:** EDIT

**5.1 เพิ่ม parameter ใน `analyzeFoodImage`:**

ค้นหา function signature:
```dart
  static Future<FoodAnalysisResult?> analyzeFoodImage(
    File imageFile, {
    EnergyService? energyService,
    String? foodName,
    double? quantity,
    String? unit,
    FoodSearchMode searchMode = FoodSearchMode.normal,
  })
```

แทนด้วย:
```dart
  static Future<FoodAnalysisResult?> analyzeFoodImage(
    File imageFile, {
    EnergyService? energyService,
    String? foodName,
    double? quantity,
    String? unit,
    FoodSearchMode searchMode = FoodSearchMode.normal,
    List<Map<String, dynamic>>? userIngredients,
  })
```

**5.2 ส่ง userIngredients ไปใน prompt:**

ค้นหาใน `analyzeFoodImage` body ที่สร้าง prompt (อาจเป็น `_getImageAnalysisPrompt()`):

ใน method `_getImageAnalysisPrompt()` เพิ่ม parameter:

ค้นหา:
```dart
  static String _getImageAnalysisPrompt() {
```

แทนด้วย:
```dart
  static String _getImageAnalysisPrompt({List<Map<String, dynamic>>? userIngredients}) {
```

**5.3 เพิ่ม ingredients hint ใน image prompt:**

เพิ่มภายใน `_getImageAnalysisPrompt` body (ต้นๆ ของ prompt string):

```dart
    String ingredientsHint = '';
    if (userIngredients != null && userIngredients.isNotEmpty) {
      final lines = userIngredients.map((ing) {
        final name = ing['name'] ?? 'Unknown';
        final amount = ing['amount'] ?? 0;
        final unit = ing['unit'] ?? 'g';
        return '  - $name: $amount $unit';
      }).join('\n');
      ingredientsHint = '''

═══════════════════════════════════════════════════════════════════
USER-SPECIFIED INGREDIENTS WITH EXACT AMOUNTS (CRITICAL):
═══════════════════════════════════════════════════════════════════
The user has specified EXACT ingredients and amounts they know are in this food.
These amounts are MORE ACCURATE than visual estimation because the user measured them.

$lines

MANDATORY RULES for user-specified ingredients:
1. You MUST use EXACTLY these amounts — do NOT change them
2. Calculate nutrition values (calories, protein, carbs, fat) for these EXACT amounts
3. Keep the ingredient names similar (you may add cooking state description)
4. You MUST actively discover HIDDEN ingredients not listed above:
   - Seasonings (fish sauce, soy sauce, MSG, sugar, salt, pepper)
   - Cooking oils/fats used in preparation
   - Marinades, pastes, or sauce bases
   - Small garnishes (cilantro, lime, chili flakes)
   - Binding agents (flour, starch, egg wash)
5. Added hidden ingredients should have amounts proportional to the dish
6. The total nutrition = sum of user's ingredients + discovered hidden ingredients
═══════════════════════════════════════════════════════════════════
''';
    }
```

จากนั้นเพิ่ม `$ingredientsHint` ลงใน prompt string (ต่อจาก food name/description):

ค้นหาจุดที่เหมาะสมใน prompt string แล้วเพิ่ม `$ingredientsHint` เข้าไป

**5.4 แก้ตรงที่เรียก `_getImageAnalysisPrompt()`:**

ค้นหาทุกที่ที่เรียก `_getImageAnalysisPrompt()` ใน `analyzeFoodImage` body:

```dart
_getImageAnalysisPrompt()
```

แทนด้วย:
```dart
_getImageAnalysisPrompt(userIngredients: userIngredients)
```

**5.5 เพิ่ม post-processing ใน analyzeFoodImage:**

หลังจากได้ result สำเร็จ ก่อน return:

```dart
    // Post-process: enforce user-specified amounts (ถ้ามี)
    if (result != null && userIngredients != null && userIngredients.isNotEmpty) {
      result = enforceUserIngredientAmounts(result, userIngredients);
    }
```

---

### Step 6: ปรับ Prompt ให้เน้น Hidden Ingredients Discovery

**ไฟล์:** `lib/core/ai/gemini_service.dart`
**Action:** EDIT

**6.1 ปรับ text analysis prompt:**

ค้นหาใน `_getTextAnalysisPrompt` (ประมาณบรรทัด 1556):
```dart
4. You MAY add additional hidden ingredients the user likely forgot (cooking oil, seasonings, sauces)
```

แทนด้วย:
```dart
4. You MUST actively discover HIDDEN ingredients the user likely forgot:
   - Cooking oils/fats (type & amount based on cooking method)
   - Seasonings (fish sauce, soy sauce, MSG, sugar, salt, pepper)
   - Marinades, pastes, or sauce bases
   - Small garnishes (cilantro, lime, chili)
   - Binding agents (flour, starch, egg wash)
   Mark discovered hidden ingredients with detail: "hidden - estimated"
```

---

### Step 7: เพิ่ม Collapsible Ingredients ใน ImageAnalysisPreviewScreen

**ไฟล์:** `lib/features/health/presentation/image_analysis_preview_screen.dart`
**Action:** EDIT

**7.1 เพิ่ม imports:**

```dart
import 'package:miro_hybrid/features/health/widgets/quick_ingredients_input.dart';
```

**7.2 เพิ่ม state variable:**

ค้นหา state variables (ประมาณบรรทัด 43-49):

เพิ่มหลัง `bool _isSaving = false;`:
```dart
  final _ingredientsInputKey = GlobalKey<QuickIngredientsInputState>();
  bool _showIngredients = false;
```

**7.3 เพิ่ม collapsible section ใน UI:**

ค้นหาใน `build` method ตรงที่อยู่ระหว่าง quantity fields กับ buttons (หลัง unit selector, ก่อน action buttons)

เพิ่ม:
```dart
            SizedBox(height: AppSpacing.lg),

            // Collapsible ingredients section
            InkWell(
              onTap: () => setState(() => _showIngredients = !_showIngredients),
              borderRadius: AppRadius.md,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.health.withValues(alpha: 0.06),
                  borderRadius: AppRadius.md,
                  border: Border.all(color: AppColors.health.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.restaurant_menu_rounded,
                        size: AppSizes.iconMd, color: AppColors.health),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'ระบุวัตถุดิบที่รู้ (optional)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.health,
                        ),
                      ),
                    ),
                    Icon(
                      _showIngredients ? Icons.expand_less : Icons.expand_more,
                      color: AppColors.health,
                    ),
                  ],
                ),
              ),
            ),

            if (_showIngredients) ...[
              SizedBox(height: AppSpacing.md),
              QuickIngredientsInput(
                key: _ingredientsInputKey,
                showCommonChips: true,
                compact: true,
              ),
            ],
```

**7.4 แก้ `_saveAndAnalyze` ให้ส่ง userIngredients:**

ค้นหาใน `_saveAndAnalyze`:
```dart
      final result = await GeminiService.analyzeFoodImage(
        File(_permanentImagePath ?? widget.imageFile.path),
        foodName: foodName.isEmpty ? null : foodName,
        quantity: quantity,
        unit: _selectedUnit,
        searchMode: _searchMode,
      );
```

แทนด้วย:
```dart
      // ดึง user-specified ingredients (ถ้ามี)
      final userIngredients = _ingredientsInputKey.currentState?.getIngredients();

      var result = await GeminiService.analyzeFoodImage(
        File(_permanentImagePath ?? widget.imageFile.path),
        foodName: foodName.isEmpty ? null : foodName,
        quantity: quantity,
        unit: _selectedUnit,
        searchMode: _searchMode,
        userIngredients: userIngredients != null && userIngredients.isNotEmpty
            ? userIngredients
            : null,
      );

      // Post-process: enforce user-specified amounts
      if (result != null && userIngredients != null && userIngredients.isNotEmpty) {
        result = GeminiService.enforceUserIngredientAmounts(result, userIngredients);
      }
```

---

### Step 8: เพิ่ม Re-analyze ใน GeminiAnalysisSheet

**ไฟล์:** `lib/features/health/widgets/gemini_analysis_sheet.dart`
**Action:** EDIT

**8.1 เพิ่ม import:**
```dart
import 'quick_ingredients_input.dart';
```

**8.2 เพิ่ม state variables:**

ค้นหา state variables ของ class:

เพิ่ม:
```dart
  bool _showAddIngredients = false;
  final _reanalyzeInputKey = GlobalKey<QuickIngredientsInputState>();
```

**8.3 เพิ่ม callback parameter:**

ค้นหา class constructor parameters:

เพิ่ม:
```dart
  final Function(String foodName, double servingSize, String servingUnit,
      List<Map<String, dynamic>> ingredients)? onReanalyze;
```

**8.4 เพิ่มปุ่ม Re-analyze ก่อน Confirm/Cancel buttons:**

ค้นหาบรรทัดก่อน `// Confirm + Cancel buttons` (ประมาณบรรทัด 885):

เพิ่ม **ก่อน** `// Confirm + Cancel buttons`:
```dart
            // Re-analyze with extra ingredients
            Container(
              width: double.infinity,
              padding: AppSpacing.paddingMd,
              decoration: BoxDecoration(
                color: AppColors.ai.withValues(alpha: 0.04),
                borderRadius: AppRadius.md,
                border: Border.all(color: AppColors.ai.withValues(alpha: 0.1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => setState(() =>
                        _showAddIngredients = !_showAddIngredients),
                    child: Row(
                      children: [
                        Icon(Icons.add_circle_outline,
                            size: AppSizes.iconMd, color: AppColors.ai),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'เพิ่มวัตถุดิบ & วิเคราะห์ใหม่',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ai,
                            ),
                          ),
                        ),
                        Icon(
                          _showAddIngredients
                              ? Icons.expand_less
                              : Icons.expand_more,
                          color: AppColors.ai,
                        ),
                      ],
                    ),
                  ),
                  if (_showAddIngredients) ...[
                    SizedBox(height: AppSpacing.md),
                    QuickIngredientsInput(
                      key: _reanalyzeInputKey,
                      showCommonChips: true,
                      compact: true,
                    ),
                    SizedBox(height: AppSpacing.md),
                    AppButton.ai(
                      label: 'วิเคราะห์ใหม่ (1 Energy)',
                      icon: Icons.auto_awesome_rounded,
                      size: AppButtonSize.small,
                      onPressed: _handleReanalyze,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg),
```

**8.5 เพิ่ม `_handleReanalyze` method:**

```dart
  void _handleReanalyze() {
    final ingredients = _reanalyzeInputKey.currentState?.getIngredients() ?? [];
    if (ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเพิ่มวัตถุดิบอย่างน้อย 1 รายการ'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final foodName = _nameController.text.trim();
    final servingSize = double.tryParse(_servingSizeController.text) ?? 1;
    final servingUnit = _servingUnit;

    Navigator.pop(context);
    widget.onReanalyze?.call(foodName, servingSize, servingUnit, ingredients);
  }
```

---

### Step 9: เพิ่ม Localization Strings

**ไฟล์:** `lib/l10n/app_en.arb`
**Action:** EDIT

เพิ่มก่อน `}` สุดท้าย:

```json
  "specifyIngredients": "Specify Known Ingredients",
  "specifyIngredientsOptional": "Specify known ingredients (optional)",
  "specifyIngredientsHint": "Enter the ingredients you know, and AI will discover hidden seasonings, oils, and sauces for you.",
  "addIngredient": "Add Ingredient",
  "saveOnly": "Save Only",
  "sendToAi": "Send to AI",
  "reanalyzeWithIngredients": "Add Ingredients & Re-analyze",
  "reanalyzeButton": "Re-analyze (1 Energy)",
  "ingredientsSaved": "Ingredients saved",
  "pleaseAddAtLeastOneIngredient": "Please add at least 1 ingredient",
  "hiddenIngredientsDiscovered": "Hidden ingredients discovered by AI"
```

**ไฟล์:** `lib/l10n/app_th.arb`
**Action:** EDIT

เพิ่มก่อน `}` สุดท้าย:

```json
  "specifyIngredients": "ระบุวัตถุดิบที่รู้",
  "specifyIngredientsOptional": "ระบุวัตถุดิบที่รู้ (optional)",
  "specifyIngredientsHint": "ใส่วัตถุดิบหลักที่คุณรู้ แล้ว AI จะค้นหาเครื่องปรุง น้ำมัน ซอส และวัตถุดิบย่อยที่ซ่อนอยู่ให้",
  "addIngredient": "เพิ่มวัตถุดิบ",
  "saveOnly": "บันทึกเฉยๆ",
  "sendToAi": "ส่งตรวจ AI",
  "reanalyzeWithIngredients": "เพิ่มวัตถุดิบ & วิเคราะห์ใหม่",
  "reanalyzeButton": "วิเคราะห์ใหม่ (1 Energy)",
  "ingredientsSaved": "บันทึกวัตถุดิบแล้ว",
  "pleaseAddAtLeastOneIngredient": "กรุณาเพิ่มวัตถุดิบอย่างน้อย 1 รายการ",
  "hiddenIngredientsDiscovered": "วัตถุดิบที่ AI ค้นพบ"
```

---

## ⚠️ ข้อควรระวัง

1. **QuickIngredientsInput ใช้ GlobalKey** — ทุกที่ที่ embed ต้องมี unique key
2. **อย่าลืม dispose** controllers ใน QuickIngredientsInput
3. **merge ingredients ต้อง deduplicate** — ถ้ามี "น้ำปลา" จาก existing + dialog ให้เก็บอันจาก dialog (ล่าสุด)
4. **Energy check** — ทุก AI call ต้องเช็ค `GeminiService.hasEnergy()` ก่อน
5. **ระวัง import path** — ใช้ relative imports สำหรับ widget ในโฟลเดอร์เดียวกัน, absolute สำหรับ core
6. **compile ทุกครั้งหลังแก้แต่ละ step** — ถ้า error ให้แก้ก่อนไป step ถัดไป

## ✅ Definition of Done

- [ ] `quick_ingredients_input.dart` — ถูกสร้าง, compile ผ่าน, autocomplete ทำงาน
- [ ] `hidden_ingredients_sheet.dart` — ถูกสร้าง, เปิดได้จาก FoodDetail
- [ ] FoodDetailBottomSheet — มีปุ่ม "Ingr." ที่ 4 ปุ่ม, กดแล้วเปิด HiddenIngredientsSheet
- [ ] Analyze Confirmation Dialog — มี ExpansionTile สำหรับระบุวัตถุดิบ
- [ ] Dialog ส่ง `userIngredients` กลับมา → ถูกส่งไป GeminiService
- [ ] `GeminiService.analyzeFoodImage()` — รับ `userIngredients` parameter
- [ ] Image prompt — มี section USER-SPECIFIED INGREDIENTS เมื่อ userIngredients มีค่า
- [ ] ImageAnalysisPreviewScreen — มี collapsible ingredients section
- [ ] GeminiAnalysisSheet — มีปุ่ม "เพิ่มวัตถุดิบ & วิเคราะห์ใหม่"
- [ ] Localization — strings EN/TH เพิ่มครบ
- [ ] `dart analyze` ไม่มี error
- [ ] แอป compile ได้ปกติ

## 🚀 ต้อง Deploy หรือไม่?

- [x] ไม่ต้อง Deploy (Flutter client-side only)
- [ ] ต้อง Deploy Firebase Functions
- [ ] ต้อง Deploy Firestore Rules

## 📋 หลัง Phase 3 เสร็จ

แจ้ง Senior (Planner) เพื่อ:
1. ตรวจงาน (review code quality)
2. ทดสอบ flow ทั้งหมด
3. เริ่ม Phase 4 — Migrate Rest of App
