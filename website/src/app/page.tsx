import {
  Camera,
  Utensils,
  Shield,
  Zap,
  BarChart3,
  ChevronRight,
  Star,
  Activity,
  Globe,
  Smartphone,
  Download,
  ScanLine,
  MessageSquare,
  Clock,
  Gift,
  CheckCircle2,
  XCircle,
  ArrowDown,
} from 'lucide-react';
import Image from 'next/image';
import { publicAsset } from '@/lib/publicAsset';
import { StoreButtons } from '@/components/StoreButtons';

function HeroSection() {
  return (
    <section className="hero-gradient relative overflow-hidden pt-28 pb-16 lg:pt-36 lg:pb-24">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="grid items-center gap-12 lg:grid-cols-2 lg:gap-16">
          <div className="text-center lg:text-left">
            <div className="mb-6 inline-flex items-center gap-2 rounded-full border border-brand-200 bg-brand-50 px-4 py-1.5 text-sm font-medium text-brand-800">
              <ScanLine size={14} className="text-brand-600" />
              First AI calorie counter with AR scan
            </div>

            <h1 className="text-4xl font-extrabold leading-[1.1] tracking-tight text-brand-950 sm:text-5xl lg:text-6xl">
              Precise calories.
              <br />
              <span className="gradient-text-hero">Zero effort.</span>
            </h1>

            <p className="mx-auto mt-6 max-w-xl text-lg text-gray-600 sm:text-xl lg:mx-0">
              Open the app and start tracking. No login, no quiz, no setup.
              AR scan or snap a photo — AI counts your calories in seconds.
            </p>

            <div className="mx-auto mt-4 flex max-w-md flex-wrap items-center justify-center gap-x-6 gap-y-2 text-sm font-medium text-brand-700 lg:justify-start">
              <span className="flex items-center gap-1.5">
                <Gift size={15} className="text-brand-500" />
                Free tokens included
              </span>
              <span className="flex items-center gap-1.5">
                <Shield size={15} className="text-brand-500" />
                No login required
              </span>
              <span className="flex items-center gap-1.5">
                <Clock size={15} className="text-brand-500" />
                10-second setup
              </span>
            </div>

            <StoreButtons className="mt-10" size="large" />

            <p className="mt-5 text-sm text-gray-500">
              Free to start &middot; No credit card &middot; Works offline
            </p>
          </div>

          <div className="relative mx-auto w-full max-w-md lg:max-w-lg">
            <div className="absolute -inset-8 rounded-3xl bg-gradient-to-br from-brand-300/30 via-brand-200/20 to-brand-400/20 blur-3xl" />
            <Image
              src={publicAsset('/arcal/screens/hero-banner.png')}
              alt="ArCal AI Calories Counter — Precise calories, zero effort"
              width={1024}
              height={500}
              className="relative rounded-2xl shadow-2xl"
              priority
            />
          </div>
        </div>
      </div>

      <div className="pointer-events-none absolute inset-x-0 bottom-0 h-24 bg-gradient-to-t from-white" />
    </section>
  );
}

function USPBanner() {
  const items = [
    'No Login Required',
    'AR Scan',
    '10-Second Setup',
    'Free Tokens to Start',
    '15 Cuisines',
    'Ingredient-Level Accuracy',
    '100% Private',
    'Works Offline',
    'Purchases Never Expire',
  ];

  return (
    <div className="overflow-hidden border-y border-brand-100 bg-brand-50/50 py-4">
      <div className="flex animate-scroll items-center gap-8 whitespace-nowrap">
        {[...items, ...items].map((item, i) => (
          <div
            key={i}
            className="flex items-center gap-3 text-sm font-medium text-brand-800"
          >
            <ChevronRight size={14} className="text-brand-500" />
            {item}
          </div>
        ))}
      </div>
    </div>
  );
}

