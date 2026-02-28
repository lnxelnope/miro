import {
  Camera,
  MessageSquare,
  Utensils,
  Shield,
  Zap,
  BarChart3,
  Sparkles,
  ChevronRight,
  Star,
  Activity,
  Globe,
  Smartphone,
} from 'lucide-react';

const PLAY_STORE_URL =
  'https://play.google.com/store/apps/details?id=com.tnbgrp.miro';
const APP_STORE_URL =
  'https://apps.apple.com/app/miro-my-intake-record-oracle/id6745498101';

function HeroSection() {
  return (
    <section className="hero-gradient relative overflow-hidden pt-32 pb-20 lg:pt-40 lg:pb-32">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-4xl text-center">
          <div className="mb-6 inline-flex items-center gap-2 rounded-full border border-white/10 bg-white/5 px-4 py-1.5 text-sm text-gray-300">
            <Sparkles size={14} className="text-brand-400" />
            Powered by Google Gemini AI
          </div>

          <h1 className="text-4xl font-extrabold leading-tight tracking-tight sm:text-5xl lg:text-7xl">
            Decode every bite.
            <br />
            <span className="gradient-text">Own every byte.</span>
          </h1>

          <p className="mx-auto mt-6 max-w-2xl text-lg text-gray-400 sm:text-xl">
            The most accurate AI food tracker ever built. Snap a photo and watch
            AI deconstruct every ingredient — including the hidden oil, sugar in
            sauces, and seasonings you can&apos;t see.
          </p>

          <div className="mt-10 flex flex-col items-center justify-center gap-4 sm:flex-row">
            <a
              href={PLAY_STORE_URL}
              target="_blank"
              rel="noopener noreferrer"
              className="group flex h-14 items-center gap-3 rounded-xl bg-white px-6 text-gray-900 transition-transform hover:scale-105"
            >
              <svg viewBox="0 0 24 24" className="h-7 w-7" fill="currentColor">
                <path d="M3.609 1.814L13.792 12 3.61 22.186a.996.996 0 0 1-.61-.92V2.734a1 1 0 0 1 .609-.92zm10.89 10.893l2.302 2.302-10.937 6.333 8.635-8.635zm3.199-3.199l2.302 2.302a1 1 0 0 1 0 1.38l-2.302 2.302L15.395 12l2.303-2.492zM5.864 3.458L16.8 9.79l-2.302 2.302L5.864 3.458z" />
              </svg>
              <div className="text-left">
                <div className="text-[10px] font-medium uppercase leading-none tracking-wider text-gray-500">
                  Get it on
                </div>
                <div className="text-lg font-semibold leading-tight">
                  Google Play
                </div>
              </div>
            </a>

            <a
              href={APP_STORE_URL}
              target="_blank"
              rel="noopener noreferrer"
              className="group flex h-14 items-center gap-3 rounded-xl bg-white px-6 text-gray-900 transition-transform hover:scale-105"
            >
              <svg viewBox="0 0 24 24" className="h-7 w-7" fill="currentColor">
                <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" />
              </svg>
              <div className="text-left">
                <div className="text-[10px] font-medium uppercase leading-none tracking-wider text-gray-500">
                  Download on the
                </div>
                <div className="text-lg font-semibold leading-tight">
                  App Store
                </div>
              </div>
            </a>
          </div>

          <p className="mt-6 text-sm text-gray-500">
            Free to start &middot; No login required &middot; 10 free AI
            analyses
          </p>
        </div>
      </div>

      <div className="pointer-events-none absolute inset-x-0 bottom-0 h-32 bg-gradient-to-t from-gray-950" />
    </section>
  );
}

const features = [
  {
    icon: Camera,
    title: 'AI Photo Analysis',
    description:
      'Snap any meal and watch AI break down every single ingredient with individual calorie counts — including hidden oil, sugar in sauces, and invisible seasonings.',
  },
  {
    icon: Utensils,
    title: 'Sub-Ingredient Precision',
    description:
      'Deep-fried chicken? MiRO sees the meat (132 kcal), flour batter (48 kcal), and absorbed oil (70 kcal). No other app goes this deep.',
  },
  {
    icon: Globe,
    title: 'Cuisine-Specific AI',
    description:
      'Select from 15 cuisines. The same curry photo identified as Thai Red Curry, Indian Butter Chicken, or Japanese Curry Rice — based on YOUR food culture.',
  },
  {
    icon: MessageSquare,
    title: 'Chat Your Entire Day',
    description:
      '"Breakfast: pancakes. Lunch: pad thai. Dinner: salmon with rice." One message, every meal logged with full ingredient breakdown.',
  },
  {
    icon: Shield,
    title: '100% Private & Offline',
    description:
      'No login. No account. No cloud storage. All your data stays on your device. Total privacy by design.',
  },
  {
    icon: Activity,
    title: 'Health Sync',
    description:
      'Two-way sync with Apple Health and Google Health Connect. Log in MiRO, see it on your wrist. Active energy adjusts your calorie goal in real time.',
  },
];

