import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { checkAuth } from '@/lib/auth';

interface OfferStat {
  templateId: string;
  slug: string;
  title: string;
  rewardType: string;
  isActive: boolean;
  claims: number;
  totalEnergyGiven: number;
  totalFreepassDays: number;
  purchasesWithBonus: number;
  bonusEnergyGiven: number;
  revenue: number;
}

function parseDateRange(raw: string): { startDate: Date; endDate: Date } {
  const now = new Date();
  let startDate = new Date();
  const endDate = new Date(now);

  if (raw === '7d') {
    startDate.setDate(now.getDate() - 7);
  } else if (raw === '30d') {
    startDate.setDate(now.getDate() - 30);
  } else if (raw === '90d') {
    startDate.setDate(now.getDate() - 90);
  } else if (raw.startsWith('custom:')) {
    const parts = raw.split(':');
    if (parts.length === 3) {
      startDate = new Date(parseInt(parts[1]));
      const end = new Date(parseInt(parts[2]));
      if (!isNaN(end.getTime())) endDate.setTime(end.getTime());
    }
  }

  return { startDate, endDate };
}

export async function GET(req: NextRequest) {
  try {
    const authError = await checkAuth(req);
    if (authError) return authError;

    const { searchParams } = new URL(req.url);
    const dateRange = searchParams.get('dateRange') || '7d';
    const { startDate, endDate } = parseDateRange(dateRange);

    // 1. Fetch all offer_templates
    const templatesSnap = await db.collection('offer_templates').orderBy('priority', 'asc').get();
    const statsMap = new Map<string, OfferStat>();

    for (const doc of templatesSnap.docs) {
      const d = doc.data();
      statsMap.set(doc.id, {
        templateId: doc.id,
        slug: d.slug || doc.id,
        title: d.title?.en || d.slug || doc.id,
        rewardType: d.rewardType || 'unknown',
        isActive: d.isActive !== false,
        claims: 0,
        totalEnergyGiven: 0,
        totalFreepassDays: 0,
        purchasesWithBonus: 0,
        bonusEnergyGiven: 0,
        revenue: 0,
      });
    }

    // 2. Query offer_free_energy transactions
    const freeEnergySnap = await db
      .collection('transactions')
      .where('type', '==', 'offer_free_energy')
      .where('createdAt', '>=', startDate)
      .where('createdAt', '<=', endDate)
      .get();

    for (const doc of freeEnergySnap.docs) {
      const d = doc.data();
      const tid = d.metadata?.templateId;
      if (tid && statsMap.has(tid)) {
        const s = statsMap.get(tid)!;
        s.claims++;
        s.totalEnergyGiven += d.amount || 0;
      }
    }

    // 3. Query offer_freepass transactions
    const freepassSnap = await db
      .collection('transactions')
      .where('type', '==', 'offer_freepass')
      .where('createdAt', '>=', startDate)
      .where('createdAt', '<=', endDate)
      .get();

    for (const doc of freepassSnap.docs) {
      const d = doc.data();
      const tid = d.metadata?.templateId;
      if (tid && statsMap.has(tid)) {
        const s = statsMap.get(tid)!;
        s.claims++;
        s.totalFreepassDays += d.metadata?.daysAdded || 0;
      }
    }

    // 4. Query purchase transactions that used an offer bonus
    //    (newer transactions have metadata.offerTemplateId; older ones don't)
    const purchaseSnap = await db
      .collection('transactions')
      .where('type', '==', 'purchase')
      .where('createdAt', '>=', startDate)
      .where('createdAt', '<=', endDate)
      .get();

    for (const doc of purchaseSnap.docs) {
      const d = doc.data();
      const meta = d.metadata || {};
      if (meta.bonusRate > 0 && meta.offerTemplateId) {
        const tid = meta.offerTemplateId;
        if (statsMap.has(tid)) {
          const s = statsMap.get(tid)!;
          s.purchasesWithBonus++;
          s.bonusEnergyGiven += meta.bonusEnergy || 0;
          s.revenue += meta.baseEnergy ? estimateRevenue(meta.productId) : 0;
        }
      } else if (meta.bonusRate > 0) {
        // Older transactions without offerTemplateId — not attributable
      }
    }

    const stats = Array.from(statsMap.values());

    return NextResponse.json({
      success: true,
      stats,
      dateRange,
      startDate: startDate.toISOString(),
      endDate: endDate.toISOString(),
    });
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : 'Failed to fetch offer analytics';
    console.error('Error fetching offer analytics:', error);
    return NextResponse.json({ success: false, error: message }, { status: 500 });
  }
}

const PRODUCT_PRICES: Record<string, number> = {
  energy_100: 0.99,
  energy_550: 4.99,
  energy_1200: 7.99,
  energy_2000: 9.99,
};

function estimateRevenue(productId?: string): number {
  if (!productId) return 0;
  return PRODUCT_PRICES[productId] || 0;
}
