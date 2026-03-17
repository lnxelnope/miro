# คู่มือตั้งค่า In-App Purchase สำหรับ App Store Connect

## ⚠️ ข้อกำหนดสำคัญของ Apple

| Field | ข้อจำกัด |
|-------|---------|
| Display Name | 2–30 ตัวอักษร |
| Description | **ไม่เกิน 45 ตัวอักษร** (สั้นมาก!) |
| Review Notes | ไม่เกิน 4,000 ตัวอักษร |
| Screenshot | ภาพหน้าจอจากแอปจริงที่แสดง item (ใช้สำหรับ review เท่านั้น ไม่แสดงบน Store) |

### สิ่งที่ทำให้ถูก Reject
- ❌ เขียน description ซ้ำกับ display name
- ❌ ใช้คำ misleading เช่น "200%", "lifetime", "unlimited"
- ❌ ไม่แนบ screenshot
- ❌ Description ไม่ได้อธิบายว่าผู้ใช้จะได้อะไร

---

## ขั้นตอนที่ 1: เตรียม Screenshot (ทำก่อนเข้า ASC)

ถ่าย screenshot **หน้า Energy Store** จากแอปจริง (Simulator ก็ได้):

1. เปิดแอป Miro
2. กดที่ **Energy Badge** (ตัวเลข energy) ที่ AppBar → เปิดหน้า Energy Store
3. ถ่าย screenshot ที่เห็น **package cards ทั้ง 4 แพ็ค** (Starter Kick, Value Pack, Power User, Ultimate Saver)
4. สำหรับ First Purchase offer → ถ่าย screenshot เมื่อมี offer banner แสดง

> ใช้ screenshot เดียวกันสำหรับทุก product ก็ได้ (Apple อนุญาต)

---

## ขั้นตอนที่ 2: กรอกข้อมูล IAP ใน App Store Connect

ไปที่ **App Store Connect → แอปของคุณ → In-App Purchases** → กดที่แต่ละ product

### Product 1: `energy_100` — Starter Kick

| Field | ค่า |
|-------|-----|
| **Reference Name** | Starter Kick — 100 Energy |
| **Product ID** | `energy_100` (แก้ไม่ได้) |
| **Type** | Consumable |
| **Price** | $0.99 (Tier 1) |

**App Store Localization — English (U.S.):**

| Field | ค่าที่ต้องกรอก |
|-------|---------------|
| Display Name | `Starter Kick — 100 Energy` (26 ตัวอักษร ✅) |
| Description | `Get 100 energy to power AI features.` (38 ตัวอักษร ✅) |

**App Store Localization — Thai:**

| Field | ค่าที่ต้องกรอก |
|-------|---------------|
| Display Name | `Starter Kick — 100 พลังงาน` |
| Description | `รับพลังงาน 100 หน่วย สำหรับใช้ฟีเจอร์ AI` |

**App Store Localization — Vietnamese:**

| Field | ค่าที่ต้องกรอก |
|-------|---------------|
| Display Name | `Starter Kick — 100 Năng lượng` |
| Description | `Nhận 100 năng lượng cho tính năng AI.` |

**Review Information:**
- Screenshot: อัปโหลดภาพหน้า Energy Store
- Review Notes: (ดูด้านล่าง)

---

### Product 2: `energy_550` — Value Pack

**App Store Localization — English (U.S.):**

| Field | ค่าที่ต้องกรอก |
|-------|---------------|
| Display Name | `Value Pack — 550 Energy` (24 ตัวอักษร ✅) |
| Description | `550 energy with 10% bonus for AI use.` (39 ตัวอักษร ✅) |

**App Store Localization — Thai:**

| Field | ค่าที่ต้องกรอก |
|-------|---------------|
| Display Name | `Value Pack — 550 พลังงาน` |
| Description | `พลังงาน 550 หน่วย พร้อมโบนัส 10%` |

**App Store Localization — Vietnamese:**

| Field | ค่าที่ต้องกรอก |
|-------|---------------|
| Display Name | `Value Pack — 550 Năng lượng` |
| Description | `550 năng lượng kèm thưởng 10% cho AI.` |

---

### Product 3: `energy_1200` — Power User

**App Store Localization — English (U.S.):**

| Field | ค่าที่ต้องกรอก |
|-------|---------------|
| Display Name | `Power User — 1,200 Energy` (26 ตัวอักษร ✅) |
| Description | `1,200 energy for heavy AI usage.` (33 ตัวอักษร ✅) |

**App Store Localization — Thai:**

| Field | ค่าที่ต้องกรอก |
|-------|---------------|
| Display Name | `Power User — 1,200 พลังงาน` |
| Description | `พลังงาน 1,200 หน่วย สำหรับใช้ AI เต็มที่` |

