import { initializeApp, getApps, cert } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

// Initialize Firebase Admin SDK
if (!getApps().length) {
  try {
    // Option 1: Use service account JSON file (Development)
    if (process.env.NODE_ENV === 'development') {
      const serviceAccount = require('../serviceAccountKey.json');
      
      initializeApp({
        credential: cert(serviceAccount),
        projectId: 'miro-d6856',
      });
      
      console.log('✅ Firebase Admin initialized with service account');
    } 
    // Option 2: Use environment variables (Production)
    else {
      initializeApp({
        credential: cert({
          projectId: process.env.FIREBASE_PROJECT_ID,
          clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
          privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
        }),
      });
      
      console.log('✅ Firebase Admin initialized with env vars');
    }
  } catch (error) {
    console.error('❌ Firebase Admin initialization error:', error);
    throw error;
  }
}

export const db = getFirestore();
export const adminApp = getApps()[0];

// Export lazy-initialized admin app (for messaging, etc.)
export const getAdminApp = () => {
  const apps = getApps();
  if (!apps.length) {
    throw new Error('Firebase Admin app not initialized');
  }
  return apps[0];
};
