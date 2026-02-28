# Admin Panel — เอกสารสรุปทั้งหมด

## 📚 ไฟล์เอกสารทั้งหมด

| ไฟล์ | หัวข้อ | ระยะเวลา | ความยาก |
|---|---|---|---|
| `README.md` | แนะนำและเริ่มต้น | - | - |
| `TASK_1_DASHBOARD.md` | Dashboard Metrics | 4 ชม. | ⭐⭐☆☆☆ |
| `TASK_2_USERS.md` | User Management | 6 ชม. | ⭐⭐⭐☆☆ |
| `TASK_3_CONFIG.md` | Config Management | 5 ชม. | ⭐⭐⭐☆☆ |
| `TASK_4_SUBSCRIPTIONS.md` | Subscription Management | 4 ชม. | ⭐⭐☆☆☆ |

**รวมทั้งหมด: ~19 ชั่วโมง** (2-3 วันทำงาน)

---

## 🎯 สิ่งที่จะได้หลังทำเสร็จ

### 1. Dashboard (/dashboard หรือ /)
- ✅ Metric cards: Total users, Active users, Revenue, Subscribers
- ✅ User growth chart (30 days)
- ✅ Streak distribution by tier
- ✅ Recent activities/transactions

### 2. User Management (/users)
- ✅ Search users (by MiRO ID or Device ID)
- ✅ View user details + transaction history
- ✅ Top-up energy (with reason)
- ✅ Reset streak to 0
- ✅ Ban/Unban users

### 3. Config Management (/config)
- ✅ Promotions settings (Welcome Offer, Tier Up, Welcome Back)
- ✅ Daily rewards per tier
- ✅ Weekly challenges config (Log Meals, Use AI)
- ✅ Milestone rewards (500, 1000 energy spent)

### 4. Subscription Management (/subscriptions)
- ✅ Subscription metrics (MRR, Active, Expiring, Churn)
- ✅ Subscribers list with expiry alerts
- ✅ Revenue report

---

## 📂 โครงสร้างโปรเจกต์

```
admin-panel/
├── src/
│   ├── app/
│   │   ├── (dashboard)/
│   │   │   ├── page.tsx                  ← Task 1: Dashboard
│   │   │   ├── users/
│   │   │   │   └── page.tsx              ← Task 2: User Management
│   │   │   ├── config/
│   │   │   │   └── page.tsx              ← Task 3: Config Management
│   │   │   └── subscriptions/
│   │   │       └── page.tsx              ← Task 4: Subscription Management
│   │   └── api/
│   │       ├── dashboard/
│   │       │   ├── stats/route.ts
│   │       │   ├── user-growth/route.ts
│   │       │   ├── streak-distribution/route.ts
│   │       │   └── recent-activities/route.ts
│   │       ├── users/
│   │       │   ├── search/route.ts
│   │       │   └── [deviceId]/
│   │       │       ├── route.ts
│   │       │       ├── topup/route.ts
│   │       │       ├── reset-streak/route.ts
│   │       │       └── ban/route.ts
│   │       ├── config/
│   │       │   └── route.ts
│   │       └── subscriptions/
│   │           ├── metrics/route.ts
│   │           └── list/route.ts
│   └── components/
│       ├── dashboard/
│       │   ├── MetricCard.tsx
│       │   ├── UserGrowthChart.tsx
│       │   ├── StreakDistribution.tsx
│       │   └── RecentActivities.tsx
│       ├── users/
│       │   ├── UserSearch.tsx
│       │   └── UserDetailModal.tsx
│       ├── config/
│       │   ├── PromotionsForm.tsx
│       │   ├── DailyRewardsForm.tsx
│       │   └── ChallengesForm.tsx
│       └── subscriptions/
│           ├── SubscriptionMetrics.tsx
│           └── SubscribersTable.tsx
```

---

## 🚀 เริ่มต้นทำงาน

### 1. Setup Environment

```powershell
cd c:\aiprogram\miro\admin-panel
npm install
```

### 2. เตรียม Firebase Service Account

- Download `serviceAccountKey.json` จาก Firebase Console
- วางไว้ที่ `admin-panel/serviceAccountKey.json`

### 3. รัน Dev Server

```powershell
npm run dev
```

เปิด: `http://localhost:3000`

### 4. ทำ Task ตามลำดับ

