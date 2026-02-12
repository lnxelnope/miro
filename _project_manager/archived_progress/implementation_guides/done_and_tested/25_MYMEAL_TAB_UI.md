# Step 25: สร้าง My Meal Tab - UI สำหรับจัดการเมนูอาหารส่วนตัว

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 4-5 ชั่วโมง
> **ความยาก:** ปานกลาง
> **ต้องทำก่อน:** Step 24 (Ingredient & MyMeal Model)

---

## 🎯 เป้าหมาย

1. เพิ่ม Tab "My Meal" ในหน้า Health
2. สร้างหน้า My Meal Tab - แสดงรายการ meals + ingredients
3. CRUD UI สำหรับ MyMeal (สร้าง, แก้ไข, ลบ)
4. CRUD UI สำหรับ Ingredient (ดู, แก้ไข, ลบ)
5. ปุ่ม "ใช้เมนูนี้" เพื่อบันทึกลง FoodEntry

---

## 📐 UI Layout

```
┌──────────────────────────────────────────────┐
│  Timeline | Diet | My Meal | Workout | Other │  ← เพิ่ม tab ใหม่
├──────────────────────────────────────────────┤
│                                              │
│  ┌─ Sub-tabs ─────────────────────────────┐  │
│  │  [🍽️ เมนูของฉัน]  [🥬 วัตถุดิบ]      │  │
│  └────────────────────────────────────────┘  │
│                                              │
│  ── แท็บ "เมนูของฉัน" ──                     │
│                                              │
│  ┌─────────────────────────────────────────┐ │
│  │ 🔍 ค้นหาเมนู...                        │ │
│  └─────────────────────────────────────────┘ │
│                                              │
│  ┌─────────────────────────────────────────┐ │
│  │ 🍛 ผัดกระเพราไข่ดาว                     │ │
│  │    611 kcal · 1 จาน                     │ │
│  │    P:27g C:57g F:29g                    │ │
│  │    [🍽️ ใช้เมนูนี้] [✏️] [🗑️]           │ │
│  └─────────────────────────────────────────┘ │
│                                              │
│  ┌─────────────────────────────────────────┐ │
│  │ 🥗 ส้มตำ                                │ │
│  │    120 kcal · 1 จาน                     │ │
│  │    P:3g C:18g F:5g                      │ │
│  │    [🍽️ ใช้เมนูนี้] [✏️] [🗑️]           │ │
│  └─────────────────────────────────────────┘ │
│                                              │
│  ── แท็บ "วัตถุดิบ" ──                       │
│                                              │
│  ┌─────────────────────────────────────────┐ │
│  │ 🥚 ไข่ (1 ฟอง)                          │ │
│  │    90 kcal P:6g C:1g F:7g               │ │
│  │    ใช้แล้ว 5 ครั้ง                       │ │
│  └─────────────────────────────────────────┘ │
│                                              │
│  [+ สร้างเมนูใหม่]                          │
└──────────────────────────────────────────────┘
```

---

## 📂 ไฟล์ที่เกี่ยวข้อง

| ไฟล์ | Action | คำอธิบาย |
|------|--------|----------|
| `lib/features/health/presentation/health_page.dart` | EDIT | เพิ่ม Tab |
| `lib/features/health/presentation/health_my_meal_tab.dart` | CREATE | Tab หลัก |
| `lib/features/health/widgets/my_meal_card.dart` | CREATE | Card แสดง meal |
| `lib/features/health/widgets/ingredient_card.dart` | CREATE | Card แสดง ingredient |
| `lib/features/health/widgets/create_meal_sheet.dart` | CREATE | Bottom sheet สร้าง meal |
| `lib/features/health/widgets/log_from_meal_sheet.dart` | CREATE | Bottom sheet บันทึกจาก meal |

---

## 🔧 ขั้นตอนการทำงาน

### Step 1: เพิ่ม Tab ใน HealthPage

**ไฟล์:** `lib/features/health/presentation/health_page.dart`
**Action:** EDIT

