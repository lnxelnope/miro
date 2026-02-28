# Admin Panel Spec — Marketing Dashboard

> **สำหรับ:** Junior Developer  
> **Stack:** Next.js / React (admin-panel/)  
> **Priority:** Phase 5 (หลังจาก Frontend เสร็จ)

---

## สิ่งที่มีอยู่แล้ว (ไม่ต้องแก้)

- ~~User Management (ดูข้อมูล, ปรับ Balance, Ban)~~ → **อัปเกรดเป็น Enhanced User Management (ดูด้านล่าง)**
- Config (Daily Rewards, Challenges, Milestones, Promotions)
- Analytics (Streak Distribution, User Growth, Subscription Metrics)
- Fraud Detection

---

## 🎯 Enhanced User Management — สำหรับการทดสอบ (Priority สูง 🔴)

### หน้า: `/dashboard/users` (อัปเกรด)

#### **ส่วนที่ 1: User Search & Overview**

**Features:**
- Search by Email, UID, Phone
- Filter by Tier (Starter, Bronze, Silver, Gold, Diamond)
- Filter by Status (Active, Banned, Subscriber, Churned)
- Sort by: Join Date, Total Energy Spent, Tier, Streak

**แสดงตาราง:**
| Email | Tier | Balance | Streak | Total Spent | Subscription | Actions |
|-------|------|---------|--------|-------------|--------------|---------|
| user@example.com | Gold | 450E | 15🔥 | 2,340E | Premium | [View] [Edit] |

---

#### **ส่วนที่ 2: User Detail Panel** (คลิก View)

**Tab 1: Profile**
```
📧 Email: user@example.com
🆔 UID: abc123xyz
📱 Phone: +66812345678
📅 Joined: Jan 1, 2026
🎯 Tier: Gold (2,340E total)
⚡ Balance: 450E
🔥 Streak: 15 days
📍 Last Active: 2 hours ago
🚫 Status: Active
```

**Quick Actions (สำหรับทดสอบ):**
- 🔄 **Reset to New User** — ล้างทุกอย่างเหมือนเริ่มใหม่
- 🎚️ **Set Tier** — เลือก Starter/Bronze/Silver/Gold/Diamond
- ⚡ **Adjust Balance** — +/- Energy โดยตรง
- 🔥 **Set Streak** — กำหนด streak และ lastCheckInDate
- 🎁 **Reset Offers** — ปลดล็อคให้เห็น promotion ใหม่อีกครั้ง
- 🏆 **Reset Milestones** — ล้าง milestones claimed flags
- 📺 **Reset Ad Views** — เซ็ต adViews count
- 🔒 **Ban/Unban User**

---

**Tab 2: Energy History** (สำหรับทดสอบ Milestones)

**แสดงตาราง Transaction ทั้งหมด:**
| Date | Type | Amount | Balance After | Source | Notes |
|------|------|--------|---------------|--------|-------|
| Feb 20, 10:00 | spend | -20E | 450E | ai_chat | Chat with AI |
| Feb 20, 09:30 | earn | +50E | 470E | purchase | $1 Deal |
| Feb 19, 08:00 | earn | +15E | 420E | daily_reward | Day 15 🔥 |
| Feb 19, 07:00 | earn | +10E | 405E | ad_reward | Watched ad |
| Feb 18, 12:00 | spend | -30E | 395E | image_analysis | Food scan |

**Export:**
- 📥 Download CSV (สำหรับการวิเคราะห์)

**Manual Transaction (เพิ่มรายการทดสอบ):**
- Type: `earn` / `spend`
- Amount: [___] E
- Source: `manual_test`, `test_milestone`, `test_purchase`, etc.
- Note: [_______________]
- ✅ Add Transaction

**Milestones Progress Simulator:**
```
Current Total Spent: 2,340E
Next Milestone: 2,500E (160E remaining)

Quick Test Buttons:
[ Spend +100E ]  [ Spend +500E ]  [ Trigger Next Milestone ]
```

---

**Tab 3: Offers & Promotions State**

