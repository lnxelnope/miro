import type { Metadata } from 'next';
import {
  Mail,
  MessageCircle,
  HelpCircle,
  ChevronDown,
  Camera,
  Zap,
  Shield,
  Smartphone,
  RefreshCw,
  Settings,
} from 'lucide-react';

export const metadata: Metadata = {
  title: 'Support — MiRO',
  description:
    'Get help with MiRO, the AI food tracker. Browse FAQs, troubleshooting guides, and contact our support team.',
};

const faqs = [
  {
    question: 'How do I get started with MiRO?',
    answer:
      'Download MiRO from Google Play or the App Store. No sign-up or account creation needed! You\'ll receive 10 free Energy tokens to try AI features right away. Just snap a photo of your food or type what you ate.',
    icon: Smartphone,
  },
  {
    question: 'What is Energy and how does it work?',
    answer:
      'Energy is MiRO\'s in-app currency for AI features. 1 Energy = 1 AI analysis (photo, label scan, or text lookup). Energy tokens never expire once purchased. Manual food logging is always free and doesn\'t cost any Energy.',
    icon: Zap,
  },
  {
    question: 'How accurate is the AI food analysis?',
    answer:
      'MiRO uses Google Gemini AI with 5 layers of precision: ingredient decomposition, sub-ingredient breakdown, cuisine preference bias, search mode selection, and user editing. The result is accuracy that no single AI model achieves alone. You can always fine-tune results by editing, adding, or removing ingredients.',
    icon: Camera,
  },
  {
    question: 'Is my data private and secure?',
    answer:
      'Absolutely. MiRO is offline-first — all your food data is stored locally on your device. No account is required, no login, and no personal information is collected. We can\'t see your data even if we wanted to. The only data sent to the cloud is when you use AI analysis (the photo is processed by Google Gemini and not stored).',
    icon: Shield,
  },
  {
    question: 'How do I transfer my data to a new device?',
    answer:
      'Go to Settings → Backup & Restore. You can create a backup file or generate a one-time Transfer Key (valid for 30 days). On your new device, install MiRO and use the restore option to import your data, Energy balance, and food history.',
    icon: RefreshCw,
  },
  {
    question: 'How does Health Sync work?',
    answer:
      'MiRO syncs two-way with Apple Health (iOS) and Google Health Connect (Android). Every food entry is automatically written to your Health app with full nutrition data. Active Energy burned is pulled back into MiRO to adjust your daily calorie goal in real time. Enable it in Settings → Health Sync.',
    icon: Settings,
  },
  {
    question: 'Can I cancel my Energy Pass subscription?',
    answer:
      'Yes, you can cancel anytime through your Google Play or App Store subscription settings. Your Energy Pass benefits remain active until the end of your billing period. Any purchased Energy tokens you own separately will remain in your account — they never expire.',
    icon: HelpCircle,
  },
  {
    question: 'Why does MiRO need camera permission?',
    answer:
      'MiRO uses your camera to photograph food for AI analysis. Photos are processed locally or sent securely to Google Gemini for analysis. MiRO also optionally accesses your photo gallery to find food photos you\'ve already taken (Gallery Auto-Scan feature). You can deny gallery access and still use the camera for direct snaps.',
    icon: Camera,
  },
];

function FAQItem({
  faq,
}: {
  faq: (typeof faqs)[0];
}) {
  return (
    <details className="glass-card group overflow-hidden">
      <summary className="flex cursor-pointer items-center gap-4 p-6 [&::-webkit-details-marker]:hidden">
        <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-brand-500/10 text-brand-400">
          <faq.icon size={20} />
        </div>
        <span className="flex-1 font-semibold">{faq.question}</span>
        <ChevronDown
          size={20}
          className="shrink-0 text-gray-500 transition-transform group-open:rotate-180"
        />
      </summary>
      <div className="border-t border-white/5 px-6 pb-6 pt-4 text-sm leading-relaxed text-gray-400">
        {faq.answer}
      </div>
    </details>
  );
}

