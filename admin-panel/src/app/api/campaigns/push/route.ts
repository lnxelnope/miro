import { NextRequest, NextResponse } from 'next/server';
import { db, getAdminApp } from '@/lib/firebase-admin';
import { getMessaging } from 'firebase-admin/messaging';
import { Timestamp } from 'firebase-admin/firestore';

export async function POST(req: NextRequest) {
  try {
    const { title, body, targetSegment } = await req.json();

    if (!title || !body) {
      return NextResponse.json(
        { success: false, error: 'Title and body are required' },
        { status: 400 }
      );
    }

    const messaging = getMessaging(getAdminApp());

    // Query users based on target segment
    let usersQuery = db.collection('users');

    if (targetSegment === 'subscribers') {
      usersQuery = usersQuery.where('subscription.status', '==', 'active') as any;
    } else if (targetSegment === 'non_subscribers') {
      usersQuery = usersQuery.where('subscription.status', '!=', 'active') as any;
    } else if (['bronze', 'silver', 'gold', 'diamond'].includes(targetSegment)) {
      usersQuery = usersQuery.where('tier', '==', targetSegment) as any;
    }

    // Limit to 1000 users per batch (FCM limit)
    const snapshot = await usersQuery.limit(1000).get();
    const tokens: string[] = [];

    snapshot.forEach((doc) => {
      const data = doc.data();
      const fcmToken = data.fcmToken || data.notifications?.fcmToken;
      if (fcmToken && typeof fcmToken === 'string') {
        tokens.push(fcmToken);
      }
    });

    if (tokens.length === 0) {
      return NextResponse.json({
        success: false,
        error: 'No users found with FCM tokens in the selected segment',
      });
    }

    // Send multicast notification
    const result = await messaging.sendEachForMulticast({
      tokens,
      notification: {
        title,
        body,
      },
      android: {
        priority: 'high' as const,
      },
      apns: {
        headers: {
          'apns-priority': '10',
        },
      },
    });

    // Clean up invalid tokens (optional - can be done async)
    const invalidTokens: string[] = [];
    result.responses.forEach((response, idx) => {
      if (!response.success && response.error) {
        const errorCode = response.error.code;
        if (
          errorCode === 'messaging/invalid-registration-token' ||
          errorCode === 'messaging/registration-token-not-registered'
        ) {
          invalidTokens.push(tokens[idx]);
        }
      }
    });

    // Remove invalid tokens from Firestore (async, don't wait)
    if (invalidTokens.length > 0) {
      const { FieldValue } = await import('firebase-admin/firestore');
      const batch = db.batch();
      snapshot.forEach((doc) => {
        const data = doc.data();
        const fcmToken = data.fcmToken || data.notifications?.fcmToken;
        if (invalidTokens.includes(fcmToken)) {
          batch.update(doc.ref, {
            fcmToken: FieldValue.delete(),
            'notifications.fcmToken': FieldValue.delete(),
          });
        }
      });
      batch.commit().catch((err) => {
        console.error('Error cleaning up invalid tokens:', err);
      });
    }

    // Save campaign history to Firestore
    const campaignData = {
      title,
      body,
      targetSegment,
      sentCount: result.successCount,
      failedCount: result.failureCount,
      totalTokens: tokens.length,
      createdAt: Timestamp.now(),
      status: result.failureCount === 0 ? 'success' : 'partial',
    };
    
    await db.collection('push_campaigns').add(campaignData);

    return NextResponse.json({
      success: true,
      sentCount: result.successCount,
      failedCount: result.failureCount,
      totalTokens: tokens.length,
      campaignId: campaignData.createdAt.toMillis().toString(),
    });
  } catch (error: any) {
    console.error('Error sending push notification:', error);
    return NextResponse.json(
      {
        success: false,
        error: error.message || 'Failed to send push notification',
      },
      { status: 500 }
    );
  }
}
