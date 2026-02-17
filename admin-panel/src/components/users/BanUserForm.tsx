'use client';

import { useState } from 'react';

interface BanUserFormProps {
  userId: string;
  isBanned: boolean;
  onSuccess: () => void;
}

export function BanUserForm({ userId, isBanned, onSuccess }: BanUserFormProps) {
  const [reason, setReason] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleBanToggle = async () => {
    const newBanStatus = !isBanned;
    
    if (newBanStatus && !reason.trim()) {
      alert('Please provide a reason for banning');
      return;
    }

    const confirmed = confirm(
      newBanStatus
        ? 'Are you sure you want to BAN this user?'
        : 'Are you sure you want to UNBAN this user?'
    );

    if (!confirmed) return;

    try {
      setIsSubmitting(true);
      const response = await fetch(`/api/users/${userId}/ban`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ banned: newBanStatus, reason }),
      });

      if (!response.ok) throw new Error('Failed to update ban status');

      alert(newBanStatus ? 'User banned successfully' : 'User unbanned successfully');
      setReason('');
      onSuccess();
    } catch (error) {
      console.error('Ban user error:', error);
      alert('Failed to update ban status');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="space-y-4">
      <h3 className="font-semibold text-gray-900">Ban/Unban User</h3>
      <p className="text-sm text-gray-600">
        Current Status:{' '}
        <span className={`font-bold ${isBanned ? 'text-red-600' : 'text-green-600'}`}>
          {isBanned ? 'BANNED' : 'ACTIVE'}
        </span>
      </p>

      {!isBanned && (
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Ban Reason (required)
          </label>
          <textarea
            value={reason}
            onChange={(e) => setReason(e.target.value)}
            className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-red-500"
            rows={3}
            placeholder="Explain why you're banning this user..."
          />
        </div>
      )}

      <button
        onClick={handleBanToggle}
        disabled={isSubmitting}
        className={`w-full px-4 py-2 text-white rounded-lg transition disabled:opacity-50 ${
          isBanned
            ? 'bg-green-600 hover:bg-green-700'
            : 'bg-red-600 hover:bg-red-700'
        }`}
      >
        {isSubmitting
          ? 'Processing...'
          : isBanned
          ? 'Unban User'
          : 'Ban User'}
      </button>
    </div>
  );
}
