'use client';

import { 
  Target, Rocket, BarChart3, Users, Shield, Zap,
  CheckCircle2, Clock, AlertCircle, ChevronDown, ChevronUp 
} from 'lucide-react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { useState } from 'react';

interface PlanPhase {
  id: string;
  phase: string;
  title: string;
  status: 'done' | 'in-progress' | 'planned';
  effort: string;
  description: string;
  items: {
    task: string;
    detail: string;
    status: 'done' | 'in-progress' | 'planned';
  }[];
}

const phases: PlanPhase[] = [
  {
    id: 'phase1',
    phase: 'Phase 1',
    title: 'Firebase Analytics + Google Ads Foundation',
    status: 'in-progress',
    effort: '1-2 days',
    description: 'เพิ่ม Firebase Analytics เพื่อ track user behavior และเชื่อมกับ Google Ads สำหรับ conversion tracking',
    items: [
      {
        task: 'เพิ่ม firebase_analytics package ใน Flutter',
        detail: 'ติดตั้ง firebase_analytics + firebase_analytics_web, init ใน main.dart',
        status: 'in-progress',
      },
      {
        task: 'Log Core Events',
        detail: 'first_open, purchase (energy), subscribe, ai_analysis, daily_checkin, meal_logged, barcode_scan',
        status: 'planned',
      },
      {
        task: 'Log User Properties',
        detail: 'tier, is_subscriber, total_spent, streak_days, device_language, app_version',
        status: 'planned',
      },
      {
        task: 'Link Firebase Project กับ Google Ads',
        detail: 'Firebase Console → Project Settings → Integrations → Google Ads → Link',
        status: 'planned',
      },
      {
        task: 'สร้าง Conversion Events ใน Google Ads',
        detail: 'purchase, subscribe, first_ai_analysis → ใช้เป็น conversion goal สำหรับ campaigns',
        status: 'planned',
      },
    ],
  },
  {
    id: 'phase2',
    phase: 'Phase 2',
    title: 'Attribution + Advertising ID',
    status: 'planned',
    effort: '3-5 days',
    description: 'เพิ่ม Attribution SDK เพื่อวัด ROI ของ ad campaigns และเก็บ Advertising ID สำหรับ Custom Audiences',
    items: [
      {
        task: 'เพิ่ม Attribution SDK (AppsFlyer Free Plan)',
        detail: 'รองรับ 10K conversions/เดือนฟรี, track installs จาก ad campaigns ต่างๆ, ส่ง postback อัตโนมัติ',
        status: 'planned',
      },
      {
        task: 'เก็บ GAID (Google Advertising ID)',
        detail: 'ใช้ advertising_id package, เก็บใน Firestore users/{deviceId}.gaid, ใช้สร้าง Custom Audience',
        status: 'planned',
      },
      {
        task: 'เก็บ IDFA (iOS Advertising ID)',
        detail: 'ต้องขอ ATT permission (App Tracking Transparency) ก่อน, ~25% opt-in rate, ใช้สำหรับ Meta/Google Ads',
        status: 'planned',
      },
      {
        task: 'SKAdNetwork (SKAN) Setup สำหรับ iOS',
        detail: 'Privacy-preserving attribution ของ Apple, ทำงานแม้ user ปฏิเสธ ATT, ข้อมูลจำกัดแต่ดีกว่าไม่มี',
        status: 'planned',
      },
      {
        task: 'สร้าง Custom Audiences จาก GAID/IDFA',
        detail: 'Upload high-value users (subscribers, high spenders) ไป Meta Ads / Google Ads เพื่อหา lookalike',
        status: 'planned',
      },
    ],
  },
  {
    id: 'phase3',
    phase: 'Phase 3',
    title: 'Advanced Segmentation + Optimization',
    status: 'planned',
    effort: '1-2 weeks',
    description: 'วิเคราะห์ user segments ที่ convert ดีที่สุด และ optimize ad targeting ตามข้อมูลจริง',
    items: [
      {
        task: 'วิเคราะห์ User Segments ที่ Convert ดี',
        detail: 'หา pattern: user แบบไหน subscribe? (tier, streak, first purchase timing, feature usage)',
        status: 'planned',
      },
      {
        task: 'สร้าง Lookalike Audiences จาก Segments',
        detail: 'ส่ง high-value user lists ไป ad networks, สร้าง 1-5% lookalike audiences',
        status: 'planned',
      },
      {
        task: 'A/B Test Ad Creatives ตาม Segment',
        detail: 'ทดสอบ ad messages ต่างกันสำหรับ health-focused vs gamification-focused users',
        status: 'planned',
      },
      {
        task: 'Retargeting Campaigns',
        detail: 'Target users ที่ install แล้วแต่ไม่ subscribe (ผ่าน GAID/IDFA matching)',
        status: 'planned',
      },
      {
        task: 'Cross-platform Campaign Analytics',
        detail: 'Dashboard รวม ROI จากทุก ad network (Google, Meta, TikTok) ใน admin panel',
        status: 'planned',
      },
    ],
  },
];