1. อ่าน `README.md` ก่อน
2. ทำ `TASK_1_DASHBOARD.md` → test
3. ทำ `TASK_2_USERS.md` → test
4. ทำ `TASK_3_CONFIG.md` → test
5. ทำ `TASK_4_SUBSCRIPTIONS.md` → test

---

## ✅ Checklist ความสมบูรณ์

### Task 1: Dashboard ✓
- [ ] API: stats, user-growth, streak-distribution, recent-activities
- [ ] Components: MetricCard, UserGrowthChart, StreakDistribution, RecentActivities
- [ ] Dashboard page แสดงทุกอย่างถูกต้อง
- [ ] ไม่มี error ใน console

### Task 2: Users ✓
- [ ] API: search, user detail, topup, reset-streak, ban
- [ ] Components: UserSearch, UserDetailModal
- [ ] Users page ทำงานครบทุกฟีเจอร์
- [ ] Top-up → balance เพิ่ม → transaction log บันทึก
- [ ] Reset streak → streak = 0
- [ ] Ban/Unban → status เปลี่ยน

### Task 3: Config ✓
- [ ] API: get/post config
- [ ] Components: PromotionsForm, DailyRewardsForm, ChallengesForm
- [ ] Config page แสดง 3 tabs
- [ ] Save config → reload → ค่ายังอยู่

### Task 4: Subscriptions ✓
- [ ] API: metrics, list
- [ ] Components: SubscriptionMetrics, SubscribersTable
- [ ] Subscriptions page แสดง metrics + table
- [ ] Expiring soon subscribers มี highlight

---

## 🎓 เคล็ดลับสำหรับ Junior

### 1. อ่านทีละบรรทัด
เอกสารเขียนละเอียดมาก มี code ตัวอย่างครบ copy-paste ได้เลย

### 2. Test ทุกครั้ง
หลังเสร็จแต่ละ Step → test API/UI ให้แน่ใจว่าใช้งานได้

### 3. ใช้ Checklist
ทุก task มี checklist → ติ๊กทุกข้อก่อนไป task ถัดไป

### 4. Console คือเพื่อน
เปิด browser console (`F12`) → ดู error messages

### 5. ถ้าติด
- อ่าน "Troubleshooting" ท้ายแต่ละ task
- เช็ค console logs
- ถามคนที่มอบหมาย task

---

## 📦 Deployment (หลังทำเสร็จทั้งหมด)

### 1. Build

```powershell
npm run build
```

### 2. Deploy to Cloud Run (Production)

```powershell
.\deploy.ps1
```

### 3. เสร็จแล้ว!

จะได้ URL: `https://admin-panel-xxx.run.app`

---

## 🛠️ Dependencies ที่ต้องติดตั้ง

### Core Dependencies
- ✅ `next` (Next.js 14)
- ✅ `react` / `react-dom`
- ✅ `firebase-admin`

### UI Libraries
```powershell
npx shadcn-ui@latest add button
npx shadcn-ui@latest add input
npx shadcn-ui@latest add dialog
npx shadcn-ui@latest add tabs
npx shadcn-ui@latest add label
npx shadcn-ui@latest add table
```

### Charts
```powershell
npm install recharts
```

---

## 🌟 สิ่งที่ควรรู้

### 1. Firebase Admin SDK
ใช้ `firebase-admin` เพื่อเข้าถึง Firestore โดยตรง (ไม่ผ่าน client SDK)

### 2. Next.js API Routes
API endpoints อยู่ใน `src/app/api/` → เรียกได้ที่ `/api/...`

### 3. Server Components vs Client Components
- **Server:** default, ไม่ต้องใส่ `'use client'`
- **Client:** ถ้ามี `useState`, `useEffect` → ต้องใส่ `'use client'` ด้านบน

### 4. Firestore Queries
```typescript
// Count documents
await db.collection('users').count().get();

// Where clause
await db.collection('users').where('tier', '==', 'gold').get();

// Order + Limit
await db.collection('users').orderBy('createdAt', 'desc').limit(10).get();
```

---

## 📞 ติดต่อ / ถามปัญหา

ถ้ามีปัญหาหรือติดขัด:
1. ✅ อ่าน Troubleshooting ใน task นั้นๆ ก่อน
2. ✅ เช็ค console logs
3. ✅ ดู error message ให้ดี
4. ✅ ถามคนที่มอบหมาย task

---

**เริ่มได้เลย! เปิดไฟล์ `README.md` แล้วไป Task 1 🚀**
