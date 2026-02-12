// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class L10nTh extends L10n {
  L10nTh([String locale = 'th']) : super(locale);

  @override
  String get appName => 'Miro Cal';

  @override
  String get save => 'บันทึก';

  @override
  String get cancel => 'ยกเลิก';

  @override
  String get delete => 'ลบ';

  @override
  String get edit => 'แก้ไข';

  @override
  String get search => 'ค้นหา';

  @override
  String get loading => 'กำลังโหลด...';

  @override
  String get error => 'เกิดข้อผิดพลาด';

  @override
  String get confirm => 'ยืนยัน';

  @override
  String get close => 'ปิด';

  @override
  String get done => 'เสร็จ';

  @override
  String get next => 'ถัดไป';

  @override
  String get skip => 'ข้าม';

  @override
  String get retry => 'ลองใหม่';

  @override
  String get ok => 'ตกลง';

  @override
  String get foodName => 'ชื่ออาหาร';

  @override
  String get calories => 'แคลอรี่';

  @override
  String get protein => 'โปรตีน';

  @override
  String get carbs => 'คาร์บ';

  @override
  String get fat => 'ไขมัน';

  @override
  String get servingSize => 'ปริมาณ';

  @override
  String get servingUnit => 'หน่วย';

  @override
  String get kcal => 'kcal';

  @override
  String get mealBreakfast => 'เช้า';

  @override
  String get mealLunch => 'กลางวัน';

  @override
  String get mealDinner => 'เย็น';

  @override
  String get mealSnack => 'ของว่าง';

  @override
  String get todaySummary => 'สรุปวันนี้';

  @override
  String dateSummary(String date) {
    return 'สรุป $date';
  }

  @override
  String get savedSuccess => 'บันทึกเรียบร้อย';

  @override
  String get deletedSuccess => 'ลบเรียบร้อย';

  @override
  String get pleaseEnterFoodName => 'กรุณากรอกชื่ออาหาร';

  @override
  String get noDataYet => 'ยังไม่มีข้อมูล';

  @override
  String get addFood => 'เพิ่มอาหาร';

  @override
  String get editFood => 'แก้ไขอาหาร';

  @override
  String get deleteFood => 'ลบอาหาร';

  @override
  String get deleteConfirm => 'ยืนยันการลบ?';

  @override
  String get foodLoggedSuccess => 'บันทึกอาหารแล้ว!';

  @override
  String get noApiKey => 'กรุณาตั้งค่า Gemini API Key';

  @override
  String get noApiKeyDescription => 'ไปที่ โปรไฟล์ → API Settings เพื่อตั้งค่า';

  @override
  String get apiKeyTitle => 'ตั้งค่า Gemini API Key';

  @override
  String get apiKeyRequired => 'ต้องการ API Key';

  @override
  String get apiKeyFreeNote => 'Gemini API ใช้ฟรี ไม่ต้องจ่ายเงิน';

  @override
  String get apiKeySetup => 'ตั้งค่า API Key';

  @override
  String get testConnection => 'ทดสอบการเชื่อมต่อ';

  @override
  String get connectionSuccess => 'เชื่อมต่อสำเร็จ! พร้อมใช้งาน';

  @override
  String get connectionFailed => 'เชื่อมต่อไม่สำเร็จ';

  @override
  String get pasteKey => 'วาง';

  @override
  String get deleteKey => 'ลบ API Key';

  @override
  String get openAiStudio => 'เปิด Google AI Studio';

  @override
  String get chatHint => 'สั่ง Miro เช่น \"บันทึกข้าวผัด\"...';

  @override
  String get chatFoodSaved => 'บันทึกอาหารแล้ว!';

  @override
  String chatFoodSavedDetail(
      String name, String serving, String unit, String cal) {
    return '$name $serving $unit\n$cal kcal';
  }

  @override
  String get featureNotAvailable =>
      'ขออภัย ฟังก์ชันนี้ยังไม่พร้อมในเวอร์ชันนี้';

  @override
  String get goalCalories => 'แคลอรี่/วัน';

  @override
  String get goalProtein => 'โปรตีน/วัน';

  @override
  String get goalCarbs => 'คาร์บ/วัน';

  @override
  String get goalFat => 'ไขมัน/วัน';

  @override
  String get goalWater => 'น้ำ/วัน';

  @override
  String get healthGoals => 'เป้าหมายสุขภาพ';

  @override
  String get profile => 'โปรไฟล์';

  @override
  String get settings => 'การตั้งค่า';

  @override
  String get privacyPolicy => 'นโยบายความเป็นส่วนตัว';

  @override
  String get termsOfService => 'เงื่อนไขการใช้งาน';

  @override
  String get clearAllData => 'ล้างข้อมูลทั้งหมด';

  @override
  String get clearAllDataConfirm => 'ข้อมูลทั้งหมดจะถูกลบ ลบแล้วกู้คืนไม่ได้!';

  @override
  String get about => 'เกี่ยวกับแอป';

  @override
  String get language => 'ภาษา';

  @override
  String get upgradePro => 'อัปเกรด Pro';

  @override
  String get proUnlocked => 'Miro Cal Pro';

  @override
  String get proDescription => 'ใช้ AI วิเคราะห์อาหารไม่จำกัด';

  @override
  String aiRemaining(int remaining, int total) {
    return 'AI วิเคราะห์: เหลือ $remaining/$total ครั้งวันนี้';
  }

  @override
  String get aiLimitReached => 'ใช้ AI ครบ 3 ครั้งแล้ววันนี้';

  @override
  String get restorePurchase => 'กู้คืนการซื้อ';

  @override
  String get myMeals => 'เมนูของฉัน';

  @override
  String get createMeal => 'สร้างเมนู';

  @override
  String get ingredients => 'วัตถุดิบ';

  @override
  String get addIngredient => 'เพิ่มวัตถุดิบ';

  @override
  String get searchFood => 'ค้นหาอาหาร';

  @override
  String get analyzing => 'กำลังวิเคราะห์...';

  @override
  String get analyzeWithAi => 'วิเคราะห์ด้วย AI';

  @override
  String get analysisComplete => 'วิเคราะห์เสร็จ';

  @override
  String get timeline => 'Timeline';

  @override
  String get diet => 'Diet';

  @override
  String get quickAdd => 'Quick Add';

  @override
  String get welcomeTitle => 'Miro Cal';

  @override
  String get welcomeSubtitle => 'บันทึกอาหารง่ายๆ ด้วย AI';

  @override
  String get onboardingFeature1 => 'ถ่ายรูปอาหาร';

  @override
  String get onboardingFeature1Desc => 'AI วิเคราะห์ kcal อัตโนมัติ';

  @override
  String get onboardingFeature2 => 'พิมพ์แชท';

  @override
  String get onboardingFeature2Desc => 'บอกว่า \"กินข้าวผัด\" → บันทึกให้เลย';

  @override
  String get onboardingFeature3 => 'สรุปทุกวัน';

  @override
  String get onboardingFeature3Desc => 'ดู kcal, โปรตีน, คาร์บ, ไขมัน';

  @override
  String get basicInfo => 'ข้อมูลพื้นฐาน';

  @override
  String get basicInfoDesc => 'เพื่อคำนวณเป้าหมายแคลอรี่ที่เหมาะกับคุณ';

  @override
  String get gender => 'เพศ';

  @override
  String get male => 'ชาย';

  @override
  String get female => 'หญิง';

  @override
  String get age => 'อายุ';

  @override
  String get weight => 'น้ำหนัก';

  @override
  String get height => 'ส่วนสูง';

  @override
  String get activityLevel => 'ระดับกิจกรรม';

  @override
  String tdeeResult(int kcal) {
    return 'TDEE ของคุณ: $kcal kcal/วัน';
  }

  @override
  String get setupAiTitle => 'ตั้งค่า Gemini AI';

  @override
  String get setupAiDesc => 'ถ่ายรูปอาหาร → AI วิเคราะห์ให้อัตโนมัติ';

  @override
  String get setupNow => 'ตั้งค่าเลย';

  @override
  String get skipForNow => 'ข้ามไปก่อน → เข้าแอป';

  @override
  String get errorTimeout => 'หมดเวลาเชื่อมต่อ — ลองใหม่อีกครั้ง';

  @override
  String get errorInvalidKey => 'API Key ไม่ถูกต้อง — ตรวจสอบการตั้งค่า';

  @override
  String get errorNoInternet => 'ไม่มีอินเทอร์เน็ต — ตรวจสอบการเชื่อมต่อ';

  @override
  String get errorGeneral => 'เกิดข้อผิดพลาด — ลองใหม่อีกครั้ง';

  @override
  String get errorQuotaExceeded => 'ใช้ API เกินโควต้า — รอสักครู่แล้วลองใหม่';

  @override
  String get apiKeyScreenTitle => 'ตั้งค่า Gemini API Key';

  @override
  String get analyzeFoodWithAi => 'วิเคราะห์อาหารด้วย AI';

  @override
  String get analyzeFoodWithAiDesc =>
      'ถ่ายรูปอาหาร → AI คำนวณแคลอรี่ให้อัตโนมัติ\nGemini API ใช้ฟรี ไม่ต้องจ่ายเงิน!';

  @override
  String get openGoogleAiStudio => 'เปิด Google AI Studio';

  @override
  String get step1Title => 'เปิด Google AI Studio';

  @override
  String get step1Desc => 'กดปุ่มด้านล่างเพื่อไปสร้าง API Key';

  @override
  String get step2Title => 'ล็อกอิน Google Account';

  @override
  String get step2Desc =>
      'ใช้ Gmail หรือ Google Account ที่มีอยู่ (ถ้ายังไม่มี สร้างฟรี)';

  @override
  String get step3Title => 'คลิก \"Create API Key\"';

  @override
  String get step3Desc =>
      'กดปุ่มสีน้ำเงิน \"Create API Key\"\nถ้าถามให้เลือก Project → กด \"Create API key in new project\"';

  @override
  String get step4Title => 'คัดลอก Key แล้วกลับมาวางด้านล่าง';

  @override
  String get step4Desc =>
      'กดปุ่ม Copy ข้างกล่อง Key ที่สร้างเสร็จ\nKey จะหน้าตาประมาณ: AIzaSyxxxx...';

  @override
  String get step5Title => 'วาง API Key ที่นี่';

  @override
  String get pasteApiKeyHint => 'วาง API Key ที่คัดลอกมา';

  @override
  String get saveApiKey => 'บันทึก API Key';

  @override
  String get testingConnection => 'กำลังทดสอบ...';

  @override
  String get deleteApiKey => 'ลบ API Key';

  @override
  String get deleteApiKeyConfirm => 'ลบ API Key?';

  @override
  String get deleteApiKeyConfirmDesc =>
      'จะไม่สามารถใช้ AI วิเคราะห์อาหารได้จนกว่าจะตั้งค่าใหม่';

  @override
  String get apiKeySaved => 'บันทึก API Key เรียบร้อย';

  @override
  String get apiKeyDeleted => 'ลบ API Key เรียบร้อย';

  @override
  String get pleasePasteApiKey => 'กรุณาวาง API Key ก่อน';

  @override
  String get apiKeyInvalidFormat =>
      'API Key ไม่ถูกต้อง — ต้องขึ้นต้นด้วย \"AIza\"';

  @override
  String get connectionSuccessMessage => '✅ เชื่อมต่อสำเร็จ! พร้อมใช้งาน';

  @override
  String get connectionFailedMessage => '❌ เชื่อมต่อไม่สำเร็จ';

  @override
  String get faqTitle => 'คำถามที่พบบ่อย';

  @override
  String get faqFreeQuestion => 'ฟรีจริงไหม?';

  @override
  String get faqFreeAnswer =>
      'ฟรีจริง! Gemini 2.0 Flash ใช้ฟรี 1,500 ครั้ง/วัน\nสำหรับบันทึกอาหาร (5-15 ครั้ง/วัน) → ฟรีตลอด ไม่ต้องจ่ายเงิน';

  @override
  String get faqSafeQuestion => 'ปลอดภัยไหม?';

  @override
  String get faqSafeAnswer =>
      'API Key เก็บใน Secure Storage ในเครื่องเท่านั้น\nแอปไม่ส่ง Key ไปที่ server ของเรา\nถ้า Key หลุด → ลบทิ้งสร้างใหม่ได้เลย (ไม่ใช่รหัสผ่าน Google)';

  @override
  String get faqNoKeyQuestion => 'ถ้าไม่สร้าง Key ล่ะ?';

  @override
  String get faqNoKeyAnswer =>
      'ยังใช้แอปได้! แต่:\n❌ ไม่สามารถถ่ายรูป → AI วิเคราะห์\n✅ บันทึกอาหารด้วยมือได้\n✅ Quick Add ได้\n✅ ดูสรุป kcal/macro ได้';

  @override
  String get faqCreditCardQuestion => 'ต้องมีบัตรเครดิตไหม?';

  @override
  String get faqCreditCardAnswer =>
      'ไม่ต้อง — สร้าง API Key ได้ฟรีโดยไม่ต้องใส่บัตรเครดิต';
}
