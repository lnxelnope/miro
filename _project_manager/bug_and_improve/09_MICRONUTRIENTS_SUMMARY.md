# Implementation Guide #09: Micronutrients in Summary Page

**Priority:** 🟢 Low-Medium  
**Estimated Time:** 2-3 hours  
**Difficulty:** Medium

---

## Overview

Add micronutrient tracking display to the summary page. This task is conditional - only implement if the AI backend returns micronutrient data (fiber, sugar, sodium, cholesterol, saturated fat).

---

## Prerequisites Check

Before starting implementation, you MUST verify:
1. Whether AI responses include micronutrient data
2. Whether the database stores micronutrient values

---

## Step-by-Step Implementation

### STEP 1: Verify AI Returns Micronutrient Data

**Check backend response:**

**File:** `functions/src/index.ts`

**Find the AI response structure (around line 200-400):**

Look for this in the prompt:
```typescript
"nutrition": {
  "calories": 0,
  "protein": 0,
  "carbs": 0,
  "fat": 0,
  "fiber": 0,        // Check if these exist
  "sugar": 0,        // Check if these exist
  "sodium": 0,       // Check if these exist
  "cholesterol": 0,  // Check if these exist
  "saturated_fat": 0 // Check if these exist
}
```

**If micronutrients are NOT in the prompt:**

You need to add them to Task #04's implementation. Go back to `04_AI_INGREDIENT_BREAKDOWN.md` and ensure the prompt includes micronutrients.

---

### STEP 2: Verify Database Model Stores Micronutrients

**File:** `lib/features/health/models/food_entry.dart`

**Find the `NutritionData` class:**

```dart
class NutritionData {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double? fiber;        // Check if these exist
  final double? sugar;        // Check if these exist
  final double? sodium;       // Check if these exist
  final double? cholesterol;  // Check if these exist
  final double? saturatedFat; // Check if these exist
  
  // ...
}
```

**If micronutrient fields DON'T exist, ADD them:**

```dart
class NutritionData {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double? fiber;
  final double? sugar;
  final double? sodium;
  final double? cholesterol;
  final double? saturatedFat;

  const NutritionData({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber,
    this.sugar,
    this.sodium,
    this.cholesterol,
    this.saturatedFat,
  });

  factory NutritionData.fromJson(Map<String, dynamic> json) {
    return NutritionData(
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      fiber: (json['fiber'] as num?)?.toDouble(),
      sugar: (json['sugar'] as num?)?.toDouble(),
      sodium: (json['sodium'] as num?)?.toDouble(),
      cholesterol: (json['cholesterol'] as num?)?.toDouble(),
      saturatedFat: (json['saturated_fat'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      if (fiber != null) 'fiber': fiber,
      if (sugar != null) 'sugar': sugar,
      if (sodium != null) 'sodium': sodium,
      if (cholesterol != null) 'cholesterol': cholesterol,
      if (saturatedFat != null) 'saturated_fat': saturatedFat,
    };
  }
}
```

---

### STEP 3: Create Micronutrient Display Widget

**Create file:** `lib/features/health/widgets/micronutrient_row.dart`

**Full file content:**

```dart
import 'package:flutter/material.dart';

/// Displays a single micronutrient value in a row
class MicronutrientRow extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final IconData icon;
  final Color? color;

  const MicronutrientRow({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (color ?? Colors.grey).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: color ?? Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '${value.toStringAsFixed(1)} $unit',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

### STEP 4: Add Micronutrient Section to Daily Summary Card

**File:** `lib/features/health/widgets/daily_summary_card.dart`

**Find where macronutrient progress bars are displayed (around line 100-150).**

**After the macronutrient section, add micronutrient section:**

```dart
import 'package:miro/features/health/widgets/micronutrient_row.dart';

// After macronutrient display, add:

// Calculate total micronutrients
double totalFiber = 0;
double totalSugar = 0;
double totalSodium = 0;
double totalCholesterol = 0;
double totalSaturatedFat = 0;

for (final entry in foodEntries) {
  final nutrition = entry.calculatedNutrition;
  totalFiber += nutrition.fiber ?? 0;
  totalSugar += nutrition.sugar ?? 0;
  totalSodium += nutrition.sodium ?? 0;
  totalCholesterol += nutrition.cholesterol ?? 0;
  totalSaturatedFat += nutrition.saturatedFat ?? 0;
}

// Check if any micronutrient data exists
final hasMicronutrients = totalFiber > 0 ||
    totalSugar > 0 ||
    totalSodium > 0 ||
    totalCholesterol > 0 ||
    totalSaturatedFat > 0;

