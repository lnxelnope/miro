# Fix Build Errors Script
# Usage: .\fix_build.ps1

Write-Host "Step 1: Remove task.g.dart" -ForegroundColor Yellow
Remove-Item "lib\features\tasks\models\task.g.dart" -ErrorAction SilentlyContinue

Write-Host "Step 2: Flutter Clean" -ForegroundColor Yellow
flutter clean

Write-Host "Step 3: Flutter Pub Get" -ForegroundColor Yellow
flutter pub get

Write-Host "Step 4: Remove all .g.dart files" -ForegroundColor Yellow
Get-ChildItem -Path "lib" -Filter "*.g.dart" -Recurse | Remove-Item -ErrorAction SilentlyContinue

Write-Host "Step 5: Regenerate Code" -ForegroundColor Yellow
dart run build_runner build --delete-conflicting-outputs

Write-Host "Done! Run flutter run" -ForegroundColor Green
