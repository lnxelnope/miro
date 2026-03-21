import type { Metadata } from 'next';
import './globals.css';
import { ConditionalChrome } from '@/components/ConditionalChrome';

export const metadata: Metadata = {
  title: 'MiRO — The Most Accurate AI Food Tracker',
  description:
    'Snap, type, or chat — MiRO deconstructs every meal into individual ingredients with AI precision. No login. No subscription trap. Your data stays on your device.',
  keywords: [
    'food tracker',
    'calorie counter',
    'AI nutrition',
    'macro tracker',
    'meal logger',
    'food diary',
    'calorie app',
    'MiRO',
  ],
  metadataBase: new URL('https://www.tnbgrp.com/miro'),
  openGraph: {
    title: 'MiRO — The Most Accurate AI Food Tracker',
    description:
      'AI-powered food tracking with ingredient-level accuracy. No login required. Your data stays on your device.',
    url: 'https://www.tnbgrp.com/miro',
    siteName: 'MiRO',
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'MiRO — The Most Accurate AI Food Tracker',
    description:
      'AI-powered food tracking with ingredient-level accuracy. No login required.',
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
        <ConditionalChrome>{children}</ConditionalChrome>
      </body>
    </html>
  );
}
