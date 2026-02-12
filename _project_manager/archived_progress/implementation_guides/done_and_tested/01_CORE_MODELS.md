# Step 01: Core Data Models

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 1 ชั่วโมง
> **ความยาก:** ปานกลาง
> **ต้องทำก่อน:** Step 00 (Project Setup)

---

## สิ่งที่ต้องทำ

1. สร้าง Enum ทั้งหมด
2. สร้าง Data Models สำหรับ Health
3. สร้าง Data Models สำหรับ Finance
4. สร้าง Data Models สำหรับ Tasks
5. สร้าง Data Models สำหรับ Chat
6. Run build_runner เพื่อ generate code
7. อัปเดต DatabaseService

---

## ขั้นตอนที่ 1: สร้าง Enums

**สร้างไฟล์:** `lib/core/constants/enums.dart`

```dart
// ============================================
// HEALTH ENUMS
// ============================================

/// ประเภทมื้ออาหาร
enum MealType {
  breakfast, // มื้อเช้า
  lunch,     // มื้อกลางวัน
  dinner,    // มื้อเย็น
  snack,     // ของว่าง
}

extension MealTypeExtension on MealType {
  String get displayName {
    switch (this) {
      case MealType.breakfast: return 'มื้อเช้า';
      case MealType.lunch: return 'มื้อกลางวัน';
      case MealType.dinner: return 'มื้อเย็น';
      case MealType.snack: return 'ของว่าง';
    }
  }
  
  String get icon {
    switch (this) {
      case MealType.breakfast: return '☀️';
      case MealType.lunch: return '🌤️';
      case MealType.dinner: return '🌙';
      case MealType.snack: return '🍿';
    }
  }
}

/// ประเภทการออกกำลังกาย
enum ActivityType {
  running,
  walking,
  cycling,
  swimming,
  yoga,
  gym,
  hiit,
  other,
}

extension ActivityTypeExtension on ActivityType {
  String get displayName {
    switch (this) {
      case ActivityType.running: return 'วิ่ง';
      case ActivityType.walking: return 'เดิน';
      case ActivityType.cycling: return 'ปั่นจักรยาน';
      case ActivityType.swimming: return 'ว่ายน้ำ';
      case ActivityType.yoga: return 'โยคะ';
      case ActivityType.gym: return 'ยิม';
      case ActivityType.hiit: return 'HIIT';
      case ActivityType.other: return 'อื่นๆ';
    }
  }
  
  String get icon {
    switch (this) {
      case ActivityType.running: return '🏃';
      case ActivityType.walking: return '🚶';
      case ActivityType.cycling: return '🚴';
      case ActivityType.swimming: return '🏊';
      case ActivityType.yoga: return '🧘';
      case ActivityType.gym: return '🏋️';
      case ActivityType.hiit: return '💪';
      case ActivityType.other: return '🎯';
    }
  }
}

/// ประเภทข้อมูลสุขภาพอื่นๆ
enum HealthEntryType {
  supplement,    // วิตามิน/อาหารเสริม
  medicine,      // ยา
  water,         // น้ำ
  weight,        // น้ำหนัก
  bodyFat,       // ไขมันในร่างกาย
  bloodPressure, // ความดัน
  bloodSugar,    // น้ำตาล
  heartRate,     // ชีพจร
  sleep,         // การนอน
}

/// ประเภท Schedule ของ Workout Program
enum ScheduleType {
  weekly,   // ตามวันในสัปดาห์ (จันทร์-อาทิตย์)
  rotating, // หมุนเวียน (Push→Pull→Legs→Rest→วนซ้ำ)
  interval, // วันเว้นวัน
  custom,   // กำหนดวันที่เอง
}

// ============================================
// FINANCE ENUMS
// ============================================

/// ประเภท Transaction
enum TransactionType {
  income,   // รายรับ
  expense,  // รายจ่าย
  transfer, // โอนเงิน
}

/// หมวดหมู่รายจ่าย
enum ExpenseCategory {
  food,          // อาหาร/เครื่องดื่ม
  transport,     // รถ/เดินทาง
  shopping,      // ช้อปปิ้ง
  services,      // ค่าบริการ
  housing,       // บ้าน/ที่พัก
  health,        // สุขภาพ
  entertainment, // บันเทิง
  education,     // การศึกษา
  saving,        // ออม/ลงทุน
  debt,          // หนี้สิน
  gift,          // ของขวัญ
  other,         // อื่นๆ
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get displayName {
    switch (this) {
      case ExpenseCategory.food: return 'อาหาร/เครื่องดื่ม';
      case ExpenseCategory.transport: return 'รถ/เดินทาง';
      case ExpenseCategory.shopping: return 'ช้อปปิ้ง';
      case ExpenseCategory.services: return 'ค่าบริการ';
      case ExpenseCategory.housing: return 'บ้าน/ที่พัก';
      case ExpenseCategory.health: return 'สุขภาพ';
      case ExpenseCategory.entertainment: return 'บันเทิง';
      case ExpenseCategory.education: return 'การศึกษา';
      case ExpenseCategory.saving: return 'ออม/ลงทุน';
      case ExpenseCategory.debt: return 'หนี้สิน';
      case ExpenseCategory.gift: return 'ของขวัญ';
      case ExpenseCategory.other: return 'อื่นๆ';
    }
  }
  
  String get icon {
    switch (this) {
      case ExpenseCategory.food: return '🍔';
      case ExpenseCategory.transport: return '🚗';
      case ExpenseCategory.shopping: return '🛒';
      case ExpenseCategory.services: return '📱';
      case ExpenseCategory.housing: return '🏠';
      case ExpenseCategory.health: return '💊';
      case ExpenseCategory.entertainment: return '🎮';
      case ExpenseCategory.education: return '📚';
      case ExpenseCategory.saving: return '💰';
      case ExpenseCategory.debt: return '💳';
      case ExpenseCategory.gift: return '🎁';
      case ExpenseCategory.other: return '📦';
    }
  }
}

/// หมวดหมู่รายรับ
enum IncomeCategory {
  salary,     // เงินเดือน
  bonus,      // โบนัส
  investment, // ลงทุน
  rental,     // ค่าเช่า
  freelance,  // ฟรีแลนซ์
  received,   // ได้รับ
  other,      // อื่นๆ
}

/// ประเภทสินทรัพย์
enum AssetType {
  cash,     // เงินสด
  stock,    // หุ้น
  fund,     // กองทุน
  gold,     // ทอง
  crypto,   // คริปโต
  property, // อสังหา
  vehicle,  // รถ
  other,    // อื่นๆ
}

/// ระดับ Liquidity
enum LiquidityLevel {
  high,   // ขายได้เร็ว (เงินสด, หุ้น, กองทุน)
  medium, // ขายได้ปานกลาง (ทอง, คริปโต)
  low,    // ขายได้ช้า (บ้าน, รถ)
}

// ============================================
// TASK ENUMS
// ============================================

/// ประเภท Task
enum TaskType {
  calendarEvent, // นัดหมาย (มีวันที่/เวลา)
  todoList,      // Todo list
  singleNote,    // บันทึก
  workoutTask,   // จาก Workout Program
  reminderTask,  // เตือนความจำ
  habitTask,     // Habit tracking
}

/// สถานะ Task
enum TaskStatus {
  pending,    // รอทำ
  inProgress, // กำลังทำ
  completed,  // เสร็จแล้ว
  cancelled,  // ยกเลิก
  overdue,    // เลยกำหนด
}

/// Priority
enum TaskPriority {
  low,
  medium,
  high,
  urgent,
}

/// แหล่งที่มาของ Task
enum TaskSource {
  user,            // ผู้ใช้สร้างเอง
  aiGenerated,     // AI สร้าง
  workoutProgram,  // จาก Workout Program
  recurring,       // Recurring task
  googleCalendar,  // จาก Google Calendar
  nudge,           // จาก Nudge
}

// ============================================
// GENERAL ENUMS
// ============================================

/// แหล่งที่มาของข้อมูล
enum DataSource {
  manual,         // ผู้ใช้กรอกเอง
  aiAnalyzed,     // AI วิเคราะห์
  slipScan,       // สแกนสลิป
  healthConnect,  // Health Connect
  googleCalendar, // Google Calendar
  barcode,        // สแกน Barcode
}
```

