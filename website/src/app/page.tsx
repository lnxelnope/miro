import {
  Camera,
  Utensils,
  Shield,
  Zap,
  BarChart3,
  ChevronRight,
  Activity,
  Globe,
  Smartphone,
  Download,
  ScanLine,
  MessageSquare,
  Clock,
  Unlock,
  Gift,
  CheckCircle2,
  XCircle,
  ArrowDown,
  Scale,
  Layers,
  Edit3,
  Sparkles,
} from 'lucide-react';
import Image from 'next/image';
import Link from 'next/link';
import { publicAsset } from '@/lib/publicAsset';
import { StoreButtons } from '@/components/StoreButtons';

function HeroSection() {
  return (
    <section className="hero-gradient relative overflow-hidden pt-28 pb-16 lg:pt-36 lg:pb-24">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="grid items-center gap-12 lg:grid-cols-2 lg:gap-16">
          <div className="text-center lg:text-left">
            <div className="mb-6 inline-flex flex-col items-center gap-2 sm:flex-row lg:items-start">
              <span className="inline-flex items-center gap-2 rounded-full border border-brand-200 bg-brand-50 px-4 py-1.5 text-sm font-medium text-brand-800">
                <ScanLine size={14} className="text-brand-600" />
                First AI calorie counter with AR scan
              </span>
              <span className="inline-flex items-center gap-2 rounded-full border border-amber-200 bg-amber-50 px-4 py-1.5 text-sm font-medium text-amber-900">
                Built for people who hate counting every bite
              </span>
              <span className="inline-flex items-center gap-2 rounded-full border border-emerald-200 bg-emerald-50 px-4 py-1.5 text-sm font-medium text-emerald-900">
                <Unlock size={14} className="text-emerald-600" />
                No paywall to start
              </span>
            </div>

            <h1 className="text-4xl font-extrabold leading-[1.1] tracking-tight text-brand-950 sm:text-5xl lg:text-6xl">
              Precise calories.
              <br />
              <span className="gradient-text-hero">Zero effort.</span>
            </h1>

            <p className="mx-auto mt-6 max-w-xl text-lg text-gray-600 sm:text-xl lg:mx-0">
              Want to <strong>lose weight</strong> but <strong>lazy to log</strong>{' '}
              every meal? <strong>Pull to refresh</strong> on the dashboard to load
              food photos you already took — tap <strong>Analyze All</strong> once
              and get a <strong>rough calorie picture</strong> for the day. It may
              not be lab-perfect, but it&apos;s a <strong>real starting point</strong>{' '}
              that builds awareness: tracking doesn&apos;t have to feel impossible.
              Then refine lines anytime — delete what you skipped, add items, or use
              AR and homemade flows when you&apos;re ready.
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
              <span className="flex items-center gap-1.5">
                <Unlock size={15} className="text-emerald-600" />
                No paywall
              </span>
            </div>

            <StoreButtons className="mt-10" size="large" />

            <p className="mt-5 text-sm text-gray-500">
              Free to start &middot; No paywall &middot; No credit card &middot;
              Works offline
            </p>
          </div>

          <div className="relative mx-auto w-full max-w-md lg:max-w-lg">
            <div className="absolute -inset-8 rounded-3xl bg-gradient-to-br from-brand-300/30 via-brand-200/20 to-brand-400/20 blur-3xl" />
            <Image
              src={publicAsset('/arcal/screens/store-ar-precision.png')}
              alt="ArCal AI calorie counter — AR food scan with precision bounding box (App Store display)"
              width={473}
              height={1024}
              className="relative mx-auto max-h-[min(70vh,520px)] w-auto rounded-2xl shadow-2xl object-contain"
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
    'No Paywall to Start',
    'No Login Required',
    'AR Scan',
    '10-Second Setup',
    'Free Tokens to Start',
    '15 Cuisines',
    'Ingredient-Level Accuracy',
    'Scale-Aware Homemade Logging',
    'Merge Into Private Recipes',
    'Reuse Searches — Fair Local AI',
    'Edit or Delete Lines After AI',
    'Add Items + AI Ingredient Lookup',
    '100% Private',
    'Works Offline',
    'Purchases Never Expire',
    'Pull to Refresh → Analyze All',
    'Lazy-Friendly Weight Loss',
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

function LazyWeightLossSection() {
  return (
    <section
      id="lazy-tracking"
      className="border-y border-amber-100 bg-gradient-to-b from-amber-50/40 via-white to-white py-16 lg:py-20"
    >
      <div className="mx-auto max-w-3xl px-4 text-center sm:px-6 lg:px-8">
        <h2 className="text-2xl font-bold tracking-tight text-brand-950 sm:text-3xl lg:text-4xl">
          Lose weight without the spreadsheet mindset
        </h2>
        <p className="mt-4 text-lg leading-relaxed text-gray-600">
          ArCal is designed for <strong>people who want calorie awareness</strong>{' '}
          but <strong>won&apos;t manually type every snack</strong>. Your camera roll
          already has meal photos — the app can pull them into the timeline, then
          you run <strong>one batch &quot;Analyze All&quot;</strong> to turn those
          shots into <strong>approximate kcal and macros</strong>. That first pass
          is enough to see patterns and stay honest; perfection comes later when you
          edit lines or add detail.
        </p>
      </div>
    </section>
  );
}

const showcaseFeatures = [
  {
    title: 'AR Scan — First of Its Kind',
    subtitle: 'Point, scan, done',
    description:
      'Use augmented reality to scan your meal. ArCal detects food on your plate, identifies every ingredient, and calculates accurate calories — all through your camera in real time.',
    image: '/arcal/screens/store-ar-precision.png',
    imageAlt:
      'ArCal AR Scan — real-time food detection with precision overlay (App Store creative)',
    reverse: false,
  },
  {
    title: 'Track Your Day with 1 Button',
    subtitle: 'Pull to refresh → Analyze All — lazy-friendly',
    description:
      'Pull to refresh on the dashboard to bring in meal photos you already took from your gallery, then hit Analyze All — one action to get a rough calorie read for the day. Ideal if you want to lose weight but refuse to log every bite by hand: you still get awareness and a starting number, then you can tighten accuracy later.',
    image: '/arcal/screens/dashboard.png',
    imageAlt: 'ArCal Dashboard — Pull to refresh and batch analyze meal photos',
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
    image: '/arcal/screens/store-sub-ingredients.png',
    imageAlt:
      'ArCal sub-ingredient precision — Thai red curry broken down to paste components (App Store creative)',
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
  {
    title: 'Homemade Meals — Photo Ingredients + Scale',
    subtitle: 'Kitchen scale & measuring cups in the frame',
    description:
      'Logging food you cooked yourself is easy: lay out ingredients next to your kitchen scale, measuring cup, or spoons and snap one photo. Tell ArCal exact amounts if you want — or let AI infer ingredients — while portions respect what the scale or measure shows in the image.',
    image: '/arcal/screens/store-snap-ingredients-recipe.png',
    imageAlt:
      'ArCal snap ingredients with scale, analyze all, group, save as private recipe — App Store display',
    reverse: false,
  },
  {
    title: 'Fastest Private Recipe Builder',
    subtitle: 'Merge analyzed items → one recipe → save forever',
    description:
      'Combine multiple AI-analyzed ingredient lines into a single entry, name it, attach any photo from your gallery as the recipe cover, and save it to My Meals. One app, one local database — analyze, merge, and reuse without exporting to another tool.',
    image: '/arcal/screens/store-snap-ingredients-recipe.png',
    imageAlt:
      'ArCal merge analyzed lines into one My Meal recipe, free to reuse (App Store display)',
    reverse: true,
  },
  {
    title: 'Fair AI Calories — Reuse What You Already Found',
    subtitle: 'Local database means your searches are yours',
    description:
      'Foods and ingredients you have already searched or analyzed stay on your phone. Log the same item again from autocomplete or My Meals without burning AI credits every time — because the knowledge lives in your local database, not a black-box cloud-only history.',
    image: '/arcal/screens/local-data.png',
    imageAlt:
      'ArCal fair AI — reuse saved foods from local database without repeated AI charges',
    reverse: false,
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
            AR scan, scale-aware homemade logging, merge-to-recipe, fair reuse
            from local storage, plus ingredient editing and cultural accuracy —
            all in one app that respects your time, privacy, and wallet.
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
  {
    icon: Scale,
    title: 'Homemade + Scale in One Photo',
    description:
      'Photograph raw ingredients beside your scale or measuring gear — AI reads portions from the frame or uses the amounts you specify.',
  },
  {
    icon: Layers,
    title: 'Merge → My Meal Recipe',
    description:
      'Turn several analyzed lines into one private recipe with a gallery photo — log it again whenever you want.',
  },
  {
    icon: Zap,
    title: 'Fair AI — Reuse Saved Foods',
    description:
      'Previously searched items live locally; log them again without paying for the same lookup every time.',
  },
  {
    icon: Edit3,
    title: 'Edit, Delete, or Add After AI',
    description:
      'Wrong line? Remove it. Skipped the rice? Delete that ingredient. Need another item? Add it and let AI fill macros — your diary stays accurate.',
  },
  {
    icon: Sparkles,
    title: 'Tell AI What You Ate + Ingredient Search',
    description:
      'Describe what is in your meal, pick from My Meals or ingredients DB, or let AI search nutrition data — built for people who want control, not a black box.',
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
            Eleven capabilities — AI-built meals you can fix line by line, plus
            AR, local recipes, and fair reuse from your own database.
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

function AiMealControlSection() {
  return (
    <section
      id="ai-meal-builder"
      className="border-y border-brand-100 bg-gradient-to-b from-white via-brand-50/40 to-white py-20 lg:py-28"
    >
      <div className="mx-auto max-w-3xl px-4 sm:px-6 lg:px-8">
        <h2 className="text-center text-3xl font-bold tracking-tight text-brand-950 sm:text-4xl">
          AI builds the meal —{' '}
          <span className="gradient-text">you keep control</span>
        </h2>
        <p className="mt-4 text-center text-lg leading-relaxed text-gray-600">
          Searching for a <strong>free-to-start AI calorie app</strong> where you
          can <strong>create menus and log food with AI</strong>, then{' '}
          <strong>edit the list</strong>, <strong>delete what you didn&apos;t eat</strong>,{' '}
          <strong>add lines</strong>, <strong>tell the app what&apos;s inside your dish</strong>, and{' '}
          <strong>use AI to look up ingredient nutrition</strong>? That workflow is
          core to ArCal — not an afterthought.
        </p>
        <ul className="mt-10 space-y-5 text-base leading-relaxed text-gray-600">
          <li className="flex gap-3">
            <span className="mt-1.5 h-2 w-2 shrink-0 rounded-full bg-brand-500" />
            <span>
              <strong className="text-brand-950">Create entries with AI</strong>{' '}
              — photo, AR scan, gallery batch, or chat. Gemini proposes ingredients
              and calories; you approve or change them.
            </span>
          </li>
          <li className="flex gap-3">
            <span className="mt-1.5 h-2 w-2 shrink-0 rounded-full bg-brand-500" />
            <span>
              <strong className="text-brand-950">Line-level edits</strong> — remove
              an ingredient, adjust portions, or add a missing item. Manual logging
              stays free; AI extras use Energy tokens you control.
            </span>
          </li>
          <li className="flex gap-3">
            <span className="mt-1.5 h-2 w-2 shrink-0 rounded-full bg-brand-500" />
            <span>
              <strong className="text-brand-950">Ingredient intelligence</strong>{' '}
              — search and autocomplete from <em>your</em> My Meals and ingredient
              database; call AI when you need a full nutrition fill-in.
            </span>
          </li>
        </ul>
        <p
          className="mt-10 rounded-2xl border border-brand-200/80 bg-white/90 p-5 text-center text-sm leading-relaxed text-gray-700 shadow-sm"
          lang="th"
        >
          <strong className="text-brand-900">ค้นหาเป็นภาษาไทย:</strong>{' '}
          ArCal ช่วย<strong>สร้างเมนูและบันทึกมื้อด้วย AI</strong> เริ่มใช้งานได้ฟรี
          (มีโทเค็นฟรี) <strong>แก้ไข ลบ หรือเพิ่มวัตถุดิบ</strong> หลังวิเคราะห์ได้
          <strong> ลบรายการที่ไม่ได้กิน</strong> บอกว่าในอาหารมีอะไร
          ให้ <strong>AI ช่วยค้นหาโภชนาการวัตถุดิบ</strong> — ข้อมูลสำคัญเก็บในเครื่อง
          (local){' '}
          <Link
            href="/th/"
            className="font-semibold text-brand-800 underline underline-offset-2 hover:text-brand-950"
          >
            หน้าไทยฉบับเต็ม — ลดน้ำหนัก ขี้เกียจนับแคล / Pull to refresh → Analyze All
          </Link>
        </p>
      </div>
    </section>
  );
}

function ComparisonSection() {
  const rows = [
    { feature: 'AR Meal Scanner', arcal: true, others: false },
    { feature: 'AI Ingredient Decomposition', arcal: true, others: false },
    { feature: 'Sub-Ingredient Breakdown', arcal: true, others: false },
    {
      feature: 'Homemade logging — ingredients + scale/measures in photo',
      arcal: true,
      others: false,
    },
    {
      feature: 'Merge multiple items into one private recipe (My Meals)',
      arcal: true,
      others: false,
    },
    {
      feature: 'Recipe photos from device gallery + unlimited re-log',
      arcal: true,
      others: false,
    },
    {
      feature: 'Reuse past searches / meals without repeated AI charges',
      arcal: true,
      others: false,
    },
    {
      feature: 'Delete ingredient lines you did not eat (per-item)',
      arcal: true,
      others: false,
    },
    {
      feature: 'Add new lines + AI nutrition lookup for ingredients',
      arcal: true,
      others: false,
    },
    {
      feature: 'Describe / correct what is in the meal; refine with AI',
      arcal: true,
      others: false,
    },
    {
      feature: 'Free manual logging + free AI tokens to start',
      arcal: true,
      others: false,
    },
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

/** Matches lib/core/services/purchase_service.dart (Mar 2026 IAP) */
const energyPackages = [
  {
    name: 'Starter Pack',
    energy: 50,
    price: '$1.99',
    badge: null,
    featured: false,
  },
  {
    name: 'Standard Pack',
    energy: 200,
    price: '$5.99',
    badge: null,
    featured: false,
  },
  {
    name: 'Power Pack',
    energy: 500,
    price: '$12.99',
    badge: 'BEST VALUE',
    featured: true,
  },
];

/** Matches lib/features/subscription/models/subscription_plan.dart */
const energyPassPlans = [
  {
    name: 'Energy Pass — Monthly',
    price: '$9.99',
    period: '/ month',
    badge: null,
    featured: false,
  },
  {
    name: 'Energy Pass — Yearly',
    price: '$22.99',
    period: '/ year',
    badge: 'BEST VALUE',
    featured: true,
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
            One-time Energy packs never expire. Optional{' '}
            <strong className="font-medium text-gray-600">Energy Pass</strong>{' '}
            subscription for unlimited AI analysis (same as in the app). Manual
            logging stays free.
          </p>
        </div>

        <p className="mx-auto mt-10 max-w-2xl text-center text-sm font-semibold uppercase tracking-wide text-brand-800">
          Energy packs (one-time)
        </p>
        <div className="mx-auto mt-4 grid max-w-4xl gap-6 sm:grid-cols-3">
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

        <p className="mx-auto mt-14 max-w-2xl text-center text-sm font-semibold uppercase tracking-wide text-brand-800">
          Energy Pass (subscription)
        </p>
        <div className="mx-auto mt-4 grid max-w-2xl gap-6 sm:grid-cols-2">
          {energyPassPlans.map((plan) => (
            <div
              key={plan.name}
              className={`relative rounded-2xl border p-6 text-center transition-all hover:scale-105 ${
                plan.featured
                  ? 'border-brand-400 bg-white shadow-xl glow-green'
                  : 'border-gray-200 bg-white shadow-md'
              }`}
            >
              {plan.badge && (
                <div className="absolute -top-3 left-1/2 -translate-x-1/2 rounded-full bg-gradient-to-r from-brand-500 to-brand-700 px-3 py-1 text-xs font-bold text-white">
                  {plan.badge}
                </div>
              )}
              <div className="mt-2 flex items-baseline justify-center gap-1">
                <span className="text-3xl font-extrabold text-brand-950">
                  {plan.price}
                </span>
                <span className="text-sm text-gray-500">{plan.period}</span>
              </div>
              <div className="mt-3 text-sm text-gray-500">
                Unlimited AI analysis, exclusive badge, priority support
              </div>
              <div className="mt-4 text-xs text-gray-400">{plan.name}</div>
            </div>
          ))}
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
      <LazyWeightLossSection />
      <SocialProofStrip />
      <ShowcaseSection />
      <FeaturesGrid />
      <HowItWorksSection />
      <AiMealControlSection />
      <ComparisonSection />
      <PricingSection />
      <DownloadSection />
    </>
  );
}
