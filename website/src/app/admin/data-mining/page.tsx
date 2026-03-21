'use client';

import { useState, useEffect, useCallback } from 'react';
import { useAdminSecret } from '../admin-context';

const API_BASE = process.env.NEXT_PUBLIC_FUNCTIONS_URL || 'https://us-central1-miro-d6856.cloudfunctions.net';

interface Report {
  period: string;
  computedAt: any;
  totalEntries: number;
  totalUsers: number;
  topFoods: TopFood[];
  ingredientFreq: Ingredient[];
  nutritionGap: NutritionGap;
  mealTiming: MealTiming;
  demographics: Demographics;
  macroSegments: MacroSegments;
  engagement: Engagement;
  aiDataset: AiDataset;
}

interface TopFood {
  food: string;
  count: number;
  uniqueUsers: number;
  avgKcal: number;
  avgProtein: number;
  avgCarbs: number;
  avgFat: number;
  mealTypes: Record<number, number>;
}

interface Ingredient {
  ingredient: string;
  count: number;
  uniqueUsers: number;
}

interface NutritionGap {
  sampleDays: number;
  avgDailyIntake: Record<string, number>;
  rda: Record<string, number>;
  avgCalorieGoal: number;
  deficiencyRates: Record<string, number>;
  goalAchievementRate: number;
}

interface MealTiming {
  hourlyDistribution: number[];
  mealTypeByHour: Record<number, number[]>;
  peakHours: Record<string, { peakHour: number; count: number }>;
  lateNightEating: number;
}

interface Demographics {
  totalProfiles: number;
  gender: Record<string, number>;
  ageGroups: Record<string, number>;
  activityLevel: Record<string, number>;
  cuisinePreference: Record<string, number>;
  bmi: Record<string, number>;
  averages: { weight: number | null; height: number | null; age: number | null };
}

interface MacroSegments {
  distribution: Record<string, number>;
  percentages: Record<string, number>;
  totalUsersAnalyzed: number;
}

interface Engagement {
  totalUsers: number;
  activeUsers: number;
  activationRate: number;
  avgEntriesPerUser: number;
  medianEntries: number;
  powerUsers: number;
  powerUserRate: number;
  sourceDistribution: Record<number, number>;
  dailyTrend: { date: string; count: number }[];
}

interface AiDataset {
  totalEntries: number;
  withThumbnail: number;
  withIngredients: number;
  withBoundingBox: number;
  withCalibration: number;
  withHighConfidence: number;
  coverageRates: Record<string, number>;
  qualityTiers: {
    platinum: number;
    gold: number;
    silver: number;
    bronze: number;
    platinumRate: number;
  };
  detectedLabels: { label: string; count: number }[];
  referenceObjects: Record<string, number>;
  resolutions: { resolution: string; count: number }[];
  estimatedDatasetValue: {
    totalImages: number;
    perImagePricing: Record<string, number>;
    estimatedTotalUSD: number;
    monthlyLicenseEstimate: number;
  };
}

type TabKey = 'overview' | 'foods' | 'ingredients' | 'nutrition' | 'timing' | 'demographics' | 'engagement' | 'aiDataset';

const TABS: { key: TabKey; label: string; icon: string }[] = [
  { key: 'overview', label: 'Overview', icon: '🎯' },
  { key: 'foods', label: 'Hero Products', icon: '🏆' },
  { key: 'ingredients', label: 'Ingredients', icon: '🥬' },
  { key: 'nutrition', label: 'Nutrition Gaps', icon: '💊' },
  { key: 'timing', label: 'Meal Timing', icon: '⏰' },
  { key: 'demographics', label: 'Demographics', icon: '👥' },
  { key: 'engagement', label: 'Engagement', icon: '📈' },
  { key: 'aiDataset', label: 'AI Dataset', icon: '🤖' },
];

const MEAL_NAMES = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
const SOURCE_NAMES: Record<number, string> = { 0: 'AI Photo', 1: 'Text', 2: 'Chat', 3: 'Manual', 4: 'My Meal', 5: 'Barcode' };