**ดูสถานะ Promotion ที่ผู้ใช้เห็น:**
| Promotion | Shown? | Purchased? | Date Shown | Date Purchased |
|-----------|--------|------------|------------|----------------|
| $1 Deal (Milestone 1) | ✅ | ✅ | Jan 5 | Jan 5 |
| 40% Bonus (Milestone 5) | ✅ | ❌ | Jan 10 | - |
| Bronze Tier Promo | ❌ | ❌ | - | - |
| Flash Sale 50% | ✅ | ✅ | Feb 15 | Feb 15 |

**Reset Actions:**
- 🔄 **Reset All Offers** — ปลดล็อคทุก promotion ให้แสดงใหม่
- ⚙️ **Force Show Specific Offer** — เลือก promotion ให้แสดง
- ❌ **Mark as Not Purchased** — ยกเลิกสถานะซื้อ (ทดสอบการซื้อซ้ำ)

---

**Tab 4: Subscription & IAP**

**Subscription Status:**
```
Status: Active / Cancelled / Expired / Never Subscribed
Plan: Premium Monthly ($4.99)
Started: Jan 15, 2026
Next Billing: Feb 15, 2026
Cancelled: No
Billing History: [View 3 transactions]
```

**IAP History:**
| Date | Product | Price | Energy | Platform | Receipt |
|------|---------|-------|--------|----------|---------|
| Feb 15 | 200_energy_flash | $2.99 | 200E | Android | [Verify] |
| Jan 5 | 50_energy_first | $0.99 | 50E | iOS | [Verify] |

**Test Actions:**
- ✅ **Grant Subscription** — เปิด subscription ทดสอบ (กำหนดวันหมดอายุ)
- ❌ **Cancel Subscription** — ทดสอบ cancel flow
- 💳 **Simulate IAP** — เพิ่ม transaction ทดสอบ (ไม่เรียกเก็บเงินจริง)

---

**Tab 5: Gamification State**

**Challenges:**
```
Current Week Challenge: Scan 5 foods (Progress: 3/5)
Status: Active
Reward: 100E
Expires: 23:59 today

Actions:
[ Set Progress to 4/5 ]  [ Complete Challenge ]  [ Reset Challenge ]
```

**Milestones:**
| Milestone | Threshold | Reward | Claimed? | Date Claimed |
|-----------|-----------|--------|----------|--------------|
| #1 | 10E | $1 Deal | ✅ | Jan 5 |
| #2 | 50E | 20E Bonus | ✅ | Jan 6 |
| #3 | 100E | 30E Bonus | ✅ | Jan 8 |
| #4 | 250E | 50E + Badge | ✅ | Jan 12 |
| #5 | 500E | 40% Promo | ✅ | Jan 20 |
| #6 | 1,000E | 100E + Tier Up | ✅ | Feb 1 |
| #7 | 2,000E | 150E | ✅ | Feb 10 |
| #8 | 2,500E | 30% Promo | ❌ | - |
| #9 | 5,000E | 300E | ❌ | - |
| #10 | 10,000E | VIP | ❌ | - |

**Actions:**
- 🔄 **Reset All Milestones** — ล้าง claimed flags ทั้งหมด
- ✅ **Mark as Claimed** — ทำเครื่องหมายว่าได้รับรางวัลแล้ว
- ❌ **Mark as Unclaimed** — ทดสอบการรับรางวัลซ้ำ

**Streak:**
```
Current Streak: 15 days 🔥
Last Check-in: Feb 20, 2026 08:00
Next Check-in Available: Feb 21, 2026 00:00

Actions:
[ Set Streak to 0 ]  [ Set Streak to 7 ]  [ Set Streak to 30 ]
[ Break Streak ]  [ Set Last Check-in Date ]
```

**Ad Rewards:**
```
Ads Watched Today: 3/5
Total Ads Watched: 47

Actions:
[ Reset Daily Count ]  [ Set Count to 4/5 ]  [ Max Out (5/5) ]
```

---

#### **ส่วนที่ 3: Bulk User Management**

**หน้า:** `/dashboard/users/bulk`

**Features:**
- 🎯 **Create Test Users** — สร้าง dummy users จำนวนมาก
  - จำนวน: [___] users
  - Tier Distribution: Starter 40%, Bronze 30%, Silver 20%, Gold 8%, Diamond 2%
  - Random Balance: 0-1000E
  - Random Streak: 0-30 days
  - ✅ Create