function FeaturesSection() {
  return (
    <section id="features" className="section-gradient py-24 lg:py-32">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-3xl text-center">
          <h2 className="text-3xl font-bold tracking-tight sm:text-4xl lg:text-5xl">
            Accuracy that{' '}
            <span className="gradient-text">no one else offers</span>
          </h2>
          <p className="mt-4 text-lg text-gray-400">
            5 layers of precision stacked together. AI analysis + cultural
            context + user correction = accuracy no single model achieves alone.
          </p>
        </div>

        <div className="mt-16 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {features.map((feature) => (
            <div
              key={feature.title}
              className="glass-card group p-6 transition-colors hover:border-brand-500/30"
            >
              <div className="mb-4 inline-flex rounded-xl bg-brand-500/10 p-3 text-brand-400 transition-colors group-hover:bg-brand-500/20">
                <feature.icon size={24} />
              </div>
              <h3 className="mb-2 text-lg font-semibold">{feature.title}</h3>
              <p className="text-sm leading-relaxed text-gray-400">
                {feature.description}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

const steps = [
  {
    step: '01',
    title: 'Snap or Type',
    description:
      'Take a photo of any meal, scan a product, or simply describe what you ate in natural language.',
    icon: Camera,
  },
  {
    step: '02',
    title: 'AI Deconstructs',
    description:
      'In seconds, MiRO breaks your meal into every ingredient with accurate calorie and macro counts.',
    icon: Zap,
  },
  {
    step: '03',
    title: 'Fine-Tune & Track',
    description:
      'Edit ingredients, adjust portions, remove what you skipped. Your data, your accuracy, your control.',
    icon: BarChart3,
  },
];

function HowItWorksSection() {
  return (
    <section id="how-it-works" className="py-24 lg:py-32">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-3xl text-center">
          <h2 className="text-3xl font-bold tracking-tight sm:text-4xl lg:text-5xl">
            How it <span className="gradient-text">works</span>
          </h2>
          <p className="mt-4 text-lg text-gray-400">
            From photo to full nutrition report in under 10 seconds.
          </p>
        </div>

        <div className="mt-16 grid gap-8 lg:grid-cols-3">
          {steps.map((item) => (
            <div key={item.step} className="relative text-center">
              <div className="mx-auto mb-6 flex h-16 w-16 items-center justify-center rounded-2xl bg-gradient-to-br from-brand-500 to-purple-500">
                <item.icon size={28} className="text-white" />
              </div>
              <div className="mb-2 text-sm font-bold text-brand-400">
                STEP {item.step}
              </div>
              <h3 className="mb-3 text-xl font-bold">{item.title}</h3>
              <p className="text-gray-400">{item.description}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

function ComparisonSection() {
  const rows = [
    { feature: 'AI Ingredient Decomposition', miro: true, others: false },
    { feature: 'Sub-Ingredient Breakdown', miro: true, others: false },
    { feature: 'Cuisine Preference (15 cuisines)', miro: true, others: false },
    { feature: 'Editable Ingredients Post-Analysis', miro: true, others: false },
    { feature: 'No Login / No Account Required', miro: true, others: false },
    { feature: 'Offline-First', miro: true, others: false },
    { feature: 'Chat-Based Logging', miro: true, others: false },
    { feature: 'Gallery Auto-Scan', miro: true, others: false },
    { feature: 'Health Sync (ingredient-level)', miro: true, others: false },
    { feature: 'Purchases Never Expire', miro: true, others: false },
  ];

  return (
    <section className="py-24 lg:py-32">
      <div className="mx-auto max-w-4xl px-4 sm:px-6 lg:px-8">
        <div className="text-center">
          <h2 className="text-3xl font-bold tracking-tight sm:text-4xl lg:text-5xl">
            Why choose <span className="gradient-text">MiRO?</span>
          </h2>
          <p className="mt-4 text-lg text-gray-400">
            Features no other food tracker offers.
          </p>
        </div>

        <div className="glass-card mt-12 overflow-hidden">
          <table className="w-full text-left text-sm">
            <thead>
              <tr className="border-b border-white/10">
                <th className="px-6 py-4 font-semibold text-gray-300">
                  Feature
                </th>
                <th className="px-6 py-4 text-center font-semibold text-brand-400">
                  MiRO
                </th>
                <th className="px-6 py-4 text-center font-semibold text-gray-500">
                  Others
                </th>
              </tr>
            </thead>
            <tbody>
              {rows.map((row, i) => (
                <tr
                  key={row.feature}
                  className={
                    i % 2 === 0 ? 'bg-white/[0.02]' : ''
                  }
                >
                  <td className="px-6 py-3.5 text-gray-300">{row.feature}</td>
                  <td className="px-6 py-3.5 text-center text-green-400">
                    ✓
                  </td>
                  <td className="px-6 py-3.5 text-center text-gray-600">
                    ✗
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </section>
  );
}

const energyPackages = [
  {
    name: 'Starter Kick',
    energy: 100,
    price: '$0.99',
    badge: null,
  },
  {
    name: 'Value Pack',
    energy: 550,
    price: '$4.99',
    badge: '+10%',
  },
  {
    name: 'Power User',
    energy: '1,200',
    price: '$7.99',
    badge: 'POPULAR',
    featured: true,
  },
  {
    name: 'Ultimate Saver',
    energy: '2,000',
    price: '$9.99',
    badge: 'BEST VALUE',
  },
];

function PricingSection() {
  return (
    <section id="pricing" className="section-gradient py-24 lg:py-32">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-3xl text-center">
          <h2 className="text-3xl font-bold tracking-tight sm:text-4xl lg:text-5xl">
            Pay for what you use.{' '}
            <span className="gradient-text">Keep it forever.</span>
          </h2>
          <p className="mt-4 text-lg text-gray-400">
            No monthly subscription trap. Buy Energy tokens once — they never
            expire. Manual logging is always free.
          </p>
        </div>

        <div className="mt-16 grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
          {energyPackages.map((pkg) => (
            <div
              key={pkg.name}
              className={`glass-card relative p-6 text-center transition-transform hover:scale-105 ${
                pkg.featured ? 'glow border-brand-500/30' : ''
              }`}
            >
              {pkg.badge && (
                <div className="absolute -top-3 left-1/2 -translate-x-1/2 rounded-full bg-gradient-to-r from-brand-500 to-purple-500 px-3 py-1 text-xs font-bold">
                  {pkg.badge}
                </div>
              )}
              <div className="mt-2 text-3xl font-extrabold">{pkg.energy}</div>
              <div className="text-sm text-gray-400">Energy</div>
              <div className="my-4 text-2xl font-bold">{pkg.price}</div>
              <div className="text-xs text-gray-500">{pkg.name}</div>
            </div>
          ))}
        </div>

        <div className="mx-auto mt-12 max-w-2xl text-center">
          <div className="glass-card inline-flex items-center gap-3 px-6 py-4">
            <Star size={20} className="text-yellow-400" />
            <div className="text-left">
              <div className="font-semibold">Energy Pass — $4.99/month</div>
              <div className="text-sm text-gray-400">
                Unlimited AI analysis, double streak rewards, priority support
              </div>
            </div>
          </div>
        </div>

        <div className="mt-8 text-center text-sm text-gray-500">
          <p>
            10 free Energy on sign up &middot; 1 free AI analysis per day with
            streak &middot; Manual logging always free
          </p>
        </div>
      </div>
    </section>
  );
}

function DownloadSection() {
  return (
    <section
      id="download"
      className="relative overflow-hidden py-24 lg:py-32"
    >
      <div className="absolute inset-0 bg-gradient-to-b from-transparent via-brand-500/5 to-transparent" />
      <div className="relative mx-auto max-w-4xl px-4 text-center sm:px-6 lg:px-8">
        <h2 className="text-3xl font-bold tracking-tight sm:text-4xl lg:text-5xl">
          Start tracking <span className="gradient-text">in 30 seconds</span>
        </h2>
        <p className="mx-auto mt-4 max-w-xl text-lg text-gray-400">
          No login. No credit card. No hidden fees. Download MiRO and get 10
          free AI analyses to see the difference.
        </p>

        <div className="mt-10 flex flex-col items-center justify-center gap-4 sm:flex-row">
          <a
            href={PLAY_STORE_URL}
            target="_blank"
            rel="noopener noreferrer"
            className="group flex h-14 items-center gap-3 rounded-xl bg-white px-6 text-gray-900 transition-transform hover:scale-105"
          >
            <svg viewBox="0 0 24 24" className="h-7 w-7" fill="currentColor">
              <path d="M3.609 1.814L13.792 12 3.61 22.186a.996.996 0 0 1-.61-.92V2.734a1 1 0 0 1 .609-.92zm10.89 10.893l2.302 2.302-10.937 6.333 8.635-8.635zm3.199-3.199l2.302 2.302a1 1 0 0 1 0 1.38l-2.302 2.302L15.395 12l2.303-2.492zM5.864 3.458L16.8 9.79l-2.302 2.302L5.864 3.458z" />
            </svg>
            <div className="text-left">
              <div className="text-[10px] font-medium uppercase leading-none tracking-wider text-gray-500">
                Get it on
              </div>
              <div className="text-lg font-semibold leading-tight">
                Google Play
              </div>
            </div>
          </a>

          <a
            href={APP_STORE_URL}
            target="_blank"
            rel="noopener noreferrer"
            className="group flex h-14 items-center gap-3 rounded-xl bg-white px-6 text-gray-900 transition-transform hover:scale-105"
          >
            <svg viewBox="0 0 24 24" className="h-7 w-7" fill="currentColor">
              <path d="M18.71 19.5c-.83 1.24-1.71 2.45-3.05 2.47-1.34.03-1.77-.79-3.29-.79-1.53 0-2 .77-3.27.82-1.31.05-2.3-1.32-3.14-2.53C4.25 17 2.94 12.45 4.7 9.39c.87-1.52 2.43-2.48 4.12-2.51 1.28-.02 2.5.87 3.29.87.78 0 2.26-1.07 3.8-.91.65.03 2.47.26 3.64 1.98-.09.06-2.17 1.28-2.15 3.81.03 3.02 2.65 4.03 2.68 4.04-.03.07-.42 1.44-1.38 2.83M13 3.5c.73-.83 1.94-1.46 2.94-1.5.13 1.17-.34 2.35-1.04 3.19-.69.85-1.83 1.51-2.95 1.42-.15-1.15.41-2.35 1.05-3.11z" />
            </svg>
            <div className="text-left">
              <div className="text-[10px] font-medium uppercase leading-none tracking-wider text-gray-500">
                Download on the
              </div>
              <div className="text-lg font-semibold leading-tight">
                App Store
              </div>
            </div>
          </a>
        </div>

        <div className="mt-12 flex flex-wrap items-center justify-center gap-8 text-sm text-gray-500">
          <div className="flex items-center gap-2">
            <Shield size={16} className="text-green-400" />
            No account needed
          </div>
          <div className="flex items-center gap-2">
            <Smartphone size={16} className="text-brand-400" />
            Android &amp; iOS
          </div>
          <div className="flex items-center gap-2">
            <Zap size={16} className="text-yellow-400" />
            10 free AI analyses
          </div>
        </div>
      </div>
    </section>
  );
}

function USPBanner() {
  const items = [
    'No Login Required',
    'Offline-First',
    '15 Cuisines',
    'Ingredient-Level Accuracy',
    'Purchases Never Expire',
  ];

  return (
    <div className="overflow-hidden border-y border-white/5 bg-white/[0.02] py-4">
      <div className="flex animate-[scroll_30s_linear_infinite] items-center gap-8 whitespace-nowrap">
        {[...items, ...items].map((item, i) => (
          <div key={i} className="flex items-center gap-3 text-sm text-gray-400">
            <ChevronRight size={14} className="text-brand-400" />
            {item}
          </div>
        ))}
      </div>
    </div>
  );
}

export default function Home() {
  return (
    <>
      <HeroSection />
      <USPBanner />
      <FeaturesSection />
      <HowItWorksSection />
      <ComparisonSection />
      <PricingSection />
      <DownloadSection />
    </>
  );
}
