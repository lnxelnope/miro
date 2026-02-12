@echo off
echo ========================================
echo  Miro Hybrid - Environment Check
echo ========================================
echo.

REM Check Flutter
echo [1/4] Checking Flutter...
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo [X] Flutter NOT found in PATH
    echo     Please install Flutter: https://flutter.dev/docs/get-started/install
) else (
    echo [OK] Flutter found
    flutter --version | findstr "Flutter"
)

echo.
echo [2/4] Checking Flutter Doctor...
flutter doctor

echo.
echo [3/4] Checking Project Structure...
if exist "pubspec.yaml" (
    echo [OK] pubspec.yaml found
) else (
    echo [X] pubspec.yaml NOT found
)

if exist "lib\main.dart" (
    echo [OK] lib/main.dart found
) else (
    echo [X] lib/main.dart NOT found
)

if exist "android\build.gradle" (
    echo [OK] Android structure exists
) else (
    echo [X] Android structure missing - Run: setup_project.bat
)

if exist "build\" (
    echo [OK] Build folder exists
) else (
    echo [!] Build folder not found (normal if not built yet)
)

echo.
echo [4/4] Checking Dependencies...
if exist "pubspec.yaml" (
    flutter pub get >nul 2>&1
    if %errorlevel% equ 0 (
        echo [OK] Dependencies OK
    ) else (
        echo [X] Dependencies have issues
    )
)

echo.
echo ========================================
echo  Check Complete!
echo ========================================
echo.
echo If you see [X] errors above:
echo 1. Install Flutter SDK
echo 2. Run: setup_project.bat
echo 3. Run: flutter doctor
echo.

pause
