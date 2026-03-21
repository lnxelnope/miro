import { initializeApp, getApps, cert, App } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import * as path from 'path';
import * as fs from 'fs';

function serviceAccountPath(): string {
  return path.join(process.cwd(), 'serviceAccountKey.json');
}

function tryInitFromEnv(): boolean {
  if (getApps().length) return true;
  if (!process.env.FIREBASE_PROJECT_ID || !process.env.FIREBASE_CLIENT_EMAIL || !process.env.FIREBASE_PRIVATE_KEY) {
    return false;
  }
  initializeApp({
    credential: cert({
      projectId: process.env.FIREBASE_PROJECT_ID,
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
      privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
    }),
  });
  console.log('✅ Firebase Admin initialized with environment variables');
  return true;
}

function tryInitFromFile(): boolean {
  if (getApps().length) return true;
  const p = serviceAccountPath();
  if (!fs.existsSync(p)) return false;
  const serviceAccount = JSON.parse(fs.readFileSync(p, 'utf8'));
  initializeApp({
    credential: cert(serviceAccount),
    projectId: serviceAccount.project_id,
  });
  console.log('✅ Firebase Admin initialized with service account from:', p);
  return true;
}

/** Try env first, then serviceAccountKey.json (local dev). */
function tryInitializeFirebase(): void {
  if (getApps().length) return;

  try {
    if (tryInitFromEnv()) return;
  } catch (e) {
    console.error('❌ Firebase env credentials failed, trying serviceAccountKey.json:', e);
  }

  try {
    if (tryInitFromFile()) return;
  } catch (e) {
    console.error('❌ serviceAccountKey.json failed:', e);
  }

  if (getApps().length === 0) {
    console.warn(
      '⚠️ Firebase Admin credentials not found — set FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, FIREBASE_PRIVATE_KEY in .env.local or add serviceAccountKey.json in the admin-panel folder (see .env.example)',
    );
    if (process.env.NODE_ENV === 'production') {
      console.warn('⚠️ Will retry initialization at runtime on first DB use');
    }
  }
}

// Initialize on module load (may skip if no creds — e.g. build time)
tryInitializeFirebase();

function ensureInitialized(): void {
  if (getApps().length) return;
  tryInitializeFirebase();
  if (getApps().length === 0) {
    throw new Error(
      'Firebase credentials not available. Add FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, FIREBASE_PRIVATE_KEY to .env.local or place serviceAccountKey.json in the admin-panel directory.',
    );
  }
}

export const getDB = () => {
  ensureInitialized();
  return getFirestore();
};

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
  },
);

export const adminApp = getApps().length > 0 ? getApps()[0] : null;

export const getAdminApp = (): App => {
  ensureInitialized();
  const apps = getApps();
  if (!apps.length) {
    throw new Error('Firebase Admin app not initialized');
  }
  return apps[0];
};
