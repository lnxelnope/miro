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

  // Macro percentages (ต้องรวมกัน = 100)
  int _proteinPct = 30; // ค่ากลาง balanced
  int _carbPct = 45;
  int _fatPct = 25;

  // Lock states (ล๊อคได้สูงสุด 2 ค่า)
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
  }

  @override
  void dispose() {
    _calorieController.dispose();
    _waterController.dispose();
    super.dispose();
  }

  void _initFromProfile(dynamic profile) {
    if (_initialized) return;
    _initialized = true;

    final cal = profile.calorieGoal as double;
    _calorieController.text = cal.toInt().toString();
    _waterController.text = (profile.waterGoal as double).toInt().toString();

    // คำนวณ % ย้อนกลับจาก gram goals ที่บันทึกไว้
    final pGram = profile.proteinGoal as double;
    final cGram = profile.carbGoal as double;
    final fGram = profile.fatGoal as double;

    final pKcal = pGram * _kCalPerGramProtein;
    final cKcal = cGram * _kCalPerGramCarbs;
    final fKcal = fGram * _kCalPerGramFat;
    final totalMacroKcal = pKcal + cKcal + fKcal;

    if (totalMacroKcal > 0) {
      _proteinPct = (pKcal / totalMacroKcal * 100).round();
      _fatPct = (fKcal / totalMacroKcal * 100).round();
      _carbPct = 100 - _proteinPct - _fatPct; // ให้ carbs เป็นตัวรับเศษ
    }
  }

  // ===== Computed grams =====
  double get _calories => double.tryParse(_calorieController.text) ?? 0;
  double get _proteinGrams => (_calories * _proteinPct / 100) / _kCalPerGramProtein;
  double get _carbGrams => (_calories * _carbPct / 100) / _kCalPerGramCarbs;
  double get _fatGrams => (_calories * _fatPct / 100) / _kCalPerGramFat;
  int get _totalPct => _proteinPct + _carbPct + _fatPct;

  // ===== Lock helpers =====
  int get _lockedCount => 
      (_proteinLocked ? 1 : 0) + (_carbLocked ? 1 : 0) + (_fatLocked ? 1 : 0);

  bool _canLock(String macro) {
    final isThisLocked = _isLocked(macro);
    if (isThisLocked) return true; // ปลดล๊อคได้เสมอ
    return _lockedCount < 2; // ล๊อคได้ถ้ายังล๊อคไม่ถึง 2 ตัว
  }

  bool _isLocked(String macro) {
    switch (macro) {
      case 'protein': return _proteinLocked;
      case 'carbs': return _carbLocked;
      case 'fat': return _fatLocked;
      default: return false;
    }
  }

  void _toggleLock(String macro) {
    if (!_canLock(macro) && !_isLocked(macro)) {
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
        case 'protein':
          _proteinLocked = !_proteinLocked;
          break;
        case 'carbs':
          _carbLocked = !_carbLocked;
          break;
        case 'fat':
          _fatLocked = !_fatLocked;
          break;
      }
    });
  }

  // ===== Adjust helpers =====
  void _adjustCalories(int delta) {
    final current = (double.tryParse(_calorieController.text) ?? 0).toInt();
    final next = (current + delta).clamp(500, 10000);
    _calorieController.text = next.toString();
    setState(() {});
  }

  /// ปรับ % ของ macro ตัวหนึ่ง แล้วจัด macro ที่เหลือให้รวมเป็น 100
  void _adjustMacroPct(String macro, int delta) {
    if (_isLocked(macro)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${macro.toUpperCase()} is locked'),
          duration: const Duration(milliseconds: 500),
        ),
      );
      return;
    }

    setState(() {
      switch (macro) {
        case 'protein':
          _proteinPct = (_proteinPct + delta).clamp(5, 80);
          _balanceOthers('protein');
          break;
        case 'carbs':
          _carbPct = (_carbPct + delta).clamp(5, 80);
          _balanceOthers('carbs');
          break;
        case 'fat':
          _fatPct = (_fatPct + delta).clamp(5, 80);
          _balanceOthers('fat');
          break;
      }
    });
  }

  /// ปรับ 2 ตัวที่เหลือให้รวมเป็น 100 โดยแบ่งตามสัดส่วนเดิม
  /// ถ้ามีตัวที่ล๊อค → ตัวที่ไม่ล๊อครับเปลี่ยนทั้งหมด
  void _balanceOthers(String changed) {
    final remaining = 100 - _getPct(changed);
    
    // หาตัวที่ไม่ใช่ changed
    final others = _getOtherMacros(changed);
    final lock1 = _isLocked(others.$1);
    final lock2 = _isLocked(others.$2);

    if (lock1 && lock2) {
      // ล๊อคทั้ง 2 → ไม่สามารถปรับได้
      return;
    } else if (lock1) {
      // ล๊อค 1 → ตัว 2 รับทั้งหมด
      _setPctByName(others.$2, remaining - _getPct(others.$1));
    } else if (lock2) {
      // ล๊อค 2 → ตัว 1 รับทั้งหมด
      _setPctByName(others.$1, remaining - _getPct(others.$2));
    } else {
      // ไม่ล๊อคเลย → แบ่งตามสัดส่วน
      if (remaining < 10) {
        _setPctPair(changed, remaining ~/ 2, remaining - remaining ~/ 2);
        return;
      }

      final otherPcts = _getOtherPcts(changed);
      final otherSum = otherPcts.$1 + otherPcts.$2;
      if (otherSum == 0) {
        _setPctPair(changed, remaining ~/ 2, remaining - remaining ~/ 2);
      } else {
        final first = (otherPcts.$1 / otherSum * remaining).round().clamp(5, remaining - 5);
        final second = remaining - first;
        _setPctPair(changed, first, second);
      }
    }
  }

  int _getPct(String macro) {
    switch (macro) {
      case 'protein': return _proteinPct;
      case 'carbs': return _carbPct;
      case 'fat': return _fatPct;
      default: return 0;
    }
  }

  void _setPctByName(String macro, int value) {
    switch (macro) {
      case 'protein':
        _proteinPct = value.clamp(5, 80);
        break;
      case 'carbs':
        _carbPct = value.clamp(5, 80);
        break;
      case 'fat':
        _fatPct = value.clamp(5, 80);
        break;
    }
  }

  (String, String) _getOtherMacros(String changed) {
    switch (changed) {
      case 'protein': return ('carbs', 'fat');
      case 'carbs': return ('protein', 'fat');
      case 'fat': return ('protein', 'carbs');
      default: return ('', '');
    }
  }

  (int, int) _getOtherPcts(String changed) {
    switch (changed) {
      case 'protein': return (_carbPct, _fatPct);
      case 'carbs': return (_proteinPct, _fatPct);
      case 'fat': return (_proteinPct, _carbPct);
      default: return (0, 0);
    }
  }

  void _setPctPair(String changed, int first, int second) {
    switch (changed) {
      case 'protein':
        _carbPct = first;
        _fatPct = second;
        break;
      case 'carbs':
        _proteinPct = first;
        _fatPct = second;
        break;
      case 'fat':
        _proteinPct = first;
        _carbPct = second;
        break;
    }
  }

  /// กรอก calorie ใหม่ → macro % คงเดิม, กรัมเปลี่ยนอัตโนมัติ
  void _onCalorieChanged() {
    setState(() {}); // rebuild grams
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
                          'Set calories, then adjust macro ratios (%)\n'
                          '🔒 Lock up to 2 macros to keep them fixed',
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

                // ===== Macro Distribution Bar =====
                _buildMacroDistributionBar(),
                const SizedBox(height: 20),

                // ===== Macro % Editors =====
                _buildMacroEditor(
                  label: 'Protein',
                  icon: '🥩',
                  pct: _proteinPct,
                  grams: _proteinGrams,
                  color: AppColors.protein,
                  kcalPerGram: _kCalPerGramProtein,
                  onAdjust: (d) => _adjustMacroPct('protein', d),
                ),
                const SizedBox(height: 12),
                _buildMacroEditor(
                  label: 'Carbs',
                  icon: '🍚',
                  pct: _carbPct,
                  grams: _carbGrams,
                  color: AppColors.carbs,
                  kcalPerGram: _kCalPerGramCarbs,
                  onAdjust: (d) => _adjustMacroPct('carbs', d),
                ),
                const SizedBox(height: 12),
                _buildMacroEditor(
                  label: 'Fat',
                  icon: '🧈',
                  pct: _fatPct,
                  grams: _fatGrams,
                  color: AppColors.fat,
                  kcalPerGram: _kCalPerGramFat,
                  onAdjust: (d) => _adjustMacroPct('fat', d),
                ),

                // validation warning
                if (_totalPct != 100) ...[
                  const SizedBox(height: 8),
                  Text(
                    'รวม $_totalPct% (ต้อง = 100%)',
                    style: const TextStyle(color: AppColors.error, fontSize: 12),
                  ),
                ],

                const SizedBox(height: 24),

                // ===== Water Goal =====
                _buildWaterSection(),
                const SizedBox(height: 28),

                // ===== Quick Presets =====
                const Text(
                  '⚡ Presets',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildPresetChip(
                      label: 'Lose Weight',
                      cal: 1500, pPct: 35, cPct: 40, fPct: 25,
                    ),
                    _buildPresetChip(
                      label: 'รักษาน้ำหนัก',
                      cal: 2000, pPct: 30, cPct: 45, fPct: 25,
                    ),
                    _buildPresetChip(
                      label: 'Build Muscle',
                      cal: 2500, pPct: 35, cPct: 45, fPct: 20,
                    ),
                    _buildPresetChip(
                      label: 'Keto',
                      cal: 1800, pPct: 25, cPct: 5, fPct: 70,
                    ),
                    _buildPresetChip(
                      label: 'Balanced',
                      cal: 2000, pPct: 30, cPct: 40, fPct: 30,
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
  // Calorie Section — ช่องกรอก + ปุ่ม +/-
  // ========================================================
  Widget _buildCalorieSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🔥 แคลอรี่ / วัน',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // ปุ่ม -100
            _buildStepButton(
              icon: Icons.remove,
              onTap: () => _adjustCalories(-100),
            ),
            const SizedBox(width: 8),
            // ช่องกรอก
            Expanded(
              child: TextField(
                controller: _calorieController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                onChanged: (_) => _onCalorieChanged(),
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
            ),
            const SizedBox(width: 8),
            // ปุ่ม +100
            _buildStepButton(
              icon: Icons.add,
              onTap: () => _adjustCalories(100),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'Adjust by 100 kcal or type your own number',
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ),
      ],
    );
  }

  // ========================================================
  // Macro Distribution Bar — แถบสีสัดส่วน P / C / F
  // ========================================================
  Widget _buildMacroDistributionBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '💪 Macro Ratio (%)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 24,
            child: Row(
              children: [
                Flexible(
                  flex: _proteinPct.clamp(1, 100),
                  child: Container(
                    color: AppColors.protein,
                    alignment: Alignment.center,
                    child: _proteinPct >= 10
                        ? Text('P $_proteinPct%',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))
                        : null,
                  ),
                ),
                Flexible(
                  flex: _carbPct.clamp(1, 100),
                  child: Container(
                    color: AppColors.carbs,
                    alignment: Alignment.center,
                    child: _carbPct >= 10
                        ? Text('C $_carbPct%',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))
                        : null,
                  ),
                ),
                Flexible(
                  flex: _fatPct.clamp(1, 100),
                  child: Container(
                    color: AppColors.fat,
                    alignment: Alignment.center,
                    child: _fatPct >= 10
                        ? Text('F $_fatPct%',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ========================================================
  // Macro Editor Row — ปุ่ม +/- สำหรับ % + แสดงกรัม + ปุ่มล๊อค
  // ========================================================
  Widget _buildMacroEditor({
    required String label,
    required String icon,
    required int pct,
    required double grams,
    required Color color,
    required double kcalPerGram,
    required void Function(int delta) onAdjust,
  }) {
    final kcal = grams * kcalPerGram;
    final macroKey = label.toLowerCase();
    final isLocked = _isLocked(macroKey);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          SizedBox(
            width: 58,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontWeight: FontWeight.w600, color: color, fontSize: 13)),
                Text('${kcalPerGram.toInt()} kcal/g',
                    style: TextStyle(fontSize: 9, color: Colors.grey[500])),
              ],
            ),
          ),

          // ปุ่มล๊อค
          InkWell(
            onTap: () => _toggleLock(macroKey),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                isLocked ? Icons.lock : Icons.lock_open,
                size: 18,
                color: isLocked ? color : Colors.grey[400],
              ),
            ),
          ),

          const SizedBox(width: 4),

          // ปุ่ม -5%
          _buildSmallStepButton(
            icon: Icons.remove,
            color: color,
            onTap: () => onAdjust(-5),
            disabled: isLocked,
          ),
          const SizedBox(width: 4),
          // %
          Container(
            width: 48,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$pct%',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
          ),
          const SizedBox(width: 4),
          // ปุ่ม +5%
          _buildSmallStepButton(
            icon: Icons.add,
            color: color,
            onTap: () => onAdjust(5),
            disabled: isLocked,
          ),

          const Spacer(),

          // แสดงกรัมที่คำนวณได้
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${grams.round()} g',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                '${kcal.round()} kcal',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
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
          '💧 น้ำ / วัน',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildStepButton(
              icon: Icons.remove,
              onTap: () {
                final cur = (int.tryParse(_waterController.text) ?? 0);
                _waterController.text = (cur - 250).clamp(250, 10000).toString();
                setState(() {});
              },
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
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
            ),
            const SizedBox(width: 8),
            _buildStepButton(
              icon: Icons.add,
              onTap: () {
                final cur = (int.tryParse(_waterController.text) ?? 0);
                _waterController.text = (cur + 250).clamp(250, 10000).toString();
                setState(() {});
              },
            ),
          ],
        ),
      ],
    );
  }

  // ========================================================
  // Preset Chip — ตั้งทั้ง kcal + %
  // ========================================================
  Widget _buildPresetChip({
    required String label,
    required int cal,
    required int pPct,
    required int cPct,
    required int fPct,
  }) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        setState(() {
          _calorieController.text = cal.toString();
          _proteinPct = pPct;
          _carbPct = cPct;
          _fatPct = fPct;
        });
      },
    );
  }

  // ========================================================
  // Step Button (ใหญ่ — สำหรับ calorie / water)
  // ========================================================
  Widget _buildStepButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: AppColors.textPrimary),
        ),
      ),
    );
  }

  // ========================================================
  // Step Button (เล็ก — สำหรับ macro %)
  // ========================================================
  Widget _buildSmallStepButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool disabled = false,
  }) {
    return Material(
      color: disabled ? Colors.grey[300] : color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: disabled ? null : onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            icon,
            size: 18,
            color: disabled ? Colors.grey[500] : color,
          ),
        ),
      ),
    );
  }

  // ========================================================
  // Save — แปลง % กลับเป็น grams แล้วบันทึก
  // ========================================================
  Future<void> _saveGoals() async {
    if (_totalPct != 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Macro ratio totals $_totalPct% — must = 100%'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

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
