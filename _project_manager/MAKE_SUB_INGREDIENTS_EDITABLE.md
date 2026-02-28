# Make Sub-Ingredients Editable & Collapsible

**File:** `lib/features/health/widgets/gemini_analysis_sheet.dart`

**Goal:** 
- Make sub-ingredients editable (like parent ingredients)
- Add collapse/expand functionality
- Add lookup button (🔍) for each sub-ingredient to use AI/DB
- Generate more Energy usage for users

---

## Changes Needed

### 1. ✅ DONE: Add `isExpanded` field

Already added at line ~40:
```dart
bool isExpanded = false; // NEW: สำหรับ collapse/expand sub-ingredients
```

---

### 2. Replace line 1157-1256 (sub-ingredients display section)

**OLD CODE (Read-only):**
```dart
// NEW: แสดง sub-ingredients (ถ้ามี)
if (hasSubs) ...[
  Padding(
    padding: const EdgeInsets.only(left: 24, bottom: 8),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Sub-ingredients list
        ...row.subIngredients!.map((sub) {
          return Container(
            // ... read-only display ...
          );
        }),
        // Info text
        Padding(...),
      ],
    ),
  ),
],
```

**NEW CODE (Collapsible + Editable):**
```dart
// NEW: แสดง sub-ingredients (ถ้ามี) - Collapsible + Editable
if (hasSubs) ...[
  // Expand/Collapse button
  InkWell(
    onTap: () => setState(() => row.isExpanded = !row.isExpanded),
    child: Container(
      margin: const EdgeInsets.only(left: 24, bottom: 8, top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            row.isExpanded ? Icons.expand_less : Icons.expand_more,
            size: 16,
            color: Colors.blue.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            row.isExpanded
                ? 'Hide ${row.subIngredients!.length} sub-ingredients'
                : 'Show ${row.subIngredients!.length} sub-ingredients',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    ),
  ),

  // Sub-ingredients list (editable when expanded)
  if (row.isExpanded)
    Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...row.subIngredients!.asMap().entries.map((entry) {
            final subIndex = entry.key;
            final sub = entry.value;
            return _buildSubIngredientRow(index, subIndex, sub);
          }),
          // Info text
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    size: 12, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Sub-ingredients are for breakdown info (editable, searchable)',
                    style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
],
```

---

### 3. Add new method `_buildSubIngredientRow()` after `_buildEditableIngredientRow()`

**Location:** Add around line 1260+

```dart
/// Build editable sub-ingredient row (similar to parent but indented)
Widget _buildSubIngredientRow(int parentIndex, int subIndex, _EditableIngredient sub) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1: Name + Lookup + Delete
        Row(
          children: [
            // Indent indicator
            Container(
              width: 2,
              height: 20,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            // Name field
            Expanded(
              child: TextField(
                controller: sub.nameController,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: 'Sub-ingredient name',
                  hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            
            // Lookup button (🔍)
            if (!sub.isLoading)
              InkWell(
                onTap: () => _onSubIngredientLookup(parentIndex, subIndex),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.search, size: 16, color: Colors.blue),
                ),
              )
            else
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            
            const SizedBox(width: 4),
            
            // Delete button
            InkWell(
              onTap: () => _deleteSubIngredient(parentIndex, subIndex),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.red),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Row 2: Amount + Unit + Nutrition
        Row(
          children: [
            const SizedBox(width: 10), // indent
            // Amount
            SizedBox(
              width: 60,
              child: TextField(
                controller: sub.amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  hintText: '0',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onChanged: (_) {
                  setState(() {
                    sub.recalculate();
                    _recalculateTotals();
                  });
                },
              ),
            ),
            const SizedBox(width: 6),
            
            // Unit dropdown
            SizedBox(
              width: 72,
              child: DropdownButtonFormField<String>(
                value: _getValidUnit(sub.unit),
                isDense: true,
                style: const TextStyle(fontSize: 12, color: Colors.black87),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: _buildCompactUnitItems(),
                onChanged: (newUnit) {
                  if (newUnit != null) {
                    setState(() {
                      _onSubIngredientUnitChanged(sub, newUnit);
                    });
                  }
                },
              ),
            ),
            const Spacer(),
            
            // Nutrition info
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${sub.calories.toInt()} kcal',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'P:${sub.protein.toInt()} C:${sub.carbs.toInt()} F:${sub.fat.toInt()}',
                  style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
        
        // Detail text (if any)
        if (sub.detail != null && sub.detail!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              sub.detail!,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    ),
  );
}
```

---

### 4. Add lookup method for sub-ingredients

**Location:** Add after `_onIngredientLookup()` method

