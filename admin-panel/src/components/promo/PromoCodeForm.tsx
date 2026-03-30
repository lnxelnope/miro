'use client';

import { useState, useEffect } from 'react';
import { Button } from '@/components/ui/button';

export interface PromoCodeFormData {
  code: string;
  rewardType: 'energy' | 'freepass';
  rewardPayload: { amount?: number; days?: number };
  maxRedemptions: number;
  perUserLimit: number;
  expiryAt: string | null;
  active: boolean;
}

interface InitialPromo {
  id: string;
  code: string;
  rewardType: string;
  rewardPayload?: { amount?: number; days?: number };
  maxRedemptions?: number;
  perUserLimit?: number;
  expiryAt?: string | null;
  active?: boolean;
}

function toDatetimeLocal(iso: string | null | undefined): string {
  if (!iso) return '';
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return '';
  const pad = (n: number) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`;
}

export function PromoCodeForm({
  initialData,
  onSubmit,
  isLoading,
  mode,
}: {
  initialData?: InitialPromo | null;
  onSubmit: (data: PromoCodeFormData) => void | Promise<void>;
  isLoading: boolean;
  mode: 'create' | 'edit';
}) {
  const [code, setCode] = useState('');
  const [rewardType, setRewardType] = useState<'energy' | 'freepass'>('energy');
  const [amount, setAmount] = useState('100');
  const [days, setDays] = useState('7');
  const [maxRedemptions, setMaxRedemptions] = useState('0');
  const [perUserLimit, setPerUserLimit] = useState('1');
  const [expiryLocal, setExpiryLocal] = useState('');
  const [active, setActive] = useState(true);

  useEffect(() => {
    if (!initialData) return;
    setCode(initialData.code || '');
    setRewardType(
      initialData.rewardType === 'freepass' ? 'freepass' : 'energy'
    );
    const p = initialData.rewardPayload || {};
    setAmount(String(p.amount ?? 100));
    setDays(String(p.days ?? 7));
    setMaxRedemptions(String(initialData.maxRedemptions ?? 0));
    setPerUserLimit(String(initialData.perUserLimit ?? 1));
    setExpiryLocal(toDatetimeLocal(initialData.expiryAt ?? null));
    setActive(initialData.active !== false);
  }, [initialData]);

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    const maxR = parseInt(maxRedemptions, 10);
    const perU = parseInt(perUserLimit, 10);
    const rewardPayload =
      rewardType === 'energy'
        ? { amount: Math.max(1, parseInt(amount, 10) || 0) }
        : { days: Math.max(1, parseInt(days, 10) || 0) };

    onSubmit({
      code: code.trim().toUpperCase(),
      rewardType,
      rewardPayload,
      maxRedemptions: Number.isFinite(maxR) && maxR >= 0 ? maxR : 0,
      perUserLimit: Number.isFinite(perU) && perU >= 1 ? perU : 1,
      expiryAt: expiryLocal ? new Date(expiryLocal).toISOString() : null,
      active,
    });
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-6 max-w-xl">
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-1">
          Code (stored uppercase)
        </label>
        <input
          type="text"
          required={mode === 'create'}
          disabled={mode === 'edit'}
          value={code}
          onChange={(e) => setCode(e.target.value)}
          className="w-full rounded-lg border border-gray-300 px-3 py-2 font-mono uppercase disabled:bg-gray-100"
          placeholder="SUMMER2026"
        />
        {mode === 'edit' && (
          <p className="text-xs text-gray-500 mt-1">Code cannot be changed after creation.</p>
        )}
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-1">Reward type</label>
        <select
          value={rewardType}
          onChange={(e) =>
            setRewardType(e.target.value === 'freepass' ? 'freepass' : 'energy')
          }
          className="w-full rounded-lg border border-gray-300 px-3 py-2"
        >
          <option value="energy">Energy</option>
          <option value="freepass">Freepass (days)</option>
        </select>
      </div>

      {rewardType === 'energy' ? (
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">
            Energy amount
          </label>
          <input
            type="number"
            min={1}
            required
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            className="w-full rounded-lg border border-gray-300 px-3 py-2"
          />
        </div>
      ) : (
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1">Freepass days</label>
          <input
            type="number"
            min={1}
            required
            value={days}
            onChange={(e) => setDays(e.target.value)}
            className="w-full rounded-lg border border-gray-300 px-3 py-2"
          />
        </div>
      )}

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-1">
          Max redemptions (0 = unlimited)
        </label>
        <input
          type="number"
          min={0}
          required
          value={maxRedemptions}
          onChange={(e) => setMaxRedemptions(e.target.value)}
          className="w-full rounded-lg border border-gray-300 px-3 py-2"
        />
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-1">Per user limit</label>
        <input
          type="number"
          min={1}
          required
          value={perUserLimit}
          onChange={(e) => setPerUserLimit(e.target.value)}
          className="w-full rounded-lg border border-gray-300 px-3 py-2"
        />
      </div>

      <div>
        <label className="block text-sm font-medium text-gray-700 mb-1">
          Expiry (optional, local time)
        </label>
        <input
          type="datetime-local"
          value={expiryLocal}
          onChange={(e) => setExpiryLocal(e.target.value)}
          className="w-full rounded-lg border border-gray-300 px-3 py-2"
        />
      </div>

      <label className="flex items-center gap-2 cursor-pointer">
        <input
          type="checkbox"
          checked={active}
          onChange={(e) => setActive(e.target.checked)}
          className="rounded border-gray-300"
        />
        <span className="text-sm font-medium text-gray-700">Active</span>
      </label>

      <Button type="submit" disabled={isLoading} className="bg-blue-600 hover:bg-blue-700">
        {isLoading ? 'Saving…' : mode === 'create' ? 'Create' : 'Save changes'}
      </Button>
    </form>
  );
}
