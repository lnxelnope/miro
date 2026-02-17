# Phase 3 - Task 3: User Management

**Status:** 📝 Ready for Implementation  
**Estimated Time:** 8-10 hours  
**Difficulty:** ⭐⭐⭐⭐ Medium-Hard  
**Prerequisites:** Task 1 & Task 2 must be completed

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

In this task, you will create a comprehensive user management system that allows admins to:

- **View all users** in a searchable, sortable, paginated table
- **Search users** by MiRO ID, email, or name
- **Filter users** by streak tier, registration date, activity status
- **View user details** including profile, balance, transactions, challenges, milestones
- **Perform admin actions** like adjusting balance, resetting streak, banning users
- **Export user data** for analysis

This is a complex task involving multiple API routes, complex Firestore queries, and interactive UI components.

---

## 📊 Requirements

### Functional Requirements
- [ ] User list page with table view
- [ ] Search by MiRO ID, email, or display name
- [ ] Filter by streak tier, active status, date range
- [ ] Sort by any column (name, email, created date, balance, etc.)
- [ ] Pagination (25 users per page)
- [ ] Click user row to view details
- [ ] User detail modal/page showing:
  - Profile information
  - Current balance & streak
  - Transaction history
  - Challenge progress
  - Milestone status
- [ ] Admin actions:
  - Adjust energy balance (+/-)
  - Reset streak tier
  - Ban/unban user
  - View full activity log
- [ ] Export user list to CSV

### Non-Functional Requirements
- [ ] Table should load < 2 seconds
- [ ] Smooth pagination with no flicker
- [ ] Responsive on all devices
- [ ] Optimistic UI updates
- [ ] Confirmation dialogs for destructive actions

---

## 🛠️ Tech Stack

- **Next.js 16** - API routes & pages
- **Firebase Admin SDK** - Firestore queries
- **Shadcn/ui Table** - Data table component
- **React Hook Form** - Form handling
- **Zod** - Form validation
- **TanStack Table (React Table v8)** - Advanced table features
- **date-fns** - Date formatting

---

## 🚀 Step-by-Step Implementation

### Step 1: Create User List API Routes

#### 1.1 Create Users List API with Pagination

**File:** `admin-panel/src/app/api/users/list/route.ts`

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { requireAuth } from '@/lib/auth';

