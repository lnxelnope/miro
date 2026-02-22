// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class L10nFr extends L10n {
  L10nFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'MiRO';

  @override
  String get save => 'Sauvegarder';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get search => 'Recherche';

  @override
  String get loading => 'Chargement...';

  @override
  String get error => 'Une erreur s\'est produite';

  @override
  String get confirm => 'Confirmer';

  @override
  String get close => 'Fermer';

  @override
  String get done => 'Fait';

  @override
  String get next => 'Suivant';

  @override
  String get skip => 'Sauter';

  @override
  String get retry => 'Réessayer';

  @override
  String get ok => 'D\'ACCORD';

  @override
  String get foodName => 'Nom de l\'aliment';

  @override
  String get calories => 'Calories';

  @override
  String get protein => 'Protein';

  @override
  String get carbs => 'Crabes';

  @override
  String get fat => 'Graisse';

  @override
  String get servingSize => 'Taille de la portion';

  @override
  String get servingUnit => 'Unité';

  @override
  String get kcal => 'kcal';

  @override
  String get mealBreakfast => 'Petit-déjeuner';

  @override
  String get mealLunch => 'Déjeuner';

  @override
  String get mealDinner => 'Dîner';

  @override
  String get mealSnack => 'Collation';

  @override
  String get todaySummary => 'Le résumé du jour';

  @override
  String dateSummary(String date) {
    return 'Résumé pour $date';
  }

  @override
  String get savedSuccess => 'Enregistré avec succès';

  @override
  String get deletedSuccess => 'Supprimé avec succès';

  @override
  String get pleaseEnterFoodName => 'Veuillez entrer le nom de l\'aliment';

  @override
  String get noDataYet => 'Aucune donnée pour l\'instant';

  @override
  String get addFood => 'Ajouter de la nourriture';

  @override
  String get editFood => 'Modifier la nourriture';

  @override
  String get deleteFood => 'Supprimer la nourriture';

  @override
  String get deleteConfirm => 'Confirmer la suppression ?';

  @override
  String get foodLoggedSuccess => 'Nourriture enregistrée !';

  @override
  String get noApiKey => 'Veuillez configurer Gemini API Key';

  @override
  String get noApiKeyDescription =>
      'Accédez au fichier Pro → API Paramètres à configurer';

  @override
  String get apiKeyTitle => 'Configurer Gemini API Key';

  @override
  String get apiKeyRequired => 'API Key requis';

  @override
  String get apiKeyFreeNote => 'Gemini API est gratuit';

  @override
  String get apiKeySetup => 'Configurer API Key';

  @override
  String get testConnection => 'Tester la connexion';

  @override
  String get connectionSuccess => 'Connecté avec succès ! Prêt à l\'emploi';

  @override
  String get connectionFailed => 'La connexion a échoué';

  @override
  String get pasteKey => 'Coller';

  @override
  String get deleteKey => 'Supprimer API Key';

  @override
  String get openAiStudio => 'Ouvrir Google AI Studio';

  @override
  String get chatHint => 'Dites à Miro par ex. \"Bûche de riz frit\"...';

  @override
  String get chatFoodSaved => 'Nourriture enregistrée !';

  @override
  String chatFoodSavedDetail(
      String name, String serving, String unit, String cal) {
    return '$name $serving $unit\n$cal kcal';
  }

  @override
  String get featureNotAvailable =>
      'Désolé, cette fonctionnalité n\'est pas encore disponible';

  @override
  String get goalCalories => 'Calories/jour';

  @override
  String get goalProtein => 'Protein/jour';

  @override
  String get goalCarbs => 'Glucides/jour';

  @override
  String get goalFat => 'Graisse/jour';

  @override
  String get goalWater => 'Eau/jour';

  @override
  String get healthGoals => 'Objectifs de santé';

  @override
  String get profile => 'Fichier Pro';

  @override
  String get settings => 'Paramètres';

  @override
  String get privacyPolicy => 'politique de confidentialité';

  @override
  String get termsOfService => 'Conditions d\'utilisation';

  @override
  String get clearAllData => 'Effacer toutes les données';

  @override
  String get clearAllDataConfirm =>
      'Toutes les données seront supprimées. Cela ne peut pas être annulé !';

  @override
  String get about => 'À propos';

  @override
  String get language => 'Langue';

  @override
  String get upgradePro => 'Mise à niveau vers Pro';

  @override
  String get proUnlocked => 'MiRO Pro';

  @override
  String get proDescription => 'Analyse alimentaire illimitée par l\'IA';

  @override
  String aiRemaining(int remaining, int total) {
    return 'Analyse IA : $remaining/$total restants aujourd\'hui';
  }

  @override
  String get aiLimitReached => 'Limite IA atteinte pour aujourd\'hui (3/3)';

  @override
  String get restorePurchase => 'Restaurer l\'achat';

  @override
  String get myMeals => 'Mes repas :';

  @override
  String get createMeal => 'Créer un repas';

  @override
  String get ingredients => 'Ingrédients';

  @override
  String get searchFood => 'Rechercher de la nourriture';

  @override
  String get analyzing => 'Analyser...';

  @override
  String get analyzeWithAi => 'Analyser avec l\'IA';

  @override
  String get analysisComplete => 'Analyse terminée';

  @override
  String get timeline => 'Chronologie';

  @override
  String get diet => 'Régime';

  @override
  String get quickAdd => 'Ajout rapide';

  @override
  String get welcomeTitle => 'MiRO';

  @override
  String get welcomeSubtitle => 'Enregistrement facile des aliments avec l\'IA';

  @override
  String get onboardingFeature1 => 'Prendre une photo';

  @override
  String get onboardingFeature1Desc =>
      'L\'IA calcule automatiquement les calories';

  @override
  String get onboardingFeature2 => 'Tapez pour vous connecter';

  @override
  String get onboardingFeature2Desc =>
      'Dites \"j\'avais du riz frit\" et c\'est enregistré';

  @override
  String get onboardingFeature3 => 'Résumé quotidien';

  @override
  String get onboardingFeature3Desc =>
      'Suivez kcal, protéines, glucides, graisses';

  @override
  String get basicInfo => 'Informations de base';

  @override
  String get basicInfoDesc =>
      'Pour calculer vos calories quotidiennes recommandées';

  @override
  String get gender => 'Genre';

  @override
  String get male => 'Mâle';

  @override
  String get female => 'Femelle';

  @override
  String get age => 'Âge';

  @override
  String get weight => 'Poids';

  @override
  String get height => 'Hauteur';

  @override
  String get activityLevel => 'Niveau d\'activité';

  @override
  String tdeeResult(int kcal) {
    return 'Votre TDEE : $kcal kcal/jour';
  }

  @override
  String get setupAiTitle => 'Configurer Gemini IA';

  @override
  String get setupAiDesc =>
      'Prenez une photo et l\'IA l\'analyse automatiquement';

  @override
  String get setupNow => 'Configurer maintenant';

  @override
  String get skipForNow => 'Passer pour l\'instant';

  @override
  String get errorTimeout => 'Délai de connexion expiré : veuillez réessayer';

  @override
  String get errorInvalidKey => 'API Key invalide : vérifiez vos paramètres';

  @override
  String get errorNoInternet => 'Pas de connexion Internet';

  @override
  String get errorGeneral => 'Une erreur s\'est produite — veuillez réessayer';

  @override
  String get errorQuotaExceeded =>
      'Quota API dépassé : veuillez patienter et réessayer';

  @override
  String get apiKeyScreenTitle => 'Configurer Gemini API Key';

  @override
  String get analyzeFoodWithAi => 'Analyser les aliments avec l\'IA';

  @override
  String get analyzeFoodWithAiDesc =>
      'Prendre une photo → L\'IA calcule automatiquement les calories\nGemini API est gratuit !';

  @override
  String get openGoogleAiStudio => 'Ouvrir Google AI Studio';

  @override
  String get step1Title => 'Ouvrir Google AI Studio';

  @override
  String get step1Desc =>
      'Cliquez sur le bouton ci-dessous pour créer un API Key';

  @override
  String get step2Title => 'Connectez-vous avec le compte Google';

  @override
  String get step2Desc =>
      'Utilisez votre compte Gmail ou Google (créez-en un gratuitement si vous n\'en avez pas)';

  @override
  String get step3Title => 'Cliquez sur \"Créer API Key\"';

  @override
  String get step3Desc =>
      'Cliquez sur le bouton bleu \"Créer API Key\"\nSi on vous demande de sélectionner un projet Pro → Cliquez sur \"Créer la clé API dans un nouveau projet\"';

  @override
  String get step4Title => 'Copiez la clé et collez-la ci-dessous';

  @override
  String get step4Desc =>
      'Cliquez sur Copier à côté de la clé créée\nLa clé ressemblera à : AIzaSyxxxx...';

  @override
  String get step5Title => 'Collez API Key ici';

  @override
  String get pasteApiKeyHint => 'Collez le API Key copié';

  @override
  String get saveApiKey => 'Enregistrer API Key';

  @override
  String get testingConnection => 'Essai...';

  @override
  String get deleteApiKey => 'Supprimer API Key';

  @override
  String get deleteApiKeyConfirm => 'Supprimer API Key ?';

  @override
  String get deleteApiKeyConfirmDesc =>
      'Vous ne pourrez pas utiliser l\'analyse alimentaire par l\'IA tant que vous ne l\'aurez pas reconfiguré.';

  @override
  String get apiKeySaved => 'API Key enregistré avec succès';

  @override
  String get apiKeyDeleted => 'API Key supprimé avec succès';

  @override
  String get pleasePasteApiKey => 'Veuillez d\'abord coller API Key';

  @override
  String get apiKeyInvalidFormat =>
      'API Key invalide — doit commencer par « AIza »';

  @override
  String get connectionSuccessMessage =>
      '✅ Connecté avec succès ! Prêt à l\'emploi';

  @override
  String get connectionFailedMessage => '❌ La connexion a échoué';

  @override
  String get faqTitle => 'Foire aux questions';

  @override
  String get faqFreeQuestion => 'Est-ce vraiment gratuit ?';

  @override
  String get faqFreeAnswer =>
      'Oui! Gemini 2.0 Flash est gratuit pour 1 500 requêtes/jour\nPour l\'enregistrement des aliments (5 à 15 fois/jour) → Gratuit pour toujours, aucun paiement requis';

  @override
  String get faqSafeQuestion => 'Est-ce sécuritaire?';

  @override
  String get faqSafeAnswer =>
      'API Key est stocké dans le stockage sécurisé sur votre appareil uniquement\nL\'application n\'envoie pas la clé à notre serveur\nSi la clé fuit → Supprimez et créez-en une nouvelle (ce n\'est pas votre mot de passe Google)';

  @override
  String get faqNoKeyQuestion => 'Que se passe-t-il si je ne crée pas de clé ?';

  @override
  String get faqNoKeyAnswer =>
      'Vous pouvez toujours utiliser l\'application ! Mais :\n❌ Impossible de prendre une photo → Analyse IA\n✅ Peut enregistrer les aliments manuellement\n✅ L\'ajout rapide fonctionne\n✅ Voir les travaux de résumé kcal/macro';

  @override
  String get faqCreditCardQuestion => 'Ai-je besoin d\'une carte de crédit ?';

  @override
  String get faqCreditCardAnswer =>
      'Non — Créez API Key gratuitement sans carte de crédit';

  @override
  String get navDashboard => 'Tableau de bord';

  @override
  String get navMyMeals => 'Mes repas';

  @override
  String get navCamera => 'Caméra';

  @override
  String get navAiChat => 'Chat IA';

  @override
  String get navProfile => 'Fichier Pro';

  @override
  String get appBarTodayIntake => 'La prise d\'aujourd\'hui';

  @override
  String get appBarMyMeals => 'Mes repas';

  @override
  String get appBarCamera => 'Caméra';

  @override
  String get appBarAiChat => 'Chat IA';

  @override
  String get appBarMiro => 'MIRO';

  @override
  String get permissionRequired => 'Autorisation requise';

  @override
  String get permissionRequiredDesc =>
      'MIRO a besoin d\'accéder aux éléments suivants :';

  @override
  String get permissionPhotos => 'Photos — pour numériser des aliments';

  @override
  String get permissionCamera =>
      'Appareil photo – pour photographier la nourriture';

  @override
  String get permissionSkip => 'Sauter';

  @override
  String get permissionAllow => 'Permettre';

  @override
  String get permissionAllGranted => 'Toutes les autorisations accordées';

  @override
  String permissionDenied(String denied) {
    return 'Autorisation refusée : $denied';
  }

  @override
  String get openSettings => 'Ouvrir les paramètres';

  @override
  String get exitAppTitle => 'Quitter l\'application ?';

  @override
  String get exitAppMessage => 'Êtes-vous sûr de vouloir quitter ?';

  @override
  String get exit => 'Sortie';

  @override
  String get healthGoalsTitle => 'Objectifs de santé';

  @override
  String get healthGoalsInfo =>
      'Définissez votre objectif calorique quotidien, vos macros et vos budgets par repas.\nVerrouillage pour calculer automatiquement : 2 macros ou 3 repas.';

  @override
  String get dailyCalorieGoal => 'Objectif calorique quotidien';

  @override
  String get proteinLabel => 'Protein';

  @override
  String get carbsLabel => 'Crabes';

  @override
  String get fatLabel => 'Graisse';

  @override
  String get autoBadge => 'auto';

  @override
  String kcalPerGram(int kcalPerGram, int kcal) {
    return '$kcalPerGram kcal/g • $kcal __SW0__';
  }

  @override
  String get mealCalorieBudget => 'Budget calorique des repas';

  @override
  String mealBudgetBalanced(int total, int goal) {
    return 'Total $total kcal = Objectif $goal __SW0__';
  }

  @override
  String mealBudgetRemaining(int total, int goal, int remaining) {
    return 'Total $total / $goal kcal ($remaining restant)';
  }

  @override
  String get lockMealsHint =>
      'Verrouillez 3 repas pour calculer automatiquement le 4ème';

  @override
  String get breakfastLabel => 'Petit-déjeuner';

  @override
  String get lunchLabel => 'Déjeuner';

  @override
  String get dinnerLabel => 'Dîner';

  @override
  String get snackLabel => 'Collation';

  @override
  String percentOfDailyGoal(String percent) {
    return '$percent % de l\'objectif quotidien';
  }

  @override
  String get smartSuggestionRange => 'Gamme de suggestions intelligentes';

  @override
  String get smartSuggestionHow =>
      'Comment fonctionne la suggestion intelligente ?';

  @override
  String smartSuggestionDesc(int threshold, int min, int max) {
    return 'Nous vous suggérons des aliments de vos Mes repas, des ingrédients et des repas d\'hier qui correspondent à votre budget par repas.\n\nCe seuil contrôle la flexibilité des suggestions. Par exemple, si votre budget déjeuner est de 700 kcal et que votre seuil est de $threshold __SW0__, nous vous suggérerons des aliments compris entre $min et $max __SW0__.';
  }

  @override
  String get suggestionThreshold => 'Seuil de suggestion';

  @override
  String suggestionThresholdDesc(int threshold) {
    return 'Autoriser les aliments ± $threshold kcal du budget repas';
  }

  @override
  String get goalsSavedSuccess => 'Objectifs enregistrés avec succès !';

  @override
  String get canOnlyLockTwoMacros =>
      'Ne peut verrouiller que 2 macros à la fois';

  @override
  String get canOnlyLockThreeMeals =>
      'Ne peut verrouiller que 3 repas ; le 4ème calcule automatiquement';

  @override
  String get tabMeals => 'Repas';

  @override
  String get tabIngredients => 'Ingrédients';

  @override
  String get searchMealsOrIngredients =>
      'Rechercher des repas ou des ingrédients...';

  @override
  String get createNewMeal => 'Créer un nouveau repas';

  @override
  String get addIngredient => 'Ajouter un ingrédient';

  @override
  String get noMealsYet => 'Pas encore de repas';

  @override
  String get noMealsYetDesc =>
      'Analysez les aliments avec l\'IA pour sauvegarder automatiquement les repas\nou créez-en un manuellement';

  @override
  String get noIngredientsYet => 'Pas encore d\'ingrédients';

  @override
  String get noIngredientsYetDesc =>
      'Quand vous analysez des aliments avec l’IA\nles ingrédients seront enregistrés automatiquement';

  @override
  String mealCreated(String name) {
    return '\"$name\" créé';
  }

  @override
  String mealLogged(String name) {
    return 'Enregistré \"$name\"';
  }

  @override
  String ingredientAmount(String unit) {
    return 'Montant ($unit)';
  }

  @override
  String ingredientLogged(String name, String amount, String unit) {
    return 'Enregistré \"$name\" $amount$unit';
  }

  @override
  String get mealNotFound => 'Repas introuvable';

  @override
  String mealUpdated(String name) {
    return '\"$name\" mis à jour';
  }

  @override
  String get deleteMealTitle => 'Supprimer le repas ?';

  @override
  String deleteMealMessage(String name) {
    return '\"$name\"';
  }

  @override
  String get deleteMealNote => 'Les ingrédients ne seront pas supprimés.';

  @override
  String get mealDeleted => 'Repas supprimé';

  @override
  String ingredientCreated(String name) {
    return '\"$name\" créé';
  }

  @override
  String get ingredientNotFound => 'Ingrédient introuvable';

  @override
  String ingredientUpdated(String name) {
    return '\"$name\" mis à jour';
  }

  @override
  String get deleteIngredientTitle => 'Supprimer l\'ingrédient ?';

  @override
  String deleteIngredientMessage(String name) {
    return '\"$name\"';
  }

  @override
  String get ingredientDeleted => 'Ingrédient supprimé';

  @override
  String get noIngredientsData => 'Aucune donnée sur les ingrédients';

  @override
  String ingredientDetail(String name, String amount, String unit) {
    return '$name ($amount $unit)';
  }

  @override
  String ingredientCalories(int calories) {
    return '$calories kcal';
  }

  @override
  String get useThisMeal => 'Utilisez ce repas';

  @override
  String errorLoading(String error) {
    return 'Erreur de chargement : $error';
  }

  @override
  String scanFoundNewImages(int count, String date) {
    return 'J\'ai trouvé $count nouvelles images sur $date';
  }

  @override
  String scanNoNewImages(String date) {
    return 'Aucune nouvelle image trouvée sur $date';
  }

  @override
  String aiAnalysisRemaining(int remaining, int total) {
    return 'Analyse IA : $remaining/$total restants aujourd\'hui';
  }

  @override
  String get upgradeToProUnlimited =>
      'Passez à Pro pour une utilisation illimitée';

  @override
  String get upgrade => 'Mise à niveau';

  @override
  String get confirmDelete => 'Confirmer la suppression';

  @override
  String confirmDeleteMessage(String name) {
    return 'Voulez-vous supprimer « $name » ?';
  }

  @override
  String get entryDeletedSuccess => '✅ Entrée supprimée avec succès';

  @override
  String entryDeleteError(String error) {
    return '❌ Erreur : $error';
  }

  @override
  String batchAnalyzeItems(int count) {
    return '$count articles (lot)';
  }

  @override
  String analyzeCancelled(int success) {
    return 'Annulé – analyse réussie des éléments $success';
  }

  @override
  String analyzeSuccessAll(int success) {
    return '✅ Analyse réussie des éléments $success';
  }

  @override
  String analyzeSuccessPartial(int success, int total, int failed) {
    return '⚠️ Analyse des éléments $success/$total ($failed a échoué)';
  }

  @override
  String analyzeProgress(String item, int current, int total) {
    return '$item ($current/$total)';
  }

  @override
  String get pullToScanMeal => 'Tirez pour scanner votre repas';

  @override
  String get analyzeAll => 'Analyser tout';

  @override
  String get addFoodTitle => 'Ajouter de la nourriture';

  @override
  String get foodNameRequired => 'Nom de l\'aliment *';

  @override
  String get foodNameHint =>
      'Tapez pour rechercher, par ex. riz frit, salade de papaye';

  @override
  String get selectedFromMyMeal =>
      '✅ Sélectionné dans Mon repas - données nutritionnelles remplies automatiquement';

  @override
  String get foundInDatabase =>
      '✅ Trouvé dans la base de données — données nutritionnelles remplies automatiquement';

  @override
  String get saveAndAnalyze => 'Enregistrer et analyser';

  @override
  String get notFoundInDatabase =>
      'Introuvable dans la base de données — sera analysé en arrière-plan';

  @override
  String get amountLabel => 'Montant';

  @override
  String get unitLabel => 'Unité';

  @override
  String get nutritionAutoCalculated => 'Nutrition (auto-calculée par montant)';

  @override
  String get nutritionEnterZero => 'Nutrition (entrez 0 si inconnu)';

  @override
  String get caloriesLabel => 'Calories (kcal)';

  @override
  String get proteinLabelShort => 'Protéine (g)';

  @override
  String get carbsLabelShort => 'Glucides (g)';

  @override
  String get fatLabelShort => 'Graisse (g)';

  @override
  String get mealTypeLabel => 'Type de repas';

  @override
  String get pleaseEnterFoodNameFirst =>
      'Veuillez d\'abord saisir le nom de l\'aliment';

  @override
  String get savedAnalyzingBackground =>
      '✅ Enregistré - analyse en arrière-plan';

  @override
  String get foodAdded => '✅ Nourriture ajoutée';

  @override
  String get suggestionSourceMyMeal => 'Mon repas';

  @override
  String get suggestionSourceIngredient => 'Ingrédient';

  @override
  String get suggestionSourceDatabase => 'Base de données';

  @override
  String get editFoodTitle => 'Modifier la nourriture';

  @override
  String get foodNameLabel => 'Nom de l\'aliment';

  @override
  String get changeAmountAutoUpdate =>
      'Modifier la quantité → les calories sont mises à jour automatiquement';

  @override
  String baseNutrition(int calories, String unit) {
    return 'Socle : $calories kcal / 1 $unit';
  }

  @override
  String get calculatedFromIngredients =>
      'Calculé à partir des ingrédients ci-dessous';

  @override
  String get ingredientsEditable => 'Ingrédients (modifiables)';

  @override
  String get addIngredientButton => 'Ajouter';

  @override
  String get noIngredientsAddHint =>
      'Aucun ingrédient - appuyez sur \"Ajouter\" pour en ajouter un nouveau';

  @override
  String get editIngredientsHint =>
      'Modifier le nom/montant → Appuyez sur l\'icône de recherche pour rechercher la base de données ou l\'IA';

  @override
  String get ingredientNameHint => 'par ex. Œuf de poule';

  @override
  String get searchDbOrAi => 'Rechercher dans la base de données/IA';

  @override
  String get amountHint => 'Montant';

  @override
  String get fromDatabase => 'À partir de la base de données';

  @override
  String subIngredients(int count) {
    return 'Sous-ingrédients ($count)';
  }

  @override
  String get addSubIngredient => 'Ajouter';

  @override
  String get subIngredientNameHint => 'Nom du sous-ingrédient';

  @override
  String get amountShort => 'Montant';

  @override
  String get pleaseEnterSubIngredientName =>
      'Veuillez d\'abord saisir le nom du sous-ingrédient';

  @override
  String foundInDatabaseSub(String name) {
    return '\"$name\" trouvé dans la base de données !';
  }

  @override
  String aiAnalyzedSub(String name) {
    return 'L\'IA a analysé \"$name\" (-1 énergie)';
  }

  @override
  String get couldNotAnalyzeSub => 'Impossible d\'analyser le sous-ingrédient';

  @override
  String get pleaseEnterIngredientName =>
      'Veuillez entrer le nom de l\'ingrédient';

  @override
  String get reAnalyzeTitle => 'Réanalyser ?';

  @override
  String reAnalyzeMessage(String name) {
    return '\"$name\" contient déjà des données nutritionnelles.\n\nUne nouvelle analyse utilisera 1 énergie.\n\nContinuer?';
  }

  @override
  String get reAnalyzeButton => 'Réanalyser (1 énergie)';

  @override
  String get amountNotSpecified => 'Montant non précisé';

  @override
  String amountNotSpecifiedMessage(String name) {
    return 'Veuillez d\'abord préciser le montant pour « $name »\nOu utiliser 100 g par défaut ?';
  }

  @override
  String get useDefault100g => 'Utiliser 100 g';

  @override
  String aiAnalyzedResult(String name, int calories) {
    return 'IA : \"$name\" → $calories kcal';
  }

  @override
  String get unableToAnalyze => 'Impossible d\'analyser';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get savedSuccessfully => '✅ Enregistré avec succès';

  @override
  String get confirmFoodPhoto => 'Confirmer la photo de la nourriture';

  @override
  String get photoSavedAutomatically => 'Photo enregistrée automatiquement';

  @override
  String get foodNameHintExample => 'par exemple, salade de poulet grillé';

  @override
  String get quantityLabel => 'Quantité';

  @override
  String get quantityHint => '1';

  @override
  String get optionalFoodInfo =>
      'La saisie du nom et de la quantité de l\'aliment est facultative, mais leur fourniture améliorera la précision de l\'analyse de l\'IA.';

  @override
  String get saveOnly => 'Enregistrer uniquement';

  @override
  String get pleaseEnterValidQuantity => 'Veuillez entrer une quantité valide';

  @override
  String analyzedResult(String name, int calories) {
    return '✅ Analysé : $name — $calories kcal';
  }

  @override
  String get couldNotAnalyzeSaved =>
      '⚠️ Analyse impossible — enregistré, utilisez « Tout analyser » plus tard';

  @override
  String get savedAnalyzeLater =>
      '✅ Enregistré - analysez plus tard avec \"Analyser tout\"';

  @override
  String get editIngredientTitle => 'Modifier l\'ingrédient';

  @override
  String get ingredientNameRequired => 'Nom de l\'ingrédient *';

  @override
  String get baseAmountLabel => 'Montant de base';

  @override
  String get baseAmountHint => '100';

  @override
  String nutritionPerBase(String amount, String unit) {
    return 'Nutrition par $amount $unit';
  }

  @override
  String nutritionCalculatedPerBase(String amount, String unit) {
    return 'Nutrition calculée par $amount $unit — le système calculera automatiquement en fonction de la quantité réelle consommée';
  }

  @override
  String get createIngredient => 'Créer un ingrédient';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get pleaseEnterIngredientNameFirst =>
      'Veuillez d\'abord entrer le nom de l\'ingrédient';

  @override
  String aiAnalyzedIngredient(
      String name, String amount, String unit, int calories) {
    return 'IA : \"$name\" $amount $unit → $calories kcal';
  }

  @override
  String get unableToFindIngredient => 'Impossible de trouver cet ingrédient';

  @override
  String searchFailed(String error) {
    return 'Échec de la recherche : $error';
  }

  @override
  String deleteEntriesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Entries',
      one: 'Entry',
    );
    return 'Supprimer $count $_temp0 ?';
  }

  @override
  String deleteEntriesMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return 'Supprimer $count aliment sélectionné $_temp0 ?';
  }

  @override
  String get deleteAll => 'Supprimer tout';

  @override
  String deletedEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return 'Supprimé $count $_temp0';
  }

  @override
  String movedEntriesToDate(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return 'Déplacé $count $_temp0 vers $date';
  }

  @override
  String get allSelectedAlreadyAnalyzed =>
      'Toutes les entrées sélectionnées sont déjà analysées';

  @override
  String analyzeCancelledSelected(int success) {
    return 'Annulé — $success analysé';
  }

  @override
  String analyzedEntriesAll(int success) {
    String _temp0 = intl.Intl.pluralLogic(
      success,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return 'Analysé $success $_temp0';
  }

  @override
  String analyzedEntriesPartial(int success, int total, int failed) {
    return 'Analysé $success/$total ($failed a échoué)';
  }

  @override
  String analyzeProgressSelected(int current, int total, String item) {
    return '$current/$total $item';
  }

  @override
  String get noEntriesYet => 'Aucune entrée pour l\'instant';

  @override
  String get selectAll => 'Tout sélectionner';

  @override
  String get deselectAll => 'Tout désélectionner';

  @override
  String get moveToDate => 'Déplacer à ce jour';

  @override
  String get analyzeSelected => 'Analyser la sélection';

  @override
  String get deleteTooltip => 'Supprimer';

  @override
  String get move => 'Se déplacer';

  @override
  String get deleteTooltipAction => 'Supprimer';

  @override
  String switchToModeTitle(String mode) {
    return 'Passer en mode $mode ?';
  }

  @override
  String switchToModeMessage(String current, String newMode) {
    return 'Cet élément a été analysé comme $current.\n\nUne nouvelle analyse en tant que $newMode utilisera 1 énergie.\n\nContinuer?';
  }

  @override
  String analyzingAsMode(String mode) {
    return 'Analyse comme $mode...';
  }

  @override
  String reAnalyzedAsMode(String mode) {
    return '✅ Ré-analysé comme $mode';
  }

  @override
  String get analysisFailed => '❌ L\'analyse a échoué';

  @override
  String get aiAnalysisComplete => '✅ IA analysée et enregistrée';

  @override
  String get changeMealType => 'Changer le type de repas';

  @override
  String get moveToAnotherDate => 'Déplacer à une autre date';

  @override
  String currentDate(String date) {
    return 'Actuel : $date';
  }

  @override
  String get cancelDateChange => 'Annuler le changement de date';

  @override
  String get undo => 'Défaire';

  @override
  String get chatHistory => 'Historique des discussions';

  @override
  String get newChat => 'Nouvelle discussion';

  @override
  String get quickActions => 'Actions rapides';

  @override
  String get clear => 'Clair';

  @override
  String get helloImMiro => 'Bonjour! Je m\'appelle Miro';

  @override
  String get tellMeWhatYouAteToday =>
      'Dis-moi ce que tu as mangé aujourd\'hui !';

  @override
  String get tellMeWhatYouAte => 'Dis-moi ce que tu as mangé...';

  @override
  String get clearHistoryTitle => 'Effacer l\'historique ?';

  @override
  String get clearHistoryMessage =>
      'Tous les messages de cette session seront supprimés.';

  @override
  String get chatHistoryTitle => 'Historique des discussions';

  @override
  String get newLabel => 'Nouveau';

  @override
  String get noChatHistoryYet => 'Pas encore d\'historique de discussion';

  @override
  String get active => 'Actif';

  @override
  String get deleteChatTitle => 'Supprimer le chat ?';

  @override
  String deleteChatMessage(String title) {
    return 'Supprimer \"$title\" ?';
  }

  @override
  String weeklySummaryTitle(String start, String end) {
    return '📊 Résumé hebdomadaire ($start - $end)';
  }

  @override
  String daySummary(String day, String calories, String emoji, String diff) {
    return '📅 $day : $calories kcal $emoji ($diff)';
  }

  @override
  String overTarget(String amount) {
    return '$amount au-dessus de l\'objectif';
  }

  @override
  String underTarget(String amount) {
    return '$amount sous l\'objectif';
  }

  @override
  String get noFoodLoggedThisWeek =>
      'Aucun aliment n\'a encore été enregistré cette semaine.';

  @override
  String averageKcalPerDay(String average) {
    return '🔥 Moyenne : $average kcal/jour';
  }

  @override
  String targetKcalPerDay(String target) {
    return '🎯 Objectif : $target kcal/jour';
  }

  @override
  String resultOverTarget(String amount) {
    return '📈 Résultat : $amount kcal au-dessus de l\'objectif';
  }

  @override
  String resultUnderTarget(String amount) {
    return '📈 Résultat : $amount kcal sous l\'objectif — Excellent travail ! 💪';
  }

  @override
  String failedToLoadWeeklySummary(String error) {
    return '❌ Échec du chargement du résumé hebdomadaire : $error';
  }

  @override
  String monthlySummaryTitle(String month, int year) {
    return '📊 Résumé mensuel ($month $year)';
  }

  @override
  String totalDays(int days) {
    return '📅 Nombre total de jours : $days';
  }

  @override
  String totalConsumed(String calories) {
    return '🔥 Total consommé : $calories kcal';
  }

  @override
  String targetTotal(String target) {
    return '🎯 Total cible : $target kcal';
  }

  @override
  String averageKcalPerDayShort(String average) {
    return '📈 Moyenne : $average kcal/jour';
  }

  @override
  String overTargetThisMonth(String amount) {
    return '⚠️ $amount kcal au-dessus de l\'objectif ce mois-ci';
  }

  @override
  String underTargetThisMonth(String amount) {
    return '✅ $amount kcal sous l\'objectif — Excellent ! 💪';
  }

  @override
  String failedToLoadMonthlySummary(String error) {
    return '❌ Échec du chargement du résumé mensuel : $error';
  }

  @override
  String get localAiHelpTitle => '🤖 Aide IA locale';

  @override
  String get localAiHelpFormat => 'Format : [nourriture] [quantité] [unité]';

  @override
  String get localAiHelpExamples =>
      'Exemples :\n• poulet 100 g et riz 200 g\n• pizza 2 tranches\n• pomme 1 morceau, banane 1 morceau';

  @override
  String get localAiHelpNote =>
      'Remarque : anglais uniquement, analyse de base\nPassez à Miro AI pour de meilleurs résultats !';

  @override
  String hiNoFoodLogged(String target) {
    return '🤖 Salut ! Aucun aliment n\'a encore été enregistré aujourd\'hui.\n   Cible : $target kcal — Prêt à commencer la journalisation ? 🍽️';
  }

  @override
  String hiKcalLeft(String remaining) {
    return '🤖 Salut ! Il vous reste $remaining kcal pour aujourd\'hui.\n   Prêt à enregistrer vos repas ? 😊';
  }

  @override
  String hiOverTarget(String calories, String over) {
    return '🤖 Salut ! Vous avez consommé $calories kcal aujourd\'hui.\n   $over __SW0__ au-dessus de l\'objectif — Continuons à suivre ! 💪';
  }

  @override
  String get hiReadyToLog => '🤖 Salut ! Prêt à enregistrer vos repas ? 😊';

  @override
  String get notEnoughEnergy => 'Pas assez d\'énergie';

  @override
  String get thinkingMealIdeas =>
      '🤖 Je pense à de bonnes idées de repas pour vous...';

  @override
  String get recentMeals => 'Repas récents :';

  @override
  String get noRecentFood => 'Aucun aliment récent enregistré.';

  @override
  String remainingCaloriesToday(String remaining) {
    return '. Calories restantes aujourd\'hui : $remaining kcal.';
  }

  @override
  String failedToGetMenuSuggestions(String error) {
    return '❌ Échec de l\'obtention des suggestions de menu : $error';
  }

  @override
  String get mealSuggestionsTitle =>
      '🤖 En fonction de votre journal alimentaire, voici 3 suggestions de repas :';

  @override
  String mealSuggestionItem(
      int index, String emoji, String name, String calories) {
    return '$index. $emoji $name (~$calories kcal)';
  }

  @override
  String mealSuggestionMacros(String protein, String carbs, String fat) {
    return 'P : ${protein}g | C : ${carbs}g | F : ${fat}g';
  }

  @override
  String get pickOneAndLog =>
      'Choisissez-en un et je l\'enregistrerai pour vous ! 😊';

  @override
  String energyCost(int cost) {
    return '⚡ -$cost Énergie';
  }

  @override
  String get giveMeTipsForHealthyEating =>
      'Donnez-moi des conseils pour manger sainement';

  @override
  String get howManyCaloriesToday => 'Combien de calories aujourd\'hui ?';

  @override
  String get menuLabel => 'Menu';

  @override
  String get weeklyLabel => 'Hebdomadaire';

  @override
  String get monthlyLabel => 'Mensuel';

  @override
  String get tipsLabel => 'Conseils';

  @override
  String get summaryLabel => 'Résumé';

  @override
  String get helpLabel => 'Aide';

  @override
  String get onboardingWelcomeSubtitle =>
      'Suivez les calories sans effort\navec une analyse basée sur l\'IA';

  @override
  String get onboardingSnap => 'Instantané';

  @override
  String get onboardingSnapDesc => 'L\'IA analyse instantanément';

  @override
  String get onboardingType => 'Taper';

  @override
  String get onboardingTypeDesc => 'Connectez-vous en quelques secondes';

  @override
  String get onboardingEdit => 'Modifier';

  @override
  String get onboardingEditDesc => 'Affiner la précision';

  @override
  String get onboardingNext => 'Suivant →';

  @override
  String get onboardingDisclaimer =>
      'Données estimées par l’IA. Pas un avis médical.';

  @override
  String get onboardingQuickSetup => 'Configuration rapide';

  @override
  String get onboardingHelpAiUnderstand =>
      'Aidez l’IA à mieux comprendre votre alimentation';

  @override
  String get onboardingYourTypicalCuisine => 'Votre cuisine typique :';

  @override
  String get onboardingDailyCalorieGoal =>
      'Objectif calorique quotidien (facultatif) :';

  @override
  String get onboardingKcalPerDay => 'kcal/jour';

  @override
  String get onboardingCalorieGoalHint => '2000';

  @override
  String get onboardingCanChangeAnytime =>
      'Vous pouvez modifier cela à tout moment dans les paramètres du fichier Pro';

  @override
  String get onboardingYoureAllSet => 'Vous êtes prêt !';

  @override
  String get onboardingStartTracking =>
      'Commencez à suivre vos repas dès aujourd\'hui.\nPrenez une photo ou tapez ce que vous avez mangé.';

  @override
  String get onboardingWelcomeGift => 'Cadeau de bienvenue';

  @override
  String get onboardingFreeEnergy => '10 Énergie GRATUITE';

  @override
  String get onboardingFreeEnergyDesc => '= 10 analyses IA pour commencer';

  @override
  String get onboardingEnergyCost =>
      'Chaque analyse coûte 1 Énergie\nPlus vous en utilisez, plus vous gagnez !';

  @override
  String get onboardingStartTrackingButton => 'Commencez le suivi ! →';

  @override
  String get onboardingNoCreditCard =>
      'Pas de carte de crédit • Pas de frais cachés';

  @override
  String get cameraTakePhotoOfFood => 'Prenez une photo de votre nourriture';

  @override
  String get cameraFailedToInitialize =>
      'Échec de l\'initialisation de la caméra';

  @override
  String get cameraFailedToCapture => 'Échec de la capture de la photo';

  @override
  String get cameraFailedToPickFromGallery =>
      'Échec de la sélection de l\'image dans la galerie';

  @override
  String get cameraProcessing => 'Processation...';

  @override
  String get referralInviteFriends => 'Inviter des amis';

  @override
  String get referralYourReferralCode => 'Votre code de parrainage';

  @override
  String get referralLoading => 'Chargement...';

  @override
  String get referralCopy => 'Copie';

  @override
  String get referralShareCodeDescription =>
      'Partagez ce code avec vos amis ! Lorsqu’ils utilisent l’IA 3 fois, vous obtenez tous les deux des récompenses !';

  @override
  String get referralEnterReferralCode => 'Entrez le code de référence';

  @override
  String get referralCodeHint => 'MIRO-XXXX-XXXX-XXXX';

  @override
  String get referralSubmitCode => 'Soumettre le code';

  @override
  String get referralPleaseEnterCode => 'Veuillez entrer un code de parrainage';

  @override
  String get referralCodeAccepted => 'Code de parrainage accepté !';

  @override
  String get referralCodeCopied =>
      'Code de parrainage copié dans le presse-papier !';

  @override
  String referralEnergyBonus(int energy) {
    return '+$energy Énergie !';
  }

  @override
  String get referralHowItWorks => 'Comment ça marche';

  @override
  String get referralStep1Title => 'Partagez votre code de parrainage';

  @override
  String get referralStep1Description =>
      'Copiez et partagez votre identifiant MiRO avec vos amis';

  @override
  String get referralStep2Title => 'Un ami entre votre code';

  @override
  String get referralStep2Description =>
      'Ils obtiennent immédiatement +20 d\'énergie';

  @override
  String get referralStep3Title => 'Un ami utilise l\'IA 3 fois';

  @override
  String get referralStep3Description =>
      'Lorsqu\'ils terminent 3 analyses d\'IA';

  @override
  String get referralStep4Title => 'Vous êtes récompensé !';

  @override
  String get referralStep4Description => 'Vous recevez +5 Énergie !';

  @override
  String get tierBenefitsTitle => 'Avantages du niveau';

  @override
  String get tierBenefitsUnlockRewards =>
      'Débloquez des récompenses\navec des séquences quotidiennes';

  @override
  String get tierBenefitsKeepStreakDescription =>
      'Maintenez votre séquence en vie pour débloquer des niveaux supérieurs et gagner des avantages incroyables !';

  @override
  String get tierBenefitsHowItWorks => 'Comment ça marche';

  @override
  String get tierBenefitsDailyEnergyReward =>
      'Récompense énergétique quotidienne';

  @override
  String get tierBenefitsDailyEnergyDescription =>
      'Utilisez l\'IA au moins une fois par jour pour gagner de l\'énergie bonus. Niveaux supérieurs = plus d\'énergie quotidienne !';

  @override
  String get tierBenefitsPurchaseBonus => 'Bonus d\'achat';

  @override
  String get tierBenefitsPurchaseBonusDescription =>
      'Les niveaux Or et Diamant reçoivent de l\'énergie supplémentaire sur chaque achat (10 à 20 % de plus !)';

  @override
  String get tierBenefitsGracePeriod => 'Délai de grâce';

  @override
  String get tierBenefitsGracePeriodDescription =>
      'Manquez une journée sans perdre votre séquence. Les niveaux Argent+ bénéficient d’une protection !';

  @override
  String get tierBenefitsAllTiers => 'Tous les niveaux';

  @override
  String get tierBenefitsNew => 'NOUVEAU';

  @override
  String get tierBenefitsPopular => 'POPULAIRE';

  @override
  String get tierBenefitsBest => 'MEILLEUR';

  @override
  String get tierBenefitsDailyCheckIn => 'Enregistrement quotidien';

  @override
  String get tierBenefitsProTips => 'Pro Conseils';

  @override
  String get tierBenefitsTip1 =>
      'Utilisez l\'IA quotidiennement pour gagner de l\'énergie gratuite et développer votre séquence';

  @override
  String get tierBenefitsTip2 =>
      'Le niveau Diamant rapporte +4 d\'énergie par jour, soit 120/mois !';

  @override
  String get tierBenefitsTip3 =>
      'Le bonus d’achat s’applique à TOUS les forfaits énergie !';

  @override
  String get tierBenefitsTip4 =>
      'Le délai de grâce protège votre séquence si vous manquez une journée';

  @override
  String get subscriptionEnergyPass => 'Pass Energie';

  @override
  String get subscriptionInAppPurchasesNotAvailable =>
      'Les achats intégrés ne sont pas disponibles';

  @override
  String get subscriptionFailedToInitiatePurchase =>
      'Échec de l\'initialisation de l\'achat';

  @override
  String subscriptionError(String error) {
    return 'Erreur : $error';
  }

  @override
  String get subscriptionFailedToLoad => 'Échec du chargement de l\'abonnement';

  @override
  String get subscriptionUnknownError => 'Erreur inconnue';

  @override
  String get subscriptionRetry => 'Réessayer';

  @override
  String get subscriptionEnergyPassActive => 'Pass Energie Actif';

  @override
  String get subscriptionUnlimitedAccess => 'Vous avez un accès illimité';

  @override
  String get subscriptionStatus => 'Statut';

  @override
  String get subscriptionRenews => 'Renouvelle';

  @override
  String get subscriptionPrice => 'Prix';

  @override
  String get subscriptionYourBenefits => 'Vos avantages';

  @override
  String get subscriptionManageSubscription => 'Gérer l\'abonnement';

  @override
  String get subscriptionNoProductAvailable =>
      'Aucun produit d\'abonnement disponible';

  @override
  String get subscriptionWhatYouGet => 'Ce que vous obtenez';

  @override
  String get subscriptionPerMonth => 'par mois';

  @override
  String get subscriptionSubscribeNow => 'Abonnez-vous maintenant';

  @override
  String get subscriptionCancelAnytime => 'Annuler à tout moment';

  @override
  String get subscriptionAutoRenewTerms =>
      'Votre abonnement sera renouvelé automatiquement. Vous pouvez annuler à tout moment à partir de Google Play.';

  @override
  String get disclaimerHealthDisclaimer =>
      'Avis de non-responsabilité concernant la santé';

  @override
  String get disclaimerImportantReminders => 'Rappels importants :';

  @override
  String get disclaimerBullet1 =>
      'Toutes les données nutritionnelles sont estimées';

  @override
  String get disclaimerBullet2 =>
      'L\'analyse de l\'IA peut contenir des erreurs';

  @override
  String get disclaimerBullet3 =>
      'Ne remplace pas les conseils d\'un professionnel';

  @override
  String get disclaimerBullet4 =>
      'Consulter des prestataires de soins de santé pour obtenir des conseils médicaux';

  @override
  String get disclaimerBullet5 =>
      'Utilisez à votre propre discrétion et à vos risques';

  @override
  String get disclaimerIUnderstand => 'Je comprends';

  @override
  String get privacyPolicyTitle => 'politique de confidentialité';

  @override
  String get privacyPolicySubtitle =>
      'MiRO — Mon enregistrement d\'admission Oracle';

  @override
  String get privacyPolicyHeaderNote =>
      'Vos données alimentaires restent sur votre appareil. Bilan énergétique synchronisé en toute sécurité via Firebase.';

  @override
  String get privacyPolicySectionInformationWeCollect =>
      'Informations que nous collectons';

  @override
  String get privacyPolicySectionDataStorage => 'Stockage des données';

  @override
  String get privacyPolicySectionDataTransmission =>
      'Transmission de données à des tiers';

  @override
  String get privacyPolicySectionRequiredPermissions =>
      'Autorisations requises';

  @override
  String get privacyPolicySectionSecurity => 'Sécurité';

  @override
  String get privacyPolicySectionUserRights => 'Droits des utilisateurs';

  @override
  String get privacyPolicySectionDataRetention => 'Conservation des données';

  @override
  String get privacyPolicySectionChildrenPrivacy =>
      'Confidentialité des enfants';

  @override
  String get privacyPolicySectionChangesToPolicy =>
      'Modifications de cette politique';

  @override
  String get privacyPolicySectionDataCollectionConsent =>
      'Consentement à la collecte de données';

  @override
  String get privacyPolicySectionPDPACompliance =>
      'Conformité PDPA (loi thaïlandaise sur la protection des données personnelles Pro)';

  @override
  String get privacyPolicySectionContactUs => 'Contactez-nous';

  @override
  String get privacyPolicyEffectiveDate =>
      'Date d\'entrée en vigueur : 18 février 2026\nDernière mise à jour : 18 février 2026';

  @override
  String get termsOfServiceTitle => 'Conditions d\'utilisation';

  @override
  String get termsSubtitle => 'MiRO — Mon enregistrement d\'admission Oracle';

  @override
  String get termsSectionAcceptanceOfTerms => 'Acceptation des conditions';

  @override
  String get termsSectionServiceDescription => 'Description des services';

  @override
  String get termsSectionDisclaimerOfWarranties => 'Exclusion de garanties';

  @override
  String get termsSectionEnergySystemTerms =>
      'Conditions du système énergétique';

  @override
  String get termsSectionUserDataAndResponsibilities =>
      'Données utilisateur et responsabilités';

  @override
  String get termsSectionBackupTransfer => 'Sauvegarde et transfert';

  @override
  String get termsSectionInAppPurchases => 'Achats intégrés';

  @override
  String get termsSectionProhibitedUses => 'ProUtilisations interdites';

  @override
  String get termsSectionIntellectualProperty => 'Propriété intellectuelle Pro';

  @override
  String get termsSectionLimitationOfLiability =>
      'Limitation de responsabilité';

  @override
  String get termsSectionServiceTermination => 'Résiliation du service';

  @override
  String get termsSectionChangesToTerms => 'Modifications des conditions';

  @override
  String get termsSectionGoverningLaw => 'Loi applicable';

  @override
  String get termsSectionContactUs => 'Contactez-nous';

  @override
  String get termsAcknowledgment =>
      'En utilisant MiRO, vous reconnaissez que vous avez lu, compris et accepté ces conditions d\'utilisation.';

  @override
  String get termsLastUpdated => 'Dernière mise à jour : 15 février 2026';

  @override
  String get profileAndSettings => 'Profichier et paramètres';

  @override
  String errorOccurred(String error) {
    return 'Erreur : $error';
  }

  @override
  String get healthGoalsSection => 'Objectifs de santé';

  @override
  String get dailyGoals => 'Objectifs quotidiens';

  @override
  String get chatAiModeSection => 'Mode IA de discussion';

  @override
  String get selectAiPowersChat => 'Sélectionnez quelle IA alimente votre chat';

  @override
  String get miroAi => 'Miro IA';

  @override
  String get miroAiSubtitle =>
      'Propulsé par Gemini • Multilingue • Haute précision';

  @override
  String get localAi => 'IA locale';

  @override
  String get localAiSubtitle =>
      'Sur l\'appareil • En anglais uniquement • Précision de base';

  @override
  String get free => 'Gratuit';

  @override
  String get cuisinePreferenceSection => 'Préférence culinaire';

  @override
  String get preferredCuisine => 'Cuisine préférée';

  @override
  String get selectYourCuisine => 'Sélectionnez votre cuisine';

  @override
  String get photoScanSection => 'Numérisation de photos';

  @override
  String get languageSection => 'Langue';

  @override
  String get languageTitle => 'Langue / ภาษา';

  @override
  String get selectLanguage => 'Sélectionnez la langue / เลือกภาษา';

  @override
  String get systemDefault => 'Système par défaut';

  @override
  String get systemDefaultSublabel => 'ตามระบบ';

  @override
  String get english => 'Anglais';

  @override
  String get englishSublabel => 'อังกฤษ';

  @override
  String get thai => 'ไทย (thaïlandais)';

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
  String get closeBilingual => 'Fermer / ปิด';

  @override
  String languageChangedTo(String language) {
    return 'Langue modifiée en $language';
  }

  @override
  String get accountSection => 'Compte';

  @override
  String get miroId => 'ID MiRO';

  @override
  String get miroIdCopied => 'MiRO ID copié !';

  @override
  String get inviteFriends => 'Inviter des amis';

  @override
  String get inviteFriendsSubtitle =>
      'Partagez votre code de parrainage et gagnez des récompenses !';

  @override
  String get unlimitedAiDoubleRewards => 'IA illimitée + récompenses doubles';

  @override
  String get plan => 'Plan';

  @override
  String get monthly => 'Mensuel';

  @override
  String get started => 'Commencé';

  @override
  String get renews => 'Renouvelle';

  @override
  String get expires => 'Expire';

  @override
  String get autoRenew => 'Renouvellement automatique';

  @override
  String get on => 'Sur';

  @override
  String get off => 'Désactivé';

  @override
  String get tapToManageSubscription => 'Appuyez pour gérer l\'abonnement';

  @override
  String get dataSection => 'Données';

  @override
  String get backupData => 'Sauvegarde des données';

  @override
  String get backupDataSubtitle =>
      'Énergie + Historique alimentaire → enregistrer en tant que fichier';

  @override
  String get restoreFromBackup => 'Restaurer à partir d\'une sauvegarde';

  @override
  String get restoreFromBackupSubtitle =>
      'Importer des données à partir d\'un fichier de sauvegarde';

  @override
  String get clearAllDataTitle => 'Effacer toutes les données ?';

  @override
  String get clearAllDataContent =>
      'Toutes les données seront supprimées :\n• Entrées alimentaires\n• Mes repas\n• Ingrédients\n• Objectifs\n• Informations personnelles\n\nCela ne peut pas être annulé !';

  @override
  String get allDataClearedSuccess =>
      'Toutes les données ont été effacées avec succès';

  @override
  String get aboutSection => 'À propos';

  @override
  String get version => 'Version';

  @override
  String get healthDisclaimer =>
      'Avis de non-responsabilité concernant la santé';

  @override
  String get importantLegalInformation => 'Informations juridiques importantes';

  @override
  String get showTutorialAgain => 'Afficher à nouveau le didacticiel';

  @override
  String get viewFeatureTour => 'Voir la présentation des fonctionnalités';

  @override
  String get showTutorialDialogTitle => 'Afficher le didacticiel';

  @override
  String get showTutorialDialogContent =>
      'Cela affichera la présentation des fonctionnalités qui met en évidence :\n\n• Système énergétique\n• Numérisation de photos par extraction pour actualiser\n• Discutez avec l\'IA Miro\n\nVous reviendrez à l\'écran d\'accueil.';

  @override
  String get showTutorialButton => 'Afficher le didacticiel';

  @override
  String get tutorialResetMessage =>
      'Réinitialisation du tutoriel ! Accédez à l’écran d’accueil pour le voir.';

  @override
  String get foodAnalysisTutorial => 'Tutoriel d\'analyse des aliments';

  @override
  String get foodAnalysisTutorialSubtitle =>
      'Apprenez à utiliser les fonctionnalités d\'analyse des aliments';

  @override
  String get backupCreated => 'Sauvegarde créée !';

  @override
  String get backupCreatedContent =>
      'Votre fichier de sauvegarde a été créé avec succès.';

  @override
  String get backupChooseDestination =>
      'Où souhaitez-vous enregistrer votre sauvegarde ?';

  @override
  String get backupSaveToDevice => 'Enregistrer sur l\'appareil';

  @override
  String get backupSaveToDeviceDesc =>
      'Enregistrer dans un dossier de votre choix sur cet appareil';

  @override
  String get backupShareToOther => 'Partager sur un autre appareil';

  @override
  String get backupShareToOtherDesc =>
      'Envoyez par ligne, e-mail, lecteur Google, etc.';

  @override
  String get backupSavedSuccess => 'Sauvegarde enregistrée !';

  @override
  String get backupSavedSuccessContent =>
      'Votre fichier de sauvegarde a été enregistré à l\'emplacement choisi.';

  @override
  String get important => 'Important:';

  @override
  String get backupImportantNotes =>
      '• Enregistrez ce fichier dans un endroit sûr (lecteur Google, etc.)\n• Les photos ne sont PAS incluses dans la sauvegarde\n• La clé de transfert expire dans 30 jours.\n• La clé ne peut être utilisée qu\'une seule fois';

  @override
  String get restoreBackup => 'Restaurer la sauvegarde ?';

  @override
  String get backupFrom => 'Sauvegarde depuis :';

  @override
  String get date => 'Date:';

  @override
  String get energy => 'Énergie:';

  @override
  String get foodEntries => 'Entrées alimentaires :';

  @override
  String get restoreImportant => 'Important';

  @override
  String restoreImportantNotes(String energy) {
    return '• L\'énergie actuelle sur cet appareil sera REMPLACÉE par l\'énergie de la sauvegarde ($energy).\n• Les entrées d\'aliments seront FUSIONNÉES (non remplacées)\n• Les photos ne sont PAS incluses dans la sauvegarde\n• La clé de transfert sera utilisée (ne peut pas être réutilisée).';
  }

  @override
  String get restore => 'Restaurer';

  @override
  String get restoreComplete => 'Restauration terminée !';

  @override
  String get restoreCompleteContent =>
      'Vos données ont été restaurées avec succès.';

  @override
  String get newEnergyBalance => 'Nouveau bilan énergétique :';

  @override
  String get foodEntriesImported => 'Entrées d\'aliments importés :';

  @override
  String get myMealsImported => 'Mes repas importés :';

  @override
  String get appWillRefresh =>
      'Votre application sera actualisée pour afficher les données restaurées.';

  @override
  String get backupFailed => 'Échec de la sauvegarde';

  @override
  String get invalidBackupFile => 'Fichier de sauvegarde invalide';

  @override
  String get restoreFailed => 'Échec de la restauration';

  @override
  String get analyticsDataCollection => 'Collecte de données analytiques';

  @override
  String get analyticsEnabled => 'Analyses activées';

  @override
  String get analyticsDisabled => 'Analyse désactivée';

  @override
  String get enabled => 'Activé';

  @override
  String get enabledSubtitle => 'Activé -';

  @override
  String get disabled => 'Désactivé';

  @override
  String get disabledSubtitle => 'Désactivé';

  @override
  String get imagesPerDay => 'Images par jour';

  @override
  String scanUpToImagesPerDay(String limit) {
    return 'Numérisez jusqu\'à $limit images par jour';
  }

  @override
  String get reset => 'Réinitialiser';

  @override
  String get resetScanHistory => 'Réinitialiser l\'historique des analyses';

  @override
  String get resetScanHistorySubtitle =>
      'Supprimez toutes les entrées numérisées et réanalysez';

  @override
  String get imagesPerDayDialog => 'Images par jour';

  @override
  String get maxImagesPerDayDescription =>
      'Nombre maximum d\'images à numériser par jour\nScanne uniquement la date sélectionnée';

  @override
  String scanLimitSetTo(String limit) {
    return 'Limite de numérisation définie sur $limit images par jour';
  }

  @override
  String get resetScanHistoryDialog =>
      'Réinitialiser l\'historique des analyses ?';

  @override
  String get resetScanHistoryContent =>
      'Toutes les entrées de nourriture numérisées dans la galerie seront supprimées.\nDéroulez n’importe quelle date pour numériser à nouveau les images.';

  @override
  String resetComplete(String count) {
    return 'Réinitialisation terminée – entrées $count supprimées. Déroulez vers le bas pour re-scanner.';
  }

  @override
  String questBarStreak(int days) {
    return 'Séquence $days jour';
  }

  @override
  String questBarDaysToNextTier(int days, String tier) {
    return '$days jours → $tier';
  }

  @override
  String get questBarMaxTier => 'Niveau maximum ! 💎';

  @override
  String get questBarOfferDismissed => 'Offre masquée';

  @override
  String get questBarViewOffer => 'Voir l\'offre';

  @override
  String get questBarNoOffersNow => '• Aucune offre pour le moment';

  @override
  String get questBarWeeklyChallenges => '🎯 Défis hebdomadaires';

  @override
  String get questBarMilestones => '🏆 Jalons';

  @override
  String get questBarInviteFriends => '👥 Invitez des amis et obtenez 20E';

  @override
  String questBarTimeRemaining(String time) {
    return '⏰ Temps restant $time';
  }

  @override
  String questBarClaimDailyEnergy(int energy) {
    return '+${energy}E';
  }

  @override
  String questBarShareReferralError(String error) {
    return 'Partage d\'erreur : $error';
  }

  @override
  String tierCelebrationTitle(String tier) {
    return '$tier Célébration 🎉';
  }

  @override
  String tierCelebrationDay(int day) {
    return 'Jour $day';
  }

  @override
  String get tierCelebrationExpired => 'Expiré';

  @override
  String get tierCelebrationComplete => 'Complet!';

  @override
  String questBarWatchAd(int energy) {
    return 'Regarder l\'annonce +$energy⚡';
  }

  @override
  String questBarAdRemaining(int remaining, int total) {
    return '$remaining/$total restant aujourd\'hui';
  }

  @override
  String questBarAdSuccess(int energy) {
    return 'Annonce regardée ! +$energy Énergie entrante...';
  }

  @override
  String get questBarAdNotReady =>
      'L\'annonce n\'est pas prête, veuillez réessayer';

  @override
  String get questBarDailyChallenge => 'Défi quotidien';

  @override
  String get questBarUseAi => 'Utiliser l\'énergie';

  @override
  String get questBarResetsMonday => 'Réinitialise tous les lundis';

  @override
  String get questBarClaimed => 'Réclamé !';

  @override
  String get questBarHideOffer => 'Cacher';

  @override
  String get questBarViewDetails => 'Voir';

  @override
  String questBarShareText(String link) {
    return 'Essayez MiRO ! Analyse alimentaire basée sur l\'IA 🍔\nUtilisez ce lien et nous obtiendrons tous les deux +20 d\'énergie gratuite !\n\n$link';
  }

  @override
  String get questBarShareSubject => 'Essayez MiRO';

  @override
  String get claimButtonTitle => 'Réclamez de l\'énergie quotidienne';

  @override
  String claimButtonReceived(String energy) {
    return 'Reçu +${energy}E !';
  }

  @override
  String get claimButtonAlreadyClaimed => 'Déjà réclamé aujourd\'hui';

  @override
  String claimButtonError(String error) {
    return 'Erreur : $error';
  }

  @override
  String get seasonalQuestLimitedTime => 'DURÉE LIMITÉE';

  @override
  String seasonalQuestDaysLeft(int days) {
    return '$days jours restants';
  }

  @override
  String seasonalQuestRewardDaily(int reward) {
    return '+${reward}E / jour';
  }

  @override
  String seasonalQuestRewardOnce(int reward) {
    return '+${reward}E une fois';
  }

  @override
  String get seasonalQuestClaimed => 'Réclamé !';

  @override
  String get seasonalQuestClaimedToday => 'Réclamé aujourd\'hui';

  @override
  String get errorFailed => 'Échoué';

  @override
  String get errorFailedToClaim => 'Échec de la réclamation';

  @override
  String errorGeneric(String error) {
    return 'Erreur : $error';
  }

  @override
  String get milestoneNoMilestonesToClaim =>
      'Aucun jalon à revendiquer pour l\'instant';

  @override
  String milestoneClaimedEnergy(int energy) {
    return '🎁 Réclamé +$energy Énergie !';
  }

  @override
  String get milestoneTitle => 'Jalons';

  @override
  String milestoneUseEnergyComplete(int threshold) {
    return 'Utiliser l\'énergie $threshold';
  }

  @override
  String milestoneNext(int threshold) {
    return 'Suivant : ${threshold}E';
  }

  @override
  String get milestoneAllComplete => 'Toutes les étapes franchies !';

  @override
  String get noEnergyTitle => 'À court d\'énergie';

  @override
  String get noEnergyContent =>
      'Vous avez besoin de 1 énergie pour analyser les aliments avec l\'IA';

  @override
  String get noEnergyTip =>
      'Vous pouvez toujours enregistrer les aliments manuellement (sans IA) gratuitement';

  @override
  String get noEnergyLater => 'Plus tard';

  @override
  String noEnergyWatchAd(int remaining) {
    return 'Regarder l\'annonce ($remaining/3)';
  }

  @override
  String get noEnergyBuyEnergy => 'Acheter de l\'énergie';

  @override
  String get tierBronze => 'Bronze';

  @override
  String get tierSilver => 'Argent';

  @override
  String get tierGold => 'Or';

  @override
  String get tierDiamond => 'Diamant';

  @override
  String get tierStarter => 'Démarreur';

  @override
  String get tierUpCongratulations => '🎉 Félicitations !';

  @override
  String tierUpYouReached(String tier) {
    return 'Vous avez atteint $tier !';
  }

  @override
  String get tierUpMotivation =>
      'Suivez les calories comme un pro\nVotre corps de rêve se rapproche !';

  @override
  String tierUpReward(int reward) {
    return '+${reward}E Récompense !';
  }

  @override
  String get referralAllLevelsClaimed => 'Tous les niveaux revendiqués !';

  @override
  String referralLevel(int level, String subtitle) {
    return 'Niveau $level : $subtitle';
  }

  @override
  String referralProgress(int current, int target, int level, int total) {
    return '[$current/$target] (Niveau $level/$total)';
  }

  @override
  String referralClaimedLevel(int level, int reward) {
    return '🎁 Niveau revendiqué $level : +$reward Énergie !';
  }

  @override
  String get challengeUseAi10 => 'Utiliser l\'énergie 10';

  @override
  String get specifyIngredients => 'Préciser les ingrédients connus';

  @override
  String get specifyIngredientsOptional =>
      'Préciser les ingrédients connus (facultatif)';

  @override
  String get specifyIngredientsHint =>
      'Entrez les ingrédients que vous connaissez et l\'IA découvrira pour vous les assaisonnements, les huiles et les sauces cachés.';

  @override
  String get sendToAi => 'Envoyer à l\'IA';

  @override
  String get reanalyzeWithIngredients =>
      'Ajouter des ingrédients et réanalyser';

  @override
  String get reanalyzeButton => 'Réanalyser (1 énergie)';

  @override
  String get ingredientsSaved => 'Ingrédients sauvegardés';

  @override
  String get pleaseAddAtLeastOneIngredient =>
      'Veuillez ajouter au moins 1 ingrédient';

  @override
  String get hiddenIngredientsDiscovered =>
      'Ingrédients cachés découverts par l\'IA';

  @override
  String get retroScanTitle => 'Scanner les photos récentes ?';

  @override
  String get retroScanDescription =>
      'Nous pouvons numériser vos photos des 7 derniers jours pour trouver automatiquement des photos de plats et les ajouter à votre agenda.';

  @override
  String get retroScanNote =>
      'Seules les photos de nourriture sont détectées – les autres photos sont ignorées. Aucune photo ne quitte votre appareil.';

  @override
  String get retroScanStart => 'Scanner mes photos';

  @override
  String get retroScanSkip => 'Passer pour l\'instant';

  @override
  String get retroScanInProgress => 'Balayage...';

  @override
  String get retroScanTagline =>
      'MiRO transforme votre\nphotos alimentaires en données de santé.';

  @override
  String get retroScanFetchingPhotos => 'Récupération de photos récentes...';

  @override
  String get retroScanAnalyzing => 'Détection de photos de nourriture...';

  @override
  String retroScanPhotosFound(int count) {
    return '$count photos trouvées au cours des 7 derniers jours';
  }

  @override
  String get retroScanCompleteTitle => 'Analyse terminée !';

  @override
  String retroScanCompleteDesc(int count) {
    return 'J\'ai trouvé $count photos de nourriture ! Ils ont été ajoutés à votre chronologie, prêts pour l\'analyse de l\'IA.';
  }

  @override
  String get retroScanNoResultsTitle => 'Aucune photo de nourriture trouvée';

  @override
  String get retroScanNoResultsDesc =>
      'Aucune photo de nourriture détectée au cours des 7 derniers jours. Essayez de prendre une photo de votre prochain repas !';

  @override
  String get retroScanAnalyzeHint =>
      'Appuyez sur « Tout analyser » sur votre chronologie pour obtenir une analyse nutritionnelle par l\'IA pour ces entrées.';

  @override
  String get retroScanDone => 'J\'ai compris!';

  @override
  String get welcomeEndTitle => 'Bienvenue sur MiRO !';

  @override
  String get welcomeEndMessage => 'MiRO est à votre service.';

  @override
  String get welcomeEndJourney => 'Bon voyage ensemble !!';

  @override
  String get welcomeEndStart => 'Commençons !';

  @override
  String greetingCalorieSummary(
      int remaining, int protein, int carbs, int fat) {
    return 'Salut! Comment puis-je vous aider aujourd\'hui ? Il vous reste encore $remaining kcal. Jusqu\'à présent : Protein ${protein}g, glucides ${carbs}g, lipides ${fat}g. Dites-moi ce que vous avez mangé – listez tout par repas et je les enregistrerai tous pour vous. Plus de détails plus précis !!';
  }

  @override
  String greetingCuisineTip(String cuisine) {
    return 'Votre cuisine préférée est définie sur $cuisine. Vous pouvez le modifier dans les paramètres à tout moment !';
  }

  @override
  String greetingEnergyTip(int balance) {
    return 'Vous disposez de $balance Énergie. N\'oubliez pas de réclamer votre récompense de séquence quotidienne sur le badge Énergie !';
  }

  @override
  String get greetingRenamePhotoTip =>
      'Astuce : Vous pouvez renommer les photos de plats pour aider MiRO à analyser plus précisément !';

  @override
  String get greetingAddIngredientsTip =>
      'Astuce : Vous pouvez ajouter des ingrédients dont vous êtes sûr avant de les envoyer à MiRO pour analyse. Je vais comprendre tous les petits détails ennuyeux pour vous !';

  @override
  String greetingBackupReminder(int days) {
    return 'Hé patron ! Vous n\'avez pas sauvegardé vos données depuis $days jours. Je recommande de sauvegarder dans Paramètres : vos données sont stockées localement et je ne peux pas les récupérer si quelque chose arrive !';
  }

  @override
  String get greetingFallback =>
      'Salut! Comment puis-je vous aider aujourd\'hui ? Dis-moi ce que tu as mangé !';

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
}
