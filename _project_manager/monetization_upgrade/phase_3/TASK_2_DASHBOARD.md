# Phase 3 - Task 2: Dashboard & Metrics

**Status:** 📝 Ready for Implementation  
**Estimated Time:** 6-8 hours  
**Difficulty:** ⭐⭐⭐ Medium  
**Prerequisites:** Task 1 (Admin Panel Setup) must be completed

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Requirements](#requirements)
3. [Tech Stack](#tech-stack)
4. [Step-by-Step Implementation](#step-by-step-implementation)
5. [Testing](#testing)
6. [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

In this task, you will create a comprehensive dashboard that displays key metrics and analytics for the MiRO app. The dashboard will show:

- **User Statistics:** Total users, active users, new registrations
- **Energy Metrics:** Total energy consumed, average per user, energy distribution
- **AI Usage:** Total AI analyses, average per user, usage trends
- **Streak Analytics:** Streak tier distribution, average streak length
- **Challenge & Milestone Progress:** Completion rates, popular challenges
- **Visual Charts:** Line charts for trends, pie charts for distributions

The dashboard will fetch real-time data from Firestore and display it in an attractive, responsive layout.

---

## 📊 Requirements

### Functional Requirements
- [ ] Display overview metrics in cards (Total Users, Active Users, Energy Stats, AI Usage)
- [ ] Show user growth chart (last 30 days)
- [ ] Display energy consumption trends
- [ ] Show streak tier distribution (Bronze/Silver/Gold/Diamond)
- [ ] Display challenge completion rates
- [ ] Show recent activities feed
- [ ] All data should update in real-time
- [ ] Loading states for all metrics
- [ ] Error handling for failed queries

### Non-Functional Requirements
- [ ] Page load time < 3 seconds
- [ ] Responsive design (mobile, tablet, desktop)
- [ ] Smooth animations and transitions
- [ ] Accessible (ARIA labels, keyboard navigation)

---

## 🛠️ Tech Stack

- **Next.js 16** - App Router with Server Components
- **Firebase Admin SDK** - For Firestore queries
- **Recharts** - For data visualization
- **Shadcn/ui** - UI components
- **Lucide Icons** - Icon library
- **date-fns** - Date formatting

---

## 🚀 Step-by-Step Implementation

### Step 1: Create Dashboard API Routes

#### 1.1 Create Stats API Route

**File:** `admin-panel/src/app/api/dashboard/stats/route.ts`

```typescript
import { NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { requireAuth } from '@/lib/auth';

export async function GET(request: Request) {
  try {
    // Verify authentication
    const authCheck = await requireAuth(request);
    if (authCheck instanceof NextResponse) {
      return authCheck; // Return 401 if not authenticated
    }

    // Get total users count
    const usersSnapshot = await db.collection('users').count().get();
    const totalUsers = usersSnapshot.data().count;

    // Get active users (logged in last 7 days)
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
    
    const activeUsersSnapshot = await db
      .collection('users')
      .where('lastActiveAt', '>=', sevenDaysAgo)
      .count()
      .get();
    const activeUsers7d = activeUsersSnapshot.data().count;

    // Get active users (logged in last 30 days)
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    
    const activeUsers30dSnapshot = await db
      .collection('users')
      .where('lastActiveAt', '>=', thirtyDaysAgo)
      .count()
      .get();
    const activeUsers30d = activeUsers30dSnapshot.data().count;

    // Get total energy consumed (sum of all transactions)
    const transactionsSnapshot = await db
      .collection('transactions')
      .where('amount', '<', 0) // Only spending transactions
      .get();
    
    const totalEnergyConsumed = transactionsSnapshot.docs.reduce(
      (sum, doc) => sum + Math.abs(doc.data().amount),
      0
    );

    // Get total AI analyses count
    const aiAnalysesSnapshot = await db
      .collection('transactions')
      .where('type', '==', 'ai_analysis')
      .count()
      .get();
    const totalAiAnalyses = aiAnalysesSnapshot.data().count;

    // Calculate averages
    const avgEnergyPerUser = totalUsers > 0 ? totalEnergyConsumed / totalUsers : 0;
    const avgAiPerUser = totalUsers > 0 ? totalAiAnalyses / totalUsers : 0;

    return NextResponse.json({
      users: {
        total: totalUsers,
        active7d: activeUsers7d,
        active30d: activeUsers30d,
      },
      energy: {
        totalConsumed: totalEnergyConsumed,
        avgPerUser: Math.round(avgEnergyPerUser),
      },
      ai: {
        totalAnalyses: totalAiAnalyses,
        avgPerUser: Math.round(avgAiPerUser * 10) / 10, // Round to 1 decimal
      },
    });
  } catch (error) {
    console.error('Dashboard stats error:', error);
    return NextResponse.json(
      { error: 'Failed to fetch dashboard stats' },
      { status: 500 }
    );
  }
}
```

#### 1.2 Create User Growth API Route

**File:** `admin-panel/src/app/api/dashboard/user-growth/route.ts`

```typescript
import { NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { requireAuth } from '@/lib/auth';

export async function GET(request: Request) {
  try {
    const authCheck = await requireAuth(request);
    if (authCheck instanceof NextResponse) {
      return authCheck;
    }

    // Get user registrations for last 30 days
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    thirtyDaysAgo.setHours(0, 0, 0, 0);

    const usersSnapshot = await db
      .collection('users')
      .where('createdAt', '>=', thirtyDaysAgo)
      .orderBy('createdAt', 'asc')
      .get();

    // Group by date
    const growthData: { [key: string]: number } = {};
    
    usersSnapshot.docs.forEach((doc) => {
      const createdAt = doc.data().createdAt?.toDate();
      if (createdAt) {
        const dateKey = createdAt.toISOString().split('T')[0]; // YYYY-MM-DD
        growthData[dateKey] = (growthData[dateKey] || 0) + 1;
      }
    });

    // Convert to array with cumulative count
    const sortedDates = Object.keys(growthData).sort();
    let cumulative = 0;
    const chartData = sortedDates.map((date) => {
      cumulative += growthData[date];
      return {
        date,
        count: growthData[date],
        cumulative,
      };
    });

    return NextResponse.json({ data: chartData });
  } catch (error) {
    console.error('User growth error:', error);
    return NextResponse.json(
      { error: 'Failed to fetch user growth data' },
      { status: 500 }
    );
  }
}
```

#### 1.3 Create Streak Distribution API Route

**File:** `admin-panel/src/app/api/dashboard/streak-distribution/route.ts`

```typescript
import { NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { requireAuth } from '@/lib/auth';

export async function GET(request: Request) {
  try {
    const authCheck = await requireAuth(request);
    if (authCheck instanceof NextResponse) {
      return authCheck;
    }

    // Get all users with gamification state
    const usersSnapshot = await db
      .collection('users')
      .select('gamificationState')
      .get();

    // Count by tier
    const tierCounts = {
      bronze: 0,
      silver: 0,
      gold: 0,
      diamond: 0,
      none: 0,
    };

    usersSnapshot.docs.forEach((doc) => {
      const gamification = doc.data().gamificationState;
      const tier = gamification?.streakTier || 'none';
      tierCounts[tier as keyof typeof tierCounts]++;
    });

    const chartData = [
      { name: 'Bronze', value: tierCounts.bronze, color: '#cd7f32' },
      { name: 'Silver', value: tierCounts.silver, color: '#c0c0c0' },
      { name: 'Gold', value: tierCounts.gold, color: '#ffd700' },
      { name: 'Diamond', value: tierCounts.diamond, color: '#b9f2ff' },
      { name: 'No Streak', value: tierCounts.none, color: '#9ca3af' },
    ];

    return NextResponse.json({ data: chartData });
  } catch (error) {
    console.error('Streak distribution error:', error);
    return NextResponse.json(
      { error: 'Failed to fetch streak distribution' },
      { status: 500 }
    );
  }
}
```

#### 1.4 Create Recent Activities API Route

**File:** `admin-panel/src/app/api/dashboard/recent-activities/route.ts`

```typescript
import { NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { requireAuth } from '@/lib/auth';

export async function GET(request: Request) {
  try {
    const authCheck = await requireAuth(request);
    if (authCheck instanceof NextResponse) {
      return authCheck;
    }

    // Get last 20 transactions
    const transactionsSnapshot = await db
      .collection('transactions')
      .orderBy('createdAt', 'desc')
      .limit(20)
      .get();

    const activities = await Promise.all(
      transactionsSnapshot.docs.map(async (doc) => {
        const data = doc.data();
        
        // Get user info
        let userName = 'Unknown User';
        let miroId = '';
        if (data.userId) {
          const userDoc = await db.collection('users').doc(data.userId).get();
          if (userDoc.exists) {
            const userData = userDoc.data();
            userName = userData?.displayName || userData?.email || 'User';
            miroId = userData?.miroId || '';
          }
        }

        return {
          id: doc.id,
          type: data.type,
          amount: data.amount,
          description: data.description || '',
          userName,
          miroId,
          createdAt: data.createdAt?.toDate().toISOString(),
        };
      })
    );

    return NextResponse.json({ data: activities });
  } catch (error) {
    console.error('Recent activities error:', error);
    return NextResponse.json(
      { error: 'Failed to fetch recent activities' },
      { status: 500 }
    );
  }
}
```

---

### Step 2: Create Dashboard UI Components

#### 2.1 Create Metric Card Component

**File:** `admin-panel/src/components/dashboard/MetricCard.tsx`

```typescript
import { LucideIcon } from 'lucide-react';

interface MetricCardProps {
  title: string;
  value: string | number;
  icon: LucideIcon;
  description?: string;
  trend?: {
    value: number;
    isPositive: boolean;
  };
  isLoading?: boolean;
}

export function MetricCard({
  title,
  value,
  icon: Icon,
  description,
  trend,
  isLoading,
}: MetricCardProps) {
  if (isLoading) {
    return (
      <div className="bg-white rounded-xl shadow p-6 animate-pulse">
        <div className="h-4 bg-gray-200 rounded w-1/2 mb-4"></div>
        <div className="h-8 bg-gray-200 rounded w-3/4"></div>
      </div>
    );
  }

  return (
    <div className="bg-white rounded-xl shadow hover:shadow-md transition-shadow p-6">
      <div className="flex items-center justify-between mb-4">
        <p className="text-sm font-medium text-gray-600">{title}</p>
        <div className="p-2 bg-blue-50 rounded-lg">
          <Icon className="w-5 h-5 text-blue-600" />
        </div>
      </div>
      
      <div className="space-y-2">
        <p className="text-3xl font-bold text-gray-900">
          {typeof value === 'number' ? value.toLocaleString() : value}
        </p>
        
        {description && (
          <p className="text-sm text-gray-500">{description}</p>
        )}
        
        {trend && (
          <div className="flex items-center text-sm">
            <span
              className={`font-medium ${
                trend.isPositive ? 'text-green-600' : 'text-red-600'
              }`}
            >
              {trend.isPositive ? '↑' : '↓'} {Math.abs(trend.value)}%
            </span>
            <span className="text-gray-500 ml-2">vs last month</span>
          </div>
        )}
      </div>
    </div>
  );
}
```

#### 2.2 Create User Growth Chart Component

**File:** `admin-panel/src/components/dashboard/UserGrowthChart.tsx`

```typescript
'use client';

import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import { format, parseISO } from 'date-fns';

interface UserGrowthChartProps {
  data: Array<{
    date: string;
    count: number;
    cumulative: number;
  }>;
  isLoading?: boolean;
}

export function UserGrowthChart({ data, isLoading }: UserGrowthChartProps) {
  if (isLoading) {
    return (
      <div className="bg-white rounded-xl shadow p-6 h-80 animate-pulse">
        <div className="h-4 bg-gray-200 rounded w-1/4 mb-4"></div>
        <div className="h-64 bg-gray-100 rounded"></div>
      </div>
    );
  }

  if (!data || data.length === 0) {
    return (
      <div className="bg-white rounded-xl shadow p-6 h-80 flex items-center justify-center">
        <p className="text-gray-500">No data available</p>
      </div>
    );
  }

  return (
    <div className="bg-white rounded-xl shadow p-6">
      <h3 className="text-lg font-semibold mb-4">User Growth (Last 30 Days)</h3>
      
      <ResponsiveContainer width="100%" height={300}>
        <LineChart data={data}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis
            dataKey="date"
            tickFormatter={(date) => format(parseISO(date), 'MMM dd')}
          />
          <YAxis />
          <Tooltip
            labelFormatter={(date) => format(parseISO(date as string), 'PPP')}
            formatter={(value: number) => [value, 'New Users']}
          />
          <Line
            type="monotone"
            dataKey="count"
            stroke="#3b82f6"
            strokeWidth={2}
            dot={{ fill: '#3b82f6' }}
          />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}
```

#### 2.3 Create Streak Distribution Chart Component

**File:** `admin-panel/src/components/dashboard/StreakDistributionChart.tsx`

```typescript
'use client';

import { PieChart, Pie, Cell, ResponsiveContainer, Legend, Tooltip } from 'recharts';

interface StreakDistributionChartProps {
  data: Array<{
    name: string;
    value: number;
    color: string;
  }>;
  isLoading?: boolean;
}

export function StreakDistributionChart({ data, isLoading }: StreakDistributionChartProps) {
  if (isLoading) {
    return (
      <div className="bg-white rounded-xl shadow p-6 h-80 animate-pulse">
        <div className="h-4 bg-gray-200 rounded w-1/3 mb-4"></div>
        <div className="h-64 bg-gray-100 rounded"></div>
      </div>
    );
  }

  if (!data || data.length === 0) {
    return (
      <div className="bg-white rounded-xl shadow p-6 h-80 flex items-center justify-center">
        <p className="text-gray-500">No data available</p>
      </div>
    );
  }

  return (
    <div className="bg-white rounded-xl shadow p-6">
      <h3 className="text-lg font-semibold mb-4">Streak Tier Distribution</h3>
      
      <ResponsiveContainer width="100%" height={300}>
        <PieChart>
          <Pie
            data={data}
            cx="50%"
            cy="50%"
            labelLine={false}
            label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
            outerRadius={100}
            fill="#8884d8"
            dataKey="value"
          >
            {data.map((entry, index) => (
              <Cell key={`cell-${index}`} fill={entry.color} />
            ))}
          </Pie>
          <Tooltip />
          <Legend />
        </PieChart>
      </ResponsiveContainer>
    </div>
  );
}
```

#### 2.4 Create Recent Activities Component

**File:** `admin-panel/src/components/dashboard/RecentActivities.tsx`

```typescript
'use client';

import { formatDistanceToNow } from 'date-fns';
import { Activity, Zap, Gift, TrendingUp, Star } from 'lucide-react';

interface Activity {
  id: string;
  type: string;
  amount: number;
  description: string;
  userName: string;
  miroId: string;
  createdAt: string;
}

interface RecentActivitiesProps {
  activities: Activity[];
  isLoading?: boolean;
}

export function RecentActivities({ activities, isLoading }: RecentActivitiesProps) {
  if (isLoading) {
    return (
      <div className="bg-white rounded-xl shadow p-6">
        <h3 className="text-lg font-semibold mb-4">Recent Activities</h3>
        <div className="space-y-4">
          {[1, 2, 3, 4, 5].map((i) => (
            <div key={i} className="flex items-center space-x-3 animate-pulse">
              <div className="w-10 h-10 bg-gray-200 rounded-full"></div>
              <div className="flex-1">
                <div className="h-4 bg-gray-200 rounded w-3/4 mb-2"></div>
                <div className="h-3 bg-gray-200 rounded w-1/2"></div>
              </div>
            </div>
          ))}
        </div>
      </div>
    );
  }

  const getActivityIcon = (type: string) => {
    switch (type) {
      case 'ai_analysis':
        return <Zap className="w-5 h-5 text-yellow-600" />;
      case 'daily_check_in':
        return <Star className="w-5 h-5 text-blue-600" />;
      case 'challenge_reward':
        return <TrendingUp className="w-5 h-5 text-green-600" />;
      case 'welcome_gift':
        return <Gift className="w-5 h-5 text-purple-600" />;
      default:
        return <Activity className="w-5 h-5 text-gray-600" />;
    }
  };

  const getActivityColor = (amount: number) => {
    return amount > 0 ? 'text-green-600' : 'text-red-600';
  };

  return (
    <div className="bg-white rounded-xl shadow p-6">
      <h3 className="text-lg font-semibold mb-4">Recent Activities</h3>
      
      {activities.length === 0 ? (
        <p className="text-gray-500 text-center py-8">No recent activities</p>
      ) : (
        <div className="space-y-4">
          {activities.map((activity) => (
            <div key={activity.id} className="flex items-start space-x-3 pb-4 border-b last:border-b-0">
              <div className="p-2 bg-gray-50 rounded-lg">
                {getActivityIcon(activity.type)}
              </div>
              
              <div className="flex-1 min-w-0">
                <div className="flex items-center justify-between">
                  <p className="text-sm font-medium text-gray-900 truncate">
                    {activity.userName}
                    {activity.miroId && (
                      <span className="text-gray-500 ml-2 text-xs">
                        ({activity.miroId})
                      </span>
                    )}
                  </p>
                  <span className={`text-sm font-semibold ${getActivityColor(activity.amount)}`}>
                    {activity.amount > 0 ? '+' : ''}{activity.amount} ⚡
                  </span>
                </div>
                
                <p className="text-sm text-gray-600 mt-1">
                  {activity.description || activity.type.replace(/_/g, ' ')}
                </p>
                
                <p className="text-xs text-gray-400 mt-1">
                  {formatDistanceToNow(new Date(activity.createdAt), { addSuffix: true })}
                </p>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
```

---

### Step 3: Create Dashboard Page

#### 3.1 Update Root Page with Dashboard

**File:** `admin-panel/src/app/page.tsx`

```typescript
import { redirect } from 'next/navigation';
import { cookies } from 'next/headers';
import Link from 'next/link';
import { DashboardContent } from '@/components/dashboard/DashboardContent';

export default async function RootPage() {
  const cookieStore = await cookies();
  const token = cookieStore.get('admin_token');
  
  if (!token) {
    redirect('/login');
  }
  
  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="bg-white shadow-sm border-b sticky top-0 z-10">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-16 items-center">
            <Link href="/" className="text-2xl font-bold text-blue-600 hover:text-blue-700">
              🔥 MiRO Admin
            </Link>
            <form action="/api/auth/logout" method="POST">
              <button 
                type="submit"
                className="px-4 py-2 bg-red-500 text-white rounded-lg hover:bg-red-600 transition"
              >
                Logout
              </button>
            </form>
          </div>
        </div>
      </nav>
      
      <main className="max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
        <h2 className="text-3xl font-bold mb-8">Dashboard</h2>
        <DashboardContent />
      </main>
    </div>
  );
}
```

#### 3.2 Create Dashboard Content Component

**File:** `admin-panel/src/components/dashboard/DashboardContent.tsx`

```typescript
'use client';

import { useEffect, useState } from 'react';
import { Users, Zap, Brain, TrendingUp } from 'lucide-react';
import { MetricCard } from './MetricCard';
import { UserGrowthChart } from './UserGrowthChart';
import { StreakDistributionChart } from './StreakDistributionChart';
import { RecentActivities } from './RecentActivities';

interface DashboardStats {
  users: {
    total: number;
    active7d: number;
    active30d: number;
  };
  energy: {
    totalConsumed: number;
    avgPerUser: number;
  };
  ai: {
    totalAnalyses: number;
    avgPerUser: number;
  };
}

export function DashboardContent() {
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [userGrowth, setUserGrowth] = useState<any[]>([]);
  const [streakDistribution, setStreakDistribution] = useState<any[]>([]);
  const [activities, setActivities] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    try {
      setIsLoading(true);
      setError(null);

      // Fetch all data in parallel
      const [statsRes, growthRes, streakRes, activitiesRes] = await Promise.all([
        fetch('/api/dashboard/stats'),
        fetch('/api/dashboard/user-growth'),
        fetch('/api/dashboard/streak-distribution'),
        fetch('/api/dashboard/recent-activities'),
      ]);

      if (!statsRes.ok || !growthRes.ok || !streakRes.ok || !activitiesRes.ok) {
        throw new Error('Failed to fetch dashboard data');
      }

      const [statsData, growthData, streakData, activitiesData] = await Promise.all([
        statsRes.json(),
        growthRes.json(),
        streakRes.json(),
        activitiesRes.json(),
      ]);

      setStats(statsData);
      setUserGrowth(growthData.data || []);
      setStreakDistribution(streakData.data || []);
      setActivities(activitiesData.data || []);
    } catch (err) {
      console.error('Dashboard fetch error:', err);
      setError('Failed to load dashboard data. Please try again.');
    } finally {
      setIsLoading(false);
    }
  };

  if (error) {
    return (
      <div className="bg-red-50 border border-red-200 rounded-lg p-6 text-center">
        <p className="text-red-800 font-medium">{error}</p>
        <button
          onClick={fetchDashboardData}
          className="mt-4 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700"
        >
          Retry
        </button>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      {/* Metric Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <MetricCard
          title="Total Users"
          value={stats?.users.total || 0}
          icon={Users}
          description="All registered users"
          isLoading={isLoading}
        />
        <MetricCard
          title="Active Users (7d)"
          value={stats?.users.active7d || 0}
          icon={TrendingUp}
          description="Users active in last 7 days"
          isLoading={isLoading}
        />
        <MetricCard
          title="Total Energy Consumed"
          value={stats?.energy.totalConsumed || 0}
          icon={Zap}
          description={`Avg: ${stats?.energy.avgPerUser || 0} per user`}
          isLoading={isLoading}
        />
        <MetricCard
          title="AI Analyses"
          value={stats?.ai.totalAnalyses || 0}
          icon={Brain}
          description={`Avg: ${stats?.ai.avgPerUser || 0} per user`}
          isLoading={isLoading}
        />
      </div>

      {/* Charts Row */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <UserGrowthChart data={userGrowth} isLoading={isLoading} />
        <StreakDistributionChart data={streakDistribution} isLoading={isLoading} />
      </div>

      {/* Recent Activities */}
      <RecentActivities activities={activities} isLoading={isLoading} />
    </div>
  );
}
```

---

## 🧪 Testing

### Step 1: Start Development Server

```bash
cd admin-panel
npm run dev
```

Server should start on `http://localhost:3002`

### Step 2: Test Each Component

#### 2.1 Test Stats API
Open browser console and run:
```javascript
fetch('/api/dashboard/stats')
  .then(r => r.json())
  .then(console.log);
```

Expected output:
```json
{
  "users": {
    "total": 150,
    "active7d": 45,
    "active30d": 89
  },
  "energy": {
    "totalConsumed": 12500,
    "avgPerUser": 83
  },
  "ai": {
    "totalAnalyses": 892,
    "avgPerUser": 5.9
  }
}
```

#### 2.2 Test User Growth API
```javascript
fetch('/api/dashboard/user-growth')
  .then(r => r.json())
  .then(console.log);
```

Expected: Array of daily user counts for last 30 days

#### 2.3 Test Dashboard UI
1. Login to admin panel
2. Dashboard should show:
   - ✅ 4 metric cards with numbers
   - ✅ Line chart showing user growth
   - ✅ Pie chart showing streak distribution
   - ✅ Recent activities list

### Step 3: Test Edge Cases

#### 3.1 Test Empty Data
Create a test Firebase project with no data and verify:
- Metric cards show 0
- Charts show "No data available"
- Activities show "No recent activities"

#### 3.2 Test Loading States
Throttle network in DevTools to "Slow 3G" and verify:
- Skeleton loaders appear
- Smooth transition when data loads

#### 3.3 Test Error Handling
1. Stop Firebase emulator (if using)
2. Verify error message appears
3. Click "Retry" button
4. Verify data loads after Firebase restarts

---

## 🐛 Troubleshooting

### Issue: "Failed to fetch dashboard stats"

**Cause:** Firebase Admin SDK not initialized or service account key missing

**Solution:**
1. Check `admin-panel/serviceAccountKey.json` exists
2. Verify `.env.local` has correct Firebase credentials
3. Check Firebase Admin SDK initialization in `lib/firebase-admin.ts`

### Issue: Charts not rendering

**Cause:** Missing Recharts dependency or data format issue

**Solution:**
```bash
cd admin-panel
npm install recharts
```

Verify data format matches expected shape for each chart.

### Issue: "count() is not a function"

**Cause:** Using older Firebase Admin SDK version

**Solution:**
```bash
cd admin-panel
npm install firebase-admin@latest
```

The `count()` method was added in Firebase Admin SDK v11.

### Issue: Slow dashboard loading (> 5 seconds)

**Cause:** Too many Firestore queries or unindexed queries

**Solution:**
1. Create composite indexes in Firebase Console
2. Use caching for stats that don't change frequently
3. Consider pre-aggregating data in a `stats` collection

**Create these indexes in Firebase Console:**
- Collection: `users`, Fields: `lastActiveAt ASC`
- Collection: `transactions`, Fields: `type ASC`, `createdAt DESC`

### Issue: Activities showing "Unknown User"

**Cause:** User document doesn't exist or was deleted

**Solution:**
Add null checks and fallback values:
```typescript
const userName = userData?.displayName || userData?.email || 'Deleted User';
```

---

## ✅ Completion Checklist

Before marking this task as complete:

- [ ] All API routes created and returning correct data
- [ ] All UI components rendering without errors
- [ ] Dashboard shows real data from Firebase
- [ ] Charts display correctly on all screen sizes (mobile, tablet, desktop)
- [ ] Loading states work smoothly
- [ ] Error handling works (test by disconnecting Firebase)
- [ ] Recent activities show correct user info
- [ ] All Firestore queries are indexed (no warnings in console)
- [ ] Page loads in < 3 seconds
- [ ] No console errors or warnings
- [ ] Code follows existing project conventions
- [ ] Tested on Chrome, Firefox, and Safari

---

## 📸 Expected Result

When complete, your dashboard should look like:

```
┌─────────────────────────────────────────────────────────────┐
│  Dashboard                                     [Logout]      │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌────────┐ │
│  │ 👥 Total    │ │ 📈 Active   │ │ ⚡ Energy   │ │ 🧠 AI  │ │
│  │ Users       │ │ Users (7d)  │ │ Consumed    │ │ Analyses│ │
│  │             │ │             │ │             │ │        │ │
│  │    1,234    │ │     456     │ │   45,678    │ │  8,901 │ │
│  └─────────────┘ └─────────────┘ └─────────────┘ └────────┘ │
│                                                               │
│  ┌─────────────────────────────┐ ┌───────────────────────┐  │
│  │ User Growth (Last 30 Days)  │ │ Streak Distribution   │  │
│  │                             │ │                       │  │
│  │     [Line Chart]            │ │    [Pie Chart]        │  │
│  │                             │ │                       │  │
│  └─────────────────────────────┘ └───────────────────────┘  │
│                                                               │
│  ┌─────────────────────────────────────────────────────────┐│
│  │ Recent Activities                                        ││
│  │                                                          ││
│  │ ⚡ User123 (MR-ABC123) used AI analysis    -5 ⚡  2m ago││
│  │ ⭐ User456 (MR-DEF456) daily check-in      +3 ⚡  5m ago││
│  │ 🎁 User789 (MR-GHI789) welcome gift       +50 ⚡ 10m ago││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

---

## 🚀 Next Steps

After completing this task:
1. Take screenshots of the dashboard
2. Test with different data volumes
3. Request code review
4. Move to **Task 3: User Management**

---

**Documentation Version:** 1.0  
**Last Updated:** 2026-02-17  
**Author:** Senior Developer  
**For:** Junior Developer (Composer)
