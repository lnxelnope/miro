# Isar → Drift Migration Guide

## สถานะ: 30% เสร็จ (EnergyTransaction migrated ✅)

### ✅ สิ่งที่ทำเสร็จแล้ว

1. **Infrastructure Setup**
   - ✅ เพิ่ม `drift`, `drift_sqflite`, `sqlite3_flutter_libs`, `drift_dev`
   - ✅ ลบ `isar`, `isar_flutter_libs`, `isar_generator` จาก pubspec.yaml
   - ✅ สร้าง `lib/core/database/app_database.dart` (9 tables)
   - ✅ Generate `app_database.g.dart`
   - ✅ อัปเดต `DatabaseService` ใหม่

2. **EnergyTransaction** (100% ✅)
   - ✅ ลบ `lib/core/models/energy_transaction.dart`
   - ✅ แก้ `lib/core/services/energy_service.dart`
   - ✅ แก้ `lib/main.dart`
   - ✅ แก้ `lib/features/energy/providers/energy_provider.dart`

3. **ChatMessage** (50% ⏳)
   - ✅ ลบ `lib/features/chat/models/chat_message.dart`
   - ⏳ ยังต้องแก้ `lib/features/chat/providers/chat_provider.dart`
   - ⏳ ยังต้องแก้ `lib/core/ai/gemini_chat_service.dart`
   - ⏳ ยังต้องแก้ `lib/features/chat/presentation/chat_screen.dart`

---

## 📖 Drift Query Cheat Sheet

### Import Statements
```dart
// OLD (Isar)
import 'package:isar/isar.dart';
import '../models/food_entry.dart';

// NEW (Drift)
import 'package:drift/drift.dart' hide JsonKey; // hide JsonKey if using json_serializable
import '../database/app_database.dart';
import '../database/database_service.dart';
```

### SELECT Queries

#### 1. Select All
```dart
// OLD (Isar)
await DatabaseService.foodEntries.where().findAll();

// NEW (Drift)
await DatabaseService.db.select(DatabaseService.db.foodEntries).get();
```

#### 2. Filter (WHERE)
```dart
// OLD (Isar)
await DatabaseService.foodEntries
    .filter()
    .isDeletedEqualTo(false)
    .findAll();

// NEW (Drift)
await (DatabaseService.db.select(DatabaseService.db.foodEntries)
    ..where((tbl) => tbl.isDeleted.equals(false)))
    .get();
```

#### 3. Multiple Filters (AND)
```dart
// OLD (Isar)
await DatabaseService.foodEntries
    .filter()
    .isDeletedEqualTo(false)
    .isSyncedEqualTo(false)
    .findAll();

// NEW (Drift)
await (DatabaseService.db.select(DatabaseService.db.foodEntries)
    ..where((tbl) => 
        tbl.isDeleted.equals(false) & 
        tbl.isSynced.equals(false)))
    .get();
```

#### 4. OR Filters
```dart
// OLD (Isar)
await DatabaseService.ingredients
    .filter()
    .nameContains(query, caseSensitive: false)
    .or()
    .nameEnContains(query, caseSensitive: false)
    .findAll();

// NEW (Drift)
await (DatabaseService.db.select(DatabaseService.db.ingredients)
    ..where((tbl) => 
        tbl.name.contains(query) | 
        tbl.nameEn.contains(query)))
    .get();
```

#### 5. Sort + Limit
```dart
// OLD (Isar)
await DatabaseService.foodEntries
    .filter()
    .isDeletedEqualTo(false)
    .sortByTimestampDesc()
    .limit(100)
    .findAll();

// NEW (Drift)
await (DatabaseService.db.select(DatabaseService.db.foodEntries)
    ..where((tbl) => tbl.isDeleted.equals(false))
    ..orderBy([(tbl) => OrderingTerm.desc(tbl.timestamp)])
    ..limit(100))
    .get();
```

#### 6. Find First
```dart
// OLD (Isar)
await DatabaseService.foodEntries
    .filter()
    .foodNameEqualTo(name)
    .findFirst();

// NEW (Drift)
await (DatabaseService.db.select(DatabaseService.db.foodEntries)
    ..where((tbl) => tbl.foodName.equals(name))
    ..limit(1))
    .getSingleOrNull();
```

