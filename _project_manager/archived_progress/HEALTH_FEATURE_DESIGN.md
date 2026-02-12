# Miro Health Feature - Detailed Design

> **โฟกัส:** สร้าง Health Tracking ที่ดีที่สุดสำหรับคนขี้เกียจ
> **อ้างอิง:** MyFitnessPal, Cronometer, Lose It!

---

## 1. โครงสร้าง Health Section

### Bottom Tab: 🍎 สุขภาพ → มี Sub-Tabs ด้านบน

```
┌─────────────────────────────────────────────────┐
│  [👤]           Miro                      [⚙️]  │
├─────────────────────────────────────────────────┤
│ [Timeline] [Diet] [Workout] [Other] [🩺 Lab]   │  ← Sub-tabs (5 tabs)
├─────────────────────────────────────────────────┤
│                                                 │
│              📜 Content Area                    │
│              (ตาม Sub-tab ที่เลือก)             │
│                                                 │
├─────────────────────────────────────────────────┤
│                                           [ ✨ ]│ขอเป็นปุ่ม เล็กๆ ขวาล่างเหลือ tabหลัก
├─────────────────────────────────────────────────┤
│    💰 เงิน    │   🍎 สุขภาพ ✓  │    📅 งาน     │
└─────────────────────────────────────────────────┘
```

---

## 2. Sub-Tabs ภายใน Health

### 2.1 📜 Timeline Tab (default)

**วัตถุประสงค์:** แสดงทุกอย่างเรียงตามเวลา มี date separator

```
┌─────────────────────────────────────────────────┐
│  ══════════ 📅 วันนี้ - 3 ก.พ. 2569 ══════════  │
├─────────────────────────────────────────────────┤
│  🍜 ข้าวผัดกุ้ง                      12:30 น.   │
│  520 kcal • P:25g C:65g F:18g                   │
├─────────────────────────────────────────────────┤
│  🏃 วิ่ง 3 กม.                       07:00 น.   │
│  -280 kcal • 25 นาที                            │
├─────────────────────────────────────────────────┤
│  💊 วิตามิน C                        06:30 น.   │
│  1000mg                                         │
├─────────────────────────────────────────────────┤
│  ═══════════ 📅 เมื่อวาน - 2 ก.พ. ═══════════   │
├─────────────────────────────────────────────────┤
│  🍕 พิซซ่า                           19:00 น.   │
│  850 kcal • P:32g C:90g F:38g                   │
└─────────────────────────────────────────────────┘
```

### 2.2 🍽️ Diet Tab

**วัตถุประสงค์:** แสดงเฉพาะอาหาร + สรุปโภชนาการรายวัน  ต้อง edit รายการได้

```
┌─────────────────────────────────────────────────┐
│  ╔═══════════════════════════════════════════╗  │
│  ║  🔥 วันนี้ 1,250 / 2,000 kcal             ║  │
│  ║  ████████████░░░░░░░░░░░░░░░  63%         ║  │
│  ║                                           ║  │
│  ║  💪 P: 68g/120g  🍞 C: 145g/250g  🥑 F: 42g/65g  │
│  ╚═══════════════════════════════════════════╝  │
├─────────────────────────────────────────────────┤
│  ☀️ มื้อเช้า (380 kcal)                         │
│  ├─ 🥗 สลัดผัก            180 kcal             │
│  └─ 🥚 ไข่ต้ม 2 ฟอง       200 kcal             │
├─────────────────────────────────────────────────┤
│  🌤️ มื้อกลางวัน (520 kcal)                      │
│  └─ 🍜 ข้าวผัดกุ้ง        520 kcal             │
├─────────────────────────────────────────────────┤
│  🌙 มื้อเย็น (350 kcal)                         │
│  └─ 🍲 ต้มยำกุ้ง          350 kcal             │
├─────────────────────────────────────────────────┤
│  🍿 ของว่าง (0 kcal)                            │
│  └─ (ยังไม่มีรายการ)                            │
└─────────────────────────────────────────────────┘
```

### 2.3 🏋️ Workout Tab

**วัตถุประสงค์:** แสดงการออกกำลังกาย + โปรแกรมออกกำลัง + สรุป

```
┌─────────────────────────────────────────────────┐
│  ╔═══════════════════════════════════════════╗  │
│  ║  🔥 เผาผลาญวันนี้: 450 kcal                ║  │
│  ║  ⏱️ ออกกำลังกาย: 45 นาที                   ║  │
│  ║  👣 ก้าวเดิน: 8,234 / 10,000               ║  │
│  ╚═══════════════════════════════════════════╝  │
├─────────────────────────────────────────────────┤
│  📋 โปรแกรมวันนี้: Push Day (Week 2/4)   [ดู →] │
│  ─────────────────────────────────────────────  │
│  ✅ Bench Press        4x8    60kg             │
│  ✅ Shoulder Press     3x10   30kg             │
│  ⬜ Tricep Pushdown    3x12   25kg             │
│  ⬜ Lateral Raise      3x15   8kg              │
│           [✓ เสร็จแล้ว บันทึก]                  │
├─────────────────────────────────────────────────┤
│  📅 ประวัติวันนี้                               │
│  ├─ 🏃 วิ่ง            -280 kcal  •  25 นาที   │
│  └─ 🧘 โยคะ           -170 kcal  •  20 นาที   │
├─────────────────────────────────────────────────┤
│  📅 เมื่อวาน                                    │
│  └─ 🚴 ปั่นจักรยาน    -320 kcal  •  30 นาที   │
└─────────────────────────────────────────────────┘

         [📋 จัดการโปรแกรม]  ← ปุ่มไปหน้า Program Manager
```

---

## 3. Workout Program Management (อ้างอิง: Strong, JEFIT, Hevy)

### 3.1 Concept

```
┌─────────────────────────────────────────────────┐
│                                                 │
│  📋 WORKOUT PROGRAM                             │
│  ═════════════════════════════════════════════  │
│                                                 │
│  ผู้ใช้สร้างโปรแกรมเอง (ไม่ใช่ AI สร้าง)         │
│  → กำหนดว่าวันไหนทำอะไร                         │
│  → กำหนด exercises, sets, reps, weight          │
│                                                 │
│  เมื่อถึงวันนั้น:                                │
│  → AI ดึงโปรแกรมมาสร้าง Task List               │
│  → User check ที่ทำเสร็จ                        │
│  → เมื่อครบ → บันทึกเป็น Workout Entry อัตโนมัติ │
│                                                 │
└─────────────────────────────────────────────────┘
```

### 3.2 Schedule Types (ผู้ใช้เลือกได้)

| Type | Description | ตัวอย่าง |
|------|-------------|----------|
| **Weekly** | กำหนดตามวันในสัปดาห์ | จันทร์=Push, พุธ=Pull, ศุกร์=Legs |
| **Rotating** | หมุนเวียนทุก X วัน | Push→Pull→Legs→Rest→วนซ้ำ |
| **Interval** | วันเว้นวัน, 1 เว้น 2 | ออกวันจันทร์ → พัก 2 วัน → ออก |
| **Custom** | กำหนดวันที่เอง | วันที่ 1, 3, 5, 8, 10... |

