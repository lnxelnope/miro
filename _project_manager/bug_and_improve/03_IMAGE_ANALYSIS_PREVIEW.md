# Implementation Guide #03: Image Analysis Preview Screen

**Priority:** 🔴 High  
**Estimated Time:** 3-4 hours  
**Difficulty:** Medium-High

---

## Overview

Create a preview screen that appears after capturing/selecting a food image. The screen allows users to edit food name, quantity, and unit before sending to AI for analysis.

---

## Files to Create/Modify

### New Files:
1. `lib/features/health/presentation/image_analysis_preview_screen.dart` - Main preview screen
2. `lib/features/health/models/image_analysis_request.dart` - Data model for analysis request

### Files to Modify:
1. `lib/features/home/presentation/home_screen.dart` - Navigate to preview after camera
2. `lib/features/health/presentation/nutrition_label_screen.dart` - Use new preview flow
3. `lib/features/health/presentation/barcode_scanner_screen.dart` - Use new preview flow

---

## Step-by-Step Implementation

### STEP 1: Create Image Analysis Request Model

**Create file:** `lib/features/health/models/image_analysis_request.dart`

**Full file content:**
```dart
import 'dart:io';

/// Request model for image analysis with optional user inputs
class ImageAnalysisRequest {
  final File imageFile;
  final String? foodName;
  final double? quantity;
  final String? unit;

  const ImageAnalysisRequest({
    required this.imageFile,
    this.foodName,
    this.quantity,
    this.unit,
  });

  /// Creates a copy with updated fields
  ImageAnalysisRequest copyWith({
    File? imageFile,
    String? foodName,
    double? quantity,
    String? unit,
  }) {
    return ImageAnalysisRequest(
      imageFile: imageFile ?? this.imageFile,
      foodName: foodName ?? this.foodName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }
}
```

---

### STEP 2: Create Image Analysis Preview Screen

**Create file:** `lib/features/health/presentation/image_analysis_preview_screen.dart`

