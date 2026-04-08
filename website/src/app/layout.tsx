import type { Metadata } from 'next';
import './globals.css';
import { ConditionalChrome } from '@/components/ConditionalChrome';
import { GoogleAnalytics } from '@/components/GoogleAnalytics';
import { ArCalJsonLd } from '@/components/ArCalJsonLd';
import { SITE_URL } from '@/lib/site';

const ogImages = [
  {
    url: '/arcal/screens/store-ar-precision.png',
    width: 473,
    height: 1024,
    type: 'image/png',
    alt: 'ArCal — AI calorie counter with AR food scan (App Store creative)',
  },
  {
    url: '/arcal/screens/store-snap-ingredients-recipe.png',
    width: 473,
    height: 1024,
    type: 'image/png',
    alt: 'ArCal — snap ingredients with scale, analyze, merge into private recipe',
  },
  {
    url: '/arcal/screens/store-sub-ingredients.png',
    width: 473,
    height: 1024,
    type: 'image/png',
    alt: 'ArCal — sub-ingredient precision for complex dishes',
  },
] as const;

export const metadata: Metadata = {
  title: 'ArCal — AI Calories Counter | Precise Calories, Zero Effort',
  description:
    'AI calorie counter for people who want to lose weight but hate manual logging: pull to refresh to load food photos from your gallery, tap Analyze All once for a rough daily total — a good start for awareness. Then edit any line, add ingredients, or use AR & chat. Free to start. No login. Android & iOS. Thai: tnbgrp.com/miro/th/',
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
    'homemade food tracker',
    'kitchen scale calorie app',
    'recipe maker app',
    'merge meals recipe',
    'private recipe database',
    'local food database',
    'fair AI calories',
    'free AI calorie counter',
    'AI meal builder',
    'create menu with AI',
    'edit food log after AI',
    'delete ingredients from meal log',
    'add ingredients to food diary',
    'AI ingredient lookup',
    'tell AI what is in my food',
    'customizable AI food tracker',
    'แอปนับแคล AI',
    'สร้างเมนูด้วย AI',
    'แก้ไขรายการอาหาร ลบวัตถุดิบ',
    'AI ค้นหาวัตถุดิบ',
    'lazy calorie counter',
    'weight loss without counting every calorie',
    'pull to refresh analyze all food photos',
    'batch calorie estimate',
    'lose weight lazy calorie tracking',
    'no paywall calorie app',
    'free calorie app no paywall',
  ],
  metadataBase: new URL(SITE_URL),
  alternates: {
    canonical: '/',
    languages: {
      en: '/',
      th: '/th/',
    },
  },
  openGraph: {
    title: 'ArCal — AI Calories Counter',
    description:
      'Free-to-start, no paywall: AI calories, edit/delete/add lines, ingredient lookup — pull to refresh & Analyze All. AR scan. Local My Meals.',
    url: SITE_URL,
    siteName: 'ArCal',
    type: 'website',
    locale: 'en_US',
    images: [...ogImages],
  },
  twitter: {
    card: 'summary_large_image',
    title: 'ArCal — AI Calories Counter',
    description:
      'Free AI calorie app: create menus with AI, edit & delete lines, add items, AI ingredient search — ArCal. AR + local recipes.',
    images: {
      url: '/arcal/screens/store-ar-precision.png',
      width: 473,
      height: 1024,
      alt: 'ArCal — AR food scan and AI calorie counter',
    },
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
        <ArCalJsonLd />
        <GoogleAnalytics />
        <ConditionalChrome>{children}</ConditionalChrome>
      </body>
    </html>
  );
}