**แทนที่ทั้งไฟล์ด้วย:**

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'health_timeline_tab.dart';
import 'health_diet_tab.dart';
import 'health_my_meal_tab.dart';
import 'health_workout_tab.dart';
import 'health_other_tab.dart';
import 'health_lab_tab.dart';

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this); // เปลี่ยนจาก 5 เป็น 6
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sub-tabs
        Container(
          color: Theme.of(context).cardColor,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColors.health,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.health,
            tabs: const [
              Tab(text: 'Timeline'),
              Tab(text: 'Diet'),
              Tab(text: 'My Meal'),  // ← TAB ใหม่
              Tab(text: 'Workout'),
              Tab(text: 'Other'),
              Tab(text: 'Lab'),
            ],
          ),
        ),
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              HealthTimelineTab(),
              HealthDietTab(),
              HealthMyMealTab(),  // ← TAB ใหม่
              HealthWorkoutTab(),
              HealthOtherTab(),
              HealthLabTab(),
            ],
          ),
        ),
      ],
    );
  }
}
```

---

### Step 2: สร้าง My Meal Tab

**ไฟล์:** `lib/features/health/presentation/health_my_meal_tab.dart`
**Action:** CREATE

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/enums.dart';
import '../providers/my_meal_provider.dart';
import '../providers/health_provider.dart';
import '../models/my_meal.dart';
import '../models/ingredient.dart';
import '../models/food_entry.dart';
import '../widgets/my_meal_card.dart';
import '../widgets/ingredient_card.dart';
import '../widgets/create_meal_sheet.dart';
import '../widgets/log_from_meal_sheet.dart';

class HealthMyMealTab extends ConsumerStatefulWidget {
  const HealthMyMealTab({super.key});

  @override
  ConsumerState<HealthMyMealTab> createState() => _HealthMyMealTabState();
}

class _HealthMyMealTabState extends ConsumerState<HealthMyMealTab>
    with SingleTickerProviderStateMixin {
  late TabController _subTabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _subTabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _subTabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sub-tabs: เมนูของฉัน | วัตถุดิบ
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _subTabController,
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.textSecondary,
            indicator: BoxDecoration(
              color: AppColors.health,
              borderRadius: BorderRadius.circular(12),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerHeight: 0,
            tabs: const [
              Tab(text: '🍽️ เมนูของฉัน'),
              Tab(text: '🥬 วัตถุดิบ'),
            ],
          ),
        ),

        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'ค้นหา...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.textTertiary.withOpacity(0.3)),
              ),
              filled: true,
              fillColor: Theme.of(context).cardColor,
            ),
          ),
        ),

        // Content
        Expanded(
          child: TabBarView(
            controller: _subTabController,
            children: [
              _buildMealsList(),
              _buildIngredientsList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMealsList() {
    final searchQuery = _searchController.text.trim();
    final mealsAsync = searchQuery.isEmpty
        ? ref.watch(allMyMealsProvider)
        : ref.watch(myMealSearchProvider(searchQuery));

    return mealsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
      data: (meals) {
        if (meals.isEmpty) {
          return _buildEmptyMeals();
        }

        return Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final meal = meals[index];
                return MyMealCard(
                  meal: meal,
                  onUse: () => _logFromMeal(meal),
                  onEdit: () => _editMeal(meal),
                  onDelete: () => _deleteMeal(meal),
                  onTap: () => _showMealDetail(meal),
                );
              },
            ),
            // FAB สร้างเมนูใหม่
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton.extended(
                onPressed: _createNewMeal,
                backgroundColor: AppColors.health,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add),
                label: const Text('สร้างเมนูใหม่'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIngredientsList() {
    final searchQuery = _searchController.text.trim();
    final ingredientsAsync = searchQuery.isEmpty
        ? ref.watch(allIngredientsProvider)
        : ref.watch(ingredientSearchProvider(searchQuery));

    return ingredientsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
      data: (ingredients) {
        if (ingredients.isEmpty) {
          return _buildEmptyIngredients();
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          itemCount: ingredients.length,
          itemBuilder: (context, index) {
            final ingredient = ingredients[index];
            return IngredientCard(
              ingredient: ingredient,
              onEdit: () => _editIngredient(ingredient),
              onDelete: () => _deleteIngredient(ingredient),
              onUse: () => _logFromIngredient(ingredient),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyMeals() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🍽️', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text('ยังไม่มีเมนูของฉัน', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text(
            'วิเคราะห์อาหารด้วย Gemini แล้วระบบจะจำเมนูให้\nหรือกดปุ่มด้านล่างเพื่อสร้างเอง',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createNewMeal,
            icon: const Icon(Icons.add),
            label: const Text('สร้างเมนูใหม่'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.health,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyIngredients() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🥬', style: TextStyle(fontSize: 64)),
          SizedBox(height: 16),
          Text('ยังไม่มีวัตถุดิบ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          Text(
            'เมื่อวิเคราะห์อาหารด้วย Gemini\nระบบจะจำวัตถุดิบแต่ละอย่างให้อัตโนมัติ',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ===== ACTIONS =====

  /// สร้างเมนูใหม่ (Manual)
  void _createNewMeal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateMealSheet(
        onSave: (meal) {
          ref.invalidate(allMyMealsProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ สร้างเมนู "${meal.name}" แล้ว'), backgroundColor: AppColors.success),
          );
        },
      ),
    );
  }

  /// บันทึกอาหารจาก MyMeal
  void _logFromMeal(MyMeal meal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LogFromMealSheet(
        meal: meal,
        onConfirm: (entry) async {
          final notifier = ref.read(foodEntriesNotifierProvider.notifier);
          await notifier.addFoodEntry(entry);
          
          // เพิ่ม usage count
          await ref.read(myMealNotifierProvider.notifier).incrementMealUsage(meal.id);

          refreshFoodProviders(ref, DateTime.now());
          ref.invalidate(allMyMealsProvider);

          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ บันทึก "${meal.name}" แล้ว'), backgroundColor: AppColors.success),
          );
        },
      ),
    );
  }

  /// บันทึกอาหารจาก Ingredient เดี่ยว
  void _logFromIngredient(Ingredient ingredient) {
    _showLogIngredientDialog(ingredient);
  }

  void _showLogIngredientDialog(Ingredient ingredient) {
    final amountController = TextEditingController(text: ingredient.baseAmount.toString());
    MealType selectedMealType = _guessMealType();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final amount = double.tryParse(amountController.text) ?? 0;
          final calories = ingredient.calcCalories(amount);
          final protein = ingredient.calcProtein(amount);

          return AlertDialog(
            title: Text('🥬 ${ingredient.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ปริมาณ
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'ปริมาณ (${ingredient.baseUnit})',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (_) => setDialogState(() {}),
                ),
                const SizedBox(height: 12),
                // Preview
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.health.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('🔥 ${calories.toInt()} kcal', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('P:${protein.toStringAsFixed(1)}g', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Meal type
                Wrap(
                  spacing: 6,
                  children: MealType.values.map((type) {
                    return ChoiceChip(
                      label: Text(type.icon, style: const TextStyle(fontSize: 16)),
                      selected: selectedMealType == type,
                      onSelected: (s) {
                        if (s) setDialogState(() => selectedMealType = type);
                      },
                      selectedColor: AppColors.health.withOpacity(0.2),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ยกเลิก'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final amt = double.tryParse(amountController.text) ?? 0;
                  if (amt <= 0) return;

                  final entry = FoodEntry()
                    ..foodName = ingredient.name
                    ..mealType = selectedMealType
                    ..timestamp = DateTime.now()
                    ..servingSize = amt
                    ..servingUnit = ingredient.baseUnit
                    ..calories = ingredient.calcCalories(amt)
                    ..protein = ingredient.calcProtein(amt)
                    ..carbs = ingredient.calcCarbs(amt)
                    ..fat = ingredient.calcFat(amt)
                    ..baseCalories = ingredient.caloriesPerBase / ingredient.baseAmount
                    ..baseProtein = ingredient.proteinPerBase / ingredient.baseAmount
                    ..baseCarbs = ingredient.carbsPerBase / ingredient.baseAmount
                    ..baseFat = ingredient.fatPerBase / ingredient.baseAmount
                    ..ingredientId = ingredient.id
                    ..source = DataSource.manual;

                  final notifier = ref.read(foodEntriesNotifierProvider.notifier);
                  await notifier.addFoodEntry(entry);
                  refreshFoodProviders(ref, DateTime.now());

                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('✅ บันทึก "${ingredient.name}" ${amt.toStringAsFixed(0)}${ingredient.baseUnit} แล้ว'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.health,
                  foregroundColor: Colors.white,
                ),
                child: const Text('บันทึก'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _editMeal(MyMeal meal) {
    // TODO: เปิด CreateMealSheet ในโหมด edit
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🚧 ฟีเจอร์แก้ไขเมนูกำลังพัฒนา')),
    );
  }

  Future<void> _deleteMeal(MyMeal meal) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบเมนู'),
        content: Text('ต้องการลบ "${meal.name}" หรือไม่?\n\n⚠️ วัตถุดิบจะไม่ถูกลบ'),
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

    if (confirm == true) {
      await ref.read(myMealNotifierProvider.notifier).deleteMeal(meal.id);
      ref.invalidate(allMyMealsProvider);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ ลบเมนูแล้ว'), backgroundColor: AppColors.success),
      );
    }
  }

  void _editIngredient(Ingredient ingredient) {
    // TODO: เปิด dialog แก้ไข ingredient
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🚧 ฟีเจอร์แก้ไขวัตถุดิบกำลังพัฒนา')),
    );
  }

  Future<void> _deleteIngredient(Ingredient ingredient) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบวัตถุดิบ'),
        content: Text('ต้องการลบ "${ingredient.name}" หรือไม่?'),
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

    if (confirm == true) {
      await ref.read(myMealNotifierProvider.notifier).deleteIngredient(ingredient.id);
      ref.invalidate(allIngredientsProvider);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ ลบวัตถุดิบแล้ว'), backgroundColor: AppColors.success),
      );
    }
  }

  void _showMealDetail(MyMeal meal) {
    final ingredientsAsync = ref.read(mealIngredientsProvider(meal.id));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
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
            Text(
              '🍽️ ${meal.name}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              meal.baseServingDescription,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            // Nutrition summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.health.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _nutritionBadge('🔥', '${meal.totalCalories.toInt()}', 'kcal'),
                  _nutritionBadge('🥩', '${meal.totalProtein.toInt()}g', 'โปรตีน'),
                  _nutritionBadge('🍞', '${meal.totalCarbs.toInt()}g', 'คาร์บ'),
                  _nutritionBadge('🫒', '${meal.totalFat.toInt()}g', 'ไขมัน'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('วัตถุดิบ:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            // Ingredients list
            ingredientsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text('Error: $e'),
              data: (ingredients) {
                if (ingredients.isEmpty) {
                  return const Text('ไม่มีข้อมูลวัตถุดิบ', style: TextStyle(color: AppColors.textSecondary));
                }
                return Column(
                  children: ingredients.map((ing) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Text('  •  '),
                        Expanded(
                          child: Text('${ing.ingredientName} (${ing.amount.toStringAsFixed(0)} ${ing.unit})'),
                        ),
                        Text(
                          '${ing.calories.toInt()} kcal',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  )).toList(),
                );
              },
            ),
            const SizedBox(height: 20),
            // Use button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _logFromMeal(meal);
                },
                icon: const Icon(Icons.restaurant),
                label: const Text('ใช้เมนูนี้'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.health,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nutritionBadge(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }

  MealType _guessMealType() {
    final hour = DateTime.now().hour;
    if (hour < 10) return MealType.breakfast;
    if (hour < 14) return MealType.lunch;
    if (hour < 17) return MealType.snack;
    return MealType.dinner;
  }
}
```

