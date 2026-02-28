@echo off
REM Force window to stay open using cmd /k hack
if "%1"=="STAY_OPEN" goto :main
cmd /k "%~f0" STAY_OPEN
exit /b

:main
echo ========================================
echo  Miro Hybrid - Debug Run (Persistent)
echo ========================================
echo.

REM Check Flutter first
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Flutter not found in PATH!
    echo Please fix your PATH or run 'setup_flutter_path.bat' first.
    exit /b
)

REM Step 1: Generate Code
echo [1/2] Generating Code...
call flutter pub run build_runner build --delete-conflicting-outputs

REM Step 2: Run App
echo.
echo [2/2] Launching App...
echo.
echo Tips: 'r' = Hot Reload, 'R' = Restart, 'q' = Quit
echo.

flutter run

echo.
echo ========================================
echo  App Process Finished.
echo  You can close this window manually.
echo ========================================
