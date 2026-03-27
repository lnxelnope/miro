import type { Metadata } from 'next';
import './globals.css';
import { ConditionalChrome } from '@/components/ConditionalChrome';
import { GoogleAnalytics } from '@/components/GoogleAnalytics';

export const metadata: Metadata = {
  title: 'ArCal — AI Calories Counter | Precise Calories, Zero Effort',
  description:
    'The easiest AI calorie counter. AR scan or snap a photo — get accurate calories in seconds. No login, no setup, free tokens to start. Available on Android & iOS.',
  keywords: [
    'calorie counter',
    'AI calorie tracker',
    'AR food scanner',
    'food tracker',
    'macro tracker',
    'calorie app',
    'ArCal',
    'AI nutrition',
    'calorie counter app',
    'food diary',
  ],
  metadataBase: new URL('https://www.tnbgrp.com/miro'),
  openGraph: {
    title: 'ArCal — AI Calories Counter',
    description:
      'Precise calories, zero effort. AR scan or snap a photo — AI counts your calories instantly. No login required. Free tokens to start.',
    url: 'https://www.tnbgrp.com/miro',
    siteName: 'ArCal',
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'ArCal — AI Calories Counter',
    description:
      'Precise calories, zero effort. The easiest AI calorie counter with AR scan.',
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className="font-sans">
        <GoogleAnalytics />
        <ConditionalChrome>{children}</ConditionalChrome>
      </body>
    </html>
  );
}
