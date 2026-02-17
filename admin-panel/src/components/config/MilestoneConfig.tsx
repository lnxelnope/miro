'use client';

import { useState } from 'react';
import { Plus, Trash2, Save } from 'lucide-react';

interface Milestone {
  threshold: number;
  reward: number;
}

interface MilestoneConfigProps {
  initialData: Milestone[];
  onSave: (data: Milestone[]) => Promise<void>;
}

export function MilestoneConfig({ initialData, onSave }: MilestoneConfigProps) {
  const [milestones, setMilestones] = useState<Milestone[]>(initialData);
  const [isSaving, setIsSaving] = useState(false);
  const [hasChanges, setHasChanges] = useState(false);

  const handleAdd = () => {
    setMilestones([...milestones, { threshold: 0, reward: 0 }]);
    setHasChanges(true);
  };

  const handleRemove = (index: number) => {
    setMilestones(milestones.filter((_, i) => i !== index));
    setHasChanges(true);
  };

  const handleChange = (index: number, field: keyof Milestone, value: number) => {
    const updated = [...milestones];
    updated[index][field] = value;
    setMilestones(updated);
    setHasChanges(true);
  };

  const handleSave = async () => {
    // Validate
    const sorted = [...milestones].sort((a, b) => a.threshold - b.threshold);
    const hasInvalid = sorted.some((m) => m.threshold <= 0 || m.reward <= 0);
    
    if (hasInvalid) {
      alert('All thresholds and rewards must be greater than 0');
      return;
    }

    try {
      setIsSaving(true);
      await onSave(sorted);
      setMilestones(sorted);
      setHasChanges(false);
      alert('Milestones saved successfully!');
    } catch (error) {
      console.error('Save error:', error);
      alert('Failed to save milestones');
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <div className="bg-white rounded-xl shadow p-6">
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-xl font-bold text-gray-900">Milestone Rewards</h2>
        {hasChanges && (
          <span className="text-sm text-orange-600 font-medium">• Unsaved Changes</span>
        )}
      </div>

      <div className="space-y-3 mb-6">
        {milestones.map((milestone, index) => (
          <div key={index} className="flex items-center space-x-3 p-3 border rounded-lg">
            <div className="flex-1 grid grid-cols-2 gap-3">
              <div>
                <label className="block text-xs text-gray-600 mb-1">
                  Threshold (energy spent)
                </label>
                <input
                  type="number"
                  value={milestone.threshold}
                  onChange={(e) =>
                    handleChange(index, 'threshold', parseInt(e.target.value) || 0)
                  }
                  className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
                />
              </div>
              <div>
                <label className="block text-xs text-gray-600 mb-1">Reward (energy)</label>
                <input
                  type="number"
                  value={milestone.reward}
                  onChange={(e) =>
                    handleChange(index, 'reward', parseInt(e.target.value) || 0)
                  }
                  className="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
                />
              </div>
            </div>
            <button
              onClick={() => handleRemove(index)}
              className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition"
            >
              <Trash2 className="w-5 h-5" />
            </button>
          </div>
        ))}
      </div>

      <div className="flex space-x-3">
        <button
          onClick={handleAdd}
          className="flex items-center space-x-2 px-4 py-2 border-2 border-dashed border-gray-300 rounded-lg hover:border-blue-500 hover:bg-blue-50 transition"
        >
          <Plus className="w-4 h-4" />
          <span>Add Milestone</span>
        </button>
        <button
          onClick={handleSave}
          disabled={isSaving || !hasChanges}
          className="flex items-center space-x-2 px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 transition"
        >
          <Save className="w-4 h-4" />
          <span>{isSaving ? 'Saving...' : 'Save Changes'}</span>
        </button>
      </div>
    </div>
  );
}
