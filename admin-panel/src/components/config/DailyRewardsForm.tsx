'use client';

import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';

interface DailyRewardsFormProps {
  initialConfig: any;
  onSave: (config: any) => void;
}

export function DailyRewardsForm({ initialConfig, onSave }: DailyRewardsFormProps) {
  const [config, setConfig] = useState(initialConfig || {});

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSave(config);
  };

  const tiers = [
    { key: 'none', label: 'Starter' },
    { key: 'bronze', label: 'Bronze' },
    { key: 'silver', label: 'Silver' },
    { key: 'gold', label: 'Gold' },
    { key: 'diamond', label: 'Diamond' },
  ];

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="border rounded-lg p-4">
        <h3 className="font-semibold mb-3">⚡ Daily Energy Rewards</h3>
        <p className="text-sm text-gray-600 mb-4">
          Energy given daily when user uses AI for the first time each day
        </p>
        
        <div className="space-y-3">
          {tiers.map(({ key, label }) => (
            <div key={key} className="flex items-center gap-4">
              <span className="w-24 font-medium">{label}:</span>
              <Input
                type="number"
                className="w-32"
                value={config.dailyRewards?.[key] || 1}
                onChange={(e) =>
                  setConfig({
                    ...config,
                    dailyRewards: {
                      ...config.dailyRewards,
                      [key]: parseInt(e.target.value) || 1,
                    },
                  })
                }
              />
              <span className="text-sm text-gray-600">Energy/day</span>
            </div>
          ))}
        </div>
      </div>

      <Button type="submit" className="w-full">
        💾 Save Daily Rewards
      </Button>
    </form>
  );
}
