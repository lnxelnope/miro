# Enhanced User Management System

## 🎯 Overview

ระบบจัดการผู้ใช้แบบครบวงจรสำหรับการทดสอบและ debugging ระบบ Energy Marketing V3

## ✨ Features

### 1. **User Detail Modal (5 Tabs)**

#### Tab 1: Profile
- ดูข้อมูลพื้นฐานของผู้ใช้
- Quick Actions สำหรับการทดสอบ:
  - 🔄 Reset to New User
  - 🎚️ Set Tier (Starter/Bronze/Silver/Gold/Diamond)
  - ⚡ Adjust Balance (+/- Energy)
  - 🔥 Set Streak (0, 7, 15, 30 days)
  - 🔒 Ban/Unban User

#### Tab 2: Energy History
- ดูประวัติ Transaction ทั้งหมด
- Milestone Progress Simulator
- เพิ่ม Manual Transaction (Earn/Spend)
- Quick Spend Buttons (10E, 50E, 100E, 500E)

#### Tab 3: Offers & Promotions
- ดูสถานะ Promotion ทั้งหมด ($1 Deal, 40% Bonus, etc.)
- แสดงว่า promotion ไหนถูก shown/purchased แล้ว
- Reset Offers (ปลดล็อคให้เห็น promotion ใหม่)

#### Tab 4: Subscription & IAP
- ดูสถานะ Subscription
- Grant Subscription สำหรับทดสอบ
- Cancel Subscription
- ดูประวัติการซื้อ (IAP History)

#### Tab 5: Gamification State
- ดู Milestones Progress (10 ขั้น)
- จัดการ Streak
- ดู Ad Views quota
- Reset Milestones

### 2. **Test Scenarios**

Apply preset user states ได้ทันที:

- ✨ **New User Journey** - ผู้ใช้ใหม่เริ่มต้น
- ⚠️ **About to Break Streak** - กำลังจะขาด streak
- 🎯 **Ready for Tier Up** - ใกล้จะขึ้น tier
- 💳 **Subscription Churn Risk** - ยกเลิก subscription แล้ว
- 🐋 **High-Value Whale** - ผู้ใช้ VIP

### 3. **Bulk User Management**

สร้าง Test Users จำนวนมาก:
- ตั้งจำนวน 1-1000 users
- กำหนด Tier Distribution (%)
- สุ่มค่า Balance, Streak, Total Spent
- All users have `test_` prefix

### 4. **Audit Logs**

บันทึกทุก Admin Action:
- ใครทำอะไร เมื่อไหร่
- แสดง Before/After states
- Filter by Action Type
- Search by User ID

## 🚀 Quick Start

### การใช้งานพื้นฐาน

1. **ค้นหาผู้ใช้**
   - ไปที่ **Users** page
   - ค้นหาด้วย MiRO ID หรือ Device ID
   - คลิก "View Details"

2. **ทดสอบ Milestone Flow**
   - เปิด User Detail → **Energy History** tab
   - คลิก "Spend +100E"
   - ไปดูที่ **Gamification** tab → ดู milestone progress
   - ไปดูที่ **Offers** tab → ตรวจสอบว่า promotion แสดงหรือยัง

3. **ทดสอบ Tier Upgrade**
   - เปิด User Detail → **Profile** tab
   - คลิก "Set Tier" → เลือก Bronze
   - ดูที่ **Profile** tab → ยืนยันว่า tier เปลี่ยนแล้ว

4. **Apply Scenario**
   - ไปที่ **Test Scenarios** page
   - ใส่ User ID
   - เลือก Scenario ที่ต้องการ
   - คลิก "Apply Scenario"

## 📡 API Endpoints

### User Management APIs

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/users/:uid` | GET | Get user details |
| `/api/users/:uid/reset-to-new` | POST | Reset to new user state |
| `/api/users/:uid/set-tier` | POST | Set user tier |
| `/api/users/:uid/set-streak` | POST | Set streak days |
| `/api/users/:uid/adjust-balance` | POST | Adjust energy balance |
| `/api/users/:uid/reset-offers` | POST | Reset all offers |
| `/api/users/:uid/reset-milestones` | POST | Reset milestones |
| `/api/users/:uid/add-transaction` | POST | Add manual transaction |
| `/api/users/:uid/transactions` | GET | Get transaction history |
| `/api/users/:uid/apply-scenario` | POST | Apply test scenario |

### Bulk Operations APIs

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/users/bulk/create-test-users` | POST | Create test users in bulk |

