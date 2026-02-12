import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.primaryLight,
      surface: AppColors.surface,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: AppColors.textPrimary,
      onSurface: AppColors.textPrimary,
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
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.divider),
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
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.primaryLight,
      surface: AppColors.surfaceDark,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: AppColors.textPrimaryDark,
      onSurface: AppColors.textPrimaryDark,
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
    cardTheme: CardThemeData(
      color: AppColors.surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.dividerDark),
      ),
    ),
  );
}
