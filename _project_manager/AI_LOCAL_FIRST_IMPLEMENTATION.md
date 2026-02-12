# 🧠 AI Local-First Implementation Plan

> **เป้าหมาย:** ปรับให้แอปใช้ AI Local (regex/rule-based) เป็นหลัก และใช้ Gemini เฉพาะตอนวิเคราะห์รูปอาหาร (ต้องกดปุ่มเลือกก่อน)

---

## 📋 สารบัญ

1. [Task 1: แก้ไข LLMService ให้ใช้ Local เท่านั้น](#task-1-แก้ไข-llmservice-ให้ใช้-local-เท่านั้น)
2. [Task 2: แก้ไข FoodPreviewScreen ให้มีปุ่มเลือก Gemini](#task-2-แก้ไข-foodpreviewscreen-ให้มีปุ่มเลือก-gemini)
3. [Task 3: สร้าง Thai Food Database](#task-3-สร้าง-thai-food-database)
4. [Task 4: เพิ่ม Query Intent สำหรับถามข้อมูล](#task-4-เพิ่ม-query-intent-สำหรับถามข้อมูล)
5. [Task 5: เพิ่ม Edit/Delete Intent](#task-5-เพิ่ม-editdelete-intent)
6. [Testing Checklist](#testing-checklist)

---

## Task 1: แก้ไข LLMService ให้ใช้ Local เท่านั้น

### 📁 ไฟล์ที่ต้องแก้
`lib/core/ai/llm_service.dart`

### 📍 ตำแหน่งที่ต้องแก้
บรรทัด 40-53

### ❌ โค้ดเดิม
```dart
Future<String> classifyAndParse(String text) async {
  // ลองใช้ Gemini API ก่อน
  final apiKey = await _getApiKey();
  if (apiKey != null) {
    final result = await _callGeminiAPI(text, apiKey);
    if (result != null) {
      return result;
    }
  }

  // Fallback to local regex
  debugPrint('⚠️ Using local fallback for text: $text');
  return _localFallback(text);
}
```

### ✅ โค้ดใหม่
```dart
Future<String> classifyAndParse(String text) async {
  // ใช้ Local AI เท่านั้น (ไม่เรียก Gemini สำหรับ text classification)
  debugPrint('🧠 [LLMService] Processing with Local AI: $text');
  return _localFallback(text);
}
```

### 📝 หมายเหตุ
- ไม่ต้องลบ method `_callGeminiAPI` และ `_getApiKey` เพราะอาจใช้ในอนาคต
- แค่เปลี่ยน `classifyAndParse` ให้เรียก `_localFallback` โดยตรง

---

## Task 2: แก้ไข FoodPreviewScreen ให้มีปุ่มเลือก Gemini

### 📁 ไฟล์ที่ต้องแก้
`lib/features/health/presentation/food_preview_screen.dart`

### 📍 ส่วนที่ 1: ลบ auto-analyze
**ตำแหน่ง:** บรรทัด 64-69

**❌ โค้ดเดิม:**
```dart
Future<void> _checkAndAnalyze() async {
  final hasKey = await GeminiService.hasApiKey();
  if (hasKey) {
    _analyzeFood();
  }
}
```

**✅ โค้ดใหม่:**
```dart
Future<void> _checkAndAnalyze() async {
  // ไม่ auto-analyze - ให้ผู้ใช้กดปุ่มเลือกเอง
  final hasKey = await GeminiService.hasApiKey();
  setState(() {
    _hasGeminiKey = hasKey;
  });
}
```

### 📍 ส่วนที่ 2: เพิ่ม state variable
**ตำแหน่ง:** บรรทัด 23 (ใต้ `bool _hasAnalyzed = false;`)

**เพิ่มบรรทัดใหม่:**
```dart
bool _hasGeminiKey = false;
```

### 📍 ส่วนที่ 3: เพิ่มปุ่ม "วิเคราะห์ด้วย Gemini"
**ตำแหน่ง:** หา method `build()` แล้วหาส่วนที่แสดง UI ใต้รูปภาพ

**เพิ่ม Widget นี้ (ก่อน form กรอกข้อมูล):**
```dart
// Gemini Analysis Button
if (!_hasAnalyzed && _hasGeminiKey)
  Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
  ),

// Manual input hint
if (!_hasAnalyzed && !_hasGeminiKey)
  Container(
    margin: const EdgeInsets.all(16),
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
  ),
```

### 📍 ส่วนที่ 4: อัปเดต _analyzeFood ให้ set state เมื่อเสร็จ
**ตำแหน่ง:** หา method `_analyzeFood()`

**เพิ่มที่ท้าย method (หลัง set ค่าจาก result):**
```dart
setState(() {
  _hasAnalyzed = true;
});
```

---

## Task 3: สร้าง Thai Food Database

### 📁 สร้างไฟล์ใหม่
`lib/core/data/thai_food_database.dart`

### 📝 โค้ดทั้งหมด
```dart
/// ฐานข้อมูลอาหารไทยสำหรับประมาณค่าโภชนาการ
class ThaiFoodDatabase {
  static final Map<String, FoodNutritionData> _foods = {
    // ข้าว
    'ข้าวผัด': FoodNutritionData(calories: 450, protein: 12, carbs: 60, fat: 15),
    'ข้าวมันไก่': FoodNutritionData(calories: 550, protein: 25, carbs: 65, fat: 18),
    'ข้าวหมูแดง': FoodNutritionData(calories: 500, protein: 22, carbs: 60, fat: 16),
    'ข้าวหมูกรอบ': FoodNutritionData(calories: 600, protein: 20, carbs: 65, fat: 25),
    'ข้าวขาหมู': FoodNutritionData(calories: 650, protein: 28, carbs: 60, fat: 30),
    'ข้าวคลุกกะปิ': FoodNutritionData(calories: 480, protein: 15, carbs: 55, fat: 20),
    'ข้าวผัดกระเพรา': FoodNutritionData(calories: 520, protein: 22, carbs: 55, fat: 22),
    'ข้าวกระเพรา': FoodNutritionData(calories: 520, protein: 22, carbs: 55, fat: 22),
    'กระเพราหมู': FoodNutritionData(calories: 520, protein: 22, carbs: 55, fat: 22),
    'กระเพราไก่': FoodNutritionData(calories: 480, protein: 25, carbs: 55, fat: 18),
    'ข้าวไข่เจียว': FoodNutritionData(calories: 450, protein: 15, carbs: 50, fat: 20),
    'ข้าวไข่ดาว': FoodNutritionData(calories: 400, protein: 14, carbs: 50, fat: 16),
    'ข้าวต้ม': FoodNutritionData(calories: 200, protein: 8, carbs: 35, fat: 3),
    'โจ๊ก': FoodNutritionData(calories: 250, protein: 10, carbs: 40, fat: 5),
    
    // ก๋วยเตี๋ยว
    'ก๋วยเตี๋ยว': FoodNutritionData(calories: 350, protein: 15, carbs: 50, fat: 10),
    'ก๋วยเตี๋ยวน้ำใส': FoodNutritionData(calories: 300, protein: 15, carbs: 45, fat: 8),
    'ก๋วยเตี๋ยวน้ำตก': FoodNutritionData(calories: 380, protein: 18, carbs: 48, fat: 12),
    'ก๋วยเตี๋ยวเรือ': FoodNutritionData(calories: 400, protein: 20, carbs: 50, fat: 14),
    'ก๋วยเตี๋ยวต้มยำ': FoodNutritionData(calories: 350, protein: 16, carbs: 45, fat: 12),
    'บะหมี่': FoodNutritionData(calories: 380, protein: 14, carbs: 55, fat: 12),
    'เส้นหมี่': FoodNutritionData(calories: 320, protein: 12, carbs: 50, fat: 8),
    'ผัดไทย': FoodNutritionData(calories: 450, protein: 15, carbs: 60, fat: 16),
    'ผัดซีอิ๊ว': FoodNutritionData(calories: 420, protein: 14, carbs: 58, fat: 15),
    'ราดหน้า': FoodNutritionData(calories: 500, protein: 18, carbs: 60, fat: 20),
    
    // ต้ม/แกง
    'ต้มยำกุ้ง': FoodNutritionData(calories: 200, protein: 18, carbs: 15, fat: 8),
    'ต้มยำ': FoodNutritionData(calories: 180, protein: 15, carbs: 15, fat: 7),
    'ต้มข่าไก่': FoodNutritionData(calories: 280, protein: 18, carbs: 10, fat: 20),
    'แกงเขียวหวาน': FoodNutritionData(calories: 350, protein: 20, carbs: 15, fat: 25),
    'แกงแดง': FoodNutritionData(calories: 320, protein: 18, carbs: 15, fat: 22),
    'แกงมัสมั่น': FoodNutritionData(calories: 400, protein: 22, carbs: 20, fat: 28),
    'แกงพะแนง': FoodNutritionData(calories: 380, protein: 22, carbs: 15, fat: 26),
    'แกงส้ม': FoodNutritionData(calories: 150, protein: 12, carbs: 18, fat: 5),
    'แกงจืด': FoodNutritionData(calories: 120, protein: 10, carbs: 12, fat: 4),
    
    // ยำ/สลัด
    'ส้มตำ': FoodNutritionData(calories: 150, protein: 5, carbs: 25, fat: 4),
    'ส้มตำไทย': FoodNutritionData(calories: 150, protein: 5, carbs: 25, fat: 4),
    'ส้มตำปู': FoodNutritionData(calories: 180, protein: 8, carbs: 25, fat: 6),
    'ยำวุ้นเส้น': FoodNutritionData(calories: 200, protein: 12, carbs: 30, fat: 5),
    'ยำหมูยอ': FoodNutritionData(calories: 250, protein: 15, carbs: 20, fat: 12),
    'ลาบ': FoodNutritionData(calories: 200, protein: 18, carbs: 10, fat: 10),
    'น้ำตก': FoodNutritionData(calories: 220, protein: 20, carbs: 10, fat: 12),
    
    // ผัด
    'ผัดผัก': FoodNutritionData(calories: 150, protein: 5, carbs: 15, fat: 8),
    'ผัดคะน้า': FoodNutritionData(calories: 180, protein: 8, carbs: 12, fat: 12),
    'ผัดบวบ': FoodNutritionData(calories: 120, protein: 5, carbs: 10, fat: 8),
    'ผัดถั่วงอก': FoodNutritionData(calories: 140, protein: 6, carbs: 12, fat: 8),
    
    // ทอด/ปิ้ง/ย่าง
    'ไก่ทอด': FoodNutritionData(calories: 350, protein: 25, carbs: 15, fat: 22),
    'หมูทอด': FoodNutritionData(calories: 380, protein: 22, carbs: 15, fat: 26),
    'ปลาทอด': FoodNutritionData(calories: 300, protein: 28, carbs: 12, fat: 16),
    'ไก่ย่าง': FoodNutritionData(calories: 280, protein: 28, carbs: 5, fat: 16),
    'หมูปิ้ง': FoodNutritionData(calories: 200, protein: 18, carbs: 8, fat: 12),
    'ไส้กรอก': FoodNutritionData(calories: 250, protein: 12, carbs: 5, fat: 20),
    
    // ของหวาน
    'ไอศกรีม': FoodNutritionData(calories: 200, protein: 4, carbs: 25, fat: 10),
    'ขนมหวาน': FoodNutritionData(calories: 250, protein: 3, carbs: 40, fat: 8),
    'บัวลอย': FoodNutritionData(calories: 180, protein: 2, carbs: 35, fat: 4),
    'ขนมครก': FoodNutritionData(calories: 150, protein: 2, carbs: 20, fat: 7),
    'กล้วยบวชชี': FoodNutritionData(calories: 200, protein: 2, carbs: 35, fat: 6),
    'ข้าวเหนียวมะม่วง': FoodNutritionData(calories: 400, protein: 5, carbs: 70, fat: 12),
    
    // เครื่องดื่ม
    'ชาเย็น': FoodNutritionData(calories: 180, protein: 2, carbs: 35, fat: 5),
    'กาแฟเย็น': FoodNutritionData(calories: 150, protein: 2, carbs: 28, fat: 5),
    'น้ำอัดลม': FoodNutritionData(calories: 140, protein: 0, carbs: 35, fat: 0),
    'น้ำผลไม้': FoodNutritionData(calories: 120, protein: 0, carbs: 30, fat: 0),
    'นมเย็น': FoodNutritionData(calories: 160, protein: 6, carbs: 20, fat: 6),
    'ชาเขียว': FoodNutritionData(calories: 120, protein: 1, carbs: 28, fat: 1),
    'โอวัลติน': FoodNutritionData(calories: 180, protein: 5, carbs: 30, fat: 5),
    
    // อาหารเช้า
    'โทสต์': FoodNutritionData(calories: 200, protein: 5, carbs: 35, fat: 5),
    'ขนมปังปิ้ง': FoodNutritionData(calories: 200, protein: 5, carbs: 35, fat: 5),
    'ไข่ต้ม': FoodNutritionData(calories: 80, protein: 6, carbs: 1, fat: 5),
    'ไข่เจียว': FoodNutritionData(calories: 180, protein: 12, carbs: 2, fat: 14),
    'ไข่ดาว': FoodNutritionData(calories: 150, protein: 10, carbs: 1, fat: 12),
    
    // ฟาสต์ฟู้ด
    'พิซซ่า': FoodNutritionData(calories: 300, protein: 12, carbs: 35, fat: 14),
    'เบอร์เกอร์': FoodNutritionData(calories: 450, protein: 22, carbs: 40, fat: 22),
    'เฟรนช์ฟรายส์': FoodNutritionData(calories: 350, protein: 4, carbs: 45, fat: 17),
    'ไก่ทอดเคเอฟซี': FoodNutritionData(calories: 320, protein: 22, carbs: 18, fat: 20),
  };

  /// Alias สำหรับชื่อที่เขียนต่างกัน
  static final Map<String, String> _aliases = {
    'ข้าวมัน': 'ข้าวมันไก่',
    'มันไก่': 'ข้าวมันไก่',
    'หมูกระเพรา': 'กระเพราหมู',
    'ไก่กระเพรา': 'กระเพราไก่',
    'กะเพรา': 'ข้าวผัดกระเพรา',
    'ตำไทย': 'ส้มตำไทย',
    'ตำปู': 'ส้มตำปู',
    'ตำ': 'ส้มตำ',
    'ยำ': 'ยำวุ้นเส้น',
    'ก๋วยเตี๋ยวหมู': 'ก๋วยเตี๋ยว',
    'ก๋วยเตี๋ยวไก่': 'ก๋วยเตี๋ยว',
    'ก๋วยเตี๋ยวเนื้อ': 'ก๋วยเตี๋ยว',
    'ก๋วยเตี๋ยวลูกชิ้น': 'ก๋วยเตี๋ยว',
    'บะหมี่หมูแดง': 'บะหมี่',
    'บะหมี่เกี๊ยว': 'บะหมี่',
    'kfc': 'ไก่ทอดเคเอฟซี',
    'เคเอฟซี': 'ไก่ทอดเคเอฟซี',
  };

  /// ค้นหาข้อมูลอาหารจากชื่อ
  static FoodNutritionData? lookup(String foodName) {
    final normalized = foodName.trim().toLowerCase();
    
    // ลองหาจาก alias ก่อน
    if (_aliases.containsKey(normalized)) {
      final realName = _aliases[normalized]!;
      return _foods[realName];
    }
    
    // ลองหาตรงๆ
    for (var entry in _foods.entries) {
      if (entry.key.toLowerCase() == normalized) {
        return entry.value;
      }
    }
    
    // ลองหาแบบ contains
    for (var entry in _foods.entries) {
      if (normalized.contains(entry.key.toLowerCase()) || 
          entry.key.toLowerCase().contains(normalized)) {
        return entry.value;
      }
    }
    
    return null;
  }

  /// ค้นหาแบบ fuzzy (คำใกล้เคียง)
  static List<String> suggest(String query, {int limit = 5}) {
    final normalized = query.trim().toLowerCase();
    final suggestions = <MapEntry<String, int>>[];
    
    for (var name in _foods.keys) {
      final distance = _levenshtein(normalized, name.toLowerCase());
      suggestions.add(MapEntry(name, distance));
    }
    
    suggestions.sort((a, b) => a.value.compareTo(b.value));
    return suggestions.take(limit).map((e) => e.key).toList();
  }

  /// Levenshtein distance
  static int _levenshtein(String s1, String s2) {
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<int> prev = List.generate(s2.length + 1, (i) => i);
    List<int> curr = List.filled(s2.length + 1, 0);

    for (int i = 1; i <= s1.length; i++) {
      curr[0] = i;
      for (int j = 1; j <= s2.length; j++) {
        int cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        curr[j] = [
          prev[j] + 1,
          curr[j - 1] + 1,
          prev[j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
      List<int> temp = prev;
      prev = curr;
      curr = temp;
    }
    return prev[s2.length];
  }
}

/// ข้อมูลโภชนาการ
class FoodNutritionData {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const FoodNutritionData({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}
```

---

## Task 4: อัปเดต LLMService ให้ใช้ Food Database

### 📁 ไฟล์ที่ต้องแก้
`lib/core/ai/llm_service.dart`

### 📍 ส่วนที่ 1: เพิ่ม import
**ตำแหน่ง:** บรรทัดบนสุด (หลัง import อื่นๆ)

```dart
import '../data/thai_food_database.dart';
```

### 📍 ส่วนที่ 2: แก้ไข Health Detection ใน _localFallback
**ตำแหน่ง:** หาส่วน `// ========== 4. Health Detection ==========`

**แก้ไขส่วน Food ให้ใช้ database:**
```dart
// สำหรับ Food: ดึงข้อมูลเพิ่มเติม
if (category == 'Food') {
  // ดึงวันที่
  final now = DateTime.now();
  DateTime entryDate = now;
  if (lowerText.contains('เมื่อวาน')) {
    entryDate = now.subtract(const Duration(days: 1));
  } else if (lowerText.contains('เมื่อวานซืน')) {
    entryDate = now.subtract(const Duration(days: 2));
  }
  final dateStr = '${entryDate.year}-${entryDate.month.toString().padLeft(2, '0')}-${entryDate.day.toString().padLeft(2, '0')}';
  
  // ดึงมื้ออาหารจากข้อความ หรือใช้เวลาปัจจุบัน
  String mealType = _detectMealTypeFromText(lowerText, now.hour);
  
  // ดึงชื่ออาหาร
  String foodName = _extractFoodName(text);
  
  // ⭐ ค้นหาจาก Thai Food Database
  final foodData = ThaiFoodDatabase.lookup(foodName);
  
  // ดึง calories จากข้อความ หรือใช้จาก database
  double calories = _extractAmount(text)?.toDouble() ?? foodData?.calories ?? 0;
  double protein = foodData?.protein ?? 0;
  double carbs = foodData?.carbs ?? 0;
  double fat = foodData?.fat ?? 0;

  return jsonEncode({
    'type': 'health',
    'title': foodName,
    'category': 'Food',
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
    'date': dateStr,
    'meal_type': mealType,
  });
}
```

---

## Task 5: เพิ่ม Query Intent สำหรับถามข้อมูล

### 📁 ไฟล์ที่ต้องแก้
1. `lib/core/ai/llm_service.dart`
2. `lib/features/chat/services/intent_handler.dart`

### 📍 ส่วนที่ 1: เพิ่ม Query Detection ใน _localFallback
**ตำแหน่ง:** ใน `_localFallback()` หลัง Shopping List Detection

```dart
// ========== 1.5 Query Detection ==========
if (_containsAny(lowerText, ['วันนี้กินไป', 'กินไปกี่', 'ใช้ไปเท่าไหร่', 'ใช้เงินไป', 'สรุป', 'รวม', 'ทั้งหมด'])) {
  String queryType = 'unknown';
  String period = 'today';
  
  if (_containsAny(lowerText, ['กิน', 'แคล', 'อาหาร', 'calories'])) {
    queryType = 'calories';
  } else if (_containsAny(lowerText, ['เงิน', 'ใช้', 'จ่าย', 'รายจ่าย'])) {
    queryType = 'expense';
  }
  
  if (lowerText.contains('เดือนนี้') || lowerText.contains('เดือน')) {
    period = 'month';
  } else if (lowerText.contains('สัปดาห์') || lowerText.contains('อาทิตย์นี้')) {
    period = 'week';
  }
  
  return jsonEncode({
    'type': 'query',
    'query_type': queryType,
    'period': period,
    'title': text,
  });
}
```

### 📍 ส่วนที่ 2: เพิ่ม case ใน IntentHandler
**ตำแหน่ง:** ใน `processMessage()` switch statement

```dart
case 'query':
  return await _handleQuery(message, parsed);
```

### 📍 ส่วนที่ 3: เพิ่ม _handleQuery method
**ตำแหน่ง:** หลัง `_handleReminder` method

```dart
/// จัดการ Query Intent (ถามข้อมูล)
Future<IntentResponse> _handleQuery(
  String original,
  Map<String, dynamic> parsedData,
) async {
  final queryType = parsedData['query_type'] as String? ?? 'unknown';
  final period = parsedData['period'] as String? ?? 'today';
  
  debugPrint('🔍 [IntentHandler] Query: type=$queryType, period=$period');
  
  final now = DateTime.now();
  DateTime startDate;
  String periodText;
  
  switch (period) {
    case 'week':
      startDate = now.subtract(Duration(days: now.weekday - 1));
      periodText = 'สัปดาห์นี้';
      break;
    case 'month':
      startDate = DateTime(now.year, now.month, 1);
      periodText = 'เดือนนี้';
      break;
    default:
      startDate = DateTime(now.year, now.month, now.day);
      periodText = 'วันนี้';
  }
  
  if (queryType == 'calories') {
    // Query food entries
    final entries = await DatabaseService.foodEntries
        .filter()
        .timestampGreaterThan(startDate)
        .findAll();
    
    final totalCalories = entries.fold<double>(0, (sum, e) => sum + e.calories);
    final count = entries.length;
    
    return IntentResponse(
      replyMessage: '📊 **สรุปแคลอรี่$periodText**\n\n'
          '🔥 รวม: ${totalCalories.toInt()} kcal\n'
          '🍽️ จำนวน: $count มื้อ\n'
          '📈 เฉลี่ย: ${count > 0 ? (totalCalories / count).toInt() : 0} kcal/มื้อ',
      actionResult: null,
    );
  }
  
  if (queryType == 'expense') {
    // Query transactions
    final transactions = await DatabaseService.transactions
        .filter()
        .dateGreaterThan(startDate)
        .typeEqualTo(TransactionType.expense)
        .findAll();
    
    final totalExpense = transactions.fold<double>(0, (sum, t) => sum + t.amount);
    final count = transactions.length;
    
    return IntentResponse(
      replyMessage: '📊 **สรุปรายจ่าย$periodText**\n\n'
          '💸 รวม: ${totalExpense.toStringAsFixed(0)} บาท\n'
          '📝 จำนวน: $count รายการ\n'
          '📈 เฉลี่ย: ${count > 0 ? (totalExpense / count).toStringAsFixed(0) : 0} บาท/รายการ',
      actionResult: null,
    );
  }
  
  return IntentResponse(
    replyMessage: '🔍 ต้องการดูข้อมูลอะไรครับ?\n\n'
        'ลองถามว่า:\n'
        '• "วันนี้กินไปกี่แคล"\n'
        '• "เดือนนี้ใช้เงินไปเท่าไหร่"\n'
        '• "สรุปรายจ่ายสัปดาห์นี้"',
    actionResult: null,
  );
}
```

---

## Task 6: เพิ่ม Edit/Delete Intent (Optional)

### 📍 เพิ่ม Detection ใน _localFallback
```dart
// ========== 1.6 Edit/Delete Detection ==========
if (_containsAny(lowerText, ['แก้ไข', 'แก้', 'เปลี่ยน', 'อัปเดต'])) {
  return jsonEncode({
    'type': 'edit',
    'title': text,
  });
}

if (_containsAny(lowerText, ['ลบ', 'ยกเลิก', 'ลบทิ้ง'])) {
  return jsonEncode({
    'type': 'delete',
    'title': text,
  });
}
```

### 📍 เพิ่ม Handler (Placeholder)
```dart
case 'edit':
  return IntentResponse(
    replyMessage: '✏️ ฟีเจอร์แก้ไขกำลังพัฒนา\n\n'
        'ตอนนี้สามารถแก้ไขได้ที่หน้าข้อมูลโดยตรงครับ',
    actionResult: null,
  );

case 'delete':
  return IntentResponse(
    replyMessage: '🗑️ ฟีเจอร์ลบกำลังพัฒนา\n\n'
        'ตอนนี้สามารถลบได้ที่หน้าข้อมูลโดยตรงครับ',
    actionResult: null,
  );
```

---

## Testing Checklist

### ✅ Task 1: Local AI Only
- [ ] พิมพ์ "กินข้าวผัด" → บันทึกอาหารโดยไม่เรียก Gemini API
- [ ] พิมพ์ "จ่ายค่ากาแฟ 50 บาท" → บันทึกรายจ่ายโดยไม่เรียก Gemini API
- [ ] ดู Debug Console ไม่มี "Gemini response" หรือ API call

### ✅ Task 2: Gemini Button for Food
- [ ] เลือกรูปอาหาร → เห็นปุ่ม "วิเคราะห์ด้วย Gemini AI"
- [ ] ไม่กดปุ่ม → สามารถกรอกข้อมูลเองได้
- [ ] กดปุ่ม → วิเคราะห์และเติมข้อมูลอัตโนมัติ
- [ ] ไม่มี API Key → เห็นข้อความ "กรอกข้อมูลอาหารด้านล่าง..."

### ✅ Task 3: Food Database
- [ ] "กินข้าวผัด" → calories ≈ 450
- [ ] "กินส้มตำ" → calories ≈ 150
- [ ] "กินก๋วยเตี๋ยว" → calories ≈ 350
- [ ] "กินอาหารแปลกๆ" → calories = 0 (ไม่มีใน database)

### ✅ Task 4: Query Intent
- [ ] "วันนี้กินไปกี่แคล" → แสดงสรุปแคลอรี่วันนี้
- [ ] "เดือนนี้ใช้เงินไปเท่าไหร่" → แสดงสรุปรายจ่ายเดือนนี้
- [ ] "สรุปรายจ่ายสัปดาห์นี้" → แสดงสรุปรายจ่ายสัปดาห์นี้

---

## 📌 หมายเหตุสำคัญ

1. **อย่าลืม run build_runner** หลังแก้ไข model:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

2. **Test บน device จริง** เพราะ Windows ไม่รองรับบางฟีเจอร์

3. **ถ้าเจอ error** ให้ดู Debug Console และ copy error มาถามได้

4. **ลำดับการทำ:**
   - Task 1 → Task 2 → Task 3 → Task 4 → Testing
   - ทำทีละ Task และ test ก่อนไป Task ถัดไป

---

**สร้างโดย:** AI Assistant  
**วันที่:** 4 กุมภาพันธ์ 2026