### 3.3 Program Structure (Data Model)

```
┌─────────────────────────────────────────────────┐
│  WORKOUT PROGRAM                                │
│  ├── name: "Push Pull Legs 6 Days"             │
│  ├── scheduleType: weekly | rotating | interval │
│  ├── isActive: true                            │
│  │                                              │
│  ├── WORKOUT DAYS (ถ้า weekly)                  │
│  │   ├── Day 1 (จันทร์): Push Day              │
│  │   ├── Day 2 (อังคาร): Pull Day              │
│  │   ├── Day 3 (พุธ): Legs Day                 │
│  │   ├── Day 4 (พฤหัส): Push Day               │
│  │   ├── Day 5 (ศุกร์): Pull Day               │
│  │   ├── Day 6 (เสาร์): Legs Day               │
│  │   └── Day 7 (อาทิตย์): Rest                 │
│  │                                              │
│  └── WORKOUT DAYS (ถ้า rotating)                │
│      ├── Day 1: Push Day                       │
│      ├── Day 2: Pull Day                       │
│      ├── Day 3: Legs Day                       │
│      ├── Day 4: Rest                           │
│      └── (วนซ้ำ)                                │
│                                                 │
│  WORKOUT DAY                                    │
│  ├── name: "Push Day"                          │
│  ├── targetMuscles: ["chest", "shoulder", "triceps"] │
│  │                                              │
│  └── EXERCISES                                  │
│      ├── Exercise 1                            │
│      │   ├── name: "Bench Press"               │
│      │   ├── sets: 4                           │
│      │   ├── reps: 8                           │
│      │   ├── weight: 60 (kg)                   │
│      │   └── restSeconds: 90                   │
│      ├── Exercise 2                            │
│      │   ├── name: "Shoulder Press"            │
│      │   └── ...                               │
│      └── ...                                   │
└─────────────────────────────────────────────────┘
```

### 3.4 Program Manager Screen

```
┌─────────────────────────────────────────────────┐
│  ← โปรแกรมออกกำลังกาย                            │
├─────────────────────────────────────────────────┤
│                                                 │
│  ╔═══════════════════════════════════════════╗  │
│  ║  🏋️ Push Pull Legs 6 Days      [Active ✓] ║  │
│  ║  ประเภท: Weekly                           ║  │
│  ║  สัปดาห์ที่: 2/4                           ║  │
│  ╚═══════════════════════════════════════════╝  │
│                                                 │
│  ─────────────────────────────────────────────  │
│                                                 │
│  📅 ตารางสัปดาห์นี้:                            │
│  ┌────┬────┬────┬────┬────┬────┬────┐          │
│  │ จ  │ อ  │ พ  │ พฤ │ ศ  │ ส  │ อา │          │
│  ├────┼────┼────┼────┼────┼────┼────┤          │
│  │Push│Pull│Legs│Push│Pull│Legs│REST│          │
│  │ ✓  │ ✓  │today│   │    │    │    │          │
│  └────┴────┴────┴────┴────┴────┴────┘          │
│                                                 │
│  ─────────────────────────────────────────────  │
│                                                 │
│  📋 Workout Days ในโปรแกรม:                     │
│  ├─ 💪 Push Day (6 exercises)         [แก้ไข]  │
│  ├─ 💪 Pull Day (5 exercises)         [แก้ไข]  │
│  └─ 🦵 Legs Day (6 exercises)         [แก้ไข]  │
│                                                 │
│  ─────────────────────────────────────────────  │
│                                                 │
│  [+ สร้างโปรแกรมใหม่]                            │
│                                                 │
│  📂 โปรแกรมอื่นๆ:                                │
│  └─ 🏃 Cardio Week (ไม่ active)       [เปิดใช้] │
│                                                 │
└─────────────────────────────────────────────────┘
```

### 3.5 Create/Edit Workout Day

```
┌─────────────────────────────────────────────────┐
│  ← แก้ไข Push Day                               │
├─────────────────────────────────────────────────┤
│                                                 │
│  📝 ชื่อ: Push Day                              │
│                                                 │
│  🎯 กล้ามเนื้อเป้าหมาย:                          │
│  [Chest ✓] [Shoulder ✓] [Triceps ✓] [+ เพิ่ม]  │
│                                                 │
│  ─────────────────────────────────────────────  │
│                                                 │
│  💪 Exercises:                                  │
│  ┌─────────────────────────────────────────┐   │
│  │ 1. Bench Press                          │   │
│  │    Sets: [4]  Reps: [8]  Weight: [60]kg │   │
│  │    Rest: [90] sec                       │   │
│  │                         [🗑️] [↑] [↓]   │   │
│  ├─────────────────────────────────────────┤   │
│  │ 2. Incline Dumbbell Press               │   │
│  │    Sets: [3]  Reps: [10] Weight: [24]kg │   │
│  │    Rest: [60] sec                       │   │
│  │                         [🗑️] [↑] [↓]   │   │
│  ├─────────────────────────────────────────┤   │
│  │ 3. Shoulder Press                       │   │
│  │    Sets: [3]  Reps: [10] Weight: [30]kg │   │
│  │    Rest: [60] sec                       │   │
│  │                         [🗑️] [↑] [↓]   │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  [+ เพิ่ม Exercise]                             │
│                                                 │
│              [ยกเลิก]  [💾 บันทึก]               │
│                                                 │
└─────────────────────────────────────────────────┘
```

### 3.6 Exercise Picker (ค้นหา/เลือก Exercise)

