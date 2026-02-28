'use client';

import { useEffect, useState } from 'react';
import { AlertTriangle, CheckCircle, XCircle, Ban } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { format } from 'date-fns';

interface FraudAlert {
  id: string;
  deviceId: string;
  action: string;
  reason: string;
  severity: 'low' | 'medium' | 'high';
  metadata: Record<string, any>;
  status: 'pending' | 'reviewed' | 'dismissed' | 'confirmed';
  createdAt: string;
  reviewedBy?: string;
  reviewedAt?: string;
  reviewReason?: string;
}

export default function FraudPage() {
  const [alerts, setAlerts] = useState<FraudAlert[]>([]);
  const [filter, setFilter] = useState<'all' | 'pending' | 'reviewed' | 'dismissed' | 'confirmed'>('pending');
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchAlerts();
  }, [filter]);

  const fetchAlerts = async () => {
    try {
      setIsLoading(true);
      setError(null);
      const response = await fetch(`/api/fraud?status=${filter}`);
      
      if (!response.ok) {
        throw new Error('Failed to fetch fraud alerts');
      }

      const data = await response.json();
      setAlerts(data.alerts || []);
    } catch (err: any) {
      console.error('Fetch alerts error:', err);
      setError(err.message || 'Failed to load fraud alerts');
    } finally {
      setIsLoading(false);
    }
  };

  const handleReview = async (alertId: string, action: 'dismiss' | 'confirm' | 'ban', reason?: string) => {
    try {
      const response = await fetch(`/api/fraud/${alertId}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action, reason }),
      });

      if (!response.ok) {
        throw new Error('Failed to review alert');
      }

      // Refresh alerts
      await fetchAlerts();
    } catch (err: any) {
      console.error('Review error:', err);
      alert(`Failed to ${action} alert: ${err.message}`);
    }
  };

  const getSeverityColor = (severity: string) => {
    switch (severity) {
      case 'high':
        return 'bg-red-100 text-red-800';
      case 'medium':
        return 'bg-yellow-100 text-yellow-800';
      case 'low':
        return 'bg-blue-100 text-blue-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'pending':
        return 'bg-orange-100 text-orange-800';
      case 'confirmed':
        return 'bg-red-100 text-red-800';
      case 'dismissed':
        return 'bg-gray-100 text-gray-800';
      case 'reviewed':
        return 'bg-blue-100 text-blue-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  const filterCounts = {
    all: alerts.length,
    pending: alerts.filter((a) => a.status === 'pending').length,
    reviewed: alerts.filter((a) => a.status === 'reviewed').length,
    dismissed: alerts.filter((a) => a.status === 'dismissed').length,
    confirmed: alerts.filter((a) => a.status === 'confirmed').length,
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900 flex items-center gap-3">
            <AlertTriangle className="w-8 h-8 text-red-600" />
            Fraud Alerts
          </h1>
          <p className="text-gray-600 mt-2">
            Monitor and review suspicious user activities
          </p>
        </div>

        {/* Filter Tabs */}
        <div className="mb-6 flex gap-2 flex-wrap">
          {(['all', 'pending', 'reviewed', 'dismissed', 'confirmed'] as const).map((status) => (
            <button
              key={status}
              onClick={() => setFilter(status)}
              className={`
                px-4 py-2 rounded-lg font-medium transition-colors
                ${filter === status
                  ? 'bg-blue-600 text-white'
                  : 'bg-white text-gray-700 hover:bg-gray-100'
                }
              `}
            >
              {status.charAt(0).toUpperCase() + status.slice(1)} ({filterCounts[status]})
            </button>
          ))}
        </div>

        {/* Error Message */}
        {error && (
          <div className="bg-red-50 border border-red-200 rounded-lg p-4 mb-6">
            <p className="text-red-800">{error}</p>
          </div>
        )}

        {/* Alerts List */}
        {isLoading ? (
          <div className="space-y-4">
            {[1, 2, 3].map((i) => (
              <div key={i} className="bg-white rounded-xl shadow p-6 animate-pulse">
                <div className="h-4 bg-gray-200 rounded w-1/4 mb-4"></div>
                <div className="h-4 bg-gray-200 rounded w-3/4"></div>
              </div>
            ))}
          </div>
        ) : alerts.length === 0 ? (
          <div className="bg-white rounded-xl shadow p-12 text-center">
            <AlertTriangle className="w-16 h-16 text-gray-400 mx-auto mb-4" />
            <p className="text-gray-600 text-lg">No fraud alerts found</p>
            <p className="text-gray-500 text-sm mt-2">
              {filter === 'pending'
                ? 'All alerts have been reviewed'
                : `No ${filter} alerts`}
            </p>
          </div>
        ) : (
          <div className="space-y-4">
            {alerts.map((alert) => (
              <div
                key={alert.id}
                className="bg-white rounded-xl shadow hover:shadow-md transition-shadow p-6"
              >
                <div className="flex items-start justify-between mb-4">
                  <div className="flex-1">
                    <div className="flex items-center gap-3 mb-2">
                      <h3 className="text-lg font-semibold text-gray-900">
                        {alert.reason}
                      </h3>
                      <Badge className={getSeverityColor(alert.severity)}>
                        {alert.severity}
                      </Badge>
                      <Badge className={getStatusColor(alert.status)}>
                        {alert.status}
                      </Badge>
                    </div>
                    <div className="text-sm text-gray-600 space-y-1">
                      <p>
                        <span className="font-medium">Device ID:</span>{' '}
                        <code className="bg-gray-100 px-2 py-1 rounded">
                          {alert.deviceId}
                        </code>
                      </p>
                      <p>
                        <span className="font-medium">Action:</span> {alert.action}
                      </p>
                      <p>
                        <span className="font-medium">Created:</span>{' '}
                        {format(new Date(alert.createdAt), 'PPpp')}
                      </p>
                      {alert.reviewedAt && (
                        <p>
                          <span className="font-medium">Reviewed:</span>{' '}
                          {format(new Date(alert.reviewedAt), 'PPpp')} by{' '}
                          {alert.reviewedBy || 'Unknown'}
                        </p>
                      )}
                      {alert.metadata && Object.keys(alert.metadata).length > 0 && (
                        <details className="mt-2">
                          <summary className="cursor-pointer text-blue-600 hover:text-blue-700">
                            View Metadata
                          </summary>
                          <pre className="mt-2 bg-gray-50 p-3 rounded text-xs overflow-auto">
                            {JSON.stringify(alert.metadata, null, 2)}
                          </pre>
                        </details>
                      )}
                    </div>
                  </div>
                </div>

                {/* Action Buttons */}
                {alert.status === 'pending' && (
                  <div className="flex gap-2 mt-4 pt-4 border-t">
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => handleReview(alert.id, 'dismiss', 'Dismissed by admin')}
                    >
                      <XCircle className="w-4 h-4 mr-2" />
                      Dismiss
                    </Button>
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => handleReview(alert.id, 'confirm', 'Confirmed as fraud')}
                    >
                      <CheckCircle className="w-4 h-4 mr-2" />
                      Confirm
                    </Button>
                    <Button
                      variant="destructive"
                      size="sm"
                      onClick={() => {
                        if (confirm('Are you sure you want to ban this user?')) {
                          handleReview(alert.id, 'ban', 'Banned due to fraud');
                        }
                      }}
                    >
                      <Ban className="w-4 h-4 mr-2" />
                      Ban User
                    </Button>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
