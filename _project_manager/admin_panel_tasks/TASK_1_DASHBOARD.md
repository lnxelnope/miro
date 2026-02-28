# Task 1: Dashboard Metrics — หน้าแดชบอร์ดแสดงสถิติ

**ระยะเวลา:** 4 ชั่วโมง  
**ความยาก:** ⭐⭐☆☆☆ (ง่าย - copy code ได้เลย)

---

## 🎯 เป้าหมาย

สร้างหน้า Dashboard แสดง:
1. **Metric Cards** — Total Users, Active Users, Total Revenue, Active Subscribers
2. **User Growth Chart** — กราฟจำนวน users เพิ่มขึ้นแต่ละวัน
3. **Streak Distribution** — จำนวน users แต่ละ tier
4. **Recent Activities** — transaction log ล่าสุด

---

## 📸 ตัวอย่างหน้าตา

```
┌─────────────────────────────────────────────────────┐
│  📊 Total Users    👥 Active Users                  │
│     1,234              890                           │
│                                                      │
│  💰 Revenue        💎 Subscribers                   │
│     ฿12,345           45                            │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│  📈 User Growth (Last 30 Days)                      │
│      [กราฟเส้น]                                     │
└─────────────────────────────────────────────────────┘

┌──────────────┐  ┌─────────────────────────────────┐
│ 🔥 Tiers     │  │ 📋 Recent Activities            │
│ Diamond: 12  │  │ • User ABC topup 100 Energy     │
│ Gold: 45     │  │ • User XYZ purchased package    │
│ Silver: 123  │  │ • User DEF daily check-in       │
└──────────────┘  └─────────────────────────────────┘
```

---

## 📝 Checklist

- [ ] Step 1: สร้าง API endpoints (4 ตัว)
- [ ] Step 2: สร้าง React components (4 ตัว)
- [ ] Step 3: รวมใน Dashboard page
- [ ] Step 4: Test ทุก metric

---

## Step 1: สร้าง API Endpoints

### 1.1 Overall Stats API

**ไฟล์:** `admin-panel/src/app/api/dashboard/stats/route.ts`

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { getFirestore } from 'firebase-admin/firestore';
import { initAdmin } from '@/lib/firebase-admin';

export async function GET(request: NextRequest) {
  try {
    initAdmin();
    const db = getFirestore();

    // Count total users
    const usersSnapshot = await db.collection('users').count().get();
    const totalUsers = usersSnapshot.data().count;

    // Count active users (checked in last 7 days)
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
    const activeUsersSnapshot = await db
      .collection('users')
      .where('lastCheckInDate', '>=', sevenDaysAgo.toISOString().split('T')[0])
      .count()
      .get();
    const activeUsers = activeUsersSnapshot.data().count;

    // Sum total revenue (from transactions)
    const purchasesSnapshot = await db
      .collection('transactions')
      .where('type', '==', 'purchase')
      .get();
    
    let totalRevenue = 0;
    purchasesSnapshot.docs.forEach((doc) => {
      const data = doc.data();
      // Assuming each purchase has a 'revenue' field (in THB)
      // If not, calculate from energy amount
      totalRevenue += data.revenue || 0;
    });

    // Count active subscribers
    const subscribersSnapshot = await db
      .collection('users')
      .where('isSubscriber', '==', true)
      .where('subscriptionStatus', '==', 'active')
      .count()
      .get();
    const activeSubscribers = subscribersSnapshot.data().count;

    return NextResponse.json({
      success: true,
      stats: {
        totalUsers,
        activeUsers,
        totalRevenue,
        activeSubscribers,
      },
    });
  } catch (error: any) {
    console.error('Error fetching stats:', error);
    return NextResponse.json(
      { error: error.message },
      { status: 500 }
    );
  }
}
```

**บันทึกไฟล์แล้ว test:**
```powershell
# ใน admin-panel directory
npm run dev
```

เปิดเบราว์เซอร์: `http://localhost:3000/api/dashboard/stats`

ต้องเห็น JSON:
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

### 1.2 User Growth API

**ไฟล์:** `admin-panel/src/app/api/dashboard/user-growth/route.ts`

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { getFirestore } from 'firebase-admin/firestore';
import { initAdmin } from '@/lib/firebase-admin';

