'use client';

import { useEffect, useState } from 'react';

export function SubscribersTable() {
  const [subscribers, setSubscribers] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch('/api/subscriptions/list?status=all&limit=100')
      .then((res) => res.json())
      .then((data) => {
        if (data.success) {
          setSubscribers(data.subscribers || []);
        }
        setLoading(false);
      })
      .catch((err) => {
        console.error(err);
        setLoading(false);
      });
  }, []);

  if (loading) return <div className="text-center py-8">Loading subscribers...</div>;

  const isExpiringSoon = (expiryDate: string | null) => {
    if (!expiryDate) return false;
    const expiry = new Date(expiryDate);
    const sevenDays = new Date();
    sevenDays.setDate(sevenDays.getDate() + 7);
    return expiry <= sevenDays && expiry > new Date();
  };

  return (
    <div className="bg-white rounded-lg shadow overflow-hidden">
      <table className="min-w-full">
        <thead className="bg-gray-50">
          <tr>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
              MiRO ID
            </th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
              Status
            </th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
              Expiry Date
            </th>
            <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
              Balance
            </th>
          </tr>
        </thead>
        <tbody className="bg-white divide-y divide-gray-200">
          {subscribers.map((sub) => (
            <tr 
              key={sub.deviceId} 
              className={isExpiringSoon(sub.subscriptionExpiryDate) ? 'bg-yellow-50' : ''}
            >
              <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                {sub.miroId}
              </td>
              <td className="px-6 py-4 whitespace-nowrap">
                <span className={`px-2 py-1 text-xs font-semibold rounded-full ${
                  sub.subscriptionStatus === 'active' 
                    ? 'bg-green-100 text-green-800'
                    : sub.subscriptionStatus === 'cancelled'
                    ? 'bg-yellow-100 text-yellow-800'
                    : 'bg-red-100 text-red-800'
                }`}>
                  {sub.subscriptionStatus}
                </span>
              </td>
              <td className="px-6 py-4 whitespace-nowrap text-sm">
                {sub.subscriptionExpiryDate 
                  ? new Date(sub.subscriptionExpiryDate).toLocaleDateString()
                  : 'N/A'
                }
                {isExpiringSoon(sub.subscriptionExpiryDate) && (
                  <span className="ml-2 text-yellow-600">⚠️ Soon</span>
                )}
              </td>
              <td className="px-6 py-4 whitespace-nowrap text-sm">
                ⚡ {sub.balance}
              </td>
            </tr>
          ))}
        </tbody>
      </table>

      {subscribers.length === 0 && (
        <div className="text-center py-8 text-gray-500">
          No subscribers found
        </div>
      )}
    </div>
  );
}
