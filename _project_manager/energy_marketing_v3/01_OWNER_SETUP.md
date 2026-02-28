# Owner Setup — สิ่งที่ต้องตั้งค่าเอง

> **สำหรับ:** Owner  
> **ต้องทำก่อน:** Phase 2-3 (ก่อน Junior เริ่ม implement IAP/AdMob/Push)

---

## 1. Google Play Console — IAP Products

เข้า Google Play Console → แอป MiRO → Monetize → Products

### 1.1 In-App Products ใหม่ (One-time)

| Product ID | ชื่อ | ราคา | หมายเหตุ |
|------------|------|------|----------|
| `energy_first_purchase_200` | ⚡ Starter Deal — 200 Energy | **$0.99** | โปรครั้งแรก, 1 ครั้ง/บัญชี |

> Product ที่มีอยู่แล้ว (`energy_100`, `energy_550`, `energy_1200`, `energy_2000`) — ไม่ต้องเปลี่ยน

### 1.2 Subscription (Base Plans & Offers)

> **โครงสร้าง Google Play:** ใช้ Product ID เดียว → สร้าง Base Plan แยกตาม period → สร้าง Offer แนบกับ Base Plan  
> **สำคัญ:** Base Plan ID ใช้ขีดกลาง (`-`) เท่านั้น ขีดล่าง (`_`) ใช้ไม่ได้

**Product ID:** `miro_normal_subscription`

#### Base Plans (สร้างแล้ว ✅)

| Base Plan ID | ประเภท | ราคา | สถานะ |
|--------------|--------|------|-------|
| `energy-pass-monthly` | Monthly, auto-renewing | **$4.99/เดือน** | ✅ Active |
| `energy-pass-weekly` | Weekly, auto-renewing | **$1.99/สัปดาห์** | ✅ Active |
| `energy-pass-yearly` | Yearly, auto-renewing | **$39.99/ปี** | ✅ Active |

#### Offers (สร้างแล้ว ✅)

| Offer ID | สำหรับ Base Plan | รายละเอียด | สถานะ |
|----------|-----------------|------------|-------|
| `first-month-free` | `energy-pass-monthly` | 1 เดือนแรกฟรี (Free Trial) สำหรับผู้ใช้ใหม่ | ✅ Active |
| `winback-3usd` | `energy-pass-monthly` | เดือนแรก $2.99 สำหรับ Ex-Subscriber (expired > 7 วัน) | ✅ Active |

---

## 2. Google AdMob — Rewarded Ads

### 2.1 สร้าง AdMob Account
1. ไปที่ https://admob.google.com
2. เพิ่มแอป MiRO (Android + iOS ถ้ามี)
3. ยืนยัน App Store listing

### 2.2 สร้าง Ad Units

| Ad Unit | ประเภท | ตำแหน่ง | หมายเหตุ |
|---------|--------|---------|----------|
| `rewarded_analyze_free` | **Rewarded Video** | หน้า Analyze (เมื่อ Energy = 0) | 30 วิ, ดูจบ → 1 Free AI |

### 2.3 ข้อมูลที่ต้องส่งให้ Junior

| Platform | ข้อมูล |
|----------|-------|
| Android | AdMob App ID: `ca-app-pub-6145254112451474~9703380291` |
| Android | Rewarded Ad Unit ID: `ca-app-pub-6145254112451474/4582480782` |
| iOS (ถ้ามี) | AdMob App ID + Ad Unit ID |

### 2.4 Mediation (Optional, ทำทีหลังได้)
- เพิ่ม mediation networks (Meta Audience Network, Unity Ads) เพื่อเพิ่ม fill rate
- ทำหลัง launch ก็ได้

---

## 3. Firebase Cloud Messaging (Push Notifications)

### 3.1 ตรวจสอบ FCM Setup
- Firebase Console → Project Settings → Cloud Messaging
- ตรวจสอบว่ามี Server Key อยู่แล้ว
- ถ้ายังไม่มี → Enable Cloud Messaging API

### 3.2 ข้อมูลที่ต้องส่งให้ Junior
- Firebase project ID
- ยืนยันว่า `google-services.json` (Android) อัพเดทแล้ว

---

## 4. Apple App Store (ถ้ามี iOS)

### 4.1 In-App Products
สร้าง IAP Products เดียวกันใน App Store Connect:
- `energy_first_purchase_200` — $0.99

### 4.2 Subscriptions
สร้าง Subscription Group + Plans ให้ตรงกับ Google Play:
- Monthly — $4.99/month
- Weekly — $1.99/week
- Yearly — $39.99/year

### 4.3 Promotional Offers
- ตั้งค่า Introductory Offer สำหรับ Free Trial (1 เดือน)
- ตั้งค่า Subscription Offer สำหรับ Winback ($2.99 เดือนแรก)

---

## Checklist

### Google Play — One-time Products
- [x] สร้าง IAP: `energy_first_purchase_200` ($0.99)

### Google Play — Subscription (`miro_normal_subscription`)
- [x] สร้าง Base Plan: `energy-pass-monthly` ($4.99/month)
- [x] สร้าง Base Plan: `energy-pass-weekly` ($1.99/week)
- [x] สร้าง Base Plan: `energy-pass-yearly` ($39.99/year)
- [x] สร้าง Offer: `first-month-free` (Free Trial 1 เดือน)
- [x] สร้าง Offer: `winback-3usd` ($2.99 เดือนแรก)

### AdMob
- [ ] สร้าง AdMob Account + App
- [ ] สร้าง Rewarded Ad Unit: `rewarded_analyze_free`
- [ ] ส่ง AdMob IDs ให้ Junior

### Firebase
- [ ] ตรวจสอบ FCM setup

### iOS (ถ้ามี)
- [ ] สร้าง IAP + Sub + Offers ใน App Store Connect
