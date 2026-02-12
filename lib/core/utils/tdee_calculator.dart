/// คำนวณ TDEE (Total Daily Energy Expenditure)
/// ใช้สูตร Mifflin-St Jeor — สูตรที่แม่นยำที่สุดในปัจจุบัน
class TdeeCalculator {
  /// คำนวณ BMR (Basal Metabolic Rate)
  ///
  /// สูตร Mifflin-St Jeor:
  /// - ชาย:  BMR = 10 × น้ำหนัก(kg) + 6.25 × ส่วนสูง(cm) - 5 × อายุ + 5
  /// - หญิง: BMR = 10 × น้ำหนัก(kg) + 6.25 × ส่วนสูง(cm) - 5 × อายุ - 161
  static double calculateBMR({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender, // 'male' หรือ 'female'
  }) {
    final base = (10 * weightKg) + (6.25 * heightCm) - (5 * age);
    return gender == 'male' ? base + 5 : base - 161;
  }

  /// ตัวคูณกิจกรรม
  static double activityMultiplier(String level) {
    switch (level) {
      case 'sedentary':    return 1.2;    // นั่งทั้งวัน
      case 'light':        return 1.375;  // ออกกำลังกายเบาๆ 1-3 วัน/สัปดาห์
      case 'moderate':     return 1.55;   // ออกกำลังกาย 3-5 วัน/สัปดาห์
      case 'active':       return 1.725;  // ออกกำลังกายหนัก 6-7 วัน/สัปดาห์
      case 'very_active':  return 1.9;    // ออกกำลังกายหนักมาก + งานที่ต้องใช้แรง
      default:             return 1.55;   // default: ปานกลาง
    }
  }

  /// คำนวณ TDEE
  static double calculateTDEE({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
    required String activityLevel,
  }) {
    final bmr = calculateBMR(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      gender: gender,
    );
    return bmr * activityMultiplier(activityLevel);
  }

  /// แนะนำเป้าหมาย kcal ตามเป้าหมาย
  static Map<String, int> suggestGoals({
    required double tdee,
  }) {
    return {
      'maintain': tdee.round(),              // รักษาน้ำหนัก
      'mild_loss': (tdee - 250).round(),     // ลดช้า (-0.25 kg/สัปดาห์)
      'loss': (tdee - 500).round(),          // ลด (-0.5 kg/สัปดาห์)
      'mild_gain': (tdee + 250).round(),     // เพิ่มช้า
      'gain': (tdee + 500).round(),          // เพิ่ม (+0.5 kg/สัปดาห์)
    };
  }

  /// แนะนำ Macro % (default)
  static Map<String, int> defaultMacroPercent() {
    return {
      'protein': 30,  // 30% protein
      'carbs': 40,    // 40% carbs
      'fat': 30,      // 30% fat
    };
  }

  /// ชื่อกิจกรรมภาษาไทย (สำหรับ dropdown)
  static List<Map<String, String>> activityLevels = [
    {'key': 'sedentary',   'th': 'นั่งทั้งวัน (ไม่ออกกำลังกาย)',     'en': 'Sedentary'},
    {'key': 'light',       'th': 'ออกกำลังกายเบา (1-3 วัน/สัปดาห์)', 'en': 'Lightly Active'},
    {'key': 'moderate',    'th': 'ออกกำลังกายปานกลาง (3-5 วัน)',     'en': 'Moderately Active'},
    {'key': 'active',      'th': 'ออกกำลังกายหนัก (6-7 วัน)',        'en': 'Very Active'},
    {'key': 'very_active', 'th': 'หนักมาก + งานใช้แรง',             'en': 'Extra Active'},
  ];
}
