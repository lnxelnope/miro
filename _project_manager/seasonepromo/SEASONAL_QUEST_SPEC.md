# Seasonal Quest System - Implementation Spec

> สำหรับ Junior Developer: ทำตาม step-by-step ตั้งแต่ Step 1 - Step 10
> ห้ามข้ามขั้นตอน ห้ามเปลี่ยนชื่อ field/function ตาม spec เป๊ะ
> เมื่อเสร็จแต่ละ step ให้ทดสอบก่อนไป step ถัดไป

---

## สารบัญ

1. [Firestore Schema](#step-1-firestore-schema)
2. [Admin API - CRUD](#step-2-admin-api-routes)
3. [Admin UI - Seasonal Quests Tab](#step-3-admin-ui)
4. [Backend - Include in Sync Responses](#step-4-backend-sync)
5. [Backend - Claim Endpoint](#step-5-backend-claim)
6. [Flutter - Data Model](#step-6-flutter-data-model)
7. [Flutter - EnergyService Pass-through](#step-7-flutter-energy-service)
8. [Flutter - GamificationProvider](#step-8-flutter-provider)
9. [Flutter - SeasonalQuestCard Widget](#step-9-flutter-widget)
10. [Flutter - QuestBar Integration + Localization](#step-10-flutter-questbar)

---

## Step 1: Firestore Schema

ไม่ต้องเขียนโค้ด แค่เข้าใจ schema ที่จะใช้

### Collection: `seasonal_quests`

แต่ละ document = 1 quest

```
seasonal_quests/{auto-id}
├── title: string              // "Happy New Year 2027"
├── description: string        // "Celebrate with free energy!"
├── icon: string               // emoji เช่น "🎄" "🎆" "🎉"
├── scheduleType: string       // "fixed_date" | "duration"
├── startDate: string          // "2026-12-25" (YYYY-MM-DD)
├── endDate: string            // "2027-01-01" (YYYY-MM-DD)
├── durationDays: number       // ใช้เฉพาะ scheduleType="duration" เช่น 7
├── claimType: string          // "daily" | "one_time"
├── rewardPerClaim: number     // จำนวน Energy ที่แจก เช่น 2
├── status: string             // "active" | "paused"
├── createdAt: Timestamp       // firebase server timestamp
└── createdBy: string          // admin email
```

**กฎสำคัญ:**
- ถ้า `scheduleType = "duration"` → `startDate` = วันที่สร้าง, `endDate` = `startDate + durationDays`
- ถ้า `scheduleType = "fixed_date"` → admin กำหนด `startDate` + `endDate` เอง
- `durationDays` ใช้แค่ตอน `scheduleType = "duration"` (เก็บไว้เพื่อแสดงผล)

### User Progress: `users/{deviceId}.seasonalProgress`

เก็บใน user document เลย (ไม่ใช่ subcollection)

```
users/{deviceId}
└── seasonalProgress: {
      [questId]: {
        claimedDays: string[]    // ["2026-12-25", "2026-12-26"] สำหรับ daily
        claimed: boolean         // true/false สำหรับ one_time
      }
    }
```

---

## Step 2: Admin API Routes

### ไฟล์ที่ 1: `admin-panel/src/app/api/seasonal-quests/route.ts`

สร้างไฟล์ใหม่ ทำ GET (list) + POST (create)

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { checkAuth } from '@/lib/auth';
import { Timestamp } from 'firebase-admin/firestore';

// GET: ดึง seasonal quests ทั้งหมด (เรียงจากใหม่สุด)
export async function GET(request: NextRequest) {
  try {
    const authError = await checkAuth(request);
    if (authError) return authError;

    const snapshot = await db
      .collection('seasonal_quests')
      .orderBy('createdAt', 'desc')
      .limit(50)
      .get();

    const quests = snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
      createdAt: doc.data().createdAt?.toDate?.()?.toISOString() || null,
    }));

    return NextResponse.json({ success: true, quests });
  } catch (error: any) {
    console.error('Error fetching seasonal quests:', error);
    return NextResponse.json(
      { success: false, error: error.message },
      { status: 500 }
    );
  }
}

// POST: สร้าง seasonal quest ใหม่
export async function POST(request: NextRequest) {
  try {
    const authError = await checkAuth(request);
    if (authError) return authError;

    const body = await request.json();
    const {
      title,
      description,
      icon,
      scheduleType,
      startDate,
      endDate,
      durationDays,
      claimType,
      rewardPerClaim,
    } = body;

    // ─── Validation ───
    if (!title || !title.trim()) {
      return NextResponse.json(
        { success: false, error: 'Title is required' },
        { status: 400 }
      );
    }

    if (!['fixed_date', 'duration'].includes(scheduleType)) {
      return NextResponse.json(
        { success: false, error: 'scheduleType must be "fixed_date" or "duration"' },
        { status: 400 }
      );
    }

    if (!['daily', 'one_time'].includes(claimType)) {
      return NextResponse.json(
        { success: false, error: 'claimType must be "daily" or "one_time"' },
        { status: 400 }
      );
    }

    if (!rewardPerClaim || rewardPerClaim < 1 || rewardPerClaim > 100) {
      return NextResponse.json(
        { success: false, error: 'rewardPerClaim must be 1-100' },
        { status: 400 }
      );
    }

    // ─── Calculate dates ───
    let finalStartDate: string;
    let finalEndDate: string;
    let finalDurationDays: number;

    if (scheduleType === 'fixed_date') {
      if (!startDate || !endDate) {
        return NextResponse.json(
          { success: false, error: 'startDate and endDate required for fixed_date' },
          { status: 400 }
        );
      }
      if (endDate <= startDate) {
        return NextResponse.json(
          { success: false, error: 'endDate must be after startDate' },
          { status: 400 }
        );
      }
      finalStartDate = startDate;
      finalEndDate = endDate;
      // Calculate duration for display
      const diffMs = new Date(endDate).getTime() - new Date(startDate).getTime();
      finalDurationDays = Math.ceil(diffMs / (1000 * 60 * 60 * 24)) + 1;
    } else {
      // duration type
      if (!durationDays || durationDays < 1 || durationDays > 365) {
        return NextResponse.json(
          { success: false, error: 'durationDays must be 1-365' },
          { status: 400 }
        );
      }
      // Start = today (UTC+7)
      const now = new Date(Date.now() + 7 * 60 * 60 * 1000);
      finalStartDate = now.toISOString().split('T')[0];
      // End = start + durationDays - 1
      const end = new Date(now.getTime() + (durationDays - 1) * 24 * 60 * 60 * 1000);
      finalEndDate = end.toISOString().split('T')[0];
      finalDurationDays = durationDays;
    }

    // ─── Save ───
    const questData = {
      title: title.trim(),
      description: (description || '').trim(),
      icon: icon || '🎁',
      scheduleType,
      startDate: finalStartDate,
      endDate: finalEndDate,
      durationDays: finalDurationDays,
      claimType,
      rewardPerClaim,
      status: 'active',
      createdAt: Timestamp.now(),
      createdBy: 'admin',
    };

    const docRef = await db.collection('seasonal_quests').add(questData);

    return NextResponse.json({
      success: true,
      id: docRef.id,
      quest: { id: docRef.id, ...questData, createdAt: new Date().toISOString() },
    });
  } catch (error: any) {
    console.error('Error creating seasonal quest:', error);
    return NextResponse.json(
      { success: false, error: error.message },
      { status: 500 }
    );
  }
}
```

### ไฟล์ที่ 2: `admin-panel/src/app/api/seasonal-quests/[id]/route.ts`

สร้างไฟล์ใหม่ ทำ PATCH (update status) + DELETE

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { checkAuth } from '@/lib/auth';

// PATCH: อัปเดต status (active/paused)
export async function PATCH(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const authError = await checkAuth(request);
    if (authError) return authError;

    const { id } = await params;
    const body = await request.json();
    const { status } = body;

    if (!['active', 'paused'].includes(status)) {
      return NextResponse.json(
        { success: false, error: 'Status must be "active" or "paused"' },
        { status: 400 }
      );
    }

    const docRef = db.collection('seasonal_quests').doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return NextResponse.json(
        { success: false, error: 'Quest not found' },
        { status: 404 }
      );
    }

    await docRef.update({ status });

    return NextResponse.json({ success: true, id, status });
  } catch (error: any) {
    console.error('Error updating seasonal quest:', error);
    return NextResponse.json(
      { success: false, error: error.message },
      { status: 500 }
    );
  }
}

// DELETE: ลบ quest
export async function DELETE(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const authError = await checkAuth(request);
    if (authError) return authError;

    const { id } = await params;
    const docRef = db.collection('seasonal_quests').doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return NextResponse.json(
        { success: false, error: 'Quest not found' },
        { status: 404 }
      );
    }

    await docRef.delete();

    return NextResponse.json({ success: true, id });
  } catch (error: any) {
    console.error('Error deleting seasonal quest:', error);
    return NextResponse.json(
      { success: false, error: error.message },
      { status: 500 }
    );
  }
}
```

### ทดสอบ Step 2

1. รัน admin panel: `cd admin-panel && npm run dev`
2. ใช้ Postman หรือ curl ทดสอบ:
   - `POST /api/seasonal-quests` — สร้าง quest
   - `GET /api/seasonal-quests` — ดูรายการ
   - `PATCH /api/seasonal-quests/{id}` — เปลี่ยน status
   - `DELETE /api/seasonal-quests/{id}` — ลบ
3. เปิด Firebase Console → ดู collection `seasonal_quests` ว่ามีข้อมูลถูกต้อง

---

## Step 3: Admin UI

### แก้ไฟล์: `admin-panel/src/app/(dashboard)/campaigns/push/page.tsx`

**เปลี่ยนหน้าเดิมจากแค่ Push Notification เป็น 2 tabs:**
- Tab 1: "Push Notification" (ของเดิมทั้งหมด ไม่ต้องแก้)
- Tab 2: "Seasonal Quests" (เพิ่มใหม่)

**วิธีทำ:**

1. เพิ่ม state `activeTab` (`'push'` | `'seasonal'`)
2. สร้าง tab bar ด้านบน
3. แยก content เดิมใส่ `{activeTab === 'push' && (...)}`
4. เพิ่ม content ใหม่ `{activeTab === 'seasonal' && (...)}`

**Seasonal Quests Tab ประกอบด้วย:**

### A. Create Quest Form

```
┌─────────────────────────────────────────────┐
│  Create New Seasonal Quest                   │
│                                              │
│  Title: [___________________________]        │
│  Description: [___________________________]  │
│  Icon (emoji): [🎁]                          │
│                                              │
│  Schedule Type:                              │
│  ○ Fixed Date   ○ Duration                   │
│                                              │
│  (ถ้า Fixed Date)                             │
│  Start Date: [2026-12-25]                    │
│  End Date:   [2027-01-01]                    │
│                                              │
│  (ถ้า Duration)                               │
│  Duration: [7] days                          │
│                                              │
│  Claim Type:                                 │
│  ○ Daily Claim (claim ได้ทุกวัน)              │
│  ○ One-Time Claim (claim ครั้งเดียว)          │
│                                              │
│  Reward per Claim: [2] Energy                │
│                                              │
│  [Create Quest]                              │
└─────────────────────────────────────────────┘
```

### B. Active Quests List (ด้านล่าง form)

```
┌──────────────────────────────────────────────────────────────────────┐
│  Active Seasonal Quests                                              │
│                                                                      │
│  Icon │ Title              │ Period           │ Type    │ Reward │ ⚙ │
│  ─────┼────────────────────┼──────────────────┼─────────┼────────┼───│
│  🎄   │ Happy New Year     │ Dec 25 - Jan 1   │ Daily   │ 2E/day │ ⏸ │
│  🆕   │ New Version Reward │ Feb 21 - Feb 27  │ OneTime │ 5E     │ 🗑 │
└──────────────────────────────────────────────────────────────────────┘
```

**ปุ่มใน column สุดท้าย:**
- ⏸ Pause / ▶ Resume (เรียก PATCH)
- 🗑 Delete (เรียก DELETE, มี confirm dialog)

### โค้ดตัวอย่าง (structure หลัก)

```tsx
'use client';

import { useState, useEffect } from 'react';

// === (ของเดิม: interfaces + PushCampaignPage logic ทั้งหมดคงไว้) ===

// เพิ่ม interface ใหม่
interface SeasonalQuest {
  id: string;
  title: string;
  description: string;
  icon: string;
  scheduleType: 'fixed_date' | 'duration';
  startDate: string;
  endDate: string;
  durationDays: number;
  claimType: 'daily' | 'one_time';
  rewardPerClaim: number;
  status: 'active' | 'paused';
  createdAt: string;
}

export default function PushCampaignPage() {
  // ─── Existing Push state (คงเดิมทั้งหมด) ───
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const [targetSegment, setTargetSegment] = useState('all');
  const [sending, setSending] = useState(false);
  const [result, setResult] = useState<any>(null);
  const [history, setHistory] = useState<CampaignHistory[]>([]);
  const [loadingHistory, setLoadingHistory] = useState(true);

  // ─── NEW: Tab state ───
  const [activeTab, setActiveTab] = useState<'push' | 'seasonal'>('push');

  // ─── NEW: Seasonal Quest state ───
  const [sqTitle, setSqTitle] = useState('');
  const [sqDescription, setSqDescription] = useState('');
  const [sqIcon, setSqIcon] = useState('🎁');
  const [sqScheduleType, setSqScheduleType] = useState<'fixed_date' | 'duration'>('duration');
  const [sqStartDate, setSqStartDate] = useState('');
  const [sqEndDate, setSqEndDate] = useState('');
  const [sqDurationDays, setSqDurationDays] = useState(7);
  const [sqClaimType, setSqClaimType] = useState<'daily' | 'one_time'>('daily');
  const [sqRewardPerClaim, setSqRewardPerClaim] = useState(2);
  const [sqCreating, setSqCreating] = useState(false);
  const [sqQuests, setSqQuests] = useState<SeasonalQuest[]>([]);
  const [sqLoading, setSqLoading] = useState(false);

  useEffect(() => {
    fetchHistory();
    fetchSeasonalQuests();
  }, []);

  // ─── Existing functions (คงเดิมทั้งหมด) ───
  async function fetchHistory() { /* เดิม */ }
  async function sendPushNotification() { /* เดิม */ }

  // ─── NEW: Seasonal Quest functions ───
  async function fetchSeasonalQuests() {
    setSqLoading(true);
    try {
      const response = await fetch('/api/seasonal-quests');
      const data = await response.json();
      if (data.success) {
        setSqQuests(data.quests || []);
      }
    } catch (error) {
      console.error('Error fetching seasonal quests:', error);
    } finally {
      setSqLoading(false);
    }
  }

  async function createSeasonalQuest() {
    if (!sqTitle.trim()) {
      alert('Please enter a title');
      return;
    }
    setSqCreating(true);
    try {
      const response = await fetch('/api/seasonal-quests', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          title: sqTitle,
          description: sqDescription,
          icon: sqIcon,
          scheduleType: sqScheduleType,
          startDate: sqScheduleType === 'fixed_date' ? sqStartDate : undefined,
          endDate: sqScheduleType === 'fixed_date' ? sqEndDate : undefined,
          durationDays: sqScheduleType === 'duration' ? sqDurationDays : undefined,
          claimType: sqClaimType,
          rewardPerClaim: sqRewardPerClaim,
        }),
      });
      const data = await response.json();
      if (data.success) {
        // Reset form
        setSqTitle('');
        setSqDescription('');
        setSqIcon('🎁');
        setSqDurationDays(7);
        setSqRewardPerClaim(2);
        fetchSeasonalQuests();
      } else {
        alert(data.error || 'Failed to create');
      }
    } catch (error) {
      console.error('Error creating seasonal quest:', error);
    } finally {
      setSqCreating(false);
    }
  }

  async function toggleQuestStatus(id: string, currentStatus: string) {
    const newStatus = currentStatus === 'active' ? 'paused' : 'active';
    try {
      await fetch(`/api/seasonal-quests/${id}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status: newStatus }),
      });
      fetchSeasonalQuests();
    } catch (error) {
      console.error('Error toggling quest status:', error);
    }
  }

  async function deleteQuest(id: string) {
    if (!confirm('Are you sure you want to delete this quest?')) return;
    try {
      await fetch(`/api/seasonal-quests/${id}`, { method: 'DELETE' });
      fetchSeasonalQuests();
    } catch (error) {
      console.error('Error deleting quest:', error);
    }
  }

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">Campaigns</h1>

      {/* ─── Tab Bar ─── */}
      <div className="flex border-b border-gray-200 mb-6">
        <button
          className={`px-4 py-2 font-medium border-b-2 transition-colors ${
            activeTab === 'push'
              ? 'border-blue-500 text-blue-600'
              : 'border-transparent text-gray-500 hover:text-gray-700'
          }`}
          onClick={() => setActiveTab('push')}
        >
          Push Notification
        </button>
        <button
          className={`px-4 py-2 font-medium border-b-2 transition-colors ${
            activeTab === 'seasonal'
              ? 'border-blue-500 text-blue-600'
              : 'border-transparent text-gray-500 hover:text-gray-700'
          }`}
          onClick={() => setActiveTab('seasonal')}
        >
          Seasonal Quests
        </button>
      </div>

      {/* ─── Push Notification Tab (ของเดิมทั้งหมด wrap ด้วย condition) ─── */}
      {activeTab === 'push' && (
        <div>
          {/* === วาง code JSX เดิมทั้งหมดที่เคยอยู่ใน return ตรงนี้ === */}
          {/* ตั้งแต่ form, result, warning, campaign history */}
        </div>
      )}

      {/* ─── Seasonal Quests Tab ─── */}
      {activeTab === 'seasonal' && (
        <div>
          {/* Create Form */}
          <div className="max-w-2xl space-y-4 mb-8">
            <h2 className="text-xl font-bold">Create New Seasonal Quest</h2>

            {/* Title */}
            <div>
              <label className="block mb-1 font-medium text-sm">Title *</label>
              <input
                type="text"
                className="border border-gray-300 rounded-lg p-2 w-full"
                value={sqTitle}
                onChange={(e) => setSqTitle(e.target.value)}
                placeholder="e.g., Happy New Year 2027"
              />
            </div>

            {/* Description */}
            <div>
              <label className="block mb-1 font-medium text-sm">Description</label>
              <input
                type="text"
                className="border border-gray-300 rounded-lg p-2 w-full"
                value={sqDescription}
                onChange={(e) => setSqDescription(e.target.value)}
                placeholder="e.g., Celebrate with free energy!"
              />
            </div>

            {/* Icon */}
            <div>
              <label className="block mb-1 font-medium text-sm">Icon (emoji)</label>
              <input
                type="text"
                className="border border-gray-300 rounded-lg p-2 w-20"
                value={sqIcon}
                onChange={(e) => setSqIcon(e.target.value)}
                maxLength={4}
              />
            </div>

            {/* Schedule Type */}
            <div>
              <label className="block mb-1 font-medium text-sm">Schedule Type</label>
              <div className="flex gap-4">
                <label className="flex items-center gap-2">
                  <input
                    type="radio"
                    name="scheduleType"
                    checked={sqScheduleType === 'fixed_date'}
                    onChange={() => setSqScheduleType('fixed_date')}
                  />
                  Fixed Date (pick start & end)
                </label>
                <label className="flex items-center gap-2">
                  <input
                    type="radio"
                    name="scheduleType"
                    checked={sqScheduleType === 'duration'}
                    onChange={() => setSqScheduleType('duration')}
                  />
                  Duration (X days from now)
                </label>
              </div>
            </div>

            {/* Date inputs (conditional) */}
            {sqScheduleType === 'fixed_date' ? (
              <div className="flex gap-4">
                <div className="flex-1">
                  <label className="block mb-1 font-medium text-sm">Start Date</label>
                  <input
                    type="date"
                    className="border border-gray-300 rounded-lg p-2 w-full"
                    value={sqStartDate}
                    onChange={(e) => setSqStartDate(e.target.value)}
                  />
                </div>
                <div className="flex-1">
                  <label className="block mb-1 font-medium text-sm">End Date</label>
                  <input
                    type="date"
                    className="border border-gray-300 rounded-lg p-2 w-full"
                    value={sqEndDate}
                    onChange={(e) => setSqEndDate(e.target.value)}
                  />
                </div>
              </div>
            ) : (
              <div>
                <label className="block mb-1 font-medium text-sm">Duration (days)</label>
                <input
                  type="number"
                  className="border border-gray-300 rounded-lg p-2 w-32"
                  value={sqDurationDays}
                  onChange={(e) => setSqDurationDays(parseInt(e.target.value) || 1)}
                  min={1}
                  max={365}
                />
              </div>
            )}

            {/* Claim Type */}
            <div>
              <label className="block mb-1 font-medium text-sm">Claim Type</label>
              <div className="flex gap-4">
                <label className="flex items-center gap-2">
                  <input
                    type="radio"
                    name="claimType"
                    checked={sqClaimType === 'daily'}
                    onChange={() => setSqClaimType('daily')}
                  />
                  Daily Claim (claim ได้ทุกวัน, ไม่ claim = หายไป)
                </label>
                <label className="flex items-center gap-2">
                  <input
                    type="radio"
                    name="claimType"
                    checked={sqClaimType === 'one_time'}
                    onChange={() => setSqClaimType('one_time')}
                  />
                  One-Time Claim (claim ครั้งเดียวตลอด event)
                </label>
              </div>
            </div>

            {/* Reward */}
            <div>
              <label className="block mb-1 font-medium text-sm">Reward per Claim (Energy)</label>
              <input
                type="number"
                className="border border-gray-300 rounded-lg p-2 w-32"
                value={sqRewardPerClaim}
                onChange={(e) => setSqRewardPerClaim(parseInt(e.target.value) || 1)}
                min={1}
                max={100}
              />
            </div>

            {/* Create button */}
            <button
              className="bg-green-500 text-white px-6 py-3 rounded-lg font-medium hover:bg-green-600 disabled:bg-gray-300 disabled:cursor-not-allowed"
              onClick={createSeasonalQuest}
              disabled={sqCreating || !sqTitle.trim()}
            >
              {sqCreating ? 'Creating...' : 'Create Quest'}
            </button>
          </div>

          {/* Quest List */}
          <div>
            <h2 className="text-xl font-bold mb-4">All Seasonal Quests</h2>
            {sqLoading ? (
              <div className="text-center py-8">Loading...</div>
            ) : sqQuests.length === 0 ? (
              <div className="text-center py-8 text-gray-500">No seasonal quests yet</div>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full border border-gray-300">
                  <thead>
                    <tr className="bg-gray-100">
                      <th className="border border-gray-300 p-2 text-left">Icon</th>
                      <th className="border border-gray-300 p-2 text-left">Title</th>
                      <th className="border border-gray-300 p-2 text-left">Period</th>
                      <th className="border border-gray-300 p-2 text-left">Type</th>
                      <th className="border border-gray-300 p-2 text-right">Reward</th>
                      <th className="border border-gray-300 p-2 text-center">Status</th>
                      <th className="border border-gray-300 p-2 text-center">Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {sqQuests.map((quest) => {
                      const isExpired = quest.endDate < new Date().toISOString().split('T')[0];
                      return (
                        <tr key={quest.id} className="hover:bg-gray-50">
                          <td className="border border-gray-300 p-2 text-2xl text-center">
                            {quest.icon}
                          </td>
                          <td className="border border-gray-300 p-2">
                            <div className="font-medium">{quest.title}</div>
                            {quest.description && (
                              <div className="text-sm text-gray-500">{quest.description}</div>
                            )}
                          </td>
                          <td className="border border-gray-300 p-2 text-sm">
                            {quest.startDate} → {quest.endDate}
                            <div className="text-xs text-gray-500">
                              ({quest.durationDays} days, {quest.scheduleType})
                            </div>
                          </td>
                          <td className="border border-gray-300 p-2">
                            {quest.claimType === 'daily' ? 'Daily' : 'One-Time'}
                          </td>
                          <td className="border border-gray-300 p-2 text-right">
                            {quest.rewardPerClaim}E
                            {quest.claimType === 'daily' && '/day'}
                          </td>
                          <td className="border border-gray-300 p-2 text-center">
                            <span
                              className={`px-2 py-1 rounded text-xs font-medium ${
                                isExpired
                                  ? 'bg-gray-100 text-gray-600'
                                  : quest.status === 'active'
                                  ? 'bg-green-100 text-green-800'
                                  : 'bg-yellow-100 text-yellow-800'
                              }`}
                            >
                              {isExpired ? 'Expired' : quest.status === 'active' ? 'Active' : 'Paused'}
                            </span>
                          </td>
                          <td className="border border-gray-300 p-2 text-center">
                            <div className="flex gap-2 justify-center">
                              {!isExpired && (
                                <button
                                  className="text-sm px-3 py-1 rounded bg-blue-100 text-blue-700 hover:bg-blue-200"
                                  onClick={() => toggleQuestStatus(quest.id, quest.status)}
                                >
                                  {quest.status === 'active' ? 'Pause' : 'Resume'}
                                </button>
                              )}
                              <button
                                className="text-sm px-3 py-1 rounded bg-red-100 text-red-700 hover:bg-red-200"
                                onClick={() => deleteQuest(quest.id)}
                              >
                                Delete
                              </button>
                            </div>
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}
```

### ทดสอบ Step 3

1. เปิด http://localhost:3000/campaigns/push
2. เห็น 2 tabs: "Push Notification" / "Seasonal Quests"
3. คลิก "Seasonal Quests" → เห็น form + empty list
4. สร้าง quest ทดสอบทั้ง 2 แบบ (fixed_date + duration)
5. ทดสอบ Pause / Resume / Delete

---

## Step 4: Backend - Include in Sync Responses

ให้ Active seasonal quests ถูกส่งไปพร้อมกับ response ของ `registerUser` และ `syncBalance`

### Helper Function

สร้างไฟล์ใหม่: `functions/src/energy/seasonalQuest.ts`

```typescript
/**
 * seasonalQuest.ts
 *
 * Helpers for Seasonal Quest system
 */

import * as admin from "firebase-admin";

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

/**
 * Get today string in UTC+7
 */
function getTodayString(): string {
  const now = new Date();
  const localTime = new Date(now.getTime() + 420 * 60 * 1000);
  return localTime.toISOString().split("T")[0];
}

/**
 * Fetch active seasonal quests and merge with user progress
 *
 * Returns array of quests with user's claim status
 */
export async function getActiveSeasonalQuests(
  deviceId: string
): Promise<any[]> {
  const today = getTodayString();

  // Query active quests where today is within date range
  const snapshot = await db
    .collection("seasonal_quests")
    .where("status", "==", "active")
    .get();

  // Filter by date range (Firestore can't do compound range queries on different fields)
  const activeQuests = snapshot.docs.filter((doc) => {
    const data = doc.data();
    return data.startDate <= today && data.endDate >= today;
  });

  if (activeQuests.length === 0) return [];

  // Get user's seasonal progress
  const userDoc = await db.collection("users").doc(deviceId).get();
  const seasonalProgress = userDoc.data()?.seasonalProgress || {};

  // Merge quest data with user progress
  return activeQuests.map((doc) => {
    const quest = doc.data();
    const progress = seasonalProgress[doc.id] || {};

    return {
      id: doc.id,
      title: quest.title,
      description: quest.description || "",
      icon: quest.icon || "🎁",
      startDate: quest.startDate,
      endDate: quest.endDate,
      durationDays: quest.durationDays || 0,
      claimType: quest.claimType,
      rewardPerClaim: quest.rewardPerClaim,
      // User progress
      claimedDays: progress.claimedDays || [],
      claimed: progress.claimed || false,
    };
  });
}
```

### แก้ไข: `functions/src/syncBalance.ts`

**เพิ่ม import** ที่บรรทัดบนสุด (ใต้ import admin):

```typescript
import {getActiveSeasonalQuests} from "./energy/seasonalQuest";
```

**เพิ่มในส่วน response** (ก่อน `res.status(200).json`):

```typescript
// Fetch active seasonal quests
const seasonalQuests = await getActiveSeasonalQuests(deviceId);
```

**เพิ่ม field ใน JSON response:**

```typescript
seasonalQuests: seasonalQuests,
```

ตำแหน่งที่ต้องเพิ่ม — ใน `res.status(200).json({...})` เพิ่มบรรทัดใหม่ต่อจาก `tierCelebration`:

```typescript
tierCelebration: userData.tierCelebration ?? {},
seasonalQuests: seasonalQuests,    // ← เพิ่มบรรทัดนี้
```

### แก้ไข: `functions/src/registerUser.ts`

**เพิ่ม import** ที่บรรทัดบนสุด:

```typescript
import {getActiveSeasonalQuests} from "./energy/seasonalQuest";
```

**เพิ่มใน response ของ existing user** (บรรทัดก่อน `res.status(200).json`):

```typescript
const seasonalQuests = await getActiveSeasonalQuests(deviceId);
```

**เพิ่ม field ใน JSON response (existing user):**

```typescript
tierCelebration: finalTierCelebration,
seasonalQuests: seasonalQuests,    // ← เพิ่มบรรทัดนี้
```

**เพิ่ม field ใน JSON response (new user):**

```typescript
tierCelebration: {},
seasonalQuests: [],    // ← เพิ่มบรรทัดนี้ (user ใหม่ยังไม่มี progress)
```

### แก้ไข: `functions/src/index.ts`

ไม่ต้อง export อะไรเพิ่ม เพราะ `seasonalQuest.ts` เป็น helper ที่ถูกเรียกจาก `syncBalance` และ `registerUser`

### ทดสอบ Step 4

1. สร้าง seasonal quest ผ่าน admin panel (ให้ active อยู่)
2. Deploy functions: `cd functions && npm run deploy`
3. เรียก `syncBalance` API → response ต้องมี `seasonalQuests: [...]`
4. เรียก `registerUser` API → response ต้องมี `seasonalQuests: [...]`

---

## Step 5: Backend - Claim Endpoint

### แก้ไข: `functions/src/energy/challenge.ts`

**เพิ่ม `"seasonal"` ใน `validTypes` array (บรรทัด 88):**

```typescript
const validTypes = [
  "dailyAi1", "dailyAi10",
  "weeklyAi20", "weeklyAi40", "weeklyAi60",
  "referFriends",
  "tierCelebration",
  "seasonal",         // ← เพิ่มบรรทัดนี้
];
```

**เพิ่ม block ใหม่** ใต้ block `tierCelebration` (หลังบรรทัด `return;` ของ tierCelebration ที่บรรทัด 183):

```typescript
      // ─── Seasonal Quest Claim ───
      if (challengeType === "seasonal") {
        const {questId} = req.body;
        if (!questId) {
          res.status(400).json({error: "Missing questId parameter"});
          return;
        }

        // Get today string (UTC+7)
        function getTodayStringSeasonal(): string {
          const now = new Date();
          const localTime = new Date(now.getTime() + 420 * 60 * 1000);
          return localTime.toISOString().split("T")[0];
        }

        const today = getTodayStringSeasonal();

        // Fetch quest config
        const questDoc = await db.collection("seasonal_quests").doc(questId).get();
        if (!questDoc.exists) {
          res.status(404).json({error: "Quest not found"});
          return;
        }
        const quest = questDoc.data()!;

        // Check quest is active
        if (quest.status !== "active") {
          res.status(400).json({error: "Quest is not active"});
          return;
        }

        // Check date range
        if (today < quest.startDate || today > quest.endDate) {
          res.status(400).json({error: "Quest is not within active date range"});
          return;
        }

        const userRef = db.collection("users").doc(deviceId);

        const result = await db.runTransaction(async (transaction) => {
          const userDoc = await transaction.get(userRef);
          if (!userDoc.exists) throw new Error("User not found");

          const userData = userDoc.data()!;
          const progress = userData.seasonalProgress?.[questId] || {};

          if (quest.claimType === "one_time") {
            // ─── One-time claim ───
            if (progress.claimed === true) {
              throw new Error("Already claimed");
            }

            const reward = quest.rewardPerClaim;
            const balance = userData.balance || 0;
            const newBalance = balance + reward;

            transaction.update(userRef, {
              balance: newBalance,
              totalEarned: (userData.totalEarned || 0) + reward,
              [`seasonalProgress.${questId}.claimed`]: true,
              lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
            });

            const txRef = db.collection("transactions").doc();
            transaction.set(txRef, {
              deviceId,
              miroId: userData.miroId || "unknown",
              type: "seasonal_quest",
              amount: reward,
              balanceAfter: newBalance,
              description: `${quest.title}: +${reward}E`,
              metadata: {questId, claimType: "one_time", reward},
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });

            return {success: true, reward, newBalance, claimType: "one_time"};
          } else {
            // ─── Daily claim ───
            const claimedDays: string[] = progress.claimedDays || [];

            if (claimedDays.includes(today)) {
              throw new Error("Already claimed today");
            }

            const reward = quest.rewardPerClaim;
            const balance = userData.balance || 0;
            const newBalance = balance + reward;

            transaction.update(userRef, {
              balance: newBalance,
              totalEarned: (userData.totalEarned || 0) + reward,
              [`seasonalProgress.${questId}.claimedDays`]: [...claimedDays, today],
              lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
            });

            const txRef = db.collection("transactions").doc();
            transaction.set(txRef, {
              deviceId,
              miroId: userData.miroId || "unknown",
              type: "seasonal_quest",
              amount: reward,
              balanceAfter: newBalance,
              description: `${quest.title} (Day): +${reward}E`,
              metadata: {questId, claimType: "daily", date: today, reward},
              createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });

            return {success: true, reward, newBalance, claimType: "daily", date: today};
          }
        });

        console.log(`🎄 [Seasonal] ${deviceId} claimed ${questId}: +${result.reward}E`);
        res.status(200).json(result);
        return;
      }
```

### ทดสอบ Step 5

1. Deploy functions
2. สร้าง seasonal quest ผ่าน admin (active, daily, 2E)
3. ทดสอบ claim:
   ```
   POST https://us-central1-miro-d6856.cloudfunctions.net/completeChallenge
   Body: {
     "deviceId": "test-device-id",
     "challengeType": "seasonal",
     "questId": "<quest-id-from-firestore>"
   }
   ```
4. ตรวจ response: `{ success: true, reward: 2, newBalance: ... }`
5. เรียกซ้ำ → ต้องได้ `"Already claimed today"`
6. ตรวจ Firestore: `users/{deviceId}.seasonalProgress.{questId}.claimedDays` มีวันนี้

---

## Step 6: Flutter - Data Model

### แก้ไข: `lib/core/models/gamification_state.dart`

**เพิ่ม class ใหม่** ไว้ใต้ `TierCelebrationData` (ก่อน `class GamificationState`):

```dart
/// Seasonal Quest data from server
class SeasonalQuestData {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String startDate;   // "YYYY-MM-DD"
  final String endDate;     // "YYYY-MM-DD"
  final int durationDays;
  final String claimType;   // "daily" | "one_time"
  final int rewardPerClaim;

  // User progress
  final List<String> claimedDays;  // for daily: ["2026-12-25", ...]
  final bool claimed;              // for one_time

  const SeasonalQuestData({
    required this.id,
    required this.title,
    this.description = '',
    this.icon = '🎁',
    required this.startDate,
    required this.endDate,
    this.durationDays = 0,
    required this.claimType,
    required this.rewardPerClaim,
    this.claimedDays = const [],
    this.claimed = false,
  });

  /// Is quest currently active (today within date range)
  bool get isActive {
    try {
      final now = DateTime.now();
      final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      return todayStr.compareTo(startDate) >= 0 && todayStr.compareTo(endDate) <= 0;
    } catch (e) {
      return false;
    }
  }

  /// Can claim today
  bool get canClaimToday {
    if (!isActive) return false;
    if (claimType == 'one_time') return !claimed;
    // daily: check if today's date is in claimedDays
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return !claimedDays.contains(todayStr);
  }

  /// Days remaining until end date
  int get daysRemaining {
    try {
      final end = DateTime.parse(endDate);
      final now = DateTime.now();
      final diff = end.difference(DateTime(now.year, now.month, now.day)).inDays;
      return diff >= 0 ? diff + 1 : 0;
    } catch (e) {
      return 0;
    }
  }

  /// Is quest completed (one_time: claimed, daily: expired)
  bool get isComplete {
    if (claimType == 'one_time') return claimed;
    return !isActive && daysRemaining == 0;
  }

  /// Total days claimed
  int get totalClaimed => claimedDays.length;

  factory SeasonalQuestData.fromJson(Map<String, dynamic> json) {
    return SeasonalQuestData(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? '🎁',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      durationDays: (json['durationDays'] as num?)?.toInt() ?? 0,
      claimType: json['claimType'] as String? ?? 'daily',
      rewardPerClaim: (json['rewardPerClaim'] as num?)?.toInt() ?? 0,
      claimedDays: (json['claimedDays'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      claimed: json['claimed'] as bool? ?? false,
    );
  }
}
```

**เพิ่ม field ใน `GamificationState`:**

ใน class declaration (ใต้ `tierCelebrations`):

```dart
  // Seasonal Quests (limited-time events)
  final List<SeasonalQuestData> seasonalQuests;
```

**เพิ่มใน constructor** (ใต้ `this.tierCelebrations = const {}`):

```dart
    this.seasonalQuests = const [],
```

**เพิ่มใน `GamificationState.empty()`** (ใต้ `tierCelebrations: {}`):

```dart
      seasonalQuests: const [],
```

**เพิ่มใน `copyWith()`:**

Parameter:
```dart
    List<SeasonalQuestData>? seasonalQuests,
```

Body (ใต้ `tierCelebrations:`):
```dart
      seasonalQuests: seasonalQuests ?? this.seasonalQuests,
```

---

## Step 7: Flutter - EnergyService Pass-through

### แก้ไข: `lib/core/services/energy_service.dart`

ใน function `registerOrSync()` — เพิ่มใน return map (ต่อจาก `tierCelebration`):

```dart
          'seasonalQuests': data['seasonalQuests'] ?? [],
```

ใน function `syncBalanceWithServer()` — เพิ่มใน return map (ต่อจาก `tierCelebration`):

```dart
          'seasonalQuests': data['seasonalQuests'] ?? [],
```

---

## Step 8: Flutter - GamificationProvider

### แก้ไข: `lib/features/energy/providers/gamification_provider.dart`

**เพิ่ม helper method** ใน class `GamificationNotifier` (ใต้ `_parseTierCelebrations`):

```dart
  /// Parse seasonal quests from API response
  List<SeasonalQuestData> _parseSeasonalQuests(dynamic data) {
    if (data == null || data is! List) return [];

    final result = <SeasonalQuestData>[];
    for (final item in data) {
      try {
        if (item is Map<String, dynamic>) {
          result.add(SeasonalQuestData.fromJson(item));
        }
      } catch (e) {
        debugPrint('[Gamification] Error parsing seasonalQuest: $e');
      }
    }
    return result;
  }
```

**ใน `_loadState()`** — เพิ่มหลังบรรทัด parse tierCelebrations:

```dart
      // Parse seasonal quests
      final seasonalQuests = _parseSeasonalQuests(result['seasonalQuests']);
      debugPrint('[Gamification] seasonalQuests parsed: ${seasonalQuests.length} active quests');
```

**ใน `_loadState()`** — เพิ่มใน `state = GamificationState(...)` (ใต้ `tierCelebrations:`):

```dart
        seasonalQuests: seasonalQuests,
```

**ใน `updateFromAiResponse()`** — เพิ่มหลัง tierCelebrations parsing:

```dart
    // Seasonal quests
    final seasonalQuests = response['seasonalQuests'] != null
        ? _parseSeasonalQuests(response['seasonalQuests'])
        : null;
```

**ใน `updateFromAiResponse()`** — เพิ่มใน `state = state.copyWith(...)` (ใต้ `tierCelebrations:`):

```dart
      seasonalQuests: seasonalQuests,
```

---

## Step 9: Flutter - SeasonalQuestCard Widget

### สร้างไฟล์ใหม่: `lib/features/energy/widgets/seasonal_quest_card.dart`

ใช้ pattern เดียวกับ `tier_celebration_card.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/services/device_id_service.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/models/gamification_state.dart';
import '../providers/gamification_provider.dart';

class SeasonalQuestCard extends ConsumerStatefulWidget {
  final SeasonalQuestData quest;

  const SeasonalQuestCard({
    super.key,
    required this.quest,
  });

  @override
  ConsumerState<SeasonalQuestCard> createState() => _SeasonalQuestCardState();
}

class _SeasonalQuestCardState extends ConsumerState<SeasonalQuestCard> {
  bool _isLoading = false;

  Future<void> _claimReward() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final deviceId = await DeviceIdService.getDeviceId();
      final response = await http.post(
        Uri.parse(
            'https://us-central1-miro-d6856.cloudfunctions.net/completeChallenge'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'deviceId': deviceId,
          'challengeType': 'seasonal',
          'questId': widget.quest.id,
        }),
      );

      if (response.statusCode == 200) {
        ref.read(gamificationProvider.notifier).refresh();
        if (mounted) {
          final data = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.quest.icon, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text('+${data['reward']}E!'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        final error = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error['error'] ?? 'Failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('[SeasonalQuest] Claim error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final quest = widget.quest;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.amber.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header: LIMITED TIME badge + title ───
              Row(
                children: [
                  // Icon
                  Text(quest.icon, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 10),
                  // Title + description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.shade600,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                l10n.seasonalQuestLimitedTime,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.seasonalQuestDaysLeft(quest.daysRemaining),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.red.shade400,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          quest.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                        ),
                        if (quest.description.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            quest.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ─── Reward info + Claim button ───
              Row(
                children: [
                  // Reward info
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(AppIcons.energy, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          quest.claimType == 'daily'
                              ? l10n.seasonalQuestRewardDaily(quest.rewardPerClaim)
                              : l10n.seasonalQuestRewardOnce(quest.rewardPerClaim),
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Claim button
                  if (quest.canClaimToday)
                    GestureDetector(
                      onTap: _isLoading ? null : _claimReward,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Colors.amber, Colors.orange]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '+${quest.rewardPerClaim}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(AppIcons.energy,
                                      size: 16, color: Colors.white),
                                ],
                              ),
                      ),
                    )
                  else if (quest.claimType == 'one_time' && quest.claimed)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle,
                              size: 16, color: Colors.green.shade700),
                          const SizedBox(width: 4),
                          Text(
                            l10n.seasonalQuestClaimed,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (quest.claimType == 'daily' &&
                      !quest.canClaimToday &&
                      quest.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n.seasonalQuestClaimedToday,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Step 10: Flutter - QuestBar Integration + Localization

### แก้ไข: `lib/features/energy/widgets/quest_bar.dart`

**เพิ่ม import** (ด้านบนไฟล์):

```dart
import '../widgets/seasonal_quest_card.dart';
```

**เพิ่ม section ใน `_buildExpandedContent()`**

แทรกระหว่าง Offers (section 2) กับ Tier Celebrations (section 2.5):

ตำแหน่ง: หลังบรรทัด `const SizedBox(height: 16),` ของ Offers, ก่อน comment `// ────── 2.5. Tier Celebrations`

```dart
          // ────── 2.3. Seasonal Quests (LIMITED TIME) ──────
          ...gamification.seasonalQuests
              .where((q) => q.isActive && !q.isComplete)
              .map((q) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SeasonalQuestCard(quest: q),
                  )),
          if (gamification.seasonalQuests.any((q) => q.isActive && !q.isComplete))
            const SizedBox(height: 8),
```

### Localization

### แก้ไข: `lib/l10n/app_en.arb`

เพิ่มก่อนบรรทัดสุดท้าย `}`:

```json
  "seasonalQuestLimitedTime": "LIMITED TIME",
  "seasonalQuestDaysLeft": "{days} days left",
  "@seasonalQuestDaysLeft": {
    "placeholders": {
      "days": {
        "type": "int"
      }
    }
  },
  "seasonalQuestRewardDaily": "+{reward}E / day",
  "@seasonalQuestRewardDaily": {
    "placeholders": {
      "reward": {
        "type": "int"
      }
    }
  },
  "seasonalQuestRewardOnce": "+{reward}E one-time",
  "@seasonalQuestRewardOnce": {
    "placeholders": {
      "reward": {
        "type": "int"
      }
    }
  },
  "seasonalQuestClaimed": "Claimed!",
  "seasonalQuestClaimedToday": "Claimed today"
```

### แก้ไข: `lib/l10n/app_th.arb`

เพิ่มก่อนบรรทัดสุดท้าย `}`:

```json
  "seasonalQuestLimitedTime": "จำกัดเวลา",
  "seasonalQuestDaysLeft": "เหลืออีก {days} วัน",
  "@seasonalQuestDaysLeft": {
    "placeholders": {
      "days": {
        "type": "int"
      }
    }
  },
  "seasonalQuestRewardDaily": "+{reward}E / วัน",
  "@seasonalQuestRewardDaily": {
    "placeholders": {
      "reward": {
        "type": "int"
      }
    }
  },
  "seasonalQuestRewardOnce": "+{reward}E ครั้งเดียว",
  "@seasonalQuestRewardOnce": {
    "placeholders": {
      "reward": {
        "type": "int"
      }
    }
  },
  "seasonalQuestClaimed": "รับแล้ว!",
  "seasonalQuestClaimedToday": "วันนี้รับไปแล้ว"
```

### Generate localizations

รัน command:

```bash
flutter gen-l10n
```

ถ้า error เรื่อง method ไม่เจอ ให้ตรวจว่า:
1. `app_localizations.dart` มี getter สำหรับ seasonal quest strings ทั้งหมด
2. `app_localizations_en.dart` และ `app_localizations_th.dart` implement method ครบ

### ทดสอบ Step 9 + 10

1. สร้าง seasonal quest ผ่าน admin (active, daily, 2E, 7 days)
2. Build Flutter app: `flutter run`
3. เปิด QuestBar → ต้องเห็น SeasonalQuestCard พร้อม "LIMITED TIME" badge
4. กด Claim → ได้ +2E, ปุ่มเปลี่ยนเป็น "Claimed today"
5. ปิดเปิด app → card ยังแสดงอยู่ ปุ่มเป็น "Claimed today"
6. สร้าง one_time quest → ทดสอบ claim 1 ครั้งแล้วเปลี่ยนเป็น "Claimed!"

---

## Checklist สำหรับ Review

เมื่อเสร็จทุก step ให้ตรวจสอบ:

- [ ] Admin Panel: Tab "Seasonal Quests" แสดงถูกต้อง
- [ ] Admin Panel: สร้าง quest ทั้ง fixed_date และ duration ได้
- [ ] Admin Panel: Pause / Resume / Delete ทำงาน
- [ ] Firestore: collection `seasonal_quests` มีข้อมูลถูกต้อง
- [ ] Backend: `syncBalance` response มี `seasonalQuests` array
- [ ] Backend: `registerUser` response มี `seasonalQuests` array
- [ ] Backend: `completeChallenge` type `"seasonal"` claim ได้
- [ ] Backend: daily claim ซ้ำวันเดียวกัน → error
- [ ] Backend: one_time claim ซ้ำ → error
- [ ] Backend: claim นอก date range → error
- [ ] Backend: claim quest ที่ paused → error
- [ ] Flutter: QuestBar แสดง SeasonalQuestCard เมื่อมี active quest
- [ ] Flutter: Claim button ทำงาน + refresh state
- [ ] Flutter: Localization EN/TH ถูกต้อง
- [ ] Flutter: Quest ที่หมดอายุหรือ complete แล้วไม่แสดง
- [ ] ไม่มี linter errors
- [ ] ไม่มี console errors

---

## Files Changed Summary

| # | Path | Action |
|---|------|--------|
| 1 | `admin-panel/src/app/api/seasonal-quests/route.ts` | **CREATE** |
| 2 | `admin-panel/src/app/api/seasonal-quests/[id]/route.ts` | **CREATE** |
| 3 | `admin-panel/src/app/(dashboard)/campaigns/push/page.tsx` | **EDIT** |
| 4 | `functions/src/energy/seasonalQuest.ts` | **CREATE** |
| 5 | `functions/src/energy/challenge.ts` | **EDIT** |
| 6 | `functions/src/syncBalance.ts` | **EDIT** |
| 7 | `functions/src/registerUser.ts` | **EDIT** |
| 8 | `lib/core/models/gamification_state.dart` | **EDIT** |
| 9 | `lib/core/services/energy_service.dart` | **EDIT** |
| 10 | `lib/features/energy/providers/gamification_provider.dart` | **EDIT** |
| 11 | `lib/features/energy/widgets/seasonal_quest_card.dart` | **CREATE** |
| 12 | `lib/features/energy/widgets/quest_bar.dart` | **EDIT** |
| 13 | `lib/l10n/app_en.arb` | **EDIT** |
| 14 | `lib/l10n/app_th.arb` | **EDIT** |
