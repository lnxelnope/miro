import 'package:flutter/material.dart';
import '../../../core/theme/app_icons.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/profile_provider.dart';

// kcal ต่อ 1 กรัม ของแต่ละ macro
const double _kCalPerGramProtein = 4.0;
const double _kCalPerGramCarbs = 4.0;
const double _kCalPerGramFat = 9.0;

class HealthGoalsScreen extends ConsumerStatefulWidget {
  const HealthGoalsScreen({super.key});

  @override
  ConsumerState<HealthGoalsScreen> createState() => _HealthGoalsScreenState();
}

class _HealthGoalsScreenState extends ConsumerState<HealthGoalsScreen> {
  late TextEditingController _calorieController;
  late TextEditingController _proteinController;
  late TextEditingController _carbController;
  late TextEditingController _fatController;

  // Meal budget controllers
  late TextEditingController _breakfastController;
  late TextEditingController _lunchController;
  late TextEditingController _dinnerController;
  late TextEditingController _snackController;

  // Suggestion threshold controller
  late TextEditingController _thresholdController;

  // Lock states (can lock up to 2 macros)
  bool _proteinLocked = false;
  bool _carbLocked = false;
  bool _fatLocked = false;

  // Meal lock states (can lock up to 3 meals)
  bool _breakfastLocked = false;
  bool _lunchLocked = false;
  bool _dinnerLocked = false;
  bool _snackLocked = false;

  bool _isLoading = false;
  bool _initialized = false;
  bool _mealSuggestionsEnabled = false;

  @override
  void initState() {
    super.initState();
    _calorieController = TextEditingController();
    _proteinController = TextEditingController();
    _carbController = TextEditingController();
    _fatController = TextEditingController();
    _breakfastController = TextEditingController();
    _lunchController = TextEditingController();
    _dinnerController = TextEditingController();
    _snackController = TextEditingController();
    _thresholdController = TextEditingController();

    // Listen for changes
    _calorieController.addListener(_onCalorieChanged);
    _proteinController.addListener(() => _onMacroChanged('protein'));
    _carbController.addListener(() => _onMacroChanged('carbs'));
    _fatController.addListener(() => _onMacroChanged('fat'));

    // Meal budget listeners
    _breakfastController.addListener(() => _onMealBudgetChanged('breakfast'));
    _lunchController.addListener(() => _onMealBudgetChanged('lunch'));
    _dinnerController.addListener(() => _onMealBudgetChanged('dinner'));
    _snackController.addListener(() => _onMealBudgetChanged('snack'));
  }

