'use client';

import { useState, useEffect, useCallback } from 'react';

interface Report {
  period: string;
  computedAt: any;
  totalEntries: number;
  totalUsers: number;
  topFoods: { food: string; count: number; uniqueUsers: number; avgKcal: number; avgProtein: number; avgCarbs: number; avgFat: number; mealTypes: Record<number, number> }[];
  ingredientFreq: { ingredient: string; count: number; uniqueUsers: number }[];
  nutritionGap: { sampleDays: number; avgDailyIntake: Record<string, number>; rda: Record<string, number>; avgCalorieGoal: number; deficiencyRates: Record<string, number>; goalAchievementRate: number };
  mealTiming: { hourlyDistribution: number[]; mealTypeByHour: Record<number, number[]>; peakHours: Record<string, { peakHour: number; count: number }>; lateNightEating: number };
  demographics: { totalProfiles: number; gender: Record<string, number>; ageGroups: Record<string, number>; activityLevel: Record<string, number>; cuisinePreference: Record<string, number>; bmi: Record<string, number>; averages: { weight: number | null; height: number | null; age: number | null } };
  macroSegments: { distribution: Record<string, number>; percentages: Record<string, number>; totalUsersAnalyzed: number };
  engagement: { totalUsers: number; activeUsers: number; activationRate: number; avgEntriesPerUser: number; medianEntries: number; powerUsers: number; powerUserRate: number; sourceDistribution: Record<number, number>; dailyTrend: { date: string; count: number }[] };
  aiDataset: {
    totalEntries: number; withThumbnail: number; withIngredients: number; withBoundingBox: number; withCalibration: number; withHighConfidence: number;
    coverageRates: Record<string, number>;
    qualityTiers: { platinum: number; gold: number; silver: number; bronze: number; platinumRate: number };
    detectedLabels: { label: string; count: number }[];
    referenceObjects: Record<string, number>;
    resolutions: { resolution: string; count: number }[];
    estimatedDatasetValue: { totalImages: number; perImagePricing: Record<string, number>; estimatedTotalUSD: number; monthlyLicenseEstimate: number };
  };
}

type Tab = 'overview' | 'foods' | 'ingredients' | 'nutrition' | 'timing' | 'demographics' | 'engagement' | 'aiDataset';

const TABS: { key: Tab; label: string }[] = [
  { key: 'overview', label: '🎯 Overview' },
  { key: 'foods', label: '🏆 Hero Products' },
  { key: 'ingredients', label: '🥬 Ingredients' },
  { key: 'nutrition', label: '💊 Nutrition Gaps' },
  { key: 'timing', label: '⏰ Meal Timing' },
  { key: 'demographics', label: '👥 Demographics' },
  { key: 'engagement', label: '📈 Engagement' },
  { key: 'aiDataset', label: '🤖 AI Dataset' },
];

const MEAL_NAMES = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
const SOURCE_NAMES: Record<number, string> = { 0: 'AI Photo', 1: 'Text', 2: 'Chat', 3: 'Manual', 4: 'My Meal', 5: 'Barcode' };

