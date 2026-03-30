'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { Button } from '@/components/ui/button';
import { Plus, Edit, Trash2 } from 'lucide-react';

interface PromoRow {
  id: string;
  code: string;
  active: boolean;
  rewardType: string;
  rewardPayload?: { amount?: number; days?: number };
  maxRedemptions: number;
  perUserLimit: number;
  redemptionCount: number;
  expiryAt: string | null;
  createdAt: string | null;
}

function formatReward(p: PromoRow): string {
  if (p.rewardType === 'energy') {
    return `${p.rewardPayload?.amount ?? '?'} E`;
  }
  if (p.rewardType === 'freepass') {
    return `${p.rewardPayload?.days ?? '?'} days`;
  }
  return p.rewardType;
}

export default function PromoCodesPage() {
  const router = useRouter();
  const [rows, setRows] = useState<PromoRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [toggling, setToggling] = useState<string | null>(null);
  const [deleting, setDeleting] = useState<string | null>(null);

  useEffect(() => {
    fetchList();
  }, []);

  async function fetchList() {
    setLoading(true);
    try {
      const res = await fetch('/api/promo-codes');
      const data = await res.json();
      if (data.success) {
        setRows(data.promoCodes || []);
      }
    } catch (e) {
      console.error(e);
    } finally {
      setLoading(false);
    }
  }

  async function toggleActive(id: string, current: boolean) {
    setToggling(id);
    try {
      const res = await fetch(`/api/promo-codes/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ active: !current }),
      });
      const data = await res.json();
      if (data.success) await fetchList();
      else alert(data.error || 'Toggle failed');
    } finally {
      setToggling(null);
    }
  }

  async function handleDelete(id: string, code: string) {
    if (!confirm(`Delete promo code "${code}"?`)) return;
    setDeleting(id);
    try {
      const res = await fetch(`/api/promo-codes/${id}`, { method: 'DELETE' });
      const data = await res.json();
      if (data.success) await fetchList();
      else alert(data.error || 'Delete failed');
    } finally {
      setDeleting(null);
    }
  }

  return (
    <div className="p-8 max-w-[1200px] mx-auto">
      <div className="flex justify-between items-start mb-8">
        <div>
          <h1 className="text-3xl font-bold">Promo codes</h1>
          <p className="text-gray-500 mt-1">
            Create codes for in-app redemption (energy / freepass)
          </p>
        </div>
        <Button onClick={() => router.push('/promo-codes/create')} className="bg-blue-600">
          <Plus className="w-4 h-4 mr-2" />
          Create
        </Button>
      </div>

      {loading ? (
        <p className="text-gray-500">Loading…</p>
      ) : rows.length === 0 ? (
        <div className="bg-white rounded-lg border p-12 text-center text-gray-500">
          No promo codes yet.
        </div>
      ) : (
        <div className="bg-white rounded-lg border overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="bg-gray-50 border-b">
              <tr>
                <th className="text-left px-4 py-3 font-semibold text-gray-600">Code</th>
                <th className="text-left px-4 py-3 font-semibold text-gray-600">Reward</th>
                <th className="text-left px-4 py-3 font-semibold text-gray-600">Redeemed</th>
                <th className="text-left px-4 py-3 font-semibold text-gray-600">Per user</th>
                <th className="text-left px-4 py-3 font-semibold text-gray-600">Expires</th>
                <th className="text-left px-4 py-3 font-semibold text-gray-600">Active</th>
                <th className="text-left px-4 py-3 font-semibold text-gray-600">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y">
              {rows.map((r) => (
                <tr key={r.id} className={!r.active ? 'opacity-60' : ''}>
                  <td className="px-4 py-3 font-mono font-medium">{r.code}</td>
                  <td className="px-4 py-3">{formatReward(r)}</td>
                  <td className="px-4 py-3">
                    {r.redemptionCount ?? 0}
                    {r.maxRedemptions > 0 ? ` / ${r.maxRedemptions}` : ' / ∞'}
                  </td>
                  <td className="px-4 py-3">{r.perUserLimit ?? 1}</td>
                  <td className="px-4 py-3 text-gray-600">
                    {r.expiryAt
                      ? new Date(r.expiryAt).toLocaleString()
                      : '—'}
                  </td>
                  <td className="px-4 py-3">
                    <button
                      type="button"
                      onClick={() => toggleActive(r.id, r.active)}
                      disabled={toggling === r.id}
                      className={`px-3 py-1 rounded-full text-xs font-semibold ${
                        r.active
                          ? 'bg-green-100 text-green-800'
                          : 'bg-gray-100 text-gray-600'
                      }`}
                    >
                      {toggling === r.id ? '…' : r.active ? 'ON' : 'OFF'}
                    </button>
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex gap-2">
                      <button
                        type="button"
                        onClick={() => router.push(`/promo-codes/${r.id}/edit`)}
                        className="p-2 text-blue-600 hover:bg-blue-50 rounded"
                        title="Edit"
                      >
                        <Edit className="w-4 h-4" />
                      </button>
                      <button
                        type="button"
                        onClick={() => handleDelete(r.id, r.code)}
                        disabled={deleting === r.id}
                        className="p-2 text-red-600 hover:bg-red-50 rounded disabled:opacity-50"
                        title="Delete"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
