# Task 2: User Management — จัดการ Users

**ระยะเวลา:** 6 ชั่วโมง  
**ความยาก:** ⭐⭐⭐☆☆ (ปานกลาง)

---

## 🎯 เป้าหมาย

สร้างหน้า User Management ที่มี:
1. **Search Box** — ค้นหา user ด้วย MiRO ID หรือ Device ID
2. **User Detail Modal** — แสดงข้อมูล user + transaction history
3. **Top-up Form** — เติม energy ให้ user
4. **Reset Streak** — รีเซ็ต streak เป็น 0
5. **Ban/Unban** — แบน user ที่ abuse

---

## 📸 ตัวอย่างหน้าตา

```
┌─────────────────────────────────────────┐
│  👥 User Management                     │
│  ┌─────────────────────────────────┐   │
│  │ 🔍 Search by MiRO ID or Device  │   │
│  └─────────────────────────────────┘   │
│                                         │
│  [Search Results Table]                 │
│  ┌──────────────────────────────────┐  │
│  │ MiRO ID │ Balance │ Tier │ Actions│  │
│  │ ABC123  │ 45      │ Gold │ [View] │  │
│  └──────────────────────────────────┘  │
└─────────────────────────────────────────┘

[User Detail Modal]
┌─────────────────────────────────────────┐
│  User: ABC123                     [X]   │
│                                         │
│  Balance: 45 Energy                     │
│  Tier: Gold (30 days streak)            │
│  Total Spent: 120 Energy                │
│                                         │
│  Actions:                               │
│  [Top-up Energy] [Reset Streak] [Ban]  │
│                                         │
│  📋 Transaction History                 │
│  • +100 Energy (purchase)               │
│  • -1 Energy (AI usage)                 │
└─────────────────────────────────────────┘
```

---

## 📝 Checklist

- [ ] Step 1: API endpoints (search, detail, topup, reset, ban)
- [ ] Step 2: Components (SearchBox, UserTable, DetailModal, Forms)
- [ ] Step 3: Users page
- [ ] Step 4: Test ทุกฟีเจอร์

---

## Step 1: API Endpoints

### 1.1 Search Users API

**ไฟล์:** `admin-panel/src/app/api/users/search/route.ts`

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { getFirestore } from 'firebase-admin/firestore';
import { initAdmin } from '@/lib/firebase-admin';

