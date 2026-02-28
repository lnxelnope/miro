import { NextRequest, NextResponse } from 'next/server';
import { checkAuth } from '@/lib/auth';
import { db, getAdminApp } from '@/lib/firebase-admin';
import * as admin from 'firebase-admin';
import { getMessaging } from 'firebase-admin/messaging';

/**
 * POST /api/notifications/send
 * Send notification to specific user(s) or all users
 */
export async function POST(request: NextRequest) {
  try {
    const authCheck = await checkAuth(request);
    if (authCheck instanceof NextResponse) {
      return authCheck;
    }

    const body = await request.json();
    const { deviceId, miroId, title, body: messageBody, data, sendToAll } = body;

    if (!title || !messageBody) {
      return NextResponse.json(
        { error: 'Title and body are required' },
        { status: 400 }
      );
    }

    const messages: admin.messaging.Message[] = [];

    if (sendToAll) {
      // Send to all users with FCM tokens
      const usersSnapshot = await db
        .collection('users')
        .where('fcmToken', '!=', null)
        .where('isBanned', '==', false)
        .get();

      usersSnapshot.docs.forEach((doc: any) => {
        const user = doc.data();
        if (user.fcmToken) {
          messages.push({
            token: user.fcmToken,
            notification: {
              title,
              body: messageBody,
            },
            data: data || {},
            android: {
              priority: 'high' as const,
            },
          });
        }
      });
    } else if (deviceId) {
      // Send to specific user by deviceId
      const userDoc = await db.collection('users').doc(deviceId).get();
      if (!userDoc.exists) {
        return NextResponse.json(
          { error: 'User not found' },
          { status: 404 }
        );
      }

      const user = userDoc.data()!;
      if (!user.fcmToken) {
        return NextResponse.json(
          { error: 'User does not have FCM token' },
          { status: 400 }
        );
      }

      if (user.isBanned) {
        return NextResponse.json(
          { error: 'Cannot send notification to banned user' },
          { status: 400 }
        );
      }

      messages.push({
        token: user.fcmToken,
        notification: {
          title,
          body: messageBody,
        },
        data: data || {},
        android: {
          priority: 'high' as const,
        },
      });
    } else if (miroId) {
      // Send to specific user by MiRO ID
      const usersSnapshot = await db
        .collection('users')
        .where('miroId', '==', miroId)
        .limit(1)
        .get();

      if (usersSnapshot.empty) {
        return NextResponse.json(
          { error: 'User not found' },
          { status: 404 }
        );
      }

      const user = usersSnapshot.docs[0].data();
      if (!user.fcmToken) {
        return NextResponse.json(
          { error: 'User does not have FCM token' },
          { status: 400 }
        );
      }

      if (user.isBanned) {
        return NextResponse.json(
          { error: 'Cannot send notification to banned user' },
          { status: 400 }
        );
      }

      messages.push({
        token: user.fcmToken,
        notification: {
          title,
          body: messageBody,
        },
        data: data || {},
        android: {
          priority: 'high' as const,
        },
      });
    } else {
      return NextResponse.json(
        { error: 'deviceId, miroId, or sendToAll is required' },
        { status: 400 }
      );
    }

    if (messages.length === 0) {
      return NextResponse.json(
        { error: 'No valid recipients found' },
        { status: 400 }
      );
    }

    // Send notifications in batches (FCM limit: 500 per batch)
    const batchSize = 500;
    let sent = 0;
    let failed = 0;
    const errors: string[] = [];

    for (let i = 0; i < messages.length; i += batchSize) {
      const batch = messages.slice(i, i + batchSize);
      try {
        const messaging = getMessaging(getAdminApp());
        const result = await messaging.sendEach(batch);
        sent += result.successCount;
        failed += result.failureCount;

        // Collect errors
        result.responses.forEach((resp, idx) => {
          if (resp.error) {
            errors.push(`Token ${idx}: ${resp.error.message}`);
            
            // Clean up invalid tokens
            if (resp.error.code === 'messaging/registration-token-not-registered') {
              const message = batch[idx];
              // Type guard to check if message has token property
              if ('token' in message && message.token) {
                const fcmToken = message.token;
                db.collection('users')
                  .where('fcmToken', '==', fcmToken)
                  .get()
                  .then((snapshot: any) => {
                    snapshot.forEach((doc: any) => {
                      doc.ref.update({ fcmToken: null });
                    });
                  });
              }
            }
          }
        });
      } catch (err: any) {
        console.error('❌ [Notify] Batch send error:', err);
        failed += batch.length;
        errors.push(`Batch error: ${err.message}`);
      }
    }

    return NextResponse.json({
      success: true,
      sent,
      failed,
      total: messages.length,
      errors: errors.length > 0 ? errors : undefined,
    });
  } catch (error: any) {
    console.error('Send notification error:', error);
    return NextResponse.json(
      { error: 'Failed to send notification' },
      { status: 500 }
    );
  }
}
