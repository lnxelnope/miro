# Task 3: Config Management — ตั้งค่า Promotions & Challenges

**ระยะเวลา:** 5 ชั่วโมง  
**ความยาก:** ⭐⭐⭐☆☆ (ปานกลาง)

---

## 🎯 เป้าหมาย

สร้างหน้า Config สำหรับตั้งค่า:
1. **Promotion Settings** — Welcome Offer, Tier Up Bonus, Welcome Back
2. **Challenge Rewards** — Weekly challenge rewards (logMeals, useAi)
3. **Milestone Rewards** — Energy spent milestones (500, 1000)
4. **Daily Rewards** — Daily energy per tier
5. **Config History** — ประวัติการเปลี่ยนแปลง config

---

## 📸 ตัวอย่างหน้าตา

```
┌─────────────────────────────────────────┐
│  ⚙️ Config Management                   │
│                                         │
│  [Promotions] [Challenges] [Daily]     │
│                                         │
│  ┌─── Promotions Settings ───┐         │
│  │ Welcome Offer (10 spent)  │         │
│  │  Free Energy: [50]        │         │
│  │  Bonus Rate:  [40%]       │         │
│  │                           │         │
│  │ Tier Up Bonus             │         │
│  │  Bronze:  [3] + [20%]     │         │
│  │  Silver:  [5] + [20%]     │         │
│  │  Gold:   [10] + [20%]     │         │
│  │  Diamond:[15] + [20%]     │         │
│  │                           │         │
│  │ Welcome Back (ex-Diamond) │         │
│  │  Bonus Rate: [40%]        │         │
│  │                           │         │
│  │  [Save Changes]           │         │
│  └───────────────────────────┘         │
└─────────────────────────────────────────┘
```

---

## 📝 Checklist

- [ ] Step 1: สร้าง API endpoints (get/update config)
- [ ] Step 2: สร้าง UI forms (Promotions, Challenges, Daily)
- [ ] Step 3: Config page
- [ ] Step 4: Test save/load config

---

## Step 1: API Endpoints

### 1.1 Get Config API

**ไฟล์:** `admin-panel/src/app/api/config/route.ts`

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { getFirestore } from 'firebase-admin/firestore';
import { initAdmin } from '@/lib/firebase-admin';

