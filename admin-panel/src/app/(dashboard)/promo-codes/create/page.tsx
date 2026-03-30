'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { PromoCodeForm, type PromoCodeFormData } from '@/components/promo/PromoCodeForm';

export default function CreatePromoCodePage() {
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(false);

  async function handleSubmit(data: PromoCodeFormData) {
    setIsLoading(true);
    try {
      const response = await fetch('/api/promo-codes', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        credentials: 'same-origin',
        body: JSON.stringify({
          code: data.code,
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
      alert('Failed to create');
    } finally {
      setIsLoading(false);
    }
  }

  return (
    <div className="p-8">
      <h1 className="text-3xl font-bold mb-6">Create promo code</h1>
      <div className="bg-white rounded-lg shadow p-6">
        <PromoCodeForm mode="create" onSubmit={handleSubmit} isLoading={isLoading} />
      </div>
    </div>
  );
}
