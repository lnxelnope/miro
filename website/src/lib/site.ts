/**
 * Canonical public URL (ต้องตรงกับ metadataBase + path บน Firebase Hosting)
 */
export const SITE_URL = 'https://www.tnbgrp.com/miro' as const;

export function absoluteUrl(path: string): string {
  const p = path.startsWith('/') ? path : `/${path}`;
  return `${SITE_URL}${p}`;
}
