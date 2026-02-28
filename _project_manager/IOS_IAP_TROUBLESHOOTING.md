# iOS IAP & Subscription — Troubleshooting

> แอป MiRO บน TestFlight — IAP และ Subscription ยังไม่ทำงาน

---

## เช็คลิสต์ก่อนทดสอบ

### 1. App Store Connect

| # | ตรวจสอบ | วิธีเช็ค |
|---|---------|----------|
| 1 | **Paid Applications Agreement** ลงนามแล้ว | App Store Connect → Agreements, Tax, and Banking → ต้องมีสถานะ "Active" |
| 2 | **Bank & Tax** กรอกครบ | Agreements → ต้องมี Bank Account และ Tax Forms |
| 3 | **Sandbox Tester** เพิ่มแล้ว | Users and Access → Sandbox → Testers → lnxelnope2@gmail.com |
| 4 | **Products "Ready to Submit"** | Monetization → In-App Purchases → ทุก product ต้อง Ready to Submit |
| 5 | **Subscription Group** | Subscriptions → miro_normal_subscription → 3 plans (weekly, monthly, yearly) |
| 6 | **Bundle ID ตรงกัน** | App ใช้ `com.tanabun.miroHybrid` — ต้องตรงกับ App Store Connect |

### 2. Firebase Backend

| # | ตรวจสอบ | วิธีเช็ค |
|---|---------|----------|
| 1 | **APPLE_SHARED_SECRET** ตั้งค่าแล้ว | `firebase functions:secrets:access APPLE_SHARED_SECRET` |
| 2 | Secret = App-Specific Shared Secret | App Store Connect → My Apps → App Information → App-Specific Shared Secret |
| 3 | Deploy functions แล้ว | `cd functions && npm run build && firebase deploy --only functions` |

### 3. บน iPhone (ก่อนทดสอบ)

| # | ต้องทำ | วิธี |
|---|--------|------|
| 1 | **Sign Out จาก App Store** | Settings → [ชื่อคุณ] → Media & Purchases → Sign Out |
| 2 | หรือ **Sign Out แค่ Purchases** | Settings → App Store → ด้านล่าง Sign Out |
| 3 | ติดตั้งแอปจาก **TestFlight** | ต้องใช้ build จาก TestFlight (ไม่ใช่ run จาก Xcode โดยตรง) |
| 4 | ตอนซื้อจะถาม **Sandbox login** | ใช้ lnxelnope2@gmail.com (Sandbox account) |

---

## อาการและวิธีแก้

### อาการ 1: "In-App Purchases not available" / Products ไม่โหลด

**สาเหตุที่เป็นไปได้:**
- Paid Applications Agreement ยังไม่ลงนาม
- Products ยังไม่ "Cleared for Sale"
- ใช้ build จาก Xcode โดยตรง แทน TestFlight
- รอ propagation (สร้าง product ใหม่ อาจใช้เวลา 2–24 ชม.)

**วิธีแก้:**
1. เช็ค Agreements ใน App Store Connect
2. Monetization → แต่ละ product → ต้องมี "Cleared for Sale" ✓
3. ทดสอบด้วย **TestFlight build** เท่านั้น
4. รอสักพักแล้วลองใหม่

---

### อาการ 2: "Cannot connect to iTunes Store"

**สาเหตุ:** ยัง login ด้วย Apple ID จริงอยู่ หรือ Sandbox มีปัญหา

**วิธีแก้:**
1. Settings → App Store → **Sign Out**
2. เปิดแอป → กดซื้อ → จะถาม Apple ID → ใส่ **lnxelnope2@gmail.com** (Sandbox)
3. ถ้ายังไม่ได้: ลบแอป → ติดตั้งใหม่จาก TestFlight → ลองอีกครั้ง

---

### อาการ 3: Products โหลดได้ แต่กดซื้อแล้วไม่เกิดอะไร / Error

**สาเหตุ:** Sandbox account ไม่ถูกต้อง หรือ region ไม่ตรง

**วิธีแก้:**
1. ตรวจสอบ Sandbox Tester ใน App Store Connect ว่า email ถูกต้อง
2. Sandbox account ต้องสร้างใน Users and Access → Sandbox (ไม่ใช่ Apple ID ปกติ)
3. ตรวจสอบ region ของ Sandbox account ตรงกับ App Store ของแอป

---

### อาการ 4: ซื้อสำเร็จ แต่ Energy ไม่เพิ่ม / Subscription ไม่ active

**สาเหตุ:** Backend verification ล้มเหลว — มักเป็น **APPLE_SHARED_SECRET**

**วิธีแก้:**
1. ตั้งค่า secret:
   ```bash
   firebase functions:secrets:set APPLE_SHARED_SECRET
   # วาง App-Specific Shared Secret จาก App Store Connect
   ```
2. App Store Connect → My Apps → [แอป] → App Information → scroll ลง → **App-Specific Shared Secret** → Generate (ถ้ายังไม่มี)
3. Deploy functions ใหม่หลัง set secret

---

### อาการ 5: Subscription โหลดไม่ได้ (หน้าว่าง / Error)

**สาเหตุ:** iOS ใช้ product ID คนละชุดกับ Android

**Product IDs ที่ถูกต้อง (iOS):**
- `miro_energy_pass_weekly`
- `miro_energy_pass_monthly`
- `miro_energy_pass_yearly`

**ตรวจสอบ:** App Store Connect → Subscriptions → miro_normal_subscription → แต่ละ subscription ต้องมี Product ID ตรงกับด้านบน

---

## แอปจะแสดง Error จริงแล้ว (v1.2.1+)

หลังอัพเดทล่าสุด แอปจะแสดง **ข้อความ error จริง** เมื่อ purchase fail แทน "Purchase failed. Please try again."

- **"Product not found"** → เช็ค App Store Connect, Paid Agreements
- **"Query error: ..."** → ปัญหาจาก StoreKit
- **"Purchase dialog failed"** → ลอง Sign Out → ใช้ Sandbox account

---

## Debug: ดู Log

รันจาก Xcode (หรือ `flutter run`) แล้วดู Console:

```
[PurchaseService] 🛒 IAP available: true/false
[PurchaseService] 🛒 Querying energy product: energy_100
[PurchaseService] ❌ Product not found  ← Products ไม่โหลด
[PurchaseService] 🛒 Initiating energy purchase  ← กำลังซื้อ
[PurchaseService] ✅ Purchase successful  ← ซื้อสำเร็จ
[PurchaseService] 🔍 Verifying with server...  ← กำลัง verify
[PurchaseService] ❌ Verification error  ← Backend ล้มเหลว
```

สำหรับ Subscription:
```
[SubscriptionService] Fetching products...
[SubscriptionService] Products not found: [...]  ← Product IDs ไม่ตรง
[SubscriptionService] Found 3 products  ← โหลดสำเร็จ
```

---

## Quick Fix Checklist

1. ☐ Sign Out จาก App Store บน iPhone
2. ☐ ใช้ TestFlight build (ไม่ใช่ run จาก Xcode)
3. ☐ เช็ค Paid Agreements ใน App Store Connect
4. ☐ ตั้งค่า APPLE_SHARED_SECRET ใน Firebase
5. ☐ Deploy functions หลัง set secret
6. ☐ รอ 15–30 นาที หลังสร้าง/แก้ product (propagation)
