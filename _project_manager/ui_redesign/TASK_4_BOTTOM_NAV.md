# TASK 4: เพิ่ม Bottom Navigation Bar

> **ระยะเวลา:** 1 วัน (8 ชั่วโมง)  
> **ความยาก:** ⭐⭐⭐ ปานกลาง (restructure navigation)  
> **Dependency:** ต้องทำ TASK_1 และ TASK_3 ก่อน  
> **มอบหมาย:** **Senior เท่านั้น** หรือ Junior pair กับ Senior

## 🎯 เป้าหมาย

เปลี่ยนจาก TabBar ด้านบน + FABs → BottomNavigationBar 4 tabs

### Before
```
┌──────────────────────────────────┐
│  [⚡42]  MIRO         [👤]       │ AppBar
├──────────────────────────────────┤
│ Timeline | Diet | My Meal        │ TabBar
├──────────────────────────────────┤
│  Content ตาม tab                 │
│                                   │
│                                   │
│                           [📷][✨]│ FABs
└──────────────────────────────────┘
```

### After
```
┌──────────────────────────────────┐
│  [⚡42]  Today's Intake           │ AppBar (dynamic)
├──────────────────────────────────┤
│  Content ตาม tab                 │
│                                   │
│                                   │
├──────────────────────────────────┤
│  🏠    📊    ➕    👤            │ BottomNav
│Dashboard Diet LogFood Profile    │
└──────────────────────────────────┘
```

## 📁 ไฟล์ที่ต้องแก้ (3 ไฟล์)

1. `lib/features/home/presentation/home_screen.dart` — หลัก
2. `lib/features/health/presentation/health_page.dart` — ลบ TabBar หรือลบไฟล์
3. `lib/features/home/widgets/feature_tour.dart` — อัพเดท GlobalKey targets (optional)

---

## ⚠️ กฎสำคัญ - Task นี้ซับซ้อน

- **Junior:** ถ้าไม่มั่นใจ ให้ Senior ทำคนเดียว
- **Senior:** Pair programming กับ Junior แนะนำ
- **การทดสอบ:** ต้อง test ทุก flow (navigation, back button, deep link)

### ✅ ที่แก้ได้
- HomeScreen structure (เพิ่ม BottomNav + IndexedStack)
- HealthPage (ลบ TabBar)
- AppBar title (dynamic ตาม tab)
- FABs → ย้ายเข้า BottomNav

### ❌ ห้ามแก้
- Providers ทั้งหมด
- Tab content (HealthTimelineTab, HealthDietTab, ProfileScreen)
- Navigation logic ใน tab (detail sheets, etc.)
- Permission requests
- Feature tour logic (แค่อัพเดท targets)

---

## ขั้นตอนที่ 1: Backup ไฟล์เดิม

```bash
cd lib/features/home/presentation
cp home_screen.dart home_screen.dart.backup

cd ../../health/presentation
cp health_page.dart health_page.dart.backup
```

---

## ขั้นตอนที่ 2: แก้ home_screen.dart

### 2.1 เปิดไฟล์
```
lib/features/home/presentation/home_screen.dart
```

### 2.2 เปลี่ยน Class State

**Before (บรรทัดที่ 23):**
```dart
class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _hasRequestedPermissions = false;
  
  final _energyBadgeKey = GlobalKey();
  final _timelineAreaKey = GlobalKey();
  final _magicButtonKey = GlobalKey();
```

**After:**
```dart
class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _hasRequestedPermissions = false;
  int _currentIndex = 0;  // เพิ่มบรรทัดนี้
  
  final _energyBadgeKey = GlobalKey();
  final _timelineAreaKey = GlobalKey();
  final _magicButtonKey = GlobalKey();
```

### 2.3 เปลี่ยน build() method

**Before (บรรทัดที่ 174-227):**
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: _buildAppBar(),
    body: Stack(
      children: [
        HealthPage(key: _timelineAreaKey),
      ],
    ),
    floatingActionButton: Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Camera Button
          SizedBox(
            width: 48.0,
            height: 48.0,
            child: FloatingActionButton(
              heroTag: 'camera_fab',
              onPressed: () async {
                // ...camera logic...
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          
          // Chat Button
          MagicButton(key: _magicButtonKey),
        ],
      ),
    ),
    floatingActionButtonLocation: FloatingActionLocation.endFloat,
  );
}
```

**After:**
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: _buildAppBar(),
    body: IndexedStack(
      index: _currentIndex == 2 ? 0 : _currentIndex,  // Log Food ไม่มีหน้า
      children: [
        HealthTimelineTab(timelineKey: _timelineAreaKey),  // 0: Dashboard
        const HealthDietTab(),                             // 1: Diet
        const SizedBox(),                                   // 2: Log Food (placeholder)
        const ProfileScreen(),                              // 3: Profile
      ],
    ),
    bottomNavigationBar: _buildBottomNav(),
    // ลบ floatingActionButton + floatingActionButtonLocation ออกทั้งหมด
  );
}
```

