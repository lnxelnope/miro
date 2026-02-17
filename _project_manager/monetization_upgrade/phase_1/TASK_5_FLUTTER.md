# Task 5: Flutter Client Updates

**ระยะเวลา:** 3 วัน  
**Complexity:** 🟡 Medium  
**ต้องรู้:** Flutter, Dart, Riverpod, API Integration

---

## 🎯 สิ่งที่ต้องทำ

อัพเดท Flutter app ให้รองรับ MiRO ID, Free AI, และ Streak Tier

### เป้าหมาย
1. เรียก `registerUser` ตอน app startup
2. แสดง Free AI indicator ใน Energy Badge
3. แสดง Streak + Tier ใน UI
4. แสดง MiRO ID ใน Profile
5. Handle streak response จาก API

---

## 📝 ขั้นตอนการทำ (Step-by-Step)

### Step 5.1: อัพเดท EnergyService

**ที่อยู่:** `lib/core/services/energy_service.dart`

**เพิ่ม method:**

```dart
/// เรียก registerUser หรือ sync balance
/// เรียกตอน app startup
Future<Map<String, dynamic>> registerOrSync() async {
  final deviceId = await DeviceIdService.getDeviceId();

  // เช็คว่ามี MiRO ID cached อยู่หรือยัง
  final cachedMiroId = await _storage.read(key: 'miro_id');

  if (cachedMiroId != null) {
    // มี MiRO ID แล้ว → sync balance ปกติ
    final balance = await syncBalanceWithServer();
    return {
      'miroId': cachedMiroId,
      'balance': balance,
      'isNew': false,
    };
  }

  // ไม่มี MiRO ID → register
  const url = 'https://us-central1-miro-d6856.cloudfunctions.net/registerUser';

  final response = await http.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'deviceId': deviceId}),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final data = jsonDecode(response.body);
    final miroId = data['miroId'] as String;
    final balance = data['balance'] as int;

    // Cache MiRO ID
    await _storage.write(key: 'miro_id', value: miroId);

    // Update local balance
    await updateFromServerResponse(balance);

    return {
      'miroId': miroId,
      'balance': balance,
      'isNew': data['isNew'] ?? false,
      'tier': data['tier'],
      'currentStreak': data['currentStreak'],
      'freeAiUsedToday': data['freeAiUsedToday'],
    };
  }

  throw Exception('Registration failed: ${response.statusCode}');
}

/// ดึง MiRO ID ที่ cached ไว้
Future<String?> getMiroId() async {
  return await _storage.read(key: 'miro_id');
}
```

---

### Step 5.2: สร้าง GamificationState Model

**ที่อยู่:** `lib/core/models/gamification_state.dart`

```dart
class GamificationState {
  final String miroId;
  final int currentStreak;
  final int longestStreak;
  final String tier; // 'none', 'bronze', 'silver', 'gold', 'diamond'
  final bool freeAiAvailable;
  final int balance;

  const GamificationState({
    required this.miroId,
    required this.currentStreak,
    required this.longestStreak,
    required this.tier,
    required this.freeAiAvailable,
    required this.balance,
  });

  factory GamificationState.empty() {
    return const GamificationState(
      miroId: '',
      currentStreak: 0,
      longestStreak: 0,
      tier: 'none',
      freeAiAvailable: true,
      balance: 0,
    );
  }

  /// Tier display info
  String get tierEmoji {
    switch (tier) {
      case 'bronze': return '🥉';
      case 'silver': return '🥈';
      case 'gold': return '🥇';
      case 'diamond': return '💎';
      default: return '⭐';
    }
  }

  String get tierName {
    switch (tier) {
      case 'bronze': return 'Bronze';
      case 'silver': return 'Silver';
      case 'gold': return 'Gold';
      case 'diamond': return 'Diamond';
      default: return 'Starter';
    }
  }

  /// Days until next tier
  int get daysToNextTier {
    switch (tier) {
      case 'none': return 7 - currentStreak;
      case 'bronze': return 14 - currentStreak;
      case 'silver': return 30 - currentStreak;
      case 'gold': return 60 - currentStreak;
      default: return 0; // Diamond = max tier
    }
  }

  /// Grace period
  int get graceDays {
    switch (tier) {
      case 'silver': return 1;
      case 'gold': return 2;
      case 'diamond': return 3;
      default: return 0;
    }
  }
}
```

