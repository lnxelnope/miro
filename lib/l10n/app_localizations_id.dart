// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class L10nId extends L10n {
  L10nId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'MiRO';

  @override
  String get save => 'Menyimpan';

  @override
  String get cancel => 'Membatalkan';

  @override
  String get delete => 'Menghapus';

  @override
  String get edit => 'Sunting';

  @override
  String get search => 'Mencari';

  @override
  String get loading => 'Memuat...';

  @override
  String get error => 'Terjadi kesalahan';

  @override
  String get confirm => 'Mengonfirmasi';

  @override
  String get close => 'Menutup';

  @override
  String get done => 'Selesai';

  @override
  String get next => 'Berikutnya';

  @override
  String get skip => 'Melewati';

  @override
  String get retry => 'Mencoba kembali';

  @override
  String get ok => 'OKE';

  @override
  String get foodName => 'Nama makanan';

  @override
  String get calories => 'Kalori';

  @override
  String get protein => 'Protein';

  @override
  String get carbs => 'Karbohidrat';

  @override
  String get fat => 'Gemuk';

  @override
  String get servingSize => 'Ukuran porsi';

  @override
  String get servingUnit => 'Satuan';

  @override
  String get kcal => 'kcal';

  @override
  String get mealBreakfast => 'Sarapan';

  @override
  String get mealLunch => 'Makan siang';

  @override
  String get mealDinner => 'Makan malam';

  @override
  String get mealSnack => 'Camilan';

  @override
  String get todaySummary => 'Ringkasan Hari Ini';

  @override
  String dateSummary(String date) {
    return 'Ringkasan untuk $date';
  }

  @override
  String get savedSuccess => 'Berhasil disimpan';

  @override
  String get deletedSuccess => 'Berhasil dihapus';

  @override
  String get pleaseEnterFoodName => 'Silakan masukkan nama makanan';

  @override
  String get noDataYet => 'Belum ada datanya';

  @override
  String get addFood => 'Tambahkan makanan';

  @override
  String get editFood => 'Sunting makanan';

  @override
  String get deleteFood => 'Hapus makanan';

  @override
  String get deleteConfirm => 'Konfirmasi penghapusan?';

  @override
  String get foodLoggedSuccess => 'Makanan dicatat!';

  @override
  String get noApiKey => 'Harap siapkan Gemini API Key';

  @override
  String get noApiKeyDescription =>
      'Buka Profile → API Pengaturan untuk menyiapkan';

  @override
  String get apiKeyTitle => 'Siapkan Gemini API Key';

  @override
  String get apiKeyRequired => 'API Key diperlukan';

  @override
  String get apiKeyFreeNote => 'Gemini API gratis untuk digunakan';

  @override
  String get apiKeySetup => 'Siapkan API Key';

  @override
  String get testConnection => 'Uji koneksi';

  @override
  String get connectionSuccess => 'Berhasil terhubung! Siap digunakan';

  @override
  String get connectionFailed => 'Koneksi gagal';

  @override
  String get pasteKey => 'Pasta';

  @override
  String get deleteKey => 'Hapus API Key';

  @override
  String get openAiStudio => 'Buka Google AI Studio';

  @override
  String get chatHint => 'Beritahu Miro mis. \"Log nasi goreng\"...';

  @override
  String get chatFoodSaved => 'Makanan dicatat!';

  @override
  String chatFoodSavedDetail(
      String name, String serving, String unit, String cal) {
    return '$name $serving $unit\n$cal kcal';
  }

  @override
  String get featureNotAvailable => 'Maaf, fitur ini belum tersedia';

  @override
  String get goalCalories => 'Kalori/hari';

  @override
  String get goalProtein => 'Protein/hari';

  @override
  String get goalCarbs => 'Karbohidrat/hari';

  @override
  String get goalFat => 'Lemak/hari';

  @override
  String get goalWater => 'Air/hari';

  @override
  String get healthGoals => 'Tujuan Kesehatan';

  @override
  String get profile => 'Proberkas';

  @override
  String get settings => 'Pengaturan';

  @override
  String get privacyPolicy => 'Kebijakan Privasi';

  @override
  String get termsOfService => 'Ketentuan Layanan';

  @override
  String get clearAllData => 'Hapus semua data';

  @override
  String get clearAllDataConfirm =>
      'Semua data akan dihapus. Hal ini tidak dapat dibatalkan!';

  @override
  String get about => 'Tentang';

  @override
  String get language => 'Bahasa';

  @override
  String get upgradePro => 'Tingkatkan ke Pro';

  @override
  String get proUnlocked => 'MiRO Pro';

  @override
  String get proDescription => 'Analisis makanan AI tanpa batas';

  @override
  String aiRemaining(int remaining, int total) {
    return 'Analisis AI: $remaining/$total tersisa hari ini';
  }

  @override
  String get aiLimitReached => 'Batas AI tercapai hari ini (3/3)';

  @override
  String get restorePurchase => 'Pulihkan pembelian';

  @override
  String get myMeals => 'Makanan Saya:';

  @override
  String get createMeal => 'Buat Makanan';

  @override
  String get ingredients => 'Bahan-bahan';

  @override
  String get searchFood => 'Cari makanan';

  @override
  String get analyzing => 'Menganalisis...';

  @override
  String get analyzeWithAi => 'Analisis dengan AI';

  @override
  String get analysisComplete => 'Analisis selesai';

  @override
  String get timeline => 'Garis Waktu';

  @override
  String get diet => 'Diet';

  @override
  String get quickAdd => 'Tambah Cepat';

  @override
  String get welcomeTitle => 'MiRO';

  @override
  String get welcomeSubtitle => 'Pencatatan makanan yang mudah dengan AI';

  @override
  String get onboardingFeature1 => 'Ambil foto';

  @override
  String get onboardingFeature1Desc => 'AI menghitung kalori secara otomatis';

  @override
  String get onboardingFeature2 => 'Ketik untuk mencatat';

  @override
  String get onboardingFeature2Desc =>
      'Ucapkan \"nasi goreng\" dan itu dicatat';

  @override
  String get onboardingFeature3 => 'Ringkasan harian';

  @override
  String get onboardingFeature3Desc =>
      'Lacak kcal, protein, karbohidrat, lemak';

  @override
  String get basicInfo => 'Info Dasar';

  @override
  String get basicInfoDesc =>
      'Untuk menghitung kalori harian yang Anda rekomendasikan';

  @override
  String get gender => 'Jenis kelamin';

  @override
  String get male => 'Pria';

  @override
  String get female => 'Perempuan';

  @override
  String get age => 'Usia';

  @override
  String get weight => 'Berat';

  @override
  String get height => 'Tinggi';

  @override
  String get activityLevel => 'Tingkat Aktivitas';

  @override
  String tdeeResult(int kcal) {
    return 'TDEE Anda: $kcal kcal/hari';
  }

  @override
  String get setupAiTitle => 'Siapkan Gemini AI';

  @override
  String get setupAiDesc => 'Ambil foto dan AI menganalisisnya secara otomatis';

  @override
  String get setupNow => 'Siapkan sekarang';

  @override
  String get skipForNow => 'Lewati untuk saat ini';

  @override
  String get errorTimeout => 'Batas waktu koneksi habis — silakan coba lagi';

  @override
  String get errorInvalidKey => 'API Key tidak valid — periksa pengaturan Anda';

  @override
  String get errorNoInternet => 'Tidak ada koneksi internet';

  @override
  String get errorGeneral => 'Terjadi kesalahan — silakan coba lagi';

  @override
  String get errorQuotaExceeded =>
      'Kuota API terlampaui — harap tunggu dan coba lagi';

  @override
  String get apiKeyScreenTitle => 'Siapkan Gemini API Key';

  @override
  String get analyzeFoodWithAi => 'Analisis makanan dengan AI';

  @override
  String get analyzeFoodWithAiDesc =>
      'Ambil foto → AI menghitung kalori secara otomatis\nGemini API gratis untuk digunakan!';

  @override
  String get openGoogleAiStudio => 'Buka Google AI Studio';

  @override
  String get step1Title => 'Buka Google AI Studio';

  @override
  String get step1Desc => 'Klik tombol di bawah untuk membuat API Key';

  @override
  String get step2Title => 'Masuk dengan Akun Google';

  @override
  String get step2Desc =>
      'Gunakan Akun Gmail atau Google Anda (buat gratis jika Anda belum punya)';

  @override
  String get step3Title => 'Klik \"Buat API Key\"';

  @override
  String get step3Desc =>
      'Klik tombol biru \"Buat API Key\".\nJika diminta untuk memilih Project → Klik \"Buat kunci API di proyek baru\"';

  @override
  String get step4Title => 'Salin Kunci dan tempel di bawah';

  @override
  String get step4Desc =>
      'Klik Salin di sebelah Kunci yang dibuat\nKuncinya akan terlihat seperti: AIzaSyxxxx...';

  @override
  String get step5Title => 'Tempel API Key di sini';

  @override
  String get pasteApiKeyHint => 'Tempelkan API Key yang disalin';

  @override
  String get saveApiKey => 'Simpan API Key';

  @override
  String get testingConnection => 'Menguji...';

  @override
  String get deleteApiKey => 'Hapus API Key';

  @override
  String get deleteApiKeyConfirm => 'Hapus API Key?';

  @override
  String get deleteApiKeyConfirmDesc =>
      'Anda tidak akan dapat menggunakan analisis makanan AI sampai Anda menyiapkannya lagi';

  @override
  String get apiKeySaved => 'API Key berhasil disimpan';

  @override
  String get apiKeyDeleted => 'API Key berhasil dihapus';

  @override
  String get pleasePasteApiKey => 'Silakan tempel API Key terlebih dahulu';

  @override
  String get apiKeyInvalidFormat =>
      'API Key tidak valid — harus dimulai dengan \"AIza\"';

  @override
  String get connectionSuccessMessage => '✅ Berhasil terhubung! Siap digunakan';

  @override
  String get connectionFailedMessage => '❌ Koneksi gagal';

  @override
  String get faqTitle => 'Pertanyaan yang Sering Diajukan';

  @override
  String get faqFreeQuestion => 'Apakah ini benar-benar gratis?';

  @override
  String get faqFreeAnswer =>
      'Ya! Gemini 2.0 Flash gratis untuk 1.500 permintaan/hari\nUntuk pencatatan makanan (5-15 kali/hari) → Gratis selamanya, tidak perlu pembayaran';

  @override
  String get faqSafeQuestion => 'Apakah aman?';

  @override
  String get faqSafeAnswer =>
      'API Key disimpan di Penyimpanan Aman di perangkat Anda saja\nAplikasi tidak mengirimkan Kunci ke server kami\nJika Kunci bocor → Hapus dan buat yang baru (itu bukan kata sandi Google Anda)';

  @override
  String get faqNoKeyQuestion => 'Bagaimana jika saya tidak membuat Kunci?';

  @override
  String get faqNoKeyAnswer =>
      'Anda masih dapat menggunakan aplikasi ini! Tapi:\n❌ Tidak dapat mengambil foto → Analisis AI\n✅ Dapat mencatat makanan secara manual\n✅ Tambah Cepat berfungsi\n✅ Lihat karya ringkasan kcal/makro';

  @override
  String get faqCreditCardQuestion => 'Apakah saya memerlukan kartu kredit?';

  @override
  String get faqCreditCardAnswer =>
      'Tidak — Buat API Key gratis tanpa kartu kredit';

  @override
  String get navDashboard => 'Dasbor';

  @override
  String get navMyMeals => 'Makananku';

  @override
  String get navCamera => 'Kamera';

  @override
  String get navAiChat => 'Obrolan AI';

  @override
  String get navProfile => 'Proberkas';

  @override
  String get appBarTodayIntake => 'Asupan hari ini';

  @override
  String get appBarMyMeals => 'Makananku';

  @override
  String get appBarCamera => 'Kamera';

  @override
  String get appBarAiChat => 'Obrolan AI';

  @override
  String get appBarMiro => 'MIRO';

  @override
  String get permissionRequired => 'Izin Diperlukan';

  @override
  String get permissionRequiredDesc =>
      'MIRO memerlukan akses ke hal-hal berikut:';

  @override
  String get permissionPhotos => 'Foto — untuk memindai makanan';

  @override
  String get permissionCamera => 'Kamera — untuk memotret makanan';

  @override
  String get permissionSkip => 'Melewati';

  @override
  String get permissionAllow => 'Mengizinkan';

  @override
  String get permissionAllGranted => 'Semua izin diberikan';

  @override
  String permissionDenied(String denied) {
    return 'Izin ditolak: $denied';
  }

  @override
  String get openSettings => 'Buka Pengaturan';

  @override
  String get exitAppTitle => 'Keluar dari Aplikasi?';

  @override
  String get exitAppMessage => 'Apakah Anda yakin ingin keluar?';

  @override
  String get exit => 'KELUAR';

  @override
  String get healthGoalsTitle => 'Tujuan Kesehatan';

  @override
  String get healthGoalsInfo =>
      'Tetapkan sasaran kalori harian, makro, dan anggaran per makanan Anda.\nKunci untuk menghitung otomatis: 2 makro atau 3 kali makan.';

  @override
  String get dailyCalorieGoal => 'Sasaran Kalori Harian';

  @override
  String get proteinLabel => 'Protein';

  @override
  String get carbsLabel => 'Karbohidrat';

  @override
  String get fatLabel => 'Gemuk';

  @override
  String get autoBadge => 'mobil';

  @override
  String kcalPerGram(int kcalPerGram, int kcal) {
    return '$kcalPerGram kcal/g • $kcal __SW0__';
  }

  @override
  String get mealCalorieBudget => 'Anggaran Kalori Makanan';

  @override
  String mealBudgetBalanced(int total, int goal) {
    return 'Jumlah $total kcal = Sasaran $goal __SW0__';
  }

  @override
  String mealBudgetRemaining(int total, int goal, int remaining) {
    return 'Jumlah $total / $goal kcal ($remaining tersisa)';
  }

  @override
  String get lockMealsHint =>
      'Kunci 3 makanan untuk menghitung makanan ke-4 secara otomatis';

  @override
  String get breakfastLabel => 'Sarapan';

  @override
  String get lunchLabel => 'Makan siang';

  @override
  String get dinnerLabel => 'Makan malam';

  @override
  String get snackLabel => 'Camilan';

  @override
  String percentOfDailyGoal(String percent) {
    return '$percent% dari target harian';
  }

  @override
  String get smartSuggestionRange => 'Rentang Saran Cerdas';

  @override
  String get smartSuggestionHow => 'Bagaimana cara kerja Saran Cerdas?';

  @override
  String smartSuggestionDesc(int threshold, int min, int max) {
    return 'Kami menyarankan makanan dari Makanan Saya, bahan-bahan, dan makanan kemarin yang sesuai dengan anggaran makan Anda.\n\nAmbang batas ini mengontrol seberapa fleksibel saran tersebut. Misalnya, jika anggaran makan siang Anda adalah 700 kcal dan ambang batasnya adalah $threshold __SW0__, kami akan menyarankan makanan antara $min–$max __SW0__.';
  }

  @override
  String get suggestionThreshold => 'Ambang Saran';

  @override
  String suggestionThresholdDesc(int threshold) {
    return 'Izinkan makanan ± $threshold kcal dari anggaran makan';
  }

  @override
  String get goalsSavedSuccess => 'Gol berhasil disimpan!';

  @override
  String get canOnlyLockTwoMacros => 'Hanya bisa mengunci 2 makro sekaligus';

  @override
  String get canOnlyLockThreeMeals =>
      'Hanya dapat mengunci 3 kali makan; perhitungan otomatis ke-4';

  @override
  String get tabMeals => 'Makanan';

  @override
  String get tabIngredients => 'Bahan-bahan';

  @override
  String get searchMealsOrIngredients => 'Cari makanan atau bahan...';

  @override
  String get createNewMeal => 'Buat Makanan Baru';

  @override
  String get addIngredient => 'Tambahkan Bahan';

  @override
  String get noMealsYet => 'Belum ada makanan';

  @override
  String get noMealsYetDesc =>
      'Analisis makanan dengan AI untuk menyimpan makanan secara otomatis\natau buat secara manual';

  @override
  String get noIngredientsYet => 'Belum ada bahan';

  @override
  String get noIngredientsYetDesc =>
      'Saat Anda menganalisis makanan dengan AI\nbahan akan disimpan secara otomatis';

  @override
  String mealCreated(String name) {
    return 'Dibuat \"$name\"';
  }

  @override
  String mealLogged(String name) {
    return 'Tercatat \"$name\"';
  }

  @override
  String ingredientAmount(String unit) {
    return 'Jumlah ($unit)';
  }

  @override
  String ingredientLogged(String name, String amount, String unit) {
    return 'Tercatat \"$name\" $amount$unit';
  }

  @override
  String get mealNotFound => 'Makanan tidak ditemukan';

  @override
  String mealUpdated(String name) {
    return 'Diperbarui \"$name\"';
  }

  @override
  String get deleteMealTitle => 'Hapus Makanan?';

  @override
  String deleteMealMessage(String name) {
    return '\"$name\"';
  }

  @override
  String get deleteMealNote => 'Bahan-bahannya tidak akan dihapus.';

  @override
  String get mealDeleted => 'Makanan dihapus';

  @override
  String ingredientCreated(String name) {
    return 'Dibuat \"$name\"';
  }

  @override
  String get ingredientNotFound => 'Bahan tidak ditemukan';

  @override
  String ingredientUpdated(String name) {
    return 'Diperbarui \"$name\"';
  }

  @override
  String get deleteIngredientTitle => 'Hapus Bahan?';

  @override
  String deleteIngredientMessage(String name) {
    return '\"$name\"';
  }

  @override
  String get ingredientDeleted => 'Bahan dihapus';

  @override
  String get noIngredientsData => 'Tidak ada data bahan';

  @override
  String ingredientDetail(String name, String amount, String unit) {
    return '$name ($amount $unit)';
  }

  @override
  String ingredientCalories(int calories) {
    return '$calories kcal';
  }

  @override
  String get useThisMeal => 'Gunakan Makanan Ini';

  @override
  String errorLoading(String error) {
    return 'Kesalahan saat memuat: $error';
  }

  @override
  String scanFoundNewImages(int count, String date) {
    return 'Menemukan $count gambar baru di $date';
  }

  @override
  String scanNoNewImages(String date) {
    return 'Tidak ada gambar baru yang ditemukan di $date';
  }

  @override
  String aiAnalysisRemaining(int remaining, int total) {
    return 'Analisis AI: $remaining/$total tersisa hari ini';
  }

  @override
  String get upgradeToProUnlimited =>
      'Tingkatkan ke Pro untuk penggunaan tak terbatas';

  @override
  String get upgrade => 'Meningkatkan';

  @override
  String get confirmDelete => 'Konfirmasi Hapus';

  @override
  String confirmDeleteMessage(String name) {
    return 'Apakah Anda ingin menghapus \"$name\"?';
  }

  @override
  String get entryDeletedSuccess => '✅ Entri berhasil dihapus';

  @override
  String entryDeleteError(String error) {
    return '❌ Kesalahan: $error';
  }

  @override
  String batchAnalyzeItems(int count) {
    return '$count item (kumpulan)';
  }

  @override
  String analyzeCancelled(int success) {
    return 'Dibatalkan — berhasil menganalisis item $success';
  }

  @override
  String analyzeSuccessAll(int success) {
    return '✅ Berhasil menganalisis item $success';
  }

  @override
  String analyzeSuccessPartial(int success, int total, int failed) {
    return '⚠️ Menganalisis item $success/$total ($failed gagal)';
  }

  @override
  String analyzeProgress(String item, int current, int total) {
    return '$item ($current/$total)';
  }

  @override
  String get pullToScanMeal => 'Tarik untuk memindai makanan Anda';

  @override
  String get analyzeAll => 'Analisis Semua';

  @override
  String get addFoodTitle => 'Tambahkan Makanan';

  @override
  String get foodNameRequired => 'Nama Makanan *';

  @override
  String get foodNameHint =>
      'Ketik untuk mencari mis. nasi goreng, salad pepaya';

  @override
  String get selectedFromMyMeal =>
      '✅ Dipilih dari Makanan Saya - data nutrisi terisi secara otomatis';

  @override
  String get foundInDatabase =>
      '✅ Ditemukan di database — data nutrisi terisi secara otomatis';

  @override
  String get saveAndAnalyze => 'Simpan & Analisis';

  @override
  String get notFoundInDatabase =>
      'Tidak ditemukan di database — akan dianalisis di latar belakang';

  @override
  String get amountLabel => 'Jumlah';

  @override
  String get unitLabel => 'Satuan';

  @override
  String get nutritionAutoCalculated =>
      'Nutrisi (dihitung otomatis berdasarkan jumlah)';

  @override
  String get nutritionEnterZero => 'Nutrisi (masukkan 0 jika tidak diketahui)';

  @override
  String get caloriesLabel => 'Kalori (kcal)';

  @override
  String get proteinLabelShort => 'Protein (g)';

  @override
  String get carbsLabelShort => 'Karbohidrat (g)';

  @override
  String get fatLabelShort => 'Lemak (g)';

  @override
  String get mealTypeLabel => 'Jenis Makanan';

  @override
  String get pleaseEnterFoodNameFirst =>
      'Silakan masukkan nama makanan terlebih dahulu';

  @override
  String get savedAnalyzingBackground =>
      '✅ Tersimpan - menganalisis di latar belakang';

  @override
  String get foodAdded => '✅ Makanan ditambahkan';

  @override
  String get suggestionSourceMyMeal => 'Makananku';

  @override
  String get suggestionSourceIngredient => 'Bahan';

  @override
  String get suggestionSourceDatabase => 'Basis data';

  @override
  String get editFoodTitle => 'Sunting Makanan';

  @override
  String get foodNameLabel => 'Nama makanan';

  @override
  String get changeAmountAutoUpdate =>
      'Ubah jumlah → pembaruan kalori secara otomatis';

  @override
  String baseNutrition(int calories, String unit) {
    return 'Basis: $calories kcal / 1 $unit';
  }

  @override
  String get calculatedFromIngredients =>
      'Dihitung dari bahan-bahan di bawah ini';

  @override
  String get ingredientsEditable => 'Bahan (Dapat Diedit)';

  @override
  String get addIngredientButton => 'Menambahkan';

  @override
  String get noIngredientsAddHint =>
      'Tanpa bahan — ketuk \"Tambah\" untuk menambahkan bahan baru';

  @override
  String get editIngredientsHint =>
      'Edit nama/jumlah → Ketuk ikon pencarian untuk mencari database atau AI';

  @override
  String get ingredientNameHint => 'misalnya Telur Ayam';

  @override
  String get searchDbOrAi => 'Cari DB / AI';

  @override
  String get amountHint => 'Jumlah';

  @override
  String get fromDatabase => 'Dari Basis Data';

  @override
  String subIngredients(int count) {
    return 'Sub-bahan ($count)';
  }

  @override
  String get addSubIngredient => 'Menambahkan';

  @override
  String get subIngredientNameHint => 'Nama sub-bahan';

  @override
  String get amountShort => 'Amt';

  @override
  String get pleaseEnterSubIngredientName =>
      'Silakan masukkan nama sub-bahan terlebih dahulu';

  @override
  String foundInDatabaseSub(String name) {
    return 'Ditemukan \"$name\" di database!';
  }

  @override
  String aiAnalyzedSub(String name) {
    return 'AI menganalisis \"$name\" (-1 Energi)';
  }

  @override
  String get couldNotAnalyzeSub => 'Tidak dapat menganalisis sub-bahan';

  @override
  String get pleaseEnterIngredientName => 'Silakan masukkan nama bahan';

  @override
  String get reAnalyzeTitle => 'Analisis ulang?';

  @override
  String reAnalyzeMessage(String name) {
    return '\"$name\" sudah memiliki data nutrisi.\n\nMenganalisis lagi akan menggunakan 1 Energi.\n\nMelanjutkan?';
  }

  @override
  String get reAnalyzeButton => 'Analisis ulang (1 Energi)';

  @override
  String get amountNotSpecified => 'Jumlah tidak ditentukan';

  @override
  String amountNotSpecifiedMessage(String name) {
    return 'Harap tentukan jumlah untuk \"$name\" terlebih dahulu\nAtau pakai bawaan 100 gr?';
  }

  @override
  String get useDefault100g => 'Gunakan 100 gram';

  @override
  String aiAnalyzedResult(String name, int calories) {
    return 'AI: \"$name\" → $calories kcal';
  }

  @override
  String get unableToAnalyze => 'Tidak dapat menganalisis';

  @override
  String get today => 'Hari ini';

  @override
  String get savedSuccessfully => '✅ Berhasil disimpan';

  @override
  String get confirmFoodPhoto => 'Konfirmasi Foto Makanan';

  @override
  String get photoSavedAutomatically => 'Foto disimpan secara otomatis';

  @override
  String get foodNameHintExample => 'misalnya, salad ayam panggang';

  @override
  String get quantityLabel => 'Kuantitas';

  @override
  String get quantityHint => '1';

  @override
  String get optionalFoodInfo =>
      'Memasukkan nama dan kuantitas makanan bersifat opsional, namun memasukkannya akan meningkatkan akurasi analisis AI.';

  @override
  String get saveOnly => 'Simpan saja';

  @override
  String get pleaseEnterValidQuantity => 'Silakan masukkan jumlah yang valid';

  @override
  String analyzedResult(String name, int calories) {
    return '✅ Dianalisis: $name — $calories kcal';
  }

  @override
  String get couldNotAnalyzeSaved =>
      '⚠️ Tidak dapat menganalisis — disimpan, gunakan \"Analisis Semua\" nanti';

  @override
  String get savedAnalyzeLater =>
      '✅ Tersimpan - analisis nanti dengan \"Analisis Semua\"';

  @override
  String get editIngredientTitle => 'Sunting Bahan';

  @override
  String get ingredientNameRequired => 'Nama Bahan *';

  @override
  String get baseAmountLabel => 'Jumlah Dasar';

  @override
  String get baseAmountHint => '100';

  @override
  String nutritionPerBase(String amount, String unit) {
    return 'Nutrisi per $amount $unit';
  }

  @override
  String nutritionCalculatedPerBase(String amount, String unit) {
    return 'Nutrisi dihitung per $amount $unit — sistem akan menghitung secara otomatis berdasarkan jumlah aktual yang dikonsumsi';
  }

  @override
  String get createIngredient => 'Buat Bahan';

  @override
  String get saveChanges => 'Simpan Perubahan';

  @override
  String get pleaseEnterIngredientNameFirst =>
      'Silakan masukkan nama bahan terlebih dahulu';

  @override
  String aiAnalyzedIngredient(
      String name, String amount, String unit, int calories) {
    return 'AI: \"$name\" $amount $unit → $calories kcal';
  }

  @override
  String get unableToFindIngredient => 'Tidak dapat menemukan bahan ini';

  @override
  String searchFailed(String error) {
    return 'Pencarian gagal: $error';
  }

  @override
  String deleteEntriesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Entries',
      one: 'Entry',
    );
    return 'Hapus $count $_temp0?';
  }

  @override
  String deleteEntriesMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return 'Hapus $count makanan yang dipilih $_temp0?';
  }

  @override
  String get deleteAll => 'Hapus Semua';

  @override
  String deletedEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return 'Dihapus $count $_temp0';
  }

  @override
  String movedEntriesToDate(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return 'Memindahkan $count $_temp0 ke $date';
  }

  @override
  String get allSelectedAlreadyAnalyzed =>
      'Semua entri yang dipilih sudah dianalisis';

  @override
  String analyzeCancelledSelected(int success) {
    return 'Dibatalkan — $success dianalisis';
  }

  @override
  String analyzedEntriesAll(int success) {
    String _temp0 = intl.Intl.pluralLogic(
      success,
      locale: localeName,
      other: 'entries',
      one: 'entry',
    );
    return 'Menganalisis $success $_temp0';
  }

  @override
  String analyzedEntriesPartial(int success, int total, int failed) {
    return 'Menganalisis $success/$total ($failed gagal)';
  }

  @override
  String analyzeProgressSelected(int current, int total, String item) {
    return '$current/$total $item';
  }

  @override
  String get noEntriesYet => 'Belum ada entri';

  @override
  String get selectAll => 'Pilih semua';

  @override
  String get deselectAll => 'Batalkan pilihan semua';

  @override
  String get moveToDate => 'Pindah ke tanggal';

  @override
  String get analyzeSelected => 'Analisis yang dipilih';

  @override
  String get deleteTooltip => 'Menghapus';

  @override
  String get move => 'Bergerak';

  @override
  String get deleteTooltipAction => 'Menghapus';

  @override
  String switchToModeTitle(String mode) {
    return 'Beralih ke mode $mode?';
  }

  @override
  String switchToModeMessage(String current, String newMode) {
    return 'Item ini dianalisis sebagai $current.\n\nMenganalisis ulang sebagai $newMode akan menggunakan 1 Energi.\n\nMelanjutkan?';
  }

  @override
  String analyzingAsMode(String mode) {
    return 'Menganalisis sebagai $mode...';
  }

  @override
  String reAnalyzedAsMode(String mode) {
    return '✅ Dianalisis ulang sebagai $mode';
  }

  @override
  String get analysisFailed => '❌ Analisis gagal';

  @override
  String get aiAnalysisComplete => '✅ AI dianalisis dan disimpan';

  @override
  String get changeMealType => 'Ubah Jenis Makanan';

  @override
  String get moveToAnotherDate => 'Pindah ke Tanggal Lain';

  @override
  String currentDate(String date) {
    return 'Saat ini: $date';
  }

  @override
  String get cancelDateChange => 'Batalkan Perubahan Tanggal';

  @override
  String get undo => 'Membuka';

  @override
  String get chatHistory => 'Riwayat Obrolan';

  @override
  String get newChat => 'Obrolan baru';

  @override
  String get quickActions => 'Tindakan Cepat';

  @override
  String get clear => 'Jernih';

  @override
  String get helloImMiro => 'Halo! saya Miro';

  @override
  String get tellMeWhatYouAteToday =>
      'Katakan padaku apa yang kamu makan hari ini!';

  @override
  String get tellMeWhatYouAte => 'Katakan padaku apa yang kamu makan...';

  @override
  String get clearHistoryTitle => 'Hapus riwayat?';

  @override
  String get clearHistoryMessage => 'Semua pesan di sesi ini akan dihapus.';

  @override
  String get chatHistoryTitle => 'Riwayat Obrolan';

  @override
  String get newLabel => 'Baru';

  @override
  String get noChatHistoryYet => 'Belum ada riwayat obrolan';

  @override
  String get active => 'Aktif';

  @override
  String get deleteChatTitle => 'Hapus obrolan?';

  @override
  String deleteChatMessage(String title) {
    return 'Hapus \"$title\"?';
  }

  @override
  String weeklySummaryTitle(String start, String end) {
    return '📊 Ringkasan Mingguan ($start - $end)';
  }

  @override
  String daySummary(String day, String calories, String emoji, String diff) {
    return '📅 $day: $calories kcal $emoji ($diff)';
  }

  @override
  String overTarget(String amount) {
    return '$amount melebihi target';
  }

  @override
  String underTarget(String amount) {
    return '$amount di bawah target';
  }

  @override
  String get noFoodLoggedThisWeek =>
      'Belum ada makanan yang dicatat minggu ini.';

  @override
  String averageKcalPerDay(String average) {
    return '🔥 Rata-rata: $average kcal/hari';
  }

  @override
  String targetKcalPerDay(String target) {
    return '🎯 Target: $target kcal/hari';
  }

  @override
  String resultOverTarget(String amount) {
    return '📈 Hasil: $amount kcal melebihi target';
  }

  @override
  String resultUnderTarget(String amount) {
    return '📈 Hasil: $amount kcal di bawah target — Kerja bagus! 💪';
  }

  @override
  String failedToLoadWeeklySummary(String error) {
    return '❌ Gagal memuat ringkasan mingguan: $error';
  }

  @override
  String monthlySummaryTitle(String month, int year) {
    return '📊 Ringkasan Bulanan ($month $year)';
  }

  @override
  String totalDays(int days) {
    return '📅 Jumlah Hari: $days';
  }

  @override
  String totalConsumed(String calories) {
    return '🔥 Jumlah yang Dikonsumsi: $calories kcal';
  }

  @override
  String targetTotal(String target) {
    return '🎯 Jumlah Sasaran: $target kcal';
  }

  @override
  String averageKcalPerDayShort(String average) {
    return '📈 Rata-rata: $average kcal/hari';
  }

  @override
  String overTargetThisMonth(String amount) {
    return '⚠️ $amount kcal melebihi target bulan ini';
  }

  @override
  String underTargetThisMonth(String amount) {
    return '✅ $amount kcal di bawah target — Luar biasa! 💪';
  }

  @override
  String failedToLoadMonthlySummary(String error) {
    return '❌ Gagal memuat ringkasan bulanan: $error';
  }

  @override
  String get localAiHelpTitle => '🤖 Bantuan AI Lokal';

  @override
  String get localAiHelpFormat => 'Format: [makanan] [jumlah] [satuan]';

  @override
  String get localAiHelpExamples =>
      'Contoh:\n• ayam 100g dan nasi 200g\n• pizza 2 potong\n• apel 1 buah, pisang 1 buah';

  @override
  String get localAiHelpNote =>
      'Catatan: Hanya bahasa Inggris, penguraian dasar\nBeralih ke Miro AI untuk hasil yang lebih baik!';

  @override
  String hiNoFoodLogged(String target) {
    return '🤖 Hai! Belum ada makanan yang dicatat hari ini.\n   Target: $target kcal — Siap memulai logging? 🍽️';
  }

  @override
  String hiKcalLeft(String remaining) {
    return '🤖 Hai! Anda memiliki $remaining kcal tersisa untuk hari ini.\n   Siap mencatat makanan Anda? 😊';
  }

  @override
  String hiOverTarget(String calories, String over) {
    return '🤖 Hai! Anda telah mengonsumsi $calories kcal hari ini.\n   $over __SW0__ melebihi target — Ayo terus lacak! 💪';
  }

  @override
  String get hiReadyToLog => '🤖 Hai! Siap mencatat makanan Anda? 😊';

  @override
  String get notEnoughEnergy => 'Energi tidak cukup';

  @override
  String get thinkingMealIdeas =>
      '🤖 Memikirkan ide makanan enak untuk Anda...';

  @override
  String get recentMeals => 'Makanan terkini:';

  @override
  String get noRecentFood => 'Tidak ada makanan terbaru yang dicatat.';

  @override
  String remainingCaloriesToday(String remaining) {
    return '. Sisa kalori hari ini: $remaining kcal.';
  }

  @override
  String failedToGetMenuSuggestions(String error) {
    return '❌ Gagal mendapatkan saran menu: $error';
  }

  @override
  String get mealSuggestionsTitle =>
      '🤖 Berdasarkan catatan makanan Anda, berikut 3 saran makan:';

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
      'Pilih satu dan saya akan mencatatnya untuk Anda! 😊';

  @override
  String energyCost(int cost) {
    return '⚡ -$cost Energi';
  }

  @override
  String get giveMeTipsForHealthyEating => 'Beri saya tip untuk makan sehat';

  @override
  String get howManyCaloriesToday => 'Berapa banyak kalori hari ini?';

  @override
  String get menuLabel => 'Menu';

  @override
  String get weeklyLabel => 'Mingguan';

  @override
  String get monthlyLabel => 'Bulanan';

  @override
  String get tipsLabel => 'Kiat';

  @override
  String get summaryLabel => 'Ringkasan';

  @override
  String get helpLabel => 'Membantu';

  @override
  String get onboardingWelcomeSubtitle =>
      'Lacak kalori dengan mudah\ndengan analisis bertenaga AI';

  @override
  String get onboardingSnap => 'Patah';

  @override
  String get onboardingSnapDesc => 'Analisis AI secara instan';

  @override
  String get onboardingType => 'Jenis';

  @override
  String get onboardingTypeDesc => 'Masuk dalam hitungan detik';

  @override
  String get onboardingEdit => 'Sunting';

  @override
  String get onboardingEditDesc => 'Sempurnakan akurasi';

  @override
  String get onboardingNext => 'Selanjutnya →';

  @override
  String get onboardingDisclaimer => 'Data perkiraan AI. Bukan nasihat medis.';

  @override
  String get onboardingQuickSetup => 'Pengaturan Cepat';

  @override
  String get onboardingHelpAiUnderstand =>
      'Bantu AI memahami makanan Anda dengan lebih baik';

  @override
  String get onboardingYourTypicalCuisine => 'Masakan khas Anda:';

  @override
  String get onboardingDailyCalorieGoal => 'Sasaran kalori harian (opsional):';

  @override
  String get onboardingKcalPerDay => 'kcal/hari';

  @override
  String get onboardingCalorieGoalHint => '2000';

  @override
  String get onboardingCanChangeAnytime =>
      'Anda dapat mengubahnya kapan saja di pengaturan Profile';

  @override
  String get onboardingYoureAllSet => 'Anda sudah siap!';

  @override
  String get onboardingStartTracking =>
      'Mulailah melacak makanan Anda hari ini.\nAmbil foto atau ketik apa yang Anda makan.';

  @override
  String get onboardingWelcomeGift => 'Hadiah Selamat Datang';

  @override
  String get onboardingFreeEnergy => '10 Energi GRATIS';

  @override
  String get onboardingFreeEnergyDesc => '= 10 analisis AI untuk memulai';

  @override
  String get onboardingEnergyCost =>
      'Setiap analisis membutuhkan 1 Energi\nSemakin banyak Anda menggunakan, semakin banyak penghasilan Anda!';

  @override
  String get onboardingStartTrackingButton => 'Mulai Pelacakan! →';

  @override
  String get onboardingNoCreditCard =>
      'Tanpa kartu kredit • Tanpa biaya tersembunyi';

  @override
  String get cameraTakePhotoOfFood => 'Ambil foto makanan Anda';

  @override
  String get cameraFailedToInitialize => 'Gagal menginisialisasi kamera';

  @override
  String get cameraFailedToCapture => 'Gagal mengambil foto';

  @override
  String get cameraFailedToPickFromGallery =>
      'Gagal mengambil gambar dari galeri';

  @override
  String get cameraProcessing => 'Prosedang...';

  @override
  String get referralInviteFriends => 'Undang Teman';

  @override
  String get referralYourReferralCode => 'Kode Referensi Anda';

  @override
  String get referralLoading => 'Memuat...';

  @override
  String get referralCopy => 'Menyalin';

  @override
  String get referralShareCodeDescription =>
      'Bagikan kode ini kepada teman-teman! Saat mereka menggunakan AI 3 kali, Anda berdua mendapat hadiah!';

  @override
  String get referralEnterReferralCode => 'Masukkan Kode Referensi';

  @override
  String get referralCodeHint => 'MIRO-XXXX-XXXX-XXXX';

  @override
  String get referralSubmitCode => 'Kirim Kode';

  @override
  String get referralPleaseEnterCode => 'Silakan masukkan kode referral';

  @override
  String get referralCodeAccepted => 'Kode referensi diterima!';

  @override
  String get referralCodeCopied => 'Kode referensi disalin ke clipboard!';

  @override
  String referralEnergyBonus(int energy) {
    return '+$energy Energi!';
  }

  @override
  String get referralHowItWorks => 'Cara Kerjanya';

  @override
  String get referralStep1Title => 'Bagikan kode referensi Anda';

  @override
  String get referralStep1Description =>
      'Salin dan bagikan ID MiRO Anda dengan teman';

  @override
  String get referralStep2Title => 'Teman memasukkan kode Anda';

  @override
  String get referralStep2Description => 'Mereka segera mendapatkan +20 Energi';

  @override
  String get referralStep3Title => 'Teman menggunakan AI sebanyak 3 kali';

  @override
  String get referralStep3Description =>
      'Saat mereka menyelesaikan 3 analisis AI';

  @override
  String get referralStep4Title => 'Anda mendapat imbalan!';

  @override
  String get referralStep4Description => 'Anda menerima +5 Energi!';

  @override
  String get tierBenefitsTitle => 'Manfaat Tingkat';

  @override
  String get tierBenefitsUnlockRewards => 'Buka Hadiah\ndengan Coretan Harian';

  @override
  String get tierBenefitsKeepStreakDescription =>
      'Pertahankan rekor Anda untuk membuka tingkatan yang lebih tinggi dan dapatkan manfaat luar biasa!';

  @override
  String get tierBenefitsHowItWorks => 'Cara Kerjanya';

  @override
  String get tierBenefitsDailyEnergyReward => 'Hadiah Energi Harian';

  @override
  String get tierBenefitsDailyEnergyDescription =>
      'Gunakan AI setidaknya sekali sehari untuk mendapatkan energi bonus. Tingkat yang lebih tinggi = lebih banyak energi harian!';

  @override
  String get tierBenefitsPurchaseBonus => 'Bonus Pembelian';

  @override
  String get tierBenefitsPurchaseBonusDescription =>
      'Tingkatan Emas & Berlian mendapatkan energi ekstra pada setiap pembelian (10-20% lebih banyak!)';

  @override
  String get tierBenefitsGracePeriod => 'Masa Tenggang';

  @override
  String get tierBenefitsGracePeriodDescription =>
      'Lewatkan satu hari tanpa kehilangan pukulan Anda. Tingkatan Silver+ mendapat perlindungan!';

  @override
  String get tierBenefitsAllTiers => 'Semua Tingkatan';

  @override
  String get tierBenefitsNew => 'BARU';

  @override
  String get tierBenefitsPopular => 'POPULER';

  @override
  String get tierBenefitsBest => 'TERBAIK';

  @override
  String get tierBenefitsDailyCheckIn => 'Check-in Harian';

  @override
  String get tierBenefitsProTips => 'Pro Tip';

  @override
  String get tierBenefitsTip1 =>
      'Gunakan AI setiap hari untuk mendapatkan energi gratis dan meningkatkan rekor Anda';

  @override
  String get tierBenefitsTip2 =>
      'Tingkat berlian menghasilkan +4 Energi per hari — yaitu 120/bulan!';

  @override
  String get tierBenefitsTip3 =>
      'Bonus Pembelian berlaku untuk SEMUA paket energi!';

  @override
  String get tierBenefitsTip4 =>
      'Masa tenggang melindungi pukulan Anda jika Anda melewatkan satu hari';

  @override
  String get subscriptionEnergyPass => 'Tiket Energi';

  @override
  String get subscriptionInAppPurchasesNotAvailable =>
      'Pembelian dalam aplikasi tidak tersedia';

  @override
  String get subscriptionFailedToInitiatePurchase => 'Gagal memulai pembelian';

  @override
  String subscriptionError(String error) {
    return 'Kesalahan: $error';
  }

  @override
  String get subscriptionFailedToLoad => 'Gagal memuat langganan';

  @override
  String get subscriptionUnknownError => 'Kesalahan tidak diketahui';

  @override
  String get subscriptionRetry => 'Mencoba kembali';

  @override
  String get subscriptionEnergyPassActive => 'Energi Lulus Aktif';

  @override
  String get subscriptionUnlimitedAccess => 'Anda memiliki akses tak terbatas';

  @override
  String get subscriptionStatus => 'Status';

  @override
  String get subscriptionRenews => 'Memperbarui';

  @override
  String get subscriptionPrice => 'Harga';

  @override
  String get subscriptionYourBenefits => 'Keuntungan Anda';

  @override
  String get subscriptionManageSubscription => 'Kelola Langganan';

  @override
  String get subscriptionNoProductAvailable =>
      'Tidak ada produk berlangganan yang tersedia';

  @override
  String get subscriptionWhatYouGet => 'Apa yang Anda Dapatkan';

  @override
  String get subscriptionPerMonth => 'per bulan';

  @override
  String get subscriptionSubscribeNow => 'Berlangganan Sekarang';

  @override
  String get subscriptionCancelAnytime => 'Batalkan kapan saja';

  @override
  String get subscriptionAutoRenewTerms =>
      'Langganan Anda akan diperpanjang secara otomatis. Anda dapat membatalkan kapan saja dari Google Play.';

  @override
  String get disclaimerHealthDisclaimer => 'Penafian Kesehatan';

  @override
  String get disclaimerImportantReminders => 'Pengingat Penting:';

  @override
  String get disclaimerBullet1 => 'Semua data nutrisi diperkirakan';

  @override
  String get disclaimerBullet2 => 'Analisis AI mungkin mengandung kesalahan';

  @override
  String get disclaimerBullet3 => 'Bukan pengganti nasihat profesional';

  @override
  String get disclaimerBullet4 =>
      'Konsultasikan dengan penyedia layanan kesehatan untuk mendapatkan panduan medis';

  @override
  String get disclaimerBullet5 =>
      'Gunakan atas kebijaksanaan dan risiko Anda sendiri';

  @override
  String get disclaimerIUnderstand => 'Saya mengerti';

  @override
  String get privacyPolicyTitle => 'Kebijakan Privasi';

  @override
  String get privacyPolicySubtitle => 'MiRO — Oracle Catatan Penerimaan Saya';

  @override
  String get privacyPolicyHeaderNote =>
      'Data makanan Anda tetap ada di perangkat Anda. Keseimbangan energi disinkronkan dengan aman melalui Firebase.';

  @override
  String get privacyPolicySectionInformationWeCollect =>
      'Informasi yang Kami Kumpulkan';

  @override
  String get privacyPolicySectionDataStorage => 'Penyimpanan Data';

  @override
  String get privacyPolicySectionDataTransmission =>
      'Transmisi Data ke Pihak Ketiga';

  @override
  String get privacyPolicySectionRequiredPermissions => 'Izin yang Diperlukan';

  @override
  String get privacyPolicySectionSecurity => 'Keamanan';

  @override
  String get privacyPolicySectionUserRights => 'Hak Pengguna';

  @override
  String get privacyPolicySectionDataRetention => 'Retensi Data';

  @override
  String get privacyPolicySectionChildrenPrivacy => 'Privasi Anak';

  @override
  String get privacyPolicySectionChangesToPolicy =>
      'Perubahan pada Kebijakan Ini';

  @override
  String get privacyPolicySectionDataCollectionConsent =>
      'Persetujuan Pengumpulan Data';

  @override
  String get privacyPolicySectionPDPACompliance =>
      'Kepatuhan PDPA (Data Pribadi Thailand Protection Act)';

  @override
  String get privacyPolicySectionContactUs => 'Hubungi kami';

  @override
  String get privacyPolicyEffectiveDate =>
      'Tanggal Berlaku: 18 Februari 2026\nTerakhir Diperbarui: 18 Februari 2026';

  @override
  String get termsOfServiceTitle => 'Ketentuan Layanan';

  @override
  String get termsSubtitle => 'MiRO — Oracle Catatan Penerimaan Saya';

  @override
  String get termsSectionAcceptanceOfTerms => 'Penerimaan Persyaratan';

  @override
  String get termsSectionServiceDescription => 'Deskripsi Layanan';

  @override
  String get termsSectionDisclaimerOfWarranties => 'Penafian Jaminan';

  @override
  String get termsSectionEnergySystemTerms => 'Istilah Sistem Energi';

  @override
  String get termsSectionUserDataAndResponsibilities =>
      'Data Pengguna dan Tanggung Jawab';

  @override
  String get termsSectionBackupTransfer => 'Cadangan & Transfer';

  @override
  String get termsSectionInAppPurchases => 'Pembelian Dalam Aplikasi';

  @override
  String get termsSectionProhibitedUses => 'Promenghambat Penggunaan';

  @override
  String get termsSectionIntellectualProperty => 'Intelektual Property';

  @override
  String get termsSectionLimitationOfLiability => 'Batasan Tanggung Jawab';

  @override
  String get termsSectionServiceTermination => 'Pengakhiran Layanan';

  @override
  String get termsSectionChangesToTerms => 'Perubahan Ketentuan';

  @override
  String get termsSectionGoverningLaw => 'Hukum yang Mengatur';

  @override
  String get termsSectionContactUs => 'Hubungi kami';

  @override
  String get termsAcknowledgment =>
      'Dengan menggunakan MiRO, Anda menyatakan bahwa Anda telah membaca, memahami, dan menyetujui Ketentuan Layanan ini.';

  @override
  String get termsLastUpdated => 'Terakhir diperbarui: 15 Februari 2026';

  @override
  String get profileAndSettings => 'Profile & Pengaturan';

  @override
  String errorOccurred(String error) {
    return 'Kesalahan: $error';
  }

  @override
  String get healthGoalsSection => 'Tujuan Kesehatan';

  @override
  String get dailyGoals => 'Tujuan Harian';

  @override
  String get chatAiModeSection => 'Mode AI Obrolan';

  @override
  String get selectAiPowersChat => 'Pilih AI mana yang mendukung obrolan Anda';

  @override
  String get miroAi => 'Miro AI';

  @override
  String get miroAiSubtitle =>
      'Didukung oleh Gemini • Multi-bahasa • Akurasi tinggi';

  @override
  String get localAi => 'AI lokal';

  @override
  String get localAiSubtitle =>
      'Di perangkat • Hanya dalam bahasa Inggris • Akurasi dasar';

  @override
  String get free => 'Bebas';

  @override
  String get cuisinePreferenceSection => 'Preferensi Masakan';

  @override
  String get preferredCuisine => 'Masakan Pilihan';

  @override
  String get selectYourCuisine => 'Pilih Masakan Anda';

  @override
  String get photoScanSection => 'Pemindaian Foto';

  @override
  String get languageSection => 'Bahasa';

  @override
  String get languageTitle => 'Bahasa / ภาษา';

  @override
  String get selectLanguage => 'Pilih Bahasa / Bahasa';

  @override
  String get systemDefault => 'Bawaan Sistem';

  @override
  String get systemDefaultSublabel => 'ตามระบบ';

  @override
  String get english => 'Bahasa inggris';

  @override
  String get englishSublabel => 'อังกฤษ';

  @override
  String get thai => 'ไทย (Thailand)';

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
  String get closeBilingual => 'Tutup / ปิด';

  @override
  String languageChangedTo(String language) {
    return 'Bahasa diubah menjadi $language';
  }

  @override
  String get accountSection => 'Akun';

  @override
  String get miroId => 'MiRO ID';

  @override
  String get miroIdCopied => 'MiRO ID disalin!';

  @override
  String get inviteFriends => 'Undang Teman';

  @override
  String get inviteFriendsSubtitle =>
      'Bagikan kode referensi Anda dan dapatkan hadiah!';

  @override
  String get unlimitedAiDoubleRewards => 'AI tanpa batas + Hadiah ganda';

  @override
  String get plan => 'Rencana';

  @override
  String get monthly => 'Bulanan';

  @override
  String get started => 'Dimulai';

  @override
  String get renews => 'Memperbarui';

  @override
  String get expires => 'Kedaluwarsa';

  @override
  String get autoRenew => 'Perpanjangan Otomatis';

  @override
  String get on => 'Pada';

  @override
  String get off => 'Mati';

  @override
  String get tapToManageSubscription => 'Ketuk untuk mengelola langganan';

  @override
  String get dataSection => 'Data';

  @override
  String get backupData => 'Data Cadangan';

  @override
  String get backupDataSubtitle =>
      'Energi + Riwayat Makanan → simpan sebagai file';

  @override
  String get restoreFromBackup => 'Pulihkan dari Cadangan';

  @override
  String get restoreFromBackupSubtitle => 'Impor data dari file cadangan';

  @override
  String get clearAllDataTitle => 'Hapus semua data?';

  @override
  String get clearAllDataContent =>
      'Semua data akan dihapus:\n• Entri makanan\n• Makanan Saya\n• Bahan\n• Tujuan\n• Informasi pribadi\n\nHal ini tidak dapat dibatalkan!';

  @override
  String get allDataClearedSuccess => 'Semua data berhasil dihapus';

  @override
  String get aboutSection => 'Tentang';

  @override
  String get version => 'Versi';

  @override
  String get healthDisclaimer => 'Penafian Kesehatan';

  @override
  String get importantLegalInformation => 'Informasi hukum penting';

  @override
  String get showTutorialAgain => 'Tampilkan Tutorial Lagi';

  @override
  String get viewFeatureTour => 'Lihat tur fitur';

  @override
  String get showTutorialDialogTitle => 'Tampilkan Tutorial';

  @override
  String get showTutorialDialogContent =>
      'Ini akan menampilkan tur fitur yang menyoroti:\n\n• Sistem Energi\n• Pemindaian Foto Tarik untuk Menyegarkan\n• Ngobrol dengan Miro AI\n\nAnda akan kembali ke layar Beranda.';

  @override
  String get showTutorialButton => 'Tampilkan Tutorial';

  @override
  String get tutorialResetMessage =>
      'Penyetelan ulang tutorial! Buka layar Beranda untuk melihatnya.';

  @override
  String get foodAnalysisTutorial => 'Tutorial Analisis Makanan';

  @override
  String get foodAnalysisTutorialSubtitle =>
      'Pelajari cara menggunakan fitur analisis makanan';

  @override
  String get backupCreated => 'Cadangan Dibuat!';

  @override
  String get backupCreatedContent =>
      'File cadangan Anda telah berhasil dibuat.';

  @override
  String get backupChooseDestination =>
      'Di mana Anda ingin menyimpan cadangan Anda?';

  @override
  String get backupSaveToDevice => 'Simpan ke Perangkat';

  @override
  String get backupSaveToDeviceDesc =>
      'Simpan ke folder yang Anda pilih di perangkat ini';

  @override
  String get backupShareToOther => 'Bagikan ke Perangkat Lain';

  @override
  String get backupShareToOtherDesc =>
      'Kirim melalui Line, Email, Google Drive, dll.';

  @override
  String get backupSavedSuccess => 'Cadangan Tersimpan!';

  @override
  String get backupSavedSuccessContent =>
      'File cadangan Anda telah disimpan ke lokasi pilihan Anda.';

  @override
  String get important => 'Penting:';

  @override
  String get backupImportantNotes =>
      '• Simpan file ini di tempat yang aman (Google Drive, dll.)\n• Foto TIDAK disertakan dalam cadangan\n• Masa berlaku Kunci Transfer akan habis dalam 30 hari\n• Kunci hanya dapat digunakan satu kali';

  @override
  String get restoreBackup => 'Pulihkan Cadangan?';

  @override
  String get backupFrom => 'Cadangan dari:';

  @override
  String get date => 'Tanggal:';

  @override
  String get energy => 'Energi:';

  @override
  String get foodEntries => 'Entri makanan:';

  @override
  String get restoreImportant => 'Penting';

  @override
  String restoreImportantNotes(String energy) {
    return '• Energi Saat Ini pada perangkat ini akan DIGANTI dengan Energi dari cadangan ($energy)\n• Entri makanan akan DIGABUNG (tidak diganti)\n• Foto TIDAK disertakan dalam cadangan\n• Transfer Key akan digunakan (tidak dapat digunakan kembali)';
  }

  @override
  String get restore => 'Memulihkan';

  @override
  String get restoreComplete => 'Pemulihan Selesai!';

  @override
  String get restoreCompleteContent => 'Data Anda telah berhasil dipulihkan.';

  @override
  String get newEnergyBalance => 'Neraca Energi Baru:';

  @override
  String get foodEntriesImported => 'Entri Makanan yang Diimpor:';

  @override
  String get myMealsImported => 'Makanan Saya Diimpor:';

  @override
  String get appWillRefresh =>
      'Aplikasi Anda akan disegarkan untuk menampilkan data yang dipulihkan.';

  @override
  String get backupFailed => 'Pencadangan Gagal';

  @override
  String get invalidBackupFile => 'File Cadangan Tidak Valid';

  @override
  String get restoreFailed => 'Pemulihan Gagal';

  @override
  String get analyticsDataCollection => 'Pengumpulan Data Analisis';

  @override
  String get analyticsEnabled => 'Analytics diaktifkan -';

  @override
  String get analyticsDisabled =>
      'Analytics dinonaktifkan - ไม่เก็บข้อมูลการใช้งาน';

  @override
  String get enabled => 'Diaktifkan';

  @override
  String get enabledSubtitle => 'Diaktifkan - ช่วยปรับปรุงประสบการณ์ใช้งาน';

  @override
  String get disabled => 'Dengan disabilitas';

  @override
  String get disabledSubtitle => 'Disabilitas - ไม่เก็บข้อมูลการใช้งาน';

  @override
  String get imagesPerDay => 'Gambar per hari';

  @override
  String scanUpToImagesPerDay(String limit) {
    return 'Pindai hingga $limit gambar per hari';
  }

  @override
  String get reset => 'Mengatur ulang';

  @override
  String get resetScanHistory => 'Atur Ulang Riwayat Pemindaian';

  @override
  String get resetScanHistorySubtitle =>
      'Hapus semua entri yang dipindai dan pindai ulang';

  @override
  String get imagesPerDayDialog => 'Gambar per hari';

  @override
  String get maxImagesPerDayDescription =>
      'Gambar maksimum untuk dipindai per hari\nHanya memindai tanggal yang dipilih';

  @override
  String scanLimitSetTo(String limit) {
    return 'Batas pemindaian disetel ke $limit gambar per hari';
  }

  @override
  String get resetScanHistoryDialog => 'Setel Ulang Riwayat Pemindaian?';

  @override
  String get resetScanHistoryContent =>
      'Semua entri makanan yang dipindai di galeri akan dihapus.\nTarik ke bawah pada tanggal mana saja untuk memindai ulang gambar.';

  @override
  String resetComplete(String count) {
    return 'Reset selesai - $count entri dihapus. Tarik ke bawah untuk memindai ulang.';
  }

  @override
  String questBarStreak(int days) {
    return 'Garis $days hari';
  }

  @override
  String questBarDaysToNextTier(int days, String tier) {
    return '$days hari → $tier';
  }

  @override
  String get questBarMaxTier => 'Tingkat Maks! 💎';

  @override
  String get questBarOfferDismissed => 'Penawaran disembunyikan';

  @override
  String get questBarViewOffer => 'Lihat Penawaran';

  @override
  String get questBarNoOffersNow => '• Tidak ada penawaran saat ini';

  @override
  String get questBarWeeklyChallenges => '🎯 Tantangan Mingguan';

  @override
  String get questBarMilestones => '🏆 Tonggak sejarah';

  @override
  String get questBarInviteFriends => '👥 Undang teman & dapatkan 20E';

  @override
  String questBarTimeRemaining(String time) {
    return '⏰ Waktu tersisa $time';
  }

  @override
  String questBarClaimDailyEnergy(int energy) {
    return '+${energy}E';
  }

  @override
  String questBarShareReferralError(String error) {
    return 'Kesalahan berbagi: $error';
  }

  @override
  String tierCelebrationTitle(String tier) {
    return '$tier Perayaan 🎉';
  }

  @override
  String tierCelebrationDay(int day) {
    return 'Hari $day';
  }

  @override
  String get tierCelebrationExpired => 'Kedaluwarsa';

  @override
  String get tierCelebrationComplete => 'Menyelesaikan!';

  @override
  String questBarWatchAd(int energy) {
    return 'Tonton Iklan +$energy⚡';
  }

  @override
  String questBarAdRemaining(int remaining, int total) {
    return '$remaining/$total tersisa hari ini';
  }

  @override
  String questBarAdSuccess(int energy) {
    return 'Iklan ditonton! +$energy Energi masuk...';
  }

  @override
  String get questBarAdNotReady => 'Iklan belum siap, silakan coba lagi';

  @override
  String get questBarDailyChallenge => 'Tantangan Harian';

  @override
  String get questBarUseAi => 'Gunakan Energi';

  @override
  String get questBarResetsMonday => 'Reset setiap hari Senin';

  @override
  String get questBarClaimed => 'Diklaim!';

  @override
  String get questBarHideOffer => 'Bersembunyi';

  @override
  String get questBarViewDetails => 'Melihat';

  @override
  String questBarShareText(String link) {
    return 'Coba MiRO! Analisis makanan bertenaga AI 🍔\nGunakan tautan ini dan kita berdua mendapatkan +20 Energi gratis!\n\n$link';
  }

  @override
  String get questBarShareSubject => 'Coba MiRO';

  @override
  String get claimButtonTitle => 'Klaim Energi Harian';

  @override
  String claimButtonReceived(String energy) {
    return 'Diterima +${energy}E!';
  }

  @override
  String get claimButtonAlreadyClaimed => 'Sudah diklaim hari ini';

  @override
  String claimButtonError(String error) {
    return 'Kesalahan: $error';
  }

  @override
  String get seasonalQuestLimitedTime => 'WAKTU TERBATAS';

  @override
  String seasonalQuestDaysLeft(int days) {
    return '$days hari tersisa';
  }

  @override
  String seasonalQuestRewardDaily(int reward) {
    return '+${reward}E / hari';
  }

  @override
  String seasonalQuestRewardOnce(int reward) {
    return '+${reward}E satu kali';
  }

  @override
  String get seasonalQuestClaimed => 'Diklaim!';

  @override
  String get seasonalQuestClaimedToday => 'Diklaim hari ini';

  @override
  String get errorFailed => 'Gagal';

  @override
  String get errorFailedToClaim => 'Gagal mengklaim';

  @override
  String errorGeneric(String error) {
    return 'Kesalahan: $error';
  }

  @override
  String get milestoneNoMilestonesToClaim =>
      'Belum ada pencapaian yang dapat diklaim';

  @override
  String milestoneClaimedEnergy(int energy) {
    return '🎁 Diklaim +$energy Energi!';
  }

  @override
  String get milestoneTitle => 'Tonggak sejarah';

  @override
  String milestoneUseEnergyComplete(int threshold) {
    return 'Gunakan Energi $threshold';
  }

  @override
  String milestoneNext(int threshold) {
    return 'Berikutnya: ${threshold}E';
  }

  @override
  String get milestoneAllComplete => 'Semua pencapaian selesai!';

  @override
  String get noEnergyTitle => 'Kehabisan Energi';

  @override
  String get noEnergyContent =>
      'Anda membutuhkan 1 Energi untuk menganalisis makanan dengan AI';

  @override
  String get noEnergyTip =>
      'Anda masih bisa mencatat makanan secara manual (tanpa AI) secara gratis';

  @override
  String get noEnergyLater => 'Nanti';

  @override
  String noEnergyWatchAd(int remaining) {
    return 'Tonton Iklan ($remaining/3)';
  }

  @override
  String get noEnergyBuyEnergy => 'Beli Energi';

  @override
  String get tierBronze => 'Perunggu';

  @override
  String get tierSilver => 'Perak';

  @override
  String get tierGold => 'Emas';

  @override
  String get tierDiamond => 'Berlian';

  @override
  String get tierStarter => 'Starter';

  @override
  String get tierUpCongratulations => '🎉 Selamat!';

  @override
  String tierUpYouReached(String tier) {
    return 'Anda mencapai $tier!';
  }

  @override
  String get tierUpMotivation =>
      'Lacak kalori seperti seorang profesional\nTubuh impian Anda semakin dekat!';

  @override
  String tierUpReward(int reward) {
    return '+${reward}E Hadiah!';
  }

  @override
  String get referralAllLevelsClaimed => 'Semua level diklaim!';

  @override
  String referralLevel(int level, String subtitle) {
    return 'Tingkat $level: $subtitle';
  }

  @override
  String referralProgress(int current, int target, int level, int total) {
    return '[$current/$target] (Tingkat $level/$total)';
  }

  @override
  String referralClaimedLevel(int level, int reward) {
    return '🎁 Level yang Diklaim $level: +$reward Energi!';
  }

  @override
  String get challengeUseAi10 => 'Gunakan Energi 10';

  @override
  String get specifyIngredients => 'Tentukan Bahan yang Diketahui';

  @override
  String get specifyIngredientsOptional =>
      'Tentukan bahan-bahan yang diketahui (opsional)';

  @override
  String get specifyIngredientsHint =>
      'Masukkan bahan-bahan yang Anda tahu, dan AI akan menemukan bumbu, minyak, dan saus tersembunyi untuk Anda.';

  @override
  String get sendToAi => 'Kirim ke AI';

  @override
  String get reanalyzeWithIngredients => 'Tambahkan Bahan & Analisis Ulang';

  @override
  String get reanalyzeButton => 'Analisis ulang (1 Energi)';

  @override
  String get ingredientsSaved => 'Bahan-bahannya disimpan';

  @override
  String get pleaseAddAtLeastOneIngredient =>
      'Silakan tambahkan setidaknya 1 bahan';

  @override
  String get hiddenIngredientsDiscovered =>
      'Bahan tersembunyi ditemukan oleh AI';

  @override
  String get retroScanTitle => 'Pindai Foto Terbaru?';

  @override
  String get retroScanDescription =>
      'Kami dapat memindai foto Anda dari 7 hari terakhir untuk secara otomatis menemukan foto makanan dan menambahkannya ke buku harian Anda.';

  @override
  String get retroScanNote =>
      'Hanya foto makanan yang terdeteksi — foto lainnya diabaikan. Tidak ada foto yang keluar dari perangkat Anda.';

  @override
  String get retroScanStart => 'Pindai Foto Saya';

  @override
  String get retroScanSkip => 'Lewati untuk saat ini';

  @override
  String get retroScanInProgress => 'Memindai...';

  @override
  String get retroScanTagline =>
      'MiRO mengubah Anda\nfoto makanan menjadi data kesehatan.';

  @override
  String get retroScanFetchingPhotos => 'Mengambil foto terbaru...';

  @override
  String get retroScanAnalyzing => 'Mendeteksi foto makanan...';

  @override
  String retroScanPhotosFound(int count) {
    return '$count foto ditemukan dalam 7 hari terakhir';
  }

  @override
  String get retroScanCompleteTitle => 'Pemindaian Selesai!';

  @override
  String retroScanCompleteDesc(int count) {
    return 'Menemukan $count foto makanan! Mereka telah ditambahkan ke timeline Anda, siap untuk analisis AI.';
  }

  @override
  String get retroScanNoResultsTitle => 'Tidak Ada Foto Makanan Ditemukan';

  @override
  String get retroScanNoResultsDesc =>
      'Tidak ada foto makanan yang terdeteksi dalam 7 hari terakhir. Coba ambil foto makanan Anda berikutnya!';

  @override
  String get retroScanAnalyzeHint =>
      'Ketuk \"Analisis Semua\" di timeline Anda untuk mendapatkan analisis nutrisi AI untuk entri ini.';

  @override
  String get retroScanDone => 'Mengerti!';

  @override
  String get welcomeEndTitle => 'Selamat datang di MiRO!';

  @override
  String get welcomeEndMessage => 'MiRO siap melayani Anda.';

  @override
  String get welcomeEndJourney => 'Semoga perjalananmu menyenangkan bersama!!';

  @override
  String get welcomeEndStart => 'Ayo Mulai!';

  @override
  String greetingCalorieSummary(
      int remaining, int protein, int carbs, int fat) {
    return 'Hai! Apa yang bisa saya bantu hari ini? Anda masih memiliki $remaining kcal tersisa. Sejauh ini: Protein ${protein}g, Karbohidrat ${carbs}g, Lemak ${fat}g. Beri tahu saya apa yang Anda makan — daftarkan semuanya berdasarkan makanan dan saya akan mencatat semuanya untuk Anda. Lebih Detail lebih tepat!!';
  }

  @override
  String greetingCuisineTip(String cuisine) {
    return 'Masakan pilihan Anda disetel ke $cuisine. Anda dapat mengubahnya di Pengaturan kapan saja!';
  }

  @override
  String greetingEnergyTip(int balance) {
    return 'Anda memiliki $balance Energi yang tersedia. Jangan lupa untuk mengklaim hadiah pukulan harian Anda pada lencana Energi!';
  }

  @override
  String get greetingRenamePhotoTip =>
      'Tip: Anda dapat mengganti nama foto makanan untuk membantu MiRO menganalisis dengan lebih akurat!';

  @override
  String get greetingAddIngredientsTip =>
      'Tip: Anda dapat menambahkan bahan-bahan yang Anda yakini sebelum mengirim ke MiRO untuk dianalisis. Saya akan memikirkan semua detail kecil yang membosankan untuk Anda!';

  @override
  String greetingBackupReminder(int days) {
    return 'Hai bos! Anda belum mencadangkan data Anda selama $days hari. Saya sarankan membuat cadangan di Pengaturan — data Anda disimpan secara lokal dan saya tidak dapat memulihkannya jika terjadi sesuatu!';
  }

  @override
  String get greetingFallback =>
      'Hai! Apa yang bisa saya bantu hari ini? Katakan padaku apa yang kamu makan!';

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
      'Memberikan nama makanan, jumlah, dan memilih apakah itu makanan atau produk akan meningkatkan akurasi AI.';

  @override
  String get hideDetails => 'Hide details';

  @override
  String get showDetails => 'Show details';

  @override
  String get searchModeLabel => 'Mode Pencarian';

  @override
  String get normalFood => 'Makanan';

  @override
  String get normalFoodDesc => 'Makanan rumahan biasa';

  @override
  String get packagedProduct => 'Produk';

  @override
  String get packagedProductDesc => 'Kemasan dengan label nutrisi';

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