export default function DataMiningPage() {
  const secret = useAdminSecret();
  const [report, setReport] = useState<Report | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [activeTab, setActiveTab] = useState<TabKey>('overview');
  const [triggering, setTriggering] = useState(false);

  const fetchReport = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const res = await fetch(`${API_BASE}/getDataMiningReport?period=latest`, {
        headers: { Authorization: `Bearer ${secret}` },
      });
      const data = await res.json();
      if (data.success) setReport(data.report);
      else setError(data.error || 'Failed to load report');
    } catch (e: any) {
      setError(e.message);
    }
    setLoading(false);
  }, [secret]);

  const triggerCompute = async (days: number) => {
    setTriggering(true);
    try {
      const res = await fetch(`${API_BASE}/triggerDataMining`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${secret}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ days }),
      });
      const data = await res.json();
      if (data.success) {
        await fetchReport();
      } else {
        setError(data.error);
      }
    } catch (e: any) {
      setError(e.message);
    }
    setTriggering(false);
  };

  useEffect(() => {
    if (secret) fetchReport();
  }, [secret, fetchReport]);

  return (
    <div className="p-6 max-w-7xl mx-auto">
      {/* Header */}
      <div className="flex items-center justify-between mb-8">
        <div>
          <h2 className="text-2xl font-bold">Data Mining Reports</h2>
          {report && (
            <p className="text-sm text-gray-500 mt-1">
              Period: {report.period} · {report.totalEntries.toLocaleString()} entries · {report.totalUsers.toLocaleString()} users
            </p>
          )}
        </div>
        <div className="flex gap-2">
          <button
            onClick={() => triggerCompute(7)}
            disabled={triggering}
            className="px-4 py-2 rounded-lg bg-emerald-600 hover:bg-emerald-500 text-sm font-medium disabled:opacity-50 transition"
          >
            {triggering ? 'Computing...' : 'Compute 7 Days'}
          </button>
          <button
            onClick={() => triggerCompute(30)}
            disabled={triggering}
            className="px-4 py-2 rounded-lg bg-gray-700 hover:bg-gray-600 text-sm font-medium disabled:opacity-50 transition"
          >
            Compute 30 Days
          </button>
        </div>
      </div>

      {error && (
        <div className="bg-red-500/10 border border-red-500/30 text-red-400 px-4 py-3 rounded-lg mb-6">
          {error}
        </div>
      )}

      {loading && <div className="text-gray-500 text-center py-20">Loading report...</div>}

      {!loading && !report && !error && (
        <div className="text-center py-20">
          <p className="text-gray-400 mb-4">No reports computed yet.</p>
          <p className="text-sm text-gray-600">Click &quot;Compute 7 Days&quot; to generate your first report.</p>
        </div>
      )}

      {report && (
        <>
          {/* Tabs */}
          <div className="flex gap-1 mb-8 overflow-x-auto pb-2">
            {TABS.map((tab) => (
              <button
                key={tab.key}
                onClick={() => setActiveTab(tab.key)}
                className={`px-4 py-2 rounded-lg text-sm font-medium whitespace-nowrap transition ${
                  activeTab === tab.key
                    ? 'bg-emerald-600/20 text-emerald-400 ring-1 ring-emerald-600/30'
                    : 'text-gray-400 hover:text-white hover:bg-gray-800'
                }`}
              >
                {tab.icon} {tab.label}
              </button>
            ))}
          </div>

          {activeTab === 'overview' && <OverviewTab report={report} />}
          {activeTab === 'foods' && <FoodsTab data={report.topFoods} />}
          {activeTab === 'ingredients' && <IngredientsTab data={report.ingredientFreq} />}
          {activeTab === 'nutrition' && <NutritionTab data={report.nutritionGap} />}
          {activeTab === 'timing' && <TimingTab data={report.mealTiming} />}
          {activeTab === 'demographics' && <DemographicsTab data={report.demographics} macros={report.macroSegments} />}
          {activeTab === 'engagement' && <EngagementTab data={report.engagement} />}
          {activeTab === 'aiDataset' && <AiDatasetTab data={report.aiDataset} secret={secret} />}
        </>
      )}
    </div>
  );
}

// ═══════════════════════════════════════════════════════
// STAT CARD
// ═══════════════════════════════════════════════════════

function StatCard({ label, value, sub, color = 'emerald' }: { label: string; value: string | number; sub?: string; color?: string }) {
  const colorClass = {
    emerald: 'border-emerald-600/30 bg-emerald-600/5',
    blue: 'border-blue-600/30 bg-blue-600/5',
    purple: 'border-purple-600/30 bg-purple-600/5',
    amber: 'border-amber-600/30 bg-amber-600/5',
    red: 'border-red-600/30 bg-red-600/5',
    cyan: 'border-cyan-600/30 bg-cyan-600/5',
  }[color] || 'border-gray-700 bg-gray-800';

  return (
    <div className={`border rounded-xl p-4 ${colorClass}`}>
      <p className="text-xs text-gray-500 uppercase tracking-wide">{label}</p>
      <p className="text-2xl font-bold mt-1">{value}</p>
      {sub && <p className="text-xs text-gray-500 mt-1">{sub}</p>}
    </div>
  );
}

