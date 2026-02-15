# Phase 3 Task 2: ผูก Feature Tour กับ Home Screen

## เป้าหมาย
แสดง Feature Tour ครั้งแรกที่เปิด app หลัง onboarding

## ขั้นตอน

### 1. เปิดไฟล์
ตำแหน่ง: `lib/features/home/presentation/home_screen.dart`

### 2. เพิ่ม import

```dart
import 'package:miro/features/home/widgets/feature_tour.dart';
```

### 3. เพิ่ม GlobalKeys ใน `_HomeScreenState`

หาใน class `_HomeScreenState`:

```dart
class _HomeScreenState extends ConsumerState<HomeScreen> {
  // ... existing code
  
  // Add GlobalKeys for Feature Tour
  final _energyBadgeKey = GlobalKey();
  final _timelineAreaKey = GlobalKey();
  final _magicButtonKey = GlobalKey();
  
  // ... rest of code
}
```

### 4. ผูก keys กับ widgets

#### a) Energy Badge (AppBar leading)

หา:
```dart
leading: Padding(
  padding: const EdgeInsets.only(left: 8),
  child: const EnergyBadgeRiverpod(),
),
```

แก้เป็น:
```dart
leading: Padding(
  key: _energyBadgeKey, // ← เพิ่ม key
  padding: const EdgeInsets.only(left: 8),
  child: const EnergyBadgeRiverpod(),
),
```

#### b) Timeline Area (ScrollView body)

หาส่วนที่เป็น main body (HealthTimelineTab หรือ food list):

```dart
// หา Widget ที่ wrap food timeline
RefreshIndicator(
  key: _timelineAreaKey, // ← เพิ่ม key ที่นี่
  onRefresh: _handleRefresh,
  child: // ... existing code
)
```

#### c) Magic Button (FAB)

หา:
```dart
floatingActionButton: MagicButton(),
```

แก้เป็น:
```dart
floatingActionButton: MagicButton(key: _magicButtonKey), // ← เพิ่ม key
```

**หมายเหตุ:** ต้องแก้ `MagicButton` widget ให้รับ key ด้วย

### 5. แก้ไข MagicButton ให้รับ key

เปิดไฟล์: `lib/features/home/widgets/magic_button.dart`

หา constructor:
```dart
const MagicButton({super.key});
```

แก้เป็น:
```dart
const MagicButton({Key? key}) : super(key: key);
```

### 6. เพิ่ม method เช็คและแสดง tour ใน HomeScreen

เพิ่มใน `_HomeScreenState`:

```dart
/// Check and show feature tour (first time only)
Future<void> _checkAndShowFeatureTour() async {
  final hasCompleted = await FeatureTour.hasCompletedTour();
  
  if (!hasCompleted && mounted) {
    // Wait for UI to render (500ms)
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    // Build tour targets
    final targets = [
      FeatureTour.buildEnergyBadgeTarget(_energyBadgeKey),
      FeatureTour.buildPullRefreshTarget(_timelineAreaKey),
      FeatureTour.buildChatButtonTarget(_magicButtonKey),
    ];
    
    // Show tour
    FeatureTour.show(
      context: context,
      targets: targets,
      onFinish: () {
        debugPrint('Feature tour completed');
      },
      onSkip: () {
        debugPrint('Feature tour skipped');
      },
    );
  }
}
```

### 7. เรียก tour หลัง permission dialog

แก้ไข `initState()`:

```dart
@override
void initState() {
  super.initState();
  
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    // 1. Request permissions first
    await _checkAndRequestPermissions();
    
    // 2. Show feature tour (only first time)
    await _checkAndShowFeatureTour();
    
    // 3. Set Gemini context
    if (mounted) {
      GeminiService.setContext(context);
    }
  });
}
```

## Flow Diagram

```
App Launch → Onboarding (if first time)
                  ↓
            Home Screen
                  ↓
          Permission Dialog
                  ↓
          Feature Tour (only first time)
          Step 1: Energy Badge
                  ↓
          Step 2: Pull-to-Refresh
                  ↓
          Step 3: Chat Button
                  ↓
         Tour Completed → Save flag
                  ↓
         Normal App Usage
```

## ทดสอบ

### ทดสอบครั้งแรก:
1. Uninstall app
2. Install ใหม่
3. ผ่าน onboarding
4. ผ่าน permission dialog
5. **Tour ควรแสดงอัตโนมัติ**
6. กด "Next" ผ่านทั้ง 3 steps
7. กด "Got it!" → tour จบ

### ทดสอบครั้งที่สอง:
1. ปิด app
2. เปิดอีกครั้ง
3. **Tour ไม่ควรแสดง** (เพราะทำไปแล้ว)

### ทดสอบ Skip:
1. Reset tour: ลบ app data หรือใช้ `FeatureTour.resetTour()`
2. เปิด app อีกครั้ง
3. กด "SKIP" → tour จบทันที

## เสร็จแล้ว
✅ Task 2 เสร็จ — Feature Tour integration สำเร็จ
➡️ ไปต่อ Task 3: `03_PHASE3_TASK3_show_tour_again_profile.md`
