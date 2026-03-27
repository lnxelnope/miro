# ArCal — Viral Features Specification
# ฟีเจอร์ใหม่เพื่อสร้าง Viral Loop + เพิ่ม Retention
# อัปเดต: มีนาคม 2026
# สถานะ: ⬜ รอพัฒนา

---

## ภาพรวม — ทำไมต้องมีฟีเจอร์เหล่านี้

```
ปัญหา: ทุก install มาจาก Ads = จ่ายทุกคน (CAC ฿600)
เป้าหมาย: ทำให้ user เป็น "นักการตลาด" ให้เรา

1 share → ~100 คนเห็น (IG story reach)
→ 2% กดลิงก์ = 2 คน
→ 50% ลง = 1 install ฟรี (CAC ฿0)

ถ้า active user 50 คน แชร์ 1 ครั้ง/สัปดาห์
= 50 installs/สัปดาห์ = 200/เดือน = ฟรีทั้งหมด
```

---

## ฟีเจอร์ A: Shareable Summary Card

### แนวคิด
ให้ผู้ใช้แชร์สรุปโภชนาการ (Daily/Weekly/Streak) เป็นรูปสวยๆ ลง Social
ทุกรูปมี branding + QR code + referral link

### Template 3 แบบ

#### 1. Daily Summary Card
```
┌──────────────────────────┐
│  📅 27 มี.ค. 2026         │
│                          │
│  วันนี้กินไป              │
│  ████████░░  1,650 kcal  │
│  เป้า: 2,000             │
│                          │
│  P: 85g  C: 200g  F: 55g│
│                          │
│  มื้อที่กิน: 3 มื้อ       │
│                          │
│  ──────────────────────  │
│  Tracked with ArCal      │
│  [QR]  arcal.app/ref/xxx │
└──────────────────────────┘
```

#### 2. Weekly Summary Card
```
┌──────────────────────────┐
│  📊 สรุปสัปดาห์           │
│  21 - 27 มี.ค. 2026      │
│                          │
│  Mon ██░  1,800          │
│  Tue ███  2,100          │
│  Wed ██░  1,650          │
│  Thu ██░  1,900          │
│  Fri ███  2,200          │
│  Sat ██░  1,750          │
│  Sun ██░  1,600          │
│                          │
│  เฉลี่ย: 1,857 kcal/วัน  │
│  ใต้เป้า: 5/7 วัน ✅      │
│                          │
│  ──────────────────────  │
│  Tracked with ArCal      │
│  [QR]  arcal.app/ref/xxx │
└──────────────────────────┘
```

#### 3. Streak Card
```
┌──────────────────────────┐
│  🔥 7 Days Streak!       │
│                          │
│  ติดตามโภชนาการ           │
│  ครบ 7 วันต่อเนื่อง       │
│                          │
│  ⭐⭐⭐⭐⭐⭐⭐             │
│                          │
│  ──────────────────────  │
│  Tracked with ArCal      │
│  [QR]  arcal.app/ref/xxx │
└──────────────────────────┘
```

### Business Rules

| Rule | รายละเอียด |
|------|-----------|
| Free user | แชร์ได้ — **ติด branding + QR เสมอ** (ดีสำหรับเรา!) |
| Subscriber | เหมือน Free — **branding บังคับตลอด** (ช่องทาง viral) |
| QR code | ลิงก์ไป `arcal.app/ref/{deviceId}` |
| Referral link | Redirect ไป store ที่ถูก platform (Android/iOS) |
| Analytics | Track `share_summary` event: type (daily/weekly/streak) |

### Implementation Guide

```
ไฟล์ที่ต้องสร้าง:
├── lib/features/summary/
│   ├── presentation/
│   │   └── share_summary_screen.dart     ← เลือก template + preview
│   ├── widgets/
│   │   ├── summary_card_daily.dart       ← Template วันนี้
│   │   ├── summary_card_weekly.dart      ← Template สัปดาห์
│   │   └── summary_card_streak.dart      ← Template streak
│   └── services/
│       └── summary_share_service.dart    ← capture (RepaintBoundary) + share

ไฟล์ที่ต้องแก้:
├── lib/features/health/presentation/today_summary_dashboard_screen.dart
│   └── เพิ่มปุ่ม "Share" ที่ summary screen
│
└── pubspec.yaml
    └── + qr_flutter (QR code generation)
    └── + share_plus (ถ้ายังไม่มี)

เว็บไซต์:
└── website/src/app/ref/[code]/page.tsx
    └── Redirect route: detect OS → redirect to Play Store / App Store
```

