'use client';

import { useEffect, useState } from 'react';
import { ChallengeConfig } from '@/components/config/ChallengeConfig';
import { MilestoneConfig } from '@/components/config/MilestoneConfig';
import { SystemSettings } from '@/components/config/SystemSettings';
import { ConfigHistory } from '@/components/config/ConfigHistory';

export default function ConfigPage() {
  const [config, setConfig] = useState<any>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    fetchConfig();
  }, []);

  const fetchConfig = async () => {
    try {
      const response = await fetch('/api/config');
      if (!response.ok) throw new Error('Failed to fetch config');
      const data = await response.json();
      setConfig(data);
    } catch (error) {
      console.error('Fetch config error:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const handleSaveSection = async (section: string, data: any) => {
    const response = await fetch('/api/config', {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ section, data }),
    });

    if (!response.ok) throw new Error('Failed to save config');

    // Refresh config
    await fetchConfig();
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading configuration...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900">Configuration Management</h1>
          <p className="text-gray-600 mt-2">
            Manage system settings, challenges, and milestones
          </p>
        </div>

        <div className="space-y-6">
          {/* Challenges */}
          <ChallengeConfig
            initialData={config.challenges}
            onSave={(data) => handleSaveSection('challenges', data)}
          />

          {/* Milestones */}
          <MilestoneConfig
            initialData={config.milestones}
            onSave={(data) => handleSaveSection('milestones', data)}
          />

          {/* System Settings */}
          <SystemSettings
            initialData={config.systemSettings}
            onSave={(data) => handleSaveSection('systemSettings', data)}
          />

          {/* Change History */}
          <ConfigHistory />
        </div>
      </div>
    </div>
  );
}
