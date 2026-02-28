# Task 4: Subscription Management — จัดการ Subscribers

**ระยะเวลา:** 4 ชั่วโมง  
**ความยาก:** ⭐⭐☆☆☆ (ค่อนข้างง่าย)

---

## 🎯 เป้าหมาย

สร้างหน้า Subscription Management:
1. **Subscriber List** — รายชื่อ subscribers ทั้งหมด
2. **Subscription Metrics** — MRR, Total subscribers, Churn rate
3. **Expiry Alerts** — subscribers ที่ใกล้หมดอายุ (7 วัน)
4. **Revenue Report** — รายได้จาก subscription

---

## 📸 ตัวอย่างหน้าตา

```
┌─────────────────────────────────────────┐
│  💎 Subscription Management             │
│                                         │
│  📊 Metrics                             │
│  ┌──────────┬──────────┬──────────┐    │
│  │ MRR      │ Active   │ Churn    │    │
│  │ ฿1,200   │ 45       │ 5%       │    │
│  └──────────┴──────────┴──────────┘    │
│                                         │
│  🔔 Expiring Soon (7 days)             │
│  • ABC123 - expires in 3 days          │
│  • XYZ789 - expires in 5 days          │
│                                         │
│  👥 All Subscribers                    │
│  ┌────────────────────────────────┐   │
│  │ MiRO ID │ Status │ Expiry       │   │
│  │ ABC123  │ Active │ 2026-03-15   │   │
│  │ XYZ789  │ Active │ 2026-03-20   │   │
│  └────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

---

## 📝 Checklist

- [ ] Step 1: API endpoints (list, metrics)
- [ ] Step 2: Components (MetricsCards, SubscriberTable)
- [ ] Step 3: Subscriptions page
- [ ] Step 4: Test

---

## Step 1: API Endpoints

### 1.1 Subscription Metrics API

**ไฟล์:** `admin-panel/src/app/api/subscriptions/metrics/route.ts`

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { getFirestore } from 'firebase-admin/firestore';
import { initAdmin } from '@/lib/firebase-admin';

export async function GET(request: NextRequest) {
  try {
    initAdmin();
    const db = getFirestore();

    // Count active subscribers
    const activeSnapshot = await db
      .collection('users')
      .where('isSubscriber', '==', true)
      .where('subscriptionStatus', '==', 'active')
      .get();

    const activeSubscribers = activeSnapshot.size;

    // Calculate MRR (assuming ฿79/month per subscriber)
    const MONTHLY_PRICE = 79;
    const mrr = activeSubscribers * MONTHLY_PRICE;

    // Count expiring soon (7 days)
    const sevenDaysFromNow = new Date();
    sevenDaysFromNow.setDate(sevenDaysFromNow.getDate() + 7);

    const expiringSoon = activeSnapshot.docs.filter((doc) => {
      const data = doc.data();
      const expiryDate = data.subscriptionExpiryDate?.toDate?.();
      return expiryDate && expiryDate <= sevenDaysFromNow;
    });

    // Count churned (last 30 days)
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const churnedSnapshot = await db
      .collection('users')
      .where('subscriptionStatus', 'in', ['expired', 'cancelled'])
      .where('subscriptionExpiryDate', '>=', thirtyDaysAgo)
      .get();

    const churnedCount = churnedSnapshot.size;
    const churnRate = activeSubscribers > 0
      ? ((churnedCount / (activeSubscribers + churnedCount)) * 100).toFixed(1)
      : 0;

    return NextResponse.json({
      success: true,
      metrics: {
        mrr,
        activeSubscribers,
        expiringSoon: expiringSoon.length,
        churnRate: parseFloat(churnRate as string),
      },
    });
  } catch (error: any) {
    console.error('Error fetching subscription metrics:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
```

**Test:** `http://localhost:3000/api/subscriptions/metrics`

---

### 1.2 Subscribers List API

