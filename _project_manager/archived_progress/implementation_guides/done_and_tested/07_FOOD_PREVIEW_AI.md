# Step 07: Food Preview Screen with AI Analysis

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 2 ชั่วโมง
> **ความยาก:** ยาก
> **ต้องทำก่อน:** Step 04 (Profile Settings - API Key), Step 06 (Diet Tab)

---

## สิ่งที่ต้องทำ

1. สร้าง Gemini Service สำหรับวิเคราะห์อาหาร
2. สร้าง Camera/Gallery Picker Service
3. สร้าง Food Preview Screen
4. เชื่อมต่อกับ Magic Button

---

## ขั้นตอนที่ 1: สร้าง Gemini Service

**สร้างไฟล์:** `lib/core/ai/gemini_service.dart`

```dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../services/secure_storage_service.dart';

class GeminiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';
  static const String _model = 'gemini-1.5-flash';

  // Check if API key is configured
  static Future<bool> hasApiKey() async {
    return await SecureStorageService.hasGeminiApiKey();
  }

  // Test connection
  static Future<bool> testConnection() async {
    final apiKey = await SecureStorageService.getGeminiApiKey();
    if (apiKey == null) return false;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?key=$apiKey'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Analyze food image
  static Future<FoodAnalysisResult?> analyzeFoodImage(File imageFile) async {
    final apiKey = await SecureStorageService.getGeminiApiKey();
    if (apiKey == null) {
      throw Exception('No API key configured');
    }

    try {
      // Read and encode image
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Prepare request
      final url = Uri.parse('$_baseUrl/$_model:generateContent?key=$apiKey');
      
      final body = jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text': '''คุณเป็น AI ที่เชี่ยวชาญด้านโภชนาการอาหารไทยและนานาชาติ
วิเคราะห์รูปภาพอาหารและประมาณค่าโภชนาการให้แม่นยำที่สุด

ให้ตอบเป็น JSON format เท่านั้น (ห้ามมีข้อความอื่น):
{
  "food_name": "ชื่ออาหารภาษาไทย",
  "food_name_en": "English name",
  "confidence": 0.85,
  "serving_size": 1,
  "serving_unit": "จาน",
  "serving_grams": 250,
  "nutrition": {
    "calories": 520,
    "protein": 25,
    "carbs": 65,
    "fat": 18,
    "fiber": 3,
    "sugar": 5,
    "sodium": 850
  },
  "ingredients": ["กุ้ง", "ข้าว", "ไข่"],
  "notes": "หมายเหตุเพิ่มเติม (ถ้ามี)"
}''',
              },
              {
                'inline_data': {
                  'mime_type': 'image/jpeg',
                  'data': base64Image,
                },
              },
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.4,
          'topK': 32,
          'topP': 1,
          'maxOutputTokens': 1024,
        },
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
        
        // Parse JSON from response
        final jsonString = _extractJson(text);
        if (jsonString != null) {
          final parsed = jsonDecode(jsonString);
          return FoodAnalysisResult.fromJson(parsed);
        }
      } else {
        throw Exception('API error: ${response.statusCode} - ${response.body}');
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Extract JSON from text
  static String? _extractJson(String text) {
    // Find JSON object in response
    final startIndex = text.indexOf('{');
    final endIndex = text.lastIndexOf('}');
    
    if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
      return text.substring(startIndex, endIndex + 1);
    }
    return null;
  }
}

// ============================================
// FOOD ANALYSIS RESULT
// ============================================

class FoodAnalysisResult {
  final String foodName;
  final String? foodNameEn;
  final double confidence;
  final double servingSize;
  final String servingUnit;
  final int? servingGrams;
  final NutritionData nutrition;
  final List<String>? ingredients;
  final String? notes;

  FoodAnalysisResult({
    required this.foodName,
    this.foodNameEn,
    required this.confidence,
    required this.servingSize,
    required this.servingUnit,
    this.servingGrams,
    required this.nutrition,
    this.ingredients,
    this.notes,
  });

  factory FoodAnalysisResult.fromJson(Map<String, dynamic> json) {
    return FoodAnalysisResult(
      foodName: json['food_name'] ?? 'Unknown',
      foodNameEn: json['food_name_en'],
      confidence: (json['confidence'] ?? 0.5).toDouble(),
      servingSize: (json['serving_size'] ?? 1).toDouble(),
      servingUnit: json['serving_unit'] ?? 'จาน',
      servingGrams: json['serving_grams'],
      nutrition: NutritionData.fromJson(json['nutrition'] ?? {}),
      ingredients: json['ingredients'] != null
          ? List<String>.from(json['ingredients'])
          : null,
      notes: json['notes'],
    );
  }
}

class NutritionData {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double? fiber;
  final double? sugar;
  final double? sodium;

  NutritionData({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber,
    this.sugar,
    this.sodium,
  });

  factory NutritionData.fromJson(Map<String, dynamic> json) {
    return NutritionData(
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      fiber: json['fiber']?.toDouble(),
      sugar: json['sugar']?.toDouble(),
      sodium: json['sodium']?.toDouble(),
    );
  }
}
```

