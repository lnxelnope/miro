# 🌳 SENIOR TASK 3: Expandable Tree UI

> **ระดับความยาก:** 🔴 Senior (ปานกลาง-ยาก)  
> **เวลาประมาณ:** 3-4 ชั่วโมง  
> **ความรู้ที่ต้องมี:** Flutter advanced widgets, state management, animations

---

## 🎯 เป้าหมาย

สร้าง expandable tree UI สำหรับแสดง hierarchical ingredients ใน:
1. **GeminiAnalysisSheet** — หลัง AI วิเคราะห์เสร็จ
2. **CreateMealSheet** — แก้ไข meal (add/remove sub-ingredients)
3. **FoodDetailBottomSheet** — แสดง detail ของ food entry
4. **LogFromMealSheet** — เลือก ingredients จาก meal

---

## 📍 ไฟล์ที่ต้องแก้

1. **`lib/features/health/widgets/gemini_analysis_sheet.dart`** — expandable read-only list
2. **`lib/features/health/widgets/create_meal_sheet.dart`** — editable nested form
3. **`lib/features/health/widgets/food_detail_bottom_sheet.dart`** — read-only hierarchy
4. **`lib/features/health/widgets/log_from_meal_sheet.dart`** — read-only hierarchy

---

## ⚠️ Design Principles

### 1. Visual Hierarchy

```
┌─────────────────────────────────────┐
│ ▼ ROOT Ingredient       250 kcal    │  ← สีเข้ม, ตัวหนา, มีลูกศรกดได้
│   ├─ Sub 1              132 kcal    │  ← เยื้อง, สีจาง, เส้นเชื่อม
│   ├─ Sub 2               48 kcal    │
│   └─ Sub 3               70 kcal    │
│                                     │
│   Simple Ingredient      50 kcal    │  ← ไม่มีลูกศร (ไม่มี sub)
└─────────────────────────────────────┘
```

### 2. Interaction Patterns

| Widget | Expandable? | Editable? | Show Detail? |
|--------|------------|-----------|--------------|
| GeminiAnalysisSheet | ✅ Yes | ❌ No | ✅ Yes |
| CreateMealSheet | ✅ Yes | ✅ Yes | ⚠️ Optional |
| FoodDetailBottomSheet | ✅ Yes | ❌ No | ✅ Yes |
| LogFromMealSheet | ✅ Yes | ❌ No | ✅ Yes |

---

## 📋 Implementation Steps

### Phase 1: Shared Widget — ExpandableIngredientCard

**สร้างไฟล์ใหม่:** `lib/features/health/widgets/expandable_ingredient_card.dart`