const dataCollectionPlan = [
  {
    category: 'Behavioral Events',
    icon: BarChart3,
    current: 'ไม่มี analytics events',
    planned: [
      'first_open — เปิดแอปครั้งแรก',
      'ai_analysis — ใช้ AI วิเคราะห์อาหาร',
      'meal_logged — บันทึกมื้ออาหาร',
      'purchase — ซื้อ energy',
      'subscribe — สมัคร Energy Pass',
      'daily_checkin — เช็คอินรายวัน',
      'barcode_scan — สแกนบาร์โค้ด',
      'streak_milestone — ถึง streak milestone',
      'challenge_completed — ทำ challenge สำเร็จ',
    ],
  },
  {
    category: 'User Properties',
    icon: Users,
    current: 'tier, balance, streak (Firestore only)',
    planned: [
      'user_tier — none/bronze/silver/gold/diamond',
      'is_subscriber — true/false',
      'total_energy_spent — cumulative spending',
      'streak_days — current streak length',
      'preferred_language — th/en',
      'app_version — version code',
    ],
  },
  {
    category: 'Advertising IDs',
    icon: Target,
    current: 'ไม่มี',
    planned: [
      'GAID (Google Advertising ID) — Android',
      'IDFA (Identifier for Advertisers) — iOS (ต้องขอ ATT)',
      'App Instance ID — Firebase-generated',
    ],
  },
  {
    category: 'Attribution Data',
    icon: Rocket,
    current: 'ไม่มี',
    planned: [
      'Install source — organic / paid / referral',
      'Campaign name — ชื่อ campaign ที่นำ user มา',
      'Ad network — Google / Meta / TikTok',
      'Cost per install (CPI)',
      'Return on ad spend (ROAS)',
    ],
  },
];

const adNetworkInfo = [
  {
    name: 'Google Ads',
    compatibility: 'high',
    requirements: 'Firebase Analytics + Google Ads account',
    features: [
      'App campaigns (Universal App Campaigns)',
      'Conversion tracking ผ่าน Firebase',
      'Lookalike audiences อัตโนมัติ',
      'Search ads + Display ads + YouTube',
    ],
    note: 'เชื่อม Firebase ได้เลย ง่ายสุด',
  },
  {
    name: 'Meta Ads (Facebook/Instagram)',
    compatibility: 'medium',
    requirements: 'Meta SDK หรือ GAID/IDFA upload',
    features: [
      'Custom Audiences จาก GAID list',
      'Lookalike Audiences 1-10%',
      'App Install campaigns',
      'Conversion API (server-side)',
    ],
    note: 'ต้องเก็บ GAID/IDFA ก่อน หรือใช้ Conversion API',
  },
  {
    name: 'TikTok Ads',
    compatibility: 'medium',
    requirements: 'TikTok SDK หรือ Attribution SDK',
    features: [
      'App Install campaigns',
      'Custom Audiences',
      'Lookalike Audiences',
      'Event optimization',
    ],
    note: 'เหมาะกับ young audience, ใช้ AppsFlyer integration ได้',
  },
  {
    name: 'Apple Search Ads',
    compatibility: 'high',
    requirements: 'Apple Search Ads account + SKAN',
    features: [
      'Search result ads ใน App Store',
      'ไม่ต้อง IDFA (ใช้ Apple attribution API)',
      'Basic tier ฟรี',
      'High intent users',
    ],
    note: 'User จาก Search Ads มี intent สูงมาก, ROI ดี',
  },
];

