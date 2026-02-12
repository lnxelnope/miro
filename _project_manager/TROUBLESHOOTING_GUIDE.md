# 🔧 คู่มือแก้ปัญหา Isar Database & Flutter Build Errors

## 📋 สารบัญ
1. [ปัญหา: Duplicate Import (Habit is imported from both)](#1-ปัญหา-duplicate-import)
2. [ปัญหา: findAll() isn't defined for QWhere](#2-ปัญหา-findall-isnt-defined)
3. [ปัญหา: sortByXxxDesc() isn't defined](#3-ปัญหา-sortbyxxxdesc-isnt-defined)
4. [ปัญหา: Provider name conflict](#4-ปัญหา-provider-name-conflict)
5. [ปัญหา: dateBetween vs timestampBetween](#5-ปัญหา-datebetween-vs-timestampbetween)
6. [ปัญหา: isActiveEqualTo conflict](#6-ปัญหา-isactiveequalto-conflict)
7. [ปัญหา: Member not found (enum)](#7-ปัญหา-member-not-found-enum)
8. [ปัญหา: Type mismatch (num vs int/double)](#8-ปัญหา-type-mismatch)
9. [ขั้นตอน Clean Build](#9-ขั้นตอน-clean-build)

---

## 1. ปัญหา: Duplicate Import

### Error Message:
```
'Habit' is imported from both 'package:miro_hybrid/features/tasks/models/habit.dart' 
and 'package:miro_hybrid/features/tasks/models/task.dart'.
```

### สาเหตุ:
- มี class `Habit` อยู่ใน 2 ไฟล์ (task.dart และ habit.dart)
- Generated file (task.g.dart) ยังมี Habit class อยู่

### วิธีแก้:

**ขั้นตอนที่ 1:** เปิดไฟล์ `lib/features/tasks/models/task.dart` และลบ/comment class Habit และ HabitCompletion ออก

```dart
// ❌ ลบหรือ comment ออก
// @collection
// class Habit {
//   ...
// }

// @collection
// class HabitCompletion {
//   ...
// }
```

**ขั้นตอนที่ 2:** ลบไฟล์ generated แล้ว regenerate ใหม่

```powershell
# ลบ task.g.dart
Remove-Item lib\features\tasks\models\task.g.dart

# Regenerate
dart run build_runner build --delete-conflicting-outputs
```

**ขั้นตอนที่ 3:** แก้ไข import ใน `database_service.dart`

```dart
// ✅ ถูกต้อง - hide classes ที่ไม่ต้องการ
import '../../features/tasks/models/task.dart' hide Habit, HabitCompletion;
import '../../features/tasks/models/habit.dart';
import '../../features/tasks/models/habit_log.dart';
```

---

## 2. ปัญหา: findAll() isn't defined

### Error Message:
```
The method 'findAll' isn't defined for the type 'QueryBuilder<..., QWhere>'.
```

### สาเหตุ:
- ใช้ `.where().findAll()` ซึ่งไม่ถูกต้องใน Isar

### วิธีแก้:

```dart
// ❌ ผิด
final items = await DatabaseService.foodEntries.where().findAll();

// ✅ ถูกต้อง - ใช้ filter() แทน where()
final items = await DatabaseService.foodEntries.filter().findAll();

// ✅ ถูกต้อง - ใช้ filter() พร้อมเงื่อนไข
final items = await DatabaseService.foodEntries
    .filter()
    .timestampBetween(startOfDay, endOfDay)
    .findAll();
```

### กฎง่ายๆ:
| ต้องการทำอะไร | ใช้อะไร |
|--------------|--------|
| ดึงทั้งหมด | `.filter().findAll()` |
| ดึงตามเงื่อนไข | `.filter().xxxEqualTo(value).findAll()` |
| ดึงตามช่วงวันที่ | `.filter().xxxBetween(start, end).findAll()` |

---

## 3. ปัญหา: sortByXxxDesc() isn't defined

### Error Message:
```
The method 'sortByIsPinnedDesc' isn't defined for the type 'QueryBuilder<...>'.
```

### สาเหตุ:
- Isar ไม่ได้ generate sort method สำหรับ field นั้น (อาจเป็น bool field)

### วิธีแก้:

```dart
// ❌ ผิด - method ไม่มีอยู่
final notes = await DatabaseService.quickNotes
    .filter()
    .sortByIsPinnedDesc()  // ❌ Error!
    .findAll();

// ✅ ถูกต้อง - ใช้ manual sort
final notes = await DatabaseService.quickNotes
    .filter()
    .sortByCreatedAtDesc()  // sort ด้วย field ที่มี method
    .findAll();

// Sort เพิ่มเติมด้วย Dart
notes.sort((a, b) {
  if (a.isPinned && !b.isPinned) return -1;  // pinned ขึ้นก่อน
  if (!a.isPinned && b.isPinned) return 1;
  return 0;
});
```

---

## 4. ปัญหา: Provider name conflict

### Error Message:
```
'todayTasksProvider' is imported from both 'package:miro_hybrid/.../task_provider.dart' 
and 'package:miro_hybrid/.../today_provider.dart'.
```

### สาเหตุ:
- มี provider ชื่อเดียวกันใน 2 ไฟล์

### วิธีแก้:

**วิธีที่ 1:** Hide provider ที่ไม่ต้องการ

```dart
// ✅ Hide provider ที่ไม่ใช้
import '../providers/task_provider.dart' hide todayTasksProvider;
import '../providers/today_provider.dart';

// ใช้ได้เลย
final tasks = ref.watch(todayTasksProvider);  // จาก today_provider.dart
```

**วิธีที่ 2:** ใช้ prefix

```dart
import '../providers/task_provider.dart' as task_prov;
import '../providers/today_provider.dart' as today_prov;

// ระบุที่มา
final tasks = ref.watch(today_prov.todayTasksProvider);
```

**วิธีที่ 3:** เปลี่ยนชื่อ provider

```dart
// ใน today_provider.dart
// เปลี่ยนจาก todayTasksProvider เป็น todayTasksFromTodayProvider
final todayTasksFromTodayProvider = FutureProvider<List<Task>>((ref) async {
  // ...
});
```

---

## 5. ปัญหา: dateBetween vs timestampBetween

### Error Message:
```
The method 'dateBetween' isn't defined for the type 'QueryBuilder<FoodEntry, ...>'.
```

### สาเหตุ:
- Method ถูก generate ตามชื่อ field ใน model
- ถ้า field ชื่อ `timestamp` → method จะเป็น `timestampBetween`
- ถ้า field ชื่อ `date` → method จะเป็น `dateBetween`

### วิธีแก้:

```dart
// ❌ ผิด - FoodEntry มี field ชื่อ 'timestamp' ไม่ใช่ 'date'
final entries = await DatabaseService.foodEntries
    .filter()
    .dateBetween(start, end)  // ❌ Error!
    .findAll();

// ✅ ถูกต้อง - ใช้ timestampBetween ตามชื่อ field
final entries = await DatabaseService.foodEntries
    .filter()
    .timestampBetween(start, end)  // ✅ 
    .findAll();
```

### วิธีตรวจสอบ:
1. เปิดไฟล์ model (เช่น `food_entry.dart`)
2. ดูชื่อ field ที่เป็น `DateTime`
3. ใช้ชื่อ field + `Between` เป็น method

```dart
// ใน food_entry.dart
@collection
class FoodEntry {
  late DateTime timestamp;  // ← ชื่อ field
  // ...
}

// ดังนั้นใช้ timestampBetween()
```

---

## 6. ปัญหา: isActiveEqualTo conflict

### Error Message:
```
The method 'isActiveEqualTo' is defined in multiple extensions...
```

### สาเหตุ:
- มีหลาย class ที่มี field `isActive` และ Isar generate method ชื่อเดียวกัน
- ไม่รู้ว่าจะใช้ method จาก class ไหน

### วิธีแก้:

```dart
// ❌ ผิด - Isar ไม่รู้จะใช้ isActiveEqualTo จาก Habit หรือ Reminder
final habits = await DatabaseService.habits
    .filter()
    .isActiveEqualTo(true)  // ❌ Error!
    .findAll();

// ✅ ถูกต้อง - ดึงทั้งหมดแล้ว filter ด้วย Dart
final allHabits = await DatabaseService.habits.filter().findAll();
final activeHabits = allHabits.where((h) => h.isActive).toList();
```

### หมายเหตุ:
- ถ้า field มี `@ignore` annotation จะไม่ถูก generate method
- ต้อง filter ด้วย Dart แทน

---

## 7. ปัญหา: Member not found (enum)

### Error Message:
```
Member not found: 'mutualFund'.
```

### สาเหตุ:
- ใช้ค่า enum ที่ไม่มีอยู่จริง

### วิธีแก้:

**ขั้นตอนที่ 1:** ตรวจสอบค่าที่มีใน enum

```dart
// ใน enums.dart
enum AssetType {
  stock,
  crypto,
  gold,
  fund,        // ✅ มีค่านี้
  realEstate,
  other,
  // mutualFund,  // ❌ ไม่มี!
}
```

**ขั้นตอนที่ 2:** แก้ไขโค้ดให้ใช้ค่าที่ถูกต้อง

```dart
// ❌ ผิด
case AssetType.mutualFund:

// ✅ ถูกต้อง
case AssetType.fund:
```

---

## 8. ปัญหา: Type mismatch

### Error Message:
```
A value of type 'num' can't be assigned to a variable of type 'int'.
A value of type 'num' can't be assigned to the parameter type 'double'.
```

### สาเหตุ:
- Dart ไม่ auto-convert ระหว่าง num, int, double

### วิธีแก้:

```dart
// ❌ ผิด - num + int = num (ไม่ใช่ int)
int totalLogs = 0;
totalLogs += logs.length;  // ❌ Error ถ้า logs.length เป็น num

// ✅ ถูกต้อง - explicit conversion
int totalLogs = 0;
totalLogs = totalLogs + logs.length;  // ใช้ + แทน +=

// ✅ หรือใช้ toInt() / toDouble()
totalLogs = totalLogs + logs.length.toInt();
profitLossPercent = (profitLoss / totalCost * 100).toDouble();
```

---

## 9. ขั้นตอน Clean Build

เมื่อแก้ไขโค้ดแล้ว ให้ทำขั้นตอนนี้ทุกครั้ง:

```powershell
# 1. Clean Flutter
flutter clean

# 2. Get dependencies
flutter pub get

# 3. ลบ generated files ที่มีปัญหา (ถ้าจำเป็น)
Remove-Item lib\features\tasks\models\task.g.dart -ErrorAction SilentlyContinue

# 4. Regenerate code
dart run build_runner build --delete-conflicting-outputs

# 5. Run app
flutter run
```

### ⚠️ สำคัญ!
- **ทำ Clean Build ทุกครั้ง** หลังแก้ไขโค้ดที่เกี่ยวกับ model หรือ Isar
- Flutter cache ไฟล์เก่าไว้ ถ้าไม่ clean จะใช้โค้ดเก่าอยู่

---

## 🔄 Checklist ก่อน Flutter Run

- [ ] ไม่มี class ซ้ำกันใน model files
- [ ] import ใช้ `hide` หรือ prefix ถ้ามีชื่อซ้ำ
- [ ] ใช้ `.filter()` ไม่ใช่ `.where()` สำหรับ query
- [ ] ชื่อ method ตรงกับชื่อ field (เช่น `timestampBetween` ไม่ใช่ `dateBetween`)
- [ ] ใช้ manual filter สำหรับ field ที่มี conflict
- [ ] ตรวจสอบค่า enum ให้ถูกต้อง
- [ ] แปลง type ด้วย `.toInt()` หรือ `.toDouble()` ถ้าจำเป็น
- [ ] รัน `flutter clean` และ `build_runner` ก่อน run

---

## 📝 Template สำหรับ Query ที่ถูกต้อง

```dart
// ดึงข้อมูลทั้งหมด
final all = await DatabaseService.xxx.filter().findAll();

// ดึงตามเงื่อนไข
final filtered = await DatabaseService.xxx
    .filter()
    .fieldEqualTo(value)
    .findAll();

// ดึงตามช่วงวันที่
final byDate = await DatabaseService.xxx
    .filter()
    .timestampBetween(start, end)
    .findAll();

// ดึงแล้ว sort
final sorted = await DatabaseService.xxx
    .filter()
    .sortByCreatedAtDesc()
    .findAll();

// ดึงแล้ว manual filter (สำหรับ @ignore fields)
final allItems = await DatabaseService.xxx.filter().findAll();
final activeItems = allItems.where((x) => x.isActive).toList();
```

---

## 🆘 ถ้ายังไม่หาย

1. ลบ folder `.dart_tool` และ `build`
2. รัน `flutter clean`
3. รัน `flutter pub get`
4. ลบ `.g.dart` files ทั้งหมดใน models
5. รัน `dart run build_runner build --delete-conflicting-outputs`
6. รัน `flutter run`

```powershell
# One-liner สำหรับ full reset
flutter clean; flutter pub get; Get-ChildItem -Path "lib" -Filter "*.g.dart" -Recurse | Remove-Item; dart run build_runner build --delete-conflicting-outputs; flutter run
```
