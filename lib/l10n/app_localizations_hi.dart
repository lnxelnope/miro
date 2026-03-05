// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class L10nHi extends L10n {
  L10nHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'MiRO';

  @override
  String get save => 'बचाना';

  @override
  String get cancel => 'रद्द करना';

  @override
  String get delete => 'मिटाना';

  @override
  String get edit => 'संपादन करना';

  @override
  String get search => 'खोज';

  @override
  String get loading => 'लोड हो रहा है...';

  @override
  String get error => 'एक त्रुटि पाई गई';

  @override
  String get confirm => 'पुष्टि करना';

  @override
  String get close => 'बंद करना';

  @override
  String get done => 'हो गया';

  @override
  String get next => 'अगला';

  @override
  String get skip => 'छोडना';

  @override
  String get retry => 'पुन: प्रयास करें';

  @override
  String get ok => 'ठीक है';

  @override
  String get foodName => 'भोजन का नाम';

  @override
  String get calories => 'कैलोरी';

  @override
  String get protein => 'Proटीन';

  @override
  String get carbs => 'कार्बोहाइड्रेट';

  @override
  String get fat => 'मोटा';

  @override
  String get servingSize => 'सेवारत आकार';

  @override
  String get servingUnit => 'इकाई';

  @override
  String get kcal => 'kcal';

  @override
  String get mealBreakfast => 'नाश्ता';

  @override
  String get mealLunch => 'दिन का खाना';

  @override
  String get mealDinner => 'रात का खाना';

  @override
  String get mealSnack => 'नाश्ता';

  @override
  String get todaySummary => 'आज का सारांश';

  @override
  String get nutritionSummary => 'Nutrition Summary';

  @override
  String dateSummary(String date) {
    return '$date के लिए सारांश';
  }

  @override
  String get periodAll => 'All';

  @override
  String get macroDistribution => 'Macro Distribution';

  @override
  String get calorieTrend => 'Calorie Trend';

  @override
  String get calorieTrend7Days => 'Calorie Trend (7 days)';

  @override
  String get micronutrientTracker => 'Micronutrient Tracker';

  @override
  String get fatBreakdown => 'Fat Breakdown';

  @override
  String get goal => 'Goal';

  @override
  String get over => 'OVER';

  @override
  String get saturated => 'Saturated';

  @override
  String get mono => 'Mono';

  @override
  String get poly => 'Poly';

  @override
  String get trans => 'Trans';

  @override
  String noDataFor(String title) {
    return 'No data for $title';
  }

  @override
  String errorColon(String error) {
    return 'Error: $error';
  }

  @override
  String get savedSuccess => 'सफलतापूर्वक बचाया';

  @override
  String get deletedSuccess => 'सफलतापूर्वक मिटाया गया';

  @override
  String get pleaseEnterFoodName => 'कृपया भोजन का नाम दर्ज करें';

  @override
  String get noDataYet => 'अभी तक कोई डेटा नहीं';

  @override
  String get addFood => 'भोजन जोड़ें';

  @override
  String get editFood => 'भोजन संपादित करें';

  @override
  String get deleteFood => 'खाना हटा दें';

  @override
  String get deleteConfirm => 'हटाने की पुष्टि करें?';

  @override
  String get foodLoggedSuccess => 'भोजन लॉग किया गया!';

  @override
  String get noApiKey => 'कृपया Gemini API Key सेट करें';

  @override
  String get noApiKeyDescription =>
      'सेट अप करने के लिए Profile → API सेटिंग्स पर जाएं';

  @override
  String get apiKeyTitle => 'Gemini API Key सेट करें';

  @override
  String get apiKeyRequired => 'API Key आवश्यक';

  @override
  String get apiKeyFreeNote => 'Gemini API का उपयोग निःशुल्क है';

  @override
  String get apiKeySetup => 'API Key सेट करें';

  @override
  String get testConnection => 'कनेक्शन का परीक्षण करें';

  @override
  String get connectionSuccess =>
      'सफलतापूर्वक कनेक्ट हो गया! इस्तेमाल के लिए तैयार';

  @override
  String get connectionFailed => 'कनेक्शन विफल';

  @override
  String get pasteKey => 'पेस्ट करें';

  @override
  String get deleteKey => 'API Key हटाएं';

  @override
  String get openAiStudio => 'Google AI Studio खोलें';

  @override
  String get chatHint => 'Miro बताएं जैसे \"लॉग फ्राइड राइस\"...';

  @override
  String get chatFoodSaved => 'भोजन लॉग किया गया!';

  @override
  String chatFoodSavedDetail(
      String name, String serving, String unit, String cal) {
    return '$name $serving $unit\n$cal kcal';
  }

  @override
  String get featureNotAvailable =>
      'क्षमा करें, यह सुविधा अभी तक उपलब्ध नहीं है';

  @override
  String get goalCalories => 'कैलोरी/दिन';

  @override
  String get goalProtein => 'Proतीन/दिन';

  @override
  String get goalCarbs => 'कार्ब्स/दिन';

  @override
  String get goalFat => 'मोटा/दिन';

  @override
  String get goalWater => 'जल डे';

  @override
  String get healthGoals => 'स्वास्थ्य लक्ष्य';

  @override
  String get profile => 'Proफ़ाइल';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get privacyPolicy => 'गोपनीयता नीति';

  @override
  String get termsOfService => 'सेवा की शर्तें';

  @override
  String get clearAllData => 'सभी डेटा साफ़ करें';

  @override
  String get clearAllDataConfirm =>
      'सारा डेटा हटा दिया जाएगा. इसे असंपादित नहीं किया जा सकता है!';

  @override
  String get about => 'के बारे में';

  @override
  String get language => 'भाषा';

  @override
  String get upgradePro => 'Pro पर अपग्रेड करें';

  @override
  String get proUnlocked => 'MiRO Pro';

  @override
  String get proDescription => 'असीमित एआई खाद्य विश्लेषण';

  @override
  String aiRemaining(int remaining, int total) {
    return 'एआई विश्लेषण: $remaining/$total आज शेष है';
  }

  @override
  String get aiLimitReached => 'आज के लिए AI सीमा पूरी हो गई (3/3)';

  @override
  String get restorePurchase => 'पुनःस्थापन क्रय';

  @override
  String get restorePurchaseSubtitle => 'Restore your Energy Pass subscription';

  @override
  String get restorePurchaseRestoring => 'Restoring purchases…';

  @override
  String get restorePurchaseSuccess => 'Purchase restored successfully!';

  @override
  String get restorePurchaseNotFound =>
      'No previous purchases found for this Apple ID';

  @override
  String get restorePurchaseFailed =>
      'Failed to restore purchase. Please try again.';

  @override
  String get myMeals => 'मेरा भोजन:';

  @override
  String get createMeal => 'भोजन बनाएँ';

  @override
  String get ingredients => 'Ingredients';

  @override
  String get searchFood => 'भोजन खोजें';

  @override
  String get analyzing => 'विश्लेषण कर रहा हूँ...';

  @override
  String get analyzeWithAi => 'एआई के साथ विश्लेषण करें';

  @override
  String get analysisComplete => 'विश्लेषण पूरा हुआ';

  @override
  String get timeline => 'समय';

  @override
  String get diet => 'आहार';

  @override
  String get quickAdd => 'शीघ्र जोड़ें';

  @override
  String get welcomeTitle => 'MiRO';

  @override
  String get welcomeSubtitle => 'एआई के साथ आसान भोजन लॉगिंग';

  @override
  String get onboardingFeature1 => 'एक फोटो खींचो';

  @override
  String get onboardingFeature1Desc =>
      'AI स्वचालित रूप से कैलोरी की गणना करता है';

  @override
  String get onboardingFeature2 => 'लॉग करने के लिए टाइप करें';

  @override
  String get onboardingFeature2Desc =>
      'कहें \"तला हुआ चावल खाया\" और यह लॉग हो गया';

  @override
  String get onboardingFeature3 => 'दैनिक सारांश';

  @override
  String get onboardingFeature3Desc =>
      'ट्रैक kcal, प्रोटीन, कार्बोहाइड्रेट, वसा';

  @override
  String get basicInfo => 'बुनियादी जानकारी';

  @override
  String get basicInfoDesc => 'आपकी अनुशंसित दैनिक कैलोरी की गणना करने के लिए';

  @override
  String get gender => 'लिंग';

  @override
  String get male => 'पुरुष';

  @override
  String get female => 'महिला';

  @override
  String get age => 'आयु';

  @override
  String get weight => 'वज़न';

  @override
  String get height => 'ऊंचाई';

  @override
  String get activityLevel => 'गतिविधि स्तर';

  @override
  String tdeeResult(int kcal) {
    return 'आपका TDEE: $kcal kcal/दिन';
  }

  @override
  String get setupAiTitle => 'Gemini AI सेट करें';

  @override
  String get setupAiDesc =>
      'एक फोटो खींचें और AI स्वचालित रूप से उसका विश्लेषण करेगा';

  @override
  String get setupNow => 'अभी सेट करें';

  @override
  String get skipForNow => 'अभी के लिए छोड़ दे';

  @override
  String get errorTimeout => 'कनेक्शन समयबाह्य - कृपया पुनः प्रयास करें';

  @override
  String get errorInvalidKey => 'अमान्य API Key — अपनी सेटिंग्स जांचें';

  @override
  String get errorNoInternet => 'कोई इंटरनेट कनेक्शन नहीं';

  @override
  String get errorGeneral => 'एक त्रुटि हुई थी। कृपया दोबारा प्रयास करें';

  @override
  String get errorQuotaExceeded =>
      'API कोटा पार हो गया - कृपया प्रतीक्षा करें और पुनः प्रयास करें';

  @override
  String get apiKeyScreenTitle => 'Gemini API Key सेट करें';

  @override
  String get analyzeFoodWithAi => 'एआई के साथ भोजन का विश्लेषण करें';

  @override
  String get analyzeFoodWithAiDesc =>
      'एक फोटो खींचें → AI स्वचालित रूप से कैलोरी की गणना करता है\nGemini API का उपयोग निःशुल्क है!';

  @override
  String get openGoogleAiStudio => 'Google AI Studio खोलें';

  @override
  String get step1Title => 'Google AI Studio खोलें';

  @override
  String get step1Desc => 'API Key बनाने के लिए नीचे दिए गए बटन पर क्लिक करें';

  @override
  String get step2Title => 'Google खाते से साइन इन करें';

  @override
  String get step2Desc =>
      'अपने जीमेल या Google खाते का उपयोग करें (यदि आपके पास एक नहीं है तो निःशुल्क बनाएं)';

  @override
  String get step3Title => '\"बनाएंAPI Key\" पर क्लिक करें';

  @override
  String get step3Desc =>
      'नीले \"Create API Key\" बटन पर क्लिक करें\nयदि Project चुनने के लिए कहा जाए तो → \"नए प्रोजेक्ट में API कुंजी बनाएं\" पर क्लिक करें';

  @override
  String get step4Title => 'कुंजी की प्रतिलिपि बनाएँ और नीचे चिपकाएँ';

  @override
  String get step4Desc =>
      'बनाई गई कुंजी के आगे कॉपी पर क्लिक करें\nकुंजी इस तरह दिखेगी: AIzaSyxxx...';

  @override
  String get step5Title => 'API Key को यहां चिपकाएं';

  @override
  String get pasteApiKeyHint => 'कॉपी किया गया API Key चिपकाएँ';

  @override
  String get saveApiKey => 'API Key सहेजें';

  @override
  String get testingConnection => 'परीक्षण...';

  @override
  String get deleteApiKey => 'API Key हटाएं';

  @override
  String get deleteApiKeyConfirm => 'API Key हटाएं?';

  @override
  String get deleteApiKeyConfirmDesc =>
      'जब तक आप इसे दोबारा सेट नहीं करेंगे तब तक आप एआई खाद्य विश्लेषण का उपयोग नहीं कर पाएंगे';

  @override
  String get apiKeySaved => 'API Key सफलतापूर्वक सहेजा गया';

  @override
  String get apiKeyDeleted => 'API Key सफलतापूर्वक हटा दिया गया';

  @override
  String get pleasePasteApiKey => 'कृपया पहले API Key पेस्ट करें';

  @override
  String get apiKeyInvalidFormat =>
      'अमान्य API Key - \"AIza\" से शुरू होना चाहिए';

  @override
  String get connectionSuccessMessage =>
      '✅ सफलतापूर्वक कनेक्ट हो गया! इस्तेमाल के लिए तैयार';

  @override
  String get connectionFailedMessage => '❌ कनेक्शन विफल';

  @override
  String get faqTitle => 'अक्सर पूछे जाने वाले प्रश्नों';

  @override
  String get faqFreeQuestion => 'क्या यह सचमुच मुफ़्त है?';

  @override
  String get faqFreeAnswer =>
      'हाँ! Gemini 2.0 फ्लैश 1,500 अनुरोध/दिन के लिए निःशुल्क है\nभोजन लॉगिंग के लिए (5-15 बार/दिन) → हमेशा के लिए निःशुल्क, किसी भुगतान की आवश्यकता नहीं';

  @override
  String get faqSafeQuestion => 'क्या यह सुरक्षित है?';

  @override
  String get faqSafeAnswer =>
      'API Key केवल आपके डिवाइस पर सिक्योर स्टोरेज में संग्रहीत है\nऐप हमारे सर्वर पर कुंजी नहीं भेजता है\nयदि कुंजी लीक हो जाती है → हटाएं और एक नया पासवर्ड बनाएं (यह आपका Google पासवर्ड नहीं है)';

  @override
  String get faqNoKeyQuestion => 'यदि मैं कुंजी नहीं बनाऊं तो क्या होगा?';

  @override
  String get faqNoKeyAnswer =>
      'आप अभी भी ऐप का उपयोग कर सकते हैं! लेकिन:\n❌ फ़ोटो नहीं ले सकते → AI विश्लेषण\n✅ भोजन को मैन्युअल रूप से लॉग कर सकते हैं\n✅ त्वरित जोड़ें कार्य करता है\n✅ kcal/मैक्रो सारांश कार्य देखें';

  @override
  String get faqCreditCardQuestion => 'क्या मुझे क्रेडिट कार्ड की आवश्यकता है?';

  @override
  String get faqCreditCardAnswer =>
      'नहीं - बिना क्रेडिट कार्ड के निःशुल्क API Key बनाएं';

  @override
  String get navDashboard => 'डैशबोर्ड';

  @override
  String get navMyMeals => 'मेरा भोजन';

  @override
  String get navCamera => 'कैमरा';

  @override
  String get navGallery => 'Gallery';

  @override
  String get navAiChat => 'एआई चैट';

  @override
  String get navProfile => 'Proफ़ाइल';

  @override
  String get appBarTodayIntake => 'आज का सेवन';

  @override
  String get appBarMyMeals => 'मेरा भोजन';

  @override
  String get appBarCamera => 'कैमरा';

  @override
  String get appBarAiChat => 'एआई चैट';

  @override
  String get appBarMiro => 'मिरो';

  @override
  String get permissionRequired => 'अनुमति आवश्यक है';

  @override
  String get permissionRequiredDesc =>
      'MIRO को निम्नलिखित तक पहुंच की आवश्यकता है:';

  @override
  String get permissionPhotos => 'तस्वीरें - भोजन स्कैन करने के लिए';

  @override
  String get permissionCamera => 'कैमरा - भोजन की तस्वीरें खींचने के लिए';

  @override
  String get permissionSkip => 'छोडना';

  @override
  String get permissionAllow => 'अनुमति दें';

  @override
  String get permissionAllGranted => 'सभी अनुमतियाँ प्रदान की गईं';

  @override
  String permissionDenied(String denied) {
    return 'अनुमति अस्वीकृत: $denied';
  }

  @override
  String get openSettings => 'खुली सेटिंग';

  @override
  String get exitAppTitle => 'ऐप से बाहर निकलें?';

  @override
  String get exitAppMessage =>
      'क्या आप निश्चित हैं आपकी बाहर निकलने की इच्छा है?';

  @override
  String get exit => 'बाहर निकलना';

  @override
  String get healthGoalsTitle => 'स्वास्थ्य लक्ष्य';

  @override
  String get healthGoalsInfo =>
      'अपना दैनिक कैलोरी लक्ष्य, मैक्रोज़ और प्रति-भोजन बजट निर्धारित करें।\nस्वतः-गणना करने के लिए लॉक करें: 2 मैक्रोज़ या 3 भोजन।';

  @override
  String get dailyCalorieGoal => 'दैनिक कैलोरी लक्ष्य';

  @override
  String get proteinLabel => 'Proटीन';

  @override
  String get carbsLabel => 'कार्बोहाइड्रेट';

  @override
  String get fatLabel => 'मोटा';

  @override
  String get autoBadge => 'ऑटो';

  @override
  String kcalPerGram(int kcalPerGram, int kcal) {
    return '$kcalPerGram kcal/g • $kcal __SW0__';
  }

  @override
  String get mealCalorieBudget => 'भोजन कैलोरी बजट';

  @override
  String mealBudgetBalanced(int total, int goal) {
    return 'कुल $total kcal = लक्ष्य $goal __SW0__';
  }

  @override
  String mealBudgetRemaining(int total, int goal, int remaining) {
    return 'कुल $total / $goal kcal ($remaining शेष)';
  }

  @override
  String get lockMealsHint => 'चौथे की स्वतः गणना करने के लिए 3 भोजन लॉक करें';

  @override
  String get breakfastLabel => 'नाश्ता';

  @override
  String get lunchLabel => 'दिन का खाना';

  @override
  String get dinnerLabel => 'रात का खाना';

  @override
  String get snackLabel => 'नाश्ता';

  @override
  String percentOfDailyGoal(String percent) {
    return 'दैनिक लक्ष्य का $percent%';
  }

  @override
  String get smartSuggestionRange => 'स्मार्ट सुझाव रेंज';

  @override
  String get smartSuggestionHow => 'स्मार्ट सुझाव कैसे काम करता है?';

  @override
  String smartSuggestionDesc(int threshold, int min, int max) {
    return 'हम आपके मेरे भोजन, सामग्री और कल के भोजन से ऐसे खाद्य पदार्थों का सुझाव देते हैं जो आपके प्रति भोजन बजट के अनुरूप हों।\n\nयह सीमा नियंत्रित करती है कि सुझाव कितने लचीले हैं। उदाहरण के लिए, यदि आपके दोपहर के भोजन का बजट 700 kcal है और सीमा $threshold __SW0__ है, तो हम $min–$max __SW0__ के बीच भोजन का सुझाव देंगे।';
  }

  @override
  String get suggestionThreshold => 'सुझाव सीमा';

  @override
  String suggestionThresholdDesc(int threshold) {
    return 'भोजन बजट से खाद्य पदार्थों की अनुमति दें ± $threshold kcal';
  }

  @override
  String get goalsSavedSuccess => 'लक्ष्य सफलतापूर्वक सहेजे गए!';

  @override
  String get canOnlyLockTwoMacros =>
      'एक बार में केवल 2 मैक्रोज़ को लॉक किया जा सकता है';

  @override
  String get canOnlyLockThreeMeals =>
      'केवल 3 भोजन लॉक कर सकते हैं; चौथा स्वतः गणना करता है';

  @override
  String get tabMeals => 'भोजन';

  @override
  String get tabIngredients => 'सामग्री';

  @override
  String get searchMealsOrIngredients => 'भोजन या सामग्री खोजें...';

  @override
  String get createNewMeal => 'नया भोजन बनाएं';

  @override
  String get addIngredient => 'सामग्री जोड़ें';

  @override
  String get noMealsYet => 'अभी तक भोजन नहीं';

  @override
  String get noMealsYetDesc =>
      'भोजन को स्वतः सहेजने के लिए AI के साथ भोजन का विश्लेषण करें\nया मैन्युअल रूप से एक बनाएं';

  @override
  String get noIngredientsYet => 'अभी तक कोई सामग्री नहीं';

  @override
  String get noIngredientsYetDesc =>
      'जब आप एआई के साथ भोजन का विश्लेषण करते हैं\nसामग्री स्वचालित रूप से सहेजी जाएगी';

  @override
  String mealCreated(String name) {
    return '\"$name\" बनाया गया';
  }

  @override
  String mealLogged(String name) {
    return 'लॉग किया गया \"$name\"';
  }

  @override
  String ingredientAmount(String unit) {
    return 'राशि ($unit)';
  }

  @override
  String ingredientLogged(String name, String amount, String unit) {
    return 'लॉग किया गया \"$name\" $amount$unit';
  }

  @override
  String get mealNotFound => 'भोजन नहीं मिला';

  @override
  String mealUpdated(String name) {
    return 'अपडेट किया गया \"$name\"';
  }

  @override
  String get deleteMealTitle => 'भोजन हटाएं?';

  @override
  String deleteMealMessage(String name) {
    return '\"$name\"';
  }

  @override
  String get deleteMealNote => 'सामग्री हटाई नहीं जाएगी.';

  @override
  String get mealDeleted => 'भोजन हटा दिया गया';

  @override
  String ingredientCreated(String name) {
    return '\"$name\" बनाया गया';
  }

  @override
  String get ingredientNotFound => 'घटक नहीं मिला';

  @override
  String ingredientUpdated(String name) {
    return 'अपडेट किया गया \"$name\"';
  }

  @override
  String get deleteIngredientTitle => 'संघटक हटाएँ?';

  @override
  String deleteIngredientMessage(String name) {
    return '\"$name\"';
  }

  @override
  String get ingredientDeleted => 'घटक हटा दिया गया';

  @override
  String get noIngredientsData => 'कोई सामग्री डेटा नहीं';

  @override
  String ingredientDetail(String name, String amount, String unit) {
    return '$name ($amount $unit)';
  }

  @override
  String ingredientCalories(int calories) {
    return '$calories kcal';
  }

  @override
  String get useThisMeal => 'इस भोजन का प्रयोग करें';

  @override
  String errorLoading(String error) {
    return 'लोड करने में त्रुटि: $error';
  }

  @override
  String scanFoundNewImages(int count, String date) {
    return '$date पर $count नई छवियाँ मिलीं';
  }

  @override
  String scanNoNewImages(String date) {
    return '$date पर कोई नई छवि नहीं मिली';
  }

  @override
  String aiAnalysisRemaining(int remaining, int total) {
    return 'एआई विश्लेषण: $remaining/$total आज शेष है';
  }

  @override
  String get upgradeToProUnlimited => 'असीमित उपयोग के लिए Pro पर अपग्रेड करें';

  @override
  String get upgrade => 'उन्नत करना';

  @override
  String get confirmDelete => 'हटाने की पुष्टि करें';

  @override
  String confirmDeleteMessage(String name) {
    return 'क्या आप \"$name\" को हटाना चाहते हैं?';
  }

  @override
  String get entryDeletedSuccess => '✅ प्रविष्टि सफलतापूर्वक हटा दी गई';

  @override
  String entryDeleteError(String error) {
    return '❌ त्रुटि: $error';
  }

  @override
  String batchAnalyzeItems(int count) {
    return '$count आइटम (बैच)';
  }

  @override
  String analyzeCancelled(int success) {
    return 'रद्द किया गया - $success आइटम का सफलतापूर्वक विश्लेषण किया गया';
  }

  @override
  String analyzeSuccessAll(int success) {
    return '✅ $success आइटम का सफलतापूर्वक विश्लेषण किया गया';
  }

  @override
  String analyzeSuccessPartial(int success, int total, int failed) {
    return '⚠️ $success/$total आइटम का विश्लेषण किया गया ($failed विफल)';
  }

  @override
  String analyzeProgress(String item, int current, int total) {
    return '$item ($current/$total)';
  }

  @override
  String get pullToScanMeal => 'अपने भोजन को स्कैन करने के लिए खींचें';

  @override
  String get analyzeAll => 'सभी का विश्लेषण करें';

  @override
  String get addFoodTitle => 'भोजन जोड़ें';

  @override
  String get foodNameRequired => 'भोजन का नाम*';

  @override
  String get foodNameHint =>
      'खोजने के लिए टाइप करें उदा. तला हुआ चावल, पपीता सलाद';

  @override
  String get selectedFromMyMeal =>
      '✅ मेरा भोजन से चयनित - पोषण डेटा स्वतः भरा हुआ';

  @override
  String get foundInDatabase => '✅ डेटाबेस में मिला - पोषण डेटा स्वतः भरा हुआ';

  @override
  String get saveAndAnalyze => 'सहेजें और विश्लेषण करें';

  @override
  String get notFoundInDatabase =>
      'डेटाबेस में नहीं मिला - पृष्ठभूमि में विश्लेषण किया जाएगा';

  @override
  String get amountLabel => 'मात्रा';

  @override
  String get unitLabel => 'इकाई';

  @override
  String get nutritionAutoCalculated => 'पोषण (राशि द्वारा स्वतः गणना)';

  @override
  String get nutritionEnterZero => 'पोषण (यदि अज्ञात हो तो 0 दर्ज करें)';

  @override
  String get caloriesLabel => 'कैलोरी (kcal)';

  @override
  String get proteinLabelShort => 'Proटीन (जी)';

  @override
  String get carbsLabelShort => 'कार्ब्स (जी)';

  @override
  String get fatLabelShort => 'वसा (जी)';

  @override
  String get mealTypeLabel => 'भोजन का प्रकार';

  @override
  String get pleaseEnterFoodNameFirst => 'कृपया पहले भोजन का नाम दर्ज करें';

  @override
  String get savedAnalyzingBackground => '✅ सहेजा गया - पृष्ठभूमि में विश्लेषण';

  @override
  String get foodAdded => '✅ भोजन जोड़ा गया';

  @override
  String get suggestionSourceMyMeal => 'मेरा भोजन';

  @override
  String get suggestionSourceIngredient => 'घटक';

  @override
  String get suggestionSourceDatabase => 'डेटाबेस';

  @override
  String get editFoodTitle => 'भोजन संपादित करें';

  @override
  String get foodNameLabel => 'भोजन का नाम';

  @override
  String get changeAmountAutoUpdate =>
      'मात्रा बदलें → कैलोरी स्वचालित रूप से अपडेट हो जाती है';

  @override
  String baseNutrition(int calories, String unit) {
    return 'आधार: $calories kcal / 1 $unit';
  }

  @override
  String get calculatedFromIngredients => 'नीचे दी गई सामग्रियों से गणना की गई';

  @override
  String get ingredientsEditable => 'सामग्री (संपादन योग्य)';

  @override
  String get addIngredientButton => 'जोड़ना';

  @override
  String get noIngredientsAddHint =>
      'कोई सामग्री नहीं - नई सामग्री जोड़ने के लिए \"जोड़ें\" पर टैप करें';

  @override
  String get editIngredientsHint =>
      'नाम/राशि संपादित करें → डेटाबेस या एआई खोजने के लिए खोज आइकन टैप करें';

  @override
  String get ingredientNameHint => 'जैसे मुर्गी का अंडा';

  @override
  String get searchDbOrAi => 'डीबी/एआई खोजें';

  @override
  String get amountHint => 'मात्रा';

  @override
  String get fromDatabase => 'डेटाबेस से';

  @override
  String subIngredients(int count) {
    return 'उप-सामग्री ($count)';
  }

  @override
  String get addSubIngredient => 'जोड़ना';

  @override
  String get subIngredientNameHint => 'उप-घटक का नाम';

  @override
  String get amountShort => 'राशि';

  @override
  String get pleaseEnterSubIngredientName =>
      'कृपया पहले उप-घटक का नाम दर्ज करें';

  @override
  String foundInDatabaseSub(String name) {
    return 'डेटाबेस में \"$name\" मिला!';
  }

  @override
  String aiAnalyzedSub(String name) {
    return 'AI ने \"$name\" (-1 ऊर्जा) का विश्लेषण किया';
  }

  @override
  String get couldNotAnalyzeSub => 'उप-घटक का विश्लेषण नहीं किया जा सका';

  @override
  String get pleaseEnterIngredientName => 'कृपया घटक का नाम दर्ज करें';

  @override
  String get reAnalyzeTitle => 'पुनः विश्लेषण करें?';

  @override
  String reAnalyzeMessage(String name) {
    return '\"$name\" में पहले से ही पोषण डेटा है।\n\nदोबारा विश्लेषण करने पर 1 ऊर्जा का उपयोग होगा।\n\nजारी रखना?';
  }

  @override
  String get reAnalyzeButton => 'पुनः विश्लेषण करें (1 ऊर्जा)';

  @override
  String get amountNotSpecified => 'राशि निर्दिष्ट नहीं है';

  @override
  String amountNotSpecifiedMessage(String name) {
    return 'कृपया पहले \"$name\" के लिए राशि निर्दिष्ट करें\nया डिफ़ॉल्ट 100 ग्राम का उपयोग करें?';
  }

  @override
  String get useDefault100g => '100 ग्राम का प्रयोग करें';

  @override
  String aiAnalyzedResult(String name, int calories) {
    return 'एआई: \"$name\" → $calories kcal';
  }

  @override
  String get unableToAnalyze => 'विश्लेषण करने में असमर्थ';

  @override
  String get today => 'आज';

  @override
  String get savedSuccessfully => '✅ सफलतापूर्वक सहेजा गया';

  @override
  String get saveToMyMeals => '📖 Save to My Meals';

  @override
  String savedToMyMealsSuccess(String mealName) {
    return '✅ Saved \'$mealName\' to My Meals';
  }

  @override
  String get failedToSaveToMyMeals => '❌ Failed to save to My Meals';

  @override
  String get noIngredientsToSave => 'No ingredients to save';

  @override
  String get confirmFoodPhoto => 'भोजन की पुष्टि करें फोटो';

  @override
  String get photoSavedAutomatically => 'फ़ोटो स्वचालित रूप से सहेजी गई';

  @override
  String get foodNameHintExample => 'उदाहरण के लिए, ग्रिल्ड चिकन सलाद';

  @override
  String get quantityLabel => 'मात्रा';

  @override
  String get quantityHint => '1';

  @override
  String get optionalFoodInfo =>
      'भोजन का नाम और मात्रा दर्ज करना वैकल्पिक है, लेकिन उन्हें प्रदान करने से एआई विश्लेषण सटीकता में सुधार होगा।';

  @override
  String get saveOnly => 'केवल सहेजें';

  @override
  String get pleaseEnterValidQuantity => 'कृपया एक वैध मात्रा दर्ज करें';

  @override
  String analyzedResult(String name, int calories) {
    return '✅ विश्लेषण किया गया: $name — $calories kcal';
  }

  @override
  String get couldNotAnalyzeSaved =>
      '⚠️ विश्लेषण नहीं किया जा सका - सहेजा गया, बाद में \"सभी का विश्लेषण करें\" का उपयोग करें';

  @override
  String get savedAnalyzeLater =>
      '✅ सहेजा गया - बाद में \"सभी का विश्लेषण करें\" के साथ विश्लेषण करें';

  @override
  String get editIngredientTitle => 'घटक संपादित करें';

  @override
  String get ingredientNameRequired => 'संघटक का नाम*';

  @override
  String get baseAmountLabel => 'आधार राशि';

  @override
  String get baseAmountHint => '100';

  @override
  String nutritionPerBase(String amount, String unit) {
    return 'पोषण प्रति $amount $unit';
  }

  @override
  String nutritionCalculatedPerBase(String amount, String unit) {
    return 'पोषण की गणना प्रति $amount $unit - प्रणाली खपत की गई वास्तविक मात्रा के आधार पर स्वतः गणना करेगी';
  }

  @override
  String get createIngredient => 'घटक बनाएँ';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get pleaseEnterIngredientNameFirst =>
      'कृपया पहले घटक का नाम दर्ज करें';

  @override
  String aiAnalyzedIngredient(
      String name, String amount, String unit, int calories) {
    return 'एआई: \"$name\" $amount $unit → $calories kcal';
  }

  @override
  String get unableToFindIngredient => 'यह घटक ढूंढने में असमर्थ';

  @override
  String searchFailed(String error) {
    return 'खोज विफल: $error';
  }

  @override
  String deleteEntriesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Entries',
      one: 'Entry',
    );
    return '$count $_temp0 हटाएं?';
  }

  @override
  String deleteEntriesMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return '$count चयनित भोजन $_temp0 हटाएं?';
  }

  @override
  String get deleteAll => 'सभी हटा दो';

  @override
  String deletedEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return 'हटाया गया $count $_temp0';
  }

  @override
  String deletedSingleEntry(String name) {
    return 'Deleted $name';
  }

  @override
  String get intakeGoalLabel => 'Intake Goal';

  @override
  String get netEnergyLabel => 'Net Energy Balance';

  @override
  String get underEatingWarning => 'Under-eating';

  @override
  String get surplusWarning => 'Surplus';

  @override
  String movedEntriesToDate(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return '$count $_temp0 को $date में ले जाया गया';
  }

  @override
  String get allSelectedAlreadyAnalyzed =>
      'सभी चयनित प्रविष्टियों का विश्लेषण पहले ही किया जा चुका है';

  @override
  String analyzeCancelledSelected(int success) {
    return 'रद्द किया गया - $success का विश्लेषण किया गया';
  }

  @override
  String analyzedEntriesAll(int success) {
    String _temp0 = intl.Intl.pluralLogic(
      success,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return 'विश्लेषण किया गया $success $_temp0';
  }

  @override
  String analyzedEntriesPartial(int success, int total, int failed) {
    return 'विश्लेषण किया गया $success/$total ($failed विफल)';
  }

  @override
  String analyzeProgressSelected(int current, int total, String item) {
    return '$current/$total $item';
  }

  @override
  String get noEntriesYet => 'अभी तक कोई प्रविष्टि नहीं';

  @override
  String get selectAll => 'सबका चयन करें';

  @override
  String get deselectAll => 'सबको अचयनित करो';

  @override
  String get moveToDate => 'तिथि पर जाएँ';

  @override
  String get analyzeSelected => 'Analyze';

  @override
  String get deleteTooltip => 'मिटाना';

  @override
  String get move => 'कदम';

  @override
  String get deleteTooltipAction => 'मिटाना';

  @override
  String switchToModeTitle(String mode) {
    return '$mode मोड पर स्विच करें?';
  }

  @override
  String switchToModeMessage(String current, String newMode) {
    return 'इस आइटम का विश्लेषण $current के रूप में किया गया था।\n\n$newMode के रूप में पुनः विश्लेषण करने पर 1 ऊर्जा का उपयोग होगा।\n\nजारी रखना?';
  }

  @override
  String analyzingAsMode(String mode) {
    return '$mode के रूप में विश्लेषण किया जा रहा है...';
  }

  @override
  String reAnalyzedAsMode(String mode) {
    return '✅ $mode के रूप में पुनः विश्लेषण किया गया';
  }

  @override
  String get analysisFailed => '❌ विश्लेषण विफल रहा';

  @override
  String get aiAnalysisComplete => '✅ AI ने विश्लेषण किया और सहेजा';

  @override
  String get changeMealType => 'भोजन का प्रकार बदलें';

  @override
  String get moveToAnotherDate => 'किसी अन्य तिथि पर जाएँ';

  @override
  String currentDate(String date) {
    return 'वर्तमान: $date';
  }

  @override
  String get cancelDateChange => 'दिनांक परिवर्तन रद्द करें';

  @override
  String get undo => 'पूर्ववत';

  @override
  String get chatHistory => 'चैट का इतिहास';

  @override
  String get newChat => 'नई चैट';

  @override
  String get quickActions => 'त्वरित कार्रवाई';

  @override
  String get clear => 'स्पष्ट';

  @override
  String get helloImMiro => 'नमस्ते! मैं Miro हूं';

  @override
  String get tellMeWhatYouAteToday => 'मुझे बताओ तुमने आज क्या खाया!';

  @override
  String get tellMeWhatYouAte => 'बताओ तुमने क्या खाया...';

  @override
  String get clearHistoryTitle => 'इतिहास मिटा दें?';

  @override
  String get clearHistoryMessage => 'इस सत्र के सभी संदेश हटा दिए जाएंगे.';

  @override
  String get chatHistoryTitle => 'चैट का इतिहास';

  @override
  String get newLabel => 'नया';

  @override
  String get noChatHistoryYet => 'अभी तक कोई चैट इतिहास नहीं है';

  @override
  String get active => 'सक्रिय';

  @override
  String get deleteChatTitle => 'चैट हटाएं?';

  @override
  String deleteChatMessage(String title) {
    return '\"$title\" हटाएं?';
  }

  @override
  String weeklySummaryTitle(String start, String end) {
    return '📊 साप्ताहिक सारांश ($start - $end)';
  }

  @override
  String daySummary(String day, String calories, String emoji, String diff) {
    return '📅 $day: $calories kcal $emoji ($diff)';
  }

  @override
  String overTarget(String amount) {
    return '$amount लक्ष्य से अधिक';
  }

  @override
  String underTarget(String amount) {
    return '$amount लक्ष्य के अंतर्गत';
  }

  @override
  String get noFoodLoggedThisWeek =>
      'इस सप्ताह अभी तक कोई भोजन लॉग नहीं हुआ है।';

  @override
  String averageKcalPerDay(String average) {
    return '🔥 औसत: $average kcal/दिन';
  }

  @override
  String targetKcalPerDay(String target) {
    return '🎯 लक्ष्य: $target kcal/दिन';
  }

  @override
  String resultOverTarget(String amount) {
    return '📈 परिणाम: $amount kcal लक्ष्य से अधिक';
  }

  @override
  String resultUnderTarget(String amount) {
    return '📈 परिणाम: $amount kcal लक्ष्य के अंतर्गत - बढ़िया काम! 💪';
  }

  @override
  String failedToLoadWeeklySummary(String error) {
    return '❌ साप्ताहिक सारांश लोड करने में विफल: $error';
  }

  @override
  String monthlySummaryTitle(String month, int year) {
    return '📊 मासिक सारांश ($month $year)';
  }

  @override
  String totalDays(int days) {
    return '📅 कुल दिन: $days';
  }

  @override
  String totalConsumed(String calories) {
    return '🔥 कुल खपत: $calories kcal';
  }

  @override
  String targetTotal(String target) {
    return '🎯 कुल लक्ष्य: $target kcal';
  }

  @override
  String averageKcalPerDayShort(String average) {
    return '📈 औसत: $average kcal/दिन';
  }

  @override
  String overTargetThisMonth(String amount) {
    return '⚠️ $amount kcal इस माह लक्ष्य से अधिक';
  }

  @override
  String underTargetThisMonth(String amount) {
    return '✅ $amount kcal लक्ष्य के अंतर्गत - उत्कृष्ट! 💪';
  }

  @override
  String failedToLoadMonthlySummary(String error) {
    return '❌ मासिक सारांश लोड करने में विफल: $error';
  }

  @override
  String get localAiHelpTitle => '🤖 स्थानीय एआई सहायता';

  @override
  String get localAiHelpFormat => 'प्रारूप: [भोजन] [राशि] [इकाई]';

  @override
  String get localAiHelpExamples =>
      'उदाहरण:\n• चिकन 100 ग्राम और चावल 200 ग्राम\n• पिज़्ज़ा 2 स्लाइस\n• सेब 1 टुकड़ा, केला 1 टुकड़ा';

  @override
  String get localAiHelpNote =>
      'नोट: केवल अंग्रेजी, बुनियादी विश्लेषण\nबेहतर परिणामों के लिए Miro AI पर स्विच करें!';

  @override
  String hiNoFoodLogged(String target) {
    return '🤖हाय! आज अभी तक कोई भोजन लॉग नहीं हुआ है।\n   लक्ष्य: $target kcal — लॉगिंग शुरू करने के लिए तैयार हैं? 🍽️';
  }

  @override
  String hiKcalLeft(String remaining) {
    return '🤖हाय! आपके पास आज के लिए $remaining kcal शेष है।\n   क्या आप अपना भोजन लॉग करने के लिए तैयार हैं? 😊';
  }

  @override
  String hiOverTarget(String calories, String over) {
    return '🤖हाय! आपने आज $calories kcal का सेवन किया है।\n   $over __SW0__ लक्ष्य से अधिक - आइए ट्रैकिंग करते रहें! 💪';
  }

  @override
  String get hiReadyToLog =>
      '🤖हाय! क्या आप अपना भोजन लॉग करने के लिए तैयार हैं? 😊';

  @override
  String get notEnoughEnergy => 'बहुत ज्यादा ऊर्जा नहीं';

  @override
  String get thinkingMealIdeas =>
      '🤖आपके लिए बढ़िया भोजन के विचारों के बारे में सोच रहा हूँ...';

  @override
  String get recentMeals => 'हाल का भोजन:';

  @override
  String get noRecentFood => 'हाल ही में कोई भोजन लॉग नहीं किया गया।';

  @override
  String remainingCaloriesToday(String remaining) {
    return '. आज शेष कैलोरी: $remaining kcal।';
  }

  @override
  String failedToGetMenuSuggestions(String error) {
    return '❌ मेनू सुझाव प्राप्त करने में विफल: $error';
  }

  @override
  String get mealSuggestionsTitle =>
      '🤖 आपके भोजन लॉग के आधार पर, यहां 3 भोजन सुझाव दिए गए हैं:';

  @override
  String mealSuggestionItem(
      int index, String emoji, String name, String calories) {
    return '$index. $emoji $name (~$calories kcal)';
  }

  @override
  String mealSuggestionMacros(String protein, String carbs, String fat) {
    return 'पी: ${protein}g | सी: ${carbs}g | एफ: ${fat}g';
  }

  @override
  String get pickOneAndLog => 'एक चुनें और मैं इसे आपके लिए लॉग कर दूंगा! 😊';

  @override
  String energyCost(int cost) {
    return '⚡ -$cost ऊर्जा';
  }

  @override
  String get giveMeTipsForHealthyEating => 'मुझे स्वस्थ भोजन के लिए सुझाव दें';

  @override
  String get howManyCaloriesToday => 'आज कितनी कैलोरी?';

  @override
  String get menuLabel => 'मेनू';

  @override
  String get weeklyLabel => 'साप्ताहिक';

  @override
  String get monthlyLabel => 'महीने के';

  @override
  String get tipsLabel => 'सुझावों';

  @override
  String get summaryLabel => 'सारांश';

  @override
  String get helpLabel => 'मदद';

  @override
  String get onboardingWelcomeSubtitle =>
      'कैलोरी को सहजता से ट्रैक करें\nएआई-संचालित विश्लेषण के साथ';

  @override
  String get onboardingSnap => 'स्नैप';

  @override
  String get onboardingSnapDesc => 'एआई तुरंत विश्लेषण करता है';

  @override
  String get onboardingType => 'प्रकार';

  @override
  String get onboardingTypeDesc => 'सेकंड में लॉग इन करें';

  @override
  String get onboardingEdit => 'संपादन करना';

  @override
  String get onboardingEditDesc => 'फाइन-ट्यून सटीकता';

  @override
  String get onboardingNext => 'अगला →';

  @override
  String get onboardingDisclaimer => 'एआई-अनुमानित डेटा। चिकित्सीय सलाह नहीं.';

  @override
  String get onboardingQuickSetup => 'शीघ्र व्यवस्थित';

  @override
  String get onboardingHelpAiUnderstand =>
      'एआई को आपके भोजन को बेहतर ढंग से समझने में सहायता करें';

  @override
  String get onboardingYourTypicalCuisine => 'आपका विशिष्ट व्यंजन:';

  @override
  String get onboardingDailyCalorieGoal => 'दैनिक कैलोरी लक्ष्य (वैकल्पिक):';

  @override
  String get onboardingKcalPerDay => 'kcal/दिन';

  @override
  String get onboardingCalorieGoalHint => '2000';

  @override
  String get onboardingCanChangeAnytime =>
      'आप इसे Proफ़ाइल सेटिंग में कभी भी बदल सकते हैं';

  @override
  String get onboardingYoureAllSet => 'तुम सब सेट हो!';

  @override
  String get onboardingStartTracking =>
      'आज ही अपने भोजन पर नज़र रखना शुरू करें।\nएक फोटो खींचें या लिखें कि आपने क्या खाया।';

  @override
  String get onboardingWelcomeGift => 'स्वागत उपहार';

  @override
  String get onboardingFreeEnergy => '10 मुफ़्त ऊर्जा';

  @override
  String get onboardingFreeEnergyDesc => '= आरंभ करने के लिए 10 एआई विश्लेषण';

  @override
  String get onboardingEnergyCost =>
      'प्रत्येक विश्लेषण में 1 ऊर्जा खर्च होती है\nजितना अधिक आप उपयोग करेंगे, उतना अधिक कमायेंगे!';

  @override
  String get onboardingStartTrackingButton => 'ट्रैकिंग शुरू करें! →';

  @override
  String get onboardingNoCreditCard =>
      'कोई क्रेडिट कार्ड नहीं • कोई छिपी हुई फीस नहीं';

  @override
  String get cameraTakePhotoOfFood => 'अपने भोजन का फ़ोटो लें';

  @override
  String get cameraFailedToInitialize => 'कैमरा प्रारंभ करने में विफल';

  @override
  String get cameraFailedToCapture => 'फ़ोटो कैप्चर करने में विफल';

  @override
  String get cameraFailedToPickFromGallery => 'गैलरी से छवि चुनने में विफल';

  @override
  String get cameraProcessing => 'Proउपवास...';

  @override
  String get referralInviteFriends => 'मित्रों को आमंत्रित करें';

  @override
  String get referralYourReferralCode => 'आपका रेफरल कोड';

  @override
  String get referralLoading => 'लोड हो रहा है...';

  @override
  String get referralCopy => 'प्रतिलिपि';

  @override
  String get referralShareCodeDescription =>
      'इस कोड को दोस्तों के साथ साझा करें! जब वे 3 बार AI का उपयोग करते हैं, तो आप दोनों को पुरस्कार मिलता है!';

  @override
  String get referralEnterReferralCode => 'रेफरल कोड दर्ज करें';

  @override
  String get referralCodeHint => 'मिरो-XXXX-XXXX-XXXX';

  @override
  String get referralSubmitCode => 'कोड सबमिट करें';

  @override
  String get referralPleaseEnterCode => 'कृपया एक रेफरल कोड दर्ज करें';

  @override
  String get referralCodeAccepted => 'रेफरल कोड स्वीकार किया गया!';

  @override
  String get referralCodeCopied => 'रेफरल कोड क्लिपबोर्ड पर कॉपी किया गया!';

  @override
  String referralEnergyBonus(int energy) {
    return '+$energy ऊर्जा!';
  }

  @override
  String get referralHowItWorks => 'यह काम किस प्रकार करता है';

  @override
  String get referralStep1Title => 'अपना रेफरल कोड साझा करें';

  @override
  String get referralStep1Description =>
      'अपनी MiRO आईडी कॉपी करें और दोस्तों के साथ साझा करें';

  @override
  String get referralStep2Title => 'मित्र आपका कोड दर्ज करता है';

  @override
  String get referralStep2Description => 'उन्हें तुरंत +20 ऊर्जा मिलती है';

  @override
  String get referralStep3Title => 'मित्र एआई का 3 बार उपयोग करता है';

  @override
  String get referralStep3Description => 'जब वे 3 AI विश्लेषण पूरा कर लेते हैं';

  @override
  String get referralStep4Title => 'तुम्हें पुरस्कार मिलता है!';

  @override
  String get referralStep4Description => 'आपको +5 ऊर्जा प्राप्त होती है!';

  @override
  String get tierBenefitsTitle => 'स्तरीय लाभ';

  @override
  String get tierBenefitsUnlockRewards =>
      'पुरस्कार अनलॉक करें\nडेली स्ट्रीक्स के साथ';

  @override
  String get tierBenefitsKeepStreakDescription =>
      'उच्च स्तरों को अनलॉक करने और आश्चर्यजनक लाभ अर्जित करने के लिए अपनी स्ट्रीक को जीवित रखें!';

  @override
  String get tierBenefitsHowItWorks => 'यह काम किस प्रकार करता है';

  @override
  String get tierBenefitsDailyEnergyReward => 'दैनिक ऊर्जा पुरस्कार';

  @override
  String get tierBenefitsDailyEnergyDescription =>
      'बोनस ऊर्जा अर्जित करने के लिए प्रतिदिन कम से कम एक बार AI का उपयोग करें। ऊंचे स्तर = अधिक दैनिक ऊर्जा!';

  @override
  String get tierBenefitsPurchaseBonus => 'बोनस खरीदें';

  @override
  String get tierBenefitsPurchaseBonusDescription =>
      'सोने और हीरे के स्तरों को प्रत्येक खरीदारी पर अतिरिक्त ऊर्जा मिलती है (10-20% अधिक!)';

  @override
  String get tierBenefitsGracePeriod => 'मुहलत';

  @override
  String get tierBenefitsGracePeriodDescription =>
      'अपनी लय खोए बिना एक भी दिन गँवाएँ। सिल्वर+ स्तरों को सुरक्षा मिलती है!';

  @override
  String get tierBenefitsAllTiers => 'सभी स्तर';

  @override
  String get tierBenefitsNew => 'नया';

  @override
  String get tierBenefitsPopular => 'लोकप्रिय';

  @override
  String get tierBenefitsBest => 'श्रेष्ठ';

  @override
  String get tierBenefitsDailyCheckIn => 'दैनिक चेक-इन';

  @override
  String get tierBenefitsProTips => 'Pro टिप्स';

  @override
  String get tierBenefitsTip1 =>
      'मुफ़्त ऊर्जा अर्जित करने और अपनी स्ट्रीक बनाने के लिए प्रतिदिन AI का उपयोग करें';

  @override
  String get tierBenefitsTip2 =>
      'डायमंड टियर प्रति दिन +4 ऊर्जा कमाता है - यानी 120/माह!';

  @override
  String get tierBenefitsTip3 => 'खरीद बोनस सभी ऊर्जा पैकेजों पर लागू होता है!';

  @override
  String get tierBenefitsTip4 =>
      'यदि आप एक दिन चूक जाते हैं तो अनुग्रह अवधि आपकी स्ट्रीक की सुरक्षा करती है';

  @override
  String get subscriptionEnergyPass => 'ऊर्जा पास';

  @override
  String get subscriptionInAppPurchasesNotAvailable =>
      'इन-ऐप खरीदारी उपलब्ध नहीं है';

  @override
  String get subscriptionFailedToInitiatePurchase =>
      'खरीदारी आरंभ करने में विफल';

  @override
  String subscriptionError(String error) {
    return 'त्रुटि: $error';
  }

  @override
  String get subscriptionFailedToLoad => 'सदस्यता लोड करने में विफल';

  @override
  String get subscriptionUnknownError => 'अज्ञात त्रुटि';

  @override
  String get subscriptionRetry => 'पुन: प्रयास करें';

  @override
  String get subscriptionEnergyPassActive => 'ऊर्जा पास सक्रिय';

  @override
  String get subscriptionUnlimitedAccess => 'आपके पास असीमित पहुंच है';

  @override
  String get subscriptionStatus => 'स्थिति';

  @override
  String get subscriptionRenews => 'नवीनिकृत';

  @override
  String get subscriptionPrice => 'कीमत';

  @override
  String get subscriptionYourBenefits => 'आपके लाभ';

  @override
  String get subscriptionManageSubscription => 'सदस्यता प्रबंधित करें';

  @override
  String get subscriptionNoProductAvailable =>
      'कोई सदस्यता उत्पाद उपलब्ध नहीं है';

  @override
  String get subscriptionWhatYouGet => 'आपको क्या मिलता है';

  @override
  String get subscriptionPerMonth => 'प्रति महीने';

  @override
  String get subscriptionSubscribeNow => 'अब सदस्यता लें';

  @override
  String get subscriptionSubscribe => 'Subscribe';

  @override
  String get subscriptionCancelAnytime => 'किसी भी समय रद्द करें';

  @override
  String get subscriptionAutoRenewTerms =>
      'आपकी सदस्यता स्वतः नवीनीकृत हो जाएगी. आप Google Play से कभी भी रद्द कर सकते हैं।';

  @override
  String get subscriptionAutoRenewTermsIos =>
      'Payment will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period. You can manage and cancel your subscriptions in your App Store account settings.';

  @override
  String subscriptionRenewsDate(String date) {
    return 'Renews: $date';
  }

  @override
  String get subscriptionBestValue => 'BEST VALUE';

  @override
  String get energyStoreTitle => 'Energy Store';

  @override
  String get energyPackages => 'Energy Packages';

  @override
  String get energyPackageStarterKick => 'Starter Kick';

  @override
  String get energyPackageValuePack => 'Value Pack';

  @override
  String get energyPackagePowerUser => 'Power User';

  @override
  String get energyPackageUltimateSaver => 'Ultimate Saver';

  @override
  String get energyBadgeBestValue => 'BEST VALUE';

  @override
  String get energyBadgePopular => 'POPULAR';

  @override
  String get energyBadgeBonus10 => '+10% bonus';

  @override
  String get energyPassUnlimitedAI => 'Unlimited AI Analysis';

  @override
  String energyPassUnlimitedFromPrice(String price) {
    return 'Unlimited AI Analysis • from $price/month';
  }

  @override
  String get energyPassActive => 'ACTIVE';

  @override
  String get subscriptionDeal => 'Subscription Deal';

  @override
  String get subscriptionViewDeal => 'View Deal';

  @override
  String get disclaimerHealthDisclaimer => 'स्वास्थ्य अस्वीकरण';

  @override
  String get disclaimerImportantReminders => 'महत्वपूर्ण अनुस्मारक:';

  @override
  String get disclaimerBullet1 => 'सभी पोषण संबंधी डेटा का अनुमान लगाया गया है';

  @override
  String get disclaimerBullet2 => 'एआई विश्लेषण में त्रुटियां हो सकती हैं';

  @override
  String get disclaimerBullet3 => 'पेशेवर सलाह का विकल्प नहीं';

  @override
  String get disclaimerBullet4 =>
      'चिकित्सीय मार्गदर्शन के लिए स्वास्थ्य सेवा प्रदाताओं से परामर्श लें';

  @override
  String get disclaimerBullet5 => 'अपने विवेक और जोखिम पर उपयोग करें';

  @override
  String get disclaimerIUnderstand => 'मैं समझता हूँ';

  @override
  String get privacyPolicyTitle => 'गोपनीयता नीति';

  @override
  String get privacyPolicySubtitle => 'MiRO - मेरा इंटेक रिकॉर्ड ओरेकल';

  @override
  String get privacyPolicyHeaderNote =>
      'आपका भोजन डेटा आपके डिवाइस पर रहता है। ऊर्जा संतुलन Firebase के माध्यम से सुरक्षित रूप से समन्वयित किया गया।';

  @override
  String get privacyPolicySectionInformationWeCollect =>
      'जानकारी हम एकत्रित करते हैं';

  @override
  String get privacyPolicySectionDataStorage => 'आधार सामग्री भंडारण';

  @override
  String get privacyPolicySectionDataTransmission =>
      'तीसरे पक्ष को डेटा ट्रांसमिशन';

  @override
  String get privacyPolicySectionRequiredPermissions => 'आवश्यक अनुमतियाँ';

  @override
  String get privacyPolicySectionSecurity => 'सुरक्षा';

  @override
  String get privacyPolicySectionUserRights => 'प्रयोगकर्ता के अधिकार';

  @override
  String get privacyPolicySectionDataRetention => 'डेटा प्रतिधारण';

  @override
  String get privacyPolicySectionChildrenPrivacy => 'बच्चों की गोपनीयता';

  @override
  String get privacyPolicySectionChangesToPolicy => 'इस नीति में परिवर्तन';

  @override
  String get privacyPolicySectionDataCollectionConsent => 'डेटा संग्रहण सहमति';

  @override
  String get privacyPolicySectionPDPACompliance =>
      'पीडीपीए अनुपालन (थाईलैंड व्यक्तिगत डेटा Proटेक्शन अधिनियम)';

  @override
  String get privacyPolicySectionContactUs => 'हमसे संपर्क करें';

  @override
  String get privacyPolicyEffectiveDate =>
      'प्रभावी तिथि: 18 फरवरी, 2026\nअंतिम अद्यतन: 18 फरवरी, 2026';

  @override
  String get termsOfServiceTitle => 'सेवा की शर्तें';

  @override
  String get termsSubtitle => 'MiRO - मेरा इंटेक रिकॉर्ड ओरेकल';

  @override
  String get termsSectionAcceptanceOfTerms => 'शर्तों की स्वीकृति';

  @override
  String get termsSectionServiceDescription => 'सेवा विवरण';

  @override
  String get termsSectionDisclaimerOfWarranties => 'वारंटियों का अस्वीकरण';

  @override
  String get termsSectionEnergySystemTerms => 'ऊर्जा प्रणाली शर्तें';

  @override
  String get termsSectionUserDataAndResponsibilities =>
      'उपयोगकर्ता डेटा और जिम्मेदारियाँ';

  @override
  String get termsSectionBackupTransfer => 'बैकअप और स्थानांतरण';

  @override
  String get termsSectionInAppPurchases => 'इन-ऐप खरीदारी';

  @override
  String get termsSectionProhibitedUses => 'Proनिषिद्ध उपयोग';

  @override
  String get termsSectionIntellectualProperty => 'बौद्धिक Property';

  @override
  String get termsSectionLimitationOfLiability => 'दायित्व की सीमा';

  @override
  String get termsSectionServiceTermination => 'सेवा समाप्ति';

  @override
  String get termsSectionChangesToTerms => 'शर्तों में परिवर्तन';

  @override
  String get termsSectionGoverningLaw => 'शासी कानून';

  @override
  String get termsSectionContactUs => 'हमसे संपर्क करें';

  @override
  String get termsAcknowledgment =>
      'MiRO का उपयोग करके, आप स्वीकार करते हैं कि आपने सेवा की इन शर्तों को पढ़, समझ लिया है और उनसे सहमत हैं।';

  @override
  String get termsLastUpdated => 'अंतिम अद्यतन: 15 फरवरी, 2026';

  @override
  String get profileAndSettings => 'Proफ़ाइल और सेटिंग्स';

  @override
  String errorOccurred(String error) {
    return 'त्रुटि: $error';
  }

  @override
  String get healthGoalsSection => 'स्वास्थ्य लक्ष्य';

  @override
  String get dailyGoals => 'दैनिक लक्ष्य';

  @override
  String get chatAiModeSection => 'चैट एआई मोड';

  @override
  String get selectAiPowersChat =>
      'चुनें कि कौन सा AI आपकी चैट को शक्ति प्रदान करता है';

  @override
  String get miroAi => 'Miro ऐ';

  @override
  String get miroAiSubtitle => 'Gemini द्वारा संचालित • बहुभाषी • उच्च सटीकता';

  @override
  String get localAi => 'स्थानीय ए.आई';

  @override
  String get localAiSubtitle => 'डिवाइस पर • केवल अंग्रेज़ी • बुनियादी सटीकता';

  @override
  String get free => 'मुक्त';

  @override
  String get cuisinePreferenceSection => 'व्यंजन प्राथमिकता';

  @override
  String get preferredCuisine => 'पसंदीदा व्यंजन';

  @override
  String get selectYourCuisine => 'अपना व्यंजन चुनें';

  @override
  String get photoScanSection => 'फोटो स्कैन';

  @override
  String get languageSection => 'भाषा';

  @override
  String get languageTitle => 'भाषा / भाषा';

  @override
  String get selectLanguage => 'भाषा चुनें / भाषा चुनें';

  @override
  String get systemDefault => 'प्रणालीगत चूक';

  @override
  String get systemDefaultSublabel => 'धन्यवाद';

  @override
  String get english => 'अंग्रेज़ी';

  @override
  String get englishSublabel => 'ठीक है';

  @override
  String get thai => 'ไทย (थाई)';

  @override
  String get thaiSublabel => 'धन्यवाद';

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
  String get closeBilingual => 'बंद करें / बंद करें';

  @override
  String languageChangedTo(String language) {
    return 'भाषा बदलकर $language कर दी गई';
  }

  @override
  String get accountSection => 'खाता';

  @override
  String get miroId => 'MiRO आईडी';

  @override
  String get miroIdCopied => 'MiRO आईडी कॉपी की गई!';

  @override
  String get inviteFriends => 'मित्रों को आमंत्रित करें';

  @override
  String get inviteFriendsSubtitle =>
      'अपना रेफरल कोड साझा करें और पुरस्कार अर्जित करें!';

  @override
  String get unlimitedAiDoubleRewards => 'असीमित एआई + दोहरा पुरस्कार';

  @override
  String get plan => 'योजना';

  @override
  String get monthly => 'महीने के';

  @override
  String get started => 'शुरू कर दिया';

  @override
  String get renews => 'नवीनिकृत';

  @override
  String get expires => 'समय-सीमा समाप्त';

  @override
  String get autoRenew => 'ऑटो नवीनीकृत';

  @override
  String get on => 'पर';

  @override
  String get off => 'बंद';

  @override
  String get tapToManageSubscription => 'सदस्यता प्रबंधित करने के लिए टैप करें';

  @override
  String get dataSection => 'डेटा';

  @override
  String get backupData => 'बैकअप डेटा';

  @override
  String get backupDataSubtitle =>
      'ऊर्जा + खाद्य इतिहास → फ़ाइल के रूप में सहेजें';

  @override
  String get restoreFromBackup => 'बैकअप से पुनर्स्थापित करें';

  @override
  String get restoreFromBackupSubtitle => 'बैकअप फ़ाइल से डेटा आयात करें';

  @override
  String get clearAllDataTitle => 'सारा डेटा साफ़ करें?';

  @override
  String get clearAllDataContent =>
      'सारा डेटा हटा दिया जाएगा:\n• खाद्य प्रविष्टियाँ\n• मेरा भोजन\n• सामग्री\n• लक्ष्य\n• व्यक्तिगत जानकारी\n\nइसे पूर्ववत नहीं किया जा सकता!';

  @override
  String get clearAllDataStorageDetails =>
      'इसमें शामिल: Isar DB, SharedPreferences, SecureStorage';

  @override
  String get clearAllDataFactoryResetHint =>
      '(नई इंस्टॉल की तरह — एडमिन पैनल में Factory Reset के साथ उपयोग करें)';

  @override
  String get allDataClearedSuccess => 'सभी डेटा सफलतापूर्वक साफ़ कर दिया गया';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountSubtitle => 'Delete all data from device and cloud';

  @override
  String get deleteAccountTitle => 'Delete Account?';

  @override
  String get deleteAccountContent =>
      'This will permanently delete:\n• All local data (food entries, meals, goals)\n• Cloud-synced data (energy balance, backups)\n• Subscription data\n\nThis action cannot be undone.';

  @override
  String get deleteAccountConfirm => 'Delete Account';

  @override
  String get deleteAccountSuccess => 'Account deleted successfully';

  @override
  String get deleteAccountFailed =>
      'Failed to delete account. Please try again.';

  @override
  String get deleteAccountDeleting => 'Deleting account…';

  @override
  String get aboutSection => 'के बारे में';

  @override
  String get version => 'संस्करण';

  @override
  String get eula => 'EULA';

  @override
  String get healthDisclaimer => 'स्वास्थ्य अस्वीकरण';

  @override
  String get importantLegalInformation => 'महत्वपूर्ण कानूनी जानकारी';

  @override
  String get showTutorialAgain => 'ट्यूटोरियल दोबारा दिखाएँ';

  @override
  String get viewFeatureTour => 'फीचर टूर देखें';

  @override
  String get showTutorialDialogTitle => 'टूटोरियल्स दिखाना';

  @override
  String get showTutorialDialogContent =>
      'यह वह फीचर टूर दिखाएगा जो निम्न पर प्रकाश डालता है:\n\n• ऊर्जा प्रणाली\n• पुल-टू-रिफ्रेश फोटो स्कैन\n• Miro AI के साथ चैट करें\n\nआप होम स्क्रीन पर वापस आ जायेंगे.';

  @override
  String get showTutorialButton => 'टूटोरियल्स दिखाना';

  @override
  String get tutorialResetMessage =>
      'ट्यूटोरियल रीसेट! इसे देखने के लिए होम स्क्रीन पर जाएँ।';

  @override
  String get foodAnalysisTutorial => 'खाद्य विश्लेषण ट्यूटोरियल';

  @override
  String get foodAnalysisTutorialSubtitle =>
      'जानें कि खाद्य विश्लेषण सुविधाओं का उपयोग कैसे करें';

  @override
  String get backupCreated => 'बैकअप बनाया गया!';

  @override
  String get backupCreatedContent => 'आपकी बैकअप फ़ाइल सफलतापूर्वक बनाई गई है.';

  @override
  String get backupChooseDestination => 'आप अपना बैकअप कहाँ सहेजना चाहेंगे?';

  @override
  String get backupSaveToDevice => 'डिवाइस में सहेजें';

  @override
  String get backupSaveToDeviceDesc =>
      'इस डिवाइस पर आपके द्वारा चुने गए फ़ोल्डर में सहेजें';

  @override
  String get backupShareToOther => 'अन्य डिवाइस पर साझा करें';

  @override
  String get backupShareToOtherDesc =>
      'लाइन, ईमेल, Google ड्राइव आदि के माध्यम से भेजें।';

  @override
  String get backupSavedSuccess => 'बैकअप सहेजा गया!';

  @override
  String get backupSavedSuccessContent =>
      'आपकी बैकअप फ़ाइल आपके चुने हुए स्थान पर सहेजी गई है।';

  @override
  String get important => 'महत्वपूर्ण:';

  @override
  String get backupImportantNotes =>
      '• इस फ़ाइल को किसी सुरक्षित स्थान पर सहेजें (Google ड्राइव, आदि)\n• तस्वीरें बैकअप में शामिल नहीं हैं\n• स्थानांतरण कुंजी 30 दिनों में समाप्त हो जाती है\n• कुंजी का उपयोग केवल एक बार किया जा सकता है';

  @override
  String get restoreBackup => 'बैकअप बहाल?';

  @override
  String get backupFrom => 'यहां से बैकअप:';

  @override
  String get date => 'तारीख:';

  @override
  String get energy => 'ऊर्जा:';

  @override
  String get foodEntries => 'खाद्य प्रविष्टियाँ:';

  @override
  String get restoreImportant => 'महत्वपूर्ण';

  @override
  String restoreImportantNotes(String energy) {
    return '• इस उपकरण पर वर्तमान ऊर्जा को बैकअप से प्राप्त ऊर्जा से प्रतिस्थापित किया जाएगा ($energy)\n• खाद्य प्रविष्टियों को मर्ज कर दिया जाएगा (प्रतिस्थापित नहीं किया जाएगा)\n• तस्वीरें बैकअप में शामिल नहीं हैं\n• स्थानांतरण कुंजी का उपयोग किया जाएगा (पुन: उपयोग नहीं किया जा सकता)';
  }

  @override
  String get restore => 'पुनर्स्थापित करना';

  @override
  String get restoreComplete => 'पूर्ण पुनर्स्थापित करें!';

  @override
  String get restoreCompleteContent =>
      'आपका डेटा सफलतापूर्वक पुनर्स्थापित कर दिया गया है.';

  @override
  String get newEnergyBalance => 'नई ऊर्जा संतुलन:';

  @override
  String get foodEntriesImported => 'आयातित खाद्य प्रविष्टियाँ:';

  @override
  String get myMealsImported => 'मेरा भोजन आयातित:';

  @override
  String get appWillRefresh =>
      'आपका ऐप पुनर्स्थापित डेटा दिखाने के लिए रीफ़्रेश हो जाएगा।';

  @override
  String get backupFailed => 'बैकअप विफल';

  @override
  String get invalidBackupFile => 'अमान्य बैकअप फ़ाइल';

  @override
  String get restoreSelectDataFile =>
      'This file only contains Energy. To restore food entries, select the data file (miro_data_*.json) instead.';

  @override
  String get restoreZeroEntriesHint =>
      'No food entries were imported. Make sure you selected the data file (miro_data_*.json), not the energy file.';

  @override
  String get restoreFailed => 'पुनर्स्थापना विफल';

  @override
  String get analyticsDataCollection => 'विश्लेषिकी डेटा संग्रह';

  @override
  String get analyticsEnabled =>
      'एनालिटिक्स सक्षम - ऐप सुधार में मदद के लिए धन्यवाद';

  @override
  String get analyticsDisabled =>
      'एनालिटिक्स अक्षम - उपयोग डेटा एकत्र नहीं किया जाता';

  @override
  String get enabled => 'सक्रिय';

  @override
  String get enabledSubtitle =>
      'सक्षम - उपयोगकर्ता अनुभव में सुधार में मदद करता है';

  @override
  String get disabled => 'अक्षम';

  @override
  String get disabledSubtitle => 'अक्षम - उपयोग डेटा एकत्र नहीं किया जाता';

  @override
  String get imagesPerDay => 'प्रति दिन छवियां';

  @override
  String scanUpToImagesPerDay(String limit) {
    return 'प्रति दिन $limit छवियों तक स्कैन करें';
  }

  @override
  String get reset => 'रीसेट करें';

  @override
  String get resetScanHistory => 'स्कैन इतिहास रीसेट करें';

  @override
  String get resetScanHistorySubtitle =>
      'सभी स्कैन की गई प्रविष्टियाँ हटाएँ और पुनः स्कैन करें';

  @override
  String get imagesPerDayDialog => 'प्रति दिन छवियां';

  @override
  String get maxImagesPerDayDescription =>
      'प्रति दिन स्कैन करने के लिए अधिकतम छवियाँ\nकेवल चयनित दिनांक को स्कैन करता है';

  @override
  String scanLimitSetTo(String limit) {
    return 'प्रति दिन छवियों को स्कैन करने की सीमा $limit पर सेट की गई';
  }

  @override
  String get resetScanHistoryDialog => 'स्कैन इतिहास रीसेट करें?';

  @override
  String get resetScanHistoryContent =>
      'गैलरी-स्कैन की गई सभी खाद्य प्रविष्टियाँ हटा दी जाएंगी।\nछवियों को पुनः स्कैन करने के लिए किसी भी तारीख को नीचे खींचें।';

  @override
  String resetComplete(String count) {
    return 'रीसेट पूर्ण - $count प्रविष्टियाँ हटा दी गईं। पुन: स्कैन करने के लिए नीचे खींचें.';
  }

  @override
  String questBarStreak(int days) {
    return 'स्ट्रीक $days दिन';
  }

  @override
  String questBarDaysToNextTier(int days, String tier) {
    return '$days दिन → $tier';
  }

  @override
  String get questBarMaxTier => 'मैक्स टियर! 💎';

  @override
  String get questBarOfferDismissed => 'प्रस्ताव छिपा हुआ';

  @override
  String get questBarViewOffer => 'ऑफर देखें';

  @override
  String get questBarNoOffersNow => '• अभी कोई ऑफर नहीं';

  @override
  String get questBarWeeklyChallenges => '🎯साप्ताहिक चुनौतियाँ';

  @override
  String get questBarMilestones => '🏆 मील के पत्थर';

  @override
  String get questBarInviteFriends =>
      '👥 मित्रों को आमंत्रित करें और 20ई प्राप्त करें';

  @override
  String questBarTimeRemaining(String time) {
    return '⏰ शेष समय $time';
  }

  @override
  String questBarClaimDailyEnergy(int energy) {
    return '+${energy}E';
  }

  @override
  String questBarShareReferralError(String error) {
    return 'साझा करने में त्रुटि: $error';
  }

  @override
  String tierCelebrationTitle(String tier) {
    return '$tier उत्सव 🎉';
  }

  @override
  String tierCelebrationDay(int day) {
    return 'दिन $day';
  }

  @override
  String get tierCelebrationExpired => 'खत्म हो चुका';

  @override
  String get tierCelebrationComplete => 'पूरा!';

  @override
  String questBarWatchAd(int energy) {
    return 'विज्ञापन देखें +$energy⚡';
  }

  @override
  String questBarAdRemaining(int remaining, int total) {
    return '$remaining/$total आज शेष है';
  }

  @override
  String questBarAdSuccess(int energy) {
    return 'विज्ञापन देखा! +$energy आने वाली ऊर्जा...';
  }

  @override
  String get questBarAdNotReady =>
      'विज्ञापन तैयार नहीं है, कृपया पुनः प्रयास करें';

  @override
  String get questBarDailyChallenge => 'दैनिक चुनौती';

  @override
  String get questBarUseAi => 'ऊर्जा का प्रयोग करें';

  @override
  String get questBarResetsMonday => 'प्रत्येक सोमवार को रीसेट होता है';

  @override
  String get questBarClaimed => 'दावा किया!';

  @override
  String get questBarHideOffer => 'छिपाना';

  @override
  String get questBarViewDetails => 'देखना';

  @override
  String questBarShareText(String link) {
    return 'MiRO आज़माएं! एआई-संचालित भोजन विश्लेषण 🍔\nइस लिंक का उपयोग करें और हम दोनों को +20 ऊर्जा निःशुल्क मिलेगी!\n\n$link';
  }

  @override
  String get questBarShareSubject => 'प्रयास करें MiRO';

  @override
  String get claimButtonTitle => 'दैनिक ऊर्जा का दावा करें';

  @override
  String claimButtonReceived(String energy) {
    return '+${energy}E प्राप्त हुआ!';
  }

  @override
  String get claimButtonAlreadyClaimed => 'आज पहले ही दावा किया जा चुका है';

  @override
  String claimButtonError(String error) {
    return 'त्रुटि: $error';
  }

  @override
  String get seasonalQuestLimitedTime => 'सीमित समय';

  @override
  String seasonalQuestDaysLeft(int days) {
    return '$days दिन बचे हैं';
  }

  @override
  String seasonalQuestRewardDaily(int reward) {
    return '+${reward}E/दिन';
  }

  @override
  String seasonalQuestRewardOnce(int reward) {
    return '+${reward}E एक बार';
  }

  @override
  String get seasonalQuestClaimed => 'दावा किया!';

  @override
  String get seasonalQuestClaimedToday => 'आज दावा किया गया';

  @override
  String get errorFailed => 'असफल';

  @override
  String get errorFailedToClaim => 'दावा करने में विफल';

  @override
  String errorGeneric(String error) {
    return 'त्रुटि: $error';
  }

  @override
  String get milestoneNoMilestonesToClaim =>
      'दावा करने के लिए अभी तक कोई मील का पत्थर नहीं है';

  @override
  String milestoneClaimedEnergy(int energy) {
    return '🎁दावा किया गया +$energy ऊर्जा!';
  }

  @override
  String get milestoneTitle => 'मील के पत्थर';

  @override
  String milestoneUseEnergyComplete(int threshold) {
    return 'ऊर्जा का उपयोग करें $threshold';
  }

  @override
  String milestoneNext(int threshold) {
    return 'अगला: ${threshold}E';
  }

  @override
  String get milestoneAllComplete => 'सभी मील के पत्थर पूरे हो गए!';

  @override
  String get noEnergyTitle => 'ऊर्जा से बाहर';

  @override
  String get noEnergyContent =>
      'एआई के साथ भोजन का विश्लेषण करने के लिए आपको 1 ऊर्जा की आवश्यकता है';

  @override
  String get noEnergyTip =>
      'आप अभी भी भोजन को मैन्युअल रूप से (एआई के बिना) निःशुल्क लॉग कर सकते हैं';

  @override
  String get noEnergyLater => 'बाद में';

  @override
  String noEnergyWatchAd(int remaining) {
    return 'विज्ञापन देखें ($remaining/3)';
  }

  @override
  String get noEnergyBuyEnergy => 'ऊर्जा खरीदें';

  @override
  String get tierBronze => 'पीतल';

  @override
  String get tierSilver => 'चाँदी';

  @override
  String get tierGold => 'सोना';

  @override
  String get tierDiamond => 'डायमंड';

  @override
  String get tierStarter => 'स्टार्टर';

  @override
  String get tierUpCongratulations => '🎉बधाई हो!';

  @override
  String tierUpYouReached(String tier) {
    return 'आप $tier तक पहुंच गए!';
  }

  @override
  String get tierUpMotivation =>
      'एक प्रोफेशनल की तरह कैलोरी ट्रैक करें\nआपके सपनों का शरीर करीब आ रहा है!';

  @override
  String tierUpReward(int reward) {
    return '+${reward}E इनाम!';
  }

  @override
  String get referralAllLevelsClaimed => 'सभी स्तरों पर दावा किया गया!';

  @override
  String referralLevel(int level, String subtitle) {
    return 'स्तर $level: $subtitle';
  }

  @override
  String referralProgress(int current, int target, int level, int total) {
    return '[$current/$target] (स्तर $level/$total)';
  }

  @override
  String referralClaimedLevel(int level, int reward) {
    return '🎁 दावा किया गया स्तर $level: +$reward ऊर्जा!';
  }

  @override
  String get challengeUseAi10 => 'ऊर्जा का प्रयोग करें 10';

  @override
  String get specifyIngredients => 'ज्ञात सामग्री निर्दिष्ट करें';

  @override
  String get specifyIngredientsOptional =>
      'ज्ञात सामग्री निर्दिष्ट करें (वैकल्पिक)';

  @override
  String get specifyIngredientsHint =>
      'वे सामग्री दर्ज करें जिन्हें आप जानते हैं, और एआई आपके लिए छिपे हुए सीज़निंग, तेल और सॉस की खोज करेगा।';

  @override
  String get sendToAi => 'एआई को भेजें';

  @override
  String get reanalyzeWithIngredients => 'सामग्री जोड़ें और पुनः विश्लेषण करें';

  @override
  String get reanalyzeButton => 'पुनः विश्लेषण करें (1 ऊर्जा)';

  @override
  String get ingredientsSaved => 'सामग्री सहेजी गई';

  @override
  String get pleaseAddAtLeastOneIngredient => 'कृपया कम से कम 1 सामग्री जोड़ें';

  @override
  String get hiddenIngredientsDiscovered => 'एआई द्वारा खोजे गए छिपे हुए तत्व';

  @override
  String get retroScanTitle => 'हाल की तस्वीरें स्कैन करें?';

  @override
  String get retroScanDescription =>
      'हम स्वचालित रूप से भोजन की तस्वीरें ढूंढने और उन्हें आपकी डायरी में जोड़ने के लिए पिछले 1 दिन की आपकी तस्वीरें स्कैन कर सकते हैं।';

  @override
  String get retroScanNote =>
      'केवल भोजन की तस्वीरें पहचानी जाती हैं - अन्य तस्वीरें नजरअंदाज कर दी जाती हैं। कोई भी फ़ोटो आपके डिवाइस को नहीं छोड़ता.';

  @override
  String get retroScanStart => 'मेरी तस्वीरें स्कैन करें';

  @override
  String get retroScanSkip => 'अभी के लिए छोड़ दे';

  @override
  String get retroScanInProgress => 'स्कैन किया जा रहा है...';

  @override
  String get retroScanTagline =>
      'MiRO आपका परिवर्तन कर रहा है\nस्वास्थ्य डेटा में भोजन की तस्वीरें।';

  @override
  String get retroScanFetchingPhotos => 'हाल की तस्वीरें लाई जा रही हैं...';

  @override
  String get retroScanAnalyzing => 'खाने की फ़ोटो का पता लगाया जा रहा है...';

  @override
  String retroScanPhotosFound(int count) {
    return 'पिछले 1 दिन में $count तस्वीरें मिलीं';
  }

  @override
  String get retroScanCompleteTitle => 'स्कैन पूर्ण!';

  @override
  String retroScanCompleteDesc(int count) {
    return '$count भोजन की तस्वीरें मिलीं! उन्हें आपकी टाइमलाइन में जोड़ दिया गया है, एआई विश्लेषण के लिए तैयार हैं।';
  }

  @override
  String get retroScanNoResultsTitle => 'खाने की कोई फ़ोटो नहीं मिली';

  @override
  String get retroScanNoResultsDesc =>
      'पिछले 1 दिन में भोजन की कोई फ़ोटो नहीं मिली। अपने अगले भोजन की फ़ोटो लेने का प्रयास करें!';

  @override
  String get retroScanAnalyzeHint =>
      'इन प्रविष्टियों के लिए एआई पोषण विश्लेषण प्राप्त करने के लिए अपनी टाइमलाइन पर \"सभी का विश्लेषण करें\" पर टैप करें।';

  @override
  String get retroScanDone => 'समझ गया!';

  @override
  String get welcomeEndTitle => 'MiRO में आपका स्वागत है!';

  @override
  String get welcomeEndMessage => 'MiRO आपकी सेवा में है.';

  @override
  String get welcomeEndJourney => 'साथ में अच्छी यात्रा करें!!';

  @override
  String get welcomeEndStart => 'चलो शुरू करो!';

  @override
  String greetingCalorieSummary(
      int remaining, int protein, int carbs, int fat) {
    return 'नमस्ते! आज मैं आपकी मदद करने में कैसे सक्षम हूं? आपके पास अभी भी $remaining kcal शेष है। अब तक: Protein ${protein}g, कार्ब्स ${carbs}g, वसा ${fat}g। मुझे बताएं कि आपने क्या खाया - भोजन के अनुसार सब कुछ सूचीबद्ध करें और मैं उन सभी को आपके लिए लॉग कर दूंगा। अधिक विवरण अधिक सटीक!!';
  }

  @override
  String greetingCuisineTip(String cuisine) {
    return 'आपका पसंदीदा व्यंजन $cuisine पर सेट है। आप इसे सेटिंग में कभी भी बदल सकते हैं!';
  }

  @override
  String greetingEnergyTip(int balance) {
    return 'आपके पास $balance ऊर्जा उपलब्ध है। एनर्जी बैज पर अपने दैनिक स्ट्रीक पुरस्कार का दावा करना न भूलें!';
  }

  @override
  String get greetingRenamePhotoTip =>
      'युक्ति: MiRO को अधिक सटीकता से विश्लेषण करने में सहायता के लिए आप भोजन फ़ोटो का नाम बदल सकते हैं!';

  @override
  String get greetingAddIngredientsTip =>
      'युक्ति: आप विश्लेषण के लिए MiRO पर भेजने से पहले ऐसी सामग्री जोड़ सकते हैं जिसके बारे में आप निश्चित हों। मैं आपके लिए सभी उबाऊ छोटी-छोटी जानकारियों का पता लगाऊंगा!';

  @override
  String greetingBackupReminder(int days) {
    return 'अरे मालिक! आपने $days दिनों से अपने डेटा का बैकअप नहीं लिया है। मैं सेटिंग्स में बैकअप लेने की सलाह देता हूं - आपका डेटा स्थानीय रूप से संग्रहीत है और अगर कुछ होता है तो मैं इसे पुनर्प्राप्त नहीं कर सकता!';
  }

  @override
  String get greetingFallback =>
      'नमस्ते! आज मैं आपकी मदद करने में कैसे सक्षम हूं? मुझे बताओ तुमने क्या खाया!';

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
  String get imageFoodNameHint =>
      'Anything special? e.g. has hidden meat inside';

  @override
  String get reanalyze => 'Re-analyze';

  @override
  String get reanalyzeFree => 'Free';

  @override
  String get reanalyzing => 'Analyzing...';

  @override
  String get reanalyzeSuccess => 'Analysis updated!';

  @override
  String get keepOrReanalyzeTitle => 'Which ingredients to keep?';

  @override
  String get keepOrReanalyzeDesc =>
      'Checked items will be kept, unchecked will be re-analyzed';

  @override
  String dailyCapReached(int count, int max) {
    return 'Daily analysis limit reached ($count/$max). Try again tomorrow!';
  }

  @override
  String dailyCapPartial(int done) {
    return 'Daily limit reached after analyzing $done items. Remaining items will be available tomorrow.';
  }

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
  String get ingredientsTapToExpand => 'Tap to view and edit';

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
  String get noIngredientsHint => 'No ingredients yet. Tap add to record.';

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
      'List is too long. Could you split it into 2-3 items? 🙏\n\nYour Energy has not been deducted.';

  @override
  String get analyzeFoodImageTitle => 'Analyze Food Image';

  @override
  String get foodNameImprovesAccuracy =>
      'Providing food name & quantity improves AI accuracy.';

  @override
  String get foodNameQuantityAndModeImprovesAccuracy =>
      'भोजन का नाम, मात्रा प्रदान करना और यह चुनना कि यह भोजन है या उत्पाद, AI की सटीकता में सुधार करेगा।';

  @override
  String get hideDetails => 'Hide details';

  @override
  String get showDetails => 'Show details';

  @override
  String get searchModeLabel => 'खोज मोड';

  @override
  String get normalFood => 'भोजन';

  @override
  String get normalFoodDesc => 'नियमित घर का पका हुआ खाना';

  @override
  String get packagedProduct => 'उत्पाद';

  @override
  String get packagedProductDesc => 'पोषण लेबल के साथ पैकेज्ड';

  @override
  String get saveAndAnalyzeButton => 'Analyze';

  @override
  String get saveWithoutAnalysis => 'Save';

  @override
  String get nutritionSection => 'Nutrition';

  @override
  String get nutritionSectionHint => 'Enter 0 if unknown';

  @override
  String get quickEditFoodName => 'Edit name';

  @override
  String get quickEditCancel => 'Cancel';

  @override
  String get quickEditSave => 'Save';

  @override
  String get mealSuggestionsToggle => 'Meal Suggestions';

  @override
  String get mealSuggestionsOn => 'On';

  @override
  String get mealSuggestionsOff => 'Off';

  @override
  String get basicMode => 'Basic';

  @override
  String get proMode => 'Pro';

  @override
  String get sandboxEmpty =>
      'No food items yet. Chat, snap a photo, or tap + to add!';

  @override
  String get deleteSelected => 'Delete';

  @override
  String get useProModeForDetail => 'For detailed editing, switch to Pro mode.';

  @override
  String get quickAddTitle => 'Quick Add';

  @override
  String get quickAddHint => 'e.g. Pad Thai, Rice...';

  @override
  String get quickCalButton => '+ cal';

  @override
  String get quickCalTitle => 'Quick Calorie';

  @override
  String get quickCalHint => 'Enter calories (kcal)';

  @override
  String quickCalSaved(int kcal) {
    return 'Quick Cal $kcal kcal';
  }

  @override
  String get quantity => 'Quantity';

  @override
  String get addToSandbox => 'Add';

  @override
  String get gallery => 'Gallery';

  @override
  String get longPressToSelect => 'चुनने के लिए लंबे समय तक दबाएं';

  @override
  String get healthSyncSection => 'स्वास्थ्य सिंक';

  @override
  String get healthSyncTitle => 'स्वास्थ्य ऐप से सिंक करें';

  @override
  String get healthSyncSubtitleOn => 'भोजन रिकॉर्ड सिंक • सक्रिय ऊर्जा शामिल';

  @override
  String get healthSyncSubtitleOff =>
      'Apple Health / Health Connect से जुड़ने के लिए टैप करें';

  @override
  String get healthSyncEnabled => 'स्वास्थ्य सिंक सक्रिय';

  @override
  String get healthSyncDisabled => 'स्वास्थ्य सिंक निष्क्रिय';

  @override
  String get healthSyncPermissionDeniedTitle => 'अनुमति आवश्यक';

  @override
  String get healthSyncPermissionDeniedMessage =>
      'आपने पहले स्वास्थ्य डेटा एक्सेस अस्वीकार कर दिया था।\nकृपया डिवाइस सेटिंग्स में सक्षम करें।';

  @override
  String get healthSyncGoToSettings => 'सेटिंग्स में जाएं';

  @override
  String healthSyncActiveEnergyValue(String value) {
    return '+$value kcal आज जली हुई';
  }

  @override
  String get healthSyncNotAvailable =>
      'इस डिवाइस पर Health Connect उपलब्ध नहीं है। कृपया Health Connect ऐप इंस्टॉल करें।';

  @override
  String get healthSyncFoodSynced => 'भोजन स्वास्थ्य ऐप में सिंक किया गया';

  @override
  String get healthSyncFoodDeletedFromHealth =>
      'स्वास्थ्य ऐप से भोजन हटाया गया';

  @override
  String get bmrSettingTitle => 'BMR (बेसल मेटाबोलिक रेट)';

  @override
  String get bmrSettingSubtitle => 'सक्रिय ऊर्जा अनुमान के लिए उपयोग';

  @override
  String get bmrDialogTitle => 'अपना BMR सेट करें';

  @override
  String get bmrDialogDescription =>
      'MiRO कुल कैलोरी बर्न से आराम की ऊर्जा घटाने के लिए BMR का उपयोग करता है, केवल आपकी सक्रिय ऊर्जा दिखाता है। डिफ़ॉल्ट 1500 kcal/दिन है। आप अपना BMR फिटनेस ऐप्स या ऑनलाइन कैलकुलेटर से जान सकते हैं।';

  @override
  String get healthSyncEnabledBmrHint =>
      'स्वास्थ्य सिंक सक्रिय। BMR डिफ़ॉल्ट: 1500 kcal/दिन — सेटिंग्स में समायोजित करें।';

  @override
  String get privacyPolicySectionHealthData => 'स्वास्थ्य डेटा एकीकरण';

  @override
  String get termsSectionHealthDataSync => 'स्वास्थ्य डेटा सिंक्रनाइज़ेशन';

  @override
  String get tdeeLabel => 'TDEE (Total Daily Energy Expenditure)';

  @override
  String get tdeeHint =>
      'Your estimated daily burn. Use the calculator below or enter manually.';

  @override
  String get tdeeCalcTitle => 'TDEE / BMR Calculator';

  @override
  String get tdeeCalcPrivacy =>
      'This is a calculator only — your data is NOT stored.';

  @override
  String get tdeeCalcGender => 'Gender';

  @override
  String get tdeeCalcMale => 'Male';

  @override
  String get tdeeCalcFemale => 'Female';

  @override
  String get tdeeCalcAge => 'Age';

  @override
  String get tdeeCalcWeight => 'Weight (kg)';

  @override
  String get tdeeCalcHeight => 'Height (cm)';

  @override
  String get tdeeCalcWeightLbs => 'Weight (lbs)';

  @override
  String get tdeeCalcHeightIn => 'Height (in)';

  @override
  String get tdeeCalcUnit => 'Unit';

  @override
  String get tdeeCalcUnitMetric => 'Metric';

  @override
  String get tdeeCalcUnitImperial => 'Imperial';

  @override
  String get tdeeCalcActivity => 'Activity Level';

  @override
  String get tdeeCalcActivitySedentary => 'Sedentary (office work)';

  @override
  String get tdeeCalcActivityLight => 'Light (1-2 days/week)';

  @override
  String get tdeeCalcActivityModerate => 'Moderate (3-5 days/week)';

  @override
  String get tdeeCalcActivityActive => 'Active (6-7 days/week)';

  @override
  String get tdeeCalcActivityVeryActive => 'Very Active (athlete)';

  @override
  String get tdeeCalcResult => 'Your estimated values';

  @override
  String tdeeCalcBmrResult(int value) {
    return 'BMR $value kcal/day';
  }

  @override
  String tdeeCalcTdeeResult(int value) {
    return 'TDEE $value kcal/day';
  }

  @override
  String get tdeeCalcApplyTdee => 'Use TDEE as Calorie Goal';

  @override
  String get tdeeCalcApplyBmr => 'Use BMR for Health Sync';

  @override
  String get tdeeCalcApplyBoth => 'Apply Both';

  @override
  String get tdeeCalcApplied => 'Applied!';

  @override
  String get tdeeCalcBmrExplain => 'BMR = energy your body uses at rest';

  @override
  String get tdeeCalcTdeeExplain => 'TDEE = BMR + daily activity';

  @override
  String get dailyBalanceLabel => 'Daily Balance';

  @override
  String get intakeLabel => 'Intake';

  @override
  String get burnedLabel => 'Burned';

  @override
  String get subscriptionAutoRenew => 'Auto-Renew';

  @override
  String get subscriptionAutoRenewOn => 'On';

  @override
  String get subscriptionAutoRenewOff => 'Off — expires at end of period';

  @override
  String get subscriptionManagedByAppStore =>
      'Subscription is managed through the App Store';

  @override
  String get subscriptionManagedByPlayStore =>
      'Subscription is managed through Google Play';

  @override
  String get subscriptionCannotLoadPrices =>
      'Unable to load prices from the Store right now';

  @override
  String get cloudSync => 'Cloud Sync';

  @override
  String get cloudSyncSynced => 'Data synced';

  @override
  String cloudSyncPending(int count) {
    return '$count entries pending sync';
  }

  @override
  String cloudSyncLastDate(String date) {
    return 'Last sync: $date';
  }

  @override
  String get cloudSyncNever => 'Never synced';

  @override
  String get cloudSyncAutoDescription =>
      'Auto-syncs when app opens for the first time each day';

  @override
  String get cloudSyncNow => 'Sync now';

  @override
  String get cloudSyncSuccess => 'Data synced successfully';

  @override
  String cloudSyncFailed(String error) {
    return 'Sync failed: $error';
  }

  @override
  String get backupExportSubtitle => 'Export file for device transfer';

  @override
  String get foodResearch => 'Food Research';

  @override
  String get foodResearchSubtitleOn => 'Helping improve food AI analysis';

  @override
  String get foodResearchSubtitleOff =>
      'Help food research with your food photos';

  @override
  String get foodResearchDialogTitle => 'Food Environment Research';

  @override
  String get foodResearchDialogDescription =>
      'Help us improve food AI analysis by sharing your food photo data';

  @override
  String get foodResearchWhatWeAnalyze => 'What we analyze:';

  @override
  String get foodResearchAnalyze1 => 'Food, beverages, snacks in photos';

  @override
  String get foodResearchAnalyze2 =>
      'Food brand + size (helps calibrate portion)';

  @override
  String get foodResearchAnalyze3 => 'Restaurant (if logo is visible)';

  @override
  String get foodResearchAnalyze4 => 'Utensils, plates, bowls';

  @override
  String get foodResearchWhatWeSkip => 'What we do NOT collect:';

  @override
  String get foodResearchSkip1 => 'Faces, personal info';

  @override
  String get foodResearchSkip2 => 'Personal belongings, clothing, bags';

  @override
  String get foodResearchSkip3 => 'Credit cards, documents';

  @override
  String get foodResearchPrivacyNote =>
      'Data is anonymized and used in aggregate only. You can turn this off anytime.';

  @override
  String get foodResearchDecline => 'Decline';

  @override
  String get foodResearchAccept => 'I\'d like to help';

  @override
  String get foodResearchThanks => 'Thank you for supporting food research!';

  @override
  String get foodResearchDisabled => 'Food research sharing disabled';

  @override
  String get consentDialogTitle => 'Data & Research';

  @override
  String get consentAnalyticsSection => 'App Usage Analytics';

  @override
  String get consentAnalyticsDescription =>
      'We use Firebase Analytics to improve your app experience';

  @override
  String get consentAnalyticsCollect =>
      'What we collect: Feature usage, screens viewed';

  @override
  String get consentAnalyticsNotCollect =>
      'Not collected: Food data, photos, health info';

  @override
  String get consentAnalyticsAnonymous => 'Data is aggregated and anonymous';

  @override
  String get consentFoodResearchSection => 'Food Research (Optional)';

  @override
  String get consentChangeAnytime =>
      'You can change these anytime in Profile → Settings';

  @override
  String get ingredientSearchHintExample =>
      'e.g. egg, vegetable oil, ground pork';

  @override
  String get freeIngredientSearch => 'Free ingredient search — no Energy cost!';

  @override
  String get recoveryKeyRestoreTitle => 'Restore with Recovery Key';

  @override
  String get recoveryKeyRestoreSubtitle =>
      'Use Key from your old device, no file needed';

  @override
  String get recoveryKeyRegenerateConfirm => 'Generate new Key?';

  @override
  String get recoveryKeyRegenerateWarning =>
      'The old Key will no longer work.\n\nIf you wrote it down, you\'ll need to note the new one instead.';

  @override
  String get recoveryKeyRegenerate => 'Generate new';

  @override
  String get recoveryKeyRegenerated => 'New Recovery Key generated';

  @override
  String get recoveryKeyDescription =>
      'Recover your account when switching devices';

  @override
  String get recoveryKeyRegenerateTooltip => 'Generate new Key';

  @override
  String get recoveryKeyLoading => 'Loading...';

  @override
  String get recoveryKeyHide => 'Hide';

  @override
  String get recoveryKeyShow => 'Show';

  @override
  String get recoveryKeyCopied => 'Recovery Key copied';

  @override
  String get recoveryKeyCopyTooltip => 'Copy';

  @override
  String get recoveryKeyWarning =>
      '⚠️ Keep this safe. Do not share with others.';

  @override
  String get restoreAccountTitle => 'Restore Account';

  @override
  String get restoreFromRecoveryKey => 'Restore from Recovery Key';

  @override
  String get restoreEnterKey =>
      'Enter the Recovery Key from your old device\nto recover your food history and Energy';

  @override
  String get restoreButton => 'Restore Account';

  @override
  String get restoreKeyLocation =>
      'Recovery Key is in Settings > Account on your old device';

  @override
  String get restoreSuccess => 'Restore successful!';

  @override
  String restoreFoodEntries(int count) {
    return '$count food entries';
  }

  @override
  String get restoreProfileRecovered => 'Profile & goals recovered';

  @override
  String get restoreStartUsing => 'Start using';

  @override
  String get restoreEmptyKey => 'Please enter a Recovery Key';

  @override
  String get restoreFailedGeneric =>
      'Unable to restore. Please check your Key.';

  @override
  String get restoreInvalidKey => 'Invalid Recovery Key. Please check again.';

  @override
  String get restoreExpiredKey =>
      'Recovery Key has expired. Please generate a new one from the original device.';

  @override
  String get restoreSameDevice => 'Cannot restore on the same device';

  @override
  String get restoreNoInternet => 'No internet connection. Please try again.';

  @override
  String restoreErrorGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String get nameChangeReAnalyzeTitle => 'Food Name Changed';

  @override
  String nameChangeReAnalyzeMessage(String newName) {
    return 'You changed the name to \"$newName\"\nIngredients with ✓ will be re-analyzed\nUncheck to keep as-is';
  }

  @override
  String get nameChangeReAnalyzeConfirm => 'Re-analyze';

  @override
  String get nameChangeSaveAsIs => 'Save as-is';

  @override
  String get nameChangeAnalyzing => 'Re-analyzing ingredients...';

  @override
  String get nameChangeAnalysisFailed => 'Re-analysis failed. Saved as-is.';

  @override
  String get nameChangeNoIngredientToAnalyze => 'No ingredients to re-analyze';

  @override
  String get freepassTitle => 'Freepass';

  @override
  String get freepassActive => 'सक्रिय';

  @override
  String get freepassUnlimitedAI => 'असीमित AI विश्लेषण';

  @override
  String freepassDaysRemaining(int days) {
    return '$days दिन शेष';
  }

  @override
  String get freepassDaysTitle => 'Freepass दिन';

  @override
  String get freepassDaysUnit => 'दिन';

  @override
  String freepassDaysSaved(int days) {
    return 'आपके पास $days दिन सहेजे हुए हैं';
  }

  @override
  String freepassDaysBadge(int days) {
    return '$daysदि';
  }

  @override
  String get freepassConvertTitle => 'Energy को Freepass में बदलें';

  @override
  String freepassConvertRate(int energy) {
    return '$energy Energy = 1 दिन असीमित AI';
  }

  @override
  String get freepassConvertDescription =>
      'Freepass दिन कभी समाप्त नहीं होते। जब आपका Energy Pass सब्सक्रिप्शन समाप्त होता है तो ये स्वचालित रूप से सक्रिय हो जाते हैं।';

  @override
  String freepassConvertButton(int days) {
    return 'बदलें (अधिकतम $days दिन)';
  }

  @override
  String freepassConvertMinimum(int energy) {
    return 'न्यूनतम $energy Energy आवश्यक';
  }

  @override
  String get freepassConvertConverting => 'बदल रहा है...';

  @override
  String get freepassConvertDialogTitle => 'Freepass में बदलें';

  @override
  String get freepassConvertDialogQuestion => 'कितने दिन?';

  @override
  String get freepassConvertDialogDay => 'दिन';

  @override
  String get freepassConvertDialogDays => 'दिन';

  @override
  String get freepassConvertDialogEnergyCost => 'Energy लागत';

  @override
  String get freepassConvertDialogRemainingBalance => 'शेष राशि';

  @override
  String get freepassConvertDialogConfirm => 'बदलें';

  @override
  String freepassConvertSuccess(int energy, int days) {
    return '$energy Energy → $days Freepass दिनों में बदला गया!';
  }

  @override
  String get freepassConvertFailed => 'बदलना विफल';

  @override
  String get freepassConvertError => 'बदलने के दौरान त्रुटि हुई';

  @override
  String get freepassConvertServiceUnavailable =>
      'सेवा अस्थायी रूप से अनुपलब्ध है। कृपया बाद में पुनः प्रयास करें।';

  @override
  String get subscriptionChangePlan => 'प्लान बदलें';

  @override
  String get subscriptionChangePlanDescAndroid =>
      'आप Google Play सब्सक्रिप्शन प्रबंधन से अपना प्लान बदल सकते हैं। नया प्लान अगले बिलिंग चक्र से लागू होगा।';

  @override
  String get subscriptionChangePlanDescIos =>
      'आप App Store सब्सक्रिप्शन प्रबंधन से अपने प्लान को अपग्रेड या डाउनग्रेड कर सकते हैं।';

  @override
  String get subscriptionCurrentPlan => 'वर्तमान';

  @override
  String get subscriptionChangePlanButton => 'बदलें';

  @override
  String get unifiedPermissionsScrollHint =>
      'Please scroll down to read all permissions, then tap Allow.';

  @override
  String get unifiedPermissionsScrollToEnable => 'Scroll down to enable';

  @override
  String get unifiedPermissionsHealthTitle => 'Health App';

  @override
  String get unifiedPermissionsHealthDesc =>
      'Enable in Settings to sync calories with Apple Health / Health Connect';

  @override
  String get privacyConsentTitle => 'Your Privacy Matters';

  @override
  String get privacyConsentSubtitle =>
      'Please review how MIRO uses your data. Toggle each option and scroll to the bottom to continue.';

  @override
  String get privacyConsentNotifTitle => 'Push Notifications';

  @override
  String get privacyConsentNotifDesc =>
      'Get helpful reminders and updates about your nutrition tracking.';

  @override
  String get privacyConsentNotifBullet1 => 'Daily meal tracking reminders';

  @override
  String get privacyConsentNotifBullet2 => 'Streak and achievement alerts';

  @override
  String get privacyConsentNotifBullet3 =>
      'You can turn off anytime in Settings';

  @override
  String get privacyConsentResearchDesc =>
      'Help improve food databases and nutritional accuracy for the community.';

  @override
  String get privacyConsentResearchBullet1 =>
      'Anonymized food photos help train AI models';

  @override
  String get privacyConsentResearchBullet2 => 'No personal data is ever shared';

  @override
  String get privacyConsentAdsTitle => 'Advertising';

  @override
  String get privacyConsentAdsDesc =>
      'Personalized ads help keep MIRO free. You can opt out anytime.';

  @override
  String get privacyConsentAdsBullet1 =>
      'Ads are never based on your food or health data';

  @override
  String get privacyConsentAdsBullet2 =>
      'Opt out to see generic, non-personalized ads';

  @override
  String get privacyConsentHealthNote =>
      'Health app integration (Apple Health / Health Connect) is separate and can be enabled later in Settings.';

  @override
  String get privacyConsentReadPolicy => 'Read full Privacy Policy';

  @override
  String get privacyConsentAccept => 'Continue';

  @override
  String get privacyConsentOptional => 'Optional';
}