```
┌─────────────────────────────────────────────────┐
│  ← เลือก Exercise                               │
├─────────────────────────────────────────────────┤
│                                                 │
│  🔍 [ค้นหา exercise...                    ]    │
│                                                 │
│  📂 หมวดหมู่:                                   │
│  [All] [Chest] [Back] [Shoulder] [Arms] [Legs] │
│                                                 │
│  ─────────────────────────────────────────────  │
│                                                 │
│  💪 Chest                                       │
│  ├─ Bench Press (Barbell)                      │
│  ├─ Bench Press (Dumbbell)                     │
│  ├─ Incline Bench Press                        │
│  ├─ Decline Bench Press                        │
│  ├─ Chest Fly                                  │
│  ├─ Cable Crossover                            │
│  └─ Push Up                                    │
│                                                 │
│  💪 Shoulder                                    │
│  ├─ Shoulder Press                             │
│  ├─ Lateral Raise                              │
│  └─ ...                                        │
│                                                 │
│  ─────────────────────────────────────────────  │
│  [+ สร้าง Exercise ใหม่]   ← Custom exercise    │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

## 4. AI + Task Integration (Workout to Task)

### 4.1 Flow: ถาม AI ขอโปรแกรมวันนี้

```
┌─────────────────────────────────────────────────┐
│  💬 Chat (Task Mode)                            │
├─────────────────────────────────────────────────┤
│                                                 │
│  👤 User: "ขอโปรแกรมออกกำลังวันนี้หน่อย"         │
│                                                 │
│  🤖 AI: ตรวจสอบโปรแกรมของคุณ...                 │
│                                                 │
│  ╔═══════════════════════════════════════════╗  │
│  ║  📋 วันนี้ (พุธ) = Legs Day                 ║  │
│  ║  จากโปรแกรม: Push Pull Legs 6 Days        ║  │
│  ╚═══════════════════════════════════════════╝  │
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │ ⬜ Squat               4x8    80kg      │   │
│  │ ⬜ Leg Press           4x10   120kg     │   │
│  │ ⬜ Romanian Deadlift   3x10   60kg      │   │
│  │ ⬜ Leg Curl            3x12   40kg      │   │
│  │ ⬜ Leg Extension       3x12   50kg      │   │
│  │ ⬜ Calf Raise          4x15   60kg      │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  [📋 สร้าง Task List]  [ดูใน Workout Tab]       │
│                                                 │
└─────────────────────────────────────────────────┘
```

### 4.2 Task List View (ใน Task Tab)

```
┌─────────────────────────────────────────────────┐
│  📅 Task วันนี้                                  │
├─────────────────────────────────────────────────┤
│                                                 │
│  ══════════ 🏋️ Legs Day ══════════             │
│  ┌─────────────────────────────────────────┐   │
│  │ ✅ Squat               4x8    80kg      │   │ ← กด check
│  │ ✅ Leg Press           4x10   120kg     │   │
│  │ ✅ Romanian Deadlift   3x10   60kg      │   │
│  │ ⬜ Leg Curl            3x12   40kg      │   │
│  │ ⬜ Leg Extension       3x12   50kg      │   │
│  │ ⬜ Calf Raise          4x15   60kg      │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  Progress: 3/6 (50%)                           │
│  ████████████░░░░░░░░░░░░                      │
│                                                 │
│  ⏱️ เริ่ม: 17:30  •  ผ่านไป: 25 นาที            │
│                                                 │
│  ─────────────────────────────────────────────  │
│                                                 │
│  ══════════ Other Tasks ══════════             │
│  ⬜ ประชุม Team Weekly           14:00        │
│  ✅ ส่งรายงาน                     10:00        │
│                                                 │
└─────────────────────────────────────────────────┘
```

### 4.3 Auto-Complete → บันทึก Workout

```
เมื่อ check ครบทุก exercise:

┌─────────────────────────────────────────────────┐
│                                                 │
│  🎉 Workout Complete!                           │
│                                                 │
│  ╔═══════════════════════════════════════════╗  │
│  ║  🏋️ Legs Day                               ║  │
│  ║  ⏱️ ใช้เวลา: 52 นาที                        ║  │
│  ║  🔥 เผาผลาญ: ~320 kcal (ประมาณ)             ║  │
│  ║  💪 6 exercises completed                  ║  │
│  ╚═══════════════════════════════════════════╝  │
│                                                 │
│  บันทึกไปที่:                                   │
│  • ✅ Health → Workout history                 │
│  • ✅ Health → Timeline                        │
│  • ✅ Health Connect (ถ้าเปิดไว้)               │
│                                                 │
│  หมายเหตุ (optional):                          │
│  ┌─────────────────────────────────────────┐   │
│  │ รู้สึกหนักกว่าปกติ เพิ่มน้ำหนักได้         │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│              [✓ บันทึก]                         │
│                                                 │
└─────────────────────────────────────────────────┘
```

### 4.4 Schedule Logic (สำหรับ AI)

```dart
// AI Logic: หาว่าวันนี้ต้องทำ Workout อะไร

class WorkoutScheduler {
  
  WorkoutDay? getTodayWorkout(WorkoutProgram program) {
    final today = DateTime.now();
    
    switch (program.scheduleType) {
      
      case ScheduleType.weekly:
        // วันจันทร์ = 1, อาทิตย์ = 7
        final dayOfWeek = today.weekday;
        return program.weeklySchedule[dayOfWeek];
        
      case ScheduleType.rotating:
        // นับจากวันเริ่มโปรแกรม
        final daysSinceStart = today.difference(program.startDate).inDays;
        final cycleLength = program.rotatingDays.length;
        final currentDayInCycle = daysSinceStart % cycleLength;
        return program.rotatingDays[currentDayInCycle];
        
      case ScheduleType.interval:
        // เช่น ออก 1 วัน พัก 2 วัน (interval = 3)
        final daysSinceStart = today.difference(program.startDate).inDays;
        final position = daysSinceStart % program.intervalDays;
        // ถ้า position < workDays → เป็นวันออกกำลัง
        if (position < program.workDaysCount) {
          return program.workoutDay;
        }
        return null; // Rest day
        
      case ScheduleType.custom:
        // ดูจาก list วันที่กำหนด
        return program.customDates[today];
    }
  }
}
```

---

## 5. Data Models (Workout Program)

### 5.1 WorkoutProgram

```dart
@collection
class WorkoutProgram {
  Id id = Isar.autoIncrement;
  
  late String name;
  String? description;
  
  @enumerated
  late ScheduleType scheduleType;
  
  late DateTime startDate;
  int? durationWeeks;           // 4, 8, 12 weeks หรือ null = ไม่มีกำหนด
  
  bool isActive = false;        // โปรแกรมที่ใช้อยู่ตอนนี้
  
  // For Weekly schedule
  List<int>? weeklyDayIds;      // Day 1-7 → WorkoutDay IDs
  
  // For Rotating schedule  
  List<int>? rotatingDayIds;    // [Push, Pull, Legs, Rest] → IDs
  
  // For Interval schedule
  int? intervalTotalDays;       // เช่น 3 = ออก 1 พัก 2
  int? intervalWorkDays;        // เช่น 1 = ออก 1 วัน
  int? workoutDayId;            // ทำ workout เดียวกันทุกครั้ง
  
  DateTime createdAt = DateTime.now();
}

enum ScheduleType { weekly, rotating, interval, custom }
```

### 5.2 WorkoutDay

```dart
@collection
class WorkoutDay {
  Id id = Isar.autoIncrement;
  
  late String name;             // "Push Day", "Legs Day"
  List<String> targetMuscles = [];  // ["chest", "shoulder", "triceps"]
  
  final exercises = IsarLinks<WorkoutExercise>();
  
  int? estimatedMinutes;
  int? estimatedCalories;
}
```

### 5.3 WorkoutExercise

```dart
@collection  
class WorkoutExercise {
  Id id = Isar.autoIncrement;
  
  late String name;             // "Bench Press"
  String? equipment;            // "Barbell", "Dumbbell", "Machine"
  String? muscleGroup;          // "Chest"
  
  late int sets;
  late int reps;
  double? weight;               // kg
  int restSeconds = 60;
  
  int orderIndex = 0;           // ลำดับใน workout day
  
  String? notes;                // "Slow negative"
}
```

### 5.4 WorkoutTaskSession (เมื่อสร้าง Task List)

```dart
@collection
class WorkoutTaskSession {
  Id id = Isar.autoIncrement;
  
  late DateTime date;
  late int workoutDayId;
  late int programId;
  
  List<ExerciseProgress> exercises = [];
  
  DateTime? startedAt;
  DateTime? completedAt;
  
  bool isCompleted = false;
  String? notes;
}

