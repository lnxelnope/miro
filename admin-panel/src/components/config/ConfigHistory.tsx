'use client';

import { useEffect, useState } from 'react';
import { format } from 'date-fns';
import { History } from 'lucide-react';

interface ConfigChange {
  id: string;
  section: string;
  changes: any;
  timestamp: string;
  admin: string;
}

export function ConfigHistory() {
  const [history, setHistory] = useState<ConfigChange[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    fetchHistory();
  }, []);

  const fetchHistory = async () => {
    try {
      const response = await fetch('/api/config/history');
      if (!response.ok) throw new Error('Failed to fetch history');
      const data = await response.json();
      setHistory(data.history);
    } catch (error) {
      console.error('Fetch history error:', error);
    } finally {
      setIsLoading(false);
    }
  };

  if (isLoading) {
    return (
      <div className="bg-white rounded-xl shadow p-6">
        <h2 className="text-xl font-bold text-gray-900 mb-4">Change History</h2>
        <div className="space-y-3">
          {[1, 2, 3].map((i) => (
            <div key={i} className="animate-pulse h-16 bg-gray-100 rounded-lg"></div>
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="bg-white rounded-xl shadow p-6">
      <div className="flex items-center space-x-2 mb-4">
        <History className="w-5 h-5 text-gray-600" />
        <h2 className="text-xl font-bold text-gray-900">Change History</h2>
      </div>

      {history.length === 0 ? (
        <p className="text-gray-500 text-center py-8">No changes yet</p>
      ) : (
        <div className="space-y-3">
          {history.map((change) => (
            <div key={change.id} className="border rounded-lg p-4">
              <div className="flex items-center justify-between mb-2">
                <span className="font-medium text-gray-900 capitalize">
                  {change.section.replace(/([A-Z])/g, ' $1').trim()}
                </span>
                <span className="text-sm text-gray-500">
                  {format(new Date(change.timestamp), 'PPpp')}
                </span>
              </div>
              <p className="text-sm text-gray-600">
                Changed by: <span className="font-medium">{change.admin}</span>
              </p>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