- 📊 **Apply Filter & Bulk Actions:**
  - Filter: Tier = Gold, Streak > 10
  - Actions:
    - ⚡ Add Energy to All
    - 🎁 Reset Offers for All
    - 📧 Send Push Notification
    - 🗑️ Delete Test Users

---

#### **ส่วนที่ 4: Testing Scenarios (Quick Presets)**

**หน้า:** `/dashboard/users/test-scenarios`

**Preset Scenarios สำหรับทดสอบ:**

**1. New User Journey**
```
✨ Reset user to brand new state
- Balance: 0E
- Tier: Starter
- Streak: 0
- All milestones: unclaimed
- All offers: unseen
- Subscription: none

[ Apply to User: ___________ ]
```

**2. About to Break Streak**
```
⚠️ High streak risk scenario
- Streak: 14 days
- Last check-in: 23 hours ago
- Balance: 5E (low energy)
- Next milestone: 50E away

[ Apply to User: ___________ ]
```

**3. Ready for Tier Up**
```
🎯 Bronze → Silver promotion test
- Total spent: 495E (5E away from 500E)
- Current tier: Bronze
- Balance: 100E
- All Bronze offers: purchased

[ Apply to User: ___________ ]
```

**4. Subscription Churn Risk**
```
💳 Cancelled subscriber
- Subscription: Cancelled (expires in 3 days)
- Last active: 5 days ago
- Streak: 0 (broken)
- Balance: 0E

[ Apply to User: ___________ ]
```

**5. High-Value Whale**
```
🐋 VIP User
- Tier: Diamond
- Total spent: 15,000E
- Balance: 500E
- Subscription: Active Premium
- All milestones: claimed

[ Apply to User: ___________ ]
```

---

## API Endpoints ที่ต้องสร้าง (Backend)

### User Management APIs

**GET /api/admin/users**
- Query: `?tier=gold&status=active&limit=50`
- Response: List of users with summary

**GET /api/admin/users/:uid**
- Response: Full user profile + computed fields (tier, totalSpent, etc.)

**POST /api/admin/users/:uid/reset-to-new**
- ล้างข้อมูลผู้ใช้กลับไปเหมือนใหม่

**POST /api/admin/users/:uid/set-tier**
- Body: `{ tier: "gold" }`
- อัปเดต tier และ totalSpent ให้สอดคล้องกัน

**POST /api/admin/users/:uid/adjust-balance**
- Body: `{ amount: 100, reason: "test" }`
- เพิ่ม/ลด energy + สร้าง transaction log

**POST /api/admin/users/:uid/set-streak**
- Body: `{ streak: 15, lastCheckIn: "2026-02-20T08:00:00Z" }`

**POST /api/admin/users/:uid/reset-offers**
- ล้าง offers, offersShown, offersPurchased

**POST /api/admin/users/:uid/reset-milestones**
- ล้าง milestones, milestonesClaimedAt

**POST /api/admin/users/:uid/reset-ads**
- เซ็ต adViews, lastAdViewDate

**GET /api/admin/users/:uid/transactions**
- Query: `?limit=100&offset=0`
- Response: Transaction history

**POST /api/admin/users/:uid/transactions**
- Body: `{ type: "earn|spend", amount: 50, source: "manual_test", note: "..." }`
- สร้าง transaction ใหม่ + อัปเดต balance

**POST /api/admin/users/:uid/grant-subscription**
- Body: `{ plan: "premium_monthly", expiresAt: "2026-03-20" }`

**POST /api/admin/users/:uid/cancel-subscription**
- ยกเลิก subscription

**POST /api/admin/users/:uid/apply-scenario**
- Body: `{ scenario: "new_user" | "streak_risk" | "tier_up" | "churn_risk" | "whale" }`
- Apply preset scenario

**POST /api/admin/users/bulk/create-test-users**
- Body: `{ count: 100, tierDistribution: {...} }`
- สร้าง test users

---

## Firestore Security Rules (Admin-only)

```javascript
// admin-panel APIs ต้องใช้ Firebase Admin SDK
// ไม่ควรให้ client เข้าถึงโดยตรง
// ทุก API ต้องตรวจสอบ admin token ก่อน

match /users/{uid} {
  allow read, write: if isAdmin(request.auth.token);
}

match /transactions/{txId} {
  allow read, write: if isAdmin(request.auth.token);
}

function isAdmin(token) {
  return token != null && 
         token.email != null && 
         token.email.matches('.*@yourdomain.com');
  // หรือเช็ค custom claim: token.admin == true
}
```

