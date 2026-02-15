# Implementation Guide #04: Fix AI Image Analysis - Ingredient Breakdown

**Priority:** 🔴 High  
**Estimated Time:** 2-3 hours  
**Difficulty:** Medium

---

## Overview

Fix the AI image analysis to ALWAYS return detailed ingredient breakdown, not just aggregated summary data. This applies to all image analysis modes: camera capture, gallery selection, and auto-scan.

---

## Problem

Currently, AI sometimes returns:
```json
{
  "food_name": "Steak with fries",
  "calories": 650,
  "protein": 43,
  "carbs": 35,
  "fat": 37
}
```

**Expected:** Should ALWAYS return ingredient breakdown:
```json
{
  "food_name": "Steak with fries",
  "calories": 650,
  "ingredients_detail": [
    {
      "name": "Beef Steak",
      "amount": 150,
      "unit": "gram",
      "calories": 375,
      "protein": 40,
      "carbs": 0,
      "fat": 22
    },
    {
      "name": "French Fries",
      "amount": 100,
      "unit": "gram",
      "calories": 220,
      "protein": 3,
      "carbs": 30,
      "fat": 11
    },
    {
      "name": "Sauce",
      "amount": 20,
      "unit": "ml",
      "calories": 55,
      "protein": 0,
      "carbs": 5,
      "fat": 4
    }
  ]
}
```

---

## Files to Modify

### Backend (Cloud Functions)
1. `functions/src/index.ts` - Update AI prompt

### Frontend (Flutter)
1. `lib/core/ai/gemini_service.dart` - Verify response parsing
2. `lib/features/health/widgets/gemini_analysis_sheet.dart` - Display ingredients properly

---

## Step-by-Step Implementation

### STEP 1: Update Backend Cloud Function Prompt

**File:** `functions/src/index.ts`

**Find the `analyzeFood` function and locate the image analysis section.**

**Search for where the AI prompt is built for image analysis (around line 200-350):**

```typescript
case 'food_image':
  // Current prompt
  const imagePart = {
    inlineData: {
      data: imageBase64,
      mimeType: 'image/jpeg'
    }
  };
  
  const prompt = `Analyze this food image...`;
```

**Replace the prompt with this DETAILED prompt:**

```typescript
case 'food_image': {
  const { foodName, quantity, unit } = requestData;
  
  const imagePart = {
    inlineData: {
      data: imageBase64,
      mimeType: 'image/jpeg'
    }
  };
  
  let promptText = `You are a nutrition analysis expert. Analyze this food image and provide DETAILED nutritional information.

IMPORTANT REQUIREMENTS:
1. You MUST identify ALL individual ingredients/components visible in the image
2. You MUST provide nutritional breakdown for EACH ingredient separately
3. You MUST include the "ingredients_detail" array with ALL ingredients
4. DO NOT just provide a total summary - break down every ingredient

`;

  // Add user-provided context if available
  if (foodName) {
    promptText += `User has identified this as: "${foodName}"\n`;
  }
  if (quantity && unit) {
    promptText += `User specified quantity: ${quantity} ${unit}\n`;
  }

  promptText += `
Return a JSON object with this EXACT structure:
{
  "food_name": "Overall dish name",
  "confidence": 0.0-1.0,
  "serving_size": ${quantity || 1},
  "serving_unit": "${unit || 'serving'}",
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
  },
  "ingredients_detail": [
    {
      "name": "Ingredient 1 name",
      "amount": 0,
      "unit": "gram/ml/piece/etc",
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
  ],
  "notes": "Analysis notes or confidence issues"
}

CRITICAL RULES:
- "ingredients_detail" array is MANDATORY and must contain at least 1 ingredient
- For complex dishes (like steak with fries), list each component separately
- For simple foods (like an apple), still create 1 ingredient entry
- The sum of all ingredient nutrition should approximately equal the total nutrition
- Estimate amounts in grams/ml when possible
- If you cannot identify ingredients, still provide your best estimate in ingredients_detail

Example for "Steak with French Fries":
- Ingredient 1: Beef Steak (150g)
- Ingredient 2: French Fries (100g)  
- Ingredient 3: Sauce (if visible, 20ml)

Return ONLY valid JSON, no markdown or explanations.`;

  const result = await model.generateContent([promptText, imagePart]);
  const response = await result.response;
  let text = response.text();
  
  // Parse and validate response
  // ... existing parsing code
  
  break;
}
```

---

### STEP 2: Add Response Validation

**Still in:** `functions/src/index.ts`

**After parsing the JSON response, add validation:**

**Find where JSON is parsed (after `JSON.parse`):**

