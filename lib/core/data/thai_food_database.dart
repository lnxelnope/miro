/// ฐานข้อมูลอาหารไทยสำหรับประมาณค่าโภชนาการ
class ThaiFoodDatabase {
  static final Map<String, FoodNutritionData> _foods = {
    // ข้าว
    'ข้าวผัด': const FoodNutritionData(calories: 450, protein: 12, carbs: 60, fat: 15),
    'ข้าวมันไก่': const FoodNutritionData(calories: 550, protein: 25, carbs: 65, fat: 18),
    'ข้าวหมูแดง': const FoodNutritionData(calories: 500, protein: 22, carbs: 60, fat: 16),
    'ข้าวหมูกรอบ': const FoodNutritionData(calories: 600, protein: 20, carbs: 65, fat: 25),
    'ข้าวขาหมู': const FoodNutritionData(calories: 650, protein: 28, carbs: 60, fat: 30),
    'ข้าวคลุกกะปิ': const FoodNutritionData(calories: 480, protein: 15, carbs: 55, fat: 20),
    'ข้าวผัดกระเพรา': const FoodNutritionData(calories: 520, protein: 22, carbs: 55, fat: 22),
    'ข้าวกระเพรา': const FoodNutritionData(calories: 520, protein: 22, carbs: 55, fat: 22),
    'กระเพราหมู': const FoodNutritionData(calories: 520, protein: 22, carbs: 55, fat: 22),
    'กระเพราไก่': const FoodNutritionData(calories: 480, protein: 25, carbs: 55, fat: 18),
    'ข้าวไข่เจียว': const FoodNutritionData(calories: 450, protein: 15, carbs: 50, fat: 20),
    'ข้าวไข่ดาว': const FoodNutritionData(calories: 400, protein: 14, carbs: 50, fat: 16),
    'ข้าวต้ม': const FoodNutritionData(calories: 200, protein: 8, carbs: 35, fat: 3),
    'โจ๊ก': const FoodNutritionData(calories: 250, protein: 10, carbs: 40, fat: 5),
    
    // ก๋วยเตี๋ยว
    'ก๋วยเตี๋ยว': const FoodNutritionData(calories: 350, protein: 15, carbs: 50, fat: 10),
    'ก๋วยเตี๋ยวน้ำใส': const FoodNutritionData(calories: 300, protein: 15, carbs: 45, fat: 8),
    'ก๋วยเตี๋ยวน้ำตก': const FoodNutritionData(calories: 380, protein: 18, carbs: 48, fat: 12),
    'ก๋วยเตี๋ยวเรือ': const FoodNutritionData(calories: 400, protein: 20, carbs: 50, fat: 14),
    'ก๋วยเตี๋ยวต้มยำ': const FoodNutritionData(calories: 350, protein: 16, carbs: 45, fat: 12),
    'บะหมี่': const FoodNutritionData(calories: 380, protein: 14, carbs: 55, fat: 12),
    'เส้นหมี่': const FoodNutritionData(calories: 320, protein: 12, carbs: 50, fat: 8),
    'ผัดไทย': const FoodNutritionData(calories: 450, protein: 15, carbs: 60, fat: 16),
    'ผัดซีอิ๊ว': const FoodNutritionData(calories: 420, protein: 14, carbs: 58, fat: 15),
    'ราดหน้า': const FoodNutritionData(calories: 500, protein: 18, carbs: 60, fat: 20),
    
    // ต้ม/แกง
    'ต้มยำกุ้ง': const FoodNutritionData(calories: 200, protein: 18, carbs: 15, fat: 8),
    'ต้มยำ': const FoodNutritionData(calories: 180, protein: 15, carbs: 15, fat: 7),
    'ต้มข่าไก่': const FoodNutritionData(calories: 280, protein: 18, carbs: 10, fat: 20),
    'แกงเขียวหวาน': const FoodNutritionData(calories: 350, protein: 20, carbs: 15, fat: 25),
    'แกงแดง': const FoodNutritionData(calories: 320, protein: 18, carbs: 15, fat: 22),
    'แกงมัสมั่น': const FoodNutritionData(calories: 400, protein: 22, carbs: 20, fat: 28),
    'แกงพะแนง': const FoodNutritionData(calories: 380, protein: 22, carbs: 15, fat: 26),
    'แกงส้ม': const FoodNutritionData(calories: 150, protein: 12, carbs: 18, fat: 5),
    'แกงจืด': const FoodNutritionData(calories: 120, protein: 10, carbs: 12, fat: 4),
    
    // ยำ/สลัด
    'ส้มตำ': const FoodNutritionData(calories: 150, protein: 5, carbs: 25, fat: 4),
    'ส้มตำไทย': const FoodNutritionData(calories: 150, protein: 5, carbs: 25, fat: 4),
    'ส้มตำปู': const FoodNutritionData(calories: 180, protein: 8, carbs: 25, fat: 6),
    'ยำวุ้นเส้น': const FoodNutritionData(calories: 200, protein: 12, carbs: 30, fat: 5),
    'ยำหมูยอ': const FoodNutritionData(calories: 250, protein: 15, carbs: 20, fat: 12),
    'ลาบ': const FoodNutritionData(calories: 200, protein: 18, carbs: 10, fat: 10),
    'น้ำตก': const FoodNutritionData(calories: 220, protein: 20, carbs: 10, fat: 12),
    
    // ผัด
    'ผัดผัก': const FoodNutritionData(calories: 150, protein: 5, carbs: 15, fat: 8),
    'ผัดคะน้า': const FoodNutritionData(calories: 180, protein: 8, carbs: 12, fat: 12),
    'ผัดบวบ': const FoodNutritionData(calories: 120, protein: 5, carbs: 10, fat: 8),
    'ผัดถั่วงอก': const FoodNutritionData(calories: 140, protein: 6, carbs: 12, fat: 8),
    
    // ทอด/ปิ้ง/ย่าง
    'ไก่ทอด': const FoodNutritionData(calories: 350, protein: 25, carbs: 15, fat: 22),
    'หมูทอด': const FoodNutritionData(calories: 380, protein: 22, carbs: 15, fat: 26),
    'ปลาทอด': const FoodNutritionData(calories: 300, protein: 28, carbs: 12, fat: 16),
    'ไก่ย่าง': const FoodNutritionData(calories: 280, protein: 28, carbs: 5, fat: 16),
    'หมูปิ้ง': const FoodNutritionData(calories: 200, protein: 18, carbs: 8, fat: 12),
    'ไส้กรอก': const FoodNutritionData(calories: 250, protein: 12, carbs: 5, fat: 20),
    
    // ของหวาน
    'ไอศกรีม': const FoodNutritionData(calories: 200, protein: 4, carbs: 25, fat: 10),
    'ขนมหวาน': const FoodNutritionData(calories: 250, protein: 3, carbs: 40, fat: 8),
    'บัวลอย': const FoodNutritionData(calories: 180, protein: 2, carbs: 35, fat: 4),
    'ขนมครก': const FoodNutritionData(calories: 150, protein: 2, carbs: 20, fat: 7),
    'กล้วยบวชชี': const FoodNutritionData(calories: 200, protein: 2, carbs: 35, fat: 6),
    'ข้าวเหนียวมะม่วง': const FoodNutritionData(calories: 400, protein: 5, carbs: 70, fat: 12),
    
    // เครื่องดื่ม
    'ชาเย็น': const FoodNutritionData(calories: 180, protein: 2, carbs: 35, fat: 5),
    'กาแฟเย็น': const FoodNutritionData(calories: 150, protein: 2, carbs: 28, fat: 5),
    'น้ำอัดลม': const FoodNutritionData(calories: 140, protein: 0, carbs: 35, fat: 0),
    'น้ำผลไม้': const FoodNutritionData(calories: 120, protein: 0, carbs: 30, fat: 0),
    'นมเย็น': const FoodNutritionData(calories: 160, protein: 6, carbs: 20, fat: 6),
    'ชาเขียว': const FoodNutritionData(calories: 120, protein: 1, carbs: 28, fat: 1),
    'โอวัลติน': const FoodNutritionData(calories: 180, protein: 5, carbs: 30, fat: 5),
    
    // อาหารเช้า
    'โทสต์': const FoodNutritionData(calories: 200, protein: 5, carbs: 35, fat: 5),
    'ขนมปังปิ้ง': const FoodNutritionData(calories: 200, protein: 5, carbs: 35, fat: 5),
    'ไข่ต้ม': const FoodNutritionData(calories: 80, protein: 6, carbs: 1, fat: 5),
    'ไข่เจียว': const FoodNutritionData(calories: 180, protein: 12, carbs: 2, fat: 14),
    'ไข่ดาว': const FoodNutritionData(calories: 150, protein: 10, carbs: 1, fat: 12),
    
    // ฟาสต์ฟู้ด
    'พิซซ่า': const FoodNutritionData(calories: 300, protein: 12, carbs: 35, fat: 14),
    'เบอร์เกอร์': const FoodNutritionData(calories: 450, protein: 22, carbs: 40, fat: 22),
    'เฟรนช์ฟรายส์': const FoodNutritionData(calories: 350, protein: 4, carbs: 45, fat: 17),
    'ไก่ทอดเคเอฟซี': const FoodNutritionData(calories: 320, protein: 22, carbs: 18, fat: 20),
  };

