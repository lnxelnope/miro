# ArCal — Share Card Feature Plan
# แผนพัฒนาฟีเจอร์ Share Card สำหรับ Viral Marketing
# อัปเดต: มีนาคม 2026
# สถานะ: ⬜ รอพัฒนา

---

## 1. ภาพรวม

ฟีเจอร์ Share Card ช่วยให้ผู้ใช้สร้างรูปโภชนาการสวยๆ แชร์ลง Social Media
ทุกรูปฝัง **ArCal branding + QR code** เสมอ (บังคับ, ไม่สามารถลบได้)

### หลักการออกแบบ
- **Template เดียว** — ดีไซน์ dark premium สไตล์เดียว ไม่มี premium tier
- **Branding บังคับตลอด** — ทุก user เห็นเหมือนกัน ไม่มีตัวเลือกลบ
- **User เลือก hero image** — จาก gallery เอง (ไม่ใช่ auto-generate)
- **Instagramable** — ดีไซน์ต้องสวยจนคนอยากแชร์เอง

---

## 2. Share Card 3 ประเภท

### 2.1 Food Item Card (แชร์รายการอาหารเดี่ยว)

**เข้าถึงจาก:** ปุ่ม Share ใน `SimpleFoodDetailSheet` (Basic mode) และ `FoodDetailBottomSheet` (Pro mode)

**Flow:**
```
ผู้ใช้กดดูรายละเอียดอาหาร → กดปุ่ม Share → 
สร้าง Card อัตโนมัติจากรูป + ข้อมูลของ entry นั้น →
Preview → Share / Save to Gallery
```

**ข้อมูลบน Card:**

| ตำแหน่ง | เนื้อหา | แหล่งข้อมูล |
|---------|---------|------------|
| มุมซ้ายบน | ArCal QR code | `arcal.app/ref/{deviceId}` |
| มุมขวาบน | Goal badge "XX% GOAL" (optional) | `entry.calories / profile.mealBudget` |
| กลาง (hero) | รูปอาหารจาก entry นั้น (ใช้ภาพที่ถ่ายไว้ตอนบันทึก) | `FoodEntry.imagePath` |
| ซ้ายล่าง overlay | ชื่ออาหาร (ตัวใหญ่ bold) | `FoodEntry.foodName` |
| ป้ายสีเขียว | `XXX KCAL` | `FoodEntry.calories` |
| แถบกลาง | `P XXg  C XXg  F XXg` | `FoodEntry.protein/carbs/fat` |
| แถบล่าง | `Fiber Xg  Sugar Xg  Sodium Xmg` | `FoodEntry.fiber/sugar/sodium` |

**Layout (สไตล์จากดีไซน์):**
```
┌────────────────────────────────┐
│ [QR ArCal]              [SCORE]│  ← overlay บนรูป
│                                │
│                                │
│  [Hero Image - full bleed]     │  ← รูปจาก FoodEntry.imagePath เต็มพื้นที่
│                                │
│  Food Name                     │  ← text overlay, ตัวใหญ่ bold สีขาว
│  (หลายบรรทัดได้)                │     drop shadow ให้อ่านได้บนรูปทุกสี
│                                │
│  ┌──────────┐                  │
│  │ 650 KCAL │                  │  ← badge สีเขียว (#4CAF50)
│  └──────────┘                  │
│                                │
│  ┌──────────────────────────┐  │
│  │ P 45g   C 15g   F 28g   │  │  ← แถบ semi-transparent
│  └──────────────────────────┘  │
│                                │
│  ┌──────────────────────────┐  │
│  │ Fiber 8g  Sugar 4g  Na…  │  │  ← แถบ micro (optional toggle)
│  └──────────────────────────┘  │
└────────────────────────────────┘
```

**กรณีไม่มีรูป:** ใช้ background gradient สีเข้ม (dark teal/navy) แทน hero image (เช่น entry ที่พิมพ์เองไม่ได้ถ่ายรูป)

**กรณีไม่มี micro data:** ซ่อนแถบ micro อัตโนมัติ

---

### 2.2 Daily Summary Card (แชร์สรุปรายวัน)