export async function GET(request: NextRequest) {
  try {
    const authCheck = await requireAuth(request);
    if (authCheck instanceof NextResponse) {
      return authCheck;
    }

    // Get query parameters
    const searchParams = request.nextUrl.searchParams;
    const page = parseInt(searchParams.get('page') || '1');
    const limit = parseInt(searchParams.get('limit') || '25');
    const search = searchParams.get('search') || '';
    const tierFilter = searchParams.get('tier') || '';
    const sortBy = searchParams.get('sortBy') || 'createdAt';
    const sortOrder = searchParams.get('sortOrder') || 'desc';

    // Build query
    let query = db.collection('users');

    // Apply tier filter
    if (tierFilter && tierFilter !== 'all') {
      query = query.where('gamificationState.streakTier', '==', tierFilter) as any;
    }

    // Apply sorting
    query = query.orderBy(sortBy, sortOrder as 'asc' | 'desc') as any;

    // Get total count (for pagination)
    const countSnapshot = await query.count().get();
    const totalUsers = countSnapshot.data().count;
    const totalPages = Math.ceil(totalUsers / limit);

    // Apply pagination
    const offset = (page - 1) * limit;
    query = query.limit(limit) as any;
    
    if (offset > 0) {
      // For pagination, we need to use cursor-based approach
      // This is a simplified version - for production, use startAfter()
      query = query.offset(offset) as any;
    }

    // Execute query
    const snapshot = await query.get();

    // Format users data
    let users = snapshot.docs.map((doc) => {
      const data = doc.data();
      return {
        id: doc.id,
        miroId: data.miroId || '',
        email: data.email || '',
        displayName: data.displayName || '',
        balance: data.balance || 0,
        createdAt: data.createdAt?.toDate().toISOString() || null,
        lastActiveAt: data.lastActiveAt?.toDate().toISOString() || null,
        streakTier: data.gamificationState?.streakTier || 'none',
        currentStreak: data.gamificationState?.currentStreak || 0,
        isBanned: data.isBanned || false,
      };
    });

    // Apply client-side search filter (case-insensitive)
    if (search) {
      const searchLower = search.toLowerCase();
      users = users.filter(
        (user) =>
          user.miroId.toLowerCase().includes(searchLower) ||
          user.email.toLowerCase().includes(searchLower) ||
          user.displayName.toLowerCase().includes(searchLower)
      );
    }

    return NextResponse.json({
      users,
      pagination: {
        page,
        limit,
        totalUsers,
        totalPages,
      },
    });
  } catch (error) {
    console.error('Users list error:', error);
    return NextResponse.json(
      { error: 'Failed to fetch users list' },
      { status: 500 }
    );
  }
}
```

#### 1.2 Create User Detail API

**File:** `admin-panel/src/app/api/users/[userId]/route.ts`

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { requireAuth } from '@/lib/auth';

export async function GET(
  request: NextRequest,
  { params }: { params: { userId: string } }
) {
  try {
    const authCheck = await requireAuth(request);
    if (authCheck instanceof NextResponse) {
      return authCheck;
    }

    const { userId } = params;

    // Get user document
    const userDoc = await db.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      return NextResponse.json(
        { error: 'User not found' },
        { status: 404 }
      );
    }

    const userData = userDoc.data()!;

    // Get user transactions (last 50)
    const transactionsSnapshot = await db
      .collection('transactions')
      .where('userId', '==', userId)
      .orderBy('createdAt', 'desc')
      .limit(50)
      .get();

    const transactions = transactionsSnapshot.docs.map((doc) => {
      const data = doc.data();
      return {
        id: doc.id,
        type: data.type,
        amount: data.amount,
        description: data.description,
        createdAt: data.createdAt?.toDate().toISOString(),
      };
    });

    // Format user data
    const user = {
      id: userDoc.id,
      miroId: userData.miroId || '',
      email: userData.email || '',
      displayName: userData.displayName || '',
      phoneNumber: userData.phoneNumber || '',
      balance: userData.balance || 0,
      createdAt: userData.createdAt?.toDate().toISOString() || null,
      lastActiveAt: userData.lastActiveAt?.toDate().toISOString() || null,
      isBanned: userData.isBanned || false,
      
      // Gamification state
      gamification: {
        streakTier: userData.gamificationState?.streakTier || 'none',
        currentStreak: userData.gamificationState?.currentStreak || 0,
        lastCheckInDate: userData.gamificationState?.lastCheckInDate || null,
        longestStreak: userData.gamificationState?.longestStreak || 0,
        totalCheckIns: userData.gamificationState?.totalCheckIns || 0,
      },

      // Weekly challenge
      weeklyChallenge: userData.weeklyChallenge || null,

      // Milestones
      milestones: userData.milestones || {},

      // Referral
      referralCode: userData.referralCode || null,
      referredBy: userData.referredBy || null,
      referralCount: userData.referralStats?.totalReferred || 0,

      // Stats
      lifetimeEnergyEarned: userData.lifetimeEnergyEarned || 0,
      lifetimeEnergySpent: userData.lifetimeEnergySpent || 0,
      totalAiAnalyses: userData.totalAiAnalyses || 0,

      transactions,
    };

    return NextResponse.json(user);
  } catch (error) {
    console.error('User detail error:', error);
    return NextResponse.json(
      { error: 'Failed to fetch user details' },
      { status: 500 }
    );
  }
}
```

#### 1.3 Create Adjust Balance API

**File:** `admin-panel/src/app/api/users/[userId]/adjust-balance/route.ts`

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { requireAuth } from '@/lib/auth';
import { FieldValue } from 'firebase-admin/firestore';

