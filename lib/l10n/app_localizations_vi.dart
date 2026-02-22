// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class L10nVi extends L10n {
  L10nVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'MiRO';

  @override
  String get save => 'Cứu';

  @override
  String get cancel => 'Hủy bỏ';

  @override
  String get delete => 'Xóa bỏ';

  @override
  String get edit => 'Biên tập';

  @override
  String get search => 'Tìm kiếm';

  @override
  String get loading => 'Đang tải...';

  @override
  String get error => 'Đã xảy ra lỗi';

  @override
  String get confirm => 'Xác nhận';

  @override
  String get close => 'Đóng';

  @override
  String get done => 'Xong';

  @override
  String get next => 'Kế tiếp';

  @override
  String get skip => 'Nhảy';

  @override
  String get retry => 'Thử lại';

  @override
  String get ok => 'ĐƯỢC RỒI';

  @override
  String get foodName => 'Tên món ăn';

  @override
  String get calories => 'Calo';

  @override
  String get protein => 'Protein';

  @override
  String get carbs => 'Carb';

  @override
  String get fat => 'Mập';

  @override
  String get servingSize => 'Kích thước phục vụ';

  @override
  String get servingUnit => 'Đơn vị';

  @override
  String get kcal => 'kcal';

  @override
  String get mealBreakfast => 'Bữa sáng';

  @override
  String get mealLunch => 'Bữa trưa';

  @override
  String get mealDinner => 'Bữa tối';

  @override
  String get mealSnack => 'Đồ ăn vặt';

  @override
  String get todaySummary => 'Tóm tắt hôm nay';

  @override
  String dateSummary(String date) {
    return 'Tóm tắt cho $date';
  }

  @override
  String get savedSuccess => 'Đã lưu thành công';

  @override
  String get deletedSuccess => 'Đã xóa thành công';

  @override
  String get pleaseEnterFoodName => 'Vui lòng nhập tên món ăn';

  @override
  String get noDataYet => 'Chưa có dữ liệu';

  @override
  String get addFood => 'Thêm thức ăn';

  @override
  String get editFood => 'Chỉnh sửa món ăn';

  @override
  String get deleteFood => 'Xóa thực phẩm';

  @override
  String get deleteConfirm => 'Xác nhận xóa?';

  @override
  String get foodLoggedSuccess => 'Thực phẩm được ghi lại!';

  @override
  String get noApiKey => 'Vui lòng thiết lập Gemini API Key';

  @override
  String get noApiKeyDescription => 'Vào Profile → API Cài đặt để thiết lập';

  @override
  String get apiKeyTitle => 'Thiết lập Gemini API Key';

  @override
  String get apiKeyRequired => 'API Key bắt buộc';

  @override
  String get apiKeyFreeNote => 'Gemini API được sử dụng miễn phí';

  @override
  String get apiKeySetup => 'Thiết lập API Key';

  @override
  String get testConnection => 'Kiểm tra kết nối';

  @override
  String get connectionSuccess => 'Đã kết nối thành công! Sẵn sàng để sử dụng';

  @override
  String get connectionFailed => 'Kết nối không thành công';

  @override
  String get pasteKey => 'Dán';

  @override
  String get deleteKey => 'Xóa API Key';

  @override
  String get openAiStudio => 'Mở Google AI Studio';

  @override
  String get chatHint => 'Nói với Miro ví dụ: \"Cơm chiên khúc gỗ\"...';

  @override
  String get chatFoodSaved => 'Thực phẩm được ghi lại!';

  @override
  String chatFoodSavedDetail(
      String name, String serving, String unit, String cal) {
    return '$name $serving $unit\n$cal kcal';
  }

  @override
  String get featureNotAvailable => 'Rất tiếc, tính năng này chưa khả dụng';

  @override
  String get goalCalories => 'Calo/ngày';

  @override
  String get goalProtein => 'Protein/ngày';

  @override
  String get goalCarbs => 'Carb/ngày';

  @override
  String get goalFat => 'Béo/ngày';

  @override
  String get goalWater => 'Nước/ngày';

  @override
  String get healthGoals => 'Mục tiêu sức khỏe';

  @override
  String get profile => 'Protập tin';

  @override
  String get settings => 'Cài đặt';

  @override
  String get privacyPolicy => 'Chính sách bảo mật';

  @override
  String get termsOfService => 'Điều khoản dịch vụ';

  @override
  String get clearAllData => 'Xóa tất cả dữ liệu';

  @override
  String get clearAllDataConfirm =>
      'Tất cả dữ liệu sẽ bị xóa. Điều này không thể được hoàn tác!';

  @override
  String get about => 'Về';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get upgradePro => 'Nâng cấp lên Pro';

  @override
  String get proUnlocked => 'MiRO Pro';

  @override
  String get proDescription => 'Phân tích thực phẩm AI không giới hạn';

  @override
  String aiRemaining(int remaining, int total) {
    return 'Phân tích AI: $remaining/$total còn lại hôm nay';
  }

  @override
  String get aiLimitReached => 'Đã đạt giới hạn AI cho ngày hôm nay (3/3)';

  @override
  String get restorePurchase => 'Khôi phục mua hàng';

  @override
  String get myMeals => 'Bữa ăn của tôi:';

  @override
  String get createMeal => 'Tạo bữa ăn';

  @override
  String get ingredients => 'Thành phần';

  @override
  String get searchFood => 'Tìm kiếm món ăn';

  @override
  String get analyzing => 'Đang phân tích...';

  @override
  String get analyzeWithAi => 'Phân tích bằng AI';

  @override
  String get analysisComplete => 'Phân tích hoàn tất';

  @override
  String get timeline => 'Dòng thời gian';

  @override
  String get diet => 'Ăn kiêng';

  @override
  String get quickAdd => 'Thêm nhanh';

  @override
  String get welcomeTitle => 'MiRO';

  @override
  String get welcomeSubtitle => 'Ghi nhật ký thực phẩm dễ dàng với AI';

  @override
  String get onboardingFeature1 => 'Chụp ảnh';

  @override
  String get onboardingFeature1Desc => 'AI tự động tính toán lượng calo';

  @override
  String get onboardingFeature2 => 'Nhập để đăng nhập';

  @override
  String get onboardingFeature2Desc =>
      'Nói \"đã ăn cơm chiên\" và nó được ghi lại';

  @override
  String get onboardingFeature3 => 'Tóm tắt hàng ngày';

  @override
  String get onboardingFeature3Desc =>
      'Theo dõi kcal, protein, carbs, chất béo';

  @override
  String get basicInfo => 'Thông tin cơ bản';

  @override
  String get basicInfoDesc =>
      'Để tính lượng calo khuyến nghị hàng ngày của bạn';

  @override
  String get gender => 'Giới tính';

  @override
  String get male => 'Nam giới';

  @override
  String get female => 'Nữ giới';

  @override
  String get age => 'Tuổi';

  @override
  String get weight => 'Cân nặng';

  @override
  String get height => 'Chiều cao';

  @override
  String get activityLevel => 'Cấp độ hoạt động';

  @override
  String tdeeResult(int kcal) {
    return 'TDEE của bạn: $kcal kcal/ngày';
  }

  @override
  String get setupAiTitle => 'Thiết lập Gemini AI';

  @override
  String get setupAiDesc => 'Chụp ảnh và AI sẽ tự động phân tích nó';

  @override
  String get setupNow => 'Thiết lập ngay bây giờ';

  @override
  String get skipForNow => 'Bỏ qua bây giờ';

  @override
  String get errorTimeout => 'Hết thời gian kết nối - vui lòng thử lại';

  @override
  String get errorInvalidKey =>
      'API Key không hợp lệ — hãy kiểm tra cài đặt của bạn';

  @override
  String get errorNoInternet => 'Không có kết nối internet';

  @override
  String get errorGeneral => 'Đã xảy ra lỗi - vui lòng thử lại';

  @override
  String get errorQuotaExceeded =>
      'API đã vượt quá hạn ngạch — vui lòng đợi và thử lại';

  @override
  String get apiKeyScreenTitle => 'Thiết lập Gemini API Key';

  @override
  String get analyzeFoodWithAi => 'Phân tích thực phẩm bằng AI';

  @override
  String get analyzeFoodWithAiDesc =>
      'Chụp ảnh → AI tự động tính toán lượng calo\nGemini API được sử dụng miễn phí!';

  @override
  String get openGoogleAiStudio => 'Mở Google AI Studio';

  @override
  String get step1Title => 'Mở Google AI Studio';

  @override
  String get step1Desc => 'Nhấp vào nút bên dưới để tạo API Key';

  @override
  String get step2Title => 'Đăng nhập bằng tài khoản Google';

  @override
  String get step2Desc =>
      'Sử dụng Tài khoản Gmail hoặc Google của bạn (tạo một tài khoản miễn phí nếu bạn chưa có)';

  @override
  String get step3Title => 'Nhấp vào \"Tạo API Key\"';

  @override
  String get step3Desc =>
      'Nhấp vào nút \"Tạo API Key\" màu xanh lam\nNếu được yêu cầu chọn Project → Nhấp vào \"Tạo khóa API trong dự án mới\"';

  @override
  String get step4Title => 'Sao chép Key và dán bên dưới';

  @override
  String get step4Desc =>
      'Nhấn Copy bên cạnh Key đã tạo\nKhóa sẽ có dạng: AIzaSyxxxx...';

  @override
  String get step5Title => 'Dán API Key vào đây';

  @override
  String get pasteApiKeyHint => 'Dán API Key đã sao chép';

  @override
  String get saveApiKey => 'Lưu API Key';

  @override
  String get testingConnection => 'Đang thử nghiệm...';

  @override
  String get deleteApiKey => 'Xóa API Key';

  @override
  String get deleteApiKeyConfirm => 'Xóa API Key?';

  @override
  String get deleteApiKeyConfirmDesc =>
      'Bạn sẽ không thể sử dụng tính năng phân tích thực phẩm bằng AI cho đến khi thiết lập lại';

  @override
  String get apiKeySaved => 'API Key đã lưu thành công';

  @override
  String get apiKeyDeleted => 'API Key đã xóa thành công';

  @override
  String get pleasePasteApiKey => 'Vui lòng dán API Key trước';

  @override
  String get apiKeyInvalidFormat =>
      'API Key không hợp lệ — phải bắt đầu bằng \"AIza\"';

  @override
  String get connectionSuccessMessage =>
      '✅ Kết nối thành công! Sẵn sàng để sử dụng';

  @override
  String get connectionFailedMessage => '❌ Kết nối không thành công';

  @override
  String get faqTitle => 'Câu hỏi thường gặp';

  @override
  String get faqFreeQuestion => 'Nó có thực sự miễn phí không?';

  @override
  String get faqFreeAnswer =>
      'Đúng! Gemini 2.0 Flash miễn phí cho 1.500 yêu cầu/ngày\nĐể ghi nhật ký thực phẩm (5-15 lần/ngày) → Miễn phí mãi mãi, không cần thanh toán';

  @override
  String get faqSafeQuestion => 'Nó có an toàn không?';

  @override
  String get faqSafeAnswer =>
      'API Key chỉ được lưu trữ trong Bộ nhớ an toàn trên thiết bị của bạn\nỨng dụng không gửi Key đến máy chủ của chúng tôi\nNếu Key bị rò rỉ → Xóa và tạo một cái mới (không phải mật khẩu Google của bạn)';

  @override
  String get faqNoKeyQuestion => 'Nếu tôi không tạo Chìa khóa thì sao?';

  @override
  String get faqNoKeyAnswer =>
      'Bạn vẫn có thể sử dụng ứng dụng! Nhưng:\n❌ Không chụp được ảnh → Phân tích AI\n✅ Có thể đăng nhập thực phẩm bằng tay\n✅ Thêm nhanh hoạt động\n✅ Xem kcal/tác phẩm tóm tắt macro';

  @override
  String get faqCreditCardQuestion => 'Tôi có cần thẻ tín dụng không?';

  @override
  String get faqCreditCardAnswer =>
      'Không — Tạo API Key miễn phí mà không cần thẻ tín dụng';

  @override
  String get navDashboard => 'Trang tổng quan';

  @override
  String get navMyMeals => 'Bữa ăn của tôi';

  @override
  String get navCamera => 'Máy ảnh';

  @override
  String get navAiChat => 'Trò chuyện AI';

  @override
  String get navProfile => 'Protập tin';

  @override
  String get appBarTodayIntake => 'Lượng tiêu thụ hôm nay';

  @override
  String get appBarMyMeals => 'Bữa ăn của tôi';

  @override
  String get appBarCamera => 'Máy ảnh';

  @override
  String get appBarAiChat => 'Trò chuyện AI';

  @override
  String get appBarMiro => 'MIRO';

  @override
  String get permissionRequired => 'Cần có sự cho phép';

  @override
  String get permissionRequiredDesc =>
      'MIRO cần quyền truy cập vào các thông tin sau:';

  @override
  String get permissionPhotos => 'Hình ảnh - để quét thực phẩm';

  @override
  String get permissionCamera => 'Máy ảnh - để chụp ảnh đồ ăn';

  @override
  String get permissionSkip => 'Nhảy';

  @override
  String get permissionAllow => 'Cho phép';

  @override
  String get permissionAllGranted => 'Tất cả các quyền được cấp';

  @override
  String permissionDenied(String denied) {
    return 'Quyền bị từ chối: $denied';
  }

  @override
  String get openSettings => 'Mở cài đặt';

  @override
  String get exitAppTitle => 'Thoát ứng dụng?';

  @override
  String get exitAppMessage => 'Bạn có chắc chắn muốn thoát không?';

  @override
  String get exit => 'Ra';

  @override
  String get healthGoalsTitle => 'Mục tiêu sức khỏe';

  @override
  String get healthGoalsInfo =>
      'Đặt mục tiêu lượng calo hàng ngày, macro và ngân sách mỗi bữa ăn của bạn.\nKhóa để tự động tính toán: 2 macro hoặc 3 bữa ăn.';

  @override
  String get dailyCalorieGoal => 'Mục tiêu calo hàng ngày';

  @override
  String get proteinLabel => 'Protein';

  @override
  String get carbsLabel => 'Carb';

  @override
  String get fatLabel => 'Mập';

  @override
  String get autoBadge => 'tự động';

  @override
  String kcalPerGram(int kcalPerGram, int kcal) {
    return '$kcalPerGram kcal/g • $kcal __SW0__';
  }

  @override
  String get mealCalorieBudget => 'Ngân sách calo bữa ăn';

  @override
  String mealBudgetBalanced(int total, int goal) {
    return 'Tổng số $total kcal = Mục tiêu $goal __SW0__';
  }

  @override
  String mealBudgetRemaining(int total, int goal, int remaining) {
    return 'Tổng cộng $total / $goal kcal (còn lại $remaining)';
  }

  @override
  String get lockMealsHint => 'Khóa 3 bữa để tự động tính ngày thứ 4';

  @override
  String get breakfastLabel => 'Bữa sáng';

  @override
  String get lunchLabel => 'Bữa trưa';

  @override
  String get dinnerLabel => 'Bữa tối';

  @override
  String get snackLabel => 'Đồ ăn vặt';

  @override
  String percentOfDailyGoal(String percent) {
    return '$percent% mục tiêu hàng ngày';
  }

  @override
  String get smartSuggestionRange => 'Phạm vi đề xuất thông minh';

  @override
  String get smartSuggestionHow => 'Đề xuất thông minh hoạt động như thế nào?';

  @override
  String smartSuggestionDesc(int threshold, int min, int max) {
    return 'Chúng tôi đề xuất các món ăn từ Bữa ăn của tôi, nguyên liệu và bữa ăn của ngày hôm qua phù hợp với ngân sách mỗi bữa của bạn.\n\nNgưỡng này kiểm soát mức độ linh hoạt của các đề xuất. Ví dụ: nếu ngân sách ăn trưa của bạn là 700 kcal và ngưỡng là $threshold __SW0__, chúng tôi sẽ đề xuất các món ăn trong khoảng $min–$max __SW0__.';
  }

  @override
  String get suggestionThreshold => 'Ngưỡng đề xuất';

  @override
  String suggestionThresholdDesc(int threshold) {
    return 'Cho phép thực phẩm ± $threshold kcal từ ngân sách bữa ăn';
  }

  @override
  String get goalsSavedSuccess => 'Đã lưu mục tiêu thành công!';

  @override
  String get canOnlyLockTwoMacros => 'Chỉ có thể khóa 2 macro cùng lúc';

  @override
  String get canOnlyLockThreeMeals =>
      'Chỉ được khóa 3 bữa; lần thứ 4 tự động tính toán';

  @override
  String get tabMeals => 'Các bữa ăn';

  @override
  String get tabIngredients => 'Thành phần';

  @override
  String get searchMealsOrIngredients => 'Tìm kiếm bữa ăn hoặc thành phần...';

  @override
  String get createNewMeal => 'Tạo bữa ăn mới';

  @override
  String get addIngredient => 'Thêm thành phần';

  @override
  String get noMealsYet => 'Chưa có bữa ăn nào';

  @override
  String get noMealsYetDesc =>
      'Phân tích thực phẩm bằng AI để tự động lưu bữa ăn\nhoặc tạo một cách thủ công';

  @override
  String get noIngredientsYet => 'Chưa có thành phần nào';

  @override
  String get noIngredientsYetDesc =>
      'Khi bạn phân tích thực phẩm bằng AI\nthành phần sẽ được lưu tự động';

  @override
  String mealCreated(String name) {
    return 'Đã tạo \"$name\"';
  }

  @override
  String mealLogged(String name) {
    return 'Đã ghi nhật ký \"$name\"';
  }

  @override
  String ingredientAmount(String unit) {
    return 'Số tiền ($unit)';
  }

  @override
  String ingredientLogged(String name, String amount, String unit) {
    return 'Đã ghi \"$name\" $amount$unit';
  }

  @override
  String get mealNotFound => 'Không tìm thấy bữa ăn';

  @override
  String mealUpdated(String name) {
    return 'Đã cập nhật \"$name\"';
  }

  @override
  String get deleteMealTitle => 'Xóa bữa ăn?';

  @override
  String deleteMealMessage(String name) {
    return '\"$name\"';
  }

  @override
  String get deleteMealNote => 'Thành phần sẽ không bị xóa.';

  @override
  String get mealDeleted => 'Đã xóa bữa ăn';

  @override
  String ingredientCreated(String name) {
    return 'Đã tạo \"$name\"';
  }

  @override
  String get ingredientNotFound => 'Không tìm thấy thành phần';

  @override
  String ingredientUpdated(String name) {
    return 'Đã cập nhật \"$name\"';
  }

  @override
  String get deleteIngredientTitle => 'Xóa thành phần?';

  @override
  String deleteIngredientMessage(String name) {
    return '\"$name\"';
  }

  @override
  String get ingredientDeleted => 'Thành phần đã bị xóa';

  @override
  String get noIngredientsData => 'Không có dữ liệu thành phần';

  @override
  String ingredientDetail(String name, String amount, String unit) {
    return '$name ($amount $unit)';
  }

  @override
  String ingredientCalories(int calories) {
    return '$calories kcal';
  }

  @override
  String get useThisMeal => 'Sử dụng bữa ăn này';

  @override
  String errorLoading(String error) {
    return 'Lỗi tải: $error';
  }

  @override
  String scanFoundNewImages(int count, String date) {
    return 'Đã tìm thấy $count hình ảnh mới trên $date';
  }

  @override
  String scanNoNewImages(String date) {
    return 'Không tìm thấy hình ảnh mới nào trên $date';
  }

  @override
  String aiAnalysisRemaining(int remaining, int total) {
    return 'Phân tích AI: $remaining/$total còn lại hôm nay';
  }

  @override
  String get upgradeToProUnlimited =>
      'Nâng cấp lên Pro để sử dụng không giới hạn';

  @override
  String get upgrade => 'Nâng cấp';

  @override
  String get confirmDelete => 'Xác nhận Xóa';

  @override
  String confirmDeleteMessage(String name) {
    return 'Bạn có muốn xóa \"$name\" không?';
  }

  @override
  String get entryDeletedSuccess => '✅ Xóa bài viết thành công';

  @override
  String entryDeleteError(String error) {
    return '❌ Lỗi: $error';
  }

  @override
  String batchAnalyzeItems(int count) {
    return '$count mặt hàng (đợt)';
  }

  @override
  String analyzeCancelled(int success) {
    return 'Đã hủy — đã phân tích thành công $success mục';
  }

  @override
  String analyzeSuccessAll(int success) {
    return '✅ Đã phân tích thành công $success mục';
  }

  @override
  String analyzeSuccessPartial(int success, int total, int failed) {
    return '⚠️ Đã phân tích $success/$total mục ($failed không thành công)';
  }

  @override
  String analyzeProgress(String item, int current, int total) {
    return '$item ($current/$total)';
  }

  @override
  String get pullToScanMeal => 'Kéo để quét bữa ăn của bạn';

  @override
  String get analyzeAll => 'Phân tích tất cả';

  @override
  String get addFoodTitle => 'Thêm thức ăn';

  @override
  String get foodNameRequired => 'Tên món ăn *';

  @override
  String get foodNameHint => 'Nhập để tìm kiếm, ví dụ: cơm chiên, gỏi đu đủ';

  @override
  String get selectedFromMyMeal =>
      '✅ Được chọn từ Bữa ăn của tôi - dữ liệu dinh dưỡng được tự động điền';

  @override
  String get foundInDatabase =>
      '✅ Có trong cơ sở dữ liệu — dữ liệu dinh dưỡng được tự động điền';

  @override
  String get saveAndAnalyze => 'Lưu & Phân tích';

  @override
  String get notFoundInDatabase =>
      'Không tìm thấy trong cơ sở dữ liệu - sẽ được phân tích ở chế độ nền';

  @override
  String get amountLabel => 'Số lượng';

  @override
  String get unitLabel => 'Đơn vị';

  @override
  String get nutritionAutoCalculated => 'Dinh dưỡng (tự động tính theo lượng)';

  @override
  String get nutritionEnterZero => 'Dinh dưỡng (nhập 0 nếu không biết)';

  @override
  String get caloriesLabel => 'Lượng calo (kcal)';

  @override
  String get proteinLabelShort => 'Protein (g)';

  @override
  String get carbsLabelShort => 'Carb (g)';

  @override
  String get fatLabelShort => 'Chất béo (g)';

  @override
  String get mealTypeLabel => 'Loại bữa ăn';

  @override
  String get pleaseEnterFoodNameFirst => 'Vui lòng nhập tên món ăn trước';

  @override
  String get savedAnalyzingBackground => '✅ Đã lưu - phân tích ở chế độ nền';

  @override
  String get foodAdded => '✅ Bổ sung thực phẩm';

  @override
  String get suggestionSourceMyMeal => 'Bữa ăn của tôi';

  @override
  String get suggestionSourceIngredient => 'Nguyên liệu';

  @override
  String get suggestionSourceDatabase => 'Cơ sở dữ liệu';

  @override
  String get editFoodTitle => 'Chỉnh sửa món ăn';

  @override
  String get foodNameLabel => 'Tên món ăn';

  @override
  String get changeAmountAutoUpdate =>
      'Thay đổi lượng → lượng calo tự động cập nhật';

  @override
  String baseNutrition(int calories, String unit) {
    return 'Cơ sở: $calories kcal / 1 $unit';
  }

  @override
  String get calculatedFromIngredients => 'Tính từ các thành phần dưới đây';

  @override
  String get ingredientsEditable => 'Thành phần (có thể chỉnh sửa)';

  @override
  String get addIngredientButton => 'Thêm vào';

  @override
  String get noIngredientsAddHint =>
      'Không có thành phần nào — nhấn \"Thêm\" để thêm thành phần mới';

  @override
  String get editIngredientsHint =>
      'Chỉnh sửa tên/số tiền → Nhấn vào biểu tượng tìm kiếm để tìm kiếm cơ sở dữ liệu hoặc AI';

  @override
  String get ingredientNameHint => 'ví dụ. Trứng gà';

  @override
  String get searchDbOrAi => 'Tìm kiếm cơ sở dữ liệu/AI';

  @override
  String get amountHint => 'Số lượng';

  @override
  String get fromDatabase => 'Từ cơ sở dữ liệu';

  @override
  String subIngredients(int count) {
    return 'Thành phần phụ ($count)';
  }

  @override
  String get addSubIngredient => 'Thêm vào';

  @override
  String get subIngredientNameHint => 'Tên thành phần phụ';

  @override
  String get amountShort => 'số tiền';

  @override
  String get pleaseEnterSubIngredientName =>
      'Vui lòng nhập tên thành phần phụ trước';

  @override
  String foundInDatabaseSub(String name) {
    return 'Đã tìm thấy \"$name\" trong cơ sở dữ liệu!';
  }

  @override
  String aiAnalyzedSub(String name) {
    return 'AI đã phân tích \"$name\" (-1 Năng lượng)';
  }

  @override
  String get couldNotAnalyzeSub => 'Không thể phân tích thành phần phụ';

  @override
  String get pleaseEnterIngredientName => 'Vui lòng nhập tên thành phần';

  @override
  String get reAnalyzeTitle => 'Phân tích lại?';

  @override
  String reAnalyzeMessage(String name) {
    return '\"$name\" đã có dữ liệu dinh dưỡng.\n\nPhân tích lại sẽ tiêu tốn 1 Năng lượng.\n\nTiếp tục?';
  }

  @override
  String get reAnalyzeButton => 'Phân tích lại (1 Năng lượng)';

  @override
  String get amountNotSpecified => 'Số tiền không được chỉ định';

  @override
  String amountNotSpecifiedMessage(String name) {
    return 'Vui lòng chỉ định số tiền cho \"$name\" trước\nHoặc sử dụng 100 g mặc định?';
  }

  @override
  String get useDefault100g => 'Dùng 100g';

  @override
  String aiAnalyzedResult(String name, int calories) {
    return 'AI: \"$name\" → $calories kcal';
  }

  @override
  String get unableToAnalyze => 'Không thể phân tích';

  @override
  String get today => 'Hôm nay';

  @override
  String get savedSuccessfully => '✅ Lưu thành công';

  @override
  String get confirmFoodPhoto => 'Xác nhận ảnh món ăn';

  @override
  String get photoSavedAutomatically => 'Ảnh được lưu tự động';

  @override
  String get foodNameHintExample => 'ví dụ: salad gà nướng';

  @override
  String get quantityLabel => 'Số lượng';

  @override
  String get quantityHint => '1';

  @override
  String get optionalFoodInfo =>
      'Việc nhập tên và số lượng thực phẩm là tùy chọn, nhưng việc cung cấp chúng sẽ cải thiện độ chính xác của phân tích AI.';

  @override
  String get saveOnly => 'Chỉ lưu';

  @override
  String get pleaseEnterValidQuantity => 'Vui lòng nhập số lượng hợp lệ';

  @override
  String analyzedResult(String name, int calories) {
    return '✅ Đã phân tích: $name — $calories kcal';
  }

  @override
  String get couldNotAnalyzeSaved =>
      '⚠️ Không thể phân tích - đã lưu, sử dụng \"Phân tích tất cả\" sau';

  @override
  String get savedAnalyzeLater =>
      '✅ Đã lưu — phân tích sau với \"Phân tích tất cả\"';

  @override
  String get editIngredientTitle => 'Chỉnh sửa thành phần';

  @override
  String get ingredientNameRequired => 'Tên thành phần *';

  @override
  String get baseAmountLabel => 'Số tiền cơ bản';

  @override
  String get baseAmountHint => '100';

  @override
  String nutritionPerBase(String amount, String unit) {
    return 'Dinh dưỡng trên $amount $unit';
  }

  @override
  String nutritionCalculatedPerBase(String amount, String unit) {
    return 'Dinh dưỡng được tính trên $amount $unit — hệ thống sẽ tự động tính toán dựa trên lượng tiêu thụ thực tế';
  }

  @override
  String get createIngredient => 'Tạo thành phần';

  @override
  String get saveChanges => 'Lưu thay đổi';

  @override
  String get pleaseEnterIngredientNameFirst =>
      'Vui lòng nhập tên thành phần trước';

  @override
  String aiAnalyzedIngredient(
      String name, String amount, String unit, int calories) {
    return 'AI: \"$name\" $amount $unit → $calories kcal';
  }

  @override
  String get unableToFindIngredient => 'Không thể tìm thấy thành phần này';

  @override
  String searchFailed(String error) {
    return 'Tìm kiếm không thành công: $error';
  }

  @override
  String deleteEntriesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Entries',
      one: 'Entry',
    );
    return 'Xóa $count $_temp0 khác?';
  }

  @override
  String deleteEntriesMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return 'Xóa $count thực phẩm đã chọn $_temp0?';
  }

  @override
  String get deleteAll => 'Xóa tất cả';

  @override
  String deletedEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return 'Đã xóa $count $_temp0';
  }

  @override
  String movedEntriesToDate(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return 'Đã chuyển $count $_temp0 sang $date';
  }

  @override
  String get allSelectedAlreadyAnalyzed =>
      'Tất cả các mục đã chọn đã được phân tích';

  @override
  String analyzeCancelledSelected(int success) {
    return 'Đã hủy — $success đã phân tích';
  }

  @override
  String analyzedEntriesAll(int success) {
    String _temp0 = intl.Intl.pluralLogic(
      success,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return 'Đã phân tích $success $_temp0';
  }

  @override
  String analyzedEntriesPartial(int success, int total, int failed) {
    return 'Đã phân tích $success/$total ($failed không thành công)';
  }

  @override
  String analyzeProgressSelected(int current, int total, String item) {
    return '$current/$total $item';
  }

  @override
  String get noEntriesYet => 'Chưa có mục nào';

  @override
  String get selectAll => 'Chọn tất cả';

  @override
  String get deselectAll => 'Bỏ chọn tất cả';

  @override
  String get moveToDate => 'Chuyển đến ngày';

  @override
  String get analyzeSelected => 'Phân tích đã chọn';

  @override
  String get deleteTooltip => 'Xóa bỏ';

  @override
  String get move => 'Di chuyển';

  @override
  String get deleteTooltipAction => 'Xóa bỏ';

  @override
  String switchToModeTitle(String mode) {
    return 'Chuyển sang chế độ $mode?';
  }

  @override
  String switchToModeMessage(String current, String newMode) {
    return 'Mục này được phân tích là $current.\n\nPhân tích lại thành $newMode sẽ tiêu tốn 1 Năng lượng.\n\nTiếp tục?';
  }

  @override
  String analyzingAsMode(String mode) {
    return 'Đang phân tích dưới dạng $mode...';
  }

  @override
  String reAnalyzedAsMode(String mode) {
    return '✅ Phân tích lại thành $mode';
  }

  @override
  String get analysisFailed => '❌ Phân tích thất bại';

  @override
  String get aiAnalysisComplete => '✅ AI phân tích và lưu trữ';

  @override
  String get changeMealType => 'Thay đổi loại bữa ăn';

  @override
  String get moveToAnotherDate => 'Chuyển sang ngày khác';

  @override
  String currentDate(String date) {
    return 'Hiện tại: $date';
  }

  @override
  String get cancelDateChange => 'Hủy thay đổi ngày';

  @override
  String get undo => 'Hoàn tác';

  @override
  String get chatHistory => 'Lịch sử trò chuyện';

  @override
  String get newChat => 'Trò chuyện mới';

  @override
  String get quickActions => 'Thao tác nhanh';

  @override
  String get clear => 'Thông thoáng';

  @override
  String get helloImMiro => 'Xin chào! Tôi là Miro';

  @override
  String get tellMeWhatYouAteToday => 'Hãy cho tôi biết hôm nay bạn đã ăn gì!';

  @override
  String get tellMeWhatYouAte => 'Hãy cho tôi biết bạn đã ăn gì...';

  @override
  String get clearHistoryTitle => 'Xóa lịch sử?';

  @override
  String get clearHistoryMessage =>
      'Tất cả tin nhắn trong phiên này sẽ bị xóa.';

  @override
  String get chatHistoryTitle => 'Lịch sử trò chuyện';

  @override
  String get newLabel => 'Mới';

  @override
  String get noChatHistoryYet => 'Chưa có lịch sử trò chuyện';

  @override
  String get active => 'Tích cực';

  @override
  String get deleteChatTitle => 'Xóa cuộc trò chuyện?';

  @override
  String deleteChatMessage(String title) {
    return 'Xóa \"$title\"?';
  }

  @override
  String weeklySummaryTitle(String start, String end) {
    return '📊 Tổng hợp hàng tuần ($start - $end)';
  }

  @override
  String daySummary(String day, String calories, String emoji, String diff) {
    return '📅 $day: $calories kcal $emoji ($diff)';
  }

  @override
  String overTarget(String amount) {
    return '$amount vượt mục tiêu';
  }

  @override
  String underTarget(String amount) {
    return '$amount dưới mục tiêu';
  }

  @override
  String get noFoodLoggedThisWeek =>
      'Chưa có món ăn nào được ghi lại trong tuần này.';

  @override
  String averageKcalPerDay(String average) {
    return '🔥 Trung bình: $average kcal/ngày';
  }

  @override
  String targetKcalPerDay(String target) {
    return '🎯 Mục tiêu: $target kcal/ngày';
  }

  @override
  String resultOverTarget(String amount) {
    return '📈 Kết quả: $amount kcal vượt mục tiêu';
  }

  @override
  String resultUnderTarget(String amount) {
    return '📈 Kết quả: $amount kcal dưới mục tiêu — Làm tốt lắm! 💪';
  }

  @override
  String failedToLoadWeeklySummary(String error) {
    return '❌ Không tải được tóm tắt hàng tuần: $error';
  }

  @override
  String monthlySummaryTitle(String month, int year) {
    return '📊 Tóm tắt hàng tháng ($month $year)';
  }

  @override
  String totalDays(int days) {
    return '📅 Tổng số ngày: $days';
  }

  @override
  String totalConsumed(String calories) {
    return '🔥 Tổng lượng tiêu thụ: $calories kcal';
  }

  @override
  String targetTotal(String target) {
    return '🎯 Tổng mục tiêu: $target kcal';
  }

  @override
  String averageKcalPerDayShort(String average) {
    return '📈 Trung bình: $average kcal/ngày';
  }

  @override
  String overTargetThisMonth(String amount) {
    return '⚠️ $amount kcal vượt mục tiêu tháng này';
  }

  @override
  String underTargetThisMonth(String amount) {
    return '✅ $amount kcal dưới mục tiêu — Tuyệt vời! 💪';
  }

  @override
  String failedToLoadMonthlySummary(String error) {
    return '❌ Không tải được bản tóm tắt hàng tháng: $error';
  }

  @override
  String get localAiHelpTitle => '🤖 Trợ giúp AI cục bộ';

  @override
  String get localAiHelpFormat => 'Định dạng: [thực phẩm] [số lượng] [đơn vị]';

  @override
  String get localAiHelpExamples =>
      'Ví dụ:\n• thịt gà 100g và cơm 200g\n• pizza 2 lát\n• táo 1 miếng, chuối 1 miếng';

  @override
  String get localAiHelpNote =>
      'Lưu ý: chỉ có tiếng Anh, phân tích cú pháp cơ bản\nChuyển sang Miro AI để có kết quả tốt hơn!';

  @override
  String hiNoFoodLogged(String target) {
    return '🤖 Xin chào! Hôm nay chưa có món ăn nào được ghi lại.\n   Mục tiêu: $target kcal — Sẵn sàng bắt đầu ghi nhật ký chưa? 🍽️';
  }

  @override
  String hiKcalLeft(String remaining) {
    return '🤖 Xin chào! Bạn còn $remaining kcal cho ngày hôm nay.\n   Sẵn sàng để đăng nhập bữa ăn của bạn? 😊';
  }

  @override
  String hiOverTarget(String calories, String over) {
    return '🤖 Xin chào! Bạn đã tiêu thụ $calories kcal hôm nay.\n   $over __SW0__ vượt mục tiêu — Hãy tiếp tục theo dõi! 💪';
  }

  @override
  String get hiReadyToLog =>
      '🤖 Xin chào! Sẵn sàng để đăng nhập bữa ăn của bạn? 😊';

  @override
  String get notEnoughEnergy => 'Không đủ năng lượng';

  @override
  String get thinkingMealIdeas =>
      '🤖 Đang nghĩ ra ý tưởng cho bữa ăn tuyệt vời dành cho bạn...';

  @override
  String get recentMeals => 'Bữa ăn gần đây:';

  @override
  String get noRecentFood => 'Không có thực phẩm gần đây được ghi lại.';

  @override
  String remainingCaloriesToday(String remaining) {
    return '. Lượng calo còn lại hôm nay: $remaining kcal.';
  }

  @override
  String failedToGetMenuSuggestions(String error) {
    return '❌ Không nhận được gợi ý menu: $error';
  }

  @override
  String get mealSuggestionsTitle =>
      '🤖 Dựa trên nhật ký ăn uống của bạn, đây là 3 gợi ý về bữa ăn:';

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
  String get pickOneAndLog => 'Hãy chọn một cái và tôi sẽ ghi nó cho bạn! 😊';

  @override
  String energyCost(int cost) {
    return '⚡ -$cost Năng lượng';
  }

  @override
  String get giveMeTipsForHealthyEating =>
      'Hãy cho tôi lời khuyên để ăn uống lành mạnh';

  @override
  String get howManyCaloriesToday => 'Hôm nay có bao nhiêu calo?';

  @override
  String get menuLabel => 'Thực đơn';

  @override
  String get weeklyLabel => 'hàng tuần';

  @override
  String get monthlyLabel => 'hàng tháng';

  @override
  String get tipsLabel => 'Mẹo';

  @override
  String get summaryLabel => 'Bản tóm tắt';

  @override
  String get helpLabel => 'Giúp đỡ';

  @override
  String get onboardingWelcomeSubtitle =>
      'Theo dõi lượng calo dễ dàng\nvới phân tích được hỗ trợ bởi AI';

  @override
  String get onboardingSnap => 'Chụp nhanh';

  @override
  String get onboardingSnapDesc => 'AI phân tích ngay lập tức';

  @override
  String get onboardingType => 'Kiểu';

  @override
  String get onboardingTypeDesc => 'Đăng nhập vài giây';

  @override
  String get onboardingEdit => 'Biên tập';

  @override
  String get onboardingEditDesc => 'Tinh chỉnh độ chính xác';

  @override
  String get onboardingNext => 'Tiếp theo →';

  @override
  String get onboardingDisclaimer =>
      'Dữ liệu ước tính của AI. Không phải lời khuyên y tế.';

  @override
  String get onboardingQuickSetup => 'Thiết lập nhanh';

  @override
  String get onboardingHelpAiUnderstand =>
      'Giúp AI hiểu rõ hơn về thực phẩm của bạn';

  @override
  String get onboardingYourTypicalCuisine => 'Món ăn đặc trưng của bạn:';

  @override
  String get onboardingDailyCalorieGoal =>
      'Mục tiêu calo hàng ngày (tùy chọn):';

  @override
  String get onboardingKcalPerDay => 'kcal/ngày';

  @override
  String get onboardingCalorieGoalHint => '2000';

  @override
  String get onboardingCanChangeAnytime =>
      'Bạn có thể thay đổi điều này bất kỳ lúc nào trong phần cài đặt tệp Pro';

  @override
  String get onboardingYoureAllSet => 'Bạn đã hoàn tất!';

  @override
  String get onboardingStartTracking =>
      'Bắt đầu theo dõi bữa ăn của bạn ngay hôm nay.\nChụp ảnh hoặc nhập những gì bạn đã ăn.';

  @override
  String get onboardingWelcomeGift => 'Quà chào mừng';

  @override
  String get onboardingFreeEnergy => '10 năng lượng MIỄN PHÍ';

  @override
  String get onboardingFreeEnergyDesc => '= 10 phân tích AI để bắt đầu';

  @override
  String get onboardingEnergyCost =>
      'Mỗi lần phân tích tốn 1 Năng lượng\nBạn càng sử dụng nhiều, bạn càng kiếm được nhiều tiền!';

  @override
  String get onboardingStartTrackingButton => 'Bắt đầu theo dõi! →';

  @override
  String get onboardingNoCreditCard =>
      'Không có thẻ tín dụng • Không có phí ẩn';

  @override
  String get cameraTakePhotoOfFood => 'Chụp ảnh món ăn của bạn';

  @override
  String get cameraFailedToInitialize => 'Không khởi tạo được máy ảnh';

  @override
  String get cameraFailedToCapture => 'Không chụp được ảnh';

  @override
  String get cameraFailedToPickFromGallery =>
      'Không thể chọn hình ảnh từ thư viện';

  @override
  String get cameraProcessing => 'Prođừng...';

  @override
  String get referralInviteFriends => 'Mời bạn bè';

  @override
  String get referralYourReferralCode => 'Mã giới thiệu của bạn';

  @override
  String get referralLoading => 'Đang tải...';

  @override
  String get referralCopy => 'Sao chép';

  @override
  String get referralShareCodeDescription =>
      'Chia sẻ mã này với bạn bè! Khi họ sử dụng AI 3 lần, cả hai bạn đều nhận được phần thưởng!';

  @override
  String get referralEnterReferralCode => 'Nhập mã giới thiệu';

  @override
  String get referralCodeHint => 'MIRO-XXXX-XXXX-XXXX';

  @override
  String get referralSubmitCode => 'Gửi mã';

  @override
  String get referralPleaseEnterCode => 'Vui lòng nhập mã giới thiệu';

  @override
  String get referralCodeAccepted => 'Mã giới thiệu được chấp nhận!';

  @override
  String get referralCodeCopied => 'Mã giới thiệu được sao chép vào clipboard!';

  @override
  String referralEnergyBonus(int energy) {
    return '+$energy Năng lượng!';
  }

  @override
  String get referralHowItWorks => 'Nó hoạt động như thế nào';

  @override
  String get referralStep1Title => 'Chia sẻ mã giới thiệu của bạn';

  @override
  String get referralStep1Description =>
      'Sao chép và chia sẻ ID MiRO của bạn với bạn bè';

  @override
  String get referralStep2Title => 'Bạn bè nhập mã của bạn';

  @override
  String get referralStep2Description =>
      'Họ nhận được +20 Năng lượng ngay lập tức';

  @override
  String get referralStep3Title => 'Người bạn sử dụng AI 3 lần';

  @override
  String get referralStep3Description => 'Khi họ hoàn thành 3 phân tích AI';

  @override
  String get referralStep4Title => 'Bạn nhận được phần thưởng!';

  @override
  String get referralStep4Description => 'Bạn nhận được +5 Năng lượng!';

  @override
  String get tierBenefitsTitle => 'Lợi ích theo cấp độ';

  @override
  String get tierBenefitsUnlockRewards =>
      'Mở khóa phần thưởng\nvới chuỗi hàng ngày';

  @override
  String get tierBenefitsKeepStreakDescription =>
      'Hãy duy trì chuỗi của bạn để mở khóa các cấp cao hơn và kiếm được những lợi ích đáng kinh ngạc!';

  @override
  String get tierBenefitsHowItWorks => 'Nó hoạt động như thế nào';

  @override
  String get tierBenefitsDailyEnergyReward =>
      'Phần thưởng năng lượng hàng ngày';

  @override
  String get tierBenefitsDailyEnergyDescription =>
      'Sử dụng AI ít nhất một lần mỗi ngày để kiếm thêm năng lượng. Bậc cao hơn = nhiều năng lượng hàng ngày hơn!';

  @override
  String get tierBenefitsPurchaseBonus => 'Tiền thưởng mua hàng';

  @override
  String get tierBenefitsPurchaseBonusDescription =>
      'Cấp Vàng & Kim cương nhận thêm năng lượng cho mỗi lần mua hàng (thêm 10-20%!)';

  @override
  String get tierBenefitsGracePeriod => 'Thời gian ân hạn';

  @override
  String get tierBenefitsGracePeriodDescription =>
      'Bỏ lỡ một ngày mà không mất đi kỷ lục của mình. Hạng Bạc+ được bảo vệ!';

  @override
  String get tierBenefitsAllTiers => 'Tất cả các bậc';

  @override
  String get tierBenefitsNew => 'MỚI';

  @override
  String get tierBenefitsPopular => 'PHỔ BIẾN';

  @override
  String get tierBenefitsBest => 'TỐT NHẤT';

  @override
  String get tierBenefitsDailyCheckIn => 'Nhận phòng hàng ngày';

  @override
  String get tierBenefitsProTips => 'Pro Lời khuyên';

  @override
  String get tierBenefitsTip1 =>
      'Sử dụng AI hàng ngày để kiếm năng lượng miễn phí và xây dựng chuỗi của bạn';

  @override
  String get tierBenefitsTip2 =>
      'Cấp kim cương kiếm được +4 Năng lượng mỗi ngày - tức là 120/tháng!';

  @override
  String get tierBenefitsTip3 =>
      'Phần thưởng mua hàng áp dụng cho TẤT CẢ các gói năng lượng!';

  @override
  String get tierBenefitsTip4 =>
      'Thời gian gia hạn sẽ bảo vệ chuỗi ngày của bạn nếu bạn bỏ lỡ một ngày';

  @override
  String get subscriptionEnergyPass => 'Thẻ năng lượng';

  @override
  String get subscriptionInAppPurchasesNotAvailable =>
      'Mua hàng trong ứng dụng không khả dụng';

  @override
  String get subscriptionFailedToInitiatePurchase =>
      'Không thể bắt đầu mua hàng';

  @override
  String subscriptionError(String error) {
    return 'Lỗi: $error';
  }

  @override
  String get subscriptionFailedToLoad => 'Không thể tải đăng ký';

  @override
  String get subscriptionUnknownError => 'Lỗi không xác định';

  @override
  String get subscriptionRetry => 'Thử lại';

  @override
  String get subscriptionEnergyPassActive => 'Năng lượng Pass đang hoạt động';

  @override
  String get subscriptionUnlimitedAccess =>
      'Bạn có quyền truy cập không giới hạn';

  @override
  String get subscriptionStatus => 'Trạng thái';

  @override
  String get subscriptionRenews => 'Gia hạn';

  @override
  String get subscriptionPrice => 'Giá';

  @override
  String get subscriptionYourBenefits => 'Lợi ích của bạn';

  @override
  String get subscriptionManageSubscription => 'Quản lý đăng ký';

  @override
  String get subscriptionNoProductAvailable => 'Không có sản phẩm đăng ký nào';

  @override
  String get subscriptionWhatYouGet => 'Những gì bạn nhận được';

  @override
  String get subscriptionPerMonth => 'mỗi tháng';

  @override
  String get subscriptionSubscribeNow => 'Đăng ký ngay';

  @override
  String get subscriptionCancelAnytime => 'Hủy bất cứ lúc nào';

  @override
  String get subscriptionAutoRenewTerms =>
      'Đăng ký của bạn sẽ tự động gia hạn. Bạn có thể hủy bất cứ lúc nào từ Google Play.';

  @override
  String get disclaimerHealthDisclaimer =>
      'Tuyên bố miễn trừ trách nhiệm về sức khỏe';

  @override
  String get disclaimerImportantReminders => 'Lời nhắc quan trọng:';

  @override
  String get disclaimerBullet1 => 'Tất cả dữ liệu dinh dưỡng được ước tính';

  @override
  String get disclaimerBullet2 => 'Phân tích AI có thể có lỗi';

  @override
  String get disclaimerBullet3 => 'Không thay thế cho lời khuyên chuyên nghiệp';

  @override
  String get disclaimerBullet4 =>
      'Tham khảo ý kiến ​​các nhà cung cấp dịch vụ chăm sóc sức khỏe để được hướng dẫn y tế';

  @override
  String get disclaimerBullet5 =>
      'Sử dụng theo quyết định và rủi ro của riêng bạn';

  @override
  String get disclaimerIUnderstand => 'Tôi hiểu';

  @override
  String get privacyPolicyTitle => 'Chính sách bảo mật';

  @override
  String get privacyPolicySubtitle => 'MiRO — Bản ghi thu nhập của tôi Oracle';

  @override
  String get privacyPolicyHeaderNote =>
      'Dữ liệu thực phẩm của bạn vẫn còn trên thiết bị của bạn. Cân bằng năng lượng được đồng bộ hóa an toàn qua Firebase.';

  @override
  String get privacyPolicySectionInformationWeCollect =>
      'Thông tin chúng tôi thu thập';

  @override
  String get privacyPolicySectionDataStorage => 'Lưu trữ dữ liệu';

  @override
  String get privacyPolicySectionDataTransmission =>
      'Truyền dữ liệu cho bên thứ ba';

  @override
  String get privacyPolicySectionRequiredPermissions => 'Quyền cần thiết';

  @override
  String get privacyPolicySectionSecurity => 'Bảo vệ';

  @override
  String get privacyPolicySectionUserRights => 'Quyền của người dùng';

  @override
  String get privacyPolicySectionDataRetention => 'Lưu giữ dữ liệu';

  @override
  String get privacyPolicySectionChildrenPrivacy => 'Quyền riêng tư của trẻ em';

  @override
  String get privacyPolicySectionChangesToPolicy =>
      'Những thay đổi đối với Chính sách này';

  @override
  String get privacyPolicySectionDataCollectionConsent =>
      'Đồng ý thu thập dữ liệu';

  @override
  String get privacyPolicySectionPDPACompliance =>
      'Tuân thủ PDPA (Đạo luật về dữ liệu cá nhân của Thái Lan Protection)';

  @override
  String get privacyPolicySectionContactUs => 'Liên hệ với chúng tôi';

  @override
  String get privacyPolicyEffectiveDate =>
      'Ngày có hiệu lực: 18 tháng 2 năm 2026\nCập nhật lần cuối: ngày 18 tháng 2 năm 2026';

  @override
  String get termsOfServiceTitle => 'Điều khoản dịch vụ';

  @override
  String get termsSubtitle => 'MiRO — Bản ghi thu nhập của tôi Oracle';

  @override
  String get termsSectionAcceptanceOfTerms => 'Chấp nhận các điều khoản';

  @override
  String get termsSectionServiceDescription => 'Mô tả dịch vụ';

  @override
  String get termsSectionDisclaimerOfWarranties =>
      'Từ chối trách nhiệm bảo đảm';

  @override
  String get termsSectionEnergySystemTerms => 'Điều khoản hệ thống năng lượng';

  @override
  String get termsSectionUserDataAndResponsibilities =>
      'Dữ liệu và trách nhiệm của người dùng';

  @override
  String get termsSectionBackupTransfer => 'Sao lưu & Chuyển giao';

  @override
  String get termsSectionInAppPurchases => 'Mua hàng trong ứng dụng';

  @override
  String get termsSectionProhibitedUses => 'ProSử dụng bị cấm';

  @override
  String get termsSectionIntellectualProperty => 'Trí tuệ Property';

  @override
  String get termsSectionLimitationOfLiability =>
      'Giới hạn trách nhiệm pháp lý';

  @override
  String get termsSectionServiceTermination => 'Chấm dứt dịch vụ';

  @override
  String get termsSectionChangesToTerms => 'Thay đổi điều khoản';

  @override
  String get termsSectionGoverningLaw => 'Luật điều chỉnh';

  @override
  String get termsSectionContactUs => 'Liên hệ với chúng tôi';

  @override
  String get termsAcknowledgment =>
      'Bằng cách sử dụng MiRO, bạn xác nhận rằng bạn đã đọc, hiểu và đồng ý với các Điều khoản dịch vụ này.';

  @override
  String get termsLastUpdated => 'Cập nhật lần cuối: ngày 15 tháng 2 năm 2026';

  @override
  String get profileAndSettings => 'Protệp & Cài đặt';

  @override
  String errorOccurred(String error) {
    return 'Lỗi: $error';
  }

  @override
  String get healthGoalsSection => 'Mục tiêu sức khỏe';

  @override
  String get dailyGoals => 'Mục tiêu hàng ngày';

  @override
  String get chatAiModeSection => 'Chế độ AI trò chuyện';

  @override
  String get selectAiPowersChat => 'Chọn AI hỗ trợ cuộc trò chuyện của bạn';

  @override
  String get miroAi => 'Miro AI';

  @override
  String get miroAiSubtitle =>
      'Được cung cấp bởi Gemini • Đa ngôn ngữ • Độ chính xác cao';

  @override
  String get localAi => 'AI cục bộ';

  @override
  String get localAiSubtitle =>
      'Trên thiết bị • Chỉ tiếng Anh • Độ chính xác cơ bản';

  @override
  String get free => 'Miễn phí';

  @override
  String get cuisinePreferenceSection => 'Sở thích ẩm thực';

  @override
  String get preferredCuisine => 'Món ăn ưa thích';

  @override
  String get selectYourCuisine => 'Chọn món ăn của bạn';

  @override
  String get photoScanSection => 'Quét ảnh';

  @override
  String get languageSection => 'Ngôn ngữ';

  @override
  String get languageTitle => 'Ngôn ngữ / ภาษา';

  @override
  String get selectLanguage => 'Chọn Ngôn ngữ / Ngôn ngữ';

  @override
  String get systemDefault => 'Mặc định hệ thống';

  @override
  String get systemDefaultSublabel => 'ตามระบบ';

  @override
  String get english => 'Tiếng Anh';

  @override
  String get englishSublabel => 'อังกฤษ';

  @override
  String get thai => 'ไทย (Thái)';

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
  String get closeBilingual => 'Đóng / ปิด';

  @override
  String languageChangedTo(String language) {
    return 'Ngôn ngữ đã thay đổi thành $language';
  }

  @override
  String get accountSection => 'Tài khoản';

  @override
  String get miroId => 'MiRO ID';

  @override
  String get miroIdCopied => 'MiRO ID đã được sao chép!';

  @override
  String get inviteFriends => 'Mời bạn bè';

  @override
  String get inviteFriendsSubtitle =>
      'Chia sẻ mã giới thiệu của bạn và kiếm phần thưởng!';

  @override
  String get unlimitedAiDoubleRewards =>
      'AI không giới hạn + Phần thưởng gấp đôi';

  @override
  String get plan => 'Kế hoạch';

  @override
  String get monthly => 'hàng tháng';

  @override
  String get started => 'Đã bắt đầu';

  @override
  String get renews => 'Gia hạn';

  @override
  String get expires => 'Hết hạn';

  @override
  String get autoRenew => 'Tự động gia hạn';

  @override
  String get on => 'TRÊN';

  @override
  String get off => 'Tắt';

  @override
  String get tapToManageSubscription => 'Nhấn để quản lý đăng ký';

  @override
  String get dataSection => 'dữ liệu';

  @override
  String get backupData => 'Sao lưu dữ liệu';

  @override
  String get backupDataSubtitle =>
      'Năng lượng + Lịch sử thực phẩm → lưu dưới dạng tệp';

  @override
  String get restoreFromBackup => 'Khôi phục từ bản sao lưu';

  @override
  String get restoreFromBackupSubtitle => 'Nhập dữ liệu từ tập tin sao lưu';

  @override
  String get clearAllDataTitle => 'Xóa tất cả dữ liệu?';

  @override
  String get clearAllDataContent =>
      'Tất cả dữ liệu sẽ bị xóa:\n• Mục món ăn\n• Bữa ăn của tôi\n• Thành phần\n• Mục tiêu\n• Thông tin cá nhân\n\nĐiều này không thể được hoàn tác!';

  @override
  String get allDataClearedSuccess => 'Tất cả dữ liệu đã được xóa thành công';

  @override
  String get aboutSection => 'Về';

  @override
  String get version => 'Phiên bản';

  @override
  String get healthDisclaimer => 'Tuyên bố miễn trừ trách nhiệm về sức khỏe';

  @override
  String get importantLegalInformation => 'Thông tin pháp lý quan trọng';

  @override
  String get showTutorialAgain => 'Hiển thị lại hướng dẫn';

  @override
  String get viewFeatureTour => 'Xem chuyến tham quan tính năng';

  @override
  String get showTutorialDialogTitle => 'Hiển thị hướng dẫn';

  @override
  String get showTutorialDialogContent =>
      'Điều này sẽ hiển thị chuyến tham quan tính năng nổi bật:\n\n• Hệ thống năng lượng\n• Quét ảnh kéo để làm mới\n• Trò chuyện với Miro AI\n\nBạn sẽ quay lại Màn hình chính.';

  @override
  String get showTutorialButton => 'Hiển thị hướng dẫn';

  @override
  String get tutorialResetMessage =>
      'Đặt lại hướng dẫn! Đi tới Màn hình chính để xem nó.';

  @override
  String get foodAnalysisTutorial => 'Hướng dẫn phân tích thực phẩm';

  @override
  String get foodAnalysisTutorialSubtitle =>
      'Tìm hiểu cách sử dụng các tính năng phân tích thực phẩm';

  @override
  String get backupCreated => 'Đã tạo bản sao lưu!';

  @override
  String get backupCreatedContent =>
      'Tệp sao lưu của bạn đã được tạo thành công.';

  @override
  String get backupChooseDestination =>
      'Bạn muốn lưu bản sao lưu của mình ở đâu?';

  @override
  String get backupSaveToDevice => 'Lưu vào thiết bị';

  @override
  String get backupSaveToDeviceDesc =>
      'Lưu vào thư mục bạn chọn trên thiết bị này';

  @override
  String get backupShareToOther => 'Chia sẻ với thiết bị khác';

  @override
  String get backupShareToOtherDesc =>
      'Gửi qua Line, Email, Google Drive, v.v.';

  @override
  String get backupSavedSuccess => 'Đã lưu bản sao lưu!';

  @override
  String get backupSavedSuccessContent =>
      'Tệp sao lưu của bạn đã được lưu vào vị trí bạn đã chọn.';

  @override
  String get important => 'Quan trọng:';

  @override
  String get backupImportantNotes =>
      '• Lưu tệp này ở nơi an toàn (Google Drive, v.v.)\n• Ảnh KHÔNG được đưa vào bản sao lưu\n• Khóa chuyển sẽ hết hạn sau 30 ngày\n• Chìa khóa chỉ được sử dụng một lần';

  @override
  String get restoreBackup => 'Khôi phục bản sao lưu?';

  @override
  String get backupFrom => 'Sao lưu từ:';

  @override
  String get date => 'Ngày:';

  @override
  String get energy => 'Năng lượng:';

  @override
  String get foodEntries => 'Mục thực phẩm:';

  @override
  String get restoreImportant => 'Quan trọng';

  @override
  String restoreImportantNotes(String energy) {
    return '• Năng lượng hiện tại trên thiết bị này sẽ được THAY THẾ bằng Năng lượng từ dự phòng ($energy)\n• Các mục thực phẩm sẽ được HỢP NHẤT (không thay thế)\n• Ảnh KHÔNG được đưa vào bản sao lưu\n• Transfer Key sẽ được sử dụng (không thể sử dụng lại)';
  }

  @override
  String get restore => 'Khôi phục';

  @override
  String get restoreComplete => 'Khôi phục hoàn tất!';

  @override
  String get restoreCompleteContent =>
      'Dữ liệu của bạn đã được khôi phục thành công.';

  @override
  String get newEnergyBalance => 'Cân bằng năng lượng mới:';

  @override
  String get foodEntriesImported => 'Mục thực phẩm nhập khẩu:';

  @override
  String get myMealsImported => 'Bữa ăn của tôi được nhập khẩu:';

  @override
  String get appWillRefresh =>
      'Ứng dụng của bạn sẽ làm mới để hiển thị dữ liệu được khôi phục.';

  @override
  String get backupFailed => 'Sao lưu không thành công';

  @override
  String get invalidBackupFile => 'Tệp sao lưu không hợp lệ';

  @override
  String get restoreFailed => 'Khôi phục không thành công';

  @override
  String get analyticsDataCollection => 'Thu thập dữ liệu phân tích';

  @override
  String get analyticsEnabled => 'Đã bật phân tích - ขอบคุณที่ช่วยปรับปรุงแอป';

  @override
  String get analyticsDisabled =>
      'Analytics bị vô hiệu hóa - ไม่เก็บข้อมูลการใช้งาน';

  @override
  String get enabled => 'Đã bật';

  @override
  String get enabledSubtitle => 'Đã bật - ช่วยปรับปรุงประสบการณ์ใช้งาน';

  @override
  String get disabled => 'Tàn tật';

  @override
  String get disabledSubtitle => 'Đã tắt - ไม่เก็บข้อมูลการใช้งาน';

  @override
  String get imagesPerDay => 'Hình ảnh mỗi ngày';

  @override
  String scanUpToImagesPerDay(String limit) {
    return 'Quét tối đa $limit hình ảnh mỗi ngày';
  }

  @override
  String get reset => 'Cài lại';

  @override
  String get resetScanHistory => 'Đặt lại lịch sử quét';

  @override
  String get resetScanHistorySubtitle =>
      'Xóa tất cả các mục được quét và quét lại';

  @override
  String get imagesPerDayDialog => 'Hình ảnh mỗi ngày';

  @override
  String get maxImagesPerDayDescription =>
      'Hình ảnh tối đa để quét mỗi ngày\nChỉ quét ngày đã chọn';

  @override
  String scanLimitSetTo(String limit) {
    return 'Đã đặt giới hạn quét thành $limit hình ảnh mỗi ngày';
  }

  @override
  String get resetScanHistoryDialog => 'Đặt lại lịch sử quét?';

  @override
  String get resetScanHistoryContent =>
      'Tất cả các mục thực phẩm được quét trong thư viện sẽ bị xóa.\nKéo xuống bất kỳ ngày nào để quét lại hình ảnh.';

  @override
  String resetComplete(String count) {
    return 'Đặt lại hoàn tất - $count mục đã bị xóa. Kéo xuống để quét lại.';
  }

  @override
  String questBarStreak(int days) {
    return 'Chuỗi $days ngày';
  }

  @override
  String questBarDaysToNextTier(int days, String tier) {
    return '$days ngày → $tier';
  }

  @override
  String get questBarMaxTier => 'Cấp tối đa! 💎';

  @override
  String get questBarOfferDismissed => 'Ưu đãi bị ẩn';

  @override
  String get questBarViewOffer => 'Xem ưu đãi';

  @override
  String get questBarNoOffersNow => '• Hiện không có ưu đãi nào';

  @override
  String get questBarWeeklyChallenges => '🎯 Thử thách hàng tuần';

  @override
  String get questBarMilestones => '🏆 Các mốc quan trọng';

  @override
  String get questBarInviteFriends => '👥 Mời bạn bè và nhận 20E';

  @override
  String questBarTimeRemaining(String time) {
    return '⏰ Thời gian còn lại $time';
  }

  @override
  String questBarClaimDailyEnergy(int energy) {
    return '+${energy}E';
  }

  @override
  String questBarShareReferralError(String error) {
    return 'Lỗi chia sẻ: $error';
  }

  @override
  String tierCelebrationTitle(String tier) {
    return '$tier Lễ kỷ niệm 🎉';
  }

  @override
  String tierCelebrationDay(int day) {
    return 'Ngày $day';
  }

  @override
  String get tierCelebrationExpired => 'Hết hạn';

  @override
  String get tierCelebrationComplete => 'Hoàn thành!';

  @override
  String questBarWatchAd(int energy) {
    return 'Xem Quảng cáo +$energy⚡';
  }

  @override
  String questBarAdRemaining(int remaining, int total) {
    return '$remaining/$total còn lại hôm nay';
  }

  @override
  String questBarAdSuccess(int energy) {
    return 'Quảng cáo đã xem! +$energy Năng lượng đi vào...';
  }

  @override
  String get questBarAdNotReady => 'Quảng cáo chưa sẵn sàng, vui lòng thử lại';

  @override
  String get questBarDailyChallenge => 'Thử thách hàng ngày';

  @override
  String get questBarUseAi => 'Sử dụng năng lượng';

  @override
  String get questBarResetsMonday => 'Đặt lại vào thứ Hai hàng tuần';

  @override
  String get questBarClaimed => 'Đã xác nhận quyền sở hữu!';

  @override
  String get questBarHideOffer => 'Trốn';

  @override
  String get questBarViewDetails => 'Xem';

  @override
  String questBarShareText(String link) {
    return 'Hãy thử MiRO! Phân tích thực phẩm được hỗ trợ bởi AI 🍔\nSử dụng liên kết này và cả hai chúng ta đều nhận được +20 Năng lượng miễn phí!\n\n$link';
  }

  @override
  String get questBarShareSubject => 'Hãy thử MiRO';

  @override
  String get claimButtonTitle => 'Yêu cầu năng lượng hàng ngày';

  @override
  String claimButtonReceived(String energy) {
    return 'Đã nhận được +${energy}E!';
  }

  @override
  String get claimButtonAlreadyClaimed => 'Đã xác nhận hôm nay';

  @override
  String claimButtonError(String error) {
    return 'Lỗi: $error';
  }

  @override
  String get seasonalQuestLimitedTime => 'THỜI GIAN CÓ HẠN';

  @override
  String seasonalQuestDaysLeft(int days) {
    return '$days ngày còn lại';
  }

  @override
  String seasonalQuestRewardDaily(int reward) {
    return '+${reward}E/ngày';
  }

  @override
  String seasonalQuestRewardOnce(int reward) {
    return '+${reward}E một lần';
  }

  @override
  String get seasonalQuestClaimed => 'Đã xác nhận quyền sở hữu!';

  @override
  String get seasonalQuestClaimedToday => 'Đã xác nhận hôm nay';

  @override
  String get errorFailed => 'Thất bại';

  @override
  String get errorFailedToClaim => 'Không thể yêu cầu';

  @override
  String errorGeneric(String error) {
    return 'Lỗi: $error';
  }

  @override
  String get milestoneNoMilestonesToClaim => 'Chưa có cột mốc nào để yêu cầu';

  @override
  String milestoneClaimedEnergy(int energy) {
    return '🎁 Đã xác nhận +$energy Năng lượng!';
  }

  @override
  String get milestoneTitle => 'Các cột mốc quan trọng';

  @override
  String milestoneUseEnergyComplete(int threshold) {
    return 'Sử dụng năng lượng $threshold';
  }

  @override
  String milestoneNext(int threshold) {
    return 'Tiếp theo: ${threshold}E';
  }

  @override
  String get milestoneAllComplete => 'Tất cả các cột mốc đã hoàn thành!';

  @override
  String get noEnergyTitle => 'Hết năng lượng';

  @override
  String get noEnergyContent =>
      'Bạn cần 1 Năng lượng để phân tích thực phẩm bằng AI';

  @override
  String get noEnergyTip =>
      'Bạn vẫn có thể đăng nhập đồ ăn thủ công (không cần AI) miễn phí';

  @override
  String get noEnergyLater => 'Sau đó';

  @override
  String noEnergyWatchAd(int remaining) {
    return 'Xem Quảng Cáo ($remaining/3)';
  }

  @override
  String get noEnergyBuyEnergy => 'Mua năng lượng';

  @override
  String get tierBronze => 'đồng';

  @override
  String get tierSilver => 'Bạc';

  @override
  String get tierGold => 'Vàng';

  @override
  String get tierDiamond => 'Kim cương';

  @override
  String get tierStarter => 'người mới bắt đầu';

  @override
  String get tierUpCongratulations => '🎉 Xin chúc mừng!';

  @override
  String tierUpYouReached(String tier) {
    return 'Bạn đã đạt đến $tier!';
  }

  @override
  String get tierUpMotivation =>
      'Theo dõi lượng calo như một người chuyên nghiệp\nCơ thể mơ ước của bạn đang đến gần hơn!';

  @override
  String tierUpReward(int reward) {
    return '+${reward}E Phần thưởng!';
  }

  @override
  String get referralAllLevelsClaimed => 'Tất cả các cấp độ được yêu cầu!';

  @override
  String referralLevel(int level, String subtitle) {
    return 'Cấp độ $level: $subtitle';
  }

  @override
  String referralProgress(int current, int target, int level, int total) {
    return '[$current/$target] (Cấp $level/$total)';
  }

  @override
  String referralClaimedLevel(int level, int reward) {
    return '🎁 Cấp yêu cầu $level: +$reward Năng lượng!';
  }

  @override
  String get challengeUseAi10 => 'Sử dụng năng lượng 10';

  @override
  String get specifyIngredients => 'Chỉ định các thành phần đã biết';

  @override
  String get specifyIngredientsOptional =>
      'Chỉ định các thành phần đã biết (tùy chọn)';

  @override
  String get specifyIngredientsHint =>
      'Nhập các thành phần bạn biết và AI sẽ khám phá các loại gia vị, dầu và nước sốt ẩn cho bạn.';

  @override
  String get sendToAi => 'Gửi tới AI';

  @override
  String get reanalyzeWithIngredients => 'Thêm thành phần & phân tích lại';

  @override
  String get reanalyzeButton => 'Phân tích lại (1 Năng lượng)';

  @override
  String get ingredientsSaved => 'Đã lưu thành phần';

  @override
  String get pleaseAddAtLeastOneIngredient =>
      'Vui lòng thêm ít nhất 1 thành phần';

  @override
  String get hiddenIngredientsDiscovered =>
      'Thành phần ẩn được phát hiện bởi AI';

  @override
  String get retroScanTitle => 'Quét ảnh gần đây?';

  @override
  String get retroScanDescription =>
      'Chúng tôi có thể quét ảnh của bạn trong 7 ngày qua để tự động tìm ảnh đồ ăn và thêm chúng vào nhật ký của bạn.';

  @override
  String get retroScanNote =>
      'Chỉ phát hiện được ảnh đồ ăn - các ảnh khác sẽ bị bỏ qua. Không có ảnh nào rời khỏi thiết bị của bạn.';

  @override
  String get retroScanStart => 'Quét ảnh của tôi';

  @override
  String get retroScanSkip => 'Bỏ qua bây giờ';

  @override
  String get retroScanInProgress => 'Đang quét...';

  @override
  String get retroScanTagline =>
      'MiRO đang biến đổi bạn\nảnh thực phẩm vào dữ liệu sức khỏe.';

  @override
  String get retroScanFetchingPhotos => 'Đang tìm nạp các ảnh gần đây...';

  @override
  String get retroScanAnalyzing => 'Đang phát hiện ảnh đồ ăn...';

  @override
  String retroScanPhotosFound(int count) {
    return '$count ảnh được tìm thấy trong 7 ngày qua';
  }

  @override
  String get retroScanCompleteTitle => 'Quét hoàn tất!';

  @override
  String retroScanCompleteDesc(int count) {
    return 'Đã tìm thấy $count ảnh đồ ăn! Chúng đã được thêm vào dòng thời gian của bạn, sẵn sàng cho phân tích AI.';
  }

  @override
  String get retroScanNoResultsTitle => 'Không tìm thấy ảnh đồ ăn';

  @override
  String get retroScanNoResultsDesc =>
      'Không phát hiện thấy ảnh đồ ăn nào trong 7 ngày qua. Hãy thử chụp ảnh bữa ăn tiếp theo của bạn!';

  @override
  String get retroScanAnalyzeHint =>
      'Nhấn vào \"Phân tích tất cả\" trên dòng thời gian của bạn để nhận phân tích dinh dưỡng AI cho các mục này.';

  @override
  String get retroScanDone => 'Hiểu rồi!';

  @override
  String get welcomeEndTitle => 'Chào mừng đến với MiRO!';

  @override
  String get welcomeEndMessage => 'MiRO sẵn sàng phục vụ bạn.';

  @override
  String get welcomeEndJourney =>
      'Chúc bạn có một chuyến đi vui vẻ cùng nhau!!';

  @override
  String get welcomeEndStart => 'Hãy bắt đầu!';

  @override
  String greetingCalorieSummary(
      int remaining, int protein, int carbs, int fat) {
    return 'CHÀO! Hôm nay tôi có thể giúp gì cho bạn? Bạn vẫn còn $remaining kcal. Cho đến nay: Protein ${protein}g, Carbs ${carbs}g, Chất béo ${fat}g. Hãy cho tôi biết bạn đã ăn gì - liệt kê mọi thứ theo bữa ăn và tôi sẽ ghi lại tất cả cho bạn. Thêm chi tiết chính xác hơn!!';
  }

  @override
  String greetingCuisineTip(String cuisine) {
    return 'Món ăn ưa thích của bạn được đặt thành $cuisine. Bạn có thể thay đổi nó trong Cài đặt bất cứ lúc nào!';
  }

  @override
  String greetingEnergyTip(int balance) {
    return 'Bạn có sẵn $balance Năng lượng. Đừng quên nhận phần thưởng liên tục hàng ngày của bạn trên huy hiệu Năng lượng!';
  }

  @override
  String get greetingRenamePhotoTip =>
      'Mẹo: Bạn có thể đổi tên ảnh đồ ăn để giúp MiRO phân tích chính xác hơn!';

  @override
  String get greetingAddIngredientsTip =>
      'Mẹo: Bạn có thể thêm các thành phần mà bạn chắc chắn trước khi gửi tới MiRO để phân tích. Tôi sẽ tìm ra tất cả những chi tiết nhỏ nhàm chán cho bạn!';

  @override
  String greetingBackupReminder(int days) {
    return 'Này ông chủ! Bạn chưa sao lưu dữ liệu của mình trong $days ngày. Tôi khuyên bạn nên sao lưu trong Cài đặt — dữ liệu của bạn được lưu trữ cục bộ và tôi không thể khôi phục dữ liệu đó nếu có chuyện gì xảy ra!';
  }

  @override
  String get greetingFallback =>
      'CHÀO! Hôm nay tôi có thể giúp gì cho bạn? Hãy cho tôi biết bạn đã ăn gì!';

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
