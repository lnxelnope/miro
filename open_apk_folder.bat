@echo off
if exist "build\app\outputs\flutter-apk\app-debug.apk" (
    echo Opening APK folder...
    explorer build\app\outputs\flutter-apk\
) else (
    echo APK not found! Run: flutter build apk --debug first
    pause
)
