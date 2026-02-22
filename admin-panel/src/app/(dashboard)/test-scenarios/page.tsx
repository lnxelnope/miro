'use client';

import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';

const SCENARIOS = [
  {
    id: 'new_user',
    name: '✨ New User Journey',
    description: 'Reset user to brand new state',
    icon: '✨',
    color: 'blue',
    details: [
      'Balance: 0E',
      'Tier: Starter',
      'Streak: 0',
      'All milestones: unclaimed',
      'All offers: unseen',
      'Subscription: none',
    ],
  },
  {
    id: 'streak_risk',
    name: '⚠️ About to Break Streak',
    description: 'High streak risk scenario',
    icon: '⚠️',
    color: 'yellow',
    details: [
      'Streak: 14 days',
      'Last check-in: 23 hours ago',
      'Balance: 5E (low energy)',
      'Next milestone: 50E away',
    ],
  },
  {
    id: 'tier_up',
    name: '🎯 Ready for Tier Up',
    description: 'Bronze → Silver promotion test',
    icon: '🎯',
    color: 'purple',
    details: [
      'Total spent: 495E (5E from Silver)',
      'Current tier: Bronze',
      'Balance: 100E',
      'All Bronze offers: purchased',
    ],
  },
  {
    id: 'churn_risk',
    name: '💳 Subscription Churn Risk',
    description: 'Cancelled subscriber scenario',
    icon: '💳',
    color: 'orange',
    details: [
      'Subscription: Cancelled (expires in 3 days)',
      'Last active: 5 days ago',
      'Streak: 0 (broken)',
      'Balance: 0E',
    ],
  },
  {
    id: 'whale',
    name: '🐋 High-Value Whale',
    description: 'VIP User scenario',
    icon: '🐋',
    color: 'green',
    details: [
      'Tier: Diamond',
      'Total spent: 15,000E',
      'Balance: 500E',
      'Subscription: Active Premium',
      'All milestones: claimed',
    ],
  },
];