function SectionTitle({ children }: { children: React.ReactNode }) {
  return <h3 className="text-lg font-semibold mb-4 mt-8 first:mt-0">{children}</h3>;
}

// ═══════════════════════════════════════════════════════
// OVERVIEW TAB
// ═══════════════════════════════════════════════════════

function OverviewTab({ report }: { report: Report }) {
  const { nutritionGap: ng, engagement: eng, macroSegments: ms, mealTiming: mt, demographics: dem } = report;

  return (
    <div>
      <SectionTitle>Key Metrics</SectionTitle>
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <StatCard label="Total Entries" value={report.totalEntries.toLocaleString()} />
        <StatCard label="Active Users" value={eng.activeUsers} sub={`${eng.activationRate}% activation`} color="blue" />
        <StatCard label="Avg Daily Calories" value={ng.avgDailyIntake.calories} sub={`Goal: ${ng.avgCalorieGoal}`} color="purple" />
        <StatCard label="Goal Achievement" value={`${ng.goalAchievementRate}%`} sub="within ±10% of goal" color="amber" />
      </div>

      <SectionTitle>Sellable Insights Preview</SectionTitle>
      <div className="grid md:grid-cols-2 gap-4">
        <InsightCard
          icon="🏆"
          title="Hero Product"
          value={report.topFoods[0]?.food || 'N/A'}
          detail={`Logged ${report.topFoods[0]?.count || 0} times by ${report.topFoods[0]?.uniqueUsers || 0} users`}
          tag="FMCG / Restaurants"
          tagColor="emerald"
        />
        <InsightCard
          icon="💊"
          title="Biggest Nutrition Gap"
          value={`${ng.deficiencyRates.fiber}% fiber deficient`}
          detail="Users consuming < 80% of RDA"
          tag="Supplement Companies"
          tagColor="purple"
        />
        <InsightCard
          icon="🌙"
          title="Late-Night Eating"
          value={`${mt.lateNightEating}% of meals`}
          detail="Eaten between 10 PM - 5 AM"
          tag="Health Brands"
          tagColor="amber"
        />
        <InsightCard
          icon="🥗"
          title="Top Diet Type"
          value={Object.entries(ms.percentages).sort((a, b) => b[1] - a[1])[0]?.[0]?.replace('_', ' ') || 'N/A'}
          detail={`${Object.entries(ms.percentages).sort((a, b) => b[1] - a[1])[0]?.[1] || 0}% of users`}
          tag="Meal Kit Companies"
          tagColor="blue"
        />
      </div>

      <SectionTitle>Demographics Snapshot</SectionTitle>
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <StatCard label="Profiles Synced" value={dem.totalProfiles} color="cyan" />
        <StatCard label="Avg Age" value={dem.averages.age ?? 'N/A'} color="blue" />
        <StatCard label="Avg Weight" value={dem.averages.weight ? `${dem.averages.weight} kg` : 'N/A'} color="purple" />
        <StatCard label="Power Users" value={eng.powerUsers} sub={`${eng.powerUserRate}% of active`} color="amber" />
      </div>
    </div>
  );
}

function InsightCard({ icon, title, value, detail, tag, tagColor }: {
  icon: string; title: string; value: string; detail: string; tag: string; tagColor: string;
}) {
  const tagClass = {
    emerald: 'bg-emerald-600/20 text-emerald-400',
    purple: 'bg-purple-600/20 text-purple-400',
    amber: 'bg-amber-600/20 text-amber-400',
    blue: 'bg-blue-600/20 text-blue-400',
  }[tagColor] || 'bg-gray-700 text-gray-400';

  return (
    <div className="border border-gray-800 rounded-xl p-5 bg-gray-900/50">
      <div className="flex items-center justify-between mb-3">
        <span className="text-2xl">{icon}</span>
        <span className={`text-xs px-2 py-1 rounded-full font-medium ${tagClass}`}>{tag}</span>
      </div>
      <p className="text-xs text-gray-500 uppercase">{title}</p>
      <p className="text-xl font-bold mt-1 capitalize">{value}</p>
      <p className="text-sm text-gray-400 mt-1">{detail}</p>
    </div>
  );
}

// ═══════════════════════════════════════════════════════
// FOODS TAB (Hero Products)
// ═══════════════════════════════════════════════════════

