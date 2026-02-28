import { NextResponse } from 'next/server';
import { db } from '@/lib/firebase-admin';

/**
 * Test Firebase Admin connection
 * GET /api/test
 */
export async function GET() {
  try {
    // Try to read from Firestore
    const usersRef = db.collection('users');
    const snapshot = await usersRef.limit(1).get();
    
    return NextResponse.json({
      success: true,
      message: '✅ Firebase Admin connected successfully!',
      userCount: snapshot.size,
      timestamp: new Date().toISOString(),
    });
  } catch (error: any) {
    console.error('❌ Firebase Admin connection error:', error);
    return NextResponse.json({
      success: false,
      error: error.message,
    }, { status: 500 });
  }
}
