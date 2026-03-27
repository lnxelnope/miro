import Script from 'next/script';

const GA_ID = process.env.NEXT_PUBLIC_GA_MEASUREMENT_ID;
/** Google Ads tag (conversion / remarketing) — รูปแบบ `AW-xxxxxxxxxx` */
const ADS_TAG_ID = process.env.NEXT_PUBLIC_GOOGLE_ADS_TAG_ID;

/**
 * Google tag (gtag.js): GA4 (`G-`) และ/หรือ Google Ads (`AW-`)
 *
 * - Google Ads “Test connection” มองหา `AW-...` ใน `gtag('config', ...)` — ต้องตั้ง
 *   `NEXT_PUBLIC_GOOGLE_ADS_TAG_ID` ให้ตรงกับที่ Google Ads แสดง
 * - GA4 ยังใช้ `NEXT_PUBLIC_GA_MEASUREMENT_ID` ได้ตามเดิม
 */
export function GoogleAnalytics() {
  if (!GA_ID && !ADS_TAG_ID) {
    return null;
  }

  // โหลดสคริปต์ด้วย AW ก่อน (ตรงกับ snippet ที่ Google Ads แนะนำ) ถ้ามีทั้งคู่
  const loaderId = ADS_TAG_ID ?? GA_ID!;

  const inlineConfig = (() => {
    const lines = [
      `window.dataLayer = window.dataLayer || [];`,
      `function gtag(){dataLayer.push(arguments);}`,
      `gtag('js', new Date());`,
    ];
    if (ADS_TAG_ID) {
      lines.push(`gtag('config', '${ADS_TAG_ID}');`);
    }
    if (GA_ID && GA_ID !== ADS_TAG_ID) {
      lines.push(
        `gtag('config', '${GA_ID}', { send_page_view: true });`,
      );
    } else if (GA_ID && !ADS_TAG_ID) {
      lines.push(
        `gtag('config', '${GA_ID}', { send_page_view: true });`,
      );
    }
    return lines.join('\n          ');
  })();

  return (
    <>
      <Script
        src={`https://www.googletagmanager.com/gtag/js?id=${loaderId}`}
        strategy="afterInteractive"
      />
      <Script id="google-analytics" strategy="afterInteractive">
        {inlineConfig}
      </Script>
    </>
  );
}