#### 7. Get by ID
```dart
// OLD (Isar)
await DatabaseService.foodEntries.get(id);

// NEW (Drift)
await (DatabaseService.db.select(DatabaseService.db.foodEntries)
    ..where((tbl) => tbl.id.equals(id)))
    .getSingleOrNull();
```

#### 8. Count
```dart
// OLD (Isar)
await DatabaseService.foodEntries.count();

// NEW (Drift)
await DatabaseService.db
    .select(DatabaseService.db.foodEntries)
    .get()
    .then((list) => list.length);

// หรือใช้ countAll() (มี built-in ใน Drift)
final count = DatabaseService.db.foodEntries.count();
await count.getSingle();
```

#### 9. Date Range
```dart
// OLD (Isar)
await DatabaseService.foodEntries
    .filter()
    .timestampBetween(startOfDay, endOfDay)
    .findAll();

// NEW (Drift)
await (DatabaseService.db.select(DatabaseService.db.foodEntries)
    ..where((tbl) => 
        tbl.timestamp.isBiggerOrEqualValue(startOfDay) & 
        tbl.timestamp.isSmallerOrEqualValue(endOfDay)))
    .get();
```

### INSERT/UPDATE (Write)

#### 1. Insert/Update Single Record
```dart
// OLD (Isar)
await DatabaseService.isar.writeTxn(() async {
  await DatabaseService.foodEntries.put(entry);
});

// NEW (Drift)
await DatabaseService.db
    .into(DatabaseService.db.foodEntries)
    .insertOnConflictUpdate(
      FoodEntriesCompanion.insert(
        foodName: entry.foodName,
        timestamp: entry.timestamp,
        calories: entry.calories,
        // ... other required fields
        
        // Optional fields use Value()
        foodNameEn: Value(entry.foodNameEn),
        imagePath: Value(entry.imagePath),
        // ...
      ),
    );
```

#### 2. Update Existing Record (when you have ID)
```dart
// OLD (Isar)
entry.calories = newValue;
await DatabaseService.isar.writeTxn(() async {
  await DatabaseService.foodEntries.put(entry);
});

// NEW (Drift)
await (DatabaseService.db.update(DatabaseService.db.foodEntries)
    ..where((tbl) => tbl.id.equals(entry.id)))
    .write(
      FoodEntriesCompanion(
        calories: Value(newValue),
      ),
    );
```

#### 3. Batch Insert
```dart
// OLD (Isar)
await DatabaseService.isar.writeTxn(() async {
  await DatabaseService.foodEntries.putAll(entries);
});

// NEW (Drift)
await DatabaseService.db.batch((batch) {
  batch.insertAllOnConflictUpdate(
    DatabaseService.db.foodEntries,
    entries.map((e) => FoodEntriesCompanion.insert(
      foodName: e.foodName,
      // ...
    )).toList(),
  );
});
```

### DELETE

#### 1. Delete by ID
```dart
// OLD (Isar)
await DatabaseService.isar.writeTxn(() async {
  await DatabaseService.foodEntries.delete(id);
});

// NEW (Drift)
await (DatabaseService.db.delete(DatabaseService.db.foodEntries)
    ..where((tbl) => tbl.id.equals(id)))
    .go();
```

#### 2. Delete All Matching Filter
```dart
// OLD (Isar)
await DatabaseService.isar.writeTxn(() async {
  await DatabaseService.foodEntries
      .filter()
      .sourceEqualTo(DataSource.galleryScanned)
      .deleteAll();
});

// NEW (Drift)
await (DatabaseService.db.delete(DatabaseService.db.foodEntries)
    ..where((tbl) => tbl.source.equalsValue(DataSource.galleryScanned)))
    .go();
```

### Working with Enums

```dart
// Drift automatically converts enums via intEnum<>()

// In table definition (app_database.dart):
IntColumn get mealType => intEnum<MealType>()();
IntColumn get source => intEnum<DataSource>()();

// In queries, use equalsValue():
..where((tbl) => tbl.mealType.equalsValue(MealType.breakfast))
..where((tbl) => tbl.source.equalsValue(DataSource.aiAnalyzed))
```

### Companion Objects (สำหรับ INSERT)

```dart
// Pattern: <TableName>Companion.insert()
// Required fields = normal parameters
// Optional fields = Value()

FoodEntriesCompanion.insert(
  foodName: 'ข้าวผัด',
  timestamp: DateTime.now(),
  mealType: MealType.lunch,
  servingSize: 1.0,
  servingUnit: 'จาน',
  calories: 520,
  protein: 15,
  carbs: 85,
  fat: 12,
  source: DataSource.aiAnalyzed,
  
  // Optional fields
  foodNameEn: Value('Fried Rice'),
  imagePath: Value('/path/to/image.jpg'),
  notes: Value(null), // explicitly null
);
```

