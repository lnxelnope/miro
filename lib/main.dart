import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:miro_hybrid/l10n/app_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/database/database_service.dart';
import 'core/services/purchase_service.dart';
import 'core/ai/llm_service.dart';
import 'core/utils/logger.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/profile/providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
  
  // Load food name database async (doesn't block startup)
  LLMService.loadFoodDatabase();
  
  // Initialize In-App Purchase
  await PurchaseService.initialize();
  AppLogger.info('Purchase Service initialized');

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
      title: 'MIRO - Intake Oracle',
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
        Locale('en'),  // English (default)
        Locale('th'),  // Thai (future)
      ],
      locale: locale,  // null = use system locale
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