---

## ต้องเพิ่ม — Priority สูง 🔴

### A1. Promotion Conversion Rate

**หน้า:** `/dashboard/analytics/promotions`

**แสดง:**
| Promotion | Times Shown | Purchased | Conversion % | Revenue |
|-----------|------------|-----------|-------------|---------|
| $1 = 200E | 1,234 | 456 | 36.9% | $456 |
| 40% Bonus | 456 | 123 | 27.0% | $614 |
| Tier Promo (Bronze) | 890 | 67 | 7.5% | $xxx |
| ... | ... | ... | ... | ... |

**Data source:** Firestore `transactions` collection, group by promotion type

**Filter:** Date range (7d, 30d, 90d, custom)

### A2. Revenue per User (ARPU)

**หน้า:** `/dashboard/analytics/revenue`

**แสดง:**
- ARPU (Average Revenue Per User) — total revenue ÷ total users
- ARPPU (Average Revenue Per Paying User) — total revenue ÷ paying users
- Paying user % — paying users ÷ total users
- Revenue by source: IAP vs Subscription vs Ads
- Revenue trend chart (daily/weekly/monthly)

**Data source:** Firestore `transactions` + Google Play revenue reports

### A3. Energy Purchase Funnel

**หน้า:** `/dashboard/analytics/funnel`

**แสดง Funnel chart:**
```
Registered Users:          10,000  (100%)
    ↓
Used 10E (Milestone #1):   7,500  (75%)
    ↓
Saw $1 Offer:               7,500  (75%)
    ↓
Purchased $1 Deal:          2,250  (22.5%)  ← First Purchase Rate
    ↓
Saw 40% Bonus:              2,250  (22.5%)
    ↓
Purchased 40% Bonus:          675  (6.75%)  ← Second Purchase Rate
    ↓
Subscribed:                    338  (3.38%)  ← Subscription Rate
```

**Data source:** Firestore user flags (milestones, offers, subscription)

### A4. Push Notification Campaign

**หน้า:** `/dashboard/campaigns/push`

**แสดง:**
- Active scheduled notifications
- Sent/Delivered/Opened counts
- Send custom notification (to all users or filtered segment)
- History log

### A5. Flash Sale / Custom Promo

**หน้า:** `/dashboard/campaigns/promotions`

**Features:**
- สร้าง promo ใหม่ (name, discount %, duration, target segment)
- ตั้งเวลา start/end
- Toggle active/inactive
- View performance (shown, purchased, revenue)

---

## ต้องเพิ่ม — Priority กลาง 🟡

### B1. Tier Distribution Chart

**หน้า:** `/dashboard/analytics/tiers`

**แสดง:** Pie chart แสดงสัดส่วน users ในแต่ละ tier
```
Starter: 45%  |  Bronze: 25%  |  Silver: 18%  |  Gold: 8%  |  Diamond: 4%
```

### B2. Daily/Weekly Active Users

**หน้า:** `/dashboard/analytics/engagement`

**แสดง:**
- DAU (Daily Active Users) trend chart
- WAU (Weekly Active Users) trend chart
- MAU (Monthly Active Users)
- Retention rate (Day 1, 7, 14, 30)

### B3. A/B Test Management

**หน้า:** `/dashboard/campaigns/ab-tests`

**Features:**
- สร้าง A/B test (variant A/B, % allocation)
- View results (conversion, revenue per variant)
- End test + apply winner

### B4. Churn Risk Users

**หน้า:** `/dashboard/retention/churn-risk`

**แสดง:** List ของ users ที่:
- Streak > 7 แต่ไม่ login มา 1 วัน (about to break)
- Ex-subscriber ที่ expired
- High-value users ที่ usage ลดลง

### B5. Rewarded Ads Analytics

**หน้า:** `/dashboard/analytics/ads`

**แสดง:**
- Total ad views/day
- Ad views per user average
- Fill rate (ads loaded vs requested)
- Estimated ad revenue
- Conversion: ad users → purchasers

### B6. Milestone Config (Update)

**หน้า:** `/dashboard/config` (เพิ่มใน existing config page)

