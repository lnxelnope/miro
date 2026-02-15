# Implementation Guide #08: Food Mock-up Tutorial with Detailed Usage Guide

**Priority:** 🔴 High  
**Estimated Time:** 4-6 hours  
**Difficulty:** Medium-High

---

## Overview

Create an interactive tutorial using a sample steak and fries image to teach users:
1. How to edit food name for accuracy
2. How to adjust quantity and unit
3. How to edit ingredients after AI analysis

This tutorial provides hands-on learning with a real example.

---

## Prerequisites

- Task #03 (Image Analysis Preview Screen) must be completed first
- Sample image file needed: `C:\Users\ASUS\Downloads\OIP.png`

---

## Files to Create/Modify

### New Files:
1. `assets/images/tutorial_steak.png` - Copy of sample image
2. `lib/features/onboarding/presentation/tutorial_food_analysis_screen.dart` - Tutorial screen
3. `lib/features/onboarding/models/tutorial_step.dart` - Tutorial step model

### Files to Modify:
1. `lib/features/onboarding/presentation/onboarding_screen.dart` - Add tutorial after onboarding
2. `pubspec.yaml` - Add new asset

---

## Step-by-Step Implementation

### STEP 1: Copy Sample Image to Assets

**Copy the image file:**

1. Copy `C:\Users\ASUS\Downloads\OIP.png` to `assets/images/tutorial_steak.png`

**Or use command:**

```bash
# Windows PowerShell
Copy-Item "C:\Users\ASUS\Downloads\OIP.png" "assets\images\tutorial_steak.png"

# Or manually:
# 1. Navigate to project root
# 2. Create assets/images folder if not exists
# 3. Copy OIP.png and rename to tutorial_steak.png
```

---

### STEP 2: Add Asset to pubspec.yaml

**File:** `pubspec.yaml`

**Find the `flutter:` section with `assets:`:**

```yaml
flutter:
  assets:
    - assets/images/
    - assets/images/tutorial_steak.png  # Add this line
    # ... other assets
```

**Run:**
```bash
flutter pub get
```

---

### STEP 3: Create Tutorial Step Model

**Create file:** `lib/features/onboarding/models/tutorial_step.dart`

**Full file content:**

```dart
/// Represents a step in the food analysis tutorial
class TutorialStep {
  final int stepNumber;
  final String title;
  final String description;
  final String? highlightText;
  final TutorialStepType type;
  final Map<String, dynamic>? data;

  const TutorialStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    this.highlightText,
    required this.type,
    this.data,
  });
}

enum TutorialStepType {
  introduction,
  editFoodName,
  editQuantity,
  analyzingWithAI,
  viewingResults,
  editingIngredients,
  completion,
}
```

---

### STEP 4: Create Tutorial Food Analysis Screen

**Create file:** `lib/features/onboarding/presentation/tutorial_food_analysis_screen.dart`

**This is a LONG file. Full content:**

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:miro/core/theme/app_colors.dart';
import 'package:miro/features/onboarding/models/tutorial_step.dart';

class TutorialFoodAnalysisScreen extends StatefulWidget {
  const TutorialFoodAnalysisScreen({super.key});

  @override
  State<TutorialFoodAnalysisScreen> createState() =>
      _TutorialFoodAnalysisScreenState();
}

