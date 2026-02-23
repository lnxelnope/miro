import 'package:flutter/material.dart';
import 'package:miro_hybrid/core/theme/app_colors.dart';
import 'package:miro_hybrid/core/theme/app_tokens.dart';
import 'package:miro_hybrid/core/theme/app_icons.dart';
import 'package:miro_hybrid/core/constants/enums.dart';
import 'package:miro_hybrid/core/services/permission_service.dart';
import 'package:miro_hybrid/core/utils/logger.dart';
import 'package:miro_hybrid/features/onboarding/models/tutorial_step.dart';
import 'package:miro_hybrid/features/home/presentation/home_screen.dart';
import 'package:miro_hybrid/features/scanner/widgets/retro_scan_dialog.dart';

class TutorialFoodAnalysisScreen extends StatefulWidget {
  const TutorialFoodAnalysisScreen({super.key});

  @override
  State<TutorialFoodAnalysisScreen> createState() =>
      _TutorialFoodAnalysisScreenState();
}

class _TutorialFoodAnalysisScreenState extends State<TutorialFoodAnalysisScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0;

  // Step 1 state
  final TextEditingController _foodNameController =
      TextEditingController(text: 'Steak and Fries');
  final TextEditingController _quantityController =
      TextEditingController(text: '1');
  String _selectedUnit = 'plate';
  FoodSearchMode _searchMode = FoodSearchMode.normal;

  // Step 2 state
  bool _highlightWrongIngredient = false;
  bool _hasFixedIngredient = false;
  String _wrongIngredientName = 'Chicken Breast';

  // Animation controller for pulse effect
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<TutorialStep> _steps = const [
    TutorialStep(
      stepNumber: 1,
      title: 'Analyze Your First Food',
      description: 'Let\'s try analyzing a sample meal!\n\n'
          'You can change the food name, quantity, or toggle between Food/Product mode.',
      type: TutorialStepType.analyzeDemo,
    ),
    TutorialStep(
      stepNumber: 2,
      title: 'Edit & Fix Ingredients',
      description: 'AI sometimes guesses wrong.\n\n'
          'You can edit the name manually or use Re-search for better results.',
      type: TutorialStepType.editAndResearch,
    ),
    TutorialStep(
      stepNumber: 3,
      title: 'You\'re a Pro!',
      description: 'Quick recap:\n\n'
          '• 📸 Snap or 💬 Type to analyze\n'
          '• 🍳 Food or 📦 Product mode\n'
          '• ✏️ Edit or 🔍 Re-search to fix',
      type: TutorialStepType.completion,
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Setup pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _foodNameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;

        // Step 2: Show mock results + highlight wrong ingredient
        if (_currentStep == 1) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() => _highlightWrongIngredient = true);
            }
          });
        }
      });
    } else {
      _finishAndRetroScan();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;

        // Reset state when going back from step 2
        if (_currentStep == 0) {
          _highlightWrongIngredient = false;
          _hasFixedIngredient = false;
        }
      });
    }
  }

  void _skipTutorial() {
    _finishAndRetroScan();
  }

  Future<void> _finishAndRetroScan() async {
    try {
      final permissionService = PermissionService();
      final hasGallery = await permissionService.hasGalleryPermission();

      if (!hasGallery) {
        final results = await permissionService.requestInitialPermissions();
        AppLogger.info('Permission results from tutorial: $results');
      }

      await permissionService.markFirstLaunchComplete();

      if (!mounted) return;

      await RetroScanDialog.show(context);
    } catch (e) {
      AppLogger.warn('RetroScan from tutorial failed: $e');
    }

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  void _onAnalyzeDemo() {
    // Show a quick animation or feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('✨ This is a demo! In real use, AI will analyze your food.'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onEditIngredient() {
    // Show edit feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('💡 In real use, you can edit ingredient details here.'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onReSearchIngredient() {
    // Simulate re-search with loading
    setState(() {
      _highlightWrongIngredient = false;
    });

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Re-searching with AI...'),
              ],
            ),
          ),
        ),
      ),
    );

    // Simulate AI re-search delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        setState(() {
          _wrongIngredientName = 'Grilled Steak';
          _hasFixedIngredient = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Fixed! AI found the correct ingredient.'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Tutorial ${_currentStep + 1}/3',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _skipTutorial,
            child: const Text(
              'Skip →',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: ClipRRect(
              borderRadius: AppRadius.sm,
              child: LinearProgressIndicator(
                value: (_currentStep + 1) / _steps.length,
                backgroundColor: AppColors.divider,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 6,
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Step content
                  if (_currentStep == 0) _buildStep1AnalyzeDemo(),
                  if (_currentStep == 1) _buildStep2EditAndResearch(),
                  if (_currentStep == 2) _buildStep3Completion(),
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
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.md,
                        ),
                        side: const BorderSide(color: AppColors.divider),
                      ),
                      child: const Text(
                        'Previous',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.md,
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      _currentStep == _steps.length - 1
                          ? '🚀 Start Tracking!'
                          : 'Next →',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
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

  // ============ Step 1: Analyze Demo ============

  Widget _buildStep1AnalyzeDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sample Image
        Container(
          height: 220,
          decoration: BoxDecoration(
            color: AppColors.divider,
            borderRadius: AppRadius.lg,
          ),
          child: ClipRRect(
            borderRadius: AppRadius.lg,
            child: Image.asset(
              'assets/images/tutorial_steak.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.restaurant_menu,
                          size: 64, color: AppColors.textSecondary),
                      SizedBox(height: 8),
                      Text(
                        'Sample: Steak and Fries',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Food Name Input
        const Text(
          'Food name:',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _foodNameController,
          decoration: InputDecoration(
            hintText: 'e.g., Steak and Fries',
            border: OutlineInputBorder(
              borderRadius: AppRadius.md,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Search Mode Toggle (NEW!)
        _buildSearchModeToggle(),

        const SizedBox(height: 20),

        // Quantity and Unit Row
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Qty:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _quantityController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      hintText: '1',
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.md,
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
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Unit:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedUnit,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.md,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    items: ['plate', 'serving', 'bowl', 'piece', 'gram']
                        .map((unit) {
                      return DropdownMenuItem(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedUnit = value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Tip Box
        _buildTipBox(
          _searchMode == FoodSearchMode.normal
              ? '💡 Tip: For packaged products like Lay\'s or Coca-Cola, select "Product" so AI uses official nutrition facts'
              : '💡 Tip: Product mode uses official nutrition facts from labels. Specify portion like "1 bag" or "100g"',
        ),

        const SizedBox(height: 20),

        // Analyze Button (Demo)
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _onAnalyzeDemo,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.md,
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, size: 20),
                SizedBox(width: 8),
                Text(
                  'Analyze (Demo)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Tutorial Info Card
        _buildTutorialInfoCard(_steps[0]),
      ],
    );
  }

  Widget _buildSearchModeToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type:',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildModePill(
              icon: Icons.restaurant_menu_rounded,
              iconColor: AppIcons.mealColor,
              label: 'Food',
              mode: FoodSearchMode.normal,
              isSelected: _searchMode == FoodSearchMode.normal,
            ),
            const SizedBox(width: 12),
            _buildModePill(
              icon: AppIcons.package,
              iconColor: AppIcons.packageColor,
              label: 'Product',
              mode: FoodSearchMode.product,
              isSelected: _searchMode == FoodSearchMode.product,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModePill({
    required IconData icon,
    required Color iconColor,
    required String label,
    required FoodSearchMode mode,
    required bool isSelected,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _searchMode = mode),
        borderRadius: AppRadius.xl,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
            borderRadius: AppRadius.xl,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: isSelected ? Colors.white : iconColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 4),
                const Icon(Icons.check, size: 16, color: Colors.white),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ============ Step 2: Edit & Re-search ============

  Widget _buildStep2EditAndResearch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'AI analyzed your meal:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        // Mock Analysis Results
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: AppRadius.lg,
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              // Correct ingredient
              _buildIngredientCard(
                name: 'Grilled Steak',
                amount: '150g',
                calories: 280,
                protein: 20,
                carbs: 5,
                fat: 18,
                isCorrect: true,
              ),

              const SizedBox(height: 12),

              // Wrong ingredient with highlight
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale:
                        _highlightWrongIngredient ? _pulseAnimation.value : 1.0,
                    child: _buildIngredientCard(
                      name: _wrongIngredientName,
                      amount: '100g',
                      calories: 165,
                      protein: 31,
                      carbs: 0,
                      fat: 3.6,
                      isCorrect: false,
                      showWarning:
                          _highlightWrongIngredient && !_hasFixedIngredient,
                      isFixed: _hasFixedIngredient,
                      onEdit: _onEditIngredient,
                      onReSearch: _onReSearchIngredient,
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Correct ingredient
              _buildIngredientCard(
                name: 'French Fries',
                amount: '100g',
                calories: 312,
                protein: 3.4,
                carbs: 41,
                fat: 15,
                isCorrect: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Tutorial Info Card
        _buildTutorialInfoCard(_steps[1]),
      ],
    );
  }

  Widget _buildIngredientCard({
    required String name,
    required String amount,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    required bool isCorrect,
    bool showWarning = false,
    bool isFixed = false,
    VoidCallback? onEdit,
    VoidCallback? onReSearch,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: showWarning
            ? AppColors.warning.withValues(alpha: 0.1)
            : isFixed
                ? AppColors.success.withValues(alpha: 0.1)
                : Colors.white,
        borderRadius: AppRadius.md,
        border: Border.all(
          color: showWarning
              ? AppColors.warning.withValues(alpha: 0.7)
              : isFixed
                  ? AppColors.success.withValues(alpha: 0.7)
                  : AppColors.divider,
          width: showWarning || isFixed ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (showWarning)
                const Icon(AppIcons.warning, size: 20, color: AppIcons.warningColor)
              else if (isFixed)
                const Icon(AppIcons.success, size: 20, color: AppIcons.successColor)
              else
                const Text('✅ ', style: TextStyle(fontSize: 18)),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              if (showWarning)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: AppRadius.sm,
                  ),
                  child: const Text(
                    'WRONG!',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.warning,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildMacroChip(
                  '${calories.toStringAsFixed(0)} kcal', AppColors.premium),
              const SizedBox(width: 8),
              _buildMacroChip('P:${protein.toStringAsFixed(1)}', AppColors.info),
              const SizedBox(width: 8),
              _buildMacroChip('C:${carbs.toStringAsFixed(1)}', AppColors.warning),
              const SizedBox(width: 8),
              _buildMacroChip('F:${fat.toStringAsFixed(1)}', AppColors.success),
            ],
          ),

          // Action buttons for wrong ingredient
          if (showWarning && onEdit != null && onReSearch != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.sm,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onReSearch,
                    icon: const Icon(Icons.search, size: 16),
                    label: const Text('Re-search'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.sm,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMacroChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.sm,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color.withValues(alpha: 0.9),
        ),
      ),
    );
  }

  // ============ Step 3: Completion ============

  Widget _buildStep3Completion() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Icon(AppIcons.milestone, size: 96, color: AppIcons.milestoneColor),
        const SizedBox(height: 24),
        const Text(
          'You\'re Ready!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 32),

        // Recap Pills
        _buildRecapPill(
          icon: AppIcons.camera,
          iconColor: AppIcons.cameraColor,
          title: 'Snap or Type',
          subtitle: 'to analyze any food',
        ),
        const SizedBox(height: 12),
        _buildRecapPill(
          icon: Icons.restaurant_menu_rounded,
          iconColor: AppIcons.mealColor,
          title: 'Food or Product',
          subtitle: 'choose mode for better accuracy',
        ),
        const SizedBox(height: 12),
        _buildRecapPill(
          icon: AppIcons.edit,
          iconColor: AppIcons.editColor,
          title: 'Edit or Re-search',
          subtitle: 'fix anything AI got wrong',
        ),

        const SizedBox(height: 40),

        // Tutorial Info Card
        _buildTutorialInfoCard(_steps[2]),
      ],
    );
  }

  Widget _buildRecapPill({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: AppRadius.lg,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 36, color: iconColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============ Shared Widgets ============

  Widget _buildTutorialInfoCard(TutorialStep step) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: AppRadius.lg,
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${step.stepNumber}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            step.description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipBox(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(AppIcons.tips, size: 20, color: AppIcons.tipsColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
