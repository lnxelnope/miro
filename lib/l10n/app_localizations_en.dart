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
  String get myMeals => 'My Meals:';

  @override
  String get createMeal => 'Create Meal';

  @override
  String get ingredients => 'Ingredients';

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

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navMyMeals => 'My Meals';

  @override
  String get navCamera => 'Camera';

  @override
  String get navGallery => 'Gallery';

  @override
  String get navAiChat => 'AI Chat';

  @override
  String get navProfile => 'Profile';

  @override
  String get appBarTodayIntake => 'Today\'s Intake';

  @override
  String get appBarMyMeals => 'My Meals';

  @override
  String get appBarCamera => 'Camera';

  @override
  String get appBarAiChat => 'AI Chat';

  @override
  String get appBarMiro => 'MIRO';

  @override
  String get permissionRequired => 'Permission Required';

  @override
  String get permissionRequiredDesc => 'MIRO needs access to the following:';

  @override
  String get permissionPhotos => 'Photos — to scan food';

  @override
  String get permissionCamera => 'Camera — to photograph food';

  @override
  String get permissionSkip => 'Skip';

  @override
  String get permissionAllow => 'Allow';

  @override
  String get permissionAllGranted => 'All permissions granted';

  @override
  String permissionDenied(String denied) {
    return 'Permission denied: $denied';
  }

  @override
  String get openSettings => 'Open Settings';

  @override
  String get exitAppTitle => 'Exit App?';

  @override
  String get exitAppMessage => 'Are you sure you want to exit?';

  @override
  String get exit => 'Exit';

  @override
  String get healthGoalsTitle => 'Health Goals';

  @override
  String get healthGoalsInfo =>
      'Set your daily calorie goal, macros, and per-meal budgets.\nLock to auto-calculate: 2 macros or 3 meals.';

  @override
  String get dailyCalorieGoal => 'Daily Calorie Goal';

  @override
  String get proteinLabel => 'Protein';

  @override
  String get carbsLabel => 'Carbs';

  @override
  String get fatLabel => 'Fat';

  @override
  String get autoBadge => 'auto';

  @override
  String kcalPerGram(int kcalPerGram, int kcal) {
    return '$kcalPerGram kcal/g • $kcal kcal';
  }

  @override
  String get mealCalorieBudget => 'Meal Calorie Budget';

  @override
  String mealBudgetBalanced(int total, int goal) {
    return 'Total $total kcal = Goal $goal kcal';
  }

  @override
  String mealBudgetRemaining(int total, int goal, int remaining) {
    return 'Total $total / $goal kcal  ($remaining remaining)';
  }

  @override
  String get lockMealsHint => 'Lock 3 meals to auto-calculate the 4th';

  @override
  String get breakfastLabel => 'Breakfast';

  @override
  String get lunchLabel => 'Lunch';

  @override
  String get dinnerLabel => 'Dinner';

  @override
  String get snackLabel => 'Snack';

  @override
  String percentOfDailyGoal(String percent) {
    return '$percent% of daily goal';
  }

  @override
  String get smartSuggestionRange => 'Smart Suggestion Range';

  @override
  String get smartSuggestionHow => 'How does Smart Suggestion work?';

  @override
  String smartSuggestionDesc(int threshold, int min, int max) {
    return 'We suggest foods from your My Meals, ingredients, and yesterday\'s meals that fit your per-meal budget.\n\nThis threshold controls how flexible the suggestions are. For example, if your lunch budget is 700 kcal and threshold is $threshold kcal, we\'ll suggest foods between $min–$max kcal.';
  }

  @override
  String get suggestionThreshold => 'Suggestion Threshold';

  @override
  String suggestionThresholdDesc(int threshold) {
    return 'Allow foods ± $threshold kcal from meal budget';
  }

  @override
  String get goalsSavedSuccess => 'Goals saved successfully!';

  @override
  String get canOnlyLockTwoMacros => 'Can only lock 2 macros at once';

  @override
  String get canOnlyLockThreeMeals =>
      'Can only lock 3 meals; the 4th auto-calculates';

  @override
  String get tabMeals => 'Meals';

  @override
  String get tabIngredients => 'Ingredients';

  @override
  String get searchMealsOrIngredients => 'Search meals or ingredients...';

  @override
  String get createNewMeal => 'Create New Meal';

  @override
  String get addIngredient => 'Add Ingredient';

  @override
  String get noMealsYet => 'No meals yet';

  @override
  String get noMealsYetDesc =>
      'Analyze food with AI to auto-save meals\nor create one manually';

  @override
  String get noIngredientsYet => 'No ingredients yet';

  @override
  String get noIngredientsYetDesc =>
      'When you analyze food with AI\ningredients will be saved automatically';

  @override
  String mealCreated(String name) {
    return 'Created \"$name\"';
  }

  @override
  String mealLogged(String name) {
    return 'Logged \"$name\"';
  }

  @override
  String ingredientAmount(String unit) {
    return 'Amount ($unit)';
  }

  @override
  String ingredientLogged(String name, String amount, String unit) {
    return 'Logged \"$name\" $amount$unit';
  }

  @override
  String get mealNotFound => 'Meal not found';

  @override
  String mealUpdated(String name) {
    return 'Updated \"$name\"';
  }

  @override
  String get deleteMealTitle => 'Delete Meal?';

  @override
  String deleteMealMessage(String name) {
    return '\"$name\"';
  }

  @override
  String get deleteMealNote => 'Ingredients will not be deleted.';

  @override
  String get mealDeleted => 'Meal deleted';

  @override
  String ingredientCreated(String name) {
    return 'Created \"$name\"';
  }

  @override
  String get ingredientNotFound => 'Ingredient not found';

  @override
  String ingredientUpdated(String name) {
    return 'Updated \"$name\"';
  }

  @override
  String get deleteIngredientTitle => 'Delete Ingredient?';

  @override
  String deleteIngredientMessage(String name) {
    return '\"$name\"';
  }

  @override
  String get ingredientDeleted => 'Ingredient deleted';

  @override
  String get noIngredientsData => 'No ingredients data';

  @override
  String ingredientDetail(String name, String amount, String unit) {
    return '$name ($amount $unit)';
  }

  @override
  String ingredientCalories(int calories) {
    return '$calories kcal';
  }

  @override
  String get useThisMeal => 'Use This Meal';

  @override
  String errorLoading(String error) {
    return 'Error loading: $error';
  }

  @override
  String scanFoundNewImages(int count, String date) {
    return 'Found $count new images on $date';
  }

  @override
  String scanNoNewImages(String date) {
    return 'No new images found on $date';
  }

  @override
  String aiAnalysisRemaining(int remaining, int total) {
    return 'AI Analysis: $remaining/$total remaining today';
  }

  @override
  String get upgradeToProUnlimited => 'Upgrade to Pro for unlimited use';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String confirmDeleteMessage(String name) {
    return 'Do you want to delete \"$name\"?';
  }

  @override
  String get entryDeletedSuccess => '✅ Entry deleted successfully';

  @override
  String entryDeleteError(String error) {
    return '❌ Error: $error';
  }

  @override
  String batchAnalyzeItems(int count) {
    return '$count items (batch)';
  }

  @override
  String analyzeCancelled(int success) {
    return 'Cancelled — analyzed $success items successfully';
  }

  @override
  String analyzeSuccessAll(int success) {
    return '✅ Analyzed $success items successfully';
  }

  @override
  String analyzeSuccessPartial(int success, int total, int failed) {
    return '⚠️ Analyzed $success/$total items ($failed failed)';
  }

  @override
  String analyzeProgress(String item, int current, int total) {
    return '$item  ($current/$total)';
  }

  @override
  String get pullToScanMeal => 'Pull to scan your meal';

  @override
  String get analyzeAll => 'Analyze All';

  @override
  String get addFoodTitle => 'Add Food';

  @override
  String get foodNameRequired => 'Food Name *';

  @override
  String get foodNameHint => 'e.g. Fried Rice with Shrimp';

  @override
  String get selectedFromMyMeal =>
      '✅ Selected from My Meal — nutrition data auto-filled';

  @override
  String get foundInDatabase =>
      '✅ Found in database — nutrition data auto-filled';

  @override
  String get saveAndAnalyze => 'Save & Analyze';

  @override
  String get notFoundInDatabase =>
      'Not found in database — will be analyzed in background';

  @override
  String get amountLabel => 'Amount';

  @override
  String get unitLabel => 'Unit';

  @override
  String get nutritionAutoCalculated => 'Nutrition (auto-calculated by amount)';

  @override
  String get nutritionEnterZero => 'Nutrition (enter 0 if unknown)';

  @override
  String get caloriesLabel => 'Calories (kcal)';

  @override
  String get proteinLabelShort => 'Protein (g)';

  @override
  String get carbsLabelShort => 'Carbs (g)';

  @override
  String get fatLabelShort => 'Fat (g)';

  @override
  String get mealTypeLabel => 'Meal Type';

  @override
  String get pleaseEnterFoodNameFirst => 'Please enter food name first';

  @override
  String get savedAnalyzingBackground => '✅ Saved — analyzing in background';

  @override
  String get foodAdded => '✅ Food added';

  @override
  String get suggestionSourceMyMeal => 'My Meal';

  @override
  String get suggestionSourceIngredient => 'Ingredient';

  @override
  String get suggestionSourceDatabase => 'Database';

  @override
  String get editFoodTitle => 'Edit Food';

  @override
  String get foodNameLabel => 'Food name';

  @override
  String get changeAmountAutoUpdate =>
      'Change amount → calories update automatically';

  @override
  String baseNutrition(int calories, String unit) {
    return 'Base: $calories kcal / 1 $unit';
  }

  @override
  String get calculatedFromIngredients => 'Calculated from ingredients below';

  @override
  String get ingredientsEditable => 'Ingredients (Editable)';

  @override
  String get addIngredientButton => 'Add';

  @override
  String get noIngredientsAddHint => 'No ingredients — tap \"Add\" to add new';

  @override
  String get editIngredientsHint =>
      'Edit name/amount → Tap search icon to search database or AI';

  @override
  String get ingredientNameHint => 'e.g. Chicken Egg';

  @override
  String get searchDbOrAi => 'Search DB / AI';

  @override
  String get amountHint => 'Amount';

  @override
  String get fromDatabase => 'From Database';

  @override
  String subIngredients(int count) {
    return 'Sub-ingredients ($count)';
  }

  @override
  String get addSubIngredient => 'Add';

  @override
  String get subIngredientNameHint => 'Sub-ingredient name';

  @override
  String get amountShort => 'Amt';

  @override
  String get pleaseEnterSubIngredientName =>
      'Please enter sub-ingredient name first';

  @override
  String foundInDatabaseSub(String name) {
    return 'Found \"$name\" in database!';
  }

  @override
  String aiAnalyzedSub(String name) {
    return 'AI analyzed \"$name\" (-1 Energy)';
  }

  @override
  String get couldNotAnalyzeSub => 'Could not analyze sub-ingredient';

  @override
  String get pleaseEnterIngredientName => 'Please enter ingredient name';

  @override
  String get reAnalyzeTitle => 'Re-analyze?';

  @override
  String reAnalyzeMessage(String name) {
    return '\"$name\" already has nutrition data.\n\nAnalyzing again will use 1 Energy.\n\nContinue?';
  }

  @override
  String get reAnalyzeButton => 'Re-analyze (1 Energy)';

  @override
  String get amountNotSpecified => 'Amount not specified';

  @override
  String amountNotSpecifiedMessage(String name) {
    return 'Please specify amount for \"$name\" first\nOr use default 100 g?';
  }

  @override
  String get useDefault100g => 'Use 100 g';

  @override
  String aiAnalyzedResult(String name, int calories) {
    return 'AI: \"$name\" → $calories kcal';
  }

  @override
  String get unableToAnalyze => 'Unable to analyze';

  @override
  String get today => 'Today';

  @override
  String get savedSuccessfully => '✅ Saved successfully';

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
  String get confirmFoodPhoto => 'Confirm Food Photo';

  @override
  String get photoSavedAutomatically => 'Photo saved automatically';

  @override
  String get foodNameHintExample => 'e.g., Grilled chicken salad';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get quantityHint => '1';

  @override
  String get optionalFoodInfo =>
      'Entering the food name and quantity is optional, but providing them will improve AI analysis accuracy.';

  @override
  String get saveOnly => 'Save only';

  @override
  String get pleaseEnterValidQuantity => 'Please enter a valid quantity';

  @override
  String analyzedResult(String name, int calories) {
    return '✅ Analyzed: $name — $calories kcal';
  }

  @override
  String get couldNotAnalyzeSaved =>
      '⚠️ Could not analyze — saved, use \"Analyze All\" later';

  @override
  String get savedAnalyzeLater =>
      '✅ Saved — analyze later with \"Analyze All\"';

  @override
  String get editIngredientTitle => 'Edit Ingredient';

  @override
  String get ingredientNameRequired => 'Ingredient Name *';

  @override
  String get baseAmountLabel => 'Base Amount';

  @override
  String get baseAmountHint => '100';

  @override
  String nutritionPerBase(String amount, String unit) {
    return 'Nutrition per $amount $unit';
  }

  @override
  String nutritionCalculatedPerBase(String amount, String unit) {
    return 'Nutrition calculated per $amount $unit — system will auto-calculate based on actual amount consumed';
  }

  @override
  String get createIngredient => 'Create Ingredient';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get pleaseEnterIngredientNameFirst =>
      'Please enter ingredient name first';

  @override
  String aiAnalyzedIngredient(
      String name, String amount, String unit, int calories) {
    return 'AI: \"$name\" $amount $unit → $calories kcal';
  }

  @override
  String get unableToFindIngredient => 'Unable to find this ingredient';

  @override
  String searchFailed(String error) {
    return 'Search failed: $error';
  }

  @override
  String deleteEntriesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Entries',
      one: 'Entry',
    );
    return 'Delete $count $_temp0?';
  }

  @override
  String deleteEntriesMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return 'Delete $count selected food $_temp0?';
  }

  @override
  String get deleteAll => 'Delete All';

  @override
  String deletedEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return 'Deleted $count $_temp0';
  }

  @override
  String movedEntriesToDate(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return 'Moved $count $_temp0 to $date';
  }

  @override
  String get allSelectedAlreadyAnalyzed =>
      'All selected entries are already analyzed';

  @override
  String analyzeCancelledSelected(int success) {
    return 'Cancelled — $success analyzed';
  }

  @override
  String analyzedEntriesAll(int success) {
    String _temp0 = intl.Intl.pluralLogic(
      success,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return 'Analyzed $success $_temp0';
  }

  @override
  String analyzedEntriesPartial(int success, int total, int failed) {
    return 'Analyzed $success/$total ($failed failed)';
  }

  @override
  String analyzeProgressSelected(int current, int total, String item) {
    return '$current/$total  $item';
  }

  @override
  String get noEntriesYet => 'No entries yet';

  @override
  String get selectAll => 'Select all';

  @override
  String get deselectAll => 'Deselect all';

  @override
  String get moveToDate => 'Move to date';

  @override
  String get analyzeSelected => 'Analyze selected';

  @override
  String get deleteTooltip => 'Delete';

  @override
  String get move => 'Move';

  @override
  String get deleteTooltipAction => 'Delete';

  @override
  String switchToModeTitle(String mode) {
    return 'Switch to $mode mode?';
  }

  @override
  String switchToModeMessage(String current, String newMode) {
    return 'This item was analyzed as $current.\n\nRe-analyzing as $newMode will use 1 Energy.\n\nContinue?';
  }

  @override
  String analyzingAsMode(String mode) {
    return 'Analyzing as $mode...';
  }

  @override
  String reAnalyzedAsMode(String mode) {
    return '✅ Re-analyzed as $mode';
  }

  @override
  String get analysisFailed => '❌ Analysis failed';

  @override
  String get aiAnalysisComplete => '✅ AI analyzed and saved';

  @override
  String get changeMealType => 'Change Meal Type';

  @override
  String get moveToAnotherDate => 'Move to Another Date';

  @override
  String currentDate(String date) {
    return 'Current: $date';
  }

  @override
  String get cancelDateChange => 'Cancel Date Change';

  @override
  String get undo => 'Undo';

  @override
  String get chatHistory => 'Chat History';

  @override
  String get newChat => 'New chat';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get clear => 'Clear';

  @override
  String get helloImMiro => 'Hello! I\'m Miro';

  @override
  String get tellMeWhatYouAteToday => 'Tell me what you ate today!';

  @override
  String get tellMeWhatYouAte => 'Tell me what you ate...';

  @override
  String get clearHistoryTitle => 'Clear history?';

  @override
  String get clearHistoryMessage =>
      'All messages in this session will be deleted.';

  @override
  String get chatHistoryTitle => 'Chat History';

  @override
  String get newLabel => 'New';

  @override
  String get noChatHistoryYet => 'No chat history yet';

  @override
  String get active => 'Active';

  @override
  String get deleteChatTitle => 'Delete chat?';

  @override
  String deleteChatMessage(String title) {
    return 'Delete \"$title\"?';
  }

  @override
  String weeklySummaryTitle(String start, String end) {
    return '📊 Weekly Summary ($start - $end)';
  }

  @override
  String daySummary(String day, String calories, String emoji, String diff) {
    return '📅 $day: $calories kcal $emoji ($diff)';
  }

  @override
  String overTarget(String amount) {
    return '$amount over target';
  }

  @override
  String underTarget(String amount) {
    return '$amount under target';
  }

  @override
  String get noFoodLoggedThisWeek => 'No food logged this week yet.';

  @override
  String averageKcalPerDay(String average) {
    return '🔥 Average: $average kcal/day';
  }

  @override
  String targetKcalPerDay(String target) {
    return '🎯 Target: $target kcal/day';
  }

  @override
  String resultOverTarget(String amount) {
    return '📈 Result: $amount kcal over target';
  }

  @override
  String resultUnderTarget(String amount) {
    return '📈 Result: $amount kcal under target — Great job! 💪';
  }

  @override
  String failedToLoadWeeklySummary(String error) {
    return '❌ Failed to load weekly summary: $error';
  }

  @override
  String monthlySummaryTitle(String month, int year) {
    return '📊 Monthly Summary ($month $year)';
  }

  @override
  String totalDays(int days) {
    return '📅 Total Days: $days';
  }

  @override
  String totalConsumed(String calories) {
    return '🔥 Total Consumed: $calories kcal';
  }

  @override
  String targetTotal(String target) {
    return '🎯 Target Total: $target kcal';
  }

  @override
  String averageKcalPerDayShort(String average) {
    return '📈 Average: $average kcal/day';
  }

  @override
  String overTargetThisMonth(String amount) {
    return '⚠️ $amount kcal over target this month';
  }

  @override
  String underTargetThisMonth(String amount) {
    return '✅ $amount kcal under target — Excellent! 💪';
  }

  @override
  String failedToLoadMonthlySummary(String error) {
    return '❌ Failed to load monthly summary: $error';
  }

  @override
  String get localAiHelpTitle => '🤖 Local AI Help';

  @override
  String get localAiHelpFormat => 'Format: [food] [amount] [unit]';

  @override
  String get localAiHelpExamples =>
      'Examples:\n• chicken 100g and rice 200g\n• pizza 2 slices\n• apple 1 piece, banana 1 piece';

  @override
  String get localAiHelpNote =>
      'Note: English only, basic parsing\nSwitch to Miro AI for better results!';

  @override
  String hiNoFoodLogged(String target) {
    return '🤖 Hi! No food logged yet today.\n   Target: $target kcal — Ready to start logging? 🍽️';
  }

  @override
  String hiKcalLeft(String remaining) {
    return '🤖 Hi! You have $remaining kcal left for today.\n   Ready to log your meals? 😊';
  }

  @override
  String hiOverTarget(String calories, String over) {
    return '🤖 Hi! You\'ve consumed $calories kcal today.\n   $over kcal over target — Let\'s keep tracking! 💪';
  }

  @override
  String get hiReadyToLog => '🤖 Hi! Ready to log your meals? 😊';

  @override
  String get notEnoughEnergy => 'Not enough Energy';

  @override
  String get thinkingMealIdeas => '🤖 Thinking of great meal ideas for you...';

  @override
  String get recentMeals => 'Recent meals: ';

  @override
  String get noRecentFood => 'No recent food logged.';

  @override
  String remainingCaloriesToday(String remaining) {
    return '. Remaining calories today: $remaining kcal.';
  }

  @override
  String failedToGetMenuSuggestions(String error) {
    return '❌ Failed to get menu suggestions: $error';
  }

  @override
  String get mealSuggestionsTitle =>
      '🤖 Based on your food log, here are 3 meal suggestions:\n';

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
  String get pickOneAndLog => '\nPick one and I\'ll log it for you! 😊';

  @override
  String energyCost(int cost) {
    return '\n⚡ -$cost Energy';
  }

  @override
  String get giveMeTipsForHealthyEating => 'Give me tips for healthy eating';

  @override
  String get howManyCaloriesToday => 'How many calories today?';

  @override
  String get menuLabel => 'Menu';

  @override
  String get weeklyLabel => 'Weekly';

  @override
  String get monthlyLabel => 'Monthly';

  @override
  String get tipsLabel => 'Tips';

  @override
  String get summaryLabel => 'Summary';

  @override
  String get helpLabel => 'Help';

  @override
  String get onboardingWelcomeSubtitle =>
      'Track calories effortlessly\nwith AI-powered analysis';

  @override
  String get onboardingSnap => 'Snap';

  @override
  String get onboardingSnapDesc => 'AI analyzes instantly';

  @override
  String get onboardingType => 'Type';

  @override
  String get onboardingTypeDesc => 'Log in seconds';

  @override
  String get onboardingEdit => 'Edit';

  @override
  String get onboardingEditDesc => 'Fine-tune accuracy';

  @override
  String get onboardingNext => 'Next →';

  @override
  String get onboardingDisclaimer => 'AI-estimated data. Not medical advice.';

  @override
  String get onboardingQuickSetup => 'Quick Setup';

  @override
  String get onboardingHelpAiUnderstand =>
      'Help AI understand your food better';

  @override
  String get onboardingYourTypicalCuisine => 'Your typical cuisine:';

  @override
  String get onboardingDailyCalorieGoal => 'Daily calorie goal (optional):';

  @override
  String get onboardingKcalPerDay => 'kcal/day';

  @override
  String get onboardingCalorieGoalHint => '2000';

  @override
  String get onboardingCanChangeAnytime =>
      'You can change this anytime in Profile settings';

  @override
  String get onboardingYoureAllSet => 'You\'re All Set!';

  @override
  String get onboardingStartTracking =>
      'Start tracking your meals today.\nSnap a photo or type what you ate.';

  @override
  String get onboardingWelcomeGift => 'Welcome Gift';

  @override
  String get onboardingFreeEnergy => '10 FREE Energy';

  @override
  String get onboardingFreeEnergyDesc => '= 10 AI analyses to get started';

  @override
  String get onboardingEnergyCost =>
      'Each analysis costs 1 Energy\nThe more you use, the more you earn!';

  @override
  String get onboardingStartTrackingButton => 'Start Tracking! →';

  @override
  String get onboardingNoCreditCard => 'No credit card • No hidden fees';

  @override
  String get cameraTakePhotoOfFood => 'Take a photo of your food';

  @override
  String get cameraFailedToInitialize => 'Failed to initialize camera';

  @override
  String get cameraFailedToCapture => 'Failed to capture photo';

  @override
  String get cameraFailedToPickFromGallery =>
      'Failed to pick image from gallery';

  @override
  String get cameraProcessing => 'Processing...';

  @override
  String get referralInviteFriends => 'Invite Friends';

  @override
  String get referralYourReferralCode => 'Your Referral Code';

  @override
  String get referralLoading => 'Loading...';

  @override
  String get referralCopy => 'Copy';

  @override
  String get referralShareCodeDescription =>
      'Share this code with friends! When they use AI 3 times, you both get rewards!';

  @override
  String get referralEnterReferralCode => 'Enter Referral Code';

  @override
  String get referralCodeHint => 'MIRO-XXXX-XXXX-XXXX';

  @override
  String get referralSubmitCode => 'Submit Code';

  @override
  String get referralPleaseEnterCode => 'Please enter a referral code';

  @override
  String get referralCodeAccepted => 'Referral code accepted!';

  @override
  String get referralCodeCopied => 'Referral code copied to clipboard!';

  @override
  String referralEnergyBonus(int energy) {
    return '+$energy Energy!';
  }

  @override
  String get referralHowItWorks => 'How It Works';

  @override
  String get referralStep1Title => 'Share your referral code';

  @override
  String get referralStep1Description =>
      'Copy and share your MiRO ID with friends';

  @override
  String get referralStep2Title => 'Friend enters your code';

  @override
  String get referralStep2Description => 'They get +20 Energy immediately';

  @override
  String get referralStep3Title => 'Friend uses AI 3 times';

  @override
  String get referralStep3Description => 'When they complete 3 AI analyses';

  @override
  String get referralStep4Title => 'You get rewarded!';

  @override
  String get referralStep4Description => 'You receive +5 Energy!';

  @override
  String get tierBenefitsTitle => 'Tier Benefits';

  @override
  String get tierBenefitsUnlockRewards => 'Unlock Rewards\nwith Daily Streaks';

  @override
  String get tierBenefitsKeepStreakDescription =>
      'Keep your streak alive to unlock higher tiers and earn amazing benefits!';

  @override
  String get tierBenefitsHowItWorks => 'How It Works';

  @override
  String get tierBenefitsDailyEnergyReward => 'Daily Energy Reward';

  @override
  String get tierBenefitsDailyEnergyDescription =>
      'Use AI at least once per day to earn bonus energy. Higher tiers = more daily energy!';

  @override
  String get tierBenefitsPurchaseBonus => 'Purchase Bonus';

  @override
  String get tierBenefitsPurchaseBonusDescription =>
      'Gold & Diamond tiers get extra energy on every purchase (10-20% more!)';

  @override
  String get tierBenefitsGracePeriod => 'Grace Period';

  @override
  String get tierBenefitsGracePeriodDescription =>
      'Miss a day without losing your streak. Silver+ tiers get protection!';

  @override
  String get tierBenefitsAllTiers => 'All Tiers';

  @override
  String get tierBenefitsNew => 'NEW';

  @override
  String get tierBenefitsPopular => 'POPULAR';

  @override
  String get tierBenefitsBest => 'BEST';

  @override
  String get tierBenefitsDailyCheckIn => 'Daily Check-in';

  @override
  String get tierBenefitsProTips => 'Pro Tips';

  @override
  String get tierBenefitsTip1 =>
      'Use AI daily to earn free energy and build your streak';

  @override
  String get tierBenefitsTip2 =>
      'Diamond tier earns +4 Energy per day — that\'s 120/month!';

  @override
  String get tierBenefitsTip3 =>
      'Purchase Bonus applies to ALL energy packages!';

  @override
  String get tierBenefitsTip4 =>
      'Grace period protects your streak if you miss a day';

  @override
  String get subscriptionEnergyPass => 'Energy Pass';

  @override
  String get subscriptionInAppPurchasesNotAvailable =>
      'In-app purchases not available';

  @override
  String get subscriptionFailedToInitiatePurchase =>
      'Failed to initiate purchase';

  @override
  String subscriptionError(String error) {
    return 'Error: $error';
  }

  @override
  String get subscriptionFailedToLoad => 'Failed to load subscription';

  @override
  String get subscriptionUnknownError => 'Unknown error';

  @override
  String get subscriptionRetry => 'Retry';

  @override
  String get subscriptionEnergyPassActive => 'Energy Pass Active';

  @override
  String get subscriptionUnlimitedAccess => 'You have unlimited access';

  @override
  String get subscriptionStatus => 'Status';

  @override
  String get subscriptionRenews => 'Renews';

  @override
  String get subscriptionPrice => 'Price';

  @override
  String get subscriptionYourBenefits => 'Your Benefits';

  @override
  String get subscriptionManageSubscription => 'Manage Subscription';

  @override
  String get subscriptionNoProductAvailable =>
      'No subscription product available';

  @override
  String get subscriptionWhatYouGet => 'What You Get';

  @override
  String get subscriptionPerMonth => 'per month';

  @override
  String get subscriptionSubscribeNow => 'Subscribe Now';

  @override
  String get subscriptionCancelAnytime => 'Cancel anytime';

  @override
  String get subscriptionAutoRenewTerms =>
      'Your subscription will renew automatically. You can cancel anytime from Google Play.';

  @override
  String get disclaimerHealthDisclaimer => 'Health Disclaimer';

  @override
  String get disclaimerImportantReminders => 'Important Reminders:';

  @override
  String get disclaimerBullet1 => 'All nutritional data is estimated';

  @override
  String get disclaimerBullet2 => 'AI analysis may contain errors';

  @override
  String get disclaimerBullet3 => 'Not a substitute for professional advice';

  @override
  String get disclaimerBullet4 =>
      'Consult healthcare providers for medical guidance';

  @override
  String get disclaimerBullet5 => 'Use at your own discretion and risk';

  @override
  String get disclaimerIUnderstand => 'I Understand';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get privacyPolicySubtitle => 'MiRO — My Intake Record Oracle';

  @override
  String get privacyPolicyHeaderNote =>
      'Your food data stays on your device. Energy balance synced securely via Firebase.';

  @override
  String get privacyPolicySectionInformationWeCollect =>
      'Information We Collect';

  @override
  String get privacyPolicySectionDataStorage => 'Data Storage';

  @override
  String get privacyPolicySectionDataTransmission =>
      'Data Transmission to Third Parties';

  @override
  String get privacyPolicySectionRequiredPermissions => 'Required Permissions';

  @override
  String get privacyPolicySectionSecurity => 'Security';

  @override
  String get privacyPolicySectionUserRights => 'User Rights';

  @override
  String get privacyPolicySectionDataRetention => 'Data Retention';

  @override
  String get privacyPolicySectionChildrenPrivacy => 'Children\'s Privacy';

  @override
  String get privacyPolicySectionChangesToPolicy => 'Changes to This Policy';

  @override
  String get privacyPolicySectionDataCollectionConsent =>
      'Data Collection Consent';

  @override
  String get privacyPolicySectionPDPACompliance =>
      'PDPA Compliance (Thailand Personal Data Protection Act)';

  @override
  String get privacyPolicySectionContactUs => 'Contact Us';

  @override
  String get privacyPolicyEffectiveDate =>
      'Effective Date: February 18, 2026\nLast Updated: February 18, 2026';

  @override
  String get termsOfServiceTitle => 'Terms of Service';

  @override
  String get termsSubtitle => 'MiRO — My Intake Record Oracle';

  @override
  String get termsSectionAcceptanceOfTerms => 'Acceptance of Terms';

  @override
  String get termsSectionServiceDescription => 'Service Description';

  @override
  String get termsSectionDisclaimerOfWarranties => 'Disclaimer of Warranties';

  @override
  String get termsSectionEnergySystemTerms => 'Energy System Terms';

  @override
  String get termsSectionUserDataAndResponsibilities =>
      'User Data and Responsibilities';

  @override
  String get termsSectionBackupTransfer => 'Backup & Transfer';

  @override
  String get termsSectionInAppPurchases => 'In-App Purchases';

  @override
  String get termsSectionProhibitedUses => 'Prohibited Uses';

  @override
  String get termsSectionIntellectualProperty => 'Intellectual Property';

  @override
  String get termsSectionLimitationOfLiability => 'Limitation of Liability';

  @override
  String get termsSectionServiceTermination => 'Service Termination';

  @override
  String get termsSectionChangesToTerms => 'Changes to Terms';

  @override
  String get termsSectionGoverningLaw => 'Governing Law';

  @override
  String get termsSectionContactUs => 'Contact Us';

  @override
  String get termsAcknowledgment =>
      'By using MiRO, you acknowledge that you have read, understood, and agree to these Terms of Service.';

  @override
  String get termsLastUpdated => 'Last updated: February 15, 2026';

  @override
  String get profileAndSettings => 'Profile & Settings';

  @override
  String errorOccurred(String error) {
    return 'Error: $error';
  }

  @override
  String get healthGoalsSection => 'Health Goals';

  @override
  String get dailyGoals => 'Daily Goals';

  @override
  String get chatAiModeSection => 'Chat AI Mode';

  @override
  String get selectAiPowersChat => 'Select which AI powers your chat';

  @override
  String get miroAi => 'Miro AI';

  @override
  String get miroAiSubtitle =>
      'Powered by Gemini • Multi-language • High accuracy';

  @override
  String get localAi => 'Local AI';

  @override
  String get localAiSubtitle => 'On-device • English only • Basic accuracy';

  @override
  String get free => 'Free';

  @override
  String get cuisinePreferenceSection => 'Cuisine Preference';

  @override
  String get preferredCuisine => 'Preferred Cuisine';

  @override
  String get selectYourCuisine => 'Select Your Cuisine';

  @override
  String get photoScanSection => 'Photo Scan';

  @override
  String get languageSection => 'Language';

  @override
  String get languageTitle => 'Language / ภาษา';

  @override
  String get selectLanguage => 'Select Language / เลือกภาษา';

  @override
  String get systemDefault => 'System Default';

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
    return 'Language changed to $language';
  }

  @override
  String get accountSection => 'Account';

  @override
  String get miroId => 'MiRO ID';

  @override
  String get miroIdCopied => 'MiRO ID copied!';

  @override
  String get inviteFriends => 'Invite Friends';

  @override
  String get inviteFriendsSubtitle =>
      'Share your referral code and earn rewards!';

  @override
  String get unlimitedAiDoubleRewards => 'Unlimited AI + Double rewards';

  @override
  String get plan => 'Plan';

  @override
  String get monthly => 'Monthly';

  @override
  String get started => 'Started';

  @override
  String get renews => 'Renews';

  @override
  String get expires => 'Expires';

  @override
  String get autoRenew => 'Auto-Renew';

  @override
  String get on => 'On';

  @override
  String get off => 'Off';

  @override
  String get tapToManageSubscription => 'Tap to manage subscription';

  @override
  String get dataSection => 'Data';

  @override
  String get backupData => 'Backup Data';

  @override
  String get backupDataSubtitle => 'Energy + Food History → save as file';

  @override
  String get restoreFromBackup => 'Restore from Backup';

  @override
  String get restoreFromBackupSubtitle => 'Import data from backup file';

  @override
  String get clearAllDataTitle => 'Clear all data?';

  @override
  String get clearAllDataContent =>
      'All data will be deleted:\n• Food entries\n• My Meals\n• Ingredients\n• Goals\n• Personal info\n\nThis cannot be undone!';

  @override
  String get allDataClearedSuccess => 'All data cleared successfully';

  @override
  String get aboutSection => 'About';

  @override
  String get version => 'Version';

  @override
  String get healthDisclaimer => 'Health Disclaimer';

  @override
  String get importantLegalInformation => 'Important legal information';

  @override
  String get showTutorialAgain => 'Show Tutorial Again';

  @override
  String get viewFeatureTour => 'View feature tour';

  @override
  String get showTutorialDialogTitle => 'Show Tutorial';

  @override
  String get showTutorialDialogContent =>
      'This will show the feature tour that highlights:\n\n• Energy System\n• Pull-to-Refresh Photo Scan\n• Chat with Miro AI\n\nYou will return to the Home screen.';

  @override
  String get showTutorialButton => 'Show Tutorial';

  @override
  String get tutorialResetMessage =>
      'Tutorial reset! Go to Home screen to view it.';

  @override
  String get foodAnalysisTutorial => 'Food Analysis Tutorial';

  @override
  String get foodAnalysisTutorialSubtitle =>
      'Learn how to use food analysis features';

  @override
  String get backupCreated => 'Backup Created!';

  @override
  String get backupCreatedContent =>
      'Your backup file has been created successfully.';

  @override
  String get backupChooseDestination =>
      'Where would you like to save your backup?';

  @override
  String get backupSaveToDevice => 'Save to Device';

  @override
  String get backupSaveToDeviceDesc =>
      'Save to a folder you choose on this device';

  @override
  String get backupShareToOther => 'Share to Other Device';

  @override
  String get backupShareToOtherDesc =>
      'Send via Line, Email, Google Drive, etc.';

  @override
  String get backupSavedSuccess => 'Backup Saved!';

  @override
  String get backupSavedSuccessContent =>
      'Your backup file has been saved to your chosen location.';

  @override
  String get important => 'Important:';

  @override
  String get backupImportantNotes =>
      '• Save this file in a safe place (Google Drive, etc.)\n• Photos are NOT included in the backup\n• Transfer Key expires in 30 days\n• Key can only be used once';

  @override
  String get restoreBackup => 'Restore Backup?';

  @override
  String get backupFrom => 'Backup from:';

  @override
  String get date => 'Date:';

  @override
  String get energy => 'Energy:';

  @override
  String get foodEntries => 'Food entries:';

  @override
  String get restoreImportant => 'Important';

  @override
  String restoreImportantNotes(String energy) {
    return '• Current Energy on this device will be REPLACED with Energy from backup ($energy)\n• Food entries will be MERGED (not replaced)\n• Photos are NOT included in backup\n• Transfer Key will be used (cannot be reused)';
  }

  @override
  String get restore => 'Restore';

  @override
  String get restoreComplete => 'Restore Complete!';

  @override
  String get restoreCompleteContent =>
      'Your data has been restored successfully.';

  @override
  String get newEnergyBalance => 'New Energy Balance:';

  @override
  String get foodEntriesImported => 'Food Entries Imported:';

  @override
  String get myMealsImported => 'My Meals Imported:';

  @override
  String get appWillRefresh =>
      'Your app will refresh to show the restored data.';

  @override
  String get backupFailed => 'Backup Failed';

  @override
  String get invalidBackupFile => 'Invalid Backup File';

  @override
  String get restoreFailed => 'Restore Failed';

  @override
  String get analyticsDataCollection => 'Analytics Data Collection';

  @override
  String get analyticsEnabled => 'Analytics enabled - ขอบคุณที่ช่วยปรับปรุงแอป';

  @override
  String get analyticsDisabled => 'Analytics disabled - ไม่เก็บข้อมูลการใช้งาน';

  @override
  String get enabled => 'Enabled';

  @override
  String get enabledSubtitle => 'Enabled - ช่วยปรับปรุงประสบการณ์ใช้งาน';

  @override
  String get disabled => 'Disabled';

  @override
  String get disabledSubtitle => 'Disabled - ไม่เก็บข้อมูลการใช้งาน';

  @override
  String get imagesPerDay => 'Images per day';

  @override
  String scanUpToImagesPerDay(String limit) {
    return 'Scan up to $limit images per day';
  }

  @override
  String get reset => 'Reset';

  @override
  String get resetScanHistory => 'Reset Scan History';

  @override
  String get resetScanHistorySubtitle =>
      'Delete all scanned entries and re-scan';

  @override
  String get imagesPerDayDialog => 'Images per day';

  @override
  String get maxImagesPerDayDescription =>
      'Maximum images to scan per day\nScans only the selected date';

  @override
  String scanLimitSetTo(String limit) {
    return 'Scan limit set to $limit images per day';
  }

  @override
  String get resetScanHistoryDialog => 'Reset Scan History?';

  @override
  String get resetScanHistoryContent =>
      'All gallery-scanned food entries will be deleted.\nPull down on any date to re-scan images.';

  @override
  String resetComplete(String count) {
    return 'Reset complete - $count entries deleted. Pull down to re-scan.';
  }

  @override
  String questBarStreak(int days) {
    return 'Streak $days day';
  }

  @override
  String questBarDaysToNextTier(int days, String tier) {
    return '$days days → $tier';
  }

  @override
  String get questBarMaxTier => 'Max Tier! 💎';

  @override
  String get questBarOfferDismissed => 'Offer hidden';

  @override
  String get questBarViewOffer => 'View Offer';

  @override
  String get questBarNoOffersNow => '• No offers right now';

  @override
  String get questBarWeeklyChallenges => '🎯 Weekly Challenges';

  @override
  String get questBarMilestones => '🏆 Milestones';

  @override
  String get questBarInviteFriends => '👥 Invite friends & get 20E';

  @override
  String questBarTimeRemaining(String time) {
    return '⏰ Time left $time';
  }

  @override
  String questBarClaimDailyEnergy(int energy) {
    return '+${energy}E';
  }

  @override
  String questBarShareReferralError(String error) {
    return 'Error sharing: $error';
  }

  @override
  String tierCelebrationTitle(String tier) {
    return '$tier Celebration 🎉';
  }

  @override
  String tierCelebrationDay(int day) {
    return 'Day $day';
  }

  @override
  String get tierCelebrationExpired => 'Expired';

  @override
  String get tierCelebrationComplete => 'Complete!';

  @override
  String questBarWatchAd(int energy) {
    return 'Watch Ad +$energy⚡';
  }

  @override
  String questBarAdRemaining(int remaining, int total) {
    return '$remaining/$total remaining today';
  }

  @override
  String questBarAdSuccess(int energy) {
    return 'Ad watched! +$energy Energy incoming...';
  }

  @override
  String get questBarAdNotReady => 'Ad not ready, please try again';

  @override
  String get questBarDailyChallenge => 'Daily Challenge';

  @override
  String get questBarUseAi => 'Use Energy';

  @override
  String get questBarResetsMonday => 'Resets every Monday';

  @override
  String get questBarClaimed => 'Claimed!';

  @override
  String get questBarHideOffer => 'Hide';

  @override
  String get questBarViewDetails => 'View';

  @override
  String questBarShareText(String link) {
    return 'Try MiRO! AI-powered food analysis 🍔\nUse this link and we both get +20 Energy free!\n\n$link';
  }

  @override
  String get questBarShareSubject => 'Try MiRO';

  @override
  String get claimButtonTitle => 'Claim Daily Energy';

  @override
  String claimButtonReceived(String energy) {
    return 'Received +${energy}E!';
  }

  @override
  String get claimButtonAlreadyClaimed => 'Already claimed today';

  @override
  String claimButtonError(String error) {
    return 'Error: $error';
  }

  @override
  String get seasonalQuestLimitedTime => 'LIMITED TIME';

  @override
  String seasonalQuestDaysLeft(int days) {
    return '$days days left';
  }

  @override
  String seasonalQuestRewardDaily(int reward) {
    return '+${reward}E / day';
  }

  @override
  String seasonalQuestRewardOnce(int reward) {
    return '+${reward}E one-time';
  }

  @override
  String get seasonalQuestClaimed => 'Claimed!';

  @override
  String get seasonalQuestClaimedToday => 'Claimed today';

  @override
  String get errorFailed => 'Failed';

  @override
  String get errorFailedToClaim => 'Failed to claim';

  @override
  String errorGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String get milestoneNoMilestonesToClaim => 'No milestones to claim yet';

  @override
  String milestoneClaimedEnergy(int energy) {
    return '🎁 Claimed +$energy Energy!';
  }

  @override
  String get milestoneTitle => 'Milestones';

  @override
  String milestoneUseEnergyComplete(int threshold) {
    return 'Use Energy $threshold';
  }

  @override
  String milestoneNext(int threshold) {
    return 'Next: ${threshold}E';
  }

  @override
  String get milestoneAllComplete => 'All milestones completed!';

  @override
  String get noEnergyTitle => 'Out of Energy';

  @override
  String get noEnergyContent => 'You need 1 Energy to analyze food with AI';

  @override
  String get noEnergyTip =>
      'You can still log food manually (without AI) for free';

  @override
  String get noEnergyLater => 'Later';

  @override
  String noEnergyWatchAd(int remaining) {
    return 'Watch Ad ($remaining/3)';
  }

  @override
  String get noEnergyBuyEnergy => 'Buy Energy';

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
  String get tierUpCongratulations => '🎉 Congratulations!';

  @override
  String tierUpYouReached(String tier) {
    return 'You reached $tier!';
  }

  @override
  String get tierUpMotivation =>
      'Track calories like a pro\nYour dream body is getting closer!';

  @override
  String tierUpReward(int reward) {
    return '+${reward}E Reward!';
  }

  @override
  String get referralAllLevelsClaimed => 'All levels claimed!';

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
    return '🎁 Claimed Level $level: +$reward Energy!';
  }

  @override
  String get challengeUseAi10 => 'Use Energy 10';

  @override
  String get specifyIngredients => 'Specify Known Ingredients';

  @override
  String get specifyIngredientsOptional =>
      'Specify known ingredients (optional)';

  @override
  String get specifyIngredientsHint =>
      'Enter the ingredients you know, and AI will discover hidden seasonings, oils, and sauces for you.';

  @override
  String get sendToAi => 'Send to AI';

  @override
  String get reanalyzeWithIngredients => 'Add Ingredients & Re-analyze';

  @override
  String get reanalyzeButton => 'Re-analyze (1 Energy)';

  @override
  String get ingredientsSaved => 'Ingredients saved';

  @override
  String get pleaseAddAtLeastOneIngredient =>
      'Please add at least 1 ingredient';

  @override
  String get hiddenIngredientsDiscovered =>
      'Hidden ingredients discovered by AI';

  @override
  String get retroScanTitle => 'Scan Recent Photos?';

  @override
  String get retroScanDescription =>
      'We can scan your photos from the last 7 days to automatically find food photos and add them to your diary.';

  @override
  String get retroScanNote =>
      'Only food photos are detected — other photos are ignored. No photos leave your device.';

  @override
  String get retroScanStart => 'Scan My Photos';

  @override
  String get retroScanSkip => 'Skip for now';

  @override
  String get retroScanInProgress => 'Scanning...';

  @override
  String get retroScanTagline =>
      'MiRO is transforming your\nfood photos into health data.';

  @override
  String get retroScanFetchingPhotos => 'Fetching recent photos...';

  @override
  String get retroScanAnalyzing => 'Detecting food photos...';

  @override
  String retroScanPhotosFound(int count) {
    return '$count photos found in last 7 days';
  }

  @override
  String get retroScanCompleteTitle => 'Scan Complete!';

  @override
  String retroScanCompleteDesc(int count) {
    return 'Found $count food photos! They\'ve been added to your timeline, ready for AI analysis.';
  }

  @override
  String get retroScanNoResultsTitle => 'No Food Photos Found';

  @override
  String get retroScanNoResultsDesc =>
      'No food photos detected in the last 7 days. Try taking a photo of your next meal!';

  @override
  String get retroScanAnalyzeHint =>
      'Tap \"Analyze All\" on your timeline to get AI nutrition analysis for these entries.';

  @override
  String get retroScanDone => 'Got it!';

  @override
  String get welcomeEndTitle => 'Welcome to MiRO!';

  @override
  String get welcomeEndMessage => 'MiRO is at your service.';

  @override
  String get welcomeEndJourney => 'Have a nice journey together!!';

  @override
  String get welcomeEndStart => 'Let\'s Start!';

  @override
  String greetingCalorieSummary(
      int remaining, int protein, int carbs, int fat) {
    return 'Hi! How can I help you today? You still have $remaining kcal left. So far: Protein ${protein}g, Carbs ${carbs}g, Fat ${fat}g. Tell me what you ate — list everything by meal and I\'ll log them all for you. More Detail more precise!!';
  }

  @override
  String greetingCuisineTip(String cuisine) {
    return 'Your preferred cuisine is set to $cuisine. You can change it in Settings anytime!';
  }

  @override
  String greetingEnergyTip(int balance) {
    return 'You have $balance Energy available. Don\'t forget to claim your daily streak reward on the Energy badge!';
  }

  @override
  String get greetingRenamePhotoTip =>
      'Tip: You can rename food photos to help MiRO analyze more accurately!';

  @override
  String get greetingAddIngredientsTip =>
      'Tip: You can add ingredients you\'re sure about before sending to MiRO for analysis. I\'ll figure out all the boring little details for you!';

  @override
  String greetingBackupReminder(int days) {
    return 'Hey boss! You haven\'t backed up your data for $days days. I recommend backing up in Settings — your data is stored locally and I can\'t recover it if something happens!';
  }

  @override
  String get greetingFallback =>
      'Hi! How can I help you today? Tell me what you ate!';

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
      'List is too long. Could you split it into 2-3 items? 🙏\n\nYour Energy has not been deducted.';

  @override
  String get analyzeFoodImageTitle => 'Analyze Food Image';

  @override
  String get foodNameImprovesAccuracy =>
      'Providing food name & quantity improves AI accuracy.';

  @override
  String get foodNameQuantityAndModeImprovesAccuracy =>
      'Providing food name, quantity, and choosing if it\'s food or product will improve AI accuracy.';

  @override
  String get hideDetails => 'Hide details';

  @override
  String get showDetails => 'Show details';

  @override
  String get searchModeLabel => 'Search Mode';

  @override
  String get normalFood => 'Food';

  @override
  String get normalFoodDesc => 'Regular home-cooked food';

  @override
  String get packagedProduct => 'Product';

  @override
  String get packagedProductDesc => 'Packaged with nutrition label';

  @override
  String get saveAndAnalyzeButton => 'Save & Analyze';

  @override
  String get saveWithoutAnalysis => 'Save without analysis';

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
}
