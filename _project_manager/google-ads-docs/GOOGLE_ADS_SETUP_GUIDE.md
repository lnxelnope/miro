# Google Ads Setup Guide — คู่มือรวม

คู่มือนี้แบ่งเป็น 2 ส่วน:
1. **คู่มือสำหรับทีมพัฒนา** (แก้ไขในโปรแกรม) ← ดูที่ `GOOGLE_ADS_DEV_GUIDE.md`
2. **คู่มือสำหรับคุณ** (ไปจัดการเองใน Console) ← ดูที่ `GOOGLE_ADS_CONSOLE_GUIDE.md`

---

## 📚 เอกสารทั้งหมดในโฟลเดอร์นี้

| เอกสาร | สำหรับใคร | คำอธิบาย | อ่านก่อนหรือไม่ |
|--------|-----------|----------|----------------|
| [`GOOGLE_ADS_SETUP_GUIDE.md`](./GOOGLE_ADS_SETUP_GUIDE.md) | ทุกทีม | ภาพรวมระบบและสถานะความพร้อม | ⭐ **อ่านเป็นอันดับ 1** |
| [`GOOGLE_ADS_DEV_GUIDE.md`](./GOOGLE_ADS_DEV_GUIDE.md) | ทีมพัฒนา | คู่มือสำหรับแก้ไขโค้ด - เพิ่ม User Properties, Events | อ่านตามบทบาท |
| [`GOOGLE_ADS_CONSOLE_GUIDE.md`](./GOOGLE_ADS_CONSOLE_GUIDE.md) | คุณ/ทีม Marketing | คู่มือสำหรับตั้งค่าใน Google Ads Console | อ่านตามบทบาท |

---

## 🎯 ภาพรวมระบบ Google Ads Conversion Tracking

```
┌─────────────────────────────────────────────────────────────┐
│                    Miro App (Flutter)                       │
│                                                             │
│  ┌──────────────────┐    ┌──────────────────────────────┐   │
│  │ Purchase Service │ →  │ Analytics Service            │   │
│  └──────────────────┘    │                              │   │
│                          │ - logEnergyPurchase()        │   │
│                          │ - logSubscribe()             │   │
│                          │ - setUserProperty()          │   │
│                          └──────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                                ↓ Firebase Analytics
                    ┌──────────────────────────────────┐
                    │  Google Analytics 4              │
                    │  Events: energy_purchase,        │
                    │  subscribe, user properties      │
                    └──────────────────────────────────┘
                                ↓ Link Account
                    ┌──────────────────────────────────┐
                    │  Google Ads                      │
                    │  Import Conversion Events        │
                    │  Set Bidding Strategy            │
                    └──────────────────────────────────┘
```

---

## 📊 สถานะความพร้อม (Current Status)

| องค์ประกอบ | สถานะ | เอกสารอ้างอิง |
|-----------|-------|-------------|
| ✅ Firebase Analytics SDK | ติดตั้งแล้ว | [`pubspec.yaml`](../../pubspec.yaml#L82-L83) |
| ✅ Google Mobile Ads SDK | ติดตั้งแล้ว | [`pubspec.yaml`](../../pubspec.yaml#L91-L93) |
| ✅ Standard Purchase Events | มีครบ (currency, value, items) | [`analytics_service.dart`](../../lib/core/services/analytics_service.dart#L158-L184) |
| ✅ Server Verification | มีระบบ verify ก่อนเพิ่ม energy | [`purchase_service.dart`](../../lib/core/services/purchase_service.dart#L393-L454) |
| ⚠️ User Properties | มีบ้างแต่ไม่ครบตาม best practice | ดูใน `GOOGLE_ADS_DEV_GUIDE.md` |
| ❌ Google Ads ↔ Firebase Link | ยังไม่ได้เชื่อมต่อ | ต้องทำเองใน Console |
| ❌ Conversion Setup | ยังไม่ได้ import | ต้องทำเองใน Console |

---

## 🚀 ขั้นตอนถัดไป

### สำหรับทีมพัฒนา:
1. อ่านและทำตาม [`GOOGLE_ADS_DEV_GUIDE.md`](./GOOGLE_ADS_DEV_GUIDE.md) เพื่อเพิ่ม User Properties และ Events ที่ขาดหาย
2. Deploy code ใหม่เพื่อให้เริ่มเก็บข้อมูล User Properties ตั้งแต่วันแรก

### สำหรับคุณ (เจ้าของแอป):
1. รอให้ทีม deploy code ใหม่
2. อ่านและทำตาม [`GOOGLE_ADS_CONSOLE_GUIDE.md`](./GOOGLE_ADS_CONSOLE_GUIDE.md) เพื่อตั้งค่าใน Google Ads Console
3. เมื่อมีผู้ซื้อ 15-30 ครั้ง → เปลี่ยน Bidding Strategy เป็น **Maximize Conversion Value** หรือ **Target ROAS**

---

## 📞 ติดต่อสอบถาม

- **ทีมพัฒนา:** ดูเอกสารใน `GOOGLE_ADS_DEV_GUIDE.md` หรือถาม Lead Developer
- **เจ้าของแอป:** ดูเอกสารใน `GOOGLE_ADS_CONSOLE_GUIDE.md` หรือติดต่อทีม Marketing