export default function SupportPage() {
  return (
    <div className="pt-24 pb-16">
      {/* Hero */}
      <section className="hero-gradient pb-16 pt-12">
        <div className="mx-auto max-w-4xl px-4 text-center sm:px-6 lg:px-8">
          <h1 className="text-4xl font-bold tracking-tight sm:text-5xl">
            How can we <span className="gradient-text">help?</span>
          </h1>
          <p className="mx-auto mt-4 max-w-2xl text-lg text-gray-400">
            Find answers to common questions or reach out to our support team.
            We&apos;re here to help you get the most out of MiRO.
          </p>
        </div>
      </section>

      {/* Contact */}
      <section className="py-12">
        <div className="mx-auto max-w-4xl px-4 sm:px-6 lg:px-8">
          <div className="grid gap-6 sm:grid-cols-2">
            <a
              href="mailto:support@tnbgrp.com"
              className="glass-card flex items-center gap-4 p-6 transition-colors hover:border-brand-500/30"
            >
              <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-brand-500/10 text-brand-400">
                <Mail size={24} />
              </div>
              <div>
                <h3 className="font-semibold">Email Support</h3>
                <p className="text-sm text-gray-400">support@tnbgrp.com</p>
                <p className="text-xs text-gray-500">
                  We typically respond within 24 hours
                </p>
              </div>
            </a>

            <a
              href="mailto:feedback@tnbgrp.com"
              className="glass-card flex items-center gap-4 p-6 transition-colors hover:border-purple-500/30"
            >
              <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-purple-500/10 text-purple-400">
                <MessageCircle size={24} />
              </div>
              <div>
                <h3 className="font-semibold">Feedback & Suggestions</h3>
                <p className="text-sm text-gray-400">feedback@tnbgrp.com</p>
                <p className="text-xs text-gray-500">
                  We love hearing from our users
                </p>
              </div>
            </a>
          </div>
        </div>
      </section>

      {/* FAQ */}
      <section className="py-12">
        <div className="mx-auto max-w-4xl px-4 sm:px-6 lg:px-8">
          <h2 className="mb-8 text-2xl font-bold sm:text-3xl">
            Frequently Asked Questions
          </h2>
          <div className="space-y-4">
            {faqs.map((faq) => (
              <FAQItem key={faq.question} faq={faq} />
            ))}
          </div>
        </div>
      </section>

      {/* Troubleshooting */}
      <section className="py-12">
        <div className="mx-auto max-w-4xl px-4 sm:px-6 lg:px-8">
          <h2 className="mb-8 text-2xl font-bold sm:text-3xl">
            Troubleshooting
          </h2>
          <div className="grid gap-6 sm:grid-cols-2">
            <div className="glass-card p-6">
              <h3 className="mb-3 font-semibold text-brand-400">
                AI analysis not working?
              </h3>
              <ul className="space-y-2 text-sm text-gray-400">
                <li>• Check your internet connection (required for AI)</li>
                <li>• Ensure you have Energy tokens available</li>
                <li>• Try taking a clearer photo with better lighting</li>
                <li>• Restart the app and try again</li>
              </ul>
            </div>

            <div className="glass-card p-6">
              <h3 className="mb-3 font-semibold text-brand-400">
                Gallery scan not finding photos?
              </h3>
              <ul className="space-y-2 text-sm text-gray-400">
                <li>• Grant photo gallery permission in Settings</li>
                <li>• Pull down to refresh on the Timeline screen</li>
                <li>• Photos must be taken today to be detected</li>
                <li>• The AI identifies food photos automatically</li>
              </ul>
            </div>

            <div className="glass-card p-6">
              <h3 className="mb-3 font-semibold text-brand-400">
                Energy not showing after purchase?
              </h3>
              <ul className="space-y-2 text-sm text-gray-400">
                <li>• Wait a few seconds for the transaction to complete</li>
                <li>• Check your internet connection</li>
                <li>• Restart the app</li>
                <li>
                  • If the issue persists, email us with your purchase receipt
                </li>
              </ul>
            </div>

            <div className="glass-card p-6">
              <h3 className="mb-3 font-semibold text-brand-400">
                Health Sync not working?
              </h3>
              <ul className="space-y-2 text-sm text-gray-400">
                <li>
                  • Ensure Health Connect (Android) or Apple Health (iOS) is installed
                </li>
                <li>• Grant all required permissions when prompted</li>
                <li>• Enable Health Sync in MiRO Settings</li>
                <li>• Check that MiRO has write permission in your Health app</li>
              </ul>
            </div>
          </div>
        </div>
      </section>

      {/* App info */}
      <section className="py-12">
        <div className="mx-auto max-w-4xl px-4 sm:px-6 lg:px-8">
          <div className="glass-card p-8 text-center">
            <h2 className="mb-2 text-xl font-bold">MiRO — My Intake Record Oracle</h2>
            <p className="text-sm text-gray-400">
              Available on{' '}
              <a
                href="https://play.google.com/store/apps/details?id=com.tnbgrp.miro"
                className="text-brand-400 underline"
                target="_blank"
                rel="noopener noreferrer"
              >
                Google Play
              </a>{' '}
              and{' '}
              <a
                href="https://apps.apple.com/app/miro-my-intake-record-oracle/id6745498101"
                className="text-brand-400 underline"
                target="_blank"
                rel="noopener noreferrer"
              >
                App Store
              </a>
            </p>
            <p className="mt-4 text-xs text-gray-500">
              Published by TNB Group &middot; support@tnbgrp.com
            </p>
          </div>
        </div>
      </section>
    </div>
  );
}