---

## ขั้นตอนที่ 2: สร้าง Health Models

### 2.1 FoodEntry Model

**สร้างไฟล์:** `lib/features/health/models/food_entry.dart`

```dart
import 'package:isar/isar.dart';
import '../../../core/constants/enums.dart';

part 'food_entry.g.dart';

@collection
class FoodEntry {
  Id id = Isar.autoIncrement;

  // ข้อมูลพื้นฐาน
  late String foodName;
  String? foodNameEn;
  late DateTime timestamp;
  String? imagePath;

  // มื้ออาหาร
  @enumerated
  late MealType mealType;

  // Serving Size
  late double servingSize; // 1.0, 0.5, 2.0
  late String servingUnit; // "จาน", "ถ้วย", "กรัม"
  double? servingGrams;

  // Macros (required)
  late double calories;
  late double protein;
  late double carbs;
  late double fat;

  // Micros (optional)
  double? fiber;
  double? sugar;
  double? sodium;
  double? cholesterol;
  double? saturatedFat;

  // Metadata
  @enumerated
  late DataSource source;
  double? aiConfidence;
  bool isVerified = false;
  String? notes;

  // Sync
  String? healthConnectId;
  DateTime? syncedAt;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
```

### 2.2 WorkoutEntry Model

**สร้างไฟล์:** `lib/features/health/models/workout_entry.dart`