---

### Step 5.3: สร้าง GamificationProvider

**ที่อยู่:** `lib/features/energy/providers/gamification_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_hybrid/core/models/gamification_state.dart';
import 'package:miro_hybrid/core/services/energy_service.dart';

final gamificationProvider =
    StateNotifierProvider<GamificationNotifier, GamificationState>((ref) {
  return GamificationNotifier(EnergyService(...));
});

class GamificationNotifier extends StateNotifier<GamificationState> {
  final EnergyService _energyService;

  GamificationNotifier(this._energyService)
      : super(GamificationState.empty()) {
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final result = await _energyService.registerOrSync();
      state = GamificationState(
        miroId: result['miroId'] ?? '',
        currentStreak: result['currentStreak'] ?? 0,
        longestStreak: result['longestStreak'] ?? 0,
        tier: result['tier'] ?? 'none',
        freeAiAvailable: !(result['freeAiUsedToday'] ?? false),
        balance: result['balance'] ?? 0,
      );
    } catch (e) {
      // Fallback
      final balance = await _energyService.getBalance();
      final miroId = await _energyService.getMiroId();
      state = GamificationState(
        miroId: miroId ?? '',
        currentStreak: 0,
        longestStreak: 0,
        tier: 'none',
        freeAiAvailable: true,
        balance: balance,
      );
    }
  }

  /// Update state จาก AI response
  void updateFromAiResponse(Map<String, dynamic> response) {
    final streak = response['streak'] as Map<String, dynamic>?;

    state = GamificationState(
      miroId: state.miroId,
      currentStreak: streak?['current'] ?? state.currentStreak,
      longestStreak: streak?['longest'] ?? state.longestStreak,
      tier: streak?['tier'] ?? state.tier,
      freeAiAvailable: false, // ใช้ free AI แล้ว
      balance: response['balance'] ?? state.balance,
    );
  }
}
```

---

### Step 5.4: แก้ไข main.dart

**ที่อยู่:** `lib/main.dart`

