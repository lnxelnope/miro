# Final Checklist — ตรวจสอบก่อน Handover

ใช้ checklist นี้เพื่อตรวจสอบว่าทำ Admin Panel เสร็จสมบูรณ์ก่อนส่งมอบงาน

---

## ✅ Pre-flight Checks (ก่อนเริ่มทำ)

- [ ] Clone/pull โปรเจกต์ล่าสุดแล้ว
- [ ] มี `serviceAccountKey.json` ใน `admin-panel/`
- [ ] รัน `npm install` เรียบร้อย
- [ ] รัน `npm run dev` ได้ → เปิด `http://localhost:3000`
- [ ] Login เข้า Admin Panel ได้
- [ ] เปิด Browser Console (`F12`) ไม่มี error ตอน load

---

## 📊 Task 1: Dashboard — Checklist

### API Endpoints ✓
- [ ] GET `/api/dashboard/stats` → return `{ totalUsers, activeUsers, totalRevenue, activeSubscribers }`
- [ ] GET `/api/dashboard/user-growth?days=30` → return `{ growth: [...] }`
- [ ] GET `/api/dashboard/streak-distribution` → return `{ distribution: [...] }`
- [ ] GET `/api/dashboard/recent-activities?limit=20` → return `{ activities: [...] }`

### Components ✓
- [ ] `MetricCard.tsx` สร้างแล้ว
- [ ] `UserGrowthChart.tsx` สร้างแล้ว + กราฟแสดงได้
- [ ] `StreakDistribution.tsx` สร้างแล้ว + แสดงแต่ละ tier
- [ ] `RecentActivities.tsx` สร้างแล้ว + แสดง transactions

### Dashboard Page ✓
- [ ] เปิด `http://localhost:3000/` → เห็น Dashboard
- [ ] แสดง 4 metric cards (Total Users, Active Users, Revenue, Subscribers)
- [ ] กราฟ User Growth แสดงได้ (ถ้ามี data)
- [ ] Streak Distribution แสดงจำนวนแต่ละ tier
- [ ] Recent Activities แสดง 10-20 รายการล่าสุด
- [ ] Refresh หน้า → ข้อมูลยังอยู่
- [ ] Console ไม่มี error

---

## 👥 Task 2: User Management — Checklist

### API Endpoints ✓
- [ ] GET `/api/users/search?q=MIRO_ID` → return `{ user: {...} }`
- [ ] GET `/api/users/[deviceId]` → return `{ user, transactions }`
- [ ] POST `/api/users/[deviceId]/topup` → update balance + log transaction
- [ ] POST `/api/users/[deviceId]/reset-streak` → reset streak = 0
- [ ] POST `/api/users/[deviceId]/ban` → update isBanned

### Components ✓
- [ ] `UserSearch.tsx` สร้างแล้ว + search ได้
- [ ] `UserDetailModal.tsx` สร้างแล้ว + แสดงข้อมูล user

### Users Page ✓
- [ ] เปิด `http://localhost:3000/users`
- [ ] มี search box
- [ ] Search ด้วย MiRO ID → เจอ user
- [ ] Search ด้วย Device ID → เจอ user
- [ ] กด "View Details" → modal เปิด
- [ ] Modal แสดงข้อมูล user ครบ (balance, tier, streak)
- [ ] Modal แสดง transaction history
- [ ] Top-up energy → balance เพิ่ม → check Firestore ถูกบันทึก
- [ ] Reset streak → streak = 0, tier = none
- [ ] Ban user → isBanned = true → แสดง badge "BANNED"
- [ ] Unban user → isBanned = false → badge หายไป
- [ ] Console ไม่มี error

### Sidebar ✓
- [ ] มี "Users" link ใน sidebar
- [ ] กด link → ไปหน้า Users ได้

---

## ⚙️ Task 3: Config Management — Checklist

### API Endpoints ✓
- [ ] GET `/api/config` → return `{ config: {...} }`
- [ ] POST `/api/config` → save config to Firestore

### Components ✓
- [ ] `PromotionsForm.tsx` สร้างแล้ว
- [ ] `DailyRewardsForm.tsx` สร้างแล้ว
- [ ] `ChallengesForm.tsx` สร้างแล้ว

