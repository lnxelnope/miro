/**
 * syncBalance Cloud Function
 * 
 * Purpose: Sync balance between Client and Server
 * Use cases:
 * 1. App startup — Client ดึง balance จาก Server
 * 2. One-time migration — เมื่อ User เก่าใช้ app version ใหม่ครั้งแรก
 * 3. Manual sync — เมื่อ Client สงสัยว่า balance ไม่ตรง
 */

import { onRequest } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';

// Initialize Firebase Admin (ถ้ายังไม่ได้ init ใน analyzeFood.ts)
if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

interface SyncBalanceRequest {
  deviceId: string;
  localBalance?: number; // สำหรับ migration (optional)
  type: 'startup' | 'migration' | 'manual';
}

export const syncBalance = onRequest(
  {
    timeoutSeconds: 10,
    memory: '256MiB',
    cors: '*',
  },
  async (req, res) => {
    // Validate request method
    if (req.method !== 'POST') {
      res.status(405).json({ error: 'Method not allowed' });
      return;
    }

    try {
      const body = req.body as SyncBalanceRequest;
      const { deviceId, localBalance, type } = body;

      // Validate required fields
      if (!deviceId) {
        res.status(400).json({ error: 'Missing deviceId' });
        return;
      }

      console.log(`📡 [syncBalance] Request from ${deviceId} (type: ${type})`);

      // ─── Check if user exists in Firestore ───
      const docRef = db.collection('energy_balances').doc(deviceId);
      const doc = await docRef.get();

      if (!doc.exists) {
        // ─── User ไม่มีใน Firestore ───
        
        // Case 1: Migration — เอา localBalance ไปใช้ (one-time)
        if (localBalance !== undefined && localBalance > 0) {
          const migratedBalance = localBalance;
          
          await docRef.set({
            balance: migratedBalance,
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            migratedFrom: 'local_storage',
            migratedAt: admin.firestore.FieldValue.serverTimestamp(),
            welcomeGiftClaimed: true, // ถือว่าได้ welcome gift แล้ว
          });
          
          console.log(`🔄 [syncBalance] Migrated ${deviceId}: ${migratedBalance} from local`);
          
          res.status(200).json({
            success: true,
            balance: migratedBalance,
            action: 'migrated',
          });
          return;
        }
        
        // Case 2: New user — สร้างพร้อม welcome gift
        const welcomeBalance = 100;
        
        await docRef.set({
          balance: welcomeBalance,
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          welcomeGiftClaimed: true,
        });
        
        console.log(`🎁 [syncBalance] New user ${deviceId}: Welcome gift ${welcomeBalance}`);
        
        res.status(200).json({
          success: true,
          balance: welcomeBalance,
          action: 'created_with_welcome_gift',
        });
        return;
      }

      // ─── User มีใน Firestore แล้ว ───
      const serverBalance = doc.data()?.balance ?? 0;
      
      console.log(`✅ [syncBalance] Existing user ${deviceId}: ${serverBalance}`);
      
      res.status(200).json({
        success: true,
        balance: serverBalance,
        action: 'synced',
      });

    } catch (error: any) {
      console.error('❌ [syncBalance] Error:', error);
      res.status(500).json({ 
        error: 'Internal server error',
        message: error.message,
      });
    }
  }
);
