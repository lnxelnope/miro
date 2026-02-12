import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/enums.dart';
import '../../../core/ai/gemini_service.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../core/services/usage_limiter.dart';
import '../models/food_entry.dart';
import '../providers/health_provider.dart';

class FoodPreviewScreen extends ConsumerStatefulWidget {
  final File imageFile;

  const FoodPreviewScreen({
    super.key,
    required this.imageFile,
  });

  @override
  ConsumerState<FoodPreviewScreen> createState() => _FoodPreviewScreenState();
}

class _FoodPreviewScreenState extends ConsumerState<FoodPreviewScreen> {
  bool _isAnalyzing = false;
  bool _hasAnalyzed = false;
  bool _hasGeminiKey = false;
  FoodAnalysisResult? _analysisResult;
  String? _error;

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
    // ไม่ auto-analyze - ให้ผู้ใช้กดปุ่มเลือกเอง
    final hasKey = await GeminiService.hasApiKey();
    setState(() {
      _hasGeminiKey = hasKey;
    });
  }

  /// เมื่อ serving size เปลี่ยน → คำนวณ kcal/macro ใหม่จาก base values
  void _onServingSizeChanged() {
    if (!_hasBaseValues) return;

    final newServing = double.tryParse(_servingSizeController.text) ?? 0;
    if (newServing <= 0) return;

    setState(() {
      _caloriesController.text = (_baseCalories * newServing).round().toString();
      _proteinController.text = (_baseProtein * newServing).round().toString();
      _carbsController.text = (_baseCarbs * newServing).round().toString();
      _fatController.text = (_baseFat * newServing).round().toString();
    });
  }

  @override
  void dispose() {
    _servingSizeController.removeListener(_onServingSizeChanged);
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _servingSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('บันทึกอาหาร'),
        actions: [
          if (!_isAnalyzing)
            TextButton(
              onPressed: _saveFood,
              child: const Text(
                'บันทึก',
                style: TextStyle(
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
            if (_hasAnalyzed && _analysisResult != null) _buildAnalysisSuccess(),

            // Manual analyze button (if no auto-analyze)
            if (!_hasAnalyzed && !_isAnalyzing) _buildAnalyzeButton(),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Food name
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'ชื่ออาหาร',
                hintText: 'เช่น ข้าวผัดกุ้ง',
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
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'ปริมาณ',
                      helperText: _hasBaseValues ? 'เปลี่ยน → แคลเปลี่ยนตาม' : null,
                      helperStyle: TextStyle(fontSize: 11, color: Colors.purple.shade300),
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
                      labelText: 'Unit',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: UnitConverter.allDropdownItems,
                    onChanged: (value) {
                      if (value != null && value.isNotEmpty) setState(() => _servingUnit = value);
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
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'ค่าฐาน: ${_baseCalories.toInt()} kcal / 1 $_servingUnit '
                        '(P:${_baseProtein.toInt()}g C:${_baseCarbs.toInt()}g F:${_baseFat.toInt()}g)',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Macros
            const Text(
              '💪 Macros',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildMacroInput('Protein', _proteinController, AppColors.health)),
                const SizedBox(width: 8),
                Expanded(child: _buildMacroInput('Carbs', _carbsController, AppColors.health)),
                const SizedBox(width: 8),
                Expanded(child: _buildMacroInput('Fat', _fatController, AppColors.health)),
              ],
            ),
            const SizedBox(height: 24),

            // Meal type
            const Text(
              '🍽️ มื้ออาหาร',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: MealType.values.map((type) {
                final isSelected = _selectedMealType == type;
                return ChoiceChip(
                  label: Text('${type.icon} ${type.displayName}'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedMealType = type);
                  },
                  selectedColor: AppColors.health.withOpacity(0.2),
                );
              }).toList(),
            ),
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
                : const Text(
                    '💾 บันทึก',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
      child: const Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('✨ AI กำลังวิเคราะห์อาหาร...'),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
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
              const Expanded(
                child: Text(
                  'ไม่สามารถวิเคราะห์ได้',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: _analyzeFood,
                child: const Text('ลองอีกครั้ง'),
              ),
            ],
          ),
          Text(
            _error ?? '',
            style: const TextStyle(
              color: AppColors.textSecondary,
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
            child: Text(
              '✨ AI วิเคราะห์แล้ว (${(_analysisResult!.confidence * 100).toInt()}% confidence)',
              style: const TextStyle(color: AppColors.success),
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
              : const Text('✨'),
          label: Text(_isAnalyzing ? 'กำลังวิเคราะห์...' : 'วิเคราะห์ด้วย Gemini AI'),
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
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'กรอกข้อมูลอาหารด้านล่าง หรือตั้งค่า Gemini API Key เพื่อวิเคราะห์อัตโนมัติ',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaloriesInput() {
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
          const Text(
            '🔥 CALORIES',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.health,
            ),
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
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'kcal',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
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

  Widget _buildMacroInput(String label, TextEditingController controller, Color color) {
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
    // === เพิ่ม Gate Check ===
    // 1. เช็คว่ามี API Key ไหม (จาก Step 30)
    final hasKey = await GeminiService.hasApiKey();
    if (!hasKey) {
      if (mounted) {
        GeminiService.showNoApiKeyDialog(context);
      }
      return;
    }

    // 2. เช็คว่ายังเหลือโควต้า AI ไหม (ใหม่ Step 31)
    final canUse = await GeminiService.checkAndConsumeUsage(context);
    if (!canUse) return; // Upsell dialog will show automatically
    // === จบ Gate Check ===

    setState(() {
      _isAnalyzing = true;
      _error = null;
    });

    try {
      final result = await GeminiService.analyzeFoodImage(widget.imageFile);
      
      if (result != null) {
        // === Record AI Usage หลังสำเร็จ ===
        await UsageLimiter.recordAiUsage();
        setState(() {
          _analysisResult = result;
          _hasAnalyzed = true;
          
          // Fill in fields
          _nameController.text = result.foodName;
          _servingUnit = _getValidUnit(result.servingUnit);

          // คำนวณ base values (ต่อ 1 หน่วย) จาก Gemini
          final geminiServing = result.servingSize > 0 ? result.servingSize : 1.0;
          _baseCalories = result.nutrition.calories / geminiServing;
          _baseProtein = result.nutrition.protein / geminiServing;
          _baseCarbs = result.nutrition.carbs / geminiServing;
          _baseFat = result.nutrition.fat / geminiServing;
          _hasBaseValues = true;

          // ต้อง remove listener ก่อน set text เพื่อไม่ให้ trigger ซ้ำ
          _servingSizeController.removeListener(_onServingSizeChanged);
          _caloriesController.text = result.nutrition.calories.toInt().toString();
          _proteinController.text = result.nutrition.protein.toInt().toString();
          _carbsController.text = result.nutrition.carbs.toInt().toString();
          _fatController.text = result.nutrition.fat.toInt().toString();
          _servingSizeController.text = result.servingSize.toString();
          _servingSizeController.addListener(_onServingSizeChanged);
        });
      } else {
        setState(() => _error = 'ไม่สามารถวิเคราะห์ภาพได้');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _saveFood() async {
    // Validation
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกชื่ออาหาร')),
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
      ..foodName = _nameController.text.trim().isEmpty ? 'อาหาร (รอวิเคราะห์)' : _nameController.text.trim()
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

    // Save
    final notifier = ref.read(foodEntriesNotifierProvider.notifier);
    await notifier.addFoodEntry(entry);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('บันทึกอาหารสำเร็จ! 🎉'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  String _getValidUnit(String unit) => UnitConverter.ensureValid(unit);
}
