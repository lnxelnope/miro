'use client';

import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { Save } from 'lucide-react';

const systemSettingsSchema = z.object({
  freeAiCredits: z.number().min(0).max(10),
  streakGracePeriod: z.number().min(0).max(7),
  aiAnalysisCost: z.number().min(1).max(50),
  welcomeGiftAmount: z.number().min(0).max(1000),
});

type SystemSettingsFormData = z.infer<typeof systemSettingsSchema>;

interface SystemSettingsProps {
  initialData: SystemSettingsFormData;
  onSave: (data: SystemSettingsFormData) => Promise<void>;
}

export function SystemSettings({ initialData, onSave }: SystemSettingsProps) {
  const [isSaving, setIsSaving] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors, isDirty },
  } = useForm<SystemSettingsFormData>({
    resolver: zodResolver(systemSettingsSchema),
    defaultValues: initialData,
  });

  const onSubmit = async (data: SystemSettingsFormData) => {
    try {
      setIsSaving(true);
      await onSave(data);
      alert('System settings saved successfully!');
    } catch (error) {
      console.error('Save error:', error);
      alert('Failed to save system settings');
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <div className="bg-white rounded-xl shadow p-6">
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-xl font-bold text-gray-900">System Settings</h2>
        {isDirty && (
          <span className="text-sm text-orange-600 font-medium">• Unsaved Changes</span>
        )}
      </div>

      <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Free AI Credits per Day
            </label>
            <input
              type="number"
              {...register('freeAiCredits', { valueAsNumber: true })}
              className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
            />
            {errors.freeAiCredits && (
              <p className="text-red-500 text-sm mt-1">{errors.freeAiCredits.message}</p>
            )}
            <p className="text-xs text-gray-500 mt-1">
              How many free AI analyses users get daily
            </p>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Streak Grace Period (days)
            </label>
            <input
              type="number"
              {...register('streakGracePeriod', { valueAsNumber: true })}
              className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
            />
            {errors.streakGracePeriod && (
              <p className="text-red-500 text-sm mt-1">{errors.streakGracePeriod.message}</p>
            )}
            <p className="text-xs text-gray-500 mt-1">
              Days users can skip without losing streak
            </p>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              AI Analysis Cost (energy)
            </label>
            <input
              type="number"
              {...register('aiAnalysisCost', { valueAsNumber: true })}
              className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
            />
            {errors.aiAnalysisCost && (
              <p className="text-red-500 text-sm mt-1">{errors.aiAnalysisCost.message}</p>
            )}
            <p className="text-xs text-gray-500 mt-1">
              Energy cost per AI food analysis
            </p>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Welcome Gift Amount (energy)
            </label>
            <input
              type="number"
              {...register('welcomeGiftAmount', { valueAsNumber: true })}
              className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
            />
            {errors.welcomeGiftAmount && (
              <p className="text-red-500 text-sm mt-1">{errors.welcomeGiftAmount.message}</p>
            )}
            <p className="text-xs text-gray-500 mt-1">
              Energy gift for new users
            </p>
          </div>
        </div>

        <button
          type="submit"
          disabled={isSaving || !isDirty}
          className="flex items-center space-x-2 px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 transition"
        >
          <Save className="w-4 h-4" />
          <span>{isSaving ? 'Saving...' : 'Save Changes'}</span>
        </button>
      </form>
    </div>
  );
}
