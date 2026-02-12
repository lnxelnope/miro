# Step 06: Health Diet Tab

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 1.5 ชั่วโมง
> **ความยาก:** ปานกลาง
> **ต้องทำก่อน:** Step 05 (Health Timeline)

---

## สิ่งที่ต้องทำ

1. สร้าง Diet Tab ที่แสดงอาหารแยกตามมื้อ
2. สร้าง Meal Section Widget
3. สร้าง Add Food Dialog
4. สร้าง Edit Food Dialog
5. เพิ่ม Food Preview Screen (หลังถ่าย/เลือกรูป)

---

## ขั้นตอนที่ 1: สร้าง Diet Tab

**สร้างไฟล์:** `lib/features/health/presentation/health_diet_tab.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/enums.dart';
import '../providers/health_provider.dart';
import '../widgets/daily_summary_card.dart';
import '../widgets/meal_section.dart';
import '../models/food_entry.dart';

class HealthDietTab extends ConsumerStatefulWidget {
  const HealthDietTab({super.key});

  @override
  ConsumerState<HealthDietTab> createState() => _HealthDietTabState();
}

class _HealthDietTabState extends ConsumerState<HealthDietTab> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final foodsAsync = ref.watch(foodEntriesByDateProvider(_selectedDate));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(foodEntriesByDateProvider(_selectedDate));
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Daily Summary
            const DailySummaryCard(),
            
            // Meals
            foodsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
              error: (e, st) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error: $e'),
              ),
              data: (foods) => Column(
                children: [
                  MealSection(
                    mealType: MealType.breakfast,
                    foods: foods.where((f) => f.mealType == MealType.breakfast).toList(),
                    onAddFood: () => _showAddFoodDialog(MealType.breakfast),
                    onEditFood: _showEditFoodDialog,
                    onDeleteFood: _deleteFoodEntry,
                  ),
                  MealSection(
                    mealType: MealType.lunch,
                    foods: foods.where((f) => f.mealType == MealType.lunch).toList(),
                    onAddFood: () => _showAddFoodDialog(MealType.lunch),
                    onEditFood: _showEditFoodDialog,
                    onDeleteFood: _deleteFoodEntry,
                  ),
                  MealSection(
                    mealType: MealType.dinner,
                    foods: foods.where((f) => f.mealType == MealType.dinner).toList(),
                    onAddFood: () => _showAddFoodDialog(MealType.dinner),
                    onEditFood: _showEditFoodDialog,
                    onDeleteFood: _deleteFoodEntry,
                  ),
                  MealSection(
                    mealType: MealType.snack,
                    foods: foods.where((f) => f.mealType == MealType.snack).toList(),
                    onAddFood: () => _showAddFoodDialog(MealType.snack),
                    onEditFood: _showEditFoodDialog,
                    onDeleteFood: _deleteFoodEntry,
                  ),
                ],
              ),
            ),
            
            // Bottom padding
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void _showAddFoodDialog(MealType mealType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddFoodBottomSheet(
        mealType: mealType,
        onSave: (entry) async {
          final notifier = ref.read(foodEntriesNotifierProvider.notifier);
          await notifier.addFoodEntry(entry);
          ref.invalidate(foodEntriesByDateProvider(_selectedDate));
        },
      ),
    );
  }

  void _showEditFoodDialog(FoodEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditFoodBottomSheet(
        entry: entry,
        onSave: (updatedEntry) async {
          final notifier = ref.read(foodEntriesNotifierProvider.notifier);
          await notifier.updateFoodEntry(updatedEntry);
          ref.invalidate(foodEntriesByDateProvider(_selectedDate));
        },
      ),
    );
  }

  Future<void> _deleteFoodEntry(FoodEntry entry) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบรายการ?'),
        content: Text('ต้องการลบ "${entry.foodName}" หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ลบ', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final notifier = ref.read(foodEntriesNotifierProvider.notifier);
      await notifier.deleteFoodEntry(entry.id);
      ref.invalidate(foodEntriesByDateProvider(_selectedDate));
    }
  }
}
```

---

## ขั้นตอนที่ 2: สร้าง Meal Section Widget

