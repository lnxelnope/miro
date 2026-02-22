'use client';

import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';

export default function BulkManagementPage() {
  const [loading, setLoading] = useState(false);
  const [count, setCount] = useState('100');
  const [result, setResult] = useState<any>(null);

  // Tier distribution state
  const [distribution, setDistribution] = useState({
    starter: 40,
    bronze: 30,
    silver: 20,
    gold: 8,
    diamond: 2,
  });

  // Referral test state
  const [referralLoading, setReferralLoading] = useState(false);
  const [referralCode, setReferralCode] = useState('');
  const [referralResult, setReferralResult] = useState<any>(null);
  const [bypassFraud, setBypassFraud] = useState(false);

  const handleCreateTestUsers = async () => {
    const userCount = parseInt(count);
    if (!userCount || userCount < 1 || userCount > 1000) {
      alert('Please enter a valid count (1-1000)');
      return;
    }

    const total = Object.values(distribution).reduce((a, b) => a + b, 0);
    if (Math.abs(total - 100) > 0.1) {
      alert('Tier distribution must add up to 100%');
      return;
    }

    if (!confirm(`Create ${userCount} test users?`)) return;

    setLoading(true);
    setResult(null);
    
    try {
      const res = await fetch('/api/users/bulk/create-test-users', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          count: userCount,
          tierDistribution: distribution,
        }),
      });
      const data = await res.json();

      if (res.ok && data.success) {
        setResult(data);
        alert(`✅ ${data.createdCount} test users created successfully!`);
      } else {
        alert('❌ Failed: ' + (data.error || 'Unknown error'));
      }
    } catch (err: any) {
      alert('❌ Error: ' + err.message);
    } finally {
      setLoading(false);
    }
  };

  const updateDistribution = (tier: string, value: number) => {
    setDistribution((prev) => ({
      ...prev,
      [tier]: Math.max(0, Math.min(100, value)),
    }));
  };

  const totalPercentage = Object.values(distribution).reduce((a, b) => a + b, 0);

  const handleTestReferral = async () => {
    if (!referralCode.trim()) {
      alert('Please enter a referral code (MiRO ID)');
      return;
    }

    if (!confirm(`Create test user with referral code: ${referralCode}?`)) return;

    setReferralLoading(true);
    setReferralResult(null);

    try {
      const res = await fetch('/api/users/bulk/create-referral-test', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          referralCode: referralCode.trim(),
          bypassFraud,
        }),
      });
      const data = await res.json();

      if (res.ok && data.success) {
        setReferralResult(data.data);
        alert(`✅ Referral test completed successfully!`);
      } else {
        const hint = data.hint ? `\n\n💡 ${data.hint}` : '';
        alert('❌ Failed: ' + (data.error || 'Unknown error') + hint);
      }
    } catch (err: any) {
      alert('❌ Error: ' + err.message);
    } finally {
      setReferralLoading(false);
    }
  };

  return (
    <div className="p-8 max-w-4xl mx-auto">
      <div className="mb-8">
        <h1 className="text-3xl font-bold mb-2">🎯 Bulk User Management</h1>
        <p className="text-gray-600">
          Create test users in bulk for load testing and scenario testing
        </p>
      </div>

      {/* Create Test Users Card */}
      <div className="bg-white rounded-lg p-6 border mb-6">
        <h2 className="text-xl font-semibold mb-4">✨ Create Test Users</h2>

        {/* Count Input */}
        <div className="mb-6">
          <label className="block text-sm font-semibold mb-2">
            Number of Users (1-1000)
          </label>
          <Input
            type="number"
            placeholder="100"
            value={count}
            onChange={(e) => setCount(e.target.value)}
            min="1"
            max="1000"
            className="max-w-xs"
          />
        </div>

        {/* Tier Distribution */}
        <div className="mb-6">
          <label className="block text-sm font-semibold mb-3">
            Tier Distribution (%)
          </label>
          <div className="space-y-3">
            {Object.entries(distribution).map(([tier, percentage]) => (
              <div key={tier} className="flex items-center gap-4">
                <label className="w-24 capitalize font-medium text-sm">
                  {tier}
                </label>
                <Input
                  type="number"
                  value={percentage}
                  onChange={(e) =>
                    updateDistribution(tier, parseFloat(e.target.value) || 0)
                  }
                  min="0"
                  max="100"
                  step="0.1"
                  className="w-32"
                />
                <span className="text-sm text-gray-600">%</span>
                <div className="flex-1 bg-gray-200 rounded-full h-2">
                  <div
                    className="bg-blue-500 h-2 rounded-full transition-all"
                    style={{ width: `${percentage}%` }}
                  />
                </div>
              </div>
            ))}
          </div>
          <div className="mt-3 text-sm">
            <span className="font-semibold">Total: </span>
            <span
              className={
                Math.abs(totalPercentage - 100) < 0.1
                  ? 'text-green-600 font-bold'
                  : 'text-red-600 font-bold'
              }
            >
              {totalPercentage.toFixed(1)}%
            </span>
            {Math.abs(totalPercentage - 100) >= 0.1 && (
              <span className="text-red-600 ml-2">(must equal 100%)</span>
            )}
          </div>
        </div>

        {/* Preview */}
        <div className="mb-6 p-4 bg-gray-50 rounded border">
          <p className="text-sm font-semibold mb-2">📊 Preview:</p>
          <div className="grid grid-cols-5 gap-2 text-xs">
            {Object.entries(distribution).map(([tier, percentage]) => {
              const userCount = Math.round((parseInt(count) || 0) * (percentage / 100));
              return (
                <div key={tier} className="text-center">
                  <p className="font-medium capitalize">{tier}</p>
                  <p className="text-gray-600">{userCount} users</p>
                </div>
              );
            })}
          </div>
        </div>

        {/* Create Button */}
        <Button
          onClick={handleCreateTestUsers}
          disabled={loading || Math.abs(totalPercentage - 100) >= 0.1}
          size="lg"
          className="w-full"
        >
          {loading ? '⏳ Creating...' : '✨ Create Test Users'}
        </Button>

        {/* Result */}
        {result && (
          <div className="mt-6 p-4 bg-green-50 rounded border border-green-200">
            <h3 className="font-semibold text-green-700 mb-2">
              ✅ Success!
            </h3>
            <p className="text-sm text-gray-700 mb-2">
              Created {result.createdCount} test users
            </p>
            {result.sampleUserIds && (
              <div className="mt-2">
                <p className="text-xs font-semibold text-gray-600 mb-1">
                  Sample User IDs:
                </p>
                <div className="space-y-1">
                  {result.sampleUserIds.map((id: string) => (
                    <p key={id} className="text-xs font-mono bg-white p-1 rounded">
                      {id}
                    </p>
                  ))}
                </div>
              </div>
            )}
          </div>
        )}
      </div>

      {/* Test Referral Flow Card */}
      <div className="bg-white rounded-lg p-6 border mb-6">
        <h2 className="text-xl font-semibold mb-4">🎁 Test Referral Flow</h2>
        <p className="text-sm text-gray-600 mb-4">
          Create a fake user via a referral link, then simulate spending 10 Energy
          to test if the referrer receives their bonus correctly.
        </p>

        {/* Bypass Anti-Fraud Toggle */}
        <div className="mb-6 p-4 bg-amber-50 rounded-lg border border-amber-200">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-semibold text-amber-800">
                🛡️ Bypass Anti-Fraud Check
              </p>
              <p className="text-xs text-amber-600 mt-1">
                Anti-fraud จะบล็อก test user ที่สร้างใหม่ (account &lt; 1 ชม.) — เปิดตัวนี้เพื่อ bypass สำหรับการ test
              </p>
            </div>
            <button
              type="button"
              role="switch"
              aria-checked={bypassFraud}
              onClick={() => setBypassFraud(!bypassFraud)}
              className={`relative inline-flex h-6 w-11 flex-shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-amber-500 focus:ring-offset-2 ${
                bypassFraud ? 'bg-amber-500' : 'bg-gray-200'
              }`}
            >
              <span
                className={`pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow ring-0 transition duration-200 ease-in-out ${
                  bypassFraud ? 'translate-x-5' : 'translate-x-0'
                }`}
              />
            </button>
          </div>
          {bypassFraud && (
            <p className="text-xs text-amber-700 mt-2 font-medium">
              ⚠️ เปิดอยู่ — จะใช้ Direct Write แทน Cloud Function (ข้าม anti-fraud)
            </p>
          )}
        </div>

        {/* Referral Code Input */}
        <div className="mb-6">
          <label className="block text-sm font-semibold mb-2">
            Referral Code (MiRO ID of Referrer)
          </label>
          <Input
            type="text"
            placeholder="MIRO-XXXX-XXXX-XXXX"
            value={referralCode}
            onChange={(e) => setReferralCode(e.target.value)}
            className="max-w-md"
          />
          <p className="text-xs text-gray-500 mt-1">
            Enter the MiRO ID of an existing user to test the referral system
          </p>
        </div>

        {/* Test Button */}
        <Button
          onClick={handleTestReferral}
          disabled={referralLoading || !referralCode.trim()}
          size="lg"
          className="w-full"
        >
          {referralLoading ? '⏳ Testing...' : '🧪 Create Referral Test User'}
        </Button>

        {/* Result */}
        {referralResult && (
          <div className="mt-6 p-4 bg-green-50 rounded border border-green-200">
            <h3 className="font-semibold text-green-700 mb-3">
              ✅ Referral Test Completed!
            </h3>
            
            {/* Fake User Info */}
            <div className="mb-4 p-3 bg-white rounded border">
              <p className="text-xs font-semibold text-gray-600 mb-2">
                📱 Created Fake User (Referee):
              </p>
              <p className="text-xs font-mono">
                <strong>Device ID:</strong> {referralResult.fakeUser?.deviceId}
              </p>
              <p className="text-xs font-mono">
                <strong>MiRO ID:</strong> {referralResult.fakeUser?.miroId}
              </p>
              <p className="text-xs text-green-600 font-semibold mt-2">
                💰 Bonus Received: +{referralResult.referee?.bonusReceived || 0}E
              </p>
            </div>

            {/* Referrer Info */}
            <div className="p-3 bg-white rounded border">
              <p className="text-xs font-semibold text-gray-600 mb-2">
                👤 Referrer:
              </p>
              <p className="text-xs font-mono">
                <strong>Device ID:</strong> {referralResult.referrer?.deviceId}
              </p>
              <p className="text-xs font-mono">
                <strong>MiRO ID:</strong> {referralResult.referrer?.miroId}
              </p>
              <p className="text-xs font-mono mt-2">
                <strong>Balance Before:</strong> {referralResult.referrer?.balanceBefore}E
              </p>
              <p className="text-xs font-mono">
                <strong>Balance After:</strong> {referralResult.referrer?.balanceAfter}E
              </p>
              <p className="text-xs text-green-600 font-semibold mt-2">
                💰 Bonus Received: +{referralResult.referrer?.bonusReceived || 0}E
              </p>
            </div>

            {/* Summary */}
            <div className="mt-3 p-3 bg-blue-50 rounded border border-blue-200">
              <p className="text-xs font-semibold text-blue-700 mb-1">
                📊 Test Flow Summary:
              </p>
              <ol className="text-xs text-gray-700 space-y-1 list-decimal list-inside">
                <li>Created fake user with referral code</li>
                <li>Referee received +{referralResult.referee?.bonusReceived || 0}E bonus</li>
                <li>Simulated spending 10 Energy</li>
                <li>Referrer received +{referralResult.referrer?.bonusReceived || 0}E reward</li>
              </ol>
              {referralResult.usedDirectWrite && (
                <p className="text-xs text-amber-600 font-medium mt-2">
                  🛡️ Used Direct Write (Anti-Fraud bypassed)
                </p>
              )}
            </div>
          </div>
        )}
      </div>

      {/* Random Data Info */}
      <div className="bg-blue-50 rounded-lg p-6 border border-blue-200">
        <h3 className="font-semibold mb-3">📝 Generated Data Details</h3>
        <ul className="space-y-2 text-sm text-gray-700">
          <li>• <strong>Device ID:</strong> Random test_xxxxxxxxx format</li>
          <li>• <strong>MiRO ID:</strong> MIRO-TEST1000 to MIRO-TEST1999</li>
          <li>• <strong>Balance:</strong> Random 0-1000E</li>
          <li>• <strong>Streak:</strong> Random 0-30 days</li>
          <li>• <strong>Total Spent:</strong> Based on tier + random 0-100E</li>
          <li>• <strong>Offers:</strong> All reset (unseen/unclaimed)</li>
          <li>• <strong>Subscription:</strong> None (free users)</li>
        </ul>
      </div>

      {/* Usage Tips */}
      <div className="mt-6 bg-green-50 rounded-lg p-6 border border-green-200">
        <h3 className="font-semibold mb-3">💡 Usage Tips</h3>
        <ul className="space-y-2 text-sm text-gray-700">
          <li>• Use for load testing analytics and reporting features</li>
          <li>• Test tier distribution charts and statistics</li>
          <li>• Simulate realistic user base for demo purposes</li>
          <li>• All test users have ID starting with "test_"</li>
          <li>• You can delete test users later with bulk actions</li>
        </ul>
      </div>

      {/* Warning */}
      <div className="mt-6 bg-yellow-50 rounded-lg p-6 border border-yellow-200">
        <h3 className="font-semibold text-yellow-800 mb-2">⚠️ Warning</h3>
        <p className="text-sm text-gray-700">
          Creating large numbers of users will consume Firestore write operations.
          Max 1000 users per batch. Test users are marked with "test_" prefix
          for easy identification and cleanup.
        </p>
      </div>
    </div>
  );
}
