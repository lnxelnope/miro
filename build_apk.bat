@echo off
echo ========================================
echo  Miro Hybrid - Build APK
echo ========================================
echo.

REM Check Flutter
echo Checking Flutter...
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ERROR: Flutter not found in PATH!
    echo Please install Flutter first.
    echo.
    pause
    exit /b 1
)

echo Flutter found!
flutter --version
echo.

REM Step 1
echo [1/4] Getting Dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo.
    echo ERROR: pub get failed!
    echo.
    pause
    exit /b 1
)

REM Step 2
echo.
echo [2/4] Generating Code...
flutter pub run build_runner build --delete-conflicting-outputs
echo.

REM Step 3
echo [3/4] Building APK (Debug)...
echo This may take 3-5 minutes...
flutter build apk --debug
if %errorlevel% neq 0 (
    echo.
    echo ERROR: Build failed!
    echo.
    pause
    exit /b 1
)

REM Step 4
echo.
echo [4/4] Verifying APK...
if exist "build\app\outputs\flutter-apk\app-debug.apk" (
    echo.
    echo ========================================
    echo  SUCCESS: APK created!
    echo ========================================
    echo.
    echo Location: build\app\outputs\flutter-apk\app-debug.apk
    echo.
    explorer build\app\outputs\flutter-apk\
) else (
    echo.
    echo ERROR: APK file not found!
    echo.
)

echo.
pause
