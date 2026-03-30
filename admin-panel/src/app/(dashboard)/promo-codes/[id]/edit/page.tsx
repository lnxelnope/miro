'use client';

import { useState, useEffect } from 'react';
import { useRouter, useParams } from 'next/navigation';
import { PromoCodeForm, type PromoCodeFormData } from '@/components/promo/PromoCodeForm';

interface PromoDoc {
  id: string;
  code: string;
  rewardType: string;
  rewardPayload?: { amount?: number; days?: number };
  maxRedemptions?: number;
  perUserLimit?: number;
  expiryAt?: string | null;
  active?: boolean;
}

export default function EditPromoCodePage() {
  const router = useRouter();
  const params = useParams();
  const id = params.id as string;
  const [promo, setPromo] = useState<PromoDoc | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    async function load() {
      setLoading(true);
      try {
        const res = await fetch(`/api/promo-codes/${id}`);
        const data = await res.json();
        if (data.success && data.promoCode) {
          setPromo(data.promoCode);
        } else {
          alert(data.error || 'Not found');
          router.push('/promo-codes');
        }
      } catch {
        router.push('/promo-codes');
      } finally {
        setLoading(false);
      }
    }
    load();
  }, [id, router]);

  async function handleSubmit(data: PromoCodeFormData) {
    setSaving(true);
    try {
      const response = await fetch(`/api/promo-codes/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'same-origin',
        body: JSON.stringify({
          rewardType: data.rewardType,
          rewardPayload: data.rewardPayload,
          maxRedemptions: data.maxRedemptions,
          perUserLimit: data.perUserLimit,
          expiryAt: data.expiryAt,
          active: data.active,
        }),
      });

      const result = await response.json().catch(() => ({}));
      if (response.ok && result.success) {
        router.push('/promo-codes');
      } else {
        alert(result.error || `HTTP ${response.status}`);
      }
    } catch (e) {
      console.error(e);
      alert('Failed to save');
    } finally {
      setSaving(false);
    }
  }

  if (loading) {
    return (
      <div className="p-8">
        <p>Loading…</p>
      </div>
    );
  }

  if (!promo) {
    return null;
  }

  return (
    <div className="p-8">
      <h1 className="text-3xl font-bold mb-6">Edit promo code</h1>
      <div className="bg-white rounded-lg shadow p-6">
        <PromoCodeForm
          mode="edit"
          initialData={promo}
          onSubmit={handleSubmit}
          isLoading={saving}
        />
      </div>
    </div>
  );
}