**เพิ่ม initialization:**

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ... Firebase init ...

  // Register or sync user
  final energyService = EnergyService(...);
  try {
    await energyService.registerOrSync();
    debugPrint('✅ User registered/synced');
  } catch (e) {
    debugPrint('❌ Registration failed: $e');
  }

  runApp(const MyApp());
}
```

---

### Step 5.5: แก้ไข Energy Badge

**ที่อยู่:** `lib/features/energy/widgets/energy_badge.dart`

**เพิ่ม Free AI indicator:**

```dart
class EnergyBadge extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamification = ref.watch(gamificationProvider);
    final freeAiAvailable = gamification.freeAiAvailable;

    return Container(
      child: Row(
        children: [
          // Balance
          Text('${gamification.balance} ⚡'),
          
          // Free AI indicator
          if (freeAiAvailable)
            Container(
              margin: EdgeInsets.only(left: 8),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '1 FREE',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }
}
```

---

### Step 5.6: สร้าง Streak Display Widget

**ที่อยู่:** `lib/features/energy/widgets/streak_display.dart`

```dart
class StreakDisplay extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamification = ref.watch(gamificationProvider);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Streak counter
            Row(
              children: [
                Text('🔥', style: TextStyle(fontSize: 24)),
                SizedBox(width: 8),
                Text(
                  '${gamification.currentStreak} days',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            
            SizedBox(height: 8),
            
            // Tier badge
            Row(
              children: [
                Text(gamification.tierEmoji, style: TextStyle(fontSize: 20)),
                SizedBox(width: 8),
                Text(gamification.tierName),
              ],
            ),
            
            SizedBox(height: 8),
            
            // Progress to next tier
            if (gamification.tier != 'diamond')
              Text(
                '${gamification.daysToNextTier} days until next tier',
                style: TextStyle(color: Colors.grey),
              ),
            
            // Grace period info
            if (gamification.graceDays > 0)
              Text(
                'Grace period: ${gamification.graceDays} day(s)',
                style: TextStyle(color: Colors.blue, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}
```

---

### Step 5.7: แก้ไข Profile Screen

**ที่อยู่:** `lib/features/profile/presentation/profile_screen.dart`

**เพิ่มแสดง MiRO ID:**

```dart
// ใน Profile Screen:
final gamification = ref.watch(gamificationProvider);

ListTile(
  title: Text('MiRO ID'),
  subtitle: Text(gamification.miroId),
  trailing: IconButton(
    icon: Icon(Icons.copy),
    onPressed: () {
      Clipboard.setData(ClipboardData(text: gamification.miroId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('MiRO ID copied!')),
      );
    },
  ),
),
```

---

### Step 5.8: Handle AI Response

**ที่อยู่:** `lib/core/ai/gemini_service.dart`

**แก้ไข response handling:**

```dart
final wasFreeAi = responseData['wasFreeAi'] == true;

if (wasFreeAi) {
  debugPrint('[AI] ✅ Free AI used today!');
  
  // Update gamification state
  ref.read(gamificationProvider.notifier)
    .updateFromAiResponse(responseData);
} else {
  // Update balance
  final newBalance = responseData['balance'] as int;
  await energyService.updateFromServerResponse(newBalance);
}
```

---

### Step 5.9: ส่ง timezoneOffset ใน Request

**ที่อยู่:** `lib/core/ai/gemini_service.dart`

**เพิ่มใน request body:**

```dart
final timezoneOffset = DateTime.now().timeZoneOffset.inMinutes;

final requestBody = {
  'deviceId': deviceId,
  'type': type,
  'timezoneOffset': timezoneOffset,  // ← ใหม่!
  // ... fields อื่นๆ
};
```

---

## ✅ Checklist

```
□ แก้ไข energy_service.dart (registerOrSync, getMiroId)
□ สร้าง gamification_state.dart model
□ สร้าง gamification_provider.dart
□ แก้ไข main.dart (เรียก registerOrSync)
□ แก้ไข energy_badge.dart (Free AI indicator)
□ สร้าง streak_display.dart widget
□ แก้ไข profile_screen.dart (แสดง MiRO ID)
□ แก้ไข gemini_service.dart (handle wasFreeAi + streak)
□ ส่ง timezoneOffset ใน request
□ Test บน device จริง
□ ไม่มี linter errors
```

---

## 🧪 Testing

### Manual Test Checklist

```dart
// 1. App startup
✓ เปิดแอป → เรียก registerUser → ได้ MiRO ID
✓ Verify: Profile แสดง MiRO ID

// 2. Free AI
✓ ใช้ AI ครั้งแรก → Energy Badge แสดง "FREE"
✓ ใช้ AI ครั้งแรก → Balance ไม่ลด
✓ ใช้ AI ครั้งที่ 2 → หัก energy

// 3. Streak
✓ ใช้ AI วันแรก → Streak = 1
✓ ใช้ AI 7 วันติด → Streak = 7, Tier = Bronze
✓ หยุด 1 วัน → Streak reset (Bronze)
✓ หยุด 1 วัน → Streak ต่อ (Silver)

// 4. UI
✓ Streak Display แสดงถูกต้อง
✓ Tier badge แสดง emoji + name
✓ Copy MiRO ID ทำงาน
```

---

## ⚠️ Common Issues

### Issue 1: "MiRO ID null"
**แก้ไข:** เช็คว่า registerOrSync ถูกเรียกใน main.dart

### Issue 2: "Free AI ไม่แสดง"
**แก้ไข:** เช็คว่า gamificationProvider ถูก watch ใน widget

### Issue 3: "Timezone ผิด"
**แก้ไข:** ใช้ `DateTime.now().timeZoneOffset.inMinutes`

---

## ⏭️ Next Task

เมื่อทำ Task 5 เสร็จ → ไป **TASK_6_BACKUP.md**