@embedded
class ExerciseProgress {
  late int exerciseId;
  late String exerciseName;
  late int targetSets;
  late int targetReps;
  double? targetWeight;
  
  int completedSets = 0;
  bool isCompleted = false;
  
  // Actual performance (อาจต่างจาก target)
  double? actualWeight;
  List<int>? actualReps;        // [8, 8, 7, 6] ต่อ set
}
```

### 2.4 📦 Other Tab

**วัตถุประสงค์:** ดูและ edit เพิ่มรายการ เช่น ยา, วิตามิน, น้ำ, นอน, biometrics ข้อมูลการแพทย์ ความดัน น้ำตาล (เช่นบอก ai ว่า "วันนี้วัดน้ำตาลได้ 110" ก็บันทึกให้แล้วแสดงตรงนี้ กับ timeline)

```
┌─────────────────────────────────────────────────┐
│  ╔═══════════════════════════════════════════╗  │
│  ║  💧 น้ำวันนี้: 1.5 / 2.5 ลิตร              ║  │
│  ║  ██████████████░░░░░░░░░░░  60%           ║  │
│  ║                                           ║  │
│  ║  😴 นอนเมื่อคืน: 6.5 ชม.                   ║  │
│  ╚═══════════════════════════════════════════╝  │
├─────────────────────────────────────────────────┤
│  💊 ยา/วิตามิน วันนี้                           │
│  ├─ ✅ วิตามิน C       1000mg    06:30        │
│  ├─ ✅ วิตามิน D       400 IU    06:30        │
│  └─ ⬜ ยาลดความดัน     (รอกิน 18:00)          │
├─────────────────────────────────────────────────┤
│  📊 Biometrics ล่าสุด                          │
│  ├─ ⚖️ น้ำหนัก        72.5 kg   (เมื่อวาน)    │
│  ├─ ❤️ ชีพจร         72 bpm    (HealthConnect)│
│  └─ 🩸 ความดัน       120/80    (2 วันก่อน)   │
└─────────────────────────────────────────────────┘
```

### 2.5 🩺 Lab Results Tab (ผลตรวจสุขภาพ)

**วัตถุประสงค์:** บันทึกผลตรวจสุขภาพแบบ open-ended เพราะแต่ละคนตรวจไม่เหมือนกัน

#### Concept

```
┌─────────────────────────────────────────────────┐
│                                                 │
│  🩺 LAB RESULTS - Open-Ended Structure          │
│  ═══════════════════════════════════════════   │
│                                                 │
│  ปัญหา: คนตรวจสุขภาพไม่เหมือนกัน               │
│  • บางคนตรวจทั่วไป (CBC, Lipid Profile)        │
│  • บางคนตรวจละเอียด (Tumor Markers, Hormones)  │
│  • แต่ละโรงพยาบาลใช้ชื่อต่างกัน!               │
│                                                 │
│  วิธีแก้: Open-ended key-value pairs           │
│  • AI อ่านรูป → กรอกค่าเท่าที่อ่านได้          │
│  • ผู้ใช้ตรวจทาน → แก้ไข/ยืนยัน                │
│  • ชื่อไม่ตรงกัน = บันทึกแยก                   │
│  • ผู้ใช้เปลี่ยนชื่อให้ตรง = เอามาเทียบได้      │
│                                                 │
└─────────────────────────────────────────────────┘
```

#### Main View

```
┌─────────────────────────────────────────────────┐
│  🩺 ผลตรวจสุขภาพ                                 │
├─────────────────────────────────────────────────┤
│                                                 │
│  📅 ผลตรวจล่าสุด                                 │
│  ┌─────────────────────────────────────────┐   │
│  │  🏥 ตรวจสุขภาพประจำปี                    │   │
│  │  📅 15 ม.ค. 2569                        │   │
│  │  📋 12 รายการ                           │   │
│  │                             [ดูรายละเอียด]│   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  📊 ค่าที่ควรติดตาม (เทียบกับครั้งก่อน)          │
│  ┌─────────────────────────────────────────┐   │
│  │  Cholesterol     195 → 180  ↓ ดีขึ้น    │   │
│  │  Triglyceride    150 → 165  ↑ สูงขึ้น   │   │
│  │  Glucose (FBS)   95  → 92   ↓ ดีขึ้น    │   │
│  │  HbA1c           5.4 → 5.2  ↓ ดีขึ้น    │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  ─────────────────────────────────────────────  │
│                                                 │
│  📂 ประวัติการตรวจ                              │
│  ├─ 📋 15 ม.ค. 2569 - ตรวจประจำปี (12 items)   │
│  ├─ 📋 10 ก.ค. 2568 - ตรวจประจำปี (15 items)   │
│  └─ 📋 5 ม.ค. 2568 - ตรวจ Lipid (4 items)      │
│                                                 │
│  ─────────────────────────────────────────────  │
│                                                 │
│       [📷 ถ่ายรูปผลตรวจใหม่]                     │
│                                                 │
└─────────────────────────────────────────────────┘
```

#### Lab Result Detail View

```
┌─────────────────────────────────────────────────┐
│  ← ผลตรวจ 15 ม.ค. 2569                          │
├─────────────────────────────────────────────────┤
│                                                 │
│  🏥 ตรวจสุขภาพประจำปี                           │
│  📍 โรงพยาบาล XYZ                               │
│                                                 │
│  ─────────────────────────────────────────────  │
│                                                 │
│  🩸 Complete Blood Count (CBC)                  │
│  ┌────────────────┬────────┬─────────┬──────┐  │
│  │ รายการ          │ ค่า     │ หน่วย    │ เทียบ │ │
│  ├────────────────┼────────┼─────────┼──────┤  │
│  │ WBC            │ 7,200  │ /µL     │ =    │  │
│  │ RBC            │ 4.8    │ M/µL    │ =    │  │
│  │ Hemoglobin     │ 14.2   │ g/dL    │ ↑    │  │
│  │ Hematocrit     │ 42     │ %       │ =    │  │
│  │ Platelet       │ 250,000│ /µL     │ =    │  │
│  └────────────────┴────────┴─────────┴──────┘  │
│                                                 │
│  📊 Lipid Profile                              │
│  ┌────────────────┬────────┬─────────┬──────┐  │
│  │ รายการ          │ ค่า     │ หน่วย    │ เทียบ │ │
│  ├────────────────┼────────┼─────────┼──────┤  │
│  │ Cholesterol    │ 180    │ mg/dL   │ ↓    │  │ ← ดีขึ้น!
│  │ Triglyceride   │ 165    │ mg/dL   │ ↑    │  │ ← สูงขึ้น
│  │ HDL            │ 55     │ mg/dL   │ ↑    │  │
│  │ LDL            │ 105    │ mg/dL   │ ↓    │  │
│  └────────────────┴────────┴─────────┴──────┘  │
│                                                 │
│  🍬 Glucose                                     │
│  ┌────────────────┬────────┬─────────┬──────┐  │
│  │ FBS            │ 92     │ mg/dL   │ ↓    │  │
│  │ HbA1c          │ 5.2    │ %       │ ↓    │  │
│  └────────────────┴────────┴─────────┴──────┘  │
│                                                 │
│  📎 รูปต้นฉบับ: [ดูรูป]                          │
│                                                 │
│       [✏️ แก้ไข]  [📊 ดูกราฟ]                    │
│                                                 │
└─────────────────────────────────────────────────┘
```

#### Add New Lab Result (AI + Manual)

```
┌─────────────────────────────────────────────────┐
│  ← เพิ่มผลตรวจใหม่                               │
├─────────────────────────────────────────────────┤
│                                                 │
│  📷 รูปผลตรวจ:                                   │
│  ┌─────────────────────────────────────────┐   │
│  │                                         │   │
│  │        [🖼️ รูปผลตรวจสุขภาพ]            │   │
│  │                                         │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  ─────────────────────────────────────────────  │
│                                                 │
│  ⚠️ ต้องใช้ Gemini AI วิเคราะห์ (Cloud API)     │
│  ┌─────────────────────────────────────────┐   │
│  │  📊 Quota วันนี้: 10/15 requests         │   │
│  │                                         │   │
│  │  [✨ ใช้ AI อ่านผลตรวจ]   [✏️ กรอกเอง]  │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  ─────────────────────────────────────────────  │
│  (หลัง AI วิเคราะห์)                            │
│                                                 │
│  ✅ AI อ่านได้ 12 รายการ (กรุณาตรวจสอบ)          │
│                                                 │
│  📅 วันที่ตรวจ: [15/01/2569       ]            │
│  🏥 สถานที่:   [โรงพยาบาล XYZ     ]            │
│  📝 หมายเหตุ:  [ตรวจประจำปี       ]            │
│                                                 │
│  ─────────────────────────────────────────────  │
│                                                 │
│  📋 รายการที่อ่านได้: (กดแก้ไขได้เลย)            │
│  ┌────────────────┬────────┬─────────┬──────┐  │
│  │ ชื่อรายการ [✏️] │ ค่า [✏️]│ หน่วย [✏️]│ ลบ  │  │
│  ├────────────────┼────────┼─────────┼──────┤  │
│  │ WBC            │ 7200   │ /µL     │ 🗑️   │  │
│  │ RBC            │ 4.8    │ M/µL    │ 🗑️   │  │
│  │ Hemoglobin     │ 14.2   │ g/dL    │ 🗑️   │  │
│  │ ...            │ ...    │ ...     │ ...  │  │
│  └────────────────┴────────┴─────────┴──────┘  │
│                                                 │
│  [+ เพิ่มรายการ]                                │
│                                                 │
│              [ยกเลิก]  [💾 บันทึก]               │
│                                                 │
└─────────────────────────────────────────────────┘
```

#### Name Matching Logic (เปรียบเทียบข้ามครั้ง)

```
┌─────────────────────────────────────────────────┐
│                                                 │
│  🔗 NAME MATCHING LOGIC                         │
│  ═══════════════════════════════════════════   │
│                                                 │
│  ปัญหา: ชื่อรายการไม่ตรงกันข้ามครั้ง             │
│                                                 │
│  ครั้งที่ 1: "WBC"                             │
│  ครั้งที่ 2: "White Blood Cell"                │
│  ครั้งที่ 3: "W.B.C."                          │
│                                                 │
│  วิธีแก้:                                       │
│  ─────────────────────────────────────────────  │
│                                                 │
│  1. บันทึกตามที่เขียนมา (ไม่แก้ให้)             │
│     → "WBC", "White Blood Cell", "W.B.C."      │
│       บันทึกแยกกัน 3 records                   │
│                                                 │
│  2. ถ้าผู้ใช้ต้องการเปรียบเทียบ                 │
│     → เปิดหน้า "จัดการชื่อรายการ"               │
│     → เลือก merge ชื่อที่ตรงกัน                 │
│                                                 │
│  3. ระบบแนะนำ (optional)                       │
│     → "White Blood Cell" คล้ายกับ "WBC"        │
│       ต้องการรวมเป็นชื่อเดียวกันไหม?            │
│                                                 │
└─────────────────────────────────────────────────┘
```

#### Manage Lab Item Names (รวมชื่อ)

```
┌─────────────────────────────────────────────────┐
│  ← จัดการชื่อรายการตรวจ                          │
├─────────────────────────────────────────────────┤
│                                                 │
│  🔍 [ค้นหา...                            ]     │
│                                                 │
│  ─────────────────────────────────────────────  │
│                                                 │
│  📋 รายการที่บันทึกไว้:                          │
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │ 🩸 WBC                      (3 records) │   │
│  │    ├─ "WBC"                 (2 ครั้ง)   │   │
│  │    ├─ "White Blood Cell"   (1 ครั้ง)   │   │
│  │    └─ [✓ รวมเป็นชื่อเดียว: WBC ]        │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │ 🩸 Cholesterol              (4 records) │   │
│  │    └─ "Cholesterol"        (4 ครั้ง)   │   │
│  │       (ชื่อตรงกันหมด ✓)                 │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │ ⚠️ ยังไม่จับคู่:                         │   │
│  │    • "FBS" (1 ครั้ง)                    │   │
│  │    • "Fasting Blood Sugar" (1 ครั้ง)   │   │
│  │    • "Glucose, Fasting" (1 ครั้ง)      │   │
│  │                                         │   │
│  │    [รวมเป็นชื่อเดียว...]                 │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
└─────────────────────────────────────────────────┘
```

#### Compare/Chart View

```
┌─────────────────────────────────────────────────┐
│  ← กราฟ: Cholesterol                            │
├─────────────────────────────────────────────────┤
│                                                 │
│  📊 Cholesterol (mg/dL)                        │
│                                                 │
│  220│                                          │
│     │  ●                                       │
│  200│     ●                                    │
│     │         ●     ●                          │
│  180│                    ●                     │
│     │                                          │
│  160│─────────────────────── ค่าปกติ <200     │
│     │                                          │
│  140│                                          │
│     └────┬────┬────┬────┬────                 │
│        ม.ค.68 ก.ค.68 ม.ค.69 ก.ค.69             │
│                                                 │
│  ─────────────────────────────────────────────  │
│                                                 │
│  📋 ประวัติ:                                    │
│  • 15 ม.ค. 2569: 180 mg/dL (↓15 จากครั้งก่อน)  │
│  • 10 ก.ค. 2568: 195 mg/dL (↓5)               │
│  • 5 ม.ค. 2568: 200 mg/dL (↓10)               │
│  • 1 ก.ค. 2567: 210 mg/dL                     │
│  • 3 ม.ค. 2567: 220 mg/dL                     │
│                                                 │
│  💡 แนวโน้ม: ลดลงต่อเนื่อง ดีมาก!               │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

