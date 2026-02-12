@echo off
echo ========================================
echo  Miro Hybrid - Project Setup
echo ========================================
echo.

REM Check if Flutter is installed
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Flutter not found in PATH!
    echo Please install Flutter and add it to PATH.
    pause
    exit /b 1
)

echo [1/3] Checking Flutter Doctor...
flutter doctor

echo.
echo [2/3] Creating Flutter Project Structure...
REM Only create if android folder doesn't have build.gradle
if not exist "android\build.gradle" (
    echo Creating Android platform files...
    flutter create --org com.miro.hybrid --platforms android .
) else (
    echo Android structure already exists, skipping...
)

echo.
echo [3/3] Getting Dependencies...
flutter pub get

echo.
echo ========================================
echo  Setup Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Run: build_apk.bat
echo 2. Or: run_web.bat
echo.

pause