---

## ขั้นตอนที่ 2: สร้าง Image Picker Service

**สร้างไฟล์:** `lib/core/services/image_picker_service.dart`

```dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  // Pick from camera
  static Future<File?> pickFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  // Pick from gallery
  static Future<File?> pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  // Pick multiple from gallery
  static Future<List<File>> pickMultipleFromGallery() async {
    final List<XFile> images = await _picker.pickMultiImage(
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    return images.map((xFile) => File(xFile.path)).toList();
  }
}
```

---

## ขั้นตอนที่ 3: สร้าง Food Preview Screen

**สร้างไฟล์:** `lib/features/health/presentation/food_preview_screen.dart`

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/enums.dart';
import '../../../core/ai/gemini_service.dart';
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
  FoodAnalysisResult? _analysisResult;
  String? _error;

  // Editable fields
  late TextEditingController _nameController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  late TextEditingController _servingSizeController;
  
  String _servingUnit = 'จาน';
  MealType _selectedMealType = MealType.lunch;

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
    final hasKey = await GeminiService.hasApiKey();
    if (hasKey) {
      _analyzeFood();
    }
  }

  @override
  void dispose() {
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
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'ปริมาณ',
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
                    value: _servingUnit,
                    decoration: InputDecoration(
                      labelText: 'หน่วย',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'จาน', child: Text('จาน')),
                      DropdownMenuItem(value: 'ถ้วย', child: Text('ถ้วย')),
                      DropdownMenuItem(value: 'ชิ้น', child: Text('ชิ้น')),
                      DropdownMenuItem(value: 'กรัม', child: Text('กรัม')),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _servingUnit = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Calories (big number)
            _buildCaloriesInput(),
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
                Expanded(child: _buildMacroInput('Protein', _proteinController, AppColors.protein)),
                const SizedBox(width: 8),
                Expanded(child: _buildMacroInput('Carbs', _carbsController, AppColors.carbs)),
                const SizedBox(width: 8),
                Expanded(child: _buildMacroInput('Fat', _fatController, AppColors.fat)),
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
      child: Row(
        children: const [
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
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Text(
                '⚠️ ต้องใช้ Gemini AI วิเคราะห์',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _analyzeFood,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('ใช้ AI วิเคราะห์'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'หรือกรอกข้อมูลด้านล่างเอง',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
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
              _buildQuickAdjustButton(+50),
              _buildQuickAdjustButton(+100),
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
        _caloriesController.text = newValue.toString();
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
    final hasKey = await GeminiService.hasApiKey();
    if (!hasKey) {
      setState(() => _error = 'กรุณาตั้งค่า Gemini API Key ก่อน');
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _error = null;
    });

    try {
      final result = await GeminiService.analyzeFoodImage(widget.imageFile);
      
      if (result != null) {
        setState(() {
          _analysisResult = result;
          _hasAnalyzed = true;
          
          // Fill in fields
          _nameController.text = result.foodName;
          _caloriesController.text = result.nutrition.calories.toInt().toString();
          _proteinController.text = result.nutrition.protein.toInt().toString();
          _carbsController.text = result.nutrition.carbs.toInt().toString();
          _fatController.text = result.nutrition.fat.toInt().toString();
          _servingSizeController.text = result.servingSize.toString();
          _servingUnit = result.servingUnit;
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
    if (calories <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกแคลอรี่')),
      );
      return;
    }

    // Create entry
    final entry = FoodEntry()
      ..foodName = _nameController.text.trim()
      ..foodNameEn = _analysisResult?.foodNameEn
      ..calories = calories
      ..protein = double.tryParse(_proteinController.text) ?? 0
      ..carbs = double.tryParse(_carbsController.text) ?? 0
      ..fat = double.tryParse(_fatController.text) ?? 0
      ..mealType = _selectedMealType
      ..servingSize = double.tryParse(_servingSizeController.text) ?? 1
      ..servingUnit = _servingUnit
      ..imagePath = widget.imageFile.path
      ..timestamp = DateTime.now()
      ..source = _hasAnalyzed ? DataSource.aiAnalyzed : DataSource.manual
      ..aiConfidence = _analysisResult?.confidence
      ..isVerified = true;

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
}
```

---

## ขั้นตอนที่ 4: เชื่อมต่อกับ Magic Button

**แก้ไขไฟล์:** `lib/features/home/widgets/magic_button.dart`

**เพิ่ม imports:**

```dart
import 'dart:io';
import '../../../core/services/image_picker_service.dart';
import '../../health/presentation/food_preview_screen.dart';
```

**แก้ไข methods:**

```dart
void _openCamera(BuildContext context) async {
  final file = await ImagePickerService.pickFromCamera();
  if (file != null && context.mounted) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FoodPreviewScreen(imageFile: file),
      ),
    );
  }
}

void _openGallery(BuildContext context) async {
  final file = await ImagePickerService.pickFromGallery();
  if (file != null && context.mounted) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FoodPreviewScreen(imageFile: file),
      ),
    );
  }
}
```

---

## ขั้นตอนที่ 5: ทดสอบ

```bash
flutter run
```

**ผลที่ควรได้:**
- กดปุ่ม ✨ → ถ่ายรูป หรือ เลือกรูป
- เปิดหน้า Food Preview
- ถ้ามี API Key → AI วิเคราะห์อัตโนมัติ
- สามารถแก้ไขค่าได้
- กดบันทึก → บันทึกลง database

---

## ✅ Checklist

- [ ] สร้าง gemini_service.dart แล้ว
- [ ] สร้าง image_picker_service.dart แล้ว
- [ ] สร้าง food_preview_screen.dart แล้ว
- [ ] แก้ไข magic_button.dart แล้ว
- [ ] ทดสอบถ่ายรูป/เลือกรูปได้
- [ ] ทดสอบ AI วิเคราะห์ได้ (ถ้ามี API Key)
- [ ] ทดสอบบันทึกอาหารได้

---

## ไฟล์ที่สร้าง/แก้ไขในขั้นตอนนี้

```
lib/
├── core/
│   ├── ai/
│   │   └── gemini_service.dart       ← NEW
│   └── services/
│       └── image_picker_service.dart ← NEW
└── features/
    ├── home/
    │   └── widgets/
    │       └── magic_button.dart     ← UPDATED
    └── health/
        └── presentation/
            └── food_preview_screen.dart ← NEW
```

---

## ขั้นตอนถัดไป

ไปที่ **Step 08: Workout Program Management** เพื่อสร้างระบบจัดการโปรแกรมออกกำลังกาย
