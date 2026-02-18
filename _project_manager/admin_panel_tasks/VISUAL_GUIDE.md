# Visual Guide — Admin Panel Architecture

เอกสารนี้อธิบายสถาปัตยกรรมและ data flow ของ Admin Panel

---

## 🏗️ สถาปัตยกรรมระบบ

```
┌─────────────────────────────────────────────────────────────┐
│                    Admin Panel (Next.js)                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐    │
│  │   Dashboard  │  │    Users     │  │    Config    │    │
│  │     Page     │  │     Page     │  │     Page     │    │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘    │
│         │                  │                  │             │
│         └──────────────────┼──────────────────┘             │
│                            │                                │
│                    ┌───────▼────────┐                      │
│                    │  API Routes    │                      │
│                    │  /api/*        │                      │
│                    └───────┬────────┘                      │
│                            │                                │
└────────────────────────────┼────────────────────────────────┘
                             │
                             │ Firebase Admin SDK
                             │
                    ┌────────▼────────┐
                    │   Firestore     │
                    │   Database      │
                    └─────────────────┘
                    │ users           │
                    │ transactions    │
                    │ config          │
                    └─────────────────┘
```

---

## 📊 Data Flow

### 1. Dashboard Page

```
User → Dashboard Page
         │
         ├─→ fetch('/api/dashboard/stats')
         │     │
         │     └─→ Firestore: count users, sum revenue
         │           │
         │           └─→ Return { totalUsers, activeUsers, ... }
         │
         ├─→ fetch('/api/dashboard/user-growth')
         │     │
         │     └─→ Firestore: query users by createdAt
         │           │
         │           └─→ Return { growth: [{date, users}] }
         │
         ├─→ fetch('/api/dashboard/streak-distribution')
         │     │
         │     └─→ Firestore: count by tier
         │           │
         │           └─→ Return { distribution: [...] }
         │
         └─→ fetch('/api/dashboard/recent-activities')
               │
               └─→ Firestore: query transactions
                     │
                     └─→ Return { activities: [...] }
```

---

### 2. User Management Page

```
User → Users Page
         │
         ├─→ Search by MiRO ID
         │     │
         │     └─→ fetch('/api/users/search?q=ABC123')
         │           │
         │           └─→ Firestore: query users.where('miroId', '==', ...)
         │                 │
         │                 └─→ Return { user: {...} }
         │
         ├─→ View User Detail
         │     │
         │     └─→ fetch('/api/users/[deviceId]')
         │           │
         │           └─→ Firestore: get user + transactions
         │                 │
         │                 └─→ Return { user, transactions }
         │
         ├─→ Top-up Energy
         │     │
         │     └─→ POST /api/users/[deviceId]/topup
         │           │
         │           └─→ Firestore: update balance + log transaction
         │                 │
         │                 └─→ Return { newBalance }
         │
         ├─→ Reset Streak
         │     │
         │     └─→ POST /api/users/[deviceId]/reset-streak
         │           │
         │           └─→ Firestore: update currentStreak = 0, tier = 'none'
         │                 │
         │                 └─→ Return { success: true }
         │
         └─→ Ban/Unban User
               │
               └─→ POST /api/users/[deviceId]/ban
                     │
                     └─→ Firestore: update isBanned, banReason
                           │
                           └─→ Return { success: true }
```

---

### 3. Config Management Page

```
User → Config Page
         │
         ├─→ Load Config
         │     │
         │     └─→ fetch('/api/config')
         │           │
         │           └─→ Firestore: get config doc (or return hardcoded)
         │                 │
         │                 └─→ Return { config: {...} }
         │
         └─→ Save Config
               │
               └─→ POST /api/config
                     │
                     ├─→ Firestore: set config doc
                     │     │
                     │     └─→ { promotions, dailyRewards, challenges, milestones }
                     │
                     └─→ Firestore: add config_history log
                           │
                           └─→ Return { success: true }
```

---

### 4. Subscription Management Page

```
User → Subscriptions Page
         │
         ├─→ Load Metrics
         │     │
         │     └─→ fetch('/api/subscriptions/metrics')
         │           │
         │           └─→ Firestore: count subscribers, calculate MRR, churn
         │                 │
         │                 └─→ Return { mrr, activeSubscribers, ... }
         │
         └─→ Load Subscribers List
               │
               └─→ fetch('/api/subscriptions/list?status=active')
                     │
                     └─→ Firestore: query users where isSubscriber = true
                           │
                           └─→ Return { subscribers: [...] }
```

---

## 🗂️ Firestore Collections

```
Firestore
├── users/
│   ├── {deviceId}/
│   │   ├── miroId: string
│   │   ├── balance: number
│   │   ├── tier: 'none' | 'bronze' | 'silver' | 'gold' | 'diamond'
│   │   ├── currentStreak: number
│   │   ├── longestStreak: number
│   │   ├── totalSpent: number
│   │   ├── totalPurchased: number
│   │   ├── totalEarned: number
│   │   ├── isSubscriber: boolean
│   │   ├── subscriptionStatus: 'active' | 'expired' | 'cancelled'
│   │   ├── subscriptionExpiryDate: timestamp
│   │   ├── isBanned: boolean
│   │   ├── banReason: string
│   │   ├── challenges: object
│   │   ├── milestones: object
│   │   ├── promotions: object
│   │   ├── createdAt: timestamp
│   │   └── lastUpdated: timestamp
│
├── transactions/
│   ├── {transactionId}/
│   │   ├── deviceId: string
│   │   ├── miroId: string
│   │   ├── type: 'purchase' | 'usage' | 'daily_checkin' | 'admin_topup' | ...
│   │   ├── amount: number
│   │   ├── balanceAfter: number
│   │   ├── description: string
│   │   ├── metadata: object
│   │   └── createdAt: timestamp
│
├── config/
│   ├── promotions/
│   │   ├── promotions: object
│   │   ├── dailyRewards: object
│   │   ├── challenges: object
│   │   ├── milestones: object
│   │   └── lastUpdated: timestamp
│
└── config_history/
    ├── {historyId}/
    │   ├── type: string
    │   ├── config: object
    │   └── changedAt: timestamp
```

