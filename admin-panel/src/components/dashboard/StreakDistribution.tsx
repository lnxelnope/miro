'use client';

import { useEffect, useState } from 'react';

export function StreakDistribution() {
  const [distribution, setDistribution] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch('/api/dashboard/streak-distribution')
      .then((res) => res.json())
      .then((json) => {
        setDistribution(json.distribution || []);
        setLoading(false);
      })
      .catch((err) => {
        console.error(err);
        setLoading(false);
      });
  }, []);

  if (loading) return <div className="text-center py-8">Loading...</div>;

  const tierColors: Record<string, string> = {
    Starter: 'bg-gray-200 text-gray-800',
    Bronze: 'bg-orange-200 text-orange-800',
    Silver: 'bg-gray-300 text-gray-800',
    Gold: 'bg-yellow-200 text-yellow-800',
    Diamond: 'bg-blue-200 text-blue-800',
  };

  return (
    <div className="bg-white rounded-lg shadow p-6">
      <h3 className="text-lg font-semibold mb-4">🔥 Streak Distribution</h3>
      <div className="space-y-3">
        {distribution.map((item: any) => (
          <div key={item.tier} className="flex items-center justify-between">
            <span className={`px-3 py-1 rounded-full text-sm font-medium ${tierColors[item.tier] || 'bg-gray-100'}`}>
              {item.tier}
            </span>
            <span className="text-lg font-bold">{item.count}</span>
          </div>
        ))}
      </div>
    </div>
  );
}