## 2.6 Lab Results Data Model

### LabSession (ครั้งที่ตรวจ)

```dart
@collection
class LabSession {
  Id id = Isar.autoIncrement;
  
  late DateTime date;           // วันที่ตรวจ
  String? location;             // โรงพยาบาล/คลินิก
  String? title;                // "ตรวจประจำปี", "ตรวจ Lipid"
  String? notes;
  
  String? imagePath;            // รูปผลตรวจ (ถ้ามี)
  
  final items = IsarLinks<LabItem>();
  
  DateTime createdAt = DateTime.now();
}
```

### LabItem (แต่ละรายการ)

```dart
@collection
class LabItem {
  Id id = Isar.autoIncrement;
  
  late int sessionId;           // belongs to LabSession
  
  late String name;             // ชื่อรายการ (ตามที่อ่านได้)
  late String value;            // ค่า (เก็บเป็น String เพราะบางทีมี range)
  String? unit;                 // หน่วย
  
  String? normalRange;          // "70-100", "<200"
  String? status;               // "normal", "high", "low"
  
  // Mapping (optional)
  int? mappedToGroupId;         // ถ้า merge ชื่อแล้ว
}
```

### LabItemGroup (รวมชื่อที่ตรงกัน)

```dart
@collection
class LabItemGroup {
  Id id = Isar.autoIncrement;
  
  late String canonicalName;    // ชื่อหลักที่ใช้แสดง
  List<String> aliases = [];    // ชื่ออื่นๆ ที่ตรงกัน
  
  String? category;             // "CBC", "Lipid", "Glucose"
  String? unit;                 // หน่วยหลัก
  String? normalRange;          // ค่าปกติ
}
```

