# Phase 3 - Task 4: Config Management

**Status:** 📝 Ready for Implementation  
**Estimated Time:** 6-8 hours  
**Difficulty:** ⭐⭐⭐ Medium  
**Prerequisites:** Task 1, 2, 3 must be completed

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

In this task, you will create a configuration management system that allows admins to:

- **Manage Weekly Challenges** - Edit goals, rewards, enable/disable
- **Manage Milestones** - Edit thresholds, rewards, add new milestones
- **Manage A/B Testing** - Create test variants, set distribution, view results
- **Manage System Settings** - Free AI credits, streak grace period, energy costs
- **View Change History** - Audit log of all config changes

All configurations are stored in a single Firestore document: `config/gamification`

---

## 📊 Requirements

### Functional Requirements
- [ ] View current configuration values
- [ ] Edit challenge goals and rewards
- [ ] Edit milestone thresholds and rewards
- [ ] Create and manage A/B test variants
- [ ] Update system settings (AI credits, grace period, etc.)
- [ ] Real-time preview of changes before saving
- [ ] Confirmation dialog for destructive changes
- [ ] Auto-save indicator
- [ ] Change history log

### Non-Functional Requirements
- [ ] Form validation using Zod
- [ ] Optimistic UI updates
- [ ] Error handling with rollback
- [ ] Responsive design

---

## 🛠️ Tech Stack

- **React Hook Form** - Form management
- **Zod** - Schema validation
- **Firebase Admin SDK** - Firestore updates
- **Shadcn/ui** - Form components

---

## 🚀 Step-by-Step Implementation

### Step 1: Create Config API Routes

#### 1.1 Get Current Config

**File:** `admin-panel/src/app/api/config/route.ts`

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

    // Get config document
    const configDoc = await db.collection('config').doc('gamification').get();

    if (!configDoc.exists) {
      // Return default config if doesn't exist
      return NextResponse.json({
        challenges: {
          logMeals: { goal: 7, reward: 30, enabled: true },
          useAi: { goal: 5, reward: 25, enabled: true },
        },
        milestones: [
          { threshold: 100, reward: 50 },
          { threshold: 500, reward: 100 },
          { threshold: 1000, reward: 200 },
          { threshold: 5000, reward: 500 },
        ],
        systemSettings: {
          freeAiCredits: 3,
          streakGracePeriod: 1,
          aiAnalysisCost: 5,
          welcomeGiftAmount: 50,
        },
        abTests: {},
      });
    }

    return NextResponse.json(configDoc.data());
  } catch (error) {
    console.error('Get config error:', error);
    return NextResponse.json(
      { error: 'Failed to fetch configuration' },
      { status: 500 }
    );
  }
}

export async function PUT(request: Request) {
  try {
    const authCheck = await requireAuth(request);
    if (authCheck instanceof NextResponse) {
      return authCheck;
    }

    const body = await request.json();
    const { section, data } = body;

    // Validate section
    const validSections = ['challenges', 'milestones', 'systemSettings', 'abTests'];
    if (!validSections.includes(section)) {
      return NextResponse.json(
        { error: 'Invalid section' },
        { status: 400 }
      );
    }

    // Update config
    const configRef = db.collection('config').doc('gamification');
    await configRef.set(
      {
        [section]: data,
        updatedAt: new Date(),
        updatedBy: 'admin', // In production, track which admin
      },
      { merge: true }
    );

    // Log change to history
    await db.collection('config_history').add({
      section,
      changes: data,
      timestamp: new Date(),
      admin: 'admin',
    });

    return NextResponse.json({
      success: true,
      message: `${section} updated successfully`,
    });
  } catch (error) {
    console.error('Update config error:', error);
    return NextResponse.json(
      { error: 'Failed to update configuration' },
      { status: 500 }
    );
  }
}
```

#### 1.2 Get Config History

**File:** `admin-panel/src/app/api/config/history/route.ts`

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

    // Get last 50 config changes
    const historySnapshot = await db
      .collection('config_history')
      .orderBy('timestamp', 'desc')
      .limit(50)
      .get();

    const history = historySnapshot.docs.map((doc) => {
      const data = doc.data();
      return {
        id: doc.id,
        section: data.section,
        changes: data.changes,
        timestamp: data.timestamp?.toDate().toISOString(),
        admin: data.admin,
      };
    });

    return NextResponse.json({ history });
  } catch (error) {
    console.error('Get config history error:', error);
    return NextResponse.json(
      { error: 'Failed to fetch config history' },
      { status: 500 }
    );
  }
}
```