### Config Page ✓
- [ ] เปิด `http://localhost:3000/config`
- [ ] มี 3 tabs: Promotions, Daily Rewards, Challenges
- [ ] Tab "Promotions":
  - [ ] แสดง Welcome Offer form (threshold, free energy, bonus %, duration)
  - [ ] แสดง Tier Upgrade form (bronze, silver, gold, diamond rewards)
  - [ ] แสดง Welcome Back form (bonus %, duration)
- [ ] Tab "Daily Rewards":
  - [ ] แสดง daily energy แต่ละ tier (Starter, Bronze, Silver, Gold, Diamond)
- [ ] Tab "Challenges":
  - [ ] แสดง Log Meals challenge (goal, reward)
  - [ ] แสดง Use AI challenge (goal, reward)
  - [ ] แสดง Milestones (500, 1000 spent)
- [ ] แก้ค่า → กด Save → alert "Config saved"
- [ ] Reload หน้า → ค่ายังอยู่ (ไม่หาย)
- [ ] Console ไม่มี error

### Sidebar ✓
- [ ] มี "Config" link ใน sidebar
- [ ] กด link → ไปหน้า Config ได้

---

## 💎 Task 4: Subscription Management — Checklist

### API Endpoints ✓
- [ ] GET `/api/subscriptions/metrics` → return `{ mrr, activeSubscribers, expiringSoon, churnRate }`
- [ ] GET `/api/subscriptions/list?status=active` → return `{ subscribers: [...] }`

### Components ✓
- [ ] `SubscriptionMetrics.tsx` สร้างแล้ว
- [ ] `SubscribersTable.tsx` สร้างแล้ว

### Subscriptions Page ✓
- [ ] เปิด `http://localhost:3000/subscriptions`
- [ ] แสดง 4 metric cards (MRR, Active Subscribers, Expiring Soon, Churn Rate)
- [ ] แสดง table รายชื่อ subscribers
- [ ] Table มี columns: MiRO ID, Status, Expiry Date, Balance
- [ ] Subscribers ที่ใกล้หมดอายุ (< 7 วัน) มี background สีเหลือง + ⚠️ icon
- [ ] Console ไม่มี error

### Sidebar ✓
- [ ] มี "Subscriptions" link ใน sidebar
- [ ] กด link → ไปหน้า Subscriptions ได้

---

## 🎨 UI/UX Quality Checks

### Responsive Design ✓
- [ ] Desktop (1920x1080) → layout ปกติ
- [ ] Tablet (768px) → layout ปรับได้
- [ ] Mobile (375px) → layout ไม่พัง (ถ้าต้องการ support)

### Loading States ✓
- [ ] Dashboard → แสดง "Loading..." ก่อนได้ data
- [ ] Users search → แสดง "Searching..." ขณะค้นหา
- [ ] Config save → แสดง loading overlay

### Error Handling ✓
- [ ] Search user ที่ไม่มี → แสดง error message
- [ ] API fail → แสดง error ไม่ crash
- [ ] Form validation → แสดง error ถ้า input ผิด

### Performance ✓
- [ ] Dashboard load ใน < 3 วินาที
- [ ] User search respond ใน < 1 วินาที
- [ ] Config save respond ใน < 2 วินาที
- [ ] ไม่มี memory leak (reload หลายครั้ง RAM ไม่เพิ่ม)

---

## 🔒 Security Checks

### Firebase Admin SDK ✓
- [ ] `serviceAccountKey.json` ไม่ commit ลง git
- [ ] `.gitignore` มี `serviceAccountKey.json`
- [ ] API routes ใช้ Firebase Admin SDK (server-side only)

### Input Validation ✓
- [ ] Top-up amount ต้อง > 0
- [ ] Search query ต้องไม่ว่าง
- [ ] Config values validate ก่อน save

### Error Messages ✓
- [ ] ไม่ expose sensitive info ใน error messages
- [ ] Error messages เป็นภาษาอังกฤษหรือไทยที่อ่านเข้าใจได้

---

## 📦 Deployment Readiness

### Environment ✓
- [ ] มีไฟล์ `.env.local` (ถ้าใช้)
- [ ] Service account key มีอยู่และถูกต้อง
- [ ] Firebase project ID ถูกต้อง

