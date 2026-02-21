// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class L10nEs extends L10n {
  L10nEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'MiRO';

  @override
  String get save => 'Ahorrar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Borrar';

  @override
  String get edit => 'Editar';

  @override
  String get search => 'Buscar';

  @override
  String get loading => 'Cargando...';

  @override
  String get error => 'Se produjo un error';

  @override
  String get confirm => 'Confirmar';

  @override
  String get close => 'Cerca';

  @override
  String get done => 'Hecho';

  @override
  String get next => 'Próximo';

  @override
  String get skip => 'Saltar';

  @override
  String get retry => 'Rever';

  @override
  String get ok => 'DE ACUERDO';

  @override
  String get foodName => 'Nombre del alimento';

  @override
  String get calories => 'calorías';

  @override
  String get protein => 'Proteína';

  @override
  String get carbs => 'carbohidratos';

  @override
  String get fat => 'Gordo';

  @override
  String get servingSize => 'Tamaño de la porción';

  @override
  String get servingUnit => 'Unidad';

  @override
  String get kcal => 'kcal';

  @override
  String get mealBreakfast => 'Desayuno';

  @override
  String get mealLunch => 'Almuerzo';

  @override
  String get mealDinner => 'Cena';

  @override
  String get mealSnack => 'Bocadillo';

  @override
  String get todaySummary => 'Resumen de hoy';

  @override
  String dateSummary(String date) {
    return 'Resumen de $date';
  }

  @override
  String get savedSuccess => 'Guardado exitosamente';

  @override
  String get deletedSuccess => 'Eliminado exitosamente';

  @override
  String get pleaseEnterFoodName => 'Por favor ingrese el nombre del alimento';

  @override
  String get noDataYet => 'Aún no hay datos';

  @override
  String get addFood => 'agregar comida';

  @override
  String get editFood => 'Editar comida';

  @override
  String get deleteFood => 'eliminar comida';

  @override
  String get deleteConfirm => '¿Confirmar eliminación?';

  @override
  String get foodLoggedSuccess => '¡Comida registrada!';

  @override
  String get noApiKey => 'Por favor configure Gemini API Key';

  @override
  String get noApiKeyDescription =>
      'Vaya a Profile → API Configuración para configurar';

  @override
  String get apiKeyTitle => 'Configurar Gemini API Key';

  @override
  String get apiKeyRequired => 'API Key requerido';

  @override
  String get apiKeyFreeNote => 'Gemini API es de uso gratuito';

  @override
  String get apiKeySetup => 'Configurar API Key';

  @override
  String get testConnection => 'Conexión de prueba';

  @override
  String get connectionSuccess =>
      '¡Conectado exitosamente! Preparado para usar';

  @override
  String get connectionFailed => 'La conexión falló';

  @override
  String get pasteKey => 'Pasta';

  @override
  String get deleteKey => 'Eliminar API Key';

  @override
  String get openAiStudio => 'Abierto Google AI Studio';

  @override
  String get chatHint => 'Dígale a Miro, p. \"Arroz frito con troncos\"...';

  @override
  String get chatFoodSaved => '¡Comida registrada!';

  @override
  String chatFoodSavedDetail(
      String name, String serving, String unit, String cal) {
    return '$name $serving $unit\n$cal kcal';
  }

  @override
  String get featureNotAvailable =>
      'Lo sentimos, esta función aún no está disponible';

  @override
  String get goalCalories => 'Calorías/día';

  @override
  String get goalProtein => 'Proteína/día';

  @override
  String get goalCarbs => 'carbohidratos/día';

  @override
  String get goalFat => 'Grasa/día';

  @override
  String get goalWater => 'Agua/día';

  @override
  String get healthGoals => 'Metas de salud';

  @override
  String get profile => 'Proarchivo';

  @override
  String get settings => 'Ajustes';

  @override
  String get privacyPolicy => 'política de privacidad';

  @override
  String get termsOfService => 'Términos de servicio';

  @override
  String get clearAllData => 'Borrar todos los datos';

  @override
  String get clearAllDataConfirm =>
      'Todos los datos serán eliminados. ¡Esto no se puede deshacer!';

  @override
  String get about => 'Acerca de';

  @override
  String get language => 'Idioma';

  @override
  String get upgradePro => 'Actualizar a Pro';

  @override
  String get proUnlocked => 'MiRO Pro';

  @override
  String get proDescription => 'Análisis ilimitado de alimentos con IA';

  @override
  String aiRemaining(int remaining, int total) {
    return 'Análisis de IA: $remaining/$total restantes hoy';
  }

  @override
  String get aiLimitReached => 'Límite de IA alcanzado para hoy (3/3)';

  @override
  String get restorePurchase => 'Restaurar compra';

  @override
  String get myMeals => 'Mis comidas:';

  @override
  String get createMeal => 'Crear comida';

  @override
  String get ingredients => 'Ingredientes';

  @override
  String get searchFood => 'buscar comida';

  @override
  String get analyzing => 'Analizando...';

  @override
  String get analyzeWithAi => 'Analizar con IA';

  @override
  String get analysisComplete => 'Análisis completo';

  @override
  String get timeline => 'Línea de tiempo';

  @override
  String get diet => 'Dieta';

  @override
  String get quickAdd => 'Agregar rápido';

  @override
  String get welcomeTitle => 'MiRO';

  @override
  String get welcomeSubtitle => 'Registro de alimentos sencillo con IA';

  @override
  String get onboardingFeature1 => 'Toma una foto';

  @override
  String get onboardingFeature1Desc =>
      'La IA calcula las calorías automáticamente';

  @override
  String get onboardingFeature2 => 'Escriba para iniciar sesión';

  @override
  String get onboardingFeature2Desc =>
      'Di \"comí arroz frito\" y se registrará.';

  @override
  String get onboardingFeature3 => 'Resumen diario';

  @override
  String get onboardingFeature3Desc =>
      'Seguimiento kcal, proteínas, carbohidratos, grasas';

  @override
  String get basicInfo => 'Información básica';

  @override
  String get basicInfoDesc => 'Para calcular tus calorías diarias recomendadas';

  @override
  String get gender => 'Género';

  @override
  String get male => 'Masculino';

  @override
  String get female => 'Femenino';

  @override
  String get age => 'Edad';

  @override
  String get weight => 'Peso';

  @override
  String get height => 'Altura';

  @override
  String get activityLevel => 'Nivel de actividad';

  @override
  String tdeeResult(int kcal) {
    return 'Su TDEE: $kcal kcal/día';
  }

  @override
  String get setupAiTitle => 'Configurar Gemini AI';

  @override
  String get setupAiDesc => 'Toma una foto y la IA la analiza automáticamente';

  @override
  String get setupNow => 'Configurar ahora';

  @override
  String get skipForNow => 'Saltar por ahora';

  @override
  String get errorTimeout => 'Tiempo de espera de conexión: inténtelo de nuevo';

  @override
  String get errorInvalidKey => 'API Key no válido: verifique su configuración';

  @override
  String get errorNoInternet => 'Sin conexión a internet';

  @override
  String get errorGeneral => 'Se produjo un error. Inténtelo de nuevo.';

  @override
  String get errorQuotaExceeded =>
      'Se superó la cuota API. Espere y vuelva a intentarlo.';

  @override
  String get apiKeyScreenTitle => 'Configurar Gemini API Key';

  @override
  String get analyzeFoodWithAi => 'Analizar alimentos con IA';

  @override
  String get analyzeFoodWithAiDesc =>
      'Toma una foto → La IA calcula las calorías automáticamente\n¡Gemini API es de uso gratuito!';

  @override
  String get openGoogleAiStudio => 'Abierto Google AI Studio';

  @override
  String get step1Title => 'Abierto Google AI Studio';

  @override
  String get step1Desc =>
      'Haga clic en el botón a continuación para crear un API Key';

  @override
  String get step2Title => 'Iniciar sesión con la cuenta Google';

  @override
  String get step2Desc =>
      'Utilice su cuenta de Gmail o Google (cree una gratis si no tiene una)';

  @override
  String get step3Title => 'Haga clic en \"Crear API Key\"';

  @override
  String get step3Desc =>
      'Haga clic en el botón azul \"Crear API Key\"\nSi se le solicita que seleccione un Project → Haga clic en \"Crear clave API en un nuevo proyecto\"';

  @override
  String get step4Title => 'Copie la clave y péguela a continuación';

  @override
  String get step4Desc =>
      'Haga clic en Copiar junto a la clave creada\nLa clave se verá así: AIzaSyxxxx...';

  @override
  String get step5Title => 'Pegue API Key aquí';

  @override
  String get pasteApiKeyHint => 'Pegue el API Key copiado';

  @override
  String get saveApiKey => 'Guardar API Key';

  @override
  String get testingConnection => 'Pruebas...';

  @override
  String get deleteApiKey => 'Eliminar API Key';

  @override
  String get deleteApiKeyConfirm => '¿Eliminar API Key?';

  @override
  String get deleteApiKeyConfirmDesc =>
      'No podrás utilizar el análisis de alimentos con IA hasta que lo vuelvas a configurar';

  @override
  String get apiKeySaved => 'API Key guardado exitosamente';

  @override
  String get apiKeyDeleted => 'API Key eliminado exitosamente';

  @override
  String get pleasePasteApiKey => 'Por favor pegue API Key primero';

  @override
  String get apiKeyInvalidFormat =>
      'API Key no válido: debe comenzar con \"AIza\"';

  @override
  String get connectionSuccessMessage =>
      '✅ ¡Conectado exitosamente! Preparado para usar';

  @override
  String get connectionFailedMessage => '❌ Error de conexión';

  @override
  String get faqTitle => 'Preguntas frecuentes';

  @override
  String get faqFreeQuestion => '¿Es realmente gratis?';

  @override
  String get faqFreeAnswer =>
      '¡Sí! Gemini 2.0 Flash es gratuito para 1.500 solicitudes/día\nPara registro de alimentos (5-15 veces/día) → Gratis para siempre, no se requiere pago';

  @override
  String get faqSafeQuestion => '¿Es seguro?';

  @override
  String get faqSafeAnswer =>
      'API Key se almacena en Almacenamiento seguro solo en su dispositivo\nLa aplicación no envía la clave a nuestro servidor\nSi la clave se filtra → Eliminar y crear una nueva (no es su contraseña Google)';

  @override
  String get faqNoKeyQuestion => '¿Qué pasa si no creo una clave?';

  @override
  String get faqNoKeyAnswer =>
      '¡Aún puedes usar la aplicación! Pero:\n❌ No se puede tomar una foto → Análisis de IA\n✅ Puede registrar alimentos manualmente\n✅ Agregar rápido funciona\n✅ Ver kcal/macro resumen de trabajos';

  @override
  String get faqCreditCardQuestion => '¿Necesito una tarjeta de crédito?';

  @override
  String get faqCreditCardAnswer =>
      'No — Crea API Key gratis sin tarjeta de crédito';

  @override
  String get navDashboard => 'Panel';

  @override
  String get navMyMeals => 'Mis comidas';

  @override
  String get navCamera => 'Cámara';

  @override
  String get navAiChat => 'Chat de IA';

  @override
  String get navProfile => 'Proarchivo';

  @override
  String get appBarTodayIntake => 'La ingesta de hoy';

  @override
  String get appBarMyMeals => 'Mis comidas';

  @override
  String get appBarCamera => 'Cámara';

  @override
  String get appBarAiChat => 'Chat de IA';

  @override
  String get appBarMiro => 'MIRO';

  @override
  String get permissionRequired => 'Permiso requerido';

  @override
  String get permissionRequiredDesc => 'MIRO necesita acceso a lo siguiente:';

  @override
  String get permissionPhotos => 'Fotos — para escanear alimentos';

  @override
  String get permissionCamera => 'Cámara: para fotografiar comida.';

  @override
  String get permissionSkip => 'Saltar';

  @override
  String get permissionAllow => 'Permitir';

  @override
  String get permissionAllGranted => 'Todos los permisos concedidos';

  @override
  String permissionDenied(String denied) {
    return 'Permiso denegado: $denied';
  }

  @override
  String get openSettings => 'Abrir configuración';

  @override
  String get exitAppTitle => '¿Salir de la aplicación?';

  @override
  String get exitAppMessage => '¿Estás seguro de que quieres salir?';

  @override
  String get exit => 'Salida';

  @override
  String get healthGoalsTitle => 'Metas de salud';

  @override
  String get healthGoalsInfo =>
      'Establezca su objetivo diario de calorías, macros y presupuestos por comida.\nBloquear para calcular automáticamente: 2 macros o 3 comidas.';

  @override
  String get dailyCalorieGoal => 'Meta diaria de calorías';

  @override
  String get proteinLabel => 'Proteína';

  @override
  String get carbsLabel => 'carbohidratos';

  @override
  String get fatLabel => 'Gordo';

  @override
  String get autoBadge => 'auto';

  @override
  String kcalPerGram(int kcalPerGram, int kcal) {
    return '$kcalPerGram kcal/g • $kcal __SW0__';
  }

  @override
  String get mealCalorieBudget => 'Presupuesto de calorías de las comidas';

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
      'Bloquea 3 comidas para calcular automáticamente la 4ta.';

  @override
  String get breakfastLabel => 'Desayuno';

  @override
  String get lunchLabel => 'Almuerzo';

  @override
  String get dinnerLabel => 'Cena';

  @override
  String get snackLabel => 'Bocadillo';

  @override
  String percentOfDailyGoal(String percent) {
    return '$percent% del objetivo diario';
  }

  @override
  String get smartSuggestionRange => 'Rango de sugerencias inteligentes';

  @override
  String get smartSuggestionHow => '¿Cómo funciona la sugerencia inteligente?';

  @override
  String smartSuggestionDesc(int threshold, int min, int max) {
    return 'Le sugerimos alimentos de Mis comidas, ingredientes y comidas de ayer que se ajusten a su presupuesto por comida.\n\nEste umbral controla la flexibilidad de las sugerencias. Por ejemplo, si su presupuesto para el almuerzo es 700 kcal y el umbral es $threshold __SW0__, le sugeriremos alimentos entre $min–$max __SW0__.';
  }

  @override
  String get suggestionThreshold => 'Umbral de sugerencia';

  @override
  String suggestionThresholdDesc(int threshold) {
    return 'Permitir alimentos ± $threshold kcal del presupuesto de comidas';
  }

  @override
  String get goalsSavedSuccess => '¡Objetivos guardados exitosamente!';

  @override
  String get canOnlyLockTwoMacros =>
      'Sólo se pueden bloquear 2 macros a la vez';

  @override
  String get canOnlyLockThreeMeals =>
      'Sólo se pueden bloquear 3 comidas; el cuarto se calcula automáticamente';

  @override
  String get tabMeals => 'Comidas';

  @override
  String get tabIngredients => 'Ingredientes';

  @override
  String get searchMealsOrIngredients => 'Buscar comidas o ingredientes...';

  @override
  String get createNewMeal => 'Crear nueva comida';

  @override
  String get addIngredient => 'Agregar ingrediente';

  @override
  String get noMealsYet => 'Aún no hay comidas';

  @override
  String get noMealsYetDesc =>
      'Analice los alimentos con IA para guardarlos automáticamente\no crear uno manualmente';

  @override
  String get noIngredientsYet => 'Aún no hay ingredientes';

  @override
  String get noIngredientsYetDesc =>
      'Cuando analizas alimentos con IA\nLos ingredientes se guardarán automáticamente.';

  @override
  String mealCreated(String name) {
    return 'Creado \"$name\"';
  }

  @override
  String mealLogged(String name) {
    return 'Registrado \"$name\"';
  }

  @override
  String ingredientAmount(String unit) {
    return 'Importe ($unit)';
  }

  @override
  String ingredientLogged(String name, String amount, String unit) {
    return 'Registrado \"$name\" $amount$unit';
  }

  @override
  String get mealNotFound => 'Comida no encontrada';

  @override
  String mealUpdated(String name) {
    return 'Actualizado \"$name\"';
  }

  @override
  String get deleteMealTitle => '¿Eliminar comida?';

  @override
  String deleteMealMessage(String name) {
    return '\"$name\"';
  }

  @override
  String get deleteMealNote => 'Los ingredientes no se eliminarán.';

  @override
  String get mealDeleted => 'Comida eliminada';

  @override
  String ingredientCreated(String name) {
    return 'Creado \"$name\"';
  }

  @override
  String get ingredientNotFound => 'Ingrediente no encontrado';

  @override
  String ingredientUpdated(String name) {
    return 'Actualizado \"$name\"';
  }

  @override
  String get deleteIngredientTitle => '¿Eliminar ingrediente?';

  @override
  String deleteIngredientMessage(String name) {
    return '\"$name\"';
  }

  @override
  String get ingredientDeleted => 'Ingrediente eliminado';

  @override
  String get noIngredientsData => 'Sin datos de ingredientes';

  @override
  String ingredientDetail(String name, String amount, String unit) {
    return '$name ($amount $unit)';
  }

  @override
  String ingredientCalories(int calories) {
    return '$calories kcal';
  }

  @override
  String get useThisMeal => 'Utilice esta comida';

  @override
  String errorLoading(String error) {
    return 'Error al cargar: $error';
  }

  @override
  String scanFoundNewImages(int count, String date) {
    return 'Se encontraron $count nuevas imágenes en $date';
  }

  @override
  String scanNoNewImages(String date) {
    return 'No se encontraron nuevas imágenes en $date';
  }

  @override
  String aiAnalysisRemaining(int remaining, int total) {
    return 'Análisis de IA: $remaining/$total restantes hoy';
  }

  @override
  String get upgradeToProUnlimited => 'Actualice a Pro para uso ilimitado';

  @override
  String get upgrade => 'Mejora';

  @override
  String get confirmDelete => 'Confirmar eliminación';

  @override
  String confirmDeleteMessage(String name) {
    return '¿Quieres eliminar \"$name\"?';
  }

  @override
  String get entryDeletedSuccess => '✅ Entrada eliminada exitosamente';

  @override
  String entryDeleteError(String error) {
    return '❌ Error: $error';
  }

  @override
  String batchAnalyzeItems(int count) {
    return '$count artículos (lote)';
  }

  @override
  String analyzeCancelled(int success) {
    return 'Cancelado: analizó $success elementos correctamente';
  }

  @override
  String analyzeSuccessAll(int success) {
    return '✅ Se analizaron $success elementos con éxito';
  }

  @override
  String analyzeSuccessPartial(int success, int total, int failed) {
    return '⚠️ Elementos $success/$total analizados ($failed falló)';
  }

  @override
  String analyzeProgress(String item, int current, int total) {
    return '$item ($current/$total)';
  }

  @override
  String get pullToScanMeal => 'Tira para escanear tu comida';

  @override
  String get analyzeAll => 'Analizar todo';

  @override
  String get addFoodTitle => 'Agregar comida';

  @override
  String get foodNameRequired => 'Nombre del alimento *';

  @override
  String get foodNameHint =>
      'Escriba para buscar, p. arroz frito, ensalada de papaya';

  @override
  String get selectedFromMyMeal =>
      '✅ Seleccionado de Mi comida: datos nutricionales autocompletados';

  @override
  String foundInDatabase(String name) {
    return '✅ Encontrado en la base de datos: datos nutricionales autocompletados';
  }

  @override
  String get saveAndAnalyze => 'Guardar y analizar';

  @override
  String get notFoundInDatabase =>
      'No encontrado en la base de datos: se analizará en segundo plano';

  @override
  String get amountLabel => 'Cantidad';

  @override
  String get unitLabel => 'Unidad';

  @override
  String get nutritionAutoCalculated =>
      'Nutrición (calculada automáticamente por cantidad)';

  @override
  String get nutritionEnterZero => 'Nutrición (ingrese 0 si se desconoce)';

  @override
  String get caloriesLabel => 'Calorías (kcal)';

  @override
  String get proteinLabelShort => 'Proteína (g)';

  @override
  String get carbsLabelShort => 'Carbohidratos (g)';

  @override
  String get fatLabelShort => 'Grasa (g)';

  @override
  String get mealTypeLabel => 'Tipo de comida';

  @override
  String get pleaseEnterFoodNameFirst =>
      'Por favor ingrese primero el nombre del alimento';

  @override
  String get savedAnalyzingBackground =>
      '✅ Guardado: analizando en segundo plano';

  @override
  String get foodAdded => '✅ Alimentos agregados';

  @override
  String get suggestionSourceMyMeal => 'mi comida';

  @override
  String get suggestionSourceIngredient => 'Ingrediente';

  @override
  String get suggestionSourceDatabase => 'Base de datos';

  @override
  String get editFoodTitle => 'Editar comida';

  @override
  String get foodNameLabel => 'Nombre del alimento';

  @override
  String get changeAmountAutoUpdate =>
      'Cambiar cantidad → las calorías se actualizan automáticamente';

  @override
  String baseNutrition(int calories, String unit) {
    return 'Base: $calories kcal / 1 $unit';
  }

  @override
  String get calculatedFromIngredients =>
      'Calculado a partir de los siguientes ingredientes';

  @override
  String get ingredientsEditable => 'Ingredientes (Editables)';

  @override
  String get addIngredientButton => 'Agregar';

  @override
  String get noIngredientsAddHint =>
      'Sin ingredientes: toca \"Agregar\" para agregar nuevos';

  @override
  String get editIngredientsHint =>
      'Editar nombre/cantidad → Toque el ícono de búsqueda para buscar en la base de datos o AI';

  @override
  String get ingredientNameHint => 'p.ej. huevo de gallina';

  @override
  String get searchDbOrAi => 'Buscar base de datos/IA';

  @override
  String get amountHint => 'Cantidad';

  @override
  String get fromDatabase => 'Desde la base de datos';

  @override
  String subIngredients(int count) {
    return 'Subingredientes ($count)';
  }

  @override
  String get addSubIngredient => 'Agregar';

  @override
  String get subIngredientNameHint => 'Nombre del subingrediente';

  @override
  String get amountShort => 'cantidad';

  @override
  String get pleaseEnterSubIngredientName =>
      'Por favor ingrese primero el nombre del subingrediente';

  @override
  String foundInDatabaseSub(String name) {
    return '¡Encontré \"$name\" en la base de datos!';
  }

  @override
  String aiAnalyzedSub(String name) {
    return 'AI analizó \"$name\" (-1 Energía)';
  }

  @override
  String get couldNotAnalyzeSub => 'No se pudo analizar el subingrediente';

  @override
  String get pleaseEnterIngredientName =>
      'Por favor ingrese el nombre del ingrediente';

  @override
  String get reAnalyzeTitle => '¿Volver a analizar?';

  @override
  String reAnalyzeMessage(String name) {
    return '\"$name\" ya tiene datos nutricionales.\n\nAnalizar nuevamente consumirá 1 energía.\n\n¿Continuar?';
  }

  @override
  String get reAnalyzeButton => 'Volver a analizar (1 energía)';

  @override
  String get amountNotSpecified => 'Cantidad no especificada';

  @override
  String amountNotSpecifiedMessage(String name) {
    return 'Especifique primero el monto de \"$name\"\n¿O usar 100 g predeterminados?';
  }

  @override
  String get useDefault100g => 'Utilice 100 gramos';

  @override
  String aiAnalyzedResult(String name, int calories) {
    return 'IA: \"$name\" → $calories kcal';
  }

  @override
  String get unableToAnalyze => 'No se puede analizar';

  @override
  String get today => 'Hoy';

  @override
  String get savedSuccessfully => '✅ Guardado exitosamente';

  @override
  String get confirmFoodPhoto => 'Confirmar foto de comida';

  @override
  String get photoSavedAutomatically => 'Foto guardada automáticamente';

  @override
  String get foodNameHintExample =>
      'por ejemplo, ensalada de pollo a la parrilla';

  @override
  String get quantityLabel => 'Cantidad';

  @override
  String get quantityHint => '1';

  @override
  String get optionalFoodInfo =>
      'Ingresar el nombre y la cantidad del alimento es opcional, pero proporcionarlos mejorará la precisión del análisis de IA.';

  @override
  String get saveOnly => 'Guardar solo';

  @override
  String get pleaseEnterValidQuantity =>
      'Por favor introduce una cantidad válida';

  @override
  String analyzedResult(String name, int calories) {
    return '✅ Analizado: $name — $calories kcal';
  }

  @override
  String get couldNotAnalyzeSaved =>
      '⚠️ No se pudo analizar: guardado, use \"Analizar todo\" más tarde';

  @override
  String get savedAnalyzeLater =>
      '✅ Guardado: analiza más tarde con \"Analizar todo\"';

  @override
  String get editIngredientTitle => 'Editar ingrediente';

  @override
  String get ingredientNameRequired => 'Nombre del ingrediente *';

  @override
  String get baseAmountLabel => 'Monto base';

  @override
  String get baseAmountHint => '100';

  @override
  String nutritionPerBase(String amount, String unit) {
    return 'Nutrición por $amount $unit';
  }

  @override
  String nutritionCalculatedPerBase(String amount, String unit) {
    return 'Nutrición calculada por $amount $unit: el sistema calculará automáticamente en función de la cantidad real consumida';
  }

  @override
  String get createIngredient => 'Crear ingrediente';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get pleaseEnterIngredientNameFirst =>
      'Por favor ingrese primero el nombre del ingrediente';

  @override
  String aiAnalyzedIngredient(
      String name, String amount, String unit, int calories) {
    return 'IA: \"$name\" $amount $unit → $calories kcal';
  }

  @override
  String get unableToFindIngredient => 'No se puede encontrar este ingrediente';

  @override
  String searchFailed(String error) {
    return 'La búsqueda falló: $error';
  }

  @override
  String deleteEntriesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Entries',
      one: 'Entry',
    );
    return '¿Eliminar $count $_temp0?';
  }

  @override
  String deleteEntriesMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return '¿Eliminar $count alimento seleccionado $_temp0?';
  }

  @override
  String get deleteAll => 'Eliminar todo';

  @override
  String deletedEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return 'Eliminado $count $_temp0';
  }

  @override
  String movedEntriesToDate(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return 'Se movió $count $_temp0 a $date';
  }

  @override
  String get allSelectedAlreadyAnalyzed =>
      'Todas las entradas seleccionadas ya están analizadas';

  @override
  String analyzeCancelledSelected(int success) {
    return 'Cancelado - $success analizado';
  }

  @override
  String analyzedEntriesAll(int success) {
    String _temp0 = intl.Intl.pluralLogic(
      success,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return 'Analizado $success $_temp0';
  }

  @override
  String analyzedEntriesPartial(int success, int total, int failed) {
    return 'Analizado $success/$total ($failed falló)';
  }

  @override
  String analyzeProgressSelected(int current, int total, String item) {
    return '$current/$total $item';
  }

  @override
  String get noEntriesYet => 'Aún no hay entradas';

  @override
  String get selectAll => 'Seleccionar todo';

  @override
  String get deselectAll => 'Deseleccionar todo';

  @override
  String get moveToDate => 'Mover a la fecha';

  @override
  String get analyzeSelected => 'Analizar seleccionados';

  @override
  String get deleteTooltip => 'Borrar';

  @override
  String get move => 'Mover';

  @override
  String get deleteTooltipAction => 'Borrar';

  @override
  String switchToModeTitle(String mode) {
    return '¿Cambiar al modo $mode?';
  }

  @override
  String switchToModeMessage(String current, String newMode) {
    return 'Este elemento fue analizado como $current.\n\nVolver a analizar como $newMode utilizará 1 energía.\n\n¿Continuar?';
  }

  @override
  String analyzingAsMode(String mode) {
    return 'Analizando como $mode...';
  }

  @override
  String reAnalyzedAsMode(String mode) {
    return '✅ Reanalizado como $mode';
  }

  @override
  String get analysisFailed => '❌ El análisis falló';

  @override
  String get aiAnalysisComplete => '✅ IA analizada y guardada';

  @override
  String get changeMealType => 'Cambiar tipo de comida';

  @override
  String get moveToAnotherDate => 'Pasar a otra fecha';

  @override
  String currentDate(String date) {
    return 'Actual: $date';
  }

  @override
  String get cancelDateChange => 'Cancelar cambio de fecha';

  @override
  String get undo => 'Deshacer';

  @override
  String get chatHistory => 'Historial de chat';

  @override
  String get newChat => 'Nuevo chat';

  @override
  String get quickActions => 'Acciones Rápidas';

  @override
  String get clear => 'Claro';

  @override
  String get helloImMiro => '¡Hola! Soy Miro';

  @override
  String get tellMeWhatYouAteToday => '¡Cuéntame qué comiste hoy!';

  @override
  String get tellMeWhatYouAte => 'Dime que comiste...';

  @override
  String get clearHistoryTitle => '¿Borrar historial?';

  @override
  String get clearHistoryMessage =>
      'Todos los mensajes de esta sesión serán eliminados.';

  @override
  String get chatHistoryTitle => 'Historial de chat';

  @override
  String get newLabel => 'Nuevo';

  @override
  String get noChatHistoryYet => 'Aún no hay historial de chat';

  @override
  String get active => 'Activo';

  @override
  String get deleteChatTitle => '¿Eliminar chat?';

  @override
  String deleteChatMessage(String title) {
    return '¿Eliminar \"$title\"?';
  }

  @override
  String weeklySummaryTitle(String start, String end) {
    return '📊 Resumen semanal ($start - $end)';
  }

  @override
  String daySummary(String day, String calories, String emoji, String diff) {
    return '📅 $day: $calories kcal $emoji ($diff)';
  }

  @override
  String overTarget(String amount) {
    return '$amount sobre el objetivo';
  }

  @override
  String underTarget(String amount) {
    return '$amount por debajo del objetivo';
  }

  @override
  String get noFoodLoggedThisWeek =>
      'Aún no se han registrado alimentos esta semana.';

  @override
  String averageKcalPerDay(String average) {
    return '🔥 Promedio: $average kcal/día';
  }

  @override
  String targetKcalPerDay(String target) {
    return '🎯 Objetivo: $target kcal/día';
  }

  @override
  String resultOverTarget(String amount) {
    return '📈 Resultado: $amount kcal sobre el objetivo';
  }

  @override
  String resultUnderTarget(String amount) {
    return '📈 Resultado: $amount kcal por debajo del objetivo - ¡Excelente trabajo! 💪';
  }

  @override
  String failedToLoadWeeklySummary(String error) {
    return '❌ No se pudo cargar el resumen semanal: $error';
  }

  @override
  String monthlySummaryTitle(String month, int year) {
    return '📊 Resumen mensual ($month $year)';
  }

  @override
  String totalDays(int days) {
    return '📅 Días totales: $days';
  }

  @override
  String totalConsumed(String calories) {
    return '🔥 Total consumido: $calories kcal';
  }

  @override
  String targetTotal(String target) {
    return '🎯 Total objetivo: $target kcal';
  }

  @override
  String averageKcalPerDayShort(String average) {
    return '📈 Promedio: $average kcal/día';
  }

  @override
  String overTargetThisMonth(String amount) {
    return '⚠️ $amount kcal superó el objetivo este mes';
  }

  @override
  String underTargetThisMonth(String amount) {
    return '✅ $amount kcal por debajo del objetivo - ¡Excelente! 💪';
  }

  @override
  String failedToLoadMonthlySummary(String error) {
    return '❌ No se pudo cargar el resumen mensual: $error';
  }

  @override
  String get localAiHelpTitle => '🤖 Ayuda local de IA';

  @override
  String get localAiHelpFormat => 'Formato: [alimento] [cantidad] [unidad]';

  @override
  String get localAiHelpExamples =>
      'Ejemplos:\n• pollo 100 g y arroz 200 g\n• pizza 2 porciones\n• manzana 1 pieza, plátano 1 pieza';

  @override
  String get localAiHelpNote =>
      'Nota: solo inglés, análisis básico\n¡Cambie a Miro AI para obtener mejores resultados!';

  @override
  String hiNoFoodLogged(String target) {
    return '🤖 ¡Hola! Aún no se ha registrado ningún alimento hoy.\n   Objetivo: $target kcal: ¿Listo para comenzar a iniciar sesión? 🍽️';
  }

  @override
  String hiKcalLeft(String remaining) {
    return '🤖 ¡Hola! Te queda $remaining kcal para hoy.\n   ¿Listo para registrar tus comidas? 😊';
  }

  @override
  String hiOverTarget(String calories, String over) {
    return '🤖 ¡Hola! Has consumido $calories kcal hoy.\n   $over __SW0__ sobre el objetivo: ¡sigamos rastreando! 💪';
  }

  @override
  String get hiReadyToLog => '🤖 ¡Hola! ¿Listo para registrar tus comidas? 😊';

  @override
  String get notEnoughEnergy => 'No hay suficiente energía';

  @override
  String get thinkingMealIdeas =>
      '🤖 Pensando en grandes ideas de comidas para ti...';

  @override
  String get recentMeals => 'Comidas recientes:';

  @override
  String get noRecentFood => 'No se ha registrado ningún alimento reciente.';

  @override
  String remainingCaloriesToday(String remaining) {
    return '. Calorías restantes hoy: $remaining kcal.';
  }

  @override
  String failedToGetMenuSuggestions(String error) {
    return '❌ No se pudieron obtener sugerencias de menú: $error';
  }

  @override
  String get mealSuggestionsTitle =>
      '🤖 Según tu registro de alimentos, aquí tienes 3 sugerencias de comidas:';

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
  String get pickOneAndLog => '¡Elige uno y lo registraré por ti! 😊';

  @override
  String energyCost(int cost) {
    return '⚡ -$cost Energía';
  }

  @override
  String get giveMeTipsForHealthyEating =>
      'Dame consejos para una alimentación saludable.';

  @override
  String get howManyCaloriesToday => '¿Cuántas calorías hoy?';

  @override
  String get menuLabel => 'Menú';

  @override
  String get weeklyLabel => 'Semanalmente';

  @override
  String get monthlyLabel => 'Mensual';

  @override
  String get tipsLabel => 'Consejos';

  @override
  String get summaryLabel => 'Resumen';

  @override
  String get helpLabel => 'Ayuda';

  @override
  String get onboardingWelcomeSubtitle =>
      'Realice un seguimiento de las calorías sin esfuerzo\ncon análisis impulsado por IA';

  @override
  String get onboardingSnap => 'Quebrar';

  @override
  String get onboardingSnapDesc => 'La IA analiza al instante';

  @override
  String get onboardingType => 'Tipo';

  @override
  String get onboardingTypeDesc => 'Iniciar sesión en segundos';

  @override
  String get onboardingEdit => 'Editar';

  @override
  String get onboardingEditDesc => 'Precisión de ajuste fino';

  @override
  String get onboardingNext => 'Siguiente →';

  @override
  String get onboardingDisclaimer =>
      'Datos estimados por IA. No consejo médico.';

  @override
  String get onboardingQuickSetup => 'Configuración rápida';

  @override
  String get onboardingHelpAiUnderstand =>
      'Ayude a la IA a comprender mejor su comida';

  @override
  String get onboardingYourTypicalCuisine => 'Su cocina típica:';

  @override
  String get onboardingDailyCalorieGoal =>
      'Meta diaria de calorías (opcional):';

  @override
  String get onboardingKcalPerDay => 'kcal/día';

  @override
  String get onboardingCalorieGoalHint => '2000';

  @override
  String get onboardingCanChangeAnytime =>
      'Puedes cambiar esto en cualquier momento en la configuración del archivo Pro';

  @override
  String get onboardingYoureAllSet => '¡Ya estás listo!';

  @override
  String get onboardingStartTracking =>
      'Comience a realizar un seguimiento de sus comidas hoy.\nToma una foto o escribe lo que comiste.';

  @override
  String get onboardingWelcomeGift => 'Regalo de bienvenida';

  @override
  String get onboardingFreeEnergy => '10 Energía GRATIS';

  @override
  String get onboardingFreeEnergyDesc => '= 10 análisis de IA para comenzar';

  @override
  String get onboardingEnergyCost =>
      'Cada análisis cuesta 1 Energía\n¡Cuanto más uses, más ganarás!';

  @override
  String get onboardingStartTrackingButton => '¡Comience a rastrear! →';

  @override
  String get onboardingNoCreditCard =>
      'Sin tarjeta de crédito • Sin cargos ocultos';

  @override
  String get cameraTakePhotoOfFood => 'Toma una foto de tu comida.';

  @override
  String get cameraFailedToInitialize => 'No se pudo inicializar la cámara';

  @override
  String get cameraFailedToCapture => 'No se pudo capturar la foto';

  @override
  String get cameraFailedToPickFromGallery =>
      'No se pudo seleccionar la imagen de la galería';

  @override
  String get cameraProcessing => 'Procesando...';

  @override
  String get referralInviteFriends => 'invitar amigos';

  @override
  String get referralYourReferralCode => 'Su código de referencia';

  @override
  String get referralLoading => 'Cargando...';

  @override
  String get referralCopy => 'Copiar';

  @override
  String get referralShareCodeDescription =>
      '¡Comparte este código con amigos! Cuando usan la IA 3 veces, ¡ambos obtienen recompensas!';

  @override
  String get referralEnterReferralCode => 'Ingrese el código de referencia';

  @override
  String get referralCodeHint => 'MIRO-XXXX-XXXX-XXXX';

  @override
  String get referralSubmitCode => 'Enviar código';

  @override
  String get referralPleaseEnterCode =>
      'Por favor ingrese un código de referencia';

  @override
  String get referralCodeAccepted => '¡Código de referencia aceptado!';

  @override
  String get referralCodeCopied =>
      '¡Código de referencia copiado al portapapeles!';

  @override
  String referralEnergyBonus(int energy) {
    return '+$energy ¡Energía!';
  }

  @override
  String get referralHowItWorks => 'Cómo funciona';

  @override
  String get referralStep1Title => 'Comparte tu código de referencia';

  @override
  String get referralStep1Description =>
      'Copie y comparta su ID MiRO con amigos';

  @override
  String get referralStep2Title => 'Amigo ingresa tu código';

  @override
  String get referralStep2Description =>
      'Obtienen +20 de energía inmediatamente.';

  @override
  String get referralStep3Title => 'Amigo usa IA 3 veces';

  @override
  String get referralStep3Description => 'Cuando completen 3 análisis de IA';

  @override
  String get referralStep4Title => '¡Serás recompensado!';

  @override
  String get referralStep4Description => '¡Recibes +5 de energía!';

  @override
  String get tierBenefitsTitle => 'Beneficios de nivel';

  @override
  String get tierBenefitsUnlockRewards =>
      'Desbloquear recompensas\ncon rachas diarias';

  @override
  String get tierBenefitsKeepStreakDescription =>
      '¡Mantén viva tu racha para desbloquear niveles más altos y obtener increíbles beneficios!';

  @override
  String get tierBenefitsHowItWorks => 'Cómo funciona';

  @override
  String get tierBenefitsDailyEnergyReward => 'Recompensa de energía diaria';

  @override
  String get tierBenefitsDailyEnergyDescription =>
      'Utilice la IA al menos una vez al día para ganar energía adicional. Niveles más altos = ¡más energía diaria!';

  @override
  String get tierBenefitsPurchaseBonus => 'Bono de compra';

  @override
  String get tierBenefitsPurchaseBonusDescription =>
      'Los niveles Oro y Diamante obtienen energía adicional en cada compra (¡entre un 10% y un 20% más!)';

  @override
  String get tierBenefitsGracePeriod => 'Período de gracia';

  @override
  String get tierBenefitsGracePeriodDescription =>
      'Pierde un día sin perder tu racha. ¡Los niveles Silver+ obtienen protección!';

  @override
  String get tierBenefitsAllTiers => 'Todos los niveles';

  @override
  String get tierBenefitsNew => 'NUEVO';

  @override
  String get tierBenefitsPopular => 'POPULAR';

  @override
  String get tierBenefitsBest => 'MEJOR';

  @override
  String get tierBenefitsDailyCheckIn => 'Registro diario';

  @override
  String get tierBenefitsProTips => 'Pro Consejos';

  @override
  String get tierBenefitsTip1 =>
      'Utilice la IA a diario para ganar energía gratis y aumentar su racha';

  @override
  String get tierBenefitsTip2 =>
      'El nivel Diamante gana +4 de energía por día, ¡eso es 120 por mes!';

  @override
  String get tierBenefitsTip3 =>
      '¡El bono de compra aplica a TODOS los paquetes de energía!';

  @override
  String get tierBenefitsTip4 =>
      'El período de gracia protege tu racha si pierdes un día';

  @override
  String get subscriptionEnergyPass => 'Pase de energía';

  @override
  String get subscriptionInAppPurchasesNotAvailable =>
      'Compras dentro de la aplicación no disponibles';

  @override
  String get subscriptionFailedToInitiatePurchase =>
      'No se pudo iniciar la compra';

  @override
  String subscriptionError(String error) {
    return 'Error: $error';
  }

  @override
  String get subscriptionFailedToLoad => 'No se pudo cargar la suscripción';

  @override
  String get subscriptionUnknownError => 'Error desconocido';

  @override
  String get subscriptionRetry => 'Rever';

  @override
  String get subscriptionEnergyPassActive => 'Pase de energía activo';

  @override
  String get subscriptionUnlimitedAccess => 'Tienes acceso ilimitado';

  @override
  String get subscriptionStatus => 'Estado';

  @override
  String get subscriptionRenews => 'Renueva';

  @override
  String get subscriptionPrice => 'Precio';

  @override
  String get subscriptionYourBenefits => 'Tus beneficios';

  @override
  String get subscriptionManageSubscription => 'Administrar suscripción';

  @override
  String get subscriptionNoProductAvailable =>
      'No hay producto de suscripción disponible';

  @override
  String get subscriptionWhatYouGet => 'Lo que obtienes';

  @override
  String get subscriptionPerMonth => 'por mes';

  @override
  String get subscriptionSubscribeNow => 'Suscríbete ahora';

  @override
  String get subscriptionCancelAnytime => 'Cancelar en cualquier momento';

  @override
  String get subscriptionAutoRenewTerms =>
      'Su suscripción se renovará automáticamente. Puedes cancelar en cualquier momento desde Google Play.';

  @override
  String get disclaimerHealthDisclaimer =>
      'Descargo de responsabilidad de salud';

  @override
  String get disclaimerImportantReminders => 'Recordatorios importantes:';

  @override
  String get disclaimerBullet1 =>
      'Todos los datos nutricionales son estimados.';

  @override
  String get disclaimerBullet2 => 'El análisis de IA puede contener errores';

  @override
  String get disclaimerBullet3 => 'No sustituye al asesoramiento profesional.';

  @override
  String get disclaimerBullet4 =>
      'Consulte a los proveedores de atención médica para obtener orientación médica.';

  @override
  String get disclaimerBullet5 => 'Úselo bajo su propia discreción y riesgo.';

  @override
  String get disclaimerIUnderstand => 'Entiendo';

  @override
  String get privacyPolicyTitle => 'política de privacidad';

  @override
  String get privacyPolicySubtitle =>
      'MiRO — Oráculo de mi registro de admisión';

  @override
  String get privacyPolicyHeaderNote =>
      'Los datos de sus alimentos permanecen en su dispositivo. Balance de energía sincronizado de forma segura a través de Firebase.';

  @override
  String get privacyPolicySectionInformationWeCollect =>
      'Información que recopilamos';

  @override
  String get privacyPolicySectionDataStorage => 'Almacenamiento de datos';

  @override
  String get privacyPolicySectionDataTransmission =>
      'Transmisión de datos a terceros';

  @override
  String get privacyPolicySectionRequiredPermissions => 'Permisos requeridos';

  @override
  String get privacyPolicySectionSecurity => 'Seguridad';

  @override
  String get privacyPolicySectionUserRights => 'Derechos de usuario';

  @override
  String get privacyPolicySectionDataRetention => 'Retención de datos';

  @override
  String get privacyPolicySectionChildrenPrivacy => 'Privacidad de los niños';

  @override
  String get privacyPolicySectionChangesToPolicy => 'Cambios a esta política';

  @override
  String get privacyPolicySectionDataCollectionConsent =>
      'Consentimiento para la recopilación de datos';

  @override
  String get privacyPolicySectionPDPACompliance =>
      'Cumplimiento de PDPA (Ley de protección de datos personales Pro de Tailandia)';

  @override
  String get privacyPolicySectionContactUs => 'Contáctenos';

  @override
  String get privacyPolicyEffectiveDate =>
      'Fecha de vigencia: 18 de febrero de 2026\nÚltima actualización: 18 de febrero de 2026';

  @override
  String get termsOfServiceTitle => 'Términos de servicio';

  @override
  String get termsSubtitle => 'MiRO — Oráculo de mi registro de admisión';

  @override
  String get termsSectionAcceptanceOfTerms => 'Aceptación de términos';

  @override
  String get termsSectionServiceDescription => 'Descripción del servicio';

  @override
  String get termsSectionDisclaimerOfWarranties => 'Renuncia de garantías';

  @override
  String get termsSectionEnergySystemTerms => 'Términos del sistema de energía';

  @override
  String get termsSectionUserDataAndResponsibilities =>
      'Datos y responsabilidades del usuario';

  @override
  String get termsSectionBackupTransfer => 'Copia de seguridad y transferencia';

  @override
  String get termsSectionInAppPurchases => 'Compras dentro de la aplicación';

  @override
  String get termsSectionProhibitedUses => 'ProUsos prohibidos';

  @override
  String get termsSectionIntellectualProperty => 'Propiedad intelectual Pro';

  @override
  String get termsSectionLimitationOfLiability =>
      'Limitación de responsabilidad';

  @override
  String get termsSectionServiceTermination => 'Terminación del servicio';

  @override
  String get termsSectionChangesToTerms => 'Cambios a los términos';

  @override
  String get termsSectionGoverningLaw => 'Ley aplicable';

  @override
  String get termsSectionContactUs => 'Contáctenos';

  @override
  String get termsAcknowledgment =>
      'Al utilizar MiRO, usted reconoce que ha leído, comprendido y aceptado estos Términos de servicio.';

  @override
  String get termsLastUpdated => 'Última actualización: 15 de febrero de 2026';

  @override
  String get profileAndSettings => 'Proarchivo y configuración';

  @override
  String errorOccurred(String error) {
    return 'Error: $error';
  }

  @override
  String get healthGoalsSection => 'Metas de salud';

  @override
  String get dailyGoals => 'Metas Diarias';

  @override
  String get chatAiModeSection => 'Modo IA de chat';

  @override
  String get selectAiPowersChat => 'Selecciona qué IA impulsa tu chat';

  @override
  String get miroAi => 'Miro IA';

  @override
  String get miroAiSubtitle =>
      'Desarrollado por Gemini • Varios idiomas • Alta precisión';

  @override
  String get localAi => 'IA local';

  @override
  String get localAiSubtitle =>
      'En el dispositivo • Solo inglés • Precisión básica';

  @override
  String get free => 'Gratis';

  @override
  String get cuisinePreferenceSection => 'Preferencia de cocina';

  @override
  String get preferredCuisine => 'Cocina preferida';

  @override
  String get selectYourCuisine => 'Selecciona tu cocina';

  @override
  String get photoScanSection => 'Escaneo de fotos';

  @override
  String get languageSection => 'Idioma';

  @override
  String get languageTitle => 'Idioma / ภาษา';

  @override
  String get selectLanguage => 'Seleccionar idioma / เลือกภาษา';

  @override
  String get systemDefault => 'Valor predeterminado del sistema';

  @override
  String get systemDefaultSublabel => 'ตามระบบ';

  @override
  String get english => 'Inglés';

  @override
  String get englishSublabel => 'อังกฤษ';

  @override
  String get thai => 'ไทย (tailandés)';

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
  String get closeBilingual => 'Cerrar / ปิด';

  @override
  String languageChangedTo(String language) {
    return 'Idioma cambiado a $language';
  }

  @override
  String get accountSection => 'Cuenta';

  @override
  String get miroId => 'MiRO identificación';

  @override
  String get miroIdCopied => 'MiRO ¡ID copiada!';

  @override
  String get inviteFriends => 'invitar amigos';

  @override
  String get inviteFriendsSubtitle =>
      '¡Comparte tu código de referencia y gana recompensas!';

  @override
  String get unlimitedAiDoubleRewards => 'IA ilimitada + recompensas dobles';

  @override
  String get plan => 'Plan';

  @override
  String get monthly => 'Mensual';

  @override
  String get started => 'Comenzó';

  @override
  String get renews => 'Renueva';

  @override
  String get expires => 'Vence';

  @override
  String get autoRenew => 'Renovación automática';

  @override
  String get on => 'En';

  @override
  String get off => 'Apagado';

  @override
  String get tapToManageSubscription => 'Toca para administrar la suscripción';

  @override
  String get dataSection => 'Datos';

  @override
  String get backupData => 'Datos de copia de seguridad';

  @override
  String get backupDataSubtitle =>
      'Energía + Historial de alimentos → guardar como archivo';

  @override
  String get restoreFromBackup => 'Restaurar desde copia de seguridad';

  @override
  String get restoreFromBackupSubtitle =>
      'Importar datos desde un archivo de copia de seguridad';

  @override
  String get clearAllDataTitle => '¿Borrar todos los datos?';

  @override
  String get clearAllDataContent =>
      'Todos los datos serán eliminados:\n• Entradas de alimentos\n• Mis comidas\n• Ingredientes\n• Metas\n• Información personal\n\n¡Esto no se puede deshacer!';

  @override
  String get allDataClearedSuccess =>
      'Todos los datos se borraron exitosamente';

  @override
  String get aboutSection => 'Acerca de';

  @override
  String get version => 'Versión';

  @override
  String get healthDisclaimer => 'Descargo de responsabilidad de salud';

  @override
  String get importantLegalInformation => 'Información legal importante';

  @override
  String get showTutorialAgain => 'Mostrar tutorial nuevamente';

  @override
  String get viewFeatureTour => 'Ver recorrido de funciones';

  @override
  String get showTutorialDialogTitle => 'Mostrar tutorial';

  @override
  String get showTutorialDialogContent =>
      'Esto mostrará el recorrido principal que destaca:\n\n• Sistema de energía\n• Escaneo de fotografías con función de extracción y actualización\n• Chatea con Miro AI\n\nVolverá a la pantalla de inicio.';

  @override
  String get showTutorialButton => 'Mostrar tutorial';

  @override
  String get tutorialResetMessage =>
      '¡Restablecimiento del tutorial! Vaya a la pantalla de inicio para verlo.';

  @override
  String get foodAnalysisTutorial => 'Tutorial de análisis de alimentos';

  @override
  String get foodAnalysisTutorialSubtitle =>
      'Aprenda a utilizar las funciones de análisis de alimentos';

  @override
  String get backupCreated => 'Copia de seguridad creada!';

  @override
  String get backupCreatedContent =>
      'Su archivo de respaldo se ha creado exitosamente.';

  @override
  String get backupChooseDestination =>
      '¿Dónde le gustaría guardar su copia de seguridad?';

  @override
  String get backupSaveToDevice => 'Guardar en dispositivo';

  @override
  String get backupSaveToDeviceDesc =>
      'Guardar en una carpeta que elijas en este dispositivo';

  @override
  String get backupShareToOther => 'Compartir con otro dispositivo';

  @override
  String get backupShareToOtherDesc =>
      'Enviar por línea, correo electrónico, unidad Google, etc.';

  @override
  String get backupSavedSuccess => 'Copia de seguridad guardada!';

  @override
  String get backupSavedSuccessContent =>
      'Su archivo de copia de seguridad se ha guardado en la ubicación elegida.';

  @override
  String get important => 'Importante:';

  @override
  String get backupImportantNotes =>
      '• Guarde este archivo en un lugar seguro (Google Drive, etc.)\n• Las fotos NO están incluidas en la copia de seguridad\n• La clave de transferencia vence en 30 días\n• La clave solo se puede usar una vez';

  @override
  String get restoreBackup => '¿Restaurar copia de seguridad?';

  @override
  String get backupFrom => 'Copia de seguridad desde:';

  @override
  String get date => 'Fecha:';

  @override
  String get energy => 'Energía:';

  @override
  String get foodEntries => 'Entradas de comida:';

  @override
  String get restoreImportant => 'Importante';

  @override
  String restoreImportantNotes(String energy) {
    return '• La energía actual en este dispositivo será SUSTITUIDA con energía de respaldo ($energy)\n• Las entradas de alimentos se fusionarán (no se reemplazarán)\n• Las fotos NO están incluidas en la copia de seguridad\n• Se utilizará la clave de transferencia (no se puede reutilizar)';
  }

  @override
  String get restore => 'Restaurar';

  @override
  String get restoreComplete => '¡Restauración completa!';

  @override
  String get restoreCompleteContent =>
      'Sus datos han sido restaurados exitosamente.';

  @override
  String get newEnergyBalance => 'Nuevo equilibrio energético:';

  @override
  String get foodEntriesImported => 'Entradas de alimentos importados:';

  @override
  String get myMealsImported => 'Mis comidas importadas:';

  @override
  String get appWillRefresh =>
      'Su aplicación se actualizará para mostrar los datos restaurados.';

  @override
  String get backupFailed => 'Error de copia de seguridad';

  @override
  String get invalidBackupFile => 'Archivo de copia de seguridad no válido';

  @override
  String get restoreFailed => 'Restauración fallida';

  @override
  String get analyticsDataCollection => 'Recopilación de datos analíticos';

  @override
  String get analyticsEnabled =>
      'Análisis habilitados - ขอบคุณที่ช่วยปรับปรุงแอป';

  @override
  String get analyticsDisabled =>
      'Análisis deshabilitados - ไม่เก็บข้อมูลการใช้งาน';

  @override
  String get enabled => 'Activado';

  @override
  String get enabledSubtitle => 'Habilitado - ช่วยปรับปรุงประสบการณ์ใช้งาน';

  @override
  String get disabled => 'Desactivado';

  @override
  String get disabledSubtitle => 'Discapacitado - ไม่เก็บข้อมูลการใช้งาน';

  @override
  String get imagesPerDay => 'Imágenes por día';

  @override
  String scanUpToImagesPerDay(String limit) {
    return 'Escanee hasta $limit imágenes por día';
  }

  @override
  String get reset => 'Reiniciar';

  @override
  String get resetScanHistory => 'Restablecer el historial de escaneo';

  @override
  String get resetScanHistorySubtitle =>
      'Elimine todas las entradas escaneadas y vuelva a escanear';

  @override
  String get imagesPerDayDialog => 'Imágenes por día';

  @override
  String get maxImagesPerDayDescription =>
      'Máximo de imágenes para escanear por día\nEscanea solo la fecha seleccionada';

  @override
  String scanLimitSetTo(String limit) {
    return 'Límite de escaneo establecido en $limit imágenes por día';
  }

  @override
  String get resetScanHistoryDialog => '¿Restablecer el historial de escaneo?';

  @override
  String get resetScanHistoryContent =>
      'Se eliminarán todas las entradas de alimentos escaneadas en la galería.\nDespliega cualquier fecha para volver a escanear las imágenes.';

  @override
  String resetComplete(String count) {
    return 'Restablecimiento completo: $count entradas eliminadas. Tire hacia abajo para volver a escanear.';
  }

  @override
  String questBarStreak(int days) {
    return 'Racha $days día';
  }

  @override
  String questBarDaysToNextTier(int days, String tier) {
    return '$days días → $tier';
  }

  @override
  String get questBarMaxTier => '¡Nivel máximo! 💎';

  @override
  String get questBarOfferDismissed => 'Oferta oculta';

  @override
  String get questBarViewOffer => 'Ver oferta';

  @override
  String get questBarNoOffersNow => '• No hay ofertas en este momento';

  @override
  String get questBarWeeklyChallenges => '🎯 Desafíos semanales';

  @override
  String get questBarMilestones => '🏆 Hitos';

  @override
  String get questBarInviteFriends => '👥 Invita amigos y obtén 20E';

  @override
  String questBarTimeRemaining(String time) {
    return '⏰ Tiempo restante $time';
  }

  @override
  String questBarClaimDailyEnergy(int energy) {
    return '+${energy}E';
  }

  @override
  String questBarShareReferralError(String error) {
    return 'Error al compartir: $error';
  }

  @override
  String tierCelebrationTitle(String tier) {
    return '$tier Celebración 🎉';
  }

  @override
  String tierCelebrationDay(int day) {
    return 'Día $day';
  }

  @override
  String get tierCelebrationExpired => 'Venció';

  @override
  String get tierCelebrationComplete => '¡Completo!';

  @override
  String questBarWatchAd(int energy) {
    return 'Ver anuncio +$energy⚡';
  }

  @override
  String questBarAdRemaining(int remaining, int total) {
    return '$remaining/$total restantes hoy';
  }

  @override
  String questBarAdSuccess(int energy) {
    return '¡Anuncio visto! +$energy Energía entrante...';
  }

  @override
  String get questBarAdNotReady =>
      'El anuncio no está listo, inténtalo de nuevo.';

  @override
  String get questBarDailyChallenge => 'Desafío diario';

  @override
  String get questBarUseAi => 'Usar energía';

  @override
  String get questBarResetsMonday => 'Se reinicia todos los lunes';

  @override
  String get questBarClaimed => '¡Reclamado!';

  @override
  String get questBarHideOffer => 'Esconder';

  @override
  String get questBarViewDetails => 'Vista';

  @override
  String questBarShareText(String link) {
    return '¡Prueba MiRO! Análisis de alimentos impulsado por IA 🍔\n¡Usa este enlace y ambos obtendremos +20 de energía gratis!\n\n$link';
  }

  @override
  String get questBarShareSubject => 'Pruebe MiRO';

  @override
  String get claimButtonTitle => 'Reclama energía diaria';

  @override
  String claimButtonReceived(String energy) {
    return '¡Recibido +${energy}E!';
  }

  @override
  String get claimButtonAlreadyClaimed => 'Ya reclamado hoy';

  @override
  String claimButtonError(String error) {
    return 'Error: $error';
  }

  @override
  String get seasonalQuestLimitedTime => 'TIEMPO LIMITADO';

  @override
  String seasonalQuestDaysLeft(int days) {
    return 'Quedan $days días';
  }

  @override
  String seasonalQuestRewardDaily(int reward) {
    return '+${reward}E / día';
  }

  @override
  String seasonalQuestRewardOnce(int reward) {
    return '+${reward}E una vez';
  }

  @override
  String get seasonalQuestClaimed => '¡Reclamado!';

  @override
  String get seasonalQuestClaimedToday => 'Reclamado hoy';

  @override
  String get errorFailed => 'Fallido';

  @override
  String get errorFailedToClaim => 'No se pudo reclamar';

  @override
  String errorGeneric(String error) {
    return 'Error: $error';
  }

  @override
  String get milestoneNoMilestonesToClaim => 'Aún no hay hitos que reclamar';

  @override
  String milestoneClaimedEnergy(int energy) {
    return '🎁 ¡Reclamó +$energy Energía!';
  }

  @override
  String get milestoneTitle => 'Hitos';

  @override
  String milestoneUseEnergyComplete(int threshold) {
    return 'Usar energía $threshold';
  }

  @override
  String milestoneNext(int threshold) {
    return 'Siguiente: ${threshold}E';
  }

  @override
  String get milestoneAllComplete => '¡Todos los hitos completados!';

  @override
  String get noEnergyTitle => 'Sin energía';

  @override
  String get noEnergyContent =>
      'Necesitas 1 Energía para analizar alimentos con IA';

  @override
  String get noEnergyTip =>
      'Aún puedes registrar alimentos manualmente (sin IA) de forma gratuita';

  @override
  String get noEnergyLater => 'Más tarde';

  @override
  String noEnergyWatchAd(int remaining) {
    return 'Ver anuncio ($remaining/3)';
  }

  @override
  String get noEnergyBuyEnergy => 'Comprar Energía';

  @override
  String get tierBronze => 'Bronce';

  @override
  String get tierSilver => 'Plata';

  @override
  String get tierGold => 'Oro';

  @override
  String get tierDiamond => 'Diamante';

  @override
  String get tierStarter => 'Motor de arranque';

  @override
  String get tierUpCongratulations => '🎉 ¡Felicidades!';

  @override
  String tierUpYouReached(String tier) {
    return '¡Llegaste a $tier!';
  }

  @override
  String get tierUpMotivation =>
      'Realiza un seguimiento de las calorías como un profesional\n¡El cuerpo de tus sueños está cada vez más cerca!';

  @override
  String tierUpReward(int reward) {
    return '+${reward}E ¡Recompensa!';
  }

  @override
  String get referralAllLevelsClaimed => '¡Todos los niveles reclamados!';

  @override
  String referralLevel(int level, String subtitle) {
    return 'Nivel $level: $subtitle';
  }

  @override
  String referralProgress(int current, int target, int level, int total) {
    return '[$current/$target] (Nivel $level/$total)';
  }

  @override
  String referralClaimedLevel(int level, int reward) {
    return '🎁 Nivel reclamado $level: +$reward ¡Energía!';
  }

  @override
  String get challengeUseAi10 => 'Usar energía 10';

  @override
  String get specifyIngredients => 'Especificar ingredientes conocidos';

  @override
  String get specifyIngredientsOptional =>
      'Especificar ingredientes conocidos (opcional)';

  @override
  String get specifyIngredientsHint =>
      'Ingrese los ingredientes que conoce y la IA descubrirá condimentos, aceites y salsas ocultos para usted.';

  @override
  String get sendToAi => 'Enviar a IA';

  @override
  String get reanalyzeWithIngredients =>
      'Agregue ingredientes y vuelva a analizar';

  @override
  String get reanalyzeButton => 'Volver a analizar (1 energía)';

  @override
  String get ingredientsSaved => 'Ingredientes guardados';

  @override
  String get pleaseAddAtLeastOneIngredient =>
      'Por favor agregue al menos 1 ingrediente';

  @override
  String get hiddenIngredientsDiscovered =>
      'Ingredientes ocultos descubiertos por la IA';

  @override
  String get retroScanTitle => '¿Escanear fotos recientes?';

  @override
  String get retroScanDescription =>
      'Podemos escanear sus fotos de los últimos 7 días para encontrar automáticamente fotos de alimentos y agregarlas a su diario.';

  @override
  String get retroScanNote =>
      'Solo se detectan fotografías de alimentos; las demás fotografías se ignoran. No salen fotos de tu dispositivo.';

  @override
  String get retroScanStart => 'Escanear mis fotos';

  @override
  String get retroScanSkip => 'Saltar por ahora';

  @override
  String get retroScanInProgress => 'Exploración...';

  @override
  String get retroScanTagline =>
      'MiRO está transformando tu\nfotos de alimentos en datos de salud.';

  @override
  String get retroScanFetchingPhotos => 'Obteniendo fotos recientes...';

  @override
  String get retroScanAnalyzing => 'Detectando fotos de comida...';

  @override
  String retroScanPhotosFound(int count) {
    return '$count fotos encontradas en los últimos 7 días';
  }

  @override
  String get retroScanCompleteTitle => '¡Escaneo completo!';

  @override
  String retroScanCompleteDesc(int count) {
    return '¡Encontré $count fotos de comida! Se agregaron a su línea de tiempo, listos para el análisis de IA.';
  }

  @override
  String get retroScanNoResultsTitle => 'No se encontraron fotos de comida';

  @override
  String get retroScanNoResultsDesc =>
      'No se detectaron fotos de comida en los últimos 7 días. ¡Intenta tomar una foto de tu próxima comida!';

  @override
  String get retroScanAnalyzeHint =>
      'Toque \"Analizar todo\" en su línea de tiempo para obtener un análisis nutricional de IA para estas entradas.';

  @override
  String get retroScanDone => '¡Entiendo!';

  @override
  String get welcomeEndTitle => '¡Bienvenido a MiRO!';

  @override
  String get welcomeEndMessage => 'MiRO está a su servicio.';

  @override
  String get welcomeEndJourney => '¡¡Buen viaje juntos!!';

  @override
  String get welcomeEndStart => '¡Empecemos!';

  @override
  String greetingCalorieSummary(
      int remaining, int protein, int carbs, int fat) {
    return '¡Hola! ¿Cómo puedo ayudarte hoy? Todavía te queda $remaining kcal. Hasta ahora: Proteína ${protein}g, carbohidratos ${carbs}g, grasas ${fat}g. Dígame qué comió; enumere todo por comida y lo registraré todo por usted. ¡Más detalles más precisos!';
  }

  @override
  String greetingCuisineTip(String cuisine) {
    return 'Su cocina preferida está configurada en $cuisine. ¡Puedes cambiarlo en Configuración en cualquier momento!';
  }

  @override
  String greetingEnergyTip(int balance) {
    return 'Tienes $balance Energía disponible. ¡No olvides reclamar tu recompensa de racha diaria en la insignia de Energía!';
  }

  @override
  String get greetingRenamePhotoTip =>
      'Consejo: ¡Puedes cambiar el nombre de las fotos de alimentos para ayudar a MiRO a analizarlas con mayor precisión!';

  @override
  String get greetingAddIngredientsTip =>
      'Consejo: Puede agregar ingredientes de los que esté seguro antes de enviarlos a MiRO para su análisis. ¡Me ocuparé de todos los pequeños detalles aburridos por ti!';

  @override
  String greetingBackupReminder(int days) {
    return '¡Hola jefe! No has realizado una copia de seguridad de tus datos durante $days días. Recomiendo hacer una copia de seguridad en Configuración: sus datos se almacenan localmente y no puedo recuperarlos si sucede algo.';
  }

  @override
  String get greetingFallback =>
      '¡Hola! ¿Cómo puedo ayudarte hoy? ¡Cuéntame qué comiste!';

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
}