---

## 3. Food Entry - Data Fields (ละเอียดแบบ Pro)

### 3.1 ข้อมูลหลัก (Required)

| Field | Type | Description | ตัวอย่าง |
|-------|------|-------------|----------|
| `foodName` | String | ชื่ออาหาร | "ข้าวผัดกุ้ง" |
| `calories` | double | แคลอรี่ (kcal) | 520 |
| `mealType` | enum | มื้ออาหาร | breakfast/lunch/dinner/snack |
| `timestamp` | DateTime | วัน-เวลา | 2026-02-03 12:30 |
| `imagePath` | String? | รูปภาพ (ถ้ามี) | "/storage/.../food.jpg" |

### 3.2 Macronutrients (สำคัญ)

| Field | Type | Unit | Description |
|-------|------|------|-------------|
| `protein` | double | grams | โปรตีน |
| `carbs` | double | grams | คาร์โบไฮเดรต |
| `fat` | double | grams | ไขมัน |
| `fiber` | double | grams | ไฟเบอร์ |
| `sugar` | double | grams | น้ำตาล |

### 3.3 Serving Size (Portion)

| Field | Type | Description | ตัวอย่าง |
|-------|------|-------------|----------|
| `servingSize` | double | ขนาด serving | 1.0, 0.5, 2.0 |
| `servingUnit` | String | หน่วย | "จาน", "ถ้วย", "กรัม", "ชิ้น" |
| `servingGrams` | double | น้ำหนักเป็นกรัม | 250 |

### 3.4 Micronutrients (Optional - สำหรับคนเอาจริง)

| Field | Type | Unit | Description |
|-------|------|------|-------------|
| `sodium` | double | mg | โซเดียม |
| `cholesterol` | double | mg | คอเลสเตอรอล |
| `saturatedFat` | double | g | ไขมันอิ่มตัว |
| `transFat` | double | g | ไขมันทรานส์ |
| `vitaminA` | double | mcg | วิตามิน A |
| `vitaminC` | double | mg | วิตามิน C |
| `calcium` | double | mg | แคลเซียม |
| `iron` | double | mg | เหล็ก |
| `potassium` | double | mg | โพแทสเซียม |

### 3.5 Metadata

| Field | Type | Description |
|-------|------|-------------|
| `source` | enum | ที่มาของข้อมูล: `ai_analyzed`, `manual`, `database`, `barcode` |
| `confidence` | double | ความมั่นใจของ AI (0-1) |
| `aiAnalyzedAt` | DateTime? | เวลาที่ AI วิเคราะห์ |
| `isVerified` | bool | ผู้ใช้ยืนยันแล้วหรือยัง |
| `notes` | String? | หมายเหตุเพิ่มเติม |

---

## 4. Workout Entry - Data Fields

### 4.1 ข้อมูลหลัก

| Field | Type | Description | ตัวอย่าง |
|-------|------|-------------|----------|
| `activityName` | String | ชื่อกิจกรรม | "วิ่ง" |
| `activityType` | enum | ประเภท | running/cycling/swimming/yoga/gym/other |
| `caloriesBurned` | double | แคลอรี่ที่เผา (kcal) | 280 |
| `duration` | int | ระยะเวลา (นาที) | 25 |
| `timestamp` | DateTime | วัน-เวลา | 2026-02-03 07:00 |

### 4.2 Activity-Specific Data

| Field | Type | Unit | ใช้กับ |
|-------|------|------|--------|
| `distance` | double | km | วิ่ง, ปั่น, ว่ายน้ำ |
| `steps` | int | ก้าว | เดิน, วิ่ง |
| `avgHeartRate` | int | bpm | ทุกประเภท |
| `maxHeartRate` | int | bpm | ทุกประเภท |
| `sets` | int | เซ็ต | ยกน้ำหนัก |
| `reps` | int | ครั้ง | ยกน้ำหนัก |
| `weight` | double | kg | ยกน้ำหนัก |

### 4.3 Metadata

| Field | Type | Description |
|-------|------|-------------|
| `source` | enum | `manual`, `health_connect`, `samsung_health`, `google_fit` |
| `externalId` | String? | ID จาก Health Connect |
| `notes` | String? | หมายเหตุ |

---

## 5. Health Connect Integration

### 5.1 Packages ที่ใช้

```yaml
dependencies:
  # Health Connect (Google's new standard)
  flutter_health_connect: ^1.2.3
  
  # Multi-provider sync (Google Fit, Samsung Health)
  health_sync_plugin: ^0.0.13
```

### 5.2 Data Types ที่ sync

| ประเภท | Read | Write | Description |
|--------|------|-------|-------------|
| **Steps** | ✅ | ⬜ | ก้าวเดินจาก Health Connect |
| **Heart Rate** | ✅ | ⬜ | ชีพจรจาก smartwatch |
| **Exercise** | ✅ | ✅ | การออกกำลังกาย (2-way sync) |
| **Calories Burned** | ✅ | ⬜ | แคลอรี่ที่เผาผลาญ |
| **Sleep** | ✅ | ⬜ | ข้อมูลการนอน |
| **Weight** | ✅ | ✅ | น้ำหนัก |
| **Body Fat** | ✅ | ✅ | เปอร์เซ็นต์ไขมัน |
| **Blood Pressure** | ✅ | ✅ | ความดันโลหิต |
| **Nutrition** | ⬜ | ✅ | ส่งข้อมูลอาหารออกไป |

### 5.3 Sync Flow

