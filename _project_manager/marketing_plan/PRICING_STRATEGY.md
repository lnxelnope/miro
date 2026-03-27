# ArCal — Pricing & Monetization Action Plan
# อัปเดต: มีนาคม 2026
# สถานะ: ✅ โค้ดแก้แล้ว → รอแก้ Store + Admin Panel

---

## สถานะรวม

| ส่วน | สถานะ | หมายเหตุ |
|------|--------|---------|
| โค้ดแอป (Dart) | ✅ เสร็จแล้ว | ราคา + free tier + ลบ weekly |
| Google Play Console | ⬜ ต้องทำ | สร้าง product ใหม่ + archive เก่า |
| App Store Connect | ⬜ ต้องทำ | สร้าง product ใหม่ + archive เก่า |
| Admin Panel (Firebase) | ⬜ ต้องทำ | ปรับ daily bonus, challenge rewards |
| ส่ง Review ทั้ง 2 Platform | ⬜ ต้องทำ | หลังแก้ทุกอย่างเสร็จ |

---

## 1. สิ่งที่แก้ในโค้ดแล้ว ✅

### 1.1 Subscription — ตัด Weekly, ปรับราคา

| ไฟล์ | การเปลี่ยนแปลง |
|------|----------------|
| `subscription_plan.dart` | ลบ `energyPassWeekly()` / Monthly → $9.99 / Yearly → $22.99 (isPopular) / savingsText "Save 81%" |
| `subscription_service.dart` | ลบ `kIosWeeklyProductId` / ลบ weekly จาก `_subscriptionProductIds` |
| `verifySubscription.ts` | เก็บ weekly ไว้ (backward compat) + comment deprecated |

**ราคาใหม่:**

| แผน | ราคาเดิม | ราคาใหม่ | ≈ THB | ตำแหน่ง |
|-----|---------|---------|-------|---------|
| ~~Weekly~~ | $1.99 | **ยกเลิก** | — | — |
| Monthly | $4.99 | **$9.99** | ฿349 | "ลองดูก่อน 1 เดือน" |
| Yearly | $39.99 | **$22.99** | ฿799 | ★ Best Value — save 81% |

### 1.2 Energy Packs — ลดเหลือ 3 แพ็ก, ปรับราคา

| ไฟล์ | การเปลี่ยนแปลง |
|------|----------------|
| `purchase_service.dart` | เพิ่ม `energy_50`, `energy_200`, `energy_500` / เก็บ legacy IDs สำหรับ restore |
| `energy_store_screen.dart` | 3 cards: 50E/$1.99, 200E/$5.99 (Popular), 500E/$12.99 (Best Value) |

**แพ็กใหม่:**

| แพ็ก | ราคาเดิม | ราคาใหม่ | Energy | ≈ THB | ตำแหน่ง |
|------|---------|---------|--------|-------|---------|
| ~~100E~~ | $0.99 | **ยกเลิก** | — | — | — |
| Starter | — | **$1.99** | 50E | ฿69 | Impulse buy |
| ~~550E~~ | $4.99 | **ยกเลิก** | — | — | — |
| Standard | — | **$5.99** | 200E | ฿199 | ★ Popular |
| ~~1200E~~ | $7.99 | **ยกเลิก** | — | — | — |
| Power | — | **$12.99** | 500E | ฿449 | Best Value |
| ~~2000E~~ | $9.99 | **ยกเลิก** | — | — | — |

### 1.3 Free Tier — ลด Chat Limit

| ไฟล์ | การเปลี่ยนแปลง |
|------|----------------|
| `usage_limiter.dart` | `freeChatPerDay`: 10 → **5** |

---

## 2. สิ่งที่ต้องทำใน Google Play Console ⬜

### 2.1 Subscription (miro_normal_subscription)

- [ ] **ลบ Base Plan "energy-pass-weekly"**
  - ไปที่ Monetize → Subscriptions → miro_normal_subscription
  - กด Base Plan "energy-pass-weekly" → Archive/Deactivate
  - ⚠️ ห้ามลบถาวร — archive เฉยๆ (backward compat)

- [ ] **แก้ราคา Base Plan "energy-pass-monthly"**
  - Price: **$9.99** (หรือ ฿349 ถ้าตั้ง THB ตรง)
  - Description: "Unlimited AI Analysis"

