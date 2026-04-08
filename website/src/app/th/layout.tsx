import type { Metadata } from 'next';
import { ThaiJsonLd } from '@/components/ThaiJsonLd';
import { SITE_URL } from '@/lib/site';

export const metadata: Metadata = {
  title:
    'ArCal — แอปนับแคล AI สำหรับคนขี้เกียจนับแคล | ลดน้ำหนัก เริ่มง่าย',
  description:
    'อยากลดน้ำหนักแต่ขี้เกียจนับแคล? ไม่มี paywall กั้นตั้งแต่เปิดแอป — ดึงรูปอาหาร (Pull to refresh) แล้วกด Analyze All ปุ่มเดียว รู้แคลอรี่โดยประมาณ แก้ไข ลบ บอกส่วนผสมได้ ไม่ต้องล็อกอิน',
  keywords: [
    'ลดน้ำหนัก',
    'ขี้เกียจนับแคล',
    'แอปนับแคล AI',
    'นับแคลอรี่ ง่าย',
    'Analyze All',
    'แอปลดน้ำหนัก',
    'ArCal',
    'นับแคลไม่ต้องจดทุกมื้อ',
    'ถ่ายรูปอาหาร นับแคล',
    'AI นับแคลอรี่',
    'ดึงรูปอาหาร วิเคราะห์',
  ],
  metadataBase: new URL(SITE_URL),
  alternates: {
    canonical: '/th/',
    languages: {
      en: '/',
      th: '/th/',
    },
  },
  openGraph: {
    title: 'ArCal — แอปนับแคล AI สำหรับคนขี้เกียจนับแคล',
    description:
      'Pull to refresh ดึงรูปมื้อที่ถ่ายไว้ กด Analyze All ปุ่มเดียว — เริ่มรู้แคลได้แม้ไม่สมบูรณ์ 100%',
    url: `${SITE_URL}/th/`,
    siteName: 'ArCal',
    type: 'website',
    locale: 'th_TH',
    images: [
      {
        url: '/arcal/screens/dashboard.png',
        width: 1242,
        height: 2688,
        type: 'image/png',
        alt: 'ArCal — แดชบอร์ดวิเคราะห์มื้ออาหาร',
      },
    ],
  },
  twitter: {
    card: 'summary_large_image',
    title: 'ArCal — แอปนับแคล AI สำหรับคนขี้เกียจนับแคล',
    description:
      'ดึงรูปอาหาร → กด Analyze All ปุ่มเดียว เริ่มลดน้ำหนักโดยไม่ต้องจดทุกคำ',
    images: {
      url: '/arcal/screens/dashboard.png',
      alt: 'ArCal แดชบอร์ด',
    },
  },
};

export default function ThLayout({ children }: { children: React.ReactNode }) {
  return (
    <>
      <ThaiJsonLd />
      {children}
    </>
  );
}
