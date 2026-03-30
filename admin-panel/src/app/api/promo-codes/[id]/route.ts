import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { checkAuth } from '@/lib/auth';
import { Timestamp } from 'firebase-admin/firestore';

function parseExpiryAt(value: unknown): Timestamp | null | undefined {
  if (value === undefined) return undefined;
  if (value === null || value === '') return null;
  if (typeof value !== 'string') return undefined;
  const d = new Date(value);
  if (Number.isNaN(d.getTime())) return undefined;
  return Timestamp.fromDate(d);
}

function normalizeRewardPayload(
  rewardType: string,
  payload: Record<string, unknown> | undefined
): { amount?: number; days?: number } | undefined {
  if (payload === undefined) return undefined;
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

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const authError = await checkAuth(request);
    if (authError) return authError;

    const { id } = await params;
    const doc = await db.collection('promo_codes').doc(id).get();

    if (!doc.exists) {
      return NextResponse.json(
        { success: false, error: 'Promo code not found' },
        { status: 404 }
      );
    }

    const data = doc.data()!;
    return NextResponse.json({
      success: true,
      promoCode: {
        id: doc.id,
        ...data,
        createdAt: data.createdAt?.toDate?.()?.toISOString() || null,
        updatedAt: data.updatedAt?.toDate?.()?.toISOString() || null,
        expiryAt: data.expiryAt?.toDate?.()?.toISOString() || null,
      },
    });
  } catch (error: any) {
    console.error('Error fetching promo_codes:', error);
    return NextResponse.json(
      { success: false, error: error.message },
      { status: 500 }
    );
  }
}

export async function PUT(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const authError = await checkAuth(request);
    if (authError) return authError;

    const { id } = await params;
    const docRef = db.collection('promo_codes').doc(id);
    const doc = await docRef.get();
    if (!doc.exists) {
      return NextResponse.json(
        { success: false, error: 'Promo code not found' },
        { status: 404 }
      );
    }

    const existing = doc.data()!;
    const body = await request.json();

    const effectiveRewardType = body.rewardType ?? existing.rewardType;
    if (
      body.rewardType !== undefined &&
      body.rewardType !== 'energy' &&
      body.rewardType !== 'freepass'
    ) {
      return NextResponse.json(
        { success: false, error: 'rewardType must be energy or freepass' },
        { status: 400 }
      );
    }

    const nextPayload =
      body.rewardPayload !== undefined
        ? normalizeRewardPayload(effectiveRewardType, body.rewardPayload)
        : undefined;

    if (nextPayload !== undefined) {
      if (effectiveRewardType === 'energy' && !nextPayload.amount) {
        return NextResponse.json(
          { success: false, error: 'rewardPayload.amount must be >= 1 for energy' },
          { status: 400 }
        );
      }
      if (effectiveRewardType === 'freepass' && !nextPayload.days) {
        return NextResponse.json(
          { success: false, error: 'rewardPayload.days must be >= 1 for freepass' },
          { status: 400 }
        );
      }
    }

    if (body.maxRedemptions !== undefined) {
      if (typeof body.maxRedemptions !== 'number' || body.maxRedemptions < 0) {
        return NextResponse.json(
          { success: false, error: 'maxRedemptions must be a number >= 0' },
          { status: 400 }
        );
      }
    }
    if (body.perUserLimit !== undefined) {
      if (typeof body.perUserLimit !== 'number' || body.perUserLimit < 1) {
        return NextResponse.json(
          { success: false, error: 'perUserLimit must be >= 1' },
          { status: 400 }
        );
      }
    }

    const expiryParsed = parseExpiryAt(body.expiryAt);
    if (body.expiryAt !== undefined && expiryParsed === undefined && body.expiryAt !== null && body.expiryAt !== '') {
      return NextResponse.json(
        { success: false, error: 'expiryAt must be a valid ISO date string or null' },
        { status: 400 }
      );
    }

    const updateData: Record<string, unknown> = {
      updatedAt: Timestamp.now(),
    };

    if (body.active !== undefined) updateData.active = Boolean(body.active);
    if (body.rewardType !== undefined) updateData.rewardType = body.rewardType;
    if (nextPayload !== undefined) updateData.rewardPayload = nextPayload;
    if (body.maxRedemptions !== undefined)
      updateData.maxRedemptions = Math.floor(body.maxRedemptions);
    if (body.perUserLimit !== undefined)
      updateData.perUserLimit = Math.floor(body.perUserLimit);
    if (body.expiryAt !== undefined) updateData.expiryAt = expiryParsed ?? null;

    await docRef.update(updateData);

    return NextResponse.json({ success: true });
  } catch (error: any) {
    console.error('Error updating promo_codes:', error);
    return NextResponse.json(
      { success: false, error: error.message },
      { status: 500 }
    );
  }
}

export async function DELETE(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const authError = await checkAuth(request);
    if (authError) return authError;

    const { id } = await params;
    const docRef = db.collection('promo_codes').doc(id);
    const doc = await docRef.get();

    if (!doc.exists) {
      return NextResponse.json(
        { success: false, error: 'Promo code not found' },
        { status: 404 }
      );
    }

    await docRef.delete();

    return NextResponse.json({ success: true });
  } catch (error: any) {
    console.error('Error deleting promo_codes:', error);
    return NextResponse.json(
      { success: false, error: error.message },
      { status: 500 }
    );
  }
}
