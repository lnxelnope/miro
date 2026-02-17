'use client';

import { useEffect, useState } from 'react';
import { UsersTable } from '@/components/users/UsersTable';
import { UserDetailModal } from '@/components/users/UserDetailModal';
import { Search, Filter } from 'lucide-react';

export default function UsersPage() {
  const [users, setUsers] = useState([]);
  const [pagination, setPagination] = useState({
    page: 1,
    totalPages: 1,
  });
  const [searchQuery, setSearchQuery] = useState('');
  const [tierFilter, setTierFilter] = useState('all');
  const [isLoading, setIsLoading] = useState(true);
  const [selectedUserId, setSelectedUserId] = useState<string | null>(null);

  useEffect(() => {
    fetchUsers();
  }, [pagination.page, searchQuery, tierFilter]);

  const fetchUsers = async () => {
    try {
      setIsLoading(true);
      const params = new URLSearchParams({
        page: pagination.page.toString(),
        search: searchQuery,
        tier: tierFilter,
      });

      const response = await fetch(`/api/users/list?${params}`);
      if (!response.ok) throw new Error('Failed to fetch users');

      const data = await response.json();
      setUsers(data.users);
      setPagination(data.pagination);
    } catch (error) {
      console.error('Fetch users error:', error);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900">User Management</h1>
          <p className="text-gray-600 mt-2">Manage and monitor all MiRO users</p>
        </div>

        {/* Search & Filters */}
        <div className="bg-white rounded-xl shadow p-4 mb-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="relative">
              <Search className="absolute left-3 top-3 w-5 h-5 text-gray-400" />
              <input
                type="text"
                placeholder="Search by MiRO ID, email, or name..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="w-full pl-10 pr-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
              />
            </div>
            <div className="relative">
              <Filter className="absolute left-3 top-3 w-5 h-5 text-gray-400" />
              <select
                value={tierFilter}
                onChange={(e) => setTierFilter(e.target.value)}
                className="w-full pl-10 pr-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 appearance-none"
              >
                <option value="all">All Tiers</option>
                <option value="bronze">Bronze</option>
                <option value="silver">Silver</option>
                <option value="gold">Gold</option>
                <option value="diamond">Diamond</option>
                <option value="none">No Streak</option>
              </select>
            </div>
          </div>
        </div>

        {/* Users Table */}
        <UsersTable
          users={users}
          totalPages={pagination.totalPages}
          currentPage={pagination.page}
          onPageChange={(page) => setPagination({ ...pagination, page })}
          onUserClick={setSelectedUserId}
          isLoading={isLoading}
        />

        {/* User Detail Modal */}
        {selectedUserId && (
          <UserDetailModal
            userId={selectedUserId}
            isOpen={!!selectedUserId}
            onClose={() => setSelectedUserId(null)}
            onUpdate={fetchUsers}
          />
        )}
      </div>
    </div>
  );
}
