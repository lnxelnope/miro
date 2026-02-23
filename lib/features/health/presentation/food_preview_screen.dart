import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/constants/enums.dart';
import '../../../core/ai/gemini_service.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../core/utils/logger.dart';
import '../../../core/services/usage_limiter.dart';
import '../../../features/energy/widgets/no_energy_dialog.dart';
import '../../../core/widgets/search_mode_selector.dart';
import '../../../l10n/app_localizations.dart';
import '../models/food_entry.dart';
import '../providers/health_provider.dart';

class FoodPreviewScreen extends ConsumerStatefulWidget {
  final File imageFile;
  final bool autoAnalyze; // วิเคราะห์ด้วย AI อัตโนมัติเมื่อเปิดหน้านี้

  const FoodPreviewScreen({
    super.key,
    required this.imageFile,
    this.autoAnalyze = false,
  });

  @override
  ConsumerState<FoodPreviewScreen> createState() => _FoodPreviewScreenState();
}

class _FoodPreviewScreenState extends ConsumerState<FoodPreviewScreen> {
  bool _isAnalyzing = false;
  bool _isCancelled = false;
  bool _hasAnalyzed = false;
  bool _hasGeminiKey = false;
  FoodAnalysisResult? _analysisResult;
  String? _error;
  FoodSearchMode _searchMode = FoodSearchMode.normal;

  // Editable fields
  late TextEditingController _nameController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  late TextEditingController _servingSizeController;

  String _servingUnit = 'serving';
  MealType _selectedMealType = MealType.lunch;

  // ค่าฐาน (ต่อ 1 หน่วย) สำหรับ recalculate เมื่อเปลี่ยนปริมาณ
  double _baseCalories = 0;
  double _baseProtein = 0;
  double _baseCarbs = 0;
  double _baseFat = 0;
  bool _hasBaseValues = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _caloriesController = TextEditingController();
    _proteinController = TextEditingController(text: '0');
    _carbsController = TextEditingController(text: '0');
    _fatController = TextEditingController(text: '0');
    _servingSizeController = TextEditingController(text: '1');

    // Detect meal type based on time
    _selectedMealType = _detectMealType();

    // ฟัง serving size เปลี่ยน → recalculate kcal/macro
    _servingSizeController.addListener(_onServingSizeChanged);