---

## 🔄 Component Hierarchy

### Dashboard Page
```
DashboardPage
├── MetricCard (x4)
│   ├── Total Users
│   ├── Active Users
│   ├── Revenue
│   └── Subscribers
├── UserGrowthChart
│   └── LineChart (from recharts)
├── StreakDistribution
│   └── Tier badges + counts
└── RecentActivities
    └── Transaction list
```

### Users Page
```
UsersPage
├── UserSearch
│   ├── Input (search box)
│   └── Button (search)
└── UserDetailModal
    ├── User info cards
    ├── Action buttons (Topup, Reset, Ban)
    ├── Top-up form (conditional)
    └── Transactions list
```

### Config Page
```
ConfigPage
└── Tabs
    ├── Promotions Tab
    │   └── PromotionsForm
    │       ├── Welcome Offer inputs
    │       ├── Tier Upgrade inputs
    │       └── Welcome Back inputs
    ├── Daily Rewards Tab
    │   └── DailyRewardsForm
    │       └── Tier reward inputs
    └── Challenges Tab
        └── ChallengesForm
            ├── Log Meals inputs
            ├── Use AI inputs
            └── Milestone inputs
```

### Subscriptions Page
```
SubscriptionsPage
├── SubscriptionMetrics
│   └── MetricCard (x4)
│       ├── MRR
│       ├── Active Subscribers
│       ├── Expiring Soon
│       └── Churn Rate
└── SubscribersTable
    └── Table (rows = subscribers)
```

---

## 🔐 Security Considerations

### ⚠️ ปัจจุบัน (Basic Setup)
- ✅ Firebase Admin SDK (server-side only)
- ❌ ยังไม่มี authentication middleware
- ❌ ยังไม่มี role-based access control

### 🔒 ควรเพิ่ม (Future)
```typescript
// middleware.ts
export function middleware(request: NextRequest) {
  const session = getSession(request);
  
  // Check if authenticated
  if (!session) {
    return NextResponse.redirect('/login');
  }
  
  // Check if admin role
  if (!session.role === 'admin') {
    return NextResponse.json({ error: 'Forbidden' }, { status: 403 });
  }
  
  return NextResponse.next();
}
```

### 🛡️ Best Practices
1. **Never expose serviceAccountKey.json** ในฝั่ง client
2. **ใช้ environment variables** สำหรับ sensitive data
3. **Validate input** ใน API routes ทุกตัว
4. **Log admin actions** เพื่อ audit trail
5. **Rate limiting** ป้องกัน abuse

---

## 📊 State Management

### Client-side State
```typescript
// ใช้ React useState + useEffect
const [data, setData] = useState(null);
const [loading, setLoading] = useState(true);

useEffect(() => {
  fetch('/api/...')
    .then(res => res.json())
    .then(data => {
      setData(data);
      setLoading(false);
    });
}, []);
```

### Server-side State
```typescript
// API routes เป็น stateless
// ข้อมูลอยู่ใน Firestore
export async function GET(request: NextRequest) {
  const db = getFirestore();
  const snapshot = await db.collection('users').get();
  return NextResponse.json({ data: snapshot.docs });
}
```

---

## 🎯 Performance Tips

### 1. Firestore Queries
```typescript
// ❌ ไม่ดี: ดึงทุก user แล้วกรองใน code
const allUsers = await db.collection('users').get();
const activeUsers = allUsers.docs.filter(doc => doc.data().isActive);

// ✅ ดี: ใช้ where clause
const activeUsers = await db.collection('users').where('isActive', '==', true).get();
```

### 2. Pagination
```typescript
// ❌ ไม่ดี: ดึงทุกรายการ
const all = await db.collection('transactions').get();

// ✅ ดี: ใช้ limit
const first50 = await db.collection('transactions').limit(50).get();
```

### 3. Caching (Future)
```typescript
// ใช้ React Query หรือ SWR สำหรับ client-side caching
import useSWR from 'swr';

function Dashboard() {
  const { data, error } = useSWR('/api/dashboard/stats', fetcher);
  // จะ cache และ auto-revalidate
}
```

---

## 🚀 Deployment Flow

```
Local Development
    │
    ├─→ npm run dev (localhost:3000)
    ├─→ ทดสอบ features
    └─→ ทดสอบ APIs
    
    ↓ (git commit + push)
    
GitHub Repository
    │
    └─→ main branch
    
    ↓ (deploy command)
    
Cloud Run (Production)
    │
    ├─→ Build Docker image
    ├─→ Deploy container
    └─→ Get URL: https://admin-panel-xxx.run.app
```

---

## 📚 Additional Resources

### Documentation
- [Next.js Docs](https://nextjs.org/docs)
- [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup)
- [Recharts Docs](https://recharts.org/en-US/)
- [shadcn/ui](https://ui.shadcn.com/)

### Troubleshooting
ดู **Troubleshooting** section ในแต่ละ task file

---

**เอกสารนี้ช่วยให้เข้าใจภาพรวมของระบบ! กลับไปทำ task ต่อได้เลย 🚀**
