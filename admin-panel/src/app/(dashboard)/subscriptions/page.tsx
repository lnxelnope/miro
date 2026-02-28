'use client';

import { SubscriptionMetrics } from '@/components/subscriptions/SubscriptionMetrics';
import { SubscribersTable } from '@/components/subscriptions/SubscribersTable';

export default function SubscriptionsPage() {
  return (
    <div className="p-8">
      <h1 className="text-3xl font-bold mb-6">💎 Subscription Management</h1>

      {/* Metrics */}
      <SubscriptionMetrics />

      {/* Subscribers Table */}
      <div className="mt-6">
        <h2 className="text-xl font-semibold mb-4">👥 All Subscribers</h2>
        <SubscribersTable />
      </div>
    </div>
  );
}
