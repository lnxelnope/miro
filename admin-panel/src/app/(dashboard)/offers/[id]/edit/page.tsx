'use client';

import { useState, useEffect } from 'react';
import { useRouter, useParams } from 'next/navigation';
import { OfferForm } from '@/components/offers/OfferForm';

interface OfferTemplate {
  id: string;
  slug: string;
  triggerEvent: string;
  triggerCondition: Record<string, any>;
  title: { en: string; th: string };
  description: { en: string; th: string };
  ctaText: { en: string; th: string };
  icon: string;
  rewardType: string;
  rewardConfig: Record<string, any>;
  expiresAfterHours: number | null;
  priority: number;
  maxClaimsPerUser: number;
  isActive: boolean;
}

export default function EditOfferPage() {
  const router = useRouter();
  const params = useParams();
  const id = params.id as string;
  const [offer, setOffer] = useState<OfferTemplate | null>(null);
  const [loading, setLoading] = useState(true);
  const [isSaving, setIsSaving] = useState(false);

  useEffect(() => {
    fetchOffer();
  }, [id]);

  async function fetchOffer() {
    setLoading(true);
    try {
      const response = await fetch(`/api/offers/${id}`);
      const data = await response.json();
      if (data.success) {
        setOffer(data.offer);
      } else {
        alert(`Error: ${data.error}`);
        router.push('/offers');
      }
    } catch (error) {
      console.error('Error fetching offer:', error);
      alert('Failed to load offer');
      router.push('/offers');
    } finally {
      setLoading(false);
    }
  }

  async function handleSubmit(data: any) {
    setIsSaving(true);
    try {
      const response = await fetch(`/api/offers/${id}`, {
        method: 'PUT',
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
      console.error('Error updating offer:', error);
      alert('Failed to update offer');
    } finally {
      setIsSaving(false);
    }
  }

  if (loading) {
    return (
      <div className="p-8">
        <p>Loading...</p>
      </div>
    );
  }

  if (!offer) {
    return (
      <div className="p-8">
        <p>Offer not found</p>
      </div>
    );
  }

  return (
    <div className="p-8">
      <h1 className="text-3xl font-bold mb-6">Edit Offer Template</h1>
      <div className="bg-white rounded-lg shadow p-6">
        <OfferForm initialData={offer} onSubmit={handleSubmit} isLoading={isSaving} />
      </div>
    </div>
  );
}
