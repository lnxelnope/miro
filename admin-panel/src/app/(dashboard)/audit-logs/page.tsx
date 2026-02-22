'use client';

import { useEffect, useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';

interface AuditLog {
  id: string;
  action: string;
  adminEmail: string;
  targetUserId: string | null;
  targetMiroId: string | null;
  previousState: any;
  newState: any;
  details: any;
  timestamp: string | null;
}

export default function AuditLogsPage() {
  const [logs, setLogs] = useState<AuditLog[]>([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('');
  const [actionFilter, setActionFilter] = useState('');

  useEffect(() => {
    loadLogs();
  }, []);

  const loadLogs = async () => {
    setLoading(true);
    try {
      const params = new URLSearchParams({
        limit: '100',
      });

      if (actionFilter) {
        params.append('action', actionFilter);
      }

      const res = await fetch(`/api/admin/audit-logs?${params}`);
      const data = await res.json();

      if (data.success) {
        setLogs(data.logs);
      }
    } catch (err) {
      console.error('Failed to load logs:', err);
    } finally {
      setLoading(false);
    }
  };

  const getActionLabel = (action: string) => {
    const labels: Record<string, { label: string; icon: string; color: string }> = {
      reset_user_to_new: { label: 'Reset to New', icon: '🔄', color: 'bg-red-100 text-red-700' },
      set_tier: { label: 'Set Tier', icon: '🎚️', color: 'bg-purple-100 text-purple-700' },
      set_streak: { label: 'Set Streak', icon: '🔥', color: 'bg-orange-100 text-orange-700' },
      reset_offers: { label: 'Reset Offers', icon: '🎁', color: 'bg-yellow-100 text-yellow-700' },
      reset_milestones: { label: 'Reset Milestones', icon: '🏆', color: 'bg-blue-100 text-blue-700' },
      add_transaction: { label: 'Add Transaction', icon: '💰', color: 'bg-green-100 text-green-700' },
      apply_scenario: { label: 'Apply Scenario', icon: '🧪', color: 'bg-indigo-100 text-indigo-700' },
      bulk_create_test_users: { label: 'Bulk Create', icon: '👥', color: 'bg-teal-100 text-teal-700' },
    };

    return labels[action] || { label: action, icon: '📝', color: 'bg-gray-100 text-gray-700' };
  };

  const filteredLogs = logs.filter((log) => {
    if (!filter) return true;
    const searchLower = filter.toLowerCase();
    return (
      log.targetUserId?.toLowerCase().includes(searchLower) ||
      log.targetMiroId?.toLowerCase().includes(searchLower) ||
      log.action.toLowerCase().includes(searchLower)
    );
  });

  return (
    <div className="p-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold mb-2">📋 Audit Logs</h1>
        <p className="text-gray-600">
          Track all admin actions and changes made in the system
        </p>
      </div>

      {/* Filters */}
      <div className="bg-white rounded-lg p-4 border mb-6">
        <div className="flex gap-4">
          <div className="flex-1">
            <label className="text-sm font-medium mb-1 block">Search</label>
            <Input
              type="text"
              placeholder="Search by User ID, MiRO ID, or action..."
              value={filter}
              onChange={(e) => setFilter(e.target.value)}
            />
          </div>
          <div className="w-64">
            <label className="text-sm font-medium mb-1 block">Action Type</label>
            <select
              value={actionFilter}
              onChange={(e) => {
                setActionFilter(e.target.value);
                loadLogs();
              }}
              className="w-full px-3 py-2 border rounded-md"
            >
              <option value="">All Actions</option>
              <option value="reset_user_to_new">Reset to New</option>
              <option value="set_tier">Set Tier</option>
              <option value="set_streak">Set Streak</option>
              <option value="reset_offers">Reset Offers</option>
              <option value="reset_milestones">Reset Milestones</option>
              <option value="add_transaction">Add Transaction</option>
              <option value="apply_scenario">Apply Scenario</option>
              <option value="bulk_create_test_users">Bulk Create</option>
            </select>
          </div>
          <div className="flex items-end">
            <Button onClick={loadLogs} variant="outline">
              🔄 Refresh
            </Button>
          </div>
        </div>
      </div>

      {/* Logs Table */}
      <div className="bg-white rounded-lg border overflow-hidden">
        {loading ? (
          <div className="text-center py-12">
            <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"></div>
            <p className="mt-2 text-gray-600">Loading logs...</p>
          </div>
        ) : filteredLogs.length === 0 ? (
          <div className="text-center py-12 text-gray-500">
            <p>No audit logs found</p>
          </div>
        ) : (
          <table className="w-full">
            <thead className="bg-gray-50 border-b">
              <tr>
                <th className="text-left p-3 text-sm font-semibold">Time</th>
                <th className="text-left p-3 text-sm font-semibold">Action</th>
                <th className="text-left p-3 text-sm font-semibold">Target User</th>
                <th className="text-left p-3 text-sm font-semibold">Details</th>
              </tr>
            </thead>
            <tbody>
              {filteredLogs.map((log) => {
                const actionInfo = getActionLabel(log.action);
                return (
                  <tr key={log.id} className="border-b hover:bg-gray-50">
                    <td className="p-3 text-sm text-gray-600">
                      {log.timestamp
                        ? new Date(log.timestamp).toLocaleString()
                        : 'N/A'}
                    </td>
                    <td className="p-3">
                      <span
                        className={`inline-flex items-center gap-1 px-2 py-1 rounded text-xs font-semibold ${actionInfo.color}`}
                      >
                        <span>{actionInfo.icon}</span>
                        {actionInfo.label}
                      </span>
                    </td>
                    <td className="p-3 text-sm">
                      {log.targetMiroId && (
                        <p className="font-semibold">{log.targetMiroId}</p>
                      )}
                      {log.targetUserId && (
                        <p className="text-xs text-gray-500 font-mono">
                          {log.targetUserId}
                        </p>
                      )}
                      {!log.targetUserId && !log.targetMiroId && (
                        <span className="text-gray-400">-</span>
                      )}
                    </td>
                    <td className="p-3 text-sm">
                      {log.previousState && log.newState && (
                        <details className="cursor-pointer">
                          <summary className="text-blue-600 hover:text-blue-800">
                            View Changes
                          </summary>
                          <div className="mt-2 p-2 bg-gray-50 rounded text-xs space-y-1">
                            <div>
                              <strong>Before:</strong>
                              <pre className="mt-1 text-xs">
                                {JSON.stringify(log.previousState, null, 2)}
                              </pre>
                            </div>
                            <div>
                              <strong>After:</strong>
                              <pre className="mt-1 text-xs">
                                {JSON.stringify(log.newState, null, 2)}
                              </pre>
                            </div>
                          </div>
                        </details>
                      )}
                      {log.details && !log.previousState && (
                        <details className="cursor-pointer">
                          <summary className="text-blue-600 hover:text-blue-800">
                            View Details
                          </summary>
                          <div className="mt-2 p-2 bg-gray-50 rounded text-xs">
                            <pre>{JSON.stringify(log.details, null, 2)}</pre>
                          </div>
                        </details>
                      )}
                      {!log.previousState && !log.details && (
                        <span className="text-gray-400">No details</span>
                      )}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        )}
      </div>

      {/* Info */}
      <div className="mt-6 bg-blue-50 rounded-lg p-4 border border-blue-200">
        <h3 className="font-semibold mb-2">📝 About Audit Logs</h3>
        <p className="text-sm text-gray-700">
          All admin actions are automatically logged here for security and
          debugging purposes. Logs include the action type, target user,
          before/after states, and timestamp. This helps track who made what
          changes and when.
        </p>
      </div>
    </div>
  );
}
