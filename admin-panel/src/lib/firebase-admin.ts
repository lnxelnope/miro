import { initializeApp, getApps, cert } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import * as path from 'path';
import * as fs from 'fs';

// Initialize Firebase Admin SDK
if (!getApps().length) {
  try {
    // Option 1: Use environment variables (preferred for production)
    if (process.env.FIREBASE_PROJECT_ID && process.env.FIREBASE_CLIENT_EMAIL && process.env.FIREBASE_PRIVATE_KEY) {
      initializeApp({
        credential: cert({
          projectId: process.env.FIREBASE_PROJECT_ID,
          clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
          privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
        }),
      });
      
      console.log('✅ Firebase Admin initialized with environment variables');
    }
    // Option 2: Use service account JSON file (fallback for development)
    else {
      const serviceAccountPath = path.join(process.cwd(), 'serviceAccountKey.json');
      
      if (fs.existsSync(serviceAccountPath)) {
        const serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, 'utf8'));
        
        initializeApp({
          credential: cert(serviceAccount),
          projectId: serviceAccount.project_id,
        });
        
        console.log('✅ Firebase Admin initialized with service account from:', serviceAccountPath);
      } else {
        // Skip initialization during build time - will initialize at runtime
        console.warn('⚠️ Firebase Admin credentials not found - skipping initialization (build time)');
      }
    }
  } catch (error) {
    console.error('❌ Firebase Admin initialization error:', error);
    // Don't throw during build - let it initialize at runtime
    if (process.env.NODE_ENV === 'production') {
      console.warn('⚠️ Will retry initialization at runtime');
    }
  }
}

// Lazy initialization helper
function ensureInitialized() {
  if (!getApps().length) {
    // Try to initialize now if we're at runtime
    if (process.env.FIREBASE_PROJECT_ID && process.env.FIREBASE_CLIENT_EMAIL && process.env.FIREBASE_PRIVATE_KEY) {
      try {
        initializeApp({
          credential: cert({
            projectId: process.env.FIREBASE_PROJECT_ID,
            clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
            privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
          }),
        });
        console.log('✅ Firebase Admin initialized at runtime');
      } catch (error) {
        console.error('❌ Runtime Firebase initialization failed:', error);
        throw new Error('Firebase Admin not initialized');
      }
    } else {
      throw new Error('Firebase credentials not available');
    }
  }
}

// Export lazy-initialized db
export const getDB = () => {
  ensureInitialized();
  return getFirestore();
};

// Proxy-based db export: lazily initializes Firebase on first use
// This ensures db.collection(...) always works, even if Firebase
// wasn't initialized at module load time (e.g. during Next.js build)
export const db: ReturnType<typeof getFirestore> = new Proxy(
  {} as ReturnType<typeof getFirestore>,
  {
    get(_target, prop, _receiver) {
      const instance = getDB();
      const value = (instance as any)[prop];
      if (typeof value === 'function') {
        return value.bind(instance);
      }
      return value;
    },
  }
);

export const adminApp = getApps().length > 0 ? getApps()[0] : null;

// Export lazy-initialized admin app (for messaging, etc.)
export const getAdminApp = () => {
  ensureInitialized();
  const apps = getApps();
  if (!apps.length) {
    throw new Error('Firebase Admin app not initialized');
  }
  return apps[0];
};
