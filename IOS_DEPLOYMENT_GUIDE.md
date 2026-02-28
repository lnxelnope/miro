# 🍎 iOS Deployment Guide - Miro App

คู่มือฉบับสมบูรณ์สำหรับการเตรียมและ deploy แอป Miro บน iOS และ App Store

## 📋 สารบัญ

1. [เตรียม Development Environment](#1-เตรียม-development-environment)
2. [Apple Developer Account](#2-apple-developer-account)
3. [สร้าง iOS Project Configuration](#3-สร้าง-ios-project-configuration)
4. [กำหนด Permissions และ Capabilities](#4-กำหนด-permissions-และ-capabilities)
5. [In-App Purchase Setup](#5-in-app-purchase-setup)
6. [Build และ Test](#6-build-และ-test)
7. [Prepare for App Store](#7-prepare-for-app-store)
8. [Submit to App Store](#8-submit-to-app-store)
9. [App Review Guidelines](#9-app-review-guidelines)
10. [Navigation & Back Button (สำคัญ!)](#10-navigation--back-button-สำคัญ)

---

## 1. เตรียม Development Environment

### ความต้องการ
- **macOS**: จำเป็น! ไม่สามารถ build iOS บน Windows ได้
- **Xcode**: เวอร์ชันล่าสุด (14.0+)
- **Flutter**: เวอร์ชันปัจจุบันของโปรเจกต์
- **CocoaPods**: สำหรับจัดการ dependencies

### ติดตั้ง Tools

```bash
# ติดตั้ง Xcode จาก Mac App Store
# หรือดาวน์โหลดจาก https://developer.apple.com/xcode/

# ติดตั้ง Command Line Tools
xcode-select --install

# ติดตั้ง CocoaPods
sudo gem install cocoapods

# ตรวจสอบ Flutter
flutter doctor
```

---

## 2. Apple Developer Account

### ขั้นตอนการสมัคร

1. **เข้าไปที่**: https://developer.apple.com/programs/
2. **สมัครสมาชิก**: Apple Developer Program
3. **ค่าใช้จ่าย**: $99 USD ต่อปี (ต่ออายุทุกปี)
4. **ระยะเวลาอนุมัติ**: 1-2 วันทำการ

### ประเภทบัญชี
- **Individual**: บุคคลธรรมดา (แนะนำสำหรับ indie developer)
- **Organization**: นิติบุคคล/บริษัท

### เอกสารที่ต้องเตรียม
- Apple ID
- บัตรเครดิต/เดบิต
- ข้อมูลติดต่อ
- DUNS Number (สำหรับ Organization)

---

## 3. สร้าง iOS Project Configuration

### Step 1: สร้าง iOS folder
```bash
# บน Mac, ใน project root
flutter create . --platforms=ios
```

### Step 2: เปิด Xcode
```bash
open ios/Runner.xcworkspace
```

### Step 3: กำหนด Bundle ID และ Team

1. เลือก **Runner** project ใน Navigator
2. เลือก **Runner** target
3. ไปที่ tab **Signing & Capabilities**
4. เลือก **Team**: เลือก Apple Developer Team ของคุณ
5. กำหนด **Bundle Identifier**: 
   - แนะนำ: `com.yourcompany.miro` 
   - ต้องไม่ซ้ำกับแอปอื่นใน App Store
   - จดไว้! จะต้องใช้ตลอด

### Step 4: Update Version
```bash
# ใน pubspec.yaml มี
version: 1.1.5+30
# 1.1.5 = Version Name
# 30 = Build Number

# สำหรับ iOS ครั้งแรก อาจเริ่ม
version: 1.0.0+1
```

---

## 4. กำหนด Permissions และ Capabilities

### Edit Info.plist

เปิดไฟล์: `ios/Runner/Info.plist`

เพิ่ม permissions ที่จำเป็น:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Display Name -->
    <key>CFBundleDisplayName</key>
    <string>Miro</string>
    
    <!-- Camera Permission -->
    <key>NSCameraUsageDescription</key>
    <string>เราต้องการเข้าถึงกล้องเพื่อถ่ายภาพอาหารและสแกนบาร์โค้ดสำหรับวิเคราะห์โภชนาการ</string>
    
    <!-- Photo Library Permission -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>เราต้องการเข้าถึงคลังภาพเพื่อให้คุณเลือกรูปอาหารสำหรับวิเคราะห์โภชนาการ</string>
    
    <key>NSPhotoLibraryAddUsageDescription</key>
    <string>เราต้องการบันทึกภาพอาหารของคุณลงในคลังภาพ</string>
    
    <!-- File Access (for backup/restore) -->
    <key>UIFileSharingEnabled</key>
    <true/>
    <key>LSSupportsOpeningDocumentsInPlace</key>
    <true/>
    
    <!-- Network Usage (for Gemini API) -->
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <false/>
    </dict>
    
    <!-- Device Orientation -->
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <key>UIInterfaceOrientationPortrait</key>
        <key>UIInterfaceOrientationPortraitUpsideDown</key>
    </array>
    
    <!-- Firebase -->
    <key>FirebaseAppDelegateProxyEnabled</key>
    <false/>
</dict>
</plist>
```

### เพิ่ม Capabilities ใน Xcode

1. เปิด **Signing & Capabilities** tab
2. คลิก **+ Capability**
3. เพิ่ม:
   - ✅ **In-App Purchase** (สำคัญมาก!)
   - ✅ **Push Notifications** (สำหรับ Firebase)
   - ✅ **Background Modes** > Remote notifications

---

## 5. In-App Purchase Setup

### Step 1: App Store Connect - App สร้าง

1. เข้า: https://appstoreconnect.apple.com/
2. ไปที่ **My Apps** > **+** > **New App**
3. กรอกข้อมูล:
   - **Platform**: iOS
   - **Name**: Miro
   - **Primary Language**: Thai (ภาษาไทย)
   - **Bundle ID**: เลือก Bundle ID ที่สร้างไว้
   - **SKU**: `miro-ios-001` (unique ID ใดก็ได้)

### Step 2: สร้าง In-App Purchase Products

1. ใน App Store Connect > เลือก App
2. ไปที่ **In-App Purchases**
3. สร้างสินค้าตาม Android IAP ที่มีอยู่:

#### Consumable Products (Energy Packs):
```
Product ID: energy_starter_pack
Reference Name: Energy Starter Pack (50 Energy)
Price: 39 THB

Product ID: energy_value_pack
Reference Name: Energy Value Pack (120 Energy)
Price: 99 THB

Product ID: energy_premium_pack
Reference Name: Energy Premium Pack (280 Energy)
Price: 199 THB

Product ID: energy_ultimate_pack
Reference Name: Energy Ultimate Pack (600 Energy)
Price: 399 THB
```

#### Non-Consumable Products (Subscriptions):
```
Product ID: premium_monthly
Reference Name: Premium Monthly Subscription
Price: 99 THB/month

Product ID: premium_yearly
Reference Name: Premium Yearly Subscription
Price: 990 THB/year
```

### Step 3: ตรวจสอบ Code IAP

ดูที่: `lib/core/services/welcome_offer_service.dart` และ payment providers
- ตรวจสอบว่า Product IDs ตรงกันทั้ง Android และ iOS

---

## 6. Build และ Test

### Build ครั้งแรก

```bash
# บน Mac
cd /path/to/miro

# Get dependencies
flutter pub get
cd ios
pod install
cd ..

# Build iOS
flutter build ios --release
```

### Test บน Simulator

```bash
# ดู simulators ที่มี
xcrun simctl list devices available

# Run บน simulator
flutter run -d "iPhone 14 Pro"
```

### Test บนเครื่องจริง (Real Device)

1. เชื่อมต่อ iPhone/iPad ผ่าน USB
2. เปิด Xcode > Window > Devices and Simulators
3. Trust device
4. Run: `flutter run -d [device-id]`

### Test In-App Purchase (Sandbox)

1. **Sandbox Tester Account**:
   - App Store Connect > Users and Access > Sandbox Testers
   - สร้าง test account
   
2. **บน iPhone**:
   - Settings > App Store > Sandbox Account
   - Login ด้วย sandbox account
   
3. **Test การซื้อ**:
   - Run app และทดสอบซื้อ energy/subscription
   - จะไม่มีการชาร์จเงินจริง

---

## 7. Prepare for App Store

### App Icons & Screenshots

#### Icons
```bash
# สร้าง icons อัตโนมัติ
flutter pub run flutter_launcher_icons
```

ตรวจสอบว่ามี icons ครบใน: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

#### Screenshots ที่ต้องเตรียม
- **iPhone 6.7"** (iPhone 14 Pro Max): 1290 x 2796 px (3-10 ภาพ)
- **iPhone 6.5"** (iPhone 11 Pro Max): 1242 x 2688 px
- **iPhone 5.5"** (iPhone 8 Plus): 1242 x 2208 px
- **iPad Pro 12.9"**: 2048 x 2732 px (ถ้าสนับสนุน iPad)

### App Preview Video (Optional)
- 15-30 วินาที
- แสดงฟีเจอร์หลัก
- ไฟล์ .mov หรือ .mp4

### App Information

เตรียมข้อมูลต่อไปนี้ (ภาษาไทย + อังกฤษ):

1. **App Name**: Miro - Hybrid Life Assistant
2. **Subtitle**: ผู้ช่วยชีวิตออฟไลน์ที่ใช้ AI
3. **Description** (4000 ตัวอักษรได้):
```
Miro คือแอปพลิเคชันผู้ช่วยชีวิตแบบ Hybrid ที่ทำงานทั้งออนไลน์และออฟไลน์ 
ช่วยคุณติดตามสุขภาพ โภชนาการ และจัดการชีวิตประจำวันได้อย่างมีประสิทธิภาพ

✨ ฟีเจอร์เด่น:
• 📸 วิเคราะห์อาหารด้วย AI - แค่ถ่ายรูปก็รู้แคลอรี่
• 🥗 ฐานข้อมูลอาหารไทย - ครบครัน แม่นยำ
• 💪 ติดตามโภชนาการ - โปรตีน คาร์บ ไขมัน
• 🔍 สแกนบาร์โค้ด - รู้ข้อมูลโภชนาการทันที
• 📊 สถิติและกราฟ - เห็นภาพรวมสุขภาพของคุณ
• 🎮 Gamification - สะสม Energy, สร้าง Streak
• 💾 ทำงานออฟไลน์ - ไม่ต้องพึ่งอินเทอร์เน็ต
• 🔒 ปลอดภัย - ข้อมูลเก็บในเครื่อง

💎 Premium Features:
• วิเคราะห์อาหารไม่จำกัด
• รายงานสุขภาพแบบละเอียด
• ไม่มีโฆษณา
• แผนอาหารแบบ custom

เหมาะสำหรับ:
- คนรักสุขภาพ
- นักออกกำลังกาย
- ผู้ควบคุมน้ำหนัก
- ผู้ที่ใส่ใจโภชนาการ
```

4. **Keywords**: 
   - อาหาร, โภชนาการ, แคลอรี่, สุขภาพ, ฟิตเนส, ลดน้ำหนัก, AI, ออฟไลน์
   - food, nutrition, calorie, health, fitness, diet, tracker, AI

5. **Support URL**: เว็บไซต์หรือ email support
6. **Privacy Policy URL**: จำเป็น! (ดูในโปรเจกต์: `_project_manager/.../35_LEGAL_PRIVACY_POLICY.md`)

### Age Rating
- **4+** หรือ **9+** (ปลอดภัยสำหรับทุกเพศทุกวัย)

---

## 8. Submit to App Store

### Step 1: Archive Build

```bash
# สร้าง release build
flutter build ios --release

# หรือใช้ Xcode
# Product > Archive
```

### Step 2: Upload to App Store Connect

**ใช้ Xcode:**
1. Product > Archive
2. เมื่อ archive เสร็จ จะเปิด Organizer
3. เลือก archive ล่าสุด
4. คลิก **Distribute App**
5. เลือก **App Store Connect**
6. เลือก **Upload**
7. Follow ขั้นตอน รอ processing (5-15 นาที)

**หรือใช้ Command Line:**
```bash
# ใช้ altool หรือ Transporter app
xcrun altool --upload-app -f Runner.ipa -u your@email.com -p app-specific-password
```

### Step 3: เตรียม App Store Listing

1. เข้า **App Store Connect**
2. เลือก App > **App Store** tab
3. เลือก **1.0 Prepare for Submission**
4. กรอกข้อมูลทั้งหมด:
   - Screenshots (บังคับ)
   - Description
   - Keywords
   - Support URL
   - Privacy Policy URL
   - App Category: **Health & Fitness**
   - Age Rating

### Step 4: Submit for Review

1. เลือก build ที่ upload แล้ว
2. ตอบคำถาม:
   - Does your app use encryption? → Usually **NO** (เว้นแต่มี custom encryption)
   - Advertising Identifier (IDFA) → **NO** (ถ้าไม่ได้ใช้)
3. กด **Submit for Review**

### ระยะเวลา Review
- โดยเฉลี่ย: **24-48 ชั่วโมง**
- อาจนานถึง: **1 สัปดาห์**
- สามารถติดตามได้ใน App Store Connect

---

## 9. App Review Guidelines

### สิ่งที่ Apple ตรวจสอบ

#### ✅ จะผ่าน:
- ฟีเจอร์ทำงานถูกต้อง ไม่มี crash
- UI/UX ใช้งานง่าย ตามหลัก Human Interface Guidelines
- Privacy policy ชัดเจน
- Permissions มีคำอธิบายที่ดี
- In-App Purchase ทำงานถูกต้อง

#### ❌ อาจไม่ผ่าน:
- แอป crash บ่อย
- Missing privacy policy
- Permissions ไม่มีเหตุผล
- In-App Purchase ไม่ทำงาน
- มี content ที่ไม่เหมาะสม
- ละเมิด copyright

### Tips เพื่อผ่าน Review:

1. **Test ให้ดี**: อย่า submit แอปที่ยัง buggy
2. **Screenshot ชัดเจน**: แสดงฟีเจอร์หลักๆ
3. **Description ตรงกับแอป**: อย่าโอ้อวดเกินจริง
4. **Demo Account**: ถ้าต้อง login, ให้ test account กับ reviewer
5. **App Review Notes**: อธิบายฟีเจอร์พิเศษให้ reviewer เข้าใจ

### ถ้า Reject:

1. อ่าน rejection reason ให้ดี
2. แก้ไขตามที่ระบุ
3. Submit ใหม่ (ไม่เสียเงินเพิ่ม)
4. ติดต่อ App Review Team ถ้าไม่เข้าใจ

---

## 10. Navigation & Back Button (สำคัญ!)

### iOS Human Interface Guidelines: Navigation

Apple มีหลักการที่ **แตกต่างจาก Android**:

#### ✅ iOS Best Practices:

1. **Navigation Bar กับ Back Button**:
   ```dart
   // ใช้ AppBar หรือ CupertinoNavigationBar
   CupertinoNavigationBar(
     leading: CupertinoNavigationBarBackButton(
       onPressed: () => Navigator.pop(context),
     ),
     middle: Text('Page Title'),
   )
   ```

2. **Swipe to Go Back** (สำคัญมาก!):
   - iOS users คาดหวัง swipe จากขอบซ้ายเพื่อกลับ
   - Flutter รองรับโดยอัตโนมัติด้วย `CupertinoPageRoute`
   ```dart
   // ใช้ Material + Cupertino hybrid
   MaterialApp(
     theme: ThemeData(
       pageTransitionsTheme: PageTransitionsTheme(
         builders: {
           TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
         },
       ),
     ),
   )
   ```

3. **Modal vs Push**:
   - Modal sheets: swipe ลงเพื่อปิด
   - Full screen: back button บนซ้าย
   ```dart
   // Modal presentation
   showCupertinoModalPopup(
     context: context,
     builder: (context) => YourSheet(),
   );
   ```

4. **Tab Bar Navigation**:
   ```dart
   CupertinoTabScaffold(
     tabBar: CupertinoTabBar(
       items: [/* tabs */],
     ),
     tabBuilder: (context, index) {
       return CupertinoTabView(
         builder: (context) => YourPage(),
       );
     },
   )
   ```

#### ❌ สิ่งที่ควรหลีกเลี่ยง:

1. **Android-style hardware back button**: 
   - iOS ไม่มี hardware back button!
   - ห้ามคาดหวังให้ user กด physical button

2. **Drawer Navigation** (Hamburger Menu):
   - ไม่เป็น iOS pattern
   - ใช้ Tab Bar แทน

3. **Floating Action Button** (FAB):
   - ไม่ค่อย iOS-like
   - ใช้ Navigation Bar buttons แทน

### การทำให้แอปรองรับทั้ง Android และ iOS:

```dart
import 'dart:io';

// ตรวจสอบ platform
if (Platform.isIOS) {
  // ใช้ Cupertino widgets
  return CupertinoPageScaffold(
    navigationBar: CupertinoNavigationBar(/* ... */),
    child: /* ... */,
  );
} else {
  // ใช้ Material widgets
  return Scaffold(
    appBar: AppBar(/* ... */),
    body: /* ... */,
  );
}
```

### ตรวจสอบใน Codebase:

ผมจะตรวจสอบว่า navigation ในแอปปัจจุบันเป็น iOS-friendly หรือไม่:

```bash
# ค้นหาการใช้ Scaffold
grep -r "Scaffold(" lib/ | wc -l

# ค้นหาการใช้ AppBar
grep -r "AppBar(" lib/ | wc -l

# ค้นหาการใช้ Drawer
grep -r "Drawer(" lib/ | wc -l
```

### Recommendation:

**สำหรับแอป Miro:**

เนื่องจากเป็นแอป Material Design อยู่แล้ว ไม่จำเป็นต้องเปลี่ยนเป็น Cupertino ทั้งหมด แต่ควร:

1. ✅ **ใช้ Material Theme** แต่ enable iOS page transitions
2. ✅ **AppBar with automatic back button** - Flutter จะใส่ให้อัตโนมัติ
3. ✅ **Support swipe-to-go-back** - ได้ฟรีกับ MaterialPageRoute
4. ⚠️ **หลีกเลี่ยง WillPopScope** ที่ block การ swipe back
5. ⚠️ **ทดสอบทุก flow** ว่ากดกลับได้ตลอด

### Code Example ที่ควรใช้:

```dart
// main.dart - Enable iOS transitions
MaterialApp(
  theme: ThemeData(
    platform: TargetPlatform.iOS, // เมื่อรันบน iOS
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
  ),
  // ...
)

// การ navigate ปกติ - รองรับ swipe back อัตโนมัติ
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => NextPage()),
);

// AppBar จะมี back button อัตโนมัติ
Scaffold(
  appBar: AppBar(
    title: Text('Page Title'),
    // ไม่ต้องใส่ leading: BackButton() - จะใส่ให้เอง
  ),
  body: YourContent(),
)
```

---

## 📊 Checklist ก่อน Submit

### Development
- [ ] สร้าง iOS project (`flutter create . --platforms=ios`)
- [ ] กำหนด Bundle ID และ Team ใน Xcode
- [ ] อัปเดต Info.plist กับ permissions
- [ ] เพิ่ม Capabilities (In-App Purchase, Push Notifications)
- [ ] Test บน Simulator
- [ ] Test บนเครื่องจริง
- [ ] Test In-App Purchase (Sandbox)

### App Store Connect
- [ ] สร้าง App ใน App Store Connect
- [ ] สร้าง In-App Purchase products
- [ ] เตรียม Screenshots (3-10 ภาพต่อขนาดหน้าจอ)
- [ ] เขียน Description (ไทย + อังกฤษ)
- [ ] เตรียม Privacy Policy URL
- [ ] เตรียม Support URL/Email
- [ ] กำหนด Age Rating

### Build & Upload
- [ ] Build release: `flutter build ios --release`
- [ ] Archive ใน Xcode
- [ ] Upload to App Store Connect
- [ ] เลือก build ใน App Store Connect
- [ ] Submit for Review

### Post-Launch
- [ ] Monitor App Review status
- [ ] ตอบกลับ reviewer (ถ้ามีคำถาม)
- [ ] Release เมื่อ Approved
- [ ] Monitor crash reports
- [ ] อัปเดตแอปเป็นระยะ

---

## 🆘 การแก้ไข Common Issues

### Issue 1: "No eligible devices found"
```bash
# แก้: เปิด Xcode > Preferences > Accounts > Download Manual Profiles
```

### Issue 2: CocoaPods error
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
```

### Issue 3: Build failed - Signing error
- ตรวจสอบว่า Team ถูกเลือกใน Xcode
- ตรวจสอบ Bundle ID ไม่ซ้ำ
- ลอง Xcode > Product > Clean Build Folder

### Issue 4: Firebase not working
```bash
# Download GoogleService-Info.plist from Firebase Console
# ใส่ใน ios/Runner/
# เพิ่มใน Xcode project
```

### Issue 5: In-App Purchase not working
- ตรวจสอบ Capability เปิดไว้
- ตรวจสอบ Product IDs ตรงกัน
- Login Sandbox Account บนเครื่อง test
- รอ 24 ชม. หลังสร้าง products ใหม่

---

## 📚 Resources

### Official Documentation
- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/ios)
- [In-App Purchase](https://developer.apple.com/in-app-purchase/)

### Tools
- [App Store Connect](https://appstoreconnect.apple.com/)
- [Apple Developer Portal](https://developer.apple.com/)
- [Transporter App](https://apps.apple.com/app/transporter/id1450874784) - Upload builds

### Communities
- [Flutter Discord](https://discord.gg/flutter)
- [Stack Overflow - Flutter iOS](https://stackoverflow.com/questions/tagged/flutter+ios)

---

## ✅ Summary

การ deploy iOS แอปมีความซับซ้อนกว่า Android เล็กน้อย แต่ก็ไม่ยาก:

1. **ต้องมี Mac** - ไม่มีทางอื่น
2. **ต้องจ่าย $99/ปี** - Apple Developer Program
3. **Review ใช้เวลา 1-2 วัน** - เร็วกว่า Android
4. **การ navigate ต่างกัน** - แต่ไม่ต้องกังวล Flutter รองรับดี

### เรื่อง Back Button:
- **iOS ใช้ swipe** มากกว่าปุ่มกด
- **Flutter รองรับอัตโนมัติ** ไม่ต้องแก้อะไรมาก
- **ทดสอบให้ดี** ว่าทุกหน้ากลับได้

**Good luck! 🚀**