### เทคนิคการ Capture + Share

```dart
// ใช้ RepaintBoundary + RenderRepaintBoundary
final boundary = _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
final image = await boundary.toImage(pixelRatio: 3.0);
final byteData = await image.toByteData(format: ImageByteFormat.png);
// Save temp file → share via share_plus
```

### ระดับความยาก: กลาง
- RepaintBoundary capture เป็น pattern ที่ทำมาแล้ว
- QR code ใช้ library ได้เลย
- Design template ใช้เวลาส่วนใหญ่

---

## ฟีเจอร์ B: AR Snap & Share

### แนวคิด
หลัง AR scan + Gemini วิเคราะห์เสร็จ → ปุ่ม "Share" ในหน้าผลลัพธ์
→ สร้างรูปสวยจากข้อมูลที่ Gemini วิเคราะห์ได้ + ภาพอาหาร → แชร์ออก Social

### AR Flow (เข้าใจให้ถูก)

```
1. เปิด AR Camera → Local AI วาด bounding box (guide ถ่ายรูป)
2. ผู้ใช้ถ่ายภาพ → ส่ง 3 ภาพ (top-down, 180°, 45-60°) + px + bb ไป Gemini
3. Gemini วิเคราะห์ → ส่งกลับ: ชื่ออาหาร, kcal, macro, micro
4. แสดงหน้า Result Screen ← ⭐ จุดนี้แหละที่เพิ่มปุ่ม Share

AR bounding box ≠ AR overlay (ไม่ได้โชว์ kcal ลอยบนอาหาร)
ดังนั้น "AR Snap & Share" = แชร์หน้า Result Screen ไม่ใช่ bounding box
```

### Share Card Layout

```
┌──────────────────────────┐
│  [ภาพอาหาร top-down]     │
│                          │
│  ผัดกะเพราไข่ดาว          │
│  ────────────────────    │
│  650 kcal                │
│                          │
│  Protein  35g  ████░░    │
│  Carbs    45g  █████░    │
│  Fat      30g  ███░░░    │
│                          │
│  ──────────────────────  │
│  Scanned with ArCal 📸   │
│  [QR]  arcal.app/ref/xxx │
└──────────────────────────┘
```

### Business Rules

| Rule | รายละเอียด |
|------|-----------|
| ใช้ภาพ top-down | เพราะเป็นภาพหลักที่ Gemini ใช้วิเคราะห์ (สวยสุด) |
| Free user | แชร์ได้ — ติด branding "Scanned with ArCal" + QR |
| Subscriber | เหมือน Free — **branding บังคับตลอด** |
| Analytics | Track `share_ar_result` event |

### Implementation Guide

```
ไฟล์ที่ต้องสร้าง:
├── lib/features/summary/widgets/
│   └── ar_snap_share_card.dart    ← Card template สำหรับ AR result

ไฟล์ที่ต้องแก้:
├── lib/features/arscan/ (หน้า result หลัง Gemini วิเคราะห์เสร็จ)
│   └── เพิ่มปุ่ม "Share" ใน result screen
│   └── กดแล้ว → สร้าง ar_snap_share_card → capture → share
```

### ทำไมนี่จะ Viral

1. **อาหารเป็นเรื่อง social** — คนถ่ายรูปอาหารอยู่แล้ว
2. **"กินผัดกะเพรา 650 แคล!"** — debate + engagement สูง
3. **คนอยากลอง** "สแกนอาหารตัวเอง" → ลง ArCal
4. **QR code** → ลงแอปได้ทันที

### ระดับความยาก: ง่าย–กลาง
- ใช้ภาพ top-down ที่มีอยู่แล้ว
- Overlay template + capture + share

---