### 2.4 เพิ่ม method _buildBottomNav()

เพิ่มใต้ `_buildAppBar()` method:

```dart
Widget _buildBottomNav() {
  return BottomNavigationBar(
    currentIndex: _currentIndex == 2 ? 0 : _currentIndex,  // Log Food ไม่highlight
    onTap: (index) {
      if (index == 2) {
        // Log Food → เปิด bottom sheet
        _showLogFoodSheet();
        return;
      }
      setState(() => _currentIndex = index);
    },
    type: BottomNavigationBarType.fixed,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.textSecondary,
    selectedFontSize: 12,
    unselectedFontSize: 12,
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Dashboard',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.pie_chart_outline),
        activeIcon: Icon(Icons.pie_chart),
        label: 'Diet',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.add_circle_outline, size: 32),
        label: 'Log Food',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Profile',
      ),
    ],
  );
}
```

### 2.5 เพิ่ม method _showLogFoodSheet()

เพิ่มต่อจาก `_buildBottomNav()`:

```dart
void _showLogFoodSheet() {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Log Food',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Camera option
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.camera_alt, color: AppColors.primary),
              ),
              title: const Text('Take Photo'),
              subtitle: const Text('Scan food with camera'),
              onTap: () async {
                Navigator.pop(context);
                // Copy logic จาก FAB camera เดิม
                if (!mounted) return;
                final navigator = Navigator.of(context);
                
                final File? capturedImage = await navigator.push<File>(
                  MaterialPageRoute(
                    builder: (context) => const CameraScreen(),
                  ),
                );
                
                if (capturedImage != null && mounted) {
                  navigator.push(
                    MaterialPageRoute(
                      builder: (context) => ImageAnalysisPreviewScreen(
                        imageFile: capturedImage,
                      ),
                    ),
                  );
                }
              },
            ),
            // Chat option
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.amber),
              ),
              title: const Text('Chat with AI'),
              subtitle: const Text('Tell me what you ate'),
              onTap: () {
                Navigator.pop(context);
                // Copy logic จาก MagicButton เดิม
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatScreen()),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}
```

### 2.6 แก้ _buildAppBar() ให้ dynamic

**Before:**
```dart
PreferredSizeWidget _buildAppBar() {
  return AppBar(
    title: const Text(
      'MIRO',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    ),
    leading: Padding(
      key: _energyBadgeKey,
      padding: const EdgeInsets.only(left: 8.0),
      child: const Center(
        child: EnergyBadgeRiverpod(),
      ),
    ),
    leadingWidth: 80,
    actions: [
      IconButton(
        icon: const Icon(Icons.person),
        onPressed: () => _openProfile(),
      ),
    ],
  );
}
```

**After:**
```dart
PreferredSizeWidget _buildAppBar() {
  String title;
  switch (_currentIndex) {
    case 0:
      title = "Today's Intake";
      break;
    case 1:
      title = 'Diet';
      break;
    case 3:
      title = 'Profile';
      break;
    default:
      title = 'MIRO';
  }
  
  return AppBar(
    title: Text(title),
    leading: Padding(
      key: _energyBadgeKey,
      padding: const EdgeInsets.only(left: 8.0),
      child: const Center(
        child: EnergyBadgeRiverpod(),
      ),
    ),
    leadingWidth: 80,
    // ลบ actions ออก (Profile ย้ายไป BottomNav แล้ว)
  );
}
```

### 2.7 ลบ method _openProfile()

เพราะ Profile เข้าถึงจาก BottomNav แล้ว ไม่ต้องใช้ method นี้

---

## ขั้นตอนที่ 3: เพิ่ม imports

### 3.1 เช็คข้างบนสุดไฟล์

ต้องมี:
```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/logger.dart';
import '../../../core/services/permission_service.dart';
import '../../../core/ai/gemini_service.dart';
import '../../health/presentation/health_timeline_tab.dart';  // เพิ่ม
import '../../health/presentation/health_diet_tab.dart';      // เพิ่ม
import '../../health/presentation/image_analysis_preview_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../camera/presentation/camera_screen.dart';
import '../../chat/presentation/chat_screen.dart';             // เพิ่ม
import '../../energy/widgets/energy_badge_riverpod.dart';
import '../widgets/magic_button.dart';  // ไม่ใช้แล้ว แต่ไว้ก่อน
import '../widgets/feature_tour.dart';
```