export async function GET(request: NextRequest) {
  try {
    initAdmin();
    const db = getFirestore();

    const days = parseInt(request.nextUrl.searchParams.get('days') || '30');

    // Get user creation dates for last N days
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const usersSnapshot = await db
      .collection('users')
      .where('createdAt', '>=', startDate)
      .orderBy('createdAt', 'asc')
      .get();

    // Group by date
    const growthByDate: Record<string, number> = {};
    
    usersSnapshot.docs.forEach((doc) => {
      const data = doc.data();
      const date = data.createdAt?.toDate?.();
      if (date) {
        const dateStr = date.toISOString().split('T')[0];
        growthByDate[dateStr] = (growthByDate[dateStr] || 0) + 1;
      }
    });

    // Convert to array
    const growth = Object.entries(growthByDate).map(([date, count]) => ({
      date,
      users: count,
    }));

    return NextResponse.json({
      success: true,
      growth,
    });
  } catch (error: any) {
    console.error('Error fetching user growth:', error);
    return NextResponse.json(
      { error: error.message },
      { status: 500 }
    );
  }
}
```

**Test:** `http://localhost:3000/api/dashboard/user-growth?days=30`

---

### 1.3 Streak Distribution API

**ไฟล์:** `admin-panel/src/app/api/dashboard/streak-distribution/route.ts`

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { getFirestore } from 'firebase-admin/firestore';
import { initAdmin } from '@/lib/firebase-admin';

export async function GET(request: NextRequest) {
  try {
    initAdmin();
    const db = getFirestore();

    // Count users by tier
    const tiers = ['none', 'bronze', 'silver', 'gold', 'diamond'];
    const distribution: Record<string, number> = {};

    for (const tier of tiers) {
      const snapshot = await db
        .collection('users')
        .where('tier', '==', tier)
        .count()
        .get();
      distribution[tier] = snapshot.data().count;
    }

    return NextResponse.json({
      success: true,
      distribution: [
        { tier: 'Starter', count: distribution.none || 0 },
        { tier: 'Bronze', count: distribution.bronze || 0 },
        { tier: 'Silver', count: distribution.silver || 0 },
        { tier: 'Gold', count: distribution.gold || 0 },
        { tier: 'Diamond', count: distribution.diamond || 0 },
      ],
    });
  } catch (error: any) {
    console.error('Error fetching streak distribution:', error);
    return NextResponse.json(
      { error: error.message },
      { status: 500 }
    );
  }
}
```

**Test:** `http://localhost:3000/api/dashboard/streak-distribution`

---

### 1.4 Recent Activities API

**ไฟล์:** `admin-panel/src/app/api/dashboard/recent-activities/route.ts`

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { getFirestore } from 'firebase-admin/firestore';
import { initAdmin } from '@/lib/firebase-admin';

export async function GET(request: NextRequest) {
  try {
    initAdmin();
    const db = getFirestore();

    const limit = parseInt(request.nextUrl.searchParams.get('limit') || '20');

    const transactionsSnapshot = await db
      .collection('transactions')
      .orderBy('createdAt', 'desc')
      .limit(limit)
      .get();

    const activities = transactionsSnapshot.docs.map((doc) => {
      const data = doc.data();
      return {
        id: doc.id,
        type: data.type,
        amount: data.amount,
        description: data.description,
        miroId: data.miroId,
        createdAt: data.createdAt?.toDate?.()?.toISOString() || null,
      };
    });

    return NextResponse.json({
      success: true,
      activities,
    });
  } catch (error: any) {
    console.error('Error fetching recent activities:', error);
    return NextResponse.json(
      { error: error.message },
      { status: 500 }
    );
  }
}
```

**Test:** `http://localhost:3000/api/dashboard/recent-activities?limit=20`

---

## ✅ Checkpoint 1: Test ทุก API

เปิดเบราว์เซอร์ test 4 URLs:
- ✅ `/api/dashboard/stats`
- ✅ `/api/dashboard/user-growth?days=30`
- ✅ `/api/dashboard/streak-distribution`
- ✅ `/api/dashboard/recent-activities?limit=20`

ทุก URL ต้อง return JSON ถูกต้อง ไม่ error!

---

## Step 2: สร้าง React Components

### 2.1 Metric Card Component

**ไฟล์:** `admin-panel/src/components/dashboard/MetricCard.tsx`