## ฟีเจอร์ C: Goal Progress (Budget Meter)

### แนวคิด
แสดงให้ผู้ใช้เห็น **ข้อเท็จจริง** ว่ามื้อนี้อยู่ตรงไหนของเป้าหมายที่ตั้งไว้
**ไม่ตัดสิน ไม่ให้เกรด ไม่ comment** — แค่นำเสนอข้อมูลให้ผู้ใช้ตีความเอง

### ทำไมไม่ใช้ Meal Score / Grade

```
ปัญหาของ Score/Grade:
- "ได้ D" → ผู้ใช้รู้สึกถูกตัดสิน → เลิกใช้แอป
- Comment อย่าง "Cheat day?" → toxic โดยไม่ตั้งใจ
- อาจกระทบผู้ที่มีปัญหาเรื่อง eating disorder
- Grade ไม่ได้บอกว่าต้องปรับอะไร

ทำไม Budget Meter ดีกว่า:
- "650/700 kcal" = ข้อเท็จจริง ไม่มีอารมณ์
- ผู้ใช้เห็นชัดว่าอยู่ตรงไหนของเป้า
- ไม่ต้อง maintain สูตร score ที่ซับซ้อน
- Neutral — ปลอดภัยสำหรับทุกคน
```

### ข้อมูลที่แสดง (ต่อมื้อ)

```
ใช้ข้อมูลที่มีอยู่แล้วในแอป:

1. Calorie Budget:
   entry.calories vs profile.{mealType}Budget
   เช่น มื้อกลางวัน: 650 / 700 kcal (93%)

2. Daily Progress:
   กินไปแล้ววันนี้ vs profile.calorieGoal
   เช่น 1,200 / 2,000 kcal (60%)

3. Macro Progress:
   entry.protein vs profile.proteinGoal (ส่วนแบ่งต่อมื้อ)
   entry.carbs vs profile.carbGoal
   entry.fat vs profile.fatGoal
```

### UI — แสดงใน Food Detail

```
┌─────────────────────────┐
│  ข้าวมันไก่              │
│  650 kcal               │
│                         │
│  งบมื้อกลางวัน:           │
│  ██████████░░  650/700  │  93%
│                         │
│  วันนี้:                 │
│  ██████░░░░░  1,200/2,000│ 60%
│                         │
│  P ████░░  28/40g       │
│  C █████░  48/83g       │
│  F ███░░░  22/22g       │
│                         │
│  [Share] [Details]      │
└─────────────────────────┘
```

### สีของ Progress Bar (Neutral — ไม่ตัดสิน)

```
0–100%  → สีเขียว (ยังอยู่ในงบ)
100–120% → สีเหลือง (ใกล้/เกินงบเล็กน้อย)
> 120%  → สีส้ม (เกินงบ)

หมายเหตุ: สีเป็น visual cue ไม่ใช่ judgment
ไม่มีสีแดง (หลีกเลี่ยงความรู้สึก "ผิด")
```

### บน Share Card

```
แสดง % ของเป้าบน badge (ถ้าผู้ใช้เปิด toggle):

┌──────────┐
│ 93% GOAL │   ← สีเขียว
└──────────┘

หรือไม่แสดงเลยก็ได้ — card แชร์แค่ kcal + macro
ซึ่งเป็น fact ล้วนๆ
```

### Business Rules

| Rule | รายละเอียด |
|------|-----------|
| แสดงเมื่อไหร่ | หลัง Gemini วิเคราะห์เสร็จ (มี kcal แล้ว) |
| คำนวณที่ไหน | Client-side (entry kcal vs profile goal — ไม่เรียก API) |
| ข้อมูลจากไหน | `FoodEntry` + `UserProfile` + `foodEntriesByDateProvider` |
| Share | แสดง % GOAL บน Share Card (optional toggle) |
| Gamification | ใช้ **Streak** แทน (ที่มีอยู่แล้ว) — ไม่ score มื้ออาหาร |
| ไม่มี goal? | ใช้ default (2000/120/250/65) ที่มีใน DB อยู่แล้ว |

### Implementation Guide

