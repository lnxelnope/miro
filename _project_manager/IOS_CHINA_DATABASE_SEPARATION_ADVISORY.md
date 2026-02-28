# iOS China Market: Database & Anti-Cheat Separation Advisory

## สถานะปัจจุบัน

### สิ่งที่ใช้ Firebase อยู่ตอนนี้:
1. **Firebase Cloud Functions** — backend API สำหรับ:
   - `analyzeFood` (Gemini API proxy)
   - `syncBalance` (Energy balance sync)
   - `registerUser` (Device registration)
   - `claimDailyEnergy` (Daily reward)
   - In-App Purchase verification
2. **Firebase Firestore** — เก็บ Energy balance ฝั่ง server (Source of Truth)
3. **Firebase Core** — initialization, analytics, crashlytics

### สิ่งที่อยู่ในเครื่อง (ไม่เกี่ยวกับ Firebase):
- **Isar Database** — food entries, user profile, meals, ingredients, chat, transactions
- **SecureStorage / SharedPreferences** — cached energy balance, device ID, flags

---

## ทำไมจีนถึงใช้ Firebase ไม่ได้?

Apple App Store China **อนุญาต** แอปที่ใช้ Firebase ได้ แต่ในทางปฏิบัติ:
- Google Cloud Functions ถูก **firewall** บล็อกในจีน → API เรียกไม่ได้
- Firebase Auth / Firestore ช้ามากหรือ timeout ในจีน
- ผู้ใช้จีนอาจมี VPN แต่ไม่ควร assume

---

## ระดับความยากในการแยกระบบ

### ระดับ 1: ง่าย — แยก API Endpoint (สัปดาห์ 1-2)

**แนวคิด:** เปลี่ยนจาก Firebase Cloud Functions → API server ที่ host ในจีน

| Component | ปัจจุบัน | ทางเลือกสำหรับจีน |
|-----------|---------|-------------------|
| API Server | Firebase Cloud Functions (us-central1) | Alibaba Cloud Function Compute / Tencent SCF / Self-hosted (Hong Kong/Shanghai) |
| Database | Firestore | PostgreSQL / MongoDB Atlas (HK region) / Alibaba RDS |
| Auth | Device ID based | เหมือนเดิม (Device ID) |

**สิ่งที่ต้องทำ:**
```
1. สร้าง backend ใหม่ (Node.js/Express หรือ Dart Shelf) ที่ทำหน้าที่เดียวกัน:
   - POST /analyzeFood
   - POST /syncBalance
   - POST /registerUser
   - POST /claimDailyEnergy
   - POST /verifyPurchase (Apple Receipt Validation)

2. ใช้ "platform" field ใน UserProfile (ที่เพิ่มแล้ว) + region detection 
   เพื่อเลือก endpoint set

3. ใน Dart code เพิ่ม config:
   class FirebaseConfig {
     static String get baseUrl {
       if (_isChinaRegion) return 'https://api-cn.miro-app.com';
       return 'https://us-central1-miro-d6856.cloudfunctions.net';
     }
   }
```

**ความยาก: ★★☆☆☆** — Logic เดิมทั้งหมด copy ไปได้เลย แค่เปลี่ยน infrastructure

---

### ระดับ 2: ปานกลาง — Anti-Cheat ที่ไม่พึ่ง Firebase (สัปดาห์ 2-3)

**ปัญหาหลัก:** ระบบ anti-cheat ปัจจุบันอาศัย:
1. Server-side balance (Firestore) เป็น Source of Truth
2. Energy Token (HMAC signed) ส่งไป-กลับกับ Cloud Functions
3. Device ID binding

**ทางเลือกสำหรับจีน:**

#### Option A: Self-hosted Backend + PostgreSQL (แนะนำ)
```
Architecture:
  [iOS App] ←→ [API Server (HK/Shanghai)] ←→ [PostgreSQL]
                     ↓
              [Gemini API proxy]
```

- **ข้อดี:** ควบคุมได้ 100%, ไม่ต้องพึ่ง Google services
- **ข้อเสีย:** ต้อง maintain server เอง
- **Cost:** ~$20-50/เดือน (Alibaba Cloud ECS + RDS)
- **Anti-cheat:** เหมือนเดิม — server เป็น source of truth

#### Option B: Supabase (Self-hosted ใน Asia region)
```
Architecture:
  [iOS App] ←→ [Supabase Edge Functions] ←→ [Supabase PostgreSQL]
```

- **ข้อดี:** คล้าย Firebase, มี auth + realtime + edge functions
- **ข้อเสีย:** Self-hosted Supabase ต้อง manage Docker
- **Cost:** ~$25/เดือน (Supabase Pro) หรือ self-hosted ฟรี

