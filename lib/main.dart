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
import 'core/ai/llm_service.dart';
import 'core/ai/gemini_service.dart';
import 'core/utils/logger.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/profile/providers/locale_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppLogger.info('Firebase initialized successfully');
  } catch (e) {
    AppLogger.warn('Firebase initialization failed: $e');
    // Continue anyway - analytics will fail silently
  }

  // Load environment variables (optional)
  try {
    await dotenv.load(fileName: ".env");
    AppLogger.info('Environment loaded');
  } catch (e) {
    AppLogger.warn('.env file not found, using defaults');
  }

  // Initialize DateFormatting for English (default) and Thai (for food DB dates)
  await initializeDateFormatting('en', null);
  await initializeDateFormatting('th', null);
  AppLogger.info('Date formatting initialized for English and Thai locales');

  // Initialize Isar Database
  await DatabaseService.initialize();

  // ────── Initialize Energy System ──────
  final energyService = EnergyService(DatabaseService.isar);

  // ✅ PHASE 3: Migrate to SecureStorage
  try {
    await energyService.migrateToSecureStorage();
    AppLogger.info('✅ Migrated to SecureStorage');
  } catch (e) {
    AppLogger.warn('⚠️ Failed to migrate to SecureStorage: $e');
    // ไม่ block app launch
  }

  // ✅ PHASE 1: Register or sync user ตอน app startup
  try {
    await energyService.registerOrSync();
    AppLogger.info('✅ User registered/synced');
  } catch (e) {
    AppLogger.warn('⚠️ Failed to register/sync user: $e');
    // ไม่ block app launch
  }

  // ✅ PHASE 2: Retry pending purchases
  try {
    await PurchaseService.retryPendingPurchases();
    AppLogger.info('✅ Pending purchases retried');
  } catch (e) {
    AppLogger.warn('⚠️ Failed to retry pending purchases: $e');
    // ไม่ block app launch
  }

  // ตรวจสอบและมอบ Welcome Gift
  final receivedGift = await energyService.initializeWelcomeGift();
  if (receivedGift) {
    AppLogger.info('🎁 Welcome Gift: 100 Energy!');
  }

  // ────── Migrate Existing Users ──────
  // ตรวจสอบว่าเคยเป็น Pro user หรือไม่
  final prefs = await SharedPreferences.getInstance();
  final wasPro = prefs.getBool('was_pro_user') ?? false;

  // Migrate (ถ้ายังไม่เคยได้ welcome gift)
  await energyService.migrateFromProSystem(
    wasProUser: wasPro,
    isBetaTester: false, // TODO: ตรวจสอบจาก Firebase Auth ถ้ามี
  );

  // ────── Register EnergyService ──────
  GeminiService.setEnergyService(energyService);
  PurchaseService.setEnergyService(energyService);

  AppLogger.info('Energy System initialized');

  // Load food name database async (doesn't block startup)
  LLMService.loadFoodDatabase();

  // Initialize In-App Purchase
  await PurchaseService.initialize();
  AppLogger.info('Purchase Service initialized');

  // ✅ PHASE 3: Initialize Push Notifications (FCM)
  try {
    await NotificationService.initialize();
    AppLogger.info('✅ Notification Service initialized');
  } catch (e) {
    AppLogger.warn('⚠️ Failed to initialize Notification Service: $e');
    // ไม่ block app launch
  }

  // --- Suppress overflow error stripes in debug mode ---
  if (kDebugMode) {
    FlutterError.onError = (FlutterErrorDetails details) {
      final msg = details.exception.toString();
      if (msg.contains('overflowed') || msg.contains('RenderFlex')) return;
      FlutterError.presentError(details);
    };
  }

  runApp(
    const ProviderScope(
      child: MiroApp(),
    ),
  );
}

class MiroApp extends ConsumerWidget {
  const MiroApp({super.key});

  /// ตรวจว่า onboarding เสร็จแล้วหรือยัง
  Future<bool> _checkOnboardingComplete() async {
    final count = await DatabaseService.userProfiles.count();

    if (count == 0) return false;

    final profile = await DatabaseService.userProfiles.get(1);
    return profile?.onboardingComplete ?? false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'MIRO - My Intake Record Oracle',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // === Localization ===
      localizationsDelegates: const [
        L10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English (default)
        Locale('th'), // Thai (future)
      ],
      locale: locale, // null = use system locale
      // === จบ Localization ===

      home: FutureBuilder<bool>(
        future: _checkOnboardingComplete(),
        builder: (context, snapshot) {
          // กำลังโหลด
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // เคยทำ onboarding แล้ว → ไป Home
          if (snapshot.data == true) {
            return const HomeScreen();
          }
          // ยังไม่เคย → ไป Onboarding
          return const OnboardingScreen();
        },
      ),
    );
  }
}