**เข้าถึงจาก:** ปุ่ม Share บน `DailySummaryCard` ทั้ง Basic mode และ Pro mode

**Flow:**
```
ผู้ใช้กด Share ที่ Daily Summary Card →
เปิด Summary Share Card Creator →
เลือกรูป hero จาก gallery / เลือกรูปอาหารของวันนั้น →
เลือกข้อมูลที่ต้องการแชร์ (toggles) →
Preview → Share / Save to Gallery
```

**Creator Screen — ตัวเลือกที่ให้ผู้ใช้ customize:**

| หมวด | ตัวเลือก | Default |
|------|---------|---------|
| Hero Image | เลือกจาก gallery | ไม่มี (ใช้ gradient) |
| Food Photos | เลือกรูปอาหารของวันนั้นจาก entries (multi-select) | ไม่เลือก |
| Calories | แสดง total kcal + ไอคอน ✅ ถ้าใต้เป้า | ✅ เปิด |
| Macros | P / C / F | ✅ เปิด |
| Micros | Fiber / Sugar / Sodium | ❌ ปิด |
| Streak | แสดง X Day Streak 🔥 | ✅ เปิด (ถ้ามี streak) |
| Daily Progress | % ของเป้า kcal วันนี้ | ✅ เปิด |
| Health Data | Active Energy Burned (ถ้าเปิด HealthKit/Google Fit) | ❌ ปิด |

**Layout (สไตล์จากดีไซน์):**
```
┌────────────────────────────────┐
│ Daily Summary         [QR]    │
│ OCT 24, 2023                  │
│                                │
│                                │
│  [Hero Image / Food Collage]  │  ← รูปจาก gallery หรือ collage อาหาร
│                                │
│                                │
│                                │
│ ┌─────────┐ ┌────────────────┐│
│ │1,650 KCAL│ │ 85P 200C 55F ││  ← แถบข้อมูลหลัก
│ │    ✅    │ │               ││
│ └─────────┘ └────────────────┘│
│                                │
│ ┌──────────────────────────┐  │
│ │ Fiber 8g Sugar 4g Na 420 │  │  ← micro (ถ้าเปิด)
│ └──────────────────────────┘  │
│                                │
│ 🔥 12 DAY STREAK              │  ← streak (ถ้าเปิด)
└────────────────────────────────┘
```

**Food Photo Collage Logic:**
- ถ้าผู้ใช้เลือกรูปอาหาร 1 รูป → full bleed เหมือน Food Item Card
- ถ้าเลือก 2 รูป → แบ่ง 2 ช่อง (50/50 แนวตั้งหรือแนวนอน)
- ถ้าเลือก 3+ รูป → grid layout (2x2 หรือ staggered)
- ถ้าไม่เลือกรูปอาหาร + ไม่เลือก gallery → ใช้ gradient background

---

### 2.3 Nutrition Summary Card (แชร์สรุปโภชนาการตามช่วงเวลา)

**เข้าถึงจาก:** ปุ่ม Share บน `TodaySummaryDashboardScreen` (หน้า Nutrition Summary)

**Flow:**
```
ผู้ใช้อยู่หน้า Nutrition Summary (D/W/M/Y/All) →
กดปุ่ม Share → เปิด Summary Share Card Creator →
ข้อมูลดึงตามช่วงเวลาที่ผู้ใช้เลือกอยู่ (เช่น Weekly) →
เลือก hero image จาก gallery →
เลือกข้อมูลที่ต้องการแชร์ →
Preview → Share / Save to Gallery
```

**Creator Screen — ตัวเลือก:**

| หมวด | ตัวเลือก | Default |
|------|---------|---------|
| Hero Image | เลือกจาก gallery (เช่น รูปวิว, workout, อาหาร) | ไม่มี (ใช้ gradient) |
| Period Label | WEEKLY / MONTHLY / YEARLY / ALL | ตามที่กำลังดูอยู่ |
| Progress | X/7 DAYS (weekly) หรือ X/30 DAYS (monthly) | ✅ เปิด |
| Average Calories | ค่าเฉลี่ย kcal/วัน | ✅ เปิด |
| Average Macros | P / C / F เฉลี่ย | ✅ เปิด |
| Average Micros | Fiber / Sugar / Sodium เฉลี่ย | ❌ ปิด |
| Streak | แสดง streak ปัจจุบัน | ✅ เปิด (ถ้ามี) |

