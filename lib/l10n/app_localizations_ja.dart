// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class L10nJa extends L10n {
  L10nJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'MiRO';

  @override
  String get save => '保存';

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete => '消去';

  @override
  String get edit => '編集';

  @override
  String get search => '検索';

  @override
  String get loading => '読み込み中...';

  @override
  String get error => 'エラーが発生しました';

  @override
  String get confirm => '確認する';

  @override
  String get close => '近い';

  @override
  String get done => '終わり';

  @override
  String get next => '次';

  @override
  String get skip => 'スキップ';

  @override
  String get retry => 'リトライ';

  @override
  String get ok => 'わかりました';

  @override
  String get foodName => '食品名';

  @override
  String get calories => 'カロリー';

  @override
  String get protein => 'Proテイン';

  @override
  String get carbs => '炭水化物';

  @override
  String get fat => '脂肪';

  @override
  String get servingSize => '1回分の分量';

  @override
  String get servingUnit => 'ユニット';

  @override
  String get kcal => 'kcal';

  @override
  String get mealBreakfast => '朝食';

  @override
  String get mealLunch => 'ランチ';

  @override
  String get mealDinner => '夕食';

  @override
  String get mealSnack => 'スナック';

  @override
  String get todaySummary => '今日のまとめ';

  @override
  String get nutritionSummary => 'Nutrition Summary';

  @override
  String dateSummary(String date) {
    return '$date の概要';
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
  String get savedSuccess => '正常に保存されました';

  @override
  String get deletedSuccess => '正常に削除されました';

  @override
  String get pleaseEnterFoodName => '食品名を入力してください';

  @override
  String get noDataYet => 'まだデータがありません';

  @override
  String get addFood => '食べ物を追加する';

  @override
  String get editFood => '食べ物を編集する';

  @override
  String get deleteFood => '食べ物を削除する';

  @override
  String get deleteConfirm => '削除を確認しますか?';

  @override
  String get foodLoggedSuccess => '食事が記録されました！';

  @override
  String get noApiKey => 'Gemini API Key を設定してください';

  @override
  String get noApiKeyDescription => 'Profile → API 設定する設定に移動します';

  @override
  String get apiKeyTitle => 'Gemini API Key のセットアップ';

  @override
  String get apiKeyRequired => 'API Key が必要です';

  @override
  String get apiKeyFreeNote => 'Gemini API は無料で使用できます';

  @override
  String get apiKeySetup => 'API Key をセットアップする';

  @override
  String get testConnection => 'テスト接続';

  @override
  String get connectionSuccess => '無事接続されました！すぐに使用できます';

  @override
  String get connectionFailed => '接続に失敗しました';

  @override
  String get pasteKey => 'ペースト';

  @override
  String get deleteKey => 'API Keyを削除';

  @override
  String get openAiStudio => 'Google AI Studio を開く';

  @override
  String get chatHint => 'Miro に伝えます。例: 「丸太チャーハン」…';

  @override
  String get chatFoodSaved => '食事が記録されました！';

  @override
  String chatFoodSavedDetail(
      String name, String serving, String unit, String cal) {
    return '$name $serving $unit\n$cal kcal';
  }

  @override
  String get featureNotAvailable => '申し訳ありませんが、この機能はまだ利用できません';

  @override
  String get goalCalories => 'カロリー/日';

  @override
  String get goalProtein => 'Proテイン/日';

  @override
  String get goalCarbs => '炭水化物/日';

  @override
  String get goalFat => '脂肪/日';

  @override
  String get goalWater => '水/日';

  @override
  String get healthGoals => '健康の目標';

  @override
  String get profile => 'Proファイル';

  @override
  String get settings => '設定';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get termsOfService => '利用規約';

  @override
  String get clearAllData => 'すべてのデータをクリア';

  @override
  String get clearAllDataConfirm => 'すべてのデータが削除されます。これは取り消しできません!';

  @override
  String get about => 'について';

  @override
  String get language => '言語';

  @override
  String get upgradePro => 'Pro にアップグレードする';

  @override
  String get proUnlocked => 'MiRO Pro';

  @override
  String get proDescription => '無制限のAI食品分析';

  @override
  String aiRemaining(int remaining, int total) {
    return 'AI 分析: 今日は残り $remaining/$total';
  }

  @override
  String get aiLimitReached => '本日（3/3）のAI制限に達しました';

  @override
  String get restorePurchase => '購入を復元する';

  @override
  String get myMeals => '私の食事:';

  @override
  String get createMeal => '食事を作成する';

  @override
  String get ingredients => 'Ingredients';

  @override
  String get searchFood => '食べ物を探す';

  @override
  String get analyzing => '分析中...';

  @override
  String get analyzeWithAi => 'AIで分析する';

  @override
  String get analysisComplete => '分析完了';

  @override
  String get timeline => 'タイムライン';

  @override
  String get diet => 'ダイエット';

  @override
  String get quickAdd => 'クイック追加';

  @override
  String get welcomeTitle => 'MiRO';

  @override
  String get welcomeSubtitle => 'AIを活用した簡単な食事記録';

  @override
  String get onboardingFeature1 => '写真を撮る';

  @override
  String get onboardingFeature1Desc => 'AIがカロリーを自動計算';

  @override
  String get onboardingFeature2 => 'ログに入力します';

  @override
  String get onboardingFeature2Desc => '「チャーハンを食べた」と言うと記録されます';

  @override
  String get onboardingFeature3 => '毎日のサマリー';

  @override
  String get onboardingFeature3Desc => 'kcal、タンパク質、炭水化物、脂肪を追跡します';

  @override
  String get basicInfo => '基本情報';

  @override
  String get basicInfoDesc => '1日の推奨カロリーを計算するには';

  @override
  String get gender => '性別';

  @override
  String get male => '男';

  @override
  String get female => '女性';

  @override
  String get age => '年';

  @override
  String get weight => '重さ';

  @override
  String get height => '身長';

  @override
  String get activityLevel => '活動レベル';

  @override
  String tdeeResult(int kcal) {
    return 'あなたの TDEE: $kcal kcal/日';
  }

  @override
  String get setupAiTitle => 'Gemini AI をセットアップする';

  @override
  String get setupAiDesc => '写真を撮るとAIが自動分析';

  @override
  String get setupNow => '今すぐセットアップ';

  @override
  String get skipForNow => '今のところスキップしてください';

  @override
  String get errorTimeout => '接続タイムアウト — もう一度お試しください';

  @override
  String get errorInvalidKey => '無効な API Key — 設定を確認してください';

  @override
  String get errorNoInternet => 'インターネット接続がありません';

  @override
  String get errorGeneral => 'エラーが発生しました - もう一度試してください';

  @override
  String get errorQuotaExceeded => 'API クォータを超えました — 待ってから再試行してください';

  @override
  String get apiKeyScreenTitle => 'Gemini API Key のセットアップ';

  @override
  String get analyzeFoodWithAi => 'AIで食品を分析する';

  @override
  String get analyzeFoodWithAiDesc =>
      '写真を撮る → AIがカロリーを自動計算\nGemini API は無料で使用できます。';

  @override
  String get openGoogleAiStudio => 'Google AI Studio を開く';

  @override
  String get step1Title => 'Google AI Studio を開く';

  @override
  String get step1Desc => 'API Key を作成するには、下のボタンをクリックしてください';

  @override
  String get step2Title => 'Google アカウントでサインインする';

  @override
  String get step2Desc => 'Gmail または Google アカウントを使用します (お持ちでない場合は無料で作成します)';

  @override
  String get step3Title => '「API Keyの作成」をクリックします。';

  @override
  String get step3Desc =>
      '青い「API Keyを作成」ボタンをクリックします。\nProject を選択するよう求められたら → 「Create API key in new project」をクリックします。';

  @override
  String get step4Title => 'キーをコピーして下に貼り付けます';

  @override
  String get step4Desc =>
      '作成したキーの横にある「コピー」をクリックします\nキーは次のようになります: AIzaSyxxxx...';

  @override
  String get step5Title => 'ここにAPI Keyを貼り付けてください';

  @override
  String get pasteApiKeyHint => 'コピーした API Key を貼り付けます';

  @override
  String get saveApiKey => 'API Key を保存';

  @override
  String get testingConnection => 'テスト中...';

  @override
  String get deleteApiKey => 'API Keyを削除';

  @override
  String get deleteApiKeyConfirm => 'API Key を削除しますか?';

  @override
  String get deleteApiKeyConfirmDesc => '再度設定するまでAI食品分析を使用することはできません';

  @override
  String get apiKeySaved => 'API Key は正常に保存されました';

  @override
  String get apiKeyDeleted => 'API Key は正常に削除されました';

  @override
  String get pleasePasteApiKey => '最初にAPI Keyを貼り付けてください';

  @override
  String get apiKeyInvalidFormat => '無効な API Key — 「AIza」で始まる必要があります';

  @override
  String get connectionSuccessMessage => '✅ 正常に接続されました！すぐに使用できます';

  @override
  String get connectionFailedMessage => '❌ 接続に失敗しました';

  @override
  String get faqTitle => 'よくある質問';

  @override
  String get faqFreeQuestion => '本当に無料ですか?';

  @override
  String get faqFreeAnswer =>
      'はい！ Gemini 2.0 Flash は 1 日あたり 1,500 リクエストまで無料\n食事ログの場合（1日5～15回） → 永久無料、支払い不要';

  @override
  String get faqSafeQuestion => '安全ですか？';

  @override
  String get faqSafeAnswer =>
      'API Key はデバイスのセキュア ストレージにのみ保存されます\nアプリがサーバーにキーを送信しません\nキーが漏洩した場合 → 削除して新しいキーを作成します (Google パスワードではありません)';

  @override
  String get faqNoKeyQuestion => 'キーを作成しない場合はどうなりますか?';

  @override
  String get faqNoKeyAnswer =>
      'アプリはまだ使えます！しかし:\n❌ 写真撮影不可 → AI解析\n✅ 食事を手動で記録できます\n✅ クイック追加機能\n✅ kcal/マクロ概要の作品を表示';

  @override
  String get faqCreditCardQuestion => 'クレジットカードは必要ですか?';

  @override
  String get faqCreditCardAnswer => 'いいえ — クレジット カードなしで API Key を無料で作成します';

  @override
  String get navDashboard => 'ダッシュボード';

  @override
  String get navMyMeals => '私の食事';

  @override
  String get navCamera => 'カメラ';

  @override
  String get navGallery => 'Gallery';

  @override
  String get navAiChat => 'AIチャット';

  @override
  String get navProfile => 'Proファイル';

  @override
  String get appBarTodayIntake => '今日の摂取量';

  @override
  String get appBarMyMeals => '私の食事';

  @override
  String get appBarCamera => 'カメラ';

  @override
  String get appBarAiChat => 'AIチャット';

  @override
  String get appBarMiro => 'ミロ';

  @override
  String get permissionRequired => '許可が必要です';

  @override
  String get permissionRequiredDesc => 'MIRO は次のものにアクセスする必要があります。';

  @override
  String get permissionPhotos => '写真 — 食べ物をスキャンするため';

  @override
  String get permissionCamera => 'カメラ — 食べ物の写真を撮るため';

  @override
  String get permissionSkip => 'スキップ';

  @override
  String get permissionAllow => '許可する';

  @override
  String get permissionAllGranted => '付与されたすべての権限';

  @override
  String permissionDenied(String denied) {
    return '許可が拒否されました: $denied';
  }

  @override
  String get openSettings => '設定を開く';

  @override
  String get exitAppTitle => 'アプリを終了しますか?';

  @override
  String get exitAppMessage => '終了してもよろしいですか?';

  @override
  String get exit => '出口';

  @override
  String get healthGoalsTitle => '健康の目標';

  @override
  String get healthGoalsInfo =>
      '毎日のカロリー目標、マクロ、食事ごとの予算を設定します。\n自動計算にロック: 2 つのマクロまたは 3 つの食事。';

  @override
  String get dailyCalorieGoal => '毎日のカロリー目標';

  @override
  String get proteinLabel => 'Proテイン';

  @override
  String get carbsLabel => '炭水化物';

  @override
  String get fatLabel => '脂肪';

  @override
  String get autoBadge => '自動';

  @override
  String kcalPerGram(int kcalPerGram, int kcal) {
    return '$kcalPerGram kcal/g • $kcal __SW0__';
  }

  @override
  String get mealCalorieBudget => '食事カロリーの予算';

  @override
  String mealBudgetBalanced(int total, int goal) {
    return '合計 $total kcal = 目標 $goal __SW0__';
  }

  @override
  String mealBudgetRemaining(int total, int goal, int remaining) {
    return '合計 $total / $goal kcal (残り $remaining)';
  }

  @override
  String get lockMealsHint => '3 食をロックして 4 食目を自動計算';

  @override
  String get breakfastLabel => '朝食';

  @override
  String get lunchLabel => 'ランチ';

  @override
  String get dinnerLabel => '夕食';

  @override
  String get snackLabel => 'スナック';

  @override
  String percentOfDailyGoal(String percent) {
    return '1 日の目標の $percent%';
  }

  @override
  String get smartSuggestionRange => 'スマートな提案範囲';

  @override
  String get smartSuggestionHow => 'スマートサジェストはどのように機能しますか?';

  @override
  String smartSuggestionDesc(int threshold, int min, int max) {
    return 'マイミール、食材、昨日の食事から1食あたりの予算に合わせた料理を提案します。\n\nこのしきい値は、提案の柔軟性を制御します。たとえば、ランチの予算が 700 kcal で、しきい値が $threshold __SW0__ の場合、$min ～ $max __SW0__ の間の料理が提案されます。';
  }

  @override
  String get suggestionThreshold => '提案のしきい値';

  @override
  String suggestionThresholdDesc(int threshold) {
    return '食事予算から± $threshold kcal 分の食品を許可する';
  }

  @override
  String get goalsSavedSuccess => '目標は正常に保存されました。';

  @override
  String get canOnlyLockTwoMacros => '一度にロックできるマクロは 2 つだけです';

  @override
  String get canOnlyLockThreeMeals => 'ロックできるのは 3 食のみです。 4番目は自動計算されます';

  @override
  String get tabMeals => '食事';

  @override
  String get tabIngredients => '材料';

  @override
  String get searchMealsOrIngredients => '食事や食材を検索...';

  @override
  String get createNewMeal => '新しい食事を作成する';

  @override
  String get addIngredient => '成分を追加する';

  @override
  String get noMealsYet => 'まだ食事はありません';

  @override
  String get noMealsYetDesc => 'AIで食事を分析して食事を自動保存\nまたは手動で作成します';

  @override
  String get noIngredientsYet => 'まだ材料がありません';

  @override
  String get noIngredientsYetDesc => 'AIで食品を分析すると\n材料は自動的に保存されます';

  @override
  String mealCreated(String name) {
    return '「$name」を作成しました';
  }

  @override
  String mealLogged(String name) {
    return '「$name」が記録されました';
  }

  @override
  String ingredientAmount(String unit) {
    return '金額 ($unit)';
  }

  @override
  String ingredientLogged(String name, String amount, String unit) {
    return 'ログに記録された「$name」 $amount$unit';
  }

  @override
  String get mealNotFound => '食事が見つかりません';

  @override
  String mealUpdated(String name) {
    return '「$name」を更新しました';
  }

  @override
  String get deleteMealTitle => '食事を削除しますか?';

  @override
  String deleteMealMessage(String name) {
    return '「$name」';
  }

  @override
  String get deleteMealNote => '成分は削除されません。';

  @override
  String get mealDeleted => '食事が削除されました';

  @override
  String ingredientCreated(String name) {
    return '「$name」を作成しました';
  }

  @override
  String get ingredientNotFound => '成分が見つかりません';

  @override
  String ingredientUpdated(String name) {
    return '「$name」を更新しました';
  }

  @override
  String get deleteIngredientTitle => '成分を削除しますか?';

  @override
  String deleteIngredientMessage(String name) {
    return '「$name」';
  }

  @override
  String get ingredientDeleted => '成分が削除されました';

  @override
  String get noIngredientsData => '成分データなし';

  @override
  String ingredientDetail(String name, String amount, String unit) {
    return '$name ($amount $unit)';
  }

  @override
  String ingredientCalories(int calories) {
    return '$calories kcal';
  }

  @override
  String get useThisMeal => 'この食事を使用してください';

  @override
  String errorLoading(String error) {
    return '読み込みエラー: $error';
  }

  @override
  String scanFoundNewImages(int count, String date) {
    return '$date で $count 件の新しい画像が見つかりました';
  }

  @override
  String scanNoNewImages(String date) {
    return '$date には新しい画像が見つかりませんでした';
  }

  @override
  String aiAnalysisRemaining(int remaining, int total) {
    return 'AI 分析: 今日は残り $remaining/$total';
  }

  @override
  String get upgradeToProUnlimited => 'Pro にアップグレードすると無制限に使用できます';

  @override
  String get upgrade => 'アップグレード';

  @override
  String get confirmDelete => '削除の確認';

  @override
  String confirmDeleteMessage(String name) {
    return '「$name」を削除しますか?';
  }

  @override
  String get entryDeletedSuccess => '✅ エントリが正常に削除されました';

  @override
  String entryDeleteError(String error) {
    return '❌ エラー: $error';
  }

  @override
  String batchAnalyzeItems(int count) {
    return '$count アイテム (バッチ)';
  }

  @override
  String analyzeCancelled(int success) {
    return 'キャンセルされました — $success アイテムは正常に分析されました';
  }

  @override
  String analyzeSuccessAll(int success) {
    return '✅ $success 項目を正常に分析しました';
  }

  @override
  String analyzeSuccessPartial(int success, int total, int failed) {
    return '⚠️ $success/$total 項目を分析しました ($failed は失敗しました)';
  }

  @override
  String analyzeProgress(String item, int current, int total) {
    return '$item ($current/$total)';
  }

  @override
  String get pullToScanMeal => '引いて食事をスキャンします';

  @override
  String get analyzeAll => 'すべて分析する';

  @override
  String get addFoodTitle => '食べ物を追加する';

  @override
  String get foodNameRequired => '食品名 *';

  @override
  String get foodNameHint => '検索するには次のように入力します。チャーハン、パパイヤサラダ';

  @override
  String get selectedFromMyMeal => '✅ 私の食事から選択 — 栄養データは自動入力されます';

  @override
  String get foundInDatabase => '✅ データベースで見つかりました - 栄養データは自動入力されます';

  @override
  String get saveAndAnalyze => '保存と分析';

  @override
  String get notFoundInDatabase => 'データベースに見つかりません - バックグラウンドで分析されます';

  @override
  String get amountLabel => '額';

  @override
  String get unitLabel => 'ユニット';

  @override
  String get nutritionAutoCalculated => '栄養成分（量により自動計算）';

  @override
  String get nutritionEnterZero => '栄養成分（不明な場合は0を入力してください）';

  @override
  String get caloriesLabel => 'カロリー (kcal)';

  @override
  String get proteinLabelShort => 'Proテイン (g)';

  @override
  String get carbsLabelShort => '炭水化物 (g)';

  @override
  String get fatLabelShort => '脂肪(g)';

  @override
  String get mealTypeLabel => '食事の種類';

  @override
  String get pleaseEnterFoodNameFirst => '最初に食品名を入力してください';

  @override
  String get savedAnalyzingBackground => '✅ 保存済み — バックグラウンドで分析中';

  @override
  String get foodAdded => '✅ 食品追加';

  @override
  String get suggestionSourceMyMeal => '私の食事';

  @override
  String get suggestionSourceIngredient => '材料';

  @override
  String get suggestionSourceDatabase => 'データベース';

  @override
  String get editFoodTitle => '食べ物を編集する';

  @override
  String get foodNameLabel => '食品名';

  @override
  String get changeAmountAutoUpdate => '量変更→カロリー自動更新';

  @override
  String baseNutrition(int calories, String unit) {
    return 'ベース: $calories kcal / 1 $unit';
  }

  @override
  String get calculatedFromIngredients => '下記成分より算出';

  @override
  String get ingredientsEditable => '材料（編集可能）';

  @override
  String get addIngredientButton => '追加';

  @override
  String get noIngredientsAddHint => '材料はありません — 新しいものを追加するには「追加」をタップします';

  @override
  String get editIngredientsHint => '名前/金額を編集→検索アイコンをタップしてデータベースまたはAIを検索します';

  @override
  String get ingredientNameHint => '例えば鶏の卵';

  @override
  String get searchDbOrAi => '検索DB・AI';

  @override
  String get amountHint => '額';

  @override
  String get fromDatabase => 'データベースから';

  @override
  String subIngredients(int count) {
    return '副成分 ($count)';
  }

  @override
  String get addSubIngredient => '追加';

  @override
  String get subIngredientNameHint => '副成分名';

  @override
  String get amountShort => 'アムト';

  @override
  String get pleaseEnterSubIngredientName => '最初に副成分名を入力してください';

  @override
  String foundInDatabaseSub(String name) {
    return 'データベースに「$name」が見つかりました!';
  }

  @override
  String aiAnalyzedSub(String name) {
    return 'AIが分析した「$name」（エネルギー-1）';
  }

  @override
  String get couldNotAnalyzeSub => '副成分を分析できませんでした';

  @override
  String get pleaseEnterIngredientName => '原材料名を入力してください';

  @override
  String get reAnalyzeTitle => '再分析しますか？';

  @override
  String reAnalyzeMessage(String name) {
    return '「$name」にはすでに栄養データが含まれています。\n\n再度分析するとエネルギーを1消費します。\n\n続く？';
  }

  @override
  String get reAnalyzeButton => '再分析（1エネルギー）';

  @override
  String get amountNotSpecified => '金額は指定されていません';

  @override
  String amountNotSpecifiedMessage(String name) {
    return '最初に「$name」の金額を指定してください\nそれともデフォルトの 100 g を使用しますか?';
  }

  @override
  String get useDefault100g => '100g使用';

  @override
  String aiAnalyzedResult(String name, int calories) {
    return 'AI: \"$name\" → $calories kcal';
  }

  @override
  String get unableToAnalyze => '分析できません';

  @override
  String get today => '今日';

  @override
  String get savedSuccessfully => '✅ 正常に保存されました';

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
  String get confirmFoodPhoto => '食べ物の写真を確認する';

  @override
  String get photoSavedAutomatically => '写真が自動的に保存されました';

  @override
  String get foodNameHintExample => '例：グリルチキンサラダ';

  @override
  String get quantityLabel => '量';

  @override
  String get quantityHint => '1';

  @override
  String get optionalFoodInfo => '食品名と数量の入力は任意ですが、入力することでAIの解析精度が向上します。';

  @override
  String get saveOnly => '保存のみ';

  @override
  String get pleaseEnterValidQuantity => '有効な数量を入力してください';

  @override
  String analyzedResult(String name, int calories) {
    return '✅ 分析済み: $name — $calories kcal';
  }

  @override
  String get couldNotAnalyzeSaved =>
      '⚠️ 分析できませんでした — 保存されました。後で「すべて分析」を使用してください';

  @override
  String get savedAnalyzeLater => '✅ 保存済み — 後で「すべて分析」を使用して分析します';

  @override
  String get editIngredientTitle => '成分の編集';

  @override
  String get ingredientNameRequired => '成分名 *';

  @override
  String get baseAmountLabel => '基本金額';

  @override
  String get baseAmountHint => '100';

  @override
  String nutritionPerBase(String amount, String unit) {
    return '$amount $unit あたりの栄養';
  }

  @override
  String nutritionCalculatedPerBase(String amount, String unit) {
    return '$amount $unit ごとに栄養成分を計算 — システムは実際の消費量に基づいて自動計算します';
  }

  @override
  String get createIngredient => '材料の作成';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get pleaseEnterIngredientNameFirst => '最初に成分名を入力してください';

  @override
  String aiAnalyzedIngredient(
      String name, String amount, String unit, int calories) {
    return 'AI: 「$name」 $amount $unit → $calories kcal';
  }

  @override
  String get unableToFindIngredient => 'この成分が見つかりません';

  @override
  String searchFailed(String error) {
    return '検索に失敗しました: $error';
  }

  @override
  String deleteEntriesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Entries',
      one: 'Entry',
    );
    return '$count $_temp0 を削除しますか?';
  }

  @override
  String deleteEntriesMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return '$count 選択した食品 $_temp0 を削除しますか?';
  }

  @override
  String get deleteAll => 'すべて削除';

  @override
  String deletedEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return '$count $_temp0 を削除しました';
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
    return '$count $_temp0 を $date に移動しました';
  }

  @override
  String get allSelectedAlreadyAnalyzed => '選択したすべてのエントリはすでに分析されています';

  @override
  String analyzeCancelledSelected(int success) {
    return 'キャンセルされました — $success が分析されました';
  }

  @override
  String analyzedEntriesAll(int success) {
    String _temp0 = intl.Intl.pluralLogic(
      success,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return '分析済み $success $_temp0';
  }

  @override
  String analyzedEntriesPartial(int success, int total, int failed) {
    return '$success/$total を分析しました ($failed は失敗しました)';
  }

  @override
  String analyzeProgressSelected(int current, int total, String item) {
    return '$current/$total $item';
  }

  @override
  String get noEntriesYet => 'まだエントリーはありません';

  @override
  String get selectAll => 'すべて選択';

  @override
  String get deselectAll => 'すべての選択を解除します';

  @override
  String get moveToDate => '現在までに移動';

  @override
  String get analyzeSelected => 'Analyze';

  @override
  String get deleteTooltip => '消去';

  @override
  String get move => '動く';

  @override
  String get deleteTooltipAction => '消去';

  @override
  String switchToModeTitle(String mode) {
    return '$mode モードに切り替えますか?';
  }

  @override
  String switchToModeMessage(String current, String newMode) {
    return 'この項目は__P​​H0__として分析されました。\n\n$newMode として再分析すると、エネルギーが 1 消費されます。\n\n続く？';
  }

  @override
  String analyzingAsMode(String mode) {
    return '$mode として分析しています...';
  }

  @override
  String reAnalyzedAsMode(String mode) {
    return '✅ $mode として再分析';
  }

  @override
  String get analysisFailed => '❌ 分析に失敗しました';

  @override
  String get aiAnalysisComplete => '✅ AIが分析して保存';

  @override
  String get changeMealType => '食事の種類を変更する';

  @override
  String get moveToAnotherDate => '別の日付に移動';

  @override
  String currentDate(String date) {
    return '現在: $date';
  }

  @override
  String get cancelDateChange => '日付変更のキャンセル';

  @override
  String get undo => '元に戻す';

  @override
  String get chatHistory => 'チャット履歴';

  @override
  String get newChat => '新しいチャット';

  @override
  String get quickActions => 'クイックアクション';

  @override
  String get clear => 'クリア';

  @override
  String get helloImMiro => 'こんにちは！私はMiroです';

  @override
  String get tellMeWhatYouAteToday => '今日何を食べたか教えてください！';

  @override
  String get tellMeWhatYouAte => '何を食べたか教えてください...';

  @override
  String get clearHistoryTitle => '履歴をクリアしますか？';

  @override
  String get clearHistoryMessage => 'このセッション内のすべてのメッセージが削除されます。';

  @override
  String get chatHistoryTitle => 'チャット履歴';

  @override
  String get newLabel => '新しい';

  @override
  String get noChatHistoryYet => 'チャット履歴はまだありません';

  @override
  String get active => 'アクティブ';

  @override
  String get deleteChatTitle => 'チャットを削除しますか?';

  @override
  String deleteChatMessage(String title) {
    return '「$title」を削除しますか?';
  }

  @override
  String weeklySummaryTitle(String start, String end) {
    return '📊 週次サマリー ($start - $end)';
  }

  @override
  String daySummary(String day, String calories, String emoji, String diff) {
    return '📅 $day: $calories kcal $emoji ($diff)';
  }

  @override
  String overTarget(String amount) {
    return '$amount 目標を上回りました';
  }

  @override
  String underTarget(String amount) {
    return '$amount は目標を下回っています';
  }

  @override
  String get noFoodLoggedThisWeek => '今週はまだ食事が記録されていません。';

  @override
  String averageKcalPerDay(String average) {
    return '🔥 平均: $average kcal/日';
  }

  @override
  String targetKcalPerDay(String target) {
    return '🎯 目標: $target kcal/日';
  }

  @override
  String resultOverTarget(String amount) {
    return '📈 結果: $amount kcal 目標を上回りました';
  }

  @override
  String resultUnderTarget(String amount) {
    return '📈 結果: $amount kcal は目標を下回りました — 素晴らしい仕事でした! 💪';
  }

  @override
  String failedToLoadWeeklySummary(String error) {
    return '❌ 週次サマリーのロードに失敗しました: $error';
  }

  @override
  String monthlySummaryTitle(String month, int year) {
    return '📊 月次サマリー ($month $year)';
  }

  @override
  String totalDays(int days) {
    return '📅 合計日数: $days';
  }

  @override
  String totalConsumed(String calories) {
    return '🔥 合計消費量: $calories kcal';
  }

  @override
  String targetTotal(String target) {
    return '🎯 目標合計: $target kcal';
  }

  @override
  String averageKcalPerDayShort(String average) {
    return '📈 平均: $average kcal/日';
  }

  @override
  String overTargetThisMonth(String amount) {
    return '⚠️ $amount kcal 今月の目標を超えました';
  }

  @override
  String underTargetThisMonth(String amount) {
    return '✅ $amount kcal は目標を下回りました — 素晴らしいです! 💪';
  }

  @override
  String failedToLoadMonthlySummary(String error) {
    return '❌ 月次サマリーのロードに失敗しました: $error';
  }

  @override
  String get localAiHelpTitle => '🤖 ローカル AI ヘルプ';

  @override
  String get localAiHelpFormat => '形式: [食品] [量] [単位]';

  @override
  String get localAiHelpExamples =>
      '例:\n• 鶏肉 100g、米 200g\n• ピザ2枚\n• リンゴ 1個、バナナ 1個';

  @override
  String get localAiHelpNote =>
      '注: 英語のみ、基本的な解析\nより良い結果を得るには、Miro AI に切り替えてください。';

  @override
  String hiNoFoodLogged(String target) {
    return '🤖 こんにちは！今日はまだ食事が記録されていません。\n   ターゲット: $target kcal — ロギングを開始する準備はできましたか? 🍽️';
  }

  @override
  String hiKcalLeft(String remaining) {
    return '🤖 こんにちは！今日は $remaining kcal が残っています。\n   食事を記録する準備はできましたか? 😊';
  }

  @override
  String hiOverTarget(String calories, String over) {
    return '🤖 こんにちは！今日は$calories kcalを消費しました。\n   $over __SW0__ 目標を上回りました — 追跡を続けましょう! 💪';
  }

  @override
  String get hiReadyToLog => '🤖 こんにちは！食事を記録する準備はできましたか? 😊';

  @override
  String get notEnoughEnergy => 'エネルギーが足りない';

  @override
  String get thinkingMealIdeas => '🤖 あなたのための素晴らしい食事のアイデアを考えています...';

  @override
  String get recentMeals => '最近の食事:';

  @override
  String get noRecentFood => '最近の食事の記録はありません。';

  @override
  String remainingCaloriesToday(String remaining) {
    return '。今日の残りカロリー: $remaining kcal。';
  }

  @override
  String failedToGetMenuSuggestions(String error) {
    return '❌ メニューの提案を取得できませんでした: $error';
  }

  @override
  String get mealSuggestionsTitle => '🤖 あなたの食事記録に基づいて、ここに 3 つの食事の提案があります:';

  @override
  String mealSuggestionItem(
      int index, String emoji, String name, String calories) {
    return '$index。 $emoji $name (~$calories kcal)';
  }

  @override
  String mealSuggestionMacros(String protein, String carbs, String fat) {
    return 'P: ${protein}g | C: ${carbs}g | F: ${fat}g';
  }

  @override
  String get pickOneAndLog => '1 つ選んでください。記録させていただきます。 😊';

  @override
  String energyCost(int cost) {
    return '⚡ -$cost エネルギー';
  }

  @override
  String get giveMeTipsForHealthyEating => '健康的な食事のヒントを教えてください';

  @override
  String get howManyCaloriesToday => '今日のカロリーはどれくらいですか？';

  @override
  String get menuLabel => 'メニュー';

  @override
  String get weeklyLabel => '毎週';

  @override
  String get monthlyLabel => '毎月';

  @override
  String get tipsLabel => 'ヒント';

  @override
  String get summaryLabel => 'まとめ';

  @override
  String get helpLabel => 'ヘルプ';

  @override
  String get onboardingWelcomeSubtitle => 'カロリーを簡単に追跡\nAIを活用した分析による';

  @override
  String get onboardingSnap => 'スナップ';

  @override
  String get onboardingSnapDesc => 'AIが瞬時に分析';

  @override
  String get onboardingType => 'タイプ';

  @override
  String get onboardingTypeDesc => '数秒でログイン';

  @override
  String get onboardingEdit => '編集';

  @override
  String get onboardingEditDesc => '精度を微調整する';

  @override
  String get onboardingNext => '次へ →';

  @override
  String get onboardingDisclaimer => 'AIによる推定データ。医学的なアドバイスではありません。';

  @override
  String get onboardingQuickSetup => 'クイックセットアップ';

  @override
  String get onboardingHelpAiUnderstand => 'AI があなたの食べ物をよりよく理解できるようにする';

  @override
  String get onboardingYourTypicalCuisine => 'あなたの典型的な料理:';

  @override
  String get onboardingDailyCalorieGoal => '毎日のカロリー目標 (オプション):';

  @override
  String get onboardingKcalPerDay => 'kcal/日';

  @override
  String get onboardingCalorieGoalHint => '2000年';

  @override
  String get onboardingCanChangeAnytime => 'これは、Profile 設定でいつでも変更できます。';

  @override
  String get onboardingYoureAllSet => '準備は完了です!';

  @override
  String get onboardingStartTracking =>
      '今日から食事の記録を始めましょう。\n写真を撮るか、食べたものを入力します。';

  @override
  String get onboardingWelcomeGift => 'ウェルカムギフト';

  @override
  String get onboardingFreeEnergy => '10 フリーエネルギー';

  @override
  String get onboardingFreeEnergyDesc => '= 開始するには 10 回の AI 分析';

  @override
  String get onboardingEnergyCost => '各分析には 1 エネルギーがかかります\n使えば使うほどお得になります！';

  @override
  String get onboardingStartTrackingButton => '追跡を開始してください! →';

  @override
  String get onboardingNoCreditCard => 'クレジットカード不要、隠れた手数料なし';

  @override
  String get cameraTakePhotoOfFood => '食べ物の写真を撮ってください';

  @override
  String get cameraFailedToInitialize => 'カメラの初期化に失敗しました';

  @override
  String get cameraFailedToCapture => '写真のキャプチャに失敗しました';

  @override
  String get cameraFailedToPickFromGallery => 'ギャラリーから画像を選択できませんでした';

  @override
  String get cameraProcessing => 'Pro処理中...';

  @override
  String get referralInviteFriends => '友達を招待する';

  @override
  String get referralYourReferralCode => 'あなたの紹介コード';

  @override
  String get referralLoading => '読み込み中...';

  @override
  String get referralCopy => 'コピー';

  @override
  String get referralShareCodeDescription =>
      'このコードを友達と共有してください! AIを3回使用すると、両方とも報酬を獲得できます!';

  @override
  String get referralEnterReferralCode => '紹介コードを入力してください';

  @override
  String get referralCodeHint => 'ミロ-XXXX-XXXX-XXXX';

  @override
  String get referralSubmitCode => 'コードを送信する';

  @override
  String get referralPleaseEnterCode => '紹介コードを入力してください';

  @override
  String get referralCodeAccepted => '紹介コード受付中！';

  @override
  String get referralCodeCopied => '紹介コードがクリップボードにコピーされました。';

  @override
  String referralEnergyBonus(int energy) {
    return '+$energy エネルギー!';
  }

  @override
  String get referralHowItWorks => '仕組み';

  @override
  String get referralStep1Title => '紹介コードを共有する';

  @override
  String get referralStep1Description => 'MiRO ID をコピーして友達と共有します';

  @override
  String get referralStep2Title => '友達があなたのコードを入力しました';

  @override
  String get referralStep2Description => '彼らはすぐに +20 エネルギーを獲得します';

  @override
  String get referralStep3Title => '友人が AI を 3 回使用しました';

  @override
  String get referralStep3Description => '3 つの AI 分析が完了すると';

  @override
  String get referralStep4Title => '報酬が得られます!';

  @override
  String get referralStep4Description => '+5 エネルギーを受け取ります!';

  @override
  String get tierBenefitsTitle => 'ティアの特典';

  @override
  String get tierBenefitsUnlockRewards => '報酬のロックを解除する\n毎日の連続記録あり';

  @override
  String get tierBenefitsKeepStreakDescription =>
      '連続記録を維持してより高いティアのロックを解除し、素晴らしい特典を獲得してください!';

  @override
  String get tierBenefitsHowItWorks => '仕組み';

  @override
  String get tierBenefitsDailyEnergyReward => '毎日のエネルギー報酬';

  @override
  String get tierBenefitsDailyEnergyDescription =>
      '少なくとも 1 日に 1 回は AI を使用して、ボーナス エネルギーを獲得してください。より高いレベル = より多くの毎日のエネルギー!';

  @override
  String get tierBenefitsPurchaseBonus => '購入特典';

  @override
  String get tierBenefitsPurchaseBonusDescription =>
      'ゴールドおよびダイヤモンド層は、購入するたびに追加のエネルギーを獲得します (10 ～ 20% 多く!)';

  @override
  String get tierBenefitsGracePeriod => '猶予期間';

  @override
  String get tierBenefitsGracePeriodDescription =>
      '連続記録を失わずに 1 日でも失敗しましょう。シルバー以上のティアは保護を受けられます!';

  @override
  String get tierBenefitsAllTiers => 'すべてのティア';

  @override
  String get tierBenefitsNew => '新しい';

  @override
  String get tierBenefitsPopular => '人気のある';

  @override
  String get tierBenefitsBest => '最高';

  @override
  String get tierBenefitsDailyCheckIn => '毎日のチェックイン';

  @override
  String get tierBenefitsProTips => 'Pro ヒント';

  @override
  String get tierBenefitsTip1 => '毎日 AI を使用して無料エネルギーを獲得し、連続記録を達成しましょう';

  @override
  String get tierBenefitsTip2 =>
      'ダイヤモンド層では、1 日あたり +4 エネルギーを獲得できます。つまり、1 か月あたり 120 エネルギーです。';

  @override
  String get tierBenefitsTip3 => '購入ボーナスはすべてのエネルギー パッケージに適用されます。';

  @override
  String get tierBenefitsTip4 => '一日欠席しても猶予期間が連続記録を保護します';

  @override
  String get subscriptionEnergyPass => 'エネルギーパス';

  @override
  String get subscriptionInAppPurchasesNotAvailable => 'アプリ内購入は利用できません';

  @override
  String get subscriptionFailedToInitiatePurchase => '購入を開始できませんでした';

  @override
  String subscriptionError(String error) {
    return 'エラー: $error';
  }

  @override
  String get subscriptionFailedToLoad => 'サブスクリプションの読み込みに失敗しました';

  @override
  String get subscriptionUnknownError => '不明なエラー';

  @override
  String get subscriptionRetry => 'リトライ';

  @override
  String get subscriptionEnergyPassActive => 'エナジーパス有効';

  @override
  String get subscriptionUnlimitedAccess => '無制限にアクセスできます';

  @override
  String get subscriptionStatus => '状態';

  @override
  String get subscriptionRenews => '更新します';

  @override
  String get subscriptionPrice => '価格';

  @override
  String get subscriptionYourBenefits => 'あなたのメリット';

  @override
  String get subscriptionManageSubscription => 'サブスクリプションの管理';

  @override
  String get subscriptionNoProductAvailable => '利用可能なサブスクリプション製品はありません';

  @override
  String get subscriptionWhatYouGet => '得られるもの';

  @override
  String get subscriptionPerMonth => '月あたり';

  @override
  String get subscriptionSubscribeNow => '今すぐ購読する';

  @override
  String get subscriptionSubscribe => 'Subscribe';

  @override
  String get subscriptionCancelAnytime => 'いつでもキャンセル可能';

  @override
  String get subscriptionAutoRenewTerms =>
      'サブスクリプションは自動的に更新されます。 Google Play からいつでもキャンセルできます。';

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
  String get disclaimerHealthDisclaimer => '健康に関する免責事項';

  @override
  String get disclaimerImportantReminders => '重要な注意事項:';

  @override
  String get disclaimerBullet1 => 'すべての栄養データは推定値です';

  @override
  String get disclaimerBullet2 => 'AI分析にはエラーが含まれる可能性があります';

  @override
  String get disclaimerBullet3 => '専門家のアドバイスに代わるものではありません';

  @override
  String get disclaimerBullet4 => '医療提供者に相談して医学的指導を受ける';

  @override
  String get disclaimerBullet5 => 'ご自身の判断とリスクでご使用ください';

  @override
  String get disclaimerIUnderstand => 'わかりました';

  @override
  String get privacyPolicyTitle => 'プライバシーポリシー';

  @override
  String get privacyPolicySubtitle => 'MiRO — 私の摂取記録 Oracle';

  @override
  String get privacyPolicyHeaderNote =>
      '食事データはデバイスに残ります。エネルギーバランスは Firebase 経由で安全に同期されます。';

  @override
  String get privacyPolicySectionInformationWeCollect => '当社が収集する情報';

  @override
  String get privacyPolicySectionDataStorage => 'データストレージ';

  @override
  String get privacyPolicySectionDataTransmission => '第三者へのデータ送信';

  @override
  String get privacyPolicySectionRequiredPermissions => '必要な権限';

  @override
  String get privacyPolicySectionSecurity => '安全';

  @override
  String get privacyPolicySectionUserRights => 'ユーザーの権利';

  @override
  String get privacyPolicySectionDataRetention => 'データの保持';

  @override
  String get privacyPolicySectionChildrenPrivacy => '子供のプライバシー';

  @override
  String get privacyPolicySectionChangesToPolicy => 'このポリシーの変更';

  @override
  String get privacyPolicySectionDataCollectionConsent => 'データ収集の同意';

  @override
  String get privacyPolicySectionPDPACompliance =>
      'PDPA コンプライアンス (タイ個人データPro保護法)';

  @override
  String get privacyPolicySectionContactUs => 'お問い合わせ';

  @override
  String get privacyPolicyEffectiveDate =>
      '発効日: 2026 年 2 月 18 日\n最終更新日: 2026 年 2 月 18 日';

  @override
  String get termsOfServiceTitle => '利用規約';

  @override
  String get termsSubtitle => 'MiRO — 私の摂取記録 Oracle';

  @override
  String get termsSectionAcceptanceOfTerms => '規約への同意';

  @override
  String get termsSectionServiceDescription => 'サービスの説明';

  @override
  String get termsSectionDisclaimerOfWarranties => '保証の否認';

  @override
  String get termsSectionEnergySystemTerms => 'エネルギーシステム用語';

  @override
  String get termsSectionUserDataAndResponsibilities => 'ユーザーデータと責任';

  @override
  String get termsSectionBackupTransfer => 'バックアップと転送';

  @override
  String get termsSectionInAppPurchases => 'アプリ内購入';

  @override
  String get termsSectionProhibitedUses => 'Pro禁止されている用途';

  @override
  String get termsSectionIntellectualProperty => '知的Proプロパティ';

  @override
  String get termsSectionLimitationOfLiability => '責任の制限';

  @override
  String get termsSectionServiceTermination => 'サービス終了';

  @override
  String get termsSectionChangesToTerms => '規約の変更';

  @override
  String get termsSectionGoverningLaw => '準拠法';

  @override
  String get termsSectionContactUs => 'お問い合わせ';

  @override
  String get termsAcknowledgment => 'MiRO を使用すると、これらの利用規約を読み、理解し、同意したことになります。';

  @override
  String get termsLastUpdated => '最終更新日: 2026 年 2 月 15 日';

  @override
  String get profileAndSettings => 'Proファイルと設定';

  @override
  String errorOccurred(String error) {
    return 'エラー: $error';
  }

  @override
  String get healthGoalsSection => '健康の目標';

  @override
  String get dailyGoals => '毎日の目標';

  @override
  String get chatAiModeSection => 'チャットAIモード';

  @override
  String get selectAiPowersChat => 'チャットを強化する AI を選択してください';

  @override
  String get miroAi => 'Miro AI';

  @override
  String get miroAiSubtitle => 'Gemini を搭載 • 多言語対応 • 高精度';

  @override
  String get localAi => 'ローカルAI';

  @override
  String get localAiSubtitle => 'オンデバイス • 英語のみ • 基本精度';

  @override
  String get free => '無料';

  @override
  String get cuisinePreferenceSection => '料理の好み';

  @override
  String get preferredCuisine => '好みの料理';

  @override
  String get selectYourCuisine => '料理をお選びください';

  @override
  String get photoScanSection => '写真スキャン';

  @override
  String get languageSection => '言語';

  @override
  String get languageTitle => '言語 / ภาษา';

  @override
  String get selectLanguage => '言語を選択 / เลือกภาษา';

  @override
  String get systemDefault => 'システムのデフォルト';

  @override
  String get systemDefaultSublabel => 'ตามระบบ';

  @override
  String get english => '英語';

  @override
  String get englishSublabel => 'อังกฤษ';

  @override
  String get thai => 'ไทย (タイ語)';

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
  String get closeBilingual => '閉じる / ปิด';

  @override
  String languageChangedTo(String language) {
    return '言語が$languageに変更されました';
  }

  @override
  String get accountSection => 'アカウント';

  @override
  String get miroId => 'MiRO ID';

  @override
  String get miroIdCopied => 'MiRO ID がコピーされました!';

  @override
  String get inviteFriends => '友達を招待する';

  @override
  String get inviteFriendsSubtitle => '紹介コードを共有して特典を獲得しましょう！';

  @override
  String get unlimitedAiDoubleRewards => '無制限の AI + 2 倍の報酬';

  @override
  String get plan => 'プラン';

  @override
  String get monthly => '毎月';

  @override
  String get started => '開始しました';

  @override
  String get renews => '更新します';

  @override
  String get expires => '有効期限が切れます';

  @override
  String get autoRenew => '自動更新';

  @override
  String get on => 'の上';

  @override
  String get off => 'オフ';

  @override
  String get tapToManageSubscription => 'タップしてサブスクリプションを管理します';

  @override
  String get dataSection => 'データ';

  @override
  String get backupData => 'バックアップデータ';

  @override
  String get backupDataSubtitle => 'エネルギー + 食事履歴 → ファイルとして保存';

  @override
  String get restoreFromBackup => 'バックアップから復元';

  @override
  String get restoreFromBackupSubtitle => 'バックアップファイルからデータをインポート';

  @override
  String get clearAllDataTitle => 'すべてのデータを消去しますか?';

  @override
  String get clearAllDataContent =>
      'すべてのデータが削除されます:\n• 食べ物のエントリー\n• 私の食事\n• 成分\n• 目標\n• 個人情報\n\nこれは取り消しできません!';

  @override
  String get allDataClearedSuccess => 'すべてのデータが正常に消去されました';

  @override
  String get aboutSection => 'について';

  @override
  String get version => 'バージョン';

  @override
  String get healthDisclaimer => '健康に関する免責事項';

  @override
  String get importantLegalInformation => '重要な法的情報';

  @override
  String get showTutorialAgain => 'チュートリアルを再度表示する';

  @override
  String get viewFeatureTour => '機能ツアーを見る';

  @override
  String get showTutorialDialogTitle => 'チュートリアルを表示する';

  @override
  String get showTutorialDialogContent =>
      'これにより、以下に焦点を当てた機能ツアーが表示されます。\n\n• エネルギーシステム\n• プルツーリフレッシュ写真スキャン\n• Miro AI とチャット\n\nホーム画面に戻ります。';

  @override
  String get showTutorialButton => 'チュートリアルを表示する';

  @override
  String get tutorialResetMessage => 'チュートリアルリセット！ホーム画面に移動して表示します。';

  @override
  String get foodAnalysisTutorial => '食品分析のチュートリアル';

  @override
  String get foodAnalysisTutorialSubtitle => '食品分析機能の使用方法を学ぶ';

  @override
  String get backupCreated => 'バックアップが作成されました!';

  @override
  String get backupCreatedContent => 'バックアップ ファイルが正常に作成されました。';

  @override
  String get backupChooseDestination => 'バックアップをどこに保存しますか?';

  @override
  String get backupSaveToDevice => 'デバイスに保存';

  @override
  String get backupSaveToDeviceDesc => 'このデバイス上で選択したフォルダーに保存します';

  @override
  String get backupShareToOther => '他のデバイスに共有する';

  @override
  String get backupShareToOtherDesc => 'Line、メール、Googleドライブなどで送信します。';

  @override
  String get backupSavedSuccess => 'バックアップが保存されました!';

  @override
  String get backupSavedSuccessContent => 'バックアップ ファイルが選択した場所に保存されました。';

  @override
  String get important => '重要：';

  @override
  String get backupImportantNotes =>
      '• このファイルを安全な場所 (Google ドライブなど) に保存します。\n• 写真はバックアップに含まれません。\n• 転送キーの有効期限は 30 日です\n• キーは一度しか使用できません';

  @override
  String get restoreBackup => 'バックアップを復元しますか?';

  @override
  String get backupFrom => 'バックアップ元:';

  @override
  String get date => '日付：';

  @override
  String get energy => 'エネルギー：';

  @override
  String get foodEntries => '食べ物のエントリー:';

  @override
  String get restoreImportant => '重要';

  @override
  String restoreImportantNotes(String energy) {
    return '• このデバイスの現在のエネルギーは、バックアップ ($energy) のエネルギーと置き換えられます。\n• 食品エントリはマージされます (置き換えられません)。\n• 写真はバックアップに含まれません\n・転送キーを使用します（再利用不可）';
  }

  @override
  String get restore => '復元する';

  @override
  String get restoreComplete => '復元完了！';

  @override
  String get restoreCompleteContent => 'データは正常に復元されました。';

  @override
  String get newEnergyBalance => '新しいエネルギーバランス:';

  @override
  String get foodEntriesImported => '輸入された食品エントリ:';

  @override
  String get myMealsImported => '輸入した私の食事:';

  @override
  String get appWillRefresh => 'アプリが更新されて、復元されたデータが表示されます。';

  @override
  String get backupFailed => 'バックアップに失敗しました';

  @override
  String get invalidBackupFile => '無効なバックアップ ファイル';

  @override
  String get restoreFailed => '復元に失敗しました';

  @override
  String get analyticsDataCollection => '分析データの収集';

  @override
  String get analyticsEnabled => '分析が有効になっています - 分析が有効です - 分析が有効です';

  @override
  String get analyticsDisabled => '分析が無効になっています - ไม่เก็บข้อมูลการใช้งาน';

  @override
  String get enabled => '有効';

  @override
  String get enabledSubtitle => '有効 - ช่วยปรับปรุงประสบการณ์ใช้งาน';

  @override
  String get disabled => '無効';

  @override
  String get disabledSubtitle => '無効 - ไม่เก็บข้อมูลการใช้งาน';

  @override
  String get imagesPerDay => '1日あたりの画像';

  @override
  String scanUpToImagesPerDay(String limit) {
    return '1 日あたり最大 $limit 枚の画像をスキャンします';
  }

  @override
  String get reset => 'リセット';

  @override
  String get resetScanHistory => 'スキャン履歴をリセット';

  @override
  String get resetScanHistorySubtitle => 'スキャンされたすべてのエントリを削除して再スキャンします';

  @override
  String get imagesPerDayDialog => '1日あたりの画像';

  @override
  String get maxImagesPerDayDescription => '1 日にスキャンできる最大画像数\n選択した日付のみをスキャンします';

  @override
  String scanLimitSetTo(String limit) {
    return 'スキャン制限は 1 日あたり $limit 枚の画像に設定されています';
  }

  @override
  String get resetScanHistoryDialog => 'スキャン履歴をリセットしますか?';

  @override
  String get resetScanHistoryContent =>
      'ギャラリーでスキャンされたすべての食品エントリは削除されます。\n画像を再スキャンするには、任意の日付をプルダウンします。';

  @override
  String resetComplete(String count) {
    return 'リセットが完了しました - $count エントリが削除されました。再スキャンするには下に引き下げます。';
  }

  @override
  String questBarStreak(int days) {
    return '連続$days日';
  }

  @override
  String questBarDaysToNextTier(int days, String tier) {
    return '$days 日 → $tier';
  }

  @override
  String get questBarMaxTier => 'マックスティア！ 💎';

  @override
  String get questBarOfferDismissed => '非表示のオファー';

  @override
  String get questBarViewOffer => 'オファーを見る';

  @override
  String get questBarNoOffersNow => '• 現在オファーはありません';

  @override
  String get questBarWeeklyChallenges => '🎯 ウィークリーチャレンジ';

  @override
  String get questBarMilestones => '🏆マイルストーン';

  @override
  String get questBarInviteFriends => '👥 友達を招待して 20E をゲット';

  @override
  String questBarTimeRemaining(String time) {
    return '⏰ 残り時間 $time';
  }

  @override
  String questBarClaimDailyEnergy(int energy) {
    return '+${energy}E';
  }

  @override
  String questBarShareReferralError(String error) {
    return '共有エラー: $error';
  }

  @override
  String tierCelebrationTitle(String tier) {
    return '$tier お祝い ​​🎉';
  }

  @override
  String tierCelebrationDay(int day) {
    return '$day日';
  }

  @override
  String get tierCelebrationExpired => '期限切れ';

  @override
  String get tierCelebrationComplete => '完了！';

  @override
  String questBarWatchAd(int energy) {
    return '広告を見る +$energy⚡';
  }

  @override
  String questBarAdRemaining(int remaining, int total) {
    return '本日残り $remaining/$total';
  }

  @override
  String questBarAdSuccess(int energy) {
    return '広告を見ました! +$energy エネルギーが入ってきます...';
  }

  @override
  String get questBarAdNotReady => '広告の準備ができていません。もう一度お試しください。';

  @override
  String get questBarDailyChallenge => 'デイリーチャレンジ';

  @override
  String get questBarUseAi => 'エネルギーを使う';

  @override
  String get questBarResetsMonday => '毎週月曜日にリセットされる';

  @override
  String get questBarClaimed => '主張しました！';

  @override
  String get questBarHideOffer => '隠れる';

  @override
  String get questBarViewDetails => 'ビュー';

  @override
  String questBarShareText(String link) {
    return 'MiRO をお試しください! AI を活用した食品分析 🍔\nこのリンクを使用すると、両方とも +20 エネルギーを無料で獲得できます!\n\n$link';
  }

  @override
  String get questBarShareSubject => 'MiRO を試してください';

  @override
  String get claimButtonTitle => '毎日のエネルギーを摂取する';

  @override
  String claimButtonReceived(String energy) {
    return '+${energy}E を受け取りました!';
  }

  @override
  String get claimButtonAlreadyClaimed => '今日すでに申請済み';

  @override
  String claimButtonError(String error) {
    return 'エラー: $error';
  }

  @override
  String get seasonalQuestLimitedTime => '期間限定';

  @override
  String seasonalQuestDaysLeft(int days) {
    return '残り$days日';
  }

  @override
  String seasonalQuestRewardDaily(int reward) {
    return '+${reward}E / 日';
  }

  @override
  String seasonalQuestRewardOnce(int reward) {
    return '+${reward}E 1 回限り';
  }

  @override
  String get seasonalQuestClaimed => '主張しました！';

  @override
  String get seasonalQuestClaimedToday => '今日請求されました';

  @override
  String get errorFailed => '失敗した';

  @override
  String get errorFailedToClaim => '請求に失敗しました';

  @override
  String errorGeneric(String error) {
    return 'エラー: $error';
  }

  @override
  String get milestoneNoMilestonesToClaim => '獲得できるマイルストーンはまだありません';

  @override
  String milestoneClaimedEnergy(int energy) {
    return '🎁 +$energy エネルギーを要求しました!';
  }

  @override
  String get milestoneTitle => 'マイルストーン';

  @override
  String milestoneUseEnergyComplete(int threshold) {
    return 'エネルギーを使用する $threshold';
  }

  @override
  String milestoneNext(int threshold) {
    return '次へ: ${threshold}E';
  }

  @override
  String get milestoneAllComplete => 'すべてのマイルストーンが完了しました!';

  @override
  String get noEnergyTitle => 'エネルギー不足';

  @override
  String get noEnergyContent => 'AIで食品を分析するにはエネルギーが1必要です';

  @override
  String get noEnergyTip => 'AI を使用せずに手動で食事の記録を無料で行うこともできます';

  @override
  String get noEnergyLater => '後で';

  @override
  String noEnergyWatchAd(int remaining) {
    return '広告を見る ($remaining/3)';
  }

  @override
  String get noEnergyBuyEnergy => 'エネルギーを購入する';

  @override
  String get tierBronze => 'ブロンズ';

  @override
  String get tierSilver => '銀';

  @override
  String get tierGold => '金';

  @override
  String get tierDiamond => 'ダイヤモンド';

  @override
  String get tierStarter => 'スターター';

  @override
  String get tierUpCongratulations => '🎉 おめでとうございます！';

  @override
  String tierUpYouReached(String tier) {
    return '$tier に到達しました!';
  }

  @override
  String get tierUpMotivation => 'プロのようにカロリーを追跡\nあなたの理想のボディが近づいています！';

  @override
  String tierUpReward(int reward) {
    return '+${reward}E ご褒美!';
  }

  @override
  String get referralAllLevelsClaimed => 'すべてのレベルを主張しました!';

  @override
  String referralLevel(int level, String subtitle) {
    return 'レベル $level: $subtitle';
  }

  @override
  String referralProgress(int current, int target, int level, int total) {
    return '[$current/$target] (レベル $level/$total)';
  }

  @override
  String referralClaimedLevel(int level, int reward) {
    return '🎁 要求レベル $level: +$reward エネルギー!';
  }

  @override
  String get challengeUseAi10 => 'エネルギーを使う 10';

  @override
  String get specifyIngredients => '既知の成分を指定する';

  @override
  String get specifyIngredientsOptional => '既知の成分を指定します (オプション)';

  @override
  String get specifyIngredientsHint =>
      '知っている材料を入力すると、AI が隠れた調味料、油、ソースを見つけてくれます。';

  @override
  String get sendToAi => 'AIに送信';

  @override
  String get reanalyzeWithIngredients => '成分を追加して再分析する';

  @override
  String get reanalyzeButton => '再分析（1エネルギー）';

  @override
  String get ingredientsSaved => '材料を保存しました';

  @override
  String get pleaseAddAtLeastOneIngredient => '少なくとも 1 つの材料を追加してください';

  @override
  String get hiddenIngredientsDiscovered => 'AIが発見した隠し食材';

  @override
  String get retroScanTitle => '最近の写真をスキャンしますか?';

  @override
  String get retroScanDescription =>
      '過去 7 日間の写真をスキャンして、食べ物の写真を自動的に見つけて日記に追加できます。';

  @override
  String get retroScanNote => '食べ物の写真のみが検出され、他の写真は無視されます。写真がデバイスから離れることはありません。';

  @override
  String get retroScanStart => '私の写真をスキャンする';

  @override
  String get retroScanSkip => '今のところスキップしてください';

  @override
  String get retroScanInProgress => '走査...';

  @override
  String get retroScanTagline => 'MiRO はあなたの変革をもたらします\n食べ物の写真を健康データに変換します。';

  @override
  String get retroScanFetchingPhotos => '最近の写真を取得しています...';

  @override
  String get retroScanAnalyzing => '食べ物の写真を検出しています...';

  @override
  String retroScanPhotosFound(int count) {
    return '過去 7 日間に $count 枚の写真が見つかりました';
  }

  @override
  String get retroScanCompleteTitle => 'スキャン完了！';

  @override
  String retroScanCompleteDesc(int count) {
    return '$count 件の食べ物の写真が見つかりました!これらはタイムラインに追加され、AI 分析の準備が整いました。';
  }

  @override
  String get retroScanNoResultsTitle => '食べ物の写真が見つかりません';

  @override
  String get retroScanNoResultsDesc =>
      '過去 7 日間に食べ物の写真は検出されませんでした。次の食事の写真を撮ってみてください。';

  @override
  String get retroScanAnalyzeHint =>
      'タイムラインで「すべて分析」をタップすると、これらのエントリの AI 栄養分析が行われます。';

  @override
  String get retroScanDone => 'わかった！';

  @override
  String get welcomeEndTitle => 'MiRO へようこそ!';

  @override
  String get welcomeEndMessage => 'MiRO がお手伝いいたします。';

  @override
  String get welcomeEndJourney => '一緒に良い旅をしてください!!';

  @override
  String get welcomeEndStart => '始めましょう!';

  @override
  String greetingCalorieSummary(
      int remaining, int protein, int carbs, int fat) {
    return 'こんにちは！今日はどのようにお手伝いできますか?まだ $remaining kcal が残っています。これまでのところ: Proテイン ${protein}g、炭水化物 ${carbs}g、脂肪 ${fat}g。何を食べたか教えてください。すべてを食事ごとにリストアップしてください。すべて記録させていただきます。より詳細に、より正確に!!';
  }

  @override
  String greetingCuisineTip(String cuisine) {
    return 'あなたの好みの料理は$cuisineに設定されています。設定でいつでも変更できます。';
  }

  @override
  String greetingEnergyTip(int balance) {
    return '$balance エネルギーが利用可能です。エネルギーバッジで毎日の連続獲得報酬を受け取ることを忘れないでください。';
  }

  @override
  String get greetingRenamePhotoTip =>
      'ヒント: MiRO がより正確に分析できるように、食べ物の写真の名前を変更できます。';

  @override
  String get greetingAddIngredientsTip =>
      'ヒント: 分析のために MiRO に送信する前に、確信のある成分を追加できます。つまらない細かいことは全部解決してあげるよ！';

  @override
  String greetingBackupReminder(int days) {
    return 'やあ、ボス！ $days 日間データをバックアップしていません。設定でバックアップすることをお勧めします。データはローカルに保存されているため、何かが起こった場合は復元できません。';
  }

  @override
  String get greetingFallback => 'こんにちは！今日はどのようにお手伝いできますか?何を食べたか教えてください！';

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
      '食品名、数量を入力し、食べ物か製品かを選択すると、AIの精度が向上します。';

  @override
  String get hideDetails => 'Hide details';

  @override
  String get showDetails => 'Show details';

  @override
  String get searchModeLabel => '検索モード';

  @override
  String get normalFood => '食べ物';

  @override
  String get normalFoodDesc => '通常の家庭料理';

  @override
  String get packagedProduct => '製品';

  @override
  String get packagedProductDesc => '栄養表示ラベル付きパッケージ';

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
  String get longPressToSelect => '長押しして選択';

  @override
  String get healthSyncSection => 'ヘルスケア連携';

  @override
  String get healthSyncTitle => 'ヘルスケアアプリと同期';

  @override
  String get healthSyncSubtitleOn => '食事記録を同期 • アクティブエネルギーを含む';

  @override
  String get healthSyncSubtitleOff => 'タップして Apple Health / Health Connect に接続';

  @override
  String get healthSyncEnabled => 'ヘルスケア同期がオンになりました';

  @override
  String get healthSyncDisabled => 'ヘルスケア同期がオフになりました';

  @override
  String get healthSyncPermissionDeniedTitle => 'アクセス許可が必要です';

  @override
  String get healthSyncPermissionDeniedMessage =>
      '以前にヘルスケアデータへのアクセスを拒否しました。\nデバイスの設定で有効にしてください。';

  @override
  String get healthSyncGoToSettings => '設定へ移動';

  @override
  String healthSyncActiveEnergyValue(String value) {
    return '+$value kcal 今日の消費';
  }

  @override
  String get healthSyncNotAvailable =>
      'このデバイスでは Health Connect を利用できません。Health Connect アプリをインストールしてください。';

  @override
  String get healthSyncFoodSynced => '食事をヘルスケアアプリに同期しました';

  @override
  String get healthSyncFoodDeletedFromHealth => 'ヘルスケアアプリから食事を削除しました';

  @override
  String get bmrSettingTitle => 'BMR（基礎代謝量）';

  @override
  String get bmrSettingSubtitle => '活動エネルギーの推定に使用';

  @override
  String get bmrDialogTitle => 'BMRを設定';

  @override
  String get bmrDialogDescription =>
      'MiROはBMRを使用して総消費カロリーから基礎代謝を差し引き、活動エネルギーのみを表示します。デフォルトは1500 kcal/日です。BMRはフィットネスアプリやオンライン計算機で確認できます。';

  @override
  String get healthSyncEnabledBmrHint =>
      'ヘルスケア同期が有効になりました。BMRデフォルト：1500 kcal/日 — 設定で調整できます。';

  @override
  String get privacyPolicySectionHealthData => 'ヘルスケアデータ連携';

  @override
  String get termsSectionHealthDataSync => 'ヘルスケアデータ同期';

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
