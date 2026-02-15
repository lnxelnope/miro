import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
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
  late TextEditingController _waterController;
  late TextEditingController _proteinController;
  late TextEditingController _carbController;
  late TextEditingController _fatController;

  // Lock states (can lock up to 2 macros)
  bool _proteinLocked = false;
  bool _carbLocked = false;
  bool _fatLocked = false;

  bool _isLoading = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _calorieController = TextEditingController();
    _waterController = TextEditingController();
    _proteinController = TextEditingController();
    _carbController = TextEditingController();
    _fatController = TextEditingController();
    
    // Listen for changes
    _calorieController.addListener(_onCalorieChanged);
    _proteinController.addListener(() => _onMacroChanged('protein'));
    _carbController.addListener(() => _onMacroChanged('carbs'));
    _fatController.addListener(() => _onMacroChanged('fat'));
  }

  @override
  void dispose() {
    _calorieController.dispose();
    _waterController.dispose();
    _proteinController.dispose();
    _carbController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  void _initFromProfile(dynamic profile) {
    if (_initialized) return;
    _initialized = true;

    final cal = profile.calorieGoal as double;
    _calorieController.text = cal.toInt().toString();
    _waterController.text = (profile.waterGoal as double).toInt().toString();

    // Load gram values from profile
    final pGram = profile.proteinGoal as double;
    final cGram = profile.carbGoal as double;
    final fGram = profile.fatGoal as double;

    _proteinController.text = pGram.toInt().toString();
    _carbController.text = cGram.toInt().toString();
    _fatController.text = fGram.toInt().toString();
    
    // ────── ถ้ามี 2 macros ล็อคอยู่แล้ว คำนวณ unlocked macro ทันที ──────
    if (_lockedCount == 2) {
      _autoCalculateUnlocked();
    }
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
      case 'protein': return _proteinLocked;
      case 'carbs': return _carbLocked;
      case 'fat': return _fatLocked;
      default: return false;
    }
  }

  void _toggleLock(String macro) {
    // If already locked, can unlock
    if (_isLocked(macro)) {
      setState(() {
        switch (macro) {
          case 'protein': _proteinLocked = false; break;
          case 'carbs': _carbLocked = false; break;
          case 'fat': _fatLocked = false; break;
        }
      });
      // หลังปลดล็อค ไม่ต้องคำนวณ (ให้ user แก้เอง)
      return;
    }
    
    // Can only lock if less than 2 are locked
    if (_lockedCount >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Can only lock 2 macros at once'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }
    
    setState(() {
      switch (macro) {
        case 'protein': _proteinLocked = true; break;
        case 'carbs': _carbLocked = true; break;
        case 'fat': _fatLocked = true; break;
      }
    });
    
    // ────── หลังล็อค macro ที่ 2 ให้คำนวณ macro ที่ unlocked ทันที ──────
    _autoCalculateUnlocked();
  }

  /// When calories change, recalculate unlocked macro to fit
  void _onCalorieChanged() {
    if (_lockedCount == 2) {
      _autoCalculateUnlocked();
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
    final lockedCalories = (_proteinLocked ? _proteinGrams * _kCalPerGramProtein : 0) +
                           (_carbLocked ? _carbGrams * _kCalPerGramCarbs : 0) +
                           (_fatLocked ? _fatGrams * _kCalPerGramFat : 0);
    
    final remainingCalories = (targetCalories - lockedCalories).clamp(0, targetCalories);
    
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

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Goals'),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (profile) {
          _initFromProfile(profile);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== Info card =====
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.primary),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Set your daily calorie goal, then enter macro values in grams.\n'
                          '🔒 Lock up to 2 macros; the 3rd will auto-calculate to match calories.',
                          style: TextStyle(color: AppColors.primary, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ===== Calorie Goal =====
                _buildCalorieSection(),
                const SizedBox(height: 24),

                // ===== Macro Editors =====
                _buildMacroEditor(
                  label: 'Protein',
                  icon: '🥩',
                  macroKey: 'protein',
                  controller: _proteinController,
                  color: AppColors.protein,
                  kcalPerGram: _kCalPerGramProtein,
                ),
                const SizedBox(height: 12),
                _buildMacroEditor(
                  label: 'Carbs',
                  icon: '🍚',
                  macroKey: 'carbs',
                  controller: _carbController,
                  color: AppColors.carbs,
                  kcalPerGram: _kCalPerGramCarbs,
                ),
                const SizedBox(height: 12),
                _buildMacroEditor(
                  label: 'Fat',
                  icon: '🧈',
                  macroKey: 'fat',
                  controller: _fatController,
                  color: AppColors.fat,
                  kcalPerGram: _kCalPerGramFat,
                ),

                const SizedBox(height: 24),

                // ===== Water Goal =====
                _buildWaterSection(),
                const SizedBox(height: 28),

                // ===== Quick Presets =====
                const Text(
                  '⚡ Quick Presets',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildPresetChip(
                      label: 'Lose Weight',
                      cal: 1500, pGram: 131, cGram: 150, fGram: 42,
                    ),
                    _buildPresetChip(
                      label: 'Maintain',
                      cal: 2000, pGram: 150, cGram: 225, fGram: 56,
                    ),
                    _buildPresetChip(
                      label: 'Build Muscle',
                      cal: 2500, pGram: 219, cGram: 281, fGram: 56,
                    ),
                    _buildPresetChip(
                      label: 'Keto',
                      cal: 1800, pGram: 113, cGram: 23, fGram: 140,
                    ),
                    _buildPresetChip(
                      label: 'Balanced',
                      cal: 2000, pGram: 150, cGram: 200, fGram: 67,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ===== Save Button =====
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveGoals,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 16),
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
        const Text(
          '🔥 Daily Calorie Goal',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
            suffixStyle: TextStyle(fontSize: 14, color: Colors.grey[600]),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLocked ? color.withOpacity(0.6) : color.withOpacity(0.3),
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
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'auto',
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
                  '${kcalPerGram.toInt()} kcal/g • ${kcal.round()} kcal',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Lock button
          InkWell(
            onTap: () => _toggleLock(macroKey),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                isLocked ? Icons.lock : Icons.lock_open,
                size: 20,
                color: isLocked ? color : Colors.grey[400],
              ),
            ),
          ),

          const SizedBox(width: 8),

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
                color: isAutoCalculated ? Colors.grey[500] : color,
              ),
              decoration: InputDecoration(
                suffixText: 'g',
                suffixStyle: TextStyle(
                  fontSize: 12,
                  color: isAutoCalculated ? Colors.grey[500] : Colors.grey[600],
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: color, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================
  // Water Section
  // ========================================================
  Widget _buildWaterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '💧 Daily Water Goal',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _waterController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            suffixText: 'ml',
            suffixStyle: TextStyle(fontSize: 14, color: Colors.grey[600]),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }

  // ========================================================
  // Preset Chip
  // ========================================================
  Widget _buildPresetChip({
    required String label,
    required int cal,
    required int pGram,
    required int cGram,
    required int fGram,
  }) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        setState(() {
          _calorieController.text = cal.toString();
          _proteinController.text = pGram.toString();
          _carbController.text = cGram.toString();
          _fatController.text = fGram.toString();
        });
      },
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
        waterGoal: double.tryParse(_waterController.text),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Goals saved successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