```dart
import 'package:isar/isar.dart';
import '../../../core/constants/enums.dart';

part 'workout_entry.g.dart';

@collection
class WorkoutEntry {
  Id id = Isar.autoIncrement;

  // ข้อมูลพื้นฐาน
  late String activityName;
  @enumerated
  late ActivityType activityType;
  late DateTime timestamp;

  // Calories & Duration
  late double caloriesBurned;
  late int durationMinutes;

  // Activity-specific
  double? distanceKm;
  int? steps;
  int? avgHeartRate;
  int? maxHeartRate;

  // Strength training
  int? sets;
  int? reps;
  double? weightKg;

  // Metadata
  @enumerated
  late DataSource source;
  String? healthConnectId;
  String? notes;
  DateTime? syncedAt;

  DateTime createdAt = DateTime.now();
}
```

### 2.3 OtherHealthEntry Model

**สร้างไฟล์:** `lib/features/health/models/other_health_entry.dart`

```dart
import 'package:isar/isar.dart';
import '../../../core/constants/enums.dart';

part 'other_health_entry.g.dart';

@collection
class OtherHealthEntry {
  Id id = Isar.autoIncrement;

  @enumerated
  late HealthEntryType entryType;
  late DateTime timestamp;

  // For supplements/medicine
  String? name;
  double? dosage;
  String? unit; // mg, ml, IU

  // For water
  double? waterMl;

  // For biometrics
  double? weightKg;
  double? bodyFatPercent;
  int? systolicBP;   // ความดันตัวบน
  int? diastolicBP;  // ความดันตัวล่าง
  int? heartRate;
  double? bloodSugar; // mg/dL

  // For sleep
  int? sleepMinutes;
  int? deepSleepMinutes;
  int? remSleepMinutes;

  // Metadata
  @enumerated
  late DataSource source;
  String? healthConnectId;
  String? notes;

  DateTime createdAt = DateTime.now();
}
```

### 2.4 WorkoutProgram Models

**สร้างไฟล์:** `lib/features/health/models/workout_program.dart`