---

## ขั้นตอนที่ 4: แก้ health_page.dart

### 4.1 เปิดไฟล์
```
lib/features/health/presentation/health_page.dart
```

### 4.2 Option A (แนะนำ): ลบไฟล์ทิ้ง

เพราะไม่ใช้แล้ว แต่ต้องเช็ค import ทุกที่ที่อ้างถึง `HealthPage`

**ค้นหาใน project:**
```bash
cd c:\aiprogram\miro
grep -r "HealthPage" lib/
```

ถ้ามีไฟล์ไหน import → เปลี่ยนเป็น import `HealthTimelineTab` และ `HealthDietTab` แทน

### 4.3 Option B: เปลี่ยนเป็น wrapper ธรรมดา

ถ้าไม่อยากลบ เปลี่ยนเป็น:
```dart
import 'package:flutter/material.dart';
import 'health_timeline_tab.dart';

class HealthPage extends StatelessWidget {
  const HealthPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Deprecated: ใช้ HealthTimelineTab แทน
    return const HealthTimelineTab();
  }
}
```

---

## ขั้นตอนที่ 5: จัดการ My Meal Tab

### 5.1 เพิ่มปุ่มใน HealthDietTab

เปิด `lib/features/health/presentation/health_diet_tab.dart`

หา `build()` method ใน `SingleChildScrollView` children (ประมาณบรรทัด 57)

**เพิ่มใต้ MealSection ทั้ง 4 (breakfast/lunch/dinner/snack):**

```dart
// ใต้ MealSection สุดท้าย เพิ่ม:
const SizedBox(height: 16),

// Button to My Meals
Card(
  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: ListTile(
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.health.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.restaurant_menu, color: AppColors.health),
    ),
    title: const Text('My Meals & Ingredients'),
    subtitle: const Text('Manage your custom meals'),
    trailing: const Icon(Icons.chevron_right),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HealthMyMealTab(),
        ),
      );
    },
  ),
),

const SizedBox(height: 100), // Bottom padding
```

**เพิ่ม import:**
```dart
import '../../../core/theme/app_colors.dart';
import 'health_my_meal_tab.dart';
```

---

## ขั้นตอนที่ 6: อัพเดท Feature Tour (Optional)

### 6.1 เปิดไฟล์
```
lib/features/home/widgets/feature_tour.dart
```

### 6.2 หา method buildChatButtonTarget

แก้ให้ชี้ไปที่ BottomNav แทน FAB:

```dart
static TargetFocus buildChatButtonTarget(GlobalKey key) {
  return TargetFocus(
    identify: 'chat_button',
    keyTarget: key,
    alignSkip: Alignment.topRight,
    contents: [
      TargetContent(
        align: ContentAlign.top,
        builder: (context, controller) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '✨ Log Food',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tap + to log food via camera or chat with AI',  // แก้ข้อความ
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    ],
  );
}
```

### 6.3 ใน home_screen.dart แก้ tour targets

หา method `_checkAndShowFeatureTour()` (ประมาณบรรทัด 264):

