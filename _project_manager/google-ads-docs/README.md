# 📚 Google Ads Documentation — สารบัญเอกสาร

โฟลเดอร์นี้รวบรวมเอกสารทั้งหมดสำหรับ **Google Ads Conversion Tracking** ในโปรเจกต์ Miro

---

## 🎯 ใช้เอกสารไหนเมื่อไหร่?

| หากคุณคือ... | อ่านไฟล์นี้ | เพื่ออะไร |
|-------------|-------------|----------|
| **ทุกคนในทีม (เริ่มจากที่นี่)** | [`GOOGLE_ADS_SETUP_GUIDE.md`](./GOOGLE_ADS_SETUP_GUIDE.md) | ภาพรวมระบบและสถานะความพร้อม |
| **นักพัฒนา** | [`GOOGLE_ADS_DEV_GUIDE.md`](./GOOGLE_ADS_DEV_GUIDE.md) | แก้ไขโค้ดเพิ่ม User Properties และ Events |
| **เจ้าของแอป/ทีม Marketing** | [`GOOGLE_ADS_CONSOLE_GUIDE.md`](./GOOGLE_ADS_CONSOLE_GUIDE.md) | ตั้งค่าใน Google Ads Console |

---

## 📋 รายละเอียดแต่ละเอกสาร

### 1️⃣ [`GOOGLE_ADS_SETUP_GUIDE.md`](./GOOGLE_ADS_SETUP_GUIDE.md)
**สำหรับ:** ทุกทีม (เริ่มอ่านจากที่นี่)

**เนื้อหา:**
- ภาพรวมระบบ Google Ads Conversion Tracking
- สถานะความพร้อมของแต่ละองค์ประกอบ (✅/❌)
- ขั้นตอนถัดไปสำหรับแต่ละทีม
- เชื่อมโยงไปยังเอกสารย่อยอื่นๆ

---

### 2️⃣ [`GOOGLE_ADS_DEV_GUIDE.md`](./GOOGLE_ADS_DEV_GUIDE.md)
**สำหรับ:** ทีมพัฒนา (นักเขียนโค้ด)

**เนื้อหา:**
- **User Properties ที่ต้องเพิ่ม:** `user_type`, `purchase_frequency`, `first_purchase_date`, `last_purchase_date`
- **Events ที่ต้องเพิ่ม:** `repeat_purchase`, `failed_payment`, `onboarding_subscribe`
- **Code Examples:** วิธีเพิ่ม method ใน `analytics_service.dart`
- **Testing Procedures:** วิธีทดสอบ User Properties และ Events
- **ข้อควรระวัง:** Hardcode Prices, Currency, Consent

---

### 3️⃣ [`GOOGLE_ADS_CONSOLE_GUIDE.md`](./GOOGLE_ADS_CONSOLE_GUIDE.md)
**สำหรับ:** เจ้าของแอป/ทีม Marketing (ตั้งค่าใน Console)

**เนื้อหา:**
- **ขั้นตอนที่ 1:** เชื่อมต่อ Google Ads ↔ Firebase Analytics
- **ขั้นตอนที่ 2:** Import Conversion Events (energy_purchase, subscribe)
- **ขั้นตอนที่ 3:** สร้าง Custom Audiences (High Value Users, Repeat Buyers, Churned Users)
- **ขั้นตอนที่ 4:** ตั้งค่า Bidding Strategy (Maximize Clicks → Maximize Conversions → Target ROAS)
- **ขั้นตอนที่ 5:** สร้างแคมเปญทดสอบ (App Install, Retargeting, Re-engagement)
- **การวัดผล:** KPIs ที่ต้องติดตาม (ROAS, CPA, CTR, Conversion Rate)

---

## 🔄 ลำดับการทำงานที่แนะนำ

### สำหรับทีมพัฒนา:
1. อ่าน `GOOGLE_ADS_SETUP_GUIDE.md` → เข้าใจภาพรวม
2. อ่าน `GOOGLE_ADS_DEV_GUIDE.md` → ทำตามขั้นตอนแก้ไขโค้ด
3. ทดสอบบน Staging environment
4. Deploy code ใหม่

### สำหรับเจ้าของแอป/ทีม Marketing:
1. อ่าน `GOOGLE_ADS_SETUP_GUIDE.md` → เข้าใจภาพรวม
2. รอให้ทีม deploy code ใหม่ (เพื่อให้เริ่มเก็บข้อมูล User Properties)
3. อ่าน `GOOGLE_ADS_CONSOLE_GUIDE.md` → ทำตามขั้นตอนตั้งค่าใน Console
4. เริ่มแคมเปญทดสอบเมื่อมีผู้ซื้อ 15-30 ครั้ง

---

## 📞 ติดต่อสอบถาม

| ทีม | ช่องทางติดต่อ |
|-----|--------------|
| **ทีมพัฒนา** | ดูเอกสารในโฟลเดอร์นี้ หรือถาม Lead Developer |
| **เจ้าของแอป/Marketing** | ดูเอกสารในโฟลเดอร์นี้ หรือติดต่อทีม Marketing |

---

## 🔄 Version History

| Version | วันที่ | ผู้แก้ไข | การเปลี่ยนแปลง |
|---------|-------|---------|---------------|
| 1.0 | 2026-03-11 | AI Assistant | สร้างสารบัญฉบับแรก |