export default function DataMiningPage() {
  const [report, setReport] = useState<Report | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [tab, setTab] = useState<Tab>('overview');
  const [triggering, setTriggering] = useState(false);

  const fetchReport = useCallback(async () => {
    setLoading(true); setError('');
    try {
      const res = await fetch('/api/data-mining?period=latest');
      const data = await res.json();
      if (data.success) setReport(data.report);
      else setError(data.error || 'No reports yet');
    } catch (e: any) { setError(e.message); }
    setLoading(false);
  }, []);

  const triggerCompute = async (days: number) => {
    setTriggering(true);
    try {
      const res = await fetch('/api/data-mining', {
        method: 'POST', headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'trigger', days }),
      });
      const data = await res.json();
      if (data.success) await fetchReport();
      else setError(data.error || 'Failed');
    } catch (e: any) { setError(e.message); }
    setTriggering(false);
  };

  const handleExport = async (tier: string, confidence: number) => {
    try {
      const res = await fetch('/api/data-mining', {
        method: 'POST', headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'export', tier, minConfidence: confidence, days: 90, limit: 10000 }),
      });
      const result = await res.json();
      if (result.success) {
        const blob = new Blob([JSON.stringify(result, null, 2)], { type: 'application/json' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url; a.download = `miro-dataset-${tier}-${new Date().toISOString().split('T')[0]}.json`;
        a.click(); URL.revokeObjectURL(url);
      }
    } catch (e: any) { setError(e.message); }
  };

  useEffect(() => { fetchReport(); }, [fetchReport]);

  return (
    <div>
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Data Mining</h1>
          {report && <p className="text-sm text-gray-500 mt-1">Period: {report.period} · {report.totalEntries.toLocaleString()} entries · {report.totalUsers} users</p>}
        </div>
        <div className="flex gap-2">
          <button onClick={() => triggerCompute(7)} disabled={triggering} className="px-4 py-2 rounded-lg bg-blue-600 hover:bg-blue-700 text-white text-sm font-medium disabled:opacity-50">{triggering ? 'Computing...' : 'Compute 7 Days'}</button>
          <button onClick={() => triggerCompute(30)} disabled={triggering} className="px-4 py-2 rounded-lg bg-gray-200 hover:bg-gray-300 text-gray-800 text-sm font-medium disabled:opacity-50">30 Days</button>
        </div>
      </div>

      {error && <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg mb-6">{error}</div>}
      {loading && <p className="text-gray-500 text-center py-20">Loading...</p>}

      {!loading && !report && !error && (
        <div className="text-center py-20">
          <p className="text-gray-500 mb-2">No reports computed yet.</p>
          <p className="text-sm text-gray-400">Click &quot;Compute 7 Days&quot; to generate.</p>
        </div>
      )}

      {report && (
        <>
          {/* Tabs */}
          <div className="flex gap-1 mb-6 overflow-x-auto border-b border-gray-200 pb-2">
            {TABS.map(t => (
              <button key={t.key} onClick={() => setTab(t.key)}
                className={`px-4 py-2 rounded-t-lg text-sm font-medium whitespace-nowrap ${tab === t.key ? 'bg-blue-50 text-blue-700 border-b-2 border-blue-600' : 'text-gray-500 hover:text-gray-900 hover:bg-gray-50'}`}>
                {t.label}
              </button>
            ))}
          </div>

          {tab === 'overview' && <OverviewTab r={report} />}
          {tab === 'foods' && <FoodsTab data={report.topFoods} />}
          {tab === 'ingredients' && <IngredientsTab data={report.ingredientFreq} />}
          {tab === 'nutrition' && <NutritionTab data={report.nutritionGap} />}
          {tab === 'timing' && <TimingTab data={report.mealTiming} />}
          {tab === 'demographics' && <DemographicsTab data={report.demographics} macros={report.macroSegments} />}
          {tab === 'engagement' && <EngagementTab data={report.engagement} />}
          {tab === 'aiDataset' && <AiDatasetTab data={report.aiDataset} onExport={handleExport} />}
        </>
      )}
    </div>
  );
}

// ═══════════════════════════════════════════════════════
// Shared UI Components
// ═══════════════════════════════════════════════════════

function Card({ children, className = '' }: { children: React.ReactNode; className?: string }) {
  return <div className={`bg-white rounded-xl border border-gray-200 p-5 shadow-sm ${className}`}>{children}</div>;
}

function Stat({ label, value, sub, color = 'blue' }: { label: string; value: string | number; sub?: string; color?: string }) {
  const cls = { blue: 'text-blue-600', green: 'text-green-600', purple: 'text-purple-600', amber: 'text-amber-600', red: 'text-red-600' }[color] || 'text-gray-900';
  return (
    <Card>
      <p className="text-xs text-gray-500 uppercase tracking-wide">{label}</p>
      <p className={`text-2xl font-bold mt-1 ${cls}`}>{value}</p>
      {sub && <p className="text-xs text-gray-400 mt-1">{sub}</p>}
    </Card>
  );
}

function SectionTitle({ children }: { children: React.ReactNode }) {
  return <h3 className="text-base font-semibold text-gray-900 mb-3 mt-6 first:mt-0">{children}</h3>;
}

function Bar({ pct, color = 'bg-blue-500' }: { pct: number; color?: string }) {
  return <div className="w-full bg-gray-100 rounded-full h-2"><div className={`${color} h-2 rounded-full`} style={{ width: `${Math.min(pct, 100)}%` }} /></div>;
}

