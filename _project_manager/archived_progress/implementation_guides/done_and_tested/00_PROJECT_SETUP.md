# Step 00: Project Setup

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 30 นาที
> **ความยาก:** ง่าย

---

## สิ่งที่ต้องทำ

1. สร้าง Flutter project ใหม่
2. ติดตั้ง dependencies ทั้งหมด
3. สร้างโครงสร้าง folder
4. Setup Isar database
5. ทดสอบว่า project run ได้

---

## ขั้นตอนที่ 1: สร้าง Flutter Project

```bash
flutter create miro_app --org com.yourcompany
cd miro_app
```

---

## ขั้นตอนที่ 2: แก้ไข pubspec.yaml

**ไฟล์:** `pubspec.yaml`

**ลบ** เนื้อหาเดิมทั้งหมดใน dependencies แล้ว **แทนที่** ด้วย:

```yaml
name: miro_app
description: Miro - Your Life Assistant
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3

  # Database
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
  path_provider: ^2.1.2

  # UI Components
  flutter_speed_dial: ^7.0.0
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0

  # Storage
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.2

  # Camera & Gallery
  image_picker: ^1.0.7
  photo_manager: ^3.0.0

  # ML Kit (Local AI)
  google_mlkit_text_recognition: ^0.11.0
  google_mlkit_image_labeling: ^0.11.0

  # HTTP & API
  http: ^1.1.0
  dio: ^5.4.0

  # Date & Time
  intl: ^0.18.1

  # Charts
  fl_chart: ^0.66.0

  # Health Connect (Android)
  # health: ^10.0.0

  # Google Calendar
  # googleapis: ^12.0.0
  # googleapis_auth: ^1.4.1

  # Icons
  cupertino_icons: ^1.0.6

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  
  # Isar Generator
  isar_generator: ^3.1.0+1
  build_runner: ^2.4.8
  
  # Riverpod Generator
  riverpod_generator: ^2.3.9

flutter:
  uses-material-design: true
```

---

## ขั้นตอนที่ 3: ติดตั้ง Dependencies

```bash
flutter pub get
```

---

## ขั้นตอนที่ 4: สร้างโครงสร้าง Folder

**รันคำสั่งนี้ใน terminal:**

```bash
# Core folders
mkdir -p lib/core/ai
mkdir -p lib/core/database
mkdir -p lib/core/services
mkdir -p lib/core/theme
mkdir -p lib/core/utils
mkdir -p lib/core/constants

# Feature folders
mkdir -p lib/features/home/presentation
mkdir -p lib/features/home/widgets

mkdir -p lib/features/health/presentation
mkdir -p lib/features/health/widgets
mkdir -p lib/features/health/models
mkdir -p lib/features/health/providers

mkdir -p lib/features/finance/presentation
mkdir -p lib/features/finance/widgets
mkdir -p lib/features/finance/models
mkdir -p lib/features/finance/providers

mkdir -p lib/features/tasks/presentation
mkdir -p lib/features/tasks/widgets
mkdir -p lib/features/tasks/models
mkdir -p lib/features/tasks/providers

mkdir -p lib/features/profile/presentation
mkdir -p lib/features/profile/widgets
mkdir -p lib/features/profile/providers

mkdir -p lib/features/chat/presentation
mkdir -p lib/features/chat/widgets
mkdir -p lib/features/chat/models
mkdir -p lib/features/chat/providers

mkdir -p lib/features/input/presentation

mkdir -p lib/features/shared/models
mkdir -p lib/features/shared/widgets
mkdir -p lib/features/shared/providers
```

---

## ขั้นตอนที่ 5: สร้างไฟล์ Constants

**สร้างไฟล์:** `lib/core/constants/app_constants.dart`

```dart
class AppConstants {
  // App Info
  static const String appName = 'Miro';
  static const String appVersion = '1.0.0';
  
  // Default Goals
  static const double defaultCalorieGoal = 2000;
  static const double defaultProteinGoal = 120;
  static const double defaultCarbGoal = 250;
  static const double defaultFatGoal = 65;
  static const double defaultWaterGoal = 2500; // ml
  
  // API Endpoints
  static const String thaiGoldApiUrl = 'https://api.chnwt.dev/thai-gold-api/latest';
  static const String secApiUrl = 'https://api.sec.or.th';
  
  // Local Storage Keys
  static const String apiKeyStorageKey = 'gemini_api_key';
  static const String userProfileKey = 'user_profile';
  static const String calorieGoalKey = 'calorie_goal';
  static const String proteinGoalKey = 'protein_goal';
  static const String carbGoalKey = 'carb_goal';
  static const String fatGoalKey = 'fat_goal';
}
```

---

## ขั้นตอนที่ 6: สร้างไฟล์ Colors

**สร้างไฟล์:** `lib/core/theme/app_colors.dart`

```dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFF6366F1);      // Indigo-500
  static const Color primaryLight = Color(0xFFA5B4FC); // Indigo-300
  static const Color primaryDark = Color(0xFF4F46E5);  // Indigo-600
  
  // Categories
  static const Color finance = Color(0xFF10B981);      // Emerald-500
  static const Color health = Color(0xFFF59E0B);       // Amber-500
  static const Color tasks = Color(0xFF3B82F6);        // Blue-500
  
  // Status
  static const Color success = Color(0xFF22C55E);      // Green-500
  static const Color warning = Color(0xFFF59E0B);      // Amber-500
  static const Color error = Color(0xFFEF4444);        // Red-500
  static const Color info = Color(0xFF3B82F6);         // Blue-500
  
  // Neutrals (Light Mode)
  static const Color background = Color(0xFFF9FAFB);   // Gray-50
  static const Color surface = Color(0xFFFFFFFF);      // White
  static const Color surfaceVariant = Color(0xFFF3F4F6); // Gray-100
  static const Color textPrimary = Color(0xFF111827);  // Gray-900
  static const Color textSecondary = Color(0xFF6B7280); // Gray-500
  static const Color textTertiary = Color(0xFF9CA3AF); // Gray-400
  static const Color divider = Color(0xFFE5E7EB);      // Gray-200
  
  // Neutrals (Dark Mode)
  static const Color backgroundDark = Color(0xFF111827);   // Gray-900
  static const Color surfaceDark = Color(0xFF1F2937);      // Gray-800
  static const Color surfaceVariantDark = Color(0xFF374151); // Gray-700
  static const Color textPrimaryDark = Color(0xFFF9FAFB);  // Gray-50
  static const Color textSecondaryDark = Color(0xFF9CA3AF); // Gray-400
  static const Color dividerDark = Color(0xFF374151);      // Gray-700
  
  // Income/Expense
  static const Color income = Color(0xFF22C55E);       // Green-500
  static const Color expense = Color(0xFFEF4444);      // Red-500
  
  // Macros
  static const Color protein = Color(0xFFEF4444);      // Red-500
  static const Color carbs = Color(0xFFF59E0B);        // Amber-500
  static const Color fat = Color(0xFF3B82F6);          // Blue-500
}
```

---

## ขั้นตอนที่ 7: สร้างไฟล์ Theme

**สร้างไฟล์:** `lib/core/theme/app_theme.dart`

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.primaryLight,
      surface: AppColors.surface,
      background: AppColors.background,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: AppColors.textPrimary,
      onSurface: AppColors.textPrimary,
      onBackground: AppColors.textPrimary,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
    ),
    cardTheme: CardTheme(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.divider),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: AppColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: AppColors.textSecondary,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.primaryLight,
      surface: AppColors.surfaceDark,
      background: AppColors.backgroundDark,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: AppColors.textPrimaryDark,
      onSurface: AppColors.textPrimaryDark,
      onBackground: AppColors.textPrimaryDark,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surfaceDark,
      foregroundColor: AppColors.textPrimaryDark,
      elevation: 0,
      centerTitle: true,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceDark,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondaryDark,
      type: BottomNavigationBarType.fixed,
    ),
    cardTheme: CardTheme(
      color: AppColors.surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.dividerDark),
      ),
    ),
  );
}
```

---

## ขั้นตอนที่ 8: สร้างไฟล์ main.dart

**แก้ไขไฟล์:** `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'core/theme/app_theme.dart';
import 'core/database/database_service.dart';
import 'features/home/presentation/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Isar Database
  await DatabaseService.initialize();
  
  runApp(
    const ProviderScope(
      child: MiroApp(),
    ),
  );
}

class MiroApp extends StatelessWidget {
  const MiroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Miro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
```

---

## ขั้นตอนที่ 9: สร้างไฟล์ Database Service (ชั่วคราว)

**สร้างไฟล์:** `lib/core/database/database_service.dart`

```dart
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  static late Isar isar;
  
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    
    isar = await Isar.open(
      [], // จะใส่ schemas ทีหลังใน Step 01
      directory: dir.path,
      name: 'miro_db',
    );
  }
}
```

---

## ขั้นตอนที่ 10: สร้าง Home Screen (Placeholder)

**สร้างไฟล์:** `lib/features/home/presentation/home_screen.dart`

```dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Miro'),
      ),
      body: const Center(
        child: Text(
          'Miro App\nSetup Complete! ✅',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
```

---

## ขั้นตอนที่ 11: ทดสอบ Run App

```bash
flutter run
```

**ผลที่ควรได้:** แอปเปิดขึ้นมาแสดงข้อความ "Miro App Setup Complete! ✅"

---

## ✅ Checklist

- [ ] สร้าง Flutter project แล้ว
- [ ] แก้ไข pubspec.yaml แล้ว
- [ ] รัน `flutter pub get` สำเร็จ
- [ ] สร้างโครงสร้าง folder แล้ว
- [ ] สร้างไฟล์ constants แล้ว
- [ ] สร้างไฟล์ colors แล้ว
- [ ] สร้างไฟล์ theme แล้ว
- [ ] สร้างไฟล์ main.dart แล้ว
- [ ] สร้างไฟล์ database_service.dart แล้ว
- [ ] สร้างไฟล์ home_screen.dart แล้ว
- [ ] ทดสอบ run app สำเร็จ

---

## ไฟล์ที่สร้างในขั้นตอนนี้

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── database/
│   │   └── database_service.dart
│   └── theme/
│       ├── app_colors.dart
│       └── app_theme.dart
├── features/
│   └── home/
│       └── presentation/
│           └── home_screen.dart
└── main.dart
```

---

## ขั้นตอนถัดไป

ไปที่ **Step 01: Core Data Models** เพื่อสร้าง data models ทั้งหมด