**App Store Localization — Vietnamese:**

| Field | ค่าที่ต้องกรอก |
|-------|---------------|
| Display Name | `Power User — 1.200 Năng lượng` |
| Description | `1.200 năng lượng cho người dùng AI nhiều.` |

---

### Product 4: `energy_2000` — Ultimate Saver

**App Store Localization — English (U.S.):**

| Field | ค่าที่ต้องกรอก |
|-------|---------------|
| Display Name | `Ultimate Saver — 2,000 Energy` (30 ตัวอักษร ✅) |
| Description | `Best value! 2,000 energy for AI.` (33 ตัวอักษร ✅) |

**App Store Localization — Thai:**

| Field | ค่าที่ต้องกรอก |
|-------|---------------|
| Display Name | `Ultimate Saver — 2,000 พลังงาน` |
| Description | `คุ้มที่สุด! พลังงาน 2,000 สำหรับ AI` |

**App Store Localization — Vietnamese:**

| Field | ค่าที่ต้องกรอก |
|-------|---------------|
| Display Name | `Ultimate Saver — 2.000 Năng lượng` |
| Description | `Giá tốt nhất! 2.000 năng lượng cho AI.` |

---

### Product 5: `energy_first_purchase_200` — First Purchase

**App Store Localization — English (U.S.):**

| Field | ค่าที่ต้องกรอก |
|-------|---------------|
| Display Name | `First Purchase — 200 Energy` (28 ตัวอักษร ✅) |
| Description | `Welcome deal! 200 energy for new users.` (40 ตัวอักษร ✅) |

**App Store Localization — Thai:**

| Field | ค่าที่ต้องกรอก |
|-------|---------------|
| Display Name | `ซื้อครั้งแรก — 200 พลังงาน` |
| Description | `ดีลต้อนรับ! พลังงาน 200 สำหรับผู้ใช้ใหม่` |

**App Store Localization — Vietnamese:**

| Field | ค่าที่ต้องกรอก |
|-------|---------------|
| Display Name | `Mua lần đầu — 200 Năng lượng` |
| Description | `Ưu đãi chào mừng! 200 năng lượng.` |

---

## ขั้นตอนที่ 2.5: กรอก Subscriptions (Auto-Renewable) — 3 ตัว

นอกจาก Consumable IAP แล้ว ยังมี **Subscriptions** อีก 3 ตัวที่ต้องกรอกให้ครบเหมือนกัน

> **หมายเหตุ:** Reference Name ใน ASC ตอนนี้มีรูปแบบไม่สวย (เช่น "monthlyEnergy Pass$4.99") — แก้ Reference Name ได้เลย ไม่ต้อง review ใหม่

---

### Subscription 1: `miro_energy_pass_weekly` — Energy Pass Weekly

| Field | ค่า |
|-------|-----|
| **Reference Name** | Energy Pass Weekly |
| **Product ID** | `miro_energy_pass_weekly` (แก้ไม่ได้) |
| **Duration** | 1 week |
| **Price** | $1.99 |

**App Store Localization — English (U.S.):**

| Field | ค่าที่ต้องกรอก |
|-------|---------------|
| Display Name | `Energy Pass Weekly` (18 ตัวอักษร ✅) |
| Description | `Unlimited AI analysis for 1 week.` (34 ตัวอักษร ✅) |

**App Store Localization — Thai:**

| Field | ค่าที่ต้องกรอก |
|-------|---------------|
| Display Name | `Energy Pass รายสัปดาห์` |
| Description | `วิเคราะห์ AI ไม่จำกัด 1 สัปดาห์` |

**App Store Localization — Vietnamese:**

| Field | ค่าที่ต้องกรอก |
|-------|---------------|
| Display Name | `Energy Pass Hàng tuần` |
| Description | `Phân tích AI không giới hạn 1 tuần.` |

---

### Subscription 2: `miro_energy_pass_monthly` — Energy Pass Monthly

| Field | ค่า |
|-------|-----|
| **Reference Name** | Energy Pass Monthly |
| **Product ID** | `miro_energy_pass_monthly` (แก้ไม่ได้) |
| **Duration** | 1 month |
| **Price** | $4.99 |

**App Store Localization — English (U.S.):**

| Field | ค่าที่ต้องกรอก |
|-------|---------------|
| Display Name | `Energy Pass Monthly` (19 ตัวอักษร ✅) |
| Description | `Unlimited AI analysis for 1 month.` (35 ตัวอักษร ✅) |

**App Store Localization — Thai:**

| Field | ค่าที่ต้องกรอก |
|-------|---------------|
| Display Name | `Energy Pass รายเดือน` |
| Description | `วิเคราะห์ AI ไม่จำกัด 1 เดือน` |