**Layout (สไตล์จากดีไซน์):**
```
┌────────────────────────────────┐
│ WEEKLY                  [QR]  │
│                                │
│                                │
│                                │
│  [Hero Image - full bleed]    │  ← รูปจาก gallery ที่ผู้ใช้เลือก
│                                │     (เช่น วิว, ธรรมชาติ, workout)
│                                │
│                                │
│                                │
│                                │
│ PROGRESS          AVERAGE     │
│ 5/7 DAYS   1.8k KCAL         │
│            ┌────────────────┐ │
│            │ 85P 200C 55F  │ │
│            └────────────────┘ │
│ ┌──────────────────────────┐  │
│ │ Fiber 8g Sugar 4g Na 420 │  │
│ └──────────────────────────┘  │
└────────────────────────────────┘
```

---

## 3. Share Card Creator Screen (หน้าสร้าง Card)

หน้าจอเดียวที่ใช้ร่วมกันทั้ง 3 ประเภท — แยก mode ตาม parameter

### 3.1 Screen Layout

```
┌────────────────────────────────┐
│  ← Back          Share Card   │  ← AppBar
│───────────────────────────────│
│                                │
│  ┌──────────────────────────┐ │
│  │                          │ │
│  │   [Live Card Preview]    │ │  ← RepaintBoundary
│  │                          │ │     อัพเดท real-time ตาม toggle
│  │                          │ │
│  └──────────────────────────┘ │
│                                │
│  ──── Hero Image ────         │  ← Section header
│  [📷 Choose from Gallery]     │  ← กดเปิด image picker
│  [ภาพตัวอย่าง / thumbnail]    │  ← แสดง preview รูปที่เลือก
│                                │
│  ──── Content Toggles ────    │  ← เฉพาะ Daily / Summary
│  ☑ Calories                   │
│  ☑ Macros (P/C/F)             │
│  ☐ Micros (Fiber/Sugar/Na)    │
│  ☑ Streak                     │
│  ☑ Goal Progress              │
│  ☐ Health Data                │
│                                │
│  ──── Food Photos ────        │  ← เฉพาะ Daily Summary
│  เลือกรูปอาหารของวันนี้:       │
│  [🖼️] [🖼️] [🖼️] [🖼️]          │  ← multi-select grid
│                                │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━  │
│  [💾 Save to Gallery]         │  ← บันทึกลงมือถือ
│  [📤 Share]                   │  ← เปิด native share sheet
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━  │
└────────────────────────────────┘
```

### 3.2 Card Preview

- ใช้ `RepaintBoundary` + `GlobalKey` wrap card widget
- Card render ขนาดจริง (1080px wide) แล้ว scale ลง fit preview area
- ทุกครั้งที่ toggle เปลี่ยน → rebuild card widget → preview อัพเดท real-time
- **Aspect ratio:** 4:5 (1080x1350) — เหมาะกับ Instagram post + story crop ได้

### 3.3 Capture & Share Flow

```dart
// 1. Capture card เป็นรูป
final boundary = _cardKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
final image = await boundary.toImage(pixelRatio: 3.0);
final byteData = await image.toByteData(format: ImageByteFormat.png);

// 2. เขียนไฟล์ temp
final tempDir = await getTemporaryDirectory();
final file = File('${tempDir.path}/arcal_share_${DateTime.now().millisecondsSinceEpoch}.png');
await file.writeAsBytes(pngBytes);

// 3. Share หรือ Save
// Share → Share.shareXFiles([XFile(file.path)])
// Save → image_gallery_saver / gal package
```

---

## 4. QR Code & Referral

### 4.1 QR Code บน Card

- ใช้ package `qr_flutter` สร้าง QR code
- URL: `https://arcal.app/ref/{deviceId}`
- ขนาด QR: 60x60 dp บน card (พอดีสแกนได้ ไม่ใหญ่เกินไป)
- มุม: ขวาบน (Summary cards) หรือ ซ้ายบน (Food Item card)
- สไตล์: ขาวบนพื้น dark, มี logo ArCal เล็กๆ ตรงกลาง QR

