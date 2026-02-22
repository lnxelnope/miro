'use client';

import { useEffect, useState } from 'react';
import { Button } from '@/components/ui/button';
import { ProfileTab } from './user-detail-tabs/ProfileTab';
import { EnergyHistoryTab } from './user-detail-tabs/EnergyHistoryTab';
import { OffersTab } from './user-detail-tabs/OffersTab';
import { SubscriptionTab } from './user-detail-tabs/SubscriptionTab';
import { GamificationTab } from './user-detail-tabs/GamificationTab';

interface UserDetailModalProps {
  deviceId: string;
  open: boolean;
  onClose: () => void;
  onRefresh?: () => void;
}

type TabType = 'profile' | 'energy' | 'offers' | 'subscription' | 'gamification';

export function UserDetailModal({ deviceId, open, onClose, onRefresh }: UserDetailModalProps) {
  const [user, setUser] = useState<any>(null);
  const [transactions, setTransactions] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState<TabType>('profile');
  const [refreshKey, setRefreshKey] = useState(0);

  useEffect(() => {
    if (!open || !deviceId) return;

    loadUserData();
  }, [open, deviceId, refreshKey]);

  const loadUserData = async () => {
    setLoading(true);
    try {
      const res = await fetch(`/api/users/${deviceId}`);
      const data = await res.json();
      
      if (data.success) {
        setUser(data.user);
        setTransactions(data.transactions || []);
      }
    } catch (err) {
      console.error('Failed to load user data:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleRefreshUser = () => {
    setRefreshKey(prev => prev + 1);
    onRefresh?.();
  };

  if (!open) return null;

  const tabs = [
    { id: 'profile', label: '👤 Profile', icon: '👤' },
    { id: 'energy', label: '⚡ Energy History', icon: '⚡' },
    { id: 'offers', label: '🎁 Offers', icon: '🎁' },
    { id: 'subscription', label: '💎 Subscription', icon: '💎' },
    { id: 'gamification', label: '🏆 Gamification', icon: '🏆' },
  ];

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
      <div className="bg-white rounded-lg shadow-lg max-w-6xl w-full max-h-[90vh] overflow-hidden m-4 flex flex-col">
        {/* Header */}
        <div className="p-6 border-b flex justify-between items-center bg-gradient-to-r from-blue-50 to-purple-50">
          <div>
            <h2 className="text-2xl font-bold">👤 User Details</h2>
            <p className="text-sm text-gray-600">
              {user?.miroId || deviceId}
              {user?.isBanned && <span className="ml-2 text-red-600 font-semibold">🚫 BANNED</span>}
            </p>
          </div>
          <button
            onClick={onClose}
            className="text-gray-500 hover:text-gray-700 text-3xl font-light leading-none"
          >
            ×
          </button>
        </div>

        {/* Tabs Navigation */}
        <div className="border-b bg-gray-50">
          <div className="flex overflow-x-auto">
            {tabs.map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id as TabType)}
                className={`px-6 py-3 font-medium whitespace-nowrap transition-colors ${
                  activeTab === tab.id
                    ? 'border-b-2 border-blue-500 text-blue-600 bg-white'
                    : 'text-gray-600 hover:text-gray-900 hover:bg-gray-100'
                }`}
              >
                {tab.label}
              </button>
            ))}
          </div>
        </div>

        {/* Tab Content */}
        <div className="flex-1 overflow-y-auto p-6">
          {loading ? (
            <div className="text-center py-12">
              <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"></div>
              <p className="mt-2 text-gray-600">Loading...</p>
            </div>
          ) : (
            <>
              {activeTab === 'profile' && (
                <ProfileTab
                  user={user}
                  deviceId={deviceId}
                  onRefresh={handleRefreshUser}
                />
              )}
              {activeTab === 'energy' && (
                <EnergyHistoryTab
                  user={user}
                  deviceId={deviceId}
                  transactions={transactions}
                  onRefresh={handleRefreshUser}
                />
              )}
              {activeTab === 'offers' && (
                <OffersTab
                  user={user}
                  deviceId={deviceId}
                  onRefresh={handleRefreshUser}
                />
              )}
              {activeTab === 'subscription' && (
                <SubscriptionTab
                  user={user}
                  deviceId={deviceId}
                  onRefresh={handleRefreshUser}
                />
              )}
              {activeTab === 'gamification' && (
                <GamificationTab
                  user={user}
                  deviceId={deviceId}
                  onRefresh={handleRefreshUser}
                />
              )}
            </>
          )}
        </div>

        {/* Footer */}
        <div className="p-4 border-t bg-gray-50 flex justify-between items-center">
          <div className="text-sm text-gray-600">
            Last Updated: {user?.lastUpdated ? new Date(user.lastUpdated).toLocaleString() : 'N/A'}
          </div>
          <div className="flex gap-2">
            <Button onClick={handleRefreshUser} variant="outline" size="sm">
              🔄 Refresh
            </Button>
            <Button onClick={onClose} size="sm">
              Close
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
}