export async function POST(
  request: NextRequest,
  { params }: { params: { userId: string } }
) {
  try {
    const authCheck = await requireAuth(request);
    if (authCheck instanceof NextResponse) {
      return authCheck;
    }

    const { userId } = params;
    const body = await request.json();
    const { amount, reason } = body;

    if (typeof amount !== 'number' || amount === 0) {
      return NextResponse.json(
        { error: 'Invalid amount' },
        { status: 400 }
      );
    }

    // Update user balance
    const userRef = db.collection('users').doc(userId);
    await userRef.update({
      balance: FieldValue.increment(amount),
    });

    // Create transaction record
    await db.collection('transactions').add({
      userId,
      type: 'admin_adjustment',
      amount,
      description: reason || 'Admin balance adjustment',
      createdAt: FieldValue.serverTimestamp(),
      adjustedBy: 'admin', // In production, track which admin did this
    });

    // Get updated user data
    const userDoc = await userRef.get();
    const userData = userDoc.data();

    return NextResponse.json({
      success: true,
      newBalance: userData?.balance || 0,
    });
  } catch (error) {
    console.error('Adjust balance error:', error);
    return NextResponse.json(
      { error: 'Failed to adjust balance' },
      { status: 500 }
    );
  }
}
```

#### 1.4 Create Reset Streak API

**File:** `admin-panel/src/app/api/users/[userId]/reset-streak/route.ts`

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { requireAuth } from '@/lib/auth';

export async function POST(
  request: NextRequest,
  { params }: { params: { userId: string } }
) {
  try {
    const authCheck = await requireAuth(request);
    if (authCheck instanceof NextResponse) {
      return authCheck;
    }

    const { userId } = params;

    // Reset streak to zero
    const userRef = db.collection('users').doc(userId);
    await userRef.update({
      'gamificationState.currentStreak': 0,
      'gamificationState.streakTier': 'none',
      'gamificationState.lastCheckInDate': null,
    });

    return NextResponse.json({
      success: true,
      message: 'Streak reset successfully',
    });
  } catch (error) {
    console.error('Reset streak error:', error);
    return NextResponse.json(
      { error: 'Failed to reset streak' },
      { status: 500 }
    );
  }
}
```

#### 1.5 Create Ban User API

**File:** `admin-panel/src/app/api/users/[userId]/ban/route.ts`

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { requireAuth } from '@/lib/auth';

export async function POST(
  request: NextRequest,
  { params }: { params: { userId: string } }
) {
  try {
    const authCheck = await requireAuth(request);
    if (authCheck instanceof NextResponse) {
      return authCheck;
    }

    const { userId } = params;
    const body = await request.json();
    const { banned, reason } = body;

    // Update user ban status
    const userRef = db.collection('users').doc(userId);
    await userRef.update({
      isBanned: banned,
      banReason: banned ? reason : null,
      bannedAt: banned ? new Date() : null,
    });

    return NextResponse.json({
      success: true,
      message: banned ? 'User banned successfully' : 'User unbanned successfully',
    });
  } catch (error) {
    console.error('Ban user error:', error);
    return NextResponse.json(
      { error: 'Failed to update ban status' },
      { status: 500 }
    );
  }
}
```

---

### Step 2: Create User Management UI Components

#### 2.1 Install TanStack Table

```bash
cd admin-panel
npm install @tanstack/react-table
```

#### 2.2 Create Users Table Component

**File:** `admin-panel/src/components/users/UsersTable.tsx`

```typescript
'use client';

import { useState } from 'react';
import {
  useReactTable,
  getCoreRowModel,
  flexRender,
  ColumnDef,
} from '@tanstack/react-table';
import { formatDistanceToNow } from 'date-fns';
import { Search, Filter, ChevronLeft, ChevronRight } from 'lucide-react';

interface User {
  id: string;
  miroId: string;
  email: string;
  displayName: string;
  balance: number;
  createdAt: string | null;
  lastActiveAt: string | null;
  streakTier: string;
  currentStreak: number;
  isBanned: boolean;
}

interface UsersTableProps {
  users: User[];
  totalPages: number;
  currentPage: number;
  onPageChange: (page: number) => void;
  onUserClick: (userId: string) => void;
  isLoading?: boolean;
}

