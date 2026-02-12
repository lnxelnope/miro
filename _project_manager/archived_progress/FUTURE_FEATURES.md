# Future Features Plan 🚀

> **เอกสารนี้รวบรวมฟีเจอร์ที่วางแผนไว้สำหรับอนาคต**
> **อ้างอิงจาก:** Design Documents ใน `_project_manager/`

---

## 📋 สารบัญ

1. [AI Features](#1-ai-features)
2. [Today Tab & Nudges](#2-today-tab--nudges)
3. [Health Enhancements](#3-health-enhancements)
4. [Finance Enhancements](#4-finance-enhancements)
5. [Voice Input](#5-voice-input)
6. [Weekly/Monthly Insights](#6-weeklymonthly-insights)
7. [Notifications & Reminders](#7-notifications--reminders)
8. [Data Management](#8-data-management)

---

## 1. AI Features

### 1.1 Context Builder (จาก CHAT_INTEGRATION_DESIGN.md)

**สถานะ:** ❌ ยังไม่ได้ทำ

**รายละเอียด:**
- สร้าง UserContext ที่รวบรวมข้อมูลผู้ใช้
- ดึงข้อมูลสุขภาพ/การเงิน/งาน มาเป็น context ให้ AI

```dart
class UserContext {
  // Health Data
  int todayCalories;
  Map<String, double> todayMacros;
  WorkoutProgram? activeWorkoutProgram;
  
  // Finance Data
  double monthlySpending;
  List<Transaction> recentTransactions;
  List<UpcomingBill> upcomingBills;
  
  // Task Data
  List<Task> todayTasks;
  List<Task> pendingTasks;
  List<Habit> activeHabits;
  
  // Chat History
  List<ChatMessage> recentMessages;
}
```

### 1.2 Rich Response Types (จาก CHAT_INTEGRATION_DESIGN.md)

**สถานะ:** ❌ ยังไม่ได้ทำ (ใช้แค่ text)

**Response Types ที่ต้องเพิ่ม:**

| Type | ใช้เมื่อ |
|------|---------|
| `confirmCard` | ยืนยันการสร้าง Entry |
| `workoutCard` | แสดงโปรแกรม workout + progress |
| `listCard` | แสดง list (บิล, tasks) |
| `assetSearchCard` | แสดงผลค้นหาสินทรัพย์ |
| `summaryCard` | สรุปข้อมูล |
| `askMore` | ถามข้อมูลเพิ่ม |

### 1.3 Local AI First Strategy (จาก HEALTH_FEATURE_DESIGN.md)

**สถานะ:** ❌ ยังไม่ได้ทำ (ใช้ Gemini ตรง)

**แผน:**
1. ใช้ ML Kit Image Labeling ก่อน
2. ใช้ Local Food Database
3. ใช้ On-device LLM (Gemma 3) ถ้าเป็นไปได้
4. ใช้ Gemini เฉพาะเมื่อจำเป็น

---

## 2. Today Tab & Nudges

### 2.1 Today Tab (จาก TASK_FEATURE_DESIGN.md)

**สถานะ:** ❌ ยังไม่ได้ทำ

**Features:**
- Quick Glance (สรุปสุขภาพ + การเงิน + งาน)
- วันนี้มี Workout อะไร
- Tasks วันนี้
- Calendar Events
- Reminders (ยา, บิล)

```
┌─────────────────────────────────────────────────┐
│  📅 วันนี้ - 3 ก.พ. 2569                         │
├─────────────────────────────────────────────────┤
│  ╔═══════════════════════════════════════════╗  │
│  ║  🔥 Quick Glance                          ║  │
│  ║  🍎 kcal: 1,250/2,000  📈 พอร์ต: +0.8%    ║  │
│  ║  🏃 Legs Day          💰 ใช้ไป: ฿850      ║  │
│  ╚═══════════════════════════════════════════╝  │
│                                                 │
│  💡 Nudges                                      │
│  ┌─────────────────────────────────────────┐   │
│  │ 🍔 ยังไม่ได้บันทึกอาหารเที่ยง             │   │
│  │         [📷 ถ่ายรูป]  [⏰ เตือนอีกที]    │   │
│  └─────────────────────────────────────────┘   │
└─────────────────────────────────────────────────┘
```

### 2.2 Proactive Nudges (จาก TASK_FEATURE_DESIGN.md)

**สถานะ:** ❌ ยังไม่ได้ทำ

**Nudge Types:**

| ประเภท | Trigger | ข้อความ |
|--------|---------|---------|
| Food Logging | ถึงเวลามื้ออาหาร + ยังไม่บันทึก | "ยังไม่ได้บันทึกอาหาร[มื้อ]" |
| Workout | วันนี้มี workout + ยังไม่ทำ | "วันนี้เป็น [Workout Day]" |
| Medicine | ถึงเวลากินยา | "ถึงเวลากินยา [ชื่อยา]" |
| Bill Due | 3 วันก่อนบิลถึงกำหนด | "บิล [ชื่อ] จะถึงกำหนดใน 3 วัน" |
| Streak Risk | ใกล้จะเสีย streak | "อย่าลืม [habit] วันนี้!" |

---

## 3. Health Enhancements

### 3.1 Other Tab (จาก HEALTH_FEATURE_DESIGN.md)

**สถานะ:** ❌ ยังไม่ได้ทำ

**Features:**
- 💧 Water Tracking (แก้ว/ลิตร)
- 💊 ยา/วิตามิน (reminder)
- 📊 Biometrics (น้ำหนัก, ความดัน, น้ำตาล)
- 😴 Sleep Tracking

**Data Model:**

```dart
@collection
class OtherHealthEntry {
  Id id = Isar.autoIncrement;
  
  @enumerated
  late HealthEntryType entryType;
  late DateTime timestamp;
  
  // For water
  double? waterMl;
  
  // For supplements/medicine
  String? name;
  double? dosage;
  String? unit;
  
  // For biometrics
  double? weightKg;
  int? systolicBP;
  int? diastolicBP;
  int? bloodSugar;
}
```

### 3.2 Lab Results Tab (จาก HEALTH_FEATURE_DESIGN.md)

**สถานะ:** ❌ ยังไม่ได้ทำ

**Features:**
- บันทึกผลตรวจสุขภาพแบบ open-ended
- ถ่ายรูปผลตรวจ → AI อ่านค่า
- เปรียบเทียบค่าข้ามครั้ง
- แสดงกราฟแนวโน้ม

**Data Models:**

```dart
@collection
class LabSession {
  Id id = Isar.autoIncrement;
  late DateTime date;
  String? location;
  String? title;
  String? imagePath;
  final items = IsarLinks<LabItem>();
}

@collection
class LabItem {
  Id id = Isar.autoIncrement;
  late int sessionId;
  late String name;      // "Cholesterol"
  late String value;     // "195"
  String? unit;          // "mg/dL"
  String? normalRange;   // "<200"
  String? status;        // "normal", "high", "low"
}
```

### 3.3 Health Connect Integration (จาก HEALTH_FEATURE_DESIGN.md)

**สถานะ:** ❌ ยังไม่ได้ทำ

**Packages:**
- `flutter_health_connect: ^1.2.3`

**Sync Data:**
- Steps, Heart Rate, Exercise
- Calories Burned, Sleep, Weight

### 3.4 Workout Program Management - Full (จาก HEALTH_FEATURE_DESIGN.md)

**สถานะ:** ⚠️ ทำแบบ simplified

**ส่วนที่ยังขาด:**
- Schedule Types (Weekly/Rotating/Interval)
- WorkoutDay model with exercises
- Progressive Overload (แนะนำเพิ่มน้ำหนัก)
- Create/Edit Workout Day UI

---

## 4. Finance Enhancements

### 4.1 Hybrid Asset Search (จาก FINANCE_FEATURE_DESIGN.md)

**สถานะ:** ❌ ยังไม่ได้ทำ (ใช้ mock prices)

**APIs ที่ต้องเพิ่ม:**

```dart
class HybridSearchService {
  // 1. Thai Gold API
  static Future<double?> getThaiGoldPrice() async {
    // api.chnwt.dev/thai-gold-api/latest
  }
  
  // 2. SEC Thailand API (Mutual Funds)
  static Future<double?> getFundNav(String symbol) async {
    // api.sec.or.th/FundFactsheet/fund
  }
  
  // 3. yfinance (Stocks)
  // - {SYMBOL}.BK (Thai)
  // - {SYMBOL} (US)
  // - {SYMBOL}-R.BK (NVDR)
}
```

### 4.2 Asset Groups (จาก FINANCE_FEATURE_DESIGN.md)

**สถานะ:** ❌ ยังไม่ได้ทำ

**Features:**
- จัดกลุ่มสินทรัพย์ (หุ้นไทย, หุ้นต่างประเทศ, ทอง)
- ดู performance ของกลุ่ม
- Target allocation

**Data Model:**

```dart
@collection
class AssetGroup {
  Id id = Isar.autoIncrement;
  late String name;           // "หุ้นไทย"
  String? icon;
  double? targetAllocation;   // 30%
}
```

### 4.3 Performance Display (จาก FINANCE_FEATURE_DESIGN.md)

**สถานะ:** ⚠️ ทำแบบ simplified

**Timeframes ที่ต้องเพิ่ม:**
- 1D, 1W, 1M, 3M, 6M, YTD, 1Y, ALL

**ต้องเก็บ Price History:**

```dart
@collection
class PriceHistory {
  Id id = Isar.autoIncrement;
  late String symbol;
  late DateTime date;
  late double price;
}
```

---

## 5. Voice Input

### (จาก CHAT_INTEGRATION_DESIGN.md)

**สถานะ:** ❌ ยังไม่ได้ทำ

**Package:**
- `speech_to_text: ^6.0.0`

**Features:**
- กดปุ่ม 🎤 ใน Chat → พูด
- รองรับภาษาไทย (`th-TH`)

**ตัวอย่างคำสั่ง:**
- "กินข้าวผัดกุ้ง 500 แคล"
- "วิ่ง 3 กิโล 30 นาที"
- "จ่ายค่ากาแฟ 65 บาท"
- "พรุ่งนี้ประชุม 2 โมง"

---

## 6. Weekly/Monthly Insights

### (จาก TASK_FEATURE_DESIGN.md)

**สถานะ:** ❌ ยังไม่ได้ทำ

**Features:**
- สรุปสุขภาพรายสัปดาห์
- สรุปการเงินรายเดือน
- สรุป Task completion
- Cross-feature Insights

**UI:**

```
┌─────────────────────────────────────────────────┐
│  📊 สรุปสัปดาห์ (27 ม.ค. - 2 ก.พ.)              │
├─────────────────────────────────────────────────┤
│  🍎 สุขภาพ                                      │
│  • kcal เฉลี่ย: 1,850/2,000                     │
│  • ออกกำลัง: 4/5 วัน ✅                         │
│  • น้ำหนัก: 72.5 → 72.0 kg (−0.5)              │
│                                                 │
│  💰 การเงิน                                     │
│  • รายรับ: +฿45,000                            │
│  • รายจ่าย: −฿28,350                           │
│  • พอร์ต: +2.3%                                │
│                                                 │
│  📅 งาน                                         │
│  • เสร็จ: 8/10 tasks (80%)                     │
│  • Streaks: 49 วันรวม                          │
│                                                 │
│  💡 Insights                                    │
│  • "น้ำหนักลดต่อเนื่อง 3 สัปดาห์แล้ว! 🎉"       │
└─────────────────────────────────────────────────┘
```

---

## 7. Notifications & Reminders

### Smart Reminders (จาก TASK_FEATURE_DESIGN.md)

**สถานะ:** ❌ ยังไม่ได้ทำ

**Reminder Types:**

| ประเภท | Recurring |
|--------|-----------|
| 💊 Medicine | Daily |
| 💳 Bill Due | Monthly |
| 🩺 Health Check | 6M/1Y |
| 📊 Portfolio Rebalance | Trigger-based |

**Package:**
- `flutter_local_notifications: ^16.0.0`
- `workmanager: ^0.5.2` (background)

---

## 8. Data Management

### Export/Backup (จาก UI_REDESIGN_PLAN.md)

**สถานะ:** ❌ ยังไม่ได้ทำ

**Features:**
- Export to JSON
- Export to CSV
- Backup/Restore
- Cloud Sync (optional)

---

## 🎯 Priority Order

### Phase 1: Essential (ทำเร็วๆ นี้)
1. ~~Today Tab + Quick Glance~~
2. ~~Other Health Tab (น้ำ, ยา)~~
3. ~~Weekly Insights~~

### Phase 2: Nice-to-Have
4. Lab Results
5. Voice Input
6. Proactive Nudges

### Phase 3: Advanced
7. Health Connect
8. Hybrid Asset Search
9. Context Builder + Rich Response Types

### Phase 4: Polish
10. Notifications/Reminders
11. Export/Backup
12. Local AI First

---

**Created:** 2026-02-04
**Status:** Planning Document
