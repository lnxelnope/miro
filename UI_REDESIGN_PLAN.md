# UI Redesign Plan: Airbnb-Inspired MIRO App
## สำหรับ Senior Developer ศึกษาและมอบหมายงาน

> **Project:** MIRO - The Offline Hybrid Life Assistant  
> **Version ปัจจุบัน:** 1.1.4+28  
> **Branch ปัจจุบัน:** `fix/play-console-android15`  
> **Branch สำหรับงานนี้:** `feature/airbnb-redesign` (สร้างใหม่จาก main หลัง merge Android 15 fix)  
> **ระยะเวลาประมาณ:** 4-5 วันทำงาน  
> **วันที่จัดทำ:** 17 กุมภาพันธ์ 2026  

---

## สารบัญ

1. [ภาพรวมและเป้าหมาย](#1-ภาพรวมและเป้าหมาย)
2. [สถาปัตยกรรมปัจจุบัน (ต้องอ่านก่อน)](#2-สถาปัตยกรรมปัจจุบัน)
3. [Phase 1: Theme & Color System](#3-phase-1-theme--color-system)
4. [Phase 2: DailySummaryCard Redesign](#4-phase-2-dailysummarycard-redesign)
5. [Phase 3: Horizontal Meal Timeline](#5-phase-3-horizontal-meal-timeline)
6. [Phase 4: Bottom Navigation Bar](#6-phase-4-bottom-navigation-bar)
7. [Phase 5: Card Sections & Polish](#7-phase-5-card-sections--polish)
8. [กฎเหล็ก: สิ่งที่ห้ามแก้](#8-กฎเหล็ก-สิ่งที่ห้ามแก้)
9. [Testing Checklist](#9-testing-checklist)
10. [ความเสี่ยงและการป้องกัน](#10-ความเสี่ยงและการป้องกัน)

---

## 1. ภาพรวมและเป้าหมาย

### 1.1 เป้าหมาย
เปลี่ยนรูปแบบการแสดงผล (Presentation) ให้สวยขึ้นแบบ Airbnb-inspired โดย **Logic ทั้งหมดต้องทำงานเหมือนเดิม 100%**

### 1.2 Reference Design (ดูภาพประกอบ)
ไฟล์ภาพ reference อยู่ที่:
```
C:\Users\ASUS\.cursor\projects\c-aiprogram-miro\assets\c__Users_ASUS_AppData_Roaming_Cursor_User_workspaceStorage_b66bc50cb66eb56c685c69efd0b27937_images_image-289f7f95-8e81-443f-a551-d0ec95caadab.png
```

### 1.3 สรุปสิ่งที่เปลี่ยน

| หัวข้อ | ก่อน (ปัจจุบัน) | หลัง (Redesign) |
|--------|-----------------|-----------------|
| สี Primary | Indigo `#6366F1` | Teal/Green `#2D8B75` |
| DailySummaryCard | Gradient amber + Linear progress bar | พื้นขาว + Circular Progress Ring |
| Food Timeline | Vertical list (SliverList) | Horizontal scroll + รูปวงกลม |
| Navigation | TabBar ด้านบน (Timeline/Diet/My Meal) + FABs | BottomNavigationBar 4 tab |
| Card style | Border + flat (elevation 0) | Soft shadow + rounded 16px |
| AppBar | "MIRO" center, Indigo style | Minimal, left-aligned title |

### 1.4 สิ่งที่ไม่เปลี่ยน (สำคัญมาก)
- Riverpod Providers ทั้งหมด
- Isar Database / Models
- AI Analysis flow (Gemini)
- Bottom Sheets ทั้ง 5 ตัว (food detail, edit, analyze, create meal, log from meal)
- Camera / Scanner / Barcode
- Energy token system
- In-app purchase
- Localization (TH/EN)
- Pull-to-refresh / Auto-scan logic

---

## 2. สถาปัตยกรรมปัจจุบัน

### 2.1 โครงสร้างไฟล์ที่เกี่ยวข้อง (เฉพาะไฟล์ที่ต้องแก้)

```
lib/
├── core/theme/
│   ├── app_colors.dart          ← [Phase 1] เปลี่ยน color palette
│   └── app_theme.dart           ← [Phase 1] เปลี่ยน card, text, appbar theme
│
├── features/home/
│   ├── presentation/
│   │   └── home_screen.dart     ← [Phase 4] เพิ่ม BottomNavigationBar
│   └── widgets/
│       ├── magic_button.dart    ← [Phase 4] ย้ายเข้า BottomNav
│       └── feature_tour.dart    ← [Phase 4] อัพเดท GlobalKey targets
│
├── features/health/
│   ├── presentation/
│   │   ├── health_page.dart             ← [Phase 4] ลบ TabBar, ปรับโครงสร้าง
│   │   ├── health_timeline_tab.dart     ← [Phase 3] เปลี่ยน layout เป็น horizontal
│   │   ├── health_diet_tab.dart         ← [Phase 4] ย้ายเป็น tab ใน BottomNav
│   │   └── health_my_meal_tab.dart      ← [Phase 4] ย้ายเป็น tab ใน BottomNav
│   └── widgets/
│       ├── daily_summary_card.dart      ← [Phase 2] Redesign เป็น circular progress
│       ├── food_timeline_card.dart      ← [Phase 3] Redesign เป็น circular avatar
│       ├── quick_add_section.dart       ← [Phase 5] Redesign เป็น card section
│       ├── meal_section.dart            ← [Phase 5] ปรับ style ให้สอดคล้อง
│       └── date_navigation_bar.dart     ← [Phase 5] ปรับ style (ถ้าใช้)
│
└── features/profile/
    └── presentation/
        └── profile_screen.dart          ← [Phase 4] เป็น tab ใน BottomNav
```

### 2.2 Flow การทำงานปัจจุบัน (ห้ามเปลี่ยน)

```
main.dart → OnboardingScreen (ครั้งแรก) → HomeScreen
                                              │
                                              ├── AppBar: [EnergyBadge] MIRO [Profile]
                                              │
                                              ├── Body: HealthPage
                                              │         ├── TabBar: Timeline | Diet | My Meal
                                              │         └── TabBarView:
                                              │             ├── HealthTimelineTab
                                              │             │   ├── UpsellBanner
                                              │             │   ├── DailySummaryCard
                                              │             │   ├── DateSelector
                                              │             │   ├── QuickAddSection
                                              │             │   └── FoodTimelineCard (SliverList)
                                              │             ├── HealthDietTab
                                              │             │   ├── DailySummaryCard
                                              │             │   ├── DateSelector
                                              │             │   └── MealSection × 4 (B/L/D/S)
                                              │             └── HealthMyMealTab
                                              │                 ├── SubTab: My Meals | Ingredients
                                              │                 └── List of meals/ingredients
                                              │
                                              └── FABs: [Camera] [MagicButton(Chat)]
```

### 2.3 State Management (ห้ามเปลี่ยน)
- ใช้ **Riverpod** ทั้งหมด
- Providers อยู่ใน `lib/features/*/providers/`
- ไม่ต้องแก้ไฟล์ provider ใดๆ
- Widget ต้องยังคงเป็น `ConsumerWidget` / `ConsumerStatefulWidget`

---

## 3. Phase 1: Theme & Color System

> **ระยะเวลา:** ครึ่งวัน  
> **ความยาก:** ง่าย  
> **ไฟล์ที่แก้:** 2 ไฟล์  
> **มอบหมายให้:** Junior ได้

### 3.1 แก้ไขไฟล์: `lib/core/theme/app_colors.dart`

**สิ่งที่ต้องทำ:**

เปลี่ยน primary color จาก Indigo เป็น Teal/Green ตามภาพ reference

```dart
// ===== ก่อน =====
static const Color primary = Color(0xFF6366F1);      // Indigo-500
static const Color primaryLight = Color(0xFFA5B4FC); // Indigo-300
static const Color primaryDark = Color(0xFF4F46E5);  // Indigo-600

// ===== หลัง =====
static const Color primary = Color(0xFF2D8B75);      // Teal-600 (สีหลักจากภาพ reference)
static const Color primaryLight = Color(0xFF5BB5A2); // Teal-400
static const Color primaryDark = Color(0xFF1F6F5C);  // Teal-700
```

**หมายเหตุ:**
- สี `health`, `protein`, `carbs`, `fat` → **ไม่ต้องเปลี่ยน** (ใช้งานใน chart/macro ที่ไม่เกี่ยว)
- สี `success`, `warning`, `error` → **ไม่ต้องเปลี่ยน**
- สี `background`, `surface`, `textPrimary` → **ไม่ต้องเปลี่ยน** (ขาว/เทาเข้ากับ design ใหม่อยู่แล้ว)

### 3.2 แก้ไขไฟล์: `lib/core/theme/app_theme.dart`

**สิ่งที่ต้องทำ (Light Theme):**

#### 3.2.1 เปลี่ยน AppBar style
```dart
// ===== ก่อน =====
appBarTheme: const AppBarTheme(
  backgroundColor: AppColors.surface,
  foregroundColor: AppColors.textPrimary,
  elevation: 0,
  centerTitle: true,   // ← ตรงกลาง
),

// ===== หลัง =====
appBarTheme: const AppBarTheme(
  backgroundColor: AppColors.background,  // ← เปลี่ยนเป็นสีพื้นหลัง (ไม่ใช่ขาว)
  foregroundColor: AppColors.textPrimary,
  elevation: 0,
  centerTitle: false,  // ← ชิดซ้ายแบบ Airbnb
  titleTextStyle: TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  ),
),
```

#### 3.2.2 เปลี่ยน Card style
```dart
// ===== ก่อน =====
cardTheme: CardThemeData(
  color: AppColors.surface,
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: const BorderSide(color: AppColors.divider),  // ← มี border
  ),
),

// ===== หลัง =====
cardTheme: CardThemeData(
  color: AppColors.surface,
  elevation: 1,                          // ← เพิ่ม shadow เล็กน้อย
  shadowColor: Colors.black.withOpacity(0.08),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),  // ← มนขึ้น
    // ลบ border ออก — ใช้ shadow แทน
  ),
),
```

#### 3.2.3 เพิ่ม headline ขนาดใหญ่ขึ้น
```dart
// เพิ่ม/แก้ใน textTheme
headlineLarge: TextStyle(
  fontSize: 28,              // ← เพิ่มจาก 24
  fontWeight: FontWeight.w800,  // ← หนาขึ้น
  color: AppColors.textPrimary,
),
```

#### 3.2.4 อย่าลืมแก้ Dark Theme ด้วย
- `appBarTheme` → `centerTitle: false` เหมือนกัน
- `cardTheme` → `borderRadius: 16`, `elevation: 1`
- ทุกอย่างที่แก้ใน light ต้องแก้ใน dark ด้วย (ยกเว้นสี)

### 3.3 Checklist Phase 1
- [ ] เปลี่ยน primary colors ใน `app_colors.dart`
- [ ] เปลี่ยน AppBar theme (centerTitle: false, background สีพื้นหลัง)
- [ ] เปลี่ยน Card theme (shadow แทน border, borderRadius 16)
- [ ] เพิ่ม headline ขนาดใหญ่ขึ้น
- [ ] แก้ Dark Theme ให้สอดคล้อง
- [ ] ทดสอบ: เปิดแอป ดูว่าสีเปลี่ยนทั้งแอป, card มี shadow, AppBar ชิดซ้าย
- [ ] ทดสอบ: สลับ dark mode ดูว่าไม่แตก

---

## 4. Phase 2: DailySummaryCard Redesign

> **ระยะเวลา:** 1 วัน  
> **ความยาก:** ปานกลาง  
> **ไฟล์ที่แก้:** 1 ไฟล์  
> **มอบหมายให้:** Junior ได้ (แต่ Senior ควรตรวจ CustomPainter/layout)

### 4.1 แก้ไขไฟล์: `lib/features/health/widgets/daily_summary_card.dart`

**สถานะปัจจุบัน:**
- Container + gradient amber background
- Linear progress bar แสดง calories
- Macro items เป็นวงกลมเล็กๆ (P/C/F)
- ปุ่ม "View Details" ด้านล่าง
- เป็น `ConsumerWidget` ใช้ `foodEntriesByDateProvider` + `profileNotifierProvider`

**เปลี่ยนเป็น:**

```
┌─────────────────────────────────────────┐
│                                          │
│  Today's Intake          ┌──────────┐   │
│  Subtitle info           │  1200    │   │
│                          │ /1800 kcal│   │
│                          │ (วงกลม)  │   │
│                          └──────────┘   │
│                                          │
│  ┌──────┐ ┌──────┐ ┌──────┐            │
│  │ P:80g│ │C:200g│ │ F:50g│            │
│  └──────┘ └──────┘ └──────┘            │
│                                          │
└─────────────────────────────────────────┘
```

### 4.2 โค้ดแนวทาง (Pseudo-code)

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  // ... เดิม: watch providers เหมือนเดิม 100%
  
  return Container(
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,                    // ← เปลี่ยนจาก gradient
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          children: [
            // ===== ฝั่งซ้าย: Title + Subtitle =====
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Today's Intake",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                  SizedBox(height: 4),
                  Text("subtitle...",
                    style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            ),
            // ===== ฝั่งขวา: Circular Progress =====
            SizedBox(
              width: 80, height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: percent,            // ← ค่าเดิมจาก provider
                    strokeWidth: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${calories.toInt()}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text('/ ${goal.toInt()} kcal',
                        style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        // ===== Macros Row =====
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMacroItem(label: 'Protein', value: protein, goal: proteinGoal, color: AppColors.protein),
            _buildMacroItem(label: 'Carbs', value: carbs, goal: carbGoal, color: AppColors.carbs),
            _buildMacroItem(label: 'Fat', value: fat, goal: fatGoal, color: AppColors.fat),
          ],
        ),
      ],
    ),
  );
}
```

### 4.3 สิ่งที่ต้องคงไว้ (สำคัญมาก)
- **Provider ต้องเหมือนเดิม:** `ref.watch(foodEntriesByDateProvider(date))` และ `ref.watch(profileNotifierProvider)`
- **การคำนวณ calories, protein, carbs, fat, percent** → ไม่ต้องแก้
- **GestureDetector / onTap** ที่ navigate ไป `TodaySummaryDashboardScreen` → คงไว้ (อาจย้ายเป็น tap ที่ card ทั้งใบ)
- **`_isToday()` function** → คงไว้

### 4.4 Checklist Phase 2
- [ ] เปลี่ยน Container decoration จาก gradient → ขาว + shadow
- [ ] เพิ่ม Row: title ซ้าย + circular progress ขวา
- [ ] Circular Progress ใช้ค่า `percent` เดิม
- [ ] Macro Row ด้านล่าง (P/C/F) ปรับ style ให้เข้ากับ design ใหม่
- [ ] คง navigation ไป TodaySummaryDashboardScreen
- [ ] ทดสอบ: Dark mode ต้องไม่แตก
- [ ] ทดสอบ: selectedDate เปลี่ยนวันแล้ว data ต้อง update
- [ ] ทดสอบ: เมื่อ goal = 0 ไม่ crash (division by zero)

---

## 5. Phase 3: Horizontal Meal Timeline

> **ระยะเวลา:** 1.5 วัน  
> **ความยาก:** ปานกลาง-ยาก  
> **ไฟล์ที่แก้:** 2 ไฟล์  
> **มอบหมายให้:** Junior ที่มีประสบการณ์ Flutter / Senior ควรช่วย review

### 5.1 เป้าหมาย
เปลี่ยน food entries จาก vertical list → horizontal scrollable cards ใน container card

```
┌─────────────────────────────────────────┐
│  Meals                                   │
│                                          │
│  ┌─────┐  ┌─────┐  ┌─────┐  ┌─────┐   │
│  │(รูป)│  │(รูป)│  │(รูป)│  │(รูป)│→  │
│  │วงกลม│  │วงกลม│  │วงกลม│  │วงกลม│   │
│  └─────┘  └─────┘  └─────┘  └─────┘   │
│   ข้าวผัด   ส้มตำ    สลัด    กาแฟ     │
│   350 kcal  200 kcal 150 kcal 80 kcal  │
│                                          │
└─────────────────────────────────────────┘
```

### 5.2 แก้ไขไฟล์: `lib/features/health/presentation/health_timeline_tab.dart`

**ส่วนที่ต้องเปลี่ยน (เฉพาะ build method):**

ปัจจุบันใน `CustomScrollView.slivers` มี `SliverList` ที่ render `FoodTimelineCard` แบบ vertical:

```dart
// ===== ก่อน (บรรทัด 100-118) =====
return SliverList(
  delegate: SliverChildBuilderDelegate(
    (context, index) {
      final item = items[index];
      if (item.type == 'food') {
        return FoodTimelineCard(
          entry: item.data as FoodEntry,
          onTap: () => _showFoodDetail(item.data),
          // ...
        );
      }
      return const SizedBox();
    },
    childCount: items.length,
  ),
);

// ===== หลัง =====
return SliverToBoxAdapter(
  child: _buildMealsHorizontalCard(items),
);
```

**เพิ่ม method ใหม่:**

```dart
Widget _buildMealsHorizontalCard(List<TimelineItem> items) {
  final foodItems = items.where((i) => i.type == 'food').toList();
  if (foodItems.isEmpty) return const SizedBox();

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [ /* soft shadow */ ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text('Meals', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        // Horizontal scroll
        SizedBox(
          height: 130,  // ความสูงคงที่
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: foodItems.length,
            itemBuilder: (context, index) {
              final entry = foodItems[index].data as FoodEntry;
              return _buildHorizontalFoodItem(entry);
            },
          ),
        ),
      ],
    ),
  );
}

Widget _buildHorizontalFoodItem(FoodEntry entry) {
  return GestureDetector(
    onTap: () => _showFoodDetail(entry),         // ← logic เดิม 100%
    onLongPress: () => _editFoodEntry(entry),     // ← logic เดิม 100%
    child: Container(
      width: 85,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          // รูปวงกลม
          CircleAvatar(
            radius: 35,
            backgroundColor: AppColors.health.withOpacity(0.1),
            backgroundImage: entry.imagePath != null
                ? FileImage(File(entry.imagePath!))
                : null,
            child: entry.imagePath == null
                ? Icon(Icons.restaurant, color: AppColors.health)
                : null,
          ),
          SizedBox(height: 8),
          // ชื่ออาหาร
          Text(
            entry.foodName,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          // แคลอรี่
          Text(
            '${entry.calories.toInt()} kcal',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    ),
  );
}
```

### 5.3 สิ่งที่ต้องคงไว้ (สำคัญมาก)

| ฟังก์ชัน | ทำหน้าที่ | ห้ามแก้ |
|----------|----------|---------|
| `_showFoodDetail(entry)` | เปิด FoodDetailBottomSheet | ห้ามแก้ logic ข้างใน |
| `_editFoodEntry(entry)` | เปิด EditFoodBottomSheet | ห้ามแก้ logic ข้างใน |
| `_analyzeFoodWithGemini(entry)` | วิเคราะห์ด้วย AI | ห้ามแก้ logic ข้างใน |
| `_deleteFoodEntry(entry)` | ลบ entry | ห้ามแก้ logic ข้างใน |
| `_showAnalyzeConfirmation(entry)` | Dialog ยืนยันก่อนวิเคราะห์ | ห้ามแก้ logic ข้างใน |
| `RefreshIndicator` + `onRefresh` | Pull-to-refresh + auto-scan | ห้ามแก้ |
| `_buildUpsellBanner()` | แสดง AI usage banner | ย้ายตำแหน่งได้ แต่ห้ามแก้ logic |
| `_buildDateSelector()` | เลือกวันที่ | ปรับ style ได้ แต่ห้ามแก้ logic |
| `_buildEmptyState()` | แสดงเมื่อไม่มี data | ปรับ style ได้ แต่ห้ามแก้ logic |

### 5.4 แก้ไขไฟล์: `lib/features/health/widgets/food_timeline_card.dart`

ไฟล์นี้ยังคงใช้ได้ใน **Diet tab** (ที่แสดงรายละเอียดเต็ม) แต่สำหรับ Timeline tab จะใช้ horizontal item แทน

**ทางเลือก 2 แบบ:**

**แบบ A (แนะนำ):** ไม่แก้ `FoodTimelineCard` เลย — ยังใช้อยู่ใน Diet tab ปกติ เพิ่ม `_buildHorizontalFoodItem()` เป็น method ใน `health_timeline_tab.dart` แทน

**แบบ B:** สร้างไฟล์ใหม่ `food_horizontal_item.dart` เป็น widget แยก — ดีกว่าถ้าจะ reuse ที่อื่น

**เลือกแบบ A** เพราะ simple กว่า และไม่ต้อง import เพิ่ม

### 5.5 ข้อควรระวัง Phase 3

1. **FileImage ต้อง check ก่อน:** `entry.imagePath != null && File(entry.imagePath!).existsSync()` — เพราะรูปอาจถูกลบจาก gallery แล้ว
2. **CircleAvatar + FileImage error:** ใส่ `onError` callback ไว้ด้วย เผื่อไฟล์เสีย
3. **Empty state:** ถ้าไม่มี food items ต้องแสดง empty state เดิม (อย่าแสดง card ว่าง)
4. **Performance:** ถ้ามี entry เยอะ (>20) horizontal scroll อาจช้า → ใช้ `ListView.builder` (ไม่ใช่ `ListView(children: [])`)

### 5.6 Checklist Phase 3
- [ ] เปลี่ยน SliverList → SliverToBoxAdapter + horizontal card
- [ ] แต่ละ item เป็น CircleAvatar + ชื่อ + แคลอรี่
- [ ] Tap → `_showFoodDetail()` ทำงานปกติ
- [ ] Long press → มี option edit/delete
- [ ] Empty state ยังแสดงถูกต้อง
- [ ] Pull-to-refresh ยังทำงาน
- [ ] DateSelector เปลี่ยนวันแล้ว data update
- [ ] รูปที่ไม่มี → แสดง placeholder icon
- [ ] Dark mode ไม่แตก
- [ ] ทดสอบ: scroll ซ้ายขวาเมื่อมี entry > 5 รายการ

---

## 6. Phase 4: Bottom Navigation Bar

> **ระยะเวลา:** 1 วัน  
> **ความยาก:** ปานกลาง (restructure navigation)  
> **ไฟล์ที่แก้:** 3-4 ไฟล์  
> **มอบหมายให้:** Senior ควรทำเอง หรือ pair กับ Junior

### 6.1 เป้าหมาย

```
┌──────────────────────────────────┐
│  AppBar: [Energy]  Today's...    │
├──────────────────────────────────┤
│                                   │
│  Body (เปลี่ยนตาม tab ที่เลือก)  │
│                                   │
├──────────────────────────────────┤
│ 🏠        📊       ➕       👤   │
│Dashboard  Diet   Log Food  Profile│
└──────────────────────────────────┘
```

**Mapping:**

| BottomNav Tab | Content เดิม | มาจากไหน |
|---------------|-------------|----------|
| Dashboard | HealthTimelineTab (redesigned) | เดิมคือ tab "Timeline" |
| Diet | HealthDietTab (ปรับ style) | เดิมคือ tab "Diet" |
| Log Food (+) | เปิด bottom sheet เลือก: Camera / Chat / Manual | เดิมคือ FABs (Camera + MagicButton) |
| Profile | ProfileScreen (embed) | เดิมคือ navigate ไป ProfileScreen |

**หมายเหตุ: My Meal tab** → ย้ายไปอยู่ใน Diet tab หรือ Profile tab (เป็น section / button ที่ navigate ไป)

### 6.2 แก้ไขไฟล์: `lib/features/home/presentation/home_screen.dart`

**โครงสร้างใหม่:**

```dart
class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  // Pages สำหรับแต่ละ tab
  // ใช้ IndexedStack เพื่อ keep state ของแต่ละ tab
  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      HealthTimelineTab(),     // Dashboard (index 0)
      HealthDietTab(),         // Diet (index 1)
      const SizedBox(),        // Placeholder สำหรับ Log Food (index 2) — ไม่ใช้จริง
      const ProfileScreen(),   // Profile (index 3)
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _currentIndex == 2 ? 0 : _currentIndex,  // Log Food ไม่มีหน้า
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNav(),
      // ลบ floatingActionButton ออก
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
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
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.pie_chart_outline), activeIcon: Icon(Icons.pie_chart), label: 'Diet'),
        BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline, size: 32), label: 'Log Food'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }

  void _showLogFoodSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _openCamera();   // ← logic เดิมจาก FAB camera
              },
            ),
            ListTile(
              leading: Icon(Icons.auto_awesome),
              title: Text('Chat with AI'),
              onTap: () {
                Navigator.pop(context);
                _openChat();     // ← logic เดิมจาก MagicButton
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

### 6.3 แก้ไขไฟล์: `lib/features/health/presentation/health_page.dart`

**ทางเลือก 2 แบบ:**

**แบบ A (แนะนำ):** ลบ `HealthPage` ออก — ไม่จำเป็นแล้ว เพราะ `HomeScreen` จัดการ tabs เองผ่าน `BottomNavigationBar` + `IndexedStack`

**แบบ B:** คง `HealthPage` ไว้แต่ลบ `TabBar` ออก — ทำเป็น wrapper ธรรมดา

**เลือกแบบ A** — แต่ต้อง update import ทุกที่ที่อ้างถึง `HealthPage`

### 6.4 จัดการ My Meal Tab

`HealthMyMealTab` ย้ายไปเข้าถึงจาก:
- **Option 1 (แนะนำ):** เพิ่มปุ่ม "My Meals" ใน `HealthDietTab` ด้านล่างสุด → navigate ไปหน้า My Meal
- **Option 2:** เพิ่มเป็น menu item ใน `ProfileScreen`

### 6.5 จัดการ Feature Tour

ไฟล์ `lib/features/home/widgets/feature_tour.dart` ใช้ `GlobalKey` ชี้ไปที่:
1. `_energyBadgeKey` → Energy Badge (ยังอยู่ใน AppBar)
2. `_timelineAreaKey` → Timeline area (เปลี่ยนจาก HealthPage → HealthTimelineTab)
3. `_magicButtonKey` → Magic Button (ย้ายไป BottomNav "Log Food")

**ต้องอัพเดท GlobalKey targets:**
- `_magicButtonKey` → ชี้ไปที่ BottomNavigationBar item "Log Food" แทน
- หรือชี้ไปที่ widget อื่นที่เหมาะสม

### 6.6 จัดการ AppBar ใหม่

```dart
PreferredSizeWidget _buildAppBar() {
  // Dashboard tab → แสดง title + energy badge
  // Diet tab → แสดง "Diet"
  // Profile tab → แสดง "Profile & Settings"
  
  String title;
  switch (_currentIndex) {
    case 0: title = "Today's Intake"; break;
    case 1: title = 'Diet'; break;
    case 3: title = 'Profile'; break;
    default: title = 'MIRO';
  }
  
  return AppBar(
    title: Text(title),
    leading: Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: const Center(child: EnergyBadgeRiverpod()),
    ),
    leadingWidth: 80,
    // ลบ actions ออก (Profile ย้ายไป BottomNav แล้ว)
  );
}
```

### 6.7 Checklist Phase 4
- [ ] เพิ่ม BottomNavigationBar ใน HomeScreen
- [ ] ใช้ IndexedStack สำหรับ 3 หน้า (Dashboard, Diet, Profile)
- [ ] Log Food tab → เปิด bottom sheet (Camera / Chat)
- [ ] ลบ FABs (Camera + MagicButton) ออกจาก HomeScreen
- [ ] ลบหรือ simplify HealthPage (ลบ TabBar)
- [ ] ย้าย My Meal → เข้าถึงจาก Diet tab หรือ Profile
- [ ] อัพเดท Feature Tour GlobalKey targets
- [ ] อัพเดท AppBar ตาม tab ที่เลือก
- [ ] ทดสอบ: switch tab แล้ว state ไม่หาย (IndexedStack)
- [ ] ทดสอบ: Log Food → Camera → ถ่ายรูป → กลับมา → data update
- [ ] ทดสอบ: Log Food → Chat → พิมพ์อาหาร → กลับมา → data update
- [ ] ทดสอบ: Profile settings ยังทำงานปกติ
- [ ] ทดสอบ: Feature Tour ยังแสดงถูกต้อง
- [ ] ทดสอบ: Deep link / navigation ไม่ broken

---

## 7. Phase 5: Card Sections & Polish

> **ระยะเวลา:** ครึ่งวัน  
> **ความยาก:** ง่าย  
> **ไฟล์ที่แก้:** 2-3 ไฟล์  
> **มอบหมายให้:** Junior ได้

### 7.1 แก้ไข: `quick_add_section.dart`

เปลี่ยนจาก expandable chips → Card section สไตล์เดียวกับ Meals card

```
┌─────────────────────────────────────────┐
│  Quick Add                      ▼ ▲    │
│                                          │
│  🔄 Same as Yesterday (1800 kcal)       │
│  ⚡ ข้าวผัด (350)  ⚡ ส้มตำ (200)       │
│                                          │
└─────────────────────────────────────────┘
```

**สิ่งที่ต้องทำ:**
- ครอบ Container เดิมด้วย Card (borderRadius 16, shadow)
- เปลี่ยนสี header ให้เข้ากับ design ใหม่
- **Logic ข้างใน (expand/collapse, quick add, repeat) → ห้ามแก้**

### 7.2 แก้ไข: `meal_section.dart` (ใช้ใน Diet tab)

ปรับ style ให้สอดคล้อง:
- Card สไตล์ใหม่ (shadow แทน border)
- Header row ปรับ typography
- **Logic (onAddFood, onEditFood, onDeleteFood) → ห้ามแก้**

### 7.3 แก้ไข: `date_navigation_bar.dart` (ถ้าใช้)

ปัจจุบัน Timeline tab ใช้ `_buildDateSelector()` ไม่ได้ใช้ `DateNavigationBar` widget โดยตรง
ถ้าต้องการ unify ก็สามารถปรับ `DateNavigationBar` แล้วใช้แทน `_buildDateSelector()` ได้

### 7.4 Polish ทั่วไป
- ตรวจสอบ spacing ทั้งแอป (ควรใช้ 16px เป็น base margin)
- ตรวจสอบ border radius (ใช้ 16px เป็น standard)
- ตรวจสอบ shadow consistency (ทุก card ใช้ shadow เดียวกัน)
- ตรวจ Upsell Banner → ปรับ style ให้เข้ากับ design ใหม่

### 7.5 Checklist Phase 5
- [ ] Quick Add Section → Card style ใหม่
- [ ] Meal Section → Card style ใหม่
- [ ] Upsell Banner → ปรับ style
- [ ] ตรวจ spacing/border-radius/shadow consistency
- [ ] ทดสอบ: Quick Add tap → บันทึกสำเร็จ
- [ ] ทดสอบ: Repeat Yesterday → คัดลอกสำเร็จ
- [ ] ทดสอบ: Diet tab → Meal Sections แสดงถูกต้อง
- [ ] ทดสอบ: Dark mode ทุกหน้า

---

## 8. กฎเหล็ก: สิ่งที่ห้ามแก้

### 8.1 ไฟล์ที่ห้ามแตะ

```
lib/core/ai/                      ← AI services ทั้ง folder
lib/core/database/                ← Database service
lib/core/models/                  ← Core models
lib/core/services/                ← Core services ทั้งหมด
lib/core/utils/                   ← Utilities ทั้งหมด
lib/core/constants/               ← Constants ทั้งหมด (ยกเว้นถ้าเพิ่ม design constants ใหม่)

lib/features/*/providers/         ← Providers ทั้งหมด (ห้ามแก้แม้แต่ 1 บรรทัด)
lib/features/*/models/            ← Models ทั้งหมด
lib/features/*/services/          ← Services ทั้งหมด
lib/features/camera/              ← Camera feature ทั้ง folder
lib/features/scanner/             ← Scanner feature ทั้ง folder
lib/features/chat/                ← Chat feature ทั้ง folder
lib/features/energy/              ← Energy feature ทั้ง folder
lib/features/onboarding/          ← Onboarding ทั้ง folder
lib/features/legal/               ← Legal screens ทั้ง folder

lib/l10n/                         ← Localization files

pubspec.yaml                      ← ไม่ต้องเพิ่ม dependency ใหม่
```

### 8.2 Logic ที่ห้ามเปลี่ยน

| Logic | อยู่ที่ | เหตุผล |
|-------|--------|--------|
| Pull-to-refresh + auto-scan | `health_timeline_tab.dart` | เป็น core feature |
| AI Analysis flow | `_analyzeFoodWithGemini()` | เชื่อมกับ Gemini API + Energy system |
| Energy checking | `GeminiService.hasEnergy()` | เชื่อมกับ purchase system |
| Quick Add | `quick_add_section.dart` (logic) | เชื่อมกับ providers |
| Repeat Yesterday | `quick_add_section.dart` (logic) | เชื่อมกับ providers |
| Food CRUD | `foodEntriesNotifierProvider` | เชื่อมกับ database |
| Profile settings | `profileNotifierProvider` | เชื่อมกับ database |
| Usage limiter | `UsageLimiter` | เชื่อมกับ IAP |

### 8.3 กฎการทำงาน

1. **ทุกการเปลี่ยนแปลงต้อง commit แยก phase** — ไม่รวม commit
2. **ทุก commit ต้อง build สำเร็จ** — `flutter build apk` ต้องผ่าน
3. **ทุก commit ต้อง test ด้วยมือ** — เปิดแอป กดทุกปุ่ม
4. **ห้าม force push** — ใช้ merge เท่านั้น
5. **Light mode + Dark mode ต้อง test ทุก phase**

---

## 9. Testing Checklist

### 9.1 Smoke Test (ทำหลังทุก Phase)

| # | ทดสอบ | ผลที่คาดหวัง |
|---|-------|-------------|
| 1 | เปิดแอป (first launch) | Onboarding แสดง → Home screen |
| 2 | Feature Tour | แสดงถูกตำแหน่ง ไม่ crash |
| 3 | Pull-to-refresh | Scan gallery + refresh data |
| 4 | เปลี่ยนวันที่ | Data เปลี่ยนตามวัน |
| 5 | Tap food item | FoodDetailBottomSheet เปิด |
| 6 | Edit food | EditFoodBottomSheet เปิด → save สำเร็จ |
| 7 | Delete food | Confirm dialog → ลบสำเร็จ |
| 8 | Analyze with AI | Dialog → Loading → GeminiAnalysisSheet |
| 9 | Camera | ถ่ายรูป → Preview → Save |
| 10 | Chat | เปิด ChatScreen → พิมพ์ข้อความ → AI ตอบ |
| 11 | Quick Add | Tap chip → บันทึกทันที |
| 12 | Energy Badge | แสดงจำนวน + tap → Energy Store |
| 13 | Profile | Settings ทำงานปกติ |
| 14 | Dark mode toggle | UI ไม่แตก ทุกหน้า |
| 15 | Localization | สลับ TH/EN ไม่มีข้อความหาย |

### 9.2 Edge Case Test

| # | ทดสอบ | ผลที่คาดหวัง |
|---|-------|-------------|
| 1 | ไม่มี food entries (วันแรก) | Empty state แสดง |
| 2 | Food entry ไม่มีรูป | Placeholder icon |
| 3 | Food entry รูปถูกลบแล้ว | Placeholder icon (ไม่ crash) |
| 4 | Calorie goal = 0 | ไม่ crash (division by zero) |
| 5 | ชื่ออาหารยาวมาก | Text ellipsis ไม่ overflow |
| 6 | มี entry > 20 รายการ | Horizontal scroll ลื่น |
| 7 | จอขนาดเล็ก (320px wide) | Layout ไม่ overflow |
| 8 | Energy = 0 | NoEnergyDialog แสดง |

---

## 10. ความเสี่ยงและการป้องกัน

### 10.1 ตารางความเสี่ยง

| ความเสี่ยง | โอกาส | ผลกระทบ | การป้องกัน |
|-----------|-------|---------|-----------|
| Dark mode แตก | สูง | UI อ่านไม่ออก | แก้ dark theme ทุกครั้งที่แก้ light |
| Layout overflow บนจอเล็ก | ปานกลาง | Pixel overflow error | Test บน 320px wide + ใช้ Flexible/Expanded |
| Feature Tour ชี้ผิดตำแหน่ง | ปานกลาง | Tour วนไม่จบ หรือ crash | อัพเดท GlobalKey หลัง restructure navigation |
| IndexedStack กิน memory | ต่ำ | App ช้า | มี 3 pages เท่านั้น ไม่มีปัญหา |
| FileImage crash (ไฟล์ไม่มี) | ปานกลาง | Red error screen | เช็ค `File.existsSync()` ก่อนสร้าง FileImage |
| BottomSheet context error | ต่ำ | Sheet ไม่เปิด/crash | ตรวจ `mounted` / `context.mounted` ก่อน navigate |
| Git conflict กับ branch อื่น | ต่ำ | Merge ยาก | ทำบน branch แยก หลัง merge Android 15 fix |

### 10.2 แผนสำรอง
- ถ้า Phase 4 (BottomNav) ซับซ้อนเกินไป → skip ได้ ทำแค่ Phase 1-3 + 5 ก็ได้ผลลัพธ์ที่ดีแล้ว (UI สวยขึ้นมาก โดยยังคง TabBar เดิม)
- ถ้า Horizontal Timeline มีปัญหา performance → fallback กลับเป็น vertical list แต่ใช้ card style ใหม่

---

## Appendix A: ลำดับ Commit ที่แนะนำ

```bash
# 1. สร้าง branch ใหม่ (หลัง merge Android 15 fix เข้า main แล้ว)
git checkout main
git pull
git checkout -b feature/airbnb-redesign

# 2. Phase 1
# แก้ app_colors.dart + app_theme.dart
git add lib/core/theme/
git commit -m "style: update color palette and theme to Airbnb-inspired design"

# 3. Phase 2
# แก้ daily_summary_card.dart
git add lib/features/health/widgets/daily_summary_card.dart
git commit -m "style: redesign DailySummaryCard with circular progress ring"

# 4. Phase 3
# แก้ health_timeline_tab.dart (+ อาจสร้าง food_horizontal_item.dart)
git add lib/features/health/
git commit -m "style: change timeline to horizontal scrollable meal cards"

# 5. Phase 4
# แก้ home_screen.dart, health_page.dart, feature_tour.dart
git add lib/features/home/ lib/features/health/presentation/health_page.dart
git commit -m "feat: replace TabBar with BottomNavigationBar"

# 6. Phase 5
# แก้ quick_add_section.dart, meal_section.dart
git add lib/features/health/widgets/
git commit -m "style: polish card sections and spacing consistency"
```

---

## Appendix B: สรุปสำหรับ Senior

| Phase | มอบหมาย | ระยะเวลา | Dependency |
|-------|---------|---------|------------|
| 1. Theme | Junior | 0.5 วัน | ไม่มี |
| 2. Summary Card | Junior (Senior review) | 1 วัน | Phase 1 |
| 3. Horizontal Timeline | Junior + Senior | 1.5 วัน | Phase 1 |
| 4. Bottom Nav | Senior (หรือ pair) | 1 วัน | Phase 1, 3 |
| 5. Polish | Junior | 0.5 วัน | Phase 1, 4 |

**Phase 1-3 ทำ parallel ได้** (คนละไฟล์) ถ้ามี Junior 2 คน:
- Junior A: Phase 1 → Phase 5
- Junior B: Phase 2 → Phase 3
- Senior: Phase 4 (หลัง Phase 1+3 เสร็จ)

**Timeline สั้นสุด: 2.5 วัน** (ถ้าทำ parallel)

---

*จัดทำโดย AI Assistant — 17 กุมภาพันธ์ 2026*
