# 🍎 Miro Hybrid - iOS Setup Guide (Mac)

คู่มือสำหรับ setup โปรเจกต์บน Mac เพื่อ develop และ launch iOS app

---

## 📋 ข้อมูลโปรเจกต์

- **App Name**: Miro Hybrid
- **Package Name**: miro_hybrid
- **Version**: 1.1.14+39
- **Current Branch**: `feature/airbnb-redesign`
- **Flutter SDK**: >=3.2.0 <4.0.0

---

## 🛠️ Prerequisites (ติดตั้งก่อน)

### 1. Xcode
```bash
# ติดตั้งจาก App Store
# หรือดาวน์โหลดจาก: https://developer.apple.com/xcode/

# ติดตั้ง Command Line Tools
xcode-select --install

# ตรวจสอบ
xcode-select -p
```

### 2. Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 3. CocoaPods
```bash
sudo gem install cocoapods
# หรือ
brew install cocoapods
```

### 4. Flutter SDK
```bash
# ติดตั้ง Flutter
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# หรือใช้ Homebrew
brew install flutter

# ตรวจสอบ
flutter doctor
```

### 5. Git
```bash
# ตรวจสอบว่ามีอยู่แล้วหรือไม่
git --version

# ถ้ายังไม่มี
brew install git
```

---

## 🚀 Setup Steps

### Step 1: Clone Repository
```bash
# Clone โปรเจกต์
git clone <YOUR_REPOSITORY_URL> miro
cd miro

# Checkout branch ที่ถูกต้อง
git checkout feature/airbnb-redesign

# ตรวจสอบสถานะ
git status
git branch
```

### Step 2: ตั้งค่า Environment Variables
```bash
# สร้างไฟล์ .env ใน root directory
nano .env
```

เพิ่มเนื้อหา:
```env
# Get your API key from: https://aistudio.google.com/app/apikey
GEMINI_API_KEY=YOUR_ACTUAL_GEMINI_API_KEY_HERE
```

**⚠️ สำคัญ**: 
- ใส่ API key **จริง** (ไม่ใช่ placeholder)
- ไฟล์นี้อยู่ใน .gitignore แล้ว ไม่ต้องกังวลเรื่อง commit
- สร้าง API key ที่: https://aistudio.google.com/app/apikey

### Step 3: ติดตั้ง Dependencies
```bash
# ติดตั้ง Flutter packages
flutter pub get

# Generate code (Riverpod, Isar, JSON serialization)
flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 4: สร้าง iOS Project (ถ้ายังไม่มี)
```bash
# ถ้ายังไม่มีโฟลเดอร์ ios/ ให้รันคำสั่งนี้
flutter create --platforms=ios .

# หรือถ้าต้องการ recreate
flutter create .
```

### Step 5: ติดตั้ง iOS Pods
```bash
cd ios
pod install
cd ..
```

**หมายเหตุ**: ถ้าเจอปัญหา pods ให้ลอง:
```bash
cd ios
pod repo update
pod install --repo-update
cd ..
```

### Step 6: Configure Firebase สำหรับ iOS

#### 6.1 ดาวน์โหลด GoogleService-Info.plist
1. ไปที่ [Firebase Console](https://console.firebase.google.com)
2. เลือกโปรเจกต์
3. Project Settings > Your apps > iOS app
4. ดาวน์โหลด `GoogleService-Info.plist`

#### 6.2 เพิ่มไฟล์เข้า Xcode Project
```bash
# วางไฟล์ที่
cp GoogleService-Info.plist ios/Runner/

# หรือเปิด Xcode แล้ว drag & drop
open ios/Runner.xcworkspace
```

ใน Xcode:
- Drag `GoogleService-Info.plist` เข้า `Runner` folder
- ✅ Check "Copy items if needed"
- ✅ Check "Runner" target

### Step 7: Configure iOS Permissions

เปิดไฟล์ `ios/Runner/Info.plist` และเพิ่ม:

```xml
<key>NSCameraUsageDescription</key>
<string>Miro ต้องการเข้าถึงกล้องเพื่อสแกนบาร์โค้ดและวิเคราะห์อาหาร</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Miro ต้องการเข้าถึงรูปภาพเพื่อวิเคราะห์โภชนาการจากภาพอาหาร</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>Miro ต้องการบันทึกรูปภาพที่วิเคราะห์แล้ว</string>

<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
</dict>
```

### Step 8: Configure AdMob (ถ้ามี App ID)

เพิ่มใน `ios/Runner/Info.plist`:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-YOUR_ADMOB_APP_ID</string>

<key>SKAdNetworkItems</key>
<array>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>cstr6suwn9.skadnetwork</string>
    </dict>
</array>
```

