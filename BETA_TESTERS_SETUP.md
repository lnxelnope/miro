# 🌟 Beta Testers — Setup Guide

> **เป้าหมาย:** มอบ 1,000 Energy ฟรีให้ beta testers ที่ช่วยทดสอบแอปก่อนเปิดตัว

---

## 📋 Step-by-Step Guide

### Step 1: รวบรวมรายชื่อ Beta Testers

#### วิธีที่ 1: จาก Google Play Console
```bash
# ไปที่: Google Play Console → Your App → Testing → Internal testing
# หรือ: Testing → Closed testing
# 
# Copy รายชื่อ email ทั้งหมด
```

#### วิธีที่ 2: จาก Firebase
```bash
# ไปที่: Firebase Console → Authentication → Users
# Filter by: Sign-up date < Launch date
# Export to CSV → ดึง email column
```

#### วิธีที่ 3: จาก Google Form / Survey
```bash
# ถ้าเคยให้ testers กรอก Google Form
# Download responses → ดึง email column
```

---

### Step 2: สร้างไฟล์ Beta Testers List

สร้างไฟล์ `lib/core/config/beta_testers.dart`:

```dart
/// Configuration สำหรับระบุ Beta Testers
class BetaTesters {
  /// รายชื่อ email ของ beta testers ทั้งหมด
  /// 
  /// ⚠️ ต้องเป็น email ที่ใช้ Sign in เข้าแอป (Firebase Auth email)
  static const List<String> emails = [
    // ────── Internal Team ──────
    'john@yourcompany.com',
    'jane@yourcompany.com',
    'dev@yourcompany.com',
    
    // ────── External Beta Testers ──────
    'tester1@gmail.com',
    'tester2@hotmail.com',
    'beta.user@example.com',
    
    // TODO: เพิ่มรายชื่อทั้งหมดตรงนี้
    // แนะนำ: เรียงตามกลุ่มหรือตาม alphabetical order
  ];
  
  /// ตรวจสอบว่า email นี้เป็น beta tester หรือไม่
  static bool isBetaTester(String? email) {
    if (email == null || email.isEmpty) return false;
    
    final normalizedEmail = email.trim().toLowerCase();
    return emails.any((e) => e.toLowerCase() == normalizedEmail);
  }
  
  /// Debug: แสดงสถานะของ user
  static void printStatus(String? userEmail) {
    if (isBetaTester(userEmail)) {
      print('🌟 Beta Tester: $userEmail');
    } else {
      print('👤 Regular User: $userEmail');
    }
  }
  
  /// ดึงจำนวน beta testers ทั้งหมด
  static int get totalCount => emails.length;
}
```

---

### Step 3: Update Migration Code

เปิด `lib/main.dart` (หรือที่ที่ initialize app):

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:miro/core/config/beta_testers.dart';
import 'package:miro/core/services/energy_service.dart';

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ... Firebase, Isar initialization ...
  
  final energyService = EnergyService(isar);
  
  // ────── Migrate Existing Users ──────
  await _migrateExistingUsers(energyService);
  
  runApp(MyApp());
}

/// Migration สำหรับ existing users
Future<void> _migrateExistingUsers(EnergyService energyService) async {
  // ตรวจสอบว่า migrate แล้วหรือยัง
  final prefs = await SharedPreferences.getInstance();
  final alreadyMigrated = prefs.getBool('energy_migration_done') ?? false;
  
  if (alreadyMigrated) {
    print('✅ Already migrated to Energy system');
    return;
  }
  
  // ────── ดึงข้อมูล User ──────
  final user = FirebaseAuth.instance.currentUser;
  
  if (user == null) {
    print('⚠️ No user signed in, skip migration');
    return;
  }
  
  final userEmail = user.email;
  print('📧 User email: $userEmail');
  
  // ────── ตรวจสอบว่าเป็น Beta Tester หรือไม่ ──────
  final isBetaTester = BetaTesters.isBetaTester(userEmail);
  BetaTesters.printStatus(userEmail);
  
  // ────── ตรวจสอบว่าเคยเป็น Pro User หรือไม่ ──────
  final wasProUser = await _checkIfWasProUser();
  
  // ────── Migrate! ──────
  try {
    await energyService.migrateFromProSystem(
      wasProUser: wasProUser,
      isBetaTester: isBetaTester,
    );
    
    // ทำเครื่องหมายว่า migrate แล้ว
    await prefs.setBool('energy_migration_done', true);
    print('✅ Migration completed!');
    
    // แสดง notification ให้ user รู้ว่าได้ Energy ฟรี
    if (isBetaTester) {
      _showBetaTesterRewardNotification();
    }
    
  } catch (e) {
    print('❌ Migration error: $e');
  }
}

/// ตรวจสอบว่าเคยเป็น Pro user หรือไม่
Future<bool> _checkIfWasProUser() async {
  // วิธีที่ 1: Check จาก SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final wasProFlag = prefs.getBool('was_pro_user');
  if (wasProFlag != null) return wasProFlag;
  
  // วิธีที่ 2: Check จาก purchase history
  // TODO: ถ้ามีระบบ Pro เก่า → ตรวจสอบจาก Google Play purchase history
  
  return false; // default: ไม่ใช่ Pro
}

/// แสดง notification ให้ beta tester ทราบ
void _showBetaTesterRewardNotification() {
  // TODO: แสดง dialog หรือ snackbar
  // "🌟 Thank you for being a beta tester! You've received 1,000 free Energy!"
}
```

---

### Step 4: Testing

#### Test Case 1: Beta Tester Email
```dart
// สร้าง test account ที่มี email ใน beta_testers.dart
// ลง app → sign in
// ควรเห็น:
// 🌟 Beta Tester: test@example.com
// ✅ Beta tester migrated: 1,000 Energy