**แสดง:**
- ตาราง 10 milestones (threshold, reward) — editable
- Preview สูตร cashback %
- Save → update Firestore config

---

## Firestore Collections ที่ต้องอ่าน

| Collection | ข้อมูล |
|------------|--------|
| `users/{id}` | balance, tier, streak, offers, milestones, adViews, subscription |
| `transactions` | ทุก energy transaction (purchase, reward, spend, ad_reward) |
| `config` | system settings, promotion config |
| `adminLogs` | (ใหม่) บันทึกทุก admin action เพื่อ audit trail |

---

## 🔐 Admin Authentication & Authorization

### Admin Role Setup

**ใช้ Firebase Custom Claims:**
```javascript
// ตั้งค่า admin role
admin.auth().setCustomUserClaims(uid, { admin: true });
```

**หรือใช้ Email Whitelist:**
- เก็บรายชื่อ admin emails ใน Firestore `config/adminEmails`
- ตรวจสอบทุกครั้งที่เรียก admin API

### Audit Log

**ทุก admin action ต้องบันทึกใน `adminLogs` collection:**
```typescript
{
  adminUid: "admin123",
  adminEmail: "admin@yourdomain.com",
  action: "reset_user_to_new",
  targetUid: "user456",
  targetEmail: "user@example.com",
  details: {
    previousBalance: 450,
    newBalance: 0,
    previousTier: "Gold",
    newTier: "Starter"
  },
  timestamp: "2026-02-20T10:30:00Z",
  ipAddress: "1.2.3.4"
}
```

**แสดง Audit Log ในหน้า:**
`/dashboard/admin/audit-logs`

| Time | Admin | Action | Target User | Details |
|------|-------|--------|-------------|---------|
| 10:30 | admin@x.com | Reset to New | user@y.com | Tier: Gold→Starter, Balance: 450→0 |
| 10:25 | admin@x.com | Adjust Balance | user@z.com | +500E (test) |

---

## 📱 Mobile Testing Integration

### QR Code Quick Login (สำหรับทดสอบ)

**หน้า:** `/dashboard/users/:uid/qr-login`

**สร้าง QR Code ที่มี:**
- Custom token สำหรับ user นั้นๆ
- URL: `miroapp://test-login?token=xxx`

**ใช้งาน:**
1. Admin เปิด User Detail Panel
2. คลิก "QR Login"
3. สแกน QR ด้วย app บนมือถือ
4. App auto-login เป็น user นั้นๆ ทันที

**ประโยชน์:** ทดสอบ user experience ต่างๆได้รวดเร็ว โดยไม่ต้องสร้าง account จริง

---

## 🧪 Testing Workflow Example

### Scenario: ทดสอบ Milestone #8 (2,500E)

**ขั้นตอน:**

1. **สร้าง Test User:**
   - ไปที่ `/dashboard/users/bulk`
   - Create 1 user, Tier: Gold, Balance: 100E, Total Spent: 2,400E

2. **Set ผู้ใช้ให้ใกล้ Milestone:**
   - เปิด User Detail → Tab "Gamification State"
   - ตรวจสอบ: Milestone #8 (2,500E) = Unclaimed, ต้องใช้อีก 100E

3. **Simulate Spending:**
   - ไปที่ Tab "Energy History"
   - Click "Spend +100E" → เลือก source: `test_milestone`
   - ตรวจสอบ: Total Spent = 2,500E

4. **ตรวจสอบว่า Backend ทริกเกอร์ Milestone:**
   - Reload page
   - ดูที่ Tab "Gamification State"
   - Milestone #8 ควร Claimed? = ✅
   - ดูที่ Tab "Offers & Promotions State"
   - ควรมี "30% Promo" แสดงใน promotion list

5. **ทดสอบบน Mobile:**
   - Click "QR Login"
   - สแกน QR ด้วย app
   - ตรวจสอบว่า popup แสดง promotion 30% off

6. **Reset และทดสอบซ้ำ:**
   - Click "Reset Milestones"
   - Click "Reset Offers"
   - ทำขั้นตอนที่ 3-5 อีกครั้ง

---

## 📊 Dashboard Overview (Homepage)

**หน้า:** `/dashboard` (หน้าแรกเมื่อเข้า admin panel)