function FoodsTab({ data }: { data: TopFood[] }) {
  return (
    <div>
      <SectionTitle>Top 50 Foods — &quot;Hero Products&quot;</SectionTitle>
      <p className="text-sm text-gray-500 mb-4">
        FMCG companies, restaurants, and food delivery services pay $5K-50K/month for this kind of data.
        It reveals what real consumers actually eat, not what they say they eat.
      </p>
      <div className="overflow-x-auto">
        <table className="w-full text-sm">
          <thead>
            <tr className="text-left text-gray-500 border-b border-gray-800">
              <th className="py-3 px-3">#</th>
              <th className="py-3 px-3">Food</th>
              <th className="py-3 px-3 text-right">Count</th>
              <th className="py-3 px-3 text-right">Users</th>
              <th className="py-3 px-3 text-right">Avg kcal</th>
              <th className="py-3 px-3 text-right">P/C/F</th>
              <th className="py-3 px-3">Top Meal</th>
            </tr>
          </thead>
          <tbody>
            {data.map((f, i) => {
              const topMeal = Object.entries(f.mealTypes).sort((a, b) => b[1] - a[1])[0];
              return (
                <tr key={f.food} className="border-b border-gray-800/50 hover:bg-gray-800/30">
                  <td className="py-3 px-3 text-gray-500">{i + 1}</td>
                  <td className="py-3 px-3 font-medium capitalize">{f.food}</td>
                  <td className="py-3 px-3 text-right text-emerald-400">{f.count}</td>
                  <td className="py-3 px-3 text-right">{f.uniqueUsers}</td>
                  <td className="py-3 px-3 text-right">{f.avgKcal}</td>
                  <td className="py-3 px-3 text-right text-gray-400">
                    {f.avgProtein}/{f.avgCarbs}/{f.avgFat}g
                  </td>
                  <td className="py-3 px-3 text-gray-400">
                    {topMeal ? MEAL_NAMES[parseInt(topMeal[0])] || 'Other' : '-'}
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════
// INGREDIENTS TAB
// ═══════════════════════════════════════════════════════

function IngredientsTab({ data }: { data: Ingredient[] }) {
  const maxCount = data[0]?.count || 1;

  return (
    <div>
      <SectionTitle>Ingredient Frequency — Top 100</SectionTitle>
      <p className="text-sm text-gray-500 mb-4">
        Raw ingredient suppliers and recipe platforms value this data.
        Shows what individual ingredients appear most in real meals.
      </p>
      <div className="grid md:grid-cols-2 gap-x-8 gap-y-1">
        {data.map((ing, i) => (
          <div key={ing.ingredient} className="flex items-center gap-3 py-2">
            <span className="text-xs text-gray-600 w-6 text-right">{i + 1}</span>
            <div className="flex-1">
              <div className="flex items-center justify-between mb-1">
                <span className="text-sm capitalize">{ing.ingredient}</span>
                <span className="text-xs text-gray-500">{ing.count}x · {ing.uniqueUsers} users</span>
              </div>
              <div className="w-full bg-gray-800 rounded-full h-1.5">
                <div
                  className="bg-emerald-500 h-1.5 rounded-full"
                  style={{ width: `${(ing.count / maxCount) * 100}%` }}
                />
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════
// NUTRITION GAP TAB
// ═══════════════════════════════════════════════════════

function NutritionTab({ data }: { data: NutritionGap }) {
  const nutrients = [
    { key: 'calories', label: 'Calories', unit: 'kcal' },
    { key: 'protein', label: 'Protein', unit: 'g' },
    { key: 'carbs', label: 'Carbs', unit: 'g' },
    { key: 'fat', label: 'Fat', unit: 'g' },
    { key: 'fiber', label: 'Fiber', unit: 'g' },
    { key: 'sodium', label: 'Sodium', unit: 'mg' },
    { key: 'sugar', label: 'Sugar', unit: 'g' },
    { key: 'cholesterol', label: 'Cholesterol', unit: 'mg' },
  ];

  return (
    <div>
      <SectionTitle>Nutrition Gap Analysis</SectionTitle>
      <p className="text-sm text-gray-500 mb-4">
        Supplement companies and functional food brands pay premium for deficiency data.
        &quot;73% of your users are fiber deficient&quot; = product opportunity.
      </p>

      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
        <StatCard label="Sample Days" value={data.sampleDays} />
        <StatCard label="Goal Achievement" value={`${data.goalAchievementRate}%`} color="emerald" />
        <StatCard label="Avg Calorie Goal" value={data.avgCalorieGoal} color="blue" />
        <StatCard label="Actual Avg Intake" value={`${data.avgDailyIntake.calories} kcal`} color="purple" />
      </div>

      <SectionTitle>Avg Daily Intake vs RDA</SectionTitle>
      <div className="space-y-4">
        {nutrients.map((n) => {
          const avg = data.avgDailyIntake[n.key] || 0;
          const rda = data.rda[n.key] || 1;
          const pct = Math.min((avg / rda) * 100, 150);
          const isOver = avg > rda;
          const barColor = isOver ? 'bg-amber-500' : pct < 80 ? 'bg-red-500' : 'bg-emerald-500';

          return (
            <div key={n.key}>
              <div className="flex items-center justify-between text-sm mb-1">
                <span>{n.label}</span>
                <span className="text-gray-400">
                  {avg} / {rda} {n.unit} ({pct.toFixed(0)}%)
                </span>
              </div>
              <div className="w-full bg-gray-800 rounded-full h-2 relative">
                <div className={`${barColor} h-2 rounded-full transition-all`} style={{ width: `${Math.min(pct, 100)}%` }} />
                <div className="absolute top-0 left-[80%] w-px h-2 bg-gray-600" title="80% RDA" />
              </div>
            </div>
          );
        })}
      </div>

      <SectionTitle>Deficiency / Excess Rates</SectionTitle>
      <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
        {Object.entries(data.deficiencyRates).map(([key, pct]) => {
          const isExcess = key.startsWith('excess');
          return (
            <StatCard
              key={key}
              label={key.replace(/([A-Z])/g, ' $1').replace('excess ', '⚠️ Excess ')}
              value={`${pct}%`}
              sub={isExcess ? '> 100% RDA' : '< 80% RDA'}
              color={pct > 50 ? 'red' : pct > 30 ? 'amber' : 'emerald'}
            />
          );
        })}
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════
// MEAL TIMING TAB
// ═══════════════════════════════════════════════════════

function TimingTab({ data }: { data: MealTiming }) {
  const maxHourly = Math.max(...data.hourlyDistribution);

  return (
    <div>
      <SectionTitle>Meal Timing Patterns</SectionTitle>
      <p className="text-sm text-gray-500 mb-4">
        Food delivery and restaurant chains use this to optimize operating hours and marketing campaigns.
      </p>

      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
        {Object.entries(data.peakHours).map(([meal, info]) => (
          <StatCard
            key={meal}
            label={`Peak ${meal}`}
            value={`${info.peakHour}:00`}
            sub={`${info.count} entries`}
            color={meal === 'breakfast' ? 'amber' : meal === 'lunch' ? 'emerald' : meal === 'dinner' ? 'purple' : 'blue'}
          />
        ))}
      </div>

      <SectionTitle>Hourly Distribution</SectionTitle>
      <div className="flex items-end gap-1 h-40">
        {data.hourlyDistribution.map((count, hour) => (
          <div key={hour} className="flex-1 flex flex-col items-center gap-1">
            <div
              className="w-full bg-emerald-500/80 rounded-t transition-all hover:bg-emerald-400"
              style={{ height: `${(count / (maxHourly || 1)) * 100}%`, minHeight: count > 0 ? '2px' : '0' }}
              title={`${hour}:00 — ${count} entries`}
            />
            <span className="text-xs text-gray-600">{hour}</span>
          </div>
        ))}
      </div>

      <StatCard label="Late-Night Eating (22:00–05:00)" value={`${data.lateNightEating}%`} sub="of all entries" color="amber" />
    </div>
  );
}

// ═══════════════════════════════════════════════════════
// DEMOGRAPHICS TAB
// ═══════════════════════════════════════════════════════

function DemographicsTab({ data, macros }: { data: Demographics; macros: MacroSegments }) {
  return (
    <div>
      <SectionTitle>User Demographics</SectionTitle>
      <p className="text-sm text-gray-500 mb-4">
        Brands pay for demographic-segmented nutrition data to target products precisely.
        All data is pseudonymized — no PII.
      </p>

      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
        <StatCard label="Total Profiles" value={data.totalProfiles} color="blue" />
        <StatCard label="Avg Age" value={data.averages.age ?? '-'} color="purple" />
        <StatCard label="Avg Weight" value={data.averages.weight ? `${data.averages.weight} kg` : '-'} color="emerald" />
        <StatCard label="Avg Height" value={data.averages.height ? `${data.averages.height} cm` : '-'} color="cyan" />
      </div>

      <div className="grid md:grid-cols-2 gap-8">
        <DistributionChart title="Gender" data={data.gender} />
        <DistributionChart title="Age Groups" data={data.ageGroups} />
        <DistributionChart title="Activity Level" data={data.activityLevel} />
        <DistributionChart title="BMI Categories" data={data.bmi} />
        <DistributionChart title="Cuisine Preference" data={data.cuisinePreference} />
        <DistributionChart title="Diet Type (by Macros)" data={macros.distribution} />
      </div>
    </div>
  );
}

function DistributionChart({ title, data }: { title: string; data: Record<string, number> }) {
  const total = Object.values(data).reduce((s, v) => s + v, 0) || 1;
  const maxVal = Math.max(...Object.values(data));
  const colors = ['bg-emerald-500', 'bg-blue-500', 'bg-purple-500', 'bg-amber-500', 'bg-cyan-500', 'bg-red-500', 'bg-pink-500', 'bg-lime-500'];

  return (
    <div className="border border-gray-800 rounded-xl p-5">
      <h4 className="text-sm font-semibold mb-4">{title}</h4>
      <div className="space-y-2">
        {Object.entries(data)
          .filter(([, v]) => v > 0)
          .sort((a, b) => b[1] - a[1])
          .map(([label, value], i) => (
            <div key={label}>
              <div className="flex items-center justify-between text-xs mb-1">
                <span className="capitalize">{label.replace(/_/g, ' ')}</span>
                <span className="text-gray-500">{value} ({((value / total) * 100).toFixed(1)}%)</span>
              </div>
              <div className="w-full bg-gray-800 rounded-full h-2">
                <div
                  className={`${colors[i % colors.length]} h-2 rounded-full`}
                  style={{ width: `${(value / maxVal) * 100}%` }}
                />
              </div>
            </div>
          ))}
      </div>
    </div>
  );
}

// ═══════════════════════════════════════════════════════
// ENGAGEMENT TAB
// ═══════════════════════════════════════════════════════

function EngagementTab({ data }: { data: Engagement }) {
  const maxDaily = Math.max(...data.dailyTrend.map((d) => d.count));

  return (
    <div>
      <SectionTitle>User Engagement</SectionTitle>

      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
        <StatCard label="Total Sync Users" value={data.totalUsers} />
        <StatCard label="Active Users" value={data.activeUsers} sub={`${data.activationRate}% of total`} color="emerald" />
        <StatCard label="Avg Entries/User" value={data.avgEntriesPerUser} sub={`Median: ${data.medianEntries}`} color="blue" />
        <StatCard label="Power Users" value={data.powerUsers} sub={`${data.powerUserRate}% (>20 entries/wk)`} color="purple" />
      </div>

      <SectionTitle>Data Source Distribution</SectionTitle>
      <div className="grid grid-cols-2 md:grid-cols-3 gap-4 mb-8">
        {Object.entries(data.sourceDistribution).map(([src, count]) => (
          <StatCard
            key={src}
            label={SOURCE_NAMES[parseInt(src)] || `Source ${src}`}
            value={count}
            sub={`${((count / data.dailyTrend.reduce((s, d) => s + d.count, 0) || 1) * 100).toFixed(1)}%`}
            color={src === '0' ? 'emerald' : src === '1' ? 'blue' : src === '2' ? 'purple' : 'amber'}
          />
        ))}
      </div>

      {data.dailyTrend.length > 0 && (
        <>
          <SectionTitle>Daily Entry Trend</SectionTitle>
          <div className="flex items-end gap-px h-32">
            {data.dailyTrend.map((d) => (
              <div key={d.date} className="flex-1 flex flex-col items-center gap-1">
                <div
                  className="w-full bg-emerald-500/80 rounded-t hover:bg-emerald-400 transition-all"
                  style={{ height: `${(d.count / (maxDaily || 1)) * 100}%`, minHeight: d.count > 0 ? '2px' : '0' }}
                  title={`${d.date}: ${d.count} entries`}
                />
              </div>
            ))}
          </div>
          <div className="flex justify-between text-xs text-gray-600 mt-1">
            <span>{data.dailyTrend[0]?.date}</span>
            <span>{data.dailyTrend[data.dailyTrend.length - 1]?.date}</span>
          </div>
        </>
      )}
    </div>
  );
}

// ═══════════════════════════════════════════════════════
// AI DATASET TAB
// ═══════════════════════════════════════════════════════

const TIER_COLORS: Record<string, string> = {
  platinum: 'from-purple-400 to-pink-400',
  gold: 'from-amber-400 to-yellow-300',
  silver: 'from-gray-300 to-gray-400',
  bronze: 'from-orange-400 to-orange-600',
};

const TIER_DESCRIPTIONS: Record<string, string> = {
  platinum: 'Image + Bounding Box + Calibration (px→cm) + Ingredients',
  gold: 'Image + Labels + Ingredients (high confidence)',
  silver: 'Image + Labels or Ingredients',
  bronze: 'Image + Nutrition Labels only',
};

function AiDatasetTab({ data, secret }: { data: AiDataset; secret: string }) {
  const [exporting, setExporting] = useState(false);
  const [exportResult, setExportResult] = useState<any>(null);

  const handleExport = async (tier: string, confidence: number) => {
    setExporting(true);
    try {
      const res = await fetch(`${API_BASE}/exportDataset`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${secret}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ tier, minConfidence: confidence, days: 90, limit: 10000 }),
      });
      const result = await res.json();
      if (result.success) {
        setExportResult(result);
        const blob = new Blob([JSON.stringify(result, null, 2)], { type: 'application/json' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `miro-dataset-${tier}-${new Date().toISOString().split('T')[0]}.json`;
        a.click();
        URL.revokeObjectURL(url);
      }
    } catch (e: any) {
      console.error(e);
    }
    setExporting(false);
  };

  const val = data.estimatedDatasetValue;

  return (
    <div>
      <SectionTitle>AI Training Dataset</SectionTitle>
      <p className="text-sm text-gray-500 mb-6">
        Labeled food images with nutrition data, bounding boxes, and real-world calibration.
        Southeast Asian cuisine data is extremely rare in the market — this is a premium dataset.
      </p>

      {/* Value estimate */}
      <div className="border border-emerald-600/30 bg-emerald-600/5 rounded-xl p-6 mb-8">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-xs text-gray-500 uppercase tracking-wide">Estimated Dataset Value</p>
            <p className="text-3xl font-bold text-emerald-400 mt-1">${val.estimatedTotalUSD.toLocaleString()}</p>
            <p className="text-sm text-gray-400 mt-1">
              {val.totalImages.toLocaleString()} images · Monthly license: ${val.monthlyLicenseEstimate.toLocaleString()}/mo
            </p>
          </div>
          <div className="text-right text-xs text-gray-500 space-y-1">
            <p>Platinum: ${val.perImagePricing.platinum}/img</p>
            <p>Gold: ${val.perImagePricing.gold}/img</p>
            <p>Silver: ${val.perImagePricing.silver}/img</p>
            <p>Bronze: ${val.perImagePricing.bronze}/img</p>
          </div>
        </div>
      </div>

      {/* Coverage stats */}
      <SectionTitle>Data Coverage</SectionTitle>
      <div className="grid grid-cols-2 md:grid-cols-3 gap-4 mb-8">
        <StatCard label="With Thumbnail" value={data.withThumbnail} sub={`${data.coverageRates.thumbnail}%`} color="emerald" />
        <StatCard label="With Ingredients" value={data.withIngredients} sub={`${data.coverageRates.ingredients}%`} color="blue" />
        <StatCard label="With Bounding Box" value={data.withBoundingBox} sub={`${data.coverageRates.boundingBox}%`} color="purple" />
        <StatCard label="With Calibration (px→cm)" value={data.withCalibration} sub={`${data.coverageRates.calibration}%`} color="amber" />
        <StatCard label="High Confidence (≥80%)" value={data.withHighConfidence} sub={`${data.coverageRates.highConfidence}%`} color="cyan" />
        <StatCard label="Total Entries" value={data.totalEntries} color="emerald" />
      </div>

      {/* Quality tiers */}
      <SectionTitle>Quality Tiers</SectionTitle>
      <div className="grid md:grid-cols-2 gap-4 mb-8">
        {(['platinum', 'gold', 'silver', 'bronze'] as const).map((tier) => {
          const count = data.qualityTiers[tier];
          const total = data.withThumbnail || 1;
          const pct = ((count / total) * 100).toFixed(1);
          return (
            <div key={tier} className="border border-gray-800 rounded-xl p-5 bg-gray-900/50">
              <div className="flex items-center justify-between mb-2">
                <div className="flex items-center gap-2">
                  <div className={`w-3 h-3 rounded-full bg-gradient-to-r ${TIER_COLORS[tier]}`} />
                  <span className="font-semibold capitalize">{tier}</span>
                </div>
                <span className="text-xl font-bold">{count.toLocaleString()}</span>
              </div>
              <p className="text-xs text-gray-500 mb-3">{TIER_DESCRIPTIONS[tier]}</p>
              <div className="w-full bg-gray-800 rounded-full h-2">
                <div className={`bg-gradient-to-r ${TIER_COLORS[tier]} h-2 rounded-full`} style={{ width: `${pct}%` }} />
              </div>
              <div className="flex items-center justify-between mt-2">
                <span className="text-xs text-gray-500">{pct}% of images</span>
                <button
                  onClick={() => handleExport(tier, 0)}
                  disabled={exporting || count === 0}
                  className="text-xs px-3 py-1 rounded-lg bg-gray-700 hover:bg-gray-600 disabled:opacity-50 transition"
                >
                  Export {tier}
                </button>
              </div>
            </div>
          );
        })}
      </div>

      {/* Detected object labels */}
      {data.detectedLabels.length > 0 && (
        <>
          <SectionTitle>Detected Object Labels (from AR)</SectionTitle>
          <div className="grid md:grid-cols-2 gap-x-8 gap-y-1 mb-8">
            {data.detectedLabels.slice(0, 30).map((lb, i) => (
              <div key={lb.label} className="flex items-center gap-3 py-2">
                <span className="text-xs text-gray-600 w-6 text-right">{i + 1}</span>
                <div className="flex-1">
                  <div className="flex items-center justify-between mb-1">
                    <span className="text-sm capitalize">{lb.label}</span>
                    <span className="text-xs text-gray-500">{lb.count}x</span>
                  </div>
                  <div className="w-full bg-gray-800 rounded-full h-1.5">
                    <div
                      className="bg-purple-500 h-1.5 rounded-full"
                      style={{ width: `${(lb.count / (data.detectedLabels[0]?.count || 1)) * 100}%` }}
                    />
                  </div>
                </div>
              </div>
            ))}
          </div>
        </>
      )}

      {/* Reference objects & resolutions */}
      <div className="grid md:grid-cols-2 gap-8 mb-8">
        {Object.keys(data.referenceObjects).length > 0 && (
          <div className="border border-gray-800 rounded-xl p-5">
            <h4 className="text-sm font-semibold mb-4">Reference Objects (for Calibration)</h4>
            <div className="space-y-2">
              {Object.entries(data.referenceObjects)
                .sort((a, b) => b[1] - a[1])
                .map(([obj, count]) => (
                  <div key={obj} className="flex items-center justify-between text-sm">
                    <span className="capitalize">{obj.replace(/([A-Z])/g, ' $1').trim()}</span>
                    <span className="text-gray-500">{count}</span>
                  </div>
                ))}
            </div>
          </div>
        )}

        {data.resolutions.length > 0 && (
          <div className="border border-gray-800 rounded-xl p-5">
            <h4 className="text-sm font-semibold mb-4">Image Resolutions</h4>
            <div className="space-y-2">
              {data.resolutions.map(({ resolution, count }) => (
                <div key={resolution} className="flex items-center justify-between text-sm">
                  <span className="font-mono">{resolution}</span>
                  <span className="text-gray-500">{count} images</span>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>

      {/* Export actions */}
      <SectionTitle>Export Dataset</SectionTitle>
      <div className="grid md:grid-cols-3 gap-4">
        <button
          onClick={() => handleExport('platinum', 0.8)}
          disabled={exporting}
          className="p-4 rounded-xl border border-purple-600/30 bg-purple-600/5 hover:bg-purple-600/10 transition text-left disabled:opacity-50"
        >
          <p className="font-semibold">Premium Export</p>
          <p className="text-xs text-gray-400 mt-1">Platinum only, confidence ≥ 80%</p>
          <p className="text-xs text-purple-400 mt-2">Best for: Object detection models</p>
        </button>
        <button
          onClick={() => handleExport('gold', 0.5)}
          disabled={exporting}
          className="p-4 rounded-xl border border-amber-600/30 bg-amber-600/5 hover:bg-amber-600/10 transition text-left disabled:opacity-50"
        >
          <p className="font-semibold">Standard Export</p>
          <p className="text-xs text-gray-400 mt-1">Gold+, confidence ≥ 50%</p>
          <p className="text-xs text-amber-400 mt-2">Best for: Food classification models</p>
        </button>
        <button
          onClick={() => handleExport('bronze', 0)}
          disabled={exporting}
          className="p-4 rounded-xl border border-gray-600/30 bg-gray-600/5 hover:bg-gray-600/10 transition text-left disabled:opacity-50"
        >
          <p className="font-semibold">Full Export</p>
          <p className="text-xs text-gray-400 mt-1">All images, no filter</p>
          <p className="text-xs text-gray-400 mt-2">Best for: Large-scale training</p>
        </button>
      </div>

      {exporting && <p className="text-sm text-gray-500 mt-4">Exporting dataset...</p>}

      {exportResult && (
        <div className="mt-6 border border-gray-800 rounded-xl p-5 bg-gray-900/50">
          <p className="text-sm font-semibold mb-2">Last Export Summary</p>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm">
            <div><span className="text-gray-500">Total Records:</span> {exportResult.totalRecords}</div>
            <div><span className="text-gray-500">Platinum:</span> {exportResult.tierBreakdown?.platinum || 0}</div>
            <div><span className="text-gray-500">Gold:</span> {exportResult.tierBreakdown?.gold || 0}</div>
            <div><span className="text-gray-500">Silver:</span> {exportResult.tierBreakdown?.silver || 0}</div>
          </div>
        </div>
      )}
    </div>
  );
}
