import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { checkAuth } from '@/lib/auth';
import { Timestamp } from 'firebase-admin/firestore';

function parseExpiryAt(value: unknown): Timestamp | null {
  if (value === null || value === undefined || value === '') return null;
  if (typeof value !== 'string') return null;
  const d = new Date(value);
  if (Number.isNaN(d.getTime())) return null;
  return Timestamp.fromDate(d);
}

function normalizeRewardPayload(
  rewardType: string,
  payload: Record<string, unknown> | undefined
): { amount?: number; days?: number } {
  if (!payload || typeof payload !== 'object') return {};
  if (rewardType === 'energy') {
    const amount = Math.floor(Number(payload.amount) || 0);
    return amount > 0 ? { amount } : {};
  }
  if (rewardType === 'freepass') {
    const days = Math.floor(Number(payload.days) || 0);
    return days > 0 ? { days } : {};
  }
  return {};
}

// GET: list promo codes (newest first)
export async function GET(request: NextRequest) {
  try {
    const authError = await checkAuth(request);
    if (authError) return authError;

    const snapshot = await db
      .collection('promo_codes')
      .orderBy('createdAt', 'desc')
      .get();

    const promos = snapshot.docs.map((doc) => {
      const data = doc.data();
      return {
        id: doc.id,
        ...data,
        createdAt: data.createdAt?.toDate?.()?.toISOString() || null,
        updatedAt: data.updatedAt?.toDate?.()?.toISOString() || null,
        expiryAt: data.expiryAt?.toDate?.()?.toISOString() || null,
      };
    });

    return NextResponse.json({ success: true, promoCodes: promos });
  } catch (error: any) {
    console.error('Error fetching promo_codes:', error);
    return NextResponse.json(
      { success: false, error: error.message },
      { status: 500 }
    );
  }
}

// POST: create promo code
export async function POST(request: NextRequest) {
  try {
    const authError = await checkAuth(request);
    if (authError) return authError;

    const body = await request.json();
    const rawCode = typeof body.code === 'string' ? body.code.trim() : '';
    const rewardType = body.rewardType;
    const rewardPayload = normalizeRewardPayload(rewardType, body.rewardPayload);

    if (!rawCode) {
      return NextResponse.json(
        { success: false, error: 'code is required' },
        { status: 400 }
      );
    }

    if (rewardType !== 'energy' && rewardType !== 'freepass') {
      return NextResponse.json(
        { success: false, error: 'rewardType must be energy or freepass' },
        { status: 400 }
      );
    }

    if (rewardType === 'energy' && !rewardPayload.amount) {
      return NextResponse.json(
        { success: false, error: 'rewardPayload.amount must be >= 1 for energy' },
        { status: 400 }
      );
    }
    if (rewardType === 'freepass' && !rewardPayload.days) {
      return NextResponse.json(
        { success: false, error: 'rewardPayload.days must be >= 1 for freepass' },
        { status: 400 }
      );
    }

    const normalizedCode = rawCode.toUpperCase();
    const dup = await db
      .collection('promo_codes')
      .where('code', '==', normalizedCode)
      .limit(1)
      .get();
    if (!dup.empty) {
      return NextResponse.json(
        { success: false, error: 'A promo code with this value already exists' },
        { status: 400 }
      );
    }

    const maxRedemptions =
      typeof body.maxRedemptions === 'number' && body.maxRedemptions >= 0
        ? Math.floor(body.maxRedemptions)
        : 0;
    const perUserLimit =
      typeof body.perUserLimit === 'number' && body.perUserLimit >= 1
        ? Math.floor(body.perUserLimit)
        : 1;
    const active = body.active !== false;
    const expiryAt = parseExpiryAt(body.expiryAt);

    const now = Timestamp.now();
    const docRef = db.collection('promo_codes').doc();
    await docRef.set({
      code: normalizedCode,
      active,
      rewardType,
      rewardPayload,
      maxRedemptions,
      perUserLimit,
      expiryAt,
      redemptionCount: 0,
      createdAt: now,
      updatedAt: now,
    });

    return NextResponse.json({ success: true, id: docRef.id });
  } catch (error: any) {
    console.error('Error creating promo_codes:', error);
    return NextResponse.json(
      { success: false, error: error.message },
      { status: 500 }
    );
  }
}
