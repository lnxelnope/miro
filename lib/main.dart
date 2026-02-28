import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:miro_hybrid/l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'core/theme/app_theme.dart';
import 'core/database/database_service.dart';
import 'core/services/purchase_service.dart';
import 'core/services/energy_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/analytics_service.dart';
import 'core/services/consent_service.dart';
import 'core/services/admob_consent_service.dart';
import 'core/ai/llm_service.dart';
import 'core/ai/gemini_service.dart';
import 'core/utils/logger.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/onboarding/presentation/language_selection_screen.dart';
import 'features/profile/providers/locale_provider.dart';
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';

// Global navigator key for deep linking
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    FlutterError.onError = (FlutterErrorDetails details) {
      final msg = details.exception.toString();
      if (msg.contains('overflowed') || msg.contains('RenderFlex')) return;
      FlutterError.presentError(details);
    };
  }

  // === จำเป็นก่อน runApp: Firebase + DB เท่านั้น ===
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    AppLogger.warn('Firebase initialization failed: $e');
  }

  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {}

  await initializeDateFormatting('en', null);
  await initializeDateFormatting('th', null);
  await DatabaseService.initialize();

  // === แสดง UI ทันที ===
  runApp(
    const ProviderScope(
      child: MiroApp(),
    ),
  );

  // === Init ที่เหลือรันใน background (ไม่ block UI) ===
  _initServicesInBackground();
}

void _initServicesInBackground() async {
  try {
    final energyService = EnergyService(DatabaseService.isar);

    try {
      await energyService.migrateToSecureStorage()
          .timeout(const Duration(seconds: 5), onTimeout: () {});
    } catch (e) {
      AppLogger.warn('⚠️ migrateToSecureStorage: $e');
    }

    try {
      await energyService.registerOrSync()
          .timeout(const Duration(seconds: 10), onTimeout: () => <String, dynamic>{});
    } catch (e) {
      AppLogger.warn('⚠️ registerOrSync: $e');
    }

    try {
      await PurchaseService.retryPendingPurchases()
          .timeout(const Duration(seconds: 5), onTimeout: () {});
    } catch (e) {
      AppLogger.warn('⚠️ retryPendingPurchases: $e');
    }

    try {
      await energyService.initializeWelcomeGift();
    } catch (e) {
      AppLogger.warn('⚠️ initializeWelcomeGift: $e');
    }

    final prefs = await SharedPreferences.getInstance();
    final wasPro = prefs.getBool('was_pro_user') ?? false;
    try {
      await energyService.migrateFromProSystem(
        wasProUser: wasPro,
        isBetaTester: false,
      ).timeout(const Duration(seconds: 5), onTimeout: () {});
    } catch (e) {
      AppLogger.warn('⚠️ migrateFromProSystem: $e');
    }

    GeminiService.setEnergyService(energyService);
    PurchaseService.setEnergyService(energyService);
    LLMService.loadFoodDatabase();

    try {
      await PurchaseService.initialize()
          .timeout(const Duration(seconds: 10), onTimeout: () {});
    } catch (e) {
      AppLogger.warn('⚠️ PurchaseService.initialize: $e');
    }

    try {
      await NotificationService.initialize()
          .timeout(const Duration(seconds: 10), onTimeout: () {});
    } catch (e) {
      AppLogger.warn('⚠️ NotificationService: $e');
    }

    try {
      final hasConsent = await ConsentService.hasConsent();
      await AnalyticsService.initialize(
        appVersion: '1.1.5',
        enabled: hasConsent,
      );
    } catch (e) {
      AppLogger.warn('⚠️ AnalyticsService: $e');
    }

    try {
      await AdmobConsentService.initializeWithConsent()
          .timeout(const Duration(seconds: 15), onTimeout: () {});
    } catch (e) {
      AppLogger.warn('⚠️ AdmobConsentService: $e');
    }

    AppLogger.info('✅ All background services initialized');
  } catch (e) {
    AppLogger.warn('⚠️ Background init error: $e');
  }
}

class MiroApp extends ConsumerStatefulWidget {
  const MiroApp({super.key});

  @override
  ConsumerState<MiroApp> createState() => _MiroAppState();
}

class _MiroAppState extends ConsumerState<MiroApp> {
  bool _isLoading = true;
  bool _languageSelected = false;
  bool _onboardingComplete = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final savedLocale = prefs.getString('selected_locale');
      if (savedLocale != null) {
        ref.read(localeProvider.notifier).state = Locale(savedLocale);
        _languageSelected = true;
      } else {
        _languageSelected = prefs.getBool('language_selected') ?? false;
      }

      final count = await DatabaseService.userProfiles.count();
      if (count > 0) {
        final profile = await DatabaseService.userProfiles.get(1);
        _onboardingComplete = profile?.onboardingComplete ?? false;

        if (profile != null && profile.platform == null) {
          profile.platform = Platform.isIOS ? 'ios' : 'android';
          profile.updatedAt = DateTime.now();
          await DatabaseService.isar.writeTxn(() async {
            await DatabaseService.userProfiles.put(profile);
          });
        }
      }
    } catch (e) {
      debugPrint('_initApp error: $e');
      _languageSelected = true;
      _onboardingComplete = false;
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'MIRO - My Intake Record Oracle',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      navigatorObservers: [AnalyticsService.observer],

      localizationsDelegates: const [
        L10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: L10n.supportedLocales,
      locale: locale,

      builder: (context, child) => GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: child!,
      ),
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_languageSelected) {
      return LanguageSelectionScreen(
        onLanguageSelected: () {
          setState(() => _languageSelected = true);
        },
      );
    }

    if (_onboardingComplete) {
      return const HomeScreen();
    }

    return const OnboardingScreen();
  }
}