**หมายเหตุ**: แทนที่ `YOUR_ADMOB_APP_ID` ด้วย App ID จริงจาก [AdMob Console](https://apps.admob.com)

### Step 9: ตั้งค่า Bundle Identifier & Signing

เปิด Xcode:
```bash
open ios/Runner.xcworkspace
```

ใน Xcode:
1. เลือก **Runner** project (sidebar ซ้าย)
2. เลือก **Runner** target
3. ไปที่ tab **Signing & Capabilities**
4. ตั้งค่า:
   - **Bundle Identifier**: `com.yourcompany.mirohybrid` (หรือตามที่ตั้งไว้)
   - **Team**: เลือก Apple Developer Team ของคุณ
   - ✅ **Automatically manage signing**

### Step 10: ตรวจสอบ Configuration

```bash
# ตรวจสอบว่าทุกอย่างพร้อม
flutter doctor -v

# ดู iOS devices/simulators ที่มี
flutter devices
```

---

## 🏃 Running the App

### บน iOS Simulator
```bash
# รัน default simulator
flutter run

# หรือระบุ device
flutter run -d "iPhone 15 Pro"

# หรือเลือกจากรายการ
flutter devices
flutter run -d <DEVICE_ID>
```

### บน Physical Device (iPhone/iPad จริง)
```bash
# เชื่อมต่อ iPhone/iPad เข้า Mac
# ตรวจสอบว่าเห็น device
flutter devices

# รัน
flutter run -d <DEVICE_ID>
```

**หมายเหตุ**: สำหรับ physical device ต้อง:
- ลงทะเบียน device ใน Apple Developer Portal
- มี Provisioning Profile ที่ถูกต้อง

---

## 🔨 Build Commands

### Debug Build
```bash
flutter build ios --debug
```

### Release Build
```bash
flutter build ios --release
```

### สำหรับ TestFlight/App Store
```bash
# Build IPA file
flutter build ipa

# หรือใช้ Xcode
open ios/Runner.xcworkspace
# Product > Archive > Distribute App
```

---

## 📦 Key Dependencies ที่ใช้ iOS Native Features

```yaml
✅ camera: ^0.10.5+5                    # Camera access
✅ google_mlkit_*                        # ML Kit (text, barcode, image)
✅ mobile_scanner: ^5.2.3                # Barcode scanner
✅ photo_manager: ^3.6.0                 # Photo library access
✅ firebase_core: ^3.6.0                 # Firebase
✅ firebase_analytics: ^11.3.3           # Analytics
✅ firebase_messaging: ^15.1.3           # Push notifications
✅ cloud_firestore: ^5.5.0               # Firestore
✅ cloud_functions: ^5.6.2               # Cloud Functions
✅ google_mobile_ads: ^5.0.0             # AdMob
✅ in_app_purchase: ^3.2.3               # In-App Purchase
```

---

## ⚠️ Troubleshooting

### ปัญหา: CocoaPods install ล้มเหลว
```bash
cd ios
rm -rf Pods Podfile.lock
pod cache clean --all
pod install --repo-update
cd ..
```

### ปัญหา: Xcode signing error
- ตรวจสอบว่ามี Apple Developer Account
- ลองใช้ "Automatically manage signing"
- หรือสร้าง Provisioning Profile ใหม่

### ปัญหา: Flutter doctor มีปัญหา
```bash
# Clear Flutter cache
flutter clean
flutter pub get

# Update Flutter
flutter upgrade
```

### ปัญหา: Build ช้า
```bash
# Enable build mode with faster compilation
flutter run --debug --start-paused
```

### ปัญหา: Firebase not initialized
- ตรวจสอบว่า `GoogleService-Info.plist` อยู่ใน `ios/Runner/` และอยู่ใน Xcode project
- ตรวจสอบว่า bundle ID ตรงกับที่ตั้งไว้ใน Firebase Console

### ปัญหา: ML Kit ไม่ทำงาน
```bash
# ML Kit models อาจต้องดาวน์โหลดครั้งแรก
# ให้ run app แล้วรอซักครู่ (ต้องมี internet)
```

---

## 🔐 Security Checklist

- [x] `.env` file มี API key จริง (ไม่ commit เข้า Git)
- [x] `GoogleService-Info.plist` ใน `ios/Runner/` (ไม่ควร commit)
- [x] AdMob App ID ตั้งค่าถูกต้อง
- [x] Bundle ID ตรงกับที่ลงทะเบียนไว้
- [x] Signing certificate ถูกต้อง

---

## 📝 Additional Notes

### Minimum iOS Version
- Min deployment target: **iOS 12.0** (ตาม dependencies)
- แนะนำ: iOS 13.0+

### Device Support
- ✅ iPhone (iOS 12.0+)
- ✅ iPad (iOS 12.0+)
- ✅ iOS Simulator

### Performance Tips
- ใช้ `--release` mode สำหรับ performance testing
- ใช้ `--profile` mode สำหรับ debugging performance

---

## 📞 Getting Help

### Flutter Issues
```bash
flutter doctor -v
flutter analyze
flutter test
```

### Xcode Logs
- เปิด Console app (Applications > Utilities > Console)
- เลือก device/simulator ที่รัน app
- ดู crash logs และ errors

### Firebase Issues
- [Firebase Console](https://console.firebase.google.com)
- ตรวจสอบ Firebase Debug View (ถ้าเปิด Debug mode)

---

## ✅ Quick Start Checklist

- [ ] ติดตั้ง Xcode, Flutter, CocoaPods
- [ ] Clone repository
- [ ] Create `.env` with GEMINI_API_KEY
- [ ] Run `flutter pub get`
- [ ] Run `flutter pub run build_runner build`
- [ ] Run `flutter create .` (ถ้ายังไม่มี ios/)
- [ ] Run `cd ios && pod install && cd ..`
- [ ] Add `GoogleService-Info.plist` to `ios/Runner/`
- [ ] Configure permissions in Info.plist
- [ ] Setup signing in Xcode
- [ ] Run `flutter run`

---

**🎉 พร้อมแล้ว! ขอให้ develop สนุกครับ**

สร้างโดย: Cursor AI Assistant  
วันที่: 2026-02-21  
สำหรับ: Miro Hybrid iOS Development
