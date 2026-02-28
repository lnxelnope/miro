'use client';

import { useEffect, useState } from 'react';

export function RecentActivities() {
  const [activities, setActivities] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch('/api/dashboard/recent-activities?limit=10')
      .then((res) => res.json())
      .then((json) => {
        setActivities(json.activities || []);
        setLoading(false);
      })
      .catch((err) => {
        console.error(err);
        setLoading(false);
      });
  }, []);

  if (loading) return <div className="text-center py-8">Loading...</div>;

  const typeEmoji: Record<string, string> = {
    purchase: '💰',
    usage: '⚡',
    daily_checkin: '✅',
    tier_upgrade_reward: '🎊',
    admin_topup: '🔧',
  };

  return (
    <div className="bg-white rounded-lg shadow p-6">
      <h3 className="text-lg font-semibold mb-4">📋 Recent Activities</h3>
      <div className="space-y-2">
        {activities.map((activity: any) => (
          <div key={activity.id} className="flex items-start justify-between py-2 border-b last:border-0">
            <div className="flex-1">
              <p className="text-sm">
                <span className="mr-2">{typeEmoji[activity.type] || '📝'}</span>
                {activity.description}
              </p>
              <p className="text-xs text-gray-500 mt-1">
                {activity.miroId} • {new Date(activity.createdAt).toLocaleString()}
              </p>
            </div>
            <span className={`text-sm font-medium ${activity.amount > 0 ? 'text-green-600' : 'text-red-600'}`}>
              {activity.amount > 0 ? '+' : ''}{activity.amount}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
}