### Build ✓
- [ ] รัน `npm run build` สำเร็จ
- [ ] ไม่มี build errors
- [ ] ไม่มี TypeScript errors

### Dependencies ✓
- [ ] `package.json` มี dependencies ครบ
- [ ] ไม่มี unused dependencies
- [ ] `package-lock.json` ถูก commit

---

## 📝 Documentation Checks

### Code Quality ✓
- [ ] Code มี proper formatting (indentation สม่ำเสมอ)
- [ ] มี comments อธิบายส่วนที่ซับซ้อน (ถ้ามี)
- [ ] ไม่มี `console.log` debug code ทิ้งค้าง

### README ✓
- [ ] `admin-panel/README.md` มีคำแนะนำ setup
- [ ] มีคำสั่ง `npm install`, `npm run dev`, `npm run build`
- [ ] มีคำอธิบายวิธี deploy (ถ้ามี)

---

## 🧪 Final Testing (ครั้งสุดท้าย)

### Smoke Test ✓
- [ ] Fresh install: clone → npm install → npm run dev → login
- [ ] Dashboard: เปิดได้ + แสดงข้อมูล
- [ ] Users: search user → view detail → top-up → reset → ban
- [ ] Config: แก้ config → save → reload → ค่ายังอยู่
- [ ] Subscriptions: ดู metrics + subscribers list

### Browser Compatibility ✓
- [ ] Chrome (ล่าสุด) → ทำงานปกติ
- [ ] Firefox (ล่าสุด) → ทำงานปกติ
- [ ] Edge (ล่าสุด) → ทำงานปกติ

### Data Integrity ✓
- [ ] Top-up → check Firestore → balance ถูกต้อง
- [ ] Top-up → check transactions collection → มี log
- [ ] Reset streak → check Firestore → streak = 0, tier = none
- [ ] Ban → check Firestore → isBanned = true, banReason มีค่า
- [ ] Save config → check Firestore config collection → data ถูกบันทึก

---

## 🎉 Final Handover Checklist

### Code ✓
- [ ] Commit code ล่าสุดแล้ว
- [ ] Push ขึ้น git repository แล้ว
- [ ] Branch: `feature/admin-panel` หรือ `main`

### Documentation ✓
- [ ] ส่ง folder `admin_panel_tasks/` ให้ผู้รับมอบ
- [ ] แจ้ง URL ของ git repository
- [ ] แจ้ง credentials (username/password) สำหรับ test

### Demo ✓
- [ ] Demo ให้ดู 4 หน้าหลัก (Dashboard, Users, Config, Subscriptions)
- [ ] แสดงการใช้งานฟีเจอร์หลัก (search, top-up, config)
- [ ] อธิบาย architecture (ตาม VISUAL_GUIDE.md)

### Known Issues ✓
- [ ] ถ้ามี bugs ที่ยังไม่แก้ → ทำ list บอกผู้รับมอบ
- [ ] ถ้ามี features ที่ยังไม่ทำ → ทำ list TODO

---

## 🚀 Deployment (Optional)

ถ้าต้อง deploy ขึ้น production:

- [ ] Build successful: `npm run build`
- [ ] Deploy script ทำงาน: `.\deploy.ps1`
- [ ] Get production URL
- [ ] Test production URL → ทำงานปกติ
- [ ] แจ้ง production URL ให้ผู้รับมอบ

---

## 📊 Final Score

**Total Checklist Items:** ~120 ข้อ

**คะแนนผ่าน:** ≥ 90% (108/120)

**คะแนนเต็ม:** 100% (120/120)

---

## 📝 Sign-off

**ผู้ทำ (Junior):**  
Signature: ___________________  
Date: ___________________

**ผู้ตรวจ (Senior/PM):**  
Signature: ___________________  
Date: ___________________

**สถานะ:**
- [ ] ✅ ผ่านทุก checklist → ส่งมอบได้
- [ ] ⚠️ มีบางข้อที่ยังไม่ผ่าน → แก้ไขก่อนส่งมอบ
- [ ] ❌ ไม่ผ่าน → ทำใหม่

---

**เสร็จสิ้น! ขอบคุณสำหรับการทำงาน 🎉**
