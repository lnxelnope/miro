// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class L10nPt extends L10n {
  L10nPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'MiRO';

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
  String get chatHint => 'Diga Miro, por exemplo. \"Arroz frito\"...';

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
  String get proUnlocked => 'MiRO Pro';

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
  String get welcomeTitle => 'MiRO';

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
  String get appBarMiro => 'MIRO';

  @override
  String get permissionRequired => 'Permissão necessária';

  @override
  String get permissionRequiredDesc => 'MIRO precisa de acesso ao seguinte:';

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
  String get helloImMiro => 'Olá! Eu sou Miro';

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
      'Nota: somente em inglês, análise básica\nMude para Miro AI para obter melhores resultados!';

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
  String get referralCodeHint => 'MIRO-XXXX-XXXX-XXXX';

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
      'Copie e compartilhe seu ID MiRO com amigos';

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
  String get subscriptionCancelAnytime => 'Cancele a qualquer momento';

  @override
  String get subscriptionAutoRenewTerms =>
      'Sua assinatura será renovada automaticamente. Você pode cancelar a qualquer momento no Google Play.';

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
      'MiRO — Meu Oráculo de Registro de Ingestão';

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
  String get termsSubtitle => 'MiRO — Meu Oráculo de Registro de Ingestão';

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
      'Ao usar MiRO, você reconhece que leu, compreendeu e concorda com estes Termos de Serviço.';

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
  String get miroAi => 'Miro IA';

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
  String get miroId => 'MiRO ID';

  @override
  String get miroIdCopied => 'MiRO ID copiado!';

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
  String get allDataClearedSuccess => 'Todos os dados apagados com sucesso';

  @override
  String get aboutSection => 'Sobre';

  @override
  String get version => 'Versão';

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
      'Isso mostrará o tour de recursos que destaca:\n\n• Sistema Energético\n• Digitalização de fotos com puxar para atualizar\n• Converse com Miro IA\n\nVocê retornará à tela inicial.';

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
  String get restoreFailed => 'Falha na restauração';

  @override
  String get analyticsDataCollection => 'Coleta de dados analíticos';

  @override
  String get analyticsEnabled => 'Analytics ativado -';

  @override
  String get analyticsDisabled => 'Análise desativada -';

  @override
  String get enabled => 'Habilitado';

  @override
  String get enabledSubtitle => 'Ativado -';

  @override
  String get disabled => 'Desabilitado';

  @override
  String get disabledSubtitle => 'Desativado - ไม่เก็บข้อมูลการใช้งาน';

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
    return 'Experimente MiRO! Análise de alimentos com tecnologia de IA 🍔\nUse este link e ambos ganharemos +20 de energia grátis!\n\n$link';
  }

  @override
  String get questBarShareSubject => 'Tente MiRO';

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
      'Podemos digitalizar suas fotos dos últimos 7 dias para encontrar automaticamente fotos de alimentos e adicioná-las ao seu diário.';

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
      'MiRO está transformando seu\nfotos de alimentos em dados de saúde.';

  @override
  String get retroScanFetchingPhotos => 'Buscando fotos recentes...';

  @override
  String get retroScanAnalyzing => 'Detectando fotos de comida...';

  @override
  String retroScanPhotosFound(int count) {
    return '$count fotos encontradas nos últimos 7 dias';
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
      'Nenhuma foto de comida detectada nos últimos 7 dias. Experimente tirar uma foto da sua próxima refeição!';

  @override
  String get retroScanAnalyzeHint =>
      'Toque em “Analisar tudo” na sua linha do tempo para obter análises nutricionais de IA para essas entradas.';

  @override
  String get retroScanDone => 'Entendi!';

  @override
  String get welcomeEndTitle => 'Bem-vindo ao MiRO!';

  @override
  String get welcomeEndMessage => 'MiRO está ao seu serviço.';

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
      'Dica: você pode renomear fotos de alimentos para ajudar MiRO a analisar com mais precisão!';

  @override
  String get greetingAddIngredientsTip =>
      'Dica: você pode adicionar ingredientes de que tenha certeza antes de enviar para MiRO para análise. Vou descobrir todos os pequenos detalhes chatos para você!';

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
      'O MiRO usa o BMR para subtrair a energia em repouso do total de calorias queimadas, mostrando apenas sua energia ativa. O padrão é 1500 kcal/dia. Você pode encontrar seu BMR em apps de fitness ou calculadoras online.';

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
}