---

### Step 2: Create Config UI Components

#### 2.1 Challenge Config Component

**File:** `admin-panel/src/components/config/ChallengeConfig.tsx`

```typescript
'use client';

import { useState, useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Save, RefreshCw } from 'lucide-react';

const challengeSchema = z.object({
  logMeals: z.object({
    goal: z.number().min(1).max(100),
    reward: z.number().min(1).max(1000),
    enabled: z.boolean(),
  }),
  useAi: z.object({
    goal: z.number().min(1).max(100),
    reward: z.number().min(1).max(1000),
    enabled: z.boolean(),
  }),
});

type ChallengeFormData = z.infer<typeof challengeSchema>;

interface ChallengeConfigProps {
  initialData: ChallengeFormData;
  onSave: (data: ChallengeFormData) => Promise<void>;
}

export function ChallengeConfig({ initialData, onSave }: ChallengeConfigProps) {
  const [isSaving, setIsSaving] = useState(false);
  const [hasChanges, setHasChanges] = useState(false);

  const {
    register,
    handleSubmit,
    watch,
    reset,
    formState: { errors },
  } = useForm<ChallengeFormData>({
    resolver: zodResolver(challengeSchema),
    defaultValues: initialData,
  });

  // Watch for changes
  useEffect(() => {
    const subscription = watch(() => setHasChanges(true));
    return () => subscription.unsubscribe();
  }, [watch]);

  const onSubmit = async (data: ChallengeFormData) => {
    try {
      setIsSaving(true);
      await onSave(data);
      setHasChanges(false);
      alert('Challenge config saved successfully!');
    } catch (error) {
      console.error('Save error:', error);
      alert('Failed to save challenge config');
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <div className="bg-white rounded-xl shadow p-6">
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-xl font-bold text-gray-900">Weekly Challenges</h2>
        {hasChanges && (
          <span className="text-sm text-orange-600 font-medium">• Unsaved Changes</span>
        )}
      </div>

      <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
        {/* Log Meals Challenge */}
        <div className="border rounded-lg p-4">
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-semibold text-gray-900">📝 Log Meals Challenge</h3>
            <label className="flex items-center space-x-2">
              <input
                type="checkbox"
                {...register('logMeals.enabled')}
                className="w-4 h-4 text-blue-600 rounded"
              />
              <span className="text-sm text-gray-700">Enabled</span>
            </label>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Goal (meals per week)
              </label>
              <input
                type="number"
                {...register('logMeals.goal', { valueAsNumber: true })}
                className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
              />
              {errors.logMeals?.goal && (
                <p className="text-red-500 text-sm mt-1">{errors.logMeals.goal.message}</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Reward (energy)
              </label>
              <input
                type="number"
                {...register('logMeals.reward', { valueAsNumber: true })}
                className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
              />
              {errors.logMeals?.reward && (
                <p className="text-red-500 text-sm mt-1">{errors.logMeals.reward.message}</p>
              )}
            </div>
          </div>
        </div>

        {/* Use AI Challenge */}
        <div className="border rounded-lg p-4">
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-semibold text-gray-900">🧠 Use AI Challenge</h3>
            <label className="flex items-center space-x-2">
              <input
                type="checkbox"
                {...register('useAi.enabled')}
                className="w-4 h-4 text-blue-600 rounded"
              />
              <span className="text-sm text-gray-700">Enabled</span>
            </label>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Goal (AI analyses per week)
              </label>
              <input
                type="number"
                {...register('useAi.goal', { valueAsNumber: true })}
                className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
              />
              {errors.useAi?.goal && (
                <p className="text-red-500 text-sm mt-1">{errors.useAi.goal.message}</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Reward (energy)
              </label>
              <input
                type="number"
                {...register('useAi.reward', { valueAsNumber: true })}
                className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
              />
              {errors.useAi?.reward && (
                <p className="text-red-500 text-sm mt-1">{errors.useAi.reward.message}</p>
              )}
            </div>
          </div>
        </div>

        {/* Action Buttons */}
        <div className="flex space-x-3">
          <button
            type="submit"
            disabled={isSaving || !hasChanges}
            className="flex items-center space-x-2 px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 transition"
          >
            <Save className="w-4 h-4" />
            <span>{isSaving ? 'Saving...' : 'Save Changes'}</span>
          </button>
          <button
            type="button"
            onClick={() => reset(initialData)}
            disabled={!hasChanges}
            className="flex items-center space-x-2 px-6 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 disabled:opacity-50 transition"
          >
            <RefreshCw className="w-4 h-4" />
            <span>Reset</span>
          </button>
        </div>
      </form>
    </div>
  );
}
```

