// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class L10nKo extends L10n {
  L10nKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'MiRO';

  @override
  String get save => '구하다';

  @override
  String get cancel => '취소';

  @override
  String get delete => '삭제';

  @override
  String get edit => '편집하다';

  @override
  String get search => '찾다';

  @override
  String get loading => '로드 중...';

  @override
  String get error => '오류가 발생했습니다';

  @override
  String get confirm => '확인하다';

  @override
  String get close => '닫다';

  @override
  String get done => '완료';

  @override
  String get next => '다음';

  @override
  String get skip => '건너뛰다';

  @override
  String get retry => '다시 해 보다';

  @override
  String get ok => '좋아요';

  @override
  String get foodName => '식품명';

  @override
  String get calories => '칼로리';

  @override
  String get protein => 'Pro테인';

  @override
  String get carbs => '탄수화물';

  @override
  String get fat => '지방';

  @override
  String get servingSize => '서빙 크기';

  @override
  String get servingUnit => '단위';

  @override
  String get kcal => 'kcal';

  @override
  String get mealBreakfast => '아침';

  @override
  String get mealLunch => '점심';

  @override
  String get mealDinner => '저녁';

  @override
  String get mealSnack => '간식';

  @override
  String get todaySummary => '오늘의 요약';

  @override
  String dateSummary(String date) {
    return '$date 요약';
  }

  @override
  String get savedSuccess => '성공적으로 저장되었습니다';

  @override
  String get deletedSuccess => '삭제되었습니다.';

  @override
  String get pleaseEnterFoodName => '음식 이름을 입력해주세요';

  @override
  String get noDataYet => '아직 데이터가 없습니다';

  @override
  String get addFood => '음식 추가';

  @override
  String get editFood => '음식 편집';

  @override
  String get deleteFood => '음식 삭제';

  @override
  String get deleteConfirm => '삭제를 확인하시겠습니까?';

  @override
  String get foodLoggedSuccess => '음식이 기록되었습니다!';

  @override
  String get noApiKey => 'Gemini API Key을(를) 설정하세요.';

  @override
  String get noApiKeyDescription => 'Profile → API 설정으로 이동하여 설정하세요.';

  @override
  String get apiKeyTitle => 'Gemini API Key 설정';

  @override
  String get apiKeyRequired => 'API Key 필요';

  @override
  String get apiKeyFreeNote => 'Gemini API은 무료로 사용할 수 있습니다.';

  @override
  String get apiKeySetup => 'API Key 설정';

  @override
  String get testConnection => '테스트 연결';

  @override
  String get connectionSuccess => '성공적으로 연결되었습니다! 사용 준비 완료';

  @override
  String get connectionFailed => '연결 실패';

  @override
  String get pasteKey => '반죽';

  @override
  String get deleteKey => 'API Key 삭제';

  @override
  String get openAiStudio => 'Google AI Studio 열기';

  @override
  String get chatHint => 'Miro에게 말하세요. \"로그볶음밥\"…';

  @override
  String get chatFoodSaved => '음식이 기록되었습니다!';

  @override
  String chatFoodSavedDetail(
      String name, String serving, String unit, String cal) {
    return '$name $serving $unit\n$cal kcal';
  }

  @override
  String get featureNotAvailable => '죄송합니다. 이 기능은 아직 사용할 수 없습니다.';

  @override
  String get goalCalories => '칼로리/일';

  @override
  String get goalProtein => 'Pro시간/일';

  @override
  String get goalCarbs => '탄수화물/일';

  @override
  String get goalFat => '지방/일';

  @override
  String get goalWater => '물/일';

  @override
  String get healthGoals => '건강 목표';

  @override
  String get profile => 'Pro파일';

  @override
  String get settings => '설정';

  @override
  String get privacyPolicy => '개인 정보 보호 정책';

  @override
  String get termsOfService => '서비스 약관';

  @override
  String get clearAllData => '모든 데이터 지우기';

  @override
  String get clearAllDataConfirm => '모든 데이터가 삭제됩니다. 이 작업은 취소할 수 없습니다!';

  @override
  String get about => '에 대한';

  @override
  String get language => '언어';

  @override
  String get upgradePro => 'Pro로 업그레이드';

  @override
  String get proUnlocked => 'MiRO Pro';

  @override
  String get proDescription => '무제한 AI 식품 분석';

  @override
  String aiRemaining(int remaining, int total) {
    return 'AI 분석: 오늘 남은 $remaining/$total';
  }

  @override
  String get aiLimitReached => '오늘(3/3) AI 한도 도달';

  @override
  String get restorePurchase => '구매 복원';

  @override
  String get myMeals => '나의 식사:';

  @override
  String get createMeal => '식사 만들기';

  @override
  String get ingredients => 'Ingredients';

  @override
  String get searchFood => '음식 검색';

  @override
  String get analyzing => '분석 중...';

  @override
  String get analyzeWithAi => 'AI로 분석';

  @override
  String get analysisComplete => '분석 완료';

  @override
  String get timeline => '타임라인';

  @override
  String get diet => '다이어트';

  @override
  String get quickAdd => '빠른 추가';

  @override
  String get welcomeTitle => 'MiRO';

  @override
  String get welcomeSubtitle => 'AI로 간편한 음식 기록';

  @override
  String get onboardingFeature1 => '사진 찍기';

  @override
  String get onboardingFeature1Desc => 'AI가 자동으로 칼로리를 계산한다';

  @override
  String get onboardingFeature2 => '기록할 내용을 입력하세요';

  @override
  String get onboardingFeature2Desc => '\"볶음밥을 먹었습니다\"라고 말하면 기록됩니다.';

  @override
  String get onboardingFeature3 => '일일 요약';

  @override
  String get onboardingFeature3Desc => 'kcal, 단백질, 탄수화물, 지방을 추적하세요.';

  @override
  String get basicInfo => '기본 정보';

  @override
  String get basicInfoDesc => '일일 권장 칼로리를 계산하려면';

  @override
  String get gender => '성별';

  @override
  String get male => '남성';

  @override
  String get female => '여성';

  @override
  String get age => '나이';

  @override
  String get weight => '무게';

  @override
  String get height => '키';

  @override
  String get activityLevel => '활동 수준';

  @override
  String tdeeResult(int kcal) {
    return '귀하의 TDEE: $kcal kcal/일';
  }

  @override
  String get setupAiTitle => 'Gemini AI 설정';

  @override
  String get setupAiDesc => '사진을 찍으면 AI가 자동으로 분석합니다.';

  @override
  String get setupNow => '지금 설정하세요';

  @override
  String get skipForNow => '지금은 건너뛰세요';

  @override
  String get errorTimeout => '연결 시간이 초과되었습니다. 다시 시도해 주세요.';

  @override
  String get errorInvalidKey => '잘못된 API Key — 설정을 확인하세요';

  @override
  String get errorNoInternet => '인터넷에 연결되어 있지 않음';

  @override
  String get errorGeneral => '오류가 발생했습니다. 다시 시도해 주세요.';

  @override
  String get errorQuotaExceeded => 'API 할당량을 초과했습니다. 잠시 기다렸다가 다시 시도하십시오.';

  @override
  String get apiKeyScreenTitle => 'Gemini API Key 설정';

  @override
  String get analyzeFoodWithAi => 'AI로 음식을 분석하다';

  @override
  String get analyzeFoodWithAiDesc =>
      '사진 찍기 → AI가 자동으로 칼로리 계산\nGemini API은 무료로 사용할 수 있습니다!';

  @override
  String get openGoogleAiStudio => 'Google AI Studio 열기';

  @override
  String get step1Title => 'Google AI Studio 열기';

  @override
  String get step1Desc => 'API Key을(를) 생성하려면 아래 버튼을 클릭하세요.';

  @override
  String get step2Title => 'Google 계정으로 로그인';

  @override
  String get step2Desc => 'Gmail 또는 Google 계정을 사용하세요(없는 경우 무료로 만드세요).';

  @override
  String get step3Title => '\"API Key 생성\"을 클릭하세요.';

  @override
  String get step3Desc =>
      '파란색 \"API Key 만들기\" 버튼을 클릭하세요.\nProject를 선택하라는 메시지가 표시되면 → \"새 프로젝트에서 API 키 생성\"을 클릭합니다.';

  @override
  String get step4Title => '키를 복사하여 아래에 붙여넣으세요.';

  @override
  String get step4Desc => '생성된 키 옆에 있는 복사를 클릭하세요.\n키는 다음과 같습니다: AIzaSyxxxx...';

  @override
  String get step5Title => '여기에 API Key을(를) 붙여넣으세요.';

  @override
  String get pasteApiKeyHint => '복사한 API Key을 붙여넣으세요.';

  @override
  String get saveApiKey => 'API Key 저장';

  @override
  String get testingConnection => '테스트 중...';

  @override
  String get deleteApiKey => 'API Key 삭제';

  @override
  String get deleteApiKeyConfirm => 'API Key을 삭제하시겠습니까?';

  @override
  String get deleteApiKeyConfirmDesc => '다시 설정할 때까지 AI 식품 분석을 사용할 수 없습니다.';

  @override
  String get apiKeySaved => 'API Key이(가) 성공적으로 저장되었습니다';

  @override
  String get apiKeyDeleted => 'API Key이(가) 성공적으로 삭제되었습니다.';

  @override
  String get pleasePasteApiKey => '먼저 API Key을(를) 붙여넣으세요.';

  @override
  String get apiKeyInvalidFormat => '잘못된 API Key — \"AIza\"로 시작해야 합니다.';

  @override
  String get connectionSuccessMessage => '✅ 성공적으로 연결되었습니다! 사용 준비 완료';

  @override
  String get connectionFailedMessage => '❌ 연결 실패';

  @override
  String get faqTitle => '자주 묻는 질문';

  @override
  String get faqFreeQuestion => '정말 무료인가요?';

  @override
  String get faqFreeAnswer =>
      '예! Gemini 2.0 플래시는 하루 1,500개 요청에 대해 무료입니다.\n음식 기록용(1일 5~15회) → 영구 무료, 결제 불필요';

  @override
  String get faqSafeQuestion => '안전합니까?';

  @override
  String get faqSafeAnswer =>
      'API Key은(는) 기기의 보안 저장소에만 저장됩니다.\n앱이 우리 서버에 키를 보내지 않습니다\nKey가 유출된 경우 → 삭제하고 새로 생성하세요. (귀하의 Google 비밀번호가 아닙니다.)';

  @override
  String get faqNoKeyQuestion => '키를 생성하지 않으면 어떻게 되나요?';

  @override
  String get faqNoKeyAnswer =>
      '여전히 앱을 사용할 수 있습니다! 하지만:\n❌ 사진 촬영 불가 → AI 분석\n✅ 음식을 수동으로 기록할 수 있습니다\n✅ 빠른 추가 작동\n✅ kcal/매크로 요약 작품 보기';

  @override
  String get faqCreditCardQuestion => '신용카드가 필요합니까?';

  @override
  String get faqCreditCardAnswer => '아니요 — 신용카드 없이 무료로 API Key을(를) 생성하세요';

  @override
  String get navDashboard => '계기반';

  @override
  String get navMyMeals => '내 식사';

  @override
  String get navCamera => '카메라';

  @override
  String get navGallery => 'Gallery';

  @override
  String get navAiChat => 'AI채팅';

  @override
  String get navProfile => 'Pro파일';

  @override
  String get appBarTodayIntake => '오늘의 섭취량';

  @override
  String get appBarMyMeals => '내 식사';

  @override
  String get appBarCamera => '카메라';

  @override
  String get appBarAiChat => 'AI채팅';

  @override
  String get appBarMiro => '미로';

  @override
  String get permissionRequired => '권한 필요';

  @override
  String get permissionRequiredDesc => 'MIRO는 다음에 대한 액세스가 필요합니다.';

  @override
  String get permissionPhotos => '사진 — 음식 스캔';

  @override
  String get permissionCamera => '카메라 — 음식 사진 촬영';

  @override
  String get permissionSkip => '건너뛰다';

  @override
  String get permissionAllow => '허용하다';

  @override
  String get permissionAllGranted => '모든 권한이 부여됨';

  @override
  String permissionDenied(String denied) {
    return '권한이 거부되었습니다: $denied';
  }

  @override
  String get openSettings => '설정 열기';

  @override
  String get exitAppTitle => '앱을 종료하시겠습니까?';

  @override
  String get exitAppMessage => '종료하시겠습니까?';

  @override
  String get exit => '출구';

  @override
  String get healthGoalsTitle => '건강 목표';

  @override
  String get healthGoalsInfo =>
      '일일 칼로리 목표, 매크로, 식사당 예산을 설정하세요.\n자동 계산 잠금: 매크로 2개 또는 식사 3개.';

  @override
  String get dailyCalorieGoal => '일일 칼로리 목표';

  @override
  String get proteinLabel => 'Pro테인';

  @override
  String get carbsLabel => '탄수화물';

  @override
  String get fatLabel => '지방';

  @override
  String get autoBadge => '자동';

  @override
  String kcalPerGram(int kcalPerGram, int kcal) {
    return '$kcalPerGram kcal/g • $kcal __SW0__';
  }

  @override
  String get mealCalorieBudget => '식사 칼로리 예산';

  @override
  String mealBudgetBalanced(int total, int goal) {
    return '합계 $total kcal = 목표 $goal __SW0__';
  }

  @override
  String mealBudgetRemaining(int total, int goal, int remaining) {
    return '총 $total / $goal kcal ($remaining 남음)';
  }

  @override
  String get lockMealsHint => '3번의 식사를 잠그면 4번째 식사가 자동 계산됩니다.';

  @override
  String get breakfastLabel => '아침';

  @override
  String get lunchLabel => '점심';

  @override
  String get dinnerLabel => '저녁';

  @override
  String get snackLabel => '간식';

  @override
  String percentOfDailyGoal(String percent) {
    return '일일 목표의 $percent%';
  }

  @override
  String get smartSuggestionRange => '스마트 제안 범위';

  @override
  String get smartSuggestionHow => '스마트 제안은 어떻게 작동하나요?';

  @override
  String smartSuggestionDesc(int threshold, int min, int max) {
    return '내 식단의 음식과 식재료, 어제의 식단을 식단당 예산에 맞춰 추천해 드립니다.\n\n이 임계값은 제안의 유연성을 제어합니다. 예를 들어 점심 예산이 700 kcal이고 기준액이 $threshold __SW0__인 경우 $min~$max __SW0__ 사이의 음식을 제안합니다.';
  }

  @override
  String get suggestionThreshold => '제안 임계값';

  @override
  String suggestionThresholdDesc(int threshold) {
    return '식사 예산에서 음식 ± $threshold kcal 허용';
  }

  @override
  String get goalsSavedSuccess => '목표가 성공적으로 저장되었습니다!';

  @override
  String get canOnlyLockTwoMacros => '한 번에 2개의 매크로만 잠글 수 있습니다.';

  @override
  String get canOnlyLockThreeMeals => '식사는 3번만 잠글 수 있습니다. 4번째 자동 계산';

  @override
  String get tabMeals => '식사';

  @override
  String get tabIngredients => '재료';

  @override
  String get searchMealsOrIngredients => '식사 또는 재료 검색...';

  @override
  String get createNewMeal => '새 식사 만들기';

  @override
  String get addIngredient => '성분 추가';

  @override
  String get noMealsYet => '아직 식사 없음';

  @override
  String get noMealsYetDesc => 'AI로 음식을 분석해 식사 자동 저장\n또는 수동으로 생성';

  @override
  String get noIngredientsYet => '아직 재료가 없습니다';

  @override
  String get noIngredientsYetDesc => 'AI로 음식을 분석하면\n재료가 자동으로 저장됩니다';

  @override
  String mealCreated(String name) {
    return '\'$name\'을(를) 생성했습니다.';
  }

  @override
  String mealLogged(String name) {
    return '\"$name\"이(가) 기록되었습니다.';
  }

  @override
  String ingredientAmount(String unit) {
    return '금액($unit)';
  }

  @override
  String ingredientLogged(String name, String amount, String unit) {
    return '\"$name\" $amount$unit이 기록되었습니다.';
  }

  @override
  String get mealNotFound => '식사를 찾을 수 없습니다';

  @override
  String mealUpdated(String name) {
    return '\"$name\" 업데이트됨';
  }

  @override
  String get deleteMealTitle => '식사를 삭제하시겠습니까?';

  @override
  String deleteMealMessage(String name) {
    return '\"$name\"';
  }

  @override
  String get deleteMealNote => '구성품은 삭제되지 않습니다.';

  @override
  String get mealDeleted => '식사가 삭제되었습니다.';

  @override
  String ingredientCreated(String name) {
    return '\'$name\'을(를) 생성했습니다.';
  }

  @override
  String get ingredientNotFound => '성분을 찾을 수 없습니다';

  @override
  String ingredientUpdated(String name) {
    return '\"$name\" 업데이트됨';
  }

  @override
  String get deleteIngredientTitle => '성분을 삭제하시겠습니까?';

  @override
  String deleteIngredientMessage(String name) {
    return '\"$name\"';
  }

  @override
  String get ingredientDeleted => '성분이 삭제되었습니다.';

  @override
  String get noIngredientsData => '성분 데이터가 없습니다.';

  @override
  String ingredientDetail(String name, String amount, String unit) {
    return '$name ($amount $unit)';
  }

  @override
  String ingredientCalories(int calories) {
    return '$calories kcal';
  }

  @override
  String get useThisMeal => '이 식사를 사용하세요';

  @override
  String errorLoading(String error) {
    return '로드 중 오류 발생: $error';
  }

  @override
  String scanFoundNewImages(int count, String date) {
    return '$date에서 $count 새 이미지를 찾았습니다.';
  }

  @override
  String scanNoNewImages(String date) {
    return '$date에 새 이미지가 없습니다.';
  }

  @override
  String aiAnalysisRemaining(int remaining, int total) {
    return 'AI 분석: 오늘 $remaining/$total 남음';
  }

  @override
  String get upgradeToProUnlimited => '무제한 사용하려면 Pro로 업그레이드하세요.';

  @override
  String get upgrade => '치받이';

  @override
  String get confirmDelete => '삭제 확인';

  @override
  String confirmDeleteMessage(String name) {
    return '\"$name\"을(를) 삭제하시겠습니까?';
  }

  @override
  String get entryDeletedSuccess => '✅ 항목이 삭제되었습니다.';

  @override
  String entryDeleteError(String error) {
    return '❌ 오류: $error';
  }

  @override
  String batchAnalyzeItems(int count) {
    return '$count 항목(일괄)';
  }

  @override
  String analyzeCancelled(int success) {
    return '취소됨 — $success개 항목을 성공적으로 분석했습니다.';
  }

  @override
  String analyzeSuccessAll(int success) {
    return '✅ $success 항목을 성공적으로 분석했습니다.';
  }

  @override
  String analyzeSuccessPartial(int success, int total, int failed) {
    return '⚠️ $success/$total 항목 분석됨($failed 실패)';
  }

  @override
  String analyzeProgress(String item, int current, int total) {
    return '$item ($current/$total)';
  }

  @override
  String get pullToScanMeal => '당겨서 식사를 스캔하세요.';

  @override
  String get analyzeAll => '모두 분석';

  @override
  String get addFoodTitle => '음식 추가';

  @override
  String get foodNameRequired => '음식 이름 *';

  @override
  String get foodNameHint => '검색하려면 입력하세요. 볶음밥, 파파야 샐러드';

  @override
  String get selectedFromMyMeal => '✅ 내 식사에서 선택 — 영양 데이터 자동 입력';

  @override
  String get foundInDatabase => '✅ 데이터베이스에서 발견 — 영양 데이터가 자동으로 채워짐';

  @override
  String get saveAndAnalyze => '저장 및 분석';

  @override
  String get notFoundInDatabase => '데이터베이스에서 찾을 수 없음 - 백그라운드에서 분석됩니다.';

  @override
  String get amountLabel => '양';

  @override
  String get unitLabel => '단위';

  @override
  String get nutritionAutoCalculated => '영양(양별로 자동계산)';

  @override
  String get nutritionEnterZero => '영양(알 수 없는 경우 0 입력)';

  @override
  String get caloriesLabel => '칼로리 (kcal)';

  @override
  String get proteinLabelShort => 'Pro테인(g)';

  @override
  String get carbsLabelShort => '탄수화물(g)';

  @override
  String get fatLabelShort => '지방(g)';

  @override
  String get mealTypeLabel => '식사 종류';

  @override
  String get pleaseEnterFoodNameFirst => '음식 이름을 먼저 입력해주세요';

  @override
  String get savedAnalyzingBackground => '✅ 저장됨 — 백그라운드에서 분석 중';

  @override
  String get foodAdded => '✅ 음식 추가됨';

  @override
  String get suggestionSourceMyMeal => '나의 식사';

  @override
  String get suggestionSourceIngredient => '재료';

  @override
  String get suggestionSourceDatabase => '데이터 베이스';

  @override
  String get editFoodTitle => '음식 편집';

  @override
  String get foodNameLabel => '식품명';

  @override
  String get changeAmountAutoUpdate => '양 변경 → 칼로리 자동 업데이트';

  @override
  String baseNutrition(int calories, String unit) {
    return '기본: $calories kcal / 1 $unit';
  }

  @override
  String get calculatedFromIngredients => '아래 성분으로 계산';

  @override
  String get ingredientsEditable => '성분 (편집 가능)';

  @override
  String get addIngredientButton => '추가하다';

  @override
  String get noIngredientsAddHint => '재료가 없습니다. 새로운 재료를 추가하려면 \"추가\"를 탭하세요.';

  @override
  String get editIngredientsHint =>
      '이름/금액 수정 → 검색 아이콘을 눌러 데이터베이스 또는 AI를 검색하세요.';

  @override
  String get ingredientNameHint => '예를 들어 닭고기 달걀';

  @override
  String get searchDbOrAi => 'DB/AI 검색';

  @override
  String get amountHint => '양';

  @override
  String get fromDatabase => '데이터베이스에서';

  @override
  String subIngredients(int count) {
    return '부성분($count)';
  }

  @override
  String get addSubIngredient => '추가하다';

  @override
  String get subIngredientNameHint => '부성분명';

  @override
  String get amountShort => '금액';

  @override
  String get pleaseEnterSubIngredientName => '부성분명을 먼저 입력해주세요';

  @override
  String foundInDatabaseSub(String name) {
    return '데이터베이스에서 \"$name\"을(를) 찾았습니다!';
  }

  @override
  String aiAnalyzedSub(String name) {
    return 'AI가 \"$name\"(-1 에너지)을 분석했습니다.';
  }

  @override
  String get couldNotAnalyzeSub => '부성분을 분석할 수 없습니다.';

  @override
  String get pleaseEnterIngredientName => '성분명을 입력해주세요';

  @override
  String get reAnalyzeTitle => '다시 분석하시겠습니까?';

  @override
  String reAnalyzeMessage(String name) {
    return '\'$name\'에는 이미 영양 데이터가 있습니다.\n\n다시 분석하면 에너지가 1 소모됩니다.\n\n계속하다?';
  }

  @override
  String get reAnalyzeButton => '재분석(에너지 1개)';

  @override
  String get amountNotSpecified => '금액이 지정되지 않음';

  @override
  String amountNotSpecifiedMessage(String name) {
    return '먼저 \"$name\"에 대한 금액을 지정하십시오.\n아니면 기본 100g을 사용합니까?';
  }

  @override
  String get useDefault100g => '100g을 사용';

  @override
  String aiAnalyzedResult(String name, int calories) {
    return 'AI: \"$name\" → $calories kcal';
  }

  @override
  String get unableToAnalyze => '분석할 수 없음';

  @override
  String get today => '오늘';

  @override
  String get savedSuccessfully => '✅ 성공적으로 저장되었습니다';

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
  String get confirmFoodPhoto => '음식 사진 확인';

  @override
  String get photoSavedAutomatically => '사진이 자동으로 저장됨';

  @override
  String get foodNameHintExample => '예: 구운 치킨 샐러드';

  @override
  String get quantityLabel => '수량';

  @override
  String get quantityHint => '1';

  @override
  String get optionalFoodInfo => '식품명과 수량 입력은 선택사항이지만, 입력하시면 AI 분석 정확도가 향상됩니다.';

  @override
  String get saveOnly => '저장만';

  @override
  String get pleaseEnterValidQuantity => '올바른 수량을 입력하세요.';

  @override
  String analyzedResult(String name, int calories) {
    return '✅ 분석됨: $name — $calories kcal';
  }

  @override
  String get couldNotAnalyzeSaved =>
      '⚠️ 분석할 수 없습니다. 저장했습니다. 나중에 \"모두 분석\"을 사용하세요.';

  @override
  String get savedAnalyzeLater => '✅ 저장됨 — 나중에 \"모두 분석\"으로 분석';

  @override
  String get editIngredientTitle => '성분 편집';

  @override
  String get ingredientNameRequired => '성분명 *';

  @override
  String get baseAmountLabel => '기본 금액';

  @override
  String get baseAmountHint => '100';

  @override
  String nutritionPerBase(String amount, String unit) {
    return '$amount $unit당 영양';
  }

  @override
  String nutritionCalculatedPerBase(String amount, String unit) {
    return '$amount $unit별로 계산된 영양 — 시스템은 실제 소비된 양을 기준으로 자동 계산합니다.';
  }

  @override
  String get createIngredient => '재료 생성';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get pleaseEnterIngredientNameFirst => '성분명을 먼저 입력해주세요';

  @override
  String aiAnalyzedIngredient(
      String name, String amount, String unit, int calories) {
    return 'AI: \"$name\" $amount $unit → $calories kcal';
  }

  @override
  String get unableToFindIngredient => '이 성분을 찾을 수 없습니다';

  @override
  String searchFailed(String error) {
    return '검색 실패: $error';
  }

  @override
  String deleteEntriesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Entries',
      one: 'Entry',
    );
    return '$count $_temp0을(를) 삭제하시겠습니까?';
  }

  @override
  String deleteEntriesMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return '$count 선택한 음식 $_temp0을(를) 삭제하시겠습니까?';
  }

  @override
  String get deleteAll => '모두 삭제';

  @override
  String deletedEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return '$count $_temp0을(를) 삭제했습니다.';
  }

  @override
  String movedEntriesToDate(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return '$count $_temp0을(를) $date(으)로 이동했습니다.';
  }

  @override
  String get allSelectedAlreadyAnalyzed => '선택한 모든 항목이 이미 분석되었습니다.';

  @override
  String analyzeCancelledSelected(int success) {
    return '취소됨 — $success 분석됨';
  }

  @override
  String analyzedEntriesAll(int success) {
    String _temp0 = intl.Intl.pluralLogic(
      success,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return '$success $_temp0을(를) 분석했습니다.';
  }

  @override
  String analyzedEntriesPartial(int success, int total, int failed) {
    return '$success/$total 분석됨($failed 실패)';
  }

  @override
  String analyzeProgressSelected(int current, int total, String item) {
    return '$current/$total $item';
  }

  @override
  String get noEntriesYet => '아직 항목이 없습니다.';

  @override
  String get selectAll => '모두 선택';

  @override
  String get deselectAll => '모두 선택 취소';

  @override
  String get moveToDate => '날짜로 이동';

  @override
  String get analyzeSelected => 'Analyze';

  @override
  String get deleteTooltip => '삭제';

  @override
  String get move => '이동하다';

  @override
  String get deleteTooltipAction => '삭제';

  @override
  String switchToModeTitle(String mode) {
    return '$mode 모드로 전환하시겠습니까?';
  }

  @override
  String switchToModeMessage(String current, String newMode) {
    return '이 항목은 $current로 분석되었습니다.\n\n$newMode로 재분석하면 에너지가 1 소모됩니다.\n\n계속하다?';
  }

  @override
  String analyzingAsMode(String mode) {
    return '$mode(으)로 분석 중...';
  }

  @override
  String reAnalyzedAsMode(String mode) {
    return '✅ $mode로 재분석됨';
  }

  @override
  String get analysisFailed => '❌ 분석 실패';

  @override
  String get aiAnalysisComplete => '✅ AI가 분석하고 저장함';

  @override
  String get changeMealType => '식사 유형 변경';

  @override
  String get moveToAnotherDate => '다른 날짜로 이동';

  @override
  String currentDate(String date) {
    return '현재: $date';
  }

  @override
  String get cancelDateChange => '날짜 변경 취소';

  @override
  String get undo => '끄르다';

  @override
  String get chatHistory => '채팅 기록';

  @override
  String get newChat => '새 채팅';

  @override
  String get quickActions => '빠른 작업';

  @override
  String get clear => '분명한';

  @override
  String get helloImMiro => '안녕하세요! 나는 Miro입니다';

  @override
  String get tellMeWhatYouAteToday => '오늘 무엇을 먹었는지 말해 보세요!';

  @override
  String get tellMeWhatYouAte => '뭘 먹었는지 말해봐...';

  @override
  String get clearHistoryTitle => '기록을 삭제하시겠습니까?';

  @override
  String get clearHistoryMessage => '이 세션의 모든 메시지가 삭제됩니다.';

  @override
  String get chatHistoryTitle => '채팅 기록';

  @override
  String get newLabel => '새로운';

  @override
  String get noChatHistoryYet => '아직 채팅 기록이 없습니다';

  @override
  String get active => '활동적인';

  @override
  String get deleteChatTitle => '채팅을 삭제하시겠습니까?';

  @override
  String deleteChatMessage(String title) {
    return '\'$title\'을 삭제하시겠습니까?';
  }

  @override
  String weeklySummaryTitle(String start, String end) {
    return '📊 주간 요약($start - $end)';
  }

  @override
  String daySummary(String day, String calories, String emoji, String diff) {
    return '📅 $day: $calories kcal $emoji ($diff)';
  }

  @override
  String overTarget(String amount) {
    return '$amount 목표 초과';
  }

  @override
  String underTarget(String amount) {
    return '$amount 타겟 미만';
  }

  @override
  String get noFoodLoggedThisWeek => '이번 주에는 아직 기록된 음식이 없습니다.';

  @override
  String averageKcalPerDay(String average) {
    return '🔥 평균: $average kcal/일';
  }

  @override
  String targetKcalPerDay(String target) {
    return '🎯 대상: $target kcal/일';
  }

  @override
  String resultOverTarget(String amount) {
    return '📈 결과: $amount kcal 목표 초과';
  }

  @override
  String resultUnderTarget(String amount) {
    return '📈 결과: $amount kcal 목표 미만 — 잘했어요! 💪';
  }

  @override
  String failedToLoadWeeklySummary(String error) {
    return '❌ 주간 요약을 로드하지 못했습니다: $error';
  }

  @override
  String monthlySummaryTitle(String month, int year) {
    return '📊 월별 요약($month $year)';
  }

  @override
  String totalDays(int days) {
    return '📅 총 일수: $days';
  }

  @override
  String totalConsumed(String calories) {
    return '🔥 총 소비량: $calories kcal';
  }

  @override
  String targetTotal(String target) {
    return '🎯 목표 합계: $target kcal';
  }

  @override
  String averageKcalPerDayShort(String average) {
    return '📈 평균: $average kcal/일';
  }

  @override
  String overTargetThisMonth(String amount) {
    return '⚠️ $amount kcal 이번 달 목표 초과';
  }

  @override
  String underTargetThisMonth(String amount) {
    return '✅ $amount kcal 목표 미만 — 훌륭합니다! 💪';
  }

  @override
  String failedToLoadMonthlySummary(String error) {
    return '❌ 월별 요약을 로드하지 못했습니다: $error';
  }

  @override
  String get localAiHelpTitle => '🤖 로컬 AI 도움말';

  @override
  String get localAiHelpFormat => '형식: [음식] [양] [단위]';

  @override
  String get localAiHelpExamples =>
      '예:\n• 닭고기 100g, 밥 200g\n• 피자 2조각\n• 사과 1개, 바나나 1개';

  @override
  String get localAiHelpNote =>
      '참고: 영어로만 제공, 기본 구문 분석\n더 나은 결과를 얻으려면 Miro AI로 전환하세요!';

  @override
  String hiNoFoodLogged(String target) {
    return '🤖 안녕하세요! 오늘은 아직 기록된 음식이 없습니다.\n   대상: $target kcal — 로깅을 시작할 준비가 되셨습니까? 🍽️';
  }

  @override
  String hiKcalLeft(String remaining) {
    return '🤖 안녕하세요! 오늘은 $remaining kcal 남았습니다.\n   식사를 기록할 준비가 되셨나요? 😊';
  }

  @override
  String hiOverTarget(String calories, String over) {
    return '🤖 안녕하세요! 오늘 $calories kcal을(를) 사용하셨습니다.\n   $over __SW0__ 목표 초과 — 계속 추적해 보겠습니다! 💪';
  }

  @override
  String get hiReadyToLog => '🤖 안녕하세요! 식사를 기록할 준비가 되셨나요? 😊';

  @override
  String get notEnoughEnergy => '에너지가 충분하지 않습니다';

  @override
  String get thinkingMealIdeas => '🤖 당신을 위한 훌륭한 식사 아이디어를 생각 중입니다...';

  @override
  String get recentMeals => '최근 식사:';

  @override
  String get noRecentFood => '최근에 기록된 음식이 없습니다.';

  @override
  String remainingCaloriesToday(String remaining) {
    return '. 오늘 남은 칼로리: $remaining kcal.';
  }

  @override
  String failedToGetMenuSuggestions(String error) {
    return '❌ 메뉴 제안을 가져오지 못했습니다: $error';
  }

  @override
  String get mealSuggestionsTitle =>
      '🤖 귀하의 음식 기록을 바탕으로 다음과 같은 3가지 식사 제안이 있습니다.';

  @override
  String mealSuggestionItem(
      int index, String emoji, String name, String calories) {
    return '$index. $emoji $name (~$calories kcal)';
  }

  @override
  String mealSuggestionMacros(String protein, String carbs, String fat) {
    return '피: ${protein}g | C: ${carbs}g | 여: ${fat}g';
  }

  @override
  String get pickOneAndLog => '하나를 선택하시면 제가 대신 기록해 드리겠습니다! 😊';

  @override
  String energyCost(int cost) {
    return '⚡ -$cost 에너지';
  }

  @override
  String get giveMeTipsForHealthyEating => '건강한 식습관에 대한 조언을 알려주세요.';

  @override
  String get howManyCaloriesToday => '오늘은 몇 칼로리인가요?';

  @override
  String get menuLabel => '메뉴';

  @override
  String get weeklyLabel => '주간';

  @override
  String get monthlyLabel => '월간 간행물';

  @override
  String get tipsLabel => '팁';

  @override
  String get summaryLabel => '요약';

  @override
  String get helpLabel => '돕다';

  @override
  String get onboardingWelcomeSubtitle => '쉽게 칼로리를 추적하세요\nAI 기반 분석으로';

  @override
  String get onboardingSnap => '스냅';

  @override
  String get onboardingSnapDesc => 'AI가 즉시 분석';

  @override
  String get onboardingType => '유형';

  @override
  String get onboardingTypeDesc => '로그인 초';

  @override
  String get onboardingEdit => '편집하다';

  @override
  String get onboardingEditDesc => '정확도 미세 조정';

  @override
  String get onboardingNext => '다음 →';

  @override
  String get onboardingDisclaimer => 'AI 추정 데이터. 의학적 조언이 아닙니다.';

  @override
  String get onboardingQuickSetup => '빠른 설정';

  @override
  String get onboardingHelpAiUnderstand => 'AI가 음식을 더 잘 이해할 수 있도록 도와주세요';

  @override
  String get onboardingYourTypicalCuisine => '전형적인 요리:';

  @override
  String get onboardingDailyCalorieGoal => '일일 칼로리 목표(선택 사항):';

  @override
  String get onboardingKcalPerDay => 'kcal/일';

  @override
  String get onboardingCalorieGoalHint => '2000';

  @override
  String get onboardingCanChangeAnytime => 'Pro파일 설정에서 언제든지 변경할 수 있습니다.';

  @override
  String get onboardingYoureAllSet => '모든 준비가 완료되었습니다!';

  @override
  String get onboardingStartTracking =>
      '오늘부터 식사 추적을 시작해 보세요.\n사진을 찍거나 무엇을 먹었는지 입력하세요.';

  @override
  String get onboardingWelcomeGift => '환영 선물';

  @override
  String get onboardingFreeEnergy => '10개의 무료 에너지';

  @override
  String get onboardingFreeEnergyDesc => '= 시작하기 위한 10가지 AI 분석';

  @override
  String get onboardingEnergyCost =>
      '각 분석 비용은 1 에너지입니다.\n더 많이 사용할수록 더 많은 수익을 얻을 수 있습니다!';

  @override
  String get onboardingStartTrackingButton => '추적을 시작하세요! →';

  @override
  String get onboardingNoCreditCard => '신용카드 없음 • 숨겨진 수수료 없음';

  @override
  String get cameraTakePhotoOfFood => '음식 사진을 찍어보세요';

  @override
  String get cameraFailedToInitialize => '카메라를 초기화하지 못했습니다.';

  @override
  String get cameraFailedToCapture => '사진을 캡처하지 못했습니다.';

  @override
  String get cameraFailedToPickFromGallery => '갤러리에서 이미지를 선택하지 못했습니다.';

  @override
  String get cameraProcessing => 'Pro중지 중...';

  @override
  String get referralInviteFriends => '친구 초대';

  @override
  String get referralYourReferralCode => '귀하의 추천 코드';

  @override
  String get referralLoading => '로드 중...';

  @override
  String get referralCopy => '복사';

  @override
  String get referralShareCodeDescription =>
      '이 코드를 친구들과 공유해보세요! AI를 3번 사용하면 둘 다 보상을 받습니다!';

  @override
  String get referralEnterReferralCode => '추천 코드 입력';

  @override
  String get referralCodeHint => 'MIRO-XXXX-XXXX-XXXX';

  @override
  String get referralSubmitCode => '코드 제출';

  @override
  String get referralPleaseEnterCode => '추천코드를 입력해주세요';

  @override
  String get referralCodeAccepted => '추천코드가 승인되었습니다!';

  @override
  String get referralCodeCopied => '추천코드가 클립보드에 복사되었습니다!';

  @override
  String referralEnergyBonus(int energy) {
    return '+$energy 에너지!';
  }

  @override
  String get referralHowItWorks => '작동 방식';

  @override
  String get referralStep1Title => '추천 코드를 공유하세요';

  @override
  String get referralStep1Description => 'MiRO ID를 복사하여 친구와 공유하세요.';

  @override
  String get referralStep2Title => '친구가 귀하의 코드를 입력했습니다.';

  @override
  String get referralStep2Description => '즉시 +20 에너지를 얻습니다.';

  @override
  String get referralStep3Title => '친구가 AI를 3번 사용함';

  @override
  String get referralStep3Description => '3개의 AI 분석을 완료하면';

  @override
  String get referralStep4Title => '보상을 받으세요!';

  @override
  String get referralStep4Description => '+5 에너지를 받습니다!';

  @override
  String get tierBenefitsTitle => '등급 혜택';

  @override
  String get tierBenefitsUnlockRewards => '보상 잠금 해제\n일일 연속';

  @override
  String get tierBenefitsKeepStreakDescription =>
      '연속 기록을 유지하여 더 높은 등급을 잠금 해제하고 놀라운 혜택을 받으세요!';

  @override
  String get tierBenefitsHowItWorks => '작동 방식';

  @override
  String get tierBenefitsDailyEnergyReward => '일일 에너지 보상';

  @override
  String get tierBenefitsDailyEnergyDescription =>
      '하루에 한 번 이상 AI를 사용하여 보너스 에너지를 얻으세요. 높은 등급 = 더 많은 일일 에너지!';

  @override
  String get tierBenefitsPurchaseBonus => '구매 보너스';

  @override
  String get tierBenefitsPurchaseBonusDescription =>
      '골드 및 다이아몬드 등급은 구매할 때마다 추가 에너지를 얻습니다(10-20% 더!)';

  @override
  String get tierBenefitsGracePeriod => '유예기간';

  @override
  String get tierBenefitsGracePeriodDescription =>
      '연속 기록을 잃지 않고 하루를 놓치지 마세요. 실버+ 등급은 보호를 받습니다!';

  @override
  String get tierBenefitsAllTiers => '모든 계층';

  @override
  String get tierBenefitsNew => '새로운';

  @override
  String get tierBenefitsPopular => '인기 있는';

  @override
  String get tierBenefitsBest => '최상의';

  @override
  String get tierBenefitsDailyCheckIn => '일일 체크인';

  @override
  String get tierBenefitsProTips => 'Pro 팁';

  @override
  String get tierBenefitsTip1 => '매일 AI를 사용하여 무료 에너지를 얻고 연속 기록을 쌓으세요.';

  @override
  String get tierBenefitsTip2 => '다이아몬드 등급은 하루에 +4 에너지를 얻습니다. 즉, 월 120입니다!';

  @override
  String get tierBenefitsTip3 => '구매 보너스는 모든 에너지 패키지에 적용됩니다!';

  @override
  String get tierBenefitsTip4 => '유예 기간은 하루를 놓친 경우 연속 연속 기록을 보호합니다.';

  @override
  String get subscriptionEnergyPass => '에너지패스';

  @override
  String get subscriptionInAppPurchasesNotAvailable => '인앱 구매를 사용할 수 없습니다.';

  @override
  String get subscriptionFailedToInitiatePurchase => '구매를 시작하지 못했습니다.';

  @override
  String subscriptionError(String error) {
    return '오류: $error';
  }

  @override
  String get subscriptionFailedToLoad => '구독을 로드하지 못했습니다.';

  @override
  String get subscriptionUnknownError => '알 수 없는 오류';

  @override
  String get subscriptionRetry => '다시 해 보다';

  @override
  String get subscriptionEnergyPassActive => '에너지 패스 액티브';

  @override
  String get subscriptionUnlimitedAccess => '무제한으로 액세스할 수 있습니다.';

  @override
  String get subscriptionStatus => '상태';

  @override
  String get subscriptionRenews => '갱신';

  @override
  String get subscriptionPrice => '가격';

  @override
  String get subscriptionYourBenefits => '귀하의 이점';

  @override
  String get subscriptionManageSubscription => '구독 관리';

  @override
  String get subscriptionNoProductAvailable => '사용 가능한 구독 제품이 없습니다.';

  @override
  String get subscriptionWhatYouGet => '당신이 얻는 것';

  @override
  String get subscriptionPerMonth => '매월';

  @override
  String get subscriptionSubscribeNow => '지금 구독하세요';

  @override
  String get subscriptionCancelAnytime => '언제든지 취소';

  @override
  String get subscriptionAutoRenewTerms =>
      '구독이 자동으로 갱신됩니다. Google Play에서 언제든지 취소할 수 있습니다.';

  @override
  String get disclaimerHealthDisclaimer => '건강 면책 조항';

  @override
  String get disclaimerImportantReminders => '중요 알림:';

  @override
  String get disclaimerBullet1 => '모든 영양 데이터는 추정치입니다.';

  @override
  String get disclaimerBullet2 => 'AI 분석에는 오류가 포함될 수 있습니다';

  @override
  String get disclaimerBullet3 => '전문가의 조언을 대신할 수 없음';

  @override
  String get disclaimerBullet4 => '의학적 지침은 의료 서비스 제공자에게 문의하세요.';

  @override
  String get disclaimerBullet5 => '귀하의 재량과 위험에 따라 사용하십시오.';

  @override
  String get disclaimerIUnderstand => '이해합니다';

  @override
  String get privacyPolicyTitle => '개인 정보 보호 정책';

  @override
  String get privacyPolicySubtitle => 'MiRO — 나의 섭취 기록 오라클';

  @override
  String get privacyPolicyHeaderNote =>
      '귀하의 음식 데이터는 귀하의 장치에 유지됩니다. 에너지 균형은 Firebase을 통해 안전하게 동기화되었습니다.';

  @override
  String get privacyPolicySectionInformationWeCollect => '당사가 수집하는 정보';

  @override
  String get privacyPolicySectionDataStorage => '데이터 저장';

  @override
  String get privacyPolicySectionDataTransmission => '제3자에게 데이터 전송';

  @override
  String get privacyPolicySectionRequiredPermissions => '필수 권한';

  @override
  String get privacyPolicySectionSecurity => '보안';

  @override
  String get privacyPolicySectionUserRights => '사용자 권리';

  @override
  String get privacyPolicySectionDataRetention => '데이터 보존';

  @override
  String get privacyPolicySectionChildrenPrivacy => '아동의 개인정보 보호';

  @override
  String get privacyPolicySectionChangesToPolicy => '본 정책의 변경 사항';

  @override
  String get privacyPolicySectionDataCollectionConsent => '데이터 수집 동의';

  @override
  String get privacyPolicySectionPDPACompliance =>
      'PDPA 규정 준수(태국 개인 데이터 Pro보호법)';

  @override
  String get privacyPolicySectionContactUs => '문의하기';

  @override
  String get privacyPolicyEffectiveDate =>
      '시행일: 2026년 2월 18일\n최종 업데이트: 2026년 2월 18일';

  @override
  String get termsOfServiceTitle => '서비스 약관';

  @override
  String get termsSubtitle => 'MiRO — 나의 섭취 기록 오라클';

  @override
  String get termsSectionAcceptanceOfTerms => '약관 동의';

  @override
  String get termsSectionServiceDescription => '서비스 설명';

  @override
  String get termsSectionDisclaimerOfWarranties => '보증의 부인';

  @override
  String get termsSectionEnergySystemTerms => '에너지 시스템 용어';

  @override
  String get termsSectionUserDataAndResponsibilities => '사용자 데이터 및 책임';

  @override
  String get termsSectionBackupTransfer => '백업 및 전송';

  @override
  String get termsSectionInAppPurchases => '인앱 구매';

  @override
  String get termsSectionProhibitedUses => 'Pro사용 금지';

  @override
  String get termsSectionIntellectualProperty => '지적 Property';

  @override
  String get termsSectionLimitationOfLiability => '책임의 제한';

  @override
  String get termsSectionServiceTermination => '서비스 종료';

  @override
  String get termsSectionChangesToTerms => '약관 변경';

  @override
  String get termsSectionGoverningLaw => '준거법';

  @override
  String get termsSectionContactUs => '문의하기';

  @override
  String get termsAcknowledgment =>
      'MiRO을(를) 사용함으로써 귀하는 본 서비스 약관을 읽고 이해했으며 이에 동의함을 인정합니다.';

  @override
  String get termsLastUpdated => '최종 업데이트 날짜: 2026년 2월 15일';

  @override
  String get profileAndSettings => 'Pro파일 및 설정';

  @override
  String errorOccurred(String error) {
    return '오류: $error';
  }

  @override
  String get healthGoalsSection => '건강 목표';

  @override
  String get dailyGoals => '일일 목표';

  @override
  String get chatAiModeSection => '채팅 AI 모드';

  @override
  String get selectAiPowersChat => '채팅을 지원하는 AI를 선택하세요';

  @override
  String get miroAi => 'Miro AI';

  @override
  String get miroAiSubtitle => 'Powered by Gemini • 다국어 • 높은 정확도';

  @override
  String get localAi => '로컬 AI';

  @override
  String get localAiSubtitle => '기기 내 • 영어로만 제공 • 기본 정확도';

  @override
  String get free => '무료';

  @override
  String get cuisinePreferenceSection => '선호하는 요리';

  @override
  String get preferredCuisine => '선호하는 요리';

  @override
  String get selectYourCuisine => '요리를 선택하세요';

  @override
  String get photoScanSection => '사진 스캔';

  @override
  String get languageSection => '언어';

  @override
  String get languageTitle => '언어 / 언어';

  @override
  String get selectLanguage => '언어를 선택하세요';

  @override
  String get systemDefault => '시스템 기본값';

  @override
  String get systemDefaultSublabel => '말하다';

  @override
  String get english => '영어';

  @override
  String get englishSublabel => '안녕하십니까';

  @override
  String get thai => 'ไท้ (태국어)';

  @override
  String get thaiSublabel => '태국';

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
  String get closeBilingual => '닫기 / 페이지';

  @override
  String languageChangedTo(String language) {
    return '언어가 $language로 변경되었습니다.';
  }

  @override
  String get accountSection => '계정';

  @override
  String get miroId => 'MiRO ID';

  @override
  String get miroIdCopied => 'MiRO ID가 복사되었습니다!';

  @override
  String get inviteFriends => '친구 초대';

  @override
  String get inviteFriendsSubtitle => '추천코드를 공유하고 보상을 받으세요!';

  @override
  String get unlimitedAiDoubleRewards => '무제한 AI + 두 배 보상';

  @override
  String get plan => '계획';

  @override
  String get monthly => '월간 간행물';

  @override
  String get started => '시작됨';

  @override
  String get renews => '갱신';

  @override
  String get expires => '만료';

  @override
  String get autoRenew => '자동 갱신';

  @override
  String get on => '~에';

  @override
  String get off => '끄다';

  @override
  String get tapToManageSubscription => '구독을 관리하려면 탭하세요.';

  @override
  String get dataSection => '데이터';

  @override
  String get backupData => '백업 데이터';

  @override
  String get backupDataSubtitle => '에너지 + 음식이력 → 파일로 저장';

  @override
  String get restoreFromBackup => '백업에서 복원';

  @override
  String get restoreFromBackupSubtitle => '백업 파일에서 데이터 가져오기';

  @override
  String get clearAllDataTitle => '모든 데이터를 삭제하시겠습니까?';

  @override
  String get clearAllDataContent =>
      '모든 데이터가 삭제됩니다:\n• 음식 항목\n• 내 식사\n• 성분\n• 목표\n• 개인정보\n\n이 작업은 취소할 수 없습니다!';

  @override
  String get allDataClearedSuccess => '모든 데이터가 성공적으로 지워졌습니다.';

  @override
  String get aboutSection => '에 대한';

  @override
  String get version => '버전';

  @override
  String get healthDisclaimer => '건강 면책 조항';

  @override
  String get importantLegalInformation => '중요한 법률 정보';

  @override
  String get showTutorialAgain => '튜토리얼 다시 표시';

  @override
  String get viewFeatureTour => '기능 둘러보기';

  @override
  String get showTutorialDialogTitle => '튜토리얼 표시';

  @override
  String get showTutorialDialogContent =>
      '다음을 강조하는 기능 둘러보기가 표시됩니다.\n\n• 에너지 시스템\n• 당겨서 새로고침하는 사진 스캔\n• Miro AI와 채팅\n\n홈 화면으로 돌아갑니다.';

  @override
  String get showTutorialButton => '튜토리얼 표시';

  @override
  String get tutorialResetMessage => '튜토리얼 초기화! 보려면 홈 화면으로 이동하세요.';

  @override
  String get foodAnalysisTutorial => '식품 분석 튜토리얼';

  @override
  String get foodAnalysisTutorialSubtitle => '식품 분석 기능 사용 방법 알아보기';

  @override
  String get backupCreated => '백업이 생성되었습니다!';

  @override
  String get backupCreatedContent => '백업 파일이 성공적으로 생성되었습니다.';

  @override
  String get backupChooseDestination => '백업을 어디에 저장하시겠습니까?';

  @override
  String get backupSaveToDevice => '장치에 저장';

  @override
  String get backupSaveToDeviceDesc => '이 장치에서 선택한 폴더에 저장';

  @override
  String get backupShareToOther => '다른 장치에 공유';

  @override
  String get backupShareToOtherDesc => '회선, 이메일, Google 드라이브 등을 통해 보내기';

  @override
  String get backupSavedSuccess => '백업이 저장되었습니다!';

  @override
  String get backupSavedSuccessContent => '백업 파일이 선택한 위치에 저장되었습니다.';

  @override
  String get important => '중요한:';

  @override
  String get backupImportantNotes =>
      '• 이 파일을 안전한 장소(Google 드라이브 등)에 저장하세요.\n• 사진은 백업에 포함되지 않습니다.\n• 이전 키는 30일 후에 만료됩니다.\n• 키는 한 번만 사용할 수 있습니다.';

  @override
  String get restoreBackup => '백업을 복원하시겠습니까?';

  @override
  String get backupFrom => '백업 위치:';

  @override
  String get date => '날짜:';

  @override
  String get energy => '에너지:';

  @override
  String get foodEntries => '음식 항목:';

  @override
  String get restoreImportant => '중요한';

  @override
  String restoreImportantNotes(String energy) {
    return '• 이 기기의 현재 에너지는 백업 에너지($energy)로 교체됩니다.\n• 음식 항목은 병합됩니다(대체되지 않음).\n• 사진은 백업에 포함되지 않습니다.\n• 전송 키가 사용됩니다(재사용 불가)';
  }

  @override
  String get restore => '복원하다';

  @override
  String get restoreComplete => '복원 완료!';

  @override
  String get restoreCompleteContent => '귀하의 데이터가 성공적으로 복원되었습니다.';

  @override
  String get newEnergyBalance => '새로운 에너지 균형:';

  @override
  String get foodEntriesImported => '수입된 식품:';

  @override
  String get myMealsImported => '내 식사가 수입되었습니다:';

  @override
  String get appWillRefresh => '복원된 데이터를 표시하기 위해 앱이 새로 고쳐집니다.';

  @override
  String get backupFailed => '백업 실패';

  @override
  String get invalidBackupFile => '잘못된 백업 파일';

  @override
  String get restoreFailed => '복원 실패';

  @override
  String get analyticsDataCollection => '분석 데이터 수집';

  @override
  String get analyticsEnabled => '분석 활성화됨 - ขאบคุณท่ช่ม้ปप्र्तบปप्र्ุแมป';

  @override
  String get analyticsDisabled =>
      '분석이 비활성화되었습니다. - ไม่ม่่ม่่ม่่่่่่่่มูมูมูมูมูมูมูมชช้้้้้ม';

  @override
  String get enabled => '활성화됨';

  @override
  String get enabledSubtitle => '활성화됨 - ช่ม้ปप्र्तบปप्र्ุปप्रะมบมช้้้้넷';

  @override
  String get disabled => '장애가 있는';

  @override
  String get disabledSubtitle =>
      '장애인 - ไม่ม่ม่่ม्่่่่่บข้้มูมูม้มูมูมูมูมูมช้้้้้ 이루고';

  @override
  String get imagesPerDay => '일일 이미지';

  @override
  String scanUpToImagesPerDay(String limit) {
    return '하루에 최대 $limit개의 이미지를 스캔하세요.';
  }

  @override
  String get reset => '다시 놓기';

  @override
  String get resetScanHistory => '검사 기록 재설정';

  @override
  String get resetScanHistorySubtitle => '검사된 모든 항목을 삭제하고 다시 검사하십시오.';

  @override
  String get imagesPerDayDialog => '일일 이미지';

  @override
  String get maxImagesPerDayDescription =>
      '하루에 스캔할 수 있는 최대 이미지\n선택한 날짜만 검사합니다.';

  @override
  String scanLimitSetTo(String limit) {
    return '하루에 $limit개의 이미지로 스캔 제한이 설정됨';
  }

  @override
  String get resetScanHistoryDialog => '스캔 기록을 재설정하시겠습니까?';

  @override
  String get resetScanHistoryContent =>
      '갤러리에서 스캔한 모든 음식 항목이 삭제됩니다.\n이미지를 다시 스캔하려면 날짜를 아래로 당깁니다.';

  @override
  String resetComplete(String count) {
    return '재설정 완료 - $count 항목이 삭제되었습니다. 아래로 당겨 다시 스캔하세요.';
  }

  @override
  String questBarStreak(int days) {
    return '연속 $days일';
  }

  @override
  String questBarDaysToNextTier(int days, String tier) {
    return '$days일 → $tier';
  }

  @override
  String get questBarMaxTier => '맥스 티어! 💎';

  @override
  String get questBarOfferDismissed => '숨겨진 혜택';

  @override
  String get questBarViewOffer => '제안 보기';

  @override
  String get questBarNoOffersNow => '• 지금은 쿠폰이 없습니다.';

  @override
  String get questBarWeeklyChallenges => '🎯 주간 챌린지';

  @override
  String get questBarMilestones => '🏆 마일스톤';

  @override
  String get questBarInviteFriends => '👥 친구를 초대하고 20E를 받으세요';

  @override
  String questBarTimeRemaining(String time) {
    return '⏰ 남은 시간 $time';
  }

  @override
  String questBarClaimDailyEnergy(int energy) {
    return '+${energy}E';
  }

  @override
  String questBarShareReferralError(String error) {
    return '공유 오류: $error';
  }

  @override
  String tierCelebrationTitle(String tier) {
    return '$tier 축하 🎉';
  }

  @override
  String tierCelebrationDay(int day) {
    return '일 $day';
  }

  @override
  String get tierCelebrationExpired => '만료됨';

  @override
  String get tierCelebrationComplete => '완벽한!';

  @override
  String questBarWatchAd(int energy) {
    return '광고 시청 +$energy⚡';
  }

  @override
  String questBarAdRemaining(int remaining, int total) {
    return '오늘 $remaining/$total 남음';
  }

  @override
  String questBarAdSuccess(int energy) {
    return '광고를 시청했습니다! +$energy 에너지 유입...';
  }

  @override
  String get questBarAdNotReady => '광고가 준비되지 않았습니다. 다시 시도해 주세요.';

  @override
  String get questBarDailyChallenge => '일일 도전';

  @override
  String get questBarUseAi => '에너지 사용';

  @override
  String get questBarResetsMonday => '매주 월요일 초기화';

  @override
  String get questBarClaimed => '소유권을 주장했습니다!';

  @override
  String get questBarHideOffer => '숨다';

  @override
  String get questBarViewDetails => '보다';

  @override
  String questBarShareText(String link) {
    return 'MiRO을 시도해 보세요! AI 기반 식품 분석 🍔\n이 링크를 사용하면 우리 둘 다 +20 에너지를 무료로 얻을 수 있습니다!\n\n$link';
  }

  @override
  String get questBarShareSubject => 'MiRO을 시도해 보세요';

  @override
  String get claimButtonTitle => '일일 에너지 청구';

  @override
  String claimButtonReceived(String energy) {
    return '+${energy}E을(를) 받았습니다!';
  }

  @override
  String get claimButtonAlreadyClaimed => '오늘 이미 소유권을 주장했습니다.';

  @override
  String claimButtonError(String error) {
    return '오류: $error';
  }

  @override
  String get seasonalQuestLimitedTime => '제한된 시간';

  @override
  String seasonalQuestDaysLeft(int days) {
    return '$days일 남음';
  }

  @override
  String seasonalQuestRewardDaily(int reward) {
    return '+${reward}E/일';
  }

  @override
  String seasonalQuestRewardOnce(int reward) {
    return '+${reward}E 일회성';
  }

  @override
  String get seasonalQuestClaimed => '소유권을 주장했습니다!';

  @override
  String get seasonalQuestClaimedToday => '오늘 소유권이 주장됨';

  @override
  String get errorFailed => '실패한';

  @override
  String get errorFailedToClaim => '소유권을 주장하지 못했습니다.';

  @override
  String errorGeneric(String error) {
    return '오류: $error';
  }

  @override
  String get milestoneNoMilestonesToClaim => '아직 청구할 마일스톤이 없습니다.';

  @override
  String milestoneClaimedEnergy(int energy) {
    return '🎁 +$energy 에너지를 획득했습니다!';
  }

  @override
  String get milestoneTitle => '마일스톤';

  @override
  String milestoneUseEnergyComplete(int threshold) {
    return '에너지 사용 $threshold';
  }

  @override
  String milestoneNext(int threshold) {
    return '다음: ${threshold}E';
  }

  @override
  String get milestoneAllComplete => '모든 마일스톤이 완료되었습니다!';

  @override
  String get noEnergyTitle => '에너지 부족';

  @override
  String get noEnergyContent => 'AI로 음식을 분석하려면 에너지 1개가 필요합니다.';

  @override
  String get noEnergyTip => 'AI 없이 수동으로 음식을 계속 무료로 기록할 수 있습니다.';

  @override
  String get noEnergyLater => '나중에';

  @override
  String noEnergyWatchAd(int remaining) {
    return '광고 시청($remaining/3)';
  }

  @override
  String get noEnergyBuyEnergy => '에너지 구매';

  @override
  String get tierBronze => '청동';

  @override
  String get tierSilver => '은';

  @override
  String get tierGold => '금';

  @override
  String get tierDiamond => '다이아몬드';

  @override
  String get tierStarter => '기동기';

  @override
  String get tierUpCongratulations => '🎉 축하합니다!';

  @override
  String tierUpYouReached(String tier) {
    return '$tier에 도달했습니다!';
  }

  @override
  String get tierUpMotivation => '전문가처럼 칼로리를 추적하세요\n당신의 꿈의 몸이 가까워지고 있습니다!';

  @override
  String tierUpReward(int reward) {
    return '+${reward}E 보상!';
  }

  @override
  String get referralAllLevelsClaimed => '모든 레벨을 획득했습니다!';

  @override
  String referralLevel(int level, String subtitle) {
    return '레벨 $level: $subtitle';
  }

  @override
  String referralProgress(int current, int target, int level, int total) {
    return '[$current/$target] (레벨 $level/$total)';
  }

  @override
  String referralClaimedLevel(int level, int reward) {
    return '🎁 요구 레벨 $level: +$reward 에너지!';
  }

  @override
  String get challengeUseAi10 => '에너지 10 사용';

  @override
  String get specifyIngredients => '알려진 성분 지정';

  @override
  String get specifyIngredientsOptional => '알려진 성분 지정(선택사항)';

  @override
  String get specifyIngredientsHint =>
      '알고 있는 재료를 입력하면 AI가 숨겨진 조미료, 오일, 소스를 찾아줍니다.';

  @override
  String get sendToAi => 'AI로 보내기';

  @override
  String get reanalyzeWithIngredients => '성분 추가 및 재분석';

  @override
  String get reanalyzeButton => '재분석(에너지 1개)';

  @override
  String get ingredientsSaved => '성분 절약';

  @override
  String get pleaseAddAtLeastOneIngredient => '재료를 1개 이상 추가해주세요.';

  @override
  String get hiddenIngredientsDiscovered => 'AI가 찾아낸 숨은 성분';

  @override
  String get retroScanTitle => '최근 사진을 스캔하시겠습니까?';

  @override
  String get retroScanDescription =>
      '지난 7일간의 사진을 스캔하여 자동으로 음식 사진을 찾아 일기에 추가할 수 있습니다.';

  @override
  String get retroScanNote => '음식 사진만 감지되며 다른 사진은 무시됩니다. 기기에 사진이 남지 않습니다.';

  @override
  String get retroScanStart => '내 사진 스캔';

  @override
  String get retroScanSkip => '지금은 건너뛰세요';

  @override
  String get retroScanInProgress => '스캐닝...';

  @override
  String get retroScanTagline => 'MiRO이 당신을 변화시키고 있습니다\n음식 사진을 건강 데이터로 변환합니다.';

  @override
  String get retroScanFetchingPhotos => '최근 사진을 가져오는 중...';

  @override
  String get retroScanAnalyzing => '음식 사진 감지 중...';

  @override
  String retroScanPhotosFound(int count) {
    return '지난 7일 동안 $count 사진이 검색되었습니다.';
  }

  @override
  String get retroScanCompleteTitle => '스캔 완료!';

  @override
  String retroScanCompleteDesc(int count) {
    return '$count 음식 사진을 찾았습니다! AI 분석을 위해 타임라인에 추가되었습니다.';
  }

  @override
  String get retroScanNoResultsTitle => '음식 사진을 찾을 수 없습니다.';

  @override
  String get retroScanNoResultsDesc =>
      '지난 7일 동안 음식 사진이 감지되지 않았습니다. 다음 식사 사진을 찍어보세요!';

  @override
  String get retroScanAnalyzeHint =>
      '해당 항목에 대한 AI 영양 분석을 받으려면 타임라인에서 \"모두 분석\"을 탭하세요.';

  @override
  String get retroScanDone => '알았어요!';

  @override
  String get welcomeEndTitle => 'MiRO에 오신 것을 환영합니다!';

  @override
  String get welcomeEndMessage => 'MiRO이(가) 귀하의 서비스에 있습니다.';

  @override
  String get welcomeEndJourney => '즐거운 여행 함께 하세요!!';

  @override
  String get welcomeEndStart => '시작하자!';

  @override
  String greetingCalorieSummary(
      int remaining, int protein, int carbs, int fat) {
    return '안녕! 오늘은 무엇을 도와드릴까요? 아직 $remaining kcal이 남아 있습니다. 지금까지: Protein ${protein}g, 탄수화물 ${carbs}g, 지방 ${fat}g. 무엇을 먹었는지 알려주세요. 식사별로 모든 것을 나열해 주시면 모두 기록해 드리겠습니다. More Detail 더 정확해요!!';
  }

  @override
  String greetingCuisineTip(String cuisine) {
    return '선호하는 요리는 $cuisine로 설정되어 있습니다. 언제든지 설정에서 변경할 수 있습니다!';
  }

  @override
  String greetingEnergyTip(int balance) {
    return '$balance 에너지를 사용할 수 있습니다. 에너지 배지로 일일 연속 보상을 획득하는 것을 잊지 마세요!';
  }

  @override
  String get greetingRenamePhotoTip =>
      '팁: MiRO이(가) 더 정확하게 분석하는 데 도움이 되도록 음식 사진의 이름을 바꿀 수 있습니다!';

  @override
  String get greetingAddIngredientsTip =>
      '팁: 분석을 위해 MiRO로 보내기 전에 확실한 성분을 추가할 수 있습니다. 지루하고 사소한 세부 사항을 모두 알아내겠습니다!';

  @override
  String greetingBackupReminder(int days) {
    return '안녕하세요 사장님! $days일 동안 데이터를 백업하지 않았습니다. 설정에서 백업하는 것이 좋습니다. 데이터는 로컬에 저장되며 어떤 일이 발생하면 복구할 수 없습니다!';
  }

  @override
  String get greetingFallback => '안녕! 오늘은 무엇을 도와드릴까요? 무엇을 먹었는지 말해 보세요!';

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
      '음식 이름, 수량을 제공하고 음식인지 제품인지 선택하면 AI 정확도가 향상됩니다.';

  @override
  String get hideDetails => 'Hide details';

  @override
  String get showDetails => 'Show details';

  @override
  String get searchModeLabel => '검색 모드';

  @override
  String get normalFood => '음식';

  @override
  String get normalFoodDesc => '일반 가정식';

  @override
  String get packagedProduct => '제품';

  @override
  String get packagedProductDesc => '영양 표시가 있는 포장 제품';

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
  String get quantity => 'Quantity';

  @override
  String get addToSandbox => 'Add';

  @override
  String get gallery => 'Gallery';

  @override
  String get longPressToSelect => '길게 눌러 항목 선택';

  @override
  String get healthSyncSection => '건강 동기화';

  @override
  String get healthSyncTitle => '건강 앱과 동기화';

  @override
  String get healthSyncSubtitleOn => '음식 기록 동기화 • 활동 에너지 포함';

  @override
  String get healthSyncSubtitleOff => '탭하여 Apple Health / Health Connect 연결';

  @override
  String get healthSyncEnabled => '건강 동기화가 활성화되었습니다';

  @override
  String get healthSyncDisabled => '건강 동기화가 비활성화되었습니다';

  @override
  String get healthSyncPermissionDeniedTitle => '접근 권한 필요';

  @override
  String get healthSyncPermissionDeniedMessage =>
      '이전에 건강 데이터 접근을 거부했습니다.\n기기 설정에서 활성화해 주세요.';

  @override
  String get healthSyncGoToSettings => '설정으로 이동';

  @override
  String healthSyncActiveEnergyValue(String value) {
    return '+$value kcal 오늘 소모';
  }

  @override
  String get healthSyncNotAvailable =>
      '이 기기에서 Health Connect를 사용할 수 없습니다. Health Connect 앱을 설치해 주세요.';

  @override
  String get healthSyncFoodSynced => '음식이 건강 앱에 동기화되었습니다';

  @override
  String get healthSyncFoodDeletedFromHealth => '건강 앱에서 음식이 삭제되었습니다';

  @override
  String get bmrSettingTitle => 'BMR (기초대사량)';

  @override
  String get bmrSettingSubtitle => '활동 에너지 추정에 사용';

  @override
  String get bmrDialogTitle => 'BMR 설정';

  @override
  String get bmrDialogDescription =>
      'MiRO는 BMR을 사용하여 총 소모 칼로리에서 기초대사량을 차감하여 활동 에너지만 표시합니다. 기본값은 1500 kcal/일입니다. BMR은 피트니스 앱이나 온라인 계산기에서 확인할 수 있습니다.';

  @override
  String get healthSyncEnabledBmrHint =>
      '건강 동기화가 활성화되었습니다. BMR 기본값: 1500 kcal/일 — 설정에서 조정 가능합니다.';

  @override
  String get privacyPolicySectionHealthData => '건강 데이터 연동';

  @override
  String get termsSectionHealthDataSync => '건강 데이터 동기화';
}