// ═══════════════════════════════════════════════════════
// Tab Components
// ═══════════════════════════════════════════════════════

function OverviewTab({ r }: { r: Report }) {
  const { nutritionGap: ng, engagement: eng, aiDataset: ai } = r;
  return (
    <div>
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <Stat label="Total Entries" value={r.totalEntries.toLocaleString()} />
        <Stat label="Active Users" value={eng.activeUsers} sub={`${eng.activationRate}% activation`} color="green" />
        <Stat label="Avg Daily Calories" value={ng.avgDailyIntake.calories} sub={`Goal: ${ng.avgCalorieGoal}`} color="purple" />
        <Stat label="Dataset Value" value={`$${ai.estimatedDatasetValue.estimatedTotalUSD}`} sub={`${ai.withThumbnail} images`} color="amber" />
      </div>
      <SectionTitle>Top 5 Foods</SectionTitle>
      <Card>{r.topFoods.slice(0, 5).map((f, i) => (
        <div key={f.food} className="flex items-center justify-between py-2 border-b border-gray-100 last:border-0">
          <span className="text-sm"><span className="text-gray-400 mr-2">{i + 1}.</span><span className="capitalize font-medium">{f.food}</span></span>
          <span className="text-sm text-gray-500">{f.count}x · {f.avgKcal} kcal</span>
        </div>
      ))}</Card>
      <SectionTitle>Nutrition Deficiency Alerts</SectionTitle>
      <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
        {Object.entries(ng.deficiencyRates).map(([k, v]) => (
          <Stat key={k} label={k.replace(/([A-Z])/g, ' $1')} value={`${v}%`} sub={k.startsWith('excess') ? '> RDA' : '< 80% RDA'} color={Number(v) > 50 ? 'red' : Number(v) > 30 ? 'amber' : 'green'} />
        ))}
      </div>
    </div>
  );
}

function FoodsTab({ data }: { data: Report['topFoods'] }) {
  return (
    <Card>
      <SectionTitle>Top 50 Foods — Hero Products</SectionTitle>
      <p className="text-sm text-gray-500 mb-4">FMCG companies and restaurants pay $5K-50K/month for this data.</p>
      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead><tr className="text-left text-gray-500 border-b"><th className="py-2 px-2">#</th><th className="py-2 px-2">Food</th><th className="py-2 px-2 text-right">Count</th><th className="py-2 px-2 text-right">Users</th><th className="py-2 px-2 text-right">kcal</th><th className="py-2 px-2 text-right">P/C/F</th><th className="py-2 px-2">Meal</th></tr></thead>
          <tbody>{data.map((f, i) => {
            const tm = Object.entries(f.mealTypes).sort((a, b) => b[1] - a[1])[0];
            return (
              <tr key={f.food} className="border-b border-gray-50 hover:bg-gray-50">
                <td className="py-2 px-2 text-gray-400">{i + 1}</td>
                <td className="py-2 px-2 font-medium capitalize">{f.food}</td>
                <td className="py-2 px-2 text-right text-blue-600 font-medium">{f.count}</td>
                <td className="py-2 px-2 text-right">{f.uniqueUsers}</td>
                <td className="py-2 px-2 text-right">{f.avgKcal}</td>
                <td className="py-2 px-2 text-right text-gray-500">{f.avgProtein}/{f.avgCarbs}/{f.avgFat}g</td>
                <td className="py-2 px-2 text-gray-500">{tm ? MEAL_NAMES[parseInt(tm[0])] || '-' : '-'}</td>
              </tr>);
          })}</tbody>
        </table>
      </div>
    </Card>
  );
}

function IngredientsTab({ data }: { data: Report['ingredientFreq'] }) {
  const mx = data[0]?.count || 1;
  return (
    <Card>
      <SectionTitle>Top 100 Ingredients</SectionTitle>
      <div className="grid md:grid-cols-2 gap-x-8 gap-y-2">
        {data.map((ing, i) => (
          <div key={ing.ingredient} className="flex items-center gap-3 py-1">
            <span className="text-xs text-gray-400 w-5 text-right">{i + 1}</span>
            <div className="flex-1">
              <div className="flex justify-between text-sm mb-0.5"><span className="capitalize">{ing.ingredient}</span><span className="text-gray-400">{ing.count}x</span></div>
              <Bar pct={(ing.count / mx) * 100} color="bg-green-500" />
            </div>
          </div>
        ))}
      </div>
    </Card>
  );
}