const showcaseFeatures = [
  {
    title: 'AR Scan — First of Its Kind',
    subtitle: 'Point, scan, done',
    description:
      'Use augmented reality to scan your meal. ArCal detects food on your plate, identifies every ingredient, and calculates accurate calories — all through your camera in real time.',
    image: '/arcal/screens/ar-scan.png',
    imageAlt: 'ArCal AR Scan — Augmented reality food scanning',
    reverse: false,
  },
  {
    title: 'Track Your Day with 1 Button',
    subtitle: 'Batch analysis — track everything at once',
    description:
      'Pull to refresh and batch-analyze your whole day in 2 clicks. Every meal organized with photos and full macro breakdowns on one beautiful dashboard.',
    image: '/arcal/screens/dashboard.png',
    imageAlt: 'ArCal Dashboard — Daily nutrition tracking',
    reverse: true,
  },
  {
    title: 'Zero Setup. Just Open and Go.',
    subtitle: 'No login, no forced subscription, no annoying questions',
    description:
      'Download ArCal and start tracking immediately. No account creation, no onboarding quiz, no paywall. Free tokens are waiting — start your first scan in 10 seconds.',
    image: '/arcal/screens/zero-setup.png',
    imageAlt: 'ArCal Zero Setup — No login required',
    reverse: false,
  },
  {
    title: 'Sub-Ingredient Precision',
    subtitle: 'Edit, delete, customize — full control',
    description:
      'Thai Red Curry? ArCal breaks it into: shrimp (70 kcal), curry paste (40 kcal), coconut milk (120 kcal). Don\'t eat something? Delete it. Add your own? AI helps.',
    image: '/arcal/screens/ingredients.png',
    imageAlt: 'ArCal Ingredients — Sub-ingredient level editing',
    reverse: true,
  },
  {
    title: 'Smarter AI. 15 Cuisines.',
    subtitle: 'Thai red curry, not "Japanese curry"',
    description:
      'ArCal understands food culture. Select your cuisine — the same dish gets identified with the right name, right recipe, and right calorie count for YOUR food.',
    image: '/arcal/screens/cuisines.png',
    imageAlt: 'ArCal Cuisines — 15 global cuisine support',
    reverse: false,
  },
  {
    title: 'Your Data. Your Device. Forever.',
    subtitle: '100% local — no cloud, no tracking',
    description:
      'All your nutrition data stays on your phone. No server uploads, no analytics tracking. Build your personal food database over time — it only gets smarter.',
    image: '/arcal/screens/local-data.png',
    imageAlt: 'ArCal Privacy — Local data storage',
    reverse: true,
  },
];

