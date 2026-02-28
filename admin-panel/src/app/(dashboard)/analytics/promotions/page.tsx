'use client';

import { useState, useEffect } from 'react';

interface PromotionStats {
  name: string;
  timesShown: number;
  purchased: number;
  conversionRate: number;
  revenue: number;
}

export default function PromotionsPage() {
  const [stats, setStats] = useState<PromotionStats[]>([]);
  const [loading, setLoading] = useState(true);
  const [dateRange, setDateRange] = useState('7d');
  const [customStartDate, setCustomStartDate] = useState('');
  const [customEndDate, setCustomEndDate] = useState('');

  useEffect(() => {
    fetchPromotionStats();
  }, [dateRange]);

  async function fetchPromotionStats() {
    setLoading(true);

    try {
      let url = `/api/analytics/promotions?dateRange=${dateRange}`;
      
      // Handle custom date range
      if (dateRange === 'custom' && customStartDate && customEndDate) {
        const startTimestamp = new Date(customStartDate).getTime();
        const endTimestamp = new Date(customEndDate).getTime();
        url = `/api/analytics/promotions?dateRange=custom:${startTimestamp}:${endTimestamp}`;
      }
      
      const response = await fetch(url);
      const data = await response.json();

      if (data.success) {
        setStats(data.stats);
      } else {
        console.error('Failed to fetch promotion stats:', data.error);
      }
    } catch (error) {
      console.error('Error fetching promotion stats:', error);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-4">
        <h1 className="text-2xl font-bold">Promotion Conversion Rate</h1>
        
        {/* Date Range Filter */}
        <div className="flex items-center gap-4">
          <select
            className="border border-gray-300 rounded-lg p-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
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
                className="border border-gray-300 rounded-lg p-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                value={customStartDate}
                onChange={(e) => setCustomStartDate(e.target.value)}
              />
              <span>to</span>
              <input
                type="date"
                className="border border-gray-300 rounded-lg p-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                value={customEndDate}
                onChange={(e) => setCustomEndDate(e.target.value)}
              />
              <button
                className="bg-blue-500 text-white px-4 py-2 rounded-lg hover:bg-blue-600 disabled:bg-gray-300"
                onClick={fetchPromotionStats}
                disabled={!customStartDate || !customEndDate || loading}
              >
                Apply
              </button>
            </div>
          )}
        </div>
      </div>

      {loading ? (
        <div className="text-center py-12">Loading...</div>
      ) : (
        <div className="overflow-x-auto">
          <table className="w-full border border-gray-300">
            <thead>
              <tr className="bg-gray-100">
                <th className="border border-gray-300 p-2 text-left">Promotion</th>
                <th className="border border-gray-300 p-2 text-right">Times Shown</th>
                <th className="border border-gray-300 p-2 text-right">Purchased</th>
                <th className="border border-gray-300 p-2 text-right">Conversion %</th>
                <th className="border border-gray-300 p-2 text-right">Revenue</th>
              </tr>
            </thead>
            <tbody>
              {stats.length === 0 ? (
                <tr>
                  <td colSpan={5} className="border border-gray-300 p-4 text-center text-gray-500">
                    No promotion data available
                  </td>
                </tr>
              ) : (
                stats.map((stat) => (
                  <tr key={stat.name} className="hover:bg-gray-50">
                    <td className="border border-gray-300 p-2 font-medium">{stat.name}</td>
                    <td className="border border-gray-300 p-2 text-right">
                      {stat.timesShown.toLocaleString()}
                    </td>
                    <td className="border border-gray-300 p-2 text-right">
                      {stat.purchased.toLocaleString()}
                    </td>
                    <td className="border border-gray-300 p-2 text-right">
                      <span
                        className={
                          stat.conversionRate >= 5
                            ? 'text-green-600 font-semibold'
                            : stat.conversionRate >= 2
                            ? 'text-yellow-600'
                            : 'text-red-600'
                        }
                      >
                        {stat.conversionRate.toFixed(1)}%
                      </span>
                    </td>
                    <td className="border border-gray-300 p-2 text-right">
                      ${stat.revenue.toFixed(2)}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      )}

      <div className="mt-6 text-sm text-gray-600">
        <p>
          <strong>Note:</strong> Times Shown is currently estimated. Full analytics integration coming soon.
        </p>
      </div>
    </div>
  );
}