```typescript
interface MetricCardProps {
  title: string;
  value: string | number;
  icon: React.ReactNode;
  description?: string;
}

export function MetricCard({ title, value, icon, description }: MetricCardProps) {
  return (
    <div className="bg-white rounded-lg shadow p-6">
      <div className="flex items-center justify-between">
        <div>
          <p className="text-sm font-medium text-gray-600">{title}</p>
          <p className="text-3xl font-bold text-gray-900 mt-2">{value}</p>
          {description && (
            <p className="text-xs text-gray-500 mt-1">{description}</p>
          )}
        </div>
        <div className="text-4xl">{icon}</div>
      </div>
    </div>
  );
}
```

---

### 2.2 User Growth Chart

**ไฟล์:** `admin-panel/src/components/dashboard/UserGrowthChart.tsx`

```typescript
'use client';

import { useEffect, useState } from 'react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

export function UserGrowthChart() {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch('/api/dashboard/user-growth?days=30')
      .then((res) => res.json())
      .then((json) => {
        setData(json.growth || []);
        setLoading(false);
      })
      .catch((err) => {
        console.error(err);
        setLoading(false);
      });
  }, []);

  if (loading) return <div className="text-center py-8">Loading...</div>;

  return (
    <div className="bg-white rounded-lg shadow p-6">
      <h3 className="text-lg font-semibold mb-4">📈 User Growth (Last 30 Days)</h3>
      <ResponsiveContainer width="100%" height={300}>
        <LineChart data={data}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="date" />
          <YAxis />
          <Tooltip />
          <Line type="monotone" dataKey="users" stroke="#8884d8" strokeWidth={2} />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}
```

---

### 2.3 Streak Distribution

**ไฟล์:** `admin-panel/src/components/dashboard/StreakDistribution.tsx`

```typescript
'use client';

import { useEffect, useState } from 'react';

export function StreakDistribution() {
  const [distribution, setDistribution] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch('/api/dashboard/streak-distribution')
      .then((res) => res.json())
      .then((json) => {
        setDistribution(json.distribution || []);
        setLoading(false);
      })
      .catch((err) => {
        console.error(err);
        setLoading(false);
      });
  }, []);

  if (loading) return <div className="text-center py-8">Loading...</div>;

  const tierColors: Record<string, string> = {
    Starter: 'bg-gray-200 text-gray-800',
    Bronze: 'bg-orange-200 text-orange-800',
    Silver: 'bg-gray-300 text-gray-800',
    Gold: 'bg-yellow-200 text-yellow-800',
    Diamond: 'bg-blue-200 text-blue-800',
  };

  return (
    <div className="bg-white rounded-lg shadow p-6">
      <h3 className="text-lg font-semibold mb-4">🔥 Streak Distribution</h3>
      <div className="space-y-3">
        {distribution.map((item: any) => (
          <div key={item.tier} className="flex items-center justify-between">
            <span className={`px-3 py-1 rounded-full text-sm font-medium ${tierColors[item.tier] || 'bg-gray-100'}`}>
              {item.tier}
            </span>
            <span className="text-lg font-bold">{item.count}</span>
          </div>
        ))}
      </div>
    </div>
  );
}
```

---

### 2.4 Recent Activities

**ไฟล์:** `admin-panel/src/components/dashboard/RecentActivities.tsx`

```typescript
'use client';

import { useEffect, useState } from 'react';

export function RecentActivities() {
  const [activities, setActivities] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch('/api/dashboard/recent-activities?limit=10')
      .then((res) => res.json())
      .then((json) => {
        setActivities(json.activities || []);
        setLoading(false);
      })
      .catch((err) => {
        console.error(err);
        setLoading(false);
      });
  }, []);

  if (loading) return <div className="text-center py-8">Loading...</div>;

  const typeEmoji: Record<string, string> = {
    purchase: '💰',
    usage: '⚡',
    daily_checkin: '✅',
    tier_upgrade_reward: '🎊',
    admin_topup: '🔧',
  };

  return (
    <div className="bg-white rounded-lg shadow p-6">
      <h3 className="text-lg font-semibold mb-4">📋 Recent Activities</h3>
      <div className="space-y-2">
        {activities.map((activity: any) => (
          <div key={activity.id} className="flex items-start justify-between py-2 border-b last:border-0">
            <div className="flex-1">
              <p className="text-sm">
                <span className="mr-2">{typeEmoji[activity.type] || '📝'}</span>
                {activity.description}
              </p>
              <p className="text-xs text-gray-500 mt-1">
                {activity.miroId} • {new Date(activity.createdAt).toLocaleString()}
              </p>
            </div>
            <span className={`text-sm font-medium ${activity.amount > 0 ? 'text-green-600' : 'text-red-600'}`}>
              {activity.amount > 0 ? '+' : ''}{activity.amount}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
}
```