### 4.2 Referral Route (เว็บไซต์)

```
website/src/app/ref/[code]/page.tsx

- Server component → detect user-agent
  - iOS → redirect App Store
  - Android → redirect Play Store
  - Desktop → แสดงหน้า landing page + QR โหลดแอป
- Track click event: code, OS, country
```

### 4.3 Branding Text

- ตำแหน่ง: ฝังอยู่ใน card design (ไม่ใช่ watermark ที่ crop ออกได้ง่าย)
- Text: `"ArCal"` ผ่าน QR code logo + ชื่อแอปบน QR badge
- **บังคับแสดงเสมอ** — ไม่มี toggle ลบ ไม่มี premium ลบ

---

## 5. Goal Progress Badge (เสริมบน Food Item Card)

### แนวคิด
แสดง **% ของงบมื้อ** บน Share Card — ข้อเท็จจริงล้วนๆ ไม่ตัดสิน ไม่ให้เกรด

### แสดงเมื่อไหร่

- เฉพาะ **Food Item Card** → badge "XX% GOAL" มุมขวาบน (optional toggle)
- ถ้าผู้ใช้ปิด toggle → ไม่แสดง badge

### คำนวณ

```
goalPercent = (entry.calories / profile.mealBudget) * 100
เช่น 650 / 700 = 93% GOAL
```

### การแสดงผลบน Card

- 0–100% → badge สีเขียว
- 100–120% → badge สีเหลือง
- > 120% → badge สีส้ม
- ไม่มีสีแดง (หลีกเลี่ยงการตัดสิน)

---

## 6. จุดเข้าถึง Share (ปุ่มที่ต้องเพิ่ม)

| หน้าจอ | Widget ที่ต้องแก้ | ประเภท Card | Action |
|--------|-----------------|------------|--------|
| Basic mode food detail | `SimpleFoodDetailSheet` | Food Item Card | กด Share → เปิด Creator ส่ง `FoodEntry` |
| Pro mode food detail | `FoodDetailBottomSheet` | Food Item Card | กด Share → เปิด Creator ส่ง `FoodEntry` |
| Daily Summary (Basic) | `DailySummaryCard` (ใน `BasicModeTab`) | Daily Summary Card | กด Share → เปิด Creator ส่ง date + entries |
| Daily Summary (Pro) | `DailySummaryCard` (ใน `HealthTimelineTab`) | Daily Summary Card | กด Share → เปิด Creator ส่ง date + entries |
| Nutrition Summary | `TodaySummaryDashboardScreen` | Nutrition Summary Card | กด Share → เปิด Creator ส่ง period + data |
| AR Result (อนาคต) | `ImageAnalysisPreviewScreen` | Food Item Card | หลัง Gemini วิเคราะห์เสร็จ → ปุ่ม Share |

---

## 7. สิ่งที่ต้องเพิ่ม / ข้อเสนอแนะเพิ่มเติม

### 7.1 ที่ผู้ใช้ยังไม่ได้กล่าวถึง

| หัวข้อ | ข้อเสนอ | เหตุผล |
|--------|---------|--------|
| **Save to Gallery** | ปุ่ม "บันทึกลงมือถือ" แยกจากปุ่ม Share | หลายคนอยาก save ก่อนแล้วค่อย share เอง IG story ต้อง share จาก gallery |
| **Aspect Ratio** | เสนอ 4:5 (1080x1350) เป็น default | เหมาะ IG Feed + สามารถ crop เป็น Story 9:16 ได้ ไม่ต้องให้ผู้ใช้เลือก |
| **Empty State** | ถ้า FoodEntry ไม่มีรูป → แสดง gradient background + ชื่ออาหาร | ทำให้ทุก entry แชร์ได้ ไม่ใช่เฉพาะที่มีรูป |
| **Loading State** | แสดง shimmer/spinner ขณะ capture + share | Capture high-res อาจใช้เวลา 1-2 วินาที |
| **Haptic Feedback** | สั่นเบาเมื่อ capture เสร็จ | UX ที่ดีให้ feedback ว่าเสร็จแล้ว |
| **Card Font** | ใช้ font เดียวกับแอป (หรือ embed bold font) | ให้ card ดู consistent กับ brand |
| **Text Shadow / Scrim** | gradient scrim ด้านล่างรูป hero | ให้อ่าน text ได้ชัดบนรูปอะไรก็ได้ |
| **Micro Toggle Default** | ปิด micro เป็น default (เปิดได้ถ้าต้องการ) | ผู้ใช้ส่วนใหญ่ไม่ได้ track micro, card ดู clean กว่า |
| **Share Analytics** | Track ว่าใครแชร์อะไร, platform ไหน | วัดผล viral loop |
| **Deep Link Fallback** | ถ้า QR scan ไม่ได้ → มี "ArCal" text ให้ search | คนอาจ screenshot แล้ว crop QR ออก ชื่อ ArCal ช่วย |