```typescript
// Remove markdown code blocks if present
text = text.replace(/```json\n?/g, '').replace(/```\n?/g, '').trim();

const analysisResult = JSON.parse(text);

// Add this validation:
if (!analysisResult.ingredients_detail || !Array.isArray(analysisResult.ingredients_detail)) {
  console.error('AI response missing ingredients_detail array');
  
  // Create default ingredient from main nutrition data
  analysisResult.ingredients_detail = [
    {
      name: analysisResult.food_name || 'Unknown Food',
      amount: analysisResult.serving_size || 1,
      unit: analysisResult.serving_unit || 'serving',
      calories: analysisResult.nutrition?.calories || 0,
      protein: analysisResult.nutrition?.protein || 0,
      carbs: analysisResult.nutrition?.carbs || 0,
      fat: analysisResult.nutrition?.fat || 0,
      fiber: analysisResult.nutrition?.fiber || 0,
      sugar: analysisResult.nutrition?.sugar || 0,
      sodium: analysisResult.nutrition?.sodium || 0,
      cholesterol: analysisResult.nutrition?.cholesterol || 0,
      saturated_fat: analysisResult.nutrition?.saturated_fat || 0,
    }
  ];
  
  console.log('Created fallback ingredient from main nutrition');
}

if (analysisResult.ingredients_detail.length === 0) {
  console.error('ingredients_detail array is empty');
  throw new functions.https.HttpsError(
    'failed-precondition',
    'AI failed to identify any ingredients'
  );
}

return analysisResult;
```

---

### STEP 3: Update Barcode Product Analysis Prompt

**Still in:** `functions/src/index.ts`

**Find the `barcode_product` case (around line 400-500):**

**Update the prompt similarly:**

```typescript
case 'barcode_product': {
  const { barcodeValue } = requestData;
  
  const imagePart = {
    inlineData: {
      data: imageBase64,
      mimeType: 'image/jpeg'
    }
  };
  
  let promptText = `You are a nutrition analysis expert. This is a product with barcode: ${barcodeValue}

Analyze the product packaging image and extract nutritional information.

IMPORTANT REQUIREMENTS:
1. You MUST provide "ingredients_detail" array with individual ingredients if visible
2. If nutrition label is visible, extract exact values
3. If ingredients list is visible, parse each ingredient separately
4. DO NOT just provide a total summary

Return JSON with this structure:
{
  "food_name": "Product name",
  "confidence": 0.0-1.0,
  "serving_size": 1,
  "serving_unit": "serving",
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
  },
  "ingredients_detail": [
    {
      "name": "Ingredient name",
      "amount": 0,
      "unit": "gram",
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
  ],
  "barcode": "${barcodeValue}",
  "notes": "Any relevant notes"
}

CRITICAL: ingredients_detail array is MANDATORY.
If ingredients list is visible on label, parse each one separately.
If not visible, estimate main components.

Return ONLY valid JSON.`;

  const result = await model.generateContent([promptText, imagePart]);
  // ... rest of code
  
  break;
}
```

---

### STEP 4: Update Nutrition Label Analysis Prompt

**Still in:** `functions/src/index.ts`

**Find the `nutrition_label` case:**

```typescript
case 'nutrition_label': {
  let promptText = `You are a nutrition label OCR expert. Extract ALL information from this nutrition facts label.

IMPORTANT REQUIREMENTS:
1. Extract serving size and serving unit
2. Extract ALL nutritional values visible
3. If ingredients list is visible, parse it into "ingredients_detail" array
4. Provide exact values, do not estimate

Return JSON:
{
  "food_name": "Product name from label",
  "confidence": 0.0-1.0,
  "serving_size": 0,
  "serving_unit": "from label",
  "servings_per_container": 0,
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
  },
  "ingredients_detail": [
    {
      "name": "Ingredient from ingredients list",
      "amount": 0,
      "unit": "gram",
      "calories": 0,
      "protein": 0,
      "carbs": 0,
      "fat": 0
    }
  ],
  "notes": "Any notes"
}

If ingredients list is NOT visible on the label, you can leave ingredients_detail as empty array [].
If ingredients list IS visible, parse each ingredient.

Return ONLY valid JSON.`;

  // ... rest of code
  
  break;
}
```

---

### STEP 5: Deploy Updated Cloud Function

**Run in terminal:**

```bash
cd functions
npm run build
firebase deploy --only functions
```

**Wait for deployment to complete (2-5 minutes).**

**Verify deployment:**
```bash
firebase functions:log
```

---

### STEP 6: Verify Frontend Response Parsing

**File:** `lib/core/ai/gemini_service.dart`

**Find the `analyzeFoodImage` method and check response parsing.**

**Look for where `FoodAnalysisResult` is created from JSON:**

```dart
// Around line 250-350
final responseData = jsonDecode(responseBody);

if (responseData['error'] != null) {
  throw Exception(responseData['error']);
}

// Ensure ingredients_detail is parsed
return FoodAnalysisResult.fromJson(responseData);
```

**Check if `FoodAnalysisResult.fromJson` handles `ingredients_detail`:**

**File:** `lib/features/health/models/food_entry.dart` or similar model file

**Find `FoodAnalysisResult` class:**

```dart
class FoodAnalysisResult {
  final String foodName;
  final double confidence;
  final double servingSize;
  final String servingUnit;
  final NutritionData nutrition;
  final List<IngredientDetail>? ingredientsDetail; // Ensure this exists
  final String? notes;
  
  // ... constructor and fromJson
  
  factory FoodAnalysisResult.fromJson(Map<String, dynamic> json) {
    return FoodAnalysisResult(
      foodName: json['food_name'] as String,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
      servingSize: (json['serving_size'] as num?)?.toDouble() ?? 1.0,
      servingUnit: json['serving_unit'] as String? ?? 'serving',
      nutrition: NutritionData.fromJson(json['nutrition'] as Map<String, dynamic>),
      ingredientsDetail: (json['ingredients_detail'] as List<dynamic>?)
          ?.map((e) => IngredientDetail.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: json['notes'] as String?,
    );
  }
}
```