function NutritionTab({ data }: { data: Report['nutritionGap'] }) {
  const nutrients = [
    { key: 'calories', label: 'Calories', unit: 'kcal' }, { key: 'protein', label: 'Protein', unit: 'g' },
    { key: 'carbs', label: 'Carbs', unit: 'g' }, { key: 'fat', label: 'Fat', unit: 'g' },
    { key: 'fiber', label: 'Fiber', unit: 'g' }, { key: 'sodium', label: 'Sodium', unit: 'mg' },
    { key: 'sugar', label: 'Sugar', unit: 'g' }, { key: 'cholesterol', label: 'Cholesterol', unit: 'mg' },
  ];
  return (
    <div>
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
        <Stat label="Sample Days" value={data.sampleDays} />
        <Stat label="Goal Achievement" value={`${data.goalAchievementRate}%`} color="green" />
        <Stat label="Avg Goal" value={data.avgCalorieGoal} color="blue" />
        <Stat label="Actual Avg" value={`${data.avgDailyIntake.calories} kcal`} color="purple" />
      </div>
      <Card>
        <SectionTitle>Avg Daily Intake vs RDA</SectionTitle>
        <div className="space-y-4">
          {nutrients.map(n => {
            const avg = data.avgDailyIntake[n.key] || 0;
            const rda = data.rda[n.key] || 1;
            const pct = (avg / rda) * 100;
            const color = pct > 100 ? 'bg-amber-500' : pct < 80 ? 'bg-red-500' : 'bg-green-500';
            return (
              <div key={n.key}>
                <div className="flex justify-between text-sm mb-1"><span>{n.label}</span><span className="text-gray-500">{avg} / {rda} {n.unit} ({pct.toFixed(0)}%)</span></div>
                <Bar pct={pct} color={color} />
              </div>);
          })}
        </div>
      </Card>
    </div>
  );
}

function TimingTab({ data }: { data: Report['mealTiming'] }) {
  const mx = Math.max(...data.hourlyDistribution);
  return (
    <div>
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
        {Object.entries(data.peakHours).map(([meal, info]) => (
          <Stat key={meal} label={`Peak ${meal}`} value={`${info.peakHour}:00`} sub={`${info.count} entries`} color={meal === 'breakfast' ? 'amber' : meal === 'lunch' ? 'green' : meal === 'dinner' ? 'purple' : 'blue'} />
        ))}
      </div>
      <Card>
        <SectionTitle>Hourly Distribution</SectionTitle>
        <div className="flex items-end gap-1 h-40">
          {data.hourlyDistribution.map((c, h) => (
            <div key={h} className="flex-1 flex flex-col items-center gap-1">
              <div className="w-full bg-blue-500 rounded-t hover:bg-blue-600 transition" style={{ height: `${(c / (mx || 1)) * 100}%`, minHeight: c > 0 ? '2px' : '0' }} title={`${h}:00 — ${c}`} />
              <span className="text-[10px] text-gray-400">{h}</span>
            </div>
          ))}
        </div>
      </Card>
      <Stat label="Late-Night Eating (22:00–05:00)" value={`${data.lateNightEating}%`} sub="of all entries" color="amber" />
    </div>
  );
}

function DemographicsTab({ data, macros }: { data: Report['demographics']; macros: Report['macroSegments'] }) {
  return (
    <div>
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
        <Stat label="Profiles" value={data.totalProfiles} color="blue" />
        <Stat label="Avg Age" value={data.averages.age ?? '-'} color="purple" />
        <Stat label="Avg Weight" value={data.averages.weight ? `${data.averages.weight} kg` : '-'} color="green" />
        <Stat label="Avg Height" value={data.averages.height ? `${data.averages.height} cm` : '-'} />
      </div>
      <div className="grid md:grid-cols-2 gap-4">
        {[
          { title: 'Gender', data: data.gender }, { title: 'Age Groups', data: data.ageGroups },
          { title: 'Activity Level', data: data.activityLevel }, { title: 'BMI', data: data.bmi },
          { title: 'Cuisine', data: data.cuisinePreference }, { title: 'Diet Type', data: macros.distribution },
        ].map(({ title, data: d }) => {
          const total = Object.values(d).reduce((s, v) => s + v, 0) || 1;
          const maxV = Math.max(...Object.values(d));
          return (
            <Card key={title}>
              <h4 className="text-sm font-semibold mb-3">{title}</h4>
              {Object.entries(d).filter(([, v]) => v > 0).sort((a, b) => b[1] - a[1]).map(([label, value]) => (
                <div key={label} className="mb-2">
                  <div className="flex justify-between text-xs mb-0.5"><span className="capitalize">{label.replace(/_/g, ' ')}</span><span className="text-gray-400">{value} ({((value / total) * 100).toFixed(1)}%)</span></div>
                  <Bar pct={(value / maxV) * 100} />
                </div>
              ))}
            </Card>);
        })}
      </div>
    </div>
  );
}

