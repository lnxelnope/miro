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
| Subscriber | template premium + ลบ branding ได้ |
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
| Subscriber | ลบ branding ได้ |
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

## ฟีเจอร์ C: Meal Score (A–D)

### แนวคิด
หลังวิเคราะห์อาหาร → ให้ "คะแนน" แต่ละมื้อแบบ gamify
เป้าหมาย: (1) retention — อยากได้ A+ ทุกมื้อ (2) viral — อวดหรือขำ

### สูตรคำนวณ

```
Meal Score คำนวณจาก 3 ปัจจัย (0–100 คะแนน):

1. Macro Balance (40%):
   - เทียบ protein/carbs/fat ratio กับเป้าหมาย
   - ยิ่งใกล้เป้า = คะแนนสูง

2. Calorie Budget (40%):
   - เทียบ kcal มื้อนี้ กับ kcal ที่เหลือในวัน
   - กินพอดี = สูง / กินเกิน budget = ต่ำ

3. Variety Bonus (20%):
   - วัตถุดิบหลากหลาย = +คะแนน
   - มื้อที่มี ≥3 วัตถุดิบ = full score

เกรด:
  90–100 = A+  "สมดุลมาก!"
  80–89  = A   "ดีเยี่ยม"
  70–79  = B+  "ดี"
  60–69  = B   "พอใช้"
  50–59  = C   "ควรปรับ"
  < 50   = D   "เกินเป้ามาก"
```

### UI — แสดงใน Result Screen

```
┌─────────────────────────┐
│  ข้าวมันไก่              │
│  650 kcal               │
│                         │
│      ┌─────────┐        │
│      │   B+    │        │  ← Badge ตัวใหญ่ สีสัน
│      └─────────┘        │
│                         │
│  "โปรตีนดี แต่ผักน้อย"   │  ← AI comment สั้นๆ
│                         │
│  [Share] [Details]      │
└─────────────────────────┘
```

### AI Comment

```
ใช้ Gemini สร้าง comment สั้น 1 บรรทัด (≤30 ตัวอักษร)
ตาม Meal Score:

A+ → "สมดุลเลิศ! 💯"
A  → "เยี่ยมมาก ครบทุกสารอาหาร"
B  → "โปรตีนดี แต่ผักน้อย"
C  → "แคลอรี่เกินเป้าเล็กน้อย"
D  → "Cheat day หรือเปล่า? 😅"

หรือใช้ template ที่คำนวณจากข้อมูลจริง (ไม่ต้องเรียก Gemini เพิ่ม)
```

### Business Rules

| Rule | รายละเอียด |
|------|-----------|
| แสดงเมื่อไหร่ | หลัง Gemini วิเคราะห์เสร็จ (ทุกมื้อ) |
| คำนวณที่ไหน | Client-side (ไม่ต้องเรียก API เพิ่ม) |
| Share | รวมใน AR Snap Share Card |
| Gamification | แสดงใน history + daily summary |
| ต้องการเป้าหมาย | ต้องมี daily calorie goal ตั้งไว้ |

### Implementation Guide

```
ไฟล์ที่ต้องสร้าง:
├── lib/features/summary/services/
│   └── meal_score_calculator.dart   ← สูตรคำนวณ + grade + comment

ไฟล์ที่ต้องแก้:
├── lib/features/arscan/ (หรือ result screen)
│   └── เพิ่ม Meal Score badge + comment ใน result
│
├── lib/features/health/
│   └── เพิ่ม average Meal Score ใน daily summary
```

### ทำไมนี่จะทำงาน

1. **"ได้ A+"** → อยากอวด → share!
2. **"ได้ D"** → "555 มื้อนี้ D เลย" → share เหมือนกัน!
3. ทั้ง 2 กรณี = **ArCal ถูกแชร์**
4. Gamification → **ใช้ทุกวัน** → retention สูงขึ้น

### ระดับความยาก: ง่าย
- แค่สูตรคำนวณ + UI badge
- ไม่ต้องเรียก API เพิ่ม

---

## ลำดับการพัฒนา (Priority)

| Priority | ฟีเจอร์ | ทำไม |
|----------|---------|------|
| **1** | Meal Score | ง่ายสุด + เพิ่ม retention ทันที |
| **2** | AR Snap & Share | ปุ่มเดียว = viral ได้เลย |
| **3** | Shareable Summary Card | ต้องสร้าง 3 templates + QR |

### Timeline

```
สัปดาห์ 1: Meal Score (calculator + UI badge)
สัปดาห์ 1–2: AR Snap & Share (template + capture + share)
สัปดาห์ 2–3: Summary Card (3 templates + QR + referral route)
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
| `meal_score_view` | Result Screen | score, grade |
| `referral_click` | Website /ref/ | code, os, country |
| `referral_install` | App first_open | referrer_code |
| `referral_bonus` | Cloud Function | referrer_id, amount |

---

*เอกสารนี้เป็น specification สำหรับทีมพัฒนา — แยกจาก pricing action plan*
*อัปเดต: มีนาคม 2026*