export async function GET(request: NextRequest) {
  try {
    initAdmin();
    const db = getFirestore();

    const query = request.nextUrl.searchParams.get('q') || '';
    
    if (!query) {
      return NextResponse.json({ error: 'Missing query' }, { status: 400 });
    }

    // Try search by MiRO ID first
    let userDoc: any = null;
    const miroIdQuery = await db
      .collection('users')
      .where('miroId', '==', query)
      .limit(1)
      .get();

    if (!miroIdQuery.empty) {
      userDoc = miroIdQuery.docs[0];
    } else {
      // Try search by deviceId
      const deviceDoc = await db.collection('users').doc(query).get();
      if (deviceDoc.exists) {
        userDoc = deviceDoc;
      }
    }

    if (!userDoc || !userDoc.exists) {
      return NextResponse.json({ error: 'User not found' }, { status: 404 });
    }

    const userData = userDoc.data();

    return NextResponse.json({
      success: true,
      user: {
        deviceId: userDoc.id,
        miroId: userData.miroId,
        balance: userData.balance || 0,
        tier: userData.tier || 'none',
        currentStreak: userData.currentStreak || 0,
        longestStreak: userData.longestStreak || 0,
        totalSpent: userData.totalSpent || 0,
        totalPurchased: userData.totalPurchased || 0,
        totalEarned: userData.totalEarned || 0,
        isSubscriber: userData.isSubscriber || false,
        subscriptionStatus: userData.subscriptionStatus,
        isBanned: userData.isBanned || false,
        createdAt: userData.createdAt?.toDate?.()?.toISOString(),
        lastUpdated: userData.lastUpdated?.toDate?.()?.toISOString(),
      },
    });
  } catch (error: any) {
    console.error('Error searching user:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
```

**Test:** `http://localhost:3000/api/users/search?q=YOUR_MIRO_ID`

---

### 1.2 User Detail + Transactions API

**ไฟล์:** `admin-panel/src/app/api/users/[deviceId]/route.ts`

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { getFirestore } from 'firebase-admin/firestore';
import { initAdmin } from '@/lib/firebase-admin';

export async function GET(
  request: NextRequest,
  { params }: { params: { deviceId: string } }
) {
  try {
    initAdmin();
    const db = getFirestore();

    const { deviceId } = params;

    const userDoc = await db.collection('users').doc(deviceId).get();
    if (!userDoc.exists) {
      return NextResponse.json({ error: 'User not found' }, { status: 404 });
    }

    const userData = userDoc.data()!;

    // Get transactions
    const transactionsSnapshot = await db
      .collection('transactions')
      .where('deviceId', '==', deviceId)
      .orderBy('createdAt', 'desc')
      .limit(50)
      .get();

    const transactions = transactionsSnapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
      createdAt: doc.data().createdAt?.toDate?.()?.toISOString(),
    }));

    return NextResponse.json({
      success: true,
      user: {
        deviceId: userDoc.id,
        miroId: userData.miroId,
        balance: userData.balance || 0,
        tier: userData.tier || 'none',
        currentStreak: userData.currentStreak || 0,
        longestStreak: userData.longestStreak || 0,
        totalSpent: userData.totalSpent || 0,
        totalPurchased: userData.totalPurchased || 0,
        totalEarned: userData.totalEarned || 0,
        isSubscriber: userData.isSubscriber || false,
        subscriptionStatus: userData.subscriptionStatus,
        subscriptionExpiryDate: userData.subscriptionExpiryDate?.toDate?.()?.toISOString(),
        isBanned: userData.isBanned || false,
        banReason: userData.banReason,
        challenges: userData.challenges,
        milestones: userData.milestones,
        promotions: userData.promotions,
        createdAt: userData.createdAt?.toDate?.()?.toISOString(),
        lastUpdated: userData.lastUpdated?.toDate?.()?.toISOString(),
      },
      transactions,
    });
  } catch (error: any) {
    console.error('Error fetching user detail:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
```

---

### 1.3 Top-up Energy API

**ไฟล์:** `admin-panel/src/app/api/users/[deviceId]/topup/route.ts`

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';
import { initAdmin } from '@/lib/firebase-admin';

export async function POST(
  request: NextRequest,
  { params }: { params: { deviceId: string } }
) {
  try {
    initAdmin();
    const db = getFirestore();

    const { deviceId } = params;
    const { amount, reason } = await request.json();

    if (!amount || !reason) {
      return NextResponse.json(
        { error: 'Missing amount or reason' },
        { status: 400 }
      );
    }

    const userRef = db.collection('users').doc(deviceId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return NextResponse.json({ error: 'User not found' }, { status: 404 });
    }

    const userData = userDoc.data()!;
    const newBalance = (userData.balance || 0) + amount;

    // Update balance
    await userRef.update({
      balance: newBalance,
      lastUpdated: FieldValue.serverTimestamp(),
    });

    // Log transaction
    await db.collection('transactions').add({
      deviceId,
      miroId: userData.miroId || 'unknown',
      type: 'admin_topup',
      amount,
      balanceAfter: newBalance,
      description: `Admin top-up: ${reason}`,
      metadata: {
        adminAction: true,
        reason,
      },
      createdAt: FieldValue.serverTimestamp(),
    });

    return NextResponse.json({
      success: true,
      newBalance,
    });
  } catch (error: any) {
    console.error('Error topping up:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
```

---

### 1.4 Reset Streak API

**ไฟล์:** `admin-panel/src/app/api/users/[deviceId]/reset-streak/route.ts`

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';
import { initAdmin } from '@/lib/firebase-admin';

export async function POST(
  request: NextRequest,
  { params }: { params: { deviceId: string } }
) {
  try {
    initAdmin();
    const db = getFirestore();

    const { deviceId } = params;
    const { reason } = await request.json();

    if (!reason) {
      return NextResponse.json({ error: 'Missing reason' }, { status: 400 });
    }

    const userRef = db.collection('users').doc(deviceId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return NextResponse.json({ error: 'User not found' }, { status: 404 });
    }

    await userRef.update({
      currentStreak: 0,
      tier: 'none',
      lastCheckInDate: null,
      bonusRate: 0,
      lastUpdated: FieldValue.serverTimestamp(),
    });

    return NextResponse.json({ success: true });
  } catch (error: any) {
    console.error('Error resetting streak:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
```

---

### 1.5 Ban/Unban User API

**ไฟล์:** `admin-panel/src/app/api/users/[deviceId]/ban/route.ts`

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';
import { initAdmin } from '@/lib/firebase-admin';

export async function POST(
  request: NextRequest,
  { params }: { params: { deviceId: string } }
) {
  try {
    initAdmin();
    const db = getFirestore();

    const { deviceId } = params;
    const { isBanned, reason } = await request.json();

    if (isBanned === undefined || !reason) {
      return NextResponse.json(
        { error: 'Missing isBanned or reason' },
        { status: 400 }
      );
    }

    const userRef = db.collection('users').doc(deviceId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return NextResponse.json({ error: 'User not found' }, { status: 404 });
    }

    await userRef.update({
      isBanned,
      banReason: isBanned ? reason : null,
      banDate: isBanned ? FieldValue.serverTimestamp() : null,
      lastUpdated: FieldValue.serverTimestamp(),
    });

    return NextResponse.json({ success: true });
  } catch (error: any) {
    console.error('Error updating ban status:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
```

---

## ✅ Checkpoint 1: Test ทุก API

Test APIs ด้วย Postman หรือ curl:

```powershell
# Search user
curl http://localhost:3000/api/users/search?q=MIRO123

# Get user detail
curl http://localhost:3000/api/users/DEVICE_ID_HERE

# Top-up (POST)
curl -X POST http://localhost:3000/api/users/DEVICE_ID/topup \
  -H "Content-Type: application/json" \
  -d '{"amount": 100, "reason": "Compensation"}'

# Reset streak (POST)
curl -X POST http://localhost:3000/api/users/DEVICE_ID/reset-streak \
  -H "Content-Type: application/json" \
  -d '{"reason": "User request"}'

# Ban user (POST)
curl -X POST http://localhost:3000/api/users/DEVICE_ID/ban \
  -H "Content-Type: application/json" \
  -d '{"isBanned": true, "reason": "Abuse detected"}'
```

---

## Step 2: React Components

### 2.1 User Search Component

**ไฟล์:** `admin-panel/src/components/users/UserSearch.tsx`

```typescript
'use client';

import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';

interface UserSearchProps {
  onUserFound: (user: any) => void;
}

export function UserSearch({ onUserFound }: UserSearchProps) {
  const [query, setQuery] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSearch = async () => {
    if (!query.trim()) return;

    setLoading(true);
    setError('');

    try {
      const res = await fetch(`/api/users/search?q=${encodeURIComponent(query)}`);
      const data = await res.json();

      if (res.ok && data.success) {
        onUserFound(data.user);
      } else {
        setError(data.error || 'User not found');
      }
    } catch (err: any) {
      setError(err.message || 'Failed to search');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-4">
      <div className="flex gap-2">
        <Input
          type="text"
          placeholder="Search by MiRO ID or Device ID..."
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          onKeyDown={(e) => e.key === 'Enter' && handleSearch()}
          className="flex-1"
        />
        <Button onClick={handleSearch} disabled={loading}>
          {loading ? 'Searching...' : '🔍 Search'}
        </Button>
      </div>

      {error && (
        <div className="bg-red-50 border border-red-200 text-red-800 px-4 py-2 rounded">
          {error}
        </div>
      )}
    </div>
  );
}
```

---

### 2.2 User Detail Modal

**ไฟล์:** `admin-panel/src/components/users/UserDetailModal.tsx`

```typescript
'use client';

import { useEffect, useState } from 'react';
import { Button } from '@/components/ui/button';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';

interface UserDetailModalProps {
  deviceId: string;
  open: boolean;
  onClose: () => void;
  onRefresh?: () => void;
}

export function UserDetailModal({ deviceId, open, onClose, onRefresh }: UserDetailModalProps) {
  const [user, setUser] = useState<any>(null);
  const [transactions, setTransactions] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [showTopupForm, setShowTopupForm] = useState(false);

  useEffect(() => {
    if (!open || !deviceId) return;

    setLoading(true);
    fetch(`/api/users/${deviceId}`)
      .then((res) => res.json())
      .then((data) => {
        if (data.success) {
          setUser(data.user);
          setTransactions(data.transactions || []);
        }
        setLoading(false);
      })
      .catch((err) => {
        console.error(err);
        setLoading(false);
      });
  }, [open, deviceId]);

  const handleTopup = async (amount: number, reason: string) => {
    try {
      const res = await fetch(`/api/users/${deviceId}/topup`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ amount, reason }),
      });

      if (res.ok) {
        alert('Top-up successful!');
        setShowTopupForm(false);
        onRefresh?.();
        // Refresh user data
        const data = await fetch(`/api/users/${deviceId}`).then((r) => r.json());
        if (data.success) setUser(data.user);
      } else {
        alert('Failed to top-up');
      }
    } catch (err) {
      alert('Error: ' + err);
    }
  };

  const handleResetStreak = async () => {
    if (!confirm('Reset streak to 0?')) return;

    const reason = prompt('Reason for reset:');
    if (!reason) return;

    try {
      const res = await fetch(`/api/users/${deviceId}/reset-streak`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ reason }),
      });

      if (res.ok) {
        alert('Streak reset!');
        onRefresh?.();
        const data = await fetch(`/api/users/${deviceId}`).then((r) => r.json());
        if (data.success) setUser(data.user);
      } else {
        alert('Failed to reset');
      }
    } catch (err) {
      alert('Error: ' + err);
    }
  };

  const handleBan = async () => {
    const isBanned = !user?.isBanned;
    const action = isBanned ? 'Ban' : 'Unban';
    
    if (!confirm(`${action} this user?`)) return;

    const reason = prompt(`Reason for ${action.toLowerCase()}:`);
    if (!reason) return;

    try {
      const res = await fetch(`/api/users/${deviceId}/ban`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ isBanned, reason }),
      });

      if (res.ok) {
        alert(`User ${action.toLowerCase()}ned!`);
        onRefresh?.();
        const data = await fetch(`/api/users/${deviceId}`).then((r) => r.json());
        if (data.success) setUser(data.user);
      } else {
        alert(`Failed to ${action.toLowerCase()}`);
      }
    } catch (err) {
      alert('Error: ' + err);
    }
  };

  if (loading) {
    return (
      <Dialog open={open} onOpenChange={onClose}>
        <DialogContent className="max-w-3xl">
          <div className="text-center py-8">Loading...</div>
        </DialogContent>
      </Dialog>
    );
  }

  return (
    <Dialog open={open} onOpenChange={onClose}>
      <DialogContent className="max-w-3xl max-h-[80vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>👤 User: {user?.miroId || deviceId}</DialogTitle>
        </DialogHeader>

        {/* User Info */}
        <div className="grid grid-cols-2 gap-4 my-4">
          <div className="bg-gray-50 p-4 rounded">
            <p className="text-sm text-gray-600">Balance</p>
            <p className="text-2xl font-bold">⚡ {user?.balance || 0}</p>
          </div>
          <div className="bg-gray-50 p-4 rounded">
            <p className="text-sm text-gray-600">Tier</p>
            <p className="text-2xl font-bold">{user?.tier || 'none'}</p>
          </div>
          <div className="bg-gray-50 p-4 rounded">
            <p className="text-sm text-gray-600">Streak</p>
            <p className="text-2xl font-bold">{user?.currentStreak || 0} days</p>
          </div>
          <div className="bg-gray-50 p-4 rounded">
            <p className="text-sm text-gray-600">Total Spent</p>
            <p className="text-2xl font-bold">{user?.totalSpent || 0}</p>
          </div>
        </div>

        {/* Subscriber Badge */}
        {user?.isSubscriber && (
          <div className="bg-purple-50 border border-purple-200 p-3 rounded text-center">
            <span className="text-purple-700 font-semibold">💎 Active Subscriber</span>
            {user.subscriptionExpiryDate && (
              <span className="text-sm text-gray-600 ml-2">
                until {new Date(user.subscriptionExpiryDate).toLocaleDateString()}
              </span>
            )}
          </div>
        )}

        {/* Ban Badge */}
        {user?.isBanned && (
          <div className="bg-red-50 border border-red-200 p-3 rounded">
            <p className="text-red-700 font-semibold">🚫 BANNED</p>
            <p className="text-sm text-gray-600">Reason: {user.banReason}</p>
          </div>
        )}

        {/* Actions */}
        <div className="flex gap-2">
          <Button onClick={() => setShowTopupForm(!showTopupForm)} variant="outline">
            💰 Top-up
          </Button>
          <Button onClick={handleResetStreak} variant="outline">
            🔄 Reset Streak
          </Button>
          <Button onClick={handleBan} variant={user?.isBanned ? 'default' : 'destructive'}>
            {user?.isBanned ? '✅ Unban' : '🚫 Ban'}
          </Button>
        </div>

        {/* Top-up Form */}
        {showTopupForm && (
          <div className="bg-blue-50 border border-blue-200 p-4 rounded space-y-3">
            <h4 className="font-semibold">Top-up Energy</h4>
            <Input
              type="number"
              placeholder="Amount"
              id="topup-amount"
            />
            <Input
              type="text"
              placeholder="Reason (e.g., Compensation)"
              id="topup-reason"
            />
            <Button
              onClick={() => {
                const amount = parseInt((document.getElementById('topup-amount') as HTMLInputElement).value);
                const reason = (document.getElementById('topup-reason') as HTMLInputElement).value;
                if (amount && reason) handleTopup(amount, reason);
              }}
            >
              Confirm Top-up
            </Button>
          </div>
        )}

        {/* Transactions */}
        <div className="mt-6">
          <h4 className="font-semibold mb-3">📋 Transaction History (Last 50)</h4>
          <div className="space-y-2 max-h-60 overflow-y-auto">
            {transactions.map((tx: any) => (
              <div key={tx.id} className="flex justify-between items-start bg-gray-50 p-3 rounded text-sm">
                <div className="flex-1">
                  <p className="font-medium">{tx.description}</p>
                  <p className="text-xs text-gray-500">
                    {new Date(tx.createdAt).toLocaleString()}
                  </p>
                </div>
                <span className={`font-bold ${tx.amount > 0 ? 'text-green-600' : 'text-red-600'}`}>
                  {tx.amount > 0 ? '+' : ''}{tx.amount}
                </span>
              </div>
            ))}
          </div>
        </div>
      </DialogContent>
    </Dialog>
  );
}
```

---

## Step 3: Users Page

**ไฟล์:** `admin-panel/src/app/(dashboard)/users/page.tsx`

```typescript
'use client';

import { useState } from 'react';
import { UserSearch } from '@/components/users/UserSearch';
import { UserDetailModal } from '@/components/users/UserDetailModal';

export default function UsersPage() {
  const [selectedUser, setSelectedUser] = useState<any>(null);
  const [showModal, setShowModal] = useState(false);

  const handleUserFound = (user: any) => {
    setSelectedUser(user);
    setShowModal(true);
  };

  return (
    <div className="p-8">
      <h1 className="text-3xl font-bold mb-6">👥 User Management</h1>

      <div className="bg-white rounded-lg shadow p-6">
        <UserSearch onUserFound={handleUserFound} />

        {selectedUser && (
          <div className="mt-6 p-4 bg-gray-50 rounded">
            <h3 className="font-semibold mb-2">Found User:</h3>
            <div className="grid grid-cols-2 gap-2 text-sm">
              <p><strong>MiRO ID:</strong> {selectedUser.miroId}</p>
              <p><strong>Balance:</strong> ⚡ {selectedUser.balance}</p>
              <p><strong>Tier:</strong> {selectedUser.tier}</p>
              <p><strong>Streak:</strong> {selectedUser.currentStreak} days</p>
            </div>
            <Button onClick={() => setShowModal(true)} className="mt-4">
              View Details →
            </Button>
          </div>
        )}
      </div>

      {/* User Detail Modal */}
      {selectedUser && (
        <UserDetailModal
          deviceId={selectedUser.deviceId}
          open={showModal}
          onClose={() => setShowModal(false)}
          onRefresh={() => {
            // Refresh user data
            if (selectedUser) {
              fetch(`/api/users/search?q=${selectedUser.miroId}`)
                .then((res) => res.json())
                .then((data) => {
                  if (data.success) setSelectedUser(data.user);
                });
            }
          }}
        />
      )}
    </div>
  );
}
```

---

## Step 4: Update Sidebar Navigation

**ไฟล์:** `admin-panel/src/components/Sidebar.tsx`

**เพิ่ม Users link:**

```typescript
// หา array ของ navigation links แล้วเพิ่ม:
{
  name: 'Users',
  href: '/users',
  icon: '👥',
},
```

ตัวอย่างเต็ม:

```typescript
const navigation = [
  { name: 'Dashboard', href: '/', icon: '📊' },
  { name: 'Users', href: '/users', icon: '👥' },  // ← เพิ่มบรรทัดนี้
  // ... other links
];
```

---

## Step 5: Test

### 5.1 เปิดหน้า Users

`http://localhost:3000/users`

### 5.2 Checklist

- [ ] Search box แสดงได้
- [ ] ค้นหา user ด้วย MiRO ID → เจอ
- [ ] ค้นหา user ด้วย Device ID → เจอ
- [ ] กด "View Details" → modal เปิด
- [ ] เห็นข้อมูล user ครบ (balance, tier, streak, transactions)
- [ ] Top-up → balance เพิ่ม → transaction log ถูกบันทึก
- [ ] Reset streak → streak = 0, tier = none
- [ ] Ban → user ถูกแบน → แสดง badge "BANNED"
- [ ] Unban → badge หายไป
- [ ] ไม่มี error ใน console

---

## 🎉 เสร็จแล้ว Task 2!

**ถ้า checklist ครบ → ไปทำ Task 3 ต่อได้เลย!**

ไฟล์ถัดไป: `TASK_3_CONFIG.md`

---

## 🔧 Troubleshooting

### ปัญหา: shadcn/ui components ไม่มี

**แก้:** ติดตั้ง shadcn components:

```powershell
npx shadcn-ui@latest add button
npx shadcn-ui@latest add input
npx shadcn-ui@latest add dialog
```

---

### ปัญหา: API return 404

**แก้:** เช็คว่า:
1. Server รันอยู่ (`npm run dev`)
2. URL ถูกต้อง
3. deviceId มีอยู่จริงใน Firestore

---

### ปัญหา: Top-up ไม่ทำงาน

**แก้:** เช็ค console logs:
```powershell
# ดู logs ใน terminal ที่รัน npm run dev
```

---

### ปัญหา: Modal ไม่เปิด

**แก้:** เช็คว่า import Dialog component ถูกต้อง + ติดตั้ง shadcn dialog:
```powershell
npx shadcn-ui@latest add dialog
```
