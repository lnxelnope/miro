# TASK 3: เปลี่ยน Timeline เป็น Horizontal Scroll

> **ระยะเวลา:** 1.5 วัน (12 ชั่วโมง)  
> **ความยาก:** ⭐⭐⭐ ปานกลาง-ยาก  
> **Dependency:** ต้องทำ TASK_1 ก่อน

## 🎯 เป้าหมาย

เปลี่ยน food entries จาก vertical list → horizontal scrollable cards ใน container card

### Before (Vertical List)
```
┌────────────────┐
│ ┌────────────┐ │
│ │ รูป  ข้าวผัด│ │
│ │      350 kcal│ │
│ └────────────┘ │
│ ┌────────────┐ │
│ │ รูป  ส้มตำ  │ │
│ │      200 kcal│ │
│ └────────────┘ │
│ ┌────────────┐ │
│ │ รูป  สลัด   │ │
│ │      150 kcal│ │
│ └────────────┘ │
└────────────────┘
```

### After (Horizontal Scroll)
```
┌──────────────────────────────────────────┐
│  Meals                                    │
│  ┌───┐  ┌───┐  ┌───┐  ┌───┐  ┌───┐  →  │
│  │(○)│  │(○)│  │(○)│  │(○)│  │(○)│      │
│  └───┘  └───┘  └───┘  └───┘  └───┘      │
│  ข้าวผัด ส้มตำ  สลัด  กาแฟ  ไก่ย่าง      │
│  350    200   150    80    250          │
└──────────────────────────────────────────┘
```

## 📁 ไฟล์ที่ต้องแก้

`lib/features/health/presentation/health_timeline_tab.dart` (1 ไฟล์เดียว)

**หมายเหตุ:** `food_timeline_card.dart` **ไม่ต้องแก้** (ยังใช้ใน Diet tab)

---

## ⚠️ กฎสำคัญ - ห้ามแก้

### ✅ ที่แก้ได้
- เปลี่ยน `SliverList` → `SliverToBoxAdapter`
- เพิ่ม method ใหม่ `_buildMealsHorizontalCard()`
- เพิ่ม method ใหม่ `_buildHorizontalFoodItem()`
- Layout (Row, Column, Container)

### ❌ ห้ามแก้
- `_showFoodDetail(entry)` → ห้ามแก้ logic
- `_editFoodEntry(entry)` → ห้ามแก้ logic
- `_analyzeFoodWithGemini(entry)` → ห้ามแก้ logic
- `_deleteFoodEntry(entry)` → ห้ามแก้ logic
- `RefreshIndicator` + `onRefresh` → ห้ามแก้
- `_buildUpsellBanner()` → ห้ามแก้ logic (ย้ายตำแหน่งได้)
- `_buildDateSelector()` → ห้ามแก้ logic (ปรับ style ได้)
- `_buildEmptyState()` → ห้ามแก้ logic
- Providers ทั้งหมด → ห้ามแก้

---

## ขั้นตอนที่ 1: อ่านโค้ดเดิมให้เข้าใจ

### 1.1 เปิดไฟล์
```
lib/features/health/presentation/health_timeline_tab.dart
```

### 1.2 ดู structure
- ไฟล์ยาว 832 บรรทัด
- `build()` method (บรรทัด 42-129)
- มี `CustomScrollView` + `slivers`
- มี `SliverList` สำหรับ food items (บรรทัด 100-118)

---

## ขั้นตอนที่ 2: เปลี่ยน SliverList เป็น SliverToBoxAdapter

### 2.1 หา SliverList (บรรทัดที่ 86-120 ในส่วน `timelineAsync.when()`)

**Before:**
```dart
timelineAsync.when(
  loading: () => const SliverFillRemaining(
    child: Center(child: CircularProgressIndicator()),
  ),
  error: (e, st) => SliverFillRemaining(
    child: Center(child: Text('Error: $e')),
  ),
  data: (items) {
    if (items.isEmpty) {
      return SliverFillRemaining(
        child: _buildEmptyState(),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = items[index];

          if (item.type == 'food') {
            return FoodTimelineCard(
              entry: item.data as FoodEntry,
              onTap: () => _showFoodDetail(item.data),
              onEdit: () => _editFoodEntry(item.data),
              onAnalyze: () => _analyzeFoodWithGemini(item.data),
              onDelete: () => _deleteFoodEntry(item.data),
            );
          }
          return const SizedBox();
        },
        childCount: items.length,
      ),
    );
  },
),
```

