# Phase 3 Task 3: เพิ่มปุ่ม "Show Tutorial Again" ใน Profile

## เป้าหมาย
ให้ user สามารถดู tutorial อีกครั้งได้จาก Profile Screen

## ขั้นตอน

### 1. เปิดไฟล์
ตำแหน่ง: `lib/features/profile/presentation/profile_screen.dart`

### 2. เพิ่ม import

```dart
import 'package:miro/features/home/widgets/feature_tour.dart';
```

### 3. หาส่วน ListTile สำหรับ settings/help

มักจะอยู่ในส่วน "Help" หรือ "About"

### 4. เพิ่ม ListTile ใหม่

หลังจาก "Privacy Policy" หรือ "Terms of Service" เพิ่ม:

```dart
ListTile(
  leading: const Icon(Icons.lightbulb_outline),
  title: const Text('Show Tutorial Again'),
  subtitle: const Text('View feature tour'),
  onTap: () => _showTutorialAgain(context),
),
```

### 5. เพิ่ม method `_showTutorialAgain()`

เพิ่มใน `_ProfileScreenState`:

```dart
/// Show feature tour again
Future<void> _showTutorialAgain(BuildContext context) async {
  // Show confirmation dialog
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Show Tutorial'),
      content: const Text(
        'This will show the feature tour that highlights:\n\n'
        '• Energy System\n'
        '• Pull-to-Refresh Photo Scan\n'
        '• Chat with Miro AI\n\n'
        'You will return to the Home screen.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Show Tutorial'),
        ),
      ],
    ),
  );
  
  if (confirm != true || !context.mounted) return;
  
  // Reset tutorial flag
  await FeatureTour.resetTour();
  
  // Show success message
  if (!context.mounted) return;
  
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Tutorial reset! Go to Home screen to view it.'),
      duration: Duration(seconds: 3),
    ),
  );
  
  // Optional: Navigate to Home automatically
  // Navigator.popUntil(context, (route) => route.isFirst);
}
```

## UI ตัวอย่าง

### Profile Screen
```
┌─────────────────────────────────┐
│  Profile                    [×] │
├─────────────────────────────────┤
│                                 │
│  👤 Account                     │
│  ⚙️  Settings                   │
│                                 │
│  Help & Support                 │
│  📄 Privacy Policy              │
│  📄 Terms of Service            │
│  💡 Show Tutorial Again    ← NEW│
│  ℹ️  About                      │
│                                 │
└─────────────────────────────────┘
```

### Confirmation Dialog
```
┌─────────────────────────────────┐
│  Show Tutorial                  │
├─────────────────────────────────┤
│  This will show the feature     │
│  tour that highlights:          │
│                                 │
│  • Energy System                │
│  • Pull-to-Refresh Photo Scan   │
│  • Chat with Miro AI            │
│                                 │
│  You will return to the Home    │
│  screen.                        │
├─────────────────────────────────┤
│  [Cancel]  [Show Tutorial]      │
└─────────────────────────────────┘
```

## อธิบาย

### Flow:
1. User กด "Show Tutorial Again" ใน Profile
2. แสดง confirmation dialog
3. User กด "Show Tutorial" → reset flag
4. แสดง SnackBar "Tutorial reset! Go to Home..."
5. User กลับไป Home → tour แสดงอัตโนมัติ

### หมายเหตุ:
- ไม่ได้แสดง tour ทันทีในหน้า Profile (เพราะ GlobalKeys อยู่ที่ HomeScreen)
- Reset flag → user ต้องกลับ Home เอง
- Optional: ใช้ `Navigator.popUntil()` เพื่อกลับ Home อัตโนมัติ

## ทดสอบ
1. เปิด Profile
2. กด "Show Tutorial Again"
3. กด "Show Tutorial" ใน dialog
4. เห็น SnackBar "Tutorial reset!"
5. กลับไป Home → tour แสดงอีกครั้ง

## เสร็จแล้ว
✅ Task 3 เสร็จ — Phase 3 เสร็จสมบูรณ์!

### Phase 3 Summary
- ✅ Feature Tour setup (tutorial_coach_mark)
- ✅ ผูก tour กับ Home Screen (3 steps)
- ✅ "Show Tutorial Again" ใน Profile

➡️ ไปต่อ Phase 4: `04_PHASE4_TASK1_menu_suggestion.md`
