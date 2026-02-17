'use client';

import { useEffect, useState } from 'react';
import { Users, Zap, Brain, TrendingUp } from 'lucide-react';
import { MetricCard } from './MetricCard';
import { UserGrowthChart } from './UserGrowthChart';
import { StreakDistributionChart } from './StreakDistributionChart';
import { RecentActivities } from './RecentActivities';

interface DashboardStats {
  users: {
    total: number;
    active7d: number;
    active30d: number;
  };
  energy: {
    totalConsumed: number;
    avgPerUser: number;
  };
  ai: {
    totalAnalyses: number;
    avgPerUser: number;
  };
}

export function DashboardContent() {
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [userGrowth, setUserGrowth] = useState<any[]>([]);
  const [streakDistribution, setStreakDistribution] = useState<any[]>([]);
  const [activities, setActivities] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    try {
      setIsLoading(true);
      setError(null);

      // Fetch all data in parallel
      const [statsRes, growthRes, streakRes, activitiesRes] = await Promise.all([
        fetch('/api/dashboard/stats'),
        fetch('/api/dashboard/user-growth'),
        fetch('/api/dashboard/streak-distribution'),
        fetch('/api/dashboard/recent-activities'),
      ]);

      if (!statsRes.ok || !growthRes.ok || !streakRes.ok || !activitiesRes.ok) {
        throw new Error('Failed to fetch dashboard data');
      }

      const [statsData, growthData, streakData, activitiesData] = await Promise.all([
        statsRes.json(),
        growthRes.json(),
        streakRes.json(),
        activitiesRes.json(),
      ]);

      setStats(statsData);
      setUserGrowth(growthData.data || []);
      setStreakDistribution(streakData.data || []);
      setActivities(activitiesData.data || []);
    } catch (err) {
      console.error('Dashboard fetch error:', err);
      setError('Failed to load dashboard data. Please try again.');
    } finally {
      setIsLoading(false);
    }
  };

  if (error) {
    return (
      <div className="bg-red-50 border border-red-200 rounded-lg p-6 text-center">
        <p className="text-red-800 font-medium">{error}</p>
        <button
          onClick={fetchDashboardData}
          className="mt-4 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700"
        >
          Retry
        </button>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      {/* Metric Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <MetricCard
          title="Total Users"
          value={stats?.users.total || 0}
          icon={Users}
          description="All registered users"
          isLoading={isLoading}
        />
        <MetricCard
          title="Active Users (7d)"
          value={stats?.users.active7d || 0}
          icon={TrendingUp}
          description="Users active in last 7 days"
          isLoading={isLoading}
        />
        <MetricCard
          title="Total Energy Consumed"
          value={stats?.energy.totalConsumed || 0}
          icon={Zap}
          description={`Avg: ${stats?.energy.avgPerUser || 0} per user`}
          isLoading={isLoading}
        />
        <MetricCard
          title="AI Analyses"
          value={stats?.ai.totalAnalyses || 0}
          icon={Brain}
          description={`Avg: ${stats?.ai.avgPerUser || 0} per user`}
          isLoading={isLoading}
        />
      </div>

      {/* Charts Row */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <UserGrowthChart data={userGrowth} isLoading={isLoading} />
        <StreakDistributionChart data={streakDistribution} isLoading={isLoading} />
      </div>

      {/* Recent Activities */}
      <RecentActivities activities={activities} isLoading={isLoading} />
    </div>
  );
}