**After:**
```dart
timelineAsync.when(
  loading: () => const SliverFillRemaining(
    child: Center(child: CircularProgressIndicator()),
  ),
  error: (e, st) => SliverFillRemaining(
    child: Center(child: Text('Error: $e')),
  ),
  data: (items) {
    if (items.isEmpty) {
      return SliverFillRemaining(
        child: _buildEmptyState(),
      );
    }

    return SliverToBoxAdapter(
      child: _buildMealsHorizontalCard(items),
    );
  },
),
```

---

## ขั้นตอนที่ 3: เพิ่ม method _buildMealsHorizontalCard()

### 3.1 เพิ่มใต้ method `_buildEmptyState()` (ประมาณบรรทัด 292)

```dart
/// Build horizontal scrollable meals card
Widget _buildMealsHorizontalCard(List<TimelineItem> items) {
  // Filter เฉพาะ food items
  final foodItems = items.where((i) => i.type == 'food').toList();
  if (foodItems.isEmpty) return const SizedBox();

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Row(
          children: [
            Text(
              'Meals',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.health.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${foodItems.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.health,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Horizontal scroll
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: foodItems.length,
            physics: const BouncingScrollPhysics(),
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
```

---

## ขั้นตอนที่ 4: เพิ่ม method _buildHorizontalFoodItem()

### 4.1 เพิ่มต่อจาก method ที่ 3.1

```dart
/// Build single food item for horizontal scroll
Widget _buildHorizontalFoodItem(FoodEntry entry) {
  return GestureDetector(
    onTap: () => _showFoodDetail(entry),
    onLongPress: () {
      // Show bottom sheet with edit/delete options
      showModalBottomSheet(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: AppColors.primary),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _editFoodEntry(entry);
                },
              ),
              if (entry.imagePath != null || !entry.isVerified)
                ListTile(
                  leading: const Icon(Icons.auto_awesome, color: Colors.amber),
                  title: const Text('Analyze with AI'),
                  onTap: () {
                    Navigator.pop(context);
                    _analyzeFoodWithGemini(entry);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteFoodEntry(entry);
                },
              ),
            ],
          ),
        ),
      );
    },
    child: Container(
      width: 90,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // รูปวงกลม
          Stack(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: AppColors.health.withOpacity(0.1),
                backgroundImage: _getImageProvider(entry),
                child: _getImageProvider(entry) == null
                    ? const Icon(
                        Icons.restaurant,
                        color: AppColors.health,
                        size: 28,
                      )
                    : null,
              ),
              // Verified badge
              if (entry.isVerified)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          // ชื่ออาหาร
          Text(
            entry.foodName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          // แคลอรี่
          Text(
            '${entry.calories.toInt()} kcal',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
          // เวลา
          Text(
            _formatTime(entry.timestamp),
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    ),
  );
}

/// Get image provider (with error handling)
ImageProvider? _getImageProvider(FoodEntry entry) {
  if (entry.imagePath == null) return null;
  
  try {
    final file = File(entry.imagePath!);
    if (file.existsSync()) {
      return FileImage(file);
    }
  } catch (e) {
    AppLogger.error('Error loading image', e);
  }
  
  return null;
}

/// Format time (HH:mm)
String _formatTime(DateTime time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
```

---

## ขั้นตอนที่ 5: เพิ่ม import (ถ้ายังไม่มี)

### 5.1 เช็คข้างบนสุดของไฟล์

ต้องมี import เหล่านี้:
```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/unit_converter.dart';
import '../../../core/constants/ai_loading_messages.dart';
import '../providers/health_provider.dart';
import '../providers/my_meal_provider.dart';
import '../widgets/daily_summary_card.dart';
import '../widgets/food_timeline_card.dart';  // ยังใช้อยู่
import '../widgets/edit_food_bottom_sheet.dart';
import '../widgets/food_detail_bottom_sheet.dart';
import '../widgets/gemini_analysis_sheet.dart';
import '../widgets/quick_add_section.dart';
import '../models/food_entry.dart';
import '../../scanner/providers/scanner_provider.dart';
import '../../../core/ai/gemini_service.dart';
import '../../../core/services/usage_limiter.dart';
import '../../../core/services/purchase_service.dart';
import '../../../features/energy/widgets/no_energy_dialog.dart';
import '../../../features/energy/providers/energy_provider.dart';
```

ถ้าไม่มี import ไหน เพิ่มเข้าไป

---

## 📝 Checklist