```dart
import 'package:flutter/material.dart';
import '../models/my_meal_ingredient.dart';

/// Expandable card สำหรับแสดง ingredient พร้อม sub-ingredients
class ExpandableIngredientCard extends StatefulWidget {
  final MyMealIngredient ingredient;
  final List<MyMealIngredient> children;
  final int depth;
  final bool isEditable;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  
  const ExpandableIngredientCard({
    Key? key,
    required this.ingredient,
    required this.children,
    this.depth = 0,
    this.isEditable = false,
    this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  State<ExpandableIngredientCard> createState() => _ExpandableIngredientCardState();
}

class _ExpandableIngredientCardState extends State<ExpandableIngredientCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasChildren = widget.children.isNotEmpty;
    final indent = widget.depth * 16.0;

    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Parent card
          _buildParentCard(hasChildren),
          
          // Children (expandable)
          if (hasChildren)
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.children.map((child) {
                  return _buildChildCard(child);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildParentCard(bool hasChildren) {
    return GestureDetector(
      onTap: hasChildren ? _toggleExpanded : widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: widget.depth == 0 ? Colors.white : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.depth == 0 ? Colors.grey[300]! : Colors.grey[200]!,
          ),
          boxShadow: widget.depth == 0
              ? [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]
              : null,
        ),
        child: Row(
          children: [
            // Expand/collapse icon (ถ้ามี children)
            if (hasChildren)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: RotationTransition(
                  turns: Tween<double>(begin: 0, end: 0.5).animate(_expandAnimation),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            
            // Vertical line (ถ้าเป็น sub)
            if (widget.depth > 0)
              Container(
                width: 2,
                height: 40,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            
            // Ingredient info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    widget.ingredient.ingredientName,
                    style: TextStyle(
                      fontSize: widget.depth == 0 ? 16 : 14,
                      fontWeight: widget.depth == 0 ? FontWeight.w600 : FontWeight.w400,
                      color: widget.depth == 0 ? Colors.black87 : Colors.black54,
                    ),
                  ),
                  
                  // Amount
                  const SizedBox(height: 4),
                  Text(
                    '${widget.ingredient.amount} ${widget.ingredient.unit}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  // Detail (ถ้ามี)
                  if (widget.ingredient.detail != null && 
                      widget.ingredient.detail!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        widget.ingredient.detail!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                  '${widget.ingredient.calories.toStringAsFixed(0)} kcal',
                  style: TextStyle(
                    fontSize: widget.depth == 0 ? 16 : 14,
                    fontWeight: FontWeight.bold,
                    color: widget.depth == 0 ? Colors.orange[700] : Colors.orange[400],
                  ),
                ),
                
                // Composite indicator
                if (hasChildren)
                  Text(
                    '${widget.children.length} items',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
              ],
            ),
            
            // Delete button (ถ้า editable)
            if (widget.isEditable && widget.onDelete != null)
              IconButton(
                icon: Icon(Icons.delete_outline, size: 20),
                color: Colors.red[400],
                onPressed: widget.onDelete,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildCard(MyMealIngredient child) {
    return Container(
      margin: const EdgeInsets.only(left: 24, top: 2, right: 8, bottom: 2),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          // Connection line
          Container(
            width: 2,
            height: 30,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.ingredientName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${child.amount} ${child.unit}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                if (child.detail != null && child.detail!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      child.detail!,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          
          Text(
            '${child.calories.toStringAsFixed(0)} kcal',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

### Phase 2: GeminiAnalysisSheet — ใช้ ExpandableIngredientCard

**ไฟล์:** `lib/features/health/widgets/gemini_analysis_sheet.dart`

**เดิม (flat list):**

```dart
ListView.builder(
  itemCount: result.ingredientsDetail.length,
  itemBuilder: (context, index) {
    final ing = result.ingredientsDetail[index];
    return IngredientCard(ingredient: ing);
  },
)
```

**ใหม่ (tree list):**

```dart
import 'expandable_ingredient_card.dart';

// ... ใน build method

// สร้าง tree structure from ingredientsDetail
List<_IngredientNode> _buildTree() {
  final nodes = <_IngredientNode>[];
  
  for (final detail in result.ingredientsDetail) {
    // แปลง IngredientDetail → MyMealIngredient (temporary)
    final parent = MyMealIngredient()
      ..ingredientName = detail.name
      ..amount = detail.amount
      ..unit = detail.unit
      ..calories = detail.calories
      ..protein = detail.protein
      ..carbs = detail.carbs
      ..fat = detail.fat
      ..detail = detail.detail
      ..depth = 0
      ..isComposite = detail.subIngredients?.isNotEmpty ?? false;
    
    final children = <MyMealIngredient>[];
    if (detail.subIngredients != null) {
      for (final sub in detail.subIngredients!) {
        children.add(MyMealIngredient()
          ..ingredientName = sub.name
          ..amount = sub.amount
          ..unit = sub.unit
          ..calories = sub.calories
          ..protein = sub.protein
          ..carbs = sub.carbs
          ..fat = sub.fat
          ..detail = sub.detail
          ..depth = 1);
      }
    }
    
    nodes.add(_IngredientNode(ingredient: parent, children: children));
  }
  
  return nodes;
}

// UI
ListView.builder(
  itemCount: _buildTree().length,
  itemBuilder: (context, index) {
    final node = _buildTree()[index];
    return ExpandableIngredientCard(
      ingredient: node.ingredient,
      children: node.children,
      depth: 0,
      isEditable: false,
    );
  },
)