```dart
import 'package:isar/isar.dart';
import '../../../core/constants/enums.dart';

part 'workout_program.g.dart';

@collection
class WorkoutProgram {
  Id id = Isar.autoIncrement;

  late String name;
  String? description;

  @enumerated
  late ScheduleType scheduleType;

  late DateTime startDate;
  int? durationWeeks; // 4, 8, 12 weeks หรือ null = ไม่มีกำหนด

  bool isActive = false; // โปรแกรมที่ใช้อยู่ตอนนี้

  // For Weekly schedule (Day 1-7 → WorkoutDay IDs)
  List<int?> weeklyDayIds = [null, null, null, null, null, null, null];

  // For Rotating schedule (เช่น Push, Pull, Legs, Rest)
  List<int> rotatingDayIds = [];

  // For Interval schedule
  int? intervalTotalDays; // เช่น 3 = ออก 1 พัก 2
  int? intervalWorkDays;  // เช่น 1 = ออก 1 วัน
  int? workoutDayId;      // ทำ workout เดียวกันทุกครั้ง

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}

@collection
class WorkoutDay {
  Id id = Isar.autoIncrement;

  late String name; // "Push Day", "Legs Day"
  List<String> targetMuscles = []; // ["chest", "shoulder", "triceps"]

  int? estimatedMinutes;
  int? estimatedCalories;

  DateTime createdAt = DateTime.now();
}

@collection
class WorkoutExercise {
  Id id = Isar.autoIncrement;

  late int workoutDayId; // belongs to WorkoutDay

  late String name;      // "Bench Press"
  String? equipment;     // "Barbell", "Dumbbell", "Machine"
  String? muscleGroup;   // "Chest"

  late int sets;
  late int reps;
  double? weight; // kg
  int restSeconds = 60;

  int orderIndex = 0; // ลำดับใน workout day

  String? notes; // "Slow negative"
}

@collection
class WorkoutSession {
  Id id = Isar.autoIncrement;

  late DateTime date;
  late int workoutDayId;
  late int programId;

  DateTime? startedAt;
  DateTime? completedAt;

  bool isCompleted = false;
  String? notes;

  DateTime createdAt = DateTime.now();
}

@collection
class ExerciseLog {
  Id id = Isar.autoIncrement;

  late int sessionId;
  late int exerciseId;
  late String exerciseName;

  late int targetSets;
  late int targetReps;
  double? targetWeight;

  int completedSets = 0;
  bool isCompleted = false;

  // Actual performance
  double? actualWeight;
  List<int> actualReps = []; // [8, 8, 7, 6] ต่อ set
}
```

### 2.5 LabSession Models

**สร้างไฟล์:** `lib/features/health/models/lab_session.dart`

```dart
import 'package:isar/isar.dart';

part 'lab_session.g.dart';

@collection
class LabSession {
  Id id = Isar.autoIncrement;

  late DateTime date;
  String? location; // โรงพยาบาล/คลินิก
  String? title;    // "ตรวจประจำปี", "ตรวจ Lipid"
  String? notes;

  String? imagePath; // รูปผลตรวจ

  DateTime createdAt = DateTime.now();
}

@collection
class LabItem {
  Id id = Isar.autoIncrement;

  late int sessionId; // belongs to LabSession

  late String name;   // ชื่อรายการ
  late String value;  // ค่า (String เพราะบางทีมี range)
  String? unit;       // หน่วย

  String? normalRange; // "70-100", "<200"
  String? status;      // "normal", "high", "low"

  int? mappedToGroupId; // ถ้า merge ชื่อแล้ว
}

@collection
class LabItemGroup {
  Id id = Isar.autoIncrement;

  late String canonicalName; // ชื่อหลักที่ใช้แสดง
  List<String> aliases = []; // ชื่ออื่นๆ ที่ตรงกัน

  String? category;    // "CBC", "Lipid", "Glucose"
  String? unit;        // หน่วยหลัก
  String? normalRange; // ค่าปกติ
}
```

---

## ขั้นตอนที่ 3: สร้าง Finance Models

**สร้างไฟล์:** `lib/features/finance/models/transaction.dart`

