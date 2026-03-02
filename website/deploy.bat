@echo off
setlocal

echo === MiRO Website - Build ^& Deploy ===
echo.

cd /d "%~dp0"

echo 1. Installing dependencies...
call npm ci
if errorlevel 1 (
    echo ERROR: npm ci failed
    exit /b 1
)

echo.
echo 2. Building static site...
call npm run build
if errorlevel 1 (
    echo ERROR: npm run build failed
    exit /b 1
)

echo.
echo 3. Preparing deploy directory...
if exist deploy rmdir /s /q deploy
mkdir deploy\miro
xcopy /e /y /q out\* deploy\miro\

echo.
echo 4. Creating root redirect...
(
echo ^<!DOCTYPE html^>
echo ^<html^>^<head^>^<meta http-equiv="refresh" content="0;url=/miro/"^>^<script^>location.replace^("/miro/"^)^</script^>^</head^>^<body^>Redirecting to ^<a href="/miro/"^>MiRO^</a^>...^</body^>^</html^>
) > deploy\index.html

echo.
echo 5. Deploying to Firebase Hosting...
cd ..
call firebase deploy --only hosting
if errorlevel 1 (
    echo ERROR: Firebase deploy failed
    exit /b 1
)

echo.
echo === Deploy complete! ===
echo Website: https://miro-d6856.web.app/miro/
echo Support: https://miro-d6856.web.app/miro/support/
echo Privacy: https://miro-d6856.web.app/miro/privacy/
echo Terms:   https://miro-d6856.web.app/miro/terms/
echo.

pause
