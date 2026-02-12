@echo off
echo ========================================
echo  Miro Hybrid - Flutter Web Preview
echo ========================================
echo.

REM Step 1: Add Web Platform if not exists
echo [1/4] Adding Web Platform...
flutter create --platforms web . 2>nul

REM Step 2: Get Dependencies
echo [2/4] Getting Dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Failed to get dependencies!
    pause
    exit /b 1
)

REM Step 3: Use Web-compatible entry point
echo [3/4] Preparing Web version...
copy lib\main.dart lib\main_mobile.dart >nul 2>&1
copy lib\main_web.dart lib\main.dart >nul 2>&1

REM Step 4: Run on Chrome
echo [4/4] Launching Chrome...
echo.
echo *** NOTE: ML Kit and Isar will NOT work on Web ***
echo *** This is for UI Preview only ***
echo.
flutter run -d chrome --target=lib/main.dart

REM Restore original main.dart
copy lib\main_mobile.dart lib\main.dart >nul 2>&1
del lib\main_mobile.dart >nul 2>&1

echo.
echo ========================================
echo  Script finished.
echo ========================================
pause