class _TutorialFoodAnalysisScreenState
    extends State<TutorialFoodAnalysisScreen> {
  int _currentStep = 0;
  final TextEditingController _foodNameController =
      TextEditingController(text: 'food');
  final TextEditingController _quantityController =
      TextEditingController(text: '1');
  String _selectedUnit = 'serving';
  bool _showAnalysisResult = false;
  bool _highlightFoodName = false;
  bool _highlightQuantity = false;
  bool _highlightIngredients = false;

  final List<TutorialStep> _steps = [
    TutorialStep(
      stepNumber: 1,
      title: 'Welcome to Food Analysis Tutorial',
      description:
          'Let\'s learn how to get the most accurate nutritional analysis using this sample steak and fries image.',
      type: TutorialStepType.introduction,
    ),
    TutorialStep(
      stepNumber: 2,
      title: 'Step 1: Edit Food Name',
      description:
          'Specifying an accurate food name helps AI analyze more precisely.\n\n'
          'For example, without specifying, AI might identify this as "beef steak" when it\'s actually a "Vegan Steak (Beyond Meat)", which has very different nutritional values.\n\n'
          'Try changing the name from "food" to "Beyond Meat and Fries"',
      highlightText: 'Change the food name above',
      type: TutorialStepType.editFoodName,
    ),
    TutorialStep(
      stepNumber: 3,
      title: 'Step 2: Adjust Quantity and Unit',
      description:
          'You can change the quantity and select a specific unit for maximum accuracy.\n\n'
          'This is optional — you can always come back and edit later.\n\n'
          'Try changing the quantity or selecting a different unit.',
      highlightText: 'Adjust quantity/unit above',
      type: TutorialStepType.editQuantity,
    ),
    TutorialStep(
      stepNumber: 4,
      title: 'Step 3: View AI Analysis Results',
      description:
          'After analysis, you\'ll see detailed nutritional breakdown including individual ingredients.\n\n'
          'Each ingredient shows its own calories, protein, carbs, and fat values.',
      type: TutorialStepType.viewingResults,
    ),
    TutorialStep(
      stepNumber: 5,
      title: 'Step 4: Edit Ingredients',
      description:
          'If you\'re in a hurry, just analyze as-is first. You can always fine-tune any ingredient that doesn\'t look right later.\n\n'
          'You can edit individual ingredients and re-analyze for better accuracy.',
      highlightText: 'Ingredients are editable',
      type: TutorialStepType.editingIngredients,
    ),
    TutorialStep(
      stepNumber: 6,
      title: 'Tutorial Complete!',
      description:
          'You now know how to:\n'
          '• Edit food names for accuracy\n'
          '• Adjust quantity and units\n'
          '• View detailed ingredient breakdown\n'
          '• Edit and re-analyze ingredients\n\n'
          'You\'re ready to start tracking your nutrition!',
      type: TutorialStepType.completion,
    ),
  ];

  @override
  void dispose() {
    _foodNameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
        _updateHighlights();
        
        // Show mock analysis results at step 4
        if (_currentStep == 3) {
          _showAnalysisResult = true;
        }
      });
    } else {
      // Tutorial complete, navigate to home
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _updateHighlights();
        
        // Hide analysis results if going back from step 4
        if (_currentStep < 3) {
          _showAnalysisResult = false;
        }
      });
    }
  }

  void _skipTutorial() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _updateHighlights() {
    setState(() {
      _highlightFoodName = _currentStep == 1;
      _highlightQuantity = _currentStep == 2;
      _highlightIngredients = _currentStep == 4;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTutorialStep = _steps[_currentStep];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Food Analysis Tutorial'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _skipTutorial,
            child: const Text('SKIP'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentStep + 1) / _steps.length,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image Preview
                  if (_currentStep < 5)
                    Container(
                      height: 250,
                      color: Colors.grey[200],
                      child: Image.asset(
                        'assets/images/tutorial_steak.png',
                        fit: BoxFit.contain,
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Input Section (Steps 1-3)
                  if (_currentStep >= 1 && _currentStep <= 3)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Food Name Input
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(
                              _highlightFoodName ? 8 : 0,
                            ),
                            decoration: BoxDecoration(
                              color: _highlightFoodName
                                  ? Colors.yellow.withOpacity(0.3)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: _highlightFoodName
                                  ? Border.all(
                                      color: Colors.orange,
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Food name',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _foodNameController,
                                  enabled: _currentStep >= 1,
                                  decoration: InputDecoration(
                                    hintText: 'e.g., Beyond Meat and Fries',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Quantity and Unit
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(
                              _highlightQuantity ? 8 : 0,
                            ),
                            decoration: BoxDecoration(
                              color: _highlightQuantity
                                  ? Colors.yellow.withOpacity(0.3)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: _highlightQuantity
                                  ? Border.all(
                                      color: Colors.orange,
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Quantity',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: TextField(
                                        controller: _quantityController,
                                        enabled: _currentStep >= 2,
                                        keyboardType: const TextInputType
                                            .numberWithOptions(
                                          decimal: true,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: '1',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      flex: 3,
                                      child: DropdownButtonFormField<String>(
                                        value: _selectedUnit,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                        ),
                                        items: [
                                          'serving',
                                          'plate',
                                          'bowl',
                                          'piece'
                                        ].map((unit) {
                                          return DropdownMenuItem(
                                            value: unit,
                                            child: Text(unit),
                                          );
                                        }).toList(),
                                        onChanged: _currentStep >= 2
                                            ? (value) {
                                                if (value != null) {
                                                  setState(() {
                                                    _selectedUnit = value;
                                                  });
                                                }
                                              }
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Mock Analysis Results (Steps 4-5)
                  if (_showAnalysisResult) _buildMockAnalysisResults(),

                  const SizedBox(height: 24),

                  // Tutorial Step Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${currentTutorialStep.stepNumber}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  currentTutorialStep.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            currentTutorialStep.description,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                          if (currentTutorialStep.highlightText != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.yellow.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.touch_app,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      currentTutorialStep.highlightText!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('PREVIOUS'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentStep == _steps.length - 1
                          ? 'START TRACKING'
                          : 'NEXT',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockAnalysisResults() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(_highlightIngredients ? 16 : 12),
        decoration: BoxDecoration(
          color: _highlightIngredients
              ? Colors.yellow.withOpacity(0.2)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _highlightIngredients
                ? Colors.orange
                : Colors.grey.shade300,
            width: _highlightIngredients ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analysis Results',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildIngredientCard(
              name: 'Beyond Meat Steak',
              amount: '150g',
              calories: 280,
              protein: 20,
              carbs: 5,
              fat: 18,
            ),
            const SizedBox(height: 12),
            _buildIngredientCard(
              name: 'French Fries',
              amount: '100g',
              calories: 312,
              protein: 3.4,
              carbs: 41,
              fat: 15,
            ),
            const SizedBox(height: 12),
            _buildIngredientCard(
              name: 'Ketchup',
              amount: '20ml',
              calories: 22,
              protein: 0.3,
              carbs: 5.3,
              fat: 0.1,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '614 kcal | P: 23.7g | C: 51.3g | F: 33.1g',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientCard({
    required String name,
    required String amount,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                amount,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${calories.toStringAsFixed(0)} kcal'),
              Text('P: ${protein.toStringAsFixed(1)}g'),
              Text('C: ${carbs.toStringAsFixed(1)}g'),
              Text('F: ${fat.toStringAsFixed(1)}g'),
            ],
          ),
        ],
      ),
    );
  }
}
```

---

### STEP 5: Integrate Tutorial into Onboarding Flow

**File:** `lib/features/onboarding/presentation/onboarding_screen.dart`

**Find the "Get Started" or "Finish" button at the end of onboarding.**

**Replace the navigation with:**

```dart
import 'package:miro/features/onboarding/presentation/tutorial_food_analysis_screen.dart';

// In the button's onPressed:
onPressed: () async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('onboarding_completed', true);
  
  if (mounted) {
    // Show food analysis tutorial
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const TutorialFoodAnalysisScreen(),
      ),
    );
  }
},
```

---

### STEP 6: Add Skip Option in Profile (Optional)

**File:** `lib/features/profile/presentation/profile_screen.dart`

**Add an option to view the tutorial again:**

```dart
ListTile(
  leading: const Icon(Icons.school),
  title: const Text('Food Analysis Tutorial'),
  subtitle: const Text('Learn how to use food analysis features'),
  trailing: const Icon(Icons.chevron_right),
  onTap: () {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TutorialFoodAnalysisScreen(),
      ),
    );
  },
),
```

---

## Testing Checklist

- [ ] Sample image displays correctly in tutorial
- [ ] Progress bar shows current step (1/6, 2/6, etc.)
- [ ] Step 1: Introduction displays with image
- [ ] Step 2: Food name field is highlighted, editable
- [ ] Step 3: Quantity and unit fields are highlighted, editable
- [ ] Step 4: Mock analysis results display correctly
- [ ] Step 5: Ingredients section is highlighted
- [ ] Step 6: Completion message displays
- [ ] "NEXT" button advances to next step
- [ ] "PREVIOUS" button goes to previous step
- [ ] "SKIP" button navigates to home screen
- [ ] "START TRACKING" button navigates to home (final step)
- [ ] Tutorial can be accessed from Profile screen
- [ ] No crashes or layout issues on small screens
- [ ] Text is readable and not cut off

---

## Troubleshooting

### Issue: Image not found
**Solution:** Ensure `tutorial_steak.png` is in `assets/images/` and listed in `pubspec.yaml`. Run `flutter pub get`.

### Issue: Highlighting animation doesn't work
**Solution:** Check `AnimatedContainer` duration and border properties.

### Issue: Navigation to home fails
**Solution:** Ensure route '/home' is defined, or use `Navigator.pushReplacement()` with direct widget.

### Issue: Mock data doesn't look realistic
**Solution:** Adjust nutrition values to match typical steak and fries meal.

---

## Completion Criteria

✅ Task is complete when:
- Tutorial displays after onboarding
- All 6 steps work correctly
- Image displays properly
- Input fields are interactive
- Mock analysis results display
- Navigation buttons work
- Skip functionality works
- Can be re-accessed from Profile
- No build errors or crashes
- Tested on multiple screen sizes

---

## Estimated Time

- 1 hour: Create tutorial step model and screen structure
- 1 hour: Build step 1-3 (input screens)
- 1 hour: Build step 4-5 (results screen)
- 30 min: Integration with onboarding
- 30 min: Polish UI and animations
- 1 hour: Testing

**Total: 4-6 hours**
