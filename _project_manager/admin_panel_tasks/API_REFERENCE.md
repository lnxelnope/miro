# Quick Reference — API Endpoints

เอกสารอ้างอิงด่วนสำหรับ API endpoints ทั้งหมดใน Admin Panel

---

## 📊 Dashboard APIs

### 1. GET `/api/dashboard/stats`
**คำอธิบาย:** ดึงสถิติภาพรวม (Total users, Active users, Revenue, Subscribers)

**Response:**
```json
{
  "success": true,
  "stats": {
    "totalUsers": 1234,
    "activeUsers": 890,
    "totalRevenue": 12345,
    "activeSubscribers": 45
  }
}
```

---

### 2. GET `/api/dashboard/user-growth?days=30`
**คำอธิบาย:** ดึงข้อมูล user growth แต่ละวัน

**Query Params:**
- `days` (optional): จำนวนวันย้อนหลัง (default: 30)

**Response:**
```json
{
  "success": true,
  "growth": [
    { "date": "2026-02-01", "users": 15 },
    { "date": "2026-02-02", "users": 20 }
  ]
}
```

---

### 3. GET `/api/dashboard/streak-distribution`
**คำอธิบาย:** ดึงจำนวน users แต่ละ tier

**Response:**
```json
{
  "success": true,
  "distribution": [
    { "tier": "Starter", "count": 100 },
    { "tier": "Bronze", "count": 50 },
    { "tier": "Silver", "count": 30 },
    { "tier": "Gold", "count": 15 },
    { "tier": "Diamond", "count": 5 }
  ]
}
```

---

### 4. GET `/api/dashboard/recent-activities?limit=20`
**คำอธิบาย:** ดึง transaction log ล่าสุด

**Query Params:**
- `limit` (optional): จำนวนรายการ (default: 20)

**Response:**
```json
{
  "success": true,
  "activities": [
    {
      "id": "txn123",
      "type": "purchase",
      "amount": 100,
      "description": "Purchased 100 energy",
      "miroId": "ABC123",
      "createdAt": "2026-02-18T10:00:00Z"
    }
  ]
}
```

---

## 👥 Users APIs

### 5. GET `/api/users/search?q=ABC123`
**คำอธิบาย:** ค้นหา user ด้วย MiRO ID หรือ Device ID

**Query Params:**
- `q` (required): MiRO ID หรือ Device ID

**Response:**
```json
{
  "success": true,
  "user": {
    "deviceId": "device123",
    "miroId": "ABC123",
    "balance": 45,
    "tier": "gold",
    "currentStreak": 30,
    "totalSpent": 120,
    "isSubscriber": false,
    "isBanned": false
  }
}
```

---

### 6. GET `/api/users/[deviceId]`
**คำอธิบาย:** ดึงข้อมูล user พร้อม transaction history

**Response:**
```json
{
  "success": true,
  "user": { ... },
  "transactions": [
    {
      "id": "txn123",
      "type": "purchase",
      "amount": 100,
      "description": "Purchased 100 energy",
      "createdAt": "2026-02-18T10:00:00Z"
    }
  ]
}
```

---

### 7. POST `/api/users/[deviceId]/topup`
**คำอธิบาย:** Top-up energy ให้ user

**Body:**
```json
{
  "amount": 100,
  "reason": "Compensation for bug"
}
```

**Response:**
```json
{
  "success": true,
  "newBalance": 145
}
```

---

### 8. POST `/api/users/[deviceId]/reset-streak`
**คำอธิบาย:** รีเซ็ต streak เป็น 0

**Body:**
```json
{
  "reason": "User request"
}
```

**Response:**
```json
{
  "success": true
}
```

---

### 9. POST `/api/users/[deviceId]/ban`
**คำอธิบาย:** แบนหรือปลดแบน user

**Body:**
```json
{
  "isBanned": true,
  "reason": "Abuse detected"
}
```

**Response:**
```json
{
  "success": true
}
```

---

## ⚙️ Config APIs

### 10. GET `/api/config`
**คำอธิบาย:** ดึงค่า config ทั้งหมด

