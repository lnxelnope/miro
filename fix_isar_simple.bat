@echo off
echo ========================================
echo  Fix Isar Namespace (Simple Method)
echo ========================================
echo.

set ISAR_FILE=%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev\isar_flutter_libs-3.1.0+1\android\build.gradle

if not exist "%ISAR_FILE%" (
    echo ERROR: File not found!
    echo %ISAR_FILE%
    pause
    exit /b 1
)

echo Opening file in Notepad...
echo.
echo INSTRUCTIONS:
echo 1. Find line: android {
echo 2. Add NEW LINE below it:     namespace = "dev.isar.isar_flutter_libs"
echo 3. Save and close
echo.
echo Press any key to open file...
pause >nul

notepad "%ISAR_FILE%"

echo.
echo File closed. Now try: flutter build apk --debug
pause
