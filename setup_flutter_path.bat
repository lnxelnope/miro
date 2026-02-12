@echo off
echo ========================================
echo  Miro Hybrid - Setup Flutter Path
echo ========================================
echo.
echo This script will help you add Flutter to PATH temporarily.
echo.
echo Option 1: Auto-detect Flutter
echo Option 2: Manual enter Flutter path
echo.
set /p CHOICE="Choose option (1 or 2): "

if "%CHOICE%"=="1" goto :auto
if "%CHOICE%"=="2" goto :manual
goto :end

:auto
echo.
echo Searching for Flutter...
call find_flutter.bat
goto :end

:manual
echo.
echo Enter your Flutter installation path (e.g., C:\flutter\bin):
set /p FLUTTER_BIN=

if not exist "%FLUTTER_BIN%\flutter.bat" (
    echo ERROR: flutter.bat not found at: %FLUTTER_BIN%
    pause
    exit /b 1
)

echo.
echo Adding to PATH...
set PATH=%FLUTTER_BIN%;%PATH%

echo.
echo Testing Flutter...
flutter --version
if %errorlevel% equ 0 (
    echo.
    echo [SUCCESS] Flutter is ready!
    echo.
    echo Now you can run:
    echo   - build_apk.bat
    echo   - run_web.bat
    echo   - setup_project.bat
    echo.
    echo NOTE: This PATH change is temporary (only for this CMD window)
    echo To make it permanent, add Flutter to System Environment Variables.
) else (
    echo ERROR: Flutter test failed!
)

:end
pause
