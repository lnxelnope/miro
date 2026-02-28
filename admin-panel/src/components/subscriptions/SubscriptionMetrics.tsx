'use client';

import { useEffect, useState } from 'react';
import { MetricCard } from '@/components/dashboard/MetricCardSimple';

export function SubscriptionMetrics() {
  const [metrics, setMetrics] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch('/api/subscriptions/metrics')
      .then((res) => res.json())
      .then((data) => {
        if (data.success) {
          setMetrics(data.metrics);
        }
        setLoading(false);
      })
      .catch((err) => {
        console.error(err);
        setLoading(false);
      });
  }, []);

  if (loading) return <div className="text-center py-4">Loading metrics...</div>;

  return (
    <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-6">
      <MetricCard
        title="MRR"
        value={`฿${metrics?.mrr?.toLocaleString() || 0}`}
        icon="💰"
        description="Monthly Recurring Revenue"
      />
      <MetricCard
        title="Active Subscribers"
        value={metrics?.activeSubscribers || 0}
        icon="💎"
        description="Currently subscribed"
      />
      <MetricCard
        title="Expiring Soon"
        value={metrics?.expiringSoon || 0}
        icon="🔔"
        description="Within 7 days"
      />
      <MetricCard
        title="Churn Rate"
        value={`${metrics?.churnRate || 0}%`}
        icon="📉"
        description="Last 30 days"
      />
    </div>
  );
}
