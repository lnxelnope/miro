# 🎁 Beta Tester Migration Guide

> **Purpose:** สคริปต์สำหรับมอบ 1,000 Energy ฟรีให้กับ beta testers  
> **Reward:** 1,000 Energy (~285 AI analyses, ~$0.35 cost)

---

## วิธีระบุ Beta Tester

### Option A: ใช้ Install Date (แนะนำ — ง่ายที่สุด)

```dart
/// ตรวจสอบว่าเป็น beta tester หรือไม่
/// Beta tester = ติดตั้งแอปก่อนวันที่ launch
Future<bool> isBetaTester() async {
  const launchDate = DateTime(2026, 2, 28); // TODO: เปลี่ยนเป็นวันที่ launch จริง
  
  final prefs = await SharedPreferences.getInstance();
  
  // ตรวจสอบว่าเคยบันทึกวันติดตั้งหรือยัง
  final installDateMs = prefs.getInt('first_install_date');
  
  if (installDateMs == null) {
    // ครั้งแรกที่เปิดแอป → บันทึกวันนี้
    await prefs.setInt('first_install_date', DateTime.now().millisecondsSinceEpoch);
    return false; // ติดตั้งใหม่ = ไม่ใช่ beta tester
  }
  
  final installDate = DateTime.fromMillisecondsSinceEpoch(installDateMs);
  return installDate.isBefore(launchDate);
}
```

**ข้อดี:**
- ไม่ต้อง maintain list
- ทำงานอัตโนมัติ

**ข้อเสีย:**
- ผู้ใช้ที่ลง fresh install หลัง launch จะไม่ได้สิทธิ์
- ต้องบันทึก install date ตั้งแต่วันนี้

---

### Option B: ใช้ Firestore/Supabase Flag

```dart
/// ตรวจสอบจาก database
Future<bool> isBetaTester() async {
  final deviceId = await DeviceIdService.getDeviceId();
  
  // Query Firestore/Supabase
  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(deviceId)
      .get();
  
  if (!doc.exists) return false;
  
  final data = doc.data()!;
  return data['is_beta_tester'] == true;
}
```

**ข้อดี:**
- ควบคุมได้แม่นยำว่าใครได้ใครไม่ได้
- สามารถเพิ่ม/ลบ beta tester ได้ทีหลัง

**ข้อเสีย:**
- ต้อง maintain database
- ต้อง manual import list

---

### Option C: ใช้ Manual List (Email/Device ID)

```dart
/// Hard-coded list (สำหรับ beta tester น้อยๆ < 50 คน)
Future<bool> isBetaTester() async {
  final deviceId = await DeviceIdService.getDeviceId();
  
  const betaTesterDeviceIds = [
    'abc123...',
    'def456...',
    // ... add more ...
  ];
  
  return betaTesterDeviceIds.contains(deviceId);
}
```

**ข้อดี:**
- ง่ายมาก ไม่ต้องใช้ database

**ข้อเสีย:**
- ต้อง hard-code device IDs
- ต้อง update แอปถ้าต้องการเพิ่ม/ลบ

---

## การ Migrate

### Step 1: เพิ่มโค้ดใน `main.dart`

```dart
Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ... existing initialization ...
  
  final isar = await Isar.open([EnergyTransactionSchema]);
  final energyService = EnergyService(isar);
  
  // ────── Check if beta tester ──────
  final isBeta = await isBetaTester();
  
  // ────── Welcome Gift (100 Energy) ──────
  final receivedGift = await energyService.initializeWelcomeGift();
  if (receivedGift) {
    print('🎁 Welcome Gift: 100 Energy');
  }
  
  // ────── Beta Tester Bonus (1,000 Energy) ──────
  if (isBeta) {
    await migrateBetaTester(energyService);
  }
  
  runApp(MyApp());
}

/// Migrate beta tester → +1,000 Energy
Future<void> migrateBetaTester(EnergyService energyService) async {
  final prefs = await SharedPreferences.getInstance();
  final deviceId = await DeviceIdService.getDeviceId();
  final key = 'beta_tester_migrated_$deviceId';
  
  // ตรวจสอบว่า migrate แล้วหรือยัง
  if (prefs.getBool(key) == true) {
    print('✅ Beta tester already migrated');
    return;
  }
  
  // มอบรางวัล!
  await energyService.addEnergy(
    1000,
    type: 'beta_tester_reward',
    description: 'Thank you for being a beta tester! 🙏💙',
  );
  
  // บันทึกว่า migrate แล้ว (ไม่ให้ได้ซ้ำ)
  await prefs.setBool(key, true);
  
  print('🎁 Beta Tester Reward: 1,000 Energy!');
  
  // แสดง popup (optional)
  // showBetaTesterThankYouDialog();
}
```