// Helper class
class _IngredientNode {
  final MyMealIngredient ingredient;
  final List<MyMealIngredient> children;
  _IngredientNode({required this.ingredient, required this.children});
}
```

---

### Phase 3: FoodDetailBottomSheet & LogFromMealSheet — ใช้ Tree Provider

**ไฟล์:** `lib/features/health/widgets/food_detail_bottom_sheet.dart`

```dart
import 'expandable_ingredient_card.dart';
import '../providers/my_meal_provider.dart';

class FoodDetailBottomSheet extends ConsumerWidget {
  final FoodEntry foodEntry;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Parse ingredientsJson → tree
    final ingredientsData = jsonDecode(foodEntry.ingredientsJson) as List;
    final tree = _parseTree(ingredientsData);
    
    return ListView.builder(
      itemCount: tree.length,
      itemBuilder: (context, index) {
        final node = tree[index];
        return ExpandableIngredientCard(
          ingredient: node.ingredient,
          children: node.children,
          depth: 0,
          isEditable: false,
        );
      },
    );
  }
  
  List<_IngredientNode> _parseTree(List ingredientsData) {
    // Similar to GeminiAnalysisSheet._buildTree()
    // Parse JSON → MyMealIngredient objects
    // Return tree structure
  }
}
```

---

### Phase 4: CreateMealSheet — Editable Nested Form

**ไฟล์:** `lib/features/health/widgets/create_meal_sheet.dart`

**Challenge:** ต้องให้ผู้ใช้เพิ่ม/ลบ sub-ingredients ได้

**Strategy:**

```dart
class CreateMealSheet extends StatefulWidget {
  @override
  State<CreateMealSheet> createState() => _CreateMealSheetState();
}

class _CreateMealSheetState extends State<CreateMealSheet> {
  // ใช้ nested list structure
  final List<_EditableIngredientNode> _ingredients = [];
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Ingredient list
        Expanded(
          child: ListView.builder(
            itemCount: _ingredients.length,
            itemBuilder: (context, index) {
              final node = _ingredients[index];
              return _buildEditableNode(node, index);
            },
          ),
        ),
        
        // Add ROOT ingredient button
        ElevatedButton(
          onPressed: _addRootIngredient,
          child: Text('+ Add Ingredient'),
        ),
        
        // Save button
        ElevatedButton(
          onPressed: _saveMeal,
          child: Text('Save Meal'),
        ),
      ],
    );
  }
  
  Widget _buildEditableNode(_EditableIngredientNode node, int index) {
    return Column(
      children: [
        // Parent ingredient form
        _buildIngredientForm(
          node: node,
          onDelete: () => setState(() => _ingredients.removeAt(index)),
        ),
        
        // Sub-ingredients
        ...node.children.asMap().entries.map((entry) {
          final subIndex = entry.key;
          final subNode = entry.value;
          return Padding(
            padding: const EdgeInsets.only(left: 24),
            child: _buildIngredientForm(
              node: subNode,
              isChild: true,
              onDelete: () => setState(() => node.children.removeAt(subIndex)),
            ),
          );
        }).toList(),
        
        // Add sub-ingredient button
        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: TextButton.icon(
            onPressed: () => _addSubIngredient(node),
            icon: Icon(Icons.add, size: 16),
            label: Text('Add Sub-ingredient'),
          ),
        ),
      ],
    );
  }
  
  Widget _buildIngredientForm({
    required _EditableIngredientNode node,
    bool isChild = false,
    VoidCallback? onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isChild ? Colors.grey[100] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // Name field
          TextField(
            controller: node.nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Amount, Unit, Calories (row)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: node.amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Amount'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: node.unitController,
                  decoration: InputDecoration(labelText: 'Unit'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: node.caloriesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'kcal'),
                ),
              ),
            ],
          ),
          
          // Detail field (optional)
          const SizedBox(height: 8),
          TextField(
            controller: node.detailController,
            decoration: InputDecoration(
              labelText: 'Detail (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          
          // Delete button
          if (onDelete != null)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onDelete,
              ),
            ),
        ],
      ),
    );
  }
  
  void _addRootIngredient() {
    setState(() {
      _ingredients.add(_EditableIngredientNode());
    });
  }
  
  void _addSubIngredient(_EditableIngredientNode parent) {
    setState(() {
      parent.children.add(_EditableIngredientNode());
    });
  }
  
  Future<void> _saveMeal() async {
    // Convert _EditableIngredientNode → MealIngredientInput
    final inputs = _ingredients.map((node) => node.toInput()).toList();
    
    // Call provider
    await ref.read(myMealProvider.notifier).createMeal(
      mealName: _mealNameController.text,
      timestamp: DateTime.now(),
      mealType: _selectedMealType,
      ingredients: inputs,
      ...
    );
    
    Navigator.pop(context);
  }
}