### Audit APIs

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/admin/audit-logs` | GET | Get audit logs |

## 🧪 Testing Workflows

### Workflow 1: ทดสอบ Milestone #1 ($1 Deal)

1. Reset user to new
2. Go to Energy History tab
3. Spend 10E (trigger milestone #1)
4. Go to Offers tab
5. ✅ Verify: $1 Deal should be available

### Workflow 2: ทดสอบ Tier Upgrade (Bronze → Silver)

1. Set user tier to Bronze
2. Check total spent = 495E (5E away from Silver)
3. Go to Energy History tab
4. Spend 10E
5. ✅ Verify: User should upgrade to Silver

### Workflow 3: ทดสอบ Subscription Flow

1. Go to Subscription tab
2. Grant 30 days subscription
3. Test in mobile app → should see subscriber benefits
4. Cancel subscription
5. ✅ Verify: Winback offer should appear

### Workflow 4: ทดสอบ Streak Risk

1. Apply "About to Break Streak" scenario
2. Check last check-in = 23 hours ago
3. Test notification system
4. ✅ Verify: Should receive streak reminder

## 🎨 UI Components

### Created Components

```
admin-panel/src/components/users/
├── UserDetailModal.tsx              (Main modal with tabs)
└── user-detail-tabs/
    ├── ProfileTab.tsx               (Tab 1: Profile & Quick Actions)
    ├── EnergyHistoryTab.tsx         (Tab 2: Transactions & Milestones)
    ├── OffersTab.tsx                (Tab 3: Promotions State)
    ├── SubscriptionTab.tsx          (Tab 4: Subscription Management)
    └── GamificationTab.tsx          (Tab 5: Gamification State)
```

### Created Pages

```
admin-panel/src/app/(dashboard)/
├── test-scenarios/page.tsx          (Apply preset scenarios)
├── bulk-management/page.tsx         (Create bulk test users)
└── audit-logs/page.tsx              (View admin action logs)
```

## 📊 Data Schema

### Firestore Collections Used

- `users/{deviceId}` - User data
- `transactions/{id}` - Energy transactions
- `adminLogs/{id}` - Audit trail

### User Fields Modified

```typescript
{
  balance: number,
  tier: string,
  currentStreak: number,
  milestones: {
    totalSpent: number,
    claimedMilestones: string[],
    nextMilestoneIndex: number
  },
  offers: {
    firstPurchaseAvailable: boolean,
    firstPurchaseClaimed: boolean,
    // ... more offer fields
  },
  subscription: {
    status: string,
    expiryDate: Timestamp,
    // ... more subscription fields
  }
}
```

## 🔐 Security

- ทุก API ต้องผ่าน `checkAuth()` middleware
- Audit logs บันทึกทุก action
- Admin role verification (ตรวจสอบ email domain)

## 💡 Tips & Best Practices

1. **ใช้ Test Scenarios** สำหรับการทดสอบแบบรวดเร็ว
2. **ตรวจสอบ Audit Logs** หลังทำการเปลี่ยนแปลงข้อมูล
3. **ใช้ Bulk Management** สำหรับ load testing
4. **Reset Offers/Milestones** เมื่อต้องการทดสอบซ้ำ
5. **ใช้ Manual Transactions** เพื่อทดสอบ milestone triggers

## 🐛 Troubleshooting

### ปัญหาที่พบบ่อย

**Q: Milestone ไม่ trigger หลังจาก spend energy?**
- ตรวจสอบ `milestones.totalSpent` field
- ดูที่ Energy History tab → ยืนยันว่า transaction สร้างแล้ว
- ตรวจสอบ Backend Cloud Function logs

**Q: Promotion ไม่แสดงหลังจาก reach milestone?**
- ตรวจสอบ `offers.firstPurchaseAvailable` field
- Reset offers และลองใหม่
- ดู Backend logic ใน `offersV2.ts`

**Q: Test users ไม่ถูกสร้าง?**
- ตรวจสอบ Firestore security rules
- ดู Admin Logs สำหรับ error messages
- ตรวจสอบ Firestore quota limits

## 📝 Next Steps

Features ที่ควรเพิ่มในอนาคต:

- [ ] QR Code Quick Login (สแกนเข้า app ทันที)
- [ ] Export Transaction History เป็น CSV
- [ ] Bulk Delete Test Users
- [ ] Advanced Filters (by date range, tier, etc.)
- [ ] Real-time Updates (WebSocket/Firestore Listeners)
- [ ] User Comparison Tool (เทียบ 2 users)

## 🎓 การเรียนรู้เพิ่มเติม

- อ่าน `FIRESTORE_SCHEMA_V3.md` สำหรับ data structure
- อ่าน `02_BACKEND_SPEC.md` สำหรับ business logic
- อ่าน `03_FRONTEND_SPEC.md` สำหรับ frontend implementation

---

**Version:** 1.0.0  
**Last Updated:** February 20, 2026  
**Maintainer:** Admin Panel Team