```
┌─────────────────────────────────────────────────┐
│                  Miro App                       │
│                                                 │
│  ┌─────────┐   ┌─────────┐   ┌─────────┐       │
│  │  Food   │   │ Workout │   │ Other   │       │
│  │ Entries │   │ Entries │   │ (weight)│       │
│  └────┬────┘   └────┬────┘   └────┬────┘       │
│       │             │             │             │
│       └─────────────┼─────────────┘             │
│                     ▼                           │
│           ┌─────────────────┐                   │
│           │  Health Connect │                   │
│           │     Bridge      │                   │
│           └────────┬────────┘                   │
└────────────────────┼────────────────────────────┘
                     ▼
┌────────────────────────────────────────────────┐
│              Health Connect API                │
│    (Android 14+ built-in, older = install)     │
├────────────────────────────────────────────────┤
│                                                │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐     │
│  │ Samsung  │  │  Google  │  │  Fitbit  │     │
│  │  Health  │  │   Fit    │  │   etc.   │     │
│  └──────────┘  └──────────┘  └──────────┘     │
│                                                │
└────────────────────────────────────────────────┘
```

### 5.4 Background Sync

```dart
// ใช้ health_sync_plugin สำหรับ background sync
// Sync อัตโนมัติทุก 1 ชั่วโมง หรือเมื่อเปิดแอป
```

---

## 6. Food Preview Screen (หลังถ่าย/เลือกรูป)

### 6.1 Layout

```
┌─────────────────────────────────────────────────┐
│  ← บันทึกอาหาร                        [💾 Save] │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌─────────────────────────────────────────┐   │
│  │                                         │   │
│  │           [🖼️ รูปอาหาร]                │   │
│  │                                         │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
│  ✨ AI วิเคราะห์แล้ว (ความมั่นใจ 85%)           │
│                                                 │
├─────────────────────────────────────────────────┤
│                                                 │
│  📝 ชื่ออาหาร                                   │
│  ┌─────────────────────────────────────────┐   │
│  │ ข้าวผัดกุ้ง                             │   │ ← Tap to edit
│  └─────────────────────────────────────────┘   │
│                                                 │
│  📏 Serving Size                               │
│  ┌─────────┐  ┌───────────────────────────┐   │
│  │   1.0   │  │ จาน ▼                     │   │ ← Dropdown
│  └─────────┘  └───────────────────────────┘   │
│  (ประมาณ 250 กรัม)                             │
│                                                 │
├─────────────────────────────────────────────────┤
│                                                 │
│  🔥 CALORIES                                    │
│  ┌─────────────────────────────────────────┐   │
│  │           520                           │   │ ← BIG number, tap to edit
│  │           kcal                          │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
├─────────────────────────────────────────────────┤
│                                                 │
│  💪 MACROS                    [ดูเพิ่มเติม ▼]   │
│  ┌───────────┬───────────┬───────────┐         │
│  │  Protein  │   Carbs   │    Fat    │         │
│  │   25g     │    65g    │    18g    │         │ ← Tap each to edit
│  │   [✏️]    │   [✏️]    │   [✏️]    │         │
│  └───────────┴───────────┴───────────┘         │
│                                                 │
│  ▼ รายละเอียดเพิ่มเติม (collapsed)              │
│  ┌─────────────────────────────────────────┐   │
│  │ Fiber: 3g  •  Sugar: 5g  •  Sodium: 850mg │ │
│  └─────────────────────────────────────────┘   │
│                                                 │
├─────────────────────────────────────────────────┤
│                                                 │
│  🍽️ มื้ออาหาร                                   │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐                   │
│  │☀️  │ │🌤️✓│ │🌙  │ │🍿  │                   │ ← Chip selection
│  │เช้า│ │กลาง│ │เย็น│ │ว่าง│                   │
│  └────┘ └────┘ └────┘ └────┘                   │
│                                                 │
│  ⏰ เวลา: 12:30                    [เปลี่ยน]    │
│  📅 วันที่: วันนี้                  [เปลี่ยน]    │
│                                                 │
│  📝 หมายเหตุ (optional)                         │
│  ┌─────────────────────────────────────────┐   │
│  │ พิเศษไม่ใส่ผงชูรส                       │   │
│  └─────────────────────────────────────────┘   │
│                                                 │
└─────────────────────────────────────────────────┘
```

### 6.2 Quick Edit Popup

```
กดที่ตัวเลขใดก็ได้ → เปิด Bottom Sheet

┌─────────────────────────────────────────────────┐
│                                                 │
│  ═══════════════════════════════════════════   │ ← Drag handle
│                                                 │
│         แก้ไข Calories                          │
│                                                 │
│         ┌───────────────────┐                   │
│         │       520         │                   │ ← Big input
│         │       kcal        │                   │
│         └───────────────────┘                   │
│                                                 │
│  Quick Adjust:                                  │
│  [-100] [-50] [-10]  •  [+10] [+50] [+100]     │
│                                                 │
│  ───────────────────────────────────────────   │
│                                                 │
│             [ยกเลิก]  [✓ บันทึก]                │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

## 7. AI Strategy: Local First, Cloud Last

### 7.1 หลักการ

```
┌─────────────────────────────────────────────────┐
│        🏠 LOCAL AI FIRST (ฟรี!)                 │
│  ═══════════════════════════════════════════   │
│                                                 │
│  Step 1: ML Kit Image Labeling                 │
│          → ระบุว่าเป็นอาหารอะไร                  │
│                                                 │
│  Step 2: Local Food Database                   │
│          → หาข้อมูล nutrition จาก DB            │
│                                                 │
│  Step 3: On-device LLM (Gemma 3)              │
│          → ประมาณค่าถ้าไม่เจอใน DB              │
│                                                 │
├─────────────────────────────────────────────────┤
│  ถ้า Local AI ไม่พอ → แสดงปุ่มให้ user เลือก:   │
│                                                 │
│  ┌───────────────────┐  ┌───────────────────┐  │
│  │ ✏️ พิมพ์ค่าเอง    │  │ ✨ ใช้ Gemini     │  │
│  │    (ฟรี!)        │  │ (ใช้ quota 1)     │  │
│  └───────────────────┘  └───────────────────┘  │
│                                                 │
└─────────────────────────────────────────────────┘
```

### 7.2 Food Analysis Flow

```
📷 ถ่าย/เลือกรูปอาหาร
         │
         ▼
┌─────────────────────────┐
│  ML Kit Image Labeling  │  ← LOCAL (ฟรี)
│  ระบุประเภทอาหาร        │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│  Search Local Food DB   │  ← LOCAL (ฟรี)
│  (Thai Food Database)   │
└───────────┬─────────────┘
            │
     ┌──────┴──────┐
     │             │
  [พบ]          [ไม่พบ]
     │             │
     ▼             ▼
┌──────────┐  ┌──────────────────┐
│ แสดงผล   │  │ On-device LLM    │ ← LOCAL (ฟรี)
│ ให้แก้ไข │  │ (Gemma 3) ประมาณ │
└──────────┘  └────────┬─────────┘
                       │
                ┌──────┴──────┐
                │             │
           [มั่นใจ]      [ไม่มั่นใจ]
                │             │
                ▼             ▼
          ┌──────────┐  ┌─────────────────────┐
          │ แสดงผล   │  │ แสดง 2 ตัวเลือก:    │
          │ ให้แก้ไข │  │ • ✏️ พิมพ์ค่าเอง    │
          └──────────┘  │ • ✨ ใช้ Gemini     │
                        └─────────────────────┘
                                  │
                           (user กดปุ่ม)
                                  │
                                  ▼
                        ┌─────────────────────┐
                        │  Gemini Vision API  │ ← CLOUD (เสีย quota!)
                        │  (BYOK required)    │
                        └─────────────────────┘