```dart
/// Lookup sub-ingredient (via AI or DB)
Future<void> _onSubIngredientLookup(int parentIndex, int subIndex) async {
  final parent = _ingredients[parentIndex];
  final sub = parent.subIngredients![subIndex];
  final subName = sub.nameController.text.trim();
  
  if (subName.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter sub-ingredient name first')),
    );
    return;
  }

  setState(() => sub.isLoading = true);

  try {
    // 1. Try database first
    final dbResult = await ref.read(ingredientSearchProvider(subName).future);
    if (dbResult.isNotEmpty) {
      final ing = dbResult.first;
      setState(() {
        sub.nameController.text = ing.name;
        sub.nameEn = ing.nameEn;
        sub.unit = ing.unit;
        
        final amount = double.tryParse(sub.amountController.text) ?? 1;
        sub.baseAmount = 1;
        sub.baseCalories = ing.calories;
        sub.baseProtein = ing.protein;
        sub.baseCarbs = ing.carbs;
        sub.baseFat = ing.fat;
        
        sub.calories = ing.calories * amount;
        sub.protein = ing.protein * amount;
        sub.carbs = ing.carbs * amount;
        sub.fat = ing.fat * amount;
        
        sub.isFromDb = true;
        sub.isLoading = false;
      });
      
      _recalculateTotals();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Found "$subName" in database! ✅'),
            backgroundColor: Colors.green,
          ),
        );
      }
      return;
    }

    // 2. If not in DB, use AI
    if (!mounted) return;
    
    final hasEnergy = await _checkEnergy();
    if (!hasEnergy) {
      setState(() => sub.isLoading = false);
      return;
    }

    final amount = double.tryParse(sub.amountController.text) ?? 1;
    final unit = sub.unit;

    final result = await GeminiService.analyzeFoodFromText(
      '$amount $unit $subName',
    );

    if (!mounted) return;

    if (result != null && result.nutrition != null) {
      // Deduct energy
      await ref.read(energyServiceProvider).deductEnergy(1);
      ref.invalidate(userEnergyProvider);

      setState(() {
        sub.nameController.text = result.foodName;
        sub.nameEn = result.foodNameEn;
        sub.unit = result.servingUnit;
        sub.amountController.text = result.servingSize.toString();
        
        sub.baseAmount = result.servingSize;
        sub.baseCalories = result.nutrition!.calories / result.servingSize;
        sub.baseProtein = result.nutrition!.protein / result.servingSize;
        sub.baseCarbs = result.nutrition!.carbs / result.servingSize;
        sub.baseFat = result.nutrition!.fat / result.servingSize;
        
        sub.calories = result.nutrition!.calories;
        sub.protein = result.nutrition!.protein;
        sub.carbs = result.nutrition!.carbs;
        sub.fat = result.nutrition!.fat;
        
        sub.isFromDb = false;
        sub.isLoading = false;
      });
      
      _recalculateTotals();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI analyzed "$subName" successfully! ✅ (-1 Energy)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      setState(() => sub.isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not analyze sub-ingredient'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  } catch (e) {
    AppLogger.error('Sub-ingredient lookup failed', e);
    setState(() => sub.isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
```

---

### 5. Add delete method for sub-ingredients

```dart
/// Delete a sub-ingredient
void _deleteSubIngredient(int parentIndex, int subIndex) {
  setState(() {
    final parent = _ingredients[parentIndex];
    parent.subIngredients![subIndex].dispose();
    parent.subIngredients!.removeAt(subIndex);
    
    // If no more subs, remove the list
    if (parent.subIngredients!.isEmpty) {
      parent.subIngredients = null;
      parent.isExpanded = false;
    }
    
    _recalculateTotals();
  });
}
```

---

### 6. Add unit change handler for sub-ingredients

```dart
/// Handle unit change for sub-ingredient
Future<void> _onSubIngredientUnitChanged(_EditableIngredient sub, String newUnit) async {
  final oldUnit = sub.unit;
  final currentAmount = double.tryParse(sub.amountController.text) ?? 0;
  
  if (currentAmount <= 0) {
    sub.unit = newUnit;
    return;
  }

  // Convert if possible
  final conversion = UnitConverter.convert(
    amount: currentAmount,
    fromUnit: oldUnit,
    toUnit: newUnit,
  );

  if (conversion != null) {
    setState(() {
      sub.amountController.text = conversion['amount'].toStringAsFixed(0);
      sub.unit = newUnit;
      sub.recalculate();
      _recalculateTotals();
    });
  } else {
    // Cannot convert, just change unit
    setState(() {
      sub.unit = newUnit;
    });
  }
}
```

---

## Summary

**Benefits:**
1. ✅ Sub-ingredients are now **editable** (name, amount, unit)
2. ✅ **Collapsible** - users can hide/show sub-ingredients
3. ✅ **Lookup button (🔍)** - search from DB or use AI (costs 1 Energy)
4. ✅ **Delete button** - remove sub-ingredients if needed
5. ✅ **More Energy usage** - each sub-ingredient lookup costs 1 Energy!

**User Flow:**
1. User sees parent ingredient with "Show N sub-ingredients" button
2. Click to expand → see all sub-ingredients (editable)
3. Edit any sub-ingredient name → click 🔍 to search
4. AI analyzes → costs 1 Energy → user uses more Energy!
5. Can collapse to save space

**Energy Impact:**
- Before: 1 Energy per food analysis
- After: 1 Energy + (N sub-ingredients × 1 Energy if user re-searches them)
- Example: "KFC Chicken Pop" with 3 sub-ingredients → up to 4 Energy total!

---

## Testing Checklist

- [ ] Sub-ingredients collapse/expand works
- [ ] Can edit sub-ingredient name, amount, unit
- [ ] Lookup button (🔍) searches DB first, then AI
- [ ] AI lookup costs 1 Energy
- [ ] Delete button removes sub-ingredient
- [ ] Totals recalculate correctly
- [ ] No crashes when expanding/collapsing
