'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { OfferForm } from '@/components/offers/OfferForm';

export default function CreateOfferPage() {
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(false);

  async function handleSubmit(data: any) {
    setIsLoading(true);
    try {
      const response = await fetch('/api/offers', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      });

      const result = await response.json();
      if (result.success) {
        router.push('/offers');
      } else {
        alert(`Error: ${result.error}`);
      }
    } catch (error) {
      console.error('Error creating offer:', error);
      alert('Failed to create offer');
    } finally {
      setIsLoading(false);
    }
  }

  return (
    <div className="p-8">
      <h1 className="text-3xl font-bold mb-6">Create Offer Template</h1>
      <div className="bg-white rounded-lg shadow p-6">
        <OfferForm onSubmit={handleSubmit} isLoading={isLoading} />
      </div>
    </div>
  );
}