#### 2.2 Milestone Config Component

**File:** `admin-panel/src/components/config/MilestoneConfig.tsx`

```typescript
'use client';

import { useState } from 'react';
import { Plus, Trash2, Save } from 'lucide-react';

interface Milestone {
  threshold: number;
  reward: number;
}

interface MilestoneConfigProps {
  initialData: Milestone[];
  onSave: (data: Milestone[]) => Promise<void>;
}

export function MilestoneConfig({ initialData, onSave }: MilestoneConfigProps) {
  const [milestones, setMilestones] = useState<Milestone[]>(initialData);
  const [isSaving, setIsSaving] = useState(false);
  const [hasChanges, setHasChanges] = useState(false);

  const handleAdd = () => {
    setMilestones([...milestones, { threshold: 0, reward: 0 }]);
    setHasChanges(true);
  };

  const handleRemove = (index: number) => {
    setMilestones(milestones.filter((_, i) => i !== index));
    setHasChanges(true);
  };

  const handleChange = (index: number, field: keyof Milestone, value: number) => {
    const updated = [...milestones];
    updated[index][field] = value;
    setMilestones(updated);
    setHasChanges(true);
  };

  const handleSave = async () => {
    // Validate
    const sorted = [...milestones].sort((a, b) => a.threshold - b.threshold);
    const hasInvalid = sorted.some((m) => m.threshold <= 0 || m.reward <= 0);
    
    if (hasInvalid) {
      alert('All thresholds and rewards must be greater than 0');
      return;
    }

    try {
      setIsSaving(true);
      await onSave(sorted);
      setMilestones(sorted);
      setHasChanges(false);
      alert('Milestones saved successfully!');
    } catch (error) {
      console.error('Save error:', error);
      alert('Failed to save milestones');
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <div className="bg-white rounded-xl shadow p-6">
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-xl font-bold text-gray-900">Milestone Rewards</h2>
        {hasChanges && (
          <span className="text-sm text-orange-600 font-medium">• Unsaved Changes</span>
        )}
      </div>

      <div className="space-y-3 mb-6">
        {milestones.map((milestone, index) => (
          <div key={index} className="flex items-center space-x-3 p-3 border rounded-lg">
            <div className="flex-1 grid grid-cols-2 gap-3">
              <div>
                <label className="block text-xs text-gray-600 mb-1">
                  Threshold (energy spent)
                </label>
                <input
                  type="number"
                  value={milestone.threshold}
                  onChange={(e) =>
                    handleChange(index, 'threshold', parseInt(e.target.value) || 0)
                  }
                  className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
                />
              </div>
              <div>
                <label className="block text-xs text-gray-600 mb-1">Reward (energy)</label>
                <input
                  type="number"
                  value={milestone.reward}
                  onChange={(e) =>
                    handleChange(index, 'reward', parseInt(e.target.value) || 0)
                  }
                  className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
                />
              </div>
            </div>
            <button
              onClick={() => handleRemove(index)}
              className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition"
            >
              <Trash2 className="w-5 h-5" />
            </button>
          </div>
        ))}
      </div>

      <div className="flex space-x-3">
        <button
          onClick={handleAdd}
          className="flex items-center space-x-2 px-4 py-2 border-2 border-dashed border-gray-300 rounded-lg hover:border-blue-500 hover:bg-blue-50 transition"
        >
          <Plus className="w-4 h-4" />
          <span>Add Milestone</span>
        </button>
        <button
          onClick={handleSave}
          disabled={isSaving || !hasChanges}
          className="flex items-center space-x-2 px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 transition"
        >
          <Save className="w-4 h-4" />
          <span>{isSaving ? 'Saving...' : 'Save Changes'}</span>
        </button>
      </div>
    </div>
  );
}
```

#### 2.3 System Settings Component

