# 📦 Flutter Installation Guide for Windows

## Quick Install (Recommended)

### Method 1: Using Git (Fastest)

```powershell
# 1. Install Git if you don't have it: https://git-scm.com/download/win

# 2. Open PowerShell as Administrator, then:
cd C:\
git clone https://github.com/flutter/flutter.git -b stable

# 3. Add to PATH:
# - Press Win + R, type: sysdm.cpl
# - Go to "Advanced" tab > "Environment Variables"
# - Under "System Variables", find "Path" > Edit
# - Add: C:\flutter\bin
# - Click OK on all dialogs

# 4. Restart Command Prompt/PowerShell
```

### Method 2: Download ZIP

1. Download Flutter SDK: https://docs.flutter.dev/get-started/install/windows
2. Extract to `C:\flutter` (or any location)
3. Add `C:\flutter\bin` to System PATH (same as Method 1, step 3)

---

## Verify Installation

Open **NEW** Command Prompt and run:

```bash
flutter doctor
```

You should see:
- ✅ Flutter (Channel stable)
- ✅ Android toolchain (if Android Studio installed)
- ⚠️ Some items might show warnings (that's OK for basic use)

---

## Quick Fix Scripts

If Flutter is installed but not in PATH:

### Option A: Use Auto-Detection
```
setup_flutter_path.bat
```

### Option B: Manual Path Setup
1. Find where Flutter is installed (usually `C:\flutter\bin`)
2. Open Command Prompt in this project folder
3. Run:
```cmd
set PATH=C:\flutter\bin;%PATH%
build_apk.bat
```

---

## Common Issues

### Issue: "flutter is not recognized"
**Solution:** Flutter is not in PATH. Use `setup_flutter_path.bat` or add manually.

### Issue: "Android SDK not found"
**Solution:** Install Android Studio: https://developer.android.com/studio
- During install, make sure to install "Android SDK" and "Android SDK Platform-Tools"

### Issue: "No devices found" (for running on phone)
**Solution:** 
- Enable Developer Options on your Android phone
- Enable USB Debugging
- Connect phone via USB

---

## After Installation

Once Flutter is installed and in PATH:

1. Run: `check_setup.bat` (should show all ✅)
2. Run: `setup_project.bat` (setup project structure)
3. Run: `build_apk.bat` (build APK)

---

## Need Help?

- Flutter Docs: https://flutter.dev/docs/get-started/install/windows
- Flutter Community: https://flutter.dev/community
