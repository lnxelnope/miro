import { initializeApp, getApps, cert } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

// Initialize Firebase Admin SDK
if (!getApps().length) {
  try {
    // Option 1: Use service account JSON file (Development)
    if (process.env.NODE_ENV === 'development') {
      const serviceAccount = require('../../serviceAccountKey.json');
      
      initializeApp({
        credential: cert(serviceAccount),
        projectId: 'miro-d6856',
      });
      
      console.log('✅ Firebase Admin initialized with service account');
    } 
    // Option 2: Use environment variables (Production)
    else if (process.env.FIREBASE_PROJECT_ID && process.env.FIREBASE_CLIENT_EMAIL && process.env.FIREBASE_PRIVATE_KEY) {
      initializeApp({
        credential: cert({
          projectId: process.env.FIREBASE_PROJECT_ID,
          clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
          privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
        }),
      });
      
      console.log('✅ Firebase Admin initialized with env vars');
    } else {
      // Skip initialization during build time if credentials are not available
      console.warn('⚠️  Firebase Admin credentials not found - skipping initialization (build time)');
    }
  } catch (error) {
    console.error('❌ Firebase Admin initialization error:', error);
    // Don't throw error during build
    if (process.env.NODE_ENV !== 'production') {
      console.warn('⚠️  Continuing without Firebase Admin (build time)');
    } else {
      throw error;
    }
  }
}

export const db = getApps().length > 0 ? getFirestore() : null as any;
export const adminApp = getApps()[0] || null;