// Helper class
class _EditableIngredientNode {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController caloriesController = TextEditingController();
  final TextEditingController detailController = TextEditingController();
  final List<_EditableIngredientNode> children = [];
  
  MealIngredientInput toInput() {
    return MealIngredientInput(
      name: nameController.text,
      amount: double.tryParse(amountController.text) ?? 0,
      unit: unitController.text,
      calories: double.tryParse(caloriesController.text) ?? 0,
      protein: 0,  // TODO: add fields
      carbs: 0,
      fat: 0,
      detail: detailController.text.isEmpty ? null : detailController.text,
      subIngredients: children.isEmpty 
          ? null 
          : children.map((c) => c.toInput()).toList(),
    );
  }
  
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    unitController.dispose();
    caloriesController.dispose();
    detailController.dispose();
    for (final child in children) {
      child.dispose();
    }
  }
}
```

---

## 🎨 UX Enhancements

### 1. Smooth Animations

```dart
AnimationController _controller = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 200),
);

// Expand/collapse animation
SizeTransition(
  sizeFactor: _controller,
  child: childrenWidget,
)

// Rotate arrow
RotationTransition(
  turns: Tween<double>(begin: 0, end: 0.5).animate(_controller),
  child: Icon(Icons.arrow_forward_ios),
)
```

### 2. Visual Feedback

```dart
// Highlight parent เมื่อ expand
Container(
  decoration: BoxDecoration(
    color: _isExpanded ? Colors.blue[50] : Colors.white,
    // ...
  ),
)

