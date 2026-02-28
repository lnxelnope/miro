'use client';

import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';

interface SubscriptionTabProps {
  user: any;
  deviceId: string;
  onRefresh: () => void;
}

export function SubscriptionTab({ user, deviceId, onRefresh }: SubscriptionTabProps) {
  const [loading, setLoading] = useState(false);
  const [showGrantForm, setShowGrantForm] = useState(false);
  const [grantDays, setGrantDays] = useState('30');

  const subscription = user?.subscription || {};
  const isActive = subscription.status === 'active';

  const handleGrantSubscription = async () => {
    const days = parseInt(grantDays);
    if (!days || days <= 0) {
      alert('Please enter valid number of days');
      return;
    }

    if (!confirm(`Grant ${days} days of subscription?`)) return;

    setLoading(true);
    try {
      const res = await fetch(`/api/users/${deviceId}/subscription`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'activate', days }),
      });
      const data = await res.json();

      if (res.ok && data.success) {
        alert(`✅ Subscription granted for ${days} days!`);
        setShowGrantForm(false);
        onRefresh();
      } else {
        alert('❌ Failed: ' + (data.error || 'Unknown error'));
      }
    } catch (err: any) {
      alert('❌ Error: ' + err.message);
    } finally {
      setLoading(false);
    }
  };

  const handleCancelSubscription = async () => {
    if (!confirm('Cancel subscription?')) return;

    setLoading(true);
    try {
      const res = await fetch(`/api/users/${deviceId}/subscription`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'cancel' }),
      });
      const data = await res.json();

      if (res.ok && data.success) {
        alert('✅ Subscription cancelled!');
        onRefresh();
      } else {
        alert('❌ Failed: ' + (data.error || 'Unknown error'));
      }
    } catch (err: any) {
      alert('❌ Error: ' + err.message);
    } finally {
      setLoading(false);
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'active':
        return 'bg-green-100 text-green-700 border-green-200';
      case 'cancelled':
        return 'bg-yellow-100 text-yellow-700 border-yellow-200';
      case 'expired':
        return 'bg-red-100 text-red-700 border-red-200';
      case 'grace_period':
        return 'bg-orange-100 text-orange-700 border-orange-200';
      default:
        return 'bg-gray-100 text-gray-700 border-gray-200';
    }
  };

  return (
    <div className="space-y-6">
      {/* Status Card */}
      <div className={`rounded-lg p-6 border-2 ${getStatusColor(subscription.status || 'none')}`}>
        <div className="flex items-center justify-between">
          <div>
            <h3 className="text-xl font-bold mb-2">
              {isActive ? '💎 Active Subscriber' : '❌ Not Subscribed'}
            </h3>
            <p className="text-sm capitalize">
              Status: <span className="font-semibold">{subscription.status || 'Never subscribed'}</span>
            </p>
          </div>
          {isActive && (
            <div className="text-right">
              <p className="text-sm text-gray-600">Plan</p>
              <p className="font-bold">{subscription.basePlanId || 'N/A'}</p>
            </div>
          )}
        </div>
      </div>

      {/* Subscription Details */}
      {subscription.status && (
        <div className="bg-white rounded-lg p-4 border">
          <h3 className="font-semibold mb-3">📋 Subscription Details</h3>
          <div className="grid grid-cols-2 gap-4">
            <div>
              <p className="text-sm text-gray-600">Product ID</p>
              <p className="font-mono text-sm">{subscription.productId || 'N/A'}</p>
            </div>
            <div>
              <p className="text-sm text-gray-600">Base Plan</p>
              <p className="text-sm font-medium">{subscription.basePlanId || 'N/A'}</p>
            </div>
            <div>
              <p className="text-sm text-gray-600">Start Date</p>
              <p className="text-sm">
                {subscription.startDate
                  ? new Date(subscription.startDate).toLocaleString()
                  : 'N/A'}
              </p>
            </div>
            <div>
              <p className="text-sm text-gray-600">Expiry Date</p>
              <p className="text-sm font-semibold">
                {subscription.expiryDate
                  ? new Date(subscription.expiryDate).toLocaleString()
                  : 'N/A'}
              </p>
            </div>
            <div>
              <p className="text-sm text-gray-600">Auto Renewing</p>
              <p className="text-sm">
                {subscription.autoRenewing ? (
                  <span className="text-green-600 font-semibold">✅ Yes</span>
                ) : (
                  <span className="text-gray-600">❌ No</span>
                )}
              </p>
            </div>
            <div>
              <p className="text-sm text-gray-600">Last Verified</p>
              <p className="text-sm">
                {subscription.lastVerifiedAt
                  ? new Date(subscription.lastVerifiedAt).toLocaleString()
                  : 'N/A'}
              </p>
            </div>
          </div>

          {subscription.offerId && (
            <div className="mt-4 p-3 bg-purple-50 rounded border border-purple-200">
              <p className="text-sm">
                <span className="font-semibold">🎁 Offer ID:</span> {subscription.offerId}
              </p>
            </div>
          )}
        </div>
      )}

      {/* Actions */}
      <div className="bg-white rounded-lg p-4 border">
        <h3 className="font-semibold mb-3">⚡ Test Actions</h3>
        
        <div className="space-y-3">
          {/* Grant Subscription */}
          {!isActive && (
            <div className="p-3 bg-green-50 rounded border border-green-200">
              <div className="flex items-center justify-between mb-2">
                <div>
                  <p className="font-semibold">✅ Grant Subscription</p>
                  <p className="text-sm text-gray-600">Activate test subscription</p>
                </div>
                <Button
                  onClick={() => setShowGrantForm(!showGrantForm)}
                  variant="outline"
                  size="sm"
                >
                  {showGrantForm ? 'Cancel' : 'Grant'}
                </Button>
              </div>

              {showGrantForm && (
                <div className="space-y-2 mt-3 p-3 bg-white rounded border">
                  <div>
                    <label className="text-sm font-medium">Number of Days</label>
                    <Input
                      type="number"
                      placeholder="30"
                      value={grantDays}
                      onChange={(e) => setGrantDays(e.target.value)}
                      min="1"
                    />
                  </div>
                  <div className="flex gap-2">
                    <Button onClick={handleGrantSubscription} disabled={loading} size="sm">
                      Grant Subscription
                    </Button>
                    <Button
                      onClick={() => setShowGrantForm(false)}
                      variant="outline"
                      size="sm"
                    >
                      Cancel
                    </Button>
                  </div>
                </div>
              )}
            </div>
          )}

          {/* Cancel Subscription — always visible for testing */}
          <div className="flex items-center justify-between p-3 bg-red-50 rounded border border-red-200">
            <div>
              <p className="font-semibold">❌ Cancel Subscription</p>
              <p className="text-sm text-gray-600">
                {isActive ? 'Test cancel flow' : 'Force cancel / clear subscription state'}
              </p>
            </div>
            <Button
              onClick={handleCancelSubscription}
              variant="destructive"
              disabled={loading}
            >
              Cancel
            </Button>
          </div>
        </div>
      </div>

      {/* Testing Scenarios */}
      <div className="bg-blue-50 rounded-lg p-4 border border-blue-200">
        <h4 className="font-semibold mb-2">💡 Testing Scenarios</h4>
        <div className="space-y-2 text-sm text-gray-700">
          <div className="flex items-start gap-2">
            <span className="font-semibold">1.</span>
            <div>
              <p className="font-medium">New Subscriber:</p>
              <p className="text-xs">Grant subscription → Test in-app benefits</p>
            </div>
          </div>
          <div className="flex items-start gap-2">
            <span className="font-semibold">2.</span>
            <div>
              <p className="font-medium">Churn Risk:</p>
              <p className="text-xs">Cancel subscription → User receives winback offers</p>
            </div>
          </div>
          <div className="flex items-start gap-2">
            <span className="font-semibold">3.</span>
            <div>
              <p className="font-medium">Expired User:</p>
              <p className="text-xs">Grant 1 day → Wait → Test expired state</p>
            </div>
          </div>
        </div>
      </div>

      {/* IAP History (Future) */}
      <div className="bg-gray-50 rounded-lg p-4 border">
        <h4 className="font-semibold mb-2">📱 IAP History</h4>
        <p className="text-sm text-gray-600">
          In-app purchase history will appear here (coming soon)
        </p>
      </div>
    </div>
  );
}