```
ไม่ต้องสร้างไฟล์ใหม่ — แค่แก้ UI ที่มีอยู่:

ไฟล์ที่ต้องแก้:
├── lib/features/home/widgets/simple_food_detail_sheet.dart
│   └── เพิ่ม progress bars (kcal vs budget, daily progress)
│
├── lib/features/health/widgets/food_detail_bottom_sheet.dart
│   └── เพิ่ม progress bars เหมือนกัน
│
├── lib/features/health/widgets/daily_summary_card.dart
│   └── มี progress อยู่แล้ว (วงแหวน kcal) — ไม่ต้องแก้
```

### ทำไมนี่ถึงดี

1. **ข้อเท็จจริง ไม่ toxic** — แค่บอกว่า 650/700 kcal
2. **ผู้ใช้ตีความเอง** — "93% โอเค พอดี" หรือ "เกือบหมดงบแล้วนะ"
3. **ไม่ต้อง maintain** สูตรซับซ้อน — แค่หาร
4. **DailySummaryCard มี progress อยู่แล้ว** — แค่เพิ่มระดับมื้อ
5. **Share Card** แชร์ได้เหมือนกัน — "กินข้าวมันไก่ 650 kcal 93% ของงบมื้อเที่ยง"

### ระดับความยาก: ง่ายมาก
- ไม่ต้องสร้างไฟล์ใหม่
- แค่เพิ่ม progress bar ใน sheet ที่มีอยู่
- ข้อมูลทุกอย่างพร้อมใช้

---

## ลำดับการพัฒนา (Priority)

| Priority | ฟีเจอร์ | ทำไม |
|----------|---------|------|
| **1** | Goal Progress (Budget Meter) | ง่ายสุด — แค่ progress bar, ข้อมูลมีครบ |
| **2** | AR Snap & Share | ปุ่มเดียว = viral ได้เลย |
| **3** | Shareable Summary Card | ต้องสร้าง templates + QR |

### Timeline

```
สัปดาห์ 1: Goal Progress — เพิ่ม budget meter ใน food detail sheets
สัปดาห์ 1–2: AR Snap & Share (template + capture + share)
สัปดาห์ 2–3: Summary Card (templates + QR + referral route)
```

---

## Referral System (ใช้ร่วมกับทุกฟีเจอร์ข้างบน)

### Flow

```
1. ผู้ใช้แชร์ card (Summary / AR Snap)
2. คนเห็นรูป → สแกน QR → เปิด arcal.app/ref/{code}
3. เว็บ detect OS:
   - Android → redirect Play Store
   - iOS → redirect App Store
4. ลงแอป → เปิดครั้งแรก → ระบบเช็ค referral
5. ผู้แนะนำ ได้ reward (Energy bonus)
```

### Implementation

```
เว็บไซต์:
└── website/src/app/ref/[code]/page.tsx
    └── Server component: detect user-agent → redirect to store
    └── Track referral code ผ่าน query param ส่งต่อ store

แอป (Android):
└── ใช้ Play Install Referrer API อ่าน referral code

แอป (iOS):
└── ใช้ deferred deep link (branch.io หรือ custom)

Backend:
└── Cloud Function: validateReferral → give bonus to referrer
```

### Referral Bonus (ปรับใน Admin Panel)

| ใครได้ | Bonus |
|--------|-------|
| ผู้แนะนำ | +10E ต่อ install (จำกัด 5 คน/วัน) |
| ผู้ถูกแนะนำ | +5E (เพิ่มจาก 10E เริ่มต้น → 15E) |

---

## Metrics ที่ต้อง Track

| Event | ที่ไหน | วัดอะไร |
|-------|--------|---------|
| `share_summary` | Summary Card | type, template, platform |
| `share_ar_result` | AR Snap Share | food_name, kcal |
| `goal_progress_view` | Food Detail Sheet | meal_kcal, budget, percent |
| `referral_click` | Website /ref/ | code, os, country |
| `referral_install` | App first_open | referrer_code |
| `referral_bonus` | Cloud Function | referrer_id, amount |

---

*เอกสารนี้เป็น specification สำหรับทีมพัฒนา — แยกจาก pricing action plan*
*อัปเดต: มีนาคม 2026*