**File:** `admin-panel/src/components/config/SystemSettings.tsx`

```typescript
'use client';

import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Save } from 'lucide-react';

const systemSettingsSchema = z.object({
  freeAiCredits: z.number().min(0).max(10),
  streakGracePeriod: z.number().min(0).max(7),
  aiAnalysisCost: z.number().min(1).max(50),
  welcomeGiftAmount: z.number().min(0).max(1000),
});

type SystemSettingsFormData = z.infer<typeof systemSettingsSchema>;

interface SystemSettingsProps {
  initialData: SystemSettingsFormData;
  onSave: (data: SystemSettingsFormData) => Promise<void>;
}

export function SystemSettings({ initialData, onSave }: SystemSettingsProps) {
  const [isSaving, setIsSaving] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors, isDirty },
  } = useForm<SystemSettingsFormData>({
    resolver: zodResolver(systemSettingsSchema),
    defaultValues: initialData,
  });

  const onSubmit = async (data: SystemSettingsFormData) => {
    try {
      setIsSaving(true);
      await onSave(data);
      alert('System settings saved successfully!');
    } catch (error) {
      console.error('Save error:', error);
      alert('Failed to save system settings');
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <div className="bg-white rounded-xl shadow p-6">
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-xl font-bold text-gray-900">System Settings</h2>
        {isDirty && (
          <span className="text-sm text-orange-600 font-medium">• Unsaved Changes</span>
        )}
      </div>

      <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Free AI Credits per Day
            </label>
            <input
              type="number"
              {...register('freeAiCredits', { valueAsNumber: true })}
              className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
            />
            {errors.freeAiCredits && (
              <p className="text-red-500 text-sm mt-1">{errors.freeAiCredits.message}</p>
            )}
            <p className="text-xs text-gray-500 mt-1">
              How many free AI analyses users get daily
            </p>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Streak Grace Period (days)
            </label>
            <input
              type="number"
              {...register('streakGracePeriod', { valueAsNumber: true })}
              className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
            />
            {errors.streakGracePeriod && (
              <p className="text-red-500 text-sm mt-1">{errors.streakGracePeriod.message}</p>
            )}
            <p className="text-xs text-gray-500 mt-1">
              Days users can skip without losing streak
            </p>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              AI Analysis Cost (energy)
            </label>
            <input
              type="number"
              {...register('aiAnalysisCost', { valueAsNumber: true })}
              className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
            />
            {errors.aiAnalysisCost && (
              <p className="text-red-500 text-sm mt-1">{errors.aiAnalysisCost.message}</p>
            )}
            <p className="text-xs text-gray-500 mt-1">
              Energy cost per AI food analysis
            </p>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Welcome Gift Amount (energy)
            </label>
            <input
              type="number"
              {...register('welcomeGiftAmount', { valueAsNumber: true })}
              className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
            />
            {errors.welcomeGiftAmount && (
              <p className="text-red-500 text-sm mt-1">{errors.welcomeGiftAmount.message}</p>
            )}
            <p className="text-xs text-gray-500 mt-1">
              Energy gift for new users
            </p>
          </div>
        </div>

        <button
          type="submit"
          disabled={isSaving || !isDirty}
          className="flex items-center space-x-2 px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 transition"
        >
          <Save className="w-4 h-4" />
          <span>{isSaving ? 'Saving...' : 'Save Changes'}</span>
        </button>
      </form>
    </div>
  );
}
```

#### 2.4 Config History Component

**File:** `admin-panel/src/components/config/ConfigHistory.tsx`

