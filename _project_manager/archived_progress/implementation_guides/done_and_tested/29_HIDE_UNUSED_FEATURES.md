# Step 29: ซ่อนฟีเจอร์ที่ไม่ใช้ (v1.0 Food Only)

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 2-3 ชั่วโมง
> **ความยาก:** ง่าย
> **ต้องทำก่อน:** Step 28 (Quick Repeat & Favorite) — โปรเจคปัจจุบันต้องรันได้ปกติ

---

## 🎯 เป้าหมาย

1. **ลบ Bottom Navigation Bar** — เหลือแค่หน้า Health เดียว (ไม่มี Finance, Tasks)
2. **ลด Health Sub-Tabs เหลือ 3** — Timeline | Diet | My Meal (ลบ Workout, Other, Lab)
3. **ปรับ Chat Intent** — เหลือแค่ food/health
4. **ซ่อนเมนู Profile** ที่ไม่เกี่ยวข้อง
5. **Fix MagicButton Context** ให้เป็น health เสมอ

---

## 📐 สิ่งที่จะเปลี่ยน

### ก่อน (ปัจจุบัน)
```
Bottom Nav: [Finance] [Health] [Tasks]
Health Tabs: Timeline | Diet | My Meal | Workout | Other | Lab
Chat: รองรับ finance, health, tasks
Profile: เมนูเยอะ (Calendar, Health Connect, Insights, etc.)
```

### หลัง (v1.0)
```
Bottom Nav: ไม่มี (แสดง Health เต็มจอ)
Health Tabs: Timeline | Diet | My Meal
Chat: รองรับ food/health เท่านั้น
Profile: เมนูที่เกี่ยวข้องเท่านั้น
```

---

## 📂 ไฟล์ที่เกี่ยวข้อง

| ไฟล์ | Action | คำอธิบาย |
|------|--------|----------|
| `lib/features/home/presentation/home_screen.dart` | EDIT | ลบ Bottom Nav, แสดง Health เดียว |
| `lib/features/health/presentation/health_page.dart` | EDIT | ลด Tab เหลือ 3 |
| `lib/features/chat/services/intent_handler.dart` | EDIT | ลบ finance/task handler |
| `lib/features/profile/presentation/profile_screen.dart` | EDIT | ซ่อนเมนูที่ไม่เกี่ยว |
| `lib/features/home/widgets/magic_button.dart` | EDIT | Fix context เป็น health เสมอ |

---

## 🔧 ขั้นตอนการทำงาน

### Step 1: แก้ HomeScreen — ลบ Bottom Navigation Bar

**ไฟล์:** `lib/features/home/presentation/home_screen.dart`
**Action:** EDIT

#### 1.1 สิ่งที่ต้องลบ

ลบทั้งหมดต่อไปนี้:
- `_currentIndex` variable
- `_pages` list (FinancePage, HealthPage, TasksPage)
- `_pageContextMap`
- `_buildBottomNav()` method ทั้งหมด
- `IndexedStack(...)` ใน body
- import `FinancePage`
- import `TasksPage`
- ปุ่ม Notification ใน AppBar (ยังเป็น mock)

#### 1.2 เปลี่ยน body เป็น Health ตรงๆ

**ก่อน:**
```dart
body: IndexedStack(
  index: _currentIndex,
  children: _pages,
),
bottomNavigationBar: _buildBottomNav(),
```

**หลัง:**
```dart
body: const HealthPage(),
// ไม่มี bottomNavigationBar
```

#### 1.3 ปรับ AppBar

**ก่อน:**
```dart
AppBar(
  title: Text('Miro Hybrid'),
  actions: [
    IconButton(icon: Icon(Icons.notifications), onPressed: ...),  // ← ลบ
    IconButton(icon: Icon(Icons.person), onPressed: _openProfile),
  ],
),
```

**หลัง:**
```dart
AppBar(
  title: const Text('Miro Cal'),  // ← ชื่อใหม่ (หรือชื่อเดิมก่อน ค่อยเปลี่ยนใน Phase 5)
  actions: [
    IconButton(icon: const Icon(Icons.person), onPressed: _openProfile),
  ],
),
```

#### 1.4 ปรับ `_openMenu()` (ถ้ามี)

