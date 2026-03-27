/**
 * ติดตามคลิกออกไป Play / App Store สำหรับ Google Ads conversion และ GA4
 *
 * - ต้องมี gtag โหลดแล้ว (ดู GoogleAnalytics.tsx + NEXT_PUBLIC_GOOGLE_ADS_TAG_ID / GA)
 * - Conversion จริงใน Google Ads: สร้างเป้าหมาย "เว็บไซต์" แล้วใส่ send_to ใน env
 */

import { APP_STORE_URL, PLAY_STORE_URL } from '@/lib/storeUrls';

export type StoreOutboundKind = 'google_play' | 'apple_app_store';

declare global {
  interface Window {
    gtag?: (...args: unknown[]) => void;
  }
}

/** เรียกจาก onClick ก่อนเปิดแท็บใหม่ (หน้าเดิมยังอยู่ → gtag ส่งครบ) */
export function trackOutboundStoreClick(kind: StoreOutboundKind): void {
  if (typeof window === 'undefined') return;
  const gtag = window.gtag;
  if (typeof gtag !== 'function') return;

  const href = kind === 'google_play' ? PLAY_STORE_URL : APP_STORE_URL;

  // GA4 / Debug — ตั้งเป็น key event ใน GA4 ได้ถ้าต้องการ
  gtag('event', 'store_outbound_click', {
    store: kind,
    link_url: href,
  });

  const playSendTo = process.env.NEXT_PUBLIC_GOOGLE_ADS_CONV_PLAY_STORE;
  const iosSendTo = process.env.NEXT_PUBLIC_GOOGLE_ADS_CONV_APP_STORE;
  const sendTo = kind === 'google_play' ? playSendTo : iosSendTo;

  if (sendTo?.trim()) {
    gtag('event', 'conversion', {
      send_to: sendTo.trim(),
    });
  }
}
