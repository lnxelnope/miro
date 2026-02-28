# Admin Panel Tasks — สำหรับ Junior Developer

**เป้าหมาย:** ทำ Admin Panel ให้เสร็จ 100% สำหรับจัดการระบบ MiRO

## 📋 Overview

Admin Panel คือหน้าเว็บหลังบ้านที่ใช้จัดการ:
- 📊 ดู Dashboard metrics (users, revenue, streaks)
- 👥 จัดการ Users (search, topup, ban, reset streak)
- ⚙️ ตั้งค่า Config (challenges, promotions, milestones)
- 💳 จัดการ Subscriptions (subscribers, revenue)

---

## 🎯 Tasks ที่ต้องทำ

| Task | Description | Duration | Status |
|---|---|---|---|
| ✅ Task 0 | Authentication (เสร็จแล้ว) | - | DONE |
| 📊 Task 1 | Dashboard Metrics | 4 ชม. | TODO |
| 👥 Task 2 | User Management | 6 ชม. | TODO |
| ⚙️ Task 3 | Config Management | 5 ชม. | TODO |
| 💳 Task 4 | Subscription Management | 4 ชม. | TODO |

---

## 🚀 เริ่มต้นอย่างไร?

### 1. เปิด Admin Panel บน Local

```powershell
cd c:\aiprogram\miro\admin-panel
npm install
npm run dev
```

เปิดเบราว์เซอร์: `http://localhost:3000`

### 2. Login

- Username: `admin` (หรือตาม `.env.local`)
- Password: `your-password`

### 3. เลือก Task ที่จะทำ

เปิดไฟล์ใน `admin_panel_tasks/` ตามลำดับ:
1. `TASK_1_DASHBOARD.md` — Dashboard Metrics
2. `TASK_2_USERS.md` — User Management
3. `TASK_3_CONFIG.md` — Config Management
4. `TASK_4_SUBSCRIPTIONS.md` — Subscription Management

---

## 📂 โครงสร้างโฟลเดอร์

```
admin-panel/
├── src/
│   ├── app/
│   │   ├── (dashboard)/
│   │   │   ├── page.tsx          ← Task 1: Dashboard
│   │   │   ├── users/
│   │   │   │   └── page.tsx      ← Task 2: Users
│   │   │   ├── config/
│   │   │   │   └── page.tsx      ← Task 3: Config
│   │   │   └── subscriptions/
│   │   │       └── page.tsx      ← Task 4: Subscriptions
│   │   └── api/
│   │       ├── dashboard/
│   │       ├── users/
│   │       ├── config/
│   │       └── subscriptions/
│   └── components/
│       ├── dashboard/
│       ├── users/
│       ├── config/
│       └── subscriptions/
```

---

## 🛠️ เครื่องมือที่ใช้

- **Frontend:** Next.js 14 (App Router)
- **UI Library:** shadcn/ui
- **Charts:** Recharts
- **Backend:** Firebase Admin SDK
- **Database:** Firestore

---

## 📝 หมายเหตุสำคัญ

1. **อ่าน Task แต่ละไฟล์ทีละบรรทัด** — มี code ตัวอย่างครบ copy ได้เลย
2. **ทำตามลำดับ Task 1 → 2 → 3 → 4** — อย่าข้าม
3. **Test ทุกครั้งหลังเสร็จแต่ละ Task** — มี checklist ให้
4. **ถ้าติดปัญหา** — ดู "Troubleshooting" ท้ายแต่ละ task

---

## 🎓 Skills ที่ต้องมี (พื้นฐาน)

- ✅ รู้จัก React/Next.js พื้นฐาน
- ✅ รู้จัก TypeScript พื้นฐาน
- ✅ Copy-paste code ได้
- ✅ อ่าน error message ออก

**ไม่ต้องเก่ง!** แค่ทำตามเอกสาร + copy code ก็เสร็จแล้ว

---

## 📞 ติดต่อ

ถ้ามีปัญหา:
1. อ่าน Troubleshooting ใน task นั้นๆ ก่อน
2. ถ้ายังแก้ไม่ได้ ถามคนที่มอบหมาย task นี้

---

**เริ่มได้เลย! 🚀 เปิดไฟล์ `TASK_1_DASHBOARD.md`**