export function UsersTable({
  users,
  totalPages,
  currentPage,
  onPageChange,
  onUserClick,
  isLoading,
}: UsersTableProps) {
  const getStreakTierBadge = (tier: string) => {
    const colors: Record<string, string> = {
      bronze: 'bg-orange-100 text-orange-800',
      silver: 'bg-gray-100 text-gray-800',
      gold: 'bg-yellow-100 text-yellow-800',
      diamond: 'bg-blue-100 text-blue-800',
      none: 'bg-gray-50 text-gray-500',
    };

    return (
      <span className={`px-2 py-1 rounded-full text-xs font-medium ${colors[tier] || colors.none}`}>
        {tier === 'none' ? 'No Streak' : tier.toUpperCase()}
      </span>
    );
  };

  const columns: ColumnDef<User>[] = [
    {
      accessorKey: 'miroId',
      header: 'MiRO ID',
      cell: ({ row }) => (
        <span className="font-mono text-sm font-medium">{row.original.miroId}</span>
      ),
    },
    {
      accessorKey: 'displayName',
      header: 'Name',
      cell: ({ row }) => (
        <div>
          <div className="font-medium">{row.original.displayName || 'N/A'}</div>
          <div className="text-sm text-gray-500">{row.original.email}</div>
        </div>
      ),
    },
    {
      accessorKey: 'balance',
      header: 'Balance',
      cell: ({ row }) => (
        <span className="font-semibold">
          {row.original.balance} ⚡
        </span>
      ),
    },
    {
      accessorKey: 'streakTier',
      header: 'Streak',
      cell: ({ row }) => (
        <div className="space-y-1">
          {getStreakTierBadge(row.original.streakTier)}
          <div className="text-xs text-gray-500">
            {row.original.currentStreak} days
          </div>
        </div>
      ),
    },
    {
      accessorKey: 'lastActiveAt',
      header: 'Last Active',
      cell: ({ row }) => {
        if (!row.original.lastActiveAt) return <span className="text-gray-400">Never</span>;
        return (
          <span className="text-sm text-gray-600">
            {formatDistanceToNow(new Date(row.original.lastActiveAt), { addSuffix: true })}
          </span>
        );
      },
    },
    {
      accessorKey: 'createdAt',
      header: 'Joined',
      cell: ({ row }) => {
        if (!row.original.createdAt) return <span className="text-gray-400">Unknown</span>;
        return (
          <span className="text-sm text-gray-600">
            {formatDistanceToNow(new Date(row.original.createdAt), { addSuffix: true })}
          </span>
        );
      },
    },
    {
      id: 'actions',
      header: 'Status',
      cell: ({ row }) => (
        <div>
          {row.original.isBanned ? (
            <span className="px-2 py-1 bg-red-100 text-red-800 rounded text-xs font-medium">
              BANNED
            </span>
          ) : (
            <span className="px-2 py-1 bg-green-100 text-green-800 rounded text-xs font-medium">
              ACTIVE
            </span>
          )}
        </div>
      ),
    },
  ];

  const table = useReactTable({
    data: users,
    columns,
    getCoreRowModel: getCoreRowModel(),
  });

  if (isLoading) {
    return (
      <div className="bg-white rounded-xl shadow">
        <div className="p-6 space-y-4">
          {[1, 2, 3, 4, 5].map((i) => (
            <div key={i} className="animate-pulse flex space-x-4">
              <div className="flex-1 space-y-3">
                <div className="h-4 bg-gray-200 rounded w-3/4"></div>
                <div className="h-4 bg-gray-200 rounded w-1/2"></div>
              </div>
            </div>
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="bg-white rounded-xl shadow overflow-hidden">
      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            {table.getHeaderGroups().map((headerGroup) => (
              <tr key={headerGroup.id}>
                {headerGroup.headers.map((header) => (
                  <th
                    key={header.id}
                    className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider"
                  >
                    {flexRender(header.column.columnDef.header, header.getContext())}
                  </th>
                ))}
              </tr>
            ))}
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {table.getRowModel().rows.map((row) => (
              <tr
                key={row.id}
                onClick={() => onUserClick(row.original.id)}
                className="hover:bg-gray-50 cursor-pointer transition"
              >
                {row.getVisibleCells().map((cell) => (
                  <td key={cell.id} className="px-6 py-4 whitespace-nowrap">
                    {flexRender(cell.column.columnDef.cell, cell.getContext())}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Pagination */}
      <div className="bg-gray-50 px-6 py-4 flex items-center justify-between border-t">
        <div className="text-sm text-gray-700">
          Page {currentPage} of {totalPages}
        </div>
        <div className="flex space-x-2">
          <button
            onClick={() => onPageChange(currentPage - 1)}
            disabled={currentPage === 1}
            className="px-3 py-1 border rounded-lg disabled:opacity-50 disabled:cursor-not-allowed hover:bg-white transition"
          >
            <ChevronLeft className="w-5 h-5" />
          </button>
          <button
            onClick={() => onPageChange(currentPage + 1)}
            disabled={currentPage === totalPages}
            className="px-3 py-1 border rounded-lg disabled:opacity-50 disabled:cursor-not-allowed hover:bg-white transition"
          >
            <ChevronRight className="w-5 h-5" />
          </button>
        </div>
      </div>
    </div>
  );
}
```

#### 2.3 Create User Detail Modal

**File:** `admin-panel/src/components/users/UserDetailModal.tsx`

```typescript
'use client';

import { useEffect, useState } from 'react';
import { X, Zap, TrendingUp, Award, Users } from 'lucide-react';
import { formatDistanceToNow, format } from 'date-fns';
import { AdjustBalanceForm } from './AdjustBalanceForm';
import { BanUserForm } from './BanUserForm';

interface UserDetailModalProps {
  userId: string;
  isOpen: boolean;
  onClose: () => void;
  onUpdate: () => void;
}

export function UserDetailModal({ userId, isOpen, onClose, onUpdate }: UserDetailModalProps) {
  const [user, setUser] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [activeTab, setActiveTab] = useState<'overview' | 'transactions' | 'actions'>('overview');

  useEffect(() => {
    if (isOpen && userId) {
      fetchUserDetails();
    }
  }, [isOpen, userId]);

  const fetchUserDetails = async () => {
    try {
      setIsLoading(true);
      const response = await fetch(`/api/users/${userId}`);
      if (!response.ok) throw new Error('Failed to fetch user');
      const data = await response.json();
      setUser(data);
    } catch (error) {
      console.error('Fetch user error:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const handleBalanceAdjusted = () => {
    fetchUserDetails();
    onUpdate();
  };

  const handleBanStatusChanged = () => {
    fetchUserDetails();
    onUpdate();
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl shadow-2xl max-w-4xl w-full max-h-[90vh] overflow-hidden">
        {/* Header */}
        <div className="bg-gradient-to-r from-blue-600 to-blue-700 text-white p-6 flex items-center justify-between">
          <div>
            <h2 className="text-2xl font-bold">{user?.displayName || 'Loading...'}</h2>
            <p className="text-blue-100 text-sm mt-1">{user?.miroId}</p>
          </div>
          <button
            onClick={onClose}
            className="p-2 hover:bg-blue-500 rounded-lg transition"
          >
            <X className="w-6 h-6" />
          </button>
        </div>

        {/* Tabs */}
        <div className="border-b">
          <div className="flex space-x-4 px-6">
            {['overview', 'transactions', 'actions'].map((tab) => (
              <button
                key={tab}
                onClick={() => setActiveTab(tab as any)}
                className={`py-3 px-4 font-medium border-b-2 transition ${
                  activeTab === tab
                    ? 'border-blue-600 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700'
                }`}
              >
                {tab.charAt(0).toUpperCase() + tab.slice(1)}
              </button>
            ))}
          </div>
        </div>

        {/* Content */}
        <div className="p-6 overflow-y-auto max-h-[60vh]">
          {isLoading ? (
            <div className="space-y-4">
              {[1, 2, 3].map((i) => (
                <div key={i} className="animate-pulse">
                  <div className="h-4 bg-gray-200 rounded w-3/4 mb-2"></div>
                  <div className="h-4 bg-gray-200 rounded w-1/2"></div>
                </div>
              ))}
            </div>
          ) : (
            <>
              {activeTab === 'overview' && (
                <div className="space-y-6">
                  {/* Stats Cards */}
                  <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                    <div className="bg-blue-50 rounded-lg p-4">
                      <div className="flex items-center space-x-2 mb-2">
                        <Zap className="w-5 h-5 text-blue-600" />
                        <span className="text-sm text-blue-600 font-medium">Balance</span>
                      </div>
                      <p className="text-2xl font-bold text-blue-900">{user.balance}</p>
                    </div>
                    <div className="bg-green-50 rounded-lg p-4">
                      <div className="flex items-center space-x-2 mb-2">
                        <TrendingUp className="w-5 h-5 text-green-600" />
                        <span className="text-sm text-green-600 font-medium">Streak</span>
                      </div>
                      <p className="text-2xl font-bold text-green-900">
                        {user.gamification.currentStreak}
                      </p>
                    </div>
                    <div className="bg-purple-50 rounded-lg p-4">
                      <div className="flex items-center space-x-2 mb-2">
                        <Award className="w-5 h-5 text-purple-600" />
                        <span className="text-sm text-purple-600 font-medium">Tier</span>
                      </div>
                      <p className="text-lg font-bold text-purple-900 uppercase">
                        {user.gamification.streakTier}
                      </p>
                    </div>
                    <div className="bg-orange-50 rounded-lg p-4">
                      <div className="flex items-center space-x-2 mb-2">
                        <Users className="w-5 h-5 text-orange-600" />
                        <span className="text-sm text-orange-600 font-medium">Referrals</span>
                      </div>
                      <p className="text-2xl font-bold text-orange-900">{user.referralCount}</p>
                    </div>
                  </div>

                  {/* User Info */}
                  <div className="bg-gray-50 rounded-lg p-4 space-y-3">
                    <h3 className="font-semibold text-gray-900 mb-3">Account Information</h3>
                    <div className="grid grid-cols-2 gap-4 text-sm">
                      <div>
                        <span className="text-gray-600">Email:</span>
                        <p className="font-medium">{user.email}</p>
                      </div>
                      <div>
                        <span className="text-gray-600">Phone:</span>
                        <p className="font-medium">{user.phoneNumber || 'N/A'}</p>
                      </div>
                      <div>
                        <span className="text-gray-600">Joined:</span>
                        <p className="font-medium">
                          {user.createdAt
                            ? format(new Date(user.createdAt), 'PPP')
                            : 'Unknown'}
                        </p>
                      </div>
                      <div>
                        <span className="text-gray-600">Last Active:</span>
                        <p className="font-medium">
                          {user.lastActiveAt
                            ? formatDistanceToNow(new Date(user.lastActiveAt), {
                                addSuffix: true,
                              })
                            : 'Never'}
                        </p>
                      </div>
                    </div>
                  </div>

                  {/* Gamification Stats */}
                  <div className="bg-gray-50 rounded-lg p-4 space-y-3">
                    <h3 className="font-semibold text-gray-900 mb-3">Gamification Stats</h3>
                    <div className="grid grid-cols-2 gap-4 text-sm">
                      <div>
                        <span className="text-gray-600">Total Check-ins:</span>
                        <p className="font-medium">{user.gamification.totalCheckIns}</p>
                      </div>
                      <div>
                        <span className="text-gray-600">Longest Streak:</span>
                        <p className="font-medium">{user.gamification.longestStreak} days</p>
                      </div>
                      <div>
                        <span className="text-gray-600">Energy Earned:</span>
                        <p className="font-medium">{user.lifetimeEnergyEarned} ⚡</p>
                      </div>
                      <div>
                        <span className="text-gray-600">Energy Spent:</span>
                        <p className="font-medium">{user.lifetimeEnergySpent} ⚡</p>
                      </div>
                      <div>
                        <span className="text-gray-600">AI Analyses:</span>
                        <p className="font-medium">{user.totalAiAnalyses}</p>
                      </div>
                    </div>
                  </div>
                </div>
              )}

              {activeTab === 'transactions' && (
                <div className="space-y-3">
                  <h3 className="font-semibold text-gray-900 mb-4">
                    Transaction History (Last 50)
                  </h3>
                  {user.transactions.length === 0 ? (
                    <p className="text-gray-500 text-center py-8">No transactions yet</p>
                  ) : (
                    <div className="space-y-2">
                      {user.transactions.map((tx: any) => (
                        <div
                          key={tx.id}
                          className="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
                        >
                          <div className="flex-1">
                            <p className="font-medium text-sm">
                              {tx.description || tx.type.replace(/_/g, ' ')}
                            </p>
                            <p className="text-xs text-gray-500">
                              {format(new Date(tx.createdAt), 'PPpp')}
                            </p>
                          </div>
                          <span
                            className={`font-bold ${
                              tx.amount > 0 ? 'text-green-600' : 'text-red-600'
                            }`}
                          >
                            {tx.amount > 0 ? '+' : ''}
                            {tx.amount} ⚡
                          </span>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              )}

              {activeTab === 'actions' && (
                <div className="space-y-6">
                  <AdjustBalanceForm
                    userId={userId}
                    currentBalance={user.balance}
                    onSuccess={handleBalanceAdjusted}
                  />
                  <div className="border-t pt-6">
                    <button
                      onClick={async () => {
                        if (
                          confirm('Are you sure you want to reset this user\'s streak?')
                        ) {
                          const res = await fetch(`/api/users/${userId}/reset-streak`, {
                            method: 'POST',
                          });
                          if (res.ok) {
                            alert('Streak reset successfully');
                            handleBalanceAdjusted();
                          }
                        }
                      }}
                      className="px-4 py-2 bg-yellow-500 text-white rounded-lg hover:bg-yellow-600 transition"
                    >
                      Reset Streak
                    </button>
                  </div>
                  <div className="border-t pt-6">
                    <BanUserForm
                      userId={userId}
                      isBanned={user.isBanned}
                      onSuccess={handleBanStatusChanged}
                    />
                  </div>
                </div>
              )}
            </>
          )}
        </div>
      </div>
    </div>
  );
}
```

#### 2.4 Create Adjust Balance Form

**File:** `admin-panel/src/components/users/AdjustBalanceForm.tsx`

```typescript
'use client';

import { useState } from 'react';

interface AdjustBalanceFormProps {
  userId: string;
  currentBalance: number;
  onSuccess: () => void;
}

export function AdjustBalanceForm({ userId, currentBalance, onSuccess }: AdjustBalanceFormProps) {
  const [amount, setAmount] = useState('');
  const [reason, setReason] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    const numAmount = parseInt(amount);
    if (isNaN(numAmount) || numAmount === 0) {
      alert('Please enter a valid amount');
      return;
    }

    if (!reason.trim()) {
      alert('Please provide a reason');
      return;
    }

    try {
      setIsSubmitting(true);
      const response = await fetch(`/api/users/${userId}/adjust-balance`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ amount: numAmount, reason }),
      });

      if (!response.ok) throw new Error('Failed to adjust balance');

      alert('Balance adjusted successfully');
      setAmount('');
      setReason('');
      onSuccess();
    } catch (error) {
      console.error('Adjust balance error:', error);
      alert('Failed to adjust balance');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <h3 className="font-semibold text-gray-900">Adjust Energy Balance</h3>
      <p className="text-sm text-gray-600">
        Current Balance: <span className="font-bold">{currentBalance} ⚡</span>
      </p>
      
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Amount (use negative for deduction)
        </label>
        <input
          type="number"
          value={amount}
          onChange={(e) => setAmount(e.target.value)}
          className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
          placeholder="+100 or -50"
          required
        />
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Reason
        </label>
        <textarea
          value={reason}
          onChange={(e) => setReason(e.target.value)}
          className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
          rows={3}
          placeholder="Explain why you're adjusting the balance..."
          required
        />
      </div>

      <button
        type="submit"
        disabled={isSubmitting}
        className="w-full px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 transition"
      >
        {isSubmitting ? 'Adjusting...' : 'Adjust Balance'}
      </button>
    </form>
  );
}
```

#### 2.5 Create Ban User Form

**File:** `admin-panel/src/components/users/BanUserForm.tsx`

```typescript
'use client';

import { useState } from 'react';

interface BanUserFormProps {
  userId: string;
  isBanned: boolean;
  onSuccess: () => void;
}

export function BanUserForm({ userId, isBanned, onSuccess }: BanUserFormProps) {
  const [reason, setReason] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleBanToggle = async () => {
    const newBanStatus = !isBanned;
    
    if (newBanStatus && !reason.trim()) {
      alert('Please provide a reason for banning');
      return;
    }

    const confirmed = confirm(
      newBanStatus
        ? 'Are you sure you want to BAN this user?'
        : 'Are you sure you want to UNBAN this user?'
    );

    if (!confirmed) return;

    try {
      setIsSubmitting(true);
      const response = await fetch(`/api/users/${userId}/ban`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ banned: newBanStatus, reason }),
      });

      if (!response.ok) throw new Error('Failed to update ban status');

      alert(newBanStatus ? 'User banned successfully' : 'User unbanned successfully');
      setReason('');
      onSuccess();
    } catch (error) {
      console.error('Ban user error:', error);
      alert('Failed to update ban status');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="space-y-4">
      <h3 className="font-semibold text-gray-900">Ban/Unban User</h3>
      <p className="text-sm text-gray-600">
        Current Status:{' '}
        <span className={`font-bold ${isBanned ? 'text-red-600' : 'text-green-600'}`}>
          {isBanned ? 'BANNED' : 'ACTIVE'}
        </span>
      </p>

      {!isBanned && (
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Ban Reason (required)
          </label>
          <textarea
            value={reason}
            onChange={(e) => setReason(e.target.value)}
            className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-red-500"
            rows={3}
            placeholder="Explain why you're banning this user..."
          />
        </div>
      )}

      <button
        onClick={handleBanToggle}
        disabled={isSubmitting}
        className={`w-full px-4 py-2 text-white rounded-lg transition disabled:opacity-50 ${
          isBanned
            ? 'bg-green-600 hover:bg-green-700'
            : 'bg-red-600 hover:bg-red-700'
        }`}
      >
        {isSubmitting
          ? 'Processing...'
          : isBanned
          ? 'Unban User'
          : 'Ban User'}
      </button>
    </div>
  );
}
```

---

### Step 3: Create Users Management Page

#### 3.1 Create Users Page

**File:** `admin-panel/src/app/users/page.tsx`

```typescript
'use client';

import { useEffect, useState } from 'react';
import { UsersTable } from '@/components/users/UsersTable';
import { UserDetailModal } from '@/components/users/UserDetailModal';
import { Search, Filter } from 'lucide-react';

export default function UsersPage() {
  const [users, setUsers] = useState([]);
  const [pagination, setPagination] = useState({
    page: 1,
    totalPages: 1,
  });
  const [searchQuery, setSearchQuery] = useState('');
  const [tierFilter, setTierFilter] = useState('all');
  const [isLoading, setIsLoading] = useState(true);
  const [selectedUserId, setSelectedUserId] = useState<string | null>(null);

  useEffect(() => {
    fetchUsers();
  }, [pagination.page, searchQuery, tierFilter]);

  const fetchUsers = async () => {
    try {
      setIsLoading(true);
      const params = new URLSearchParams({
        page: pagination.page.toString(),
        search: searchQuery,
        tier: tierFilter,
      });

      const response = await fetch(`/api/users/list?${params}`);
      if (!response.ok) throw new Error('Failed to fetch users');

      const data = await response.json();
      setUsers(data.users);
      setPagination(data.pagination);
    } catch (error) {
      console.error('Fetch users error:', error);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900">User Management</h1>
          <p className="text-gray-600 mt-2">Manage and monitor all MiRO users</p>
        </div>

        {/* Search & Filters */}
        <div className="bg-white rounded-xl shadow p-4 mb-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="relative">
              <Search className="absolute left-3 top-3 w-5 h-5 text-gray-400" />
              <input
                type="text"
                placeholder="Search by MiRO ID, email, or name..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full pl-10 pr-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div className="relative">
              <Filter className="absolute left-3 top-3 w-5 h-5 text-gray-400" />
              <select
                value={tierFilter}
                onChange={(e) => setTierFilter(e.target.value)}
                className="w-full pl-10 pr-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 appearance-none"
              >
                <option value="all">All Tiers</option>
                <option value="bronze">Bronze</option>
                <option value="silver">Silver</option>
                <option value="gold">Gold</option>
                <option value="diamond">Diamond</option>
                <option value="none">No Streak</option>
              </select>
            </div>
          </div>
        </div>

        {/* Users Table */}
        <UsersTable
          users={users}
          totalPages={pagination.totalPages}
          currentPage={pagination.page}
          onPageChange={(page) => setPagination({ ...pagination, page })}
          onUserClick={setSelectedUserId}
          isLoading={isLoading}
        />

        {/* User Detail Modal */}
        {selectedUserId && (
          <UserDetailModal
            userId={selectedUserId}
            isOpen={!!selectedUserId}
            onClose={() => setSelectedUserId(null)}
            onUpdate={fetchUsers}
          />
        )}
      </div>
    </div>
  );
}
```

---

## 🧪 Testing

### Step 1: Test API Routes

```javascript
// Test users list
fetch('/api/users/list?page=1&limit=25')
  .then(r => r.json())
  .then(console.log);

// Test user detail
fetch('/api/users/USER_ID_HERE')
  .then(r => r.json())
  .then(console.log);
```

### Step 2: Test UI Components

1. Navigate to `/users` page
2. Verify user table loads
3. Test search functionality
4. Test tier filter
5. Test pagination
6. Click a user row to open detail modal
7. Test all three tabs (Overview, Transactions, Actions)
8. Adjust balance and verify it updates
9. Reset streak and verify it resets
10. Ban/unban user and verify status changes

### Step 3: Test Edge Cases

- Empty search results
- No users in database
- User with no transactions
- Banned user display
- Very long user names/emails

---

## 🐛 Troubleshooting

### Issue: Pagination not working

**Solution:** Make sure Firestore indexes are created for `orderBy` queries.

### Issue: Search too slow

**Solution:** Implement Algolia or similar search service for production.

### Issue: Modal not closing

**Solution:** Check z-index and make sure backdrop click handler is working.

---

## ✅ Completion Checklist

- [ ] All API routes working
- [ ] User table displays correctly
- [ ] Search works
- [ ] Filters work
- [ ] Pagination works
- [ ] User detail modal opens
- [ ] Balance adjustment works
- [ ] Streak reset works
- [ ] Ban/unban works
- [ ] No console errors

---

**Documentation Version:** 1.0  
**Last Updated:** 2026-02-17