export async function GET(request: NextRequest) {
  try {
    initAdmin();
    const db = getFirestore();

    // Read from promotions.ts constants (or Firestore config doc)
    // For now, return current hardcoded values
    
    const config = {
      promotions: {
        welcomeOffer: {
          threshold: 10,
          freeEnergy: 50,
          bonusRate: 0.40,
          duration: 24,
        },
        tierUpgrade: {
          bonusRate: 0.20,
          duration: 24,
          rewards: {
            bronze: 3,
            silver: 5,
            gold: 10,
            diamond: 15,
          },
        },
        welcomeBack: {
          bonusRate: 0.40,
          duration: 24,
          condition: 'ex-Diamond fell to Starter/Bronze',
        },
      },
      dailyRewards: {
        none: 1,
        bronze: 1,
        silver: 2,
        gold: 3,
        diamond: 4,
      },
      challenges: {
        logMeals: {
          goal: 7,
          reward: 10,
        },
        useAi: {
          goal: 3,
          reward: 5,
        },
      },
      milestones: {
        spent500: 50,
        spent1000: 100,
      },
    };

    return NextResponse.json({
      success: true,
      config,
    });
  } catch (error: any) {
    console.error('Error fetching config:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}

export async function POST(request: NextRequest) {
  try {
    initAdmin();
    const db = getFirestore();

    const { config } = await request.json();

    if (!config) {
      return NextResponse.json({ error: 'Missing config' }, { status: 400 });
    }

    // Save to Firestore config collection
    await db.collection('config').doc('promotions').set(
      {
        ...config,
        lastUpdated: new Date().toISOString(),
      },
      { merge: true }
    );

    // Log change to history
    await db.collection('config_history').add({
      type: 'promotions',
      config,
      changedAt: new Date().toISOString(),
    });

    return NextResponse.json({ success: true });
  } catch (error: any) {
    console.error('Error updating config:', error);
    return NextResponse.json({ error: error.message }, { status: 500 });
  }
}
```

**Test:**
- GET: `http://localhost:3000/api/config`
- POST: ใช้ Postman ส่ง JSON

---

## Step 2: Config Form Components

### 2.1 Promotions Config Form

**ไฟล์:** `admin-panel/src/components/config/PromotionsForm.tsx`

```typescript
'use client';

import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';

interface PromotionsFormProps {
  initialConfig: any;
  onSave: (config: any) => void;
}

export function PromotionsForm({ initialConfig, onSave }: PromotionsFormProps) {
  const [config, setConfig] = useState(initialConfig);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSave(config);
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      {/* Welcome Offer */}
      <div className="border rounded-lg p-4">
        <h3 className="font-semibold mb-3">🎁 Welcome Offer (First 10 Energy Spent)</h3>
        <div className="grid grid-cols-2 gap-4">
          <div>
            <Label>Threshold (Energy)</Label>
            <Input
              type="number"
              value={config.promotions?.welcomeOffer?.threshold || 10}
              onChange={(e) =>
                setConfig({
                  ...config,
                  promotions: {
                    ...config.promotions,
                    welcomeOffer: {
                      ...config.promotions.welcomeOffer,
                      threshold: parseInt(e.target.value),
                    },
                  },
                })
              }
            />
          </div>
          <div>
            <Label>Free Energy</Label>
            <Input
              type="number"
              value={config.promotions?.welcomeOffer?.freeEnergy || 50}
              onChange={(e) =>
                setConfig({
                  ...config,
                  promotions: {
                    ...config.promotions,
                    welcomeOffer: {
                      ...config.promotions.welcomeOffer,
                      freeEnergy: parseInt(e.target.value),
                    },
                  },
                })
              }
            />
          </div>
          <div>
            <Label>Bonus Rate (%)</Label>
            <Input
              type="number"
              value={(config.promotions?.welcomeOffer?.bonusRate || 0.4) * 100}
              onChange={(e) =>
                setConfig({
                  ...config,
                  promotions: {
                    ...config.promotions,
                    welcomeOffer: {
                      ...config.promotions.welcomeOffer,
                      bonusRate: parseInt(e.target.value) / 100,
                    },
                  },
                })
              }
            />
          </div>
          <div>
            <Label>Duration (hours)</Label>
            <Input
              type="number"
              value={config.promotions?.welcomeOffer?.duration || 24}
              onChange={(e) =>
                setConfig({
                  ...config,
                  promotions: {
                    ...config.promotions,
                    welcomeOffer: {
                      ...config.promotions.welcomeOffer,
                      duration: parseInt(e.target.value),
                    },
                  },
                })
              }
            />
          </div>
        </div>
      </div>

      {/* Tier Upgrade Bonus */}
      <div className="border rounded-lg p-4">
        <h3 className="font-semibold mb-3">🎊 Tier Up Bonus (1-time per tier)</h3>
        <div className="space-y-3">
          {['bronze', 'silver', 'gold', 'diamond'].map((tier) => (
            <div key={tier} className="flex items-center gap-4">
              <span className="w-24 font-medium capitalize">{tier}:</span>
              <Input
                type="number"
                placeholder="Reward Energy"
                className="w-32"
                value={config.promotions?.tierUpgrade?.rewards?.[tier] || 0}
                onChange={(e) =>
                  setConfig({
                    ...config,
                    promotions: {
                      ...config.promotions,
                      tierUpgrade: {
                        ...config.promotions.tierUpgrade,
                        rewards: {
                          ...config.promotions.tierUpgrade.rewards,
                          [tier]: parseInt(e.target.value),
                        },
                      },
                    },
                  })
                }
              />
              <span className="text-sm text-gray-600">Energy + 20% bonus</span>
            </div>
          ))}
        </div>
      </div>

      {/* Welcome Back */}
      <div className="border rounded-lg p-4">
        <h3 className="font-semibold mb-3">🎁 Welcome Back (ex-Diamond fell)</h3>
        <div className="grid grid-cols-2 gap-4">
          <div>
            <Label>Bonus Rate (%)</Label>
            <Input
              type="number"
              value={(config.promotions?.welcomeBack?.bonusRate || 0.4) * 100}
              onChange={(e) =>
                setConfig({
                  ...config,
                  promotions: {
                    ...config.promotions,
                    welcomeBack: {
                      ...config.promotions.welcomeBack,
                      bonusRate: parseInt(e.target.value) / 100,
                    },
                  },
                })
              }
            />
          </div>
          <div>
            <Label>Duration (hours)</Label>
            <Input
              type="number"
              value={config.promotions?.welcomeBack?.duration || 24}
              onChange={(e) =>
                setConfig({
                  ...config,
                  promotions: {
                    ...config.promotions,
                    welcomeBack: {
                      ...config.promotions.welcomeBack,
                      duration: parseInt(e.target.value),
                    },
                  },
                })
              }
            />
          </div>
        </div>
        <p className="text-xs text-gray-500 mt-2">
          Triggers when ex-Diamond users fall to Starter or Bronze
        </p>
      </div>

      {/* Save Button */}
      <Button type="submit" className="w-full">
        💾 Save All Changes
      </Button>
    </form>
  );
}
```

---

### 2.2 Daily Rewards Config

**ไฟล์:** `admin-panel/src/components/config/DailyRewardsForm.tsx`

```typescript
'use client';

import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';

interface DailyRewardsFormProps {
  initialConfig: any;
  onSave: (config: any) => void;
}

export function DailyRewardsForm({ initialConfig, onSave }: DailyRewardsFormProps) {
  const [config, setConfig] = useState(initialConfig);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSave(config);
  };

  const tiers = [
    { key: 'none', label: 'Starter' },
    { key: 'bronze', label: 'Bronze' },
    { key: 'silver', label: 'Silver' },
    { key: 'gold', label: 'Gold' },
    { key: 'diamond', label: 'Diamond' },
  ];

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="border rounded-lg p-4">
        <h3 className="font-semibold mb-3">⚡ Daily Energy Rewards</h3>
        <p className="text-sm text-gray-600 mb-4">
          Energy given daily when user uses AI for the first time each day
        </p>
        
        <div className="space-y-3">
          {tiers.map(({ key, label }) => (
            <div key={key} className="flex items-center gap-4">
              <span className="w-24 font-medium">{label}:</span>
              <Input
                type="number"
                className="w-32"
                value={config.dailyRewards?.[key] || 1}
                onChange={(e) =>
                  setConfig({
                    ...config,
                    dailyRewards: {
                      ...config.dailyRewards,
                      [key]: parseInt(e.target.value),
                    },
                  })
                }
              />
              <span className="text-sm text-gray-600">Energy/day</span>
            </div>
          ))}
        </div>
      </div>

      <Button type="submit" className="w-full">
        💾 Save Daily Rewards
      </Button>
    </form>
  );
}
```

---

### 2.3 Challenges Config

**ไฟล์:** `admin-panel/src/components/config/ChallengesForm.tsx`

```typescript
'use client';

import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';

interface ChallengesFormProps {
  initialConfig: any;
  onSave: (config: any) => void;
}

export function ChallengesForm({ initialConfig, onSave }: ChallengesFormProps) {
  const [config, setConfig] = useState(initialConfig);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSave(config);
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="border rounded-lg p-4">
        <h3 className="font-semibold mb-3">🏆 Weekly Challenges</h3>
        
        <div className="space-y-4">
          {/* Log Meals */}
          <div>
            <h4 className="font-medium mb-2">📝 Log Meals Challenge</h4>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <Label>Goal (meals/week)</Label>
                <Input
                  type="number"
                  value={config.challenges?.logMeals?.goal || 7}
                  onChange={(e) =>
                    setConfig({
                      ...config,
                      challenges: {
                        ...config.challenges,
                        logMeals: {
                          ...config.challenges.logMeals,
                          goal: parseInt(e.target.value),
                        },
                      },
                    })
                  }
                />
              </div>
              <div>
                <Label>Reward (Energy)</Label>
                <Input
                  type="number"
                  value={config.challenges?.logMeals?.reward || 10}
                  onChange={(e) =>
                    setConfig({
                      ...config,
                      challenges: {
                        ...config.challenges,
                        logMeals: {
                          ...config.challenges.logMeals,
                          reward: parseInt(e.target.value),
                        },
                      },
                    })
                  }
                />
              </div>
            </div>
          </div>

          {/* Use AI */}
          <div>
            <h4 className="font-medium mb-2">🤖 Use AI Challenge</h4>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <Label>Goal (times/week)</Label>
                <Input
                  type="number"
                  value={config.challenges?.useAi?.goal || 3}
                  onChange={(e) =>
                    setConfig({
                      ...config,
                      challenges: {
                        ...config.challenges,
                        useAi: {
                          ...config.challenges.useAi,
                          goal: parseInt(e.target.value),
                        },
                      },
                    })
                  }
                />
              </div>
              <div>
                <Label>Reward (Energy)</Label>
                <Input
                  type="number"
                  value={config.challenges?.useAi?.reward || 5}
                  onChange={(e) =>
                    setConfig({
                      ...config,
                      challenges: {
                        ...config.challenges,
                        useAi: {
                          ...config.challenges.useAi,
                          reward: parseInt(e.target.value),
                        },
                      },
                    })
                  }
                />
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Milestones */}
      <div className="border rounded-lg p-4">
        <h3 className="font-semibold mb-3">🎯 Milestone Rewards</h3>
        <div className="space-y-3">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <Label>500 Energy Spent Milestone</Label>
              <Input
                type="number"
                value={config.milestones?.spent500 || 50}
                onChange={(e) =>
                  setConfig({
                    ...config,
                    milestones: {
                      ...config.milestones,
                      spent500: parseInt(e.target.value),
                    },
                  })
                }
              />
            </div>
            <div>
              <Label>1000 Energy Spent Milestone</Label>
              <Input
                type="number"
                value={config.milestones?.spent1000 || 100}
                onChange={(e) =>
                  setConfig({
                    ...config,
                    milestones: {
                      ...config.milestones,
                      spent1000: parseInt(e.target.value),
                    },
                  })
                }
              />
            </div>
          </div>
        </div>
      </div>

      <Button type="submit" className="w-full">
        💾 Save Config
      </Button>
    </form>
  );
}
```

---

## Step 3: Config Page

**ไฟล์:** `admin-panel/src/app/(dashboard)/config/page.tsx`

```typescript
'use client';

import { useEffect, useState } from 'react';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { PromotionsForm } from '@/components/config/PromotionsForm';
import { DailyRewardsForm } from '@/components/config/DailyRewardsForm';
import { ChallengesForm } from '@/components/config/ChallengesForm';

export default function ConfigPage() {
  const [config, setConfig] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    fetch('/api/config')
      .then((res) => res.json())
      .then((data) => {
        setConfig(data.config);
        setLoading(false);
      })
      .catch((err) => {
        console.error(err);
        setLoading(false);
      });
  }, []);

  const handleSave = async (updatedConfig: any) => {
    setSaving(true);
    try {
      const res = await fetch('/api/config', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ config: updatedConfig }),
      });

      if (res.ok) {
        alert('✅ Config saved!');
        setConfig(updatedConfig);
      } else {
        alert('❌ Failed to save config');
      }
    } catch (err) {
      alert('Error: ' + err);
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="p-8">
        <div className="text-center py-12">Loading config...</div>
      </div>
    );
  }

  return (
    <div className="p-8">
      <h1 className="text-3xl font-bold mb-6">⚙️ Config Management</h1>

      <div className="bg-white rounded-lg shadow p-6">
        <Tabs defaultValue="promotions">
          <TabsList className="grid w-full grid-cols-3">
            <TabsTrigger value="promotions">🎁 Promotions</TabsTrigger>
            <TabsTrigger value="daily">⚡ Daily Rewards</TabsTrigger>
            <TabsTrigger value="challenges">🏆 Challenges</TabsTrigger>
          </TabsList>

          <TabsContent value="promotions" className="mt-6">
            <PromotionsForm initialConfig={config} onSave={handleSave} />
          </TabsContent>

          <TabsContent value="daily" className="mt-6">
            <DailyRewardsForm initialConfig={config} onSave={handleSave} />
          </TabsContent>

          <TabsContent value="challenges" className="mt-6">
            <ChallengesForm initialConfig={config} onSave={handleSave} />
          </TabsContent>
        </Tabs>
      </div>

      {saving && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center">
          <div className="bg-white rounded-lg p-6">
            <p>Saving config...</p>
          </div>
        </div>
      )}
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
  name: 'Config',
  href: '/config',
  icon: '⚙️',
},
```

---

## Step 5: Test

### Checklist

- [ ] เปิดหน้า Config: `http://localhost:3000/config`
- [ ] แสดง 3 tabs: Promotions, Daily, Challenges
- [ ] แก้ค่า Welcome Offer (threshold, free energy, bonus %) → Save → reload → ค่ายังอยู่
- [ ] แก้ค่า Tier rewards → Save → reload → ค่ายังอยู่
- [ ] แก้ค่า Daily rewards → Save → reload → ค่ายังอยู่
- [ ] ไม่มี error

---

## 🎉 เสร็จแล้ว Task 3!

ไฟล์ถัดไป: `TASK_4_SUBSCRIPTIONS.md`

---

## 🔧 Troubleshooting

### ปัญหา: Tabs ไม่แสดง

**แก้:**
```powershell
npx shadcn-ui@latest add tabs
```

### ปัญหา: Config save แล้วหาย

**แก้:** เช็คว่า POST API บันทึกลง Firestore ถูก collection (`config`)

### ปัญหา: Label component ไม่มี

**แก้:**
```powershell
npx shadcn-ui@latest add label
```