// Pulse animation เมื่อ add/delete
AnimatedContainer(
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeOut,
  // ...
)
```

### 3. Validation

```dart
// ตรวจสอบว่า sum(sub) ≈ parent
bool _validateCalories(_EditableIngredientNode node) {
  if (node.children.isEmpty) return true;
  
  final parentCal = double.tryParse(node.caloriesController.text) ?? 0;
  final subSum = node.children.fold<double>(
    0,
    (sum, child) => sum + (double.tryParse(child.caloriesController.text) ?? 0),
  );
  
  final diff = (subSum - parentCal).abs();
  final tolerance = parentCal * 0.1;  // 10% tolerance
  
  if (diff > tolerance) {
    // แสดง warning
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Warning: Sub-ingredients sum ($subSum kcal) ≠ parent ($parentCal kcal)',
        ),
        backgroundColor: Colors.orange,
      ),
    );
    return false;
  }
  
  return true;
}
```

---

## 🧪 Testing Strategy

### 1. Widget Tests

```dart
testWidgets('ExpandableIngredientCard shows children when tapped', (tester) async {
  final parent = MyMealIngredient()..ingredientName = 'Parent';
  final children = [
    MyMealIngredient()..ingredientName = 'Child 1',
    MyMealIngredient()..ingredientName = 'Child 2',
  ];

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ExpandableIngredientCard(
          ingredient: parent,
          children: children,
        ),
      ),
    ),
  );

  // Initially collapsed
  expect(find.text('Child 1'), findsNothing);

  // Tap to expand
  await tester.tap(find.text('Parent'));
  await tester.pumpAndSettle();

  // Children should be visible
  expect(find.text('Child 1'), findsOneWidget);
  expect(find.text('Child 2'), findsOneWidget);
});
```

### 2. Integration Tests

```dart
testWidgets('CreateMealSheet allows adding sub-ingredients', (tester) async {
  await tester.pumpWidget(MyApp());

  // Navigate to CreateMealSheet
  // ...

  // Add ROOT ingredient
  await tester.tap(find.text('+ Add Ingredient'));
  await tester.pumpAndSettle();

  // Fill parent data
  await tester.enterText(find.byType(TextField).first, 'Fried Chicken');

  // Add sub-ingredient
  await tester.tap(find.text('Add Sub-ingredient'));
  await tester.pumpAndSettle();

  // Fill sub data
  // ...

  // Save
  await tester.tap(find.text('Save Meal'));
  await tester.pumpAndSettle();

  // Verify in DB
  final meals = await db.myMeals.where().findAll();
  expect(meals.first.name, 'Test Meal');

  final ingredients = await db.myMealIngredients
      .filter()
      .myMealIdEqualTo(meals.first.id)
      .findAll();
  
  expect(ingredients.where((e) => e.parentId == null).length, 1);
  expect(ingredients.where((e) => e.parentId != null).length, greaterThan(0));
});
```

---

## ⚠️ Common Pitfalls

### 1. Performance — Too Many Rebuilds

**ปัญหา:** ทุกครั้งที่ expand/collapse → rebuild ทั้ง list

**แก้:** ใช้ `AutomaticKeepAliveClientMixin`

```dart
class _ExpandableIngredientCardState extends State<ExpandableIngredientCard>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  Widget build(BuildContext context) {
    super.build(context);  // MUST call super
    // ...
  }
}
```

### 2. Memory Leaks — Controllers Not Disposed

**ปัญหา:** ลืม dispose TextEditingController

**แก้:**

```dart
@override
void dispose() {
  nameController.dispose();
  amountController.dispose();
  // ... dispose all controllers
  for (final child in children) {
    child.dispose();  // recursive dispose
  }
  super.dispose();
}
```

### 3. Layout Overflow

**ปัญหา:** Sub-ingredients เยื้องมากเกินไป → overflow

**แก้:** จำกัด max depth

```dart
if (widget.depth >= 2) {
  // ไม่อนุญาตให้ nest เกิน 2 ชั้น
  return Text('Max nesting depth reached');
}
```

---

## 📊 Success Criteria

- [ ] GeminiAnalysisSheet แสดง tree แบบ expandable
- [ ] FoodDetailBottomSheet แสดง hierarchy
- [ ] LogFromMealSheet แสดง hierarchy
- [ ] CreateMealSheet เพิ่ม/ลบ sub-ingredients ได้
- [ ] Animations smooth (expand/collapse)
- [ ] Validation warnings แสดงเมื่อ calorie sum ไม่ตรง
- [ ] Widget tests ผ่านหมด
- [ ] Integration tests ผ่านหมด
- [ ] ไม่มี memory leaks (controllers disposed)

---

## 🔜 Final Steps

**เมื่อทำเสร็จทั้ง 6 tasks:**
1. รัน full regression tests
2. ทดสอบ backward compatibility กับ data เก่า
3. ทดสอบ end-to-end (AI → UI → DB → UI)
4. Performance testing (10+ meals with 5+ ingredients each)
5. Deploy to staging
6. User acceptance testing

---

## 🆘 ถ้าติดปัญหา

1. **Animations ไม่ smooth:** ลด complexity ของ widget tree, ใช้ `RepaintBoundary`
2. **Layout overflow:** ใช้ `Expanded`, `Flexible`, `ConstrainedBox`
3. **Controllers conflict:** ตรวจสอบ lifecycle, ใช้ `Form` + `FormField`
4. **Tree structure confusing:** วาด diagram บน whiteboard
5. **Memory leaks:** ใช้ DevTools Memory profiler

---

**หมายเหตุ:** Task นี้เป็น UI task ที่ซับซ้อนที่สุด ต้องพิถีพิถันในเรื่อง UX, animations, และ performance!
