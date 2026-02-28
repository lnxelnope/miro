'use client';

import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';

interface EnergyHistoryTabProps {
  user: any;
  deviceId: string;
  transactions: any[];
  onRefresh: () => void;
}

export function EnergyHistoryTab({ user, deviceId, transactions, onRefresh }: EnergyHistoryTabProps) {
  const [loading, setLoading] = useState(false);
  const [showAddForm, setShowAddForm] = useState(false);
  const [txType, setTxType] = useState<'earn' | 'spend'>('earn');
  const [txAmount, setTxAmount] = useState('');
  const [txNote, setTxNote] = useState('');

  const handleAddTransaction = async () => {
    const amount = parseInt(txAmount);
    if (!amount || amount <= 0) {
      alert('Please enter a valid amount');
      return;
    }

    setLoading(true);
    try {
      const res = await fetch(`/api/users/${deviceId}/add-transaction`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          type: txType,
          amount,
          source: 'manual_test',
          note: txNote || `Manual ${txType} by admin`,
        }),
      });
      const data = await res.json();

      if (res.ok && data.success) {
        alert(`✅ Transaction added: ${txType === 'earn' ? '+' : '-'}${amount}E`);
        setShowAddForm(false);
        setTxAmount('');
        setTxNote('');
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

  const handleQuickSpend = async (amount: number) => {
    if (!confirm(`Spend ${amount}E?`)) return;

    setLoading(true);
    try {
      const res = await fetch(`/api/users/${deviceId}/add-transaction`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          type: 'spend',
          amount,
          source: 'test_milestone',
          note: `Quick spend test (${amount}E)`,
        }),
      });
      const data = await res.json();

      if (res.ok && data.success) {
        alert(`✅ Spent ${amount}E for milestone testing`);
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

  // Calculate summary
  const totalEarned = transactions
    .filter(t => t.amount > 0)
    .reduce((sum, t) => sum + t.amount, 0);
  
  const totalSpent = transactions
    .filter(t => t.amount < 0)
    .reduce((sum, t) => sum + Math.abs(t.amount), 0);

  return (
    <div className="space-y-6">
      {/* Summary Stats */}
      <div className="grid grid-cols-3 gap-4">
        <div className="bg-green-50 rounded-lg p-4 border border-green-200">
          <p className="text-sm text-gray-600">💰 Total Earned</p>
          <p className="text-2xl font-bold text-green-600">+{totalEarned}E</p>
        </div>
        <div className="bg-red-50 rounded-lg p-4 border border-red-200">
          <p className="text-sm text-gray-600">📉 Total Spent</p>
          <p className="text-2xl font-bold text-red-600">-{totalSpent}E</p>
        </div>
        <div className="bg-blue-50 rounded-lg p-4 border border-blue-200">
          <p className="text-sm text-gray-600">💎 Current Balance</p>
          <p className="text-2xl font-bold text-blue-600">{user?.balance || 0}E</p>
        </div>
      </div>

      {/* Milestone Progress Simulator */}
      <div className="bg-purple-50 rounded-lg p-4 border border-purple-200">
        <h3 className="font-semibold mb-3">🏆 Milestone Progress Simulator</h3>
        <div className="mb-3">
          <p className="text-sm">Current Total Spent: <span className="font-bold">{user?.totalSpent || 0}E</span></p>
          <div className="mt-2 bg-white rounded p-2 text-xs">
            Next Milestones: 10E → 50E → 100E → 250E → 500E → 1,000E → 2,000E → 2,500E → 5,000E → 10,000E
          </div>
        </div>
        <div className="flex gap-2 flex-wrap">
          <Button onClick={() => handleQuickSpend(10)} variant="outline" size="sm" disabled={loading}>
            Spend +10E
          </Button>
          <Button onClick={() => handleQuickSpend(50)} variant="outline" size="sm" disabled={loading}>
            Spend +50E
          </Button>
          <Button onClick={() => handleQuickSpend(100)} variant="outline" size="sm" disabled={loading}>
            Spend +100E
          </Button>
          <Button onClick={() => handleQuickSpend(500)} variant="outline" size="sm" disabled={loading}>
            Spend +500E
          </Button>
        </div>
      </div>

      {/* Manual Transaction */}
      <div className="bg-white rounded-lg p-4 border">
        <div className="flex items-center justify-between mb-3">
          <h3 className="font-semibold">➕ Add Manual Transaction</h3>
          <Button
            onClick={() => setShowAddForm(!showAddForm)}
            variant="outline"
            size="sm"
          >
            {showAddForm ? 'Cancel' : '+ Add'}
          </Button>
        </div>

        {showAddForm && (
          <div className="space-y-3 bg-gray-50 p-4 rounded border">
            <div>
              <label className="text-sm font-medium">Type</label>
              <div className="flex gap-2 mt-1">
                <Button
                  onClick={() => setTxType('earn')}
                  variant={txType === 'earn' ? 'default' : 'outline'}
                  size="sm"
                >
                  💰 Earn
                </Button>
                <Button
                  onClick={() => setTxType('spend')}
                  variant={txType === 'spend' ? 'default' : 'outline'}
                  size="sm"
                >
                  📉 Spend
                </Button>
              </div>
            </div>
            <div>
              <label className="text-sm font-medium">Amount</label>
              <Input
                type="number"
                placeholder="100"
                value={txAmount}
                onChange={(e) => setTxAmount(e.target.value)}
                min="1"
              />
            </div>
            <div>
              <label className="text-sm font-medium">Note (optional)</label>
              <Input
                type="text"
                placeholder="Test transaction"
                value={txNote}
                onChange={(e) => setTxNote(e.target.value)}
              />
            </div>
            <Button onClick={handleAddTransaction} disabled={loading}>
              ✅ Add Transaction
            </Button>
          </div>
        )}
      </div>

      {/* Transaction History */}
      <div className="bg-white rounded-lg p-4 border">
        <div className="flex items-center justify-between mb-3">
          <h3 className="font-semibold">📋 Transaction History</h3>
          <span className="text-sm text-gray-600">{transactions.length} transactions</span>
        </div>

        <div className="space-y-2 max-h-96 overflow-y-auto">
          {transactions.length === 0 ? (
            <div className="text-center py-8 text-gray-500">
              <p>No transactions found</p>
            </div>
          ) : (
            transactions.map((tx) => (
              <div
                key={tx.id}
                className="flex items-start justify-between p-3 bg-gray-50 rounded hover:bg-gray-100 transition-colors"
              >
                <div className="flex-1">
                  <div className="flex items-center gap-2">
                    <span className={`text-lg ${tx.amount > 0 ? 'text-green-600' : 'text-red-600'}`}>
                      {tx.amount > 0 ? '💰' : '📉'}
                    </span>
                    <div>
                      <p className="font-medium text-sm">{tx.description || tx.type}</p>
                      <p className="text-xs text-gray-500">
                        {tx.createdAt ? new Date(tx.createdAt).toLocaleString() : 'Unknown date'}
                      </p>
                    </div>
                  </div>
                </div>
                <div className="text-right">
                  <p className={`text-lg font-bold ${tx.amount > 0 ? 'text-green-600' : 'text-red-600'}`}>
                    {tx.amount > 0 ? '+' : ''}{tx.amount}E
                  </p>
                  <p className="text-xs text-gray-500">
                    Balance: {tx.balanceAfter || 'N/A'}
                  </p>
                </div>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
}
