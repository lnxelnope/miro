'use client';

import { useEffect, useState } from 'react';
import { X, Zap, TrendingUp, Award, Users } from 'lucide-react';
import { formatDistanceToNow, format } from 'date-fns';
import { AdjustBalanceForm } from './AdjustBalanceForm';
import { BanUserForm } from './BanUserForm';

interface UserDetailModalProps {
  userId: string;
  isOpen: boolean;
  onClose: () => void;
  onUpdate: () => void;
}

export function UserDetailModal({ userId, isOpen, onClose, onUpdate }: UserDetailModalProps) {
  const [user, setUser] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [activeTab, setActiveTab] = useState<'overview' | 'transactions' | 'actions'>('overview');

  useEffect(() => {
    if (isOpen && userId) {
      fetchUserDetails();
    }
  }, [isOpen, userId]);

  const fetchUserDetails = async () => {
    try {
      setIsLoading(true);
      const response = await fetch(`/api/users/${userId}`);
      if (!response.ok) throw new Error('Failed to fetch user');
      const data = await response.json();
      setUser(data);
    } catch (error) {
      console.error('Fetch user error:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const handleBalanceAdjusted = () => {
    fetchUserDetails();
    onUpdate();
  };

  const handleBanStatusChanged = () => {
    fetchUserDetails();
    onUpdate();
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-xl shadow-2xl max-w-4xl w-full max-h-[90vh] overflow-hidden">
        {/* Header */}
        <div className="bg-gradient-to-r from-blue-600 to-blue-700 text-white p-6 flex items-center justify-between">
          <div>
            <h2 className="text-2xl font-bold">{user?.displayName || 'Loading...'}</h2>
            <p className="text-blue-100 text-sm mt-1">{user?.miroId}</p>
          </div>
          <button
            onClick={onClose}
            className="p-2 hover:bg-blue-500 rounded-lg transition"
          >
            <X className="w-6 h-6" />
          </button>
        </div>

        {/* Tabs */}
        <div className="border-b">
          <div className="flex space-x-4 px-6">
            {['overview', 'transactions', 'actions'].map((tab) => (
              <button
                key={tab}
                onClick={() => setActiveTab(tab as any)}
                className={`py-3 px-4 font-medium border-b-2 transition ${
                  activeTab === tab
                    ? 'border-blue-600 text-blue-600'
                    : 'border-transparent text-gray-500 hover:text-gray-700'
                }`}
              >
                {tab.charAt(0).toUpperCase() + tab.slice(1)}
              </button>
            ))}
          </div>
        </div>

        {/* Content */}
        <div className="p-6 overflow-y-auto max-h-[60vh]">
          {isLoading ? (
            <div className="space-y-4">
              {[1, 2, 3].map((i) => (
                <div key={i} className="animate-pulse">
                  <div className="h-4 bg-gray-200 rounded w-3/4 mb-2"></div>
                  <div className="h-4 bg-gray-200 rounded w-1/2"></div>
                </div>
              ))}
            </div>
          ) : (
            <>
              {activeTab === 'overview' && (
                <div className="space-y-6">
                  {/* Stats Cards */}
                  <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                    <div className="bg-blue-50 rounded-lg p-4">
                      <div className="flex items-center space-x-2 mb-2">
                        <Zap className="w-5 h-5 text-blue-600" />
                        <span className="text-sm text-blue-600 font-medium">Balance</span>
                      </div>
                      <p className="text-2xl font-bold text-blue-900">{user.balance}</p>
                    </div>
                    <div className="bg-green-50 rounded-lg p-4">
                      <div className="flex items-center space-x-2 mb-2">
                        <TrendingUp className="w-5 h-5 text-green-600" />
                        <span className="text-sm text-green-600 font-medium">Streak</span>
                      </div>
                      <p className="text-2xl font-bold text-green-900">
                        {user.gamification.currentStreak}
                      </p>
                    </div>
                    <div className="bg-purple-50 rounded-lg p-4">
                      <div className="flex items-center space-x-2 mb-2">
                        <Award className="w-5 h-5 text-purple-600" />
                        <span className="text-sm text-purple-600 font-medium">Tier</span>
                      </div>
                      <p className="text-lg font-bold text-purple-900 uppercase">
                        {user.gamification.streakTier}
                      </p>
                    </div>
                    <div className="bg-orange-50 rounded-lg p-4">
                      <div className="flex items-center space-x-2 mb-2">
                        <Users className="w-5 h-5 text-orange-600" />
                        <span className="text-sm text-orange-600 font-medium">Referrals</span>
                      </div>
                      <p className="text-2xl font-bold text-orange-900">{user.referralCount}</p>
                    </div>
                  </div>

                  {/* User Info */}
                  <div className="bg-gray-50 rounded-lg p-4 space-y-3">
                    <h3 className="font-semibold text-gray-900 mb-3">Account Information</h3>
                    <div className="grid grid-cols-2 gap-4 text-sm">
                      <div>
                        <span className="text-gray-600">Email:</span>
                        <p className="font-medium">{user.email}</p>
                      </div>
                      <div>
                        <span className="text-gray-600">Phone:</span>
                        <p className="font-medium">{user.phoneNumber || 'N/A'}</p>
                      </div>
                      <div>
                        <span className="text-gray-600">Joined:</span>
                        <p className="font-medium">
                          {user.createdAt
                            ? format(new Date(user.createdAt), 'PPP')
                            : 'Unknown'}
                        </p>
                      </div>
                      <div>
                        <span className="text-gray-600">Last Active:</span>
                        <p className="font-medium">
                          {user.lastActiveAt
                            ? formatDistanceToNow(new Date(user.lastActiveAt), {
                                addSuffix: true,
                              })
                            : 'Never'}
                        </p>
                      </div>
                    </div>
                  </div>

                  {/* Gamification Stats */}
                  <div className="bg-gray-50 rounded-lg p-4 space-y-3">
                    <h3 className="font-semibold text-gray-900 mb-3">Gamification Stats</h3>
                    <div className="grid grid-cols-2 gap-4 text-sm">
                      <div>
                        <span className="text-gray-600">Total Check-ins:</span>
                        <p className="font-medium">{user.gamification.totalCheckIns}</p>
                      </div>
                      <div>
                        <span className="text-gray-600">Longest Streak:</span>
                        <p className="font-medium">{user.gamification.longestStreak} days</p>
                      </div>
                      <div>
                        <span className="text-gray-600">Energy Earned:</span>
                        <p className="font-medium">{user.lifetimeEnergyEarned} ⚡</p>
                      </div>
                      <div>
                        <span className="text-gray-600">Energy Spent:</span>
                        <p className="font-medium">{user.lifetimeEnergySpent} ⚡</p>
                      </div>
                      <div>
                        <span className="text-gray-600">AI Analyses:</span>
                        <p className="font-medium">{user.totalAiAnalyses}</p>
                      </div>
                    </div>
                  </div>
                </div>
              )}

              {activeTab === 'transactions' && (
                <div className="space-y-3">
                  <h3 className="font-semibold text-gray-900 mb-4">
                    Transaction History (Last 50)
                  </h3>
                  {user.transactions.length === 0 ? (
                    <p className="text-gray-500 text-center py-8">No transactions yet</p>
                  ) : (
                    <div className="space-y-2">
                      {user.transactions.map((tx: any) => (
                        <div
                          key={tx.id}
                          className="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
                        >
                          <div className="flex-1">
                            <p className="font-medium text-sm">
                              {tx.description || tx.type.replace(/_/g, ' ')}
                            </p>
                            <p className="text-xs text-gray-500">
                              {format(new Date(tx.createdAt), 'PPpp')}
                            </p>
                          </div>
                          <span
                            className={`font-bold ${
                              tx.amount > 0 ? 'text-green-600' : 'text-red-600'
                            }`}
                          >
                            {tx.amount > 0 ? '+' : ''}
                            {tx.amount} ⚡
                          </span>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              )}

              {activeTab === 'actions' && (
                <div className="space-y-6">
                  <AdjustBalanceForm
                    userId={userId}
                    currentBalance={user.balance}
                    onSuccess={handleBalanceAdjusted}
                  />
                  <div className="border-t pt-6">
                    <button
                      onClick={async () => {
                        if (
                          confirm('Are you sure you want to reset this user\'s streak?')
                        ) {
                          const res = await fetch(`/api/users/${userId}/reset-streak`, {
                            method: 'POST',
                          });
                          if (res.ok) {
                            alert('Streak reset successfully');
                            handleBalanceAdjusted();
                          }
                        }
                      }}
                      className="px-4 py-2 bg-yellow-500 text-white rounded-lg hover:bg-yellow-600 transition"
                    >
                      Reset Streak
                    </button>
                  </div>
                  <div className="border-t pt-6">
                    <BanUserForm
                      userId={userId}
                      isBanned={user.isBanned}
                      onSuccess={handleBanStatusChanged}
                    />
                  </div>
                </div>
              )}
            </>
          )}
        </div>
      </div>
    </div>
  );
}