function EngagementTab({ data }: { data: Report['engagement'] }) {
  const mx = Math.max(...data.dailyTrend.map(d => d.count));
  return (
    <div>
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
        <Stat label="Sync Users" value={data.totalUsers} />
        <Stat label="Active" value={data.activeUsers} sub={`${data.activationRate}%`} color="green" />
        <Stat label="Avg Entries/User" value={data.avgEntriesPerUser} sub={`Median: ${data.medianEntries}`} color="blue" />
        <Stat label="Power Users" value={data.powerUsers} sub={`${data.powerUserRate}% (>20/wk)`} color="purple" />
      </div>
      <Card>
        <SectionTitle>Data Source</SectionTitle>
        <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
          {Object.entries(data.sourceDistribution).map(([src, count]) => (
            <div key={src} className="text-sm"><span className="text-gray-500">{SOURCE_NAMES[parseInt(src)] || src}:</span> <span className="font-medium">{count}</span></div>
          ))}
        </div>
      </Card>
      {data.dailyTrend.length > 0 && (
        <Card className="mt-4">
          <SectionTitle>Daily Trend</SectionTitle>
          <div className="flex items-end gap-px h-32">
            {data.dailyTrend.map(d => (
              <div key={d.date} className="flex-1"><div className="w-full bg-blue-500 rounded-t hover:bg-blue-600" style={{ height: `${(d.count / (mx || 1)) * 100}%`, minHeight: d.count > 0 ? '2px' : '0' }} title={`${d.date}: ${d.count}`} /></div>
            ))}
          </div>
          <div className="flex justify-between text-xs text-gray-400 mt-1"><span>{data.dailyTrend[0]?.date}</span><span>{data.dailyTrend[data.dailyTrend.length - 1]?.date}</span></div>
        </Card>
      )}
    </div>
  );
}

const TIER_COLORS: Record<string, string> = { platinum: 'bg-purple-500', gold: 'bg-amber-500', silver: 'bg-gray-400', bronze: 'bg-orange-500' };
const TIER_DESC: Record<string, string> = { platinum: 'Image + BBox + Calibration + Ingredients', gold: 'Image + Labels + Ingredients', silver: 'Image + Labels or Ingredients', bronze: 'Image + Nutrition only' };