ลบ menu items ที่เกี่ยวกับ Finance, Tasks ออก เหลือแค่:
- Profile / Settings
- About

---

### Step 2: ลด Health Sub-Tabs เหลือ 3

**ไฟล์:** `lib/features/health/presentation/health_page.dart`
**Action:** EDIT

#### 2.1 เปลี่ยน TabController length

**ก่อน:**
```dart
_tabController = TabController(length: 6, vsync: this);
```

**หลัง:**
```dart
_tabController = TabController(length: 3, vsync: this);
```

#### 2.2 ลบ Tab ที่ไม่ใช้

**ก่อน (TabBar):**
```dart
TabBar(
  tabs: [
    Tab(text: 'Timeline'),
    Tab(text: 'Diet'),
    Tab(text: 'My Meal'),
    Tab(text: 'Workout'),    // ← ลบ
    Tab(text: 'Other'),      // ← ลบ
    Tab(text: 'Lab'),        // ← ลบ
  ],
)
```

**หลัง (TabBar):**
```dart
TabBar(
  tabs: const [
    Tab(text: 'Timeline'),
    Tab(text: 'Diet'),
    Tab(text: 'My Meal'),
  ],
)
```

#### 2.3 ลบ TabBarView children

**ก่อน (TabBarView):**
```dart
TabBarView(
  children: [
    HealthTimelineTab(),
    HealthDietTab(),
    HealthMyMealTab(),
    HealthWorkoutTab(),     // ← ลบ
    HealthOtherTab(),       // ← ลบ
    HealthLabTab(),         // ← ลบ
  ],
)
```

**หลัง (TabBarView):**
```dart
TabBarView(
  children: const [
    HealthTimelineTab(),
    HealthDietTab(),
    HealthMyMealTab(),
  ],
)
```

#### 2.4 ลบ imports ที่ไม่ใช้

```dart
// ลบ 3 บรรทัดนี้
import 'health_workout_tab.dart';
import 'health_other_tab.dart';
import 'health_lab_tab.dart';
```

> **หมายเหตุ:** ไม่ต้องลบไฟล์ `health_workout_tab.dart`, `health_other_tab.dart`, `health_lab_tab.dart` — แค่ไม่ import ก็พอ เผื่อเปิดกลับมาในอนาคต

---

### Step 3: ปรับ Chat Intent Handler

**ไฟล์:** `lib/features/chat/services/intent_handler.dart`
**Action:** EDIT

#### 3.1 Comment out Finance/Task handlers

หา method `_handleFinance()` และ `_handleTask()` → **comment out** ทั้ง method (ไม่ต้องลบ เผื่อเปิดกลับ)

```dart
// === COMMENTED OUT FOR v1.0 (Food Only) ===
// Future<ActionResult> _handleFinance(String text) async {
//   ...
// }
//
// Future<ActionResult> _handleTask(String text) async {
//   ...
// }
// === END COMMENTED OUT ===
```

#### 3.2 แก้ intent classification ให้ตอบกลับเมื่อถาม finance/tasks

หา method ที่ classify intent (อาจชื่อ `_classifyIntent()` หรือ `handleMessage()`) → เพิ่ม response สำหรับกรณีที่ไม่ใช่ food:

```dart
// เมื่อ intent ไม่ใช่ food/health
if (intent == 'finance' || intent == 'task') {
  return ActionResult(
    success: false,
    message: 'ขออภัยครับ ฟังก์ชันนี้ยังไม่พร้อมในเวอร์ชันนี้\nตอนนี้รองรับเฉพาะการบันทึกอาหารครับ',
    type: ActionResultType.info,
  );
}
```

---

### Step 4: ซ่อนเมนู Profile ที่ไม่เกี่ยว

**ไฟล์:** `lib/features/profile/presentation/profile_screen.dart`
**Action:** EDIT

#### 4.1 ซ่อนเมนูเหล่านี้

หา widgets / ListTile ที่เกี่ยวกับเมนูเหล่านี้ → **comment out** หรือ **wrap ด้วย `if (false)`**:

