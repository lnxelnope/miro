'use client';

import { useEffect, useState } from 'react';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { PromotionsForm } from '@/components/config/PromotionsForm';
import { DailyRewardsForm } from '@/components/config/DailyRewardsForm';
import { ChallengesForm } from '@/components/config/ChallengesForm';

export default function ConfigPage() {
  const [config, setConfig] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    fetch('/api/config')
      .then((res) => res.json())
      .then((data) => {
        if (data.success) {
          setConfig(data.config);
        }
        setLoading(false);
      })
      .catch((err) => {
        console.error(err);
        setLoading(false);
      });
  }, []);

  const handleSave = async (updatedConfig: any) => {
    setSaving(true);
    try {
      const res = await fetch('/api/config', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ config: updatedConfig }),
      });

      const data = await res.json();

      if (res.ok && data.success) {
        alert('✅ Config saved!');
        setConfig(updatedConfig);
      } else {
        alert('❌ Failed to save config: ' + (data.error || 'Unknown error'));
      }
    } catch (err: any) {
      alert('Error: ' + err.message);
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div className="p-8">
        <div className="text-center py-12">Loading config...</div>
      </div>
    );
  }

  return (
    <div className="p-8">
      <h1 className="text-3xl font-bold mb-6">⚙️ Config Management</h1>

      <div className="bg-white rounded-lg shadow p-6">
        <Tabs defaultValue="promotions">
          <TabsList className="grid w-full grid-cols-3">
            <TabsTrigger value="promotions">🎁 Promotions</TabsTrigger>
            <TabsTrigger value="daily">⚡ Daily Rewards</TabsTrigger>
            <TabsTrigger value="challenges">🏆 Challenges</TabsTrigger>
          </TabsList>

          <TabsContent value="promotions" className="mt-6">
            <PromotionsForm initialConfig={config} onSave={handleSave} />
          </TabsContent>

          <TabsContent value="daily" className="mt-6">
            <DailyRewardsForm initialConfig={config} onSave={handleSave} />
          </TabsContent>

          <TabsContent value="challenges" className="mt-6">
            <ChallengesForm initialConfig={config} onSave={handleSave} />
          </TabsContent>
        </Tabs>
      </div>

      {saving && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6">
            <p>Saving config...</p>
          </div>
        </div>
      )}
    </div>
  );
}