- [ ] **แก้ราคา Base Plan "energy-pass-yearly"**
  - Price: **$22.99** (หรือ ฿799 ถ้าตั้ง THB ตรง)
  - Description: "Best value — save 81%"

- [ ] **Free Trial (ถ้ายังไม่มี)**
  - สร้าง Offer ใน Yearly plan → "free-trial-7d"
  - Trial period: **7 days**

### 2.2 In-App Products (Consumable Energy Packs)

- [ ] **สร้าง Product ใหม่ 3 ตัว:**

| Product ID | ชื่อ | ราคา |
|-----------|------|------|
| `energy_50` | Starter Energy Pack | $1.99 |
| `energy_200` | Standard Energy Pack | $5.99 |
| `energy_500` | Power Energy Pack | $12.99 |

- [ ] **Archive Product เก่า 4 ตัว:**

| Product ID | Action |
|-----------|--------|
| `energy_100` | Archive (ห้ามลบ — restore compat) |
| `energy_550` | Archive |
| `energy_1200` | Archive |
| `energy_2000` | Archive |

### 2.3 Store Listing อัปเดต (ถ้าต้องการ)

- [ ] อัปเดต screenshot ที่แสดงราคา (ถ้ามี)
- [ ] อัปเดต description เรื่อง subscription benefits

---

## 3. สิ่งที่ต้องทำใน App Store Connect ⬜

### 3.1 Subscriptions

- [ ] **Archive product "miro_energy_pass_weekly"**
  - ไปที่ App → Subscriptions → miro_energy_pass_weekly
  - Remove from sale / Archive

- [ ] **แก้ราคา "miro_energy_pass_monthly"**
  - Price: **$9.99** (Tier 15 หรือใกล้เคียง)

- [ ] **แก้ราคา "miro_energy_pass_yearly"**
  - Price: **$22.99** (Tier 34 หรือใกล้เคียง)

- [ ] **ตั้ง Free Trial (Introductory Offer)**
  - Product: miro_energy_pass_yearly
  - Type: Free Trial
  - Duration: **7 days**

### 3.2 In-App Purchases (Consumable)

- [ ] **สร้าง IAP ใหม่ 3 ตัว:**

| Product ID | ชื่อ | ราคา | Type |
|-----------|------|------|------|
| `energy_50` | Starter Energy Pack | $1.99 | Consumable |
| `energy_200` | Standard Energy Pack | $5.99 | Consumable |
| `energy_500` | Power Energy Pack | $12.99 | Consumable |

  - ⚠️ ต้องกรอก Review Information + Screenshot สำหรับ Apple Review

- [ ] **Archive IAP เก่า 4 ตัว:**

| Product ID | Action |
|-----------|--------|
| `energy_100` | Remove from sale |
| `energy_550` | Remove from sale |
| `energy_1200` | Remove from sale |
| `energy_2000` | Remove from sale |

---

## 4. สิ่งที่ต้องทำใน Admin Panel (Firebase) ⬜

> ส่วนนี้คือระบบ bonus/challenge/daily ที่กำหนดจาก backend — แก้ใน admin panel ได้เลยไม่ต้องแก้โค้ด

### 4.1 Daily Check-in Energy

| Setting | ค่าเดิม | ค่าใหม่ | หมายเหตุ |
|---------|---------|---------|---------|
| Daily check-in (Free user) | 1–3E | **1E** | ลดให้พอ 1 scan/วัน |
| Daily check-in (Subscriber) | 1–3E | **1E** (เท่ากัน) | Subscriber ไม่ต้องการ E อยู่แล้ว |

### 4.2 Daily Challenge Rewards

| Challenge | ค่าเดิม | ค่าใหม่ | หมายเหตุ |
|-----------|---------|---------|---------|
| AI 1x (สแกน 1 ครั้ง) | +1E | **ยกเลิก** | ได้คืนเท่าที่ใช้ = ฟรีตลอดชีวิต |
| AI 10x (สแกน 10 ครั้ง) | +3E | **+2E** (subscriber only) | เป็น perk ของ subscriber |
| Weekly challenge | +5E | **+3E** | ลดลงเล็กน้อย |

### 4.3 เป้าหมาย Free Tier ใหม่

```
Free user: ได้ ~1–2E/วัน (30–60E/เดือน)
  → สแกนได้ 1–2 มื้อ/วัน (casual user = ใช้ฟรีได้ = ambassador)
  → Core user สแกน 3+ มื้อ/วัน = Energy ไม่พอ = ต้องจ่าย

Subscriber: Unlimited AI + bonus 2E/วันจาก challenge
  → ไม่ต้องกังวลเรื่อง Energy
```

