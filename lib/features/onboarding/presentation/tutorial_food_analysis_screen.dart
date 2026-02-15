import 'package:flutter/material.dart';
import 'package:miro_hybrid/core/theme/app_colors.dart';
import 'package:miro_hybrid/features/onboarding/models/tutorial_step.dart';
import 'package:miro_hybrid/features/home/presentation/home_screen.dart';

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
  bool _showBeforeAfterComparison = false;
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
      title: 'Step 1: Why Food Name Matters',
      description:
          '⚠️ See the difference below:\n\n'
          '❌ Using "food" → AI gives GENERIC results (any food)\n'
          '✅ Using "Beyond Meat and Fries" → AI gives SPECIFIC results\n\n'
          'Generic names lead to inaccurate calorie estimates!\n\n'
          'Try changing the name above to see how it affects AI analysis.',
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
  void initState() {
    super.initState();
    _updateHighlights();
  }

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
        
        // Show before/after comparison at step 2
        if (_currentStep == 1) {
          _showBeforeAfterComparison = true;
        }
        
        // Show mock analysis results at step 4
        if (_currentStep == 3) {
          _showAnalysisResult = true;
          _showBeforeAfterComparison = false;
        }
      });
    } else {
      // Tutorial complete, navigate to home
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _updateHighlights();
        
        // Show/hide comparison based on step
        if (_currentStep == 1) {
          _showBeforeAfterComparison = true;
        } else {
          _showBeforeAfterComparison = false;
        }
        
        // Hide analysis results if going back from step 4
        if (_currentStep < 3) {
          _showAnalysisResult = false;
        }
      });
    }
  }

  void _skipTutorial() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
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
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.image_not_supported, size: 64),
                          );
                        },
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
                            padding: EdgeInsets.all(
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
                            padding: EdgeInsets.all(
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
                                        initialValue: _selectedUnit,
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

                  // Before/After Comparison (Step 2)
                  if (_showBeforeAfterComparison) _buildBeforeAfterComparison(),

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

  Widget _buildBeforeAfterComparison() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border.all(color: Colors.orange.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.compare_arrows, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'See the difference:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.orange.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Comparison Cards
          Row(
            children: [
              // Generic "food"
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.close, color: Colors.red.shade700, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Using "food"',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildComparisonItem('1 serving'),
                      const Divider(height: 20),
                      Text(
                        '~450 kcal',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Generic estimate',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '⚠️ Could be\n300-800 kcal!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.red.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Specific "Beyond Meat and Fries"
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    border: Border.all(color: Colors.green.shade300, width: 2),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Using specific name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildComparisonItem('1 serving'),
                      const Divider(height: 20),
                      Text(
                        '614 kcal',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Precise breakdown',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '✅ Accurate\ningredients!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom explanation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              border: Border.all(color: Colors.blue.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Specific names = More accurate calorie tracking!',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade900,
                      fontWeight: FontWeight.w500,
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

  Widget _buildComparisonItem(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12),
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
