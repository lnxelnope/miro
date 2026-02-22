// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class L10nZh extends L10n {
  L10nZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'MiRO';

  @override
  String get save => '节省';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get edit => '编辑';

  @override
  String get search => '搜索';

  @override
  String get loading => '加载中...';

  @override
  String get error => '发生错误';

  @override
  String get confirm => '确认';

  @override
  String get close => '关闭';

  @override
  String get done => '完毕';

  @override
  String get next => '下一个';

  @override
  String get skip => '跳过';

  @override
  String get retry => '重试';

  @override
  String get ok => '好的';

  @override
  String get foodName => '食品名称';

  @override
  String get calories => '卡路里';

  @override
  String get protein => 'Pro泰因';

  @override
  String get carbs => '碳水化合物';

  @override
  String get fat => '胖的';

  @override
  String get servingSize => '份量';

  @override
  String get servingUnit => '单元';

  @override
  String get kcal => 'kcal';

  @override
  String get mealBreakfast => '早餐';

  @override
  String get mealLunch => '午餐';

  @override
  String get mealDinner => '晚餐';

  @override
  String get mealSnack => '小吃';

  @override
  String get todaySummary => '今日总结';

  @override
  String dateSummary(String date) {
    return '$date 的摘要';
  }

  @override
  String get savedSuccess => '保存成功';

  @override
  String get deletedSuccess => '删除成功';

  @override
  String get pleaseEnterFoodName => '请输入食物名称';

  @override
  String get noDataYet => '还没有数据';

  @override
  String get addFood => '添加食物';

  @override
  String get editFood => '编辑食物';

  @override
  String get deleteFood => '删除食物';

  @override
  String get deleteConfirm => '确认删除？';

  @override
  String get foodLoggedSuccess => '食物已记录！';

  @override
  String get noApiKey => '请设置Gemini API Key';

  @override
  String get noApiKeyDescription => '进入 Profile → API Settings 进行设置';

  @override
  String get apiKeyTitle => '设置 Gemini API Key';

  @override
  String get apiKeyRequired => '需要 API Key';

  @override
  String get apiKeyFreeNote => 'Gemini API 可以免费使用';

  @override
  String get apiKeySetup => '设置 API Key';

  @override
  String get testConnection => '测试连接';

  @override
  String get connectionSuccess => '连接成功！准备使用';

  @override
  String get connectionFailed => '连接失败';

  @override
  String get pasteKey => '粘贴';

  @override
  String get deleteKey => '删除API Key';

  @override
  String get openAiStudio => '打开Google AI Studio';

  @override
  String get chatHint => '告诉 Miro 例如“原木炒饭”...';

  @override
  String get chatFoodSaved => '食物已记录！';

  @override
  String chatFoodSavedDetail(
      String name, String serving, String unit, String cal) {
    return '$name $serving $unit\n$cal kcal';
  }

  @override
  String get featureNotAvailable => '抱歉，此功能暂不可用';

  @override
  String get goalCalories => '卡路里/天';

  @override
  String get goalProtein => 'Pro斯坦/天';

  @override
  String get goalCarbs => '碳水化合物/天';

  @override
  String get goalFat => '脂肪/天';

  @override
  String get goalWater => '水/天';

  @override
  String get healthGoals => '健康目标';

  @override
  String get profile => 'Pro文件';

  @override
  String get settings => '设置';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get termsOfService => '服务条款';

  @override
  String get clearAllData => '清除所有数据';

  @override
  String get clearAllDataConfirm => '所有数据都将被删除。这无法撤销！';

  @override
  String get about => '关于';

  @override
  String get language => '语言';

  @override
  String get upgradePro => '升级到 Pro';

  @override
  String get proUnlocked => 'MiRO Pro';

  @override
  String get proDescription => '无限AI食品分析';

  @override
  String aiRemaining(int remaining, int total) {
    return 'AI分析：今日剩余$remaining/$total';
  }

  @override
  String get aiLimitReached => '今天达到 AI 限制 (3/3)';

  @override
  String get restorePurchase => '恢复购买';

  @override
  String get myMeals => '我的饭菜：';

  @override
  String get createMeal => '创建膳食';

  @override
  String get ingredients => '原料';

  @override
  String get searchFood => '搜索食物';

  @override
  String get analyzing => '正在分析...';

  @override
  String get analyzeWithAi => '人工智能分析';

  @override
  String get analysisComplete => '分析完成';

  @override
  String get timeline => '时间轴';

  @override
  String get diet => '饮食';

  @override
  String get quickAdd => '快速添加';

  @override
  String get welcomeTitle => 'MiRO';

  @override
  String get welcomeSubtitle => '利用人工智能轻松记录食物';

  @override
  String get onboardingFeature1 => '拍张照片';

  @override
  String get onboardingFeature1Desc => 'AI自动计算卡路里';

  @override
  String get onboardingFeature2 => '输入要记录的内容';

  @override
  String get onboardingFeature2Desc => '说“吃了炒饭”就会被记录';

  @override
  String get onboardingFeature3 => '每日总结';

  @override
  String get onboardingFeature3Desc => '追踪kcal、蛋白质、碳水化合物、脂肪';

  @override
  String get basicInfo => '基本信息';

  @override
  String get basicInfoDesc => '计算您推荐的每日卡路里摄入量';

  @override
  String get gender => '性别';

  @override
  String get male => '男性';

  @override
  String get female => '女性';

  @override
  String get age => '年龄';

  @override
  String get weight => '重量';

  @override
  String get height => '高度';

  @override
  String get activityLevel => '活动水平';

  @override
  String tdeeResult(int kcal) {
    return '您的 TDEE：$kcal kcal/天';
  }

  @override
  String get setupAiTitle => '设置 Gemini AI';

  @override
  String get setupAiDesc => '拍摄照片，AI 自动分析';

  @override
  String get setupNow => '立即设置';

  @override
  String get skipForNow => '暂时跳过';

  @override
  String get errorTimeout => '连接超时 - 请重试';

  @override
  String get errorInvalidKey => 'API Key 无效 — 检查您的设置';

  @override
  String get errorNoInternet => '没有互联网连接';

  @override
  String get errorGeneral => '发生错误 - 请重试';

  @override
  String get errorQuotaExceeded => 'API 超出配额 — 请等待并重试';

  @override
  String get apiKeyScreenTitle => '设置 Gemini API Key';

  @override
  String get analyzeFoodWithAi => '用人工智能分析食物';

  @override
  String get analyzeFoodWithAiDesc => '拍照→AI自动计算卡路里\nGemini API 可以免费使用！';

  @override
  String get openGoogleAiStudio => '打开Google AI Studio';

  @override
  String get step1Title => '打开Google AI Studio';

  @override
  String get step1Desc => '单击下面的按钮创建 API Key';

  @override
  String get step2Title => '使用 Google 帐户登录';

  @override
  String get step2Desc => '使用您的 Gmail 或 Google 帐户（如果您没有，请免费创建一个）';

  @override
  String get step3Title => '单击“创建API Key”';

  @override
  String get step3Desc =>
      '单击蓝色的“创建 API Key”按钮\n如果要求选择 Project → 单击“在新项目中创建 API 密钥”';

  @override
  String get step4Title => '复制密钥并粘贴到下面';

  @override
  String get step4Desc => '单击创建的密钥旁边的复制\n密钥看起来像：AIzaSyxxxx...';

  @override
  String get step5Title => '将 API Key 粘贴到此处';

  @override
  String get pasteApiKeyHint => '粘贴复制的 API Key';

  @override
  String get saveApiKey => '保存API Key';

  @override
  String get testingConnection => '测试...';

  @override
  String get deleteApiKey => '删除API Key';

  @override
  String get deleteApiKeyConfirm => '删除API Key？';

  @override
  String get deleteApiKeyConfirmDesc => '在重新设置之前，您将无法使用 AI 食物分析';

  @override
  String get apiKeySaved => 'API Key 保存成功';

  @override
  String get apiKeyDeleted => 'API Key 删除成功';

  @override
  String get pleasePasteApiKey => '请先粘贴API Key';

  @override
  String get apiKeyInvalidFormat => '无效 API Key — 必须以“AIza”开头';

  @override
  String get connectionSuccessMessage => '✅ 连接成功！准备使用';

  @override
  String get connectionFailedMessage => '❌ 连接失败';

  @override
  String get faqTitle => '常见问题解答';

  @override
  String get faqFreeQuestion => '真的免费吗？';

  @override
  String get faqFreeAnswer =>
      '是的！ Gemini 2.0 Flash 免费用于每天 1,500 个请求\n食物记录（5-15次/天）→ 永久免费，无需付费';

  @override
  String get faqSafeQuestion => '安全吗？';

  @override
  String get faqSafeAnswer =>
      'API Key 仅存储在您设备上的安全存储中\n应用程序未将密钥发送到我们的服务器\n如果密钥泄漏 → 删除并创建一个新密钥（这不是您的 Google 密码）';

  @override
  String get faqNoKeyQuestion => '如果我不创建密钥怎么办？';

  @override
  String get faqNoKeyAnswer =>
      '您仍然可以使用该应用程序！但是：\n❌无法拍照→AI分析\n✅ 可以手动记录食物\n✅ 快速添加作品\n✅ 查看kcal/宏总结作品';

  @override
  String get faqCreditCardQuestion => '我需要信用卡吗？';

  @override
  String get faqCreditCardAnswer => '否 — 无需信用卡即可免费创建 API Key';

  @override
  String get navDashboard => '仪表板';

  @override
  String get navMyMeals => '我的饭菜';

  @override
  String get navCamera => '相机';

  @override
  String get navAiChat => '人工智能聊天';

  @override
  String get navProfile => 'Pro文件';

  @override
  String get appBarTodayIntake => '今日摄入量';

  @override
  String get appBarMyMeals => '我的饭菜';

  @override
  String get appBarCamera => '相机';

  @override
  String get appBarAiChat => '人工智能聊天';

  @override
  String get appBarMiro => '米罗';

  @override
  String get permissionRequired => '需要许可';

  @override
  String get permissionRequiredDesc => 'MIRO 需要访问以下内容：';

  @override
  String get permissionPhotos => '照片 — 扫描食物';

  @override
  String get permissionCamera => '相机——拍摄食物';

  @override
  String get permissionSkip => '跳过';

  @override
  String get permissionAllow => '允许';

  @override
  String get permissionAllGranted => '已授予所有权限';

  @override
  String permissionDenied(String denied) {
    return '权限被拒绝：$denied';
  }

  @override
  String get openSettings => '打开设置';

  @override
  String get exitAppTitle => '退出应用程序？';

  @override
  String get exitAppMessage => '您确定要退出吗？';

  @override
  String get exit => '出口';

  @override
  String get healthGoalsTitle => '健康目标';

  @override
  String get healthGoalsInfo => '设置您的每日卡路里目标、宏指令和每餐预算。\n锁定自动计算：2 个宏或 3 餐。';

  @override
  String get dailyCalorieGoal => '每日卡路里目标';

  @override
  String get proteinLabel => 'Pro泰因';

  @override
  String get carbsLabel => '碳水化合物';

  @override
  String get fatLabel => '胖的';

  @override
  String get autoBadge => '汽车';

  @override
  String kcalPerGram(int kcalPerGram, int kcal) {
    return '$kcalPerGram kcal/g • $kcal __SW0__';
  }

  @override
  String get mealCalorieBudget => '膳食热量预算';

  @override
  String mealBudgetBalanced(int total, int goal) {
    return '总计 $total kcal = 目标 $goal __SW0__';
  }

  @override
  String mealBudgetRemaining(int total, int goal, int remaining) {
    return '总计 $total / $goal kcal （剩余 $remaining）';
  }

  @override
  String get lockMealsHint => '锁定 3 餐以自动计算第 4 餐';

  @override
  String get breakfastLabel => '早餐';

  @override
  String get lunchLabel => '午餐';

  @override
  String get dinnerLabel => '晚餐';

  @override
  String get snackLabel => '小吃';

  @override
  String percentOfDailyGoal(String percent) {
    return '每日目标的 $percent%';
  }

  @override
  String get smartSuggestionRange => '智能建议范围';

  @override
  String get smartSuggestionHow => '智能建议如何运作？';

  @override
  String smartSuggestionDesc(int threshold, int min, int max) {
    return '我们会从您的“我的餐食”、食材和昨天的餐食中推荐符合您每餐预算的食物。\n\n该阈值控制建议的灵活性。例如，如果您的午餐预算为 700 kcal，阈值为 $threshold __SW0__，我们会建议 $min–$max __SW0__ 之间的食物。';
  }

  @override
  String get suggestionThreshold => '建议阈值';

  @override
  String suggestionThresholdDesc(int threshold) {
    return '允许食物 ± $threshold kcal 超出膳食预算';
  }

  @override
  String get goalsSavedSuccess => '目标保存成功！';

  @override
  String get canOnlyLockTwoMacros => '一次只能锁定 2 个宏';

  @override
  String get canOnlyLockThreeMeals => '只能锁定3餐；第四个自动计算';

  @override
  String get tabMeals => '膳食';

  @override
  String get tabIngredients => '原料';

  @override
  String get searchMealsOrIngredients => '搜索餐食或配料...';

  @override
  String get createNewMeal => '创造新餐';

  @override
  String get addIngredient => '添加成分';

  @override
  String get noMealsYet => '还没吃饭';

  @override
  String get noMealsYetDesc => '利用人工智能分析食物以自动保存膳食\n或手动创建一个';

  @override
  String get noIngredientsYet => '还没有配料';

  @override
  String get noIngredientsYetDesc => '当你用人工智能分析食物时\n成分将自动保存';

  @override
  String mealCreated(String name) {
    return '创建了“$name”';
  }

  @override
  String mealLogged(String name) {
    return '记录“$name”';
  }

  @override
  String ingredientAmount(String unit) {
    return '金额 ($unit)';
  }

  @override
  String ingredientLogged(String name, String amount, String unit) {
    return '记录“$name”$amount$unit';
  }

  @override
  String get mealNotFound => '未找到餐食';

  @override
  String mealUpdated(String name) {
    return '更新了“$name”';
  }

  @override
  String get deleteMealTitle => '删除餐食？';

  @override
  String deleteMealMessage(String name) {
    return '“$name”';
  }

  @override
  String get deleteMealNote => '成分不会被删除。';

  @override
  String get mealDeleted => '餐食已删除';

  @override
  String ingredientCreated(String name) {
    return '创建了“$name”';
  }

  @override
  String get ingredientNotFound => '未找到成分';

  @override
  String ingredientUpdated(String name) {
    return '更新了“$name”';
  }

  @override
  String get deleteIngredientTitle => '删除成分？';

  @override
  String deleteIngredientMessage(String name) {
    return '“$name”';
  }

  @override
  String get ingredientDeleted => '成分已删除';

  @override
  String get noIngredientsData => '无成分数据';

  @override
  String ingredientDetail(String name, String amount, String unit) {
    return '$name ($amount $unit)';
  }

  @override
  String ingredientCalories(int calories) {
    return '$calories kcal';
  }

  @override
  String get useThisMeal => '使用这顿饭';

  @override
  String errorLoading(String error) {
    return '加载错误：$error';
  }

  @override
  String scanFoundNewImages(int count, String date) {
    return '在 $date 上找到 $count 新图片';
  }

  @override
  String scanNoNewImages(String date) {
    return '在 $date 上找不到新图像';
  }

  @override
  String aiAnalysisRemaining(int remaining, int total) {
    return 'AI 分析：今日剩余 $remaining/$total';
  }

  @override
  String get upgradeToProUnlimited => '升级到 Pro 无限使用';

  @override
  String get upgrade => '升级';

  @override
  String get confirmDelete => '确认删除';

  @override
  String confirmDeleteMessage(String name) {
    return '您想删除“$name”吗？';
  }

  @override
  String get entryDeletedSuccess => '✅ 条目删除成功';

  @override
  String entryDeleteError(String error) {
    return '❌错误：$error';
  }

  @override
  String batchAnalyzeItems(int count) {
    return '$count 项（批次）';
  }

  @override
  String analyzeCancelled(int success) {
    return '已取消 — 成功分析 $success 项';
  }

  @override
  String analyzeSuccessAll(int success) {
    return '✅ 成功分析 $success 项';
  }

  @override
  String analyzeSuccessPartial(int success, int total, int failed) {
    return '⚠️ 分析了 $success/$total 项（$failed 失败）';
  }

  @override
  String analyzeProgress(String item, int current, int total) {
    return '$item ($current/$total)';
  }

  @override
  String get pullToScanMeal => '拉动扫描您的餐食';

  @override
  String get analyzeAll => '分析全部';

  @override
  String get addFoodTitle => '添加食物';

  @override
  String get foodNameRequired => '食品名称 *';

  @override
  String get foodNameHint => '输入搜索例如炒饭，木瓜沙拉';

  @override
  String get selectedFromMyMeal => '✅ 从我的膳食中选择 — 自动填充营养数据';

  @override
  String get foundInDatabase => '✅ 在数据库中找到 - 自动填充营养数据';

  @override
  String get saveAndAnalyze => '保存并分析';

  @override
  String get notFoundInDatabase => '在数据库中未找到 — 将在后台进行分析';

  @override
  String get amountLabel => '数量';

  @override
  String get unitLabel => '单元';

  @override
  String get nutritionAutoCalculated => '营养（按量自动计算）';

  @override
  String get nutritionEnterZero => '营养（如果未知，请输入 0）';

  @override
  String get caloriesLabel => '卡路里 (kcal)';

  @override
  String get proteinLabelShort => 'Protein (克)';

  @override
  String get carbsLabelShort => '碳水化合物（克）';

  @override
  String get fatLabelShort => '脂肪（克）';

  @override
  String get mealTypeLabel => '膳食类型';

  @override
  String get pleaseEnterFoodNameFirst => '请先输入食物名称';

  @override
  String get savedAnalyzingBackground => '✅ 已保存 — 在后台分析';

  @override
  String get foodAdded => '✅ 添加食物';

  @override
  String get suggestionSourceMyMeal => '我的饭菜';

  @override
  String get suggestionSourceIngredient => '成分';

  @override
  String get suggestionSourceDatabase => '数据库';

  @override
  String get editFoodTitle => '编辑食物';

  @override
  String get foodNameLabel => '食品名称';

  @override
  String get changeAmountAutoUpdate => '改变量→卡路里自动更新';

  @override
  String baseNutrition(int calories, String unit) {
    return '基数：$calories kcal / 1 $unit';
  }

  @override
  String get calculatedFromIngredients => '根据以下成分计算';

  @override
  String get ingredientsEditable => '成分（可编辑）';

  @override
  String get addIngredientButton => '添加';

  @override
  String get noIngredientsAddHint => '没有成分 — 点击“添加”添加新成分';

  @override
  String get editIngredientsHint => '编辑名称/金额→点击搜索图标搜索数据库或AI';

  @override
  String get ingredientNameHint => '例如鸡蛋';

  @override
  String get searchDbOrAi => '搜索数据库/人工智能';

  @override
  String get amountHint => '数量';

  @override
  String get fromDatabase => '来自数据库';

  @override
  String subIngredients(int count) {
    return '子成分 ($count)';
  }

  @override
  String get addSubIngredient => '添加';

  @override
  String get subIngredientNameHint => '子成分名称';

  @override
  String get amountShort => '阿姆特';

  @override
  String get pleaseEnterSubIngredientName => '请先输入子成分名称';

  @override
  String foundInDatabaseSub(String name) {
    return '在数据库中找到“$name”！';
  }

  @override
  String aiAnalyzedSub(String name) {
    return 'AI 分析“$name”（-1 能量）';
  }

  @override
  String get couldNotAnalyzeSub => '无法分析子成分';

  @override
  String get pleaseEnterIngredientName => '请输入成分名称';

  @override
  String get reAnalyzeTitle => '重新分析？';

  @override
  String reAnalyzeMessage(String name) {
    return '“$name”已有营养数据。\n\n再次分析将消耗 1 点能量。\n\n继续？';
  }

  @override
  String get reAnalyzeButton => '重新分析（1 能量）';

  @override
  String get amountNotSpecified => '金额未指定';

  @override
  String amountNotSpecifiedMessage(String name) {
    return '请先指定“$name”的金额\n还是使用默认的100克？';
  }

  @override
  String get useDefault100g => '使用100克';

  @override
  String aiAnalyzedResult(String name, int calories) {
    return 'AI：“$name”→ $calories kcal';
  }

  @override
  String get unableToAnalyze => '无法分析';

  @override
  String get today => '今天';

  @override
  String get savedSuccessfully => '✅ 保存成功';

  @override
  String get confirmFoodPhoto => '确认食物照片';

  @override
  String get photoSavedAutomatically => '照片自动保存';

  @override
  String get foodNameHintExample => '例如，烤鸡肉沙拉';

  @override
  String get quantityLabel => '数量';

  @override
  String get quantityHint => '1';

  @override
  String get optionalFoodInfo => '输入食物名称和数量是可选的，但提供它们将提高人工智能分析的准确性。';

  @override
  String get saveOnly => '仅保存';

  @override
  String get pleaseEnterValidQuantity => '请输入有效数量';

  @override
  String analyzedResult(String name, int calories) {
    return '✅ 分析：$name — $calories kcal';
  }

  @override
  String get couldNotAnalyzeSaved => '⚠️ 无法分析 — 已保存，稍后使用“分析全部”';

  @override
  String get savedAnalyzeLater => '✅ 已保存 — 稍后使用“分析全部”进行分析';

  @override
  String get editIngredientTitle => '编辑成分';

  @override
  String get ingredientNameRequired => '成分名称 *';

  @override
  String get baseAmountLabel => '基础金额';

  @override
  String get baseAmountHint => '100';

  @override
  String nutritionPerBase(String amount, String unit) {
    return '每 $amount $unit 的营养';
  }

  @override
  String nutritionCalculatedPerBase(String amount, String unit) {
    return '按 $amount $unit 计算营养 — 系统将根据实际消耗量自动计算';
  }

  @override
  String get createIngredient => '创建成分';

  @override
  String get saveChanges => '保存更改';

  @override
  String get pleaseEnterIngredientNameFirst => '请先输入成分名称';

  @override
  String aiAnalyzedIngredient(
      String name, String amount, String unit, int calories) {
    return 'AI：“$name” $amount $unit → $calories kcal';
  }

  @override
  String get unableToFindIngredient => '找不到这个成分';

  @override
  String searchFailed(String error) {
    return '搜索失败：$error';
  }

  @override
  String deleteEntriesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Entries',
      one: 'Entry',
    );
    return '删除 $count $_temp0？';
  }

  @override
  String deleteEntriesMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return '删除 $count 所选食物 $_temp0？';
  }

  @override
  String get deleteAll => '全部删除';

  @override
  String deletedEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return '已删除 $count $_temp0';
  }

  @override
  String movedEntriesToDate(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return '将 $count $_temp0 移至 $date';
  }

  @override
  String get allSelectedAlreadyAnalyzed => '所有选定的条目均已分析';

  @override
  String analyzeCancelledSelected(int success) {
    return '已取消 — 分析了 $success';
  }

  @override
  String analyzedEntriesAll(int success) {
    String _temp0 = intl.Intl.pluralLogic(
      success,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return '分析了 $success $_temp0';
  }

  @override
  String analyzedEntriesPartial(int success, int total, int failed) {
    return '分析 $success/$total（$failed 失败）';
  }

  @override
  String analyzeProgressSelected(int current, int total, String item) {
    return '$current/$total $item';
  }

  @override
  String get noEntriesYet => '还没有条目';

  @override
  String get selectAll => '选择全部';

  @override
  String get deselectAll => '取消全选';

  @override
  String get moveToDate => '移至日期';

  @override
  String get analyzeSelected => '分析选定的';

  @override
  String get deleteTooltip => '删除';

  @override
  String get move => '移动';

  @override
  String get deleteTooltipAction => '删除';

  @override
  String switchToModeTitle(String mode) {
    return '切换到 $mode 模式？';
  }

  @override
  String switchToModeMessage(String current, String newMode) {
    return '该项目被分析为 $current。\n\n重新分析 $newMode 将使用 1 能量。\n\n继续？';
  }

  @override
  String analyzingAsMode(String mode) {
    return '分析为 $mode...';
  }

  @override
  String reAnalyzedAsMode(String mode) {
    return '✅ 重新分析为 $mode';
  }

  @override
  String get analysisFailed => '❌ 分析失败';

  @override
  String get aiAnalysisComplete => '✅ AI分析并保存';

  @override
  String get changeMealType => '更改膳食类型';

  @override
  String get moveToAnotherDate => '移至另一个日期';

  @override
  String currentDate(String date) {
    return '当前：$date';
  }

  @override
  String get cancelDateChange => '取消更改日期';

  @override
  String get undo => '撤消';

  @override
  String get chatHistory => '聊天记录';

  @override
  String get newChat => '新聊天';

  @override
  String get quickActions => '快速行动';

  @override
  String get clear => '清除';

  @override
  String get helloImMiro => '你好！我是Miro';

  @override
  String get tellMeWhatYouAteToday => '告诉我你今天吃了什么！';

  @override
  String get tellMeWhatYouAte => '告诉我你吃了什么...';

  @override
  String get clearHistoryTitle => '清除历史记录？';

  @override
  String get clearHistoryMessage => '此会话中的所有消息都将被删除。';

  @override
  String get chatHistoryTitle => '聊天记录';

  @override
  String get newLabel => '新的';

  @override
  String get noChatHistoryYet => '还没有聊天记录';

  @override
  String get active => '积极的';

  @override
  String get deleteChatTitle => '删除聊天记录？';

  @override
  String deleteChatMessage(String title) {
    return '删除“$title”？';
  }

  @override
  String weeklySummaryTitle(String start, String end) {
    return '📊 每周总结（$start - $end）';
  }

  @override
  String daySummary(String day, String calories, String emoji, String diff) {
    return '📅$day：$calories kcal $emoji ($diff)';
  }

  @override
  String overTarget(String amount) {
    return '$amount 超过目标';
  }

  @override
  String underTarget(String amount) {
    return '$amount 低于目标';
  }

  @override
  String get noFoodLoggedThisWeek => '本周尚未记录任何食物。';

  @override
  String averageKcalPerDay(String average) {
    return '🔥 平均：$average kcal/天';
  }

  @override
  String targetKcalPerDay(String target) {
    return '🎯 目标：$target kcal/天';
  }

  @override
  String resultOverTarget(String amount) {
    return '📈 结果：$amount kcal 超过目标';
  }

  @override
  String resultUnderTarget(String amount) {
    return '📈 结果：$amount kcal 低于目标 — 干得好！ 💪';
  }

  @override
  String failedToLoadWeeklySummary(String error) {
    return '❌ 无法加载每周摘要：$error';
  }

  @override
  String monthlySummaryTitle(String month, int year) {
    return '📊 每月总结 ($month $year)';
  }

  @override
  String totalDays(int days) {
    return '📅 总天数：$days';
  }

  @override
  String totalConsumed(String calories) {
    return '🔥 总消耗量：$calories kcal';
  }

  @override
  String targetTotal(String target) {
    return '🎯 目标总计：$target kcal';
  }

  @override
  String averageKcalPerDayShort(String average) {
    return '📈 平均：$average kcal/天';
  }

  @override
  String overTargetThisMonth(String amount) {
    return '⚠️ $amount kcal 超过本月目标';
  }

  @override
  String underTargetThisMonth(String amount) {
    return '✅ $amount kcal 低于目标 — 非常好！ 💪';
  }

  @override
  String failedToLoadMonthlySummary(String error) {
    return '❌ 无法加载每月摘要：$error';
  }

  @override
  String get localAiHelpTitle => '🤖 本地人工智能帮助';

  @override
  String get localAiHelpFormat => '格式：[食物][数量][单位]';

  @override
  String get localAiHelpExamples => '示例：\n•鸡肉100克，米饭200克\n•披萨2片\n• 苹果1块，香蕉1块';

  @override
  String get localAiHelpNote => '注：仅限英文，基本解析\n切换到 Miro AI 以获得更好的结果！';

  @override
  String hiNoFoodLogged(String target) {
    return '🤖 嗨！今天尚未记录任何食物。\n   目标：$target kcal — 准备好开始记录了吗？ 🍽️';
  }

  @override
  String hiKcalLeft(String remaining) {
    return '🤖 嗨！您今天还有 $remaining kcal 。\n   准备好记录您的膳食了吗？ 😊';
  }

  @override
  String hiOverTarget(String calories, String over) {
    return '🤖 嗨！您今天已消耗 $calories kcal。\n   $over __SW0__ 超出目标 — 让我们继续跟踪！ 💪';
  }

  @override
  String get hiReadyToLog => '🤖 嗨！准备好记录您的膳食了吗？ 😊';

  @override
  String get notEnoughEnergy => '能量不足';

  @override
  String get thinkingMealIdeas => '🤖 为您思考美味佳肴......';

  @override
  String get recentMeals => '最近的饭菜：';

  @override
  String get noRecentFood => '没有记录最近的食物。';

  @override
  String remainingCaloriesToday(String remaining) {
    return '。今天剩余卡路里：$remaining kcal。';
  }

  @override
  String failedToGetMenuSuggestions(String error) {
    return '❌ 获取菜单建议失败：$error';
  }

  @override
  String get mealSuggestionsTitle => '🤖 根据您的饮食记录，这里有 3 种膳食建议：';

  @override
  String mealSuggestionItem(
      int index, String emoji, String name, String calories) {
    return '$index。 $emoji $name (~$calories kcal)';
  }

  @override
  String mealSuggestionMacros(String protein, String carbs, String fat) {
    return 'P： ${protein}g | C：${carbs}g | F：${fat}g';
  }

  @override
  String get pickOneAndLog => '选择一个，我会为您记录！ 😊';

  @override
  String energyCost(int cost) {
    return '⚡ -$cost 能源';
  }

  @override
  String get giveMeTipsForHealthyEating => '给我健康饮食的建议';

  @override
  String get howManyCaloriesToday => '今天多少卡路里？';

  @override
  String get menuLabel => '菜单';

  @override
  String get weeklyLabel => '每周';

  @override
  String get monthlyLabel => '每月';

  @override
  String get tipsLabel => '尖端';

  @override
  String get summaryLabel => '概括';

  @override
  String get helpLabel => '帮助';

  @override
  String get onboardingWelcomeSubtitle => '轻松追踪卡路里\n借助人工智能分析';

  @override
  String get onboardingSnap => '折断';

  @override
  String get onboardingSnapDesc => 'AI即时分析';

  @override
  String get onboardingType => '类型';

  @override
  String get onboardingTypeDesc => '登录秒数';

  @override
  String get onboardingEdit => '编辑';

  @override
  String get onboardingEditDesc => '微调精度';

  @override
  String get onboardingNext => '下一页 →';

  @override
  String get onboardingDisclaimer => 'AI估计数据。不是医疗建议。';

  @override
  String get onboardingQuickSetup => '快速设置';

  @override
  String get onboardingHelpAiUnderstand => '帮助人工智能更好地理解你的食物';

  @override
  String get onboardingYourTypicalCuisine => '您的典型美食：';

  @override
  String get onboardingDailyCalorieGoal => '每日卡路里目标（可选）：';

  @override
  String get onboardingKcalPerDay => 'kcal/天';

  @override
  String get onboardingCalorieGoalHint => '2000年';

  @override
  String get onboardingCanChangeAnytime => '您可以随时在 Pro 文件设置中更改此设置';

  @override
  String get onboardingYoureAllSet => '一切就绪！';

  @override
  String get onboardingStartTracking => '从今天开始记录您的膳食。\n拍张照片或输入你吃了什么。';

  @override
  String get onboardingWelcomeGift => '欢迎礼物';

  @override
  String get onboardingFreeEnergy => '10 免费能量';

  @override
  String get onboardingFreeEnergyDesc => '= 10 项人工智能分析入门';

  @override
  String get onboardingEnergyCost => '每次分析消耗 1 能量\n使用越多，赚得越多！';

  @override
  String get onboardingStartTrackingButton => '开始追踪！ →';

  @override
  String get onboardingNoCreditCard => '无需信用卡 • 无隐藏费用';

  @override
  String get cameraTakePhotoOfFood => '给你的食物拍张照片';

  @override
  String get cameraFailedToInitialize => '相机初始化失败';

  @override
  String get cameraFailedToCapture => '拍摄照片失败';

  @override
  String get cameraFailedToPickFromGallery => '无法从图库中选取图像';

  @override
  String get cameraProcessing => 'Pro停止...';

  @override
  String get referralInviteFriends => '邀请好友';

  @override
  String get referralYourReferralCode => '您的推荐码';

  @override
  String get referralLoading => '加载中...';

  @override
  String get referralCopy => '复制';

  @override
  String get referralShareCodeDescription => '与朋友分享此代码！当他们使用 AI 3 次时，你们都会获得奖励！';

  @override
  String get referralEnterReferralCode => '输入推荐码';

  @override
  String get referralCodeHint => '米罗-XXXX-XXXX-XXXX';

  @override
  String get referralSubmitCode => '提交代码';

  @override
  String get referralPleaseEnterCode => '请输入推荐码';

  @override
  String get referralCodeAccepted => '接受推荐码！';

  @override
  String get referralCodeCopied => '推荐代码已复制到剪贴板！';

  @override
  String referralEnergyBonus(int energy) {
    return '+$energy 能量！';
  }

  @override
  String get referralHowItWorks => '它是如何运作的';

  @override
  String get referralStep1Title => '分享您的推荐代码';

  @override
  String get referralStep1Description => '复制并与朋友分享您的 MiRO ID';

  @override
  String get referralStep2Title => '朋友输入您的代码';

  @override
  String get referralStep2Description => '他们立即获得 +20 能量';

  @override
  String get referralStep3Title => '朋友使用AI 3次';

  @override
  String get referralStep3Description => '当他们完成 3 项人工智能分析时';

  @override
  String get referralStep4Title => '你会得到奖励！';

  @override
  String get referralStep4Description => '您获得+5 能量！';

  @override
  String get tierBenefitsTitle => '等级福利';

  @override
  String get tierBenefitsUnlockRewards => '解锁奖励\n每日连胜';

  @override
  String get tierBenefitsKeepStreakDescription => '保持你的连胜，解锁更高的等级并获得惊人的好处！';

  @override
  String get tierBenefitsHowItWorks => '它是如何运作的';

  @override
  String get tierBenefitsDailyEnergyReward => '每日能量奖励';

  @override
  String get tierBenefitsDailyEnergyDescription =>
      '每天至少使用一次人工智能来赚取奖励能量。更高的等级=更多的日常能量！';

  @override
  String get tierBenefitsPurchaseBonus => '购买特典';

  @override
  String get tierBenefitsPurchaseBonusDescription =>
      '黄金级和钻石级每次购买都会获得额外能量（多 10-20%！）';

  @override
  String get tierBenefitsGracePeriod => '宽限期';

  @override
  String get tierBenefitsGracePeriodDescription => '错过一天也不会失去连续记录。白银+等级获得保护！';

  @override
  String get tierBenefitsAllTiers => '所有级别';

  @override
  String get tierBenefitsNew => '新的';

  @override
  String get tierBenefitsPopular => '受欢迎的';

  @override
  String get tierBenefitsBest => '最好的';

  @override
  String get tierBenefitsDailyCheckIn => '每日签到';

  @override
  String get tierBenefitsProTips => 'Pro 提示';

  @override
  String get tierBenefitsTip1 => '每天使用人工智能来赚取免费能量并建立你的连胜纪录';

  @override
  String get tierBenefitsTip2 => '钻石级每天赚取 +4 能量——即 120/月！';

  @override
  String get tierBenefitsTip3 => '购买奖励适用于所有能量包！';

  @override
  String get tierBenefitsTip4 => '如果您错过一天，宽限期可以保护您的连续记录';

  @override
  String get subscriptionEnergyPass => '能量通行证';

  @override
  String get subscriptionInAppPurchasesNotAvailable => '不支持应用内购买';

  @override
  String get subscriptionFailedToInitiatePurchase => '发起购买失败';

  @override
  String subscriptionError(String error) {
    return '错误：$error';
  }

  @override
  String get subscriptionFailedToLoad => '加载订阅失败';

  @override
  String get subscriptionUnknownError => '未知错误';

  @override
  String get subscriptionRetry => '重试';

  @override
  String get subscriptionEnergyPassActive => '能量通行证激活';

  @override
  String get subscriptionUnlimitedAccess => '您有无限制的访问权限';

  @override
  String get subscriptionStatus => '地位';

  @override
  String get subscriptionRenews => '续订';

  @override
  String get subscriptionPrice => '价格';

  @override
  String get subscriptionYourBenefits => '您的好处';

  @override
  String get subscriptionManageSubscription => '管理订阅';

  @override
  String get subscriptionNoProductAvailable => '没有可用的订阅产品';

  @override
  String get subscriptionWhatYouGet => '你得到什么';

  @override
  String get subscriptionPerMonth => '每月';

  @override
  String get subscriptionSubscribeNow => '立即订阅';

  @override
  String get subscriptionCancelAnytime => '随时取消';

  @override
  String get subscriptionAutoRenewTerms => '您的订阅将自动续订。您可以随时从 Google Play 取消。';

  @override
  String get disclaimerHealthDisclaimer => '健康免责声明';

  @override
  String get disclaimerImportantReminders => '重要提醒：';

  @override
  String get disclaimerBullet1 => '所有营养数据均为估算值';

  @override
  String get disclaimerBullet2 => 'AI分析可能存在错误';

  @override
  String get disclaimerBullet3 => '不能替代专业建议';

  @override
  String get disclaimerBullet4 => '向医疗保健提供者咨询医疗指导';

  @override
  String get disclaimerBullet5 => '请自行决定使用并承担风险';

  @override
  String get disclaimerIUnderstand => '我明白';

  @override
  String get privacyPolicyTitle => '隐私政策';

  @override
  String get privacyPolicySubtitle => 'MiRO — 我的摄入记录 Oracle';

  @override
  String get privacyPolicyHeaderNote => '您的食物数据保留在您的设备上。能量平衡通过 Firebase 安全同步。';

  @override
  String get privacyPolicySectionInformationWeCollect => '我们收集的信息';

  @override
  String get privacyPolicySectionDataStorage => '数据存储';

  @override
  String get privacyPolicySectionDataTransmission => '向第三方传输数据';

  @override
  String get privacyPolicySectionRequiredPermissions => '所需权限';

  @override
  String get privacyPolicySectionSecurity => '安全';

  @override
  String get privacyPolicySectionUserRights => '用户权利';

  @override
  String get privacyPolicySectionDataRetention => '数据保留';

  @override
  String get privacyPolicySectionChildrenPrivacy => '儿童隐私';

  @override
  String get privacyPolicySectionChangesToPolicy => '本政策的变更';

  @override
  String get privacyPolicySectionDataCollectionConsent => '数据收集同意书';

  @override
  String get privacyPolicySectionPDPACompliance => 'PDPA 合规性（泰国个人数据Pro保护法）';

  @override
  String get privacyPolicySectionContactUs => '联系我们';

  @override
  String get privacyPolicyEffectiveDate =>
      '生效日期：2026 年 2 月 18 日\n最后更新时间：2026 年 2 月 18 日';

  @override
  String get termsOfServiceTitle => '服务条款';

  @override
  String get termsSubtitle => 'MiRO — 我的摄入记录 Oracle';

  @override
  String get termsSectionAcceptanceOfTerms => '接受条款';

  @override
  String get termsSectionServiceDescription => '服务说明';

  @override
  String get termsSectionDisclaimerOfWarranties => '免责声明';

  @override
  String get termsSectionEnergySystemTerms => '能源系统术语';

  @override
  String get termsSectionUserDataAndResponsibilities => '用户数据和责任';

  @override
  String get termsSectionBackupTransfer => '备份与传输';

  @override
  String get termsSectionInAppPurchases => '应用内购买';

  @override
  String get termsSectionProhibitedUses => 'Pro禁止用途';

  @override
  String get termsSectionIntellectualProperty => '智力 Property';

  @override
  String get termsSectionLimitationOfLiability => '责任限制';

  @override
  String get termsSectionServiceTermination => '服务终止';

  @override
  String get termsSectionChangesToTerms => '条款变更';

  @override
  String get termsSectionGoverningLaw => '适用法律';

  @override
  String get termsSectionContactUs => '联系我们';

  @override
  String get termsAcknowledgment => '使用MiRO，即表示您承认您已阅读、理解并同意这些服务条款。';

  @override
  String get termsLastUpdated => '最后更新时间：2026 年 2 月 15 日';

  @override
  String get profileAndSettings => 'Pro文件和设置';

  @override
  String errorOccurred(String error) {
    return '错误：$error';
  }

  @override
  String get healthGoalsSection => '健康目标';

  @override
  String get dailyGoals => '每日目标';

  @override
  String get chatAiModeSection => '聊天人工智能模式';

  @override
  String get selectAiPowersChat => '选择哪个 AI 为您的聊天提供支持';

  @override
  String get miroAi => 'Miro人工智能';

  @override
  String get miroAiSubtitle => '由Gemini 提供支持 • 多语言 • 高精度';

  @override
  String get localAi => '本地人工智能';

  @override
  String get localAiSubtitle => '设备上 • 仅英语 • 基本准确性';

  @override
  String get free => '自由的';

  @override
  String get cuisinePreferenceSection => '美食偏好';

  @override
  String get preferredCuisine => '首选美食';

  @override
  String get selectYourCuisine => '选择您的菜系';

  @override
  String get photoScanSection => '照片扫描';

  @override
  String get languageSection => '语言';

  @override
  String get languageTitle => '语言 / ภาษา';

  @override
  String get selectLanguage => '选择语言 / เลือกภาษา';

  @override
  String get systemDefault => '系统默认值';

  @override
  String get systemDefaultSublabel => 'ตามระบบ';

  @override
  String get english => '英语';

  @override
  String get englishSublabel => 'อังกฤษ';

  @override
  String get thai => 'ไทย（泰语）';

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
  String get closeBilingual => '关闭 / ปิด';

  @override
  String languageChangedTo(String language) {
    return '语言更改为 $language';
  }

  @override
  String get accountSection => '帐户';

  @override
  String get miroId => 'MiRO ID';

  @override
  String get miroIdCopied => 'MiRO ID 已复制！';

  @override
  String get inviteFriends => '邀请好友';

  @override
  String get inviteFriendsSubtitle => '分享您的推荐代码并赚取奖励！';

  @override
  String get unlimitedAiDoubleRewards => '无限AI+双倍奖励';

  @override
  String get plan => '计划';

  @override
  String get monthly => '每月';

  @override
  String get started => '开始';

  @override
  String get renews => '续订';

  @override
  String get expires => '过期';

  @override
  String get autoRenew => '自动续订';

  @override
  String get on => '在';

  @override
  String get off => '离开';

  @override
  String get tapToManageSubscription => '点击即可管理订阅';

  @override
  String get dataSection => '数据';

  @override
  String get backupData => '备份数据';

  @override
  String get backupDataSubtitle => '能量+食物历史→另存为文件';

  @override
  String get restoreFromBackup => '从备份恢复';

  @override
  String get restoreFromBackupSubtitle => '从备份文件导入数据';

  @override
  String get clearAllDataTitle => '清除所有数据？';

  @override
  String get clearAllDataContent =>
      '所有数据将被删除：\n• 食品条目\n• 我的膳食\n• 成分\n• 目标\n• 个人信息\n\n这无法撤销！';

  @override
  String get allDataClearedSuccess => '全部数据清除成功';

  @override
  String get aboutSection => '关于';

  @override
  String get version => '版本';

  @override
  String get healthDisclaimer => '健康免责声明';

  @override
  String get importantLegalInformation => '重要法律信息';

  @override
  String get showTutorialAgain => '再次显示教程';

  @override
  String get viewFeatureTour => '查看特色导览';

  @override
  String get showTutorialDialogTitle => '显示教程';

  @override
  String get showTutorialDialogContent =>
      '这将显示突出显示的功能导览：\n\n• 能源系统\n• 拉动刷新照片扫描\n• 与Miro AI 聊天\n\n您将返回主屏幕。';

  @override
  String get showTutorialButton => '显示教程';

  @override
  String get tutorialResetMessage => '教程重置！转到主屏幕即可查看。';

  @override
  String get foodAnalysisTutorial => '食品分析教程';

  @override
  String get foodAnalysisTutorialSubtitle => '了解如何使用食品分析功能';

  @override
  String get backupCreated => '备份已创建！';

  @override
  String get backupCreatedContent => '您的备份文件已成功创建。';

  @override
  String get backupChooseDestination => '您想在哪里保存备份？';

  @override
  String get backupSaveToDevice => '保存到设备';

  @override
  String get backupSaveToDeviceDesc => '保存到您在此设备上选择的文件夹';

  @override
  String get backupShareToOther => '分享到其他设备';

  @override
  String get backupShareToOtherDesc => '通过线路、电子邮件、Google 驱动器等发送。';

  @override
  String get backupSavedSuccess => '备份已保存！';

  @override
  String get backupSavedSuccessContent => '您的备份文件已保存到您选择的位置。';

  @override
  String get important => '重要的：';

  @override
  String get backupImportantNotes =>
      '• 将此文件保存在安全的地方（Google 驱动器等）\n• 照片不包含在备份中\n• 转移密钥将在 30 天后过期\n• 钥匙只能使用一次';

  @override
  String get restoreBackup => '恢复备份？';

  @override
  String get backupFrom => '备份来源：';

  @override
  String get date => '日期：';

  @override
  String get energy => '活力：';

  @override
  String get foodEntries => '食品条目：';

  @override
  String get restoreImportant => '重要的';

  @override
  String restoreImportantNotes(String energy) {
    return '• 该设备上的当前能量将替换为备用能量 ($energy)\n• 食品条目将被合并（不被替换）\n• 照片不包含在备份中\n• 将使用转移密钥（不能重复使用）';
  }

  @override
  String get restore => '恢复';

  @override
  String get restoreComplete => '恢复完成！';

  @override
  String get restoreCompleteContent => '您的数据已成功恢复。';

  @override
  String get newEnergyBalance => '新能源平衡：';

  @override
  String get foodEntriesImported => '进口食品条目：';

  @override
  String get myMealsImported => '我的进口餐食：';

  @override
  String get appWillRefresh => '您的应用程序将刷新以显示恢复的数据。';

  @override
  String get backupFailed => '备份失败';

  @override
  String get invalidBackupFile => '无效的备份文件';

  @override
  String get restoreFailed => '恢复失败';

  @override
  String get analyticsDataCollection => '分析数据收集';

  @override
  String get analyticsEnabled => '启用分析 - ขอบคุณที่ช่วยปรับปรุงแอป';

  @override
  String get analyticsDisabled => '分析已禁用 - ไม่เก็บข้อมูลการใช้งาน';

  @override
  String get enabled => '启用';

  @override
  String get enabledSubtitle => '启用 - ช่วยปรับปรุงประสบการณ์ใช้งาน';

  @override
  String get disabled => '残疾人';

  @override
  String get disabledSubtitle => '已禁用 - ไม่เก็บข้อมูลการใช้งาน';

  @override
  String get imagesPerDay => '每天的图像数';

  @override
  String scanUpToImagesPerDay(String limit) {
    return '每天最多扫描 $limit 张图像';
  }

  @override
  String get reset => '重置';

  @override
  String get resetScanHistory => '重置扫描历史记录';

  @override
  String get resetScanHistorySubtitle => '删除所有扫描条目并重新扫描';

  @override
  String get imagesPerDayDialog => '每天的图像数';

  @override
  String get maxImagesPerDayDescription => '每天扫描的最大图像数\n仅扫描选定的日期';

  @override
  String scanLimitSetTo(String limit) {
    return '扫描限制设置为每天 $limit 张图像';
  }

  @override
  String get resetScanHistoryDialog => '重置扫描历史记录？';

  @override
  String get resetScanHistoryContent => '所有画廊扫描的食品条目都将被删除。\n下拉任意日期即可重新扫描图像。';

  @override
  String resetComplete(String count) {
    return '重置完成 - $count 条目已删除。向下拉重新扫描。';
  }

  @override
  String questBarStreak(int days) {
    return '连续 $days 天';
  }

  @override
  String questBarDaysToNextTier(int days, String tier) {
    return '$days 天 → $tier';
  }

  @override
  String get questBarMaxTier => '最高等级！ 💎';

  @override
  String get questBarOfferDismissed => '优惠隐藏';

  @override
  String get questBarViewOffer => '查看优惠';

  @override
  String get questBarNoOffersNow => '• 目前没有优惠';

  @override
  String get questBarWeeklyChallenges => '🎯 每周挑战';

  @override
  String get questBarMilestones => '🏆 里程碑';

  @override
  String get questBarInviteFriends => '👥 邀请好友送20E';

  @override
  String questBarTimeRemaining(String time) {
    return '⏰ 剩余时间$time';
  }

  @override
  String questBarClaimDailyEnergy(int energy) {
    return '+${energy}E';
  }

  @override
  String questBarShareReferralError(String error) {
    return '错误分享：$error';
  }

  @override
  String tierCelebrationTitle(String tier) {
    return '$tier 庆祝活动🎉';
  }

  @override
  String tierCelebrationDay(int day) {
    return '日 $day';
  }

  @override
  String get tierCelebrationExpired => '已到期';

  @override
  String get tierCelebrationComplete => '完全的！';

  @override
  String questBarWatchAd(int energy) {
    return '观看广告 +$energy⚡';
  }

  @override
  String questBarAdRemaining(int remaining, int total) {
    return '今天剩余 $remaining/$total';
  }

  @override
  String questBarAdSuccess(int energy) {
    return '广告看了！ +$energy 能量输入...';
  }

  @override
  String get questBarAdNotReady => '广告未准备好，请重试';

  @override
  String get questBarDailyChallenge => '每日挑战';

  @override
  String get questBarUseAi => '使用能源';

  @override
  String get questBarResetsMonday => '每周一重置';

  @override
  String get questBarClaimed => '声称！';

  @override
  String get questBarHideOffer => '隐藏';

  @override
  String get questBarViewDetails => '看法';

  @override
  String questBarShareText(String link) {
    return '尝试MiRO！人工智能驱动的食品分析🍔\n使用此链接，我们都可以免费获得 +20 能量！\n\n$link';
  }

  @override
  String get questBarShareSubject => '尝试MiRO';

  @override
  String get claimButtonTitle => '索取每日能量';

  @override
  String claimButtonReceived(String energy) {
    return '收到+${energy}E！';
  }

  @override
  String get claimButtonAlreadyClaimed => '今天已经领取了';

  @override
  String claimButtonError(String error) {
    return '错误：$error';
  }

  @override
  String get seasonalQuestLimitedTime => '限时';

  @override
  String seasonalQuestDaysLeft(int days) {
    return '还剩 $days 天';
  }

  @override
  String seasonalQuestRewardDaily(int reward) {
    return '+${reward}E / 天';
  }

  @override
  String seasonalQuestRewardOnce(int reward) {
    return '+${reward}E 一次性';
  }

  @override
  String get seasonalQuestClaimed => '声称！';

  @override
  String get seasonalQuestClaimedToday => '今天领取';

  @override
  String get errorFailed => '失败的';

  @override
  String get errorFailedToClaim => '索赔失败';

  @override
  String errorGeneric(String error) {
    return '错误：$error';
  }

  @override
  String get milestoneNoMilestonesToClaim => '尚未取得任何里程碑';

  @override
  String milestoneClaimedEnergy(int energy) {
    return '🎁 已领取 +$energy 能量！';
  }

  @override
  String get milestoneTitle => '里程碑';

  @override
  String milestoneUseEnergyComplete(int threshold) {
    return '使用能量 $threshold';
  }

  @override
  String milestoneNext(int threshold) {
    return '下一页： ${threshold}E';
  }

  @override
  String get milestoneAllComplete => '所有里程碑均已完成！';

  @override
  String get noEnergyTitle => '耗尽能量';

  @override
  String get noEnergyContent => '使用 AI 分析食物需要 1 能量';

  @override
  String get noEnergyTip => '您仍然可以免费手动记录食物（无需人工智能）';

  @override
  String get noEnergyLater => '之后';

  @override
  String noEnergyWatchAd(int remaining) {
    return '观看广告 ($remaining/3)';
  }

  @override
  String get noEnergyBuyEnergy => '购买能源';

  @override
  String get tierBronze => '青铜';

  @override
  String get tierSilver => '银';

  @override
  String get tierGold => '金子';

  @override
  String get tierDiamond => '钻石';

  @override
  String get tierStarter => '起动机';

  @override
  String get tierUpCongratulations => '🎉恭喜！';

  @override
  String tierUpYouReached(String tier) {
    return '您已达到 $tier！';
  }

  @override
  String get tierUpMotivation => '像专业人士一样追踪卡路里\n你梦想的身材越来越近了！';

  @override
  String tierUpReward(int reward) {
    return '+${reward}E 奖励！';
  }

  @override
  String get referralAllLevelsClaimed => '所有级别均已领取！';

  @override
  String referralLevel(int level, String subtitle) {
    return '等级$level：$subtitle';
  }

  @override
  String referralProgress(int current, int target, int level, int total) {
    return '[$current/$target]（级别 $level/$total）';
  }

  @override
  String referralClaimedLevel(int level, int reward) {
    return '🎁 声称等级 $level：+$reward 能量！';
  }

  @override
  String get challengeUseAi10 => '使用能量 10';

  @override
  String get specifyIngredients => '指定已知成分';

  @override
  String get specifyIngredientsOptional => '指定已知成分（可选）';

  @override
  String get specifyIngredientsHint => '输入你知道的配料，人工智能就会为你发现隐藏的调味料、油和酱汁。';

  @override
  String get sendToAi => '发送至人工智能';

  @override
  String get reanalyzeWithIngredients => '添加成分并重新分析';

  @override
  String get reanalyzeButton => '重新分析（1 能量）';

  @override
  String get ingredientsSaved => '保存食材';

  @override
  String get pleaseAddAtLeastOneIngredient => '请添加至少 1 种成分';

  @override
  String get hiddenIngredientsDiscovered => 'AI发现的隐藏成分';

  @override
  String get retroScanTitle => '扫描最近的照片？';

  @override
  String get retroScanDescription => '我们可以扫描您过去 7 天的照片，自动查找食物照片并将其添加到您的日记中。';

  @override
  String get retroScanNote => '仅检测到食物照片 - 其他照片将被忽略。没有照片离开您的设备。';

  @override
  String get retroScanStart => '扫描我的照片';

  @override
  String get retroScanSkip => '暂时跳过';

  @override
  String get retroScanInProgress => '扫描...';

  @override
  String get retroScanTagline => 'MiRO 正在改变您的\n食物照片转化为健康数据。';

  @override
  String get retroScanFetchingPhotos => '正在获取最近的照片...';

  @override
  String get retroScanAnalyzing => '正在检测食物照片...';

  @override
  String retroScanPhotosFound(int count) {
    return '过去 7 天内找到的 $count 照片';
  }

  @override
  String get retroScanCompleteTitle => '扫描完成！';

  @override
  String retroScanCompleteDesc(int count) {
    return '找到 $count 食物照片！它们已添加到您的时间线中，准备进行 AI 分析。';
  }

  @override
  String get retroScanNoResultsTitle => '未找到食物照片';

  @override
  String get retroScanNoResultsDesc => '过去 7 天内未检测到任何食物照片。尝试拍摄下一顿饭的照片！';

  @override
  String get retroScanAnalyzeHint => '点击时间线上的“全部分析”即可获取这些条目的人工智能营养分析。';

  @override
  String get retroScanDone => '知道了！';

  @override
  String get welcomeEndTitle => '欢迎来到MiRO！';

  @override
  String get welcomeEndMessage => 'MiRO 竭诚为您服务。';

  @override
  String get welcomeEndJourney => '祝大家旅途愉快！！';

  @override
  String get welcomeEndStart => '让我们开始吧！';

  @override
  String greetingCalorieSummary(
      int remaining, int protein, int carbs, int fat) {
    return '你好！今天我能为您提供什么帮助？您还剩下 $remaining kcal。到目前为止：Protein ${protein}g，碳水化合物${carbs}g，脂肪${fat}g。告诉我你吃了什么——按餐列出所有内容，我会为你全部记录下来。更详细更精准！！';
  }

  @override
  String greetingCuisineTip(String cuisine) {
    return '您的首选美食设置为 $cuisine。您可以随时在“设置”中更改它！';
  }

  @override
  String greetingEnergyTip(int balance) {
    return '您有 $balance 可用能量。不要忘记在能量徽章上领取每日连胜奖励！';
  }

  @override
  String get greetingRenamePhotoTip => '提示：您可以重命名食物照片以帮助MiRO更准确地分析！';

  @override
  String get greetingAddIngredientsTip =>
      '提示：您可以添加您确定的成分，然后发送到 MiRO 进行分析。我会为你找出所有无聊的小细节！';

  @override
  String greetingBackupReminder(int days) {
    return '嘿老板！您已经 $days 天没有备份数据。我建议在“设置”中进行备份 - 您的数据存储在本地，如果发生问题我无法恢复！';
  }

  @override
  String get greetingFallback => '你好！今天我能为您提供什么帮助？告诉我你吃了什么！';

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
      '提供食物名称、数量并选择是食物还是产品将提高AI准确性。';

  @override
  String get hideDetails => 'Hide details';

  @override
  String get showDetails => 'Show details';

  @override
  String get searchModeLabel => '搜索模式';

  @override
  String get normalFood => '食物';

  @override
  String get normalFoodDesc => '普通家常食物';

  @override
  String get packagedProduct => '产品';

  @override
  String get packagedProductDesc => '带营养标签的包装产品';

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