- [ ] เปลี่ยน SliverList → SliverToBoxAdapter
- [ ] เพิ่ม method `_buildMealsHorizontalCard()`
- [ ] เพิ่ม method `_buildHorizontalFoodItem()`
- [ ] เพิ่ม helper methods (`_getImageProvider`, `_formatTime`)
- [ ] แต่ละ item เป็น CircleAvatar + ชื่อ + แคลอรี่ + เวลา
- [ ] Tap → `_showFoodDetail()` ทำงาน
- [ ] Long press → แสดง bottom sheet (edit/analyze/delete)
- [ ] เช็ค imports ครบ
- [ ] Build ผ่าน: `flutter build apk --debug`
- [ ] ทดสอบ: Card "Meals" แสดง
- [ ] ทดสอบ: Scroll ซ้ายขวาได้
- [ ] ทดสอบ: Tap food item → เปิด detail
- [ ] ทดสอบ: Long press → แสดง options
- [ ] ทดสอบ: รูปไม่มี → แสดง icon
- [ ] ทดสอบ: Empty state ยังแสดงถูกต้อง
- [ ] ทดสอบ: Pull-to-refresh ยังทำงาน
- [ ] ทดสอบ: Dark mode ไม่แตก
- [ ] ทดสอบ: มี entry > 5 รายการ scroll ลื่น

---

## 🧪 Testing Steps

### 1. Build
```bash
flutter clean
flutter pub get
flutter build apk --debug
```

### 2. Run
```bash
flutter run
```

### 3. Test Horizontal Scroll

#### เมื่อมี Food Entries
- เปิดแอป → scroll ลงมาหลัง DailySummaryCard
- เห็น Card "Meals" พื้นขาว มี shadow
- ข้างในเป็นรูปวงกลม เรียงซ้ายขวา
- Scroll ซ้ายขวาได้ (ถ้ามี > 4 items)

#### Tap Item
- Tap รูปอาหาร → เปิด FoodDetailBottomSheet
- เห็นรายละเอียดเต็ม
- Close sheet → กลับมาหน้าเดิม

#### Long Press Item
- Long press รูปอาหาร → bottom sheet 3 options:
  - Edit → เปิด EditFoodBottomSheet
  - Analyze with AI → ถ้ามีรูปหรือยังไม่ verify
  - Delete → confirm dialog → ลบสำเร็จ

#### รูปภาพ
- Food มีรูป → แสดงรูปจริง
- Food ไม่มีรูป → แสดง icon restaurant
- รูปถูกลบจาก gallery → แสดง icon (ไม่ crash)

#### Empty State
- ลบ food ทั้งหมด → แสดง empty state เดิม (📭)
- ไม่แสดง card "Meals"

#### Pull-to-Refresh
- Pull down → scan gallery + refresh data
- มี food ใหม่ → แสดงใน horizontal scroll

#### Dark Mode
- Toggle dark mode → Card พื้นเทาเข้ม
- รูปวงกลมยังเห็นชัด
- Text อ่านได้

#### Performance
- เพิ่ม food entries > 20 รายการ
- Scroll ซ้ายขวาต้องลื่น (ไม่กระตุก)

---

## 🚀 Git Commit

```bash
git add lib/features/health/presentation/health_timeline_tab.dart
git commit -m "style: change timeline to horizontal scrollable meal cards

- Replace vertical SliverList with horizontal ListView
- Wrap food items in Meals card container
- Display as circular avatars with name and calories
- Tap to view detail, long press for edit/delete/analyze options
- Add image error handling for deleted files
- Maintain all existing logic for CRUD operations"

git push origin feature/airbnb-redesign
```

---

## ❓ Q&A

**Q: Build error "File not found"?**  
A: เช็ค import `dart:io` ที่ข้างบนสุด

**Q: รูปไม่แสดง?**  
A: เช็คว่า `_getImageProvider()` มี try-catch และ `file.existsSync()`

**Q: Long press ไม่ทำงาน?**  
A: เช็คว่า `GestureDetector` มี `onLongPress` callback

**Q: Horizontal scroll ไม่ลื่น?**  
A: ใส่ `physics: const BouncingScrollPhysics()` ใน ListView

**Q: Empty state ไม่แสดง?**  
A: เช็คว่า `if (items.isEmpty) return SliverFillRemaining(...)` ยังอยู่

**Q: Diet tab แตก?**  
A: ไม่ควรแตก เพราะ `food_timeline_card.dart` ไม่ได้แก้ (ยังใช้ใน Diet tab)

**Q: ถ้าอยากเพิ่ม meal type icon (🍳🍱🍲)?**  
A: เพิ่มใน `_buildHorizontalFoodItem()`:
```dart
Text(
  entry.mealType.icon,  // เช่น 🍳 สำหรับ breakfast
  style: const TextStyle(fontSize: 14),
),
```

---

**✅ เสร็จแล้ว?** → รอ Senior ทำ `TASK_4_BOTTOM_NAV.md` หรือทำ `TASK_5_POLISH.md` ข้ามไปก่อน (ถ้าทำได้)