function ShowcaseSection() {
  return (
    <section id="features" className="py-20 lg:py-28">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-3xl text-center">
          <h2 className="text-3xl font-bold tracking-tight text-brand-950 sm:text-4xl lg:text-5xl">
            Everything you need.{' '}
            <span className="gradient-text">Nothing you don&apos;t.</span>
          </h2>
          <p className="mt-4 text-lg text-gray-500">
            AR scan, AI analysis, ingredient editing, cultural accuracy — all in
            one app that respects your time and privacy.
          </p>
        </div>

        <div className="mt-20 space-y-24 lg:space-y-32">
          {showcaseFeatures.map((feature, i) => (
            <div
              key={feature.title}
              className={`flex flex-col items-center gap-10 lg:gap-16 ${
                feature.reverse ? 'lg:flex-row-reverse' : 'lg:flex-row'
              }`}
            >
              <div className="w-full lg:w-1/2">
                <div className="relative mx-auto max-w-md">
                  <div
                    className={`absolute -inset-6 rounded-3xl blur-2xl ${
                      i % 3 === 0
                        ? 'bg-brand-400/10'
                        : i % 3 === 1
                        ? 'bg-brand-300/10'
                        : 'bg-brand-500/10'
                    }`}
                  />
                  <Image
                    src={publicAsset(feature.image)}
                    alt={feature.imageAlt}
                    width={540}
                    height={1080}
                    className="relative rounded-2xl shadow-xl"
                  />
                </div>
              </div>

              <div className="w-full text-center lg:w-1/2 lg:text-left">
                <div className="mb-3 text-sm font-semibold uppercase tracking-wider text-brand-600">
                  {feature.subtitle}
                </div>
                <h3 className="text-2xl font-bold tracking-tight text-brand-950 sm:text-3xl lg:text-4xl">
                  {feature.title}
                </h3>
                <p className="mt-4 text-lg leading-relaxed text-gray-500">
                  {feature.description}
                </p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

const features = [
  {
    icon: ScanLine,
    title: 'AR Food Scanner',
    description:
      'Point your camera and scan meals in augmented reality — the first calorie counter to do this.',
  },
  {
    icon: Camera,
    title: 'AI Photo Analysis',
    description:
      'Snap any meal and watch AI break down every single ingredient with individual calorie counts.',
  },
  {
    icon: Utensils,
    title: 'Sub-Ingredient Precision',
    description:
      'See the meat, the batter, and the absorbed oil — each with its own calorie count.',
  },
  {
    icon: Globe,
    title: '15 Global Cuisines',
    description:
      'Select your cuisine. Thai curry stays Thai curry, pho stays pho — never misidentified.',
  },
  {
    icon: MessageSquare,
    title: 'Chat-Based Logging',
    description:
      'Describe your entire day in one message — every meal logged with full breakdown.',
  },
  {
    icon: Shield,
    title: '100% Private & Local',
    description:
      'No login. No cloud. All data stays on your device. Your nutrition diary belongs to you.',
  },
];

function FeaturesGrid() {
  return (
    <section className="section-gradient py-20 lg:py-28">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="mx-auto mb-16 max-w-3xl text-center">
          <h2 className="text-3xl font-bold tracking-tight text-brand-950 sm:text-4xl">
            Built different
          </h2>
          <p className="mt-3 text-lg text-gray-500">
            Six features that set ArCal apart from every other calorie counter.
          </p>
        </div>
        <div className="grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
          {features.map((feature) => (
            <div
              key={feature.title}
              className="glass-card group p-6 transition-all hover:border-brand-300 hover:shadow-md"
            >
              <div className="mb-4 inline-flex rounded-xl bg-brand-50 p-3 text-brand-600 transition-colors group-hover:bg-brand-100">
                <feature.icon size={24} />
              </div>
              <h3 className="mb-2 text-lg font-semibold text-brand-950">
                {feature.title}
              </h3>
              <p className="text-sm leading-relaxed text-gray-500">
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
    title: 'Open & Scan',
    description:
      'No login needed. Open ArCal, point your camera, and AR-scan your meal — or snap a photo, or just type what you ate.',
    icon: ScanLine,
  },
  {
    step: '02',
    title: 'AI Analyzes',
    description:
      'In under 10 seconds, AI identifies every ingredient with individual calorie and macro counts. Powered by Google Gemini.',
    icon: Zap,
  },
  {
    step: '03',
    title: 'Fine-Tune & Track',
    description:
      'Edit ingredients, adjust portions, remove what you skipped. Your personal food database grows smarter every day.',
    icon: BarChart3,
  },
];

function HowItWorksSection() {
  return (
    <section id="how-it-works" className="py-20 lg:py-28">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-3xl text-center">
          <h2 className="text-3xl font-bold tracking-tight text-brand-950 sm:text-4xl lg:text-5xl">
            How it <span className="gradient-text">works</span>
          </h2>
          <p className="mt-4 text-lg text-gray-500">
            From open to first scan in under 10 seconds. Really.
          </p>
        </div>

        <div className="mt-16 grid gap-8 lg:grid-cols-3">
          {steps.map((item) => (
            <div key={item.step} className="relative text-center">
              <div className="mx-auto mb-6 flex h-16 w-16 items-center justify-center rounded-2xl bg-gradient-to-br from-brand-500 to-brand-700 shadow-lg shadow-brand-500/25">
                <item.icon size={28} className="text-white" />
              </div>
              <div className="mb-2 text-sm font-bold text-brand-600">
                STEP {item.step}
              </div>
              <h3 className="mb-3 text-xl font-bold text-brand-950">
                {item.title}
              </h3>
              <p className="text-gray-500">{item.description}</p>
            </div>
          ))}
        </div>

        <div className="mt-12 text-center">
          <a href="#download" className="cta-button">
            <Download size={20} />
            Try It Free
          </a>
        </div>
      </div>
    </section>
  );
}

function ComparisonSection() {
  const rows = [
    { feature: 'AR Meal Scanner', arcal: true, others: false },
    { feature: 'AI Ingredient Decomposition', arcal: true, others: false },
    { feature: 'Sub-Ingredient Breakdown', arcal: true, others: false },
    { feature: 'Cuisine Preference (15 cuisines)', arcal: true, others: false },
    { feature: 'Editable Ingredients Post-Analysis', arcal: true, others: false },
    { feature: 'No Login / No Account Required', arcal: true, others: false },
    { feature: '100% Offline & Local Data', arcal: true, others: false },
    { feature: 'Chat-Based Logging', arcal: true, others: false },
    { feature: 'Gallery Batch Scan', arcal: true, others: false },
    { feature: 'Purchases Never Expire', arcal: true, others: false },
  ];

  return (
    <section className="section-gradient-reverse py-20 lg:py-28">
      <div className="mx-auto max-w-4xl px-4 sm:px-6 lg:px-8">
        <div className="text-center">
          <h2 className="text-3xl font-bold tracking-tight text-brand-950 sm:text-4xl lg:text-5xl">
            Why choose <span className="gradient-text">ArCal?</span>
          </h2>
          <p className="mt-4 text-lg text-gray-500">
            Features no other calorie counter offers.
          </p>
        </div>

        <div className="mt-12 overflow-hidden rounded-2xl border border-gray-200 bg-white shadow-lg">
          <table className="w-full text-left text-sm">
            <thead>
              <tr className="border-b border-gray-100 bg-brand-50/50">
                <th className="px-6 py-4 font-semibold text-gray-700">
                  Feature
                </th>
                <th className="px-6 py-4 text-center font-semibold text-brand-700">
                  ArCal
                </th>
                <th className="px-6 py-4 text-center font-semibold text-gray-400">
                  Others
                </th>
              </tr>
            </thead>
            <tbody>
              {rows.map((row, i) => (
                <tr
                  key={row.feature}
                  className={i % 2 === 0 ? 'bg-brand-50/30' : 'bg-white'}
                >
                  <td className="px-6 py-3.5 text-gray-700">{row.feature}</td>
                  <td className="px-6 py-3.5 text-center">
                    <CheckCircle2 size={18} className="mx-auto text-brand-500" />
                  </td>
                  <td className="px-6 py-3.5 text-center">
                    <XCircle size={18} className="mx-auto text-gray-300" />
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
    featured: false,
  },
  {
    name: 'Value Pack',
    energy: 550,
    price: '$4.99',
    badge: '+10%',
    featured: false,
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
    featured: false,
  },
];

function PricingSection() {
  return (
    <section id="pricing" className="section-gradient py-20 lg:py-28">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="mx-auto max-w-3xl text-center">
          <h2 className="text-3xl font-bold tracking-tight text-brand-950 sm:text-4xl lg:text-5xl">
            Pay for what you use.{' '}
            <span className="gradient-text">Keep it forever.</span>
          </h2>
          <p className="mt-4 text-lg text-gray-500">
            No monthly subscription trap. Buy Energy tokens once — they never
            expire. Manual logging is always free.
          </p>
        </div>

        <div className="mt-16 grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
          {energyPackages.map((pkg) => (
            <div
              key={pkg.name}
              className={`relative rounded-2xl border p-6 text-center transition-all hover:scale-105 ${
                pkg.featured
                  ? 'border-brand-400 bg-white shadow-xl glow-green'
                  : 'border-gray-200 bg-white shadow-md'
              }`}
            >
              {pkg.badge && (
                <div className="absolute -top-3 left-1/2 -translate-x-1/2 rounded-full bg-gradient-to-r from-brand-500 to-brand-700 px-3 py-1 text-xs font-bold text-white">
                  {pkg.badge}
                </div>
              )}
              <div className="mt-2 text-3xl font-extrabold text-brand-950">
                {pkg.energy}
              </div>
              <div className="text-sm text-gray-500">Energy</div>
              <div className="my-4 text-2xl font-bold text-brand-700">
                {pkg.price}
              </div>
              <div className="text-xs text-gray-400">{pkg.name}</div>
            </div>
          ))}
        </div>

        <div className="mx-auto mt-12 max-w-2xl text-center">
          <div className="inline-flex items-center gap-3 rounded-2xl border border-brand-200 bg-brand-50 px-6 py-4 shadow-sm">
            <Star size={20} className="text-yellow-500" />
            <div className="text-left">
              <div className="font-semibold text-brand-900">
                Energy Pass — $4.99/month
              </div>
              <div className="text-sm text-gray-500">
                Unlimited AI analysis, double streak rewards, priority support
              </div>
            </div>
          </div>
        </div>

        <div className="mt-8 text-center text-sm text-gray-400">
          <p>
            Free tokens on first launch &middot; 1 free AI analysis per day with
            streak &middot; Manual logging always free
          </p>
        </div>
      </div>
    </section>
  );
}

function SocialProofStrip() {
  const stats = [
    { value: '10 sec', label: 'Setup time' },
    { value: '95%', label: 'AI confidence' },
    { value: '15', label: 'Cuisines' },
    { value: '0', label: 'Login required' },
  ];

  return (
    <section className="border-y border-brand-100 bg-brand-950 py-12">
      <div className="mx-auto max-w-5xl px-4 sm:px-6 lg:px-8">
        <div className="grid grid-cols-2 gap-8 lg:grid-cols-4">
          {stats.map((stat) => (
            <div key={stat.label} className="text-center">
              <div className="text-3xl font-extrabold text-brand-400 sm:text-4xl">
                {stat.value}
              </div>
              <div className="mt-1 text-sm text-gray-400">{stat.label}</div>
            </div>
          ))}
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
      <div className="absolute inset-0 hero-gradient" />
      <div className="relative mx-auto max-w-4xl px-4 text-center sm:px-6 lg:px-8">
        <h2 className="text-3xl font-bold tracking-tight text-brand-950 sm:text-4xl lg:text-5xl">
          Start tracking{' '}
          <span className="gradient-text">in 10 seconds</span>
        </h2>
        <p className="mx-auto mt-4 max-w-xl text-lg text-gray-600">
          No login. No credit card. No setup quiz. Download ArCal and get free
          tokens to try AI-powered calorie counting right now.
        </p>

        <StoreButtons className="mt-10" size="large" />

        <div className="mt-12 flex flex-wrap items-center justify-center gap-8 text-sm font-medium text-gray-500">
          <div className="flex items-center gap-2">
            <Shield size={16} className="text-brand-500" />
            No account needed
          </div>
          <div className="flex items-center gap-2">
            <Smartphone size={16} className="text-brand-500" />
            Android & iOS
          </div>
          <div className="flex items-center gap-2">
            <Gift size={16} className="text-brand-500" />
            Free tokens included
          </div>
        </div>
      </div>
    </section>
  );
}

export default function Home() {
  return (
    <>
      <HeroSection />
      <USPBanner />
      <SocialProofStrip />
      <ShowcaseSection />
      <FeaturesGrid />
      <HowItWorksSection />
      <ComparisonSection />
      <PricingSection />
      <DownloadSection />
    </>
  );
}