```

### 7.3 Local Food Database (Thai Foods)

```dart
// เก็บ common Thai foods + nutrition ไว้ในแอป
// ประมาณ 500-1000 รายการ
final thaiFoodDb = {
  "ข้าวผัด": FoodNutrition(cal: 450, p: 12, c: 65, f: 15),
  "ข้าวผัดกุ้ง": FoodNutrition(cal: 520, p: 25, c: 65, f: 18),
  "ต้มยำกุ้ง": FoodNutrition(cal: 180, p: 20, c: 8, f: 8),
  "ส้มตำ": FoodNutrition(cal: 120, p: 3, c: 18, f: 4),
  // ... 
};
```

### 7.4 Gemini Vision (Cloud - Last Resort)

**เมื่อไหร่ถึงใช้:**
- Local AI ไม่รู้จักอาหาร
- User กดปุ่ม "✨ ใช้ Gemini วิเคราะห์" เอง
- มี API Key ตั้งค่าไว้แล้ว

**System Prompt:**
```
คุณเป็น AI ที่เชี่ยวชาญด้านโภชนาการอาหารไทยและนานาชาติ
วิเคราะห์รูปภาพอาหารและประมาณค่าโภชนาการให้แม่นยำที่สุด

ให้ตอบเป็น JSON format:
{
  "food_name": "ชื่ออาหารภาษาไทย",
  "confidence": 0.85,
  "serving_grams": 250,
  "nutrition": {
    "calories": 520,
    "protein": 25,
    "carbs": 65,
    "fat": 18,
    "fiber": 3,
    "sugar": 5,
    "sodium": 850
  },
  "ingredients": ["กุ้ง", "ข้าว", "ไข่"],
  "notes": "อาจมีน้ำมันมาก"
}
```

### 7.5 Cloud AI Protection UI

```
┌─────────────────────────────────────────────────┐
│  ⚠️ ต้องการใช้ Gemini AI?                       │
├─────────────────────────────────────────────────┤
│                                                 │
│  การวิเคราะห์นี้จะใช้ Gemini API                │
│  ซึ่งนับเป็น quota ของคุณ                       │
│                                                 │
│  📊 Quota วันนี้: 12/15 requests                │
│                                                 │
│  ─────────────────────────────────────────────  │
│                                                 │
│      [ยกเลิก]        [✨ ใช้ Gemini]            │
│                                                 │
└─────────────────────────────────────────────────```

---

## 8. Data Models (Dart/Isar)

### 8.1 FoodEntry Model

```dart
@collection
class FoodEntry {
  Id id = Isar.autoIncrement;
  
  // Basic Info
  late String foodName;
  String? foodNameEn;
  late DateTime timestamp;
  String? imagePath;
  
  // Meal Type
  @enumerated
  late MealType mealType;
  
  // Serving
  late double servingSize;        // 1.0, 0.5, 2.0
  late String servingUnit;        // "จาน", "ถ้วย", "กรัม"
  double? servingGrams;           // estimated weight
  
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
  late DataSource source;         // ai_analyzed, manual, database
  double? aiConfidence;           // 0.0 - 1.0
  bool isVerified = false;
  String? notes;
  
  // Sync
  String? healthConnectId;
  DateTime? syncedAt;
}

enum MealType { breakfast, lunch, dinner, snack }
enum DataSource { aiAnalyzed, manual, database, barcode }
```

### 8.2 WorkoutEntry Model

```dart
@collection
class WorkoutEntry {
  Id id = Isar.autoIncrement;
  
  // Basic Info
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
}

enum ActivityType { 
  running, walking, cycling, swimming, 
  yoga, gym, hiit, other 
}
```

### 8.3 OtherHealthEntry Model

```dart
@collection
class OtherHealthEntry {
  Id id = Isar.autoIncrement;
  
  @enumerated
  late HealthEntryType entryType;
  late DateTime timestamp;
  
  // For supplements/medicine
  String? name;
  double? dosage;
  String? unit;           // mg, ml, IU
  
  // For water
  double? waterMl;
  
  // For biometrics
  double? weightKg;
  double? bodyFatPercent;
  int? systolicBP;        // ความดันตัวบน
  int? diastolicBP;       // ความดันตัวล่าง
  int? heartRate;
  
  // For sleep
  int? sleepMinutes;
  int? deepSleepMinutes;
  int? remSleepMinutes;
  
  // Metadata
  @enumerated
  late DataSource source;
  String? healthConnectId;
  String? notes;
}

enum HealthEntryType {
  supplement, medicine, water,
  weight, bodyFat, bloodPressure, heartRate,
  sleep
}
```

---

## 9. Implementation Priority

### Phase 1: Core Diet Tracking (ทำก่อน!)

| Task | Priority | Effort |
|------|----------|--------|
| สร้าง Health sub-tabs UI | 🔴 High | 2h |
| สร้าง FoodEntry model | 🔴 High | 1h |
| สร้าง Diet Tab + Daily Summary | 🔴 High | 3h |
| สร้าง Food Preview Screen | 🔴 High | 3h |
| Gemini Vision for Food | 🔴 High | 2h |
| Quick Edit Dialog | 🔴 High | 1h |
| Timeline Tab with date separator | 🔴 High | 2h |

### Phase 2: Workout Tracking

| Task | Priority | Effort |
|------|----------|--------|
| สร้าง WorkoutEntry model | 🟡 Med | 1h |
| สร้าง Workout Tab | 🟡 Med | 2h |
| Manual workout input | 🟡 Med | 2h |
| Health Connect sync (read) | 🟡 Med | 3h |

### Phase 3: Other Health

| Task | Priority | Effort |
|------|----------|--------|
| สร้าง OtherHealthEntry model | 🟢 Low | 1h |
| สร้าง Other Tab | 🟢 Low | 2h |
| Water tracking widget | 🟢 Low | 1h |
| Weight/Biometrics input | 🟢 Low | 2h |

### Phase 4: Advanced

| Task | Priority | Effort |
|------|----------|--------|
| Health Connect write (2-way) | 🟢 Low | 3h |
| Barcode scanner | 🟢 Low | 2h |
| Food database search | 🟢 Low | 4h |
| Weekly/Monthly reports | 🟢 Low | 3h |

---

## 10. Success Criteria

- [ ] ถ่ายรูปอาหาร → ได้ kcal + macros ภายใน 5 วินาที
- [ ] แก้ไขค่าได้ทันทีโดยกดที่ตัวเลข
- [ ] ดู Daily Summary ได้ง่าย
- [ ] แยก tabs ชัดเจน: Timeline / Diet / Workout / Other
- [ ] มี date separator ใน Timeline
- [ ] Sync กับ Health Connect ได้
- [ ] ใช้งานง่าย ไม่ต้องพิมพ์เยอะ = สำหรับคนขี้เกียจ!

---

**Created:** 2026-02-03
**Focus:** Health Feature First
**Status:** Ready for Implementation
