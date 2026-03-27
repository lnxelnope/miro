// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class L10nPt extends L10n {
  L10nPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'ArCal';

  @override
  String get save => 'Salvar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String get edit => 'Editar';

  @override
  String get search => 'Procurar';

  @override
  String get loading => 'Carregando...';

  @override
  String get error => 'Ocorreu um erro';

  @override
  String get confirm => 'Confirmar';

  @override
  String get close => 'Fechar';

  @override
  String get done => 'Feito';

  @override
  String get next => 'Próximo';

  @override
  String get skip => 'Pular';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get ok => 'OK';

  @override
  String get foodName => 'Nome da comida';

  @override
  String get calories => 'Calorias';

  @override
  String get protein => 'Proteína';

  @override
  String get carbs => 'Carboidratos';

  @override
  String get fat => 'Gordo';

  @override
  String get servingSize => 'Tamanho da porção';

  @override
  String get servingUnit => 'Unidade';

  @override
  String get kcal => 'kcal';

  @override
  String get mealBreakfast => 'Café da manhã';

  @override
  String get mealLunch => 'Almoço';

  @override
  String get mealDinner => 'Jantar';

  @override
  String get mealSnack => 'Lanche';

  @override
  String get todaySummary => 'Resumo de hoje';

  @override
  String get nutritionSummary => 'Nutrition Summary';

  @override
  String dateSummary(String date) {
    return 'Resumo para $date';
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
  String get savedSuccess => 'Salvo com sucesso';

  @override
  String get deletedSuccess => 'Excluído com sucesso';

  @override
  String get pleaseEnterFoodName => 'Por favor insira o nome do alimento';

  @override
  String get noDataYet => 'Ainda não há dados';

  @override
  String get addFood => 'Adicione comida';

  @override
  String get editFood => 'Editar comida';

  @override
  String get deleteFood => 'Excluir comida';

  @override
  String get deleteConfirm => 'Confirmar exclusão?';

  @override
  String get foodLoggedSuccess => 'Alimentos registrados!';

  @override
  String get noApiKey => 'Configure Gemini API Key';

  @override
  String get noApiKeyDescription =>
      'Vá para Profile → API Configurações para configurar';

  @override
  String get apiKeyTitle => 'Configurar Gemini API Key';

  @override
  String get apiKeyRequired => 'API Key obrigatório';

  @override
  String get apiKeyFreeNote => 'Gemini API é de uso gratuito';

  @override
  String get apiKeySetup => 'Configurar API Key';

  @override
  String get testConnection => 'Conexão de teste';

  @override
  String get connectionSuccess => 'Conectado com sucesso! Pronto para usar';

  @override
  String get connectionFailed => 'Falha na conexão';

  @override
  String get pasteKey => 'Colar';

  @override
  String get deleteKey => 'Excluir API Key';

  @override
  String get openAiStudio => 'Abra Google AI Studio';

  @override
  String get chatHint => 'Diga ArCal, por exemplo. \"Arroz frito\"...';

  @override
  String get chatFoodSaved => 'Alimentos registrados!';

  @override
  String chatFoodSavedDetail(
      String name, String serving, String unit, String cal) {
    return '$name $serving $unit\n$cal kcal';
  }

  @override
  String get featureNotAvailable =>
      'Desculpe, este recurso ainda não está disponível';

  @override
  String get goalCalories => 'Calorias/dia';

  @override
  String get goalProtein => 'Proteína/dia';

  @override
  String get goalCarbs => 'Carboidratos/dia';

  @override
  String get goalFat => 'Gordura/dia';

  @override
  String get goalWater => 'Água/dia';

  @override
  String get healthGoals => 'Metas de saúde';

  @override
  String get profile => 'Proarquivo';

  @override
  String get settings => 'Configurações';

  @override
  String get privacyPolicy => 'política de Privacidade';

  @override
  String get termsOfService => 'Termos de Serviço';

  @override
  String get clearAllData => 'Limpar todos os dados';

  @override
  String get clearAllDataConfirm =>
      'Todos os dados serão excluídos. Isso não pode ser desfeito!';

  @override
  String get about => 'Sobre';

  @override
  String get language => 'Linguagem';

  @override
  String get upgradePro => 'Atualizar para Pro';

  @override
  String get proUnlocked => 'ArCal Pro';

  @override
  String get proDescription => 'Análise ilimitada de alimentos com IA';

  @override
  String aiRemaining(int remaining, int total) {
    return 'Análise de IA: $remaining/$total restantes hoje';
  }

  @override
  String get aiLimitReached => 'Limite de IA atingido para hoje (3/3)';

  @override
  String get restorePurchase => 'Restaurar compra';

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
  String get myMeals => 'Minhas refeições:';

  @override
  String get createMeal => 'Criar refeição';

  @override
  String get ingredients => 'Ingredients';

  @override
  String get searchFood => 'Pesquisar comida';

  @override
  String get analyzing => 'Analisando...';

  @override
  String get analyzeWithAi => 'Analise com IA';

  @override
  String get analysisComplete => 'Análise concluída';

  @override
  String get timeline => 'Linha do tempo';

  @override
  String get diet => 'Dieta';

  @override
  String get quickAdd => 'Adição rápida';

  @override
  String get welcomeTitle => 'ArCal';

  @override
  String get welcomeSubtitle => 'Registro fácil de alimentos com IA';

  @override
  String get onboardingFeature1 => 'Tire uma foto';

  @override
  String get onboardingFeature1Desc => 'AI calcula calorias automaticamente';

  @override
  String get onboardingFeature2 => 'Digite para registrar';

  @override
  String get onboardingFeature2Desc =>
      'Diga \"comi arroz frito\" e está registrado';

  @override
  String get onboardingFeature3 => 'Resumo diário';

  @override
  String get onboardingFeature3Desc =>
      'Rastreie kcal, proteínas, carboidratos, gordura';

  @override
  String get basicInfo => 'Informações básicas';

  @override
  String get basicInfoDesc =>
      'Para calcular suas calorias diárias recomendadas';

  @override
  String get gender => 'Gênero';

  @override
  String get male => 'Macho';

  @override
  String get female => 'Fêmea';

  @override
  String get age => 'Idade';

  @override
  String get weight => 'Peso';

  @override
  String get height => 'Altura';

  @override
  String get activityLevel => 'Nível de atividade';

  @override
  String tdeeResult(int kcal) {
    return 'Seu TDEE: $kcal kcal/dia';
  }

  @override
  String get setupAiTitle => 'Configurar Gemini IA';

  @override
  String get setupAiDesc => 'Tire uma foto e a IA a analisa automaticamente';

  @override
  String get setupNow => 'Configurar agora';

  @override
  String get skipForNow => 'Pular por enquanto';

  @override
  String get errorTimeout => 'Tempo limite de conexão — tente novamente';

  @override
  String get errorInvalidKey =>
      'API Key inválido — verifique suas configurações';

  @override
  String get errorNoInternet => 'Sem conexão com a internet';

  @override
  String get errorGeneral => 'Ocorreu um erro. Tente novamente';

  @override
  String get errorQuotaExceeded =>
      'Cota API excedida. Aguarde e tente novamente';

  @override
  String get apiKeyScreenTitle => 'Configurar Gemini API Key';

  @override
  String get analyzeFoodWithAi => 'Analise alimentos com IA';

  @override
  String get analyzeFoodWithAiDesc =>
      'Tire uma foto → IA calcula calorias automaticamente\nGemini API é de uso gratuito!';

  @override
  String get openGoogleAiStudio => 'Abra Google AI Studio';

  @override
  String get step1Title => 'Abra Google AI Studio';

  @override
  String get step1Desc => 'Clique no botão abaixo para criar um API Key';

  @override
  String get step2Title => 'Faça login com a conta Google';

  @override
  String get step2Desc =>
      'Use sua conta Gmail ou Google (crie uma gratuitamente se não tiver uma)';

  @override
  String get step3Title => 'Clique em \"Criar API Key\"';

  @override
  String get step3Desc =>
      'Clique no botão azul \"Criar API Key\"\nSe for solicitado a selecionar um Project → Clique em \"Criar chave API no novo projeto\"';

  @override
  String get step4Title => 'Copie a chave e cole abaixo';

  @override
  String get step4Desc =>
      'Clique em Copiar ao lado da chave criada\nA chave será semelhante a: AIzaSyxxxx...';

  @override
  String get step5Title => 'Cole API Key aqui';

  @override
  String get pasteApiKeyHint => 'Cole o API Key copiado';

  @override
  String get saveApiKey => 'Salvar API Key';

  @override
  String get testingConnection => 'Testando...';

  @override
  String get deleteApiKey => 'Excluir API Key';

  @override
  String get deleteApiKeyConfirm => 'Excluir API Key?';

  @override
  String get deleteApiKeyConfirmDesc =>
      'Você não poderá usar a análise alimentar de IA até configurá-la novamente';

  @override
  String get apiKeySaved => 'API Key salvo com sucesso';

  @override
  String get apiKeyDeleted => 'API Key excluído com sucesso';

  @override
  String get pleasePasteApiKey => 'Por favor cole API Key primeiro';

  @override
  String get apiKeyInvalidFormat =>
      'API Key inválido — deve começar com \"AIza\"';

  @override
  String get connectionSuccessMessage =>
      '✅Conectado com sucesso! Pronto para usar';

  @override
  String get connectionFailedMessage => '❌ Falha na conexão';

  @override
  String get faqTitle => 'Perguntas frequentes';

  @override
  String get faqFreeQuestion => 'É realmente grátis?';

  @override
  String get faqFreeAnswer =>
      'Sim! Gemini 2.0 Flash é gratuito para 1.500 solicitações/dia\nPara registro de alimentos (5-15 vezes/dia) → Gratuito para sempre, sem necessidade de pagamento';

  @override
  String get faqSafeQuestion => 'É seguro?';

  @override
  String get faqSafeAnswer =>
      'API Key é armazenado no armazenamento seguro apenas no seu dispositivo\nO aplicativo não envia a chave para o nosso servidor\nSe a chave vazar → Exclua e crie uma nova (não é sua senha Google)';

  @override
  String get faqNoKeyQuestion => 'E se eu não criar uma chave?';

  @override
  String get faqNoKeyAnswer =>
      'Você ainda pode usar o aplicativo! Mas:\n❌ Não é possível tirar foto → Análise de IA\n✅ Pode registrar alimentos manualmente\n✅ A adição rápida funciona\n✅ Ver trabalhos de resumo de kcal/macro';

  @override
  String get faqCreditCardQuestion => 'Preciso de um cartão de crédito?';

  @override
  String get faqCreditCardAnswer =>
      'Não — Crie API Key gratuitamente sem cartão de crédito';

  @override
  String get navDashboard => 'Painel';

  @override
  String get navMyMeals => 'Minhas refeições';

  @override
  String get navCamera => 'Câmera';

  @override
  String get navGallery => 'Gallery';

  @override
  String get navAiChat => 'Bate-papo com IA';

  @override
  String get navProfile => 'Proarquivo';

  @override
  String get appBarTodayIntake => 'Ingestão de hoje';

  @override
  String get appBarMyMeals => 'Minhas refeições';

  @override
  String get appBarCamera => 'Câmera';

  @override
  String get appBarAiChat => 'Bate-papo com IA';

  @override
  String get appBarMiro => 'ArCal';

  @override
  String get permissionRequired => 'Permissão necessária';

  @override
  String get permissionRequiredDesc => 'ArCal precisa de acesso ao seguinte:';

  @override
  String get permissionPhotos => 'Fotos – para escanear alimentos';

  @override
  String get permissionCamera => 'Câmera – para fotografar comida';

  @override
  String get permissionSkip => 'Pular';

  @override
  String get permissionAllow => 'Permitir';

  @override
  String get permissionAllGranted => 'Todas as permissões concedidas';

  @override
  String permissionDenied(String denied) {
    return 'Permissão negada: $denied';
  }

  @override
  String get openSettings => 'Abra Configurações';

  @override
  String get exitAppTitle => 'Sair do aplicativo?';

  @override
  String get exitAppMessage => 'Tem certeza de que deseja sair?';

  @override
  String get exit => 'Saída';

  @override
  String get healthGoalsTitle => 'Metas de saúde';

  @override
  String get healthGoalsInfo =>
      'Defina sua meta diária de calorias, macros e orçamentos por refeição.\nBloqueie para calcular automaticamente: 2 macros ou 3 refeições.';

  @override
  String get dailyCalorieGoal => 'Meta diária de calorias';

  @override
  String get proteinLabel => 'Proteína';

  @override
  String get carbsLabel => 'Carboidratos';

  @override
  String get fatLabel => 'Gordo';

  @override
  String get autoBadge => 'auto';

  @override
  String kcalPerGram(int kcalPerGram, int kcal) {
    return '$kcalPerGram kcal/g • $kcal __SW0__';
  }

  @override
  String get mealCalorieBudget => 'Orçamento de calorias de refeição';

  @override
  String mealBudgetBalanced(int total, int goal) {
    return 'Total $total kcal = Meta $goal __SW0__';
  }

  @override
  String mealBudgetRemaining(int total, int goal, int remaining) {
    return 'Total $total / $goal kcal ($remaining restante)';
  }

  @override
  String get lockMealsHint =>
      'Bloqueie 3 refeições para calcular automaticamente a 4ª';

  @override
  String get breakfastLabel => 'Café da manhã';

  @override
  String get lunchLabel => 'Almoço';

  @override
  String get dinnerLabel => 'Jantar';

  @override
  String get snackLabel => 'Lanche';

  @override
  String percentOfDailyGoal(String percent) {
    return '$percent% da meta diária';
  }

  @override
  String get smartSuggestionRange => 'Faixa de sugestões inteligentes';

  @override
  String get smartSuggestionHow => 'Como funciona a Sugestão Inteligente?';

  @override
  String smartSuggestionDesc(int threshold, int min, int max) {
    return 'Sugerimos alimentos de Minhas Refeições, ingredientes e refeições de ontem que cabem no seu orçamento por refeição.\n\nEste limite controla a flexibilidade das sugestões. Por exemplo, se o seu orçamento para almoço for 700 kcal e o limite for $threshold __SW0__, sugeriremos alimentos entre $min–$max __SW0__.';
  }

  @override
  String get suggestionThreshold => 'Limite de sugestão';

  @override
  String suggestionThresholdDesc(int threshold) {
    return 'Permitir alimentos ± $threshold kcal do orçamento de refeições';
  }

  @override
  String get goalsSavedSuccess => 'Metas salvas com sucesso!';

  @override
  String get canOnlyLockTwoMacros =>
      'Só é possível bloquear 2 macros de uma vez';

  @override
  String get canOnlyLockThreeMeals =>
      'Só é possível bloquear 3 refeições; o 4º calcula automaticamente';

  @override
  String get tabMeals => 'Refeições';

  @override
  String get tabIngredients => 'Ingredientes';

  @override
  String get searchMealsOrIngredients =>
      'Pesquisar refeições ou ingredientes...';

  @override
  String get createNewMeal => 'Criar nova refeição';

  @override
  String get addIngredient => 'Adicionar ingrediente';

  @override
  String get noMealsYet => 'Ainda não há refeições';

  @override
  String get noMealsYetDesc =>
      'Analise alimentos com IA para salvar refeições automaticamente\nou crie um manualmente';

  @override
  String get noIngredientsYet => 'Ainda não há ingredientes';

  @override
  String get noIngredientsYetDesc =>
      'Quando você analisa alimentos com IA\ningredientes serão salvos automaticamente';

  @override
  String mealCreated(String name) {
    return 'Criado \"$name\"';
  }

  @override
  String mealLogged(String name) {
    return 'Registrado \"$name\"';
  }

  @override
  String get logThisMealButton => 'Log this meal';

  @override
  String logFromMealBaseLine(String baseDescription, String calories) {
    return 'Base: $baseDescription · $calories kcal';
  }

  @override
  String logFromMealOriginalServingHint(String amount) {
    return 'Original serving: $amount';
  }

  @override
  String ingredientAmount(String unit) {
    return 'Quantidade ($unit)';
  }

  @override
  String ingredientLogged(String name, String amount, String unit) {
    return 'Registrado \"$name\" $amount$unit';
  }

  @override
  String get mealNotFound => 'Refeição não encontrada';

  @override
  String mealUpdated(String name) {
    return '\"$name\" atualizado';
  }

  @override
  String get deleteMealTitle => 'Excluir refeição?';

  @override
  String deleteMealMessage(String name) {
    return '\"$name\"';
  }

  @override
  String get deleteMealNote => 'Os ingredientes não serão excluídos.';

  @override
  String get mealDeleted => 'Refeição excluída';

  @override
  String ingredientCreated(String name) {
    return 'Criado \"$name\"';
  }

  @override
  String get ingredientNotFound => 'Ingrediente não encontrado';

  @override
  String ingredientUpdated(String name) {
    return '\"$name\" atualizado';
  }

  @override
  String get deleteIngredientTitle => 'Excluir ingrediente?';

  @override
  String deleteIngredientMessage(String name) {
    return '\"$name\"';
  }

  @override
  String get ingredientDeleted => 'Ingrediente excluído';

  @override
  String get noIngredientsData => 'Sem dados de ingredientes';

  @override
  String ingredientDetail(String name, String amount, String unit) {
    return '$name ($amount $unit)';
  }

  @override
  String ingredientCalories(int calories) {
    return '$calories kcal';
  }

  @override
  String get useThisMeal => 'Use esta refeição';

  @override
  String errorLoading(String error) {
    return 'Erro ao carregar: $error';
  }

  @override
  String scanFoundNewImages(int count, String date) {
    return 'Encontradas $count novas imagens em $date';
  }

  @override
  String scanNoNewImages(String date) {
    return 'Nenhuma nova imagem encontrada em $date';
  }

  @override
  String aiAnalysisRemaining(int remaining, int total) {
    return 'Análise de IA: $remaining/$total restantes hoje';
  }

  @override
  String get upgradeToProUnlimited => 'Atualize para Pro para uso ilimitado';

  @override
  String get upgrade => 'Atualizar';

  @override
  String get confirmDelete => 'Confirmar exclusão';

  @override
  String confirmDeleteMessage(String name) {
    return 'Deseja excluir \"$name\"?';
  }

  @override
  String get entryDeletedSuccess => '✅ Entrada excluída com sucesso';

  @override
  String entryDeleteError(String error) {
    return '❌ Erro: $error';
  }

  @override
  String batchAnalyzeItems(int count) {
    return '$count itens (lote)';
  }

  @override
  String analyzeCancelled(int success) {
    return 'Cancelado — itens $success analisados ​​com sucesso';
  }

  @override
  String analyzeSuccessAll(int success) {
    return '✅ Itens $success analisados ​​com sucesso';
  }

  @override
  String analyzeSuccessPartial(int success, int total, int failed) {
    return '⚠️ Itens $success/$total analisados ​​($failed falhou)';
  }

  @override
  String analyzeProgress(String item, int current, int total) {
    return '$item ($current/$total)';
  }

  @override
  String get pullToScanMeal => 'Puxe para digitalizar sua refeição';

  @override
  String get analyzeAll => 'Analisar tudo';

  @override
  String get addFoodTitle => 'Adicionar comida';

  @override
  String get foodNameRequired => 'Nome do alimento *';

  @override
  String get foodNameHint =>
      'Digite para pesquisar, por exemplo arroz frito, salada de mamão';

  @override
  String get selectedFromMyMeal =>
      '✅ Selecionado em Minha Refeição - dados nutricionais preenchidos automaticamente';

  @override
  String get foundInDatabase =>
      '✅ Encontrado no banco de dados – dados nutricionais preenchidos automaticamente';

  @override
  String get saveAndAnalyze => 'Salvar e analisar';

  @override
  String get notFoundInDatabase =>
      'Não encontrado no banco de dados — será analisado em segundo plano';

  @override
  String get amountLabel => 'Quantia';

  @override
  String get unitLabel => 'Unidade';

  @override
  String get nutritionAutoCalculated =>
      'Nutrição (calculada automaticamente por quantidade)';

  @override
  String get nutritionEnterZero => 'Nutrição (insira 0 se desconhecido)';

  @override
  String get caloriesLabel => 'Calorias (kcal)';

  @override
  String get proteinLabelShort => 'Proteína (g)';

  @override
  String get carbsLabelShort => 'Carboidratos (g)';

  @override
  String get fatLabelShort => 'Gordura (g)';

  @override
  String get mealTypeLabel => 'Tipo de refeição';

  @override
  String get pleaseEnterFoodNameFirst =>
      'Por favor, insira o nome do alimento primeiro';

  @override
  String get savedAnalyzingBackground =>
      '✅ Salvo — analisando em segundo plano';

  @override
  String get foodAdded => '✅ Alimentos adicionados';

  @override
  String get suggestionSourceMyMeal => 'Minha refeição';

  @override
  String get suggestionSourceIngredient => 'Ingrediente';

  @override
  String get suggestionSourceDatabase => 'Banco de dados';

  @override
  String get editFoodTitle => 'Editar comida';

  @override
  String get foodNameLabel => 'Nome da comida';

  @override
  String get changeAmountAutoUpdate =>
      'Alterar quantidade → calorias são atualizadas automaticamente';

  @override
  String baseNutrition(int calories, String unit) {
    return 'Base: $calories kcal / 1 $unit';
  }

  @override
  String get calculatedFromIngredients =>
      'Calculado a partir dos ingredientes abaixo';

  @override
  String get ingredientsEditable => 'Ingredientes (editáveis)';

  @override
  String get addIngredientButton => 'Adicionar';

  @override
  String get noIngredientsAddHint =>
      'Sem ingredientes – toque em \"Adicionar\" para adicionar novos';

  @override
  String get editIngredientsHint =>
      'Editar nome/quantidade → Toque no ícone de pesquisa para pesquisar no banco de dados ou IA';

  @override
  String get ingredientNameHint => 'por exemplo Ovo de galinha';

  @override
  String get searchDbOrAi => 'Pesquisar banco de dados/IA';

  @override
  String get amountHint => 'Quantia';

  @override
  String get fromDatabase => 'Do banco de dados';

  @override
  String subIngredients(int count) {
    return 'Subingredientes ($count)';
  }

  @override
  String get addSubIngredient => 'Adicionar';

  @override
  String get subIngredientNameHint => 'Nome do subingrediente';

  @override
  String get amountShort => 'Valor';

  @override
  String get pleaseEnterSubIngredientName =>
      'Por favor, insira o nome do subingrediente primeiro';

  @override
  String foundInDatabaseSub(String name) {
    return 'Encontrado \"$name\" no banco de dados!';
  }

  @override
  String aiAnalyzedSub(String name) {
    return 'IA analisou \"$name\" (-1 Energia)';
  }

  @override
  String get couldNotAnalyzeSub => 'Não foi possível analisar o subingrediente';

  @override
  String get pleaseEnterIngredientName =>
      'Por favor insira o nome do ingrediente';

  @override
  String get reAnalyzeTitle => 'Reanalisar?';

  @override
  String reAnalyzeMessage(String name) {
    return '\"$name\" já possui dados nutricionais.\n\nAnalisar novamente usará 1 Energia.\n\nContinuar?';
  }

  @override
  String get reAnalyzeButton => 'Reanalisar (1 Energia)';

  @override
  String get amountNotSpecified => 'Valor não especificado';

  @override
  String amountNotSpecifiedMessage(String name) {
    return 'Especifique o valor para \"$name\" primeiro\nOu usar o padrão 100g?';
  }

  @override
  String get useDefault100g => 'Usar 100g';

  @override
  String aiAnalyzedResult(String name, int calories) {
    return 'IA: \"$name\" → $calories kcal';
  }

  @override
  String get unableToAnalyze => 'Não é possível analisar';

  @override
  String get today => 'Hoje';

  @override
  String get savedSuccessfully => '✅ Salvo com sucesso';

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
  String get confirmFoodPhoto => 'Confirme a foto da comida';

  @override
  String get photoSavedAutomatically => 'Foto salva automaticamente';

  @override
  String get foodNameHintExample => 'por exemplo, salada de frango grelhado';

  @override
  String get quantityLabel => 'Quantidade';

  @override
  String get quantityHint => '1';

  @override
  String get optionalFoodInfo =>
      'Inserir o nome e a quantidade do alimento é opcional, mas fornecê-los melhorará a precisão da análise de IA.';

  @override
  String get saveOnly => 'Salvar apenas';

  @override
  String get pleaseEnterValidQuantity => 'Insira uma quantidade válida';

  @override
  String analyzedResult(String name, int calories) {
    return '✅ Analisado: $name — $calories kcal';
  }

  @override
  String get couldNotAnalyzeSaved =>
      '⚠️ Não foi possível analisar — ​​salvo, use \"Analisar tudo\" mais tarde';

  @override
  String get savedAnalyzeLater =>
      '✅ Salvo — analise mais tarde com \"Analisar tudo\"';

  @override
  String get editIngredientTitle => 'Editar ingrediente';

  @override
  String get ingredientNameRequired => 'Nome do Ingrediente *';

  @override
  String get baseAmountLabel => 'Valor base';

  @override
  String get baseAmountHint => '100';

  @override
  String nutritionPerBase(String amount, String unit) {
    return 'Nutrição por $amount $unit';
  }

  @override
  String nutritionCalculatedPerBase(String amount, String unit) {
    return 'Nutrição calculada por $amount $unit — o sistema calculará automaticamente com base na quantidade real consumida';
  }

  @override
  String get createIngredient => 'Criar ingrediente';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get pleaseEnterIngredientNameFirst =>
      'Por favor, insira o nome do ingrediente primeiro';

  @override
  String aiAnalyzedIngredient(
      String name, String amount, String unit, int calories) {
    return 'IA: \"$name\" $amount $unit → $calories kcal';
  }

  @override
  String get unableToFindIngredient =>
      'Não foi possível encontrar este ingrediente';

  @override
  String searchFailed(String error) {
    return 'Falha na pesquisa: $error';
  }

  @override
  String deleteEntriesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Entries',
      one: 'Entry',
    );
    return 'Excluir $count $_temp0?';
  }

  @override
  String deleteEntriesMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return 'Excluir $count alimento selecionado $_temp0?';
  }

  @override
  String get deleteAll => 'Excluir tudo';

  @override
  String deletedEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return 'Excluído $count $_temp0';
  }

  @override
  String deletedSingleEntry(String name) {
    return 'Deleted $name';
  }

  @override
  String get intakeGoalLabel => 'Intake Goal';

  @override
  String get activeBurnLabel => 'Active Burn';

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
    return 'Movido $count $_temp0 para $date';
  }

  @override
  String get allSelectedAlreadyAnalyzed =>
      'Todas as entradas selecionadas já foram analisadas';

  @override
  String analyzeCancelledSelected(int success) {
    return 'Cancelado — $success analisado';
  }

  @override
  String analyzedEntriesAll(int success) {
    String _temp0 = intl.Intl.pluralLogic(
      success,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return 'Analisado $success $_temp0';
  }

  @override
  String analyzedEntriesPartial(int success, int total, int failed) {
    return 'Analisado $success/$total ($failed falhou)';
  }

  @override
  String analyzeProgressSelected(int current, int total, String item) {
    return '$current/$total $item';
  }

  @override
  String get noEntriesYet => 'Nenhuma entrada ainda';

  @override
  String get selectAll => 'Selecionar tudo';

  @override
  String get deselectAll => 'Desmarcar tudo';

  @override
  String get moveToDate => 'Mover para a data';

  @override
  String get analyzeSelected => 'Analyze';

  @override
  String get deleteTooltip => 'Excluir';

  @override
  String get move => 'Mover';

  @override
  String get deleteTooltipAction => 'Excluir';

  @override
  String switchToModeTitle(String mode) {
    return 'Mudar para o modo $mode?';
  }

  @override
  String switchToModeMessage(String current, String newMode) {
    return 'Este item foi analisado como $current.\n\nReanalisar como $newMode usará 1 energia.\n\nContinuar?';
  }

  @override
  String analyzingAsMode(String mode) {
    return 'Analisando como $mode...';
  }

  @override
  String reAnalyzedAsMode(String mode) {
    return '✅ Reanalisado como $mode';
  }

  @override
  String get analysisFailed => '❌ Falha na análise';

  @override
  String get aiAnalysisComplete => '✅ IA analisada e salva';

  @override
  String get changeMealType => 'Alterar tipo de refeição';

  @override
  String get moveToAnotherDate => 'Mudar para outra data';

  @override
  String currentDate(String date) {
    return 'Atual: $date';
  }

  @override
  String get cancelDateChange => 'Cancelar alteração de data';

  @override
  String get undo => 'Desfazer';

  @override
  String get chatHistory => 'Histórico de bate-papo';

  @override
  String get newChat => 'Novo bate-papo';

  @override
  String get quickActions => 'Ações rápidas';

  @override
  String get clear => 'Claro';

  @override
  String get helloImMiro => 'Olá! Eu sou ArCal';

  @override
  String get tellMeWhatYouAteToday => 'Me conta o que você comeu hoje!';

  @override
  String get tellMeWhatYouAte => 'Me conta o que você comeu...';

  @override
  String get clearHistoryTitle => 'Limpar histórico?';

  @override
  String get clearHistoryMessage =>
      'Todas as mensagens nesta sessão serão excluídas.';

  @override
  String get chatHistoryTitle => 'Histórico de bate-papo';

  @override
  String get newLabel => 'Novo';

  @override
  String get noChatHistoryYet => 'Ainda não há histórico de bate-papo';

  @override
  String get active => 'Ativo';

  @override
  String get deleteChatTitle => 'Excluir bate-papo?';

  @override
  String deleteChatMessage(String title) {
    return 'Excluir \"$title\"?';
  }

  @override
  String weeklySummaryTitle(String start, String end) {
    return '📊 Resumo semanal ($start - $end)';
  }

  @override
  String daySummary(String day, String calories, String emoji, String diff) {
    return '📅 $day: $calories kcal $emoji ($diff)';
  }

  @override
  String overTarget(String amount) {
    return '$amount acima do alvo';
  }

  @override
  String underTarget(String amount) {
    return '$amount abaixo do alvo';
  }

  @override
  String get noFoodLoggedThisWeek =>
      'Nenhum alimento registrado esta semana ainda.';

  @override
  String averageKcalPerDay(String average) {
    return '🔥 Média: $average kcal/dia';
  }

  @override
  String targetKcalPerDay(String target) {
    return '🎯 Meta: $target kcal/dia';
  }

  @override
  String resultOverTarget(String amount) {
    return '📈 Resultado: $amount kcal acima da meta';
  }

  @override
  String resultUnderTarget(String amount) {
    return '📈 Resultado: $amount kcal abaixo da meta - Ótimo trabalho! 💪';
  }

  @override
  String failedToLoadWeeklySummary(String error) {
    return '❌ Falha ao carregar o resumo semanal: $error';
  }

  @override
  String monthlySummaryTitle(String month, int year) {
    return '📊 Resumo Mensal ($month $year)';
  }

  @override
  String totalDays(int days) {
    return '📅 Total de dias: $days';
  }

  @override
  String totalConsumed(String calories) {
    return '🔥 Total Consumido: $calories kcal';
  }

  @override
  String targetTotal(String target) {
    return '🎯 Meta Total: $target kcal';
  }

  @override
  String averageKcalPerDayShort(String average) {
    return '📈 Média: $average kcal/dia';
  }

  @override
  String overTargetThisMonth(String amount) {
    return '⚠️ $amount kcal acima da meta este mês';
  }

  @override
  String underTargetThisMonth(String amount) {
    return '✅ $amount kcal abaixo da meta - Excelente! 💪';
  }

  @override
  String failedToLoadMonthlySummary(String error) {
    return '❌ Falha ao carregar o resumo mensal: $error';
  }

  @override
  String get localAiHelpTitle => '🤖 Ajuda local de IA';

  @override
  String get localAiHelpFormat => 'Formato: [comida] [quantidade] [unidade]';

  @override
  String get localAiHelpExamples =>
      'Exemplos:\n• frango 100g e arroz 200g\n• pizza 2 fatias\n• maçã 1 peça, banana 1 peça';

  @override
  String get localAiHelpNote =>
      'Nota: somente em inglês, análise básica\nMude para ArCal AI para obter melhores resultados!';

  @override
  String hiNoFoodLogged(String target) {
    return '🤖 Olá! Nenhum alimento registrado ainda hoje.\n   Alvo: $target kcal — Pronto para começar a registrar? 🍽️';
  }

  @override
  String hiKcalLeft(String remaining) {
    return '🤖 Olá! Você tem $remaining kcal restante por hoje.\n   Pronto para registrar suas refeições? 😊';
  }

  @override
  String hiOverTarget(String calories, String over) {
    return '🤖 Olá! Você consumiu $calories kcal hoje.\n   $over __SW0__ acima da meta — Vamos continuar acompanhando! 💪';
  }

  @override
  String get hiReadyToLog => '🤖 Olá! Pronto para registrar suas refeições? 😊';

  @override
  String get notEnoughEnergy => 'Energia insuficiente';

  @override
  String get thinkingMealIdeas =>
      '🤖 Pensando em ótimas ideias de refeições para você...';

  @override
  String get recentMeals => 'Refeições recentes:';

  @override
  String get noRecentFood => 'Nenhum alimento recente registrado.';

  @override
  String remainingCaloriesToday(String remaining) {
    return '. Calorias restantes hoje: $remaining kcal.';
  }

  @override
  String failedToGetMenuSuggestions(String error) {
    return '❌ Falha ao obter sugestões de menu: $error';
  }

  @override
  String get mealSuggestionsTitle =>
      '🤖 Com base no seu registo alimentar, aqui ficam 3 sugestões de refeições:';

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
  String get pickOneAndLog => 'Escolha um e eu registrarei para você! 😊';

  @override
  String energyCost(int cost) {
    return '⚡ -$cost Energia';
  }

  @override
  String get giveMeTipsForHealthyEating =>
      'Dê-me dicas para uma alimentação saudável';

  @override
  String get howManyCaloriesToday => 'Quantas calorias hoje?';

  @override
  String get menuLabel => 'Menu';

  @override
  String get weeklyLabel => 'Semanalmente';

  @override
  String get monthlyLabel => 'Mensal';

  @override
  String get tipsLabel => 'Pontas';

  @override
  String get summaryLabel => 'Resumo';

  @override
  String get helpLabel => 'Ajuda';

  @override
  String get onboardingWelcomeSubtitle =>
      'Monitore calorias sem esforço\ncom análise alimentada por IA';

  @override
  String get onboardingSnap => 'Foto';

  @override
  String get onboardingSnapDesc => 'A IA analisa instantaneamente';

  @override
  String get onboardingType => 'Tipo';

  @override
  String get onboardingTypeDesc => 'Faça login em segundos';

  @override
  String get onboardingEdit => 'Editar';

  @override
  String get onboardingEditDesc => 'Precisão de ajuste fino';

  @override
  String get onboardingNext => 'Próximo →';

  @override
  String get onboardingDisclaimer =>
      'Dados estimados por IA. Não é conselho médico.';

  @override
  String get onboardingQuickSetup => 'Configuração rápida';

  @override
  String get onboardingHelpAiUnderstand =>
      'Ajude a IA a entender melhor sua comida';

  @override
  String get onboardingYourTypicalCuisine => 'Sua culinária típica:';

  @override
  String get onboardingDailyCalorieGoal =>
      'Meta diária de calorias (opcional):';

  @override
  String get onboardingKcalPerDay => 'kcal/dia';

  @override
  String get onboardingCalorieGoalHint => '2000';

  @override
  String get onboardingCanChangeAnytime =>
      'Você pode alterar isso a qualquer momento nas configurações do Profile';

  @override
  String get onboardingYoureAllSet => 'Está tudo pronto!';

  @override
  String get onboardingStartTracking =>
      'Comece a monitorar suas refeições hoje.\nTire uma foto ou digite o que você comeu.';

  @override
  String get onboardingWelcomeGift => 'Presente de boas-vindas';

  @override
  String get onboardingFreeEnergy => '10 Energia GRATUITA';

  @override
  String get onboardingFreeEnergyDesc => '= 10 análises de IA para começar';

  @override
  String get onboardingEnergyCost =>
      'Cada análise custa 1 Energia\nQuanto mais você usa, mais você ganha!';

  @override
  String get onboardingStartTrackingButton => 'Comece a rastrear! →';

  @override
  String get onboardingNoCreditCard =>
      'Sem cartão de crédito • Sem taxas ocultas';

  @override
  String get cameraTakePhotoOfFood => 'Tire uma foto da sua comida';

  @override
  String get cameraFailedToInitialize => 'Falha ao inicializar a câmera';

  @override
  String get cameraPermissionDeniedMessage =>
      'Camera permission was denied. Please enable camera access in Settings to use AR Scan.';

  @override
  String get cameraFailedToCapture => 'Falha ao capturar foto';

  @override
  String get cameraFailedToPickFromGallery =>
      'Falha ao escolher a imagem da galeria';

  @override
  String get cameraProcessing => 'Proprocessando...';

  @override
  String get referralInviteFriends => 'Convide amigos';

  @override
  String get referralYourReferralCode => 'Seu código de referência';

  @override
  String get referralLoading => 'Carregando...';

  @override
  String get referralCopy => 'Cópia';

  @override
  String get referralShareCodeDescription =>
      'Compartilhe este código com amigos! Quando eles usam IA 3 vezes, vocês dois recebem recompensas!';

  @override
  String get referralEnterReferralCode => 'Insira o código de referência';

  @override
  String get referralCodeHint => 'ArCal-XXXX-XXXX-XXXX';

  @override
  String get referralSubmitCode => 'Enviar código';

  @override
  String get referralPleaseEnterCode =>
      'Por favor insira um código de referência';

  @override
  String get referralCodeAccepted => 'Código de referência aceito!';

  @override
  String get referralCodeCopied =>
      'Código de referência copiado para a área de transferência!';

  @override
  String referralEnergyBonus(int energy) {
    return '+$energy Energia!';
  }

  @override
  String get referralHowItWorks => 'Como funciona';

  @override
  String get referralStep1Title => 'Compartilhe seu código de referência';

  @override
  String get referralStep1Description =>
      'Copie e compartilhe seu ID ArCal com amigos';

  @override
  String get referralStep2Title => 'Amigo digite seu código';

  @override
  String get referralStep2Description =>
      'Eles recebem +20 de energia imediatamente';

  @override
  String get referralStep3Title => 'Amigo usa IA 3 vezes';

  @override
  String get referralStep3Description =>
      'Quando eles concluírem 3 análises de IA';

  @override
  String get referralStep4Title => 'Você é recompensado!';

  @override
  String get referralStep4Description => 'Você recebe +5 de energia!';

  @override
  String get tierBenefitsTitle => 'Benefícios de nível';

  @override
  String get tierBenefitsUnlockRewards =>
      'Desbloquear recompensas\ncom sequências diárias';

  @override
  String get tierBenefitsKeepStreakDescription =>
      'Mantenha sua sequência viva para desbloquear níveis mais altos e ganhar benefícios incríveis!';

  @override
  String get tierBenefitsHowItWorks => 'Como funciona';

  @override
  String get tierBenefitsDailyEnergyReward => 'Recompensa diária de energia';

  @override
  String get tierBenefitsDailyEnergyDescription =>
      'Use IA pelo menos uma vez por dia para ganhar energia bônus. Níveis mais altos = mais energia diária!';

  @override
  String get tierBenefitsPurchaseBonus => 'Bônus de compra';

  @override
  String get tierBenefitsPurchaseBonusDescription =>
      'Os níveis Gold e Diamond recebem energia extra em cada compra (10-20% a mais!)';

  @override
  String get tierBenefitsGracePeriod => 'Período de carência';

  @override
  String get tierBenefitsGracePeriodDescription =>
      'Perca um dia sem perder a sequência. Os níveis Silver+ recebem proteção!';

  @override
  String get tierBenefitsAllTiers => 'Todos os níveis';

  @override
  String get tierBenefitsNew => 'NOVO';

  @override
  String get tierBenefitsPopular => 'POPULAR';

  @override
  String get tierBenefitsBest => 'MELHOR';

  @override
  String get tierBenefitsDailyCheckIn => 'Check-in Diário';

  @override
  String get tierBenefitsProTips => 'Pro Dicas';

  @override
  String get tierBenefitsTip1 =>
      'Use a IA diariamente para ganhar energia grátis e construir sua sequência';

  @override
  String get tierBenefitsTip2 =>
      'O nível Diamante ganha +4 de energia por dia – são 120/mês!';

  @override
  String get tierBenefitsTip3 =>
      'O bônus de compra se aplica a TODOS os pacotes de energia!';

  @override
  String get tierBenefitsTip4 =>
      'O período de carência protege sua seqüência se você perder um dia';

  @override
  String get subscriptionEnergyPass => 'Passe Energia';

  @override
  String get subscriptionInAppPurchasesNotAvailable =>
      'Compras no aplicativo não disponíveis';

  @override
  String get subscriptionFailedToInitiatePurchase =>
      'Falha ao iniciar a compra';

  @override
  String subscriptionError(String error) {
    return 'Erro: $error';
  }

  @override
  String get subscriptionFailedToLoad => 'Falha ao carregar assinatura';

  @override
  String get subscriptionUnknownError => 'Erro desconhecido';

  @override
  String get subscriptionRetry => 'Tentar novamente';

  @override
  String get subscriptionEnergyPassActive => 'Passe de Energia Ativo';

  @override
  String get subscriptionUnlimitedAccess => 'Você tem acesso ilimitado';

  @override
  String get subscriptionStatus => 'Status';

  @override
  String get subscriptionRenews => 'Renova';

  @override
  String get subscriptionPrice => 'Preço';

  @override
  String get subscriptionYourBenefits => 'Seus benefícios';

  @override
  String get subscriptionManageSubscription => 'Gerenciar assinatura';

  @override
  String get subscriptionNoProductAvailable =>
      'Nenhum produto de assinatura disponível';

  @override
  String get subscriptionWhatYouGet => 'O que você ganha';

  @override
  String get subscriptionPerMonth => 'por mês';

  @override
  String get subscriptionSubscribeNow => 'Assine agora';

  @override
  String get subscriptionSubscribe => 'Assinar';

  @override
  String get subscriptionCancelAnytime => 'Cancele a qualquer momento';

  @override
  String get subscriptionAutoRenewTerms =>
      'Sua assinatura será renovada automaticamente. Você pode cancelar a qualquer momento no Google Play.';

  @override
  String get subscriptionAutoRenewTermsIos =>
      'O pagamento será cobrado na sua conta Apple ID na confirmação da compra. A assinatura é renovada automaticamente, a menos que seja cancelada pelo menos 24 horas antes do final do período atual. Pode gerir as suas assinaturas nas definições da conta App Store.';

  @override
  String subscriptionRenewsDate(String date) {
    return 'Renews: $date';
  }

  @override
  String get subscriptionBestValue => 'MELHOR VALOR';

  @override
  String get energyStoreTitle => 'Loja de Energia';

  @override
  String get energyPackages => 'Pacotes de Energia';

  @override
  String get energyPackageStarterKick => 'Starter Kick';

  @override
  String get energyPackageValuePack => 'Value Pack';

  @override
  String get energyPackagePowerUser => 'Power User';

  @override
  String get energyPackageUltimateSaver => 'Ultimate Saver';

  @override
  String get energyBadgeBestValue => 'MELHOR VALOR';

  @override
  String get energyBadgePopular => 'POPULAR';

  @override
  String get energyBadgeBonus10 => '+10% bónus';

  @override
  String get energyPassUnlimitedAI => 'Análise de IA ilimitada';

  @override
  String energyPassUnlimitedFromPrice(String price) {
    return 'Análise de IA ilimitada • a partir de $price/mês';
  }

  @override
  String get energyPassActive => 'ATIVO';

  @override
  String get subscriptionDeal => 'Oferta de assinatura';

  @override
  String get subscriptionViewDeal => 'Ver oferta';

  @override
  String get disclaimerHealthDisclaimer =>
      'Isenção de responsabilidade de saúde';

  @override
  String get disclaimerImportantReminders => 'Lembretes importantes:';

  @override
  String get disclaimerBullet1 => 'Todos os dados nutricionais são estimados';

  @override
  String get disclaimerBullet2 => 'A análise de IA pode conter erros';

  @override
  String get disclaimerBullet3 => 'Não substitui o aconselhamento profissional';

  @override
  String get disclaimerBullet4 =>
      'Consulte profissionais de saúde para orientação médica';

  @override
  String get disclaimerBullet5 => 'Use a seu próprio critério e risco';

  @override
  String get disclaimerIUnderstand => 'Eu entendo';

  @override
  String get privacyPolicyTitle => 'política de Privacidade';

  @override
  String get privacyPolicySubtitle =>
      'ArCal — Meu Oráculo de Registro de Ingestão';

  @override
  String get privacyPolicyHeaderNote =>
      'Seus dados alimentares permanecem no seu dispositivo. Balanço de energia sincronizado com segurança via Firebase.';

  @override
  String get privacyPolicySectionInformationWeCollect =>
      'Informações que coletamos';

  @override
  String get privacyPolicySectionDataStorage => 'Armazenamento de dados';

  @override
  String get privacyPolicySectionDataTransmission =>
      'Transmissão de Dados a Terceiros';

  @override
  String get privacyPolicySectionRequiredPermissions =>
      'Permissões necessárias';

  @override
  String get privacyPolicySectionSecurity => 'Segurança';

  @override
  String get privacyPolicySectionUserRights => 'Direitos do usuário';

  @override
  String get privacyPolicySectionDataRetention => 'Retenção de dados';

  @override
  String get privacyPolicySectionChildrenPrivacy => 'Privacidade infantil';

  @override
  String get privacyPolicySectionChangesToPolicy => 'Mudanças nesta política';

  @override
  String get privacyPolicySectionDataCollectionConsent =>
      'Consentimento para coleta de dados';

  @override
  String get privacyPolicySectionPDPACompliance =>
      'Conformidade com PDPA (Lei de Proteção de Dados Pessoais da Tailândia Pro)';

  @override
  String get privacyPolicySectionContactUs => 'Contate-nos';

  @override
  String get privacyPolicyEffectiveDate =>
      'Data de vigência: 18 de fevereiro de 2026\nÚltima atualização: 18 de fevereiro de 2026';

  @override
  String get termsOfServiceTitle => 'Termos de Serviço';

  @override
  String get termsSubtitle => 'ArCal — Meu Oráculo de Registro de Ingestão';

  @override
  String get termsSectionAcceptanceOfTerms => 'Aceitação dos Termos';

  @override
  String get termsSectionServiceDescription => 'Descrição do serviço';

  @override
  String get termsSectionDisclaimerOfWarranties =>
      'Isenção de responsabilidade de garantias';

  @override
  String get termsSectionEnergySystemTerms => 'Termos do Sistema Energético';

  @override
  String get termsSectionUserDataAndResponsibilities =>
      'Dados e responsabilidades do usuário';

  @override
  String get termsSectionBackupTransfer => 'Backup e transferência';

  @override
  String get termsSectionInAppPurchases => 'Compras no aplicativo';

  @override
  String get termsSectionProhibitedUses => 'ProUsos proibidos';

  @override
  String get termsSectionIntellectualProperty => 'Propriedade intelectual Pro';

  @override
  String get termsSectionLimitationOfLiability =>
      'Limitação de responsabilidade';

  @override
  String get termsSectionServiceTermination => 'Rescisão do serviço';

  @override
  String get termsSectionChangesToTerms => 'Mudanças nos Termos';

  @override
  String get termsSectionGoverningLaw => 'Lei Aplicável';

  @override
  String get termsSectionContactUs => 'Contate-nos';

  @override
  String get termsAcknowledgment =>
      'Ao usar ArCal, você reconhece que leu, compreendeu e concorda com estes Termos de Serviço.';

  @override
  String get termsLastUpdated => 'Última atualização: 15 de fevereiro de 2026';

  @override
  String get profileAndSettings => 'Proarquivo e configurações';

  @override
  String errorOccurred(String error) {
    return 'Erro: $error';
  }

  @override
  String get healthGoalsSection => 'Metas de saúde';

  @override
  String get dailyGoals => 'Metas Diárias';

  @override
  String get chatAiModeSection => 'Modo IA de bate-papo';

  @override
  String get selectAiPowersChat =>
      'Selecione qual IA potencializa seu bate-papo';

  @override
  String get miroAi => 'ArCal IA';

  @override
  String get miroAiSubtitle =>
      'Desenvolvido por Gemini • Multilíngue • Alta precisão';

  @override
  String get localAi => 'IA local';

  @override
  String get localAiSubtitle =>
      'No dispositivo • Somente em inglês • Precisão básica';

  @override
  String get free => 'Livre';

  @override
  String get cuisinePreferenceSection => 'Preferência de cozinha';

  @override
  String get preferredCuisine => 'Cozinha preferida';

  @override
  String get selectYourCuisine => 'Selecione sua cozinha';

  @override
  String get photoScanSection => 'Digitalização de fotos';

  @override
  String get languageSection => 'Linguagem';

  @override
  String get languageTitle => 'Idioma / Português';

  @override
  String get selectLanguage => 'Selecione o idioma / เลือกภาษา';

  @override
  String get systemDefault => 'Padrão do sistema';

  @override
  String get systemDefaultSublabel => 'Mais';

  @override
  String get english => 'Inglês';

  @override
  String get englishSublabel => 'O que é isso?';

  @override
  String get thai => 'ไทย (tailandês)';

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
  String get closeBilingual => 'Fechar / Fechar';

  @override
  String languageChangedTo(String language) {
    return 'Idioma alterado para $language';
  }

  @override
  String get accountSection => 'Conta';

  @override
  String get miroId => 'ArCal ID';

  @override
  String get miroIdCopied => 'ArCal ID copiado!';

  @override
  String get inviteFriends => 'Convide amigos';

  @override
  String get inviteFriendsSubtitle =>
      'Compartilhe seu código de indicação e ganhe recompensas!';

  @override
  String get unlimitedAiDoubleRewards => 'IA ilimitada + recompensas em dobro';

  @override
  String get plan => 'Plano';

  @override
  String get monthly => 'Mensal';

  @override
  String get started => 'Iniciado';

  @override
  String get renews => 'Renova';

  @override
  String get expires => 'Expira';

  @override
  String get autoRenew => 'Renovação automática';

  @override
  String get on => 'Sobre';

  @override
  String get off => 'Desligado';

  @override
  String get tapToManageSubscription => 'Toque para gerenciar a assinatura';

  @override
  String get dataSection => 'Dados';

  @override
  String get backupData => 'Dados de backup';

  @override
  String get backupDataSubtitle =>
      'Energia + Histórico Alimentar → salvar como arquivo';

  @override
  String get restoreFromBackup => 'Restaurar do backup';

  @override
  String get restoreFromBackupSubtitle => 'Importar dados do arquivo de backup';

  @override
  String get clearAllDataTitle => 'Limpar todos os dados?';

  @override
  String get clearAllDataContent =>
      'Todos os dados serão excluídos:\n• Entradas de alimentação\n• Minhas refeições\n• Ingredientes\n• Metas\n• Informações pessoais\n\nIsso não pode ser desfeito!';

  @override
  String get clearAllDataStorageDetails =>
      'Incluindo: Isar DB, SharedPreferences, SecureStorage';

  @override
  String get clearAllDataFactoryResetHint =>
      '(Como instalação nova — use junto com Factory Reset no Painel Admin)';

  @override
  String get allDataClearedSuccess => 'Todos os dados apagados com sucesso';

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
  String get aboutSection => 'Sobre';

  @override
  String get version => 'Versão';

  @override
  String get eula => 'EULA';

  @override
  String get healthDisclaimer => 'Isenção de responsabilidade de saúde';

  @override
  String get importantLegalInformation => 'Informações legais importantes';

  @override
  String get showTutorialAgain => 'Mostrar tutorial novamente';

  @override
  String get viewFeatureTour => 'Ver tour pelos recursos';

  @override
  String get showTutorialDialogTitle => 'Mostrar tutorial';

  @override
  String get showTutorialDialogContent =>
      'Isso mostrará o tour de recursos que destaca:\n\n• Sistema Energético\n• Digitalização de fotos com puxar para atualizar\n• Converse com ArCal IA\n\nVocê retornará à tela inicial.';

  @override
  String get showTutorialButton => 'Mostrar tutorial';

  @override
  String get tutorialResetMessage =>
      'Redefinição do tutorial! Vá para a tela inicial para visualizá-lo.';

  @override
  String get foodAnalysisTutorial => 'Tutorial de Análise de Alimentos';

  @override
  String get foodAnalysisTutorialSubtitle =>
      'Aprenda como usar recursos de análise de alimentos';

  @override
  String get backupCreated => 'Backup criado!';

  @override
  String get backupCreatedContent =>
      'Seu arquivo de backup foi criado com sucesso.';

  @override
  String get backupChooseDestination =>
      'Onde você gostaria de salvar seu backup?';

  @override
  String get backupSaveToDevice => 'Salvar no dispositivo';

  @override
  String get backupSaveToDeviceDesc =>
      'Salve em uma pasta de sua escolha neste dispositivo';

  @override
  String get backupShareToOther => 'Compartilhar para outro dispositivo';

  @override
  String get backupShareToOtherDesc =>
      'Enviar via linha, e-mail, unidade Google, etc.';

  @override
  String get backupSavedSuccess => 'Backup salvo!';

  @override
  String get backupSavedSuccessContent =>
      'Seu arquivo de backup foi salvo no local escolhido.';

  @override
  String get important => 'Importante:';

  @override
  String get backupImportantNotes =>
      '• Salve este arquivo em um local seguro (unidade Google, etc.)\n• As fotos NÃO estão incluídas no backup\n• A chave de transferência expira em 30 dias\n• A chave só pode ser usada uma vez';

  @override
  String get restoreBackup => 'Restaurar cópia de segurança?';

  @override
  String get backupFrom => 'Backup de:';

  @override
  String get date => 'Data:';

  @override
  String get energy => 'Energia:';

  @override
  String get foodEntries => 'Entradas de alimentos:';

  @override
  String get restoreImportant => 'Importante';

  @override
  String restoreImportantNotes(String energy) {
    return '• A energia atual neste dispositivo será SUBSTITUÍDA pela energia do backup ($energy)\n• As inscrições de alimentos serão MESCLADAS (não substituídas)\n• As fotos NÃO estão incluídas no backup\n• A chave de transferência será usada (não pode ser reutilizada)';
  }

  @override
  String get restore => 'Restaurar';

  @override
  String get restoreComplete => 'Restauração concluída!';

  @override
  String get restoreCompleteContent =>
      'Seus dados foram restaurados com sucesso.';

  @override
  String get newEnergyBalance => 'Novo Balanço Energético:';

  @override
  String get foodEntriesImported => 'Entradas Alimentares Importadas:';

  @override
  String get myMealsImported => 'Minhas refeições importadas:';

  @override
  String get appWillRefresh =>
      'Seu aplicativo será atualizado para mostrar os dados restaurados.';

  @override
  String get backupFailed => 'Falha no backup';

  @override
  String get invalidBackupFile => 'Arquivo de backup inválido';

  @override
  String get restoreSelectDataFile =>
      'This file only contains Energy. To restore food entries, select the data file (arcal_data_*.json) instead.';

  @override
  String get restoreZeroEntriesHint =>
      'No food entries were imported. Make sure you selected the data file (arcal_data_*.json), not the energy file.';

  @override
  String get restoreFailed => 'Falha na restauração';

  @override
  String get analyticsDataCollection => 'Coleta de dados analíticos';

  @override
  String get analyticsEnabled =>
      'Analytics ativado - Obrigado por ajudar a melhorar o app';

  @override
  String get analyticsDisabled =>
      'Analytics desativado - Nenhum dado de uso coletado';

  @override
  String get enabled => 'Habilitado';

  @override
  String get enabledSubtitle =>
      'Ativado - Ajuda a melhorar a experiência do usuário';

  @override
  String get disabled => 'Desabilitado';

  @override
  String get disabledSubtitle => 'Desativado - Nenhum dado de uso coletado';

  @override
  String get imagesPerDay => 'Imagens por dia';

  @override
  String scanUpToImagesPerDay(String limit) {
    return 'Digitalize até $limit imagens por dia';
  }

  @override
  String get reset => 'Reiniciar';

  @override
  String get resetScanHistory => 'Redefinir histórico de verificação';

  @override
  String get resetScanHistorySubtitle =>
      'Exclua todas as entradas digitalizadas e verifique novamente';

  @override
  String get imagesPerDayDialog => 'Imagens por dia';

  @override
  String get maxImagesPerDayDescription =>
      'Máximo de imagens para digitalizar por dia\nVerifica apenas a data selecionada';

  @override
  String scanLimitSetTo(String limit) {
    return 'Limite de digitalização definido para $limit imagens por dia';
  }

  @override
  String get resetScanHistoryDialog => 'Redefinir histórico de verificação?';

  @override
  String get resetScanHistoryContent =>
      'Todas as entradas de alimentos digitalizadas na galeria serão excluídas.\nPuxe para baixo em qualquer data para digitalizar novamente as imagens.';

  @override
  String resetComplete(String count) {
    return 'Redefinição concluída - entradas $count excluídas. Puxe para baixo para digitalizar novamente.';
  }

  @override
  String questBarStreak(int days) {
    return 'Sequência $days dia';
  }

  @override
  String questBarDaysToNextTier(int days, String tier) {
    return '$days dias → $tier';
  }

  @override
  String get questBarMaxTier => 'Nível máximo! 💎';

  @override
  String get questBarOfferDismissed => 'Oferta oculta';

  @override
  String get questBarViewOffer => 'Ver oferta';

  @override
  String get questBarNoOffersNow => '• Nenhuma oferta no momento';

  @override
  String get questBarWeeklyChallenges => '🎯 Desafios Semanais';

  @override
  String get questBarMilestones => '🏆 Marcos';

  @override
  String get questBarInviteFriends => '👥 Convide amigos e ganhe 20E';

  @override
  String questBarTimeRemaining(String time) {
    return '⏰ Tempo restante $time';
  }

  @override
  String questBarClaimDailyEnergy(int energy) {
    return '+${energy}E';
  }

  @override
  String questBarShareReferralError(String error) {
    return 'Erro ao compartilhar: $error';
  }

  @override
  String tierCelebrationTitle(String tier) {
    return '$tier Comemoração 🎉';
  }

  @override
  String tierCelebrationDay(int day) {
    return 'Dia $day';
  }

  @override
  String get tierCelebrationExpired => 'Expirado';

  @override
  String get tierCelebrationComplete => 'Completo!';

  @override
  String questBarWatchAd(int energy) {
    return 'Assistir ao anúncio +$energy⚡';
  }

  @override
  String questBarAdRemaining(int remaining, int total) {
    return '$remaining/$total restantes hoje';
  }

  @override
  String questBarAdSuccess(int energy) {
    return 'Anúncio assistido! +$energy Energia entrando...';
  }

  @override
  String get questBarAdNotReady => 'O anúncio não está pronto. Tente novamente';

  @override
  String get questBarDailyChallenge => 'Desafio Diário';

  @override
  String get questBarUseAi => 'Usar energia';

  @override
  String get questBarResetsMonday => 'Reinicia toda segunda-feira';

  @override
  String get questBarClaimed => 'Reivindicado!';

  @override
  String get questBarHideOffer => 'Esconder';

  @override
  String get questBarViewDetails => 'Visualizar';

  @override
  String questBarShareText(String link) {
    return 'Experimente ArCal! Análise de alimentos com tecnologia de IA 🍔\nUse este link e ambos ganharemos +20 de energia grátis!\n\n$link';
  }

  @override
  String get questBarShareSubject => 'Tente ArCal';

  @override
  String get claimButtonTitle => 'Reivindique energia diária';

  @override
  String claimButtonReceived(String energy) {
    return 'Recebido +${energy}E!';
  }

  @override
  String get claimButtonAlreadyClaimed => 'Já reivindicado hoje';

  @override
  String claimButtonError(String error) {
    return 'Erro: $error';
  }

  @override
  String get seasonalQuestLimitedTime => 'TEMPO LIMITADO';

  @override
  String seasonalQuestDaysLeft(int days) {
    return '$days dias restantes';
  }

  @override
  String seasonalQuestRewardDaily(int reward) {
    return '+${reward}E/dia';
  }

  @override
  String seasonalQuestRewardOnce(int reward) {
    return '+${reward}E uma vez';
  }

  @override
  String get seasonalQuestClaimed => 'Reivindicado!';

  @override
  String get seasonalQuestClaimedToday => 'Reivindicado hoje';

  @override
  String get errorFailed => 'Fracassado';

  @override
  String get errorFailedToClaim => 'Falha ao reivindicar';

  @override
  String errorGeneric(String error) {
    return 'Erro: $error';
  }

  @override
  String get milestoneNoMilestonesToClaim =>
      'Ainda não há marcos para reivindicar';

  @override
  String milestoneClaimedEnergy(int energy) {
    return '🎁 Energia reivindicada +$energy!';
  }

  @override
  String get milestoneTitle => 'Conquistas';

  @override
  String milestoneUseEnergyComplete(int threshold) {
    return 'Usar Energia $threshold';
  }

  @override
  String milestoneNext(int threshold) {
    return 'Próximo: ${threshold}E';
  }

  @override
  String get milestoneAllComplete => 'Todos os marcos concluídos!';

  @override
  String get noEnergyTitle => 'Sem energia';

  @override
  String get noEnergyContent =>
      'Você precisa de 1 energia para analisar alimentos com IA';

  @override
  String get noEnergyTip =>
      'Você ainda pode registrar alimentos manualmente (sem IA) gratuitamente';

  @override
  String get noEnergyLater => 'Mais tarde';

  @override
  String noEnergyWatchAd(int remaining) {
    return 'Assistir ao anúncio ($remaining/3)';
  }

  @override
  String get noEnergyBuyEnergy => 'Comprar energia';

  @override
  String get tierBronze => 'Bronze';

  @override
  String get tierSilver => 'Prata';

  @override
  String get tierGold => 'Ouro';

  @override
  String get tierDiamond => 'Diamante';

  @override
  String get tierStarter => 'Iniciante';

  @override
  String get tierUpCongratulations => '🎉 Parabéns!';

  @override
  String tierUpYouReached(String tier) {
    return 'Você alcançou $tier!';
  }

  @override
  String get tierUpMotivation =>
      'Monitore calorias como um profissional\nO corpo dos seus sonhos está cada vez mais próximo!';

  @override
  String tierUpReward(int reward) {
    return '+${reward}E Recompensa!';
  }

  @override
  String get referralAllLevelsClaimed => 'Todos os níveis reivindicados!';

  @override
  String referralLevel(int level, String subtitle) {
    return 'Nível $level: $subtitle';
  }

  @override
  String referralProgress(int current, int target, int level, int total) {
    return '[$current/$target] (Nível $level/$total)';
  }

  @override
  String referralClaimedLevel(int level, int reward) {
    return '🎁 Nível reivindicado $level: +$reward Energia!';
  }

  @override
  String get challengeUseAi10 => 'Usar Energia 10';

  @override
  String get specifyIngredients => 'Especifique ingredientes conhecidos';

  @override
  String get specifyIngredientsOptional =>
      'Especifique ingredientes conhecidos (opcional)';

  @override
  String get specifyIngredientsHint =>
      'Insira os ingredientes que você conhece e a IA descobrirá temperos, óleos e molhos escondidos para você.';

  @override
  String get sendToAi => 'Enviar para IA';

  @override
  String get reanalyzeWithIngredients =>
      'Adicione ingredientes e analise novamente';

  @override
  String get reanalyzeButton => 'Reanalisar (1 Energia)';

  @override
  String get ingredientsSaved => 'Ingredientes salvos';

  @override
  String get pleaseAddAtLeastOneIngredient =>
      'Adicione pelo menos 1 ingrediente';

  @override
  String get hiddenIngredientsDiscovered =>
      'Ingredientes ocultos descobertos pela IA';

  @override
  String get retroScanTitle => 'Digitalizar fotos recentes?';

  @override
  String get retroScanDescription =>
      'Podemos digitalizar suas fotos do último 1 dia para encontrar automaticamente fotos de alimentos e adicioná-las ao seu diário.';

  @override
  String get retroScanNote =>
      'Apenas fotos de comida são detectadas – outras fotos são ignoradas. Nenhuma foto sai do seu dispositivo.';

  @override
  String get retroScanStart => 'Digitalizar minhas fotos';

  @override
  String get retroScanSkip => 'Pular por enquanto';

  @override
  String get retroScanInProgress => 'Digitalizando...';

  @override
  String get retroScanTagline =>
      'ArCal está transformando seu\nfotos de alimentos em dados de saúde.';

  @override
  String get retroScanFetchingPhotos => 'Buscando fotos recentes...';

  @override
  String get retroScanAnalyzing => 'Detectando fotos de comida...';

  @override
  String retroScanPhotosFound(int count) {
    return '$count fotos encontradas no último 1 dia';
  }

  @override
  String get retroScanCompleteTitle => 'Digitalização concluída!';

  @override
  String retroScanCompleteDesc(int count) {
    return 'Encontrei $count fotos de comida! Eles foram adicionados à sua linha do tempo, prontos para análise de IA.';
  }

  @override
  String get retroScanNoResultsTitle => 'Nenhuma foto de comida encontrada';

  @override
  String get retroScanNoResultsDesc =>
      'Nenhuma foto de comida detectada no último 1 dia. Experimente tirar uma foto da sua próxima refeição!';

  @override
  String get retroScanAnalyzeHint =>
      'Toque em “Analisar tudo” na sua linha do tempo para obter análises nutricionais de IA para essas entradas.';

  @override
  String get retroScanDone => 'Entendi!';

  @override
  String get welcomeEndTitle => 'Bem-vindo ao ArCal!';

  @override
  String get welcomeEndMessage => 'ArCal está ao seu serviço.';

  @override
  String get welcomeEndJourney => 'Tenham uma boa viagem juntos!!';

  @override
  String get welcomeEndStart => 'Vamos começar!';

  @override
  String greetingCalorieSummary(
      int remaining, int protein, int carbs, int fat) {
    return 'Oi! Como posso ajudá-lo hoje? Você ainda tem $remaining kcal sobrando. Até agora: Proteína ${protein}g, Carboidratos ${carbs}g, Gordura ${fat}g. Diga-me o que você comeu - liste tudo por refeição e eu registrarei tudo para você. Mais detalhes mais precisos!!';
  }

  @override
  String greetingCuisineTip(String cuisine) {
    return 'Sua culinária preferida está definida como $cuisine. Você pode alterá-lo em Configurações a qualquer momento!';
  }

  @override
  String greetingEnergyTip(int balance) {
    return 'Você tem $balance Energia disponível. Não se esqueça de resgatar sua recompensa diária no emblema de Energia!';
  }

  @override
  String get greetingRenamePhotoTip =>
      'Dica: você pode renomear fotos de alimentos para ajudar ArCal a analisar com mais precisão!';

  @override
  String get greetingAddIngredientsTip =>
      'Dica: você pode adicionar ingredientes de que tenha certeza antes de enviar para ArCal para análise. Vou descobrir todos os pequenos detalhes chatos para você!';

  @override
  String greetingBackupReminder(int days) {
    return 'Ei chefe! Você não faz backup dos seus dados há $days dias. Recomendo fazer backup em Configurações — seus dados são armazenados localmente e não poderei recuperá-los se algo acontecer!';
  }

  @override
  String get greetingFallback =>
      'Oi! Como posso ajudá-lo hoje? Me conta o que você comeu!';

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
  String savedAsNewMeal(String name) {
    return 'Saved as new meal: $name';
  }

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
  String get parentIngredientDrivenBySubs =>
      'Amount and unit are calculated from sub-ingredients (locked)';

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
      'Fornecer o nome do alimento, a quantidade e escolher se é comida ou produto melhorará a precisão da IA.';

  @override
  String get hideDetails => 'Hide details';

  @override
  String get showDetails => 'Show details';

  @override
  String get searchModeLabel => 'Modo de pesquisa';

  @override
  String get normalFood => 'Comida';

  @override
  String get normalFoodDesc => 'Comida caseira regular';

  @override
  String get packagedProduct => 'Produto';

  @override
  String get packagedProductDesc => 'Embalado com etiqueta nutricional';

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
  String get longPressToSelect => 'Pressione e segure para selecionar';

  @override
  String get healthSyncSection => 'Sincronização de Saúde';

  @override
  String get healthSyncTitle => 'Sincronizar com App de Saúde';

  @override
  String get healthSyncSubtitleOn =>
      'Alimentos sincronizados • Energia ativa incluída';

  @override
  String get healthSyncSubtitleOff =>
      'Toque para conectar Apple Health / Health Connect';

  @override
  String get healthSyncEnabled => 'Sincronização de saúde ativada';

  @override
  String get healthSyncDisabled => 'Sincronização de saúde desativada';

  @override
  String get healthSyncPermissionDeniedTitle => 'Permissão Necessária';

  @override
  String get healthSyncPermissionDeniedMessage =>
      'Você negou anteriormente o acesso aos dados de saúde.\nPor favor, ative nas configurações do dispositivo.';

  @override
  String get healthSyncGoToSettings => 'Ir para Configurações';

  @override
  String healthSyncActiveEnergyValue(String value) {
    return '+$value kcal queimadas hoje';
  }

  @override
  String get healthSyncNotAvailable =>
      'Health Connect não está disponível neste dispositivo. Por favor, instale o app Health Connect.';

  @override
  String get healthSyncFoodSynced => 'Alimento sincronizado com App de Saúde';

  @override
  String get healthSyncFoodDeletedFromHealth =>
      'Alimento removido do App de Saúde';

  @override
  String get bmrSettingTitle => 'BMR (Taxa Metabólica Basal)';

  @override
  String get bmrSettingSubtitle => 'Usado para estimar energia ativa';

  @override
  String get bmrDialogTitle => 'Definir seu BMR';

  @override
  String get bmrDialogDescription =>
      'O ArCal usa o BMR para subtrair a energia em repouso do total de calorias queimadas, mostrando apenas sua energia ativa. O padrão é 1500 kcal/dia. Você pode encontrar seu BMR em apps de fitness ou calculadoras online.';

  @override
  String get healthSyncEnabledBmrHint =>
      'Sincronização de saúde ativada. BMR padrão: 1500 kcal/dia — ajuste nas Configurações.';

  @override
  String get privacyPolicySectionHealthData => 'Integração de Dados de Saúde';

  @override
  String get termsSectionHealthDataSync => 'Sincronização de Dados de Saúde';

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
  String get subscriptionAutoRenew => 'Renovação automática';

  @override
  String get subscriptionAutoRenewOn => 'Ativada';

  @override
  String get subscriptionAutoRenewOff =>
      'Desativada — expira no final do período';

  @override
  String get subscriptionManagedByAppStore =>
      'Assinatura gerida através da App Store';

  @override
  String get subscriptionManagedByPlayStore =>
      'Assinatura gerida através do Google Play';

  @override
  String get subscriptionCannotLoadPrices =>
      'Não é possível carregar preços da loja neste momento';

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
  String get freepassActive => 'ATIVO';

  @override
  String get freepassUnlimitedAI => 'Análise IA ilimitada';

  @override
  String freepassDaysRemaining(int days) {
    return '$days dias restantes';
  }

  @override
  String get freepassDaysTitle => 'Dias de Freepass';

  @override
  String get freepassDaysUnit => 'dias';

  @override
  String freepassDaysSaved(int days) {
    return 'Você tem $days dias salvos';
  }

  @override
  String freepassDaysBadge(int days) {
    return '${days}d';
  }

  @override
  String get freepassConvertTitle => 'Converter Energy em Freepass';

  @override
  String freepassConvertRate(int energy) {
    return '$energy Energy = 1 dia de IA ilimitada';
  }

  @override
  String get freepassConvertDescription =>
      'Os dias de Freepass nunca expiram. Eles se ativam automaticamente quando sua assinatura Energy Pass termina.';

  @override
  String freepassConvertButton(int days) {
    return 'Converter (até $days dias)';
  }

  @override
  String freepassConvertMinimum(int energy) {
    return 'Necessário mínimo de $energy Energy';
  }

  @override
  String get freepassConvertConverting => 'Convertendo...';

  @override
  String get freepassConvertDialogTitle => 'Converter em Freepass';

  @override
  String get freepassConvertDialogQuestion => 'Quantos dias?';

  @override
  String get freepassConvertDialogDay => 'dia';

  @override
  String get freepassConvertDialogDays => 'dias';

  @override
  String get freepassConvertDialogEnergyCost => 'Custo de Energy';

  @override
  String get freepassConvertDialogRemainingBalance => 'Saldo restante';

  @override
  String get freepassConvertDialogConfirm => 'Converter';

  @override
  String freepassConvertSuccess(int energy, int days) {
    return '$energy Energy convertidos em $days dias de Freepass!';
  }

  @override
  String get freepassConvertFailed => 'Falha na conversão';

  @override
  String get freepassConvertError => 'Erro durante a conversão';

  @override
  String get freepassConvertServiceUnavailable =>
      'Serviço temporariamente indisponível. Tente novamente mais tarde.';

  @override
  String get subscriptionChangePlan => 'Alterar plano';

  @override
  String get subscriptionChangePlanDescAndroid =>
      'Você pode alterar seu plano através do gerenciamento de assinaturas do Google Play. O novo plano será aplicado no próximo ciclo de cobrança.';

  @override
  String get subscriptionChangePlanDescIos =>
      'Você pode fazer upgrade ou downgrade do seu plano através do gerenciamento de assinaturas da App Store.';

  @override
  String get subscriptionCurrentPlan => 'ATUAL';

  @override
  String get subscriptionChangePlanButton => 'Alterar';

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
      'Please review how ArCal uses your data. Toggle each option, then tap Continue.';

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
      'Personalized ads help keep ArCal free. You can opt out anytime.';

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

  @override
  String get arScan => 'AR Scan';

  @override
  String get arScanPositionFood => 'Position food in the frame';

  @override
  String get arScanStartCapture => 'Start Scanning';

  @override
  String get arScanContinueAnalysis => 'Continue to Analysis';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get pickFromGallery => 'Pick from Gallery';

  @override
  String get arScanFoodNotDetected => 'Food not detect';

  @override
  String get arScanAngleTop => 'Top';

  @override
  String get arScanAngleDiagonal => 'Diagonal';

  @override
  String get arScanAngleSide => 'Side';

  @override
  String arScanAngleProgress(int current, int total) {
    return '$current/$total';
  }

  @override
  String arScanAngleCaptured(String zone, int current, int total) {
    return '$zone angle captured ($current/$total)';
  }

  @override
  String get arScanTapToCapture => 'Tap anywhere to capture';

  @override
  String get arScanMoveToAngle => 'Tilt to next angle';

  @override
  String get subscriptionPlanWeeklyName => 'Energy Pass Semanal';

  @override
  String get subscriptionPlanMonthlyName => 'Energy Pass Mensal';

  @override
  String get subscriptionPlanYearlyName => 'Energy Pass Anual';

  @override
  String get subscriptionPlanWeeklyDesc => 'Assinatura semanal';

  @override
  String get subscriptionPlanMonthlyDesc => 'Análise de IA ilimitada';

  @override
  String get subscriptionPlanYearlyDesc => 'Melhor valor — poupe 81%';

  @override
  String get subscriptionPeriodWeek => 'semana';

  @override
  String get subscriptionPeriodMonth => 'mês';

  @override
  String get subscriptionPeriodYear => 'ano';

  @override
  String get subscriptionBenefitUnlimitedAI => 'Análise de IA ilimitada';

  @override
  String get subscriptionBenefitExclusiveBadge => 'Distintivo exclusivo';

  @override
  String get subscriptionBenefitPrioritySupport => 'Suporte prioritário';

  @override
  String subscriptionSavePercent(String price) {
    return 'Poupe 81% — $price/mês';
  }

  @override
  String subscriptionYearlySavingsVsMonthly(int percent, String price) {
    return 'Poupe $percent% — $price/mês';
  }

  @override
  String get subscriptionStatusActive => 'Ativo';

  @override
  String get subscriptionStatusCancelled => 'Cancelado';

  @override
  String get subscriptionStatusExpired => 'Expirado';

  @override
  String get subscriptionStatusGracePeriod => 'Período de carência';

  @override
  String get subscriptionStatusNone => 'Não assinante';

  @override
  String get energyYourBalance => 'Seu saldo de energia';

  @override
  String get energyLimitedTime => 'TEMPO LIMITADO';

  @override
  String energyAmountLabel(int amount) {
    return '$amount Energia';
  }

  @override
  String get energyClaiming => 'Resgatando...';

  @override
  String energyDaysFreeAI(int days) {
    return '$days dias de IA grátis';
  }

  @override
  String energyBonusOnPurchases(int percent) {
    return '+$percent% Bónus em todas as compras!';
  }

  @override
  String energyBonusBreakdown(int base, int bonus, int total) {
    return '$base + $bonus Bónus = $total Energia';
  }

  @override
  String energyPromoBonusPercent(int percent) {
    return 'Bónus promo: +$percent%';
  }

  @override
  String energyTierBonusPercent(String tierName, int percent) {
    return 'Bónus $tierName: +$percent%';
  }

  @override
  String get energyAboutTitle => 'Sobre Energia';

  @override
  String get energyInfoAnalysis => '1 Energia = 1 análise de IA';

  @override
  String get energyInfoNeverExpires => 'A energia nunca expira';

  @override
  String get energyInfoOneTime => 'Compra única, por dispositivo';

  @override
  String get energyInfoManualFree => 'O registo manual é sempre gratuito';

  @override
  String get shareCard => 'Share Card';

  @override
  String get share => 'Share';

  @override
  String get saveToGallery => 'Save';

  @override
  String get savedToGallery => 'Saved to gallery';

  @override
  String get saveFailed => 'Failed to save';

  @override
  String get macros => 'Macros';

  @override
  String get micronutrients => 'Micronutrients';

  @override
  String get shareNoImageSelected => 'No image selected yet';

  @override
  String get shareImageSelected => 'Image selected';

  @override
  String get shareSelectImageRequired =>
      'Please select an image before sharing';

  @override
  String get shareCardDailySummaryTitle => 'Resumo Diário';

  @override
  String get shareCardFiber => 'Fibra';

  @override
  String get shareCardSugar => 'Açúcar';

  @override
  String get shareCardSodium => 'Sódio';

  @override
  String shareCardDayStreak(int days) {
    return 'Sequência de $days dias';
  }

  @override
  String shareCardDays(int days) {
    return '$days dias';
  }

  @override
  String get shareCardShowBoundingBox => 'Show bounding box';
}