---

### Step 3: สร้าง MyMeal Card Widget

**ไฟล์:** `lib/features/health/widgets/my_meal_card.dart`
**Action:** CREATE

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/my_meal.dart';

class MyMealCard extends StatelessWidget {
  final MyMeal meal;
  final VoidCallback onUse;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const MyMealCard({
    super.key,
    required this.meal,
    required this.onUse,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${meal.baseServingDescription} · ใช้แล้ว ${meal.usageCount} ครั้ง',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  // Source badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: meal.source == 'gemini'
                          ? Colors.purple.withOpacity(0.1)
                          : AppColors.textTertiary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      meal.source == 'gemini' ? '✨ AI' : '✏️ Manual',
                      style: TextStyle(
                        fontSize: 10,
                        color: meal.source == 'gemini' ? Colors.purple : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Nutrition row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.health.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _nutritionItem('🔥', '${meal.totalCalories.toInt()}', 'kcal', AppColors.health),
                    _divider(),
                    _nutritionItem('🥩', '${meal.totalProtein.toInt()}g', 'P', AppColors.protein),
                    _divider(),
                    _nutritionItem('🍞', '${meal.totalCarbs.toInt()}g', 'C', AppColors.carbs),
                    _divider(),
                    _nutritionItem('🫒', '${meal.totalFat.toInt()}g', 'F', AppColors.fat),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onUse,
                      icon: const Icon(Icons.restaurant, size: 16),
                      label: const Text('ใช้เมนูนี้', style: TextStyle(fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.health,
                        side: BorderSide(color: AppColors.health.withOpacity(0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    color: AppColors.textSecondary,
                    tooltip: 'แก้ไข',
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: AppColors.error,
                    tooltip: 'ลบ',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nutritionItem(String emoji, String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 24, color: AppColors.textTertiary.withOpacity(0.3));
  }
}
```

---

### Step 4: สร้าง Ingredient Card Widget

**ไฟล์:** `lib/features/health/widgets/ingredient_card.dart`
**Action:** CREATE

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/ingredient.dart';

class IngredientCard extends StatelessWidget {
  final Ingredient ingredient;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onUse;

  const IngredientCard({
    super.key,
    required this.ingredient,
    required this.onEdit,
    required this.onDelete,
    required this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.health.withOpacity(0.1),
          child: const Text('🥬', style: TextStyle(fontSize: 20)),
        ),
        title: Text(
          ingredient.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${ingredient.baseAmount.toStringAsFixed(0)} ${ingredient.baseUnit} = '
              '${ingredient.caloriesPerBase.toInt()} kcal  '
              'P:${ingredient.proteinPerBase.toInt()}g  '
              'C:${ingredient.carbsPerBase.toInt()}g  '
              'F:${ingredient.fatPerBase.toInt()}g',
              style: const TextStyle(fontSize: 11),
            ),
            const SizedBox(height: 2),
            Text(
              'ใช้แล้ว ${ingredient.usageCount} ครั้ง · ${ingredient.source == 'gemini' ? '✨ AI' : '✏️ Manual'}',
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onUse,
              icon: const Icon(Icons.add_circle_outline, size: 22),
              color: AppColors.health,
              tooltip: 'บันทึกรายการนี้',
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit': onEdit(); break;
                  case 'delete': onDelete(); break;
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('✏️ แก้ไข')),
                const PopupMenuItem(value: 'delete', child: Text('🗑️ ลบ')),
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

### Step 5: สร้าง Create Meal Sheet

**ไฟล์:** `lib/features/health/widgets/create_meal_sheet.dart`
**Action:** CREATE

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/my_meal_provider.dart';
import '../models/my_meal.dart';

/// Bottom sheet สำหรับสร้างเมนูอาหารใหม่ (Manual)
class CreateMealSheet extends ConsumerStatefulWidget {
  final Function(MyMeal) onSave;

  const CreateMealSheet({super.key, required this.onSave});

  @override
  ConsumerState<CreateMealSheet> createState() => _CreateMealSheetState();
}

class _CreateMealSheetState extends ConsumerState<CreateMealSheet> {
  final _nameController = TextEditingController();
  final _servingDescController = TextEditingController(text: '1 จาน');
  final List<_IngredientRow> _ingredients = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _servingDescController.dispose();
    for (final row in _ingredients) {
      row.dispose();
    }
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
            // Drag handle
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
            const Text('🍽️ สร้างเมนูใหม่', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // ชื่อเมนู
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'ชื่อเมนู *',
                hintText: 'เช่น ผัดกระเพราไข่ดาว',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),

            // ปริมาณฐาน
            TextField(
              controller: _servingDescController,
              decoration: InputDecoration(
                labelText: 'ปริมาณฐาน',
                hintText: 'เช่น 1 จาน, 1 ชุด',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            // Ingredients
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('🥬 วัตถุดิบ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                TextButton.icon(
                  onPressed: _addIngredientRow,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('เพิ่ม'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_ingredients.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.textTertiary.withOpacity(0.3), style: BorderStyle.solid),
                ),
                child: const Center(
                  child: Text(
                    'กดปุ่ม "เพิ่ม" เพื่อเพิ่มวัตถุดิบ\nหรือใส่ข้อมูลโภชนาการรวมด้านล่าง',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
              ),

            // Ingredient rows
            ..._ingredients.asMap().entries.map((entry) {
              final idx = entry.key;
              final row = entry.value;
              return _buildIngredientRow(row, idx);
            }),
            const SizedBox(height: 16),

            // Total nutrition (calculated or manual)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.health.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📊 รวมโภชนาการ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('🔥 ${_totalCalories.toInt()} kcal', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('P:${_totalProtein.toInt()}g', style: const TextStyle(fontSize: 12)),
                      Text('C:${_totalCarbs.toInt()}g', style: const TextStyle(fontSize: 12)),
                      Text('F:${_totalFat.toInt()}g', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.health,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('บันทึกเมนู', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientRow(_IngredientRow row, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.textTertiary.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: row.nameController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อ',
                    isDense: true,
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: row.amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'ปริมาณ',
                    isDense: true,
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 14),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 40,
                child: TextField(
                  controller: row.unitController,
                  decoration: const InputDecoration(
                    labelText: 'หน่วย',
                    isDense: true,
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              IconButton(
                onPressed: () => setState(() {
                  _ingredients[index].dispose();
                  _ingredients.removeAt(index);
                }),
                icon: const Icon(Icons.close, size: 18, color: AppColors.error),
              ),
            ],
          ),
          const Divider(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: row.calController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'kcal', isDense: true, border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 13),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: row.proteinController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'P(g)', isDense: true, border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 13),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: row.carbsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'C(g)', isDense: true, border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 13),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: row.fatController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'F(g)', isDense: true, border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 13),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addIngredientRow() {
    setState(() {
      _ingredients.add(_IngredientRow());
    });
  }

  double get _totalCalories => _ingredients.fold<double>(
      0, (sum, row) => sum + (double.tryParse(row.calController.text) ?? 0));
  double get _totalProtein => _ingredients.fold<double>(
      0, (sum, row) => sum + (double.tryParse(row.proteinController.text) ?? 0));
  double get _totalCarbs => _ingredients.fold<double>(
      0, (sum, row) => sum + (double.tryParse(row.carbsController.text) ?? 0));
  double get _totalFat => _ingredients.fold<double>(
      0, (sum, row) => sum + (double.tryParse(row.fatController.text) ?? 0));

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกชื่อเมนู')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final notifier = ref.read(myMealNotifierProvider.notifier);

      final ingredients = _ingredients
          .where((row) => row.nameController.text.trim().isNotEmpty)
          .map((row) => MealIngredientInput(
                name: row.nameController.text.trim(),
                amount: double.tryParse(row.amountController.text) ?? 0,
                unit: row.unitController.text.trim().isEmpty ? 'g' : row.unitController.text.trim(),
                calories: double.tryParse(row.calController.text) ?? 0,
                protein: double.tryParse(row.proteinController.text) ?? 0,
                carbs: double.tryParse(row.carbsController.text) ?? 0,
                fat: double.tryParse(row.fatController.text) ?? 0,
              ))
          .toList();

      final meal = await notifier.createMeal(
        name: _nameController.text.trim(),
        baseServingDescription: _servingDescController.text.trim(),
        ingredients: ingredients,
        source: 'manual',
      );

      widget.onSave(meal);
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ เกิดข้อผิดพลาด: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _IngredientRow {
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  final unitController = TextEditingController(text: 'g');
  final calController = TextEditingController(text: '0');
  final proteinController = TextEditingController(text: '0');
  final carbsController = TextEditingController(text: '0');
  final fatController = TextEditingController(text: '0');

  void dispose() {
    nameController.dispose();
    amountController.dispose();
    unitController.dispose();
    calController.dispose();
    proteinController.dispose();
    carbsController.dispose();
    fatController.dispose();
  }
}
```

---

### Step 6: สร้าง Log From Meal Sheet

**ไฟล์:** `lib/features/health/widgets/log_from_meal_sheet.dart`
**Action:** CREATE

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/enums.dart';
import '../models/my_meal.dart';
import '../models/food_entry.dart';

/// Bottom sheet สำหรับบันทึกอาหารจาก MyMeal
/// ผู้ใช้ระบุ multiplier (ปริมาณ) แล้ว nutrition คำนวณอัตโนมัติ
class LogFromMealSheet extends StatefulWidget {
  final MyMeal meal;
  final Function(FoodEntry) onConfirm;

  const LogFromMealSheet({
    super.key,
    required this.meal,
    required this.onConfirm,
  });

  @override
  State<LogFromMealSheet> createState() => _LogFromMealSheetState();
}

class _LogFromMealSheetState extends State<LogFromMealSheet> {
  final _multiplierController = TextEditingController(text: '1');
  late MealType _selectedMealType;

  @override
  void initState() {
    super.initState();
    _selectedMealType = _guessMealType();
    _multiplierController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _multiplierController.dispose();
    super.dispose();
  }

  double get _multiplier => double.tryParse(_multiplierController.text) ?? 0;
  double get _calories => widget.meal.calcCalories(_multiplier);
  double get _protein => widget.meal.calcProtein(_multiplier);
  double get _carbs => widget.meal.calcCarbs(_multiplier);
  double get _fat => widget.meal.calcFat(_multiplier);

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
            // Drag handle
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
            Text(
              '🍽️ ${widget.meal.name}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'ฐาน: ${widget.meal.baseServingDescription}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),

            // Multiplier
            TextField(
              controller: _multiplierController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'จำนวน (เท่า)',
                helperText: '1 = ${widget.meal.baseServingDescription}, '
                    '0.5 = ครึ่ง${widget.meal.baseServingDescription}',
                helperMaxLines: 2,
                helperStyle: TextStyle(fontSize: 11, color: Colors.purple.shade300),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.purple, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Nutrition preview
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
              child: Column(
                children: [
                  // Calories
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Text(
                        '${_calories.toInt()}',
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.health),
                      ),
                      const SizedBox(width: 4),
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text('kcal', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Macros
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _macroItem('โปรตีน', _protein, AppColors.protein),
                      _macroItem('คาร์บ', _carbs, AppColors.carbs),
                      _macroItem('ไขมัน', _fat, AppColors.fat),
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

            // Confirm button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _multiplier > 0 ? _confirm : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.health,
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

  Widget _macroItem(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(
            '${value.toStringAsFixed(1)}g',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  MealType _guessMealType() {
    final hour = DateTime.now().hour;
    if (hour < 10) return MealType.breakfast;
    if (hour < 14) return MealType.lunch;
    if (hour < 17) return MealType.snack;
    return MealType.dinner;
  }

  void _confirm() {
    final entry = FoodEntry()
      ..foodName = widget.meal.name
      ..foodNameEn = widget.meal.nameEn
      ..mealType = _selectedMealType
      ..timestamp = DateTime.now()
      ..servingSize = _multiplier
      ..servingUnit = widget.meal.baseServingDescription
      ..calories = _calories
      ..protein = _protein
      ..carbs = _carbs
      ..fat = _fat
      // Base values (per 1 multiplier = total meal)
      ..baseCalories = widget.meal.totalCalories
      ..baseProtein = widget.meal.totalProtein
      ..baseCarbs = widget.meal.totalCarbs
      ..baseFat = widget.meal.totalFat
      ..myMealId = widget.meal.id
      ..source = DataSource.manual;

    widget.onConfirm(entry);
    Navigator.pop(context);
  }
}
```

---

## ✅ Definition of Done

- [ ] Tab "My Meal" แสดงในหน้า Health (6 tabs ทั้งหมด)
- [ ] Sub-tabs: เมนูของฉัน + วัตถุดิบ ทำงานได้
- [ ] ค้นหาเมนู/วัตถุดิบได้
- [ ] กดปุ่ม "สร้างเมนูใหม่" → เปิด CreateMealSheet → เพิ่มวัตถุดิบได้ → บันทึกได้
- [ ] กดปุ่ม "ใช้เมนูนี้" → เปิด LogFromMealSheet → เปลี่ยน multiplier → kcal เปลี่ยนตาม → บันทึกลง FoodEntry
- [ ] กดบันทึกวัตถุดิบเดี่ยวได้ (เช่น ไข่ 2 ฟอง)
- [ ] ลบเมนู/วัตถุดิบได้
- [ ] MyMeal card แสดง nutrition + usage count
- [ ] Ingredient card แสดง nutrition per base unit

---

## 📁 ไฟล์ที่สร้าง/แก้ไข

```
lib/features/health/
├── presentation/
│   ├── health_page.dart             ← EDIT (เพิ่ม tab)
│   └── health_my_meal_tab.dart      ← NEW
└── widgets/
    ├── my_meal_card.dart            ← NEW
    ├── ingredient_card.dart         ← NEW
    ├── create_meal_sheet.dart       ← NEW
    └── log_from_meal_sheet.dart     ← NEW
```
