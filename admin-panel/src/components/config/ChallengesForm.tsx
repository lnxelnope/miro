'use client';

import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';

interface ChallengesFormProps {
  initialConfig: any;
  onSave: (config: any) => void;
}

export function ChallengesForm({ initialConfig, onSave }: ChallengesFormProps) {
  const [config, setConfig] = useState(initialConfig || {});

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSave(config);
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="border rounded-lg p-4">
        <h3 className="font-semibold mb-3">🏆 Weekly Challenges</h3>
        
        <div className="space-y-4">
          {/* Log Meals */}
          <div>
            <h4 className="font-medium mb-2">📝 Log Meals Challenge</h4>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <Label>Goal (meals/week)</Label>
                <Input
                  type="number"
                  value={config.challenges?.logMeals?.goal || 7}
                  onChange={(e) =>
                    setConfig({
                      ...config,
                      challenges: {
                        ...config.challenges,
                        logMeals: {
                          ...config.challenges?.logMeals,
                          goal: parseInt(e.target.value) || 7,
                        },
                      },
                    })
                  }
                />
              </div>
              <div>
                <Label>Reward (Energy)</Label>
                <Input
                  type="number"
                  value={config.challenges?.logMeals?.reward || 10}
                  onChange={(e) =>
                    setConfig({
                      ...config,
                      challenges: {
                        ...config.challenges,
                        logMeals: {
                          ...config.challenges?.logMeals,
                          reward: parseInt(e.target.value) || 10,
                        },
                      },
                    })
                  }
                />
              </div>
            </div>
          </div>

          {/* Use AI */}
          <div>
            <h4 className="font-medium mb-2">🤖 Use AI Challenge</h4>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <Label>Goal (times/week)</Label>
                <Input
                  type="number"
                  value={config.challenges?.useAi?.goal || 3}
                  onChange={(e) =>
                    setConfig({
                      ...config,
                      challenges: {
                        ...config.challenges,
                        useAi: {
                          ...config.challenges?.useAi,
                          goal: parseInt(e.target.value) || 3,
                        },
                      },
                    })
                  }
                />
              </div>
              <div>
                <Label>Reward (Energy)</Label>
                <Input
                  type="number"
                  value={config.challenges?.useAi?.reward || 5}
                  onChange={(e) =>
                    setConfig({
                      ...config,
                      challenges: {
                        ...config.challenges,
                        useAi: {
                          ...config.challenges?.useAi,
                          reward: parseInt(e.target.value) || 5,
                        },
                      },
                    })
                  }
                />
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Milestones */}
      <div className="border rounded-lg p-4">
        <h3 className="font-semibold mb-3">🎯 Milestone Rewards</h3>
        <div className="space-y-3">
          <div className="grid grid-cols-2 gap-4">
            <div>
              <Label>500 Energy Spent Milestone</Label>
              <Input
                type="number"
                value={config.milestones?.spent500 || 50}
                onChange={(e) =>
                  setConfig({
                    ...config,
                    milestones: {
                      ...config.milestones,
                      spent500: parseInt(e.target.value) || 50,
                    },
                  })
                }
              />
            </div>
            <div>
              <Label>1000 Energy Spent Milestone</Label>
              <Input
                type="number"
                value={config.milestones?.spent1000 || 100}
                onChange={(e) =>
                  setConfig({
                    ...config,
                    milestones: {
                      ...config.milestones,
                      spent1000: parseInt(e.target.value) || 100,
                    },
                  })
                }
              />
            </div>
          </div>
        </div>
      </div>

      <Button type="submit" className="w-full">
        💾 Save Config
      </Button>
    </form>
  );
}
