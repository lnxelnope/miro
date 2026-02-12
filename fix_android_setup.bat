@echo off
echo ========================================
echo  Fix Android Setup for Flutter
echo ========================================
echo.

REM Step 1: Accept Android Licenses
echo [1/2] Accepting Android Licenses...
flutter doctor --android-licenses
if %errorlevel% neq 0 (
    echo.
    echo WARNING: License acceptance failed.
    echo You may need to install cmdline-tools first.
    echo.
)

REM Step 2: Check cmdline-tools
echo.
echo [2/2] Checking cmdline-tools...
echo.
echo If cmdline-tools is missing, you need to:
echo 1. Open Android Studio
echo 2. Go to: Tools ^> SDK Manager
echo 3. SDK Tools tab
echo 4. Check "Android SDK Command-line Tools"
echo 5. Click Apply
echo.

REM Final check
echo ========================================
echo  Running flutter doctor...
echo ========================================
flutter doctor

echo.
pause
