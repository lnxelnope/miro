import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_th.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

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
    Locale('th'),
    Locale('vi'),
    Locale('id'),
    Locale('zh'),
    Locale('ja'),
    Locale('ko'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
    Locale('pt'),
    Locale('hi')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'MiRO'**
  String get appName;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get error;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @foodName.
  ///
  /// In en, this message translates to:
  /// **'Food name'**
  String get foodName;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// No description provided for @carbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get carbs;

  /// No description provided for @fat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fat;

  /// No description provided for @servingSize.
  ///
  /// In en, this message translates to:
  /// **'Serving size'**
  String get servingSize;

  /// No description provided for @servingUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get servingUnit;

  /// No description provided for @kcal.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get kcal;

  /// No description provided for @mealBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get mealBreakfast;

  /// No description provided for @mealLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get mealLunch;

  /// No description provided for @mealDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get mealDinner;

  /// No description provided for @mealSnack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get mealSnack;

  /// No description provided for @todaySummary.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Summary'**
  String get todaySummary;

  /// No description provided for @nutritionSummary.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Summary'**
  String get nutritionSummary;

  /// No description provided for @dateSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary for {date}'**
  String dateSummary(String date);

  /// No description provided for @periodAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get periodAll;

  /// No description provided for @macroDistribution.
  ///
  /// In en, this message translates to:
  /// **'Macro Distribution'**
  String get macroDistribution;

  /// No description provided for @calorieTrend.
  ///
  /// In en, this message translates to:
  /// **'Calorie Trend'**
  String get calorieTrend;

  /// No description provided for @calorieTrend7Days.
  ///
  /// In en, this message translates to:
  /// **'Calorie Trend (7 days)'**
  String get calorieTrend7Days;

  /// No description provided for @micronutrientTracker.
  ///
  /// In en, this message translates to:
  /// **'Micronutrient Tracker'**
  String get micronutrientTracker;

  /// No description provided for @fatBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Fat Breakdown'**
  String get fatBreakdown;

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @over.
  ///
  /// In en, this message translates to:
  /// **'OVER'**
  String get over;

  /// No description provided for @saturated.
  ///
  /// In en, this message translates to:
  /// **'Saturated'**
  String get saturated;

  /// No description provided for @mono.
  ///
  /// In en, this message translates to:
  /// **'Mono'**
  String get mono;

  /// No description provided for @poly.
  ///
  /// In en, this message translates to:
  /// **'Poly'**
  String get poly;

  /// No description provided for @trans.
  ///
  /// In en, this message translates to:
  /// **'Trans'**
  String get trans;

  /// No description provided for @noDataFor.
  ///
  /// In en, this message translates to:
  /// **'No data for {title}'**
  String noDataFor(String title);

  /// No description provided for @errorColon.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorColon(String error);

  /// No description provided for @savedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully'**
  String get savedSuccess;

  /// No description provided for @deletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully'**
  String get deletedSuccess;

  /// No description provided for @pleaseEnterFoodName.
  ///
  /// In en, this message translates to:
  /// **'Please enter food name'**
  String get pleaseEnterFoodName;

  /// No description provided for @noDataYet.
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get noDataYet;

  /// No description provided for @addFood.
  ///
  /// In en, this message translates to:
  /// **'Add food'**
  String get addFood;

  /// No description provided for @editFood.
  ///
  /// In en, this message translates to:
  /// **'Edit food'**
  String get editFood;

  /// No description provided for @deleteFood.
  ///
  /// In en, this message translates to:
  /// **'Delete food'**
  String get deleteFood;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm delete?'**
  String get deleteConfirm;

  /// No description provided for @foodLoggedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Food logged!'**
  String get foodLoggedSuccess;

  /// No description provided for @noApiKey.
  ///
  /// In en, this message translates to:
  /// **'Please set up Gemini API Key'**
  String get noApiKey;

  /// No description provided for @noApiKeyDescription.
  ///
  /// In en, this message translates to:
  /// **'Go to Profile → API Settings to set up'**
  String get noApiKeyDescription;

  /// No description provided for @apiKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up Gemini API Key'**
  String get apiKeyTitle;

  /// No description provided for @apiKeyRequired.
  ///
  /// In en, this message translates to:
  /// **'API Key required'**
  String get apiKeyRequired;

  /// No description provided for @apiKeyFreeNote.
  ///
  /// In en, this message translates to:
  /// **'Gemini API is free to use'**
  String get apiKeyFreeNote;

  /// No description provided for @apiKeySetup.
  ///
  /// In en, this message translates to:
  /// **'Set up API Key'**
  String get apiKeySetup;

  /// No description provided for @testConnection.
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get testConnection;

  /// No description provided for @connectionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Connected successfully! Ready to use'**
  String get connectionSuccess;

  /// No description provided for @connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed'**
  String get connectionFailed;

  /// No description provided for @pasteKey.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get pasteKey;

  /// No description provided for @deleteKey.
  ///
  /// In en, this message translates to:
  /// **'Delete API Key'**
  String get deleteKey;

  /// No description provided for @openAiStudio.
  ///
  /// In en, this message translates to:
  /// **'Open Google AI Studio'**
  String get openAiStudio;

  /// No description provided for @chatHint.
  ///
  /// In en, this message translates to:
  /// **'Tell Miro e.g. \"Log fried rice\"...'**
  String get chatHint;

  /// No description provided for @chatFoodSaved.
  ///
  /// In en, this message translates to:
  /// **'Food logged!'**
  String get chatFoodSaved;

  /// No description provided for @chatFoodSavedDetail.
  ///
  /// In en, this message translates to:
  /// **'{name} {serving} {unit}\n{cal} kcal'**
  String chatFoodSavedDetail(
      String name, String serving, String unit, String cal);

  /// No description provided for @featureNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Sorry, this feature is not available yet'**
  String get featureNotAvailable;

  /// No description provided for @goalCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories/day'**
  String get goalCalories;

  /// No description provided for @goalProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein/day'**
  String get goalProtein;

  /// No description provided for @goalCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs/day'**
  String get goalCarbs;

  /// No description provided for @goalFat.
  ///
  /// In en, this message translates to:
  /// **'Fat/day'**
  String get goalFat;

  /// No description provided for @goalWater.
  ///
  /// In en, this message translates to:
  /// **'Water/day'**
  String get goalWater;

  /// No description provided for @healthGoals.
  ///
  /// In en, this message translates to:
  /// **'Health Goals'**
  String get healthGoals;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @clearAllData.
  ///
  /// In en, this message translates to:
  /// **'Clear all data'**
  String get clearAllData;

  /// No description provided for @clearAllDataConfirm.
  ///
  /// In en, this message translates to:
  /// **'All data will be deleted. This cannot be undone!'**
  String get clearAllDataConfirm;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @upgradePro.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get upgradePro;

  /// No description provided for @proUnlocked.
  ///
  /// In en, this message translates to:
  /// **'MiRO Pro'**
  String get proUnlocked;

  /// No description provided for @proDescription.
  ///
  /// In en, this message translates to:
  /// **'Unlimited AI food analysis'**
  String get proDescription;

  /// No description provided for @aiRemaining.
  ///
  /// In en, this message translates to:
  /// **'AI analysis: {remaining}/{total} remaining today'**
  String aiRemaining(int remaining, int total);

  /// No description provided for @aiLimitReached.
  ///
  /// In en, this message translates to:
  /// **'AI limit reached for today (3/3)'**
  String get aiLimitReached;

  /// No description provided for @restorePurchase.
  ///
  /// In en, this message translates to:
  /// **'Restore purchase'**
  String get restorePurchase;

  /// No description provided for @myMeals.
  ///
  /// In en, this message translates to:
  /// **'My Meals:'**
  String get myMeals;

  /// No description provided for @createMeal.
  ///
  /// In en, this message translates to:
  /// **'Create Meal'**
  String get createMeal;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @searchFood.
  ///
  /// In en, this message translates to:
  /// **'Search food'**
  String get searchFood;

  /// No description provided for @analyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get analyzing;

  /// No description provided for @analyzeWithAi.
  ///
  /// In en, this message translates to:
  /// **'Analyze with AI'**
  String get analyzeWithAi;

  /// No description provided for @analysisComplete.
  ///
  /// In en, this message translates to:
  /// **'Analysis complete'**
  String get analysisComplete;

  /// No description provided for @timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// No description provided for @diet.
  ///
  /// In en, this message translates to:
  /// **'Diet'**
  String get diet;

  /// No description provided for @quickAdd.
  ///
  /// In en, this message translates to:
  /// **'Quick Add'**
  String get quickAdd;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'MiRO'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Easy food logging with AI'**
  String get welcomeSubtitle;

  /// No description provided for @onboardingFeature1.
  ///
  /// In en, this message translates to:
  /// **'Snap a photo'**
  String get onboardingFeature1;

  /// No description provided for @onboardingFeature1Desc.
  ///
  /// In en, this message translates to:
  /// **'AI calculates calories automatically'**
  String get onboardingFeature1Desc;

  /// No description provided for @onboardingFeature2.
  ///
  /// In en, this message translates to:
  /// **'Type to log'**
  String get onboardingFeature2;

  /// No description provided for @onboardingFeature2Desc.
  ///
  /// In en, this message translates to:
  /// **'Say \"had fried rice\" and it\'s logged'**
  String get onboardingFeature2Desc;

  /// No description provided for @onboardingFeature3.
  ///
  /// In en, this message translates to:
  /// **'Daily summary'**
  String get onboardingFeature3;

  /// No description provided for @onboardingFeature3Desc.
  ///
  /// In en, this message translates to:
  /// **'Track kcal, protein, carbs, fat'**
  String get onboardingFeature3Desc;

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get basicInfo;

  /// No description provided for @basicInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'To calculate your recommended daily calories'**
  String get basicInfoDesc;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @activityLevel.
  ///
  /// In en, this message translates to:
  /// **'Activity Level'**
  String get activityLevel;

  /// No description provided for @tdeeResult.
  ///
  /// In en, this message translates to:
  /// **'Your TDEE: {kcal} kcal/day'**
  String tdeeResult(int kcal);

  /// No description provided for @setupAiTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up Gemini AI'**
  String get setupAiTitle;

  /// No description provided for @setupAiDesc.
  ///
  /// In en, this message translates to:
  /// **'Snap a photo and AI analyzes it automatically'**
  String get setupAiDesc;

  /// No description provided for @setupNow.
  ///
  /// In en, this message translates to:
  /// **'Set up now'**
  String get setupNow;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timeout — please try again'**
  String get errorTimeout;

  /// No description provided for @errorInvalidKey.
  ///
  /// In en, this message translates to:
  /// **'Invalid API Key — check your settings'**
  String get errorInvalidKey;

  /// No description provided for @errorNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get errorNoInternet;

  /// No description provided for @errorGeneral.
  ///
  /// In en, this message translates to:
  /// **'An error occurred — please try again'**
  String get errorGeneral;

  /// No description provided for @errorQuotaExceeded.
  ///
  /// In en, this message translates to:
  /// **'API quota exceeded — please wait and retry'**
  String get errorQuotaExceeded;

  /// No description provided for @apiKeyScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up Gemini API Key'**
  String get apiKeyScreenTitle;

  /// No description provided for @analyzeFoodWithAi.
  ///
  /// In en, this message translates to:
  /// **'Analyze food with AI'**
  String get analyzeFoodWithAi;

  /// No description provided for @analyzeFoodWithAiDesc.
  ///
  /// In en, this message translates to:
  /// **'Snap a photo → AI calculates calories automatically\nGemini API is free to use!'**
  String get analyzeFoodWithAiDesc;

  /// No description provided for @openGoogleAiStudio.
  ///
  /// In en, this message translates to:
  /// **'Open Google AI Studio'**
  String get openGoogleAiStudio;

  /// No description provided for @step1Title.
  ///
  /// In en, this message translates to:
  /// **'Open Google AI Studio'**
  String get step1Title;

  /// No description provided for @step1Desc.
  ///
  /// In en, this message translates to:
  /// **'Click the button below to create an API Key'**
  String get step1Desc;

  /// No description provided for @step2Title.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google Account'**
  String get step2Title;

  /// No description provided for @step2Desc.
  ///
  /// In en, this message translates to:
  /// **'Use your Gmail or Google Account (create one for free if you don\'t have one)'**
  String get step2Desc;

  /// No description provided for @step3Title.
  ///
  /// In en, this message translates to:
  /// **'Click \"Create API Key\"'**
  String get step3Title;

  /// No description provided for @step3Desc.
  ///
  /// In en, this message translates to:
  /// **'Click the blue \"Create API Key\" button\nIf asked to select a Project → Click \"Create API key in new project\"'**
  String get step3Desc;

  /// No description provided for @step4Title.
  ///
  /// In en, this message translates to:
  /// **'Copy Key and paste below'**
  String get step4Title;

  /// No description provided for @step4Desc.
  ///
  /// In en, this message translates to:
  /// **'Click Copy next to the created Key\nKey will look like: AIzaSyxxxx...'**
  String get step4Desc;

  /// No description provided for @step5Title.
  ///
  /// In en, this message translates to:
  /// **'Paste API Key here'**
  String get step5Title;

  /// No description provided for @pasteApiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Paste the copied API Key'**
  String get pasteApiKeyHint;

  /// No description provided for @saveApiKey.
  ///
  /// In en, this message translates to:
  /// **'Save API Key'**
  String get saveApiKey;

  /// No description provided for @testingConnection.
  ///
  /// In en, this message translates to:
  /// **'Testing...'**
  String get testingConnection;

  /// No description provided for @deleteApiKey.
  ///
  /// In en, this message translates to:
  /// **'Delete API Key'**
  String get deleteApiKey;

  /// No description provided for @deleteApiKeyConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete API Key?'**
  String get deleteApiKeyConfirm;

  /// No description provided for @deleteApiKeyConfirmDesc.
  ///
  /// In en, this message translates to:
  /// **'You won\'t be able to use AI food analysis until you set it up again'**
  String get deleteApiKeyConfirmDesc;

  /// No description provided for @apiKeySaved.
  ///
  /// In en, this message translates to:
  /// **'API Key saved successfully'**
  String get apiKeySaved;

  /// No description provided for @apiKeyDeleted.
  ///
  /// In en, this message translates to:
  /// **'API Key deleted successfully'**
  String get apiKeyDeleted;

  /// No description provided for @pleasePasteApiKey.
  ///
  /// In en, this message translates to:
  /// **'Please paste API Key first'**
  String get pleasePasteApiKey;

  /// No description provided for @apiKeyInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid API Key — must start with \"AIza\"'**
  String get apiKeyInvalidFormat;

  /// No description provided for @connectionSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'✅ Connected successfully! Ready to use'**
  String get connectionSuccessMessage;

  /// No description provided for @connectionFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'❌ Connection failed'**
  String get connectionFailedMessage;

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get faqTitle;

  /// No description provided for @faqFreeQuestion.
  ///
  /// In en, this message translates to:
  /// **'Is it really free?'**
  String get faqFreeQuestion;

  /// No description provided for @faqFreeAnswer.
  ///
  /// In en, this message translates to:
  /// **'Yes! Gemini 2.0 Flash is free for 1,500 requests/day\nFor food logging (5-15 times/day) → Free forever, no payment required'**
  String get faqFreeAnswer;

  /// No description provided for @faqSafeQuestion.
  ///
  /// In en, this message translates to:
  /// **'Is it safe?'**
  String get faqSafeQuestion;

  /// No description provided for @faqSafeAnswer.
  ///
  /// In en, this message translates to:
  /// **'API Key is stored in Secure Storage on your device only\nApp doesn\'t send Key to our server\nIf Key leaks → Delete and create a new one (it\'s not your Google password)'**
  String get faqSafeAnswer;

  /// No description provided for @faqNoKeyQuestion.
  ///
  /// In en, this message translates to:
  /// **'What if I don\'t create a Key?'**
  String get faqNoKeyQuestion;

  /// No description provided for @faqNoKeyAnswer.
  ///
  /// In en, this message translates to:
  /// **'You can still use the app! But:\n❌ Cannot take photo → AI analysis\n✅ Can log food manually\n✅ Quick Add works\n✅ View kcal/macro summary works'**
  String get faqNoKeyAnswer;

  /// No description provided for @faqCreditCardQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do I need a credit card?'**
  String get faqCreditCardQuestion;

  /// No description provided for @faqCreditCardAnswer.
  ///
  /// In en, this message translates to:
  /// **'No — Create API Key for free without credit card'**
  String get faqCreditCardAnswer;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navMyMeals.
  ///
  /// In en, this message translates to:
  /// **'My Meals'**
  String get navMyMeals;

  /// No description provided for @navCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get navCamera;

  /// No description provided for @navGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get navGallery;

  /// No description provided for @navAiChat.
  ///
  /// In en, this message translates to:
  /// **'AI Chat'**
  String get navAiChat;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @appBarTodayIntake.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Intake'**
  String get appBarTodayIntake;

  /// No description provided for @appBarMyMeals.
  ///
  /// In en, this message translates to:
  /// **'My Meals'**
  String get appBarMyMeals;

  /// No description provided for @appBarCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get appBarCamera;

  /// No description provided for @appBarAiChat.
  ///
  /// In en, this message translates to:
  /// **'AI Chat'**
  String get appBarAiChat;

  /// No description provided for @appBarMiro.
  ///
  /// In en, this message translates to:
  /// **'MIRO'**
  String get appBarMiro;

  /// No description provided for @permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get permissionRequired;

  /// No description provided for @permissionRequiredDesc.
  ///
  /// In en, this message translates to:
  /// **'MIRO needs access to the following:'**
  String get permissionRequiredDesc;

  /// No description provided for @permissionPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos — to scan food'**
  String get permissionPhotos;

  /// No description provided for @permissionCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera — to photograph food'**
  String get permissionCamera;

  /// No description provided for @permissionSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get permissionSkip;

  /// No description provided for @permissionAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get permissionAllow;

  /// No description provided for @permissionAllGranted.
  ///
  /// In en, this message translates to:
  /// **'All permissions granted'**
  String get permissionAllGranted;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied: {denied}'**
  String permissionDenied(String denied);

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @exitAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit App?'**
  String get exitAppTitle;

  /// No description provided for @exitAppMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit?'**
  String get exitAppMessage;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  /// No description provided for @healthGoalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Health Goals'**
  String get healthGoalsTitle;

  /// No description provided for @healthGoalsInfo.
  ///
  /// In en, this message translates to:
  /// **'Set your daily calorie goal, macros, and per-meal budgets.\nLock to auto-calculate: 2 macros or 3 meals.'**
  String get healthGoalsInfo;

  /// No description provided for @dailyCalorieGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Calorie Goal'**
  String get dailyCalorieGoal;

  /// No description provided for @proteinLabel.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get proteinLabel;

  /// No description provided for @carbsLabel.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get carbsLabel;

  /// No description provided for @fatLabel.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fatLabel;

  /// No description provided for @autoBadge.
  ///
  /// In en, this message translates to:
  /// **'auto'**
  String get autoBadge;

  /// No description provided for @kcalPerGram.
  ///
  /// In en, this message translates to:
  /// **'{kcalPerGram} kcal/g • {kcal} kcal'**
  String kcalPerGram(int kcalPerGram, int kcal);

  /// No description provided for @mealCalorieBudget.
  ///
  /// In en, this message translates to:
  /// **'Meal Calorie Budget'**
  String get mealCalorieBudget;

  /// No description provided for @mealBudgetBalanced.
  ///
  /// In en, this message translates to:
  /// **'Total {total} kcal = Goal {goal} kcal'**
  String mealBudgetBalanced(int total, int goal);

  /// No description provided for @mealBudgetRemaining.
  ///
  /// In en, this message translates to:
  /// **'Total {total} / {goal} kcal  ({remaining} remaining)'**
  String mealBudgetRemaining(int total, int goal, int remaining);

  /// No description provided for @lockMealsHint.
  ///
  /// In en, this message translates to:
  /// **'Lock 3 meals to auto-calculate the 4th'**
  String get lockMealsHint;

  /// No description provided for @breakfastLabel.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfastLabel;

  /// No description provided for @lunchLabel.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunchLabel;

  /// No description provided for @dinnerLabel.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinnerLabel;

  /// No description provided for @snackLabel.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get snackLabel;

  /// No description provided for @percentOfDailyGoal.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of daily goal'**
  String percentOfDailyGoal(String percent);

  /// No description provided for @smartSuggestionRange.
  ///
  /// In en, this message translates to:
  /// **'Smart Suggestion Range'**
  String get smartSuggestionRange;

  /// No description provided for @smartSuggestionHow.
  ///
  /// In en, this message translates to:
  /// **'How does Smart Suggestion work?'**
  String get smartSuggestionHow;

  /// No description provided for @smartSuggestionDesc.
  ///
  /// In en, this message translates to:
  /// **'We suggest foods from your My Meals, ingredients, and yesterday\'s meals that fit your per-meal budget.\n\nThis threshold controls how flexible the suggestions are. For example, if your lunch budget is 700 kcal and threshold is {threshold} kcal, we\'ll suggest foods between {min}–{max} kcal.'**
  String smartSuggestionDesc(int threshold, int min, int max);

  /// No description provided for @suggestionThreshold.
  ///
  /// In en, this message translates to:
  /// **'Suggestion Threshold'**
  String get suggestionThreshold;

  /// No description provided for @suggestionThresholdDesc.
  ///
  /// In en, this message translates to:
  /// **'Allow foods ± {threshold} kcal from meal budget'**
  String suggestionThresholdDesc(int threshold);

  /// No description provided for @goalsSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Goals saved successfully!'**
  String get goalsSavedSuccess;

  /// No description provided for @canOnlyLockTwoMacros.
  ///
  /// In en, this message translates to:
  /// **'Can only lock 2 macros at once'**
  String get canOnlyLockTwoMacros;

  /// No description provided for @canOnlyLockThreeMeals.
  ///
  /// In en, this message translates to:
  /// **'Can only lock 3 meals; the 4th auto-calculates'**
  String get canOnlyLockThreeMeals;

  /// No description provided for @tabMeals.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get tabMeals;

  /// No description provided for @tabIngredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get tabIngredients;

  /// No description provided for @searchMealsOrIngredients.
  ///
  /// In en, this message translates to:
  /// **'Search meals or ingredients...'**
  String get searchMealsOrIngredients;

  /// No description provided for @createNewMeal.
  ///
  /// In en, this message translates to:
  /// **'Create New Meal'**
  String get createNewMeal;

  /// No description provided for @addIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add Ingredient'**
  String get addIngredient;

  /// No description provided for @noMealsYet.
  ///
  /// In en, this message translates to:
  /// **'No meals yet'**
  String get noMealsYet;

  /// No description provided for @noMealsYetDesc.
  ///
  /// In en, this message translates to:
  /// **'Analyze food with AI to auto-save meals\nor create one manually'**
  String get noMealsYetDesc;

  /// No description provided for @noIngredientsYet.
  ///
  /// In en, this message translates to:
  /// **'No ingredients yet'**
  String get noIngredientsYet;

  /// No description provided for @noIngredientsYetDesc.
  ///
  /// In en, this message translates to:
  /// **'When you analyze food with AI\ningredients will be saved automatically'**
  String get noIngredientsYetDesc;

  /// No description provided for @mealCreated.
  ///
  /// In en, this message translates to:
  /// **'Created \"{name}\"'**
  String mealCreated(String name);

  /// No description provided for @mealLogged.
  ///
  /// In en, this message translates to:
  /// **'Logged \"{name}\"'**
  String mealLogged(String name);

  /// No description provided for @ingredientAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount ({unit})'**
  String ingredientAmount(String unit);

  /// No description provided for @ingredientLogged.
  ///
  /// In en, this message translates to:
  /// **'Logged \"{name}\" {amount}{unit}'**
  String ingredientLogged(String name, String amount, String unit);

  /// No description provided for @mealNotFound.
  ///
  /// In en, this message translates to:
  /// **'Meal not found'**
  String get mealNotFound;

  /// No description provided for @mealUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated \"{name}\"'**
  String mealUpdated(String name);

  /// No description provided for @deleteMealTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Meal?'**
  String get deleteMealTitle;

  /// No description provided for @deleteMealMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\"'**
  String deleteMealMessage(String name);

  /// No description provided for @deleteMealNote.
  ///
  /// In en, this message translates to:
  /// **'Ingredients will not be deleted.'**
  String get deleteMealNote;

  /// No description provided for @mealDeleted.
  ///
  /// In en, this message translates to:
  /// **'Meal deleted'**
  String get mealDeleted;

  /// No description provided for @ingredientCreated.
  ///
  /// In en, this message translates to:
  /// **'Created \"{name}\"'**
  String ingredientCreated(String name);

  /// No description provided for @ingredientNotFound.
  ///
  /// In en, this message translates to:
  /// **'Ingredient not found'**
  String get ingredientNotFound;

  /// No description provided for @ingredientUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated \"{name}\"'**
  String ingredientUpdated(String name);

  /// No description provided for @deleteIngredientTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Ingredient?'**
  String get deleteIngredientTitle;

  /// No description provided for @deleteIngredientMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\"'**
  String deleteIngredientMessage(String name);

  /// No description provided for @ingredientDeleted.
  ///
  /// In en, this message translates to:
  /// **'Ingredient deleted'**
  String get ingredientDeleted;

  /// No description provided for @noIngredientsData.
  ///
  /// In en, this message translates to:
  /// **'No ingredients data'**
  String get noIngredientsData;

  /// No description provided for @ingredientDetail.
  ///
  /// In en, this message translates to:
  /// **'{name} ({amount} {unit})'**
  String ingredientDetail(String name, String amount, String unit);

  /// No description provided for @ingredientCalories.
  ///
  /// In en, this message translates to:
  /// **'{calories} kcal'**
  String ingredientCalories(int calories);

  /// No description provided for @useThisMeal.
  ///
  /// In en, this message translates to:
  /// **'Use This Meal'**
  String get useThisMeal;

  /// No description provided for @errorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading: {error}'**
  String errorLoading(String error);

  /// No description provided for @scanFoundNewImages.
  ///
  /// In en, this message translates to:
  /// **'Found {count} new images on {date}'**
  String scanFoundNewImages(int count, String date);

  /// No description provided for @scanNoNewImages.
  ///
  /// In en, this message translates to:
  /// **'No new images found on {date}'**
  String scanNoNewImages(String date);

  /// No description provided for @aiAnalysisRemaining.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis: {remaining}/{total} remaining today'**
  String aiAnalysisRemaining(int remaining, int total);

  /// No description provided for @upgradeToProUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro for unlimited use'**
  String get upgradeToProUnlimited;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete \"{name}\"?'**
  String confirmDeleteMessage(String name);

  /// No description provided for @entryDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'✅ Entry deleted successfully'**
  String get entryDeletedSuccess;

  /// No description provided for @entryDeleteError.
  ///
  /// In en, this message translates to:
  /// **'❌ Error: {error}'**
  String entryDeleteError(String error);

  /// No description provided for @batchAnalyzeItems.
  ///
  /// In en, this message translates to:
  /// **'{count} items (batch)'**
  String batchAnalyzeItems(int count);

  /// No description provided for @analyzeCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled — analyzed {success} items successfully'**
  String analyzeCancelled(int success);

  /// No description provided for @analyzeSuccessAll.
  ///
  /// In en, this message translates to:
  /// **'✅ Analyzed {success} items successfully'**
  String analyzeSuccessAll(int success);

  /// No description provided for @analyzeSuccessPartial.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Analyzed {success}/{total} items ({failed} failed)'**
  String analyzeSuccessPartial(int success, int total, int failed);

  /// No description provided for @analyzeProgress.
  ///
  /// In en, this message translates to:
  /// **'{item}  ({current}/{total})'**
  String analyzeProgress(String item, int current, int total);

  /// No description provided for @pullToScanMeal.
  ///
  /// In en, this message translates to:
  /// **'Pull to scan your meal'**
  String get pullToScanMeal;

  /// No description provided for @analyzeAll.
  ///
  /// In en, this message translates to:
  /// **'Analyze All'**
  String get analyzeAll;

  /// No description provided for @addFoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Food'**
  String get addFoodTitle;

  /// No description provided for @foodNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Food Name *'**
  String get foodNameRequired;

  /// No description provided for @foodNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Fried Rice with Shrimp'**
  String get foodNameHint;

  /// No description provided for @selectedFromMyMeal.
  ///
  /// In en, this message translates to:
  /// **'✅ Selected from My Meal — nutrition data auto-filled'**
  String get selectedFromMyMeal;

  /// No description provided for @foundInDatabase.
  ///
  /// In en, this message translates to:
  /// **'✅ Found in database — nutrition data auto-filled'**
  String get foundInDatabase;

  /// No description provided for @saveAndAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Analyze'**
  String get saveAndAnalyze;

  /// No description provided for @notFoundInDatabase.
  ///
  /// In en, this message translates to:
  /// **'Not found in database — will be analyzed in background'**
  String get notFoundInDatabase;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// No description provided for @unitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unitLabel;

  /// No description provided for @nutritionAutoCalculated.
  ///
  /// In en, this message translates to:
  /// **'Nutrition (auto-calculated by amount)'**
  String get nutritionAutoCalculated;

  /// No description provided for @nutritionEnterZero.
  ///
  /// In en, this message translates to:
  /// **'Nutrition (enter 0 if unknown)'**
  String get nutritionEnterZero;

  /// No description provided for @caloriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Calories (kcal)'**
  String get caloriesLabel;

  /// No description provided for @proteinLabelShort.
  ///
  /// In en, this message translates to:
  /// **'Protein (g)'**
  String get proteinLabelShort;

  /// No description provided for @carbsLabelShort.
  ///
  /// In en, this message translates to:
  /// **'Carbs (g)'**
  String get carbsLabelShort;

  /// No description provided for @fatLabelShort.
  ///
  /// In en, this message translates to:
  /// **'Fat (g)'**
  String get fatLabelShort;

  /// No description provided for @mealTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Meal Type'**
  String get mealTypeLabel;

  /// No description provided for @pleaseEnterFoodNameFirst.
  ///
  /// In en, this message translates to:
  /// **'Please enter food name first'**
  String get pleaseEnterFoodNameFirst;

  /// No description provided for @savedAnalyzingBackground.
  ///
  /// In en, this message translates to:
  /// **'✅ Saved — analyzing in background'**
  String get savedAnalyzingBackground;

  /// No description provided for @foodAdded.
  ///
  /// In en, this message translates to:
  /// **'✅ Food added'**
  String get foodAdded;

  /// No description provided for @suggestionSourceMyMeal.
  ///
  /// In en, this message translates to:
  /// **'My Meal'**
  String get suggestionSourceMyMeal;

  /// No description provided for @suggestionSourceIngredient.
  ///
  /// In en, this message translates to:
  /// **'Ingredient'**
  String get suggestionSourceIngredient;

  /// No description provided for @suggestionSourceDatabase.
  ///
  /// In en, this message translates to:
  /// **'Database'**
  String get suggestionSourceDatabase;

  /// No description provided for @editFoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Food'**
  String get editFoodTitle;

  /// No description provided for @foodNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Food name'**
  String get foodNameLabel;

  /// No description provided for @changeAmountAutoUpdate.
  ///
  /// In en, this message translates to:
  /// **'Change amount → calories update automatically'**
  String get changeAmountAutoUpdate;

  /// No description provided for @baseNutrition.
  ///
  /// In en, this message translates to:
  /// **'Base: {calories} kcal / 1 {unit}'**
  String baseNutrition(int calories, String unit);

  /// No description provided for @calculatedFromIngredients.
  ///
  /// In en, this message translates to:
  /// **'Calculated from ingredients below'**
  String get calculatedFromIngredients;

  /// No description provided for @ingredientsEditable.
  ///
  /// In en, this message translates to:
  /// **'Ingredients (Editable)'**
  String get ingredientsEditable;

  /// No description provided for @addIngredientButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addIngredientButton;

  /// No description provided for @noIngredientsAddHint.
  ///
  /// In en, this message translates to:
  /// **'No ingredients — tap \"Add\" to add new'**
  String get noIngredientsAddHint;

  /// No description provided for @editIngredientsHint.
  ///
  /// In en, this message translates to:
  /// **'Edit name/amount → Tap search icon to search database or AI'**
  String get editIngredientsHint;

  /// No description provided for @ingredientNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Chicken Egg'**
  String get ingredientNameHint;

  /// No description provided for @searchDbOrAi.
  ///
  /// In en, this message translates to:
  /// **'Search DB / AI'**
  String get searchDbOrAi;

  /// No description provided for @amountHint.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountHint;

  /// No description provided for @fromDatabase.
  ///
  /// In en, this message translates to:
  /// **'From Database'**
  String get fromDatabase;

  /// No description provided for @subIngredients.
  ///
  /// In en, this message translates to:
  /// **'Sub-ingredients ({count})'**
  String subIngredients(int count);

  /// No description provided for @addSubIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addSubIngredient;

  /// No description provided for @subIngredientNameHint.
  ///
  /// In en, this message translates to:
  /// **'Sub-ingredient name'**
  String get subIngredientNameHint;

  /// No description provided for @amountShort.
  ///
  /// In en, this message translates to:
  /// **'Amt'**
  String get amountShort;

  /// No description provided for @pleaseEnterSubIngredientName.
  ///
  /// In en, this message translates to:
  /// **'Please enter sub-ingredient name first'**
  String get pleaseEnterSubIngredientName;

  /// No description provided for @foundInDatabaseSub.
  ///
  /// In en, this message translates to:
  /// **'Found \"{name}\" in database!'**
  String foundInDatabaseSub(String name);

  /// No description provided for @aiAnalyzedSub.
  ///
  /// In en, this message translates to:
  /// **'AI analyzed \"{name}\" (-1 Energy)'**
  String aiAnalyzedSub(String name);

  /// No description provided for @couldNotAnalyzeSub.
  ///
  /// In en, this message translates to:
  /// **'Could not analyze sub-ingredient'**
  String get couldNotAnalyzeSub;

  /// No description provided for @pleaseEnterIngredientName.
  ///
  /// In en, this message translates to:
  /// **'Please enter ingredient name'**
  String get pleaseEnterIngredientName;

  /// No description provided for @reAnalyzeTitle.
  ///
  /// In en, this message translates to:
  /// **'Re-analyze?'**
  String get reAnalyzeTitle;

  /// No description provided for @reAnalyzeMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" already has nutrition data.\n\nAnalyzing again will use 1 Energy.\n\nContinue?'**
  String reAnalyzeMessage(String name);

  /// No description provided for @reAnalyzeButton.
  ///
  /// In en, this message translates to:
  /// **'Re-analyze (1 Energy)'**
  String get reAnalyzeButton;

  /// No description provided for @amountNotSpecified.
  ///
  /// In en, this message translates to:
  /// **'Amount not specified'**
  String get amountNotSpecified;

  /// No description provided for @amountNotSpecifiedMessage.
  ///
  /// In en, this message translates to:
  /// **'Please specify amount for \"{name}\" first\nOr use default 100 g?'**
  String amountNotSpecifiedMessage(String name);

  /// No description provided for @useDefault100g.
  ///
  /// In en, this message translates to:
  /// **'Use 100 g'**
  String get useDefault100g;

  /// No description provided for @aiAnalyzedResult.
  ///
  /// In en, this message translates to:
  /// **'AI: \"{name}\" → {calories} kcal'**
  String aiAnalyzedResult(String name, int calories);

  /// No description provided for @unableToAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Unable to analyze'**
  String get unableToAnalyze;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @savedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'✅ Saved successfully'**
  String get savedSuccessfully;

  /// No description provided for @saveToMyMeals.
  ///
  /// In en, this message translates to:
  /// **'📖 Save to My Meals'**
  String get saveToMyMeals;

  /// No description provided for @savedToMyMealsSuccess.
  ///
  /// In en, this message translates to:
  /// **'✅ Saved \'{mealName}\' to My Meals'**
  String savedToMyMealsSuccess(String mealName);

  /// No description provided for @failedToSaveToMyMeals.
  ///
  /// In en, this message translates to:
  /// **'❌ Failed to save to My Meals'**
  String get failedToSaveToMyMeals;

  /// No description provided for @noIngredientsToSave.
  ///
  /// In en, this message translates to:
  /// **'No ingredients to save'**
  String get noIngredientsToSave;

  /// No description provided for @confirmFoodPhoto.
  ///
  /// In en, this message translates to:
  /// **'Confirm Food Photo'**
  String get confirmFoodPhoto;

  /// No description provided for @photoSavedAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Photo saved automatically'**
  String get photoSavedAutomatically;

  /// No description provided for @foodNameHintExample.
  ///
  /// In en, this message translates to:
  /// **'e.g., Grilled chicken salad'**
  String get foodNameHintExample;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// No description provided for @quantityHint.
  ///
  /// In en, this message translates to:
  /// **'1'**
  String get quantityHint;

  /// No description provided for @optionalFoodInfo.
  ///
  /// In en, this message translates to:
  /// **'Entering the food name and quantity is optional, but providing them will improve AI analysis accuracy.'**
  String get optionalFoodInfo;

  /// No description provided for @saveOnly.
  ///
  /// In en, this message translates to:
  /// **'Save only'**
  String get saveOnly;

  /// No description provided for @pleaseEnterValidQuantity.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid quantity'**
  String get pleaseEnterValidQuantity;

  /// No description provided for @analyzedResult.
  ///
  /// In en, this message translates to:
  /// **'✅ Analyzed: {name} — {calories} kcal'**
  String analyzedResult(String name, int calories);

  /// No description provided for @couldNotAnalyzeSaved.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Could not analyze — saved, use \"Analyze All\" later'**
  String get couldNotAnalyzeSaved;

  /// No description provided for @savedAnalyzeLater.
  ///
  /// In en, this message translates to:
  /// **'✅ Saved — analyze later with \"Analyze All\"'**
  String get savedAnalyzeLater;

  /// No description provided for @editIngredientTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Ingredient'**
  String get editIngredientTitle;

  /// No description provided for @ingredientNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Ingredient Name *'**
  String get ingredientNameRequired;

  /// No description provided for @baseAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Base Amount'**
  String get baseAmountLabel;

  /// No description provided for @baseAmountHint.
  ///
  /// In en, this message translates to:
  /// **'100'**
  String get baseAmountHint;

  /// No description provided for @nutritionPerBase.
  ///
  /// In en, this message translates to:
  /// **'Nutrition per {amount} {unit}'**
  String nutritionPerBase(String amount, String unit);

  /// No description provided for @nutritionCalculatedPerBase.
  ///
  /// In en, this message translates to:
  /// **'Nutrition calculated per {amount} {unit} — system will auto-calculate based on actual amount consumed'**
  String nutritionCalculatedPerBase(String amount, String unit);

  /// No description provided for @createIngredient.
  ///
  /// In en, this message translates to:
  /// **'Create Ingredient'**
  String get createIngredient;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @pleaseEnterIngredientNameFirst.
  ///
  /// In en, this message translates to:
  /// **'Please enter ingredient name first'**
  String get pleaseEnterIngredientNameFirst;

  /// No description provided for @aiAnalyzedIngredient.
  ///
  /// In en, this message translates to:
  /// **'AI: \"{name}\" {amount} {unit} → {calories} kcal'**
  String aiAnalyzedIngredient(
      String name, String amount, String unit, int calories);

  /// No description provided for @unableToFindIngredient.
  ///
  /// In en, this message translates to:
  /// **'Unable to find this ingredient'**
  String get unableToFindIngredient;

  /// No description provided for @searchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search failed: {error}'**
  String searchFailed(String error);

  /// No description provided for @deleteEntriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {count} {count, plural, =1 {Entry} other {Entries}}?'**
  String deleteEntriesTitle(int count);

  /// No description provided for @deleteEntriesMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete {count} selected food {count, plural, =1 {entry} other {entries}}?'**
  String deleteEntriesMessage(int count);

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAll;

  /// No description provided for @deletedEntries.
  ///
  /// In en, this message translates to:
  /// **'Deleted {count} {count, plural, =1 {entry} other {entries}}'**
  String deletedEntries(int count);

  /// No description provided for @deletedSingleEntry.
  ///
  /// In en, this message translates to:
  /// **'Deleted {name}'**
  String deletedSingleEntry(String name);

  /// No description provided for @intakeGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Intake Goal'**
  String get intakeGoalLabel;

  /// No description provided for @netEnergyLabel.
  ///
  /// In en, this message translates to:
  /// **'Net Energy Balance'**
  String get netEnergyLabel;

  /// No description provided for @underEatingWarning.
  ///
  /// In en, this message translates to:
  /// **'Under-eating'**
  String get underEatingWarning;

  /// No description provided for @surplusWarning.
  ///
  /// In en, this message translates to:
  /// **'Surplus'**
  String get surplusWarning;

  /// No description provided for @movedEntriesToDate.
  ///
  /// In en, this message translates to:
  /// **'Moved {count} {count, plural, =1 {entry} other {entries}} to {date}'**
  String movedEntriesToDate(int count, String date);

  /// No description provided for @allSelectedAlreadyAnalyzed.
  ///
  /// In en, this message translates to:
  /// **'All selected entries are already analyzed'**
  String get allSelectedAlreadyAnalyzed;

  /// No description provided for @analyzeCancelledSelected.
  ///
  /// In en, this message translates to:
  /// **'Cancelled — {success} analyzed'**
  String analyzeCancelledSelected(int success);

  /// No description provided for @analyzedEntriesAll.
  ///
  /// In en, this message translates to:
  /// **'Analyzed {success} {success, plural, =1 {entry} other {entries}}'**
  String analyzedEntriesAll(int success);

  /// No description provided for @analyzedEntriesPartial.
  ///
  /// In en, this message translates to:
  /// **'Analyzed {success}/{total} ({failed} failed)'**
  String analyzedEntriesPartial(int success, int total, int failed);

  /// No description provided for @analyzeProgressSelected.
  ///
  /// In en, this message translates to:
  /// **'{current}/{total}  {item}'**
  String analyzeProgressSelected(int current, int total, String item);

  /// No description provided for @noEntriesYet.
  ///
  /// In en, this message translates to:
  /// **'No entries yet'**
  String get noEntriesYet;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAll;

  /// No description provided for @deselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect all'**
  String get deselectAll;

  /// No description provided for @moveToDate.
  ///
  /// In en, this message translates to:
  /// **'Move to date'**
  String get moveToDate;

  /// No description provided for @analyzeSelected.
  ///
  /// In en, this message translates to:
  /// **'Analyze'**
  String get analyzeSelected;

  /// No description provided for @deleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteTooltip;

  /// No description provided for @move.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get move;

  /// No description provided for @deleteTooltipAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteTooltipAction;

  /// No description provided for @switchToModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch to {mode} mode?'**
  String switchToModeTitle(String mode);

  /// No description provided for @switchToModeMessage.
  ///
  /// In en, this message translates to:
  /// **'This item was analyzed as {current}.\n\nRe-analyzing as {newMode} will use 1 Energy.\n\nContinue?'**
  String switchToModeMessage(String current, String newMode);

  /// No description provided for @analyzingAsMode.
  ///
  /// In en, this message translates to:
  /// **'Analyzing as {mode}...'**
  String analyzingAsMode(String mode);

  /// No description provided for @reAnalyzedAsMode.
  ///
  /// In en, this message translates to:
  /// **'✅ Re-analyzed as {mode}'**
  String reAnalyzedAsMode(String mode);

  /// No description provided for @analysisFailed.
  ///
  /// In en, this message translates to:
  /// **'❌ Analysis failed'**
  String get analysisFailed;

  /// No description provided for @aiAnalysisComplete.
  ///
  /// In en, this message translates to:
  /// **'✅ AI analyzed and saved'**
  String get aiAnalysisComplete;

  /// No description provided for @changeMealType.
  ///
  /// In en, this message translates to:
  /// **'Change Meal Type'**
  String get changeMealType;

  /// No description provided for @moveToAnotherDate.
  ///
  /// In en, this message translates to:
  /// **'Move to Another Date'**
  String get moveToAnotherDate;

  /// No description provided for @currentDate.
  ///
  /// In en, this message translates to:
  /// **'Current: {date}'**
  String currentDate(String date);

  /// No description provided for @cancelDateChange.
  ///
  /// In en, this message translates to:
  /// **'Cancel Date Change'**
  String get cancelDateChange;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @chatHistory.
  ///
  /// In en, this message translates to:
  /// **'Chat History'**
  String get chatHistory;

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get newChat;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @helloImMiro.
  ///
  /// In en, this message translates to:
  /// **'Hello! I\'m Miro'**
  String get helloImMiro;

  /// No description provided for @tellMeWhatYouAteToday.
  ///
  /// In en, this message translates to:
  /// **'Tell me what you ate today!'**
  String get tellMeWhatYouAteToday;

  /// No description provided for @tellMeWhatYouAte.
  ///
  /// In en, this message translates to:
  /// **'Tell me what you ate...'**
  String get tellMeWhatYouAte;

  /// No description provided for @clearHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear history?'**
  String get clearHistoryTitle;

  /// No description provided for @clearHistoryMessage.
  ///
  /// In en, this message translates to:
  /// **'All messages in this session will be deleted.'**
  String get clearHistoryMessage;

  /// No description provided for @chatHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat History'**
  String get chatHistoryTitle;

  /// No description provided for @newLabel.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newLabel;

  /// No description provided for @noChatHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No chat history yet'**
  String get noChatHistoryYet;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @deleteChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete chat?'**
  String get deleteChatTitle;

  /// No description provided for @deleteChatMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"?'**
  String deleteChatMessage(String title);

  /// No description provided for @weeklySummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'📊 Weekly Summary ({start} - {end})'**
  String weeklySummaryTitle(String start, String end);

  /// No description provided for @daySummary.
  ///
  /// In en, this message translates to:
  /// **'📅 {day}: {calories} kcal {emoji} ({diff})'**
  String daySummary(String day, String calories, String emoji, String diff);

  /// No description provided for @overTarget.
  ///
  /// In en, this message translates to:
  /// **'{amount} over target'**
  String overTarget(String amount);

  /// No description provided for @underTarget.
  ///
  /// In en, this message translates to:
  /// **'{amount} under target'**
  String underTarget(String amount);

  /// No description provided for @noFoodLoggedThisWeek.
  ///
  /// In en, this message translates to:
  /// **'No food logged this week yet.'**
  String get noFoodLoggedThisWeek;

  /// No description provided for @averageKcalPerDay.
  ///
  /// In en, this message translates to:
  /// **'🔥 Average: {average} kcal/day'**
  String averageKcalPerDay(String average);

  /// No description provided for @targetKcalPerDay.
  ///
  /// In en, this message translates to:
  /// **'🎯 Target: {target} kcal/day'**
  String targetKcalPerDay(String target);

  /// No description provided for @resultOverTarget.
  ///
  /// In en, this message translates to:
  /// **'📈 Result: {amount} kcal over target'**
  String resultOverTarget(String amount);

  /// No description provided for @resultUnderTarget.
  ///
  /// In en, this message translates to:
  /// **'📈 Result: {amount} kcal under target — Great job! 💪'**
  String resultUnderTarget(String amount);

  /// No description provided for @failedToLoadWeeklySummary.
  ///
  /// In en, this message translates to:
  /// **'❌ Failed to load weekly summary: {error}'**
  String failedToLoadWeeklySummary(String error);

  /// No description provided for @monthlySummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'📊 Monthly Summary ({month} {year})'**
  String monthlySummaryTitle(String month, int year);

  /// No description provided for @totalDays.
  ///
  /// In en, this message translates to:
  /// **'📅 Total Days: {days}'**
  String totalDays(int days);

  /// No description provided for @totalConsumed.
  ///
  /// In en, this message translates to:
  /// **'🔥 Total Consumed: {calories} kcal'**
  String totalConsumed(String calories);

  /// No description provided for @targetTotal.
  ///
  /// In en, this message translates to:
  /// **'🎯 Target Total: {target} kcal'**
  String targetTotal(String target);

  /// No description provided for @averageKcalPerDayShort.
  ///
  /// In en, this message translates to:
  /// **'📈 Average: {average} kcal/day'**
  String averageKcalPerDayShort(String average);

  /// No description provided for @overTargetThisMonth.
  ///
  /// In en, this message translates to:
  /// **'⚠️ {amount} kcal over target this month'**
  String overTargetThisMonth(String amount);

  /// No description provided for @underTargetThisMonth.
  ///
  /// In en, this message translates to:
  /// **'✅ {amount} kcal under target — Excellent! 💪'**
  String underTargetThisMonth(String amount);

  /// No description provided for @failedToLoadMonthlySummary.
  ///
  /// In en, this message translates to:
  /// **'❌ Failed to load monthly summary: {error}'**
  String failedToLoadMonthlySummary(String error);

  /// No description provided for @localAiHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'🤖 Local AI Help'**
  String get localAiHelpTitle;

  /// No description provided for @localAiHelpFormat.
  ///
  /// In en, this message translates to:
  /// **'Format: [food] [amount] [unit]'**
  String get localAiHelpFormat;

  /// No description provided for @localAiHelpExamples.
  ///
  /// In en, this message translates to:
  /// **'Examples:\n• chicken 100g and rice 200g\n• pizza 2 slices\n• apple 1 piece, banana 1 piece'**
  String get localAiHelpExamples;

  /// No description provided for @localAiHelpNote.
  ///
  /// In en, this message translates to:
  /// **'Note: English only, basic parsing\nSwitch to Miro AI for better results!'**
  String get localAiHelpNote;

  /// No description provided for @hiNoFoodLogged.
  ///
  /// In en, this message translates to:
  /// **'🤖 Hi! No food logged yet today.\n   Target: {target} kcal — Ready to start logging? 🍽️'**
  String hiNoFoodLogged(String target);

  /// No description provided for @hiKcalLeft.
  ///
  /// In en, this message translates to:
  /// **'🤖 Hi! You have {remaining} kcal left for today.\n   Ready to log your meals? 😊'**
  String hiKcalLeft(String remaining);

  /// No description provided for @hiOverTarget.
  ///
  /// In en, this message translates to:
  /// **'🤖 Hi! You\'ve consumed {calories} kcal today.\n   {over} kcal over target — Let\'s keep tracking! 💪'**
  String hiOverTarget(String calories, String over);

  /// No description provided for @hiReadyToLog.
  ///
  /// In en, this message translates to:
  /// **'🤖 Hi! Ready to log your meals? 😊'**
  String get hiReadyToLog;

  /// No description provided for @notEnoughEnergy.
  ///
  /// In en, this message translates to:
  /// **'Not enough Energy'**
  String get notEnoughEnergy;

  /// No description provided for @thinkingMealIdeas.
  ///
  /// In en, this message translates to:
  /// **'🤖 Thinking of great meal ideas for you...'**
  String get thinkingMealIdeas;

  /// No description provided for @recentMeals.
  ///
  /// In en, this message translates to:
  /// **'Recent meals: '**
  String get recentMeals;

  /// No description provided for @noRecentFood.
  ///
  /// In en, this message translates to:
  /// **'No recent food logged.'**
  String get noRecentFood;

  /// No description provided for @remainingCaloriesToday.
  ///
  /// In en, this message translates to:
  /// **'. Remaining calories today: {remaining} kcal.'**
  String remainingCaloriesToday(String remaining);

  /// No description provided for @failedToGetMenuSuggestions.
  ///
  /// In en, this message translates to:
  /// **'❌ Failed to get menu suggestions: {error}'**
  String failedToGetMenuSuggestions(String error);

  /// No description provided for @mealSuggestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'🤖 Based on your food log, here are 3 meal suggestions:\n'**
  String get mealSuggestionsTitle;

  /// No description provided for @mealSuggestionItem.
  ///
  /// In en, this message translates to:
  /// **'{index}. {emoji} {name} (~{calories} kcal)'**
  String mealSuggestionItem(
      int index, String emoji, String name, String calories);

  /// No description provided for @mealSuggestionMacros.
  ///
  /// In en, this message translates to:
  /// **'   P: {protein}g | C: {carbs}g | F: {fat}g'**
  String mealSuggestionMacros(String protein, String carbs, String fat);

  /// No description provided for @pickOneAndLog.
  ///
  /// In en, this message translates to:
  /// **'\nPick one and I\'ll log it for you! 😊'**
  String get pickOneAndLog;

  /// No description provided for @energyCost.
  ///
  /// In en, this message translates to:
  /// **'\n⚡ -{cost} Energy'**
  String energyCost(int cost);

  /// No description provided for @giveMeTipsForHealthyEating.
  ///
  /// In en, this message translates to:
  /// **'Give me tips for healthy eating'**
  String get giveMeTipsForHealthyEating;

  /// No description provided for @howManyCaloriesToday.
  ///
  /// In en, this message translates to:
  /// **'How many calories today?'**
  String get howManyCaloriesToday;

  /// No description provided for @menuLabel.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menuLabel;

  /// No description provided for @weeklyLabel.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weeklyLabel;

  /// No description provided for @monthlyLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthlyLabel;

  /// No description provided for @tipsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get tipsLabel;

  /// No description provided for @summaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summaryLabel;

  /// No description provided for @helpLabel.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpLabel;

  /// No description provided for @onboardingWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track calories effortlessly\nwith AI-powered analysis'**
  String get onboardingWelcomeSubtitle;

  /// No description provided for @onboardingSnap.
  ///
  /// In en, this message translates to:
  /// **'Snap'**
  String get onboardingSnap;

  /// No description provided for @onboardingSnapDesc.
  ///
  /// In en, this message translates to:
  /// **'AI analyzes instantly'**
  String get onboardingSnapDesc;

  /// No description provided for @onboardingType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get onboardingType;

  /// No description provided for @onboardingTypeDesc.
  ///
  /// In en, this message translates to:
  /// **'Log in seconds'**
  String get onboardingTypeDesc;

  /// No description provided for @onboardingEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get onboardingEdit;

  /// No description provided for @onboardingEditDesc.
  ///
  /// In en, this message translates to:
  /// **'Fine-tune accuracy'**
  String get onboardingEditDesc;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next →'**
  String get onboardingNext;

  /// No description provided for @onboardingDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'AI-estimated data. Not medical advice.'**
  String get onboardingDisclaimer;

  /// No description provided for @onboardingQuickSetup.
  ///
  /// In en, this message translates to:
  /// **'Quick Setup'**
  String get onboardingQuickSetup;

  /// No description provided for @onboardingHelpAiUnderstand.
  ///
  /// In en, this message translates to:
  /// **'Help AI understand your food better'**
  String get onboardingHelpAiUnderstand;

  /// No description provided for @onboardingYourTypicalCuisine.
  ///
  /// In en, this message translates to:
  /// **'Your typical cuisine:'**
  String get onboardingYourTypicalCuisine;

  /// No description provided for @onboardingDailyCalorieGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily calorie goal (optional):'**
  String get onboardingDailyCalorieGoal;

  /// No description provided for @onboardingKcalPerDay.
  ///
  /// In en, this message translates to:
  /// **'kcal/day'**
  String get onboardingKcalPerDay;

  /// No description provided for @onboardingCalorieGoalHint.
  ///
  /// In en, this message translates to:
  /// **'2000'**
  String get onboardingCalorieGoalHint;

  /// No description provided for @onboardingCanChangeAnytime.
  ///
  /// In en, this message translates to:
  /// **'You can change this anytime in Profile settings'**
  String get onboardingCanChangeAnytime;

  /// No description provided for @onboardingYoureAllSet.
  ///
  /// In en, this message translates to:
  /// **'You\'re All Set!'**
  String get onboardingYoureAllSet;

  /// No description provided for @onboardingStartTracking.
  ///
  /// In en, this message translates to:
  /// **'Start tracking your meals today.\nSnap a photo or type what you ate.'**
  String get onboardingStartTracking;

  /// No description provided for @onboardingWelcomeGift.
  ///
  /// In en, this message translates to:
  /// **'Welcome Gift'**
  String get onboardingWelcomeGift;

  /// No description provided for @onboardingFreeEnergy.
  ///
  /// In en, this message translates to:
  /// **'10 FREE Energy'**
  String get onboardingFreeEnergy;

  /// No description provided for @onboardingFreeEnergyDesc.
  ///
  /// In en, this message translates to:
  /// **'= 10 AI analyses to get started'**
  String get onboardingFreeEnergyDesc;

  /// No description provided for @onboardingEnergyCost.
  ///
  /// In en, this message translates to:
  /// **'Each analysis costs 1 Energy\nThe more you use, the more you earn!'**
  String get onboardingEnergyCost;

  /// No description provided for @onboardingStartTrackingButton.
  ///
  /// In en, this message translates to:
  /// **'Start Tracking! →'**
  String get onboardingStartTrackingButton;

  /// No description provided for @onboardingNoCreditCard.
  ///
  /// In en, this message translates to:
  /// **'No credit card • No hidden fees'**
  String get onboardingNoCreditCard;

  /// No description provided for @cameraTakePhotoOfFood.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of your food'**
  String get cameraTakePhotoOfFood;

  /// No description provided for @cameraFailedToInitialize.
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize camera'**
  String get cameraFailedToInitialize;

  /// No description provided for @cameraFailedToCapture.
  ///
  /// In en, this message translates to:
  /// **'Failed to capture photo'**
  String get cameraFailedToCapture;

  /// No description provided for @cameraFailedToPickFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image from gallery'**
  String get cameraFailedToPickFromGallery;

  /// No description provided for @cameraProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get cameraProcessing;

  /// No description provided for @referralInviteFriends.
  ///
  /// In en, this message translates to:
  /// **'Invite Friends'**
  String get referralInviteFriends;

  /// No description provided for @referralYourReferralCode.
  ///
  /// In en, this message translates to:
  /// **'Your Referral Code'**
  String get referralYourReferralCode;

  /// No description provided for @referralLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get referralLoading;

  /// No description provided for @referralCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get referralCopy;

  /// No description provided for @referralShareCodeDescription.
  ///
  /// In en, this message translates to:
  /// **'Share this code with friends! When they use AI 3 times, you both get rewards!'**
  String get referralShareCodeDescription;

  /// No description provided for @referralEnterReferralCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Referral Code'**
  String get referralEnterReferralCode;

  /// No description provided for @referralCodeHint.
  ///
  /// In en, this message translates to:
  /// **'MIRO-XXXX-XXXX-XXXX'**
  String get referralCodeHint;

  /// No description provided for @referralSubmitCode.
  ///
  /// In en, this message translates to:
  /// **'Submit Code'**
  String get referralSubmitCode;

  /// No description provided for @referralPleaseEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter a referral code'**
  String get referralPleaseEnterCode;

  /// No description provided for @referralCodeAccepted.
  ///
  /// In en, this message translates to:
  /// **'Referral code accepted!'**
  String get referralCodeAccepted;

  /// No description provided for @referralCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Referral code copied to clipboard!'**
  String get referralCodeCopied;

  /// No description provided for @referralEnergyBonus.
  ///
  /// In en, this message translates to:
  /// **'+{energy} Energy!'**
  String referralEnergyBonus(int energy);

  /// No description provided for @referralHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'How It Works'**
  String get referralHowItWorks;

  /// No description provided for @referralStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Share your referral code'**
  String get referralStep1Title;

  /// No description provided for @referralStep1Description.
  ///
  /// In en, this message translates to:
  /// **'Copy and share your MiRO ID with friends'**
  String get referralStep1Description;

  /// No description provided for @referralStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Friend enters your code'**
  String get referralStep2Title;

  /// No description provided for @referralStep2Description.
  ///
  /// In en, this message translates to:
  /// **'They get +20 Energy immediately'**
  String get referralStep2Description;

  /// No description provided for @referralStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Friend uses AI 3 times'**
  String get referralStep3Title;

  /// No description provided for @referralStep3Description.
  ///
  /// In en, this message translates to:
  /// **'When they complete 3 AI analyses'**
  String get referralStep3Description;

  /// No description provided for @referralStep4Title.
  ///
  /// In en, this message translates to:
  /// **'You get rewarded!'**
  String get referralStep4Title;

  /// No description provided for @referralStep4Description.
  ///
  /// In en, this message translates to:
  /// **'You receive +5 Energy!'**
  String get referralStep4Description;

  /// No description provided for @tierBenefitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tier Benefits'**
  String get tierBenefitsTitle;

  /// No description provided for @tierBenefitsUnlockRewards.
  ///
  /// In en, this message translates to:
  /// **'Unlock Rewards\nwith Daily Streaks'**
  String get tierBenefitsUnlockRewards;

  /// No description provided for @tierBenefitsKeepStreakDescription.
  ///
  /// In en, this message translates to:
  /// **'Keep your streak alive to unlock higher tiers and earn amazing benefits!'**
  String get tierBenefitsKeepStreakDescription;

  /// No description provided for @tierBenefitsHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'How It Works'**
  String get tierBenefitsHowItWorks;

  /// No description provided for @tierBenefitsDailyEnergyReward.
  ///
  /// In en, this message translates to:
  /// **'Daily Energy Reward'**
  String get tierBenefitsDailyEnergyReward;

  /// No description provided for @tierBenefitsDailyEnergyDescription.
  ///
  /// In en, this message translates to:
  /// **'Use AI at least once per day to earn bonus energy. Higher tiers = more daily energy!'**
  String get tierBenefitsDailyEnergyDescription;

  /// No description provided for @tierBenefitsPurchaseBonus.
  ///
  /// In en, this message translates to:
  /// **'Purchase Bonus'**
  String get tierBenefitsPurchaseBonus;

  /// No description provided for @tierBenefitsPurchaseBonusDescription.
  ///
  /// In en, this message translates to:
  /// **'Gold & Diamond tiers get extra energy on every purchase (10-20% more!)'**
  String get tierBenefitsPurchaseBonusDescription;

  /// No description provided for @tierBenefitsGracePeriod.
  ///
  /// In en, this message translates to:
  /// **'Grace Period'**
  String get tierBenefitsGracePeriod;

  /// No description provided for @tierBenefitsGracePeriodDescription.
  ///
  /// In en, this message translates to:
  /// **'Miss a day without losing your streak. Silver+ tiers get protection!'**
  String get tierBenefitsGracePeriodDescription;

  /// No description provided for @tierBenefitsAllTiers.
  ///
  /// In en, this message translates to:
  /// **'All Tiers'**
  String get tierBenefitsAllTiers;

  /// No description provided for @tierBenefitsNew.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get tierBenefitsNew;

  /// No description provided for @tierBenefitsPopular.
  ///
  /// In en, this message translates to:
  /// **'POPULAR'**
  String get tierBenefitsPopular;

  /// No description provided for @tierBenefitsBest.
  ///
  /// In en, this message translates to:
  /// **'BEST'**
  String get tierBenefitsBest;

  /// No description provided for @tierBenefitsDailyCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Daily Check-in'**
  String get tierBenefitsDailyCheckIn;

  /// No description provided for @tierBenefitsProTips.
  ///
  /// In en, this message translates to:
  /// **'Pro Tips'**
  String get tierBenefitsProTips;

  /// No description provided for @tierBenefitsTip1.
  ///
  /// In en, this message translates to:
  /// **'Use AI daily to earn free energy and build your streak'**
  String get tierBenefitsTip1;

  /// No description provided for @tierBenefitsTip2.
  ///
  /// In en, this message translates to:
  /// **'Diamond tier earns +4 Energy per day — that\'s 120/month!'**
  String get tierBenefitsTip2;

  /// No description provided for @tierBenefitsTip3.
  ///
  /// In en, this message translates to:
  /// **'Purchase Bonus applies to ALL energy packages!'**
  String get tierBenefitsTip3;

  /// No description provided for @tierBenefitsTip4.
  ///
  /// In en, this message translates to:
  /// **'Grace period protects your streak if you miss a day'**
  String get tierBenefitsTip4;

  /// No description provided for @subscriptionEnergyPass.
  ///
  /// In en, this message translates to:
  /// **'Energy Pass'**
  String get subscriptionEnergyPass;

  /// No description provided for @subscriptionInAppPurchasesNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'In-app purchases not available'**
  String get subscriptionInAppPurchasesNotAvailable;

  /// No description provided for @subscriptionFailedToInitiatePurchase.
  ///
  /// In en, this message translates to:
  /// **'Failed to initiate purchase'**
  String get subscriptionFailedToInitiatePurchase;

  /// No description provided for @subscriptionError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String subscriptionError(String error);

  /// No description provided for @subscriptionFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load subscription'**
  String get subscriptionFailedToLoad;

  /// No description provided for @subscriptionUnknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get subscriptionUnknownError;

  /// No description provided for @subscriptionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get subscriptionRetry;

  /// No description provided for @subscriptionEnergyPassActive.
  ///
  /// In en, this message translates to:
  /// **'Energy Pass Active'**
  String get subscriptionEnergyPassActive;

  /// No description provided for @subscriptionUnlimitedAccess.
  ///
  /// In en, this message translates to:
  /// **'You have unlimited access'**
  String get subscriptionUnlimitedAccess;

  /// No description provided for @subscriptionStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get subscriptionStatus;

  /// No description provided for @subscriptionRenews.
  ///
  /// In en, this message translates to:
  /// **'Renews'**
  String get subscriptionRenews;

  /// No description provided for @subscriptionPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get subscriptionPrice;

  /// No description provided for @subscriptionYourBenefits.
  ///
  /// In en, this message translates to:
  /// **'Your Benefits'**
  String get subscriptionYourBenefits;

  /// No description provided for @subscriptionManageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get subscriptionManageSubscription;

  /// No description provided for @subscriptionNoProductAvailable.
  ///
  /// In en, this message translates to:
  /// **'No subscription product available'**
  String get subscriptionNoProductAvailable;

  /// No description provided for @subscriptionWhatYouGet.
  ///
  /// In en, this message translates to:
  /// **'What You Get'**
  String get subscriptionWhatYouGet;

  /// No description provided for @subscriptionPerMonth.
  ///
  /// In en, this message translates to:
  /// **'per month'**
  String get subscriptionPerMonth;

  /// No description provided for @subscriptionSubscribeNow.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Now'**
  String get subscriptionSubscribeNow;

  /// No description provided for @subscriptionSubscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscriptionSubscribe;

  /// No description provided for @subscriptionCancelAnytime.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime'**
  String get subscriptionCancelAnytime;

  /// No description provided for @subscriptionAutoRenewTerms.
  ///
  /// In en, this message translates to:
  /// **'Your subscription will renew automatically. You can cancel anytime from Google Play.'**
  String get subscriptionAutoRenewTerms;

  /// No description provided for @subscriptionRenewsDate.
  ///
  /// In en, this message translates to:
  /// **'Renews: {date}'**
  String subscriptionRenewsDate(String date);

  /// No description provided for @subscriptionBestValue.
  ///
  /// In en, this message translates to:
  /// **'BEST VALUE'**
  String get subscriptionBestValue;

  /// No description provided for @energyStoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Energy Store'**
  String get energyStoreTitle;

  /// No description provided for @energyPackages.
  ///
  /// In en, this message translates to:
  /// **'Energy Packages'**
  String get energyPackages;

  /// No description provided for @energyPackageStarterKick.
  ///
  /// In en, this message translates to:
  /// **'Starter Kick'**
  String get energyPackageStarterKick;

  /// No description provided for @energyPackageValuePack.
  ///
  /// In en, this message translates to:
  /// **'Value Pack'**
  String get energyPackageValuePack;

  /// No description provided for @energyPackagePowerUser.
  ///
  /// In en, this message translates to:
  /// **'Power User'**
  String get energyPackagePowerUser;

  /// No description provided for @energyPackageUltimateSaver.
  ///
  /// In en, this message translates to:
  /// **'Ultimate Saver'**
  String get energyPackageUltimateSaver;

  /// No description provided for @energyBadgeBestValue.
  ///
  /// In en, this message translates to:
  /// **'BEST VALUE'**
  String get energyBadgeBestValue;

  /// No description provided for @energyBadgePopular.
  ///
  /// In en, this message translates to:
  /// **'POPULAR'**
  String get energyBadgePopular;

  /// No description provided for @energyBadgeBonus10.
  ///
  /// In en, this message translates to:
  /// **'+10% bonus'**
  String get energyBadgeBonus10;

  /// No description provided for @energyPassUnlimitedAI.
  ///
  /// In en, this message translates to:
  /// **'Unlimited AI Analysis'**
  String get energyPassUnlimitedAI;

  /// No description provided for @energyPassUnlimitedFromPrice.
  ///
  /// In en, this message translates to:
  /// **'Unlimited AI Analysis • from {price}/month'**
  String energyPassUnlimitedFromPrice(String price);

  /// No description provided for @energyPassActive.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get energyPassActive;

  /// No description provided for @subscriptionDeal.
  ///
  /// In en, this message translates to:
  /// **'Subscription Deal'**
  String get subscriptionDeal;

  /// No description provided for @subscriptionViewDeal.
  ///
  /// In en, this message translates to:
  /// **'View Deal'**
  String get subscriptionViewDeal;

  /// No description provided for @disclaimerHealthDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Health Disclaimer'**
  String get disclaimerHealthDisclaimer;

  /// No description provided for @disclaimerImportantReminders.
  ///
  /// In en, this message translates to:
  /// **'Important Reminders:'**
  String get disclaimerImportantReminders;

  /// No description provided for @disclaimerBullet1.
  ///
  /// In en, this message translates to:
  /// **'All nutritional data is estimated'**
  String get disclaimerBullet1;

  /// No description provided for @disclaimerBullet2.
  ///
  /// In en, this message translates to:
  /// **'AI analysis may contain errors'**
  String get disclaimerBullet2;

  /// No description provided for @disclaimerBullet3.
  ///
  /// In en, this message translates to:
  /// **'Not a substitute for professional advice'**
  String get disclaimerBullet3;

  /// No description provided for @disclaimerBullet4.
  ///
  /// In en, this message translates to:
  /// **'Consult healthcare providers for medical guidance'**
  String get disclaimerBullet4;

  /// No description provided for @disclaimerBullet5.
  ///
  /// In en, this message translates to:
  /// **'Use at your own discretion and risk'**
  String get disclaimerBullet5;

  /// No description provided for @disclaimerIUnderstand.
  ///
  /// In en, this message translates to:
  /// **'I Understand'**
  String get disclaimerIUnderstand;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicySubtitle.
  ///
  /// In en, this message translates to:
  /// **'MiRO — My Intake Record Oracle'**
  String get privacyPolicySubtitle;

  /// No description provided for @privacyPolicyHeaderNote.
  ///
  /// In en, this message translates to:
  /// **'Your food data stays on your device. Energy balance synced securely via Firebase.'**
  String get privacyPolicyHeaderNote;

  /// No description provided for @privacyPolicySectionInformationWeCollect.
  ///
  /// In en, this message translates to:
  /// **'Information We Collect'**
  String get privacyPolicySectionInformationWeCollect;

  /// No description provided for @privacyPolicySectionDataStorage.
  ///
  /// In en, this message translates to:
  /// **'Data Storage'**
  String get privacyPolicySectionDataStorage;

  /// No description provided for @privacyPolicySectionDataTransmission.
  ///
  /// In en, this message translates to:
  /// **'Data Transmission to Third Parties'**
  String get privacyPolicySectionDataTransmission;

  /// No description provided for @privacyPolicySectionRequiredPermissions.
  ///
  /// In en, this message translates to:
  /// **'Required Permissions'**
  String get privacyPolicySectionRequiredPermissions;

  /// No description provided for @privacyPolicySectionSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get privacyPolicySectionSecurity;

  /// No description provided for @privacyPolicySectionUserRights.
  ///
  /// In en, this message translates to:
  /// **'User Rights'**
  String get privacyPolicySectionUserRights;

  /// No description provided for @privacyPolicySectionDataRetention.
  ///
  /// In en, this message translates to:
  /// **'Data Retention'**
  String get privacyPolicySectionDataRetention;

  /// No description provided for @privacyPolicySectionChildrenPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Children\'s Privacy'**
  String get privacyPolicySectionChildrenPrivacy;

  /// No description provided for @privacyPolicySectionChangesToPolicy.
  ///
  /// In en, this message translates to:
  /// **'Changes to This Policy'**
  String get privacyPolicySectionChangesToPolicy;

  /// No description provided for @privacyPolicySectionDataCollectionConsent.
  ///
  /// In en, this message translates to:
  /// **'Data Collection Consent'**
  String get privacyPolicySectionDataCollectionConsent;

  /// No description provided for @privacyPolicySectionPDPACompliance.
  ///
  /// In en, this message translates to:
  /// **'PDPA Compliance (Thailand Personal Data Protection Act)'**
  String get privacyPolicySectionPDPACompliance;

  /// No description provided for @privacyPolicySectionContactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get privacyPolicySectionContactUs;

  /// No description provided for @privacyPolicyEffectiveDate.
  ///
  /// In en, this message translates to:
  /// **'Effective Date: February 18, 2026\nLast Updated: February 26, 2026'**
  String get privacyPolicyEffectiveDate;

  /// No description provided for @termsOfServiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfServiceTitle;

  /// No description provided for @termsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'MiRO — My Intake Record Oracle'**
  String get termsSubtitle;

  /// No description provided for @termsSectionAcceptanceOfTerms.
  ///
  /// In en, this message translates to:
  /// **'Acceptance of Terms'**
  String get termsSectionAcceptanceOfTerms;

  /// No description provided for @termsSectionServiceDescription.
  ///
  /// In en, this message translates to:
  /// **'Service Description'**
  String get termsSectionServiceDescription;

  /// No description provided for @termsSectionDisclaimerOfWarranties.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer of Warranties'**
  String get termsSectionDisclaimerOfWarranties;

  /// No description provided for @termsSectionEnergySystemTerms.
  ///
  /// In en, this message translates to:
  /// **'Energy System Terms'**
  String get termsSectionEnergySystemTerms;

  /// No description provided for @termsSectionUserDataAndResponsibilities.
  ///
  /// In en, this message translates to:
  /// **'User Data and Responsibilities'**
  String get termsSectionUserDataAndResponsibilities;

  /// No description provided for @termsSectionBackupTransfer.
  ///
  /// In en, this message translates to:
  /// **'Backup & Transfer'**
  String get termsSectionBackupTransfer;

  /// No description provided for @termsSectionInAppPurchases.
  ///
  /// In en, this message translates to:
  /// **'In-App Purchases'**
  String get termsSectionInAppPurchases;

  /// No description provided for @termsSectionProhibitedUses.
  ///
  /// In en, this message translates to:
  /// **'Prohibited Uses'**
  String get termsSectionProhibitedUses;

  /// No description provided for @termsSectionIntellectualProperty.
  ///
  /// In en, this message translates to:
  /// **'Intellectual Property'**
  String get termsSectionIntellectualProperty;

  /// No description provided for @termsSectionLimitationOfLiability.
  ///
  /// In en, this message translates to:
  /// **'Limitation of Liability'**
  String get termsSectionLimitationOfLiability;

  /// No description provided for @termsSectionServiceTermination.
  ///
  /// In en, this message translates to:
  /// **'Service Termination'**
  String get termsSectionServiceTermination;

  /// No description provided for @termsSectionChangesToTerms.
  ///
  /// In en, this message translates to:
  /// **'Changes to Terms'**
  String get termsSectionChangesToTerms;

  /// No description provided for @termsSectionGoverningLaw.
  ///
  /// In en, this message translates to:
  /// **'Governing Law'**
  String get termsSectionGoverningLaw;

  /// No description provided for @termsSectionContactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get termsSectionContactUs;

  /// No description provided for @termsAcknowledgment.
  ///
  /// In en, this message translates to:
  /// **'By using MiRO, you acknowledge that you have read, understood, and agree to these Terms of Service.'**
  String get termsAcknowledgment;

  /// No description provided for @termsLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: February 26, 2026'**
  String get termsLastUpdated;

  /// No description provided for @profileAndSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile & Settings'**
  String get profileAndSettings;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorOccurred(String error);

  /// No description provided for @healthGoalsSection.
  ///
  /// In en, this message translates to:
  /// **'Health Goals'**
  String get healthGoalsSection;

  /// No description provided for @dailyGoals.
  ///
  /// In en, this message translates to:
  /// **'Daily Goals'**
  String get dailyGoals;

  /// No description provided for @chatAiModeSection.
  ///
  /// In en, this message translates to:
  /// **'Chat AI Mode'**
  String get chatAiModeSection;

  /// No description provided for @selectAiPowersChat.
  ///
  /// In en, this message translates to:
  /// **'Select which AI powers your chat'**
  String get selectAiPowersChat;

  /// No description provided for @miroAi.
  ///
  /// In en, this message translates to:
  /// **'Miro AI'**
  String get miroAi;

  /// No description provided for @miroAiSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Powered by Gemini • Multi-language • High accuracy'**
  String get miroAiSubtitle;

  /// No description provided for @localAi.
  ///
  /// In en, this message translates to:
  /// **'Local AI'**
  String get localAi;

  /// No description provided for @localAiSubtitle.
  ///
  /// In en, this message translates to:
  /// **'On-device • English only • Basic accuracy'**
  String get localAiSubtitle;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @cuisinePreferenceSection.
  ///
  /// In en, this message translates to:
  /// **'Cuisine Preference'**
  String get cuisinePreferenceSection;

  /// No description provided for @preferredCuisine.
  ///
  /// In en, this message translates to:
  /// **'Preferred Cuisine'**
  String get preferredCuisine;

  /// No description provided for @selectYourCuisine.
  ///
  /// In en, this message translates to:
  /// **'Select Your Cuisine'**
  String get selectYourCuisine;

  /// No description provided for @photoScanSection.
  ///
  /// In en, this message translates to:
  /// **'Photo Scan'**
  String get photoScanSection;

  /// No description provided for @languageSection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSection;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language / ภาษา'**
  String get languageTitle;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language / เลือกภาษา'**
  String get selectLanguage;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @systemDefaultSublabel.
  ///
  /// In en, this message translates to:
  /// **'ตามระบบ'**
  String get systemDefaultSublabel;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @englishSublabel.
  ///
  /// In en, this message translates to:
  /// **'อังกฤษ'**
  String get englishSublabel;

  /// No description provided for @thai.
  ///
  /// In en, this message translates to:
  /// **'ไทย (Thai)'**
  String get thai;

  /// No description provided for @thaiSublabel.
  ///
  /// In en, this message translates to:
  /// **'ภาษาไทย'**
  String get thaiSublabel;

  /// No description provided for @vietnamese.
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt'**
  String get vietnamese;

  /// No description provided for @vietnameseSublabel.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get vietnameseSublabel;

  /// No description provided for @indonesian.
  ///
  /// In en, this message translates to:
  /// **'Bahasa Indonesia'**
  String get indonesian;

  /// No description provided for @indonesianSublabel.
  ///
  /// In en, this message translates to:
  /// **'Indonesian'**
  String get indonesianSublabel;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get chinese;

  /// No description provided for @chineseSublabel.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get chineseSublabel;

  /// No description provided for @japanese.
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get japanese;

  /// No description provided for @japaneseSublabel.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get japaneseSublabel;

  /// No description provided for @korean.
  ///
  /// In en, this message translates to:
  /// **'한국어'**
  String get korean;

  /// No description provided for @koreanSublabel.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get koreanSublabel;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @spanishSublabel.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanishSublabel;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @frenchSublabel.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get frenchSublabel;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get german;

  /// No description provided for @germanSublabel.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get germanSublabel;

  /// No description provided for @portuguese.
  ///
  /// In en, this message translates to:
  /// **'Português'**
  String get portuguese;

  /// No description provided for @portugueseSublabel.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get portugueseSublabel;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get hindi;

  /// No description provided for @hindiSublabel.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindiSublabel;

  /// No description provided for @closeBilingual.
  ///
  /// In en, this message translates to:
  /// **'Close / ปิด'**
  String get closeBilingual;

  /// No description provided for @languageChangedTo.
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}'**
  String languageChangedTo(String language);

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSection;

  /// No description provided for @miroId.
  ///
  /// In en, this message translates to:
  /// **'MiRO ID'**
  String get miroId;

  /// No description provided for @miroIdCopied.
  ///
  /// In en, this message translates to:
  /// **'MiRO ID copied!'**
  String get miroIdCopied;

  /// No description provided for @inviteFriends.
  ///
  /// In en, this message translates to:
  /// **'Invite Friends'**
  String get inviteFriends;

  /// No description provided for @inviteFriendsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share your referral code and earn rewards!'**
  String get inviteFriendsSubtitle;

  /// No description provided for @unlimitedAiDoubleRewards.
  ///
  /// In en, this message translates to:
  /// **'Unlimited AI + Double rewards'**
  String get unlimitedAiDoubleRewards;

  /// No description provided for @plan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get plan;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @started.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get started;

  /// No description provided for @renews.
  ///
  /// In en, this message translates to:
  /// **'Renews'**
  String get renews;

  /// No description provided for @expires.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get expires;

  /// No description provided for @autoRenew.
  ///
  /// In en, this message translates to:
  /// **'Auto-Renew'**
  String get autoRenew;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @tapToManageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Tap to manage subscription'**
  String get tapToManageSubscription;

  /// No description provided for @dataSection.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get dataSection;

  /// No description provided for @backupData.
  ///
  /// In en, this message translates to:
  /// **'Backup Data'**
  String get backupData;

  /// No description provided for @backupDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Energy + Food History → save as file'**
  String get backupDataSubtitle;

  /// No description provided for @restoreFromBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore from Backup'**
  String get restoreFromBackup;

  /// No description provided for @restoreFromBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import data from backup file'**
  String get restoreFromBackupSubtitle;

  /// No description provided for @clearAllDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all data?'**
  String get clearAllDataTitle;

  /// No description provided for @clearAllDataContent.
  ///
  /// In en, this message translates to:
  /// **'All data will be deleted:\n• Food entries\n• My Meals\n• Ingredients\n• Goals\n• Personal info\n\nThis cannot be undone!'**
  String get clearAllDataContent;

  /// No description provided for @clearAllDataStorageDetails.
  ///
  /// In en, this message translates to:
  /// **'Including: Isar DB, SharedPreferences, SecureStorage'**
  String get clearAllDataStorageDetails;

  /// No description provided for @clearAllDataFactoryResetHint.
  ///
  /// In en, this message translates to:
  /// **'(Like a fresh install — use together with Factory Reset in Admin Panel)'**
  String get clearAllDataFactoryResetHint;

  /// No description provided for @allDataClearedSuccess.
  ///
  /// In en, this message translates to:
  /// **'All data cleared successfully'**
  String get allDataClearedSuccess;

  /// No description provided for @aboutSection.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutSection;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @healthDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Health Disclaimer'**
  String get healthDisclaimer;

  /// No description provided for @importantLegalInformation.
  ///
  /// In en, this message translates to:
  /// **'Important legal information'**
  String get importantLegalInformation;

  /// No description provided for @showTutorialAgain.
  ///
  /// In en, this message translates to:
  /// **'Show Tutorial Again'**
  String get showTutorialAgain;

  /// No description provided for @viewFeatureTour.
  ///
  /// In en, this message translates to:
  /// **'View feature tour'**
  String get viewFeatureTour;

  /// No description provided for @showTutorialDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Show Tutorial'**
  String get showTutorialDialogTitle;

  /// No description provided for @showTutorialDialogContent.
  ///
  /// In en, this message translates to:
  /// **'This will show the feature tour that highlights:\n\n• Energy System\n• Pull-to-Refresh Photo Scan\n• Chat with Miro AI\n\nYou will return to the Home screen.'**
  String get showTutorialDialogContent;

  /// No description provided for @showTutorialButton.
  ///
  /// In en, this message translates to:
  /// **'Show Tutorial'**
  String get showTutorialButton;

  /// No description provided for @tutorialResetMessage.
  ///
  /// In en, this message translates to:
  /// **'Tutorial reset! Go to Home screen to view it.'**
  String get tutorialResetMessage;

  /// No description provided for @foodAnalysisTutorial.
  ///
  /// In en, this message translates to:
  /// **'Food Analysis Tutorial'**
  String get foodAnalysisTutorial;

  /// No description provided for @foodAnalysisTutorialSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn how to use food analysis features'**
  String get foodAnalysisTutorialSubtitle;

  /// No description provided for @backupCreated.
  ///
  /// In en, this message translates to:
  /// **'Backup Created!'**
  String get backupCreated;

  /// No description provided for @backupCreatedContent.
  ///
  /// In en, this message translates to:
  /// **'Your backup file has been created successfully.'**
  String get backupCreatedContent;

  /// No description provided for @backupChooseDestination.
  ///
  /// In en, this message translates to:
  /// **'Where would you like to save your backup?'**
  String get backupChooseDestination;

  /// No description provided for @backupSaveToDevice.
  ///
  /// In en, this message translates to:
  /// **'Save to Device'**
  String get backupSaveToDevice;

  /// No description provided for @backupSaveToDeviceDesc.
  ///
  /// In en, this message translates to:
  /// **'Save to a folder you choose on this device'**
  String get backupSaveToDeviceDesc;

  /// No description provided for @backupShareToOther.
  ///
  /// In en, this message translates to:
  /// **'Share to Other Device'**
  String get backupShareToOther;

  /// No description provided for @backupShareToOtherDesc.
  ///
  /// In en, this message translates to:
  /// **'Send via Line, Email, Google Drive, etc.'**
  String get backupShareToOtherDesc;

  /// No description provided for @backupSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup Saved!'**
  String get backupSavedSuccess;

  /// No description provided for @backupSavedSuccessContent.
  ///
  /// In en, this message translates to:
  /// **'Your backup file has been saved to your chosen location.'**
  String get backupSavedSuccessContent;

  /// No description provided for @important.
  ///
  /// In en, this message translates to:
  /// **'Important:'**
  String get important;

  /// No description provided for @backupImportantNotes.
  ///
  /// In en, this message translates to:
  /// **'• Save this file in a safe place (Google Drive, etc.)\n• Photos are NOT included in the backup\n• Transfer Key expires in 30 days\n• Key can only be used once'**
  String get backupImportantNotes;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore Backup?'**
  String get restoreBackup;

  /// No description provided for @backupFrom.
  ///
  /// In en, this message translates to:
  /// **'Backup from:'**
  String get backupFrom;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date:'**
  String get date;

  /// No description provided for @energy.
  ///
  /// In en, this message translates to:
  /// **'Energy:'**
  String get energy;

  /// No description provided for @foodEntries.
  ///
  /// In en, this message translates to:
  /// **'Food entries:'**
  String get foodEntries;

  /// No description provided for @restoreImportant.
  ///
  /// In en, this message translates to:
  /// **'Important'**
  String get restoreImportant;

  /// No description provided for @restoreImportantNotes.
  ///
  /// In en, this message translates to:
  /// **'• Current Energy on this device will be REPLACED with Energy from backup ({energy})\n• Food entries will be MERGED (not replaced)\n• Photos are NOT included in backup\n• Transfer Key will be used (cannot be reused)'**
  String restoreImportantNotes(String energy);

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @restoreComplete.
  ///
  /// In en, this message translates to:
  /// **'Restore Complete!'**
  String get restoreComplete;

  /// No description provided for @restoreCompleteContent.
  ///
  /// In en, this message translates to:
  /// **'Your data has been restored successfully.'**
  String get restoreCompleteContent;

  /// No description provided for @newEnergyBalance.
  ///
  /// In en, this message translates to:
  /// **'New Energy Balance:'**
  String get newEnergyBalance;

  /// No description provided for @foodEntriesImported.
  ///
  /// In en, this message translates to:
  /// **'Food Entries Imported:'**
  String get foodEntriesImported;

  /// No description provided for @myMealsImported.
  ///
  /// In en, this message translates to:
  /// **'My Meals Imported:'**
  String get myMealsImported;

  /// No description provided for @appWillRefresh.
  ///
  /// In en, this message translates to:
  /// **'Your app will refresh to show the restored data.'**
  String get appWillRefresh;

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup Failed'**
  String get backupFailed;

  /// No description provided for @invalidBackupFile.
  ///
  /// In en, this message translates to:
  /// **'Invalid Backup File'**
  String get invalidBackupFile;

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore Failed'**
  String get restoreFailed;

  /// No description provided for @analyticsDataCollection.
  ///
  /// In en, this message translates to:
  /// **'Analytics Data Collection'**
  String get analyticsDataCollection;

  /// No description provided for @analyticsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Analytics enabled - ขอบคุณที่ช่วยปรับปรุงแอป'**
  String get analyticsEnabled;

  /// No description provided for @analyticsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Analytics disabled - ไม่เก็บข้อมูลการใช้งาน'**
  String get analyticsDisabled;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @enabledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enabled - ช่วยปรับปรุงประสบการณ์ใช้งาน'**
  String get enabledSubtitle;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @disabledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Disabled - ไม่เก็บข้อมูลการใช้งาน'**
  String get disabledSubtitle;

  /// No description provided for @imagesPerDay.
  ///
  /// In en, this message translates to:
  /// **'Images per day'**
  String get imagesPerDay;

  /// No description provided for @scanUpToImagesPerDay.
  ///
  /// In en, this message translates to:
  /// **'Scan up to {limit} images per day'**
  String scanUpToImagesPerDay(String limit);

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @resetScanHistory.
  ///
  /// In en, this message translates to:
  /// **'Reset Scan History'**
  String get resetScanHistory;

  /// No description provided for @resetScanHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all scanned entries and re-scan'**
  String get resetScanHistorySubtitle;

  /// No description provided for @imagesPerDayDialog.
  ///
  /// In en, this message translates to:
  /// **'Images per day'**
  String get imagesPerDayDialog;

  /// No description provided for @maxImagesPerDayDescription.
  ///
  /// In en, this message translates to:
  /// **'Maximum images to scan per day\nScans only the selected date'**
  String get maxImagesPerDayDescription;

  /// No description provided for @scanLimitSetTo.
  ///
  /// In en, this message translates to:
  /// **'Scan limit set to {limit} images per day'**
  String scanLimitSetTo(String limit);

  /// No description provided for @resetScanHistoryDialog.
  ///
  /// In en, this message translates to:
  /// **'Reset Scan History?'**
  String get resetScanHistoryDialog;

  /// No description provided for @resetScanHistoryContent.
  ///
  /// In en, this message translates to:
  /// **'All gallery-scanned food entries will be deleted.\nPull down on any date to re-scan images.'**
  String get resetScanHistoryContent;

  /// No description provided for @resetComplete.
  ///
  /// In en, this message translates to:
  /// **'Reset complete - {count} entries deleted. Pull down to re-scan.'**
  String resetComplete(String count);

  /// No description provided for @questBarStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak {days} day'**
  String questBarStreak(int days);

  /// No description provided for @questBarDaysToNextTier.
  ///
  /// In en, this message translates to:
  /// **'{days} days → {tier}'**
  String questBarDaysToNextTier(int days, String tier);

  /// No description provided for @questBarMaxTier.
  ///
  /// In en, this message translates to:
  /// **'Max Tier! 💎'**
  String get questBarMaxTier;

  /// No description provided for @questBarOfferDismissed.
  ///
  /// In en, this message translates to:
  /// **'Offer hidden'**
  String get questBarOfferDismissed;

  /// No description provided for @questBarViewOffer.
  ///
  /// In en, this message translates to:
  /// **'View Offer'**
  String get questBarViewOffer;

  /// No description provided for @questBarNoOffersNow.
  ///
  /// In en, this message translates to:
  /// **'• No offers right now'**
  String get questBarNoOffersNow;

  /// No description provided for @questBarWeeklyChallenges.
  ///
  /// In en, this message translates to:
  /// **'🎯 Weekly Challenges'**
  String get questBarWeeklyChallenges;

  /// No description provided for @questBarMilestones.
  ///
  /// In en, this message translates to:
  /// **'🏆 Milestones'**
  String get questBarMilestones;

  /// No description provided for @questBarInviteFriends.
  ///
  /// In en, this message translates to:
  /// **'👥 Invite friends & get 20E'**
  String get questBarInviteFriends;

  /// No description provided for @questBarTimeRemaining.
  ///
  /// In en, this message translates to:
  /// **'⏰ Time left {time}'**
  String questBarTimeRemaining(String time);

  /// No description provided for @questBarClaimDailyEnergy.
  ///
  /// In en, this message translates to:
  /// **'+{energy}E'**
  String questBarClaimDailyEnergy(int energy);

  /// No description provided for @questBarShareReferralError.
  ///
  /// In en, this message translates to:
  /// **'Error sharing: {error}'**
  String questBarShareReferralError(String error);

  /// No description provided for @tierCelebrationTitle.
  ///
  /// In en, this message translates to:
  /// **'{tier} Celebration 🎉'**
  String tierCelebrationTitle(String tier);

  /// No description provided for @tierCelebrationDay.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String tierCelebrationDay(int day);

  /// No description provided for @tierCelebrationExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get tierCelebrationExpired;

  /// No description provided for @tierCelebrationComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete!'**
  String get tierCelebrationComplete;

  /// No description provided for @questBarWatchAd.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad +{energy}⚡'**
  String questBarWatchAd(int energy);

  /// No description provided for @questBarAdRemaining.
  ///
  /// In en, this message translates to:
  /// **'{remaining}/{total} remaining today'**
  String questBarAdRemaining(int remaining, int total);

  /// No description provided for @questBarAdSuccess.
  ///
  /// In en, this message translates to:
  /// **'Ad watched! +{energy} Energy incoming...'**
  String questBarAdSuccess(int energy);

  /// No description provided for @questBarAdNotReady.
  ///
  /// In en, this message translates to:
  /// **'Ad not ready, please try again'**
  String get questBarAdNotReady;

  /// No description provided for @questBarDailyChallenge.
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge'**
  String get questBarDailyChallenge;

  /// No description provided for @questBarUseAi.
  ///
  /// In en, this message translates to:
  /// **'Use Energy'**
  String get questBarUseAi;

  /// No description provided for @questBarResetsMonday.
  ///
  /// In en, this message translates to:
  /// **'Resets every Monday'**
  String get questBarResetsMonday;

  /// No description provided for @questBarClaimed.
  ///
  /// In en, this message translates to:
  /// **'Claimed!'**
  String get questBarClaimed;

  /// No description provided for @questBarHideOffer.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get questBarHideOffer;

  /// No description provided for @questBarViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get questBarViewDetails;

  /// No description provided for @questBarShareText.
  ///
  /// In en, this message translates to:
  /// **'Try MiRO! AI-powered food analysis 🍔\nUse this link — you get +5 Energy, friend gets +20 Energy free!\n\n{link}'**
  String questBarShareText(String link);

  /// No description provided for @questBarShareSubject.
  ///
  /// In en, this message translates to:
  /// **'Try MiRO'**
  String get questBarShareSubject;

  /// No description provided for @claimButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Claim Daily Energy'**
  String get claimButtonTitle;

  /// No description provided for @claimButtonReceived.
  ///
  /// In en, this message translates to:
  /// **'Received +{energy}E!'**
  String claimButtonReceived(String energy);

  /// No description provided for @claimButtonAlreadyClaimed.
  ///
  /// In en, this message translates to:
  /// **'Already claimed today'**
  String get claimButtonAlreadyClaimed;

  /// No description provided for @claimButtonError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String claimButtonError(String error);

  /// No description provided for @seasonalQuestLimitedTime.
  ///
  /// In en, this message translates to:
  /// **'LIMITED TIME'**
  String get seasonalQuestLimitedTime;

  /// No description provided for @seasonalQuestDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String seasonalQuestDaysLeft(int days);

  /// No description provided for @seasonalQuestRewardDaily.
  ///
  /// In en, this message translates to:
  /// **'+{reward}E / day'**
  String seasonalQuestRewardDaily(int reward);

  /// No description provided for @seasonalQuestRewardOnce.
  ///
  /// In en, this message translates to:
  /// **'+{reward}E one-time'**
  String seasonalQuestRewardOnce(int reward);

  /// No description provided for @seasonalQuestClaimed.
  ///
  /// In en, this message translates to:
  /// **'Claimed!'**
  String get seasonalQuestClaimed;

  /// No description provided for @seasonalQuestClaimedToday.
  ///
  /// In en, this message translates to:
  /// **'Claimed today'**
  String get seasonalQuestClaimedToday;

  /// No description provided for @errorFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get errorFailed;

  /// No description provided for @errorFailedToClaim.
  ///
  /// In en, this message translates to:
  /// **'Failed to claim'**
  String get errorFailedToClaim;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorGeneric(String error);

  /// No description provided for @milestoneNoMilestonesToClaim.
  ///
  /// In en, this message translates to:
  /// **'No milestones to claim yet'**
  String get milestoneNoMilestonesToClaim;

  /// No description provided for @milestoneClaimedEnergy.
  ///
  /// In en, this message translates to:
  /// **'🎁 Claimed +{energy} Energy!'**
  String milestoneClaimedEnergy(int energy);

  /// No description provided for @milestoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get milestoneTitle;

  /// No description provided for @milestoneUseEnergyComplete.
  ///
  /// In en, this message translates to:
  /// **'Use Energy {threshold}'**
  String milestoneUseEnergyComplete(int threshold);

  /// No description provided for @milestoneNext.
  ///
  /// In en, this message translates to:
  /// **'Next: {threshold}E'**
  String milestoneNext(int threshold);

  /// No description provided for @milestoneAllComplete.
  ///
  /// In en, this message translates to:
  /// **'All milestones completed!'**
  String get milestoneAllComplete;

  /// No description provided for @noEnergyTitle.
  ///
  /// In en, this message translates to:
  /// **'Out of Energy'**
  String get noEnergyTitle;

  /// No description provided for @noEnergyContent.
  ///
  /// In en, this message translates to:
  /// **'You need 1 Energy to analyze food with AI'**
  String get noEnergyContent;

  /// No description provided for @noEnergyTip.
  ///
  /// In en, this message translates to:
  /// **'You can still log food manually (without AI) for free'**
  String get noEnergyTip;

  /// No description provided for @noEnergyLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get noEnergyLater;

  /// No description provided for @noEnergyWatchAd.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad ({remaining}/3)'**
  String noEnergyWatchAd(int remaining);

  /// No description provided for @noEnergyBuyEnergy.
  ///
  /// In en, this message translates to:
  /// **'Buy Energy'**
  String get noEnergyBuyEnergy;

  /// No description provided for @tierBronze.
  ///
  /// In en, this message translates to:
  /// **'Bronze'**
  String get tierBronze;

  /// No description provided for @tierSilver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get tierSilver;

  /// No description provided for @tierGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get tierGold;

  /// No description provided for @tierDiamond.
  ///
  /// In en, this message translates to:
  /// **'Diamond'**
  String get tierDiamond;

  /// No description provided for @tierStarter.
  ///
  /// In en, this message translates to:
  /// **'Starter'**
  String get tierStarter;

  /// No description provided for @tierUpCongratulations.
  ///
  /// In en, this message translates to:
  /// **'🎉 Congratulations!'**
  String get tierUpCongratulations;

  /// No description provided for @tierUpYouReached.
  ///
  /// In en, this message translates to:
  /// **'You reached {tier}!'**
  String tierUpYouReached(String tier);

  /// No description provided for @tierUpMotivation.
  ///
  /// In en, this message translates to:
  /// **'Track calories like a pro\nYour dream body is getting closer!'**
  String get tierUpMotivation;

  /// No description provided for @tierUpReward.
  ///
  /// In en, this message translates to:
  /// **'+{reward}E Reward!'**
  String tierUpReward(int reward);

  /// No description provided for @referralAllLevelsClaimed.
  ///
  /// In en, this message translates to:
  /// **'All levels claimed!'**
  String get referralAllLevelsClaimed;

  /// No description provided for @referralLevel.
  ///
  /// In en, this message translates to:
  /// **'Level {level}: {subtitle}'**
  String referralLevel(int level, String subtitle);

  /// No description provided for @referralProgress.
  ///
  /// In en, this message translates to:
  /// **'[{current}/{target}] (Level {level}/{total})'**
  String referralProgress(int current, int target, int level, int total);

  /// No description provided for @referralClaimedLevel.
  ///
  /// In en, this message translates to:
  /// **'🎁 Claimed Level {level}: +{reward} Energy!'**
  String referralClaimedLevel(int level, int reward);

  /// No description provided for @challengeUseAi10.
  ///
  /// In en, this message translates to:
  /// **'Use Energy 10'**
  String get challengeUseAi10;

  /// No description provided for @specifyIngredients.
  ///
  /// In en, this message translates to:
  /// **'Specify Known Ingredients'**
  String get specifyIngredients;

  /// No description provided for @specifyIngredientsOptional.
  ///
  /// In en, this message translates to:
  /// **'Specify known ingredients (optional)'**
  String get specifyIngredientsOptional;

  /// No description provided for @specifyIngredientsHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the ingredients you know, and AI will discover hidden seasonings, oils, and sauces for you.'**
  String get specifyIngredientsHint;

  /// No description provided for @sendToAi.
  ///
  /// In en, this message translates to:
  /// **'Send to AI'**
  String get sendToAi;

  /// No description provided for @reanalyzeWithIngredients.
  ///
  /// In en, this message translates to:
  /// **'Add Ingredients & Re-analyze'**
  String get reanalyzeWithIngredients;

  /// No description provided for @reanalyzeButton.
  ///
  /// In en, this message translates to:
  /// **'Re-analyze (1 Energy)'**
  String get reanalyzeButton;

  /// No description provided for @ingredientsSaved.
  ///
  /// In en, this message translates to:
  /// **'Ingredients saved'**
  String get ingredientsSaved;

  /// No description provided for @pleaseAddAtLeastOneIngredient.
  ///
  /// In en, this message translates to:
  /// **'Please add at least 1 ingredient'**
  String get pleaseAddAtLeastOneIngredient;

  /// No description provided for @hiddenIngredientsDiscovered.
  ///
  /// In en, this message translates to:
  /// **'Hidden ingredients discovered by AI'**
  String get hiddenIngredientsDiscovered;

  /// No description provided for @retroScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Recent Photos?'**
  String get retroScanTitle;

  /// No description provided for @retroScanDescription.
  ///
  /// In en, this message translates to:
  /// **'We can scan your photos from the last 7 days to automatically find food photos and add them to your diary.'**
  String get retroScanDescription;

  /// No description provided for @retroScanNote.
  ///
  /// In en, this message translates to:
  /// **'Only food photos are detected — other photos are ignored. No photos leave your device.'**
  String get retroScanNote;

  /// No description provided for @retroScanStart.
  ///
  /// In en, this message translates to:
  /// **'Scan My Photos'**
  String get retroScanStart;

  /// No description provided for @retroScanSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get retroScanSkip;

  /// No description provided for @retroScanInProgress.
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get retroScanInProgress;

  /// No description provided for @retroScanTagline.
  ///
  /// In en, this message translates to:
  /// **'MiRO is transforming your\nfood photos into health data.'**
  String get retroScanTagline;

  /// No description provided for @retroScanFetchingPhotos.
  ///
  /// In en, this message translates to:
  /// **'Fetching recent photos...'**
  String get retroScanFetchingPhotos;

  /// No description provided for @retroScanAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Detecting food photos...'**
  String get retroScanAnalyzing;

  /// No description provided for @retroScanPhotosFound.
  ///
  /// In en, this message translates to:
  /// **'{count} photos found in last 7 days'**
  String retroScanPhotosFound(int count);

  /// No description provided for @retroScanCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Complete!'**
  String get retroScanCompleteTitle;

  /// No description provided for @retroScanCompleteDesc.
  ///
  /// In en, this message translates to:
  /// **'Found {count} food photos! They\'ve been added to your timeline, ready for AI analysis.'**
  String retroScanCompleteDesc(int count);

  /// No description provided for @retroScanNoResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'No Food Photos Found'**
  String get retroScanNoResultsTitle;

  /// No description provided for @retroScanNoResultsDesc.
  ///
  /// In en, this message translates to:
  /// **'No food photos detected in the last 7 days. Try taking a photo of your next meal!'**
  String get retroScanNoResultsDesc;

  /// No description provided for @retroScanAnalyzeHint.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Analyze All\" on your timeline to get AI nutrition analysis for these entries.'**
  String get retroScanAnalyzeHint;

  /// No description provided for @retroScanDone.
  ///
  /// In en, this message translates to:
  /// **'Got it!'**
  String get retroScanDone;

  /// No description provided for @welcomeEndTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to MiRO!'**
  String get welcomeEndTitle;

  /// No description provided for @welcomeEndMessage.
  ///
  /// In en, this message translates to:
  /// **'MiRO is at your service.'**
  String get welcomeEndMessage;

  /// No description provided for @welcomeEndJourney.
  ///
  /// In en, this message translates to:
  /// **'Have a nice journey together!!'**
  String get welcomeEndJourney;

  /// No description provided for @welcomeEndStart.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Start!'**
  String get welcomeEndStart;

  /// No description provided for @greetingCalorieSummary.
  ///
  /// In en, this message translates to:
  /// **'Hi! How can I help you today? You still have {remaining} kcal left. So far: Protein {protein}g, Carbs {carbs}g, Fat {fat}g. Tell me what you ate — list everything by meal and I\'ll log them all for you. More Detail more precise!!'**
  String greetingCalorieSummary(int remaining, int protein, int carbs, int fat);

  /// No description provided for @greetingCuisineTip.
  ///
  /// In en, this message translates to:
  /// **'Your preferred cuisine is set to {cuisine}. You can change it in Settings anytime!'**
  String greetingCuisineTip(String cuisine);

  /// No description provided for @greetingEnergyTip.
  ///
  /// In en, this message translates to:
  /// **'You have {balance} Energy available. Don\'t forget to claim your daily streak reward on the Energy badge!'**
  String greetingEnergyTip(int balance);

  /// No description provided for @greetingRenamePhotoTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: You can rename food photos to help MiRO analyze more accurately!'**
  String get greetingRenamePhotoTip;

  /// No description provided for @greetingAddIngredientsTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: You can add ingredients you\'re sure about before sending to MiRO for analysis. I\'ll figure out all the boring little details for you!'**
  String get greetingAddIngredientsTip;

  /// No description provided for @greetingBackupReminder.
  ///
  /// In en, this message translates to:
  /// **'Hey boss! You haven\'t backed up your data for {days} days. I recommend backing up in Settings — your data is stored locally and I can\'t recover it if something happens!'**
  String greetingBackupReminder(int days);

  /// No description provided for @greetingFallback.
  ///
  /// In en, this message translates to:
  /// **'Hi! How can I help you today? Tell me what you ate!'**
  String get greetingFallback;

  /// No description provided for @saveFoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Save Food'**
  String get saveFoodTitle;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @analyzingTitle.
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get analyzingTitle;

  /// No description provided for @analyzingWarningContent.
  ///
  /// In en, this message translates to:
  /// **'AI is analyzing food\n\nIf you leave now, the analysis result will be lost and you will need to re-analyze (costs Energy again)'**
  String get analyzingWarningContent;

  /// No description provided for @waitButton.
  ///
  /// In en, this message translates to:
  /// **'Wait'**
  String get waitButton;

  /// No description provided for @exitButton.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exitButton;

  /// No description provided for @amountAutoAdjust.
  ///
  /// In en, this message translates to:
  /// **'Change → calories adjust automatically'**
  String get amountAutoAdjust;

  /// No description provided for @processingImageData.
  ///
  /// In en, this message translates to:
  /// **'PROCESSING IMAGE DATA...'**
  String get processingImageData;

  /// No description provided for @unableToAnalyzeTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to analyze'**
  String get unableToAnalyzeTitle;

  /// No description provided for @tryAgainButton.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgainButton;

  /// No description provided for @aiAnalyzedConfidence.
  ///
  /// In en, this message translates to:
  /// **'AI Analyzed ({confidence}% confidence)'**
  String aiAnalyzedConfidence(String confidence);

  /// No description provided for @analyzingButton.
  ///
  /// In en, this message translates to:
  /// **'ANALYZING...'**
  String get analyzingButton;

  /// No description provided for @aiAnalysisButton.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis'**
  String get aiAnalysisButton;

  /// No description provided for @manualInputHint.
  ///
  /// In en, this message translates to:
  /// **'Enter food details below or use AI analysis for automatic nutrition estimation'**
  String get manualInputHint;

  /// No description provided for @caloriesTitle.
  ///
  /// In en, this message translates to:
  /// **'CALORIES'**
  String get caloriesTitle;

  /// No description provided for @macrosTitle.
  ///
  /// In en, this message translates to:
  /// **'Macros'**
  String get macrosTitle;

  /// No description provided for @mealTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Meal Type'**
  String get mealTypeTitle;

  /// No description provided for @ingredientsTitle.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredientsTitle;

  /// Subtitle hint on collapsed ingredients section
  ///
  /// In en, this message translates to:
  /// **'Tap to view and edit'**
  String get ingredientsTapToExpand;

  /// No description provided for @pleaseEnterFoodNameShort.
  ///
  /// In en, this message translates to:
  /// **'Please enter food name'**
  String get pleaseEnterFoodNameShort;

  /// No description provided for @foodPendingAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Food (pending analysis)'**
  String get foodPendingAnalysis;

  /// No description provided for @unableToAnalyzeImage.
  ///
  /// In en, this message translates to:
  /// **'Unable to analyze image'**
  String get unableToAnalyzeImage;

  /// No description provided for @foodSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Food saved successfully!'**
  String get foodSavedSuccess;

  /// No description provided for @baseInfo.
  ///
  /// In en, this message translates to:
  /// **'Base: {calories} kcal / 1 {unit} (P:{protein}g C:{carbs}g F:{fat}g)'**
  String baseInfo(
      String calories, String unit, String protein, String carbs, String fat);

  /// No description provided for @editMealTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Meal'**
  String get editMealTitle;

  /// No description provided for @createNewMealTitle.
  ///
  /// In en, this message translates to:
  /// **'Create New Meal'**
  String get createNewMealTitle;

  /// No description provided for @mealNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Meal Name *'**
  String get mealNameLabel;

  /// No description provided for @mealNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Pad Krapow with fried egg'**
  String get mealNameHint;

  /// No description provided for @servingSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Serving Size *'**
  String get servingSizeLabel;

  /// No description provided for @unitRequired.
  ///
  /// In en, this message translates to:
  /// **'Unit *'**
  String get unitRequired;

  /// No description provided for @ingredientsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredientsSectionTitle;

  /// No description provided for @aiAllButton.
  ///
  /// In en, this message translates to:
  /// **'AI All'**
  String get aiAllButton;

  /// No description provided for @addButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addButton;

  /// No description provided for @noIngredientsHint.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Add\" button to add ingredients\nOr enter total nutrition below'**
  String get noIngredientsHint;

  /// No description provided for @totalNutritionTitle.
  ///
  /// In en, this message translates to:
  /// **'Total Nutrition'**
  String get totalNutritionTitle;

  /// No description provided for @saveChangesButton.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChangesButton;

  /// No description provided for @saveMealButton.
  ///
  /// In en, this message translates to:
  /// **'Save Meal'**
  String get saveMealButton;

  /// No description provided for @kcalAutoCalculated.
  ///
  /// In en, this message translates to:
  /// **'kcal auto-calculated'**
  String get kcalAutoCalculated;

  /// No description provided for @typeIngredientNameHint.
  ///
  /// In en, this message translates to:
  /// **'Type ingredient name...'**
  String get typeIngredientNameHint;

  /// No description provided for @searchNutritionWithAi.
  ///
  /// In en, this message translates to:
  /// **'Search nutrition with AI'**
  String get searchNutritionWithAi;

  /// No description provided for @pleaseEnterIngredientFirst.
  ///
  /// In en, this message translates to:
  /// **'Please enter ingredient name first'**
  String get pleaseEnterIngredientFirst;

  /// No description provided for @reAnalyzeQuestion.
  ///
  /// In en, this message translates to:
  /// **'Re-analyze?'**
  String get reAnalyzeQuestion;

  /// No description provided for @reAnalyzeContent.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" already has nutrition data.\n\nAnalyzing again will use 1 Energy.\n\nContinue?'**
  String reAnalyzeContent(String name);

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @reAnalyzeEnergy.
  ///
  /// In en, this message translates to:
  /// **'Re-analyze (1 Energy)'**
  String get reAnalyzeEnergy;

  /// No description provided for @amountNotEntered.
  ///
  /// In en, this message translates to:
  /// **'Amount not entered'**
  String get amountNotEntered;

  /// No description provided for @amountNotEnteredContent.
  ///
  /// In en, this message translates to:
  /// **'Please enter amount for \"{name}\" first\ne.g. 100 (grams), 1 (piece), 200 (ml)\n\nOr use default 100 g?'**
  String amountNotEnteredContent(String name);

  /// No description provided for @enterManually.
  ///
  /// In en, this message translates to:
  /// **'Enter manually'**
  String get enterManually;

  /// No description provided for @use100g.
  ///
  /// In en, this message translates to:
  /// **'Use 100 g'**
  String get use100g;

  /// No description provided for @aiAnalyzeAllTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Analyze All'**
  String get aiAnalyzeAllTitle;

  /// No description provided for @aiAnalyzeAllContent.
  ///
  /// In en, this message translates to:
  /// **'Will analyze {count} items:\n{names}\n\nThis will use {count} Energy ({count} × 1 Energy)\n\nContinue?'**
  String aiAnalyzeAllContent(String count, String names);

  /// No description provided for @analyzeCountEnergy.
  ///
  /// In en, this message translates to:
  /// **'Analyze ({count} Energy)'**
  String analyzeCountEnergy(String count);

  /// No description provided for @noIngredientsNeedLookup.
  ///
  /// In en, this message translates to:
  /// **'No ingredients need nutrition lookup'**
  String get noIngredientsNeedLookup;

  /// No description provided for @someMissingAmount.
  ///
  /// In en, this message translates to:
  /// **'Some ingredients missing amount'**
  String get someMissingAmount;

  /// No description provided for @someMissingAmountContent.
  ///
  /// In en, this message translates to:
  /// **'The following items are missing amounts:\n{names}\n\nPlease enter amounts for accurate results\nOr use default 100 g for all items?'**
  String someMissingAmountContent(String names);

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @searchSuccessCount.
  ///
  /// In en, this message translates to:
  /// **'Search successful: {success}/{total} items'**
  String searchSuccessCount(String success, String total);

  /// No description provided for @pleaseEnterMealName.
  ///
  /// In en, this message translates to:
  /// **'Please enter meal name'**
  String get pleaseEnterMealName;

  /// No description provided for @pleaseEnterValidServing.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid serving size'**
  String get pleaseEnterValidServing;

  /// No description provided for @addSubIngredientButton.
  ///
  /// In en, this message translates to:
  /// **'Add Sub-ingredient'**
  String get addSubIngredientButton;

  /// No description provided for @subIngredientsCount.
  ///
  /// In en, this message translates to:
  /// **'Sub-ingredients ({count})'**
  String subIngredientsCount(String count);

  /// No description provided for @subIngredientNameHintCreate.
  ///
  /// In en, this message translates to:
  /// **'Sub-ingredient name'**
  String get subIngredientNameHintCreate;

  /// No description provided for @editSubIngredientHint.
  ///
  /// In en, this message translates to:
  /// **'Edit sub-ingredient amounts to adjust nutrition'**
  String get editSubIngredientHint;

  /// No description provided for @pleaseEnterSubFirst.
  ///
  /// In en, this message translates to:
  /// **'Please enter sub-ingredient name first'**
  String get pleaseEnterSubFirst;

  /// No description provided for @aiAnalyzedEnergy.
  ///
  /// In en, this message translates to:
  /// **'AI analyzed \"{name}\" (-1 Energy)'**
  String aiAnalyzedEnergy(String name);

  /// No description provided for @couldNotAnalyzeSubIngredient.
  ///
  /// In en, this message translates to:
  /// **'Could not analyze sub-ingredient'**
  String get couldNotAnalyzeSubIngredient;

  /// No description provided for @ingredientSaved.
  ///
  /// In en, this message translates to:
  /// **'{name} ({amount} {unit}): {calories} kcal — ingredient saved'**
  String ingredientSaved(
      String name, String amount, String unit, String calories);

  /// No description provided for @baseNutritionInfo.
  ///
  /// In en, this message translates to:
  /// **'Base: {calories} kcal / {amount} {unit}'**
  String baseNutritionInfo(String calories, String amount, String unit);

  /// Error message when user sends too many food items in chat at once (HTTP 422/413)
  ///
  /// In en, this message translates to:
  /// **'List is too long. Could you split it into 2-3 items? 🙏\n\nYour Energy has not been deducted.'**
  String get chatContentTooLongError;

  /// No description provided for @analyzeFoodImageTitle.
  ///
  /// In en, this message translates to:
  /// **'Analyze Food Image'**
  String get analyzeFoodImageTitle;

  /// No description provided for @foodNameImprovesAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Providing food name & quantity improves AI accuracy.'**
  String get foodNameImprovesAccuracy;

  /// No description provided for @foodNameQuantityAndModeImprovesAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Providing food name, quantity, and choosing if it\'s food or product will improve AI accuracy.'**
  String get foodNameQuantityAndModeImprovesAccuracy;

  /// No description provided for @hideDetails.
  ///
  /// In en, this message translates to:
  /// **'Hide details'**
  String get hideDetails;

  /// No description provided for @showDetails.
  ///
  /// In en, this message translates to:
  /// **'Show details'**
  String get showDetails;

  /// No description provided for @searchModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Search Mode'**
  String get searchModeLabel;

  /// No description provided for @normalFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get normalFood;

  /// No description provided for @normalFoodDesc.
  ///
  /// In en, this message translates to:
  /// **'Regular home-cooked food'**
  String get normalFoodDesc;

  /// No description provided for @packagedProduct.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get packagedProduct;

  /// No description provided for @packagedProductDesc.
  ///
  /// In en, this message translates to:
  /// **'Packaged with nutrition label'**
  String get packagedProductDesc;

  /// No description provided for @saveAndAnalyzeButton.
  ///
  /// In en, this message translates to:
  /// **'Analyze'**
  String get saveAndAnalyzeButton;

  /// No description provided for @saveWithoutAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveWithoutAnalysis;

  /// No description provided for @nutritionSection.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutritionSection;

  /// No description provided for @nutritionSectionHint.
  ///
  /// In en, this message translates to:
  /// **'Enter 0 if unknown'**
  String get nutritionSectionHint;

  /// No description provided for @quickEditFoodName.
  ///
  /// In en, this message translates to:
  /// **'Edit name'**
  String get quickEditFoodName;

  /// No description provided for @quickEditCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get quickEditCancel;

  /// No description provided for @quickEditSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get quickEditSave;

  /// No description provided for @mealSuggestionsToggle.
  ///
  /// In en, this message translates to:
  /// **'Meal Suggestions'**
  String get mealSuggestionsToggle;

  /// No description provided for @mealSuggestionsOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get mealSuggestionsOn;

  /// No description provided for @mealSuggestionsOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get mealSuggestionsOff;

  /// No description provided for @basicMode.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get basicMode;

  /// No description provided for @proMode.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get proMode;

  /// No description provided for @sandboxEmpty.
  ///
  /// In en, this message translates to:
  /// **'No food items yet. Chat, snap a photo, or tap + to add!'**
  String get sandboxEmpty;

  /// No description provided for @deleteSelected.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteSelected;

  /// No description provided for @useProModeForDetail.
  ///
  /// In en, this message translates to:
  /// **'For detailed editing, switch to Pro mode.'**
  String get useProModeForDetail;

  /// No description provided for @quickAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Add'**
  String get quickAddTitle;

  /// No description provided for @quickAddHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Pad Thai, Rice...'**
  String get quickAddHint;

  /// No description provided for @quickCalButton.
  ///
  /// In en, this message translates to:
  /// **'+ cal'**
  String get quickCalButton;

  /// No description provided for @quickCalTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Calorie'**
  String get quickCalTitle;

  /// No description provided for @quickCalHint.
  ///
  /// In en, this message translates to:
  /// **'Enter calories (kcal)'**
  String get quickCalHint;

  /// No description provided for @quickCalSaved.
  ///
  /// In en, this message translates to:
  /// **'Quick Cal {kcal} kcal'**
  String quickCalSaved(int kcal);

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @addToSandbox.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addToSandbox;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @longPressToSelect.
  ///
  /// In en, this message translates to:
  /// **'Long-press to select items'**
  String get longPressToSelect;

  /// No description provided for @healthSyncSection.
  ///
  /// In en, this message translates to:
  /// **'Health Sync'**
  String get healthSyncSection;

  /// No description provided for @healthSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync with Health App'**
  String get healthSyncTitle;

  /// No description provided for @healthSyncSubtitleOn.
  ///
  /// In en, this message translates to:
  /// **'Food entries synced • Active energy included'**
  String get healthSyncSubtitleOn;

  /// No description provided for @healthSyncSubtitleOff.
  ///
  /// In en, this message translates to:
  /// **'Tap to connect Apple Health / Health Connect'**
  String get healthSyncSubtitleOff;

  /// No description provided for @healthSyncEnabled.
  ///
  /// In en, this message translates to:
  /// **'Health sync enabled'**
  String get healthSyncEnabled;

  /// No description provided for @healthSyncDisabled.
  ///
  /// In en, this message translates to:
  /// **'Health sync disabled'**
  String get healthSyncDisabled;

  /// No description provided for @healthSyncPermissionDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get healthSyncPermissionDeniedTitle;

  /// No description provided for @healthSyncPermissionDeniedMessage.
  ///
  /// In en, this message translates to:
  /// **'You previously denied health data access.\nPlease enable it in your device settings.'**
  String get healthSyncPermissionDeniedMessage;

  /// No description provided for @healthSyncGoToSettings.
  ///
  /// In en, this message translates to:
  /// **'Go to Settings'**
  String get healthSyncGoToSettings;

  /// No description provided for @healthSyncActiveEnergyValue.
  ///
  /// In en, this message translates to:
  /// **'+{value} kcal burned today'**
  String healthSyncActiveEnergyValue(String value);

  /// No description provided for @healthSyncNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Health Connect is not available on this device. Please install the Health Connect app.'**
  String get healthSyncNotAvailable;

  /// No description provided for @healthSyncFoodSynced.
  ///
  /// In en, this message translates to:
  /// **'Food synced to Health App'**
  String get healthSyncFoodSynced;

  /// No description provided for @healthSyncFoodDeletedFromHealth.
  ///
  /// In en, this message translates to:
  /// **'Food removed from Health App'**
  String get healthSyncFoodDeletedFromHealth;

  /// No description provided for @bmrSettingTitle.
  ///
  /// In en, this message translates to:
  /// **'BMR (Basal Metabolic Rate)'**
  String get bmrSettingTitle;

  /// No description provided for @bmrSettingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Used to estimate active energy from total burned'**
  String get bmrSettingSubtitle;

  /// No description provided for @bmrDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Set your BMR'**
  String get bmrDialogTitle;

  /// No description provided for @bmrDialogDescription.
  ///
  /// In en, this message translates to:
  /// **'MiRO uses BMR to subtract resting energy from total calories burned, showing only your active energy. Default is 1500 kcal/day. You can find your BMR from fitness apps or online calculators.'**
  String get bmrDialogDescription;

  /// No description provided for @healthSyncEnabledBmrHint.
  ///
  /// In en, this message translates to:
  /// **'Health sync enabled. BMR default: 1500 kcal/day — adjust in Settings if needed.'**
  String get healthSyncEnabledBmrHint;

  /// No description provided for @privacyPolicySectionHealthData.
  ///
  /// In en, this message translates to:
  /// **'Health Data Integration'**
  String get privacyPolicySectionHealthData;

  /// No description provided for @termsSectionHealthDataSync.
  ///
  /// In en, this message translates to:
  /// **'Health Data Synchronization'**
  String get termsSectionHealthDataSync;

  /// No description provided for @tdeeLabel.
  ///
  /// In en, this message translates to:
  /// **'TDEE (Total Daily Energy Expenditure)'**
  String get tdeeLabel;

  /// No description provided for @tdeeHint.
  ///
  /// In en, this message translates to:
  /// **'Your estimated daily burn. Use the calculator below or enter manually.'**
  String get tdeeHint;

  /// No description provided for @tdeeCalcTitle.
  ///
  /// In en, this message translates to:
  /// **'TDEE / BMR Calculator'**
  String get tdeeCalcTitle;

  /// No description provided for @tdeeCalcPrivacy.
  ///
  /// In en, this message translates to:
  /// **'This is a calculator only — your data is NOT stored.'**
  String get tdeeCalcPrivacy;

  /// No description provided for @tdeeCalcGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get tdeeCalcGender;

  /// No description provided for @tdeeCalcMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get tdeeCalcMale;

  /// No description provided for @tdeeCalcFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get tdeeCalcFemale;

  /// No description provided for @tdeeCalcAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get tdeeCalcAge;

  /// No description provided for @tdeeCalcWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get tdeeCalcWeight;

  /// No description provided for @tdeeCalcHeight.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get tdeeCalcHeight;

  /// No description provided for @tdeeCalcWeightLbs.
  ///
  /// In en, this message translates to:
  /// **'Weight (lbs)'**
  String get tdeeCalcWeightLbs;

  /// No description provided for @tdeeCalcHeightIn.
  ///
  /// In en, this message translates to:
  /// **'Height (in)'**
  String get tdeeCalcHeightIn;

  /// No description provided for @tdeeCalcUnit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get tdeeCalcUnit;

  /// No description provided for @tdeeCalcUnitMetric.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get tdeeCalcUnitMetric;

  /// No description provided for @tdeeCalcUnitImperial.
  ///
  /// In en, this message translates to:
  /// **'Imperial'**
  String get tdeeCalcUnitImperial;

  /// No description provided for @tdeeCalcActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity Level'**
  String get tdeeCalcActivity;

  /// No description provided for @tdeeCalcActivitySedentary.
  ///
  /// In en, this message translates to:
  /// **'Sedentary (office work)'**
  String get tdeeCalcActivitySedentary;

  /// No description provided for @tdeeCalcActivityLight.
  ///
  /// In en, this message translates to:
  /// **'Light (1-2 days/week)'**
  String get tdeeCalcActivityLight;

  /// No description provided for @tdeeCalcActivityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate (3-5 days/week)'**
  String get tdeeCalcActivityModerate;

  /// No description provided for @tdeeCalcActivityActive.
  ///
  /// In en, this message translates to:
  /// **'Active (6-7 days/week)'**
  String get tdeeCalcActivityActive;

  /// No description provided for @tdeeCalcActivityVeryActive.
  ///
  /// In en, this message translates to:
  /// **'Very Active (athlete)'**
  String get tdeeCalcActivityVeryActive;

  /// No description provided for @tdeeCalcResult.
  ///
  /// In en, this message translates to:
  /// **'Your estimated values'**
  String get tdeeCalcResult;

  /// No description provided for @tdeeCalcBmrResult.
  ///
  /// In en, this message translates to:
  /// **'BMR {value} kcal/day'**
  String tdeeCalcBmrResult(int value);

  /// No description provided for @tdeeCalcTdeeResult.
  ///
  /// In en, this message translates to:
  /// **'TDEE {value} kcal/day'**
  String tdeeCalcTdeeResult(int value);

  /// No description provided for @tdeeCalcApplyTdee.
  ///
  /// In en, this message translates to:
  /// **'Use TDEE as Calorie Goal'**
  String get tdeeCalcApplyTdee;

  /// No description provided for @tdeeCalcApplyBmr.
  ///
  /// In en, this message translates to:
  /// **'Use BMR for Health Sync'**
  String get tdeeCalcApplyBmr;

  /// No description provided for @tdeeCalcApplyBoth.
  ///
  /// In en, this message translates to:
  /// **'Apply Both'**
  String get tdeeCalcApplyBoth;

  /// No description provided for @tdeeCalcApplied.
  ///
  /// In en, this message translates to:
  /// **'Applied!'**
  String get tdeeCalcApplied;

  /// No description provided for @tdeeCalcBmrExplain.
  ///
  /// In en, this message translates to:
  /// **'BMR = energy your body uses at rest'**
  String get tdeeCalcBmrExplain;

  /// No description provided for @tdeeCalcTdeeExplain.
  ///
  /// In en, this message translates to:
  /// **'TDEE = BMR + daily activity'**
  String get tdeeCalcTdeeExplain;

  /// No description provided for @dailyBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily Balance'**
  String get dailyBalanceLabel;

  /// No description provided for @intakeLabel.
  ///
  /// In en, this message translates to:
  /// **'Intake'**
  String get intakeLabel;

  /// No description provided for @burnedLabel.
  ///
  /// In en, this message translates to:
  /// **'Burned'**
  String get burnedLabel;

  /// No description provided for @subscriptionAutoRenew.
  ///
  /// In en, this message translates to:
  /// **'Auto-Renew'**
  String get subscriptionAutoRenew;

  /// No description provided for @subscriptionAutoRenewOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get subscriptionAutoRenewOn;

  /// No description provided for @subscriptionAutoRenewOff.
  ///
  /// In en, this message translates to:
  /// **'Off — expires at end of period'**
  String get subscriptionAutoRenewOff;

  /// No description provided for @subscriptionManagedByAppStore.
  ///
  /// In en, this message translates to:
  /// **'Subscription is managed through the App Store'**
  String get subscriptionManagedByAppStore;

  /// No description provided for @subscriptionManagedByPlayStore.
  ///
  /// In en, this message translates to:
  /// **'Subscription is managed through Google Play'**
  String get subscriptionManagedByPlayStore;

  /// No description provided for @subscriptionCannotLoadPrices.
  ///
  /// In en, this message translates to:
  /// **'Unable to load prices from the Store right now'**
  String get subscriptionCannotLoadPrices;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'de',
        'en',
        'es',
        'fr',
        'hi',
        'id',
        'ja',
        'ko',
        'pt',
        'th',
        'vi',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return L10nDe();
    case 'en':
      return L10nEn();
    case 'es':
      return L10nEs();
    case 'fr':
      return L10nFr();
    case 'hi':
      return L10nHi();
    case 'id':
      return L10nId();
    case 'ja':
      return L10nJa();
    case 'ko':
      return L10nKo();
    case 'pt':
      return L10nPt();
    case 'th':
      return L10nTh();
    case 'vi':
      return L10nVi();
    case 'zh':
      return L10nZh();
  }

  throw FlutterError(
      'L10n.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