  /// Alias สำหรับชื่อที่เขียนต่างกัน (ภาษาไทย)
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

  /// English aliases → map ไปหา key ภาษาไทย
  static final Map<String, String> _englishAliases = {
    'fried rice': 'ข้าวผัด',
    'chicken rice': 'ข้าวมันไก่',
    'pad thai': 'ผัดไทย',
    'tom yum': 'ต้มยำ',
    'tom yum goong': 'ต้มยำกุ้ง',
    'tom yum shrimp': 'ต้มยำกุ้ง',
    'green curry': 'แกงเขียวหวาน',
    'red curry': 'แกงแดง',
    'massaman curry': 'แกงมัสมั่น',
    'pad kra pao': 'ผัดกระเพรา',
    'basil stir fry': 'ผัดกระเพรา',
    'sticky rice': 'ข้าวเหนียว',
    'papaya salad': 'ส้มตำ',
    'som tam': 'ส้มตำ',
    'mango sticky rice': 'ข้าวเหนียวมะม่วง',
    'spring roll': 'ปอเปี๊ยะ',
    'satay': 'สะเต๊ะ',
    'larb': 'ลาบ',
    'khao soi': 'ข้าวซอย',
    'boat noodles': 'ก๋วยเตี๋ยวเรือ',
    'pad see ew': 'ผัดซีอิ๊ว',
    'thai tea': 'ชาไทย',
    'thai iced tea': 'ชาเย็น',
    'thai iced coffee': 'กาแฟเย็น',
    'noodle soup': 'ก๋วยเตี๋ยว',
    'rice soup': 'ข้าวต้ม',
    'congee': 'โจ๊ก',
    'fried chicken': 'ไก่ทอด',
    'grilled chicken': 'ไก่ย่าง',
    'pork skewer': 'หมูปิ้ง',
    'ice cream': 'ไอศกรีม',
    'toast': 'โทสต์',
    'fried egg': 'ไข่เจียว',
    'sunny side up': 'ไข่ดาว',
    'boiled egg': 'ไข่ต้ม',
    'pizza': 'พิซซ่า',
    'burger': 'เบอร์เกอร์',
    'french fries': 'เฟรนช์ฟรายส์',
    'kfc chicken': 'ไก่ทอดเคเอฟซี',
  };

