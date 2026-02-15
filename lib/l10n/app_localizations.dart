import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_th.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n? of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n);
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('th')
  ];

  /// No description provided for @appName.
  ///
  /// In th, this message translates to:
  /// **'MiRO'**
  String get appName;

  /// No description provided for @save.
  ///
  /// In th, this message translates to:
  /// **'บันทึก'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In th, this message translates to:
  /// **'ยกเลิก'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In th, this message translates to:
  /// **'ลบ'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In th, this message translates to:
  /// **'แก้ไข'**
  String get edit;

  /// No description provided for @search.
  ///
  /// In th, this message translates to:
  /// **'ค้นหา'**
  String get search;

  /// No description provided for @loading.
  ///
  /// In th, this message translates to:
  /// **'กำลังโหลด...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In th, this message translates to:
  /// **'เกิดข้อผิดพลาด'**
  String get error;

  /// No description provided for @confirm.
  ///
  /// In th, this message translates to:
  /// **'ยืนยัน'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In th, this message translates to:
  /// **'ปิด'**
  String get close;

  /// No description provided for @done.
  ///
  /// In th, this message translates to:
  /// **'เสร็จ'**
  String get done;

  /// No description provided for @next.
  ///
  /// In th, this message translates to:
  /// **'ถัดไป'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In th, this message translates to:
  /// **'ข้าม'**
  String get skip;

  /// No description provided for @retry.
  ///
  /// In th, this message translates to:
  /// **'ลองใหม่'**
  String get retry;

  /// No description provided for @ok.
  ///
  /// In th, this message translates to:
  /// **'ตกลง'**
  String get ok;

  /// No description provided for @foodName.
  ///
  /// In th, this message translates to:
  /// **'ชื่ออาหาร'**
  String get foodName;

  /// No description provided for @calories.
  ///
  /// In th, this message translates to:
  /// **'แคลอรี่'**
  String get calories;

  /// No description provided for @protein.
  ///
  /// In th, this message translates to:
  /// **'โปรตีน'**
  String get protein;

  /// No description provided for @carbs.
  ///
  /// In th, this message translates to:
  /// **'คาร์บ'**
  String get carbs;

  /// No description provided for @fat.
  ///
  /// In th, this message translates to:
  /// **'ไขมัน'**
  String get fat;

  /// No description provided for @servingSize.
  ///
  /// In th, this message translates to:
  /// **'ปริมาณ'**
  String get servingSize;

  /// No description provided for @servingUnit.
  ///
  /// In th, this message translates to:
  /// **'หน่วย'**
  String get servingUnit;

  /// No description provided for @kcal.
  ///
  /// In th, this message translates to:
  /// **'kcal'**
  String get kcal;

  /// No description provided for @mealBreakfast.
  ///
  /// In th, this message translates to:
  /// **'เช้า'**
  String get mealBreakfast;

  /// No description provided for @mealLunch.
  ///
  /// In th, this message translates to:
  /// **'กลางวัน'**
  String get mealLunch;

  /// No description provided for @mealDinner.
  ///
  /// In th, this message translates to:
  /// **'เย็น'**
  String get mealDinner;

  /// No description provided for @mealSnack.
  ///
  /// In th, this message translates to:
  /// **'ของว่าง'**
  String get mealSnack;

  /// No description provided for @todaySummary.
  ///
  /// In th, this message translates to:
  /// **'สรุปวันนี้'**
  String get todaySummary;

  /// No description provided for @dateSummary.
  ///
  /// In th, this message translates to:
  /// **'สรุป {date}'**
  String dateSummary(String date);

  /// No description provided for @savedSuccess.
  ///
  /// In th, this message translates to:
  /// **'บันทึกเรียบร้อย'**
  String get savedSuccess;

  /// No description provided for @deletedSuccess.
  ///
  /// In th, this message translates to:
  /// **'ลบเรียบร้อย'**
  String get deletedSuccess;

  /// No description provided for @pleaseEnterFoodName.
  ///
  /// In th, this message translates to:
  /// **'กรุณากรอกชื่ออาหาร'**
  String get pleaseEnterFoodName;

  /// No description provided for @noDataYet.
  ///
  /// In th, this message translates to:
  /// **'ยังไม่มีข้อมูล'**
  String get noDataYet;

  /// No description provided for @addFood.
  ///
  /// In th, this message translates to:
  /// **'เพิ่มอาหาร'**
  String get addFood;

  /// No description provided for @editFood.
  ///
  /// In th, this message translates to:
  /// **'แก้ไขอาหาร'**
  String get editFood;

  /// No description provided for @deleteFood.
  ///
  /// In th, this message translates to:
  /// **'ลบอาหาร'**
  String get deleteFood;

  /// No description provided for @deleteConfirm.
  ///
  /// In th, this message translates to:
  /// **'ยืนยันการลบ?'**
  String get deleteConfirm;

  /// No description provided for @foodLoggedSuccess.
  ///
  /// In th, this message translates to:
  /// **'บันทึกอาหารแล้ว!'**
  String get foodLoggedSuccess;

  /// No description provided for @noApiKey.
  ///
  /// In th, this message translates to:
  /// **'กรุณาตั้งค่า Gemini API Key'**
  String get noApiKey;

  /// No description provided for @noApiKeyDescription.
  ///
  /// In th, this message translates to:
  /// **'ไปที่ โปรไฟล์ → API Settings เพื่อตั้งค่า'**
  String get noApiKeyDescription;

  /// No description provided for @apiKeyTitle.
  ///
  /// In th, this message translates to:
  /// **'ตั้งค่า Gemini API Key'**
  String get apiKeyTitle;

  /// No description provided for @apiKeyRequired.
  ///
  /// In th, this message translates to:
  /// **'ต้องการ API Key'**
  String get apiKeyRequired;

  /// No description provided for @apiKeyFreeNote.
  ///
  /// In th, this message translates to:
  /// **'Gemini API ใช้ฟรี ไม่ต้องจ่ายเงิน'**
  String get apiKeyFreeNote;

  /// No description provided for @apiKeySetup.
  ///
  /// In th, this message translates to:
  /// **'ตั้งค่า API Key'**
  String get apiKeySetup;

  /// No description provided for @testConnection.
  ///
  /// In th, this message translates to:
  /// **'ทดสอบการเชื่อมต่อ'**
  String get testConnection;

  /// No description provided for @connectionSuccess.
  ///
  /// In th, this message translates to:
  /// **'เชื่อมต่อสำเร็จ! พร้อมใช้งาน'**
  String get connectionSuccess;

  /// No description provided for @connectionFailed.
  ///
  /// In th, this message translates to:
  /// **'เชื่อมต่อไม่สำเร็จ'**
  String get connectionFailed;

  /// No description provided for @pasteKey.
  ///
  /// In th, this message translates to:
  /// **'วาง'**
  String get pasteKey;

  /// No description provided for @deleteKey.
  ///
  /// In th, this message translates to:
  /// **'ลบ API Key'**
  String get deleteKey;

  /// No description provided for @openAiStudio.
  ///
  /// In th, this message translates to:
  /// **'เปิด Google AI Studio'**
  String get openAiStudio;

  /// No description provided for @chatHint.
  ///
  /// In th, this message translates to:
  /// **'สั่ง Miro เช่น \"บันทึกข้าวผัด\"...'**
  String get chatHint;

  /// No description provided for @chatFoodSaved.
  ///
  /// In th, this message translates to:
  /// **'บันทึกอาหารแล้ว!'**
  String get chatFoodSaved;

  /// No description provided for @chatFoodSavedDetail.
  ///
  /// In th, this message translates to:
  /// **'{name} {serving} {unit}\n{cal} kcal'**
  String chatFoodSavedDetail(
      String name, String serving, String unit, String cal);

  /// No description provided for @featureNotAvailable.
  ///
  /// In th, this message translates to:
  /// **'ขออภัย ฟังก์ชันนี้ยังไม่พร้อมในเวอร์ชันนี้'**
  String get featureNotAvailable;

  /// No description provided for @goalCalories.
  ///
  /// In th, this message translates to:
  /// **'แคลอรี่/วัน'**
  String get goalCalories;

  /// No description provided for @goalProtein.
  ///
  /// In th, this message translates to:
  /// **'โปรตีน/วัน'**
  String get goalProtein;

  /// No description provided for @goalCarbs.
  ///
  /// In th, this message translates to:
  /// **'คาร์บ/วัน'**
  String get goalCarbs;

  /// No description provided for @goalFat.
  ///
  /// In th, this message translates to:
  /// **'ไขมัน/วัน'**
  String get goalFat;

  /// No description provided for @goalWater.
  ///
  /// In th, this message translates to:
  /// **'น้ำ/วัน'**
  String get goalWater;

  /// No description provided for @healthGoals.
  ///
  /// In th, this message translates to:
  /// **'เป้าหมายสุขภาพ'**
  String get healthGoals;

  /// No description provided for @profile.
  ///
  /// In th, this message translates to:
  /// **'โปรไฟล์'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In th, this message translates to:
  /// **'การตั้งค่า'**
  String get settings;

  /// No description provided for @privacyPolicy.
  ///
  /// In th, this message translates to:
  /// **'นโยบายความเป็นส่วนตัว'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In th, this message translates to:
  /// **'เงื่อนไขการใช้งาน'**
  String get termsOfService;

  /// No description provided for @clearAllData.
  ///
  /// In th, this message translates to:
  /// **'ล้างข้อมูลทั้งหมด'**
  String get clearAllData;

  /// No description provided for @clearAllDataConfirm.
  ///
  /// In th, this message translates to:
  /// **'ข้อมูลทั้งหมดจะถูกลบ ลบแล้วกู้คืนไม่ได้!'**
  String get clearAllDataConfirm;

  /// No description provided for @about.
  ///
  /// In th, this message translates to:
  /// **'เกี่ยวกับแอป'**
  String get about;

  /// No description provided for @language.
  ///
  /// In th, this message translates to:
  /// **'ภาษา'**
  String get language;

  /// No description provided for @upgradePro.
  ///
  /// In th, this message translates to:
  /// **'อัปเกรด Pro'**
  String get upgradePro;

  /// No description provided for @proUnlocked.
  ///
  /// In th, this message translates to:
  /// **'MiRO Pro'**
  String get proUnlocked;

  /// No description provided for @proDescription.
  ///
  /// In th, this message translates to:
  /// **'ใช้ AI วิเคราะห์อาหารไม่จำกัด'**
  String get proDescription;

  /// No description provided for @aiRemaining.
  ///
  /// In th, this message translates to:
  /// **'AI วิเคราะห์: เหลือ {remaining}/{total} ครั้งวันนี้'**
  String aiRemaining(int remaining, int total);

  /// No description provided for @aiLimitReached.
  ///
  /// In th, this message translates to:
  /// **'ใช้ AI ครบ 3 ครั้งแล้ววันนี้'**
  String get aiLimitReached;

  /// No description provided for @restorePurchase.
  ///
  /// In th, this message translates to:
  /// **'กู้คืนการซื้อ'**
  String get restorePurchase;

  /// No description provided for @myMeals.
  ///
  /// In th, this message translates to:
  /// **'เมนูของฉัน'**
  String get myMeals;

  /// No description provided for @createMeal.
  ///
  /// In th, this message translates to:
  /// **'สร้างเมนู'**
  String get createMeal;

  /// No description provided for @ingredients.
  ///
  /// In th, this message translates to:
  /// **'วัตถุดิบ'**
  String get ingredients;

  /// No description provided for @addIngredient.
  ///
  /// In th, this message translates to:
  /// **'เพิ่มวัตถุดิบ'**
  String get addIngredient;

  /// No description provided for @searchFood.
  ///
  /// In th, this message translates to:
  /// **'ค้นหาอาหาร'**
  String get searchFood;

  /// No description provided for @analyzing.
  ///
  /// In th, this message translates to:
  /// **'กำลังวิเคราะห์...'**
  String get analyzing;

  /// No description provided for @analyzeWithAi.
  ///
  /// In th, this message translates to:
  /// **'วิเคราะห์ด้วย AI'**
  String get analyzeWithAi;

  /// No description provided for @analysisComplete.
  ///
  /// In th, this message translates to:
  /// **'วิเคราะห์เสร็จ'**
  String get analysisComplete;

  /// No description provided for @timeline.
  ///
  /// In th, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// No description provided for @diet.
  ///
  /// In th, this message translates to:
  /// **'Diet'**
  String get diet;

  /// No description provided for @quickAdd.
  ///
  /// In th, this message translates to:
  /// **'Quick Add'**
  String get quickAdd;

  /// No description provided for @welcomeTitle.
  ///
  /// In th, this message translates to:
  /// **'MiRO'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In th, this message translates to:
  /// **'บันทึกอาหารง่ายๆ ด้วย AI'**
  String get welcomeSubtitle;

  /// No description provided for @onboardingFeature1.
  ///
  /// In th, this message translates to:
  /// **'ถ่ายรูปอาหาร'**
  String get onboardingFeature1;

  /// No description provided for @onboardingFeature1Desc.
  ///
  /// In th, this message translates to:
  /// **'AI วิเคราะห์ kcal อัตโนมัติ'**
  String get onboardingFeature1Desc;

  /// No description provided for @onboardingFeature2.
  ///
  /// In th, this message translates to:
  /// **'พิมพ์แชท'**
  String get onboardingFeature2;

  /// No description provided for @onboardingFeature2Desc.
  ///
  /// In th, this message translates to:
  /// **'บอกว่า \"กินข้าวผัด\" → บันทึกให้เลย'**
  String get onboardingFeature2Desc;

  /// No description provided for @onboardingFeature3.
  ///
  /// In th, this message translates to:
  /// **'สรุปทุกวัน'**
  String get onboardingFeature3;

  /// No description provided for @onboardingFeature3Desc.
  ///
  /// In th, this message translates to:
  /// **'ดู kcal, โปรตีน, คาร์บ, ไขมัน'**
  String get onboardingFeature3Desc;

  /// No description provided for @basicInfo.
  ///
  /// In th, this message translates to:
  /// **'ข้อมูลพื้นฐาน'**
  String get basicInfo;

  /// No description provided for @basicInfoDesc.
  ///
  /// In th, this message translates to:
  /// **'เพื่อคำนวณเป้าหมายแคลอรี่ที่เหมาะกับคุณ'**
  String get basicInfoDesc;

  /// No description provided for @gender.
  ///
  /// In th, this message translates to:
  /// **'เพศ'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In th, this message translates to:
  /// **'ชาย'**
  String get male;

  /// No description provided for @female.
  ///
  /// In th, this message translates to:
  /// **'หญิง'**
  String get female;

  /// No description provided for @age.
  ///
  /// In th, this message translates to:
  /// **'อายุ'**
  String get age;

  /// No description provided for @weight.
  ///
  /// In th, this message translates to:
  /// **'น้ำหนัก'**
  String get weight;

  /// No description provided for @height.
  ///
  /// In th, this message translates to:
  /// **'ส่วนสูง'**
  String get height;

  /// No description provided for @activityLevel.
  ///
  /// In th, this message translates to:
  /// **'ระดับกิจกรรม'**
  String get activityLevel;

  /// No description provided for @tdeeResult.
  ///
  /// In th, this message translates to:
  /// **'TDEE ของคุณ: {kcal} kcal/วัน'**
  String tdeeResult(int kcal);

  /// No description provided for @setupAiTitle.
  ///
  /// In th, this message translates to:
  /// **'ตั้งค่า Gemini AI'**
  String get setupAiTitle;

  /// No description provided for @setupAiDesc.
  ///
  /// In th, this message translates to:
  /// **'ถ่ายรูปอาหาร → AI วิเคราะห์ให้อัตโนมัติ'**
  String get setupAiDesc;

  /// No description provided for @setupNow.
  ///
  /// In th, this message translates to:
  /// **'ตั้งค่าเลย'**
  String get setupNow;

  /// No description provided for @skipForNow.
  ///
  /// In th, this message translates to:
  /// **'ข้ามไปก่อน → เข้าแอป'**
  String get skipForNow;

  /// No description provided for @errorTimeout.
  ///
  /// In th, this message translates to:
  /// **'หมดเวลาเชื่อมต่อ — ลองใหม่อีกครั้ง'**
  String get errorTimeout;

  /// No description provided for @errorInvalidKey.
  ///
  /// In th, this message translates to:
  /// **'API Key ไม่ถูกต้อง — ตรวจสอบการตั้งค่า'**
  String get errorInvalidKey;

  /// No description provided for @errorNoInternet.
  ///
  /// In th, this message translates to:
  /// **'ไม่มีอินเทอร์เน็ต — ตรวจสอบการเชื่อมต่อ'**
  String get errorNoInternet;

  /// No description provided for @errorGeneral.
  ///
  /// In th, this message translates to:
  /// **'เกิดข้อผิดพลาด — ลองใหม่อีกครั้ง'**
  String get errorGeneral;

  /// No description provided for @errorQuotaExceeded.
  ///
  /// In th, this message translates to:
  /// **'ใช้ API เกินโควต้า — รอสักครู่แล้วลองใหม่'**
  String get errorQuotaExceeded;

  /// No description provided for @apiKeyScreenTitle.
  ///
  /// In th, this message translates to:
  /// **'ตั้งค่า Gemini API Key'**
  String get apiKeyScreenTitle;

  /// No description provided for @analyzeFoodWithAi.
  ///
  /// In th, this message translates to:
  /// **'วิเคราะห์อาหารด้วย AI'**
  String get analyzeFoodWithAi;

  /// No description provided for @analyzeFoodWithAiDesc.
  ///
  /// In th, this message translates to:
  /// **'ถ่ายรูปอาหาร → AI คำนวณแคลอรี่ให้อัตโนมัติ\nGemini API ใช้ฟรี ไม่ต้องจ่ายเงิน!'**
  String get analyzeFoodWithAiDesc;

  /// No description provided for @openGoogleAiStudio.
  ///
  /// In th, this message translates to:
  /// **'เปิด Google AI Studio'**
  String get openGoogleAiStudio;

  /// No description provided for @step1Title.
  ///
  /// In th, this message translates to:
  /// **'เปิด Google AI Studio'**
  String get step1Title;

  /// No description provided for @step1Desc.
  ///
  /// In th, this message translates to:
  /// **'กดปุ่มด้านล่างเพื่อไปสร้าง API Key'**
  String get step1Desc;

  /// No description provided for @step2Title.
  ///
  /// In th, this message translates to:
  /// **'ล็อกอิน Google Account'**
  String get step2Title;

  /// No description provided for @step2Desc.
  ///
  /// In th, this message translates to:
  /// **'ใช้ Gmail หรือ Google Account ที่มีอยู่ (ถ้ายังไม่มี สร้างฟรี)'**
  String get step2Desc;

  /// No description provided for @step3Title.
  ///
  /// In th, this message translates to:
  /// **'คลิก \"Create API Key\"'**
  String get step3Title;

  /// No description provided for @step3Desc.
  ///
  /// In th, this message translates to:
  /// **'กดปุ่มสีน้ำเงิน \"Create API Key\"\nถ้าถามให้เลือก Project → กด \"Create API key in new project\"'**
  String get step3Desc;

  /// No description provided for @step4Title.
  ///
  /// In th, this message translates to:
  /// **'คัดลอก Key แล้วกลับมาวางด้านล่าง'**
  String get step4Title;

  /// No description provided for @step4Desc.
  ///
  /// In th, this message translates to:
  /// **'กดปุ่ม Copy ข้างกล่อง Key ที่สร้างเสร็จ\nKey จะหน้าตาประมาณ: AIzaSyxxxx...'**
  String get step4Desc;

  /// No description provided for @step5Title.
  ///
  /// In th, this message translates to:
  /// **'วาง API Key ที่นี่'**
  String get step5Title;

  /// No description provided for @pasteApiKeyHint.
  ///
  /// In th, this message translates to:
  /// **'วาง API Key ที่คัดลอกมา'**
  String get pasteApiKeyHint;

  /// No description provided for @saveApiKey.
  ///
  /// In th, this message translates to:
  /// **'บันทึก API Key'**
  String get saveApiKey;

  /// No description provided for @testingConnection.
  ///
  /// In th, this message translates to:
  /// **'กำลังทดสอบ...'**
  String get testingConnection;

  /// No description provided for @deleteApiKey.
  ///
  /// In th, this message translates to:
  /// **'ลบ API Key'**
  String get deleteApiKey;

  /// No description provided for @deleteApiKeyConfirm.
  ///
  /// In th, this message translates to:
  /// **'ลบ API Key?'**
  String get deleteApiKeyConfirm;

  /// No description provided for @deleteApiKeyConfirmDesc.
  ///
  /// In th, this message translates to:
  /// **'จะไม่สามารถใช้ AI วิเคราะห์อาหารได้จนกว่าจะตั้งค่าใหม่'**
  String get deleteApiKeyConfirmDesc;

  /// No description provided for @apiKeySaved.
  ///
  /// In th, this message translates to:
  /// **'บันทึก API Key เรียบร้อย'**
  String get apiKeySaved;

  /// No description provided for @apiKeyDeleted.
  ///
  /// In th, this message translates to:
  /// **'ลบ API Key เรียบร้อย'**
  String get apiKeyDeleted;

  /// No description provided for @pleasePasteApiKey.
  ///
  /// In th, this message translates to:
  /// **'กรุณาวาง API Key ก่อน'**
  String get pleasePasteApiKey;

  /// No description provided for @apiKeyInvalidFormat.
  ///
  /// In th, this message translates to:
  /// **'API Key ไม่ถูกต้อง — ต้องขึ้นต้นด้วย \"AIza\"'**
  String get apiKeyInvalidFormat;

  /// No description provided for @connectionSuccessMessage.
  ///
  /// In th, this message translates to:
  /// **'✅ เชื่อมต่อสำเร็จ! พร้อมใช้งาน'**
  String get connectionSuccessMessage;

  /// No description provided for @connectionFailedMessage.
  ///
  /// In th, this message translates to:
  /// **'❌ เชื่อมต่อไม่สำเร็จ'**
  String get connectionFailedMessage;

  /// No description provided for @faqTitle.
  ///
  /// In th, this message translates to:
  /// **'คำถามที่พบบ่อย'**
  String get faqTitle;

  /// No description provided for @faqFreeQuestion.
  ///
  /// In th, this message translates to:
  /// **'ฟรีจริงไหม?'**
  String get faqFreeQuestion;

  /// No description provided for @faqFreeAnswer.
  ///
  /// In th, this message translates to:
  /// **'ฟรีจริง! Gemini 2.0 Flash ใช้ฟรี 1,500 ครั้ง/วัน\nสำหรับบันทึกอาหาร (5-15 ครั้ง/วัน) → ฟรีตลอด ไม่ต้องจ่ายเงิน'**
  String get faqFreeAnswer;

  /// No description provided for @faqSafeQuestion.
  ///
  /// In th, this message translates to:
  /// **'ปลอดภัยไหม?'**
  String get faqSafeQuestion;

  /// No description provided for @faqSafeAnswer.
  ///
  /// In th, this message translates to:
  /// **'API Key เก็บใน Secure Storage ในเครื่องเท่านั้น\nแอปไม่ส่ง Key ไปที่ server ของเรา\nถ้า Key หลุด → ลบทิ้งสร้างใหม่ได้เลย (ไม่ใช่รหัสผ่าน Google)'**
  String get faqSafeAnswer;

  /// No description provided for @faqNoKeyQuestion.
  ///
  /// In th, this message translates to:
  /// **'ถ้าไม่สร้าง Key ล่ะ?'**
  String get faqNoKeyQuestion;

  /// No description provided for @faqNoKeyAnswer.
  ///
  /// In th, this message translates to:
  /// **'ยังใช้แอปได้! แต่:\n❌ ไม่สามารถถ่ายรูป → AI วิเคราะห์\n✅ บันทึกอาหารด้วยมือได้\n✅ Quick Add ได้\n✅ ดูสรุป kcal/macro ได้'**
  String get faqNoKeyAnswer;

  /// No description provided for @faqCreditCardQuestion.
  ///
  /// In th, this message translates to:
  /// **'ต้องมีบัตรเครดิตไหม?'**
  String get faqCreditCardQuestion;

  /// No description provided for @faqCreditCardAnswer.
  ///
  /// In th, this message translates to:
  /// **'ไม่ต้อง — สร้าง API Key ได้ฟรีโดยไม่ต้องใส่บัตรเครดิต'**
  String get faqCreditCardAnswer;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'th'].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return L10nEn();
    case 'th':
      return L10nTh();
  }

  throw FlutterError(
      'L10n.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
