@echo off
echo ==========================================
echo   Miro - Launching on Mobile Device
echo ==========================================
echo.

:: ตรวจสอบว่ามีเครื่องโทรศัพท์เชื่อมต่ออยู่หรือไม่
echo [*] Checking connected devices...
flutter devices

echo.
echo [*] Starting flutter run...
echo [TIP] If multiple devices are connected, use 'flutter run -d <DeviceId>'
echo.

:: รันแอป
:: -d RFCX90FZS8E (ID เครื่องที่ตรวจพบปัจจุบัน)
flutter run -d RFCX90FZS8E

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [!] Failed to run. Trying default flutter run...
    flutter run
)

pause