**Full file content:**
```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro/core/ai/gemini_service.dart';
import 'package:miro/core/services/energy_service.dart';
import 'package:miro/core/theme/app_colors.dart';
import 'package:miro/core/utils/loading_overlay.dart';
import 'package:miro/features/health/models/image_analysis_request.dart';
import 'package:miro/features/health/widgets/gemini_analysis_sheet.dart';

/// Available serving units for food
const List<String> servingUnits = [
  'serving',
  'plate',
  'bowl',
  'cup',
  'piece',
  'slice',
  'gram',
  'ounce',
  'tablespoon',
  'teaspoon',
];

class ImageAnalysisPreviewScreen extends ConsumerStatefulWidget {
  final File imageFile;
  final String? initialFoodName;
  final double? initialQuantity;
  final String? initialUnit;

  const ImageAnalysisPreviewScreen({
    super.key,
    required this.imageFile,
    this.initialFoodName,
    this.initialQuantity,
    this.initialUnit,
  });

  @override
  ConsumerState<ImageAnalysisPreviewScreen> createState() =>
      _ImageAnalysisPreviewScreenState();
}

class _ImageAnalysisPreviewScreenState
    extends ConsumerState<ImageAnalysisPreviewScreen> {
  late TextEditingController _foodNameController;
  late TextEditingController _quantityController;
  late String _selectedUnit;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _foodNameController = TextEditingController(
      text: widget.initialFoodName ?? 'food',
    );
    _quantityController = TextEditingController(
      text: (widget.initialQuantity ?? 1.0).toString(),
    );
    _selectedUnit = widget.initialUnit ?? 'serving';
  }

  @override
  void dispose() {
    _foodNameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _analyzeWithAI() async {
    if (_isAnalyzing) return;

    // Validate inputs
    final foodName = _foodNameController.text.trim();
    final quantityText = _quantityController.text.trim();
    
    double? quantity;
    if (quantityText.isNotEmpty) {
      quantity = double.tryParse(quantityText);
      if (quantity == null || quantity <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid quantity')),
        );
        return;
      }
    }

    setState(() {
      _isAnalyzing = true;
    });

    LoadingOverlay.show(context, message: 'Analyzing with AI...');

    try {
      final energyService = EnergyService();
      final geminiService = GeminiService(energyService: energyService);

      // Call AI analysis with optional parameters
      final result = await geminiService.analyzeFoodImage(
        widget.imageFile,
        foodName: foodName.isEmpty ? null : foodName,
        quantity: quantity,
        unit: _selectedUnit,
      );

      if (!mounted) return;

      LoadingOverlay.hide(context);

      // Show analysis result
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => GeminiAnalysisSheet(
          result: result,
          imageFile: widget.imageFile,
        ),
      );

      // Navigate back to home after analysis
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (!mounted) return;
      
      LoadingOverlay.hide(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Analysis failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Analyze Food Image'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Preview
            Container(
              height: 300,
              color: Colors.grey[200],
              child: Image.file(
                widget.imageFile,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 24),

            // Input Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food Name Input
                  Text(
                    'Food name',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _foodNameController,
                    decoration: InputDecoration(
                      hintText: 'e.g., Grilled chicken salad',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Quantity and Unit Row
                  Text(
                    'Quantity',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Quantity Input
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _quantityController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            hintText: '1',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Unit Dropdown
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          value: _selectedUnit,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          items: servingUnits.map((unit) {
                            return DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedUnit = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Helper Text
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.blue[700],
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Entering the food name and quantity is optional, but providing them will improve AI analysis accuracy.',
                            style: TextStyle(
                              color: Colors.blue[900],
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Analyze Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isAnalyzing ? null : _analyzeWithAI,
                      icon: const Icon(Icons.auto_awesome, size: 24),
                      label: Text(
                        _isAnalyzing ? 'Analyzing...' : 'Analyze with AI',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### STEP 3: Update Camera Button in Home Screen

**File:** `lib/features/home/presentation/home_screen.dart`

**Find the camera button code you added in Task #01:**
```dart
// Camera Button
SizedBox(
  width: 48.0,
  height: 48.0,
  child: FloatingActionButton(
    heroTag: 'camera_fab',
    onPressed: () async {
      final File? capturedImage = await Navigator.of(context).push<File>(
        MaterialPageRoute(
          builder: (context) => const CameraScreen(),
        ),
      );
      
      if (capturedImage != null && mounted) {
        // TODO: Navigate to Image Analysis Preview Screen (Task #3)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image captured: ${capturedImage.path}')),
        );
      }
    },
    backgroundColor: AppColors.primary,
    child: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
  ),
),
```

**Replace the `onPressed` function with:**
```dart
onPressed: () async {
  final File? capturedImage = await Navigator.of(context).push<File>(
    MaterialPageRoute(
      builder: (context) => const CameraScreen(),
    ),
  );
  
  if (capturedImage != null && mounted) {
    // Navigate to preview screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImageAnalysisPreviewScreen(
          imageFile: capturedImage,
        ),
      ),
    );
  }
},
```

**Add import at the top:**
```dart
import 'package:miro/features/health/presentation/image_analysis_preview_screen.dart';
```

---

### STEP 4: Update GeminiService to Support Optional Parameters

**File:** `lib/core/ai/gemini_service.dart`

**Find the `analyzeFoodImage` method (around line 150-250):**

```dart
Future<FoodAnalysisResult> analyzeFoodImage(File imageFile) async {
```

**Replace the method signature with:**
```dart
Future<FoodAnalysisResult> analyzeFoodImage(
  File imageFile, {
  String? foodName,
  double? quantity,
  String? unit,
}) async {
```

**Inside the method, find where the request body is prepared.**

**Look for something like:**
```dart
final requestBody = {
  'imageBase64': base64Image,
  'analysisType': 'food_image',
};
```

**Update it to include optional parameters:**
```dart
final requestBody = {
  'imageBase64': base64Image,
  'analysisType': 'food_image',
  if (foodName != null && foodName.isNotEmpty) 'foodName': foodName,
  if (quantity != null) 'quantity': quantity,
  if (unit != null) 'unit': unit,
};
```

---

### STEP 5: Update Backend Cloud Function (Optional but Recommended)

**File:** `functions/src/index.ts`

**Find the `analyzeFood` Cloud Function.**

**In the image analysis section, update the prompt to include optional parameters:**

**Look for the prompt construction (around line 200-300):**
```typescript
let prompt = `Analyze this food image and provide detailed nutritional information...`;
```

**Update it to:**
```typescript
const { foodName, quantity, unit } = requestData;

let prompt = `Analyze this food image and provide detailed nutritional information.`;

if (foodName) {
  prompt += ` The user has indicated this is: "${foodName}".`;
}

if (quantity && unit) {
  prompt += ` The user has specified the quantity as: ${quantity} ${unit}.`;
} else if (quantity) {
  prompt += ` The user has specified the quantity as: ${quantity}.`;
}

prompt += ` 

Return a JSON object with the following structure:
{
  "food_name": "Name of the food",
  "confidence": 0.95,
  "serving_size": ${quantity || 1},
  "serving_unit": "${unit || 'serving'}",
  ...
}`;
```

**Deploy the updated function:**
```bash
cd functions
npm run deploy
```

---

### STEP 6: Update Nutrition Label Screen Flow

**File:** `lib/features/health/presentation/nutrition_label_screen.dart`

**Find the `_takePicture` method (around line 174):**

**After capturing the image, instead of analyzing directly:**

**Find:**
```dart
if (_imageFile != null) {
  await _analyzeNutritionLabel();
}
```

**Replace with:**
```dart
if (_imageFile != null && mounted) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => ImageAnalysisPreviewScreen(
        imageFile: _imageFile!,
        initialFoodName: 'food',
      ),
    ),
  );
}
```

**Add import at the top:**
```dart
import 'package:miro/features/health/presentation/image_analysis_preview_screen.dart';
```

**Do the same for `_pickFromGallery` method.**

---

### STEP 7: Update Barcode Scanner Screen Flow

**File:** `lib/features/health/presentation/barcode_scanner_screen.dart`

**Find the `_captureAndAnalyze` method (around line 375):**

**After capturing product image, navigate to preview:**

**Find where the image is captured:**
```dart
final File? image = await imagePickerService.pickFromCamera();
if (image != null) {
  // existing analysis code
}
```

**Replace with:**
```dart
final File? image = await imagePickerService.pickFromCamera();
if (image != null && mounted) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => ImageAnalysisPreviewScreen(
        imageFile: image,
        initialFoodName: _barcodeValue ?? 'product',
      ),
    ),
  );
}
```

**Add import at the top:**
```dart
import 'package:miro/features/health/presentation/image_analysis_preview_screen.dart';
```

---

## Testing Checklist

After completing all steps, test:

- [ ] Capture image from camera button → Preview screen opens
- [ ] Preview screen shows captured image correctly
- [ ] Food name field defaults to "food"
- [ ] Quantity field defaults to "1"
- [ ] Unit dropdown defaults to "serving"
- [ ] Can edit all three fields (food name, quantity, unit)
- [ ] Unit dropdown shows all 10 units
- [ ] Helper text displays correctly (blue box with lightbulb icon)
- [ ] "Analyze with AI" button is visible and styled correctly
- [ ] Clicking "Analyze with AI" shows loading overlay
- [ ] After analysis, bottom sheet appears with results
- [ ] Energy is consumed (check energy badge decreases by 1)
- [ ] After closing result sheet, returns to home screen
- [ ] Test with empty food name → Should still work
- [ ] Test with invalid quantity (negative, text) → Shows error
- [ ] Test with nutrition label flow → Uses preview screen
- [ ] Test with barcode scanner flow → Uses preview screen

---

## Troubleshooting

### Issue: Image doesn't display in preview
**Solution:** Check file path is valid and file exists. Verify `Image.file()` widget has correct path.

### Issue: Analysis fails with parameters
**Solution:** Check backend Cloud Function is updated and deployed. Verify request body includes optional fields.

### Issue: Dropdown doesn't show units
**Solution:** Verify `servingUnits` list is defined at top of file. Check `DropdownButtonFormField` items are mapped correctly.

### Issue: Can't navigate back to home after analysis
**Solution:** Use `Navigator.of(context).popUntil((route) => route.isFirst)` to clear navigation stack.

---

## Completion Criteria

✅ Task is complete when:
- Preview screen displays after capturing/selecting image
- All input fields work correctly (food name, quantity, unit)
- AI analysis uses provided parameters
- Navigation flow works: Camera → Preview → Analysis → Home
- No build errors or runtime errors
- Energy is consumed correctly
- All flows (camera, nutrition label, barcode) use the new preview screen

---

## Estimated Time Breakdown

- 1 hour: Create preview screen UI
- 1 hour: Integrate with camera flow
- 30 min: Update GeminiService for optional parameters
- 30 min: Update backend Cloud Function
- 30 min: Update nutrition label and barcode flows
- 30 min: Testing and bug fixes

**Total: 3-4 hours**