```dart
Future<void> _checkAndShowFeatureTour() async {
  final hasCompleted = await FeatureTour.hasCompletedTour();
  
  if (!hasCompleted && mounted) {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    final targets = [
      FeatureTour.buildEnergyBadgeTarget(_energyBadgeKey),
      FeatureTour.buildPullRefreshTarget(_timelineAreaKey),
      // ลบบรรทัดนี้ออก (ไม่มี MagicButton แล้ว):
      // FeatureTour.buildChatButtonTarget(_magicButtonKey),
    ];
    
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

---

## 📝 Checklist

- [ ] แก้ home_screen.dart: เพิ่ม `_currentIndex` state
- [ ] เปลี่ยน body เป็น IndexedStack (4 children)
- [ ] เพิ่ม `_buildBottomNav()` method
- [ ] เพิ่ม `_showLogFoodSheet()` method
- [ ] แก้ `_buildAppBar()` ให้ dynamic title
- [ ] ลบ FABs ออก
- [ ] ลบ `_openProfile()` method
- [ ] เช็ค imports ครบ
- [ ] แก้ health_page.dart (ลบหรือเปลี่ยนเป็น wrapper)
- [ ] เพิ่มปุ่ม My Meals ใน HealthDietTab
- [ ] อัพเดท Feature Tour (optional)
- [ ] Build ผ่าน: `flutter build apk --debug`
- [ ] ทดสอบ: BottomNav 4 tabs
- [ ] ทดสอบ: Switch tab state ไม่หาย
- [ ] ทดสอบ: Log Food → bottom sheet → camera/chat
- [ ] ทดสอบ: Back button ทำงานถูก
- [ ] ทดสอบ: Feature Tour ไม่ crash
- [ ] ทดสอบ: Deep link (ถ้ามี)
- [ ] ทดสอบ: Dark mode

---

## 🧪 Testing Steps (ละเอียด)

### 1. Build
```bash
flutter clean
flutter pub get
flutter build apk --debug
```

### 2. Test BottomNav

#### Dashboard Tab (index 0)
- เปิดแอป → default tab = Dashboard
- AppBar title = "Today's Intake"
- เห็น DailySummaryCard + Meals card (horizontal)
- Pull-to-refresh ทำงาน

#### Diet Tab (index 1)
- Tap "Diet" → switch tab
- AppBar title = "Diet"
- เห็น DailySummaryCard + MealSection 4 ตัว (B/L/D/S)
- Scroll ลงล่างสุด → เห็นปุ่ม "My Meals & Ingredients"
- Tap ปุ่ม → navigate ไป HealthMyMealTab
- Back → กลับมา Diet tab

#### Log Food (index 2)
- Tap "+ Log Food" → bottom sheet เปิด
- เห็น 2 options: Camera, Chat
- Tap "Take Photo" → เปิด Camera
  - ถ่ายรูป → Preview → Save → กลับ Dashboard → data update
- Tap "Chat with AI" → เปิด ChatScreen
  - พิมพ์ข้อความ → AI ตอบ → บันทึก → กลับ Dashboard → data update

#### Profile Tab (index 3)
- Tap "Profile" → switch tab
- AppBar title = "Profile"
- เห็น ProfileScreen
- Settings ทำงานปกติ
- Back → อยู่ใน Profile tab (ไม่ออกแอป)

### 3. Test State Preservation

- Dashboard → เพิ่ม food → switch ไป Diet → กลับ Dashboard → food ยังอยู่
- Dashboard → scroll ลง → switch tab → กลับ Dashboard → scroll position ยังอยู่
- Diet → scroll → switch tab → กลับ Diet → scroll position ยังอยู่

### 4. Test Back Button

- Dashboard → กด back (hardware) → แอปออก (exit)
- Diet → กด back → แอปออก (ไม่กลับ Dashboard)
- Profile → กด back → แอปออก
- Log Food sheet → กด back → sheet close

### 5. Test Feature Tour (First Launch)

- ลบแอปแล้วติดใหม่
- เปิดแอป → Onboarding → Permission → Tour
- Tour แสดง 2 จุด (Energy Badge, Pull Refresh)
- ไม่มี tour ชี้ที่ MagicButton (เพราะลบแล้ว)

### 6. Test Dark Mode

- Toggle dark mode → ทุก tab ไม่แตก
- BottomNav สีเข้ม
- Selected item เห็นชัด

---

## 🚀 Git Commit

```bash
git add lib/features/home/presentation/home_screen.dart
git add lib/features/health/presentation/health_page.dart
git add lib/features/health/presentation/health_diet_tab.dart
git add lib/features/home/widgets/feature_tour.dart
git commit -m "feat: replace TabBar with BottomNavigationBar

- Add BottomNavigationBar with 4 tabs: Dashboard, Diet, Log Food, Profile
- Use IndexedStack to preserve state across tab switches
- Replace FABs with Log Food bottom sheet (camera/chat options)
- Move My Meal access to Diet tab as button
- Update AppBar title dynamically based on selected tab
- Update Feature Tour to remove MagicButton target
- Maintain all existing logic and providers"

git push origin feature/airbnb-redesign
```

---

## ❓ Q&A

**Q: Build error "HealthTimelineTab not found"?**  
A: เพิ่ม import: `import '../../health/presentation/health_timeline_tab.dart';`

**Q: IndexedStack ทำให้ app ช้า?**  
A: มีแค่ 3-4 หน้า ไม่น่ามีปัญหา แต่ถ้าช้าจริง เปลี่ยนเป็น `PageView`

**Q: Log Food sheet ไม่เปิด?**  
A: เช็ค `context.mounted` ก่อน `showModalBottomSheet`

**Q: Back button กด 1 ครั้งแล้วออกแอป?**  
A: ปกติ (เพราะ BottomNav ไม่มี back stack), ถ้าอยาก double-tap to exit ต้องเพิ่ม `WillPopScope`

**Q: Feature Tour crash?**  
A: อาจเป็นเพราะ GlobalKey หา target ไม่เจอ ลองลบ tour target ออกชั่วคราว

---

**✅ เสร็จแล้ว?** → ไปทำ `TASK_5_POLISH.md` ต่อ (ทำความสะอาด + ปรับแต่ง)
