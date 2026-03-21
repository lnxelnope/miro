# Google Ads Console Guide — คู่มือสำหรับเจ้าของแอป/ทีม Marketing

คู่มือนี้สำหรับ **คุณ (เจ้าของแอป)** หรือ **ทีม Marketing** ที่ต้องตั้งค่าใน Google Ads Console เพื่อเชื่อมต่อกับการทำ Conversion Tracking

---

## 📚 สารบัญเอกสารย่อย

| เอกสาร | สำหรับใคร | คำอธิบาย |
|--------|-----------|----------|
| [`GOOGLE_ADS_SETUP_GUIDE.md`](./GOOGLE_ADS_SETUP_GUIDE.md) | ทุกทีม | ภาพรวมระบบและสถานะความพร้อม |
| [`GOOGLE_ADS_DEV_GUIDE.md`](./GOOGLE_ADS_DEV_GUIDE.md) | ทีมพัฒนา | คู่มือสำหรับแก้ไขโค้ด - เพิ่ม User Properties, Events |
| **GOOGLE_ADS_CONSOLE_GUIDE.md** | **คุณ/ทีม Marketing** | **คู่มือนี้ — ตั้งค่าใน Google Ads Console** |

---

## 🎯 วัตถุประสงค์ของเอกสารนี้

1. เชื่อมต่อ Google Ads ↔ Firebase Analytics
2. Import Conversion Events จาก Firebase
3. สร้าง Custom Audiences จาก User Properties
4. ตั้งค่า Bidding Strategy ให้เหมาะสม
5. วัดผลและปรับปรุงแคมเปญ (ROAS, CPA)

---

## 🚀 ขั้นตอนทีละขั้นตอน

### ขั้นตอนที่ 1: เชื่อมต่อ Google Ads ↔ Firebase (ทำครั้งเดียว)

#### 1.1 เปิด Google Analytics Admin
```
Firebase Console → เลือกโปรเจกต์ → Go to Google Analytics → Admin
```

#### 1.2 Link กับ Google Ads
```
Product Links → Google Ads Links → Link Account
```

**สิ่งที่จะเกิดขึ้น:**
- ระบบจะขอ Login เข้า Google Ads Account
- ต้องมีบทบาท **Admin** ในทั้ง Firebase และ Google Ads
- ใช้ Google Account เดียวกับที่จัดการ Google Ads

#### 1.3 ตรวจสอบการ Link สำเร็จ
```
After linking → Google Ads Links → Click on your account
→ Status: "Linked"
```

---

### ขั้นตอนที่ 2: Import Conversion Events (ทำครั้งเดียว)

#### 2.1 เปิด Conversion Tracking ใน Google Ads
```
Google Ads → Tools & Settings → Measurement → Conversions → New conversion action
```

#### 2.2 เลือก Source = Web Analytics
```
Select import source → Google Analytics (GA4)
```

#### 2.3 เลือก Events ที่ต้องการ Import
**Events ควร Import:**

| Event Name | ใน Firebase | แปลความหมาย | ค่าที่แนะนำ |
|------------|-------------|--------------|-------------|
| `energy_purchase` | ✅ มีอยู่แล้ว | ผู้ซื้อ Energy Pack | **Primary Conversion** ⭐⭐⭐ |
| `subscribe` | ✅ มีอยู่แล้ว | ผู้สมัครสมาชิก | **Secondary Conversion** ⭐⭐ |

#### 2.4 ตั้งค่า Conversion Values

**สำหรับ `energy_purchase`:**
```
Use different values for each conversion → Yes (ใช้ตามจำนวนเงินจริง)
```

**สำหรับ `subscribe`:**
```
Use the same value for each conversion → No (ใช้ตาม Plan ที่เลือก)
- weekly: 35 THB
- monthly: 150 THB
- yearly: 890 THB
```

---

### ขั้นตอนที่ 3: สร้าง Custom Audiences (ทำก่อนเริ่มแคมเปญ)

#### 3.1 เปิด Custom Audiences ใน Google Ads
```
Google Ads → Tools & Settings → Audience Manager → Segments → New segment
```

#### 3.2 สร้าง Audiences จาก User Properties

**Audience #1: High Value Users (สำหรับ Lookalike)**
```
Condition: user_type = 'high_value'
Purchase in last 90 days: Yes
Minimum users required: 1,000
```

**Audience #2: Repeat Buyers (สำหรับ Retargeting)**
```
Condition: purchase_frequency = 'recurring'
Purchase in last 30 days: Yes
Minimum users required: 500
```

**Audience #3: Churned Users (สำหรับ Re-engagement)**
```
Condition: is_subscriber = 'false' AND total_energy_spent > 100
Last purchase date > 60 days ago
Minimum users required: 2,000
```

#### 3.3 สร้าง Lookalike Audiences
```
After High Value Users audience reaches 1,000+ users → Create Similar Audience
Target countries: Thailand (95%), Others (5%)
```

---

### ขั้นตอนที่ 4: ตั้งค่า Bidding Strategy

#### 4.1 ช่วงเริ่มต้น (0-15 conversions/month)
```
Bidding Strategy: Maximize Clicks
Daily Budget: 300-500 THB
Target CPA: ไม่ตั้ง (ยังไม่มีข้อมูล)
```