---

## Step 3: รวมทุก Component ในหน้า Dashboard

**ไฟล์:** `admin-panel/src/app/(dashboard)/page.tsx`

**แก้ไขจาก:**
```typescript
export default function DashboardPage() {
  return (
    <div className="p-8">
      <h1 className="text-3xl font-bold mb-6">Dashboard</h1>
      <div className="bg-green-50 border border-green-200 rounded-lg p-4">
        <h2 className="text-green-800 font-semibold">Authentication working!</h2>
        <p className="text-gray-600">Dashboard metrics will be added in Task 2</p>
      </div>
    </div>
  );
}
```

**เป็น:**
```typescript
'use client';

import { useEffect, useState } from 'react';
import { MetricCard } from '@/components/dashboard/MetricCard';
import { UserGrowthChart } from '@/components/dashboard/UserGrowthChart';
import { StreakDistribution } from '@/components/dashboard/StreakDistribution';
import { RecentActivities } from '@/components/dashboard/RecentActivities';

export default function DashboardPage() {
  const [stats, setStats] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch('/api/dashboard/stats')
      .then((res) => res.json())
      .then((json) => {
        setStats(json.stats);
        setLoading(false);
      })
      .catch((err) => {
        console.error(err);
        setLoading(false);
      });
  }, []);

  if (loading) {
    return (
      <div className="p-8">
        <div className="text-center py-12">Loading dashboard...</div>
      </div>
    );
  }

  return (
    <div className="p-8">
      <h1 className="text-3xl font-bold mb-6">📊 Dashboard</h1>

      {/* Metric Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <MetricCard
          title="Total Users"
          value={stats?.totalUsers.toLocaleString() || 0}
          icon="👥"
          description="All registered users"
        />
        <MetricCard
          title="Active Users"
          value={stats?.activeUsers.toLocaleString() || 0}
          icon="✅"
          description="Checked in last 7 days"
        />
        <MetricCard
          title="Total Revenue"
          value={`฿${stats?.totalRevenue.toLocaleString() || 0}`}
          icon="💰"
          description="All-time revenue"
        />
        <MetricCard
          title="Active Subscribers"
          value={stats?.activeSubscribers.toLocaleString() || 0}
          icon="💎"
          description="Current subscribers"
        />
      </div>

      {/* User Growth Chart */}
      <div className="mb-8">
        <UserGrowthChart />
      </div>

      {/* Bottom Row: Streak Distribution + Recent Activities */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <StreakDistribution />
        <RecentActivities />
      </div>
    </div>
  );
}
```

---

## Step 4: Test หน้า Dashboard

### 4.1 รัน dev server

```powershell
cd c:\aiprogram\miro\admin-panel
npm run dev
```

### 4.2 เปิดเบราว์เซอร์

`http://localhost:3000`

### 4.3 Checklist

- [ ] เห็น 4 metric cards แสดงตัวเลขถูกต้อง
- [ ] กราฟ User Growth แสดงได้ (ถ้ามี data)
- [ ] Streak Distribution แสดงจำนวนแต่ละ tier
- [ ] Recent Activities แสดง transaction ล่าสุด 10 รายการ
- [ ] ไม่มี error ใน console
- [ ] Refresh หน้าแล้วยังแสดงได้ปกติ

---

## 🎉 เสร็จแล้ว Task 1!

**ถ้า checklist ครบทุกข้อ → ไปทำ Task 2 ต่อได้เลย!**

ไฟล์ถัดไป: `TASK_2_USERS.md`

---

## 🔧 Troubleshooting

### ปัญหา: API return error "Firebase not initialized"

**แก้:** เช็คว่ามี `serviceAccountKey.json` ใน `admin-panel/` หรือยัง

```powershell
ls admin-panel/serviceAccountKey.json
```

ถ้าไม่มี → download จาก Firebase Console

---

### ปัญหา: ไม่มี data แสดง (ทุก metric เป็น 0)

**แก้:** ไปสร้าง test data ใน Firestore ก่อน หรือใช้ production database

---

### ปัญหา: Chart ไม่แสดง

**แก้:** ติดตั้ง recharts:
```powershell
npm install recharts
```

---

### ปัญหา: TypeScript error

**แก้:** ติดตั้ง types:
```powershell
npm install --save-dev @types/node @types/react @types/react-dom
```
