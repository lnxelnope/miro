'use client';

import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';

interface ProfileTabProps {
  user: any;
  deviceId: string;
  onRefresh: () => void;
}

export function ProfileTab({ user, deviceId, onRefresh }: ProfileTabProps) {
  const [loading, setLoading] = useState(false);
  const [showBalanceAdjust, setShowBalanceAdjust] = useState(false);
  const [balanceAmount, setBalanceAmount] = useState('');
  const [balanceNote, setBalanceNote] = useState('');

  const handleResetToNew = async () => {
    if (!confirm('⚠️ Reset user to NEW state? This will clear ALL data (balance, tier, streak, offers, milestones)!')) {
      return;
    }

    setLoading(true);
    try {
      const res = await fetch(`/api/users/${deviceId}/reset-to-new`, {
        method: 'POST',
      });
      const data = await res.json();

      if (res.ok && data.success) {
        alert('✅ User reset to new state successfully!');
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

  const handleFactoryReset = async () => {
    const confirmed = confirm(
      '🚨 FACTORY RESET: ลบ user document ทั้งก้อน + transactions ทั้งหมด!\n\n' +
      'เหมือน install ครั้งแรกเลย — เปิดแอปครั้งถัดไปจะสร้าง account ใหม่\n\n' +
      '⚠️ ต้องเคลียร์ App Data บนมือถือด้วย (Settings > Apps > MiRO > Clear Data)\n\n' +
      'ดำเนินการต่อ?'
    );
    if (!confirmed) return;

    setLoading(true);
    try {
      const res = await fetch(`/api/users/${deviceId}/factory-reset`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ deleteTransactions: true }),
      });
      const data = await res.json();

      if (res.ok && data.success) {
        alert(
          `✅ Factory Reset สำเร็จ!\n\n` +
          `${data.message}\n\n` +
          `📱 อย่าลืม: เคลียร์ App Data บนมือถือด้วย\n` +
          `(Settings > Apps > MiRO > Clear Data)`
        );
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

  const handleSetTier = async (tier: string) => {
    if (!confirm(`Set user tier to ${tier.toUpperCase()}?`)) return;

    setLoading(true);
    try {
      const res = await fetch(`/api/users/${deviceId}/set-tier`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ tier }),
      });
      const data = await res.json();

      if (res.ok && data.success) {
        alert(`✅ Tier set to ${tier}!`);
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

  const handleAdjustBalance = async () => {
    const amount = parseInt(balanceAmount);
    if (!amount || amount === 0) {
      alert('Please enter a valid amount (+/- number)');
      return;
    }

    setLoading(true);
    try {
      const res = await fetch(`/api/users/${deviceId}/adjust-balance`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ 
          amount, 
          reason: balanceNote || 'Admin adjustment' 
        }),
      });
      const data = await res.json();

      if (res.ok && data.success) {
        alert(`✅ Balance adjusted by ${amount > 0 ? '+' : ''}${amount}E!`);
        setShowBalanceAdjust(false);
        setBalanceAmount('');
        setBalanceNote('');
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
          lastCheckInDate: new Date().toISOString().split('T')[0]
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

  const handleBanToggle = async () => {
    const isBanned = !user?.isBanned;
    const action = isBanned ? 'Ban' : 'Unban';
    const reason = prompt(`Reason for ${action}:`);
    if (!reason) return;

    setLoading(true);
    try {
      const res = await fetch(`/api/users/${deviceId}/ban`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ isBanned, reason }),
      });
      const data = await res.json();

      if (res.ok && data.success) {
        alert(`✅ User ${action}ned!`);
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

  return (
    <div className="space-y-6">
      {/* User Info Card */}
      <div className="bg-gradient-to-br from-blue-50 to-indigo-50 rounded-lg p-6 border border-blue-200">
        <h3 className="text-lg font-semibold mb-4">📧 User Information</h3>
        <div className="grid grid-cols-2 gap-4">
          <div>
            <p className="text-sm text-gray-600">Device ID</p>
            <p className="font-mono text-sm break-all">{deviceId}</p>
          </div>
          <div>
            <p className="text-sm text-gray-600">MiRO ID</p>
            <p className="font-semibold">{user?.miroId || 'N/A'}</p>
          </div>
          <div>
            <p className="text-sm text-gray-600">Created At</p>
            <p className="text-sm">{user?.createdAt ? new Date(user.createdAt).toLocaleString() : 'N/A'}</p>
          </div>
          <div>
            <p className="text-sm text-gray-600">Status</p>
            <p className={`font-semibold ${user?.isBanned ? 'text-red-600' : 'text-green-600'}`}>
              {user?.isBanned ? '🚫 Banned' : '✅ Active'}
            </p>
          </div>
        </div>
      </div>

      {/* Current Stats */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <div className="bg-white rounded-lg p-4 border shadow-sm">
          <p className="text-sm text-gray-600">⚡ Balance</p>
          <p className="text-3xl font-bold text-blue-600">{user?.balance || 0}</p>
        </div>
        <div className="bg-white rounded-lg p-4 border shadow-sm">
          <p className="text-sm text-gray-600">🎯 Tier</p>
          <p className="text-2xl font-bold capitalize">{user?.tier || 'starter'}</p>
        </div>
        <div className="bg-white rounded-lg p-4 border shadow-sm">
          <p className="text-sm text-gray-600">🔥 Streak</p>
          <p className="text-3xl font-bold text-orange-600">{user?.currentStreak || 0}</p>
        </div>
        <div className="bg-white rounded-lg p-4 border shadow-sm">
          <p className="text-sm text-gray-600">📊 Total Spent</p>
          <p className="text-2xl font-bold text-purple-600">{user?.totalSpent || 0}E</p>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="bg-white rounded-lg p-6 border">
        <h3 className="text-lg font-semibold mb-4">⚡ Quick Actions (Testing)</h3>
        
        <div className="space-y-4">
          {/* Reset to New */}
          <div className="flex items-center justify-between p-3 bg-red-50 rounded border border-red-200">
            <div>
              <p className="font-semibold">🔄 Reset to New User</p>
              <p className="text-sm text-gray-600">รีเซ็ตค่าทั้งหมดเป็น 0 (document ยังอยู่)</p>
            </div>
            <Button onClick={handleResetToNew} variant="destructive" disabled={loading}>
              Reset
            </Button>
          </div>

          {/* Factory Reset */}
          <div className="flex items-center justify-between p-3 bg-red-100 rounded border-2 border-red-400">
            <div>
              <p className="font-semibold text-red-800">🚨 Factory Reset (ลบทั้งหมด)</p>
              <p className="text-sm text-red-700">ลบ user document + transactions ทั้งก้อน = เหมือน install ครั้งแรก</p>
              <p className="text-xs text-red-500 mt-1">⚠️ ต้อง Clear App Data บนมือถือด้วย</p>
            </div>
            <Button onClick={handleFactoryReset} variant="destructive" disabled={loading}>
              Factory Reset
            </Button>
          </div>

          {/* Set Tier */}
          <div className="p-3 bg-purple-50 rounded border border-purple-200">
            <p className="font-semibold mb-2">🎚️ Set Tier</p>
            <div className="flex gap-2 flex-wrap">
              {['starter', 'bronze', 'silver', 'gold', 'diamond'].map((tier) => (
                <Button
                  key={tier}
                  onClick={() => handleSetTier(tier)}
                  variant="outline"
                  size="sm"
                  disabled={loading}
                  className="capitalize"
                >
                  {tier}
                </Button>
              ))}
            </div>
          </div>

          {/* Adjust Balance */}
          <div className="p-3 bg-blue-50 rounded border border-blue-200">
            <div className="flex items-center justify-between mb-2">
              <p className="font-semibold">⚡ Adjust Balance</p>
              <Button
                onClick={() => setShowBalanceAdjust(!showBalanceAdjust)}
                variant="outline"
                size="sm"
              >
                {showBalanceAdjust ? 'Cancel' : 'Adjust'}
              </Button>
            </div>
            {showBalanceAdjust && (
              <div className="space-y-2 mt-3">
                <Input
                  type="number"
                  placeholder="Amount (+100 or -50)"
                  value={balanceAmount}
                  onChange={(e) => setBalanceAmount(e.target.value)}
                />
                <Input
                  type="text"
                  placeholder="Note (optional)"
                  value={balanceNote}
                  onChange={(e) => setBalanceNote(e.target.value)}
                />
                <Button onClick={handleAdjustBalance} disabled={loading} size="sm">
                  Apply
                </Button>
              </div>
            )}
          </div>

          {/* Set Streak */}
          <div className="p-3 bg-orange-50 rounded border border-orange-200">
            <p className="font-semibold mb-2">🔥 Set Streak</p>
            <div className="flex gap-2 flex-wrap">
              {[0, 7, 15, 30].map((days) => (
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

          {/* Ban/Unban */}
          <div className="flex items-center justify-between p-3 bg-gray-50 rounded border">
            <div>
              <p className="font-semibold">🔒 Ban/Unban User</p>
              <p className="text-sm text-gray-600">Block or unblock user access</p>
            </div>
            <Button
              onClick={handleBanToggle}
              variant={user?.isBanned ? 'default' : 'destructive'}
              disabled={loading}
            >
              {user?.isBanned ? '✅ Unban' : '🚫 Ban'}
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
}