**เหตุผล:** ยังไม่มีความรู้เรื่อง Conversion Rate ต้องสะสมข้อมูลก่อน

#### 4.2 ช่วงเติบโต (15-30 conversions/month)
```
Switch to → Maximize Conversions
Target CPA: ตั้งตามเป้าหมาย (เช่น 200 THB/conversion)
```

#### 4.3 ช่วง optimize (30+ conversions/month)
```
Switch to → Target ROAS (Return on Ad Spend)
Target ROAS: 400% (ROAS = Revenue / Ad Spend, 400% = ได้เงินกลับ 4 เท่า)
```

**สูตรคำนวณ Target ROAS:**
```
Target ROAS = (Average Order Value × Conversion Rate × Profit Margin) / CPA_target
ตัวอย่าง: (150 THB × 3%) × 60% / 200 THB = 2.7 → ตั้ง 270%
```

---

### ขั้นตอนที่ 5: สร้างแคมเปญทดสอบ

#### 5.1 แคมเปญ #1: App Install (สำหรับหาผู้ใช้ใหม่)
```
Objective: App installs
Campaign type: UA (Universal App Campaigns)
Target: Thailand
Budget: 300 THB/day
Ad groups: 
- Group 1: Focus on "Free trial" (ดึงดูดผู้ที่ไม่เคยใช้)
- Group 2: Focus on "Premium features" (สำหรับผู้ใช้ที่สนใจ)
```

#### 5.2 แคมเปญ #2: Retargeting (สำหรับผู้ใช้เก่า)
```
Objective: Conversions
Campaign type: Search or Display
Target audience: Custom Audience → Repeat Buyers
Budget: 200 THB/day
Ad copy: "กลับมาใช้ Miro อีกครั้ง! ลดพิเศษ 20% สำหรับสมาชิกเก่า"
```

#### 5.3 แคมเปญ #3: Re-engagement (สำหรับ Churned Users)
```
Objective: Conversions
Campaign type: Display
Target audience: Custom Audience → Churned Users
Budget: 150 THB/day
Ad copy: "เราคิดถึงคุณ! รับ Energy Pack ฟรี 100 หน่วย กลับมาใช้งานอีกครั้ง"
```

---

## 📊 การวัดผลและปรับปรุง

### KPIs ที่ต้องติดตาม

| Metric | สูตร | เป้าหมายเริ่มต้น | เป้าหมายระยะยาว |
|--------|------|-----------------|----------------|
| **ROAS** | Revenue / Ad Spend | 200% (ได้กลับมา 2 เท่า) | 400%+ |
| **CPA** | Total Ad Spend / Conversions | < 300 THB/conversion | < 200 THB/conversion |
| **CTR** | Clicks / Impressions | > 1.5% | > 3% |
| **Conversion Rate** | Conversions / Clicks | > 2% | > 4% |

### ตารางติดตามผลรายสัปดาห์

```
Week # | Ad Spend | Conversions | ROAS | CPA | Notes
-------|----------|-------------|------|-----|-------
   1   | 2,100    | 5           | 0%   | N/A | ยังไม่มี conversion
   2   | 2,100    | 8           | 100% | 263 THB | เริ่มมี purchase
   3   | 2,100    | 12          | 150% | 175 THB | ปรับ Ad Groups
   4   | 2,100    | 18          | 250% | 117 THB | เปิด Target ROAS
```

---

## 🚨 ข้อควรระวัง

### 1. **อย่าตั้ง Target ROAS ก่อนมีข้อมูลเพียงพอ**
- ต้องมีอย่างน้อย **30 conversions ใน 30 วันแรก** ก่อนเปลี่ยนไปใช้ Target ROAS
- ถ้าตั้งเร็วเกินไป → ระบบจะไม่สามารถเรียนรู้ และประสิทธิภาพจะแย่ลง

### 2. **ตรวจสอบ Conversion Count อย่างสม่ำเสมอ**
```
Google Ads → Tools & Settings → Measurement → Conversions
→ ดูว่าจำนวน conversion ที่ record ตรงกับใน Firebase หรือไม่
```

### 3. **ระวัง Data Discrepancy**
- Google Ads อาจนับ conversion น้อยกว่าจริง 10-20% (เนื่องจาก Ad Blockers, Privacy settings)
- อย่ากังวลมากถ้าตัวเลขไม่ตรงกัน 100%

### 4. **Respect User Privacy**
- ต้องมี **Privacy Policy** ที่ชัดเจน
- ต้องขอ Consent ก่อนเก็บข้อมูล (GDPR/PDPA compliance)
- ห้ามส่งข้อมูลส่วนบุคคล (PII) เช่น ชื่อ, เบอร์โทร, อีเมล

---

## 📞 ติดต่อสอบถาม

- **ทีมพัฒนา:** ดูใน `GOOGLE_ADS_DEV_GUIDE.md` หรือถาม Lead Developer
- **Google Ads Support:** https://support.google.com/google-ads

---

## 🔄 Version History

| Version | วันที่ | ผู้แก้ไข | การเปลี่ยนแปลง |
|---------|-------|---------|---------------|
| 1.0 | 2026-03-11 | AI Assistant | สร้างคู่มือฉบับแรก |