  /// ค้นหาข้อมูลอาหารจากชื่อ — รองรับทั้งไทยและอังกฤษ
  static FoodNutritionData? lookup(String foodName) {
    final normalized = foodName.trim().toLowerCase();
    
    // ลองหาจาก alias ภาษาไทยก่อน
    if (_aliases.containsKey(normalized)) {
      final realName = _aliases[normalized]!;
      return _foods[realName];
    }
    
    // ลองหาจาก English aliases
    if (_englishAliases.containsKey(normalized)) {
      final thaiKey = _englishAliases[normalized]!;
      return _foods[thaiKey];
    }
    
    // ลองหาตรงๆ (ภาษาไทย)
    for (var entry in _foods.entries) {
      if (entry.key.toLowerCase() == normalized) {
        return entry.value;
      }
    }
    
    // ลองหาแบบ contains (ภาษาไทย)
    for (var entry in _foods.entries) {
      if (normalized.contains(entry.key.toLowerCase()) || 
          entry.key.toLowerCase().contains(normalized)) {
        return entry.value;
      }
    }
    
    // ลองหาแบบ contains (English aliases)
    for (var alias in _englishAliases.entries) {
      if (alias.key.contains(normalized) || normalized.contains(alias.key)) {
        return _foods[alias.value];
      }
    }
    
    return null;
  }

  /// ค้นหาอาหารที่ชื่อ contains query → คืน Map ของ name → nutrition (รองรับทั้ง TH + EN)
  static Map<String, FoodNutritionData> search(String query, {int limit = 10}) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return {};
    final results = <String, FoodNutritionData>{};
    
    // ค้นจาก Thai
    for (final entry in _foods.entries) {
      if (entry.key.toLowerCase().contains(normalized) ||
          normalized.contains(entry.key.toLowerCase())) {
        results[entry.key] = entry.value;
        if (results.length >= limit) break;
      }
    }
    
    // ค้นจาก English aliases
    for (final alias in _englishAliases.entries) {
      if (alias.key.contains(normalized)) {
        final data = _foods[alias.value];
        if (data != null && !results.containsKey(alias.value)) {
          results[alias.value] = data; // ใช้ชื่อไทยเป็น key
          if (results.length >= limit) break;
        }
      }
    }
    
    return results;
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
