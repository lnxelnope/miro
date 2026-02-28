// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class L10nTh extends L10n {
  L10nTh([String locale = 'th']) : super(locale);

  @override
  String get appName => 'MiRO';

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
  String get nutritionSummary => 'สรุปโภชนาการ';

  @override
  String dateSummary(String date) {
    return 'สรุป $date';
  }

  @override
  String get periodAll => 'ทั้งหมด';

  @override
  String get macroDistribution => 'การกระจายสารอาหารหลัก';

  @override
  String get calorieTrend => 'แนวโน้มแคลอรี่';

  @override
  String get calorieTrend7Days => 'แนวโน้มแคลอรี่ (7 วัน)';

  @override
  String get micronutrientTracker => 'ติดตามสารอาหารรอง';

  @override
  String get fatBreakdown => 'การแยกไขมัน';

  @override
  String get goal => 'เป้าหมาย';

  @override
  String get over => 'เกิน';

  @override
  String get saturated => 'อิ่มตัว';

  @override
  String get mono => 'โมโน';

  @override
  String get poly => 'โพลี';

  @override
  String get trans => 'ทรานส์';

  @override
  String noDataFor(String title) {
    return 'ไม่มีข้อมูลสำหรับ $title';
  }

  @override
  String errorColon(String error) {
    return 'ข้อผิดพลาด: $error';
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
  String get proUnlocked => 'MiRO Pro';

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
  String get myMeals => 'อาหารของฉัน:';

  @override
  String get createMeal => 'สร้างเมนู';

  @override
  String get ingredients => 'ส่วนประกอบ';

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
  String get welcomeTitle => 'MiRO';

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

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navMyMeals => 'เมนูของฉัน';

  @override
  String get navCamera => 'กล้อง';

  @override
  String get navGallery => 'แกลเลอรี';

  @override
  String get navAiChat => 'แชท AI';

  @override
  String get navProfile => 'โปรไฟล์';

  @override
  String get appBarTodayIntake => 'สรุปวันนี้';

  @override
  String get appBarMyMeals => 'เมนูของฉัน';

  @override
  String get appBarCamera => 'กล้อง';

  @override
  String get appBarAiChat => 'แชท AI';

  @override
  String get appBarMiro => 'MIRO';

  @override
  String get permissionRequired => 'ต้องการสิทธิ์';

  @override
  String get permissionRequiredDesc => 'MIRO ต้องการเข้าถึง:';

  @override
  String get permissionPhotos => 'รูปภาพ — เพื่อสแกนอาหาร';

  @override
  String get permissionCamera => 'กล้อง — เพื่อถ่ายรูปอาหาร';

  @override
  String get permissionSkip => 'ข้าม';

  @override
  String get permissionAllow => 'อนุญาต';

  @override
  String get permissionAllGranted => 'ได้รับสิทธิ์ทั้งหมดแล้ว';

  @override
  String permissionDenied(String denied) {
    return 'ปฏิเสธสิทธิ์: $denied';
  }

  @override
  String get openSettings => 'เปิดการตั้งค่า';

  @override
  String get exitAppTitle => 'ออกจากแอป?';

  @override
  String get exitAppMessage => 'คุณแน่ใจหรือไม่ว่าต้องการออก?';

  @override
  String get exit => 'ออก';

  @override
  String get healthGoalsTitle => 'เป้าหมายสุขภาพ';

  @override
  String get healthGoalsInfo =>
      'ตั้งเป้าหมายแคลอรี่รายวัน แมโคร และงบประมาณต่อมื้อ\nล็อคเพื่อคำนวณอัตโนมัติ: 2 แมโคร หรือ 3 มื้อ';

  @override
  String get dailyCalorieGoal => 'เป้าหมายแคลอรี่รายวัน';

  @override
  String get proteinLabel => 'โปรตีน';

  @override
  String get carbsLabel => 'คาร์บ';

  @override
  String get fatLabel => 'ไขมัน';

  @override
  String get autoBadge => 'auto';

  @override
  String kcalPerGram(int kcalPerGram, int kcal) {
    return '$kcalPerGram kcal/g • $kcal kcal';
  }

  @override
  String get mealCalorieBudget => 'งบประมาณแคลอรี่ต่อมื้อ';

  @override
  String mealBudgetBalanced(int total, int goal) {
    return 'รวม $total kcal = เป้าหมาย $goal kcal';
  }

  @override
  String mealBudgetRemaining(int total, int goal, int remaining) {
    return 'รวม $total / $goal kcal  (เหลือ $remaining)';
  }

  @override
  String get lockMealsHint => 'ล็อค 3 มื้อเพื่อคำนวณมื้อที่ 4 อัตโนมัติ';

  @override
  String get breakfastLabel => 'เช้า';

  @override
  String get lunchLabel => 'กลางวัน';

  @override
  String get dinnerLabel => 'เย็น';

  @override
  String get snackLabel => 'ของว่าง';

  @override
  String percentOfDailyGoal(String percent) {
    return '$percent% ของเป้าหมายรายวัน';
  }

  @override
  String get smartSuggestionRange => 'ช่วงคำแนะนำอัจฉริยะ';

  @override
  String get smartSuggestionHow => 'Smart Suggestion ทำงานอย่างไร?';

  @override
  String smartSuggestionDesc(int threshold, int min, int max) {
    return 'เราจะแนะนำอาหารจากเมนูของฉัน วัตถุดิบ และอาหารเมื่อวานที่เหมาะกับงบประมาณต่อมื้อของคุณ\n\nค่า threshold นี้ควบคุมความยืดหยุ่นของคำแนะนำ ตัวอย่างเช่น ถ้างบประมาณมื้อกลางวันของคุณคือ 700 kcal และ threshold คือ $threshold kcal เราจะแนะนำอาหารระหว่าง $min–$max kcal';
  }

  @override
  String get suggestionThreshold => 'ค่า Threshold คำแนะนำ';

  @override
  String suggestionThresholdDesc(int threshold) {
    return 'อนุญาตอาหาร ± $threshold kcal จากงบประมาณมื้อ';
  }

  @override
  String get goalsSavedSuccess => 'บันทึกเป้าหมายสำเร็จ!';

  @override
  String get canOnlyLockTwoMacros => 'ล็อคได้แค่ 2 แมโครพร้อมกัน';

  @override
  String get canOnlyLockThreeMeals =>
      'ล็อคได้แค่ 3 มื้อ มื้อที่ 4 จะคำนวณอัตโนมัติ';

  @override
  String get tabMeals => 'เมนู';

  @override
  String get tabIngredients => 'วัตถุดิบ';

  @override
  String get searchMealsOrIngredients => 'ค้นหาเมนูหรือวัตถุดิบ...';

  @override
  String get createNewMeal => 'สร้างเมนูใหม่';

  @override
  String get addIngredient => 'เพิ่มวัตถุดิบ';

  @override
  String get noMealsYet => 'ยังไม่มีเมนู';

  @override
  String get noMealsYetDesc =>
      'วิเคราะห์อาหารด้วย AI เพื่อบันทึกเมนูอัตโนมัติ\nหรือสร้างด้วยมือ';

  @override
  String get noIngredientsYet => 'ยังไม่มีวัตถุดิบ';

  @override
  String get noIngredientsYetDesc =>
      'เมื่อคุณวิเคราะห์อาหารด้วย AI\nวัตถุดิบจะถูกบันทึกอัตโนมัติ';

  @override
  String mealCreated(String name) {
    return 'สร้าง \"$name\" แล้ว';
  }

  @override
  String mealLogged(String name) {
    return 'บันทึก \"$name\" แล้ว';
  }

  @override
  String ingredientAmount(String unit) {
    return 'ปริมาณ ($unit)';
  }

  @override
  String ingredientLogged(String name, String amount, String unit) {
    return 'บันทึก \"$name\" $amount$unit แล้ว';
  }

  @override
  String get mealNotFound => 'ไม่พบเมนู';

  @override
  String mealUpdated(String name) {
    return 'อัพเดท \"$name\" แล้ว';
  }

  @override
  String get deleteMealTitle => 'ลบเมนู?';

  @override
  String deleteMealMessage(String name) {
    return '\"$name\"';
  }

  @override
  String get deleteMealNote => 'วัตถุดิบจะไม่ถูกลบ';

  @override
  String get mealDeleted => 'ลบเมนูแล้ว';

  @override
  String ingredientCreated(String name) {
    return 'สร้าง \"$name\" แล้ว';
  }

  @override
  String get ingredientNotFound => 'ไม่พบวัตถุดิบ';

  @override
  String ingredientUpdated(String name) {
    return 'อัพเดท \"$name\" แล้ว';
  }

  @override
  String get deleteIngredientTitle => 'ลบวัตถุดิบ?';

  @override
  String deleteIngredientMessage(String name) {
    return '\"$name\"';
  }

  @override
  String get ingredientDeleted => 'ลบวัตถุดิบแล้ว';

  @override
  String get noIngredientsData => 'ไม่มีข้อมูลวัตถุดิบ';

  @override
  String ingredientDetail(String name, String amount, String unit) {
    return '$name ($amount $unit)';
  }

  @override
  String ingredientCalories(int calories) {
    return '$calories kcal';
  }

  @override
  String get useThisMeal => 'ใช้เมนูนี้';

  @override
  String errorLoading(String error) {
    return 'เกิดข้อผิดพลาดในการโหลด: $error';
  }

  @override
  String scanFoundNewImages(int count, String date) {
    return 'พบรูปภาพใหม่ $count รูปใน $date';
  }

  @override
  String scanNoNewImages(String date) {
    return 'ไม่พบรูปภาพใหม่ใน $date';
  }

  @override
  String aiAnalysisRemaining(int remaining, int total) {
    return 'AI Analysis: เหลือ $remaining/$total ครั้งวันนี้';
  }

  @override
  String get upgradeToProUnlimited => 'อัพเกรด Pro เพื่อใช้งานไม่จำกัด';

  @override
  String get upgrade => 'อัพเกรด';

  @override
  String get confirmDelete => 'ยืนยันการลบ';

  @override
  String confirmDeleteMessage(String name) {
    return 'คุณต้องการลบ \"$name\"?';
  }

  @override
  String get entryDeletedSuccess => '✅ ลบรายการสำเร็จ';

  @override
  String entryDeleteError(String error) {
    return '❌ เกิดข้อผิดพลาด: $error';
  }

  @override
  String batchAnalyzeItems(int count) {
    return '$count รายการ (batch)';
  }

  @override
  String analyzeCancelled(int success) {
    return 'ยกเลิกแล้ว - วิเคราะห์สำเร็จ $success รายการ';
  }

  @override
  String analyzeSuccessAll(int success) {
    return '✅ วิเคราะห์สำเร็จ $success รายการ';
  }

  @override
  String analyzeSuccessPartial(int success, int total, int failed) {
    return '⚠️ วิเคราะห์สำเร็จ $success/$total รายการ ($failed ล้มเหลว)';
  }

  @override
  String analyzeProgress(String item, int current, int total) {
    return '$item  ($current/$total)';
  }

  @override
  String get pullToScanMeal => 'ดึงลงเพื่อสแกนมื้ออาหาร';

  @override
  String get analyzeAll => 'วิเคราะห์ทั้งหมด';

  @override
  String get addFoodTitle => 'เพิ่มอาหาร';

  @override
  String get foodNameRequired => 'ชื่ออาหาร *';

  @override
  String get foodNameHint => 'พิมพ์เพื่อค้นหา เช่น ข้าวผัด ส้มตำ';

  @override
  String get selectedFromMyMeal =>
      '✅ เลือกจากเมนูของฉัน — ข้อมูลโภชนาการเติมอัตโนมัติ';

  @override
  String get foundInDatabase => '✅ พบในฐานข้อมูล — ข้อมูลโภชนาการเติมอัตโนมัติ';

  @override
  String get saveAndAnalyze => 'วิเคราะห์';

  @override
  String get notFoundInDatabase => 'ไม่พบในฐานข้อมูล — จะวิเคราะห์ในพื้นหลัง';

  @override
  String get amountLabel => 'ปริมาณ';

  @override
  String get unitLabel => 'หน่วย';

  @override
  String get nutritionAutoCalculated => 'โภชนาการ (คำนวณอัตโนมัติตามปริมาณ)';

  @override
  String get nutritionEnterZero => 'โภชนาการ (กรอก 0 ถ้าไม่ทราบ)';

  @override
  String get caloriesLabel => 'แคลอรี่ (kcal)';

  @override
  String get proteinLabelShort => 'โปรตีน (g)';

  @override
  String get carbsLabelShort => 'คาร์บ (g)';

  @override
  String get fatLabelShort => 'ไขมัน (g)';

  @override
  String get mealTypeLabel => 'ประเภทมื้อ';

  @override
  String get pleaseEnterFoodNameFirst => 'กรุณากรอกชื่ออาหารก่อน';

  @override
  String get savedAnalyzingBackground =>
      '✅ บันทึกแล้ว — กำลังวิเคราะห์ในพื้นหลัง';

  @override
  String get foodAdded => '✅ เพิ่มอาหารแล้ว';

  @override
  String get suggestionSourceMyMeal => 'เมนูของฉัน';

  @override
  String get suggestionSourceIngredient => 'วัตถุดิบ';

  @override
  String get suggestionSourceDatabase => 'ฐานข้อมูล';

  @override
  String get editFoodTitle => 'แก้ไขอาหาร';

  @override
  String get foodNameLabel => 'ชื่ออาหาร';

  @override
  String get changeAmountAutoUpdate => 'เปลี่ยนปริมาณ → แคลอรี่อัพเดทอัตโนมัติ';

  @override
  String baseNutrition(int calories, String unit) {
    return 'ค่าฐาน: $calories kcal / 1 $unit';
  }

  @override
  String get calculatedFromIngredients => 'คำนวณจากวัตถุดิบด้านล่าง';

  @override
  String get ingredientsEditable => 'วัตถุดิบ (แก้ไขได้)';

  @override
  String get addIngredientButton => 'เพิ่ม';

  @override
  String get noIngredientsAddHint =>
      'ไม่มีวัตถุดิบ — กด \"เพิ่ม\" เพื่อเพิ่มใหม่';

  @override
  String get editIngredientsHint =>
      'แก้ไขชื่อ/ปริมาณ → กดไอคอนค้นหาเพื่อค้นหาจากฐานข้อมูลหรือ AI';

  @override
  String get ingredientNameHint => 'เช่น ไข่ไก่';

  @override
  String get searchDbOrAi => 'ค้นหาจาก DB / AI';

  @override
  String get amountHint => 'ปริมาณ';

  @override
  String get fromDatabase => 'จากฐานข้อมูล';

  @override
  String subIngredients(int count) {
    return 'วัตถุดิบย่อย ($count)';
  }

  @override
  String get addSubIngredient => 'เพิ่ม';

  @override
  String get subIngredientNameHint => 'ชื่อวัตถุดิบย่อย';

  @override
  String get amountShort => 'ปริมาณ';

  @override
  String get pleaseEnterSubIngredientName => 'กรุณากรอกชื่อวัตถุดิบย่อยก่อน';

  @override
  String foundInDatabaseSub(String name) {
    return 'พบ \"$name\" ในฐานข้อมูล!';
  }

  @override
  String aiAnalyzedSub(String name) {
    return 'AI วิเคราะห์ \"$name\" (-1 Energy)';
  }

  @override
  String get couldNotAnalyzeSub => 'ไม่สามารถวิเคราะห์วัตถุดิบย่อยได้';

  @override
  String get pleaseEnterIngredientName => 'กรุณากรอกชื่อวัตถุดิบ';

  @override
  String get reAnalyzeTitle => 'วิเคราะห์ใหม่?';

  @override
  String reAnalyzeMessage(String name) {
    return '\"$name\" มีข้อมูลโภชนาการอยู่แล้ว\n\nการวิเคราะห์ใหม่จะใช้ 1 Energy\n\nดำเนินการต่อ?';
  }

  @override
  String get reAnalyzeButton => 'วิเคราะห์ใหม่ (1 Energy)';

  @override
  String get amountNotSpecified => 'ไม่ได้ระบุปริมาณ';

  @override
  String amountNotSpecifiedMessage(String name) {
    return 'กรุณาระบุปริมาณสำหรับ \"$name\" ก่อน\nหรือใช้ค่าเริ่มต้น 100 g?';
  }

  @override
  String get useDefault100g => 'ใช้ 100 g';

  @override
  String aiAnalyzedResult(String name, int calories) {
    return 'AI: \"$name\" → $calories kcal';
  }

  @override
  String get unableToAnalyze => 'ไม่สามารถวิเคราะห์ได้';

  @override
  String get today => 'วันนี้';

  @override
  String get savedSuccessfully => '✅ บันทึกสำเร็จ';

  @override
  String get saveToMyMeals => '📖 บันทึกไปยังเมนูของฉัน';

  @override
  String savedToMyMealsSuccess(String mealName) {
    return '✅ บันทึก \'$mealName\' ไปยังเมนูของฉันแล้ว';
  }

  @override
  String get failedToSaveToMyMeals => '❌ บันทึกไปยังเมนูของฉันไม่สำเร็จ';

  @override
  String get noIngredientsToSave => 'ไม่มีวัตถุดิบที่จะบันทึก';

  @override
  String get confirmFoodPhoto => 'ยืนยันรูปอาหาร';

  @override
  String get photoSavedAutomatically => 'บันทึกรูปอัตโนมัติ';

  @override
  String get foodNameHintExample => 'เช่น สลัดไก่ย่าง';

  @override
  String get quantityLabel => 'ปริมาณ';

  @override
  String get quantityHint => '1';

  @override
  String get optionalFoodInfo =>
      'การกรอกชื่ออาหารและปริมาณเป็นทางเลือก แต่การให้ข้อมูลจะช่วยให้การวิเคราะห์ AI แม่นยำขึ้น';

  @override
  String get saveOnly => 'บันทึกเท่านั้น';

  @override
  String get pleaseEnterValidQuantity => 'กรุณากรอกปริมาณที่ถูกต้อง';

  @override
  String analyzedResult(String name, int calories) {
    return '✅ วิเคราะห์: $name — $calories kcal';
  }

  @override
  String get couldNotAnalyzeSaved =>
      '⚠️ ไม่สามารถวิเคราะห์ได้ — บันทึกแล้ว ใช้ \"วิเคราะห์ทั้งหมด\" ทีหลัง';

  @override
  String get savedAnalyzeLater =>
      '✅ บันทึกแล้ว — วิเคราะห์ทีหลังด้วย \"วิเคราะห์ทั้งหมด\"';

  @override
  String get editIngredientTitle => 'แก้ไขวัตถุดิบ';

  @override
  String get ingredientNameRequired => 'ชื่อวัตถุดิบ *';

  @override
  String get baseAmountLabel => 'ปริมาณฐาน';

  @override
  String get baseAmountHint => '100';

  @override
  String nutritionPerBase(String amount, String unit) {
    return 'โภชนาการต่อ $amount $unit';
  }

  @override
  String nutritionCalculatedPerBase(String amount, String unit) {
    return 'โภชนาการคำนวณต่อ $amount $unit — ระบบจะคำนวณอัตโนมัติตามปริมาณที่บริโภคจริง';
  }

  @override
  String get createIngredient => 'สร้างวัตถุดิบ';

  @override
  String get saveChanges => 'บันทึก';

  @override
  String get pleaseEnterIngredientNameFirst => 'กรุณากรอกชื่อวัตถุดิบก่อน';

  @override
  String aiAnalyzedIngredient(
      String name, String amount, String unit, int calories) {
    return 'AI: \"$name\" $amount $unit → $calories kcal';
  }

  @override
  String get unableToFindIngredient => 'ไม่พบวัตถุดิบนี้';

  @override
  String searchFailed(String error) {
    return 'ค้นหาล้มเหลว: $error';
  }

  @override
  String deleteEntriesTitle(int count) {
    return 'ลบ $count รายการ?';
  }

  @override
  String deleteEntriesMessage(int count) {
    return 'ลบรายการอาหารที่เลือก $count รายการ?';
  }

  @override
  String get deleteAll => 'ลบทั้งหมด';

  @override
  String deletedEntries(int count) {
    return 'ลบ $count รายการแล้ว';
  }

  @override
  String deletedSingleEntry(String name) {
    return 'ลบ $name แล้ว';
  }

  @override
  String get intakeGoalLabel => 'การกิน';

  @override
  String get netEnergyLabel => 'พลังงานสุทธิ';

  @override
  String get underEatingWarning => 'กินน้อยเกินไป';

  @override
  String get surplusWarning => 'เกินเป้าหมาย';

  @override
  String movedEntriesToDate(int count, String date) {
    return 'ย้าย $count รายการไป $date';
  }

  @override
  String get allSelectedAlreadyAnalyzed =>
      'รายการที่เลือกทั้งหมดถูกวิเคราะห์แล้ว';

  @override
  String analyzeCancelledSelected(int success) {
    return 'ยกเลิกแล้ว — วิเคราะห์สำเร็จ $success รายการ';
  }

  @override
  String analyzedEntriesAll(int success) {
    return 'วิเคราะห์สำเร็จ $success รายการ';
  }

  @override
  String analyzedEntriesPartial(int success, int total, int failed) {
    return 'วิเคราะห์สำเร็จ $success/$total ($failed ล้มเหลว)';
  }

  @override
  String analyzeProgressSelected(int current, int total, String item) {
    return '$current/$total  $item';
  }

  @override
  String get noEntriesYet => 'ยังไม่มีรายการ';

  @override
  String get selectAll => 'เลือกทั้งหมด';

  @override
  String get deselectAll => 'ยกเลิกการเลือกทั้งหมด';

  @override
  String get moveToDate => 'ย้ายไปวันที่';

  @override
  String get analyzeSelected => 'วิเคราะห์';

  @override
  String get deleteTooltip => 'ลบ';

  @override
  String get move => 'ย้าย';

  @override
  String get deleteTooltipAction => 'ลบ';

  @override
  String switchToModeTitle(String mode) {
    return 'เปลี่ยนเป็นโหมด $mode?';
  }

  @override
  String switchToModeMessage(String current, String newMode) {
    return 'รายการนี้ถูกวิเคราะห์เป็น $current\n\nการวิเคราะห์ใหม่เป็น $newMode จะใช้ 1 Energy\n\nดำเนินการต่อ?';
  }

  @override
  String analyzingAsMode(String mode) {
    return 'กำลังวิเคราะห์เป็น $mode...';
  }

  @override
  String reAnalyzedAsMode(String mode) {
    return '✅ วิเคราะห์ใหม่เป็น $mode แล้ว';
  }

  @override
  String get analysisFailed => '❌ วิเคราะห์ล้มเหลว';

  @override
  String get aiAnalysisComplete => '✅ วิเคราะห์และบันทึกแล้ว';

  @override
  String get changeMealType => 'เปลี่ยนประเภทมื้อ';

  @override
  String get moveToAnotherDate => 'ย้ายไปวันที่อื่น';

  @override
  String currentDate(String date) {
    return 'ปัจจุบัน: $date';
  }

  @override
  String get cancelDateChange => 'ยกเลิกการเปลี่ยนวันที่';

  @override
  String get undo => 'ยกเลิก';

  @override
  String get chatHistory => 'ประวัติการแชท';

  @override
  String get newChat => 'แชทใหม่';

  @override
  String get quickActions => 'การกระทำด่วน';

  @override
  String get clear => 'ล้าง';

  @override
  String get helloImMiro => 'สวัสดี! ผมคือ Miro';

  @override
  String get tellMeWhatYouAteToday => 'บอกผมว่าคุณกินอะไรวันนี้!';

  @override
  String get tellMeWhatYouAte => 'บอกผมว่าคุณกินอะไร...';

  @override
  String get clearHistoryTitle => 'ล้างประวัติ?';

  @override
  String get clearHistoryMessage => 'ข้อความทั้งหมดในเซสชันนี้จะถูกลบ';

  @override
  String get chatHistoryTitle => 'ประวัติการแชท';

  @override
  String get newLabel => 'ใหม่';

  @override
  String get noChatHistoryYet => 'ยังไม่มีประวัติการแชท';

  @override
  String get active => 'ใช้งานอยู่';

  @override
  String get deleteChatTitle => 'ลบแชท?';

  @override
  String deleteChatMessage(String title) {
    return 'ลบ \"$title\"?';
  }

  @override
  String weeklySummaryTitle(String start, String end) {
    return 'สรุปรายสัปดาห์ ($start - $end)';
  }

  @override
  String daySummary(String day, String calories, String emoji, String diff) {
    return '$day: $calories kcal $emoji ($diff)';
  }

  @override
  String overTarget(String amount) {
    return '$amount เกินเป้าหมาย';
  }

  @override
  String underTarget(String amount) {
    return '$amount ต่ำกว่าเป้าหมาย';
  }

  @override
  String get noFoodLoggedThisWeek => 'ยังไม่มีอาหารบันทึกในสัปดาห์นี้';

  @override
  String averageKcalPerDay(String average) {
    return 'ค่าเฉลี่ย: $average kcal/วัน';
  }

  @override
  String targetKcalPerDay(String target) {
    return 'เป้าหมาย: $target kcal/วัน';
  }

  @override
  String resultOverTarget(String amount) {
    return 'ผลลัพธ์: $amount kcal เกินเป้าหมาย';
  }

  @override
  String resultUnderTarget(String amount) {
    return 'ผลลัพธ์: $amount kcal ต่ำกว่าเป้าหมาย — ทำได้ดีมาก! 💪';
  }

  @override
  String failedToLoadWeeklySummary(String error) {
    return '❌ โหลดสรุปรายสัปดาห์ล้มเหลว: $error';
  }

  @override
  String monthlySummaryTitle(String month, int year) {
    return 'สรุปรายเดือน ($month $year)';
  }

  @override
  String totalDays(int days) {
    return 'จำนวนวันทั้งหมด: $days';
  }

  @override
  String totalConsumed(String calories) {
    return 'บริโภคทั้งหมด: $calories kcal';
  }

  @override
  String targetTotal(String target) {
    return 'เป้าหมายรวม: $target kcal';
  }

  @override
  String averageKcalPerDayShort(String average) {
    return 'ค่าเฉลี่ย: $average kcal/วัน';
  }

  @override
  String overTargetThisMonth(String amount) {
    return '⚠️ $amount kcal เกินเป้าหมายในเดือนนี้';
  }

  @override
  String underTargetThisMonth(String amount) {
    return '✅ $amount kcal ต่ำกว่าเป้าหมาย — ยอดเยี่ยม! 💪';
  }

  @override
  String failedToLoadMonthlySummary(String error) {
    return '❌ โหลดสรุปรายเดือนล้มเหลว: $error';
  }

  @override
  String get localAiHelpTitle => '🤖 คำแนะนำ Local AI';

  @override
  String get localAiHelpFormat => 'รูปแบบ: [อาหาร] [ปริมาณ] [หน่วย]';

  @override
  String get localAiHelpExamples =>
      'ตัวอย่าง:\n• chicken 100g and rice 200g\n• pizza 2 slices\n• apple 1 piece, banana 1 piece';

  @override
  String get localAiHelpNote =>
      'หมายเหตุ: ภาษาอังกฤษเท่านั้น การแยกคำพื้นฐาน\nเปลี่ยนไปใช้ Miro AI เพื่อผลลัพธ์ที่ดีกว่า!';

  @override
  String hiNoFoodLogged(String target) {
    return '🤖 สวัสดี! ยังไม่มีอาหารบันทึกวันนี้\n   เป้าหมาย: $target kcal — พร้อมเริ่มบันทึกแล้วหรือยัง? 🍽️';
  }

  @override
  String hiKcalLeft(String remaining) {
    return '🤖 สวัสดี! คุณเหลือ $remaining kcal สำหรับวันนี้\n   พร้อมบันทึกมื้ออาหารแล้วหรือยัง? 😊';
  }

  @override
  String hiOverTarget(String calories, String over) {
    return '🤖 สวัสดี! คุณบริโภค $calories kcal วันนี้\n   $over kcal เกินเป้าหมาย — มาบันทึกกันต่อ! 💪';
  }

  @override
  String get hiReadyToLog => '🤖 สวัสดี! พร้อมบันทึกมื้ออาหารแล้วหรือยัง? 😊';

  @override
  String get notEnoughEnergy => 'Energy ไม่พอ';

  @override
  String get thinkingMealIdeas => '🤖 กำลังคิดเมนูอาหารดีๆ ให้คุณ...';

  @override
  String get recentMeals => 'มื้ออาหารล่าสุด: ';

  @override
  String get noRecentFood => 'ไม่มีอาหารล่าสุดที่บันทึก';

  @override
  String remainingCaloriesToday(String remaining) {
    return 'แคลอรี่ที่เหลือวันนี้: $remaining kcal';
  }

  @override
  String failedToGetMenuSuggestions(String error) {
    return '❌ ไม่สามารถรับคำแนะนำเมนูได้: $error';
  }

  @override
  String get mealSuggestionsTitle =>
      '🤖 จากบันทึกอาหารของคุณ นี่คือคำแนะนำเมนู 3 รายการ:\n';

  @override
  String mealSuggestionItem(
      int index, String emoji, String name, String calories) {
    return '$index. $emoji $name (~$calories kcal)';
  }

  @override
  String mealSuggestionMacros(String protein, String carbs, String fat) {
    return '   P: ${protein}g | C: ${carbs}g | F: ${fat}g';
  }

  @override
  String get pickOneAndLog => '\nเลือกหนึ่งรายการแล้วผมจะบันทึกให้คุณ! 😊';

  @override
  String energyCost(int cost) {
    return '\n⚡ -$cost Energy';
  }

  @override
  String get giveMeTipsForHealthyEating => 'ให้คำแนะนำการกินเพื่อสุขภาพ';

  @override
  String get howManyCaloriesToday => 'วันนี้กินกี่แคลอรี่?';

  @override
  String get menuLabel => 'เมนู';

  @override
  String get weeklyLabel => 'รายสัปดาห์';

  @override
  String get monthlyLabel => 'รายเดือน';

  @override
  String get tipsLabel => 'เคล็ดลับ';

  @override
  String get summaryLabel => 'สรุป';

  @override
  String get helpLabel => 'ช่วยเหลือ';

  @override
  String get onboardingWelcomeSubtitle =>
      'ติดตามแคลอรี่ได้ง่ายๆ\nด้วยการวิเคราะห์ด้วย AI';

  @override
  String get onboardingSnap => 'ถ่ายรูป';

  @override
  String get onboardingSnapDesc => 'AI วิเคราะห์ทันที';

  @override
  String get onboardingType => 'พิมพ์';

  @override
  String get onboardingTypeDesc => 'บันทึกในไม่กี่วินาที';

  @override
  String get onboardingEdit => 'แก้ไข';

  @override
  String get onboardingEditDesc => 'ปรับแต่งความแม่นยำ';

  @override
  String get onboardingNext => 'ถัดไป →';

  @override
  String get onboardingDisclaimer =>
      'ข้อมูลที่ AI ประมาณการ ไม่ใช่คำแนะนำทางการแพทย์';

  @override
  String get onboardingQuickSetup => 'ตั้งค่าเร็ว';

  @override
  String get onboardingHelpAiUnderstand => 'ช่วยให้ AI เข้าใจอาหารของคุณดีขึ้น';

  @override
  String get onboardingYourTypicalCuisine => 'อาหารที่คุณกินบ่อย:';

  @override
  String get onboardingDailyCalorieGoal => 'เป้าหมายแคลอรี่รายวัน (ไม่บังคับ):';

  @override
  String get onboardingKcalPerDay => 'kcal/วัน';

  @override
  String get onboardingCalorieGoalHint => '2000';

  @override
  String get onboardingCanChangeAnytime =>
      'คุณสามารถเปลี่ยนได้ทุกเมื่อในการตั้งค่าโปรไฟล์';

  @override
  String get onboardingYoureAllSet => 'พร้อมแล้ว!';

  @override
  String get onboardingStartTracking =>
      'เริ่มติดตามมื้ออาหารของคุณวันนี้\nถ่ายรูปหรือพิมพ์สิ่งที่คุณกิน';

  @override
  String get onboardingWelcomeGift => 'ของขวัญต้อนรับ';

  @override
  String get onboardingFreeEnergy => 'พลังงานฟรี 10 หน่วย';

  @override
  String get onboardingFreeEnergyDesc =>
      '= การวิเคราะห์ AI 10 ครั้งเพื่อเริ่มต้น';

  @override
  String get onboardingEnergyCost =>
      'การวิเคราะห์แต่ละครั้งใช้พลังงาน 1 หน่วย\nยิ่งใช้มากยิ่งได้มาก!';

  @override
  String get onboardingStartTrackingButton => 'เริ่มติดตาม! →';

  @override
  String get onboardingNoCreditCard =>
      'ไม่ต้องใช้บัตรเครดิต • ไม่มีค่าธรรมเนียมแอบแฝง';

  @override
  String get cameraTakePhotoOfFood => 'ถ่ายรูปอาหารของคุณ';

  @override
  String get cameraFailedToInitialize => 'ไม่สามารถเริ่มต้นกล้องได้';

  @override
  String get cameraFailedToCapture => 'ถ่ายรูปไม่สำเร็จ';

  @override
  String get cameraFailedToPickFromGallery => 'ไม่สามารถเลือกรูปจากแกลเลอรีได้';

  @override
  String get cameraProcessing => 'กำลังประมวลผล...';

  @override
  String get referralInviteFriends => 'เชิญเพื่อน';

  @override
  String get referralYourReferralCode => 'รหัสแนะนำของคุณ';

  @override
  String get referralLoading => 'กำลังโหลด...';

  @override
  String get referralCopy => 'คัดลอก';

  @override
  String get referralShareCodeDescription =>
      'แชร์รหัสนี้กับเพื่อน! เมื่อเพื่อนใช้ AI 3 ครั้ง คุณทั้งคู่จะได้รับรางวัล!';

  @override
  String get referralEnterReferralCode => 'ใส่รหัสแนะนำ';

  @override
  String get referralCodeHint => 'MIRO-XXXX-XXXX-XXXX';

  @override
  String get referralSubmitCode => 'ส่งรหัส';

  @override
  String get referralPleaseEnterCode => 'กรุณาใส่รหัสแนะนำ';

  @override
  String get referralCodeAccepted => 'ยอมรับรหัสแนะนำแล้ว!';

  @override
  String get referralCodeCopied => 'คัดลอกรหัสแนะนำไปยังคลิปบอร์ดแล้ว!';

  @override
  String referralEnergyBonus(int energy) {
    return '+$energy พลังงาน!';
  }

  @override
  String get referralHowItWorks => 'วิธีใช้งาน';

  @override
  String get referralStep1Title => 'แชร์รหัสแนะนำของคุณ';

  @override
  String get referralStep1Description =>
      'คัดลอกและแชร์ MiRO ID ของคุณกับเพื่อน';

  @override
  String get referralStep2Title => 'เพื่อนใส่รหัสของคุณ';

  @override
  String get referralStep2Description => 'เพื่อนจะได้รับ +20 พลังงานทันที';

  @override
  String get referralStep3Title => 'เพื่อนใช้ AI 3 ครั้ง';

  @override
  String get referralStep3Description =>
      'เมื่อเพื่อนทำการวิเคราะห์ AI ครบ 3 ครั้ง';

  @override
  String get referralStep4Title => 'คุณได้รับรางวัล!';

  @override
  String get referralStep4Description => 'คุณจะได้รับ +5 พลังงาน!';

  @override
  String get tierBenefitsTitle => 'สิทธิประโยชน์ของ Tier';

  @override
  String get tierBenefitsUnlockRewards => 'ปลดล็อกรางวัล\nด้วย Daily Streaks';

  @override
  String get tierBenefitsKeepStreakDescription =>
      'รักษา streak ให้ต่อเนื่องเพื่อปลดล็อค tier ที่สูงขึ้นและรับสิทธิประโยชน์สุดพิเศษ!';

  @override
  String get tierBenefitsHowItWorks => 'วิธีใช้งาน';

  @override
  String get tierBenefitsDailyEnergyReward => 'รางวัลพลังงานรายวัน';

  @override
  String get tierBenefitsDailyEnergyDescription =>
      'ใช้ AI อย่างน้อย 1 ครั้งต่อวันเพื่อรับพลังงานโบนัส Tier สูงขึ้น = พลังงานรายวันมากขึ้น!';

  @override
  String get tierBenefitsPurchaseBonus => 'โบนัสการซื้อ';

  @override
  String get tierBenefitsPurchaseBonusDescription =>
      'Tier Gold และ Diamond ได้รับพลังงานเพิ่มในทุกการซื้อ (เพิ่ม 10-20%!)';

  @override
  String get tierBenefitsGracePeriod => 'ช่วงเวลาพิเศษ';

  @override
  String get tierBenefitsGracePeriodDescription =>
      'พลาดวันโดยไม่เสีย streak Tier Silver+ ได้รับการปกป้อง!';

  @override
  String get tierBenefitsAllTiers => 'Tier ทั้งหมด';

  @override
  String get tierBenefitsNew => 'ใหม่';

  @override
  String get tierBenefitsPopular => 'ยอดนิยม';

  @override
  String get tierBenefitsBest => 'ดีที่สุด';

  @override
  String get tierBenefitsDailyCheckIn => 'เช็คอินรายวัน';

  @override
  String get tierBenefitsProTips => 'เคล็ดลับ';

  @override
  String get tierBenefitsTip1 =>
      'ใช้ AI ทุกวันเพื่อรับพลังงานฟรีและสร้าง streak';

  @override
  String get tierBenefitsTip2 =>
      'Tier Diamond ได้รับ +4 พลังงานต่อวัน — นั่นคือ 120/เดือน!';

  @override
  String get tierBenefitsTip3 => 'โบนัสการซื้อใช้ได้กับแพ็คเกจพลังงานทั้งหมด!';

  @override
  String get tierBenefitsTip4 => 'ช่วงเวลาพิเศษปกป้อง streak ของคุณหากพลาดวัน';

  @override
  String get subscriptionEnergyPass => 'Energy Pass';

  @override
  String get subscriptionInAppPurchasesNotAvailable =>
      'ไม่สามารถใช้ In-app purchases ได้';

  @override
  String get subscriptionFailedToInitiatePurchase => 'ไม่สามารถเริ่มการซื้อได้';

  @override
  String subscriptionError(String error) {
    return 'เกิดข้อผิดพลาด: $error';
  }

  @override
  String get subscriptionFailedToLoad => 'ไม่สามารถโหลดข้อมูลการสมัครสมาชิกได้';

  @override
  String get subscriptionUnknownError => 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ';

  @override
  String get subscriptionRetry => 'ลองอีกครั้ง';

  @override
  String get subscriptionEnergyPassActive => 'Energy Pass ใช้งานได้';

  @override
  String get subscriptionUnlimitedAccess => 'คุณมีสิทธิ์ใช้งานไม่จำกัด';

  @override
  String get subscriptionStatus => 'สถานะ';

  @override
  String get subscriptionRenews => 'ต่ออายุ';

  @override
  String get subscriptionPrice => 'ราคา';

  @override
  String get subscriptionYourBenefits => 'สิทธิประโยชน์ของคุณ';

  @override
  String get subscriptionManageSubscription => 'จัดการการสมัครสมาชิก';

  @override
  String get subscriptionNoProductAvailable => 'ไม่มีแพ็คเกจการสมัครสมาชิก';

  @override
  String get subscriptionWhatYouGet => 'สิ่งที่คุณจะได้รับ';

  @override
  String get subscriptionPerMonth => 'ต่อเดือน';

  @override
  String get subscriptionSubscribeNow => 'สมัครสมาชิกเลย';

  @override
  String get subscriptionSubscribe => 'สมัครสมาชิก';

  @override
  String get subscriptionCancelAnytime => 'ยกเลิกได้ทุกเมื่อ';

  @override
  String get subscriptionAutoRenewTerms =>
      'การสมัครสมาชิกของคุณจะต่ออายุอัตโนมัติ คุณสามารถยกเลิกได้ทุกเมื่อจาก Google Play';

  @override
  String subscriptionRenewsDate(String date) {
    return 'ต่ออายุ: $date';
  }

  @override
  String get subscriptionBestValue => 'คุ้มที่สุด';

  @override
  String get energyStoreTitle => 'ร้านพลังงาน';

  @override
  String get energyPackages => 'แพ็คเกจพลังงาน';

  @override
  String get energyPackageStarterKick => 'Starter Kick';

  @override
  String get energyPackageValuePack => 'Value Pack';

  @override
  String get energyPackagePowerUser => 'Power User';

  @override
  String get energyPackageUltimateSaver => 'Ultimate Saver';

  @override
  String get energyBadgeBestValue => 'คุ้มที่สุด';

  @override
  String get energyBadgePopular => 'ยอดนิยม';

  @override
  String get energyBadgeBonus10 => '+10% โบนัส';

  @override
  String get energyPassUnlimitedAI => 'วิเคราะห์ AI ไม่จำกัด';

  @override
  String energyPassUnlimitedFromPrice(String price) {
    return 'วิเคราะห์ AI ไม่จำกัด • เริ่มต้น $price/เดือน';
  }

  @override
  String get energyPassActive => 'ใช้งานอยู่';

  @override
  String get subscriptionDeal => 'ดีลสมัครสมาชิก';

  @override
  String get subscriptionViewDeal => 'ดูดีล';

  @override
  String get disclaimerHealthDisclaimer => 'ข้อจำกัดความรับผิด';

  @override
  String get disclaimerImportantReminders => 'ข้อควรระวังสำคัญ:';

  @override
  String get disclaimerBullet1 => 'ข้อมูลโภชนาการทั้งหมดเป็นค่าประมาณ';

  @override
  String get disclaimerBullet2 => 'การวิเคราะห์ AI อาจมีข้อผิดพลาด';

  @override
  String get disclaimerBullet3 => 'ไม่ใช่คำแนะนำจากผู้เชี่ยวชาญ';

  @override
  String get disclaimerBullet4 =>
      'ปรึกษาผู้ให้บริการด้านสุขภาพสำหรับคำแนะนำทางการแพทย์';

  @override
  String get disclaimerBullet5 => 'ใช้ตามดุลยพินิจและความเสี่ยงของคุณเอง';

  @override
  String get disclaimerIUnderstand => 'ฉันเข้าใจแล้ว';

  @override
  String get privacyPolicyTitle => 'นโยบายความเป็นส่วนตัว';

  @override
  String get privacyPolicySubtitle => 'MiRO — My Intake Record Oracle';

  @override
  String get privacyPolicyHeaderNote =>
      'ข้อมูลอาหารของคุณเก็บไว้บนอุปกรณ์ของคุณ พลังงานซิงค์อย่างปลอดภัยผ่าน Firebase';

  @override
  String get privacyPolicySectionInformationWeCollect => 'ข้อมูลที่เรารวบรวม';

  @override
  String get privacyPolicySectionDataStorage => 'การเก็บข้อมูล';

  @override
  String get privacyPolicySectionDataTransmission =>
      'การส่งข้อมูลไปยังบุคคลที่สาม';

  @override
  String get privacyPolicySectionRequiredPermissions => 'สิทธิ์ที่จำเป็น';

  @override
  String get privacyPolicySectionSecurity => 'ความปลอดภัย';

  @override
  String get privacyPolicySectionUserRights => 'สิทธิ์ของผู้ใช้';

  @override
  String get privacyPolicySectionDataRetention => 'การเก็บรักษาข้อมูล';

  @override
  String get privacyPolicySectionChildrenPrivacy => 'ความเป็นส่วนตัวของเด็ก';

  @override
  String get privacyPolicySectionChangesToPolicy => 'การเปลี่ยนแปลงนโยบาย';

  @override
  String get privacyPolicySectionDataCollectionConsent =>
      'ความยินยอมในการเก็บข้อมูล';

  @override
  String get privacyPolicySectionPDPACompliance =>
      'การปฏิบัติตาม PDPA (พระราชบัญญัติคุ้มครองข้อมูลส่วนบุคคล)';

  @override
  String get privacyPolicySectionContactUs => 'ติดต่อเรา';

  @override
  String get privacyPolicyEffectiveDate =>
      'วันที่มีผลบังคับใช้: 18 กุมภาพันธ์ 2026\nอัพเดทล่าสุด: 18 กุมภาพันธ์ 2026';

  @override
  String get termsOfServiceTitle => 'เงื่อนไขการใช้งาน';

  @override
  String get termsSubtitle => 'MiRO — My Intake Record Oracle';

  @override
  String get termsSectionAcceptanceOfTerms => 'การยอมรับเงื่อนไข';

  @override
  String get termsSectionServiceDescription => 'คำอธิบายบริการ';

  @override
  String get termsSectionDisclaimerOfWarranties => 'ข้อจำกัดความรับผิด';

  @override
  String get termsSectionEnergySystemTerms => 'เงื่อนไขระบบพลังงาน';

  @override
  String get termsSectionUserDataAndResponsibilities =>
      'ข้อมูลและความรับผิดชอบของผู้ใช้';

  @override
  String get termsSectionBackupTransfer => 'สำรองข้อมูลและการโอนย้าย';

  @override
  String get termsSectionInAppPurchases => 'การซื้อในแอป';

  @override
  String get termsSectionProhibitedUses => 'การใช้งานที่ห้าม';

  @override
  String get termsSectionIntellectualProperty => 'ทรัพย์สินทางปัญญา';

  @override
  String get termsSectionLimitationOfLiability => 'ข้อจำกัดความรับผิด';

  @override
  String get termsSectionServiceTermination => 'การยกเลิกบริการ';

  @override
  String get termsSectionChangesToTerms => 'การเปลี่ยนแปลงเงื่อนไข';

  @override
  String get termsSectionGoverningLaw => 'กฎหมายที่ใช้บังคับ';

  @override
  String get termsSectionContactUs => 'ติดต่อเรา';

  @override
  String get termsAcknowledgment =>
      'โดยการใช้ MiRO คุณยอมรับว่าคุณได้อ่าน เข้าใจ และยอมรับเงื่อนไขการใช้งานเหล่านี้แล้ว';

  @override
  String get termsLastUpdated => 'อัพเดทล่าสุด: 15 กุมภาพันธ์ 2026';

  @override
  String get profileAndSettings => 'โปรไฟล์และการตั้งค่า';

  @override
  String errorOccurred(String error) {
    return 'เกิดข้อผิดพลาด: $error';
  }

  @override
  String get healthGoalsSection => 'เป้าหมายสุขภาพ';

  @override
  String get dailyGoals => 'เป้าหมายรายวัน';

  @override
  String get chatAiModeSection => 'โหมด Chat AI';

  @override
  String get selectAiPowersChat => 'เลือก AI ที่จะใช้ในแชท';

  @override
  String get miroAi => 'Miro AI';

  @override
  String get miroAiSubtitle => 'ใช้ Gemini • รองรับหลายภาษา • ความแม่นยำสูง';

  @override
  String get localAi => 'Local AI';

  @override
  String get localAiSubtitle =>
      'ทำงานบนอุปกรณ์ • ภาษาอังกฤษเท่านั้น • ความแม่นยำพื้นฐาน';

  @override
  String get free => 'ฟรี';

  @override
  String get cuisinePreferenceSection => 'อาหารที่ชอบ';

  @override
  String get preferredCuisine => 'อาหารที่ชอบ';

  @override
  String get selectYourCuisine => 'เลือกอาหารที่คุณชอบ';

  @override
  String get photoScanSection => 'สแกนรูปภาพ';

  @override
  String get languageSection => 'ภาษา';

  @override
  String get languageTitle => 'Language / ภาษา';

  @override
  String get selectLanguage => 'Select Language / เลือกภาษา';

  @override
  String get systemDefault => 'ตามระบบ';

  @override
  String get systemDefaultSublabel => 'ตามระบบ';

  @override
  String get english => 'English';

  @override
  String get englishSublabel => 'อังกฤษ';

  @override
  String get thai => 'ไทย (Thai)';

  @override
  String get thaiSublabel => 'ภาษาไทย';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get vietnameseSublabel => 'Vietnamese';

  @override
  String get indonesian => 'Bahasa Indonesia';

  @override
  String get indonesianSublabel => 'Indonesian';

  @override
  String get chinese => '中文';

  @override
  String get chineseSublabel => 'Chinese';

  @override
  String get japanese => '日本語';

  @override
  String get japaneseSublabel => 'Japanese';

  @override
  String get korean => '한국어';

  @override
  String get koreanSublabel => 'Korean';

  @override
  String get spanish => 'Español';

  @override
  String get spanishSublabel => 'Spanish';

  @override
  String get french => 'Français';

  @override
  String get frenchSublabel => 'French';

  @override
  String get german => 'Deutsch';

  @override
  String get germanSublabel => 'German';

  @override
  String get portuguese => 'Português';

  @override
  String get portugueseSublabel => 'Portuguese';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get hindiSublabel => 'Hindi';

  @override
  String get closeBilingual => 'Close / ปิด';

  @override
  String languageChangedTo(String language) {
    return 'เปลี่ยนภาษาเป็น $language';
  }

  @override
  String get accountSection => 'บัญชี';

  @override
  String get miroId => 'MiRO ID';

  @override
  String get miroIdCopied => 'คัดลอก MiRO ID แล้ว!';

  @override
  String get inviteFriends => 'เชิญเพื่อน';

  @override
  String get inviteFriendsSubtitle => 'แชร์รหัสแนะนำของคุณและรับรางวัล!';

  @override
  String get unlimitedAiDoubleRewards => 'AI ไม่จำกัด + รางวัลสองเท่า';

  @override
  String get plan => 'แผน';

  @override
  String get monthly => 'รายเดือน';

  @override
  String get started => 'เริ่มเมื่อ';

  @override
  String get renews => 'ต่ออายุ';

  @override
  String get expires => 'หมดอายุ';

  @override
  String get autoRenew => 'ต่ออัตโนมัติ';

  @override
  String get on => 'เปิด';

  @override
  String get off => 'ปิด';

  @override
  String get tapToManageSubscription => 'แตะเพื่อจัดการการสมัครสมาชิก';

  @override
  String get dataSection => 'ข้อมูล';

  @override
  String get backupData => 'สำรองข้อมูล';

  @override
  String get backupDataSubtitle => 'พลังงาน + ประวัติอาหาร → บันทึกเป็นไฟล์';

  @override
  String get restoreFromBackup => 'กู้คืนจากสำรองข้อมูล';

  @override
  String get restoreFromBackupSubtitle => 'นำเข้าข้อมูลจากไฟล์สำรอง';

  @override
  String get clearAllDataTitle => 'ล้างข้อมูลทั้งหมด?';

  @override
  String get clearAllDataContent =>
      'ข้อมูลทั้งหมดจะถูกลบ:\n• รายการอาหาร\n• อาหารของฉัน\n• ส่วนผสม\n• เป้าหมาย\n• ข้อมูลส่วนตัว\n\nไม่สามารถกู้คืนได้!';

  @override
  String get allDataClearedSuccess => 'ล้างข้อมูลทั้งหมดเรียบร้อย';

  @override
  String get aboutSection => 'เกี่ยวกับ';

  @override
  String get version => 'เวอร์ชัน';

  @override
  String get healthDisclaimer => 'ข้อจำกัดความรับผิดด้านสุขภาพ';

  @override
  String get importantLegalInformation => 'ข้อมูลกฎหมายสำคัญ';

  @override
  String get showTutorialAgain => 'แสดงทัวร์อีกครั้ง';

  @override
  String get viewFeatureTour => 'ดูทัวร์ฟีเจอร์';

  @override
  String get showTutorialDialogTitle => 'แสดงทัวร์';

  @override
  String get showTutorialDialogContent =>
      'จะแสดงทัวร์ฟีเจอร์ที่เน้น:\n\n• ระบบพลังงาน\n• ดึงลงเพื่อสแกนรูปภาพ\n• แชทกับ Miro AI\n\nคุณจะกลับไปที่หน้าหลัก';

  @override
  String get showTutorialButton => 'แสดงทัวร์';

  @override
  String get tutorialResetMessage => 'รีเซ็ตทัวร์แล้ว! ไปที่หน้าหลักเพื่อดู';

  @override
  String get foodAnalysisTutorial => 'ทัวร์การวิเคราะห์อาหาร';

  @override
  String get foodAnalysisTutorialSubtitle =>
      'เรียนรู้วิธีใช้ฟีเจอร์วิเคราะห์อาหาร';

  @override
  String get backupCreated => 'สร้างสำรองข้อมูลสำเร็จ!';

  @override
  String get backupCreatedContent => 'สร้างไฟล์สำรองข้อมูลสำเร็จแล้ว';

  @override
  String get backupChooseDestination => 'ต้องการบันทึก Backup ไว้ที่ไหน?';

  @override
  String get backupSaveToDevice => 'บันทึกลงเครื่อง';

  @override
  String get backupSaveToDeviceDesc => 'เลือกโฟลเดอร์ที่ต้องการบันทึก';

  @override
  String get backupShareToOther => 'ส่งไปเครื่องอื่น';

  @override
  String get backupShareToOtherDesc => 'ส่งผ่าน Line, Email, Google Drive ฯลฯ';

  @override
  String get backupSavedSuccess => 'บันทึก Backup สำเร็จ!';

  @override
  String get backupSavedSuccessContent =>
      'ไฟล์สำรองข้อมูลถูกบันทึกไปยังโฟลเดอร์ที่เลือกแล้ว';

  @override
  String get important => 'สำคัญ:';

  @override
  String get backupImportantNotes =>
      '• บันทึกไฟล์นี้ในที่ปลอดภัย (Google Drive เป็นต้น)\n• รูปภาพไม่รวมอยู่ในสำรองข้อมูล\n• Transfer Key หมดอายุใน 30 วัน\n• Key ใช้ได้ครั้งเดียวเท่านั้น';

  @override
  String get restoreBackup => 'กู้คืนจากสำรองข้อมูล?';

  @override
  String get backupFrom => 'สำรองจาก:';

  @override
  String get date => 'วันที่:';

  @override
  String get energy => 'พลังงาน:';

  @override
  String get foodEntries => 'รายการอาหาร:';

  @override
  String get restoreImportant => 'สำคัญ';

  @override
  String restoreImportantNotes(String energy) {
    return '• พลังงานปัจจุบันบนอุปกรณ์นี้จะถูกแทนที่ด้วยพลังงานจากสำรองข้อมูล ($energy)\n• รายการอาหารจะถูกรวม (ไม่ใช่แทนที่)\n• รูปภาพไม่รวมอยู่ในสำรองข้อมูล\n• Transfer Key จะถูกใช้ (ใช้ซ้ำไม่ได้)';
  }

  @override
  String get restore => 'กู้คืน';

  @override
  String get restoreComplete => 'กู้คืนสำเร็จ!';

  @override
  String get restoreCompleteContent => 'กู้คืนข้อมูลสำเร็จแล้ว';

  @override
  String get newEnergyBalance => 'ยอดพลังงานใหม่:';

  @override
  String get foodEntriesImported => 'รายการอาหารที่นำเข้า:';

  @override
  String get myMealsImported => 'อาหารของฉันที่นำเข้า:';

  @override
  String get appWillRefresh => 'แอปจะรีเฟรชเพื่อแสดงข้อมูลที่กู้คืน';

  @override
  String get backupFailed => 'สร้างสำรองข้อมูลล้มเหลว';

  @override
  String get invalidBackupFile => 'ไฟล์สำรองข้อมูลไม่ถูกต้อง';

  @override
  String get restoreFailed => 'กู้คืนล้มเหลว';

  @override
  String get analyticsDataCollection => 'การเก็บข้อมูลการวิเคราะห์';

  @override
  String get analyticsEnabled =>
      'เปิดการวิเคราะห์แล้ว - ขอบคุณที่ช่วยปรับปรุงแอป';

  @override
  String get analyticsDisabled =>
      'ปิดการวิเคราะห์แล้ว - ไม่เก็บข้อมูลการใช้งาน';

  @override
  String get enabled => 'เปิด';

  @override
  String get enabledSubtitle => 'เปิด - ช่วยปรับปรุงประสบการณ์ใช้งาน';

  @override
  String get disabled => 'ปิด';

  @override
  String get disabledSubtitle => 'ปิด - ไม่เก็บข้อมูลการใช้งาน';

  @override
  String get imagesPerDay => 'รูปภาพต่อวัน';

  @override
  String scanUpToImagesPerDay(String limit) {
    return 'สแกนได้สูงสุด $limit รูปภาพต่อวัน';
  }

  @override
  String get reset => 'รีเซ็ต';

  @override
  String get resetScanHistory => 'รีเซ็ตประวัติการสแกน';

  @override
  String get resetScanHistorySubtitle => 'ลบรายการที่สแกนทั้งหมดและสแกนใหม่';

  @override
  String get imagesPerDayDialog => 'รูปภาพต่อวัน';

  @override
  String get maxImagesPerDayDescription =>
      'จำนวนรูปภาพสูงสุดที่สแกนต่อวัน\nสแกนเฉพาะวันที่เลือก';

  @override
  String scanLimitSetTo(String limit) {
    return 'ตั้งค่าจำกัดการสแกนเป็น $limit รูปภาพต่อวัน';
  }

  @override
  String get resetScanHistoryDialog => 'รีเซ็ตประวัติการสแกน?';

  @override
  String get resetScanHistoryContent =>
      'รายการอาหารที่สแกนจากแกลเลอรีทั้งหมดจะถูกลบ\nดึงลงที่วันที่ใดก็ได้เพื่อสแกนรูปภาพใหม่';

  @override
  String resetComplete(String count) {
    return 'รีเซ็ตเสร็จแล้ว - ลบ $count รายการ ดึงลงเพื่อสแกนใหม่';
  }

  @override
  String questBarStreak(int days) {
    return 'Streak $days วัน';
  }

  @override
  String questBarDaysToNextTier(int days, String tier) {
    return 'อีก $days วัน → $tier';
  }

  @override
  String get questBarMaxTier => 'Max Tier! 💎';

  @override
  String get questBarOfferDismissed => 'Offer ถูกซ่อน';

  @override
  String get questBarViewOffer => 'ดู Offer';

  @override
  String get questBarNoOffersNow => '• ไม่มี Offer ในตอนนี้';

  @override
  String get questBarWeeklyChallenges => '🎯 Weekly Challenges';

  @override
  String get questBarMilestones => '🏆 Milestones';

  @override
  String get questBarInviteFriends => '👥 ชวนเพื่อนได้ 20E';

  @override
  String questBarTimeRemaining(String time) {
    return '⏰ เหลือเวลา $time';
  }

  @override
  String questBarClaimDailyEnergy(int energy) {
    return '+${energy}E';
  }

  @override
  String questBarShareReferralError(String error) {
    return 'เกิดข้อผิดพลาด: $error';
  }

  @override
  String tierCelebrationTitle(String tier) {
    return 'ฉลองระดับ $tier 🎉';
  }

  @override
  String tierCelebrationDay(int day) {
    return 'วันที่ $day';
  }

  @override
  String get tierCelebrationExpired => 'หมดอายุ';

  @override
  String get tierCelebrationComplete => 'สำเร็จ!';

  @override
  String questBarWatchAd(int energy) {
    return 'ดูโฆษณา +$energy⚡';
  }

  @override
  String questBarAdRemaining(int remaining, int total) {
    return 'เหลือ $remaining/$total ครั้งวันนี้';
  }

  @override
  String questBarAdSuccess(int energy) {
    return '🎉 ดูโฆษณาเสร็จแล้ว! +$energy Energy กำลังเข้าบัญชี...';
  }

  @override
  String get questBarAdNotReady => 'โฆษณายังไม่พร้อม กรุณาลองอีกครั้ง';

  @override
  String get questBarDailyChallenge => 'Daily Challenge';

  @override
  String get questBarUseAi => 'ใช้ Energy';

  @override
  String get questBarResetsMonday => 'รีเซ็ตทุกวันจันทร์';

  @override
  String get questBarClaimed => 'เคลมแล้ว!';

  @override
  String get questBarHideOffer => 'ซ่อน';

  @override
  String get questBarViewDetails => 'ดูเลย';

  @override
  String questBarShareText(String link) {
    return 'มาลองแอป MiRO กัน! วิเคราะห์อาหารด้วย AI 🍔\nใช้ลิงก์นี้ — คุณได้ +5 Energy เพื่อนได้ +20 Energy ฟรี!\n\n$link';
  }

  @override
  String get questBarShareSubject => 'ชวนใช้ MiRO';

  @override
  String get claimButtonTitle => 'กดเพื่อรับ Daily Energy';

  @override
  String claimButtonReceived(String energy) {
    return 'ได้รับ +${energy}E แล้ว!';
  }

  @override
  String get claimButtonAlreadyClaimed => 'วันนี้เคลมไปแล้ว';

  @override
  String claimButtonError(String error) {
    return 'เกิดข้อผิดพลาด: $error';
  }

  @override
  String get seasonalQuestLimitedTime => 'จำกัดเวลา';

  @override
  String seasonalQuestDaysLeft(int days) {
    return 'เหลืออีก $days วัน';
  }

  @override
  String seasonalQuestRewardDaily(int reward) {
    return '+${reward}E / วัน';
  }

  @override
  String seasonalQuestRewardOnce(int reward) {
    return '+${reward}E ครั้งเดียว';
  }

  @override
  String get seasonalQuestClaimed => 'รับแล้ว!';

  @override
  String get seasonalQuestClaimedToday => 'วันนี้รับไปแล้ว';

  @override
  String get errorFailed => 'ล้มเหลว';

  @override
  String get errorFailedToClaim => 'เคลมไม่สำเร็จ';

  @override
  String errorGeneric(String error) {
    return 'เกิดข้อผิดพลาด: $error';
  }

  @override
  String get milestoneNoMilestonesToClaim => 'ยังไม่มี milestone ที่เคลมได้';

  @override
  String milestoneClaimedEnergy(int energy) {
    return '🎁 เคลมได้ +$energy Energy!';
  }

  @override
  String get milestoneTitle => 'Milestones';

  @override
  String milestoneUseEnergyComplete(int threshold) {
    return 'ใช้ Energy ครบ $threshold';
  }

  @override
  String milestoneNext(int threshold) {
    return 'ถัดไป: ${threshold}E';
  }

  @override
  String get milestoneAllComplete => 'ทุก Milestone สำเร็จแล้ว!';

  @override
  String get noEnergyTitle => 'Energy หมด';

  @override
  String get noEnergyContent =>
      'คุณต้องการ 1 Energy เพื่อวิเคราะห์อาหารด้วย AI';

  @override
  String get noEnergyTip => 'คุณยังสามารถบันทึกอาหารด้วยมือ (ไม่ใช้ AI) ได้ฟรี';

  @override
  String get noEnergyLater => 'ไว้ทีหลัง';

  @override
  String noEnergyWatchAd(int remaining) {
    return 'ดูโฆษณา ($remaining/3)';
  }

  @override
  String get noEnergyBuyEnergy => 'ซื้อ Energy';

  @override
  String get tierBronze => 'Bronze';

  @override
  String get tierSilver => 'Silver';

  @override
  String get tierGold => 'Gold';

  @override
  String get tierDiamond => 'Diamond';

  @override
  String get tierStarter => 'Starter';

  @override
  String get tierUpCongratulations => '🎉 ยินดีด้วย!';

  @override
  String tierUpYouReached(String tier) {
    return 'คุณเลื่อนเป็น $tier!';
  }

  @override
  String get tierUpMotivation =>
      'Track calories เก่งมาก\nหุ่นในฝันใกล้จะเป็นจริงแล้ว!';

  @override
  String tierUpReward(int reward) {
    return '+${reward}E Reward!';
  }

  @override
  String get referralAllLevelsClaimed => 'เคลมครบทุก level แล้ว!';

  @override
  String referralLevel(int level, String subtitle) {
    return 'Level $level: $subtitle';
  }

  @override
  String referralProgress(int current, int target, int level, int total) {
    return '[$current/$target] (Level $level/$total)';
  }

  @override
  String referralClaimedLevel(int level, int reward) {
    return '🎁 เคลม Level $level: +$reward Energy!';
  }

  @override
  String get challengeUseAi10 => 'ใช้ Energy 10';

  @override
  String get specifyIngredients => 'ระบุวัตถุดิบที่รู้';

  @override
  String get specifyIngredientsOptional => 'ระบุวัตถุดิบที่รู้ (optional)';

  @override
  String get specifyIngredientsHint =>
      'ใส่วัตถุดิบหลักที่คุณรู้ แล้ว AI จะค้นหาเครื่องปรุง น้ำมัน ซอส และวัตถุดิบย่อยที่ซ่อนอยู่ให้';

  @override
  String get sendToAi => 'ส่งตรวจ AI';

  @override
  String get reanalyzeWithIngredients => 'เพิ่มวัตถุดิบ & วิเคราะห์ใหม่';

  @override
  String get reanalyzeButton => 'วิเคราะห์ใหม่ (1 Energy)';

  @override
  String get ingredientsSaved => 'บันทึกวัตถุดิบแล้ว';

  @override
  String get pleaseAddAtLeastOneIngredient =>
      'กรุณาเพิ่มวัตถุดิบอย่างน้อย 1 รายการ';

  @override
  String get hiddenIngredientsDiscovered => 'วัตถุดิบที่ AI ค้นพบ';

  @override
  String get retroScanTitle => 'สแกนรูปย้อนหลัง?';

  @override
  String get retroScanDescription =>
      'เราสามารถสแกนรูปภาพ 7 วันที่ผ่านมา เพื่อค้นหารูปอาหารและเพิ่มลง diary ให้อัตโนมัติ';

  @override
  String get retroScanNote =>
      'ตรวจจับเฉพาะรูปอาหาร — รูปอื่นจะถูกข้าม ไม่มีรูปถูกส่งออกนอกเครื่อง';

  @override
  String get retroScanStart => 'สแกนรูปของฉัน';

  @override
  String get retroScanSkip => 'ข้ามไปก่อน';

  @override
  String get retroScanInProgress => 'กำลังสแกน...';

  @override
  String get retroScanTagline =>
      'MiRO กำลังเปลี่ยนรูปอาหารของคุณ\nให้เป็นข้อมูลสุขภาพ';

  @override
  String get retroScanFetchingPhotos => 'กำลังดึงรูปภาพล่าสุด...';

  @override
  String get retroScanAnalyzing => 'กำลังตรวจจับรูปอาหาร...';

  @override
  String retroScanPhotosFound(int count) {
    return 'พบ $count รูปใน 7 วันที่ผ่านมา';
  }

  @override
  String get retroScanCompleteTitle => 'สแกนเสร็จแล้ว!';

  @override
  String retroScanCompleteDesc(int count) {
    return 'พบ $count รูปอาหาร! เพิ่มลง timeline แล้ว พร้อมให้ AI วิเคราะห์';
  }

  @override
  String get retroScanNoResultsTitle => 'ไม่พบรูปอาหาร';

  @override
  String get retroScanNoResultsDesc =>
      'ไม่พบรูปอาหารใน 7 วันที่ผ่านมา ลองถ่ายรูปมื้อต่อไปดูนะ!';

  @override
  String get retroScanAnalyzeHint =>
      'กด \"วิเคราะห์ทั้งหมด\" บน timeline เพื่อให้ AI วิเคราะห์โภชนาการ';

  @override
  String get retroScanDone => 'เข้าใจแล้ว!';

  @override
  String get welcomeEndTitle => 'ยินดีต้อนรับสู่ MiRO!';

  @override
  String get welcomeEndMessage => 'MiRO ยินดีรับใช้';

  @override
  String get welcomeEndJourney => 'Have a nice journey together!!';

  @override
  String get welcomeEndStart => 'เริ่มใช้งานเลย!';

  @override
  String greetingCalorieSummary(
      int remaining, int protein, int carbs, int fat) {
    return 'สวัสดีค่ะ วันนี้ช่วยอะไรได้บ้าง? ตอนนี้คุณเหลือแคลอรี่ให้ทานอีก $remaining kcal ทานโปรตีน ${protein}g คาร์บ ${carbs}g ไขมัน ${fat}g ทานอะไรเล่าให้ฉันฟัง แยกเป็นมื้อๆ มาทีเดียวได้เลยค่ะ ดิฉันจะแยกเป็นรายการๆ และบันทึกให้เองค่ะ ยิ่งบอกละเอียด ยิ่งแม่นยำคะ';
  }

  @override
  String greetingCuisineTip(String cuisine) {
    return 'ตอนนี้คุณตั้งค่าอาหารที่ทานบ่อยเป็น $cuisine หากต้องการเปลี่ยนแปลง สามารถเปลี่ยนได้ที่การตั้งค่านะคะ';
  }

  @override
  String greetingEnergyTip(int balance) {
    return 'ตอนนี้คุณมี Energy อีก $balance กดเคลมได้ที่แถบ streak ได้นะคะ';
  }

  @override
  String get greetingRenamePhotoTip =>
      'คุณสามารถเปลี่ยนชื่ออาหารของรูปถ่ายเพื่อให้ MiRO วิเคราะห์ได้แม่นยำขึ้นนะคะ';

  @override
  String get greetingAddIngredientsTip =>
      'คุณสามารถเพิ่มวัตถุดิบที่คุณมั่นใจในปริมาณที่ทานไปในรายการก่อนส่งมาให้ MiRO วิเคราะห์ได้นะ ฉันจะวิเคราะห์ส่วนยิบย่อยน่าเบื่อให้เอง';

  @override
  String greetingBackupReminder(int days) {
    return 'เจ้านายตอนนี้คุณไม่ได้ backup ข้อมูลมาแล้ว $days วันนะคะ ดิฉันแนะนำให้ backup ใน Setting เพราะข้อมูลของเจ้านายอยู่ในเครื่อง ไม่ได้อยู่ใน internet และฉันไม่สามารถกู้คืนข้อมูลให้ได้นะคะ';
  }

  @override
  String get greetingFallback =>
      'สวัสดีค่ะ วันนี้ช่วยอะไรได้บ้าง? ทานอะไรเล่าให้ฉันฟังนะ!';

  @override
  String get saveFoodTitle => 'Save Food';

  @override
  String get saveButton => 'Save';

  @override
  String get analyzingTitle => 'Analyzing...';

  @override
  String get analyzingWarningContent =>
      'AI is analyzing food\n\nIf you leave now, the analysis result will be lost and you will need to re-analyze (costs Energy again)';

  @override
  String get waitButton => 'Wait';

  @override
  String get exitButton => 'Exit';

  @override
  String get amountAutoAdjust => 'Change → calories adjust automatically';

  @override
  String get processingImageData => 'PROCESSING IMAGE DATA...';

  @override
  String get unableToAnalyzeTitle => 'Unable to analyze';

  @override
  String get tryAgainButton => 'Try Again';

  @override
  String aiAnalyzedConfidence(String confidence) {
    return 'AI Analyzed ($confidence% confidence)';
  }

  @override
  String get analyzingButton => 'ANALYZING...';

  @override
  String get aiAnalysisButton => 'AI Analysis';

  @override
  String get manualInputHint =>
      'Enter food details below or use AI analysis for automatic nutrition estimation';

  @override
  String get caloriesTitle => 'CALORIES';

  @override
  String get macrosTitle => 'Macros';

  @override
  String get mealTypeTitle => 'Meal Type';

  @override
  String get ingredientsTitle => 'Ingredients';

  @override
  String get ingredientsTapToExpand => 'แตะเพื่อดูและแก้ไข';

  @override
  String get pleaseEnterFoodNameShort => 'Please enter food name';

  @override
  String get foodPendingAnalysis => 'Food (pending analysis)';

  @override
  String get unableToAnalyzeImage => 'Unable to analyze image';

  @override
  String get foodSavedSuccess => 'Food saved successfully!';

  @override
  String baseInfo(
      String calories, String unit, String protein, String carbs, String fat) {
    return 'Base: $calories kcal / 1 $unit (P:${protein}g C:${carbs}g F:${fat}g)';
  }

  @override
  String get editMealTitle => 'Edit Meal';

  @override
  String get createNewMealTitle => 'Create New Meal';

  @override
  String get mealNameLabel => 'Meal Name *';

  @override
  String get mealNameHint => 'e.g. Pad Krapow with fried egg';

  @override
  String get servingSizeLabel => 'Serving Size *';

  @override
  String get unitRequired => 'Unit *';

  @override
  String get ingredientsSectionTitle => 'Ingredients';

  @override
  String get aiAllButton => 'AI All';

  @override
  String get addButton => 'Add';

  @override
  String get noIngredientsHint =>
      'Tap \"Add\" button to add ingredients\nOr enter total nutrition below';

  @override
  String get totalNutritionTitle => 'Total Nutrition';

  @override
  String get saveChangesButton => 'Save Changes';

  @override
  String get saveMealButton => 'Save Meal';

  @override
  String get kcalAutoCalculated => 'kcal auto-calculated';

  @override
  String get typeIngredientNameHint => 'Type ingredient name...';

  @override
  String get searchNutritionWithAi => 'Search nutrition with AI';

  @override
  String get pleaseEnterIngredientFirst => 'Please enter ingredient name first';

  @override
  String get reAnalyzeQuestion => 'Re-analyze?';

  @override
  String reAnalyzeContent(String name) {
    return '\"$name\" already has nutrition data.\n\nAnalyzing again will use 1 Energy.\n\nContinue?';
  }

  @override
  String get cancelButton => 'Cancel';

  @override
  String get reAnalyzeEnergy => 'Re-analyze (1 Energy)';

  @override
  String get amountNotEntered => 'Amount not entered';

  @override
  String amountNotEnteredContent(String name) {
    return 'Please enter amount for \"$name\" first\ne.g. 100 (grams), 1 (piece), 200 (ml)\n\nOr use default 100 g?';
  }

  @override
  String get enterManually => 'Enter manually';

  @override
  String get use100g => 'Use 100 g';

  @override
  String get aiAnalyzeAllTitle => 'AI Analyze All';

  @override
  String aiAnalyzeAllContent(String count, String names) {
    return 'Will analyze $count items:\n$names\n\nThis will use $count Energy ($count × 1 Energy)\n\nContinue?';
  }

  @override
  String analyzeCountEnergy(String count) {
    return 'Analyze ($count Energy)';
  }

  @override
  String get noIngredientsNeedLookup => 'No ingredients need nutrition lookup';

  @override
  String get someMissingAmount => 'Some ingredients missing amount';

  @override
  String someMissingAmountContent(String names) {
    return 'The following items are missing amounts:\n$names\n\nPlease enter amounts for accurate results\nOr use default 100 g for all items?';
  }

  @override
  String get goBack => 'Go back';

  @override
  String searchSuccessCount(String success, String total) {
    return 'Search successful: $success/$total items';
  }

  @override
  String get pleaseEnterMealName => 'Please enter meal name';

  @override
  String get pleaseEnterValidServing => 'Please enter valid serving size';

  @override
  String get addSubIngredientButton => 'Add Sub-ingredient';

  @override
  String subIngredientsCount(String count) {
    return 'Sub-ingredients ($count)';
  }

  @override
  String get subIngredientNameHintCreate => 'Sub-ingredient name';

  @override
  String get editSubIngredientHint =>
      'Edit sub-ingredient amounts to adjust nutrition';

  @override
  String get pleaseEnterSubFirst => 'Please enter sub-ingredient name first';

  @override
  String aiAnalyzedEnergy(String name) {
    return 'AI analyzed \"$name\" (-1 Energy)';
  }

  @override
  String get couldNotAnalyzeSubIngredient => 'Could not analyze sub-ingredient';

  @override
  String ingredientSaved(
      String name, String amount, String unit, String calories) {
    return '$name ($amount $unit): $calories kcal — ingredient saved';
  }

  @override
  String baseNutritionInfo(String calories, String amount, String unit) {
    return 'Base: $calories kcal / $amount $unit';
  }

  @override
  String get chatContentTooLongError =>
      'รายการยาวเกินไป ช่วยแบ่งส่งทีละ 2-3 รายการได้ไหมครับ 🙏\n\nEnergy ไม่ถูกหักนะครับ';

  @override
  String get analyzeFoodImageTitle => 'วิเคราะห์รูปอาหาร';

  @override
  String get foodNameImprovesAccuracy =>
      'ระบุชื่ออาหารและปริมาณช่วยให้ AI วิเคราะห์แม่นยำขึ้น';

  @override
  String get foodNameQuantityAndModeImprovesAccuracy =>
      'ระบุชื่ออาหาร ปริมาณ และเลือกว่าเป็นอาหารหรือสินค้าจะช่วยให้ AI วิเคราะห์แม่นยำขึ้น';

  @override
  String get hideDetails => 'ซ่อนรายละเอียด';

  @override
  String get showDetails => 'แสดงรายละเอียด';

  @override
  String get searchModeLabel => 'โหมดค้นหา';

  @override
  String get normalFood => 'อาหาร';

  @override
  String get normalFoodDesc => 'อาหารทั่วไปทำกินเอง';

  @override
  String get packagedProduct => 'สินค้า';

  @override
  String get packagedProductDesc => 'สินค้าที่มีฉลากโภชนาการ';

  @override
  String get saveAndAnalyzeButton => 'วิเคราะห์';

  @override
  String get saveWithoutAnalysis => 'บันทึก';

  @override
  String get nutritionSection => 'โภชนาการ';

  @override
  String get nutritionSectionHint => 'ใส่ 0 หากไม่ทราบ';

  @override
  String get quickEditFoodName => 'แก้ไขชื่อ';

  @override
  String get quickEditCancel => 'ยกเลิก';

  @override
  String get quickEditSave => 'บันทึก';

  @override
  String get mealSuggestionsToggle => 'คำแนะนำมื้ออาหาร';

  @override
  String get mealSuggestionsOn => 'เปิด';

  @override
  String get mealSuggestionsOff => 'ปิด';

  @override
  String get basicMode => 'Basic';

  @override
  String get proMode => 'Pro';

  @override
  String get sandboxEmpty =>
      'ยังไม่มีรายการอาหาร แชท ถ่ายรูป หรือกด + เพื่อเพิ่ม!';

  @override
  String get deleteSelected => 'ลบ';

  @override
  String get useProModeForDetail => 'สำหรับแก้ไขแบบละเอียด ใช้โหมด Pro';

  @override
  String get quickAddTitle => 'เพิ่มด่วน';

  @override
  String get quickAddHint => 'เช่น ผัดไทย, ข้าวสวย...';

  @override
  String get quickCalButton => '+ cal';

  @override
  String get quickCalTitle => 'แคลอรี่ด่วน';

  @override
  String get quickCalHint => 'ใส่จำนวนแคลอรี่ (kcal)';

  @override
  String quickCalSaved(int kcal) {
    return 'Quick Cal $kcal kcal';
  }

  @override
  String get quantity => 'ปริมาณ';

  @override
  String get addToSandbox => 'เพิ่ม';

  @override
  String get gallery => 'แกลเลอรี';

  @override
  String get longPressToSelect => 'กดค้างเพื่อเลือกรายการ';

  @override
  String get healthSyncSection => 'เชื่อมต่อสุขภาพ';

  @override
  String get healthSyncTitle => 'เชื่อมต่อกับ Health App';

  @override
  String get healthSyncSubtitleOn => 'ซิงค์รายการอาหาร • รวมพลังงานที่เผาผลาญ';

  @override
  String get healthSyncSubtitleOff =>
      'แตะเพื่อเชื่อมต่อ Apple Health / Health Connect';

  @override
  String get healthSyncEnabled => 'เปิดเชื่อมต่อสุขภาพแล้ว';

  @override
  String get healthSyncDisabled => 'ปิดเชื่อมต่อสุขภาพแล้ว';

  @override
  String get healthSyncPermissionDeniedTitle => 'ต้องการสิทธิ์การเข้าถึง';

  @override
  String get healthSyncPermissionDeniedMessage =>
      'คุณเคยปฏิเสธการเข้าถึงข้อมูลสุขภาพ\nกรุณาไปเปิดที่ตั้งค่าเครื่อง';

  @override
  String get healthSyncGoToSettings => 'ไปที่ตั้งค่า';

  @override
  String healthSyncActiveEnergyValue(String value) {
    return '+$value kcal จากกิจกรรมวันนี้';
  }

  @override
  String get healthSyncNotAvailable =>
      'ไม่พบ Health Connect บนอุปกรณ์นี้ กรุณาติดตั้งแอป Health Connect';

  @override
  String get healthSyncFoodSynced => 'ซิงค์อาหารไปยัง Health App แล้ว';

  @override
  String get healthSyncFoodDeletedFromHealth => 'ลบอาหารจาก Health App แล้ว';

  @override
  String get bmrSettingTitle => 'BMR (อัตราการเผาผลาญขั้นพื้นฐาน)';

  @override
  String get bmrSettingSubtitle => 'ใช้คำนวณพลังงานจากการเคลื่อนไหว';

  @override
  String get bmrDialogTitle => 'ตั้งค่า BMR ของคุณ';

  @override
  String get bmrDialogDescription =>
      'MiRO ใช้ค่า BMR หักพลังงานพื้นฐานออกจากพลังงานรวมที่เผาผลาญ เพื่อแสดงเฉพาะพลังงานจากการเคลื่อนไหว ค่าเริ่มต้น 1500 kcal/วัน คุณสามารถดูค่า BMR ได้จากแอปสุขภาพหรือเครื่องคำนวณออนไลน์';

  @override
  String get healthSyncEnabledBmrHint =>
      'เปิด Health Sync แล้ว BMR เริ่มต้น: 1500 kcal/วัน — ปรับได้ใน Settings';

  @override
  String get privacyPolicySectionHealthData => 'การเชื่อมต่อข้อมูลสุขภาพ';

  @override
  String get termsSectionHealthDataSync => 'การซิงค์ข้อมูลสุขภาพ';

  @override
  String get tdeeLabel => 'TDEE (พลังงานที่ใช้ต่อวัน)';

  @override
  String get tdeeHint =>
      'ค่าประมาณพลังงานที่เผาผลาญต่อวัน ใช้เครื่องคำนวณด้านล่างหรือใส่เองได้';

  @override
  String get tdeeCalcTitle => 'เครื่องคำนวณ TDEE / BMR';

  @override
  String get tdeeCalcPrivacy =>
      'นี่เป็นเพียงเครื่องคำนวณ — ระบบจะไม่เก็บข้อมูลส่วนนี้';

  @override
  String get tdeeCalcGender => 'เพศ';

  @override
  String get tdeeCalcMale => 'ชาย';

  @override
  String get tdeeCalcFemale => 'หญิง';

  @override
  String get tdeeCalcAge => 'อายุ';

  @override
  String get tdeeCalcWeight => 'น้ำหนัก (กก.)';

  @override
  String get tdeeCalcHeight => 'ส่วนสูง (ซม.)';

  @override
  String get tdeeCalcWeightLbs => 'น้ำหนัก (ปอนด์)';

  @override
  String get tdeeCalcHeightIn => 'ส่วนสูง (นิ้ว)';

  @override
  String get tdeeCalcUnit => 'หน่วย';

  @override
  String get tdeeCalcUnitMetric => 'เมตริก';

  @override
  String get tdeeCalcUnitImperial => 'อิมพีเรียล';

  @override
  String get tdeeCalcActivity => 'ระดับกิจกรรม';

  @override
  String get tdeeCalcActivitySedentary => 'นั่งทำงาน (ไม่ออกกำลัง)';

  @override
  String get tdeeCalcActivityLight => 'เบา (1-2 วัน/สัปดาห์)';

  @override
  String get tdeeCalcActivityModerate => 'ปานกลาง (3-5 วัน/สัปดาห์)';

  @override
  String get tdeeCalcActivityActive => 'หนัก (6-7 วัน/สัปดาห์)';

  @override
  String get tdeeCalcActivityVeryActive => 'หนักมาก (นักกีฬา)';

  @override
  String get tdeeCalcResult => 'ค่าประมาณของคุณ';

  @override
  String tdeeCalcBmrResult(int value) {
    return 'BMR $value kcal/วัน';
  }

  @override
  String tdeeCalcTdeeResult(int value) {
    return 'TDEE $value kcal/วัน';
  }

  @override
  String get tdeeCalcApplyTdee => 'ใช้ TDEE เป็นเป้าหมายแคลอรี่';

  @override
  String get tdeeCalcApplyBmr => 'ใช้ BMR สำหรับ Health Sync';

  @override
  String get tdeeCalcApplyBoth => 'ใช้ทั้งคู่';

  @override
  String get tdeeCalcApplied => 'นำไปใช้แล้ว!';

  @override
  String get tdeeCalcBmrExplain => 'BMR = พลังงานที่ร่างกายใช้ขณะพัก';

  @override
  String get tdeeCalcTdeeExplain => 'TDEE = BMR + กิจกรรมประจำวัน';

  @override
  String get dailyBalanceLabel => 'สมดุลพลังงาน';

  @override
  String get intakeLabel => 'ทาน';

  @override
  String get burnedLabel => 'เผาผลาญ';

  @override
  String get subscriptionAutoRenew => 'ต่ออายุอัตโนมัติ';

  @override
  String get subscriptionAutoRenewOn => 'เปิด';

  @override
  String get subscriptionAutoRenewOff => 'ปิด — หมดอายุเมื่อสิ้นสุดรอบ';

  @override
  String get subscriptionManagedByAppStore =>
      'การสมัครสมาชิกจัดการผ่าน App Store';

  @override
  String get subscriptionManagedByPlayStore =>
      'การสมัครสมาชิกจัดการผ่าน Google Play';

  @override
  String get subscriptionCannotLoadPrices =>
      'ไม่สามารถโหลดราคาจาก Store ได้ในขณะนี้';
}