**ไฟล์:** `admin-panel/src/app/api/subscriptions/list/route.ts`

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { getFirestore } from 'firebase-admin/firestore';
import { initAdmin } from '@/lib/firebase-admin';

export async function GET(request: NextRequest) {
  try {
    initAdmin();
    const db = getFirestore();

    const status = request.nextUrl.searchParams.get('status') || 'active';
    const limit = parseInt(request.nextUrl.searchParams.get('limit') || '50');

    let query = db.collection('users').where('isSubscriber', '==', true);

    if (status !== 'all') {
      query = query.where('subscriptionStatus', '==', status);
    }

    const snapshot = await query.orderBy('subscriptionExpiryDate', 'desc').limit(limit).get();

    const subscribers = snapshot.docs.map((doc) => {
      const data = doc.data();
      return {
        deviceId: doc.id,
        miroId: data.miroId,
        subscriptionStatus: data.subscriptionStatus,
        subscriptionExpiryDate: data.subscriptionExpiryDate?.toDate?.()?.toISOString(),
        balance: data.balance || 0,
        tier: data.tier || 'none',
        currentStreak: data.currentStreak || 0,
      };
    });

    return NextResponse.json({
      success: true,
      subscribers,
      total: subscribers.length,
    });
  } catch (error: any) {
    console.error('Error fetching subscribers:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
```

**Test:** `http://localhost:3000/api/subscriptions/list?status=active&limit=50`

---

## Step 2: Components

### 2.1 Subscription Metrics Cards

**ไฟล์:** `admin-panel/src/components/subscriptions/SubscriptionMetrics.tsx`

```typescript
'use client';

import { useEffect, useState } from 'react';
import { MetricCard } from '@/components/dashboard/MetricCard';

export function SubscriptionMetrics() {
  const [metrics, setMetrics] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch('/api/subscriptions/metrics')
      .then((res) => res.json())
      .then((data) => {
        setMetrics(data.metrics);
        setLoading(false);
      })
      .catch((err) => {
        console.error(err);
        setLoading(false);
      });
  }, []);

  if (loading) return <div className="text-center py-4">Loading metrics...</div>;

  return (
    <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-6">
      <MetricCard
        title="MRR"
        value={`฿${metrics?.mrr.toLocaleString() || 0}`}
        icon="💰"
        description="Monthly Recurring Revenue"
      />
      <MetricCard
        title="Active Subscribers"
        value={metrics?.activeSubscribers || 0}
        icon="💎"
        description="Currently subscribed"
      />
      <MetricCard
        title="Expiring Soon"
        value={metrics?.expiringSoon || 0}
        icon="🔔"
        description="Within 7 days"
      />
      <MetricCard
        title="Churn Rate"
        value={`${metrics?.churnRate || 0}%`}
        icon="📉"
        description="Last 30 days"
      />
    </div>
  );
}
```

---

### 2.2 Subscribers Table

**ไฟล์:** `admin-panel/src/components/subscriptions/SubscribersTable.tsx`

```typescript
'use client';

import { useEffect, useState } from 'react';

export function SubscribersTable() {
  const [subscribers, setSubscribers] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch('/api/subscriptions/list?status=active&limit=100')
      .then((res) => res.json())
      .then((data) => {
        setSubscribers(data.subscribers || []);
        setLoading(false);
      })
      .catch((err) => {
        console.error(err);
        setLoading(false);
      });
  }, []);

  if (loading) return <div className="text-center py-8">Loading subscribers...</div>;

  const isExpiringSoon = (expiryDate: string) => {
    const expiry = new Date(expiryDate);
    const sevenDays = new Date();
    sevenDays.setDate(sevenDays.getDate() + 7);
    return expiry <= sevenDays;
  };

  return (
    <div className="bg-white rounded-lg shadow overflow-hidden">
      <table className="min-w-full">
        <thead className="bg-gray-50">
          <tr>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
              MiRO ID
            </th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
              Status
            </th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
              Expiry Date
            </th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
              Balance
            </th>
          </tr>
        </thead>
        <tbody className="bg-white divide-y divide-gray-200">
          {subscribers.map((sub) => (
            <tr key={sub.deviceId} className={isExpiringSoon(sub.subscriptionExpiryDate) ? 'bg-yellow-50' : ''}>
              <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                {sub.miroId}
              </td>
              <td className="px-6 py-4 whitespace-nowrap">
                <span className="px-2 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800">
                  {sub.subscriptionStatus}
                </span>
              </td>
              <td className="px-6 py-4 whitespace-nowrap text-sm">
                {new Date(sub.subscriptionExpiryDate).toLocaleDateString()}
                {isExpiringSoon(sub.subscriptionExpiryDate) && (
                  <span className="ml-2 text-yellow-600">⚠️ Soon</span>
                )}
              </td>
              <td className="px-6 py-4 whitespace-nowrap text-sm">
                ⚡ {sub.balance}
              </td>
            </tr>
          ))}
        </tbody>
      </table>

      {subscribers.length === 0 && (
        <div className="text-center py-8 text-gray-500">
          No active subscribers
        </div>
      )}
    </div>
  );
}
```

---

## Step 3: Subscriptions Page

**ไฟล์:** `admin-panel/src/app/(dashboard)/subscriptions/page.tsx`

```typescript
'use client';

import { SubscriptionMetrics } from '@/components/subscriptions/SubscriptionMetrics';
import { SubscribersTable } from '@/components/subscriptions/SubscribersTable';

export default function SubscriptionsPage() {
  return (
    <div className="p-8">
      <h1 className="text-3xl font-bold mb-6">💎 Subscription Management</h1>

      {/* Metrics */}
      <SubscriptionMetrics />

      {/* Subscribers Table */}
      <div className="mt-6">
        <h2 className="text-xl font-semibold mb-4">👥 All Subscribers</h2>
        <SubscribersTable />
      </div>
    </div>
  );
}
```

---

## Step 4: Update Sidebar

**ไฟล์:** `admin-panel/src/components/Sidebar.tsx`

เพิ่ม:
```typescript
{
  name: 'Subscriptions',
  href: '/subscriptions',
  icon: '💎',
},
```

---

## Step 5: Test

### Checklist

- [ ] เปิดหน้า Subscriptions: `http://localhost:3000/subscriptions`
- [ ] แสดง 4 metric cards (MRR, Active, Expiring, Churn)
- [ ] แสดง table รายชื่อ subscribers
- [ ] Subscribers ที่ใกล้หมดอายุมี background สีเหลือง
- [ ] แสดงวันหมดอายุถูกต้อง
- [ ] ไม่มี error

---

## 🎉 เสร็จแล้ว Task 4!

**เสร็จครบทั้ง 4 Tasks แล้ว! 🎊**

---

## 📦 Next Steps

### 1. Deploy ขึ้น Cloud Run (production)

```powershell
cd c:\aiprogram\miro\admin-panel
.\deploy.ps1
```

### 2. Share URL กับทีม

หลัง deploy จะได้ URL: `https://admin-panel-xxx.run.app`

---

## 🔧 Troubleshooting

### ปัญหา: ไม่มี subscribers แสดง

**แก้:** เช็ค Firestore ว่ามี users ที่ `isSubscriber: true` หรือยัง

ถ้าไม่มี → ไปซื้อ subscription ใน app ก่อน

---

### ปัญหา: MRR ไม่ถูกต้อง

**แก้:** แก้ `MONTHLY_PRICE` ใน code ให้ตรงกับราคาจริง (ตอนนี้ hardcode ฿79)

---

### ปัญหา: Table ไม่สวย

**แก้:** เพิ่ม Tailwind classes หรือใช้ shadcn Table component:

```powershell
npx shadcn-ui@latest add table
```