**สร้างไฟล์:** `lib/features/health/widgets/meal_section.dart`

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/enums.dart';
import '../models/food_entry.dart';

class MealSection extends StatelessWidget {
  final MealType mealType;
  final List<FoodEntry> foods;
  final VoidCallback onAddFood;
  final Function(FoodEntry) onEditFood;
  final Function(FoodEntry) onDeleteFood;

  const MealSection({
    super.key,
    required this.mealType,
    required this.foods,
    required this.onAddFood,
    required this.onEditFood,
    required this.onDeleteFood,
  });

  @override
  Widget build(BuildContext context) {
    final totalCalories = foods.fold<double>(0, (sum, f) => sum + f.calories);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                mealType.icon,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                mealType.displayName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.health.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${totalCalories.toInt()} kcal',
                  style: const TextStyle(
                    color: AppColors.health,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                color: AppColors.primary,
                onPressed: onAddFood,
              ),
            ],
          ),
          
          // Foods list
          if (foods.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'ยังไม่มีรายการ',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ...foods.map((food) => _buildFoodItem(context, food)),
        ],
      ),
    );
  }

  Widget _buildFoodItem(BuildContext context, FoodEntry food) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => onEditFood(food),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image or icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.health.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.restaurant,
                    color: AppColors.health,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.foodName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${food.servingSize} ${food.servingUnit}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Calories
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${food.calories.toInt()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'kcal',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              
              // Actions
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (value) {
                  if (value == 'edit') {
                    onEditFood(food);
                  } else if (value == 'delete') {
                    onDeleteFood(food);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('แก้ไข'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('ลบ', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## ขั้นตอนที่ 3: สร้าง Add Food Bottom Sheet

**เพิ่มในไฟล์:** `lib/features/health/presentation/health_diet_tab.dart`

**เพิ่มท้ายไฟล์:**

```dart
// ============================================
// ADD FOOD BOTTOM SHEET
// ============================================

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
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController(text: '0');
  final _carbsController = TextEditingController(text: '0');
  final _fatController = TextEditingController(text: '0');
  final _servingSizeController = TextEditingController(text: '1');
  
  String _servingUnit = 'จาน';
  late MealType _selectedMealType;
  bool _showMacros = false;

  @override
  void initState() {
    super.initState();
    _selectedMealType = widget.mealType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
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
            
            // Title
            const Text(
              '🍽️ เพิ่มอาหาร',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Food name
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'ชื่ออาหาร *',
                hintText: 'เช่น ข้าวผัดกุ้ง',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Serving size
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _servingSizeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'ปริมาณ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'จาน', child: Text('จาน')),
                      DropdownMenuItem(value: 'ถ้วย', child: Text('ถ้วย')),
                      DropdownMenuItem(value: 'ชิ้น', child: Text('ชิ้น')),
                      DropdownMenuItem(value: 'กรัม', child: Text('กรัม')),
                      DropdownMenuItem(value: 'แก้ว', child: Text('แก้ว')),
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
            const SizedBox(height: 16),
            
            // Calories
            TextField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'แคลอรี่ (kcal) *',
                prefixText: '🔥 ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Show/hide macros
            InkWell(
              onTap: () => setState(() => _showMacros = !_showMacros),
              child: Row(
                children: [
                  Text(
                    _showMacros ? '▼ Macros' : '▶ Macros (optional)',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            if (_showMacros) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _proteinController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Protein (g)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            
            // Meal type selector
            const Text(
              'มื้ออาหาร',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: MealType.values.map((type) {
                final isSelected = _selectedMealType == type;
                return ChoiceChip(
                  label: Text('${type.icon} ${type.displayName}'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedMealType = type);
                    }
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'บันทึก',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    // Validation
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกชื่ออาหาร')),
      );
      return;
    }
    
    final calories = double.tryParse(_caloriesController.text) ?? 0;
    if (calories <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกแคลอรี่')),
      );
      return;
    }

    final entry = FoodEntry()
      ..foodName = _nameController.text.trim()
      ..calories = calories
      ..protein = double.tryParse(_proteinController.text) ?? 0
      ..carbs = double.tryParse(_carbsController.text) ?? 0
      ..fat = double.tryParse(_fatController.text) ?? 0
      ..mealType = _selectedMealType
      ..servingSize = double.tryParse(_servingSizeController.text) ?? 1
      ..servingUnit = _servingUnit
      ..timestamp = DateTime.now()
      ..source = DataSource.manual;

    widget.onSave(entry);
    Navigator.pop(context);
  }
}

// ============================================
// EDIT FOOD BOTTOM SHEET
// ============================================

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
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  late TextEditingController _servingSizeController;
  
  late String _servingUnit;
  late MealType _selectedMealType;
  bool _showMacros = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.entry.foodName);
    _caloriesController = TextEditingController(text: widget.entry.calories.toInt().toString());
    _proteinController = TextEditingController(text: widget.entry.protein.toInt().toString());
    _carbsController = TextEditingController(text: widget.entry.carbs.toInt().toString());
    _fatController = TextEditingController(text: widget.entry.fat.toInt().toString());
    _servingSizeController = TextEditingController(text: widget.entry.servingSize.toString());
    _servingUnit = widget.entry.servingUnit;
    _selectedMealType = widget.entry.mealType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _servingSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Same as AddFoodBottomSheet but with pre-filled values
    // และ title เป็น "แก้ไขอาหาร"
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
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Food name
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
            
            // Calories
            TextField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'แคลอรี่ (kcal)',
                prefixText: '🔥 ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Macros
            const Text('Macros', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _proteinController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Protein (g)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'บันทึก',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final updatedEntry = widget.entry
      ..foodName = _nameController.text.trim()
      ..calories = double.tryParse(_caloriesController.text) ?? widget.entry.calories
      ..protein = double.tryParse(_proteinController.text) ?? widget.entry.protein
      ..carbs = double.tryParse(_carbsController.text) ?? widget.entry.carbs
      ..fat = double.tryParse(_fatController.text) ?? widget.entry.fat
      ..mealType = _selectedMealType
      ..servingSize = double.tryParse(_servingSizeController.text) ?? widget.entry.servingSize
      ..servingUnit = _servingUnit;

    widget.onSave(updatedEntry);
    Navigator.pop(context);
  }
}
```

---

## ขั้นตอนที่ 4: อัปเดต Health Page

**แก้ไขไฟล์:** `lib/features/health/presentation/health_page.dart`

**เพิ่ม import:**

```dart
import 'health_diet_tab.dart';
```

**แก้ไข TabBarView:**

```dart
TabBarView(
  controller: _tabController,
  children: [
    const HealthTimelineTab(),
    const HealthDietTab(), // ← เพิ่มตรงนี้
    _buildPlaceholder('Workout', '🏋️'),
    _buildPlaceholder('Other', '📦'),
    _buildPlaceholder('Lab Results', '🩺'),
  ],
),
```

---

## ขั้นตอนที่ 5: ทดสอบ

```bash
flutter run
```

**ผลที่ควรได้:**
- ไปที่ tab สุขภาพ → Diet tab
- เห็นอาหารแยกตาม 4 มื้อ
- กด + เพื่อเพิ่มอาหาร
- กดที่อาหาร → แก้ไขได้
- กด ... → ลบได้

---

## ✅ Checklist

- [ ] สร้าง health_diet_tab.dart แล้ว
- [ ] สร้าง meal_section.dart แล้ว
- [ ] สร้าง Add Food Bottom Sheet แล้ว
- [ ] สร้าง Edit Food Bottom Sheet แล้ว
- [ ] อัปเดต health_page.dart แล้ว
- [ ] ทดสอบเพิ่ม/แก้ไข/ลบอาหารได้

---

## ไฟล์ที่สร้าง/แก้ไขในขั้นตอนนี้

```
lib/features/health/
├── presentation/
│   ├── health_page.dart      ← UPDATED
│   └── health_diet_tab.dart  ← NEW
└── widgets/
    └── meal_section.dart     ← NEW
```

---

## ขั้นตอนถัดไป

ไปที่ **Step 07: Food Preview Screen (AI Analysis)** เพื่อสร้างหน้าวิเคราะห์อาหารจากรูป
