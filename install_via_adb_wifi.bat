@echo off
echo ========================================
echo  Miro Hybrid - Wireless ADB Install
echo ========================================
echo.
echo Prerequisites:
echo 1. Enable Developer Options on your Android phone
echo 2. Enable "Wireless debugging" 
echo 3. On phone: Settings ^> Developer Options ^> Wireless debugging ^> Pair device with pairing code
echo.

REM Check if APK exists
if not exist "build\app\outputs\flutter-apk\app-debug.apk" (
    echo ERROR: APK not found! Run build_apk.bat first.
    pause
    exit /b 1
)

echo Enter your phone's IP:PORT for pairing (e.g., 192.168.1.100:37000):
set /p PAIR_ADDRESS=

echo Enter the pairing code from your phone:
set /p PAIR_CODE=

echo.
echo [1/3] Pairing with device...
adb pair %PAIR_ADDRESS% %PAIR_CODE%

echo.
echo Enter your phone's IP:PORT for connection (usually different port, e.g., 192.168.1.100:40000):
set /p CONNECT_ADDRESS=

echo.
echo [2/3] Connecting to device...
adb connect %CONNECT_ADDRESS%

echo.
echo [3/3] Installing APK...
adb install build\app\outputs\flutter-apk\app-debug.apk

echo.
echo ========================================
echo  Done! Check your phone for the app.
echo ========================================

pause
