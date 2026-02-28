'use client';

import { useState } from 'react';

interface AdjustBalanceFormProps {
  userId: string;
  currentBalance: number;
  onSuccess: () => void;
}

export function AdjustBalanceForm({ userId, currentBalance, onSuccess }: AdjustBalanceFormProps) {
  const [amount, setAmount] = useState('');
  const [reason, setReason] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    const numAmount = parseInt(amount);
    if (isNaN(numAmount) || numAmount === 0) {
      alert('Please enter a valid amount');
      return;
    }

    if (!reason.trim()) {
      alert('Please provide a reason');
      return;
    }

    try {
      setIsSubmitting(true);
      const response = await fetch(`/api/users/${userId}/adjust-balance`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ amount: numAmount, reason }),
      });

      if (!response.ok) throw new Error('Failed to adjust balance');

      alert('Balance adjusted successfully');
      setAmount('');
      setReason('');
      onSuccess();
    } catch (error) {
      console.error('Adjust balance error:', error);
      alert('Failed to adjust balance');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <h3 className="font-semibold text-gray-900">Adjust Energy Balance</h3>
      <p className="text-sm text-gray-600">
        Current Balance: <span className="font-bold">{currentBalance} ⚡</span>
      </p>
      
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Amount (use negative for deduction)
        </label>
        <input
          type="number"
          value={amount}
          onChange={(e) => setAmount(e.target.value)}
          className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
          placeholder="+100 or -50"
          required
        />
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Reason
        </label>
        <textarea
          value={reason}
          onChange={(e) => setReason(e.target.value)}
          className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
          rows={3}
          placeholder="Explain why you're adjusting the balance..."
          required
        />
      </div>

      <button
        type="submit"
        disabled={isSubmitting}
        className="w-full px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 transition"
      >
        {isSubmitting ? 'Adjusting...' : 'Adjust Balance'}
      </button>
    </form>
  );
}