// ตรวจสอบ:
final balance = await energyService.getBalance();
print(balance); // Should be 1000
```

#### Test Case 2: Regular User
```dart
// สร้าง account ที่ไม่อยู่ใน list
// ลง app → sign in
// ควรเห็น:
// 👤 Regular User: other@example.com
// ✅ Free user migrated: 100 Energy

// ตรวจสอบ:
final balance = await energyService.getBalance();
print(balance); // Should be 100
```

#### Test Case 3: Pro User (not beta tester)
```dart
// Account ที่เคยซื้อ Pro แต่ไม่ใช่ beta tester
// ควรได้ 2,000 Energy (ไม่ใช่ 1,000)
```

#### Test Case 4: Pro User + Beta Tester
```dart
// Account ที่ทั้ง Pro และเป็น beta tester
// ควรได้ 1,000 Energy (beta tester bonus)
// หรือถ้าต้องการให้ได้ทั้งสอง → แก้ logic ใน migrateFromProSystem()
```

---

### Step 5: Deploy

#### 5.1 ตรวจสอบรายชื่อครั้งสุดท้าย
```bash
# เปิด lib/core/config/beta_testers.dart
# ตรวจสอบว่า:
# - ไม่มี email ผิด (typo)
# - ไม่มี duplicate
# - เรียงลำดับให้เป็นระเบียบ
```

#### 5.2 Build & Upload
```bash
flutter build appbundle --release
# Upload to Google Play Console
```

#### 5.3 Monitor
```bash
# หลังจากผู้ใช้ update → ตรวจสอบ logs
# ดูว่ามี beta testers กี่คนที่ได้รับ reward
# ดูจาก Firebase Analytics หรือ Crashlytics
```

---

## 🔐 Alternative: Firebase Remote Config (Advanced)

ถ้าไม่อยาก hardcode email ในแอป → ใช้ Firebase Remote Config:

### Setup
```dart
// 1. สร้าง parameter ใน Firebase Console:
//    Key: beta_tester_emails
//    Value: ["email1@gmail.com","email2@gmail.com"]

// 2. แก้โค้ด:
class BetaTesters {
  static List<String>? _remoteEmails;
  
  static Future<void> initialize() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.fetchAndActivate();
    
    final jsonString = remoteConfig.getString('beta_tester_emails');
    if (jsonString.isNotEmpty) {
      _remoteEmails = List<String>.from(json.decode(jsonString));
    }
  }
  
  static bool isBetaTester(String? email) {
    if (email == null || email.isEmpty) return false;
    
    final emailList = _remoteEmails ?? emails; // fallback to hardcoded
    final normalized = email.trim().toLowerCase();
    return emailList.any((e) => e.toLowerCase() == normalized);
  }
  
  // ... rest of code ...
}
```

**ข้อดี:**
- เปลี่ยน list ได้โดยไม่ต้อง update app
- ไม่มี email ใน source code

**ข้อเสีย:**
- ซับซ้อนกว่า
- ต้อง fetch remote config ก่อนใช้

---

## 📊 Analytics (Optional)

Track beta tester metrics:

```dart
// หลังจาก migration
if (isBetaTester) {
  await FirebaseAnalytics.instance.logEvent(
    name: 'beta_tester_migrated',
    parameters: {
      'email_hash': sha256.convert(utf8.encode(userEmail)).toString(),
      'energy_granted': 1000,
    },
  );
}
```

---

## ❓ FAQ

### Q: ถ้า beta tester ไม่ได้ Sign In ด้วย email ที่ใช้ทดสอบ?
**A:** จะไม่ได้รับ 1,000 Energy (ได้แค่ 100 เหมือนคนทั่วไป)  
→ แนะนำให้แจ้ง beta testers ล่วงหน้าว่าต้องใช้ email เดิม

### Q: ถ้าต้องการเพิ่ม beta tester ภายหลัง?
**A:** 
1. เพิ่ม email ใน `beta_testers.dart`
2. Build version ใหม่
3. User ที่ยังไม่ migrate จะได้ 1,000 Energy

### Q: ถ้าต้องการให้ Pro user ที่เป็น beta tester ได้ทั้ง 2,000 + 1,000?
**A:** แก้ logic ใน `migrateFromProSystem()`:
```dart
if (isBetaTester && wasProUser) {
  // ได้ทั้งสองอัน
  await addEnergy(2000, type: 'pro_migration', ...);
  await addEnergy(1000, type: 'beta_tester_reward', ...);
} else if (isBetaTester) {
  // ได้แค่ beta reward
  await addEnergy(1000, type: 'beta_tester_reward', ...);
} else if (wasProUser) {
  // ได้แค่ pro reward
  await addEnergy(2000, type: 'pro_migration', ...);
}
```

---

## ✅ Checklist

- [ ] รวบรวมรายชื่อ beta testers ครบทุกคน
- [ ] สร้างไฟล์ `beta_testers.dart`
- [ ] เพิ่ม email ทั้งหมดลงในไฟล์
- [ ] ตรวจสอบ typo และ duplicates
- [ ] Update migration code ใน `main.dart`
- [ ] Test กับ beta tester account
- [ ] Test กับ regular account
- [ ] Deploy to production
- [ ] Monitor logs หลัง deploy
- [ ] แจ้ง beta testers ว่าได้รับ reward แล้ว

---

**Done!** Beta testers จะได้รับ 1,000 Energy ฟรีเมื่อ update แอป 🎉
