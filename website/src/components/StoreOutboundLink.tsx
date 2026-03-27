'use client';

import type { ReactNode } from 'react';
import {
  trackOutboundStoreClick,
  type StoreOutboundKind,
} from '@/lib/gtagStore';

type Props = {
  href: string;
  store: StoreOutboundKind;
  className?: string;
  children: ReactNode;
  'aria-label'?: string;
};

/** ลิงก์ไปสโตร์พร้อมยิง gtag (Google Ads conversion + event สำหรับ GA4) */
export function StoreOutboundLink({
  href,
  store,
  className,
  children,
  'aria-label': ariaLabel,
}: Props) {
  return (
    <a
      href={href}
      target="_blank"
      rel="noopener noreferrer"
      className={className}
      aria-label={ariaLabel}
      onClick={() => trackOutboundStoreClick(store)}
    >
      {children}
    </a>
  );
}
