@echo off
echo ========================================
echo  Miro Hybrid - Find Flutter SDK
echo ========================================
echo.

REM Check common Flutter installation paths
set FLUTTER_PATHS[0]=C:\flutter\bin
set FLUTTER_PATHS[1]=C:\src\flutter\bin
set FLUTTER_PATHS[2]=%USERPROFILE%\flutter\bin
set FLUTTER_PATHS[3]=%LOCALAPPDATA%\flutter\bin
set FLUTTER_PATHS[4]=D:\flutter\bin
set FLUTTER_PATHS[5]=E:\flutter\bin

echo Searching for Flutter SDK in common locations...
echo.

set FOUND=0
for /L %%i in (0,1,5) do (
    call set "PATH_CHECK=%%FLUTTER_PATHS[%%i]%%"
    if exist "!PATH_CHECK!\flutter.bat" (
        echo [FOUND] Flutter at: !PATH_CHECK!
        set FOUND=1
        set FLUTTER_PATH=!PATH_CHECK!
        goto :found
    )
)

:found
if %FOUND% equ 0 (
    echo [NOT FOUND] Flutter SDK not found in common locations.
    echo.
    echo Options:
    echo 1. Install Flutter: https://flutter.dev/docs/get-started/install/windows
    echo 2. If Flutter is installed elsewhere, add it to PATH manually
    echo 3. Or run this script with Flutter path:
    echo    set PATH_TO_FLUTTER=C:\your\flutter\path\bin
    echo    set PATH=%%PATH_TO_FLUTTER%%;%%PATH%%
    echo    build_apk.bat
    echo.
) else (
    echo.
    echo Adding Flutter to PATH for this session...
    set PATH=%FLUTTER_PATH%;%PATH%
    echo.
    echo Testing Flutter...
    flutter --version
    if %errorlevel% equ 0 (
        echo.
        echo [SUCCESS] Flutter is now in PATH!
        echo You can now run: build_apk.bat
    )
)

echo.
pause
