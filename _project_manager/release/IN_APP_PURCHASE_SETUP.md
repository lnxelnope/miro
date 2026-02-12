# In-App Purchase Setup Guide

## Product Details

**Product ID:** `miro_cal_pro`  
**Product Type:** Managed product (Non-consumable)  
**Price:** $9.99 USD (หรือ 349 THB)

---

## ขั้นตอนการตั้งค่าใน Google Play Console

### 1. ตั้งราคาแอป

- ไปที่: **App pricing → Monetization**
- เลือก: **Free**
- Contains ads: **No**
- Contains in-app purchases: **Yes**

### 2. สร้าง In-App Product

- ไปที่: **Monetize → Products → In-app products**
- กด: **Create product**

#### กรอกข้อมูล:

```
Product ID:          miro_cal_pro
Product name:        Miro Cal Pro - Unlimited AI
```

#### Description (English):

```
Unlock unlimited AI food analysis

✨ Features:
• Unlimited Gemini AI analysis
• Analyze food photos without limits
• Chat to log food without limits
• No ads

Perfect for serious calorie trackers!
```

#### Description (Thai):

```
ปลดล็อค AI วิเคราะห์อาหารไม่จำกัด

✨ ฟีเจอร์:
• ใช้ Gemini AI ไม่จำกัดครั้ง
• วิเคราะห์รูปอาหารได้ทุกเมื่อ
• แชทบันทึกอาหารไม่จำกัด
• ไม่มีโฆษณา

เหมาะสำหรับคนที่จริงจังกับการนับแคลอรี่!
```

#### ราคา:

| Country | Price |
|---------|-------|
| United States | $9.99 USD |
| Thailand | ฿349 THB |
| *Auto-convert* | *ราคาประเทศอื่นๆ* |

#### Product Type:

- **Managed product** (Non-consumable)
- คือ: ซื้อครั้งเดียว ใช้ได้ตลอด

#### Status:

- **Active**

---

## 3. ทดสอบ IAP

### ทดสอบด้วย License Tester

1. ไปที่: **Settings → License Testing**
2. เพิ่ม Gmail tester: `your.email@gmail.com`
3. เลือก: **License Response: LICENSED**

### ทดสอบจริง

1. Build AAB → Upload → Internal Testing track
2. เพิ่มตัวเองเป็น tester
3. ติดตั้งจาก Play Store (Internal Testing)
4. ทดลองซื้อ Pro (จะไม่มีค่าใช้จ่ายจริง)

---

## 4. Code ที่เกี่ยวข้อง

### UsageLimiter (`lib/core/services/usage_limiter.dart`)

- `canUseAi()` → ตรวจว่ายังใช้ AI ได้อีกไหม
- `recordAiUsage()` → บันทึกการใช้ AI (เรียกหลัง Gemini สำเร็จ)
- `isPro()` → ตรวจว่าเป็น Pro user หรือไม่
- `remainingToday()` → เหลือกี่ครั้งวันนี้

### PurchaseService (`lib/core/services/purchase_service.dart`)

- `initialize()` → เริ่มต้น IAP (เรียกใน main.dart)
- `buyPro()` → ซื้อ Pro
- `restorePurchase()` → restore สำหรับเปลี่ยนเครื่อง

### UI ที่แสดง Upgrade

- `profile_screen.dart` → ปุ่ม "อัปเกรด Pro"
- `health_timeline_tab.dart` → แสดง remaining usage
- `gemini_analysis_sheet.dart` → แสดง upgrade prompt เมื่อใช้ครบ

---

## 5. Testing Checklist

- [ ] Free user ใช้ AI ได้ 3 ครั้ง/วัน
- [ ] ครั้งที่ 4 → แสดง upgrade prompt
- [ ] กดซื้อ Pro → Google Play payment sheet เปิด
- [ ] ซื้อสำเร็จ → แสดง "Pro" badge ใน Profile
- [ ] Pro user ใช้ AI ไม่จำกัด
- [ ] Restore purchase ใช้งานได้ (ลบแอป ติดตั้งใหม่)

---

## 6. Important Notes

⚠️ **Product ID ต้องตรงกัน:**
- Code: `miro_cal_pro`
- Play Console: `miro_cal_pro`
- ถ้าไม่ตรงกัน → IAP จะไม่ทำงาน!

⚠️ **License Testing:**
- ใช้ได้แค่ตอนทดสอบ
- Production → ต้องใช้ credit card จริง

⚠️ **Restore Purchase:**
- ต้องใช้ Gmail เดียวกับที่ซื้อ
- เปลี่ยน Gmail → ต้องซื้อใหม่

---

## 7. Marketing Message

### App Store Description

```
💰 ราคา: ฟรี (มี In-App Purchase)

ใช้ฟรี:
• บันทึกอาหารด้วยมือ — ไม่จำกัด
• AI วิเคราะห์ — 3 ครั้ง/วัน

อัปเกรด Pro เพียง $9.99:
• ใช้ AI ไม่จำกัดครั้ง
• ซื้อครั้งเดียว ใช้ตลอด
• ไม่มีโฆษณา
```

---

## 8. Revenue Model

**Target:**
- 1,000 users → 5% conversion = 50 Pro users
- 50 × $9.99 = $499.50/month
- Google Play commission 15-30% (depends on revenue)

**Tips to increase conversion:**
- แสดง "3/3 ครั้ง" counter ชัดเจน
- ทำ onboarding ให้ user ลอง AI 1 ครั้งก่อน
- แสดง testimonials จาก Pro users
- ทำ limited-time offer ($9.99 → $6.99 first week)

---

## 9. Next Steps

1. สร้าง In-App Product ใน Play Console
2. Upload AAB → Internal Testing
3. ทดสอบ IAP flow
4. Fix bugs (ถ้ามี)
5. Promote to Production
6. Monitor conversion rate

---

**Good luck! 🚀**
