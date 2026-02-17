# Phase 3: Admin Panel + Notifications

**เป้าหมาย:** Admin Dashboard, Push Notifications, Monitoring  
**ระยะเวลา:** 2 สัปดาห์  
**Tech Stack:** Next.js, Firebase Admin SDK, FCM

---

## 📋 Task List

| Task | ชื่อ | ระยะเวลา |
|------|------|---------|
| 1 | Admin Panel Setup (Next.js + shadcn/ui) | 2 วัน |
| 2 | Dashboard (Metrics + Charts) | 2 วัน |
| 3 | User Lookup + Operations | 2 วัน |
| 4 | Config Management UI | 1 วัน |
| 5 | Push Notifications (FCM) | 2 วัน |
| 6 | Fraud Detection Alerts | 1 วัน |
| 7 | Testing + Deploy | 2 วัน |

---

## 🎯 Deliverables

### Admin Panel Features
- ✅ Dashboard: DAU, Revenue, Streak distribution
- ✅ User Lookup (by MiRO ID / deviceId)
- ✅ Manual Operations (top-up, reset streak, ban)
- ✅ Config Editor (rewards, feature flags)
- ✅ Transaction History viewer
- ✅ Fraud alerts (suspicious patterns)

### Push Notifications
- ✅ Streak Reminder (20:00)
- ✅ Challenge Almost Done
- ✅ Tier Almost Unlocked
- ✅ Win-back (3+ days inactive)

### Cloud Functions
- ✅ `admin/*` — CRUD + metrics
- ✅ `sendNotifications` — Cron job

---

## 📌 Important Notes

1. **Authentication:** Admin Panel ต้องมี Firebase Auth (email/password)
2. **Role-based:** เฉพาะ admin email ที่ listed ใน Firestore เท่านั้นเข้าได้
3. **Audit Log:** ทุก manual operation ต้องบันทึก log
4. **Read-only Dashboard:** Default = read-only, ต้อง unlock เพื่อแก้ไข

---

## 🔗 Resources

- Next.js: https://nextjs.org/docs
- shadcn/ui: https://ui.shadcn.com/
- FCM: https://firebase.google.com/docs/cloud-messaging

ดูรายละเอียดใน: `PHASE_3_ADMIN.md` (in parent folder)