---

## 5. ส่ง Review ทั้ง 2 Platform ⬜

### 5.1 Google Play

- [ ] Build APK/AAB ใหม่ด้วยราคาใหม่ในโค้ด
- [ ] อัปโหลดเข้า Internal/Open Testing
- [ ] ทดสอบ:
  - [ ] ซื้อ Monthly ($9.99) → ได้ subscription
  - [ ] ซื้อ Yearly ($22.99) → ได้ subscription
  - [ ] ซื้อ Energy Pack ทั้ง 3 แพ็ก → ได้ Energy ถูกต้อง
  - [ ] Weekly plan ไม่แสดงในแอป
  - [ ] Restore purchase ของ product เก่า → ยังทำงาน
- [ ] Promote to Production

### 5.2 App Store

- [ ] Build ใหม่ + Archive + Upload to App Store Connect
- [ ] Submit for Review พร้อม:
  - [ ] Review Notes: "Updated subscription pricing and energy pack options. Removed weekly plan."
  - [ ] IAP Screenshots (สำหรับ energy_50, energy_200, energy_500)
- [ ] ทดสอบใน TestFlight ก่อน submit

---

## 6. Checklist สุดท้าย — ก่อน Go Live

- [ ] ราคาในโค้ดตรงกับ Store ทั้ง 2 platform
- [ ] Admin Panel: daily bonus, challenge rewards ปรับแล้ว
- [ ] Free Trial 7 วัน ตั้งค่าแล้ว (ทั้ง Play + App Store)
- [ ] ทดสอบซื้อจริง (sandbox) ทั้ง Android + iOS
- [ ] Legacy products (energy_100, etc.) ยัง restore ได้
- [ ] Weekly subscription: ไม่แสดงในแอป แต่ backend ยังรองรับ
- [ ] Chat limit ลดเป็น 5/วัน ทำงานถูกต้อง

---

## 7. หลักคิดเบื้องหลัง (อ้างอิง)

### ทำไมตัด Weekly?
- Weekly ฿69–149 = รายได้ต่ำ + churn สูง + หน้าจอรก
- Free Trial 7 วัน ทดแทนได้ดีกว่า (ลองฟรี → ติดใจ → จ่าย)

### ทำไม Monthly ฿349 ($9.99)?
- ฿529+ ในตลาดไทย = คนปิดหน้าไป
- ฿349 = "ลองดู" → ใช้ 1 เดือน → เห็น value → upgrade yearly
- ฿349 ยังแพงพอที่ yearly ฿799 (฿67/เดือน) ดูคุ้ม (save 81%)

### ทำไม Yearly ฿799 ($22.99)?
- CAC ฿600 + กำไร ฿199 ต่อ paying user ที่ซื้อรายปี
- ถูกกว่าคู่แข่งทุกราย
- เท่า Netflix Basic ไทย (฿799) → anchoring ที่คนคุ้น

### ทำไม Energy Pack ลดลง?
- 3 แพ็ก = Goldilocks (ถูก/กลาง/แพง → คนเลือกกลาง)
- Energy น้อยลง → หมดเร็ว → กลับมาซื้อหรือ subscribe
- Pack แพงกว่า subscription ต่อ scan → ดันคนไป yearly

### ทำไมลด Free Tier?
- เดิม: Free user ได้ 3–5E/วัน = ใช้ฟรีสบาย = ไม่มีเหตุผลจ่าย
- ใหม่: 1–2E/วัน = casual user ยังใช้ฟรีได้ (เป็น ambassador) แต่ core user ต้องจ่าย

---

## 8. เอกสารที่เกี่ยวข้อง

| เอกสาร | เนื้อหา |
|--------|---------|
| `VIRAL_FEATURES_SPEC.md` | ฟีเจอร์ใหม่: Summary Card, AR Share, Meal Score |
| `INFLUENCER_MARKETING_PLAN.md` | แผน influencer + content + budget |
| `GOOGLE_ADS_GUIDE.txt` | แผน Google Ads (ใช้หลังเดือนที่ 3+) |

---

*เอกสารนี้เป็น action checklist — ทำตามลำดับ: โค้ด ✅ → Store → Admin → Review → Go Live*
*อัปเดต: มีนาคม 2026*
