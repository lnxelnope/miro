@echo off
setlocal enabledelayedexpansion

echo ========================================
echo  Fix Isar Namespace Issue
echo ========================================
echo.

set ISAR_PATH=%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev\isar_flutter_libs-3.1.0+1\android\build.gradle

if not exist "%ISAR_PATH%" (
    echo ERROR: Isar build.gradle not found!
    echo Expected: %ISAR_PATH%
    echo.
    echo Please run: flutter pub get first
    pause
    exit /b 1
)

echo Found: %ISAR_PATH%
echo.

REM Check if namespace already exists
findstr /C:"namespace" "%ISAR_PATH%" >nul 2>&1
if %errorlevel% equ 0 (
    echo Namespace already exists! No need to fix.
    pause
    exit /b 0
)

echo Creating backup...
copy "%ISAR_PATH%" "%ISAR_PATH%.backup" >nul

echo Adding namespace...
echo.

REM Use PowerShell to add namespace
powershell -NoProfile -ExecutionPolicy Bypass -Command "$content = Get-Content '%ISAR_PATH%' -Raw; $content = $content -replace '(android\s*\{)', '$1`n    namespace = \"dev.isar.isar_flutter_libs\"'; Set-Content '%ISAR_PATH%' -Value $content -NoNewline"

if %errorlevel% equ 0 (
    echo.
    echo SUCCESS: Namespace added!
    echo Backup: %ISAR_PATH%.backup
    echo.
    echo Now try: flutter build apk --debug
) else (
    echo ERROR: Failed to add namespace
    echo Restoring backup...
    copy "%ISAR_PATH%.backup" "%ISAR_PATH%" >nul
)

echo.
pause