if (hasMicronutrients) ...[
  const SizedBox(height: 24),
  const Divider(),
  const SizedBox(height: 16),
  
  // Micronutrient header
  const Text(
    'Micronutrients',
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),
  const SizedBox(height: 12),
  
  // Micronutrient rows
  if (totalFiber > 0)
    MicronutrientRow(
      label: 'Fiber',
      value: totalFiber,
      unit: 'g',
      icon: Icons.grass,
      color: Colors.green,
    ),
  
  if (totalSugar > 0)
    MicronutrientRow(
      label: 'Sugar',
      value: totalSugar,
      unit: 'g',
      icon: Icons.cake,
      color: Colors.pink,
    ),
  
  if (totalSodium > 0)
    MicronutrientRow(
      label: 'Sodium',
      value: totalSodium,
      unit: 'mg',
      icon: Icons.water_drop,
      color: Colors.orange,
    ),
  
  if (totalCholesterol > 0)
    MicronutrientRow(
      label: 'Cholesterol',
      value: totalCholesterol,
      unit: 'mg',
      icon: Icons.favorite,
      color: Colors.red,
    ),
  
  if (totalSaturatedFat > 0)
    MicronutrientRow(
      label: 'Saturated Fat',
      value: totalSaturatedFat,
      unit: 'g',
      icon: Icons.opacity,
      color: Colors.purple,
    ),
],
```

---

### STEP 5: Test with Real Data

**Run the app and test:**

1. Analyze a food item with AI
2. Check if micronutrient data is returned
3. View the Daily Summary Card
4. Verify micronutrients display if data exists

**Check logs:**

```dart
// Add debug print in daily_summary_card.dart:
print('Fiber: $totalFiber, Sugar: $totalSugar, Sodium: $totalSodium');
```

---

### STEP 6: Add Micronutrient Note (Optional)

**If micronutrients display, add an info note:**

```dart
if (hasMicronutrients) ...[
  // ... micronutrient rows ...
  
  const SizedBox(height: 12),
  Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.blue.shade50,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Icon(Icons.info_outline, size: 16, color: Colors.blue.shade700),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Micronutrient values are estimates from AI analysis',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade700,
            ),
          ),
        ),
      ],
    ),
  ),
],
```

---

## Decision Tree

```
START
  │
  ├─→ Check AI Response
  │   ├─→ Has micronutrients? → YES → Continue to STEP 2
  │   └─→ Has micronutrients? → NO → Update AI prompt (Task #04)
  │
  ├─→ Check Database Model
  │   ├─→ Has fields? → YES → Continue to STEP 3
  │   └─→ Has fields? → NO → Add fields to model
  │
  ├─→ Implement Display Widget (STEP 3)
  │
  ├─→ Add to Summary Card (STEP 4)
  │
  └─→ Test with Real Data (STEP 5)
      ├─→ Data appears? → YES → DONE ✅
      └─→ Data appears? → NO → Debug AI response
```

---

## Testing Checklist

- [ ] AI response includes micronutrient values
- [ ] Database stores micronutrient values
- [ ] Micronutrient section appears in Daily Summary Card
- [ ] Only non-zero values are displayed
- [ ] Icons and colors are correct
- [ ] Values are formatted correctly (1 decimal place)
- [ ] Units are correct (g for fiber/sugar/fat, mg for sodium/cholesterol)
- [ ] No errors when micronutrient data is missing
- [ ] Section only shows when data exists
- [ ] Info note displays (optional)

---

## Troubleshooting

### Issue: Micronutrients don't appear
**Solution:** Check if AI returns micronutrient data. Add debug prints to verify values > 0.

### Issue: Values are always 0
**Solution:** AI might not be returning micronutrient data. Update backend prompt in Task #04.

### Issue: Icons don't display
**Solution:** Ensure Material Icons package is included (it should be by default).

### Issue: Layout breaks with long text
**Solution:** Use `Expanded` widget to wrap flexible text.

---

## If AI Does NOT Return Micronutrient Data

**You have two options:**

### Option A: Update AI Prompt (Recommended)

Go to Task #04 and add micronutrients to the AI prompt:

```typescript
"nutrition": {
  "calories": 0,
  "protein": 0,
  "carbs": 0,
  "fat": 0,
  "fiber": 0,
  "sugar": 0,
  "sodium": 0,
  "cholesterol": 0,
  "saturated_fat": 0
}
```

### Option B: Skip This Task

If micronutrients are not important for the MVP:
- Skip this implementation
- Document that micronutrients are not tracked
- Can be added in future versions

---

## Completion Criteria

✅ Task is complete when:
- Verified AI returns micronutrient data OR updated prompt to include it
- Database model stores micronutrient values
- Micronutrient display widget created
- Micronutrients appear in Daily Summary Card
- Only non-zero values display
- Proper formatting and styling
- No crashes when data is missing
- Tested with real food entries

---

## Estimated Time

- 30 min: Verify AI response and database model
- 30 min: Create display widget
- 45 min: Add to summary card
- 30 min: Testing and debugging

**Total: 2-3 hours**

---

## Notes

- Micronutrients are OPTIONAL - not all foods have complete data
- Only display micronutrients that have values > 0
- This is supplementary information, not core functionality
- Users don't set goals for micronutrients (unlike macros)
- Values are estimates and may not be 100% accurate
