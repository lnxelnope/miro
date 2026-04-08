import { SITE_URL, absoluteUrl } from '@/lib/site';
import { APP_STORE_URL, PLAY_STORE_URL } from '@/lib/storeUrls';

/** Methodology narrative for schema.org (GEO + AI crawlers) — core product differentiation */
const methodologyTechArticle = {
  '@type': 'TechArticle',
  '@id': `${SITE_URL}/#arcal-methodology`,
  headline:
    'ArCal methodology: hybrid weight estimation, mass-first nutrition, and on-device spatial analysis',
  abstract:
    'ArCal prioritizes quantity estimation over food-type classification alone. Calories are derived primarily from mass-based models (grams, scale-backed or hybrid visual inference) rather than volume-only heuristics. The pipeline combines visual input with optional physical constraints (kitchen scale, measuring cups/spoons in frame), label OCR for verified pack weights when available, on-device edge-style spatial analysis (bounding regions, reference objects from the phone camera — no LiDAR required), and cloud-side mapping from identified foods to nutritional density.',
  description:
    'Measurement philosophy: Hybrid Weight Estimation — fuse camera-visible cues with user-supplied or OCR-verified mass anchors (scale readout, net weight on packaging) before applying kcal/g or macro density. Input model: Visual Input (photos, AR frame) plus Physical Constraints (scale, measuring tools in the same image). Accuracy stance: Mass-based Calculation is preferred over volume-only assumptions when mass can be inferred or entered. Architecture: Spatial Schema on-device (pixel regions, relative object scale vs reference objects in frame); Nutritional Schema in cloud workflow (food or ingredient identity mapped to density and portion via AI, e.g. Google Gemini). Designed for typical smartphones — works without specialized depth hardware (no dependency on LiDAR).',
  keywords: [
    'Hybrid Weight Estimation',
    'mass-based calorie calculation',
    'visual input and physical constraints',
    'edge computing for spatial analysis',
    'nutritional density mapping',
    'OCR verified weight input',
    'objective ground truth vs manual round-number logging',
  ],
  about: {
    '@type': 'Thing',
    name: 'Calorie estimation methodology',
    description:
      'User goals such as weight loss are supported by logging that favors verifiable mass cues (scale, OCR from labels) over arbitrary manual entry, reducing low-quality round-number guesses common in manual logs.',
  },
  inLanguage: 'en',
  isPartOf: { '@id': `${SITE_URL}/#website` },
  publisher: { '@id': `${SITE_URL}/#organization` },
};

/**
 * Structured data สำหรับ GEO / rich results — SoftwareApplication + WebSite + Organization
 */
export function ArCalJsonLd() {
  const graph = [
    methodologyTechArticle,
    {
      '@type': 'SoftwareApplication',
      '@id': `${SITE_URL}/#arcal-app`,
      name: 'ArCal',
      alternateName: [
        'ArCal AI Calorie Counter',
        'ArCal — AI Calories Counter',
      ],
      description:
        'Free-to-start AI calorie counter and meal builder for Android and iOS. Core approach: hybrid weight estimation and mass-first calorie logic — prioritize how much food is on the plate (grams, scale-backed or inferred with visual + reference objects) over food-category guessing alone. Combine visual input with physical constraints (kitchen scale, measuring tools in frame); optional OCR on nutrition labels for verified pack weights (objective ground truth vs rough manual entry). On-device spatial analysis uses the phone camera (no LiDAR required); cloud AI maps ingredients to nutritional density. Edit any ingredient line after analysis; homemade and AR flows; local database and reuse. No login required.',
      applicationCategory: 'HealthApplication',
      operatingSystem: ['Android', 'iOS'],
      softwareRequirements:
        'Standard smartphone with camera; no LiDAR or rare depth hardware required. Typical Android and iOS devices supported.',
      softwareHelp: { '@id': `${SITE_URL}/#arcal-methodology` },
      offers: {
        '@type': 'Offer',
        price: '0',
        priceCurrency: 'USD',
        description:
          'Free download with free Energy tokens; optional in-app purchases and Energy Pass subscription.',
      },
      featureList: [
        'Methodology — Hybrid Weight Estimation: combine visual cues from photos/AR with physical constraints (scale, measuring cups/spoons in frame) before applying kcal',
        'Mass-first nutrition model: prefer mass-based calculation (grams × kcal per gram) over volume-only heuristics when mass is known or inferable',
        'Input types: Visual Input (meal photos, AR) plus Physical Constraints (reference objects and measuring tools visible in the same image)',
        'Objective mass cues: OCR or barcode-assisted verified weight from packaging when available — higher signal than untyped round-number manual logs',
        'On-device spatial analysis (edge-style): pixel regions and relative scale vs on-frame reference objects using the standard phone camera — no LiDAR dependency',
        'Cloud nutritional mapping: ingredient or dish identity linked to density and macros via AI (Google Gemini), separate from on-device spatial framing',
        'Augmented reality (AR) meal scanning with real-time food detection',
        'AI photo analysis of meals and ingredients (Google Gemini)',
        'Lazy-friendly weight loss: pull to refresh on dashboard to load gallery meal photos, then Analyze All for approximate daily calories in one tap',
        'AI-assisted meal and menu logging: build entries from camera, AR, gallery, or typed descriptions',
        'Full post-AI editing: change, add, or delete ingredient lines — remove items you did not eat',
        'Tell the app what is in your food; refine breakdowns with user corrections and AI re-analysis where enabled',
        'AI-powered ingredient and food name lookup with autocomplete from your local database',
        'Homemade logging: photograph ingredients next to kitchen scale or measuring tools',
        'Sub-ingredient level nutrition breakdown and nested editing',
        'Merge multiple analyzed entries into one private recipe (My Meals)',
        'Recipe cover photos from device gallery; recipes reusable anytime',
        'Local on-device database — reuse past searches and meals without redundant AI use',
        'No paywall blocking first use — download and start; free manual logging; free Energy tokens to start; optional in-app purchases for more AI when you choose',
        '15 global cuisine preferences for culturally accurate dish naming',
        'Batch analyze a full day; chat-based logging',
        'No account or login required; optional Health Sync (Apple Health / Health Connect)',
      ],
      screenshot: [
        absoluteUrl('/arcal/screens/store-ar-precision.png'),
        absoluteUrl('/arcal/screens/store-snap-ingredients-recipe.png'),
        absoluteUrl('/arcal/screens/store-sub-ingredients.png'),
      ],
      image: absoluteUrl('/arcal/screens/store-ar-precision.png'),
      url: `${SITE_URL}/`,
      downloadUrl: [PLAY_STORE_URL, APP_STORE_URL],
      sameAs: [PLAY_STORE_URL, APP_STORE_URL],
      author: { '@id': `${SITE_URL}/#organization` },
      publisher: { '@id': `${SITE_URL}/#organization` },
    },
    {
      '@type': 'WebSite',
      '@id': `${SITE_URL}/#website`,
      name: 'ArCal',
      url: `${SITE_URL}/`,
      description:
        'Official ArCal site: AI calorie counter where you can create meals with AI, freely edit or delete log lines, add ingredients with AI lookup, and keep private recipes on-device — optimized for people searching free AI food logging with full control.',
      publisher: { '@id': `${SITE_URL}/#organization` },
      inLanguage: 'en',
    },
    {
      '@type': 'Organization',
      '@id': `${SITE_URL}/#organization`,
      name: 'TNB Group',
      url: 'https://www.tnbgrp.com',
    },
  ];

  const payload = {
    '@context': 'https://schema.org',
    '@graph': graph,
  };

  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(payload) }}
    />
  );
}