    // Check if API key exists and start analysis
    _checkAndAnalyze();
  }

  MealType _detectMealType() {
    final hour = DateTime.now().hour;
    if (hour < 11) return MealType.breakfast;
    if (hour < 15) return MealType.lunch;
    if (hour < 20) return MealType.dinner;
    return MealType.snack;
  }

  Future<void> _checkAndAnalyze() async {
    // ตรวจสอบว่าควรทำ auto-analyze หรือไม่
    // ตอนนี้ใช้ Energy System แล้ว ไม่ต้องเช็ค API Key
    setState(() {
      _hasGeminiKey = true; // Energy System พร้อมใช้งานเสมอ
    });

    // ถ้า autoAnalyze = true (มาจากแชท) ให้วิเคราะห์ทันที
    if (widget.autoAnalyze && mounted) {
      await _analyzeFood();
    }
  }

  /// เมื่อ serving size เปลี่ยน → คำนวณ kcal/macro ใหม่จาก base values
  void _onServingSizeChanged() {
    if (!_hasBaseValues) return;

    final newServing = double.tryParse(_servingSizeController.text) ?? 0;
    if (newServing <= 0) return;

    setState(() {
      _caloriesController.text =
          (_baseCalories * newServing).round().toString();
      _proteinController.text = (_baseProtein * newServing).round().toString();
      _carbsController.text = (_baseCarbs * newServing).round().toString();
      _fatController.text = (_baseFat * newServing).round().toString();
    });
  }

  @override
  void dispose() {
    _isCancelled = true;
    _servingSizeController.removeListener(_onServingSizeChanged);
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _servingSizeController.dispose();
    super.dispose();
  }

  /// เตือนผู้ใช้ก่อนออกขณะ AI กำลังวิเคราะห์
  Future<bool> _onWillPop() async {
    if (!_isAnalyzing) return true;

    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(child: Text(L10n.of(context)!.analyzingTitle)),
          ],
        ),
        content: Text(L10n.of(context)!.analyzingWarningContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(L10n.of(context)!.waitButton),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text(L10n.of(context)!.exitButton),
          ),
        ],
      ),
    );

    if (shouldLeave == true) {
      _isCancelled = true;
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      canPop: !_isAnalyzing,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldLeave = await _onWillPop();
        if (shouldLeave && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: Text(L10n.of(context)!.saveFoodTitle),
        actions: [
          if (!_isAnalyzing)
            TextButton(
              onPressed: _saveFood,
              child: Text(
                L10n.of(context)!.saveButton,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image preview
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                widget.imageFile,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            // Analysis status
            if (_isAnalyzing) _buildAnalyzingIndicator(),
            if (_error != null) _buildErrorMessage(),
            if (_hasAnalyzed && _analysisResult != null)
              _buildAnalysisSuccess(),

            // Search Mode Toggle (show before analysis)
            if (!_hasAnalyzed && !_isAnalyzing)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SearchModeSelector(
                  selectedMode: _searchMode,
                  onChanged: (mode) => setState(() => _searchMode = mode),
                ),
              ),

            // Manual analyze button (if no auto-analyze)
            if (!_hasAnalyzed && !_isAnalyzing) _buildAnalyzeButton(),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Food name
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: L10n.of(context)!.foodNameLabel,
                hintText: L10n.of(context)!.foodNameHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Serving size
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _servingSizeController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: L10n.of(context)!.amountLabel,
                      helperText:
                          _hasBaseValues ? L10n.of(context)!.amountAutoAdjust : null,
                      helperStyle: TextStyle(
                          fontSize: 11, color: Colors.purple.shade300),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    initialValue: UnitConverter.ensureValid(_servingUnit),
                    decoration: InputDecoration(
                      labelText: L10n.of(context)!.unitLabel,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: UnitConverter.allDropdownItems,
                    onChanged: (value) {
                      if (value != null && value.isNotEmpty) {
                        setState(() => _servingUnit = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Calories (big number)
            _buildCaloriesInput(),

            // แสดง base info ถ้ามี
            if (_hasBaseValues) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceVariantDark : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        L10n.of(context)!.baseInfo(
                          _baseCalories.toInt().toString(),
                          _servingUnit,
                          _baseProtein.toInt().toString(),
                          _baseCarbs.toInt().toString(),
                          _baseFat.toInt().toString(),
                        ),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Macros
            AppIcons.iconWithLabel(
              AppIcons.macros,
              L10n.of(context)!.macrosTitle,
              iconColor: AppIcons.macrosColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _buildMacroInput(
                        L10n.of(context)!.proteinLabel, _proteinController, AppColors.health)),
                const SizedBox(width: 8),
                Expanded(
                    child: _buildMacroInput(
                        L10n.of(context)!.carbsLabel, _carbsController, AppColors.health)),
                const SizedBox(width: 8),
                Expanded(
                    child: _buildMacroInput(
                        L10n.of(context)!.fatLabel, _fatController, AppColors.health)),
              ],
            ),
            const SizedBox(height: 24),

            // Meal type
            AppIcons.iconWithLabel(
              AppIcons.meal,
              L10n.of(context)!.mealTypeTitle,
              iconColor: AppIcons.mealColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: MealType.values.map((type) {
                final isSelected = _selectedMealType == type;
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(type.icon, size: 16, color: type.iconColor),
                      const SizedBox(width: 6),
                      Text(type.displayName),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedMealType = type);
                  },
                  selectedColor: AppColors.health.withOpacity(0.2),
                );
              }).toList(),
            ),

            // แสดงวัตถุดิบ (ถ้ามี) — ย่อ default, กดเปิดเพื่อดู/แก้ไข
            if (_hasAnalyzed &&
                _analysisResult?.ingredientsDetail != null &&
                _analysisResult!.ingredientsDetail!.isNotEmpty) ...[
              const SizedBox(height: 24),
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceVariantDark : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                    childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    initiallyExpanded: false,
                    leading: const Icon(
                      Icons.restaurant_menu_rounded,
                      color: AppIcons.mealColor,
                      size: 20,
                    ),
                    title: Text(
                      '${L10n.of(context)!.ingredientsTitle} (${_analysisResult!.ingredientsDetail!.length})',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      L10n.of(context)!.ingredientsTapToExpand,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                    children: _analysisResult!.ingredientsDetail!.map((ingredient) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          '• ${ingredient.name} (${ingredient.amount}${ingredient.unit}) - ${ingredient.calories.toInt()} kcal',
                          style: const TextStyle(fontSize: 13),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _isAnalyzing ? null : _saveFood,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isAnalyzing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(AppIcons.save, size: 20, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        L10n.of(context)!.saveButton,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildAnalyzingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(L10n.of(context)!.processingImageData),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  L10n.of(context)!.unableToAnalyzeTitle,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: _analyzeFood,
                child: Text(L10n.of(context)!.tryAgainButton),
              ),
            ],
          ),
          Text(
            _error ?? '',
            style: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisSuccess() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                const Icon(AppIcons.aiAnalyzed, size: 16, color: AppColors.success),
                const SizedBox(width: 4),
                Text(
                  L10n.of(context)!.aiAnalyzedConfidence(
                    (_analysisResult!.confidence * 100).toInt().toString(),
                  ),
                  style: const TextStyle(color: AppColors.success),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    // Gemini Analysis Button
    if (_hasGeminiKey) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _isAnalyzing ? null : _analyzeFood,
          icon: _isAnalyzing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(AppIcons.aiAnalyzed, size: 20, color: Colors.purple),
          label: Text(_isAnalyzing ? L10n.of(context)!.analyzingButton : L10n.of(context)!.aiAnalysisButton),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.purple,
            side: const BorderSide(color: Colors.purple),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      );
    }

    // Manual input hint
    return Container(
      margin: const EdgeInsets.all(0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                L10n.of(context)!.manualInputHint,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildCaloriesInput() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.health.withOpacity(0.1),
            AppColors.health.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.health.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          AppIcons.iconWithLabel(
            AppIcons.calories,
            L10n.of(context)!.caloriesTitle,
            iconColor: AppIcons.caloriesColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _caloriesController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '0',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'kcal',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          // Quick adjust buttons
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildQuickAdjustButton(-100),
              _buildQuickAdjustButton(-50),
              _buildQuickAdjustButton(50),
              _buildQuickAdjustButton(100),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAdjustButton(int value) {
    final label = value > 0 ? '+$value' : '$value';
    return ActionChip(
      label: Text(label),
      onPressed: () {
        final current = int.tryParse(_caloriesController.text) ?? 0;
        final newValue = (current + value).clamp(0, 9999);
        setState(() {
          _caloriesController.text = newValue.toString();
        });
      },
    );
  }

  Widget _buildMacroInput(
      String label, TextEditingController controller, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            suffixText: 'g',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _analyzeFood() async {
    // === ตรวจสอบ Energy ก่อนเรียก API ===
    final hasEnergy = await GeminiService.hasEnergy();
    if (!hasEnergy) {
      if (mounted) {
        await NoEnergyDialog.show(context);
      }
      return;
    }
    // === จบ Gate Check ===

    setState(() {
      _isAnalyzing = true;
      _isCancelled = false;
      _error = null;
    });

    try {
      final foodName = _nameController.text.trim();
      final quantity = double.tryParse(_servingSizeController.text);
      final result = await GeminiService.analyzeFoodImage(
        widget.imageFile,
        foodName: foodName.isNotEmpty ? foodName : null,
        quantity: quantity != null && quantity > 0 ? quantity : null,
        unit: _servingUnit,
        searchMode: _searchMode,
      );

      // ถ้า user กดออกระหว่างรอ → หยุดทำงาน
      if (_isCancelled || !mounted) return;

      if (result != null) {
        // === Record AI Usage หลังสำเร็จ ===
        await UsageLimiter.recordAiUsage();
        if (_isCancelled || !mounted) return;
        setState(() {
          _analysisResult = result;
          _hasAnalyzed = true;

          // Fill in fields
          _nameController.text = result.foodName;
          _servingUnit = _getValidUnit(result.servingUnit);

          // คำนวณ base values (ต่อ 1 หน่วย) จาก Gemini
          final geminiServing =
              result.servingSize > 0 ? result.servingSize : 1.0;
          _baseCalories = result.nutrition.calories / geminiServing;
          _baseProtein = result.nutrition.protein / geminiServing;
          _baseCarbs = result.nutrition.carbs / geminiServing;
          _baseFat = result.nutrition.fat / geminiServing;
          _hasBaseValues = true;

          // ต้อง remove listener ก่อน set text เพื่อไม่ให้ trigger ซ้ำ
          _servingSizeController.removeListener(_onServingSizeChanged);
          _caloriesController.text =
              result.nutrition.calories.toInt().toString();
          _proteinController.text = result.nutrition.protein.toInt().toString();
          _carbsController.text = result.nutrition.carbs.toInt().toString();
          _fatController.text = result.nutrition.fat.toInt().toString();
          _servingSizeController.text = result.servingSize.toString();
          _servingSizeController.addListener(_onServingSizeChanged);
        });
      } else {
        setState(() => _error = L10n.of(context)!.unableToAnalyzeImage);
      }
    } catch (e) {
      if (_isCancelled || !mounted) return;
      // ตรวจสอบว่าเป็น Energy error หรือไม่
      if (e.toString().contains('Insufficient energy')) {
        await NoEnergyDialog.show(context);
      } else {
        setState(() => _error = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  Future<void> _saveFood() async {
    // Validation
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(L10n.of(context)!.pleaseEnterFoodNameShort), duration: const Duration(seconds: 2)),
      );
      return;
    }

    final calories = double.tryParse(_caloriesController.text) ?? 0;
    // อนุญาตให้บันทึกด้วยค่า 0 ได้ (จะวิเคราะห์ด้วย Gemini ทีหลัง)

    // Create entry
    final protein = double.tryParse(_proteinController.text) ?? 0;
    final carbs = double.tryParse(_carbsController.text) ?? 0;
    final fat = double.tryParse(_fatController.text) ?? 0;
    final servingSize = double.tryParse(_servingSizeController.text) ?? 1;

    final entry = FoodEntry()
      ..foodName = _nameController.text.trim().isEmpty
          ? L10n.of(context)!.foodPendingAnalysis
          : _nameController.text.trim()
      ..foodNameEn = _analysisResult?.foodNameEn
      ..calories = calories
      ..protein = protein
      ..carbs = carbs
      ..fat = fat
      // เก็บ base values สำหรับ recalculate
      ..baseCalories = servingSize > 0 ? calories / servingSize : calories
      ..baseProtein = servingSize > 0 ? protein / servingSize : protein
      ..baseCarbs = servingSize > 0 ? carbs / servingSize : carbs
      ..baseFat = servingSize > 0 ? fat / servingSize : fat
      ..mealType = _selectedMealType
      ..servingSize = servingSize
      ..servingUnit = _servingUnit
      ..imagePath = widget.imageFile.path
      ..timestamp = DateTime.now()
      ..source = _hasAnalyzed ? DataSource.aiAnalyzed : DataSource.manual
      ..aiConfidence = _analysisResult?.confidence
      ..isVerified = _hasAnalyzed;

    // บันทึกวัตถุดิบ (ถ้ามี) จาก AI analysis
    if (_hasAnalyzed &&
        _analysisResult?.ingredientsDetail != null &&
        _analysisResult!.ingredientsDetail!.isNotEmpty) {
      entry.ingredientsJson = jsonEncode(_analysisResult!.ingredientsDetail);
      AppLogger.info(
          'Saved ${_analysisResult!.ingredientsDetail!.length} ingredients to FoodEntry');
    }

    // Save
    final notifier = ref.read(foodEntriesNotifierProvider.notifier);
    await notifier.addFoodEntry(entry);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(AppIcons.success, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(L10n.of(context)!.foodSavedSuccess),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  String _getValidUnit(String unit) => UnitConverter.ensureValid(unit);
}