---

## 🗂️ Files ที่ต้อง Migrate (ตาม Priority)

### 1. ChatMessage + ChatSession (⏳ 50% done)
- `lib/features/chat/providers/chat_provider.dart` — มี query เยอะมาก!
- `lib/core/ai/gemini_chat_service.dart`
- `lib/features/chat/presentation/chat_screen.dart`
- `lib/features/chat/widgets/message_bubble.dart`
- `lib/features/chat/services/intent_handler.dart`

### 2. UserProfile
- `lib/features/profile/models/user_profile.dart` → ลบ, ใช้ `UserProfileData`
- `lib/features/profile/presentation/profile_screen.dart`
- `lib/features/profile/providers/profile_provider.dart`
- `lib/features/onboarding/presentation/onboarding_screen.dart`
- `lib/main.dart`

### 3. DailySummary
- `lib/features/health/models/daily_summary.dart` → ลบ, ใช้ `DailySummaryData`
- `lib/core/services/daily_summary_service.dart`
- `lib/features/health/providers/health_provider.dart`
- `lib/features/health/presentation/today_summary_dashboard_screen.dart`

### 4. Ingredient
- `lib/features/health/models/ingredient.dart` → ลบ, ใช้ `IngredientData`
- `lib/features/health/widgets/create_meal_sheet.dart`
- `lib/features/health/widgets/edit_food_bottom_sheet.dart`
- `lib/features/home/widgets/simple_food_detail_sheet.dart`
- `lib/features/chat/services/food_lookup_service.dart`

### 5. MyMeal + MyMealIngredient
- `lib/features/health/models/my_meal.dart` → ลบ
- `lib/features/health/models/my_meal_ingredient.dart` → ลบ
- `lib/features/health/providers/my_meal_provider.dart`
- `lib/features/health/presentation/health_my_meal_tab.dart`
- `lib/features/health/widgets/create_meal_sheet.dart`
- `lib/features/chat/services/food_lookup_service.dart`

### 6. FoodEntry (ใหญ่สุด!)
- `lib/features/health/models/food_entry.dart` → ลบ
- `lib/features/health/providers/health_provider.dart` (หลัก)
- `lib/features/health/providers/micronutrient_stats_provider.dart`
- `lib/features/scanner/logic/scan_controller.dart`
- `lib/core/services/data_sync_service.dart`
- `lib/core/services/backup_service.dart`
- `lib/core/services/thumbnail_service.dart`
- และอีกหลายไฟล์...

---

## ⚠️ สิ่งสำคัญที่ต้องจำ

1. **ไม่ต้อง migrate data** — คุณบอกว่าลบข้อมูลได้
2. **ลบ model files เก่า** ก่อนแก้ query (เพื่อเห็น compile error ชัดๆ)
3. **Run `dart run build_runner build --delete-conflicting-outputs`** หลังลบ model
4. **Test ทีละ feature** — อย่าทำหมดพร้อมกัน
5. **Data Types:**
   - `FoodEntry` → `FoodEntryData`
   - `Ingredient` → `IngredientData`
   - `MyMeal` → `MyMealData`
   - เป็นต้น

---

## 🚀 Next Steps for You

1. **Continue ChatMessage migration:**
   ```bash
   # Edit these files:
   lib/features/chat/providers/chat_provider.dart
   lib/core/ai/gemini_chat_service.dart
   ```

2. **Test after each collection:**
   ```bash
   flutter run
   # ทดสอบ feature ที่เกี่ยวข้อง
   ```

3. **When all done:**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   flutter clean
   flutter pub get
   flutter build appbundle --release
   ```

4. **Verify 16KB alignment:**
   ```bash
   # Extract AAB
   unzip build/app/outputs/bundle/release/app-release.aab -d /tmp/aab

   # Check .so files
   llvm-objdump -p /tmp/aab/base/lib/arm64-v8a/*.so | grep LOAD
   # Should see "align 2**14" or higher (NOT 2**12)
   ```

---

**โชคดีครับ! งานนี้ใหญ่แต่ทำทีละขั้นตอนได้แน่นอน 💪**
