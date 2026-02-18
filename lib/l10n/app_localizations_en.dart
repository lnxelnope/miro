// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'MiRO';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get search => 'Search';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'An error occurred';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get done => 'Done';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get retry => 'Retry';

  @override
  String get ok => 'OK';

  @override
  String get foodName => 'Food name';

  @override
  String get calories => 'Calories';

  @override
  String get protein => 'Protein';

  @override
  String get carbs => 'Carbs';

  @override
  String get fat => 'Fat';

  @override
  String get servingSize => 'Serving size';

  @override
  String get servingUnit => 'Unit';

  @override
  String get kcal => 'kcal';

  @override
  String get mealBreakfast => 'Breakfast';

  @override
  String get mealLunch => 'Lunch';

  @override
  String get mealDinner => 'Dinner';

  @override
  String get mealSnack => 'Snack';

  @override
  String get todaySummary => 'Today\'s Summary';

  @override
  String dateSummary(String date) {
    return 'Summary for $date';
  }

  @override
  String get savedSuccess => 'Saved successfully';

  @override
  String get deletedSuccess => 'Deleted successfully';

  @override
  String get pleaseEnterFoodName => 'Please enter food name';

  @override
  String get noDataYet => 'No data yet';

  @override
  String get addFood => 'Add food';

  @override
  String get editFood => 'Edit food';

  @override
  String get deleteFood => 'Delete food';

  @override
  String get deleteConfirm => 'Confirm delete?';

  @override
  String get foodLoggedSuccess => 'Food logged!';

  @override
  String get noApiKey => 'Please set up Gemini API Key';

  @override
  String get noApiKeyDescription => 'Go to Profile → API Settings to set up';

  @override
  String get apiKeyTitle => 'Set up Gemini API Key';

  @override
  String get apiKeyRequired => 'API Key required';

  @override
  String get apiKeyFreeNote => 'Gemini API is free to use';

  @override
  String get apiKeySetup => 'Set up API Key';

  @override
  String get testConnection => 'Test connection';

  @override
  String get connectionSuccess => 'Connected successfully! Ready to use';

  @override
  String get connectionFailed => 'Connection failed';

  @override
  String get pasteKey => 'Paste';

  @override
  String get deleteKey => 'Delete API Key';

  @override
  String get openAiStudio => 'Open Google AI Studio';

  @override
  String get chatHint => 'Tell Miro e.g. \"Log fried rice\"...';

  @override
  String get chatFoodSaved => 'Food logged!';

  @override
  String chatFoodSavedDetail(
      String name, String serving, String unit, String cal) {
    return '$name $serving $unit\n$cal kcal';
  }

  @override
  String get featureNotAvailable => 'Sorry, this feature is not available yet';

  @override
  String get goalCalories => 'Calories/day';

  @override
  String get goalProtein => 'Protein/day';

  @override
  String get goalCarbs => 'Carbs/day';

  @override
  String get goalFat => 'Fat/day';

  @override
  String get goalWater => 'Water/day';

  @override
  String get healthGoals => 'Health Goals';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get clearAllData => 'Clear all data';

  @override
  String get clearAllDataConfirm =>
      'All data will be deleted. This cannot be undone!';

  @override
  String get about => 'About';

  @override
  String get language => 'Language';

  @override
  String get upgradePro => 'Upgrade to Pro';

  @override
  String get proUnlocked => 'MiRO Pro';

  @override
  String get proDescription => 'Unlimited AI food analysis';

  @override
  String aiRemaining(int remaining, int total) {
    return 'AI analysis: $remaining/$total remaining today';
  }

  @override
  String get aiLimitReached => 'AI limit reached for today (3/3)';

  @override
  String get restorePurchase => 'Restore purchase';

  @override
  String get myMeals => 'My Meals';

  @override
  String get createMeal => 'Create meal';

  @override
  String get ingredients => 'Ingredients';

  @override
  String get addIngredient => 'Add ingredient';

  @override
  String get searchFood => 'Search food';

  @override
  String get analyzing => 'Analyzing...';

  @override
  String get analyzeWithAi => 'Analyze with AI';

  @override
  String get analysisComplete => 'Analysis complete';

  @override
  String get timeline => 'Timeline';

  @override
  String get diet => 'Diet';

  @override
  String get quickAdd => 'Quick Add';

  @override
  String get welcomeTitle => 'MiRO';

  @override
  String get welcomeSubtitle => 'Easy food logging with AI';

  @override
  String get onboardingFeature1 => 'Snap a photo';

  @override
  String get onboardingFeature1Desc => 'AI calculates calories automatically';

  @override
  String get onboardingFeature2 => 'Type to log';

  @override
  String get onboardingFeature2Desc =>
      'Say \"had fried rice\" and it\'s logged';

  @override
  String get onboardingFeature3 => 'Daily summary';

  @override
  String get onboardingFeature3Desc => 'Track kcal, protein, carbs, fat';

  @override
  String get basicInfo => 'Basic Info';

  @override
  String get basicInfoDesc => 'To calculate your recommended daily calories';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get age => 'Age';

  @override
  String get weight => 'Weight';

  @override
  String get height => 'Height';

  @override
  String get activityLevel => 'Activity Level';

  @override
  String tdeeResult(int kcal) {
    return 'Your TDEE: $kcal kcal/day';
  }

  @override
  String get setupAiTitle => 'Set up Gemini AI';

  @override
  String get setupAiDesc => 'Snap a photo and AI analyzes it automatically';

  @override
  String get setupNow => 'Set up now';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get errorTimeout => 'Connection timeout — please try again';

  @override
  String get errorInvalidKey => 'Invalid API Key — check your settings';

  @override
  String get errorNoInternet => 'No internet connection';

  @override
  String get errorGeneral => 'An error occurred — please try again';

  @override
  String get errorQuotaExceeded => 'API quota exceeded — please wait and retry';

  @override
  String get apiKeyScreenTitle => 'Set up Gemini API Key';

  @override
  String get analyzeFoodWithAi => 'Analyze food with AI';

  @override
  String get analyzeFoodWithAiDesc =>
      'Snap a photo → AI calculates calories automatically\nGemini API is free to use!';

  @override
  String get openGoogleAiStudio => 'Open Google AI Studio';

  @override
  String get step1Title => 'Open Google AI Studio';

  @override
  String get step1Desc => 'Click the button below to create an API Key';

  @override
  String get step2Title => 'Sign in with Google Account';

  @override
  String get step2Desc =>
      'Use your Gmail or Google Account (create one for free if you don\'t have one)';

  @override
  String get step3Title => 'Click \"Create API Key\"';

  @override
  String get step3Desc =>
      'Click the blue \"Create API Key\" button\nIf asked to select a Project → Click \"Create API key in new project\"';

  @override
  String get step4Title => 'Copy Key and paste below';

  @override
  String get step4Desc =>
      'Click Copy next to the created Key\nKey will look like: AIzaSyxxxx...';

  @override
  String get step5Title => 'Paste API Key here';

  @override
  String get pasteApiKeyHint => 'Paste the copied API Key';

  @override
  String get saveApiKey => 'Save API Key';

  @override
  String get testingConnection => 'Testing...';

  @override
  String get deleteApiKey => 'Delete API Key';

  @override
  String get deleteApiKeyConfirm => 'Delete API Key?';

  @override
  String get deleteApiKeyConfirmDesc =>
      'You won\'t be able to use AI food analysis until you set it up again';

  @override
  String get apiKeySaved => 'API Key saved successfully';

  @override
  String get apiKeyDeleted => 'API Key deleted successfully';

  @override
  String get pleasePasteApiKey => 'Please paste API Key first';

  @override
  String get apiKeyInvalidFormat =>
      'Invalid API Key — must start with \"AIza\"';

  @override
  String get connectionSuccessMessage =>
      '✅ Connected successfully! Ready to use';

  @override
  String get connectionFailedMessage => '❌ Connection failed';

  @override
  String get faqTitle => 'Frequently Asked Questions';

  @override
  String get faqFreeQuestion => 'Is it really free?';

  @override
  String get faqFreeAnswer =>
      'Yes! Gemini 2.0 Flash is free for 1,500 requests/day\nFor food logging (5-15 times/day) → Free forever, no payment required';

  @override
  String get faqSafeQuestion => 'Is it safe?';

  @override
  String get faqSafeAnswer =>
      'API Key is stored in Secure Storage on your device only\nApp doesn\'t send Key to our server\nIf Key leaks → Delete and create a new one (it\'s not your Google password)';

  @override
  String get faqNoKeyQuestion => 'What if I don\'t create a Key?';

  @override
  String get faqNoKeyAnswer =>
      'You can still use the app! But:\n❌ Cannot take photo → AI analysis\n✅ Can log food manually\n✅ Quick Add works\n✅ View kcal/macro summary works';

  @override
  String get faqCreditCardQuestion => 'Do I need a credit card?';

  @override
  String get faqCreditCardAnswer =>
      'No — Create API Key for free without credit card';
}
