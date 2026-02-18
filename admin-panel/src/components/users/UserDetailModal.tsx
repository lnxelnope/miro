'use client';

import { useEffect, useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';

interface UserDetailModalProps {
  deviceId: string;
  open: boolean;
  onClose: () => void;
  onRefresh?: () => void;
}

export function UserDetailModal({ deviceId, open, onClose, onRefresh }: UserDetailModalProps) {
  const [user, setUser] = useState<any>(null);
  const [transactions, setTransactions] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [showTopupForm, setShowTopupForm] = useState(false);
  const [topupAmount, setTopupAmount] = useState('');
  const [topupReason, setTopupReason] = useState('');
  const [showSubForm, setShowSubForm] = useState(false);
  const [subDays, setSubDays] = useState('30');

  useEffect(() => {
    if (!open || !deviceId) return;

    setLoading(true);
    fetch(`/api/users/${deviceId}`)
      .then((res) => res.json())
      .then((data) => {
        if (data.success) {
          setUser(data.user);
          setTransactions(data.transactions || []);
        }
        setLoading(false);
      })
      .catch((err) => {
        console.error(err);
        setLoading(false);
      });
  }, [open, deviceId]);

  const handleTopup = async () => {
    const amount = parseInt(topupAmount);
    const reason = topupReason.trim();

    if (!amount || !reason) {
      alert('Please enter amount and reason');
      return;
    }

    try {
      const res = await fetch(`/api/users/${deviceId}/topup`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ amount, reason }),
      });

      const data = await res.json();

      if (res.ok && data.success) {
        alert('Top-up successful!');
        setShowTopupForm(false);
        setTopupAmount('');
        setTopupReason('');
        onRefresh?.();
        // Refresh user data
        const userData = await fetch(`/api/users/${deviceId}`).then((r) => r.json());
        if (userData.success) {
          setUser(userData.user);
          setTransactions(userData.transactions || []);
        }
      } else {
        alert('Failed to top-up: ' + (data.error || 'Unknown error'));
      }
    } catch (err: any) {
      alert('Error: ' + err.message);
    }
  };

  const handleResetStreak = async () => {
    if (!confirm('Reset streak to 0?')) return;

    const reason = prompt('Reason for reset:');
    if (!reason) return;

    try {
      const res = await fetch(`/api/users/${deviceId}/reset-streak`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ reason }),
      });

      const data = await res.json();

      if (res.ok && data.success) {
        alert('Streak reset!');
        onRefresh?.();
        const userData = await fetch(`/api/users/${deviceId}`).then((r) => r.json());
        if (userData.success) {
          setUser(userData.user);
        }
      } else {
        alert('Failed to reset: ' + (data.error || 'Unknown error'));
      }
    } catch (err: any) {
      alert('Error: ' + err.message);
    }
  };

  const handleBan = async () => {
    const isBanned = !user?.isBanned;
    const action = isBanned ? 'Ban' : 'Unban';
    
    if (!confirm(`${action} this user?`)) return;

    const reason = prompt(`Reason for ${action.toLowerCase()}:`);
    if (!reason) return;

    try {
      const res = await fetch(`/api/users/${deviceId}/ban`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ isBanned, reason }),
      });

      const data = await res.json();

      if (res.ok && data.success) {
        alert(`User ${action.toLowerCase()}ned!`);
        onRefresh?.();
        const userData = await fetch(`/api/users/${deviceId}`).then((r) => r.json());
        if (userData.success) {
          setUser(userData.user);
        }
      } else {
        alert(`Failed to ${action.toLowerCase()}: ` + (data.error || 'Unknown error'));
      }
    } catch (err: any) {
      alert('Error: ' + err.message);
    }
  };

  const handleCancelSubscription = async () => {
    if (!confirm('Cancel subscription for this user?')) return;

    try {
      const res = await fetch(`/api/users/${deviceId}/subscription`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'cancel' }),
      });

      const data = await res.json();

      if (res.ok && data.success) {
        alert('Subscription cancelled!');
        onRefresh?.();
        const userData = await fetch(`/api/users/${deviceId}`).then((r) => r.json());
        if (userData.success) {
          setUser(userData.user);
        }
      } else {
        alert('Failed to cancel: ' + (data.error || 'Unknown error'));
      }
    } catch (err: any) {
      alert('Error: ' + err.message);
    }
  };

  const handleExtendSubscription = async () => {
    const days = parseInt(subDays);
    if (!days || days <= 0) {
      alert('Please enter valid number of days');
      return;
    }

    try {
      const res = await fetch(`/api/users/${deviceId}/subscription`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'extend', days }),
      });

      const data = await res.json();

      if (res.ok && data.success) {
        alert(`Subscription extended by ${days} days!`);
        setShowSubForm(false);
        setSubDays('30');
        onRefresh?.();
        const userData = await fetch(`/api/users/${deviceId}`).then((r) => r.json());
        if (userData.success) {
          setUser(userData.user);
        }
      } else {
        alert('Failed to extend: ' + (data.error || 'Unknown error'));
      }
    } catch (err: any) {
      alert('Error: ' + err.message);
    }
  };

  const handleActivateSubscription = async () => {
    const days = parseInt(subDays);
    if (!days || days <= 0) {
      alert('Please enter valid number of days');
      return;
    }

    try {
      const res = await fetch(`/api/users/${deviceId}/subscription`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'activate', days }),
      });

      const data = await res.json();

      if (res.ok && data.success) {
        alert(`Subscription activated for ${days} days!`);
        setShowSubForm(false);
        setSubDays('30');
        onRefresh?.();
        const userData = await fetch(`/api/users/${deviceId}`).then((r) => r.json());
        if (userData.success) {
          setUser(userData.user);
        }
      } else {
        alert('Failed to activate: ' + (data.error || 'Unknown error'));
      }
    } catch (err: any) {
      alert('Error: ' + err.message);
    }
  };

  if (!open) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
      <div className="bg-white rounded-lg shadow-lg max-w-3xl w-full max-h-[80vh] overflow-y-auto m-4">
        <div className="p-6">
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-2xl font-bold">👤 User: {user?.miroId || deviceId}</h2>
            <button
              onClick={onClose}
              className="text-gray-500 hover:text-gray-700 text-2xl"
            >
              ×
            </button>
          </div>

          {loading ? (
            <div className="text-center py-8">Loading...</div>
          ) : (
            <>
              {/* User Info */}
              <div className="grid grid-cols-2 gap-4 my-4">
                <div className="bg-gray-50 p-4 rounded">
                  <p className="text-sm text-gray-600">Balance</p>
                  <p className="text-2xl font-bold">⚡ {user?.balance || 0}</p>
                </div>
                <div className="bg-gray-50 p-4 rounded">
                  <p className="text-sm text-gray-600">Tier</p>
                  <p className="text-2xl font-bold capitalize">{user?.tier || 'none'}</p>
                </div>
                <div className="bg-gray-50 p-4 rounded">
                  <p className="text-sm text-gray-600">Streak</p>
                  <p className="text-2xl font-bold">{user?.currentStreak || 0} days</p>
                </div>
                <div className="bg-gray-50 p-4 rounded">
                  <p className="text-sm text-gray-600">Total Spent</p>
                  <p className="text-2xl font-bold">{user?.totalSpent || 0}</p>
                </div>
              </div>

              {/* Subscriber Badge */}
              {user?.isSubscriber && (
                <div className="bg-purple-50 border border-purple-200 p-3 rounded text-center mb-4">
                  <span className="text-purple-700 font-semibold">💎 Active Subscriber</span>
                  {user.subscriptionExpiryDate && (
                    <span className="text-sm text-gray-600 ml-2">
                      until {new Date(user.subscriptionExpiryDate).toLocaleDateString()}
                    </span>
                  )}
                </div>
              )}

              {/* Ban Badge */}
              {user?.isBanned && (
                <div className="bg-red-50 border border-red-200 p-3 rounded mb-4">
                  <p className="text-red-700 font-semibold">🚫 BANNED</p>
                  <p className="text-sm text-gray-600">Reason: {user.banReason}</p>
                </div>
              )}

              {/* Actions */}
              <div className="flex gap-2 mb-4 flex-wrap">
                <Button onClick={() => setShowTopupForm(!showTopupForm)} variant="outline">
                  💰 Top-up
                </Button>
                <Button onClick={handleResetStreak} variant="outline">
                  🔄 Reset Streak
                </Button>
                <Button onClick={handleBan} variant={user?.isBanned ? 'default' : 'destructive'}>
                  {user?.isBanned ? '✅ Unban' : '🚫 Ban'}
                </Button>
                
                {/* Subscription Actions */}
                {user?.isSubscriber ? (
                  <>
                    <Button onClick={handleCancelSubscription} variant="destructive">
                      🚫 Cancel Subscription
                    </Button>
                    <Button onClick={() => setShowSubForm(!showSubForm)} variant="outline">
                      ➕ Extend Subscription
                    </Button>
                  </>
                ) : (
                  <Button onClick={() => setShowSubForm(!showSubForm)} variant="outline">
                    💎 Activate Subscription
                  </Button>
                )}
              </div>

              {/* Top-up Form */}
              {showTopupForm && (
                <div className="bg-blue-50 border border-blue-200 p-4 rounded space-y-3 mb-4">
                  <h4 className="font-semibold">Top-up Energy</h4>
                  <Input
                    type="number"
                    placeholder="Amount"
                    value={topupAmount}
                    onChange={(e) => setTopupAmount(e.target.value)}
                  />
                  <Input
                    type="text"
                    placeholder="Reason (e.g., Compensation)"
                    value={topupReason}
                    onChange={(e) => setTopupReason(e.target.value)}
                  />
                  <Button onClick={handleTopup}>
                    Confirm Top-up
                  </Button>
                </div>
              )}

              {/* Subscription Form */}
              {showSubForm && (
                <div className="bg-purple-50 border border-purple-200 p-4 rounded space-y-3 mb-4">
                  <h4 className="font-semibold">
                    {user?.isSubscriber ? 'Extend Subscription' : 'Activate Subscription'}
                  </h4>
                  <div>
                    <label className="text-sm text-gray-600">Number of Days</label>
                    <Input
                      type="number"
                      placeholder="30"
                      value={subDays}
                      onChange={(e) => setSubDays(e.target.value)}
                      min="1"
                    />
                  </div>
                  <div className="flex gap-2">
                    {user?.isSubscriber ? (
                      <Button onClick={handleExtendSubscription}>
                        Extend Subscription
                      </Button>
                    ) : (
                      <Button onClick={handleActivateSubscription}>
                        Activate Subscription
                      </Button>
                    )}
                    <Button variant="outline" onClick={() => setShowSubForm(false)}>
                      Cancel
                    </Button>
                  </div>
                </div>
              )}

              {/* Transactions */}
              <div className="mt-6">
                <h4 className="font-semibold mb-3">📋 Transaction History (Last 50)</h4>
                <div className="space-y-2 max-h-60 overflow-y-auto">
                  {transactions.length === 0 ? (
                    <p className="text-gray-500 text-center py-4">No transactions</p>
                  ) : (
                    transactions.map((tx: any) => (
                      <div key={tx.id} className="flex justify-between items-start bg-gray-50 p-3 rounded text-sm">
                        <div className="flex-1">
                          <p className="font-medium">{tx.description}</p>
                          <p className="text-xs text-gray-500">
                            {tx.createdAt ? new Date(tx.createdAt).toLocaleString() : 'Unknown date'}
                          </p>
                        </div>
                        <span className={`font-bold ${tx.amount > 0 ? 'text-green-600' : 'text-red-600'}`}>
                          {tx.amount > 0 ? '+' : ''}{tx.amount}
                        </span>
                      </div>
                    ))
                  )}
                </div>
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
}