```typescript
'use client';

import { useEffect, useState } from 'react';
import { format } from 'date-fns';
import { History } from 'lucide-react';

interface ConfigChange {
  id: string;
  section: string;
  changes: any;
  timestamp: string;
  admin: string;
}

export function ConfigHistory() {
  const [history, setHistory] = useState<ConfigChange[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    fetchHistory();
  }, []);

  const fetchHistory = async () => {
    try {
      const response = await fetch('/api/config/history');
      if (!response.ok) throw new Error('Failed to fetch history');
      const data = await response.json();
      setHistory(data.history);
    } catch (error) {
      console.error('Fetch history error:', error);
    } finally {
      setIsLoading(false);
    }
  };

  if (isLoading) {
    return (
      <div className="bg-white rounded-xl shadow p-6">
        <h2 className="text-xl font-bold text-gray-900 mb-4">Change History</h2>
        <div className="space-y-3">
          {[1, 2, 3].map((i) => (
            <div key={i} className="animate-pulse h-16 bg-gray-100 rounded-lg"></div>
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="bg-white rounded-xl shadow p-6">
      <div className="flex items-center space-x-2 mb-4">
        <History className="w-5 h-5 text-gray-600" />
        <h2 className="text-xl font-bold text-gray-900">Change History</h2>
      </div>

      {history.length === 0 ? (
        <p className="text-gray-500 text-center py-8">No changes yet</p>
      ) : (
        <div className="space-y-3">
          {history.map((change) => (
            <div key={change.id} className="border rounded-lg p-4">
              <div className="flex items-center justify-between mb-2">
                <span className="font-medium text-gray-900 capitalize">
                  {change.section.replace(/([A-Z])/g, ' $1').trim()}
                </span>
                <span className="text-sm text-gray-500">
                  {format(new Date(change.timestamp), 'PPpp')}
                </span>
              </div>
              <p className="text-sm text-gray-600">
                Changed by: <span className="font-medium">{change.admin}</span>
              </p>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
```

---

### Step 3: Create Config Management Page

**File:** `admin-panel/src/app/config/page.tsx`

```typescript
'use client';

import { useEffect, useState } from 'react';
import { ChallengeConfig } from '@/components/config/ChallengeConfig';
import { MilestoneConfig } from '@/components/config/MilestoneConfig';
import { SystemSettings } from '@/components/config/SystemSettings';
import { ConfigHistory } from '@/components/config/ConfigHistory';

export default function ConfigPage() {
  const [config, setConfig] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    fetchConfig();
  }, []);

  const fetchConfig = async () => {
    try {
      const response = await fetch('/api/config');
      if (!response.ok) throw new Error('Failed to fetch config');
      const data = await response.json();
      setConfig(data);
    } catch (error) {
      console.error('Fetch config error:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const handleSaveSection = async (section: string, data: any) => {
    const response = await fetch('/api/config', {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ section, data }),
    });

    if (!response.ok) throw new Error('Failed to save config');

    // Refresh config
    await fetchConfig();
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading configuration...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900">Configuration Management</h1>
          <p className="text-gray-600 mt-2">
            Manage system settings, challenges, and milestones
          </p>
        </div>

        <div className="space-y-6">
          {/* Challenges */}
          <ChallengeConfig
            initialData={config.challenges}
            onSave={(data) => handleSaveSection('challenges', data)}
          />

          {/* Milestones */}
          <MilestoneConfig
            initialData={config.milestones}
            onSave={(data) => handleSaveSection('milestones', data)}
          />

          {/* System Settings */}
          <SystemSettings
            initialData={config.systemSettings}
            onSave={(data) => handleSaveSection('systemSettings', data)}
          />

          {/* Change History */}
          <ConfigHistory />
        </div>
      </div>
    </div>
  );
}
```

---

## 🧪 Testing

### Step 1: Test API Routes

```javascript
// Get config
fetch('/api/config')
  .then(r => r.json())
  .then(console.log);

// Update config
fetch('/api/config', {
  method: 'PUT',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    section: 'systemSettings',
    data: { freeAiCredits: 5 }
  })
});
```

### Step 2: Test UI

1. Navigate to `/config`
2. Change challenge goals and save
3. Add/remove milestones and save
4. Update system settings and save
5. Check history shows all changes

### Step 3: Verify Changes in Firebase

1. Open Firebase Console
2. Go to Firestore → `config/gamification`
3. Verify changes are saved correctly
4. Check `config_history` collection for audit log

---

## 🐛 Troubleshooting

### Issue: Changes not saving

**Solution:** Check browser console for errors. Verify auth token is valid.

### Issue: Form validation errors

**Solution:** Check Zod schema matches data structure.

### Issue: History not loading

**Solution:** Ensure Firestore index exists for `config_history` collection.

---

## ✅ Completion Checklist

- [ ] All API routes working
- [ ] Challenge config form works
- [ ] Milestone config works (add/remove/edit)
- [ ] System settings form works
- [ ] Changes save to Firestore
- [ ] History shows all changes
- [ ] Form validation works
- [ ] No console errors

---

**Documentation Version:** 1.0  
**Last Updated:** 2026-02-17
