'use client';

import { useState, useEffect } from 'react';

interface OfferStat {
  templateId: string;
  slug: string;
  title: string;
  rewardType: string;
  isActive: boolean;
  claims: number;
  totalEnergyGiven: number;
  totalFreepassDays: number;
  purchasesWithBonus: number;
  bonusEnergyGiven: number;
  revenue: number;
}

const REWARD_BADGE: Record<string, { label: string; color: string }> = {
  bonus_rate: { label: 'Bonus Rate', color: 'bg-purple-100 text-purple-800' },
  free_energy: { label: 'Free Energy', color: 'bg-blue-100 text-blue-800' },
  freepass: { label: 'Freepass', color: 'bg-green-100 text-green-800' },
};

export default function OfferAnalyticsPage() {
  const [stats, setStats] = useState<OfferStat[]>([]);
  const [loading, setLoading] = useState(true);
  const [dateRange, setDateRange] = useState('7d');
  const [customStartDate, setCustomStartDate] = useState('');
  const [customEndDate, setCustomEndDate] = useState('');

  useEffect(() => {
    fetchStats();
  }, [dateRange]);

  async function fetchStats() {
    setLoading(true);
    try {
      let url = `/api/analytics/promotions?dateRange=${dateRange}`;
      if (dateRange === 'custom' && customStartDate && customEndDate) {
        const s = new Date(customStartDate).getTime();
        const e = new Date(customEndDate).getTime();
        url = `/api/analytics/promotions?dateRange=custom:${s}:${e}`;
      }
      const res = await fetch(url);
      const data = await res.json();
      if (data.success) {
        setStats(data.stats);
      }
    } catch (err) {
      console.error('Error fetching offer analytics:', err);
    } finally {
      setLoading(false);
    }
  }

  const totalClaims = stats.reduce((a, s) => a + s.claims + s.purchasesWithBonus, 0);
  const totalEnergy = stats.reduce((a, s) => a + s.totalEnergyGiven + s.bonusEnergyGiven, 0);
  const totalRevenue = stats.reduce((a, s) => a + s.revenue, 0);

  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div className="flex flex-col gap-4 sm:flex-row sm:justify-between sm:items-center">
        <h1 className="text-2xl font-bold">Offer Analytics</h1>
        <div className="flex items-center gap-3 flex-wrap">
          <select
            className="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
            value={dateRange}
            onChange={(e) => setDateRange(e.target.value)}
            disabled={loading}
          >
            <option value="7d">Last 7 days</option>
            <option value="30d">Last 30 days</option>
            <option value="90d">Last 90 days</option>
            <option value="custom">Custom Range</option>
          </select>
          {dateRange === 'custom' && (
            <div className="flex items-center gap-2">
              <input
                type="date"
                className="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                value={customStartDate}
                onChange={(e) => setCustomStartDate(e.target.value)}
              />
              <span className="text-sm text-gray-500">to</span>
              <input
                type="date"
                className="border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                value={customEndDate}
                onChange={(e) => setCustomEndDate(e.target.value)}
              />
              <button
                className="bg-blue-500 text-white px-4 py-2 rounded-lg text-sm hover:bg-blue-600 disabled:bg-gray-300"
                onClick={fetchStats}
                disabled={!customStartDate || !customEndDate || loading}
              >
                Apply
              </button>
            </div>
          )}
        </div>
      </div>

      {loading ? (
        <div className="text-center py-12 text-gray-500">Loading…</div>
      ) : (
        <>
          {/* Summary Cards */}
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <SummaryCard label="Total Claims" value={totalClaims.toLocaleString()} />
            <SummaryCard label="Energy Given" value={totalEnergy.toLocaleString()} />
            <SummaryCard label="Revenue (est.)" value={`$${totalRevenue.toFixed(2)}`} />
          </div>

          {/* Table */}
          <div className="overflow-x-auto rounded-lg border border-gray-200">
            <table className="w-full text-sm">
              <thead>
                <tr className="bg-gray-50 text-left">
                  <th className="px-4 py-3 font-medium">Offer</th>
                  <th className="px-4 py-3 font-medium">Type</th>
                  <th className="px-4 py-3 font-medium text-center">Status</th>
                  <th className="px-4 py-3 font-medium text-right">Claims</th>
                  <th className="px-4 py-3 font-medium text-right">Reward Given</th>
                  <th className="px-4 py-3 font-medium text-right">Revenue</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {stats.length === 0 ? (
                  <tr>
                    <td colSpan={6} className="px-4 py-8 text-center text-gray-400">
                      No offer data in this period
                    </td>
                  </tr>
                ) : (
                  stats.map((s) => <OfferRow key={s.templateId} stat={s} />)
                )}
              </tbody>
            </table>
          </div>
        </>
      )}
    </div>
  );
}

function SummaryCard({ label, value }: { label: string; value: string }) {
  return (
    <div className="rounded-lg border border-gray-200 bg-white p-5">
      <p className="text-sm text-gray-500">{label}</p>
      <p className="mt-1 text-2xl font-semibold">{value}</p>
    </div>
  );
}

function OfferRow({ stat }: { stat: OfferStat }) {
  const badge = REWARD_BADGE[stat.rewardType] || { label: stat.rewardType, color: 'bg-gray-100 text-gray-700' };

  const claimCount = stat.rewardType === 'bonus_rate' ? stat.purchasesWithBonus : stat.claims;

  let rewardText = '—';
  if (stat.rewardType === 'free_energy' && stat.totalEnergyGiven > 0) {
    rewardText = `${stat.totalEnergyGiven.toLocaleString()} Energy`;
  } else if (stat.rewardType === 'freepass' && stat.totalFreepassDays > 0) {
    rewardText = `${stat.totalFreepassDays} days`;
  } else if (stat.rewardType === 'bonus_rate' && stat.bonusEnergyGiven > 0) {
    rewardText = `+${stat.bonusEnergyGiven.toLocaleString()} bonus E`;
  }

  return (
    <tr className="hover:bg-gray-50">
      <td className="px-4 py-3">
        <div className="font-medium">{stat.title}</div>
        <div className="text-xs text-gray-400">{stat.slug}</div>
      </td>
      <td className="px-4 py-3">
        <span className={`inline-block rounded-full px-2.5 py-0.5 text-xs font-medium ${badge.color}`}>
          {badge.label}
        </span>
      </td>
      <td className="px-4 py-3 text-center">
        <span
          className={`inline-block h-2 w-2 rounded-full ${stat.isActive ? 'bg-green-500' : 'bg-gray-300'}`}
          title={stat.isActive ? 'Active' : 'Inactive'}
        />
      </td>
      <td className="px-4 py-3 text-right font-medium tabular-nums">
        {claimCount.toLocaleString()}
      </td>
      <td className="px-4 py-3 text-right tabular-nums">{rewardText}</td>
      <td className="px-4 py-3 text-right tabular-nums">
        {stat.revenue > 0 ? `$${stat.revenue.toFixed(2)}` : '—'}
      </td>
    </tr>
  );
}
