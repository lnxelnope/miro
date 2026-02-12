@echo off
echo ========================================
echo  Miro Hybrid - Serve APK via QR Code
echo ========================================
echo.

REM Check if APK exists
if not exist "build\app\outputs\flutter-apk\app-debug.apk" (
    echo ERROR: APK not found! Run build_apk.bat first.
    pause
    exit /b 1
)

REM Get local IP
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4"') do (
    set IP=%%a
    goto :found
)
:found
set IP=%IP:~1%

echo.
echo Your Local IP: %IP%
echo.

REM Create temp folder for serving
if not exist "temp_server" mkdir temp_server
copy "build\app\outputs\flutter-apk\app-debug.apk" "temp_server\miro.apk" >nul

REM Create simple HTML page
echo ^<html^>^<head^>^<title^>Miro APK Download^</title^>^</head^> > temp_server\index.html
echo ^<body style="font-family:Arial;text-align:center;padding:50px"^> >> temp_server\index.html
echo ^<h1^>Miro Hybrid APK^</h1^> >> temp_server\index.html
echo ^<p^>^<a href="miro.apk" style="font-size:24px"^>Download APK^</a^>^</p^> >> temp_server\index.html
echo ^<p^>Or scan QR Code on your phone^</p^> >> temp_server\index.html
echo ^</body^>^</html^> >> temp_server\index.html

echo ========================================
echo  Starting Local Server on port 8080
echo ========================================
echo.
echo On your Android phone:
echo 1. Connect to the SAME Wi-Fi network
echo 2. Open Browser and go to: http://%IP%:8080
echo 3. Download and install the APK
echo.
echo (Press Ctrl+C to stop server)
echo.

cd temp_server
python -m http.server 8080

pause