  @override
  void dispose() {
    _calorieController.dispose();
    _proteinController.dispose();
    _carbController.dispose();
    _fatController.dispose();
    _breakfastController.dispose();
    _lunchController.dispose();
    _dinnerController.dispose();
    _snackController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  /// Safely convert double to int, returning fallback for NaN/Infinity/zero
  int _safeInt(double value, [int fallback = 0]) {
    if (value.isNaN || value.isInfinite) return fallback;
    return value.toInt();
  }

  void _initFromProfile(dynamic profile) {
    if (_initialized) return;
    _initialized = true;

    final cal = profile.calorieGoal as double;
    _calorieController.text = _safeInt(cal, 2000).toString();

    // Load gram values from profile
    final pGram = profile.proteinGoal as double;
    final cGram = profile.carbGoal as double;
    final fGram = profile.fatGoal as double;

    _proteinController.text = _safeInt(pGram, 120).toString();
    _carbController.text = _safeInt(cGram, 250).toString();
    _fatController.text = _safeInt(fGram, 65).toString();

    // Load meal budgets (new fields — guard against NaN from Isar migration)
    final calInt = _safeInt(cal, 2000);
    _breakfastController.text = _safeMealBudget(profile.breakfastBudget, (calInt * 0.28).round()).toString();
    _lunchController.text = _safeMealBudget(profile.lunchBudget, (calInt * 0.35).round()).toString();
    _dinnerController.text = _safeMealBudget(profile.dinnerBudget, (calInt * 0.30).round()).toString();
    _snackController.text = _safeMealBudget(profile.snackBudget, (calInt * 0.07).round()).toString();

    _thresholdController.text = _safeMealBudget(profile.suggestionThreshold, 100).toString();
    _mealSuggestionsEnabled = profile.mealSuggestionsEnabled;

    if (_lockedCount == 2) {
      _autoCalculateUnlocked();
    }
  }

  /// Safely read a meal budget, using fallback for NaN/Infinity/0
  int _safeMealBudget(double value, int fallback) {
    if (value.isNaN || value.isInfinite || value <= 0) return fallback;
    return value.toInt();
  }

  // ===== Computed values =====
  double get _calories => double.tryParse(_calorieController.text) ?? 0;
  double get _proteinGrams => double.tryParse(_proteinController.text) ?? 0;
  double get _carbGrams => double.tryParse(_carbController.text) ?? 0;
  double get _fatGrams => double.tryParse(_fatController.text) ?? 0;

  // ===== Lock helpers =====
  int get _lockedCount =>
      (_proteinLocked ? 1 : 0) + (_carbLocked ? 1 : 0) + (_fatLocked ? 1 : 0);

  bool _isLocked(String macro) {
    switch (macro) {
      case 'protein':
        return _proteinLocked;
      case 'carbs':
        return _carbLocked;
      case 'fat':
        return _fatLocked;
      default:
        return false;
    }
  }

  void _toggleLock(String macro) {
    // If already locked, can unlock
    if (_isLocked(macro)) {
      setState(() {
        switch (macro) {
          case 'protein':
            _proteinLocked = false;
            break;
          case 'carbs':
            _carbLocked = false;
            break;
          case 'fat':
            _fatLocked = false;
            break;
        }
      });
      // หลังปลดล็อค ไม่ต้องคำนวณ (ให้ user แก้เอง)
      return;
    }

    // Can only lock if less than 2 are locked
    if (_lockedCount >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10n.of(context)!.canOnlyLockTwoMacros),
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    setState(() {
      switch (macro) {
        case 'protein':
          _proteinLocked = true;
          break;
        case 'carbs':
          _carbLocked = true;
          break;
        case 'fat':
          _fatLocked = true;
          break;
      }
    });

    // ────── หลังล็อค macro ที่ 2 ให้คำนวณ macro ที่ unlocked ทันที ──────
    _autoCalculateUnlocked();
  }

  /// When calories change, recalculate unlocked macro and meal budget
  void _onCalorieChanged() {
    if (_lockedCount == 2) {
      _autoCalculateUnlocked();
    }
    if (_mealLockedCount == 3) {
      _autoCalculateUnlockedMeal();
    }
  }

  /// When a macro value changes, recalculate if needed
  void _onMacroChanged(String macro) {
    // ────── ถ้า macro ที่ล็อคไว้ถูกเปลี่ยนค่า → คำนวณ unlocked macro ใหม่ ──────
    if (_isLocked(macro) && _lockedCount == 2) {
      _autoCalculateUnlocked();
      return;
    }

    // If this is the unlocked macro and 2 are locked, don't trigger recalculation
    // (let user type freely)
    if (_lockedCount == 2) return;

    setState(() {});
  }

  /// Auto-calculate the unlocked macro based on calories and locked macros
  void _autoCalculateUnlocked() {
    if (_lockedCount != 2) return;

    final targetCalories = _calories;
    if (targetCalories <= 0) return;

    // Find which macro is unlocked
    String? unlockedMacro;
    if (!_proteinLocked) {
      unlockedMacro = 'protein';
    } else if (!_carbLocked) {
      unlockedMacro = 'carbs';
    } else if (!_fatLocked) {
      unlockedMacro = 'fat';
    }

    if (unlockedMacro == null) return;

    // Calculate remaining calories
    final lockedCalories =
        (_proteinLocked ? _proteinGrams * _kCalPerGramProtein : 0) +
            (_carbLocked ? _carbGrams * _kCalPerGramCarbs : 0) +
            (_fatLocked ? _fatGrams * _kCalPerGramFat : 0);

    final remainingCalories =
        (targetCalories - lockedCalories).clamp(0, targetCalories);

    // Calculate grams for unlocked macro
    double unlockedGrams;
    switch (unlockedMacro) {
      case 'protein':
        unlockedGrams = remainingCalories / _kCalPerGramProtein;
        _proteinController.text = unlockedGrams.round().toString();
        break;
      case 'carbs':
        unlockedGrams = remainingCalories / _kCalPerGramCarbs;
        _carbController.text = unlockedGrams.round().toString();
        break;
      case 'fat':
        unlockedGrams = remainingCalories / _kCalPerGramFat;
        _fatController.text = unlockedGrams.round().toString();
        break;
    }

    setState(() {});
  }

  // ===== Meal Budget Lock System =====
  int get _mealLockedCount =>
      (_breakfastLocked ? 1 : 0) +
      (_lunchLocked ? 1 : 0) +
      (_dinnerLocked ? 1 : 0) +
      (_snackLocked ? 1 : 0);

  bool _isMealLocked(String meal) {
    switch (meal) {
      case 'breakfast':
        return _breakfastLocked;
      case 'lunch':
        return _lunchLocked;
      case 'dinner':
        return _dinnerLocked;
      case 'snack':
        return _snackLocked;
      default:
        return false;
    }
  }

  TextEditingController _mealController(String meal) {
    switch (meal) {
      case 'breakfast':
        return _breakfastController;
      case 'lunch':
        return _lunchController;
      case 'dinner':
        return _dinnerController;
      case 'snack':
        return _snackController;
      default:
        return _breakfastController;
    }
  }

  void _toggleMealLock(String meal) {
    if (_isMealLocked(meal)) {
      setState(() {
        switch (meal) {
          case 'breakfast':
            _breakfastLocked = false;
          case 'lunch':
            _lunchLocked = false;
          case 'dinner':
            _dinnerLocked = false;
          case 'snack':
            _snackLocked = false;
        }
      });
      return;
    }

    if (_mealLockedCount >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10n.of(context)!.canOnlyLockThreeMeals),
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    setState(() {
      switch (meal) {
        case 'breakfast':
          _breakfastLocked = true;
        case 'lunch':
          _lunchLocked = true;
        case 'dinner':
          _dinnerLocked = true;
        case 'snack':
          _snackLocked = true;
      }
    });

    _autoCalculateUnlockedMeal();
  }

  void _onMealBudgetChanged(String meal) {
    if (_isMealLocked(meal) && _mealLockedCount == 3) {
      _autoCalculateUnlockedMeal();
      return;
    }
    if (_mealLockedCount == 3) return;
    setState(() {});
  }

  void _autoCalculateUnlockedMeal() {
    if (_mealLockedCount != 3) return;

    final totalCalories = _calories;
    if (totalCalories <= 0) return;

    String? unlockedMeal;
    if (!_breakfastLocked) {
      unlockedMeal = 'breakfast';
    } else if (!_lunchLocked) {
      unlockedMeal = 'lunch';
    } else if (!_dinnerLocked) {
      unlockedMeal = 'dinner';
    } else if (!_snackLocked) {
      unlockedMeal = 'snack';
    }

    if (unlockedMeal == null) return;

    final lockedSum =
        (_breakfastLocked ? (double.tryParse(_breakfastController.text) ?? 0) : 0) +
        (_lunchLocked ? (double.tryParse(_lunchController.text) ?? 0) : 0) +
        (_dinnerLocked ? (double.tryParse(_dinnerController.text) ?? 0) : 0) +
        (_snackLocked ? (double.tryParse(_snackController.text) ?? 0) : 0);

    final remaining = (totalCalories - lockedSum).clamp(0, totalCalories);

    _mealController(unlockedMeal).text = remaining.round().toString();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.of(context)!.healthGoalsTitle),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('${L10n.of(context)!.error}: $e')),
        data: (profile) {
          _initFromProfile(profile);

          return SingleChildScrollView(
            padding: AppSpacing.paddingLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== Info card =====
                Container(
                  padding: AppSpacing.paddingLg,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.2),
                    borderRadius: AppRadius.md,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.primary),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          L10n.of(context)!.healthGoalsInfo,
                          style: const TextStyle(color: AppColors.primary, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.xxl),

                // ===== Calorie Goal =====
                _buildCalorieSection(),
                SizedBox(height: AppSpacing.xxl),

                // ===== Macro Editors =====
                _buildMacroEditor(
                  label: L10n.of(context)!.proteinLabel,
                  icon: '🥩',
                  macroKey: 'protein',
                  controller: _proteinController,
                  color: AppColors.protein,
                  kcalPerGram: _kCalPerGramProtein,
                ),
                SizedBox(height: AppSpacing.md),
                _buildMacroEditor(
                  label: L10n.of(context)!.carbsLabel,
                  icon: '🍚',
                  macroKey: 'carbs',
                  controller: _carbController,
                  color: AppColors.carbs,
                  kcalPerGram: _kCalPerGramCarbs,
                ),
                SizedBox(height: AppSpacing.md),
                _buildMacroEditor(
                  label: L10n.of(context)!.fatLabel,
                  icon: '🧈',
                  macroKey: 'fat',
                  controller: _fatController,
                  color: AppColors.fat,
                  kcalPerGram: _kCalPerGramFat,
                ),

                SizedBox(height: AppSpacing.xxxl),

                // ===== Meal Calorie Budget =====
                _buildMealBudgetSection(),
                SizedBox(height: AppSpacing.xxl),

                // ===== Suggestion Threshold =====
                _buildSuggestionThresholdSection(),
                SizedBox(height: AppSpacing.xxxl),

                // ===== Save Button =====
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveGoals,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.md,
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(L10n.of(context)!.save,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                SizedBox(height: AppSpacing.lg),
              ],
            ),
          );
        },
      ),
    );
  }

  // ========================================================
  // Calorie Section
  // ========================================================
  Widget _buildCalorieSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppIcons.iconWithLabel(
          AppIcons.calories,
          L10n.of(context)!.dailyCalorieGoal,
          iconColor: AppIcons.caloriesColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _calorieController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            suffixText: 'kcal',
            suffixStyle: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            border: OutlineInputBorder(borderRadius: AppRadius.md),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.md,
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: AppSpacing.verticalLg,
          ),
        ),
      ],
    );
  }

  // ========================================================
  // Macro Editor Row — TextField for grams + lock button
  // ========================================================
  Widget _buildMacroEditor({
    required String label,
    required String icon,
    required String macroKey,
    required TextEditingController controller,
    required Color color,
    required double kcalPerGram,
  }) {
    final grams = double.tryParse(controller.text) ?? 0;
    final kcal = grams * kcalPerGram;
    final isLocked = _isLocked(macroKey);

    // แสดง "auto" badge ถ้า macro นี้ไม่ได้ล็อคและมี 2 macros ถูกล็อคแล้ว
    final isAutoCalculated = !isLocked && _lockedCount == 2;

    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppRadius.md,
        border: Border.all(
          color: isLocked ? color.withValues(alpha: 0.6) : color.withValues(alpha: 0.3),
          width: isLocked ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Icon + label
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: color,
                        fontSize: 15,
                      ),
                    ),
                    if (isAutoCalculated) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppSpacing.xs), // Keep 4px for small badge
                        ),
                        child: Text(
                          L10n.of(context)!.autoBadge,
                          style: TextStyle(
                            fontSize: 10,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  L10n.of(context)!.kcalPerGram(kcalPerGram.toInt(), kcal.round()),
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          // Lock button
          InkWell(
            onTap: () => _toggleLock(macroKey),
            borderRadius: AppRadius.sm,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                isLocked ? Icons.lock : Icons.lock_open,
                size: 20,
                color: isLocked ? color : AppColors.textTertiary,
              ),
            ),
          ),

          SizedBox(width: AppSpacing.sm),

          // Gram input
          SizedBox(
            width: 80,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              enabled: !isAutoCalculated,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isAutoCalculated ? AppColors.textTertiary : color,
              ),
              decoration: InputDecoration(
                suffixText: 'g',
                suffixStyle: TextStyle(
                  fontSize: 12,
                  color: isAutoCalculated ? AppColors.textTertiary : AppColors.textSecondary,
                ),
                border:
                    OutlineInputBorder(borderRadius: AppRadius.sm),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.sm,
                  borderSide: BorderSide(color: color, width: 2),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.sm),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================
  // Meal Calorie Budget Section
  // ========================================================
  Widget _buildMealBudgetSection() {
    final totalBudget =
        (double.tryParse(_breakfastController.text) ?? 0) +
        (double.tryParse(_lunchController.text) ?? 0) +
        (double.tryParse(_dinnerController.text) ?? 0) +
        (double.tryParse(_snackController.text) ?? 0);
    final calGoal = _calories;
    final diff = calGoal - totalBudget;
    final isBalanced = diff.abs() < 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppIcons.iconWithLabel(
          AppIcons.calories,
          L10n.of(context)!.mealCalorieBudget,
          iconColor: AppIcons.caloriesColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: AppSpacing.sm), // 6 -> 8 closest
        Container(
          padding: AppSpacing.paddingMd,
          decoration: BoxDecoration(
            color: isBalanced
                ? AppColors.success.withValues(alpha: 0.08)
                : AppColors.warning.withValues(alpha: 0.08),
            borderRadius: AppRadius.md,
          ),
          child: Row(
            children: [
              Icon(
                isBalanced ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                size: 18,
                color: isBalanced ? AppColors.success : AppColors.warning,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  isBalanced
                      ? L10n.of(context)!.mealBudgetBalanced(totalBudget.toInt(), calGoal.toInt())
                      : L10n.of(context)!.mealBudgetRemaining(totalBudget.toInt(), calGoal.toInt(), diff.toInt()),
                  style: TextStyle(
                    fontSize: 12,
                    color: isBalanced ? AppColors.success : AppColors.warning,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          L10n.of(context)!.lockMealsHint,
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        SizedBox(height: AppSpacing.md),
        _buildMealBudgetRow(
          label: L10n.of(context)!.breakfastLabel,
          mealKey: 'breakfast',
          controller: _breakfastController,
          color: AppColors.warning, // orange-400
          icon: Icons.wb_sunny_rounded,
        ),
                SizedBox(height: AppSpacing.sm),
        _buildMealBudgetRow(
          label: L10n.of(context)!.lunchLabel,
          mealKey: 'lunch',
          controller: _lunchController,
          color: AppColors.warning, // amber-400
          icon: Icons.wb_cloudy_rounded,
        ),
                SizedBox(height: AppSpacing.sm),
        _buildMealBudgetRow(
          label: L10n.of(context)!.dinnerLabel,
          mealKey: 'dinner',
          controller: _dinnerController,
          color: AppColors.ai, // indigo-400
          icon: Icons.nightlight_round,
        ),
                SizedBox(height: AppSpacing.sm),
        _buildMealBudgetRow(
          label: L10n.of(context)!.snackLabel,
          mealKey: 'snack',
          controller: _snackController,
          color: AppColors.success, // emerald-400
          icon: Icons.cookie_rounded,
        ),
      ],
    );
  }

  Widget _buildMealBudgetRow({
    required String label,
    required String mealKey,
    required TextEditingController controller,
    required Color color,
    required IconData icon,
  }) {
    final isLocked = _isMealLocked(mealKey);
    final isAutoCalc = !isLocked && _mealLockedCount == 3;
    final kcal = double.tryParse(controller.text) ?? 0;
    final pct = _calories > 0 ? (kcal / _calories * 100) : 0;

    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: AppRadius.md,
        border: Border.all(
          color: isLocked ? color.withValues(alpha: 0.5) : color.withValues(alpha: 0.2),
          width: isLocked ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color.withValues(alpha: 0.8), size: 22),
          SizedBox(width: AppSpacing.md), // 10 -> 12 closest
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: color,
                        fontSize: 14,
                      ),
                    ),
                    if (isAutoCalc) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(AppSpacing.xs), // Keep 4px for small badge
                        ),
                        child: Text(
                          L10n.of(context)!.autoBadge,
                          style: TextStyle(
                            fontSize: 10,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  L10n.of(context)!.percentOfDailyGoal(pct.toStringAsFixed(0)),
                  style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => _toggleMealLock(mealKey),
            borderRadius: AppRadius.sm,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                isLocked ? Icons.lock : Icons.lock_open,
                size: 20,
                color: isLocked ? color : AppColors.textTertiary,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 80,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              enabled: !isAutoCalc,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isAutoCalc ? AppColors.textTertiary : color,
              ),
              decoration: InputDecoration(
                suffixText: 'kcal',
                suffixStyle: TextStyle(
                  fontSize: 9,
                    color: isAutoCalc ? AppColors.textTertiary : AppColors.textSecondary,
                ),
                border: OutlineInputBorder(borderRadius: AppRadius.sm),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.sm,
                  borderSide: BorderSide(color: color, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.xs),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================
  // Suggestion Threshold Section
  // ========================================================
  Widget _buildSuggestionThresholdSection() {
    final threshold = double.tryParse(_thresholdController.text) ?? 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppIcons.iconWithLabel(
          AppIcons.calories,
          L10n.of(context)!.smartSuggestionRange,
          iconColor: AppColors.primary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
                SizedBox(height: AppSpacing.sm),
        // Explanation card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.06),
                AppColors.health.withValues(alpha: 0.04),
              ],
            ),
            borderRadius: AppRadius.md,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome_rounded,
                      size: 18, color: AppColors.primary.withValues(alpha: 0.7)),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      L10n.of(context)!.smartSuggestionHow,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                L10n.of(context)!.smartSuggestionDesc(
                  threshold.toInt(),
                  (700 - threshold).toInt(),
                  (700 + threshold).toInt(),
                ),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.md),
        // Threshold input
        Container(
          padding: AppSpacing.paddingMd,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: AppRadius.md,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.restaurant_menu_rounded,
                      color: AppColors.primary.withValues(alpha: 0.7), size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      L10n.of(context)!.mealSuggestionsToggle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Switch(
                    value: _mealSuggestionsEnabled,
                    onChanged: (v) => setState(() => _mealSuggestionsEnabled = v),
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
              if (_mealSuggestionsEnabled) ...[
                const Divider(height: 16),
                Row(
                  children: [
                    Icon(Icons.tune_rounded,
                        color: AppColors.primary.withValues(alpha: 0.7), size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            L10n.of(context)!.suggestionThreshold,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            L10n.of(context)!.suggestionThresholdDesc(threshold.toInt()),
                            style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: _thresholdController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        decoration: InputDecoration(
                          suffixText: 'kcal',
                          suffixStyle: TextStyle(
                            fontSize: 9,
                            color: AppColors.textSecondary,
                          ),
                          border: OutlineInputBorder(
                              borderRadius: AppRadius.sm),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: AppRadius.sm,
                            borderSide:
                                const BorderSide(color: AppColors.primary, width: 2),
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.xs),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ========================================================
  // Save Goals
  // ========================================================
  Future<void> _saveGoals() async {
    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(profileNotifierProvider.notifier);

      await notifier.updateHealthGoals(
        calorieGoal: _calories,
        proteinGoal: _proteinGrams.roundToDouble(),
        carbGoal: _carbGrams.roundToDouble(),
        fatGoal: _fatGrams.roundToDouble(),
        breakfastBudget: double.tryParse(_breakfastController.text),
        lunchBudget: double.tryParse(_lunchController.text),
        dinnerBudget: double.tryParse(_dinnerController.text),
        snackBudget: double.tryParse(_snackController.text),
        suggestionThreshold: double.tryParse(_thresholdController.text),
        mealSuggestionsEnabled: _mealSuggestionsEnabled,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(L10n.of(context)!.goalsSavedSuccess),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), duration: const Duration(seconds: 2)),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
