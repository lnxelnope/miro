import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';
import { checkAuth } from '@/lib/auth';
import { FieldValue } from 'firebase-admin/firestore';

export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ userId: string }> }
) {
  try {
    const authError = await checkAuth(request);
    if (authError) {
      return authError;
    }

    const { userId } = await params;
    const { action, days } = await request.json();

    const userRef = db.collection('users').doc(userId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return NextResponse.json(
        { error: 'User not found' },
        { status: 404 }
      );
    }

    const userData = userDoc.data()!;
    const currentSubscription = userData.subscription || {};

    if (action === 'cancel') {
      // Cancel subscription
      await userRef.update({
        'subscription.status': 'cancelled',
        'subscription.cancelledAt': FieldValue.serverTimestamp(),
        'isSubscriber': false,
        lastUpdated: FieldValue.serverTimestamp(),
      });

      return NextResponse.json({
        success: true,
        message: 'Subscription cancelled successfully',
      });
    } else if (action === 'extend') {
      // Extend subscription
      if (!days || days <= 0) {
        return NextResponse.json(
          { error: 'Invalid days value' },
          { status: 400 }
        );
      }

      const currentExpiry = currentSubscription.expiryDate?.toDate() || new Date();
      const newExpiry = new Date(currentExpiry);
      newExpiry.setDate(newExpiry.getDate() + days);

      await userRef.update({
        'subscription.expiryDate': newExpiry,
        'subscription.status': 'active',
        'isSubscriber': true,
        lastUpdated: FieldValue.serverTimestamp(),
      });

      return NextResponse.json({
        success: true,
        message: `Subscription extended by ${days} days`,
        newExpiryDate: newExpiry.toISOString(),
      });
    } else if (action === 'activate') {
      // Activate/reactivate subscription
      if (!days || days <= 0) {
        return NextResponse.json(
          { error: 'Invalid days value' },
          { status: 400 }
        );
      }

      const newExpiry = new Date();
      newExpiry.setDate(newExpiry.getDate() + days);

      await userRef.update({
        'subscription.status': 'active',
        'subscription.expiryDate': newExpiry,
        'subscription.activatedAt': FieldValue.serverTimestamp(),
        'isSubscriber': true,
        lastUpdated: FieldValue.serverTimestamp(),
      });

      return NextResponse.json({
        success: true,
        message: `Subscription activated for ${days} days`,
        newExpiryDate: newExpiry.toISOString(),
      });
    } else {
      return NextResponse.json(
        { error: 'Invalid action' },
        { status: 400 }
      );
    }
  } catch (error: any) {
    console.error('Subscription management error:', error);
    return NextResponse.json(
      { error: error.message },
      { status: 500 }
    );
  }
}
