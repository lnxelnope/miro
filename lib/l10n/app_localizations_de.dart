// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class L10nDe extends L10n {
  L10nDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'MiRO';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Stornieren';

  @override
  String get delete => 'Löschen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get search => 'Suchen';

  @override
  String get loading => 'Laden...';

  @override
  String get error => 'Es ist ein Fehler aufgetreten';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get close => 'Schließen';

  @override
  String get done => 'Erledigt';

  @override
  String get next => 'Nächste';

  @override
  String get skip => 'Überspringen';

  @override
  String get retry => 'Wiederholen';

  @override
  String get ok => 'OK';

  @override
  String get foodName => 'Lebensmittelname';

  @override
  String get calories => 'Kalorien';

  @override
  String get protein => 'Protein';

  @override
  String get carbs => 'Kohlenhydrate';

  @override
  String get fat => 'Fett';

  @override
  String get servingSize => 'Portionsgröße';

  @override
  String get servingUnit => 'Einheit';

  @override
  String get kcal => 'kcal';

  @override
  String get mealBreakfast => 'Frühstück';

  @override
  String get mealLunch => 'Mittagessen';

  @override
  String get mealDinner => 'Abendessen';

  @override
  String get mealSnack => 'Snack';

  @override
  String get todaySummary => 'Die heutige Zusammenfassung';

  @override
  String dateSummary(String date) {
    return 'Zusammenfassung für $date';
  }

  @override
  String get savedSuccess => 'Erfolgreich gespeichert';

  @override
  String get deletedSuccess => 'Erfolgreich gelöscht';

  @override
  String get pleaseEnterFoodName => 'Bitte geben Sie den Lebensmittelnamen ein';

  @override
  String get noDataYet => 'Noch keine Daten';

  @override
  String get addFood => 'Essen hinzufügen';

  @override
  String get editFood => 'Essen bearbeiten';

  @override
  String get deleteFood => 'Lebensmittel löschen';

  @override
  String get deleteConfirm => 'Löschen bestätigen?';

  @override
  String get foodLoggedSuccess => 'Essen protokolliert!';

  @override
  String get noApiKey => 'Bitte richten Sie Gemini API Key ein';

  @override
  String get noApiKeyDescription =>
      'Gehen Sie zum Einrichten zu Profile → API Settings';

  @override
  String get apiKeyTitle => 'Einrichten Gemini API Key';

  @override
  String get apiKeyRequired => 'API Key erforderlich';

  @override
  String get apiKeyFreeNote => 'Die Nutzung von Gemini API ist kostenlos';

  @override
  String get apiKeySetup => 'API Key einrichten';

  @override
  String get testConnection => 'Testverbindung';

  @override
  String get connectionSuccess => 'Erfolgreich verbunden! Gebrauchsfertig';

  @override
  String get connectionFailed => 'Verbindung fehlgeschlagen';

  @override
  String get pasteKey => 'Paste';

  @override
  String get deleteKey => 'API Key löschen';

  @override
  String get openAiStudio => 'Öffnen Sie Google AI Studio';

  @override
  String get chatHint => 'Sagen Sie Miro z.B. „Gebratener Reis“...';

  @override
  String get chatFoodSaved => 'Essen protokolliert!';

  @override
  String chatFoodSavedDetail(
      String name, String serving, String unit, String cal) {
    return '$name $serving $unit\n$cal kcal';
  }

  @override
  String get featureNotAvailable =>
      'Leider ist diese Funktion noch nicht verfügbar';

  @override
  String get goalCalories => 'Kalorien/Tag';

  @override
  String get goalProtein => 'Protein/Tag';

  @override
  String get goalCarbs => 'Kohlenhydrate/Tag';

  @override
  String get goalFat => 'Fett/Tag';

  @override
  String get goalWater => 'Wasser/Tag';

  @override
  String get healthGoals => 'Gesundheitsziele';

  @override
  String get profile => 'ProDatei';

  @override
  String get settings => 'Einstellungen';

  @override
  String get privacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get termsOfService => 'Nutzungsbedingungen';

  @override
  String get clearAllData => 'Alle Daten löschen';

  @override
  String get clearAllDataConfirm =>
      'Alle Daten werden gelöscht. Dies kann nicht rückgängig gemacht werden!';

  @override
  String get about => 'Um';

  @override
  String get language => 'Sprache';

  @override
  String get upgradePro => 'Upgrade auf Pro';

  @override
  String get proUnlocked => 'MiRO Pro';

  @override
  String get proDescription => 'Unbegrenzte KI-Lebensmittelanalyse';

  @override
  String aiRemaining(int remaining, int total) {
    return 'KI-Analyse: $remaining/$total verbleiben heute';
  }

  @override
  String get aiLimitReached => 'KI-Grenze für heute erreicht (3/3)';

  @override
  String get restorePurchase => 'Kauf wiederherstellen';

  @override
  String get myMeals => 'Meine Mahlzeiten:';

  @override
  String get createMeal => 'Mahlzeit erstellen';

  @override
  String get ingredients => 'Zutaten';

  @override
  String get searchFood => 'Essen suchen';

  @override
  String get analyzing => 'Analysieren...';

  @override
  String get analyzeWithAi => 'Analysieren Sie mit KI';

  @override
  String get analysisComplete => 'Analyse abgeschlossen';

  @override
  String get timeline => 'Zeitleiste';

  @override
  String get diet => 'Diät';

  @override
  String get quickAdd => 'Schnell hinzufügen';

  @override
  String get welcomeTitle => 'MiRO';

  @override
  String get welcomeSubtitle => 'Einfache Lebensmittelprotokollierung mit KI';

  @override
  String get onboardingFeature1 => 'Machen Sie ein Foto';

  @override
  String get onboardingFeature1Desc => 'KI berechnet Kalorien automatisch';

  @override
  String get onboardingFeature2 =>
      'Geben Sie Folgendes ein, um sich zu protokollieren';

  @override
  String get onboardingFeature2Desc =>
      'Sagen Sie „hatte gebratenen Reis“ und es wird protokolliert';

  @override
  String get onboardingFeature3 => 'Tägliche Zusammenfassung';

  @override
  String get onboardingFeature3Desc =>
      'Verfolgen Sie kcal, Protein, Kohlenhydrate, Fett';

  @override
  String get basicInfo => 'Grundlegende Informationen';

  @override
  String get basicInfoDesc =>
      'Um Ihre empfohlenen täglichen Kalorien zu berechnen';

  @override
  String get gender => 'Geschlecht';

  @override
  String get male => 'Männlich';

  @override
  String get female => 'Weiblich';

  @override
  String get age => 'Alter';

  @override
  String get weight => 'Gewicht';

  @override
  String get height => 'Höhe';

  @override
  String get activityLevel => 'Aktivitätsniveau';

  @override
  String tdeeResult(int kcal) {
    return 'Ihr TDEE: $kcal kcal/Tag';
  }

  @override
  String get setupAiTitle => 'Richten Sie Gemini AI ein';

  @override
  String get setupAiDesc =>
      'Machen Sie ein Foto und die KI analysiert es automatisch';

  @override
  String get setupNow => 'Jetzt einrichten';

  @override
  String get skipForNow => 'Überspringen Sie es vorerst';

  @override
  String get errorTimeout =>
      'Verbindungszeitüberschreitung – bitte versuchen Sie es erneut';

  @override
  String get errorInvalidKey =>
      'Ungültiger API Key – überprüfen Sie Ihre Einstellungen';

  @override
  String get errorNoInternet => 'Keine Internetverbindung';

  @override
  String get errorGeneral =>
      'Es ist ein Fehler aufgetreten. Bitte versuchen Sie es erneut';

  @override
  String get errorQuotaExceeded =>
      'API-Kontingent überschritten – bitte warten Sie und versuchen Sie es erneut';

  @override
  String get apiKeyScreenTitle => 'Einrichten Gemini API Key';

  @override
  String get analyzeFoodWithAi => 'Analysieren Sie Lebensmittel mit KI';

  @override
  String get analyzeFoodWithAiDesc =>
      'Machen Sie ein Foto → KI berechnet Kalorien automatisch\nDie Nutzung von Gemini API ist kostenlos!';

  @override
  String get openGoogleAiStudio => 'Öffnen Sie Google AI Studio';

  @override
  String get step1Title => 'Öffnen Sie Google AI Studio';

  @override
  String get step1Desc =>
      'Klicken Sie auf die Schaltfläche unten, um ein API Key zu erstellen.';

  @override
  String get step2Title => 'Melden Sie sich mit dem Google-Konto an';

  @override
  String get step2Desc =>
      'Verwenden Sie Ihr Gmail- oder Google-Konto (erstellen Sie kostenlos eines, wenn Sie noch keins haben)';

  @override
  String get step3Title => 'Klicken Sie auf „API Key erstellen“';

  @override
  String get step3Desc =>
      'Klicken Sie auf die blaue Schaltfläche „API Key erstellen“.\nWenn Sie aufgefordert werden, ein Pro-Projekt auszuwählen → Klicken Sie auf „API-Schlüssel in neuem Projekt erstellen“.';

  @override
  String get step4Title =>
      'Kopieren Sie den Schlüssel und fügen Sie ihn unten ein';

  @override
  String get step4Desc =>
      'Klicken Sie neben dem erstellten Schlüssel auf Kopieren\nDer Schlüssel sieht so aus: AIzaSyxxxx...';

  @override
  String get step5Title => 'Fügen Sie hier API Key ein';

  @override
  String get pasteApiKeyHint => 'Fügen Sie den kopierten API Key ein.';

  @override
  String get saveApiKey => 'Speichern API Key';

  @override
  String get testingConnection => 'Testen...';

  @override
  String get deleteApiKey => 'API Key löschen';

  @override
  String get deleteApiKeyConfirm => 'API Key löschen?';

  @override
  String get deleteApiKeyConfirmDesc =>
      'Sie können die KI-Lebensmittelanalyse erst verwenden, wenn Sie sie erneut einrichten';

  @override
  String get apiKeySaved => 'API Key erfolgreich gespeichert';

  @override
  String get apiKeyDeleted => 'API Key erfolgreich gelöscht';

  @override
  String get pleasePasteApiKey => 'Bitte fügen Sie zuerst API Key ein';

  @override
  String get apiKeyInvalidFormat =>
      'Ungültiger API Key – muss mit „AIza“ beginnen';

  @override
  String get connectionSuccessMessage =>
      '✅ Erfolgreich verbunden! Gebrauchsfertig';

  @override
  String get connectionFailedMessage => '❌ Verbindung fehlgeschlagen';

  @override
  String get faqTitle => 'Häufig gestellte Fragen';

  @override
  String get faqFreeQuestion => 'Ist es wirklich kostenlos?';

  @override
  String get faqFreeAnswer =>
      'Ja! Gemini 2.0 Flash ist für 1.500 Anfragen/Tag kostenlos\nFür die Lebensmittelprotokollierung (5–15 Mal/Tag) → Für immer kostenlos, keine Zahlung erforderlich';

  @override
  String get faqSafeQuestion => 'Ist es sicher?';

  @override
  String get faqSafeAnswer =>
      'API Key wird nur im sicheren Speicher auf Ihrem Gerät gespeichert\nDie App sendet den Schlüssel nicht an unseren Server\nWenn der Schlüssel verloren geht → Löschen und einen neuen erstellen (es ist nicht Ihr Google-Passwort)';

  @override
  String get faqNoKeyQuestion =>
      'Was passiert, wenn ich keinen Schlüssel erstelle?';

  @override
  String get faqNoKeyAnswer =>
      'Sie können die App weiterhin nutzen! Aber:\n❌ Foto kann nicht aufgenommen werden → KI-Analyse\n✅ Kann Lebensmittel manuell protokollieren\n✅ Quick Add funktioniert\n✅ Sehen Sie sich kcal/Makro-Zusammenfassungsarbeiten an';

  @override
  String get faqCreditCardQuestion => 'Brauche ich eine Kreditkarte?';

  @override
  String get faqCreditCardAnswer =>
      'Nein – Erstellen Sie API Key kostenlos und ohne Kreditkarte';

  @override
  String get navDashboard => 'Armaturenbrett';

  @override
  String get navMyMeals => 'Meine Mahlzeiten';

  @override
  String get navCamera => 'Kamera';

  @override
  String get navAiChat => 'KI-Chat';

  @override
  String get navProfile => 'ProDatei';

  @override
  String get appBarTodayIntake => 'Die heutige Aufnahme';

  @override
  String get appBarMyMeals => 'Meine Mahlzeiten';

  @override
  String get appBarCamera => 'Kamera';

  @override
  String get appBarAiChat => 'KI-Chat';

  @override
  String get appBarMiro => 'MIRO';

  @override
  String get permissionRequired => 'Erlaubnis erforderlich';

  @override
  String get permissionRequiredDesc => 'MIRO benötigt Zugriff auf Folgendes:';

  @override
  String get permissionPhotos => 'Fotos – zum Scannen von Lebensmitteln';

  @override
  String get permissionCamera => 'Kamera – um Essen zu fotografieren';

  @override
  String get permissionSkip => 'Überspringen';

  @override
  String get permissionAllow => 'Erlauben';

  @override
  String get permissionAllGranted => 'Alle Berechtigungen erteilt';

  @override
  String permissionDenied(String denied) {
    return 'Berechtigung verweigert: $denied';
  }

  @override
  String get openSettings => 'Öffnen Sie Einstellungen';

  @override
  String get exitAppTitle => 'App beenden?';

  @override
  String get exitAppMessage =>
      'Sind Sie sicher, dass Sie den Vorgang beenden möchten?';

  @override
  String get exit => 'Ausfahrt';

  @override
  String get healthGoalsTitle => 'Gesundheitsziele';

  @override
  String get healthGoalsInfo =>
      'Legen Sie Ihr tägliches Kalorienziel, Ihre Makros und Ihr Budget pro Mahlzeit fest.\nSperren, um automatisch zu berechnen: 2 Makros oder 3 Mahlzeiten.';

  @override
  String get dailyCalorieGoal => 'Tägliches Kalorienziel';

  @override
  String get proteinLabel => 'Protein';

  @override
  String get carbsLabel => 'Kohlenhydrate';

  @override
  String get fatLabel => 'Fett';

  @override
  String get autoBadge => 'Auto';

  @override
  String kcalPerGram(int kcalPerGram, int kcal) {
    return '$kcalPerGram kcal/g • $kcal __SW0__';
  }

  @override
  String get mealCalorieBudget => 'Kalorienbudget einer Mahlzeit';

  @override
  String mealBudgetBalanced(int total, int goal) {
    return 'Gesamt $total kcal = Ziel $goal __SW0__';
  }

  @override
  String mealBudgetRemaining(int total, int goal, int remaining) {
    return 'Gesamt $total / $goal kcal ($remaining verbleibend)';
  }

  @override
  String get lockMealsHint =>
      'Sperren Sie 3 Mahlzeiten, um die vierte automatisch zu berechnen';

  @override
  String get breakfastLabel => 'Frühstück';

  @override
  String get lunchLabel => 'Mittagessen';

  @override
  String get dinnerLabel => 'Abendessen';

  @override
  String get snackLabel => 'Snack';

  @override
  String percentOfDailyGoal(String percent) {
    return '$percent % des Tagesziels';
  }

  @override
  String get smartSuggestionRange => 'Smart-Suggestion-Bereich';

  @override
  String get smartSuggestionHow => 'Wie funktioniert Smart Suggestion?';

  @override
  String smartSuggestionDesc(int threshold, int min, int max) {
    return 'Wir schlagen Ihnen Lebensmittel aus „Meine Mahlzeiten“, Zutaten und Mahlzeiten von gestern vor, die zu Ihrem Budget pro Mahlzeit passen.\n\nDieser Schwellenwert steuert, wie flexibel die Vorschläge sind. Wenn Ihr Budget für das Mittagessen beispielsweise 700 kcal beträgt und der Schwellenwert $threshold __SW0__ beträgt, schlagen wir Lebensmittel zwischen $min und $max __SW0__ vor.';
  }

  @override
  String get suggestionThreshold => 'Vorschlagsschwelle';

  @override
  String suggestionThresholdDesc(int threshold) {
    return 'Erlauben Sie Lebensmittel ± $threshold kcal vom Essensbudget';
  }

  @override
  String get goalsSavedSuccess => 'Tore erfolgreich gespeichert!';

  @override
  String get canOnlyLockTwoMacros =>
      'Es können nur 2 Makros gleichzeitig gesperrt werden';

  @override
  String get canOnlyLockThreeMeals =>
      'Es können nur 3 Mahlzeiten gesperrt werden; Der 4. berechnet automatisch';

  @override
  String get tabMeals => 'Mahlzeiten';

  @override
  String get tabIngredients => 'Zutaten';

  @override
  String get searchMealsOrIngredients =>
      'Suchen Sie nach Mahlzeiten oder Zutaten...';

  @override
  String get createNewMeal => 'Neue Mahlzeit erstellen';

  @override
  String get addIngredient => 'Zutat hinzufügen';

  @override
  String get noMealsYet => 'Noch keine Mahlzeiten';

  @override
  String get noMealsYetDesc =>
      'Analysieren Sie Lebensmittel mit KI, um Mahlzeiten automatisch zu speichern\noder erstellen Sie eines manuell';

  @override
  String get noIngredientsYet => 'Noch keine Zutaten';

  @override
  String get noIngredientsYetDesc =>
      'Wenn Sie Lebensmittel mit KI analysieren\nZutaten werden automatisch gespeichert';

  @override
  String mealCreated(String name) {
    return 'Erstellt „$name“';
  }

  @override
  String mealLogged(String name) {
    return 'Protokolliert „$name“';
  }

  @override
  String ingredientAmount(String unit) {
    return 'Betrag ($unit)';
  }

  @override
  String ingredientLogged(String name, String amount, String unit) {
    return 'Protokolliert „$name“ $amount$unit';
  }

  @override
  String get mealNotFound => 'Mahlzeit nicht gefunden';

  @override
  String mealUpdated(String name) {
    return '„$name“ aktualisiert';
  }

  @override
  String get deleteMealTitle => 'Mahlzeit löschen?';

  @override
  String deleteMealMessage(String name) {
    return '„$name“';
  }

  @override
  String get deleteMealNote => 'Zutaten werden nicht gelöscht.';

  @override
  String get mealDeleted => 'Mahlzeit gelöscht';

  @override
  String ingredientCreated(String name) {
    return 'Erstellt „$name“';
  }

  @override
  String get ingredientNotFound => 'Zutat nicht gefunden';

  @override
  String ingredientUpdated(String name) {
    return '„$name“ aktualisiert';
  }

  @override
  String get deleteIngredientTitle => 'Zutat löschen?';

  @override
  String deleteIngredientMessage(String name) {
    return '„$name“';
  }

  @override
  String get ingredientDeleted => 'Zutat gelöscht';

  @override
  String get noIngredientsData => 'Keine Angaben zu Inhaltsstoffen';

  @override
  String ingredientDetail(String name, String amount, String unit) {
    return '$name ($amount $unit)';
  }

  @override
  String ingredientCalories(int calories) {
    return '$calories kcal';
  }

  @override
  String get useThisMeal => 'Verwenden Sie diese Mahlzeit';

  @override
  String errorLoading(String error) {
    return 'Fehler beim Laden: $error';
  }

  @override
  String scanFoundNewImages(int count, String date) {
    return '$count neue Bilder gefunden auf $date';
  }

  @override
  String scanNoNewImages(String date) {
    return 'Keine neuen Bilder gefunden auf $date';
  }

  @override
  String aiAnalysisRemaining(int remaining, int total) {
    return 'KI-Analyse: $remaining/$total verbleiben heute';
  }

  @override
  String get upgradeToProUnlimited => 'Upgrade auf Pro für unbegrenzte Nutzung';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get confirmDelete => 'Bestätigen Sie Löschen';

  @override
  String confirmDeleteMessage(String name) {
    return 'Möchten Sie „$name“ löschen?';
  }

  @override
  String get entryDeletedSuccess => '✅ Eintrag erfolgreich gelöscht';

  @override
  String entryDeleteError(String error) {
    return '❌ Fehler: $error';
  }

  @override
  String batchAnalyzeItems(int count) {
    return '$count Artikel (Charge)';
  }

  @override
  String analyzeCancelled(int success) {
    return 'Abgebrochen – $success Elemente erfolgreich analysiert';
  }

  @override
  String analyzeSuccessAll(int success) {
    return '✅ $success Elemente erfolgreich analysiert';
  }

  @override
  String analyzeSuccessPartial(int success, int total, int failed) {
    return '⚠️ Analysierte $success/$total Elemente ($failed fehlgeschlagen)';
  }

  @override
  String analyzeProgress(String item, int current, int total) {
    return '$item ($current/$total)';
  }

  @override
  String get pullToScanMeal => 'Ziehen Sie, um Ihre Mahlzeit zu scannen';

  @override
  String get analyzeAll => 'Alles analysieren';

  @override
  String get addFoodTitle => 'Essen hinzufügen';

  @override
  String get foodNameRequired => 'Lebensmittelname *';

  @override
  String get foodNameHint =>
      'Geben Sie zum Suchen ein, z. B. gebratener Reis, Papayasalat';

  @override
  String get selectedFromMyMeal =>
      '✅ Aus „Meine Mahlzeit“ ausgewählt – Nährwertdaten werden automatisch ausgefüllt';

  @override
  String get foundInDatabase =>
      '✅ In der Datenbank gefunden – Nährwertdaten werden automatisch ausgefüllt';

  @override
  String get saveAndAnalyze => 'Speichern und analysieren';

  @override
  String get notFoundInDatabase =>
      'Nicht in der Datenbank gefunden – wird im Hintergrund analysiert';

  @override
  String get amountLabel => 'Menge';

  @override
  String get unitLabel => 'Einheit';

  @override
  String get nutritionAutoCalculated =>
      'Nährwert (automatisch nach Menge berechnet)';

  @override
  String get nutritionEnterZero =>
      'Ernährung (geben Sie 0 ein, wenn unbekannt)';

  @override
  String get caloriesLabel => 'Kalorien (kcal)';

  @override
  String get proteinLabelShort => 'Protein (g)';

  @override
  String get carbsLabelShort => 'Kohlenhydrate (g)';

  @override
  String get fatLabelShort => 'Fett (g)';

  @override
  String get mealTypeLabel => 'Art der Mahlzeit';

  @override
  String get pleaseEnterFoodNameFirst =>
      'Bitte geben Sie zuerst den Lebensmittelnamen ein';

  @override
  String get savedAnalyzingBackground =>
      '✅ Gespeichert – Analyse im Hintergrund';

  @override
  String get foodAdded => '✅ Essen hinzugefügt';

  @override
  String get suggestionSourceMyMeal => 'Meine Mahlzeit';

  @override
  String get suggestionSourceIngredient => 'Bestandteil';

  @override
  String get suggestionSourceDatabase => 'Datenbank';

  @override
  String get editFoodTitle => 'Essen bearbeiten';

  @override
  String get foodNameLabel => 'Lebensmittelname';

  @override
  String get changeAmountAutoUpdate =>
      'Menge ändern → Kalorien werden automatisch aktualisiert';

  @override
  String baseNutrition(int calories, String unit) {
    return 'Basis: $calories kcal / 1 $unit';
  }

  @override
  String get calculatedFromIngredients =>
      'Berechnet aus den unten aufgeführten Zutaten';

  @override
  String get ingredientsEditable => 'Zutaten (bearbeitbar)';

  @override
  String get addIngredientButton => 'Hinzufügen';

  @override
  String get noIngredientsAddHint =>
      'Keine Zutaten – tippen Sie auf „Hinzufügen“, um neue hinzuzufügen';

  @override
  String get editIngredientsHint =>
      'Name/Betrag bearbeiten → Tippen Sie auf das Suchsymbol, um die Datenbank oder AI zu durchsuchen';

  @override
  String get ingredientNameHint => 'z.B. Hühnerei';

  @override
  String get searchDbOrAi => 'Suche DB/AI';

  @override
  String get amountHint => 'Menge';

  @override
  String get fromDatabase => 'Aus der Datenbank';

  @override
  String subIngredients(int count) {
    return 'Unterzutaten ($count)';
  }

  @override
  String get addSubIngredient => 'Hinzufügen';

  @override
  String get subIngredientNameHint => 'Name der Unterzutat';

  @override
  String get amountShort => 'Amt';

  @override
  String get pleaseEnterSubIngredientName =>
      'Bitte geben Sie zuerst den Namen der Unterzutat ein';

  @override
  String foundInDatabaseSub(String name) {
    return '„$name“ in der Datenbank gefunden!';
  }

  @override
  String aiAnalyzedSub(String name) {
    return 'KI analysierte „$name“ (-1 Energie)';
  }

  @override
  String get couldNotAnalyzeSub =>
      'Unterbestandteil konnte nicht analysiert werden';

  @override
  String get pleaseEnterIngredientName =>
      'Bitte geben Sie den Namen der Zutat ein';

  @override
  String get reAnalyzeTitle => 'Neu analysieren?';

  @override
  String reAnalyzeMessage(String name) {
    return '„$name“ verfügt bereits über Nährwertdaten.\n\nEine erneute Analyse verbraucht 1 Energie.\n\nWeitermachen?';
  }

  @override
  String get reAnalyzeButton => 'Erneut analysieren (1 Energie)';

  @override
  String get amountNotSpecified => 'Betrag nicht angegeben';

  @override
  String amountNotSpecifiedMessage(String name) {
    return 'Bitte geben Sie zuerst den Betrag für „$name“ an\nOder Standard 100 g verwenden?';
  }

  @override
  String get useDefault100g => 'Verwenden Sie 100 g';

  @override
  String aiAnalyzedResult(String name, int calories) {
    return 'AI: „$name“ → $calories kcal';
  }

  @override
  String get unableToAnalyze => 'Analyse nicht möglich';

  @override
  String get today => 'Heute';

  @override
  String get savedSuccessfully => '✅ Erfolgreich gespeichert';

  @override
  String get confirmFoodPhoto => 'Bestätigen Sie das Lebensmittelfoto';

  @override
  String get photoSavedAutomatically => 'Foto automatisch gespeichert';

  @override
  String get foodNameHintExample => 'z. B. gegrillter Hühnersalat';

  @override
  String get quantityLabel => 'Menge';

  @override
  String get quantityHint => '1';

  @override
  String get optionalFoodInfo =>
      'Die Eingabe des Namens und der Menge des Lebensmittels ist optional, die Angabe dieser Angaben erhöht jedoch die Genauigkeit der KI-Analyse.';

  @override
  String get saveOnly => 'Nur speichern';

  @override
  String get pleaseEnterValidQuantity =>
      'Bitte geben Sie eine gültige Menge ein';

  @override
  String analyzedResult(String name, int calories) {
    return '✅ Analysiert: $name — $calories kcal';
  }

  @override
  String get couldNotAnalyzeSaved =>
      '⚠️ Analyse konnte nicht durchgeführt werden – gespeichert, verwenden Sie später „Alle analysieren“.';

  @override
  String get savedAnalyzeLater =>
      '✅ Gespeichert – später mit „Alle analysieren“ analysieren';

  @override
  String get editIngredientTitle => 'Zutat bearbeiten';

  @override
  String get ingredientNameRequired => 'Name der Zutat *';

  @override
  String get baseAmountLabel => 'Grundbetrag';

  @override
  String get baseAmountHint => '100';

  @override
  String nutritionPerBase(String amount, String unit) {
    return 'Ernährung pro $amount $unit';
  }

  @override
  String nutritionCalculatedPerBase(String amount, String unit) {
    return 'Der Nährwert wird pro $amount $unit berechnet – das System berechnet automatisch basierend auf der tatsächlich verbrauchten Menge';
  }

  @override
  String get createIngredient => 'Zutat erstellen';

  @override
  String get saveChanges => 'Änderungen speichern';

  @override
  String get pleaseEnterIngredientNameFirst =>
      'Bitte geben Sie zuerst den Namen der Zutat ein';

  @override
  String aiAnalyzedIngredient(
      String name, String amount, String unit, int calories) {
    return 'AI: „$name“ $amount $unit → $calories kcal';
  }

  @override
  String get unableToFindIngredient =>
      'Diese Zutat konnte nicht gefunden werden';

  @override
  String searchFailed(String error) {
    return 'Suche fehlgeschlagen: $error';
  }

  @override
  String deleteEntriesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Entries',
      one: 'Entry',
    );
    return '$count $_temp0 löschen?';
  }

  @override
  String deleteEntriesMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return '$count ausgewähltes Lebensmittel $_temp0 löschen?';
  }

  @override
  String get deleteAll => 'Alle löschen';

  @override
  String deletedEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return 'Gelöscht $count $_temp0';
  }

  @override
  String movedEntriesToDate(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return '$count $_temp0 nach $date verschoben';
  }

  @override
  String get allSelectedAlreadyAnalyzed =>
      'Alle ausgewählten Einträge sind bereits analysiert';

  @override
  String analyzeCancelledSelected(int success) {
    return 'Abgebrochen – $success analysiert';
  }

  @override
  String analyzedEntriesAll(int success) {
    String _temp0 = intl.Intl.pluralLogic(
      success,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return 'Analysiert $success $_temp0';
  }

  @override
  String analyzedEntriesPartial(int success, int total, int failed) {
    return 'Analysiert $success/$total ($failed fehlgeschlagen)';
  }

  @override
  String analyzeProgressSelected(int current, int total, String item) {
    return '$current/$total $item';
  }

  @override
  String get noEntriesYet => 'Noch keine Einträge';

  @override
  String get selectAll => 'Alles auswählen';

  @override
  String get deselectAll => 'Alle abwählen';

  @override
  String get moveToDate => 'Auf den neuesten Stand verschieben';

  @override
  String get analyzeSelected => 'Ausgewählte Analyse';

  @override
  String get deleteTooltip => 'Löschen';

  @override
  String get move => 'Bewegen';

  @override
  String get deleteTooltipAction => 'Löschen';

  @override
  String switchToModeTitle(String mode) {
    return 'In den $mode-Modus wechseln?';
  }

  @override
  String switchToModeMessage(String current, String newMode) {
    return 'Dieses Element wurde als $current analysiert.\n\nEine erneute Analyse als $newMode wird 1 Energie verbrauchen.\n\nWeitermachen?';
  }

  @override
  String analyzingAsMode(String mode) {
    return 'Analysiert als $mode...';
  }

  @override
  String reAnalyzedAsMode(String mode) {
    return '✅ Neu analysiert als $mode';
  }

  @override
  String get analysisFailed => '❌ Analyse fehlgeschlagen';

  @override
  String get aiAnalysisComplete => '✅ KI analysiert und gespeichert';

  @override
  String get changeMealType => 'Ändern Sie die Art der Mahlzeit';

  @override
  String get moveToAnotherDate => 'Zu einem anderen Datum verschieben';

  @override
  String currentDate(String date) {
    return 'Aktuell: $date';
  }

  @override
  String get cancelDateChange => 'Datumsänderung abbrechen';

  @override
  String get undo => 'Rückgängig machen';

  @override
  String get chatHistory => 'Chat-Verlauf';

  @override
  String get newChat => 'Neuer Chat';

  @override
  String get quickActions => 'Schnelle Aktionen';

  @override
  String get clear => 'Klar';

  @override
  String get helloImMiro => 'Hallo! Ich bin Miro';

  @override
  String get tellMeWhatYouAteToday => 'Sag mir, was du heute gegessen hast!';

  @override
  String get tellMeWhatYouAte => 'Sag mir, was du gegessen hast...';

  @override
  String get clearHistoryTitle => 'Verlauf löschen?';

  @override
  String get clearHistoryMessage =>
      'Alle Nachrichten in dieser Sitzung werden gelöscht.';

  @override
  String get chatHistoryTitle => 'Chat-Verlauf';

  @override
  String get newLabel => 'Neu';

  @override
  String get noChatHistoryYet => 'Noch kein Chatverlauf';

  @override
  String get active => 'Aktiv';

  @override
  String get deleteChatTitle => 'Chat löschen?';

  @override
  String deleteChatMessage(String title) {
    return '„$title“ löschen?';
  }

  @override
  String weeklySummaryTitle(String start, String end) {
    return '📊 Wöchentliche Zusammenfassung ($start - $end)';
  }

  @override
  String daySummary(String day, String calories, String emoji, String diff) {
    return '📅 $day: $calories kcal $emoji ($diff)';
  }

  @override
  String overTarget(String amount) {
    return '$amount über dem Ziel';
  }

  @override
  String underTarget(String amount) {
    return '$amount unter Ziel';
  }

  @override
  String get noFoodLoggedThisWeek =>
      'Diese Woche wurden noch keine Lebensmittel protokolliert.';

  @override
  String averageKcalPerDay(String average) {
    return '🔥 Durchschnitt: $average kcal/Tag';
  }

  @override
  String targetKcalPerDay(String target) {
    return '🎯 Ziel: $target kcal/Tag';
  }

  @override
  String resultOverTarget(String amount) {
    return '📈 Ergebnis: $amount kcal über dem Ziel';
  }

  @override
  String resultUnderTarget(String amount) {
    return '📈 Ergebnis: $amount kcal unter Ziel – Tolle Arbeit! 💪';
  }

  @override
  String failedToLoadWeeklySummary(String error) {
    return '❌ Die wöchentliche Zusammenfassung konnte nicht geladen werden: $error';
  }

  @override
  String monthlySummaryTitle(String month, int year) {
    return '📊 Monatliche Zusammenfassung ($month $year)';
  }

  @override
  String totalDays(int days) {
    return '📅 Gesamttage: $days';
  }

  @override
  String totalConsumed(String calories) {
    return '🔥 Gesamtverbrauch: $calories kcal';
  }

  @override
  String targetTotal(String target) {
    return '🎯 Gesamtziel: $target kcal';
  }

  @override
  String averageKcalPerDayShort(String average) {
    return '📈 Durchschnitt: $average kcal/Tag';
  }

  @override
  String overTargetThisMonth(String amount) {
    return '⚠️ $amount kcal über dem Ziel diesen Monat';
  }

  @override
  String underTargetThisMonth(String amount) {
    return '✅ $amount kcal unter Ziel – Ausgezeichnet! 💪';
  }

  @override
  String failedToLoadMonthlySummary(String error) {
    return '❌ Monatliche Zusammenfassung konnte nicht geladen werden: $error';
  }

  @override
  String get localAiHelpTitle => '🤖 Lokale KI-Hilfe';

  @override
  String get localAiHelpFormat => 'Format: [Essen] [Menge] [Einheit]';

  @override
  String get localAiHelpExamples =>
      'Beispiele:\n• Huhn 100 g und Reis 200 g\n• Pizza 2 Scheiben\n• Apfel 1 Stück, Banane 1 Stück';

  @override
  String get localAiHelpNote =>
      'Hinweis: Nur Englisch, einfache Analyse\nWechseln Sie zu Miro AI, um bessere Ergebnisse zu erzielen!';

  @override
  String hiNoFoodLogged(String target) {
    return '🤖 Hallo! Heute wurde noch kein Futter protokolliert.\n   Ziel: $target kcal – Bereit, mit der Protokollierung zu beginnen? 🍽️';
  }

  @override
  String hiKcalLeft(String remaining) {
    return '🤖 Hallo! Sie haben für heute noch $remaining kcal übrig.\n   Sind Sie bereit, Ihre Mahlzeiten zu protokollieren? 😊';
  }

  @override
  String hiOverTarget(String calories, String over) {
    return '🤖 Hallo! Sie haben heute $calories kcal verbraucht.\n   $over __SW0__ über dem Ziel – Bleiben wir dran! 💪';
  }

  @override
  String get hiReadyToLog =>
      '🤖 Hallo! Sind Sie bereit, Ihre Mahlzeiten zu protokollieren? 😊';

  @override
  String get notEnoughEnergy => 'Nicht genug Energie';

  @override
  String get thinkingMealIdeas =>
      '🤖 Überlegen Sie sich tolle Essensideen für Sie ...';

  @override
  String get recentMeals => 'Letzte Mahlzeiten:';

  @override
  String get noRecentFood => 'Keine aktuellen Lebensmittel protokolliert.';

  @override
  String remainingCaloriesToday(String remaining) {
    return '. Verbleibende Kalorien heute: $remaining kcal.';
  }

  @override
  String failedToGetMenuSuggestions(String error) {
    return '❌ Menüvorschläge konnten nicht abgerufen werden: $error';
  }

  @override
  String get mealSuggestionsTitle =>
      '🤖 Basierend auf Ihrem Ernährungsprotokoll finden Sie hier 3 Essensvorschläge:';

  @override
  String mealSuggestionItem(
      int index, String emoji, String name, String calories) {
    return '$index. $emoji $name (~$calories kcal)';
  }

  @override
  String mealSuggestionMacros(String protein, String carbs, String fat) {
    return 'P: ${protein}g | C: ${carbs}g | F: ${fat}g';
  }

  @override
  String get pickOneAndLog =>
      'Wählen Sie eines aus und ich protokolliere es für Sie! 😊';

  @override
  String energyCost(int cost) {
    return '⚡ -$cost Energie';
  }

  @override
  String get giveMeTipsForHealthyEating =>
      'Gib mir Tipps für eine gesunde Ernährung';

  @override
  String get howManyCaloriesToday => 'Wie viele Kalorien heute?';

  @override
  String get menuLabel => 'Speisekarte';

  @override
  String get weeklyLabel => 'Wöchentlich';

  @override
  String get monthlyLabel => 'Monatlich';

  @override
  String get tipsLabel => 'Tipps';

  @override
  String get summaryLabel => 'Zusammenfassung';

  @override
  String get helpLabel => 'Helfen';

  @override
  String get onboardingWelcomeSubtitle =>
      'Verfolgen Sie mühelos Kalorien\nmit KI-gestützter Analyse';

  @override
  String get onboardingSnap => 'Schnapp';

  @override
  String get onboardingSnapDesc => 'KI analysiert sofort';

  @override
  String get onboardingType => 'Typ';

  @override
  String get onboardingTypeDesc => 'Melden Sie sich in Sekunden an';

  @override
  String get onboardingEdit => 'Bearbeiten';

  @override
  String get onboardingEditDesc => 'Feinabstimmung der Genauigkeit';

  @override
  String get onboardingNext => 'Weiter →';

  @override
  String get onboardingDisclaimer =>
      'KI-geschätzte Daten. Kein medizinischer Rat.';

  @override
  String get onboardingQuickSetup => 'Schnelle Einrichtung';

  @override
  String get onboardingHelpAiUnderstand =>
      'Helfen Sie der KI, Ihr Essen besser zu verstehen';

  @override
  String get onboardingYourTypicalCuisine => 'Ihre typische Küche:';

  @override
  String get onboardingDailyCalorieGoal => 'Tägliches Kalorienziel (optional):';

  @override
  String get onboardingKcalPerDay => 'kcal/Tag';

  @override
  String get onboardingCalorieGoalHint => '2000';

  @override
  String get onboardingCanChangeAnytime =>
      'Sie können dies jederzeit in den ProDateieinstellungen ändern';

  @override
  String get onboardingYoureAllSet => 'Sie sind bereit!';

  @override
  String get onboardingStartTracking =>
      'Beginnen Sie noch heute damit, Ihre Mahlzeiten zu verfolgen.\nMachen Sie ein Foto oder geben Sie ein, was Sie gegessen haben.';

  @override
  String get onboardingWelcomeGift => 'Willkommensgeschenk';

  @override
  String get onboardingFreeEnergy => '10 KOSTENLOSE Energie';

  @override
  String get onboardingFreeEnergyDesc => '= 10 KI-Analysen zum Einstieg';

  @override
  String get onboardingEnergyCost =>
      'Jede Analyse kostet 1 Energie\nJe mehr Sie verwenden, desto mehr verdienen Sie!';

  @override
  String get onboardingStartTrackingButton =>
      'Beginnen Sie mit der Verfolgung! →';

  @override
  String get onboardingNoCreditCard =>
      'Keine Kreditkarte • Keine versteckten Gebühren';

  @override
  String get cameraTakePhotoOfFood => 'Machen Sie ein Foto von Ihrem Essen';

  @override
  String get cameraFailedToInitialize =>
      'Kamera konnte nicht initialisiert werden';

  @override
  String get cameraFailedToCapture => 'Foto konnte nicht aufgenommen werden';

  @override
  String get cameraFailedToPickFromGallery =>
      'Bild konnte nicht aus der Galerie ausgewählt werden';

  @override
  String get cameraProcessing => 'ProVerarbeitung...';

  @override
  String get referralInviteFriends => 'Freunde einladen';

  @override
  String get referralYourReferralCode => 'Ihr Empfehlungscode';

  @override
  String get referralLoading => 'Laden...';

  @override
  String get referralCopy => 'Kopie';

  @override
  String get referralShareCodeDescription =>
      'Teilen Sie diesen Code mit Freunden! Wenn sie dreimal KI einsetzen, erhalten Sie beide Belohnungen!';

  @override
  String get referralEnterReferralCode => 'Geben Sie den Empfehlungscode ein';

  @override
  String get referralCodeHint => 'MIRO-XXXX-XXXX-XXXX';

  @override
  String get referralSubmitCode => 'Code senden';

  @override
  String get referralPleaseEnterCode =>
      'Bitte geben Sie einen Empfehlungscode ein';

  @override
  String get referralCodeAccepted => 'Empfehlungscode akzeptiert!';

  @override
  String get referralCodeCopied =>
      'Empfehlungscode in die Zwischenablage kopiert!';

  @override
  String referralEnergyBonus(int energy) {
    return '+$energy Energie!';
  }

  @override
  String get referralHowItWorks => 'Wie es funktioniert';

  @override
  String get referralStep1Title => 'Teilen Sie Ihren Empfehlungscode';

  @override
  String get referralStep1Description =>
      'Kopieren Sie Ihre MiRO-ID und teilen Sie sie mit Freunden';

  @override
  String get referralStep2Title => 'Freund gibt Ihren Code ein';

  @override
  String get referralStep2Description => 'Sie erhalten sofort +20 Energie';

  @override
  String get referralStep3Title => 'Freund nutzt dreimal KI';

  @override
  String get referralStep3Description =>
      'Wenn sie 3 KI-Analysen abgeschlossen haben';

  @override
  String get referralStep4Title => 'Du wirst belohnt!';

  @override
  String get referralStep4Description => 'Du erhältst +5 Energie!';

  @override
  String get tierBenefitsTitle => 'Stufenvorteile';

  @override
  String get tierBenefitsUnlockRewards =>
      'Schalte Belohnungen frei\nmit Daily Streaks';

  @override
  String get tierBenefitsKeepStreakDescription =>
      'Halte deinen Streak am Leben, um höhere Ränge freizuschalten und tolle Vorteile zu erhalten!';

  @override
  String get tierBenefitsHowItWorks => 'Wie es funktioniert';

  @override
  String get tierBenefitsDailyEnergyReward => 'Tägliche Energiebelohnung';

  @override
  String get tierBenefitsDailyEnergyDescription =>
      'Benutze KI mindestens einmal am Tag, um Bonusenergie zu verdienen. Höhere Stufen = mehr tägliche Energie!';

  @override
  String get tierBenefitsPurchaseBonus => 'Kaufbonus';

  @override
  String get tierBenefitsPurchaseBonusDescription =>
      'Gold- und Diamantstufen erhalten bei jedem Einkauf zusätzliche Energie (10–20 % mehr!)';

  @override
  String get tierBenefitsGracePeriod => 'Gnadenfrist';

  @override
  String get tierBenefitsGracePeriodDescription =>
      'Verpassen Sie einen Tag, ohne Ihren Streak zu verlieren. Silber+-Stufen erhalten Schutz!';

  @override
  String get tierBenefitsAllTiers => 'Alle Stufen';

  @override
  String get tierBenefitsNew => 'NEU';

  @override
  String get tierBenefitsPopular => 'BELIEBT';

  @override
  String get tierBenefitsBest => 'AM BESTEN';

  @override
  String get tierBenefitsDailyCheckIn => 'Täglicher Check-in';

  @override
  String get tierBenefitsProTips => 'Pro Tipps';

  @override
  String get tierBenefitsTip1 =>
      'Nutze die KI täglich, um kostenlose Energie zu verdienen und deinen Streak aufzubauen';

  @override
  String get tierBenefitsTip2 =>
      'Die Diamantstufe verdient +4 Energie pro Tag – das sind 120/Monat!';

  @override
  String get tierBenefitsTip3 => 'Der Kaufbonus gilt für ALLE Energiepakete!';

  @override
  String get tierBenefitsTip4 =>
      'Die Schonfrist schützt Ihren Streak, wenn Sie einen Tag verpassen';

  @override
  String get subscriptionEnergyPass => 'Energiepass';

  @override
  String get subscriptionInAppPurchasesNotAvailable =>
      'In-App-Käufe sind nicht verfügbar';

  @override
  String get subscriptionFailedToInitiatePurchase =>
      'Der Kauf konnte nicht eingeleitet werden';

  @override
  String subscriptionError(String error) {
    return 'Fehler: $error';
  }

  @override
  String get subscriptionFailedToLoad =>
      'Das Abonnement konnte nicht geladen werden';

  @override
  String get subscriptionUnknownError => 'Unbekannter Fehler';

  @override
  String get subscriptionRetry => 'Wiederholen';

  @override
  String get subscriptionEnergyPassActive => 'Energiepass aktiv';

  @override
  String get subscriptionUnlimitedAccess =>
      'Sie haben uneingeschränkten Zugriff';

  @override
  String get subscriptionStatus => 'Status';

  @override
  String get subscriptionRenews => 'Erneuert';

  @override
  String get subscriptionPrice => 'Preis';

  @override
  String get subscriptionYourBenefits => 'Ihre Vorteile';

  @override
  String get subscriptionManageSubscription => 'Abonnement verwalten';

  @override
  String get subscriptionNoProductAvailable =>
      'Kein Abonnementprodukt verfügbar';

  @override
  String get subscriptionWhatYouGet => 'Was Sie bekommen';

  @override
  String get subscriptionPerMonth => 'pro Monat';

  @override
  String get subscriptionSubscribeNow => 'Jetzt abonnieren';

  @override
  String get subscriptionCancelAnytime => 'Jederzeit kündbar';

  @override
  String get subscriptionAutoRenewTerms =>
      'Ihr Abonnement verlängert sich automatisch. Sie können jederzeit ab Google Play kündigen.';

  @override
  String get disclaimerHealthDisclaimer =>
      'Haftungsausschluss für die Gesundheit';

  @override
  String get disclaimerImportantReminders => 'Wichtige Hinweise:';

  @override
  String get disclaimerBullet1 => 'Alle Nährwertangaben sind Schätzungen';

  @override
  String get disclaimerBullet2 => 'Die KI-Analyse kann Fehler enthalten';

  @override
  String get disclaimerBullet3 => 'Kein Ersatz für professionelle Beratung';

  @override
  String get disclaimerBullet4 =>
      'Konsultieren Sie Gesundheitsdienstleister für medizinische Beratung';

  @override
  String get disclaimerBullet5 =>
      'Die Nutzung erfolgt nach eigenem Ermessen und auf eigenes Risiko';

  @override
  String get disclaimerIUnderstand => 'Ich verstehe';

  @override
  String get privacyPolicyTitle => 'Datenschutzrichtlinie';

  @override
  String get privacyPolicySubtitle => 'MiRO – My Intake Record Oracle';

  @override
  String get privacyPolicyHeaderNote =>
      'Ihre Lebensmitteldaten bleiben auf Ihrem Gerät. Energiebilanz sicher über Firebase synchronisiert.';

  @override
  String get privacyPolicySectionInformationWeCollect =>
      'Informationen, die wir sammeln';

  @override
  String get privacyPolicySectionDataStorage => 'Datenspeicherung';

  @override
  String get privacyPolicySectionDataTransmission =>
      'Datenübermittlung an Dritte';

  @override
  String get privacyPolicySectionRequiredPermissions =>
      'Erforderliche Berechtigungen';

  @override
  String get privacyPolicySectionSecurity => 'Sicherheit';

  @override
  String get privacyPolicySectionUserRights => 'Benutzerrechte';

  @override
  String get privacyPolicySectionDataRetention => 'Datenaufbewahrung';

  @override
  String get privacyPolicySectionChildrenPrivacy => 'Privatsphäre von Kindern';

  @override
  String get privacyPolicySectionChangesToPolicy =>
      'Änderungen an dieser Richtlinie';

  @override
  String get privacyPolicySectionDataCollectionConsent =>
      'Einwilligung zur Datenerfassung';

  @override
  String get privacyPolicySectionPDPACompliance =>
      'PDPA-Konformität (Thailand Personal Data Protection Act)';

  @override
  String get privacyPolicySectionContactUs => 'Kontaktieren Sie uns';

  @override
  String get privacyPolicyEffectiveDate =>
      'Datum des Inkrafttretens: 18. Februar 2026\nLetzte Aktualisierung: 18. Februar 2026';

  @override
  String get termsOfServiceTitle => 'Nutzungsbedingungen';

  @override
  String get termsSubtitle => 'MiRO – My Intake Record Oracle';

  @override
  String get termsSectionAcceptanceOfTerms => 'Annahme der Bedingungen';

  @override
  String get termsSectionServiceDescription => 'Servicebeschreibung';

  @override
  String get termsSectionDisclaimerOfWarranties => 'Haftungsausschluss';

  @override
  String get termsSectionEnergySystemTerms => 'Begriffe des Energiesystems';

  @override
  String get termsSectionUserDataAndResponsibilities =>
      'Benutzerdaten und Verantwortlichkeiten';

  @override
  String get termsSectionBackupTransfer => 'Sichern und Übertragen';

  @override
  String get termsSectionInAppPurchases => 'In-App-Käufe';

  @override
  String get termsSectionProhibitedUses => 'Proverbotene Verwendungen';

  @override
  String get termsSectionIntellectualProperty => 'Intellektuelles Property';

  @override
  String get termsSectionLimitationOfLiability => 'Haftungsbeschränkung';

  @override
  String get termsSectionServiceTermination => 'Dienstbeendigung';

  @override
  String get termsSectionChangesToTerms => 'Änderungen der Bedingungen';

  @override
  String get termsSectionGoverningLaw => 'Geltendes Recht';

  @override
  String get termsSectionContactUs => 'Kontaktieren Sie uns';

  @override
  String get termsAcknowledgment =>
      'Durch die Nutzung von MiRO bestätigen Sie, dass Sie diese Nutzungsbedingungen gelesen und verstanden haben und ihnen zustimmen.';

  @override
  String get termsLastUpdated => 'Letzte Aktualisierung: 15. Februar 2026';

  @override
  String get profileAndSettings => 'ProDatei und Einstellungen';

  @override
  String errorOccurred(String error) {
    return 'Fehler: $error';
  }

  @override
  String get healthGoalsSection => 'Gesundheitsziele';

  @override
  String get dailyGoals => 'Tägliche Ziele';

  @override
  String get chatAiModeSection => 'Chat-KI-Modus';

  @override
  String get selectAiPowersChat =>
      'Wählen Sie aus, welche KI Ihren Chat antreibt';

  @override
  String get miroAi => 'Miro KI';

  @override
  String get miroAiSubtitle =>
      'Unterstützt von Gemini • Mehrsprachig • Hohe Genauigkeit';

  @override
  String get localAi => 'Lokale KI';

  @override
  String get localAiSubtitle =>
      'Auf dem Gerät • Nur Englisch • Grundlegende Genauigkeit';

  @override
  String get free => 'Frei';

  @override
  String get cuisinePreferenceSection => 'Küchenpräferenz';

  @override
  String get preferredCuisine => 'Bevorzugte Küche';

  @override
  String get selectYourCuisine => 'Wählen Sie Ihre Küche';

  @override
  String get photoScanSection => 'Fotoscan';

  @override
  String get languageSection => 'Sprache';

  @override
  String get languageTitle => 'Sprache / ภาษา';

  @override
  String get selectLanguage => 'Wählen Sie Sprache / Sprachen';

  @override
  String get systemDefault => 'Systemstandard';

  @override
  String get systemDefaultSublabel => 'ตามระบบ';

  @override
  String get english => 'Englisch';

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
  String get closeBilingual => 'Schließen / schließen';

  @override
  String languageChangedTo(String language) {
    return 'Die Sprache wurde in $language geändert.';
  }

  @override
  String get accountSection => 'Konto';

  @override
  String get miroId => 'MiRO ID';

  @override
  String get miroIdCopied => 'MiRO ID kopiert!';

  @override
  String get inviteFriends => 'Freunde einladen';

  @override
  String get inviteFriendsSubtitle =>
      'Teilen Sie Ihren Empfehlungscode und verdienen Sie Prämien!';

  @override
  String get unlimitedAiDoubleRewards =>
      'Unbegrenzte KI + doppelte Belohnungen';

  @override
  String get plan => 'Planen';

  @override
  String get monthly => 'Monatlich';

  @override
  String get started => 'Begonnen';

  @override
  String get renews => 'Erneuert';

  @override
  String get expires => 'Läuft ab';

  @override
  String get autoRenew => 'Automatische Verlängerung';

  @override
  String get on => 'An';

  @override
  String get off => 'Aus';

  @override
  String get tapToManageSubscription =>
      'Tippen Sie hier, um das Abonnement zu verwalten';

  @override
  String get dataSection => 'Daten';

  @override
  String get backupData => 'Sicherungsdaten';

  @override
  String get backupDataSubtitle =>
      'Energie- und Lebensmittelverlauf → als Datei speichern';

  @override
  String get restoreFromBackup => 'Aus Backup wiederherstellen';

  @override
  String get restoreFromBackupSubtitle =>
      'Daten aus Sicherungsdatei importieren';

  @override
  String get clearAllDataTitle => 'Alle Daten löschen?';

  @override
  String get clearAllDataContent =>
      'Alle Daten werden gelöscht:\n• Lebensmitteleinträge\n• Meine Mahlzeiten\n• Zutaten\n• Ziele\n• Persönliche Informationen\n\nDies kann nicht rückgängig gemacht werden!';

  @override
  String get allDataClearedSuccess => 'Alle Daten erfolgreich gelöscht';

  @override
  String get aboutSection => 'Um';

  @override
  String get version => 'Version';

  @override
  String get healthDisclaimer => 'Haftungsausschluss für die Gesundheit';

  @override
  String get importantLegalInformation => 'Wichtige rechtliche Informationen';

  @override
  String get showTutorialAgain => 'Tutorial erneut anzeigen';

  @override
  String get viewFeatureTour => 'Feature-Tour ansehen';

  @override
  String get showTutorialDialogTitle => 'Tutorial anzeigen';

  @override
  String get showTutorialDialogContent =>
      'Dadurch wird die Feature-Tour angezeigt, die Folgendes hervorhebt:\n\n• Energiesystem\n• Pull-to-Refresh-Fotoscan\n• Chatten Sie mit Miro AI\n\nSie kehren zum Startbildschirm zurück.';

  @override
  String get showTutorialButton => 'Tutorial anzeigen';

  @override
  String get tutorialResetMessage =>
      'Tutorial zurückgesetzt! Gehen Sie zum Startbildschirm, um es anzuzeigen.';

  @override
  String get foodAnalysisTutorial => 'Tutorial zur Lebensmittelanalyse';

  @override
  String get foodAnalysisTutorialSubtitle =>
      'Erfahren Sie, wie Sie die Funktionen zur Lebensmittelanalyse nutzen';

  @override
  String get backupCreated => 'Backup erstellt!';

  @override
  String get backupCreatedContent =>
      'Ihre Sicherungsdatei wurde erfolgreich erstellt.';

  @override
  String get backupChooseDestination => 'Wo möchten Sie Ihr Backup speichern?';

  @override
  String get backupSaveToDevice => 'Auf Gerät speichern';

  @override
  String get backupSaveToDeviceDesc =>
      'Speichern Sie es in einem von Ihnen ausgewählten Ordner auf diesem Gerät';

  @override
  String get backupShareToOther => 'Mit anderem Gerät teilen';

  @override
  String get backupShareToOtherDesc =>
      'Senden Sie per Telefon, E-Mail, Google-Laufwerk usw.';

  @override
  String get backupSavedSuccess => 'Backup gespeichert!';

  @override
  String get backupSavedSuccessContent =>
      'Ihre Sicherungsdatei wurde an dem von Ihnen gewählten Speicherort gespeichert.';

  @override
  String get important => 'Wichtig:';

  @override
  String get backupImportantNotes =>
      '• Speichern Sie diese Datei an einem sicheren Ort (Google-Laufwerk usw.).\n• Fotos sind NICHT im Backup enthalten\n• Der Übertragungsschlüssel läuft in 30 Tagen ab\n• Der Schlüssel kann nur einmal verwendet werden';

  @override
  String get restoreBackup => 'Backup wiederherstellen?';

  @override
  String get backupFrom => 'Backup von:';

  @override
  String get date => 'Datum:';

  @override
  String get energy => 'Energie:';

  @override
  String get foodEntries => 'Lebensmitteleinträge:';

  @override
  String get restoreImportant => 'Wichtig';

  @override
  String restoreImportantNotes(String energy) {
    return '• Die aktuelle Energie auf diesem Gerät wird durch Energie aus dem Backup ($energy) ERSETZT.\n• Lebensmitteleinträge werden ZUSAMMENGEFÜHRT (nicht ersetzt)\n• Fotos sind NICHT im Backup enthalten\n• Übertragungsschlüssel wird verwendet (kann nicht wiederverwendet werden)';
  }

  @override
  String get restore => 'Wiederherstellen';

  @override
  String get restoreComplete => 'Wiederherstellung abgeschlossen!';

  @override
  String get restoreCompleteContent =>
      'Ihre Daten wurden erfolgreich wiederhergestellt.';

  @override
  String get newEnergyBalance => 'Neue Energiebilanz:';

  @override
  String get foodEntriesImported => 'Importierte Lebensmitteleinträge:';

  @override
  String get myMealsImported => 'Meine importierten Mahlzeiten:';

  @override
  String get appWillRefresh =>
      'Ihre App wird aktualisiert und zeigt die wiederhergestellten Daten an.';

  @override
  String get backupFailed => 'Sicherung fehlgeschlagen';

  @override
  String get invalidBackupFile => 'Ungültige Sicherungsdatei';

  @override
  String get restoreFailed => 'Wiederherstellung fehlgeschlagen';

  @override
  String get analyticsDataCollection => 'Analytics-Datenerfassung';

  @override
  String get analyticsEnabled =>
      'Analytics aktiviert – ขอบคุณที่ช่วยปรับปรุงแอป';

  @override
  String get analyticsDisabled => 'Analytics deaktiviert – nicht verfügbar';

  @override
  String get enabled => 'Ermöglicht';

  @override
  String get enabledSubtitle => 'Aktiviert – aktiviert';

  @override
  String get disabled => 'Deaktiviert';

  @override
  String get disabledSubtitle => 'Deaktiviert – nicht verfügbar';

  @override
  String get imagesPerDay => 'Bilder pro Tag';

  @override
  String scanUpToImagesPerDay(String limit) {
    return 'Scannen Sie bis zu $limit Bilder pro Tag';
  }

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get resetScanHistory => 'Scanverlauf zurücksetzen';

  @override
  String get resetScanHistorySubtitle =>
      'Löschen Sie alle gescannten Einträge und scannen Sie erneut';

  @override
  String get imagesPerDayDialog => 'Bilder pro Tag';

  @override
  String get maxImagesPerDayDescription =>
      'Maximal zu scannende Bilder pro Tag\nScannt nur das ausgewählte Datum';

  @override
  String scanLimitSetTo(String limit) {
    return 'Das Scanlimit ist auf $limit Bilder pro Tag festgelegt';
  }

  @override
  String get resetScanHistoryDialog => 'Scanverlauf zurücksetzen?';

  @override
  String get resetScanHistoryContent =>
      'Alle in der Galerie gescannten Lebensmitteleinträge werden gelöscht.\nZiehen Sie an einem beliebigen Datum nach unten, um Bilder erneut zu scannen.';

  @override
  String resetComplete(String count) {
    return 'Zurücksetzen abgeschlossen – $count Einträge gelöscht. Zum erneuten Scannen nach unten ziehen.';
  }

  @override
  String questBarStreak(int days) {
    return 'Streak $days Tag';
  }

  @override
  String questBarDaysToNextTier(int days, String tier) {
    return '$days Tage → $tier';
  }

  @override
  String get questBarMaxTier => 'Maximale Stufe! 💎';

  @override
  String get questBarOfferDismissed => 'Angebot ausgeblendet';

  @override
  String get questBarViewOffer => 'Angebot ansehen';

  @override
  String get questBarNoOffersNow => '• Zur Zeit keine Angebote';

  @override
  String get questBarWeeklyChallenges => '🎯 Wöchentliche Herausforderungen';

  @override
  String get questBarMilestones => '🏆 Meilensteine';

  @override
  String get questBarInviteFriends => '👥 Freunde einladen und 20E erhalten';

  @override
  String questBarTimeRemaining(String time) {
    return '⏰ Verbleibende Zeit $time';
  }

  @override
  String questBarClaimDailyEnergy(int energy) {
    return '+${energy}E';
  }

  @override
  String questBarShareReferralError(String error) {
    return 'Fehler beim Teilen: $error';
  }

  @override
  String tierCelebrationTitle(String tier) {
    return '$tier Feier 🎉';
  }

  @override
  String tierCelebrationDay(int day) {
    return 'Tag $day';
  }

  @override
  String get tierCelebrationExpired => 'Abgelaufen';

  @override
  String get tierCelebrationComplete => 'Vollständig!';

  @override
  String questBarWatchAd(int energy) {
    return 'Anzeige ansehen +$energy⚡';
  }

  @override
  String questBarAdRemaining(int remaining, int total) {
    return 'Heute verbleiben noch $remaining/$total';
  }

  @override
  String questBarAdSuccess(int energy) {
    return 'Anzeige gesehen! +$energy Energieeingang...';
  }

  @override
  String get questBarAdNotReady =>
      'Anzeige nicht fertig, bitte versuchen Sie es erneut';

  @override
  String get questBarDailyChallenge => 'Tägliche Herausforderung';

  @override
  String get questBarUseAi => 'Nutzen Sie Energie';

  @override
  String get questBarResetsMonday => 'Wird jeden Montag zurückgesetzt';

  @override
  String get questBarClaimed => 'Behauptet!';

  @override
  String get questBarHideOffer => 'Verstecken';

  @override
  String get questBarViewDetails => 'Sicht';

  @override
  String questBarShareText(String link) {
    return 'Versuchen Sie es mit MiRO! KI-gestützte Lebensmittelanalyse 🍔\nBenutzen Sie diesen Link und wir bekommen beide +20 Energie gratis!\n\n$link';
  }

  @override
  String get questBarShareSubject => 'Versuchen Sie es mit MiRO';

  @override
  String get claimButtonTitle => 'Fordern Sie tägliche Energie an';

  @override
  String claimButtonReceived(String energy) {
    return '+${energy}E erhalten!';
  }

  @override
  String get claimButtonAlreadyClaimed => 'Heute bereits beansprucht';

  @override
  String claimButtonError(String error) {
    return 'Fehler: $error';
  }

  @override
  String get seasonalQuestLimitedTime => 'BEGRENZTE ZEIT';

  @override
  String seasonalQuestDaysLeft(int days) {
    return 'Noch $days Tage';
  }

  @override
  String seasonalQuestRewardDaily(int reward) {
    return '+${reward}E / Tag';
  }

  @override
  String seasonalQuestRewardOnce(int reward) {
    return '+${reward}E einmalig';
  }

  @override
  String get seasonalQuestClaimed => 'Behauptet!';

  @override
  String get seasonalQuestClaimedToday => 'Heute beansprucht';

  @override
  String get errorFailed => 'Fehlgeschlagen';

  @override
  String get errorFailedToClaim =>
      'Anspruch konnte nicht geltend gemacht werden';

  @override
  String errorGeneric(String error) {
    return 'Fehler: $error';
  }

  @override
  String get milestoneNoMilestonesToClaim =>
      'Es sind noch keine Meilensteine ​​zu beanspruchen';

  @override
  String milestoneClaimedEnergy(int energy) {
    return '🎁 +$energy Energie beansprucht!';
  }

  @override
  String get milestoneTitle => 'Meilensteine';

  @override
  String milestoneUseEnergyComplete(int threshold) {
    return 'Energie nutzen $threshold';
  }

  @override
  String milestoneNext(int threshold) {
    return 'Weiter: ${threshold}E';
  }

  @override
  String get milestoneAllComplete => 'Alle Meilensteine ​​erreicht!';

  @override
  String get noEnergyTitle => 'Keine Energie mehr';

  @override
  String get noEnergyContent =>
      'Sie benötigen 1 Energie, um Lebensmittel mit KI zu analysieren';

  @override
  String get noEnergyTip =>
      'Sie können Lebensmittel weiterhin kostenlos manuell (ohne KI) protokollieren';

  @override
  String get noEnergyLater => 'Später';

  @override
  String noEnergyWatchAd(int remaining) {
    return 'Anzeige ansehen ($remaining/3)';
  }

  @override
  String get noEnergyBuyEnergy => 'Kaufen Sie Energie';

  @override
  String get tierBronze => 'Bronze';

  @override
  String get tierSilver => 'Silber';

  @override
  String get tierGold => 'Gold';

  @override
  String get tierDiamond => 'Diamant';

  @override
  String get tierStarter => 'Anlasser';

  @override
  String get tierUpCongratulations => '🎉 Herzlichen Glückwunsch!';

  @override
  String tierUpYouReached(String tier) {
    return 'Du hast $tier erreicht!';
  }

  @override
  String get tierUpMotivation =>
      'Verfolgen Sie Kalorien wie ein Profi\nIhr Traumkörper rückt immer näher!';

  @override
  String tierUpReward(int reward) {
    return '+${reward}E Belohnung!';
  }

  @override
  String get referralAllLevelsClaimed => 'Alle Level erreicht!';

  @override
  String referralLevel(int level, String subtitle) {
    return 'Stufe $level: $subtitle';
  }

  @override
  String referralProgress(int current, int target, int level, int total) {
    return '[$current/$target] (Stufe $level/$total)';
  }

  @override
  String referralClaimedLevel(int level, int reward) {
    return '🎁 Beanspruchtes Level $level: +$reward Energie!';
  }

  @override
  String get challengeUseAi10 => 'Nutze Energie 10';

  @override
  String get specifyIngredients => 'Geben Sie bekannte Zutaten an';

  @override
  String get specifyIngredientsOptional =>
      'Geben Sie bekannte Zutaten an (optional)';

  @override
  String get specifyIngredientsHint =>
      'Geben Sie die Zutaten ein, die Sie kennen, und die KI entdeckt für Sie versteckte Gewürze, Öle und Saucen.';

  @override
  String get sendToAi => 'An AI senden';

  @override
  String get reanalyzeWithIngredients =>
      'Zutaten hinzufügen und erneut analysieren';

  @override
  String get reanalyzeButton => 'Erneut analysieren (1 Energie)';

  @override
  String get ingredientsSaved => 'Zutaten gespart';

  @override
  String get pleaseAddAtLeastOneIngredient =>
      'Bitte fügen Sie mindestens 1 Zutat hinzu';

  @override
  String get hiddenIngredientsDiscovered =>
      'Versteckte Zutaten von KI entdeckt';

  @override
  String get retroScanTitle => 'Aktuelle Fotos scannen?';

  @override
  String get retroScanDescription =>
      'Wir können Ihre Fotos der letzten 7 Tage scannen, um automatisch Lebensmittelfotos zu finden und sie Ihrem Tagebuch hinzuzufügen.';

  @override
  String get retroScanNote =>
      'Es werden nur Lebensmittelfotos erkannt – andere Fotos werden ignoriert. Es verlassen keine Fotos Ihr Gerät.';

  @override
  String get retroScanStart => 'Scannen Sie meine Fotos';

  @override
  String get retroScanSkip => 'Überspringen Sie es vorerst';

  @override
  String get retroScanInProgress => 'Scannen...';

  @override
  String get retroScanTagline =>
      'MiRO verändert Ihr\nLebensmittelfotos in Gesundheitsdaten umwandeln.';

  @override
  String get retroScanFetchingPhotos => 'Aktuelle Fotos werden abgerufen...';

  @override
  String get retroScanAnalyzing => 'Lebensmittelfotos werden erkannt...';

  @override
  String retroScanPhotosFound(int count) {
    return '$count Fotos in den letzten 7 Tagen gefunden';
  }

  @override
  String get retroScanCompleteTitle => 'Scan abgeschlossen!';

  @override
  String retroScanCompleteDesc(int count) {
    return '$count Essensfotos gefunden! Sie wurden Ihrer Zeitleiste hinzugefügt und sind bereit für die KI-Analyse.';
  }

  @override
  String get retroScanNoResultsTitle => 'Keine Lebensmittelfotos gefunden';

  @override
  String get retroScanNoResultsDesc =>
      'In den letzten 7 Tagen wurden keine Lebensmittelfotos erkannt. Versuchen Sie, ein Foto von Ihrer nächsten Mahlzeit zu machen!';

  @override
  String get retroScanAnalyzeHint =>
      'Tippen Sie in Ihrer Chronik auf „Alle analysieren“, um eine KI-Ernährungsanalyse für diese Einträge zu erhalten.';

  @override
  String get retroScanDone => 'Habe es!';

  @override
  String get welcomeEndTitle => 'Willkommen bei MiRO!';

  @override
  String get welcomeEndMessage => 'MiRO steht Ihnen zur Verfügung.';

  @override
  String get welcomeEndJourney => 'Habt eine schöne gemeinsame Reise!!';

  @override
  String get welcomeEndStart => 'Fangen wir an!';

  @override
  String greetingCalorieSummary(
      int remaining, int protein, int carbs, int fat) {
    return 'Hallo! Wie kann ich Ihnen heute helfen? Sie haben noch $remaining kcal übrig. Bisher: Protein ${protein}g, Kohlenhydrate ${carbs}g, Fett ${fat}g. Sagen Sie mir, was Sie gegessen haben – listen Sie alles nach Mahlzeit auf und ich protokolliere alles für Sie. Mehr Details, genauer!!';
  }

  @override
  String greetingCuisineTip(String cuisine) {
    return 'Ihre bevorzugte Küche ist auf $cuisine eingestellt. Sie können es jederzeit in den Einstellungen ändern!';
  }

  @override
  String greetingEnergyTip(int balance) {
    return 'Ihnen stehen $balance Energie zur Verfügung. Vergessen Sie nicht, Ihre tägliche Streak-Belohnung auf dem Energieabzeichen einzufordern!';
  }

  @override
  String get greetingRenamePhotoTip =>
      'Tipp: Sie können Lebensmittelfotos umbenennen, um MiRO eine genauere Analyse zu ermöglichen!';

  @override
  String get greetingAddIngredientsTip =>
      'Tipp: Sie können Zutaten hinzufügen, bei denen Sie sich sicher sind, bevor Sie sie zur Analyse an MiRO senden. Ich werde all die langweiligen kleinen Details für Sie herausfinden!';

  @override
  String greetingBackupReminder(int days) {
    return 'Hey Chef! Sie haben Ihre Daten seit $days Tagen nicht gesichert. Ich empfehle die Sicherung in den Einstellungen – Ihre Daten werden lokal gespeichert und ich kann sie nicht wiederherstellen, wenn etwas passiert!';
  }

  @override
  String get greetingFallback =>
      'Hallo! Wie kann ich Ihnen heute helfen? Sag mir, was du gegessen hast!';

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
  String get hideDetails => 'Hide details';

  @override
  String get showDetails => 'Show details';

  @override
  String get searchModeLabel => 'Search Mode';

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