**App Store Localization — Vietnamese:**

| Field | ค่าที่ต้องกรอก |
|-------|---------------|
| Display Name | `Energy Pass Hàng tháng` |
| Description | `Phân tích AI không giới hạn 1 tháng.` |

---

### Subscription 3: `miro_energy_pass_yearly` — Energy Pass Yearly

| Field | ค่า |
|-------|-----|
| **Reference Name** | Energy Pass Yearly |
| **Product ID** | `miro_energy_pass_yearly` (แก้ไม่ได้) |
| **Duration** | 1 year |
| **Price** | $39.99 |

**App Store Localization — English (U.S.):**

| Field | ค่าที่ต้องกรอก |
|-------|---------------|
| Display Name | `Energy Pass Yearly` (18 ตัวอักษร ✅) |
| Description | `Unlimited AI analysis. Save 62%.` (33 ตัวอักษร ✅) |

**App Store Localization — Thai:**

| Field | ค่าที่ต้องกรอก |
|-------|---------------|
| Display Name | `Energy Pass รายปี` |
| Description | `วิเคราะห์ AI ไม่จำกัด ประหยัด 62%` |

**App Store Localization — Vietnamese:**

| Field | ค่าที่ต้องกรอก |
|-------|---------------|
| Display Name | `Energy Pass Hàng năm` |
| Description | `Phân tích AI không giới hạn. Tiết kiệm 62%.` |

---

### Subscription Review Information

สำหรับ Subscription ให้ใส่ **Review Notes + Screenshot** เหมือน IAP:

- **Screenshot**: ถ่ายหน้า **Subscription Screen** (หน้าที่แสดง Weekly / Monthly / Yearly plans) จาก Simulator full-screen
- **Review Notes**: ใช้ template เดียวกับ IAP แต่เพิ่มวิธีเข้าหน้า Subscription:

```
คร
```

---

## ขั้นตอนที่ 3: เขียน Review Notes (ใช้ร่วมกันทุก product)

คัดลอก review notes นี้ใส่ในช่อง **Review Notes** ของแต่ละ product:

```
HOW TO FIND IN-APP PURCHASES:

1. Open the Miro app
2. On the home screen, tap the Energy badge (number with lightning bolt icon) in the top-right of the navigation bar
3. This opens the Energy Store screen
4. All energy packages are displayed as cards:
   - First Purchase — 200 Energy ($0.99) *see note below
   - Starter Kick — 100 Energy ($0.99)
   - Value Pack — 550 Energy ($4.99)
   - Power User — 1,200 Energy ($7.99)
   - Ultimate Saver — 2,000 Energy ($9.99)
5. Tap any package card to initiate the purchase

WHAT IS ENERGY:
Energy is a consumable virtual currency used to power AI features in the app, such as:
- AI food analysis from photos
- AI nutrition estimation
- AI chat assistant for diet advice

Each AI action consumes 1 energy unit. Users can purchase energy packages to continue using AI features.

ABOUT "First Purchase — 200 Energy":
This is a limited-time welcome offer that appears as a special banner card at the top of the Energy Store. It is only shown to users who have not made any purchase before. To test this IAP, please use a fresh Sandbox Apple Account that has no prior purchase history. The offer banner will appear at the top of the Energy Store screen above the regular packages.

No login is required to test purchases.
```

---

## ขั้นตอนที่ 4: Checklist ก่อน Submit

ทำเครื่องหมาย ✅ ทุกข้อก่อนกด Submit:

- [ ] **Paid Apps Agreement** — Active ✅ (ตรวจแล้วจากภาพ)
- [ ] **ทุก product มี Price** — ตั้งราคาครบทุกตัว
- [ ] **ทุก product มี English localization** — Display Name + Description
- [ ] **ทุก product มี Thai localization** — Display Name + Description
- [ ] **ทุก product มี Vietnamese localization** — Display Name + Description
- [ ] **ทุก product มี Screenshot** — อัปโหลดภาพ full-screen จาก Simulator (ไม่ใช่ 1024×1024!)
- [ ] **ทุก product มี Review Notes** — ใส่ขั้นตอนการหา IAP
- [ ] **Subscriptions ทั้ง 3 ตัว** — กรอก localization + screenshot + review notes ครบ
- [ ] **Status ทุกตัวเป็น "Ready to Submit"** — ไม่ใช่ "Developer Action Needed"

---

## ขั้นตอนที่ 5: แนบ IAP กับ App Version

**สำคัญมาก!** — IAP ต้องถูกเลือกในหน้า App Version ก่อน submit:

1. ไปที่ **App Store Connect → แอปของคุณ → App Store tab**
2. เลือก version ที่จะ submit (เช่น 1.0.1)
3. เลื่อนลงไปหา section **"In-App Purchases and Subscriptions"**
4. กด **"+"** แล้วเลือก IAP products ทั้ง 5 ตัว + Subscriptions ทั้ง 3 ตัว
5. ตรวจให้แน่ใจว่าทั้ง 8 products ปรากฏในรายการ

> ⚠️ ถ้าไม่ทำขั้นตอนนี้ Apple จะหา IAP ไม่เจอ!

---

## ⚠️ ก่อน Reply / Resubmit — ต้องมี Build ใหม่

Apple บอก **"Version reviewed: 1.0"** = เค้ายัง review บน build เก่า (1.0) อยู่

- **Guideline 4 (Permission):** การแก้อยู่ที่ **โค้ด** (InfoPlist.strings) → ต้อง **อัปโหลด build ใหม่** (เช่น 1.2.2 build 51) ถึงจะเห็น
- **Guideline 2.1(b) (IAP):** ต้องแนบ IAP/Subscriptions กับ **version ของ build ใหม่** แล้ว **Reply** บอกขั้นตอนหา IAP

ถ้าส่งแค่ Reply โดย**ไม่ส่ง build ใหม่** → Apple จะยังเปิดแอป 1.0 อยู่ → permission ยังเป็นภาษาเดิม และอาจหา IAP ไม่เจอเหมือนเดิม

**ลำดับที่ถูก:**  
1) Build ใหม่ (flutter build ipa)  
2) อัปโหลด build ใหม่ใน App Store Connect  
3) เลือก build ใหม่ในหน้า Version  
4) แนบ IAP + Subscriptions กับ version นั้น  
5) **แล้วค่อย** Reply ข้อความด้านล่าง + กด Submit for Review  

---

## ขั้นตอนที่ 6: Reply กลับ Apple

หลังจากอัปโหลด **build ใหม่** และแนบ IAP ครบแล้ว ให้ reply ใน **App Store Connect → Resolution Center** (หรือในข้อความของ submission นั้น):

```
Dear App Review Team,

Thank you for your feedback. We have addressed both issues and have uploaded a new build for your review.

1. **Guideline 4 (Permission Language):** We have added localized permission strings (InfoPlist.strings) for English, Thai, and Vietnamese. The permission dialogs now display in the same language as the app. This fix is included in the new build we have submitted.

2. **Guideline 2.1(b) (In-App Purchases):** All IAP and subscription metadata are complete and attached to this version. Steps to locate In-App Purchases (including Ultimate Saver — 2,000 Energy and Value Pack — 550 Energy) on iPad:

   • Open the Miro app.
   • On the home screen, tap the **Energy badge** (the number with a lightning bolt icon) in the **top-right area of the navigation bar**.
   • The **Energy Store** screen opens. Scroll if needed. You will see these packages as cards:
     – Starter Kick — 100 Energy ($0.99)
     – Value Pack — 550 Energy ($4.99)
     – Power User — 1,200 Energy ($7.99)
     – Ultimate Saver — 2,000 Energy ($9.99)
   • Tap any of these cards to initiate the purchase. (A "First Purchase — 200 Energy" offer may also appear at the top for first-time Sandbox users.)
   • For subscriptions: On the same Energy Store screen, tap the **"Energy Pass"** banner/card at the top to open the Subscription screen (Weekly / Monthly / Yearly plans).

   IAP and subscriptions are not restricted by storefront or device; they are available in the app as described. We have accepted the Paid Apps Agreement. Please use your Sandbox environment to test.

All IAP products and subscriptions are attached to this app version submission.

Best regards
```

---

## FAQ

### Q: ต้องใส่ localization กี่ภาษา?
ต้องใส่อย่างน้อย **English + Thai + Vietnamese** เพราะแอปเปิดตัวในตลาดไทยและเวียดนาม ภาษาอื่นที่แอปรองรับ (ja, zh, ko, etc.) สามารถเพิ่มทีหลังได้ แต่ 3 ภาษานี้ต้องมีก่อน submit

### Q: ถ้ายังเจอ "Developer Action Needed"?
1. ตรวจว่ากรอก metadata ครบทุกช่อง
2. ลองลบ localization ที่ rejected แล้วสร้างใหม่
3. รอ 1 ชม. ให้ metadata propagate ไป sandbox

### Q: Product ID เปลี่ยนได้ไหม?
ไม่ได้ และลบแล้วก็ใช้ซ้ำไม่ได้ ต้องสร้าง ID ใหม่เท่านั้น (ซึ่งจะต้องแก้ code ด้วย)
