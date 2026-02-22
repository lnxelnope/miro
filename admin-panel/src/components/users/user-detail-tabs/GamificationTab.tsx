'use client';

import { useState } from 'react';
import { Button } from '@/components/ui/button';

interface GamificationTabProps {
  user: any;
  deviceId: string;
  onRefresh: () => void;
}

const MILESTONES = [
  { id: 'milestone_10', threshold: 10, reward: '$1 Deal Offer' },
  { id: 'milestone_50', threshold: 50, reward: '20E Bonus' },
  { id: 'milestone_100', threshold: 100, reward: '30E Bonus' },
  { id: 'milestone_250', threshold: 250, reward: '50E + Badge' },
  { id: 'milestone_500', threshold: 500, reward: '40% Promo' },
  { id: 'milestone_1000', threshold: 1000, reward: '100E + Tier Up' },
  { id: 'milestone_2000', threshold: 2000, reward: '150E' },
  { id: 'milestone_2500', threshold: 2500, reward: '30% Promo' },
  { id: 'milestone_5000', threshold: 5000, reward: '300E' },
  { id: 'milestone_10000', threshold: 10000, reward: 'VIP Status' },
];

export function GamificationTab({ user, deviceId, onRefresh }: GamificationTabProps) {
  const [loading, setLoading] = useState(false);

  const milestones = user?.milestones || {};
  const totalSpent = milestones.totalSpent || 0;
  const claimedMilestones = milestones.claimedMilestones || [];

  const handleResetMilestones = async () => {
    if (!confirm('Reset all milestones? (totalSpent will be preserved)')) return;

    setLoading(true);
    try {
      const res = await fetch(`/api/users/${deviceId}/reset-milestones`, {
        method: 'POST',
      });
      const data = await res.json();

      if (res.ok && data.success) {
        alert('✅ Milestones reset successfully!');
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

  const handleSetStreak = async (streak: number) => {
    if (!confirm(`Set streak to ${streak} days?`)) return;

    setLoading(true);
    try {
      const res = await fetch(`/api/users/${deviceId}/set-streak`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          streak,
          lastCheckInDate: new Date().toISOString().split('T')[0],
        }),
      });
      const data = await res.json();

      if (res.ok && data.success) {
        alert(`✅ Streak set to ${streak} days!`);
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

  // Find next milestone
  const nextMilestone = MILESTONES.find(m => totalSpent < m.threshold);
  const remaining = nextMilestone ? nextMilestone.threshold - totalSpent : 0;

  return (
    <div className="space-y-6">
      {/* Summary */}
      <div className="grid grid-cols-3 gap-4">
        <div className="bg-purple-50 rounded-lg p-4 border border-purple-200">
          <p className="text-sm text-gray-600">🏆 Total Spent</p>
          <p className="text-3xl font-bold text-purple-600">{totalSpent}E</p>
        </div>
        <div className="bg-orange-50 rounded-lg p-4 border border-orange-200">
          <p className="text-sm text-gray-600">🔥 Current Streak</p>
          <p className="text-3xl font-bold text-orange-600">{user?.currentStreak || 0}</p>
        </div>
        <div className="bg-blue-50 rounded-lg p-4 border border-blue-200">
          <p className="text-sm text-gray-600">📺 Ads Watched Today</p>
          <p className="text-3xl font-bold text-blue-600">
            {user?.adViews?.count || 0}/5
          </p>
        </div>
      </div>

      {/* Milestones */}
      <div className="bg-white rounded-lg p-4 border">
        <div className="flex items-center justify-between mb-4">
          <h3 className="font-semibold">🏆 Milestones Progress</h3>
          <Button onClick={handleResetMilestones} variant="outline" size="sm" disabled={loading}>
            🔄 Reset Milestones
          </Button>
        </div>

        {nextMilestone && (
          <div className="mb-4 p-3 bg-yellow-50 rounded border border-yellow-200">
            <p className="text-sm font-semibold">Next Milestone: {nextMilestone.threshold}E</p>
            <p className="text-sm text-gray-600">
              {remaining}E remaining • Reward: {nextMilestone.reward}
            </p>
            <div className="mt-2 w-full bg-gray-200 rounded-full h-2">
              <div
                className="bg-yellow-500 h-2 rounded-full transition-all"
                style={{
                  width: `${Math.min(100, (totalSpent / nextMilestone.threshold) * 100)}%`,
                }}
              />
            </div>
          </div>
        )}

        <div className="space-y-2">
          {MILESTONES.map((milestone) => {
            const isClaimed = claimedMilestones.includes(milestone.id);
            const isReached = totalSpent >= milestone.threshold;

            return (
              <div
                key={milestone.id}
                className={`flex items-center justify-between p-3 rounded border ${
                  isClaimed
                    ? 'bg-green-50 border-green-200'
                    : isReached
                    ? 'bg-blue-50 border-blue-200'
                    : 'bg-gray-50 border-gray-200'
                }`}
              >
                <div className="flex items-center gap-3">
                  <div
                    className={`w-8 h-8 rounded-full flex items-center justify-center font-bold ${
                      isClaimed
                        ? 'bg-green-500 text-white'
                        : isReached
                        ? 'bg-blue-500 text-white'
                        : 'bg-gray-300 text-gray-600'
                    }`}
                  >
                    {isClaimed ? '✓' : MILESTONES.indexOf(milestone) + 1}
                  </div>
                  <div>
                    <p className="font-semibold text-sm">{milestone.threshold}E</p>
                    <p className="text-xs text-gray-600">{milestone.reward}</p>
                  </div>
                </div>
                <div>
                  {isClaimed ? (
                    <span className="px-2 py-1 bg-green-100 text-green-700 rounded text-xs font-semibold">
                      ✅ Claimed
                    </span>
                  ) : isReached ? (
                    <span className="px-2 py-1 bg-blue-100 text-blue-700 rounded text-xs font-semibold">
                      🎁 Ready
                    </span>
                  ) : (
                    <span className="px-2 py-1 bg-gray-100 text-gray-600 rounded text-xs">
                      🔒 Locked
                    </span>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      </div>

      {/* Streak Management */}
      <div className="bg-white rounded-lg p-4 border">
        <h3 className="font-semibold mb-3">🔥 Streak Management</h3>
        
        <div className="mb-4 p-3 bg-orange-50 rounded">
          <div className="flex items-center justify-between">
            <div>
              <p className="font-semibold">Current Streak: {user?.currentStreak || 0} days</p>
              <p className="text-sm text-gray-600">
                Longest: {user?.longestStreak || 0} days
              </p>
            </div>
          </div>
        </div>

        <div>
          <p className="text-sm font-medium mb-2">Quick Set:</p>
          <div className="flex gap-2 flex-wrap">
            {[0, 7, 15, 30, 60, 100].map((days) => (
              <Button
                key={days}
                onClick={() => handleSetStreak(days)}
                variant="outline"
                size="sm"
                disabled={loading}
              >
                {days} days
              </Button>
            ))}
          </div>
        </div>
      </div>

      {/* Ad Rewards */}
      <div className="bg-white rounded-lg p-4 border">
        <h3 className="font-semibold mb-3">📺 Rewarded Ads</h3>
        <div className="space-y-2">
          <div className="flex items-center justify-between p-3 bg-gray-50 rounded">
            <div>
              <p className="font-semibold">Ads Watched Today</p>
              <p className="text-sm text-gray-600">
                {user?.adViews?.count || 0} / 5 (Daily limit)
              </p>
            </div>
            <span className="text-2xl">{user?.adViews?.count || 0}/5</span>
          </div>
          <div className="p-3 bg-blue-50 rounded border border-blue-200">
            <p className="text-sm text-gray-600">
              Date: {user?.adViews?.date || 'Not set'}
            </p>
          </div>
        </div>
        <p className="text-xs text-gray-500 mt-2">
          💡 Ad view count resets daily at midnight
        </p>
      </div>

      {/* Challenges (Future) */}
      <div className="bg-gray-50 rounded-lg p-4 border">
        <h4 className="font-semibold mb-2">🎯 Weekly Challenges</h4>
        <p className="text-sm text-gray-600">
          Challenge system will appear here (coming soon)
        </p>
        {user?.challenges && (
          <div className="mt-2 p-2 bg-white rounded text-xs">
            <pre>{JSON.stringify(user.challenges, null, 2)}</pre>
          </div>
        )}
      </div>

      {/* Testing Tips */}
      <div className="bg-green-50 rounded-lg p-4 border border-green-200">
        <h4 className="font-semibold mb-2">💡 Testing Tips</h4>
        <ul className="text-sm space-y-1 text-gray-700">
          <li>• Go to <strong>Energy History</strong> tab to spend energy and trigger milestones</li>
          <li>• Reset milestones to test milestone flow multiple times</li>
          <li>• Set high streak to test streak-based features</li>
          <li>• Check <strong>Offers</strong> tab after reaching milestone thresholds</li>
        </ul>
      </div>
    </div>
  );
}