**Response:**
```json
{
  "success": true,
  "config": {
    "promotions": {
      "welcomeOffer": {
        "threshold": 10,
        "freeEnergy": 50,
        "bonusRate": 0.40,
        "duration": 24
      },
      "tierUpgrade": {
        "bonusRate": 0.20,
        "duration": 24,
        "rewards": {
          "bronze": 3,
          "silver": 5,
          "gold": 10,
          "diamond": 15
        }
      },
      "welcomeBack": {
        "bonusRate": 0.40,
        "duration": 24
      }
    },
    "dailyRewards": {
      "none": 1,
      "bronze": 1,
      "silver": 2,
      "gold": 3,
      "diamond": 4
    },
    "challenges": {
      "logMeals": { "goal": 7, "reward": 10 },
      "useAi": { "goal": 3, "reward": 5 }
    },
    "milestones": {
      "spent500": 50,
      "spent1000": 100
    }
  }
}
```

---

### 11. POST `/api/config`
**คำอธิบาย:** บันทึกค่า config ใหม่

**Body:**
```json
{
  "config": {
    "promotions": { ... },
    "dailyRewards": { ... },
    "challenges": { ... },
    "milestones": { ... }
  }
}
```

**Response:**
```json
{
  "success": true
}
```

---

## 💎 Subscriptions APIs

### 12. GET `/api/subscriptions/metrics`
**คำอธิบาย:** ดึง subscription metrics

**Response:**
```json
{
  "success": true,
  "metrics": {
    "mrr": 3555,
    "activeSubscribers": 45,
    "expiringSoon": 5,
    "churnRate": 5.2
  }
}
```

---

### 13. GET `/api/subscriptions/list?status=active&limit=50`
**คำอธิบาย:** ดึงรายชื่อ subscribers

**Query Params:**
- `status` (optional): `active`, `expired`, `cancelled`, `all` (default: active)
- `limit` (optional): จำนวนรายการ (default: 50)

**Response:**
```json
{
  "success": true,
  "subscribers": [
    {
      "deviceId": "device123",
      "miroId": "ABC123",
      "subscriptionStatus": "active",
      "subscriptionExpiryDate": "2026-03-15T10:00:00Z",
      "balance": 999,
      "tier": "diamond",
      "currentStreak": 60
    }
  ],
  "total": 45
}
```

---

## 🔒 Authentication

**ทุก API ควรตรวจสอบ authentication ก่อน** (ตอนนี้ยังไม่มี middleware)

ในอนาคต อาจเพิ่ม:
```typescript
// middleware.ts
export function middleware(request: NextRequest) {
  const session = getSession(request);
  if (!session) {
    return NextResponse.redirect('/login');
  }
}
```

---

## 📝 Error Responses

**Error Format:**
```json
{
  "error": "Error message here"
}
```

**HTTP Status Codes:**
- `200` — Success
- `400` — Bad Request (missing params)
- `404` — Not Found
- `500` — Internal Server Error

---

## 🧪 Testing APIs

### ใช้ Browser (GET requests)
```
http://localhost:3000/api/dashboard/stats
```

### ใช้ curl (POST requests)
```powershell
# Top-up
curl -X POST http://localhost:3000/api/users/DEVICE_ID/topup `
  -H "Content-Type: application/json" `
  -d '{\"amount\": 100, \"reason\": \"Test\"}'

# Reset streak
curl -X POST http://localhost:3000/api/users/DEVICE_ID/reset-streak `
  -H "Content-Type: application/json" `
  -d '{\"reason\": \"Test\"}'

# Ban user
curl -X POST http://localhost:3000/api/users/DEVICE_ID/ban `
  -H "Content-Type: application/json" `
  -d '{\"isBanned\": true, \"reason\": \"Test\"}'

# Save config
curl -X POST http://localhost:3000/api/config `
  -H "Content-Type: application/json" `
  -d '{\"config\": {...}}'
```

### ใช้ Postman
1. Import collection จาก `admin-panel/postman_collection.json` (ถ้ามี)
2. หรือสร้าง request ใหม่ตาม endpoints ข้างบน

---

## 🎯 Tips

### 1. เช็ค Logs
```powershell
# ดู logs จาก Cloud Functions
firebase functions:log

# ดู logs จาก Next.js dev server
# (จะแสดงอัตโนมัติใน terminal)
```

### 2. เช็ค Firestore Data
เปิด Firebase Console → Firestore Database

### 3. Test Error Cases
- ลอง search user ที่ไม่มี
- ลอง top-up amount เป็น negative
- ลอง save config format ผิด

---

**Reference เสร็จสิ้น! กลับไปทำ task ต่อได้เลย 🚀**