function StatusBadge({ status }: { status: 'done' | 'in-progress' | 'planned' }) {
  const config = {
    done: { label: 'Done', color: 'bg-green-100 text-green-800', icon: CheckCircle2 },
    'in-progress': { label: 'In Progress', color: 'bg-blue-100 text-blue-800', icon: Clock },
    planned: { label: 'Planned', color: 'bg-gray-100 text-gray-600', icon: AlertCircle },
  };
  const c = config[status];
  const Icon = c.icon;
  return (
    <span className={`inline-flex items-center gap-1 px-2 py-1 rounded-full text-xs font-medium ${c.color}`}>
      <Icon className="w-3 h-3" />
      {c.label}
    </span>
  );
}

function CompatibilityBadge({ level }: { level: string }) {
  const color = level === 'high' ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800';
  return (
    <span className={`px-2 py-1 rounded-full text-xs font-medium ${color}`}>
      {level === 'high' ? 'Easy to integrate' : 'Needs additional setup'}
    </span>
  );
}

export default function RoadmapPage() {
  const [expandedPhase, setExpandedPhase] = useState<string | null>('phase1');

  return (
    <div className="p-8 max-w-6xl">
      <div className="mb-8">
        <h1 className="text-3xl font-bold flex items-center gap-3">
          <Rocket className="w-8 h-8 text-blue-600" />
          Future Growth Plan
        </h1>
        <p className="text-gray-600 mt-2">
          User Acquisition Roadmap — เก็บข้อมูลอะไร, ส่งให้ใคร, เพื่อหา users ใหม่
        </p>
      </div>

      {/* Current System Status */}
      <Card className="mb-8 border-amber-200 bg-amber-50">
        <CardHeader>
          <CardTitle className="text-lg flex items-center gap-2">
            <Shield className="w-5 h-5 text-amber-600" />
            ระบบปัจจุบัน: Anonymous Device-ID Based
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
            <div>
              <p className="font-medium text-amber-800">User Identification</p>
              <p className="text-amber-700">Device ID (ANDROID_ID / IDFV)</p>
              <p className="text-amber-600 text-xs mt-1">ไม่มี email, ชื่อ, หรือ login</p>
            </div>
            <div>
              <p className="font-medium text-amber-800">Analytics</p>
              <p className="text-amber-700">ยังไม่มี Firebase Analytics</p>
              <p className="text-amber-600 text-xs mt-1">เก็บแค่ balance/streak ใน Firestore</p>
            </div>
            <div>
              <p className="font-medium text-amber-800">Ad Attribution</p>
              <p className="text-amber-700">ไม่มี attribution SDK</p>
              <p className="text-amber-600 text-xs mt-1">ไม่รู้ว่า user มาจาก channel ไหน</p>
            </div>
          </div>
          <div className="mt-4 p-3 bg-white rounded-lg border border-amber-200">
            <p className="text-sm text-amber-800">
              <strong>ข้อดี:</strong> ระบบ anonymous ไม่เป็นอุปสรรค — Ad networks ต้องการ Advertising ID (GAID/IDFA) 
              และ conversion events ไม่ใช่ email/ชื่อ user
            </p>
          </div>
        </CardContent>
      </Card>

      {/* Implementation Phases */}
      <h2 className="text-xl font-bold mb-4 flex items-center gap-2">
        <Zap className="w-5 h-5 text-purple-600" />
        Implementation Roadmap
      </h2>

      <div className="space-y-4 mb-8">
        {phases.map((phase) => (
          <Card key={phase.id} className="overflow-hidden">
            <button
              className="w-full text-left"
              onClick={() => setExpandedPhase(expandedPhase === phase.id ? null : phase.id)}
            >
              <CardHeader className="flex flex-row items-center justify-between py-4">
                <div className="flex items-center gap-4">
                  <span className="text-sm font-bold text-blue-600 bg-blue-50 px-3 py-1 rounded-full">
                    {phase.phase}
                  </span>
                  <div>
                    <CardTitle className="text-base">{phase.title}</CardTitle>
                    <p className="text-sm text-gray-500 mt-1">Effort: {phase.effort}</p>
                  </div>
                </div>
                <div className="flex items-center gap-3">
                  <StatusBadge status={phase.status} />
                  {expandedPhase === phase.id ? (
                    <ChevronUp className="w-5 h-5 text-gray-400" />
                  ) : (
                    <ChevronDown className="w-5 h-5 text-gray-400" />
                  )}
                </div>
              </CardHeader>
            </button>

            {expandedPhase === phase.id && (
              <CardContent className="pt-0 pb-4">
                <p className="text-sm text-gray-600 mb-4">{phase.description}</p>
                <div className="space-y-3">
                  {phase.items.map((item, idx) => (
                    <div key={idx} className="flex items-start gap-3 p-3 bg-gray-50 rounded-lg">
                      <StatusBadge status={item.status} />
                      <div className="flex-1 min-w-0">
                        <p className="font-medium text-sm">{item.task}</p>
                        <p className="text-xs text-gray-500 mt-1">{item.detail}</p>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            )}
          </Card>
        ))}
      </div>

      {/* Data Collection Plan */}
      <h2 className="text-xl font-bold mb-4 flex items-center gap-2">
        <BarChart3 className="w-5 h-5 text-green-600" />
        Data Collection Plan
      </h2>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-8">
        {dataCollectionPlan.map((item) => {
          const Icon = item.icon;
          return (
            <Card key={item.category}>
              <CardHeader className="pb-2">
                <CardTitle className="text-base flex items-center gap-2">
                  <Icon className="w-4 h-4 text-gray-600" />
                  {item.category}
                </CardTitle>
                <p className="text-xs text-red-500">Current: {item.current}</p>
              </CardHeader>
              <CardContent>
                <p className="text-xs font-medium text-green-700 mb-2">Planned:</p>
                <ul className="space-y-1">
                  {item.planned.map((p, idx) => (
                    <li key={idx} className="text-xs text-gray-600 flex items-start gap-1">
                      <span className="text-green-500 mt-0.5">+</span>
                      {p}
                    </li>
                  ))}
                </ul>
              </CardContent>
            </Card>
          );
        })}
      </div>

      {/* Ad Network Compatibility */}
      <h2 className="text-xl font-bold mb-4 flex items-center gap-2">
        <Target className="w-5 h-5 text-red-600" />
        Ad Network Compatibility
      </h2>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-8">
        {adNetworkInfo.map((network) => (
          <Card key={network.name}>
            <CardHeader className="pb-2">
              <div className="flex items-center justify-between">
                <CardTitle className="text-base">{network.name}</CardTitle>
                <CompatibilityBadge level={network.compatibility} />
              </div>
              <p className="text-xs text-gray-500">Requires: {network.requirements}</p>
            </CardHeader>
            <CardContent>
              <ul className="space-y-1 mb-3">
                {network.features.map((f, idx) => (
                  <li key={idx} className="text-xs text-gray-600 flex items-center gap-1">
                    <CheckCircle2 className="w-3 h-3 text-green-500 flex-shrink-0" />
                    {f}
                  </li>
                ))}
              </ul>
              <p className="text-xs text-blue-600 bg-blue-50 p-2 rounded">
                {network.note}
              </p>
            </CardContent>
          </Card>
        ))}
      </div>

      {/* Key Insights */}
      <Card className="border-blue-200 bg-blue-50">
        <CardHeader>
          <CardTitle className="text-lg">Key Insights</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-3 text-sm">
            <div className="flex items-start gap-2">
              <span className="text-blue-600 font-bold">1.</span>
              <p>
                <strong>Anonymous ≠ Invisible:</strong> Ad networks ไม่ต้องการ email/ชื่อ user 
                — ต้องการ GAID/IDFA + conversion events เพื่อหา lookalike audiences
              </p>
            </div>
            <div className="flex items-start gap-2">
              <span className="text-blue-600 font-bold">2.</span>
              <p>
                <strong>Firebase Analytics เป็น Quick Win:</strong> มี Firebase อยู่แล้ว 
                แค่เพิ่ม analytics package → link Google Ads → สร้าง conversion campaigns ได้ทันที
              </p>
            </div>
            <div className="flex items-start gap-2">
              <span className="text-blue-600 font-bold">3.</span>
              <p>
                <strong>Privacy-first approach:</strong> ไม่ต้อง collect PII (personal info) เลย 
                — ใช้ device-level signals + behavioral events เพียงพอสำหรับ ad targeting
              </p>
            </div>
            <div className="flex items-start gap-2">
              <span className="text-blue-600 font-bold">4.</span>
              <p>
                <strong>Play Store / App Store ไม่บอกว่าใครโหลด:</strong> รู้แค่จำนวน + country + source 
                — ต้องใช้ Attribution SDK (AppsFlyer/Adjust) เพื่อรู้ว่า install มาจาก ad campaign ไหน
              </p>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