**แสดง Key Metrics:**
```
┌─────────────────────────────────────────────────────────┐
│  Today's Snapshot                                       │
├─────────────────────────────────────────────────────────┤
│  💰 Revenue:      $1,234.56  (+12% vs yesterday)       │
│  👥 Active Users: 4,567       (+5%)                     │
│  ⚡ Energy Sold:  45,678E     (+8%)                     │
│  📺 Ads Watched:  12,345      (+15%)                    │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  Quick Links                                            │
├─────────────────────────────────────────────────────────┤
│  [Analytics] [User Management] [Campaigns] [Config]     │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  Recent Admin Actions                                   │
├─────────────────────────────────────────────────────────┤
│  • admin@x.com created 100 test users (2 min ago)      │
│  • admin@y.com adjusted balance for user@z.com          │
│  • admin@x.com launched Flash Sale 50% (1 hour ago)    │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  Alerts & Notifications                                 │
├─────────────────────────────────────────────────────────┤
│  ⚠️ 23 users at risk of breaking streak (>10 days)     │
│  💳 12 subscriptions expiring in 3 days                 │
│  🐛 5 failed IAP verifications in last hour             │
└─────────────────────────────────────────────────────────┘
```

---

## 🎨 UI/UX Guidelines

### Design System
- ใช้ Tailwind CSS + shadcn/ui components
- Dark mode support
- Responsive (desktop-first, mobile ดูได้แต่อาจไม่ optimize เต็มที่)

### Color Coding
- 🟢 Green: Positive metrics, Active users, Success actions
- 🔴 Red: Negative metrics, Banned users, Failed transactions
- 🟡 Yellow: Warning, Churn risk, Expiring soon
- 🔵 Blue: Info, Neutral actions
- ⚪ Gray: Inactive, Disabled

### Loading States
- ใช้ skeleton loaders แทน spinner
- Show progress bar สำหรับ bulk actions

### Error Handling
- Toast notifications สำหรับ success/error
- Confirmation dialog สำหรับ destructive actions (delete, reset, ban)
- Inline validation สำหรับ forms

---

## 🚀 Implementation Priority

### Phase 1: Core User Management (Week 1-2)
- [x] User Search & List
- [x] User Detail Panel (5 tabs)
- [x] Quick Actions (Reset, Set Tier, Adjust Balance, etc.)
- [x] Energy History
- [x] API endpoints

### Phase 2: Testing Tools (Week 2-3)
- [ ] Test Scenarios (5 presets)
- [ ] Bulk User Management
- [ ] QR Quick Login
- [ ] Manual Transaction Creator
- [ ] Milestone Progress Simulator

### Phase 3: Analytics & Campaigns (Week 3-4)
- [ ] Promotion Conversion Rate (A1)
- [ ] Revenue per User (A2)
- [ ] Energy Purchase Funnel (A3)
- [ ] Push Notification Campaign (A4)
- [ ] Flash Sale / Custom Promo (A5)

### Phase 4: Advanced Features (Week 4+)
- [ ] Tier Distribution Chart (B1)
- [ ] DAU/WAU/MAU (B2)
- [ ] A/B Test Management (B3)
- [ ] Churn Risk Users (B4)
- [ ] Rewarded Ads Analytics (B5)
- [ ] Milestone Config (B6)
- [ ] Audit Log Viewer
- [ ] Dashboard Overview

---

## ✅ Checklist ก่อน Deploy

- [ ] ตรวจสอบ admin authentication ทำงาน
- [ ] Firestore Security Rules ถูกต้อง (admin-only)
- [ ] Audit log บันทึกทุก action
- [ ] Test ทุก API endpoint
- [ ] Test ทุก Quick Action (Reset, Set Tier, etc.)
- [ ] Test QR Login บนมือถือ
- [ ] Test Bulk Actions
- [ ] Error handling + confirmation dialogs
- [ ] Mobile responsive (พอดูได้)
- [ ] Performance: ตาราง pagination + lazy loading
- [ ] Documentation: API docs + User guide

---

## 📚 References

- Firestore Schema: `FIRESTORE_SCHEMA_V3.md`
- Backend Spec: `02_BACKEND_SPEC.md`
- Frontend Spec: `03_FRONTEND_SPEC.md`
- Marketing Blueprint: `ENERGY_MARKETING_BLUEPRINT.md`