#### Option C: Dual Backend (แนะนำสำหรับ phase แรก)
```
ไม่ต้องสร้างใหม่ทั้งหมด — ใช้ Cloudflare Workers เป็น proxy:
  [iOS China] → [Cloudflare Worker (HK)] → [Firebase Cloud Functions]
```

- **ข้อดี:** ไม่ต้องเขียน backend ใหม่เลย, Cloudflare มี POP ในจีน
- **ข้อเสีย:** ยังพึ่ง Firebase อยู่ (แค่ bypass firewall)
- **Cost:** Cloudflare Workers Free tier (100k req/day)
- **ความยาก: ★☆☆☆☆** — เร็วที่สุด, แก้ปัญหาได้ทันที

---

### ระดับ 3: ซับซ้อน — Apple Receipt Validation แยก (สัปดาห์ 3-4)

In-App Purchase verification สำหรับ China App Store:
- China App Store ใช้ **Apple Sandbox/Production server เดียวกัน** กับ global
- Receipt validation endpoint ของ Apple เข้าถึงได้จากทุกที่
- **ไม่ต้องเปลี่ยนอะไร** — แค่ย้าย verification logic ไป server ใหม่

```
// ใช้ได้เหมือนเดิม
POST https://buy.itunes.apple.com/verifyReceipt  (Production)
POST https://sandbox.itunes.apple.com/verifyReceipt  (Sandbox)
```

---

## แผนที่แนะนำ (Recommended Roadmap)

### Phase 0: Quick Win — Cloudflare Proxy (1-2 วัน)
- ใช้ Cloudflare Workers เป็น reverse proxy ไปยัง Firebase
- ผู้ใช้จีนเรียก `api-cn.miro-app.com` → Cloudflare → Firebase
- **ไม่ต้องแก้ backend เลย**
- ใช้ `platform` field ที่เพิ่มแล้วเพื่อตัดสินใจ URL

### Phase 1: Region-Aware Client Config (1 สัปดาห์)
```dart
class ApiConfig {
  static Future<String> get baseUrl async {
    // Check if device is in China region
    if (await _isInChinaRegion()) {
      return 'https://api-cn.miro-app.com';
    }
    return 'https://us-central1-miro-d6856.cloudfunctions.net';
  }
  
  static Future<bool> _isInChinaRegion() async {
    // Option 1: Check device locale
    final locale = Platform.localeName;
    if (locale.contains('CN') || locale.contains('zh_Hans')) return true;
    
    // Option 2: Check App Store region (from receipt)
    // Option 3: User manual selection in settings
    return false;
  }
}
```

### Phase 2: Independent Backend (เมื่อมี user base ในจีน)
- สร้าง dedicated backend (Node.js + PostgreSQL) บน Alibaba Cloud
- Migrate energy logic ทั้งหมด
- ระบบ anti-cheat เหมือนเดิมทุกประการ (server = source of truth)

---

## สรุปความยาก

| Task | ความยาก | เวลา | Priority |
|------|---------|------|----------|
| Cloudflare proxy | ★☆☆☆☆ | 1-2 วัน | ทำก่อน |
| Client region detection | ★★☆☆☆ | 2-3 วัน | ทำพร้อม proxy |
| Independent API server | ★★★☆☆ | 1-2 สัปดาห์ | ทำเมื่อมี users |
| Database migration | ★★★☆☆ | 1 สัปดาห์ | ทำพร้อม API server |
| Anti-cheat (server-side) | ★★☆☆☆ | 2-3 วัน | Copy logic เดิมได้ |
| IAP verification | ★☆☆☆☆ | 1 วัน | Apple API ใช้ได้ทุกที่ |

**Total estimated effort:** 2-4 สัปดาห์ (สำหรับ full independent backend)
**Quick launch option:** 2-3 วัน (Cloudflare proxy only)

---

## หมายเหตุสำคัญ

1. **Gemini API** — Google Gemini API อาจถูกบล็อกในจีน เช่นกัน ต้อง proxy ผ่าน server ที่อยู่นอกจีน (HK) หรือใช้ alternative AI (Baidu ERNIE / Alibaba Qwen)
2. **`platform` field** — เพิ่มใน `UserProfile` แล้ว (`'android'` / `'ios'`) เพื่อรองรับ conditional logic ในอนาคต
3. **Data sovereignty** — ข้อมูลอาหารเก็บในเครื่อง (Isar) ไม่เกี่ยวกับ server → ไม่มีปัญหา PIPL (Personal Information Protection Law ของจีน)
4. **Energy data** — ถ้า host server ใน mainland China ต้อง comply กับ data localization laws