### 7.2 สิ่งที่ตัดออก (ตามที่ผู้ใช้ขอ)

| สิ่งที่ตัด | เหตุผล |
|-----------|--------|
| ~~Premium templates~~ | ยุ่งยากเกินไป มี template เดียว |
| ~~ลบ branding สำหรับ Subscriber~~ | branding บังคับตลอด เป็นช่องทาง viral |
| ~~Template หลายแบบ (daily/weekly/streak)~~ | ใช้ template เดียว dynamic ตาม content |

---

## 8. Technical Architecture

### 8.1 File Structure

```
lib/features/sharing/
├── presentation/
│   └── share_card_creator_screen.dart   ← หน้าสร้าง card (ใช้ร่วมทุกประเภท)
├── widgets/
│   ├── share_card_food_item.dart        ← Card widget สำหรับอาหารเดี่ยว
│   ├── share_card_daily_summary.dart    ← Card widget สำหรับ daily
│   ├── share_card_nutrition_summary.dart ← Card widget สำหรับ nutrition period
│   ├── share_card_base.dart             ← Base widget (QR, branding, gradient scrim)
│   ├── hero_image_picker.dart           ← ปุ่มเลือกรูป + preview
│   ├── content_toggle_section.dart      ← Toggle switches สำหรับเลือก content
│   └── food_photo_selector.dart         ← Grid เลือกรูปอาหารของวัน
├── models/
│   └── share_card_config.dart           ← Config object (type, toggles, image path)
├── services/
│   └── card_capture_service.dart        ← RepaintBoundary capture + save + share
└── providers/
    └── share_card_provider.dart         ← State management สำหรับ toggles + image
```

### 8.2 ไฟล์ที่ต้องแก้

```
ไฟล์ที่ต้องแก้:
├── lib/features/home/widgets/simple_food_detail_sheet.dart
│   └── + ปุ่ม Share → navigate to ShareCardCreatorScreen(type: foodItem)
│
├── lib/features/health/widgets/food_detail_bottom_sheet.dart
│   └── + ปุ่ม Share → navigate to ShareCardCreatorScreen(type: foodItem)
│
├── lib/features/health/widgets/daily_summary_card.dart
│   └── + ปุ่ม Share → navigate to ShareCardCreatorScreen(type: daily)
│
├── lib/features/health/presentation/today_summary_dashboard_screen.dart
│   └── + ปุ่ม Share ใน AppBar → navigate to ShareCardCreatorScreen(type: nutrition)
│
├── pubspec.yaml
│   └── + qr_flutter: ^4.1.0
│   └── + image_gallery_saver_plus (หรือ gal) สำหรับ save to gallery
│
├── lib/l10n/app_en.arb + app_th.arb
│   └── + strings ทั้งหมดสำหรับ share feature
│
└── website/src/app/ref/[code]/page.tsx (ใหม่)
    └── Referral redirect route
```

### 8.3 Dependencies ใหม่

| Package | ใช้ทำอะไร | มีในแอปแล้ว? |
|---------|----------|-------------|
| `share_plus` | Native share sheet | ✅ มีแล้ว (^12.0.1) |
| `qr_flutter` | สร้าง QR code | ❌ ต้องเพิ่ม |
| `image_gallery_saver_plus` | Save รูปลง gallery | ❌ ต้องเพิ่ม |
| `image_picker` | เลือกรูปจาก gallery | ✅ มีแล้ว (ผ่าน ImagePickerService) |
| `path_provider` | Temp directory | ✅ มีแล้ว |