```dart
import 'package:isar/isar.dart';
import '../../../core/constants/enums.dart';

part 'transaction.g.dart';

@collection
class Transaction {
  Id id = Isar.autoIncrement;

  @enumerated
  late TransactionType type;

  late double amount;
  late DateTime date;

  // Category (เก็บเป็น String เพราะอาจเป็น Income หรือ Expense)
  late String category;

  String? description;
  String? payee;        // ผู้รับ/ร้านค้า
  String? bankAccount;  // บัญชีธนาคาร

  String? imagePath; // รูปสลิป
  List<String> tags = [];

  @enumerated
  late DataSource source;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
```

**สร้างไฟล์:** `lib/features/finance/models/asset.dart`

```dart
import 'package:isar/isar.dart';
import '../../../core/constants/enums.dart';

part 'asset.g.dart';

@collection
class Asset {
  Id id = Isar.autoIncrement;

  late String symbol; // AOT.BK, K-USA, GOLD-TH
  late String name;

  @enumerated
  late AssetType type;

  @enumerated
  late LiquidityLevel liquidity;

  late String source; // yfinance, sec, thai_gold_api, manual

  // Quantity & Cost
  late double quantity;
  double? avgCost; // ราคาทุนเฉลี่ย

  // Current Price (auto-update)
  double? currentPrice;
  String? currency;
  DateTime? lastPriceUpdate;

  // Non-liquid specific
  String? location;       // ที่อยู่/ตำแหน่ง
  String? imagePath;      // รูปภาพ
  double? estimatedValue; // มูลค่าประมาณ
  DateTime? valueUpdatedAt;

  // Grouping
  int? groupId;

  String? notes;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}

@collection
class AssetGroup {
  Id id = Isar.autoIncrement;

  late String name; // "หุ้นไทย", "หุ้นต่างประเทศ"
  String? description;
  String? icon;

  double? targetAllocation; // สัดส่วนเป้าหมาย (%)

  DateTime createdAt = DateTime.now();
}

@collection
class PriceHistory {
  Id id = Isar.autoIncrement;

  late String symbol;
  late DateTime date;
  late double price;
  late String currency;

  @Index()
  late int timestamp; // for fast query
}
```

---

## ขั้นตอนที่ 4: สร้าง Task Models

**สร้างไฟล์:** `lib/features/tasks/models/task.dart`

```dart
import 'package:isar/isar.dart';
import '../../../core/constants/enums.dart';

part 'task.g.dart';

@collection
class Task {
  Id id = Isar.autoIncrement;

  late String title;
  String? description;

  @enumerated
  late TaskType type;

  @enumerated
  late TaskStatus status;

  @enumerated
  late TaskPriority priority;

  @enumerated
  late TaskSource source;

  // Timing (for calendar events)
  DateTime? dueDate;
  DateTime? dueTime;
  DateTime? endTime;
  bool isAllDay = false;

  // Linking
  String? category; // health, finance, general
  int? linkedWorkoutDayId;
  int? linkedGoalId;

  // Google Calendar
  String? googleEventId;
  String? googleCalendarLink;
  bool isSynced = false;

  // Completion
  DateTime? completedAt;
  String? completionNotes;

  // Meta
  List<String> tags = [];
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}

@collection
class ChecklistItem {
  Id id = Isar.autoIncrement;

  late int taskId;
  late String title;
  bool isCompleted = false;
  int orderIndex = 0;
}

@collection
class Habit {
  Id id = Isar.autoIncrement;

  late String name;
  String? icon;
  String? color;

  // Goal
  late String frequency; // daily, weekly
  int targetPerWeek = 7;

  // Streak
  int currentStreak = 0;
  int longestStreak = 0;
  DateTime? lastCompletedDate;

  bool isActive = true;
  DateTime createdAt = DateTime.now();
}

@collection
class HabitCompletion {
  Id id = Isar.autoIncrement;

  late int habitId;
  late DateTime date;
  String? notes;
}

@collection
class Reminder {
  Id id = Isar.autoIncrement;

  late String title;
  String? description;

  late String reminderType; // medicine, bill, healthCheck, custom

  // Timing
  String? dailyTime;  // HH:mm
  int? dayOfMonth;
  int? monthInterval;

  // Medicine specific
  String? medicineName;
  String? dosage;

  // Bill specific
  double? amount;
  String? payee;

  bool isActive = true;
  DateTime? lastTriggered;
  DateTime? nextTrigger;

  DateTime createdAt = DateTime.now();
}
```