---

### Step 2: แสดง Thank You Dialog (Optional)

```dart
/// แสดง popup ขอบคุณ beta tester
class BetaTesterThankYouDialog extends StatelessWidget {
  const BetaTesterThankYouDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Text('🎁', style: TextStyle(fontSize: 32)),
          SizedBox(width: 12),
          Expanded(child: Text('Thank You!')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ขอบคุณที่ช่วยเราทดสอบแอป MIRO! 🙏',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            'คุณได้รับ 1,000 Energy ฟรี เป็นของขวัญพิเศษจากเรา 💙',
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('⚡', style: TextStyle(fontSize: 32)),
                SizedBox(width: 12),
                Text(
                  '+1,000 Energy',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Text(
            '✨ ~285 AI analyses',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          ),
          child: Text('เริ่มใช้งานเลย! 🚀', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
  
  /// แสดง dialog
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false, // ต้องกดปุ่มถึงจะปิดได้
      builder: (_) => BetaTesterThankYouDialog(),
    );
  }
}
```

**วิธีใช้:**
```dart
// ใน main.dart หรือ home_screen.dart
if (isBeta && !hasShownThankYou) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    BetaTesterThankYouDialog.show(context);
  });
}
```

---

## Testing

### ทดสอบว่า Beta Tester Detection ทำงาน

```dart
// ใน developer settings หรือ debug console
void testBetaTesterDetection() async {
  final isBeta = await isBetaTester();
  print('Is Beta Tester: $isBeta');
  
  if (isBeta) {
    print('✅ Should receive 1,000 Energy');
  } else {
    print('❌ Not a beta tester, no bonus');
  }
}
```

### Force Reset (สำหรับทดสอบ)

```dart
// ลบ flag เพื่อทดสอบซ้ำ
Future<void> resetBetaTesterMigration() async {
  final prefs = await SharedPreferences.getInstance();
  final deviceId = await DeviceIdService.getDeviceId();
  await prefs.remove('beta_tester_migrated_$deviceId');
  print('🔄 Reset beta tester migration flag');
}
```

---

## Timeline

| Step | Timeline |
|------|----------|
| เพิ่มโค้ด detection | Day 1 |
| ทดสอบกับ beta tester list | Day 1-2 |
| Deploy update | Day 3 |
| Monitor ว่า beta tester ได้รับ reward | Week 1 |

---

## FAQ

**Q: ถ้า beta tester ลบแอปแล้วลงใหม่ จะได้ 1,000 Energy อีกไหม?**  
A: ไม่ได้ เพราะเราใช้ Device ID binding (เหมือน welcome gift)

**Q: ถ้า beta tester ไม่ได้ 1,000 Energy ต้องทำยังไง?**  
A: สร้างฟังก์ชัน manual grant:
```dart
Future<void> manualGrantBetaReward(String deviceId) async {
  // Admin only — grant reward manually
  await energyService.addEnergy(
    1000,
    type: 'beta_tester_manual',
    description: 'Manual grant by admin',
  );
}
```

**Q: 1,000 Energy = เท่าไหร่?**  
- Cost to us: ~$0.35
- AI analyses: ~285 times (if 100% image analysis)
- Value to user: ~$4.99 (Value Pack = 550 Energy)

---

## Conclusion

**แนะนำ:** ใช้ **Option A (Install Date)** เพราะง่ายที่สุดและไม่ต้อง maintain list

Beta testers จะได้รับ:
- ✅ 100 Energy (welcome gift)
- ✅ 1,000 Energy (beta tester reward)
- **รวม: 1,100 Energy** (~310 AI analyses)

🙏 Thank you, beta testers!
