/**
 * Firebase Cloud Functions for MIRO Energy System
 * 
 * Export all functions here
 */

import { setGlobalOptions } from 'firebase-functions';

// Global options for cost control
setGlobalOptions({ 
  maxInstances: 10,
  region: 'us-central1',
});

// ───────────────────────────────────────────────────────────
// EXPORTS
// ───────────────────────────────────────────────────────────

// Energy System API
export { analyzeFood } from './analyzeFood';
export { syncBalance } from './syncBalance';
export { verifyPurchase } from './verifyPurchase';

// Transfer Key API
export { generateTransferKey, redeemTransferKey } from './transferKey';