---

## ขั้นตอนที่ 5: สร้าง Chat Models

**สร้างไฟล์:** `lib/features/chat/models/chat_message.dart`

```dart
import 'package:isar/isar.dart';

part 'chat_message.g.dart';

enum MessageRole { user, assistant }

@collection
class ChatMessage {
  Id id = Isar.autoIncrement;

  late String sessionId;

  @enumerated
  late MessageRole role;

  late String content;

  // Rich content
  String? responseType; // text, confirmCard, listCard, workoutCard
  String? cardDataJson; // JSON string ของ card data
  String? actionsJson;  // JSON string ของ actions

  // Metadata
  String? detectedIntent;
  double? confidence;

  DateTime createdAt = DateTime.now();
}

@collection
class ChatSession {
  Id id = Isar.autoIncrement;

  late String title;
  String? sessionId; // UUID

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
```

---

## ขั้นตอนที่ 6: สร้าง User Profile Model

**สร้างไฟล์:** `lib/features/profile/models/user_profile.dart`

```dart
import 'package:isar/isar.dart';

part 'user_profile.g.dart';

@collection
class UserProfile {
  Id id = Isar.autoIncrement;

  String? name;
  String? avatarPath;

  // Health Goals
  double calorieGoal = 2000;
  double proteinGoal = 120;
  double carbGoal = 250;
  double fatGoal = 65;
  double waterGoal = 2500; // ml

  // Settings
  bool isDarkMode = false;
  String? locale; // th, en

  // API Keys (encrypted)
  bool hasGeminiApiKey = false;

  // Connections
  bool isGoogleCalendarConnected = false;
  bool isHealthConnectConnected = false;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
```

---

## ขั้นตอนที่ 7: Run build_runner

**รันคำสั่งนี้ใน terminal:**

```bash
dart run build_runner build --delete-conflicting-outputs
```

**รอจนกว่าจะเสร็จ** - จะสร้างไฟล์ `.g.dart` สำหรับทุก model

---

## ขั้นตอนที่ 8: อัปเดต DatabaseService

**แก้ไขไฟล์:** `lib/core/database/database_service.dart`

```dart
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

// Health Models
import '../../features/health/models/food_entry.dart';
import '../../features/health/models/workout_entry.dart';
import '../../features/health/models/other_health_entry.dart';
import '../../features/health/models/workout_program.dart';
import '../../features/health/models/lab_session.dart';

// Finance Models
import '../../features/finance/models/transaction.dart';
import '../../features/finance/models/asset.dart';

// Task Models
import '../../features/tasks/models/task.dart';

// Chat Models
import '../../features/chat/models/chat_message.dart';

// Profile Models
import '../../features/profile/models/user_profile.dart';

class DatabaseService {
  static late Isar isar;

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();

    isar = await Isar.open(
      [
        // Health
        FoodEntrySchema,
        WorkoutEntrySchema,
        OtherHealthEntrySchema,
        WorkoutProgramSchema,
        WorkoutDaySchema,
        WorkoutExerciseSchema,
        WorkoutSessionSchema,
        ExerciseLogSchema,
        LabSessionSchema,
        LabItemSchema,
        LabItemGroupSchema,
        
        // Finance
        TransactionSchema,
        AssetSchema,
        AssetGroupSchema,
        PriceHistorySchema,
        
        // Tasks
        TaskSchema,
        ChecklistItemSchema,
        HabitSchema,
        HabitCompletionSchema,
        ReminderSchema,
        
        // Chat
        ChatMessageSchema,
        ChatSessionSchema,
        
        // Profile
        UserProfileSchema,
      ],
      directory: dir.path,
      name: 'miro_db',
    );
  }

  // Health Queries
  static IsarCollection<FoodEntry> get foodEntries => isar.foodEntrys;
  static IsarCollection<WorkoutEntry> get workoutEntries => isar.workoutEntrys;
  static IsarCollection<OtherHealthEntry> get otherHealthEntries => isar.otherHealthEntrys;
  static IsarCollection<WorkoutProgram> get workoutPrograms => isar.workoutPrograms;
  static IsarCollection<WorkoutDay> get workoutDays => isar.workoutDays;
  static IsarCollection<WorkoutExercise> get workoutExercises => isar.workoutExercises;
  static IsarCollection<LabSession> get labSessions => isar.labSessions;
  static IsarCollection<LabItem> get labItems => isar.labItems;

  // Finance Queries
  static IsarCollection<Transaction> get transactions => isar.transactions;
  static IsarCollection<Asset> get assets => isar.assets;
  static IsarCollection<AssetGroup> get assetGroups => isar.assetGroups;

  // Task Queries
  static IsarCollection<Task> get tasks => isar.tasks;
  static IsarCollection<Habit> get habits => isar.habits;
  static IsarCollection<Reminder> get reminders => isar.reminders;

  // Chat Queries
  static IsarCollection<ChatMessage> get chatMessages => isar.chatMessages;
  static IsarCollection<ChatSession> get chatSessions => isar.chatSessions;

  // Profile Queries
  static IsarCollection<UserProfile> get userProfiles => isar.userProfiles;
}
```