function AiDatasetTab({ data, onExport }: { data: Report['aiDataset']; onExport: (tier: string, conf: number) => void }) {
  const val = data.estimatedDatasetValue;
  return (
    <div>
      {/* Value */}
      <Card className="bg-gradient-to-r from-blue-50 to-purple-50 border-blue-200 mb-6">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-xs text-gray-500 uppercase">Estimated Dataset Value</p>
            <p className="text-3xl font-bold text-blue-700 mt-1">${val.estimatedTotalUSD.toLocaleString()}</p>
            <p className="text-sm text-gray-500 mt-1">{val.totalImages.toLocaleString()} images · License: ${val.monthlyLicenseEstimate}/mo</p>
          </div>
          <div className="text-right text-xs text-gray-500 space-y-0.5">
            <p>Platinum: ${val.perImagePricing.platinum}/img</p><p>Gold: ${val.perImagePricing.gold}/img</p>
            <p>Silver: ${val.perImagePricing.silver}/img</p><p>Bronze: ${val.perImagePricing.bronze}/img</p>
          </div>
        </div>
      </Card>

      {/* Coverage */}
      <div className="grid grid-cols-2 md:grid-cols-3 gap-4 mb-6">
        <Stat label="With Thumbnail" value={data.withThumbnail} sub={`${data.coverageRates.thumbnail}%`} color="green" />
        <Stat label="With Ingredients" value={data.withIngredients} sub={`${data.coverageRates.ingredients}%`} color="blue" />
        <Stat label="With Bounding Box" value={data.withBoundingBox} sub={`${data.coverageRates.boundingBox}%`} color="purple" />
        <Stat label="With Calibration" value={data.withCalibration} sub={`${data.coverageRates.calibration}%`} color="amber" />
        <Stat label="High Confidence" value={data.withHighConfidence} sub={`${data.coverageRates.highConfidence}%`} />
        <Stat label="Total" value={data.totalEntries} />
      </div>

      {/* Quality Tiers */}
      <SectionTitle>Quality Tiers</SectionTitle>
      <div className="grid md:grid-cols-2 gap-4 mb-6">
        {(['platinum', 'gold', 'silver', 'bronze'] as const).map(tier => {
          const count = data.qualityTiers[tier];
          const pct = ((count / (data.withThumbnail || 1)) * 100).toFixed(1);
          return (
            <Card key={tier}>
              <div className="flex items-center justify-between mb-2">
                <div className="flex items-center gap-2"><div className={`w-3 h-3 rounded-full ${TIER_COLORS[tier]}`} /><span className="font-semibold capitalize">{tier}</span></div>
                <span className="text-xl font-bold">{count.toLocaleString()}</span>
              </div>
              <p className="text-xs text-gray-500 mb-2">{TIER_DESC[tier]}</p>
              <Bar pct={parseFloat(pct)} color={TIER_COLORS[tier]} />
              <div className="flex items-center justify-between mt-2">
                <span className="text-xs text-gray-400">{pct}%</span>
                <button onClick={() => onExport(tier, 0)} disabled={count === 0} className="text-xs px-3 py-1 rounded bg-gray-100 hover:bg-gray-200 disabled:opacity-50">Export</button>
              </div>
            </Card>);
        })}
      </div>

      {/* Labels & Refs */}
      <div className="grid md:grid-cols-2 gap-4 mb-6">
        {data.detectedLabels.length > 0 && (
          <Card>
            <h4 className="text-sm font-semibold mb-3">Detected Labels (AR)</h4>
            {data.detectedLabels.slice(0, 20).map((lb, i) => (
              <div key={lb.label} className="flex justify-between text-sm py-1 border-b border-gray-50"><span><span className="text-gray-400 mr-1">{i + 1}.</span> <span className="capitalize">{lb.label}</span></span><span className="text-gray-400">{lb.count}</span></div>
            ))}
          </Card>
        )}
        {Object.keys(data.referenceObjects).length > 0 && (
          <Card>
            <h4 className="text-sm font-semibold mb-3">Reference Objects</h4>
            {Object.entries(data.referenceObjects).sort((a, b) => b[1] - a[1]).map(([obj, count]) => (
              <div key={obj} className="flex justify-between text-sm py-1 border-b border-gray-50"><span className="capitalize">{obj.replace(/([A-Z])/g, ' $1')}</span><span className="text-gray-400">{count}</span></div>
            ))}
          </Card>
        )}
      </div>

      {/* Export */}
      <SectionTitle>Export Dataset</SectionTitle>
      <div className="grid md:grid-cols-3 gap-4">
        <button onClick={() => onExport('platinum', 0.8)} className="p-4 rounded-xl border border-purple-200 bg-purple-50 hover:bg-purple-100 text-left">
          <p className="font-semibold text-purple-900">Premium</p><p className="text-xs text-gray-500 mt-1">Platinum, confidence ≥ 80%</p>
        </button>
        <button onClick={() => onExport('gold', 0.5)} className="p-4 rounded-xl border border-amber-200 bg-amber-50 hover:bg-amber-100 text-left">
          <p className="font-semibold text-amber-900">Standard</p><p className="text-xs text-gray-500 mt-1">Gold+, confidence ≥ 50%</p>
        </button>
        <button onClick={() => onExport('bronze', 0)} className="p-4 rounded-xl border border-gray-200 bg-gray-50 hover:bg-gray-100 text-left">
          <p className="font-semibold text-gray-900">Full</p><p className="text-xs text-gray-500 mt-1">All images, no filter</p>
        </button>
      </div>
    </div>
  );
}