### 8.4 Share Card Config Model

```dart
enum ShareCardType { foodItem, dailySummary, nutritionSummary }

class ShareCardConfig {
  final ShareCardType type;
  
  // Hero image
  final String? heroImagePath;  // จาก gallery
  
  // Content toggles
  final bool showCalories;      // default: true
  final bool showMacros;        // default: true
  final bool showMicros;        // default: false
  final bool showStreak;        // default: true
  final bool showGoalProgress;  // default: true
  final bool showHealthData;    // default: false
  
  // Food photos (daily summary only)
  final List<String> selectedFoodPhotos;  // image paths จาก entries
  
  // Data
  final FoodEntryData? foodEntry;            // สำหรับ foodItem
  final DateTime? date;                       // สำหรับ daily
  final DateRange? dateRange;                 // สำหรับ nutrition summary
  final String? periodLabel;                  // "WEEKLY" / "MONTHLY" / etc.
}
```

---

## 9. Card Design Specs (สำหรับ Implement)

### 9.1 สี & สไตล์

| Element | ค่า |
|---------|-----|
| Card background | Dark (#1A2332 หรือ gradient dark teal) |
| Card size | 1080 x 1350 px (4:5 ratio) |
| Card corner radius | 24 dp |
| Text color | White (#FFFFFF) |
| Food name font | Bold, 32-40sp, drop shadow |
| Kcal badge | Green (#4CAF50), rounded pill, 18sp bold |
| Macro bar | Semi-transparent white (rgba 255,255,255,0.15), rounded 12dp |
| Micro bar | Semi-transparent white (rgba 255,255,255,0.10), rounded 12dp |
| QR code | White on transparent, 60x60 dp, ArCal logo center |
| Goal badge | Rounded rect, สีตาม % (เขียว/เหลือง/ส้ม), 14sp bold |
| Gradient scrim | Bottom → top, black 60% → transparent (ให้อ่าน text ได้) |

### 9.2 Typography Hierarchy

```
Food Name:        Bold, 32-40sp (ลดขนาดถ้าชื่อยาว)
Period Label:     Light/Caps, 14sp letter-spacing 2px ("WEEKLY", "DAILY SUMMARY")
Date:             Regular, 12sp, สี gray
Kcal Number:      Bold, 24sp
Kcal Unit:        Regular, 12sp
Macro Values:     SemiBold, 16sp
Macro Labels:     Regular, 12sp (P, C, F)
Micro Values:     Regular, 14sp
Streak:           SemiBold, 14sp
```

---

## 10. Analytics Events

| Event Name | Parameters | เมื่อไหร่ |
|------------|-----------|----------|
| `share_card_opened` | `type` (foodItem/daily/nutrition) | เปิด Creator screen |
| `share_card_image_selected` | `type`, `hasHeroImage` | เลือกรูปจาก gallery |
| `share_card_shared` | `type`, `platform`, `hasHeroImage`, `toggles` | กด Share สำเร็จ |
| `share_card_saved` | `type`, `hasHeroImage` | กด Save to Gallery |
| `referral_qr_scanned` | `code`, `os`, `country` | เว็บ /ref/ route |
| `referral_install` | `referrer_code` | เปิดแอปครั้งแรกจาก referral |

---

## 11. ลำดับการพัฒนา (Phases)

### Phase 1: Foundation (สัปดาห์ 1)
- [ ] สร้าง `card_capture_service.dart` (RepaintBoundary capture + save + share)
- [ ] เพิ่ม `qr_flutter` + `image_gallery_saver_plus` ใน pubspec
- [ ] สร้าง `share_card_config.dart` model
- [ ] สร้าง `share_card_base.dart` (QR + branding + gradient scrim)
- [ ] สร้าง referral redirect route บนเว็บไซต์

### Phase 2: Food Item Card (สัปดาห์ 1-2)
- [ ] สร้าง `share_card_food_item.dart` widget
- [ ] สร้าง `share_card_creator_screen.dart` (food item mode)
- [ ] เพิ่มปุ่ม Share ใน `SimpleFoodDetailSheet`
- [ ] เพิ่มปุ่ม Share ใน `FoodDetailBottomSheet`
- [ ] เพิ่ม i18n strings
- [ ] ทดสอบ share flow ทั้ง iOS + Android

### Phase 3: Daily Summary Card (สัปดาห์ 2-3)
- [ ] สร้าง `share_card_daily_summary.dart` widget
- [ ] สร้าง `food_photo_selector.dart` (grid เลือกรูปอาหารของวัน)
- [ ] สร้าง `content_toggle_section.dart`
- [ ] Update Creator Screen สำหรับ daily mode
- [ ] เพิ่มปุ่ม Share ใน `DailySummaryCard`
- [ ] ดึง streak data จาก `GamificationState`
- [ ] ทดสอบ

### Phase 4: Nutrition Summary Card (สัปดาห์ 3)
- [ ] สร้าง `share_card_nutrition_summary.dart` widget
- [ ] Update Creator Screen สำหรับ nutrition mode
- [ ] ดึง period summary data (W/M/Y/All)
- [ ] เพิ่มปุ่ม Share ใน `TodaySummaryDashboardScreen` AppBar
- [ ] ทดสอบ

### Phase 5: Goal Progress Integration (สัปดาห์ 3-4)
- [ ] เพิ่ม budget meter (progress bar) ใน `SimpleFoodDetailSheet`
- [ ] เพิ่ม budget meter ใน `FoodDetailBottomSheet`
- [ ] เพิ่ม Goal badge (XX% GOAL) บน Food Item Share Card (optional toggle)
- [ ] ทดสอบ

### Phase 6: Polish & Analytics (สัปดาห์ 4)
- [ ] เพิ่ม analytics events ทั้งหมด
- [ ] Loading state / haptic feedback
- [ ] Edge cases (ไม่มีรูป, ไม่มี micro data, ชื่อยาวมาก)
- [ ] ทดสอบ QR code สแกนได้จริง
- [ ] ทดสอบ referral redirect (iOS + Android + Desktop)

---

## 12. Risk & Considerations

| Risk | Mitigation |
|------|-----------|
| RepaintBoundary capture ช้าบนเครื่องเก่า | ใช้ `pixelRatio: 2.0` แทน 3.0 บนเครื่อง low-end, แสดง loading |
| QR code เล็กเกินสแกนไม่ได้ | ทดสอบกับ QR scanner หลายตัว, minimum 60dp |
| รูปจาก gallery ขนาดใหญ่ → memory issue | Resize image ก่อน render บน card (max 1080px width) |
| IG Story crop ทำให้ branding หายไป | วาง QR + branding ไว้ตรงกลาง-ล่าง (safe zone ของ story) |
| ผู้ใช้ share แล้ว QR link เสีย | ใช้ stable domain `arcal.app` ที่ควบคุมเอง |
| iOS permission gallery save | ต้องขอ `NSPhotoLibraryAddUsageDescription` ใน Info.plist |

---

## 13. สรุป Scope

```
✅ ทำ:
- Share Card 3 ประเภท (Food Item / Daily / Nutrition Summary)
- Creator Screen 1 หน้า (dynamic ตาม type)
- Hero image จาก gallery (ผู้ใช้เลือกเอง)
- Content toggles (เลือกว่าจะโชว์อะไร)
- Food photo selector (เลือกรูปอาหารของวัน)
- QR code + referral link
- Save to Gallery + Share
- Goal Progress badge (% GOAL)
- Analytics events
- Referral redirect route (เว็บ)

❌ ไม่ทำ:
- Premium template (template เดียว)
- ลบ branding (บังคับตลอด)
- Multiple aspect ratios (ใช้ 4:5 เดียว)
- Video share (เฉพาะรูปนิ่ง)
- In-app referral tracking ระบบเต็ม (ทำแค่ redirect + basic tracking)
```

---

*เอกสารนี้เป็นแผนพัฒนาฟีเจอร์ Share Card — อ้างอิงจากดีไซน์ของผู้ใช้*
*อัปเดต: มีนาคม 2026*