---

## ขั้นตอนที่ 9: ทดสอบ

```bash
flutter run
```

**ผลที่ควรได้:** แอปเปิดขึ้นมาได้โดยไม่มี error

---

## ✅ Checklist

- [ ] สร้างไฟล์ enums.dart แล้ว
- [ ] สร้าง Health Models ทั้งหมดแล้ว
  - [ ] food_entry.dart
  - [ ] workout_entry.dart
  - [ ] other_health_entry.dart
  - [ ] workout_program.dart
  - [ ] lab_session.dart
- [ ] สร้าง Finance Models ทั้งหมดแล้ว
  - [ ] transaction.dart
  - [ ] asset.dart
- [ ] สร้าง Task Models ทั้งหมดแล้ว
  - [ ] task.dart
- [ ] สร้าง Chat Models แล้ว
  - [ ] chat_message.dart
- [ ] สร้าง Profile Model แล้ว
  - [ ] user_profile.dart
- [ ] รัน build_runner สำเร็จ (มีไฟล์ .g.dart)
- [ ] อัปเดต DatabaseService แล้ว
- [ ] ทดสอบ run app สำเร็จ

---

## ไฟล์ที่สร้างในขั้นตอนนี้

```
lib/
├── core/
│   ├── constants/
│   │   └── enums.dart              ← NEW
│   └── database/
│       └── database_service.dart   ← UPDATED
├── features/
│   ├── health/
│   │   └── models/
│   │       ├── food_entry.dart     ← NEW
│   │       ├── food_entry.g.dart   ← GENERATED
│   │       ├── workout_entry.dart  ← NEW
│   │       ├── workout_entry.g.dart
│   │       ├── other_health_entry.dart
│   │       ├── other_health_entry.g.dart
│   │       ├── workout_program.dart
│   │       ├── workout_program.g.dart
│   │       ├── lab_session.dart
│   │       └── lab_session.g.dart
│   ├── finance/
│   │   └── models/
│   │       ├── transaction.dart
│   │       ├── transaction.g.dart
│   │       ├── asset.dart
│   │       └── asset.g.dart
│   ├── tasks/
│   │   └── models/
│   │       ├── task.dart
│   │       └── task.g.dart
│   ├── chat/
│   │   └── models/
│   │       ├── chat_message.dart
│   │       └── chat_message.g.dart
│   └── profile/
│       └── models/
│           ├── user_profile.dart
│           └── user_profile.g.dart
```

---

## ขั้นตอนถัดไป

ไปที่ **Step 02: Home Screen with Tabs** เพื่อสร้างหน้าหลักพร้อม Bottom Navigation
