'use client';

import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';

interface PromotionsFormProps {
  initialConfig: any;
  onSave: (config: any) => void;
}

export function PromotionsForm({ initialConfig, onSave }: PromotionsFormProps) {
  const [config, setConfig] = useState(initialConfig || {});

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSave(config);
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      {/* Welcome Offer */}
      <div className="border rounded-lg p-4">
        <h3 className="font-semibold mb-3">🎁 Welcome Offer (First 10 Energy Spent)</h3>
        <div className="grid grid-cols-2 gap-4">
          <div>
            <Label>Threshold (Energy)</Label>
            <Input
              type="number"
              value={config.promotions?.welcomeOffer?.threshold || 10}
              onChange={(e) =>
                setConfig({
                  ...config,
                  promotions: {
                    ...config.promotions,
                    welcomeOffer: {
                      ...config.promotions?.welcomeOffer,
                      threshold: parseInt(e.target.value) || 10,
                    },
                  },
                })
              }
            />
          </div>
          <div>
            <Label>Free Energy</Label>
            <Input
              type="number"
              value={config.promotions?.welcomeOffer?.freeEnergy || 50}
              onChange={(e) =>
                setConfig({
                  ...config,
                  promotions: {
                    ...config.promotions,
                    welcomeOffer: {
                      ...config.promotions?.welcomeOffer,
                      freeEnergy: parseInt(e.target.value) || 50,
                    },
                  },
                })
              }
            />
          </div>
          <div>
            <Label>Bonus Rate (%)</Label>
            <Input
              type="number"
              value={((config.promotions?.welcomeOffer?.bonusRate || 0.4) * 100).toFixed(0)}
              onChange={(e) =>
                setConfig({
                  ...config,
                  promotions: {
                    ...config.promotions,
                    welcomeOffer: {
                      ...config.promotions?.welcomeOffer,
                      bonusRate: parseFloat(e.target.value) / 100 || 0.4,
                    },
                  },
                })
              }
            />
          </div>
          <div>
            <Label>Duration (hours)</Label>
            <Input
              type="number"
              value={config.promotions?.welcomeOffer?.duration || 24}
              onChange={(e) =>
                setConfig({
                  ...config,
                  promotions: {
                    ...config.promotions,
                    welcomeOffer: {
                      ...config.promotions?.welcomeOffer,
                      duration: parseInt(e.target.value) || 24,
                    },
                  },
                })
              }
            />
          </div>
        </div>
      </div>

      {/* Tier Upgrade Bonus */}
      <div className="border rounded-lg p-4">
        <h3 className="font-semibold mb-3">🎊 Tier Up Bonus (1-time per tier)</h3>
        <div className="space-y-3">
          {['bronze', 'silver', 'gold', 'diamond'].map((tier) => (
            <div key={tier} className="flex items-center gap-4">
              <span className="w-24 font-medium capitalize">{tier}:</span>
              <Input
                type="number"
                placeholder="Reward Energy"
                className="w-32"
                value={config.promotions?.tierUpgrade?.rewards?.[tier] || 0}
                onChange={(e) =>
                  setConfig({
                    ...config,
                    promotions: {
                      ...config.promotions,
                      tierUpgrade: {
                        ...config.promotions?.tierUpgrade,
                        rewards: {
                          ...config.promotions?.tierUpgrade?.rewards,
                          [tier]: parseInt(e.target.value) || 0,
                        },
                      },
                    },
                  })
                }
              />
              <span className="text-sm text-gray-600">Energy + 20% bonus</span>
            </div>
          ))}
        </div>
      </div>

      {/* Welcome Back */}
      <div className="border rounded-lg p-4">
        <h3 className="font-semibold mb-3">🎁 Welcome Back (ex-Diamond fell)</h3>
        <div className="grid grid-cols-2 gap-4">
          <div>
            <Label>Bonus Rate (%)</Label>
            <Input
              type="number"
              value={((config.promotions?.welcomeBack?.bonusRate || 0.4) * 100).toFixed(0)}
              onChange={(e) =>
                setConfig({
                  ...config,
                  promotions: {
                    ...config.promotions,
                    welcomeBack: {
                      ...config.promotions?.welcomeBack,
                      bonusRate: parseFloat(e.target.value) / 100 || 0.4,
                    },
                  },
                })
              }
            />
          </div>
          <div>
            <Label>Duration (hours)</Label>
            <Input
              type="number"
              value={config.promotions?.welcomeBack?.duration || 24}
              onChange={(e) =>
                setConfig({
                  ...config,
                  promotions: {
                    ...config.promotions,
                    welcomeBack: {
                      ...config.promotions?.welcomeBack,
                      duration: parseInt(e.target.value) || 24,
                    },
                  },
                })
              }
            />
          </div>
        </div>
        <p className="text-xs text-gray-500 mt-2">
          Triggers when ex-Diamond users fall to Starter or Bronze
        </p>
      </div>

      {/* Save Button */}
      <Button type="submit" className="w-full">
        💾 Save All Changes
      </Button>
    </form>
  );
}
