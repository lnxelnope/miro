# Phase 3 Task 1: Feature Tour Setup

## เป้าหมาย
เพิ่ม package และ setup โครงสร้างสำหรับ Feature Tour

## ขั้นตอน

### 1. เพิ่ม dependency

เปิดไฟล์: `pubspec.yaml`

เพิ่มใน `dependencies`:

```yaml
dependencies:
  # ... existing dependencies
  tutorial_coach_mark: ^1.2.11
```

### 2. Install package

Run:
```bash
flutter pub get
```

### 3. สร้างไฟล์ใหม่

ตำแหน่ง: `lib/features/home/widgets/feature_tour.dart`

### 4. Copy โค้ดนี้ลงไฟล์

```dart
import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Feature Tour for first-time users
class FeatureTour {
  static const String _keyTutorialCompleted = 'feature_tour_completed_v1';
  
  /// Check if tutorial has been completed
  static Future<bool> hasCompletedTour() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyTutorialCompleted) ?? false;
  }
  
  /// Mark tutorial as completed
  static Future<void> completeTour() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTutorialCompleted, true);
  }
  
  /// Reset tutorial (for testing or "Show again")
  static Future<void> resetTour() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTutorialCompleted);
  }
  
  /// Create and show the feature tour
  static void show({
    required BuildContext context,
    required List<TargetFocus> targets,
    VoidCallback? onFinish,
    VoidCallback? onSkip,
  }) {
    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      paddingFocus: 10,
      opacityShadow: 0.8,
      textSkip: "SKIP",
      onFinish: () {
        completeTour();
        onFinish?.call();
      },
      onSkip: () {
        completeTour();
        onSkip?.call();
      },
    ).show(context: context);
  }
  
  /// Build Energy Badge target (Step 1)
  static TargetFocus buildEnergyBadgeTarget(GlobalKey key) {
    return TargetFocus(
      identify: "energy-badge",
      keyTarget: key,
      alignSkip: Alignment.topRight,
      shape: ShapeLightFocus.RRect,
      radius: 8,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          builder: (context, controller) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚡ Energy System',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'This is your Energy balance.\n\n'
                    'Each AI food analysis costs 1 Energy.\n'
                    'You start with 100 FREE Energy!\n\n'
                    'Tap here to visit the Energy Store.',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => controller.next(),
                      child: const Text('Next →'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
  
  /// Build Pull-to-Refresh target (Step 2)
  static TargetFocus buildPullRefreshTarget(GlobalKey key) {
    return TargetFocus(
      identify: "pull-refresh",
      keyTarget: key,
      alignSkip: Alignment.topRight,
      shape: ShapeLightFocus.RRect,
      radius: 16,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          builder: (context, controller) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📸 Auto Photo Scan',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Pull down on the food list to automatically '
                    'scan your photo gallery for food images!\n\n'
                    'Found food photos will be added to your timeline.\n'
                    'You can then analyze them with AI.',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_downward, size: 32),
                      SizedBox(width: 8),
                      Text('Swipe Down', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => controller.next(),
                      child: const Text('Next →'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
  
  /// Build Chat/Magic Button target (Step 3)
  static TargetFocus buildChatButtonTarget(GlobalKey key) {
    return TargetFocus(
      identify: "chat-button",
      keyTarget: key,
      alignSkip: Alignment.topRight,
      shape: ShapeLightFocus.Circle,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          builder: (context, controller) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💬 Chat with Miro',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Two modes available:\n\n'
                    '🧠 Local AI (Free)\n'
                    '  • English only\n'
                    '  • Basic food logging\n\n'
                    '⚡ Miro AI (1 Energy/chat)\n'
                    '  • Any language\n'
                    '  • Smart multi-food parsing\n'
                    '  • Menu suggestions\n'
                    '  • Nutrition estimates',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => controller.next(),
                      child: const Text('Got it! ✓'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
```

## อธิบาย

### FeatureTour Class มีหน้าที่:
1. **hasCompletedTour()** — เช็คว่า user ทำ tour แล้วหรือยัง
2. **completeTour()** — บันทึกว่าทำเสร็จแล้ว
3. **resetTour()** — ลบ flag (สำหรับทดสอบหรือ "Show again")
4. **show()** — แสดง tutorial
5. **buildXXXTarget()** — สร้าง step แต่ละขั้น

### Tour Steps:
1. **Energy Badge** — อธิบาย Energy system
2. **Pull-to-Refresh** — อธิบายการสแกนรูปอัตโนมัติ
3. **Chat Button** — อธิบาย 2 โหมด AI

## เสร็จแล้ว
✅ Task 1 เสร็จ — Feature Tour setup สำเร็จ
➡️ ไปต่อ Task 2: `03_PHASE3_TASK2_integrate_tour_home_screen.md`