**If `ingredientsDetail` field doesn't exist, ADD it.**

---

### STEP 7: Verify IngredientDetail Model Exists

**Search for `IngredientDetail` class:**

```bash
rg "class IngredientDetail" --type dart
```

**If NOT found, create it:**

**File:** Add to existing model file or create `lib/features/health/models/ingredient_detail.dart`

```dart
class IngredientDetail {
  final String name;
  final double amount;
  final String unit;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double? fiber;
  final double? sugar;
  final double? sodium;
  final double? cholesterol;
  final double? saturatedFat;

  const IngredientDetail({
    required this.name,
    required this.amount,
    required this.unit,
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

  factory IngredientDetail.fromJson(Map<String, dynamic> json) {
    return IngredientDetail(
      name: json['name'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? 'gram',
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
      'name': name,
      'amount': amount,
      'unit': unit,
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

### STEP 8: Update Analysis Sheet to Display Ingredients

**File:** `lib/features/health/widgets/gemini_analysis_sheet.dart`

**Find where analysis results are displayed.**

**Add a section to show ingredients breakdown:**

```dart
// After displaying main nutrition summary
if (widget.result.ingredientsDetail != null && 
    widget.result.ingredientsDetail!.isNotEmpty) {
  const SizedBox(height: 24),
  Text(
    'Ingredient Breakdown',
    style: Theme.of(context).textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.bold,
    ),
  ),
  const SizedBox(height: 12),
  
  // List each ingredient
  ...widget.result.ingredientsDetail!.map((ingredient) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  ingredient.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                '${ingredient.amount} ${ingredient.unit}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Calories: ${ingredient.calories.toStringAsFixed(0)} kcal'),
              Text('P: ${ingredient.protein.toStringAsFixed(1)}g'),
              Text('C: ${ingredient.carbs.toStringAsFixed(1)}g'),
              Text('F: ${ingredient.fat.toStringAsFixed(1)}g'),
            ],
          ),
        ],
      ),
    );
  }).toList(),
}
```

---

## Testing Checklist

After completing all steps:

- [ ] Deploy backend function successfully
- [ ] Test camera capture → Analyze steak with fries
- [ ] Verify response includes `ingredients_detail` array
- [ ] Verify array has at least 2-3 ingredients (steak, fries, sauce)
- [ ] Each ingredient has: name, amount, unit, calories, protein, carbs, fat
- [ ] UI displays ingredient breakdown section
- [ ] Test with simple food (single apple) → Should have 1 ingredient
- [ ] Test with complex dish (mixed salad) → Should have multiple ingredients
- [ ] Test barcode product → Should include ingredients if visible on package
- [ ] Test nutrition label → Should extract ingredients if list is visible
- [ ] Check Firebase Functions logs for any errors
- [ ] Verify energy is consumed correctly (1 Energy per analysis)

---

## Troubleshooting

### Issue: AI still returns no ingredients_detail
**Solution:** Check Firebase Functions logs. AI might be failing to parse. Review prompt wording.

### Issue: ingredients_detail is empty array
**Solution:** Backend validation should create fallback. Check validation code in STEP 2.

### Issue: Frontend crash when displaying ingredients
**Solution:** Check null safety. Verify `ingredientsDetail` is nullable and handled properly.

### Issue: Ingredients don't sum to total nutrition
**Solution:** This is expected (AI estimation). Add note in UI: "Values are approximations."

---

## Verification Commands

```bash
# Check if IngredientDetail model exists
rg "class IngredientDetail" --type dart

# Check if FoodAnalysisResult has ingredientsDetail field
rg "ingredientsDetail" lib/features/health/models/

# View Firebase Functions logs
firebase functions:log --limit 50

# Test API endpoint manually (optional)
curl -X POST https://YOUR-REGION-YOUR-PROJECT.cloudfunctions.net/analyzeFood \
  -H "Content-Type: application/json" \
  -d '{"imageBase64":"...","analysisType":"food_image"}'
```

---

## Completion Criteria

✅ Task is complete when:
- Backend Cloud Function updated with detailed prompt
- Validation ensures `ingredients_detail` always exists
- Frontend models parse `ingredients_detail` correctly
- UI displays ingredient breakdown for all analyses
- All 3 image analysis modes return ingredients:
  - Camera capture
  - Gallery selection
  - Auto-scan (pull-to-refresh)
- Tested with multiple food types (simple and complex)
- No crashes or null pointer errors
- Firebase Functions logs show no errors

---

## Estimated Time

- 1 hour: Update backend prompts and validation
- 30 min: Deploy and test backend
- 30 min: Verify frontend models
- 30 min: Update UI to display ingredients
- 30 min: End-to-end testing

**Total: 2-3 hours**