```dart
// ===== ซ่อนสำหรับ v1.0 =====

// 1. Google Calendar → ซ่อน
// ListTile(
//   leading: Icon(Icons.calendar_month),
//   title: Text('Google Calendar'),
//   ...
// ),

// 2. Health Connect → ซ่อน
// ListTile(
//   leading: Icon(Icons.monitor_heart),
//   title: Text('Health Connect'),
//   ...
// ),

// 3. สรุปสัปดาห์ (Insights) → ซ่อน
// ListTile(
//   leading: Icon(Icons.insights),
//   title: Text('สรุปสัปดาห์'),
//   ...
// ),

// ===== จบซ่อน v1.0 =====
```

#### 4.2 เมนูที่ต้องเก็บไว้

ตรวจสอบว่ายังมีเมนูเหล่านี้:
- ✅ โปรไฟล์ / ข้อมูลส่วนตัว
- ✅ Gemini API Key
- ✅ เป้าหมายสุขภาพ
- ✅ ล้างข้อมูล
- ✅ เกี่ยวกับแอป
- ✅ นโยบายความเป็นส่วนตัว (จะ implement ใน Phase 6)

---

### Step 5: Fix MagicButton Context

**ไฟล์:** `lib/features/home/widgets/magic_button.dart`
**Action:** EDIT

> **ปัญหา:** `activePageContextProvider` อาจยังส่ง context ว่าอยู่หน้า finance หรือ tasks
> **แก้:** force ให้เป็น health เสมอ

#### 5.1 หา activePageContextProvider

```dart
// ก่อน
final activeContext = ref.watch(activePageContextProvider);
```

```dart
// หลัง — force เป็น health เสมอ (v1.0)
const activeContext = 'health'; // v1.0: Health only
// final activeContext = ref.watch(activePageContextProvider); // ← comment ไว้
```

> **หมายเหตุ:** ถ้า `activePageContextProvider` ถูกใช้ในที่อื่นด้วย ให้เปลี่ยนค่า default ของ provider เป็น `'health'` แทน

---

## ✅ Checklist

### หลังทำเสร็จ ต้องตรวจสอบ:

- [ ] เปิดแอป → เห็น Health page เต็มจอ ไม่มี Bottom Navigation Bar
- [ ] Health มี 3 Tabs: Timeline, Diet, My Meal
- [ ] กด Tab ทั้ง 3 → ทำงานปกติ
- [ ] เปิด Chat → พิมพ์ "บันทึกข้าวผัด" → ทำงานปกติ (food intent)
- [ ] เปิด Chat → พิมพ์ "ฝากเงิน 500" → ได้ message "ฟังก์ชันยังไม่พร้อม"
- [ ] เปิด Profile → ไม่เห็น Google Calendar, Health Connect, Insights
- [ ] เปิด Profile → ยังเห็น API Key, เป้าหมายสุขภาพ
- [ ] กด MagicButton → ทำงานถูกต้อง (context เป็น health)
- [ ] ไม่มี error / warning ใน console ที่เกี่ยวกับ Finance หรือ Tasks

### ⚠️ สิ่งที่ห้ามทำ

- ❌ **ห้ามลบไฟล์** ของ Finance, Tasks, Workout, Other, Lab — แค่เอา import / reference ออก
- ❌ **ห้ามลบ Models** (เช่น transaction.dart, task.dart) — Isar ยังต้องการ schema
- ❌ **ห้ามลบ Providers** — อาจมีที่อ้างถึงอยู่

---

## 🔍 Troubleshooting

### Q: Error "Too many positional arguments"
**สาเหตุ:** อาจลบ parameter ที่ TabController ยังอ้างอยู่
**แก้:** ตรวจว่า `TabController(length: 3, ...)` ตรงกับจำนวน Tab ที่มี

### Q: MagicButton แสดง option ของ Finance
**สาเหตุ:** MagicButton ยังอ่าน context จาก provider
**แก้:** Force `activeContext = 'health'` ตาม Step 5

### Q: Hot reload ไม่ทำงานหลังลบ Tab
**สาเหตุ:** TabController length เปลี่ยน → ต้อง hot restart
**แก้:** กด `R` (ตัวใหญ่) หรือ Stop → Run ใหม่

---

## 🎉 เสร็จแล้ว! ไปต่อ Step 30 →

ไปทำ **Step 30: BYOK — คู่มือ API Key + ปรับ UX** ได้เลย
