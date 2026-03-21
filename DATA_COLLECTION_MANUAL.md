# MIRO Data Collection Manual
# คู่มือการเก็บข้อมูล MIRO

> **เอกสารนี้สรุปทุก data point ที่แอป MIRO เก็บ วิธีเก็บ มูลค่าเชิงพาณิชย์ และ privacy safeguards**
> **อัปเดตล่าสุด: March 2026**

---

## สารบัญ

1. [ภาพรวมสถาปัตยกรรม Data](#1-ภาพรวม)
2. [FoodEntry — โมเดลหลัก](#2-foodentry)
3. [Ingredient Database — ฐานข้อมูลวัตถุดิบ](#3-ingredient-database)
4. [DailySummary — สรุปพลังงานรายวัน](#4-dailysummary)
5. [Scene Context — บริบทรอบอาหาร](#5-scene-context)
6. [AR / Computer Vision Data](#6-ar-data)
7. [User Correction Tracking](#7-correction-tracking)
8. [Brand / Product Data](#8-brand-product)
9. [Meal Grouping](#9-meal-grouping)
10. [Food Research Program (Opt-In)](#10-food-research)
11. [Cloud Sync System](#11-cloud-sync)
12. [Backup System](#12-backup)
13. [Free vs Paid — Usage Limiter](#13-usage-limiter)
14. [Privacy & Compliance](#14-privacy)
15. [มูลค่าเชิงพาณิชย์ — Data Valuation](#15-data-valuation)

---

## 1. ภาพรวม

### Data Flow

```
User Input (text/photo/camera)
    │
    ▼
┌──────────────────┐
│  AI Analysis     │  ← Gemini API
│  (GeminiService) │
└──────┬───────────┘
       │
       ▼
┌──────────────────┐     ┌─────────────────┐
│  FoodEntry       │────▶│  Isar (Local DB) │
│  (enriched)      │     └────────┬────────┘
└──────────────────┘              │
                                  │  auto-sync (1/day)
                                  ▼
                    ┌──────────────────────────┐
                    │  Firestore               │
                    │  users/{id}/daily_sync/   │
                    └──────────────────────────┘
                                  │
                    ┌─────────────┴────────────┐
                    │  Firebase Storage         │
                    │  (thumbnails + metadata)  │
                    └──────────────────────────┘
```

### Storage Layers

| Layer | เก็บอะไร | ที่เก็บ |
|-------|---------|--------|
| Local DB | FoodEntry, Ingredient, MyMeal, DailySummary, UserProfile | Isar |
| Cloud Sync | Compact entries, meals, profile | Firestore (`daily_sync`) |
| Thumbnails | รูปอาหาร + metadata ครบ | Firebase Storage |
| File Backup | JSON export สำหรับย้ายเครื่อง | Local file → share |

---

## 2. FoodEntry

**ไฟล์:** `lib/features/health/models/food_entry.dart`

FoodEntry คือ model หลักของทุกรายการอาหาร ทุก field ด้านล่างถูก sync ขึ้น cloud

### 2.1 ข้อมูลพื้นฐาน

| Field | Type | คำอธิบาย |
|-------|------|---------|
| `foodName` | `String` | ชื่ออาหาร (ไทย) |
| `foodNameEn` | `String?` | ชื่ออาหาร (อังกฤษ) |
| `timestamp` | `DateTime` | เวลาที่บันทึก |
| `mealType` | `MealType` | breakfast / lunch / dinner / snack |
| `servingSize` | `double` | จำนวนที่กิน |
| `servingUnit` | `String` | หน่วย (g, จาน, ชิ้น ฯลฯ) |
| `servingGrams` | `double?` | ปริมาณเป็นกรัม (ถ้าทราบ) |
| `searchMode` | `FoodSearchMode` | normal / ingredientBased / camera / photo |

### 2.2 Nutrition (คำนวณแล้ว)

| Field | Type | คำอธิบาย |
|-------|------|---------|
| `calories` | `double` | แคลอรี่ |
| `protein` | `double` | โปรตีน (g) |
| `carbs` | `double` | คาร์โบไฮเดรต (g) |
| `fat` | `double` | ไขมัน (g) |
| `fiber` | `double?` | ไฟเบอร์ (g) |
| `sugar` | `double?` | น้ำตาล (g) |
| `sodium` | `double?` | โซเดียม (mg) |
| `cholesterol` | `double?` | คอเลสเตอรอล (mg) |
| `saturatedFat` | `double?` | ไขมันอิ่มตัว (g) |
| `transFat` | `double?` | ไขมันทรานส์ (g) |
| `unsaturatedFat` | `double?` | ไขมันไม่อิ่มตัว (g) |
| `monounsaturatedFat` | `double?` | ไขมันไม่อิ่มตัวเชิงเดี่ยว (g) |
| `polyunsaturatedFat` | `double?` | ไขมันไม่อิ่มตัวเชิงซ้อน (g) |
| `potassium` | `double?` | โพแทสเซียม (mg) |

### 2.3 Base Nutrition (ต่อ 1 หน่วย)

| Field | คำอธิบาย |
|-------|---------|
| `baseCalories` / `baseProtein` / `baseCarbs` / `baseFat` | ค่า nutrition ต่อ 1 `servingUnit` — ใช้สำหรับคำนวณเมื่อ user เปลี่ยนปริมาณ |

### 2.4 AI Metadata

| Field | Type | คำอธิบาย |
|-------|------|---------|
| `source` | `DataSource` | manual / aiAnalyzed / database / healthConnect |
| `aiConfidence` | `double?` | 0.0–1.0 ความมั่นใจของ AI |
| `isVerified` | `bool` | user ยืนยันแล้วหรือไม่ |
| `ingredientsJson` | `String?` | JSON array ของวัตถุดิบย่อย |

---

## 3. Ingredient Database

**ไฟล์:** `lib/features/health/models/ingredient.dart`

ฐานข้อมูลวัตถุดิบส่วนตัว — เรียนรู้จากการใช้งานจริง

| Field | Type | คำอธิบาย |
|-------|------|---------|
| `name` | `String` | ชื่อวัตถุดิบ (ไทย) |
| `nameEn` | `String?` | ชื่อวัตถุดิบ (อังกฤษ) |
| `baseAmount` | `double` | ปริมาณฐาน (เช่น 100 ถ้าหน่วยเป็น g) |
| `baseUnit` | `String` | หน่วยฐาน |
| `caloriesPerBase` / `proteinPerBase` / `carbsPerBase` / `fatPerBase` | `double` | ค่าต่อ baseAmount |
| `source` | `String` | "gemini" หรือ "manual" |
| `usageCount` | `int` | จำนวนครั้งที่ถูกใช้ (สำหรับ ranking) |

### Upsert Logic (แก้บั๊ก usageCount ไม่นับ)

```dart
// ทุกจุดที่ save ingredient ใช้ Ingredient.upsert()
// - ถ้าชื่อซ้ำ → อัปเดต nutrition + usageCount++
// - ถ้าไม่ซ้ำ → สร้างใหม่ usageCount = 1

// ทุกจุดที่เลือกจาก DB ใช้ Ingredient.incrementUsage(id)
```

**ไฟล์ที่เกี่ยว:**
- `Ingredient.upsert(...)` — static method ใน `ingredient.dart`
- `Ingredient.incrementUsage(id)` — static method ใน `ingredient.dart`
- ถูกใช้ใน: `edit_food_bottom_sheet`, `add_food_bottom_sheet`, `simple_food_detail_sheet`, `gemini_analysis_sheet`

---

## 4. DailySummary

**ไฟล์:** `lib/features/health/models/daily_summary.dart`

สรุป energy balance รายวัน — **เก็บค่าที่คำนวณเอง (derived) เท่านั้น** เพื่อไม่ละเมิด HealthKit/Health Connect policy

| Field | Type | คำอธิบาย |
|-------|------|---------|
| `date` | `DateTime` | วันที่ (unique, replace) |
| `caloriesEaten` | `double` | แคลอรี่ที่กินทั้งวัน (sum จาก FoodEntry) |
| `proteinEaten` / `carbsEaten` / `fatEaten` | `double` | macro ทั้งวัน |
| `tdee` | `double` | TDEE ณ วันนั้น (Mifflin-St Jeor) |
| `netEnergy` | `double` | **caloriesEaten - tdee - activeBurn** (derived) |
| `deficitZone` | `String` | "danger" / "careful" / "sweet_spot" / "maintain" / "surplus" |
| `entryCount` | `int` | จำนวนรายการอาหาร |
| `correctionCount` | `int` | จำนวน entries ที่ user แก้ไข |
| `calorieGoal` | `double` | เป้าแคลอรี่ ณ วันนั้น |

### ทำไมไม่เก็บ Active Burn ตรงๆ?

> **Apple HealthKit Policy** & **Google Health Connect Policy** ห้ามเก็บ raw health data (เช่น Active Energy Burned) ขึ้น cloud
> เราจึง "ละลาย" ค่า active burn เข้าไปใน `netEnergy` ซึ่งเป็นค่าที่แอปคำนวณเอง
> ไม่สามารถแยก active burn กลับออกมาได้ → ปลอดภัยจากการถูกแบน

### Trigger

- `DailySummaryService.snapshotToday()` ถูกเรียกทุกครั้งที่:
  - `addFoodEntry()`
  - `updateFoodEntry()`
  - `deleteFoodEntry()`

---

## 5. Scene Context

**ไฟล์:** `gemini_service.dart` (prompt) → `food_entry.dart` (`sceneContextJson`)

AI วิเคราะห์สิ่งที่อยู่รอบอาหารในรูป — เฉพาะ food/beverage/dining items เท่านั้น

### JSON Structure

```json
{
  "dining_setting": "restaurant",
  "restaurant_chain": "McDonald's",
  "other_food_items": ["ข้าวผัด", "ส้มตำ"],
  "beverages": [
    {"name": "Coca-Cola", "size": "330ml", "container": "can"}
  ],
  "packaged_products": [
    {"name": "Lay's Original", "size": "75g", "container": "bag"}
  ]
}
```

### กฎเข้มงวดใน AI Prompt

```
✅ เก็บ: อาหาร, เครื่องดื่ม, ขนม, ร้านอาหาร (ถ้าเห็นโลโก้)
✅ เก็บ: ภาชนะ, ช้อนส้อม (dining items)
❌ ห้ามเก็บ: ของใช้ส่วนตัว, เสื้อผ้า, กระเป๋า, อิเล็กทรอนิกส์
❌ ห้ามเก็บ: ใบหน้า, บัตรเครดิต, เอกสาร, PII ทุกชนิด
```

### เหตุผลเชิงพาณิชย์

- **Portion Calibration:** ขนาดขวด/กระป๋องมาตรฐาน → ใช้เทียบขนาด portion ได้
- **Food Co-occurrence:** รู้ว่าคนกินอะไรคู่กัน
- **Chain Attribution:** รู้ว่าอาหารจากร้านไหน
- **Market Research:** brand presence analysis

---

## 6. AR / Computer Vision Data

เก็บผลจาก ML Kit Object Detection

| Field | Type | มูลค่า |
|-------|------|--------|
| `arLabelsJson` | `String?` | JSON array ของ detected objects + bounding boxes |
| `arImageWidth` | `double?` | ความกว้างรูป (px) |
| `arImageHeight` | `double?` | ความสูงรูป (px) |
| `arPixelPerCm` | `double?` | pixel ต่อ cm (calibration factor) |
| `referenceObjectUsed` | `String?` | วัตถุอ้างอิง (เช่น "credit_card", "coin") |
| `referenceConfidence` | `double?` | ความมั่นใจในการ calibrate |
| `plateDiameterCm` | `double?` | ขนาดจาน (cm) |
| `estimatedVolumeMl` | `double?` | ปริมาตรโดยประมาณ (ml) |
| `isCalibrated` | `bool` | ผ่านการ calibrate หรือไม่ |

### มูลค่า

รูปอาหาร + bounding box + pixel-to-cm → **Labeled Training Data** สำหรับ food AI
ราคาตลาด: **$0.50–$2.00 ต่อรูป** (vs $0.01–0.05 สำหรับรูปไม่มี label)

---

## 7. User Correction Tracking

**หลักการ:** ข้อมูลที่ผู้ใช้แก้ไขจาก AI มีมูลค่าสูงมาก เพราะเป็น human-verified ground truth

| Field | Type | คำอธิบาย |
|-------|------|---------|
| `userInputText` | `String?` | ข้อความดิบที่ user พิมพ์ก่อน AI normalize |
| `originalFoodName` | `String?` | ชื่อเดิมที่ AI วิเคราะห์ |
| `originalFoodNameEn` | `String?` | ชื่อเดิม (EN) |
| `originalCalories` | `double?` | kcal เดิมจาก AI |
| `originalProtein` / `originalCarbs` / `originalFat` | `double?` | macro เดิมจาก AI |
| `originalIngredientsJson` | `String?` | วัตถุดิบเดิมจาก AI |
| `editCount` | `int` | จำนวนครั้งที่แก้ไข |
| `isUserCorrected` | `bool` | user เคยแก้ไขหรือไม่ |

### Trigger Logic

```dart
// เกิดขึ้นใน _save() ของ edit/simple bottom sheets
if (entry.originalFoodName == null && entry.source == DataSource.aiAnalyzed) {
  // Snapshot ค่าเดิมครั้งแรกที่ edit
  entry.originalFoodName = widget.entry.foodName;
  entry.originalCalories = widget.entry.calories;
  // ...
}
entry.editCount += 1;
entry.isUserCorrected = true;
```

### มูลค่า

- AI วิเคราะห์ว่า "ข้าวผัด 350 kcal" → user แก้เป็น "ข้าวผัดกุ้ง 420 kcal"
- ข้อมูลคู่ (AI prediction vs human correction) ขายได้เป็น **AI training dataset**
- ราคาตลาด: **$1–5 ต่อ correction pair** (เทียบกับ human labeling cost)

---

## 8. Brand / Product Data

แยก "อาหาร" กับ "สินค้าบรรจุภัณฑ์" ออกจากกัน

| Field | Type | คำอธิบาย |
|-------|------|---------|
| `brandName` | `String?` | ชื่อแบรนด์ (ไทย) |
| `brandNameEn` | `String?` | ชื่อแบรนด์ (EN) |
| `productCategory` | `String?` | beverage / snack / ready_meal / fast_food / dairy / candy / other |
| `packageSize` | `String?` | "330ml", "60g" |
| `barcode` | `String?` | EAN/UPC code |
| `chainName` | `String?` | ร้าน/เชน (KFC, 7-Eleven ฯลฯ) |
| `nutritionSource` | `String?` | label_read / brand_database / ai_estimated |

### มูลค่า

- **ข้อมูล Brand + Category + Region** → ขายให้ FMCG companies, market research firms
- **Chain attribution** → ข้อมูลว่าคนกินอะไรจากร้านไหน, ความถี่, เวลา

---

## 9. Meal Grouping

เก็บข้อมูลว่าอาหารอะไรถูกกินด้วยกันในมื้อเดียว

| Field | Type | คำอธิบาย |
|-------|------|---------|
| `groupId` | `String?` | UUID สำหรับ group entries ที่กินด้วยกัน |
| `groupSource` | `String?` | "photo" / "manual" / "user_added" |
| `groupOrder` | `int?` | ลำดับใน group (0 = main dish) |
| `isGroupOriginal` | `bool` | true = AI เจอจากรูป, false = user เพิ่มเอง |

### มูลค่า

- **Food Co-occurrence Data:** "คนที่กินส้มตำ มักกินข้าวเหนียว + คอหมูย่าง"
- **Meal Pattern Analysis:** ข้อมูล pairing ขายให้ restaurant / food delivery platforms

---

## 10. Food Research Program (Opt-In)

**ไฟล์:** `user_profile.dart`, `profile_screen.dart`, `thumbnail_service.dart`

### Consent Fields (UserProfile)

```dart
bool foodResearchConsent = false;
DateTime? foodResearchConsentAt;
```

### เมื่อ consent = true

Thumbnail ที่อัปโหลดจะมี **research-grade metadata** เพิ่ม:

| Metadata Key | คำอธิบาย |
|-------------|---------|
| `researchable` | "true" |
| `arLabels` | bounding box labels |
| `imgW` / `imgH` / `pxPerCm` | image dimensions + calibration |
| `sceneContext` | scene context JSON |
| `corrected` / `editCount` / `origName` / `origKcal` | correction data |
| `brand` / `chain` / `prodCat` / `pkgSize` | product data |
| `userInput` | raw user text input |
| `ingredients` | ingredients JSON |

### Privacy Safeguards

```
✅ Explicit opt-in (ต้องกดยืนยัน)
✅ Anonymized (hashed device ID เท่านั้น)
✅ Dialog อธิบายชัดเจนว่าเก็บอะไร/ไม่เก็บอะไร
✅ ปิดได้ทุกเมื่อ
❌ ไม่เก็บ: ใบหน้า, ของใช้ส่วนตัว, PII
```

### มูลค่า

- รูปอาหาร + bounding box + nutrition label = **Premium AI Training Data**
- ขายเป็น bulk dataset ให้ AI companies, food tech startups
- **รูปที่มี bounding box แพงกว่ารูปเปล่า 10–50 เท่า**

---

## 11. Cloud Sync System

**ไฟล์:** `lib/core/services/data_sync_service.dart`

### Auto Sync (ใหม่)

```
เปิดแอป → _initServicesInBackground()
         → DataSyncService.autoSyncIfNeeded()
            → เช็ค: ซิงค์วันนี้แล้วหรือยัง? (SharedPreferences: auto_sync_last_date)
               ✓ แล้ว → ข้าม
               ✗ ยังไม่ → buildPayload → เขียน Firestore → markSyncSuccess
```

### Firestore Structure

```
users/{deviceId}/daily_sync/{YYYY-MM-DD}
├── entries: [compact food entry objects]
├── meals: [compact meal objects]
├── profile: {compact profile}
├── syncTimestamp: ServerTimestamp
├── entryCount: int
├── mealCount: int
└── platform: "ios" | "android"
```

### Compact Format

ข้อมูลถูกย่อเพื่อประหยัด bandwidth:

| Original | Compact | ตัวอย่าง |
|----------|---------|---------|
| `foodName` | `fn` | "ข้าวผัด" |
| `calories` | `k` | 350.0 |
| `protein` | `p` | 12.5 |
| `sceneContextJson` | `scj` | "{...}" |
| `userInputText` | `uit` | "ข้าวผัดกุ้ง" |
| `brandName` | `bn` | "CP" |
| `editCount` | `ec` | 2 |

### Sync Channels

| Channel | Trigger | ไปที่ไหน |
|---------|---------|---------|
| Auto Sync | เปิดแอปครั้งแรกของวัน | Firestore (`daily_sync`) |
| Energy Claim Sync | user กด claim | Cloud Function → Firestore |
| Manual Sync | user กด "ซิงค์ตอนนี้" ใน profile | Firestore (`daily_sync`) |

---

## 12. Backup System

**ไฟล์:** `lib/core/services/backup_service.dart`

### 2 ไฟล์ backup

| ไฟล์ | เนื้อหา | Restore |
|------|--------|---------|
| `miro_data_YYYY-MM-DD.json` | food entries + meals + MiRO ID | ได้เรื่อยๆ (merge, ไม่ลบ) |
| `miro_energy_YYYY-MM-DD.json` | transfer key + energy | ครั้งเดียว, ห้ามเครื่องเดียวกัน |

### ใช้สำหรับ

- **ย้ายเครื่อง** (device transfer)
- **Manual export** ข้อมูลเก่า
- ไม่ใช่สำหรับ backup ประจำวัน (ใช้ Auto Sync แทน)

---

## 13. Free vs Paid — Usage Limiter

**ไฟล์:** `lib/core/services/usage_limiter.dart`

### ฟรี (ไม่เสีย Energy)

| Feature | Limit | เหตุผล |
|---------|-------|--------|
| แก้ไขวัตถุดิบ (ingredient lookup) | 10 ครั้ง/วัน | correction data มูลค่าสูง |
| Re-analyze อาหาร | ไม่จำกัด | token น้อย, data มูลค่าสูง |
| ค้นหาวัตถุดิบรายตัว | ไม่จำกัด | เหมือนข้อบน |

### เสีย Energy

| Feature | Cost |
|---------|------|
| AI วิเคราะห์อาหารจากรูป | 1 Energy |
| AI วิเคราะห์อาหารจาก text | 1 Energy |
| Ingredient lookup เกิน 10/วัน | 1 Energy |

### หลักการ

> **"ให้ฟรีสิ่งที่สร้าง valuable data กลับ"**
> User corrections, ingredient edits, re-analyzes → ทำฟรี เพราะ data ที่ได้กลับมามีมูลค่าสูงกว่า token cost

---

## 14. Privacy & Compliance

### PDPA (Thai Personal Data Protection Act)

| ประเภทข้อมูล | หมวด PDPA | ต้อง consent? |
|-------------|----------|-------------|
| ข้อมูลอาหาร + nutrition | General Data | ไม่ (legitimate interest) |
| Scene context (food only) | General Data | ไม่ (portion calibration purpose) |
| Correction history | General Data | ไม่ |
| Meal grouping | General Data | ไม่ |
| Food Research (รูป + bounding box) | General Data | **ใช่ (explicit opt-in)** |
| ข้อมูลสุขภาพ (Health Connect) | Sensitive Data | **ใช่** (แต่เราไม่เก็บ raw) |

### App Store Compliance

| Policy | วิธีจัดการ |
|--------|----------|
| Apple HealthKit | ไม่เก็บ raw health data → ใช้ derived `netEnergy` แทน |
| Google Health Connect | เหมือนกัน — `netEnergy` เป็นค่าที่แอปคำนวณเอง |
| Photo Privacy | AI prompt สั่งห้ามเก็บ PII, ใบหน้า, ของส่วนตัว |
| Data Minimization | optional fields ส่งเฉพาะเมื่อมีค่า (save bytes) |

### Anonymization

- Device ID ถูก **hash ด้วย SHA-256** ก่อนใช้เป็น uid ใน metadata
- ไม่มี email, ชื่อ, เบอร์โทร ในข้อมูลที่ sync
- Food Research photos ถูก flag `researchable: true` เฉพาะเมื่อ user consent

---

## 15. มูลค่าเชิงพาณิชย์ — Data Valuation

### ข้อมูลที่ขายได้ (Ranked by Value)

| # | ประเภท | มูลค่าต่อ record | เหตุผล |
|---|--------|----------------|--------|
| 1 | รูปอาหาร + bounding box + nutrition | **$0.50–2.00** | Labeled AI training data |
| 2 | User corrections (AI vs human) | **$1.00–5.00** | Ground truth for AI improvement |
| 3 | Brand/product + scene context | **$0.10–0.50** | Market research, FMCG insights |
| 4 | Food co-occurrence (meal grouping) | **$0.05–0.20** | Menu optimization, food delivery |
| 5 | User input text (raw) | **$0.05–0.10** | NLP training, food name normalization |
| 6 | Nutrition data (verified) | **$0.01–0.05** | Basic food database |
| 7 | Demographic + food preference | **$0.01–0.03** | Consumer segmentation |

### ลูกค้าเป้าหมาย

| ลูกค้า | สนใจอะไร | ราคาประเมิน |
|--------|---------|------------|
| AI/ML Companies | Labeled food images + corrections | $10K–100K per dataset |
| FMCG (Nestle, Unilever) | Brand consumption patterns | $5K–50K per report |
| Restaurant Chains | Food co-occurrence, meal patterns | $2K–20K per analysis |
| Health Insurance | Dietary patterns by demographic | $10K–50K per cohort |
| Food Delivery (Grab, LINE MAN) | What pairs with what, when | $5K–30K per dataset |
| Academic Research | Labeled nutrition data | $1K–10K per study |

### Multiplier Effects

```
รูปเปล่า                     → $0.01
+ bounding box               → x10  ($0.10)
+ nutrition labels            → x5   ($0.50)
+ user correction             → x4   ($2.00)
+ scene context + brand       → x2   ($4.00)
                              ──────────────
                              Total: $4.00/record
```

---

## 16. Store Declaration Guide

**อัปเดตล่าสุด: March 2026 (Build 54)**

ทุกครั้งที่เพิ่ม data collection ใหม่ ต้องเช็ค section นี้และอัปเดต Store declarations ให้ตรงกัน

---

### 16.1 Apple App Store — App Privacy Labels

ต้องกรอกใน **App Store Connect > App Privacy** ทุกครั้งที่ submit build ใหม่ที่มีการเปลี่ยน data collection

#### Data Types ที่ต้องประกาศ

| Apple Category | Data Type | Collected? | Shared? | Linked to User? | Purpose |
|---|---|---|---|---|---|
| **Health & Fitness** | Health | ✅ | ❌ | ❌ | App Functionality (HealthKit read/write) |
| **Health & Fitness** | Fitness | ✅ | ❌ | ❌ | App Functionality (Active Energy Burned) |
| **Health & Fitness** | Other (Nutrition) | ✅ | ✅ (if Food Research) | ❌ | App Functionality, Analytics |
| **Photos or Videos** | Photos | ✅ | ✅ (if Food Research) | ❌ | App Functionality (thumbnails → Firebase) |
| **Identifiers** | Device ID | ✅ | ❌ | ❌ | App Functionality (hashed, anonymous) |
| **Identifiers** | Advertising ID | ✅ | ✅ (AdMob) | ❌ | Third-Party Advertising |
| **Financial Info** | Purchase History | ✅ | ❌ | ❌ | App Functionality (IAP via StoreKit) |
| **Usage Data** | Product Interaction | ✅ | ❌ | ❌ | Analytics (Firebase Analytics, opt-in) |
| **Diagnostics** | Crash Data | ✅ | ❌ | ❌ | App Functionality |
| **Other Data** | Food diary entries | ✅ | ✅ (if Food Research) | ❌ | App Functionality, Product Improvement |
| **Other Data** | User corrections | ✅ | ✅ (if Food Research) | ❌ | Product Improvement, AI Training |
| **Other Data** | Scene context | ✅ | ✅ (if Food Research) | ❌ | Product Improvement |
| **Other Data** | AR/bounding box labels | ✅ | ✅ (if Food Research) | ❌ | Product Improvement, AI Training |
| **Other Data** | Brand/product data | ✅ | ✅ (if Food Research) | ❌ | Product Improvement |

#### "Collected" vs "Shared" (คำจำกัดความ Apple)

- **Collected** = เก็บไว้นอกตัวเครื่อง (Firebase, server)
- **Shared** = ส่งต่อให้ third party (Food Research → AI companies)
- **Linked to User** = สามารถระบุตัวตนผู้ใช้ได้ → **ไม่** (ใช้ hashed device ID)

#### "Shared" Trigger: Food Research Program

เมื่อ user เปิด Food Research (`foodResearchConsent = true`):
- Thumbnail metadata ถูก flag `researchable: true`
- ข้อมูลนี้ **อาจถูก license** ให้ third-party AI/ML companies
- ต้องประกาศเป็น **"Shared"** ใน App Privacy Labels

เมื่อ Food Research **ปิด**:
- ข้อมูลยังถือว่า **"Collected"** (เก็บบน Firebase) แต่ **ไม่ "Shared"**

#### iOS Permissions (Info.plist)

| Key | ข้อความ | ต้องมี? |
|-----|---------|---------|
| `NSCameraUsageDescription` | ถ่ายรูปอาหารเพื่อวิเคราะห์ | ✅ |
| `NSPhotoLibraryUsageDescription` | เลือกรูปอาหารจากแกลเลอรี | ✅ |
| `NSPhotoLibraryAddUsageDescription` | บันทึกรูปที่วิเคราะห์แล้ว | ✅ |
| `NSHealthShareUsageDescription` | อ่าน Active Energy Burned | ✅ |
| `NSHealthUpdateUsageDescription` | เขียน Dietary Nutrition | ✅ |
| `NSUserTrackingUsageDescription` | AdMob IDFA tracking (iOS 14.5+) | ✅ |
| `SKAdNetworkItems` | AdMob attribution | ✅ |
| `GADApplicationIdentifier` | AdMob App ID | ✅ |

#### HealthKit Review Notes (Apple จะถาม)

```
Q: Does your app send HealthKit data to a server?
A: No. HealthKit data (Active Energy Burned) is only used on-device
   to calculate daily calorie bonus. We store a derived value (netEnergy)
   which cannot be reverse-engineered to reveal raw health data.

Q: Do you use HealthKit data for advertising?
A: No. HealthKit data is never used for advertising purposes.

Q: Is HealthKit data shared with third parties?
A: No. Raw HealthKit values never leave the device.
```

---

### 16.2 Google Play Store — Data Safety

ต้องกรอกใน **Play Console > App Content > Data Safety**

#### Data Types ที่ต้องประกาศ

| Play Category | Data Type | Collected? | Shared? | Required? | Purpose |
|---|---|---|---|---|---|
| **Personal info** | Name, Email | ❌ | — | — | — |
| **Financial info** | Purchase history | ✅ | ❌ | Required | App functionality (via Google Play Billing) |
| **Health and fitness** | Health info | ✅ | ❌ | Optional | App functionality (Health Connect read/write) |
| **Health and fitness** | Nutrition info | ✅ | ✅ (if Food Research) | Required | App functionality, Analytics |
| **Photos and videos** | Photos | ✅ | ✅ (if Food Research) | Required | App functionality (thumbnails → Firebase) |
| **App activity** | App interactions | ✅ | ❌ | Optional | Analytics (Firebase Analytics, opt-in) |
| **App info and performance** | Crash logs | ✅ | ❌ | Required | App functionality |
| **Device or other IDs** | Device ID | ✅ | ❌ | Required | App functionality (hashed, anonymous) |
| **Device or other IDs** | Advertising ID | ✅ | ✅ (AdMob) | Optional | Advertising |

#### Data Safety — Additional Questions

| Question | Answer |
|----------|--------|
| Does your app collect or share any required data types? | **Yes** |
| Is all collected data encrypted in transit? | **Yes** (HTTPS) |
| Do you provide a way for users to request data deletion? | **Yes** (contact support@tnbgrp.com) |
| Can users request their data to be deleted? | **Yes** |

#### Android Permissions (AndroidManifest.xml)

| Permission | ใช้ทำอะไร | ต้องมี? |
|-----------|----------|---------|
| `INTERNET` | AI API calls, Firebase sync | ✅ |
| `CAMERA` | ถ่ายรูปอาหาร | ✅ |
| `READ_EXTERNAL_STORAGE` | เลือกรูปจากแกลเลอรี | ✅ |
| `AD_ID` | AdMob personalized ads (Android 13+) | ✅ |
| `health.READ_ACTIVE_CALORIES_BURNED` | Health Connect read | ✅ |
| `health.READ_TOTAL_CALORIES_BURNED` | Health Connect read | ✅ |
| `health.WRITE_NUTRITION` | Health Connect write | ✅ |

#### Data Deletion Requirement (Google Play บังคับ)

Google Play ต้องการ **Data Deletion URL** ที่ใช้งานได้จริง:
- ต้องมีหน้า web หรือ email ที่ user ขอลบข้อมูลได้
- ต้องระบุ **ระยะเวลาการลบ** (เช่น ภายใน 30 วัน)
- URL: ใส่ใน Play Console > App Content > Data Safety > Data deletion

```
ช่องทาง: support@tnbgrp.com
ข้อมูลที่ลบได้:
  - Firestore daily_sync data
  - Firebase Storage thumbnails
  - Energy balance
ระยะเวลา: ภายใน 30 วัน
ข้อมูลที่ลบไม่ได้: Purchase records (ตามกฎหมายภาษี)
```

---

### 16.3 Privacy Compliance Checklist

ทุกครั้งที่ release build ใหม่ที่เปลี่ยน data collection:

#### Pre-Release Checklist

```
[ ] Data Safety (Play Console) — อัปเดตแล้ว
[ ] App Privacy Labels (App Store Connect) — อัปเดตแล้ว
[ ] Privacy Policy (website + in-app) — อัปเดตแล้ว
[ ] Info.plist permissions — ครบถ้วน
[ ] AndroidManifest.xml permissions — ครบถ้วน
[ ] Consent dialogs — ทำงานถูกต้อง (Analytics, Food Research, Health Sync, AdMob UMP)
[ ] foodResearchConsent flag — ถูกเช็คก่อนส่ง research metadata ทุกจุด
[ ] HealthKit/Health Connect data — ไม่ถูกส่งขึ้น cloud (ใช้ derived netEnergy เท่านั้น)
```

#### Legal Documents ที่ต้องมี

| Document | ที่อยู่ | ครอบคลุม |
|----------|--------|---------|
| Privacy Policy | `PRIVACY_POLICY.md` + website | PDPA, GDPR, CCPA, HealthKit, Food Research |
| Terms of Service | in-app + website | Usage terms, data licensing, subscription |
| Data Collection Manual | `DATA_COLLECTION_MANUAL.md` | Internal reference (ไม่เผยแพร่) |
| Cookie/Tracking Notice | UMP consent dialog (AdMob) | Ad tracking consent |

#### GDPR (EU) — Required if selling globally

| Requirement | Status |
|-------------|--------|
| Lawful basis for processing | ✅ Legitimate interest (food tracking) + Consent (analytics, research) |
| Right to access | ✅ Profile > Export Data |
| Right to erasure | ✅ Profile > Clear Data + email request for cloud |
| Right to data portability | ✅ Backup/export as JSON |
| Right to object | ✅ Opt-out toggles for analytics, research |
| Data Protection Officer | ⚠️ ไม่จำเป็นถ้าองค์กรขนาดเล็ก แต่ต้องมี contact |
| Privacy by design | ✅ Offline-first, hashed IDs, no PII |
| Data breach notification | ⚠️ ต้องมี process (72 ชม.) — ยังไม่มี formal process |

#### CCPA (California, USA) — Required if selling globally

| Requirement | Status |
|-------------|--------|
| "Do Not Sell My Personal Information" | ⚠️ ต้องเพิ่มใน Privacy Policy |
| Right to know what data is collected | ✅ Privacy Policy ครอบคลุม |
| Right to delete | ✅ มีช่องทาง |
| Right to opt-out of sale | ✅ Food Research toggle = opt-out mechanism |
| Financial incentive notice | ⚠️ ถ้ามีการแลก data ↔ benefit (เช่น Food Research ↔ free features) ต้องประกาศ |

#### PDPA (Thailand) — Required

| Requirement | Status |
|-------------|--------|
| Consent before collection | ✅ Analytics + Research opt-in |
| Data minimization | ✅ Optional fields only sent when non-null |
| Right to access/delete | ✅ |
| Cross-border transfer notice | ⚠️ Firebase servers อยู่นอกไทย — ต้องระบุใน Privacy Policy |
| Data Protection Officer | ⚠️ ไม่จำเป็นถ้าองค์กรขนาดเล็ก |

---

### 16.4 เมื่อเพิ่ม Data Collection ใหม่ — Workflow

```
1. เพิ่ม field ใน FoodEntry / UserProfile / etc.
2. อัปเดต DATA_COLLECTION_MANUAL.md (เอกสารนี้)
3. อัปเดต _compactEntry() ใน data_sync_service.dart (ถ้า sync ขึ้น cloud)
4. อัปเดต _buildNutritionMetadata() ใน thumbnail_service.dart (ถ้าใส่ใน metadata)
5. อัปเดต PRIVACY_POLICY.md
6. อัปเดต website privacy page
7. เพิ่มใน checklist ด้านบน (16.3)
8. อัปเดต Data Safety (Play Console) ก่อน publish
9. อัปเดต App Privacy Labels (App Store Connect) ก่อน submit
```

---

## Appendix: ไฟล์สำคัญ

| ไฟล์ | หน้าที่ |
|------|--------|
| `lib/features/health/models/food_entry.dart` | โมเดลหลัก — ทุก data field |
| `lib/features/health/models/ingredient.dart` | DB วัตถุดิบ + upsert/incrementUsage |
| `lib/features/health/models/daily_summary.dart` | สรุป energy balance รายวัน |
| `lib/core/ai/gemini_service.dart` | AI prompts (scene context, brand detection) |
| `lib/core/services/data_sync_service.dart` | Cloud sync + auto-sync |
| `lib/core/services/backup_service.dart` | File backup/restore (device transfer) |
| `lib/core/services/thumbnail_service.dart` | รูปอาหาร + research metadata |
| `lib/core/services/usage_limiter.dart` | Free vs paid feature limits |
| `lib/core/services/daily_summary_service.dart` | Net energy calculation |
| `lib/core/utils/batch_analysis_helper.dart` | Apply AI results → FoodEntry |
| `lib/features/profile/models/user_profile.dart` | Consent flags |
| `lib/features/profile/presentation/profile_screen.dart` | Consent toggle + sync status |
| `PRIVACY_POLICY.md` | Legal — data collection disclosure |

---

## Appendix: SharedPreferences Keys

| Key | ไฟล์ | ใช้ทำอะไร |
|-----|------|----------|
| `data_sync_last_timestamp` | DataSyncService | timestamp ของ sync สำเร็จล่าสุด |
| `auto_sync_last_date` | DataSyncService | วันที่ auto-sync ล่าสุด (YYYY-MM-DD) |
| `last_backup_date` | GreetingService | วันที่ backup/sync ล่าสุด (for greeting reminder) |
| `edit_lookup_date` | UsageLimiter | วันที่นับ free edit lookup |
| `edit_lookup_count` | UsageLimiter | จำนวน free edit lookup ที่ใช้ไปวันนี้ |
