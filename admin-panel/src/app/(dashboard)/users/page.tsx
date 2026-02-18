'use client';

import { useState } from 'react';
import { UserSearch } from '@/components/users/UserSearch';
import { UserDetailModal } from '@/components/users/UserDetailModal';
import { Button } from '@/components/ui/button';

export default function UsersPage() {
  const [selectedUser, setSelectedUser] = useState<any>(null);
  const [showModal, setShowModal] = useState(false);

  const handleUserFound = (user: any) => {
    setSelectedUser(user);
    setShowModal(true);
  };

  const handleRefresh = () => {
    if (selectedUser) {
      fetch(`/api/users/search?q=${selectedUser.miroId}`)
        .then((res) => res.json())
        .then((data) => {
          if (data.success) setSelectedUser(data.user);
        });
    }
  };

  return (
    <div className="p-8">
      <h1 className="text-3xl font-bold mb-6">👥 User Management</h1>

      <div className="bg-white rounded-lg shadow p-6">
        <UserSearch onUserFound={handleUserFound} />

        {selectedUser && (
          <div className="mt-6 p-4 bg-gray-50 rounded">
            <h3 className="font-semibold mb-2">Found User:</h3>
            <div className="grid grid-cols-2 gap-2 text-sm">
              <p><strong>MiRO ID:</strong> {selectedUser.miroId}</p>
              <p><strong>Balance:</strong> ⚡ {selectedUser.balance}</p>
              <p><strong>Tier:</strong> {selectedUser.tier}</p>
              <p><strong>Streak:</strong> {selectedUser.currentStreak} days</p>
            </div>
            <Button onClick={() => setShowModal(true)} className="mt-4">
              View Details →
            </Button>
          </div>
        )}
      </div>

      {/* User Detail Modal */}
      {selectedUser && (
        <UserDetailModal
          deviceId={selectedUser.deviceId}
          open={showModal}
          onClose={() => setShowModal(false)}
          onRefresh={handleRefresh}
        />
      )}
    </div>
  );
}
