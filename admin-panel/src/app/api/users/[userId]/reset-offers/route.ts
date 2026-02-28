import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { checkAuth } from '@/lib/auth';
import { FieldValue, Timestamp } from 'firebase-admin/firestore';

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ userId: string }> }
) {
  try {
    const authError = await checkAuth(request);
    if (authError) return authError;

    const { userId } = await params;
    const userRef = db.collection('users').doc(userId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return NextResponse.json({ error: 'User not found' }, { status: 404 });
    }

    const userData = userDoc.data()!;

    const body = await request.json().catch(() => ({}));
    const makeAvailable = body.makeAvailable !== false; // default true

    const fourHoursFromNow = new Date(Date.now() + 4 * 60 * 60 * 1000);
    const twentyFourHoursFromNow = new Date(Date.now() + 24 * 60 * 60 * 1000);

    const resetOffers: Record<string, any> = {
      offers: {
        firstPurchaseClaimed: false,
        firstPurchaseAvailable: makeAvailable,
        firstPurchaseExpiry: makeAvailable
          ? Timestamp.fromDate(fourHoursFromNow)
          : null,
        firstPurchaseClaimedAt: null,
        welcomeBonusClaimed: false,
        welcomeBonusAvailable: makeAvailable,
        welcomeBonusExpiry: makeAvailable
          ? Timestamp.fromDate(twentyFourHoursFromNow)
          : null,
        welcomeBonusClaimedAt: null,
      },
      
      promotions: {
        welcomeOfferClaimed: false,
        welcomeBackClaimed: false,
        tierPromoClaimed: {},
        tierPromoAt: {},
        tierRewardClaimed: {},
      },
      
      winbackOfferAvailable: false,
      winbackOfferExpiry: null,
      subUpsellAvailable: false,
      subUpsellShown: false,
      
      lastUpdated: FieldValue.serverTimestamp(),
    };

    await userRef.update(resetOffers);

    // Log audit trail
    await db.collection('adminLogs').add({
      action: 'reset_offers',
      targetUserId: userId,
      targetMiroId: userData.miroId || '',
      previousState: {
        offers: userData.offers || {},
        promotions: userData.promotions || {},
      },
      timestamp: FieldValue.serverTimestamp(),
    });

    return NextResponse.json({
      success: true,
      message: 'All offers reset successfully',
    });
  } catch (error) {
    console.error('Reset offers error:', error);
    return NextResponse.json(
      { error: 'Failed to reset offers' },
      { status: 500 }
    );
  }
}