export default function TestScenariosPage() {
  const [userId, setUserId] = useState('');
  const [resolvedDeviceId, setResolvedDeviceId] = useState('');
  const [resolvedMiroId, setResolvedMiroId] = useState('');
  const [resolving, setResolving] = useState(false);
  const [loading, setLoading] = useState(false);

  const resolveUser = async (input: string): Promise<string | null> => {
    try {
      setResolving(true);
      const res = await fetch(`/api/users/search?q=${encodeURIComponent(input.trim())}`);
      const data = await res.json();

      if (res.ok && data.success && data.user) {
        setResolvedDeviceId(data.user.deviceId);
        setResolvedMiroId(data.user.miroId || '');
        return data.user.deviceId;
      } else {
        setResolvedDeviceId('');
        setResolvedMiroId('');
        alert('❌ ไม่พบผู้ใช้: ' + input);
        return null;
      }
    } catch (err: any) {
      alert('❌ Error resolving user: ' + err.message);
      return null;
    } finally {
      setResolving(false);
    }
  };

  const handleApplyScenario = async (scenarioId: string) => {
    if (!userId.trim()) {
      alert('กรุณาใส่ MiRO ID หรือ Device ID');
      return;
    }

    let deviceId = resolvedDeviceId;
    if (!deviceId) {
      deviceId = (await resolveUser(userId)) || '';
      if (!deviceId) return;
    }

    if (!confirm(`Apply scenario to user: ${resolvedMiroId || deviceId}?`)) return;

    setLoading(true);
    try {
      const res = await fetch(`/api/users/${deviceId}/apply-scenario`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ scenario: scenarioId }),
      });
      const data = await res.json();

      if (res.ok && data.success) {
        alert(`✅ Scenario "${data.scenario}" applied successfully!`);
      } else {
        alert('❌ Failed: ' + (data.error || 'Unknown error'));
      }
    } catch (err: any) {
      alert('❌ Error: ' + err.message);
    } finally {
      setLoading(false);
    }
  };

  const getColorClasses = (color: string) => {
    const colors: Record<string, string> = {
      blue: 'border-blue-200 bg-blue-50',
      yellow: 'border-yellow-200 bg-yellow-50',
      purple: 'border-purple-200 bg-purple-50',
      orange: 'border-orange-200 bg-orange-50',
      green: 'border-green-200 bg-green-50',
    };
    return colors[color] || 'border-gray-200 bg-gray-50';
  };

  return (
    <div className="p-8 max-w-6xl mx-auto">
      <div className="mb-8">
        <h1 className="text-3xl font-bold mb-2">🧪 Test Scenarios</h1>
        <p className="text-gray-600">
          Apply preset user states for quick testing of different flows
        </p>
      </div>

      {/* User ID Input */}
      <div className="bg-white rounded-lg p-6 border mb-8">
        <label className="block text-sm font-semibold mb-2">
          MiRO ID / Device ID
        </label>
        <div className="flex gap-2 max-w-lg">
          <Input
            type="text"
            placeholder="เช่น MIRO-XXXX-XXXX-XXXX หรือ Device ID"
            value={userId}
            onChange={(e) => {
              setUserId(e.target.value);
              setResolvedDeviceId('');
              setResolvedMiroId('');
            }}
            onKeyDown={(e) => {
              if (e.key === 'Enter' && userId.trim()) resolveUser(userId);
            }}
          />
          <Button
            onClick={() => resolveUser(userId)}
            disabled={resolving || !userId.trim()}
            variant="outline"
          >
            {resolving ? '🔍...' : '🔍 ค้นหา'}
          </Button>
        </div>
        {resolvedDeviceId ? (
          <div className="mt-2 p-2 bg-green-50 rounded border border-green-200 text-sm">
            <span className="text-green-700 font-semibold">✅ พบผู้ใช้: </span>
            <span className="font-mono">{resolvedMiroId || resolvedDeviceId}</span>
            {resolvedMiroId && (
              <span className="text-gray-500 ml-2 text-xs">(Device: {resolvedDeviceId.slice(0, 12)}...)</span>
            )}
          </div>
        ) : (
          <p className="text-xs text-gray-500 mt-1">
            💡 ใส่ MiRO ID (เช่น MIRO-PZKB-NN4X-MT88) หรือ Device ID แล้วกด ค้นหา
          </p>
        )}
      </div>

      {/* Scenarios Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        {SCENARIOS.map((scenario) => (
          <div
            key={scenario.id}
            className={`rounded-lg border-2 p-6 ${getColorClasses(scenario.color)}`}
          >
            <div className="flex items-start justify-between mb-4">
              <div>
                <h3 className="text-xl font-bold mb-1">{scenario.name}</h3>
                <p className="text-sm text-gray-600">{scenario.description}</p>
              </div>
              <span className="text-3xl">{scenario.icon}</span>
            </div>

            <div className="bg-white rounded p-4 mb-4">
              <p className="text-xs font-semibold text-gray-600 mb-2">
                SCENARIO DETAILS:
              </p>
              <ul className="space-y-1">
                {scenario.details.map((detail, idx) => (
                  <li key={idx} className="text-sm text-gray-700">
                    • {detail}
                  </li>
                ))}
              </ul>
            </div>

            <Button
              onClick={() => handleApplyScenario(scenario.id)}
              disabled={loading || !userId.trim()}
              className="w-full"
            >
              {loading ? 'Applying...' : 'Apply Scenario'}
            </Button>
          </div>
        ))}
      </div>

      {/* Usage Instructions */}
      <div className="mt-8 bg-blue-50 rounded-lg p-6 border border-blue-200">
        <h3 className="font-semibold mb-3">📖 How to Use</h3>
        <ol className="space-y-2 text-sm text-gray-700">
          <li>
            <strong>1. Find User:</strong> Go to User Management and search for
            a user, copy their Device ID
          </li>
          <li>
            <strong>2. Paste ID:</strong> Paste the Device ID in the input field
            above
          </li>
          <li>
            <strong>3. Choose Scenario:</strong> Click "Apply Scenario" on the
            desired scenario card
          </li>
          <li>
            <strong>4. Test in App:</strong> Login as that user in the mobile
            app to test the flow
          </li>
          <li>
            <strong>5. Repeat:</strong> You can apply different scenarios to the
            same user multiple times
          </li>
        </ol>
      </div>

      {/* Tips */}
      <div className="mt-6 bg-green-50 rounded-lg p-6 border border-green-200">
        <h3 className="font-semibold mb-3">💡 Testing Tips</h3>
        <ul className="space-y-2 text-sm text-gray-700">
          <li>
            • <strong>New User Journey:</strong> Test onboarding, first
            milestone, and $1 offer
          </li>
          <li>
            • <strong>Streak Risk:</strong> Test streak reminder notifications
          </li>
          <li>
            • <strong>Tier Up:</strong> Test tier promotion flow and new tier
            benefits
          </li>
          <li>
            • <strong>Churn Risk:</strong> Test winback offers and
            re-engagement campaigns
          </li>
          <li>
            • <strong>Whale:</strong> Test VIP features and high-tier benefits
          </li>
        </ul>
      </div>
    </div>
  );
}
