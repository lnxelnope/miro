'use client';

import { useState, useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Save, RefreshCw } from 'lucide-react';

const challengeSchema = z.object({
  logMeals: z.object({
    goal: z.number().min(1).max(100),
    reward: z.number().min(1).max(1000),
    enabled: z.boolean(),
  }),
  useAi: z.object({
    goal: z.number().min(1).max(100),
    reward: z.number().min(1).max(1000),
    enabled: z.boolean(),
  }),
});

type ChallengeFormData = z.infer<typeof challengeSchema>;

interface ChallengeConfigProps {
  initialData: ChallengeFormData;
  onSave: (data: ChallengeFormData) => Promise<void>;
}

export function ChallengeConfig({ initialData, onSave }: ChallengeConfigProps) {
  const [isSaving, setIsSaving] = useState(false);
  const [hasChanges, setHasChanges] = useState(false);

  const {
    register,
    handleSubmit,
    watch,
    reset,
    formState: { errors },
  } = useForm<ChallengeFormData>({
    resolver: zodResolver(challengeSchema),
    defaultValues: initialData,
  });

  // Watch for changes
  useEffect(() => {
    const subscription = watch(() => setHasChanges(true));
    return () => subscription.unsubscribe();
  }, [watch]);

  const onSubmit = async (data: ChallengeFormData) => {
    try {
      setIsSaving(true);
      await onSave(data);
      setHasChanges(false);
      alert('Challenge config saved successfully!');
    } catch (error) {
      console.error('Save error:', error);
      alert('Failed to save challenge config');
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <div className="bg-white rounded-xl shadow p-6">
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-xl font-bold text-gray-900">Weekly Challenges</h2>
        {hasChanges && (
          <span className="text-sm text-orange-600 font-medium">• Unsaved Changes</span>
        )}
      </div>

      <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
        {/* Log Meals Challenge */}
        <div className="border rounded-lg p-4">
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-semibold text-gray-900">📝 Log Meals Challenge</h3>
            <label className="flex items-center space-x-2">
              <input
                type="checkbox"
                {...register('logMeals.enabled')}
                className="w-4 h-4 text-blue-600 rounded"
              />
              <span className="text-sm text-gray-700">Enabled</span>
            </label>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Goal (meals per week)
              </label>
              <input
                type="number"
                {...register('logMeals.goal', { valueAsNumber: true })}
                className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
              />
              {errors.logMeals?.goal && (
                <p className="text-red-500 text-sm mt-1">{errors.logMeals.goal.message}</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Reward (energy)
              </label>
              <input
                type="number"
                {...register('logMeals.reward', { valueAsNumber: true })}
                className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
              />
              {errors.logMeals?.reward && (
                <p className="text-red-500 text-sm mt-1">{errors.logMeals.reward.message}</p>
              )}
            </div>
          </div>
        </div>

        {/* Use AI Challenge */}
        <div className="border rounded-lg p-4">
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-semibold text-gray-900">🧠 Use AI Challenge</h3>
            <label className="flex items-center space-x-2">
              <input
                type="checkbox"
                {...register('useAi.enabled')}
                className="w-4 h-4 text-blue-600 rounded"
              />
              <span className="text-sm text-gray-700">Enabled</span>
            </label>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Goal (AI analyses per week)
              </label>
              <input
                type="number"
                {...register('useAi.goal', { valueAsNumber: true })}
                className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
              />
              {errors.useAi?.goal && (
                <p className="text-red-500 text-sm mt-1">{errors.useAi.goal.message}</p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Reward (energy)
              </label>
              <input
                type="number"
                {...register('useAi.reward', { valueAsNumber: true })}
                className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
              />
              {errors.useAi?.reward && (
                <p className="text-red-500 text-sm mt-1">{errors.useAi.reward.message}</p>
              )}
            </div>
          </div>
        </div>

        {/* Action Buttons */}
        <div className="flex space-x-3">
          <button
            type="submit"
            disabled={isSaving || !hasChanges}
            className="flex items-center space-x-2 px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 transition"
          >
            <Save className="w-4 h-4" />
            <span>{isSaving ? 'Saving...' : 'Save Changes'}</span>
          </button>
          <button
            type="button"
            onClick={() => reset(initialData)}
            disabled={!hasChanges}
            className="flex items-center space-x-2 px-6 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 disabled:opacity-50 transition"
          >
            <RefreshCw className="w-4 h-4" />
            <span>Reset</span>
          </button>
        </div>
      </form>
    </div>
  );
}
