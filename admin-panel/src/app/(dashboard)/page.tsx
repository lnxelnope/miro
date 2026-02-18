'use client';

import { useEffect, useState } from 'react';
import { MetricCard } from '@/components/dashboard/MetricCardSimple';
import { UserGrowthChart } from '@/components/dashboard/UserGrowthChartSimple';
import { StreakDistribution } from '@/components/dashboard/StreakDistribution';
import { RecentActivities } from '@/components/dashboard/RecentActivitiesSimple';

export default function DashboardPage() {
  const [stats, setStats] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch('/api/dashboard/stats')
      .then((res) => res.json())
      .then((json) => {
        setStats(json.stats);
        setLoading(false);
      })
      .catch((err) => {
        console.error(err);
        setLoading(false);
      });
  }, []);

  if (loading) {
    return (
      <div className="p-8">
        <div className="text-center py-12">Loading dashboard...</div>
      </div>
    );
  }

  return (
    <div className="p-8">
      <h1 className="text-3xl font-bold mb-6">📊 Dashboard</h1>

      {/* Metric Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <MetricCard
          title="Total Users"
          value={stats?.totalUsers.toLocaleString() || 0}
          icon="👥"
          description="All registered users"
        />
        <MetricCard
          title="Active Users"
          value={stats?.activeUsers.toLocaleString() || 0}
          icon="✅"
          description="Checked in last 7 days"
        />
        <MetricCard
          title="Total Revenue"
          value={`฿${stats?.totalRevenue.toLocaleString() || 0}`}
          icon="💰"
          description="All-time revenue"
        />
        <MetricCard
          title="Active Subscribers"
          value={stats?.activeSubscribers.toLocaleString() || 0}
          icon="💎"
          description="Current subscribers"
        />
      </div>

      {/* User Growth Chart */}
      <div className="mb-8">
        <UserGrowthChart />
      </div>

      {/* Bottom Row: Streak Distribution + Recent Activities */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <StreakDistribution />
        <RecentActivities />
      </div>
    </div>
  );
}
