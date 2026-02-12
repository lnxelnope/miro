# Step 02: Home Screen with Bottom Tabs

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 45 นาที
> **ความยาก:** ง่าย
> **ต้องทำก่อน:** Step 01 (Core Models)

---

## สิ่งที่ต้องทำ

1. สร้าง HomeScreen พร้อม Bottom Navigation Bar
2. สร้าง Placeholder สำหรับ 3 tabs (Finance, Health, Tasks)
3. สร้าง Top App Bar พร้อม Profile Avatar
4. เพิ่ม placeholder สำหรับ Magic Button

---

## ขั้นตอนที่ 1: สร้าง HomeScreen

**แก้ไขไฟล์:** `lib/features/home/presentation/home_screen.dart`

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../finance/presentation/finance_page.dart';
import '../../health/presentation/health_page.dart';
import '../../tasks/presentation/tasks_page.dart';
import '../widgets/magic_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1; // เริ่มที่ Health (กลาง)

  final List<Widget> _pages = const [
    FinancePage(),
    HealthPage(),
    TasksPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: const MagicButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () => _openProfile(),
          child: CircleAvatar(
            backgroundColor: AppColors.primaryLight,
            child: const Icon(
              Icons.person,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
      title: const Text(
        'Miro',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () => _openNotifications(),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _openMenu(),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.account_balance_wallet_outlined,
                activeIcon: Icons.account_balance_wallet,
                label: 'เงิน',
                color: AppColors.finance,
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.restaurant_outlined,
                activeIcon: Icons.restaurant,
                label: 'สุขภาพ',
                color: AppColors.health,
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.event_note_outlined,
                activeIcon: Icons.event_note,
                label: 'งาน',
                color: AppColors.tasks,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required Color color,
  }) {
    final isSelected = _currentIndex == index;
    
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? color : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 20,
                height: 3,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openProfile() {
    // TODO: Navigate to Profile Screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('จะไป Profile Screen')),
    );
  }

  void _openNotifications() {
    // TODO: Show notifications
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifications - Phase 2')),
    );
  }

  void _openMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.backup_outlined),
              title: const Text('สำรองข้อมูล'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('เกี่ยวกับ'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## ขั้นตอนที่ 2: สร้าง Magic Button (Placeholder)

**สร้างไฟล์:** `lib/features/home/widgets/magic_button.dart`

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class MagicButton extends StatelessWidget {
  const MagicButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showMagicMenu(context),
      backgroundColor: AppColors.primary,
      child: const Icon(
        Icons.auto_awesome,
        color: Colors.white,
      ),
    );
  }

  void _showMagicMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'เพิ่มข้อมูล',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMenuButton(
                  context: context,
                  icon: Icons.camera_alt,
                  label: 'ถ่ายรูป',
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Open camera
                  },
                ),
                _buildMenuButton(
                  context: context,
                  icon: Icons.photo_library,
                  label: 'เลือกรูป',
                  color: AppColors.health,
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Open gallery
                  },
                ),
                _buildMenuButton(
                  context: context,
                  icon: Icons.edit_note,
                  label: 'พิมพ์เอง',
                  color: AppColors.finance,
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Open quick add
                  },
                ),
                _buildMenuButton(
                  context: context,
                  icon: Icons.smart_toy,
                  label: 'Chat AI',
                  color: AppColors.tasks,
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Open chat
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## ขั้นตอนที่ 3: สร้าง Finance Page (Placeholder)

**สร้างไฟล์:** `lib/features/finance/presentation/finance_page.dart`

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sub-tabs
        Container(
          color: Theme.of(context).cardColor,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.finance,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.finance,
            tabs: const [
              Tab(text: 'Timeline'),
              Tab(text: 'รายรับ/จ่าย'),
              Tab(text: 'สินทรัพย์'),
            ],
          ),
        ),
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPlaceholder('Finance Timeline', '📜'),
              _buildPlaceholder('Income/Expense', '💰'),
              _buildPlaceholder('Assets', '📈'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(String title, String emoji) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming soon...',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## ขั้นตอนที่ 4: สร้าง Health Page (Placeholder)

**สร้างไฟล์:** `lib/features/health/presentation/health_page.dart`

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sub-tabs
        Container(
          color: Theme.of(context).cardColor,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColors.health,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.health,
            tabs: const [
              Tab(text: 'Timeline'),
              Tab(text: 'Diet'),
              Tab(text: 'Workout'),
              Tab(text: 'Other'),
              Tab(text: 'Lab'),
            ],
          ),
        ),
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPlaceholder('Health Timeline', '📜'),
              _buildPlaceholder('Diet', '🍽️'),
              _buildPlaceholder('Workout', '🏋️'),
              _buildPlaceholder('Other', '📦'),
              _buildPlaceholder('Lab Results', '🩺'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(String title, String emoji) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming soon...',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## ขั้นตอนที่ 5: สร้าง Tasks Page (Placeholder)

**สร้างไฟล์:** `lib/features/tasks/presentation/tasks_page.dart`

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sub-tabs
        Container(
          color: Theme.of(context).cardColor,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.tasks,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.tasks,
            tabs: const [
              Tab(text: 'Today'),
              Tab(text: 'Calendar'),
              Tab(text: 'Lists'),
              Tab(text: 'Habits'),
            ],
          ),
        ),
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPlaceholder('Today', '📅'),
              _buildPlaceholder('Calendar', '📆'),
              _buildPlaceholder('Lists', '📝'),
              _buildPlaceholder('Habits', '🔥'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(String title, String emoji) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming soon...',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## ขั้นตอนที่ 6: ทดสอบ

```bash
flutter run
```

**ผลที่ควรได้:**
- Bottom Navigation Bar มี 3 tabs: เงิน, สุขภาพ, งาน
- กดเปลี่ยน tab ได้
- แต่ละ tab มี sub-tabs ด้านบน
- มี Magic Button (✨) ที่มุมขวาล่าง
- กด Magic Button แล้วแสดง menu

---

## ✅ Checklist

- [ ] สร้าง home_screen.dart แล้ว
- [ ] สร้าง magic_button.dart แล้ว
- [ ] สร้าง finance_page.dart แล้ว
- [ ] สร้าง health_page.dart แล้ว
- [ ] สร้าง tasks_page.dart แล้ว
- [ ] Bottom Navigation ทำงานได้
- [ ] Sub-tabs ทำงานได้
- [ ] Magic Button กดแล้วแสดง menu

---

## ไฟล์ที่สร้าง/แก้ไขในขั้นตอนนี้

```
lib/features/
├── home/
│   ├── presentation/
│   │   └── home_screen.dart       ← UPDATED
│   └── widgets/
│       └── magic_button.dart      ← NEW
├── finance/
│   └── presentation/
│       └── finance_page.dart      ← NEW
├── health/
│   └── presentation/
│       └── health_page.dart       ← NEW
└── tasks/
    └── presentation/
        └── tasks_page.dart        ← NEW
```

---

## ขั้นตอนถัดไป

ไปที่ **Step 03: Magic Button with Speed Dial** เพื่อทำให้ Magic Button เป็น Speed Dial ที่สวยงาม
